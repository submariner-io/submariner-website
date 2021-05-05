---
date: 2020-02-21T13:36:18+01:00
title: "On AWS with Globalnet"
weight: 30
---

This quickstart guide covers the necessary steps to deploy two OpenShift Container Platform (OCP) clusters on AWS with
full stack automation, also known as installer-provisioned infrastructure (IPI). Once the OpenShift clusters are deployed, we deploy
Submariner to interconnect the two clusters. Since the two clusters share the same Cluster and Service CIDR ranges,
[Globalnet](../../../architecture/globalnet/) will be enabled.

{{< include "/resources/shared/openshift/setup_openshift.md" >}}

{{% notice info %}}
Please ensure that the tools you downloaded above are compatible with your OpenShift Container Platform version. For more information,
please refer to the official [OpenShift documentation](https://docs.openshift.com/container-platform/).
{{% /notice %}}

{{< include "/resources/shared/openshift/setup_aws.md" >}}

### Create and Deploy cluster-a

In this step you will deploy **cluster-a** using the default IP CIDR ranges:

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

```bash
openshift-install create install-config --dir cluster-a
```

```bash
openshift-install create cluster --dir cluster-a
```

When the cluster deployment completes, directions for accessing your cluster, including a link to its web console and credentials for the
`kubeadmin` user, display in your terminal.

### Create and Deploy cluster-b

In this step you will deploy **cluster-b** using the same default IP CIDR ranges:

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

```bash
openshift-install create install-config --dir cluster-b
```

```bash
openshift-install create cluster --dir cluster-b
```

When the cluster deployment completes, directions for accessing your cluster, including a link to its web console and credentials for the
`kubeadmin` user, display in your terminal.

### Prepare AWS Clusters for Submariner

{{< include "/resources/shared/openshift/download_prep_for_subm.md" >}}

{{% notice info %}}
Please note that  `oc`, `aws-cli`, `terraform`, and `wget` need to be installed before the `prep_for_subm.sh` script can be run.
Also note that the script is known to be working with [Terraform](https://releases.hashicorp.com/terraform/) version 0.12.
Maximum compatible version is 0.12.12.
{{% /notice %}}

{{% notice note %}}
The script deploys an `m5n.large` EC2 instance type by default, optimized for improved network throughput and packet rate performance,
for the Submariner gateway node. Please ensure that the AWS Region you deploy to supports this instance type. Alternatively, you can
customize the AWS instance type as shown below.
{{% /notice %}}

{{< include "/resources/shared/openshift/run_prep_for_subm.md" >}}

### Install `subctl`

{{% subctl-install %}}

### Install Submariner with Service Discovery and Globalnet

To install Submariner with multi-cluster service discovery and support for overlapping CIDRs follow the steps below.

#### Use cluster-a as Broker with service discovery and globalnet enabled

```bash
subctl deploy-broker  --kubeconfig cluster-a/auth/kubeconfig --globalnet
```

#### Join cluster-a and cluster-b to the Broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b
```

{{< include "/resources/shared/verify_with_discovery.md" >}}
