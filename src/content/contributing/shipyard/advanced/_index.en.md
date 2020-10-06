---
title: "Advanced Features"
date: 2020-05-05T09:11:00+0300
weight: 20
---

Shipyard has many advanced features to use in consuming projects.

To utilize an advanced feature in a project consuming Shipyard, a good practice is to change the project's Makefile to have the advanced
logic that is always needed. Any variable functionality can then be passed as desired in the command line.

## Image Building Helper Script

Shipyard ships an image building script `build_image.sh` which can be used to build the image(s) that you require. The script has built in
caching capabilities to speed up local and pull request CI builds, by utilizing docker's ability to reuse layers from a cached image.

The script accepts several flags:

* **tag:** The tag to set for the local image (defaults to *dev*).
* **repo:** The repo portion to use for the image name.
* **image (-i):** The image name itself.
* **dockerfile (-f):** The Dockerfile to build the image from.
* **[no]cache:** Turns the caching on (or off).

For example, to build the submariner image use:

```bash
${SCRIPTS_DIR}/build_image.sh -i submariner -f package/Dockerfile
```

## Deployment Scripts Features

### Per Cluster Settings

Shipyard supports specifying different settings for each deployed cluster. A default `cluster_settings` is supplied in the image, so any
custom settings override those. The settings are sent to supporting scripts using a `--cluster_settings` flag.

Currently, the following settings are supported:

* **clusters:** An array of the clusters to deploy.

  ```bash
  clusters=(cluster1,cluster2)
  ```

* **cluster_nodes:** A map of cluster names to a space separated string, representing a list of nodes to deploy. Supported values are
  `control-plane` and `worker`.

  ```bash
  cluster_nodes[cluster1]="control-plane worker"
  cluster_nodes[cluster2]="control-plane worker worker"
  ```

* **cluster_subm:** A map of cluster names to values specifying if Submariner should be installed. Set to `true` to have Submariner
  installed, or to `false` to skip the installation.

  ```bash
  cluster_subm[cluster1]="false"
  cluster_subm[cluster2]="true"
  ```

#### Example: Custom Per Cluster Settings

As an example, in order to customize the clusters to have two workers, and no submariner on the 1st cluster, create a `cluster_settings`
file in the project:

```bash
cluster_nodes['cluster1']="control-plane"
cluster_nodes['cluster2']="control-plane worker worker"
cluster_nodes['cluster3']="control-plane worker worker"
cluster_subm['cluster1']="false"
```

Then, to apply these settings, add this snippet to the Makefile:

```Makefile
CLUSTER_SETTINGS_FLAG = --cluster_settings $(DAPPER_SOURCE)/path/to/cluster_settings
CLUSTERS_ARGS += $(CLUSTER_SETTINGS_FLAG)
DEPLOY_ARGS += $(CLUSTER_SETTINGS_FLAG)
```

The path to `cluster_settings` should be specified relative to the project root; this ends up available in the build container in the
directory referenced by `$DAPPER_SOURCE`.

### Clusters Deployment Customization

It's possible to supply extra flags when calling `make clusters` via a make variable `CLUSTERS_ARGS` (or an environment variable with the
same name). These flags affect how the clusters are deployed (and possibly influence how Submariner works).

Flags of note:

* **k8s_version:** Allows to specify the K8s version that [kind](https://kind.sigs.k8s.io/) will deploy. Available versions can be found
  [here](https://hub.docker.com/r/kindest/node/tags).

  ```bash
  make clusters CLUSTERS_ARGS='--k8s_version 1.18.0'
  ```

* **globalnet:** When set, deploys the clusters with overlapping Pod & Service CIDRs to simulate this scenario.

  ```bash
  make clusters CLUSTERS_ARGS='--globalnet'
  ```

### Submariner Deployment Customization

It's possible to supply extra flags when calling `make deploy` via a make variable `DEPLOY_ARGS` (or an environment variable with the same
name). These flags affect how Submariner is deployed on the clusters.

Since `deploy` relies on `clusters` then effectively you could also specify `CLUSTERS_ARGS` to control the cluster deployment (provided the
cluster hasn't been deployed yet).

Flags of note:

* **deploytool:** Specifies the deployment tool to use: `operator` (default) or `helm`.

  ```bash
  make deploy DEPLOY_ARGS='--deploytool operator'
  ```

* **deploytool_broker_args:** Any extra arguments to pass to the deploy tool when deploying the broker.

  ```bash
  make deploy DEPLOY_ARGS='--deploytool operator --deploytool_broker_args "--service-discovery"'
  ```

* **deploytool_submariner_args:** Any extra arguments to pass to the deploy tool when deploying Submariner.

  ```bash
  make deploy DEPLOY_ARGS='--deploytool operator --deploytool_submariner_args "--cable-driver wireguard"'
  ```

* **globalnet:** When set, deploys Submariner with the globalnet controller, and assigns a unique Global CIDR to each cluster.

  ```bash
  make deploy DEPLOY_ARGS='--globalnet'
  ```

#### Example: Passing Deployment Variables

As an example, in order to deploy with Lighthouse and support both Operator and Helm deployments, one can add this snippet to the Makefile:

```Makefile
ifeq ($(deploytool),operator)
DEPLOY_ARGS += --deploytool operator --deploytool_broker_args '--service-discovery'
else
DEPLOY_ARGS += --deploytool helm --deploytool_broker_args '--set submariner.serviceDiscovery=true' --deploytool_submariner_args '--set submariner.serviceDiscovery=true,lighthouse.image.repository=localhost:5000/lighthouse-agent,serviceAccounts.lighthouse.create=true'
endif
```

In such a case, the call to deploy the environment would look like this:

```shell
make deploy [deploytool=operator]
```

Note that `deploytool` is a variable used to determine the tool to use, but isn't passed to or used by Shipyard.
