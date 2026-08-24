# CLAUDE.md

Guidelines to reduce common coding mistakes. Bias toward caution over speed; use judgment on trivial tasks.

## 1. Think Before Coding
- State assumptions. If uncertain, ask.
- Multiple interpretations? Present them — don't pick silently.
- Simpler approach exists? Say so.

## 2. Simplicity First
- Minimum code that solves the problem.
- No unrequested features, abstractions, config, or error handling.
- If 200 lines could be 50, rewrite it.

## 3. Surgical Changes
- Touch only what the task requires.
- Don't refactor or reformat working code.
- Match existing style.
- Remove orphans your change created; leave pre-existing dead code (mention it).

## 4. Goal-Driven Execution
- Turn tasks into verifiable goals (e.g. "fix bug" → "test that reproduces it, then make it pass").
- For multi-step work, state a brief plan with a verify step each.

## 5. Worktree for New Work
- Starting new development (feature/fix branch)? Create it as a git worktree under
  the repo's `.claude/worktrees/<branch-name>` and work there — not in the main checkout.
- Ensure `.claude` (or `.claude/worktrees/`) is gitignored in that repo first.
- Small edits to the current branch, questions, and reviews: stay put.
