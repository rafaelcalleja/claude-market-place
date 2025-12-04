"""
Pytest fixtures and configuration for the evaluation suite.

Provides fixtures for executor, judge, storage, and dynamic test generation
from evaluation scenarios.
"""

import asyncio
import os
from pathlib import Path
from typing import Generator

import pytest

from src.evaluator.config import load_config, Config
from src.evaluator.executor import PluginExecutor
from src.evaluator.judge import EvaluationJudge
from src.evaluator.storage import ResultStorage

# Project paths
PROJECT_ROOT = Path(__file__).parent
DEFAULT_CONFIG_PATH = PROJECT_ROOT / "config.yaml"


@pytest.fixture(scope="session")
def event_loop() -> Generator[asyncio.AbstractEventLoop, None, None]:
    """Create event loop for async tests."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session")
def config() -> Config:
    """Load configuration from config.yaml."""
    config_path = os.environ.get("EVAL_CONFIG", str(DEFAULT_CONFIG_PATH))
    return load_config(config_path)


@pytest.fixture(scope="session")
def executor(config: Config) -> PluginExecutor:
    """Create plugin executor instance."""
    workspace = PROJECT_ROOT / "workspace"
    workspace.mkdir(exist_ok=True)

    return PluginExecutor(
        plugin_path=config.plugin.path,
        working_dir=workspace,
        max_turns=config.executor.max_turns,
        permission_mode=config.executor.permission_mode,
        timeout_seconds=config.executor.timeout_seconds
    )


@pytest.fixture(scope="session")
def judge(config: Config) -> EvaluationJudge:
    """Create evaluation judge instance."""
    return EvaluationJudge(model=config.judge.model)


@pytest.fixture(scope="session")
def storage(config: Config) -> ResultStorage:
    """Create result storage instance."""
    return ResultStorage(config.paths.results)


@pytest.fixture(scope="session")
def run_id(storage: ResultStorage) -> str:
    """Create a run ID for this test session."""
    mr_id = os.environ.get("CI_MERGE_REQUEST_IID")
    version = os.environ.get("PLUGIN_VERSION", "dev")
    return storage.create_run(mr_id=mr_id, version=version)


@pytest.fixture(scope="session")
def passing_threshold(config: Config) -> int:
    """Get the passing threshold from config or environment."""
    env_threshold = os.environ.get("EVAL_THRESHOLD")
    if env_threshold:
        return int(env_threshold)
    return config.thresholds.passing


# Collected results for finalization
_collected_results: list = []


@pytest.fixture
def collect_result():
    """Fixture to collect results for final aggregation."""
    def _collect(result):
        _collected_results.append(result)
    return _collect


@pytest.fixture(scope="session", autouse=True)
def finalize_results(
    storage: ResultStorage,
    run_id: str,
    passing_threshold: int,
    request
) -> Generator[None, None, None]:
    """Finalize results after all tests complete."""
    yield
    if _collected_results:
        summary = storage.finalize_run(
            run_id,
            _collected_results,
            passing_threshold
        )
        print(f"\n{'='*60}")
        print(f"Evaluation Run: {run_id}")
        print(f"{'='*60}")
        print(f"Total Scenarios: {summary['total_scenarios']}")
        print(f"Passed: {summary['passed']}")
        print(f"Failed: {summary['failed']}")
        print(f"Average Score: {summary['average_score']}")
        print(f"{'='*60}")


def pytest_generate_tests(metafunc):
    """Dynamically generate test cases from evaluation scenarios."""
    if "scenario" in metafunc.fixturenames:
        config_path = os.environ.get("EVAL_CONFIG", str(DEFAULT_CONFIG_PATH))
        config = load_config(config_path)
        evaluations_dir = config.paths.evaluations

        scenarios = []
        if evaluations_dir.exists():
            for scenario_dir in sorted(evaluations_dir.iterdir()):
                if scenario_dir.is_dir() and (scenario_dir / "prompt.md").exists():
                    scenarios.append(scenario_dir.name)

        # If no scenarios, skip parameterization (tests will be skipped)
        if scenarios:
            metafunc.parametrize("scenario", scenarios)
        else:
            # Create a dummy scenario that will be skipped
            metafunc.parametrize(
                "scenario",
                ["no_scenarios_found"],
                ids=["no_scenarios"]
            )
