---
title: "Image Related Targets"
date: 2020-05-05T09:11:00+0300
weight: 30
---

## Image Capabilities

Shipyard ships [Makefile.images] which contains pre-packaged image capabilities that can be used to build and consume the image(s) that
a project requires:

* **[images](#images):** Builds the images the project provides.
* **[preload-images](#pre-load-images)**: Pre-loads images into a local registry.
* **[reload-images](#reload-images)**: Reloads images into a local registry, and updates local deployment.
* **[multiarch-images](#multi-arch-images):** Builds the images the project provides for all platforms declared by the project.
* **[release-images](#release-images):** Uploads the requested image(s) to Quay.io.

{{% notice info %}}
Any consuming project **has to** define the following variables **in order for image targets to work**.

* **`IMAGES`**: A space separated list of images the project provides.
* **`MULTIARCH_IMAGES`**: A space separated list of multi-arch images the project provides.
{{% /notice %}}

### Global Variables

These variables affect most or all of the targets mentioned below.

* **`REPO`**: The repo prefix to use for images (defaults to `quay.io/submariner`).

### Images

Builds the images that the project provides, for the currently detected platform.
These images can then be used when deploying a local environment.

The target is automatically consumed by other Shipyard targets, so there's no need to explicitly specify it.
Use this target when you want to purposefully rebuild a project's images.

```shell
make images
```

### Pre-load Images

Pre-loads all images (as defined by `IMAGES`) to a local registry, in case the `PROVIDER` is `kind` (default behavior).
The target will rebuild all images first, to make sure they're up-to-date.

The target is automatically consumed by other Shipyard targets, so there's no need to explicitly specify it.

```shell
make preload-images
```

### Reload Images

Reloads all images (as defined by `IMAGES`) to a local registry.
The target will rebuild all images first, to make sure they're up-to-date.

Use this target when testing with a local deployment, and you wish to use updated images without re-deploying.

```shell
make reload-images
```

#### Respected Variables for Reload

* **`RESTART`**: Specify which Submariner component to restart:
  * **`none`**: Don't restart anything (default behavior).
  * **`all`**: Restart all Submariner related components.
  * **`<component name`>**: Restart just the given component (e.g. `gateway`).

### Multi-arch Images

Builds the images that the project provides for all platforms declared by the project.
These images are packaged for release, and can't be used when deploying a local environment.

```shell
make multiarch-images
```

Any project wishing to package such images should set the following variable in it's `Makefile`:

* **`PLATFORMS`**: Comma separated list of platforms the image should be built for.

### Release Images

Uploads the images built by the project to Quay.io:

```shell
make release-images
```

#### Respected Variables for Release

* **`QUAY_USERNAME`, `QUAY_PASSWORD`**: Needed in order to log in to Quay.
* **`TAG`**: A tag to use for the release (default is the branch name).

[Makefile.images]: https://github.com/submariner-io/shipyard/blob/devel/Makefile.images
