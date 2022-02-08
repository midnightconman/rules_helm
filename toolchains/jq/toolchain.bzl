JqToolchainInfo = provider(
    doc = "jq toolchain rule parameters",
    fields = {
        "tool": "Path to the jq executable",
    },
)

def _jq_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        jqinfo = JqToolchainInfo(
            tool = ctx.attr.tool,
        ),
    )
    return [toolchain_info]

jq_toolchain = rule(
    implementation = _jq_toolchain_impl,
    attrs = {
        "tool": attr.label(allow_single_file = True),
    },
)
