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

To prune all Submariner-provided images, ensuring they will be rebuilt or pulled the next time they’re required:

```shell
make prune-images
```

### End-to-End Tests

To run functional end-to-end tests with a full multi-cluster deployment:

```shell
make e2e
```

Different types of deployments can be configured with `using` flags:

```shell
make e2e using=helm,globalnet
```

See [Shipyard's `Makefile.inc`](https://github.com/submariner-io/shipyard/blob/devel/Makefile.inc) for the currently-supported `using` flags.

A subset of tests can be selected with Ginkgo `focus` flags:

```shell
make e2e focus=dataplane
```

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
make clean-clusters
```

### Shell Session in Development Environment

To jump into a shell in Submariner's standard development environment:

```shell
make shell
```

## Known issues

### OSX getopt and sed are incompatible with our scripts

symptoms:
```
  flags:ERROR short flag required for (tag) on this platform and "docker buildx build" requires exactly 1 argument
```

or

```
sed: 1: "/"DAPPER_RUN_ARGS=/{s/[ ...": extra characters at the end of q command
docker: invalid reference format: repository name must be lowercase.
```

This problem is seen in OSX while running make because the OSX shipped `getopt` tool is very limited.
To fix this issue you need to install gnu-getopt:

`brew install gnu-getopt`
`brew install gnu-sed`

And then make it available in your shell:

`echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH' >> ~/.bash_profile`
`echo 'export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH' >> ~/.bash_profile`"
