# PATTERNS

- Blue text for hardcoded inputs is an industry-standard convention in financial modeling.
- Black text for formulas is the standard convention across financial models.
- Zero formula errors is a mandatory requirement for all Excel deliverables.
- Excel formulas should be used instead of hardcoding calculated values in Python.
- LibreOffice is required and assumed available for formula recalculation via recalc.py script.
- Preserve existing template formatting when modifying files; never impose new standards.
- Currency formatting must always specify units in headers like "Revenue ($mm)".
- Years should be formatted as text strings, not numbers with commas.
- All zeros should display as dashes using number formatting patterns.
- Assumptions must be placed in separate cells, never hardcoded within formulas.
- Documentation of hardcoded values requires source, date, and specific reference information.
- The recalc.py script automatically configures LibreOffice on first run without manual setup.
- Cell references are 1-indexed in openpyxl, unlike 0-indexed Python data structures.
- Opening with data_only=True and saving permanently destroys all formulas in file.
- Pandas is recommended for data analysis while openpyxl handles formulas and formatting.
- Green text indicates links pulling from other worksheets within the same workbook.
- Red text signals external links to other files in financial models.
- Yellow background highlights key assumptions needing attention or requiring updates.
- Negative numbers should use parentheses format, not minus signs in financial contexts.
- Percentages default to one decimal place (0.0%) for consistency across models.
- Valuation multiples use 0.0x format for EV/EBITDA and P/E ratios.
- Formula verification requires testing sample references before building full models.
- Column mapping errors are common; Excel column 64 is BL, not BK.
- Row offset issues arise because Excel rows are 1-indexed while DataFrames are 0-indexed.
- NaN handling requires explicit checks using pd.notna() before formula operations.
- Division by zero checks are essential to prevent #DIV/0! errors in formulas.
- Cross-sheet references must use correct Sheet1!A1 format for linking between sheets.
- The recalc.py script scans ALL cells for errors and returns detailed JSON.
- Error summary in recalc.py output includes error counts and specific cell locations.
- Start small strategy: test formulas on 2-3 cells before applying broadly.
- Far-right columns (50+) often contain fiscal year data that gets overlooked.
- Multiple matches require searching all occurrences, not just the first found.
- Test edge cases including zero, negative, and very large values in formulas.
- Minimal Python code without verbose comments is preferred for Excel operations.
- Cell-level comments should document complex formulas and important assumptions in spreadsheets.
- Write_only and read_only modes in openpyxl optimize performance for large files.
- Specify data types explicitly in pandas to avoid inference issues with IDs.
- Parse_dates parameter in pandas ensures proper date handling from Excel files.
- Reading specific columns with usecols improves performance on large Excel files.
- Formulas are preserved but not evaluated by openpyxl; recalc.py updates values.

# META

- Blue/black/green/red text color coding mentioned 4 times across color standards and conventions.
- Zero formula errors requirement stated in 3 sections: overview, requirements, and verification.
- Recalc.py script referenced 8 times across workflow, requirements, and error handling sections.
- Openpyxl vs pandas distinction appears 6 times in library selection and best practices.
- Cell reference indexing (1-based vs 0-based) mentioned 3 times in pitfalls and practices.
- Data_only=True warning repeated 2 times emphasizing permanent formula loss risk.
- Formula-over-hardcode principle stated 4 times with wrong/correct examples and critical warnings.
- LibreOffice installation assumption mentioned 2 times in requirements and recalc.py description.
- Template preservation directive stated 3 times in requirements and formatting override rules.
- Number formatting standards detailed across 6 different format types with specific examples.
- Documentation requirements for hardcodes shown with 4 different source examples (10-K, Bloomberg, etc).
- Error types (#REF!, #DIV/0!, etc) listed 5 times across requirements and verification.
- Column width and formatting code examples appear in 2 separate openpyxl sections.
- JSON output structure from recalc.py detailed twice with status and error_summary fields.
- Formula verification checklist has 3 main categories: essential, pitfalls, and testing strategy.
- Year formatting as text strings mentioned twice to prevent comma formatting issues.
- Dash display for zeros specified twice with exact formatting pattern "$#,##0;($#,##0);-".
- Assumptions placement rule stated 3 times with examples showing cell reference approach.
- Sheet navigation methods shown twice: wb.active and wb['SheetName'] approaches.
- Performance optimization tips appear 3 times: read_only, write_only, and usecols parameters.

# ANALYSIS

Financial Excel models require strict color-coding, zero errors, formula-based calculations, template preservation, comprehensive documentation, proper tool selection between pandas and openpyxl, mandatory recalculation verification, and careful attention to indexing differences.

# BEST 5

- **Excel formulas must replace Python calculations to maintain dynamic spreadsheets**: This pattern appeared 4+ times with explicit wrong/correct examples, emphasizing the critical principle that hardcoding values destroys spreadsheet functionality and prevents scenario analysis.

- **Zero formula errors is non-negotiable across all deliverables with mandatory verification**: Mentioned 8+ times through requirements, recalc.py workflow, and verification checklists, this represents the fundamental quality standard that prevents broken models and ensures professional delivery.

- **Industry-standard color coding (blue/black/green/red) communicates formula logic instantly**: Referenced 4 times across standards sections, this convention enables financial professionals to immediately understand cell types without inspecting formulas, critical for model auditing and collaboration.

- **Openpyxl for formulas/formatting, pandas for data analysis creates optimal workflow**: Stated 6+ times across tool selection and best practices, this separation of concerns prevents common pitfalls like accidentally destroying formulas with data_only=True while maximizing each library's strengths.

- **Template preservation overrides all standardization rules when modifying existing files**: Emphasized 3 times in requirements hierarchy, this prevents the common mistake of reformatting client files to match standards, which destroys established workflows and conventions in production models.

# ADVICE FOR BUILDERS

- Build Excel tools that enforce formula-based calculations and flag hardcoded values automatically.
- Create validation layers that scan for formula errors before file delivery.
- Implement color-coding automation that applies industry standards to new financial models.
- Design template detection systems that preserve existing formatting when modifying files.
- Build recalculation pipelines that verify formula integrity after every programmatic modification.
- Create documentation generators that auto-populate source citations for hardcoded data inputs.
- Develop indexing translators that prevent 0-based/1-based conversion errors in Excel operations.
- Build error dashboards that surface #REF!, #DIV/0! locations with fix suggestions.
- Create assumption extractors that identify and centralize hardcoded values in formulas.
- Design format validators that enforce currency units, zero dashes, and percentage standards.
- Build cross-sheet reference checkers that verify Sheet1!A1 syntax across complex workbooks.
- Create NaN handlers that prevent null values from breaking formula chains.
- Design column mappers that validate Excel column letters against DataFrame positions accurately.
- Build edge case testers that verify formulas with zero, negative, extreme values.
- Create minimal code generators that produce concise Python without verbose Excel comments.