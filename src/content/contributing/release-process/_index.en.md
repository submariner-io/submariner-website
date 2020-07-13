---
title: "Release Process"
date: 2020-03-18T16:03:26+01:00
weight: 10
---

This section explains the necessary steps to make a submariner release.
It is assumed that you are familiar with the submariner project and the various repositories.


## Project dependencies

When releasing the submariner components it's important to keep in mind the dependencies between projects, in terms of go libraries and docker images.

**something very important to note is that while in git we use the vx.x.x format, in docker we use x.x.x**

### go dependencies
`shipyard -e2e framework-` <- `admiral` <- `[submariner, lighthouse]` <- `submariner-operator`

### docker images
`subctl binary` <- `shipyard` <- `[admiral, submariner, lighthouse, submariner-operator]`

### docker image version notes

Currently, subctl and the operator expect that lighthouse and submariner are aligned on the same exact semver version.

## Step 0: Bump subctl into shipyard image, optional

This is only necessary if you have specific chages which will require a newer subctl version.

Edit ` package/Dockerfile.shipyard-dapper-base` and bump `SUBCTL_VERSION` to the new version, then send a pull request. 

Make sure it's merged.

## Step 1: Release shipyard

Tag and push the shipyard repository (or use the github release interface).

For this example we will use `v0.5.0` as the image.

Once this is done, CI will generate a `quay.io/submariner/shipyard-dapper-base:0.5.0` docker image. 

This step should generate images here:

> https://quay.io/repository/submariner/shipyard-dapper-base?tab=tags


## Step 2: Admiral

1) Edit `Dockerfile.dapper` and pin the image of shipyard to `0.5.0` instead of `devel`

2) Update the go.mod references:
```
make shell
go get github.com/submariner-io/shipyard@v0.5.0
go mod vendor
go mod tidy
exit
```

3) Send a pull request with the changes, and make sure it's merged before continuing

4) tag/push the merged changes as `v0.5.0`, or use the github interface to release admiral.


## Step 3: Submariner & Lighthouse

go to `submariner` and `lighthouse`,

1) Edit `Dockerfile.dapper` and pin the image of shipyard to `0.5.0`

2) Update the `go.mod` references
```
make shell
go get github.com/submariner-io/shipyard@v0.5.0
go get github.com/submariner-io/admiral@v0.5.0
go mod vendor
go mod tidy
```
3) Send a pull request with the changes, and make sure it's merged before continuing

4) tag/push the merged changes as `v0.5.0`, or use the github interface to release submariner/lighthouse.

This step should generate images here:

> https://quay.io/repository/submariner/lighthouse-agent?tab=tags
> https://quay.io/repository/submariner/lighthouse-coredns?tab=tags

## Step 4: Operator / subctl

go to `submariner-operator`

1) Edit `Dockerfile.dapper` and pin the image of shipyard to `0.5.0`

2) Update the `go.mod` references
```
make shell
go get github.com/submariner-io/shipyard@v0.5.0
go get github.com/submariner-io/admiral@v0.5.0
go get github.com/submariner-io/submariner@v0.5.0
go get github.com/submariner-io/lighthouse@v0.5.0
go mod vendor
go mod tidy
```

3) Edit versions/versions.go to update the referenced versions to `v0.5.0`

3) Send a pull request with the changes, and make sure it's merged before continuing

4) tag/push the merged changes as `v0.5.0`, or use the github interface to release submariner-operator and subctl.

This step should generate images here:

> https://quay.io/repository/submariner/submariner-operator?tab=tags

And binaries here (see the Assets section):

> https://github.com/submariner-io/submariner-operator/releases


### Verify the Subctl Binaries Release

At this point, you should see subctl binaries generated and listed for the various platforms under the release
 https://github.com/submariner-io/submariner-operator/tags, find the tag for 0.5.0 , verify that the binaries uploaded, the process needs around 5 minutes.
 
 ### Update the release notes
 
 Go to https://github.com/submariner-io/submariner-operator/tags, find the tag for `v0.5.0` and select "Edit release" to the right. 
 
Update the release notes.
 
If this is a pre-release, mark the checkbox "This is a pre-release".
 
 If this is not a pre-release update [the release notes on the website](https://github.com/submariner-io/submariner-website/edit/master/src/content/releases/_index.en.md).


## Step 4: Verify the Version

You can follow any of our quickstarts, for example [this one](../../quickstart/openshiftgn/)

## Step 5: Announce

### Via E-Mail

* <https://bit.ly/submariner-dev>
* <https://bit.ly/submariner-users>

### Via Twitter

* <https://twitter.com/submarinerio>
