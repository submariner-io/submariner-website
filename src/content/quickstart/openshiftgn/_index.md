---
date: 2020-02-21T13:36:18+01:00
title: "OpenShift with Service Discovery and Globalnet (AWS)"
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

{{% notice info %}}

The Lighthouse project is meant only to be used as a development preview. Installing the operator on an Openshift cluster will disable Openshift CVO.

{{% /notice %}}

To install Submariner with multi-cluster service discovery and support for overlapping CIDRs follow the steps below.

#### Create a merged kubeconfig

```bash
export KUBECONFIG=$PWD/cluster-a/auth/kubeconfig:$PWD/cluster-b/auth/kubeconfig
sed -i 's/admin/east/' cluster-a/auth/kubeconfig
sed -i 's/admin/west/' cluster-b/auth/kubeconfig
kubectl config view --flatten > ./merged_kubeconfig
```
#### Use cluster-a as broker with service discovery and globalnet enabled

```bash
subctl deploy-broker  --kubecontext west --kubeconfig ./merged_kubeconfig --service-discovery --globalnet
```

#### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubecontext west --kubeconfig ./merged_kubeconfig broker-info.subm --clusterid west --broker-cluster-context west
```

```bash
subctl join --kubecontext east --kubeconfig ./merged_kubeconfig broker-info.subm --clusterid east --broker-cluster-context west
```

####  Verify Deployment
To verify the deployment follow the steps below.

```bash
export KUBECONFIG=./merged_kubeconfig
kubectl --context east create deployment nginx --image=nginx
kubectl --context east expose deployment nginx --port=80
kubectl --context west run --generator=run-pod/v1 tmp-shell --rm -i --tty --image nicolaka/netshoot -- /bin/bash
curl nginx
```
