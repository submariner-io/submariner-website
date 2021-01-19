---
title: "Network Plugin Syncer"
---

The Network Plugin Syncer provides a framework for components to interface
with the configured Kubernetes Container Network Interface (CNI) plugin to
perform any API/database tasks necessary to facilitate routing cross-cluster
traffic, like creating API objects that the CNI plugin will process or
working with the specific CNI databases.

The detected CNI plugin implementation configured for the cluster
is received by the Network Plugin Syncer, and executes
the appropriate plugin handler component, if any.

The following table highlights the differences with the
[Route Agent](../route-agent/):

<!-- markdownlint-disable line-length -->
|                                                   |Route Agent|Network Plugin Syncer  |
|:---                                               |:---       |:---                   |
| Configures the CNI plugin                         |           |            x          |
| Configures low level network elements on the host |     x     |                       |
| Runs as a Kubernetes Deployment                   |           |            x          |
| Runs as a Kubernetes Daemonset on every host      |     x     |                       |
<!-- markdownlint-enable line-length -->

{{% notice info %}}
This component is only necessary for specific Kubernetes CNI plugins
like [OVN Kubernetes](./ovn-kubernetes/).
{{% /notice %}}
