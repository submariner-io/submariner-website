---
title: "Release Process"
date: 2020-03-18T16:03:26+01:00
weight: 10
---

This section explains the necessary steps to make a submariner release.
It is assumed that you are familiar with the submariner project and the various repositories.


## Step 1: Create a Submariner Release


Assuming that you have an existing submariner git directory, the following steps create a release named "Globalnet Overlapping IP support RC0" with version v0.2.0-rc0 based on the master branch.

```bash
cd submariner
git stash
git remote add upstream ssh://git@github.com/submariner-io/submariner
git fetch -a -v -t upstream
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

A tagged release should appear [here](https://github.com/submariner-io/submariner/tags).

> https://github.com/submariner-io/submariner/tags

A build for v0.2.0-rc0 should start and appear under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/submariner/branches).

> https://travis-ci.com/github/submariner-io/submariner/branches

Verify that the build successfully completes as indicated by a green checkmark at the right. At this point the images tagged with 0.2.0-rc0 will be available [here](https://quay.io/repository/submariner/submariner?tab=tags).

> https://quay.io/repository/submariner/submariner?tab=tags

<!-- TODO(mangelajo) https://github.com/submariner-io/submariner-website/issues/46 -->


## Step 2: Create a Lighthouse Release

To create lighthouse release artifacts follow the steps below.

### Build Lighthouse Controller

Assuming that you have an existing lighthouse git directory, run the following steps .

```bash
cd lighthouse
git stash
git remote add upstream ssh://git@github.com/submariner-io/lighthouse
git fetch -a -v -t upstream
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

A tagged release should appear [here](https://github.com/submariner-io/lighthouse/tags)

> https://github.com/submariner-io/lighthouse/tags

A build for v0.2.0-rc0 should start and appear under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/lighthouse/branches)

> https://travis-ci.com/github/submariner-io/lighthouse/branches

For this example the build can be found [here](https://travis-ci.com/github/submariner-io/lighthouse/builds/153946391).

Verify that the build successfully completes as indicated by a green checkmark at the right. At this point the images tagged with 0.2.0-rc0 will be available on quay.io at:

> https://quay.io/repository/submariner/lighthouse-controller?tab=tags
> https://quay.io/repository/submariner/lighthouse-coredns?tab=tags

### Build Lighthouse CoreDNS

1) Get the coredns repository and change to the folder

```bash
go get github.com/openshift/coredns
cd $GOPATH/src/github.com/openshift/coredns
```
2) Build the image and push

```bash
COREDNS_VERSION=<VERSION-NO>
LH_COREDNS_VERSION=<LH-VERSION-NO>
COREDNS_IMAGE="lighthouse-coredns:${LH_COREDNS_VERSION}"
git checkout -b ${COREDNS_VERSION}
sed -i '/^kubernetes:kubernetes/a lighthouse:github.com/submariner-io/lighthouse/plugin/lighthouse' plugin.cfg
sed -i '/^github.com/aws/aws-sdk-go/a github.com/submariner-io/lighthouse v0.2.0' go.mod
sed -i '$a replace\ k8s.io\/apimachinery\ =>\ k8s.io\/apimachinery\ v0.0.0-20190313205120-d7deff9243b1' go.mod
sed -i '$a replace\ github.com\/openzipkin-contrib\/zipkin-go-opentracing\ =>\ github.com\/openzipkin-contrib\/zipkin-go-opentracing\ v0.3.5' go.mod
docker build  -f Dockerfile.openshift -t quay.io/submariner/${COREDNS_IMAGE} .
docker push quay.io/submariner/${COREDNS_IMAGE}
```

### Build Cluster-DNS-Operator

1) Clone the cluster-dns-operator repository and create a version branch

```bash
git clone https://github.com/submariner-io/cluster-dns-operator.git
git checkout -b <VERSION-NO>
```

2) Change the coredns and cluster dns operator versions.

```
	- name: dns-operator
          terminationMessagePolicy: FallbackToLogsOnError
          image: quay.io/submariner/lighthouse-cluster-dns-operator:<VERSION-NO>
          command:
          - dns-operator
          env:
          - name: RELEASE_VERSION
            value: "0.0.1-snapshot"
          - name: IMAGE
            value: quay.io/submariner/lighthouse-coredns:<VERSION-NO>
```

For example,
https://github.com/submariner-io/cluster-dns-operator/pull/1/files#diff-8c85a5683e17f9599cbfc641cceaa040R33

3) Build a new image and upload it to quay.

```bash
REPO=quay.io/submariner/lighthouse-cluster-dns-operator:$VERSION make release-local
```

3) Commit and push the changes and raise a PR.

```bash
git add .
git commit -s
git push HEAD:<VERSION-NO>
```

## Step 3: Update the Operator Version References and Create a Release

Once the other builds have finished and you have 0.2.0-rc0 release tags for the submariner and lighthouse projects, you can proceed with changes to the operator.

### Change Referenced Versions

Edit the operator [versions](https://github.com/submariner-io/submariner-operator/edit/master/pkg/versions/versions.go) file and change the project version constants to reference the new release, "0.2.0-rc0".


```bash
cd submariner-operator
git stash
git remote add upstream ssh://git@github.com/submariner-io/submariner-operator
git fetch -a -v -t upstream
git checkout remotes/upstream/master -B update-references-to-v0.2.0-rc0
vim pkg/versions/versions.go
# make sure we are referencing the latest submariner code (we use it for verify-connectivity and the API)
GO111MODULES=on go get github.com/submariner-io/submariner@v0.2.0-rc0
git push my-repo update-references-to-v0.2.0-rc0
```


Create a pull request, wait for the CI job to pass, and get approval/merge. See an example PR [here](https://github.com/submariner-io/submariner-operator/pull/276)


### Create a Submariner-Operator Release

Assuming you have an existing submariner-operator git directory, run the following steps:

```bash
cd submariner-operator
git stash
git remote add upstream ssh://git@github.com/submariner-io/submariner-operator
git fetch -a -v -t upstream
git checkout remotes/upstream/master -B master
git tag -s -m "Globalnet Overlapping IP support RC0" v0.2.0-rc0
git push upstream v0.2.0-rc0
```

A tagged release should appear [here](https://github.com/submariner-io/submariner-operator/tags).

> https://github.com/submariner-io/submariner-operator/tags

A build for v0.2.0-rc0 should start and appear under the under the "Active branches" section [here](https://travis-ci.com/github/submariner-io/submariner-operator/branches).

> https://travis-ci.com/github/submariner-io/submariner-operator/branches

Verify that the build successfully completes as indicated by a green checkmark at the right.
At this point the images tagged with 0.2.0-rc0 will be available [here](https://quay.io/repository/submariner/submariner-operator?tab=tags).

> https://quay.io/repository/submariner/submariner-operator?tab=tags


### Verify the Subctl Binaries Release

At this point, you should see subctl binaries generated and listed for the various platforms under the release
 https://github.com/submariner-io/submariner-operator/tags, find the tag for v0.2.0-rc0 

If this is a pre-release, mark the checkbox "This is a pre-release".

## Step 4: Verify the Version

You can follow any of our quickstarts, for example [this one](../../quickstart/openshiftgn/)

## Step 5: Announce

### Via E-Mail

* <https://bit.ly/submariner-dev>
* <https://bit.ly/submariner-users>

### Via Twitter

* <https://twitter.com/submarinerio>
