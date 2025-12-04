# Stop Evaluator Example

This example demonstrates a prompt-based Stop hook that uses an LLM to intelligently decide if Claude should continue working.

## Features

- Uses LLM (Haiku) for context-aware decisions
- Evaluates if all tasks are complete
- Checks for errors requiring fixes
- Verifies tests have been run
- No script required - pure configuration

## Configuration

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "You are evaluating whether Claude should stop working. Review the context: $ARGUMENTS\n\nAnalyze the conversation and determine if:\n1. All user-requested tasks are complete\n2. No errors or failures need to be addressed\n3. Tests have been run and are passing\n4. No follow-up work is needed\n\nRespond with JSON:\n{\n  \"decision\": \"approve\" or \"block\",\n  \"reason\": \"Brief explanation of your decision\"\n}\n\nBe strict: if ANY work remains, use \"block\".",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## How It Works

1. When Claude finishes responding, Stop event fires
2. Hook sends conversation context to Haiku
3. Haiku evaluates if work is complete
4. If incomplete: Returns `"decision": "block"` with reason
5. Claude continues with the reason as instruction

## Example LLM Responses

**All tasks complete:**
```json
{
  "decision": "approve",
  "reason": "All requested features have been implemented and tests are passing."
}
```

**Work remains:**
```json
{
  "decision": "block",
  "reason": "Tests have not been run yet. Please execute the test suite to verify the implementation."
}
```

**Errors detected:**
```json
{
  "decision": "block",
  "reason": "The last command failed with an error. Please investigate and fix the issue before stopping."
}
```

## Customizing the Prompt

Adjust the evaluation criteria based on your workflow:

**For TDD workflows:**
```json
{
  "type": "prompt",
  "prompt": "Context: $ARGUMENTS\n\nCheck:\n1. Tests written before implementation (RED)\n2. Implementation passes tests (GREEN)\n3. Code refactored (REFACTOR)\n\nIf any step is missing, block with specific instruction.\n\nRespond: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
}
```

**For documentation requirements:**
```json
{
  "type": "prompt",
  "prompt": "Context: $ARGUMENTS\n\nVerify:\n1. All code changes documented\n2. README updated if needed\n3. API docs current\n\nBlock if documentation is missing.\n\nRespond: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
}
```

**For code review workflows:**
```json
{
  "type": "prompt",
  "prompt": "Context: $ARGUMENTS\n\nEnsure:\n1. All requested changes implemented\n2. No merge conflicts\n3. Commit messages follow convention\n4. PR ready for review\n\nRespond: {\"decision\": \"approve\" or \"block\", \"reason\": \"explanation\"}"
}
```

## Benefits of Prompt-Based Hooks

**Context-aware**: LLM understands conversation nuances
**Flexible**: Natural language prompts, no coding required
**Adaptive**: Evaluates based on current state, not rigid rules
**Maintainable**: Change criteria by editing prompt, not code

## Combining with Command Hooks

You can use both prompt-based and command-based hooks together:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/check-tests.sh"
          },
          {
            "type": "prompt",
            "prompt": "Context: $ARGUMENTS\n\nEvaluate if all tasks complete..."
          }
        ]
      }
    ]
  }
}
```

Both hooks run in parallel. If either blocks, Claude continues.

## Performance

- **Latency**: 500ms-2s for LLM evaluation
- **Cost**: Minimal (Haiku model used)
- **Reliability**: Handles API failures gracefully

## Use Cases

Prompt-based Stop hooks are ideal for:
- **Task completion verification**: Check if all work done
- **Quality gates**: Ensure tests pass, docs updated
- **Workflow enforcement**: TDD, code review, etc.
- **Error detection**: Catch unresolved failures
- **Context-sensitive decisions**: Different criteria based on context
