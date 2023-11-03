---
title: "Upgrading"
date: 2023-09-06T14:06:11+02:00
weight: 15
---

Starting with Submariner 0.16, the recommended way to upgrade Submariner is via the [`subctl upgrade`](#automated-upgrade) command.
This can be used to upgrade clusters to Submariner 0.16 or later.
To upgrade older clusters to a version of Submariner before 0.16, follow the [manual upgrade process](#manual-upgrade).

## Automated Upgrade

If your current version of `subctl` (as indicated by `subctl version`) is older than 0.16,
start by [installing the desired version of `subctl`](../deployment/subctl/#install).
If your current version of `subctl` is 0.16 or later, it will upgrade itself during the upgrade process.

Once you have `subctl` 0.16 or later, run it with a kubeconfig pointing to the cluster(s) you wish to upgrade:

```bash
subctl upgrade --kubeconfig /path/to/kubeconfig
```

(The `--kubeconfig` parameter is optional; `subctl` will use any configuration that `kubectl` would find.)

`subctl upgrade` will start by upgrading `subctl` to the latest released version,
and then upgrade all the Submariner components in accessible clusters to match,
_i.e._ all Submariner components present in any cluster accessible through a context in the configured kubeconfig.

A specific target version can be specified using the `--to-version` parameter:

```bash
subctl upgrade --to-version v0.16.0
```

## Manual Upgrade

To manually upgrade Submariner in a set of clusters, follow the steps below:

{{% notice note %}}
Make sure KUBECONFIG for all participating clusters is exported and all participating clusters are accessible via kubectl.
{{% /notice %}}

1. Download the appropriate version of `subctl`

2. Re-deploy the broker in the broker context, pointing to the previous broker-info.subm file to preserve the PSK:

   ```bash
   subctl deploy-broker --context cluster1 --ipsec-psk-from broker-info.subm
   ```

3. Join the connected clusters:

   ```bash
   subctl join --context cluster1
   subctl join --context cluster2
   ```

   This will restart the operator and all Submariner pods, using the version of Submariner matching the version of `subctl`.
