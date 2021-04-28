---
date: 2020-05-15T15:30:00+00:00
title: "Rancher"
weight: 20
---

{{< include "/resources/shared/rancher/prerequisites.md" >}}
{{< include "/resources/shared/rancher/create_clusters.md" >}}

### Install subctl

{{< subctl-install >}}

Obtain the kubeconfig files from the Rancher UI for each of your clusters, placing them in the respective kubeconfigs.

|Cluster|Kubeconfig File Name|
|----|---|
|Cluster A|kubeconfig-cluster-a|
|Cluster B|kubeconfig-cluster-b|

Edit the kubeconfig files so they use the context names “cluster-a” and “cluster-b”.

### Use cluster-a as Broker

```bash
subctl deploy-broker --kubeconfig kubeconfig-cluster-a
```

### Join cluster-a and cluster-b to the Broker

```bash
subctl join --kubeconfig kubeconfig-cluster-a broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig kubeconfig-cluster-b broker-info.subm --clusterid cluster-b
```

### Verify connectivity

This will run a series of E2E tests to verify proper connectivity between the cluster Pods and Services

```bash
export KUBECONFIG=kubeconfig-cluster-a:kubeconfig-cluster-b
subctl verify --kubecontexts cluster-a,cluster-b --only connectivity --verbose
```
