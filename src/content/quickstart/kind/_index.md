---
date: 2020-03-17T13:36:18+01:00
title: "KIND (Local Environment)"
weight: 100
---

## Locally Testing With KIND

[KIND](https://github.com/kubernetes-sigs/kind) is a tool to run local Kubernetes clusters inside Docker container nodes.

Submariner provides (via [Shipyard](../../contributing/shipyard)) scripts that deploy 3 Kubernetes clusters locally - 1 broker and 2 data clusters with the Submariner dataplane components deployed on all the clusters.

{{% notice note %}}
Docker must be installed and running on your computer.
{{% /notice %}}

### Deploying a Basic Environment

If you wish to deploy just a basic multi cluster environment, run:

```bash
git clone https://github.com/submariner-io/shipyard
cd shipyard
make deploy
```

At the end of the deployment you'll have a very basic environment that you can experiment with.

### Deploying Like a Submariner

To deploy the environment like Submariner does it, run:

```bash
git clone https://github.com/submariner-io/submariner
cd submariner
make e2e
```

This will deploy 3 Kubernetes clusters and run basic [end-to-end tests](https://github.com/submariner-io/submariner/tree/master/test/e2e). The environment will remain available after the tests complete.

More details on testing can be found in the [testing guide](../../contributing/building_testing).
