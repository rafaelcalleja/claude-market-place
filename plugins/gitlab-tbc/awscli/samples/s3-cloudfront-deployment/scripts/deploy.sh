#!/bin/bash
set -euo pipefail

# =============================================================================
# AWS S3 + CloudFront Deployment Script
# =============================================================================
# This script demonstrates best practices for deploying static websites to
# AWS S3 with CloudFront cache invalidation.
#
# Environment variables expected:
# - S3_BUCKET: S3 bucket name
# - CLOUDFRONT_DISTRIBUTION_ID: CloudFront distribution ID
# - CI_ENVIRONMENT_SLUG: Environment identifier (from GitLab)
# - AWS_DEFAULT_REGION: AWS region (from awscli component)
#
# The script will:
# 1. Sync built assets to S3 with optimal caching headers
# 2. Create CloudFront invalidation to refresh cached content
# 3. Export deployment outputs for downstream jobs
# =============================================================================

log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

# =============================================================================
# Configuration
# =============================================================================

S3_URI="s3://${S3_BUCKET}/${CI_ENVIRONMENT_SLUG:-staging}"
DIST_DIR="./dist"

log_info "Deployment Configuration:"
log_info "  S3 Bucket:           ${S3_BUCKET}"
log_info "  S3 Prefix:           ${CI_ENVIRONMENT_SLUG:-staging}"
log_info "  CloudFront Dist ID:  ${CLOUDFRONT_DISTRIBUTION_ID}"
log_info "  Source Directory:    ${DIST_DIR}"
log_info "  AWS Region:          ${AWS_DEFAULT_REGION}"

# =============================================================================
# Validate prerequisites
# =============================================================================

log_info "Validating prerequisites..."

if [[ ! -d "$DIST_DIR" ]]; then
  log_error "Distribution directory not found: $DIST_DIR"
  exit 1
fi

FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l)
log_info "Found ${FILE_COUNT} files to deploy"

if [[ $FILE_COUNT -eq 0 ]]; then
  log_error "No files found in distribution directory"
  exit 1
fi

# Verify AWS authentication
CALLER_IDENTITY=$(aws sts get-caller-identity --output json)
CALLER_ARN=$(echo "$CALLER_IDENTITY" | grep -o '"Arn": "[^"]*' | cut -d'"' -f4)
log_success "Authenticated as: ${CALLER_ARN}"

# =============================================================================
# S3 Sync with Cache-Control Headers
# =============================================================================

log_info "Syncing files to S3: ${S3_URI}"

# Sync HTML files with no-cache (always revalidate)
log_info "Syncing HTML files (no-cache)..."
aws s3 sync "$DIST_DIR" "$S3_URI" \
  --exclude "*" \
  --include "*.html" \
  --cache-control "public, max-age=0, must-revalidate" \
  --metadata-directive REPLACE \
  --delete

# Sync CSS/JS with versioned filenames (long cache)
log_info "Syncing CSS/JS files (1 year cache)..."
aws s3 sync "$DIST_DIR" "$S3_URI" \
  --exclude "*" \
  --include "*.css" \
  --include "*.js" \
  --cache-control "public, max-age=31536000, immutable" \
  --metadata-directive REPLACE \
  --delete

# Sync images with moderate cache
log_info "Syncing image files (30 day cache)..."
aws s3 sync "$DIST_DIR" "$S3_URI" \
  --exclude "*" \
  --include "*.jpg" \
  --include "*.jpeg" \
  --include "*.png" \
  --include "*.gif" \
  --include "*.svg" \
  --include "*.webp" \
  --cache-control "public, max-age=2592000" \
  --metadata-directive REPLACE \
  --delete

# Sync all other files with default cache
log_info "Syncing remaining files..."
aws s3 sync "$DIST_DIR" "$S3_URI" \
  --exclude "*.html" \
  --exclude "*.css" \
  --exclude "*.js" \
  --exclude "*.jpg" \
  --exclude "*.jpeg" \
  --exclude "*.png" \
  --exclude "*.gif" \
  --exclude "*.svg" \
  --exclude "*.webp" \
  --cache-control "public, max-age=3600" \
  --metadata-directive REPLACE \
  --delete

log_success "S3 sync completed"

# =============================================================================
# CloudFront Invalidation
# =============================================================================

log_info "Creating CloudFront invalidation..."

INVALIDATION_OUTPUT=$(aws cloudfront create-invalidation \
  --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
  --paths "/${CI_ENVIRONMENT_SLUG:-staging}/*" \
  --output json)

INVALIDATION_ID=$(echo "$INVALIDATION_OUTPUT" | grep -o '"Id": "[^"]*' | cut -d'"' -f4)

log_success "CloudFront invalidation created: ${INVALIDATION_ID}"
log_info "Invalidation status: In Progress"
log_info "Note: Invalidation may take 10-15 minutes to complete"

# Optionally wait for invalidation (uncomment if needed)
# log_info "Waiting for invalidation to complete..."
# aws cloudfront wait invalidation-completed \
#   --distribution-id "${CLOUDFRONT_DISTRIBUTION_ID}" \
#   --id "${INVALIDATION_ID}"
# log_success "Invalidation completed"

# =============================================================================
# Generate deployment outputs
# =============================================================================

log_info "Generating deployment outputs..."

# Construct website URLs
S3_WEBSITE_URL="https://${S3_BUCKET}.s3-website-${AWS_DEFAULT_REGION}.amazonaws.com/${CI_ENVIRONMENT_SLUG:-staging}"

# Get CloudFront domain name
CLOUDFRONT_DOMAIN=$(aws cloudfront get-distribution \
  --id "${CLOUDFRONT_DISTRIBUTION_ID}" \
  --query 'Distribution.DomainName' \
  --output text)

CLOUDFRONT_URL="https://${CLOUDFRONT_DOMAIN}/${CI_ENVIRONMENT_SLUG:-staging}"

# Write outputs to custom env file (merged into awscli.env by component)
cat > awscli-custom.env << EOF
# Deployment Outputs
website_url=${S3_WEBSITE_URL}
cloudfront_url=${CLOUDFRONT_URL}
cloudfront_distribution_id=${CLOUDFRONT_DISTRIBUTION_ID}
cloudfront_invalidation_id=${INVALIDATION_ID}
deployment_timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
deployed_files=${FILE_COUNT}
s3_uri=${S3_URI}
EOF

log_success "Deployment outputs written to awscli-custom.env"

# =============================================================================
# Deployment Summary
# =============================================================================

log_success "========================================="
log_success "   Deployment Completed Successfully"
log_success "========================================="
log_info ""
log_info "S3 Website URL:"
log_info "  ${S3_WEBSITE_URL}"
log_info ""
log_info "CloudFront URL:"
log_info "  ${CLOUDFRONT_URL}"
log_info ""
log_info "CloudFront Invalidation:"
log_info "  ID: ${INVALIDATION_ID}"
log_info "  Status: In Progress"
log_info ""
log_info "Files Deployed: ${FILE_COUNT}"
log_info "========================================="

exit 0