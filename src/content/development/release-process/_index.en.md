---
title: "Release Process"
date: 2020-03-18T16:03:26+01:00
weight: 40
---

This section describes how to create a Submariner product release. It is assumed that you are familiar with the various
Submariner projects and their repositories and are familiar with Git and GitHub.

## Project dependencies

The Submariner projects have a dependency hierarchy with respect to their Go libraries and Docker images.
Therefore the releases for each individual project must be created in a specific order.

The Go dependency hierarchy flow is as follows:

`shipyard` <- `admiral` <- `[submariner, lighthouse, cloud-prepare]` <- `submariner-operator`

Note that the `submariner` and `lighthouse` projects are siblings and thus do not depend on one another. Also the
`submariner-operator` components expect that `lighthouse` and `submariner` are aligned on the same exact version.
The cloud-prepare library is consumed by the operator as well.

The Docker image dependency hierarchy flow is as follows:

`subctl binary` <- `shipyard dapper base image` <- `[admiral, cloud-prepare, submariner, lighthouse, submariner-operator]`

The Dapper base image that is provided by `shipyard` for building and E2E tests in all of the other projects pulls in the
`subctl` binary.

## Release versions

The `vx.x.x` version format is used for the git projects while `x.x.x` is used for Docker images.

The typical workflow is to first create release candidate(s) for testing before creating the final release. The suggested
naming convention is to append `-rcN` to the final version, for example `v0.8.0-rc0`, `v0.8.0-rc1` etc.

Sometimes you may want to create a specific project release for testing prior to creating a release candidate. In this
case, the suggested naming convention is to append `-preN`.

### Stable branches and versions

Stable branches will be maintained for major and minor versions. For example, versions v0.8.0, v0.8.1 and
any other 0.8.x releases will all be maintained and released on the `release-0.8` branch.

The automated release process described here can also create these stable branches when necessary.
The branch should be specified in the release YAML file. If a stable branch isn't specified, the development branch is used.

## Create Submariner product release

The following sections outline the steps to be taken in order to create a full Submariner product release. As an example,
we'll use version `v0.8.0`.

The release process is mostly automated and uses a YAML file created in the releases repository that describes the release.
This file is updated for each step in the release process.

Once the changes for a step are reviewed and merged, a CI job will run to create the release(s) for the step and create the
required pull requests in preparation for the next step to be reviewed and merged. Once all these pull requests have been
merged, you can continue onto the next step.

For most projects, after a release is created, another job will be initiated to build release artifacts and publish to Quay.
This will take several minutes. You can monitor the progress from the project's main page. In the branches/tags pull-down
above the file list heading, select the tag for the new version. A small yellow circle icon should be present to the right
of the file list heading which indicates a job is in progress. You can click it to see details. There may be several checks
for the job listed but the important one is `Release Images`. When complete, the indicator icon will change to either a
green check mark on success or a red X on failure. A failure likely means the artifacts were not published to Quay, in
which case select the failed check, inspect the logs, correct the issue and re-run the job.

### Sometimes: Create stable branches for stable releases

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

### Step 1: Create release for the `shipyard` project

Navigate to the [releases](https://github.com/submariner-io/releases) repository.

1) Create a new file in the `releases` directory (you can copy the `example.yaml file`). For our example, we'll name it `v0.8.0.yaml`.

2) Fill in the general fields for the release with the `status` field set to `shipyard`. Also add the `shipyard` component with
   the hash of the desired or latest commit ID on which to base the release. To obtain the latest, first navigate to
   the [shipyard project](https://github.com/submariner-io/shipyard). The heading above the file list shows the latest
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

Once the pull request is merged, it will trigger a CI job to create a
[shipyard release](https://github.com/submariner-io/submariner-operator/releases) and build the Dapper base image. In addition,
it creates pull requests in the projects that consume `shipyard` to update them to the new version in preparation for the
subsequent steps.

On successful completion, the generated image version (`0.8.0`) should be available on Quay here:

> <https://quay.io/repository/submariner/shipyard-dapper-base?tab=tags>

### Step 2: Create release for the `admiral` project

Once the pull request to pin the `admiral` project to the new `shipyard` version is merged, we can proceed to updating the
release YAML file to create an `admiral` release.

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

Once the pull request is merged, it will trigger a CI job to create an
[admiral release](https://github.com/submariner-io/admiral/releases) and pull requests in the consuming projects to pin them
to the new version in preparation for the subsequent steps.

### Step 3: Create releases for the `cloud-prepare`, `lighthouse` and `submariner` projects

Once the pull requests to pin the `cloud-prepare`, `lighthouse` and `submariner` projects to the new `admiral` version are merged:

1) Edit the release yaml file (`v0.8.0.yaml`). Update the `status` field to `projects` and add the `submariner`, `cloud-prepare` and
   `lighthouse` components with their latest commit ID hashes:

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

2) Commit your changes, make sure your branch is rebased properly, create a pull request, and have it reviewed.

Once the pull request is merged, it will trigger a CI job to create
[cloud-prepare](https://github.com/submariner-io/cloud-prepare/releases),
[lighthouse](https://github.com/submariner-io/lighthouse/releases) and
[submariner](https://github.com/submariner-io/submariner/releases) releases and a pull request to pin the consuming
`submariner-operator` project to the new version.

On successful completion, the new image versions (`0.8.0`) should be available on Quay.

<!-- markdownlint-disable no-inline-html -->
For `submariner`:

> <https://quay.io/repository/submariner/submariner?tab=tags> <br>
> <https://quay.io/repository/submariner/submariner-route-agent?tab=tags> <br>
> <https://quay.io/repository/submariner/submariner-globalnet?tab=tags> <br>
> <https://quay.io/repository/submariner/submariner-networkplugin-syncer?tab=tags>

For `lighthouse`:

> <https://quay.io/repository/submariner/lighthouse-agent?tab=tags> <br>
> <https://quay.io/repository/submariner/lighthouse-coredns?tab=tags>
<!-- markdownlint-enable no-inline-html -->

### Step 4: Create the product release

Once the pull request to pin the `submariner-operator` has been merged, we can create the final product release:

1) Edit the release yaml file (`v0.8.0.yaml`). Update the `status` field to `released` and add the `submariner-operator`
   and `submariner-charts` components with their latest commit ID hashes:

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

Once the pull request is merged, it will trigger a CI job to generate and tag the `submariner-operator` image which should be
made available on Quay here:

> <https://quay.io/repository/submariner/submariner-operator?tab=tags>

The final product release will be created on the [releases repository](https://github.com/submariner-io/releases/releases)
with a job triggered to publish the `subctl` binaries for the various platforms. These should be listed under the `Assets`
section for the new release. If not then the job failed so correct the issue and re-run the job.

If the release wasn't marked as a `pre-release`, the release job will also create pull requests in each consuming project
to unpin the `shipyard` Dapper base image version, that is set it back to `devel`. For ongoing development we want each
project to automatically pick up the latest changes to the base image.

### Step 5: Add release notes

If this is a final release, add a section for it on this website's [release notes](../../community/releases/) page.

1) Clone the [submariner-website](https://github.com/submariner-io/submariner-website) project.

2) Open `src/content/releases/_index.en.md` and make changes.

3) Commit your changes, create a pull request, and have it reviewed.

Alternatively you can edit the file and create a pull request directly on GitHub
[here](https://github.com/submariner-io/submariner-website/edit/devel/src/content/community/releases/_index.en.md)

### Step 6: Verify the release

You can follow any of the [quick start guides](../../getting-started/quickstart).

### Step 7: Update the Submariner Operator on OperatorHub.io

The [community-operators](https://github.com/operator-framework/community-operators) Git repository
is the source for sharing Kubernetes Operators with the broader community. This repository is split into two sections:

* Operators for deployment to a vanilla Kubernetes environment (upstream-community-operators).
These are shared with the Kubernetes community via [OperatorHub.io](https://operatorhub.io/).
* Operators for deployment to OpenShift (community-operators)

Here we are going to update the Submariner Operator on OperatorHub.io. OpenShift users will find the Operator in the
official Red Hat catalog.

To publish the Submariner Operator to the community, perform the following steps:

1) Clone the [submariner-operator](https://github.com/submariner-io/submariner-operator) project
2) Make sure you have operator-sdk v1 installed on your machine
   otherwise follow [this guide](https://v1-0-x.sdk.operatorframework.io/docs/installation/install-operator-sdk/)
3) Generate new package manifests by running the command:

   ```bash
   make packagemanifests VERSION=${new_version} FROM_VERSION=${previous_version} CHANNEL=${channel}
   ```

   the generated package output should be located in `/packagemanifests/${VERSION}/`
4) Fork and clone [community-operators](https://github.com/operator-framework/community-operators) project.
5) Update the Kubernetes Operator:
    * copy the generated package from step 3 into `upstream-community-operators/submariner`
    * copy the generated package definition `/packagemanifests/submariner.package.yaml`
    into `upstream-community-operators/submariner/`
    * test the Operator by running the command: `make operator.test OP_PATH=upstream-community-operators/submariner`
    * preview the Operator on [OperatorHub.io](https://operatorhub.io/preview)
    * once everything is fine, review this
    [checklist](https://github.com/operator-framework/community-operators/blob/master/docs/pull_request_template.md)
    and create a new PR on [community-operators](https://github.com/operator-framework/community-operators)

### Step 8: Announce the release

#### Via E-Mail

* <https://bit.ly/submariner-dev>
* <https://bit.ly/submariner-users>

#### Via Twitter

* <https://twitter.com/submarinerio>
