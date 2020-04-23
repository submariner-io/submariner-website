---
title: "Adding Shipyard to a Project"
date: 2020-04-20T17:12:52+0300
weight: 10
---

To use Shipyard for your project, it's easiest to use *[Dapper](https://github.com/rancher/dapper)* and *make*.
To use Dapper you'll need a specific Dockerfile that Dapper consumes to create a consistent environment based upon Shipyard's base image.
To use make you'll need some commands to enable Dapper and also include the targets which ship in the base image.

## Dockerfile.dapper

The project should have a `Dockerfile.dapper` dockerfile which builds upon `quay.io/submariner/shipyard-dapper-base`.

For example:

```Dockerfile
FROM quay.io/submariner/shipyard-dapper-base

ENV DAPPER_ENV="REPO TAG QUAY_USERNAME QUAY_PASSWORD TRAVIS_COMMIT" \
    DAPPER_SOURCE=<your source directory> DAPPER_DOCKER_SOCKET=true
ENV DAPPER_OUTPUT=${DAPPER_SOURCE}/output

WORKDIR ${DAPPER_SOURCE}

ENTRYPOINT ["./scripts/entry"]
CMD ["ci"]
```

You can also refer to the project's own [Dockerfile.dapper](https://github.com/submariner-io/shipyard/blob/master/Dockerfile.dapper) as an example.

#### Building The Base Image

To build the base container image used in the shared developer and CI enviroment, simply run:

```
make dapper-image
```


### Makefile

The Makefile should include targets to run everything in Dapper, they're defined in [Makefile.dapper](https://github.com/submariner-io/shipyard/blob/master/Makefile.dapper) and can be copied as is and included.
To use Shipyard's target simply include the [Makefile.inc](https://github.com/submariner-io/shipyard/blob/master/Makefile.inc) file in your own Makefile.

The simplest Makefile would look like this:

```Makefile
ifneq (,$(DAPPER_HOST_ARCH))

# Running in Dapper

include $(SHIPYARD_DIR)/Makefile.inc

else

# Not running in Dapper

include Makefile.dapper

endif

# Disable rebuilding Makefile
Makefile Makefile.dapper Makefile.inc: ;
```

You can also refer to the project's own [Makefile](https://github.com/submariner-io/shipyard/blob/master/Makefile) as an example.

