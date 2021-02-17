+++
title = "Globalnet Controller"
date = 2020-02-19T21:08:37+01:00
weight = 50
+++

## Introduction

Submariner is a tool built to connect overlay networks of different Kubernetes clusters. These clusters can be on different public clouds or
on-premises. An important use case for Submariner is to connect disparate independent clusters into a ClusterSet.

However, by default, a limitation of Submariner is that it doesn't handle overlapping CIDRs (ServiceCIDR and ClusterCIDR) across clusters.
Each cluster must use distinct CIDRs that don't conflict or overlap with any other cluster that is going to be part of the ClusterSet.

![Figure 1 - Problem with overlapping CIDRs](/images/globalnet/overlappingcidr-problem.png)

This is largely problematic because most actual deployments use the default CIDRs for a cluster so every cluster ends up using the same
CIDRs. Changing CIDRs on existing clusters is a very disruptive process and requires a cluster restart. So Submariner needs a way to allow
clusters with overlapping CIDRs to connect together.

## Architecture

To support overlapping CIDRs in connected clusters, Submariner has a component called Global Private Network, Globalnet (`globalnet`). This
Globalnet is a virtual network specifically to support Submariner's multi-cluster solution with a global CIDR. Each cluster is given a
subnet from this virtual Global Private Network, configured as new cluster parameter `GlobalCIDR` (e.g. 169.254.0.0/16) which is
configurable at time of deployment. User can also manually specify GlobalCIDR for each cluster that is joined to the Broker using the flag
```globalnet-cidr``` passed to ```subctl join``` command. If Globalnet is not enabled in the Broker or if a GlobalCIDR is preconfigured in
the cluster, the supplied globalnet-cidr will be ignored.

Once configured, each exported Service and Pod that requires cross-cluster access is allocated an IP, named `globalIp`,
from this `GlobalCIDR` that is annotated on the Pod/Service object.
This globalIp is used for allcross-cluster communication to and from a Pod and the globalIp of a
remote Service. Routing and iptable rules are configured to use the globalIp for ingress and egress. All address translations occur on the
Gateway node.

![Figure 1 - Proposed solution](/images/globalnet/overlappingcidr-solution.png)

{{% notice info %}}

Unlike vanilla Submariner, where Pod to Pod connectivity is also supported, Globalnet only supports Pod to remote Service connectivity using
globalIps.

{{% /notice %}}

### submariner-globalnet

Submariner Globalnet is a component that provides cross-cluster connectivity from Pods to remote Services using their globalIps. Compiled as
binary `submariner-globalnet`, it is responsible for maintaining a pool of global IPs, allocating IPs from the GlobalIp pool to pods and
services, annotating Services and Pods with their globalIp, and configuring the required rules on the gateway node to provide cross-cluster
connectivity using globalIps.
Globalnet also supports connectivity from the Nodes (including Pods that use HostNetworking) to globalIp of remote Services.
It mainly consists of two key components: the IP Address Manager and Globalnet.

#### IP Address Manager (IPAM)

The IP Address Manager (IPAM) component does the following:

* Creates a pool of IP addresses based on the `GlobalCIDR` configured on cluster.
* On creation of a Pod, or export of a Service, allocates a globalIp from the GlobalIp pool.
* Annotates the Pod or exported Service with `submariner.io/globalIp=<global-ip>`.
* On deletion of a Pod, Service or ServiceExport, releases its globalIp back to the pool.

#### Globalnet

This component is responsible for programming the routing entries, iptable rules and does the following:

* Creates initial iptables chains for Globalnet rules.
* Whenever a Pod is annotated with a globalIp, creates an egress SNAT rule to convert the source Ip from the Pod's Ip to the Pod's globalIp
  on the Gateway Node.
* Whenever a Service is annotated with a globalIp, creates an ingress rule to direct all traffic destined to the Service's globalIp to the
  Service's `kube-proxy` iptables chain which in turn directs traffic to Service's backend Pods.
* On deletion of pod/service, clean up the rules from the gateway node.

Globalnet currently relies on `kube-proxy` and thus will only work with deployments that use `kube-proxy`.

### Service Discovery - Lighthouse

Connectivity is only part of the solution as pods still need to know the IPs of services on remote clusters.

This is achieved by enhancing [lighthouse](https://github.com/submariner-io/lighthouse) with support for Globalnet. The Lighthouse
controller adds the service's globalIp to the `ServiceImport` object that is distributed to all clusters. The [lighthouse
plugin](https://github.com/submariner-io/lighthouse/tree/devel/plugin/lighthouse) then uses the Service's globalIp when replying to DNS
queries for the Service.

## Building

Nothing extra needs to be done to build `submariner-globalnet` as it is built with the standard Submariner build.
