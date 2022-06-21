---
title: "OVN Kubernetes"
---

A specific handler component is deployed for the
[OVN Kubernetes CNI plugin](https://github.com/ovn-org/ovn-kubernetes).

[OVN](https://www.ovn.org/en/architecture/) is a project that builds on top
of Open vSwitch providing a rich high level API for describing virtual
network components like Logical Routers, Logical Switches, Load balancers,
Logical Ports. [OVN Kubernetes](https://github.com/ovn-org/ovn-kubernetes) is a Cloud Management System Plugin (CMS plugin)
which manages OVN resources to setup networking for Kubernetes clusters.

The OVN Kubernetes handler watches for Submariner `Endpoints` and Kubernetes
`Nodes` and interfaces with the OVN databases (OVN NorthDB and SouthDB) to store and
create OVN resources necessary for Submariner, including:

* A logical router named `submariner_router` that handles the communication
  to remote clusters and has a leg on the network which can talk to the
  `ovn-k8s-sub0` interface on the Gateway node. This router is pinned to
  the active Gateway chassis.

* The Ovn-Kubernetes Specific OVN Load Balancer Group (which contains all of the
  cluster's service VIPs) is added to the `submariner_router`in order to ensure
  total service connectivity.  

* OVN Logical Router Static Routes added to the `submariner_router` to ensure
  local traffic destined for remote clusters and remote traffic destined for local
  resources is routed correctly.

* OVN Logical Router Policies added to the existing `ovn_cluster_router` which redirect
  traffic targeted for remote routers through the `submariner_router`.

* A `submariner_join` logical switch that connects the `submariner_router`
  with the `ovn_cluster_router`.

## The handler architecture

The following diagram illustrates the required Submariner OVN architecture transposed
on the native OVN-Kubernetes managed OVN architecture and components. The specific
`networkpluginsyncer` managed OVN components are boxed in green.

![Submariner with OVNKubernetes architecture](/images/ovn-kubernetes/ovn-submariner-architecture.svg)
<!-- Image Source: https://docs.google.com/presentation/d/180CtHZnr9PP5Rh98VEmkQz3ovc5AGXG9wosoHMLhgaY/edit#slide=id.g135fd365b7e_0_5 -->
