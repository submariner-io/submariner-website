---
title: "subctl"
weight: 10
---

`subctl` is a command line utility designed to simplify the deployment and maintenance of
Submariner across your clusters.

## Synopsis

`subctl [command] [--flags] ...`

## Description

`subctl` helps to automate the deployment of the Submariner [operator](https://github.com/submariner-io/submariner-operator) thereby reducing the possibility of mistakes during the process.

`subctl` connects to specified cluster(s) and performs the requested *command*.

## Commands

### deploy-broker

`subctl deploy-broker [flags]`

The **deploy-broker** command configures the cluster specified by the `--kubeconfig` flag
(or `KUBECONFIG` env var) and the `--kubecontext` flag as the Broker. It installs
the necessary CRDs and the `submariner-k8s-broker` namespace.

In addition, it generates a `broker-info.subm` file which can be used with the `join` command
to connect clusters to the Broker. This file contains the following details:

 * Encryption PSK key
 * Broker access details for subsequent `subctl` runs.
 * Service discovery settings
 * Globalnet settings

#### deploy-broker flags


| Flag                               | Description
|:-----------------------------------|:----------------------------------------------------------------------------|
|`--kubeconfig` `<string>`           | Absolute path(s) to the kubeconfig file(s) (default "$HOME/.kube/config")
|`--kubecontext` `<string>`          | kubeconfig context to use
|`--service-discovery`               | Enable Multi Cluster Service Discovery
|`--globalnet`                       | Enable support for Overlapping cluster/service CIDRs in connecting clusters (default disabled)
|`--globalnet-cidr-range` `<string>` | Global CIDR supernet range for allocating GlobalCIDRs to each cluster (default "169.254.0.0/16")
|`--ipsec-psk-from` `<string>`       | Import IPSEC PSK from existing Submariner broker file, like broker-info.subm (default "broker-info.subm)
|`--dataplane`                       | Install the Submariner dataplane on the broker. If this flag is enabled, the broker will be joined as if a join command was run right after deploy-broker. Use the join flags too if you use --dataplane.

### join

`subctl join broker-info.subm [flags]`

The **join** command deploys the Submariner operator in a cluster using the settings provided in the `broker-info.subm` file.
The service account credentials needed for the new cluster to access the Broker cluster will be created and provided to the Submariner operator
deployment. All the other settings like service discovery enablement and globalnet support are sourced from the
broker-info file.


#### join flags (general)

| Flag                               | Description
|:-----------------------------------|:----------------------------------------------------------------------------|
| `--cable-driver` `<string>`        | Cable driver implementation (defaults to strongswan -IPSec-)
| `--clusterid` `<string>`           | Cluster ID used to identify the tunnels. Every cluster needs to have an unique cluster ID, if not provided `subctl` will prompt the admin for a cluster ID.
| `--clustercidr` `<string>`         | Cluster CIDR specify a cluster CIDR (generally the IP addresses used for the pods in this cluster), if not specified subctl will try to discover this detail, and if it's unable to discover it will prompt the admin.
| `--colorcodes` `<string>`          | Color codes (default "blue"), coma separated values. Please use with caution, as it may change in the future. This setting is used to make Submariner gateway form connections only with clusters which share the same color code. This will be replaced by something more flexible in the future.
| `--no-label `                      | Skip gateway labeling this will disable prompting the administrator for a worker node to use as gateway.
| `--subm-debug`                     | Enable Submariner debugging (verbose logging)
| `--disable-cvo`                    | Disable OpenShift's cluster version operator if necessary, without prompting. Currently, lighthouse service modifies the cluster dns operator in OpenShift and we need to disable CVO, this setting disables the prompt which warns the administrator.

#### join flags (globalnet)

| Flag                                 | Description
|:-------------------------------------|:----------------------------------------------------------------------------|
| `--globalnet-cluster-size` `<value>` | Cluster size for GlobalCIDR allocated to this cluster (amount of global IPs).
| `--globalnet-cidr` `<string>`        | GlobalCIDR to be allocated to the cluster, this setting is exclusive with `--globalnet-cluster-size` and configures a specific globalnet CIDR for this cluster.

#### join flags (IPSec)

| Flag                    | Description
|:------------------------|:-----------------------------------------------|
| `--disable-nat`         | Disable NAT for IPsec.
| `--ikeport` `<value>`   | IPsec IKE port (default 500)
| `--ipsec-debug`         | Enable IPsec debugging (verbose logging)
| `--nattport` `<value>`  | IPsec NATT port (default 4500)

#### join flags (images and repositories)

| Flag                                    | Description
|:----------------------------------------|:----------------------------------------------------------------------------|
| `--repository` `<string>`               | Image repository, the repository from where the various submariner images will be sourced. (default "quay.io/submariner")
| `--version` `<string>`                  | Image version
| `-o`, `--operator-image` `<string>`     | The operator image you wish to use (default "quay.io/submariner/submariner-operator:$version")
| `--service-discovery-repo` `<string>`   | Service Discovery Image repository (default "quay.io/submariner")
| `--service-discovery-version` `<string>`| Service Discovery Image version

### info

`subctl info [flags]`

The `info` command inspects the cluster and reports information related to Submariner, like the
detected network plugin, and the detected Cluster and Service CIDRs.

#### info flags

| Flag                         | Description
|:-----------------------------|:----------------------------------------------------------------------------|
| `--kubeconfig` `<string>`    | Absolute path(s) to the kubeconfig file(s) (default "$HOME/.kube/config")
| `--kubecontext` `<string>`   | Kubeconfig context to use

### verify-connectivity

`subctl verify-connectivity <kubeConfig1> <kubeConfig2> [flags]`

The `verify-connectivity` command verifies dataplane connectivity between two clusters. The
`kubeConfig1` file will be `ClusterA` in the reports, while `kubeConfig2` will be `ClusterB` in the
reports. The `--verbose` flag is recommended to see what's happening during the tests.

Dataplane connectivity is verified in multiple ways: between pods and services, between pods and pods,
and between gateway and non-gateway node combinations.


#### verify-connectivity flags

| Flag                                | Description
|:------------------------------------|:----------------------------------------------------------------------------|
| `--connection-attempts` `<value>`   | The maximum number of connection attempts (default 2)
| `--connection-timeout` `<value>`    | The timeout in seconds per connection attempt  (default 60)
| `--operation-timeout` `<value>`     | Operation timeout for K8s API calls (default 240)
| `--report-dir` `<string>`           | XML report directory (default ".")
| `--verbose`                         | Produce verbose logs during connectivity verification

### version

`subctl version`

Prints the version details for the subctl binary.


## Installation

{{< subctl-install >}}
