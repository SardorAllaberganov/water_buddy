---
description: Update docs after code changes — and do not invent new ones
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "WaterBuddyTests/**/*.swift"]
---

# Docs Cascade

Run `/doc_sync` after code changes. The doc set is small on purpose.

## What exists
1. **`docs/AI_CONTEXT.md`** — where the work stands: targets, the six shared files, files on disk,
   the non-negotiables, gate results with test counts, known issues
2. **`docs/STATE.md`** — the stored shape: every key with its justification, resolution and clamping,
   the day ordinal, the ordered rollover, who may write on behalf of the group, the migration, the
   reminder seam
3. **`docs/WIDGET.md`** — the widget contract: families, timeline, rendering modes, intent parameters
4. **`docs/DESIGN.md`** — tokens and the measurements behind them, including sampled contrast figures
5. **`CLAUDE.md`** — the governing doc. A rule here outranks every doc under `docs/`
6. **`tasks/lessons.md`** — pitfalls learned, append-only
7. **`HISTORY.md`** — checkpoints, append-only, newest at the bottom

## What must not be created
`docs/ARCHITECTURE.md`, `docs/CAPABILITIES.md` and `docs/dependencies.md` do **not** exist on
purpose: the topology is carried by `.claude/rules/10-architecture.md`, the capability surface by
`25-shared-storage` + `15-project`, and there are no dependencies to record. A stub restating a rule
file reads as coverage and is worse than the file's absence.

## Rules
- **`.claude/` is not derived.** A doc sync never rewrites a rule or a command — those change when the
  owner decides. A worked example in a rule may go stale while the rule itself still holds; leave it
- The **code wins**. If the docs and the code disagree, the docs change
- A doc sync writes only to `CLAUDE.md`, `docs/` and `tasks/` — never to a source or test target
- Never publish a gate result that was not run in this session. Write "not run" instead
- Never publish a count you did not just compute. The `@Test` count is the attribute grep, not a
  string grep
- Retire a known issue only when the fix is on disk
- A change to stored shape, the widget contract, target membership or entitlements cascades to
  `CLAUDE.md` **and** the sheet that owns the subject — not one or the other
- Historical entries are superseded, never rewritten
