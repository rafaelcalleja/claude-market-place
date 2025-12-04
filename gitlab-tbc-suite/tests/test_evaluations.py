"""
Evaluation tests for Claude Code plugins.

Dynamically runs evaluation scenarios found in the evaluations/ directory.
Each scenario is executed against the plugin and judged by an LLM.
"""

from datetime import datetime
from pathlib import Path

import pytest
import yaml

from src.evaluator.config import load_config
from src.evaluator.executor import (
    load_scenario_prompt,
    load_scenario_context,
    load_expected_output
)
from src.evaluator.models import EvaluationResult


@pytest.mark.evaluation
@pytest.mark.asyncio
async def test_scenario_evaluation(
    scenario: str,
    executor,
    judge,
    storage,
    run_id,
    passing_threshold,
    collect_result,
    config
):
    """
    Test a single evaluation scenario.

    This test:
    1. Loads the prompt from evaluations/{scenario}/prompt.md
    2. Executes it against the plugin
    3. Compares output against evaluations/{scenario}/expected/
    4. Uses LLM judge to score the result
    5. Stores result for historical tracking
    """
    # Skip if no real scenarios found
    if scenario == "no_scenarios_found":
        pytest.skip("No evaluation scenarios found in evaluations/ directory")

    scenario_dir = config.paths.evaluations / scenario

    # Skip if scenario directory doesn't exist
    if not scenario_dir.exists():
        pytest.skip(f"Scenario directory not found: {scenario_dir}")

    # Load scenario files
    try:
        prompt = load_scenario_prompt(scenario_dir)
    except FileNotFoundError as e:
        pytest.skip(f"Missing prompt file: {e}")

    try:
        expected_output = load_expected_output(scenario_dir)
    except FileNotFoundError as e:
        pytest.skip(f"Missing expected output: {e}")

    context = load_scenario_context(scenario_dir)
    context["scenario_name"] = scenario

    # Phase 1: Execute prompt against plugin
    execution_result = await executor.execute_scenario(
        prompt=prompt,
        scenario_name=scenario
    )

    # Check for execution errors
    if execution_result.error:
        pytest.fail(f"Execution failed: {execution_result.error}")

    if execution_result.parsed_yaml is None:
        pytest.fail(
            f"No YAML output captured. Raw output:\n"
            f"{execution_result.raw_output[:1000]}..."
        )

    # Phase 2: Judge the output
    actual_yaml_str = yaml.dump(
        execution_result.parsed_yaml,
        default_flow_style=False,
        allow_unicode=True
    )

    analysis = await judge.evaluate(
        actual_output=actual_yaml_str,
        expected_output=expected_output,
        scenario_context=context
    )

    # Create full result
    result = EvaluationResult(
        scenario_name=scenario,
        execution=execution_result,
        analysis=analysis,
        timestamp=datetime.now(),
        run_id=run_id,
        version="dev"
    )

    # Store result
    storage.store_scenario_result(run_id, result)
    collect_result(result)

    # Generate detailed failure message
    failure_details = (
        f"\nScore: {analysis.score.overall}/{passing_threshold} (threshold)\n"
        f"Reasoning: {analysis.reasoning}\n"
    )

    if analysis.missing_elements:
        failure_details += f"Missing: {analysis.missing_elements}\n"

    if analysis.incorrect_elements:
        failure_details += f"Incorrect: {analysis.incorrect_elements}\n"

    if analysis.suggestions:
        failure_details += f"Suggestions: {analysis.suggestions}\n"

    # Assert passing score
    assert analysis.score.overall >= passing_threshold, failure_details


@pytest.mark.evaluation
def test_scenarios_exist(config):
    """Verify that at least one evaluation scenario exists."""
    evaluations_dir = config.paths.evaluations

    if not evaluations_dir.exists():
        pytest.skip("Evaluations directory does not exist")

    scenarios = [
        d for d in evaluations_dir.iterdir()
        if d.is_dir() and (d / "prompt.md").exists()
    ]

    # This is informational, not a failure
    if not scenarios:
        pytest.skip(
            "No evaluation scenarios found. Create scenarios in evaluations/ directory:\n"
            "  evaluations/{scenario-name}/\n"
            "    ├── prompt.md          # Prompt to send\n"
            "    ├── context.yaml       # Optional context\n"
            "    └── expected/\n"
            "        └── .gitlab-ci.yml # Expected output"
        )

    print(f"\nFound {len(scenarios)} evaluation scenario(s): {scenarios}")
