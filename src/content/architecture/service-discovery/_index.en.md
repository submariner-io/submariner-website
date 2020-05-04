---
title: "Service Discovery"
date: 2020-03-02T21:25:35+01:00
weight: 10
---

The Lighthouse project provides DNS discovery for Kubernetes clusters connected by [Submariner](https://github.com/submariner-io/submariner) in multi-cluster environments. The solution is compatible with any CNI (Container Network Interfaces) plugin.

## Architecture
The below diagram shows the basic Lighthouse architecture.

![Lighthouse Architecture](/images/lighthouse/architecture.png)

### Lighthouse Agent
The Lighthouse Agent runs in every cluster and accesses the Kubernetes API server running in the broker cluster to exchange service metadata information with other clusters. Local service information is exported to the broker and service information from other clusters is imported.

#### WorkFlow
The workflow is as follows:

- Lighthouse agent connects to the broker's K8s API server.
-  For every service in the local cluster, it creates a corresponding MultiClusterService resource and exports it to the broker to be consumed by other clusters.
- For every MultiClusterService resource in the broker exported from another cluster, it creates a copy of it in the local cluster.

![Lighthouse Agent WorkFlow](/images/lighthouse/controllerWorkFlow.png)
<!-- Image Source: /images/lighthouse/source/controllerWorkFlow.vsdx  -->

### Lighthouse Plugin
Lighthouse plugin can be installed as an external plugin for CoreDNS, and will work along with the default Kubernetes plugin. It uses the MultiClusterService resources that are distributed by the controller for DNS resolution. The below diagram indicates a high-level architecture.

![Lighthouse Plugin Architecture](/images/lighthouse/lighthousePluginArchitecture.png)

#### WorkFlow
The workflow is as follows.

- A pod tries to resolve a Service name.
- The Kubernetes plugin in CoreDNS will first try to resolve the request. If no records are present the request will be sent to Lighthouse plugin.
- The Lighthouse plugin will use its MultiClusterService cache to try to resolve the request.
- If a record exists it will be returned, otherwise the plugin will pass the request to the next plugin registered in CoreDNS.

![Lighthouse CoreDNS WorkFlow](/images/lighthouse/coreDNSWorkFlow.png)
<!-- Image Source: /images/lighthouse/source/coreDNSWorkFlow.vsdx -->
