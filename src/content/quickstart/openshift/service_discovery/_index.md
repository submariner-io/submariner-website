---
date: 2020-02-21T13:36:18+01:00
title: "With Service Discovery"
weight: 15
---

{{< include "quickstart/openshift/setup_openshift.md" >}}
{{< include "quickstart/openshift/create_clusters.md" >}}
{{< include "quickstart/openshift/ready_clusters.md" >}}

### Install subctl

{{< subctl-install >}}

### Install Submariner with Service Discovery

To install Submariner with multi-cluster service discovery follow the steps below.

#### Use cluster-a as broker with service discovery enabled

```bash
subctl deploy-broker --kubeconfig cluster-a/auth/kubeconfig --service-discovery
```

#### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b
```

{{< include "quickstart/verify_with_discovery.md" >}}
