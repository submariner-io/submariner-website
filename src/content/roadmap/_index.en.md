+++
title = "Roadmap"
date = 2020-02-19T20:24:34+01:00
weight = 40
pre = "<b>8. </b>"
+++

This is a preliminary community roadmap. It represents our best guess at broad priorities, and can serve as a general guideline.

Details of past releases are described [here](../releases).

## v0.7.0

* In progress: <https://github.com/orgs/submariner-io/projects/10>

## Future Releases

* Auto detecting NAT vs non-NAT scenarios (<https://github.com/submariner-io/submariner/issues/300>)
* Support different IPsec ports for each cluster
* Network Policy across clusters (Coastguard)
* Support for finer-grained connectivity policies (<https://github.com/submariner-io/submariner/issues/533>)
* Support for OVN-based clusters
* Globalnet: annotating Global IPs per namespaces (<https://github.com/submariner-io/submariner/issues/528>)
* Globalnet: only annotate Services for which a ServiceExport has been created (<https://github.com/submariner-io/submariner/issues/652>)
* More tunnel encapsulation options
* Dynamic routing with BGP to support multi-path forwarding across gateways
* Testing with multi-cluster Istio

## How You Can Help

If we are missing something that would make Submariner more useful to you, please let us know. The best way is to file an issue and include
information on how you intend to use Submariner with that feature.
