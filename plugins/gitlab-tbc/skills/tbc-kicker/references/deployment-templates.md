# Deployment & Infrastructure Templates Reference

Complete configuration for TBC deployment and infrastructure templates (1 infrastructure + 11 hosting).

---

## Infrastructure Templates

### Terraform

**Template**: `to-be-continuous/terraform`
**Prefix**: `TF_`
**CI/CD Component**: Yes

#### Variants

| Variant | Purpose |
|---------|---------|
| **Vault** | HashiCorp Vault secrets |
| **Google Cloud** | GCP Workload Identity |
| **AWS** | AWS OIDC authentication |

#### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TF_IMAGE` | Terraform CLI image | - |
| `TF_STATE_DISABLED` | Disable GitLab managed state | `false` |
| `TF_PROJECT_DIR` | Project directory | `.` |
| `TF_SCRIPTS_DIR` | Hook scripts directory | `.` |
| `TF_OUTPUT_DIR` | Output directory (artifacts) | `.` |
| `TF_DEFAULT_OPTS` | Default extra options | - |
| `TF_DEFAULT_INIT_OPTS` | Init options | - |
| `TF_DEFAULT_WORKSPACE` | Default workspace | - |
| `TF_DEFAULT_PLAN_OPTS` | Plan options | - |
| `TF_DEFAULT_APPLY_OPTS` | Apply options | - |
| `TF_DEFAULT_DESTROY_OPTS` | Destroy options | - |

### Security Analysis Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| tfsec | `TF_TFSEC_ENABLED` | Security issues detection |
| Trivy Config | `TF_TRIVY_ENABLED` | Misconfiguration scan |
| Checkov | `TF_CHECKOV_ENABLED` | IaC analysis |
| Infracost | `TF_INFRACOST_ENABLED` | Cost estimation |

### Code Quality Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| TFLint | `TF_TFLINT_ENABLED` | Linting |
| TF Fmt | `TF_FMT_ENABLED` | Format check |
| TF Validate | `TF_VALIDATE_ENABLED` | Validation |
| TF Docs | `TF_DOCS_ENABLED` | Documentation |

### Testing & Publishing

| Feature | Variable | Description |
|---------|----------|-------------|
| Test | `TF_TEST_STRATEGY` | `disabled`, `single`, `cascading` |
| Module Publish | `TF_MODULE_PUBLISH_ENABLED` | GitLab Module Registry |

### Environment Configuration

Each environment supports:

| Variable Pattern | Description |
|------------------|-------------|
| `TF_{ENV}_OPTS` | Extra options |
| `TF_{ENV}_INIT_OPTS` | Init options |
| `TF_{ENV}_WORKSPACE` | Workspace name |
| `TF_{ENV}_PLAN_ENABLED` | Separate plan job |
| `TF_{ENV}_PLAN_OPTS` | Plan options |
| `TF_{ENV}_APPLY_OPTS` | Apply options |
| `TF_{ENV}_DESTROY_OPTS` | Destroy options |
| `TF_{ENV}_AUTOSTOP_DURATION` | Auto-stop (non-prod) |

Where `{ENV}` is: `REVIEW`, `INTEG`, `STAGING`, `PROD`

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/terraform/terraform@5
    inputs:
      image: "hashicorp/terraform:1.7"
      tfsec-enabled: true
      checkov-enabled: true
      infracost-enabled: true
      tflint-enabled: true
      review-plan-enabled: true
      staging-plan-enabled: true
      prod-plan-enabled: true
```

---

## Deployment Templates

### Ansible

**Template**: `to-be-continuous/ansible`
**Prefix**: `ANSIBLE_`
**Latest Version**: 6.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ANSIBLE_IMAGE` | Ansible Docker image | `docker.io/cytopia/ansible:latest-tools` |
| `ANSIBLE_PROJECT_DIR` | Project directory | `.` |
| `ANSIBLE_BASE_APP_NAME` | Base application name | `$CI_PROJECT_NAME` |
| `ANSIBLE_ENVIRONMENT_URL` | Default environment URL | - |
| `ANSIBLE_VAULT_PASSWORD` | Vault password (secret) | - |
| `ANSIBLE_PRIVATE_KEY` | SSH private key (secret) | - |
| `ANSIBLE_PUBLIC_KEY` | SSH public key | - |
| `ANSIBLE_DEFAULT_INVENTORY` | Default inventory | - |
| `ANSIBLE_DEFAULT_TAGS` | Default tags | - |
| `ANSIBLE_REQUIREMENTS_FILE` | Galaxy requirements | `requirements.yml` |

### Features & Environments

| Feature | Required Variables |
|---------|-------------------|
| Lint | `ANSIBLE_LINT_DISABLED` to disable |
| Review | `ANSIBLE_REVIEW_PLAYBOOK_FILE`, `ANSIBLE_REVIEW_CLEANUP_TAGS` |
| Integration | `ANSIBLE_INTEG_PLAYBOOK_FILE`, `ANSIBLE_INTEG_CLEANUP_TAGS` |
| Staging | `ANSIBLE_STAGING_PLAYBOOK_FILE`, `ANSIBLE_STAGING_CLEANUP_TAGS` |
| Production | `ANSIBLE_PROD_PLAYBOOK_FILE` |

### Variants

| Variant | Description |
|---------|-------------|
| Vault | HashiCorp Vault secrets |
| GCP | Google Cloud authentication |

---

### AWS

**Template**: `to-be-continuous/aws`
**Prefix**: `AWS_`
**Latest Version**: 5.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_CLI_IMAGE` | AWS CLI image | `docker.io/amazon/aws-cli:latest` |
| `AWS_BASE_APP_NAME` | Application name | `$CI_PROJECT_NAME` |
| `AWS_ENVIRONMENT_URL` | Environment URL template | - |
| `AWS_SCRIPTS_DIR` | Scripts directory | `.` |

### Environments

Enable with `AWS_{ENV}_ENABLED`:
- Review: `AWS_REVIEW_ENABLED`
- Integration: `AWS_INTEG_ENABLED`
- Staging: `AWS_STAGING_ENABLED`
- Production: `AWS_PROD_ENABLED`

### Variants

| Variant | Variables |
|---------|-----------|
| OIDC | `AWS_OIDC_ROLE_ARN` |
| Vault | `VAULT_BASE_URL`, `VAULT_ROLE_ID`, `VAULT_SECRET_ID` |

---

### Azure

**Template**: `to-be-continuous/azure`
**Prefix**: `AZURE_`
**Latest Version**: 5.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AZURE_CLI_IMAGE` | Azure CLI image | `mcr.microsoft.com/azure-cli:latest` |
| `AZURE_BASE_APP_NAME` | Application name | `$CI_PROJECT_NAME` |
| `AZURE_ENVIRONMENT_URL` | Environment URL template | - |
| `AZURE_SCRIPTS_DIR` | Scripts directory | `.` |
| `AZURE_SP_CLIENT_ID` | Service Principal client ID | - |
| `AZURE_SP_PASSWORD` | Service Principal password (secret) | - |
| `AZURE_SP_TENANT_ID` | Service Principal tenant ID | - |

### Environments

Enable with `AZURE_{ENV}_ENABLED`

### Variants

| Variant | Description |
|---------|-------------|
| OIDC | OpenID Connect authentication |
| Vault | HashiCorp Vault secrets |

---

### Cloud Foundry

**Template**: `to-be-continuous/cf`
**Prefix**: `CF_`
**Latest Version**: 6.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `CF_CLI_IMAGE` | CF CLI image | - |
| `CF_MANIFEST_FILE` | Manifest basename | - |
| `CF_API_URL` | Global CF API URL | - |
| `CF_ORG` | CF organization | - |
| `CF_DOMAIN` | Default domain | - |
| `CF_ROUTE_PATH` | Default route path | - |
| `CF_PUSH_ARGS` | Additional push args | - |
| `CF_BASE_APP_NAME` | Application name | - |
| `CF_SCRIPTS_DIR` | Scripts directory | - |
| `CF_NATIVE_ZERODOWNTIME` | Native zero-downtime | `false` |

### Environment Variables

For each env (`REVIEW`, `INTEG`, `STAGING`, `PROD`):
- `CF_{ENV}_ORG`, `CF_{ENV}_SPACE`
- `CF_{ENV}_APP_NAME`, `CF_{ENV}_HOST`
- `CF_{ENV}_DOMAIN`, `CF_{ENV}_ROUTE_PATH`
- `CF_{ENV}_ENVIRONMENT_URL`
- `CF_{ENV}_ZERODOWNTIME_ENABLED`

---

### Docker Compose

**Template**: `to-be-continuous/docker-compose`
**Prefix**: `DCMP_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DCMP_IMAGE` | Docker Compose CLI image | - |
| `DCMP_CMD` | compose or stack command | auto |
| `DCMP_BASE_APP_NAME` | Application name | `$CI_PROJECT_NAME` |
| `DCMP_ENVIRONMENT_URL` | Environment URL template | - |
| `DCMP_SCRIPTS_DIR` | Scripts directory | `.` |
| `DCMP_UP_OPTS` | compose up options | - |
| `DCMP_DOWN_OPTS` | compose down options | - |
| `DCMP_STACK_OPTS` | stack deploy options | - |
| `DCMP_SSH_KNOWN_HOSTS` | SSH known_hosts | - |

### Environments

For each env, set `DCMP_{ENV}_DOCKER_HOST` (e.g., `ssh://docker@host:2375`)

---

### Google Cloud

**Template**: `to-be-continuous/gcloud`
**Prefix**: `GCLOUD_`
**Latest Version**: 5.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GCLOUD_CLI_IMAGE` | Google Cloud CLI image | - |
| `GCP_OIDC_PROVIDER` | Workload Identity Provider | - |
| `GCP_OIDC_ACCOUNT` | Service Account | - |
| `GCLOUD_BASE_APP_NAME` | Application name | `$CI_PROJECT_NAME` |
| `GCLOUD_ENVIRONMENT_URL` | Environment URL template | - |
| `GCLOUD_SCRIPTS_DIR` | Scripts directory | `.` |

### Environments

For each env: `GCLOUD_{ENV}_PROJECT_ID`

---

### Helm

**Template**: `to-be-continuous/helm`
**Prefix**: `HELM_`
**Latest Version**: 5.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HELM_IMAGE` | Helm Docker image | - |
| `HELM_CHART_DIR` | Chart directory | - |
| `HELM_SCRIPTS_DIR` | Hook scripts directory | - |
| `HELM_VALUES_FILE` | Common values file | - |
| `HELM_CHART` | External chart name | - |
| `HELM_REPOS` | Chart repos (`name@url name@url`) | - |
| `HELM_NAMESPACE` | Default namespace | - |
| `HELM_BASE_APP_NAME` | Application name | - |
| `HELM_ENVIRONMENT_URL` | Environment URL template | - |

### Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| Lint | `HELM_LINT_DISABLED` to disable | Chart linting |
| Test | `HELM_TEST_ENABLED` | Helm tests |
| YamlLint | `HELM_YAMLLINT_ENABLED` | Values linting |
| Kube-Score | `HELM_KUBESCORE_ENABLED` | Resource validation |
| Package | `HELM_PACKAGE_ENABLED` | Chart packaging |
| Publish | `HELM_PUBLISH_ENABLED` | Registry publish |

### Environment Variables

For each env:
- `HELM_{ENV}_APP_NAME`
- `HELM_{ENV}_ENVIRONMENT_URL`
- `HELM_{ENV}_VALUES_FILE`
- `HELM_{ENV}_NAMESPACE`

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/helm/helm@5
    inputs:
      chart-dir: "charts/myapp"
      lint-disabled: false
      kubescore-enabled: true
      review-namespace: "review-$CI_COMMIT_REF_SLUG"
      staging-namespace: "staging"
      prod-namespace: "production"
```

---

### Helmfile

**Template**: `to-be-continuous/helmfile`
**Prefix**: `HELMFILE_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `HELMFILE_IMAGE` | Helmfile Docker image | - |
| `HELMFILE_SCRIPTS_DIR` | Hook scripts directory | - |
| `HELMFILE_FILE` | Helmfile path | - |
| `HELMFILE_NAMESPACE` | Default namespace | - |
| `HELMFILE_BASE_APP_NAME` | Application name | - |
| `HELMFILE_ENVIRONMENT_URL` | Environment URL template | - |

---

### Kubernetes

**Template**: `to-be-continuous/kubernetes`
**Prefix**: `K8S_`
**Latest Version**: 5.x

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `K8S_IMAGE` | kubectl Docker image | - |
| `K8S_URL` | Global Kubernetes API URL | - |
| `K8S_BASE_APP_NAME` | Application name | `$CI_PROJECT_NAME` |
| `K8S_ENVIRONMENT_URL` | Environment URL template | - |
| `K8S_SCRIPTS_DIR` | Scripts directory | `.` |
| `K8S_KUSTOMIZE_ENABLED` | Enable Kustomize | `false` |
| `K8S_KUSTOMIZE_OPTS` | Kustomize options | - |
| `K8S_AUTO_CREATE_NAMESPACE` | Auto create namespace | `false` |

### Features

| Feature | Enable Variable | Description |
|---------|----------------|-------------|
| Kube-Score | `K8S_KUBESCORE_ENABLED` | Template analysis |

### Environment Variables

For each env:
- `K8S_{ENV}_NAMESPACE` (mandatory)
- `K8S_{ENV}_APP_NAME`
- `K8S_{ENV}_ENVIRONMENT_URL`
- `K8S_{ENV}_URL` (override)
- `K8S_{ENV}_TOKEN` (secret)

### Example

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/kubernetes/kubernetes@5
    inputs:
      kustomize-enabled: true
      auto-create-namespace: true
      kubescore-enabled: true
      review-namespace: "review-$CI_COMMIT_REF_SLUG"
      integ-namespace: "integration"
      staging-namespace: "staging"
      prod-namespace: "production"

variables:
  K8S_TOKEN: $KUBE_TOKEN
```

---

### OpenShift

**Template**: `to-be-continuous/openshift`
**Prefix**: `OS_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `OS_IMAGE` | OpenShift CLI image | - |
| `OS_URL` | Global OpenShift API URL | - |
| `OS_BASE_APP_NAME` | Application name | `$CI_PROJECT_NAME` |
| `OS_TEMPLATE_NAME` | Template name | - |
| `OS_ENVIRONMENT_URL` | Environment URL template | - |
| `OS_SCRIPTS_DIR` | Scripts directory | `.` |

### Environment Variables

For each env:
- `OS_{ENV}_PROJECT` (mandatory)
- `OS_{ENV}_APP_NAME`
- `OS_{ENV}_ENVIRONMENT_URL`
- `OS_{ENV}_URL` (override)

---

### S3

**Template**: `to-be-continuous/s3`
**Prefix**: `S3_`

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `S3_IMAGE` | s3cmd Docker image | - |
| `S3_HOST_BASE` | S3 endpoint hostname:port | - |
| `S3_HOST_BUCKET` | Bucket URL template | - |
| `S3_DEFAULT_REGION` | Default region | - |
| `S3_BASE_BUCKET_NAME` | Base bucket name | - |
| `S3_DEPLOY_CMD` | s3cmd deploy command | - |
| `S3_DEPLOY_FILES` | Files pattern | - |
| `S3_WEBSITE_DISABLED` | Disable website hosting | `false` |
| `S3_WEBSITE_ENDPOINT` | Website URL pattern | - |
| `S3_DEFAULT_PREFIX` | Upload prefix | - |
| `S3_SCRIPTS_DIR` | Scripts directory | - |

### Variants

| Variant | Purpose |
|---------|---------|
| **Vault** | HashiCorp Vault secrets |

### Environment Variables

For each env:
- `S3_{ENV}_HOST_BASE`
- `S3_{ENV}_REGION`
- `S3_{ENV}_BUCKET_NAME`
- `S3_{ENV}_PREFIX`
- `S3_{ENV}_ACCESS_KEY` (secret)
- `S3_{ENV}_SECRET_KEY` (secret)

---

## Variants Summary

All templates with variant support:

| Template | Vault | OIDC | GCP | AWS | Other |
|----------|:-----:|:----:|:---:|:---:|-------|
| Terraform | Yes | - | Yes | Yes | - |
| Ansible | Yes | - | Yes | - | - |
| AWS | Yes | Yes | - | - | - |
| Azure | Yes | Yes | - | - | - |
| Cloud Foundry | Yes | - | - | - | - |
| Google Cloud | Yes | Yes | - | - | - |
| Helm | Yes | - | Yes | - | - |
| Helmfile | Yes | - | - | - | - |
| Kubernetes | Yes | - | Yes | - | - |
| OpenShift | Yes | - | - | - | - |
| S3 | Yes | - | - | - | - |

---

## Common Patterns

### Vault Integration

All Vault variants require these secret variables:

```yaml
# secret variables
# VAULT_BASE_URL: HashiCorp Vault server URL
# VAULT_ROLE_ID: AppRole RoleID
# VAULT_SECRET_ID: AppRole SecretID
```

### OIDC Integration

For AWS, Azure, GCP with OpenID Connect:

1. Configure Identity Provider in cloud console
2. Create role/service account with GitLab trust policy
3. Set role ARN/provider in CI/CD variables

**AWS OIDC Example:**
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/aws/aws@5
    inputs:
      review-enabled: true
      prod-enabled: true
  - component: $CI_SERVER_FQDN/to-be-continuous/aws/aws-oidc@5

# secret variables
# AWS_OIDC_ROLE_ARN: arn:aws:iam::123456789012:role/GitLabOIDC
```

### Environment Patterns

Standard 4-environment deployment:

| Environment | Branch | Auto Deploy | Cleanup |
|-------------|--------|-------------|---------|
| review | Feature | Yes | Auto |
| integration | develop | Yes | Manual |
| staging | main | Yes | Manual |
| production | main | Manual | Never |

### Feature Toggle Patterns

Features use consistent naming:

```yaml
# Enable a disabled feature
inputs:
  {feature}-enabled: true

# Disable an enabled feature
inputs:
  {feature}-disabled: true
```
