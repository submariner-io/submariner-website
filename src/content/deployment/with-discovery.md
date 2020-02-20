---
title: "With Discovery (experimental)"
date: 2020-02-20T16:40:57+01:00
---


Deployment with discovery will include the ([lighthouse](https://github.com/submariner-io/lighthouse) components.

{{% notice warning %}}
 **Project status**: The Lighthouse project is meant only to be used as a development preview. Installing the operator on an Openshift cluster may disable some of the operator features.
{{% /notice %}}

The [Lighthouse](https://github.com/submariner-io/lighthouse) project helps in cross-cluster service discovery. It has the below **additional dependencies**

- kubefedctl installed ([0.1.0-rc3](https://github.com/kubernetes-sigs/kubefed/releases/tag/v0.1.0-rc3)).
- kubectl installed.

### To deploy Submariner with Lighthouse follow the below steps

#### Deploy Broker

```
subctl deploy-broker --kubeconfig <PATH-TO-KUBECONFIG-BROKER> --service-discovery --broker-cluster-context <BROKER-CONTEXT-NAME>
```

kubefed will be installed in the broker cluster, as lighthouse currently depends on it for resource distribution. Such dependency will be eliminated in the future.

#### Join Clusters

To join all the other clusters with the broker cluster run using the broker-info.subm generated in the folder from which the previous step was run.

{{% notice info %}}
You will need a kubeconfig file with multiple contexts, a default admin context pointing to
the cluster you're trying to join, and another context which provides access to the broker
cluster from the previous step. This is a requirement from kubefedctl.
{{% /notice %}}

```
subctl join --kubeconfig <PATH-TO-KUBECONFIG-DATA-CLUSTER> broker-info.subm  --broker-cluster-context <BROKER-CONTEXT-NAME>
```

As for a normal deployment, subctl will try to figure out all necessary information and will
ask for anything it can't figure out.

