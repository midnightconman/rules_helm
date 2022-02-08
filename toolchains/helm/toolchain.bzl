HelmToolchainInfo = provider(
    doc = "Helm toolchain",
    fields = {
        "tool": "Helm executable binary",
    },
)

def _helm_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        helminfo = HelmToolchainInfo(
            tool = ctx.attr.tool,
        ),
    )
    return [toolchain_info]

helm_toolchain = rule(
    implementation = _helm_toolchain_impl,
    attrs = {
        "tool": attr.label(allow_single_file = True),
    },
)
