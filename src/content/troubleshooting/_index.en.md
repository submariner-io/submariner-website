+++
title = "Troubleshooting Guide"
date = 2020-05-04T19:01:14+05:30
weight = 20
pre = "<b>4. </b>"
+++

## Overview

You have followed steps in [Deployment](../deployment) but something has gone wrong. You're not sure what and how to fix it, or what information to collect to raise an issue. Welcome to the Submariner troubleshooting guide where we will help you get your deployment working again.

Basic familiarity with the Submariner components and architecture will be helpful when troubleshooting so please review the [Architecture](../architecture) section.

The guide has been broken into different sections for easy navigation.

### Pre-requisite
Before we begin troubleshooting, run `subctl version` to obtain which version of the Submariner components you are running.

Run `kubectl get services -n <service-namespace> | grep <service-name>` to get information about the service you're trying to access. This will provide you with the Service *Name*, *Namespace* and *ServiceIP*. If **GlobalNet** is enabled, you will also need the *globalIp* of the service by running

``` kubectl get service <service-name> -o jsonpath='{.metadata.annotations.submariner\.io/globalIp}' ```

<!---
### Deployment Issues
This section will contain information about common deployment issues you can run into.

#### TBD

### Connectivity Issues
Submariner deployment completed successfully but Services/Pods on one cluster are unable to connect to Services on another cluster. This can be due to multiple factors outlined in the following sections.

#### IPSec tunnel not created between clusters
TBD

#### IPSEc tunnel is not up between clusters
TBD

#### None of pods/services able to connect to remote service
TBD
##### Without GlobalNet
TBD
##### With GlobalNet
TBD

#### Pods on non-gateway nodes not able to connect to remote service
TBD
##### Without GlobalNet
TBD
##### With GlobalNet
TBD

-->

### Service Discovery Issues
If you are able to connect to remote service by using ServiceIP or globalIp, but not by service name, it is a Service Discovery Issue.

#### Service Discovery not working
This is good time to familiarize yourself with [Service Discovery Architecture](../architecture/service-discovery/) if you haven't already.

##### Check ServiceExport for your Service
For a Service to be accessible across clusters, you must first create a `ServiceExport` resource. Make sure the `ServiceExport` resource exists and has the same name and namespace as the Service you're trying to export.

```kubectl get serviceexport -n <service-namespace> <service-name>```

Sample output:
```
apiVersion: lighthouse.submariner.io/v2alpha1
kind: ServiceExport
metadata:
  name: nginx
```

##### Check Lighthouse CoreDNS Service
All cross-cluster service queries are handled by Lighthouse CoreDNS server. First we check if the Lighthouse CoreDNS Service is running properly.

```kubectl -n submariner-operator get service submariner-lighthouse-coredns``` 

If it is running fine, note down the `ServiceIP` for the next steps. If not, check the logs for an error.

If the error is due to a wrong image, run ```kubectl -n submariner-operator get deployment submariner-lighthouse-coredns``` and make sure `Image` is set to `quay.io/submariner/lighthouse-coredns:<version>` and refers to the correct version.

For any other errors, capture the information and raise a new [issue](https://github.com/submariner-io/lighthouse/issues)

If there's no error, then check if the Lighthouse CoreDNS server is configured correctly. Run ```kubectl describe configmap submariner-lighthouse-coredns``` and make sure it has following configuration:

```
    supercluster.local:53 {
        lighthouse
        errors
        health
        ready
    }
```

##### Check CoreDNS Configuration
Submariner requires the CoreDNS deployment to forward requests for the domain `supercluster.local` to the Lighthouse CoreDNS server in the cluster making the query. Ensure this configuration exists and is correct.

First we check if CoreDNS is configured to forward requests for domain `supercluster.local` to Lighthouse CoreDNS Server in the cluster making the query.

```kubectl describe configmap coredns```

In the output look for something like this:

```
    supercluster.local:53 {
        forward . <lighthouse-coredns-serviceip> ======> ServiceIP of lighthouse-coredns service as noted in pervious section
    }
```
If the entries highlighted above are missing or `ServiceIp` is incorrect, it means CoreDNS wasn't configured correctly. It can be fixed by running `kubectl edit configmap coredns` and making the changes manually. You may need to repeat this step on every cluster.

##### Check submariner-lighthouse-agent
Next we check if the `submariner-lighthouse-agent` is properly running. Run `kubectl -n submariner-operator get pods submariner-lighthouse-agent` and check the status of Pods.

If the status indicates the `ImagePullBackOff` error, run `kubectl -n submariner-operator describe deployment submariner-lighthouse-agent` and check if `Image` is set correctly to `quay.io/submariner/lighthouse-agent:<version>`. If it is and the same error still occurs, raise an issue [here](https://github.com/submariner-io/lighthouse/issues) or ping us on the community slack channel.

If the status indicates any other error, run `kubectl -n submariner-operator get pods` to get the name of the `lighthouse-agent` Pod. Then run `kubectl -n submariner-operator logs <lighthouse-agent-pod-name>` to get the logs. See if there are any errors in the log. If yes, raise an [issue](https://github.com/submariner-io/lighthouse/issues) with the log contents, or you can continue reading through this guide to troubleshoot further.

If there are no errors, grep the log for the service name that you're trying to query as we may need the log entries later for raising an issue.

##### Check Multiclusterservice resources
If the steps above did not indicate an issue, next we check if the Multiclusterservice resources were properly created for the service you're trying to access. The format of a Multiclusterservice resources's name is as follows:

`<service-name>-<service-namespace>-<cluster-id>`

Run `kubectl get multiclusterservices --all-namespaces |grep <your-service-name>` on the broker cluster to check if a resource was created for your service. If not, then check the Lighthouse Agent logs on the cluster where service was created and look for any error or warning messages indicating a failure to create the Multiclusterservice resource for your service. The most common error is `Forbidden` if the RBAC wasn't configured correctly. Depending on the deployment method used, 'subctl' or 'helm', it should've been done for you. Create an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the Multiclusterservice resource was created correctly on the broker cluster, the next step is to check if it exists on the cluster where you're trying to access the service. Follow the same steps as earlier to get the list of the Multiclusterservice resources and check if the Multiclusterservice for your service exists. If not, check the logs of the Lighthouse Agent on the cluster where you are trying to access the service. As described earlier, it will most commonly be an issue with RBAC otherwise create an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the Multiclusterservice resource was created properly on the cluster, run `kubectl -n submariner-operator describe multiclusterservice <your-multiclusterservice-name>` and check if it has the correct `ClusterID` and `ServiceIP`:

```
Name:         nginx-demo-default-cluster2
Namespace:    submariner-operator
Labels:       submariner-io/clusterID=cluster2
Annotations:  <none>
API Version:  lighthouse.submariner.io/v1
Kind:         MultiClusterService
Metadata:
  Creation Timestamp:  2020-04-16T15:40:36Z
  Generation:          1
  Resource Version:    6847
  Self Link:           /apis/lighthouse.submariner.io/v1/namespaces/submariner-operator/multiclusterservices/nginx-demo-ns-default-src-cluster2
  UID:                 9db7759c-7ff8-11ea-85a3-0242ac110006
Spec:
  Cluster Service Info:
    Cluster Domain:  
    Cluster ID:      cluster2       ==========> ClusterID of cluster where service is running
    Service IP:      100.92.243.156 ==========> ServiceIP or GlobalIP of service you're trying to access
Events:              <none>
```

If the data is not correct, you can manually edit the Multiclusterservice resource to set the correct IP as a workaround and create an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant information.

If it is correct, congratulations - you've found a new [issue](https://github.com/submariner-io/lighthouse/issues).
