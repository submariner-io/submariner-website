---
title: "Submariner"
---

![Submariner](/images/frontpage-illustration-logo.svg)

#### Submariner enables direct networking between pods and services in different Kubernetes clusters, either on premise or in the cloud. 

## Why Submariner?

As Kubernetes gains adoption, teams are finding they must deploy and manage multiple clusters to facilitate features like geo-redundancy, scale, and fault isolation for their applications. With Submariner, your applications and services can span multiple cloud providers, data centers, and regions.

Submariner is completely open source, and designed to be network plugin (CNI) agnostic.


## What Submariner Provides?

* Cross-cluster L3 connectivity using encrypted VPN tunnels
* [Service Discovery](./architecture/service-discovery/) across clusters
* [subctl](./deployment/), a friendly deployment tool 
* Support for interconnecting clusters with [overlapping CIDRs](./architecture/globalnet/)

<style>
.mygrid {  
    display: grid;
    grid-gap: 12px;  
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    grid-template-rows: repeat(2, 100px);  
    padding-bottom: 5em;
}
.mygrid h5 {
    text-align: center;
}

</style>

## Demos
<div class="mygrid">
  <div>
    <div> {{< youtube fMhZRNn0fxQ >}}</div>
    <h5> Connecting Pods and Services across Clusters</h5>
  </div>
  <div>
    <div> {{< youtube cInmBXuZsU8 >}}</div>
    <h5> Deploying Submariner with subctl</h5>
  </div>
  <div>
    <div> {{< youtube tXsemQPNhyQ >}}</div>
    <h5> Cross-cluster Service Discovery</h5>
  </div>
</div>

{{% notice tip %}}
Check the [Quickstart guide](./quickstart/) section for deployment instructions.
{{% /notice %}}
