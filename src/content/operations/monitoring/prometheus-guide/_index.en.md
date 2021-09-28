+++
title = "Prometheus Deployment Example"
date = 2020-08-12T16:02:00+02:00
weight = 30
+++

### Multi-Cluster monitoring with Prometheus and Submariner

#### Step 1 — Spinning up some local clusters:  
We will use a boilerplate setup from _Submariner._  
Just download the _Submariner_ repository, and run `make clusters`   
This will spin up two local Kubernetes clusters.

<pre name="501c" id="501c" class="graf graf--pre graf-after--p">
git clone [https://github.com/submariner-io/submariner](https://github.com/submariner-io/submariner)  
cd submariner  
make clusters
</pre>

Please refer to [Submariner Quick-Start Guide](https://submariner.io/getting-started/quickstart/) for installations on different cloud providers.

#### Step 2 — Deploy `Prometheus` on the clusters:  
There are many ways for deploying _Prometheus_ on your Kubernetes cluster, I have used the kube-prometheus setup (some will recommend Helm which is great as well) which deploys prometheus-operator from this [link](https://github.com/prometheus-operator/kube-prometheus). But we are going to modify the quick start version to allow _Submariner_ metrics collection and monitoring as well.

Install [jsonnet](https://jsonnet.org/learning/getting_started.html).

Download the pre-defined configuration files and build the

<pre name="b872" id="b872" class="graf graf--pre graf-after--p">
git clone [https://github.com/danibachar/submariner-cheatsheet](https://github.com/danibachar/submariner-cheatsheet.git)  
cd submariner-cheatsheet/prometheus/install  
jb init  
jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@release-0.8  
jb update  
sudo chmod +x ./build.sh  
./build.sh
</pre>

After the script finishes running, you will notice several new directories under `submariner-cheatsheet/prometheus/install`. The one that we will find interesting is the `manifast` directory and its subdirectory `setup` under them there are all the yamls defining the _Prometheus_ CRDs and the operator.

Go back to the root directory where we downloaded the submariner repository into. And let's deploy _Prometheus_

<pre name="68f2" id="68f2" class="graf graf--pre graf-after--p">
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 apply -f submariner-cheatsheet/prometheus/install/manifests/setup  
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster2 \
 apply -f submariner-cheatsheet/prometheus/install/manifests/setup  

kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 apply -f submariner-cheatsheet/prometheus/install/manifests/  
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster2 \
 apply -f submariner-cheatsheet/prometheus/install/manifests/
</pre>

Now you should see _Prometheus_ CRDS, services, and deployments starting to spin up. Run each of these commands to see the relevant Kubernetes resources.  
Note that _Prometheus_ is deployed in the monitoring namespace.  
Note that this example is using cluster1 config, change the kubeconfig flag to point to the cluster2 config to see the status there.

<pre name="59a3" id="59a3" class="graf graf--pre graf-after--p">
# Note the new namespace `monitoring` has appeared
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 get ns

# Will show all the new CRDs defined by Prometheus or any other setup (for example Submariner has its own CRDs)  
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 get crds

# Will show all the relevant service accounts, role and role bindings defined for Prometheus.  
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 get role, rolebindings, clusterrole,clusterrolebindings, serviceaccount -n monitoring

# Will show the service monitoring and prometheus setups  
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 get prometheus --all-namespaces  
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 get servicemonitor --all-namespaces
</pre>

* It is important to deploy prometheus on the different clusters before deploying Submariner so `Prometheus` CRDS will be available for the `Submariner` operator to install its `ServiceMonitor`s resource.

#### Step 3 — Install `subctl` Submariner CLI:

<pre name="c8de" id="c8de" class="graf graf--pre graf-after--p">
curl -Ls [https://get.submariner.io](https://get.submariner.io) | bash  
export PATH=$PATH:~/.local/bin  
echo export PATH=\$PATH:~/.local/bin >> ~/.profile
</pre>

#### Step 4 — Deploy Submariner and join clusters to the mesh:  
1) Define Submariner Broker on `cluster1`(it is very recommended to read about the `Submariner` [architecture](https://submariner.io/getting-started/architecture/) and [the Broker](https://submariner.io/getting-started/architecture/broker/) role in it). In short, one of the Broker roles is to propagate changes in the _Submariner_ datapath to all clusters in the mesh from a central point, avoiding bombarding the system with messages directly between the clusters.  
2) Join `cluster1` and `cluster2` into the mesh

<pre name="0702" id="0702" class="graf graf--pre graf-after--p">
# Deploy cluster1 as the Broker cluster  
subctl deploy-broker --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1

# joins cluster1 and cluster2 into the mesh  
subctl join --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 submariner/broker-info.subm --clusterid cluster1 --natt=false  
subctl join --kubeconfig submariner/output/kubeconfigs/kind-config-cluster2 \
 submariner/broker-info.subm --clusterid cluster2 --natt=false
</pre>

You can now run:

<pre name="2701" id="2701" class="graf graf--pre graf-after--p">
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 get servicemonitor --all-namespaces
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 get servicemonitor --all-namespaces
</pre>

And see the relevant `ServiceMonitor` of _Submariner_

<pre name="4290" id="4290" class="graf graf--pre graf-after--p">AMESPACE             NAME                                    AGE  
monitoring            alertmanager                            6h24m  
monitoring            blackbox-exporter                       6h24m  
monitoring            coredns                                 6h24m  
monitoring            grafana                                 6h24m  
monitoring            kube-apiserver                          6h24m  
monitoring            kube-controller-manager                 6h24m  
monitoring            kube-scheduler                          6h24m  
monitoring            kube-state-metrics                      6h24m  
monitoring            kubelet                                 6h24m  
monitoring            node-exporter                           6h24m  
monitoring            prometheus-adapter                      6h24m  
monitoring            prometheus-k8s                          6h24m  
monitoring            prometheus-operator                     6h24m  
submariner-operator   submariner-gateway-metrics              6h22m  
submariner-operator   submariner-lighthouse-agent-metrics     6h22m  
submariner-operator   submariner-lighthouse-coredns-metrics   6h22m  
submariner-operator   submariner-operator-metrics             6h23m
</pre>

If for some reason the _Submariner_ `ServiceMonitor`objects are not present you can re-deploy them using

<pre name="e241" id="e241" class="graf graf--pre graf-after--p">
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1  apply -f \
 submariner-cheatsheet/prometheus/submariner-service-monitors/
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1  apply -f \
 submariner-cheatsheet/prometheus/submariner-service-monitors/
</pre>

You can also expose the _Prometheus_ server on one of the clusters and make sure its Targets and Service Discovery is configured correctly

<pre name="1282" id="1282" class="graf graf--pre graf-after--p">
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \  
 port-forward --address 0.0.0.0 svc/prometheus-k8s 9090 --namespace monitoring
</pre>

Targets — http://localhost:9090/targets |  Service Discovery — http://localhost:9090/service-discovery
:-------------------------:|:-------------------------:
<img src="https://miro.medium.com/max/3200/1*rR0HpKdMqzCkrtQ6G-E4BQ.png" width="450"/>  |  <img src="https://miro.medium.com/max/3140/1*ZDWU3N0YnN0fwPpo7JoIwQ.png" width="450"/>

I really urge you to go and read about _Prometheus_ and how it utilizes service discovery to discover metrics endpoints. Note that it is important to allow _Prometheus_ access to the `submariner-operator` namespace using ClusterRoleBingins — our `example.jsonnet` file allows for this configuration. If you are using another _Prometheus_ setup like Helm or others you will need to understand how to enable this access role.

#### Step 5 — Exporting the `Prometheus` server services:

<pre name="7930" id="7930" class="graf graf--pre graf-after--p">
subctl export service --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 --namespace monitoring prometheus-k8s  
subctl export service --kubeconfig submariner/output/kubeconfigs/kind-config-cluster2 --namespace monitoring prometheus-k8s
</pre>

This step is using the Kubernetes multi-cluster API implemented by _Submariner_ and exposes the `prometheus-k8s` service in both clusters to be accessed from any cluster in the mesh.

When using _Submariner_ you can access an exported service  
with the following DNS scheme: `service-name.spacename.svc.clusterset.local`.   
Submariner utilizes the Service Discovery mechanized within Kubernetes (by supplying a CoreDNS plugin that monitors changes in the multi-cluster service and supplies the relevant IP address to this DNS query). While the usage of this scheme is the recommended one, right now the implementation of this DNS plugin (named Lighthouse) will prefer to return the IP of the local service (i.e if we query this address from cluster1 and we have that kind of service deployed there it will always return the IP of that service). Alternately, if the service is not deployed on that cluster but some others, currently (September 2021) there is a Round-Robin mechanism that will return a different IP each time.

For these reasons, when we want to access a certain _Prometheus_ server on a certain cluster we will need to use a slightly different scheme: `cluster-name.service-name.namespace.svc.clusterset.local`.  
For example, to access _Prometheus_ metrics endpoint on a cluster named `cluster1`in namespace `monitoring`you can `curl` the following: `curl cluster1.prometheus-k8s.monitoring.svc.clusterset.local:9090\metrics`

#### Step 6 — Configuring `Grafana` with each of the `Prometheus` servers:

OK, so now we are ready to build some dashboards! There are several different ways to expose the Grafana Service from within the Kubernetes cluster. For our experiment purposes, we will just run in a different shell

<pre name="30ed" id="30ed" class="graf graf--pre graf-after--p">
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 port-forward --address 0.0.0.0 svc/grafana 3000 -n monitoring
</pre>

Open [http://localohost:3000](http://HTTP://localohost:3000)

1\.  Login with admin:admin (user:password) and add new Datasources

<p float="center">
  <img src="https://cdn-images-1.medium.com/max/800/1*5N1LDjgXi7j8hgDMYTkPwA.png" width="450"/>
  <img src="https://cdn-images-1.medium.com/max/800/1*affXy5DHVEpNl72B3lmpdg.png" width="450"/>
</p>

3\. Enter the DNS Address with the relevant Prometheus port as explained in the previous section (`cluster1.prometheus-k8s.monitoring.svc.clusterset.local` and `cluster2.prometheus-k8s.monitoring.svc.clusterset.local`)

![](https://cdn-images-1.medium.com/max/800/1*XwR_3MUimC1m2Bs1tmvwyA.png)

4\. Save and test connection (do the following per _Prometheus_ server)

![](https://cdn-images-1.medium.com/max/800/1*v13k9BaoyDgt7vU7Nwxa3w.png)

5\. Create your first Dashboard and add an empty panel

New dashboard |  Empty panel
:-------------------------:|:-------------------------:
<img src="https://cdn-images-1.medium.com/max/800/1*TZVCnR09s0FY6y3oCJZ6Cw.png" height="350"/>  |  <img src="https://cdn-images-1.medium.com/max/800/1*l38QgqAjBxVXc3NfOra2qg.png" width="500"/>

6\. Define some queries, let’s try and monitor some _Submariner_ metrics. The full list is described [at this link](https://submariner.io/operations/monitoring/). Choose the server from the list and add queries, in our example we added simple Submariner metrics for each cluster: `submariner_connections` and `submariner_connection_latency_seconds`

submariner_connections metrics |  submariner_connection_latency_seconds metrics
:-------------------------:|:-------------------------:
<img src="https://cdn-images-1.medium.com/max/600/1*tjqxxQ_RXMBLx7VEp-dyMA.png"/>  |  <img src="https://cdn-images-1.medium.com/max/800/1*HfqFyCKjCLO1oxzcVVxYUw.png" width="630"/>

#### Step 7 — Optional — Setup `Prometheus Federation`:  
_Prometheus_ offers a federation feature, where one can configure [hierarchical or cross-service federation](https://prometheus.io/docs/prometheus/latest/federation/). The main idea behind it is to allow the aggregation of metrics and information from several different _Prometheus_ servers (possibly across different locations). This is where the _Submariner_ multi-cluster setup comes in handy!

To allow this federation we will need to add additional scraping config to our main _Prometheus server.   
_Take a look at the `submariner-cheatsheet/prometheus/prometheus-additional.yaml`.

<pre name="3570" id="3570" class="graf graf--pre graf-after--p">
- job_name: "prometheus-federate"  
  honor_labels: true  
  metrics_path: '/federate'  
  params:  
    match[]: ['{job=~".+"}']  
  static_configs:  
  - targets: ["cluster2.prometheus-k8s.monitoring.svc.clusterset.local"]
</pre>

You can see the additional configuration, as described in the federation page of _Prometheus,_ we are adding `cluster2` a static scraping destination. The match labels basically define to scrape all jobs. Take a deeper look into [Prometheus Querying](https://prometheus.io/docs/prometheus/latest/querying/basics/) for more info.

Set `cluster1` as our main monitoring cluster and add the _Prometheus_ federation configuration to it

<pre name="0d3a" id="0d3a" class="graf graf--pre graf-after--p">
kubectl --kubeconfig \  
 submariner/output/kubeconfigs/kind-config-cluster1 \  
 create secret generic additional-scrape-configs \  
 --from-file=submariner-cheatsheet/prometheus/prometheus-additional.yaml \  
 --dry-run=client -oyaml > \  
 submariner-cheatsheet/prometheus/manifests/additional-scrape-configs.yaml
 </pre>

Note that after running this command a new file will be created under `submariner-cheatsheet/prometheus/manifest/additional-scrape-configs.yaml`.

Now we want to refer to this file from the main _Prometheus_ definition.  
let's edit it:

<pre name="fc72" id="fc72" class="graf graf--pre graf-after--p">
nano submariner-cheatsheet/prometheus/manifests/prometheus-prometheus.yaml
</pre>

Copy and paste the following to the end of the file we just opened:

<pre name="aa79" id="aa79" class="graf graf--pre graf-after--p">
additionalScrapeConfigs:  
  name: additional-scrape-configs  
  key: prometheus-additional.yaml
</pre>

And apply the new configuration, here we just run the whole manifest but you can run it specifically

<pre name="170c" id="170c" class="graf graf--pre graf-after--p">
kubectl --kubeconfig submariner/output/kubeconfigs/kind-config-cluster1 \
 apply -f submariner-cheatsheet/prometheus/manifests/
</pre>

That is it, you can now go to the server targets and see the new federation target configured!
