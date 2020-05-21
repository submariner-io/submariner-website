+++
title = "Quickstart Guide"
date = 2020-02-19T20:03:44+01:00
weight = 5
pre = "<b>1. </b>"
+++

## Basic Overview

Submariner has two main core pieces (the broker and submariner), more information about 
this topic can be found in the [Architecture](../architecture) section.

### The Broker
The broker is an API to which all participating clusters are given access and where two objects are exchanged via CRDs:
* Cluster(.submariner.io): defines a participating cluster and its IP CIDRs.
* Endpoint(.submariner.io): defines a connection endpoint to a Cluster, and the reachable cluster IPs from the endpoint.

The broker must be deployed on a single Kubernetes cluster. This cluster’s API server must be reachable by all Kubernetes clusters connected by Submariner. It can be a dedicated cluster, or one of the connected clusters.

### The Submariner Deployment on a Cluster
Once submariner is deployed on a cluster with the proper credentials to the broker it will exchange Cluster and Endpoint objects with other clusters (via push/pull/watching), and start forming connections and routes to other clusters.


## Prerequisites

Submariner has a few requirements to get started:

- At least **2 Kubernetes** clusters, one of which is designated to serve as the central broker that is accessible by all of your connected clusters; this can be one of your connected clusters, but comes with the limitation that the cluster is required to be up to facilitate interconnectivity/negotiation.

- **Non-overlapping** Service and Pod CIDRs between clusters. This is to prevent routing conflicts. For cases where addresses **do overlap**, [GlobalNet](../architecture/globalnet) can be set up.
<!-- This is not true yet, but eventually will be: (as well as different Kubernetes DNS suffixes).
-->
- **IP reachability between the gateway nodes**. Also, when connecting two clusters, at least one of the clusters should have a publicly routable IP address designated to the gateway node. This is needed for creating the IPsec tunnel between the clusters. The default ports used by IPsec are 4500/UDP and 500/UDP. For clusters behind corporate firewalls that block the default ports, Submariner also supports NAT Traversal (NAT-T) with the option to set custom non-standard ports like 4501/UDP and 501/UDP.

- Knowledge of each cluster's network configuration.

- Worker node IPs on all connected clusters must be outside of the Pods/Service CIDR ranges.

An example of three clusters configured to use with Submariner (without GlobalNet) would look like the following:

| Cluster Name | Provider | Pods CIDR    | Service CIDR | Cluster Nodes CIDR |
|:-------------|:---------|:-------------|:-------------|--------------------|
| broker       | AWS      | 10.42.0.0/16 | 10.43.0.0/16 | 192.168.1.0/24     |
| west         | vSphere  | 10.0.0.0/16  | 10.1.0.0/16  | 192.168.1.0/24     |
| east         | OnPrem   | 10.98.0.0/16 | 10.99.0.0/16 | 192.168.1.0/24     |



## Support Matrix

Submariner is designed to be cloud provider agnostic, and should run in any standard Kubernetes cluster. Submariner has been tested with and known to be working properly with the following cloud environments:

{{% notice tip %}}
Are you using Submariner in an environment which is not described here? Please [let us know](../contributing/website) so that we can update this document. 
{{% /notice %}}

### Cloud Providers

* AWS
* VMware vSphere
* OpenStack
* GCP

### Kubernetes CNI Plugins

Presently, Submariner has been tested with the following CNI Plugins that leverage kube-proxy with iptables mode:

* [openshift-sdn](https://github.com/openshift/sdn)
* [Weave](https://github.com/weaveworks/weave)
* [Flannel](https://github.com/coreos/flannel)
* [Canal](https://docs.projectcalico.org/getting-started/kubernetes/flannel/flannel)


## Deployment

The available methods for deployment are:
* [subctl](../deployment) (+ submariner-operator).
* [helm charts](../deployment/helm).
  
  
The community recommends the use of **_subctl_**, because it simplifies most of the
manual steps required for deployment, as well as verification of connectivity between the clusters. In the _future_ it may provide additional capabilities like:

* Detection of possible conflicts
* Upgrade management
* Status inspection of the deployment
* Configuration updates
* Maintenance and debugs tasks
* Wrapping of logs for support tasks.


To deploy submariner with **subctl** please follow the [deployment](../deployment) guide.
If **helm** fits better your deployment methodologies, please find the details [here](../deployment/helm)
