# Submariner

<span style="font-size:1.5em;">Submariner enables direct networking between Pods and Services in different Kubernetes clusters, either on premise or in the cloud.</span>

## Why Submariner

As Kubernetes gains adoption, teams are finding they must deploy and manage multiple clusters to facilitate features like geo-redundancy, scale, and fault isolation for their applications. With Submariner, your applications and services can span multiple cloud providers, data centers, and regions.

Submariner is completely open source, and designed to be network plugin (CNI) agnostic.

## What Submariner Provides

* Cross-cluster L3 connectivity using encrypted VPN tunnels
* [Service Discovery](./architecture/service-discovery/) across clusters
* [subctl](./deployment/), a friendly deployment tool
* Support for interconnecting clusters with [overlapping CIDRs](./architecture/globalnet/)

{{% notice tip %}}
Check the [Quickstart guide](./quickstart/) section for deployment instructions.
{{% /notice %}}
