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

OpenShift 4.5 or later will automatically discover the Submariner metrics with service monitors in the
`openshift-monitoring` namespace.

## Metrics Reference

Submariner metrics provide insights into both the state of Submariner itself, as well as the inter-cluster network behavior of your
cluster set. All Submariner metrics are exported within the `submariner-operator` namespace by default.

The following metrics are exposed currently:

### Submariner Gateway
<!-- markdownlint-disable line-length -->
<!-- markdownlint-disable no-trailing-spaces -->
| Name                                          | Label                                                               | Description                       
|:----------------------------------------------|:--------------------------------------------------------------------|:--------------------------------------------------------------|
| `submariner_gateways`                         |                                                                     | The number of gateways in the cluster                         |
| `submariner_gateway_creation_timestamp`       | `local_cluster`, `local_hostname`                                   | Timestamp of gateway creation time                            |
| `submariner_gateway_sync_iterations`          |                                                                     | Gateway synchronization iterations                            |
| `submariner_gateway_rx_bytes`                 | `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`   | Count of bytes received by cable driver and cable
| `submariner_gateway_tx_bytes`                 | `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`   | Count of bytes transmitted by cable driver and cable

### Submariner Connections

| Name                                          | Label                                                               | Description
|:----------------------------------------------|:--------------------------------------------------------------------|:--------------------------------------------------------------|
| `submariner_requested_connections`            | `local_cluster`, `local_hostname`, `remote_cluster`, `remote_hostname`, `status`: “connecting”, “connected”, or “error” | The number of connections by endpoint and status
| `submariner_connections`                      | `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip`, `status`: “connecting”, “connected”, or “error” | The number of connections and corresponding status by cable driver and cable
| `submariner_connection_established_timestamp` | `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip` | Timestamp of last successful connection established by cable driver and cable
| `submariner_connection_latency_seconds`       | `cable_driver`, `local_cluster`, `local_hostname`, `local_endpoint_ip`, `remote_cluster`, `remote_hostname`, `remote_endpoint_ip` | Connection latency in seconds; last RTT, by cable driver and cable

### Globalnet

| Name                                            | Label                                                               | Description
|:------------------------------------------------|:--------------------------------------------------------------------|:--------------------------------------------------------------|
| `submariner_global_IP_availability`             | `cidr`                                                              | Count of available global IPs per CIDR
| `submariner_global_IP_allocated`                | `cidr`                                                              | Count of all global IPs allocated for Pods/Services per CIDR
| `submariner_global_egress_IP_allocated`         | `cidr`                                                              | Count of global Egress IPs allocated for Pods/Services per CIDR
| `submariner_cluster_global_egress_IP_allocated` | `cidr`                                                              | Count of global Egress IPs allocated for clusters per CIDR
| `submariner_global_ingress_IP_allocated`        | `cidr`                                                              | Count of global Ingress IPs allocated for Pods/Services per CIDR

### Service Discovery

| Name                                          | Label                                                               | Description
|:----------------------------------------------|:--------------------------------------------------------------------|:--------------------------------------------------------------|
| `submariner_service_import`                   | `direction`, `operation`, `syncer_name` | Count of imported Services
| `submariner_service_export`                   | `direction`, `operation`, `syncer_name`                                                                                        | Count of exported Services
| `submariner_service_discovery_query`  | `source_cluster`, `destination_cluster`, `destination_service_name`, `destination_service_ip`, `destination_service_namespace` | Count DNS queries handled by Lighthouse plugin
