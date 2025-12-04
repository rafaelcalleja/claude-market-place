"""
Phase 1: Executor - Run prompts against the plugin.

Executes prompts against a Claude Code plugin using the Agent SDK
and captures the output for evaluation.
"""

import re
import time
from pathlib import Path
from typing import Any

import yaml
from claude_agent_sdk import query, ClaudeAgentOptions
from claude_agent_sdk.types import (
    SdkPluginConfig,
    AssistantMessage,
    TextBlock,
    ToolUseBlock,
)

from .models import ExecutionResult


class PluginExecutor:
    """Executes prompts against a Claude Code plugin."""

    def __init__(
        self,
        plugin_path: Path,
        working_dir: Path | None = None,
        max_turns: int = 20,
        permission_mode: str = "acceptEdits",
        timeout_seconds: int = 120
    ):
        self.plugin_path = Path(plugin_path)
        self.working_dir = Path(working_dir) if working_dir else Path.cwd()
        self.max_turns = max_turns
        self.permission_mode = permission_mode
        self.timeout_seconds = timeout_seconds

    async def execute_scenario(
        self,
        prompt: str,
        scenario_name: str,
        system_prompt: str | None = None
    ) -> ExecutionResult:
        """
        Execute a prompt against the plugin and capture output.

        Args:
            prompt: The prompt to send to Claude
            scenario_name: Name of the scenario (for result tracking)
            system_prompt: Optional custom system prompt

        Returns:
            ExecutionResult with captured output and metadata
        """
        start_time = time.time()
        raw_output_parts: list[str] = []
        tool_calls: list[dict[str, Any]] = []
        error: str | None = None

        # Build system prompt
        if system_prompt is None:
            system_prompt = self._build_default_system_prompt()

        # Configure SDK with plugin
        options = ClaudeAgentOptions(
            system_prompt=system_prompt,
            permission_mode=self.permission_mode,  # type: ignore
            cwd=str(self.working_dir),
            plugins=[
                SdkPluginConfig(type="local", path=str(self.plugin_path))
            ],
            max_turns=self.max_turns
        )

        try:
            async for message in query(prompt=prompt, options=options):
                # Handle AssistantMessage with content blocks
                if isinstance(message, AssistantMessage):
                    for block in message.content:
                        if isinstance(block, TextBlock):
                            raw_output_parts.append(block.text)
                        elif isinstance(block, ToolUseBlock):
                            tool_calls.append({
                                "id": block.id,
                                "name": block.name,
                                "input": block.input
                            })
                # Handle other message types with hasattr fallback
                elif hasattr(message, "content"):
                    for block in message.content:
                        if hasattr(block, "text"):
                            raw_output_parts.append(block.text)
                        elif hasattr(block, "name"):
                            tool_calls.append({
                                "id": getattr(block, "id", "unknown"),
                                "name": block.name,
                                "input": getattr(block, "input", {})
                            })
        except Exception as e:
            error = str(e)

        execution_time_ms = int((time.time() - start_time) * 1000)
        full_output = "\n".join(raw_output_parts)

        return ExecutionResult(
            scenario_name=scenario_name,
            prompt=prompt,
            raw_output=full_output,
            parsed_yaml=self._extract_yaml(full_output),
            execution_time_ms=execution_time_ms,
            error=error,
            tool_calls=tool_calls
        )

    def _build_default_system_prompt(self) -> str:
        """Build the default system prompt for plugin testing."""
        return """You are testing a Claude Code plugin for generating GitLab CI/CD configurations.

When asked to create a pipeline or CI/CD configuration:
1. Use the plugin's skills and commands to generate the configuration
2. Output the complete YAML configuration wrapped in a ```yaml code block
3. Do not ask clarifying questions - make reasonable assumptions based on the requirements
4. Focus on generating a complete, valid .gitlab-ci.yml file

Be thorough and use the To-Be-Continuous (TBC) framework when appropriate."""

    def _extract_yaml(self, output: str) -> dict[str, Any] | None:
        """
        Extract YAML content from code blocks in the output.

        Looks for ```yaml or ```yml code blocks and returns the parsed content
        of the last one found (most likely to be the final output).
        """
        # Pattern to match yaml/yml code blocks
        pattern = r"```(?:yaml|yml)\n(.*?)```"
        matches = re.findall(pattern, output, re.DOTALL)

        if matches:
            # Use the last YAML block (most likely the final output)
            try:
                return yaml.safe_load(matches[-1])
            except yaml.YAMLError:
                return None
        return None


def load_scenario_prompt(scenario_dir: Path) -> str:
    """Load prompt from a scenario directory."""
    prompt_file = scenario_dir / "prompt.md"
    if not prompt_file.exists():
        raise FileNotFoundError(f"Prompt file not found: {prompt_file}")

    with open(prompt_file) as f:
        return f.read()


def load_scenario_context(scenario_dir: Path) -> dict[str, Any]:
    """Load optional context from a scenario directory."""
    context_file = scenario_dir / "context.yaml"
    if not context_file.exists():
        return {}

    with open(context_file) as f:
        return yaml.safe_load(f) or {}


def load_expected_output(scenario_dir: Path) -> str:
    """Load expected output from a scenario directory."""
    expected_dir = scenario_dir / "expected"
    gitlab_ci_file = expected_dir / ".gitlab-ci.yml"

    if not gitlab_ci_file.exists():
        raise FileNotFoundError(f"Expected output not found: {gitlab_ci_file}")

    with open(gitlab_ci_file) as f:
        return f.read()
