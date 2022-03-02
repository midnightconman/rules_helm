# TODO(midnightconman): Convert this to a toolchain
# more info can be found here: https://github.com/masmovil/bazel-rules/tree/master/toolchains
sh_binary(
    name = "helm",
    srcs = ["helm.sh"],
    data = select({
        "@bazel_tools//src/conditions:linux_x86_64": ["@helm//:allfiles"],
        "@bazel_tools//src/conditions:darwin": ["@helm_osx//:allfiles"],
    }),
    visibility = ["//visibility:public"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_library(
    name = "runfiles_bash",
    srcs = ["runfiles.bash"],
    visibility = ["//visibility:public"],
)

sh_test(
    name = "dummy_test",
    size = "small",
    srcs = [
        ".dummy_test.sh",
    ],
)

# TODO(midnightconman): Convert these to toolchains
sh_binary(
    name = "yq",
    srcs = ["yq.sh"],
    data = select({
        "@bazel_tools//src/conditions:linux_x86_64": ["@yq_linux//file"],
        "@bazel_tools//src/conditions:darwin": ["@yq_darwin//file"],
    }),
    visibility = ["//visibility:public"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)

sh_binary(
    name = "jq",
    srcs = ["jq.sh"],
    data = select({
        "@bazel_tools//src/conditions:linux_x86_64": ["@jq_linux//file"],
        "@bazel_tools//src/conditions:darwin": ["@jq_darwin//file"],
    }),
    visibility = ["//visibility:public"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
