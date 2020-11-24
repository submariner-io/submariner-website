---
title: "Release Process (Automated)"
date: 2020-03-18T16:03:26+01:00
weight: 70
---

This section describes how to create a Submariner product release. It is assumed that you are familiar with the various
Submariner projects and their repositories and are familiar with Git and GitHub.

## Project dependencies

The Submariner projects have a dependency hierarchy with respect to their Go libraries and Docker images.
Therefore the releases for each individual project must be created in a specific order.

The Go dependency hierarchy flow is as follows:

`shipyard` <- `admiral` <- `[submariner, lighthouse]` <- `submariner-operator`

Note that the `submariner` and `lighthouse` projects are siblings and thus do not depend on one another. Also the
`submariner-operator` components expect that `lighthouse` and `submariner` are aligned on the same exact version.

The Docker image dependency hierarchy flow is as follows:

`subctl binary` <- `shipyard dapper base image` <- `[admiral, submariner, lighthouse, submariner-operator]`

The Dapper base image that is provided by `shipyard` for building and E2E tests in all of the other projects pulls in the
`subctl` binary.

## Release versions

The `vx.x.x` version format is used for the git projects while `x.x.x` is used for Docker images.

The typical workflow is to first create release candidate(s) for testing before creating the final release. The suggested
naming convention is to append `-rcN` to the final version, for example `v0.5.0-rc0`, `v0.5.0-rc1` etc.

Sometimes you may want to create a specific project release for testing prior to creating a release candidate. In this
case, the suggested naming convention is to append `-preN`.

## Create Submariner product release

The following sections outline the steps to be taken in order to create a full Submariner product release. As an example,
we'll use version `v0.8.0`.

The release process is mostly automated and uses a YAML file created in the releases repository that describes the release.
This file is updated for each step in the release process.

Once the changes for a step are reviewed and merged, a CI job will run and create the required pull requests for the next
step to be reviewed and merged.
Once all these patches have been merged, you can continue to the next stage.

### Step 1: Create release for the `shipyard` project

Navigate to the [releases](https://github.com/submariner-io/releases) repository and fork it.

1) Create a new branch for your intended release.

2) Create a new file in the releases directory (you can copy the example.yaml file). For our example. we'll name it `v0.8.0.yaml`.

3) Fill in the general fields for the release, for example:

   ```yaml
   version: v0.8.0
   name: v0.8.0 - The mighty one
   #pre-release: true # if it was one
   release-notes: Lorem ipsum
   status: shipyard
   components:
     shipyard: <hash goes here>
   ```

4) Create a link for the file to make it the target release.

   ```bash
   ln -s <your-release-file.yaml> target
   ```

5) Commit the new files and create a new pull request.

6) Have the pull request reviewed and merged, which will trigger the release CI job. The job will then create a Shipyard release and
   pull requests to pin all Shipyard consuming projects to the release version.

### Step 2: Create release for the `admiral` project

Once the pull request to pin the Admiral project to Shipyard is merged, use the commit hash of Admiral in the next stage.

1) On your fork, reuse the previous branch (or create a new one).

2) Update the `status` field to `admiral`.

3) Add the `admiral` component with the commit hash to the release yaml, for example:

   ```diff
    version: v0.8.0
    name: v0.8.0 - The mighty one
    #pre-release: true # if it was one
    release-notes: Lorem ipsum
   -status: shipyard
   +status: admiral
    components:
      shipyard: <hash goes here>
   +  admiral: <hash goes here>
   ```

4) Commit the modified file and create a new pull request.

5) Have the pull request reviewed and merged, which will trigger the release CI job. The job will then create an Admiral release and
   pull requests to pin all Admiral consuming projects to the release version.

### Step 3: Create releases for the `lighthouse` and `submariner` projects

Once the pull requests to pin Lighthouse and Submariner to Admiral are merged, use the commit hashes from them in the next stage.

1) On your fork, reuse the previous branch (or create a new one).

2) Update the `status` field to `projects`.

3) Add the `submariner` and `lighthouse` components with the commit hashes to the release yaml, for example:

   ```diff
    version: v0.8.0
    name: v0.8.0 - The mighty one
    #pre-release: true # if it was one
    release-notes: Lorem ipsum
   -status: admiral
   +status: projects
    components:
      shipyard: <hash goes here>
      admiral: <hash goes here>
   +  lighthouse: <hash goes here>
   +  submariner: <hash goes here>
   ```

4) Commit the modified file and create a new pull request.

5) Have the pull request reviewed and merged, which will trigger the release CI job.
   The job will then create releases for Lighthouse and Submariner and a pull request to pin submariner-operator to these components.

### Step 4: Finalize the release

Once the pull request to submariner-operator has been merged, use the submariner-operator commit hash in the next stage.

1) On your fork, reuse the previous branch (or create a new one).

2) Update the `status` field to `released`.

3) Add the `submariner-operator` and `submariner-charts` components with the commit hashes to the release yaml, for example:

   ```diff
    version: v0.8.0
    name: v0.8.0 - The mighty one
    #pre-release: true # if it was one
    release-notes: Lorem ipsum
   -status: projects
   +status: released
    components:
      shipyard: <hash goes here>
      admiral: <hash goes here>
      lighthouse: <hash goes here>
      submariner: <hash goes here>
   +  submariner-charts: <hash goes here>
   +  submariner-operator: <hash goes here>
   ```

4) Commit the modified file and create a new pull request.

Once this last pull request is merged the CI will run a release job which will tag the images with the release tag (e.g. `0.8.0`).
The images should be available on [Quay.io](https://quay.io/organization/submariner/) (Under the respectful image repositories).

The release itself will be created on the [releases repository](https://github.com/submariner-io/releases/releases)
and will contain the released subctl files.

In case the release wasn't marked as `pre-release`, the release job will also create patches to un-pin Shipyard.

### Step 5: Add release notes

If this is a final release, add a section for it on this website's [release notes](../../community/releases/) page.

1) Clone the [submariner-website](https://github.com/submariner-io/submariner-website) project.

2) Open `src/content/releases/_index.en.md` and make changes.

3) Commit the changes, create a pull request, and have it reviewed and merged.

Alternatively you can edit the file and create a pull request directly on GitHub
[here](https://github.com/submariner-io/submariner-website/edit/master/src/content/community/releases/_index.en.md)

### Step 6: Verify the release

You can follow any of the [quick start guides](../../getting_started/quickstart).

### Step 7: Update the Submariner Operator on OperatorHub.io

The [community-operators](https://github.com/operator-framework/community-operators) Git repository
is the source for sharing Kubernetes Operators with the broader community. This repository is split into two sections:

* Operators for deployment to a vanilla Kubernetes environment (upstream-community-operators).
These are shared with the Kubernetes community via [OperatorHub.io](https://operatorhub.io/).
* Operators for deployment to OpenShift (community-operators)

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
6) Update the OpenShift Operator:
   * re-run step 5 on the `community-operators/submariner` directory.

### Step 8: Announce the release

#### Via E-Mail

* <https://bit.ly/submariner-dev>
* <https://bit.ly/submariner-users>

#### Via Twitter

* <https://twitter.com/submarinerio>
