+++
title = "Architecture"
date = 2020-02-19T21:00:30+01:00
weight = 5
+++

The diagram below illustrates the basic architecture of Submariner:

![Submariner Architecture](/images/submariner/architecture.jpg)

Submariner consists of several main components that work in conjunction to securely connect workloads across multiple Kubernetes clusters,
both on-premises and on public clouds:

* [Gateway Engine](./gateway-engine/): manages the secure tunnels to other clusters.
* [Route Agent](./route-agent/): routes cross-cluster traffic from nodes to the active Gateway Engine.
* [Broker](./broker/): facilitates the exchange of metadata between Gateway Engines enabling them to discover one another.
* [Service Discovery](./service-discovery/): provides DNS discovery of Services across clusters.

Submariner has optional components that provide additional functionality:

* [Globalnet Controller](./globalnet/): handles interconnection of clusters with overlapping CIDRs.
