---
title: "Docs Style Guide"
date: 2020-04-29T19:09:55+02:00
weight: 5
---

## Documentation Style Guide

This guide is meant to help keep our documentation consistent and ease the
contribution and review process.

Submariner follows the [Kubernetes Documentation Style Guide][kube docs guide]
wherever relevant. This is a Submariner-specific extension of those practices.

### Submariner.io Word List

A list of Submariner-specific terms and words to be used consistently across
the site.

<!-- markdownlint-disable line-length -->
Term | Usage
:--- | :----
Admiral | The project name *Admiral* should always be capitalized.
Broker | The design pattern component *Broker* should always be capitalized.
`ClusterSet` | The Kubernetes object *ClusterSet* proposed in KEP1645 should always be CamelCase and formatted in code style.
Cluster set | The words "cluster set" should be used as a term for a group of clusters, but not the proposed Kubernetes object.
Coastguard | The project name *Coastguard* should always be capitalized.
Globalnet | The feature name *Globalnet* is one word, and so should always be capitalized and should have a lowercase "n".
IPsec | The protocol *IPsec* should follow the capitalization used by [RFCs](https://datatracker.ietf.org/doc/html/rfc6071) and [popular sources](https://en.wikipedia.org/wiki/IPsec).
iptables | The application *iptables* consistently uses all-lowercase. Follow their convention, but avoid starting a sentence with "iptables".
K8s | The project nickname *K8s* should typically be expanded to "Kubernetes".
kind | The tool *kind* consistently uses all-lowercase. Follow their convention, but avoid starting a sentence with "kind".
Lighthouse | The project name *Lighthouse* should always be capitalized.
Operator | The design pattern *Operator* should always be capitalized.
Shipyard | The project name *Shipyard* should always be capitalized.
`subctl` | The artifact `subctl` should not be capitalized and should be formatted in code style.
Submariner | The project name *Submariner* should always be capitalized.
<!-- markdownlint-enable line-length -->

### Pronunciation of "Submariner"

Both the "Sub-mariner" ("Sub-MARE-en-er", like the watch) and "Submarine-er" ("Sub-muh-REEN-er", like the Navy job) pronunciations are okay.

The second option, "Submarine-er", has historically been more common as Chris Kim (the initial creator) imagined the iconography of the
project as related to submarine cables.

### Date Format

Submariner follows ISO 8601 for date formats (YYYY-MM-DD or YYYY-MM).

[kube docs guide]: https://kubernetes.io/docs/contribute/style/style-guide

### Use Versions, not "New"

Avoid referring to things as "new", as this will become out of date and require maintenance.
Instead, document the versions that introduce or remove features:

> As of 0.12.0, a `subctl` image is provided ...
