# AWS CLI Component

Complete AWS CLI component for executing AWS operations in GitLab CI/CD pipelines with support for role assumption and OIDC authentication.

## Overview

This component provides a robust, production-ready solution for executing AWS CLI commands in GitLab pipelines. It supports both traditional credential-based authentication and modern OIDC-based authentication for enhanced security.

**Key features:**
- ✅ Role assumption with configurable duration
- ✅ OIDC authentication for temporary credentials (no long-lived secrets)
- ✅ Environment-specific role ARNs (review, staging, production)
- ✅ Script execution from files or inline commands
- ✅ Extensible output system via dotenv artifacts
- ✅ Multi-distro support (Debian, RHEL, Alpine)
- ✅ Debug mode and additional tool installation

## Variants

### Standard Variant

**File**: `templates/gitlab-ci-awscli.yml`

**Authentication**: AWS access keys via CI/CD variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)

**Use Case**: Simple deployments with basic secret management, or when OIDC is not available

**Example**:
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli@1.0.0
    inputs:
      aws-region: "us-west-2"
      role-arn: "arn:aws:iam::123456789012:role/GitLabCI"
      script-inline: |
        aws s3 sync ./dist s3://my-bucket/
        aws cloudfront create-invalidation --distribution-id E1234567890 --paths "/*"
```

### OIDC Variant (Recommended)

**File**: `templates/gitlab-ci-awscli-oidc.yml`

**Authentication**: OpenID Connect for temporary credentials via GitLab JWT tokens

**Use Case**: Enhanced security without long-lived credentials, supports environment-specific roles

**Example**:
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      aws-region: "us-west-2"
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-Default"
      production-oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-Production"
      script-file: "./scripts/deploy-to-aws.sh"
```

## Inputs

### Common Inputs (Both Variants)

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `cli-image` | string | `amazon/aws-cli:latest` | Docker image containing AWS CLI |
| `aws-region` | string | `us-east-1` | AWS region for operations |
| `script-file` | string | `""` | Path to AWS CLI script to execute |
| `script-inline` | string | `""` | Inline AWS CLI commands (alternative to script-file) |
| `export-outputs` | boolean | `true` | Export outputs to dotenv artifact |
| `debug-mode` | boolean | `false` | Enable AWS CLI debug output |
| `install-extras` | string | `""` | Space-separated list of tools to install (e.g., `jq yq`) |

### Standard Variant Inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `role-arn` | string | `""` | IAM role ARN to assume (optional) |
| `role-session-name` | string | `gitlab-ci-${CI_PROJECT_NAME}-${CI_PIPELINE_ID}` | Session name when assuming role |
| `role-duration` | number | `3600` | Duration in seconds for credentials (900-43200) |

### OIDC Variant Inputs

| Input | Type | Default | Description |
|-------|------|---------|-------------|
| `oidc-aud` | string | `$CI_SERVER_URL` | OIDC audience claim |
| `oidc-role-arn` | string | **(required)** | Default IAM role ARN to assume via OIDC |
| `review-oidc-role-arn` | string | `""` | Role ARN for review environments (overrides default) |
| `integration-oidc-role-arn` | string | `""` | Role ARN for integration environment |
| `staging-oidc-role-arn` | string | `""` | Role ARN for staging environment |
| `production-oidc-role-arn` | string | `""` | Role ARN for production environment |
| `role-session-name` | string | `gitlab-ci-${CI_PROJECT_NAME}-${CI_PIPELINE_ID}` | Session name when assuming role |
| `role-duration` | number | `3600` | Duration in seconds for credentials (900-43200) |
| `external-id` | string | `""` | External ID for additional security (optional) |

## Jobs

### `awscli-execute`

**Stage**: `deploy`

**Purpose**: Execute AWS CLI commands with optional role assumption

**Behavior**:
1. Installs additional tools if specified (`install-extras`)
2. Authenticates to AWS (standard: verifies credentials, OIDC: assumes role with JWT)
3. Assumes additional role if `role-arn` specified (standard variant)
4. Executes script from `script-file` or `script-inline`
5. Exports outputs to `awscli.env` artifact

**Output Variables**:
- `awscli_region`: AWS region used
- `awscli_executed_at`: Timestamp of execution (ISO 8601 UTC)
- `awscli_assumed_role`: Role ARN that was assumed (if applicable)
- `awscli_auth_method`: Authentication method (`oidc` for OIDC variant)
- `awscli_environment`: Environment name (OIDC variant)
- Custom outputs from `awscli-custom.env` (see below)

## Usage Examples

### Example 1: Deploy to S3 with CloudFront Invalidation

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      aws-region: "us-east-1"
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI"
      script-inline: |
        # Sync build artifacts to S3
        aws s3 sync ./dist s3://my-website-bucket/ --delete

        # Invalidate CloudFront cache
        aws cloudfront create-invalidation \
          --distribution-id E1234567890ABC \
          --paths "/*"

        # Export custom output
        echo "website_url=https://my-website.example.com" > awscli-custom.env
```

### Example 2: Multi-Environment Deployment with Script File

**`.gitlab-ci.yml`**:
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      aws-region: "eu-west-1"
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-Dev"
      staging-oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-Staging"
      production-oidc-role-arn: "arn:aws:iam::987654321098:role/GitLabCI-Prod"
      script-file: "./scripts/deploy.sh"
      install-extras: "jq"
```

**`scripts/deploy.sh`**:
```bash
#!/bin/bash
set -euo pipefail

# Get current caller identity
CALLER_IDENTITY=$(aws sts get-caller-identity)
echo "Deploying as: $(echo $CALLER_IDENTITY | jq -r .Arn)"

# Deploy CloudFormation stack
aws cloudformation deploy \
  --template-file template.yaml \
  --stack-name my-app-${CI_ENVIRONMENT_NAME} \
  --parameter-overrides \
    Environment=${CI_ENVIRONMENT_NAME} \
    Version=${CI_COMMIT_SHORT_SHA} \
  --capabilities CAPABILITY_IAM \
  --no-fail-on-empty-changeset

# Get stack outputs
STACK_OUTPUTS=$(aws cloudformation describe-stacks \
  --stack-name my-app-${CI_ENVIRONMENT_NAME} \
  --query 'Stacks[0].Outputs' \
  --output json)

# Export API URL to downstream jobs
API_URL=$(echo $STACK_OUTPUTS | jq -r '.[] | select(.OutputKey=="ApiUrl") | .OutputValue')
echo "api_url=${API_URL}" > awscli-custom.env
```

### Example 3: ECS Task Deployment

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      aws-region: "ap-southeast-1"
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-ECS"
      script-inline: |
        # Update ECS task definition
        TASK_DEFINITION=$(aws ecs describe-task-definition \
          --task-definition my-app \
          --query 'taskDefinition' \
          --output json)

        # Update image in task definition
        NEW_TASK_DEF=$(echo $TASK_DEFINITION | jq \
          --arg IMAGE "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" \
          '.containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities, .registeredAt, .registeredBy)')

        # Register new task definition
        NEW_TASK_ARN=$(aws ecs register-task-definition \
          --cli-input-json "$NEW_TASK_DEF" \
          --query 'taskDefinition.taskDefinitionArn' \
          --output text)

        # Update ECS service
        aws ecs update-service \
          --cluster my-cluster \
          --service my-service \
          --task-definition $NEW_TASK_ARN \
          --force-new-deployment

        # Wait for service stability
        aws ecs wait services-stable \
          --cluster my-cluster \
          --services my-service
```

### Example 4: Lambda Function Deployment

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      aws-region: "us-west-2"
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-Lambda"
      script-inline: |
        # Package Lambda function
        zip -r function.zip . -x "*.git*" "*.gitlab-ci.yml"

        # Update Lambda function code
        aws lambda update-function-code \
          --function-name my-function \
          --zip-file fileb://function.zip

        # Wait for update to complete
        aws lambda wait function-updated \
          --function-name my-function

        # Publish new version
        VERSION=$(aws lambda publish-version \
          --function-name my-function \
          --description "Deployed from GitLab CI: ${CI_COMMIT_SHORT_SHA}" \
          --query 'Version' \
          --output text)

        # Update alias to point to new version
        aws lambda update-alias \
          --function-name my-function \
          --name live \
          --function-version $VERSION

        # Export version to downstream jobs
        echo "lambda_version=${VERSION}" > awscli-custom.env
```

### Example 5: RDS Snapshot and Restore

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      aws-region: "eu-central-1"
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-RDS"
      script-inline: |
        DB_INSTANCE="my-database"
        SNAPSHOT_ID="${DB_INSTANCE}-${CI_COMMIT_SHORT_SHA}-$(date +%Y%m%d-%H%M%S)"

        # Create RDS snapshot
        aws rds create-db-snapshot \
          --db-instance-identifier $DB_INSTANCE \
          --db-snapshot-identifier $SNAPSHOT_ID

        # Wait for snapshot to complete
        aws rds wait db-snapshot-completed \
          --db-snapshot-identifier $SNAPSHOT_ID

        echo "Database snapshot created: $SNAPSHOT_ID"
        echo "rds_snapshot_id=${SNAPSHOT_ID}" > awscli-custom.env
```

## AWS IAM Configuration

### Standard Variant: IAM User Setup

**Create IAM user**:
```bash
aws iam create-user --user-name gitlab-ci
```

**Attach policies** (principle of least privilege):
```bash
aws iam attach-user-policy \
  --user-name gitlab-ci \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

**Create access keys**:
```bash
aws iam create-access-key --user-name gitlab-ci
```

**Add to GitLab CI/CD variables**:
- `AWS_ACCESS_KEY_ID`: Access key ID
- `AWS_SECRET_ACCESS_KEY`: Secret access key (masked)

### OIDC Variant: IAM Role Setup

**Step 1: Create OIDC Provider** (one-time setup per GitLab instance):

```bash
# Get GitLab's OIDC thumbprint
THUMBPRINT=$(echo | openssl s_client -servername gitlab.example.com \
  -connect gitlab.example.com:443 2>/dev/null | openssl x509 -fingerprint -noout | \
  cut -d'=' -f2 | tr -d ':' | tr '[:upper:]' '[:lower:]')

# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://gitlab.example.com \
  --client-id-list https://gitlab.example.com \
  --thumbprint-list $THUMBPRINT
```

**Step 2: Create IAM Role with Trust Policy**:

**`trust-policy.json`**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/gitlab.example.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "gitlab.example.com:aud": "https://gitlab.example.com"
        },
        "StringLike": {
          "gitlab.example.com:sub": "project_path:mygroup/myproject:ref_type:branch:ref:main"
        }
      }
    }
  ]
}
```

**Create role**:
```bash
aws iam create-role \
  --role-name GitLabCI-OIDC \
  --assume-role-policy-document file://trust-policy.json
```

**Step 3: Attach Permissions**:

```bash
# Attach managed policy
aws iam attach-role-policy \
  --role-name GitLabCI-OIDC \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Or create custom policy
aws iam put-role-policy \
  --role-name GitLabCI-OIDC \
  --policy-name CustomPermissions \
  --policy-document file://permissions-policy.json
```

**Trust Policy Condition Examples**:

```json
// Allow specific project
"gitlab.example.com:sub": "project_path:mygroup/myproject:*"

// Allow specific branch
"gitlab.example.com:sub": "project_path:mygroup/myproject:ref_type:branch:ref:main"

// Allow any tag
"gitlab.example.com:sub": "project_path:mygroup/myproject:ref_type:tag:ref:*"

// Allow entire group
"gitlab.example.com:sub": "project_path:mygroup/*:*"

// Production environment only
"gitlab.example.com:sub": "project_path:mygroup/myproject:*",
"gitlab.example.com:environment": "production"
```

## Integration with Other Components

### Downstream Usage of Outputs

The component exports variables via dotenv artifacts that can be consumed by downstream jobs:

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI"
      script-inline: |
        # Deploy and capture outputs
        echo "api_url=https://api.example.com" > awscli-custom.env
        echo "database_endpoint=db.example.com:5432" >> awscli-custom.env

smoke-tests:
  stage: test
  image: curlimages/curl:latest
  needs:
    - awscli-execute
  script:
    - echo "Testing API at ${api_url}"
    - curl -f "${api_url}/health"
    - echo "Database endpoint: ${database_endpoint}"
```

### Chaining with Docker Component

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/docker/gitlab-ci-docker-ecr@1.0.0
    inputs:
      ecr-registry: "123456789012.dkr.ecr.us-west-2.amazonaws.com"
      image-name: "my-app"

  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI-ECS"
      script-inline: |
        # Use the docker_image variable from docker component
        aws ecs update-service \
          --cluster my-cluster \
          --service my-service \
          --force-new-deployment \
          --task-definition my-task
```

## Extending the Base Job

Users can extend `.awscli-base` (standard) or `.awscli-oidc-base` (OIDC) to customize behavior:

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI"

# Override base job for custom needs
.awscli-oidc-base:
  tags:
    - kubernetes  # Use different runner
  variables:
    http_proxy: "http://proxy.example.com:8080"  # Add proxy
  after_script:
    - echo "Cleanup actions here"

# Create custom job extending base
deploy-custom:
  extends: .awscli-oidc-base
  stage: deploy
  script:
    - aws s3 cp file.txt s3://my-bucket/
  environment:
    name: production
```

## Troubleshooting

### Authentication Issues (Standard Variant)

**Error**: `Unable to locate credentials`

**Solution**: Ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are set in GitLab CI/CD variables.

**Error**: `The security token included in the request is invalid`

**Solution**: Regenerate access keys or verify the IAM user exists.

### Authentication Issues (OIDC Variant)

**Error**: `An error occurred (InvalidIdentityToken) when calling the AssumeRoleWithWebIdentity operation`

**Solution**:
1. Verify OIDC provider is configured in AWS IAM
2. Check trust policy conditions match your GitLab project/branch
3. Ensure `oidc-aud` matches the audience in trust policy

**Error**: `OIDC JWT token not found (AWS_JWT variable)`

**Solution**: Ensure GitLab version supports OIDC (GitLab 15.7+) and `id_tokens` is properly configured in the job.

### Role Assumption Issues

**Error**: `An error occurred (AccessDenied) when calling the AssumeRole operation: User: ... is not authorized to perform: sts:AssumeRole on resource: ...`

**Solution**:
1. Verify the IAM user/role has `sts:AssumeRole` permission
2. Check the target role's trust policy allows the source identity
3. If using external ID, ensure it matches

**Error**: `Value for parameter durationSeconds out of range`

**Solution**: Adjust `role-duration` to be between 900 and 43200 seconds (15 minutes to 12 hours). Some roles have maximum session durations configured in IAM.

### Script Execution Issues

**Error**: `Script file not found`

**Solution**: Verify `script-file` path is relative to repository root and the file exists.

**Error**: Script fails with `command not found`

**Solution**: Install required tools using `install-extras` input (e.g., `install-extras: "jq curl"`).

### Debug Mode

Enable debug mode to see detailed AWS CLI output:

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      debug-mode: true
      oidc-role-arn: "arn:aws:iam::123456789012:role/GitLabCI"
```

## Best Practices

### Security

1. **Use OIDC variant when possible**: Eliminates long-lived credentials
2. **Principle of least privilege**: Grant only necessary IAM permissions
3. **Environment-specific roles**: Use different roles for staging vs production
4. **External ID**: Add `external-id` for additional security layer when assuming roles
5. **Audit logging**: Enable AWS CloudTrail to track all API calls

### Performance

1. **Role duration**: Set appropriate `role-duration` based on job length to avoid re-authentication
2. **Install extras selectively**: Only install tools you actually need via `install-extras`
3. **Cache AWS CLI**: Use Docker image with pre-installed tools to speed up jobs

### Maintainability

1. **Script files over inline**: Use `script-file` for complex operations to enable versioning and testing
2. **Export outputs**: Use `awscli-custom.env` to pass data to downstream jobs
3. **Error handling**: Always use `set -euo pipefail` in bash scripts
4. **Idempotency**: Design scripts to be safely re-runnable (use `--no-fail-on-empty-changeset` for CloudFormation)

## Variables Reference

### Environment Variables Set by Component

| Variable | Description | Example |
|----------|-------------|---------|
| `AWS_DEFAULT_REGION` | AWS region for operations | `us-west-2` |
| `AWS_REGION` | AWS region (alias) | `us-west-2` |
| `AWS_ACCESS_KEY_ID` | AWS access key (after role assumption) | `ASIA...` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key (after role assumption) | `***` |
| `AWS_SESSION_TOKEN` | Session token (after role assumption) | `***` |
| `AWS_DEBUG` | Debug mode flag | `1` (if enabled) |

### Environment Variables Consumed from CI/CD

**Standard variant** requires:
- `AWS_ACCESS_KEY_ID`: IAM user access key
- `AWS_SECRET_ACCESS_KEY`: IAM user secret key

**OIDC variant** requires:
- No external variables (credentials obtained via OIDC)

**Optional for both**:
- `http_proxy`, `https_proxy`: Proxy configuration
- `AWS_CA_BUNDLE`: Custom CA bundle path

## Migration from Standard to OIDC

**Step 1: Set up OIDC provider in AWS** (see IAM Configuration section)

**Step 2: Update `.gitlab-ci.yml`**:

**Before** (standard):
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli@1.0.0
    inputs:
      role-arn: "arn:aws:iam::123456789012:role/MyRole"
      script-file: "./deploy.sh"
```

**After** (OIDC):
```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/awscli/gitlab-ci-awscli-oidc@1.0.0
    inputs:
      oidc-role-arn: "arn:aws:iam::123456789012:role/MyRole"
      script-file: "./deploy.sh"
```

**Step 3: Remove CI/CD variables**:
- Delete `AWS_ACCESS_KEY_ID`
- Delete `AWS_SECRET_ACCESS_KEY`

**Step 4: Test in non-production** before rolling out to production pipelines.

## License

MIT License - see [LICENSE](LICENSE) file

## Contributing

Contributions welcome! Please follow to-be-continuous contribution guidelines:
1. Discuss on Discord: topic `awscli component: <your-idea>`
2. Fork and create branch from `main`
3. Follow semantic commit conventions
4. Include tests and documentation
5. Submit MR with clear description

## Support

- **Documentation**: https://to-be-continuous.gitlab.io/doc/ref/awscli
- **Issues**: https://gitlab.com/to-be-continuous/awscli/-/issues
- **Discord**: https://discord.gg/to-be-continuous
- **Examples**: See `samples/` directory

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.