# cmux.md

How to work when running inside cmux (macOS terminal workspace app).
Detection: `$CMUX_SURFACE_ID` is set; `cmux identify` succeeds.

## Guide sessions (pane-aware guiding)

- The user applies line-by-line guides in another pane — usually the left
  pane in the same workspace. `cmux identify` gives my own `caller.pane_ref`
  and `surface_ref`; `cmux tree` lists the rest. The user's pane is the
  sibling surface in my workspace whose title is a path/cwd, not a session
  title.
- Before giving the next guide step, read that surface to see the user's
  editor/shell state and verify the previous edit was applied as intended;
  adjust the guide if not.
- Read only. Never send text/keys (`send`, `send-key`) to the user's pane
  unless explicitly asked.

## Commands

- `cmux identify` — my own window/workspace/pane/surface refs
- `cmux tree` — every workspace, pane, surface with titles and ttys
- `cmux read-screen --surface <ref>` — what's on screen now
- `cmux read-screen --surface <ref> --scrollback --lines N` — recent scrollback
- `cmux send --surface <ref> <text>` — type into a pane (explicit request only)

## Remote work

`cmux ssh <host>` opens the remote shell as an ordinary cmux surface, so the
commands above work unchanged on remote panes. Don't run herdr on the remote
host just to get pane access.
