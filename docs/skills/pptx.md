# PATTERNS

- Template-based presentations require unpacking XML, editing content, and repacking the file structure carefully.
- Visual validation through thumbnails is critical to catch text cutoff and overlap issues.
- Color palette selection should match content subject matter, not rely on generic defaults.
- Two-column layouts work best for slides combining text with charts or tables.
- Placeholder counts in templates must exactly match actual content pieces to avoid forcing.
- Shape inventory extraction reveals all text containers before any replacement operations begin.
- Bullet points require explicit level property and automatic left alignment without manual symbols.
- Validation errors must be fixed immediately after each XML edit before proceeding further.
- Reading entire documentation files without range limits is mandatory before any operations.
- Automatic text clearing happens for all inventory shapes unless paragraphs are explicitly provided.
- Zero-based indexing applies consistently across slides, shapes, and template references throughout workflows.
- HTML-to-PPTX conversion requires rasterizing gradients and icons as PNG images before rendering.
- Font selection limited to web-safe options ensures consistent rendering across different systems.
- Typography treatments include extreme size contrast, all-caps headers, and monospace for technical content.
- Geometric patterns like diagonal dividers and asymmetric columns create visual interest beyond defaults.
- Theme file analysis extracts color schemes and font definitions from XML structure.
- Markdown conversion provides quick text extraction without needing full XML unpacking process.
- Replacement JSON validation checks shape existence before applying any text modifications to slides.
- Thumbnail grids support 3-6 columns with automatic pagination for large presentation decks.
- PDF intermediate conversion enables slide-to-image export using LibreOffice and Poppler utilities.
- Border treatments include single-side thick borders, corner brackets, and L-shaped accent frames.
- Chart styling favors monochrome with single accent colors and minimal gridlines for clarity.
- Layout innovations include full-bleed images, sidebar columns, and modular grid systems for organization.
- Background treatments use solid color blocks, vertical gradients, and split backgrounds strategically.
- Speaker notes and comments require raw XML access, not available through markdown conversion.
- Design principles demand content analysis before code generation to match tone and industry.
- Overflow detection in replacement script identifies text that exceeds shape boundaries after changes.
- Rearrange script handles slide duplication, deletion, and reordering in single command execution.
- Paragraph properties preservation includes bold, alignment, font size, and color during text replacement.
- Default font sizes extracted from layout placeholders guide appropriate text sizing decisions.

# META

- Template workflow pattern combines markdown extraction, thumbnail creation, and inventory analysis (3 sources).
- Validation requirement appears in both editing workflow and replacement script documentation (2 mentions).
- Zero-based indexing mentioned in template inventory, rearrange script, and thumbnail documentation (3 sources).
- Color palette guidance includes 18 example combinations plus creative selection principles (2 sections).
- Two-column layout preference stated in layout tips and workflow sections (2 mentions).
- Read-entire-file requirement appears for html2pptx.md, ooxml.md, template-content.md, and text-inventory.json (4 files).
- Automatic clearing behavior documented in replacement text generation and replace.py script sections (2 mentions).
- Thumbnail creation described in dedicated section plus template workflow step (2 locations).
- HTML-to-PPTX workflow covers design principles, layout tips, and conversion process (3 components).
- Shape inventory extraction detailed in JSON structure, script usage, and validation process (3 aspects).
- Web-safe fonts requirement appears in design principles and font selection guidelines (2 mentions).
- Visual validation process includes thumbnail inspection and specific issue identification (2 steps).
- PDF conversion workflow combines LibreOffice and Poppler tools for image export (2 tools).
- Bullet formatting rules mentioned in replacement text generation and paragraph examples (2 sections).
- Placeholder type identification shown in inventory JSON and shape analysis documentation (2 sources).

# ANALYSIS

Presentation workflows emphasize visual validation, exact content-to-layout matching, zero-based indexing consistency, mandatory full-file reading, automatic clearing with explicit replacement, and creative design choices informed by subject matter rather than defaults.

# BEST 5

- **Visual validation through thumbnails catches layout issues before finalization**: Multiple workflow steps require thumbnail generation and inspection to identify text cutoff, overlap, and positioning problems. This pattern prevents publishing broken presentations by enabling visual quality control at critical checkpoints throughout the creation process.

- **Placeholder counts must exactly match content pieces to avoid forced layouts**: Documentation repeatedly warns against using three-column layouts for two items or image placeholders without actual images. This pattern emerged from real-world issues where mismatched layouts create awkward, empty spaces or cramped content that undermines presentation effectiveness.

- **Zero-based indexing applies consistently across all slide and shape references**: Mentioned in template inventory, rearrange script, thumbnail documentation, and replacement validation. This universal pattern prevents off-by-one errors that would break automation scripts and cause confusion when referencing specific slides throughout multi-step workflows.

- **Automatic text clearing happens unless paragraphs explicitly provided in replacement JSON**: Documented in both replacement text generation and replace.py script sections. This pattern ensures clean slate for new content while preventing accidental retention of template placeholder text that would look unprofessional in final presentations.

- **Reading entire documentation files without range limits is mandatory before operations**: Required for html2pptx.md, ooxml.md, template-content.md, and text-inventory.json across four different workflow types. This pattern prevents incomplete understanding of complex formatting rules, critical syntax requirements, and validation steps that cause failures in presentation generation.

# ADVICE FOR BUILDERS

- Always generate and inspect thumbnail grids before finalizing any presentation workflow completion.
- Match layout structure to actual content count before selecting templates or placeholders.
- Implement validation checks immediately after each XML modification to catch errors early.
- Build shape inventory extraction into every template-based workflow as foundational first step.
- Design color palettes based on content subject matter, not generic corporate defaults.
- Use two-column layouts for slides combining text with charts, tables, or images.
- Enforce zero-based indexing consistently across all slide and shape reference systems throughout.
- Require full documentation reading before allowing any presentation creation or editing operations.
- Default to automatic text clearing with explicit replacement to prevent placeholder retention.
- Limit font selection to web-safe options for consistent rendering across different systems.
- Implement overflow detection in text replacement to identify boundary-exceeding content automatically.
- Support thumbnail grid generation with flexible column counts for different analysis needs.
- Enable slide rearrangement with duplication and deletion in single command for efficiency.
- Extract theme files for color and font analysis when emulating existing designs.
- Rasterize gradients and icons as PNG before HTML-to-PPTX conversion to ensure accuracy.