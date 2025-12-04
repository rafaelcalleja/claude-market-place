# Understand - to be continuous

This page introduces general notions & philosophy about _to be continuous_.

## A state-of-the art pipeline?

Generally speaking, a CI/CD pipeline should be composed of one or several of the following stages:

1. **compile** the code and **package** it into an executable or intermediate format
2. perform all required **tests** and code **analysis**:
   * Unit Testing
   * Code Quality analysis
   * Static Application Security Testing ([SAST](https://en.wikipedia.org/wiki/Static_application_security_testing))
   * Dependency Scanning and Container Scanning
   * Licenses Compliance verification
   * ...
3. **package** the compiled code into an executable format (ex: a Docker image)
4. **create** the hosting infrastructure
5. **deploy** the code into a hosting environment
6. perform all required **acceptance tests** on the deployed application
   * Functional Testing (using an automated browser or a tool to test the APIs)
   * Performance Testing
   * Dynamic Application Security Testing ([DAST](https://en.wikipedia.org/wiki/Dynamic_application_security_testing))
   * ...
7. **publish** the validated code and/or package somewhere
8. and lastly **deploy to production**

**Note**

_to be continuous_ provides predefined, configurable and extensible templates covering one or several of the above stages.

## Several kinds of template

_to be continuous_ provides 6 kinds of template, each one related to a specific part of your pipeline.

### Build & Test

Build & Test templates depend on the language/build system and are in charge of:

* building and unit testing the code,
* providing all _language specific_ code analysis tools (linters, [SAST](https://en.wikipedia.org/wiki/Static_program_analysis), dependency check, ...),
* publishing the built artifacts on a package repository.

### Code Analysis

Code Analysis templates provide code analysis tools ([SAST](https://en.wikipedia.org/wiki/Static_program_analysis), dependency check, ...) not dependent on any specific language or build tool (ex: SonarQube, Checkmarx, Coverity).

### Packaging

Packaging templates provide tools allowing to package the code into a specific executable/distributable package (ex: Docker, YUM, DEB, ...). They also provide security tools related to the packaging technology (linters, dependency checks, ...).

### Infrastructure

Infrastructure(_-as-code_) templates are in charge of managing and provisioning your infrastructure resources (network, compute, storage, ...).

### Deploy & Run

Deploy & Run templates depend on the hosting (cloud) environment and are in charge of deploying the code to the hosting environment.

### Acceptance

Acceptance templates provide acceptance test tools (functional testing, performance testing, [DAST](https://en.wikipedia.org/wiki/Dynamic_application_security_testing)).

## Generic pipeline stages

Our GitLab templates keep using a coherent set of generic GitLab CI [stages](https://docs.gitlab.com/ci/yaml/#stages), mapped on the generic pipeline depicted in the previous chapter:

| Stage | Template type | Description |
| --- | --- | --- |
| `build` | build & test | Build (_when applicable_), unit test (_with code coverage_), and package the code |
| `test` | build & test / code analysis | Perform code anaysis jobs (code quality, Static Application Security Testing, dependency check, license check, ...) |
| `package-build` | packaging | Build the deployable package |
| `package-test` | packaging | Perform all tests on package |
| `infra` | infrastructure | Instantiate/update the (non-production) infrastructure |
| `deploy` | deploy & run | Deploy the application to a (non-production) environment |
| `acceptance` | acceptance | Perform acceptance tests on the upstream environment |
| `publish` | build & test | Publish the packaged code to an artifact repository |
| `infra-prod` | infrastructure | Instantiate/update the production infrastructure |
| `production` | deploy & run | Deploy the application to the [production](https://en.wikipedia.org/wiki/Deployment_environment#Production) environment (CD pipeline only) |

**Ambiguous naming?**

* `build` stage is not only related to **building** the code, but also running **unit tests** (with code coverage)
* `test` is not related to unit testing, but more **code analysis**.

We chose to keep those names anyway to stay compatible with GitLab Auto DevOps that has the same philosophy.

**Can I add my own stages?**

If you're only using the generic _to be continuous_ pipeline stages, you won't have anything to do as all our templates define those stages for you.

But if you're willing to add you own, then you'll have to override the stages in your `.gitlab-ci.yml` file, **inserting yours**:

```
stages:
  - build
  - test
  - package-build
  - package-test
  - infra
  - deploy
  - acceptance
  - my-pre-publish # 👈 insert your extra stage(s)
  - publish
  - infra-prod
  - production
```

💡 you may think the complete list is too large for you case, but don't worry: each stage only appears if at least one active job is mapped to it. Therefore - for e.g. - if you're not using any packaging template, the `package-xxx` stages will never show up in your pipelines.

## Publish & Release

Many templates offer the possibility to package the code and **publish** it to an appropriate registry (ex: PyPI for Python, Maven repository for Java, npm for Node.js, Container registry for container images...).

In addition, _to be continuous_ also support triggering a **release**. A release is the action - from the main branch - to freeze a stable version of the code, determine the next version, publish the versioned code packages (possibly with additional release specific artifacts - ex: a changelog).

As stated above, a **release** should trigger one or several **publish** actions. But a **publish** is not necessarily related to a **release**. Depending on the related technology, you may also want to publish _unstable_ package versions (ex: _snapshot_ in Maven terminology).

### Release

Functionally, a **release** involves the following:

1. `[mandatory]` determine the next release **version** (either manually or automatically),
2. `[optional]` **bump version**
   1. update files with the new version (ex: `pom.xml`, `setup.py`, `.bumpversion.cfg`...)
   2. update other files related with the release (ex: `README.md`, `CHANGELOG.md` ...)
   3. commit the changes
3. `[mandatory]` create a **Git tag** named after the version,
4. `[optional]` create a [GitLab release](https://docs.gitlab.com/user/project/releases/),
5. `[mandatory]` **package** the code (language-dependent format) & **publish** the versioned package(s) to an appropriate repository.

In _to be continuous_, it is implemented in two separate stages:

![release process implementation](https://to-be-continuous.gitlab.io/doc/img/release-process.drawio.svg)

Some _to be continuous_ templates provide their own release stage 1 job implementation (_Prepare_) when supported by the build tool (ex: Maven with the [Maven Release Plugin](https://maven.apache.org/maven-release/maven-release-plugin/), Python with [Bumpversion](https://pypi.org/project/bumpversion/) or with the [Poetry Version](https://python-poetry.org/docs/cli/#version) command), but the release _Prepare_ can also be implemented by a separate tool/template such as [semantic-release](https://semantic-release.gitbook.io/semantic-release/) that can gracefully automates the release process (automatically determines the next version number based on Git commit messages, enforces [semantic versioning](https://semver.org/), generates the release notes, creates the tag and the GitLab release).

### Publish

As explained before, publishing a code package is not necessarily related to a release process (as some technologies - such as Maven - allow publishing _unstable_ package versions) but a release always ends by publishing the versioned packages (stage 2 _Perform_ hereabove).

As a result, all publish-capable templates are fully compatible with `semantic-release` or any alternative implementing the release process.

That means that - for instance - you may perfectly choose to use `semantic-release` to perform the release of a multi-modude project containing Maven and Docker code: the publish of released versions will be implemented by each template in the pipeline triggered by the Git tag created during the release process.

## Deployment environments

All our Deploy & Run templates support 4 kinds of environments (each being optional):

| Environment Type | Description | Associated branch(es) |
| --- | --- | --- |
| **Review** | Those are dynamic and ephemeral environments to deploy your ongoing developments. It is a strict equivalent of GitLab's [Review Apps](https://docs.gitlab.com/ci/review_apps/) feature. | All **development branches** (non-integration, non-production) |
| **Integration** | A single environment to continuously deploy your integration branch. | The **integration branch** (`develop` by default) |
| **Staging** | A single environment to continuously deploy your production branch. It is an iso-prod environment, meant for running the automated acceptance tests prior to deploying to the production env. | The **production branch** (`main` or `master` by default) |
| **Production** | _Well.. the prod!_ | The **production branch** (`main` or `master` by default) |

A few remarks:

* All our Acceptance templates support those environments and cooperate gracefully with whichever deployment technology you're using to test the right server depending on the branch it's running on.
* Transition from **Staging** to **Production** can be either automatic (if you feel confident enough with your automated acceptance tests) or _one-click_ (this is the default). This is configurable.
* If you're working in an organization where development and deployment are managed by separate teams, you may perfectly not declare any **Production** environment in the development project, but instead trigger a pipeline in the project owned by the deployment team.
* [More info about deployment environments on Wikipedia](https://en.wikipedia.org/wiki/Deployment_environment).

## Git branching models

Using Git, there are [many possible branching models](https://www.atlassian.com/git/tutorials/comparing-workflows).

You are free to use whichever you want, but our templates make strong hypothesis you should be aware of:

* the `main` (or `master`) branch is **production** (triggers the CD pipeline),
* the `develop` branch is **integration** (triggers the CI pipeline),

⚠ _the use of an integration branch is **optional**, and even [discouraged as a default choice](https://to-be-continuous.gitlab.io/doc/understand/#when-to-use-gitflow)_

* any other branch is **development** (triggers the CI pipeline).

### When to use Gitflow?

Let's state it clearly: **the most efficient Git branching model is the simplest one** that fits your needs. Consequently:

1. If you do not have good reasons of using an integration branch, just don't.
2. If you do not know which Git branching model to use, start as simple as possible.
3. Gitflow is often chosen by default but Feature-Branch shall be enough in most situations.

ℹ 10 years after the publication of _"A successful Git branching model"_, Vincent Driessen himself (the original author of Gitflow) warned against the dogmatic use of his model [in an addendum to his original article](https://nvie.com/posts/a-successful-git-branching-model/) (see _"Note of reflection"_), even mentionning _"I would suggest to adopt a much simpler workflow (like [GitHub flow](https://guides.github.com/introduction/flow/) [another name for Feature-Branch])"_.

**What is the harm with Gitflow?**

Using an integration branch (`develop`) has several drawbacks that you shall be aware of before making your choice.

The main issue is that it introduces a de-facto delay between the end of a development (feature branch being merged into `develop`) and its deployment to the production environment (`develop` being merged into `main`, thus flushing accumulated changes all at once).

This "two-stages" deployment raises issues:

* Who is responsible for flushing `develop` into `main`? When?
* When things go wrong during a deployment to production, it might be complex to identify which change caused the issue (there might even be cases where the problem is actually due to the interaction between 2 separate changes).
* Depending on the time elapsed since the end of development, it may be difficult for the author of the failing code to analyze the reasons of the problem if this development dates back to a few weeks or months, and the developer has moved on to other tasks.

ℹ Gitflow has a direct impact on [DORA metrics](https://dora.dev/quickcheck/):

| Measure | Impact | Explanation |
| --- | --- | --- |
| **Lead time for changes** | ⬇ | A finished development (merged into `develop`) has to wait for the next release to be available in prod. |
| **Deployment frequency** | ⬇ | Teams working with Gitflow tend to accumulate changes in the integration branch, and release to production less frequently. |
| **Change failure rate** | ⬇ | Accumulating more changes to release all at once increases the risk of failure. |
| **Time to restore** | ⬇ | Releasing a large batch of changes, possibly developed weeks or months ago makes troubleshooting more complex. |

Using an integration branch (with a Gitflow-like branching model) is discouraged as a default choice, but there are some acceptable reasons to adopt one. The following chapters present the 3 main ones.

#### Can't afford review environments

Instantiating a dedicated hosting environment for each development branch in progress might be indeed a cost difficult to afford.

**Tip**

Keep in mind there might be tricks to mitigate this cost:

* shutdown all review environments every evening,
* use a degraded infrastructure (ex: use an in-memory database instead of a real one, get rid of all redundancy…)

Even with smart ideas, it may occur that review environments are just not affordable. In that case your developers will need a single, shared environment to integrate all their work. That's exactly the purpose of an integration branch.

#### Not mature enough for continuous delivery

Lack of automated testing, need of manual acceptance tests campaign on a dedicated environment, poor software quality… There are many reasons why you may not feel ready for continuous delivery.

In that case, an integration branch with its associated integration environment might be the adapted solution.

#### Release-oriented delivery

In release-oriented projects, several features get bundled into a release and then deployed all at once. With the release often comes a product roadmap, a versioning strategy, release notes, a third party for whom the software is intended. Something very common in the software publishing industry.

In that case, an integration branch would be the most appropriate way of addressing this requirement.

Thus developers will develop changes and continuously integrate them into the integration branch, and once all expected features have been developed, you'll be able to proceed with the release and _flush_ them all by merging `develop` into `main`.

That would be a typical case of using the [Software Distribution](https://to-be-continuous.gitlab.io/doc/understand/#software-distribution-mode) delivery mode.

## Development workflow

So far, we've presented a quite _static_ vision of what a CI/CD pipeline should be, but _to be continuous_ implements a differentiated behavior depending on where you are in the **development workflow**.

The following schemas detail the implemented pipeline behavior throughout the development workflow:

![Feature-Branch branching model](https://to-be-continuous.gitlab.io/doc/img/tbc-pipelines-featurebranch.drawio.svg)

![Gitflow-like branching model](https://to-be-continuous.gitlab.io/doc/img/tbc-pipelines-gitflow.drawio.svg)

Development workflow step-by-step:

| Step | Description |
| --- | --- |
| 0⃣ | Any code change shall be developed within a (feature) branch, created from the default branch (`main` or `develop` depending on your Git branching model). |
| 1⃣ | Any new commit in the feature branch is automatically built, verified, possibly deployed and tested in an ephemerate **review environment**. 👉 This is **continuous integration**. The [Adaptive Pipeline](https://to-be-continuous.gitlab.io/doc/understand/#adaptive-pipeline) behavior is implemented on feature branches. |
| 2⃣ | Once reviewed and accepted, the changes can be **merged** into the default branch. |
| 3⃣ (**Gitflow** only) | Merging the changes into `develop` triggers a pipeline where the code is built, verified, possibly deployed and tested in the **integration environment**. 👉 This is still **continuous integration**. |
| 4⃣ (**Gitflow** only) | Later on, the `develop` branch is merged into the `main` branch (deliver to production). |
| 5⃣ | Merging the changes into the `main