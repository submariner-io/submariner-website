---
title: "Deployment"
date: 2020-02-19T21:25:11+01:00
weight: 10
pre: "<b>2. </b>"
---

Submariner provides an [Operator](https://github.com/submariner-io/submariner-operator), a Go-based Kubernetes custom controller, for easy API-based installation and management. A command line utility, *subctl*, wraps the Operator to aid users with manual deployments and easy experimentation. subctl greatly automates and simplifies the deployment of Submariner, and is therefore the recommended deployment method. For complete information about subctl, please refer to [this page](subctl). 

In addition to Operator and subctl, Submariner also provides [Helm Charts](helm).

## Installing subctl

{{< subctl-install >}}

## Deployment of Broker

The Broker is a set of Custom Resource Definitions (CRDs) backed by the Kubernetes datastore. The Broker should be deployed on a cluster whose Kubernetes API must be accessible by all of the participating clusters:

```bash
subctl deploy-broker --kubeconfig <PATH-TO-KUBECONFIG-BROKER> 
```

This will create:

* The `submariner-k8s-broker` namespace.
* The `Endpoint` and `Cluster` CRDs in the cluster.
* A Service Account (SA) in the namespace for subsequent subctl access.

And generate the `broker-info.subm` file which contains the following elements:

* The API endpoint.
* A CA certificate for the API endpoint.
* The Service Account token for accessing the API endpoint.
* A random IPsec PSK which will be stored only in this file.
* Globalnet settings.
* Service Discovery settings.


{{% notice info %}}
The cluster in which the Broker is deployed can also participate in the dataplane connectivity with other clusters, but it will need to be joined (see following step).
{{% /notice %}}

## Joining clusters


For each cluster you want to join, issue the following command:
```bash
subctl join --kubeconfig <PATH-TO-JOINING-CLUSTER> broker-info.subm --clusterid <ID>
```

subctl will automatically discover as much as it can, and prompt the user for any missing necessary information. Note that each cluster must be configured with a unique 'clusterid' value.
