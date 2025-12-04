# PATTERNS

- TypeScript is the recommended language for MCP servers due to SDK quality and broad compatibility.
- Comprehensive API coverage should be prioritized over specialized workflow tools when uncertain about design.
- Tool names should use consistent prefixes and action-oriented naming for better agent discoverability.
- Streamable HTTP transport is preferred for remote servers due to simpler scaling and maintenance.
- Error messages must be actionable, providing specific suggestions and next steps for agents.
- Input schemas should include constraints, clear descriptions, and examples in field descriptions.
- Output schemas help clients understand and process tool outputs more effectively when defined.
- Evaluations require 10 complex, realistic questions that test multi-tool usage and deep exploration.
- All evaluation questions must be read-only operations to avoid destructive testing scenarios.
- Evaluation answers must be stable over time and verifiable through string comparison.
- Tool descriptions should be concise summaries including parameter descriptions and return type schemas.
- Pagination support is essential for tools that return large datasets or lists.
- Async/await patterns are required for all I/O operations in tool implementations.
- DRY principle is emphasized to avoid duplicated code across the server implementation.
- MCP Inspector is the standard testing tool for both TypeScript and Python implementations.
- Tool annotations include readOnlyHint, destructiveHint, idempotentHint, and openWorldHint flags for clarity.
- Structured content in tool responses is a TypeScript SDK feature for better data processing.
- Evaluation questions must be independent and not depend on answers from other questions.
- Phase-based development workflow separates research, implementation, review, and evaluation into distinct stages.
- API client, error handling, and response formatting should be implemented as shared utilities.
- Zod is the schema validation library for TypeScript while Pydantic is used for Python.
- Context management focuses on concise tool descriptions and filtered/paginated results for agents.
- Code execution capability varies by client, affecting whether basic or workflow tools perform better.
- Full type coverage is a required quality standard during code review phase.
- Documentation loading uses specific patterns: sitemap first, then .md suffix for MCP protocol pages.

# META

- TypeScript recommendation appears in framework selection, stack recommendation, and language-specific guide references (3 sources).
- API coverage vs workflow tools is discussed in modern MCP design section and tool selection planning.
- Tool naming pattern mentioned in discoverability section and best practices reference (2 sources).
- Streamable HTTP preference stated in transport mechanisms and recommended stack sections (2 sources).
- Actionable error messages emphasized in context management and implementation sections (2 sources).
- Input schema requirements detailed in implementation phase and tool implementation subsection (2 sources).
- Output schema guidance appears in tool implementation and structured content discussions (2 sources).
- Evaluation requirements specified across multiple subsections in Phase 4 (4+ sources).
- Read-only evaluation constraint mentioned in evaluation requirements and question generation sections (2 sources).
- Stable answers requirement appears in evaluation requirements and output format guidance (2 sources).
- Tool description structure defined in implementation phase and tool implementation details (2 sources).
- Pagination mentioned in context management, core infrastructure, and implementation sections (3 sources).
- Async/await pattern specified in tool implementation and I/O operations guidance (2 sources).
- DRY principle appears once in code quality review section (1 source).
- MCP Inspector mentioned in both TypeScript and Python testing sections (2 sources).
- Tool annotations listed comprehensively in implementation phase annotations subsection (1 source).
- Structured content feature mentioned in output schema and TypeScript SDK sections (2 sources).
- Independent questions requirement stated in evaluation requirements section (1 source).
- Four-phase workflow is the document's primary organizational structure (1 source).
- Shared utilities pattern appears in core infrastructure implementation section (1 source).
- Schema libraries mentioned in implementation phase and language-specific guide references (2 sources).
- Context management discussed in modern MCP design and tool implementation (2 sources).
- Code execution variance noted in API coverage discussion and context management (2 sources).
- Type coverage requirement stated in code quality review section (1 source).
- Documentation loading pattern specified in MCP protocol study section (1 source).

# ANALYSIS

The guide emphasizes a structured four-phase approach prioritizing comprehensive API coverage, TypeScript implementation, actionable error handling, and thorough evaluation with read-only testing to ensure high-quality MCP server development.

# BEST 5

- **TypeScript is the recommended language due to SDK quality, broad compatibility, and AI model proficiency**: This pattern appears across framework selection, stack recommendations, and implementation guides, making it the clearest technical direction in the document.

- **Comprehensive API coverage should be prioritized over workflow tools when design is uncertain**: Mentioned in both modern MCP design and tool selection planning, this represents a fundamental architectural decision affecting all implementations.

- **Evaluations require 10 complex, realistic, read-only questions verifiable through stable string comparison**: This pattern combines multiple requirements from Phase 4, representing the quality bar for validating MCP server effectiveness.

- **Error messages must be actionable with specific suggestions, appearing in both design principles and implementation**: Emphasized in context management and implementation sections, this pattern directly impacts agent success rates and user experience.

- **Streamable HTTP transport is preferred for remote servers due to simpler scaling and stateless design**: Mentioned in transport mechanisms and recommended stack, this architectural choice affects deployment, maintenance, and scalability of implementations.

# ADVICE FOR BUILDERS

- Start with TypeScript unless you have strong Python infrastructure already in place.
- Build comprehensive API coverage first, then add specialized workflows based on usage patterns.
- Use consistent tool naming prefixes to help agents discover related functionality quickly.
- Implement pagination from the start for any tools returning lists or collections.
- Write error messages that tell agents exactly what went wrong and how to fix it.
- Create 10 complex evaluation questions before considering your server production-ready.
- Test your server with MCP Inspector to catch issues before agent integration.
- Use Zod or Pydantic schemas with examples in descriptions to guide agent usage.
- Design for stateless HTTP transport to simplify scaling and reduce operational complexity.
- Include tool annotations for read-only, destructive, and idempotent operations from the beginning.
- Build shared utilities for authentication, error handling, and response formatting before implementing tools.
- Ensure all evaluation questions are read-only to enable safe automated testing.
- Define output schemas wherever possible to help clients process tool responses effectively.
- Review for DRY violations and consistent patterns before finalizing your implementation.
- Load MCP protocol documentation using sitemap first, then fetch specific markdown pages.