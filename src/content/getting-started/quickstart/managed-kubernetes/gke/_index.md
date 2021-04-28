---
date: 2020-11-13T17:55:18+01:00
title: "Google (GKE)"
weight: 10
---

This quickstart guide covers deploying two Google Kubernetes Engine (GKE) clusters on Google Cloud Platform (GCP) and connecting them with
Submariner and [Service Discovery](https://submariner.io/getting-started/architecture/service-discovery/).

{{% notice info %}}
The guide assumes clusters have non-overlapping Pod and Service CIDRs.
[Globalnet](https://submariner.io/getting-started/architecture/globalnet/) can be used if overlapping CIDRs can't be avoided.
{{% /notice %}}

{{% notice info %}}
The guide assumes you have the [`gcloud` binary installed and configured](https://cloud.google.com/sdk/docs/install) and a [GCP account with
billing enabled for the active project](https://cloud.google.com/kubernetes-engine/docs/quickstart#before-you-begin).
{{% /notice %}}

## Cluster Creation

Create two identical Kubernetes clusters on GKE.
For this guide, the following minimal configuration was used, however not everything is required (see the note part below).

```shell
gcloud container clusters create "cluster-a" \
    --zone "europe-west3-a" \
    --enable-ip-alias \
    --cluster-ipv4-cidr "10.0.0.0/14" \
    --services-ipv4-cidr="10.4.0.0/20" \
    --cluster-version "1.17.13-gke.2001" \
    --username "admin" \
    --machine-type "g1-small" \
    --image-type "UBUNTU" \
    --disk-type "pd-ssd" \
    --disk-size "15" \
    --num-nodes "3" \
    --network "default"
```

```shell
gcloud container clusters create "cluster-b" \
    --zone "europe-west3-a" \
    --enable-ip-alias \
    --cluster-ipv4-cidr "10.8.0.0/14" \
    --services-ipv4-cidr="10.12.0.0/20" \
    --cluster-version "1.17.13-gke.2001" \
    --username "admin" \
    --machine-type "g1-small" \
    --image-type "UBUNTU" \
    --disk-type "pd-ssd" \
    --disk-size "15" \
    --num-nodes "3" \
    --network "default"
```

{{% notice note %}}
Make sure to use Kubernetes version 1.17 or higher, set by `--cluster-version`. The latest versions are listed in the [GKE release
notes](https://cloud.google.com/kubernetes-engine/docs/release-notes).
{{% /notice %}}

## Prepare Clusters for Submariner

The clusters need some changes in order for Submariner to successfully open the IPsec tunnel between them.

### Preparation: Node Configuration

As of version 0.8 of Submariner (the current one while writing this), Google's native CNI plugin is not directly supported.
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
gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
./configure-rp-filter.sh
gcloud container clusters get-credentials cluster-b --zone="europe-west3-a"
./configure-rp-filter.sh
```

### Preparation: Firewall Configuration

Submariner requires UDP ports 500, 4500, and 4800 to be open in both directions. Additionally the microservices' traffic needs to flow
through the IPsec tunnel as TCP packets. Hence the TCP traffic has source and destination addresses originating in the participating
clusters. Create those firewall rules on the GCP project. Use the same IP ranges as in the cluster creation steps above.

``` bash
gcloud compute firewall-rules create "allow-tcp-in" --allow=tcp \
  --direction=IN --source-ranges=10.12.0.0/20,10.8.0.0/14,10.4.0.0/20,10.0.0.0/14

gcloud compute firewall-rules create "allow-tcp-out" --allow=tcp --direction=OUT \
  --destination-ranges=10.12.0.0/20,10.8.0.0/14,10.4.0.0/20,10.0.0.0/14

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

Deploy the [Broker](https://submariner.io/getting-started/architecture/broker/) on cluster-a.

``` bash
gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
subctl deploy-broker
```

The command will output a file named `broker-info.subm` to the directory it is run from, which will be used to setup the
IPsec tunnel between clusters.

Verify the Broker components are installed:

```shell
$ kubectl get crds | grep submariner
clusters.submariner.io
endpoints.submariner.io
gateways.submariner.io
serviceimports.lighthouse.submariner.io

kubectl get crds --context cluster-a | grep multicluster
serviceexports.multicluster.x-k8s.io
serviceimports.multicluster.x-k8s.io

$ kubectl get ns | grep submariner

submariner-k8s-broker
```

Now it is time to register every cluster in the future `ClusterSet` to the Broker.

First join the Broker-hosting cluster itself to the Broker:

```shell
gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
subctl join broker-info.subm --clusterid cluster-a --servicecidr 10.4.0.0/20
```

Submariner will figure out most required information on its own. The `--clusterid` and `--servicecidr` flags should be used to pass the same
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

Check the DaemonSets and Deployments with the following command:

```shell
$ gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
$ kubectl get ds,deploy -n submariner-operator
NAME                                   DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                AGE
daemonset.apps/submariner-gateway      1         1         1       1            1           submariner.io/gateway=true   5m29s
daemonset.apps/submariner-routeagent   3         3         3       3            3           <none>                       5m27s

NAME                                            READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/submariner-lighthouse-agent     1/1     1            1           5m28s
deployment.apps/submariner-lighthouse-coredns   2/2     2            2           5m27s
deployment.apps/submariner-operator             1/1     1            1           5m43s
```

Now join the second cluster to the Broker:

```shell
gcloud container clusters get-credentials cluster-b --zone="europe-west3-a"
subctl join broker-info.subm --clusterid cluster-b --servicecidr 10.12.0.0/20
```

Then verify connectivity and CIDR settings within the `ClusterSet`:

```shell
$ gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
$ subctl show all
CLUSTER ID                    ENDPOINT IP     PUBLIC IP       CABLE DRIVER        TYPE
cluster-a                     10.156.0.8      34.107.75.239   libreswan           local
cluster-b                     10.156.0.13     35.242.247.43   libreswan           remote

GATEWAY                         CLUSTER                 REMOTE IP       CABLE DRIVER        SUBNETS                                 STATUS
gke-cluster-b-default-pool-e2e7 cluster-b               10.156.0.13     libreswan           10.12.0.0/20, 10.8.0.0/14               connected

NODE                            HA STATUS       SUMMARY
gke-cluster-a-default-pool-4e5f active          All connections (1) are established

COMPONENT                       REPOSITORY                                            VERSION
submariner                      quay.io/submariner                                    0.8.0-rc0
submariner-operator             quay.io/submariner                                    0.8.0-rc0
service-discovery               quay.io/submariner                                    0.8.0-rc0
$ gcloud container clusters get-credentials cluster-b --zone="europe-west3-a"
$ subctl show all
CLUSTER ID                    ENDPOINT IP     PUBLIC IP       CABLE DRIVER        TYPE
cluster-b                     10.156.0.13     35.242.247.43   libreswan           local
cluster-a                     10.156.0.8      34.107.75.239   libreswan           remote

GATEWAY                         CLUSTER                 REMOTE IP       CABLE DRIVER        SUBNETS                                 STATUS
gke-cluster-a-default-pool-4e5f cluster-a               10.156.0.8      libreswan           10.4.0.0/20, 10.0.0.0/14                connected

NODE                            HA STATUS       SUMMARY
gke-cluster-b-default-pool-e2e7 active          All connections (1) are established

COMPONENT                       REPOSITORY                                            VERSION
submariner                      quay.io/submariner                                    0.8.0-rc0
submariner-operator             quay.io/submariner                                    0.8.0-rc0
service-discovery               quay.io/submariner                                    0.8.0-rc0
```

### Workaround for KubeDNS

GKE uses KubeDNS by default for cluster-internal DNS queries. Submariner however only works with CoreDNS as of version 0.7. As a
consequence, the `*.clusterset.local` domain stub needs to be added manually to KubeDNS.
Query the ClusterIP of the `submariner-lighthouse-coredns` Service in cluster-a and cluster-b:

```shell
$ gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
$ CLUSTER_IP=$(kubectl get svc submariner-lighthouse-coredns -n submariner-operator -o=custom-columns=ClusterIP:.spec.clusterIP | tail -n +2)
$ cat <<EOF | kubectl apply -f -
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
$ gcloud container clusters get-credentials cluster-b --zone="europe-west3-a"
$ CLUSTER_IP=$(kubectl get svc submariner-lighthouse-coredns -n submariner-operator -o=custom-columns=ClusterIP:.spec.clusterIP | tail -n +2)
$ cat <<EOF | kubectl apply -f -
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

## Automated Verification

This will perform automated verifications between the clusters.

```bash
KUBECONFIG=cluster-a.yml gcloud container clusters get-credentials cluster-a --zone="europe-west3-a"
KUBECONFIG=cluster-b.yml gcloud container clusters get-credentials cluster-b --zone="europe-west3-a"
KUBECONFIG=cluster-a.yml:cluster-b.yml subctl verify --kubecontexts cluster-a,cluster-b --only service-discovery,connectivity --verbose
```

## Reconfig after Node Restart

If the GKE Nodes were at some point drained or deleted, the Submariner Pods needed to terminate.
Once the Nodes are up again, remember to

* label one Node with `kubectl label node <name> submariner.io/gateway=true` in order for the Gateway to be deployed on this Node
* apply the Node Configuration workaround again
* change the applied KubeDNS workaround to reflect the current `submariner-lighthouse-coredns` IP.

This makes Submariner functional again and work can be continued.

## Clean Up

When you're done, delete your clusters:

```shell
gcloud container clusters delete cluster-a --zone="europe-west3-a"
gcloud container clusters delete cluster-b --zone="europe-west3-a"
```
