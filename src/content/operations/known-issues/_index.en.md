+++
title = "Known Issues"
date = 2020-08-12T16:02:00+02:00
weight = 40
+++

## General

* Minimum supported Kubernetes version is 1.17.
* Submariner only supports kube-proxy in iptables mode. IPVS is not supported at this time.
* CoreDNS is supported out of the box for `*.clusterset.local` service discovery. KubeDNS needs manual configuration. Please refer to the
[GKE Quickstart Guide](../../getting-started/quickstart/managed-kubernetes/gke/#final-workaround-for-kubedns) for more information.
* Clusters deployed with the Calico network plug-in require further configuration to be compatible with Submariner. Please refer to the
[Calico-specific deployment instructions](../deployment/calico/).
* The [Gateway load balancer support](../../getting-started/quickstart/openshift/aws-lb/) is still experimental and needs more testing.

## Globalnet

* Globalnet only supports Pod to remote Service connectivity using Global IPs. Pod to Pod connectivity is not supported at this time.
* Globalnet is not compatible with Headless Services. Only ClusterIP Services are supported at this time.
* Currently, Globalnet is not supported with the OVN network plug-in.
* The `subctl benchmark latency` command is not compatible with Globalnet deployments at this time.
