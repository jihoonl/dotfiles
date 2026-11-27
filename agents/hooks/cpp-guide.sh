#!/usr/bin/env bash
set -euo pipefail

input="$(cat)"
candidates="$(printf '%s' "${input}" | jq -r '
  .tool_input as $t
  | (
      [$t.file_path // empty]
      + [(($t.command // "") | if type == "array" then join(" ") else tostring end)]
      + ((($t.input // $t.patch // "") | split("\n")) | map(select(startswith("*** "))))
    )
  | .[]
' 2>/dev/null || true)"

printf '%s\n' "${candidates}" | grep -qE '\.(cpp|cc|cxx|hpp|hh|hxx|h|inl|ipp)([^A-Za-z0-9_.]|$)' || exit 0

session_id="$(printf '%s' "${input}" | jq -r '.session_id // empty' 2>/dev/null || true)"
if [[ -n "${session_id}" ]]; then
  marker="/tmp/cppmd-${session_id}"
  [[ -e "${marker}" ]] && exit 0
  touch "${marker}"
fi

guide="${HOME}/.claude/CPP.md"
[[ -f "${guide}" ]] || exit 0

jq -n --rawfile g "${guide}" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: ("You are working on C++ code. Follow this guide (~/.claude/CPP.md):\n\n" + $g)
  }
}'
