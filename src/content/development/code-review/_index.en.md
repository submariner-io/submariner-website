---
title: "Code Review Guide"
date: 2020-05-06T08:19:26+02:00
weight: 20
---

## Code Review Guide

This guide is meant to facilitate Submariner code review by sharing norms, best practices, and useful patterns.

Submariner follows the [Kubernetes Code Review Guide][kube code review guide] wherever relevant. This guide collects the most important
highlights of the Kubernetes process and adds Submariner-specific extensions.

### Two non-author Committer approvals required

Pull Requests to Submariner require two approvals from a Committer to the relevant part of the code base, as defined by the CODEOWNERS file
at the root of each repository and the [Community
Membership/Committers](../../community/contributor-roles/#committers) process.

### No merge commits

Kubernetes recommends [avoiding merge commits][merge commits].

With our current GitHub setup, pull requests are liable to include merge commits temporarily. Whenever a PR is updated through the UI,
GitHub merges the target branch into the PR. However, since we merge PRs by either squashing or rebasing them, those merge commits
disappear from the series of commits which ultimately ends up in the target branch.

### Squash/amend commits into discrete steps

Kubernetes recommends [squashing commits using these guidelines][squashing].

After a review, prepare your PR for merging by squashing your commits.

All commits left on your branch after a review should represent meaningful milestones or units of work. Use commits to add clarity to the
development and review process. Keep in mind that smaller commits are easier to review.

Before merging a PR, squash the following kinds of commits:

* Fixes/review feedback
* Typos
* Merges and rebases
* Work in progress
* Aim to have every commit in a PR compile and pass tests independently if you can, but it's not a requirement.

### Address code review feedback with new commits

When addressing review comments, as a general rule, push a new commit instead of amending to the prior commit as the former makes it easy
for reviewers to determine what changed.

To avoid cluttering the git log, squash the review commits into the appropriate commit before merging. The committer can do this in GitHub
via the "Squash and merge" option. However you may want to preserve other commits, in which case squashing will need to be done manually via
the Git CLI. To make that simpler, you can commit the review-prompted changes with `git commit --fixup` with the appropriate commit hash.
This will keep them as separate commits, and if you later rebase with the `--autosquash` option (that is `git rebase --autosquash -i`) they
will automatically be selected for squashing.

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

GitLint will automatically be run against all commits to try to validate these conventions.

### Dismiss reviews after substantial changes

If a PR is substantially changed after a code review, the author should dismiss the stale reviews.

With the current GitHub configuration, reviews are not automatically dismissed when PRs are updated. This is to cause less drag for the
typical cases, like minor merge conflicts. As Submariner grows, it might make sense to trade this low-drag solution for one where only
exactly the reviewed code can be merged.

### Address all -1s before merging

If someone requests changes ("votes -1") for a PR, a best-effort should be made to address those concerns and achieve a neutral position or
approval (0/+1 vote) before the PR is merged.

### Update branch only after required reviews

To avoid wasting resources by running unnecessary jobs, only use the **Update branch** button to add a merge commit once a PR is actually
ready to merge (has [required reviews](#two-non-author-committer-approvals-required) and [no -1s](#address-all--1s-before-merging)). Unless
other relevant code has changed, the new job results don't tell us anything new. Since changes are constantly being merged, it's likely
another merge commit and set of jobs will be necessary right before merging anyway.

### Mark work-in-progress PRs as drafts

To clearly indicate a PR is still under development and not yet ready for review, mark it as a draft. It is not necessary to modify PR
summaries or commit messages (e.g. "WIP", "DO NOT MERGE"). Keeping the same PR summary keeps email notifications threaded, and using the
commit message you plan to merge will allow gitlint to verify it. PRs should typically be marked as drafts if any CI is failing that the
author can fix before asking for code review.

Please do this when opening the PR: instead of clicking on the “Create pull request” button, click on the drop-down arrow next to it, and
select “Create draft pull request”. This will avoid notifying code owners; they will be notified when the PR is marked as ready for review.

### Use private forks for debugging PRs by running CI

If a PR is not expected to pass CI but the author wants to see the results to enable development, use a personal fork to run CI. This avoids
clogging the GitHub Actions job queue of the Submariner-io GitHub Organization. After the same `git push` to your personal fork you'd
typically do for a PR, simply choose your fork as the "base repository" of the PR in GitHub's "Open a pull request" UI. Make sure your
fork's main branch is up-to-date. After creating the PR, CI will trigger as usual but the jobs will count towards your personal queue. You
will need to open a new PR against the main repository once your proposed change is ready for review.

[kube code review guide]: https://github.com/kubernetes/community/blob/master/contributors/guide/contributing.md#code-review
[merge commits]: https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md#4-keep-your-branch-in-sync
[squashing]: https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md#squash-commits
[commit messages]: https://chris.beams.io/posts/git-commit/
