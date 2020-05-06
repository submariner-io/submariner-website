---
title: "Contributing to Lighthouse"
date: 2020-04-20T17:12:52+0300
weight: 10
---

The [Lighthouse Project](https://github.com/submariner-io/lighthouse) has an agent and a coreDNS plugin.
You can find more about the architecture at [Lighthouse Architecture](../../architecture/components/lighthouse/).
This guide helps in making your contribution easier.

### Fork and get the codebase

You need to fork the [Lighthouse repo](https://github.com/submariner-io/lighthouse/fork) after logging into your GitHub account.
Then you can clone your forked repo locally and switch to the lighthouse folder. You need to create a branch in order to raise a PR

```
git clone https://github.com/<your-github-username>/lighthouse.git
cd lighthouse
git checkout -b <BRANCH-NAME>
```

#### Contributing to Lighthouse Agent

The Lighthouse agent code is present at pkg folder inside the Lighthouse house directory. There is a package for Kubernetes controller
which listens for service creation and creates MultiClusterService CRs. Once you have made the code changes you can refer [building](../building_testing/#submariner-iolighthouse)
and [testing](../building_testing/#common-build-and-testing-targets) it to check if the changes have no regression.

Once you run the make e2e you will have a 3 virtual cluster deployment, you could use it to verify if the changes are working as expected manually.
Lighthouse agent will be running the submariner-operator namespace in the data clusters. You could use kubectl commands
to see the logs and the pods status.

#### Contributing to Lighthouse Plugin

The plugin/lighthouse/ folder has the lighthouse plugin code. This uses the structure of as required by a standard code DNS plugin.
The plugin answers the DNS requests by using the info in multicluster service. After making changes you can [build](../building_testing/#submariner-iolighthouse)
and [test](.../building_testing/#common-build-and-testing-targets) the code.

Similar to the agent, you can use the deployment created using make e2e. The lighthouse plugin will be running as a part of the coreDNS in the kube-system 
namespace and the config map will be changed to use it. The usual kubectl commands can be used here as well.
You can add the debug entry in the coreDNS config map if you require more logging.

### Raising a Pull Request

You can commit your changes using git commit and push the changes to your fork branch. Then you will see an option to raise a PR in
the GitHub UI in your browser when you go to your forked repo.

```
git commit -s #Give a commit message
git push -f origin HEAD:<Your-Branch-Name>
```

Raising a PR will trigger CI and will verify the changes.
