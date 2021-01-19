---
title: "OVN Kubernetes"
---

A specific handler component is deployed for the
[OVN Kubernetes CNI plugin](https://github.com/ovn-org/ovn-kubernetes).

[OVN](https://www.ovn.org/en/architecture/) is a project that builds on top
of Open vSwitch providing a rich high level API for describing virtual
network components like Logical Routers, Logical Switches, Load balancers,
Logical Ports. OVN Kubernetes is a Cloud Management System Plugin (CMS plugin)
in terms of the OVN project.

The OVN Kubernetes handler watches for Submariner `Endpoints` and Kubernetes
`Nodes` and interfaces with the OVN databases (OVN NorthDB and SouthDB) to store and
maintain information necessary for Submariner, including:

* A logical router named `submariner_router` that handles the communication
  to remote clusters and has a leg on the network which can talk to the
  `ovn-k8s-gw0` interface on the Gateway node. This router is pinned to
  the active Gateway chassis.

* Routing policies added to the existing `ovn_cluster_router` which redirect
  traffic targeted for remote routers through the `submariner_router`.

* A `submariner_join` logical switch that connects the `submariner_router`
  with the `ovn_cluster_router`.

## The handler architecture

The following diagram illustrates the OVN Kubernetes handler architecture where the
blue elements represent the OVN Kubernetes native network elements and the yellow
elements are introduced by Submariner.

![Submariner with OVNKubernetes architecture](/images/ovn-kubernetes/submariner-on-ovn-v2.svg)
