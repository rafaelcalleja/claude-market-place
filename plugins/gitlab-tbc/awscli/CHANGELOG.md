# Changelog

All notable changes to the AWS CLI component will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-11-30

### Added

#### Core Features
- **Standard variant** (`gitlab-ci-awscli.yml`) with AWS access key authentication
- **OIDC variant** (`gitlab-ci-awscli-oidc.yml`) with OpenID Connect authentication
- Role assumption support with configurable session duration (900-43200 seconds)
- Environment-specific role ARNs for OIDC (review, integration, staging, production)
- External ID support for additional security in role assumption

#### Script Execution
- Script execution from external files via `script-file` input
- Inline script execution via `script-inline` input
- Support for both approaches in a single component

#### Output Management
- DotEnv artifact export for downstream job integration
- Standard outputs: region, execution timestamp, assumed role, auth method
- Extensible output system via `awscli-custom.env` file
- User scripts can append custom outputs to component outputs

#### Developer Experience
- Multi-distro support (Debian/Ubuntu, RHEL/CentOS, Alpine)
- Additional tool installation via `install-extras` input
- Debug mode for AWS CLI troubleshooting
- Comprehensive logging with color-coded output (INFO, WARN, ERROR, SUCCESS)
- Pre-flight authentication verification
- Post-assumption identity verification

#### Security Features
- OIDC-based authentication eliminating long-lived credentials
- Automatic temporary credential management via AWS STS
- Configurable JWT audience claim for OIDC
- External ID support for cross-account role assumption
- Principle of least privilege in examples and documentation

#### Documentation
- Complete README with usage examples
- 5 real-world examples (S3/CloudFront, ECS, Lambda, RDS, multi-environment)
- AWS IAM configuration guides for both variants
- OIDC provider setup instructions
- Trust policy examples for GitLab OIDC integration
- Troubleshooting section with common issues and solutions
- Migration guide from standard to OIDC variant
- Integration patterns with other to-be-continuous components

#### Component Architecture
- Hidden base jobs (`.awscli-base`, `.awscli-oidc-base`) for extensibility
- YAML anchors for script library reusability
- Standard to-be-continuous workflow rules integration
- Backward compatibility via dual input/variable syntax

### Technical Details

#### Inputs
- **Common**: `cli-image`, `aws-region`, `script-file`, `script-inline`, `export-outputs`, `debug-mode`, `install-extras`
- **Standard**: `role-arn`, `role-session-name`, `role-duration`
- **OIDC**: `oidc-aud`, `oidc-role-arn`, `review-oidc-role-arn`, `integration-oidc-role-arn`, `staging-oidc-role-arn`, `production-oidc-role-arn`, `role-session-name`, `role-duration`, `external-id`

#### Jobs
- `awscli-execute`: Main execution job in `deploy` stage with artifact export

#### Artifacts
- DotEnv report: `awscli.env` with component and custom outputs
- Artifact paths: `awscli.env` (1 week expiration)
- Always collected (even on failure) for debugging

#### Dependencies
- Requires `amazon/aws-cli:latest` Docker image (or custom via `cli-image`)
- GitLab 15.7+ for OIDC variant (JWT token support)
- AWS STS API access for role assumption
- to-be-continuous workflow rules (`.tbc-workflow-rules`)

### Testing
- Component self-testing via `.gitlab-ci.yml` (see next commit)
- Sample project demonstrating usage patterns (see `samples/` directory)

### License
- MIT License (standard for to-be-continuous ecosystem)

---

## Version Numbering Scheme

This component follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version: Incompatible changes (breaking changes to inputs, job names, or output variables)
- **MINOR** version: New features in backward-compatible manner (new inputs, new jobs, new variants)
- **PATCH** version: Backward-compatible bug fixes

### Future Planned Features (Not Yet Released)

Potential future enhancements being considered:

- **Vault variant**: HashiCorp Vault integration for secret management
- **AssumeRole chaining**: Support for multi-hop role assumption
- **Credential caching**: Reduce STS calls for faster multi-job pipelines
- **AWS SSO support**: Integration with AWS IAM Identity Center
- **Policy simulation**: Pre-execution IAM policy validation
- **Cost tracking**: Tag-based cost allocation for CI/CD operations
- **Multi-region support**: Parallel execution across multiple regions
- **Retry logic**: Automatic retry for transient AWS API failures

---

## Migration Notes

### Upgrading from Pre-Release Versions

If you used a pre-release or development version of this component, please:

1. **Review input names**: All inputs now use kebab-case (`oidc-role-arn`, not `oidcRoleArn`)
2. **Check job names**: Main job is now `awscli-execute` (was `aws-cli-run` in some betas)
3. **Update artifact references**: DotEnv artifact is now `awscli.env` (was `aws-outputs.env`)
4. **Verify role ARN format**: Must be full ARN format (`arn:aws:iam::123456789012:role/Name`)

### Breaking Changes from 0.x to 1.0.0

- N/A (initial stable release)

---

## Deprecation Warnings

None for version 1.0.0 (initial release).

---

## Security Advisories

None at this time. Security issues should be reported to the to-be-continuous security team.

---

[Unreleased]: https://gitlab.com/to-be-continuous/awscli/-/compare/v1.0.0...HEAD
[1.0.0]: https://gitlab.com/to-be-continuous/awscli/-/tags/v1.0.0