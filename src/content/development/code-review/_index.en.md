---
title: "Code Review Guide"
date: 2020-05-06T08:19:26+02:00
weight: 20
---

## Code Review Guide

This guide is meant to facilitate Submariner code review by sharing norms, best practices, and useful patterns.

Submariner follows the [Kubernetes Code Review Guide][kube code review guide] wherever relevant. This guide collects the most important
highlights of the Kubernetes process and adds Submariner-specific extensions.

### Two non-author approvals required

Pull Requests to Submariner require two approvals, including at least one from a Committer to the relevant part of the code base,
as defined by the CODEOWNERS file at the root of each repository and the [Community
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

### Request new reviews after substantial changes

If a PR is substantially changed after a code review, the author should request new reviews from all existing reviewers, including
approvals, using the double-arrow icons in the list of reviewers. This will notify the reviewer and add the PR to their list of
requested reviews.

With the current GitHub configuration, reviews are not automatically dismissed when PRs are updated. This is to cause less drag for the
typical cases, like minor merge conflicts. As Submariner grows, it might make sense to trade this low-drag solution for one where only
exactly the reviewed code can be merged.

### Address all -1s before merging

If someone requests changes ("votes -1") for a PR, a best-effort should be made to address those concerns and achieve a neutral position or
approval (0/+1 vote) before the PR is merged.

### Update branch only after required reviews

To avoid wasting resources by running unnecessary jobs, only use the **Update branch** button to add a merge commit once a PR is actually
ready to merge (has [required reviews](#two-non-author-approvals-required) and [no -1s](#address-all--1s-before-merging)). Unless
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

### Manage dependency among pull requests

If a PR (child) is dependent on another PR (parent), irrespective of the project, comment on the child PR with the parent PR's number with
`Depends on <Parent PR number>` or `depends on <Parent PR number>`. This will trigger a `PR Dependencies/Check Dependencies` workflow. The
workflow will add a `dependent` label to the child PR. The workflow will fail until the parent PR is merged and will pass once the parent
PR is merged. This will prevent merging the child PR until the parent PR is merged.

### Test new functionality

As new functionality is added, tests of that functionality should be added to automated test suites.
As far as possible, such tests should be added in the same PR that adds the feature.

### Full end-to-end testing of new pull requests

On some repositories, full E2E testing of pull requests will be done once a label `ready-to-test` has been assigned to the request.
The label will be automatically assigned once the PR reaches the necessary number of approvals.

You can assign this label manually to the PR in order to trigger the full E2E test suite.

### Document "why" in commit messages

Commit messages should document the "why" of a change. Why is this change being made? Why is this change helpful? The diff is the ultimate
documentation of the "what" of a change, and although it may need explaining, the commit message is the only opportunity to record the "why"
of a change in the git history for future developers. See this [example of good "why" in a commit
message](https://github.com/submariner-io/submariner-operator/commit/a85aaae0c223f831a9288a2dc15cb469f387209e).

### Rename and edit in separate commits

When submitting a PR that modifies the contents of a file and also renames/moves it (`git mv`),
use separate commits for the rename/move (with any required supporting changes so that the commit still builds) on the one hand,
and the modifications on the other hand.
This makes the git history and GitHub diffs more clear.

[kube code review guide]: https://github.com/kubernetes/community/blob/master/contributors/guide/contributing.md#code-review
[merge commits]: https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md#4-keep-your-branch-in-sync
[squashing]: https://github.com/kubernetes/community/blob/master/contributors/guide/github-workflow.md#squash-commits
[commit messages]: https://chris.beams.io/posts/git-commit/
