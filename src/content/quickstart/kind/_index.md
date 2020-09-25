---
date: 2020-03-17T13:36:18+01:00
title: "KIND (Local Environment)"
weight: 100
---

## Locally Testing With KIND

[KIND](https://github.com/kubernetes-sigs/kind) is a tool to run local Kubernetes clusters inside Docker container nodes.

Submariner provides (via [Shipyard](../../contributing/shipyard)) scripts that deploy 3 Kubernetes clusters locally - 1 broker and 2 data
clusters with the Submariner dataplane components deployed on all the clusters.

{{% notice note %}}
Docker must be installed and running on your computer.
{{% /notice %}}

### Deploying automatically

To create KIND clusters and deploy Submariner, run:

```bash
git clone https://github.com/submariner-io/submariner
cd submariner
make deploy
```

### Deploying manually

If you wish to try out Submariner deployment manually, an easy option is to create KIND clusters using our scripts and deploy Submariner
with [subctl](../../deployment/subctl).

#### Create KIND clusters

To create KIND clusters, run:

```bash
git clone https://github.com/submariner-io/submariner
cd submariner
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

#### Verify Deployment

To manually verify the deployment, follow the steps below using either a headless or ClusterIP `nginx` service deployed in `cluster3`.

##### Deploy ClusterIP Service

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 create deployment nginx --image=nginx
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 expose deployment nginx --port=80
subctl export service --kubeconfig output/kubeconfigs/kind-config-cluster3 --namespace default nginx
```

##### Deploy Headless Service

Note that headless Services can only be exported on non-globalnet deployments.

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
curl nginx.default.svc.supercluster.local:8080
```

#### Perform automated verification

This will perform automated verifications between the clusters.

```bash
subctl verify cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --only service-discovery,connectivity --verbose
```
