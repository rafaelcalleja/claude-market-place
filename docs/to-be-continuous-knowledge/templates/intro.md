---
author: Pierre Smeyers
description: to-be-continuous is a set of GitLab CI templates developed and maintained by DevOps and technology experts to build state-of-the-art CI/CD pipelines in minutes.
---

# To Be Continuous

_to be continuous_ proposes a set of GitLab CI templates developed and maintained by DevOps and technology experts to build state-of-the-art CI/CD pipelines in minutes.

## Key features

| Feature             | Description |
| ------------------- | ----------- |
| Easy                | No need to master GitLab CI: follow the guide and include the templates you need. |
| Modular             | Build your project pipeline by assembling every required template. |
| Security            | Ease the use of security & quality tools (code quality, SAST, dependency check, license management, DAST, ...). |
| Git Workflows       | Our templates support modern DevOps workflows ([Feature Branch](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow), [Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow), ...). |
| Up-To-Date          | We carefully follow every GitLab CE release to integrate every new [feature](https://about.gitlab.com/features/) to our templates. |
| Configurable & Extensible | Comply to the convention over configuration principle. <br> Work with minimal configuration, yet can be configured to fit specific needs. |
| Review Environments | Dynamically created environments in your cloud, hosting your development in progress. <br>It is a strict equivalent of GitLab's [Review Apps](https://docs.gitlab.com/ci/review_apps/) feature. |
| Documented          | All our templates have an extensive online documentation. |
| Examples            | We also provide a wide variety of project samples to illustrate their use and best practices. |

## Implemented GitLab features

| Feature             | Description |
| ------------------- | ----------- |
| [cache](https://docs.gitlab.com/ci/caching/) | Every template carefully implements optimized cache policy to speedup your pipeline execution. |
| [artifacts](https://docs.gitlab.com/ci/yaml/artifacts_reports/) | Every template implements optimized artifacts policy to keep only the bare necessities. |
| [interruptible](https://docs.gitlab.com/ci/yaml/#interruptible) | Every interruptible job implements the `interruptible` feature to allow cancelling the pipeline as soon as a newer one is triggered. |
| [code coverage](https://docs.gitlab.com/ci/testing/code_coverage/) | Every build&test job enforces code coverage computing (using the required build tools and options), and integration to GitLab (visible in merge requests and as a [badge](https://docs.gitlab.com/ci/testing/code_coverage/#pipeline-badges)). |
| [JUnit test reports](https://docs.gitlab.com/ci/testing/unit_test_reports/) | Every test job produces - whenever possible - a JUnit report, so that your test reports are automatically integrated to your pipelines and merge requests. |
| [code quality](https://docs.gitlab.com/ci/testing/code_quality/) | Every code quality job produces - whenever possible - a Code Climate report, so that your code quality reports are automatically integrated to your pipelines and merge requests. |
| [environments](https://docs.gitlab.com/ci/environments/) | Every deployment job declares the deployed environment to GitLab. They also implement a cleanup job for ephemeral environments, that can be triggered manually and also automatically on branch deletion. |
| [resource_group](https://docs.gitlab.com/ci/yaml/#resource_group) | Every deployment job implements the `resource_group` feature to prevent concurrent jobs deploying at the same time on the same environment. |
| [container_scanning](https://docs.gitlab.com/ci/yaml/artifacts_reports/#artifactsreportscontainer_scanning) | Every job creating a Docker Container Image reports the identified vulnerabilities to enhance security. |
| [SBOM](https://docs.gitlab.com/ci/yaml/artifacts_reports/#artifactsreportscyclonedx) | Every build template reports the Software Bill of Materials describing the components of the project. |

## How does it work?

Any _to be continuous_ template may be [included](https://docs.gitlab.com/ci/yaml/#include) in your `.gitlab-ci.yml` file using one of the 3 techniques:

* [`include:component`](https://docs.gitlab.com/ci/yaml/#includecomponent) to use it as a [CI/CD component](https://docs.gitlab.com/ci/components/):
    ```yaml
    include:
      # <gitlab-host>/to-be-continuous/<project>/<template>@<version>
      - component: $CI_SERVER_FQDN/to-be-continuous/maven/gitlab-ci-maven@3.9.0
    ```
* [`include:project`](https://docs.gitlab.com/ci/yaml/#includeproject) to use it as a regular template:
    ```yaml
    include:
      - project: 'to-be-continuous/maven' # this is the template project
        file: '/templates/gitlab-ci-maven.yml' # template file within the project
        ref: '3.9.0' # template version
    ```
* or [`include:remote`](https://docs.gitlab.com/ci/yaml/#includeremote):
    ```yaml
    include:
      - remote: "https://gitlab.com/to-be-continuous/maven/-/raw/3.9.0/templates/gitlab-ci-maven.yml"
    ```
    :information_source: _this technique might only be of interest if you want to test _to be continuous_ from your Self-Managed GitLab without installing it locally_
