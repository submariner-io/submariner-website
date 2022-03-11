+++
title = "Getting Started"
date = 2020-02-19T20:03:44+01:00
weight = 10
pre = "<b>1. </b>"
+++

## Basic Overview

Submariner consists of several main components that work in conjunction to securely connect workloads across multiple Kubernetes clusters.
For more information about Submariner's architecture, please refer to the [Architecture](./architecture) section.

### The Broker

The Broker is an API that all participating clusters are given access to, and where two objects are exchanged via CRDs in `.submariner.io`:

* Cluster: defines a participating cluster and its IP CIDRs.
* Endpoint: defines a connection endpoint to a cluster, and the reachable cluster IPs from the endpoint.

The Broker must be deployed on a single Kubernetes cluster. This cluster’s API server must be reachable by all Kubernetes clusters connected
by Submariner. It can be a dedicated cluster, or one of the connected clusters.

### The Submariner Deployment on a Cluster

Once Submariner is deployed on a cluster with the proper credentials to the Broker it will exchange Cluster and Endpoint objects with other
clusters (via push/pull/watching), and start forming connections and routes to other clusters.

## Prerequisites

Submariner has a few requirements to get started:

* At least two Kubernetes clusters, one of which is designated to serve as the central Broker that is accessible by all of your connected
clusters; this can be one of your connected clusters, or a dedicated cluster.
* Minimum supported Kubernetes version is 1.17.
* Non-overlapping Pod and Service CIDRs between clusters. This is to prevent routing conflicts. For cases where addresses **do
overlap**, [Globalnet](./architecture/globalnet) can be set up.
* IP reachability between the gateway nodes. When connecting two clusters, the gateways must have at least one-way connectivity
  to each other on their public or private IP address and encapsulation port. This is needed for creating the tunnels between
  the clusters. The default encapsulation port is 4500/UDP, for [NAT Traversal](./../operations/nat-traversal) discovery port
  4490/UDP is used.
For clusters behind corporate firewalls that block the default ports, Submariner also supports NAT Traversal
(NAT-T) with the option to set custom non-standard ports like 4501/UDP.
* Submariner uses UDP port 4800 to encapsulate Pod traffic from worker and master nodes to the Gateway nodes. This is required in order to
preserve the source IP addresses of the Pods. Ensure that firewall configuration allows 4800/UDP across all nodes in the cluster in both
directions.
* Submariner uses TCP port 8080 to export metrics on the Gateway nodes. Ensure that firewall configuration allows ingress 8080/TCP on
the Gateway nodes so that other nodes in the cluster can access it. Also, no other workload on the Gateway nodes should be listening on TCP
port 8080.
* Worker node IPs on all connected clusters must be outside of the Pod/Service CIDR ranges.

An example of three clusters configured to use with Submariner (without Globalnet) would look like the following:

| Cluster Name | Provider | Pod  CIDR    | Service CIDR | Cluster Nodes CIDR |
|:-------------|:---------|:-------------|:-------------|--------------------|
| broker       | AWS      | 10.42.0.0/16 | 10.43.0.0/16 | 192.168.1.0/24     |
| west         | vSphere  | 10.0.0.0/16  | 10.1.0.0/16  | 192.168.1.0/24     |
| east         | On-Prem  | 10.98.0.0/16 | 10.99.0.0/16 | 192.168.1.0/24     |

## Support Matrix

Submariner is designed to be cloud provider agnostic, and should run in any standard Kubernetes cluster. Submariner has been tested with the
following network (CNI) Plugins:

* [OpenShift-SDN](https://github.com/openshift/sdn)
* [Weave](https://github.com/weaveworks/weave)
* [Flannel](https://github.com/coreos/flannel)
* [Canal](https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel)
* [Calico](https://www.projectcalico.org/) (see the [Calico-specific deployment instructions](../operations/deployment/calico/))
* [OVN](https://github.com/ovn-org/ovn-kubernetes)

Submariner supports all currently-supported Kubernetes versions, as determined by [the Kubernetes release policy](https://kubernetes.io/releases/).

## Deployment

Submariner is deployed and managed using its Operator. [Submariner's Operator](https://github.com/submariner-io/submariner-operator) can be
deployed using [subctl](../operations/deployment) or [Helm](../operations/deployment/helm).

The recommended deployment method is `subctl`, as it is currently the default in CI and provides diagnostic features.
