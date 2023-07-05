---
date: 2022-07-03T10:00:00+02:00
title: "IBM Cloud (IKS)"
weight: 10
---

This quickstart guide covers deploying Submariner on two IBM Cloud Kubernetes (IKS) clusters.
The *Automated example* section point to an automated installer for those who just want to have a quick demo,
while the *Manual guide* walks through the more important settings and steps.

{{% notice info %}}
The guide assumes clusters have non-overlapping Pod and Service CIDRs.
[Globalnet](https://submariner.io/getting-started/architecture/globalnet/) can be used if overlapping CIDRs can't be avoided.
{{% /notice %}}

# Automated example

The following repo's [submariner-quickstart folder](https://github.com/IBM-Cloud/kube-samples/tree/master/submariner-quickstart)
contains an automated installer that:
- creates two IKS clusters with Terraform
- installs Submariner on them
- verifies the setup

For more details, see the repo.

# Manual guide

A step-by-step walkthrough about using Submariner on IBM Cloud.

## Clusters

The exact process of cluster creation is not covered here.
One can use the [web UI](https://cloud.ibm.com/docs/containers?topic=containers-getting-started&interface=ui),
the [CLI](https://cloud.ibm.com/docs/containers?topic=containers-getting-started&interface=cli) or
[Terraform](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest)
([example](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/container_cluster#vpc-generation-2-ibm-cloud-kubernetes-service-cluster))
to create IBM Cloud Kubernetes Clusters.

### Example topology

The guide the following example parameters:

| Cluster Name | Pod CIDR       | Service CIDR  |
|--------------|----------------|---------------|
| primary      | 172.17.0.0/18  | 172.21.0.0/16 |
| secondary    | 172.17.64.0/18 | 172.22.0.0/16 |

## Submariner deployment

### Subctl binary 

{{% subctl-install %}}

### Access

At the time of writing, `subctl` does not support OIDC-based authentication,
so accessing the clusters can be done through [Service Accounts](https://kubernetes.io/docs/concepts/security/service-accounts/).

The fastest way to obtain a suitable kube config is to run the following command:

```shell
ibmcloud ks cluster config --admin --cluster CLUSTER_NAME
```

The example uses `$primary_ctx` and `$secondary_ctx` environment variables.
Their values can be obtained using `kubectl` like:
```shell
kubectl config get-contexts -o name
export primary_ctx=CLUSTER1_NAME
export secondary_ctx=CLUSTER2_NAME
```

### Calico CNI

Due to [active-passive gateway model](https://submariner.io/getting-started/architecture/gateway-engine/)
of Submariner, "external" (cross-cluster) traffic will appear on the nodes.
As a consequence, in-cluster node-to-node traffic encapsulation should be configured.

```shell
kubectl patch --type=merge IPPool default-ipv4-ippool -p '{"spec":{"ipipMode":"Always"}}'
```

On an IBM Cloud Kubernetes (and OpenShift) cluster, the default encapsulation mode is IP in IP,
which is acceleration-assisted, so it is recommended to keep that.
Avoiding the `Always` encapsulation is also an option, but it requires configuring reverse path filtering on the nodes.

Calico should be also configured to avoid unnecessary NAT on cross-cluster traffic.
Please read the [Calico specific](https://submariner.io/operations/deployment/calico/) guide on how to set it up.

Every Submariner cluster should have something like this:
```yaml
# see: https://submariner.io/operations/deployment/calico/
# applicable on the first cluster
---
apiVersion: crd.projectcalico.org/v1
kind: IPPool
metadata:
  name: avoid-nat-towards-cluster2-pods
spec:
  cidr: 172.17.64.0/18  # secondary cluster's pod subnet
  natOutgoing: false    # what we want
  disabled: true        # Calico should not use the mentioned subnet to assign IPs from
---
apiVersion: crd.projectcalico.org/v1
kind: IPPool
metadata:
  name: avoid-nat-towards-cluster2-services
spec:
  cidr: 172.22.0.0/16
  natOutgoing: false
  disabled: true
```

### Broker

Deploy the [Broker](https://submariner.io/getting-started/architecture/broker/) on the primary cluster.

``` bash
subctl deploy-broker --context $primary_ctx
```

The command will output a file named `broker-info.subm` to the directory it is run from, which will be used to set up the
IPsec tunnel between clusters.

### Join clusters 

Now it is time to register every cluster in the ClusterSet of the Broker.

First, join the Broker-hosting cluster itself to the Broker:

```shell
./subctl join --context $primary_ctx \
  broker-info.subm \
  --clusterid my-cluster-name1 \
  --load-balancer \
  --clustercidr "172.17.0.0/18"
```

Submariner will figure out most of the required information on its own. The `--clusterid` and `--servicecidr` flags should be used to pass the same
values as during the cluster creation steps above. You will also see a dialogue on the terminal that asks you to decide which of the three
nodes will be the Gateway. Any node will work. It will be annotated with `submariner.io/gateway: true`.

When a cluster is joined, the Submariner Operator is installed. It creates several components in the `submariner-operator` namespace:

* `submariner-gateway` DaemonSet, to open a gateway for the IPsec tunnel on one node
* `submariner-routeagent` DaemonSet, which runs on every worker node in order to route the internal traffic to the local gateway
via VXLAN tunnels
* `submariner-lighthouse-agent` Deployment, which accesses the Kubernetes API server in the Broker cluster to exchange Service
information with the Broker
* `submariner-lighthouse-coredns` Deployment, which - as an external DNS server - gets forwarded requests to the
`*.clusterset.local` domain for cross-cluster communication by Kubernetes' internal DNS server


The `--load-balancer` flag creates a `LoadBalancer` service for the Gateway.
It should be annotated to achieve correct behaviour
because those are used [to configure](https://cloud.ibm.com/docs/containers?topic=containers-vpc-lbaas#setup_vpc_nlb)
the backing Network Load Balancer.

```shell
# Get the `healthCheckNodePort` of the LoadBalancer service
# to allow the NLB to forward traffic "directly" to the Gateway
healthcheck_port=$(kubectl --context $primary_ctx \
  get service -n=submariner-operator \
  submariner-gateway-healtcheck \
  -o jsonpath='{.spec.healthCheckNodePort}'
)

# Configure backing NLB through annotations
kubectl --context $primary_ctx annotate service \
  -n submariner-operator submariner-gateway \
  --overwrite \
  service.beta.kubernetes.io/aws-load-balancer-type- \
  service.kubernetes.io/ibm-load-balancer-cloud-provider-enable-features=nlb \
  service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type=public \
  service.kubernetes.io/ibm-load-balancer-cloud-provider-vpc-health-check-protocol=http \
  service.kubernetes.io/ibm-load-balancer-cloud-provider-vpc-health-check-port=$healthcheck_port
```

After these steps, let's wait for the creation of the Load Balancer. It can take approx. 5-20 minutes.

Now join the second cluster to the Broker:

```shell
./subctl join --context $secondary_ctx \
  broker-info.subm \
  --clusterid my-cluster-name2 \
  --clustercidr "172.17.64.0/18"
```

For more subctl flags, see [subctl manual](https://submariner.io/operations/deployment/subctl/).

## Verification 

After the LoadBalancer has been created and the tunnels are established,
we can verify the new setup.

```shell
# Overview of the settings and statuses
subctl show all --context $primary_ctx

# End-to-end test (> 10 minutes)
subctl verify \
  --context $primary_ctx \
  --tocontext $secondary_ctx \
  --only connectivity,service-discovery

# In case of something is off
subctl diagnose --context $primary_ctx
```

## See also

- [Prerequisites of Submariner](https://submariner.io/getting-started/#prerequisites)
- [subctl manual](https://submariner.io/operations/deployment/subctl/)
