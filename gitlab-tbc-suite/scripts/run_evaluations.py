#!/usr/bin/env python3
"""
CLI entry point for running plugin evaluations.

Usage:
    python scripts/run_evaluations.py                    # Run all scenarios
    python scripts/run_evaluations.py --scenario foo     # Run specific scenario
    python scripts/run_evaluations.py --threshold 80     # Custom threshold
    python scripts/run_evaluations.py --mr-id 123        # Track MR
    python scripts/run_evaluations.py --list             # List scenarios
    python scripts/run_evaluations.py --history          # Show history
"""

import argparse
import asyncio
import sys
from datetime import datetime
from pathlib import Path

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from src.evaluator.config import load_config
from src.evaluator.executor import (
    PluginExecutor,
    load_scenario_prompt,
    load_scenario_context,
    load_expected_output
)
from src.evaluator.judge import EvaluationJudge
from src.evaluator.storage import ResultStorage
from src.evaluator.models import EvaluationResult

import yaml


def list_scenarios(config) -> list[str]:
    """List available evaluation scenarios."""
    evaluations_dir = config.paths.evaluations
    if not evaluations_dir.exists():
        return []

    return [
        d.name for d in sorted(evaluations_dir.iterdir())
        if d.is_dir() and (d / "prompt.md").exists()
    ]


def print_scenario_info(scenario_dir: Path) -> None:
    """Print information about a scenario."""
    prompt_file = scenario_dir / "prompt.md"
    context_file = scenario_dir / "context.yaml"

    print(f"  Prompt: {prompt_file}")

    if context_file.exists():
        with open(context_file) as f:
            context = yaml.safe_load(f) or {}
        if "description" in context:
            print(f"  Description: {context['description']}")


async def run_scenario(
    scenario_name: str,
    executor: PluginExecutor,
    judge: EvaluationJudge,
    storage: ResultStorage,
    run_id: str,
    config
) -> EvaluationResult:
    """Run a single evaluation scenario."""
    scenario_dir = config.paths.evaluations / scenario_name

    print(f"\n{'='*60}")
    print(f"Running: {scenario_name}")
    print(f"{'='*60}")

    # Load scenario
    prompt = load_scenario_prompt(scenario_dir)
    expected_output = load_expected_output(scenario_dir)
    context = load_scenario_context(scenario_dir)
    context["scenario_name"] = scenario_name

    # Phase 1: Execute
    print("Phase 1: Executing prompt against plugin...")
    execution_result = await executor.execute_scenario(
        prompt=prompt,
        scenario_name=scenario_name
    )

    if execution_result.error:
        print(f"  ERROR: {execution_result.error}")
    else:
        print(f"  Execution time: {execution_result.execution_time_ms}ms")
        print(f"  Tool calls: {len(execution_result.tool_calls)}")
        print(f"  YAML extracted: {execution_result.parsed_yaml is not None}")

    # Phase 2: Judge
    print("\nPhase 2: Evaluating output with LLM judge...")

    if execution_result.parsed_yaml:
        actual_yaml_str = yaml.dump(
            execution_result.parsed_yaml,
            default_flow_style=False,
            allow_unicode=True
        )
    else:
        actual_yaml_str = "(No YAML output captured)"

    analysis = await judge.evaluate(
        actual_output=actual_yaml_str,
        expected_output=expected_output,
        scenario_context=context
    )

    # Print results
    print(f"\n  Scores:")
    print(f"    Overall:      {analysis.score.overall}/100")
    print(f"    Structural:   {analysis.score.structural}/100")
    print(f"    Semantic:     {analysis.score.semantic}/100")
    print(f"    Completeness: {analysis.score.completeness}/100")
    print(f"    Correctness:  {analysis.score.correctness}/100")

    if analysis.missing_elements:
        print(f"\n  Missing: {analysis.missing_elements[:3]}...")

    if analysis.incorrect_elements:
        print(f"  Incorrect: {analysis.incorrect_elements[:3]}...")

    # Create result
    result = EvaluationResult(
        scenario_name=scenario_name,
        execution=execution_result,
        analysis=analysis,
        timestamp=datetime.now(),
        run_id=run_id,
        version="dev"
    )

    # Store result
    storage.store_scenario_result(run_id, result)

    return result


async def main():
    parser = argparse.ArgumentParser(
        description="Run plugin evaluations",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                         Run all scenarios
  %(prog)s --scenario python-k8s   Run specific scenario
  %(prog)s --threshold 80          Use custom passing threshold
  %(prog)s --mr-id 123             Track merge request
  %(prog)s --list                  List available scenarios
  %(prog)s --history               Show evaluation history
        """
    )
    parser.add_argument(
        "--config", "-c",
        default="config.yaml",
        help="Path to config file (default: config.yaml)"
    )
    parser.add_argument(
        "--scenario", "-s",
        help="Run specific scenario only"
    )
    parser.add_argument(
        "--threshold", "-t",
        type=int,
        help="Passing threshold (overrides config)"
    )
    parser.add_argument(
        "--mr-id",
        help="Merge request ID for tracking"
    )
    parser.add_argument(
        "--version", "-v",
        default="dev",
        help="Plugin version being tested"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List available scenarios"
    )
    parser.add_argument(
        "--history",
        action="store_true",
        help="Show evaluation history"
    )

    args = parser.parse_args()

    # Load config
    config = load_config(args.config)

    # Handle --list
    if args.list:
        scenarios = list_scenarios(config)
        if not scenarios:
            print("No evaluation scenarios found.")
            print(f"Create scenarios in: {config.paths.evaluations}/")
            return 0

        print(f"Available scenarios ({len(scenarios)}):\n")
        for s in scenarios:
            print(f"  - {s}")
            print_scenario_info(config.paths.evaluations / s)
            print()
        return 0

    # Initialize components
    storage = ResultStorage(config.paths.results)

    # Handle --history
    if args.history:
        history = storage.get_history(limit=10)
        if not history:
            print("No evaluation history found.")
            return 0

        print("Recent Evaluation History:\n")
        print(f"{'Run ID':<30} {'Score':>8} {'Passed':>8} {'Failed':>8}")
        print("-" * 60)
        for run in history:
            print(
                f"{run['run_id']:<30} "
                f"{run['average_score']:>8.1f} "
                f"{run['passed']:>8} "
                f"{run['failed']:>8}"
            )
        return 0

    # Get scenarios to run
    scenarios = list_scenarios(config)

    if not scenarios:
        print("No evaluation scenarios found.")
        print(f"Create scenarios in: {config.paths.evaluations}/")
        return 1

    if args.scenario:
        if args.scenario not in scenarios:
            print(f"Scenario '{args.scenario}' not found.")
            print(f"Available: {scenarios}")
            return 1
        scenarios = [args.scenario]

    # Initialize executor and judge
    workspace = PROJECT_ROOT / "workspace"
    workspace.mkdir(exist_ok=True)

    executor = PluginExecutor(
        plugin_path=config.plugin.path,
        working_dir=workspace,
        max_turns=config.executor.max_turns,
        permission_mode=config.executor.permission_mode,
        timeout_seconds=config.executor.timeout_seconds
    )

    judge = EvaluationJudge(model=config.judge.model)

    # Create run
    run_id = storage.create_run(mr_id=args.mr_id, version=args.version)
    print(f"Starting evaluation run: {run_id}")
    print(f"Scenarios to run: {len(scenarios)}")

    # Get threshold
    threshold = args.threshold or config.thresholds.passing

    # Run scenarios
    results: list[EvaluationResult] = []
    for scenario in scenarios:
        try:
            result = await run_scenario(
                scenario,
                executor,
                judge,
                storage,
                run_id,
                config
            )
            results.append(result)
        except Exception as e:
            print(f"\nERROR running {scenario}: {e}")

    # Finalize
    summary = storage.finalize_run(run_id, results, threshold)

    # Print summary
    print(f"\n{'='*60}")
    print("EVALUATION SUMMARY")
    print(f"{'='*60}")
    print(f"Run ID: {run_id}")
    print(f"Total Scenarios: {summary['total_scenarios']}")
    print(f"Passed: {summary['passed']} (threshold: {threshold})")
    print(f"Failed: {summary['failed']}")
    print(f"Average Score: {summary['average_score']:.1f}")
    print(f"{'='*60}")

    # Return exit code
    if summary['failed'] > 0:
        return 1
    return 0


if __name__ == "__main__":
    exit_code = asyncio.run(main())
    sys.exit(exit_code)
