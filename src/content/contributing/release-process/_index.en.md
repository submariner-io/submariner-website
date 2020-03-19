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

A build for v0.2.0-rc0 should start and appear under the under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/submariner/branches).

> https://travis-ci.com/github/submariner-io/submariner/branches

Look under the "Active branches" section for v0.2.0-rc0 , and monitor that the build
Verify that the build successfully completes as indicated by a green checkmark at the right . At this point the images are pushed to quay.io.

For this example the build can be found [here](https://travis-ci.com/github/submariner-io/submariner/builds/153943761) from all the sub-builds, the one tagged with DEPLOY=true will push the resulting image to quay, as can be seen here: [deployment script](https://travis-ci.com/github/submariner-io/submariner/jobs/299505392#L3417)

Finally once that has finished, a 0.2.0-rc0 tag will be available [here](https://quay.io/repository/submariner/submariner?tab=tags).

> https://quay.io/repository/submariner/submariner?tab=tags



# Step 2: create a lighthouse release

Assuming that you have an existing lighthouse git directory, and that you are making a release based in master.

```bash
cd lighthouse
git remote add upstream ssh://git@github.com/submariner-io/lighthouse
git fetch -a -v -t
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

At this point the release should appear here, a github release can be created.

> https://github.com/submariner-io/lighthouse/tags

A build should start:

> https://travis-ci.com/github/submariner-io/lighthouse/branches

For this example the build can be found [here](https://travis-ci.com/github/submariner-io/lighthouse/builds/153946391).

Look under the "Active branches" section for v0.2.0-rc0 , and monitor that the build
completes successfully, specially the Deploy section, where the images are pushed to quay.io, those should eventually appear here after the job has finished:

> https://quay.io/repository/submariner/lighthouse-controller?tab=tags
> https://quay.io/repository/submariner/lighthouse-coredns?tab=tags

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
