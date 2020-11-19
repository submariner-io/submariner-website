---
title: "Contributing to the Website"
date: 2020-02-19T22:03:26+01:00
weight: 60
---

The Submariner documentation website is based on Hugo, Grav,
[Hugo-theme-learn](https://themes.gohugo.io/theme/hugo-theme-learn/en/cont/pages/), and is written in
[Markdown](https://www.markdownguide.org/getting-started/) format.

You can always click the **Edit this page** link at the top right of each page, but if you want to test your changes locally before
submitting you can:

1. Fork the [submariner-io/submariner-website](https://github.com/submariner-io/submariner-website/fork) on GitHub.
2. Check out your copy locally:

    ```bash
    git clone ssh://git@github.com/<your-user>/submariner-website.git
    cd submariner-website
    make server
    ```

3. An instance of the website is now running locally on your machine and is accessible at <http://localhost:1313>.
4. Edit files in src. The browser should automatically reload so you can test your changes.
5. Eventually commit, push, and pull-request your changes. You can find a good guide about the GitHub workflow
   [here](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project).
