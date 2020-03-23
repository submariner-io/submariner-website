+++
title = "Roadmap"
date = 2020-02-19T20:24:34+01:00
weight = 100
pre = "<b>6. </b>"
+++

This is a preliminary community roadmap, it's not written in stone, but it can serve
as a guideline about what's ahead.

Please see details of previous releases [here](../releases)

### v0.2.0
* Support for Overlapping CIDRs
* Improve documentation and website

### Future releases
* Removing the kubefed dependency from Lighthouse service discovery
* De-duplicate E2E scripts and go code, into shipyard.
* Libreswan support
* Support for multiple cable engines, including wireguard
* Auto detecting NAT vs non-NAT scenarios.
* Supporting different ports for IPSEC for each cluster
* Measuring and improving A/P HA (different scenarios)
* Support for network policies via coastguard
* Monitoring and reporting of tunnel endpoints (status of connection, bandwidth, pps, etc..)
* Monitoring connectivity over port 4800 between routeagent nodes.
* Support for non-kubeproxy / iptables based implementations, starting with OVN
* HA Active/Active gateway support (ECMP?) (keep in mind non-iptables-kubeproxy based implementations)
* Testing with Istio
