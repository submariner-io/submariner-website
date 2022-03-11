+++
date = 2020-08-24T11:35:16+02:00
title = "Releases"
weight = 40
+++

## v0.11.2

This release doesn’t contain any user-facing changes; it fixes internal release issues.

## v0.11.1

This is a bugfix release:

* All exported headless Services are now given a Globalnet ingress IP when Globalnet is enabled ([#1634](https://github.com/submariner-io/submariner/issues/1634)).
* Deployments without Globalnet no longer fail because of an invalid `GlobalCIDR` range ([#1668](https://github.com/submariner-io/submariner-operator/issues/1668)).
* `subctl gather` no longer panics when retrieving some Pod container status information ([#1684](https://github.com/submariner-io/submariner-operator/issues/1684)).

## v0.11.0

This release mainly focused on stability, bug fixes, and improving the integration between Submariner and Open Cluster Management
via the [Submariner addon](https://github.com/open-cluster-management/submariner-addon).

* `subctl cloud prepare` command now supports Google Cloud Platform as well as generic Kubernetes clusters.
* `--ignore-requirements` flag was added to `subctl join` command which ignores Submariner requirements checks.

## v0.10.1

* Inter-connecting clusters with overlapping CIDRs (Globalnet):
  * The initial Globanet implementation is deprecated in favor of a new implementation which is more performant and scalable.
    Globalnet now allows users to explicitly request global IPs at the cluster level, for specific namespaces, or for specific
    Pods. The new Globalnet implementation is not backward-compatible with the initial Globalnet solution and there is no
    upgrade path.
  * Globalnet now supports headless Services.
  * The default `globalnetCIDR` range is changed from 169.254.0.0/16 to 242.0.0.0/8 and each cluster is allocated 64K Global IPs.
  * Globalnet no longer annotates Pods and Services with global IPs but stores this information in `ClusterGlobalEgressIP`,
    `GlobalEgressIP`, and `GlobalIngressIP` resources.
* A new experimental load balancer mode was introduced which is designed to simplify the deployment of Submariner in cloud
  environments where worker nodes do not have access to a dedicated public IP. In this mode, the Submariner Operator creates a
  LoadBalancer Service that exposes both the encapsulation dataplane port as well as the NAT-T discovery port. This mode can be
  enabled by using `subctl join --load-balancer`.
* Submariner now supports inter-cluster connections based on the VXLAN protocol. This is useful in cases where encryption,
  such as with IPsec or WireGuard, is not desired, for example on connections that are already encrypted where the overhead
  of double encryption is not necessary or performant. This can be enabled by setting the `--cable-driver vxlan` option
  during `subctl join`.
* Submariner now supports SRV DNS queries for both ClusterIP and Headless Services. This facilitates Service discovery using
  port name and protocol. For a ClusterIP Service, this resolves to the port number and the domain name. For a Headless Service,
  the name resolves to multiple answers, one for each Pod backing the Service.
* Improved the Submariner integration with the Calico CNI.
* `subctl benchmark latency` and `subctl benchmark throughput` now take a new flag `--kubecontexts` as input instead of
  two kubeconfig files.

## v0.9.1

* The `--kubecontext` flag in `subctl` commands now works properly.
* Simplified `subctl cloud prepare aws` to extract the credentials, infrastructure ID, and region from a local configuration file (if available).
* The `natt-discovery-port` and `udp-port` options can now be set via node annotations.

## v0.9.0

* The gateway Pod has been renamed from `submariner` to `submariner-gateway`.
* The Helm charts now use Submariner's Operator to deploy and manage Submariner.
* Broker creation is now managed by the Operator instead of `subctl`.
* Each Submariner Pod now has its own service account with appropriate privileges.
* The Lighthouse CoreDNS server metrics are now exposed.
* The `submariner_connections` metric is renamed to `submariner_requested_connections`.
* The `service-discovery` flag of `subctl deploy-broker` has been deprecated in favor of the `components` flag.
* For cases in which cross-cluster connectivity is provided without Submariner, `subctl` can now just deploy
  Service Discovery.
* Improved Service CIDR discovery for K3s deployments.
* All Submariner Prometheus metrics are now prefixed with `submariner_`.
* With Globalnet deployments, Global IPs are now assigned to exported Services only. Previously, Globalnet annotated
  every Service in the cluster, whether or not it was exported.
* The name of the CoreDNS custom ConfigMap for service discovery can now be specified on `subctl join`.
* The `strongswan` cable driver that was deprecated in the v0.8.0 release is now removed.
* The Lighthouse-specific API is now removed in favor of [Kubernetes Multicluster Services API](https://github.com/kubernetes-sigs/mcs-api/).
* A new tool, [subctl diagnose](https://submariner.io/operations/deployment/subctl/#diagnose), was added that detects issues with the
  Submariner deployment that may prevent it from working properly.
* `subctl` commands now check if the `subctl` version is compatible with the deployed Submariner version.
* New flags, `repository` and `version`, were added to the `subctl deploy-broker` command.
* New Lighthouse metrics were added that track the number of services imported from and exported to other clusters.
* `subctl show connections` now also shows `average rtt` values.
* A new tool, [subctl gather](https://submariner.io/operations/deployment/subctl/#gather), was added that collects various information
  from clusters to aid in troubleshooting a Submariner deployment.
* Each gateway can now use a different port for IPsec/WireGuard communication via the `gateway.submariner.io/udp-port` node label.
* Gateways now implement a NAT-Traversal (NAT-T) discovery protocol that can be enabled via the `gateway.submariner.io/natt-discovery-port`
  node label.
* A cluster can now be configured in IPsec server mode via the `preferred-server` flag on `subctl join`.

## v0.8.1

* Submariner Gateway Health Check is now supported with Globalnet deployments.
* Support deploying OVN in kind using `make clusters using=ovn` for E2E testing and development environments.
* Support debugging the Libreswan cable driver.
* Fix the cable driver label in the Prometheus latency metrics.
* Support non-TLS connections for OVN databases.
* Services can now be recreated without needing to recreate their associated `ServiceExport` objects.
* Service Discovery no longer depends on Submariner-provided connectivity.
* Improved Service Discovery verification suite.
* The `ServiceImport` object now includes Port information from the original Service.
* `subctl show` now indicates when the target cluster doesn't have Submariner installed.

## v0.8.0

* Added support for connecting clusters that use the OVNKubernetes CNI plugin in non-Globalnet deployments. Support for
  Globalnet will be available in a future release.
* The active Gateway now performs periodic health checks on the connections to remote clusters, updates the Gateway
  connection status, and adds latency statistics.
* Gateways now export the following connection metrics on TCP port 8080 which can be used with Prometheus. These are
  currently only supported for the Libreswan cable driver:
  * The count of bytes transmitted and received between Gateways.
  * The number of connections between Gateways and their corresponding status.
  * The timestamp of the last successful connection established between Gateways.
  * The RTT latency between Gateways.
* The Libreswan cable driver is now the default.
* The strongSwan cable driver is deprecated and will be removed in a future release.
* The Lighthouse DNS always returns the IP address of the local exported ClusterIP Service, if available, otherwise it
  load-balances between the same Services exported from other clusters in a round-robin fashion.
* Lighthouse has fully migrated to use the proposed [Kubernetes Multicluster Services API](https://github.com/kubernetes-sigs/mcs-api/)
  (`ServiceExport` and `ServiceImport`).
  The Lighthouse-specific API is deprecated and will be removed in a future release. On upgrade from v0.7.0, exported
  Services will automatically be migrated to the new CRDs.
* Broker resiliency has been improved. The dataplane is no longer affected in any way if the Broker is unavailable.
* The `subctl` benchmark tests now accept a verbose flag to enable full logging. Otherwise only the results are presented.

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

* Cleaner logging for `submariner-engine`.
* Cleaner logging for `submariner-route-agent`.
* Fixed issue with wrong token stored in `.subm` file ([#244](https://github.com/submariner-io/submariner-operator/issues/244)).
* Added flag to disable the OpenShift CVO ([#235](https://github.com/submariner-io/submariner-operator/issues/235)).
* Fixed several service discovery bugs ([#194](https://github.com/submariner-io/submariner-operator/issues/194), [#167](https://github.com/submariner-io/submariner-operator/issues/167)).
* Fixed several panics on nil network discovery.
* Added checks to ensure the CIDRs for joining cluster don't overlap with existing ones.
* Fix context handling related to service discovery/KubeFed
  ([#180](https://github.com/submariner-io/submariner-operator/issues/180)).
* Use the correct CoreDNS image for OpenShift.

## v0.1.0 Submariner with some light

> This release has focused on stability, bugfixes and making [Lighthouse](https://github.com/submariner-io/lighthouse) available as a
> developer preview via `subctl` deployments.

* Several bugfixes and enhancements around HA failover ([#346](https://github.com/submariner-io/submariner/issues/346),
  [#348](https://github.com/submariner-io/submariner/pull/348),
  [#332](https://github.com/submariner-io/submariner/pull/332)).
* Migrated to DaemonSets for Submariner gateway deployment.
* Added support for hostNetwork to remote Pod/Service connectivity ([#298](https://github.com/submariner-io/submariner/issues/298)).
* Auto detection and configuration of MTU for `vx-submariner`, jumbo frames support
  ([#301](https://github.com/submariner-io/submariner/issues/301)).
* Support for updated strongSwan ([#288](https://github.com/submariner-io/submariner/issues/288)).
* Better iptables detection for some hosts ([#227](https://github.com/submariner-io/submariner/pull/227)).

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
