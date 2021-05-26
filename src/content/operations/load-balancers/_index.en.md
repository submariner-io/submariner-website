---
title: "Using cloud load balancers"
weight: 25
---

Using cloud load balancers removes the need to use dedicated nodes for the Submariner
gateway. 

To configure load balancers, if deployed with OpenShift, make sure that the submariner machineset
is removed:

```bash
oc get Machineset -A
oc delete Machineset x -n openshift-machine-api
```

Then create a Service object of type LoadBalancer (nlb in AWS):
```
apiVersion: v1
kind: Service
metadata:
  name: gw1
  namespace: submariner-operator
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  externalTrafficPolicy: Local
  selector:
    app: submariner-gateway
    # node: ip-10-0-162-208.us-east-2.compute.internal
  ports:
    - name: ipsec-encap
      protocol: UDP
      port: 4500
      targetPort: 4500
    - name: natt-discovery
      protocol: UDP
      port: 4490
      targetPort: 4490
  type: LoadBalancer
```


Then annotate the selected node to point to such load balancer (so the gateway can find it):
```bash
kubectl annotate node $node gateway.submariner.io/public-ip=lb:gw1
```

Then assign that node as a Submariner gateway (please note that the above annotation is only read by
the submariner gateway on boot, so if you modify the annotation afterwards make sure to reboot
the existing gateway pod)
```bash
kubectl label node $node submariner.io/gateway=true
```

Join the cluster with the `--preferred-server` flag, that will change the IPSEC mode to server<-client
instead of client<->client.

```bash
export KUBECONFIG=....
subctl join brokerinfo.subm --preferred-server --clusterid $yourClusterID
```
