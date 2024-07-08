---
title: "Contributing to the Project"
date: 2022-03-15T10:31:00+02:00
weight: 30
---

This guide outlines the process which developers need to follow when contributing to the Submariner project.
Developers are expected to read and follow the guidelines outlined in this guide and in the other contribution guides,
in order for their contributions to the project to be addressed in a timely manner.

## Project Resources

Submariner uses [GitHub Projects] to manage releases. Read [Best practices for projects] to learn more about how to work with
projects.

### Backlog Board

[The backlog board] hosts issues, bugs and features which are not a part of a particular release board. While each issue is opened in
its corresponding repository, this board gives an aggregated view of all open issues across all repositories. The board has total of three
columns. Any new issues or epics should typically be assigned to the `Backlog` column. Epics which are candidates to be included in
the next release are moved to the `Next Version Candidate` column. During [planning](#planning), all epics from the `Next
Version Candidate` column are reviewed and triaged. Epics which are selected to be in the next release are moved to
the [current release board](#current-release-board). All unassigned issues are labeled with priority based on the priority discussed in
the team meeting.
The `Close?` column holds any issues/epics that can probably be closed for
various reasons.

### Current Release Board

Current release work is tracked in [the latest board]. The board has 5 columns. The first one, `Schedule and Epics`, hosts all properly
triaged epics targeted for the current release and the schedule for the current release. Triaged issues are under the `To do` column. When
an issue is being worked on, it is moved to `In Progress` column. When a PR for the issue is pushed, the issue is moved to `In Review`
column. The PR has the corresponding issue linked from the GitHub UI and is not tracked on the board. Once the PR is merged, the issue
is moved to `Done` column.

### Enhancements Repository

The [Enhancements repository] is used for tracking [epics](#epics) as issues, and their corresponding enhancement proposals (the epics design)
as [pull requests to the enhancements repository]. Any medium or small enhancement should be opened as an issue in the relevant repository,
or as a general [Enhancement Request issue].

### Releases Repository

Submariner's release is automated to a great extent. [The release process documentation] explains the details of a release. The release
automation is maintained in the [releases repository]. It also hosts `subctl` binaries for all released versions.
Code is frozen during releases: no PRs unrelated to the release can be merged to the branch being released.

## Bugs, Tasks and Epics

In order to have more structure and clarity, we expand upon the standard GitHub issue and define 3 types of issues:
Bugs, Tasks and Epics.

### Bugs

A bug is an issue which captures an error or fault in the project.
If a bug meets the criteria of a blocker, it is considered a blocker bug.

#### Blocker Criteria

If an issue prevents a feature (either new or existing) from operating correctly and there's no sufficient workaround, it may be deemed as
a blocker for a release such that the release cannot proceed until it is addressed.

### Tasks

A task defines a specific unit of work that can be stand-alone or part of an epic. Work on a bug is not a task. A task should be relatively
small and fit within the scope of a single sprint otherwise it should be broken down into smaller tasks or perhaps be defined as an epic.
Tasks that relate to ongoing maintenance (version bumps, image trimmings, CI and automation) will usually be small, unplanned tasks that
typically occur throughout each release cycle. The associated GitHub issue / PR should be labeled as `maintenance`.

### Epics

An epic is a collection of tasks which are required to accomplish a feature.

#### Epic Guidelines

* Epics should be issues in the [enhancements] repository and created using the [epic template].
* Only include work that is a part of the [Submariner project].
* The design should be completed before starting working on an epic.
* An epic should not be added to a release after the planning is complete.
* Provide clear and agreed-upon acceptance criteria.
* An epic should be split into smaller tasks (implementation, testing, documentation etc) using the design, acceptance criteria and
epic template checklist as guidelines:
  * Open a GitHub issue for each task in the appropriate repository.
  * Each task should be listed under the Work Items section in the epic template.
  * Tasks should be small to medium in size and fit within the scope of a single sprint.

## Release Cycles

The Submariner project follows time based release cycles where each cycle is 16 weeks long.
While blocking bugs may delay the [general availability](#general-availability) release date, new features will not.

Features that were partially implemented in a given release will be considered "experimental" and won't have any support commitment.

Each cycle will result in either a minor version bump or a major version bump in case backwards compatibility can't be maintained.

### Sprints

Sprints are 3 week periods which encapsulate work on the release.
Most sprints focus on active development of the current version, while the last one focuses on stabilization.
Specific sprints and their contents are detailed in the following sections.

Most sprints will end with a milestone pre-release as detailed in the following sections.
This allows the community and project members to verify the project is stable and test any fixes or features that were added during the
sprint.
A formal [test day](#test-days) may be held to facilitate testing of the pre-release.

Each sprint ends on a boundary day which also marks the beginning of the next sprint.
The boundary days occur on a **Monday**.

On the sprint boundary day we will:

* Perform a milestone pre-release (when applicable).
* Have release related meetings, instead of any usually recurring meetings:
  * Grooming (30 minutes):
    * Making sure epics are on track.
    * Reviewing the Definition of Done for each epic.
    * Moving epics back to the Backlog, in case they're de-prioritized.
  * Retrospective (30 minutes):
    * Looking back at the task sizes and assessing if they were correct.
    * General process improvement.
  * Demos (30 minutes):
    * Any enhancements (or parts of) that have been delivered in the sprint.
    * Other interesting changes (e.g. refactors) that aren't part of any epic.
    * In case there's nothing to showcase, this meeting will be skipped.

### Release Timeline

<!-- Source: https://docs.google.com/drawings/d/1wZCogcChCkX2PqoIuTx9I_iOgJuwsYjChVopq1nfqeM -->
![Timeline Diagram](/images/timeline.png)

Each release follows a fixed timeline, with 4 development sprints and one final sprint for stabilization.
The version will be released one week after the last sprint, and the planning work for the next release will begin.

The following sections explain the activities of each sprint.

#### Planning

The week before a new release cycle starts is dedicated to planning the release.
Planning covers the [epics](#epics), [tasks](#tasks) and [bugs](#bugs) which are targeted for the next release version.
Planning meetings will be held, focusing on the [Backlog board].

##### Inclusion Criteria

In order for a task or an epic to be eligible for the next version, it needs to fulfill these requirements:

* Be part of the [Backlog board].
* Located in the `next-version-candidate` column.
* Have a description detailing **what** the issue is and optionally **how** it's going to be solved.
* Have an appropriate sizing label, according to the amount of work expected for a single person to completely deliver the task:
  * *Small*: Work is contained in one sprint and is expected to take less than half the sprint.
  * *Medium*: Work is contained in one sprint and is expected to take most of the sprint.
  * *Large*: Work is contained within a release (two-three sprints).
  * *Extra-Large*: Work can't be contained within a release and would span multiple releases.
* Any *Large* or *Extra-Large* task must be converted to an epic.
* In case of an epic, it should:
  * Have a corresponding issue in the [enhancements] project.
  * Adhere to the [epic template].
  * Have a high-level break down of the expected work, corresponding to the "Definition of Done".

##### Planning Meetings

The project team will hold planning meetings, led by the project's "scrum lead".
During these meetings, the project team will:

* Prioritize and assign epics for the next version.
  * Only epics adhering to the described requirements will be considered.
  * Transfer assigned epics to the [release board](#current-release-board) according to the capacity of the team to deliver them.
* Re-evaluate the priorities of any *Small* and *Medium* tasks in the backlog.
* Optionally assign important bugs and tasks and move them to the release board.

By the end of the planning week, the project team will have a backlog of epics and tasks and can commence working on the design phase.
All epics for the next version will be on the release board, along with *Small* and *Medium* tasks with an owner assigned.
Unassigned tasks will be left on the backlog board and
worked on based on their priority.

#### Feature Design

Project members are expected to work on the design for any [epic](#epics) features assigned to them.
Project members will update their respective epics with any work identified during the design phase.
Project members are encouraged to perform proof of concept investigations in order to validate the design and clarify specific work items.

In case additional work items are identified during the design, they should be opened as [tasks](#tasks) and tracked under the respective epic.
Such tasks are expected to follow the sizing guidelines from the [Planning](#planning) stage.
Specifically, tasks that are themselves epics due to their size should be identified and treated as such.

Design proposals for epics should be submitted as [pull requests to the enhancements repository], detailing the proposed design, any
alternatives, and any changes necessary to the Submariner projects and APIs.

The [pull requests to the enhancements repository] will be reviewed, discussing any necessary changes or reservations.
Any pull request will need approval from at least 50% of the [code owners of the enhancements repository].
The code owners list is an aggregate list of the code owners of all Sumbariner repositories.
As soon as the pull request is reviewed and merged, work on the epic can begin.

Project members are expected to review proposals from other members in addition to drafting their own proposals.
If a project member has finished work on their proposal, they're encouraged to help with the other ongoing proposals.

Project members are encouraged to host a design review for their enhancement proposal design.

#### Development Milestones

The milestone sprints are focused on development work for various [tasks](#tasks) and [bugs](#bugs).
Project members will work on any planned tasks and bugs, and will also work on unplanned bugs should they arise.
Any [unplanned work](#unplanned-work) should follow the defined guidelines.

Each sprint will end with a release to allow the community to test new features and fixed bugs.
In total, three milestone sprints are planned:

* Three sprints ending with the release of each milestone `m1`, `m2`, and `m3`.
* The last sprint ending with the release of the [release candidate](#release-candidates) `rc0`.

As detailed in the [sprints](#sprints) section, each milestone release will be followed by a test day and the sprint meetings.

#### Release Candidates

At the end of 12 weeks, the project is ready to be released and the pre-release `rc0` is created.
At this point, as detailed in the [release process] documentation, stable branches are created and the project goes into feature freeze
for the release branches.

Two [test days](#test-days) will take place after the release is created, as the project members make sure the release is ready for
[general availability](#general-availability).
Any bugs found during the test days will need to be labeled with the appropriate `testday` label.
The project members will triage the test day bugs and identify any high priority ones that should be addressed before general availability.

If any high priority bugs were identified after `rc0`, a new release `rc1` will be planned to allow for fixing them.
The `rc1` release will be planned at the team's discretion and has no expected date.
If no `rc1` release is planned, the team will proceed with the general availability release.

Starting from `rc1`, the stable branches enter a code freeze mode - only blocker bugs will be eligible for merging.
If a bug is fixed and merged during the code freeze, a new release candidate needs to be prepared and tested.
Releasing `rc2` and beyond will delay the general availability release.

#### General Availability

Once a release candidate is deemed stable and has no blocker bugs it will be released for general availability.
Prior to releasing, the release manager will verify that there were no changes on the stable branches since the last release candidate.
This ensures that no bugs could have been introduced to possibly affect the stability of the released version.

The new version will be announced per the [announcement guidelines] in the release process documentation, and
[release notes](#release-notes) for the new release will need to be published.

The [current release board](#current-release-board) will be closed, and all remaining items will be moved back to the
[backlog board](#backlog-board).
The items can then be considered for the next version, based on the [planning](#planning) guidelines.

During the week when the general availability release is performed, the next version will be planned.
Additionally, a retrospective meeting for the last release cycle will be held.
There will be no dedicated [test day](#test-days), as the release candidate has been tested and no changes have occurred since.

##### Release Notes

[Release notes] should be published for each GA version.
All new features and bug fixes of the release should be labeled with `release-note-needed` and have a corresponding release note
PR in [the website repository].

Pending release notes should be prepared as pull requests adding to the pending release notes on the appropriate branch in
[the website repository], *i.e.* `release-notes-0.16` etc. Release notes should follow the practices described in
[writing good release notes]. Each release note pull request, if it's written alongside the PR it describes, should depend on
the main PR (so that it can't be merged before the PR it documents). A PR with a release note PR should be labeled with the
`release-note-handled` label.

Once a week, as part of the tasks and bugs triage meeting, the team will make sure that new bugs / tasks / PRs are properly
labeled and have corresponding release notes. When the version is ready for GA, the pending release note branch can then be
merged to the main branch of [the website repository].

[Searching the Submariner GitHub Org with `label:release-note-needed -label:release-note-handled`] can help identify PRs that still need
release notes.

### Unplanned Work

During a release, new work that was unknown during the planning phase will emerge.
This work is typically one of three types:

* [Bugs](#bugs).
* Ongoing maintenance [tasks](#tasks).
* New [epics](#epics) or independent [tasks](#tasks).

The team [triages tasks and bugs as part of a weekly meeting].
The bugs can be worked on immediately, while other types of issues are described below.

### Test Days

Test days are held in order to validate pre-released versions by the project members and the wider community.
Any bugs opened on a test day will be triaged soon after.

The goals of these days are:

* Verify any new features that were introduced during the last [sprint](#sprints).
* Validate any [bugs](#bugs) that were closed were actually fixed.
* Find any regressions in existing functionality.

Test days will be led by one of the project members, who will be responsible for:

* Creating a test day spreadsheet, if one doesn't exist yet, using the [test day template].
  * The first sheet of the document is a template for the test days.
    * Updated with the correct infrastructure versions.
    * Add columns for planned new features.
    * Add rows to planned new infrastructure support.
* Adding a sheet for the test day with the milestone as the sheet name.
* Announcing the test day (meetings, slack, email, social media).
* Hosting the test day itself.

{{% notice note %}}
Should a bug be identified during a test day, it should be labeled with an appropriate `testday` label.
{{% /notice %}}

[announcement guidelines]: ../release-process/#step-7-announce-release
[Backlog board]: #backlog-board
[code owners of the enhancements repository]: https://github.com/submariner-io/enhancements/blob/devel/CODEOWNERS
[enhancements]: https://github.com/submariner-io/enhancements/issues
[epic template]: https://github.com/submariner-io/enhancements/blob/devel/.github/ISSUE_TEMPLATE/epic.md
[pull requests to the enhancements repository]: https://github.com/submariner-io/enhancements/pulls
[release process]: ../release-process
[test day template]: https://docs.google.com/spreadsheets/d/14wNJAbR2CC3wWdHtxnvnNlft8kSWp-SIFMWJ-hRISao
[Submariner project]: https://github.com/submariner-io
[triages tasks and bugs as part of a weekly meeting]: https://docs.google.com/document/d/1ICvOBOUpIEI45Yqcjf26Z1e5mZNzYsEN-H7_3xx54jI
[Release notes]: ../../community/releases/
[the website repository]: https://github.com/submariner-io/submariner-website/
[Searching the Submariner GitHub Org with `label:release-note-needed -label:release-note-handled`]:
https://github.com/pulls?q=user%3Asubmariner-io+label%3Arelease-note-needed+-label%3Arelease-note-handled
[GitHub Projects]: https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects
[Best practices for projects]:
https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/best-practices-for-projects
[The backlog board]: https://github.com/orgs/submariner-io/projects/29
[the latest board]: https://github.com/orgs/submariner-io/projects?query=is%3Aopen
[enhancements repository]: https://github.com/submariner-io/enhancements
[Enhancement Request issue]: https://github.com/submariner-io/enhancements/issues/new?assignees=&labels=enhancement&template=enhancement.md
[The release process documentation]: https://submariner.io/development/release-process/
[releases repository]: https://github.com/submariner-io/releases
[writing good release notes]: https://www.k8s.dev/docs/guide/release-notes/#writing-good-release-notes
