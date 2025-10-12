# Code Analysis Agents Plugin

Specialized agents for code review, security analysis, and performance optimization.

## Agents

### Security Auditor (`security-auditor`)
Expert security engineer specializing in vulnerability assessment and secure coding practices.

**Use when:**
- Reviewing code for security vulnerabilities
- Auditing authentication/authorization logic
- Analyzing data protection mechanisms
- Checking for OWASP Top 10 vulnerabilities

**Provides:**
- Critical security issue identification
- Vulnerability remediation guidance
- Security best practice recommendations
- Compliance notes (OWASP, GDPR, etc.)

### Performance Optimizer (`performance-optimizer`)
Performance engineering expert focused on identifying bottlenecks and optimization opportunities.

**Use when:**
- Investigating performance issues
- Optimizing algorithms and data structures
- Reducing resource consumption
- Improving scalability

**Provides:**
- Bottleneck identification with complexity analysis
- Algorithm optimization recommendations
- Resource usage optimization
- Scalability assessment

### Architecture Reviewer (`architecture-reviewer`)
Senior software architect reviewing system design, patterns, and maintainability.

**Use when:**
- Evaluating system architecture
- Reviewing design pattern usage
- Assessing code organization
- Identifying technical debt

**Provides:**
- Architectural concern identification
- Design pattern guidance
- Code organization improvements
- Technical debt inventory

## Usage

These agents are automatically available when the plugin is enabled. Claude Code will invoke them proactively when appropriate, or you can explicitly request them:

```
"Please use the security-auditor agent to review this authentication code"
"Have the performance-optimizer analyze this search function"
"Use the architecture-reviewer to evaluate this module structure"
```

## Installation

```bash
# Add the marketplace
/plugin marketplace add /path/to/example-marketplace

# Install the plugin
/plugin install code-analysis-agents@example-marketplace
```

## Agent Capabilities

All agents:
- Analyze code without making direct modifications
- Provide specific file locations and line numbers
- Include code examples in recommendations
- Prioritize findings by severity/impact
- Consider real-world context and trade-offs

## License

MIT
