---
title: "Service Discovery"
date: 2020-03-02T21:25:35+01:00
weight: 5
---

The Lighthouse project provides DNS discovery for Kubernetes clusters connected by
[Submariner](https://github.com/submariner-io/submariner) in multi-cluster environments.

## Architecture

The below diagram shows the basic Lighthouse architecture.

![Lighthouse Architecture](/images/lighthouse/architecture.png)

### Lighthouse Agent

The Lighthouse Agent runs in every cluster and accesses the Kubernetes API server running in
the broker cluster to exchange service metadata information with other clusters. Local service
information is exported to the broker and service information from other clusters is imported.

#### Agent Workflow

The workflow is as follows:

- Lighthouse agent connects to the broker's K8s API server.
- For every Service in the local cluster for which a ServiceExport has been created, the agent creates a corresponding
ServiceImport resource and exports it to the broker to be consumed by other clusters.
- For every ServiceImport resource in the broker exported from another cluster,
it creates a copy of it in the local cluster.

![Lighthouse Agent WorkFlow](/images/lighthouse/controllerWorkFlow.png)
<!-- Image Source: /images/lighthouse/source/controllerWorkFlow.vsdx  -->

### Lighthouse DNS Server

The Lighthouse DNS server runs as an external DNS server which owns the domain clusterset.local.
KubeDNS is configured to forward any request sent to clusterset.local to the Lighthouse DNS server,
which uses the ServiceImport resources that are distributed by the controller for DNS resolution. The
Lighthouse DNS server uses a round robin algorithm for IP selection to distribute the load evenly across the clusters.

#### Server Workflow

The workflow is as follows.

- A Pod tries to resolve a Service name using the domain name clusterset.local
- KubeDNS forwards the request to the Lighthouse DNS server.
- The Lighthouse DNS server will use its ServiceImport cache to try to resolve the request.
- If a record exists it will be returned, else an NXDomain error will be returned.

![Lighthouse CoreDNS WorkFlow](/images/lighthouse/coreDNSWorkFlow.png)
<!-- Image Source: /images/lighthouse/source/coreDNSWorkFlow.vsdx -->
