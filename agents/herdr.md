# herdr.md

How to work when running inside herdr (terminal workspace manager).
Detection: `herdr pane current` succeeds.

## Guide sessions (pane-aware guiding)

- The user applies line-by-line guides in another pane — usually the left
  pane in the same tab. Find it with `herdr pane list`: a pane in my tab
  without an `agent` field, or `herdr pane neighbor --current --direction left`.
- Before giving the next guide step, read that pane to see the user's
  editor/shell state and verify the previous edit was applied as intended;
  adjust the guide if not.
- Read only. Never send text/keys (`send-text`, `send-keys`, `run`) to the
  user's pane unless explicitly asked.

## Commands

- `herdr pane current` — my own pane (id, tab, workspace)
- `herdr pane list` — all panes with pane_id, cwd, agent/user, titles
- `herdr pane read <pane_id> --source visible` — what's on screen now
- `herdr pane read <pane_id> --source recent --lines N` — recent scrollback
- `herdr pane run --pane <pane_id> <cmd>` — run in a pane (explicit request only)
