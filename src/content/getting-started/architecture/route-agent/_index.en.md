+++
title =  "Route Agent"
weight = 30
+++

The Route Agent component runs on every node in each participating cluster. It is responsible for setting up VXLAN tunnels and routing the
cross cluster traffic from the node to the cluster’s active Gateway Engine which subsequently sends the traffic to the destination cluster.

When running on the same node as the active Gateway Engine, Route Agent creates a VXLAN VTEP interface to which Route Agent instances
running on the other worker nodes in the local cluster connect by establishing a VXLAN tunnel with the VTEP of the active Gateway Engine
node. The MTU of the VXLAN tunnel is configured based on the MTU of the default interface on the host minus the VXLAN overhead.

Route Agents use `Endpoint` resources synced from other clusters to configure routes and to program the necessary iptables rules to enable
full cross-cluster connectivity.

When the active Gateway Engine fails and a new Gateway Engine takes over, Route Agents will automatically update the route tables on each
node to point to the new active Gateway Engine node.
