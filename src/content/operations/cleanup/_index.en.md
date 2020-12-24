---
title: "Uninstalling Submariner"
date: 2020-12-23T21:25:11+01:00
weight: 20
---

To properly uninstall Submariner from a cluster, follow the steps below.

1. Delete Submariner related namespaces:

    On data cluster,
    ```bash
    kubectl delete namespace submariner-operator
    ```
    On broker cluster,
    ```bash
    kubectl delete namespace submariner-k8s-broker
    ```

2. Deleting submariner CRDs in the cluster
    ```bash
    for CRD in `kubectl get crds | grep -iE 'submariner|multicluster.x-k8s.io'| awk '{print $1}'`; do kubectl delete crd $CRD; done
    ```

3. Delete iptable chains, `SUBMARINER-INPUT` and `SUBMARINER-POSTROUTING`, that Submariner created.
    On all nodes, delete `SUBMARINER-INPUT`
    ```bash
    iptables --flush SUBMARINER-INPUT
    iptables -D INPUT $(iptables -L INPUT --line-numbers | grep SUBMARINER-INPUT | awk '{print $1}')
    iptables --delete-chain SUBMARINER-INPUT
    ```
    Follow same commands for `SUBMARINER-POSTROUTING` chain.
      
    If Globalnet is enabled in the setup, delete iptable chains `SUBMARINER-GN-INGRESS`, `SUBMARINER-GN-EGRESS` and `SUBMARINER-GN-MARK` too following the same commands as above.
    
    Note that KIND based setup will have just `SUBMARINER-INPUT` chain.

4. Delete vx-submariner interface from all the nodes
    ```bash
    ip link delete vx-submariner
    ```

5. Remove submariner gateway labels
    ```bash
    kubectl label --all node submariner.io/gateway-
    ```