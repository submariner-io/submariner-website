---
date: 2020-03-17T13:36:18+01:00
title: "Sandbox Environment (kind)"
weight: 10
---

## Deploy kind with Submariner Locally

[kind](https://github.com/kubernetes-sigs/kind) is a tool for running local Kubernetes clusters using Docker container nodes. This guide
uses kind to demonstrate deployment and operation of Submariner in three Kubernetes clusters running locally on your computer.

Submariner provides automation to deploy clusters using kind and connect them using Submariner.

### Prerequisites

1. Install [Docker](https://docs.docker.com/get-docker/) and ensure it is running properly on your computer.
2. Install and set up [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

{{% notice note %}}
You may need to [increase your inotify resource limits](https://kind.sigs.k8s.io/docs/user/known-issues/#pod-errors-due-to-too-many-open-files).
{{% /notice %}}

### Deploy Automatically

To create kind clusters and deploy Submariner with service discovery enabled, run:

```bash
git clone https://github.com/submariner-io/submariner-operator
cd submariner-operator
make deploy using=lighthouse
```

By default, the automation configuration in the `submariner-io/submariner-operator` repository deploys two clusters, with cluster1
configured as the Broker.
See the [settings](https://github.com/submariner-io/submariner-operator/blob/devel/.shipyard.e2e.yml) file for details.

Once you become familiar with Submariner's basics, you may want to visit the
[Building and Testing page](../../../development/building-testing/) to learn more about customizing your Submariner development deployment.
To understand how Submariner's development deployment infrastructure works under the hood, see
[Submariner Deployment Customization in the Shipyard Advanced Options](../../../development/shipyard/advanced/).

### Deploy Manually

If you wish to try out Submariner deployment manually, an easy option is to create kind clusters using our scripts and deploy Submariner
with [`subctl`](../../../operations/deployment/subctl).

#### Create kind Clusters

To create kind clusters, run:

```bash
git clone https://github.com/submariner-io/submariner-operator
cd submariner-operator
make clusters
```

Once the clusters are deployed, `make clusters` will indicate how to access them:

```text
Your virtual cluster(s) are deployed and working properly and can be accessed with:

export KUBECONFIG=$(find $(git rev-parse --show-toplevel)/output/kubeconfigs/ -type f -printf %p:)

$ kubectl config use-context cluster1 # or cluster2, cluster3..

To clean everthing up, just run: make clean-clusters
```

The `export KUBECONFIG` command has to be run before `kubectl` can be used.

`make clusters` creates two Kubernetes clusters: cluster1 and cluster2. To see the list of kind clusters, use the following command:

```bash
$ kind get clusters
cluster1
cluster2
```
<!-- markdownlint-disable no-trailing-spaces -->
To list the local Kubernetes contexts, use the following command:

```bash
$ kubectl config get-contexts
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          cluster1   cluster1   cluster1      
*         cluster2   cluster2   cluster2
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

{{% subctl-install %}}

#### Use cluster1 as Broker

```bash
subctl deploy-broker --kubeconfig output/kubeconfigs/kind-config-cluster1
```

#### Join cluster1 and cluster2 to the Broker

```bash
subctl join --kubeconfig output/kubeconfigs/kind-config-cluster1 broker-info.subm --clusterid cluster1 --natt=false
```

```bash
subctl join --kubeconfig output/kubeconfigs/kind-config-cluster2 broker-info.subm --clusterid cluster2 --natt=false
```

You now have a Submariner environment that you can experiment with.

### Verify Deployment

#### Verify Automatically with `subctl`

This will perform automated verifications between the clusters.

<!-- markdownlint-disable line-length -->
```bash
export KUBECONFIG=output/kubeconfigs/kind-config-cluster1:output/kubeconfigs/kind-config-cluster2
subctl verify --kubecontexts cluster1,cluster2 --only service-discovery,connectivity --verbose
```
<!-- markdownlint-enable line-length -->

#### Verify Manually

To manually verify the deployment, follow the steps below using either a headless or ClusterIP `nginx` service deployed in `cluster2`.

##### Deploy ClusterIP Service

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster2 create deployment nginx --image=nginx
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster2 expose deployment nginx --port=80
subctl export service --kubeconfig output/kubeconfigs/kind-config-cluster2 --namespace default nginx
```

##### Deploy Headless Service

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster2 create deployment nginx --image=nginx
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster2 expose deployment nginx --port=80 --cluster-ip=None
subctl export service --kubeconfig output/kubeconfigs/kind-config-cluster2 --namespace default nginx
```

##### Verify

Run `nettest` from `cluster1` to access the `nginx` service:

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster1 -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest \
-- /bin/bash
curl nginx.default.svc.clusterset.local
```

### Cleanup

When you are done experimenting and you want to delete the clusters deployed in any of the previous steps, use the following command:

```bash
make clean-clusters
```
