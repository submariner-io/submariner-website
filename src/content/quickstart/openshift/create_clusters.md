### Create and deploy cluster A

In this step you will deploy cluster A, with the default IP CIDRs

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.128.0.0/14 |172.30.0.0/16 |


```bash
openshift-install create install-config --dir cluster-a
```

```bash
openshift-install create cluster --dir cluster-a
```

The create cluster step will take some time, you can create Cluster B in parallel if you wish.

### Create and deploy cluster B

In this step you will deploy cluster B, modifying the default IP CIDRs

| Pod CIDR     | Service CIDR |
|--------------|--------------|
|10.132.0.0/14 |172.31.0.0/16 |


```bash
openshift-install create install-config --dir cluster-b
```


Change the POD IP network, please note it’s a /14 range by default so you need to use 
+4 increments for “128”, for example: 10.132.0.0, 10.136.0.0, 10.140.0.0, ...
 
```bash
sed -i 's/10.128.0.0/10.132.0.0/g' cluster-b/install-config.yaml
```

Change the service IP network, this is a /16 range by default, so just use +1 increments
for “30”: for example: 172.31.0.0, 172.32.0.0, 172.33.0.0, ...

```bash
sed -i 's/172.30.0.0/172.31.0.0/g' cluster-b/install-config.yaml
```


And finally deploy

```bash
openshift-install create cluster --dir cluster-b
```