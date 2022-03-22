---
title: "Secrets"
weight: 60
---

The following Kubernetes Secrets are used to store sensitive information
(with the usual caveat that
[Secrets don't protect sensitive information](https://kubernetes.io/docs/concepts/configuration/secret/#information-security-for-secrets)):

* `broker-secret-` with a Kubernetes-generated suffix, which stores the
  credentials used to connect to the Broker.
* `submariner-ipsec-psk`, which stores the PSK used for IPsec connections.

These secrets are stored in the operator’s namespace, `submariner-operator`.

The following fields in the Submariner specification store the names to
use:

* `BrokerK8sSecret` gives the name of the Broker Secret.
* `CeIPSecPSKSecret` gives the name of the IPsec Secret.

The ServiceDiscovery specification also has a `BrokerK8sSecret` since it
needs access to the Broker.

The Operator presents the Secrets as corresponding volumes in the appropriate
deployments to make them available to the relevant Submariner components.
