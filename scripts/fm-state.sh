#!/usr/bin/env bash
# fm-state — durable, restart-proof state for the /fm (River) loop (P2).
#
# The LIVE REPO is the source of truth; this file is only a cache. If it is
# lost, River re-derives "already built" from open codex/* branches + fm-built
# PRs, so a lost state file degrades to a re-scan — never a double-merge (branch
# protection) and rarely a double-build (fm-build's branch-collision check).
#
#   fm-state path                 print the state file path
#   fm-state init                 ensure state exists; reset the window on a new UTC day; bump tick
#   fm-state get <jq-filter>      read a value, e.g.  fm-state get '.buildsThisWindow'
#   fm-state built? <issue#>      exit 0 if the issue was already built this window
#   fm-state mark-built <issue#>  record a build: append the issue + bump the window counter
#   fm-state paused?              exit 0 if the PAUSE kill-switch file exists
set -euo pipefail

REPO_ROOT="$(git rev-parse --path-format=absolute --git-common-dir | xargs dirname)"
FM_DIR="$REPO_ROOT/data/context/fm"
STATE="$FM_DIR/state.json"
PAUSE="$FM_DIR/PAUSE"
TODAY="$(date -u +%F)"

_write() { mkdir -p "$FM_DIR"; cat > "$STATE.tmp"; mv -f "$STATE.tmp" "$STATE"; }

_ensure() {
  mkdir -p "$FM_DIR"
  [ -f "$STATE" ] || printf '{"schema":1,"window":"%s","buildsThisWindow":0,"tick":0,"builtIssues":[]}\n' "$TODAY" | _write
  local win; win="$(jq -r '.window // ""' "$STATE" 2>/dev/null || echo "")"
  if [ "$win" != "$TODAY" ]; then           # new UTC day → reset the build window
    jq --arg d "$TODAY" '.window=$d | .buildsThisWindow=0 | .builtIssues=[]' "$STATE" | _write
  fi
}

cmd="${1:-init}"; shift || true
case "$cmd" in
  path)       echo "$STATE" ;;
  init)       _ensure; jq '.tick=(.tick+1)' "$STATE" | _write ;;
  get)        _ensure; jq -r "${1:?usage: fm-state get <jq-filter>}" "$STATE" ;;
  built?)     _ensure; jq -e --argjson n "${1:?usage: fm-state built? <issue#>}" '.builtIssues | index($n) != null' "$STATE" >/dev/null ;;
  mark-built) _ensure; jq --argjson n "${1:?usage: fm-state mark-built <issue#>}" '.builtIssues=(.builtIssues+[$n]|unique) | .buildsThisWindow=(.buildsThisWindow+1)' "$STATE" | _write ;;
  paused?)    [ -f "$PAUSE" ] ;;
  *)          echo "fm-state: unknown subcommand: $cmd" >&2; exit 2 ;;
esac
