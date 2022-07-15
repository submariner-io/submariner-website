### cluster-a on AWS

#### Setup Your AWS Profile

Configure the AWS CLI with the settings required to interact with AWS. These include your security credentials, the default AWS Region,
and the default output format:

```bash
$ aws configure
AWS Access Key ID [None]: ....
AWS Secret Access Key [None]: ....
Default region name [None]: ....
Default output format [None]: text
```

#### Create and Deploy cluster-a

In this step you will deploy **cluster-a** in **aws** (or any other public cloud can be used) using the default IP CIDR ranges:

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

### cluster-b on OpenStack (On-Prem)

#### Setup Your OpenStack Profile

Configure the OpenStack credentials for the command line client.
Please refer to the official
[OpenStack documentation](https://docs.openstack.org/newton/user-guide/common/cli-set-environment-variables-using-openstack-rc.html)
for detailed instructions.

#### Create and Deploy cluster-b

In this step you will deploy **cluster-b**, modifying the default IP CIDRs to avoid IP address
conflicts with **cluster-a**. You can change the IP addresses block and prefix based on your requirements. For
more information on IPv4 CIDR conversion, please check [this page](https://account.arin.net/public/cidrCalculator).

In this example, we will use the following IP ranges:

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
`kubeadmin` user, will be displayed in your terminal.
