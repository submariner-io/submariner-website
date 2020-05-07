---
title: "Contributing to Lighthouse"
date: 2020-04-20T17:12:52+0300
weight: 10
---

The [Lighthouse Project](https://github.com/submariner-io/lighthouse) contains the code for the service discovery component of Submariner. It mainly consists of an agent and a coreDNS plugin.
Learn more about the architecture [here](../../architecture/service-discovery/).

### Fork and Clone the Repository

First log into your GitHub account and create a [fork of the Lighthouse repository](https://github.com/submariner-io/lighthouse/fork).
Then clone your forked repository locally and switch to the lighthouse folder. You will need to create a branch in order to raise a PR.

```
git clone https://github.com/<your-github-username>/lighthouse.git
cd lighthouse
git checkout -b <BRANCH-NAME>
```

#### Contributing to Lighthouse Agent

The Lighthouse Agent code is located under the `pkg/agent` directory. The `Controller` is the main component that performs bi-directional syncing of Service and MultiClusterService resources. After making code changes, please refer to [building](../building_testing/#submariner-iolighthouse)
and [testing](../building_testing/#common-build-and-testing-targets) to build and verify your changes.

Running `make e2e` will create a 3-cluster deployment which you can use it manually verify changes if necessary.
The Lighthouse Agent will be deployed in the `submariner-operator` namespace in each cluster. You can use `kubectl` commands to check the pod's logs and status.

#### Contributing to Lighthouse Plugin

The Lighthouse plugin code is located under the `plugin/lighthouse` directory and uses the structure as required by a standard code CoreDNS plugin.
The plugin answers the DNS requests by using the info in multicluster service. After making code changes, please refer to [building](../building_testing/#submariner-iolighthouse)
and [testing](../building_testing/#common-build-and-testing-targets) to build and verify your changes.

Similar to the agent, you can use the deployment created using `make e2e` to manually test and verify as well. The Lighthouse plugin will be running as a part of the CoreDNS in the `kube-system`  
namespace and the CoreDNS config map will be changed to use it. The usual `kubectl` commands can be used here as well.
You can add the debug entry in the CoreDNS config map if you require more logging.

### Creating a Pull Request

You can commit your changes using `git commit` and push the changes to your fork branch. Then you will see an option to create a PR in
the GitHub UI in your browser when you go to your forked repository.

```
git commit -s #Give a commit message
git push -f origin HEAD:<Your-Branch-Name>
```

Creating a PR will trigger CI to verify the changes.
