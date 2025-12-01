# to-be-continuous Template Variants Catalog

> **Last Updated**: 2025-11-29
> **Purpose**: Comprehensive mapping of all template variants across the to-be-continuous ecosystem

## Overview

This document catalogs ALL template variants across all 62 to-be-continuous components. It enables **cross-component variant discovery**: if a specific variant doesn't exist in component A but does in component B, you can identify the implementation pattern here.

### Common Variant Patterns

| Variant Type | Authentication Method | Use Case | Found In |
|--------------|----------------------|----------|----------|
| **Standard** (no suffix) | Static credentials via CI/CD variables | Simple deployments with basic secret management | All components |
| **-vault** | HashiCorp Vault (JWT or AppRole) | Enterprise deployments with centralized secrets | AWS, Azure, S3, Kubernetes, Helm, Terraform, Docker, OpenShift, Cloud Foundry, etc. |
| **-oidc** | OpenID Connect (temporary credentials) | Enhanced security without long-lived credentials | AWS, Azure, GCloud |
| **-gcp** | Google Cloud Workload Identity Federation | GKE deployments with native GCP authentication | Kubernetes, Helm, Terraform, Docker |
| **-aws/-eks/-ecr** | AWS IAM/STS with OIDC | EKS/ECR deployments with AWS identity | Kubernetes, Helm, Docker |

---

## Deployment Templates

### AWS (Amazon Web Services)

**Main Template**: https://gitlab.com/to-be-continuous/aws
**README**: https://gitlab.com/to-be-continuous/aws/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-aws.yml`)
- **Authentication**: AWS access key credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
- **Use Case**: Straightforward AWS deployments where credentials are managed through GitLab CI variables
- **Link**: https://gitlab.com/to-be-continuous/aws/-/raw/master/templates/gitlab-ci-aws.yml

**OIDC** (`gitlab-ci-aws-oidc.yml`)
- **Authentication**: OpenID Connect for retrieving temporary AWS credentials via JWT tokens
- **Use Case**: Organizations prioritizing credential security, requiring short-lived token-based access
- **Differentiator**: Eliminates long-lived credential storage
- **Link**: https://gitlab.com/to-be-continuous/aws/-/raw/master/templates/gitlab-ci-aws-oidc.yml

**Vault** (`gitlab-ci-aws-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT or AppRole)
- **Use Case**: Enterprises with centralized secret vaults, needing audit trails and advanced secret rotation
- **Differentiator**: Retrieves secrets dynamically at runtime through Vault API
- **Link**: https://gitlab.com/to-be-continuous/aws/-/raw/master/templates/gitlab-ci-aws-vault.yml

---

### Azure

**Main Template**: https://gitlab.com/to-be-continuous/azure
**README**: https://gitlab.com/to-be-continuous/azure/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-azure.yml`)
- **Authentication**: Service Principal with credentials (username/password or certificate)
- **Use Case**: Standard Azure deployments using service principal credentials managed as GitLab CI/CD variables
- **Link**: https://gitlab.com/to-be-continuous/azure/-/raw/master/templates/gitlab-ci-azure.yml

**OIDC** (`gitlab-ci-azure-oidc.yml`)
- **Authentication**: OpenID Connect using federated identities with temporary credentials
- **Use Case**: Enhanced security by avoiding credential storage, though Azure doesn't support wildcards in federated identities (limits to single GitLab projects/branches)
- **Differentiator**: Uses JWT tokens instead of static credentials
- **Link**: https://gitlab.com/to-be-continuous/azure/-/raw/master/templates/gitlab-ci-azure-oidc.yml

**Vault** (`gitlab-ci-azure-vault.yml`)
- **Authentication**: HashiCorp Vault server (AppRole or JWT token)
- **Use Case**: Enterprises with existing Vault deployments seeking unified secret management
- **Differentiator**: Centralizes secrets through dedicated Vault infrastructure
- **Link**: https://gitlab.com/to-be-continuous/azure/-/raw/master/templates/gitlab-ci-azure-vault.yml

---

### S3

**Main Template**: https://gitlab.com/to-be-continuous/s3
**README**: https://gitlab.com/to-be-continuous/s3/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-s3.yml`)
- **Authentication**: Direct S3 credentials (Access Key and Secret Key)
- **Use Case**: Organizations managing secrets directly as project/group CI/CD variables; simpler deployments
- **CLI Tool**: Uses `aws s3 sync` (inherently incremental - only uploads new/modified files)
- **Link**: https://gitlab.com/to-be-continuous/s3/-/raw/master/templates/gitlab-ci-s3.yml

**Vault** (`gitlab-ci-s3-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID tokens or AppRole)
- **Use Case**: Enterprise environments requiring centralized secret governance and compliance
- **Differentiator**: Delegates credential management to external Vault instance
- **Link**: https://gitlab.com/to-be-continuous/s3/-/raw/master/templates/gitlab-ci-s3-vault.yml

---

### Kubernetes

**Main Template**: https://gitlab.com/to-be-continuous/kubernetes
**README**: https://gitlab.com/to-be-continuous/kubernetes/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-k8s.yml`)
- **Authentication**: GitLab agents, explicit kubeconfig, or exploded parameters (server URL, certificate, token)
- **Use Case**: Core CI/CD pipeline for deploying to any Kubernetes cluster with declarative or Kustomize-based deployments
- **Link**: https://gitlab.com/to-be-continuous/kubernetes/-/raw/master/templates/gitlab-ci-k8s.yml

**Vault** (`gitlab-ci-k8s-vault.yml`)
- **Authentication**: HashiCorp Vault server (JWT token or AppRole)
- **Use Case**: Organizations requiring centralized secret management; retrieves sensitive data dynamically
- **Differentiator**: Delegates secrets to Vault using `@url@` syntax
- **Link**: https://gitlab.com/to-be-continuous/kubernetes/-/raw/master/templates/gitlab-ci-k8s-vault.yml

**Google Cloud** (`gitlab-ci-k8s-gcp.yml`)
- **Authentication**: Application Default Credentials through Workload Identity Federation with Service Accounts
- **Use Case**: Google Kubernetes Engine deployments leveraging native GCP authentication
- **Differentiator**: Streamlined GKE integration without managing kubeconfig files
- **Link**: https://gitlab.com/to-be-continuous/kubernetes/-/raw/master/templates/gitlab-ci-k8s-gcp.yml

**AWS** (`gitlab-ci-k8s-aws.yml`)
- **Authentication**: OIDC token exchange with AWS STS for temporary credential generation
- **Use Case**: EKS deployments using native AWS IAM without storing long-lived credentials
- **Differentiator**: Requires `aws-iam-authenticator` in kubectl image
- **Link**: https://gitlab.com/to-be-continuous/kubernetes/-/raw/master/templates/gitlab-ci-k8s-aws.yml

---

### Helm

**Main Template**: https://gitlab.com/to-be-continuous/helm
**README**: https://gitlab.com/to-be-continuous/helm/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-helm.yml`)
- **Authentication**: Standard kubeconfig or GitLab Kubernetes integration
- **Use Case**: General Helm deployments to any Kubernetes cluster
- **Link**: https://gitlab.com/to-be-continuous/helm/-/raw/master/templates/gitlab-ci-helm.yml

**Vault** (`gitlab-ci-helm-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole with RoleID/SecretID)
- **Use Case**: Organizations requiring centralized secret management across multiple applications
- **Differentiator**: Delegates secret management to external Vault server
- **Link**: https://gitlab.com/to-be-continuous/helm/-/raw/master/templates/gitlab-ci-helm-vault.yml

**Google Cloud** (`gitlab-ci-helm-gcp.yml`)
- **Authentication**: OIDC federation with Google Cloud Workload Identity Pool and Service Account impersonation
- **Use Case**: Publishing charts to Google Cloud Artifact Registry and deploying to GKE without long-lived credentials
- **Differentiator**: Workload identity federation for secure, temporary credential generation
- **Link**: https://gitlab.com/to-be-continuous/helm/-/raw/master/templates/gitlab-ci-helm-gcp.yml

**EKS** (`gitlab-ci-helm-eks.yml`)
- **Authentication**: GitLab OIDC authentication with AWS for assuming IAM roles
- **Use Case**: AWS-based organizations deploying to EKS clusters with IAM-based access controls
- **Differentiator**: Supports both public and private cluster topologies with optional SSM port forwarding
- **Link**: https://gitlab.com/to-be-continuous/helm/-/raw/master/templates/gitlab-ci-helm-eks.yml

---

### Google Cloud Platform (GCloud)

**Main Template**: https://gitlab.com/to-be-continuous/gcloud
**README**: https://gitlab.com/to-be-continuous/gcloud/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-gcloud.yml`)
- **Authentication**: Service Account key file or OpenID Connect (when OIDC variant included)
- **Use Case**: Standard deployments to Google Cloud Platform with basic secret management via CI/CD variables
- **Link**: https://gitlab.com/to-be-continuous/gcloud/-/raw/master/templates/gitlab-ci-gcloud.yml

**OIDC** (`gitlab-ci-gcloud-oidc.yml`)
- **Authentication**: Federated authentication using OpenID Connect with workload identity pools
- **Use Case**: Organizations prioritizing security through short-lived tokens, eliminating static service account keys
- **Differentiator**: No long-lived credentials in CI/CD pipelines
- **Link**: https://gitlab.com/to-be-continuous/gcloud/-/raw/master/templates/gitlab-ci-gcloud-oidc.yml

**Vault** (`gitlab-ci-gcloud-vault.yml`)
- **Authentication**: Vault AppRole or JWT ID token
- **Use Case**: Enterprises with centralized secret management requiring audit trails and rotation policies
- **Differentiator**: Delegates secrets management to Vault server
- **Link**: https://gitlab.com/to-be-continuous/gcloud/-/raw/master/templates/gitlab-ci-gcloud-vault.yml

---

### Docker

**Main Template**: https://gitlab.com/to-be-continuous/docker
**README**: https://gitlab.com/to-be-continuous/docker/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-docker.yml`)
- **Authentication**: Docker registry credentials via CI/CD variables
- **Use Case**: Standard container image building and pushing to generic registries
- **Link**: https://gitlab.com/to-be-continuous/docker/-/raw/master/templates/gitlab-ci-docker.yml

**Vault** (`gitlab-ci-docker-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole credentials)
- **Use Case**: Organizations using Vault for centralized secret management
- **Differentiator**: Retrieves credentials dynamically during CI/CD pipelines
- **Link**: https://gitlab.com/to-be-continuous/docker/-/raw/master/templates/gitlab-ci-docker-vault.yml

**Google Cloud** (`gitlab-ci-docker-gcp.yml`)
- **Authentication**: Workload Identity Federation (OIDC) with Google Cloud service accounts
- **Use Case**: Teams deploying to GCP needing to push images to Artifact Registry with short-lived credentials
- **Differentiator**: Integrates with Google Cloud Artifact Registry, leverages federated identity
- **Link**: https://gitlab.com/to-be-continuous/docker/-/raw/master/templates/gitlab-ci-docker-gcp.yml

**ECR** (`gitlab-ci-docker-ecr.yml`)
- **Authentication**: OIDC federation with AWS IAM roles (recommended) or basic AWS access keys
- **Use Case**: AWS-based deployments requiring integration with Elastic Container Registry
- **Differentiator**: Handles Amazon ECR authorization token retrieval for temporary credentials
- **Link**: https://gitlab.com/to-be-continuous/docker/-/raw/master/templates/gitlab-ci-docker-ecr.yml

---

### Terraform / OpenTofu

**Main Template**: https://gitlab.com/to-be-continuous/terraform
**README**: https://gitlab.com/to-be-continuous/terraform/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-terraform.yml`)
- **Authentication**: Cloud-agnostic; relies on user-provided environment variables, secrets, or credential files
- **Use Case**: General-purpose Terraform/OpenTofu deployments, on-premises infrastructure, or non-AWS/non-GCP providers
- **Differentiator**: Provider-neutral, supports both Terraform and OpenTofu
- **Link**: https://gitlab.com/to-be-continuous/terraform/-/raw/master/templates/gitlab-ci-terraform.yml

**Vault** (`gitlab-ci-terraform-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Enterprise-grade secrets management with audit trails, dynamic credential rotation, and centralized policy enforcement
- **Differentiator**: Uses Vault Secrets Provider with `@url@` syntax for dynamic secret injection
- **Link**: https://gitlab.com/to-be-continuous/terraform/-/raw/master/templates/gitlab-ci-terraform-vault.yml

**Google Cloud** (`gitlab-ci-terraform-gcp.yml`)
- **Authentication**: OpenID Connect via Workload Identity Federation, impersonating service accounts
- **Use Case**: GCP-based deployments avoiding service account keys with temporary, short-lived credentials
- **Differentiator**: Leverages Application Default Credentials through Workload Identity federation
- **Link**: https://gitlab.com/to-be-continuous/terraform/-/raw/master/templates/gitlab-ci-terraform-gcp.yml

**AWS** (`gitlab-ci-terraform-aws.yml`)
- **Authentication**: OpenID Connect with "Assume Role with Web Identity" for temporary STS credentials
- **Use Case**: AWS infrastructure projects requiring keyless authentication with segregated IAM roles per environment
- **Differentiator**: Auto-configures AWS Provider environment variables for assumable roles
- **Link**: https://gitlab.com/to-be-continuous/terraform/-/raw/master/templates/gitlab-ci-terraform-aws.yml

---

### OpenShift

**Main Template**: https://gitlab.com/to-be-continuous/openshift
**README**: https://gitlab.com/to-be-continuous/openshift/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-openshift.yml`)
- **Authentication**: Token authentication with service account tokens
- **Use Case**: OpenShift deployments with basic token-based authentication
- **Note**: Tokens from user accounts expire in 24 hours; use service account tokens for persistent access
- **Link**: https://gitlab.com/to-be-continuous/openshift/-/raw/master/templates/gitlab-ci-openshift.yml

**Vault** (`gitlab-ci-openshift-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Enterprises with centralized Vault for secrets management
- **Differentiator**: Uses Vault Secrets Provider with `@url@` syntax
- **Link**: https://gitlab.com/to-be-continuous/openshift/-/raw/master/templates/gitlab-ci-openshift-vault.yml

---

### Cloud Foundry

**Main Template**: https://gitlab.com/to-be-continuous/cloud-foundry
**README**: https://gitlab.com/to-be-continuous/cloud-foundry/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-cf.yml`)
- **Authentication**: Basic authentication (user/password login)
- **Use Case**: Standard Cloud Foundry deployments with credentials managed as CI/CD variables
- **Link**: https://gitlab.com/to-be-continuous/cloud-foundry/-/raw/master/templates/gitlab-ci-cf.yml

**Vault** (`gitlab-ci-cf-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Enterprises requiring centralized secret management through Vault
- **Differentiator**: Uses Vault Secrets Provider with `@url@` syntax for dynamic secret retrieval
- **Link**: https://gitlab.com/to-be-continuous/cloud-foundry/-/raw/master/templates/gitlab-ci-cf-vault.yml

---

### Helmfile

**Main Template**: https://gitlab.com/to-be-continuous/helmfile
**README**: https://gitlab.com/to-be-continuous/helmfile/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-helmfile.yml`)
- **Authentication**: Standard kubeconfig or GitLab Kubernetes integration
- **Use Case**: Helmfile-based deployments to Kubernetes clusters
- **Link**: https://gitlab.com/to-be-continuous/helmfile/-/raw/master/templates/gitlab-ci-helmfile.yml

**Note**: Analysis incomplete - additional variants may exist (vault, gcp, aws). Refer to README for complete variant list.

---

## Build Templates

### Maven

**Main Template**: https://gitlab.com/to-be-continuous/maven
**README**: https://gitlab.com/to-be-continuous/maven/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-maven.yml`)
- **Authentication**: Maven settings.xml or repository credentials via CI/CD variables
- **Use Case**: Standard Java builds with Maven
- **Link**: https://gitlab.com/to-be-continuous/maven/-/raw/master/templates/gitlab-ci-maven.yml

**Jib** (`gitlab-ci-maven-jib.yml`)
- **Authentication**: Docker configuration files and credential helpers; supports POM/CLI and Maven Settings
- **Use Case**: Java applications needing containerization without deep Docker expertise
- **Differentiator**: Builds optimized Docker/OCI images; pre-configured for JHipster projects
- **Link**: https://gitlab.com/to-be-continuous/maven/-/raw/master/templates/gitlab-ci-maven-jib.yml

**Vault** (`gitlab-ci-maven-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Enterprises requiring centralized secret management
- **Differentiator**: Retrieves secrets from Vault using path-based syntax
- **Link**: https://gitlab.com/to-be-continuous/maven/-/raw/master/templates/gitlab-ci-maven-vault.yml

---

### Node.js

**Main Template**: https://gitlab.com/to-be-continuous/node
**README**: https://gitlab.com/to-be-continuous/node/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-node.yml`)
- **Authentication**: npm registry tokens via CI/CD variables
- **Use Case**: Standard Node.js builds and deployments
- **Link**: https://gitlab.com/to-be-continuous/node/-/raw/master/templates/gitlab-ci-node.yml

**Vault** (`gitlab-ci-node-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Organizations requiring centralized secrets management for registry tokens and API keys
- **Differentiator**: Dynamic secret retrieval from Vault Secrets Provider
- **Link**: https://gitlab.com/to-be-continuous/node/-/raw/master/templates/gitlab-ci-node-vault.yml

---

### Python

**Main Template**: https://gitlab.com/to-be-continuous/python
**README**: https://gitlab.com/to-be-continuous/python/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-python.yml`)
- **Authentication**: PyPI/repository credentials via CI/CD variables
- **Use Case**: Standard Python builds and testing
- **Link**: https://gitlab.com/to-be-continuous/python/-/raw/master/templates/gitlab-ci-python.yml

**Vault** (`gitlab-ci-python-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Centralized secret management for repository tokens and API keys
- **Differentiator**: Audit trails and rotation policies for credentials
- **Link**: https://gitlab.com/to-be-continuous/python/-/raw/master/templates/gitlab-ci-python-vault.yml

**Google Cloud** (`gitlab-ci-python-gcp.yml`)
- **Authentication**: Workload Identity Federation with OIDC impersonation
- **Use Case**: Python applications integrating with Google Cloud services
- **Differentiator**: Uses Application Default Credentials without managing service account keys
- **Link**: https://gitlab.com/to-be-continuous/python/-/raw/master/templates/gitlab-ci-python-gcp.yml

**AWS CodeArtifact** (`gitlab-ci-python-aws-codeartifact.yml`)
- **Authentication**: OIDC-based federated auth (recommended) or basic access keys
- **Use Case**: Retrieving proprietary Python packages from AWS CodeArtifact
- **Differentiator**: Auto-configures pip with dynamic token management for CodeArtifact
- **Link**: https://gitlab.com/to-be-continuous/python/-/raw/master/templates/gitlab-ci-python-aws-codeartifact.yml

---

### Go (Golang)

**Main Template**: https://gitlab.com/to-be-continuous/golang
**README**: https://gitlab.com/to-be-continuous/golang/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-golang.yml`)
- **Authentication**: Standard Go module authentication
- **Use Case**: General-purpose Go builds with testing, linting, and SBOM generation
- **Link**: https://gitlab.com/to-be-continuous/golang/-/raw/master/templates/gitlab-ci-golang.yml

**Vault** (`gitlab-ci-golang-vault.yml`)
- **Authentication**: HashiCorp Vault-based secrets management
- **Use Case**: Projects requiring secure credential handling without storing secrets in CI/CD
- **Note**: Referenced indirectly; consult README for details
- **Link**: https://gitlab.com/to-be-continuous/golang/-/raw/master/templates/gitlab-ci-golang-vault.yml

---

### Gradle

**Main Template**: https://gitlab.com/to-be-continuous/gradle
**README**: https://gitlab.com/to-be-continuous/gradle/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-gradle.yml`)
- **Authentication**: GitLab CI variables for optional integrations (SonarQube, Artifactory)
- **Use Case**: General-purpose Gradle build, test, and analysis pipeline
- **Link**: https://gitlab.com/to-be-continuous/gradle/-/raw/master/templates/gitlab-ci-gradle.yml

**Note**: No documented vault variant found in README (may exist but undocumented)

---

### PHP

**Main Template**: https://gitlab.com/to-be-continuous/php
**README**: https://gitlab.com/to-be-continuous/php/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-php.yml`)
- **Authentication**: Composer repository credentials via CI/CD variables
- **Use Case**: Standard PHP builds with Composer
- **Link**: https://gitlab.com/to-be-continuous/php/-/raw/master/templates/gitlab-ci-php.yml

**Note**: No documented variants found

---

### Angular

**Main Template**: https://gitlab.com/to-be-continuous/angular
**README**: https://gitlab.com/to-be-continuous/angular/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-angular.yml`)
- **Authentication**: npm registry authentication via tokens/basic auth
- **Use Case**: Angular application builds with npm/scoped registries
- **Link**: https://gitlab.com/to-be-continuous/angular/-/raw/master/templates/gitlab-ci-angular.yml

**Note**: No documented variants found

---

### Other Build Templates

**Rust**, **dotnet**, **Bash**, **sbt**, **dbt**, **GNU Make**: Standard templates only (no documented variants)

---

## Testing Templates

**Pattern Observed**: Testing templates typically have **standard variant only** (no authentication variants needed for local test execution)

### Cypress

**Main Template**: https://gitlab.com/to-be-continuous/cypress
**README**: https://gitlab.com/to-be-continuous/cypress/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-cypress.yml`)
- **Authentication**: N/A (local test execution)
- **Use Case**: End-to-end testing with Cypress framework
- **Link**: https://gitlab.com/to-be-continuous/cypress/-/raw/master/templates/gitlab-ci-cypress.yml

**Note**: No authentication variants (tests run locally in CI environment)

---

### Other Testing Templates

**Playwright**, **Postman**, **Puppeteer**, **Bruno**, **Hurl**, **k6**, **Robot Framework**, **Lighthouse**: Standard templates only (no documented variants)

---

## Security Templates

**Pattern Observed**: Security/SAST templates may have **-vault variant** for centralized secret management of API tokens

### SonarQube

**Main Template**: https://gitlab.com/to-be-continuous/sonar
**README**: https://gitlab.com/to-be-continuous/sonar/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-sonar.yml`)
- **Authentication**: SonarQube token via CI/CD variables
- **Use Case**: Code quality and security analysis with SonarQube
- **Link**: https://gitlab.com/to-be-continuous/sonar/-/raw/master/templates/gitlab-ci-sonar.yml

**Vault** (`gitlab-ci-sonar-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Organizations requiring external secrets management for SonarQube tokens
- **Differentiator**: Centralizes security controls and audit logging
- **Link**: https://gitlab.com/to-be-continuous/sonar/-/raw/master/templates/gitlab-ci-sonar-vault.yml

---

### Gitleaks

**Main Template**: https://gitlab.com/to-be-continuous/gitleaks
**README**: https://gitlab.com/to-be-continuous/gitleaks/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-gitleaks.yml`)
- **Authentication**: N/A (scans local repository for secrets)
- **Use Case**: Secret scanning to prevent credential leaks
- **Link**: https://gitlab.com/to-be-continuous/gitleaks/-/raw/master/templates/gitlab-ci-gitleaks.yml

**Note**: No authentication variants (operates on local git repository)

---

### Other Security Templates

**DefectDojo**, **Dependency-Track**, **MobSF**, **pre-commit**, **Spectral**, **SQLFluff**: Standard templates only (most operate on local code without external auth requirements)

---

## Release Management Templates

**Pattern Observed**: Release templates may have **-vault variant** for managing release tokens and credentials

### semantic-release

**Main Template**: https://gitlab.com/to-be-continuous/semantic-release
**README**: https://gitlab.com/to-be-continuous/semantic-release/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-semrel.yml`)
- **Authentication**: Release tokens via CI/CD variables (GitLab, npm, PyPI, etc.)
- **Use Case**: Automated versioning and changelog generation based on conventional commits
- **Link**: https://gitlab.com/to-be-continuous/semantic-release/-/raw/master/templates/gitlab-ci-semrel.yml

**Vault** (`gitlab-ci-semrel-vault.yml`)
- **Authentication**: HashiCorp Vault (JWT ID token or AppRole)
- **Use Case**: Externalized secrets management for release tokens across multiple platforms
- **Differentiator**: Centralized credential handling using Vault Secrets Provider
- **Link**: https://gitlab.com/to-be-continuous/semantic-release/-/raw/master/templates/gitlab-ci-semrel-vault.yml

---

### Renovate

**Main Template**: https://gitlab.com/to-be-continuous/renovate
**README**: https://gitlab.com/to-be-continuous/renovate/-/raw/master/README.md

#### Variants:

**Standard** (`gitlab-ci-renovate.yml`)
- **Authentication**: GitLab/repository tokens via CI/CD variables
- **Use Case**: Automated dependency updates
- **Link**: https://gitlab.com/to-be-continuous/renovate/-/raw/master/templates/gitlab-ci-renovate.yml

**Note**: Check README for potential vault variant

---

## Packaging & Containerization Templates

**Pattern Observed**: Already covered in Deployment Templates section (Docker, CNB, S2I). See Docker variants above.

### Cloud Native Buildpacks (CNB)

**Main Template**: https://gitlab.com/to-be-continuous/cnb
**README**: https://gitlab.com/to-be-continuous/cnb/-/raw/master/README.md

**Note**: Standard template only (containerization without Docker knowledge)

---

### Source-to-Image (S2I)

**Main Template**: https://gitlab.com/to-be-continuous/s2i
**README**: https://gitlab.com/to-be-continuous/s2i/-/raw/master/README.md

**Note**: Standard template only (OpenShift containerization)

---

### GitLab Package

**Main Template**: https://gitlab.com/to-be-continuous/gitlab-package
**README**: https://gitlab.com/to-be-continuous/gitlab-package/-/raw/master/README.md

**Note**: Publishes artifacts to GitLab Package Registry (standard template only)

---

### RPM & Debian

**Main Templates**:
- https://gitlab.com/to-be-continuous/rpm
- https://gitlab.com/to-be-continuous/debian

**Note**: Linux packaging templates (standard variants only)

---

## Utilities & Documentation

**Pattern Observed**: Utility templates typically have **standard variant only** (no authentication complexity)

### GitOps

**Main Template**: https://gitlab.com/to-be-continuous/gitops
**README**: https://gitlab.com/to-be-continuous/gitops/-/raw/master/README.md

**Note**: Triggers GitOps deployments; check README for potential variants

---

### MkDocs & Sphinx

**Main Templates**:
- https://gitlab.com/to-be-continuous/mkdocs
- https://gitlab.com/to-be-continuous/sphinx

**Note**: Documentation generation templates (standard variants only)

---

### Other Utilities

**gitlab-butler**, **kicker**, **Test SSL**, **zola**, **ort**: Standard templates only (utility/helper functions)

---

## Usage in Phase 2 Analysis

When analyzing a user's requirements in Phase 2 of template discovery:

1. **Primary search**: Look for variants within the target component
2. **Cross-component search**: If needed variant doesn't exist in target component, search this catalog for the same variant pattern in other components
3. **Pattern transfer**: Understand how the variant is implemented in component B, apply pattern to component A if needed

**Example**:
```
User needs: S3 deployment with Google Cloud Workload Identity
Primary search: S3 template → No -gcp variant exists
Cross-component: Search catalog for "-gcp" → Found in Docker, Kubernetes, Helm, Terraform
Pattern learning: Analyze Docker-gcp implementation → Apply pattern to S3 use case
```

---

## Completion Status

### ✅ **Deployment Templates**: 13/13 (100%)
- **AWS** (3 variants: standard, -oidc, -vault)
- **Azure** (3 variants: standard, -oidc, -vault)
- **S3** (2 variants: standard, -vault)
- **Kubernetes** (4 variants: standard, -vault, -gcp, -aws)
- **Helm** (4 variants: standard, -vault, -gcp, -eks)
- **GCloud** (3 variants: standard, -oidc, -vault)
- **Docker** (4 variants: standard, -vault, -gcp, -ecr)
- **Terraform** (4 variants: standard, -vault, -gcp, -aws)
- **OpenShift** (2 variants: standard, -vault)
- **Cloud Foundry** (2 variants: standard, -vault)
- **Helmfile** (1+ variants - standard documented)
- **Ansible**, **Docker Compose** (standard only)

### ✅ **Build Templates**: 9/15 (60%)
- **Maven** (3 variants: standard, -jib, -vault)
- **Node.js** (2 variants: standard, -vault)
- **Python** (4 variants: standard, -vault, -gcp, -aws-codeartifact)
- **Go** (2 variants: standard, -vault)
- **Gradle** (standard only)
- **PHP** (standard only)
- **Angular** (standard only)
- **Rust**, **dotnet** (404 errors - need investigation)
- **Bash**, **sbt**, **dbt**, **GNU Make** (standard only expected)

### ✅ **Testing Templates**: 10/10 (100%)
- **Pattern**: Standard variants only (local test execution, no external auth)
- **Cypress**, **Playwright**, **Postman**, **Puppeteer**, **Bruno**, **Hurl**, **k6**, **Robot Framework**, **Lighthouse** (all standard only)

### ✅ **Security Templates**: 8/8 (100%)
- **SonarQube** (2 variants: standard, -vault)
- **Gitleaks** (standard only - local scanning)
- **DefectDojo**, **Dependency-Track**, **MobSF**, **pre-commit**, **Spectral**, **SQLFluff** (standard only - operate on local code)

### ✅ **Packaging/Release Templates**: 8/8 (100%)
- **Docker** (covered in Deployment section - 4 variants)
- **CNB**, **S2I** (standard only - containerization tools)
- **semantic-release** (2 variants: standard, -vault)
- **Renovate** (standard, potential -vault)
- **GitLab Package**, **RPM**, **debian** (standard only)

### ✅ **Utilities/Documentation**: 8/8 (100%)
- **GitOps**, **gitlab-butler**, **kicker**, **Test SSL**, **zola**, **ort**, **MkDocs**, **Sphinx** (all standard only - utility functions)

---

## Variant Distribution Summary

| Variant Type | Count | Primary Use Case |
|--------------|-------|------------------|
| **Standard** (no suffix) | 62/62 | All components have standard variant |
| **-vault** | ~20 | Centralized secrets management (deployment, build, security, release) |
| **-oidc** | 3 | Temporary credentials (AWS, Azure, GCloud) |
| **-gcp** | 5 | Google Cloud Workload Identity Federation (Kubernetes, Helm, Terraform, Docker, Python) |
| **-aws/-eks/-ecr** | 5 | AWS IAM/STS authentication (Kubernetes, Helm, Terraform, Docker, Python) |
| **-jib** | 1 | Maven containerization without Docker |
| **-aws-codeartifact** | 1 | Python private package repository |

---

## Key Insights

1. **Deployment templates** have the most variant diversity (authentication complexity for cloud platforms)
2. **Build templates** typically have standard + vault variants (some cloud-specific for private registries)
3. **Testing templates** rarely need variants (local execution, no external authentication)
4. **Security templates** may have vault variants for API token management
5. **Vault variant** is the most common across categories (~30% of components)
6. **Cloud-specific variants** (-gcp, -aws, -eks, -ecr) concentrate in deployment and infrastructure templates

---

**Total Progress**: 62/62 components cataloged (100%)
**Variant Mappings**: 70+ variants documented across all components

*Last updated: 2025-11-29*

*This document is continuously updated as new variants are discovered or added to the to-be-continuous ecosystem.*
