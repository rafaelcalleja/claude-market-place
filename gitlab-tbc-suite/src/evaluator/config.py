"""Configuration loader for the evaluation suite."""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


@dataclass
class PluginConfig:
    """Plugin configuration."""
    path: Path


@dataclass
class ExecutorConfig:
    """Executor configuration."""
    max_turns: int = 20
    permission_mode: str = "acceptEdits"
    timeout_seconds: int = 120


@dataclass
class JudgeConfig:
    """Judge configuration."""
    model: str = "sonnet"


@dataclass
class ThresholdsConfig:
    """Score thresholds."""
    passing: int = 70
    excellent: int = 90


@dataclass
class PathsConfig:
    """Paths configuration."""
    evaluations: Path = field(default_factory=lambda: Path("evaluations"))
    results: Path = field(default_factory=lambda: Path("results"))


@dataclass
class Config:
    """Main configuration."""
    plugin: PluginConfig
    executor: ExecutorConfig
    judge: JudgeConfig
    thresholds: ThresholdsConfig
    paths: PathsConfig

    @classmethod
    def from_dict(cls, data: dict[str, Any], base_path: Path) -> "Config":
        """Create Config from dictionary."""
        plugin_data = data.get("plugin", {})
        executor_data = data.get("executor", {})
        judge_data = data.get("judge", {})
        thresholds_data = data.get("thresholds", {})
        paths_data = data.get("paths", {})

        return cls(
            plugin=PluginConfig(
                path=Path(plugin_data.get("path", ""))
            ),
            executor=ExecutorConfig(
                max_turns=executor_data.get("max_turns", 20),
                permission_mode=executor_data.get("permission_mode", "acceptEdits"),
                timeout_seconds=executor_data.get("timeout_seconds", 120)
            ),
            judge=JudgeConfig(
                model=judge_data.get("model", "sonnet")
            ),
            thresholds=ThresholdsConfig(
                passing=thresholds_data.get("passing", 70),
                excellent=thresholds_data.get("excellent", 90)
            ),
            paths=PathsConfig(
                evaluations=base_path / paths_data.get("evaluations", "evaluations"),
                results=base_path / paths_data.get("results", "results")
            )
        )


def load_config(config_path: str | Path = "config.yaml") -> Config:
    """Load configuration from YAML file."""
    config_path = Path(config_path)
    base_path = config_path.parent

    with open(config_path) as f:
        data = yaml.safe_load(f)

    return Config.from_dict(data, base_path)
