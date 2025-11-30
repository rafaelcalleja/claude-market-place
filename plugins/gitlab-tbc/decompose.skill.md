graph TB
Start[Usuario pregunta sobre templates TBC] --> ParseRequest[1. Parse User Request<br/>Extract keywords]

      ParseRequest --> Phase1[PHASE 1: Initial Discovery]
      Phase1 --> SearchCatalog[Search catalog.md<br/>Identify 2-5 candidates]

      SearchCatalog --> Phase2[PHASE 2: Deep Template Analysis]
      Phase2 --> P2_1[2.1 Fetch README Overview<br/>WebFetch template README]
      P2_1 --> P2_2[2.2 Discover ALL Variants]

      P2_2 --> CheckVariantes{Consult<br/>variantes.md}
      CheckVariantes --> VariantesFound[Known variants found]
      CheckVariantes --> WebFetchVariants[WebFetch to verify/expand]
      VariantesFound --> P2_3
      WebFetchVariants --> P2_3

      P2_3[2.3 Analyze EACH Variant<br/>WebFetch each YAML file]
      P2_3 --> P2_35[2.3.5 Analyze CLI Tool Capabilities]

      P2_35 --> ExtractCLI[Extract CLI commands<br/>from YAML scripts]
      ExtractCLI --> ResearchTool[Research tool semantics<br/>Is it incremental?]
      ResearchTool --> ToolMatrix[Create Tool Capability Matrix<br/>Map requirements to native features]
      ToolMatrix --> GapAnalysis[True vs False Gap Analysis]

      GapAnalysis --> P2_4[2.4 Create Variant<br/>Comparison Matrix]
      P2_4 --> VariantMissing{Variant<br/>missing?}

      VariantMissing -->|Yes| P2_5[2.5 Cross-Component<br/>Variant Learning]
      VariantMissing -->|No| Phase3

      P2_5 --> SearchPattern[Search variantes.md<br/>for pattern in other components]
      SearchPattern --> AnalyzeRef[Analyze reference<br/>implementation]
      AnalyzeRef --> MapPattern[Create mapping table<br/>Reference → Target]
      MapPattern --> AdaptGuide[Present adaptation<br/>guidance]
      AdaptGuide --> Phase3

      Phase3[PHASE 3: Cross-Template Evaluation]
      Phase3 --> Rerank[Re-rank options<br/>based on criteria]
      Rerank --> IdentifyGaps[Identify gaps &<br/>workarounds]
      IdentifyGaps --> P3_4

      P3_4[3.4 FAQ Validation]
      P3_4 --> ExtractDoubts[Extract doubts/assumptions<br/>from analysis]
      ExtractDoubts --> MatchFAQ{Match against<br/>faq.md}
      MatchFAQ -->|Match found| ConsultUsageGuide[Consult usage-guide.md<br/>for details]
      MatchFAQ -->|No match| P3_5
      ConsultUsageGuide --> CorrectAnalysis[Correct analysis<br/>based on official docs]
      CorrectAnalysis --> P3_5

      P3_5[3.5 Apply Best Practices]
      P3_5 --> CheckReviewApps{Review Apps<br/>scenario?}
      CheckReviewApps -->|Yes| ValidateReviewApps[Validate against<br/>best-practices.md]
      CheckReviewApps -->|No| CheckGitOps

      ValidateReviewApps --> CheckGitOps{GitOps/Deployment<br/>scenario?}
      CheckGitOps -->|Yes| ValidateGitOps[Hybrid model validation<br/>Push vs GitOps]
      CheckGitOps -->|No| CheckRepoStructure

      ValidateGitOps --> CheckRepoStructure{Repository<br/>structure?}
      CheckRepoStructure -->|Relevant| ValidateRepo[Apply decision matrix<br/>Monorepo vs Separate]
      CheckRepoStructure -->|Not relevant| Phase4
      ValidateRepo --> Phase4

      Phase4[PHASE 4: Present Findings]
      Phase4 --> FormatResponse[Format response with:<br/>✅ Best option<br/>📋 Why it fits<br/>📊 Alternatives<br/>⚠️ Limitations]
      FormatResponse --> AskMore[💬 Ask: ¿Necesitas algo más?]

      AskMore --> WaitUser{User<br/>responds}
      WaitUser -->|Adds something| ParseRequest
      WaitUser -->|ya está / gracias| Summarize
      WaitUser -->|Needs adjustment| Phase5

      Phase5[PHASE 5: Iterative Refinement]
      Phase5 --> GoBackPhase2[Go back to Phase 2<br/>with new requirements]
      GoBackPhase2 --> P2_1

      Summarize[Summarize pipeline<br/>components added]
      Summarize --> End[End conversation]

      style Phase1 fill:#e1f5ff
      style Phase2 fill:#fff4e1
      style P2_5 fill:#ffe1e1
      style P2_35 fill:#ffe1e1
      style Phase3 fill:#f0ffe1
      style P3_4 fill:#ffe1e1
      style P3_5 fill:#ffe1e1
      style Phase4 fill:#e1ffe1
      style Phase5 fill:#f5e1ff
      style AskMore fill:#ffb3b3,stroke:#ff0000,stroke-width:3px

Funciones que realiza la skill (agrupadas):

🔵 CONVERSATIONAL ORCHESTRATION

- Parse user request (extract keywords)
- Conversational loop ("¿Necesitas algo más?")
- Wait for user response
- Iterative refinement (Phase 5)
- Summarize final pipeline

🟡 CATALOG & DISCOVERY (Phase 1)

- Search catalog.md for templates
- Identify 2-5 candidate templates
- Match by technology/keywords

🟠 DEEP ANALYSIS (Phase 2.1-2.4)

- Fetch README overview (WebFetch)
- Discover ALL variants (consult variantes.md)
- Analyze EACH variant (WebFetch YAML)
- Create variant comparison matrix

🔴 CRITICAL SUB-PROCESSES (extraíbles)

- 2.3.5 CLI Tool Analysis: Extract commands → Research semantics → Capability matrix → Gap analysis
- 2.5 Cross-Component Learning: Search pattern → Analyze reference → Map pattern → Adaptation guide

🟢 VALIDATION & RANKING (Phase 3)

- Re-rank options
- Identify gaps
- 3.4 FAQ Validation: Match doubts → Consult faq.md → Consult usage-guide.md → Correct analysis
- 3.5 Best Practices: Review Apps check → GitOps validation → Repo structure validation

🟣 PRESENTATION (Phase 4)

- Format response with emoji structure
- Show best option + why
- List alternatives
- Explain limitations
