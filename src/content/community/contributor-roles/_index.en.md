---
title: "Contributor Roles"
date: 2020-02-19T21:43:46+01:00
weight: 20
---

**This is a stripped-down version of the [Kubernetes Community Membership
process][parent process].**

**Although we aspire to follow the Kubernetes process, some parts are not currently
relevant to our structure or possible with our tooling:**

* **The SIG and subproject abstraction layers don't apply to Submariner.
  Submariner is treated as a single project with file-based commit rights, not
  a "project" per repository.**
* **We hope to eventually move to Kubernetes OWNERS and Prow, but until we do so we
  can't support advanced role-based automation (reviewers vs approvers;
  PR workflow commands like /okay-to-test, /lgtm, /approved).**
* **Project Owners are given responsibility for some tasks that are handled by dedicated teams in Kubernetes (security responses, Code of
  Conduct violations, and managing project funds). Submariner aspires to create dedicated teams for these tasks as the community grows.**

---

This doc outlines the various responsibilities of contributor roles in
Submariner.

<!-- markdownlint-disable line-length -->
| Role | Responsibilities | Requirements | Defined by |
| ---- | ---------------- | ------------ | ---------- |
| Member | Active contributor in the community | Sponsored by 2 committers, multiple contributions to the project | [Submariner GitHub org member][org members] |
| Committer | Approve contributions from other members | History of review and authorship | CODEOWNERS file entry |
| Owner | Set direction and priorities for the project | Demonstrated responsibility and excellent technical judgement for the project | [Submariner-owners GitHub team member][owners team] and [`*`entry in all CODEOWNERS files][codeowners file] |
<!-- markdownlint-enable line-length -->

## New Contributors

New contributors should be welcomed to the community by existing members,
helped with PR workflow, and directed to relevant documentation and
communication channels.

We require every contributor to certify that they are legally permitted to contribute to our project.
A contributor expresses this by consciously signing their commits,
and by this act expressing that they comply with the [Developer Certificate Of Origin](https://developercertificate.org/).

## Established Community Members

Established community members are expected to demonstrate their adherence to
the principles in this document, familiarity with project organization, roles,
policies, procedures, conventions, etc., and technical and/or writing ability.
Role-specific expectations, responsibilities, and requirements are enumerated
below.

## Member

Members are continuously active contributors in the community. They can have
issues and PRs assigned to them and participate through GitHub teams. Members
are expected to remain active contributors to the community.

**Defined by:** Member of the [Submariner GitHub organization][org members].

### Member Requirements

* Enabled [two-factor authentication] on their GitHub account
* Have made multiple contributions to the project or community. Contribution
  may include, but is not limited to:
  * Authoring or reviewing PRs on GitHub
  * Filing or commenting on issues on GitHub
  * Contributing to community discussions (e.g. meetings, Slack, email
    discussion forums, Stack Overflow)
* Subscribed to [`submariner-dev@googlegroups.com`]
* Have read the [community] and [development] guides
* Actively contributing
* Sponsored by 2 committers. **Note the following requirements for sponsors**:
  * Sponsors must have close interactions with the prospective member - e.g.
    code/design/proposal review, coordinating on issues, etc.
  * Sponsors must be committers in at least 1 CODEOWNERS file either in any
    repo in the [Submariner org]
* [Open an issue][membership request issue] against the `submariner-io/submariner` repo
  * Ensure your sponsors are @mentioned on the issue
  * Complete every item on the checklist ([preview the current version of the member template][membership template])
  * Make sure that the list of contributions included is representative of
    your work on the project
* Have your sponsoring committers reply confirmation of sponsorship: `+1`
* Once your sponsors have responded, your request will be reviewed. Any missing
  information will be requested.

### Member Responsibilities and Privileges

* Responsive to issues and PRs assigned to them
* Responsive to mentions of teams they are members of
* Active owner of code they have contributed (unless ownership is explicitly
  transferred)
  * Code is well tested
  * Tests consistently pass
  * Addresses bugs or issues discovered after code is accepted
* They can be assigned to issues and PRs, and people can ask members for
  reviews

**Note:** Members who frequently contribute code are expected to proactively
perform code reviews and work towards becoming a committer.

Members can be removed by stepping down or by two thirds vote of Project Owners.

## Committers

Committers are able to review code for quality and correctness on some part of
the project. They are knowledgeable about both the codebase and software
engineering principles.

**Until automation supports approvers vs reviewers:** They also review for
holistic acceptance of a contribution including: backwards / forwards
compatibility, adhering to API and flag conventions, subtle performance and
correctness issues, interactions with other parts of the system, etc.

**Defined by:** Entry in an CODEOWNERS file in a repo owned by the Submariner
project.

**Committer status is scoped to a part of the codebase.**

### Committer Requirements

The following apply to the part of codebase for which one would be a committer
in an CODEOWNERS file:

* Member for at least 3 months
* Primary reviewer for at least 5 PRs to the codebase
* Reviewed at least 20 substantial PRs to the codebase
* Knowledgeable about the codebase
* Sponsored by two committers or project owners
  * With no objections from other committers or project owners
* May either self-nominate or be nominated by a committer/owner
* [Open an issue][committership request issue] against the `submariner-io/submariner` repo
  * Ensure your sponsors are @mentioned on the issue
  * Complete every item on the checklist ([preview the current version of the committer template][committership template])
  * Make sure that the list of contributions included is representative of
    your work on the project
* Have your sponsoring committers/owners reply confirmation of sponsorship: `+1`
* Once your sponsors have responded, your request will be reviewed. Any missing
  information will be requested.

### Committer Responsibilities and Privileges

The following apply to the part of codebase for which one would be a committer
in a CODEOWNERS file:

* Responsible for project quality control via [code reviews]
  * Focus on code quality and correctness, including testing and factoring
  * **Until automation supports approvers vs reviewers:** Focus on holistic
    acceptance of contribution such as dependencies with other features,
    backwards / forwards compatibility, API and flag definitions, etc
* Expected to be responsive to review requests as per [community expectations]
* Assigned PRs to review related to project of expertise
* Assigned test bugs related to project of expertise
* Granted "read access" to the corresponding repository
* May get a badge on PR and issue comments
* Demonstrate sound technical judgement
* Mentor contributors and reviewers

Committers can be removed by stepping down or by two thirds vote of Project Owners.

## Project Owner

Project owners are the technical authority for the Submariner project. They
*MUST* have demonstrated both good judgement and responsibility towards the
health the project. Project owners *MUST* set technical direction and make or
approve design decisions for the project - either directly or through
delegation of these responsibilities.

**Defined by:** Member of the [`submariner-owners` GitHub team][owners team] and [`*` entry in all CODEOWNERS files][codeowners file].

### Owner Requirements

Unlike the roles outlined above, the owners of the project are typically
limited to a relatively small group of decision makers and updated as fits the
needs of the project.

The following apply to people who would be an owner:

* Deep understanding of the technical goals and direction of the project
* Deep understanding of the technical domain of the project
* Sustained contributions to design and direction by doing all of:
  * Authoring and reviewing proposals
  * Initiating, contributing and resolving discussions (emails, GitHub issues,
    meetings)
  * Identifying subtle or complex issues in designs and implementation PRs
* Directly contributed to the project through implementation and / or review

### Owner Removal and Future Elected Governance

Removal of Project Owners is currently frozen except for stepping down or violations of the Code of Conduct. This is a temporary governance
step to define a removal process for extreme cases while protecting the project from dominance by a company. Once the Submariner community
is diverse enough to replace Project Owners with an elected governance system, the project should do so. If the project hasn't replaced
Project Owners with elected governance by June 1st 2023, and if there are committers from at least three different companies, the project
defaults to replacing Project Owners with a Technical Steering Committee elected by [OpenDaylight's TSC Election
System](https://wiki.opendaylight.org/display/ODL/TSC+Election+Process) with a single Committer at Large Represented Group (defined below)
and a 49% company cap.

```text
Min Seats: 5
Max Seats: 5
Voters: Submariner Committers
Duplicate Voter Strategy: Vote-per-Person
```

### Owner Responsibilities and Privileges

The following apply to people who would be an owner:

* Make and approve technical design decisions for the project
* Set technical direction and priorities for the project
* Define milestones and releases
* Mentor and guide committers and contributors to the project
* Ensure continued health of project
  * Adequate test coverage to confidently release
  * Tests are passing reliably (i.e. not flaky) and are fixed when they fail
* Ensure a healthy process for discussion and decision making is in place
* Work with other project owners to maintain the project's overall health and
  success holistically
* Receive security disclosures and ensure an adequate response.
* Receive reports of Code of Conduct violations and ensure an adequate response.
* Decide how funds raised by the project are spent.

[parent process]: https://github.com/kubernetes/community/blob/7d2ebad43cde06607cde3d55e9eed4bb08a286a9/community-membership.md
[code reviews]: ../../development/code-review
[community expectations]: https://github.com/kubernetes/community/blob/7d2ebad43cde06607cde3d55e9eed4bb08a286a9/contributors/guide/expectations.md
[development]: ../../development
[community]: ..
[Submariner org]: https://github.com/submariner-io
[`submariner-dev@googlegroups.com`]: https://groups.google.com/forum/#!forum/submariner-dev
[membership request issue]: https://github.com/submariner-io/submariner/issues/new?template=membership.md&title=REQUEST%3A%20New%20membership%20request%20for%20%3Cyour-GH-handle%3E
[membership template]: https://github.com/submariner-io/submariner/blob/devel/.github/ISSUE_TEMPLATE/membership.md
[committership request issue]: https://github.com/submariner-io/submariner/issues/new?template=committership.md&title=REQUEST%3A%20New%20committer%20rights%20request%20for%20%3Cyour-GH-handle%3E
[committership template]: https://github.com/submariner-io/submariner/blob/devel/.github/ISSUE_TEMPLATE/committership.md
[two-factor authentication]: https://help.github.com/articles/about-two-factor-authentication
[owners team]: https://github.com/orgs/submariner-io/teams/submariner-owners
[codeowners file]: https://github.com/submariner-io/submariner/blob/devel/CODEOWNERS.in
[org members]: https://github.com/orgs/submariner-io/people
