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

If you wish to try out Submariner deployment manually, you can first create KIND clusters
using our scripts and [subctl](../../deployment/subctl).

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


####  Verify Deployment
To manually verify the deployment follow the steps below.

```bash
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 create deployment nginx --image=nginx
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 expose deployment nginx --port=80
kubectl --kubeconfig output/kubeconfigs/kind-config-cluster3 -n default apply -f - <<EOF
subctl export service --namespace default nginx
```

{{% notice info %}}

The `ServiceExport` resource must be created in the same namespace as the Service you're trying to export. In the example above, `nginx` is created in `default` so we create the `ServiceExport` resource in `default` as well.

{{% /notice %}}

#### Perform automated verification
You can also perform automated verifications of service discovery via the `subctl verify` command.

```bash
subctl verify cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --only service-discovery,connectivity --verbose
```
