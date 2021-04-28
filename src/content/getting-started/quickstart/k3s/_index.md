---
date: 2021-02-24T13:36:18+01:00
title: "K3s"
weight: 15
---

This quickstart guide covers the necessary steps to deploy two [K3s](https://k3s.io/) clusters
and deploy Submariner with Service Discovery to interconnect the two clusters. Note that this
guide focuses on Submariner deployment on clusters with non-overlapping Pod and Service CIDRs.
For connecting clusters with overlapping CIDRs, please refer to the
[Globalnet guide](../../architecture/globalnet/).

### Prerequisites

1. Prepare two nodes with
[K3s-supported OS](https://rancher.com/docs/k3s/latest/en/installation/installation-requirements/#operating-systems)
installed (These two nodes are referred to as node-a and node-b).
2. Choose the Pod CIDR and the Service CIDR for each K3s cluster.

    In this guide, we will use the following CIDRs:

    | Cluster   | Pod CIDR     | Service CIDR |
    |-----------|--------------|--------------|
    | cluster-a |10.44.0.0/16  |10.45.0.0/16  |
    | cluster-b |10.144.0.0/16 |10.145.0.0/16 |

### Deploy K3s Clusters

#### Deploy cluster-a on node-a

In this step you will deploy K3s on node-a using the the **cluster-a** CIDRs.

```bash
POD_CIDR=10.44.0.0/16
SERVICE_CIDR=10.45.0.0/16
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--cluster-cidr $POD_CIDR --service-cidr $SERVICE_CIDR" sh -s -
```

{{% notice tip %}}
For more information on interacting with K3s, please refer to the [k3s documentation](https://rancher.com/docs/k3s/latest/en/quick-start/).
{{% /notice %}}

The kubeconfig file needs to be modified to set the Kubernetes API endpoint to the public IP of node-a,
which is obtained from the first field yielded by `hostname -I`, and to give the context a name other
than “default”. (This uses [yq](https://github.com/mikefarah/yq/) v4.7.0 or later.)

```bash
cp /etc/rancher/k3s/k3s.yaml kubeconfig.cluster-a
export IP=$(hostname -I | awk '{print $1}')
yq -i eval \
'.clusters[].cluster.server |= sub("127.0.0.1", env(IP)) | .contexts[].name = "cluster-a" | .current-context = "cluster-a"' \
kubeconfig.cluster-a
```

#### Deploy cluster-b on node-b

In this step you will deploy K3s on node-b using the the **cluster-b** CIDRs.

```bash
POD_CIDR=10.144.0.0/16
SERVICE_CIDR=10.145.0.0/16
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--cluster-cidr $POD_CIDR --service-cidr $SERVICE_CIDR" sh -s -
```

The kubeconfig file needs to be modified to set the Kubernetes API endpoint to the public IP of node-b,
which is obtained from the first field yielded by `hostname -I`, and to give the context a name other
than “default”.

```bash
cp /etc/rancher/k3s/k3s.yaml kubeconfig.cluster-b
export IP=$(hostname -I | awk '{print $1}')
yq -i eval \
'.clusters[].cluster.server |= sub("127.0.0.1", env(IP)) | .contexts[].name = "cluster-b" | .current-context = "cluster-b"' \
kubeconfig.cluster-b
```

Next, copy kubeconfig.cluster-b to node-a.

#### Install `subctl` on node-a

{{< subctl-install >}}

#### Use cluster-a as the Broker

On node-a, run:

```bash
subctl deploy-broker --kubeconfig kubeconfig.cluster-a --service-discovery
```

#### Join cluster-a to the Broker

```bash
subctl join --kubeconfig kubeconfig.cluster-a broker-info.subm --clusterid cluster-a --natt=false
```

#### Join cluster-b to the Broker

```bash
subctl join --kubeconfig kubeconfig.cluster-b broker-info.subm --clusterid cluster-b --natt=false
```

### Verify Deployment

#### Verify Automatically with `subctl`

This will perform automated verifications between the clusters.

<!-- markdownlint-disable line-length -->
```bash
KUBECONFIG=kubeconfig.cluster-a:kubeconfig.cluster-b subctl verify --kubecontexts cluster-a,cluster-b --only service-discovery,connectivity --verbose
```
<!-- markdownlint-enable line-length -->

#### Verify Manually

To manually verify the deployment, follow the steps below using either a headless or ClusterIP `nginx` service deployed in `cluster-b`.

##### Deploy ClusterIP Service

```bash
kubectl --kubeconfig kubeconfig.cluster-b create deployment nginx --image=nginx
kubectl --kubeconfig kubeconfig.cluster-b expose deployment nginx --port=80
subctl export service --kubeconfig kubeconfig.cluster-b --namespace default nginx
```

##### Verify

Run `nettest` from `cluster-a` to access the `nginx` service:

```bash
kubectl --kubeconfig kubeconfig.cluster-a -n default  run --generator=run-pod/v1 \
tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.clusterset.local
```
