## Git & Version Control

Never execute git commands (add, commit, push, pull, etc.). I handle all git operations manually to review your work before committing.

## Workflow

### Code simplifier

After finishing any coding task (writing new code, fixing bugs, refactoring, addressing review items), spawn a code-simplifier subagent to review the changed code for clarity, consistency, and maintainability.

**Why:** The user wants an automatic simplification pass on all code changes to catch unnecessary complexity, improve readability, and enforce project standards before considering work done.

**How to apply:** After all code changes compile and tests pass, launch an Agent with the code-simplifier plugin's principles (from `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/code-simplifier/agents/code-simplifier.md`): preserve functionality, reduce unnecessary complexity, improve naming, eliminate redundant abstractions, and choose clarity over brevity. Focus only on the files that were modified.
