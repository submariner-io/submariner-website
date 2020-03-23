---
title: "Gateway Engine"
---

The gateway engine component is deployed in each connected cluster and
is responsible for establishing IPsec tunnels to other
clusters. Instances of the gateway engine run on specifically
designated nodes in a cluster of which there may be more than one for
fault tolerance. There is only one active gateway engine instance in a
cluster - the others await in standby mode ready to take over should
the active instance fail. The active gateway engine communicates with
the central broker to advertise its endpoint to the other connected
clusters and to learn about the gateway endpoints on the other
clusters.
