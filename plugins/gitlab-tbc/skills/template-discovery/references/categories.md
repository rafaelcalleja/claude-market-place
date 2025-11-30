# Template Categories

This document categorizes to-be-continuous templates by function and technology.

## By Function

### Build & Compile
- **Angular** - Angular applications
- **Bash** - Shell scripts
- **dbt** - Data build tool
- **debian** - Debian packages
- **dotnet** - .NET applications
- **Go** - Go applications
- **Gradle** - Gradle builds
- **GNU Make** - Make builds
- **Maven** - Maven builds
- **MkDocs** - MkDocs documentation
- **Node.js** - Node.js applications
- **PHP** - PHP applications
- **Python** - Python applications
- **RPM** - RPM packages
- **Rust** - Rust applications
- **sbt** - Scala sbt builds
- **Sphinx** - Sphinx documentation
- **Zola** - Zola static sites

### Containerization & Packaging
- **Docker** - Container images (kaniko, Buildah, Docker)
- **Cloud Native Buildpacks** - CNB packaging
- **Source-to-Image** - S2I packaging

### Testing
- **Bruno** - Bruno API testing
- **Cypress** - Cypress E2E testing
- **Hurl** - Hurl API testing
- **k6** - k6 load testing
- **Lighthouse** - Lighthouse performance testing
- **Playwright** - Playwright testing
- **Postman** - Postman API testing
- **Puppeteer** - Puppeteer testing
- **Robot Framework** - Robot Framework testing
- **UUV** - Accessibility testing (WIP)

### Security & Quality (SAST/DAST)
- **DefectDojo** - Security vulnerability management
- **Dependency-Track** - Dependency analysis
- **Gitleaks** - Secret scanning
- **MobSF** - Mobile security
- **ort** - Open source compliance
- **pre-commit** - Pre-commit hooks
- **SonarQube** - Code quality and security
- **Spectral** - API linting
- **SQLFluff** - SQL linting
- **Test SSL** - TLS/SSL testing
- **zap** - OWASP ZAP DAST (WIP)

### Deployment
- **Amazon Web Services** - AWS deployment
- **Ansible** - Ansible automation
- **Azure** - Azure deployment
- **Cloud Foundry** - Cloud Foundry PaaS
- **Docker Compose** - Docker Compose deployment
- **Google Cloud Platform** - GCP deployment
- **GitOps** - GitOps workflows
- **Helm** - Helm charts
- **Helmfile** - Helmfile deployment
- **Kubernetes** - Kubernetes deployment
- **OpenShift** - OpenShift deployment
- **S3** - S3 static hosting
- **Terraform** - Infrastructure as Code

### Release & Dependency Management
- **GitLab Package** - GitLab package registry
- **Renovate** - Automated dependency updates
- **semantic-release** - Semantic versioning and releases

### Utilities
- **gitlab-butler** - GitLab group management
- **kicker** - .gitlab-ci.yml wizard

## By Technology Stack

### Python Stack
**Core:**
- Python (build, test)
- SonarQube (quality)
- Gitleaks (secrets)

**Deployment Options:**
- Docker + Kubernetes
- Docker + Helm
- AWS Lambda (serverless)
- Azure
- Cloud Foundry

**Testing:**
- pytest (built-in)
- Postman (API)
- Bruno (API)
- Hurl (API)

**Related Samples:**
- python-on-kubernetes
- python-serverless-on-aws
- python-on-azure
- python-docker-compose
- python-helmfile-on-kubernetes
- python-library

### Node.js/JavaScript Stack
**Core:**
- Node.js (build, test)
- Angular (if using Angular)

**Deployment:**
- Docker + Kubernetes
- S3 (static sites)
- OpenShift

**Testing:**
- Cypress
- Playwright
- Puppeteer
- Lighthouse

**Related Samples:**
- angular-on-s3
- svelte-on-s3
- node-on-openshift

### Java/JVM Stack
**Core:**
- Maven (Java)
- Gradle (Java/Kotlin)
- sbt (Scala)

**Quality:**
- SonarQube

**Deployment:**
- Docker + Kubernetes
- OpenShift (S2I)
- Cloud Foundry
- GCP App Engine

**Related Samples:**
- maven-on-kubernetes
- maven-on-openshift
- maven-on-gcloud
- maven-library

### Go Stack
**Core:**
- Go (build, test)
- SonarQube

**Packaging:**
- Docker
- Cloud Native Buildpacks

**Deployment:**
- Kubernetes
- Helm
- AWS ECS
- Cloud Foundry

**Related Samples:**
- golang-docker-on-aws
- golang-cnb-on-kubernetes
- golang-cnb-helm-on-kubernetes
- golang-on-cloudfoundry

### PHP Stack
**Core:**
- PHP (build, test)
- SonarQube

**Deployment:**
- Docker + Kubernetes
- Cloud Native Buildpacks

**Related Samples:**
- php-on-kubernetes
- php-cnb-on-kubernetes

### .NET Stack
**Core:**
- dotnet (build, test)

**Related Samples:**
- dotnet-sample

### Infrastructure as Code
**Terraform:**
- Terraform template
- Ansible (for provisioning)

**Related Samples:**
- terraform-ansible-on-aws

### DevOps/Shell
**Core:**
- Bash (shell scripts)
- GNU Make

**Related Samples:**
- bash-sample
- freepascal-make-helm

## Common Combinations

### Full-Stack Application
```
1. Build: python/node/maven
2. Quality: sonarqube + gitleaks
3. Package: docker or cnb
4. Deploy: kubernetes/helm or aws/gcp/azure
5. Test: postman/bruno (API) + cypress/playwright (E2E)
6. Release: semantic-release
```

### Static Site/Documentation
```
1. Build: mkdocs/sphinx/zola
2. Deploy: s3
3. Quality: lighthouse (performance)
```

### Serverless Application
```
1. Build: python/node
2. Quality: sonarqube
3. Deploy: aws (lambda)
4. Test: postman/hurl
```

### Microservices
```
1. Build: go/java/python
2. Quality: sonarqube + dependency-track
3. Package: docker or cnb
4. Deploy: kubernetes + helm/helmfile
5. Orchestration: gitops
```

## By Cloud Provider

### AWS
- Amazon Web Services template
- Terraform (with AWS)
- Related samples: golang-docker-on-aws, cloudformation-on-aws, python-serverless-on-aws, terraform-ansible-on-aws

### Azure
- Azure template
- Related samples: python-on-azure

### GCP
- Google Cloud Platform template
- Related samples: maven-on-gcloud, python-with-gcp-wif

### Multi-Cloud/Platform-Agnostic
- Kubernetes
- Helm
- Helmfile
- Docker
- Cloud Foundry
- OpenShift

## Template Compatibility Matrix

### Works Well Together
✅ Python + SonarQube + Docker + Kubernetes
✅ Node.js + Cypress + S3
✅ Maven + SonarQube + Docker + Helm
✅ Go + CNB + Kubernetes
✅ Any build template + semantic-release
✅ Any build template + Renovate

### Mutually Exclusive (Choose One)
⚠️ Docker vs CNB vs S2I (packaging methods)
⚠️ Kubernetes vs Helm vs Helmfile (K8s deployment methods)
⚠️ AWS vs Azure vs GCP (cloud providers - can combine but not typical)

### Language-Specific (Don't Mix)
❌ Don't combine multiple language build templates (python + node + maven)
   → Use monorepo strategy or separate pipelines
