Submariner Gateway nodes need to be able to accept traffic over UDP ports (4500 and 4490 by default).
Submariner also uses UDP port 4800 to encapsulate traffic from the worker and master nodes to the Gateway nodes, and TCP port 8080 to
retrieve metrics from the Gateway nodes.
Additionally, the default OpenShift deployment does not allow assigning an elastic public IP to existing worker nodes, which may be
necessary on one end of the tunnel connection.

`subctl cloud prepare` is a command designed to update your OpenShift installer provisioned AWS infrastructure for Submariner deployments,
handling the requirements specified above.
