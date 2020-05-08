---
title: "Submariner"
---

# Submariner

![Illustration](/images/frontpage-illustration-animated.svg)

#### Submariner enables direct networking between pods and services in different Kubernetes clusters, either on premise or in the cloud. 

## Why Submariner?

As Kubernetes gains adoption, teams are finding they must deploy and manage multiple clusters to facilitate features like geo-redundancy, scale, and fault isolation for their applications. With Submariner, your applications and services can span multiple cloud providers, data centers, and regions.

Submariner is completely open source, and designed to be network plugin (CNI) agnostic.

### What Submariner Provides?

* Cross-cluster L3 connectivity using encrypted VPN tunnels
* Service Discovery across clusters via [Lighthouse](./architecture/components/lighthouse/)
* [subctl](./deployment/), a friendly deployment tool 
* Support for interconnecting clusters with [overlapping CIDRs](./architecture/globalnet/)

<style>
.mygrid {  
    display: grid;
    grid-gap: 12px;  
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    grid-template-rows: repeat(2, 100px);  
}

</style>

<div class="mygrid">  
  <div>
    <h5> Connecting containers with Submariner</h5>
    <div> {{< youtube fMhZRNn0fxQ >}}</div>
  </div>
  <div>
    <h5> Deploying Submariner
</h5>
    <div> {{< youtube cInmBXuZsU8 >}}</div>
  </div>
  <div>
    <h5> Service discovery in Submariner</h5>
    <div> {{< youtube tXsemQPNhyQ >}}</div>
  </div>
</div>


{{% notice tip %}}
Check the [Quickstart guide](./quickstart/) section for deployment instructions.
{{% /notice %}}
