"""
Evaluation suite for Claude Code plugins.

Components:
- PluginExecutor: Execute prompts against a plugin
- EvaluationJudge: LLM-based output evaluation
- ResultStorage: Result persistence and history
- Config: Configuration management
"""

from .config import Config, load_config
from .executor import PluginExecutor, load_scenario_prompt, load_expected_output
from .judge import EvaluationJudge
from .models import (
    EvaluationResult,
    EvaluationScore,
    ExecutionResult,
    JudgeAnalysis,
    ScenarioConfig,
)
from .storage import ResultStorage

__all__ = [
    "Config",
    "load_config",
    "PluginExecutor",
    "load_scenario_prompt",
    "load_expected_output",
    "EvaluationJudge",
    "EvaluationResult",
    "EvaluationScore",
    "ExecutionResult",
    "JudgeAnalysis",
    "ScenarioConfig",
    "ResultStorage",
]
