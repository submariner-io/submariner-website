Submariner gateway nodes need to be able to accept traffic over UDP ports (4500 and 500 by default) when using IPsec. Submariner also uses
UDP port 4800 to encapsulate traffic from the worker nodes to the gateway nodes. Additionally, the default OpenShift deployment does not
allow assigning an elastic public IP to existing worker nodes, which may be necessary on one end of the IPsec connection.

`prep_for_subm` is a script designed to update your OpenShift installer provisioned AWS infrastructure for Submariner deployments,
handling the requirements specified above.

* Download the `prep_for_subm.sh` script and set permissions:

```bash
curl https://raw.githubusercontent.com/submariner-io/submariner/master/tools/openshift/ocp-ipi-aws/prep_for_subm.sh -L -O
chmod a+x ./prep_for_subm.sh
```
