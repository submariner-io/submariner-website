---
title: "Working with Shipyard"
date: 2020-04-20T17:12:52+0300
weight: 60
---

## Overview

The Shipyard project provides common tooling for creating Kubernetes clusters with [kind](https://github.com/kubernetes-sigs/kind)
(Kubernetes in Docker) and provides a common Go framework for creating end to end tests.
Shipyard contains common functionality shared by other projects. Any project specific functionality should be part of that project.

A base image `quay.io/submariner/shipyard-dapper-base` is created from Shipyard and contains all the tooling to build other projects and run
tests in a consistent environment.

Shipyard has several folders at the root of the project:

* **package:** Contains the ingredients to build the base images.
* **scripts:** Contains general scripts for Shipyard make targets.
  * **shared:** Contains all the shared scripts that projects can consume. These are copied into the base image under `$SCRIPTS_DIR`.
    * **lib:** Library functions that shared scripts, or consuming projects, can use.
    * **resources:** Resource files to be used by the shared scripts.
* **test:** Test library to be used by other projects.

Shipyard ships with some [shared](targets) and [image related](images) Make targets which can be used by developers in
consuming projects.

## Usage

A developer can use the `make` command to interact with a project (which in turn uses Shipyard).

To see all targets defined in a project, run:

```shell
make targets
```

The most common targets would be `clusters`, `deploy` and `e2e` which are built as a "dependency graph" -
`e2e` will `deploy` Submariner if its not deployed, which in turn calls `clusters` to create the deployment environment.
Therefore, variables used in any "dependent" target will be propagated to it's dependencies.

### Simplified Usage Options

For ease of use and convenience, many of the shared targets support a simplified usage model using the special **`USING`** variable.
The value is a space separated string of usage options.
Specifying conflicting options (e.g. **`wireguard`** and **`libreswan`**) will work, but the outcome should not be considered predictable.
Any non-existing options will be silently ignored.

For example, to deploy an environment that uses Globalnet, Lighthouse and a WireGuard cable driver use:

```shell
make deploy USING='globalnet lighthouse wireguard'
```

#### Highlighted **`USING`** Options

* General deployment:
  * **`aws-ocp`**: Deploy on top of AWS using OCP (OpenShift Container Platform).
  * **`globalnet`**: Deploy clusters with overlapping CIDRs, and Submariner in *Globalnet* mode.
  * **`lighthouse`**: Deploy service discovery (Lighthouse) in addition to the basic deployment.
  * **`ovn`**: Deploy the clusters with the OVN CNI.
  * **`air-gap`**: Deploy clusters in a simulated air-gapped (disconnected) environment. 
* Deployment tools.
  * **`helm`**: Deploy clusters using Helm.
  * **`operator`**: Deploy clusters using the Submariner Operator.
* Cable drivers:
  * **`libreswan`**: Use the Libreswan cable driver when deploying the clusters.
  * **`vxlan`**: Use the VXLAN cable driver when deploying the clusters.
  * **`wireguard`**: Use the WireGuard cable driver when deploying the clusters.
* Testing:
  * **`subctl-verify`**: Force [end-to-end tests](../building-testing#e2e) to run with `subctl verify`, irrespective of any possible
    project-specific tests.

### How to Add Shipyard to a Project

The project should have a **`Makefile`** that contains all the projects targets, and imports all the Shipyard targets.

In case you're adding Shipyard to a project that doesn't have it yet, use the following skeleton:

```makefile
BASE_BRANCH ?= devel

# Running in Dapper
ifneq (,$(DAPPER_HOST_ARCH))
include $(SHIPYARD_DIR)/Makefile.inc

### All your specific targets and settings go here. ###

# Not running in Dapper
else

Makefile.dapper:
        @echo Downloading $@
        @curl -sfLO https://raw.githubusercontent.com/submariner-io/shipyard/$(BASE_BRANCH)/$@

include Makefile.dapper

endif
```

You can also refer to the project's own [Makefile] as an example.

### Use Shipyard in Your Project

Once Shipyard has been added to a project, you can use any of the [shared targets](targets) that it provides.

### Have Shipyard Targets Depend on Your Project's Targets

Having any of the Shipyard Makefile targets rely on your project's specific targets can be done easily by adding the dependency in your
project's Makefile. For example:

```Makefile
clusters: <pre-cluster-target>
```

### Use an Updated Images in Your Project

#### Test an Updated Shipyard Image

If you've made changes to Shipyard's targets and need to test them in your project, run this command in the Shipyard directory:

```shell
make images
```

This creates a local image with your changes available for consumption in other projects.

#### Test Updated Images from Sibling Project(s)

In case you made changes in a sibling project and wish to test with that project's images, first rebuild the images:

```shell
cd <path/to/sibling project>
make images
```

These images will be available in the local docker image cache, but not necessarily used by the project when deploying.
To use these images, set the `PRELOAD_IMAGES` variable to the projects images and any sibling images.

For example, to use updated gateway images when deploying on the operator repository:

```shell
make deploy PRELOAD_IMAGES='submariner-operator submariner-gateway'
```

[Makefile]: https://github.com/submariner-io/shipyard/blob/devel/Makefile
