+++
title = "Roadmap"
date = 2020-02-19T20:24:34+01:00
weight = 100
pre = "<b>6. </b>"
+++

This is a preliminary community roadmap, it's not written in stone, but it can serve
as a guideline about what's ahead.

Please see details of previous releases [here](../releases)

### v0.1.1

* Stabilization of new lighthouse related features and deployment
* Bugfixes
* Working with the OpenShift CoreDNS distribution to make lighthouse compiled in their container

### v0.2.0

* Support for Overlapping CIDRs
* Improve documentation and website
* (internal) start using Armada to deploy multiple clusters in CI
* Support for multiple cable engines, including wireguard

### v0.3.0

* Auto detecting NAT vs non-NAT scenarios.
* Supporting different ports for IPSEC for each cluster
* Removing the kubefed dependency from Lighthouse service discovery
* Measuring and improving A/P HA (different scenarios)
* Libreswan support

### v0.4.0 

* Support for network policies via coastguard
* Monitoring and reporting of tunnel endpoints (status of connection, bandwidth, pps, etc..)
* Monitoring connectivity over port 4800 between routeagent nodes.
* Support for non-kubeproxy / iptables based implementations, starting with OVN

### v0.5.0
* HA Active/Active gateway support (ECMP?) (keep in mind non-iptables-kubeproxy based implementations)
* Testing with Istio
