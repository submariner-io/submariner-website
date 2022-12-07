+++
title = "Roadmap"
date = 2020-02-19T20:24:34+01:00
weight = 50
+++

Submariner organizes all current and upcoming work using GitHub Issues, Projects, and Milestones.

## Planning Process

In preparation for sprint planning meetings (see [Submariner's Community Calendar][cal]), GitHub Issues should be raised for work that is to
be a part of a sprint. Issues targeted for a sprint should be added to the upcoming Project's "Backlog" column. During sprint planning
meetings, Issues will be discussed and moved to the "TODO" column and the milestone will be set to the targeted release. As contributors
make progress during sprints, Issues should be moved through the "In Progress"/"Review/Verify"/"Done" columns of the Project. If an Issue is
implemented during a release but additional work (like an ACK-fixed verification) tracked by the relevant Issue is necessary, the Issue can
be carried over to the next Project but the Milestone should reflect where the code was shipped for accurate release note creation.

## Current Work

Current and near-future work is tracked by [Submariner's open Projects][projects].

## Future Work

Some high-level goals are summarized here, but the primary source for tracking future work are Submariner's GitHub Issues.

* Network Policy across clusters (Coastguard)
* Support for finer-grained connectivity policies (<https://github.com/submariner-io/enhancements/pull/4/files>)
* Dynamic routing with BGP to support multi-path forwarding across gateways
* Testing with multi-cluster Istio
* Scale improvements

## Suggesting Work

If we are missing something that would make Submariner more useful to you, please let us know. The best way is to file an Issue and include
information on how you intend to use Submariner with that feature.

[cal]: https://calendar.google.com/calendar/r?cid=NHFuZGVoOGY0bzZ1ajlvZnBsczh1NWNlZ2tAZ3JvdXAuY2FsZW5kYXIuZ29vZ2xlLmNvbQ
[projects]: https://github.com/orgs/submariner-io/projects?type=classic
