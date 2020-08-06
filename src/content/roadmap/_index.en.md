+++
title = "Roadmap"
date = 2020-02-19T20:24:34+01:00
weight = 35
pre = "<b>7. </b>"
+++

This is a preliminary community roadmap. It represents our best guess at broad priorities, and can serve as a general guideline.

Details of past releases are described [here](../releases).

## v0.6.0

* In progress: <https://github.com/orgs/submariner-io/projects/9>

## Future Releases

* Auto detecting NAT vs non-NAT scenarios (https://github.com/submariner-io/submariner/issues/300)
* Support different IPsec ports for each cluster
* Measuring and improving High Availability for gateway-labeled nodes
* Network Policy across clusters (Coastguard)
* Richer monitoring and alerting with Prometheus
* Support for finer-grained connectivity policies (https://github.com/submariner-io/submariner/issues/533)
* Support for more network plugins (OVN, Calico, others)
* Globalnet: annotating Global IPs per namespaces
* Globalnet: only annotate Services for which a ServiceExport has been created
* More tunnel encapsulation options
* Dynamic routing with BGP to support multi-path forwarding across gateways
* Testing with multi-cluster Istio

## How You Can Help

If we are missing something that would make Submariner more useful to you, please let us know. The best way is to file an issue and include information on how you intend to use Submariner with that feature.
