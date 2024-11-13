+++
date = 2020-08-24T11:35:16+02:00
title = "Releases"
weight = 40
+++
<!-- markdownlint-disable no-duplicate-header -->

## v0.20.0

### New features

### Other changes

* Enhanced the Flannel network discovery logic to improve performance and reliability.

## v0.18.2 (October 30, 2024)

* Fixed an issue with Service Discovery that caused a new `EndpointSlice` to be created when the labels on the exporting `Service`
  were updated.
* New options were added to `subctl cloud prepare` to support a custom vpc for AWS.

## v0.19.0 (October 25, 2024)

### New features

* Service Discovery now propagates the session affinity information from the exported service to the aggregated `ServiceImport`.
* Service Discovery can now allocate a cluster set virtual IP for exported services. This is an opt-in feature that can be enabled
  per service via the `lighthouse.submariner.io/use-clusterset-ip` annotation on the `ServiceExport` or automatically for all services via
  the `enable-clusterset-ip` option on `subctl deploy-broker`. Note that while DNS queries will return the cluster set virtual IP,
  Service Discovery does not route this virtual IP and relies on some external component to do so.
* Each Route Agent now monitors the connectivity to each remote cluster's gateway using ICMP and the health of each connection is
  reported by `subctl diagnose`.
* New options were added to `subctl cloud prepare` to support a custom vpc for AWS.
* Submariner can now be deployed on Kubernetes KubeVirt clusters.

### Other changes

* Fixed an issue with Service Discovery that caused significant latencies when exporting a large number of service.
* Fixed an issue which could cause the wrong pod CIDR to be discovered on join.
* The Service Discovery CoreDNS ClusterIP service now also defines a TCP port to support TCP retries after truncation per
  RFC1035 and RFC2181.
* Fixed an issue with Calico wrongly overwriting static routes added by RouteAgent.
* Fixed an issue with detecting Calico CNI interface after node reboot.
* Fixed an issue with Service Discovery that caused a new `EndpointSlice` to be created when the labels on the exporting `Service`
  were updated.

## v0.17.3 (October 9, 2024)

* Fixed an issue with Service Discovery that caused significant latencies when exporting a large number of service.
* Fixed an issue with Calico wrongly overwriting static routes added by RouteAgent.
* Fixed an issue with detecting Calico CNI interface after node reboot.
* The Service Discovery CoreDNS ClusterIP service now also defines a TCP port to support TCP retries after truncation per
  RFC1035 and RFC2181.
* Fixed an issue with Service Discovery that caused a new `EndpointSlice` to be created when the labels on the exporting `Service`
  were updated.
* New options were added to `subctl cloud prepare` to support a custom vpc for AWS.

## v0.18.1 (October 7, 2024)

* Fixed an issue with Service Discovery that caused significant latencies when exporting a large number of service.
* Fixed an issue which could cause the wrong pod CIDR to be discovered on join.
* Fixed an issue with Calico wrongly overwriting static routes added by RouteAgent.
* Fixed an issue with detecting Calico CNI interface after node reboot.
* The Service Discovery CoreDNS ClusterIP service now also defines a TCP port to support TCP retries after truncation per
  RFC1035 and RFC2181.

## v0.14.9 (July 26, 2024)

* Reduced and restricted the RBAC permissions for the various Submariner components to only what is actually needed to reduce any
  potential attack surface.

**Note**: this version replaces v0.14.8.

## v0.15.5 (July 23, 2024)

* Reduced and restricted the RBAC permissions for the various Submariner components to only what is actually needed to reduce any
  potential attack surface.

**Note**: this version replaces v0.15.4.

## v0.18.0 (July 4, 2024)

### New features

* `subctl join` and other commands now support HTTP proxy arguments corresponding to the HTTP proxy environment variables
   that are propagated to the various pods.
* `subctl verify` now outputs a short description of each test that is run.

### Other changes

* Fixed an issue in Service Discovery where un-exporting a Service on one cluster and then quickly exporting it on another cluster could
  result in a missing `ServiceImport` resource and cause name resolution failures.
* Reduced and restricted the RBAC permissions for the various Submariner components to only what is actually needed to reduce any
  potential attack surface.
* Improved the performance of Service Discovery exporting at scale which was hindered by excessive throttling delays when exporting many
  services quickly.
* To reduce RBAC permissions, Submariner no longer annotates Node resources. After upgrade, any `submariner.io/*`
  annotations will not be removed because Submariner no longer has Node update permission.
* Health check counters on the Gateway resource now report correct information after a gateway leader re-election occurs.
* AWS cloud prepare now supports the resource naming convention implemented in Openshift 4.16 and above.

## v0.17.2 (June 26, 2024)

* Improved the performance of Service Discovery exporting at scale which was hindered by excessive throttling delays when exporting many
  services quickly.
* Reduced and restricted the RBAC permissions for the various Submariner components to only what is actually needed to reduce any
  potential attack surface.
* Health check counters on the Gateway resource now report correct information after a gateway leader re-election occurs.
* AWS cloud prepare now supports the resource naming convention implemented in Openshift 4.16 and above.

## v0.16.7 (June 17, 2024)

* Fixed an issue in Service Discovery where un-exporting a Service on one cluster and then quickly exporting it on another cluster could
  result in a missing `ServiceImport` resource and cause name resolution failures.
* Reduced and restricted the RBAC permissions for the various Submariner components to only what is actually needed to reduce any
  potential attack surface.
* Health check counters on the Gateway resource now report correct information after a gateway leader re-election occurs.

**Note**: this version replaces v0.16.4, v0.16.5, v0.16.6.

## v0.17.1 (April 17, 2024)

* Fixed an issue in Service Discovery where un-exporting a Service on one cluster and then quickly exporting it on another cluster could
  result in a missing `ServiceImport` resource and cause name resolution failures.

## v0.17.0 (February 26, 2024)

### New features

* The new `--only basic-connectivity` option on `subctl verify` runs a smaller set of connectivity tests as a quick sanity check when
  time is a constraint.
* The `deploy-broker`, `recover-broker-info`, and `join` sub-commands have a `--broker-url` option which can be used to override the
  broker URL (which is usually derived from the context used to access the broker, or stored in the `broker-info.subm` file).
* `subctl join` now ensures the local cluster ID is unique with respect to existing joined clusters to avoid issues with duplicate IDs.
* `subctl verify` has a new flag, `--extracontext`, to specify the context for a third cluster that is required for some Service Discovery
  tests.

### Other changes

* The Globalnet controller now employs Kubernetes leader election to ensure proper continuity during fail-over and avoid potential race
  conditions.
* Globalnet now handles port updates for exported services.
* Removed the `dedicated-gateway` flag from `subctl cloud prepare` that was previously deprecated in v0.15.0. To deploy without dedicated
  gateways, use the Load Balancer mode instead.
* Removed the `generic` option from `subctl cloud prepare` that was previously deprecated in v0.15.0. To label gateway nodes, use
  `subctl join` instead.
* Fixed an issue in Service Discovery where stale endpoint IPs, corresponding to services that no longer exist, were returned from DNS
  queries.
* Fixed an issue in Service Discovery which caused an erroneous ServiceExport Conflict status condition to be reported.
* The Gateway leader election was enhanced to not restart the pod when leadership is lost to avoid possible data path disruptions.
* Fixed a crash in the Submariner Operator pod due to a concurrent map write.
* Fixed an issue with Service Discovery where, after disaster recovery of the broker cluster, some DNS queries could fail requiring a
  restart of the CoreDNS server pod.
* Fixed an issue with the OVN-Kubernetes CNI where, after a cluster recovery, the data path was broken requiring manual deletion of
  stale GatewayRoute and NonGatewayRoute resources and a restart of the Route Agent pod.
* The script to download the `subctl` binary now correctly handles the Linux aarch64 architecture.

## v0.16.3 (January 11, 2024)

* Fixed an issue in Service Discovery which caused an erroneous ServiceExport Conflict status condition to be reported.
* Fixed an issue with Service Discovery where, after disaster recovery of the broker cluster, some DNS queries could fail requiring a
  restart of the CoreDNS server pod.
* Fixed an issue with the OVN-Kubernetes CNI where, after a cluster recovery, the data path was broken requiring manual deletion of
  stale GatewayRoute and NonGatewayRoute resources and a restart of the Route Agent pod.
* Fixed a crash in the Submariner Operator pod due to a concurrent map write.

## v0.16.2 (November 7, 2023)

* The Globalnet controller now employs Kubernetes leader election to ensure proper continuity during fail-over and avoid potential race
  conditions.
* The Gateway leader election was enhanced to not restart the pod when leadership is lost to avoid possible data path disruption.
* Fixed an issue in Service Discovery where stale endpoint IPs, corresponding to services that no longer exist, were returned from DNS
  queries.
* Sockets from the host are mounted through their parent directory, which ensures that the sockets themselves aren't replaced by directories
  (which prevents OVN components from starting). Additionally, stray directories are cleaned up at startup. This fixes the known issue with
  upgrades involving OVN, as documented in the known issues section for v0.16.0

**Note**: this version replaces v0.16.1.

## v0.15.3 (November 3, 2023)

* The `subctl diagnose` command has been enhanced to check for potential firewall issues that may be blocking ESP traffic
  and will provide an appropriate error message.
* Submariner now explicitly enables forwarding on the interfaces that it creates to support forwarding even when
  global forwarding on the node is turned off.
* Enhanced Calico CNI detection now includes searching for calico-node CNI pods when the calico-config map is
  not detected.
* Submariner now explicitly configures dpddelay when initiating IPsec connections to prevent excessively frequent
  liveness probes.
* Service Discovery will now publish DNS records for pods that are not ready based on the setting of the `publishNotReadyAddresses`
  flag on the service.
* The CNI detection method in Submariner Operator is now improved to detect the Flannel CNI, even when the Flannel configMap
  is missing from the cluster.
* Submariner now ensures that the IPsec control socket is created before initiating connection requests, and also
  automatically retries connections in response to errors reported by the 'whack' command.
* The pod CIDR detection logic now ensures that the node's `podCIDR` is exclusively used for single-node deployments.
* The Submariner gateway now retries reading local node information on startup to reduce pod restarts if the Kubernetes API server is
  temporarily unavailable.
* Reduced data path downtime with Libreswan cable driver when gateway pod restarts.

## v0.14.7 (October 17, 2023)

* Submariner now explicitly enables forwarding on the interfaces that it creates to support forwarding even
  when global forwarding on the node is turned off.
* Submariner now ensures that the IPsec control socket is created before initiating connection requests, and also
  automatically retries connections in response to errors reported by the 'whack' command.
* The Submariner gateway now retries reading local node information on startup to reduce pod restarts if the Kubernetes API server is
  temporarily unavailable.
* Reduced data path downtime with Libreswan cable driver when gateway pod restarts.

## v0.16.0 (October 2, 2023)

### New features

* The `subctl cloud prepare azure` command has a new flag, `air-gapped`, to indicate the cluster is in an air-gapped
  environment which may forbid certain configurations in a disconnected Azure installation.
* `subctl` is now built for ARM Macs (Darwin arm64).
* `subctl show versions` now shows the version of the metrics proxy component.
* The `subctl gather` command now collects metrics proxy pod logs in Globalnet deployments.
* For headless services, Service Discovery now derives its `EndpointSlices` from the Kubernetes `EndpointSlices` so for each
  Kubernetes `EndpointSlice` there will be a corresponding Service Discovery `EndpointSlice`.  Service Discovery `EndpointSlices`
  follow the same naming convention in that the names are auto-generated by Kubernetes prefixed by the service name.
  Endpoints for all conditions are now included - prior releases only published ready endpoints.
* Service Discovery will now publish DNS records for pods that are not ready based on the setting of the `publishNotReadyAddresses`
  flag on the service.
* Service Discovery now propagates labels from an exported `Service` to its generated `EndpointSlices`.
* The new `subctl upgrade` command can upgrade `subctl` itself in-place, and upgrade Submariner deployments on brokers
  and joined clusters to the corresponding version of Submariner.
* The `subctl diagnose` command has been enhanced to check for potential firewall issues that may be blocking ESP traffic
  and will provide an appropriate error message.
* Submariner now explicitly enables forwarding on the interfaces that it creates to support forwarding even when
  global forwarding on the node is turned off.

### Other changes

* Reduced data path downtime with Libreswan cable driver when gateway pod restarts.
* Fixed an issue with OVNKubernetes CNI where routes could be accidentally deleted during cluster restart, or
  upgrade scenarios.
* Submariner gateway pods now skip invoking cable engine cleanup during termination, as this is handled by the route agent
  during gateway migration.
* The status condition type "Allocated" for Globalnet resources now adheres to the intended design of status conditions in
  Kubernetes by reflecting only the latest observed status.
* Fixed issue which caused the IPsec pluto process to crash when the remote endpoint was unstable.
* Submariner now explicitly configures dpddelay when initiating IPsec connections to prevent excessively frequent
  liveness probes.
* Submariner now uses case-insensitive comparison while parsing CNI names.
* Enhanced Calico CNI detection now includes searching for calico-node CNI pods when the calico-config map is not detected.
* Submariner now automatically creates the necessary Calico IPPools for remote cluster connectivity when the Calico API Server is
  installed in the cluster.
* Fixed an issue with Service Discovery with Globalnet enabled where a service was inaccessible after recreating it.
* Fixed an issue with Service Discovery where a remote cluster's service was inaccessible after recreating its local namespace.
* Service Discovery with Globalnet enabled now correctly handles headless services without a selector.
* The pod CIDR detection logic now ensures that the node's `podCIDR` is exclusively used for single-node deployments.
* `subctl verify` no longer requires the KUBECONFIG environment variable to be set.
* The `submariner_service_export` metric is now properly exposed after being inadvertently removed.
* The Globalnet component now handles out-of-order remote endpoint notifications properly.
* The Submariner gateway now retries reading local node information on startup to reduce pod restarts if the Kubernetes API server is
  temporarily unavailable.
* Submariner now ensures that the IPsec control socket is created before initiating connection requests, and also
  automatically retries connections in response to errors reported by the 'whack' command.
* The CNI detection method in Submariner Operator is now improved to detect the Flannel CNI, even when the Flannel configMap
  is missing from the cluster.

### Known issues

* Upgrades involving OVN can fail because one of the OVN sockets is replaced by a directory.
  To bring affected nodes up successfully, all invalid sockets on each node must be removed: `find /run -type d -name '*.sock' -delete`.
  v0.16.0 includes a partial fix for this: route agents wait for node readiness before starting,
  which allows OVN to finish initializing.
  In some scenarios however, an invalid directory is created before OVN is upgraded, which prevents OVN from starting up correctly.
  This will be fixed fully in v0.16.1.

## v0.14.6 (July 5, 2023)

* The `subctl cloud prepare azure` command has a new flag, `air-gapped`, to indicate the cluster is in an air-gapped
  environment which may forbid certain configurations in a disconnected Azure installation.
* The Globalnet component now handles out-of-order remote endpoint notifications properly.
* `subctl` is now built for ARM Macs (Darwin arm64).
* Fixed an issue with OVNKubernetes CNI where routes could be accidentally deleted during cluster restart, or
  upgrade scenarios.
* Submariner gateway pods now skip invoking cable engine cleanup during termination, as this is handled by the route agent
  during gateway migration.

## v0.15.2 (July 4, 2023)

* The `subctl cloud prepare azure` command has a new flag, `air-gapped`, to indicate the cluster is in an air-gapped
  environment which may forbid certain configurations in a disconnected Azure installation.
* Submariner now uses case-insensitive comparison while parsing CNI names.
* Submariner gateway pods now skip invoking cable engine cleanup during termination, as this is handled by the route agent
  during gateway migration.
* `subctl` is now built for ARM Macs (Darwin arm64).
* `subctl show versions` now shows the versions of the metrics proxy and plugin syncer components.
* The Globalnet component now handles out-of-order remote endpoint notifications properly.
* Reduced data path downtime with Libreswan cable driver when gateway pod restarts.
* Fixed an issue with OVNKubernetes CNI where routes could be accidentally deleted during cluster restart, or
  upgrade scenarios.

## v0.13.6 (June 7, 2023)

This is a bugfix release:

* Fixed issue where a Gateway pod restart due to SIGINT or SIGTERM signals caused data path disruption.
* Fixed issue which caused the IPsec pluto process to crash when the remote endpoint was unstable.

## v0.15.1 (June 6, 2023)

This is a bugfix release:

* Fixed issue which caused the IPsec pluto process to crash when the remote endpoint was unstable.
* Fixed issue where a Gateway pod restart due to SIGINT or SIGTERM signals caused data path disruption.
* Service Discovery now publishes DNS records for pods that are not ready for headless services based on the setting of
  the `publishNotReadyAddresses` flag on the Service.

## v0.14.5 (June 5, 2023)

This is a bugfix release:

* The `subctl gather` command now collects iptables information for OVN-Kubernetes CNI.
* Fixed issue while running `subctl gather` command for OVN-Kubernetes CNI.
* Fixed issue where a Gateway pod restart due to SIGINT or SIGTERM signals caused data path disruption.
* Fixed issue which caused the IPsec pluto process to crash when the remote endpoint was unstable.

## v0.12.4 (May 24, 2023)

There are no user-facing changes in this release.

## v0.13.5 (May 23, 2023)

This is a bugfix release:

* Submariner now ensures that reverse path filtering setting is properly applied on the `vx-submariner` and `vxlan-tunnel` interfaces after
  they are created. This fix was necessary for RHEL 9 nodes where the setting was sometimes getting overwritten.
* Fixed intermittent failure where gateway connections sometimes don't get established.
* Submariner now handles out-of-order remote endpoint notifications properly in various handlers associated with the Route Agent component.
* Fixed stale iptables rules and a global IP leak which can sometimes happen when a `GlobalEgressIP` is created and immediately deleted as
  part of stress testing.
* Fixed issues while spawning Gateway nodes during cloud prepare for clusters deployed on OpenStack environment running OVN-Kubernetes CNI.
* Fixed issue with Service addresses being resolved before the service is ready.
* The `subctl gather` command now collects the `ipset` information from all cluster nodes.

## v0.14.4 (May 4, 2023)

This is a bugfix release:

* Fixed stale iptables rules along with global IP leak which can sometimes happen as part of stress testing.
* Handle out-of-order remote endpoint notifications properly in various Route Agent handlers.
* Ensure that reverse path filtering setting is properly applied on the `vx-submariner` and `vxlan-tunnel` interfaces after they are created.
  This fix was necessary for RHEL 9 nodes where the setting was sometimes getting overwritten.
* Fixed issues while spawning Gateway nodes during cloud prepare for clusters deployed on OpenStack environment running OVN-Kubernetes CNI.
* The `subctl gather` command now collects the `ipset` information from all cluster nodes.

## v0.15.0 (May 2, 2023)

### New features

* To be compliant with the [Kubernetes Multicluster Services specification][MCS KEP], Service Discovery now distributes a single aggregated
  ServiceImport to each cluster in the exported service's namespace. Previously, each cluster distributed its own ServiceImport copy that
was placed in the `submariner-operator` namespace.
* Submariner can now be installed on IPv4/IPv6 dual-stack Kubernetes clusters. Currently, only IPv4 addresses are supported.
* Added a `subctl recover-broker-info` command to recover lost a `broker-info.subm` file.
* Extended the ability to customize the default TCP MSS clamping value set by Submariner to non-Globalnet deployments.
* The `subctl gather` command now gathers iptables logs for Calico and kindnet CNIs.
* The `subctl gather` command now collects the `ipset` information from all cluster nodes.
* The `subctl diagnose` command now validates that the Calico IPPool configuration matches Submariner's requirements.
* The `subctl verify` E2E tests now support setting the packet size used in TCP connectivity tests to troubleshoot MTU issues.
* The `subctl verify` command now runs FIPS verification tests.
* Allow overriding the image name of the metrics proxy component.
* Added endpoints to access profiling information for the gateway and Globalnet binaries.
* The following deprecated commands and variants have been removed:
  * `subctl benchmark`’s `--kubecontexts` option (use `--context` and `--tocontext` instead)
  * `subctl benchmark`’s `--intra-cluster` option (specify a single context to run intra-cluster benchmarks)
  * `subctl benchmark` with two `kubeconfigs` as command-line arguments
  * `subctl cloud`’s `--metrics-ports` option
  * `subctl deploy-broker`’s `--broker-namespace` option (use `--namespace` instead)
  * `subctl diagnose firewall metrics` (this is checked during deployment)
  * `subctl diagnose firewall intra-cluster` with two `kubeconfigs` as command-line arguments
  * `subctl diagnose firewall inter-cluster` with two `kubeconfigs` as command-line arguments
  * `subctl gather`’s `--kubecontexts` option (use `--contexts` instead)
* Deprecated the `subctl cloud prepare ... --dedicated-gateway` flag, as it's not actually used.
* Deprecated the `subctl cloud prepare generic` command, as it's not actually used.

### Other changes

* Service Discovery-only deployments now work properly without the connectivity component deployed.
* Names of `EndpointSlice` objects now include their namespace to avoid conflicts between services with the same name in multiple namespaces.
* Changes in Azure cloud prepare:
  * Machine set names are now based on region + UUID and limited to 20 characters to prevent issues with long cluster names.
  * Machine set creation and deletion logic was updated to prevent creation of multiple gateway nodes.
  * Image names are now retrieved from existing machine sets.
* Fixed stale iptables rules and a global IP leak which can sometimes happen when a `GlobalEgressIP` is created and immediately deleted as
  part of stress testing.
* Label gateway nodes as infrastructure with `node-role.kubernetes.io/infra=""` to prevent them from counting against OpenShift subscriptions.
* Submariner now handles out-of-order remote endpoint notifications properly in various handlers associated with the Route Agent component.
* Submariner now ensures that reverse path filtering setting is properly applied on the `vx-submariner` and `vxlan-tunnel` interfaces after
  they are created. This fix was necessary for RHEL 9 nodes where the setting was sometimes getting overwritten.
* Fixed intermittent failure where gateway connections sometimes don't get established.
* Fixed an issue whereby the flags for `subctl unexport service` were not recognized.
* The `subctl diagnose cni` command no longer fails for the Calico CNI when the `natOutgoing` IPPool status is missing.
* Fixed CVE-2023-28840, CVE-2023-28841, and CVE-2023-28842, which don't affect Submariner but were flagged in deliverables.

## v0.14.3 (March 16, 2023)

This is a bugfix release:

* Fixed issue with Service addresses being resolved before the service is ready.
* Various fixes for the `--image-overrides` flag when used with the `subctl diagnose` command.
* Fixed overriding the metrics proxy component in `subctl join`.

## v0.13.4 (February 24, 2023)

This is a bugfix release:

* Changes in Azure cloud prepare:
  * Machine set names are now based on region + UUID and limited to 20 characters to prevent issues with long cluster names.
  * Machine set creation and deletion logic was updated to prevent creation of multiple gateway nodes.
  * Image names are now retrieved from existing machine sets.
* The namespace is now included in `EndpointSlice` names to avoid conflicts between services with the same name in multiple namespaces.
* The `subctl gather` command now gathers iptables logs for Calico and kindnet CNIs.
* The `subctl cloud prepare` command no longer causes errors if the list of ports is empty.
* Cloud cleanup for OpenStack now identifies and deletes failed MachineSets.
* Bumped k8s.io/client-go to 0.20.15 to fix CVE-2020-8565.
* Bumped golang.org/x/crypto to 0.6.0 to fix CVE-2022-27191.
* Bumped golang.org/x/net to 0.7.0 to fix a number of security issues.

## v0.14.2 (February 22, 2023)

This is a bugfix release:

* Changes in Azure cloud prepare:
  * Machine set names are now based on region + UUID and limited to 20 characters to prevent issues with long cluster names.
  * Machine set creation and deletion logic was updated to prevent creation of multiple gateway nodes.
  * Image names are now retrieved from existing machine sets.
* Fixed a socket permission denied error in external network end-to-end tests.
* The `subctl gather` command now gathers iptables logs for Calico and kindnet CNIs.
* The `subctl cloud prepare` command no longer causes errors if the list of ports is empty.
* `subctl` operations which deploy images now allow those images to be overridden. The overrides are specified using `--image-override`:
  * `subctl benchmark`.
  * `subctl verify`.
  * `subctl diagnose` sub-commands.
* The namespace is now included in `EndpointSlice` names to avoid conflicts between services with the same name in multiple namespaces.
* Bumped go-restful to 2.16.0 to address CVE-2022-1996.
* Bumped k8s.io/client-go to 0.20.15 to fix CVE-2020-8565.
* Bumped golang.org/x/crypto to 0.6.0 to fix CVE-2022-27191.
* Bumped golang.org/x/net to 0.7.0 to fix a number of security issues.

## v0.13.3 (December 21, 2022)

This is a bugfix release:

* The `subctl diagnose kube-proxy-mode` command now works with different versions of iproute packages.
* The following changes were made to pods running `subctl diagnose` commands in order to allow them to run commands like `tcpdump`:
  * Made the `diagnose` pod privileged.
  * Run the `diagnose` pod with user ID 0.

## v0.12.3 (December 13, 2022)

This is a bugfix release:

* Image version hashes are now 12 character long, avoiding possible collisions between images.
* Stopped using cluster-owned tag for AWS cloud prepare, fixing problems with Submariner security groups left over after uninstallation.
* Support overriding the MTU value used in TCP MSS clamping, allowing fine tuning of MTU when necessary.
* CNI interface annotations created by Submariner are now removed during uninstallation.
* Bumped x/text to address CVE-2021-38561 and CVE-2022-32149.
* Diagnose now validates if the `OVNKubernetes` CNI is supported by the deployed Submariner.
* Set `DNSPolicy` to `ClusterFirstWithHostNet` for pods that run with host networking.
* Service Discovery now writes the DNS message response body when it is not a `ServerFailure` to avoid unnecessary client retries.

## v0.14.1 (December 9, 2022)

This is a bugfix release:

* Stopped using cluster-owned tag for AWS Security Group lookup.
* Running the `subctl diagnose firewall` command with individual kubeconfigs will now deploy diagnose pods in the `submariner-operator` namespace
to avoid pod security errors.
* The periodic public IP watcher is enhanced to use random external servers to resolve the public IP associated with Gateway nodes.
* The `subctl diagnose kube-proxy-mode` command now works with different versions of iproute packages.
* The following changes were made to pods running `subctl diagnose` commands in order to allow them to run commands like `tcpdump`:
  * Made the `diagnose` pod privileged.
  * Run the `diagnose` pod with user ID 0.

## v0.13.2 (November 30, 2022)

* Added support for OpenShift 4.12.
* Service Discovery now returns a DNS error message in the response body when no matching records are found when queried about
  `clusterset.local`. This prevents unnecessary retries.
* Stopped using cluster-owned tag for AWS Security Group lookup.
* Stopped using api.ipify.org as the first resolver for public IPs.
* Extended the ability to customize the default TCP MSS clamping value set by Submariner to non-Globalnet deployments.

## v0.14.0 (November 21, 2022)

### New features

* Users no longer need to open ports 8080 and 8081 on the host for querying metrics. A new `submariner-metrics-proxy` DaemonSet
runs pods on gateway nodes and forwards HTTP requests for metrics services to gateway and Globalnet pods running on the nodes.
Gateway and Globalnet pods now listen on ports 32780 and 32781 instead of well-known ports 8080 and 8081 to avoid conflict with
any other services that might be using those ports. Users will continue to query existing `submariner-gateway-metrics` and
`submariner-globalnet-metrics` services to query the metrics.
* Added `subctl diagnose service-discovery` verifications for Service Discovery objects.
* The `subctl join` command now supports an `--air-gapped` option that instructs Submariner not to access any external servers for
`public-ip` resolution.
  * Support for simulated "air-gapped" environments has been added to kind clusters.
  To use, deploy with `USING=air-gap` or `AIR_GAPPED=true`.
* Support was added in the Shipyard project to easily deploy Submariner with a LoadBalancer type Service in front.
To use, simply specify the target (e.g. `deploy`) with `USING=load-balancer` or `LOAD_BALANCER=true`.
For kind-based deployments, [MetalLB](https://metallb.universe.tf/) is deployed to provide the capability.
The MetalLB version can be specified using `METALLB_VERSION=x.y.z`.
* Support was added to force running `subctl verify` when testing end-to-end, ignoring any local tests.
To use this feature, run `make e2e using=subctl-verify`.
Verifications can be now specified using the `SUBCTL_VERIFICATIONS` flag, instead of relying on the default behavior.
e.g.: `make e2e using=subctl-verify SUBCTL_VERIFICATIONS=connectivity,service-discovery`.
* kubeconfig handling has been revamped to be consistent across all
  `subctl` commands and to match `kubectl`’s behaviour.
  * The single-context commands, `cloud-prepare`, `deploy-broker`, `export`,
  `join`, `unexport` and `uninstall`, now all support a `--context` argument
  to specify the kubeconfig context to use. kubeconfig files can be
  specified using either the `KUBECONFIG` environment variable or the
  `--kubeconfig` argument; `kubectl` defaults will be applied if
  configured. If no context is specified, the kubeconfig default context
  will be used.
  * Multiple-context commands which operate on all contexts by default,
  `show` and `gather`, support a `--contexts` argument which can be used
  to select one or more contexts; they also support the `--context` argument
  to select a single context.
  * Multiple-context commands which operate on specific contexts,
  `benchmark` and `verify`, support a `--context` argument to specify the
  originating context, and a `--tocontext` argument to specify the target
  context.
  * `diagnose` operates on all accessible contexts by default, except
  `diagnose firewall inter-cluster` and `diagnose firewall nat-traversal`
  which rely on an originating context specified by `--context` and a
  remote context specified by `--remotecontext`.
  * Namespace-based commands such as `export` will use the namespace given
  using `--namespace` (`-n`), if any, or the current namespace in the
  selected context, if there is one, rather than the `default`
  namespace.
  * These commands also support all connection options supported by
  `kubectl`, so connections can be configured using command arguments
  instead of kubeconfigs.
  * Existing options (`--kubecontext` etc.) are preserved for backwards
  compatibility, but are deprecated and will be removed in the next
  release.

### Other changes

* The Flannel CNI is now properly identified during join.
* A new ServiceExport status condition type named Synced was added that indicates whether or not the ServiceImport
was successfully synced to the broker.
* Service Discovery now handles updates to an exported service and updates/deletes the corresponding ServiceImport accordingly.
* Service Discovery now returns a DNS error message in the response body when no matching records are found when queried about
`clusterset.local`. This prevents unnecessary retries.
* Cloud cleanup for OpenStack now identifies and deletes failed MachineSets.
* Privileges of the Route Agent and Gateway pods were reduced as they don’t need to access PersistentVolumeClaims and Secrets.
* The privileged SCC permission for Submariner components in OCP is set now by creating separate `ClusterRole` and `ClusterRoleBinding`
resources instead of manipulating the system privileged SCC resource.
* Extended the ability to customize the default TCP MSS clamping value set by Submariner to non-Globalnet deployments.
* The `subctl show` command now correctly reports component image versions when image overrides were specified on `join`.
* Updates to the `subctl gather` command:
  * The `subctl gather` command now creates one subdirectory per cluster instead of embedding the cluster name in each file name.
  * If it’s not given a custom directory, `subctl gather` stores all its output in a directory
  named `submariner-` followed by the current date and time (in UTC) in "YYYYMMDDHHmmss" format.
  * The `subctl gather` command now includes the output from `ovn-sbctl show` which has the `chassis-id` to `hostname` mapping that can
  be used to verify if `submariner_router` is pinned to the proper Gateway node.

## v0.13.1 (September 22, 2022)

This is a bugfix release:

* Allow broker certificate checks to be disabled for insecure connections, using `subctl join --check-broker-certificate=false`.
* Return local cluster IP for headless services.
* Display proper output message from `subctl show brokers` when broker is not installed on the cluster.
* Allow passing `DEFAULT_REPO` while building subctl.
* Cleaned up the host routes programmed by OVN RA plugin during uninstall.
* Support overriding image names per-component to better support downstream builds.
* Limited Azure machine name lengths to 40 characters.
* Documented the default cable driver in the `subctl join` help message.
* Set `DNSPolicy` to `ClusterFirstWithHostNet` for pods that run with `HostNetworking: true`.
* Removed hardcoded `workerNodeList` while querying image for GCP and RHOS cloud preparation steps.
* Collect the output of `ovn-sbctl show` in `subctl gather`.
* Bumped x/text to address CVE-2021-38561.
* Set `ReadHeaderTimeout` (new in Go 1.18) to mitigate potential Slowloris attacks.

## v0.13.0 (July 18, 2022)

### New features

* All Submariner container images are now available for x86-64 and ARM64 architectures.
* Support was added in `subctl cloud prepare` to deploy Submariner on OpenShift on Microsoft Azure. This automatically configures the
underlying Azure cloud infrastructure to meet Submariner's prerequisites.
* Added more robust support for connecting clusters that use the OVNKubernetes CNI plugin in non-Globalnet deployments. Note that
OVNKubernetes requires the OVN NorthBound DB version to be 6.1.0 or above and older versions are not supported. Also note that the minimum
supported OpenShift Container Platform (OCP) version is 4.11.
* Added support for connecting to Kubernetes headless Services without Pod label selectors in Globalnet deployments. This is useful when you
want to point a Service to another Service in a different namespace or external network. When endpoints are manually defined by the user,
Submariner automatically routes the traffic and provides DNS resolution.
* Added a new `subctl show brokers` command that displays information about the Submariner Brokers installed.
* The `subctl diagnose` command was extended to verify inter-cluster connectivity when Submariner is deployed using a LoadBalancer Service.

### Other changes

* The `submariner-operator` namespace is labeled in accordance with _KEP-2579: Pod Security Admission Control_ (default in Kubernetes 1.24)
to allow the Pods to be privileged.
* The default namespace in which `subctl diagnose kubeproxy` and `subctl diagnose firewall` (and subcommands) spawn a Pod has been changed
from `default` to `submariner-operator` as the latter has all necessary labels needed by the Pod Security Admission Controller. If the
user-specified namespace is missing any of these labels, `subctl` will inform the user about the warnings in the `subctl diagnose` logs.
* The Globalnet metrics port will now be opened by default when Globalnet is deployed using `subctl cloud prepare`.
* It is now possible to customize the default TCP MSS clamping value set by Submariner in Globalnet deployments. This could be useful in
network topologies where MTU issues are seen. To force a particular MSS clamping value use the `submariner.io/tcp-clamp-mss` node annotation
on Gateway nodes, e.g. `kubectl annotate node <node_name> submariner.io/tcp-clamp-mss=<value>`.

## v0.12.2 (July 7, 2022)

This is a bugfix release:

* The Globalnet metrics port will now be opened by default when Globalnet is deployed using `subctl cloud prepare`.
* Submariner ServiceExport now has unique condition types to simplify waiting for readiness.
* The `subctl diagnose` command now supports NAT-discovery port validation.
* The `subctl cloud prepare rhos` command will now work properly for nodes to which security groups were added manually.
* The `submariner-operator` namespace is labeled in accordance with _KEP-2579: Pod Security Admission Control_ (default in Kubernetes 1.24)
to allow the Pods to be privileged.
* The default namespace for the `subctl diagnose` command was changed to `submariner-operator`.
* Submariner pod images are now based on Fedora 36.
* Fixed issues related to Globalnet and Route-agent pods due to missing grep in the container image.
* Made secrets for ServiceAccounts compatible with Kubernetes 1.24 onwards.
* Restart health check pinger if it fails.
* Fixed intermittent failure when running `subctl diagnose firewall metrics`.

## v0.12.1 (May 10, 2022)

This is a bugfix release:

* The default image type for a dedicated gateway node is changed from `PnTAE.CPU_16_Memory_32768_Disk_80` to
`PnTAE.CPU_4_Memory_8192_Disk_50` for OpenStack Cloud prepare.
* `subctl gather` will now use `libreswan` as  a default cable driver if none is specified in `SubmarinerSpec` during installation.
* Sometimes when Submariner, with Globalnet enabled, is used to connect onPrem clusters with Public clusters, MTU issues are seen. This
was particularly noticed when the underlying platform uses `nftables` on the host nodes. This release fixes the MTU issues by explicitly
clamping the TCP MSS to a fixed value derived from the default interface MTU subtracted with the cable-driver overhead.
* As part of `subctl uninstall` operation, we now remove the `submariner.io/globalIp` annotation that is added on the gateway node.

## v0.12.0 (March 21, 2022)

### New features

* Added a new `subctl uninstall` command that removes all Submariner components and dataplane artifacts, such as iptables rules and routing
table entries, from a cluster.
* Added a new `subctl unexport` command that stops exporting a previously exported service.
* Added new `subctl cloud prepare` and `subctl cloud cleanup` commands for the Red Hat OpenStack Platform (RHOS).
* Added new metrics:
  * Globalnet: Count of global Egress IPs allocated at Cluster scope, namespace scope, and for selected pods per CIDR.
  * Globalnet: Count of global Ingress IPs allocated for Pods/Services per CIDR.
  * Service Discovery: Count of DNS queries handled by Lighthouse.
* Added support for Globalnet objects verification using the `subctl diagnose` command.
* Added support for `--broker-namespace` flag while deploying the Broker.
* Added support for running `subctl diagnose` on single node clusters.
* Added support for running `subctl diagnose` from a pod in a cluster.
* `subctl cloud prepare` now deploys a dedicated gateway node as a default option on GCP and OpenStack platforms.
* `subctl show` now shows information about the Broker CR in the cluster.
* `subctl gather` now collects Globalnet information.
* `subctl diagnose` displays a warning when a generic CNI network plugin is detected.

### Bug fixes

* Calico is now correctly detected when used as a network plugin in OpenShift.
* Services without selectors can now be resolved across the ClusterSet.
* `subctl diagnose firewall inter-cluster` now works correctly for the VXLAN cable driver.

### Other changes

* The broker token and IPsec PSK are now stored in secrets which are used in preference to the corresponding fields in the Submariner CR,
which are now deprecated. For backwards compatibility and to simplify upgrades, the deprecated fields are still populated but will be
removed in 0.13.
* Globalnet no longer uses `kube-proxy` chains in support of exported services. Instead, it now creates an internal `ClusterIP` Service with
the `ExternalIPs` set to the global IP assigned to the corresponding Service. Some Kubernetes distributions don't allow Services with
`ExternalIPs` by default for security reasons. Users must follow the
[Globalnet prerequisites](https://submariner.io/getting-started/architecture/globalnet/) to allow the Globalnet controller to
create/update/delete Services with `ExternalIPs`.

### Known Issues

* When using the dot character in the cluster name, service discovery doesn’t work
([#707](https://github.com/submariner-io/lighthouse/issues/707)).
* On OpenShift, Globalnet metrics do not appear automatically. This can be fixed by manually opening the Globalnet metrics port, TCP/8081.
* When using `subctl cloud prepare` on Red Hat OpenStack Platform (RHOS), if a dedicated gateway is used, the Submariner gateway security
group and Submariner internal security group are associated with the wrong node. This can be resolved by manually adding the security
groups using OpenStack CLI or Web UI ([#227](https://github.com/submariner-io/cloud-prepare/issues/227)).

## v0.11.2 (February 1, 2022)

This release doesn’t contain any user-facing changes; it fixes internal release issues.

## v0.11.1 (January 10, 2022)

This is a bugfix release:

* All exported headless Services are now given a Globalnet ingress IP when Globalnet is enabled ([#1634](https://github.com/submariner-io/submariner/issues/1634)).
* Deployments without Globalnet no longer fail because of an invalid `GlobalCIDR` range ([#1668](https://github.com/submariner-io/submariner-operator/issues/1668)).
* `subctl gather` no longer panics when retrieving some Pod container status information ([#1684](https://github.com/submariner-io/submariner-operator/issues/1684)).

## v0.11.0 (October 28, 2021)

This release mainly focused on stability, bug fixes, and improving the integration between Submariner and Open Cluster Management
via the [Submariner addon](https://github.com/open-cluster-management/submariner-addon).

* `subctl cloud prepare` command now supports Google Cloud Platform as well as generic Kubernetes clusters.
* `--ignore-requirements` flag was added to `subctl join` command which ignores Submariner requirements checks.

## v0.10.1 (August 12, 2021)

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

## v0.9.1 (June 29, 2021)

* The `--kubecontext` flag in `subctl` commands now works properly.
* Simplified `subctl cloud prepare aws` to extract the credentials, infrastructure ID, and region from a local configuration file (if available).
* The `natt-discovery-port` and `udp-port` options can now be set via node annotations.

## v0.9.0 (April 30, 2021)

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

## v0.8.1 (February 11, 2021)

* Submariner Gateway Health Check is now supported with Globalnet deployments.
* Added support for deploying OVN in kind using `make clusters using=ovn` for E2E testing and development environments.
* Added support for debugging the Libreswan cable driver.
* Fixed the cable driver label in the Prometheus latency metrics.
* Added support for non-TLS connections for OVN databases.
* Services can now be recreated without needing to recreate their associated `ServiceExport` objects.
* Service Discovery no longer depends on Submariner-provided connectivity.
* Improved Service Discovery verification suite.
* The `ServiceImport` object now includes Port information from the original Service.
* `subctl show` now indicates when the target cluster doesn't have Submariner installed.

## v0.8.0 (December 22, 2020)

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
* Refactoring to **support pluggable drivers** (in preparation for WireGuard).

## v0.1.1 Submariner with more light

> This release is focused on stability for Lighthouse.

* Cleaner logging for `submariner-engine`.
* Cleaner logging for `submariner-route-agent`.
* Fixed issue with wrong token stored in `.subm` file ([#244](https://github.com/submariner-io/submariner-operator/issues/244)).
* Added flag to disable the OpenShift CVO ([#235](https://github.com/submariner-io/submariner-operator/issues/235)).
* Fixed several service discovery bugs ([#194](https://github.com/submariner-io/submariner-operator/issues/194), [#167](https://github.com/submariner-io/submariner-operator/issues/167)).
* Fixed several panics on nil network discovery.
* Added checks to ensure the CIDRs for joining cluster don't overlap with existing ones.
* Fixed context handling related to service discovery/KubeFed
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
* Renamed `submariner` Pods to `submariner-gateway` Pods for clarity.
* Print version details on crash (`subctl`).
* Stopped storing IPsec key on Broker during `deploy-broker`, now it's only contained into the `.subm` file.
* Version command for `subctl`.
* Nicer spinners during deployment (thanks to kind).

## v0.0.3 -- KubeCon NA 2019

Submariner has been greatly enhanced to allow administrators to deploy into Kubernetes clusters without the necessity for Layer 2 adjacency
for nodes. Submariner now allows for VXLAN interconnectivity between nodes (facilitated by the route agent). `subctl` was created to make
deployment of Submariner easier.

## v0.0.2 Second Submariner release

## v0.0.1 First Submariner release
