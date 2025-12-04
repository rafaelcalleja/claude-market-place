# PATTERNS

- Redlining workflow is recommended as default for editing someone else's documents.
- Legal, academic, business, and government documents require the redlining workflow.
- Mandatory complete file reading before starting any document creation or editing task.
- Batch changes into groups of 3-10 for manageable debugging and efficient progress.
- Only mark text that actually changes in tracked edits, not entire sentences.
- Preserve original run's RSID for unchanged text to maintain document integrity.
- Convert documents to markdown using pandoc for simple text extraction needs.
- Use raw XML access for comments, formatting, structure, media, and metadata.
- Creating new documents requires docx-js JavaScript/TypeScript library exclusively.
- Editing existing documents requires Python-based Document library and OOXML manipulation.
- Unpack document before editing, make changes, then pack back to .docx format.
- Never use markdown line numbers for locating changes in XML structure.
- Use section headings, grep patterns, and document structure for finding changes.
- Grep word/document.xml immediately before writing scripts to verify current state.
- Line numbers change after each script run, requiring fresh grep verification.
- Implement all changes systematically to ensure comprehensive tracked changes completion.
- Minimal precise edits principle: break replacements into unchanged-deletion-insertion-unchanged segments.
- Final verification step checks all changes applied correctly without unintended modifications.
- Two-step conversion process for visual analysis: DOCX to PDF to images.
- Code should be concise, avoiding verbose names, redundant operations, and unnecessary prints.
- Different tools for different tasks: pandoc for reading, docx-js for creating, Python for editing.
- Text split across multiple w:r XML elements requires careful grep verification.
- Group changes logically by section, type, proximity, or complexity for batching.
- Unpack script suggests specific RSID to use for all tracked changes.
- Document library provides both high-level methods and direct DOM access options.

# META

- Redlining workflow mentioned 3+ times across decision tree, editing section, and workflow details.
- Mandatory file reading emphasized twice with identical "NEVER set range limits" warnings.
- Batching strategy appears in workflow introduction and detailed implementation steps with 3-10 range.
- Minimal edits principle shown through bad/good code example and multiple workflow references.
- RSID preservation mentioned in principle section and code example with technical details.
- Pandoc conversion referenced in text extraction, tracked changes workflow, and verification steps.
- Raw XML access described in reading section and throughout editing workflow requirements.
- Docx-js specified exclusively for new document creation in decision tree and workflow.
- Document library referenced in editing workflow, ooxml.md reading requirement, and implementation steps.
- Pack/unpack cycle mentioned in editing workflow, tracked changes workflow, and final steps.
- Grep verification emphasized three times: before scripting, after changes, and final verification.
- Line number warning appears in location methods and implementation guidance with explanation.
- Section-based location methods listed with five different approaches including headings and structure.
- Batch organization strategies detailed with four different grouping approaches and examples.
- RSID suggestion from unpack script mentioned in workflow step 3 with usage instructions.
- Systematic implementation requirement stated in redlining critical note and final verification step.
- Code style guidelines appear in dedicated section emphasizing conciseness three different ways.
- Two-step image conversion process detailed with soffice and pdftoppm commands separately.
- Different tool selection logic embedded in decision tree and three separate workflow sections.
- Dependencies section lists five tools with installation commands for each platform.

# ANALYSIS

The input reveals a sophisticated document editing system that prioritizes professional redlining workflows, mandatory comprehensive documentation reading, precise minimal edits with RSID preservation, systematic batching strategies, and tool-specific workflows with continuous verification.

# BEST 5

- **Redlining workflow as default for external documents**: Mentioned across decision tree, required for professional contexts (legal/academic/business/government), and detailed with complete implementation workflow. This pattern dominates because it addresses the highest-risk scenario where improper edits damage professional relationships or legal validity.

- **Mandatory complete file reading before any work**: Emphasized twice with identical "NEVER set range limits" warnings for both docx-js.md and ooxml.md files. This pattern ranks high because it appears as blocking requirement before any document creation or editing can proceed successfully.

- **Minimal precise edits preserving original RSIDs**: Demonstrated through bad/good code example, stated as principle, and reinforced in workflow steps. Critical because improper tracking makes documents unprofessional and harder to review, directly impacting deliverable quality.

- **Batch changes into 3-10 groups for manageable debugging**: Specified in workflow introduction, detailed with four grouping strategies, and integrated into implementation steps. Essential pattern because it balances efficiency with error isolation, making complex document edits practically achievable.

- **Grep verification before every script and after completion**: Required three times throughout workflow with explicit warnings about changing line numbers. Fundamental because XML structure doesn't match markdown view, and skipping verification causes scripts to fail or corrupt documents.

# ADVICE FOR BUILDERS

- Default to redlining workflow for all document editing unless creating from scratch.
- Build comprehensive documentation that users must read completely before using tools.
- Implement batch processing with 3-10 item groups for complex multi-step operations.
- Preserve original metadata and formatting when making minimal targeted changes only.
- Require verification steps before and after each operation to prevent corruption.
- Use different specialized tools for reading, creating, and editing document types.
- Convert complex formats to simpler ones (markdown) for basic read operations.
- Provide clear decision trees that route users to appropriate workflows quickly.
- Emphasize systematic completion of all planned changes to avoid partial implementations.
- Build verification into workflow, not as optional step but mandatory checkpoint.
- Separate high-level convenience methods from low-level direct access for flexibility.
- Use location strategies based on document structure, never on visual representation.
- Warn users explicitly about state changes that invalidate previous location information.
- Suggest specific identifiers (like RSID) during setup for consistency throughout workflow.
- Make code generation concise by default to reduce cognitive load reviewing.