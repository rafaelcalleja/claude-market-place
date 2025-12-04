#!/usr/bin/env python3
"""
Test hook input/output locally without running Claude Code.

Usage:
    python3 test-hook-io.py <hook-script> <event-name> [--tool-name TOOL]

Examples:
    python3 test-hook-io.py ./validator.py PreToolUse --tool-name Bash
    python3 test-hook-io.py ./enricher.sh UserPromptSubmit
    python3 test-hook-io.py ./stop-check.py Stop
"""

import json
import sys
import subprocess
import argparse
from pathlib import Path


# Sample hook inputs for testing
SAMPLE_INPUTS = {
    "PreToolUse": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "cwd": "/home/user/project",
        "permission_mode": "default",
        "hook_event_name": "PreToolUse",
        "tool_name": "Bash",
        "tool_input": {
            "command": "echo 'hello world'",
            "description": "Test command"
        },
        "tool_use_id": "toolu_test123"
    },
    "PostToolUse": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "cwd": "/home/user/project",
        "permission_mode": "default",
        "hook_event_name": "PostToolUse",
        "tool_name": "Write",
        "tool_input": {
            "file_path": "/tmp/test.txt",
            "content": "test content"
        },
        "tool_response": {
            "filePath": "/tmp/test.txt",
            "success": True
        },
        "tool_use_id": "toolu_test123"
    },
    "UserPromptSubmit": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "cwd": "/home/user/project",
        "permission_mode": "default",
        "hook_event_name": "UserPromptSubmit",
        "prompt": "Write a function to validate email addresses"
    },
    "Stop": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "permission_mode": "default",
        "hook_event_name": "Stop",
        "stop_hook_active": False
    },
    "SubagentStop": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "permission_mode": "default",
        "hook_event_name": "SubagentStop",
        "stop_hook_active": False
    },
    "SessionStart": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "permission_mode": "default",
        "hook_event_name": "SessionStart",
        "source": "startup"
    },
    "SessionEnd": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "cwd": "/home/user/project",
        "permission_mode": "default",
        "hook_event_name": "SessionEnd",
        "reason": "other"
    },
    "Notification": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "cwd": "/home/user/project",
        "permission_mode": "default",
        "hook_event_name": "Notification",
        "message": "Claude needs your permission",
        "notification_type": "permission_prompt"
    },
    "PreCompact": {
        "session_id": "test-session-123",
        "transcript_path": "/tmp/transcript.jsonl",
        "permission_mode": "default",
        "hook_event_name": "PreCompact",
        "trigger": "manual",
        "custom_instructions": ""
    }
}


def run_hook(script_path, input_data, timeout=10):
    """Run hook script with input data via stdin."""
    try:
        result = subprocess.run(
            [script_path],
            input=json.dumps(input_data),
            capture_output=True,
            text=True,
            timeout=timeout,
            env={**subprocess.os.environ, "CLAUDE_PROJECT_DIR": "/home/user/project"}
        )

        return {
            "exit_code": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr
        }
    except subprocess.TimeoutExpired:
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": f"Hook timed out after {timeout}s"
        }
    except Exception as e:
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": f"Error running hook: {str(e)}"
        }


def parse_hook_output(exit_code, stdout, stderr):
    """Parse hook output and provide interpretation."""
    interpretation = []

    # Interpret exit code
    if exit_code == 0:
        interpretation.append("✓ Exit Code 0: Success")

        # Try to parse stdout as JSON
        if stdout.strip():
            try:
                output_json = json.loads(stdout)
                interpretation.append("✓ Valid JSON output detected")

                # Check for decision control
                if "decision" in output_json:
                    interpretation.append(f"  Decision: {output_json['decision']}")
                if "reason" in output_json:
                    interpretation.append(f"  Reason: {output_json['reason']}")
                if "continue" in output_json:
                    interpretation.append(f"  Continue: {output_json['continue']}")
                if "hookSpecificOutput" in output_json:
                    interpretation.append("  Hook-specific output provided")

            except json.JSONDecodeError:
                interpretation.append("  Plain text output (will be added to context)")

    elif exit_code == 2:
        interpretation.append("✗ Exit Code 2: Blocking error")
        interpretation.append("  Behavior: Blocks action, stderr fed to Claude")
        interpretation.append(f"  Message: {stderr}")

    else:
        interpretation.append(f"! Exit Code {exit_code}: Non-blocking error")
        interpretation.append("  Behavior: Execution continues, logged to verbose mode")

    return "\n".join(interpretation)


def main():
    parser = argparse.ArgumentParser(
        description="Test Claude Code hook scripts locally"
    )
    parser.add_argument("script", help="Path to hook script")
    parser.add_argument("event", choices=SAMPLE_INPUTS.keys(), help="Hook event name")
    parser.add_argument("--tool-name", help="Override tool name (for PreToolUse/PostToolUse)")
    parser.add_argument("--command", help="Override bash command (for PreToolUse with Bash)")
    parser.add_argument("--timeout", type=int, default=10, help="Timeout in seconds")
    parser.add_argument("--custom-input", help="Path to custom JSON input file")

    args = parser.parse_args()

    script_path = Path(args.script)
    if not script_path.exists():
        print(f"Error: Script not found: {script_path}")
        sys.exit(1)

    if not script_path.stat().st_mode & 0o111:
        print(f"Warning: Script is not executable. Run: chmod +x {script_path}")

    # Prepare input data
    if args.custom_input:
        with open(args.custom_input) as f:
            input_data = json.load(f)
    else:
        input_data = SAMPLE_INPUTS[args.event].copy()

        # Apply overrides
        if args.tool_name and "tool_name" in input_data:
            input_data["tool_name"] = args.tool_name

        if args.command and args.event == "PreToolUse":
            input_data["tool_input"]["command"] = args.command

    # Display test info
    print("=" * 60)
    print(f"Testing Hook: {script_path.name}")
    print(f"Event: {args.event}")
    print("=" * 60)

    print("\nInput Data:")
    print("-" * 60)
    print(json.dumps(input_data, indent=2))

    # Run hook
    print("\nRunning Hook...")
    print("-" * 60)
    result = run_hook(str(script_path), input_data, args.timeout)

    # Display results
    print("\nResults:")
    print("-" * 60)
    print(f"Exit Code: {result['exit_code']}")

    if result['stdout']:
        print(f"\nStdout:")
        print(result['stdout'])

    if result['stderr']:
        print(f"\nStderr:")
        print(result['stderr'])

    print("\nInterpretation:")
    print("-" * 60)
    interpretation = parse_hook_output(
        result['exit_code'],
        result['stdout'],
        result['stderr']
    )
    print(interpretation)

    print("\n" + "=" * 60)

    # Exit with hook's exit code
    sys.exit(result['exit_code'])


if __name__ == "__main__":
    main()
