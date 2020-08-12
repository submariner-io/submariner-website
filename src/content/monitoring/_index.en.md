+++
title = "Monitoring"
date = 2020-08-12T16:02:00+02:00
weight = 20
pre = "<b>4. </b>"
+++

## Basic Overview

Submariner provides a number of Prometheus metrics, and sets up `ServiceMonitor` instances which allow these metrics to be scraped by an
in-cluster Prometheus instance.

The following metrics are exposed currently:

* `submariner_gateways`: the number of gateways in the cluster;

* `submariner_connections`: the number of connections to other clusters, with the following labels:

  * `local_cluster`: the local cluster name
  * `local_hostname`: the local hostname
  * `remote_cluster`: the remote cluster name
  * `remote_hostname`: the remote hostname
  * `status`: the connection status (“connecting”, “connected”, or “error”)

### OpenShift setup

OpenShift 4.5 or later can automatically discover the Submariner metrics.
This currently requires enabling user workload monitoring; see
[the OpenShift documentation](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html/monitoring/monitoring-your-own-services)
for details.

### Prometheus operator

To start monitoring Submariner using the Prometheus operator, Prometheus needs to be configured to scrape the Submariner operator’s
namespace (`submariner-operator` by default). The specifics depend on your Prometheus deployment, but typically, this will require
you to:

* add the Submariner operator’s namespace to Prometheus’ `ClusterRoleBinding`;

* ensure that Prometheus’ configuration doesn’t prevent it from scraping this namespace.

A minimal `Prometheus` object providing access to the Submariner metrics is as follows:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  labels:
    prometheus: prometheus
spec:
  replicas: 1
  serviceAccountName: prometheus
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector:
    matchLabels:
      name: submariner-operator
```
