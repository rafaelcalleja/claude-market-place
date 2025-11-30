# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2025-11-30

### Changed
- **MAJOR: Conversational Interaction Model** (v0.2.0)
  - Transformed skill from "search engine" to "interactive guide"
  - Skill now asks "¿Necesitas algo más?" after each response
  - Builds pipeline incrementally based on user responses
  - Continues conversation until user says "ya está" or similar
  - Added conversational workflow (LOOP until satisfied)
  - Added 3 complete conversation examples in SKILL.md
  - Output format now structured as: "✅ Sí, tenemos X" → Show config → Ask what else needed
  - Emphasizes guiding step-by-step vs dumping all information at once
  - **Impact**: Users now have interactive guidance instead of one-shot search results

- **Component-based Syntax Only** (v0.2.0)
  - Plugin now shows ONLY modern `component:` syntax (never legacy)
  - Examples use: `component: $CI_SERVER_FQDN/to-be-continuous/[name]/[job]@[version]`
  - Legacy syntax (`remote:`, `project:` + `ref:` + `file:`) is hidden
  - When showing sample pipelines, translates legacy to component syntax
  - Added critical rule in SKILL.md: NEVER show legacy syntax
  - **Impact**: Users learn modern best practices from day one

- **Explicit Read-Only Guard** (v0.2.0)
  - `/discover` command description updated: "NEVER generates files"
  - Warning added at top of discover.md: "This is a READ-ONLY guide"
  - Clear distinction: Shows configs vs Generates files (Phase 3)
  - Prevents common mistake: Planning command that starts implementing
  - **Impact**: Users understand plugin guides but doesn't write code (yet)

- **Stay Within Ecosystem** (v0.2.0) - CRITICAL
  - When NO match found: Plugin now guides to create to-be-continuous component (instead of custom solutions)
  - Added critical rule: NEVER propose scripts, custom jobs, workarounds outside ecosystem
  - Suggests future skills: `/create-template`, `/extend-template` (Phase 4)
  - Example 4 added: Shows correct response when component doesn't exist (S3 selective upload case)
  - **Philosophy**: Maintain to-be-continuous coherence - reusable, maintainable, shareable components
  - **Impact**: Users build within ecosystem, not ad-hoc solutions

### Added
- **Sample Pipeline Viewing**: Skill now fetches and shows real `.gitlab-ci.yml` files from sample projects
  - Added Step 6b in SKILL.md: "Fetch Sample Pipeline Configuration"
  - Sample CI URL pattern: `https://gitlab.com/to-be-continuous/samples/[name]/-/raw/master/.gitlab-ci.yml`
  - Offers to show pipeline when suggesting samples: "Want to see how it's configured?"
  - WebFetch retrieves real pipeline configuration
  - Explains template composition, variables, stages, and integration patterns
  - Added Example 3 in Real Documentation Fetching section showing complete workflow
  - Updated workflow from 8 to 9 steps (added "Offer Sample Pipelines" step)
  - Enhanced Use Case 5 with complete sample pipeline viewing workflow
  - Created `examples/sample-pipeline-viewing.md` with 4 detailed examples and best practices
  - Updated README.md with sample pipeline viewing examples
  - Natural language triggers: "show me the pipeline", "how is X configured?"

### Fixed
- **CRITICAL FIX**: Plugin now fetches real README documentation from GitLab instead of inventing examples
  - Added WebFetch tool to `/discover` command
  - Updated `template-discovery` skill to always use real documentation
  - Added explicit workflow for fetching READMEs: `https://gitlab.com/to-be-continuous/[name]/-/raw/master/README.md`
  - Added safeguards: NEVER INVENT EXAMPLES instruction in skill
  - Added 3 examples in SKILL.md showing correct WebFetch usage
  - Updated Best Practices section to emphasize real documentation only

### Changed
- README.md updated with WebFetch capabilities and `--details` flag example
- SKILL.md workflow updated from 7 steps to 8 steps (added "Fetch Real Docs" step)
- Output format now includes option to fetch detailed usage with `--details` flag

### Technical Details

**Problem**: When users asked `/discover semantic-release`, the plugin was generating fictional examples based on general knowledge instead of showing real usage from official documentation.

**Solution**:
1. Added WebFetch to allowed-tools in `commands/discover.md`
2. Updated `skills/template-discovery/SKILL.md` with:
   - Step 6: "Fetch Real Documentation (CRITICAL)"
   - README URL construction pattern
   - WebFetch usage instructions
   - Explicit "NEVER INVENT EXAMPLES" warnings
   - 3 concrete examples (semantic-release, python, error handling)
3. Updated Best Practices with WebFetch requirements
4. Updated Template Discovery Workflow to include WebFetch step

**Impact**:
- ✅ Users now get accurate, official documentation
- ✅ No more fictional/invented examples
- ✅ Deterministic output based on real GitLab content
- ⚠️ Requires internet connection to fetch READMEs
- ⚠️ Slightly slower (WebFetch adds latency)

**Testing**:
After this fix, test with:
```bash
/discover semantic-release
```
Should now fetch and show real README content from:
`https://gitlab.com/to-be-continuous/semantic-release/-/raw/master/README.md`

---

## [0.1.0] - 2024-11-28

### Added
- Initial MVP release
- `/discover` command for template search
- `template-discovery` skill with intelligent search
- Catalog of 110 to-be-continuous templates
- Category-based organization
- 15 example queries
- Intelligent suggestions for complementary templates
- Sample project recommendations

### Components
- 1 command: `discover.md`
- 1 skill: `template-discovery/`
- 3 reference files: `catalog.md`, `categories.md`, `queries.md`
- Complete documentation: README.md, TESTING.md

### Known Limitations
- ~~Invented examples instead of real documentation~~ (FIXED in Unreleased)
- No offline mode (requires internet for WebFetch)
- No pipeline creation (discovery only)
- No template downloading/caching
