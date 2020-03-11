---
title: "Lighthouse"
date: 2020-03-02T21:25:35+01:00
weight: 10
---

Lighthouse provides DNS discovery for Kubernetes clusters connected by [Submariner](https://github.com/submariner-io/submariner) in multi-cluster environments. The solution is compatible with any CNI (Container Network Interfaces) plugin.

## Architecture
The below digram shows the basic Lighthouse architecture.

![Lighthouse Architecture](/images/lighthouse/architecture.png)

### Lighthouse Controller
This is the central discovery controller that gathers the information from the clusters, decides what information is to be shared and distributes the information as newly defined CRDs (Kubernetes custom resources).

The Lighthouse controller uses [kubefed](https://github.com/kubernetes-sigs/kubefed) to discover clusters and to extract and distribute aggregated Service information used to perform DNS resolution.

#### WorkFlow
The workflow is as follows.

- Lighthouse controller registers to be notified when clusters join and unjoin the kubefed control plane.
- When notified about a join event, it retrieves the credentials from kubefed and registers a watch for Service creation and removal on that cluster.
- When notified of a new Service created, it creates a MultiClusterService resource with the Service info and distributes it to all the clusters that are connected to the kubefed  control plane.
- When notified of a Service deleted, its info is removed from the MultiClusterService resource and re-distributed.
- The controller distributes the CRD to all the clusters that have joined.

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
