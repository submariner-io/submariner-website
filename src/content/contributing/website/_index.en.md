---
title: "Contributing to the website"
date: 2020-02-19T22:03:26+01:00
weight: 10
---

The Submariner documentation website is based on hugo, grav, and the
hugo-learn-theme and written in markdown format.

If you want to contribute I recommend reading the
[hugo-learn-theme documentation](https://themes.gohugo.io//theme/hugo-theme-learn/en/cont/pages/)

You can always click the "Edit this page link" at the top right of each page, but
if you want to test your changes locally before submitting you can:

1. Download and install a [recent version of hugo](https://gohugo.io/getting-started/quick-start/#step-1-install-hugo)

2. Fork the [submariner-io/website](https://github.com/submariner-io/website/fork) on github

3. Checkout your copy locally
```bash
$ git clone ssh://git@github.com/<your-user>/website.git submariner-website
$ cd submariner-website
$ ./scripts/server
```

4. Open your browser on [http://localhost:1313](http://localhost:1313)

5. Edit files in src, the browser should automatically reload changes.

6. Eventually commit, push, and pull-request your changes. You can find a good guide about the github workflow here: [contributing to a github project](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project)

