---
date: 2020-02-21T13:36:18+01:00
title: "Hybrid OpenStack and AWS"
weight: 50
---

This quickstart guide covers the necessary steps to deploy two OpenShift Container Platform (OCP) clusters: one on AWS
and the other one on OpeStack, both with full stack automation, also known as installer-provisioned infrastructure (IPI).
Once the OpenShift clusters are deployed, we deploy Submariner with Service Discovery to interconnect the two clusters.
Note that this guide focuses on Submariner deployment on clusters with non-overlapping Pod and Service CIDRs.
For connecting clusters with overlapping CIDRs, please refer to the
[Submariner with Globalnet guide](../globalnet/).

{{< include "/resources/shared/openshift/setup_openshift_openstack.md" >}}

{{% notice info %}}
Please ensure that the tools you downloaded above are compatible with your OpenShift Container Platform version. For more information,
please refer to the official [OpenShift documentation](https://docs.openshift.com/container-platform/).
{{% /notice %}}

{{< include "/resources/shared/openshift/create_clusters_aws_openstack.md" >}}

### Install `subctl`

{{% subctl-install %}}

### Prepare OpenStack and AWS Clusters for Submariner

{{% cloud-prepare/intro %}}
{{% cloud-prepare/OpenStack %}}

### Install Submariner with Service Discovery

To install Submariner with multi-cluster Service Discovery follow the steps below:

#### Use cluster-a as Broker

```bash
subctl deploy-broker --kubeconfig cluster-a/auth/kubeconfig
```

#### Join cluster-a and cluster-b to the Broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a --nattport 4747
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b --nattport 4747
```

{{< include "/resources/shared/verify_with_discovery.md" >}}
