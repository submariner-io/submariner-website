+++
date = 2020-08-24T11:35:16+02:00
title = "Releases"
pre = "<b>6. </b>"
weight = 30
+++

## v0.7.0 StatefulSet support for service discovery and benchmark tooling

> This release mainly focused on adding support for StatefulSets in Lighthouse for service discovery and adding new `subctl`
> commands to benchmark the network performance across clusters.

* Lighthouse enhancements/changes:
  * Added support for accessing individual Pods in a StatefulSet using their host names.
  * A Service in a specific cluster can now be explicitly queried.
  * Removed support for the `supercluster.local` domain to align with the Kubernetes MultiCluster Service API.
* Added new `subctl` benchmark commands for measuring the throughput and round trip latency between two Pods in separate
  clusters or within the same cluster.
* The data path is no longer disrupted when the Globalnet Pod is restarted.
* The Route Agent component now runs on all worker nodes including those with taints.

When upgrading to 0.7.0 on a cluster already running Submariner, the current state must be cleared:

* Remove the Submariner namespaces: `kubectl delete ns submariner-operator submariner-k8s-broker`
* Remove the Submariner cluster roles: `kubectl delete clusterroles submariner-lighthouse submariner-operator submariner-operator:globalnet`

## v0.6.0 Improved Submariner High Availability and various Lighthouse enhancements

> This release mainly focused on support for headless Services in Lighthouse,
> as well as improving Submariner's High Availability (HA).

{{% notice warning %}}
  The DNS domains have been updated from `<service>.<namespace>.svc.supercluster.local` to
  `<service>.<namespace>.svc.clusterset.local` to **align with the change in Kubernetes Multicluster Service API**.
  Both domains will be supported for 0.6.0 but **0.7.0 will remove support for `supercluster.local`**.
  Please update your deployments and applications.
{{% /notice %}}

* Lighthouse has been enhanced to:
  * Be aware of the local cluster Gateway connectivity so as not to announce the IP addresses for disconnected remote clusters.
  * Support **headless Services** for non-Globalnet deployments. Support for Globalnet will be available in a future release.
  * Be aware of a Service's backend Pods so as not to announce IP addresses for Services that have no active Pods.
  * Use Round Robin IP resolution for Services available in multiple clusters.
  * Enable service discovery by default for `subctl` deployments.
* `subctl` auto-detects the cluster ID from the `kubeconfig` file's information when possible.
* Submariner's Pods now shut down gracefully and do proper cleanup which **reduces downtime** during Gateway failover.
* The Operator now automatically exports **Prometheus metrics**; these integrate seamlessly with OpenShift Prometheus if user
  workload monitoring is enabled, and can be included in any other Prometheus setup.
* Minimum Kubernetes version is now 1.17.
* HostNetwork to remote Service connectivity [fixes for AWS clusters](https://github.com/submariner-io/submariner/issues/736).
* The project's codebase quality and readability has been improved using various linters.

## v0.5.0 Lighthouse service discovery alignment

> This release mainly focused on continuing the alignment of Lighthouse's service discovery support with the [Kubernetes Multicluster
> Services KEP][MCS KEP].

* Lighthouse has been modified per the **[Kubernetes Multicluster Services KEP][MCS KEP]** as follows:
  * The `MultiClusterService` resource has been replaced by `ServiceImport`.
  * The `ServiceExport` resource is now updated with status information as lifecycle events occur.
* Lighthouse now allows a `ServiceExport` resource to be created prior to the associated `Service`.
* **Network discovery** was moved from `subctl` to the Submariner Operator.
* Several **new commands** were added to `subctl`: `export service`, `show versions`, `show connections`, `show networks`,
  `show endpoints`, and `show gateways`.
* The `subctl info` command has been removed in lieu of the new `show networks` command.
* The Globalnet configuration has been moved from the `broker-info.subm` file to a `ConfigMap` resource stored on the
  Broker cluster. Therefore, the new `subctl` cannot be used on brownfield Globalnet deployments where this information
  was stored as part of `broker-info.subm`.
* `subctl` now supports **joining multiple clusters in parallel** without having to explicitly specify the `globalnet-cidr` for the
  cluster to work around this issue. The `globalnet-cidr` will automatically be allocated by `subctl` for each cluster.
* The separate `--operator-image` parameter has been removed from `subctl join` and the `--repository` and `--version`
  parameters are now used for all images.
* The Submariner Operator status now includes `Gateway` information.
* Closed technical requirements for Submariner to become a **CNCF project**, including _Developer Certificate of Origin_ compliance
  and additional source code linting.

## v0.4.0 Libreswan cable driver, Kubernetes multicluster service discovery

> This release is mainly focused on Submariner's Libreswan cable driver implementation, as well
> as standardizing Lighthouse's service discovery support with the [Kubernetes Multicluster
> Services KEP][MCS KEP].

* **Libreswan IPsec cable driver** is available for testing and is covered in Submariner's CI.
* Lighthouse has been modified per the **[Kubernetes Multicluster Services KEP][MCS KEP]** as follows:
  * A `ServiceExport` object needs to be created alongside any `Service` that is intended to be
    exported to participant clusters.
  * Supercluster services can be accessed with `<service-name>.<namespace>.svc.clusterset.local`.
* Globalnet **overlapping CIDR** support improvements and bug fixes.
* Multiple **CI** improvements implemented from Shipyard.
* CI tests are now run via **[GitHub Actions](https://github.com/submariner-io/submariner/actions)**.
* Submariner's Operator now completely handles the **Lighthouse deployment** via the `ServiceDiscovery` CRD.
* `subctl verify` is now available for `connectivity`, `service-discovery` and `gateway-failover`.

[MCS KEP]: https://github.com/kubernetes/enhancements/tree/master/keps/sig-multicluster/1645-multi-cluster-services-api

## v0.3.0 Lighthouse Service Discovery without KubeFed

> This release is focused on removing the KubeFed dependency from Lighthouse, improving the user experience,
> and adding experimental WireGuard support as an alternative to IPsec.

* Lighthouse **no longer depends on KubeFed**. All metadata exchange is handled over the Broker as `MultiClusterService` CRs.
* Experimental **WireGuard** support has been added as a pluggable `CableDriver` option in addition to the current default IPsec.
* Submariner reports the active and passive gateways as a `gateway.submariner.io` resource.
* The Submariner Operator reports a detailed status of the deployment.
* The **gateway redundancy/failover** tests are now enabled and stable in CI.
* Globalnet **hostNetwork to remote globalIP** is now supported. Previously, when a Pod used hostNetworking it was unable to connect to a
  remote Service via globalIP.
* A GlobalCIDR can be manually specified when joining a cluster with Globalnet enabled. This enables CI speed optimizations via better
  parallelism.
* Operator and `subctl` are more robust via standard retries on updates.
* `subctl` creates a new **individual access token** for every new joined cluster.

## v0.2.0 Overlapping CIDR support

> This release is focused on overlapping CIDR support between clusters.

* **Support for overlapping CIDRs** between clusters (Globalnet).
* Enhanced end-to-end scripts, which will be shared between repositories in the Shipyard project (ongoing work).
* Improved end-to-end deployment by using a local registry.
* Refactoring to **support pluggable drivers** (in preparation for [WireGuard](https://www.wireguard.com/) support).

## v0.1.1 Submariner with more light

> This release is focused on stability for Lighthouse.

* Cleaner logging for submariner-engine.
* Cleaner logging for submariner-route-agent.
* Fixed issue with wrong token stored in `.subm` file ([submariner-operator#244](https://github.com/submariner-io/submariner-operator/issues/244)).
* Added flag to disable the OpenShift CVO ([submariner-operator#235](https://github.com/submariner-io/submariner-operator/issues/235)).
* Fixed several service discovery bugs ([submariner-operator#194](https://github.com/submariner-io/submariner-operator/issues/194), [submariner-operator#167](https://github.com/submariner-io/submariner-operator/issues/167)).
* Fixed several panics on nil network discovery.
* Added checks to ensure the CIDRs for joining cluster don't overlap with existing ones.
* Fix context handling related to service discovery/KubeFed
  ([submariner-operator#180](https://github.com/submariner-io/submariner-operator/issues/180)).
* Use the correct CoreDNS image for OpenShift.

## v0.1.0 Submariner with some light

> This release has focused on stability, bugfixes and making [Lighthouse](https://github.com/submariner-io/lighthouse) available as a
> developer preview via `subctl` deployments.

* Several bugfixes and enhancements around HA failover ([submariner#346](https://github.com/submariner-io/submariner/issues/346),
  [submariner#348](https://github.com/submariner-io/submariner/pull/348),
  [submariner#332](https://github.com/submariner-io/submariner/pull/332)).
* Migrated to DaemonSets for Submariner gateway deployment.
* Added support for hostNetwork to remote Pod/Service connectivity ([submariner#298](https://github.com/submariner-io/submariner/issues/298)).
* Auto detection and configuration of MTU for vx-submariner, jumbo frames support
  ([submariner#301](https://github.com/submariner-io/submariner/issues/301)).
* Support for updated strongSwan ([submariner#288](https://github.com/submariner-io/submariner/issues/288)).
* Better iptables detection for some hosts ([submariner#227](https://github.com/submariner-io/submariner/pull/227)).

> `subctl` and the Submariner Operator have the following improvements:

* Support for `verify-connectivity` checks between two connected clusters.
* Deployment of Submariner gateways based on `DaemonSet` instead of `Deployment`.
* Rename `submariner` Pods to `submariner-gateway` Pods for clarity.
* Print version details on crash (`subctl`).
* Stop storing IPsec key on Broker during `deploy-broker`, now it's only contained into the `.subm` file.
* Version command for `subctl`.
* Nicer spinners during deployment (thanks to kind).

## v0.0.3 -- KubeCon NA 2019

Submariner has been greatly enhanced to allow administrators to deploy into Kubernetes clusters without the necessity for Layer 2 adjacency
for nodes. Submariner now allows for VXLAN interconnectivity between nodes (facilitated by the route agent). `subctl` was created to make
deployment of Submariner easier.

## v0.0.2 Second Submariner release

## v0.0.1 First Submariner release
