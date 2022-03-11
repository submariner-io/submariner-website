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

* **`tag`**: The tag to set for the local image (defaults to *dev*).
* **`repo`**: The repo portion to use for the image name.
* **`image` (`-i`)**: The image name itself.
* **`dockerfile` (`-f`)**: The Dockerfile to build the image from.
* **`[no]cache`**: Turns the caching on (or off).

For example, to build the `submariner` image use:

```bash
${SCRIPTS_DIR}/build_image.sh -i submariner -f package/Dockerfile
```

## Deployment Scripts Features

### Per Cluster Settings

Shipyard supports specifying different settings for each deployed cluster. The settings are sent to supporting scripts using a
`--settings` flag.

The settings are specified in a YAML file, where default and per cluster settings can be provided. All clusters are listed under the
`clusters` key, and each cluster can have specific deployment settings. All cluster specific settings (except `broker`) can be specified
on the root of the settings file to determine defaults.

The possible settings are:

* **`broker`**: Special key to mark the broker, set to anything to select a broker. By default, the first cluster is selected.
* **`cni`**: Which CNI to deploy on the cluster, currently supports `weave` and `ovn` (leave empty or unset for `kindnet`).
* **`nodes`**: A space separated list of nodes to deploy, supported types are `control-plane` and `worker`.
* **`submariner`**: If Submariner should be deployed, set to `true`. Otherwise, leave unset (or set to `false` explicitly).

For example, a basic settings file that deploys a couple of clusters with weave CNI:

```yaml
cni: weave
submariner: true
nodes: control-plane worker worker
clusters:
  cluster1:
  cluster2:
```

The following settings file deploys two clusters with one control node and two workers, with weave and Submariner. The third cluster
will host the broker and as such needs no CNI, only a worker node, and no Submariner deployment:

```yaml
cni: weave
submariner: true
nodes: control-plane worker worker
clusters:
  cluster1:
  cluster2:
  cluster3:
    broker: true
    cni:
    submariner: false
    nodes: control-plane
```

### Clusters Deployment Customization

It's possible to supply extra flags when calling `make clusters` via a make variable `CLUSTERS_ARGS` (or an environment variable with the
same name). These flags affect how the clusters are deployed (and possibly influence how Submariner works).

Flags of note:

* **`k8s_version`**: Allows to specify the Kubernetes version that [kind](https://kind.sigs.k8s.io/) will deploy. Available versions can be
found [here](https://hub.docker.com/r/kindest/node/tags).

  ```bash
  make clusters CLUSTERS_ARGS='--k8s_version 1.18.0'
  ```

* **`globalnet`**: When set, deploys the clusters with overlapping Pod & Service CIDRs to simulate this scenario.

  ```bash
  make clusters CLUSTERS_ARGS='--globalnet'
  ```

### Submariner Deployment Customization

It's possible to supply extra flags when calling `make deploy` via a make variable `DEPLOY_ARGS` (or an environment variable with the same
name). These flags affect how Submariner is deployed on the clusters.

Since `deploy` relies on `clusters` then effectively you could also specify `CLUSTERS_ARGS` to control the cluster deployment (provided the
cluster hasn't been deployed yet).

Flags of note (see the flags defined in [deploy.sh](https://github.com/submariner-io/shipyard/blob/devel/scripts/shared/deploy.sh)
for the full list):

* **`deploytool`**: Specifies the deployment tool to use: `operator` (default), `helm`, `bundle` or `ocm`.

  ```bash
  make deploy DEPLOY_ARGS='--deploytool operator'
  ```

* **`deploytool_broker_args`**: Any extra arguments to pass to the deploy tool when deploying the broker.

  ```bash
  make deploy DEPLOY_ARGS='--deploytool operator --deploytool_broker_args "--components service-discovery,connectivity"'
  ```

* **`deploytool_submariner_args`**: Any extra arguments to pass to the deploy tool when deploying Submariner.

  ```bash
  make deploy DEPLOY_ARGS='--deploytool operator --deploytool_submariner_args "--cable-driver wireguard"'
  ```

As shown above, arguments can be passed directly to the Broker and Submariner.
The deploy script also has flags that group common options together for easier user experience.
For example, the [`service_discovery` flag in `deploy.sh`](https://github.com/submariner-io/shipyard/blob/devel/scripts/shared/deploy.sh)
will handle the `--components service-discovery,connectivity` flags mentioned above. Other examples:

* **`globalnet`**: When set, deploys Submariner with the Globalnet controller, and assigns a unique Global CIDR to each cluster.

  ```bash
  make deploy DEPLOY_ARGS='--globalnet'
  ```

* **`cable_driver`**: Override the default cable driver to configure the tunneling method for connections between clusters.

  ```bash
  make deploy DEPLOY_ARGS='--cable_driver wireguard'
  ```

#### Example: Passing Deployment Variables

As an example, in order to deploy with Lighthouse and support both Operator and Helm deployments, one can add this snippet to the Makefile:

```Makefile
ifeq ($(deploytool),operator)
DEPLOY_ARGS += --deploytool operator --deploytool_broker_args '--components service-discovery,connectivity'
else
DEPLOY_ARGS += --deploytool helm --deploytool_broker_args '--set submariner.serviceDiscovery=true' --deploytool_submariner_args '--set submariner.serviceDiscovery=true,lighthouse.image.repository=localhost:5000/lighthouse-agent,serviceAccounts.lighthouse.create=true'
endif
```

In such a case, the call to deploy the environment would look like this:

```shell
make deploy [deploytool=operator]
```

Note that `deploytool` is a variable used to determine the tool to use, but isn't passed to or used by Shipyard.
