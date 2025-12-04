# PATTERNS

- Communication types follow standardized formats: 3P updates, newsletters, FAQs, status reports, incident reports.
- Internal communications require specific guideline files for each distinct communication type.
- The system emphasizes identifying communication type before beginning any writing task.
- Template-driven approach ensures consistency across all internal communications within the organization.
- Progress, Plans, Problems (3P) framework is a core communication structure used repeatedly.
- Tone and formatting requirements vary by communication type and are documented separately.
- The skill is triggered by requests for status reports, updates, or newsletters.
- External guideline files in examples directory provide detailed instructions for each format.
- FAQ responses are treated as a distinct communication category with specific guidelines.
- Leadership updates require different handling than general team communications.
- Project updates are categorized separately from general status reports in the system.
- Incident reports follow their own specific format distinct from other update types.
- The system defaults to general-comms guidelines when communication type is ambiguous.
- Clarification is requested when communication doesn't match existing guideline categories.
- Keywords trigger skill activation: updates, comms, newsletter, FAQs, 3P updates.
- Company-wide communications (newsletters) have different requirements than team-level updates.
- The skill centralizes all internal communication writing into a single framework.
- Guideline files are modular, allowing independent updates to specific communication types.
- Context gathering is part of the process before writing begins.
- The system prioritizes format consistency over content flexibility in communications.

# META

- 3P updates pattern appears in multiple contexts: title, examples, keywords, usage instructions.
- Newsletter pattern sourced from communication types list, examples directory, and keywords section.
- FAQ pattern mentioned in three distinct sections: when-to-use, guideline files, keywords.
- Status reports appear twice: in when-to-use list and keywords section.
- Leadership updates mentioned in both when-to-use and guideline file references.
- Project updates pattern drawn from when-to-use list and keywords.
- Incident reports referenced in when-to-use list and guideline structure.
- Template approach inferred from examples directory structure and how-to-use instructions.
- Identification-first workflow stated explicitly in numbered how-to-use steps.
- General-comms fallback mentioned once but represents critical decision-tree endpoint.
- Tone variation implied by separate guideline files for different communication types.
- Modular structure evident from separate markdown files for each type.
- Clarification protocol mentioned once in how-to-use section final paragraph.
- Keywords list aggregates terms from all other sections into single reference.
- Company-wide versus team-level distinction appears in newsletter versus 3P framing.

# ANALYSIS

The input reveals a highly structured, template-driven internal communications system that prioritizes format identification and consistency through modular guidelines, with the 3P framework as a central organizing principle for team updates.

# BEST 5

- **Progress, Plans, Problems (3P) framework is a core communication structure used repeatedly.** This made the top 5 because it appears in the skill name, examples, keywords, and represents the primary team update methodology, suggesting it's the most frequently used format.

- **Template-driven approach ensures consistency across all internal communications within the organization.** This pattern is fundamental to the entire system's design, with separate guideline files for each type and explicit instructions to follow specific formats.

- **The system emphasizes identifying communication type before beginning any writing task.** This appears as step one in the how-to-use instructions and drives the entire workflow, making it the critical first decision point.

- **External guideline files in examples directory provide detailed instructions for each format.** This architectural choice enables modularity and appears in multiple references throughout the input, showing it's central to implementation.

- **The system defaults to general-comms guidelines when communication type is ambiguous.** This safety net pattern ensures the system handles edge cases gracefully and appears as the fallback in the decision tree.

# ADVICE FOR BUILDERS

- Build modular communication templates that can be independently updated without affecting other formats.
- Implement a clear type-identification step before any content generation in communication tools.
- Create a fallback "general" template to handle edge cases and ambiguous requests.
- Use the 3P framework (Progress, Plans, Problems) for team-level status updates.
- Separate company-wide communications from team-level updates with distinct templates and tone.
- Document tone and formatting requirements separately for each communication type you support.
- Trigger your communication tools with specific keywords related to update types and formats.
- Maintain a centralized examples directory that users can reference for format guidance.
- Design for consistency over flexibility in organizational communication tools to reduce confusion.
- Build clarification prompts into your system when communication type cannot be determined.
- Treat FAQs as a distinct category requiring different structure than announcements or updates.
- Create separate workflows for incident reports versus routine status updates and newsletters.
- Use standardized frameworks that employees already understand rather than inventing new formats.
- Make guideline files easily accessible and clearly named for quick reference during writing.
- Consider context-gathering as a required step before generating any internal communication content.