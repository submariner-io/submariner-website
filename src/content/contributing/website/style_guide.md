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

Term | Usage
:--- | :----
Admiral | The project name *Admiral* should always be capitalized.
Broker | The design pattern component *Broker* should always be capitalized.
ClusterSet | The Kubernetes object *ClusterSet* proposed in KEP1645 should always be CamelCase.
Cluster set | The words "cluster set" should be used as a term for a group of clusters, but not the proposed Kubernetes object.
Coastguard | The project name *Coastguard* should always be capitalized.
Globalnet | The feature name *Globalnet* is one word, and so should always be capitalized and should have a lowercase "n".
Lighthouse | The project name *Lighthouse* should always be capitalized.
Shipyard | The project name *Shipyard* should always be capitalized.
`subctl` | The artifact `subctl` should not be capitalized and should be formatted in code style.
Submariner | The project name *Submariner* should always be capitalized.

### Pronunciation of "Submariner"

Both the "Sub-mariner" ("Sub-MARE-en-er", like the watch) and "Submarine-er" ("Sub-muh-REEN-er", like the Navy job) pronunciations are okay.

The second option, "Submarine-er", has historically been more common as Chris Kim (the initial creator) imagined the iconography of the
project as related to submarine cables.

[kube docs guide]: https://kubernetes.io/docs/contribute/style/style-guide
