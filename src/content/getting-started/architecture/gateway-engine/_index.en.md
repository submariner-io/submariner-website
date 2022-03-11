+++
title =  "Gateway Engine"
weight = 20
+++

The Gateway Engine component is deployed in each participating cluster and
is responsible for establishing secure tunnels to other clusters.

The Gateway Engine has a pluggable architecture for the cable engine component
that maintains the tunnels. The following implementations are available:

* an IPsec implementation using [Libreswan](https://libreswan.org/). This is currently the default.
* an implementation for [WireGuard](https://www.wireguard.com/) (via the [wgctrl](https://github.com/WireGuard/wgctrl-go) library).
* an un-encrypted tunnel implementation using VXLAN.

The cable driver can be specified via the `--cable-driver` flag while joining a cluster using `subctl`. For more information, please refer
to the [`subctl` guide](../../../operations/deployment/subctl/).

{{% notice note %}}
WireGuard needs to be installed on Gateway nodes. See the [WireGuard installation instructions](https://www.wireguard.com/install/).
{{% /notice %}}

{{% notice note %}}
VXLAN connections are unencrypted by design. This is typically useful for environments in which all of the participating clusters run
on-premises, the underlying inter-network fabric is controlled, and in many cases already encrypted by other means. Other common use case is
to leverage the VXLAN cable engine over a virtual network peering on public clouds (for e.g, VPC Peering on AWS). In this case, the VXLAN
connection will be established on top of a peering link which is provided by the underlying cloud infrastructure and is already secured.
In both cases, the expectation is that connected clusters should be directly reachable without NAT.
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
on nodes labelled with `submariner.io/gateway=true`.
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

### Cable Drivers Topology Overview

#### Libreswan

The following diagram shows a high level topology for a Submariner deployment created with:

```bash
make deploy using=lighthouse
```

In this case, Libreswan is configured to create 4 IPsec tunnels to allow for:

* Pod subnet to Pod subnet connectivity
* Pod subnet to Service subnet connectivity
* Service subnet to Pod subnet connectivity
* Service subnet to Service subnet connectivity

![Figure 2 - Clusters inter-connected using IPsec tunnel mode](/images/cable-drivers/ipsec_cable.png)

#### VXLAN

The following diagram shows a high level topology for a Submariner deployment created with:

```bash
make deploy using=lighthouse, vxlan
```

With the VXLAN cable driver routes in table 100 are used on the source Gateway to steer the traffic
into the vxlan-tunnel interface.

The figure shows a simple interaction (a ping from one pod in one cluster to another pod in
a second cluster) when Submariner is used.

![Figure 3 - Clusters inter-connected using VXLAN tunnels](/images/cable-drivers/vxlan_cable.png)

### Gateway Failover

If the active Gateway Engine fails, another Gateway Engine on one of the
other designated nodes will gain leadership and perform reconciliation to
advertise its `Endpoint` and to ensure that it is the sole `Endpoint`. The
remote clusters will learn of the new `Endpoint` via the Broker and establish
a new tunnel. Similarly, the Route Agent Pods running in the local cluster
automatically update the route tables on each node to point to the new active
Gateway node in the cluster.

![Figure 4 - Gateway Failover Scenario](/images/high-availability/HA_Cluster2.png)
<!-- Image Source: https://docs.google.com/presentation/d/180CtHZnr9PP5Rh98VEmkQz3ovc5AGXG9wosoHMLhgaY/edit -->

The impact on datapath for various scenarios in a kind setup are captured in the
following [spreadsheet](https://docs.google.com/spreadsheets/d/1JsXsyRDDXkp6t55Gm-NP5EggWTyYi2yo27pyuDYwlpc/edit#gid=0).

### Gateway Health Check

The Gateway Engine continuously monitors the health of connected clusters.
It periodically pings each cluster and collects statistics including basic connectivity,
round trip time (RTT) and average latency. This information is updated in the `Gateway`
resource. Whenever the Gateway Engine detects that a ping to a particular cluster has failed,
its connection status is marked with an error state. Service Discovery uses this information
to avoid unhealthy clusters during Service discovery.

The health checking feature can be enabled/disabled via an option on the
[`subctl`](../../../operations/deployment/subctl/#join-flags-healthcheck) join command.

### Load Balancer mode

{{% notice info %}}
The load balancer mode is still experimental, and is yet to be tested in all cloud providers nor in different failover scenarios.
{{% /notice %}}

The load balancer mode is designed to simplify the deployment of Submariner in cloud environments
where worker nodes don't have a dedicated public IP available.

When enabled for a cluster during [`subctl join`](../../../operations/deployment/subctl/#join-flags-general),
the operator will create a LoadBalancer type Service exposing both the encapsulation dataplane port
as well as the NAT-T discovery port. This load balancer targets Pods labeled with
`gateway.submariner.io/status=active` and `app=submariner-gateway`.

When the LoadBalancer mode is enabled, the `preferred-server` mode is enabled automatically for
the cluster, as IPsec is incompatible with the bi-directional connection mode and the
load balancers and client/server connectivity is necessary.

![Figure 5 - Gateway behind load balancer](/images/high-availability/HA_Cluster_LB1.png)

If a failover occurred, the load balancer would update to the new available and active
gateway endpoints.

![Figure 6 - Gateway behind load balancer failover](/images/high-availability/HA_Cluster_LB2.png)

### Preferred-server mode

This mode is specific to the libreswan cable-driver which is based on IPsec. Other cable drivers ignore
this setting.

When enabled for a cluster during [`subctl join`](../../../operations/deployment/subctl/#join-flags-general),
the gateway will try to establish connection with other clusters by configuring the IPsec connection
in server mode, and waiting for remote connections.

Remote clusters will identify the `preferred-server` mode of this cluster, and attempt the connection.
This is useful in environments where on-premises clusters don't have access to port mapping.

When both sides of a connection are in `preferred-server` mode, they will compare the endpoint cable
names to decide which one will be server and which one will be client. When cable names are ordered
alphabetically, the first one will be the client, the second one will be the server.
