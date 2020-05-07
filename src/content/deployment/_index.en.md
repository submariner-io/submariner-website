---
title: "Deployment"
date: 2020-02-19T21:25:11+01:00
weight: 10
pre: "<b>2. </b>"
---

The inner details of deploying a broker and connecting clusters to the broker are complicated, subctl automates and simplifies most of those details eliminating human error as much as possible. This is why **subctl** is the recommended deployment method, you can find a complete guide to the subctl tool here: [subctl in detail](subctl). If you still believe _helm_ works better for you, please go [here](helm).

## Installing subctl

{{< subctl-install >}}

## Deployment of broker

Please remember, this cluster's API should be accessible from all other clusters:
```bash
subctl deploy-broker --kubeconfig <PATH-TO-KUBECONFIG-BROKER> 
```

this will create:

* The submariner-k8s-broker namespace
* The Cluster and Endpoint (.submariner.io) CRDs in the cluster
* A service account in the namespace for subsequent subctl access.

And generate a broker-info.subm file which contains the following elements:

* The API endpoint
* A CA certificate to for the API endpoint
* The service account token for accessing the API endpoint / submariner-k8s-broker namespace.
* A random IPSEC PSK which will be stored only in this file.
* Globalnet settings
* Service discovery settings


{{% notice info %}}
This cluster can also participate in the dataplane connectivity with the other clusters, but it will need to be joined (see following step)
{{% /notice %}}

## Joining clusters


For each cluster you want to join:
```bash
subctl join --kubeconfig <PATH-TO-JOINING-CLUSTER> broker-info.subm
```

subctl will discover as much as it can, and ask you for any necessary detail it can't figure out like the cluster ID which has to be different between all clusters.


## Discovery

Service discovery (via DNS and lighthouse project) is an experimental feature (developer preview), and the instructions to deploy with discovery can be found [here](with-discovery/)
