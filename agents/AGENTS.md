# AGENTS.md

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
  the repo's `.worktrees/<branch-name>` and work there — not in the main checkout.
- Ensure `.worktrees/` is gitignored in that repo first.
- Small edits to the current branch, questions, and reviews: stay put.

## 6. Guide-First Development
- When the user says to start development, default to a line-by-line implementation guide with exact files, edit locations, and code; let the user make the changes.
- Create worktrees or modify files only when the user explicitly asks you to make or apply the changes directly.
- Exception: test code — write and apply it directly yourself; only the implementation goes through the guide.

## 7. C++ Development
- When working on C++, read and follow `CPP.md` in the same directory as this file.
