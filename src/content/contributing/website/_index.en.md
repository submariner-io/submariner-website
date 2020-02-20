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

1. Fork the [submariner-io/submariner-website](https://github.com/submariner-io/submariner-website/fork) on github

3. Checkout your copy locally
```bash
$ git clone ssh://git@github.com/<your-user>/submariner-website.git
$ cd submariner-website
$ make server
```

4. Open your browser on [http://localhost:1313](http://localhost:1313)

5. Edit files in src, the browser should automatically reload changes.

6. Eventually commit, push, and pull-request your changes. You can find a good guide about the github workflow here: [contributing to a github project](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project)

