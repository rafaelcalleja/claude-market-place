# PATTERNS

- pypdf library appears as primary tool for basic operations: merge, split, rotate, encrypt PDFs.
- pdfplumber consistently recommended for text and table extraction tasks requiring layout preservation.
- reportlab emerges as standard library for programmatic PDF creation from scratch.
- Command-line tools (qpdf, pdftotext) presented as alternatives for automation and scripting workflows.
- Table extraction workflow repeatedly involves converting to pandas DataFrames for further processing.
- Password operations (encryption/decryption) handled through pypdf's encrypt method with dual password types.
- Page-by-page iteration pattern appears across all major operations: merge, split, text extraction.
- Watermarking accomplished through merge_page() function combining original pages with watermark overlay.
- OCR workflow consistently requires two-step process: PDF to images, then image to text.
- Metadata extraction follows standard pattern accessing reader.metadata with predefined property names.
- Writer/Reader pattern dominates: read source PDF, manipulate, write to new output file.
- Multiple pages creation uses story/Platypus pattern with SimpleDocTemplate for structured documents.
- Image extraction delegated to command-line tool pdfimages rather than Python libraries.
- Layout preservation emphasized through specific flags like -layout in pdftotext command.
- Form filling explicitly separated into dedicated forms.md documentation requiring special handling.
- Reference documentation pattern: advanced features consistently deferred to separate reference.md file.
- Page rotation uses degree-based rotation method (90, 180, 270) in pypdf.
- Scanned PDFs require pytesseract and pdf2image libraries working in combination.
- Empty table checking pattern appears before DataFrame conversion to avoid errors.
- Output file handling uses context managers (with statements) for proper resource cleanup.
- Quick reference table provided mapping tasks to best tools and code patterns.
- Batch processing pattern: iterate through multiple files, apply same operation to each.
- Page range specification available in both Python and command-line tool interfaces.
- Excel export commonly used as final output format for extracted table data.

# META

- pypdf mentioned in 8+ code examples: merge, split, rotate, metadata, watermark, encryption operations.
- pdfplumber appears in 3 major sections: basic text, table extraction, advanced tables.
- reportlab shown in 2 creation examples: basic canvas drawing and multi-page document generation.
- Command-line tools section covers 3 different utilities: pdftotext, qpdf, pdftk for various tasks.
- pandas integration appears in 2 contexts: table extraction and Excel export workflows.
- forms.md referenced 3 times: overview, quick reference, next steps sections consistently.
- reference.md mentioned 4 times directing users to advanced features and JavaScript alternatives.
- Page iteration pattern appears in 10+ code snippets across different operations.
- Two-password pattern (user/owner) explicitly shown in encryption example demonstrating access control levels.
- OCR workflow combines 2 libraries: pytesseract and pdf2image for scanned document processing.
- Context manager pattern (with statements) used in 6+ examples ensuring proper file handling.
- Quick reference table synthesizes 10 common tasks mapping to optimal tools.
- Rotation mentioned in 3 contexts: pypdf code, qpdf command, pdftk command examples.
- Table extraction workflow spans 3 progressive examples: basic, advanced, DataFrame conversion with Excel.
- Metadata extraction shows 4 standard properties: title, author, subject, creator fields.

# ANALYSIS

The documentation reveals a layered toolkit approach where pypdf handles basic manipulation, pdfplumber extracts content, reportlab creates new documents, and command-line tools enable automation, with consistent patterns of page iteration, reader/writer separation, and deferral of complex operations to specialized references.

# BEST 5

- **pypdf dominates basic PDF manipulation across merge, split, rotate, encrypt operations**: Appears in 8+ examples as the foundational Python library, demonstrating its position as the go-to tool for standard PDF operations requiring programmatic control.

- **pdfplumber specialized for text and table extraction with layout preservation**: Consistently recommended across 3 major sections specifically for extraction tasks, showing clear differentiation from pypdf's manipulation focus and superior handling of structured data.

- **Page-by-page iteration pattern universally applied across all major operations**: Appears in 10+ code snippets spanning different libraries and tasks, revealing fundamental PDF processing paradigm that builders must implement regardless of specific operation.

- **Separate documentation for forms and advanced features indicates complexity boundaries**: forms.md referenced 3 times and reference.md mentioned 4 times, suggesting these areas require specialized knowledge beyond basic operations and represent common pain points.

- **Two-step OCR workflow combining pdf2image and pytesseract for scanned documents**: Explicitly detailed as separate process from regular text extraction, indicating scanned PDFs represent distinct use case requiring different technical approach and additional dependencies.

# ADVICE FOR BUILDERS

- Start with pypdf for basic manipulation; it handles 80% of common PDF operations.
- Use pdfplumber specifically for extraction; don't reinvent text and table parsing logic yourself.
- Implement page-by-page iteration pattern; it's fundamental architecture for scalable PDF processing.
- Separate scanned PDF handling; OCR requires different pipeline than native text extraction.
- Plan for form filling complexity; dedicate separate module as documentation suggests specialized handling.
- Provide command-line interfaces alongside Python APIs; users want both programmatic and script access.
- Export tables to pandas DataFrames; users expect structured data in analyzable formats.
- Handle empty content gracefully; check for null tables/text before processing to avoid errors.
- Use context managers consistently; proper resource cleanup prevents memory leaks at scale.
- Support batch operations natively; users process multiple files, not single documents typically.
- Offer quick reference mapping; users want task-to-tool guidance, not exhaustive documentation first.
- Implement dual password support; enterprise users need user/owner permission separation for security.
- Defer advanced features strategically; core functionality should work simply, complexity in separate modules.
- Preserve layout options; users extract PDFs with formatting intact, not just raw text.
- Consider reportlab for generation; creating PDFs programmatically is distinct need from manipulation.