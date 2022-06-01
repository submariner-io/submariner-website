{{- $clusters := $.Get "clusters" }}
{{- range $cluster := split $clusters "," }}
Run the command for **{{ $cluster }}**:

```bash
export KUBECONFIG={{ $cluster }}/auth/kubeconfig
subctl cloud prepare azure --ocp-metadata {{ $cluster }}/metadata.json --auth-file my.auth
```

{{- end }}
