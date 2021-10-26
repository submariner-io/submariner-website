{{- $clusters := $.Get "clusters" }}
{{- range $cluster := split $clusters "," }}
Run the command for **{{ $cluster }}**:

```bash
export KUBECONFIG={{ $cluster }}/auth/kubeconfig
subctl cloud prepare gcp --ocp-metadata {{ $cluster }}/metadata.json
```

{{- end }}
