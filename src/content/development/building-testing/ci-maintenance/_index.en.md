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
