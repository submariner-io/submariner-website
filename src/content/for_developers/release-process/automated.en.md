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
we'll use version `v0.5.0`.

The release process is mostly automated and is centered on a release YAML file which is constantly updated.
On each step, once your pull request is reviewed and merged, the CI will create the required pull requests for
other projects and they in turn would need to be reviewed and merged.

### Step 1: Create release for the `shipyard` project

Navigate to the [releases](https://github.com/submariner-io/releases) repository and fork it.

1) Create a new branch for your intended release.

2) Author a new release file in the releases directory (You can copy the example.yaml file).

3) Fill in the general fields for the release.

4) Create a link to the file to make it the target release (So CI knows what we're releasing):

   ```bash
   ln -s <your-release-file.yaml> target
   ```

5) Commit the new files and create a new pull request.

### Step 2: Create release for the `admiral` project

Once the Shipyard pull request to pin the Admiral project is merged, use its commit id to pin to Admiral.

1) Create a new branch, or use your branch from before, on the fork of releases repository.

2) Update the `status` field to `admiral`.

3) Add the `admiral` component with the commit hash to the release yaml.

4) Commit the modified file and create a new pull request.

### Step 3: Create releases for the `submariner` and `lighthouse` projects

Once the pull requests to pin Lighthouse and Submariner to Admiral are merged, use their commit ids.

1) Create a new branch, or use your branch from before, on the fork of releases repository.

2) Update the `status` field to `projects`.

3) Add the `submariner` and `lighthouse` components with the commit hashes to the release yaml.

4) Commit the modified file and create a new pull request.

### Step 4: Create the final release

Once the pull request to submariner-operator has been merged, use its commit hash.

1) Create a new branch, or use your branch from before, on the fork of releases repository.

2) Update the `status` field to `released`.

3) Add the `submariner-operator` and `submariner-charts` components with the commit hashes to the release yaml.

4) Commit the modified file and create a new pull request.

Once the pull request is merged and the release job successfully completes, the generated images with tag `0.5.0`
should be available on [Quay.io](https://quay.io/organization/submariner/) (Under the respectful images)

The release itself will be created on the [releases repository](https://github.com/submariner-io/releases/releases)
and will contain the released subctl files.

### Step 5: Update `subctl` version in `shipyard`

Update the Dapper base image to pull in the latest `subctl` binary:

1) In the `shipyard` project, edit `package/Dockerfile.shipyard-dapper-base` and set `SUBCTL_VERSION` to the new version.

2) Commit the change and create a pull request with the `e2e-projects` label so it runs the E2E tests on the consuming projects. After the
   tests successfully complete, have it merged.

### Step 6: Unpin the `shipyard` Dapper base image version

At this point the new product release has been successfully created however we don't want to leave each downstream
project pinned to the new `shipyard` Dapper base image version. For ongoing development we want each project to
automatically pick up the latest changes to the base image.

For each project, `admiral`, `lighthouse`, `submariner`, and `submariner-operator`:

1) Edit `Dockerfile.dapper` and, on the first line, change the `shipyard-dapper-base` image version back to `devel`.

2) Commit the changes, create a pull request, and have it merged.

### Step 7: Add release notes

If this is a final release, add a section for it on this website's [release notes](../../releases/) page.

1) Clone the [submariner-website](https://github.com/submariner-io/submariner-website) project.

2) Open `src/content/releases/_index.en.md` and make changes.

3) Commit the changes, create a pull request, and have it reviewed and merged.

Alternatively you can edit the file and create a pull request directly on GitHub
[here](https://github.com/submariner-io/submariner-website/edit/master/src/content/releases/_index.en.md)

### Step 8: Verify the release

You can follow any of the [quick start guides](../../quickstart).

### Step 9: Update the Submariner Operator on OperatorHub.io

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

### Step 10: Announce the release

#### Via E-Mail

* <https://bit.ly/submariner-dev>
* <https://bit.ly/submariner-users>

#### Via Twitter

* <https://twitter.com/submarinerio>
