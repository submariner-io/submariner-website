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

* **package:** Contains the ingredients to build the base image.
* **scripts:** Contains general scripts for Shipyard make targets.
  * **shared:** Contains all the shared scripts that projects can consume. These are copied into the base image under `$SCRIPTS_DIR`.
    * **lib:** Library functions that shared scripts, or consuming projects, can use.
    * **resources:** Resource files to be used by the shared scripts.
* **test:** Test library to be used by other projects.

Shipyard ships with some [Makefile targets](#shared-makefile-targets) which can be used by consuming projects and are used by Shipyard's CI
to test and validate itself. It also has some [specific Makefile targets](#specific-makefile-targets) which are used by the project itself.

## Usage

### Add Shipyard to a Project

To enable usage of Shipyard's functionality, please see [Adding Shipyard to a Project](first-time).

### Use Shipyard in Your Project

Once Shipyard has been added to a project, you can use any of the [Makefile targets](#shared-makefile-targets) that it provides.

Any variables that you need to pass to these targets should be specified in your Dockerfile.dapper so they're available in the Dapper
environment. For example:

```Dockerfile
ENV DAPPER_ENV="REPO TAG QUAY_USERNAME QUAY_PASSWORD TRAVIS_COMMIT CLUSTERS_ARGS DEPLOY_ARGS"
```

### Have Shipyard Targets Depend on Your Project's Targets

Having any of the Shipyard Makefile targets rely on your project's specific targets can be done easily by adding the dependency in your
project's Makefile. For example:

```Makefile
clusters: build images
```

### Use an Updated Shipyard Image in Your Project

If you've made changes to Shipyard's [base image](#dapper-image) and need to test them in your project, run:

```shell
make dapper-image
```

in the Shipyard directory. This creates a local image with your changes available for consumption in other projects.

## Shared Makefile Targets

Shipyard ships a [Makefile.inc] file which defines these basic targets:

* **[clusters](#clusters):** Creates the kind-based cluster environment.
* **[deploy](#deploy)** : Deploys Submariner components in the cluster environment (depends on clusters).
* **[clean-clusters](#cleanclusters):** Deletes the kind environment (if it exists) and any residual resources.
* **[clean-generated](#cleangenerated):** Deletes all generated files.
* **[clean](#clean):** Cleans everything up (running clusters and generated files).
* **[release](#release):** Uploads the requested image(s) to Quay.io.
* **vendor/modules.txt:** Populates go modules (in case go.mod exists in the root directory).

If your project uses Shipyard then it has all these targets and supports all the variables these targets support.

Any variables supported by these targets can be either declared as environment variables or assigned on the `make` command line (takes
precedence over environment variables).

### Clusters {#clusters}

A Make target that creates a kind-based multi-cluster environment with just the default Kubernetes deployment:

```shell
make clusters
```

Respected variables:

* **CLUSTERS_ARGS:** Any arguments (flags and/or values) to be sent to the `clusters.sh` script. To get a list of available arguments, run:
  `scripts/shared/clusters.sh --help`

### Deploy {#deploy}

A Make target that deploys Submariner components in a kind-based cluster environment (if one isn't created yet, this target will first
invoke the clusters target to do so):

```shell
make deploy
```

Respected variables:

* Any variable from [clusters](#clusters) target (only if it wasn't created).
* **DEPLOY_ARGS:** Any arguments (flags and/or values) to be sent to the `deploy.sh` script. To get a list of available arguments, run:
  `scripts/shared/deploy.sh --help`

### Clean-clusters {#cleanclusters}

To clean up all the kind clusters deployed in any of the previous steps, use:

```shell
make clean-clusters
```

This command will remove the clusters and any resources that might've been left in docker that are not needed any more (images, volumes,
etc).

### Clean-generated {#cleangenerated}

To clean up all generated files, use:

```shell
make clean-generated
```

This will remove any file which can be re-generated and doesn’t need to be tracked.

### Clean {#clean}

To clean everything up, use:

```shell
make clean
```

This removes any running clusters and all generated files.

### Release {#release}

Uploads the built images to Quay.io:

```shell
make release release_images="<image name>"
```

Respected variables:

* **QUAY_USERNAME, QUAY_PASSWORD:** Needed in order to log in to Quay.
* **release_images:** One or more image names to release separated by spaces.
* **release_tag:** A tag to use for the release (default is *latest*).
* **repo:** The Quay repo to use (default is *`quay.io/submariner`*).

## Specific Makefile Targets

Shipyard has some project-specific targets which are used to build parts of the projects:

* **[dapper-image](#dapper-image):** Builds the base image that can be used by other projects.
* **validate:** Validates the go code that Shipyard provides, and the shared shell scripts.

### Dapper-Image

Builds the basic image which is then used by other projects to build the code and run tests:

```shell
make dapper-image
```

Respected variables:

* **dapper_image_flags:** Any additional flags and values to be sent to the `build_image.sh` script.

[Makefile.inc]: https://github.com/submariner-io/shipyard/blob/devel/Makefile.inc
