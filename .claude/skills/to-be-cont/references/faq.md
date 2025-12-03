---
author: Pierre Smeyers
description: This page awsers frequenty asked questions about to-be-continuous.
---

# Frequently Asked Questions

## What is the license?

_to be continuous_ is an Open Source project licensed under the [GNU Lesser General Public License](https://www.gnu.org/licenses/lgpl-3.0.html),
version 3.0.

You can **use it for commercial purposes**, you can **(re)distribute it**, you can **modify it** under certain conditions.
More info available on [choosealicense.com](https://choosealicense.com/licenses/gpl-3.0/).

## Who develops _to be continuous_?

This has been an internal project at [Orange](https://orange.com) for 2 years before becoming an Open Source project.

The project is still mainly developed and maintained by Orange developers, but anyone is welcome to [contribute](dev/workflow.md).

## Can I use _to be continuous_ on my self-managed GitLab?

(a.k.a. _"on-premise" GitLab_)

Yes.

We have an extensive documentation about [how to use _to be continuous_ in your own self-managed GitLab](self-managed/basic.md).

## How does to-be-continuous compares to GitLab Auto DevOps?

The _to-be-continuous_ (TBC) may appear to be competing and overlapping with the features provided by [GitLab Auto DevOps templates](https://docs.gitlab.com/topics/autodevops/). Here are some notable differences between the two:

* The TBC templates are designed to be **modular** and **composable**, which makes it easy to support a polyglot IT ecosystem (in large organizations for e.g.). Whereas Auto DevOps is more rigid with limited out-of-the-box support for tools and technologies.
* The TBC is **self-contained** and can be **evolved independently** from the GitLab platform itself. Auto DevOps has tightly-coupled dependencies on the GitLab platform upgrades.
* Each TBC template is maintained as an individual GitLab project, allowing separate (semantic) **versioning** and GitLab releases. This also allows using tools like [Renovate](https://docs.renovatebot.com/) to automate dependency management, which can be a painful process across large number of client projects. Auto DevOps templates are all developed in a single project, and are not designed to be versioned (can potentially break working functionalities in production).
* TBC supports (and encourages) production-grade [Git branching models](understand.mdit-branching-models) in alignment with the industry best practices of continuous delivery and continuous deployment, while still supporting the ubiquitous Gitflow for those who are not yet mature enough to move to these best practices. TBC takes balanced approach of being opinionated and flexible where it matters, whereas Auto DevOps - much more rigid - can hardly be twisted to fit specific needs. 
* The TBC [adaptive pipelines](understand.mddaptive-pipeline) addresses the developer experience for different stages of the development lifecycle. The Auto DevOps takes a single dimensional approach using the branch-pipeline and main pipeline. As a result the Auto DevOps pipelines take longer to run (whichever the development stage) resulting into poor developer experience. Tweaking Auto DevOps to support [Merge Request pipeline](https://docs.gitlab.com/ci/pipelines/merge_request_pipelines/) is far from easy.
* The TBC is **thoroughly documented**: basic notions and philosophy, general usage principles, setup and maintenance for self-managed GitLab, reference documentation for individual templates... GitLab Auto DevOps documentation - limited to the setup instructions - dramatically lacks conceptual information and individual templates documentation.
* The TBC templates have **configurable** inputs with sensible defaults, which covers most customization needs without having to override the YAML file (advanced usage).
* While TBC is addressing both CI & CD, GitLab Auto DevOps is clearly more focussed on the CD part (building a container and deploying it). This is obvious with Maven for instance, where TBC implements many production grade features such as code-coverage integration, SonarQube integration, release plugin, snapshot dependency-check, dependency management, etc... while the Auto DevOps Maven template provides basic build and test with hardcoded Maven version. This is true with almost any build template, but also deployment templates, where TBC systematically integrates leading linters, security checkers and SAST tools having consensus in the community.

## How can I override the jobs defined by _to-be-continuous_ templates?

Please read our dedicated chapter about [overriding _to-be-continuous_ templates](usage.md#override-yaml-advanced-usage) .

## Is it possible to prevent users from overriding the included jobs configuration?

No, GitLab `include` feature is designed to allow [override](https://docs.gitlab.com/ci/yaml/includes/#override-included-configuration-values) of the included job configuration for flexibility.

Depending on your GitLab Edition, you may consider using GitLab [compliance frameworks](https://docs.gitlab.com/user/group/compliance_frameworks/) and/or [Scan Execution Policies](https://docs.gitlab.com/user/application_security/policies/scan-execution-policies.html) that allow group admin to mandate certain job executions in the pipeline, but it CAN NOT prevent developers from doing any particular thing.  

## Is there any vulnerability scanner to run against the GitLab/_to-be-continuous_ templates?

The GitLab pipeline code is written in YAML - general-purpose markup language - which allows to mix shell scripts, configuration, etc. No tool exists to do vulnerability scans against the YAML GitLab pipeline configuration. Please refer our [Security](https://to-be-continuous.gitlab.io/doc/secu) page for vulnerability scanning of the default images used by the _to-be-continuous_

## The `gitlab-sync` is failing to copy TBC to my own GitLab server

* if you're having authorization errors from the API: have you checked that the [group access token](https://docs.gitlab.com/user/group/settings/group_access_tokens/) you've generated for the destination API was created from the right root group (`to-be-continuous` by default), with sufficient scopes `api,read_registry,write_registry,read_repository,write_repository` and with `Owner` role?
* if you're having Git errors: make sure all the _Pre-defined push rules_ in the root group are disabled (`Settings > Repository > Pre-defined push rules`).

## What is the tracking image for? As a gitlab.com user, am I being spied on?

Short answer: no you can relax, your usage is not tracked.

The tracking image is a general mechanism supported by _to-be-continuous_ to allow companies to track TBC usage **on their self-managed GitLab instances**.
It is fully disabled by default, and may be enabled on self-managed instances, for instance to measure CI/CD and DevOps good practices adoption.

[More information in our documentation](./self-managed/advanced.md#setup-tracking).
