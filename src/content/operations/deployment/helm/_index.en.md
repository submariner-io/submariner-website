---
title: "Helm"
date: 2020-02-19T21:25:43+01:00
weight: 20
---

## Deploying with Helm

### Installing Helm

The latest Submariner charts require Helm 3; once you have that, run

```bash
export KUBECONFIG=<kubeconfig-of-broker>
helm repo add submariner-latest https://submariner-io.github.io/submariner-charts/charts
```

### Exporting environment variables needed later

```bash
export BROKER_NS=submariner-k8s-broker
export SUBMARINER_NS=submariner-operator
export SUBMARINER_PSK=$(LC_CTYPE=C tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 64 | head -n 1)
```

### Deploying the Broker

```bash
helm install "${BROKER_NS}" submariner-latest/submariner-k8s-broker \
             --create-namespace \
             --namespace "${BROKER_NS}" \
             --set submariner.serviceDiscovery=true
```

Setup more environment variables we will need later for joining clusters.

```bash
export SUBMARINER_BROKER_CA=$(kubectl -n "${BROKER_NS}" get secrets \
    -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='${BROKER_NS}-client')].data['ca\.crt']}")
export SUBMARINER_BROKER_TOKEN=$(kubectl -n "${BROKER_NS}" get secrets \
    -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='${BROKER_NS}-client')].data.token}" \
       | base64 --decode)
export SUBMARINER_BROKER_URL=$(kubectl -n default get endpoints kubernetes \
    -o jsonpath="{.subsets[0].addresses[0].ip}:{.subsets[0].ports[?(@.name=='https')].port}")
```

### Joining a cluster

This step needs to be repeated for every cluster you want to connect with Submariner.

```bash
export KUBECONFIG=kubeconfig-of-the-cluster-to-join
export CLUSTER_ID=the-id-of-the-cluster
export CLUSTER_CIDR=x.x.x.x/x   # the cluster's Pod IP CIDR
export SERVICE_CIDR=x.x.x.x/x   # the cluster's Service IP CIDR
```

If your clusters have overlapping IPs (Cluster/Service CIDRs), please set:

```bash
export GLOBALNET=true
export GLOBAL_CIDR=169.254.x.x/x # using an individual non-overlapping
                                 # range for each cluster you join.
```

Joining the cluster:

```bash
helm install submariner-operator submariner-latest/submariner-operator \
        --create-namespace \
        --namespace "${SUBMARINER_NS}" \
        --set ipsec.psk="${SUBMARINER_PSK}" \
        --set broker.server="${SUBMARINER_BROKER_URL}" \
        --set broker.token="${SUBMARINER_BROKER_TOKEN}" \
        --set broker.namespace="${BROKER_NS}" \
        --set broker.ca="${SUBMARINER_BROKER_CA}" \
        --set submariner.cableDriver=libreswan \ # or wireguard
        --set submariner.clusterId="${CLUSTER_ID}" \
        --set submariner.clusterCidr="${CLUSTER_CIDR}" \
        --set submariner.serviceCidr="${SERVICE_CIDR}" \
        --set submariner.globalCidr="${GLOBAL_CIDR}" \
        --set serviceAccounts.globalnet.create="${GLOBALNET}" \
        --set submariner.natEnabled="true" \  # disable this if no NAT will happen between gateways
        --set brokercrd.create=false \
        --set submariner.serviceDiscovery=true \
        --set serviceAccounts.lighthouse.create=true
```

Some image override settings you could use

```bash
        --set operator.image.repository="localhost:5000/submariner-operator" \
        --set operator.image.tag="local" \
        --set operator.image.pullPolicy="IfNotPresent"
```

If installing on OpenShift, please also add the Submariner service accounts (SAs) to the
privileged Security Context Constraint.

```bash
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-routeagent
oc adm policy add-scc-to-user privileged system:serviceaccount:submariner:submariner-engine
```

## Perform automated verification

Automated verification of the deployment can be performed by using the verification
tests embedded in the `subctl` command line tool via the `subctl verify` command.

### Install `subctl`

{{< subctl-install >}}

### Run the verification

Ensure your kubeconfigs have different context names for each cluster, _e.g._ “cluster-a” and “cluster-b”;
then run

```bash
KUBECONFIG=cluster-a/auth/kubeconfig:cluster-b/auth/kubeconfig subctl verify --kubecontexts cluster-a,cluster-b --verbose
```
