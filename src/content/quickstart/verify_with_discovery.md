#### Verify Deployment

To verify the deployment follow the steps below which creates a headless or ClusterIp nginx service and
ServiceExport for it.

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
```

##### Deploy ClusterIP Service

To verify a ClusterIP service follow the steps below

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl -n default expose deployment nginx --port=8080
subctl export service --namespace default nginx
```

##### Deploy Headless Service

To verify a headless service follow the steps below

```bash
kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl -n default expose deployment nginx --port=8080 --cluster-ip=''
subctl export service --namespace default nginx
```

##### Verify

Now verify the service deployed from custer-a

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default  run --generator=run-pod/v1 tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.supercluster.local:8080
```

#### Perform automated verification

This will perform all automated verification between your clusters.

```bash
subctl verify cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --only service-discovery,connectivity --verbose
```
