---
date: 2020-02-21T13:36:18+01:00
title: "With Service Discovery"
weight: 15
---

This quickstart guide covers the necessary steps to deploy two OpenShift Container Platform (OCP) clusters on AWS with full stack automation
(aka IPI). Once the OpenShift clusters are deployed, we will walk you through the deployment of Submariner with Service Discovery,
interconnecting the two clusters.

{{< include "quickstart/openshift/setup_openshift.md" >}}

{{% notice info %}}
Please ensure that the tools you downloaded above are compatible with your OpenShift Container Platform version. For more information,
please refer to the official [OpenShift documentation](https://docs.openshift.com/container-platform/).
{{% /notice %}}

{{< include "quickstart/openshift/setup_aws.md" >}}
{{< include "quickstart/openshift/create_clusters.md" >}}

### Prepare Your AWS Clusters for Submariner

{{< include "quickstart/openshift/download_prep_for_subm.md" >}}

{{% notice info %}}
Please note that  **oc**, **aws-cli**, **terraform**, and **wget** need to be installed before the `prep_for_subm.sh` script can be run.
{{% /notice %}}

{{< include "quickstart/openshift/run_prep_for_subm.md" >}}

### Install subctl

{{< subctl-install >}}

### Install Submariner with Service Discovery

To install Submariner with multi-cluster service discovery follow the steps below.

#### Use cluster-a as Broker with service discovery enabled

```bash
subctl deploy-broker --kubeconfig cluster-a/auth/kubeconfig --service-discovery
```

#### Join cluster-a and cluster-b to the Broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b
```

{{< include "quickstart/verify_with_discovery.md" >}}
