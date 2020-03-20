---
title: "Release process"
date: 2020-03-18T16:03:26+01:00
weight: 10
---

This section explains the necessary steps to make a submariner release.
It is assumed that you are familiar with the submariner project and the various repositories.


# Step 1: create a submariner release


Assuming that you have an existing submariner git directory, the following steps create a release named "Globalnet Overlapping IP support RC0" with version v0.2.0-rc0 based on the master branch.

```bash
cd submariner
git remote add upstream ssh://git@github.com/submariner-io/submariner
git fetch -a -v -t
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

A tagged release should appear [here](https://github.com/submariner-io/submariner/tags).

> https://github.com/submariner-io/submariner/tags

A build for v0.2.0-rc0 should start and appear under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/submariner/branches).

> https://travis-ci.com/github/submariner-io/submariner/branches

Verify that the build successfully completes as indicated by a green checkmark at the right. At this point the images tagged with 0.2.0-rc0 will be available [here](https://quay.io/repository/submariner/submariner?tab=tags)..

For this example the build can be found [here](https://travis-ci.com/github/submariner-io/submariner/builds/153943761) from all the sub-builds, the one tagged with DEPLOY=true will push the resulting image to quay, as can be seen here: [deployment script](https://travis-ci.com/github/submariner-io/submariner/jobs/299505392#L3417)

Finally once that has finished, a 0.2.0-rc0 tag will be available [here](https://quay.io/repository/submariner/submariner?tab=tags).

> https://quay.io/repository/submariner/submariner?tab=tags



# Step 2: create a lighthouse release

Assuming that you have an existing lighthouse git directory, run the following steps .

```bash
cd lighthouse
git remote add upstream ssh://git@github.com/submariner-io/lighthouse
git fetch -a -v -t
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

A tagged release should appear [here](https://github.com/submariner-io/lighthouse/tags)

> https://github.com/submariner-io/lighthouse/tags

A build for v0.2.0-rc0 should start and appear under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/lighthouse/branches)

> https://travis-ci.com/github/submariner-io/lighthouse/branches

For this example the build can be found [here](https://travis-ci.com/github/submariner-io/lighthouse/builds/153946391).

Look under the "Active branches" section for v0.2.0-rc0, and monitor the build.
Verify that the build successfully completes as indicated by a green checkmark at the right. At this point the images tagged with 0.2.0-rc0 will be available on quay.io at:

> https://quay.io/repository/submariner/lighthouse-controller?tab=tags
> https://quay.io/repository/submariner/lighthouse-coredns?tab=tags

<!-- TODO: Aswin: the openshift-coredns part -->

# Step 3: update the operator version references and create a release

Once the other builds have finished and you have 0.2.0-rc0 release tags for the submariner and lighthouse projects, you can proceed with changes to the operator.

## Change referenced versions

Edit the operator [versions](https://github.com/submariner-io/submariner-operator/edit/master/pkg/versions/versions.go) file and change the project version constants to reference the new release, "0.2.0-rc0".

> https://github.com/submariner-io/submariner-operator/edit/master/pkg/versions/versions.go

Create a pull request, wait for the CI job to pass, and get approval/merge. See an example PR [here](https://github.com/submariner-io/submariner-operator/pull/276)


## Create a submariner-operator release

Assuming you have an existing submariner-operator git directory, run the following steps:

```bash
cd submariner-operator
git remote add upstream ssh://git@github.com/submariner-io/submariner-operator
git fetch -a -v -t
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```


A tagged release should appear [here](https://github.com/submariner-io/submariner-operator/tags).

> https://github.com/submariner-io/submariner-operator/tags

A build for v0.2.0-rc0 should start and appear under the under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/submariner-operator/branches).

> https://travis-ci.com/github/submariner-io/submariner-operator/branches

Look under the "Active branches" section for v0.2.0-rc0 , and monitor the build.
Verify that the build successfully completes as indicated by a green checkmark at the right.
At this point the images are pushed to quay.io.

Finally once that has finished, a 0.2.0-rc0 tag will be available [here](https://quay.io/repository/submariner/submariner-operator?tab=tags).

> https://quay.io/repository/submariner/submariner-operator?tab=tags


## Create the subctl binaries release


```bash
cd submariner-operator
git fetch -a -v -t
git checkout v0.2.0-rc0
rm bin/subctl*
make build-cross
ls -la bin/subctl*
```
At this point, you should see subctl binaries generated and listed for the various platforms under bin.
Go to https://github.com/submariner-io/submariner-operator/tags, find the tag for v0.2.0-rc0 and select "Edit release" to the right. Then upload the generated subctl binaries.

If this is a pre-release, mark the checkbox "This is a pre-release".

# Announce

## email

to:
* bit.ly/submariner-dev
* bit.ly/submariner-users

## twitter

under:
* twitter.com/submarinerio
