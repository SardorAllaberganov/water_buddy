# /doc_sync

Synchronize the developer docs with the current code state. Writes only to `CLAUDE.md`, `docs/` and
`tasks/` — never to `WaterBuddy/`, `WaterBuddyWidget/` or the test targets. `CLAUDE.md` is in scope
because it carries the target table, the shared-file contract and the storage invariants, all of
which drift with the code. `.claude/` is **not** in scope: rule `99-docs-cascade` says it is not
derived — it changes when the owner decides.

## Start with a diff, not a reread

Docs drift toward the plan, not the code. Begin every sync by comparing the documented file list
against reality — that is what catches a whole file going undocumented:

```bash
find WaterBuddy WaterBuddyWidget WaterBuddyTests WaterBuddyUITests -name '*.swift' | sort
grep -ohE '[A-Za-z0-9]+\.swift' docs/AI_CONTEXT.md | sort -u

# Count the ATTRIBUTE, never the string — `@Test` also appears inside DocC comments,
# and a doc that overstates coverage is worse than one that omits it.
grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'
grep -chE '^[[:space:]]*func test' WaterBuddyUITests/*.swift | awk '{s+=$1} END {print s}'

# The shared-file contract lives in the project file, not in prose.
sed -n '/membershipExceptions/,/);/p' WaterBuddy.xcodeproj/project.pbxproj
```

## Steps

1. **`docs/AI_CONTEXT.md`** — where the work stands. Refresh the targets table, the shared-file
   list, the files-on-disk line counts, the gate results with their test counts, and the known-issues
   list. **Never report a gate result that was not run in this session** — say "not run" instead.
   Retire a known issue only when the fix is on disk, not when it is planned.

2. **`docs/STATE.md`** — the stored shape: every key on `DataManager.Key` with its type and its
   one-line justification, the resolution and clamping rules, the day ordinal, the ordered rollover,
   who may write on behalf of the group, the one-shot migration, and the reminder seam. If a key was
   added, the count in **both** this file and `CLAUDE.md` has to move.

3. **`docs/WIDGET.md`** — the widget contract: supported families, the timeline and its entries,
   both rendering modes, the derived vessel geometry, and `AddWaterIntent` as Shortcuts sees it
   (including the parameter range, which is wider than the button's serving).

4. **`docs/DESIGN.md`** — the tokens and the measurements behind them: the elevation/density/base
   tables, the palette, the water and the scrim, and the measured contrast figures. Re-verify any
   arithmetic whenever a token changes — compute it, do not eyeball it.

5. **`CLAUDE.md`** — the governing doc, and the one a sync scoped to `docs/` skips. Reconcile the
   target table, the six shared files, the storage table and the key count, the mutation surface it
   names, and the "Architecture" and "Storage" bullet lists against the code. A rule here outranks
   every doc under `docs/`, so a stale one misdirects the next change before any of them are read.

6. **`tasks/lessons.md`** — append-only. Add a `## YYYY-MM-DD — <topic>` entry for each pattern
   learned since the last sync: what happened, why, and the rule that prevents a repeat. Never
   delete or edit a prior entry.

7. **`HISTORY.md`** — append a checkpoint at the bottom: `## [YYYY-MM-DD] — <one-line summary>`
   with what changed, drift found and fixed, what was checked and already accurate, files touched,
   and the gate result. Historical entries stay as written — supersede them, never rewrite them.

8. **Docs that must not be created.** `docs/ARCHITECTURE.md`, `docs/CAPABILITIES.md` and
   `docs/dependencies.md` do not exist on purpose: the topology is carried by
   `.claude/rules/10-architecture.md`, the capability surface by `25-shared-storage` + `15-project`,
   and there are no dependencies to record. A stub restating a rule file reads as coverage and is
   worse than the file's absence.

## Verify before claiming the sync is done

- Every doc under `docs/` had its `Last updated:` inspected, and refreshed if its content changed.
- `ls docs/*.md` **plus `CLAUDE.md`** cross-checked against steps 1–5 — no doc silently skipped.
- The documented file list matches `find … -name '*.swift'`, and the line counts are current.
- The published `@Test` count matches the attribute grep, and the same number appears in every
  place the docs state it.
- The key count agrees between `CLAUDE.md` and `docs/STATE.md`, and both match `DataManager.Key`.
- The six shared files agree between `CLAUDE.md` and `membershipExceptions` in `project.pbxproj`.
- No stale references to a surface that has been replaced — read the worked examples, do not regex
  them. The same idea is worded differently in each doc, and a pattern short enough to write will
  report false drift.
- Rule citations resolve: every `` rule `nn-name` `` mentioned in the docs has a file in
  `.claude/rules/`.
  ```bash
  grep -rhoE 'rule .[0-9]{2}-[a-z-]+.' CLAUDE.md docs/ tasks/ WaterBuddy/ WaterBuddyWidget/ \
    | grep -oE '[0-9]{2}-[a-z-]+' | sort -u \
    | while read r; do [ -f ".claude/rules/$r.md" ] || echo "MISSING: $r"; done
  ```
- Wrote nothing under `WaterBuddy/`, `WaterBuddyWidget/` or the test targets — a doc sync never
  edits code. If the docs and the code disagree, **the code wins** and the docs change.

> Use `grep -F` for fixed strings, and a script file rather than `swift -e` or an inline `python3 -c`
> inside bash — two layers of shell quoting silently mangle backticks and `\b`, producing checks that
> fail everywhere.
