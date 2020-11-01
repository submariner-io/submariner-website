### Create and Deploy cluster-a

In this step you will deploy **cluster-a** using the default IP CIDR ranges:

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |

```bash
openshift-install create install-config --dir cluster-a
```

```bash
openshift-install create cluster --dir cluster-a
```

When the cluster deployment completes, directions for accessing your cluster, including a link to its web console and credentials for the
`kubeadmin` user, display in your terminal.

### Create and Deploy cluster-b

In this step you will deploy **cluster-b**, modifying the default IP CIDRs to avoid IP address conflicts. In this example, we will use the
following IP ranges:

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.132.0.0/14 |172.31.0.0/16 |

```bash
openshift-install create install-config --dir cluster-b
```

Change the Pod network CIDR from 10.128.0.0/14 to 10.132.0.0/14:

```bash
sed -i 's/10.128.0.0/10.132.0.0/g' cluster-b/install-config.yaml
```

Change the Service network CIDR from 172.30.0.0/16 to 172.31.0.0/16:

```bash
sed -i 's/172.30.0.0/172.31.0.0/g' cluster-b/install-config.yaml
```

And finally deploy the cluster:

```bash
openshift-install create cluster --dir cluster-b
```

When the cluster deployment completes, directions for accessing your cluster, including a link to its web console and credentials for the
`kubeadmin` user, display in your terminal.
