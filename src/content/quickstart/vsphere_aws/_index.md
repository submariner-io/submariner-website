---
date: 2020-02-21T13:36:18+01:00
title: "OpenShift with Service Discovery (vSphere/AWS)"
weight: 30
---

In this quickstart guide, we shall cover the necessary steps to deploy OpenShift Container Platform (OCP) on vSphere and AWS.
Once the OCP clusters are deployed, we shall cover how to deploy Submariner and connect the two clusters.

### OpenShift Prerequisites

Before we proceed, the following prerequisites have to be downloaded and added to your `$PATH:`

 1. [openshift-installer](https://cloud.redhat.com/openshift/install/aws/installer-provisioned)
 2. [pull secret](https://cloud.redhat.com/openshift/install/aws/installer-provisioned)
 3. [oc](https://cloud.redhat.com/openshift/install/aws/installer-provisioned) tools
 4. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

{{% notice info %}}

Please ensure that the tools you downloaded above are compatible with the OpenShift Container Platform version.

{{% /notice %}}

### Deploy Cluster on vSphere (On-Prem)

Create the necessary infrastructure on vSphere and ensure that your machines have direct internet access before starting the installation.
See the [docs for deploying OCP 4.4 on
vSphere](https://docs.openshift.com/container-platform/4.4/installing/installing_vsphere/installing-vsphere.html).

Assuming that you deployed the cluster (say, cluster-a) with default network configuration, the Pod and Service CIDRs would be

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

Submariner creates a VXLAN overlay network in the local cluster and uses port 4800/UDP to encapsulate traffic from the worker nodes to the
gateway nodes to preserve the source IP of the inter-cluster traffic.
Ensure that firewall configuration on vSphere cluster allows 4800/UDP across all the worker nodes.

|  Protocol  |  Port  |     Description                              |
|------------|--------|----------------------------------------------|
|   UDP      |  4800  | overlay network for inter-cluster traffic    |

{{% notice tip %}}

Although we are using the default OCP network configuration on vSphere, you can [install vSphere with a custom network
configuration](https://red.ht/2WFjEVg).

{{% /notice %}}

### Deploy Cluster on AWS

#### Configure AWS CLI with appropriate values

```bash
$ aws configure
AWS Access Key ID [None]: ....
AWS Secret Access Key [None]: ....
Default region name [None]: ....
Default output format [None]: text
```

For more details, see the [OCP 4.4 AWS account configuration
docs](https://docs.openshift.com/container-platform/4.4/installing/installing_aws/installing-aws-account.html).

In this step we shall modify the default Cluster/Service CIDRs and deploy cluster-b on AWS.

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.132.0.0/14 |172.31.0.0/16 |

```bash
openshift-install create install-config --dir cluster-b
```

Change the Pod IP network. Please note it’s a /14 range by default so you need to use +4 increments for “128”, for example: 10.132.0.0,
10.136.0.0, 10.140.0.0, ...

```bash
sed -i 's/10.128.0.0/10.132.0.0/g' cluster-b/install-config.yaml
```

Change the Service IP network. This is a /16 range by default, so just use +1 increments for “30”: for example: 172.31.0.0, 172.32.0.0,
172.33.0.0, ...

```bash
sed -i 's/172.30.0.0/172.31.0.0/g' cluster-b/install-config.yaml
```

And finally deploy

```bash
openshift-install create cluster --dir cluster-b
```

### Make your AWS cluster ready for Submariner

Submariner gateway nodes need to be able to accept IPsec traffic. The default ports are 4500/UDP and 500/UDP.
However, when you have some on-premises clusters (like vSphere in this example) which are typically inside a corporate network, the firewall
configuration on the corporate router may not allow the default IPsec traffic.
We can overcome this limitation by using non-standard ports like 4501/UDP and 501/UDP.

Additionally, the default OpenShift deployment does not allow assigning an elastic public IP
to existing worker nodes, something that is necessary at least on one end of the IPsec connections.

To handle these requirements on AWS, we provide a script
[prep_for_subm.sh](https://github.com/submariner-io/submariner/blob/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh),
that will prepare your AWS OpenShift deployment for Submariner, and will create an additional gateway node with an external IP.

In the following example, we create the gateway node on cluster-b, with custom IPsec ports and instance type:

```bash

curl https://raw.githubusercontent.com/submariner-io/submariner/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh -L -O
chmod a+x ./prep_for_subm.sh

export IPSEC_NATT_PORT=4501
export IPSEC_IKE_PORT=501
export GW_INSTANCE_TYPE=m4.xlarge

./prep_for_subm.sh cluster-b  # respond yes when terraform asks to approve, or add after path: -auto-approve

```

> **_INFO_** Please note that  **oc**, **aws-cli**, **terraform**, and **wget** need to be installed before running the `prep_for_subm.sh` script.

### Submariner Installation

{{< subctl-install >}}

#### Install Submariner with Service Discovery

To install Submariner with multi-cluster service discovery, follow the steps below.

##### Use cluster-b (AWS) as Broker with service discovery enabled

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

{{< include "quickstart/verify_with_discovery.md" >}}
