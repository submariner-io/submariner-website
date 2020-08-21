#### Verify Deployment

To verify the deployment follow the steps below which creates an nginx service and
ServiceExport for it.

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl -n default expose deployment nginx --port=8080
subctl export service --namespace default nginx
```

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default  run --generator=run-pod/v1 tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.supercluster.local:8080
```

To verify a headless service follow the steps below using a mehdb service

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
kubectl apply -f https://raw.githubusercontent.com/openshift-evangelists/mehdb/master/app.yaml
subctl export service --namespace default mehdb
```

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default  run --generator=run-pod/v1 tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
dig mehdb.default.svc.clusterset.local:8080 +short
```

The dig will return a set of A records containing the IP address of Pods backing the service mehdb in cluster-b.

#### Perform automated verification

This will perform all automated verification between your clusters.

```bash
subctl verify cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --only service-discovery,connectivity --verbose
```
