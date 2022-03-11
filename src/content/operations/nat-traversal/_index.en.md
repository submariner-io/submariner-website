+++
title = "NAT Traversal"
date = 2020-08-12T16:02:00+02:00
weight = 25
+++

## Basic Overview

Submariner establishes the dataplane tunnels between clusters over port
`4500/UDP` by default. This port can be customized per cluster and per gateway
and is published as part of the `Endpoint` objects.

### Public vs Private IP

`Endpoint` objects publish both a `PrivateIP` and a `PublicIP`. The `PrivateIP` is the IP assigned
to an interface on the gateway node where the `Endpoint` originated. The `PublicIP` is the source
IP for the packets sent from the gateway to the Internet which is discovered by default via
[ipify.org](https://ipify.org), or [my-ip.io](https://my-ip.io) and [seeip.org](https://seeip.org)
fallbacks.

Alternative methods can be configured on each gateway Node via the `gateway.submariner.io/public-ip` annotation:

```bash
kubectl annotate node $GW gateway.submariner.io/public-ip=<resolver>,[resolver...]
```

Resolvers are evaluated one by one, using the result of the first one to succeed.
`<resolver>` should be written in the following form: `method:parameter`, and the
following methods are implemented:

| Method   | Parameter                                                        | Notes                                                  |
|:---------|:-----------------------------------------------------------------|:-------------------------------------------------------|
|   api    | HTTPS endpoint to contact, for example api.ipify.org             | The result body is inspected looking for the IP address|
|   lb     | LoadBalancer Service name in the `submariner-operator` namespace | A network load balancer should be used                 |
|   ipv4   | Fixed IPv4 address used as public IP                             |                                                        |
|   dns    | FQDN DNS entry to be resolved                                    | The A entry of the FQDN will be resolved and used      |

For example, when using a fixed public IPv4 address for a gateway, this can be used:

```bash
kubectl annotate node $GW gateway.submariner.io/public-ip=ipv4:1.2.3.4
```

### Reachability

For two gateway `Endpoints` to connect to one another, at least one of them should be reachable
either on its public or private IP address and the firewall configuration should allow the
tunnel encapsulation port.
If one of the clusters is designated as a _preferred server_, then only its `Endpoint` needs
to be reachable to the other endpoints. This can be accomplished by joining the cluster
in preferred server mode.

```bash
subctl join --kubeconfig A --preferred-server ... broker_info.subm
```

Each gateway implements a UDP NAT-T discovery protocol where each gateway queries the
gateways of the remote clusters on both the public and private IPs in order to
determine the most suitable IP and its NAT characteristics to use for the tunnel
connections, with a preference for the private IP.

This protocol is enabled by default on port `4490/UDP` and can assign non default
ports by annotating the gateway nodes:

```bash
kubectl annotate node $GW gateway.submariner.io/natt-discovery-port=4490
```

If the NATT discovery protocol fails to determine reachability between two endpoints then it
falls back to the NAT setting specified on join (the `natEnabled` field of the `Submariner` object or the
`--natt` parameter of `subctl`), that is, if NAT is enabled, the public IP is used otherwise the private IP
is used.

### IP Selection Algorithm

The following flow chart describes the IP selection algorithm:

<!-- source: https://app.diagrams.net/#G1e_M84l8iQH6U4QqD3-Jw2ypIWiRfLQkk -->
![Public/Private IP selection](/images/natt/public_private_selection_algorithm.svg)

### Port Selection

If the gateways of a cluster don't have public floating or elastic IPs assigned
to them then it's recommended to use a separate UDP port for every node marked
as a gateway. This will allow eventual port mapping on a router
when communicating to clusters on remote sites with no direct routing.

{{% notice note %}}
If a cluster is behind a router which will NAT the traffic, it's recommended to
map the open ports into the gateway node private IPs, see the port mapping
section. It could temporarily work without mapping, because most routers when
performing NAT to the external network will not randomize or modify the source
port of packets, but **this will happen as soon as two connections collide
over the same source port**.
{{% /notice %}}

## UDP Dataplane Protocol (IPsec, WireGuard or VXLAN)

By default, Submariner uses the `4500/UDP` port for the dataplane. This can be changed
cluster-wide via the `--nattport` flag on join although it's possible to specify
the port to be used per gateway node:

```bash
kubectl annotate node $GW gateway.submariner.io/udp-port=4501
```

This allows individual gateways on the cluster to have different port numbers,
hence allowing individual port-mapping if a public IP is shared.

## IPsec

### ESP or UDP Encapsulation

IPsec in the Libreswan cable driver will be configured for the more performant ESP protocol
whenever possible, which is normally when NAT is not detected and connectivity over the private IP is possible.

If your network and routers filter the `IP>ESP` packets, encapsulation can be forced
by using the `--force-udp-encaps` during `subctl` join.

## Practical Examples

### All Private and Routed

This is the simplest practical case where all gateways can contact
all other gateways via routing on their private IPs and no NAT is needed.

<!-- source: https://app.diagrams.net/#G1IORJ9qW95qJ15P6Xk6idEfI4jj9Uo84l -->
![All private and routed](/images/natt/nat_scenario_all_private_routed.svg)

The NATT discovery protocol will determine that the private IPs are preferred, and
will try to avoid using NAT.

### All Public Cloud, with Some Private Reachability

In this case case, the gateways for clusters A and B have direct reachability
over their private IPs (10.0.0.1 and 10.1.0.1) possibly with large MTU capabilities.  The
same is true for clusters C and D (192.168.0.4 and 192.168.128.4).

Between any other pair of clusters reachability is only possible over
their public IPs and the IP packets will undergo DNAT + SNAT translation at the
border via the elastic or floating IP and also, while on transit via the public
network, the MTU will be limited to 1500 bytes or less.

<!-- source: https://app.diagrams.net/#G1IORJ9qW95qJ15P6Xk6idEfI4jj9Uo84l -->
![Public vs on-premises](/images/natt/nat_scenario_all_public.svg)

#### Endpoints

| Endpoint | Private IP      | Public IP |
|:---------|:----------------|:----------|
|   A      | 10.0.0.1        | 1.1.1.1   |
|   B      | 10.1.0.1        | 1.1.1.2   |
|   C      | 192.168.0.4     | 2.1.1.1   |
|   D      | 192.168.128.4   | 2.1.1.2   |

#### Connections

| Left Cluster |  Left IP     | Left Port | Right Cluster  | Right IP       | Right Port | NAT   |
|:-------------|:-------------|:----------|:---------------|:---------------|:-----------|:------|
| A            |  10.0.0.1    | 4500      | B              | 10.1.0.1       | 4500       | no    |
| C            |  192.168.0.4 | 4500      | D              | 192.168.128.4  | 4500       | no    |
| A            |  1.1.1.1     | 4500      | C              | 2.1.1.1        | 4500       | yes   |
| A            |  1.1.1.1     | 4500      | D              | 2.1.1.2        | 4500       | yes   |
| B            |  1.1.1.2     | 4500      | C              | 2.1.1.1        | 4500       | yes   |
| B            |  1.1.1.2     | 4500      | D              | 2.1.1.2        | 4500       | yes   |

The default configuration for the NAT-T discovery protocol will detect the IPs to use, make
sure that the gateways have port 4490/udp open, as well as the encapsulation port `4500/udp`.

### Public Cloud vs On-Premises

In this case case, A & B cluster gateways have direct reachability over their private
IPs (10.0.0.1 and 10.1.0.1) possibly with large MTU capabilities. The
same is true for the C & D cluster gateways (192.168.0.4 and 192.168.128.4).

Between all other cluster pairs reachability is only possible over
their public IPs, the IP packets from A & B will undergo DNAT + SNAT translation at the
border via the elastic or floating IP,  the packets from C & D will undergo SNAT translation
to the public IP of the router 2.1.1.1 and also, while on transit via the public
network, the MTU will be limited to 1500 bytes or less.

<!-- source: https://app.diagrams.net/#G1tUJ3DOdaM1krgxrWXQ82zpIcdsh4liLv -->
![Public vs on-premises](/images/natt/nat_scenarios_1.svg)

#### Endpoints for Public Cloud to On-Premises

| Endpoint | Private IP      | Public IP |
|:---------|:----------------|:----------|
|   A      | 10.0.0.1        | 1.1.1.1   |
|   B      | 10.1.0.1        | 1.1.1.2   |
|   C      | 192.168.0.4     | 2.1.1.1   |
|   D      | 192.168.128.4   | 2.1.1.1   |

#### Connections for Public Cloud to On-Premises

| Left Cluster |  Left IP     | Left Port | Right Cluster  | Right IP       | Right Port | NAT   |
|:-------------|:-------------|:----------|:---------------|:---------------|:-----------|:------|
| A            |  10.0.0.1    | 4500      | B              | 10.1.0.1       | 4500       | no    |
| C            |  192.168.0.4 | 4501      | D              | 192.168.128.4  | 4502       | no    |
| A            |  1.1.1.1     | 4500      | C              | 2.1.1.1        | 4501       | yes   |
| A            |  1.1.1.1     | 4500      | D              | 2.1.1.1        | 4502       | yes   |
| B            |  1.1.1.2     | 4500      | C              | 2.1.1.1        | 4501       | yes   |
| B            |  1.1.1.2     | 4500      | D              | 2.1.1.1        | 4502       | yes   |

The recommended configuration for the gateways behind the on-premises router which has
a single external IP with no IP routing or mapping to the private network is to have a
dedicated and distinct port number for the NATT discovery protocol (as well as the encapsulation)

```bash
kubectl annotate node $GWC --kubeconfig C gateway.submariner.io/natt-discovery-port=4491
kubectl annotate node $GWC --kubeconfig C gateway.submariner.io/udp-port=4501
kubectl annotate node $GWD --kubeconfig D gateway.submariner.io/natt-discovery-port=4492
kubectl annotate node $GWD --kubeconfig D gateway.submariner.io/udp-port=4502

# restart the gateways to pick up the new setting
for cluster in C D;
do
  kubectl delete pod -n submariner-operator -l app=submariner-gateway --kubeconfig $cluster
done
```

{{% notice warning %}}
If **HA** is configured on the on-premise clusters, **each gateway** behind the 2.1.1.1 router
**should have a dedicated UDP port**. For example if we had two clusters and two gateways on each
cluster, four ports would be necessary.
{{% /notice %}}

#### Router Port Mapping

Under this configuration it's important to map the UDP ports on the 2.1.1.1 router to the private
IPs of the gateways.

| External IP | Port | Internal IP   | Port | Protocol |
|:------------|:-----|:--------------|:-----|:---------|
| 2.1.1.1     | 4501 | 192.168.0.4   | 4501 | UDP      |
| 2.1.1.1     | 4491 | 192.168.0.4   | 4491 | UDP      |
| 2.1.1.1     | 4502 | 192.168.128.4 | 4502 | UDP      |
| 2.1.1.1     | 4492 | 192.168.128.4 | 4492 | UDP      |

{{% notice note %}}
Without port mapping it's entirely possible that the connectivity will be established without
issues. This can happen because the router's NAT will not generally modify the source port
of the outgoing UDP packets, and future packets arriving on this port will be redirected to the
internal IP which initiated connectivity. However if the 2.1.1.1 router randomizes the source port on
NAT or if other applications on the internal network were already using the 4501-4502 or 4491-4492
ports, the remote ends would not be able to contact gateway C or D over the expected ports.
{{% /notice %}}

#### Alternative to Port Mapping

If port mapping is not possible, we can enable a server/client model for connections
where we designate the clusters with a dedicated public IP or the clusters with the
ability to get mapped ports as **preferred servers**. In this way, only the non-preferred
server clusters will initiate connections to the preferred server clusters.

For example, given clusters A, B, C, and D, we designate A and B as preferred servers:

```bash
subctl join --kubeconfig A --preferred-server .... broker_info.subm
subctl join --kubeconfig B --preferred-server .... broker_info.subm
```

This means that the gateways for clusters A and B will negotiate which one will be the server
based on the `Endpoint` names. Clusters C and D will connect to clusters A and B as clients.
Clusters C and D will connect normally.

### Multiple on-premise sites

In this case case, A & B cluster gateways have direct reachability over their private
IPs (10.0.0.1 and 10.1.0.1) possibly with large MTU capabilities. The
same is true for the C & D cluster gateways (192.168.0.4 and 192.168.128.4).

Between all other cluster pairs reachability is only possible over
their public IPs, the IP packets from A,B,C & D will undergo SNAT translation at the
border with the public network also, while on transit via the public
network the MTU will be limited to 1500 bytes or less.

<!-- source: https://app.diagrams.net/#G1Nrbs6Kx3yuP23YlIfSbLIgXPRcmVjSMy -->
![on-premises vs on-premises](/images/natt/nat_scenarios_2.svg)

#### Endpoints for Multiple On-Premises

| Endpoint | Private IP      | Public IP |
|:---------|:----------------|:----------|
|   A      | 10.0.0.1        | 1.1.1.1   |
|   B      | 10.1.0.1        | 1.1.1.1   |
|   C      | 192.168.0.4     | 2.1.1.1   |
|   D      | 192.168.128.4   | 2.1.1.1   |

#### Connections for Multiple On-Premises

| Left Cluster |  Left IP     | Left Port | Right Cluster  | Right IP       | Right Port | NAT   |
|:-------------|:-------------|:----------|:---------------|:---------------|:-----------|:------|
| A            |  10.0.0.1    | 4501      | B              | 10.1.0.1       | 4502       | no    |
| C            |  192.168.0.4 | 4501      | D              | 192.168.128.4  | 4502       | no    |
| A            |  1.1.1.1     | 4501      | C              | 2.1.1.1        | 4501       | yes   |
| A            |  1.1.1.1     | 4501      | D              | 2.1.1.1        | 4502       | yes   |
| B            |  1.1.1.1     | 4502      | C              | 2.1.1.1        | 4501       | yes   |
| B            |  1.1.1.1     | 4502      | D              | 2.1.1.1        | 4502       | yes   |

Every gateway must have its own port number for NATT discovery, as well as for encapsulation,
and the ports on the NAT gateway should be mapped to the internal IPs and ports of the gateways.

```bash
kubectl annotate node $GWA --kubeconfig A gateway.submariner.io/natt-discovery-port=4491
kubectl annotate node $GWA --kubeconfig A gateway.submariner.io/udp-port=4501
kubectl annotate node $GWB --kubeconfig B gateway.submariner.io/natt-discovery-port=4492
kubectl annotate node $GWB --kubeconfig B gateway.submariner.io/udp-port=4502
kubectl annotate node $GWC --kubeconfig C gateway.submariner.io/natt-discovery-port=4491
kubectl annotate node $GWC --kubeconfig C gateway.submariner.io/udp-port=4501
kubectl annotate node $GWD --kubeconfig D gateway.submariner.io/natt-discovery-port=4492
kubectl annotate node $GWD --kubeconfig D gateway.submariner.io/udp-port=4502

# restart the gateways to pick up the new setting
for cluster in A B C D;
do
  kubectl delete pod -n submariner-operator -l app=submariner-gateway --kubeconfig $cluster
done
```

{{% notice warning %}}
If **HA** is configured on the on-premises clusters, **each gateway** behind the routers
**should have a dedicated UDP port**. For example if we had two clusters and two gateways on each network,
four ports would be necessary.
{{% /notice %}}

#### Router Port Mapping for Multiple On-Oremises

Under this configuration it's important to map the UDP ports on the 2.1.1.1 router to the private
IPs of the gateways.

##### On the 2.1.1.1 router

| External IP | Port | Internal IP   | Port | Protocol |
|:------------|:-----|:--------------|:-----|:---------|
| 2.1.1.1     | 4501 | 192.168.0.4   | 4501 | UDP      |
| 2.1.1.1     | 4491 | 192.168.0.4   | 4491 | UDP      |
| 2.1.1.1     | 4502 | 192.168.128.4 | 4502 | UDP      |
| 2.1.1.1     | 4492 | 192.168.128.4 | 4492 | UDP      |

##### On the 1.1.1.1 router

| External IP | Port | Internal IP   | Port | Protocol |
|:------------|:-----|:--------------|:-----|:---------|
| 1.1.1.1     | 4501 | 10.0.0.1      | 4501 | UDP      |
| 1.1.1.1     | 4491 | 10.0.0.1      | 4491 | UDP      |
| 1.1.1.1     | 4502 | 10.1.0.1      | 4502 | UDP      |
| 1.1.1.1     | 4492 | 10.1.0.1      | 4492 | UDP      |

{{% notice note %}}
Without port mapping it's entirely possible that the connectivity will be established without
issues, this happens due to the fact that route's NAT will not generally modify the src port
of the outgoing UDP packets, and future packets arriving this port will be redirected to the
internal IP which initiated connectivity, but if the 2.1.1.1 router randomizes the source port on
NAT, or if other applications on the internal network were already using the 4501-4502,4491-4492
ports, the remote ends would not be able to contact gateway C or D over the expected ports.
{{% /notice %}}

### Double NAT Traversal

In this case case, A & B cluster gateways have direct reachability over their private
IPs (10.0.0.1 and 10.1.0.1) possibly with large MTU capabilities, while between cluster
C and D (192.168.0.4 and 192.168.0.4 too), reachability over the private IPs is not possible
but it would be possible over the private floating IPs 10.2.0.1 and 10.2.0.2. However Submariner
is unable to detect such floating IPs.

<!-- source: https://app.diagrams.net/#G1VTxw02pmAgE1WeGX5vWfSswZNciK-5AC -->
![on-premises vs on-premises](/images/natt/double_nat_scenario.svg)

#### Endpoints for Double NAT

| Endpoint | Private IP      | Public IP |
|:---------|:----------------|:----------|
|   A      | 10.0.0.1        | 1.1.1.1   |
|   B      | 10.1.0.1        | 1.1.1.1   |
|   C      | 192.168.0.4     | 2.1.1.1   |
|   D      | 192.168.0.4     | 2.1.1.1   |

A problem will exist between C & D because they can't reach each other neither on 2.1.1.1
or ther IPs since the private CIDRs overlap.

This is a complicated topology that is still not supported in Submariner. Possible solutions to this could be:

* Modifying the CIDRs of the virtual networks for clusters C & D, and then
  peer the virtual routers of those virtual networks to perform routing between C & D. Then
  C & D would be able to connect over the private IPs to each other.

* Support manual addition of multiple IPs per gateway, so
  each Endpoint would simply expose a list of IPs with preference instead of just a Public/Private
  IP.
