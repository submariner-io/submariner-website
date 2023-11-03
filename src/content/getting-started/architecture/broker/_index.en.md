+++
title =  "Broker"
weight = 10
+++

Submariner uses a central Broker component to facilitate the exchange of metadata
information between Gateway Engines deployed in participating clusters. The Broker is
basically a set of Custom Resource Definitions (CRDs) backed by the Kubernetes datastore.
The Broker also defines a ServiceAccount and RBAC components to enable other Submariner
components to securely access the Broker's API.

While there no Services associated with the Broker, if using ```subctl``` to deploy the Broker, an
operator Pod is also deployed that installs the CRDs and the Globalnet configuration.

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

The availability of the Broker cluster does not affect the operation of the dataplane on the
participating clusters, that is the dataplane will continue to route traffic using the last known
information while the Broker is unavailable. However, during this time, control plane components
will be unable to advertise new or updated information to other clusters and learn about new or updated
information from other clusters. When connection is re-established to the Broker, each component will
automatically re-synchronize its local information with the Broker and update the dataplane if necessary.
