"""
Storage for evaluation results with historical tracking.

Manages result persistence, run tracking, and historical data
for evaluation analysis and CI/CD integration.
"""

import json
from datetime import datetime
from pathlib import Path
from typing import Any

import yaml

from .models import EvaluationResult


class ResultStorage:
    """Manages storage and retrieval of evaluation results."""

    def __init__(self, results_dir: Path):
        self.results_dir = Path(results_dir)
        self.runs_dir = self.results_dir / "runs"
        self.history_file = self.results_dir / "history.json"

        # Ensure directories exist
        self.runs_dir.mkdir(parents=True, exist_ok=True)

    def create_run(
        self,
        mr_id: str | None = None,
        version: str | None = None
    ) -> str:
        """
        Create a new evaluation run and return its ID.

        Args:
            mr_id: Optional merge request ID for tracking
            version: Optional plugin version being tested

        Returns:
            The run ID (timestamp + optional MR ID)
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        run_id = f"{timestamp}_{mr_id}" if mr_id else timestamp

        run_dir = self.runs_dir / run_id
        run_dir.mkdir(exist_ok=True)

        # Initialize run metadata
        metadata = {
            "run_id": run_id,
            "timestamp": datetime.now().isoformat(),
            "mr_id": mr_id,
            "version": version,
            "status": "running",
            "scenarios": []
        }

        with open(run_dir / "summary.json", "w") as f:
            json.dump(metadata, f, indent=2)

        return run_id

    def store_scenario_result(
        self,
        run_id: str,
        result: EvaluationResult
    ) -> None:
        """
        Store result for a single scenario.

        Creates:
        - actual_output.yml: The parsed YAML output
        - raw_output.txt: Full raw output for debugging
        - evaluation.json: Judge analysis and scores
        """
        scenario_dir = self.runs_dir / run_id / result.scenario_name
        scenario_dir.mkdir(exist_ok=True)

        # Store actual output as YAML
        if result.execution.parsed_yaml:
            with open(scenario_dir / "actual_output.yml", "w") as f:
                yaml.dump(
                    result.execution.parsed_yaml,
                    f,
                    default_flow_style=False,
                    allow_unicode=True
                )

        # Store raw output for debugging
        with open(scenario_dir / "raw_output.txt", "w") as f:
            f.write(result.execution.raw_output)

        # Store evaluation details
        evaluation_data = {
            "scores": {
                "overall": result.analysis.score.overall,
                "structural": result.analysis.score.structural,
                "semantic": result.analysis.score.semantic,
                "completeness": result.analysis.score.completeness,
                "correctness": result.analysis.score.correctness
            },
            "correct_elements": result.analysis.correct_elements,
            "incorrect_elements": result.analysis.incorrect_elements,
            "missing_elements": result.analysis.missing_elements,
            "extra_elements": result.analysis.extra_elements,
            "reasoning": result.analysis.reasoning,
            "suggestions": result.analysis.suggestions,
            "execution_time_ms": result.execution.execution_time_ms,
            "tool_calls": result.execution.tool_calls,
            "error": result.execution.error,
            "timestamp": result.timestamp.isoformat()
        }

        with open(scenario_dir / "evaluation.json", "w") as f:
            json.dump(evaluation_data, f, indent=2)

    def finalize_run(
        self,
        run_id: str,
        results: list[EvaluationResult],
        passing_threshold: int = 70
    ) -> dict[str, Any]:
        """
        Finalize a run with aggregated statistics.

        Args:
            run_id: The run ID to finalize
            results: List of all evaluation results
            passing_threshold: Score threshold for passing

        Returns:
            Summary dictionary with aggregate statistics
        """
        run_dir = self.runs_dir / run_id

        # Calculate aggregates
        scores = [r.analysis.score.overall for r in results]
        avg_score = sum(scores) / len(scores) if scores else 0

        summary = {
            "run_id": run_id,
            "timestamp": datetime.now().isoformat(),
            "status": "completed",
            "total_scenarios": len(results),
            "passed": sum(1 for s in scores if s >= passing_threshold),
            "failed": sum(1 for s in scores if s < passing_threshold),
            "average_score": round(avg_score, 2),
            "min_score": min(scores) if scores else 0,
            "max_score": max(scores) if scores else 0,
            "passing_threshold": passing_threshold,
            "scenarios": [
                {
                    "name": r.scenario_name,
                    "score": r.analysis.score.overall,
                    "status": "passed" if r.analysis.score.overall >= passing_threshold else "failed",
                    "execution_time_ms": r.execution.execution_time_ms
                }
                for r in results
            ]
        }

        with open(run_dir / "summary.json", "w") as f:
            json.dump(summary, f, indent=2)

        # Update history
        self._update_history(summary)

        return summary

    def _update_history(self, run_summary: dict[str, Any]) -> None:
        """Append run to history file for trend tracking."""
        history: list[dict[str, Any]] = []
        if self.history_file.exists():
            with open(self.history_file) as f:
                history = json.load(f)

        history.append({
            "run_id": run_summary["run_id"],
            "timestamp": run_summary["timestamp"],
            "average_score": run_summary["average_score"],
            "passed": run_summary["passed"],
            "failed": run_summary["failed"],
            "total": run_summary["total_scenarios"]
        })

        # Keep last 100 runs to manage file size
        history = history[-100:]

        with open(self.history_file, "w") as f:
            json.dump(history, f, indent=2)

    def get_history(self, limit: int = 20) -> list[dict[str, Any]]:
        """
        Get recent evaluation history.

        Args:
            limit: Maximum number of runs to return

        Returns:
            List of run summaries, most recent last
        """
        if not self.history_file.exists():
            return []

        with open(self.history_file) as f:
            history = json.load(f)

        return history[-limit:]

    def get_run_summary(self, run_id: str) -> dict[str, Any] | None:
        """Get summary for a specific run."""
        summary_file = self.runs_dir / run_id / "summary.json"
        if not summary_file.exists():
            return None

        with open(summary_file) as f:
            return json.load(f)

    def get_scenario_result(
        self,
        run_id: str,
        scenario_name: str
    ) -> dict[str, Any] | None:
        """Get detailed result for a specific scenario in a run."""
        eval_file = self.runs_dir / run_id / scenario_name / "evaluation.json"
        if not eval_file.exists():
            return None

        with open(eval_file) as f:
            return json.load(f)

    def list_runs(self) -> list[str]:
        """List all run IDs, sorted by timestamp (newest first)."""
        if not self.runs_dir.exists():
            return []

        runs = [
            d.name for d in self.runs_dir.iterdir()
            if d.is_dir() and (d / "summary.json").exists()
        ]
        return sorted(runs, reverse=True)
