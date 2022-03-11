---
title: "CI/CD Maintenance"
date: 2022-01-05T16:03:26+01:00
weight: 10
---

This page documents the maintenance of Submariner's CI/CD for developers.

## Kubernetes Versions

The versions of Kubernetes tested in Submariner's CI need to be updated for new [Kubernetes releases](https://kubernetes.io/releases/).

Submariner's policy is to support all versions upstream-Kubernetes supports and no EOL versions.

The versions that should be used in CI are described below.

<!-- markdownlint-disable line-length -->
CI | Kubernetes Version | Notes
:--- | :---- | :----
Most CI | Latest | CI should run against the latest Kubernetes version by default.
Basic Kubernetes Support | All non-latest supported versions | One defaults-only E2E for each non-latest supported Kubernetes version.
Full Kubernetes Support | All non-latest supported versions | Workflow to run all CI for all of the currently-supported, non-latest Kubernetes versions. Run periodically, on releases, or manually by adding the `e2e-all-k8s` label.
Unsupported Kubernetes Cut-off | Oldest working version | One defaults-only E2E for the oldest Kubernetes version known to work with Submariner. This tests the cut-off version used by `subctl` to prevent installing Submariner in environments that are known to be unsupported.
<!-- markdownlint-enable line-length -->

## Shipyard Base Image Software

Some versions of software used by the Shipyard base image are maintained manually and should be periodically updated.

```shell
ENV LINT_VERSION=<version> \
    HELM_VERSION=<version> \
    KIND_VERSION=<version> \
    BUILDX_VERSION=<version> \
    GH_VERSION=<version> \
    YQ_VERSION=<version>
```

[`submariner-io/shipyard/package/Dockerfile.shipyard-dapper-base`](https://github.com/submariner-io/shipyard/blob/devel/package/Dockerfile.shipyard-dapper-base)

## Shflags Library Version

Shipyard uses the shflags library. Because it must be downloaded (if missing) and sourced at the start of Shipyard's shared scripts, the
version is maintained in a special place and must be manually updated.

```shell
SHFLAGS_VERSION=${SHFLAGS_VERSION:=<version>}
```

[`submariner-io/shipyard/scripts/shared/lib/shflags`](https://github.com/submariner-io/shipyard/blob/devel/scripts/shared/lib/shflags)

## GitHub actions

All our projects use GitHub actions.
These include dependencies which should be regularly checked for updates;
because we specify them using hashes, dependabot and other such tools don't identify available updates for us.

For example, in the website repository,

```yaml
    steps:
      - name: Check out the repository
        uses: actions/checkout@5a4ac9002d0be2fb38bd78e4b4dbde5606d7042f
        with:
          fetch-depth: 0
```

should be checked by looking at the `checkout` [releases](https://github.com/actions/checkout/releases).
