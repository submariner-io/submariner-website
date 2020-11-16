---
date: 2020-03-17T13:36:18+01:00
title: "kind (Local Environment)"
weight: 10
---

## Deploy kind with Submariner Locally

[kind](https://github.com/kubernetes-sigs/kind) is a tool for running local Kubernetes clusters using Docker container nodes. This guide
uses kind to demonstrate deployment and operation of Submariner in three Kubernetes clusters running locally on your computer.

Submariner provides automation to deploy clusters using kind and connect them using Submariner.

### Prerequisites

1. Install [Docker](https://docs.docker.com/get-docker/) and ensure it is running properly on your computer.
2. Install and set up [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

### Deploy Automatically

To create kind clusters and deploy Submariner, run:

```bash
git clone https://github.com/submariner-io/submariner
cd submariner
make deploy
```

By default, the automation configuration in the main submariner-io/submariner repository deploys three clusters, with cluster1 configured as
the Broker. See the [cluster-settings](https://github.com/submariner-io/submariner/blob/master/scripts/cluster_settings) file for details.

### Deploy Manually

If you wish to try out Submariner deployment manually, an easy option is to create kind clusters using our scripts and deploy Submariner
with [`subctl`](../../deployment/subctl).

#### Create kind Clusters

To create kind clusters, run:

```bash
git clone https://github.com/submariner-io/submariner
cd submariner
make clusters
```

This creates three Kubernetes clusters: cluster1, cluster2 and cluster3. To see the list of kind clusters, use the following command:

```bash
$ kind get clusters
cluster1
cluster2
cluster3
```
<!-- markdownlint-disable no-trailing-spaces -->
To list the local Kubernetes contexts, use the following command:

```bash
$ kubectl config get-contexts
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          cluster1   cluster1   cluster1   
          cluster2   cluster2   cluster2   
*         cluster3   cluster3   cluster3
```
<!-- markdownlint-enable no-trailing-spaces -->

Since multiple clusters are running, you need to choose which cluster `kubectl` talks to. You can set a default cluster for `kubectl` by
setting the current context in the Kubernetes kubeconfig file. Additionally, you can run the following command to set the current context
for `kubectl`:

```bash
kubectl config use-context <cluster name>
```

{{% notice tip %}}
For more information on interacting with kind, please refer to the [kind documentation](https://kind.sigs.k8s.io/docs/user/quick-start/).
{{% /notice %}}

#### Install `subctl`

{{< subctl-install >}}

#### Use cluster1 as Broker

```bash
subctl deploy-broker --kubeconfig output/kubeconfigs/kind-config-cluster1 --service-discovery
```

#### Join cluster2 and cluster3 to the Broker

```bash
subctl join --kubeconfig output/kubeconfigs/kind-config-cluster2 broker-info.subm --clusterid cluster2 --disable-nat
```

```bash
subctl join --kubeconfig output/kubeconfigs/kind-config-cluster3 broker-info.subm --clusterid cluster3 --disable-nat
```

You now have a Submariner environment that you can experiment with.

### Verify Deployment

#### Verify Automatically with `subctl`

This will perform automated verifications between the clusters.

<!-- markdownlint-disable line-length -->
```bash
subctl verify output/kubeconfigs/kind-config-cluster2 output/kubeconfigs/kind-config-cluster3 --only service-discovery,connectivity --verbose
```
<!-- markdownlint-enable line-length -->

#### Verify Manually

To manually verify the deployment, follow the steps below using either a headless or ClusterIP `nginx` service deployed in `cluster3`.

##### Deploy ClusterIP Service

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 create deployment nginx --image=nginx
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 expose deployment nginx --port=80
subctl export service --kubeconfig output/kubeconfigs/kind-config-cluster3 --namespace default nginx
```

##### Deploy Headless Service

{{% notice note %}}
Headless Services can only be exported on non-Globalnet deployments.
{{% /notice %}}

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 create deployment nginx --image=nginx
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 expose deployment nginx --port=80 --cluster-ip=None
subctl export service --kubeconfig output/kubeconfigs/kind-config-cluster3 --namespace default nginx
```

##### Verify

Run `nettest` from `cluster2` to access the `nginx` service:

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster2 -n default  run --generator=run-pod/v1 \
tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.clusterset.local
```

### Cleanup

When you are done experimenting and you want to delete the clusters deployed in any of the previous steps, use the following command:

```bash
make cleanup
```
