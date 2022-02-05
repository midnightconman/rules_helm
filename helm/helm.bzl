# TODO(midnightconman): verify we don't need this
#load("@bazel_skylib//lib:paths.bzl", "paths")

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

for f in $(SRCS) ; do
  mv $$f $$TMP/templates/
done

mv $$TMP/templates $(RULEDIR)

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

def helm_template(name, out, chart, values_files = [], values = None):
    """Expand a helm chart to a json formatted file.

    Args:
        name: A unique name for this rule.
        out: The output file (in json).
        chart: The chart defined by helm_package.
        values_files: The values.yaml files to supply for the release.
        values: A map of additional values to supply for the release.
    """
    if values:
        set_params = _build_helm_set_args(values)

    # build --values param
    value_srcs = ["@com_github_midnightconman_rules_helm//:runfiles_bash"]
    values_param = []
    for f in values_files:
        values_param.append("--values=$(location %s)" % f)
        value_srcs.append(f)

    values_filegroup_name = name + "_values_filegroup"
    native.filegroup(
        name = values_filegroup_name,
        srcs = value_srcs,
    )

    # TODO(midnightconman): convert this to ctx.action.run instead of a genrule
    native.genrule(
        name = name,
        srcs = [chart] + [values_filegroup_name],
        outs = [out],
        tools = [
            "@com_github_midnightconman_rules_helm//:runfiles_bash",
            "@com_github_midnightconman_rules_helm//:helm",
            "@com_github_midnightconman_rules_helm//:jq",
            "@com_github_midnightconman_rules_helm//:yq",
            values_filegroup_name,
        ],
        cmd = """
TMP=$$(mktemp -d)
TMP_JSON=$$(mktemp)
tar xzf $(RULEDIR)/{chart} -C $$TMP
rm $(RULEDIR)/{chart}

CHARTLOC=$$(find $$TMP -name 'Chart.yaml' -exec dirname {{}} ';' )

$(location @com_github_midnightconman_rules_helm//:helm) template {name} $$CHARTLOC {template_flags} {set_params} {values_files} | \
    $(location @com_github_midnightconman_rules_helm//:yq) eval-all -j | \
    $(location @com_github_midnightconman_rules_helm//:jq) -s '.' > $@
rm $$TMP_JSON
""".format(
            name = name,
            chart = chart,
            template_flags = "",
            set_params = set_params,
            values_files = " ".join(values_param),
        ),
    )
