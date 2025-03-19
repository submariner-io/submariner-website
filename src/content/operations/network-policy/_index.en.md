---
title: "Network Policy"
date: 2025-03-19T14:06:11+02:00
weight: 28
---

Submariner can be used with `NetworkPolicy` objects, with some caveats.

## Local operation

Since Submariner doesn’t modify the cluster-local network, network policies apply as-is.
This includes `.clusterset.local` access to local services: this obeys local network policies.
Thus a deny-all, allow-specific policy will only allow pods to access exported services
that are available locally if their local service is accessible.

## Remote operation

Network policies also affect access to remote resources: pods that aren’t allowed to access
resources other than those granted by a network policy won’t be able to access remote resources
(either pods or exported services).

Submariner currently doesn’t provide any explicit support for `NetworkPolicy` objects,
which means that access to remote pods and services can only be controlled using locally-relevant
information.
That effectively means that the only way to specify network policies controlling access to remote
pods or services is by referring to the pods’ or services’ IP addresses in the target clusters.
Submariner preserves source IP addresses in packets entering the clusters,
so remote IP addresses can be used unchanged.
If you’re using Globalnet, the addresses used in policies need to be Globalnet addresses.

The gateway is transparent and doesn’t need to be referenced in network policies.

For example for egress:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-netshoot-to-nginx
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: netshoot
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 100.66.213.87/32
    - podSelector:
        matchLabels:
          app: nginx-demo
```

allows “netshoot” pods to access local pods providing the “nginx-demo” app,
and a specific pod service IP address in the remote cluster.

For ingress:

```yaml
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx-from-netshoot
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: nginx-demo
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 10.131.0.0/16
    - podSelector:
        matchLabels:
          app: netshoot
```

implements the same access as above on the receiving side,
without the same level of control for the remote end —
access is granted to any pod in the given CIDR (an entire cluster’s pod CIDR).
