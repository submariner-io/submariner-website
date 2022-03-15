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
subnet from this virtual Global Private Network, configured as new cluster parameter `GlobalCIDR` (e.g. 242.0.0.0/8) which is
configurable at time of deployment. User can also manually specify GlobalCIDR for each cluster that is joined to the Broker using the flag
```globalnet-cidr``` passed to ```subctl join``` command. If Globalnet is not enabled in the Broker or if a GlobalCIDR is preconfigured in
the cluster, the supplied Globalnet CIDR will be ignored.

### Cluster-scope global egress IPs

By default, every cluster is assigned a configurable number of global IPs, represented by a `ClusterGlobalEgressIP` resource, which are
used as egress IPs for cross-cluster communication. Multiple IPs are supported to avoid ephemeral port exhaustion issues. The default is 8.
The IPs are allocated from a configurable global CIDR.
Applications running on the host network that access remote clusters also use the cluster-level global egress IPs.

### Namespace-scope global egress IPs

A user can assign a configurable number of global IPs per namespace by creating a `GlobalEgressIP` resource. These IPs are also allocated
from the global CIDR and are used as egress IPs for all or selected pods in the namespace and take precedence over the cluster-level
global IPs. In addition, the global IPs allocated for a `GlobalEgressIP` that targets specific pods in a namespace take precedence
over the global IPs allocated for a `GlobalEgressIP` that just targets the namespace.

### Service global ingress IPs

Exported `ClusterIP` type services are automatically allocated a global IP from the global CIDR for ingress. For headless services, each
backing pod is allocated a global IP that is used for both ingress and egress. However, if a backing pod matches a `GlobalEgressIP` then
its allocated IPs are used for egress.

Routing and iptable rules are configured to use the corresponding global IPs for ingress and egress. All address translations occur on the active
Gateway node of the cluster.

![Figure 1 - Proposed solution](/images/globalnet/overlappingcidr-solution.png)

![Figure 2 - Globalnet priority](/images/globalnet/globalnet-priority.png)
<!-- Image Source: https://docs.google.com/presentation/d/180CtHZnr9PP5Rh98VEmkQz3ovc5AGXG9wosoHMLhgaY/edit -->

### `submariner-globalnet`

Submariner Globalnet is a component that provides cross-cluster connectivity from pods to remote services using their global IPs. Compiled as
binary `submariner-globalnet`, it is responsible for maintaining a pool of global IPs, allocating IPs from the global IP pool to pods and
services, and configuring the required rules on the gateway node to provide cross-cluster connectivity using global IPs.
Globalnet also supports connectivity from the nodes (including pods that use host networking) to the global IP of remote services.
It mainly consists of two key components: the IP Address Manager and Globalnet.

#### IP Address Manager (IPAM)

The IP Address Manager (IPAM) component does the following:

* Creates a pool of IP addresses based on the `GlobalCIDR` configured on cluster.
* Allocates IPs from the global pool for all ingress and egress, and releases them when no longer needed.

#### Globalnet

This component is responsible for programming the routing entries, iptable rules and does the following:

* Creates initial iptables chains for Globalnet rules.
* For each `GlobalEgressIP`, creates corresponding SNAT rules to convert the source IPs for all the matching pods to the corresponding
  global IP(s) allocated to the `GlobalEgressIP` object.
* For each exported service, creates an ingress rule to direct all traffic destined to the Service's global IP to the service's
  `kube-proxy` iptables chain which in turn directs traffic to service's backend pods.
* Clean up the rules from the gateway node on the deletion of a `Pod`, `Service`, or `ServiceExport`.

Globalnet currently relies on `kube-proxy` and thus will only work with deployments that use `kube-proxy`.

### Service Discovery - Lighthouse

Connectivity is only part of the solution as pods still need to know the IPs of services on remote clusters.

This is achieved by enhancing [Lighthouse](https://github.com/submariner-io/lighthouse) with support for Globalnet. The Lighthouse
controller uses a service's global IP when creating the `ServiceImport` for services of type `ClusterIP`. For headless services,
backing pod's global IP is used when creating the `EndpointSlice` resources to be distributed to other clusters.
The [Lighthouse plugin](https://github.com/submariner-io/lighthouse/tree/devel/plugin/lighthouse) then uses the global IPs when
replying to DNS queries.

## Building

Nothing extra needs to be done to build `submariner-globalnet` as it is built with the standard Submariner build.

## Prerequisites

Allow Globalnet controller to create/update/delete the `Service` with `externalIPs` by below steps:

1. Disable [DenyServiceExternalIPs](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#denyserviceexternalips),
if enabled.
2. Restrict the use of the `Service` with `externalIPs`:
    * OpenShift: No extra configuration is needed.
    The default
    [network.openshift.io/ExternalIPRanger](https://docs.openshift.com/container-platform/4.9/architecture/admission-plug-ins.html)
    validating admission plug-in allows the use of the `Service` with `externalIPs` only for users with permission to handle
    the `service/externalips` resource in the `network.openshift.io` group.
    By default, `submariner-globalnet`'s `ServiceAccount` has such an RBAC rule.
    * Other Kubernetes distributions:
    Enable [externalip-webhook](https://github.com/kubernetes-sigs/externalip-webhook) while specifying `allowed-external-ip-cidrs` to
    include the `GlobalCIDR` allocated to the cluster and `allowed-usernames` to include
    `system:serviceaccount:submariner-operator:submariner-globalnet`.

{{% notice note %}}
The steps above are necessary because for every exported `Service`, Submariner
Globalnet internally creates a `Service` with `externalIPs` and sets the `externalIPs`
to the globalIP assigned to the respective `Service`.
Some deployments of Kubernetes do not allow the `Service` with `externalIPs` to be created
for [security reasons](https://github.com/kubernetes/kubernetes/issues/97076).
{{% /notice %}}

## Usage

Refer to the [Quickstart Guides](../../quickstart/) on how to deploy Submariner with Globalnet enabled. For most deployments users will not
need to do anything else once deployed. However, users can create `GlobalEgressIP`s or edit the `ClusterGlobalEgressIP` for specific
use cases.

### Ephemeral Port Exhaustion

By default, 8 cluster-scoped global IPs are allocated which allows for ~8x64k active ephemeral ports. If those are still
not enough for a cluster, this number can be increased by setting the `NumberOfIPs` field in the `ClusterGlobalEgressIP` with the
well-known name `cluster-egress.submariner.io`:

```yaml
   apiVersion: submariner.io/v1alpha1
   kind: ClusterGlobalEgressIP
   metadata:
     name: cluster-egress.submariner.io
   spec:
     NumberOfIPs: 9
```

{{% notice note %}}
Only the `ClusterGlobalEgressIP` resource with the name `cluster-egress.submariner.io` is recognized by Globalnet. This resource is automatically
created with the default number of IPs.
{{% /notice %}}

### Global IPs for a Namespace

If it's desired for all pods in a namespace to use a unique global IP instead of one of the cluster-scoped IPs, a user can create a
`GlobalEgressIP` resource in that namespace:

```yaml
   apiVersion: submariner.io/v1alpha1
   kind: GlobalEgressIP
   metadata:
     name: ns-egressip
     namespace: ns1
   spec:
     NumberOfIPs: 1
```

The example above will allocate 1 global IP which will be used as egress IP for all pods in namespace `ns1`.

{{% notice note %}}
`NumberOfIPs` can have minimum value of `0` and maximum of `20`
{{% /notice %}}

### Global IPs for a set of pods

If it's desired for a set of pods in a namespace to use unique global IP(s), a user can create a `GlobalEgressIP` resource in that
namespace with the `podSelector` field set:

```yaml
   apiVersion: submariner.io/v1alpha1
   kind: GlobalEgressIP
   metadata:
     name: db-pods
     namespace: ns1
   spec:
     podSelector:
         matchLabels:
           role: db
     NumberOfIPs: 1
```

The example above will allocate 1 global IP which will be used as egress IP for all pods matching label `role=db` in namespace `ns1`.
