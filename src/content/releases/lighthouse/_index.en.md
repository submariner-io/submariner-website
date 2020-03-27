---
title: "Releasing Lighthouse"
date: 2020-03-02T21:25:35+01:00
weight: 15
---

To make lighthouse release artifacts follow the below steps,

## Build Lighthouse CoreDNS

1) Get the coreDNS and change to the folder

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
sed -i '$a replace\ github.com/bronze1man/goStrongswanVici\ =>\ github.com/mangelajo/goStrongswanVici\ v0.0.0-20190223031456-9a5ae4453bd' go.mod

docker build  -f Dockerfile.openshift -t quay.io/submariner/${COREDNS_IMAGE} .
docker push quay.io/submariner/${COREDNS_IMAGE}
```

## Build Lighthouse Cluster-DNS-Operator

1) Clone  the Lighthouse Cluster-DNS branch and create a version branch

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





