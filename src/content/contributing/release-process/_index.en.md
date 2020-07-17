---
title: "Release Process"
date: 2020-03-18T16:03:26+01:00
weight: 10
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

The dapper base image that is provided by `shipyard` for building and E2E tests in all of the other projects pulls in the
`subctl` binary.
 
## Release versions

The `vx.x.x` version format is used for the git projects while `x.x.x` is used for Docker images.

The typical workflow is to first create release candidate(s) for testing before creating the final release. The suggested
naming convention is to append `-rcN` to the final version, for example `v0.5.0-rc0`, `v0.5.0-rc1` etc. 

Sometimes you may want to create a specific project release for testing prior to creating a release candidate. In this
case, the suggested naming convention is to append `-preN`.

## Create Submariner product release

The following outlines the steps to be taken in order to create a full Submariner product release. As an example, we'll
use version `v0.5.0`.

Project releases can either be created via the git CLI or the GitHub UI. This guide uses the GitHub UI as it is
simpler:

1) Navigate to the project's main releases page.

2) Click `Draft a new release`

3) Fill in the `Tag version` field with the new version.

4) Fill in the `Release title` field as appropriate. Typically this is just the version (sans the leading `v`) as a release
   usually contains various changes. But if it's a targeted release then the `Release title` can reflect that.
   
5) Enter information to describe the release. This is optional for pre-releases but should be filled in for
   a final release.
   
6) If this is not a final release, mark the checkbox `This is a pre-release`.

7) Click `Publish release`.

For most projects a GitHub action job will be initiated to build release artifacts and publish to Quay. This will take
several minutes. You can monitor the progress from the project's main page. A small yellow circle should be present to
the right of the heading above the file listing which indicates it's in progress. You can click it to see details. When
complete, it will change to either a green check mark or a red X.

### Step 0: Create a `subctl` pre-release, optional

Since `subctl` is provided by `shipyard`'s dapper base image, if there are specific changes to `subctl` which other
projects require, you will need to create a pre-release (for example `v0.5.0-pre0`) of the `submariner-operator` project: 

1) Navigate to the [releases](https://github.com/submariner-io/submariner-operator/releases) page and create the release
   with the new version.

2) In the `shipyard` project, edit `package/Dockerfile.shipyard-dapper-base` and set `SUBCTL_VERSION` to the new version.

3) Commit the change, create a pull request and merge it.

### Step 1: Create release for the `shipyard` project

Navigate to the [releases](https://github.com/submariner-io/shipyard/releases) page and create the release with the new
version. This will initiate a job to build the dapper base image. Once successfully completed, the generated image
version (`0.5.0`) should be available on Quay here: 

> https://quay.io/repository/submariner/shipyard-dapper-base?tab=tags


### Step 2: Create release for the `admiral` project

1) Pin the `shipyard` dapper base image to the new version. Edit `Dockerfile.dapper` and, on the first line, change
   the `shipyard-dapper-base` image version from `devel` to the new version (`0.5.0`).

2) Update the _go.mod_ and _go.sum_ references for `shipyard` to the new version:

```
make shell
go get github.com/submariner-io/shipyard@v0.5.0
go mod vendor
go mod tidy
exit
```

3) Commit the changes, create a pull request and merge it.

4) Navigate to [releases](https://github.com/submariner-io/admiral/releases) and create the release for the new version.

### Step 3: Create releases for the `submariner` and `lighthouse` projects

These can be done in any order or in parallel and the process is the same.

1) Pin the `shipyard` dapper base image to the new version. Edit `Dockerfile.dapper` and, on the first line, change
   the `shipyard-dapper-base` image version from `devel` to the new version (`0.5.0`).

2) Update the _go.mod_ and _go.sum_ references for the dependent projects to the new version:

```
make shell
go get github.com/submariner-io/shipyard@v0.5.0
go get github.com/submariner-io/admiral@v0.5.0
go mod vendor
go mod tidy
```

3) Commit the changes, create a pull request and merge it.

4) Navigate to the project's releases page and create the release for the new version.

Wait for the project's new images to be generated and published to Quay.

For `submariner`:

> https://quay.io/repository/submariner/submariner?tab=tags
> https://quay.io/repository/submariner/submariner-route-agent?tab=tags
> https://quay.io/repository/submariner/submariner-globalnet?tab=tags

For `lighthouse`:

> https://quay.io/repository/submariner/lighthouse-agent?tab=tags
> https://quay.io/repository/submariner/lighthouse-coredns?tab=tags

### Step 4: Create release for the `submariner-operator` project

1) Pin the `shipyard` dapper base image to the new version. Edit `Dockerfile.dapper` and, on the first line, change
   the `shipyard-dapper-base` image version from `devel` to the new version (`0.5.0`).
   
2) Update the _go.mod_ and _go.sum_ references for the dependent projects to the new version:

```
make shell
go get github.com/submariner-io/shipyard@v0.5.0
go get github.com/submariner-io/admiral@v0.5.0
go get github.com/submariner-io/submariner@v0.5.0
go get github.com/submariner-io/lighthouse@v0.5.0
go mod vendor
go mod tidy
```

3) Edit _pkg/versions/versions.go_ and update the *Version constants to the new version:

```
DefaultSubmarinerOperatorVersion = "0.5.0"
DefaultSubmarinerVersion         = "0.5.0"
DefaultLighthouseVersion         = "0.5.0"
```
3) Commit the changes, create a pull request and merge it.

4) Navigate to [releases](https://github.com/submariner-io/submariner-operator/releases) and create the release for the
   new version.

Once the build job successfully completes, the generated image version (`0.5.0`) should be available on Quay here: 

> https://quay.io/repository/submariner/submariner-operator?tab=tags

The `subctl` binaries for the various platforms should be listed under the `Assets` section for the new release on the
main [releases](https://github.com/submariner-io/submariner-operator/releases) page.
 
### Step 5: Update `subctl` version in `shipyard`

Update the dapper base image to pull in the latest `subctl` binary:

1) In the `shipyard` project, edit `package/Dockerfile.shipyard-dapper-base` and set `SUBCTL_VERSION` to the new version.

2) Commit the change, create a pull request and merge it.

### Step 6: Add release notes
 
If this is a final release, add a section for it on this website's [release notes](../..//releases/) page.

1) Clone the [submariner-website](https://github.com/submariner-io/submariner-website) project.

2) Open `src/content/releases/_index.en.md` and make changes.

3) Commit the changes and create a pull request.

Alternatively you can edit the file and create a pull request directly on GitHub
[here](https://github.com/submariner-io/submariner-website/edit/master/src/content/releases/_index.en.md)
 
### Step 7: Verify the release

You can follow any of the [quick start guides](../../quickstart).

### Step 8: Announce the release

#### Via E-Mail

* <https://bit.ly/submariner-dev>
* <https://bit.ly/submariner-users>

#### Via Twitter

* <https://twitter.com/submarinerio>
