"""Data models for the evaluation suite."""

from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any


@dataclass
class ScenarioConfig:
    """Configuration for a single evaluation scenario."""
    name: str
    prompt_path: Path
    expected_dir: Path
    context: dict[str, Any] = field(default_factory=dict)


@dataclass
class ExecutionResult:
    """Result from Phase 1 (executor)."""
    scenario_name: str
    prompt: str
    raw_output: str
    parsed_yaml: dict[str, Any] | None
    execution_time_ms: int
    error: str | None = None
    tool_calls: list[dict[str, Any]] = field(default_factory=list)


@dataclass
class EvaluationScore:
    """Scores from the LLM judge."""
    overall: int  # 0-100
    structural: int  # YAML structure correctness
    semantic: int  # Semantic correctness of CI/CD logic
    completeness: int  # All required components present
    correctness: int  # Correct values and configurations

    def __post_init__(self):
        """Validate scores are in range."""
        for attr in ["overall", "structural", "semantic", "completeness", "correctness"]:
            value = getattr(self, attr)
            if not 0 <= value <= 100:
                raise ValueError(f"{attr} must be between 0 and 100, got {value}")


@dataclass
class JudgeAnalysis:
    """Analysis from Phase 2 (LLM judge)."""
    score: EvaluationScore
    correct_elements: list[str] = field(default_factory=list)
    incorrect_elements: list[str] = field(default_factory=list)
    missing_elements: list[str] = field(default_factory=list)
    extra_elements: list[str] = field(default_factory=list)
    reasoning: str = ""
    suggestions: list[str] = field(default_factory=list)


@dataclass
class EvaluationResult:
    """Complete evaluation result for a scenario."""
    scenario_name: str
    execution: ExecutionResult
    analysis: JudgeAnalysis
    timestamp: datetime
    run_id: str
    version: str = "dev"

    def passed(self, threshold: int = 70) -> bool:
        """Check if the evaluation passed the threshold."""
        return self.analysis.score.overall >= threshold

    def to_dict(self) -> dict[str, Any]:
        """Convert to dictionary for serialization."""
        return {
            "scenario_name": self.scenario_name,
            "execution": {
                "prompt": self.execution.prompt,
                "raw_output": self.execution.raw_output,
                "parsed_yaml": self.execution.parsed_yaml,
                "execution_time_ms": self.execution.execution_time_ms,
                "error": self.execution.error,
                "tool_calls": self.execution.tool_calls
            },
            "analysis": {
                "score": {
                    "overall": self.analysis.score.overall,
                    "structural": self.analysis.score.structural,
                    "semantic": self.analysis.score.semantic,
                    "completeness": self.analysis.score.completeness,
                    "correctness": self.analysis.score.correctness
                },
                "correct_elements": self.analysis.correct_elements,
                "incorrect_elements": self.analysis.incorrect_elements,
                "missing_elements": self.analysis.missing_elements,
                "extra_elements": self.analysis.extra_elements,
                "reasoning": self.analysis.reasoning,
                "suggestions": self.analysis.suggestions
            },
            "timestamp": self.timestamp.isoformat(),
            "run_id": self.run_id,
            "version": self.version
        }
