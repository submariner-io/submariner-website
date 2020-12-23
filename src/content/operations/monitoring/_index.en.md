+++
title = "Monitoring"
date = 2020-08-12T16:02:00+02:00
weight = 20
+++

## Basic Overview

Submariner provides a number of [Prometheus](https://prometheus.io/) metrics, and sets up `ServiceMonitor` instances which allow these
metrics to be scraped by an in-cluster Prometheus deployment. Prometheus is a pluggable metrics collection and storage system and can act as
a data source for [Grafana](https://grafana.com/), a metrics visualization frontend. Unlike some metrics collectors, Prometheus requires the
collectors to pull metrics from each source.

## Exposed Metrics

Submariner metrics provide insights into both the state of Submariner itself, as well as the inter-cluster network behavior of your
cluster set. All Submariner metrics are exported within the `submariner-operator` namespace by default.

The following metrics are exposed currently:

* `submariner_gateways`: the number of gateways in the cluster

* `submariner_gateway_creation_timestamp`: timestamp of gateway creation time, with the following labels:

  * `local_cluster`: the local cluster name
  * `local_hostname`: the local hostname

* `submariner_connections`: the number of connections to other clusters, with the following labels:

  * `local_cluster`: the local cluster name
  * `local_hostname`: the local hostname
  * `remote_cluster`: the remote cluster name
  * `remote_hostname`: the remote hostname
  * `status`: the connection status (“connecting”, “connected”, or “error”)

* `gateway_rx_bytes`: count of bytes received by cable driver and cable (labels: `cable_driver`, `local_cluster`, `local_hostname`,
`local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`)

* `gateway_tx_bytes`: count of bytes transmitted by cable driver and cable (labels: `cable_driver`, `local_cluster`, `local_hostname`,
`local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`)

* `connection_established_timestamp`: timestamp of last successful connection established by cable driver and cable
(labels: `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`)

* `connection_latency_seconds`: connection latency in seconds; last RTT, by cable driver and cable
(labels: `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`)

* `connections`: the number of connections and corresponding status by cable driver and cable
(labels: `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`,
`status`)

### Prometheus Operator

To start monitoring Submariner using the Prometheus Operator, Prometheus needs to be configured to scrape the Submariner Operator’s
namespace (`submariner-operator` by default). The specifics depend on your Prometheus deployment, but typically, this will require
you to:

* Add the Submariner Operator’s namespace to Prometheus’ `ClusterRoleBinding`.

* Ensure that Prometheus’ configuration doesn’t prevent it from scraping this namespace.

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

### OpenShift Setup

OpenShift 4.5 or later can automatically discover the Submariner metrics.
This requires enabling user workload monitoring; see the
[OpenShift 4.5](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.5/html/monitoring/monitoring-your-own-services)
or
[OpenShift 4.6](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.6/html/monitoring/enabling-monitoring-for-user-defined-projects)
documentation for details.
