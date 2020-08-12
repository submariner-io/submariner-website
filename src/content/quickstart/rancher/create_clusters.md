### Create and Deploy Cluster A

In this step you will deploy cluster A, with the default IP CIDRs

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.42.0.0/16  |10.43.0.0/16  |

Use the Rancher UI to create a cluster, leaving the default options selected.

Make sure you create at least one node that has a publicly accessible IP with the label `submariner.io/gateway: "true"`, either via node
pool or via a custom node registration command.

### Create and Deploy Cluster B

In this step you will deploy cluster B, modifying the default IP CIDRs

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.44.0.0/16  |10.45.0.0/16  |

Create your cluster, but select `Edit as YAML` in the cluster creation UI. Edit the services stanza to reflect the options below, while
making sure to keep the options that were already defined.

```bash
  services:
    kube-api:
      service_cluster_ip_range: 10.45.0.0/16
    kube-controller:
      cluster_cidr: 10.44.0.0/16
      service_cluster_ip_range: 10.45.0.0/16
    kubelet:
      cluster_domain: cluster.local
      cluster_dns_server: 10.45.0.10
```

Make sure you create at least one node that has a publicly accessible IP with the label `submariner.io/gateway: "true"`, either via node
pool or via a custom node registration command.

Once you have done this, you can deploy your cluster.
