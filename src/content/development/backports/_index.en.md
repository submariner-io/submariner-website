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

Update your local clone of the relevant repository, and identify the commit(s) which need to be backported
(all the commits listed in the pull request, as merged).
If multiple commits are involved, it is expected that they will be consecutive (since they were part of the same pull request).

Check out a new backport branch based on the _target_ branch;
for example, to backport PR 1431 in the operator to the 0.9 release branch:

```sh
git checkout -b backport-1431-0.9 origin/release-0.9
```

Then, cherry pick the commits:

```sh
git cherry-pick -x 0448fcd60972da03c84c345c24c2cf1c34b6b42b
```

The `-x` option ensures that the commit is referenced in the resulting commit message.

If necessary, resolve any conflicts which occur, and conclude with

```sh
git cherry-pick --continue
```

Push the resulting branch and open a new pull request; add “Backport: ” to the pull request description to identify it as a backport.
(Do not use the “backport” label here; that doesn’t identify backports, it identifies requested backports.)
On the original pull request, add a comment referencing the new pull request and identifying it as a backport to the relevant release.

Once _all_ the requested backports of the original pull request have been handled, add the “backport-handled” label.
This will result in the pull request disappearing from the list of pending backports.

### Pull requests requiring dependent backports

<!-- TODO skitt document dependent backports -->

## Reviewing backports

Backports need to go through the same review process as usual.
The author of the original pull request should be added as a reviewer.

Change requests on a backport should only concern changes arising from the specifics of backporting to the target release branch.
Any other change which is deemed useful as a result of the review probably also applies to the original pull request and should result in
an entirely new pull request, which might not be a backport candidate.
