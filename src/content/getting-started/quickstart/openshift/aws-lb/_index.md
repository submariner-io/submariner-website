---
date: 2020-02-21T13:36:18+01:00
title: "On AWS (LoadBalancer mode)"
weight: 20
---

This quickstart guide covers the necessary steps to deploy two OpenShift Container Platform (OCP)
clusters on AWS leveraging a cloud network load balancer service in front of the Submariner gateways.

The main benefit of this mode is that there is no need to dedicate specialized nodes with a public IP
address to act as gateways. The administrator only needs to manually label any existing
node or nodes in each cluster as Submariner gateways, and the submariner-operator will take care of creating a LoadBalancer
type Service pointing to the active Submariner gateway.

{{% notice warning %}}
Please note that this mode is still experimental and may need more testing. For example we haven't
measured the impact on HA failover times.
{{% /notice %}}

{{< include "/resources/shared/openshift/setup_openshift.md" >}}

{{% notice info %}}
Please ensure that the tools you downloaded above are compatible with your OpenShift Container Platform version. For more information,
please refer to the official [OpenShift documentation](https://docs.openshift.com/container-platform/).
{{% /notice %}}

{{< include "/resources/shared/openshift/setup_aws.md" >}}
{{< include "/resources/shared/openshift/create_clusters.md" >}}

### Install `subctl`

{{% subctl-install %}}

### Prepare AWS Clusters for Submariner

{{% cloud-prepare/intro %}}
{{% cloud-prepare/aws-lb clusters="cluster-a,cluster-b" %}}

### Install Submariner with Service Discovery

To install Submariner with multi-cluster Service Discovery follow the steps below:

#### Use cluster-a as Broker

```bash
subctl deploy-broker --kubeconfig cluster-a/auth/kubeconfig
```

#### Join cluster-a and cluster-b to the Broker

```bash
subctl join --load-balancer --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a
```

```bash
subctl join --load-balancer  --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b
```

{{< include "/resources/shared/verify_with_discovery.md" >}}
