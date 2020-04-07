---
date: 2020-02-21T13:36:18+01:00
title: "OpenShift (AWS)"
weight: 10
---

{{< include "quickstart/openshift/setup_openshift.md" >}}
{{< include "quickstart/openshift/create_clusters.md" >}}
{{< include "quickstart/openshift/ready_clusters.md" >}}

### Install subctl

{{< subctl-install >}}

### Use cluster-a as broker

```bash
subctl deploy-broker --kubeconfig cluster-a/auth/kubeconfig 
```


### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b
```

### Verify connectivity

This will run a series of E2E tests to verify proper connectivity between the cluster pods and services

```bash
subctl verify-connectivity cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --verbose
```
