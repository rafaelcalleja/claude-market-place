# Usage - to be continuous

This page presents the general principles of use supported throughout all _to be continuous_ templates.

## Include a template

As previously said, each template may be [included](https://docs.gitlab.com/ci/yaml/#include) in your `.gitlab-ci.yml` file using one of the 3 following syntaxes:

#1: `include:component` #2: `include:project` #3: `include:remote`

The [`include:component`](https://docs.gitlab.com/ci/yaml/#includecomponent) is the newest GitLab syntax and allows to use templates as a [CI/CD component](https://docs.gitlab.com/ci/components/) (thus configuring them with [`inputs`](https://docs.gitlab.com/ci/inputs/)):

```yaml
include:
  # Maven template with exact version '3.9.0'
  - component: $CI_SERVER_FQDN/to-be-continuous/maven/gitlab-ci-maven@3.9.0
  # AWS template with minor version alias '5.2' (uses the latest available patch version)
  - component: $CI_SERVER_FQDN/to-be-continuous/aws/gitlab-ci-aws@5.2
```

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

*   each version is exposed through a Git tag such as `1.1.0`, `2.1.4`, ...
*   for convenience purpose, our templates also maintain a **minor version alias** tag (ex: `2.1`), always referencing the latest patched version within that minor version, and also a **major version alias** tag (ex: `2`), always referencing the latest minor version within that major version.
*   our recommendation is to **use a fixed version** of each template (either exact, minor or major), and upgrade when a new valuable feature is rolled out.
*   you may also chose to use the **latest released** version (discouraged as a new version with breaking changes would break your pipeline). For this, simply include the template from the default branch.

## Configure a template

Each template comes with a predefined configuration (whenever possible), but is always overridable:

*   with [inputs](https://docs.gitlab.com/ci/components/#use-a-component) if using the [`include:component`](https://docs.gitlab.com/ci/yaml/#includecomponent) technique,
*   or with [variables](https://docs.gitlab.com/ci/variables/) if using `include:project`](https://docs.gitlab.com/ci/yaml/#includeproject) or [`include:remote`](https://docs.gitlab.com/ci/yaml/#includeremote).

Some template features are also enabled by defining the right variable(s).

### Use as a CI/CD component

Here is an example of a Maven project that:

1.   overrides the Maven version used (with `image` input),
2.   overrides the build arguments (with `build-args`),
3.   enables [SonarQube](https://www.sonarqube.org/) analysis (by defining the `sonar-url` input and the `SONAR_AUTH_TOKEN` secret variable),

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

1.   overrides the Maven version used (with `MAVEN_IMAGE` variable),
2.   overrides the build arguments (with `MAVEN_BUILD_ARGS`),
3.   enables [SonarQube](https://www.sonarqube.org/) analysis (by defining `SONAR_URL` and `SONAR_AUTH_TOKEN`),

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

**Security notice**

When using the `CI_DEBUG_TRACE` variable in GitLab, it's important to be aware of the potential security risks associated with it. Setting `CI_DEBUG_TRACE` to `true` enables detailed tracing of all commands executed during a CI/CD job, including the output of environment variables, command arguments, and any sensitive information that might be exposed during the pipeline's execution. This can include credentials, tokens, API keys, and other confidential data. If these logs are not properly secured, they can be accessed by unauthorized users, leading to potential security breaches. Therefore, it is recommended to use `CI_DEBUG_TRACE` only when necessary and to ensure that sensitive information is appropriately masked or removed from the logs. Additionally, access to these logs should be restricted to authorized personnel only to minimize the risk of exposing critical information.

## Docker Images Versions

_to be continuous_ templates use - whenever possible - required tools as container images. And when available, the _latest_ image version is used.

In some cases, using the latest version is a good thing, and in some other cases, the latest version is bad.

*   _latest_ is **good** for:
    *   DevSecOps tools (Code Quality, Security Analysis, Dependency Check, Linters ...) as using the latest version of the tool is the best way to ensure you're likely to detect vulnerabilities as soon as possible (well, as soon as new vulnerabilities are known and covered by DevSecOps tools).
    *   Public cloud CLI clients as there is only one version of the public cloud, and the official container image is likely to evolve at the same time as the APIs.

*   _latest_ is **not good** for:
    *   Build tools as your project is developped using one specific version of the language / the build tool, and you would like to control when you change version.
    *   Infrastructure-as-Code tools for the same reason as above.
    *   Acceptance tests tools for the same reason as build tools.
    *   Private cloud CLI clients as you may not have installed the latest version of - say - OpenShift or Kubernetes, and you'll need to use the client CLI version that matches your servers version.

**To summarize**

1.   Make sure you explicitely override the container image versions of your build, Infrastructure-as-Code, private cloud CLI clients and acceptance tests tools matching your project requirements.
2.   Be aware that sometimes your pipeline may fail (without any change from you) due to a new version of DevSecOps tool that either highlights a new vulnerability (🎉), or due to a bug or breaking change in the tool (💩 happens).

## Secrets managements

Most of our templates manage 🔒**secrets** (access tokens, user/passwords, ...).

Our general recommendation for those secrets is to [manage them as project or group CI/CD variables](https://docs.gitlab.com/ci/variables/#for-a-project):

*   [**masked**](https://docs.gitlab.com/ci/variables/#mask-a-cicd-variable) to prevent them from being inadvertently displayed in your job logs,
*   [**protected**](https://docs.gitlab.com/ci/variables/#protected-cicd-variables) if you want to secure some secrets you don't want everyone in the project to have access to (for instance production secrets).

### What if a secret can't be masked?

It may happen that a secret contains [characters that prevent it from being masked](https://docs.gitlab.com/ci/variables/#mask-a-cicd-variable).

In that case there is a simple solution: simply encode it in [Base64](https://en.wikipedia.org/wiki/Base64) and declare the variable value as the Base64 string prefixed with `@b64@`. This value **can** be masked, and it will be automatically decoded by our templates (make sure you're using a version of the template that supports this syntax).

⚠ The Base64 string is not allowed to contain linebreaks. If you are for example using `base64` to encode, be sure to use the `-w 0` option to disable line wrapping.

**Example**

`CAVE_PASSPHRASE={"open":"$€5@me"}` can't be masked, but the Base64 encoded secret can.

Then just declare instead:

`CAVE_PASSPHRASE=@b64@eyJvcGVuIjoiJOKCrDVAbWUifQ==`

### Using an external secrets management system

If you want to pull secrets from an external secrets management system, declare a variable with `@url@` prefix, followed by the URL of the secret. Our templates will automatically fetch the URL and put the content into the variable (make sure you're using a version of the template that supports this syntax).

For [Hashicorp Vault](https://developer.hashicorp.com/vault), we provide a [vault-secrets-provider](https://gitlab.com/to-be-continuous/tools/vault-secrets-provider) image, available in most templates through a `-vault`[variant](https://to-be-continuous.gitlab.io/doc/self-managed/advanced/#template-variants). It allows fetching secrets from a Vault server and inject them into your CI/CD variables using the `@url@http://vault-secrets-provider/api/secrets/{secret_path}?field={field}` syntax.

Default timeout for fetching secrets is 5 seconds. If you need to increase it, you can set the global `TBC_SECRET_URL_TIMEOUT` variable to the desired number of seconds.

## Scoped variables

All our templates support a generic and powerful way of limiting/overriding some of your environment variables, depending on the execution context.

This feature is comparable to GitLab [Scoping environments with specs](https://docs.gitlab.com/ci/environments/#scope-environments-with-specs) feature, but covers a broader usage:

*   can be used with **non-secret variables** (defined in your `.gitlab-ci.yml` file),
*   variables can be scoped by **any other criteria than deployment environment**.

The feature is based on a specific variable naming syntax:

```
# syntax 1: using a unary test operator
scoped__<target var>__<condition>__<cond var>__<unary op>=<target val>

# syntax 2: using a comparison operator
scoped__<target var>__<condition>__<cond var>__<cmp op>__<cmp val>=<target val>
```

⚠ mind the **double underscore** that separates each part.

Where:

| Name | Description | Possible values / examples |
| --- | --- | --- |
| `<target var>` | Scoped variable name | any example: `MY_SECRET`, `MAVEN_BUILD_ARGS`, ... |
| `<condition>` | The test condition | one of: `if` or `ifnot` |
| `<cond var>` | The variable on which relies the condition | any example: `CI_ENVIRONMENT_NAME`, `CI_COMMIT_REF_NAME`, ... |
| `<unary op>` | Unary test operator to use | only: `defined` |
| `<cmp op>` | Comparison operator to use | one of: `equals`, `startswith`, `endswith`, `contains`, `in` or their _ignore case_ version: `equals_ic`, `startswith_ic`, `endswith_ic`,`contains_ic` or `in_ic` |
| `<cmp val>` | Sluggified value to compare `<cond var>` against | any With `in` or `in_ic` operators, matching values shall be separated with **double underscores** |
| `<target val>` | The value `<target var>` takes when condition matches | any (can even use other variables that will be expanded) |

**Which variables support this?**

The scoped variables feature has a **strong limitation**: it may only be used for variables used in the `script` and/or `before_script` parts; not elsewhere in the `.gitlab-ci.yml` file.

🔴 They **don't support _scoped variables_**:

*   variables used to parameterize the jobs container image(s) (ex: `MAVEN_IMAGE` or `K8S_KUBECTL_IMAGE`),
*   variables that enable/disable some jobs behavior (ex: `MAVEN_DEPLOY_ENABLED`, `NODE_AUDIT_DISABLED` or `AUTODEPLOY_TO_PROD`),
*   variables used in [artifacts](https://docs.gitlab.com/ci/yaml/#artifacts), [cache](https://docs.gitlab.com/ci/yaml/#cache) or [rules](https://docs.gitlab.com/ci/yaml/#rules) sections (ex: `PYTHON_PROJECT_DIR`, `NG_WORKSPACE_DIR` or `TF_PROJECT_DIR`).

✅ They **do support _scoped variables_**:

*   credentials (logins, passwords, tokens, ...),
*   configuration URLs,
*   tool CLI options and arguments (ex: `MAVEN_BUILD_ARGS` or `PHP_CODESNIFFER_ARGS`)

_If you have any doubt: have a look at the template implementation._

**How variable values are sluggified?**

Each character that is not a **letter**, a **digit** or **underscore** is replaced by an underscore (`_`).

Examples:

*   `Wh@t*tH€!h3¢k` becomes: `Wh_t_tH__h3_k`
*   `feat/add-welcome-page` becomes: `feat_add_welcome_page`

**Example 1: scope by environment**

```yaml
variables:
  # default configuration
  K8S_URL: "https://my-nonprod-k8s.domain"
  MY_DATABASE_PASSWORD: "admin"

  # overridden for prodution environment
  scoped__K8S_URL__if__CI_ENVIRONMENT_NAME__equals__production: "https://