# Workflow Weaver - Interactive Skill Builder

Generate a Claude Code skill that enables recording workflows into reusable skills by monitoring Claude's own actions and asking users which actions to include.

## Core Innovation

This skill creates **self-documenting workflows** where Claude monitors its own actions and helps build reusable skills in real-time through interactive questioning.

## Objective

Create a SKILL.md file that:
1. Monitors Claude's actions (WebFetch, Read, Bash, Edit, Write, Grep, Glob)
2. Asks user after each action whether to include it
3. Maintains state in building.json during recording
4. Saves references (web pages, files) to references/ folder
5. Generates complete, reusable SKILL.md at the end

## File Structure

```
.claude/
├── skills/skill-builder/
│   └── SKILL.md                    # The skill to generate
└── skills-in-progress/
    └── [skill-name]/
        ├── building.json           # Recording state
        ├── references/             # Saved content
        │   ├── web-doc.md
        │   └── local-file.js
        └── SKILL.md               # Final generated skill
```

## SKILL.md Implementation Specification

Generate this complete skill:

### Frontmatter

```yaml
---
name: skill-builder
description: "Interactive workflow recorder that generates reusable skills. Start with 'start recording: skill-name' and Claude will ask about each action. Captures WebFetch, Read, Bash, Edit, Write operations."
allowed-tools:
  - bash
  - read
  - write
---
```

### Core Instructions Section

```markdown
# Skill Builder

Records your workflow with Claude into reusable skills through interactive questioning.

## How It Works

1. You say: "start recording: [skill-name]"
2. Work normally with Claude
3. After each significant action, Claude asks if you want to include it
4. You choose: Add as step / Save as reference / Both / Skip
5. When done: "stop recording" generates complete SKILL.md

## Recording Commands

**Start recording:**
- "start recording: [skill-name]"
- "start recording skill: [skill-name]"
- "begin recording: [skill-name]"

**During recording:**
- "pause recording" - Stop monitoring temporarily
- "resume recording" - Continue monitoring
- "show current skill" - Preview progress
- "stop recording" / "finish recording" - Generate SKILL.md

## Behavior: Detection and Initialization

When user says "start recording: [skill-name]":

**Step 1: Create structure**
```bash
mkdir -p .claude/skills-in-progress/[skill-name]/references
```

**Step 2: Initialize building.json**
```json
{
  "skill_name": "[skill-name]",
  "started_at": "[ISO-8601 timestamp]",
  "status": "recording",
  "steps": [],
  "references": [],
  "metadata": {
    "total_actions": 0,
    "included_steps": 0,
    "references_count": 0
  }
}
```

**Step 3: Confirm**
```
📝 Recording started for skill: **[skill-name]**

I'll ask about each action I take. Work normally!
```

## Behavior: Self-Monitoring After Each Action

**CRITICAL RULE:** After EVERY significant action YOU (Claude) perform, immediately pause and use AskUserQuestion.

### Actions to Monitor

| Action Type | When to Ask | Description Template |
|------------|-------------|---------------------|
| **WebFetch** | After fetching any URL | "I just fetched [URL]" |
| **WebSearch** | After web search | "I just searched for [query]" |
| **Read** | After reading any file | "I just read file [path]" |
| **Bash** | After executing command | "I just executed: `[command]`" |
| **Edit** | After modifying file | "I just edited [path]: [brief change]" |
| **Write** | After creating file | "I just created file [path]" |
| **Grep** | After search | "I just searched for pattern: [pattern]" |
| **Glob** | After pattern match | "I just found files matching: [pattern]" |

### Question Format

Use AskUserQuestion with exactly this structure:

```
Question: "I just [describe action]. How should I handle this?"

Header: "Action"

Options:
  1. Label: "Add as step"
     Description: "Include this action as a numbered step in the skill"

  2. Label: "Save as reference"
     Description: "Save the content to references/ folder"

  3. Label: "Both"
     Description: "Add as step AND save content as reference"

  4. Label: "Skip"
     Description: "Don't include in the skill"

MultiSelect: false
```

### Processing User Response

Based on selection, update building.json:

#### Option 1: "Add as step"

Add to steps array:
```json
{
  "step_id": [next_number],
  "type": "[webfetch|read|bash|edit|write|grep|glob]",
  "action": "[Imperative description: 'Fetch docs', 'Read config']",
  "details": {
    "url": "[if webfetch]",
    "file": "[if read/edit/write]",
    "command": "[if bash]",
    "pattern": "[if grep/glob]"
  },
  "description": "[Why this step matters]",
  "timestamp": "[ISO-8601]"
}
```

Increment: `metadata.total_actions++`, `metadata.included_steps++`

#### Option 2: "Save as reference"

1. Save content to `references/[descriptive-name].[ext]`:
   - WebFetch → save HTML/text as .md
   - Read → copy file to references/
   - Bash output → save to .txt
   - Other → save appropriately

2. Add to references array:
```json
{
  "name": "[descriptive-name].[ext]",
  "source": "[original URL or path]",
  "type": "[web|local|generated]",
  "description": "[What this contains]",
  "saved_at": "[ISO-8601]"
}
```

Increment: `metadata.references_count++`

#### Option 3: "Both"

Perform BOTH actions above.

#### Option 4: "Skip"

Increment only: `metadata.total_actions++`

**After updating:** Always write updated building.json to disk immediately.

## Behavior: Session Control

Monitor for these commands:

**"pause recording":**
- Set `status: "paused"`
- Stop asking questions
- Respond: "⏸️ Recording paused. Say 'resume recording' to continue."

**"resume recording":**
- Set `status: "recording"`
- Resume asking questions
- Respond: "▶️ Recording resumed."

**"show current skill":**
Display summary:
```
📊 Current Skill: [skill-name]

Steps: [X]
References: [Y]
Status: [recording|paused]

Recent steps:
1. [action 1]
2. [action 2]
...
```

**"stop recording" or "finish recording":**
Proceed to generation phase (see next section).

## Behavior: Generating Final SKILL.md

When user says "stop recording" or "finish recording":

**Step 1: Read state**
```bash
cat .claude/skills-in-progress/[skill-name]/building.json
```

**Step 2: Generate SKILL.md**

Create with this structure:

```markdown
---
name: [skill-name]
description: "[One-sentence summary derived from steps]"
allowed-tools:
  - [list unique tool types from steps]
---

# [Skill Name in Title Case]

[2-3 sentence summary of what this skill accomplishes]

## Prerequisites

[Infer from steps any required tools, files, or setup]

## Steps

[For each step in building.json:]

### [step_id]. [Step Action as Imperative]

[Step description]

**Action:** [type]
**Details:**
[Format details as bulleted list]

[If saved_as in details:]
**Reference:** [references/filename](references/filename)

[Repeat for all steps]

## References

[If references array is not empty:]

This skill uses these reference materials:

- **[name]** ([references/name](references/name)) - [description]
[Repeat for all references]

## Usage

To use this skill:

1. [Describe first step from workflow]
2. [Describe second step]
3. [Continue...]

[Optionally add example commands or variations]

## Notes

- [Any important prerequisites not covered above]
- [Tips for adapting this skill]
- [Known limitations or edge cases]

---

*Generated by skill-builder on [current date]*
```

**Step 3: Write SKILL.md**
```bash
# Write to skills-in-progress
cat > .claude/skills-in-progress/[skill-name]/SKILL.md << 'EOF'
[generated content]
EOF
```

**Step 4: Move to skills folder**
```bash
mv .claude/skills-in-progress/[skill-name] .claude/skills/[skill-name]
```

**Step 5: Confirm success**
```
✅ Skill generated successfully!

📁 Location: .claude/skills/[skill-name]/
📄 Skill file: SKILL.md
📚 References: [X] files
🔢 Steps: [Y]

Your skill is ready to use!
```

## Best Practices

**Naming references:**
- Use descriptive names: `typescript-best-practices.md` not `doc1.md`
- Include source type: `api-docs-github.md`, `local-config.json`

**Writing step descriptions:**
- Use imperative: "Fetch API docs" not "Fetched docs"
- Include WHY: "Review auth flow to identify security issues"
- Be specific: Full commands, exact URLs, complete paths

**Grouping actions:**
- If 3+ similar actions, consider asking once with summary
- Example: "I fetched 3 documentation pages. Include all as references?"

## Error Handling

**Corrupted building.json:**
```
⚠️ building.json appears corrupted.

Options:
1. Restart recording (lose progress)
2. Attempt recovery
3. Cancel recording
```

**Skill name exists:**
```
⚠️ Skill '[name]' already exists.

Options:
1. Overwrite existing
2. Use different name
3. Cancel
```

**Long recording (50+ steps):**
```
💡 This skill has 50+ steps. Consider:
1. Continue (may be hard to use)
2. Break into multiple skills
3. Finish and refine later
```

**Missing reference file:**
If reference can't be saved, note in SKILL.md but continue.

## Edge Cases

- **Only one recording at a time:** If already recording, reject "start recording"
- **Empty recording:** If 0 steps when stopping, confirm: "No steps recorded. Cancel?"
- **Paused too long:** If paused for 100+ actions, remind: "Still recording? Say 'stop' or 'resume'"

## Example Session

```
User: start recording: deploy-to-production

Claude: 📝 Recording started for skill: **deploy-to-production**

I'll ask about each action I take. Work normally!

[Claude performs WebFetch to deployment docs]

Claude: I just fetched https://docs.aws.amazon.com/deploy.
        How should I handle this?

User: Both

Claude: ✓ Saved to references/aws-deploy-docs.md
        ✓ Added as step 1

[Claude reads local config file]

Claude: I just read file config/production.yml.
        How should I handle this?

User: Save as reference

Claude: ✓ Saved to references/production-config.yml

[... workflow continues ...]

User: stop recording

Claude: ✅ Skill generated successfully!

📁 Location: .claude/skills/deploy-to-production/
📄 Skill file: SKILL.md
📚 References: 3 files
🔢 Steps: 7

Your skill is ready to use!
```
```

## Implementation Requirements

1. **State persistence:** Write building.json after EVERY update
2. **Atomic operations:** Use proper file locking if available
3. **Clear questions:** Make AskUserQuestion options self-explanatory
4. **Graceful degradation:** Handle missing tools, permissions
5. **Consistent formatting:** Follow specified JSON and SKILL.md formats exactly

## Success Criteria

- [ ] Claude detects "start recording" commands
- [ ] Directory structure is created correctly
- [ ] AskUserQuestion appears after each monitored action
- [ ] building.json updates correctly with each response
- [ ] References are saved with descriptive names
- [ ] Final SKILL.md is well-formatted and usable
- [ ] Skill can be executed by another Claude instance
- [ ] Error cases are handled gracefully
- [ ] State persists across conversation turns

## Output Format

Generate the complete SKILL.md file exactly as specified above. The skill must be:
- Self-contained with all instructions
- Production-ready with error handling
- Clear and unambiguous
- Executable by Claude Code immediately
- Well-documented with examples
