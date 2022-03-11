+++
title =  "Calico CNI"
weight = 30
+++

Typically, the Kubernetes network plugin (based on kube-proxy) programs iptables rules for Pod
networking within a cluster. When a Pod in a cluster tries to access an external IP, the plugin
performs specific Network Address Translation (NAT) manipulation on the traffic as it does not
belong to the local cluster. Similarly, Submariner also programs certain iptables rules and it
requires these rules to be applied prior to the ones programmed by the network plugin.
Submariner tries to preserve the source IP of the Pods for cross-cluster communication for visibility,
ease of debugging, and security purposes.

On clusters deployed with Calico as the network plugin, the rules inserted by Calico take
precedence over Submariner, causing issues with cross-cluster communication.
To make Calico compatible with Submariner, it needs to be configured, via IPPools,
not to perform NAT on the subnets associated with the Pod and Service CIDRs of the remote clusters.
Once the IPPools are configured in the clusters, Calico will not perform NAT for the configured CIDRs
and allows Submariner to support cross-cluster connectivity.

{{% notice note %}}
When using [Submariner Globalnet](../../../getting-started/architecture/globalnet) with Calico, please avoid the default
Globalnet CIDR (i.e., 242.0.0.0/8) as it is used internally within Calico. You can explicitly specify
a non-overlapping Globalnet CIDR while deploying Submariner.
{{% /notice %}}

As an example, consider two clusters, East and West, deployed with the Calico network plugin
and connected via Submariner. For cluster East, the Service CIDR is 100.93.0.0/16 and the Pod CIDR is
10.243.0.0/16. For cluster West, they are 100.92.0.0/16 and 10.242.0.0/16. The following IPPools
should be created:

On East Cluster:

```bash
$ cat > svcwestcluster.yaml <<EOF
  apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: svcwestcluster
  spec:
    cidr: 100.92.0.0/16
    natOutgoing: false
    disabled: true
  EOF

  cat > podwestcluster.yaml <<EOF
  apiVersion: projectcalico.org/v3
  kind: IPPool
  metadata:
    name: podwestcluster
  spec:
    cidr: 10.242.0.0/16
    natOutgoing: false
    disabled: true
  EOF

DATASTORE_TYPE=kubernetes KUBECONFIG=<kubeconfig-eastcluster.yaml> calicoctl create -f svcwestcluster.yaml
DATASTORE_TYPE=kubernetes KUBECONFIG=<kubeconfig-eastcluster.yaml> calicoctl create -f podwestcluster.yaml
```

On West Cluster:

```bash
cat > svceastcluster.yaml <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: svceastcluster
spec:
  cidr: 100.93.0.0/16
  natOutgoing: false
  disabled: true
EOF

cat > podeastcluster.yaml <<EOF
apiVersion: projectcalico.org/v3
kind: IPPool
metadata:
  name: podeastcluster
spec:
  cidr: 10.243.0.0/16
  natOutgoing: false
  disabled: true
EOF

DATASTORE_TYPE=kubernetes KUBECONFIG=<kubeconfig-westcluster.yaml> calicoctl create -f svceastcluster.yaml
DATASTORE_TYPE=kubernetes KUBECONFIG=<kubeconfig-westcluster.yaml> calicoctl create -f podeastcluster.yaml
```
