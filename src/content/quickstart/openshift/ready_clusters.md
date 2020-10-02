### Make your clusters ready for Submariner

Submariner gateway nodes need to be able to accept traffic over ports 4500/UDP and 500/UDP
when using IPSEC. In addition we use port 4800/UDP to encapsulate traffic from the worker nodes
to the gateway nodes and ensuring that Pod IP addresses are preserved.

Additionally, the default Openshift deployments don't allow assigning an elastic public IP
to existing worker nodes, something that it's necessary at least on one end of the IPSEC connections.

To handle all those details we provide a script that will prepare your AWS OpenShift deployment
for Submariner, and will create an additional gateway node with an external IP.

```bash

curl https://raw.githubusercontent.com/submariner-io/submariner/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh -L -O
chmod a+x ./prep_for_subm.sh

./prep_for_subm.sh cluster-a     # respond yes when terraform asks
./prep_for_subm.sh cluster-b      # respond yes when terraform asks

```

> **_INFO_** Please note that  **oc**, **aws-cli**, **terraform**, and **unzip** need to be installed before running the `prep_for_subm.sh` script.
