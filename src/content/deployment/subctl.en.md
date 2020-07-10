---
title: "subctl"
weight: 10
---

`subctl` is a command line utility designed to simplify the deployment and maintenance of
Submariner across your clusters.

## Synopsis

`subctl [command] [--flags] ...`

## Description

`subctl` helps to automate the deployment of the Submariner [operator](https://github.com/submariner-io/submariner-operator), thereby reducing the possibility of mistakes during the process.

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
| `--clusterid` `<string>`           | Cluster ID used to identify the tunnels. Every cluster needs to have a unique cluster ID, if not provided `subctl` will prompt the admin for a cluster ID.
| `--clustercidr` `<string>`         | Specifies the cluster's CIDR used to generate Pod IP addresses. If not specified, subctl will try to discover it and, if unable to do so, it will prompt the user.
| `--no-label `                      | Skip gateway labeling. This disables the prompt for a worker node to use as gateway.
| `--subm-debug`                     | Enable Submariner debugging (verbose logging)

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
| `--repository` `<string>`               | The repository from where the various submariner images will be sourced. (default "quay.io/submariner")
| `--version` `<string>`                  | Image version

### info

`subctl info [flags]`

The `info` command inspects the cluster and reports information related to Submariner, like the
detected network plugin, and the detected Cluster and Service CIDRs.

#### info flags

| Flag                         | Description
|:-----------------------------|:----------------------------------------------------------------------------|
| `--kubeconfig` `<string>`    | Absolute path(s) to the kubeconfig file(s) (default "$HOME/.kube/config")
| `--kubecontext` `<string>`   | Kubeconfig context to use

### verify

`subctl verify <kubeConfig1> <kubeConfig2> [flags]`

The `verify` command verifies a Submariner deployment between two clusters is functioning properly. The
`kubeConfig1` file will be `ClusterA` in the reports, while `kubeConfig2` will be `ClusterB` in the
reports. The `--verbose` flag is recommended to see what's happening during the tests.

There are several suites of verifications that can be performed. By default all verifications are performed.
Some verifications are deemed disruptive in that they change some state of the clusters as a side effect.
If running the command interactively, you will be prompted for confirmation to perform disruptive
verifications unless the `--enable-disruptive` flag is also specified. If running non-interactively (that is with no stdin), `--enable-disruptive` must be specified otherwise disruptive verifications are skipped.

The `connectivity` suite verifies dataplane connectivity across the clusters for the following cases:
 * Pods (on gateways) to Services
 * Pods (on non-gateways) to Services
 * Pods (on gateways) to Pods
 * Pods (on non-gateways) to Pods
and between gateway and non-gateway node combinations.

The `service-discovery` suite verifies dns discovery of `<service>.<namespace>.svc.supercluster.local`
entries across the clusters.

The `gateway-failover` suite verifies the continuity of cross-cluster dataplane connectivity after a
gateway failure in a cluster occurs. This suite requires a single gateway configured on `ClusterA` and other
available worker nodes capable of serving as gateways. Please note that this verification is disruptive.

#### verify flags

| Flag                                | Description
|:------------------------------------|:----------------------------------------------------------------------------|
| `--connection-attempts` `<value>`   | The maximum number of connection attempts (default 2)
| `--connection-timeout` `<value>`    | The timeout in seconds per connection attempt  (default 60)
| `--operation-timeout` `<value>`     | Operation timeout for K8s API calls (default 240)
| `--report-dir` `<string>`           | XML report directory (default ".")
| `--verbose`                         | Produce verbose logs during connectivity verification
| `--only`                            | Comma separated list of specific verifications to perform 
| `--enable-disruptive`               | Enable verifications which are potentially disruptive to your deployment

### version

`subctl version`

Prints the version details for the subctl binary.


## Installation

{{< subctl-install >}}
