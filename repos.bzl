load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")

def helm_repositories():
    skylib_version = "0.8.0"
    http_archive(
        name = "bazel_skylib",
        type = "tar.gz",
        url = "https://github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib.{}.tar.gz".format(skylib_version, skylib_version),
        sha256 = "2ef429f5d7ce7111263289644d233707dba35e39696377ebab8b0bc701f7818e",
    )

    HELM_VERSION = "3.7.1"

    HELM_BUILD_FILE_CONTENT = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "allfiles",
    srcs = glob([
        "**/*",
    ]),
)
    """

    http_archive(
        name = "helm",
        sha256 = "6cd6cad4b97e10c33c978ff3ac97bb42b68f79766f1d2284cfd62ec04cd177f4",
        urls = ["https://get.helm.sh/helm-v" + HELM_VERSION + "-linux-amd64.tar.gz"],
        build_file_content = HELM_BUILD_FILE_CONTENT,
    )

    http_archive(
        name = "helm_osx",
        sha256 = "3a9efe337c61a61b3e160da919ac7af8cded8945b75706e401f3655a89d53ef5",
        urls = ["https://get.helm.sh/helm-v" + HELM_VERSION + "-darwin-amd64.tar.gz"],
        build_file_content = HELM_BUILD_FILE_CONTENT,
    )
