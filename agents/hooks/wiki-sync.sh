#!/usr/bin/env bash
# Keep ~/.wiki/* git repos in sync. Usage: wiki-sync.sh pull|push
# pull : fast-forward from origin (SessionStart)
# push : commit local changes and push (Stop)
# Never stashes: other Claude sessions may be writing concurrently, and an
# autostash re-apply under a concurrent write leaves conflict markers behind.
mode=${1:-push}
for repo in "$HOME"/.wiki/*/; do
  [ -d "$repo/.git" ] || continue
  lock="$repo/.git/wiki-sync.lock"
  mkdir "$lock" 2>/dev/null || continue   # another session is syncing
  (
    cd "$repo" || exit 0
    if [ "$mode" = push ] && [ -n "$(git status --porcelain)" ]; then
      git add -A
      git commit -q -m "wiki: auto-sync $(date +%Y-%m-%dT%H:%M) from $(hostname -s)"
    fi
    [ -z "$(git status --porcelain)" ] && git pull -q --rebase origin HEAD
    [ "$mode" = push ] && git push -q origin HEAD
  ) >>"$HOME/.claude/hooks/wiki-sync.log" 2>&1
  rmdir "$lock"
done
exit 0
