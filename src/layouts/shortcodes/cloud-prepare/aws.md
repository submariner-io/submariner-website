<!-- Hugo doesn't allow shortcodes in shortcodes, so use HTML -->
<div class="notices note">
<p>The default EC2 instance type for the Submariner gateway node is <code>m5n.large</code>,
optimized for improved network throughput and packet rate performance.
Please ensure that the AWS Region you deploy to supports this instance type.
Alternatively, you can choose to deploy using a different instance type.</p>
</div>

You need to extract your infra ID and region in order to use the command.
Its possible to extract them from the `metadata.json` file that the OpenShift Installer created:

```bash
metadata_file=<path/to>/metadata.json
infra_id=$(jq -r .infraID $metadata_file)
region=$(jq -r .aws.region $metadata_file)
```

{{- $clusters := $.Get "clusters" }}
{{- range $cluster := split $clusters "," }}
Run the command for **{{ $cluster }}**:

```bash
export KUBECONFIG={{ $cluster }}/auth/kubeconfig
subctl cloud prepare aws --infra-id $infra_id --region $region {{ with $.Get "nattPort" }}--natt-port {{.}}{{ end }}
```

{{- end }}

Note that certain parameters, such as the tunnel UDP port and AWS instance type for the gateway,
can be customized. For example:

```bash
subctl cloud prepare aws --infraid $infra_id --region $region --natt-port 4501 --gateway-instance m4.xlarge
```

Submariner can be deployed in HA mode by setting the `gateways` flag:

```bash
subctl cloud prepare aws --infraid $infra_id --region $region --gateways 3
```
