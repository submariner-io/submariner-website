+++
title =  "Broker"
weight = 1
+++

Submariner uses a central Broker component to facilitate the exchange of metadata
information between Gateway Engines deployed in participating clusters. The Broker is
basically a set of Custom Resource Definitions (CRDs) backed by the Kubernetes datastore.
The Broker also defines a ServiceAccount and RBAC components to enable other Submariner
components to securely access the Broker's API. There are no Pods or Services deployed
with the Broker.

Submariner defines two CRDs that are exchanged via the Broker: `Endpoint` and `Cluster`.
The `Endpoint` CRD contains the information about the active Gateway Engine in a cluster,
such as its IP, needed for clusters to connect to one another. The `Cluster` CRD contains
static information about the originating cluster, such as its Service and Pod CIDRs.

The Broker is a singleton component that is deployed on a cluster whose Kubernetes API must
be accessible by all of the participating clusters. If there is a mix of on-premises and
public clusters, the Broker can be deployed on a public cluster. The Broker cluster may be
one of the participating clusters or a standalone cluster without the other Submariner
components deployed. The Gateway Engine components deployed in each participating cluster are
configured with the information to securely connect to the Broker cluster's API.
