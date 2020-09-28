---
title: "Building and Testing"
date: 2020-03-18T16:03:26+01:00
weight: 10
---

Submariner strives to be an open, welcoming community. Substantial tooling is provided to ease the contribution experience.

## Standard Development Environment

Submariner provides a standard, shared environment for both development and CI that is maintained in the
[Shipyard](https://github.com/submariner-io/shipyard) project.

Learn more about working with Shipyard [here](../shipyard).

## Building and Testing

Submariner provides a set of Make targets for building and testing in the standard development environment.

### Linting

To run all linting:

```shell
make lint
```

There are also Make targets for each type of linting:

```shell
make gitlint golangci-lint markdownlint yamllint
```

See the linter configuration files at the root of each repository for details about which checks are enabled.

Note that a few linters only run in CI via GitHub Actions and are not available in the standard development environment.

### Unit Tests

To run Go unit tests:

```shell
make unit
```

### Building

To build the Go binaries provided by a repository:

```shell
make build
```

To package those Go binaries into container images:

```shell
make images
```

Note that Submariner will automatically rebuild binaries and images when they have been modified and are required by tests.

### End-to-End Tests

To run functional end-to-end tests with a full multi-cluster deployment:

```shell
make e2e
```

Different types of deployments can be configured with `using` flags:

```shell
make e2e using=helm,globalnet
```

See [Shipyard's `Makefile.inc`](https://github.com/submariner-io/shipyard/blob/master/Makefile.inc) for the currently-supported `using` flags.

To create a multi-cluster deployment and install Submariner but not run tests:

```shell
make deploy
```

To create a multi-cluster deployment without Submariner:

```shell
make clusters
```

To clean up a multi-cluster deployment from one of the previous commands:

```shell
make cleanup
```

### Shell Session in Development Environment

To jump into a shell in Submariner's standard development environment:

```shell
make shell
```
