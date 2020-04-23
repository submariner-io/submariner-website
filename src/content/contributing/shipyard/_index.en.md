---
title: "Working With Shipyard"
date: 2020-04-20T17:12:52+0300
weight: 10
---

## Overview

The Shipyard project provides tooling for creating K8s clusters with [KIND](https://github.com/kubernetes-sigs/kind) (K8s in Docker) and provides a Go framework for creating end to end tests.
Feel free to add any capabilities that need to be shared to Shipyard, while any project specific capabilities should probably be part of that project.

A base image `quay.io/submariner/shipyard-dapper-base` is created from Shipyard, and contains all the tooling to build your projects and run any kind of tests in a consistent environment.

Shipyard has several folders at the root of the project, with different usages:
* **package:** Contains the ingerdients to build the base image.
* **scripts:** Contains general scripts for Shipyard make targets, each executable one is a target.
  * **shared:** Gets copied into the base image under `$SCRIPTS_DIR`. Contains all shared scripts that projects can consume.
    * **lib:** Library functions that shared scripts, or consuming projects, can use.
    * **resources:** Resource files to be used by the shared scripts.
* **test:** Test library to be used by other projects.

Shipyard ships with some [Makefile targets](#shared-makefile-targets) which can be used by consuming projects, and are used by Shipyard's CI to test and validate itself. It also has some [specific Makefile targets](#specific-makefile-targets) which are used by the project itself.

## Usage

#### Add Shipyard to a Project

To add Shipyard to a project that doesn't have it, please see [Adding Shipyard to a Project](first_time).

#### Use Shipyard in Your Project

If your project already uses Shipyard, you can use any of the [Makefile targets](#shared-makefile-targets) that it provides.

Make sure to pass any variables that you need in these targets in your Dockerfile.dapper, so that they're available in the Dapper environment.
For example:

```Dockerfile
ENV DAPPER_ENV="REPO TAG QUAY_USERNAME QUAY_PASSWORD TRAVIS_COMMIT CLUSTERS_ARGS DEPLOY_ARGS"
```

#### Have Shipyard Targets Depend on Your Project's Targets

Having any of the Shipyard Makefile targets rely on your project's specific targets can be done easily by adding the dependency in your project's Makefile.
For example:

```Makefile
clusters: build images
```

#### Use an Updated Shipyard Image in Your Project

If you've made changes to Shipyard's [base image](#dapper-image) and need to test them in your project, it's as simple as running:

```
make dapper-image
```

Within the Shipyard directory. You would then have a local image with your changes, and can run the necessary procedure from your project's directory.

## Shared Makefile Targets

Shipyard ships a [Makefile.inc] file which defines these basic targets:
* **[clusters](#clusters):** Creates the multi-cluster environment in KIND.
* **[deploy](#deploy)** (depends on clusters): Deploys submariner on to the multi-cluster environment.
* **[cleanup](#cleanup):** Deletes the KIND environment (if it exists) and any residual resources.
* **[release](#release):** Uploads the requested image(s) to Quay.io.
* **vendor/modules.txt:** Populates go modules (in case go.mod exists in the root directory).

If your project uses Shipyard then it has all these targets and supports all the variables these targets support.

Any variables supported by these targets can be either declared as environment variables, or assigned on the make call (takes precedence over environment variables).

### Clusters {#clusters}

A basic target that creates a KIND based multi-cluster environment, without any special deployment (apart from the default K8s).

```
make clusters
```

Respected variables:
* **CLUSTERS_ARGS:** Any arguments (flags and/or values) to be sent to the `clusters.sh` script. To get a list of available arguments, run: `scripts/shared/clusters.sh --help`

### Deploy {#deploy}

A basic target that deploys submariner on a KIND based multi-cluster environment (if one isn't deployed, this target will deploy it as well):

```
make deploy
```

Respected variables:
* Any variable from [clusters](#clusters) target (only if it wasn't created).
* **DEPLOY_ARGS:** Any arguments (flags and/or values) to be sent to the `deploy.sh` script. To get a list of available arguments, run: `scripts/shared/deploy.sh --help`

### Cleanup {#cleanup}

To clean up all the KIND clusters deployed in any of the previous steps, use:

```
make cleanup
```

This command will make sure to remove the clusters, and any clutter that might've been left in docker and is not needed any more (images, volumes, etc).

### Release {#release}

Uploads the built images to Quay.io:

```
make release release_images="<image name>"
```

Respected variables:
* **QUAY_USERNAME, QUAY_PASSWORD:** Needed in order to log in to Quay.
* **release_images:** Has to have at least one image name to release, and could have several separated by spaces.
* **release_tag:** A tag to use for the release (default is *latest*).
* **repo:** The quay repo to use (default is *quay.io/submariner*).

## Specific Makefile Targets

Shipyard has some project specific targets which are used to build parts of the projects:
* **[dapper-image](#dapper-image):** Builds the base image that can be used by other projects.
* **validate:** Validates the go code that Shipyard provides, and the shared shell scripts.

### Dapper-Image

Builds the basic image which is then used by other projects to build the code and run tests:

```
make dapper-image
```

Respected variables:
* **dapper_image_flags:** Any additional flags and values to be sent to the `build_image.sh` script.


[Makefile.inc]: https://github.com/submariner-io/shipyard/blob/master/Makefile.inc
