+++
title = "Getting Started"
date = 2020-02-19T20:03:44+01:00
weight = 10
pre = "<b>1. </b>"
+++

## Basic Overview

Submariner consists of several main components that work in conjunction to securely connect workloads across multiple Kubernetes clusters.
For more information about Submariner's architecture, please refer to the [Architecture](./architecture) section.

### The Broker

The Broker is an API that all participating clusters are given access to, and where two objects are exchanged via CRDs in `.submariner.io`:

* Cluster: defines a participating cluster and its IP CIDRs.
* Endpoint: defines a connection endpoint to a cluster, and the reachable cluster IPs from the endpoint.

The Broker must be deployed on a single Kubernetes cluster. This cluster’s API server must be reachable by all Kubernetes clusters connected
by Submariner. It can be a dedicated cluster, or one of the connected clusters.

### The Submariner Deployment on a Cluster

Once Submariner is deployed on a cluster with the proper credentials to the Broker it will exchange Cluster and Endpoint objects with other
clusters (via push/pull/watching), and start forming connections and routes to other clusters.

## Prerequisites

Submariner has a few requirements to get started:

* At least two Kubernetes clusters, one of which is designated to serve as the central Broker that is accessible by all of your connected
clusters; this can be one of your connected clusters, or a dedicated cluster.
* The oldest [tested Kubernetes version](../development/building-testing/ci-maintenance/#kubernetes-versions) is 1.19.
  Older versions are known not to work with Submariner. Service discovery requires Kubernetes 1.21 or later.
* Non-overlapping Pod and Service CIDRs between clusters. This is to prevent routing conflicts. For cases where addresses **do
overlap**, [Globalnet](./architecture/globalnet) can be set up.
* IP reachability between the gateway nodes. When connecting two clusters, the gateways must have at least one-way connectivity
  to each other on their public or private IP address and encapsulation port. This is needed for creating the tunnels between
  the clusters. The default encapsulation port is 4500/UDP, for [NAT Traversal](./../operations/nat-traversal) discovery port
  4490/UDP is used.
For clusters behind corporate firewalls that block the default ports, Submariner also supports NAT Traversal
(NAT-T) with the option to set custom non-standard ports like 4501/UDP.
* Submariner uses UDP port 4800 to encapsulate Pod traffic from worker and master nodes to the Gateway nodes. This is required in order to
preserve the source IP addresses of the Pods. Ensure that firewall configuration allows 4800/UDP across all nodes in the cluster in both
directions. This is not a requirement when using OVN-Kubernetes CNI.
* If the gateway nodes are directly reachable over their private IPs without any NAT in between, ensure that firewall configuration allows
ESP protocol on the gateway nodes.
* Worker node IPs on all connected clusters must be outside of the Pod/Service CIDR ranges.
* Submariner can be deployed on x86-64 and ARM64 nodes.
  (Submariner components are deployed on _all_ nodes in the cluster,
  so all nodes must be x86-64 or ARM64.)

An example of three clusters configured to use with Submariner (without Globalnet) would look like the following:

| Cluster Name | Provider | Pod  CIDR    | Service CIDR | Cluster Nodes CIDR |
|:-------------|:---------|:-------------|:-------------|--------------------|
| broker       | AWS      | 10.42.0.0/16 | 10.43.0.0/16 | 192.168.1.0/24     |
| west         | vSphere  | 10.0.0.0/16  | 10.1.0.0/16  | 192.168.1.0/24     |
| east         | On-Prem  | 10.98.0.0/16 | 10.99.0.0/16 | 192.168.1.0/24     |

### systemd-networkd

On nodes managed by `systemd-networkd` (e.g. Flatcar, Ubuntu Server), the routes and routing policy rules programmed by Submariner may be removed because `systemd-networkd` treats them as foreign. This requires systemd 249 or later (`ManageForeignRoutes=` was added in 246 and `ManageForeignRoutingPolicyRules=` in 249); on systemd 246–248 the routing policy rules can still be removed. On every gateway node, create `/etc/systemd/networkd.conf.d/10-submariner-foreign-routes.conf` with the following content and restart `systemd-networkd`:

```ini
[Network]
ManageForeignRoutes=no
ManageForeignRoutingPolicyRules=no
```

The prevents future removal; it does not restore entries that are already missing. To recover, restart the route agent on the affected gateway node so that it re-installs the rule and routes:

```shell
kubectl -n submariner-operator delete pod -l app=submariner-routeagent --field-selector spec.nodeName=<gateway node>
```

If the nodes are not reachable over SSH, use a privileged DaemonSet that does the work, for example:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: submariner-gateway-node-config
  namespace: submariner-operator
  labels:
    app: submariner-gateway-node-config
spec:
  selector:
    matchLabels:
      app: submariner-gateway-node-config
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: submariner-gateway-node-config
    spec:
      serviceAccountName: submariner-gateway-node-config
      automountServiceAccountToken: false
      nodeSelector:
        submariner.io/gateway: 'true'
      tolerations:
        - operator: Exists
      terminationGracePeriodSeconds: 5
      securityContext:
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: networkd-dropin
          image: docker.io/library/busybox:1.37.0
          command:
            - sh
            - -c
            - |
              set -eu
              f=/host/networkd.conf.d/10-submariner-foreign-routes.conf
              want='[Network]
              ManageForeignRoutes=no
              ManageForeignRoutingPolicyRules=no'
              if [ "$(cat "$f" 2>/dev/null)" = "$want" ]; then
                echo "$f up to date"
              else
                printf '%s\n' "$want" > "$f"
                chmod 0644 "$f"
                echo "$f written; effective at the next systemd-networkd start"
              fi
              trap 'exit 0' TERM INT
              while :; do sleep 3600 & wait $!; done
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop: [ALL]
          resources:
            requests:
              cpu: 1m
              memory: 8Mi
            limits:
              memory: 16Mi
          volumeMounts:
            - name: networkd-conf-d
              mountPath: /host/networkd.conf.d
```

Note that this is a privileged container and this might not be compatible with your security policies, adapt as needed.

## Support Matrix

Submariner is designed to be cloud provider agnostic, and should run in any standard Kubernetes cluster. Submariner has been tested with the
following network (CNI) Plugins:

* [OpenShift-SDN](https://github.com/openshift/sdn)
* [Weave](https://github.com/weaveworks/weave)
* [Flannel](https://github.com/coreos/flannel)
* [Canal](https://docs.tigera.io/calico/latest/getting-started/kubernetes/flannel/install-for-flannel)
* [Calico](https://www.projectcalico.org/) (see the [Calico-specific deployment instructions](../operations/deployment/calico/))
* [OVN](https://github.com/ovn-org/ovn-kubernetes) - Requires OVN NorthBound DB version 6.1.0+

Submariner supports all currently-supported Kubernetes versions, as determined by [the Kubernetes release policy](https://kubernetes.io/releases/).

## Deployment

Submariner is deployed and managed using its Operator. [Submariner's Operator](https://github.com/submariner-io/submariner-operator) can be
deployed using [subctl](../operations/deployment) or [Helm](../operations/deployment/helm).

The recommended deployment method is `subctl`, as it is currently the default in CI and provides diagnostic features.
