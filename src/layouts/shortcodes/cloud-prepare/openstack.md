Prepare OpenShift-on-AWS **cluster-a** for Submariner:

<div class="notices note">
<p>The default EC2 instance type for the Submariner gateway node is <code>c5d.large</code>,
optimized for better CPU which is found to be a bottleneck for IPsec and Wireguard drivers.
Alternatively, you can choose to deploy using a different instance type.</p>
</div>

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
subctl cloud prepare aws --ocp-metadata path/to/cluster-a/metadata.json {{ with $.Get "nattPort" }}--natt-port {{.}}{{ end }}
```

Prepare OpenShift-on-OpenStack **cluster-b** for Submariner:

The default OpenStack vm instance type for the Submariner gateway node is <code>PnTAE.CPU_4_Memory_8192_Disk_50</code>,
Alternatively, you can choose to deploy using a different instance type.
You need to use the appropriate cloud name from clouds.yaml, here it uses **OpenStack**

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
subctl cloud prepare rhos --ocp-metadata path/to/cluster-b/metadata.json --cloud-entry\
openstack {{ with $.Get "nattPort" }}--natt-port {{.}}{{ end }}
```

Note that certain parameters, such as the tunnel UDP port and OpenStack instance type for the gateway,
can be customized. For example:

```bash
subctl cloud prepare aws --ocp-metadata path/to/metadata.json --natt-port 4501 --gateway-instance m4.xlarge
```

Submariner can be deployed in HA mode by setting the `gateways` flag:

```bash
subctl cloud prepare aws --ocp-metadata path/to/metadata.json --gateways 3
```
