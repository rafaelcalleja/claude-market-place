# PATTERNS

- Always run helper scripts with `--help` flag before attempting to read source code.
- Wait for `networkidle` state before inspecting DOM on dynamic web applications.
- Use reconnaissance-then-action pattern: screenshot first, identify selectors second, execute actions third.
- Launch Chromium browser in headless mode for all automation tasks.
- Treat helper scripts as black boxes to avoid polluting context window.
- Helper scripts handle server lifecycle management automatically for automation scripts.
- Decision tree approach: check if static HTML first, then determine server status.
- Multiple servers can be managed simultaneously using single helper script invocation.
- Read HTML files directly for static content to identify selectors efficiently.
- Close browser instances explicitly when automation tasks complete.
- Use descriptive selector strategies: text, role, CSS selectors, or IDs preferred.
- Server readiness is guaranteed before automation script execution begins.
- Screenshot and DOM inspection should occur after page load completes fully.
- Context window pollution is primary concern when deciding whether to read scripts.
- Helper scripts exist specifically to be invoked directly, not ingested into context.
- Synchronous Playwright API recommended for writing automation scripts.
- Common pitfall: inspecting DOM before JavaScript execution finishes on dynamic apps.
- Example files demonstrate patterns without requiring source code reading.
- Static versus dynamic content determines fundamentally different testing approaches.
- Server lifecycle complexity abstracted away from automation script logic.

# META

- "Always run --help first" mentioned in opening instructions and best practices section.
- Headless mode directive appears in code example with inline comment emphasis.
- Black-box pattern emphasized in helper scripts intro and best practices sections.
- Context window pollution mentioned twice: helper description and best practices.
- Reconnaissance-then-action appears as dedicated section and in decision tree.
- `networkidle` wait appears in example code, common pitfalls, and decision tree.
- Server lifecycle management mentioned in helper description and code examples.
- Multiple servers pattern shown in both single and multi-server examples.
- Static HTML approach appears in decision tree and separate branch.
- Browser closing mentioned in example code and best practices list.
- Selector strategies enumerated once in best practices section.
- Decision tree provides single comprehensive workflow visualization.
- Example files referenced once as learning resources.
- Synchronous API recommended in example code and best practices.
- Server readiness implicit in code example comment.

# ANALYSIS

The documentation emphasizes treating automation infrastructure as black boxes to preserve context efficiency, while enforcing strict sequencing patterns (wait-inspect-act) to handle JavaScript-heavy applications, with static versus dynamic content fundamentally determining workflow approach.

# BEST 5

- **Wait for `networkidle` before DOM inspection on dynamic apps**: Mentioned in code example, common pitfalls section, and decision tree. Critical pattern preventing premature selector identification failures in JavaScript-heavy applications.

- **Treat helper scripts as black boxes, run `--help` instead of reading source**: Emphasized in opening instructions, helper description, and best practices. Core philosophy preventing context window pollution while maintaining functionality.

- **Use reconnaissance-then-action pattern for dynamic webapps**: Dedicated section plus decision tree integration. Systematic approach ensuring selectors discovered from actual rendered state rather than assumptions.

- **Helper scripts manage server lifecycle automatically for automation scripts**: Appears in description, both code examples, and workflow explanation. Separates concerns between infrastructure and testing logic effectively.

- **Decision tree determines static versus dynamic approach first**: Single comprehensive flowchart guiding all testing decisions. Prevents wasted effort by establishing content type before choosing methodology.

# ADVICE FOR BUILDERS

- Provide helper scripts with comprehensive `--help` output to reduce documentation reading needs.
- Abstract infrastructure complexity away from core testing logic for cleaner separation.
- Enforce wait-before-inspect patterns through examples to prevent common JavaScript timing bugs.
- Design APIs that discourage context pollution through black-box invocation patterns.
- Create decision trees for complex workflows to guide users systematically.
- Support multiple simultaneous servers to handle modern frontend-backend architectures.
- Use inline code comments to emphasize critical directives like headless mode.
- Provide example files demonstrating patterns rather than requiring source code reading.
- Make static content optimization a first-class workflow consideration for efficiency.
- Design synchronous APIs as default to reduce async complexity for users.
- Separate server management from testing logic to improve script portability.
- Emphasize screenshot-driven debugging to make invisible state visible quickly.
- Build workflows assuming JavaScript execution delays in modern web applications.
- Use explicit browser cleanup patterns to prevent resource leaks.
- Prioritize selector strategy documentation to improve test reliability and maintainability.