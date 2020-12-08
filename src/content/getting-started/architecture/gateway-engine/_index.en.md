+++
title =  "Gateway Engine"
weight = 20
+++

The Gateway Engine component is deployed in each participating cluster and
is responsible for establishing secure tunnels to other clusters.

The Gateway Engine has a pluggable architecture for the cable engine component
that maintains the tunnels. The following implementations are available:

* an IPsec implementation using [Libreswan](https://libreswan.org/). This is currently the default.
* an IPsec implementation using [strongSwan](https://www.strongswan.org/) (via the
  [goStrongswanVici](https://github.com/bronze1man/goStrongswanVici) library).
* an implementation for [WireGuard](https://www.wireguard.com/) (via the [wgctrl](https://github.com/WireGuard/wgctrl-go) library).

The cable driver can be specified via the `--cable-driver` flag while joining a cluster using `subctl`. For more information, please refer
to the [`subctl` guide](../../../operations/deployment/subctl/).

{{% notice note %}}
WireGuard needs to be installed on Gateway nodes. See the [WireGuard installation instructions](https://www.wireguard.com/install/).
{{% /notice %}}

Instances of the Gateway Engine run on specifically designated nodes in a
cluster of which there may be more than one for fault tolerance. Submariner
supports active/passive High Availability for the Gateway Engine component,
which means that there is only one active Gateway Engine instance at a time
in a cluster. They perform a leader election process to determine the active
instance and the others await in standby mode ready to take over should the
active instance fail.

{{% notice info %}}
The Gateway Engine is deployed as a DaemonSet that is configured to only run
on nodes labelled with "submariner.io/gateway=true".
{{% /notice %}}

The active Gateway Engine communicates with the central Broker to advertise
its `Endpoint` and `Cluster` resources to the other clusters connected to the
Broker, also ensuring that it is the sole `Endpoint` for its cluster. The
[Route Agent](../route-agent/) Pods running in the cluster learn about the
local `Endpoint` and setup the necessary infrastructure to route cross-cluster
traffic from all nodes to the active Gateway Engine node. The active Gateway Engine
also establishes a watch on the Broker to learn about the active `Endpoint` and
`Cluster` resources advertised by the other clusters. Once two clusters are
aware of each other's `Endpoints`, they can establish a secure tunnel through
which traffic can be routed.

![Figure 1 - High Availability in stable cluster](/images/high-availability/HA_Cluster1.png)
<!-- Image Source: https://docs.google.com/presentation/d/180CtHZnr9PP5Rh98VEmkQz3ovc5AGXG9wosoHMLhgaY/edit -->

#### Gateway Failover

If the active Gateway Engine fails, another Gateway Engine on one of the
other designated nodes will gain leadership and perform reconciliation to
advertise its `Endpoint` and to ensure that it is the sole `Endpoint`. The
remote clusters will learn of the new `Endpoint` via the Broker and establish
a new tunnel. Similarly, the Route Agent Pods running in the local cluster
automatically update the route tables on each node to point to the new active
Gateway node in the cluster.

![Figure 2 - Gateway Failover Scenario](/images/high-availability/HA_Cluster2.png)
<!-- Image Source: https://docs.google.com/presentation/d/180CtHZnr9PP5Rh98VEmkQz3ovc5AGXG9wosoHMLhgaY/edit -->

The impact on datapath for various scenarios in a kind setup are captured in the
following [spreadsheet](https://docs.google.com/spreadsheets/d/1JsXsyRDDXkp6t55Gm-NP5EggWTyYi2yo27pyuDYwlpc/edit#gid=0).

#### Gateway Health Check

The Gateway Engine continuously monitors the health of connected clusters.
It periodically pings each cluster and collects statistics including basic connectivity,
round trip time (RTT) and average latency. This information is updated in the `Gateway`
resource. Whenever the Gateway Engine detects that a ping to a particular cluster has failed,
its connection status is marked with an error state. Service Discovery uses this information
to avoid unhealthy clusters during Service discovery.

The health checking feature can be enabled/disabled via an option on the
[`subctl`](../../../operations/deployment/subctl/#join-flags-healthcheck) join command.
