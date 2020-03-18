---
title: "Release process"
date: 2020-03-18T16:03:26+01:00
weight: 10
---


In this section of the documentation we explain the necessary steps to make a submariner release,
it's assumed that you are familiar with the submariner project and the different repositories.


# Step 1: release submariner (core)


Assuming that you have an existing submariner git directory, and that you are making a release based in master.

```bash
cd submariner
git remote add upstream ssh://git@github.com/submariner-io/submariner
git fetch -a -v -t
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

At this point the release should appear here, a github release can be created.

> https://github.com/submariner-io/submariner/tags

A build should start:

> https://travis-ci.com/github/submariner-io/submariner/branches

Look under the "Active branches" section for v0.2.0-rc0 , and monitor that the build
completes successfully, specially the Deploy section, where the images are pushed to quay.io, those should eventually appear here after the job has finished:

For this example the build can be found [here](https://travis-ci.com/github/submariner-io/submariner/builds/153943761) from all the sub-builds, the one tagged with DEPLOY=true will push the resulting image to quay, as can be seen here: [deployment script](https://travis-ci.com/github/submariner-io/submariner/jobs/299505392#L3417)

Finally once that has finished, a 0.2.0-rc0 tag will be available here:

> https://quay.io/repository/submariner/submariner?tab=tags



# Step 2: release lighthouse

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

# Step 3: update operator version references, and release

Once the other builds have finished and you have image tags 0.2.0-rc0 on submariner and ligthouse repos, you can proceed with changes to the operator

## Reference versions

Edit the reference versions from the right operator/subctl branch:

> https://github.com/submariner-io/submariner-operator/edit/master/pkg/versions/versions.go

and send a PR, wait for CI to pass, and get approval/merge. See an example PR here: [0.2.0-rc0-release-pr](https://github.com/submariner-io/submariner-operator/pull/276)


## Tag the operator repository (once the previous PR is merged)

Assuming that you have an existing lighthouse git directory, and that you are making a release based in master.

```bash
cd submariner-operator
git remote add upstream ssh://git@github.com/submariner-io/submariner-operator
git fetch -a -v -t
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```
