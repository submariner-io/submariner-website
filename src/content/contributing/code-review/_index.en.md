---
title: "Code Review Guide"
date: 2020-05-06T08:19:26+02:00
weight: 30
---

## Code Review Guide

This guide is meant to facilitate Submariner code review by sharing norms, best
practices, and useful patterns.

Submariner follows the [Kubernetes Code Review Guide][kube code review guide]
wherever relevant. This guide collects the most important highlights of the
K8s process and adds Submariner-specific extensions.

### Two non-author approvals required

Pull Requests to Submariner require two non-author code review approvals.

At least one approval must be from a Committer to the relevant part of the code
base, as defined by the CODEOWNERS file at the root of the repository.

### No merge commits

Kubernetes recommends [avoiding merge commits][merge commits].

Use `git fetch` and `git rebase` to avoid them.

### Squash/amend commits into discrete steps

Kubernetes recommends [squashing commits using these guidelines][squashing].

After a review, prepare your PR for merging by squashing your commits.

All commits left on your branch after a review should represent meaningful
milestones or units of work. Use commits to add clarity to the development and
review process.

Before merging a PR, squash the following kinds of commits:

* Fixes/review feedback
* Typos
* Merges and rebases
* Work in progress
* Aim to have every commit in a PR compile and pass tests independently if you
  can, but it's not a requirement.

### Commit message formatting

Kubernetes recommends [these commit message practices][commit messages].

In summary:

1. Separate subject from body with a blank line
2. Limit the subject line to 50 characters
3. Capitalize the subject line
4. Do not end the subject line with a period
5. Use the imperative mood in the subject line
6. Wrap the body at 72 characters
7. Use the body to explain what and why vs how

### Dismiss reviews after substantial changes

If a PR is substantially changed after a code review, the author should dismiss the stale reviews.

With the current GitHub configuration, reviews are not automatically dismissed when PRs are updated. This is to cause less drag for the
typical cases, like minor merge conflicts. As Submariner grows, it might make sense to trade this low-drag solution for one where only
exactly the reviewed code can be merged.

### Address all -1s before merging

If someone requests changes ("votes -1") for a PR, a best-effort should be made to address those concerns and achieve a neutral position or
approval (0/+1 vote) before the PR is merged.

[kube code review guide]: https://github.com/kubernetes/community/blob/master/contributors/guide/contributing.md#code-review
[merge commits]: https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md#4-keep-your-branch-in-sync
[squashing]: https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md#squash-commits
[commit messages]: https://chris.beams.io/posts/git-commit/
