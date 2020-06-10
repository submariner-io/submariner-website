---
date: 2020-02-21T13:36:18+01:00
title: "With Service Discovery and Globalnet"
weight: 20
---

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

### Install subctl

{{< subctl-install >}}

### Install Submariner with Service Discovery and Globalnet

To install Submariner with multi-cluster service discovery and support for overlapping CIDRs follow the steps below.

#### Use cluster-a as broker with service discovery and globalnet enabled

```bash
subctl deploy-broker  --kubeconfig cluster-a/auth/kubeconfig --service-discovery --globalnet
```

#### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid west
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid east
```
####  Verify Deployment
To verify the deployment follow the steps below.

```bash
kubectl --kubeconfig cluster-b/auth/kubeconfig create deployment nginx --image=nginx
kubectl --kubeconfig cluster-b/auth/kubeconfig expose deployment nginx --port=80
kubectl --kubeconfig cluster-a/auth/kubeconfig run --generator=run-pod/v1 tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
curl nginx
```
