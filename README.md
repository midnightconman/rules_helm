# rules_helm

This repository contains Bazel rules to consume and produce Helm charts with Bazel.

**NOTE:** This work was inspired by [https://github.com/tmc/rules_helm](https://github.com/tmc/rules_helm), but takes mostly the opposite focus of this repo... to execute (install, test, or delete) helm charts against a Kubernetes cluster. If you are looking for that pattern, please check out their repo.

## Documentation

* See [Rule and macro defintions](./docs/docs.md) for macro documentation.

### API

* helm_package - a helm chart in tar.gz format, with a `Chart.yaml` and any other metadata / config. helm_package targets can be used as dependencies for other helm_package declarations.
* helm_template - expand a helm chart to a yaml formatted file.

### Getting started

In your Bazel `WORKSPACE` file add this repository as a dependency:

```
RULES_HELM_VERSION = "0.1.0"

RULES_HELM_CHECKSUM = ""

http_archive(
    name = "com_github_midnightconman_rules_helm",
    sha256 = RULES_HELM_CHECKSUM,
    strip_prefix = "rules_helm-" + RULES_HELM_VERSION,
    urls = ["https://github.com/midnightconman/rules_helm/archive/v" + RULES_HELM_VERSION + "tar.gz"],
)
```

Then in your `BUILD` files include the `helm_package` and / or `helm_template` rules:

`charts/a-great-chart/zBUILD`:
```python
load("@com_github_midnightconman_rules_helm//:helm.bzl", "helm_package")

package(default_visibility = ["//visibility:public"])

helm_package(
    name = "a_great_chart",
    srcs = glob(["**"]),
)
```
