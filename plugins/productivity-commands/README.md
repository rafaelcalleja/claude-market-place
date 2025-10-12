# Productivity Commands Plugin

Collection of productivity-enhancing slash commands for common development workflows.

## Commands

### `/quick-test`
Quickly run tests for your project, automatically detecting the project type and running the appropriate test suite.

**Supported project types:**
- Node.js (npm test)
- Python (pytest)
- Go (go test)
- Rust (cargo test)

### `/analyze-deps`
Analyze project dependencies for security vulnerabilities and outdated packages.

**Features:**
- Security vulnerability scanning
- Outdated package detection
- Dependency conflict identification
- Update recommendations

### `/project-stats`
Generate comprehensive project statistics including lines of code, file counts, and language breakdown.

**Provides:**
- File statistics and breakdown
- Lines of code by language
- Git repository information
- Project health indicators

## Installation

```bash
# Add the marketplace
/plugin marketplace add /path/to/example-marketplace

# Install the plugin
/plugin install productivity-commands@example-marketplace
```

## Usage

Simply type any of the commands above in your Claude Code session:

```
/quick-test
/analyze-deps
/project-stats
```

## License

MIT
