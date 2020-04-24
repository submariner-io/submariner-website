---
date: 2020-02-21T13:36:18+01:00
title: "OpenShift with Service Discovery (AWS)"
weight: 15
---

{{< include "quickstart/openshift/setup_openshift.md" >}}
{{< include "quickstart/openshift/create_clusters.md" >}}
{{< include "quickstart/openshift/ready_clusters.md" >}}

### Install subctl

{{< subctl-install >}}

### Install kubefedctl

Download the kubefedctl binary and make it available on your PATH.

```bash
VERSION=0.1.0-rc3
OS=linux
ARCH=amd64
curl -LO https://github.com/kubernetes-sigs/kubefed/releases/download/v${VERSION}/kubefedctl-${VERSION}-${OS}-${ARCH}.tgz
tar -zxvf kubefedctl-*.tgz
chmod u+x kubefedctl
mv kubefedctl ~/.local/bin/
```

### Install Submariner with Service Discovery

{{% notice info %}}

The Lighthouse project is meant only to be used as a development preview. Installing the operator on an Openshift cluster will disable Openshift CVO.

{{% /notice %}}

To install Submariner with multi-cluster service discovery follow the steps below.

#### Create a merged kubeconfig

```bash
export KUBECONFIG=$PWD/cluster-a/auth/kubeconfig:$PWD/cluster-b/auth/kubeconfig
sed -i 's/admin/east/' cluster-a/auth/kubeconfig
sed -i 's/admin/west/' cluster-b/auth/kubeconfig
kubectl config view --flatten > ./merged_kubeconfig
```
#### Use cluster-a as broker with service discovery enabled

```bash
subctl deploy-broker  --kubecontext west --kubeconfig ./merged_kubeconfig --service-discovery
```

#### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubecontext west --kubeconfig ./merged_kubeconfig broker-info.subm --clusterid west
```

```bash
subctl join --kubecontext east --kubeconfig ./merged_kubeconfig broker-info.subm --clusterid east
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
