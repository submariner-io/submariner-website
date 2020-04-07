---
date: 2020-02-21T13:36:18+01:00
title: "OpenShift with Service Discovery and Globalnet (AWS)"
weight: 15
---

## AWS

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

### Make your clusters ready for submariner

Submariner gateway nodes need to be able to accept traffic over ports 4500/UDP and 500/UDP
when using IPSEC. In addition we use port 4800/UDP to encapsulate traffic from the worker nodes
to the gateway nodes and ensure that Pod IP addresses are preserved.

Additionally, the default Openshift deployments don't allow assigning an elastic public IP
to existing worker nodes which is necessary on at least one end of the IPSEC connections. 

To handle these requirements, a script is provided that will prepare your AWS OpenShift deployment
for submariner, and will create an additional gateway node with an external IP.

```bash

curl https://raw.githubusercontent.com/submariner-io/submariner/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh -L -O
chmod a+x ./prep_for_subm.sh

./prep_for_subm.sh cluster-a     # respond yes when terraform asks
./prep_for_subm.sh cluster-b      # respond yes when terraform asks

```

{{% notice info %}}

Please note that the prep_for_subm.sh script requires that you first have the following installed: **oc, aws-cli, terraform, and unzip**. 

{{% /notice %}}

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
