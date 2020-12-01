+++
title = "Architecture"
date = 2020-02-19T21:00:30+01:00
weight = 5
+++
<!-- markdownlint-disable line-length -->
Submariner connects multiple Kubernetes clusters in a way that is secure and performant. Submariner flattens the networks between the
connected clusters, and enables IP reachability between Pods and Services. Submariner also provides, via Lighthouse, service discovery
capabilities. The service discovery model is built using the proposed
[Kubernetes Multi Cluster Services](https://github.com/kubernetes/enhancements/tree/master/keps/sig-multicluster/1645-multi-cluster-services-api).
<!-- markdownlint-enable line-length -->
Submariner consists of several main components that work in conjunction to securely connect workloads across multiple Kubernetes clusters,
both on-premises and on public clouds:

* [Gateway Engine](./gateway-engine/): manages the secure tunnels to other clusters.
* [Route Agent](./route-agent/): routes cross-cluster traffic from nodes to the active Gateway Engine.
* [Broker](./broker/): facilitates the exchange of metadata between Gateway Engines enabling them to discover one another.
* [Service Discovery](./service-discovery/): provides DNS discovery of Services across clusters.

Submariner has optional components that provide additional functionality:

* [Globalnet Controller](./globalnet/): handles interconnection of clusters with overlapping CIDRs.

The diagram below illustrates the basic architecture of Submariner:

![Submariner Architecture](/images/submariner/architecture.jpg)

### Terminology and Concepts

* `ClusterSet` - a group of two or more clusters with a high degree of mutual trust that share Services among themselves.
Within a cluster set, all namespaces with a given name are considered to be the same namespace.

* `ServiceExport` (CRD) - used to specify which Services should be exposed across all clusters in the cluster set. If multiple clusters
export a Service with the same name and from the same namespace, they will be recognized as a single combined Service.

  * ServiceExports must be explicitly created by the user in each cluster and within the namespace that the underlying Service resides in,
in order to signify that the Service should be visible and discoverable to other clusters in the cluster set. The `ServiceExport` object can
be created manually or via the `subctl export` command.

  * When a `ServiceExport` is created, this will cause the multi-cluster Service to become accessible as
`<service>.<ns>.svc.clusterset.local`.

* `ServiceImport` (CRD) - representation of a multi-cluster Service in each cluster. Created and used internally by Lighthouse and does not
require any user action.
