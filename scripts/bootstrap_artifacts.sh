#!/usr/bin/env bash
set -euo pipefail

BASE=""
for d in .codex .claude .cursor .agent-cache; do
  if [ -d "$d" ]; then
    BASE="$d"
    break
  fi
done

if [ -z "$BASE" ]; then
  BASE=".agent-cache"
  mkdir -p "$BASE"
fi

for f in mission-plan.md validation-matrix.json run-log.md final-report.md; do
  if [ ! -f "$BASE/$f" ]; then
    : > "$BASE/$f"
    echo "Created $BASE/$f"
  else
    echo "Exists  $BASE/$f"
  fi
done
