---
author: Pierre Smeyers
description: This page presents the general principles of use supported throughout all to-be-continuous templates.
---

# Using _To Be Continuous_

This page presents the general principles of use supported throughout all _to be continuous_ templates.

## Include a template

As previously said, each template may be [included](https://docs.gitlab.com/ci/yaml/#include) in your `.gitlab-ci.yml` file using one of the 3 following syntaxes:

=== "#1: `include:component`"

    The [`include:component`](https://docs.gitlab.com/ci/yaml/#includecomponent) is the newest 
    GitLab syntax and allows to use templates as a [CI/CD component](https://docs.gitlab.com/ci/components/)
    (thus configuring them with [`inputs`](https://docs.gitlab.com/ci/inputs/)):

    ```yaml
    include:
      # Maven template with exact version '3.9.0'
      - component: $CI_SERVER_FQDN/to-be-continuous/maven/gitlab-ci-maven@3.9.0
      # AWS template with minor version alias '5.2' (uses the latest available patch version)
      - component: $CI_SERVER_FQDN/to-be-continuous/aws/gitlab-ci-aws@5.2
    ```

=== "#2: `include:project`"

    The [`include:project`](https://docs.gitlab.com/ci/yaml/#includeproject) syntax is the former GitLab syntax, and is very similar (except it implies configuring templates with [`variables`](https://docs.gitlab.com/ci/variables/)):

    ```yaml
    include:
      # Maven template with exact version '3.9.0'
      - project: "to-be-continuous/maven"
        ref: "3.9.0"
        file: "templates/gitlab-ci-maven.yml"
      # AWS template with minor version alias '5.2' (uses the latest available patch version)
      - project: "to-be-continuous/aws"
        ref: "5.2"
        file: "templates/gitlab-ci-aws.yml"
    ```

=== "#3: `include:remote`"

    The [`include:remote`](https://docs.gitlab.com/ci/yaml/#includeremote) syntax might be interesting if you want to test _to be continuous_ from your Self-Managed GitLab without installing it locally (thus you'll be able to download _to be continuous_ templates directly from [gitlab.com](https://gitlab.com/to-be-continuous)).

    With this syntax, templates have to be configured with [variables](https://docs.gitlab.com/ci/variables/).

    ```yaml
    include:
      # Maven template with exact version '3.9.0'
      - remote: "https://gitlab.com/to-be-continuous/maven/-/raw/3.9.0/templates/gitlab-ci-maven.yml"
      # AWS template with minor version alias '5.2' (uses the latest available patch version)
      - remote: "https://gitlab.com/to-be-continuous/aws/-/raw/5.2/templates/gitlab-ci-aws.yml"
    ```

Our templates are **versioned** (compliant with [Semantic Versioning](https://semver.org/)):

* each version is exposed through a Git tag such as `1.1.0`, `2.1.4`, ...
* for convenience purpose, our templates also maintain a **minor version alias** tag (ex: `2.1`), always referencing the latest patched version within that minor version, 
  and also a **major version alias** tag (ex: `2`), always referencing the latest minor version within that major version.
* our recommendation is to **use a fixed version** of each template (either exact, minor or major), and upgrade when a new valuable feature is rolled out.
* you may also chose to use the **latest released** version (discouraged as a new version with breaking changes would break your pipeline).
  For this, simply include the template from the default branch.

## Configure a template

Each template comes with a predefined configuration (whenever possible), but is always overridable:

* with [inputs](https://docs.gitlab.com/ci/components/#use-a-component) if using the [`include:component`](https://docs.gitlab.com/ci/yaml/#includecomponent) technique,
* or with [variables](https://docs.gitlab.com/ci/variables/) if using `include:project`](https://docs.gitlab.com/ci/yaml/#includeproject) or [`include:remote`](https://docs.gitlab.com/ci/yaml/#includeremote).

Some template features are also enabled by defining the right variable(s).

### Use as a CI/CD component

Here is an example of a Maven project that:

1. overrides the Maven version used (with `image` input),
2. overrides the build arguments (with `build-args`),
3. enables [SonarQube](https://www.sonarqube.org/) analysis (by defining the `sonar-url` input and the `SONAR_AUTH_TOKEN` secret variable),

```yaml
include:
  # 1: include the component
  - component: $CI_SERVER_FQDN/to-be-continuous/maven/gitlab-ci-maven@3.9.0
    # 2: set/override component inputs
    inputs:
      # use Maven 3.6 with JDK 8
      image: "maven:3.6-jdk-8"
      # use 'cicd' Maven profile
      build-args: 'verify -Pcicd'
      # enable SonarQube analysis
      sonar-url: "https://mysonar.domain.my"
      # SONAR_AUTH_TOKEN defined as a secret CI/CD variable
```

### Use as a regular template

Here is an example of a Maven project that:

1. overrides the Maven version used (with `MAVEN_IMAGE` variable),
2. overrides the build arguments (with `MAVEN_BUILD_ARGS`),
3. enables [SonarQube](https://www.sonarqube.org/) analysis (by defining `SONAR_URL` and `SONAR_AUTH_TOKEN`),

```yaml
# 1: include the template(s)
include:
  - project: 'to-be-continuous/maven'
    ref: '3.9.0'
    file: '/templates/gitlab-ci-maven.yml'

# 2: set/override template variables
variables:
  # use Maven 3.6 with JDK 8
  MAVEN_IMAGE: "maven:3.6-jdk-8"
  # use 'cicd' Maven profile
  MAVEN_BUILD_ARGS: 'verify -Pcicd'
  # enable SonarQube analysis
  SONAR_URL: "https://mysonar.domain.my"
  # SONAR_AUTH_TOKEN defined as a secret CI/CD variable
```

This is the basic pattern for configuring the templates!

You'll find configuration details in each template reference documentation.

## Debugging _to be continuous_ jobs

Each template enable debug logs when `$TRACE` is set to `true`.

So you may simply manually run your pipeline, and set `TRACE=true` interactively.

This is different (and complementary) to GitLab's [`CI_DEBUG_TRACE`](https://docs.gitlab.com/ci/variables/#enable-debug-logging) variable.

> [!important] Security notice
> When using the `CI_DEBUG_TRACE` variable in GitLab, it's important to be aware of the potential security risks associated with it. 
> Setting `CI_DEBUG_TRACE` to `true` enables detailed tracing of all commands executed during a CI/CD job, including the output of 
> environment variables, command arguments, and any sensitive information that might be exposed during the pipeline's execution. 
> This can include credentials, tokens, API keys, and other confidential data. 
> If these logs are not properly secured, they can be accessed by unauthorized users, leading to potential security breaches. 
> Therefore, it is recommended to use `CI_DEBUG_TRACE` only when necessary and to ensure that sensitive information is appropriately 
> masked or removed from the logs. 
> Additionally, access to these logs should be restricted to authorized personnel only to minimize the risk of exposing critical information.

## Docker Images Versions

_to be continuous_ templates use - whenever possible - required tools as container images.
And when available, the _latest_ image version is used.

In some cases, using the latest version is a good thing, and in some other cases, the latest version is bad.

* _latest_ is **good** for:
    * DevSecOps tools (Code Quality, Security Analysis, Dependency Check, Linters ...) as using the latest version of the tool is the best way to ensure
      you're likely to detect vulnerabilities as soon as possible (well, as soon as new vulnerabilities are known and covered by DevSecOps tools).
    * Public cloud CLI clients as there is only one version of the public cloud, and the official container image is likely to evolve at the same time as the APIs.
* _latest_ is **not good** for:
    * Build tools as your project is developped using one specific version of the language / the build tool, and you would like to control when you change version.
    * Infrastructure-as-Code tools for the same reason as above.
    * Acceptance tests tools for the same reason as build tools.
    * Private cloud CLI clients as you may not have installed the latest version of - say - OpenShift or Kubernetes, and you'll need to use the client CLI version that matches your servers version.

> [!tip] To summarize
> 1. Make sure you explicitely override the container image versions of your build, Infrastructure-as-Code, private cloud CLI clients and acceptance tests tools matching your project requirements.
> 2. Be aware that sometimes your pipeline may fail (without any change from you) due to a new version of DevSecOps tool that either highlights a new vulnerability (:tada:), or due to a bug or breaking change in the tool (:poop: happens).

## Secrets managements

Most of our templates manage :lock: **secrets** (access tokens, user/passwords, ...).

Our general recommendation for those secrets is to [manage them as project or group CI/CD variables](https://docs.gitlab.com/ci/variables/#for-a-project):

* [**masked**](https://docs.gitlab.com/ci/variables/#mask-a-cicd-variable) to prevent them from being inadvertently
  displayed in your job logs,
* [**protected**](https://docs.gitlab.com/ci/variables/#protected-cicd-variables) if you want to secure some secrets
  you don't want everyone in the project to have access to (for instance production secrets).

### What if a secret can't be masked?

It may happen that a secret contains [characters that prevent it from being masked](https://docs.gitlab.com/ci/variables/#mask-a-cicd-variable).

In that case there is a simple solution: simply encode it in [Base64](https://en.wikipedia.org/wiki/Base64) and declare
the variable value as the Base64 string prefixed with `@b64@`. This value **can** be masked, and it will be automatically
decoded by our templates (make sure you're using a version of the template that supports this syntax).

:warning: The Base64 string is not allowed to contain linebreaks. If you are for example using `base64` to encode, be sure to use the `-w 0` option to disable line wrapping.

> [!note] Example
> `CAVE_PASSPHRASE={"open":"$€5@me"}` can't be masked, but the Base64 encoded secret can.
>
> Then just declare instead:
>
> `CAVE_PASSPHRASE=@b64@eyJvcGVuIjoiJOKCrDVAbWUifQ==`

### Using an external secrets management system

If you want to pull secrets from an external secrets management system, declare a variable with `@url@` prefix, followed by the URL of the secret. Our templates will automatically fetch the URL and put the content into the variable (make sure you're using a version of the template that supports this syntax).

For [Hashicorp Vault](https://developer.hashicorp.com/vault), we provide a [vault-secrets-provider](https://gitlab.com/to-be-continuous/tools/vault-secrets-provider) image, available in most templates through a `-vault` [variant](../self-managed/advanced/#template-variants). It allows fetching secrets from a Vault server and inject them into your CI/CD variables using the `@url@http://vault-secrets-provider/api/secrets/{secret_path}?field={field}` syntax.

Default timeout for fetching secrets is 5 seconds. If you need to increase it, you can set the global `TBC_SECRET_URL_TIMEOUT` variable to the desired number of seconds.

## Scoped variables

All our templates support a generic and powerful way of limiting/overriding some of your environment variables, depending on the execution context.

This feature is comparable to GitLab [Scoping environments with specs](https://docs.gitlab.com/ci/environments/#scope-environments-with-specs)
feature, but covers a broader usage:

* can be used with **non-secret variables** (defined in your `.gitlab-ci.yml` file),
* variables can be scoped by **any other criteria than deployment environment**.

The feature is based on a specific variable naming syntax:

```bash
# syntax 1: using a unary test operator
scoped__<target var>__<condition>__<cond var>__<unary op>=<target val>

# syntax 2: using a comparison operator
scoped__<target var>__<condition>__<cond var>__<cmp op>__<cmp val>=<target val>
```

:warning: mind the **double underscore** that separates each part.

Where:

| Name           | Description                | Possible values / examples |
| -------------- | -------------------------- | -------------------------  |
| `<target var>` | Scoped variable name       | any <br/> example: `MY_SECRET`, `MAVEN_BUILD_ARGS`, ... |
| `<condition>`  | The test condition         | one of: `if` or `ifnot`    |
| `<cond var>`   | The variable on which relies the condition | any <br/> example: `CI_ENVIRONMENT_NAME`, `CI_COMMIT_REF_NAME`, ... |
| `<unary op>`   | Unary test operator to use | only: `defined` |
| `<cmp op>`     | Comparison operator to use | one of: `equals`, `startswith`, `endswith`, `contains`, `in`<br/>or their _ignore case_ version: `equals_ic`, `startswith_ic`, `endswith_ic`,`contains_ic` or `in_ic` |
| `<cmp val>`    | Sluggified value to compare `<cond var>` against | any<br/> With `in` or `in_ic` operators, matching values shall be separated with **double underscores** |
| `<target val>` | The value `<target var>` takes when condition matches | any (can even use other variables that will be expanded) |

> [!caution] Which variables support this?
> The scoped variables feature has a **strong limitation**: it may only be used for variables used in the `script` and/or `before_script` parts; not elsewhere in the `.gitlab-ci.yml` file.
> 
> :red_circle: They **don't support _scoped variables_**:
>
> * variables used to parameterize the jobs container image(s) (ex: `MAVEN_IMAGE` or `K8S_KUBECTL_IMAGE`),
> * variables that enable/disable some jobs behavior (ex: `MAVEN_DEPLOY_ENABLED`, `NODE_AUDIT_DISABLED` or `AUTODEPLOY_TO_PROD`),
> * variables used in [artifacts](https://docs.gitlab.com/ci/yaml/#artifacts), [cache](https://docs.gitlab.com/ci/yaml/#cache) or [rules](https://docs.gitlab.com/ci/yaml/#rules) sections (ex: `PYTHON_PROJECT_DIR`, `NG_WORKSPACE_DIR` or `TF_PROJECT_DIR`).
>
> :white_check_mark: They **do support _scoped variables_**:
>
> * credentials (logins, passwords, tokens, ...),
> * configuration URLs,
> * tool CLI options and arguments (ex: `MAVEN_BUILD_ARGS` or `PHP_CODESNIFFER_ARGS`)
>
> _If you have any doubt: have a look at the template implementation._

> [!caution] How variable values are sluggified?
> Each character that is not a **letter**, a **digit** or **underscore** is replaced by an underscore (`_`).
>
> Examples:
>
> * `Wh@t*tH€!h3¢k` becomes: `Wh_t_tH__h3_k`
> * `feat/add-welcome-page` becomes: `feat_add_welcome_page`

> [!note] Example 1: scope by environment
> ```yaml
> variables:
>   # default configuration
>   K8S_URL: "https://my-nonprod-k8s.domain"
>   MY_DATABASE_PASSWORD: "admin"
>
>   # overridden for prodution environment
>   scoped__K8S_URL__if__CI_ENVIRONMENT_NAME__equals__production: "https://my-prod-k8s.domain"
>   # MY_DATABASE_PASSWORD is overridden for prod in my project CI/CD variables using
>   # scoped__MY_DATABASE_PASSWORD__if__CI_ENVIRONMENT_NAME__equals__production
> ```

> [!note] Example 2: scope by branch
> ```yaml
> variables:
>   # default Angular build arguments (default configuration)
>   NG_BUILD_ARGS: "build"
>
>   # use 'staging' configuration on develop branch
>   scoped__NG_BUILD_ARGS__if__CI_COMMIT_REF_NAME__equals__develop: "build --configuration=staging"
>
>   # use 'production' configuration and optimization on master branch
>   scoped__NG_BUILD_ARGS__if__CI_COMMIT_REF_NAME__equals__master: "build --configuration=production --optimization=true"
> ```

> [!note] Example 3: scope on tag
> ```yaml
> variables:
>   # default Docker build configuration
>   DOCKER_BUILD_ARGS: "--build-arg IMAGE_TYPE=snapshot"
>
>   # overridden when building image on tag (release)
>   scoped__DOCKER_BUILD_ARGS__if__CI_COMMIT_TAG__defined: "--build-arg IMAGE_TYPE=release"
> ```

## Proxy configuration

Our templates don't have any proxy configuration set by default, but they all support standard Linux variables:

* `http_proxy`
* `https_proxy`
* `ftp_proxy`
* `no_proxy`

As a result, you may perfectly define those variables in your project:

* either globally as group or project variables or in the top variables block definition of your `.gitlab-ci.yml` file,
* either locally in specific jobs,
* or for all jobs from one single template ([see below](#the-templates-base-job)).

## Certificate Authority configuration

Our templates all come configured with the Default Trusted Certificate Authorities, but they all support the `CUSTOM_CA_CERTS`
variable to configure additional certificate authorities.

When set, this variable shall contain one or several certificates in [PEM format](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail),
then the template will assume those are trusted certificates, and add them accordingly to the right trust store.

Again, you may perfectly set `CUSTOM_CA_CERTS` in your project:

* either globally as group or project variables or in the top variables block definition of your `.gitlab-ci.yml` file,
* either locally in specific jobs,
* or for all jobs from one single template ([see below](#the-templates-base-job)).

## Configurable Git references

### Production and integration branches

As explained earlier, _to be continuous_ supports various [Git branching models](understand.mdit-branching-models) 
with at least one **production branch** (`main` or `master` by default), 
and possibly one **integration branch** (`develop` by default).

Those _eternal_ branches can be easily configured by overriding the following global variables (regular expression patterns):

```yaml
variables:
  # default production ref name (regex pattern)
  PROD_REF: '/^(master|main)$/'
  # default integration ref name (regex pattern)
  INTEG_REF: '/^develop$/'
```

Those variables are used internally thoughout all _to be continuous_ templates.

### Release tag pattern

Some _to be continuous_ templates also support [publish & release](understand.mdublish--release).
Those templates trigger the publication of released packages only on Git tags matching a predefined pattern.
By default the pattern enforces [semantic versioning](https://semver.org/) but can be overridden.

```yaml
variables:
  # default release tag name (pattern)
  RELEASE_REF: '/^v?[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\-\.]+)?(\+[a-zA-Z0-9\-\.]+)?$/'
```

## Extended `[skip ci]` feature

GitLab skips triggering the CI/CD pipeline when `[skip ci]` or `[ci skip]` is present in the Git commit message.

This feature can be handy, but in some situations you would like to skip the CI/CD pipeline only under certain
circumstances. Example: when creating a release with a Git commit containing only _bumpversion_ changes (setting 
the new released version in configuration and/or documentation files). This commit will also be pushed as a tag. 
You might want to prevent the commit from being processed twice (one from the origin branch **and** one from the tag pipeline).

For this, all the recent versions of _to be continuous_ templates implement an extended `[skip ci]` feature.
It is now possible to skip **selectively** the CI/CD pipeline if your Git commit message contains a part of the following format:

```
[ci skip on <comma separated words>]
or:
[skip ci on <comma separated words>]
```

Supported words are:

| Words   | Description                |
| ------- | -------------------------- |
| `tag`   | skipped on tag pipelines |
| `mr`    | skipped on Merge Request pipelines |
| `branch`| skipped on branch pipelines |
| `default`| skipped on the default project branch |
| `prod`  | skipped on the [production branch](#production-and-integration-branches) |
| `integ` | skipped on the [integration branch](#production-and-integration-branches) |
| `dev`   | skipped on any development branch (other than production or integration) |

This feature can be disabled by removing `!reference [.tbc-workflow-rules, extended-skip-ci]` from `worflow: rules: []`. See next section for more details.

## Merge Request workflow

One thing that has to be chosen with GitLab CI/CD is the [Merge Request workflow strategy](https://docs.gitlab.com/ci/yaml/workflow/#switch-between-branch-pipelines-and-merge-request-pipelines).

By default, _to be continuous_ implements the **merge request pipelines** strategy, with the following workflow declaration:

```yaml
# default workflow rules: Merge Request pipelines
.tbc-workflow-rules:
  # prevent MR pipeline originating from production or integration branch(es)
  skip-back-merge:
    - if: '$CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ $PROD_REF || $CI_MERGE_REQUEST_SOURCE_BRANCH_NAME =~ $INTEG_REF'
      when: never
  # on non-prod, non-integration branches: prefer MR pipeline over branch pipeline
  # ⚠️ can't be used with next rule
  prefer-mr-pipeline:
    - if: '$CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS && $CI_COMMIT_REF_NAME !~ $PROD_REF && $CI_COMMIT_REF_NAME !~ $INTEG_REF'
      when: never
  # prefer branch pipeline over MR pipeline
  # ⚠️ can't be used with previous rule
  prefer-branch-pipeline:
    - if: $CI_MERGE_REQUEST_ID
      when: never
  # extended "[skip ci]" behavior
  extended-skip-ci: [] # hidden for readability
  # TBC default rules (MR workflow policy)
  default:
    - !reference [.tbc-workflow-rules, skip-back-merge]
    - !reference [.tbc-workflow-rules, prefer-mr-pipeline]
    - !reference [.tbc-workflow-rules, extended-skip-ci]

workflow:
  rules:
    - !reference [.tbc-workflow-rules, default]
    - when: always
```

If you want to switch to the **branch pipelines** strategy, simply add the following to your `.gitlab-ci.yml` file:


```yaml
workflow:
  rules:
    - !reference [.tbc-workflow-rules, skip-back-merge]
    - !reference [.tbc-workflow-rules, prefer-branch-pipeline]
    - !reference [.tbc-workflow-rules, extended-skip-ci]
    - when: always
```

> [!important]
> Merge Request pipelines has not always been the default workflow strategy.
> Use the latest version of each **_to be continuous_ templates** to be guaranteed to use this one, or else explicitly
> redefine the strategy you want in your `.gitlab-ci.yaml` file.

Using the same technique as above, you are free to adapt the Workflow Rules by removing or modifying generic _to be continuous_ rules or even adding your own custom rules. 

## Test & Analysis jobs rules

As explained [in this chapter](understand.md#development-workflow), by default _to be continuous_ implements an **adaptive pipeline** strategy with test & analysis jobs:

![Adaptive Pipeline](img/Adaptive-Pipeline.drawio.svg)

This behavior is implemented with a common block of [`rules`](https://docs.gitlab.com/ci/yaml/#rules), shared among all test & analysis jobs:

```yaml
# test job prototype: implement adaptive pipeline rules
.test-policy:
  rules:
    # on tag: auto & failing
    - if: $CI_COMMIT_TAG
    # on ADAPTIVE_PIPELINE_DISABLED: auto & failing
    - if: '$ADAPTIVE_PIPELINE_DISABLED == "true"'
    # on production or integration branch(es): auto & failing
    - if: '$CI_COMMIT_REF_NAME =~ $PROD_REF || $CI_COMMIT_REF_NAME =~ $INTEG_REF'
    # early stage (dev branch, no MR): manual & non-failing
    - if: '$CI_MERGE_REQUEST_ID == null && $CI_OPEN_MERGE_REQUESTS == null'
      when: manual
      allow_failure: true
    # Draft MR: auto & non-failing
    - if: '$CI_MERGE_REQUEST_TITLE =~ /^Draft:.*/'
      allow_failure: true
    # else (Ready MR): auto & failing
    - when: on_success
```

Acceptance test jobs also use a similar (but separate) common block:

```yaml
# acceptance job prototype: implement adaptive pipeline rules
.acceptance-policy:
  rules:
    # exclude tags
    - if: $CI_COMMIT_TAG
      when: never
    # on production or integration branch(es): auto & failing
    - if: '$CI_COMMIT_REF_NAME =~ $PROD_REF || $CI_COMMIT_REF_NAME =~ $INTEG_REF'
    # disable if no review environment
    - if: '$REVIEW_ENABLED != "true"'
      when: never
    # on ADAPTIVE_PIPELINE_DISABLED: auto & failing
    - if: '$ADAPTIVE_PIPELINE_DISABLED == "true"'
    # early stage (dev branch, no MR): manual & non-failing
    - if: '$CI_MERGE_REQUEST_ID == null && $CI_OPEN_MERGE_REQUESTS == null'
      when: manual
      allow_failure: true
    # Draft MR: auto & non-failing
    - if: '$CI_MERGE_REQUEST_TITLE =~ /^Draft:.*/'
      allow_failure: true
    # else (Ready MR): auto & failing
    - when: on_success
```

From the above rules, you might notice you can easily disable the **adaptive pipeline** strategy (therefore enforce 
quality and security jobs, whatever the development stage) by setting the `ADAPTIVE_PIPELINE_DISABLED` variable to `true`.

You might also want to globally override the test & analysis and/or the acceptance jobs strategy by overriding the common block(s).

??? EXAMPLE "Example of custom acceptance jobs strategy"

    For example, the following enforces the acceptance tests whatever the development stage:

    ```yaml
    # my acceptance job strategy: always run acceptance tests on any branch
    .acceptance-policy:
      rules:
        # exclude tags
        - if: $CI_COMMIT_TAG
          when: never
        - when: on_success
    ```

## Override YAML (Advanced Usage)

Sometimes, configuration via variables is not enough to tweak an existing template to fit to your needs.

Fortunately, GitLab CI [include](https://docs.gitlab.com/ci/yaml/#includefile) feature is implemented in a way that
allows you to **override the included YAML code**.

> [!note] Quote from [GitLab documentation](https://docs.gitlab.com/ci/yaml/#include)
> The files defined in include are:
>
> * Deep merged with those in `.gitlab-ci.yml`.
> * Always evaluated first and merged with the content of `.gitlab-ci.yml`, regardless of the position of the include keyword.

In order to override the included templates YAML code, you'll probably have to deep dive into it and understand how it
is designed.

### The templates base job

A very important thing you should be aware of is that every template defines a ([hidden](https://docs.gitlab.com/ci/yaml/#hide-jobs))
base job, [extended](https://docs.gitlab.com/ci/yaml/#extends) by all other jobs.
That might not be the case for templates that declare **one single job**.

For example the Maven template defines the `.mvn-base` base job.

Thus, if you wish to override something **for all the jobs from a specific template**, this is the right place to do
the magic.

### Example 1: add service containers

In this example, let's consider my Java project needs a MySQL database to run its unit tests.

According to the Maven template implementation, that can be done by overriding the `mvn-build` job as follows:

```yaml
mvn-build:
  services:
    - name: mysql:latest
      alias: mysql_host
  variables:
    MYSQL_DATABASE: "acme"
    MYSQL_ROOT_PASSWORD: "root"
```

Those changes will gracefully be merged with the `mvn-build` job, the rest of it (defined by the Maven template) will
remain unchanged.

> [!tip]
> [More info about Service Containers](https://docs.gitlab.com/ci/services/)

### Example 2: run on private runners with proxy

In this example, let's consider my project needs to deploy on a Kubernetes cluster that is only
accessible from my [private runner](https://docs.gitlab.com/ci/runners/#specific-runner) (with tags
`kubernetes`, `private`), and that requires an http proxy.

According to the Kubernetes template implementation, that can be done by overriding the base `.k8s-base` job as follows:

```yaml
.k8s-base:
  # set my runner tags
  tags:
    - kubernetes
    - private
  # set my proxy configuration
  variables:
    http_proxy: "http://my.proxy:8080"
    https_proxy: "http://my.proxy:8080"
```

This way, all Kubernetes jobs will inherit this configuration.

### Example 3: disable go-mod-outdated job

There are a few _to be continuous_ jobs that can't be disabled.
It is the case for example of the `go-mod-outdated` job from the Golang template (actually this job is a pure manually triggered job).

Let's suppose in my project I don't want this job to appear in my pipelines.

That can be done by simply overriding the `go-mod-outdated` job rules as follows:

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/golang/gitlab-ci-golang@4.8.1

# hard disable go-mod-outdated
go-mod-outdated:
  rules:
    - when: never
```

This way, the job won't never appear in the project pipeline.
This technique may be used to hard-disable any non-configurable _to be continuous_ job.

### Example 4: allow a test job to fail

All _to be continuous_ test & analysis jobs implement a [progressive strategy](#test--analysis-jobs-rules).
With this strategy, test & analysis jobs are **not allowed to fail on production and integration branches**.

> [!important] Why can't I configure this behavior?
> _to be continuous_ considers it's an anti-pattern to allow a test or analysis job to fail.
> In practice, such an in-between choice quickly becomes totally useless because no one will 
> pay attention when it fails.
>
> _to be continuous_ position:
>
> * either you care about the topic addressed by the job: activate it, accept to break the pipeline 
> when the job fails, and fixing it shall be a priority to restore the pipeline.
> * either you don't really care: simply disable (or don't enable) the job.
>
> There should not be an in-between position.

Nevertheless if you want to change the strategy to allow a test or analysis job to fail, it can be done by overriding the job rules as follows (example with `docker-trivy`):

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/docker/gitlab-ci-docker@5.7.0

# allow docker-trivy to fail
docker-trivy:
  rules:
    # next rule to preserve the Adaptive Pipeline's "early stage" behavior
    # (dev branch, no MR: manual & allow failure)
    - if: '$CI_MERGE_REQUEST_ID == null && $CI_OPEN_MERGE_REQUESTS == null'
      when: manual
      allow_failure: true
    # any other case: auto & allow failure
    - allow_failure: true
```

## Multiple template instantiation (Advanced Usage)

It may happen that you need to multi-instantiate a _to-be-continuous_ template in your project.
A very common case is with monorepos, when your Git repository hosts multiple independant projects.

Most of _to-be-continuous_ templates support GitLab's [`parallel:matrix` syntax](https://docs.gitlab.com/ci/yaml/#parallelmatrix) to allow multiple template instantiation.
All you have to do is to define a `parallel:matrix` configuration at the [template's base job](#the-templates-base-job) level in your `.gitlab-ci.yml` file,
and define each project specific configuration in your matrix entries.

Example (multi instanciation of the Python template):

```yaml
include:
  # Python template
  - component: $CI_SERVER_FQDN/to-be-continuous/python/gitlab-ci-python@8

# multi-instantiate the Python template
.python-base:
  parallel:
    matrix:
      - PYTHON_PROJECT_DIR: backends/users-api
        PYTHON_IMAGE: docker.io/library/python:3.13-slim
        PYTEST_ENABLED: true
        RUFF_ENABLED: true
      - PYTHON_PROJECT_DIR: backends/orders-api
        PYTHON_IMAGE: docker.io/library/python:3.13-slim
        NOSETESTS_ENABLED: true
      - PYTHON_PROJECT_DIR: cli/users-cli
        PYTHON_IMAGE: docker.io/library/python:3.10-slim
        PYTHON_BLACK_ENABLED: true
```

> [!important]
> As you can see in the above example, the `parallel:matrix` syntax compels to use `variables` to configure the template
> (there's no `parallel:matrix` syntax for CI/CD component's [`inputs`](https://docs.gitlab.com/ci/inputs/)).
