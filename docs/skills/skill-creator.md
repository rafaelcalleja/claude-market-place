# PATTERNS

- Skills are modular packages that transform Claude from general-purpose to specialized domain agent.
- Context window is a shared public good that must be carefully managed.
- Default assumption: Claude is already very smart, only add missing context.
- Challenge each piece of information: "Does Claude really need this explanation?"
- Match specificity level to task fragility: high freedom for flexible tasks.
- Low freedom (specific scripts) for fragile operations requiring consistency and specific sequences.
- Every skill requires SKILL.md with YAML frontmatter (name, description) and markdown body.
- Description field is primary triggering mechanism, must include what and when comprehensively.
- Bundled resources are optional: scripts for deterministic code, references for documentation, assets.
- Scripts provide token efficiency and deterministic reliability for repeatedly rewritten code patterns.
- References contain documentation loaded only when Claude determines it's needed for work.
- Assets are files used in output, not loaded into context window.
- Do NOT create auxiliary documentation files like README, CHANGELOG, or installation guides.
- Progressive disclosure: metadata always loaded, SKILL.md when triggered, resources as needed.
- Keep SKILL.md body under 500 lines to minimize context bloat and waste.
- Split content into separate files when approaching the 500-line limit threshold.
- When splitting content, reference files clearly from SKILL.md with usage guidance.
- For multiple variations, keep core workflow in SKILL.md, move details to references.
- Avoid deeply nested references; keep all references one level deep from SKILL.md.
- Structure longer reference files with table of contents for Claude to preview.
- Skill creation follows six steps: understand, plan, initialize, edit, package, iterate.
- Start with concrete examples to understand skill usage patterns before building.
- Analyze examples to identify reusable scripts, references, and assets needed repeatedly.
- Always run init_skill.py script when creating new skills from scratch for efficiency.
- Edit skill by starting with reusable resources, then update SKILL.md last.
- Test added scripts by running them to ensure no bugs exist.
- Write SKILL.md in imperative/infinitive form for clarity and consistency throughout.
- Include all "when to use" information in description, not in body text.
- Body is only loaded after triggering, making "when to use" sections useless.
- Package skills with package_skill.py which validates before creating distributable .skill files.
- Validation checks frontmatter, naming, descriptions, structure, and references before allowing packaging.
- Iterate based on real usage: use skill, notice struggles, identify improvements, implement.
- Information should live in either SKILL.md or references, never duplicated in both.
- Prefer references for detailed information unless truly core to skill workflow.
- Concise examples are preferred over verbose explanations for teaching Claude patterns.
- Think of Claude exploring paths: narrow bridges need guardrails, open fields allow routes.
- Scripts may still need reading by Claude for patching or environment adjustments.
- Delete example files and directories not needed for the specific skill being created.
- Consult proven design pattern guides for multi-step processes and output formats.

# META

- "Context window as public good" mentioned repeatedly across core principles and design sections.
- "Progressive disclosure" pattern appears in anatomy, design principles, and resource organization sections together.
- "Default assumption: Claude is smart" stated in core principles, reinforced throughout editing guidelines.
- Token efficiency emphasized in: core principles, scripts rationale, SKILL.md length limits, reference patterns.
- "Degrees of freedom" concept explained once in core principles, applied throughout resource decisions.
- SKILL.md structure (frontmatter + body) mentioned in: anatomy, initialization, editing, packaging, validation.
- Description as triggering mechanism stated in: anatomy section, frontmatter guidelines, packaging validation rules.
- Six-step process defined once, referenced throughout skill creation workflow and iteration sections.
- "Avoid duplication" principle stated for references, reinforced in progressive disclosure and editing guidelines.
- Scripts for deterministic reliability mentioned in: bundled resources, planning step, editing guidelines together.
- 500-line limit for SKILL.md appears in: progressive disclosure patterns, editing guidelines sections.
- "Imperative form" writing guideline stated once in editing section, applied to all instructions.
- init_skill.py script mentioned in: step 3, workflow efficiency, template generation context repeatedly.
- Validation requirements listed in: packaging section, what not to include, frontmatter guidelines.
- "When to use" placement rule stated in: description guidelines, body guidelines, frontmatter section.
- Concrete examples approach mentioned in: step 1, understanding phase, planning rationale sections.
- References one-level-deep rule stated in: progressive disclosure patterns, avoid nested references guideline.
- Testing scripts requirement mentioned in: editing step, implementation phase, quality assurance context.
- Real usage iteration pattern stated in: step 6, workflow conclusion, improvement cycle description.
- Assets definition (output files not context) mentioned in: bundled resources, anatomy, planning examples.

# ANALYSIS

Skills are context-efficient, progressively-disclosed packages transforming Claude into specialized agents through reusable scripts, references, and assets while obsessively protecting the shared context window from bloat.

# BEST 5

- Context window is a shared public good that must be carefully managed: This fundamental principle appears throughout the entire document as the driving constraint behind every design decision, from progressive disclosure to the 500-line limits to avoiding duplication.

- Description field is primary triggering mechanism, must include what and when comprehensively: This pattern is critical because it determines skill activation, appears in anatomy, frontmatter guidelines, and packaging validation, making it the most important metadata field.

- Progressive disclosure: metadata always loaded, SKILL.md when triggered, resources as needed: This three-tier loading system is the core architectural pattern enabling context efficiency, mentioned across anatomy, design principles, and resource organization sections repeatedly.

- Default assumption: Claude is already very smart, only add missing context: This principle appears early in core principles and is reinforced throughout, fundamentally shifting skill creation from over-explaining to providing only non-obvious procedural knowledge.

- For multiple variations, keep core workflow in SKILL.md, move details to references: This pattern appears in progressive disclosure section with multiple concrete examples (BigQuery domains, cloud providers, document frameworks), showing it's a proven solution.

# ADVICE FOR BUILDERS

- Ruthlessly cut explanations Claude already knows; protect context window as shared resource.
- Put all triggering conditions in description field; body loads too late for that.
- Start skill creation with concrete usage examples before writing any documentation or code.
- Test scripts by actually running them; don't assume generated code works correctly.
- Keep SKILL.md under 500 lines; split detailed content into separate reference files early.
- Use scripts for code that gets rewritten repeatedly; save tokens and ensure consistency.
- Store domain knowledge in references, not SKILL.md; load only when Claude needs it.
- Match freedom level to task fragility; fragile operations need specific scripts with guardrails.
- Always run init_skill.py for new skills; manual creation misses required structure and wastes time.
- Delete unused example files after initialization; don't ship unnecessary template files to users.
- Iterate based on real usage struggles, not theoretical improvements; watch the skill work.
- Avoid nested references; keep all reference files one level deep from SKILL.md for discoverability.
- Never duplicate information between SKILL.md and references; choose one location per piece of content.
- Use imperative form consistently; skills are instruction sets, not explanatory documentation or guides.
- Package with validation script; catch structural errors before distribution to end users happens.