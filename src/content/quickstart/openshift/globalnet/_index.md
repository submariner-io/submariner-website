---
date: 2020-02-21T13:36:18+01:00
title: "With Service Discovery and Globalnet"
weight: 20
---

This quickstart guide covers the necessary steps to deploy two OpenShift Container Platform (OCP) clusters on AWS with full stack automation
(aka IPI). Once the OpenShift clusters are deployed, we will walk you through the deployment of Submariner with Service Discovery,
interconnecting the two clusters. Since the two clusters share the same Cluster and Service CIDR ranges,
[Globalnet](../../../architecture/globalnet/) will be enabled.

{{< include "quickstart/openshift/setup_openshift.md" >}}

### Create cluster A

This step will create a cluster named "cluster-a" with the default IP CIDRs.

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

```bash
openshift-install create install-config --dir cluster-a
```

```bash
openshift-install create cluster --dir cluster-a
```

This may take some time to complete so you can move on to the next section in parallel if you wish.

### Create cluster B

This step will create a cluster named "cluster-b" with the default IP CIDRs.

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

```bash
openshift-install create install-config --dir cluster-b
```

And finally deploy

```bash
openshift-install create cluster --dir cluster-b
```

{{< include "quickstart/openshift/ready_clusters.md" >}}

### Install `subctl`

{{< subctl-install >}}

### Install Submariner with Service Discovery and Globalnet

To install Submariner with multi-cluster service discovery and support for overlapping CIDRs follow the steps below.

#### Use cluster-a as Broker with service discovery and globalnet enabled

```bash
subctl deploy-broker  --kubeconfig cluster-a/auth/kubeconfig --service-discovery --globalnet
```

#### Join cluster-a and cluster-b to the Broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid west
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid east
```

{{< include "quickstart/verify_with_discovery.md" >}}
