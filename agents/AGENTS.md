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

## 3. Code Structure
Applies to code you write. When editing existing code, follow its structure; don't restructure it unless asked (§4). Exception: to add a requested test, extract only what the test needs and say so.
- Each function reads at one level of abstraction: a reader learns what it does without opening the functions it calls.
- Extract a block when it needs a comment to say what it does, or a test needs it alone. Keep it inline when a name would only restate the code: no one-line wrappers, no single-use helper as plain as its body. A new class, interface, or layer still needs a real need (§2).
- Keep logic testable: decisions and computation go in functions that take inputs and return outputs. Push I/O, clocks, hardware, and globals to the edges and pass them in. Add a seam (injected dependency, interface) only where a test needs to replace something.
- Write for the human reader: names that say what a thing is or returns, early returns over deep nesting, no clever code a reader has to decode. When fewer lines and readability conflict, choose readability.

## 4. Surgical Changes
- Touch only what the task requires.
- Don't refactor or reformat working code.
- Match existing style.
- Remove orphans your change created; leave pre-existing dead code (mention it).

## 5. Goal-Driven Execution
- Turn tasks into verifiable goals (e.g. "fix bug" → "test that reproduces it, then make it pass").
- For multi-step work, state a brief plan with a verify step each.

## 6. Worktree for New Work
- Starting new development (feature/fix branch)? Create it as a git worktree under
  the repo's `.worktrees/<branch-name>` and work there — not in the main checkout.
- Branch names must follow the repo's convention — check its CI branch-name rules
  before creating. Never rename a branch after its PR is open; GitHub may close the PR.
- Ensure `.worktrees/` is gitignored in that repo first.
- Small edits to the current branch, questions, and reviews: stay put.

## 7. Guide-First Development
- When the user says to start development, default to a line-by-line implementation guide with exact files, edit locations, and code; let the user make the changes.
- Structure the guide like a human develops, not as a per-file edit list: start from the entry point / main flow, descend outward-in step by step, and cut each step as a buildable, verifiable increment (with its build command or runtime check). Includes, members, and build changes belong to the step that needs them.
- Create worktrees or modify files only when the user explicitly asks you to make or apply the changes directly.
- Exception: test code — write and apply it directly yourself; only the implementation goes through the guide.
- Keep the full guide in one file (scratchpad by default) and revise it there. In chat, show only the steps that changed; re-print the whole guide only when asked.
- Running inside herdr (`herdr pane current` succeeds) or cmux (`$CMUX_SURFACE_ID` set)? Read and follow `herdr.md` or `cmux.md` in the same directory as this file — guide by watching the user's pane.

## 8. C++ Development
- When working on C++, read and follow `CPP.md` in the same directory as this file.

## 9. Write Plainly, Facts Only
Applies to PR bodies, PR/review comments, code comments, and every reply to the user.
- State facts: what changed, what was measured, what is unverified. No adjectives, hedging, praise, or restating the question.
- Answer first, one or two lines per point. Tables and short bullets over paragraphs.
- No unrequested template sections (to-do, done criteria, out of scope) or self-added checklists.
- Code comments: only the non-obvious fact (why, constraint, unit). No narration of what the code does, no change history.
