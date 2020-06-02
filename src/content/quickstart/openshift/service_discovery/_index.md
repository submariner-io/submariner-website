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

{{% notice info %}}

The Lighthouse project is meant only to be used as a development preview. Installing the operator on an Openshift cluster will disable Openshift CVO.

{{% /notice %}}

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

####  Verify Deployment
To verify the deployment follow the steps below.

```bash
kubectl --kubeconfig cluster-b/auth/kubeconfig create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl --kubeconfig cluster-b/auth/kubeconfig expose deployment nginx --port=8080
kubectl --kubeconfig cluster-a/auth/kubeconfig run --generator=run-pod/v1 tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.supercluster.local:8080
```
