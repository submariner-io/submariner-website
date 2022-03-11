---
title: "Release Process"
date: 2020-03-18T16:03:26+01:00
weight: 40
---

These docs describe how to create a Submariner release.

## Release Concepts

### Project Release Order

Submariner's projects have a dependency hierarchy among their Go libraries and container images, which drives their release order.

The Go dependency hierarchy is:

`shipyard` <- `admiral` <- [`submariner`, `lighthouse`, `cloud-prepare`] <- `submariner-operator`

The container image dependency hierarchy is:

`subctl` binary <- `shipyard-dapper-base` image <- [`admiral`, `cloud-prepare`, `submariner`, `lighthouse`, `submariner-operator`]

Projects in brackets are siblings and do not depend on each other. Dependencies of siblings require all siblings to have aligned versions.

### Choosing Versions

Version numbers are required to be formatted following the schema norms where they are used.

* Git: `vx.y.z` (example: `v0.8.0`)
* Containers: `x.y.z` (example: `0.8.0`)
* Stable branches: `release-x.y` (example: `release-0.8`)
* Milestone releases: Append `-mN` starting at 1 (example: `v0.8.0-m1`)
* Release candidates: Append `-rcN` starting at 0 (example: `v0.8.0-rc0`)
* Single-project testing release: Append `-preN` starting at 0 (example: `v0.8.0-pre0`)
* Release errors: Append `.N` starting at 1 (example: `v0.8.0-m1.1`)

### Creating Releases

The following sections are an ordered series of steps to create a Submariner release.

The release process is mostly automated and uses a YAML file created in the
[releases repository](https://github.com/submariner-io/releases) that describes the release.
This file is updated for each step in the release process.

Once the changes for a step are reviewed and merged, a CI job will run to create the release(s) for the step and create the
required pull requests in preparation for the next step to be reviewed and merged. Once all these pull requests have been
merged, you can continue onto the next step.

For most projects, after a release is created, another job will be initiated to build release artifacts and publish to Quay.
This will take several minutes. You can monitor the progress from the project's main page. In the branches/tags pull-down
above the file list heading, select the tag for the new version. A small yellow circle icon should be present to the right
of the file list heading which indicates a job is in progress. You can click it to see details. There may be several checks
for the job listed but the important one is "Release Images". When complete, the indicator icon will change to either a
green check mark on success or a red X on failure. A failure likely means the artifacts were not published to Quay, in
which case select the failed check, inspect the logs, correct the issue and re-run the job.

### Release Notes (Final Releases)

If you're creating a release meant for general consumption, not a milestone or release candidate, [release notes](../../community/releases/)
must also be created.

It's best to start working with the broader community to create release notes well before the release. Create a PR to start the process, and
work with contributors to get everything added and reviewed.

### Updating Dependencies

Verify that all dependencies are up to date before branch cutting at the first release candidate.
See the [CI Maintenance docs](../building-testing/ci-maintenance) for details about versions that must be manually maintained.

## Automated Release Creation Process

Most of the release can be done in a series of mostly-automated steps. After each step, a Pull Request is sent with the correct YAML
content for the release, this needs to be reviewed. Once the pull request is merged, the release process will continue automatically
and the next step can be initiated shortly after making sure the release jobs on the `releases` and any participating repositories are done.

{{% notice info %}}
The `GITHUB_TOKEN` environment variable in the shell you're using for the automation must be set to a
[Personal Access Token](https://github.com/settings/tokens) you create.
The token needs at least `public_repo` scope for the automated release to work.

```shell
export GITHUB_TOKEN=<token>
```

{{% /notice %}}

To run the automated release, simply clone the [releases](https://github.com/submariner-io/releases) repository and execute:

```bash
make release VERSION="0.8.0"
```

Make sure to specify the proper version you're intending to release (e.g. for rc0 specify `VERSION="0.8.0-rc0"`).

By default, the action will try to push to the GitHub account used in the `origin` remote.
If you want to use a specific GitHub account, set `GITHUB_ACTOR` to the desired account, e.g.

```bash
make release VERSION="0.8.0" GITHUB_ACTOR="octocat"
```

{{% notice tip %}}
You can run the process without pushing the PR automatically (obviating the need to set `GITHUB_TOKEN`).
To do so, run the `make` command with `dryrun=true`.
{{% /notice %}}

The command runs, gathers the data for the release, updates the release YAML and pushes it for review. Once the review process is done,
merge the PR. Pull requests will then be created for all dependent projects to update them to the new version. The automation
will leave a comment with a list of the version-bump PRs for dependent project in the release PR that was just merged. Make sure all those
PRs are merged and their release jobs pass (see the Actions tab of the repository on GitHub) then **proceed to the next release phase by
running the same command again**.

Once there isn't anything else to do, the command will inform you. At this point, continue manually with any steps not automated yet,
starting with [Verify Release](#verify).

## Manual Release Creation Process

These instructions are here as a backup in case the automated creation process has problems, and to serve as a guide.

### Stable Releases: Create Stable Branches

If you're creating a stable release, you need to create a stable branch for backports in each repository. Milestone releases don't receive
backports and therefore don't need branches.

The release automation process can create stable branches for you. To do so, navigate to the
[releases](https://github.com/submariner-io/releases) repository.

1) Create a new file in the `releases` directory (you can copy the `example.yaml` file). For our example, we'll name it `v0.8.0.yaml`.

2) Fill in the `version`/`name`/`branch` fields for the release, following the naming scheme below. The `status` field must be set to
   `branch` for this phase.

   ```yaml
   version: v0.8.0
   name: 0.8.0
   branch: release-0.8
   status: branch
   ```

3) Commit your changes, create a pull request, and have it reviewed.

Once the pull request is merged, it will trigger a CI job to create the stable branches and pin them to Shipyard on that stable
branch.

### Step 1: Create Shipyard Release

Navigate to the [releases](https://github.com/submariner-io/releases) repository.

1) Create a new file in the `releases` directory (you can copy the `example.yaml file`). For our example, we'll name it `v0.8.0.yaml`.

2) Fill in the general fields for the release with the `status` field set to `shipyard`. Also add the `shipyard` component with
   the hash of the desired or latest commit ID on which to base the release. To obtain the latest, first navigate to
   the [Shipyard project](https://github.com/submariner-io/shipyard). The heading above the file list shows the latest
   commit on the devel branch including the first 7 hex digits of the commit ID hash.

   If this is not a final release, set the `pre-release` field to `true` (that is uncomment the `pre-release` line below).
   This includes release candidates. This is important so it is not labeled as the Latest release in GitHub.

   When releasing on a stable branch, make sure to specify the branch as outlined below. Otherwise, omit it.

   ```yaml
   version: v0.8.0
   name: 0.8.0
   #pre-release: true
   branch: release-0.8
   status: shipyard
   components:
     shipyard: <hash goes here>
   ```

3) Commit your changes, create a pull request, and have it reviewed.

4) **Verify**:

   * The [`releases/release` job](https://github.com/submariner-io/releases/actions/workflows/release.yml) passed.
   * The [Shipyard release](https://github.com/submariner-io/shipyard/releases) was created.
   * The [`submariner/shipyard-dapper-base` image](https://github.com/submariner-io/shipyard/releases) is on Quay.

5) Pull requests will be created for projects that consume Shipyard to update them to the new version in preparation for the subsequent
   steps. The automation will leave a comment with a list of them. Make sure all those PRs are merged and their release jobs pass.

### Step 2: Create Admiral Release

Once the pull request to pin Admiral to the new Shipyard version is merged, we can proceed to updating the
release YAML file to create an Admiral release.

1) Edit the release yaml file (`v0.8.0.yaml`). Update the `status` field to `admiral` and add the `admiral` component with
   the latest commit ID hash:

   ```diff
   -status: shipyard
   +status: admiral
    components:
      shipyard: <hash goes here>
   +  admiral: <hash goes here>
   ```

2) Commit your changes, create a pull request, and have it reviewed.

3) **Verify**:

   * The [releases/release job](https://github.com/submariner-io/releases/actions/workflows/release.yml) passed.
   * The [Admiral release](https://github.com/submariner-io/admiral/releases) was created.

4) Pull requests will be created for projects that consume Admiral to update them to the new version in preparation for the subsequent
   steps. The automation will leave a comment with a list of them. Make sure all those PRs are merged and their release jobs pass.

### Step 3: Create cloud-prepare, Lighthouse, and Submariner Releases

Once the pull requests to pin the cloud-prepare, Lighthouse and Submariner projects to the new Admiral version are merged:

1) Update the release YAML file `status` field to `projects` and add the `submariner`, `cloud-prepare` and `lighthouse` components with
   their latest commit ID hashes:

   ```diff
   -status: admiral
   +status: projects
    components:
      shipyard: <hash goes here>
      admiral: <hash goes here>
   +  cloud-prepare: <hash goes here>
   +  lighthouse: <hash goes here>
   +  submariner: <hash goes here>
   ```

2) Commit your changes, create a pull request, and have it reviewed.

3) **Verify**:

   * The [`releases/release` job](https://github.com/submariner-io/releases/actions/workflows/release.yml) passed.
   * The [`cloud-prepare` release](https://github.com/submariner-io/cloud-prepare/releases) was created.
   * The [Lighthouse release](https://github.com/submariner-io/lighthouse/releases) was created.
   * The [Submariner release](https://github.com/submariner-io/submariner/releases) was created.
   * The [`submariner/submariner-gateway` image](https://quay.io/repository/submariner/submariner-gateway?tab=tags) is on Quay.
   * The [`submariner/submariner-route-agent` image](https://quay.io/repository/submariner/submariner-route-agent?tab=tags) is on Quay.
   * The [`submariner/submariner-globalnet` image](https://quay.io/repository/submariner/submariner-globalnet?tab=tags) is on Quay.
   * The [`submariner/submariner-networkplugin-syncer` image](https://quay.io/repository/submariner/submariner-networkplugin-syncer?tab=tags)
     is on Quay.
   * The [`submariner/lighthouse-agent` image](https://quay.io/repository/submariner/lighthouse-agent?tab=tags) is on Quay.
   * The [`submariner/lighthouse-coredns` image](https://quay.io/repository/submariner/lighthouse-coredns?tab=tags) is on Quay.

4) Automation will create a pull request to pin `submariner-operator` to the released versions. Make sure that the PR is merged and the release
   job passes.

### Step 4: Create Operator and Charts Releases

Once the pull request to pin `submariner-operator` has been merged, we can create the final release:

1) Update the release YAML file `status` field to `released`. Add the `submariner-operator` and `submariner-charts` components with their
   latest commit ID hashes.

   ```diff
   -status: projects
   +status: released
    components:
      shipyard: <hash goes here>
      admiral: <hash goes here>
      cloud-prepare: <hash goes here>
      lighthouse: <hash goes here>
      submariner: <hash goes here>
   +  submariner-charts: <hash goes here>
   +  submariner-operator: <hash goes here>
   ```

2) Commit your changes, create a pull request, and have it reviewed.

3) **Verify**:

   * The [`releases/release` job](https://github.com/submariner-io/releases/actions/workflows/release.yml) passed.
   * The [`subctl` artifacts](https://github.com/submariner-io/releases/releases) were released
   * The [`submariner-operator` release](https://github.com/submariner-io/submariner-operator/releases) was created.
   * The [`submariner/submariner-operator` image](https://quay.io/repository/submariner/submariner-operator?tab=tags) is on Quay.

4) If the release wasn't marked as a `pre-release`, the `releases/release` job will also create pull requests in each consuming project to
   unpin the Shipyard Dapper base image version, that is set it back to `devel`. For ongoing development we want each project to
   automatically pick up the latest changes to the base image.

### Step 5: Verify Release {id="verify"}

You can follow any of the [quick start guides](../../getting-started/quickstart).

### Step 6: Update OperatorHub.io

The [k8s-operatorhub/community-operators](https://github.com/k8s-operatorhub/community-operators) Git repository
is a source for sharing Kubernetes Operators with the broader community via [OperatorHub.io](https://operatorhub.io/).
OpenShift users will find Submariner's Operator in the official [Red Hat catalog](https://catalog.redhat.com/software/operators/explore).

1) Clone the [`submariner-operator`](https://github.com/submariner-io/submariner-operator) repository.

2) Make sure you have [`operator-sdk` v1 installed](https://v1-0-x.sdk.operatorframework.io/docs/installation/install-operator-sdk/).

3) Generate new package manifests:

   ```bash
   make packagemanifests VERSION=${new_version} FROM_VERSION=${previous_version} CHANNEL=${channel}
   ```

   For example:

   ```bash
   make packagemanifests VERSION=0.11.1 FROM_VERSION=0.11.0 CHANNEL=alpha-0.11
   ```

   Generated package manifests should be in `/packagemanifests/${VERSION}/`.

4) Fork and clone the [k8s-operatorhub/community-operators](https://github.com/k8s-operatorhub/community-operators) repository.

5) Update the Kubernetes Operator:

    * Copy the generated package from Step 3 into `operators/submariner`.
    * Copy the generated package definition `/packagemanifests/submariner.package.yaml` into `operators/submariner/`.
    * Test the Operator by running:

      ```bash
      OPP_AUTO_PACKAGEMANIFEST_CLUSTER_VERSION_LABEL=1 OPP_PRODUCTION_TYPE=k8s \
      curl -sL https://raw.githubusercontent.com/redhat-openshift-ecosystem/community-operators-pipeline/ci/latest/ci/scripts/opp.sh | bash \
      -s -- all operators/submariner/${VERSION}
      ```

    * Preview the Operator on [OperatorHub.io](https://operatorhub.io/preview)
    * Once everything is fine, review this
    [checklist](https://github.com/k8s-operatorhub/community-operators/blob/main/docs/pull_request_template.md)
    and create a new PR on [k8s-operatorhub/community-operators](https://github.com/k8s-operatorhub/community-operators).
    * For more details check the [full documentation](https://k8s-operatorhub.github.io/community-operators).

### Step 7: Announce Release

#### E-Mail

Once the release and release notes are published, make an announcement to both Submariner mailing lists.

* [`submariner-dev`](https://groups.google.com/g/submariner-dev)
* [`submariner-users`](https://groups.google.com/g/submariner-users)

See the [v0.8.0 email example](https://groups.google.com/g/submariner-users/c/2F8Fzvi4mS4).

#### Twitter

Synthesize the release notes and summarize the key points in a Tweet. Link to the release notes for details.

* [@submarinerio](https://twitter.com/submarinerio)

See the [v0.8.0 Tweet example](https://twitter.com/submarinerio/status/1341347551396687872).
