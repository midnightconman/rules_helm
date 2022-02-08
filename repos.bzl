load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

HELM_VERSION = "3.7.1"

YQ_VERSION = "4.11.1"

JQ_VERSION = "1.6"

def helm_repositories():
    HELM_BUILD_FILE_CONTENT = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "allfiles",
    srcs = glob([
        "**/helm",
    ]),
)
    """

    http_archive(
        name = "helm_linux",
        sha256 = "6cd6cad4b97e10c33c978ff3ac97bb42b68f79766f1d2284cfd62ec04cd177f4",
        urls = ["https://get.helm.sh/helm-v" + HELM_VERSION + "-linux-amd64.tar.gz"],
        build_file_content = HELM_BUILD_FILE_CONTENT,
    )

    http_archive(
        name = "helm_darwin",
        sha256 = "3a9efe337c61a61b3e160da919ac7af8cded8945b75706e401f3655a89d53ef5",
        urls = ["https://get.helm.sh/helm-v" + HELM_VERSION + "-darwin-amd64.tar.gz"],
        build_file_content = HELM_BUILD_FILE_CONTENT,
    )

def jq_repositories():
    http_file(
        name = "jq_linux",
        urls = ["https://github.com/stedolan/jq/releases/download/jq-%s/jq-linux64" % JQ_VERSION],
        sha256 = "af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44",
        downloaded_file_path = "jq",
        executable = True,
    )

    http_file(
        name = "jq_darwin",
        urls = ["https://github.com/stedolan/jq/releases/download/jq-%s/jq-osx-amd64" % JQ_VERSION],
        sha256 = "5c0a0a3ea600f302ee458b30317425dd9632d1ad8882259fcaf4e9b868b2b1ef",
        downloaded_file_path = "jq",
        executable = True,
    )

def yq_repositories():
    http_file(
        name = "yq_linux",
        urls = ["https://github.com/mikefarah/yq/releases/download/v%s/yq_linux_amd64" % YQ_VERSION],
        sha256 = "1f63c9fe412c0d17b263e0ccfd91a596bb359db69ef7dddf5f53af1b2e8db898",
        downloaded_file_path = "yq",
        executable = True,
    )

    http_file(
        name = "yq_darwin",
        urls = ["https://github.com/mikefarah/yq/releases/download/v%s/yq_darwin_amd64" % YQ_VERSION],
        sha256 = "95244750f0d9e2bd37b48e473823cc8dacf8ccc8a69fd5bbd20fe023bfead002",
        downloaded_file_path = "yq",
        executable = True,
    )

def repositories():
    helm_repositories()
    jq_repositories()
    yq_repositories()

    native.register_toolchains(
        "@com_github_midnightconman_rules_helm//toolchains/helm:helm_linux_toolchain",
        "@com_github_midnightconman_rules_helm//toolchains/helm:helm_osx_toolchain",
        "@com_github_midnightconman_rules_helm//toolchains/jq:jq_linux_toolchain",
        "@com_github_midnightconman_rules_helm//toolchains/jq:jq_osx_toolchain",
        "@com_github_midnightconman_rules_helm//toolchains/yq:yq_linux_toolchain",
        "@com_github_midnightconman_rules_helm//toolchains/yq:yq_osx_toolchain",
    )
