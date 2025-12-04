# ThoughtStream Recorder

**Intelligent Session Recording for Claude Code with Semantic Annotation**

## Overview

ThoughtStream Recorder is an advanced Claude Code skill that goes beyond simple interaction logging to capture the **reasoning, decisions, and context** behind every action. It creates a searchable, analyzable history of not just what happened, but *why* it happened.

## What Makes This Unique

Unlike traditional session loggers that only capture commands and outputs, ThoughtStream Recorder implements a **three-layer architecture**:

1. **Automatic Capture Layer** (Hooks) - Zero-config recording of all interactions
2. **Semantic Annotation Layer** (Self-Reporting) - Claude annotates decision points with reasoning
3. **Pattern Recognition Layer** (Post-Processing) - Identifies workflows and problem-solving patterns

## Key Innovations

- **JSONL format** - Lock-free atomic appends, stream processing, corruption resilience
- **Semantic categories** - bug_fix, feature_add, refactor, investigation, optimization
- **Decision capture** - Records alternatives considered and reasoning behind choices
- **Output hashing** - SHA256 hashes for large outputs to prevent log bloat
- **Session queries** - Built-in search tool for finding past decisions
- **Pattern detection** - Identifies repeated workflows and strategies
- **Session replay** - Reconstruct decision paths from history

## Generation Process

This prompt was created using a rigorous **Fabric AI workflow**:

### Process Flow

```
1. Research (claude-code-guide agent)
   ↓
2. Sequential Thinking (--seq, 25 thoughts)
   ↓
3. Design 7 different approaches
   ↓
4. User selected: Enfoque 2 (Hybrid)
   ↓
5. Draft prompt creation
   ↓
6. Fabric AI: improve_prompt + cot strategy
   ↓
7. Fabric AI: analyze_prose + reflexion strategy
   ↓
8. Identified gaps & improvements
   ↓
9. Final prompt v2 with innovations
```

### Fabric AI Analysis Results

**Initial Version (Post improve_prompt):**
- Novelty: D (Derivative)
- Clarity: A (Crystal)
- Prose: C (Standard)
- Overall: C

**Final Version (Post reflexion):**
- Added 10+ innovations
- Changed from JSON to JSONL
- Added semantic annotation system
- Included pattern detection
- Added query and replay capabilities

### Tools Used

- **Sequential Thinking MCP** - Deep reasoning (25 thought steps)
- **Fabric AI Patterns** - `improve_prompt`, `analyze_prose`, `extract_patterns`
- **Fabric AI Strategies** - `cot` (Chain of Thought), `reflexion`
- **Claude Code Guide Agent** - Official documentation research

## Architecture Highlights

### Data Format

**JSONL** (JSON Lines) instead of single JSON:
```jsonl
{"type":"session_start","session_id":"uuid","timestamp":"ISO-8601",...}
{"type":"user_message","id":"uuid","content":"Fix auth bug",...}
{"type":"assistant_annotation","category":"bug_fix","summary":"Found race condition",...}
```

### Semantic Annotation

Claude self-reports with rich context:
```bash
bash annotate.sh \
  --category "bug_fix" \
  --summary "Resolved authentication race condition" \
  --reasoning "Token cache accessed without synchronization" \
  --alternatives "Mutex,Thread-local storage,Redesign cache" \
  --chosen "Mutex - minimal risk, proven pattern"
```

### Components

- **4 Hook Scripts** - Automatic event capture
- **1 Annotation Helper** - Self-reporting tool
- **1 Query Tool** - Search session history
- **1 Index Generator** - Fast lookups
- **SKILL.md** - Instructions for Claude

## Success Criteria

- ✅ Zero-configuration automatic capture
- ✅ < 10ms overhead per interaction
- ✅ Queryable history across sessions
- ✅ Support for 10,000+ interactions per file
- ✅ Pattern detection (3+ workflows per project)

## Use Cases

1. **Debugging** - Trace decision paths that led to bugs
2. **Learning** - Review problem-solving strategies
3. **Documentation** - Auto-generate decision logs
4. **Workflow Extraction** - Identify and templatize common patterns
5. **Team Handoff** - Share context with complete reasoning
6. **Metrics** - Analyze time spent, tools used, success rates

## Comparison: ThoughtStream vs Traditional Logging

| Feature | Traditional Logger | ThoughtStream |
|---------|-------------------|---------------|
| Captures commands | ✅ | ✅ |
| Captures outputs | ✅ | ✅ |
| Captures reasoning | ❌ | ✅ |
| Captures alternatives | ❌ | ✅ |
| Semantic categories | ❌ | ✅ |
| Pattern detection | ❌ | ✅ |
| Decision replay | ❌ | ✅ |
| Queryable history | ❌ | ✅ |
| Output hashing | ❌ | ✅ |
| Lock-free writes | ❌ | ✅ |

## Implementation

Use `prompt.md` in this directory to generate the complete skill implementation with Claude Code or Claude.ai.

The prompt will generate:
- All hook scripts with full implementation
- Complete SKILL.md with examples
- claude.json hook configuration
- Query tool
- Session index generator
- Installation guide
- Usage examples

## Performance Targets

- **Overhead**: < 10ms per interaction
- **Scalability**: 10,000+ interactions per session
- **Storage**: Efficient with output hashing
- **Query Speed**: Fast searches on large logs
- **Concurrency**: Lock-free, corruption-resistant

## Future Enhancements

- ML-based pattern recognition
- Auto-generated workflow templates
- Visual decision tree rendering
- Integration with CI/CD pipelines
- Team analytics dashboard
- Session comparison tools

---

**Generated**: 2025-12-02
**Method**: Fabric AI + Sequential Thinking + Claude Code Research
**Approach**: Enfoque 2 (Hybrid) + Innovations from Reflexion
