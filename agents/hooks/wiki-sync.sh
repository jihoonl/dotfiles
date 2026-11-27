#!/usr/bin/env bash
# Keep ~/.wiki/* git repos in sync. Usage: wiki-sync.sh [--hook] pull|push
# pull : fast-forward from origin (SessionStart)
# push : commit local changes and push (Stop)
# Never stashes: other agent sessions may be writing concurrently, and an
# autostash re-apply under a concurrent write leaves conflict markers behind.
# Antigravity hooks require JSON on stdout and run Stop synchronously per turn.
if [ "${1:-}" = "--hook" ]; then
  shift
  mode=${1:-push}
  cat >/dev/null 2>&1 || true
  mkdir -p "$HOME/.claude/hooks"
  if [ "$mode" = push ]; then
    nohup bash "$0" push >>"$HOME/.claude/hooks/wiki-sync.log" 2>&1 </dev/null &
  else
    bash "$0" "$mode" >>"$HOME/.claude/hooks/wiki-sync.log" 2>&1 || true
  fi
  printf '{}\n'
  exit 0
fi

mode=${1:-push}
# Dead TCP (e.g. network switch) must fail fast, or a hung push holds the lock forever.
export GIT_SSH_COMMAND='ssh -o ConnectTimeout=10 -o ServerAliveInterval=5 -o ServerAliveCountMax=3'
for repo in "$HOME"/.wiki/*/; do
  [ -d "$repo/.git" ] || continue
  lock="$repo/.git/wiki-sync.lock"
  find "$lock" -maxdepth 0 -mmin +5 -delete 2>/dev/null   # stale lock from a killed session
  mkdir "$lock" 2>/dev/null || continue   # another session is syncing
  (
    cd "$repo" || exit 0
    if [ "$mode" = push ] && [ -n "$(git status --porcelain)" ]; then
      git add -A
      git commit -q -m "wiki: auto-sync $(date +%Y-%m-%dT%H:%M) from $(hostname -s)"
    fi
    if [ -z "$(git status --porcelain)" ] && ! git pull -q --rebase origin HEAD; then
      git rebase --abort 2>/dev/null   # leave the tree clean; surface below
      exit 3
    fi
    [ "$mode" = push ] && git push -q origin HEAD
  ) >>"$HOME/.claude/hooks/wiki-sync.log" 2>&1
  [ $? -eq 3 ] && echo "wiki-sync: pull failed in $repo (conflict or offline); run 'git pull --rebase' there, see ~/.claude/hooks/wiki-sync.log"
  rmdir "$lock"
done
# Re-index qmd collections over ~/.wiki (memory/, wiki/); ~0.2 s when nothing changed.
if [ "$mode" = push ] && command -v qmd >/dev/null; then
  { qmd update && qmd embed; } >/dev/null 2>>"$HOME/.claude/hooks/wiki-sync.log"
fi
exit 0
