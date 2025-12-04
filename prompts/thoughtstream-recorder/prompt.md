# Claude Code Advanced Session Recording Skill - Implementation Specification

Build an intelligent session recording skill for Claude Code that goes beyond simple logging to create a searchable, analyzable interaction history with semantic understanding.

## Core Innovation

This skill implements a **hybrid capture + semantic analysis** system that:
- Automatically captures all interaction events via hooks
- Enables Claude to self-annotate significant moments with context
- Builds a queryable session history with pattern detection
- Supports session replay and workflow extraction

## Architecture Overview

### Multi-Layer Recording Strategy

**Layer 1: Automatic Capture** (Hooks)
- Raw event stream: user prompts, tool invocations, results
- Zero-configuration capture of all interactions
- Atomic append-only log for data integrity

**Layer 2: Semantic Annotation** (Self-Reporting)
- Claude identifies and annotates "decision points"
- Captures reasoning, alternatives considered, trade-offs
- Tags interactions with semantic categories (bug_fix, feature_add, refactor, investigation)

**Layer 3: Pattern Recognition** (Post-Processing)
- Detects common workflows and interaction patterns
- Identifies repeated problem-solving strategies
- Builds session summaries with key decision paths

## Data Schema

### Primary Session Log: `.claude/session_logs/session_YYYY-MM-DD.jsonl`

Use **JSONL** (JSON Lines) instead of single JSON for:
- Atomic appends without locking
- Stream processing capability
- Easy truncation/rotation
- Resilience to corruption (one bad line doesn't break entire file)

```jsonl
{"type":"session_start","session_id":"uuid","timestamp":"ISO-8601","project":"/path","git_branch":"main"}
{"type":"user_message","id":"uuid","ts":"ISO-8601","content":"Fix the auth bug","session_id":"uuid"}
{"type":"tool_call","id":"uuid","ts":"ISO-8601","tool":"bash","cmd":"grep -r 'authenticate'","session_id":"uuid"}
{"type":"tool_result","id":"uuid","ts":"ISO-8601","tool":"bash","exit_code":0,"output_hash":"sha256:...","session_id":"uuid"}
{"type":"assistant_annotation","id":"uuid","ts":"ISO-8601","category":"bug_fix","summary":"Found race condition in token validation","reasoning":"Multiple threads accessing shared token cache without locks","alternatives_considered":["Add mutex","Use thread-local storage","Redesign cache"],"chosen_approach":"Add mutex - simplest fix with minimal risk","session_id":"uuid"}
{"type":"session_end","session_id":"uuid","timestamp":"ISO-8601","total_interactions":47}
```

### Session Index: `.claude/session_logs/index.json`

Fast lookup structure for session queries:

```json
{
  "sessions": [
    {
      "session_id": "uuid",
      "date": "2025-12-02",
      "duration_seconds": 3600,
      "interaction_count": 47,
      "categories": ["bug_fix", "testing"],
      "files_modified": ["auth.js", "auth.test.js"],
      "summary": "Fixed race condition in authentication token validation"
    }
  ]
}
```

## File Structure

```
.claude/
├── claude.json                           # Hook configuration
├── skills/
│   └── session-recorder/
│       ├── SKILL.md                      # Skill documentation
│       ├── lib/
│       │   ├── append_event.sh          # Atomic JSONL append
│       │   ├── generate_id.sh           # UUID generation
│       │   └── session_query.sh         # Query session logs
│       ├── annotate.sh                  # Self-reporting helper
│       └── hooks/
│           ├── 01_session_init.sh
│           ├── 02_capture_user.sh
│           ├── 03_capture_tool.sh
│           └── 04_session_end.sh
└── session_logs/
    ├── session_2025-12-02.jsonl
    ├── session_2025-12-01.jsonl
    └── index.json
```

## Implementation Specifications

### 1. SKILL.md - Semantic Annotation Instructions

**Frontmatter:**
```yaml
---
name: session-recorder
description: "Intelligent session recording with semantic annotation. Captures all interactions and enables Claude to annotate significant moments with reasoning and context. Activates on 'record session' or runs passively."
allowed-tools:
  - bash
  - read
---
```

**Key Content Sections:**

**When to Self-Annotate:**
Instruct Claude to call `annotate.sh` after:
1. **Decision Points**: When choosing between multiple approaches
2. **Problem Discovery**: When identifying root causes or bugs
3. **Architecture Changes**: When modifying system structure
4. **Error Resolution**: When fixing issues or working around limitations
5. **Workflow Completion**: When finishing multi-step tasks

**Annotation Format:**
```bash
bash .claude/skills/session-recorder/annotate.sh \
  --category "bug_fix|feature_add|refactor|investigation|optimization" \
  --summary "One-line description of what was accomplished" \
  --reasoning "Why this approach was taken" \
  --alternatives "Other approaches considered (comma-separated)" \
  --chosen "Which approach was selected and why"
```

**Example:**
```bash
bash .claude/skills/session-recorder/annotate.sh \
  --category "bug_fix" \
  --summary "Resolved authentication race condition" \
  --reasoning "Token cache accessed by multiple threads without synchronization" \
  --alternatives "Add mutex lock,Use thread-local storage,Redesign cache architecture" \
  --chosen "Mutex lock - minimal risk, fast implementation, proven pattern"
```

### 2. Hook Scripts - Event Capture

**01_session_init.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Generate session ID
SESSION_ID=$(uuidgen)
export SESSION_ID

# Detect project context
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git")

# Create session log directory
mkdir -p "$PROJECT_DIR/.claude/session_logs"

# Get today's log file
LOG_FILE="$PROJECT_DIR/.claude/session_logs/session_$(date +%Y-%m-%d).jsonl"

# Append session start event (atomic)
jq -n \
  --arg session_id "$SESSION_ID" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg project "$PROJECT_DIR" \
  --arg branch "$GIT_BRANCH" \
  '{type:"session_start",session_id:$session_id,timestamp:$ts,project:$project,git_branch:$branch}' \
  >> "$LOG_FILE"
```

**02_capture_user.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Read user message from stdin (provided by hook system)
USER_MESSAGE=$(cat)

SESSION_ID="${SESSION_ID:-unknown}"
LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/session_logs/session_$(date +%Y-%m-%d).jsonl"

# Append user message event
jq -n \
  --arg id "$(uuidgen)" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg content "$USER_MESSAGE" \
  --arg session_id "$SESSION_ID" \
  '{type:"user_message",id:$id,ts:$ts,content:$content,session_id:$session_id}' \
  >> "$LOG_FILE"
```

**03_capture_tool.sh:**
```bash
#!/bin/bash
set -euo pipefail

# Hook receives tool call data as JSON via stdin
TOOL_DATA=$(cat)

TOOL_NAME=$(echo "$TOOL_DATA" | jq -r '.tool_name // "unknown"')
TOOL_INPUT=$(echo "$TOOL_DATA" | jq -c '.tool_input // {}')
TOOL_RESULT=$(echo "$TOOL_DATA" | jq -c '.tool_result // {}')
EXIT_CODE=$(echo "$TOOL_DATA" | jq -r '.exit_code // 0')

SESSION_ID="${SESSION_ID:-unknown}"
LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/session_logs/session_$(date +%Y-%m-%d).jsonl"

# Calculate output hash for large results (avoid storing huge outputs)
OUTPUT_HASH=$(echo "$TOOL_RESULT" | sha256sum | cut -d' ' -f1)

# Append tool execution event
jq -n \
  --arg id "$(uuidgen)" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg tool "$TOOL_NAME" \
  --argjson input "$TOOL_INPUT" \
  --arg hash "$OUTPUT_HASH" \
  --argjson exit_code "$EXIT_CODE" \
  --arg session_id "$SESSION_ID" \
  '{type:"tool_call",id:$id,ts:$ts,tool:$tool,input:$input,output_hash:$hash,exit_code:$exit_code,session_id:$session_id}' \
  >> "$LOG_FILE"
```

**04_session_end.sh:**
```bash
#!/bin/bash
set -euo pipefail

SESSION_ID="${SESSION_ID:-unknown}"
LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/session_logs/session_$(date +%Y-%m-%d).jsonl"

# Count interactions in this session
INTERACTION_COUNT=$(grep -c "\"session_id\":\"$SESSION_ID\"" "$LOG_FILE" || echo 0)

# Append session end event
jq -n \
  --arg session_id "$SESSION_ID" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --argjson count "$INTERACTION_COUNT" \
  '{type:"session_end",session_id:$session_id,timestamp:$ts,total_interactions:$count}' \
  >> "$LOG_FILE"

# Update index (async, non-blocking)
bash "${CLAUDE_PROJECT_DIR:-.}/.claude/skills/session-recorder/lib/update_index.sh" &
```

### 3. Annotation Helper - annotate.sh

```bash
#!/bin/bash
set -euo pipefail

# Parse arguments
CATEGORY=""
SUMMARY=""
REASONING=""
ALTERNATIVES=""
CHOSEN=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --category) CATEGORY="$2"; shift 2 ;;
    --summary) SUMMARY="$2"; shift 2 ;;
    --reasoning) REASONING="$2"; shift 2 ;;
    --alternatives) ALTERNATIVES="$2"; shift 2 ;;
    --chosen) CHOSEN="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Validation
[[ -z "$CATEGORY" ]] && { echo "Error: --category required"; exit 1; }
[[ -z "$SUMMARY" ]] && { echo "Error: --summary required"; exit 1; }

SESSION_ID="${SESSION_ID:-unknown}"
LOG_FILE="${CLAUDE_PROJECT_DIR:-.}/.claude/session_logs/session_$(date +%Y-%m-%d).jsonl"

# Convert alternatives to JSON array
ALT_ARRAY=$(echo "$ALTERNATIVES" | jq -R 'split(",")')

# Append annotation
jq -n \
  --arg id "$(uuidgen)" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg category "$CATEGORY" \
  --arg summary "$SUMMARY" \
  --arg reasoning "$REASONING" \
  --argjson alternatives "$ALT_ARRAY" \
  --arg chosen "$CHOSEN" \
  --arg session_id "$SESSION_ID" \
  '{type:"assistant_annotation",id:$id,ts:$ts,category:$category,summary:$summary,reasoning:$reasoning,alternatives_considered:$alternatives,chosen_approach:$chosen,session_id:$session_id}' \
  >> "$LOG_FILE"

echo "✓ Annotation recorded: $SUMMARY"
```

### 4. Query Tool - session_query.sh

Enable searching session history:

```bash
#!/bin/bash
# Usage: session_query.sh --category bug_fix --date 2025-12-02

LOGS_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/session_logs"

# Parse query parameters
CATEGORY=""
DATE=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --category) CATEGORY="$2"; shift 2 ;;
    --date) DATE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Build query
if [[ -n "$DATE" ]]; then
  LOG_FILE="$LOGS_DIR/session_$DATE.jsonl"
else
  LOG_FILE="$LOGS_DIR/session_$(date +%Y-%m-%d).jsonl"
fi

# Search annotations
if [[ -n "$CATEGORY" ]]; then
  grep "\"category\":\"$CATEGORY\"" "$LOG_FILE" | jq -r '[.ts,.summary,.reasoning] | @tsv'
else
  cat "$LOG_FILE" | jq -r 'select(.type=="assistant_annotation") | [.ts,.category,.summary] | @tsv'
fi
```

## Hook Configuration - claude.json

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "command": "bash",
        "script": "$CLAUDE_PROJECT_DIR/.claude/skills/session-recorder/hooks/01_session_init.sh"
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "command": "bash",
        "script": "$CLAUDE_PROJECT_DIR/.claude/skills/session-recorder/hooks/02_capture_user.sh"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "command": "bash",
        "script": "$CLAUDE_PROJECT_DIR/.claude/skills/session-recorder/hooks/03_capture_tool.sh"
      }
    ],
    "SessionEnd": [
      {
        "matcher": "*",
        "command": "bash",
        "script": "$CLAUDE_PROJECT_DIR/.claude/skills/session-recorder/hooks/04_session_end.sh"
      }
    ]
  }
}
```

## Advanced Features to Implement

### Pattern Detection
Analyze session logs to identify:
- Common debugging workflows
- Repeated problem-solving patterns
- Frequently used tool sequences
- Time-consuming operations

### Session Replay
Build capability to:
- Reconstruct decision paths
- Extract workflows as reusable templates
- Generate session summaries automatically
- Create "highlight reels" of key moments

### Integration Points
- Export to Markdown for documentation
- Feed into learning systems
- Generate metrics (tools used, time distribution)
- Create decision trees from annotation data

## Testing Strategy

Validate:
1. **Concurrency**: Multiple rapid tool calls don't corrupt JSONL
2. **Date Rollover**: Sessions spanning midnight create correct files
3. **Missing Dependencies**: Graceful degradation if jq unavailable
4. **Large Outputs**: Hash-based storage prevents log bloat
5. **Query Performance**: Fast searches on 1000+ interaction sessions
6. **Annotation Quality**: Semantic categories are meaningful
7. **Replay Accuracy**: Reconstructed workflows match actual execution

## Success Criteria

- Zero-configuration automatic capture of all events
- < 10ms overhead per interaction
- Queryable history across sessions
- Meaningful semantic annotations from Claude
- Support for 10,000+ interactions per session file
- Pattern detection identifies 3+ common workflows per project

## Output Requirements

Generate:
1. All shell scripts with full implementation
2. Complete SKILL.md with examples
3. claude.json hook configuration
4. Query tool implementation
5. Session index generator
6. Installation and usage guide
7. Example queries and analysis commands

Deliver production-ready code with error handling, documentation, and extensibility for future enhancements.
