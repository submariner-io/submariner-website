+++
title = "Quickstart Guide"
date = 2020-02-19T20:03:44+01:00
weight = 5
pre = "<b>1. </b>"
+++

## Basic Overview

Submariner consists of several main components that work in conjunction to securely connect workloads across multiple Kubernetes clusters.
For more information about Submariner's architecture, please refer to the [Architecture](../architecture) section.

### The Broker

The Broker is an API to which all participating clusters are given access to, and where two objects are exchanged via CRDs:

* Cluster(.submariner.io): defines a participating cluster and its IP CIDRs.
* Endpoint(.submariner.io): defines a connection endpoint to a cluster, and the reachable cluster IPs from the endpoint.

The Broker must be deployed on a single Kubernetes cluster. This cluster’s API server must be reachable by all Kubernetes clusters connected
by Submariner. It can be a dedicated cluster, or one of the connected clusters.

### The Submariner Deployment on a Cluster

Once Submariner is deployed on a cluster with the proper credentials to the Broker it will exchange Cluster and Endpoint objects with other
clusters (via push/pull/watching), and start forming connections and routes to other clusters.

## Prerequisites

Submariner has a few requirements to get started:

* At least two Kubernetes clusters, one of which is designated to serve as the central Broker that is accessible by all of your connected
  clusters; this can be one of your connected clusters, or a dedicated cluster.
* Non-overlapping Pod and Service CIDRs between clusters. This is to prevent routing conflicts. For cases where addresses **do
  overlap**, [Globalnet](../architecture/globalnet) can be set up.
* IP reachability between the gateway nodes. When connecting two clusters, at least one of the clusters should have a publicly routable
  IP address designated to the Gateway node. This is needed for creating the IPsec tunnel between the clusters. The default ports used by
IPsec are 4500/UDP and 500/UDP. For clusters behind corporate firewalls that block the default ports, Submariner also supports NAT Traversal
(NAT-T) with the option to set custom non-standard ports like 4501/UDP and 501/UDP.
* Submariner uses port 4800/UDP to encapsulate traffic from the Worker nodes to the Gateway nodes and ensuring that Pod IP addresses are
preserved. Ensure that firewall configuration allows 4800/UDP across all the Worker nodes.
* Worker node IPs on all connected clusters must be outside of the Pod/Service CIDR ranges.

An example of three clusters configured to use with Submariner (without Globalnet) would look like the following:

| Cluster Name | Provider | Pod  CIDR    | Service CIDR | Cluster Nodes CIDR |
|:-------------|:---------|:-------------|:-------------|--------------------|
| broker       | AWS      | 10.42.0.0/16 | 10.43.0.0/16 | 192.168.1.0/24     |
| west         | vSphere  | 10.0.0.0/16  | 10.1.0.0/16  | 192.168.1.0/24     |
| east         | OnPrem   | 10.98.0.0/16 | 10.99.0.0/16 | 192.168.1.0/24     |

## Support Matrix

Submariner is designed to be cloud provider agnostic, and should run in any standard Kubernetes cluster. Submariner has been tested with and
known to be working properly with the following cloud environments:

{{% notice tip %}}
Are you using Submariner in an environment which is not described here? Please [let us know](../contributing/website) so that we can update
this document.
{{% /notice %}}

### Cloud Providers

* AWS
* VMware vSphere
* OpenStack
* GCP

### Kubernetes CNI Plugins

Presently, Submariner has been tested with the following CNI Plugins that leverage kube-proxy with iptables mode:

* [OpenShift-SDN](https://github.com/openshift/sdn)
* [Weave](https://github.com/weaveworks/weave)
* [Flannel](https://github.com/coreos/flannel)
* [Canal](https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel)
* [Calico](https://www.projectcalico.org/). Please refer to the [following section](../deployment/calico/) for deployment instructions.

## Deployment

The available methods for deployment are:

* [subctl](../deployment)
* [Operator](https://github.com/submariner-io/submariner-operator)
* [Helm](../deployment/helm)

`subctl` greatly simplifies the deployment of Submariner, and is therefore the recommended deployment
method.
