## AWS

### openshift-install and pull-secret

Download the **openshift-install** and _oc_ tools, and copy your _pull secret_ from:

> https://cloud.redhat.com/openshift/install/aws/installer-provisioned

Find more detailed instructions here:

> https://docs.openshift.com/container-platform/4.3/installing/installing_aws/installing-aws-default.html

### Make sure the aws cli is properly installed and configured

Installation instructions

> https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html

```bash
$ aws configure
AWS Access Key ID [None]: ....
AWS Secret Access Key [None]: ....
Default region name [None]: ....
Default output format [None]: text
```

See also for more details:

> https://docs.openshift.com/container-platform/4.3/installing/installing_aws/installing-aws-account.html

