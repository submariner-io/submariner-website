---
title: "With Discovery (experimental)"
date: 2020-02-20T16:40:57+01:00
---


Deployment with discovery will include the ([lighthouse](https://github.com/submariner-io/lighthouse) components.

{{% notice warning %}}
 **Project status**: The Lighthouse project is meant only to be used as a development preview. Installing the operator on an Openshift cluster may disable some of the operator features.
{{% /notice %}}

The [Lighthouse](https://github.com/submariner-io/lighthouse) project helps in cross-cluster service discovery. It has the below **additional dependencies**

- kubectl installed.

### Deploying Submariner with Lighthouse

#### Deploy Broker

```
subctl deploy-broker --kubeconfig <PATH-TO-KUBECONFIG-BROKER> --service-discovery
```

#### Join Clusters

To join all the other clusters with the broker cluster, run subctl using the broker-info.subm generated in the folder from which the previous step was run.

```
subctl join --kubeconfig <PATH-TO-KUBECONFIG-DATA-CLUSTER> broker-info.subm
```

As for a normal deployment, subctl will try to figure out all necessary information and will
ask for anything it can't figure out.
