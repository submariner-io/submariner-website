+++
title =  "Broker"
weight = 1
+++

Submariner uses a central Broker component to facilitate the exchange of metadata
information between Gateway Engines in participating clusters. The Broker is basically
a set of Custom Resource Definitions (CRDs) backed by the Kubernetes datastore. The
Endpoint CRD contains the information about the active Gateway Engine, such as its IP,
needed for clusters to connect to one another. The Cluster CRD contains static information
about the originating cluster, such as its Service and Pod CIDRs.

The Broker is a singleton component that is deployed on a cluster whose
Kubernetes API must be accessible by all of the participating clusters. The
Gateway Engine components running in each cluster are configured with the information
to securely connect to the Broker cluster's API. The Broker may be deployed on
one of the participating clusters or on a separate cluster without the other
Submariner components deployed.
