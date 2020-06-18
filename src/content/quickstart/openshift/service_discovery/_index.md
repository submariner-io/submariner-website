---
date: 2020-02-21T13:36:18+01:00
title: "With Service Discovery"
weight: 15
---

{{< include "quickstart/openshift/setup_openshift.md" >}}
{{< include "quickstart/openshift/create_clusters.md" >}}
{{< include "quickstart/openshift/ready_clusters.md" >}}

### Install subctl

{{< subctl-install >}}

### Install Submariner with Service Discovery

To install Submariner with multi-cluster service discovery follow the steps below.

#### Use cluster-a as broker with service discovery enabled

```bash
subctl deploy-broker --kubeconfig cluster-a/auth/kubeconfig --service-discovery
```

#### Join cluster-a and cluster-b to the broker

```bash
subctl join --kubeconfig cluster-a/auth/kubeconfig broker-info.subm --clusterid cluster-a
```

```bash
subctl join --kubeconfig cluster-b/auth/kubeconfig broker-info.subm --clusterid cluster-b
```

####  Verify Deployment
To verify the deployment follow the steps below.

```bash
export KUBECONFIG=cluster-b/auth/kubeconfig
kubectl -n default create deployment nginx --image=nginxinc/nginx-unprivileged:stable-alpine
kubectl -n default expose deployment nginx --port=8080
kubectl -n default apply -f - <<EOF
apiVersion: lighthouse.submariner.io/v2alpha1
kind: ServiceExport
metadata:
  name: nginx
EOF
```

```bash
export KUBECONFIG=cluster-a/auth/kubeconfig
kubectl -n default  run --generator=run-pod/v1 tmp-shell --rm -i --tty --image quay.io/submariner/nettest -- /bin/bash
curl nginx.default.svc.supercluster.local:8080
```

{{% notice info %}}

The `ServiceExport` resource must be created in the same namespace as the Service you're trying to export. In the example above, `nginx` is created in `default` so we create the `ServiceExport` resource in `default` as well.

{{% /notice %}}

#### Perform automated verification
You can also perform automated verifications of service discovery via the `subctl verify` command.

```bash
subctl verify cluster-a/auth/kubeconfig cluster-b/auth/kubeconfig --only service-discovery,connectivity --verbose
```
