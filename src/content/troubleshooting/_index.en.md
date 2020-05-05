+++
title = "Troubleshooting Guide"
date = 2020-05-04T19:01:14+05:30
weight = 5
pre = "<b>1. </b>"
+++

## Overview

You have folowed steps in [Deployment](../deployment) but something has gone wrong. You're not sure what and how to fix it, or what information to collect to raise an issue. Welcome to the Submariner troubleshooting guide where we will help you get your deployment working again.

To recap, Submariner consists of two main core components (broker and submariner) and optional components (lighthouse), detailed in [Architecture](../architecture) section. Basic familiarity with the architecture will be helpful when troubleshooting.

The guide has been broken into different sections for easy navigation.

### Pre-requisite
Before we begin troubleshooting, it would be good to know which version of submariner and its components you are running.

{{% notice info %}}

TBD: Add information on how to find out which version users are running. Is `subctl version` enough?

{{% /notice %}}

Get information about the service you're trying to access.

`kubectl get services |grep <service-name` will provide you with Service *Name*, *Namespace* and *ServiceIP*. If you enabled **Globalnet** you will also need the *GlobalnetIP* of the service by running

``` kubectl get service <service-name> -o jsonpath='{.metadata.annotations.submariner\.io/globalIp}' ```

### Deployment Issues
This section will contain information about common deployment issues you can run into.

#### TBD

### Connectivity Issues
Deployment went through successfully but services/pods on one cluster are unable to connect to services in another clusters. This can be due to multuple factors - IP Sec tunnels, IP Table rules, Gateway pods, Routeagent etc.

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

### Service Discovery Issues
If you are able to connect to remote service by using ServiceIP or GlobalnetIP, but not by service name, it is a Service Discovery Issue.

#### Service Discovery not working
This is good time to familiarize yourself with [Lighthouse Architecture](../architecture/components/lighthouse) if you haven't already.

##### Check CoreDNS Configuration
Submariner configures CoreDNS deployment to enable `lighthouse` plugin. Since CoreDNS is the first point of entry for any DNS queries, that is where we will start first. 

First we check if we are running the correct image. We need CoreDNS image with ligthouse enabled.

```kubectl -n kube-system kube-dns describe deployment```

Make sure that `Image` is set to `quay.io/submariner/lighthouse-coredns:<version>` and version is correct. If not, change it to use the Lighthouse image.

If image is correct, next we need to check if `lighthouse` plugin is enabled on the CoreDNS in the source cluster i.e. the cluster making the query.

```kubectl describe configmap coredns```

In the output look for something like this:

```
        kubernetes cluster2.local in-addr.arpa ip6.arpa {
           pods insecure
           upstream
           #fallthrough in-addr.arpa ip6.arpa
           fallthrough     =====> This tells kubernetes to go to next plugin if query fails locally
        }
        lighthouse { ====> Lighthouse plugin will catch any queries that local kubernetes can't resolve
           fallthrough =====> proceed as usual if lighthouse can't resolve
        }
```
If the entries highlighted above are missing, it means CoreDNS wasn't configured with lighthouse. It can be easily added by running `kubectl edit configmap coredns` and making the changes manually. You may need to repeat this step on every cluster.

##### Check submariner-lighthouse-agent
Next we check if `submariner-lighthouse-agent` is running correctly or not. Run `kubectl -n submariner-operator get pods submariner-lighthouse-agent` and check status of pods.

If status is error with `ImagePullBackOff`, run `kubectl -n submariner-operator describe deployment submariner-lighthouse-agent` and check if `Image` is set correctly to `quay.io/submariner/lighthouse-agent:<version>`. If it is and still getting the same error, raise an issue as image has likely gone missing from quay.io

If status is just error, run `kubectl -n submariner-operator get pods` to get the pod name for lighthouse agent. Then run `kubectl -n submariner-operator logs <lighthouse-agent-pod-name>` to get the logs. See if there are any errors in the log. If yes, raise an [issue](https://github.com/submariner-io/lighthouse/issues) with log contents, or you can continue reading through document to troubleshoot this further.

If there are no errors, grep the logs for service name that you're trying to query, we may need them later for raising an issue.

##### Check multiclusterservice CRs
If all this was fine, next we need to check if `multiclusterservices` CRs were created correctly for the service you're trying to access. The format of `multiclusterservice` object's name is as follows:

`<service-name>-<service-namespace>-<cluster-id>`

Run `kubectl get multiclusterservices --all-namespaces |grep <your-service-name>` on the broker cluster to see if CR was created for your service or not. If not, check the Lighthouse Agent logs on the cluster where service was created, there should be some error or warning messages about being unable to create `multiclusterservice` object for your service. Most common error can be `Forbidden` if the RBAC wasn't configured correctly. Depending on deployment used, *subctl* or *helm* it should've been done for you. Create an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the CR was created correctly on broker cluster, next step is to check for it on the cluster where you're trying to access the service. Follow the same steps as earlier to get list of `multiclusterservices` objects created and if your service name shows up in it or not. If not, again check the logs of Lighthouse Agent but this time on the cluster where you are trying to access the service. Again, it will likely be an issue with RBAC and you follow the same steps, create an Create an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant log entries.

If the CR was created correctly, run `kubectl -n submariner-operator describe multiclusterservice <your-mcs-name>` and check if it has correct `ClusterID` and `ServiceIP`.

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

If not correct, you can manually edit the `multiclusterservices` CR to the correct IP as a workaround and Create an [issue](https://github.com/submariner-io/lighthouse/issues) with relevant information.

If it is correct, congratulations - you've found a new [issue](https://github.com/submariner-io/lighthouse/issues).
