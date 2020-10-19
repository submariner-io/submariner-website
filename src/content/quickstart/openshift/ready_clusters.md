### Make your clusters ready for Submariner

Submariner gateway nodes need to be able to accept traffic over UDP ports (4500 and 500 by default) when using IPsec.
In addition we use port 4800/UDP to encapsulate traffic from the worker nodes to the gateway nodes and ensuring that Pod IP addresses are preserved.

Additionally, the default OpenShift deployment does not allow assigning an elastic public IP
to existing worker nodes, which may be necessary on one end of the IPsec connections.

To handle all those details we provide a script
[prep_for_subm.sh](https://github.com/submariner-io/submariner/blob/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh)
that will prepare your AWS OpenShift deployment for Submariner, and will create an additional gateway node with an external IP:

```bash

curl https://raw.githubusercontent.com/submariner-io/submariner/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh -L -O
chmod a+x ./prep_for_subm.sh

./prep_for_subm.sh <OCP install path>  # respond yes when terraform asks to approve, or add after path: -auto-approve

```

> **_INFO_** Please note that  **oc**, **aws-cli**, **terraform**, and **wget** need to be installed before running the `prep_for_subm.sh` script.

In the following example, we create the gateway node on cluster-b, with custom IPsec ports and instance type:

```bash

export IPSEC_NATT_PORT=4501
export IPSEC_IKE_PORT=501
export GW_INSTANCE_TYPE=m4.xlarge

./prep_for_subm.sh cluster-b

```
