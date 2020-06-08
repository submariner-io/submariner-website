+++
title =  "Gateway Engine"
weight = 2
+++

The Gateway Engine component is deployed in each participating cluster and
is responsible for establishing secure tunnels to other clusters. 

Instances of the Gateway Engine run on specifically designated nodes in a
cluster of which there may be more than one for fault tolerance. There is
only one active Gateway Engine instance at a time in a cluster. They
perform a leader election process to determine the active instance and the
others await in standby mode ready to take over should the active instance
fail. 

The active Gateway Engine communicates with the central Broker to advertise
its `Endpoint` and `Cluster` resources to the other clusters connected to the
Broker, also ensuring that it is the sole `Endpoint` for its cluster. The
active Gateway Engine also establishes a watch on the Broker to learn about
the active `Endpoint` and `Cluster` resources advertised by the other clusters.
Once two clusters are aware of each other's `Endpoints`, they can establish a
secure tunnel through which traffic can be routed.

If the active Gateway Engine fails, another Gateway Engine on one of the
other designated nodes will gain leadership and perform reconciliation to
advertise its `Endpoint` and to ensure that it is the sole `Endpoint`. The
remote clusters will learn of the new `Endpoint` via the Broker and establish
a new tunnel.

The Gateway Engine is deployed as a DaemonSet that is configured to only run
on nodes labelled with `submariner.io/gateway=true`.

The Gateway Engine has a pluggable architecture for the cable engine component
that maintains the tunnels. The following implementations are available:

* an IPsec implementation using [strongSwan](https://www.strongswan.org/) (via the
  [goStrongswanVici](https://github.com/bronze1man/goStrongswanVici) library);
  this is currently the default;
* an IPsec implementation using [Libreswan](https://libreswan.org/);
* an implementation for [WireGuard](https://www.wireguard.com/).