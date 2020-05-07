+++
title =  "Route Agent"
weight = 3
+++

The Route Agent component runs on every node in each participating cluster. It is
responsible for setting up VxLAN tunnels and routing the cross cluster traffic
from the node to the cluster’s active Gateway Engine which subsequently sends the
traffic to the destination cluster. 

When running on the same node as the active Gateway Engine, the Route Agent creates
a VxLAN VTEP interface to which the Route Agent instances running on the other worker
nodes in the local cluster connect by establishing a VXLAN tunnel with the VTEP of
the active Gateway Engine node. The MTU of VxLAN tunnel is configured based on the MTU
of the default interface on the host minus the VxLAN overhead.

The Route Agent uses Endpoint resources synced from other clusters to configure routes
and to program the necessary IP table rules to enable full cross-cluster connectivity.

When the active Gateway Engine fails and a new Gateway Engine takes over, the Route
Agent will automatically update the route tables on each node to point to the new
active Gateway Engine node.
