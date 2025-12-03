# Session Recorder Integration Guide

This guide covers integrating session logs with external tools and workflows.

## Git Integration

### Auto-Commit Logs

Create a post-session hook to commit logs:

```bash
#!/bin/bash
# .git/hooks/post-claude-session

LOG_DIR=".claude/session_logs"
TODAY=$(date +%Y-%m-%d)
LOG_FILE="${LOG_DIR}/session_${TODAY}.json"

if [ -f "$LOG_FILE" ]; then
  git add "$LOG_FILE"
  git commit -m "chore: add Claude session log for ${TODAY}" --no-verify
fi
```

### Include in .gitignore (Optional)

If logs should not be committed:

```gitignore
# .gitignore
.claude/session_logs/
.claude/*.lock
```

## CI/CD Integration

### GitHub Actions - Session Analysis

```yaml
# .github/workflows/session-analysis.yml
name: Analyze Claude Sessions

on:
  push:
    paths:
      - '.claude/session_logs/*.json'

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install jq
        run: sudo apt-get install -y jq

      - name: Generate Report
        run: |
          echo "## Session Analysis Report" >> $GITHUB_STEP_SUMMARY
          for log in .claude/session_logs/session_*.json; do
            if [ -f "$log" ]; then
              echo "### $(basename $log)" >> $GITHUB_STEP_SUMMARY
              jq -r '"- Interactions: \(.interactions | length)"' "$log" >> $GITHUB_STEP_SUMMARY
              jq -r '"- Tools: \([.interactions[] | select(.type == "tool_call") | .content.tool] | unique | join(", "))"' "$log" >> $GITHUB_STEP_SUMMARY
            fi
          done
```

## Database Integration

### PostgreSQL Import

```sql
-- Create table
CREATE TABLE session_logs (
  id SERIAL PRIMARY KEY,
  session_id UUID NOT NULL,
  start_timestamp TIMESTAMPTZ NOT NULL,
  end_timestamp TIMESTAMPTZ,
  project_path TEXT,
  interactions JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for querying
CREATE INDEX idx_session_logs_session_id ON session_logs(session_id);
CREATE INDEX idx_session_logs_start ON session_logs(start_timestamp);
```

```bash
#!/bin/bash
# import_to_postgres.sh

LOG_FILE="$1"
DB_URL="${DATABASE_URL:-postgres://localhost/claude_logs}"

if [ ! -f "$LOG_FILE" ]; then
  echo "Usage: import_to_postgres.sh <log_file>"
  exit 1
fi

# Convert to SQL-compatible format and import
jq -c '{
  session_id: .session_id,
  start_timestamp: .start_timestamp,
  end_timestamp: .end_timestamp,
  project_path: .project_path,
  interactions: .interactions
}' "$LOG_FILE" | \
psql "$DB_URL" -c "
  INSERT INTO session_logs (session_id, start_timestamp, end_timestamp, project_path, interactions)
  SELECT
    (input->>'session_id')::uuid,
    (input->>'start_timestamp')::timestamptz,
    (input->>'end_timestamp')::timestamptz,
    input->>'project_path',
    input->'interactions'
  FROM json_populate_record(NULL::json, '$(cat)') AS input
"
```

### SQLite Local Storage

```bash
#!/bin/bash
# sqlite_import.sh

DB_FILE=".claude/sessions.db"
LOG_FILE="$1"

# Create table if not exists
sqlite3 "$DB_FILE" <<EOF
CREATE TABLE IF NOT EXISTS sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  start_timestamp TEXT NOT NULL,
  end_timestamp TEXT,
  project_path TEXT,
  interaction_count INTEGER,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS interactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  interaction_id TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  type TEXT NOT NULL,
  content TEXT,
  FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);
EOF

# Import session
session_id=$(jq -r '.session_id' "$LOG_FILE")
start_ts=$(jq -r '.start_timestamp' "$LOG_FILE")
end_ts=$(jq -r '.end_timestamp // ""' "$LOG_FILE")
project=$(jq -r '.project_path' "$LOG_FILE")
count=$(jq '.interactions | length' "$LOG_FILE")

sqlite3 "$DB_FILE" "INSERT INTO sessions (session_id, start_timestamp, end_timestamp, project_path, interaction_count) VALUES ('$session_id', '$start_ts', '$end_ts', '$project', $count);"

# Import interactions
jq -c '.interactions[]' "$LOG_FILE" | while read -r interaction; do
  int_id=$(echo "$interaction" | jq -r '.interaction_id')
  ts=$(echo "$interaction" | jq -r '.timestamp')
  type=$(echo "$interaction" | jq -r '.type')
  content=$(echo "$interaction" | jq -c '.content' | sed "s/'/''/g")

  sqlite3 "$DB_FILE" "INSERT INTO interactions (session_id, interaction_id, timestamp, type, content) VALUES ('$session_id', '$int_id', '$ts', '$type', '$content');"
done
```

## Monitoring Integration

### Prometheus Metrics

```bash
#!/bin/bash
# export_metrics.sh - Export session metrics for Prometheus

LOG_DIR=".claude/session_logs"
METRICS_FILE="/tmp/claude_session_metrics.prom"

# Calculate metrics
total_sessions=$(ls -1 "$LOG_DIR"/session_*.json 2>/dev/null | wc -l)
total_interactions=$(jq -s '[.[].interactions | length] | add // 0' "$LOG_DIR"/session_*.json 2>/dev/null)
total_tool_calls=$(jq -s '[[.[].interactions[] | select(.type == "tool_call")] | length] | add // 0' "$LOG_DIR"/session_*.json 2>/dev/null)

# Write Prometheus format
cat > "$METRICS_FILE" <<EOF
# HELP claude_sessions_total Total number of Claude Code sessions
# TYPE claude_sessions_total counter
claude_sessions_total ${total_sessions}

# HELP claude_interactions_total Total number of interactions across all sessions
# TYPE claude_interactions_total counter
claude_interactions_total ${total_interactions}

# HELP claude_tool_calls_total Total number of tool calls across all sessions
# TYPE claude_tool_calls_total counter
claude_tool_calls_total ${total_tool_calls}
EOF

echo "Metrics exported to $METRICS_FILE"
```

### Grafana Dashboard

Create a JSON dashboard definition:

```json
{
  "dashboard": {
    "title": "Claude Code Sessions",
    "panels": [
      {
        "title": "Sessions Over Time",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(claude_sessions_total[1d])",
            "legendFormat": "Sessions/day"
          }
        ]
      },
      {
        "title": "Tool Usage",
        "type": "piechart",
        "targets": [
          {
            "expr": "claude_tool_calls_by_type",
            "legendFormat": "{{tool}}"
          }
        ]
      }
    ]
  }
}
```

## Webhook Integration

### Generic Webhook on Session End

Add to `session_finalize.sh` or create a separate script:

```bash
#!/bin/bash
# webhook_notify.sh

WEBHOOK_URL="${CLAUDE_SESSION_WEBHOOK_URL}"
LOG_FILE="$1"

if [ -z "$WEBHOOK_URL" ] || [ ! -f "$LOG_FILE" ]; then
  exit 0
fi

# Build payload
payload=$(jq '{
  event: "session_complete",
  session_id: .session_id,
  start: .start_timestamp,
  end: .end_timestamp,
  stats: {
    total: (.interactions | length),
    user_messages: ([.interactions[] | select(.type == "user_message")] | length),
    tool_calls: ([.interactions[] | select(.type == "tool_call")] | length),
    summaries: ([.interactions[] | select(.type == "assistant_summary")] | length)
  },
  tools_used: ([.interactions[] | select(.type == "tool_call") | .content.tool] | unique)
}' "$LOG_FILE")

curl -s -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload"
```

### Discord Notification

```bash
#!/bin/bash
# discord_notify.sh

DISCORD_WEBHOOK="${DISCORD_WEBHOOK_URL}"
LOG_FILE="$1"

if [ -z "$DISCORD_WEBHOOK" ] || [ ! -f "$LOG_FILE" ]; then
  exit 0
fi

# Build Discord embed
summary=$(jq -r '
  "**Session Complete**\n" +
  "Duration: " + (
    if .end_timestamp then
      (((.end_timestamp | fromdateiso8601) - (.start_timestamp | fromdateiso8601)) / 60 | floor | tostring) + " minutes"
    else "Unknown"
    end
  ) + "\n" +
  "Interactions: " + (.interactions | length | tostring) + "\n" +
  "Tools: " + ([.interactions[] | select(.type == "tool_call") | .content.tool] | unique | join(", "))
' "$LOG_FILE")

curl -s -X POST "$DISCORD_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d "{\"content\": \"$summary\"}"
```

## API Server

### Simple Flask API

```python
#!/usr/bin/env python3
# session_api.py - Simple API for session logs

from flask import Flask, jsonify
import json
import os
from glob import glob

app = Flask(__name__)
LOG_DIR = ".claude/session_logs"

@app.route("/sessions")
def list_sessions():
    sessions = []
    for log_file in glob(f"{LOG_DIR}/session_*.json"):
        with open(log_file) as f:
            data = json.load(f)
            sessions.append({
                "session_id": data["session_id"],
                "start": data["start_timestamp"],
                "end": data.get("end_timestamp"),
                "interactions": len(data["interactions"])
            })
    return jsonify(sessions)

@app.route("/sessions/<session_id>")
def get_session(session_id):
    for log_file in glob(f"{LOG_DIR}/session_*.json"):
        with open(log_file) as f:
            data = json.load(f)
            if data["session_id"] == session_id:
                return jsonify(data)
    return jsonify({"error": "Session not found"}), 404

@app.route("/sessions/<session_id>/interactions")
def get_interactions(session_id):
    for log_file in glob(f"{LOG_DIR}/session_*.json"):
        with open(log_file) as f:
            data = json.load(f)
            if data["session_id"] == session_id:
                return jsonify(data["interactions"])
    return jsonify({"error": "Session not found"}), 404

if __name__ == "__main__":
    app.run(port=5000)
```

## Security Considerations

### Sensitive Data Filtering

Add filtering before export:

```bash
#!/bin/bash
# filter_sensitive.sh - Remove sensitive data from logs

LOG_FILE="$1"
OUTPUT_FILE="$2"

# Patterns to redact
jq '
  .interactions |= map(
    if .content then
      .content |= (
        if type == "string" then
          gsub("(?i)(password|secret|api_key|token)\\s*[=:]\\s*\\S+"; "[REDACTED]")
        else
          .
        end
      )
    else
      .
    end
  )
' "$LOG_FILE" > "$OUTPUT_FILE"
```

### Access Control

```bash
# Set restrictive permissions on log directory
chmod 700 .claude/session_logs
chmod 600 .claude/session_logs/*.json
```
