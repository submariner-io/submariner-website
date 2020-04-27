---
title: "Lighthouse"
date: 2020-03-02T21:25:35+01:00
weight: 10
---

Lighthouse provides DNS discovery for Kubernetes clusters connected by [Submariner](https://github.com/submariner-io/submariner) in multi-cluster environments. The solution is compatible with any CNI (Container Network Interfaces) plugin.

## Architecture
The below digram shows the basic Lighthouse architecture.

![Lighthouse Architecture](/images/lighthouse/architecture.png)

### Lighthouse Agent
The Lighthouse Agent runs in every cluster and it has access to the Kubernetes api-server running in the broker. It creates a lighthouse crd for each service and sync the CRD with broker. It also retrieves the information about services running in another cluster from the broker and creates a lighthouse CRD locally.

The lighthouse agent will get updated, whenever a new lighthouse CRD is created or deleted in the broker.

#### WorkFlow
The workflow is as follows:

- Lighthouse agent connects to the kube-api-server of the broker.
- It creates MultiClusterService CR for every service in the local cluster.
- It syncs the MutltiClusterService CR to and from the broker.

![Lighthouse Controller WorkFlow](/images/lighthouse/controllerWorkFlow.png)
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
