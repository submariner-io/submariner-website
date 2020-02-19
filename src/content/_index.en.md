---
title: "Submariner"
---

# Cross-Cluster Network for Kubernetes
## Submariner

Submariner enables direct networking between pods and services in different Kubernetes clusters, on premises or in the cloud.

Submariner is completely opensource, and it's designed to be network-plugin agnostic and works with most plugins based on kube-proxy ([see compatibility matrix](#)).


{{% notice info %}}
Submariner routes **L3 traffic** in the kernel, *no traffic is handled at user level*, and inter-cluster traffic is encrypted with IPSEC, although more options are being added.
{{% /notice %}}

** add simpler diagram here **

Joining a cluster to an existing submariner broker is as simple as running:

`subctl join --kubeconfig /path/to/your/config broker-info.subm
`

Creating a broker is as simple as running:
	
`subctl deploy-broker --kubeconfig /path/to/your/config`
`

{{% notice tip %}}
See the deployment section for more detailed deployment instructions.
{{% /notice %}}
