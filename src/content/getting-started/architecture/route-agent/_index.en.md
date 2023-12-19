---
title: "Route Agent"
---

The Route Agent component runs on every node in each participating cluster.
It is responsible for setting up the necessary host network elements on top
of the existing Kubernetes CNI plugin.

The Route Agent receives the detected CNI plugin as part of its
configuration.

## kube-proxy iptables

For CNI plugins that utilize kube-proxy in iptables mode, the Route Agent is responsible
for setting up VXLAN tunnels and routing the cross cluster traffic from the node to the
cluster’s active Gateway Engine which subsequently sends the traffic to the
destination cluster.

When running on the same node as the active Gateway Engine, Route Agent
creates a VXLAN VTEP interface to which Route Agent instances running on
the other worker nodes in the local cluster connect by establishing a VXLAN
tunnel with the VTEP of the active Gateway Engine node. The MTU of the VXLAN
tunnel is configured based on the MTU of the default interface on the host
minus the VXLAN overhead.

Route Agents use `Endpoint` resources synced from other clusters to configure
routes and to program the necessary iptables rules to enable full cross-cluster
connectivity.

When the active Gateway Engine fails and a new Gateway Engine takes over,
Route Agents will automatically update the route tables on each node to point to
the new active Gateway Engine node.

## OVN Kubernetes

 With OVN Kubernetes we reuse the GENEVE tunnels created by OVNKubernetes CNI to reach the
gateway nodes from non-gateway nodes and a separate VXLAN tunnel is not created.

{{% notice info %}}
For Submariner 0.15 and below refer  [network plugin syncer](../networkplugin-syncer/)
{{% /notice %}}

With OVN we can have two deployment models,

{{% notice info %}}
Submariner automatically discovers the OVN mode and uses the appropriate implementation and this is
not a configuration option in Submariner
{{% /notice %}}

### Single Zone

A single-zone deployment involves a single OVN database and a set of master nodes that
program it.

Here, Submariner configures the `ovn_cluster_router` to route traffic to other clusters through the
`ovn-k8s-mp0` interface of the gateway node, effectively bridging it to the host networking
stack of the gateway node. Since `ovn_cluster_router`  is distributed, this route also ensures
that traffic from non-gateway node is directed to local gateway node.

The traffic that comes through Submariner tunnel from remote cluster to gateway node will be
directed to `ovn-k8s-mp0` interface through host routes and will be handled by `ovn_cluster_router`.

![Single Zone](/images/ovn-kubernetes/ovn-without-ic.svg)

### Multiple Zone

In a multi-zone configuration, each zone operates with its dedicated OVN database and OVN master pod.
These zones are interconnected via transit switches, and OVN-Kubernetes orchestrates the essential
routing for enabling pod and service communication across nodes situated in different zones.

Within this framework, the Submariner route agent plays a pivotal role. It ensures that the same
routing configurations employed in a single zone are replicated in the OVN cluster router and the
host stack of the gateway node. For nodes outside the zone where the gateway node is located,
Submariner takes action by adding a route that directs traffic to remote clusters, channeling
it through the transit switch IP of the gateway node.

The host networking rules remain consistent across all nodes. They guide traffic towards the
`ovn_cluster_router` specific to that zone, leveraging `ovn-k8s-mp0`. The `ovn_cluster_router`, in
turn, guarantees that the traffic is directed through the Submariner tunnel via the gateway
node.

![Multiple Zone](/images/ovn-kubernetes/ovn-with-ic.svg)
