#!/usr/bin/env bash
#
# Script: sync-modified-sql-to-s3.sh
# Description: Syncs only modified SQL files from sql/ directory to S3 bucket
#              Uses git diff to detect changes since last tag or from main branch
#
# Requirements:
#   - AWS CLI installed and configured (via OIDC or credentials)
#   - Git repository with history
#   - Environment variables: S3_BUCKET, AWS_REGION (optional)
#
# Usage:
#   ./sync-modified-sql-to-s3.sh
#

set -euo pipefail

# Configuration
SQL_DIR="${SQL_DIR:-sql}"
S3_BUCKET="${S3_BUCKET:?Error: S3_BUCKET environment variable is required}"
AWS_REGION="${AWS_REGION:-us-east-1}"
S3_PREFIX="${S3_PREFIX:-sql}"  # Optional prefix in S3 bucket

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Validate SQL directory exists
if [[ ! -d "$SQL_DIR" ]]; then
    log_error "SQL directory '$SQL_DIR' does not exist"
    exit 1
fi

# Detect base reference for comparison
# Priority: last semantic-release tag > main branch > all files
if git describe --tags --abbrev=0 --match='v*' 2>/dev/null; then
    LAST_TAG=$(git describe --tags --abbrev=0 --match='v*')
    BASE_REF="$LAST_TAG"
    log_info "Comparing against last tag: $LAST_TAG"
elif git rev-parse origin/main &>/dev/null; then
    BASE_REF="origin/main"
    log_info "Comparing against origin/main"
elif git rev-parse main &>/dev/null; then
    BASE_REF="main"
    log_info "Comparing against main branch"
else
    log_warn "No reference found, syncing ALL SQL files"
    BASE_REF=""
fi

# Get list of modified SQL files
if [[ -n "$BASE_REF" ]]; then
    # Get merge-base to find common ancestor
    MERGE_BASE=$(git merge-base "$BASE_REF" HEAD 2>/dev/null || echo "$BASE_REF")

    # Find modified/added SQL files (A=added, M=modified, C=copied, R=renamed)
    MODIFIED_FILES=$(git diff --name-only --diff-filter=ACMR "$MERGE_BASE" HEAD -- "$SQL_DIR/"*.sql 2>/dev/null || true)
else
    # No reference, get all SQL files
    MODIFIED_FILES=$(find "$SQL_DIR" -type f -name "*.sql" 2>/dev/null || true)
fi

# Check if any files to sync
if [[ -z "$MODIFIED_FILES" ]]; then
    log_info "No SQL files modified, nothing to sync"
    exit 0
fi

# Count files
FILE_COUNT=$(echo "$MODIFIED_FILES" | wc -l)
log_info "Found $FILE_COUNT SQL file(s) to sync"

# Display files to sync
echo ""
echo "Files to sync:"
echo "$MODIFIED_FILES" | while read -r file; do
    echo "  - $file"
done
echo ""

# Sync each file to S3
SYNC_COUNT=0
FAIL_COUNT=0

echo "$MODIFIED_FILES" | while read -r file; do
    # Skip if file doesn't exist (might have been deleted)
    if [[ ! -f "$file" ]]; then
        log_warn "File not found, skipping: $file"
        continue
    fi

    # Calculate S3 key (preserve directory structure under sql/)
    # Example: sql/migrations/001_create_tables.sql -> sql/migrations/001_create_tables.sql
    RELATIVE_PATH="${file#$SQL_DIR/}"
    S3_KEY="$S3_PREFIX/$RELATIVE_PATH"
    S3_URI="s3://$S3_BUCKET/$S3_KEY"

    log_info "Syncing: $file -> $S3_URI"

    # Upload to S3
    if aws s3 cp "$file" "$S3_URI" --region "$AWS_REGION"; then
        SYNC_COUNT=$((SYNC_COUNT + 1))
        log_info "✓ Successfully synced: $file"
    else
        FAIL_COUNT=$((FAIL_COUNT + 1))
        log_error "✗ Failed to sync: $file"
    fi
done

# Summary
echo ""
log_info "Sync completed: $SYNC_COUNT succeeded, $FAIL_COUNT failed"

if [[ $FAIL_COUNT -gt 0 ]]; then
    exit 1
fi