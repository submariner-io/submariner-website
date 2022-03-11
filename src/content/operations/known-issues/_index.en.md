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
* The [Gateway load balancer support](../../getting-started/quickstart/openshift/gcp-lb/) is still experimental and needs more testing.
* Submariner Gateway metrics `submariner_gateway_rx_bytes` and `submariner_gateway_tx_bytes` will not be collected when using the
VXLAN cable driver.
* Submariner currently only supports IPv4. IPv6 and dual-stack are not supported at this time.
  
## Globalnet

* Currently, Globalnet is not supported with the OVN network plug-in.
* The `subctl benchmark latency` command is not compatible with Globalnet deployments at this time.

## Deploying with Helm on OpenShift

When deploying Submariner using Helm on OpenShift, Submariner needs to be granted the appropriate security context for its service accounts:

```shell
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-routeagent
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-gateway
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-globalnet
```

This is handled automatically in `subctl` and the Submariner addon.
