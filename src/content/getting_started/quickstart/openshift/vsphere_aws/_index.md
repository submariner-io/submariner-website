---
date: 2020-02-21T13:36:18+01:00
title: "Hybrid vSphere and AWS"
weight: 40
---

This quickstart guide covers the necessary steps to deploy two OpenShift Container Platform (OCP) clusters: one on VMware vSphere with user
provisioned infrastructure (UPI) and the other one on AWS with full stack automation, also known as installer-provisioned infrastructure
(IPI). Once the OpenShift clusters are deployed, we deploy Submariner with Service Discovery to interconnect the two clusters.

{{< include "/resources/shared/openshift/setup_openshift.md" >}}

{{% notice info %}}
Please ensure that the tools you downloaded above are compatible with your OpenShift Container Platform version. For more information,
please refer to the official [OpenShift documentation](https://docs.openshift.com/container-platform/).
{{% /notice %}}

### Create and Deploy cluster-a on vSphere (On-Prem)

In this step you will deploy **cluster-a** using the default IP CIDR ranges:

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

Before you deploy an OpenShift Container Platform cluster that uses user-provisioned infrastructure, you must create the underlying
infrastructure. Follow the [OpenShift documenation](https://docs.openshift.com/container-platform/) for installation instructions on
supported versions of vSphere.

Submariner Gateway nodes need to be able to accept IPsec traffic. For on-premises clusters behind corporate firewalls, the default IPsec UDP
ports might be blocked. To overcome this, Submariner supports NAT Traversal (NAT-T) with the option to set custom non-standard ports.
In this example, we use UDP 4501 and UDP 501. Ensure that those ports are allowed on the gateway node and on the corporate firewall.

Submariner also uses VXLAN to encapsulate traffic from the worker and master nodes to the Gateway nodes. Ensure that firewall configuration
on the vSphere cluster allows 4800/UDP across all nodes in the cluster in both directions.

| Protocol   | Port   | Description                                  |
|------------|--------|----------------------------------------------|
| UDP        | 4800   | Overlay network for inter-cluster traffic    |
| UDP        | 4501   | IPsec traffic                                |
| UDP        | 501    | IPsec traffic                                |

When the cluster deployment completes, directions for accessing your cluster, including a link to its web console and credentials for the
`kubeadmin` user, display in your terminal.

### Create and Deploy cluster-b on AWS

#### Setup Your AWS Profile

Configure the AWS CLI with the settings required to interact with AWS. These include your security credentials, the default AWS Region,
and the default output format:

```bash
$ aws configure
AWS Access Key ID [None]: ....
AWS Secret Access Key [None]: ....
Default region name [None]: ....
Default output format [None]: text
```

#### Create and Deploy cluster-b

In this step you will deploy **cluster-b**, modifying the default IP CIDRs to avoid IP address conflicts with **cluster-a**. You can change
the IP addresses block and prefix based on your requirements. For more information on IPv4 CIDR conversion,
please check [this page](https://www.ipaddressguide.com/cidr).

In this example, we will use the following IP ranges:

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.132.0.0/14 |172.31.0.0/16 |

```bash
openshift-install create install-config --dir cluster-b
```

Change the Pod network CIDR from 10.128.0.0/14 to 10.132.0.0/14:

```bash
sed -i 's/10.128.0.0/10.132.0.0/g' cluster-b/install-config.yaml
```

Change the Service network CIDR from 172.30.0.0/16 to 172.31.0.0/16:

```bash
sed -i 's/172.30.0.0/172.31.0.0/g' cluster-b/install-config.yaml
```

And finally deploy the cluster:

```bash
openshift-install create cluster --dir cluster-b
```

When the cluster deployment completes, directions for accessing your cluster, including a link to its web console and credentials for the
`kubeadmin` user, display in your terminal.

#### Prepare AWS Cluster for Submariner

{{< include "/resources/shared/openshift/download_prep_for_subm.md" >}}

{{% notice info %}}
Please note that  `oc`, `aws-cli`, `terraform`, and `wget` need to be installed before the `prep_for_subm.sh` script can be run.
Also note that the script is known to be working with [Terraform](https://releases.hashicorp.com/terraform/) version 0.12.
Maximum compatible version is 0.12.12.
{{% /notice %}}

{{% notice note %}}
The script deploys an `m5n.large` EC2 instance type by default, optimized for improved network throughput and packet rate performance,
for the Submariner gateway node. Please ensure that the AWS Region you deploy to support this instance type. Alternatively, you can
customize the AWS instance type as shown below.
{{% /notice %}}

* Modify the IPsec UDP ports and run the `prep_for_subm.sh` script for **cluster-b**:

```bash
export IPSEC_NATT_PORT=4501
export IPSEC_IKE_PORT=501
```

```bash
./prep_for_subm.sh cluster-b # respond "yes" when Terraform asks for approval, or otherwise add the -auto-approve flag
```

### Submariner Installation

{{< subctl-install >}}

#### Install Submariner with Service Discovery

To install Submariner with multi-cluster service discovery, follow the steps below:

##### Use cluster-b (AWS) as Broker with Service Discovery enabled

```bash
subctl deploy-broker --kubeconfig cluster-b/auth/kubeconfig --service-discovery
```

##### Join cluster-b (AWS) and cluster-a (vSphere) to the Broker

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --ikeport 501 --nattport 4501
```

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --ikeport 501 --nattport 4501
```

{{< include "/resources/shared/verify_with_discovery.md" >}}
