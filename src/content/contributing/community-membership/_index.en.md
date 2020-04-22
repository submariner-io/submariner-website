---
title: "Community membership"
date: 2020-02-19T21:43:46+01:00
weight: 20
---

**This is a stripped-down version of the [Kubernetes Community Membership
process][parent process].**

**Although we aspire to follow the K8s process, some parts are not currently
relevant to our structure or possible with our tooling:**

* **The SIG and subproject abstraction layers don't apply to Submariner.
  Submariner is treated as a single project with file-based commit rights, not
  a "project" per repository.**
* **We hope to eventually move to K8s OWNERS and Prow, but until we do so we
  can't support advanced role-based automation (reviewers vs approvers;
  PR workflow commands like /okay-to-test, /lgtm, /approved).**

---

This doc outlines the various responsibilities of contributor roles in
Submariner.

| Role | Responsibilities | Requirements | Defined by |
| -----| ---------------- | ------------ | -------|
| Member | Active contributor in the community | Sponsored by 2 committers, multiple contributions to the project | [Submariner GitHub org member][org members] |
| Committer | Approve contributions from other members | History of review and authorship | CODEOWNERS file entry |
| Owner | Set direction and priorities for the project | Demonstrated responsibility and excellent technical judgement for the project | [Submariner-owners GitHub team member][owners team] |

## New contributors

New contributors should be welcomed to the community by existing members,
helped with PR workflow, and directed to relevant documentation and
communication channels.

## Established community members

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

### Requirements

- Enabled [two-factor authentication] on their GitHub account
- Have made multiple contributions to the project or community. Contribution
  may include, but is not limited to:
    - Authoring or reviewing PRs on GitHub
    - Filing or commenting on issues on GitHub
    - Contributing to community discussions (e.g. meetings, Slack, email
      discussion forums, Stack Overflow)
- Subscribed to [submariner-dev@googlegroups.com]
- Have read the [contributor guide]
- Actively contributing
- Sponsored by 2 committers. **Note the following requirements for sponsors**:
    - Sponsors must have close interactions with the prospective member - e.g.
      code/design/proposal review, coordinating on issues, etc.
    - Sponsors must be committers in at least 1 CODEOWNERS file either in any
      repo in the [Submariner org]
- [Open an issue][open issue] against the submariner-io/submariner repo
   - Ensure your sponsors are @mentioned on the issue
   - Complete every item on the checklist ([preview the current version of the template][membership template])
   - Make sure that the list of contributions included is representative of
     your work on the project
- Have your sponsoring committers reply confirmation of sponsorship: `+1`
- Once your sponsors have responded, your request will be reviewed. Any missing
  information will be requested.

### Responsibilities and privileges

- Responsive to issues and PRs assigned to them
- Responsive to mentions of teams they are members of
- Active owner of code they have contributed (unless ownership is explicitly
  transferred)
  - Code is well tested
  - Tests consistently pass
  - Addresses bugs or issues discovered after code is accepted
- They can be assigned to issues and PRs, and people can ask members for
  reviews

**Note:** Members who frequently contribute code are expected to proactively
perform code reviews and work towards becoming a committer.

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

### Requirements

The following apply to the part of codebase for which one would be a committer
in an CODEOWNERS file:

- Member for at least 3 months
- Primary reviewer for at least 5 PRs to the codebase
- Reviewed at least 20 substantial PRs to the codebase
- Knowledgeable about the codebase
- Sponsored by two committers or project owners
  - With no objections from other committers or project owners
- May either self-nominate or be nominated by a committer/owner

### Responsibilities and privileges

The following apply to the part of codebase for which one would be a committer
in an CODEOWNERS file:

- Responsible for project quality control via [code reviews]
  - Focus on code quality and correctness, including testing and factoring
  - **Until automation supports approvers vs reviewers:** Focus on holistic
    acceptance of contribution such as dependencies with other features,
    backwards / forwards compatibility, API and flag definitions, etc
- Expected to be responsive to review requests as per [community expectations]
- Assigned PRs to review related to project of expertise
- Assigned test bugs related to project of expertise
- Granted "read access" to submariner repo
- May get a badge on PR and issue comments
- Demonstrate sound technical judgement
- Mentor contributors and reviewers

## Project Owner

Project owners are the technical authority for the Submariner project. They
*MUST* have demonstrated both good judgement and responsibility towards the
health the project. Project owners *MUST* set technical direction and make or
approve design decisions for the project - either directly or through
delegation of these responsibilities.

**Defined by:** Member of the [submariner-owners GitHub team][owners team].

### Requirements

Unlike the roles outlined above, the owners of the project are typically
limited to a relatively small group of decision makers and updated as fits the
needs of the project.

The following apply to people who would be an owner:

- Deep understanding of the technical goals and direction of the project
- Deep understanding of the technical domain of the project
- Sustained contributions to design and direction by doing all of:
  - Authoring and reviewing proposals
  - Initiating, contributing and resolving discussions (emails, GitHub issues,
    meetings)
  - Identifying subtle or complex issues in designs and implementation PRs
- Directly contributed to the project through implementation and / or review

### Responsibilities and privileges

The following apply to people who would be an owner:

- Make and approve technical design decisions for the project
- Set technical direction and priorities for the project
- Define milestones and releases
- Mentor and guide committers and contributors to the project
- Ensure continued health of project
  - Adequate test coverage to confidently release
  - Tests are passing reliably (i.e. not flaky) and are fixed when they fail
- Ensure a healthy process for discussion and decision making is in place
- Work with other project owners to maintain the project's overall health and
  success holistically

[parent process]: https://github.com/kubernetes/community/blob/7d2ebad43cde06607cde3d55e9eed4bb08a286a9/community-membership.md
[code reviews]: https://github.com/kubernetes/community/blob/7d2ebad43cde06607cde3d55e9eed4bb08a286a9/contributors/guide/collab.md
[community expectations]: https://github.com/kubernetes/community/blob/7d2ebad43cde06607cde3d55e9eed4bb08a286a9/contributors/guide/expectations.md
[contributor guide]: https://submariner-io.github.io/contributing/
[Submariner org]: https://github.com/submariner
[submariner-dev@googlegroups.com]: https://groups.google.com/forum/#!forum/submariner-dev
[open issue]: https://github.com/submariner-io/submariner/issues/new
[membership template]: https://git.k8s.io/org/.github/ISSUE_TEMPLATE/membership.md
[two-factor authentication]: https://help.github.com/articles/about-two-factor-authentication
[owners team]: https://github.com/orgs/submariner-io/teams/submariner-core
[org members]: https://github.com/orgs/submariner-io/people
