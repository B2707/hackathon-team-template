---
description: First Mate / River — the manager's autonomous liaison loop: triage the board, build ready work to DRAFT PRs, queue green ones for your one-tap merge. Manager seat only.
argument-hint: "[tick | bearings | ack | status]  (default tick; loop it with /loop 10m /fm)"
allowed-tools: Bash, Read, Write
---

# /fm — First Mate (River)

You are the **captain**; `/fm` is your **first mate**. You talk to one agent; it runs the
crew and hands you finished work. One tick = **sense** the board → **triage** → **build**
ready work to DRAFT PRs (headless codex) → **queue** the green ones for your ack → **digest**.
Run continuously on the First Mate pane with `/loop 10m /fm`, or once with `/fm`.

Autonomy: **build-and-queue-green.** River prepares, drafts, and queues; **a human always
merges.** Design adopted from `kunchenguid/firstmate` + ECC `continuous-agent-loop`, reusing
this repo's `/consensus`, `scripts/task`, tripwires, and review bot.

## Boundaries — why you can leave it running (structural, not vibes)
1. **River is read-only over the repo.** All code changes happen in **crewmate worktrees**
   behind your merge approval — never in the main working tree, never on `main`.
2. NEVER merge, NEVER push `main`, NEVER apply `break-glass`, NEVER `gh pr merge`.
3. NEVER decide a plan change / tool swap / dispute → `needs-human` + a digest line.
4. River **defers to the existing merge gate** — the required checks (`tests-touched`,
   `build-test`, and the AI `review` bot) decide mergeability, then YOU merge. River never
   self-certifies a PR on its own read, and never bypasses or replaces the review bot.
5. **Manager seat only** — refuse on any other seat.

## Task shapes (firstmate's ship-vs-scout)
- **ship** — issue is unclaimed, `ready`, in-scope, fully specified (brief has file scope +
  acceptance criteria) → build to a DRAFT PR.
- **scout** — issue is fuzzy, a question, or out-of-scope → DON'T build. Write a short
  investigation report to `data/context/handoffs/<n>.md` + a digest line. River never
  builds underspecified work.

## Phase 0 — Guard  [Preflight]
```bash
TMP="$(mktemp -d)"
: "${TEAM_SEAT:=$(git config user.name | tr ' [:upper:]' '-[:lower:]')}"
case "${FM_MANAGER:-$TEAM_SEAT}" in
  bader|manager) ;;
  *) echo "STOP: /fm is the First Mate (manager) seat only — TEAM_SEAT=$TEAM_SEAT. Override with FM_MANAGER=manager."; exit 1;;
esac
gh auth status >/dev/null 2>&1 || { echo "STOP: gh not authenticated (gh auth login)"; exit 1; }
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
HANDOFFS="$(git rev-parse --show-toplevel)/data/context/handoffs"; DIGEST="$HANDOFFS/DIGEST.md"
CODEX_OK=0; command -v codex >/dev/null 2>&1 && codex login status >/dev/null 2>&1 && CODEX_OK=1
[ "$CODEX_OK" = 0 ] && echo "NOTE: codex unavailable — this tick is triage + scout + digest only (no ship builds)."
```
Dispatch on `$ARGUMENTS`: `bearings`→Phase B (read-only), `diagnose [run|PR|latest]`→Phase D, `ack`→Phase A, `status`→print `$DIGEST`, else→Phases 1–5.

## Phase B — Bearings (read-only "where are we")
No writes. Print: ready / in-flight / blocked / green-unmerged / needs-human counts, the
`queued-merge` list, and the top 3 things that need *you*. The safe "pick up where I left
off" view — run it any time.

## Phase D — Diagnose a workflow/CI failure (workflow-doctor in a worktree)
For "the review bot flags everything", a red CI run, a hook that let something through,
subagents leaving gaps, stale context, malformed structured output, duplicate PR comments.
River stays read-only; the doctor is read-only too.
```bash
RUN=$(gh run list --status failure -L 1 --json databaseId,headSha,workflowName)   # or resolve from a run id / PR
ID=$(echo "$RUN" | jq -r '.[0].databaseId'); SHA=$(echo "$RUN" | jq -r '.[0].headSha')
gh run view "$ID" --log-failed > "$TMP/fail.log"      # the failing logs
git worktree add "$TMP/diag" "$SHA"                    # isolated read-only checkout of the failing state
```
Dispatch the **workflow-doctor** subagent (Task tool, `subagent_type: workflow-doctor`) in
**INCIDENT mode**, cwd = `$TMP/diag`, handing it the symptom + `$TMP/fail.log`. It diagnoses
against `data/context/anthropic-canon/` (read-only) and returns a cited root cause + fix.
River then writes the diagnosis to `$HANDOFFS/incident-$ID.md` and either files a fix **issue**
(propose-style) or, if it's a clear in-scope fix, ships it to a DRAFT PR (Phase 3) — never a
direct main fix. Clean up: `git worktree remove "$TMP/diag"`.

## Phase 1 — Sense
```bash
gh issue list --state open -L 100 --json number,title,labels,assignees,updatedAt > "$TMP/issues.json"
gh pr list   --state open -L 100 --json number,title,headRefName,isDraft,mergeable,statusCheckRollup,labels > "$TMP/prs.json"
gh issue list --label proposed -L 50 --json number,title > "$TMP/proposed.json"
ls "$(git rev-parse --show-toplevel)/data/context/gotcha-candidates" 2>/dev/null
```
Summarize the board in ≤5 lines.

## Phase 2 — Triage (you pick the channel, never the outcome)
- **Gotcha candidates** → promote into `data/context/gotchas.md` (FM is the one writer) on a
  branch `fm/gotchas-<short-sha>`, open a normal PR (bot reviews). Never touch gotchas.md on main.
- **Proposals** (`proposed`): `PLAN:` titles → `needs-human` + digest line, leave for Bader.
  Clear, lane-relevant ideas → promote (drop `proposed`, add lane + priority). Fuzzy → digest, leave.
- **Board hazards** (mirror tripwires: stuck-pr / stale-claim / collision / deadlock) → write a
  next-up brief into `$HANDOFFS/`, digest line. Real red-main it can't SAFELY revert →
  `needs-human` + loud line. Never auto-revert main.

## Phase 3 — Ship ready work to DRAFT PRs  [Execute · codex · budget-capped]
Pick ≤ **${FM_BUILD_BUDGET:-2}** `ship`-shaped issues (`demo-path` first). Skip entirely if the
`budget` tripwire is hot (>10 review-bot runs this hour → build 0). For each, run the
**/consensus** engine (plan → codex consensus ≤5 → codex exec on a fresh `codex/<slug>`
worktree branch → cross-model review), then leave a **draft** PR — never ready, never merged:
```bash
git worktree add "$TMP/wt-$SLUG" -b "codex/$SLUG" origin/main    # isolated crewmate home
# run the /consensus procedure with cwd = "$TMP/wt-$SLUG"
gh pr create --draft --fill --head "codex/$SLUG" --label fm-built
```
Underspecified after a look → convert to **scout**, don't force a build. Clean up the worktree
(`git worktree remove`) once the branch is pushed.

## Phase 4 — Queue green drafts for your ack (no merge)
For each `fm-built` PR now not-draft-blocked, mergeable, review check GREEN, and bot `review`
passed → `gh pr edit <n> --add-label queued-merge` and add a one-line risk-tagged digest entry.
**Do not merge.**

## Phase 5 — Digest (one line per item, risk-tagged — firstmate style)
Overwrite `$DIGEST` (restart-proof: all state on disk). One line per item:
```
#42 rate-limiter    — DRAFT #88 · risk: low  · CI green  · QUEUED for /fm ack
#43 oauth refactor  — SCOUT handoffs/43.md · risk: high · NEEDS YOUR CALL
#51 PLAN: swap Redis→SQLite — needs-human · your decision
```
Print the QUEUED and NEEDS-YOUR-CALL sections to the pane so you catch them at a glance.

## Phase A — /fm ack  (the ONLY path to main — you, not River)
```bash
gh pr list --label queued-merge --json number,title,url -q '.[] | "\(.number)  \(.title)  \(.url)"'
# for each you approve:  gh pr ready <n> && gh pr merge <n> --squash   (bot gate still applies)
```

## Caps (hard)
Build budget ${FM_BUILD_BUDGET:-2}/tick · consensus ≤5 rounds · ≤1 fix pass (from /consensus).
Never exceed; never merge; never push main; never break-glass. `rm -rf "$TMP"` at the end of the tick.
