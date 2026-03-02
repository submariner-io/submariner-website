+++
title = "Known Issues"
date = 2020-08-12T16:02:00+02:00
weight = 40
+++

## General

* The oldest Kubernetes version for which Submariner is known to work is 1.19 (1.21 for Service Discovery).
* Submariner only supports kube-proxy in iptables mode. IPVS is not supported at this time.
* CoreDNS is supported out of the box for `*.clusterset.local` service discovery. KubeDNS needs manual configuration. Please refer to the
[GKE Quickstart Guide](../../getting-started/quickstart/managed-kubernetes/gke/#final-workaround-for-kubedns) for more information.
* Clusters deployed with the Calico network plug-in require further configuration to be compatible with Submariner. Please refer to the
[Calico-specific deployment instructions](../deployment/calico/).
* The [Gateway load balancer support](../../getting-started/quickstart/openshift/gcp-lb/) is still experimental and needs more testing.
* Submariner Gateway metrics `submariner_gateway_rx_bytes` and `submariner_gateway_tx_bytes` will not be collected when using the
VXLAN cable driver.
* Submariner does not support IPv6-only setups. On dual-stack setups, it only allocates IPv4 addresses.
* In OpenShift 4.18 with OVNK, the source IP is not retained when packet reaches the destination pod.
This may affect applications relying on source IP, like NetworkPolicy.

## Globalnet

* The `subctl benchmark latency` command is not compatible with Globalnet deployments at this time.

## Deploying with Helm on OpenShift

When deploying Submariner using Helm on OpenShift, Submariner needs to be granted the appropriate security context for its service accounts:

```shell
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-routeagent
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-gateway
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-globalnet
```

This is handled automatically in `subctl` and the Submariner addon.

## AWS EKS with AWS VPC CNI: Intermittent Connectivity on Secondary ENIs

When using Submariner on AWS EKS with the default AWS VPC CNI configuration, pods assigned to secondary Elastic Network Interfaces (ENIs)
may experience cross-cluster connectivity loss.

The AWS VPC CNI for pods on secondary ENIs creates IP rules that force traffic into a custom routing table instead of the main table.
Currently, the Submariner route-agent only populates the main routing table. Consequently, these custom tables lack the routes to the
`vx-submariner` interface, and traffic is instead sent to the default VPC gateway (black-holed).

You can manually replicate the Submariner routes from the main table into the custom tables created by the CNI. For example,
if your pod is using table 2:

```shell
sudo ip route add <remote-cluster-cidr> via <submariner-gw-ip> dev vx-submariner table 2
sudo ip route add <submariner-internal-cidr> dev vx-submariner table 2
```
