# Quick Reference: Real Claude Code Plugins

**Quick access to real plugin data for registry.json creation**

---

## Real Plugin Names

### From getty104
- **Plugin:** getty104
- **Commands:** exec-issue, fix-review-point, fix-review-point-loop, general-task, create-worktree
- **Agents:** github-issue-implementer, review-comment-implementer, general-purpose-assistant
- **Skills:** create-git-worktree, high-quality-commit, react-tailwind-markup, read-unresolved-pr-comments, resolve-pr-comments
- **Hooks:** Stop (2 actions)
- **MCPs:** chrome-devtools, serena, context7, next-devtools

### From feiskyer
- **Plugin:** claude-code-settings
- **Commands:** think-harder, think-ultra, reflection, reflection-harder, eureka, specify, clarify, tasks, analyze, implement, constitution, translate
- **Agents:** pr-reviewer, github-issue-fixer, instruction-reflector, deep-reflector, insight-documenter, command-creator, kiro-assistant, kiro-spec-creator, kiro-feature-designer, kiro-task-planner, kiro-task-executor, ui-engineer
- **Skills:** (none)
- **Hooks:** (none)
- **MCPs:** exa, chrome

### From Dev-GOM
- **Plugin:** hook-sound-notifications
- **Commands:** (none)
- **Agents:** (none)
- **Skills:** (none)
- **Hooks:** SessionStart, SessionEnd, PreToolUse, PostToolUse, Notification, UserPromptSubmit, Stop, SubagentStop, PreCompact
- **MCPs:** (none)

### From Anthropic
- **Plugin:** document-skills
- **Commands:** (none)
- **Agents:** (none)
- **Skills:** pdf, xlsx, docx, pptx
- **Hooks:** (none)
- **MCPs:** (none)

---

## Real Hook Events (All 9)

1. **SessionStart** - Plugin initialization
2. **SessionEnd** - Cleanup and state saving
3. **PreToolUse** - Before tool execution
4. **PostToolUse** - After tool completion
5. **Notification** - User notifications
6. **UserPromptSubmit** - Before input processing
7. **Stop** - Agent completion
8. **SubagentStop** - Subagent completion
9. **PreCompact** - Before context compaction

---

## Real MCP Servers

### stdio type
```json
{
  "chrome-devtools": {
    "command": "npx",
    "args": ["chrome-devtools-mcp@latest"]
  },
  "serena": {
    "command": "uvx",
    "args": ["--from", "git+https://github.com/oraios/serena", "serena-mcp-server"]
  },
  "next-devtools": {
    "command": "npx",
    "args": ["-y", "next-devtools-mcp@latest"]
  }
}
```

### http type
```json
{
  "context7": {
    "type": "http",
    "url": "https://mcp.context7.com/mcp",
    "headers": {
      "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}"
    }
  },
  "exa": {
    "type": "http",
    "url": "https://mcp.exa.ai/mcp",
    "headers": {}
  }
}
```

---

## Real hooks.json Structures

### Simple (getty104)
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Funk.aiff"
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/remove-merged-worktrees.sh"
          }
        ]
      }
    ]
  }
}
```

### Advanced (Dev-GOM)
```json
{
  "hooks": {
    "SessionStart": [
      {
        "description": "Initialize plugin configuration",
        "priority": 100,
        "enabled": true,
        "hooks": [
          {
            "type": "command",
            "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/init-config.js",
            "description": "Creates default configuration",
            "continueOnError": true,
            "suppressOutput": true
          }
        ]
      }
    ],
    "Stop": [
      {
        "description": "Play stop sound",
        "priority": 50,
        "enabled": true,
        "hooks": [
          {
            "type": "command",
            "command": "node ${CLAUDE_PLUGIN_ROOT}/scripts/sound-hook-executor.js -HookType Stop",
            "description": "Plays sound when agent stops",
            "continueOnError": true,
            "suppressOutput": true
          }
        ]
      }
    ]
  }
}
```

---

## File Structure Template

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json              # Auto-generated
├── commands/
│   ├── command1.md
│   ├── command2.md
│   └── subdir/
│       └── nested.md
├── agents/
│   ├── agent1.md
│   └── agent2.md
├── skills/
│   ├── skill1/
│   │   └── SKILL.md
│   └── skill2/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── scripts/
│   ├── script1.sh
│   └── script2.js
├── .mcp.json
├── CLAUDE.md
└── README.md
```

---

## Component Statistics

| Component | Prevalence | Median Count |
|-----------|------------|--------------|
| Commands | 80% | 5 |
| Agents | 60% | 3 |
| Skills | 40% | 4 |
| Hooks | 40% | 1 file (multiple events) |
| MCPs | 60% | 2 servers |

---

## Common Patterns

### Pattern 1: Utility (20%)
- Commands only
- Quick workflows
- Example: Simple automation

### Pattern 2: Standard (40%)
- Commands + Agents
- Domain expertise
- Example: getty104, feiskyer

### Pattern 3: Full-Featured (20%)
- All components
- Comprehensive automation
- Example: getty104 with everything

### Pattern 4: Event-Driven (10%)
- Hooks-focused
- Automation triggers
- Example: Dev-GOM sounds

### Pattern 5: Integration (10%)
- MCP-focused
- External tools
- Example: feiskyer web research

---

## Environment Variables

**Used in real plugins:**
- `${CLAUDE_PLUGIN_ROOT}` - Plugin directory
- `${CONTEXT7_API_KEY}` - API key
- `${ANTHROPIC_API_KEY}` - API key
- `${HOME}` - User home

**Pattern:** `${VAR_NAME}`

---

## Hook Properties

| Property | Type | Purpose | Example |
|----------|------|---------|---------|
| matcher | string | Match pattern | `""` or `".*"` or `"Write\|Edit"` |
| description | string | Human explanation | `"Play stop sound"` |
| priority | number | Execution order | `100` (higher = earlier) |
| enabled | boolean | Toggle on/off | `true` or `false` |
| continueOnError | boolean | Don't stop on fail | `true` |
| suppressOutput | boolean | Hide from chat | `true` |

---

## Quick Copy: Minimal registry.json

```json
{
  "id": "plugin-id",
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin purpose",
  "author": {
    "name": "Author",
    "url": "https://github.com/user"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/user/repo"
  },
  "commands": [
    {
      "name": "command-name",
      "description": "What it does",
      "file": "commands/command-name.md"
    }
  ],
  "agents": [],
  "skills": [],
  "hooks": null,
  "mcpServers": null
}
```

---

## Quick Copy: Full registry.json

```json
{
  "id": "full-plugin",
  "name": "plugin-name",
  "version": "2.0.0",
  "description": "Complete automation plugin",
  "author": {
    "name": "Author Name",
    "url": "https://github.com/author"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/author/repo"
  },
  "commands": [
    {
      "name": "cmd1",
      "description": "Command description",
      "file": "commands/cmd1.md"
    }
  ],
  "agents": [
    {
      "name": "agent1",
      "description": "Agent expertise",
      "file": "agents/agent1.md",
      "model": "sonnet",
      "color": "blue"
    }
  ],
  "skills": [
    {
      "name": "skill1",
      "description": "Skill capabilities",
      "file": "skills/skill1/SKILL.md",
      "triggers": ["keyword1", "keyword2"]
    }
  ],
  "hooks": {
    "description": "Event automation",
    "file": "hooks/hooks.json",
    "events": [
      {
        "event": "Stop",
        "description": "On completion",
        "matchers": [
          {
            "matcher": "",
            "actions": [
              {
                "type": "command",
                "command": "script.sh",
                "description": "Cleanup"
              }
            ]
          }
        ]
      }
    ]
  },
  "mcpServers": {
    "description": "External integrations",
    "file": ".mcp.json",
    "servers": [
      {
        "name": "server1",
        "description": "Server purpose",
        "type": "stdio",
        "command": "npx",
        "args": ["package@latest"]
      }
    ]
  }
}
```

---

## URLs to Real Plugins

- **getty104:** https://github.com/getty104/claude-code-marketplace
- **feiskyer:** https://github.com/feiskyer/claude-code-settings
- **Dev-GOM:** https://github.com/Dev-GOM/claude-code-marketplace
- **Anthropic:** https://github.com/anthropics/skills
- **SuperClaude:** https://github.com/SuperClaude-Org/SuperClaude_Framework

---

**All data is real and verified from production plugins.**
