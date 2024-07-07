+++
title = "Role in the Ecosystem"
weight = 50
+++

As cloud-native applications continue to evolve, the open-source ecosystem for multi-cluster networking has changed significantly in recent
years. There are several community projects and emerging technologies addressing various challenges of connecting, securing, and managing
communication between Kubernetes clusters across different environments. Some notable examples include
[Submariner](https://submariner.io/), [Skupper](https://skupper.io/), [Istio](https://istio.io/),
[Calico](https://www.tigera.io/project-calico/community/), and [Cilium](https://cilium.io/). These solutions play a critical role in
enabling scalable and secure multi-cluster deployments.

This page highlights Submariner’s role within the ecosystem and touches on how it compares to some of these other projects.

## Submariner

**Networking Focus**: Submariner is primarily focused on providing network connectivity at layer 3. It establishes tunnels between clusters
to facilitate direct communication between pods and services. Submariner operates at layer 3 of the OSI model, which means it can support
communication for any type of application data or protocol. However, setting up Submariner does require some administrative overhead,
particularly in configuring firewall rules in the underlying infrastructure.

**Service Discovery**: Submariner provides an implementation of the Multi-cluster Services API (MCS API), an initiative within the
Kubernetes ecosystem aimed at standardizing the management of services across multiple Kubernetes clusters, and follows its core principal
of “namespace seamness” whereby Kubernetes namespaces behave consistently and seamlessly across interconnected clusters.

**Use Cases**: It is well-suited for scenarios where you need to create a unified permanent network across geographically distributed
clusters, ensuring seamless pod-to-pod communication and service discovery.

**Connectivity Domain**: Submariner primarily focuses on interconnecting Kubernetes clusters. However, Submariner also provides an
experimental feature that allows access to external applications or endpoints that exist outside of the cluster, in non-Kubernetes
environments. It's important to note that while this [experimental feature](../../getting-started/quickstart/external/) exists, it might not
be as mature or stable as Submariner's core functionalities. Users interested in leveraging Submariner for accessing external applications
should consider testing and evaluating this feature in their specific use cases.

**Integration**: Submariner integrates with various networking solutions and can work alongside existing CNI
(Container Network Interface) plug-ins like Calico, Flannel, etc., ensuring compatibility with different Kubernetes environments.

**Security**: Provides secure communication between clusters using IPsec tunnels by default, which encrypt traffic between clusters.

## Comparison Summary

- **Submariner** focuses on establishing a unified network between Kubernetes clusters, ensuring secure pod-to-pod communication and service
discovery.

- **Skupper** leverages messaging functionalities to facilitate flexible communication across end-points. While Skupper provides support for
linking namespaces across different Kubernetes clusters, it can also be used to support non-Kubernetes environments, including bare-metal,
VMs or services running as Docker or Podman containers. It’s important to note that Skupper utilizes a layer 7-based mechanism for
establishing connectivity. This approach supports selected application protocols today, including HTTP/1.1, HTTP/2, gRPC, and TCP
communication.

- **Istio** provides a robust service mesh with advanced traffic management, policy and security features primarily designed for
intra-cluster communication but can be extended to manage communication across clusters with additional setup.

- Projects like **Calico** and **Cilium**, which integrate with Kubernetes using the Container Network Interface (CNI), require that the
same CNI plug-in is configured consistently across all interconnected clusters for multi-cluster connectivity solutions to work effectively.

Choosing between these solutions would depend on your specific use case requirements regarding network connectivity, service discovery,
security needs, and integration preferences within a multi-cluster environment.
