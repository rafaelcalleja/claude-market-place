# Fabric Helper Plugin

Fabric AI system integration for Claude Code with pattern suggestion and execution workflows.

## Overview

This plugin integrates the Fabric AI patterns system into Claude Code, providing intelligent pattern suggestion and execution capabilities. It includes 200+ pre-built analysis patterns for code review, security analysis, content transformation, documentation generation, and more.

## Features

- **Intelligent Pattern Suggestion**: Semantic analysis of prompts to recommend appropriate Fabric patterns
- **Pattern Execution**: High-quality pattern execution using Sonnet model
- **Workflow Orchestration**: Chain multiple patterns into automated workflows
- **200+ Built-in Patterns**: Comprehensive pattern library for diverse use cases
- **Specialized Agents**: Dedicated suggester and executor agents for optimal performance

## Installation

### From Marketplace

```bash
cd /path/to/claude-marketplace
make install
```

Then in Claude Code:
```
/plugin install fabric-helper
```

### Manual Installation

```bash
# Clone the marketplace repository
git clone https://github.com/your-username/claude-market-place.git
cd claude-market-place

# Validate the plugin
make validate

# Install locally
make install
```

## Usage

The plugin provides three main commands:

### 1. `/suggest` - Get Pattern Recommendations

Analyzes your request and suggests appropriate Fabric patterns.

**Syntax**: `/suggest [description]`

**Examples**:

```bash
/suggest "I need to review this code for security issues"
# Returns: analyze_security, review_code, extract_vulnerabilities

/suggest "Extract main ideas from a research paper"
# Returns: extract_ideas, summarize, create_documentation

/suggest "Analyze meeting transcript and create action items"
# Returns: analyze_meeting, extract_tasks, create_summary
```

### 2. `/exec` - Execute a Specific Pattern

Directly executes a known pattern by name.

**Syntax**: `/exec [pattern_name] [input]`

**Examples**:

```bash
/exec review_code "function getData() { return data; }"
# Performs comprehensive code review

/exec summarize "[long article text here]"
# Creates concise summary

/exec analyze_security "[code snippet]"
# Analyzes security vulnerabilities
```

### 3. `/orchestrate` - Automated Workflow

Orchestrates complete multi-pattern workflows by automatically suggesting and executing a sequence of patterns.

**Syntax**: `/orchestrate [workflow description]`

**Examples**:

```bash
/orchestrate "Analyze this meeting transcript, extract action items, and create a summary report"
# Automatically: analyze_meeting → extract_tasks → create_summary

/orchestrate "Review code quality, find bugs, and generate documentation"
# Automatically: review_code → extract_issues → create_documentation
```

## Use Cases

### Case 1: Code Analysis

**Problem**: Need to review code for quality, bugs, and best practices

**Solution**:
```bash
# Get suggestions first
/suggest "review this TypeScript function for bugs and best practices"

# Execute the recommended pattern
/exec review_code "function getData() { ... }"
```

### Case 2: Documentation Extraction

**Problem**: Extract key information from documents and create structured documentation

**Solution**:
```bash
/orchestrate "Extract the main ideas from this research paper and create documentation"
```

The orchestrator will:
1. Analyze the paper content
2. Extract key ideas and concepts
3. Generate structured documentation

### Case 3: Content Transformation

**Problem**: Convert content between formats or create summaries

**Solution**:
```bash
# Convert HTML to Markdown
/exec convert_to_markdown "[HTML content here]"

# Create summary from long document
/exec create_summary "[document text]"
```

## How It Works

### Architecture

```
User Command
    ↓
Commands Layer (suggest.md, orchestrate.md, exec.md)
    ↓
Agents Layer
    ├─ pattern-suggester (analysis & recommendation)
    └─ pattern-executor (pattern execution)
    ↓
Data Layer
    ├─ pattern_descriptions.json (pattern catalog)
    └─ pattern_extracts.json (pattern prompts)
```

### Pattern Suggester Agent

- **Model**: inherit
- **Purpose**: Analyzes user prompts semantically to suggest appropriate patterns
- **Capabilities**:
  - Intent extraction (analyze, create, extract, summarize, etc.)
  - Domain identification (development, security, writing, business)
  - Tag-based pattern matching
  - Workflow sequence generation
- **Restriction**: Only suggests patterns, never executes

### Pattern Executor Agent

- **Model**: sonnet (high-quality analysis)
- **Purpose**: Executes specific Fabric patterns with provided input
- **Capabilities**:
  - Pattern extraction from library
  - High-quality analysis using Sonnet model
  - Structured output formatting
- **Restriction**: Only executes patterns, never suggests

## Available Patterns

The plugin includes 200+ patterns organized by domain:

- **Development**: code_review, analyze_architecture, create_tests, optimize_code
- **Security**: analyze_security, extract_vulnerabilities, threat_modeling
- **Writing**: summarize, improve_writing, create_documentation
- **Analysis**: extract_insights, analyze_data, identify_patterns
- **Business**: create_strategy, analyze_market, decision_analysis
- **And many more...**

To explore available patterns, use `/suggest` with your use case description.

## Troubleshooting

### Pattern Not Found

**Issue**: Pattern name doesn't exist in the library

**Solution**: Use `/suggest` to get valid pattern names first

```bash
/suggest "what I want to do"
# Get valid pattern names
/exec [valid_pattern_name] "input"
```

### No Suggestions Returned

**Issue**: Suggester doesn't return any patterns

**Solution**: Make your prompt more specific about what you want to achieve

```bash
# Too vague
/suggest "help me"

# Better
/suggest "analyze this code for security vulnerabilities"
```

### Orchestration Fails

**Issue**: Workflow orchestration doesn't complete

**Solution**: Check that each pattern in the sequence is compatible

```bash
# Start with suggestion to see the sequence
/suggest "your workflow description"

# Then orchestrate
/orchestrate "your workflow description"
```

### Pattern Execution Timeout

**Issue**: Pattern execution takes too long

**Solution**: Break down large inputs into smaller chunks

```bash
# Instead of entire codebase
/exec review_code "[entire codebase]"

# Review file by file
/exec review_code "[single file content]"
```

## Data Files

The plugin includes two core data files:

### pattern_descriptions.json (48KB)

Catalog of all available patterns with:
- Pattern name
- Description
- Tags for categorization

Used by the suggester agent for pattern matching.

### pattern_extracts.json (330KB)

Complete pattern prompts for execution containing:
- Pattern name
- Full pattern instructions
- Expected input/output formats

Used by the executor agent to apply patterns.

## Development

### File Structure

```
plugins/fabric-helper/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── commands/
│   ├── suggest.md               # Suggestion command
│   ├── orchestrate.md           # Orchestration command
│   └── exec.md                  # Execution command
├── agents/
│   ├── pattern-suggester.md     # Suggester agent
│   └── pattern-executor.md      # Executor agent
├── .fabric-core/
│   ├── pattern_descriptions.json # Pattern catalog (48KB)
│   └── pattern_extracts.json     # Pattern prompts (330KB)
├── README.md
└── LICENSE
```

### Validation

```bash
cd /path/to/marketplace
make validate
```

### Local Testing

```bash
make install
# Then in Claude Code:
/suggest "test prompt"
/exec summarize "test content"
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `make validate`
5. Submit a pull request

## License

MIT License - see LICENSE file

Copyright (c) 2025 Rafael Calleja

## References

- **Fabric AI**: Original pattern system
- **Claude Code**: https://docs.claude.com/en/docs/claude-code
- **Plugin Docs**: https://docs.claude.com/en/docs/claude-code/plugins
- **Marketplace Guide**: https://docs.claude.com/en/docs/claude-code/plugin-marketplaces

## Version History

### 1.0.3 (2025-10-12)
- **Simplified commands**: Rewritten all command prompts to be more direct and executable by Claude
- Commands now have clearer, imperative instructions ("Execute these steps now")
- Removed ambiguous placeholders, made all steps concrete
- This version requires reinstallation to take effect

### 1.0.2 (2025-10-12)
- **Major Fix**: Redesigned architecture - commands now read data files and pass content to agents
- Fixed: `${CLAUDE_PLUGIN_ROOT}` variable doesn't expand in agent prompts
- Commands (suggest, exec, orchestrate) now use Bash tool to read pattern files
- Agents (pattern-suggester, pattern-executor) simplified to receive content directly
- Improved reliability and eliminates path resolution issues
- Added jq-based pattern extraction in exec command

### 1.0.1 (2025-10-12)
- **Fix**: Use `${CLAUDE_PLUGIN_ROOT}` for all data file paths to support installation in any directory
- Ensures plugin works correctly when installed via Claude Code marketplace

### 1.0.0 (2025-10-12)
- Initial release
- 3 commands: suggest, orchestrate, exec
- 2 specialized agents
- 200+ pre-built patterns
- Complete pattern library integration
