---
date: 2020-03-17T13:36:18+01:00
title: "KIND (Local Environment)"
weight: 100
---

## Locally Testing With KIND

[KIND](https://github.com/kubernetes-sigs/kind) is a tool to run local Kubernetes clusters inside Docker container nodes.

Submariner provides (via [Shipyard](../../contributing/shipyard)) scripts that deploy 3 Kubernetes clusters locally - 1 broker and 2 data clusters with the Submariner dataplane components deployed on all the clusters.

{{% notice note %}}
Docker must be installed and running on your computer.
{{% /notice %}}

### Deploying manually

If you wish to try out Submariner deployment manually, you can first create KIND clusters using [Shipyard](../../contributing/shipyard) provided scripts and [subctl](../../deployment/subctl).

#### Create KIND clusters

To create KIND clusters, run:

```bash
git clone https://github.com/submariner-io/shipyard
cd shipyard
make clusters
```

This creates 3 Kubernetes clusters, cluster1, cluster2 and cluster3.

#### Install subctl

{{< subctl-install >}}

#### Use cluster1 as broker

```bash
subctl deploy-broker --kubeconfig output/kubeconfigs/kind-config-cluster1 --service-discovery
```

#### Join cluster2 and cluster3 to the broker

```bash
subctl join --kubeconfig output/kubeconfigs/kind-config-cluster2 broker-info.subm --clusterid cluster2 --disable-nat
```

```bash
subctl join --kubeconfig output/kubeconfigs/kind-config-cluster3 broker-info.subm --clusterid cluster3 --disable-nat
```

You now have a Submariner environment that you can experiment with.

### Deploying a Basic Environment

If you wish to deploy just a basic multi cluster environment, run:

```bash
git clone https://github.com/submariner-io/shipyard
cd shipyard
make deploy
```

At the end of the deployment you'll have a very basic environment that you can experiment with.

### Deploying Like a Submariner

To deploy the environment like Submariner does it, run:

```bash
git clone https://github.com/submariner-io/submariner
cd submariner
make e2e
```

This will deploy 3 Kubernetes clusters and run basic [end-to-end tests](https://github.com/submariner-io/submariner/tree/master/test/e2e). The environment will remain available after the tests complete.

More details on testing can be found in the [testing guide](../../contributing/building_testing).
