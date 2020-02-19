+++
date = 2016-04-09T16:50:16+02:00
title = "Releases"
pre = "<b>4. </b>"
weight = 15
+++


## v0.1.0 Submariner with some light

> This release has focused on stability, bugfixes and making https://github.com/submariner.io/lighthouse available as developer preview via subctl deployments.

* Several bugfixes and enhancements around HA failover (#346, #348, #332)
* Migrated to Daemonsets for submariner gateway deployment
* Added support for hostNetwork to remote pod/service connectivity (#288)
* Auto detection and configuration of MTU for vx-submariner, jumbo frames support (#301)
* Support for updated strongswan (#288)
* Better iptables detection for some hosts (#227)

> subctl and the submariner operator have the following improvements

* support to verify-connectivity between two connected clusters
* deployment of submariner gateways based in daemonsets instead of deployments
* renaming submariner pods to "submariner-gateway" pods for clarity
* print version details on crash (subctl)
* stop storing IPSEC key on broker during deploy-broker, now it's only contained into the .subm file
* version command for subctl
* nicer spinners during deployment (thanks to kind)


## v0.0.3 -- KubeCon NA 2019

>Submariner has been greatly enhanced to allow operators to deploy into Kubernetes clusters without the necessity for layer-2 adjacency for nodes. Submariner now allows for VXLAN interconnectivity between nodes (facilitated by the route agent). Subctl
was created to make deployment of submariner easier.

## v0.0.1 Second Submariner release
## v0.0.1 First Submariner release