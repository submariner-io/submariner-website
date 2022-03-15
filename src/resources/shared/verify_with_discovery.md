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
kubectl -n default run tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.clusterset.local:8080
```

To access a Service in a specific cluster, prefix the query with `<cluster-id>` as follows:

```bash
curl cluster-b.nginx.default.svc.clusterset.local:8080
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

Use this yaml to create a StatefulSet `web` with `nginx-ss` as the Headless Service.

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default apply -f web.yaml
subctl export service -n default nginx-ss
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

The contexts on both config files are named `admin` and need to be modified before running the `verify` command.
Here is how this can be done using [yq](http://mikefarah.github.io/yq/):

```bash
yq e -i '.contexts[0].name = "cluster-a" | .current-context = "cluster-a"' cluster-a/auth/kubeconfig
yq e -i '.contexts[0].context.user = "admin-a" | .users[0].name = "admin-a"' cluster-a/auth/kubeconfig
yq e -i '.contexts[0].name = "cluster-b" | .current-context = "cluster-a"' cluster-b/auth/kubeconfig
yq e -i '.contexts[0].context.user = "admin-b" | .users[0].name = "admin-b"' cluster-b/auth/kubeconfig
```

(if you’re using `yq` 4.18.1 or later, you can use `yq -i` instead of `yq e -i`).

More generally, see
[the Kubernetes documentation on accessing multiple clusters using configuration files](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/).

This will perform automated verifications between the clusters.

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig:cluster-b/auth/kubeconfig
subctl verify --kubecontexts cluster-a,cluster-b --only service-discovery,connectivity --verbose
```
