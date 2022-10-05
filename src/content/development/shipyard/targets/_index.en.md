---
title: "Shared Targets"
date: 2020-04-20T17:12:52+0300
weight: 20
---

Shipyard ships a [Makefile.inc] file which defines these basic targets:

* **[clusters](#clusters):** Creates the kind-based cluster environment.
* **[deploy](#deploy)** : Deploys Submariner components in the cluster environment (depends on clusters).
* **[e2e](#e2e)** : Runs end to end tests on top of the deployed environment (deploying it if necessary).
* **[clean-clusters](#clean-clusters):** Deletes the kind environment (if it exists) and any residual resources.
* **[clean-generated](#clean-generated):** Deletes all generated files.
* **[clean](#clean):** Cleans everything up (running clusters and generated files).
* **vendor/modules.txt:** Populates go modules (in case go.mod exists in the root directory).

If your project uses Shipyard then it has all these targets and supports all the variables these targets support.
Any variables supported by these targets can be assigned on the `make` command line.

### Global Variables

Many targets support variables that influence how each target behaves.

#### Highlighted Variables

* **`SETTINGS`**: Settings file that specifies a topology for deployment.
* **`PROVIDER`**: Cloud provider for the infrastructure (defaults to `kind`).
* **`GOLBALNET`**: When true, deploys the clusters with overlapping IPs (defaults to `false`).
* **`DEBUG_PRINT`**: When true, outputs debug information for Shipyard's scripts (defaults to `true`).

### Clusters

Creates a kind-based multi-cluster environment with just the default Kubernetes deployment:

```shell
make clusters
```

#### Highlighted Variables for Clusters

* Any variable from the [global variables](#global-variables) list.
* **`K8S_VERSION`**: Determines the Kubernetes version that gets deployed (defaults to `1.24`).

### Deploy

Deploys Submariner components in a kind-based cluster environment (if one isn't created yet, this target will first invoke the `clusters`
target to do so):

```shell
make deploy
```

#### Highlighted Variables for Deploy

* Any variable from the [global variables](#global-variables) list.
* Any variable from [clusters](#clusters) target (only if it wasn't created).
* **`CABLE_DRIVER`**: The cable driver used by Submariner (defaults to `libreswan`).
* **`DEPLOYTOOL`**: The tool used to deploy Submariner itself (defaults to `operator`).
* **`LIGHTHOUSE`**: Deploys Lighthouse in addition to the basic Submariner deployment (defaults to `false`).

### E2E (End to End) <a id="e2e"></a>

Runs end to end testing on the deployed environment (if one isn't created yet, this target will first invoke the `deploy` target to do so).
The tests are taken from the project, unless it has no specific end to end tests, in which case generic testing using `subctl verify` is
run.

```shell
make e2e
```

#### Highlighted Variables for E2E

* Any variable from the [global variables](#global-variables) list.
* Any variable from [deploy](#deploy) target (only if it wasn't created).

### Clean-clusters

To clean up all the kind clusters deployed in any of the previous steps, use:

```shell
make clean-clusters
```

This command will remove the clusters and any resources that might've been left in docker that are not needed any more (images, volumes,
etc).

### Clean-generated

To clean up all generated files, use:

```shell
make clean-generated
```

This will remove any file which can be re-generated and doesn’t need to be tracked.

### Clean

To clean everything up, use:

```shell
make clean
```

This removes any running clusters and all generated files.

[Makefile.inc]: https://github.com/submariner-io/shipyard/blob/devel/Makefile.inc
