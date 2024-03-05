---
title: "CI/CD Maintenance"
date: 2022-01-05T16:03:26+01:00
weight: 10
---

This page documents the maintenance of Submariner's CI/CD for developers.

## Custom GitHub Actions

We have built some custom GitHub Actions in Shipyard for project-internal use.
They have dependencies on public GitHub Actions that need to be periodically updated.

```text
[~/go/src/submariner-io/shipyard/gh-actions]$ grep -rni uses
e2e/action.yaml:77:      uses: submariner-io/shipyard/gh-actions/restore-images@devel
release-images/action.yaml:17:      uses: docker/setup-qemu-action@e81a89b1732b9c48d79cd809d8d81d79c4647a18
release-images/action.yaml:19:      uses: docker/setup-buildx-action@4b4e9c3e2d4531116a6f8ba8e71fc6e2cb6e6c8c
cache-images/action.yaml:14:      uses: actions/cache@88522ab9f39a2ea568f7027eddc7d8d8bc9d59c8
restore-images/action.yaml:18:      uses: actions/cache@88522ab9f39a2ea568f7027eddc7d8d8bc9d59c8
```

[`submariner-io/shipyard/gh-actions`](https://github.com/submariner-io/shipyard/tree/devel/gh-actions)

## GitHub Actions

All our projects use GitHub Actions.
These include dependencies which should be regularly checked for updates.
Dependabot should be used to submit PRs to keep all GitHub Actions up-to-date.
Hash-based versions should always be used to ensure there are no changes without an update on our side.

For example, this GitHub Action dependency:

```yaml
    steps:
      - name: Check out the repository
        uses: actions/checkout@5a4ac9002d0be2fb38bd78e4b4dbde5606d7042f
        with:
          fetch-depth: 0
```

Would be updated by this Dependabot configuration:

```yaml
---
version: 2
updates:
  - package-ecosystem: github-actions
    directory: '/'
    schedule:
      interval: daily
```

Dependabot will only submit updates when projects make releases. That may leave CI broken waiting on a release while a fix is available.
If a project has a fix but has not made a release that includes it, we should manually update the SHA we consume to include the fix.
In particular, some projects "release" fixes by moving a tag to a point in git history that includes the fix.
They assume versioning like `gaurav-nelson/github-action-markdown-link-check@v1`.
Again, we should always use SHA-based versions, not moveable references like tags, to help mitigate supply-chain attacks.

## Kubernetes Versions

The versions of Kubernetes tested in Submariner's CI need to be updated for new [Kubernetes releases](https://kubernetes.io/releases/).

Submariner's policy is to support all versions upstream-Kubernetes supports and no EOL versions.

The versions that should be used in CI are described below.

<!-- markdownlint-disable line-length -->
CI | Kubernetes Version | Notes
:--- | :---- | :----
Most CI | Latest | CI should run against the latest Kubernetes version by default.
Full E2E | Top/bottom of supported range | Full E2E CI matrix should use the latest Kubernetes version and the oldest non-EOL Kubernetes version.
Full Kubernetes Support | All other non-latest supported versions | Full E2E CI matrix with all non-EOL Kubernetes versions not tested in E2E-Full. Run periodically, on releases, or manually by adding the `e2e-all-k8s` label.
Unsupported Kubernetes Cut-off | Oldest working version | E2E for the oldest Kubernetes version known to work with Submariner. This tests the cut-off version used by `subctl` to prevent installing Submariner in environments that are known to be unsupported.
<!-- markdownlint-enable line-length -->

## Shipyard Base Image Software

In branches older than 0.16, some versions of software used by the Shipyard base image are maintained manually and should be periodically updated.

```shell
ENV LINT_VERSION=<version> \
    HELM_VERSION=<version> \
    KIND_VERSION=<version> \
    BUILDX_VERSION=<version> \
    GH_VERSION=<version> \
    YQ_VERSION=<version>
```

[`submariner-io/shipyard/package/Dockerfile.shipyard-dapper-base`](https://github.com/submariner-io/shipyard/blob/devel/package/Dockerfile.shipyard-dapper-base)

## Shipyard Linting Image Software

Some software used by Shipyard's linting image are pinned to avoid unplanned changes in linting requirements, which can cause disruption.
These versions should be periodically updated.

```shell
ENV MARKDOWNLINT_VERSION=0.33.0 \
    GITLINT_VERSION=0.19.1
```

[`submariner-io/shipyard/package/Dockerfile.shipyard-linting`](https://github.com/submariner-io/shipyard/blob/devel/package/Dockerfile.shipyard-linting)
