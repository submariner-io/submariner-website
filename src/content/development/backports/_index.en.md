---
title: "Backports"
date: 2021-06-21T16:03:26+02:00
weight: 5
---

Fixes for serious issues or regressions affecting previous releases may be backported to the corresponding branches,
to be included in the next release from that branch.

## Requesting a backport

Backports can only be requested on fixes made against a later branch, or the `devel` branch.
(This doesn’t mean that bugs can’t be fixed in older branches directly; but where relevant, they should first be fixed on `devel`.)

To request such a backport, identify the relevant pull request, and add the “backport” label to it.
You should also add a comment to the pull request explaining why the backport is necessary, and which branch(es) are targeted.
Issues should _not_ be labeled, they are liable to be overlooked or lack a one-to-one mapping to a code fix.

## Handling backports

Pending backports can be identified using
[this query, listing all non-archived pull requests with a “backport” label and without a “backport-handled” label](https://github.com/pulls?q=is%3Apr+archived%3Afalse+user%3Asubmariner-io+label%3Abackport+-label%3Abackport-handled).

Backports should only be handled once the reference pull request is merged.
This ensures that commit identifiers will remain stable during the backport process and for later history.

### Standalone pull requests

Backporting a pull request (PR) is automated by running:

`make LOCAL_BUILD=1 backport release=<release-branch> pr=<PR to cherry-pick>`

Since you are running with `LOCAL_BUILD=1`, ensure that [Shipyard's repo](https://github.com/submariner-io/shipyard) is
checked out and updated alongside the project (`../<project dir where running make backport>`).
The `make` target runs a script,
[backport.sh](https://github.com/submariner-io/shipyard/blob/devel/scripts/shared/backport.sh), originally developed by the [Kubernetes community](https://github.com/kubernetes/kubernetes/blob/master/hack/cherry_pick_pull.sh).

The script does the following:

1. Cherry-picks the commits from the PR onto `<remote branch>`.
2. Creates a PR on `<release-branch>` with the title `Automated backport of <original PR number>: <original PR title>`.
3. Adds the `backport-handled` label to the original PR and the `automated-backport` label to the backported PR.

The `DRY_RUN` environment variable can be set to skip creating the PR. When set, it leaves you in a branch containing the commits that were cherry-picked.

Multiple PRs can be backported together by passing a comma-separated list of PR numbers, eg `pr=630,631`.  

The script uses the following environment variables. Please change them according to your setup.

* `UPSTREAM_REMOTE`: the remote for the upstream repository. Defaults to `origin`.
* `FORK_REMOTE`: the remote for your forked repository. Defaults to `GITHUB_USER`.
* `GITHUB_USER`: needs to be set to your GitHub username.

### Pull requests requiring dependent backports

<!-- TODO skitt document dependent backports -->

## Reviewing backports

Backports need to go through the same review process as usual.
The author of the original pull request should be added as a reviewer.

Change requests on a backport should only concern changes arising from the specifics of backporting to the target release branch.
Any other change which is deemed useful as a result of the review probably also applies to the original pull request and should result in
an entirely new pull request, which might not be a backport candidate.
