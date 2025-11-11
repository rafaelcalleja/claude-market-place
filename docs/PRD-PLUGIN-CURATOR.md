# PRD: Plugin Curator & Marketplace Builder

**Version:** 1.0.0
**Created:** 2025-11-11
**Status:** Draft - For Review
**Author:** Based on Codex CLI Analysis + User Requirements

---

## 🎯 Executive Summary

### Vision
Create a comprehensive system to **curate, compose, and version new Claude Code plugins and marketplaces** by selecting, copying, and assembling individual components (commands, agents, skills, hooks, MCPs) from existing installed plugins.

### Problem Statement
Currently:
- Plugins are monolithic units (all-or-nothing activation)
- No way to mix components from multiple plugins into a new curated plugin
- Cannot create customized marketplaces tailored for specific workflows
- No versioning system for curated component compositions
- Manual copying and file management is error-prone

### Solution
A **Plugin Curator & Marketplace Builder** system that:
1. Discovers and indexes all installed Claude Code plugins
2. Allows granular selection of individual components across plugins
3. Creates new curated plugins by copying/moving selected components
4. Generates proper manifests and metadata for new plugins
5. Versions curated plugins and tracks component sources
6. Builds custom marketplaces from curated plugins
7. Validates dependencies and resolves conflicts automatically

---

## 🏗️ System Architecture

### High-Level Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: DISCOVERY                           │
│  Scan installed Claude Code plugins from all sources            │
│  - User plugins (~/.claude/plugins)                             │
│  - Project plugins (.claude/plugins)                            │
│  - Marketplace plugins (.claude/plugins/marketplaces/*)         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: INDEXING                            │
│  Build component inventory with metadata                        │
│  - Commands: path, frontmatter, dependencies                    │
│  - Agents: path, description, tools                             │
│  - Skills: path, SKILL.md metadata                              │
│  - Hooks: event, matcher, command                               │
│  - MCPs: server name, config, dependencies                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 3: CURATION                            │
│  Interactive/programmatic component selection                   │
│  - Browse component catalog                                     │
│  - Filter by type, source plugin, tags                          │
│  - Select components for new plugin                             │
│  - Define curation rules (profiles, presets)                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 4: COMPOSITION                         │
│  Create new plugin from selected components                     │
│  - Copy components to new plugin structure                      │
│  - Generate plugin.json manifest                                │
│  - Generate hooks.json (filtered)                               │
│  - Generate .mcp.json (filtered)                                │
│  - Resolve and validate dependencies                            │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 5: VERSIONING                          │
│  Track component sources and versions                           │
│  - Generate curation manifest (provenance)                      │
│  - Lock component versions                                      │
│  - Track updates to source components                           │
│  - Generate changelog for curated plugin                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 6: MARKETPLACE BUILDING                │
│  Compose multiple curated plugins into marketplace              │
│  - Generate marketplace.json                                    │
│  - Validate cross-plugin conflicts                              │
│  - Build distribution package                                   │
│  - Generate documentation                                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Core Features

### Feature 1: Plugin Discovery & Indexing

**User Story:**
> As a plugin curator, I want to discover and catalog all installed Claude Code plugins and their components, so I can understand what's available to compose into new plugins.

**Functionality:**
- Scan multiple plugin sources:
  - `~/.claude/plugins/` (user global)
  - `<project>/.claude/plugins/` (project-local)
  - `<marketplace>/.claude-plugin/marketplace.json` → plugins
- Extract component metadata:
  - **Commands:** frontmatter (name, description, allowed-tools, requires)
  - **Agents:** frontmatter (name, description, tools)
  - **Skills:** SKILL.md metadata
  - **Hooks:** hooks.json structure
  - **MCPs:** .mcp.json server definitions
- Build searchable index:
  - Component type, source plugin, path, metadata
  - Dependencies (requires), tags, categories

**Technical Spec:**
```typescript
interface ComponentIndex {
  version: string;
  generated: string; // ISO timestamp
  sources: PluginSource[];
  components: {
    commands: CommandMeta[];
    agents: AgentMeta[];
    skills: SkillMeta[];
    hooks: HookMeta[];
    mcpServers: McpServerMeta[];
  };
}

interface CommandMeta {
  id: string;           // plugin:path
  sourcePlugin: string;
  path: string;
  name: string;
  description: string;
  allowedTools?: string[];
  argumentHint?: string;
  requires?: Requires;
  tags?: string[];
}
```

**CLI Commands:**
```bash
# Discover and index all plugins
claude-curator discover

# Show component inventory
claude-curator list [--type commands|agents|skills|hooks|mcp]

# Search components
claude-curator search "authentication" --type commands

# Show component details
claude-curator show superclaude-framework:commands/help.md
```

---

### Feature 2: Component Curation Interface

**User Story:**
> As a plugin curator, I want to interactively select specific components from multiple plugins, so I can compose a new plugin tailored to my workflow.

**Functionality:**
- **Interactive TUI** (Terminal UI):
  - Browse component tree by plugin
  - Multi-select components (checkboxes)
  - Preview component metadata
  - See dependencies in real-time
  - Add/remove components to curation
- **Declarative Configuration**:
  - Define curation in YAML/JSON
  - Support for profiles and presets
  - Version-lockable selections

**Technical Spec:**
```yaml
# curation.yaml
name: my-curated-plugin
version: 1.0.0
description: Custom plugin for frontend development
author:
  name: Your Name
  email: you@example.com

# Component selection
components:
  # From superclaude-framework
  - source: superclaude-framework
    type: commands
    select:
      - commands/help.md
      - commands/design.md
      - commands/implement.md

  - source: superclaude-framework
    type: agents
    select:
      - agents/frontend-architect.md
      - agents/technical-writer.md

  # From claudekit-skills
  - source: claudekit-skills
    type: skills
    select:
      - skills/better-auth/
      - skills/chrome-devtools/

  # From fabric-helper
  - source: fabric-helper
    type: commands
    select:
      - commands/suggest.md

# Rename components (avoid conflicts)
rename:
  "commands/help.md": "commands/framework-help.md"

# Override metadata
overrides:
  name: "Frontend Dev Toolkit"
  description: "Curated tools for modern frontend development"

# Dependency resolution
dependencies:
  mcpServers:
    include:
      - sequential-thinking
      - playwright
    exclude:
      - serena

  hooks:
    SessionStart:
      - init-frontend-env
```

**CLI Commands:**
```bash
# Start interactive curation
claude-curator create --interactive

# Create from curation file
claude-curator create --config curation.yaml

# Add component to curation
claude-curator add superclaude-framework:commands/help.md

# Remove component
claude-curator remove commands/help.md

# Preview curated plugin (dry-run)
claude-curator preview

# Validate curation (dependencies, conflicts)
claude-curator validate
```

---

### Feature 3: Plugin Composition & Generation

**User Story:**
> As a plugin curator, I want to automatically generate a properly structured plugin from my selected components, including manifests and dependency resolution.

**Functionality:**
- **Copy/Move Components**:
  - Smart copy (preserve structure)
  - Optional renaming (conflict resolution)
  - Update internal references
- **Manifest Generation**:
  - `plugin.json` with component paths
  - `hooks.json` (filtered from sources)
  - `.mcp.json` (filtered from sources)
  - `README.md` (generated)
- **Dependency Resolution**:
  - Analyze component dependencies
  - Include required MCPs, hooks, agents
  - Warn about missing dependencies
  - Suggest additional components
- **Conflict Detection**:
  - Command name collisions
  - Hook event conflicts
  - MCP server duplicates

**Technical Spec:**
```typescript
interface CompositionResult {
  plugin: {
    name: string;
    path: string;
    manifest: PluginManifest;
  };
  components: {
    copied: ComponentCopy[];
    renamed: ComponentRename[];
    skipped: ComponentSkip[];
  };
  dependencies: {
    resolved: Dependency[];
    missing: Dependency[];
    conflicts: Conflict[];
  };
  warnings: Warning[];
  errors: Error[];
}
```

**Output Structure:**
```
curated-plugins/
  my-curated-plugin/
    .claude-plugin/
      plugin.json
      curation.json          # Provenance tracking
      components.lock.json   # Version locks
    commands/
      help.md
      design.md
      implement.md
    agents/
      frontend-architect.md
      technical-writer.md
    skills/
      better-auth/
      chrome-devtools/
    hooks/
      hooks.json
    .mcp.json
    README.md
    CHANGELOG.md
```

---

### Feature 4: Provenance & Versioning

**User Story:**
> As a plugin curator, I want to track where each component came from and lock versions, so I can maintain consistency and handle updates properly.

**Functionality:**
- **Provenance Tracking**:
  - Record source plugin, version, path for each component
  - Generate `curation.json` manifest
  - Track curation date, author, rationale
- **Version Locking**:
  - Lock component versions (SHA/commit hash)
  - Detect updates to source components
  - Diff between locked and current versions
- **Update Management**:
  - List available updates
  - Selective update (per component)
  - Regenerate plugin with updates

**Technical Spec:**
```json
// .claude-plugin/curation.json
{
  "version": "1",
  "name": "my-curated-plugin",
  "curated": "2025-11-11T10:00:00Z",
  "curator": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "sources": [
    {
      "plugin": "superclaude-framework",
      "version": "4.1.5",
      "commit": "5374c58...",
      "components": [
        {
          "type": "command",
          "original": "commands/help.md",
          "curated": "commands/help.md",
          "sha256": "abc123...",
          "modified": false
        }
      ]
    }
  ],
  "dependencies": {
    "mcpServers": ["sequential-thinking", "playwright"],
    "requiredBy": {
      "commands/design.md": {
        "agents": ["frontend-architect.md"],
        "mcpServers": ["sequential-thinking"]
      }
    }
  },
  "changeLog": [
    {
      "date": "2025-11-11",
      "version": "1.0.0",
      "changes": ["Initial curation"]
    }
  ]
}
```

**CLI Commands:**
```bash
# Show provenance
claude-curator provenance

# Check for updates
claude-curator check-updates

# Update specific component
claude-curator update commands/help.md

# Update all components
claude-curator update --all

# Lock current versions
claude-curator lock

# Show diff from source
claude-curator diff commands/help.md
```

---

### Feature 5: Marketplace Builder

**User Story:**
> As a marketplace creator, I want to compose multiple curated plugins into a cohesive marketplace with proper validation and documentation.

**Functionality:**
- **Marketplace Composition**:
  - Select multiple curated plugins
  - Generate `marketplace.json`
  - Validate cross-plugin compatibility
  - Detect command/agent/skill conflicts
- **Distribution Packaging**:
  - Bundle marketplace for distribution
  - Generate installation instructions
  - Create documentation site
- **Validation & Testing**:
  - Run `claude plugin validate` on all plugins
  - Test plugin loading
  - Generate compatibility matrix

**Technical Spec:**
```yaml
# marketplace.yaml
name: frontend-toolkit-marketplace
version: 1.0.0
description: Complete frontend development toolkit
owner:
  name: Your Organization
  email: org@example.com

plugins:
  - name: react-dev-toolkit
    source: ./curated-plugins/react-dev-toolkit
    version: 1.0.0

  - name: vue-dev-toolkit
    source: ./curated-plugins/vue-dev-toolkit
    version: 1.0.0

  - name: testing-toolkit
    source: ./curated-plugins/testing-toolkit
    version: 1.0.0

# Cross-plugin validation
validation:
  allowCommandConflicts: false
  allowMcpDuplicates: true
  strictDependencies: true

# Distribution
distribution:
  format: git
  repository: https://github.com/org/frontend-toolkit-marketplace
  releaseBranch: main
```

**CLI Commands:**
```bash
# Create marketplace from curated plugins
claude-curator marketplace create --config marketplace.yaml

# Add plugin to marketplace
claude-curator marketplace add my-curated-plugin

# Validate marketplace
claude-curator marketplace validate

# Build distribution package
claude-curator marketplace build

# Generate documentation
claude-curator marketplace docs
```

---

## 🎨 User Experience

### Workflow Example 1: Interactive Curation

```bash
$ claude-curator discover
✓ Discovered 15 plugins
✓ Indexed 247 components
  - 89 commands
  - 45 agents
  - 78 skills
  - 23 hooks
  - 12 MCP servers

$ claude-curator create --interactive

┌─────────────────────────────────────────────────────────────┐
│ Claude Plugin Curator                                       │
│ Create a new curated plugin from existing components        │
└─────────────────────────────────────────────────────────────┘

Plugin Name: frontend-dev-toolkit
Description: Tools for modern frontend development
Author: Your Name <you@example.com>

┌─ Select Components ─────────────────────────────────────────┐
│ Source Plugins (3 selected)                                 │
│ ☑ superclaude-framework (4.1.5)                             │
│ ☐ fabric-helper (1.2.0)                                     │
│ ☑ claudekit-skills (2.0.1)                                  │
│ ☑ personal-ai-infrastructure (1.0.0)                        │
│                                                              │
│ Components (12 selected)                                    │
│ Commands (5)                                                │
│   ☑ superclaude-framework:commands/design.md               │
│   ☑ superclaude-framework:commands/implement.md            │
│   ☐ fabric-helper:commands/suggest.md                      │
│                                                              │
│ Agents (3)                                                  │
│   ☑ superclaude-framework:agents/frontend-architect.md     │
│   ☑ superclaude-framework:agents/technical-writer.md       │
│                                                              │
│ Skills (4)                                                  │
│   ☑ claudekit-skills:skills/better-auth/                   │
│   ☑ claudekit-skills:skills/chrome-devtools/               │
└─────────────────────────────────────────────────────────────┘

[Space] Toggle  [Enter] Confirm  [q] Quit

Validating selection...
✓ No dependency conflicts
✓ No command name collisions
⚠ Warning: commands/design.md requires MCP 'sequential-thinking'
  → Automatically included in .mcp.json

Generate plugin? [Y/n] y

Creating plugin at ./curated-plugins/frontend-dev-toolkit...
✓ Copied 12 components
✓ Generated plugin.json
✓ Generated hooks.json
✓ Generated .mcp.json
✓ Generated README.md
✓ Created curation.json (provenance)

Plugin created successfully!

Next steps:
  cd curated-plugins/frontend-dev-toolkit
  claude plugin validate .
  claude plugin install .
```

### Workflow Example 2: Declarative Curation

```bash
$ cat curation.yaml
name: my-security-toolkit
version: 1.0.0
components:
  - source: superclaude-framework
    type: agents
    select:
      - agents/security-engineer.md
      - agents/root-cause-analyst.md
  - source: personal-ai-infrastructure
    type: commands
    select:
      - commands/pentester.md

$ claude-curator create --config curation.yaml --output ./curated-plugins/security-toolkit

✓ Validated curation.yaml
✓ Created plugin at ./curated-plugins/security-toolkit
✓ All dependencies resolved

$ claude-curator provenance --plugin security-toolkit

Curation Provenance:
├─ Plugin: my-security-toolkit v1.0.0
├─ Created: 2025-11-11 10:30:00
├─ Curator: Your Name <you@example.com>
│
└─ Components (3):
   ├─ agents/security-engineer.md
   │  ├─ Source: superclaude-framework v4.1.5
   │  ├─ SHA256: abc123...
   │  └─ Modified: No
   │
   ├─ agents/root-cause-analyst.md
   │  ├─ Source: superclaude-framework v4.1.5
   │  ├─ SHA256: def456...
   │  └─ Modified: No
   │
   └─ commands/pentester.md
      ├─ Source: personal-ai-infrastructure v1.0.0
      ├─ SHA256: ghi789...
      └─ Modified: No
```

---

## 🔧 Technical Implementation

### Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| **CLI** | Node.js + Commander.js | Matches existing Claude Code ecosystem |
| **TUI** | Ink (React for CLI) | Rich interactive experience |
| **Validation** | Ajv + JSON Schema | Robust schema validation |
| **File Ops** | fs-extra | Reliable file operations |
| **Glob Matching** | fast-glob + minimatch | Component discovery |
| **YAML Parsing** | js-yaml | Curation config format |
| **Hashing** | crypto (Node built-in) | Component versioning |
| **Git Integration** | simple-git | Provenance tracking |

### File Structure

```
claude-curator/
├── src/
│   ├── cli/
│   │   ├── index.ts          # Main CLI entry
│   │   ├── discover.ts       # Discovery command
│   │   ├── create.ts         # Creation command
│   │   ├── marketplace.ts    # Marketplace builder
│   │   └── ui/
│   │       ├── interactive.tsx  # Interactive TUI (Ink)
│   │       └── components/
│   ├── core/
│   │   ├── indexer.ts        # Component indexing
│   │   ├── curator.ts        # Curation logic
│   │   ├── composer.ts       # Plugin composition
│   │   ├── validator.ts      # Validation engine
│   │   └── versioner.ts      # Version tracking
│   ├── schemas/
│   │   ├── curation.schema.json
│   │   ├── marketplace.schema.json
│   │   └── provenance.schema.json
│   └── utils/
│       ├── file-ops.ts
│       ├── dependency-resolver.ts
│       └── conflict-detector.ts
├── templates/
│   ├── plugin.json.hbs
│   ├── README.md.hbs
│   └── marketplace.json.hbs
├── tests/
├── docs/
└── package.json
```

### Key Algorithms

#### 1. Component Discovery
```typescript
async function discoverComponents(pluginPath: string): Promise<ComponentIndex> {
  const commands = await glob('commands/**/*.md', { cwd: pluginPath });
  const agents = await glob('agents/**/*.md', { cwd: pluginPath });
  const skills = await glob('skills/*/', { cwd: pluginPath });

  const index: ComponentIndex = {
    version: '1',
    generated: new Date().toISOString(),
    sources: [],
    components: {
      commands: await Promise.all(commands.map(parseCommand)),
      agents: await Promise.all(agents.map(parseAgent)),
      skills: await Promise.all(skills.map(parseSkill)),
      hooks: await parseHooks(pluginPath),
      mcpServers: await parseMcpServers(pluginPath)
    }
  };

  return index;
}
```

#### 2. Dependency Resolution
```typescript
function resolveDependencies(
  components: Component[],
  index: ComponentIndex
): DependencyGraph {
  const graph = new Map<string, Dependency[]>();

  for (const component of components) {
    const deps: Dependency[] = [];

    // Extract from frontmatter
    if (component.requires) {
      deps.push(...component.requires.mcpServers.map(s => ({
        type: 'mcp',
        name: s
      })));
      deps.push(...component.requires.agents.map(a => ({
        type: 'agent',
        name: a
      })));
    }

    // Infer from content (optional)
    const inferred = inferDependencies(component.content);
    deps.push(...inferred);

    graph.set(component.id, deps);
  }

  // Detect cycles
  const cycles = detectCycles(graph);
  if (cycles.length > 0) {
    throw new Error(`Circular dependencies: ${cycles.join(', ')}`);
  }

  return graph;
}
```

#### 3. Conflict Detection
```typescript
function detectConflicts(
  curations: Curation[]
): Conflict[] {
  const conflicts: Conflict[] = [];
  const commandNames = new Map<string, string[]>();

  // Check command name collisions
  for (const curation of curations) {
    for (const cmd of curation.components.commands) {
      const name = extractCommandName(cmd);
      if (!commandNames.has(name)) {
        commandNames.set(name, []);
      }
      commandNames.get(name)!.push(curation.name);
    }
  }

  for (const [name, plugins] of commandNames) {
    if (plugins.length > 1) {
      conflicts.push({
        type: 'command-collision',
        name,
        plugins,
        severity: 'error'
      });
    }
  }

  return conflicts;
}
```

---

## 📊 Data Models

### Component Index Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "ComponentIndex",
  "type": "object",
  "properties": {
    "version": { "type": "string" },
    "generated": { "type": "string", "format": "date-time" },
    "sources": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "name": { "type": "string" },
          "path": { "type": "string" },
          "version": { "type": "string" },
          "manifest": { "type": "object" }
        },
        "required": ["name", "path"]
      }
    },
    "components": {
      "type": "object",
      "properties": {
        "commands": { "$ref": "#/definitions/CommandMeta" },
        "agents": { "$ref": "#/definitions/AgentMeta" },
        "skills": { "$ref": "#/definitions/SkillMeta" },
        "hooks": { "$ref": "#/definitions/HookMeta" },
        "mcpServers": { "$ref": "#/definitions/McpServerMeta" }
      }
    }
  },
  "required": ["version", "generated", "components"]
}
```

### Curation Manifest Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CurationManifest",
  "type": "object",
  "properties": {
    "version": { "type": "string" },
    "name": { "type": "string" },
    "curated": { "type": "string", "format": "date-time" },
    "curator": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "email": { "type": "string", "format": "email" }
      }
    },
    "sources": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "plugin": { "type": "string" },
          "version": { "type": "string" },
          "commit": { "type": "string" },
          "components": {
            "type": "array",
            "items": {
              "type": "object",
              "properties": {
                "type": { "enum": ["command", "agent", "skill", "hook", "mcp"] },
                "original": { "type": "string" },
                "curated": { "type": "string" },
                "sha256": { "type": "string" },
                "modified": { "type": "boolean" }
              },
              "required": ["type", "original", "curated", "sha256"]
            }
          }
        },
        "required": ["plugin", "version", "components"]
      }
    }
  },
  "required": ["version", "name", "curated", "curator", "sources"]
}
```

---

## 🎯 Success Metrics

### MVP Metrics (Phase 1)
- [ ] Successfully discover and index all plugins in test environment
- [ ] Create 3 curated plugins from existing components
- [ ] Generate valid plugin manifests passing `claude plugin validate`
- [ ] Track provenance for 100% of curated components

### Beta Metrics (Phase 2)
- [ ] Interactive TUI completes curation in < 5 minutes
- [ ] Dependency resolution accuracy > 95%
- [ ] Conflict detection catches 100% of name collisions
- [ ] Update detection works for all component types

### Production Metrics (Phase 3)
- [ ] Build 5 custom marketplaces with curated plugins
- [ ] < 1% error rate in plugin composition
- [ ] Documentation coverage for all features
- [ ] Community adoption: 10+ curated plugins created

---

## 🚀 Implementation Phases

### Phase 1: Foundation (Weeks 1-2)
**Goal:** Basic discovery, indexing, and simple curation

- [ ] Implement plugin discovery from all sources
- [ ] Build component indexer (commands, agents, skills)
- [ ] Create CLI commands: `discover`, `list`, `search`
- [ ] Implement basic component copying
- [ ] Generate minimal plugin.json

**Deliverables:**
- `claude-curator discover` working
- Component index JSON output
- Basic `claude-curator create` from config file

---

### Phase 2: Curation & Validation (Weeks 3-4)
**Goal:** Declarative curation with validation

- [ ] Implement curation.yaml parser
- [ ] Build dependency resolver
- [ ] Add conflict detector
- [ ] Generate hooks.json and .mcp.json
- [ ] Implement validation engine

**Deliverables:**
- Full `create --config curation.yaml` workflow
- Dependency warnings and errors
- Conflict detection reports

---

### Phase 3: Interactive TUI (Weeks 5-6)
**Goal:** Rich interactive curation experience

- [ ] Build Ink-based interactive UI
- [ ] Component tree browser
- [ ] Multi-select with real-time preview
- [ ] Dependency visualization
- [ ] Conflict resolution prompts

**Deliverables:**
- `claude-curator create --interactive`
- Full TUI workflow

---

### Phase 4: Provenance & Versioning (Weeks 7-8)
**Goal:** Component tracking and updates

- [ ] Generate curation.json with provenance
- [ ] Implement SHA256 hashing for components
- [ ] Build update checker
- [ ] Create diff viewer
- [ ] Add version locking

**Deliverables:**
- `provenance`, `check-updates`, `update` commands
- components.lock.json generation

---

### Phase 5: Marketplace Builder (Weeks 9-10)
**Goal:** Multi-plugin marketplace composition

- [ ] Marketplace composition from curated plugins
- [ ] Cross-plugin validation
- [ ] Distribution packaging
- [ ] Documentation generation

**Deliverables:**
- `marketplace create` command
- Complete marketplace.json generation
- Distribution packages

---

### Phase 6: Polish & Documentation (Weeks 11-12)
**Goal:** Production-ready release

- [ ] Comprehensive error handling
- [ ] Full documentation
- [ ] Tutorial videos
- [ ] Example curations
- [ ] Testing suite (unit + integration)

**Deliverables:**
- 1.0.0 release
- Complete documentation site
- 5+ example curated plugins

---

## 🔒 Security & Privacy

### Component Provenance
- **SHA256 hashing** of all copied components
- **Git commit tracking** for source plugins
- **Curator attribution** in curation.json
- **License propagation** from source plugins

### Dependency Validation
- **Static analysis** of component requires
- **Runtime validation** of MCP availability
- **Conflict warnings** before installation
- **Sandbox testing** (optional)

### Distribution Security
- **Marketplace signing** (optional GPG)
- **Component integrity** verification
- **Update authenticity** checks
- **Source verification** for updates

---

## 📖 Documentation Plan

### User Documentation
1. **Quick Start Guide**
   - Installation
   - First curation
   - Publishing marketplace

2. **Reference**
   - CLI command reference
   - curation.yaml schema
   - marketplace.yaml schema

3. **Tutorials**
   - Creating a curated plugin
   - Building a marketplace
   - Updating components
   - Resolving conflicts

4. **Examples**
   - Frontend toolkit
   - Security toolkit
   - Testing toolkit
   - DevOps toolkit

### Developer Documentation
1. **Architecture**
   - System design
   - Data models
   - Algorithms

2. **API Reference**
   - Indexer API
   - Curator API
   - Validator API

3. **Contributing**
   - Setup development environment
   - Running tests
   - Submitting PRs

---

## 🤔 Open Questions & Decisions

### Q1: Component Modification
**Question:** Should users be able to modify components after curation?

**Options:**
1. **Read-only** - Components are exact copies, modifications require forking
2. **Allow edits** - Track modifications in provenance with `modified: true`
3. **Hybrid** - Allow metadata edits, prevent content changes

**Recommendation:** Option 2 (Allow edits) with clear tracking

---

### Q2: Update Strategy
**Question:** How should updates to source components be handled?

**Options:**
1. **Manual** - User must explicitly update each component
2. **Automatic** - Auto-update on `curator update`
3. **Semver-aware** - Auto-update patches, prompt for majors

**Recommendation:** Option 3 (Semver-aware) with lock file override

---

### Q3: Marketplace Distribution
**Question:** How should curated marketplaces be distributed?

**Options:**
1. **Git repository** - Clone to install
2. **npm package** - Standard package manager
3. **Claude marketplace** - Official Claude distribution
4. **Tarball** - Self-contained archive

**Recommendation:** Support all 4 (configurable in marketplace.yaml)

---

### Q4: Conflict Resolution
**Question:** How to handle command name conflicts between plugins?

**Options:**
1. **Block** - Error and require manual resolution
2. **Namespace** - Auto-rename to `plugin:command`
3. **Priority** - First plugin wins, warn about collision

**Recommendation:** Option 1 (Block) with suggestion for Option 2

---

## 🎉 Future Enhancements

### v2.0 Features
- [ ] **AI-powered curation suggestions**
  - Analyze workflow and suggest relevant components
  - Auto-detect missing dependencies

- [ ] **Component marketplace**
  - Public registry of curated plugins
  - Community ratings and reviews

- [ ] **Visual editor**
  - Web-based drag-and-drop curation
  - Dependency graph visualization

- [ ] **Testing framework**
  - Automated testing of curated plugins
  - Compatibility matrix generation

### v3.0 Features
- [ ] **Dynamic loading**
  - Enable/disable components at runtime
  - Hot-reload without restart

- [ ] **Component analytics**
  - Track component usage
  - Popularity metrics

- [ ] **Collaborative curation**
  - Team-based curation workflows
  - Review and approval process

---

## 📝 Appendix

### A. Related Systems
- **npm** - Package composition and versioning
- **Docker** - Layered composition and provenance
- **Webpack** - Module bundling and dependency resolution
- **Nix** - Declarative package management

### B. References
- Claude Code Plugin Documentation: https://docs.claude.com/en/docs/claude-code/plugins
- Codex CLI Analysis: Stored in this repository
- Marketplace Schema: `.claude-plugin/marketplace.json`

### C. Glossary
- **Component**: Individual piece (command, agent, skill, hook, MCP)
- **Curation**: Process of selecting components
- **Composition**: Combining components into new plugin
- **Provenance**: Origin tracking of components
- **Marketplace**: Collection of plugins

---

**END OF PRD**

---

## Review & Approval

| Stakeholder | Role | Status | Date | Notes |
|-------------|------|--------|------|-------|
| Product Owner | Decision Maker | ⏳ Pending | - | - |
| Tech Lead | Technical Review | ⏳ Pending | - | - |
| UX Designer | UX Review | ⏳ Pending | - | - |
| Security | Security Review | ⏳ Pending | - | - |

---

**Document Version:** 1.0.0
**Last Updated:** 2025-11-11
**Next Review:** 2025-11-18
