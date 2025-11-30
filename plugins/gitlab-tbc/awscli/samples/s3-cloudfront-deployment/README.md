# Sample Project: S3 + CloudFront Deployment

This sample project demonstrates how to use the AWS CLI component to deploy a static website to Amazon S3 with CloudFront CDN integration.

## Overview

This example showcases:
- ✅ **OIDC authentication** for secure, keyless AWS access
- ✅ **Environment-specific deployments** (staging vs production)
- ✅ **Optimized S3 sync** with appropriate cache headers
- ✅ **CloudFront invalidation** for immediate content updates
- ✅ **Output propagation** to downstream verification jobs
- ✅ **Review environment cleanup** for ephemeral deployments

## Architecture

```
┌─────────────┐
│   GitLab    │
│   Pipeline  │
└──────┬──────┘
       │
       │ 1. Build static site
       │
       ▼
┌─────────────────┐
│  Build Artifacts│
│   (dist/)       │
└──────┬──────────┘
       │
       │ 2. OIDC Authentication
       │    (JWT → STS temporary credentials)
       │
       ▼
┌─────────────────┐
│   AWS CLI       │
│   Component     │
└──────┬──────────┘
       │
       ├─── 3a. S3 Sync ────────────┐
       │                            ▼
       │                    ┌───────────────┐
       │                    │   S3 Bucket   │
       │                    │  (Static Site)│
       │                    └───────┬───────┘
       │                            │
       └─── 3b. CloudFront ─────────┼────────┐
            Invalidation            │        │
                                    ▼        ▼
                            ┌─────────────────────┐
                            │  CloudFront CDN     │
                            │  (Global Distribution)
                            └─────────────────────┘
```

## Prerequisites

### 1. AWS Infrastructure

**S3 Bucket** configured for static website hosting:
```bash
# Create S3 bucket
aws s3 mb s3://my-static-website --region us-east-1

# Enable static website hosting
aws s3 website s3://my-static-website \
  --index-document index.html \
  --error-document error.html

# Configure bucket policy for public read
aws s3api put-bucket-policy \
  --bucket my-static-website \
  --policy file://bucket-policy.json
```

**`bucket-policy.json`**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-static-website/*"
    }
  ]
}
```

**CloudFront Distribution**:
```bash
# Create distribution (or use AWS Console)
aws cloudfront create-distribution \
  --origin-domain-name my-static-website.s3-website-us-east-1.amazonaws.com \
  --default-root-object index.html
```

### 2. GitLab OIDC Configuration in AWS

**Create OIDC Provider** (one-time setup):
```bash
# Replace gitlab.example.com with your GitLab instance URL
aws iam create-open-id-connect-provider \
  --url https://gitlab.example.com \
  --client-id-list https://gitlab.example.com \
  --thumbprint-list <thumbprint>
```

**Create IAM Role** with trust policy:

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
          "gitlab.example.com:sub": "project_path:mygroup/myproject:*"
        }
      }
    }
  ]
}
```

```bash
# Create role
aws iam create-role \
  --role-name GitLabCI-Staging \
  --assume-role-policy-document file://trust-policy.json

# Attach permissions
aws iam attach-role-policy \
  --role-name GitLabCI-Staging \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

aws iam attach-role-policy \
  --role-name GitLabCI-Staging \
  --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess
```

### 3. GitLab CI/CD Variables

Set in GitLab project settings (Settings → CI/CD → Variables):

| Variable | Value | Protected | Masked |
|----------|-------|-----------|--------|
| `S3_BUCKET` | `my-static-website` | No | No |
| `CLOUDFRONT_DISTRIBUTION_ID` | `E1234567890ABC` | No | No |

**Note**: No AWS credentials needed with OIDC!

## Project Structure

```
s3-cloudfront-deployment/
├── .gitlab-ci.yml              # Pipeline configuration
├── scripts/
│   └── deploy.sh               # Deployment script
├── src/                        # Source code (example)
│   ├── index.html
│   ├── css/
│   │   └── main.css
│   └── js/
│       └── app.js
├── dist/                       # Build output (generated)
├── package.json                # Node.js dependencies
└── README.md                   # This file
```

## Usage

### 1. Clone and Customize

```bash
# Clone this sample
git clone <repository-url>
cd s3-cloudfront-deployment

# Update .gitlab-ci.yml with your values
sed -i 's/my-static-website/YOUR_BUCKET_NAME/g' .gitlab-ci.yml
sed -i 's/E1234567890ABC/YOUR_DISTRIBUTION_ID/g' .gitlab-ci.yml
sed -i 's/123456789012/YOUR_AWS_ACCOUNT_ID/g' .gitlab-ci.yml
```

### 2. Configure Your Application

**`package.json`** (example for React/Vue/Angular):
```json
{
  "name": "my-static-website",
  "version": "1.0.0",
  "scripts": {
    "build": "react-scripts build",
    "start": "react-scripts start"
  },
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "react-scripts": "^5.0.0"
  }
}
```

### 3. Push and Deploy

```bash
git add .
git commit -m "Initial deployment setup"
git push origin main
```

Pipeline will automatically:
1. Build the static website (`npm run build`)
2. Authenticate to AWS via OIDC
3. Sync files to S3 with optimized cache headers
4. Invalidate CloudFront cache
5. Run smoke tests to verify deployment

## Pipeline Stages

### Stage 1: Build

**Job**: `build-website`
- Installs npm dependencies
- Runs build command (`npm run build`)
- Produces `dist/` artifact

### Stage 2: Deploy

**Job**: `awscli-execute` (from component)
- Authenticates via OIDC (no credentials needed!)
- Assumes appropriate IAM role (staging or production)
- Executes `scripts/deploy.sh`
- Exports deployment outputs

**Script**: `scripts/deploy.sh`
- Validates prerequisites (dist/ exists, AWS auth)
- Syncs HTML files with `Cache-Control: no-cache`
- Syncs CSS/JS with `Cache-Control: max-age=31536000` (1 year)
- Syncs images with `Cache-Control: max-age=2592000` (30 days)
- Creates CloudFront invalidation
- Exports custom outputs (URLs, invalidation ID)

**Job**: `cleanup-review` (manual)
- Deletes S3 objects for review environments
- Triggered manually via GitLab UI
- Configured as environment stop action

### Stage 3: Verify

**Job**: `verify-deployment`
- Tests S3 direct access
- Tests CloudFront distribution
- Validates critical assets exist
- Uses outputs from deploy stage

## Cache Strategy

The deployment script applies different cache headers based on file type:

| File Type | Cache-Control | Reasoning |
|-----------|---------------|-----------|
| HTML | `public, max-age=0, must-revalidate` | Always fresh, enables quick updates |
| CSS/JS (versioned) | `public, max-age=31536000, immutable` | Long cache for versioned assets |
| Images | `public, max-age=2592000` | 30-day cache for static images |
| Other | `public, max-age=3600` | 1-hour default cache |

**Best Practice**: Use content hashing in filenames (e.g., `main.a3f5b.css`) to enable aggressive caching.

## Environment-Specific Deployments

The pipeline supports multiple environments via different IAM roles:

**Staging** (feature branches, main):
- Role: `arn:aws:iam::123456789012:role/GitLabCI-Staging`
- S3 Prefix: `${CI_ENVIRONMENT_SLUG}`
- Manual cleanup available

**Production** (production branch, tags):
- Role: `arn:aws:iam::123456789012:role/GitLabCI-Production`
- S3 Prefix: `production`
- Requires manual approval (add `when: manual` to job)

## Outputs and Downstream Jobs

The component exports these variables via dotenv artifact:

**Standard outputs**:
- `awscli_region`: AWS region used
- `awscli_assumed_role`: IAM role ARN
- `awscli_auth_method`: `oidc`

**Custom outputs** (from `deploy.sh`):
- `website_url`: S3 website URL
- `cloudfront_url`: CloudFront distribution URL
- `cloudfront_invalidation_id`: Invalidation ID
- `deployment_timestamp`: Deployment time (ISO 8601)
- `deployed_files`: Number of files deployed

**Usage in downstream jobs**:
```yaml
verify-deployment:
  needs:
    - awscli-execute
  script:
    - echo "Testing ${website_url}"
    - curl -f "${cloudfront_url}/index.html"
```

## Troubleshooting

### Issue: `InvalidIdentityToken` error

**Cause**: OIDC trust policy doesn't match GitLab project path

**Solution**: Update trust policy condition:
```json
"gitlab.example.com:sub": "project_path:YOUR_GROUP/YOUR_PROJECT:*"
```

### Issue: `AccessDenied` on S3 sync

**Cause**: IAM role lacks S3 permissions

**Solution**: Attach policy to role:
```bash
aws iam attach-role-policy \
  --role-name GitLabCI-Staging \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

### Issue: CloudFront invalidation fails

**Cause**: Missing CloudFront permissions

**Solution**: Add inline policy:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetDistribution"
      ],
      "Resource": "arn:aws:cloudfront::123456789012:distribution/E1234567890ABC"
    }
  ]
}
```

### Issue: Deployment succeeds but changes not visible

**Cause**: CloudFront invalidation still in progress (10-15 min)

**Solution**: Wait or uncomment wait command in `deploy.sh`:
```bash
aws cloudfront wait invalidation-completed \
  --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
  --id "${INVALIDATION_ID}"
```

## Extending This Example

### Add Deployment Notifications

```yaml
notify-deployment:
  stage: verify
  image: curlimages/curl:latest
  needs:
    - awscli-execute
  script:
    - |
      curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK/URL \
        -H 'Content-Type: application/json' \
        -d "{\"text\": \"Deployed to ${cloudfront_url}\"}"
```

### Add Performance Testing

```yaml
lighthouse-audit:
  stage: verify
  image: cypress/browsers:node18.12.0-chrome106
  needs:
    - awscli-execute
  script:
    - npm install -g @lhci/cli
    - lhci autorun --collect.url="${cloudfront_url}"
```

### Add Security Scanning

```yaml
include:
  - component: $CI_SERVER_FQDN/to-be-continuous/s3/gitlab-ci-s3@1.0.0
    inputs:
      bucket: "${S3_BUCKET}"
      scan-enabled: true
```

## Additional Resources

- [AWS CLI Component Documentation](../../README.md)
- [AWS S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- [CloudFront Documentation](https://docs.aws.amazon.com/cloudfront/)
- [GitLab OIDC with AWS](https://docs.gitlab.com/ee/ci/cloud_services/aws/)
- [Cache-Control Best Practices](https://web.dev/http-cache/)

## License

MIT License