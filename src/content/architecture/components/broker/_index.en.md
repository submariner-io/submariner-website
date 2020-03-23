---
title: "Broker"
---

Submariner uses a central broker to facilitate the exchange of
metadata information between connected clusters. The broker is
basically a set of custom resource definitions (CRDs) backed by the
kubernetes datastore. The broker is a singleton component that is
deployed on one of the clusters whose Kubernetes API must be
accessible by all of the connected clusters.
