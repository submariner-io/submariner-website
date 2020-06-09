+++
date = 2020-05-04T16:50:16+02:00
title = "Releases"
pre = "<b>5. </b>"
weight = 25
+++

## v0.4.0 Libreswan cable driver, Kubernetes multicluster service discovery

> This release is mainly focused on the libreswan Submariner cable driver implementation, as well 
> as standardizing the service discovery support in Lighthouse with the upstream
> kubernetes KEP [1].

* The **libreswan** IPsec cable driver is available for testing. It's been included
  on the testing matrix of the project.
* **Lighthouse** has been modified per [1] as follows:
   - A `ServiceExport` object needs to be created alongside any `Service` that is intended to be exported to participant clusters
   - The supercluster services can now be accessed with `<service-name>.<namespace>.svc.supercluster.local`

* **Globanet** overlapping CIDR support improvements and bug fixes

* Multiple **CI** improvements implemented from shipyard

* The testing matrix is now run via [GitHub actions](https://github.com/submariner-io/submariner/actions)

* The submariner-operator now completely handles the Lighthouse deployment via the `ServiceDiscovery` CRD.

* `subctl verify` is now available for `connectivity`, `service-discovery` and `gateway-failover`.


[1] https://github.com/kubernetes/enhancements/tree/master/keps/sig-multicluster/1645-multi-cluster-services-api

## v0.3.0 Lighthouse Service Discovery without KubeFed

> This release is focused on removing the KubeFed dependency from Lighthouse, improving the user experience
> and adding experimental WireGuard support as an alternative to IPsec

* Lighthouse no longer depends KubeFed. All metadata exchange is handled over the Broker as MultiClusterService CRs.
* Experimental **Wireguard** support has been added as a pluggable CableDriver option in addition to the current default IPsec.
* Submariner reports the active and passive gateways as a gateway.submariner.io resource.
* The Submariner Operator reports a detailed status of the deployment.
* The **gateway redundancy/failover** tests are now enabled and stable in CI.
* *Globalnet hostNetwork* to remote globalIP is now supported. Previously, when a pod used hostNetworking it was unable to connect to a remote service via globalIP.
* A globalCIDR can be manually specified when joining a cluster with globalnet enabled. This enables CI speed optimizations via better parallelism.
* Operator and subctl are more robust via standard retries on updates.
* Subctl creates a new **individual access token** for every new joined cluster.


## v0.2.0 Overlapping CIDR support

> This release is focused on overlapping CIDR support between clusters

* Support for Overlapping CIDRs between clusters (globalnet)
* Enhanced e2e scripts, which will be shared between repositories in the shipyard project (ongoing work)
* Improved e2e deployment by using a local registry.
* Refactoring to support pluggable drivers (in preparation for [WireGuard](https://www.wireguard.com/) support)


## v0.1.1 Submariner with more light

> This release has focused on stability for the Lighthouse support

* Cleaner logging for the submariner-engine
* Cleaner logging for the submariner-route-agent
* Fixed issue with wrong token stored in subm file #244
* Added flag to disable the OpenShift CVO #235
* Fixed several service-discovery related bugs #194 , #167
* Fixed several panics on nil network discovery
* Added checks to ensure the CIDRs for joining cluster don't overlap with an existing ones.
* Fix context handling related to service-discovery / kubefed #180
* Use the right CoreDNS image for OpenShift.

## v0.1.0 Submariner with some light

> This release has focused on stability, bugfixes and making https://github.com/submariner.io/lighthouse available as developer preview via subctl deployments.

* Several bugfixes and enhancements around HA failover (#346, #348, #332)
* Migrated to Daemonsets for submariner gateway deployment
* Added support for hostNetwork to remote pod/service connectivity (#288)
* Auto detection and configuration of MTU for vx-submariner, jumbo frames support (#301)
* Support for updated strongswan (#288)
* Better iptables detection for some hosts (#227)

> subctl and the submariner operator have the following improvements

* support to verify-connectivity between two connected clusters
* deployment of submariner gateways based in daemonsets instead of deployments
* renaming submariner pods to "submariner-gateway" pods for clarity
* print version details on crash (subctl)
* stop storing IPSEC key on broker during deploy-broker, now it's only contained into the .subm file
* version command for subctl
* nicer spinners during deployment (thanks to kind)


## v0.0.3 -- KubeCon NA 2019

>Submariner has been greatly enhanced to allow operators to deploy into Kubernetes clusters without the necessity for layer-2 adjacency for nodes. Submariner now allows for VXLAN interconnectivity between nodes (facilitated by the route agent). Subctl
was created to make deployment of submariner easier.

## v0.0.1 Second Submariner release
## v0.0.1 First Submariner release
