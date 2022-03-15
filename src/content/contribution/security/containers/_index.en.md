---
title: "Container Requirements"
weight: 50
---

Current privilege setup is as follows, for non-test containers deployed by Submariner.
Production containers not described here don’t use extra capabilities.

| Container | Capabilities | Privilege escalation | Privileged | Read-only root | Runs as non-root | Host network | Volume mounts |
|-----------|--------------|----------------------|------------|----------------|------------------|--------------|---------------|
| Gateway[^1]        | All                    | Yes | Yes      | No             | No               | Yes
| Route agent[^1]    | All                    | Yes | Yes      | No             | No               | Yes
| Globalnet[^1]      | All                    | Yes | Yes      | No             | No               | Yes
| Lighthouse CoreDNS | `NET_BIND_SERVICE`[^2] | No  | No       | Yes            | Yes            | No | `/etc/coredns`, read-only |

[^1]: This container needs to run `iptables`.
[^2]: This is required to bind to port 53.
