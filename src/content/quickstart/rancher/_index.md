---
date: 2020-05-15T15:30:00+00:00
title: "Rancher 2.x"
weight: 10
---

{{< include "quickstart/rancher/prerequisites.md" >}}
{{< include "quickstart/rancher/create_clusters.md" >}}

### Install subctl

{{< subctl-install >}}

Obtain the kubeconfig files from the Rancher UI for each of your clusters, placing them in the respective kubeconfigs.

|Cluster|Kubeconfig File Name|
|----|---|
|Cluster A|kubeconfig-cluster-a|
|Cluster B|kubeconfig-cluster-b|

### Use cluster-a as broker

```bash
subctl deploy-broker --kubeconfig kubeconfig-cluster-a
```

### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubeconfig kubeconfig-cluster-a broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig kubeconfig-cluster-b broker-info.subm --clusterid cluster-b
```

### Verify connectivity

This will run a series of E2E tests to verify proper connectivity between the cluster Pods and Services

```bash
subctl verify-connectivity kubeconfig-cluster-a kubeconfig-cluster-b --verbose
```
