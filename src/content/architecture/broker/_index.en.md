---
title: "Broker"
---

Submariner uses a central broker to facilitate the exchange of metadata information between connected clusters. The broker is basically a set of custom resource definitions (CRDs) backed by the kubernetes datastore. The broker is a singleton component that is deployed on one of the clusters whose Kubernetes API must be accessible by all of the connected clusters. So, if you have a mix of on-premise and public clusters, you can deploy Broker on the public cluster.

{{% notice tip %}}

Broker can also be deployed on a standalone kubernetes cluster which is not part of Submariner data cluster fleet.

{{% /notice %}}

It is to be noted that Submariner does not run any Pods on the Broker cluster. It only uses it as a datastore for sync'ing information of all the connected clusters.
On the Broker cluster, the information associated with all the data clusters is stored as cluster and endpoint CRDs in `submariner-k8s-broker` namespace.
When a data cluster is joined to the Broker, the `submariner-gateway` Pod on the data cluster will push the local cluster and endpoint CRD info to the Broker and will sync information of other clusters (based on the cluster ID) from the Broker to the local cluster.
This information will be used by the data clusters to setup tunnels to other clusters.

![Figure 1 - Problem with overlapping CIDRs](/images/brokercluster.png)

{{% notice info %}}
Currently, the broker is implemented by utilizing the Kubernetes API, but is modular and can be enhanced in the future to bring support for other interfaces.
{{% /notice %}}

To query the list of clusters and endpoints stored on the broker, you can run the following commands

```bash
kubectl --kubeconfig <kubeConfigOfBrokerCluster> get clusters -n submariner-k8s-broker
kubectl --kubeconfig <kubeConfigOfBrokerCluster> get endpoint -n submariner-k8s-broker
```
