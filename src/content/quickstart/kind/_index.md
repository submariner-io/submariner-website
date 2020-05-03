---
date: 2020-03-17T13:36:18+01:00
title: "KIND"
weight: 100
---

## KIND

[KIND](https://github.com/kubernetes-sigs/kind) is a tool to run local Kubernetes clusters inside Docker container nodes.
Please note that Docker must be installed and running on your computer.

Submariner provides (via [Shipyard](https://github.com/submariner-io/shipyard)) scripts that deploy 3 Kubernetes clusters locally - 1 broker and 2 data clusters with the Submariner dataplane components deployed on all the clusters.

### Deploying a Basic Environment

If you wish to deploy just a basic 3 cluster environment, clone the [shipyard repo](https://github.com/submariner-io/shipyard) and run

`make deploy`

At the end of the deployment you'll have a very basic environment that you can experiment with.

### Deploying Like a Submariner

To deploy the environment like Submariner does it, clone the [submariner repo](https://github.com/submariner-io/submariner) and run

`make e2e`

This will deploy 3 Kubernetes clusters and run basic [end-to-end tests](https://github.com/submariner-io/submariner/tree/master/test/e2e). The environment will be available after the tests complete.

More details can be found [here.](https://github.com/submariner-io/submariner/tree/master/scripts/kind-e2e)
