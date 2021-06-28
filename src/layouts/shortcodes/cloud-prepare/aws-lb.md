{{- $clusters := $.Get "clusters" }}
{{- range $cluster := split $clusters "," }}
Run the command for **{{ $cluster }}**:

```bash
export KUBECONFIG={{ $cluster }}/auth/kubeconfig
subctl cloud prepare aws --ocp-metadata {{ $cluster }}/metadata.json --disable-gateways
kubectl label node $gateway submariner.io/gateway=true
```

{{- end }}
