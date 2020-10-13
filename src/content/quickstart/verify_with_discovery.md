#### Verify Deployment

To manually verify the deployment, follow the steps below using either a headless or ClusterIP `nginx` service deployed in `cluster-b`.

##### Deploy ClusterIP Service

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl -n default expose deployment nginx --port=8080
subctl export service --namespace default nginx
```

##### Deploy Headless Service

Note that headless Services can only be exported on non-globalnet deployments.

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl -n default expose deployment nginx --port=8080 --cluster-ip=None
subctl export service --namespace default nginx
```

##### Verify

Run `nettest` from `cluster-a` to access the `nginx` service:

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default  run --generator=run-pod/v1 tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.clusterset.local:8080
```

To access a Service in a specific cluster, prefix the query with `<cluster-id>` as follows:

```bash
curl cluster-a.nginx.default.svc.clusterset.local:8080
```

#### Verify StatefulSets

A StatefulSet uses a headless Service. Create a `web.yaml` as follows:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ss
  labels:
    app.kubernetes.io/instance: nginx-ss
    app.kubernetes.io/name: nginx-ss
spec:
  ports:
  - port: 80
    name: web
  clusterIP: None
  selector:
    app.kubernetes.io/instance: nginx-ss
    app.kubernetes.io/name: nginx-ss
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web
spec:
  serviceName: "nginx-ss"
  replicas: 2
  selector:
    matchLabels:
        app.kubernetes.io/instance: nginx-ss
        app.kubernetes.io/name: nginx-ss
  template:
    metadata:
      labels:
        app.kubernetes.io/instance: nginx-ss
        app.kubernetes.io/name: nginx-ss
    spec:
      containers:
      - name: nginx-ss
        image: nginxinc/nginx-unprivileged:stable-alpine
        ports:
        - containerPort: 80
          name: web
```

Use this yaml to create a StatefulSet `web` with `nginx-ss` as the headless Service.

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default  apply -f web.yaml
curl nginx-ss.default.svc.clusterset.local:8080
```

To access the Service in a specific cluster, prefix the query with `<cluster-id>`:

```bash
curl cluster-a.nginx-ss.default.svc.clusterset.local:8080
```

To access an individual pod in a specific cluster, prefix the query with `<pod-hostname>.<cluster-id>`:

```bash
curl web-0.cluster-a.nginx-ss.default.svc.clusterset.local:8080
```

#### Perform automated verification

This will perform automated verifications between the clusters.

```bash
subctl verify cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --only service-discovery,connectivity --verbose
```
