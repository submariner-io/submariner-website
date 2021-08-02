---
title: "Service Discovery"
date: 2020-03-02T21:25:35+01:00
weight: 40
---

The Lighthouse project provides DNS discovery for Kubernetes clusters connected by
[Submariner](https://github.com/submariner-io/submariner) in multi-cluster environments. Lighthouse implements the Kubernetes
[Multi-Cluster Service APIs](https://github.com/kubernetes-sigs/mcs-api).

## Architecture

The below diagram shows the basic Lighthouse architecture:

![Lighthouse Architecture](/images/lighthouse/architecture.png)

### Lighthouse Agent

The Lighthouse Agent runs in every cluster and accesses the Kubernetes API server running in
the Broker cluster to exchange service metadata information with other clusters. Local Service
information is exported to the Broker and Service information from other clusters is imported.

#### Agent Workflow

The workflow is as follows:

- Lighthouse Agent connects to the Broker's Kubernetes API server.
- For every Service in the local cluster for which a ServiceExport has been created, the Agent creates a corresponding
ServiceImport resource and exports it to the Broker to be consumed by other clusters.
- For every ServiceImport resource in the Broker exported from another cluster,
it creates a copy of it in the local cluster.

![Lighthouse Agent WorkFlow](/images/lighthouse/controllerWorkFlow.png)
<!-- Image Source: /images/lighthouse/source/controllerWorkFlow.vsdx  -->

### Lighthouse DNS Server

The Lighthouse DNS server runs as an external DNS server which owns the domain `clusterset.local`.
CoreDNS is configured to forward any request sent to `clusterset.local` to the Lighthouse DNS server,
which uses the ServiceImport resources that are distributed by the controller for DNS resolution. The
Lighthouse DNS server supports queries using an A record and an SRV record.

{{% notice note %}}
When a single Service is deployed to multiple clusters, Lighthouse DNS server prefers the local cluster first before routing the traffic to
other remote clusters in a round-robin fashion.
{{% /notice %}}

#### Server Workflow

The workflow is as follows:

- A Pod tries to resolve a Service name using the domain name `clusterset.local`.
- CoreDNS forwards the request to the Lighthouse DNS server.
- The Lighthouse DNS server will use its ServiceImport cache to try to resolve the request.
- If a record exists it will be returned, else an NXDomain error will be returned.

![Lighthouse CoreDNS WorkFlow](/images/lighthouse/coreDNSWorkFlow.png)
<!-- Image Source: /images/lighthouse/source/coreDNSWorkFlow.vsdx -->
