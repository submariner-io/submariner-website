+++
title = "User Guide"
date = 2020-05-04T19:01:14+05:30
weight = 15
+++

## Overview

This guide is intended for users who have a Submariner environment set up and want to verify the installation and learn more about how to
use Submariner and the main capabilities it provides. This guide assumes that there are two Kubernetes clusters,
**cluster2** and **cluster3**, forming a clusterset, and that the Broker is deployed into a separate cluster **cluster1**.

{{% notice tip %}}
Make sure you have `subctl` [set up](../deployment/subctl/#installation). Regardless of how Submariner was deployed, `subctl` can be used
for various verification and troubleshooting tasks, as shown in this guide.
{{% /notice %}}

{{% notice note %}}
This guide focuses on a non-Globalnet Submariner deployment.
{{% /notice %}}

### 1. Validate the Installation

#### On the Broker

The Broker facilitates the exchange of metadata information between the connected clusters, enabling them to discover one another.
The Broker consists of a set of Custom Resource Definitions (CRDs) only; there are no Pods or Services deployed with it.

You can use this command to validate that the Broker namespace has been created in the Broker cluster:

```bash
$ kubectl config use-context cluster1
Switched to context "cluster1".
```

```bash
$ kubectl get namespace submariner-k8s-broker
NAME                    STATUS   AGE
submariner-k8s-broker   Active   5m
```

You can use this command to validate that the Submariner CRDs have been created in the Broker cluster:

```bash
$ kubectl get crds | grep -iE 'submariner|multicluster.x-k8s.io'
clusters.submariner.io                    2020-11-30T13:49:16Z
endpoints.submariner.io                   2020-11-30T13:49:16Z
gateways.submariner.io                    2020-11-30T13:49:16Z
serviceimports.lighthouse.submariner.io   2020-11-30T13:49:16Z
serviceimports.multicluster.x-k8s.io      2020-11-30T13:52:39Z
```

You can use this command to validate that the participating clusters have successfully joined the Broker:

```bash
$ kubectl -n submariner-k8s-broker get clusters.submariner.io
NAME       AGE
cluster2   5m9s
cluster3   2m9s
```

#### On Connected Clusters

The below commands can be used on either **cluster2** or **cluster3** to verify that the two clusters have successfully formed a clusterset
and are properly connected to each other. In this example, the commands are being issued on **cluster2**.

You can use this command to monitor as all required Submariner components are being installed:

```bash
$ kubectl config use-context cluster2
Switched to context "cluster2".
```

```bash
$ kubectl -n submariner-operator get pods --watch
NAME                                  READY   STATUS    RESTARTS   AGE
submariner-operator-dcbdf5669-n7jgp   1/1     Running   0          12s
submariner-gateway-btzrq              0/1     Pending   0          0s
submariner-gateway-btzrq              0/1     Pending   0          0s
submariner-gateway-btzrq              0/1     ContainerCreating   0          0s
submariner-routeagent-bmgbc           0/1     Pending             0          0s
submariner-routeagent-rl9nh           0/1     Pending             0          0s
submariner-routeagent-bmgbc           0/1     Pending             0          0s
submariner-routeagent-wqmzs           0/1     Pending             0          0s
submariner-routeagent-rl9nh           0/1     Pending             0          0s
submariner-routeagent-wqmzs           0/1     Pending             0          0s
submariner-routeagent-rl9nh           0/1     ContainerCreating   0          0s
submariner-routeagent-bmgbc           0/1     ContainerCreating   0          0s
submariner-routeagent-wqmzs           0/1     ContainerCreating   0          0s
submariner-lighthouse-agent-586cf4899-wn747   0/1     Pending             0          0s
submariner-lighthouse-agent-586cf4899-wn747   0/1     Pending             0          0s
submariner-lighthouse-agent-586cf4899-wn747   0/1     ContainerCreating   0          0s
submariner-lighthouse-coredns-c88f64f5-qlw4x   0/1     Pending             0          0s
submariner-lighthouse-coredns-c88f64f5-h77kw   0/1     Pending             0          0s
```

It may take a couple of minutes for all components to come up:

```bash
$ kubectl -n submariner-operator get pods
NAME                                           READY   STATUS    RESTARTS   AGE
submariner-gateway-btzrq                       1/1     Running   0          76s
submariner-lighthouse-agent-586cf4899-wn747    1/1     Running   0          75s
submariner-lighthouse-coredns-c88f64f5-h77kw   1/1     Running   0          73s
submariner-lighthouse-coredns-c88f64f5-qlw4x   1/1     Running   0          73s
submariner-operator-dcbdf5669-n7jgp            1/1     Running   0          89s
submariner-routeagent-bmgbc                    1/1     Running   0          75s
submariner-routeagent-rl9nh                    1/1     Running   0          75s
submariner-routeagent-wqmzs                    1/1     Running   0          75s
```

You can use this command to verify on which node the Gateway Engine is running on:

```bash
$ kubectl get node --selector=submariner.io/gateway=true -o wide
NAME              STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE       KERNEL-VERSION           CONTAINER-RUNTIME
cluster2-worker   Ready    <none>   6h59m   v1.17.0   172.17.0.7    <none>        Ubuntu 19.10   5.8.18-200.fc32.x86_64   containerd://1.3.2
```

You can use this command to quickly verify the connection between the participating clusters:
<!-- markdownlint-disable no-trailing-spaces -->
```bash
$ subctl show connections

Showing information for cluster "cluster2":
GATEWAY                         CLUSTER                 REMOTE IP       CABLE DRIVER        SUBNETS                               STATUS
cluster3-worker                 cluster3                172.17.0.10     libreswan           100.3.0.0/16, 10.3.0.0/16             connected
```

You can use this command to get detailed information about the inter-cluster connection:

```bash
$ kubectl -n submariner-operator describe Gateway
Name:         cluster2-worker
Namespace:    submariner-operator
Labels:       <none>
Annotations:  update-timestamp: 1606751397
API Version:  submariner.io/v1
Kind:         Gateway
Metadata:
  Creation Timestamp:  2020-11-30T13:51:39Z
  Generation:          538
  Resource Version:    28717
  Self Link:           /apis/submariner.io/v1/namespaces/submariner-operator/gateways/cluster2-worker
  UID:                 682f791a-00b5-4f51-8249-80c7c82c4bbf
Status:
  Connections:
    Endpoint:
      Backend:          libreswan
      cable_name:       submariner-cable-cluster3-172-17-0-10
      cluster_id:       cluster3
      Health Check IP:  10.3.224.0
      Hostname:         cluster3-worker
      nat_enabled:      false
      private_ip:       172.17.0.10
      public_ip:        
      Subnets:
        100.3.0.0/16
        10.3.0.0/16
    Latency:
      Average RTT:   472623
      Last RTT:      583181
      Max RTT:       2603444
      Min RTT:       80202
      Stddev RTT:    164687
    Status:          connected
    Status Message:  
  Ha Status:         active
  Local Endpoint:
    Backend:          libreswan
    cable_name:       submariner-cable-cluster2-172-17-0-7
    cluster_id:       cluster2
    Health Check IP:  10.2.224.0
    Hostname:         cluster2-worker
    nat_enabled:      false
    private_ip:       172.17.0.7
    public_ip:        
    Subnets:
      100.2.0.0/16
      10.2.0.0/16
  Status Failure:  
  Version:         v0.8.0-pre0-1-g5d7f163
Events:            <none>
```
<!-- markdownlint-enable no-trailing-spaces -->
To verify that service discovery is installed properly, validate that the Submariner CRDs have been created in the cluster:

```bash
$ kubectl get crds | grep -iE 'submariner|multicluster.x-k8s.io'
clusters.submariner.io                    2020-11-30T13:50:33Z
endpoints.submariner.io                   2020-11-30T13:50:33Z
gateways.submariner.io                    2020-11-30T13:50:33Z
servicediscoveries.submariner.io          2020-11-30T13:50:34Z
serviceexports.lighthouse.submariner.io   2020-11-30T13:50:33Z
serviceexports.multicluster.x-k8s.io      2020-11-30T13:50:34Z
serviceimports.lighthouse.submariner.io   2020-11-30T13:50:33Z
serviceimports.multicluster.x-k8s.io      2020-11-30T13:50:33Z
submariners.submariner.io                 2020-11-30T13:50:24Z
```

Check that the `submariner-lighthouse-coredns` Service is ready:

```bash
$ kubectl -n submariner-operator get service submariner-lighthouse-coredns
NAME                            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
submariner-lighthouse-coredns   ClusterIP   100.2.177.123   <none>        53/UDP    126m
```

Verify that CoreDNS was properly configured to forward requests sent to `clusterset.local` to Lighthouse CoreDNS Server in the
cluster:

```bash
$ kubectl -n kube-system describe configmap coredns
Name:         coredns
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Data
====
Corefile:
----
#lighthouse-start AUTO-GENERATED SECTION. DO NOT EDIT
clusterset.local:53 {
    forward . 100.2.177.123
}
#lighthouse-end
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster2.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}
```

Note that **100.2.177.123** is the ClusterIP address of the `submariner-lighthouse-coredns` Service we verified earlier.

### 2. Export Services Across Clusters

At this point, we have enabled secure IP communication between the connected clusters and formed the clusterset. However, further
configuration is required in order to signify that a Service should be visible and discoverable to other clusters in the clusterset. This
can be done by creating a `ServiceExport` object in each cluster within the namespace that the underlying Service resides in. When a
`ServiceExport` is created, this will cause the multi-cluster Service to become accessible as `<service>.<ns>.svc.clusterset.local`.
Similarly, deleting the `ServiceExport` will stop exporting the Service.

This guide uses a simple nginx server for demonstration purposes.

{{% notice info %}}
Note that the namespace must be created in both clusters for service discovery to work properly. In the example below, we test with the
default namespace which automatically exists, but if we were to test with a dedicated namespace, it needs to be created in both clusters.
{{% /notice %}}

#### Test ClusterIP Services

A Kubernetes Service is an abstraction which defines a logical set of Pods running in your cluster, that all provide the same functionality.
When created, each Service is assigned a unique IP address. This address is tied to the lifespan of the Service.
Pods can be configured to talk to the Service, and know that communication to the Service will be automatically load-balanced out to some
Pod that is a member of the Service. ClusterIP is the default ServiceType in Kubernetes, and is only accessible from within the cluster.
Submariner makes it possible for a ClusterIP Service to be accessible across cluster boundaries.

##### 1. Create an `nginx` Deployment on **cluster3**

```bash
$ kubectl config use-context cluster3
Switched to context "cluster3".
```

```bash
$ kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
deployment.apps/nginx created

$ kubectl -n default expose deployment nginx --port=8080
service/nginx exposed
```

This will create an `nginx` Service on the default namespace which targets TCP port 8080 on any Pod with the `app: nginx` label, and
expose it on an abstracted Service port. When created, the Service is assigned a unique IP address (also called ClusterIP):

```bash
$ kubectl -n default get service nginx
NAME    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
nginx   ClusterIP   100.3.220.176  <none>        8080/TCP   2m41s
```

```bash
$ kubectl -n default get pods -l app=nginx -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP         NODE                NOMINATED NODE   READINESS GATES
nginx-667744f849-t26s5   1/1     Running   0          3m    10.3.0.5   cluster3-worker2    <none>           <none>
```

##### 2. Export the Service

In order to signify that the Service should be visible and discoverable to other clusters in the clusterset, a `ServiceExport` needs to be
created. The `subctl export` command can be used to automatically create the required `ServiceExport` object:

```bash
$ subctl export service --namespace default nginx
Service exported successfully
```

Verify that the `ServiceExport` object has been created for the `nginx` Service within the default namespace:
<!-- markdownlint-disable no-trailing-spaces -->
```bash
$ kubectl -n default describe serviceexports
Name:         nginx
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  multicluster.x-k8s.io/v1alpha1
Kind:         ServiceExport
Metadata:
  Creation Timestamp:  2020-12-01T12:35:32Z
  Generation:          1
  Resource Version:    302209
  Self Link:           /apis/multicluster.x-k8s.io/v1alpha1/namespaces/default/serviceexports/nginx
  UID:                 afe0533c-7cca-4443-9d8a-aee8e888e8bc
Status:
  Conditions:
    Last Transition Time:  2020-12-01T12:35:32Z
    Message:               Awaiting sync of the ServiceImport to the broker
    Reason:                AwaitingSync
    Status:                False
    Type:                  Valid
    Last Transition Time:  2020-12-01T12:35:32Z
    Message:               Service was successfully synced to the broker
    Reason:                
    Status:                True
    Type:                  Valid
Events:                    <none>

```
<!-- markdownlint-enable no-trailing-spaces -->
When the Service is exported successfully, it can be discovered as `nginx.default.svc.clusterset.local` across the clusterset.

##### 3. Consume the Service from **cluster2**

First, verify that the exported `nginx` Service was imported to **cluster2** as expected. Submariner (via Lighthouse) automatically
creates a corresponding `ServiceImport`:

```bash
$ kubectl config use-context cluster2
Switched to context "cluster2".
```

```bash
$ kubectl get -n submariner-operator serviceimport
NAME                     TYPE           IP                AGE
nginx-default-cluster3   ClusterSetIP   [100.3.220.176]   13m
```

Next, run a test Pod on **cluster2** and try to access the `nginx` Service from within the Pod:

```bash
$ kubectl -n default  run --generator=run-pod/v1 \
tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
```

```bash
bash-5.0# curl nginx.default.svc.clusterset.local
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```
<!-- markdownlint-disable no-hard-tabs -->
```bash
bash-5.0# dig nginx.default.svc.clusterset.local
; <<>> DiG 9.16.6 <<>> nginx.default.svc.clusterset.local
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34800
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 6ff7ea72c14ce2d4 (echoed)
;; QUESTION SECTION:
;nginx.default.svc.clusterset.local. IN	A

;; ANSWER SECTION:
nginx.default.svc.clusterset.local. 5 IN A	100.3.220.176

;; Query time: 16 msec
;; SERVER: 100.2.0.10#53(100.2.0.10)
;; WHEN: Mon Nov 30 17:52:55 UTC 2020
;; MSG SIZE  rcvd: 125
```
<!-- markdownlint-enable no-hard-tabs -->
Note that DNS resolution works across the clusters, and that the IP address **100.3.220.176** returned is the same ClusterIP associated with
the `nginx` Service on **cluster3**.

##### 4. Create an `nginx` Deployment on **cluster2**

If multiple clusters export a Service with the same name and from the same namespace, it will be recognized as a single combined Service.
To test this, let's deploy the same `nginx` Service, this time on **cluster2**:

```bash
$ kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
deployment.apps/nginx created

$ kubectl -n default expose deployment nginx --port=8080
service/nginx exposed
```

This will create an `nginx` Service on the default namespace which targets TCP port 8080 on any Pod with the `app: nginx` label, and
expose it on an abstracted Service port. When created, the Service is assigned a unique IP address (also called ClusterIP):

```bash
$ kubectl -n default get service nginx
NAME    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
nginx   ClusterIP   100.2.29.136   <none>        8080/TCP   1m40s
```

```bash
$ kubectl -n default get pods -l app=nginx -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP           NODE              NOMINATED NODE   READINESS GATES
nginx-5578584966-d7sj7   1/1     Running   0          22s   10.2.224.3   cluster2-worker   <none>           <none>
```

##### 5. Export the Service

In order to signify that the Service should be visible and discoverable to other clusters in the clusterset, a `ServiceExport` needs to be
created. The `subctl export` command can be used to automatically create the required `ServiceExport` object:

```bash
$ subctl export service --namespace default nginx
Service exported successfully
```

##### 6. Consume the Service from **cluster3**

First, verify that the exported `nginx` Service was imported to **cluster3** as expected. Submariner (via Lighthouse) automatically
creates a corresponding `ServiceImport`:

```bash
$ kubectl config use-context cluster3
Switched to context "cluster3".
```

```bash
$ kubectl get -n submariner-operator serviceimport
NAME                     TYPE           IP               AGE
nginx-default-cluster2   ClusterSetIP   [100.2.29.136]   62s
```

Next, run a test Pod on **cluster3** and try to access the `nginx` Service from within the Pod:

```bash
$ kubectl -n default  run --generator=run-pod/v1 \
tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
```

```bash
bash-5.0# curl nginx.default.svc.clusterset.local
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

<!-- markdownlint-disable no-hard-tabs -->
```bash
bash-5.0# dig nginx.default.svc.clusterset.local
; <<>> DiG 9.16.6 <<>> nginx.default.svc.clusterset.local
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55022
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 6f9db9800a9a9779 (echoed)
;; QUESTION SECTION:
;nginx.default.svc.clusterset.local. IN	A

;; ANSWER SECTION:
nginx.default.svc.clusterset.local. 5 IN A	100.2.29.136

;; Query time: 5 msec
;; SERVER: 100.3.0.10#53(100.3.0.10)
;; WHEN: Tue Dec 01 07:45:48 UTC 2020
;; MSG SIZE  rcvd: 125
```
<!-- markdownlint-enable no-hard-tabs -->

Note that DNS resolution works, and that the IP address 100.2.29.136 returned is the ClusterIP associated with the **local** nginx Service
deployed on cluster3. This is expected, as Submariner prefers to handle the traffic locally.

#### Service Discovery for Services Deployed to Multiple Clusters

Submariner follows this logic for service discovery across the clusterset:

* If an exported Service is not available in the local cluster, Lighthosue DNS returns the IP address of the ClusterIP Service from one of
the remote clusters on which the Service was exported.

* If an exported Service is available in the local cluster, Lighthosue DNS always returns the IP address of the local ClusterIP Service.
In this example, if a Pod from **cluster2** tries to access the `nginx` Service as `nginx.default.svc.clusterset.local`, Lighthouse DNS
resolves the Service as **100.2.29.136** which is the local ClusterIP Service on **cluster2**. Similarly, if a Pod from **cluster3** tries
to access the `nginx` Service as `nginx.default.svc.clusterset.local`, Lighthouse DNS resolves the Service as **100.3.220.176** which is the
local ClusterIP Service on **cluster3**.

* If multiple clusters export a Service with the same name and from the same namespace, Lighthosue DNS load balances between the clusters
in a round-robin fashion. If, in our example, a Pod from a third cluster that joined the clusterset tries to access the `nginx` Service as
`nginx.default.svc.clusterset.local`, Lighthouse will round-robin the DNS responses across **cluster2** and **cluster3**, causing
requests to be served by both **cluster2** and **cluster3**. Note that Lighthouse returns IPs from *connected* clusters only. Clusters in
*disconnected* state are ignored.

* Applications can access a Service from a specific cluster by prefixing the DNS query with `cluster-id` as follows:
`<cluster-id>.<svcname>.<namespace>.svc.clusterset.local`. In our example, querying for `cluster2.nginx.default.svc.clusterset.local`
always returns the ClusterIP Service on **cluster2**. Similarly, `cluster3.nginx.default.svc.clusterset.local`
always returns the ClusterIP Service on **cluster3**.

#### Test StatefulSet and Headless Service

Submariner also supports headless Services with StatefulSets, making it possible to access individual Pods via their stable DNS name.
Kubernetes supports this by introducing stable Pod IDs composed of `<pod-name>.<svc-name>.<ns>.svc.cluster.local` within a single cluster,
which Submariner extends to `<pod-name>.<cluster-id>.<svc-name>.<ns>.svc.clusterset.local` across the clusterset. The headless Service in
this case offers one single Service for all the underlying Pods.

Like a Deployment, a StatefulSet manages Pods that are based on an identical container spec. Unlike a Deployment, a StatefulSet maintains a
sticky identity for each of its Pods. StatefulSets are typically used for applications that require stable unique network identifiers,
persistent storage, and ordered deployment and scaling.

##### 1. Create StatefulSet and headless Service on **cluster3**

`kubectl apply` the following yaml:

```bash
apiVersion: v1
kind: Service
metadata:
 name: nginx-ss
 labels:
   app.kubernetes.io/instance: nginx-ss
   app.kubernetes.io/name: nginx-ss
spec:
 ports:
 - port: 80
   name: web
 clusterIP: None
 selector:
   app.kubernetes.io/instance: nginx-ss
   app.kubernetes.io/name: nginx-ss
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
 name: web
spec:
 serviceName: "nginx-ss"
 replicas: 2
 selector:
   matchLabels:
       app.kubernetes.io/instance: nginx-ss
       app.kubernetes.io/name: nginx-ss
 template:
   metadata:
     labels:
       app.kubernetes.io/instance: nginx-ss
       app.kubernetes.io/name: nginx-ss
   spec:
     containers:
     - name: nginx-ss
       image: nginxinc/nginx-unprivileged:stable-alpine
       ports:
       - containerPort: 80
         name: web
```

This specification will create a StatefulSet named `web` which indicates that two replicas of the `nginx` container will be launched in
unique Pods. This also creates a headless Service called `nginx-ss` on the default namespace. Note that headless Service is requested by
explicitly specifying "None" for the clusterIP (.spec.clusterIP).

```bash
$ kubectl apply -f ./nginx-ss.yaml
service/nginx-ss created
statefulset.apps/web created
```

Verify the Service and StatefulSet:

```bash
$ kubectl get service nginx-ss
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx-ss   ClusterIP   None         <none>        80/TCP    83s
```

```bash
$ kubectl describe statefulset web
Name:               web
Namespace:          default
CreationTimestamp:  Mon, 30 Nov 2020 21:53:01 +0200
Selector:           app.kubernetes.io/instance=nginx-ss,app.kubernetes.io/name=nginx-ss
Labels:             <none>
Annotations:        <none>
Replicas:           2 desired | 2 total
Update Strategy:    RollingUpdate
  Partition:        0
Pods Status:        2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app.kubernetes.io/instance=nginx-ss
           app.kubernetes.io/name=nginx-ss
  Containers:
   nginx-ss:
    Image:        nginxinc/nginx-unprivileged:stable-alpine
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Volume Claims:    <none>
Events:
  Type    Reason            Age   From                    Message
  ----    ------            ----  ----                    -------
  Normal  SuccessfulCreate  94s   statefulset-controller  create Pod web-0 in StatefulSet web successful
  Normal  SuccessfulCreate  85s   statefulset-controller  create Pod web-1 in StatefulSet web successful
```

##### 2. Export the Service

In order to signify that the Service should be visible and discoverable to other clusters in the clusterset, a `ServiceExport` needs to be
created. The `subctl export` command can be used to automatically create the required `ServiceExport` object:

```bash
$ subctl export service --namespace default nginx-ss
Service exported successfully
```

Verify that the `ServiceExport` object has been created for the `nginx-ss` Service within the default namespace:
<!-- markdownlint-disable no-trailing-spaces -->
```bash
$ kubectl describe serviceexport nginx-ss
Name:         nginx-ss
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  multicluster.x-k8s.io/v1alpha1
Kind:         ServiceExport
Metadata:
  Creation Timestamp:  2020-11-30T19:59:44Z
  Generation:          1
  Resource Version:    83431
  Self Link:           /apis/multicluster.x-k8s.io/v1alpha1/namespaces/default/serviceexports/nginx-ss
  UID:                 2c0d6419-6160-431e-990c-8a9993363b10
Status:
  Conditions:
    Last Transition Time:  2020-11-30T19:59:44Z
    Message:               Awaiting sync of the ServiceImport to the broker
    Reason:                AwaitingSync
    Status:                False
    Type:                  Valid
    Last Transition Time:  2020-11-30T19:59:44Z
    Message:               Service was successfully synced to the broker
    Reason:                
    Status:                True
    Type:                  Valid
Events:                    <none>
```
<!-- markdownlint-enable no-trailing-spaces -->
When the Service is exported successfully, it can be discovered as `nginx-ss.default.svc.clusterset.local` across the clusterset.
In addition, the individual Pods can be accessed as `web-0.cluster3.nginx-ss.default.svc.clusterset.local` and
`web-1.cluster3.nginx-ss.default.svc.clusterset.local`.

##### 3. Consume the Service from **cluster2**

Verify that the exported `nginx-ss` Service was imported to **cluster2**. Submariner (via Lighthouse) automatically creates a
corresponding `ServiceImport`:

```bash
$ kubectl get -n submariner-operator serviceimport
NAME                        TYPE           IP                AGE
nginx-default-cluster3      ClusterSetIP   [100.3.220.176]   166m
nginx-ss-default-cluster3   Headless                         5m48s
```

Next, run a test Pod on **cluster2** and try to access the `nginx-ss` Service from within the Pod:

```bash
kubectl -n default  run --generator=run-pod/v1 \
tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
```
<!-- markdownlint-disable no-hard-tabs -->
```bash
bash-5.0# dig nginx-ss.default.svc.clusterset.local

; <<>> DiG 9.16.6 <<>> nginx-ss.default.svc.clusterset.local
;; global options: +cmd
;; Got answer:
;; WARNING: .local is reserved for Multicast DNS
;; You are currently testing what happens when an mDNS query is leaked to DNS
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 19729
;; flags: qr aa rd; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: 0b17506cb2b4a93b (echoed)
;; QUESTION SECTION:
;nginx-ss.default.svc.clusterset.local. IN A

;; ANSWER SECTION:
nginx-ss.default.svc.clusterset.local. 5 IN A	10.3.0.5
nginx-ss.default.svc.clusterset.local. 5 IN A	10.3.224.3

;; Query time: 1 msec
;; SERVER: 100.2.0.10#53(100.2.0.10)
;; WHEN: Mon Nov 30 20:18:08 UTC 2020
;; MSG SIZE  rcvd: 184

bash-5.0#
```

You can also access the individual Pods:

```bash
bash-5.0# nslookup web-0.cluster3.nginx-ss.default.svc.clusterset.local
Server:		100.2.0.10
Address:	100.2.0.10#53

Name:	web-0.cluster3.nginx-ss.default.svc.clusterset.local
Address: 10.3.0.5

bash-5.0# nslookup web-1.cluster3.nginx-ss.default.svc.clusterset.local
Server:		100.2.0.10
Address:	100.2.0.10#53

Name:	web-1.cluster3.nginx-ss.default.svc.clusterset.local
Address: 10.3.224.3

bash-5.0#
```
<!-- markdownlint-enable no-hard-tabs -->
#### Clean the Created Resources

To remove the previously created Kubernetes resources, use the following commands on **cluster3**:

```bash
$ kubectl delete service nginx
service "nginx" deleted

$ kubectl delete deployment nginx
deployment.apps "nginx" deleted

$ kubectl delete serviceexport nginx
serviceexport.multicluster.x-k8s.io "nginx" deleted

$ kubectl delete service nginx-ss
service "nginx-ss" deleted

$ kubectl delete statefulset web
statefulset.apps "web" deleted

$ kubectl delete serviceexport nginx-ss
serviceexport.multicluster.x-k8s.io "nginx-ss" deleted
```

Use the following commands on **cluster2**:

```bash
$ kubectl delete service nginx
service "nginx" deleted

$ kubectl delete deployment nginx
deployment.apps "nginx" deleted

$ kubectl delete serviceexport nginx
serviceexport.multicluster.x-k8s.io "nginx" deleted
