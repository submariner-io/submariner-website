---
date: 2020-11-13T17:55:18+01:00
title: "Google (GKE)"
weight: 10
---

This quickstart guide covers the necessary steps to deploy two Google Kubernetes Engine (GKE) clusters on Google Cloud Platform (GCP) using
`gcloud`. The clusters are named **cluster-a** and **cluster-b**.

Once the GKE clusters are deployed, we deploy Submariner with Service Discovery to interconnect the two clusters.
Note that this guide focuses on Submariner deployment on clusters with non-overlapping Pod and Service CIDRs.

{{% notice info %}}
The guide assumes that you have a working GCP account and the `gcloud` binary installed and configured.
To get the binary, please visit [Google's website](https://cloud.google.com/sdk/docs/install).
{{% /notice %}}

## Cluster Creation

Create two identical Kubernetes clusters on GKE.
For this guide, the following minimal configuration was used, however not everything is required (see the note part below).

``` bash
gcloud container clusters create "cluster-a" \
    --zone "europe-west3-a" \
    --cluster-ipv4-cidr "10.0.0.0/14"
    --services-ipv4-cidr="10.3.240.0/20"
    --cluster-version "1.17.13-gke.1400" \
    --username "admin" \
    --machine-type "g1-small" \
    --image-type "UBUNTU" \
    --disk-type "pd-ssd" \
    --disk-size "15" \
    --num-nodes "3" \
    --network "default" \
```

``` bash
gcloud container clusters create "cluster-b" \
    --zone "europe-west3-a" \
    --cluster-ipv4-cidr "10.4.0.0/14"
    --services-ipv4-cidr="10.7.240.0/20"
    --cluster-version "1.17.13-gke.1400" \
    --username "admin" \
    --machine-type "g1-small" \
    --image-type "UBUNTU" \
    --disk-type "pd-ssd" \
    --disk-size "15" \
    --num-nodes "3" \
    --network "default" \
```

{{% notice note %}}
Make sure to use Kubernetes version 1.17 or higher, set by `--cluster-version`
(refer to the [GKE docs/ release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes)).
Also double check for non-overlapping Pod and Service CIDRs between clusters using the commands below:
{{% /notice %}}

``` bash
gcloud container clusters describe "cluster-a" --zone "europe-west3-a" | grep -e clusterIpv4Cidr -e servicesIpv4Cidr
gcloud container clusters describe "cluster-b" --zone "europe-west3-a" | grep -e clusterIpv4Cidr -e servicesIpv4Cidr
```

## Prepare Clusters for Submariner

Next, the created clusters need some changes in order for Submariner to successfully open the IPSEC tunnel between them.

### Preparation: Node Configuration

As of version 0.7 of Submariner (the current one while writing this), Google's native CNI plugin is not directly supported.
GKE clusters can be generated with Calico CNI instead, but this was not tested during this demo and therefore could hold surprises as well.

So as this guide uses Google's native CNI plugin, configuration is needed for the `eth0` interface of each node on every cluster.
The used workaround deploys `netshoot` pods onto each node that configure the reverse path filtering.
The scripts in [this](https://github.com/sridhargaddam/k8sscripts/tree/main/rp_filter_settings) Github repository need to be executed
in all clusters.

``` bash
wget https://raw.githubusercontent.com/sridhargaddam/k8sscripts/main/rp_filter_settings/update-rp-filter.sh
wget https://raw.githubusercontent.com/sridhargaddam/k8sscripts/main/rp_filter_settings/configure-rp-filter.sh
chmod +x update-rp-filter.sh
chmod +x configure-rp-filter.sh
kubectx cluster-a # kubectl config use-context cluster-a
./configure-rp-filter.sh
kubectx cluster-b # kubectl config use-context cluster-b
./configure-rp-filter.sh
```

### Preparation: Firewall Configuration

Submariner requires UDP ports 500, 4500 and 4800 to be open in both directions.
Additionally the microservices' traffic needs to flow through the IPsec tunnel as TCP packets.
Hence the TCP traffic has source and destination addresses originating in the participating clusters.
Create those firewall rules on the GCP project.

{{% notice note %}}
Use the commands above to retrieve the `clusterIpv4Cidr` and `servicesIpv4Cidr` for both clusters.
If you copied the above code, you can just copy&paste the values below for the `--source-ranges` and `--destination-ranges`.
{{% /notice %}}

``` bash
gcloud compute firewall-rules create "allow-tcp-in" --allow=tcp \
  --direction=IN --source-ranges=10.7.240.0/20,10.4.0.0/14,10.3.240.0/20,10.0.0.0/14

gcloud compute firewall-rules create "allow-tcp-out" --allow=tcp --direction=OUT \
  --destination-ranges=10.7.240.0/20,10.4.0.0/14,10.3.240.0/20,10.0.0.0/14

gcloud compute firewall-rules create "udp-in-500" --allow=udp:500 --direction=IN
gcloud compute firewall-rules create "udp-in-4500" --allow=udp:4500 --direction=IN
gcloud compute firewall-rules create "udp-in-4800" --allow=udp:4800 --direction=IN

gcloud compute firewall-rules create "udp-out-500" --allow=udp:500 --direction=OUT
gcloud compute firewall-rules create "udp-out-4500" --allow=udp:4500 --direction=OUT
gcloud compute firewall-rules create "udp-out-4800" --allow=udp:4800 --direction=OUT
```

After this, the clusters are finally ready for Submariner!

## Deploy Submariner

{{< subctl-install >}}

We will deploy the [Broker](https://submariner.io/getting_started/architecture/broker/) on **cluster-a**.
The command will output a file named `broker-info.subm` to the directory it is run from, which will be used to setup the
IPsec tunnel between clusters.

The Broker cluster's API must be accessible by all the participating clusters, which is given by GKE standard configuration.

Kubecontext and the kubeconfig file can be specified (it defaults to ~/.kube/config):

``` bash
subctl deploy-broker --kubecontext cluster-a --kubeconfig <path/to/config>
```

Verify the Broker components are installed using `kubectl`:

``` bash
kubectl get crds --context cluster-a | grep -i submariner
  > clusters.submariner.io
    endpoints.submariner.io
    gateways.submariner.io
    multiclusterservices.lighthouse.submariner.io
    servicediscoveries.submariner.io
    serviceexports.lighthouse.submariner.io
    serviceimports.lighthouse.submariner.io
    submariners.submariner.io
```

``` bash
kubectl get ns --context cluster-a | grep -i submariner
  > submariner-k8s-broker
```

Now it is time to register every cluster in the future clusterset to the Broker.

First join the Broker cluster itself (the Broker could also be deployed on a cluster that does not run workloads,
hence installing the Broker does not automatically add the cluster). The command tags the cluster for Submariner with the ID `cluster-a`.

``` bash
subctl join --kubecontext cluster-a --kubeconfig <path/to/config> broker-info.subm --clusterid cluster-a
```

Submariner will figure out most information needed on its own. In addition, you will see a dialogue on the terminal that asks you to

* decide which of the three nodes shall be the Gateway. This node gets annotated with `submariner.io/gateway: true` automatically.
* input the cluster's Pod and Service CIDR, if it could not be detected.

When a cluster is joined, the Submariner Operator is installed. It creates several components in the `submariner-operator` namespace:

* a `submariner-gateway` DaemonSet, to open a gateway for the IPsec tunnel on one node
* a `submariner-routeagent` DaemonSet, which runs on every worker node in order to route the internal traffic to the local gateway
via VXLAN tunnels
* a `submariner-lighthouse-agent` Deployment, which accesses the Kubernetes API server in the Broker cluster to exchange Service
information with the Broker
* a `submariner-lighthouse-coredns` Deployment, which - as an external DNS server - gets forwarded requests to the
`*.clusterset.local` domain for cross-cluster communication by Kubernetes' internal DNS server

Check the DaemonSets and Deployments with the following command:

``` bash
kubectl --context cluster-a get ds,deploy -n submariner-operator
```

Repeat with the second cluster:

``` bash
subctl join --kubecontext cluster-b --kubeconfig <path/to/config> broker-info.subm --clusterid cluster-b
```

Then verify connectivity and CIDR settings within the clusterset using:

``` bash
subctl show all
```

You should see similar output to this:

``` bash
CLUSTER ID    ENDPOINT IP    PUBLIC IP    CABLE DRIVER    TYPE
cluster-a     10.156.0.46     35.x.x.x    strongswan      local
cluster-b     10.156.0.42     35.x.x.x    strongswan      remote

GATEWAY    CLUSTER     REMOTE IP      CABLE DRIVER    SUBNETS                       STATUS
gke-*-*    cluster-a   10.156.0.42    strongswan      10.3.240.0/20, 10.0.0.0/14    connected

NODE       HA STATUS     SUMMARY
gke-*-*    active        All connections (1) are established
```

### Final Workaround for KubeDNS

GKE uses KubeDNS by default for cluster-internal DNS queries. Submariner however only works with CoreDNS as of version 0.7. As a
consequence, the `*.clusterset.local` domain stub needs to be added manually to KubeDNS.
Query the ClusterIP of the `submariner-lighthouse-coredns` Service in **cluster-a**:

``` bash
CLUSTER_IP=$(kubectl --context cluster-a get svc submariner-lighthouse-coredns -n submariner-operator \
  -o=custom-columns=ClusterIP:.spec.clusterIP | tail -n +2)
```

Use the information to apply the following ConfigMap, automatically replacing $CLUSTER_IP with the ClusterIP obtained for
the `submariner-lighthouse-coredns`:

``` bash
cat <<EOF | kubectl --context cluster-a apply -f -
apiVersion: v1
kind: ConfigMap
data:
  stubDomains: |
    {"clusterset.local":["$CLUSTER_IP"]}
metadata:
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
  name: kube-dns
  namespace: kube-system
EOF
```

{{% notice note %}}
Repeat both commands, the `CLUSTER_IP` discovery and the `kubectl apply`, this time using `--context cluster-b`.
{{% /notice %}}

{{< include "/resources/shared/verify_with_discovery.md" >}}

### Reconfig after Node Restart

If the GKE Nodes were at some point drained or deleted, the Submariner Pods needed to terminate.
Once the Nodes are up again, remember to

* label one Node with `kubectl label node <name> submariner.io/gateway=true` in order for the Gateway to be deployed on this Node
* apply the Node Configuration workaround again
* change the applied KubeDNS workaround to reflect the current `submariner-lighthouse-coredns` IP.

This makes Submariner functional again and work can be continued.
