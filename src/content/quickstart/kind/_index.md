---
date: 2020-03-17T13:36:18+01:00
title: "KIND"
weight: 100
---

## KIND

[KIND](https://github.com/kubernetes-sigs/kind) is a tool to run local Kubernetes clusters inside Docker container nodes.

Submariner provides scripts that deploy 3 Kubernetes clusters locally, 1 broker and 2 data clusters with the Submariner dataplane components deployed on all the clusters.

Please note that docker must be installed and running on your computer.
To deploy the setup, clone [submariner repo](https://github.com/submariner-io/submariner) and run

`make ci e2e status=keep`

This will deploy 3 Kubernetes clusters and run basic [end-to-end tests](https://github.com/submariner-io/submariner/tree/master/test/e2e). The `status=keep` option retains the cluster setup after the tests complete.

More details can be found [here.](https://github.com/submariner-io/submariner/tree/master/scripts/kind-e2e)
