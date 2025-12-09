# Blogging Skill - Canonical Example

This is the **canonical example** of a properly structured skill. Use this as a template when creating new skills.

---

## File: Blogging/SKILL.md

```yaml
---
name: Blogging
description: Complete blog workflow for creating, editing, and publishing posts. USE WHEN user mentions doing anything with their blog, website, site, including things like update, proofread, write, edit, publish, preview, blog posts, or website pages.
---

# Blogging

Complete blog workflow management including content creation, editing, and publishing.

## Workflow Routing

**When executing a workflow, output this notification:**

Running the **WorkflowName** workflow from the **Blogging** skill...

| Workflow | Trigger | File |
|----------|---------|------|
| **Create** | "create post", "new blog post", "write article" | `workflows/Create.md` |
| **Edit** | "edit post", "update content", "revise article" | `workflows/Edit.md` |
| **Publish** | "publish post", "deploy article", "go live" | `workflows/Publish.md` |
| **Preview** | "preview post", "see draft", "check formatting" | `workflows/Preview.md` |

## Examples

**Example 1: Create a new blog post**
User: "I want to write a new blog post about TypeScript tips"
-> Invokes Create workflow
-> Asks for title, tags, and outline
-> Creates draft in content directory
-> Returns path to new draft file

**Example 2: Publish an existing draft**
User: "Publish my typescript-tips post"
-> Invokes Publish workflow
-> Validates frontmatter and content
-> Runs build process
-> Deploys to production
-> Returns live URL

**Example 3: Preview before publishing**
User: "Let me see how my draft looks"
-> Invokes Preview workflow
-> Starts local dev server
-> Opens browser preview
-> Returns preview URL

## Content Guidelines

- Use frontmatter for metadata (title, date, tags, description)
- Follow markdown best practices
- Include code examples with syntax highlighting
- Add images with proper alt text
```

---

## Directory Structure

```
Blogging/
├── SKILL.md                  # Main skill file (shown above)
├── ProsodyGuide.md           # Reference doc: Writing style guide
├── ContentChecklist.md       # Reference doc: Quality checklist
├── tools/
│   └── .gitkeep              # Empty tools directory
└── workflows/
    ├── Create.md             # Create new post workflow
    ├── Edit.md               # Edit existing post workflow
    ├── Publish.md            # Publish post workflow
    └── Preview.md            # Preview draft workflow
```

---

## Key Points Demonstrated

### TitleCase Naming
- Skill directory: `Blogging` (not `blogging` or `blog-skill`)
- Workflows: `Create.md`, `Edit.md`, `Publish.md` (not `create.md`)
- References: `ProsodyGuide.md` (not `prosody-guide.md`)

### YAML Frontmatter
- Single-line description with `USE WHEN` clause
- Intent-based triggers (not exact phrases)
- TitleCase skill name

### Markdown Body
- `## Workflow Routing` section with table
- `## Examples` section with 3 concrete patterns
- Additional documentation sections

### Structure
- `tools/` directory exists (even if empty)
- Reference docs at skill root
- Workflows only contain execution procedures
