# Submariner

<span style="font-size:1.5em;">Submariner enables direct networking between Pods and Services in different Kubernetes clusters, either
on-premises or in the cloud.</span>

## Why Submariner

As Kubernetes gains adoption, teams are finding they must deploy and manage multiple clusters to facilitate features like geo-redundancy,
scale, and fault isolation for their applications. With Submariner, your applications and services can span multiple cloud providers, data
centers, and regions.

Submariner is completely open source, and designed to be network plugin (CNI) agnostic.

## What Submariner Provides

* Cross-cluster L3 connectivity using encrypted or unencrypted connections
* [Service Discovery](./getting-started/architecture/service-discovery/) across clusters
* [`subctl`](./operations/deployment/), a command-line utility that simplifies deployment and management
* Support for interconnecting clusters with [overlapping CIDRs](./getting-started/architecture/globalnet/)

{{% notice note %}}
A few requirements need to be met before you can begin. Check the [Prerequisites](./getting-started/#prerequisites) section for more
information.
{{% /notice %}}

{{% notice tip %}}
Check the [Quickstart Guides](./getting-started/quickstart/) section for deployment instructions.
{{% /notice %}}
