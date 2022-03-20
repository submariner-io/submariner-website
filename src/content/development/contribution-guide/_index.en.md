---
title: "Contributing to the Project"
date: 2022-03-15T10:31:00+02:00
weight: 30
---

This guide outlines the process which developers need to follow when contributing to the Submariner project.
Developers are expected to read and follow the guidelines outlined in this guide and in the other contribution guides,
in order for their contributions to the project to be addressed in a timely manner.

## Project Resources

To be expanded

### Backlog Board

To be expanded

### Current Release Board

To be expanded

### Enhancements Repository

To be expanded

### Releases Repository

To be expanded

## Bugs, Tasks and Epics

To be expanded

### Bugs

To be expanded

### Tasks

To be expanded

### Epics

To be expanded

## Release Cycles

The Submariner project follows time based release cycles where each cycle is 16 weeks long.
While blocking bugs may delay the [general availability](#general-availability) release date, new features will not.

Features that were partially implemented in a given release will be considered "experimental" and won't have any support commitment.

Each cycle will result in either a minor version bump or a major version bump in case backwards compatibility can't be maintained.

### Sprints

Sprints are 3 week periods which encapsulate work on the release.
Most sprints focus on active development of the current version, while some focus on additional aspects such as design and stabilization.
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
* Have a `next-version-candidate` label.
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
  * Remove the `next-version-candidate` label from transferred epics.
* Re-evaluate the priorities of any *Small* and *Medium* tasks in the backlog.
* Optionally assign important bugs and tasks and move them to the release board.

By the end of the planning week, the project team will have a backlog of epics and tasks and can commence working on the design phase.
All epics for the next version will be on the release board, while all *Small* and *Medium* tasks will be left on the backlog board and
worked on based on their priority.

#### Feature Design

Project members are expected to work on the design for any [epic](#epics) features assigned to them.
During this sprint, project members will update their respective epics with any work identified during the design phase.
Project members are encouraged to perform proof of concept investigations in order to validate the design and clarify specific work items.

In case additional work items are identified during the design, they should be opened as [tasks](#tasks) and tracked under the respective epic.
Such tasks are expected to follow the sizing guidelines from the [Planning](#planning) stage.
Specifically, tasks that are themselves epics due to their size should be identified and treated as such.

Design proposals for epics should be submitted as [pull requests to the enhancements repository], detailing the proposed design, any
alternatives, and any changes necessary to the Submariner projects and APIs.

The [pull requests to the enhancements repository] will be reviewed during the sprint, discussing any necessary changes or reservations.
Any pull request will need approval from at least 50% of the [code owners of the enhancements repository].
The code owners list is an aggregate list of the code owners of all Sumbariner repositories.
As soon as the pull request is reviewed and merged, work on the epic can begin.

Project members are expected to review proposals from other members in addition to drafting their own proposals.
If a project member has finished work on their proposal, they're encouraged to help with the other ongoing proposals.

Only epics which were planned for the release will be reviewed at this stage.
Any epic that was unplanned but seeks inclusion in the release should follow the [exception process](#exception-process).
The same process will have to be followed for any epic that was planned but has not been agreed upon by the end of this sprint.
Any such epics will be moved back to the [Backlog board](#backlog-board) and reconsidered for the next release.

In lieu of demos, the project will host a design review at the end of the sprint.
All the approved epics and their designs will be presented.

#### Development Milestones

The milestone sprints are focused on development work for various [tasks](#tasks) and [bugs](#bugs).
Project members will work on any planned tasks and bugs, and will also work on unplanned bugs should they arise.
Any [unplanned work](#unplanned-work) should follow the defined guidelines.

Each sprint will end with a release to allow the community to test new features and fixed bugs.
In total, three milestone sprints are planned:

* Two milestones ending with releases of milestone `m1` and milestone `m2`.
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

To be expanded

### Unplanned Work

To be expanded

#### Ongoing Maintenance

To be expanded

#### Exception Process

To be expanded

### Test Days

To be expanded

[Backlog board]: #backlog-board
[code owners of the enhancements repository]: https://github.com/submariner-io/enhancements/blob/devel/CODEOWNERS
[enhancements]: https://github.com/submariner-io/enhancements/issues
[epic template]: https://github.com/submariner-io/enhancements/blob/devel/.github/ISSUE_TEMPLATE/epic.md
[pull requests to the enhancements repository]: https://github.com/submariner-io/enhancements/pulls
[release process]: ../release-process
