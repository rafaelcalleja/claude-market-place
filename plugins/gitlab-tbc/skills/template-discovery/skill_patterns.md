I'll analyze this input step by step to identify patterns.

# PATTERNS

- Conversational incremental approach emphasized repeatedly over dump-all-information-at-once method
- WebFetch used to retrieve real configurations from GitLab instead of inventing examples
- Component-based syntax mandated over legacy project/ref/file or remote syntax
- Template variant discovery requires checking multiple files per template systematically
- Deep multi-phase analysis required before suggesting any solution to users
- CLI tool capability research prevents suggesting workarounds for native features
- Stay within ecosystem principle forbids custom scripts outside to-be-continuous
- Loop-based workflow continues until user explicitly says finished
- Explicit gap acknowledgment preferred over hiding template limitations
- Comparison matrices used to evaluate multiple template variants side-by-side
- Best practices validation phase added before presenting recommendations to users
- GitOps for production and push-based for non-prod environments pattern
- Repository structure decisions based on team organization and separation concerns
- Future skills referenced for template creation instead of custom solutions
- Real sample projects linked with context rather than bare URLs
- Deterministic verification checklist prevents assumptions about tool capabilities
- Incremental tools like aws s3 sync already solve many user requirements
- False gaps distinguished from true gaps through tool semantics research
- Template combination suggestions offered based on current technology stack
- Alternatives always provided with explicit ranking criteria and trade-offs

# META

- Conversational pattern mentioned 8+ times across workflow, rules, and critical sections
- WebFetch deterministic approach appears in capabilities, rules, analysis phases, and examples
- Component syntax enforcement stated in critical rules, output instructions, and examples
- Multi-phase analysis (Phases 1-5) structured as core methodology with sub-phases
- CLI tool analysis (Phase 2.3.5) added as critical step with validation checklist
- Stay within ecosystem appears in capabilities, no-match-found, and critical rules sections
- Loop workflow visualized in ASCII diagram and repeated in conversation rules
- Best practices validation (Phase 3.5) cross-references external best-practices.md file repeatedly
- Variant discovery pattern shown through S3 template examples with vault/standard comparisons
- Gap acknowledgment pattern demonstrated in response format and phase 4 presentation
- Comparison matrix format appears in variant analysis, tool capabilities, and alternatives
- GitOps pattern sourced from best-practices.md reference and deployment strategy validation
- Repository structure guidance derived from best-practices.md architectural patterns section
- Future skills (/create-template, /extend-template) mentioned in no-match and roadmap sections
- Sample project linking emphasized in conversational rules and real examples sections
- Tool semantics research pattern includes aws s3 sync, kubectl, helm examples
- Incremental tools list compiled from common tools section with native behavior notes
- False vs true gaps distinction demonstrated through S3 case study example
- Template combination mentioned in capabilities, workflow loop, and helpful behaviors
- Alternatives requirement stated in conversation rules with 2nd/3rd option mandates

# ANALYSIS

This document establishes a conversational, deterministic, ecosystem-constrained approach to GitLab CI/CD template discovery, emphasizing multi-phase analysis including CLI tool capability research, best practices validation, and incremental user guidance over single-response solutions.

# BEST 5

- **Conversational incremental approach over information dumping**: Mentioned 8+ times across workflow, rules, and examples. Makes top 5 because it fundamentally changes interaction model from search-engine to guided-conversation, requiring loop-until-satisfied behavior and "¿Necesitas algo más?" pattern after every response.

- **Multi-phase deep analysis before recommending (Phases 1-5)**: Structured methodology spanning discovery, variant analysis, CLI tool research, cross-evaluation, and best practices validation. Critical because it prevents premature suggestions and ensures exhaustive evaluation of all template variants and native tool capabilities before presenting options.

- **CLI tool semantics research prevents false gaps (Phase 2.3.5)**: Validation checklist requiring extraction of commands from YAML and researching native capabilities. Top 5 worthy because it prevents suggesting workarounds for features that already exist natively (aws s3 sync is incremental, kubectl apply is differential).

- **Stay within to-be-continuous ecosystem constraint**: Forbids custom scripts, bash jobs, or workarounds outside ecosystem. Fundamental principle appearing in capabilities, critical rules, and no-match responses. Guides users to create official components via future skills rather than quick-dirty solutions.

- **Component-based syntax enforcement over legacy patterns**: Mandated in critical rules, output instructions, and all examples. Makes top 5 because it represents architectural migration from deprecated project/ref/file syntax to modern component-based includes across entire to-be-continuous ecosystem.

# ADVICE FOR BUILDERS

- Build conversational loops that continue until user satisfaction, not single-response interactions
- Fetch real configurations via API rather than inventing examples or documentation
- Enforce modern syntax patterns and deprecate legacy approaches in all outputs
- Implement multi-phase analysis workflows before presenting recommendations to users
- Research underlying tool capabilities to avoid reinventing native features unnecessarily
- Stay within your ecosystem constraints rather than suggesting external workarounds
- Validate recommendations against architectural best practices before presenting to users
- Provide comparison matrices when evaluating multiple options with explicit trade-offs
- Acknowledge gaps honestly rather than overselling capabilities or hiding limitations
- Offer incremental guidance with specific next-step options based on context
- Distinguish false gaps from true gaps through tool semantics research
- Guide users to create official components when no existing solution fits
- Use decision matrices for architecture choices like deployment strategies or repos
- Link to working examples with context rather than bare documentation URLs
- Maintain validation checklists to prevent assumptions about tool or template capabilities