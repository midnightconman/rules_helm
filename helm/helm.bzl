# TODO(midnightconman): verify we don't need this
#load("@bazel_skylib//lib:paths.bzl", "paths")

HELM_CMD_PREFIX = """
echo "#!/usr/bin/env bash" > $@
cat $(location @com_github_midnightconman_rules_helm//:runfiles_bash) >> $@
echo "export NAMESPACE=$$(grep NAMESPACE bazel-out/stable-status.txt | cut -d ' ' -f 2)" >> $@
echo "export BUILD_USER=$$(grep BUILD_USER bazel-out/stable-status.txt | cut -d ' ' -f 2)" >> $@
cat <<EOF >> $@
#export RUNFILES_LIB_DEBUG=1 # For runfiles debugging

export HELM=\\$$(rlocation com_github_midnightconman_rules_helm/helm)
PATH=\\$$(dirname \\$$HELM):\\$$PATH
"""

# TODO(midnightconman): add an _impl here
#def _impl(ctx):
#    out_file = ctx.actions.declare_file("%s.dtree" % ctx.attr.name)
#    ctx.actions.run(
#        inputs = [ctx.file.deps],
#        outputs = [out_file],
#        executable = ctx.executable.dep_tool,
#        progress_message = "Parsing Dependencies",
#        arguments = [
#            "--output_file=%s" % out_file.path,
#            "--deps_file=%s" % ctx.file.deps.path,
#        ],
#    )
#
#    return [DefaultInfo(files = depset([out_file]))]
#
#_helm_package = rule(
#    attrs = {
#        "name": attr.label(
#            mandatory = True,
#            doc = "name",
#        ),
#        "templates": attr.label(
#            mandatory = True,
#            allow_single_file = True,
#            doc = "Template files to be placed in the /template directory in the final chart",
#        ),
#    },
#    implementation = _impl,
#)

# TODO(midnightconman): Add chart.yaml parameters and content option here
# TODO(midnightconman): Figure out a safe way to support chart dependencies
def helm_package(name, templates, chart_deps = "", version = "0.0.0"):
    """Defines a helm chart (directory containing a Chart.yaml).

    Args:
        name: A unique name for this rule.
        chart_deps: A string (optional) in yaml format that can be used to add remote chart dependencies. Please note this option doesn't work correctly yet.
        version: A string in semantic version format, to set as the charts version.
        templates: Source files to include as the helm chart. Typically this will just be glob(["**"]).
    """
    templates_filegroup_name = name + "_templates_filegroup"
    helm_cmd_name = name + "_package.sh"
    package_flags = ""
    native.filegroup(
        name = templates_filegroup_name,
        srcs = templates,
    )

    # TODO(midnightconman): convert this to ctx.action.run instead of a genrule
    native.genrule(
        name = name,
        srcs = [templates_filegroup_name],
        outs = ["%s-%s.tgz" % (name, version)],
        tools = ["@com_github_midnightconman_rules_helm//:helm"],
        # TODO(midnightconman): This should create a simple Chart.yaml if content is not provided
        cmd = """
TMP=$$(mktemp -d)
mkdir -p $$TMP/templates
mv $(RULEDIR) $$TMP/templates
mv $$TMP $(RULEDIR)

# Write Chart.yaml
echo "name: {name}
version: {version}" > $(RULEDIR)/Chart.yaml

[[ ! -z "{chart_deps}" ]] && echo "dependencies:\n{chart_deps}" >> $(RULEDIR)/Chart.yaml

$(location @com_github_midnightconman_rules_helm//:helm) package {package_flags} $(RULEDIR)
mv *tgz $@
""".format(
            chart_deps = chart_deps,
            name = name,
            package_flags = package_flags,
            version = version,
        ),
    )

def _build_helm_set_args(values):
    set_args = ["--set=%s=%s" % (key, values[key]) for key in sorted((values or {}).keys())]
    return " ".join(set_args)

def _helm_cmd(cmd, name, helm_cmd_name, values_yaml = None, values = None):
    args = []
    binary_data = ["@com_github_midnightconman_rules_helm//:helm"]
    if values_yaml:
        binary_data.append(values_yaml)
    if values:
        args.append(_build_helm_set_args(values))

    native.sh_binary(
        name = name + "." + cmd,
        srcs = [helm_cmd_name],
        deps = ["@bazel_tools//tools/bash/runfiles"],
        data = binary_data,
        args = args,
    )

def helm_template(name, chart, values_yaml = None, values = None):
    """Expand a helm chart to a yaml formatted file.

    A given target has the following executable targets generated:

    `(target_name).output`

    Args:
        name: A unique name for this rule.
        chart: The chart defined by helm_package.
        values_yaml: The values.yaml file to supply for the release.
        values: A map of additional values to supply for the release.
    """
    helm_cmd_name = name + "_run_helm_cmd.sh"
    genrule_srcs = ["@com_github_midnightconman_rules_helm//:runfiles_bash", chart]

    # build --set params
    set_params = _build_helm_set_args(values)

    # build --values param
    values_param = ""
    if values_yaml:
        values_param = "--values=$(location %s)" % values_yaml
        genrule_srcs.append(values_yaml)

    native.genrule(
        name = name,
        stamp = True,
        srcs = genrule_srcs,
        outs = [helm_cmd_name],
        cmd = HELM_CMD_PREFIX + """
export CHARTLOC=$(location """ + chart + """)
if [ "\\$$1" == "output" ]; then
    helm template \\$$@ """ + name + " " + """ \\$$CHARTLOC """ + " " + set_params + " " + values_param + """ + " | tee $@"
else
    helm template \\$$@ """ + name + " " + """ \\$$CHARTLOC """ + " " + set_params + " " + values_param + """ + " | tee $@"
fi

EOF""",
    )
    _helm_cmd("output", name, helm_cmd_name, values_yaml, values)
