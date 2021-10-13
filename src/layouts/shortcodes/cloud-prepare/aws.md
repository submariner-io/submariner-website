<!-- Hugo doesn't allow shortcodes in shortcodes, so use HTML -->
<div class="notices note">
<p>The default EC2 instance type for the Submariner gateway node is <code>c5d.large</code>,
optimized for better CPU which is found to be a bottleneck for IPsec and Wireguard drivers.
Please ensure that the AWS Region you deploy to supports this instance type.
Alternatively, you can choose to deploy using a different instance type.</p>
</div>

{{- $clusters := $.Get "clusters" }}
{{- range $cluster := split $clusters "," }}

Prepare OpenShift-on-AWS **{{ $cluster }}** for Submariner:

```bash
export KUBECONFIG={{ $cluster }}/auth/kubeconfig
subctl cloud prepare aws --ocp-metadata path/to/{{ $cluster }}/metadata.json {{ with $.Get "nattPort" }}--natt-port {{.}}{{ end }}
```

{{- end }}

Note that certain parameters, such as the tunnel UDP port and AWS instance type for the gateway,
can be customized. For example:

```bash
subctl cloud prepare aws --ocp-metadata path/to/metadata.json --natt-port 4501 --gateway-instance m4.xlarge
```

Submariner can be deployed in HA mode by setting the `gateways` flag:

```bash
subctl cloud prepare aws --ocp-metadata path/to/metadata.json --gateways 3
```
