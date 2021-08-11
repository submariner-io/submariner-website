---
title: "Uninstalling Submariner"
date: 2020-12-23T21:25:11+01:00
weight: 50
---

To properly uninstall Submariner from a cluster, follow the steps below:

{{% notice note %}}
Make sure KUBECONFIG for all participating clusters is exported and all participating clusters are accessible via kubectl.
{{% /notice %}}

1. Delete Submariner-related namespaces

   For each participating cluster, issue the following command:

   ```bash
   kubectl delete namespace submariner-operator
   ```

   For the Broker cluster, issue the following command:

   ```bash
   kubectl delete namespace submariner-k8s-broker
    ```

   For `submariner` version 0.9 and above, also delete `submariner-operator` namespace from the Broker cluster
   by issuing the following command:

   ```bash
   kubectl delete namespace submariner-operator
   ```

2. Delete the Submariner CRDs

   For each participating cluster, issue the following command:

   ```bash
   for CRD in `kubectl get crds | grep -iE 'submariner|multicluster.x-k8s.io'| awk '{print $1}'`; do kubectl delete crd $CRD; done
   ```

3. Delete Submariner's `ClusterRole`s and `ClusterRoleBinding`s

   For each participating cluster, issue the following command:

   ```bash
   roles="submariner-operator submariner-operator-globalnet submariner-lighthouse submariner-networkplugin-syncer"
   kubectl delete clusterrole,clusterrolebinding $roles --ignore-not-found
   ```

4. Remove the Submariner gateway labels

   For each participating cluster, issue the following command:

   ```bash
   kubectl label --all node submariner.io/gateway-
   ```

5. For OpenShift deployments, delete Lighthouse entry from `default` DNS.

   For each participating cluster, issue the following command:

   ```bash
   kubectl apply -f -  <<EOF
   apiVersion: operator.openshift.io/v1
   kind: DNS
   metadata:
     finalizers:
     - dns.operator.openshift.io/dns-controller
     name: default
   spec:
     servers: []
   EOF
   ```

   This deletes the lighthouse entry from the `Data` section in `Corefile` of the configmap.

   ```bash
   #lighthouse-start AUTO-GENERATED SECTION. DO NOT EDIT
   clusterset.local:53 {
       forward . 100.3.185.93
   }
   #lighthouse-end
   ```

   Verify that the lighthouse entry is deleted from `Corefile` of `dns-default` configmap by running
   following command on an OpenShift cluster

   ```bash
   kubectl describe configmap dns-default -n openshift-dns
   ```

   For Kubernetes deployments, manually edit the `Corefile` of `coredns` configmap and delete the
   lighthouse entry by issuing below commands

   ```bash
   kubectl edit cm coredns -n kube-system
   ```

   This will also restart the `coredns`. Below command can also be issued to manually restart `coredns`.

   ```bash
   kubectl rollout restart -n kube-system deployment/coredns
   ```

   Verify that the lighthouse entry is deleted from `Data` section in `Corefile` of `dns-default`
   config map by running following command on a Kubernetes cluster

   ```bash
   kubectl describe configmap coredns -n kube-system
   ```

   {{% notice note %}}
   Following commands need to be executed from inside the cluster nodes.
   {{% /notice %}}

6. Remove Submariner's iptables chains

   On all nodes in each participating cluster, issue the following commands:

   ```bash
   iptables --flush SUBMARINER-INPUT
   iptables -D INPUT $(iptables -L INPUT --line-numbers | grep SUBMARINER-INPUT | awk '{print $1}')
   iptables --delete-chain SUBMARINER-INPUT

   iptables -t nat --flush SUBMARINER-POSTROUTING
   iptables -t nat -D POSTROUTING $(iptables -t nat -L POSTROUTING --line-numbers | grep SUBMARINER-POSTROUTING | awk '{print $1}')
   iptables -t nat --delete-chain SUBMARINER-POSTROUTING

   iptables -t mangle --flush SUBMARINER-POSTROUTING
   iptables -t mangle -D POSTROUTING $(iptables -t mangle -L POSTROUTING --line-numbers | grep SUBMARINER-POSTROUTING | awk '{print $1}')
   iptables -t mangle --delete-chain SUBMARINER-POSTROUTING

   ipset destroy SUBMARINER-LOCALCIDRS
   ipset destroy SUBMARINER-REMOTECIDRS
   ```

   If Globalnet is enabled in the setup, additionally issue the following commands on gateway nodes:

   ```bash
   iptables -t nat --flush SUBMARINER-GN-INGRESS
   iptables -t nat -D PREROUTING $(iptables -t nat -L PREROUTING --line-numbers | grep SUBMARINER-GN-INGRESS | awk '{print $1}')
   iptables -t nat --delete-chain SUBMARINER-GN-INGRESS

   iptables -t nat --flush SUBMARINER-GN-EGRESS
   iptables -t nat --delete-chain SUBMARINER-GN-EGRESS

   iptables -t nat -t nat --flush SUBMARINER-GN-MARK
   iptables -t nat --delete-chain SUBMARINER-GN-MARK
   ```

7. Delete the `vx-submariner` interface

   On all nodes in each participating cluster, issue the following command:

   ```bash
   ip link delete vx-submariner
   ```

8. If Globalnet release 0.9 (or earlier) is enabled in the setup, issue the following commands to remove the
   annotations from all the Pods and Services.

   For each participating cluster, issue the following command:

   ```bash
   for ns in `kubectl get ns -o jsonpath="{.items[*].metadata.name}"`; do
       kubectl annotate pods -n $ns --all submariner.io/globalIp-
       kubectl annotate services -n $ns --all submariner.io/globalIp-
   done
   ```
