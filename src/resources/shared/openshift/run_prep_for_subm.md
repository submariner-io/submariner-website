* Run the `prep_for_subm.sh` script for **cluster-a** and **cluster-b**:

```bash
./prep_for_subm.sh cluster-a # respond "yes" when Terraform asks for approval, or otherwise add the -auto-approve flag
./prep_for_subm.sh cluster-b # respond "yes" when Terraform asks for approval, or otherwise add the -auto-approve flag
```

Note that certain parameters, such as the IPsec UDP ports and AWS instance type for the gateway,
can be customized before running the script. For example:

```bash
export IPSEC_NATT_PORT=4501
export IPSEC_IKE_PORT=501
export GW_INSTANCE_TYPE=m4.xlarge
```
