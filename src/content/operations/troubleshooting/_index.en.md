+++
title = "Troubleshooting"
date = 2020-05-04T19:01:14+05:30
weight = 30
+++

## Overview

You have followed steps in [Deployment](../deployment) but something has gone wrong. You're not sure what and how to fix it, or what
information to collect to raise an issue. Welcome to the Submariner troubleshooting guide where we will help you get your deployment working
again.

Basic familiarity with the Submariner components and architecture will be helpful when troubleshooting so please review the
[Architecture](../../getting-started/architecture) section.

The guide has been broken into different sections for easy navigation.

## Automated Troubleshooting

Use the `subctl` utility to automate troubleshooting and collecting debugging information.

Install subctl:

```shell
curl -Ls https://get.submariner.io | VERSION=<your Submariner version> bash
```

Set `KUBECONFIG` to point at your clusters:

```shell
export KUBECONFIG=<kubeconfig0 path>:<kubeconfig1 path>
```

Show overview of, and diagnose issues with, each cluster:

```shell
subctl show all
subctl diagnose all
```

Diagnose common firewall issues between a pair of clusters:

```shell
subctl diagnose firewall inter-cluster <kubeconfig0 path> <kubeconfig1 path>
```

{{% notice info %}}
[Merged KUBECONFIGs are currently not supported by `subctl diagnose firewall`](https://github.com/open-cluster-management/backlog/issues/17196).
{{% /notice %}}

Collect details about an issue you'd like help with:

```shell
subctl gather
tar cfz submariner-<timestamp>.tar.gz submariner-<timestamp>
```

When reporting an issue, it may also help to include the information in the
[`bug-report.md` template](https://github.com/submariner-io/submariner/issues/new?assignees=&labels=bug&template=bug-report.md).

## Manual Troubleshooting

### Pre-requisite

Before we begin troubleshooting, run `subctl version` to obtain which version of the Submariner components you are running.

Run `kubectl get services -n <service-namespace> | grep <service-name>` to get information about the service you're trying to access. This
will provide you with the Service *Name*, *Namespace* and *ServiceIP*. If **Globalnet** is enabled, you will also need the *globalIp* of the
service by running

`kubectl get globalingressip <service-name>'`

<!---

### Deployment Issues

This section will contain information about common deployment issues you can run into.

#### TBD

-->

### Connectivity Issues

Submariner deployment completed successfully but Services/Pods on one cluster are unable to connect to Services on another cluster. This can
be due to multiple factors outlined below.

#### Check the Connection Statistics

If you are unable to connect to a remote cluster, check its connection status in the Gateway resource.

`kubectl describe Gateway -n submariner-operator`

Sample output:

```yaml
   - endpoint:
        backend: libreswan
        cable_name: submariner-cable-cluster1-172-17-0-7
        cluster_id: cluster1
        healthCheckIP: 10.1.128.0
        hostname: cluster1-worker
        nat_enabled: false
        private_ip: 172.17.0.7
        public_ip: ""
        subnets:
        - 100.1.0.0/16
        - 10.1.0.0/16
      latencyRTT:
        average: 447.358µs
        last: 281.577µs
        max: 5.80437ms
        min: 158.725µs
        stdDev: 364.154µs
      status: connected
      statusMessage: Connected to 172.17.0.7:4500 - encryption alg=AES_GCM_16, keysize=128
        rekey-time=13444
```

The Gateway Engine uses the `Health Check IP` of the endpoint to verify connectivity.
The connection `Status` will be marked as `error`, if it cannot reach this IP,
and the `Status Message` will provide more information about the possible failure reason.
It also provides the statistics for the connection.

<!---
#### IPSec tunnel not created between clusters

TBD

#### IPSEc tunnel is not up between clusters

TBD

#### None of pods/services able to connect to remote service

TBD

##### Without Globalnet

TBD

##### With Globalnet

TBD

#### Pods on non-gateway nodes not able to connect to remote service

TBD

##### Without Globalnet

TBD

##### With Globalnet

TBD

-->

### Service Discovery Issues

If you are able to connect to remote service by using ServiceIP or globalIp, but not by service name, it is a Service Discovery Issue.

#### Service Discovery not working

This is good time to familiarize yourself with [Service Discovery Architecture](../../getting-started/architecture/service-discovery/) if
you haven't already.

##### Check ServiceExport for your Service

For a Service to be accessible across clusters, you must first export the Service via `subctl` which creates a `ServiceExport` resource.
Ensure the `ServiceExport` resource exists and check if its status condition indicates `Exported'. Otherwise, its status condition will
indicate the reason it wasn't exported.

`kubectl describe serviceexport -n <service-namespace> <service-name>`

Note that you can also use shorthand `svcex` for `serviceexport` and `svcim` for `serviceimport`.

Sample output:

```yaml
Name:         nginx-demo
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  multicluster.x-k8s.io/v1alpha1
Kind:         ServiceExport
Metadata:
  Creation Timestamp:  2020-11-25T06:21:01Z
  Generation:          1
  Resource Version:    5254
  Self Link:           /apis/multicluster.x-k8s.io/v1alpha1/namespaces/default/serviceexports/nginx-demo
  UID:                 77509e43-8fd1-4173-805c-e03c4581ebbf
Status:
  Conditions:
    Last Transition Time:  2020-11-25T06:21:01Z
    Message:               Awaiting sync of the ServiceImport to the broker
    Reason:                AwaitingSync
    Status:                False
    Type:                  Valid
    Last Transition Time:  2020-11-25T06:21:01Z
    Message:               Service was successfully synced to the broker
    Reason:
    Status:                True
    Type:                  Valid
Events:                    <none>
```

##### Check Lighthouse CoreDNS Service

All cross-cluster service queries are handled by Lighthouse CoreDNS server. First we check if the Lighthouse CoreDNS Service is running
properly.

`kubectl -n submariner-operator get service submariner-lighthouse-coredns`

If it is running fine, note down the `ServiceIP` for the next steps. If not, check the logs for an error.

If the error is due to a wrong image, run `kubectl -n submariner-operator get deployment submariner-lighthouse-coredns` and make sure
`Image` is set to `quay.io/submariner/lighthouse-coredns:<version>` and refers to the correct version.

For any other errors, capture the information and raise a new [issue](https://github.com/submariner-io/lighthouse/issues).

If there's no error, then check if the Lighthouse CoreDNS server is configured correctly. Run `kubectl -n submariner-operator describe
configmap submariner-lighthouse-coredns` and make sure it has following configuration:

```text
    clusterset.local:53 {
        lighthouse
        errors
        health
        ready
    }
```

##### Check CoreDNS Configuration

Submariner requires the CoreDNS deployment to forward requests for the domain `clusterset.local` to the Lighthouse CoreDNS server in the
cluster making the query. Ensure this configuration exists and is correct.

First we check if CoreDNS is configured to forward requests for domain `clusterset.local` to Lighthouse CoreDNS Server in the cluster
making the query.

`kubectl -n kube-system describe configmap coredns`

In the output look for something like this:

```text
    clusterset.local:53 {
        forward . <lighthouse-coredns-serviceip> ======> ServiceIP of lighthouse-coredns service as noted in previous section
    }
```

If the entries highlighted above are missing or `ServiceIp` is incorrect, it means CoreDNS wasn't configured correctly. It can be fixed by
running `kubectl edit configmap coredns` and making the changes manually. You may need to repeat this step on every cluster.

##### Check `submariner-lighthouse-agent`

Next we check if the `submariner-lighthouse-agent` is properly running. Run `kubectl -n submariner-operator get pods
submariner-lighthouse-agent` and check the status of Pods.

If the status indicates the `ImagePullBackOff` error, run `kubectl -n submariner-operator describe deployment submariner-lighthouse-agent`
and check if `Image` is set correctly to `quay.io/submariner/lighthouse-agent:<version>`. If it is and the same error still occurs, raise an
issue [here](https://github.com/submariner-io/lighthouse/issues) or ping us on the community slack channel.

If the status indicates any other error, run `kubectl -n submariner-operator get pods` to get the name of the `lighthouse-agent` Pod. Then
run `kubectl -n submariner-operator logs <lighthouse-agent-pod-name>` to get the logs. See if there are any errors in the log. If yes, raise
an [issue](https://github.com/submariner-io/lighthouse/issues) with the log contents, or you can continue reading through this guide to
troubleshoot further.

If there are no errors, grep the log for the service name that you're trying to query as we may need the log entries later for raising an
issue.

##### Check ServiceImport resources

If the steps above did not indicate an issue, next we check if the ServiceImport resources were properly created for the service you're
trying to access. The format of a ServiceImport resources's name is as follows:

`<service-name>-<service-namespace>-<cluster-id>`

Run `kubectl get serviceimports --all-namespaces |grep <your-service-name>` on the Broker cluster to check if a resource was created for
your service. If not, then check the Lighthouse Agent logs on the cluster where service was created and look for any error or warning
messages indicating a failure to create the ServiceImport resource for your service. The most common error is `Forbidden` if the RBAC wasn't
configured correctly. Depending on the deployment method used, 'subctl' or 'helm', it should've been done for you. Create an
[issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the ServiceImport resource was created correctly on the Broker cluster, the next step is to check if it exists on the cluster where
you're trying to access the service. Follow the same steps as earlier to get the list of the ServiceImport resources and check if the
ServiceImport for your service exists. If not, check the logs of the Lighthouse Agent on the cluster where you are trying to access the
service. As described earlier, it will most commonly be an issue with RBAC otherwise create an
[issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the ServiceImport resource was created properly on the cluster, run
`kubectl -n submariner-operator describe serviceimport <your-serviceimport-name>`
and check if it has the correct `ClusterID` and `ServiceIP`:

```text
Name:         nginx-demo-default-cluster2
Namespace:    submariner-operator
Labels:       lighthouse.submariner.io/sourceCluster=cluster2
              lighthouse.submariner.io/sourceName=nginx-demo
              lighthouse.submariner.io/sourceNamespace=default
              submariner-io/clusterID=cluster2
Annotations:  cluster-ip: 100.2.33.171
              origin-name: nginx-demo
              origin-namespace: default
API Version:  multicluster.x-k8s.io/v1alpha1
Kind:         ServiceImport
Metadata:
  Creation Timestamp:  2020-11-25T06:21:02Z
  Generation:          1
  Resource Version:    5312
  Self Link:           /apis/multicluster.x-k8s.io/v1alpha1/namespaces/submariner-operator/serviceimports/nginx-demo-default-cluster2
  UID:                 a4c4abe0-1c84-4118-ae09-760b26f7fe3c
Spec:
  Ips:
    100.2.33.171
  Ports:
  Session Affinity Config:
  Type:  ClusterSetIP
Events:  <none>

```

For headless Service, you need to check `EndpointSlice` resource.

If the data is not correct, you can manually edit the ServiceImport resource to set the correct IP as a workaround and create an
[issue](https://github.com/submariner-io/lighthouse/issues) with relevant information.

If the ServiceImport `Ips` are correct but still not being returned from DNS queries, check the connectivity to the cluster
using [`subctl show endpoint`](../deployment/subctl/_index.en.md#show-endpoints). The Lighthouse CoreDNS Server only returns IPs
from connected clusters.

##### Check EndpointSlice resources

For a headless Service, next we check if the EndpointSlice resources were properly created for the service you're
trying to access. EndpointSlice resources are created in the same namespace as the source Service. The format of a EndpointSlice
resource's name is as follows:

`<service-name>--<cluster-id>`

Run `kubectl get endpointslices --all-namespaces |grep <your-service-name>` on the Broker cluster to check if a resource was created for
your Service. If not, then check the Lighthouse Agent logs on the cluster where the Service was created and look for any error or warning
messages indicating a failure to create the ServiceImport resource for your Service. The most common error is `Forbidden` if the RBAC wasn't
configured correctly. This is supposed to be done automatically during deployment so please file an
[issue](https://github.com/submariner-io/lighthouse/issues) with the relevant log entries.

If the EndpointSlice resource was created correctly on the Broker cluster, the next step is to check if it exists on the cluster where
you're trying to access the Service. Follow the same steps as earlier to get the list of the EndpointSlice resources and check if the
EndpointSlice for the Service exists. If not, check the logs of the Lighthouse Agent on the cluster where you are trying to access the
Service. As described earlier, it will most commonly be an issue with RBAC so create an
[issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the EndpointSlice resource was created properly on the cluster, run
`kubectl -n <your-service-namespace> describe endpointslice <your-endpointslice-name>`
and check if it has the correct endpoint addresses:

```text
Name:         nginx-ss-cluster2
Namespace:    default
Labels:       endpointslice.kubernetes.io/managed-by=lighthouse-agent.submariner.io
              lighthouse.submariner.io/sourceCluster=cluster2
              lighthouse.submariner.io/sourceName=nginx-ss
              lighthouse.submariner.io/sourceNamespace=default
              multicluster.kubernetes.io/service-name=nginx-ss-default-cluster2
Annotations:  <none>
AddressType:  IPv4
Ports:
  Name  Port  Protocol
  ----  ----  --------
  web   80    TCP
Endpoints:
  - Addresses:  10.242.0.5  -----> Pod IP
    Conditions:
      Ready:    true
    Hostname:   web-0   -----> Pod hostname
    Topology:   kubernetes.io/hostname=cluster2-worker2
  - Addresses:  10.242.224.4
    Conditions:
      Ready:   true
    Hostname:  web-1
    Topology:  kubernetes.io/hostname=cluster2-worker
Events:        <none>
```

If the `Addresses` are correct but still not being returned from DNS queries, try querying IPs in a specific cluster
by prefixing the query with `<cluster-id>.` If that returns the IPs correctly, then check the connectivity to the cluster
using [`subctl show endpoint`](../deployment/subctl/_index.en.md#show-endpoints). The Lighthouse CoreDNS Server only returns IPs
from connected clusters.

For errors querying specific Pods of a StatefulSet, check that the `Hostname` is correct for the endpoint.

If still not working, file an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.
