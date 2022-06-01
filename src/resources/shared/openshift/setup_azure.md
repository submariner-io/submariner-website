### Setup Your Azure Profile

Create a service principal and configure its access to Azure resources. Output the result in an Azure SDK compatible auth file. Please
refer to [the official OpenShift on Azure
documentation](https://docs.openshift.com/container-platform/4.10/installing/installing_azure/preparing-to-install-on-azure.html) for
details.

```bash
az ad sp create-for-rbac --sdk-auth > my.auth
```
