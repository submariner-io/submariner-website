---
date: 2021-08-11T12:33:18+01:00
title: "External Network (Experimental)"
weight: 50
---

This guide covers experimenting with the external network use case.
In this use case, pods running in a Kubernetes cluster can access external applications outside of the cluster and vice versa
by using DNS resolution supported by Lighthouse or manually using the Globalnet ingress IPs.
In addition to providing connectivity, the source IP of traffic is also preserved.

{{% notice warning %}}
**This feature is experimental.** The configuration mechanism and observed behavior may change.
{{% /notice %}}

### Prerequisites

1. Prepare:
    - Two or more Kubernetes clusters
    - One or more non-cluster hosts that exist in the same network segment to one of the Kubernetes clusters

    In this guide, we will use the following Kubernetes clusters and non-cluster host.

    | Name      | IP              | Description         |
    |-----------|-----------------|---------------------|
    | cluster-a | 192.168.122.26  | Single-node cluster |
    | cluster-b | 192.168.122.27  | Single-node cluster |
    | test-vm   | 192.168.122.142 | Linux host          |

    In this example, everything is deployed in the 192.168.122.0/24 segment.
    However, it is only required that cluster-a and test-vm are in the same segment.
    Other clusters, cluster-b and any additional clusters, can be deployed in different segments or even in any other networks in the internet.
    Also, clusters can be multi-node clusters.

    Subnets of non-cluster hosts should be distinguished from those of the clusters to easily specify the external network CIDR.
    In this example, cluster-a and cluster-b belong to 192.168.122.0/25 and test-vm belongs to 192.168.122.128/25.
    Therefore, the external network CIDR for this configuration is 192.168.122.128/25.
    In test environments with just one host, an external network CIDR like 192.168.122.142/32 can be specified.
    However, design of the subnets need to be considered when more hosts are used.

2. Choose the Pod CIDR and the Service CIDR for Kubernetes clusters and deply them.

    In this guide, we will use the following CIDRs:

    | Cluster   | Pod CIDR     | Service CIDR |
    |-----------|--------------|--------------|
    | cluster-a |10.42.0.0/24  |10.43.0.0/16  |
    | cluster-b |10.42.0.0/24  |10.43.0.0/16  |

    Note that we will use Globalnet in this guide, therefore overlapping CIDRs are supported.
    One of the easiest way to create this environment will be to deploy two K3s clusters by the steps described
    [here](https://submariner.io/getting-started/quickstart/k3s/) until "Deploy cluster-b on node-b",
    with modifying deploy commands to just `curl -sfL https://get.k3s.io | sh -` to use default CIDR.

{{% notice note %}}
In this configuration, global IPs are used to access between the gateway node and non-cluster hosts,
which means packets are sent to IP addresses that are not part of the actual network segment.
To make such packets not to be dropped, anti-spoofing rules need to be disabled for the hosts and the gateway node.
{{% /notice %}}

### Setup Submariner

#### Ensure kubeconfig files

Ensure that kubeconfig files for both clusters are available.
This guide assumes cluster-a's kubeconfig file is named `kubeconfig.cluster-a` and cluster-b's is named `kubeconfig.cluster-b`.

#### Install `subctl`

{{% subctl-install %}}

#### Use cluster-a as the Broker with Globalnet enabled

```bash
subctl deploy-broker --kubeconfig kubeconfig.cluster-a --globalnet
```

#### Label gateway nodes

When Submariner joins a cluster to the broker via the `subctl join` command, it chooses a node on which to install the
gateway by labeling it appropriately. By default, Submariner uses a worker node for the gateway; if there are no worker
nodes, then no gateway is installed unless a node is manually labeled as a gateway. Since we are deploying k3s all-in-one
nodes, there are no worker nodes, so it is necessary to label the single node as a gateway. By default, the node name is
the hostname. In this example, the hostnames are "cluster-a" and "cluster-b", respectively.

Execute the following on cluster-a:

```bash
kubectl label node cluster-a submariner.io/gateway=true
```

Execute the following on cluster-b:

```bash
kubectl label node cluster-b submariner.io/gateway=true
```

#### Join cluster-a to the Broker with external CIDR added as cluster CIDR

Carefully review the `CLUSTER_CIDR` and `EXTERNAL_CIDR` and run:

```bash
CLUSTER_CIDR=10.42.0.0/24
EXTERNAL_CIDR=192.168.122.128/25
subctl join --kubeconfig kubeconfig.cluster-a broker-info.subm --clusterid cluster-a --natt=false --clustercidr=${CLUSTER_CIDR},${EXTERNAL_CIDR}
```

#### Join cluster-b to the Broker

```bash
subctl join --kubeconfig kubeconfig.cluster-b broker-info.subm --clusterid cluster-b --natt=false
```

#### Deploy DNS server on cluster-a for non-cluster hosts

Create a list of upstream DNS servers as `upstreamservers`:

Note that `dnsip` is the IP of DNS server for the test-vm, which is defined as `nameserver` in `/etc/resolve.conf`.

```bash
dnsip=192.168.122.1
lighthousednsip=$(kubectl get svc --kubeconfig kubeconfig.cluster-a -n submariner-operator submariner-lighthouse-coredns -o jsonpath='{.spec.clusterIP}')

cat << EOF > upstreamservers
server=/svc.clusterset.local/$lighthousednsip
server=$dnsip
EOF
```

Create configmap of the list:

```bash
export KUBECONFIG=kubeconfig.cluster-a
kubectl create configmap external-dnsmasq -n submariner-operator --from-file=upstreamservers
```

Create a `dns.yaml` as follows:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-cluster-a
  namespace: submariner-operator
  labels:
    app: external-dns-cluster-a
spec:
  replicas: 1
  selector:
    matchLabels:
      app: external-dns-cluster-a
  template:
    metadata:
      labels:
        app: external-dns-cluster-a
    spec:
      containers:
      - name: dnsmasq
        image: registry.access.redhat.com/ubi8/ubi-minimal:latest
        ports:
        - containerPort: 53
        command: [ "/bin/sh", "-c", "microdnf install -y dnsmasq; ln -s /upstreamservers /etc/dnsmasq.d/upstreamservers; dnsmasq -k" ]
        securityContext:
          capabilities:
            add: ["NET_ADMIN"]
        volumeMounts:
        - name: upstreamservers
          mountPath: /upstreamservers
      volumes:
        - name: upstreamservers
          configMap:
            name: external-dnsmasq
---
apiVersion: v1
kind: Service
metadata:
  namespace: submariner-operator
  name: external-dns-cluster-a
spec:
  ports:
  - name: udp
    port: 53
    protocol: UDP
    targetPort: 53
  selector:
    app: external-dns-cluster-a
```

Use this YAML to create DNS server, and assign global ingress IP:

```bash
kubectl apply -f dns.yaml
subctl export service -n submariner-operator external-dns-cluster-a
```

Check global ingress IP:

```bash
kubectl --kubeconfig kubeconfig.cluster-a get globalingressip external-dns-cluster-a -n submariner-operator
NAME                     IP
external-dns-cluster-a   242.0.255.251
```

### Set up non-cluster hosts

Modify routing for global CIDR on test-vm:

Note that `subm_gw_ip` is the gateway node IP of the cluster in the same network segment of the hosts.
In the case of the example of this guide, it is the node IP of cluster-a.
Also, 242.0.0.0/8 is the default globalCIDR.

```bash
subm_gw_ip=192.168.122.26
ip r add 242.0.0.0/8 via ${subm_gw_ip}
```

To persist above configuration across reboot, check the document for each Linux distribution.
For example, on Centos 7, to set presistent route for eth0, below command is required:

```bash
echo "242.0.0.0/8 via ${subm_gw_ip} dev eth0" >> /etc/sysconfig/network-scripts/route-eth0
```

Modify `/etc/resolv.conf` to change DNS server for the host on test-vm:

For example)

- Before:

```bash
nameserver 192.168.122.1
```

- After:

```bash
nameserver 242.0.255.251
```

Check that the DNS server itself can be resolved:

```bash
nslookup external-dns-cluster-a.submariner-operator.svc.clusterset.local
Server:         242.0.255.251
Address:        242.0.255.251#53

Name:   external-dns-cluster-a.submariner-operator.svc.clusterset.local
Address: 10.43.162.46
```

### Verify Deployment

#### Verify Manually

##### Deploy HTTP server on hosts

Run on test-vm:

```bash
# Python 2.x:
python -m SimpleHTTPServer 80
# Python 3.x:
python -m http.server 80
```

##### Verify access to External hosts from clusters

Create Service, Endpoints, ServiceExport to access the test-vm from cluster-a:

Note that `Endpoints.subsets.addresses` needs to be modified to IP of test-vm.

```bash
export KUBECONFIG=kubeconfig.cluster-a
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: test-vm
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
EOF

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Endpoints
metadata:
  name: test-vm
subsets:
  - addresses:
      - ip: 192.168.122.142
    ports:
      - port: 80
EOF

subctl export service -n default test-vm
```

Check global ingress IP for test-vm, on cluster-a:

```bash
kubectl get globalingressip test-vm
NAME      IP
test-vm   242.0.255.253
```

Verify access to test-vm from clusters:

```bash
export KUBECONFIG=kubeconfig.cluster-a
kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- bash
curl 242.0.255.253
```

```bash
export KUBECONFIG=kubeconfig.cluster-b
kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- bash
curl 242.0.255.253
```

On test-vm, check the console log of HTTP server that there are accesses from pods

{{% notice note %}}
Currently, __headless__ service without selector is not supported for Globalnet,
therefore service without selector needs to be used.
This feature is under discussion in [#1537](https://github.com/submariner-io/submariner/issues/1537).
{{% /notice %}}

{{% notice note %}}
Currently, DNS resolution for service without selector is not supported,
therefore global IPs need to be used to access to the external hosts.
This feature is under discussion in [#603](https://github.com/submariner-io/lighthouse/issues/603).
Note that there is a workaround to make it resolvable by manually creating endpointslice, as described [here](https://github.com/submariner-io/lighthouse/issues/603#issuecomment-901944297).
{{% /notice %}}

##### Verify access to Deployment from non-cluster hosts

Create Deployment in cluster-b:

```bash
export KUBECONFIG=kubeconfig.cluster-b
kubectl -n default create deployment nginx --image=k8s.gcr.io/nginx-slim:0.8
kubectl -n default expose deployment nginx --port=80
subctl export service --namespace default nginx
```

From test-vm, verify access:

```bash
curl nginx.default.svc.clusterset.local
```

Check the console log of HTTP server that there is access from test-vm:

```bash
kubectl logs -l app=nginx
```

##### Verify access to Statefulset from non-cluster hosts

A `StatefulSet` uses a headless `Service`. Create a `web.yaml` file as follows:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ss
  labels:
    app.kubernetes.io/instance: nginx-ss
    app.kubernetes.io/name: nginx-ss
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app.kubernetes.io/instance: nginx-ss
    app.kubernetes.io/name: nginx-ss
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx-ss"
  replicas: 2
  selector:
    matchLabels:
        app.kubernetes.io/instance: nginx-ss
        app.kubernetes.io/name: nginx-ss
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: nginx-ss
        app.kubernetes.io/name: nginx-ss
    spec:
      containers:
      - name: nginx-ss
        image: k8s.gcr.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
```

Apply the above YAML to create a web `StatefulSet` with nginx-ss as the headless service:

```bash
export KUBECONFIG=kubeconfig.cluster-b
kubectl -n default apply -f web.yaml
subctl export service -n default nginx-ss
```

From test-vm, verify access:

```bash
curl nginx-ss.default.svc.clusterset.local
curl cluster-b.nginx-ss.default.svc.clusterset.local
curl web-0.cluster-b.nginx-ss.default.svc.clusterset.local
curl web-1.cluster-b.nginx-ss.default.svc.clusterset.local
```

Check the console log of the HTTP server to verify there are accesses from test-vm:

```bash
kubectl logs web-0
kubectl logs web-1
```

##### Verify source IP of the access from Statefulset

Confirm the global egress IPs for each pod managed by Statefulset:

- From Cluster:

```bash
export KUBECONFIG=kubeconfig.cluster-b
kubectl get globalingressip | grep web
pod-web-0     242.1.255.251
pod-web-1     242.1.255.250
```

- From Hosts:

```bash
nslookup web-0.cluster-b.nginx-ss.default.svc.clusterset.local
Server:         242.0.255.251
Address:        242.0.255.251#53

Name:   web-0.cluster-b.nginx-ss.default.svc.clusterset.local
Address: 242.1.255.251

nslookup web-1.cluster-b.nginx-ss.default.svc.clusterset.local
Server:         242.0.255.251
Address:        242.0.255.251#53

Name:   web-1.cluster-b.nginx-ss.default.svc.clusterset.local
Address: 242.1.255.250
```

Verify the source IP of each access from each pod to test-vm is the same to its global egress IP:

- Access from web-0

```bash
export KUBECONFIG=kubeconfig.cluster-b
kubectl exec -it web-0 -- bash
curl 242.0.255.253
exit
```

- Access from web-1

```bash
export KUBECONFIG=kubeconfig.cluster-b
kubectl exec -it web-1 -- bash
curl 242.0.255.253
exit
```

- Check the console log in test-vm
