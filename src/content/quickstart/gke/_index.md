---
date: 2020-02-21T13:36:18+01:00
title: "Google GKE"
weight: 20
---

Google Kubernetes Engine is a platform for containerized applications provided by google,
you can find more about the platform [here](https://cloud.google.com/kubernetes-engine)


## Setup the command line utility

Download the google cloud sdk: 

> https://cloud.google.com/sdk

Find more detailed instructions for your platform here:

> https://cloud.google.com/sdk/docs/quickstarts

Make sure the necessary components of the gcloud shell are installed

```
source ~/.bashrc # if you just installed the gcloud shell
gcloud components install kubectl beta
gcloud init
```


## Create and deploy cluster A

In this step you will deploy cluster A, with the default IP CIDRs

| Pod CIDR        | Service CIDR |
|-----------------|--------------|
|192.168.128.0/18 |172.17.0.0/16 |	


```bash
gcloud container clusters create cluster-a \
            --machine-type=g1-small \
            --cluster-ipv4-cidr=192.168.128.0/18 \
            --services-ipv4-cidr=172.17.0.0/16 \
            --enable-ip-alias 
    
```

The create cluster step will take some time, you can create Cluster B in parallel if you wish.

{{% notice info %}}
  
**Notes about network CIDRs**: Please note that the default VPC subnets per zone
in google cloud (10.128.0.0/9) for worker nodes can conflict with the Cluster CIDRs
for some k8s distributions, see: https://cloud.google.com/vpc/docs/vpc#ip-ranges
{{% /notice %}}


## Create and deploy cluster B

In this step you will deploy cluster B, modifying the default IP CIDRs

| Pod CIDR        | Service CIDR   |
|-----------------|----------------|
|192.168.192.0/18 |10.4.128.0/19   |

```bash
gcloud container clusters create cluster-b \
    --machine-type=g1-small \
    --cluster-ipv4-cidr=192.168.192.0/18 \
    --services-ipv4-cidr=10.4.128.0/19 \
    --enable-ip-alias 

```

## Make your clusters ready for submariner

Submariner gateway nodes need to be able to accept traffic over ports 4500/UDP and 500/UDP
when using IPSEC. In addition we use port 4800/UDP to encapsulate traffic from the worker nodes
to the gateway nodes and ensuring that Pod IP addresses are preserved.

```bash
gcloud compute firewall-rules create submariner-traffic \
               --allow=udp:4800 --allow=udp:4500 --allow=udp:500

```

## Install subctl

{{< subctl-install >}}

## Use cluster-a as broker

```bash
gcloud container clusters get-credentials cluster-a
subctl deploy-broker
```

## Join cluster-a and cluster-b to the broker

```bash
gcloud container clusters get-credentials cluster-a
subctl join broker-info.subm --cluster-id cluster-a
```

You should expect an interaction with subctl which looks like:
```
* broker-info.subm says broker is at: https://104.199.21.143
? Which node should be used as the gateway? gke-cluster-a-default-pool-b0d8c878-1c4x
 ✓ Deploying the Submariner operator
 ✓ Created operator CRDs
 ✓ Created operator namespace: submariner-operator
 ✓ Created operator service account and role
 ✓ Deployed the operator successfully
* Discovering network details
    Discovered network details:
        Network plugin:  generic
        Service CIDRs: []
        Cluster CIDRs: [192.168.128.0/18]
? What's the ClusterIP service CIDR for your cluster? 172.17.0.0/16
 ✓ Discovering multi cluster details
 ✓ Deploying Submariner
```



```bash
gcloud container clusters get-credentials cluster-b
subctl join broker-info.subm --clusterid cluster-b
```

```
* broker-info.subm says broker is at: https://104.199.21.143
? Which node should be used as the gateway?  gke-cluster-b-default-pool-7e34ee5c-3mp1
 ✓ Deploying the Submariner operator 
* Discovering network details
    Discovered network details:
        Network plugin:  generic
        Service CIDRs: []
        Cluster CIDRs: [192.168.192.0/18]
? What's the ClusterIP service CIDR for your cluster? 10.4.128.0/19
⠈⠁ Discovering multi cluster details     Discovered global network details for Cluster cluster-a:
        ServiceCidrs: [172.17.0.0/16]
        ClusterCidrs: [192.168.128.0/18]
        Global CIDRs: []
 ✓ Discovering multi cluster details
 ✓ Deploying Submariner


```

## Verify connectivity

This will run a series of E2E tests to verify proper connectivity between the cluster pods and services

```bash
gcloud container clusters get-credentials cluster-a
kubectl config view --flatten >kubeconfig-cluster-a

gcloud container clusters get-credentials cluster-b
kubectl config view --flatten >kubeconfig-cluster-b

subctl verify-connectivity kubeconfig-cluster-a kubeconfig-cluster-b --verbose
```
