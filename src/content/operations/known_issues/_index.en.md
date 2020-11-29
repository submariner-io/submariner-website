+++
title = "Known Issues"
date = 2020-08-12T16:02:00+02:00
weight = 50
+++

## General

* Minimum supported Kubernetes version is 1.17.
* Submariner only supports kube-proxy in iptables mode. IPVS is not supported at this time.
* Clusters deployed with the Calico network plug-in require further configuration to be compatible with Submariner. Please refer to the
[Calico-specific deployment instructions](../deployment/calico/).

## Globalnet

* Globalnet only supports Pod to remote Service connectivity using Global IPs. Pod to Pod connectivity is not supported at this time.
* Globalnet is not compatible with headless Services. Only ClusterIP Services are supported at this time.
* Globalnet annotates every Service in a cluster, whether or not it was exported.
