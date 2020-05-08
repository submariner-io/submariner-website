---
title: "Building and Testing"
date: 2020-03-18T16:03:26+01:00
weight: 10
---

Submariner strives to be an open, welcoming community for developers.
Substantial tooling is provided to ease the contribution experience.

## Standard Development Environment

Submariner provides a standard, shared development environment suitable for all
local work. The same environment is used in CI.

The [submariner-io/shipyard](https://github.com/submariner-io/shipyard) project
contains the logic to build the base container images used across all
submariner-io repositories.

Learn more about working with Shipyard [here](../shipyard).

## Prescribed Tasks via Make Targets

Make targets are provided to further ease the process of using the shared
development environment. The specific make targets available might differ by
repository. For any submariner-io repository, see the `Makefile` at the root of
the repository for the supported targets and the `.travis.yml` file for the
targets actually used in CI.

## Common Build and Testing Targets

All **submariner-io/**\* repositories provide a standard set of Make targets for
similar building and testing actions.

### Linting

To run static Go linting (goimports, golangci-lint):

```
make validate
```

### Unit tests

To run Go unit tests:

```
make test
```

### Multi-Cluster KIND Based Environment {#clusters}

Shipyard provides a basic target that creates a KIND based multi-cluster
environment, without any special deployment (apart from the default K8s):

```
make clusters
```

Find out more about [Shipyard's clusters target](../shipyard#clusters).

### Multi-Cluster Submariner Deployment

Shipyard provides a basic target that deploys submariner on a KIND based
multi-cluster environment (if one isn't yet created, this target will first invoke the clusters target to do so):
as well):

```
make deploy
```

Find out more about [Shipyard's deploy target](../shipyard#deploy).

### End-to-End Tests

To run functional end-to-end tests with a full multi-cluster deployment (if one isn't yet deployed, this target will first invoke the deploy target to do so):

```
make e2e
```

Optionally, you can specify flags to control the execution of the end-to-end
testing and deployment (if it wasn't run separately).
Currently these flags are project-specific, so consult the project's
`Makefile` to learn which flags are supported.
The flags can be combined or used separately, or not at all (in which case
default values apply).

For example, here's a flag variation used in **submariner-io/submariner** CI:

```
make e2e deploytool=helm globalnet=true
```

### Environment Clean Up

To clean up all the KIND clusters deployed in any of the previous steps, use:

```
make cleanup
```

Learn more about Shipyard's cleanup target [here](../shipyard#cleanup).

## submariner-io/submariner

### Building Engine, Routeagent, and Globalnet Go binaries

To build the `submariner-route-agent`, `submariner-engine`, and
`submariner-globalnet` Go binaries, in the [submariner-io/submariner][1]
repository:

```
make build
```

There is an optional flag to build with debug flags set:

```
make build --build_debug=true
```

### Building Engine, Routeagent, and Globalnet container images

To build the `submariner/submariner`, `submariner/submariner-route-agent`, and
`submariner/submariner-globalnet` container images, in the
[submariner-io/submariner][1] repository:

```
make images
```

## submariner-io/submariner-operator

### Building the Operator and subctl

To build the `submariner-operator` container image and the `subctl` Go binary,
in the [submariner-io/submariner-operator][2] repository:

```
make build
```

## submariner-io/lighthouse

### Building Lighthouse Controller, CoreDNS and DNSServer container images

To build the `lighthouse-agent` and `lighthouse-coredns` contaienr images, in the [submariner-io/lighthouse][3]
repository:

```
make build-agent build-coredns
```

## submariner-io/shipyard

### Building dapper-base container image

To build the base container image used in the shared developer and CI
enviroment, in the [submariner-io/shipyard][4]:

```
make dapper-image
```

[1]: https://github.com/submariner-io/submariner
[2]: https://github.com/submariner-io/submariner-operator
[3]: https://github.com/submariner-io/lighthouse
[4]: https://github.com/submariner-io/shipyard
