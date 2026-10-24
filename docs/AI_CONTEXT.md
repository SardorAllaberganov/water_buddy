# AI_CONTEXT — WaterBuddy

Orientation for anyone (human or model) picking this repo up cold.
Authority order is unchanged: **DocC on the type you are changing** → `.claude/rules/` →
`CLAUDE.md` → this file. This document records *where the work stands*, never what the rules say.

**Last updated:** 2026-10-24, evening (set A's step 5's own records, after its walk, its review and its
gate — not a `/doc_sync` pass). HEAD `ad244c2`, nothing committed. *Current state* gains step 5's block
above step 4's; *Targets*' three test rows (931 `@Test` in 105 suites, 61 UI `func test`, 70 watch — each
printed); *Files on disk*: four new rows (`RecapCard.swift` 295, `RecapSheet.swift` 200,
`MonthRecapTests.swift` 254, `RecapImageTests.swift` 104) and six changed by `wc -l` — `DataManager.swift`
4,258, `HistoryView.swift` 3,535, `PremiumSet.swift` 104, `LocalizationTests.swift` 1,286,
`PremiumAccessTests.swift` 377, `PremiumSetTests.swift` 58 — 112 rows for 112 files, every count equal to
`wc -l` (by script); the catalogue 231 keys; #182–#186 are new. `docs/STATE.md` (*`recap(of:)`*),
`docs/DESIGN.md` (*The recap, measured*), `docs/ROADMAP.md` (1.4.7's note), `CLAUDE.md`, `tasks/lessons.md`
and `HISTORY.md` with it. `docs/WIDGET.md`: nothing in its subject moved. **Line citations**: this step's
insertions in `DataManager.swift` begin after line 1191 and in `HistoryView.swift` after line 231; citations
other passes made below those lines are dated notes, which name the line as it stood.

**Last updated:** 2026-10-24 (eighty-eighth pass — `/doc_sync` run by the owner straight after the
eighty-seventh; no code changed since step 4's gate). The eighty-seventh's script run again, each figure
printed and equal: 108 `.swift` files and 108 rows, every count equal to `wc -l`
(`WaterBuddyWatchWidgetBundle.swift` 9 = 9 by hand); 908 phone `@Test` in 102 suites — the four new
suites 31, 7, 7 and 20, as *Files on disk* says — 70 watch, 61 UI `func test`; 13 keys, `Key.all`
thirteen; three six-file exception sets; 18 rules cited, 18 files; the confined imports; 226 catalogue
keys; no forbidden doc. **New this pass: every line citation into `DataManager.swift` past line 216 and
`HistoryView.swift` past line 52 — where step 4's insertions begin — printed beside the text it lands on**,
in `CLAUDE.md` and the five sheets, and every `File.swift:N` naming the other four files step 4 changed.
**Drift found, one:** `docs/STATE.md`'s code block under *Who may write on behalf of the group* still
cited `role` at `:1924`, `HEAD`'s line, where it stands at `:1996` — re-pointed, its old number kept.
*The process role* here was right (`:1996`, `:2005`); the eighty-seventh pass's sentence below checked
the guard lines and not that declaration. Every other hit is current and lands on what it names, or sits
in a dated note: known issue #84's `WaterBuddyApp.swift` "two destinations" comment, last noted at
`:129–130`, is at `:157` and still stale, as that note says. `docs/WIDGET.md`, `docs/DESIGN.md`,
`docs/ROADMAP.md` (no header, as before) and `CLAUDE.md`: nothing moved. `tasks/lessons.md`: one entry.
Gate: not run by this pass; the last is step 4's (*Targets*).

**Last updated:** 2026-10-24 (eighty-seventh pass — `/doc_sync` run by the owner on set A's step 4's
staged tree; no code changed since its gate). The command's checks, by one read-only script printing
what it read: 108 `.swift` files in the seven target folders, tracked or staged, and 108 *Files on disk*
rows, every count equal to `wc -l` (`WaterBuddyWatchWidgetBundle.swift` 9 = 9, its row ending at the
number, as before); 908 phone `@Test`, 70 watch, 61 UI `func test`, as *Targets* states them; 13 keys on
`DataManager.Key`; the three exception sets six files each, as `CLAUDE.md` names them; 18 rules cited and
18 rule files; `StoreKit` imported in `HomeView.swift` and `PremiumStore.swift` alone, `FoundationModels`
in `InsightWriter.swift` alone, no `SwiftData` under `WaterBuddyWidget/`; 226 keys in the app's catalogue;
no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`; every guard-site citation in *The
process role* and its twin in `docs/STATE.md` landing on the guard it names, and History's `servings[1]`
at `:419`; the replaced surface's own words — *Personal AI insights*, *Using Apple Intelligence*,
`LockedMonth`, *Week · Month* — only in dated blocks, a known issue's history and the roadmap's item name.
**Drift found, two:** `CLAUDE.md`'s *Architecture* list named Premium and `StoreKit`'s two files and
nothing of Insights or `FoundationModels` — a bullet added; and `docs/DESIGN.md`'s *Insights, measured*
did not say the switch's third segment was unmeasured — its *Not measured* gains it, and the sheet a
block. `docs/STATE.md`, `docs/WIDGET.md` and `docs/ROADMAP.md`: read, nothing in their subjects moved
since the records. `tasks/lessons.md`: one entry. Gate: not run by this pass; the last is step 4's, on
its final code, earlier the same night (*Targets*).

**Last updated:** 2026-10-24, early morning (set A's step 4's own records, after its walk, its review and
its gate — not a `/doc_sync` pass). HEAD `5b511bd`, nothing committed in the session. *Current state*
gains step 4's block above step 3's; *Targets*' three test rows (908 `@Test` in 102 suites, 61 UI
`func test` at the start of a line, 70 watch — each printed); *Files on disk*: four new rows
(`InsightCopy.swift` 113, `InsightWriter.swift` 270, `InsightCopyTests.swift` 365,
`WeekInsightsTests.swift` 482) and eight changed ones by `wc -l` — `DataManager.swift` 4,195,
`HistoryView.swift` 3,428, `PremiumSet.swift` 103, `RootTabView.swift` 565, `WaterBuddyApp.swift` 197,
`LocalizationTests.swift` 1,280, `PremiumSetTests.swift` 57, `PremiumUITests.swift` 160 — and the
catalogue's (226 keys, by script); #164 and #176 gain notes; #177–#181 are new. `docs/STATE.md`
(*`insights`*), `docs/DESIGN.md` (*Insights, measured*), `docs/ROADMAP.md` (1.4.12's note), `CLAUDE.md`
(nine guard sites; the warning trail), `tasks/lessons.md` and `HISTORY.md` with it. `docs/WIDGET.md`:
nothing in its subject moved. **Line citations**: this step's insertions in `DataManager.swift` begin
after line 216 and in `HistoryView.swift` after line 52; the citations other passes made into either
are dated notes, which name the line as it stood.

**Last updated:** 2026-10-23, late evening (eighty-sixth pass — `/doc_sync` run by the owner on set A's
step 3's staged tree; no code changed since its gate). The command's checks, by script files in the
session's scratchpad: 104 `.swift` files in the seven target folders, tracked and on disk, and 104 *Files
on disk* rows, every count equal to `wc -l` (`WaterBuddyWatchWidgetBundle.swift` 9 = 9, its row ending at
the number); 842 phone `@Test`, 70 watch, 60 UI `func test`, as *Targets* states them; 13 keys on
`DataManager.Key`; the three exception sets six files each, as `CLAUDE.md` names them; 18 rules cited and
18 rule files; `StoreKit` imported in `HomeView.swift` and `PremiumStore.swift` alone; 197 keys in the app's
catalogue; no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`; the bare-citation sweep for
`HistoryView.swift` past 232 and `DataManager.swift` past 2,632 — no current-text pointer left on an old
line. **Drift found, two:** `docs/STATE.md` and `docs/DESIGN.md` still headed themselves with step 2's
passes though step 3's records had added a section to each — both gain a block. `docs/WIDGET.md` and
`docs/ROADMAP.md` (which keeps no such header) read, nothing in their subjects moved; `CLAUDE.md` read
against the code, current. `tasks/lessons.md`: one entry. Gate: not run by this pass; the last is step 3's,
on its final code, earlier the same evening (*Targets*).

**Last updated:** 2026-10-23, evening (set A's step 3's own records, after its walk, its review and its
gate — not a `/doc_sync` pass). HEAD `24b2de4`, 172 commits, nothing committed in the session; step 2
was committed before it began (`9fcdc48`, `40e7e41`, `95c343d`, `24b2de4`). *Current state* gains step
3's block above step 2's; *Targets*' three test rows (842 `@Test` in 98 suites; 60 UI `func test`; 70
watch, each by the attribute grep); six *Files on disk* rows by `wc -l` — `MonthPatternsTests.swift`
new, `DataManager.swift`, `HistoryView.swift`, `HistoryViewTests.swift`, `LocalizationTests.swift`,
`MonthHistoryTests.swift` — and the catalogue's row (197 keys, counted by script); 104 `.swift` files
in the seven target folders, tracked and on disk; #171–#176 are new. `docs/STATE.md` (*`month.patterns`*),
`docs/DESIGN.md` (*The patterns, measured*), `docs/ROADMAP.md` (1.4.6's note), `CLAUDE.md` (the warning
trail), `tasks/lessons.md` (four) and `HISTORY.md` with it. `docs/WIDGET.md`: nothing in its subject
moved. **Line citations**, by the bare-citation sweep the lesson of 2026-10-23 asks for (each `` `:N` ``
attributed to the last file named before it), over this file, `docs/STATE.md`, `docs/DESIGN.md` and
`CLAUDE.md`, for `HistoryView.swift` past line 232 and `DataManager.swift` past 2,632, where this step's
insertions begin: the one current-text pointer, History's literal `servings[1]`, re-pointed `:363` →
`:397` here and in `docs/STATE.md`, its old numbers kept; every other hit sits in a dated note or a known
issue's history, which names the line as it stood. The process role's guard sites are all above 2,632
and did not move.

**Last updated:** 2026-10-23 (eighty-fifth pass — `/doc_sync` run by the owner on set A's step 2's
staged tree; no code changed since its gate). The command's checks, by script, `comm` over sorted
lists: 103 `.swift` files in the seven target folders, tracked and on disk, and 103 *Files on disk*
rows, every count equal to `wc -l`; 815 phone `@Test` in 97 suites, 70 watch, 60 UI `func test`, as
*Targets* states them; 13 keys on `DataManager.Key`; the three exception sets six files each, as
`CLAUDE.md` names them; 18 rules cited and 18 rule files; `StoreKit` imported in `HomeView.swift` and
`PremiumStore.swift` alone; no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`.
**Drift found, three:** *The process role*'s seven guard-site lines, bare `` `:N` ``, still read
`HEAD` `2e2f3a7`'s (41 to 137 short) — re-derived by each guard's words, the eighth site added
(`republishMonth()`, `:1182`), and `docs/STATE.md`'s twin with them; `CLAUDE.md`'s "seven sites",
now eight; and `CLAUDE.md`'s *Targets* row for `WaterBuddyUITests`, which had not named
`PremiumUITests` since `d5cf816`. #103 gains (h). `tasks/lessons.md`: one entry. `docs/WIDGET.md`,
`docs/DESIGN.md`, `docs/ROADMAP.md`: read, nothing in their subjects moved since Task 10. Gate: not
run by this pass; the last is step 2's, on its final code, 2026-10-23 (*Targets*, and its *Current
state* block).

**Last updated:** 2026-10-23 (set A's step 2's own Task 10, after its walk, its review and its gate —
not a `/doc_sync` pass). HEAD `2e2f3a7`, 168 commits, nothing committed in the session. *Current state*
gains step 2's block above the eighty-fourth's; *Targets*' three test rows (815 `@Test`, 60 UI
`func test`, 70 watch) and seven *Files on disk* rows by `wc -l` — `MonthHistoryTests.swift` new,
`DataManager.swift`, `HistoryView.swift`, `PaywallView.swift`, `HistoryViewTests.swift`,
`LocalizationTests.swift`, `PremiumUITests.swift` — and the catalogue's row (187 keys, counted by script);
#159 and #166 gain notes; #167–#170 are new; *Git*. **Line citations:** every `File.swift:N` into the
files step 2 grew was read against the tree — `DataManager.swift` +360 lines, `HistoryView.swift` +862 —
and the three in current text re-pointed (`HistoryView.swift:363`, `DataManager.swift:1924` and
`:1933`, each with its old number); the ones inside dated notes and known issues' history name the
line as it stood when written, superseded rather than rewritten. Searched every sheet for "seven
days", "the week only", "History reaches" and "Month": none claims History stops at the week.

**Last updated:** 2026-10-22 (eighty-fourth pass — `/doc_sync` run by the owner once set A's step 2 was
designed, drawn on the canvas, specified and planned; no code of it). HEAD `a6e287b`, 166 commits,
level with `origin/main`: step 1 was committed after the eighty-third pass (`4577d92`, `d5cf816`,
`fd12b7f`, `a6e287b`). The command's checks, by `comm` over sorted lists: 102 tracked `.swift` files in
the seven target folders, 102 *Files on disk* rows, every count equal to `wc -l`; 768 phone `@Test`, 70
watch, 58 UI `func test`; 13 keys on `DataManager.Key`; the three exception sets six files each, as
`CLAUDE.md` names them; 18 rules cited and 18 rule files; `StoreKit` imported in `HomeView.swift` and
`PremiumStore.swift` alone; no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`.
**Drift found:** the sheets' newest notes still read step 1 as staged at `HEAD` `b981374` — superseded
by dated notes, never rewritten. Changed: this block; *Current state* gains step 2's block; #50 a note;
*Git*. `docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md`: dated notes, nothing in their subjects
moved. `docs/ROADMAP.md`: 1.4.1's and 1.4.2's notes. `CLAUDE.md`: read against the code, current.
`tasks/lessons.md`: two entries. Gate: not run.

**Last updated:** 2026-10-22 (eighty-third pass — `/doc_sync` run by the owner straight after the
eighty-second). The command's checks, by script: 102 `.swift` files in the seven target folders, every
one with a *Files on disk* row whose count equals `wc -l` (101 matched by the row pattern,
`WaterBuddyWatchWidgetBundle.swift` 9 = 9 by hand); 768 phone `@Test`, 70 watch, 58 `func test`, the
same wherever the docs state a current figure; 13 keys on `DataManager.Key`, as `docs/STATE.md` says;
the three exception sets as `CLAUDE.md` names them; every `rule nn-name` cited resolves; `StoreKit`
imported in `HomeView.swift` and `PremiumStore.swift` alone. **One drift, fixed:** *Targets*' watch-test
row still cited its 2026-10-20 run; it now cites step 1's gate. The other four docs and `CLAUDE.md`
were read against the code and are current; `.claude/` was not touched.

**Last updated:** 2026-10-22 (eighty-second pass — step 1's own Task 10, after its Tasks 8 and 9: the
walk, its fixes, the colour pairs measured and the owner's four rulings on them, the gate, the
warnings). HEAD `b981374`, nothing committed. *Current state* gains Task 8–10's block above the
eighty-first's; *Targets*' two phone test rows and seven *Files on disk* rows are re-counted by
`wc -l` and the attribute grep (768 `@Test`; 58 `func test`, unchanged); #163 is retired (the scheme is
cleaned and staged); #164 (the *Apple Intelligence* wording), #165 (the paywall measured on 27.0
alone) and #166 (`PremiumUITests`' first runs on 26.5) are new.

**Last updated:** 2026-10-22 (eighty-first pass — `/doc_sync` run by the owner in the session that
built set A's step 1 through its Task 7, before Task 8, the owner's walk). HEAD `b981374`, nothing
committed. The command's checks: 105 tracked or staged `.swift` files against *Files on disk* by one
`join` — two new without a row (`PremiumRim.swift`, `PremiumSetTests.swift`), nine counts stale
(`PaywallView.swift` 358 → 607, `PremiumAccess.swift` 195 → 304, `PremiumSet.swift` 20 → 99,
`PremiumStore.swift` 331 → 376, `SettingsView.swift` 888 → 957, `LocalizationTests.swift` 1111 → 1138,
`PremiumAccessTests.swift` 216 → 358, `PremiumStoreTests.swift` 437 → 581, `PremiumUITests.swift`
64 → 71), `WaterBuddyWatchWidgetBundle.swift` 9 = 9 by hand, every other count equal to `wc -l`; 764
`@Test`, 70 on the watch, 58 UI `func test`; `project.pbxproj` last changed in `eba1b1e`, its three
exception sets six files each as `CLAUDE.md` gives them; 13 keys on `DataManager.Key` (11 phone, 2
watch); every cited rule resolves (`comm`); no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or
`dependencies.md`. **Drift found:** the app catalogue's row read 110 keys — 167 now, counted by
script. Changed: this block; *Targets*' two test rows; *Files on disk* — two new rows, nine counts,
one note, the `.storekit` paragraph, the catalogue row; *Current state* gains step 1's block; #139,
#155, #157 and #159 gain notes, #161 is retired, #162 and #163 are new; *Git*. `docs/STATE.md`,
`docs/WIDGET.md`, `docs/DESIGN.md`: dated notes, no key or shared token moved. `docs/ROADMAP.md`:
1.4.1's note. `CLAUDE.md`: the warning trail. `tasks/lessons.md`: five entries. Gate: the phone unit
suite and `PremiumUITests` in this session, the rest not run — *Current state* gives both.

**Last updated:** 2026-10-21 (eightieth pass — `/doc_sync` run by the owner in the session that built
roadmap item 1.4.1's Task 6, gated it, and then redirected Premium to a designed set A; after step
1's spec and plan were approved). HEAD `b981374`: Tasks 0–5 committed (`e7b7f38`), their doc sync
(`3d577bb`) and the rule wording (`b981374`). The command's checks: 103 tracked or staged `.swift`
files — two new without a row until this pass (`PaywallView.swift`, `PremiumUITests.swift`), five
rows stale (`PremiumStore.swift` 325 → 331, `SettingsView.swift` 818 → 888, `WaterBuddyApp.swift`
178 → 190, `PremiumAccessTests.swift` 185 → 216, `PremiumStoreTests.swift` 415 → 437), every other
count equal to `wc -l` by one `join` pipeline (the first form, a script made executable, was refused
by the deny list — `tasks/lessons.md`); 734 `@Test`, 70 on the watch, 58 UI `func test`;
`project.pbxproj` last changed in `eba1b1e`, its three exception sets six files each as `CLAUDE.md`
gives them; 13 keys on `DataManager.Key` (11 phone, 2 watch); every cited rule resolves; no
`docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`. Changed: this block; *Targets*' two
test rows; *Files on disk* — two new rows, five counts, three notes on unchanged counts; *Current
state* gains the redirection's block; #50, #140, #155, #157 and #159 gain notes, and #160 and #161
are new; *Git*. `docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md`: dated notes, no key or token
moved. `docs/ROADMAP.md`: the owner's rulings of the day. `CLAUDE.md`: the warning trail.
`tasks/lessons.md`: six entries. Gate: run in this session, 19:09–21:18, on the code as it stands —
*Current state* gives it.

**Last updated:** 2026-10-21 (seventy-ninth pass — `/doc_sync` run by the owner in the session that
began roadmap item 1.4.1, Premium's foundation, at its pause before Task 6). HEAD `0be24f9`: 1.3.2 is
committed whole (7c `5194121`, its doc sync `0be24f9`). 1.4.1's Tasks 0–5 are built and staged; it
waits for the privacy policy's URL (#159). The command's checks: 101 tracked `.swift` files, each
with its row, every count equal to `wc -l` (100 by script, `WaterBuddyWatchWidgetBundle.swift`'s by
hand) — five new rows, one count moved (`LocalizationTests.swift`, 1061 → 1111); 729 `@Test` (the
attribute grep), 70 on the watch, 56 UI `func test`; `project.pbxproj` last changed in `eba1b1e`, its
three exception sets six files each as `CLAUDE.md` gives them; 13 keys on `DataManager.Key` (11
phone, 2 watch) — 1.4.1 adds none; every cited rule resolves; no `docs/ARCHITECTURE.md`,
`CAPABILITIES.md` or `dependencies.md`. Changed here: this block; *Targets*' test row (729); *Files on
disk* — three app rows, two test rows, the localization row, and a line for
`WaterBuddyTests/WaterBuddy.storekit`; *Current state* gains 1.4.1's block and marks 7c's history;
known issues #155–#159 are new; *Git* gains this pass's block. `docs/ROADMAP.md`: 7c's commits under
1.3.2 — missed until now — and 1.4.1 begun. `docs/STATE.md`: no key moved; two dated notes — the paid
state is stored nowhere, and Apple is told nothing new. `docs/WIDGET.md` and `docs/DESIGN.md`: checked
and left — 1.4.1 has touched no file under `WaterBuddyWidget/` and none of the six shared files yet,
and draws no colour pair yet. `CLAUDE.md`: the warning trail gains the baseline read before 1.4.1's
code; its *Architecture* bullet *Premium is read, never stored* is the spec's §5 wording, typed with
the rules and true of the code on disk. `tasks/lessons.md`: three entries. Gate: the phone unit suite
only, this session — `✔ Test run with 729 tests in 91 suites passed`, one skipped by design; the rest
not run (Task 8).

**Last updated:** 2026-10-21 (seventy-eighth pass — `/doc_sync` run by the owner in the session that
built roadmap item 1.3.2's stage 7c, after its records and before its `/commit`). HEAD `3d1cda8`; 7c
staged. The command's checks: 96 tracked `.swift` files, each with its row, every row's count equal
to `wc -l` by script — none stale; 683 `@Test`, 70 on the watch, 56 UI `func test`; `project.pbxproj`
last changed in `eba1b1e`, its three exception sets six files each as `CLAUDE.md` gives them; 13 keys
on `DataManager.Key` (11 phone, 2 watch); the watch widget's catalogue 5 keys, as its row gives;
every cited rule resolves; no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`.
Changed here: this block and *Git*. `CLAUDE.md`: the target table's watch widget row names the three
faces — the sentence 7c's records left for this pass — the warning trail gains 7c, and the line on
placing widgets by hand names the three faces and a watch face with slots. `docs/STATE.md`: no key
moved; two dated notes under *The language* — the faces read the mirror's language and format with
its locale, which 7c's records missed. `docs/DESIGN.md`: no token changed; a block giving
`Aurora.blue` against a full-colour face's black, 6.21:1, computed from the token. `docs/WIDGET.md`,
`docs/ROADMAP.md`, the spec and the plan: written by 7c's records in this session, read again, left.
`tasks/lessons.md`: one entry. Gate: not re-run — no code moved; 7c's ran in this session on its
staged copy, and *Current state* gives it.

**Last updated:** 2026-10-21 (roadmap item 1.3.2's stage 7c, written by the session that built it —
not a `/doc_sync` pass). HEAD `3d1cda8`. 7c is staged: *Current state* gains its block; four rows in
*Files on disk* change or join — 96 tracked `.swift` files with `WristFaceView.swift` — and the watch
widget catalogue's row; the *Targets* row for the watch widget and the never-placed line under
*Current state* gain dated notes; 683 `@Test`, 70 on the watch, 56 UI `func test`, all unchanged;
#50, #140 and #151 gain notes, and #153 and #154 are new; *Git* gains this session's block.
`CLAUDE.md` is left for `/doc_sync`: its target table still describes the watch widget as the
circular ring alone.

**Last updated:** 2026-10-20 (seventy-seventh pass — `/doc_sync` run by the owner in the session that
built roadmap item 1.3.2's stage 7b, after its records and before its `/commit`). HEAD `ca43a60`; 7b
staged. The command's checks: 95 tracked `.swift` files, each with its row, every row's count equal
to `wc -l` by script — **two were stale**, `WristView.swift` (495 → 498) and
`WristVesselLayoutTests.swift` (116 → 120), left by the final review's fix, the second also still
describing the disc as before it; 683 `@Test`, 70 on the watch, 56 UI `func test`; `project.pbxproj`
last changed in `eba1b1e`, its three exception sets six files each as `CLAUDE.md` gives them; 13 keys
on `DataManager.Key` (11 phone, 2 watch); every cited rule resolves; no `docs/ARCHITECTURE.md`,
`CAPABILITIES.md` or `dependencies.md`. Line citations into 7b's files re-read by their words: three
current sentences still named the watch's `primaryIndex` — *Targets*, #136 and `docs/STATE.md` —
and gain dated notes; #100(b) and #103's carry their own. #50 gains a note: Xcode, opened on the
project during this pass, rewrote five files unstaged. Changed: this block; two rows; three notes;
#50; *Git*. `CLAUDE.md`: the warning trail gains 7b. `docs/STATE.md`: its *Last updated* and the
note. `docs/WIDGET.md`: checked and left — 7b changes none of the phone widget's six files, and the
watch face's provider does not read `WristPlan.Face` until 7c. `docs/DESIGN.md`: its scrim levels and
ceilings recomputed, the 40 mm vessel's floor checked off a render — left. `tasks/lessons.md`: one
entry. Gate: run in this session, on 7b's staged copy — the block below and *Current state* give it.

**Last updated:** 2026-10-20 (roadmap item 1.3.2's stage 7b, written by the session that built it —
not a `/doc_sync` pass). HEAD `ca43a60`. 7b is staged: *Current state* gains its block; ten rows in
*Files on disk* change or join — 95 tracked `.swift` files with `WristColumn.swift` — and the watch
catalogue's row; 683 `@Test`, 70 on the watch; #44 is retired; #20, #45, #84, #104 and #151 gain
notes and #152 is new; *Git* gains this session's block. A `/doc_sync` after the owner's `/commit`
re-checks the rest.

**Last updated:** 2026-10-20 (seventy-sixth pass — `/doc_sync` run by the owner in the session that
built roadmap item 1.3.2's stage 7a, after its records and before its `/commit`). HEAD `ff7305b`; 7a
staged. The command's checks: 94 tracked `.swift` files, each with its row, every row's count equal
to `wc -l` (93 by script, `WaterBuddyWatchWidgetBundle.swift`'s by hand); 677 `@Test`, 58 on the
watch, 56 UI `func test`; `project.pbxproj` last changed in `eba1b1e`, its three exception sets six
files each as `CLAUDE.md` gives them; 13 keys on `DataManager.Key` (11 phone, 2 watch); every cited
rule resolves; no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`. Changed: this
block; *Targets*' two test rows, the phone's found still at 1.2.5's 616; *Git*. `CLAUDE.md`: the
warning trail gains 7a. `docs/WIDGET.md`: a dated block — a shared file changed, the contract did
not. `docs/STATE.md`: checked and left, no key moved. `docs/DESIGN.md` and `docs/ROADMAP.md` were
written by 7a's records in this session and read again. Gate: run in this session, on 7a's staged
copy — the block below and *Current state* give it.

**Last updated:** 2026-10-20 (roadmap item 1.3.2's stage 7a, written by the session that built it —
not a `/doc_sync` pass). HEAD `ff7305b`. 7a is staged: *Current state* gains its block; four rows in
*Files on disk* change or join — 94 tracked `.swift` files with `WristGlassTests.swift`; 677 `@Test`,
58 on the watch; #91(b) is retired, #77 gains a note and #151 is new; *Git* gains this session's
block. A `/doc_sync` after the owner's `/commit` re-checks the rest.

**Last updated:** 2026-10-20 (seventy-fifth pass — `/doc_sync` run by the owner in the session that
opened roadmap item 1.3.2, during its plan's preconditions, before any of its code). HEAD `06229be`:
1.3.1 is committed whole — 6c as `fb1af96`, its doc sync as `cdc53da`, the ten rule files' wording as
`06229be` — so the block below it in *Current state* is history. 1.3.2's spec and plan are written and
approved, and untracked until this pass stages them. The command's checks: 93 tracked `.swift` files
(90 in the seven target folders, 3 in `Tools/`), each with its row, no source file changed since the
seventy-fourth pass; 677 `@Test`, 57 on the watch, 56 UI `func test`; `project.pbxproj` last changed
in `eba1b1e`, its three exception sets six files each as `CLAUDE.md` gives them; 13 keys on
`DataManager.Key` (11 phone, 2 watch — `prefix` and `all` are not keys); every cited rule resolves; no
`docs/ARCHITECTURE.md`, `CAPABILITIES.md` or `dependencies.md`. Changed: this block; *Current state*
gains 1.3.2's block and 6c's its commits; #77 and #90 gain notes; *Git* gains this pass's block.
`docs/ROADMAP.md`: 1.3.1 committed, 1.3.2 begun. The redesign spec's status line gains a dated note.
`CLAUDE.md`: the warning trail gains this session's measurement of `HEAD`. `docs/STATE.md`,
`docs/WIDGET.md` and `docs/DESIGN.md` were checked and left — no key, widget contract or token moved.
Gate: not run in this pass; the one clean build it read is in `HISTORY.md`.

**Last updated:** 2026-10-20 (seventy-fourth pass — `/doc_sync` after roadmap item 1.3.1's stage 6c,
run by the owner in the session that built it, before its `/commit`). HEAD `4c796a9`: 6b and its doc
sync were committed (`ed77d9f`, `4c796a9`); 6c is staged, its records written by the build itself —
*Current state*'s block, the rows, #149 and #150, notes on #76 and #140, `HISTORY.md`. The command's
checks: 93 tracked and staged `.swift` files, 93 rows, every count compared with the staged file by
one script — none stale (its pattern misses `WaterBuddyWatchWidgetBundle.swift`'s row, which ends at
its count, 9 = 9, read by hand); 677 `@Test`, 57 on the watch, 56 UI `func test`; `project.pbxproj`
last changed in `eba1b1e`, its three exception sets as `CLAUDE.md` gives them; 13 `static let`s on
`DataManager.Key`, 11 on the phone and 2 on the watch — `CLAUDE.md` and `docs/STATE.md` moved to
eleven this pass; 18 rule names cited, 18 files; no `docs/ARCHITECTURE.md`, `CAPABILITIES.md` or
`dependencies.md`. Changed: this block; *Targets*' widget row (three configurations); *The process
role*'s nine `DataManager.swift` lines and `ProcessRoleTests`' line, re-derived by their words —
stale since stage 5; #50's note (D1 done, the tree clean of Xcode's rewrite); an *Opened by* line
for #149 and #150. `CLAUDE.md`: the target table, the storage table's eleven keys and the
extension's read of the rows, the warning trail with 6c, the week in the snapshot bullet and a
bullet of its own, and the week widget among the things placed by hand. `docs/STATE.md`: the
guard sites' lines and `role`'s, the key counts. Gate: not re-run for this pass — 6c's two gates,
this session, are in `HISTORY.md`.

**Last updated:** 2026-10-19 (seventy-third pass — `/doc_sync` after roadmap item 1.3.1's stages 6a
and 6b, run by the owner in the session that built 6b, before its `/commit`). HEAD `5a46609`: 1.3.4
and its records were committed at 23:40 on 2026-10-18 (`4a7ece7`..`41309e3`), and 1.3.1's spec and
plan (`1899aba`) and stage 6a (`5a46609`) at 20:22 today, with nothing in `docs/`; 6b is staged.
The command's checks: 91 tracked `.swift` files, 91 rows, every count compared with the staged file
by one script — one stale, `WaterBuddyWidget.swift`, 618 → 756 (659 after 6a);
654 `@Test`, 57 on the watch, 56 UI `func test`, unchanged; `project.pbxproj` last changed in
`eba1b1e`; the three exception sets as `CLAUDE.md` gives them; 12 `static let`s on `DataManager.Key`,
10 on the phone and 2 on the watch, as `CLAUDE.md` and `docs/STATE.md` say — the staged rule
`10-architecture` already says 11, its approved wording being 6c's; 18 rule names cited, 18 files.
Changed: this block; *Current state* gains 1.3.1's block, and 1.3.4's its commits; the row; #50 and
#140 gain notes; **#148 opened** (what only a device shows of StandBy). `docs/WIDGET.md`: the
button's two forms, the bare layout and the quiet form, and a dated note where *The two rendering
modes* said stage 6 was not built and filed StandBy under templated. `docs/DESIGN.md`: the primary
surface's fourth place, and dated notes in the density and elevation lists and on the backdrop's
StandBy sentence. `docs/ROADMAP.md`: 1.3.1's status, 1.3.4's commits, the ten rule files 1.3.1's
wording touches. `CLAUDE.md`: the warning baseline's trail gains 1.3.1 and how the lines are now
counted; the device checks name StandBy. `docs/STATE.md` checked and left: no key or stored byte
moved. Found and left for the code: `WaterBuddyWidget.swift:498`'s comment still says the bordered
capsule would draw "over the glass pane" — a doc sync does not edit a source file. Gate: not re-run
for this pass — 6b's runs, this session, are in `HISTORY.md`.

**Last updated:** 2026-10-18 (seventy-second pass — `/doc_sync` after roadmap item 1.3.4, Siri's
*Today's Water*, in the session that built it). **Nothing was committed:** HEAD `88d694f`, where 1.2.8
and its records were committed at 20:33 (`eecb6a7`..`88d694f`); 1.3.4 is staged, its records written
by the build itself (*Current state*, #145–#147, notes on #63 and #140, `HISTORY.md`). The command's
checks: 91 tracked `.swift` files, 91 rows, each row's count equal to its file's lines by one script;
654 `@Test` (638 before), 57 on the watch, 56 UI `func test`; `project.pbxproj` last changed in
`eba1b1e`, nothing staged in it; the three exception sets as `CLAUDE.md` gives them; 12
`static let`s on `DataManager.Key`, no key added; 18 rule names cited, 18 files. Changed: this
block; the 1.2.8 block in *Current state* and its roadmap entry gain their commits; #50 gains a
note — the open Xcode rewrote three catalogues again by 23:34, unstaged, the staged copies intact.
`CLAUDE.md`: the warning baseline's trail gains 1.3.4, measured this session; the snapshot bullet
names Siri's question as its second reader. `docs/STATE.md`: a `Last updated` and a note on the
`currentWater` row — a new reader, no new writer. `docs/WIDGET.md`: a `Last updated` for the note the
build added. `docs/DESIGN.md` was checked and left: no token moved. Gate: not re-run for this pass —
the build's own runs are in `HISTORY.md`.

**Last updated:** 2026-10-18 (seventy-first pass — `/doc_sync` after known issue #144's fix, in the
session that made it). **Nothing was committed:** HEAD `93d23df`; 1.2.8 and the fix staged together,
as the owner chose — #144 fixed inside the change before `/commit`. Two files' DocC and the capture
script changed: `Tools/CaptureScreenshots.sh` now reads the clock once at the top, refuses a run
outside 1:45–11:45 PM before the boot and the build, and freezes the time it checked;
`AppStoreScreenshotUITests.swift` and `WaterBuddyApp.swift` changed only in `///` lines. The
command's checks: 89 tracked `.swift` files, the two rows that moved re-counted
(`AppStoreScreenshotUITests.swift` 714 → 717, `WaterBuddyApp.swift` 176 → 178) and every row compared
with its file by script; 638 `@Test`, 57 on the watch, 56 UI `func test` — unchanged;
`project.pbxproj` last changed in `eba1b1e`; no key added; every `` rule `nn-name` `` resolves.
Changed: this block; *Current state*'s 1.2.8 entry gains a dated note; three rows; **#144 retired**.
`docs/STATE.md` gains a dated note — its test-isolation paragraph named `WelcomeUITests` as the one
UI suite on the fresh start, and since 1.2.8 the store capture is the second. The plan gains a note
on its step 2. `docs/WIDGET.md`, `docs/DESIGN.md` and `CLAUDE.md` were checked and left: the gate
line's window is the harness's and still true, and no key, token or widget contract moved. Gate: a
`build-for-testing` only, this session; the five invocations were not run (`HISTORY.md`).

**Last updated:** 2026-10-18 (seventieth pass — `/doc_sync` run by the owner again, straight after
the sixty-ninth, on the same tree). **No source or test file changed and nothing was committed:**
HEAD `93d23df`, 1.2.8 and its records staged. The checks re-run and unchanged: 89 rows equal to their
files, 638 `@Test`, 57 on the watch, 56 UI, `project.pbxproj` at `eba1b1e`, every rule name
resolving. With nothing new to sync, two fresh readers read the staged text — one against the code
and git, one against this session's logs and the earlier session's transcript — and each finding was
checked at its source. Taken: *Current state* said five earlier days were "over the goal" (two are
exactly at it — met); the wheel's failure was written as observed ("turned through 3 PM") where the
log shows only the request and the read-back — now said to be inferred, here, in #142 and in the
plan; #142's retirement note said the entry "implied" the failed order, which came from this
session's proposal, and its older text dates the approval 2026-10-18 where the transcript gives
23:59 on 2026-10-17; `CLAUDE.md`'s gate line said the method writes into `Screenshots/`, which the
script does, and now names the window; the stage-5 record's "No other UI test passes it" gains a
note; the plan's `--time` "takes only `HH:mm`" (`2:53` was accepted), its typing date, the watch
shot as the design's assumption rather than the owner's answer, `tapSpacing`'s DocC, and its first
capture finishing in the background. **#144 opened**: four sentences in 1.2.8's own harness, script
and `WaterBuddyApp`'s DocC that overstate, which a sync may not edit. Not taken: the harness's row
still opening with "both deliberately non-idempotent" — the row's notes are dated in front of it, as
every row's are. `HISTORY.md`'s two checkpoints and `tasks/lessons.md`'s entry are superseded in new
ones, with a lesson.

**Last updated:** 2026-10-18 (sixty-ninth pass — `/doc_sync` run straight after roadmap item 1.2.8's
records, in the session that built it). **Nothing was committed:** HEAD is `93d23df` — the lag fix
and the sixty-eighth pass were committed at 13:50–13:51 (`b1bbbc3`, `90eb5e4`, `258a67d`, `93d23df`),
which that pass, written before, could not say. 1.2.8 is staged: the store method of
`AppStoreScreenshotUITests` rewritten to start clean and build a lived-in week through History's
sheet, `Tools/CaptureScreenshots.sh` reworked, the four iPhone PNGs retaken, rule `85-testing`'s
approved wording. The gate passed on the working tree — 638 unit, UI on iOS 27.0 and 26.5 (38 with 1
skipped, and 31, on each), 57 on the watch, both widgets built. The command's checks: 89 tracked
`.swift` files, the one row that moved re-counted (`AppStoreScreenshotUITests.swift`, 559 → 714);
638 `@Test`, 57 on the watch, 56 UI `func test` — unchanged, the store method still one test;
`project.pbxproj` last changed in `eba1b1e`; no key added; every `` rule `nn-name` `` resolves.
Changed: *Current state* opens on 1.2.8 and dates the lag fix's commits; #142 retired; #45, #82 and
#88 gain dated notes; three rows (the harness, the capture script, the iPhone set); `CLAUDE.md`'s
gate line 2 now says what rule `85-testing` says — the store method starts clean, the census does
not; `docs/ROADMAP.md`'s 1.2.8 entry. `docs/STATE.md`, `docs/WIDGET.md` and `docs/DESIGN.md` were
checked and left: they say nothing of the store set, and no key, token or widget contract moved.

**Last updated:** 2026-10-18 (sixty-eighth pass — `/doc_sync` run by the owner again, straight after
the sixty-seventh, on the same tree). **No source or test file changed and nothing was committed:**
HEAD `9999979`, 16 paths staged. The checks re-run and unchanged: 89 rows equal to their files, 638
`@Test`, 57 on the watch, 56 UI. With nothing new to sync, two fresh readers read the staged text —
one against the code and git, one against this session's logs — and found 24; each was checked
against its source. Taken: #99 said "unstaged" — staged since 11:09; the block below says "built
test-first and unstaged", which was true when it was written and is kept as written. "An earlier
date" for `addLog` is "a date on another day" in `docs/STATE.md` and the streaks spec, and
`updateLog` forgets the run when a serving was *or becomes* another day's. "Pins both halves" and
"every path that must recount does" overstated the tests — #143 lists what they do not reach,
with two code comments a sync may not edit. `WaterMotionTests` is 7 `@Test` and 8 cases. The welcome
after the fix is 0.176 s per 5 s, the source of "3.5 %". The aurora's "about 2 %" was never a
switch-off: History and Settings, which carry it, idled at 2.1 % and 2.6 % — a ceiling, now called
one. #140's load range, run counts and evidence are restated from the `uptime` readings and the
logs, with what survives only in the session's output said so. The waters spec's table now follows
its logs run by run, the streaks spec gives five runs for a goal change, and the plan says A and B
were staged in one `git add`. Not taken: one reader's "the per-size after-figures are unsupported" —
`pourprobe-after.log` gives 1.4 ms at 45 days and 1.7 at 500, a refresh 0.4 and 0.6, exactly. A
lesson was added. `HISTORY.md`'s checkpoint gives the superseded figures.

**Last updated:** 2026-10-18 (sixty-seventh pass — `/doc_sync` run by the owner straight after the
lag fix's records, in the session that built it). **No source or test file changed for this pass,
and nothing was committed:** HEAD is `9999979`, the lag fix's 13 paths staged. The command's checks:
- 89 tracked `.swift` files — the two new ones staged — each row's count equal to its file's lines,
  all 89 by one script;
- 638 `@Test`, 57 on the watch, 56 UI `func test`, as the records give them;
- the shared-file contract — `project.pbxproj` last changed in `eba1b1e`, 2026-10-09;
- twelve keys on `DataManager.Key`, ten in the phone's suite — the fix added none;
- every `` rule `nn-name` `` resolves — 18 names, 18 files; `docs/ARCHITECTURE.md`,
  `docs/CAPABILITIES.md` and `docs/dependencies.md` still do not exist.

Drift found and fixed, four: *Current state* opened on 1.2.6 as staged — it was committed on
2026-10-17 (`5bc7a0a`, `419868a`, `2451143`, `9999979`), and *Current state* now opens on the lag fix;
`docs/STATE.md` still described `readStreak()` walking its windows on every read; `docs/DESIGN.md`'s
older water sentence gave the slosh a 5-second window; `docs/ROADMAP.md` gave 1.2.6 no commits and
1.2.8 no word of its parking. `CLAUDE.md`'s warning baseline gains the lag fix's measurement — the
29 unique lines on both sides, from this session's clean builds of the tree and of a `HEAD` export.

**Last updated:** 2026-10-18 (the lag fix's records, written by the session that built it — not a
`/doc_sync` pass). The owner reported lag on their iPhone, Debug build from Xcode, on Home, History,
Settings and the welcome, worse over time. Two changes, built test-first and unstaged, HEAD still
`9999979`: **A** — the water moves for 2.5 s after a pour and then rests (`WaterMotion`, new, app
only; `HomeView`, `WelcomeView`); **B** — the run of days before today is kept and counted again only
when one of them changes (`DataManager.closedRun`). Known issue #99 retired; #140–#142 opened. File
rows: four changed, two new — 89 `.swift` files once the two are added. 638 `@Test` (622 + 7 + 9),
57 on the watch, 56 UI `func test`. The gate passed, the iOS 26.5 UI target on its second, quiet
run (#140); no new warning on the app, watch or watch-widget schemes against clean builds of
`HEAD`. Roadmap item 1.2.8 is parked (#142). *Current state*, `docs/STATE.md` and `docs/WIDGET.md`
were not edited — neither change moves stored shape or the widget contract; a `/doc_sync` pass is
the place to read them against the change.

**Last updated:** 2026-10-17, night (sixty-sixth pass — `/doc_sync` run by the owner straight after
roadmap item 1.2.6's records, in the session that built it). **No source or test file has changed
since those records, nothing was built or run for this pass, and nothing was committed:** HEAD is
`52ee815`. The command's checks:
- 87 tracked `.swift` files, each row's count equal to its file's lines — all 87 by one script this
  time, `WaterBuddyWatchWidgetBundle.swift`'s row, which ends at its count, included;
- 622 `@Test`, 57 on the watch, 56 UI `func test` — the figures *Current state* gives;
- 18 exception-set entries — `project.pbxproj` last changed in `eba1b1e`, on 2026-10-09;
- every `` rule `nn-name` `` resolves, the watch and test folders searched as well;
- twelve keys on `DataManager.Key`, ten in the phone's suite — 1.2.6 added none.

One find: `CLAUDE.md`'s warning baseline listed its re-measurements up to 1.2.5, and now gives
1.2.6's — the 29 unique lines again, on the staged tree, against a clean build of `HEAD`. The block
below says `CLAUDE.md` was read and nothing in it made false; that stands, as the line was true, only
short by one measurement. Read and already accurate: *Current state*'s 1.2.6 block; the 16 file rows'
and five catalogue rows' notes; known issues #39, #40, #41, #109(g) and #139; the 1.2.6 notes in
`docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md` and `docs/ROADMAP.md`, whose *Last updated* are
already 2026-10-17. No doc names a surface 1.2.6 replaced — `String(format:)` over a resolved key,
`onlyTheSpokenHomeStringTakesARawNumber`, `syncedCaption`, `attribution` and `spokenFigures` without
a locale — except as history. `HISTORY.md`'s checkpoint gives the staging.

**Last updated:** 2026-10-17, afternoon (roadmap item 1.2.6's records, written by the session that
built it — not a `/doc_sync` pass). 1.2.6 is built, gated and staged, not committed; HEAD is still
`52ee815`. What moved: *Current state* opens on 1.2.6; known issues #39 and #40 are retired, #139 is
opened, and #41, #50, #100(b), #103(f) and #109(g) gain dated notes; the file table's 16 changed
`.swift` rows carry dated notes — 13 with new counts, each checked against `wc -l`, three whose counts
did not move — and the five catalogue rows dated notes; 622
`@Test`, 57 on the watch, 56 UI `func test`. `docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md` and
`docs/ROADMAP.md` each gain a dated note; `CLAUDE.md` was read and nothing in it is made false.

**Last updated:** 2026-10-17 (sixty-fifth pass — `/doc_sync` run by the owner the morning after the
sixty-fourth, on the same tree). **No source or test file has changed since the sixty-third pass,
nothing was built or run, and nothing was committed between the two passes:** HEAD is `52ee815`,
with the sixty-fourth pass's five files staged and the same six unstaged. The command's checks,
re-run:
- 87 tracked `.swift` files, each row's count equal to its file's lines — 86 rows by the same
  script, and `WaterBuddyWatchWidgetBundle.swift`'s, which its pattern misses, by hand;
- 616 `@Test`, 57 on the watch, 54 UI `func test`;
- 18 exception-set entries — `project.pbxproj` last changed in `eba1b1e`, on 2026-10-09;
- every `` rule `nn-name` `` resolves;
- twelve keys on `DataManager.Key`, ten in the phone's suite.

With nothing new to sync, this pass checked what the sixty-fourth had written. Two fresh readers read
its staged text against the code, git and the probes' output, and found 26 — 7 and 19; their reports
are in the session's scratchpad (`readers/docsync-65-reader-a.md`, `-b.md`). Each was checked
against its source and taken:
- **This file.** The *Git* block of 12:34 calls the blocks under it 1.2.5's staging; they are 1.2.4's,
  at `6010e25`, and 1.2.5's staging was read only in `HISTORY.md`. That block is kept as written, and
  the one above it says so. #50's note said the spec edits the watch catalogue; the change would.
  *Current state* said the spec's first red test would show what the simulator does; only its tests
  passing once the forms exist can. *Files on disk* gains a note: the "staged" notes of stage 5 and
  1.2.5 name commits now.
- **`docs/ROADMAP.md`.** 1.2.6's note said the change "closes #39", though nothing is built, and
  named "one new helper"; §8's note now gives the commits of 1.2.2's and 1.2.3's rule wording
  (`1438122`, `6010e25`) as well as 1.2.4's and 1.2.5's.
- **The spec.** See `HISTORY.md`'s checkpoint. It is corrected in place, and its *Provenance* says so.
- **`tasks/lessons.md` and `HISTORY.md`** are append-only: their errors are corrected in a new entry.

A third fresh reader then read this pass's own edits and found 8, 1 error and 7 doubts
(`readers/docsync-65-reader-c.md`); each was checked against its source and taken, and `HISTORY.md`
lists them.

The paragraph below is the sixty-fourth pass's, as it was written. Its "§8's lists" lacks "note",
and its finds name the rule wording of 1.2.4 and 1.2.5, not of 1.2.2 and 1.2.3.
`docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md` and `CLAUDE.md` describe nothing that changed
and keep their *Last updated*.

**Last updated:** 2026-10-16 (sixty-fourth pass — `/doc_sync` run by the owner straight after roadmap
item 1.2.6's spec was written and staged, in the session that wrote it). **No source or test file
has changed since the sixty-third pass, and nothing was built or run for this one;** the gate
*Current state* reports is still 1.2.5's, from 2026-10-15. Between the two passes the owner committed
1.2.5 — `5241030`, `86a44ed`, `314d63a`, `52ee815` — so what the sixty-third pass and the block it
describes call staged is committed. The command's checks:
- 87 tracked `.swift` files, each with a row here whose count equals its file's lines, by a script
  (84 in the seven target folders, three in `Tools/`);
- 616 `@Test`, 57 on the watch, 54 UI `func test`;
- the three exception sets in `project.pbxproj` unchanged since `314d63a`, 18 entries;
- every `` rule `nn-name` `` resolves;
- twelve keys on `DataManager.Key`, ten in the phone's suite.

Its finds: *Current state* opened on 1.2.5 as staged at `450d76f`, with its rule wording "typed in and
unstaged" — a new block above it gives the four commits and 1.2.6's spec; in `docs/ROADMAP.md`, the
notes on 1.2.4 and 1.2.5 still said "awaiting `/commit`", §2 still called stage 5 (1.2.3) staged, and
§8 called 1.2.4's and 1.2.5's rule wording unstaged — dated notes give their commits, and §8's lists
the three rule files 1.2.6 needs; #39, #40 and
#50 gain notes for the spec, which closes the first two if built and asks the owner about the third
(its D7). `docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md` and `CLAUDE.md` describe nothing that
changed and keep their *Last updated*. The paragraph below is the sixty-third pass's, as it was
written.

**Last updated:** 2026-10-16 (sixty-third pass — `/doc_sync` run by the owner straight after roadmap
item 1.2.5 was built, gated and staged, on that staged tree). **No source or test file changed in this
pass, and nothing was built or run for it;** the gate *Current state* reports ran on 2026-10-15, in
the session that built 1.2.5. The command's checks:
- 87 tracked `.swift` files, each with a row here whose count equals its file's lines (84 in the seven
  target folders, three in `Tools/`);
- 616 `@Test`, 57 on the watch, 54 UI `func test`;
- the three exception sets in `project.pbxproj` unchanged, 18 entries;
- every `` rule `nn-name` `` resolves;
- twelve keys on `DataManager.Key`, ten in the phone's suite, as `CLAUDE.md` and `docs/STATE.md` say.

Its finds, each a place the change made incomplete rather than wrong:
- `docs/DESIGN.md`'s *The goal-reached burst* did not say the burst's length now times the rating
  request (`ReviewPrompt.pause`) — a dated note;
- `docs/STATE.md`'s *What Apple is told* asks, for any added key, whether it brings a required-reason
  category, and nothing had answered it for `reviewRequestedVersion` — answered (none);
- #120(a), on a page kept through its slide, gains the rating request's case.

`docs/WIDGET.md` describes nothing 1.2.5 changed and keeps its *Last updated*. The paragraph below is
the sixty-second pass's, as it was written.

**Last updated:** 2026-10-15 (sixty-second pass — roadmap item 1.2.5's records, written by the
session that built it; not a `/doc_sync`). *Current state* opens with the rating request's block;
*Targets* counts 616 `@Test` in 77 suites (the attribute grep), and *What this is* the phone's
suite at ten keys; *Files on disk* has two new rows and five re-counted (87 tracked `.swift` files
with the two staged); fourteen cited line numbers, on twelve lines, name their code's line now
(the block says which were moved and which re-pointed); known issues #137 (the device check) and
#138 (the final review's deferred minors) are new; #29 gains the re-measurement. The gate and the warning comparison
were run in that session, after its fix pass.

The paragraph below is the sixty-first pass's, as it was written.

**Last updated:** 2026-10-15 (sixty-first pass — `/doc_sync` run by the owner straight after roadmap
item 1.2.4 was built, gated and staged, on that staged tree). **No source or test file changed in this
pass, and nothing was built or run for it;** the gate *Current state* reports ran earlier the same day,
in the session that built 1.2.4. The command's checks:
- 85 tracked `.swift` files (84 at HEAD, plus `ReminderResponder.swift`), each with a row here whose
  count equals its file's lines;
- 604 `@Test`, 57 on the watch, 54 UI `func test`;
- the three exception sets in `project.pbxproj` unchanged;
- every `` rule `nn-name` `` resolves;
- `docs/STATE.md`'s 11 key rows match `DataManager.Key`.

Its finds:
- known issue #3, *The reminder has no action button*, retired — 1.2.4 is its fix;
- #29 gains the 2026-10-15 re-measurement (29 shipping lines);
- the vessels note in Settings and the welcome names three doors that log the Glass and not the
  reminder's button — opened as #136 for the owner to word;
- `docs/STATE.md`'s `servings` row now names the button among those doors;
- this file's *Last updated*, and `docs/STATE.md`'s and `docs/WIDGET.md`'s, had not moved for 1.2.4's
  records.

The paragraph below is the sixtieth pass's, as it was written.

**Last updated:** 2026-10-14, night (sixtieth pass — `/doc_sync` run by the owner again, straight
after the fifty-ninth, on the same staged tree). **No source or test file changed and nothing was
built or run.** Every check the command lists held again — 84 `.swift` files, each named here and
each row's count equal to `wc -l`; 593 `@Test`, 57 on the watch, 54 UI `func test`;
`project.pbxproj` untouched by the stage; every `` rule `nn-name` `` resolves. Its finds were
**lists of what uses something the welcome now uses too**, which searches for the old screen and
the stage's subjects had passed over: in `docs/DESIGN.md`, *What moves* (no row for the welcome's
slide), the held-slider row, the first run's hand-over (seen on `GoalSetupView`), *Selection*,
*The look, measured*'s *First run* rows, `.glassGroup()` in two places and *The header and a
screen arriving*; in `docs/STATE.md`, "the setup slider". Two fresh readers of the pass
(`docsync-60-reader-e.md`, `-f.md`, in the stage's ledger folder) then found more of the same
kind: `innerCornerRadius`'s users, the clear glass variant's, Reduce Motion's readers and the
glass-pane counts in `docs/DESIGN.md`; the figures grouped by the locale in `docs/STATE.md`; and
here #40's single-form Russian keys, #121's departures from the rules, #95's screens on the aurora
and #59's system wheels — dated notes on each. They also found this paragraph's first form
claiming those sections had never been opened, when stage 5's own records had edited *Motion* and
named the first run. `HISTORY.md`'s checkpoint lists them all. The paragraph below is the
fifty-ninth pass's, as it was written.

Previously — 2026-10-14, night (fifty-ninth pass — `/doc_sync` run by the owner straight after
stage 5 was staged, in the session that built it). **No source or test file changed, and nothing
was built or run in this pass**; its figures are recounts of the tree and re-counts of the stage's
saved build logs. Every check the command lists held: 84 `.swift` files, each named here and each
row's count matching `wc -l`; 593 `@Test`, 57 on the watch, 54 UI `func test`, as the targets table
says; eleven keys on `DataManager.Key`, nine in the phone's suite; the three exception sets as
`CLAUDE.md` lists them; every `` rule `nn-name` `` resolves. Drift found and fixed: #14 now says
all five places that build a `DataManager` for a preview pass the reminder hook, and that stage 5's
typed rule wording corrects the rule; `CLAUDE.md`'s warning baseline, 31, was re-counted from the
stage's clean builds of HEAD and the index and stands, which *Current state*'s gate bullet now says
beside the stage's own 32; and `docs/STATE.md`'s *Tests that pin this* has the three of stage 5's
six new suites that pin stored state. **Then two fresh readers read the pass and the stage's
corrections** (`docsync-59-reader-c.md`, `-d.md`, saved in the stage's ledger folder) and found
more, all checked and taken — `HISTORY.md`'s checkpoint for this pass lists them: among them #89,
which the stage's own render had answered; the tightest contrast pair, which is Settings' Cup glyph
(3.10) in the stage's own table; the claim that every staged file matched the gate's export, true
of the code and not of the records; the rule's three previews, said as two; and `docs/WIDGET.md`'s
75 keys. The paragraph below is the stage's own.

Previously — 2026-10-14, evening — **the redesign's stage 5, the welcome, is built, gated and
staged, not committed**; written by the session that built it, not a `/doc_sync` pass. HEAD
`1438122`, level with `origin/main` (stage 4 committed and pushed on 2026-10-14). The first block
of *Current state* has it; #100(d) is fixed on disk with its device walk still to do, and #130–#132
are opened. The tree in the index now: 84 `.swift` files (seven added, `GoalSetupView.swift`
deleted), each with its row in *Files on disk*; 593 `@Test`, 57 on the watch, 54 UI `func test`;
eleven keys (none added — the DEBUG fresh start uses a suite of its own); three exception sets
(no shared file added). Two fresh readers then read these records before they were staged
(`reader-a.md`, `reader-b.md` in the stage's ledger folder); every finding was checked and taken,
and `HISTORY.md`'s stage checkpoint lists the ones that mattered most — among them three moved
citations in *The process role*, the catalogue's count (103 keys) and the tightest figures; the
notes on #82, #89, #103(m) and #111 came from them too. The paragraph below is the fifty-eighth
pass's, as it was written.

Previously — 2026-10-14, morning (fifty-eighth pass — `/doc_sync` run by the owner straight
after stage 4 was staged, in the session that built it). **No source or test file changed, and
nothing was built or run in this pass**; its figures are recounts of the tree and re-reads of the
stage's saved build logs. The tree: 78 `.swift` files, each with its row in *Files on disk* and
every count there matching `wc -l`; 557 `@Test`, 57 on the watch, 41 UI `func test`, as the
targets table says; eleven keys; three exception sets, as `CLAUDE.md` lists them. Here: #39 has
Settings' half — the stage grouped the amounts and left the entry as it was; #126 is retired, its
commit having landed (`c9d1f6b`); #121 and #129 have notes; *Files on disk*'s note says what stage
3c and the App Store header were committed as. Elsewhere: `docs/STATE.md`'s list of figures that do
not group still named History's and Settings'; `docs/WIDGET.md`, `docs/STATE.md` and
`docs/DESIGN.md` had their *Last updated* on stage 3c; `docs/ROADMAP.md` called the App Store header
uncommitted, left #129 off its device-check sweep and stage 4's rule changes off its §8;
`CLAUDE.md`'s 31 warning lines were re-counted from the stage's clean builds of HEAD and the index
and stand. One lesson. Two fresh readers then read the pass (`docsync-58-reader-a.md`, `-b.md` in
the stage's ledger folder); every finding was checked, and all but two were taken —
`HISTORY.md`'s checkpoint lists them and the two. The paragraph below is the stage's own.

Previously — 2026-10-14, just after midnight — **the redesign's stage 4, Settings, is built,
gated and staged, not committed**; written by the session that built it, not a `/doc_sync` pass.
HEAD `c9d1f6b`, level with `origin/main` (stage 3c committed and pushed on 2026-10-13). The first
block of *Current state* has it; #108 retired, #84 and #111 noted, #129 opened. The tree now: 78
`.swift` files (none added); 557 `@Test`, 57 on the watch, 41 UI `func test`; eleven keys; three
exception sets. The paragraph below is the fifty-seventh pass's, as it was written.

Previously — 2026-10-13, afternoon (fifty-seventh pass — `/doc_sync` run by the owner
straight after stage 3c was staged, in the session that built it). **No source or test file
changed, and nothing was built or run in this pass**; its figures are recounts of the tree and
re-reads of the stage's saved build logs. The tree at the start: 78 `.swift` files, each named
here; 556 `@Test`, 57 on the watch, 39 UI `func test`; eleven keys; three exception sets — the
targets table still gave 547 and 33 `GoalSetupUITests`. Here: *Files on disk* has the eight rows
the stage changed re-counted and two new rows — the App Store header and its HTML; the targets
table's two test rows have stage 3c's counts; the fifty-sixth pass's *Current state* block is
marked superseded, and *Git* is re-read; nine cited lines the stage moved are given where they
are now — #82, #104, #111, #117, and #103's new (l), which lists them; *Where the rest is written
down* names `docs/ROADMAP.md`. Elsewhere: `docs/DESIGN.md`'s token sections said the glass as it
was before the stage and say it as it is now, and its older sections that gave pre-stage figures
as current say they are not; `docs/STATE.md` has one citation moved; `docs/WIDGET.md` says no
contract changed and gives the warning comparison; `CLAUDE.md`'s 31 warning lines were
re-counted from the logs and stand. One lesson. **Two fresh readers then read this pass**
(`docsync-57-reader-a.md`, `-b.md` in the stage's ledger folder): eleven findings and nine, every
one checked against the code or the logs and taken — among them four of the nine moved citations,
this *Git* section, and nine in `docs/DESIGN.md`. The paragraph below is the
stage's own.

Previously — 2026-10-13, afternoon — **the redesign's stage 3c (the look) is built, gated and
staged, not committed**; written by the session that built it, not a `/doc_sync` pass. HEAD
`684f3dd`; stage 3 and 3b were committed and pushed that morning. The first block of *Current
state* has it; known issues #85 and #95 amended, #123 to #127 opened. The paragraph below is the
fifty-sixth pass's, as it was written.

Previously — 2026-10-13 (fifty-sixth pass — `/doc_sync` run by the owner after `/commit`
had put its plan to them, by the same session. **Nothing is committed; the plan waits for the
owner's word.** HEAD is `e16221e`, stage 3 in the index and stage 3b unstaged, as before, and
no source or test file has changed since 13:42:47 on the 12th. **What is new is a gate
result: before its plan, `/commit` gated the staged tree by itself**, from an export of the
index, because the gate of the 12th had run on stage 3 and stage 3b together. 479 unit tests
in 60 suites; `GoalSetupUITests`' 25 and the other classes' 18 on iOS 27.0 and on 26.5; 57
watch tests; both widget builds. **One chunk of it ended `** TEST FAILED **`:** on iOS 27.0
the runner of `testAnUndoOfferExpires` was killed — the result bundle, read that night and
gone from DerivedData since, said "Test crashed with signal term" — and the test passed when
run alone. What killed it is not known: **#122, opened.** Not run: iOS
18.6. The results are at the head of *Current state*. Clean at the start of this pass: 78
`.swift` files, each named here; 547 `@Test`, 57 on the watch, 38 UI `func test`; eleven
keys; three exception sets. `docs/DESIGN.md`, `docs/STATE.md`, `docs/WIDGET.md` and
`CLAUDE.md` were not edited. **One fresh reader checked this record against the logs**
(`docsync-56-reader-g.md`): every result, count, device and time matched, and six things in
the wording are answered in it — among them that #122 no longer offers the simulator's boot
as what set the killed chunk apart, since `xcodebuild` booted it for four later runs that
passed. The answers were read by no reader. **Still true:** nothing has run on a device.)

<details>
<summary>Fifty-fifth pass — 2026-10-12, retained</summary>

**Last updated:** 2026-10-12 (fifty-fifth pass — `/doc_sync` run by the owner a third time,
after the fifty-fourth, by the same session. **No source or test file changed and nothing was
built or run**: HEAD is `e16221e`, stage 3 in the index and stage 3b unstaged, as before.
Clean at the start: 78 `.swift` files, each named here; 547 `@Test`, 57 on the watch, 38 UI
`func test`; eleven keys; three exception sets; four schemes. **One fresh reader went over
the round the header below says no reader had read**, and over that header and its
checkpoint as wholes (`docsync-55-reader-e.md`, saved as it arrived). Of reader D's eight,
seven fixes were right and one carried a pointer a row off. **Nine findings, none touching a
figure from the code, the gate, the pixels, the review or git.**
- **Two are in this file.** In the header below, which is kept as written: its last fixes
  were not applied "mostly by taking words out" — against the old words, six of the eight
  were longer — and its sentence that they "were checked against their files by this
  session" was saved before that pass's last edits to other documents. So was "after its
  last edit" under *Git*, which is kept there as that pass's block.
- **Four are in `HISTORY.md`'s checkpoint of that pass and one in a lesson of it**; today's
  checkpoint and a new lesson supersede them.
- **Fixed where they stood:** History's bars are simply there under Reduce Motion, which
  *Current state* and #120 (e) now say; and the note withdrawing a pixel share in #119 said
  it had stood "for an hour", where it was under forty minutes. `docs/DESIGN.md` carries
  both, and a pointer that was a row off; the second pass's spec and plan carry the first.

Known issues: **#119 and #120 amended; none opened, none retired.** **The gate was not run
in this pass**; its figures below are the second pass's. **Still true:** nothing has run on a
device. **A last reader read this header, today's checkpoint and lesson and this pass's
edits** (`docsync-55-reader-f.md`, saved as it arrived): none of reader E's nine left
unanswered, and six things of its own in the new words, each answered in the text above, in
the checkpoint or in the document it named. Those edits, this sentence and the git block
were read by no reader.)

</details>

<details>
<summary>Fifty-fourth pass — 2026-10-12, retained</summary>

**Last updated:** 2026-10-12 (fifty-fourth pass — `/doc_sync` run by the owner straight after
the fifty-third, by the same session. **No source or test file changed, nothing was built or
run, nothing was staged and nothing is committed**: HEAD is `e16221e`, stage 3 in the index
and stage 3b, in both its builds, unstaged, as before. The mechanical checks were clean at the
start — 78 `.swift` files, each named here; 547 `@Test`, 57 on the watch, 38 UI `func test`;
eleven keys; three six-file exception sets. **The fifty-third pass's text went to two fresh
readers, which its own header said it had not: fifteen findings, fourteen theirs and one this
pass's own, each read again against the code, the gate's logs or the saved reports before a
word was changed.** Their reports are saved as they arrived, beside the ledger. **Four were
things the closing report had told the owner:**
- **"Pixel for pixel" on iOS 27.0 was a tolerance, and the bar is not quite the `TabView`'s.**
  The measure is "no pixel of the bottom 700 differs by more than 24 levels **in grey**".
  Taken finer: in the bar's own 83 pt, up to 11 levels in grey and 26 in blue; in the content
  above it, 2 and 4 — which is also all that two captures of one build differ by (#119).
- **"A page that slides in is whole" had an exception the code states.** Its sections are;
  History's bars start at nothing on every page and grow, unless Reduce Motion is on.
- **"No run was retried" left out a comparison made twice** — the clean build of the app
  scheme and the widget build behind the warnings row. No test run was repeated.
- **"About 3.8:1" was never read.** The reviewer read two frames: 3.6–4.0:1 with the week
  card mostly out, and 5.9–6.9:1 — over the floor — with a card about a third out. 3.8 is
  the middle of the first range. Three of the records, and a DocC, also put it on the card
  a third out, which is the second reading's.

**A third reader then read this pass's own corrections and found eight things in them**, two
that mattered: the first version of the last bullet said the reviewer had taken one reading
and that nobody had read a card a third out; and the builds' times and actions were given
wrongly for the widget. All eight are applied, each against the file it comes from
(`docsync-54-reader-c.md`). **A fourth, narrower reader then read those fixes**
(`docsync-54-reader-d.md`): the two that mattered stand, and it found eight smaller things —
a share of differing pixels that meant nothing, one "slides in whole" left behind, Reduce
Motion missing from the sentence about History's bars, and five of wording. Those are
applied too, mostly by taking words out, and **were checked against their files by this
session and by no further reader**.

**The rest:** the app-only list said thirteen files and is nineteen; "the 63 above" is 75;
the kept first-build block's rise, stagger and *Undo* scale are not the tree's and nothing
said so; one citation was two lines off (#103 (k)); `docs/DESIGN.md` still had no switch for
Reduce Motion, four readers of it where there are three, and "the other two scripts" where
there are four; the second pass's spec said no call site spells a curve, against sixteen
that do and its own §7; its plan's *As built* missed four differences; and the first build's
spec and plan did not say the second pass had replaced their container. **Ten comments in
source and tests that are false, or name a mechanism that is gone — nine of them the second
pass's doing — are listed in #117**; a doc sync edits none.
Known issues: **#103, #117, #119, #120 and #121 amended; none opened, none retired.**
`docs/STATE.md`, `docs/WIDGET.md` and `CLAUDE.md` were read and needed nothing. **The gate
was not run in this pass**: its figures below are the fifty-third's, and both readers checked
them against the logs, which are newer than the newest source file. **Still true:** nothing
has run on a device.)

</details>

<details>
<summary>Fifty-third pass — 2026-10-12, retained</summary>

**Last updated:** 2026-10-12 (fifty-third pass — the records of **stage 3b's second pass**, by
the session that built it. **It is finished, tested and unstaged, on top of stage 3b's first
build; stage 3 is still staged; nothing is committed.** HEAD is `e16221e`. **How it came
about:** the owner built the first build to their iPhone (iOS 27.0) and said there was no
animation in a change of page and that it did not look premium — "It just appears." They chose
a slide by direction and all four groups of micro-interactions. **What it is:** `RootTabView`
is one pager on every system — one backdrop, two pages at most (`PageTurn`), a bar in the
bottom inset; Apple's `TabView` is gone and its bar stays as a standalone `UITabBar`
(`SystemTabBar`); a page is rebuilt each time it is shown; `Motion` names the curves; a drop
from the disc to the vessel, a marker that glides, a tick that draws itself, sections that
shrink as they scroll off (`PourDrop`, `ScrollDepth`). **No key added** — eleven — and no
shared, widget or watch file touched. **78 `.swift` files, 75 in targets; 547 `@Test`
functions in 68 suites; 57 on the watch; 38 UI `func test`, 51 executed a system.** The gate
ran on the final source, all five invocations, the UI class in chunks on iOS 27.0, 26.5 and
18.6, **no run retried**; no new warning against a clean build of the index. **A fresh
reviewer read the pass's diff**: two important findings, both acted on — the scroll effect
faded text still on screen, and its figures were not the final tree's. **Reduce Motion was run
for the first time in this project**, switched on through the simulator's own Settings app.
**For the owner:** on iOS 26.x the bar's glass is darker than a `TabView`'s (#119); the scroll
effect does not fade, where they chose "fade and shrink"; a tap on the tab already shown no
longer scrolls to the top (#120). Known issues: **#114 retired; #82, #84, #103, #104, #106,
#111, #112, #115, #116, #117 and #118 amended; #119 to #121 opened.** Every line citation
into the six app files the pass moved was re-derived. `docs/DESIGN.md` gains *Motion* and its
tab-bar and arrival sections are brought up to date; `docs/STATE.md` has one citation moved;
`docs/WIDGET.md` and `CLAUDE.md` were checked and needed nothing. **This pass's own text was
not given to a fresh reader.**)

</details>

<details>
<summary>Fifty-second pass — 2026-10-12, retained</summary>

**Last updated:** 2026-10-12 (fifty-second pass — `/doc_sync` run by the owner straight after
the fifty-first, by the same session. **No source or test file changed, nothing was built or
run, nothing is staged and nothing is committed**: HEAD is `e16221e`, stage 3 staged and stage
3b unstaged, as before. The mechanical checks were clean at the start — 70 `.swift` files and
every row's line count, 500 `@Test` in 64 suites, 57 on the watch, 37 UI `func test`, eleven
keys, the three exception sets, every rule citation, no source file newer than the docs — so
this pass did what the fifty-first said it had not: **two fresh readers were given the stage 3b
text**, one this file's and one `docs/DESIGN.md`'s with `CLAUDE.md`, and each finding was
checked against the code before a word changed. **Nine findings and three smaller remarks, none
serious, all acted on.** What was wrong: **(1) the fifty-first pass re-derived no line
citation** after a stage that moves lines in six app files — fourteen citations in this file
and one in `docs/STATE.md`, to twelve places in the code, pointed at the wrong line; this
pass's own script found them, and #103 gains (i), where each stands now. **(2) The capture
harness's `returnToTop` rests on the container stage 3b replaced**: on iOS 26 and later a kept
screen is not rebuilt at its top — by reading only, the harness is not run by the gate (#82,
#114, #117). **(3) "The code contradicts two rules" was an undercount by the letter**: two of
the stage's haptics are triggered by a view's own state where two rules ask for a counter, and
the spec proposed no wording for it (#111, and a dated note in the spec's §8). **(4) Smaller:**
`PressStyle` is not stage 2's (#115); `ScreenMetricsTests` holds Home's and History's numbers,
not three screens'; #106 did not say that #114 changes it; `docs/DESIGN.md` has four sentences
corrected, each marked where it stands; and `docs/STATE.md` one count that had been one short
since stage 3 — 204 `@Test` in its seventeen suites. What the readers checked and found right
— every count, constant, test name and git listing they could reach — is listed in their
reports, saved as they arrived beside the stage's ledger. **Not checkable from the tree and
not re-checked by anyone**: by the readers' own tallies about 55 statements in this file's
stage 3b text and about 90 in `docs/DESIGN.md`'s and `CLAUDE.md` — gate results, contrast and
pixel figures, readings off recordings. `CLAUDE.md` and `docs/WIDGET.md` were read and needed
nothing. Known issues: none opened and none retired; **#82, #84, #103, #104, #106, #111, #114,
#115 and #117 amended**. **The gate was not run in this pass**; every result below is the
fifty-first's.)

</details>

<details>
<summary>Fifty-first pass — 2026-10-12, retained</summary>

**Last updated:** 2026-10-12 (fifty-first pass — `/doc_sync` at the end of the redesign's stage
3b, navigation and motion, by the session that built it. **Stage 3b is finished, tested and
unstaged; stage 3 is still staged; nothing is committed.** HEAD is `e16221e`. **How it came
about:** the owner, shown stage 3's History, said the title stood in a different place on Home
and History, that the change of page looked poor, and that the bar should be iOS's own glass bar
with its drag; shown the built screens beside the canvas with seven differences marked, they
said "go". **What it is:** one header on every tab (`ScreenHeader`); Apple's `TabView` bar on
iOS 26 and later and the app's own below, behind the codebase's third version check; a shade
under Apple's bar, because its selected caption read 3.79–4.46:1 on iOS 26.5 without one; every
screen's content settling in under a title that holds still (`Arrival`); every backdrop on one
clock (`AuroraDrift`); and two haptics more, `select` and `remove`. **No key added** — eleven —
and no shared file, widget or watch file touched. **70 `.swift` files, 67 in targets; 500
`@Test` functions in 64 suites; 57 on the watch; 37 UI `func test`, 50 executed a system.** The
gate ran on the final source: all five invocations, the UI class in chunks on iOS 27.0, 26.5 and
18.6; no new warning against a clean build of the index. **Two chunks failed on a first run and
passed on a second**, one on a busy Mac and one for a cause not established (#115). **A fresh
reviewer read the stage's diff**: four important findings, all acted on — and two of the seven
things it declined to judge were rendered and found to be defects: the backdrop changing at
every change of tab, and on iOS 26.5 the screen being left standing empty for a quarter of a
second. **The rule wording is in the stage's spec and in no rule file**, so the code contradicts
two rules as they stand (#111). Known issue **#110 updated; #111 to #118 opened.**
`docs/DESIGN.md` gains *Apple's tab bar, measured* and *The header and a screen arriving*, and
its sections on the aurora and the haptics are brought up to date; `docs/STATE.md` and
`docs/WIDGET.md` were read and needed nothing — no stored shape and no widget contract moved;
`CLAUDE.md` gains one clause in its target table, **unstaged**. **This pass's own text was not
given to a fresh reader**, as the fiftieth's was.)

</details>

<details>
<summary>Fiftieth pass — 2026-10-11, retained</summary>

**Last updated:** 2026-10-11 (fiftieth pass — `/doc_sync` at the end of the redesign's stage 3,
History, by the session that built it. **Stage 3 is finished, tested and staged; nothing is
committed.** HEAD is `e16221e`, 96 commits: **stage 2 was committed in between** — `1ced514`,
`e7406a5`, `6b5f319`, `e16221e` — which the forty-ninth pass's text and *Git* block predate; both
are brought up to date here. **What stage 3 is:** History as one list — the header, the week
card (cyan for a day that reached the goal, white for one that did not; *Average*, *Best day*,
*Goal met*), a new strip of the day's servings by time of day, and the servings as lighter rows
that name their vessel — and three vessel shortcuts in the serving sheet. Behind it, on
`DataManager`: `reached(_:)`, `daysMet(in:goal:)`, `dayFraction(of:)` and `hours(_:onDayOf:)`.
**No key added** — eleven, as before. **66 `.swift` files, 63 in targets; 479 `@Test` functions
in 60 suites; 57 on the watch; 30 UI `func test`, 43 executed.** The gate ran on the staged
source — the unit target five times of five after known issue #92's race failed it twice in
three, the UI suite on iOS 27.0, 26.5 and 18.6 as two invocations a system. **A fresh reviewer
read the staged diff**: nothing critical; two test gaps closed, and one thing it had graded
minor on an estimate was rendered and found real — a past day's heading cut at the largest text
sizes, which one of the stage's own captures had shown for an hour unread. **Two fresh readers
then checked this pass's own text** against the logs and the code: every contrast figure, gate
result and source line citation they checked held, and their twenty-six findings — two of them
only steps not yet taken — were in the prose: among them where the strip's contrast was
sampled, why iOS 18.6's sweep did not scroll, three counts of runs, and that the stage "did not
carry" a flag it had carried all afternoon. Each was opened and corrected; their reports are saved beside the
stage's ledger. Known issues **#62 and #92 retired**; #39, #82, #83, #85, #90, #94, #95, #101, #103, #104
and #105 updated; **#107 to #110 opened.** Rule wording for two rule files is written and **unstaged**,
for the owner. `docs/DESIGN.md` gains History's measured table; `docs/STATE.md` and
`docs/WIDGET.md` gain a dated note each; `CLAUDE.md` was read and needed nothing.)

</details>

<details>
<summary>Forty-ninth pass — 2026-10-11, retained</summary>

**Last updated:** 2026-10-11 (forty-ninth pass — a fourth `/doc_sync` the same day. **No source or
test file changed, nothing was built or run, and nothing is committed**: HEAD is `b8a1386`, stage 2
staged as before. The tree and the mechanical checks were clean at the start, so this pass checked
**only what the forty-eighth had written**: the previous staging's copies of the seven docs were
recovered from git and diffed against the index, and four fresh readers were given the diffs and
the primary evidence. **The forty-eighth pass's text was not clean.** Wrong in this file: "every
development unit run of the stage named the stock *iPhone 17*" — those of 10 October did, and the
11th's went to the stage's own simulators; "Increase Contrast … no control operated" — its probe
taps four discs; the warning row's unit — 17 of the app's 38 lines are macro expansions that keep
their position, and by one unit throughout the figure is 31; and that header's own "every count …
and table cell they checked was right; what was wrong was prose", in a pass whose diff corrects a
count and several table rows. Tightened: the largest phone's runs; the spec section for the
capsule's words (§5.1); `shutdown all` on six lines of the plan, not in six steps; where the two
readings of the disk and the 12:21 come from. **The unit tests are hosted in the app**, so each
run's launch stamps the simulator's group container — #90's note and `docs/STATE.md` had said
otherwise. Six stale copies of statements `CLAUDE.md` no longer makes — in the storage table and
non-negotiables 1, 3, 4 and 7 — are fixed. **#103 gains part (g)**: thirteen more stale source
comments and six rule lines, among them the comment in `saveDailyGoal` that the forty-eighth pass
had copied into `docs/STATE.md` as fact. #104, #105 and #106 each gain a note. **Counts,
re-derived:** 66 `.swift` files, 63 in targets and 3 in `Tools/`, every row's line count
matching; 444 `@Test` on the phone, 57 on the watch, 25 UI `func test`; eleven keys, nine the
phone's; three exception sets of six. **The gate was not run in this pass.** `docs/STATE.md`,
`docs/DESIGN.md` and `docs/WIDGET.md` corrected, each header saying what; `CLAUDE.md` tightened
in two phrases, **unstaged**. Every reader's report of the last three passes, and the stage
reviewer's, is now saved to a file beside the scratch evidence.)

</details>

<details>
<summary>Forty-eighth pass — 2026-10-11, retained</summary>

**Last updated:** 2026-10-11 (forty-eighth pass — a third `/doc_sync` the same day, after the owner
deleted the stage's twenty-one simulators. **No source or test file changed, nothing was built or
run, and nothing is committed**: HEAD is `b8a1386`, and stage 2 stands staged as it was. Seven
fresh read-only readers — three on this file, one each on `docs/STATE.md` and `docs/DESIGN.md`, one
on `docs/WIDGET.md` and `CLAUDE.md`, one on today's own records against the stage's ledger — and
each finding opened in the code, the saved logs or the session's own record before it was used.
**Every count, line citation, table cell, gate figure and Git line they checked was right; what
was wrong was prose.** In this file: a notification read outside "the only UN caller"; four
file-backed test stores against "every test builds an in-memory container"; **eight** non-Swift
build inputs, not six (three asset catalogues); five of the six shared files in four targets, not
"both"; a heading that a closing details tag, with no blank line after it, had swallowed. In the
stage's section: **the gate ran in the
working tree, which also holds five unstaged build inputs**; the warning comparison's units and
folders — 38/19/2/19 are distinct warnings by file and message, only the app's build started in an
empty folder, and by whole lines the shipping sources give `CLAUDE.md`'s 31 and 44; what each of
the three settings passes showed, which was not the same thing; the large-text renders, whose
last later write was comments only; and four things missing from *Not done*, the plan's largest
phone among them. **A correction corrected:** the forty-seventh pass wrote that the stage's
reviewer "did not find" the change of yardstick. Its report, in the session's own record, says
"The yardstick changed, though" and asks that it go to the owner (#95). Known issues: notes on
#14, #40, #80, #88, #90, #95, #102 — the disk read 82 % twenty-five minutes after it read 90 %;
**#103 gains part (f)**, eleven more stale comments and rule sentences; **#104, #105, #106
opened**, all older than the stage: three spellings of the Glass's index, two fallbacks silent in
`DEBUG`, a haptic triggered by a model value. **Counts, re-derived:** 66 `.swift` files, 63 in
targets and 3 in `Tools/`, every row's line count matching; 444 `@Test` on the phone, 57 on the
watch, 25 UI `func test`; eleven keys, nine the phone's; three exception sets of six. **The gate
was not run in this pass.** `docs/STATE.md`, `docs/DESIGN.md`, `docs/WIDGET.md`, the plan's closing
note and `tasks/lessons.md` corrected; `CLAUDE.md` reconciled in seven more lines, **unstaged**.)

</details>

<details>
<summary>Forty-seventh pass — 2026-10-11, retained</summary>

**Last updated:** 2026-10-11 (forty-seventh pass — `/doc_sync` run again by the owner the same day.
**No source or test file changed, nothing was built or run, and nothing is committed**: HEAD is
`b8a1386`, and stage 2 stands staged exactly as the forty-sixth pass left it. **What this pass is:**
the forty-sixth was written by the session that built the stage, and it left behind what that
session did not reopen. Four fresh readers, one per sheet, worked from the tree; each finding was
checked against the code or the stage's ledger before anything was written. **In this file:** the
targets table (444 `@Test` in 56 suites; `GoalSetupUITests` holds 20; 25 UI `func test`, 38
executed), the app-only list, the harness's row, the watch catalogues' key counts, the project
census (seven resource phases, six non-Swift inputs, two root Info.plists), the process-role
table — every line citation into `DataManager.swift` moved when the file grew from 2,583 lines to
2,792, and **`republishStreak()` is a seventh guarded site** — and *Rendered and read*, which now
says which build each settings pass ran on: **none was the final one**. Known issue **#7 retired**
(the text it names is gone); dated notes on #36, #44, #45, #51, #77, #82, #84, #87, #88, #90 and
#91; #92, #95, #100, #101 and #102 corrected; **#103 opened** — what stage 2 left stale that a doc
sync may not edit: rule `25-shared-storage`'s "six sites", and source comments in six files.
**Corrected about the forty-sixth pass's own account:** the stage's *first* contrast table was the
clean-ground one and it failed; the change of yardstick was the building session's ruling, not a
slip the reviewer caught (#95). **Counts, re-derived at the end of this pass:** 66 `.swift` files —
63 in the seven targets, 3 in `Tools/` — every row's line count matching the tree; 444 `@Test` on
the phone, 57 on the watch, 25 UI `func test`; eleven keys on `DataManager.Key`, nine of them the
phone suite's; three exception sets of six files. **The gate was not run in this pass**; every
result below is the forty-sixth's, run on 2026-10-11 on the source that is still staged.
`docs/STATE.md`, `docs/DESIGN.md` and `docs/WIDGET.md` corrected, each header saying what;
`CLAUDE.md` reconciled in five lines and left **unstaged** with the rule wording.)

</details>

<details>
<summary>Forty-sixth pass — 2026-10-11, retained</summary>

**Last updated:** 2026-10-11 (forty-sixth pass — `/doc_sync` at the end of the redesign's stage 2,
Home, by the session that built it. **Stage 2 is finished, tested and staged; nothing is
committed.** HEAD is `b8a1386`: **stage 1 was committed in between** — `c9ef45d` and the six commits
after it — which the forty-fifth pass's *Git* block and this file's "staged 2026-10-10" notes
predate; both are brought up to date here. **What stage 2 is:** Home redrawn — the date, *Today* and
a streak chip; the vessel sized by a `Layout` between a fixed floor and a ceiling that scales with
text; a status line; a quiet line (next reminder, last drink) that an *Undo* capsule replaces for
eight seconds after a pour; the Glass ranked above Cup and Bottle on the screen's one primary
surface. Behind it, on `DataManager`: `addLog` returns the row's id, `undoLog(id:)`, four derived
figures, a published `streak`, and `dayDidTurn()`, which republishes the rows when the day turns
with the app open. **No key added** — eleven, as before. **63 `.swift` files; 444 `@Test` functions
in 56 suites; 57 on the watch; 25 UI `func test`, 38 executed.** The gate ran on the staged source,
and the UI suite on iOS 27.0, 26.5 and 18.6. **A fresh reviewer read the staged diff**: nothing
critical, four things that mattered — two of them were mine to reverse or repair (the vessel's
floor, the *Undo* capsule at large text) and the fix pass found two defects of its own before
anything was recorded. Known issues **#91a retired**, #91d two of three; **#39, #81, #85, #87, #89,
#90 updated; #92 to #102 opened.** Rule wording for five rule files and `CLAUDE.md` is written and
**unstaged**, for the owner. `docs/DESIGN.md`, `docs/STATE.md` and `docs/WIDGET.md` updated.)

</details>

<details>
<summary>Forty-fifth pass — 2026-10-10, retained</summary>

**Last updated:** 2026-10-10 (forty-fifth pass — `/doc_sync` run by the owner straight after stage 1
was reported finished. **No source file changed, and nothing was committed in between:** HEAD is
`8a44e8f`, and the index still holds stage 1's twelve paths. The pass before this one was written by
the session that built the stage, as its last task; this one read it against the tree. **The diff is
clean** — 60 `.swift` files, every one named here, no stale line count; 387 `@Test`, 57 on the watch,
14 UI `func test`; three exception sets and eleven keys, as `CLAUDE.md` and `docs/STATE.md` say.
**Three things had drifted, all of them the forty-fourth pass's own:** *Shipped, but not Swift* still
listed three screenshot sets that are gone from disk; `docs/WIDGET.md`'s header still called stage 1
"staged and not finished"; and `docs/DESIGN.md`'s measured-contrast table still drew the goal line at
white 0.45. **One published count was wrong:** the screenshot checkpoint in `HISTORY.md` says twenty
census iPhone captures were deleted, and there were nineteen — superseded there, not rewritten. **No
gate run this pass**; the results under *Current state* are the forty-fourth's, run that night on
the source that is staged now. `docs/STATE.md` and `CLAUDE.md` checked and not touched.)

</details>

<details>
<summary>Forty-fourth pass — 2026-10-10, retained</summary>

**Last updated:** 2026-10-10 (forty-fourth pass — `/doc_sync` at the end of the redesign's stage 1.
**Stage 1 is finished, tested and staged; nothing is committed.** The owner settled what had paused
it: Apple's glass is darkened with Apple's own tint, climbed one rung at a time against measured
contrast — `0.40` and `0.44` failed at rest, `0.48` failed once the aurora was followed through its
swing, **`0.52` is the first that passes**; the week card's goal line goes to white 0.55 and the goal
slider's range labels to 0.75; the tests run on iOS 27.0 and on simulators made for the purpose,
because the pinned ones never came back. **A real bug was found on iOS 26.5 and fixed:** a serving row
ignored a tap on its bare glass, while iOS 27.0 took it — `systemPane` now says `.contentShape`, and
a UI test holds it. **The app ran below iOS 26 for the first time**, on iOS 18.6. **387 `@Test`
functions in 48 suites; 14 UI `func test`, 27 executed.** The watch tests ran again, on watchOS
27.0 (#77). **Found, not fixed:** the hand-made pane reads lighter than this document's design
records on iOS 18.6 and in the shipped 1.1 on iOS 27.0, so several pairs the records show passing
are under their floor there (#85). **Separately, the same night:** four new iPhone store captures of
1.1, the old iPhone 6.5″, iPad and census-iPhone sets deleted, two capture-tool fixes — unstaged, a
change of their own. Known issue **#80 retired**; #45, #62, #77, #81, #82 updated; **#85 to #91
opened**. `docs/DESIGN.md` updated; `docs/STATE.md`, `docs/WIDGET.md` and `CLAUDE.md` checked and not
touched.)

</details>

<details>
<summary>Forty-third pass — 2026-10-09, retained</summary>

**Last updated:** 2026-10-09 (forty-third pass — `/doc_sync` run by the owner in the middle of the
redesign's stage 1. **A premium redesign was designed, specified and planned today, and its first
stage is half built, staged and paused.** The owner put it ahead of StoreKit; the look was confirmed on
a canvas; the spec, `docs/superpowers/specs/2026-10-09-premium-redesign-design.md`, and stage 1's plan,
`docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md`, were both approved. **Built and
staged, not committed:** `liquidGlass(…)` draws Apple's own glass on iOS 26 and later, chosen by a pure
routing function; a solid white *primary surface* under *Get Started* and the sheet's *Save*;
`LiquidGlass.Selection`, and a lozenge behind the selected tab; rule wording in `60-design-system` and
`15-project`. **385 `@Test` functions in 48 suites** (377 in 46 before). **Paused on two things only
the owner can settle:** the pinned simulators still have no data on disk (#77), and **on Apple's glass
most of the app's dimmed text measures 2.3–3.9:1 against a 4.5:1 floor** (#80, opened) — the plan's one
authorised fix cannot close it, and two measured alternatives await a decision. **No gate run this
pass:** five suites, three builds and a throwaway render probe ran, all on iOS 27.0. **This sync's own
drift:** the *Git* section still described `78ff05a` and an uncommitted tree, a day after `8a44e8f`
committed it; **#79 is retired** against `eba1b1e`; six line counts were stale, the change's own six
files. Known issues **#80 to #84 opened**. `docs/DESIGN.md` and `docs/WIDGET.md` updated;
`docs/STATE.md` and `CLAUDE.md` checked and not touched.)

</details>

<details>
<summary>Forty-second pass — 2026-10-09, 09:01, retained</summary>

**Last updated:** 2026-10-09 (forty-second pass — `/doc_sync` at 09:01, minutes after the forty-first, on
the owner's word: **the Siri phrase works, and 1.1 has been submitted to App Review.** No source file
changed, and none was changed for Siri. **#78 is closed by observation, not fixed**: why *Log a Glass*
opened the app and logged nothing on an earlier build is still not known. **Four archives stand in
Xcode's Archives folder**, read this pass for the first time: 1.0 (1), refused; then 1.1 (1), 1.1 (2) and
1.1 (3), each uploaded. The failure was reported before build 3 existed, so it was seen on (1) or (2).
Build (2) carried the app at 2 and its widget and watch app at 1; (3) carries 3 throughout. That is the
one difference found between them, and it is a correlation, not a cause. **The build in review has no
commit** (#79, opened): every one of those archives was made from the working tree, which holds the
fixes for #68 and #73 and the version change, all uncommitted. **This sync's own drift:** the
forty-first pass wrote that nothing had been archived as 1.1 (3), three minutes after one was. Known
issue **#78 closed**, **#79 opened**; #63 gains a note. **No gate run this pass.** `docs/STATE.md`,
`docs/WIDGET.md`, `docs/DESIGN.md` and `CLAUDE.md` checked and not touched.)

</details>

<details>
<summary>Forty-first pass — 2026-10-09, 08:55, retained</summary>

**Last updated:** 2026-10-09 (forty-first pass — `/doc_sync` the morning after the fortieth. **No source
file changed.** Two other things did. **The Siri phrase fails on the owner's iPhone** (#78, opened): on a
TestFlight build of 1.1, *Log a Glass* opens WaterBuddy and logs nothing, whether spoken to Siri in
English or tapped in Shortcuts. It is the first time the App Shortcut has been tried on a build the
system will run (#63), so roadmap item 4's device check has failed. **The cause is not found.** The built
app's metadata, phrase tables and binary are right in Debug and in Release. Three throwaway probes on the
simulator found the intent by name from off the main actor, ran `perform()` — it returned its dialog and
logged one Glass — and read its mode as background-only. What is missing is the device's own log.
**The build number is 3** at all fourteen sites, beside `MARKETING_VERSION` 1.1; the owner had set 2 on
the app target alone. **This sync's own drift:** one stale sentence, the build number; #63 and #50 gain
notes. Known issue **#78 opened**. **No gate run this pass** — no source changed; the three probe runs
are recorded as probes, under *Current state*. `docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md` and
`CLAUDE.md` checked and not touched.)

</details>

<details>
<summary>Fortieth pass — 2026-10-09, just after midnight, retained</summary>

**Last updated:** 2026-10-09 (fortieth pass — `/doc_sync`, run just after midnight, after **known issue
#73, fixed** on the evening of 2026-10-08: the owner's pick with no task named. `loadFromStore()` re-read the goal, the vessels and the language on every
`refresh()` and left `remindersEnabled` as `init` had read it. A widget extension that outlived the
toggle therefore planned from the old flag: a press after reminders were switched on filed an empty plan
and cleared them, and a press after they were switched off filed them again. The flag is now re-read
behind the same equality guard as its neighbours. One file, `DataManager.swift`, +13 lines; no rule, key,
catalogue, entitlement or membership. Four tests in `ReminderSeamTests`, each seen RED: both directions
through a second manager standing in for the extension, the publish, and the guard — the last made to
fail against an unguarded re-read before the guard was written. **The gate ran on a different
simulator.** The Mac's simulators lost their data that evening (#77), so the phone runs used iOS 27.0's
iPhone 17, not the pinned 26.5: **377**/46 phone unit, **26 of 26** phone UI, both widget builds, no new
warning by clean builds. **The watch tests did not run** — no watchOS 26 runtime is installed — though
the watch app and its tests compile. **Also that evening, the owner's own change:** App Store Connect
refused an upload of 1.0, which is approved, and `MARKETING_VERSION` is now **1.1** at all fourteen
sites. **This sync's own drift:** two line counts, the test count, the eight `DataManager.swift`
citations in *The process role*, seven more in `docs/STATE.md`, and one in #37. Known issue **#73
retired**, **#77 opened**; #5, #62 and #75 annotated. `docs/STATE.md` and `docs/WIDGET.md` updated;
`docs/DESIGN.md` and `CLAUDE.md` checked and not touched — nothing they describe moved.)

</details>

<details>
<summary>Thirty-ninth pass — 2026-10-08, retained</summary>

**Last updated:** 2026-10-08 (thirty-ninth pass — `/doc_sync` after **known issue #68, fixed**. The
roadmap's *Now* and *Next* lists had all shipped, and the owner chose this bug ahead of its two
owner's-call items (Apple Health, StoreKit). The medium Home Screen widget drew its two figure lines in
the phone's language beside a button in the app's: `HydrationView` read `strings` from above its own
injection. The medium family's column is now `MediumColumn`, a view of its own beneath the injection —
`LockScreenView`'s pattern — and `HydrationView` declares no `strings` at all. One file,
`WaterBuddyWidget.swift`; no rule, key, catalogue, entitlement or project-file line. **Rendered for the
first time**, by a throwaway probe that placed a medium widget on the simulator's Home Screen: RED on the
old code — `+250 мл` beside `7450 ml` and `of 2000 ml` — then GREEN in Russian and Uzbek, with the
English card byte-identical before and after. Gate on the final code — **373**/46 phone unit, **25 of 26**
phone UI (#62, pre-existing), **57**/6 watch unit, both widget builds — with no new warning by clean
builds. **This sync's own drift:** one line count. Known issue **#68 retired**, **#76 opened** (found by
reading while moving the column). `docs/WIDGET.md` and `docs/DESIGN.md` updated; `CLAUDE.md` and
`docs/STATE.md` checked and not touched — nothing they describe moved.)

</details>

<details>
<summary>Thirty-eighth pass — 2026-10-08, re-verified twice the same day, retained</summary>

**Last updated:** 2026-10-08 (thirty-eighth pass — `/doc_sync` after **roadmap item 6, the Control Center
control**: `docs/superpowers/specs/2026-10-08-control-center-design.md`. A `ControlWidget`,
`LogWaterControl` (kind `"WaterBuddyLogWater"`), in the existing extension, listed inside `if
#available(iOS 18.0, *)` — the codebase's first version check, the floor still 17.0. It draws the Glass's
glyph and *Log Water* in the app's language and no figure (the owner's ruling); its button is
`AddWaterIntent(amount: snapshot.serving)` over a `ControlValueProvider` that reads
`DataManager.snapshot(now:)`. `requestWidgetReload()` now also reloads controls, and
`DataManager.usualSlot` names the Glass's index for `usualServing(in:)` and the glyph alike. The owner
approved the design in conversation and asked to go straight to implementation, so the spec is the
record and the wording in five rule files is in the staged diff for their reading. Gate on the final code
— **373**/46 phone unit, **25 of 26** phone UI (#62, pre-existing), **57**/6 watch unit, both widget
builds — with no new warning by clean builds. On the simulator the control was placed, its title followed
the picker in all three languages, and a press **ran** — through `chronod`, not `linkd` (#63) — logging
the stored Glass, an edited one included; a mutation run showed the reload is what delivers the edit. A
fresh final review found no critical issue; its fixes are in. **This sync's own drift:** one
undocumented file (`LogWaterControl.swift`), five line counts, the targets table and the test count.
Known issues **#72–#75 opened**; #53, #63, #69 and #70 annotated. `CLAUDE.md`, `docs/WIDGET.md` and
`docs/STATE.md` updated; `docs/DESIGN.md` checked and not touched — no token moved. **Re-verified the
same day by a second `/doc_sync`**, which read the sections a count script cannot judge and found
*The process role*'s ten `DataManager.swift` citations stale — wrong at HEAD already, three moved further
by `usualSlot` — and seven more in `docs/STATE.md`, all re-derived against their symbols; plus one
`docs/WIDGET.md` sentence naming only the widget's button and a `CLAUDE.md` warning-baseline note now
dated. **A third `/doc_sync`** resolved the open known issues' own citations: **#11 retired** — its fix,
the test's corrected DocC, on disk since the repository's first commit — and one of #37's lines moved
33 down.)

</details>

<details>
<summary>Thirty-seventh pass — 2026-10-08, retained</summary>

**Last updated:** 2026-10-08 (thirty-seventh pass — `/doc_sync` after **roadmap item 5, the Lock Screen
widget**, owner-approved: `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`, executed from
`docs/superpowers/plans/2026-10-08-lock-screen-widget.md`. A second widget in the existing extension,
`LockScreenWidget` (kind `"WaterBuddyLockScreen"`), over the same `HydrationProvider`: a ring that fills
with the percentage inside, a card with today's millilitres, the goal, a bar and a 44pt **+** that logs
the Glass through `AddWaterIntent(amount: entry.snapshot.serving)`, and a drop and the percentage beside
the date. Every figure is `.privacySensitive()` with a quiet form for `.privacy`, so iOS's own *Lock
Screen Widgets* setting hides them — the owner's ruling, written into rule `70-privacy` with four more
rule files (`40-widget`, `60-design-system`, `65-accessibility`, `85-testing`) before any code. Gate run
three times, the last on the staged code — **371**/46 phone unit, **25 of 26** phone UI (#62,
pre-existing — HEAD's export fails it identically), **57**/6 watch unit, both widget builds — with no
new warning by clean builds. On the simulator all three shapes were placed and captured in all three
languages; the **+** reached `linkd`, which refused it (#63). A fresh final review led to
`.accessibilityHidden(true)` on every drawn figure and `.invalidatableContent()` on the card's — what
VoiceOver actually says stays the owner's device check's. **This sync's own drift:** two line counts
(`WaterBuddyWidget.swift`, `WaterBuddyWidgetBundle.swift`), one undocumented file
(`LockScreenWidget.swift`), the targets table. Known issues **#68–#71 opened**. `CLAUDE.md` and
`docs/WIDGET.md` updated; `docs/STATE.md` and `docs/DESIGN.md` checked and not touched — no key, no
stored shape and no token moved.)

</details>

<details>
<summary>Thirty-sixth pass — 2026-10-07, re-verified 2026-10-08, retained</summary>

**Last updated:** 2026-10-08 (thirty-sixth pass of 2026-10-07, **re-verified by a second `/doc_sync`
run on 2026-10-08**, after the owner had spec §5's wording written into six rule files — `15-project`,
`20-state`, `40-widget`, `43-concurrency`, `70-privacy`, `80-notifications`. The re-run re-derived every
probe — all current, the staged code byte-identical to what the final gate built — and corrected one
sentence of the spec, which still said rule `43-concurrency` names a single `static var`. The pass
itself: `/doc_sync` after **roadmap item 4, the Siri phrase**, owner-approved: `docs/superpowers/specs/2026-10-07-siri-phrase-design.md`, executed from
`docs/superpowers/plans/2026-10-07-siri-phrase.md`. "Log water in WaterBuddy" — or *Add water in*, *Log
a glass in*, and their Russian — runs the new app-only `LogServingIntent` (*Log a Glass*), which logs
the user's middle vessel, read through the new `DataManager.usualServing(in:)` that the widget's
snapshot now reads too, and replies only *Water logged.*, locked or not. Siri launches the app in the
background; the intent waits up to a second for the watch link and then for the reminder queue to drain
(`ReconcileQueue.settled()`). The phrases are en + ru in a fifth catalogue, `AppShortcuts.xcstrings` —
Siri has no Uzbek. **Registration is verified on the simulator; execution is not:** `linkd` refuses an
ad-hoc-signed build (#63), so the owner's device check is `perform()`'s first run, and
`LogTheGlassTests` pins the body between its two waits. Gate run in full twice — **371**/46 phone unit,
**25 of 26** phone UI (the one failure pre-existing: HEAD fails it identically on the same simulator,
#62), **57**/6 watch unit, both widget builds — with no new warning by clean builds. A fresh final
review found no defect; its fix pass added that seam and its three tests, corrected three DocC passages
the change had made false, and widened a timing test. **This sync's own drift:** two line counts
(`DataManager.swift`, `NotificationManager.swift`); three undocumented files; the targets table; the
app catalogue's key count, which read 58 from before the earlier-servings change (now 64); and
`docs/WIDGET.md`'s "vocabulary not translated" section, stale since known issue #1 was fixed on
2026-10-06. Known issues **#62–#67 opened**; #57 gains the unit-test host's refusal. `CLAUDE.md`,
`docs/STATE.md` and `docs/WIDGET.md` updated; `docs/DESIGN.md` checked and not touched — no token or
measured figure moved, and the tile's `.blue` is a system `ShortcutTileColor`, not an app colour.)

</details>

<details>
<summary>Thirty-fifth pass — 2026-10-07, retained</summary>

**Last updated:** 2026-10-07 (thirty-fifth pass — `/doc_sync` after **known issue #60's fix**: the
serving sheet's *Cancel* and *Save* labels now shrink to fit their capsules at `AccessibilityXXXL` —
`.lineLimit(1)`, `.minimumScaleFactor(0.4)` and `.padding(.horizontal, 12)` on both, eleven lines in
`HistoryView.swift`, byte-identical to the fix the previous session rendered (`e083cfc`). It lands on
its own, as the owner ruled: first, `/commit` — run at the owner's instruction — committed and pushed
roadmap item 3 as `9e8e6df`, `ffe82e6`, `b33d08f` and `4217f7c`. **#60 retired.** **This sync's own
drift:** one line count of 58 — `HistoryView.swift`'s, documented 947, already 948 at HEAD (the owner's
#59 comment landed after the count), now 959. **#57** gains a second refusal, from a run that started
with no other `xcodebuild` running; **#61 opened**: `/commit`'s own gate block predates the watch. Gate
run in full twice this session — before the commit and after the fix — green both times: **358**/41
phone unit, **26** phone UI (the second time on a second run — the first was refused launch, #57),
**57**/6 watch unit, both widget builds. No warning in `HistoryView.swift`; the builds were
incremental, so there is no figure to set against the clean baseline. `docs/STATE.md`,
`docs/WIDGET.md`, `docs/DESIGN.md` and `CLAUDE.md` were checked and deliberately not touched: nothing
they state has changed.)

</details>

<details>
<summary>Thirty-fourth pass — 2026-10-07, retained</summary>

**Last updated:** 2026-10-07 (thirty-fourth pass — `/doc_sync` after **roadmap item 3: a serving added
or fixed at an earlier time or day**, owner-approved:
`docs/superpowers/specs/2026-10-07-earlier-servings-design.md`. History's week card now picks the day:
seven full-width buttons, the shown day outlined and announced as selected. The header and the list
follow it — today exactly as before, a past day from `historyLogs`, the window's rows published from
the fetch `history` is summed from. A `+` in the header opens one sheet, *Add a serving* or *Edit
serving*, whose day · hour · minute wheel is bounded by the week and by now. `updateLog` takes a time,
so an edit can move a serving's water between two days, and the widget and the watch hear of it only
when today's total moves. **This sync's own drift:** 3 of 57 line counts (exactly the three existing
files the change touched); one undocumented file, the new `EarlierServingTests.swift`; both phone test
counts in the targets table; `docs/STATE.md`'s "the week card is its only consumer" of `history`,
loose before this change; and the Git section's account of `.claude/settings.json`, which said
`git push` moved to *allow* where the diff moves `git commit` and `git init` and leaves `git push`
under *ask*. Known issue **#16 retired** — the change rewrote the DocC it named — and **#59 and #60
opened**: the wheel's neighbouring rows under the text floor, and the sheet's buttons overflowing at
`AccessibilityXXXL`, pre-existing. The owner then ruled on all three follow-ups the same day: #59
**accepted** as the system control's styling; the spec's §5 rule wording **written** (`20-state`,
`30-rollover`, `50-views`, `65-accessibility`); and #60 **fixed**, verified, and held for its own
commit. Gate re-run in full this session, without `xcrun simctl shutdown
all` (a simulator this session had not booted was running): **358**/41 phone unit, **26** phone UI (on
a second run — the first was refused launch, #57's shape), **57**/6 watch unit, both widget builds
green. No new warning, by named and by generic destinations; the generic one gives the documented 31/80
and 6/12, the named one 44/6, because a generic destination builds two architectures. `docs/DESIGN.md`
gains seven measured figures. `docs/WIDGET.md` and `CLAUDE.md` were checked and deliberately not
touched: the widget and nothing `CLAUDE.md` states have changed.)

</details>

<details>
<summary>Thirty-third pass — 2026-10-07, re-verified three times the same day, retained</summary>

**Last updated:** 2026-10-07 (thirty-third pass, **re-verified by three further `/doc_sync` runs the
same day**. The fourth re-derived every probe — all current — and tightened three of the third's
phrases in place: a check pinned only by the run after it is not "bracketed"; the probe shows that
*any* context the old wake re-read was in the store before its reload, not that one was; and one
identified `Glazzy` run plus one unidentified `xcodebuild` are not "another project's test runs". The
third re-derived every probe again — all current — and confirmed the second's central correction by
experiment: a `queue: .main` block observer, posted to from the main thread, ran before `post`
returned, on this Mac's Foundation, so any context the old wake re-read was in the store before its
reload. It corrected three of the second run's own phrases, fixed in place below. The phone widget's
rebuild reprints the watch app's warnings as well as the phone app's. The other project's run was seen
just before 11:39:42 — by a check that printed no time, pinned by the gate's own `start` after it —
and gone by 11:52:05, by a second check between the failed run's `end 11:51:11` and the re-run's
`start`: not "at 11:39:42" and "by 11:51". And returning at once did not rule delegate deliveries
out; it left them unable to land while the task was still open. The second run
re-derived every probe — all current — and corrected seven of this pass's own statements.
"No simulator here has ever run" a WatchConnectivity background task said more than spec §15 found,
which is that none was ever *seen* to. The 31/80 warning figures belong to the `WaterBuddy`
build-for-testing alone, not to all four schemes, which give 31/160 — the phone widget's scheme
rebuilds the phone app and the watch app it embeds, and reprints the same 80 — and still 6/12. The old
background wake was not "never able to work": `activate()` re-read `receivedApplicationContext` before
the reload, so a context already held could reach the face, while returning at once left every
delegate delivery, any push included, unable to land while the task was still open; the spec's §2 is
corrected in place, and two comments the change wrote into code still say otherwise (#58 opened).
That §2 also said the 15-minute refresh "cannot help a phone drink": it could, once the watch app had
run, because a foreground launch applied a mirror without reloading the face, and the timer drew it —
corrected in place too. The memberwise `isNews` whose claim was too strong never existed as code — it
was the spec's first §4.6. The script that tripped `Bash(chmod:*)` was never written: the whole
command was refused. And #57 now says what was observed rather than what was likely. The pass's own
summary follows, corrected. `/doc_sync` after **roadmap item 2: the complication stays current**,
owner-approved: `docs/superpowers/specs/2026-10-07-complication-current-design.md`, with §18 added to
the watch spec. The watch app now reloads its own face whenever it writes the store
— every pour, and every mirror that is *news* (`WristMirror.isNews(since:)`: any field but
`composedAt`). The `.backgroundTask(.watchConnectivity)` closure waits, bounded and cancellable, until
the session has delivered, instead of returning at once. The face asks for a timeline `.atEnd`, not
every 15 minutes. The phone pushes a news mirror with `transferCurrentComplicationUserInfo` beside the
application context, while the complication is on the face and the day's budget lasts, cancelling any
superseded push first. And `WristModel.apply(_:)` never takes a mirror composed before the one it
holds, unless the one held is more than a minute ahead of the watch's clock. **The background path is
unverified on hardware** — no simulator here has ever been seen running a WatchConnectivity
background task — and the owner chose to check it on their own iPhone and Apple Watch (spec §8.3,
#52). **This sync's own
drift:** 6 of 56 line counts (exactly the six files the change touched); one undocumented file, the
new `WristLinkDeliveryTests.swift`; `WristSyncTests.swift`'s row, which had never listed
`WristLinkReachabilityTests`; both test counts in the targets table; `docs/STATE.md`'s `wristMirror`
row, which named only the context as its source. Known issue **#43 narrowed** — the change reflowed
one of its two ragged comment lines — and **#52–#57 opened**, with #58 by the re-run. Gate re-run in full this session, again
without `xcrun simctl shutdown all` (another project's run was live): **331**/35 phone unit, **25**
phone UI (on a second run — the first was refused launch, #57), **57**/6 watch unit, both widget
builds green; warnings identical per file, message and count against a `git archive HEAD` export
across all four schemes — and in the `WaterBuddy` build-for-testing, the baseline's own method, 31
unique lines and 80 occurrences on the shipping targets, 6 and 12 on the test targets.
`docs/WIDGET.md`, `docs/DESIGN.md` and `CLAUDE.md` were checked and deliberately not touched: the
phone widget, the tokens and nothing `CLAUDE.md` states has changed.)

</details>

<details>
<summary>Thirty-second pass — 2026-10-07, re-verified the same day, retained</summary>

**Last updated:** 2026-10-07 (thirty-second pass, **re-verified by a second `/doc_sync` run the same
day**. It re-derived every probe — all current — and corrected four of this pass's own statements.
The simulators found shut down between runs were shut down by `xcodebuild` itself as each run ended,
not by another session: a two-second poller showed it. The watch gate run boots the watch *and* its
paired iPhone 17, so "each run used one device" was false for it (#51 opened). The phone-widget
build's warnings came from the phone and watch apps that scheme also builds, not "the shared files it
recompiled". And 6/12 was the test targets' first clean-build count, not their first measurement.
The pass's own summary follows, corrected. `/doc_sync` after **known issue #46 was fixed**:
the two reconciles every mutation files now run one at a time, in call order.
`DataManager.requestReminderReschedule` hands each to one process-wide `ReconcileQueue` — new, in
`NotificationManager.swift`, one worker draining an `AsyncStream` — instead of a `Task` of its own,
so the plan from before a drink can no longer finish after the plan from after it and re-file the
slot the drink dropped. Owner-approved, with three rule amendments: `80-notifications`, and
`ReconcileQueueTests` joining the non-`@MainActor` canary lists in `43-concurrency` and
`85-testing`. **This sync's own drift:** 4 of 56 line counts (exactly the four files the change
touched); the targets table's phone test count; all eight `DataManager.swift` line references in
*The process role*, stale before this change too (the hook's guard was documented at `:847`, stood
at `:1067` in `641e88c` and stands at `:1084` now); the files-on-disk note, still dated to the
thirtieth pass; #16's line numbers; `docs/STATE.md`'s reminder seam and its *Tests that pin this*;
one sentence in `docs/WIDGET.md`. Known issue **#46 retired**, and **#16 narrowed** to two comments —
the change rewrote the third. **#49 and #50 opened**: the widget's own reconciles stay outside the
queue, a race unverified; and the Xcode app writes strings into both watch catalogues. Gate re-run
in full this session, without `xcrun simctl shutdown all` — other projects' test runs were sharing
the simulators: **328**/34 phone unit, **25** phone UI, **45**/5 watch unit, both widget builds
green; warnings identical per file and message against a `git archive HEAD` export — 31 unique lines
and 80 occurrences on the shipping targets, and 6 and 12 on the test targets, their first clean-build
count. `docs/DESIGN.md` and `CLAUDE.md` were checked and deliberately not touched — no token moved,
and nothing `CLAUDE.md` states changed.)

</details>

<details>
<summary>Thirty-first pass — 2026-10-06, re-verified 2026-10-06 and 2026-10-07, retained</summary>

**Last updated:** 2026-10-07 (thirty-first pass, **re-verified by two further `/doc_sync` runs**, the
same day and the next. Both re-derived every probe — all current. The second corrected one claim
this pass had inferred rather than checked: the false caption's age, first written as "since
2026-08-28", the date of the reminders feature's checkpoint. Git can prove only that the string was
in the repository's first commit; the summary below now says so, and quotes the README in its own
words. The third, on 2026-10-07, found two claims in *Current state* stated beyond their evidence —
the TDD order ("the parameter landed first"; the tests came first) and what
`everyDrawnStringIsTranslatedUnlessDeliberatelyNot` proves (that a translation exists, not what it
says) — and corrected both there. The pass's own summary follows, corrected. `/doc_sync` after **smart reminders learned to skip
the one due within an hour of a drink**, the first item of the owner's App Store roadmap, ordered by a
read-only market scan of about 430 recent reviews of six competing apps. `ReminderPlan.slots(...)`
takes `lastDrink: Date?` and drops — never moves — any slot due less than `quietAfterDrink` (one
hour) after it, the drink clamped to `now`; `DataManager.currentReminderSlots()` passes the latest of
`todaysLogs`' timestamps, so the app's hook and `AddWaterIntent` file the same plan. It also retires
a false claim that was in the tree from the repository's first commit (`69c5a39`, 2026-09-01) — git
holds nothing earlier: the Settings caption said "Logging water pushes the next one back", the README
"Logging pushes the next one back" (from `e93802d`, 2026-09-02), and nothing did. Both reminder
captions are rewritten in en/ru/uz
under new keys. Rule `80-notifications` amended, owner-approved. **This sync's own drift:** the five
line counts of exactly the five Swift files the change grew; the phone test count in the targets
table; the Git section one pass stale; and `docs/STATE.md`'s *Tests that pin this*, stale before the
change — it printed 151, its own figures summed to 152, the tree held 160. Known issues **#46–#48**
opened: the three limits the change records rather than fixes. Gate re-run in full this session:
**325**/33 phone unit, **25** phone UI, **45**/5 watch unit, both widget builds green; warnings
compared on clean `-scheme WaterBuddy` builds, 31 against 31 unique lines and 80 against 80
occurrences, none new. `docs/STATE.md` carries the plan's new input. `docs/WIDGET.md`,
`docs/DESIGN.md` and `CLAUDE.md` were checked and deliberately not touched — the widget's contract,
the tokens and every statement they make about reminders still hold.)

</details>

<details>
<summary>Thirtieth pass — 2026-10-06, re-verified twice the same day, retained</summary>

**Last updated:** 2026-10-06 (thirtieth pass, **re-verified by two further `/doc_sync` runs the same
day**. The second re-derived every probe — all current — and corrected four of this pass's own
figures: #44 measured with a sampler that read glyph ink as background, so its failure is wider than
first written (77% of the line, not "toward its ends"); the widget's ramp, ported, ≈3.0:1 rather than
2.9; the warning comparison 8 against 8 compiler-emitted occurrences, not 16; and the old glass colour
≈(24, 28, 62). The third widened #45 — the watch capture script also repeats two claims since found
false — and confirmed off the scheme file a claim this pass had only inferred. The pass's own summary
follows, corrected. `/doc_sync` after **known issue #35 was
fixed**. The watch's vessel laid its readability scrim down at the phone app's constant full
strength, so at 0% it drew as a near-black disc — every watch's first screen of the day, and the
shipped App Store image. `WristVessel.scrimIntensity(at:)` now ramps it from none at 0% to full
strength by 20%, a ramp of the watch's own: measuring the shipped captures showed the phone widget's
`min(1, level * 1.6)`, ported, would have taken the watch's small millilitre line to about 3.0:1 over
water. The same measurement found that line already under 4.5:1 across most of its width at full
strength — **known issue #44**, opened and deliberately not fixed, at the owner's ruling. Rule `60-design-system`'s *Water* bullet amended,
owner-approved. **This sync's own drift:** 2 of 56 line counts (exactly the two files the fix
touched); the targets table and the gate table a pass behind on the watch count (42 → 45); the Git
section five commits stale. **Found along the way:** all three capture scripts default to simulators
that no longer exist — **known issue #45**. Known issue **#35 retired**; **#44 and #45 opened**. Gate
re-run in full this session: **316**/33 phone unit, **25** phone UI, **45**/5 watch unit, both widget
builds green; warnings compared on clean `-scheme WaterBuddyWatch` builds, 2 against 2, none new.
`docs/DESIGN.md` carries the new ramp and two measured watch figures. `docs/STATE.md`,
`docs/WIDGET.md` and `CLAUDE.md` were checked and deliberately not touched — no key, no phone-widget
contract and nothing they state changed.)

</details>

<details>
<summary>Twenty-ninth pass — 2026-10-06, re-verified twice the same day, retained</summary>

**Last updated:** 2026-10-06 (twenty-ninth pass, **re-verified by two further `/doc_sync` runs the
same day**. The second re-derived every probe and corrected three of this pass's own statements —
the build-input count (six → five), a claim that every task went RED before GREEN (Task 5 had no RED
step, by ruling), and `docs/STATE.md`'s DEBUG note (an empty code is not announced). The third found
the new spec's status line still reading "awaiting the owner's review … No code has been written",
gave the plan a status note, and corrected a build count recorded as "a dozen" — there were 22.
The pass's own summary follows. `/doc_sync` after **the watch was localized**,
closing known issues **#18** and **#19**. The watch drew hard-coded English everywhere — its screen,
the "More" sheet, every VoiceOver string — and `WristMirror.languageCode`, sent and persisted, had no
reader. Now `WristModel.language` resolves it through `AppLanguage(code:)` (`nil` and no mirror →
the watch's own `Bundle.main`), a private `WristRoot` injects `\.strings` and `\.locale` above
`WristView`, and two new catalogues ship en/ru/uz (`WaterBuddyWatch/` 16 keys,
`WaterBuddyWatchWidget/` 2) — spec `docs/superpowers/specs/2026-10-06-watch-localization-design.md`,
plan `docs/superpowers/plans/2026-10-06-watch-localization.md`, both owner-approved. **This sync's
own drift:** 8 of 56 line counts (exactly the eight files the change touched); the phone widget
catalogue's row still called its five Shortcuts strings untranslated; known issues **#1** and **#12**
were fixed on disk before the repository's first commit and never retired; **#25**'s premise was
false; **#32**'s premise — "Apple has never shipped XCUITest for watchOS" — was false too,
`XCUIAutomation.framework` ships in the watchOS SDK; **#36**'s open question is answered; and the Git
section named HEAD `55c73b2`, three commits stale. Known issues **#1, #12, #18, #19 and #25
retired**; **#39–#43** opened. Gate re-run in full this session: **316**/33 phone unit, **25** phone
UI, **42**/5 watch unit, both widget builds green; warnings 31 against 31 on clean builds, none new.
`docs/WIDGET.md` and `docs/DESIGN.md` were checked and deliberately not touched — neither mentions the
watch, and neither the phone widget's contract nor a design token changed.)

</details>

<details>
<summary>Twenty-eighth pass — 2026-10-05, re-verified 2026-10-06, retained</summary>

**Last updated:** 2026-10-06 (twenty-eighth pass, 2026-10-05, **re-verified by a second `/doc_sync`
run on 2026-10-06**: every probe and check re-derived and current, one figure in this paragraph
corrected — the Git section had been stale for three passes, not two — and `PRIVACY.md`'s list of
"the entire contents of the link" found one field short of the wire after the #26 fix, corrected at
the owner's word. The twenty-eighth pass's own summary follows. `/doc_sync` after **known issue #26
was fixed**.
The watch counted the phone's mirrored total whatever day it came from, so every morning — until
something woke the phone — the watch's screen *and* its complication drew yesterday's water.
`WristMirror` gained `phoneDayEnd` (spec §17, owner-approved), `WristPlan` gained
`todaysTotal(mirror:outbox:now:calendar:)` and `dayBoundaries(after:mirror:calendar:)`, both watch
surfaces read them, and the complication now schedules timeline entries at the phone's day end and
the watch's own midnight. **The toolchain moved under the repo between sessions:** Xcode 27.0 with
iOS/watchOS 27.0 runtimes beside 26.5; a second simulator named "iPhone 17" on iOS 26.5 made the
gate's destination ambiguous until the owner had it renamed; and the warning baseline was
re-measured on the new toolchain — 33 unique warning lines before this change, **31** after, no new
pair (known issue #29). HEAD is `55c73b2`: five commits landed after the twenty-seventh pass with no
checkpoint — the rule/gate update, the iPad 13″ composite set and its tool, the README and the
privacy policy — and `HISTORY.md` now records them. **This sync's own drift:** 7 of 55 line counts
(exactly the seven files the fix touched), one undocumented file (`Tools/ComposeStoreScreenshot.swift`),
the watch widget's exception set still described as five files when it has been six since
2026-09-01, #27 and #28 still listed open after this file's own header closed them, the entitlements
paragraph naming two files of four, and the Git section three passes stale. Known issue **#26 fixed**;
**#36–#38** opened. Gate re-run in full this session: **309**/33 phone unit, **25** phone UI,
**30**/5 watch unit, both widget builds green. `docs/WIDGET.md` and `docs/DESIGN.md` were checked and
deliberately not touched — the phone widget's contract and the design tokens did not change.)

</details>

<details>
<summary>Twenty-seventh pass — 2026-09-02, retained</summary>

**Last updated:** 2026-09-02 (twenty-seventh pass — `/doc_sync` after the App Store preparation
work: iPad dropped to `TARGETED_DEVICE_FAMILY = 1`, `IPHONEOS_DEPLOYMENT_TARGET` 26.5/18.6 → **17.0**
and `WATCHOS_DEPLOYMENT_TARGET` 26.5 → **26.0** (both compile- and link-verified, neither ever *run* —
no matching runtime is installed), the watch's missing launcher icon fixed, four `PrivacyInfo.xcprivacy`
manifests added, export compliance declared, and a screenshot harness built that captured 37 verified
images. HEAD is still `7f55364`; **nothing is committed**, and the index continues to hold the watchOS
docs pass's own 39 paths, so this session's work was deliberately left unstaged to keep the two
separable (rule `90-git`). Drift fixed this pass: one stale line count, one undocumented file, the
UI-test declared count 10 → 12, and a build command in `docs/WIDGET.md` still pinned to
`OS=18.6,name=iPhone 16`. Six known issues opened, **#29–#35**; two closed by observation, **#27**
(`WristServingMenu` had never been rendered by anyone — it has now, and it is correct) and **#28** (the
"More" button's below-the-fold position *and* its crown reachability, both previously argued rather
than seen). Superseding note for the twenty-sixth pass below, which is retained as written.)

</details>

<details>
<summary>Twenty-sixth pass — 2026-09-01, retained</summary>

**Last updated:** 2026-09-01 (twenty-sixth pass — `/doc_sync` after the `WristView` redesign.
HEAD is still `7f55364`; nothing this pass is committed. **The watch's one screen was reorganised at
the owner's direction**: the three equal-weight pour rows under the vessel are gone, the **vessel
itself** is now the pour button for one serving — `mirror.servings[1]`, the same middle quick-add
vessel `AddWaterIntent` logs from the phone widget, so the two ambient front doors cannot follow
different ones — and the other two servings sit behind a single "More" button that presents a sheet
(`Menu` does not exist on watchOS). `WristVessel` gave up its three accessibility modifiers, which
moved onto the `Button` in `WristView` because rule `65-accessibility` forbids an
`.accessibilityElement(children: .ignore)` wrapper around a control. The vessel was then enlarged
twice, also at the owner's direction: `vesselHeightFraction` 0.5 → 0.625 → **0.78125**, ~80pt → ~125pt
on a 46mm, **+56%**, which puts the "More" button below the fold at rest on every size — a stated
trade of reach for presence, recorded in that constant's own DocC. One real hardening rode along:
`WristMirror.servings` crosses the wire as an unvalidated `[Int]`, so indexing `[1]` for the vessel
was a trap on a malformed publish; `WristView.primary(from:)` is now non-optional and falls back to
`DataManager.defaultServing`. **This sync's own drift:** 3 of the 52 line counts in *Files on disk*
below were stale (exactly the three files the redesign touched — the other 49 were already current);
the targets table and the gate table both still said **24** watch tests, now **29**; and four prose
descriptions still named "three pour rows", a surface that no longer exists. Gate re-run in full
this session: **300**/33 phone unit, **25** phone UI, **29**/5 watch unit, both widget builds green.
`docs/STATE.md`, `docs/WIDGET.md` and `docs/DESIGN.md` were checked and deliberately not touched —
no key moved, the phone widget's contract did not change, and no design token moved; rule
`99-docs-cascade` forbids publishing a doc change nothing required. Previously: twenty-fifth pass —
`/doc_sync` after the scheme repair and spec §16.
HEAD `7f55364`; nothing this pass is committed. **Two owner-reported problems, both fixed:** the
`WaterBuddy` and `WaterBuddyWatch` schemes had vanished from `xcodebuild -list` — marking two other
schemes Shared writes `SuppressBuildableAutocreation` for every target, and neither of those two had
a checked-in `.xcscheme` — so the app could not be built to a device at all; all four are now shared
and tracked. And `WristView` is no longer gated on having heard from the phone (spec §16,
owner-approved, reversing one line of §12): it draws the vessel and pour rows against
`WristModel.displayGoal` — the mirror's goal, or `DataManager.defaultDailyGoal` before one arrives —
with the attribution line moved outside every branch and split three ways so "no mirror yet" and
"the phone has no goal yet" stop sharing one dead-end sentence. Also: `WristLink` now publishes on
WCSession activation and on `sessionWatchStateDidChange`, and reads `receivedApplicationContext` on
the watch's own wake (spec §4 named that property and nothing had ever read it); `WristVessel`
gained `diameter(fitting:within:)`, clamping both dimensions, retiring known issue 21;
`WaterBuddyWatchWidget` takes the same default-goal fallback and counts outbox pours, which put
`WristPlan.swift` into its exception set (five files → **six**) and corrected its
`WATCHOS_DEPLOYMENT_TARGET` from a stray 11.6 to 26.5. **This sync's own drift:** 24 of the 52
line counts in *Files on disk* below were stale and are re-derived; the gate table's phone-unit and
watch-unit figures were a pass behind. Gate re-run in full this session: **300**/33 phone unit,
**25** phone UI, **24**/5 watch unit, both widget builds green. `docs/WIDGET.md` and
`docs/DESIGN.md` were checked and deliberately not touched — the phone widget's contract and the
design tokens did not change, and rule `99-docs-cascade` forbids publishing a doc change nothing
required. Previously: twenty-fourth pass — final whole-branch review, fix round 1. HEAD
was `6cee506`; nothing that pass was committed. Fixed on disk and re-verified with real RED-then-
GREEN evidence: `WristLink`'s silent (would-be) `@MainActor` inference marked `nonisolated`
explicitly, though this toolchain's `SWIFT_APPROACHABLE_CONCURRENCY = YES` turns out to suppress the
diagnostic that would prove the regression — three probe techniques tried, none reproduced a
warning, recorded honestly rather than papered over (`WristLinkReachabilityTests`); the applied
ledger's `acked` truncation now keeps the newest ids under the 256 cap, not the oldest; a failed
existence-read or ledger-decode now declines the whole `ingest(_:)` batch instead of collapsing to
"nothing exists"; the ledger is written only after a successful SwiftData save; four missing
`publishWrist` call sites closed (`saveDailyGoal` unconditionally, `refresh()`'s backstop, the
`language` setter, `AddWaterIntent`'s two initialisers activating `WristLink`); the watch's outbox
now resends its whole pending queue on every pour, not just the newest one; `WristModel.shared` is
now eagerly constructed on both the watch app's `init()` and its `.backgroundTask(.watchConnectivity)`
closure; every `DataManager` test fixture and `#Preview` now injects `publishWrist: { _ in }`, and
the closure's production default now takes its `UserDefaults` as a parameter rather than reading the
shared global; the applied-ledger retention trim no longer strips a just-folded old pour in the same
write that added it; `WristAurora` gained the `if !reduceTransparency` branch its declared sibling
`WidgetAurora` already had; the `WristView` pane that used a bare colour literal now goes through
`.liquidGlass(in: Capsule(), density: .sheer)`. The `@Test` count re-derived at **299** across **33**
suites on the phone side (up from 292 across 31 — one new test,
`savingTheDefaultGoalUnchangedStillPublishesToTheWrist`, and one new suite,
`WristLinkReachabilityTests`, both from `xcodebuild`'s own printed `✔ Test run with 299 tests in 33
suites passed`, not a grep — the attribute-grep in *Counting* below undercounts suites whose
declaration line does not start exactly with `struct`/`final class`), **16** across **5** suites on
`WaterBuddyWatchTests` (up from 15, the new `pouringASecondTimeResendsTheWholeOutboxNotJustTheNewestPour`). `.claude/rules/*.md` and
`docs/*.md` corrected in the same pass, joining Task 17's own still-staged, not-committed doc cascade
— see the entries below and `HISTORY.md`'s own new checkpoint for the full account. Previously:
twenty-third pass — cascade after **the watchOS implementation plan**
(17 tasks, `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md`) landed in full,
`6cee506`. Three new native targets — `WaterBuddyWatch`, `WaterBuddyWatchTests`,
`WaterBuddyWatchWidget` — bring the project to **seven** targets and **four** signed. Two new
phone-side files (`WristPlan.swift`, `WristInbox.swift`) and `WristLink`/`WristBatch`/`WristPour`/
`WristMirror` (declared inside `DataManager.swift`, behind `#if canImport(WatchConnectivity)`) carry
pours to and a mirror from the watch over `WatchConnectivity`, never the App Group — the watch holds
its **own**, physically separate local suite under the identical App Group identifier string. Three
new keys (`Key.wristOutbox`, `Key.wristMirror` — watch-local; `Key.wristApplied` — phone-local)
bring `Key.all` to eleven. The `@Test` count re-derived at **292** across **31** suites on the phone
side, plus a new, separately-gated **15** across **5** suites on `WaterBuddyWatchTests`. The gate is
now **five** invocations across two platforms, re-run in full this session. **Known issues #15 and
#17 retired on evidence** — the two rule files now name the current `role.mayFileReminders`
predicate, and the three `@available(watchOS, unavailable)` markers landed in Task 2 of the
watchOS plan, closing the role model's previously-open compile-time half. Known issue #16 (stale
DocC comments) is **still open** — this is a documentation-only task and cannot touch source; its
line numbers are corrected below, since ~500 lines landed above them. One new known issue: the
watch's own view draws hardcoded English literals rather than routing through `\.strings`, unlike
every phone-side and phone-widget string. Previously: twenty-second pass — cascade after **the process role model** landed
2026-08-31 23:34 with no checkpoint and no doc sync. `isAppExtension` is no longer a guard anywhere:
all six sites read `DataManager.role`, a four-state `nonisolated static let`, and a new *The process
role* section documents it. The `@Test` count re-derived at **259** across **23** suites — the
twenty-third is `ProcessRoleTests`. The gate was re-run in full this session. **Two known issues
retired on evidence:** #8 (shared schemes now exist on disk) and #9 (the documented destination
resolves again — re-probed by running a test, per rule `85-testing`). **One known issue corrected
rather than retired:** #10's closing claim about `theTripwireHelperEnumeratesEveryStoredKey` was
itself false. Three new issues added: two rule files now mandate a guard the code no longer has
(#15), three DocC comments went stale and the fix was declined (#16), and the role model's
compile-time half is unbuilt (#17). Previously: twenty-first pass — cascade after the six test fixtures that reached a real `UNUserNotificationCenter` were closed; known issue #6 retired, the `@Test` count re-derived at **252**, the suite table and the file block updated, the gate re-run in full this session. The known issue's own denominator was two changes stale — it said eight `DataManager(` sites, the tree has eleven — and that is recorded in `tasks/lessons.md`. Previously: twentieth pass — `/doc_sync` verification after the vessels landed; the file block, counts, keys and roster re-derived and already current, one stale code sample in `docs/WIDGET.md` corrected, the Settings cards' contrast measured for the first time. Previously: editable quick-add vessels, an eighth key, and the midnight-entry language bug; the file block, both catalogue counts, the gate, the suite table and the targets table re-derived; the Git section rewritten from `git rev-parse`, which reports no repository; five known issues added)

---


</details>

## What this is

An iPhone hydration tracker on the arc *log → see → log again without opening the app*.
No account and no server.

**Storage is now two stores in one App Group, and the split is the whole design:**

| Store | Holds | Read by |
|---|---|---|
| SwiftData — `WaterBuddy.store` | every ``WaterLog`` (`id`, `amount`, `timestamp`) — the **source of truth** | the app — and, to log a serving, the extension's `AddWaterIntent` through `DataManager.shared`; never the widget's draw path *("the app only" until the forty-ninth pass)* |
| `UserDefaults` — ten keys | today's total, goal, day ordinal, three flags, the chosen language, the three quick-add amounts, the phone's applied-pours ledger, and the version the app last asked for a rating in — a **derived cache** | the app *and* the widget |

Today's total is not stored; it is the sum of today's logs, recomputed after every mutation and
written through to the cache. **The widget's draw path never opens SwiftData.** A `TimelineProvider` carries no
isolation and a `ModelContext` is not `Sendable`, so reading through the cache is what keeps
`HydrationProvider` synchronous and `nonisolated` (rule `43-concurrency`). The cache is never
authoritative — it cannot drift without the log side being wrong first.

**One writer per store**, not "the only writer" full stop — `DataManager` remains the only writer to
the phone's SwiftData/`UserDefaults` pair; `WristModel` is the only writer to the watch's own local
App Group suite, a disjoint key set on a physically separate container (see non-negotiable #23 below,
rules `20-state`/`10-architecture`).

Two front doors, and one serving they must agree on. The app's quick-add row offers three
vessels — Cup 150 ml, **Glass 250 ml**, Bottle 500 ml — and the widget's `AddWaterIntent` offers
one. The middle vessel is whatever the user set it to (`250` ml by default), read from the suite rather
than as a literal, because the widget's face says `+250 ml` and the two must not drift. The three
vessels' names, glyphs and order (`vesselSlots`) no longer live on `HomeView` — Task 14 moved them to
file scope in `WaterSurface.swift`, because `WristView` became a second, non-view consumer of the
identical menu (rule `50-views`). The three *amounts* still live on `DataManager.servings`, unchanged.
Since 2026-10-08 the same intent also sits behind the Control Center control (iOS 18), which reads the
same snapshot; the one-tap doors take the Glass's index from one name, `DataManager.usualSlot`, for
its amount and its glyph — and since stage 2 Home marks its primary disc by it. *(Read "is named
once" until the forty-eighth pass. Two other spellings of the same index exist: a literal `[1]` in
`HistoryView.swift:447` (`:419` until set A's step 5, `:397` until set A's step 4, `:363` until set A's step 3, `:305` until set A's step 2, `:283` until stage 3c, `:271` after stage 3b's
first build, `:240` before it) and the watch's own `primaryIndex = 1`, `WristView.swift:136` — known issue #104.)* *(2026-10-20, 1.3.2's stage 7b, staged: the watch's spelling is gone — `WristView.primary(from:)` and `secondary(from:)` read `usualSlot`; History's `servings[1]` remains.)*

## Targets

| Target | Bundle id | Sources | Status |
|---|---|---|---|
| `WaterBuddy` | `sardor.WaterBuddy` | `WaterBuddy/` | **LIVE** — SwiftUI, `@Observable` `DataManager` over SwiftData |
| `WaterBuddyWidgetExtension` | `sardor.WaterBuddy.WaterBuddyWidget` | `WaterBuddyWidget/` **+ 6 shared files** | **LIVE** — three `StaticConfiguration`s over one provider: the Home Screen widget (small, medium), the week widget (medium; staged 2026-10-20, 1.3.1's 6c) and the Lock Screen widget (circle, rectangle, line); interactive `AddWaterIntent`; and, from iOS 18 behind the codebase's first `if #available`, the Control Center control `LogWaterControl` |
| `WaterBuddyTests` | `sardor.WaterBuddyTests` | `WaterBuddyTests/` | **LIVE** — swift-testing, **931 `@Test` functions in 105 suites, run on 2026-10-24 on *iPhone 17* (27.0) in set A's step 5's gate, on its final code, `test-without-building` after one `build-for-testing`: 929 passed, one skipped by design (#157), one failing by design until the owner's privacy URL (#159)** — step 5 adds 23: `MonthRecapTests` (new, 11), `RecapReadingTests` (new, 6), `RecapImageTests` (new, 5), `PaywallOfferTests` +1 (`PremiumSetTests`' pin renamed, not new); by the attribute grep. Before that: **908 `@Test` functions in 102 suites, run on 2026-10-24 at 00:39 on *iPhone 17* (27.0) in set A's step 4's gate, on its final code: 906 passed, one skipped by design (#157), one failing by design until the owner's privacy URL (`theLinksAreApplesTermsAndAPageOfOurs`, #159)** — step 4 adds 66: `WeekInsightsTests` (new, 31), `InsightsPublishingTests` (new, 7), `InsightCopyTests` (new, 7), `InsightWriterTests` (new, 20), `PremiumSetTests` +1; by the attribute grep. `xcodebuild` then sat after its tear-down until stopped (#180). Before that: **842 `@Test` functions in 98 suites, run on 2026-10-23 at 21:41 on *iPhone 17* (27.0) in set A's step 3's gate, on its final code: 840 passed, one skipped by design (#157), one failing by design until the owner's privacy URL (`theLinksAreApplesTermsAndAPageOfOurs`, #159)** — step 3 adds 27: `MonthPatternsTests` (new, 22), `MonthHistoryTests` +1, `MonthPublishingTests` +1, `MonthLayoutTests` +3; by the attribute grep. Before that: **815 `@Test` functions in 97 suites, run on 2026-10-23 at 01:01 on *iPhone 17* (27.0) in set A's step 2's gate, on its final code: 813 passed, one skipped by design (#157), one failing by design until the owner's privacy URL (`theLinksAreApplesTermsAndAPageOfOurs`, #159)** — step 2 adds 47 (the attribute grep says 815): `MonthHistoryTests` 22 and `MonthPublishingTests` 15, new, and `MonthLayoutTests` 10 in `HistoryViewTests.swift`; the plan's 812 and three for the owner's read-once ruling. Before that: **768 `@Test` functions in 94 suites, run on 2026-10-22 at 10:36 on *iPhone 17* (27.0) in step 1's gate: 766 passed, one skipped by design (#157), one failing by design until the owner's privacy URL (`theLinksAreApplesTermsAndAPageOfOurs`, #159)**, with step 1 staged whole (the attribute grep says 768: +4 — the final review's I1, three in `PremiumStoreTests`, and I2, `aYearlyThatSavesNothingIsNotMarkedBestValue` in `PremiumWordsTests`). Before that: **764 `@Test` functions in 94 suites, run on 2026-10-22 at 00:31 on *iPhone 17* (27.0): 761 passed, one skipped by design (#157), two failing — `theLinksAreApplesTermsAndAPageOfOurs` by design until the owner's privacy URL (#159), and `theTestRunItselfIsNotOfferedThePaywall` because the owner's unstaged scheme edit launches the test host with `-WaterBuddyPremium` (#163; green on a copy of the index)**, with step 1's Tasks 3–7 staged (the attribute grep says 764: +30 — `PremiumAccessTests` +8, `PremiumWordsTests` +4, `PaywallOfferTests` +1, `PaywallScreenTests` 4, `PremiumSetTests` 4, `PremiumStoreTests` +6, `StoreKitSessionTests` +3). Before that: **734 `@Test` functions in 92 suites, run on 2026-10-21 at 19:38: 732 passed, one skipped by design (#157), one failing by design until the owner's privacy URL (`theLinksAreApplesTermsAndAPageOfOurs`, #159)**, with 1.4.1's Task 6 and its review fix staged (the attribute grep says 734: +5 — `PaywallOfferTests` 4, and `openingTheSheetAgainWhileBuyingKeepsThePurchase` in `PremiumStoreTests`). Before that: **729 `@Test` functions in 91 suites, all run on 2026-10-21, one skipped by design (#157)**, with 1.4.1's Tasks 3–5 staged (the attribute grep says 729: +46 — `PremiumAccessTests` 14, `PremiumWordsTests` 5, `PremiumStoreTests` 18, `StoreKitSessionTests` 8, `PremiumStringTests` 1). Before that: **683 `@Test` functions in 86 suites, all run on 2026-10-20** in 1.3.2's stage 7b gate (the attribute grep says 683; 7b added the face's six to `WristPlanTests`). Before that: **677 in 86, all run on 2026-10-20** in 1.3.2's stage 7a gate (the attribute grep said 677; the seventy-sixth pass found this row still at 1.2.5's figure — roadmap items 1.2.6 to 1.3.1 added the 61 since, and their rows in *Files on disk* name them). Before that: **616 `@Test` functions in 77 suites, all run on 2026-10-15** (roadmap item 1.2.5 added twelve, in two new suites — `ReviewRequestTests` 8 and `ReviewPromptTests` 4; 604 in 75 before it, when 1.2.4 had added eleven; 593 on 2026-10-14) (36 are the redesign's stage 5, staged: six new suites — `ReminderPermissionTests` 7, `WelcomeStepTests` 8, `WelcomeFinishTests` 6 and `FreshStartTests` 2 in the new `WelcomeTests.swift`, `GoalSuggestionTests` 12 in its own file, and `WelcomeStringTests` 1 in `LocalizationTests`; `DailyGoalSetupTests` reads `WelcomeView`'s menu). Before that: **557 `@Test` functions in 69 suites, all run on 2026-10-13** (one is the redesign's stage 4, staged: `theVesselsNoteNamesTheGlassByItsOwnName` in `LocalizationTests`). Before that: 556 `@Test` functions in 69 suites, all run on 2026-10-13 (9 are the redesign's stage 3c, staged: one new suite — `LiquidGlassScrimTests` 4 — one test more in each of `LiquidGlassRoutingTests`, 10, and `PrimarySurfaceTests`, 2, and three more in `HistoryLayoutTests`, 17; recounted per suite by script in the fifty-seventh pass). Before that: 547 `@Test` functions in 68 suites, all run on 2026-10-12 (47 are stage 3b's second pass, unstaged: four new suites — `MotionTests` 6, `PageTurnTests` 13, `PourArcTests` 6, `ScrollDepthTests` 16 — four more in `ArrivalTests`, 10, and two more in `HistoryLayoutTests`, 14). Before that: 500 in 64 suites, all run on 2026-10-12 (21 are the redesign's stage 3b, unstaged: four new suites — `ScreenMetricsTests` 4, `ArrivalTests` 6, `BarShadeTests` 3, `AuroraDriftTests` 6 — and one test more in each of `HapticLadderTests` and `HomeLayoutTests`). Before that: 479 `@Test` functions in 60 suites, all run on 2026-10-11 (35 tests are the redesign's stage 3, staged: four new suites — `DaysMetTests` 8, `DayFractionTests` 9, `HistoryLayoutTests` 12, `HistoryStringTests` 3 — and one test more in each of `HistoryWindowTests`, `HistoryServingTests` and `GroupedFigureTests`. Stage 2's 57 in eight suites were committed in `1ced514`: `UndoTests`, `HomeFiguresTests`, `DayTurnTests`, `StreakCountTests`, `StreakPublishingTests`, `HomeLayoutTests`, `HomeStringTests`, `GroupedFigureTests`; stage 1's `LiquidGlassRoutingTests` and `PrimarySurfaceTests` in `c9ef45d`). *(Read 444 in 56 until the fiftieth pass; 387 in 48 until the forty-seventh — the forty-sixth updated the header and the gate and left this row.)* |
| `WaterBuddyUITests` | `sardor.WaterBuddyUITests` | `WaterBuddyUITests/` | **LIVE** — **61 `func test`, unchanged by set A's step 5 (no UI run can hold Premium, so the recap has none). Its gate, 2026-10-24, on the final code, `test-without-building`, by class and in chunks of at most thirteen: on *iPhone 17* (27.0), 74 executed, 1 skipped (#157), 1 failure — `WelcomeUITests.testAStepIsAsItWasLeftWhenBackReturnsToIt`, #140's lost tap on *Active*, which passed alone; on *iPhone 17* (26.5), 74 executed, 1 skipped, no failure.** Before that: **61 `func test` (counted at the start of a line, as before): set A's step 4 adds `testAFreeUsersInsightsAreLockedAndOpenThePaywall`. Its gate, 2026-10-24, on the final code, class by class (the whole run passes 600 s): on *iPhone 17* (27.0), 74 executed, 1 skipped (#157), no failure — the new test's first class run had failed on an ambiguous *History* tap straight after the welcome, passed alone, and taps its first match now; on *WaterBuddy Gate 26.5*, 74 executed, 1 skipped, 1 failure — `testADoubleTapMovesOneStep`, the welcome's, at a load of ~140, which passed alone.** Before that: **60 `func test`, unchanged by set A's step 3. Its gate, 2026-10-23, on the final code, under two other projects' load (80–190): on *WaterBuddy Gate 27*, 73 executed, 1 skipped, 1 failure — `testAnOlderPoursTimerDoesNotEndANewerOffer`'s own speed guard (8.44 s against 6.5), which passed alone at a load of 6; on *WaterBuddy Gate 26.5*, 73 executed, 1 skipped, 2 failures — `testAnOrdinaryRunHasNoPremiumCard` and `testUseSetsTheGoalItSuggests`, each a 5-second wait, both passed alone at a load of 11.** Before that: **60 `func test`: set A's step 2 adds two to `PremiumUITests` (`testAnOrdinaryRunsHistoryHasNoMonthSwitch`, `testAFreeUsersMonthIsLockedAndOpensThePaywall`). Its gate, 2026-10-23, on the final code, each of three runs started at a 1-minute load of 8 or under: on *WaterBuddy Gate 27*, 73 executed, 1 skipped, 0 failures; on *WaterBuddy Gate 26.5*, 73 executed, 1 skipped, 0 failures — `PremiumUITests` among them on 26.5 (#166).** Before that: **58 `func test`, unchanged by step 1. Its gate, 2026-10-22, under another session's load (7 to 196): on *WaterBuddy Gate 27*, 71 executed, 1 skipped, two failures that passed alone — Home's *Undo* timing pair, #115's family; on *WaterBuddy Gate 26.5*, 71 executed, 1 skipped, five failures that each passed on re-run — two at Home's first Glass (one passed only after a `HEAD` export's run, then three times), #140's pair, and `PremiumUITests` on its first runs there (#166).** Before that: **58 `func test`, unchanged by step 1 (2026-10-22), whose Task 7 rewrote `PremiumUITests`' two: that class alone run on *WaterBuddy Gate 27* at 00:29, `Executed 2 tests, with 0 failures`; the whole UI suite not run since 2026-10-21.** Since 1.4.1's Task 6 (staged 2026-10-21): `PremiumUITests`, 2, the only class launched with `-WaterBuddyPremium`. Run 2026-10-21 on *WaterBuddy Gate 27*, three runs: 71 executed, 1 skipped, 1 failure — `WelcomeUITests.testUseComesBackWhenTheGoalIsMovedAway` at `:355`, #140's flake, failing as often on a `HEAD` export under the same load spikes; on *WaterBuddy Gate 26.5*: 71 executed, 1 skipped, 0 failures.** Before that, **since the redesign's stage 5, staged 2026-10-14: a new class, `WelcomeUITests`, 13 tests on the DEBUG fresh start (the welcome walked forward and back, each control one element, the largest text size, the shared walk, a vessel set in the welcome and one edited in Settings read back on Home, a step's title where a tab's stands, a double tap moving one step, and five for the calculator); `GoalSetupUITests` still has 36, its eleven *Get Started* preambles now `completeWelcomeIfShown(_:)`; 54 declared, 67 executed a system, one of them skipped.** Before that, **since the redesign's stage 4, staged 2026-10-13: `GoalSetupUITests` has 36 tests, 41 declared, 54 executed a system, one of them skipped** — two more, that Settings draws the new vessels note and that each of its controls is one element. Before that, **since the redesign's stage 3c, staged 2026-10-13: `GoalSetupUITests` has 34 tests, 39 declared, 52 executed a system, one of them skipped** — one more, `testEveryDayOnTheWeekCardIsATapTarget`, that each of the week card's days is at least 44 × 44. Before that, **since stage 3b's second pass, unstaged 2026-10-12: `GoalSetupUITests` has 33 tests, 38 declared, 51 executed a system, one of them skipped** — one more, that only the page shown is in the tree once a change of tab has ended. Before that, **since the redesign's stage 3b, unstaged 2026-10-12: `GoalSetupUITests` has 32 tests** — seven more, for the title's place (two), a screen coming back whole, a kept screen answering a tap, the drag along Apple's bar, the app's own bar's captions, and History returning to today — **37 declared, 50 executed a system, one of them skipped** (the caption test where the bar is Apple's, the drag test where it is the app's own), and the class runs in chunks (#110). The text that follows is the fiftieth pass's. — `GoalSetupUITests` (25 real tests; the ninth, committed in `c9ef45d`, taps a serving row on its bare glass; eleven are stage 2's, committed in `1ced514`: Home's heading, the two "never squeezed" checks, and *Undo*; five are stage 3's, staged: the strip's heading, the sheet's shortcuts, and three at the largest text size — the shortcuts' figures, a row's amount, a past day's heading), the Xcode template's 3, and `AppStoreScreenshotUITests`' 2 capture harnesses. **30 declared, 43 executed** — the 2 harnesses are skipped by the gate, and `testLaunch` runs once per launch configuration. Since stage 3 the target runs as two invocations, 25 and 18: one no longer fits a 600-second foreground call (known issue #110). *(Read "20 real tests … 25 declared, 38 executed" until the fiftieth pass; "9 real tests … 14 declared, 27 executed" until the forty-seventh.)* |
| `WaterBuddyWatch` | `sardor.WaterBuddy.watchkitapp` | `WaterBuddyWatch/` **+ 6 shared files** | **LIVE** — SwiftUI, `@Observable` `WristModel` over its own local App Group suite; no SwiftData |
| `WaterBuddyWatchWidget` | `sardor.WaterBuddy.watchkitapp.WaterBuddyWatchWidget` | `WaterBuddyWatchWidget/` **+ 6 shared files** | **LIVE** — `.accessoryCircular` percentage ring, reads the watch's own suite directly *(2026-10-21, 1.3.2's stage 7c, staged: three faces — the circle, `.accessoryRectangular` and `.accessoryCorner` — drawn by `WristFaceView` from `WristPlan.Face`, in the phone's chosen language, every figure `.privacySensitive()` with a quiet form; still display-only)* |
| `WaterBuddyWatchTests` | `sardor.WaterBuddyWatchTests` | `WaterBuddyWatchTests/` | **LIVE** — swift-testing, **70 `@Test` functions in 7 suites, unchanged by set A's step 5, all run and passed on 2026-10-24 in its gate**; before that, **unchanged by set A's step 4, all run and passed on 2026-10-24 at 01:23 in its gate**; before that, **all run and passed on 2026-10-23 at 22:09** on *Apple Watch Series 12 (46mm)* (watchOS 27.0) in set A's step 3's gate — unchanged by it. Before that: **70 `@Test` functions in 7 suites, all run and passed on 2026-10-23 at 01:46** on *WaterBuddy Watch 27* (watchOS 27.0) in set A's step 2's gate — unchanged by it. Before that: **70 `@Test` functions in 7 suites, all run and passed on 2026-10-22 at 11:50** on *WaterBuddy Watch 27* (watchOS 27.0) in set A's step 1's gate — unchanged since 1.3.2's stage 7b (the attribute grep says 70). Before that: **70 `@Test` functions in 7 suites, all run on 2026-10-20** on watchOS 27.0 in 1.3.2's stage 7b gate (7b: +1 in `WristModelTests`, +5 and one rewritten in `WristViewLogicTests` with the scrim's one replaced by two, and in `WristVesselLayoutTests` two removed and seven added). Before that: 58 in 7 (1.3.2's stage 7a added `WristGlassTests`, 1). Before that: 57 in 6 suites |

Every target's sources come from a `PBXFileSystemSynchronizedRootGroup`, so a new `.swift` file
dropped in a folder joins that target with no project edit. `xcodebuild -list` reports **four**
schemes for these seven targets, not seven: `WaterBuddy`, `WaterBuddyWatch`, `WaterBuddyWatchWidget`,
`WaterBuddyWidgetExtension` — each `*Tests` target is driven by `-only-testing:` against the scheme
of the app that hosts it, with no scheme of its own (rule `15-project`).

### The six shared files — and two more exception sets besides

`project.pbxproj` now carries **three** `PBXFileSystemSynchronizedBuildFileExceptionSet`s, not one
— the `target` field on each is scalar, so a single set can never serve two targets:

Verified against `project.pbxproj` → `PBXFileSystemSynchronizedBuildFileExceptionSet`
(target `WaterBuddyWidgetExtension`, unchanged by this plan):

```
DataManager.swift
LiquidGlassModifier.swift
NotificationManager.swift
ReminderPlan.swift
WaterLog.swift
WaterSurface.swift
```

**`WaterBuddyWatch`'s own set (six files, not the widget's — a different roster):**

```
DataManager.swift
LiquidGlassModifier.swift
ReminderPlan.swift
WaterLog.swift
WaterSurface.swift
WristPlan.swift
```

Omits `NotificationManager.swift` — `role.mayFileReminders` is `false` on both watch roles, so
shipping the notification surface to a process that can never file one is pointless. Adds
`WristPlan.swift`, absent from the widget's set, because `WristModel` buckets pours through it.

**`WaterBuddyWatchWidget`'s own set (six files — the watch app's roster, by the same reasoning):**

```
DataManager.swift
LiquidGlassModifier.swift
ReminderPlan.swift
WaterLog.swift
WaterSurface.swift
WristPlan.swift
```

Omits only `NotificationManager.swift` (same reason). `WristPlan.swift` joined on 2026-09-01, when
spec §16 made the complication count pending outbox pours, and since spec §17 it is also what tells
the complication when the phone's total stops counting and where to schedule its timeline entries —
the same function the watch app reads, so the face and the screen cannot disagree. *(This block said
five files, and that the widget "never buckets pours itself", until the twenty-eighth pass — stale
for that whole month; `project.pbxproj` has carried six since 2026-09-01.)*
`LiquidGlassModifier.swift` is required only **transitively**: nothing the widget draws calls
`.liquidGlass(...)` directly, but `WaterSurface.swift`'s own `#Preview` does, and a `#Preview` still
has to compile into whatever target the file joins.

The watch's own files — `WristModel.swift`, `WristView.swift`, `WristAurora.swift`,
`WristVessel.swift`, `WaterBuddyWatchApp.swift` — are invisible to both widget extensions and vice
versa. Reaching one from the other is a target-membership compile error the relevant scheme's own
green test run cannot show (rule `15-project`).

`ReminderPlan.swift` and `NotificationManager.swift` joined the widget's set because `AddWaterIntent` reschedules
reminders **from the extension**, and `perform()` is the only place that work can be awaited.

`WaterLog.swift` joined the list with the SwiftData move: `DataManager` is shared and references
the model, and `AddWaterIntent` runs **in the extension**, so the widget process genuinely inserts
rows. Both processes open the same store file in the App Group container.

They live in `WaterBuddy/` and compile into **both** phone targets — and five of the six, all but
`NotificationManager.swift`, into the two watch targets as well, so most of them are in four
binaries (the exception sets above). Of everything else under
`WaterBuddy/`, **`WristPlan.swift` is shared too — with the two watch targets, not with the
widget** (the two watch exception sets above) — and the other twenty-three are app-only:
`RootTabView.swift`, `HomeView.swift`, `WaterBuddyApp.swift`,
`HistoryView.swift`, `SettingsView.swift`, `AuroraBackground.swift`, `PressStyle.swift`,
`Celebration.swift`, `Haptics.swift`, `LogServingIntent.swift`, `WaterBuddyShortcuts.swift`,
`WristInbox.swift`, stage 3b's six — `Arrival.swift`, `ScreenHeader.swift`, `Motion.swift`,
`PageTurn.swift`, `PourDrop.swift` and `ScrollDepth.swift` — and stage 5's four, `WelcomeView.swift`,
`GoalSuggestion.swift`, `ReminderPermission.swift` and `VesselSliders.swift`, and 1.2.4's
`ReminderResponder.swift`. *(1.2.4, 2026-10-15: it said twenty-two; the folder is 30 files in the
index.)* *(Stage 5, 2026-10-14:
it said nineteen and named `GoalSetupView.swift`, which the stage deleted; the folder is 29 files
in the index, less the six and `WristPlan.swift`.)* *(Until the forty-seventh pass this
sentence listed eight files and called "everything else" app-only, `WristPlan.swift` included;
until the fifty-fourth it said thirteen and left out stage 3b's six, which the file table below
had as app-only all along — a fresh reader counted the folder: 26 files, less the six and
`WristPlan.swift`.)* Editing one of the
six edits at least two processes, and four for all but `NotificationManager.swift`; adding a
seventh means editing that list.

## Files on disk

*Line counts re-derived with `wc -l` on 2026-10-14 (fifty-eighth pass), every row against its file
by a script: none stale — the three stage 4 moved had been re-counted by its own session. In the
notes below, "staged 2026-10-11, the redesign's stage 3" was committed on 2026-10-13 as `e0762ab`;
"unstaged 2026-10-12, stage 3b" (both passes) as `7368dec`; and, the same day, "2026-10-13, stage
3c, staged" as `a58b9e6` and the App Store header's "staged 2026-10-13" (its two rows only) as
`6499619`. No note that names stage 4 is committed: its rows say "staged 2026-10-13", when the
stage first staged its files, or — `SettingsView.swift`'s — "2026-10-14", when that file was last
re-staged, after midnight. Stage 4 was committed on 2026-10-14 as `4e70235`.*

*Re-derived with `wc -l` on 2026-10-15 for roadmap item 1.2.5 (staged, not committed): two new
files have rows (`ReviewPrompt.swift`, `ReviewRequestTests.swift`) and five changed ones a new count
and a note (`DataManager.swift`, `HomeView.swift`, `RootTabView.swift`, `WaterBuddyApp.swift`,
`DataManagerTests.swift`). 87 tracked `.swift` files with the two staged (`git ls-files`).*

*Re-derived again with `wc -l` on 2026-10-14, for the redesign's stage 5 (staged, not committed):
`GoalSetupView.swift` is deleted and its row gone; four new app files and three new test files have
rows; the eleven existing Swift files the stage changed have a note on their rows, seven of them
with a new count, and `NotificationManager.swift`'s row a moved citation; a note that says "stage
5" names this staging.*

*(2026-10-17, the sixty-fifth pass: both stagings above are committed — stage 5's Swift files in
`2af8dbc`, 1.2.5's in `86a44ed` — so a row's "stage 5" or "1.2.5" now names a commit. The rows
re-checked against their files, 86 by script and one by hand: none stale.)*

```
WaterBuddy/Arrival.swift                         154   app only — unstaged 2026-10-12, stage 3b; rewritten by its second pass: Arrival (rise 14, stagger 0.05, hiddenOpacity never zero, and the pure opacity(arrived:settles:) and lift(arrived:settles:reduceMotion:)), EnvironmentValues.pageSettlesIn — true for the page the app opens on, false for every page a turn brings in, whose sections are whole as it slides (History's bars read the flag and not this, and grow on every page) — View.arrives(_:order:) and View.tracksArrival(_:), a task that sets the flag 50 ms after the page is built. isShownTab is gone
WaterBuddy/AuroraBackground.swift                235   app only — the moving backdrop: RootTabView's one for the three tabs since stage 3b's second pass, and the first-run screen's and the serving sheet's own (stage 5: a comment names WelcomeView for the first-run screen); unstaged 2026-10-12, stage 3b: AuroraClock and AuroraDrift, a CustomAnimation that places a light by one clock every copy reads; staged 2026-10-11, the redesign's stage 3: legibleOnBackdrop(), the two shadows for text that sits straight on it, moved in from HomeView now that History draws on it too
WaterBuddy/Celebration.swift                     213   app only — ConfettiPiece, the seeded burst, the overlay
WaterBuddy/DataManager.swift                    4258   shared — (2026-10-24, set A's step 5, staged: `MonthHistory.recap: Neighbour?` — the month a page offers, worked out in `make` — `recapDays`, `Identifiable`; `recap(of:)`, a read; `readMonth(_:)`, the month's two reads spelled once for `republishMonth()` and `recap(of:)`; 4,195 lines before) (2026-10-24, set A's step 4, staged: `WeekInsights` at file scope after `MonthPatterns` — the last finished week against the week before, the three parts, the suggestion; `insights`, `showInsights(_:)`, `republishInsights()` — the ninth guard site — beside each `republishMonth()`; `MonthPatterns`' `usual`, `instant`, `saturating`, `saturatedSum` private → file-private, shared rather than copied) (2026-10-23, set A's step 3, staged: `MonthPatterns` at file scope, `nonisolated`, beside `MonthHistory` — each hour's water, the busiest hour, each weekday's tally, the usual first and last drink, `split(weekend:)`, `minuteOfDay`; `MonthHistory.patterns`, built in `make` from the same rows; no new property, read or call site) (2026-10-23, set A's step 2, staged: `MonthHistory` at file scope, `nonisolated`, beside `DaySummary` — a month's days, counts, best run, total, average, change and neighbours from its rows, the first serving and the goal; `month`, `monthLogs` and `thisMonth` published, `showMonth(_:)`, `republishMonth()` and `readOldestLog()`, called from the `dailyGoal` setter, `dayDidTurn()`, `refresh()` and `saveAndRecompute()`, never `init`; `addLog` and `removeWater` re-read through the private `refresh(republishingMonth: false)`, the owner's read-once ruling) (2026-10-21, 1.4.1's Task 6, staged, DocC only: `claimReviewRequest`'s note names rule `70-privacy`'s *StoreKit, for the review request and for Premium*; the count unchanged; both widget schemes built after it) (2026-10-19, 1.3.1 6c, staged: `Key.weekTotals` and `readWeekTotals(from:)`, both nonisolated — the week validated on the way out and discarded whole, and each day clamped on the way in by `cacheWeek` (the final review's fix); `recomputeTodayAndTheWeek()` in `init` and `saveAndRecompute()`, `republishHistory(cachingTheWeek:)` and `cacheWeek` — one doorbell a pass; `DaySummary.window`, the one walk the card and the widget share; `WaterSnapshot.weekTotals` (nonisolated) and `week(endingOn:calendar:)`; `WidgetLink`; 3026 lines before) (2026-10-18, 1.3.4, staged: WaterSnapshot gains remaining and hasReachedGoal, nonisolated — the snapshot's twins of the manager's, for TodaysWaterIntent.answer(for:); 3005 lines before) (2026-10-18, the lag fix, change B: closedRun keeps the run of days before today; readStreak adds today's share; readClosedRun counts it by the old walk; forgetClosedRunIfNotToday in addLog, deleteLog and updateLog, ingest forgets it for another day's pour, dayDidTurn always.) (2026-10-17, 1.2.6: Bundle.localized(_:_:locale:), nonisolated, beside figure — every sentence with an argument that figure does not take now goes through it; figure's DocC no longer says spoken strings keep %d.) (2026-10-15, 1.2.5: Key.reviewRequestedVersion, in Key.all; reviewStreak = 3, the pure mayRequestReview(reachedToday:streak:askedVersion:version:) and claimReviewRequest(version:), which writes the version before it answers true — no new import; 2866 lines before) (2026-10-15, 1.2.4: the language setter re-plans the reminders; requestReminderReschedule's queued operation reads the bundle once and registers the reminder's category before it reconciles; AppLanguage.bundle is nonisolated; 2846 lines before) (stage 5: comments only — the first-run screen named as WelcomeView where it was GoalSetupView; 2845 lines before) (2026-10-11, `1ced514`: addLog returns the row's id and undoLog(id:) takes it back; remaining, hasReachedGoal, lastDrink and nextReminder, derived on read; the published streak and its growing windows; dayDidTurn(), which the two day-change observers call; Bundle.figure for grouped volumes. Staged 2026-10-11, the redesign's stage 3: DaySummary.reached(_:) and daysMet(in:goal:); dayFraction(of:) and hours(_:onDayOf:) — where an instant falls in its day, by that day's real length — each a nonisolated static over a calendar with an instance wrapper) the model, the log CRUD (updateLog takes a time), the window's published rows (historyLogs) and where the window starts (historyWindowStart), the cache, WaterSnapshot, DaySummary, AppLanguage, the four-state Role, usualServing(in:) (the Glass — the widget's, Siri's, the control's and, since 2026-10-15, the reminder button's one definition) at usualSlot (its index — one of three spellings, known issue #104), requestWidgetReload() (timelines and, on iOS 18, controls), remindersSettled() (not on watchOS), the Wrist wire structs and WristMirror.isNews(since:), WristLink (behind #if canImport(WatchConnectivity)) — its push to the face and waitUntilActivated() on iOS, its wait for delivery on watchOS, poll on both
WaterBuddy/GoalSuggestion.swift                  123   app only — stage 5: the calculator's arithmetic, pure and in whole millilitres — Unit (kilograms 30...200 from 70, pounds 66...440 from 155; starting(for:) is pounds only where the locale measures in US units; convert(_:to:)), Activity (adds 0 / 350 / 700), goal(weight:unit:activity:) rounded half up to WelcomeView.goalStep and held to goalRange
WaterBuddy/Haptics.swift                          66   app only — the feedback ladder: three rungs, and unstaged 2026-10-12, stage 3b, two more — select (the system's selection tick) and remove (a light impact at confirm's intensity)
WaterBuddy/HistoryView.swift                    3535   app only — (2026-10-24, set A's step 5, staged: `RecapRow`, the recap's `.sheet(item:)` and its `#Preview` of the first-week row; `drawnChange`, `spokenChange`, `changeSymbol` lifted from `MonthFigures` to `nonisolated static`s the card shares; 3,428 lines before) (2026-10-24, set A's step 4, staged: `HistoryMode.insights`; `ModeSwitch` three segments, scrolling where they overflow; `insightsRows`, `insightPanes`, `insightsRequest`, `weekRange(from:to:locale:)`; `InsightsHeading`, `OneThingPane`, `InsightPane`, `InsightFooter`, `InsightsPending`, `DrawnInsight`; `LockedMonth` → `LockedPage(kind:)`; the previews inject a silent `InsightWriter`) (2026-10-23, set A's step 3, staged: Month mode's patterns after the figures — `PatternsHeading`, `HoursChart`, `WeekSplit`, `UsualTimes`, `PatternsPending`; `weekend(in:)`, `hourPosition(_:)`, `hourBars(_:)`) (2026-10-23, set A's step 2, staged: *Week · Month* under the header, drawn where `offersMonth(status:offered:)` says; Month mode — the month card, an opened day read-only under it, the figures; a free user's locked month over a drawn one, opening the paywall with `.history`; `ServingRow.edit` optional, `nil` read-only; `MonthStyle`, `ModeSwitch`, `MonthCard`, `OpenedDayHeading`, `MonthFigures`, `LockedMonth`, `DrawnMonth`; five `nonisolated` statics; the month let go in `.onDisappear`, the owner's ruling on the final review's I1/I2) (2026-10-17, 1.2.6: seven sentences through localized; ServingSheet and DayStrip read the locale; DayStrip's heading speaks *5 servings* as its value and draws the count trailing it, or under it where both do not fit; its DocC cites #139.) (stage 5: comments only, naming WelcomeView where they named GoalSetupView) (2026-10-13, stage 3c, staged: the week card's rounded tracks and bars on LiquidGlass.innerCornerRadius, the dashed goal line (GoalLine), a ring on the shown day's track and a white disc behind its letter placed from LetterCentres anchors in place of the gliding capsule, letters white and the shown one Aurora.top heavy, the disclosure 0.88; DayRow lays the days out inside dayRowInset(across:count:) — 16, or 9.5 on a 375-pt phone — with daySlot(across:count:) and dayTapFloor; a serving's glyph white on an Aurora.cyan 0.16 wash) (second pass of stage 3b, unstaged 2026-10-12: no backdrop of its own; markerOffset(ofDay:among:across:) and one capsule that glides to the shown day; DayStrip grows its bars again when the day changes (not under Reduce Motion); every row recedes through historyRow's scrollDepth(); the sheet's shortcut lozenge lands; the onDisappear reset is gone — a page is rebuilt) unstaged 2026-10-12, stage 3b: the header is ScreenHeader, everything under it arrives, the bars grow as it does, a tick for a day picked and a light tap for a serving swiped away, back to today in onDisappear; staged 2026-10-11, the redesign's stage 3: one List whose rows are the header (the day at .largeTitle, its total against the goal, the +; a past day on two lines at an accessibility text size), the week card that picks the day (cyan for a day that reached the goal, white for one that did not; Average, Best day, Goal met), DayStrip (When you drank: a bar per serving by time of day, hour labels at 6, 12 and 18, a bell at the next reminder) and the servings (ServingRow: the vessel's glyph in a dark well, the amount, the vessel's name, the time; two layouts); swipe-to-delete; the + and one add/edit sheet with three vessel shortcuts under the slider and a day · hour · minute wheel; StripBar at file scope and the statics stripBars(for:vessels:), vessel(forAmount:amounts:), sliderBounds(forAmount:vessels:) (2026-10-10, `c9ef45d`: Save on the primary surface; the shown day reads LiquidGlass.Selection; the goal line at white 0.55)
WaterBuddy/InsightCopy.swift                     113   app only — new 2026-10-24 (set A's step 4, staged): `InsightCopy`, `nonisolated`, `Foundation` alone — the one mapping from a `WeekInsights.Finding` and a suggestion to the app's own sentences, `InsightCopy.Page`; History draws it, `InsightWriter` hands its English to the model
WaterBuddy/InsightWriter.swift                   270   app only — new 2026-10-24 (set A's step 4, staged): `InsightWriter`, `@MainActor @Observable`, the one `import FoundationModels`; `Source` (`live()`: `SystemLanguageModel.default` only, greedy; `silent()`), `accepts(_:for:)` part by part, `speaksEnglish(_:main:)`, `prompt(for:)`, `Retry`; notes kept in memory for the run
WaterBuddy/HomeView.swift                       1234   app only — (2026-10-21, 1.4.1's Task 6, staged, DocC only: the rating request is "one of StoreKit's two uses", and rule `70-privacy`'s section is named *StoreKit, for the review request and for Premium*; the count unchanged) (2026-10-18, the lag fix, change A: the vessel's clock runs only while WaterMotion says the water moves, and never while the app is not active; motionStart and restingPhase change together in one onChange; the slosh shares WaterMotion.settling.) (2026-10-17, 1.2.6: five sentences through localized; the streak chip draws *12 days* — a ViewThatFits of two streakCapsules, the count alone where the noun does not fit — and speaks the noun at every size.) (2026-10-15, 1.2.5: import StoreKit — the only file that does; requestReview and pageIsShown read; goalPours and ratingWait; pour(_:) counts a crossing it made; askForARating(after:) waits ReviewPrompt.pause, re-checks, claims, asks; 1138 lines before) (stage 5: a comment only, naming WelcomeView) (2026-10-13, stage 3c, staged: WaterVessel's glow, halo and highlight — the Depth ratios from the canvas — none of them under Reduce Transparency) (second pass of stage 3b, unstaged 2026-10-12: no backdrop of its own; a drop from the pressed disc to the vessel — anchors gathered by PourPlaces, flights, land(_:) — and the vessel's swell; the level on Motion.water; the Undo capsule and the streak chip land, each animation scoped to its own view; the onDisappear reset is gone) unstaged 2026-10-12, stage 3b: the header is ScreenHeader with the date under the title (dateFormat, dateScaleFloor 0.45), the vessel, status and row arrive, a disc's glyph bounces when poured, Undo ends in onDisappear; 2026-10-11, `1ced514`, the redesign's stage 2: the date, the title and the streak chip; the vessel, sized by HomeColumn (a Layout) between vesselFloor and a ceiling that scales with text; the status line; the quiet line (next reminder, last drink) that Undo replaces for eight seconds, in three forms chosen by fit; the ranked quick-add row — the Glass on the primary surface, Cup and Bottle on glass in one glassGroup; UndoOffer; the goal burst (vesselSlots moved out, Task 14; legibleOnBackdrop moved out to AuroraBackground.swift, staged 2026-10-11)
WaterBuddy/LiquidGlassModifier.swift             893   shared — (2026-10-20, 1.3.2 7a, staged: Apple's glass on the watch — systemGlassAvailable, sampling(_:)/systemGlass and GlassGroupModifier behind #available(iOS 26.0, watchOS 26.0, *), every #if os(iOS) round them gone; six DocC passages that put the watch on the hand-made stack, or the glass on iOS alone, corrected) design tokens + the glass modifier; 2026-10-13, stage 3c, staged: Apple's glass tinted with systemTintColor (Aurora.top) at systemTintOpacity 0.64, the hand-made sheen and lit rim laid over it (litSurface), scrim(density:scheme:base:onPhone:) in place of Density.scrimOpacity(for:) — Aurora.top 0.30 / 0.70 / 0.80 for the phone's own panes, black 0.16 / 0.28 / 0.40 for the widget's .archived base and the watch — runsOnPhone, Selection.ringOpacity / ringWidth / discFill, innerCornerRadius; 2026-10-11, `1ced514`: routed branches on the pane's base only, and a .material pane on iOS 26+ always carries glassEffect — .identity when it is not Apple's — so a setting never moves a pane's content (#91a); .glassGroup(), Apple's GlassEffectContainer on iOS 26+ and nothing elsewhere; committed 2026-10-10 in c9ef45d: the routing (rendering, systemGlassAvailable, systemVariant), Apple's glass on iOS 26+ behind #if os(iOS) + #available, darkened by systemTintOpacity(for:) (0.52 regular, 0 clear) and given its hit region by .contentShape(shape), LiquidGlass.Primary and primarySurface(in:ring:), LiquidGlass.Selection
WaterBuddy/LogServingIntent.swift                 90   app only — the Siri phrase's intent ("Log a Glass"): logTheGlassInTheBackground() — wait for the watch link, logTheGlass, wait for the reminder queue — then reply "Water logged." (2026-10-15: the three steps moved into logTheGlassInTheBackground(), which the reminder's button runs too; 78 lines before)
WaterBuddy/Motion.swift                           93   app only — unstaged 2026-10-12, stage 3b's second pass: Motion, the curves by name — page (.smooth 0.45), pageFade (0.25, under Reduce Motion), settle (0.3), land (spring 0.5 / 0.68) and landSpring, water (spring 0.8 / 0.62), drop (easeIn 0.42) — and the plain numbers behind them. Fifteen older call sites still write .smooth themselves (sixteen until stage 5 deleted GoalSetupView's)
WaterBuddy/NotificationManager.swift             395   shared — (2026-10-15, 1.2.4: ReminderScheduler is nonisolated, reads pending requests back as PendingReminder — identifier, title, body, category — and gains setCategories; the reminder's category and its one action, Log a Glass, as reminderCategoryIdentifier / logTheGlassActionIdentifier / reminderCategory(in:); reconcile files again a pending reminder whose words differ; 283 lines before) ReminderScheduler + reconcile, the only code that files, removes or asks permission (SettingsView.swift:266 since set A's step 1, :242 since the redesign's stage 5, :254 after stage 4, :240 before it — :234 after stage 3b's first build, :225 before it — also reads the centre's settings directly, for the Notification Summary line; it has since the first commit, and this row said "the only UN caller" until the forty-eighth pass); ReconcileQueue, which runs the app's reconciles one at a time in call order (known issue #46), and settled(), which waits for it to drain
WaterBuddy/PageTurn.swift                         94   app only — unstaged 2026-10-12, stage 3b's second pass: PageTurn, a change of tab as a value — the page shown, the page leaving, which way the shown one came, and how many turns have been made; mounted (two pages at most, in the bar's order), offset, entry, opacity, and settle(_:), which ends a turn by its number
WaterBuddy/PaywallView.swift                     654   app only — (2026-10-23, set A's step 2, staged: `Entry.history`, the locked month's way in) (2026-10-22, step 1's Task 8, staged, from the walk and the colour pairs: the subtitle, the four feature rows and the included line on **one `.frosted` card**, the title alone on the aurora with `legibleOnBackdrop()` — so is every other line there; the glyphs `Aurora.cyan` in a scaled 28-pt box (ceiling 42), no tiles, `tint(_:)` gone; **BEST VALUE the yearly tile's first line**, white — its pill, `badgeLift` and `tileTop` gone — with an invisible copy in the other tiles side by side; the yearly's saving its own line (`savingLine`), the trial note white 0.92, the promise's check white, the promise on `.frosted` and on its own rounded row at the accessibility sizes; the tiles one height; 607 lines before) (2026-10-22, step 1's Tasks 4 and 7, staged: **rewritten whole** to the owner's canvas design (spec `2026-10-21-premium-paywall-and-monthly-design.md` §3.4) — `Screen` (`offer`, `thanks`, `held`) and the pure `screen(status:purchase:)`; the switch `isOffered(debug:arguments:setsOnSale:privacyPolicy:)` — Release only with a set on sale **and** an `https` privacy link — `isDebug`, `shownSets(debug:)`; the close button (*Not now*) and the promise's capsule, a decorative preview with no figure, the heading, set A's four feature rows from `PremiumSet` (each `.combine`d) and *New Premium features arrive in updates, included.*, three plan tiles (yearly chosen and *Best value*, the price the largest figure, the saving in the yearly's period line, a column at the accessibility sizes), the primary surface, the terms, the states (loading, unavailable, buying, pending, failed, thank-you with *Done* — no timed close — held, restoring, *No purchases to restore.*), the footer links in a `ViewThatFits`; `thanksPause` retired; 358 lines before) superseded: the first paywall — `Entry` (`.settings`), the switch (`launchArgument` `-WaterBuddyPremium`, `isOffered(debug:arguments:sets:)`, `isOffered(arguments:)`, `isOfferedHere`), `termsOfUse` (Apple's standard licence) and `privacyPolicy` — still the token `OWNER-PRIVACY-URL` (#159); two plan rows on glass, the primary surface, the terms, *Restore Purchases*, the two links, *Not now*; `PaywallStyle`. Judged "very poor" by the owner on their iPhone and redesigned (*Current state*)
WaterBuddy/PourDrop.swift                        160   app only — unstaged 2026-10-12, stage 3b's second pass: PourArc (a drop's path and presence, pure), PourPlace and the PourPlaces preference key (where the discs and the vessel stand), PourDrop (one 22 pt drop flown along the arc, reporting its landing) and View.swells(on:)
WaterBuddy/PremiumAccess.swift                   313   app only — (2026-10-22, step 1's final review and walk, staged: `Plan.period(in:)` — *a month*, *a year*, *once* — and `savingLine(in:locale:saving:)`, the yearly's saving on a line of its own (the walk's W2: the joined line broke after its dot in all three languages); `showsBestValue(saving:)`, *Best value* only while the yearly saves something (the review's I2); 304 lines before) (2026-10-22, step 1's Tasks 3 and 6, staged: `monthlyID` and three `productIDs` in the paywall's order; `Status.monthly(until:)`; **the owner's grace ruling** — `resolve(_:)` takes no clock and trusts StoreKit's current entitlements, ignoring only an unknown product and a revoked one; a lifetime wins, else the later end, the yearly on a tie (#161); `holdsSubscription(_:)`; `yearlySaving(yearly:monthly:)` in `Decimal`, rounded down, `nil` under 1 % — and `(among:)`; `Status.line(in:locale:now:)` — the plan's name alone once the date has passed; `Plan.amount` (StoreKit's `price`); the monthly's name, price line, terms and *Subscribe*; `period(in:locale:saving:)` and `note(in:locale:)` for the tiles; 195 lines before) new 2026-10-21 (1.4.1, staged, Tasks 3 and 5): Premium decided without StoreKit, Foundation alone, nonisolated — the two product IDs spelled once (productIDs), Entitlement, Status (.free, .yearly(until:), .lifetime; line(in:locale:)), resolve(_:now:) — the lifetime wins, refunds and ends at or before now ignored, a subscription with no end not taken as paid — and Plan (Kind, Period with formatted(locale:) — Foundation's DateComponentsFormatter, so the trial's length reads in the app's language — name, priceLine, terms, action)
WaterBuddy/PremiumRim.swift                       43   app only — new 2026-10-22 (step 1's Task 7, staged): `PremiumRim` and `.premiumRim()` — `Aurora.cyan` → `Aurora.magenta` → `Aurora.blue` stroked 1.5 pt around a standard pane, the one place that gradient is spelled; on the Settings card alone (rule `60-design-system`, the wording typed unstaged)
WaterBuddy/PremiumSet.swift                      104   app only — (2026-10-24, set A's step 5, staged: `isOnSale` `true` for `.understand` — set A on sale; a Release build still waits for the privacy URL, #159) (2026-10-24, set A's step 4, staged: the insights row *Personal insights* / *Each week, from your own figures, on your iPhone*, the caption *Insights* — no Apple mark) (2026-10-22, step 1's Task 4, staged: `.understand` — set A — with `Feature` (`monthView`, `patterns`, `insights`, `recap`: title, line, the card's caption — none for the recap — and a glyph), `features`, `isOnSale` (`false` until step 5) and `onSale`; a case is no longer a sale; 20 lines before) new 2026-10-21 (1.4.1, staged, Task 3): the sets Premium sells, no case yet — the paywall's Release switch counts it
WaterBuddy/PremiumStore.swift                    381   app only — (2026-10-22, step 1's final review, staged: `refresh()` clears *No purchases to restore.* once a purchase lands, by whichever read — a restore decided from a read a newer one overtook no longer outlives it (the review's I1, seen on the walk); 376 lines before) (2026-10-22, step 1's Tasks 3 and 5, staged: `now` internal, for the status line; three plans or `.unavailable`; the monthly's `Plan` with `amount: product.price`; `refresh()` numbers its reads, so one a newer read overtook publishes nothing, and publishes `holdsSubscription`; `Restoring` (`idle`, `restoring`, `nothingFound`) — a second restore asks nothing, and `prepare()` forgets a *nothing found*; `canManage`, through `Source.canManage` — `live()` not on a Mac, `silent()` never; 331 lines before) (2026-10-21, 1.4.1's final review, staged: `prepare()` keeps a purchase under way — *Not now* then *See Premium* while StoreKit's sheet was still coming up had let a second purchase start; `openingTheSheetAgainWhileBuyingKeepsThePurchase` RED → GREEN; 325 lines before) new 2026-10-21 (1.4.1, Task 4, committed in `e7b7f38`): the second file to import StoreKit; @MainActor @Observable; the paid state read, never stored — State (.checking, .known), Plans (both or .unavailable), Purchase, Outcome; one Transaction.updates listener started in init; refresh, prepare, loadPlans, buy (a second tap buys nothing; unverified is failed), restore (AppStore.sync), manage (showManageSubscriptions); StoreKit only through Source, a struct of closures — live(), and silent() for previews; purchase(confirmIn:) on the foreground scene. Not yet built into the app: WaterBuddyApp does not construct it until Task 6
WaterBuddy/PressStyle.swift                       32   app only — the shared press recoil
WaterBuddy/RecapCard.swift                       295   app only — new 2026-10-24 (set A's step 5, staged): `RecapCard` — the month in one card, drawn in the sheet and rendered as the shared image (`image(of:strings:locale:)`, `Rendered`: 360 pt × 3, `.dynamicTypeSize(.large)`, dark); flat `Aurora.gradient` canvas, `.premiumRim()`, tiles on `Base.archived`; no streak, goal, serving or time
WaterBuddy/RecapSheet.swift                      200   app only — new 2026-10-24 (set A's step 5, staged): `RecapSheet` — the card, the best streak beside it, *Share as an image* (`ShareLink`, `sharedItem(_:)`), the footnote; the image in memory only
WaterBuddy/ReminderPermission.swift               57   app only — stage 5: the one way the app asks for reminders and reads the answer back — enable(on:using:) asks only when the system has not been asked and stores what it answers (Settings' switch turning on, the welcome's Turn on reminders), reconcile(_:using:) turns reminders off when the system reads denied (every return to the foreground, and Settings appearing or coming back); the switch turning off writes the flag itself
WaterBuddy/ReminderPlan.swift                    149   shared — WHEN to remind, as a pure value
WaterBuddy/ReminderResponder.swift                59   app only — new 2026-10-15 (1.2.4): the notification centre's main-actor delegate, installed in WaterBuddyApp.init(); a press of a reminder's Log a Glass runs LogServingIntent.logTheGlassInTheBackground(); logsTheGlass(for:) decides; no willPresent
WaterBuddy/ReviewPrompt.swift                     56   app only — new 2026-10-15 (1.2.5): the rating request's app side — the DEBUG opt-in -WaterBuddyReviewPrompt (isEnabled(arguments:), isEnabledHere), the pause (Confetti.duration + 0.4), the version (CFBundleShortVersionString); imports Foundation only
WaterBuddy/RootTabView.swift                     565   app only — (2026-10-24, set A's step 4, staged: the `#Preview` injects a silent `InsightWriter`) (2026-10-21, 1.4.1's Task 6, staged: the `#Preview` injects `PremiumStore(source: .silent())`; the count unchanged) (2026-10-19, 1.3.1 6c, staged: `AppTab(link:)` and `.onOpenURL` — the week widget's link turns to History as the bar would; 542 lines before) (2026-10-15, 1.2.5: EnvironmentValues.pageIsShown, injected on every mounted page as tab == turn.shown, so a page sliding out knows at the turn — the final review's fix; 520 lines before) unstaged 2026-10-12, stage 3b; its container rewritten by the second pass: ONE pager on every system — one AuroraBackground, the page shown and, while it slides, the page leaving (PageTurn; `.transaction(value:)` with addAnimationCompletion takes the old page out), one BarShade under Apple's bar — and the bar in a bottom safeAreaInset: SystemTabBar, a standalone UITabBar behind `if #available(iOS 26.0, *)`, or the app's own GlassTabBar. No TabView, no SystemTabs, no HandMadeTabs (the first build of stage 3b had all three). AppTab (3 cases, nonisolated now), the container, the glass tab bar with a lozenge behind the selected tab (2026-10-09, committed in `c9ef45d`) (the 420pt cap's comment rewritten 2026-09-02: it justified itself in iPad measurements, and iPad is gone — the cap is kept, because 420 is below the widest iPhone's content width)
WaterBuddy/ScreenHeader.swift                     99   app only — (2026-10-13, stage 3c, staged: DocC only — the week card's days are budgeted by HistoryView.daySlot, not by slot(of:across:)) unstaged 2026-10-12, stage 3b: ScreenMetrics (margin 24, topInset 16, titleLine 44, slot(of:across:)) and ScreenHeader, the header every tab opens with — the title, a line under it, an accessory on the title's line that never sets its height
WaterBuddy/ScrollDepth.swift                     167   app only — unstaged 2026-10-12, stage 3b's second pass: ScrollDepth (phase(of:within:) by what is left showing, span(from:to:), scale to 0.92, anchor — pure; it shrinks and does not fade), EnvironmentValues.scrollDepthSpan, View.scrollDepth() (a visualEffect off the section's global frame) and View.scrollDepthContainer(). On History and Settings, not Home
WaterBuddy/SettingsView.swift                    990   app only — (2026-10-22, step 1's walk, staged: the card's previews aligned on their first baseline, each glyph set as text (W1); at the accessibility sizes the previews a column of glyph beside caption (W5) and the title a whole *WaterBuddy* / *Premium* lockup spoken as one (W6); the header sparkle white — cyan read 2.88:1 in the card's lit corner (the owner's ruling R4); 957 lines before) (2026-10-22, step 1's Tasks 3 and 7, staged: **Premium's card first**, the owner's ruling, behind `showsPremium` — offered here and the store not `.checking` — the other cards' arrival after it (`lead`); `PremiumCard` rewritten: free — a sparkle, *WaterBuddy Premium*, the line, three decorative previews (glyph over caption, hidden), *See Premium* on the primary surface (Settings' only one), `.premiumRim()`; held — *You have Premium.*, the status line with the store's clock, *Manage Subscription* for any subscription held where Apple's sheet works; `PremiumCardStyle`; 888 lines before) (2026-10-21, 1.4.1's Task 6, staged, superseded by the above: `PremiumCard` as a fifth card, last, behind `PaywallView.isOfferedHere` and a store no longer `.checking` — *Premium*, a line and a glass *See Premium* while free; the plan's line and *Manage Subscription* for a yearly; the paywall on `.sheet(item:)`; the preview's `PremiumStore(source: .silent())`; 818 lines before) (2026-10-17, 1.2.6: GoalCard reads the locale; the goal's spoken value through localized.) (stage 5: the vessel rows moved out to VesselSliders, the card committing from its own onChange while no drag is in flight; the switch asks through ReminderPermission; the goal's range and step read off WelcomeView; 951 lines before) (the redesign's stage 4, staged 2026-10-14: the canvas's Settings — SettingsStyle, one title and one note style for the four cards, cardTitle()/cardNote()/settingsCard(), Hairline; the goal at 36 pt bold, its range labels white 0.88 (the 0.75 further on is from before — noted in the fifty-eighth pass); vessel amounts grouped and full white, the row a ViewThatFits measured at its widest; the note "The Glass is the one your widget, Siri and Control Center log."; .onAppear refresh with the two cards re-seeded by onChange unless a drag is in flight; step ticks (Haptics.select) from `steps` counters, the language pick on select; one point of top padding, #108; 774 lines before) (second pass of stage 3b, unstaged 2026-10-12: no backdrop of its own; SavedTick and CheckShape, drawn over the title of the goal's and the vessels' cards by savedTick(_:) when a change is saved; the figure under a held slider at 1.06; the language's checkmark bounces; the cards re-lay out together when the reminders card's text changes; every section recedes with scrollDepth()) unstaged 2026-10-12, stage 3b: its title is ScreenHeader and its four cards arrive; the goal editor (range labels at white 0.75, 2026-10-10, `c9ef45d`), the vessel editor, reminders, the language picker
WaterBuddy/TodaysWaterIntent.swift                89   app only — new 2026-10-18, 1.3.4, staged: Siri's "how much water today" ("Today's Water") — perform() reads DataManager.snapshot(), the widget's own read, and writes nothing; answer(for:), nonisolated static, picks one of three explicit positional keys (nothing yet, met, under) with the total and what is left as the figures, resolved by Siri in its own language; authenticationPolicy .requiresAuthentication, openAppWhenRun false
WaterBuddy/VesselSliders.swift                   179   app only — (2026-10-17, 1.2.6: a row's spoken amount through localized; the count did not move.) stage 5: the three vessel rows, lifted out of Settings' card so the welcome draws the same rows — a binding to the three amounts, an onDrag hook, a tick per step while held, the row a ViewThatFits measured at its widest
WaterBuddy/WaterBuddyApp.swift                   197   app only — (2026-10-24, set A's step 4, staged: builds `InsightWriter()` beside `PremiumStore()`, before the fresh start, and injects it) (2026-10-22, step 1's Task 7, staged, a comment only: the store is built right after the App Group is resolved, before anything draws; the count unchanged) (2026-10-21, 1.4.1's Task 6, staged: `premium = PremiumStore()` built in `init()` after `prepareSharedStorage()` and before the fresh start's return, injected beside the manager, and read again on every `.active`; 178 lines before) (2026-10-18, #144, staged with 1.2.8, DocC only: freshStartArgument no longer names who passes it — rule 85-testing does; freshStartManager says init() resolves the App Group suite before it; 176 lines before) (2026-10-15, 1.2.5: freshStartManager's DocC names the rating request as the one Debug/Release difference; 175 lines before) RootView, the setup gate, the strings/locale injection, WristInbox.shared + WristLink.live.activate() at launch, then ReminderResponder.install() (2026-10-15; 170 lines before) (stage 5: the gate shows WelcomeView; every return to the foreground reads the system's answer back through ReminderPermission.reconcile; in DEBUG, -WaterBuddyFreshStart opens on a throwaway suite and an in-memory store — freshStartManager(arguments:); 108 lines before)
WaterBuddy/WaterBuddyShortcuts.swift              50   app only — the one AppShortcutsProvider: two shortcuts, three phrases each (en + ru, AppShortcuts.xcstrings) — the "Log a Glass" tile first, then "Today's Water" (drop.fill; 2026-10-18, 1.3.4, staged; 38 lines before)
WaterBuddy/WaterLog.swift                         57   shared — the SwiftData @Model, source of truth
WaterBuddy/WaterMotion.swift                      64   app only — new 2026-10-18, the lag fix, change A: how the water moves after a pour and then rests — the phase eases from 1.1 rad/s to a standstill over settling (2.5 s), carries on across pours, and remaining(at:since:) runs Home's clock (the welcome's waits out settling itself); pure and nonisolated
WaterBuddy/WaterSurface.swift                    194   shared — waves, scrim, Aurora palette, vesselSlots (moved in from HomeView, Task 14 — a second, non-view consumer: WristView)
WaterBuddy/WelcomeView.swift                    1338   app only — (2026-10-18, the lag fix, change A: the hello vessel moves for WaterMotion.settling each time its step is shown, then rests; paused while the app is not active.) (2026-10-17, 1.2.6: four sentences through localized; WelcomeView reads the locale; spokenMillilitres' DocC rewritten.) stage 5, replacing GoalSetupView: four steps — hello, the goal (with the calculator under "Work it out for me"), the vessels, reminders — mounted side by side and slid by the step (Motion.page, a fade under Reduce Motion; one turn at a time, the bar disabled while one slides); WelcomeStep (nonisolated: next, previous, number, offset, opacity); the goal's menu, goalRange and goalStep, read by Settings; bellTimes(in:) from ReminderPlan.hours; finish(goal:amounts:asksForReminders:on:using:) — the vessels, then the question, then the goal, which ends the welcome; CalculatorPanel; ReminderBells on frosted discs; WelcomeStyle's measured opacities
WaterBuddy/WristInbox.swift                       90   app only, NOT shared — reassembles chunked WristBatch payloads (wrist → phone), calls DataManager.ingest(_:)
WaterBuddy/WristPlan.swift                       138   (2026-10-20, 1.3.2 7b, staged: WristPlan.Face — total, goal, progress, percentage held to 0...999, spokenFigures and millilitreLine in the app's own sentences, sample — and face(mirror:outbox:now:calendar:), what the screen and the complication both draw; 80 lines before) shared (in both watch exception sets, not the phone widget's) — ReminderPlan's pure twin: buckets the outbox by the watch's day, counts the phone's total until the phone's day ends, names the complication's turnover instants (spec §17)
WaterBuddyTests/AppLanguageTests.swift           112   AppLanguageTests — the menu and each bundle
WaterBuddyTests/ArrivalTests.swift                82   unstaged 2026-10-12, stage 3b — ArrivalTests (not @MainActor, 10): the delay grows with the order and stops, the whole arrival is short, a hidden section is never at exactly nothing; second pass, four more: a page that slid in is whole from its first frame, a section of the opening page waits hidden and low, and under Reduce Motion it does not rise
WaterBuddyTests/AuroraBackgroundTests.swift      168   AuroraLightTests — the backdrop's lights; unstaged 2026-10-12, stage 3b: AuroraDriftTests (not @MainActor) — there and back in two periods, the curve, the clock alone says where a light stands, a broken clock leaves it at rest
WaterBuddyTests/CelebrationTests.swift           115   HapticLadderTests (stage 3b: remove is in the legal range and no firmer than confirm) + ConfettiTests
WaterBuddyTests/DataManagerTests.swift          1385   (2026-10-19, 1.3.1 6c, staged: three doorbell tests count from after construction, which now rings once for the first week — plan P1; 1373 lines before) (2026-10-15, 1.2.5: everyKeyTheProductWritesIsOnTheRoster drives the claim and requires its key; 1363 lines before) (2026-10-15, 1.2.4: ReminderSeamTests' changingTheLanguageRePlans and choosingTheSameLanguageAgainDoesNotRePlan; 1332 lines before) (stage 5: DailyGoalSetupTests reads WelcomeView's goalRange and goalStep, and its comments name the welcome; 1331 lines before) DataManagerTests + DailyGoalSetupTests + ReminderSeamTests + WristPublishSeamTests + LanguageSeamTests
WaterBuddyTests/EarlierServingTests.swift        431   (2026-10-19, 1.3.1 6c, staged: `aServingBackdatedIntoYesterdayRingsTheWidgetOnce` replaces `…RingsNoWidgetDoorbell` — the week widget draws past days; the owner's ruling; 429 lines before) HistoryLogsTests + RetimingTests + HistoryWindowStartTests (not @MainActor) + CorrectionRangeTests + RetimedPourTests + HistorySelectionTests (not @MainActor) — the window's published rows, re-timing a serving, where the week starts, what the sheet offers and where it opens, a watch pour re-timed, the screen's day selection
WaterBuddyTests/GoalSuggestionTests.swift        115   stage 5 — GoalSuggestionTests (not @MainActor, 12): the spec's table of weights and activities, 155 lb at moderate is 2,500 ml, a light weight lifted to the slider's floor and a heavy one held to its ceiling, exactly half a step rounds up, the weight starts in the region's unit and on its own wheel, 70 kg reads as 154 lb and back, every kilogram survives a trip through pounds, a weight converted to its own unit is unchanged, every suggestion lands on the slider and rises with weight, and more activity never suggests less
WaterBuddyTests/HistoryRangeTests.swift          601   DaySummaryTests (pure, not @MainActor) + HistoryWindowTests; staged 2026-10-11, the redesign's stage 3: DaysMetTests — reached(_:) and daysMet(in:goal:) — + DayFractionTests — dayFraction and hours, across a 23- and a 25-hour day — both pure, not @MainActor
WaterBuddyTests/HistoryViewTests.swift           420   (2026-10-23, set A's step 3, staged: `MonthLayoutTests` +3 — the locale's weekend, an hour's place on the chart, the hours' bars) (2026-10-23, set A's step 2, staged: `MonthLayoutTests`, 10 — not `@MainActor` — the switch's offer, the month's grid, the first weekday and its letters in each language, litres) (stage 5: a comment names WelcomeView) (2026-10-13, stage 3c, staged: three more in HistoryLayoutTests — every day clears the tap floor on four card widths, the row takes the full 16 where the card affords it and 9.5 / 0 where it does not, a row of no days is no division by zero) (second pass of stage 3b, unstaged 2026-10-12: two more in HistoryLayoutTests, 14 — the marker stands over the day shown, on the four real row widths, and a week of no days is no division by zero) HistoryServingTests — the editor's offered range (staged 2026-10-11: its bounds contain every vessel), and the fixture's own tripwire; staged 2026-10-11, the redesign's stage 3: HistoryLayoutTests (not @MainActor) — the strip's bars, a row's vessel, the strip's hours
WaterBuddyTests/HomeModelTests.swift             409   2026-10-11, `1ced514` — UndoTests (the id addLog returns, undo by id, after midnight, on a failed read) + HomeFiguresTests (remaining, hasReachedGoal, lastDrink, nextReminder and what each observes) + DayTurnTests (dayDidTurn republishes on a real day change and on nothing else)
WaterBuddyTests/InsightCopyTests.swift           365   new 2026-10-24 (set A's step 4, staged): `InsightCopyTests`, 7 — not `@MainActor` — the sentences in three languages, the page; `InsightWriterTests`, 20 — `@MainActor` — `accepts(_:for:)` part by part, the English gate, kept and declined notes, `Retry`, the prompt
WaterBuddyTests/HomeViewTests.swift              287   (unstaged 2026-10-12, stage 3b: theWidestDateFitsTheNarrowestPhoneAtTheLargestTextSize — every day of a year in three languages, measured in iOS's own font) HomeServingTests — the quick-add row's offered vessels — + HomeLayoutTests (not @MainActor; 2026-10-11, `1ced514`): the Glass ranked, the vessel's floor and ceiling, what the column leaves it, the discs' bounds, an offer's lifetime, Home's glyphs
WaterBuddyTests/LiquidGlassTests.swift           340   (2026-10-20, 1.3.2 7a, staged: two DocC comments no longer put the watch on the hand-made stack; no assertion moved.) (2026-10-13, stage 3c, staged: the tint floor moved to 0.64, theGlassIsTintedWithTheSkysOwnBlue, LiquidGlassScrimTests — the phone's own panes scrimmed with the sky at 0.30 / 0.70 / 0.80 in density order, the widget and the watch keeping black, Light Mode none — and theShownDaysLetterReadsOnItsDisc in PrimarySurfaceTests) LiquidGlassInteractionTests + LiquidGlassBaseTests — the press response; 2026-10-10, `c9ef45d`: LiquidGlassRoutingTests (which pane, which of Apple's variants, the availability flag, only the regular variant darkened, and no lighter than the lightest rung that passed) + PrimarySurfaceTests (the derived contrast); none @MainActor
WaterBuddyTests/LocalizationTests.swift         1286   (2026-10-24, set A's step 5, staged: `historyKeys` +5, the recap's words) (2026-10-24, set A's step 4, staged: `historyKeys` +29, `countedKeys` +5 with their sentences, the paywall's three insights keys renamed) (2026-10-23, set A's step 3, staged: `historyKeys` +11, `countedKeys` +2, `expected` +6) (2026-10-23, set A's step 2, staged: `historyKeys` +20, `countedKeys` +5, `expected` +15) (2026-10-22, step 1's walk, staged: `a year · save %1$@` → `save %1$@` among premiumKeys, still 54; the count unchanged) (2026-10-22, step 1's Task 6, staged: premiumKeys gains the 27 new keys — 54 in all, each in en, ru and uz with its arguments; 1111 lines before) (2026-10-21, 1.4.1, staged: premiumKeys — the paywall's and the card's 27 — and PremiumStringTests, each in en, ru and uz with its arguments; 1061 lines before) (2026-10-21, 1.3.2 7c, staged: watchWidgetSharedKeys — Today's hydration, Hydration, %1$@ of %2$@ ml and the vessel's sentence — compared with the app bundle in every language, replacing the description's single check; the sentence counted in the watch widget's bundle too; 1048 lines before) (2026-10-20, 1.3.2 7b, staged: watchSharedKeys gains %1$@ of %2$@ ml and %1$@, add %2$d millilitres; watchOwnKeys loses the readout, Logs %1$d millilitres, More and Shows the other serving sizes; the pour sentence counted in the watch's bundle too, Logs %1$d millilitres no longer; 1055 lines before) (2026-10-19, 1.3.1 6c, staged: `sharedKeys` gains the week widget's seven; `theWeekWidgetSaysWhatTheSpecSays` — its three new strings in en/ru/uz, in both bundles; 1028 lines before) (2026-10-18, 1.3.4, staged: Siri's three answer keys join countedKeys and expected — every form at twelve counts in en/ru/uz; 999 lines before) (2026-10-17, 1.2.6: PluralFormTests, five — every counted key in every bundle at twelve counts in en/ru/uz, the no-locale finding, a German and a Japanese phone on Follow device, theFollowDeviceLocaleSpeaksTheBundlesLanguage; table(_:_:) reads Localizable.stringsdict too and returns every form; theTablesSeeAKeyWithPluralForms; homeKeys and historyKeys gain %1$d days and %1$d servings; theHomeKeysThatTakeARawNumberAreTheCountedOnes replaces onlyTheSpokenHomeStringTakesARawNumber.) (2026-10-15, 1.2.4: theTranslatedReminderCopyStillCarriesNoUserValues reads Log a Glass in ru and uz, required; theAppAndTheWidgetFileRemindersInTheSameWords in en, ru, uz; 699 lines before) (stage 5: welcomeKeys, the welcome's 28 keys, and WelcomeStringTests — each in en/ru/uz with its specifiers matching; 648 lines before) (stage 4, staged 2026-10-13: theVesselsNoteNamesTheGlassByItsOwnName — the note's key in en/ru/uz contains each table's word for Glass, and the old note's key is gone; 628 lines before) (2026-10-11, `1ced514`: HomeStringTests — Home's ten keys in en/ru/uz with matching specifiers — + GroupedFigureTests — Bundle.figure groups by the locale and Uzbek reorders. Staged 2026-10-11, the redesign's stage 3: HistoryStringTests — History's six keys in en/ru/uz, the four retired keys gone, and the built table's raw-number volume keys exactly the three other screens still draw) the four bundles' string tables, en/ru/uz — the phone's two and, through the built phone app's Watch/ folder, the watch's two; the Shortcuts vocabulary test also pins the control's two strings
WaterBuddyTests/MonthHistoryTests.swift          578   (2026-10-23, set A's step 3, staged: +2 — a month carries its own rows' patterns; the day turning adds yesterday to them) new 2026-10-23 (set A's step 2, staged): `MonthHistoryTests`, 22 — not `@MainActor` — the counting rule, a DST month, a flight across a month's edge, a serving stamped after today, saturation, the neighbours; `MonthPublishingTests`, 15, `@MainActor` — published only while asked, behind `role.drawsHistory`, never from `init`, a failed read left standing, the first serving deleted, a month ending on screen, a pour and a removal reading the shown month once (`ChangeTally`)
WaterBuddyTests/MonthPatternsTests.swift         304   new 2026-10-23 (set A's step 3, staged): `MonthPatternsTests`, 22 — not `@MainActor` — finished days only, seven days of water, each hour's water and the busiest, the weekday/weekend split under two weekends, the medians and their rounding, a DST day's wall clock, Paris against London, the drawn instants
WaterBuddyTests/MonthRecapTests.swift            254   new 2026-10-24 (set A's step 5, staged): `MonthRecapTests` (11, not @MainActor — which month a page offers, the first-week window across a time zone) + `RecapReadingTests` (6, @MainActor — `recap(of:)` reads the month view's month, writes no key, rings nothing, publishes nothing, `nil` on a failed read)
WaterBuddyTests/MotionTests.swift                 64   unstaged 2026-10-12, stage 3b's second pass — MotionTests (not @MainActor, 6): a page changes in under half a second and over a quarter, the fade is shorter than the slide, what lands overshoots and does not ring, neither spring is as quick as the press's, a drop is quicker than the level, a state changes quicker than a page
WaterBuddyTests/NotificationManagerTests.swift   495   (2026-10-15, 1.2.4: both spies hold PendingReminders and replace a request filed under its identifier, as the centre does; eight new tests — the button's category and action, its title in the bundle passed, PendingReminder read off a request, the re-file in other words, in another language and from 1.1, and ReminderResponder.logsTheGlass(for:); theReminderCopyCarriesNoUserValues reads the button's title; 352 lines before) NotificationManagerTests — applying a plan, against a spy scheduler — + ReconcileQueueTests (not @MainActor), against SharedCentre, a lock-guarded stand-in two reconciles can reach at once
WaterBuddyTests/PageTurnTests.swift              185   unstaged 2026-10-12, stage 3b's second pass — PageTurnTests (not @MainActor, 13): a tab to the right comes in from the right and the page leaving ends a whole width away; the tab already shown turns nothing; two pages at most, in the bar's order; every turn is counted; an older turn's end does not end a newer one, nor does there-back-and-there-again inside one slide; under Reduce Motion nothing travels and the page leaving fades
WaterBuddyTests/PourDropTests.swift               68   unstaged 2026-10-12, stage 3b's second pass — PourArcTests (not @MainActor, 6): a drop starts at the disc and ends in the vessel, rises above the line between, is held at its ends, is whole on the way and gone when it lands, and goes straight up from straight below
WaterBuddyTests/PremiumAccessTests.swift         377   (2026-10-24, set A's step 5, staged: +1, `setAOnSaleStillWaitsForThePrivacyLink`) (2026-10-22, step 1's final review and walk, staged: PremiumWordsTests +1, `aYearlyThatSavesNothingIsNotMarkedBestValue` (I2); `theTilesReadAsDrawn` and `theNewLinesReadInTheirOwnLanguage` read the period and the saving line apart (W2); 358 lines before) (2026-10-22, step 1's Tasks 3, 4, 6 and 7, staged: PremiumAccessTests 22 — the monthly, precedence, `holdsSubscription`, the saving (Review Focus 2), three product IDs; **the grace ruling's replacements**, named by the spec, not narrowed: `aListedYearlyPastItsEndIsStillHeld` and `aSubscriptionInItsGracePeriodIsStillPaid` for `aYearlyEndingAtThisInstantIsOver` and `aYearlyThatEndedIsOver`, `aSubscriptionStoreKitStopsListingReadsFree` for `anExpiryPassingWhileTheAppRunsReadsFreeOnTheNextRead`; PremiumWordsTests 9 — the status line's passed date (Review Focus 4), the monthly, the tiles, the new lines in ru and uz; PaywallOfferTests 5 — Release needs a set on sale **and** an `https` link, `shownSets`; PaywallScreenTests 4, not @MainActor — offer, thanks, a refund after a thank-you (Review Focus 1), a subscriber sees what they hold (Review Focus 5); 216 lines before) (2026-10-21, 1.4.1's Task 6, staged: `PaywallOfferTests`, not @MainActor, 4 — DEBUG offered only with `-WaterBuddyPremium`, Release only with a set, the gate's own run not offered, Apple's terms and an `https` privacy link; `theLinksAreApplesTermsAndAPageOfOurs` **fails by design until the owner's URL**, #159; 185 lines before) new 2026-10-21 (1.4.1, committed in `e7b7f38`): PremiumAccessTests (not @MainActor, 14 — the decision), PremiumWordsTests (not @MainActor, 5 — every sentence formatted in en, ru and uz off the built bundle; no length in a button)
WaterBuddyTests/PremiumSetTests.swift             58   (2026-10-24, set A's step 5, staged: `setAIsOnSaleNowEveryFeatureIsBuilt` replaces the `false` pin) (2026-10-24, set A's step 4, staged: +1, `theInsightsRowCarriesNoAppleMark`) new 2026-10-22 (step 1's Task 4, staged): PremiumSetTests, 4, not @MainActor — set A's four features in order, not on sale until step 5, every glyph resolves, the card previews all but the recap
WaterBuddyTests/PremiumStoreTests.swift          635   (2026-10-22, step 1's final review, staged: PremiumStoreTests +3 (I1) — a purchase, and an approval, after *nothing to restore* clear the line; a restore whose read a newer one overtook does not outlive the purchase — the fake can hold a second read; 581 lines before) (2026-10-22, step 1's Tasks 3 and 5, staged: the fake holds a read and a restore, counts reads, and answers `canManage`; PremiumStoreTests 25, a minute's limit — three plans, two → unavailable, restore's states and a second restore asking once (Review Focus 3), a read overtaken not publishing, manage only where it works, a lifetime beside a monthly still a subscription to manage, and the store reading free once StoreKit stops listing the plan; StoreKitSessionTests 11 — all three products load and only the yearly offers a week, the monthly renews monthly, a bought monthly reads monthly, a monthly then a yearly reads the yearly; `anExpiredYearlyReadsFree`'s DocC names the grace ruling's tests; 437 lines before) (2026-10-21, 1.4.1's final review, staged: `openingTheSheetAgainWhileBuyingKeepsThePurchase` — the reopened sheet's `prepare()` keeps the purchase, and a second tap buys nothing; PremiumStoreTests 19; 415 lines before) new 2026-10-21 (1.4.1, committed in `e7b7f38`): PremiumStoreTests (18, through a FakeAppStore Source) and StoreKitSessionTests (8, .serialized, a minute's limit, an SKTestSession over WaterBuddy.storekit through the live Source — one, anExpiredYearlyReadsFree, .disabled with its measured reason, known issue #157)
WaterBuddyTests/RecapImageTests.swift            104   new 2026-10-24 (set A's step 5, staged): `RecapImageTests` (5, @MainActor) — 1,080 px wide, the same at the largest text size, three languages, a 31-day month at the maximum, and the PNG `ShareLink` exports keeps its pixels
WaterBuddyTests/ReminderPlanTests.swift          251   the plan — pure, and no UserNotifications import
WaterBuddyTests/ReviewRequestTests.swift         185   new 2026-10-15 (1.2.5): ReviewRequestTests (8) — the decision and the claim; ReviewPromptTests (4) — DEBUG's opt-in, the gate's own run not launched to ask, the pause, the version
WaterBuddyTests/RootTabViewTests.swift           115   (2026-10-19, 1.3.1 6c, staged: `theWeekWidgetsLinkOpensHistory` and `anyOtherLinkOpensNothing` in AppTabTests; 102 lines before) AppTabTests — the tab bar's offered destinations; unstaged 2026-10-12, stage 3b: BarShadeTests (not @MainActor) — the shade is no lighter than the first rung with room, leaves the aurora showing, and its ramp is no taller than Home's foot
WaterBuddyTests/ScreenHeaderTests.swift           43   (2026-10-13, stage 3c, staged: the seven-day floor test now asks HistoryView.daySlot of the 327-pt card, not the screen's slot) unstaged 2026-10-12, stage 3b — ScreenMetricsTests (not @MainActor): Home's column padding is ScreenMetrics' margin and top inset and History's margin is ScreenMetrics' (Settings reads ScreenMetrics directly and is not in the suite, and History's top inset, one point less for its list, is not asserted — "the three screens read one margin and one top inset" until the fifty-second pass), seven day buttons clear 44 pt on a 375 pt phone, the title's line is at least a tap target, and a slot of nothing does not divide by zero
WaterBuddyTests/ScrollDepthTests.swift           134   unstaged 2026-10-12, stage 3b's second pass — ScrollDepthTests (not @MainActor, 16): a section at rest is whole and at the edge at its floor, the top and the foot alike; a section inside what is shown has not moved at all, half out is half gone, wholly out no further; a card taller than the screen is whole while it fills it and nothing jumps as its top crosses the edge; a span of nonsense is no span
WaterBuddyTests/ServingSeamTests.swift           297   ServingResolutionTests (pure, not @MainActor; usualSlot is the Glass, and usualServing reads it) + ServingSeamTests
WaterBuddyTests/SiriPhraseTests.swift            278   (2026-10-18, 1.3.4, staged: the phrase tables hold six each, not three; 277 lines before) UsualServingTests + ReconcileQueueSettledTests (both not @MainActor) + LogServingIntentTests + LogTheGlassTests + AppShortcutPhraseTests
WaterBuddyTests/StreakTests.swift                491   (2026-10-18, the lag fix, change B: StreakRecountTests, nine — a pour and a tab's refresh do not reread the past, shown by changing it behind the manager's back; an earlier day's add, delete and move into today, a watch pour onto an earlier day, a turn of the day and midnight each recount it. A change of zone and a serving moved off today onto another day are not tested (#143).) 2026-10-11, `1ced514` — StreakCountTests (pure, not @MainActor: DaySummary.streak and streakFillsWindow, and three on windowStart, historyWindowStart and streakWindows) + StreakPublishingTests (the published streak: the window walk, a goal change, a failed read, and that it reaches neither the snapshot nor the wrist's mirror)
WaterBuddyTests/TodaysWaterTests.swift           272   new 2026-10-18, 1.3.4, staged — 16 @Test: TodaysWaterSnapshotTests (not @MainActor, async, each value read into a local before #expect — the proven canary for the two properties' nonisolated, #147; remaining and hasReachedGoal at zero, under, at and over) + TodaysWaterAgreementTests (theSnapshotAgreesWithTheManager) + TodaysWaterAnswerTests (not @MainActor; the three lines resolved exactly in en/ru/uz, the plural forms, the cap, German falling back to English words, a question after midnight) + TodaysWaterIntentTests (theAnswerWaitsForAnUnlock, never opens the app, the title in three languages, the provider's two shortcuts)
WaterBuddyTests/UnreadableStore.swift             87   2026-10-11, `1ced514` — NOT a suite: a file-backed store whose reads fail on demand (the servings' table renamed away through a second SQLite connection, and put back), for the tests that pin what the model does when it cannot read; three tests use it since WristIngestTests' joined (staged 2026-10-11, known issue #92)
WaterBuddyTests/WaterLogTests.swift              510   (2026-10-19, 1.3.1 6c, staged: `loggingRingsTheWidgetDoorbellExactlyOnce` counts from after construction — plan P1; 505 lines before) WaterLogStoreTests — one makeManager factory is the file's only DataManager( site
WaterBuddyTests/WaterMotionTests.swift            85   new 2026-10-18, the lag fix, change A — WaterMotionTests (not @MainActor, 7 @Test, 8 cases — one takes two arguments): sets off at its own speed, slows to a standstill, stands still once settled, carries on across a pour, the first pour of a launch, a pour still ahead, settles in 2.5 s
WaterBuddyTests/WaterSnapshotTests.swift         678   (2026-10-19, 1.3.1 6c, staged: WeekSnapshotTests (not @MainActor, 7 @Test, one over seven corruptions) — the cached week through the snapshot, discarded whole, today from the total, the midnight shift, a stale cache, another zone, a read that writes nothing; `WeekCorruption` internal, as an internal @Test's argument must be; 565 lines before) WaterSnapshotTests + WidgetLanguageTests + ProcessRoleTests
WaterBuddyTests/WeekCacheTests.swift             297   new 2026-10-19, 1.3.1 6c, staged — WeekCacheTests (@MainActor, 13 @Test; the thirteenth, `aCorruptNegativeServingIsClampedInTheCachedDay`, from the final review): a pour caches the week; the morning-after tap keeps yesterday; one ring a pass — a pour, an earlier day's edit, a serving moved to yesterday; the first week rings once, a cached one not at all; `refresh()` and the day turning write nothing; a failed read leaves it; an `Int.max` row saturates; the widget's week equals History's across a 25-hour day
WaterBuddyTests/WeekInsightsTests.swift          482   new 2026-10-24 (set A's step 4, staged): `WeekInsightsTests`, 31 — not `@MainActor` — the week's bounds, DST, pending, counted days, each finding, the threshold and rounding, the order and the tie, the review's fixes; `InsightsPublishingTests`, 7 — `@MainActor` — published while asked, republished, a failed read, no key written
WaterBuddyTests/WelcomeTests.swift               379   (2026-10-15: PermissionSpy's scheduler takes pending and setCategories; 378 lines before) stage 5 — ReminderPermissionTests (7: a grant stored, a refusal and a failed request stored as off, a phone already allowed or already refused not asked again, a re-read that turns reminders off on a refusal and leaves the switch alone otherwise) + WelcomeStepTests (not @MainActor, 8: the order, no Back first and no Continue last, Continue and Back as a pair, the dots from one, where the next and previous steps wait, a slid step seen all the way out, under Reduce Motion nothing travels, the bells at the reminder hours) + WelcomeFinishTests (6: vessels left alone store nothing, vessels set are stored, the goal saved closes the welcome, reminders asked for before it closes, a refusal still opens the app with reminders off, Not now asks nothing) + FreshStartTests (DEBUG only, 2: no argument, no fresh start; a fresh start is a throwaway cleared at each launch) — the first and third against PermissionSpy, a ReminderScheduler built from a spy's closures
WaterBuddyTests/WristSyncTests.swift             955   (2026-10-20, 1.3.2 7b, staged: WristPlanTests gains the face's six — the default goal before a sync, the phone's total and the watch's pours, the turnover at the phone's day end, the complication's rounding, a goal of zero and an overflowing readout, the app's sentences; 882 lines before) WristWireTests + WristIngestTests + WristPlanTests + WristInboxReassemblyTests + WristPublishTests + WristMirrorNewsTests (not @MainActor) + WristLinkDecodingTests + WristLinkChunkingTests + WristLinkReachabilityTests; staged 2026-10-11: WristIngestTests' failed-read test makes its store unreadable with UnreadableStore, no longer by overwriting the file (known issue #92)
WaterBuddyUITests/AppStoreScreenshotUITests.swift  717   (2026-10-18, #144, DocC only, staged with 1.2.8: *Why it starts clean* says the launch still resolves the App Group suite and runs the migration, and the run's figures live only in the throwaway; setTime's afternoon failure is the request and the read-back, the snap-back inferred; 714 lines before) (2026-10-18, roadmap item 1.2.8, staged: the store method rewritten — launched with -WaterBuddyFreshStart and en_US, refuses to start outside 1:45–11:45 PM, builds a lived-in week through History's + and wheel (today's five at set times, six earlier days from the sheet's shortcuts), asserts Home at 65 % with a 5 days chip; run three times, the last two passing — the store method is no longer non-idempotent, the census still is, still not run; 559 lines before) (2026-10-17, 1.2.6: its spoken figures through a private grouped(_:), the capture device's own grouping — it is en_UZ; not run.) (stage 5, compiled and not run: both methods tap Get Started, shoot the goal step, and walk on with Continue, Continue and Not now through tapWhenReady; 540 lines before) NOT a test — the App Store capture harness. Two methods, both deliberately non-idempotent and both SKIPPED by the gate (`-skip-testing:`): the 4-shot store set (run 2026-10-09, after its stale *Last 7 days* query was fixed — committed in `12ddfc4`) and the 25-shot full census (same fix, not run). 2026-10-11, `1ced514`, compiled and not run: its six waits for History look for the `+` button, *Add a serving*, where they looked for a static text *Today* — which is now Home's heading as well. Unstaged 2026-10-12, stage 3b's second pass: its `returnToTop` works again on every system — a page is rebuilt when its tab is shown — and the comment on it says what the container is now; still not run (#82)
WaterBuddyUITests/GoalSetupUITests.swift        1296   (2026-10-17, 1.2.6: 38 tests — total(in:), waitForTotal and millilitres(on:) read grouped figures, as do the Undo and the sheet's-shortcut sites; the chip's and the strip's spoken values checked, and testTheChipSpeaksItsNounAtTheLargestTextSize and testTheStripSpeaksItsCountAtTheLargestTextSize added; the strip's "second element" check dropped by the owner's decision, #139.) (stage 5: eleven Get Started preambles are now completeWelcomeIfShown(app), the class's DocC says the welcome; still 36 tests; 1236 lines before) (stage 4, staged 2026-10-13, 36 tests: testSettingsSaysWhichVesselTheOneTapDoorsLog — the new note drawn, the old one not; testEverySettingsControlIsOneElement — the goal slider, three vessel sliders, the switch and four language rows one element each, a guard green before and after; 1196 lines before) (2026-10-13, stage 3c, staged, 34 tests: testEveryDayOnTheWeekCardIsATapTarget — every day button at least 44 × 44, which bites on a 375-pt phone) (second pass of stage 3b, unstaged 2026-10-12, 33 tests: one more — once a change of tab has ended only the page shown is in the tree — and `testAKeptScreenAnswersATapWhenItIsShownAgain` is `testAScreenAnswersATapWhenItIsShownAgain`) (unstaged 2026-10-12, stage 3b, seven tests: the title holds its place on every tab, and where its accessory is taller; a screen comes back whole, read off the picture of all three; a kept screen answers a tap; a press dragged along Apple's bar; the app's own bar's captions share a line; History returns to today) setup, the a11y tree, the tab swap, the Settings tab, the week card (one summary, one button per day), a serving row tapped on its bare glass; staged 2026-10-11, the redesign's stage 3, History: a serving added to yesterday (read off the day's total, and listed as one button in its row), the strip's one heading, the sheet's three shortcuts (one button each, the shown amount's selected, a tap sets the amount), and three at the largest text size — the shortcuts' figures whole, a row's amount whole, a past day's heading not squeezed and one element; 2026-10-11, `1ced514`, Home: one heading, the status line and the title never squeezed, Undo (takes back the last pour only, expires, does not outlive its tab or the app leaving the screen, an older pour's timer does not end a newer offer, its amount drawn whole at the largest text size), a disc and Undo tapped off their glyphs
WaterBuddyUITests/PremiumUITests.swift           160   (2026-10-24, set A's step 4, staged: +1, `testAFreeUsersInsightsAreLockedAndOpenThePaywall`; the paywall's row is *Personal insights*) (2026-10-23, set A's step 2, staged: +2 — `testAnOrdinaryRunsHistoryHasNoMonthSwitch`, `testAFreeUsersMonthIsLockedAndOpensThePaywall`) (2026-10-22, step 1's Task 7, staged: both tests rewritten — `testAnOrdinaryRunHasNoPremiumCard` waits three seconds for a card that must not come; `testTheCardLeadsSettingsAndOpensThePaywall` — the card one element and above the goal, the sheet's line and promise, each feature row one element counted by its whole label (`"<title>, "`, the owner's ruling — XCUITest also lists the row's own title, `tasks/lessons.md` 2026-10-17 and 2026-10-22), the four links and *Not now* one element each, *Not now* closing it; 64 lines before) new 2026-10-21 (1.4.1's Task 6, staged; superseded by the above): the only class launched with `-WaterBuddyPremium` — `testAnOrdinaryRunHasNoPremiumCard` and `testTheCardOpensThePaywall` (the card one element, the sheet's title, promise, *Restore Purchases*, both links and *Not now* one element each, *Not now* closing it); asserts nothing that needs products to load
WaterBuddyUITests/WaterBuddyUITests.swift         41   template
WaterBuddyUITests/WaterBuddyUITestsLaunchTests.swift   33   template
WaterBuddyUITests/WelcomeUITests.swift           378   (2026-10-17, 1.2.6: its 18 spoken figures through a private spoken(_:), the device's grouping.) stage 5 — 13 tests, each launched with -WaterBuddyFreshStart: the welcome walked forward and back, every control one element, walkable at the largest text size, the shared walk lands on Home, a vessel set in the welcome is the one Home pours, a vessel edited in Settings saved as before, a step's title where a tab's stands, a double tap moves one step; the calculator — Use sets the goal it suggests, the activity moves only the suggestion, the unit switch converts the weight, Use comes back when the goal moves away, a step is as it was left when Back returns. At file scope: tapWhenReady(_:) (waits for the button to exist and be enabled, then taps — the capture harness uses it too) and completeWelcomeIfShown(_:), which GoalSetupUITests calls eleven times
WaterBuddyWidget/AddWaterIntent.swift            148   writes: runs DataManager in the extension — for both widgets' + and the Control Center control; authenticationPolicy written out, .alwaysAllowed
WaterBuddyWidget/LockScreenWidget.swift          346   (2026-10-17, 1.2.6: four sentences through localized — the .privacy branch's Log Water untouched; spokenFigures(in:locale:); LockScreenCard and LockScreenPourButton read the locale.) the Lock Screen widget (kind "WaterBuddyLockScreen"): circle, rectangle with the + (AddWaterIntent(amount: serving), the serving handed down from entry.snapshot), line — over the same HydrationProvider; every figure privacySensitive, a quiet form under .privacy; strings read only in child views
WaterBuddyWidget/LogWaterControl.swift            83   the Control Center control (kind "WaterBuddyLogWater", iOS 18): ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving)), titled Log Water in the snapshot's language, the glyph at DataManager.usualSlot, no figure; LogWaterControlProvider reads DataManager.snapshot(now:)
WaterBuddyWidget/WaterBuddyWidget.swift          779   (2026-10-19, 1.3.1 6c, staged: `widgetCard()`, the card both Home Screen widgets draw; `cardInset` and `cardPadding` internal; `WaterSnapshot.sample(at:)` carries a week for the gallery; the pour button's comment names the primary surface; 756 lines before) (2026-10-19, 1.3.1: 6a — 659, committed in 5a46609 — PourSurface, the pour button on the primary surface in full colour and white in the lit rim on a template; 6b, staged — SmallLayout(snapshot:bare:), the bare layout HydrationView picks when showsWidgetContainerBackground is false, widgetPane(glass:), MiniVessel's bare flag and quiet form under .privacy, three previews.) (2026-10-17, 1.2.6: five sentences through localized; MediumColumn, MiniVessel and PourButton read the locale.) reads the cache only, never SwiftData — the Home Screen widget; HydrationView reads no string itself, MediumColumn does; PourButton internal (its minimumTarget is the Lock Screen button's too)
WaterBuddyWidget/WaterBuddyWidgetBundle.swift     24   (2026-10-19, 1.3.1 6c, staged: WeekWidget listed after WaterBuddyWidget; 23 lines before) three widgets, WaterBuddyWidget, WeekWidget and LockScreenWidget, and inside if #available(iOS 18.0, *) the control, LogWaterControl
WaterBuddyWidget/WeekWidget.swift                242   new 2026-10-19, 1.3.1 6c, staged — the week widget (kind "WaterBuddyWeek", .systemMedium only): HydrationProvider's entry, `entry.snapshot.week(endingOn:calendar:)`; WeekCard — the title, the days met, seven bars on white 0.10 tracks against the dashed goal line, the narrow weekday letters; the type capped at `.accessibility1` in `WeekView`, above the card's `@ScaledMetric` (the final review's fix — not #76's shape); one VoiceOver element; *Open WaterBuddy to see your week.* when no week is cached; `widgetCard()` and `.widgetURL(WidgetLink.history)`; no button
WaterBuddyWatch/WaterBuddyWatchApp.swift          77   watch app only — activates WristLink.live, .backgroundTask(.watchConnectivity) (which now awaits WristLink.waitForPendingDelivery() rather than returning at once), and WristRoot: \.strings + \.locale from WristModel.language, above WristView
WaterBuddyWatch/WristAurora.swift                 48   watch app only — WidgetAurora's proportional-geometry shape, mirrored for the watch canvas
WaterBuddyWatch/WristColumn.swift                 88   (2026-10-20, 1.3.2 7b, staged, new) watch app only — WristColumn: Layout, the screen's column: the vessel takes what the line and the row leave of WristView.columnHeight, between its floor and ceiling; the sync caption, its last child, gives way to the vessel; arrangement(height:width:heights:range:) and diameter(available:others:range:) are its pure arithmetic
WaterBuddyWatch/WristModel.swift                 314   (2026-10-20, 1.3.2 7b, staged: face, WristPlan.face over the same store; displayGoal and todaysTotal read through it; 305 lines before) (2026-10-17, 1.2.6: one DocC mention of attribution(mirror:now:strings:locale:); the count did not move.) watch app only, NOT shared — @Observable @MainActor, the watch's only writer to its own local suite; language, the phone's in-app choice read off the mirror; reloads the complication on every pour and every mirror that is news, and never takes a mirror older than the one held
WaterBuddyWatch/WristVessel.swift                117   (2026-10-20, 1.3.2 7b, staged: a display again — takes a WristPlan.Face, one VoiceOver element with the label and the vessel's sentence; draws the percentage only, the figure at 0.32 of the diameter and the "%" at signSize(diameter:), never under 14 pt bold; the scrim full by 32%, re-derived from the percentage's ink; readout and diameter(fitting:reserving:) removed. The two sentences after this note are history; 139 lines before) (2026-10-17, 1.2.6: readout through figure, its DocC rewritten.) watch app only — the one vessel, WaterSurface + WaterReadabilityScrim + readout; scrimIntensity(at:) is its own scrim ramp, none at 0% and full by 20% (known issue #35), never the widget's; readout(volume:goal:strings:locale:) groups per language; NOT self-describing to VoiceOver since it became a Button's label
WaterBuddyWatch/WristView.swift                  498   (2026-10-20, 1.3.2 7b, staged: the canvas's screen — the vessel, the millilitre line under it, WristPourRow (Cup and Bottle as interactive glass discs, the Glass the primary surface, a capsule carrying its amount where it fits, ViewThatFits then a sideways scroll), the caption; pourRow, pourLabel, amountLabel, vesselRange, columnHeight, columnShare, discDiameter; the More sheet, vesselHeightFraction and primaryIndex gone, DataManager.usualSlot in its place. The sentence after the notes is history; 477 lines before) (2026-10-20, 1.3.2 7a, committed in 90fef5d: the More capsule and the sheet's rows are interactive: true — regular, tinted glass under a label, #91(b).) (2026-10-17, 1.2.6: four sentences through localized; syncedCaption and attribution take locale:; WristView and WristServingMenu read the locale.) watch app only — the one screen: the vessel IS the pour button, one "More" button over a sheet, "Synced Nm ago"; every string through \.strings
WaterBuddyWatchTests/WristGlassTests.swift        23   (2026-10-20, 1.3.2 7a, staged, new) WristGlassTests (not @MainActor) — theWatchDrawsAppleGlass: the watch's half of theAvailabilityFlagMatchesTheRunningSystem, the runtime checked against the 26.0 floor first
WaterBuddyWatchTests/WristLinkCompileTests.swift  21   compile-time canary — WristLink stays non-@MainActor and Sendable
WaterBuddyWatchTests/WristLinkDeliveryTests.swift 56   WristLinkDeliveryTests (not @MainActor) — how long a background wake is held open: WristLink.poll stops when delivery is done, gives up after its last check, ends when cancelled
WaterBuddyWatchTests/WristModelTests.swift       462   (2026-10-20, 1.3.2 7b, staged: theModelsFaceIsThePlansFace; 443 lines before) WristModelTests — pour, apply, isMirrorStale, todaysTotal, reconstruction, the phone's day end through the model, the language the watch draws in, when the face reloads, and which mirror wins
WaterBuddyWatchTests/WristPlanCompileTests.swift  20   compile-time canary — WristPlan stays free of actor isolation
WaterBuddyWatchTests/WristVesselLayoutTests.swift 120  (2026-10-20, 1.3.2 7b, staged: the two diameter(fitting:reserving:) tests removed (#84(d)); the column — the vessel takes what the line and the row leave, the caption gives way to it, the height runs into the bottom inset to the canvas's margin; the row — an even share per column, a disc giving way to the floor below the accessibility sizes and keeping its size at them; the ceiling as the canvas's share; the "%" kept large text; 49 lines before) diameter(fitting:within:) against five real watch width/height pairs
WaterBuddyWatchTests/WristViewLogicTests.swift   388   (2026-10-20, 1.3.2 7b, staged: the pour row's five — order and amounts, a short or empty mirror keeping the Glass, a litre grouped, the phone's sentence in en/ru/uz, the phone's language followed; the readout test rewritten for the line under the vessel; the scrim's tests rewritten for the percentage — full before water reaches it, and still ramping below. The sentence after the notes is history; 323 lines before) (2026-10-17, 1.2.6: the 17 calls of syncedCaption and attribution pass locale:; the count did not move.) the pure logic WristView composes — servings resolution, which one the vessel pours, what the menu gets, attribution in en/ru/uz, serving names, the grouped readout, and the vessel's scrim ramp (full before water can reach the millilitre line, on every diameter)
WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift 88   (2026-10-21, 1.3.2 7c, staged: WristWidgetEntry carries a WristPlan.Face and an AppLanguage from the mirror; the provider calls WristPlan.face(…); three families; the view is WristFaceRoot; 95 lines before) .accessoryCircular percentage ring — reads Key.wristMirror + Key.wristOutbox directly, never WristModel.shared; WristPlan's arithmetic; entries at the phone's day end and the watch's midnight, policy .atEnd (no longer a 15-minute timer); its description is the phone's own "Today's hydration"
WaterBuddyWatchWidget/WaterBuddyWatchWidgetBundle.swift 9
WaterBuddyWatchWidget/WristFaceView.swift       209   (2026-10-21, 1.3.2 7c, staged, new) the three faces: WristFaceRoot (the background, \.strings and \.locale from the entry's language), WristFaceView(face:family:), the ring, the corner (the percentage on one line, a curved gauge as its widgetLabel, accentable, hidden from VoiceOver) and the card (the drop, Hydration and the percentage; the screen's line; a bar) — each one VoiceOver element, Today's hydration with the vessel's sentence, and a quiet form under .privacy that draws and speaks no figure; three previews
```

**81 `.swift` files across the seven target folders**, all listed above — 84 with the three
scripts in `Tools/`. Re-derived 2026-10-14 for the redesign's stage 5, from the index with `git
ls-files` and a script that compares each row's count with its file: the stage's seven new files
have rows, `GoalSetupView.swift`'s row is gone with the file, and every row matches `wc -l`. *(It
read 75 and 78 until this edit.)* Before that: re-derived 2026-10-12 in the fifty-third pass, after stage 3b's second
pass, by the same script: **eight files were undocumented, the pass's own** (`Motion`,
`PageTurn`, `PourDrop`, `ScrollDepth` and a test file for each), and **eleven counts stale, the
eleven existing files it edits** (`Arrival`, `AuroraBackground`, `HistoryView`, `HomeView`,
`RootTabView`, `SettingsView`, `ArrivalTests`, `AuroraBackgroundTests`, `HistoryViewTests`,
`AppStoreScreenshotUITests`, `GoalSetupUITests`); 78 rows compared with their files after the
edit, none stale. *(It read 67 and 70 until this pass.)* Before that: re-derived 2026-10-12 in
the fifty-first pass, at the end of the redesign's stage 3b, with `find` over all seven and `Tools/` against this file: **four files were
undocumented, the stage's own** (`Arrival`, `ScreenHeader`, `ArrivalTests`,
`ScreenHeaderTests`), and **eleven counts stale, the eleven existing files it edits**
(`AuroraBackground`, `Haptics`, `HistoryView`, `HomeView`, `RootTabView`, `SettingsView`,
`AuroraBackgroundTests`, `CelebrationTests`, `HomeViewTests`, `RootTabViewTests`,
`GoalSetupUITests`); every row was compared with its file by a script after the edit. *(It read
63 until this pass.)* Before that: re-derived 2026-10-11 in
the fiftieth pass with `find` over all seven and `Tools/`, and a script that compares each row's
count with its file: no file undocumented, no phantom row, and **ten counts stale — the ten
Swift files the redesign's stage 3 and #92's fix edit** (`AuroraBackground`, `DataManager`,
`HistoryView`, `HomeView`, `HistoryRangeTests`, `HistoryViewTests`, `LocalizationTests`,
`UnreadableStore`, `WristSyncTests`, `GoalSetupUITests`); re-run after the edit, 66 rows, none
stale. Stage 3 adds no file. Before that, the forty-sixth pass, the same day,
with `find` over all seven and a two-way comparison against this file: three
files were undocumented, stage 2's own (`HomeModelTests`, `StreakTests`, `UnreadableStore`), and
eight counts were stale, eight of the nine files stage 2 edits; `AppStoreScreenshotUITests` was
edited and kept its 541 lines. The 66 counts here — 63 files and the three Swift scripts below —
were re-checked against the files by a script after the edit: none wrong, none undocumented. *(It read 60 files until this pass.)* Before that:
re-derived 2026-10-09 in
the forty-third pass with `find` over all seven and a two-way comparison against this file: no
phantom row and no new file. **Six counts were stale, the redesign's stage 1's own six files**
(`GoalSetupView`, `HistoryView`, `LiquidGlassModifier`, `PressStyle`, `RootTabView`,
`LiquidGlassTests`); the 63 were re-checked against the files by a script after the edit. Before
that: re-derived 2026-10-08 in
the thirty-eighth pass with `find` over all seven and a two-way comparison against this file: no
phantom row, and the change's one new file — `LogWaterControl.swift` — now listed. The 63 line counts
here (60 files and the three Swift scripts below) were re-checked against `wc -l` by a script after the
edit: none stale. *(This paragraph read 58 files until the thirty-eighth pass — one short since
`LockScreenWidget.swift` joined: HEAD `be31994` tracks 59. The thirty-eighth pass found 5 stale counts
— the change's own five edited files — and one file undocumented; the thirty-seventh, 2 stale and one
undocumented; the thirty-fifth pass found 1 stale of 58, the thirty-fourth 3 of 57, the thirty-third 6 of 56, the thirty-second 4, the
thirty-first 5, the thirtieth 2, the twenty-ninth 8 of 56, the twenty-eighth 7 of 55 on 2026-10-05.)*

### Outside every target

`Tools/` sits outside all seven `PBXFileSystemSynchronizedRootGroup`s, so nothing in it is compiled
into anything (rule `15-project`). It is **not** part of the 81 above (read "53" until the
thirty-eighth pass, "60" until the forty-seventh, "63" until the fifty-fourth, and "75" until
stage 5, while the paragraph it points at went on to 81), which is why earlier passes' "every file is documented" claim was true while
omitting it:

```
Tools/GenerateAppIcon.swift                      267   generates the three iOS icon variants at 1024². Run: swift Tools/GenerateAppIcon.swift. Does NOT own the watch icon — see known issue #34
Tools/FlattenPNG.swift                            99   re-encodes a PNG to colour type 2, RGB untouched. Required for every watch capture: simctl writes RGBA on watchOS even with --mask=ignored
Tools/ComposeStoreScreenshot.swift               161   composites an unaltered iPhone screen onto the product's own aurora at a target slot size — how the iPad 13" set was made (see below)
Tools/CaptureScreenshots.sh                        —   the iPhone App Store set. WATERBUDDY_SCREENSHOT_SLOT picks iPhone-6.9 (default) or iPhone-6.5. Its default device is gone — known issue #45. It no longer overrides the status bar's clock (2026-10-09, committed in `12ddfc4`). *(2026-10-18, 1.2.8, staged: it finds the phone by name and runtime — iPhone 18 Pro Max, iOS 27.0, the first of two; WATERBUDDY_SCREENSHOT_PHONE still takes a UDID — so its half of #45 is fixed; no dirty-device gate, since the harness starts clean; the clock frozen again, at the run's start, in 24-hour form, the owner's ruling; DerivedData kept between runs. Run end to end twice.)* *(2026-10-18, #144, staged with 1.2.8: the clock is read once at the top and a run outside 1:45–11:45 PM is refused there, before the boot and the build — the harness keeps its own check — and the time checked is the time frozen; its header and `--time` comment say what the code and the 1.2.8 transcript show. Proved by fake-clock runs against a device name nothing matches; not run end to end since.)*
Tools/CaptureFullCensus.sh                         —   the 25-shot coverage run, every screen/state/scroll position. Its default device is gone — #45
Tools/CaptureWatchScreenshot.sh                    —   the watch capture. WATERBUDDY_SCREENSHOT_NOWAIT=1 shoots the empty state unattended. Its default device is gone, and it repeats two claims since found false — #45
Tools/VerifyScreenshots.sh                         —   proves each capture's size/alpha/format against the slot it will be uploaded to
Tools/RenameScreenshots.py                         —   xcresult attachment UUIDs → slot names, via manifest.json
Tools/ProductPageHeader.html                     —   the App Store product page header (staged 2026-10-13): the redesign's vessel, discs and "One tap. Watch it fill." over the aurora, 1920 × 823 CSS px rendered at 2× by headless Chrome to Screenshots/en-US/ProductPageHeader/01-one-tap.png (3840 × 1646, no alpha); the render command is in its header comment
```

None of these carries the executable bit: `Bash(chmod:*)` is on this project's permission deny list,
so they are invoked as `bash Tools/<name>.sh` and `swift Tools/<name>.swift`.

### Shipped, but not Swift

```
WaterBuddy/PrivacyInfo.xcprivacy                  —   \
WaterBuddyWidget/PrivacyInfo.xcprivacy            —    | four byte-identical manifests, one per shipping
WaterBuddyWatch/PrivacyInfo.xcprivacy             —    | bundle. Each target's synchronized root group
WaterBuddyWatchWidget/PrivacyInfo.xcprivacy       —   /  gives membership with NO project.pbxproj edit
Screenshots/en-US/iPhone-6.9/*.png                4    the 6.9" store set, 1320x2868 — recaptured 2026-10-09 from 8a44e8f (1.1) on iOS 27.0; committed in 96ca467 (#88). *(2026-10-18, 1.2.8: retaken of the redesign at 15:06 on iOS 27.0, iPhone 18 Pro Max, over a lived-in week — staged, not committed.)*
Screenshots/en-US/AppleWatch/01-wrist.png         1    416x496 — the empty state (known issue #32), from 2026-09-02; kept until a new watch capture exists
Screenshots/en-US/ProductPageHeader/01-one-tap.png 1  3840x1646, no alpha — the App Store product page header (iOS 27's), from Tools/ProductPageHeader.html; staged 2026-10-13, shows the redesign, so it goes up with 1.2
Screenshots/census/AppleWatch/*.png               9    coverage run, five sizes plus four driven states, from 2026-09-02; untracked
```

*(2026-10-21, 1.4.1, staged.)* And one file that is neither Swift nor shipped:
`WaterBuddyTests/WaterBuddy.storekit` (105 lines; 78 before 2026-10-22) — the local StoreKit
configuration, three products at placeholder prices: $2.99 a month (no introductory offer, group
level 2 — step 1's Task 5, staged), $19.99 a year with a free week (level 1) and $39.99 once. On this
Mac's simulators — every one of them `en_UZ` — StoreKit testing reads those prices whole: `Product.price`
answers 2, 19 and 39 while `displayPrice` draws $2.99, $19.99 and $39.99 (#162). It joins the test target
through its synchronized folder with no `project.pbxproj` edit and lands in `WaterBuddyTests.xctest`
alone — `find` over a probe build's products, 2026-10-21. `SKTestSession` reads it; from 1.4.1's
Task 7, so will the `WaterBuddy` scheme's Run action (rule `15-project`).

Gone from disk since 2026-10-09, on the owner's word ("delete the all other items"): `Screenshots/en-US/iPhone-6.5/`
and `Screenshots/en-US/iPad-13/` (four files each — in `8a44e8f`, deleted in `96ca467`) and
`Screenshots/census/iPhone-6.9/` (nineteen files git never tracked, so not recoverable).
`Tools/ComposeStoreScreenshot.swift`, which composited the iPad set, has no output left.

The four `PrivacyInfo.xcprivacy` files are a **submission blocker**, not paperwork: `UserDefaults` is
a required-reason API and Apple does not accept an upload that fails to declare one. See rule
`15-project`'s *Submission* section for the reason codes and why all four bundles need their own.

**Why an iPhone-only app has an iPad set** (committed `03d4fc8`, after the twenty-seventh pass, with
no checkpoint until this one). Apple's spec asks for the 13″ iPad set only "if app runs on iPad", and
this app does not (`UIDeviceFamily [1]`); App Store Connect offers the tab anyway until a build has
been processed. Filled with a raw iPad-simulator capture, the slot would show the app inside the
iPad's floating compatibility window — the desktop rather than the product, and the kind of asset
App Review 2.3.3 objects to. So the four images are the real, unaltered iPhone screens scaled onto
the product's own aurora. The reasoning is `Tools/ComposeStoreScreenshot.swift`'s own header; this
paragraph only points at it.

`AuroraBackground` and `PressStyle` were `private` inside `HomeView.swift` until `GoalSetupView`
(the first-run screen until stage 5, `WelcomeView` since) became a second consumer. They are **app-only**: the widget re-expresses the same lights itself in
`WidgetAurora`, because the app's absolute ±240pt offsets mean nothing on a 158pt canvas. Only the
colours in `Aurora` are shared between the two processes.

Plus four entitlements files, one per signed target — `Entitlements/WaterBuddy.entitlements`,
`Entitlements/WaterBuddyWidgetExtension.entitlements`, `Entitlements/WaterBuddyWatch.entitlements`
and `Entitlements/WaterBuddyWatchWidgetExtension.entitlements`, each declaring
`group.sardor.WaterBuddy` (rule `15-project`'s *Signing*) — and two hand-written Info.plists at
the repository root, `WaterBuddyWidget-Info.plist` and `WaterBuddyWatchWidget-Info.plist`, each
wired by `INFOPLIST_FILE` with `GENERATE_INFOPLIST_FILE = NO`; in each, `NSExtension` holds
`NSExtensionPointIdentifier = com.apple.widgetkit-extension` and nothing else. *(This sentence
named only the first two entitlements files until the twenty-eighth pass, and only the phone
widget's plist until the forty-seventh; the watch widget's has existed since `a9bbdd5`.)*

And eight non-Swift build inputs — the five string catalogues and **three asset catalogues** —
plus one file that is deliberately *not* one. *(This line said "four" with three listed until the
twenty-ninth pass, and that pass's own "six" was off by one too; corrected by the same day's
re-run. "Six — the five string catalogues and the app icon set" stood from then until the
forty-eighth pass, which counted the catalogues in the tree: the table below had one row for the
app's icon set and none for the widget's catalogue or the watch's.)*

| | |
|---|---|
| `WaterBuddy/Localizable.xcstrings` | *(2026-10-24, set A's step 4, staged, counted by script: **226** keys — 222 in en/ru/uz, the same 4 deliberately not; +29 for Insights, five of them counted, and step 1's three insights keys replaced by *Personal insights*, *Each week, from your own figures, on your iPhone* and *Insights*. The Russian and Uzbek are drafts, #179.)* **197** keys — 193 translated into en/ru/uz, 4 deliberately not (`%`, `+%lld`, `1,450 ml`, `WaterBuddy`). *(2026-10-23, set A's step 3, staged, counted by script from the catalogue: +10 — the patterns' heading line, the chart's title and busiest hour, *Weekdays*, *Weekends*, a side's figure drawn and spoken, the two tiles and the pending line; two counted, with their plural forms; *Patterns* reused from the paywall; the Russian and Uzbek are drafts, #175.)* *(2026-10-23, set A's step 2, staged, counted by script from the catalogue: +20 — the switch, the month's figures, the legend, the locked month and the change line; five counted, with their plural forms; the Russian and Uzbek values are the session's drafts, for the owner's sweep.)* *(2026-10-22, the eighty-first pass, counted by script from the catalogue: step 1's Task 6, staged, adds 27 — the monthly plan's words, the tiles' lines, set A's four features, the card's three captions, *Done* and *No purchases to restore.* The row read 110 until this pass, stale twice over: 113 at `0be24f9` and 140 at `b981374`, where 1.4.1's 27 were never counted here.)* *(2026-10-18, roadmap item 1.3.4, staged: five manual keys for Siri's *Today's Water* — its title, its description and its three answers, the answers with explicit positional `%1$lld`/`%2$lld` keys and plural variations in en and ru. 105 before; counted by script, the file checked to round-trip byte-identically through sorted JSON.)* *(2026-10-17, roadmap item 1.2.6: two new manual keys, `%1$d days` and `%1$d servings`; nine keys gained plural variations — English one/other, Russian one/few/many/other, Uzbek one value — compiled into `Localizable.stringsdict`. 103 before.)* *(75 and 71 until the redesign's stage 5, staged 2026-10-14: 28 keys for the welcome, none removed. Counted by script from the catalogue, as staged and at HEAD.)* *(73 and 69 until the redesign's stage 3, staged 2026-10-11: six keys for History — `Average`, `Best day`, `Goal met`, `%1$@ of %2$@`, `When you drank` and the week card's spoken summary with the days met — and four removed with their last readers: `%1$d of %2$d ml`, `Average %1$d ml`, `Best %1$d ml` and the two-figure spoken summary. Counted by script from the catalogue, as staged and at HEAD.)* *(64 and 60 until the redesign's stage 2, `1ced514`: ten keys for Home — four grouped figures that take `%n$@`, the spoken `%1$d millilitres to go`, `Goal reached`, the two times, `Undo`, `Day streak` — and `%1$d / %2$d ml` removed with its only reader. Counted by script from the catalogue.)* The explicit `en` values are what make the build emit an `en.lproj` to select. *(Read 58 until the thirty-sixth pass — three passes after the earlier-servings change had made it 61.)* |
| `WaterBuddy/AppShortcuts.xcstrings` | **6** phrases, **en and ru only** — Siri has no Uzbek, so this is the one catalogue that does not ship all three. Keys are the English phrases with `${applicationName}`; the build compiles `en.lproj`/`ru.lproj` `AppShortcuts.strings` (`AppShortcutPhraseTests`). *(2026-10-18, roadmap item 1.3.4, staged: three for *Today's Water* — *How much water today in*, *How much water have I had in*, *Check my water in* — and in Russian *Сколько воды сегодня в*, *Сколько осталось выпить в*, *Проверь воду в*; 3 before. The open Xcode rewrote this file again mid-task, and the owner closed the project and chose to restore it to `HEAD` before the phrases were added, so the tree now holds no
Xcode rewrite of it; what follows is this row's earlier text.)* As committed before 1.3.4; **the working-tree copy is Xcode's unstaged rewrite, which marks two of the three phrases `"extractionState" : "stale"`** (known issue #50) *(2026-10-17: discarded by the owner's choice — 1.2.6's decision D7 — so the tree matches the commit; an IDE build writes it again)* |
| `WaterBuddyWidget/Localizable.xcstrings` | **19** keys — **15** in en/ru/uz: the 10 hand-written as a strict subset of the app's (a membership exception cannot carry a resource) plus `AddWaterIntent`'s five Shortcuts strings, translated since before the repository's first commit (known issue #1, retired 2026-10-06); and **4 the build extracted** (`%`, `+%lld`, `1,450 ml`, `Today`) with no values at all, which reach no compiled table. *(This row called all nine extracted keys untranslated until the twenty-ninth pass.)* *(2026-10-17, roadmap item 1.2.6: the percentage key and `Add %1$d millilitres` carry plural variations, value for value the app's.)* |
| `WaterBuddyWatch/Localizable.xcstrings` | **16** keys as committed — **19 in the working tree**, where Xcode's unstaged rewrite appends three it extracted with no values (`+%lld`, `1,450 ml`, `Today`; known issue #50) — 15 in en/ru/uz (six copied value for value from the app's catalogue, nine the watch's own) and `%`, en only. Written by a script that copies the shared keys, and held to the phone's own strings by `LocalizationTests` through the built phone app *(2026-10-17, roadmap item 1.2.6: the percentage key and `Logs %1$d millilitres` carry plural variations, edited by hand in the file's own style; Xcode's rewrite discarded (D7), so the tree holds the 16 again until an IDE build writes it back)* *(2026-10-20, roadmap item 1.3.2's stage 7b, staged: **14** keys — `%1$@ of %2$@ ml` and `%1$@, add %2$d millilitres` copied from the app's catalogue value for value, with the latter's plural variations; `%1$@ / %2$@ ml`, `Logs %1$d millilitres`, `More` and `Shows the other serving sizes` removed. Edited by hand with Xcode holding no WaterBuddy file; the file round-trips through `json.dumps(…, indent=2)` byte for byte)* |
| `WaterBuddyWatchWidget/Localizable.xcstrings` | **2** keys as committed — **6 in the working tree**, with four Xcode extracted and left empty (`%lld`, `+%lld`, `1,450 ml`, `Today`; #50) — `Today's hydration` (the complication's description, the phone's own string) in en/ru/uz, and `WaterBuddy`, en only and never translated *(2026-10-17: Xcode's rewrite discarded (1.2.6's D7); the tree holds the 2)* *(2026-10-21, 1.3.2's stage 7c, staged: **5** keys — `%1$@ of %2$@ ml`, `%1$d percent. %2$d of %3$d millilitres.` and `Hydration` join, each the app catalogue's entry value for value, plural forms included; Xcode's rewrite of this file was restored to `HEAD` first, on the owner's word, so the four empty extracted keys are gone from the tree)* |
| `WaterBuddy/Assets.xcassets` | `AppIcon.appiconset/AppIcon-{light,dark,tinted}.png`, 1024², generated; and `AccentColor.colorset` |
| `WaterBuddyWidget/Assets.xcassets` | `AccentColor.colorset` and `WidgetBackground.colorset` — no icon |
| `WaterBuddyWatch/Assets.xcassets` | `AppIcon.appiconset/AppIcon.png`, 1024², the modern `universal` + `"platform" : "watchos"` form (rule `15-project`, *Submission*) — not made by the generator; and `AccentColor.colorset` |
| `Tools/GenerateAppIcon.swift` | **not in any target.** `Tools/` is not a synchronized root, which is the point — a `.swift` file in `WaterBuddy/` would join the app, and this one imports AppKit |

## Non-negotiables

These are the ones that a passing test suite cannot protect. Full reasoning lives in the DocC and
in `.claude/rules/`.

1. **`DataManager` is the only writer to the phone's SwiftData/`UserDefaults` pair** — one writer
   per store, not "the only writer" full stop, since `WristModel` is the identical thing for the
   watch's own local suite (non-negotiable #23). On the phone, views, intents and providers never
   touch `UserDefaults` or a `ModelContext` directly; the watch's complication reads the watch's
   own suite itself, by design.
2. **`addWater` / `removeWater` call `refresh()` first.** Two processes hold their own instance;
   a stale one would write `staleTotal + amount` over a newer figure.
3. **The widget reads through `WaterSnapshot`, never `DataManager.shared`.** Constructing a
   `DataManager` there can roll the day over — zero the total, stamp the day, ring the widget
   doorbell — and recomputes today from the rows: writes from a process whose job is to draw.
   *(Read "is four writes" until the forty-ninth pass; two of the four it meant, materialising the
   goal and the fresh-install stamp, are guarded and do not happen in an extension.)*
4. **Reset writes the zero *before* it stamps the day.** The opposite order launders yesterday's
   water into today. Since the log became the source of truth this only clears the **cache** —
   yesterday's rows stay as history, and `resetDailyProgress()` is the one **reset** path that
   deletes rows (`deleteLog`, `undoLog` and `removeWater` delete them as ordinary edits).
5. **The day is a `yyyyMMdd` ordinal, never a `Date`.** An instant is re-read under the current
   time zone and travel would wipe a day.
6. **The container URL is the App Group probe** — `UserDefaults(suiteName:)` returns a live object
   even when the entitlement is missing.
7. **Only the app writes on behalf of the group** — the goal materialisation, the fresh-install
   day stamp, the one-shot migration and the seed from a cached total, drawing the history and
   the streak, and filing reminders are all guarded by `DataManager.role`, which as of 2026-08-31
   replaced the two-state `isAppExtension` at every guard site. Seven sites, the seventh stage
   2's. **The rollover's own stamp is not guarded.** See *The process role* below. *(Listed three
   of them, and "the day stamp" without the qualifier, until the forty-ninth pass.)*
8. **`isGoalSet` is never materialised.** Its absence carries meaning.
9. **No `Material` in the widget** — `LiquidGlass.Base.archived` is the measured stand-in.
10. **Today's total is derived, never authored.** It is the sum of today's logs, written through
    the `currentWater` setter so the clamp, the equality guard and the widget doorbell all still
    fire exactly once.
11. **A failed read must not write.** `recomputeToday()` leaves the total untouched when the store
    cannot be read; returning `[]` on error once turned a transient failure into permanent loss.
12. **Every test passes its own `ModelContainer`.** Omitting it resolves the *real* App Group
    store — see `tasks/lessons.md`. In-memory, except where a test needs a store that fails: those
    are file-backed in a temporary directory — `UnreadableStore`'s two users, and two tests in
    `WristSyncTests`. *(Read "builds an in-memory `ModelContainer`" until the forty-eighth pass.)*
13. **Reminders decide nothing at delivery time.** There is no fire-time hook for a local
    notification, so "skip this one" is an absence, not a filter — `ReminderPlan` is a pure value
    computed in advance. `removeAllPendingNotificationRequests()` is never called: from the
    extension it would clear the *app's* entire set (rule `80-notifications`).
14. **A read path may re-publish, but must not write back.** `refresh()` republishes
    `todaysLogs` and deliberately does *not* recompute the total from them: a cross-process
    SwiftData fetch can succeed while returning stale rows, and re-deriving would overwrite the
    widget's serving. See `tasks/lessons.md`.
15. **Nothing from `.claude/` or `CLAUDE.md` is a build input.** All seven
    `PBXResourcesBuildPhase` sections — one per target — are empty, counted in the forty-seventh
    pass. *(Read "all four" since before the watch's three targets joined.)*
16. **A type `DataManager` exposes lives *inside* `DataManager.swift`.** `WaterSnapshot`,
    `AppLanguage` and now `DaySummary` are declared at file scope in that one file rather than in
    files of their own. `DataManager.swift` is one of the six compiled into the widget extension,
    so a type it references from a separate app-only file is a break that appears **only** in the
    widget build — which the app scheme's green run never touches (rule `15-project`; **not so**
    — the app scheme's build compiles the extension, known issue #69 — and the widget's own build
    stays in the gate regardless).
17. **History never reaches the widget.** `republishHistory()` opens with
    `guard Self.role.drawsHistory`, because `recomputeToday()` deliberately carries no such guard and
    `AddWaterIntent` therefore reaches `saveAndRecompute()` on every widget tap. Without it, that
    tap would run a seven-day fetch and a full Swift-side roll-up inside a process whose entire job
    is to draw one number. A per-day series is derivable from none of the phone's ten cache keys, so
    there is nothing for `WaterSnapshot` to carry (rule `40-widget`).
18. **A past day is judged against the *current* goal, and the screen says so.** `Key.dailyGoal` is
    one scalar overwritten in place and `WaterLog` carries no goal, so nothing in either store can
    say what the goal *was* on a past day. `DaySummary` therefore has **no `goal` field** — one
    would be today's figure stamped onto every bar while looking like a record, and the next reader
    would believe it. The limitation is disclosed in the card's own copy.
19. **The two front doors agree by a shared read, not a shared constant.** The quick-add vessels are
    editable, and the middle one is what the widget's button logs and its face draws. Both resolve
    `Key.servings` from the App Group suite; `WaterSnapshot.serving` is how it crosses. A constant
    re-introduced on either side is the drift `defaultServing` used to prevent by being the only
    spelling, and `theWidgetsServingIsTheAppsMiddleVessel` asserts the read at an *edited* value so
    a constant would fail it. The Control Center control reads the same snapshot, and its glyph the
    same slot — `DataManager.usualSlot`, which `usualServing(in:)` reads too and
    `theUsualSlotIsTheGlass` pins to the Glass — so its tile and the amount it logs cannot drift.
20. **`WaterSnapshot.rolledOver()` is how the midnight entry is built, never a memberwise call.**
    Copying `self` and zeroing one field is what makes a forgotten field impossible. Built by
    enumeration, that entry silently reset `language` to `.system` — the widget reverted to the
    device language at local midnight, for two releases, invisibly.
21. **A `nonisolated static` that projects model state takes the state as a parameter.**
    `HomeView.servings(amounts:)` takes `[Int]`, not the `DataManager`. Reaching a `@MainActor`
    property from a `nonisolated` context needs `MainActor.assumeIsolated`, which *traps* when the
    assumption is wrong — a `precondition` in all but name, and this codebase has none.
22. **Which binary this is, is a four-state question — `DataManager.role`, not `isAppExtension`.**
    Landed 2026-08-31. Every `!Self.isAppExtension` guard is gone; a grep returns **zero**.
23. **"`DataManager` is the only writer" is now one writer per store, stated plainly rather than
    hidden.** `DataManager` remains the only writer to the phone's SwiftData/`UserDefaults` pair;
    `WristModel` is the only writer to the watch's own local App Group suite — a disjoint key set on
    a physically separate container that happens to share the phone's App Group *identifier*
    string. This weakening is recorded in both `.claude/rules/20-state.md` and
    `.claude/rules/10-architecture.md` deliberately, not just one — an earlier draft of the watchOS
    design flagged that leaving it in only one file would make the two rule files disagree.
24. **Three `PBXFileSystemSynchronizedBuildFileExceptionSet`s, not one.** The `target` field on each
    is scalar; `WaterBuddyWidgetExtension`, `WaterBuddyWatch` and `WaterBuddyWatchWidget` each carry
    their own (six files each: the two watch targets' sets are identical, and the phone widget's
    swaps `WristPlan.swift` for `NotificationManager.swift` — see *The six shared files* above). A
    file reaching one target through its set is invisible to the other two unless it is also listed
    in theirs. *(Read "six, six, and five" until the twenty-eighth pass; the
    watch widget's set reached six on 2026-09-01.)*

## The process role

`DataManager.role` (`DataManager.swift:2024`; read `:1996` until set A's step 5, `:1924` until set A's step 4, `:1787` until set A's step 2, `:1647` until 2026-10-20, `:1565`, a line of its DocC, until 1.2.5, and `:1564` until stage 5) resolves once, `nonisolated static let`, from
`isAppExtension` plus `#if os(watchOS)` — never a second runtime probe, which rule
`25-shared-storage` forbids because two probes can disagree and leave one guard open.

```
enum Role: Sendable, CaseIterable {   // DataManager.swift:2033 (read :2005 until set A's step 5; :1933 until set A's step 4; :1796 until set A's step 2; :1656 until 2026-10-20; :1574, a line of role's DocC, until 1.2.5)
    case phoneApp, phoneExtension, watchApp, watchExtension
}
```

`isAppExtension` was a **two-state answer to a four-state question**, and it answered it wrongly
for a watch: a watchOS app is a `.app`, so `pathExtension == "appex"` is `false` and every
`!isAppExtension` guard would *open* on the wrist. The enum asks four separate questions, each an
exhaustive `switch` with **no `default`**, so a fifth binary fails to compile until somebody
answers all four for it:

| Question | Gates | Sites |
|---|---|---|
| `ownsSharedStorage` | *is this container my own first-class home?* | `:654` goal materialisation, `:1513` fresh-install day stamp |
| `mayHaveLegacyStandardDefaults` | *has my `.standard` ever held WaterBuddy state?* | `:1434` `seedFromCachedTotalIfNeeded`, `:2168` `migrateIfNeeded` |
| `drawsHistory` | *do I have a history surface to draw?* | `:1106` `republishHistory` — since 1.3.1's 6c `draws \|\| cachingTheWeek`, the week's cache in any process that recomputes today — `:1167` `republishStreak` — **a seventh site, the redesign's stage 2** — `:1201` `republishMonth` — **an eighth, set A's step 2** — `:1287` `republishInsights` — **a ninth, set A's step 4** — `:1229` `recap(of:)` — **a tenth, set A's step 5** (staged; a read, publishing nothing) |
| `mayFileReminders` | *may I file notifications for this user?* | `:1768` `requestReminderReschedule` |

*(2026-10-24, set A's step 5: the lines above re-derived by `grep` for each guard's own words — its
insertions in `DataManager.swift` begin after line 1191; at `HEAD` `ad244c2` they read `:1485`, `:1406`,
`:2140`, `:1203`, `:1259` and `:1740`, and `role`/`Role` `:1996`/`:2005`.)*

*(2026-10-24, set A's step 4: every line above re-derived by `grep` for each guard's own words — step 4's
insertions in `DataManager.swift` begin at line 217, so all moved; at `HEAD` `5b511bd` they read `:633`,
`:1416`, `:1337`, `:2068`, `:1085`, `:1146`, `:1182`, `:1668`, and `role` and `Role` `:1924` and `:1933`.)*

**Nine sites since set A's step 4 (2026-10-24, staged); eight since set A's step 2 (2026-10-23); seven
since 2026-10-11, where there were six.** `republishStreak()` carries its own `drawsHistory` guard because the `dailyGoal` setter calls
it directly, outside `republishHistory()`; `republishMonth()` carries its own because `showMonth(_:)`,
`refresh()`, `saveAndRecompute()`, `dayDidTurn()` and the `dailyGoal` setter all call it, outside
`republishHistory()` too. Rule `25-shared-storage` still says "**Six** sites are guarded" and gives
`drawsHistory` one; the rule is the owner's (known issue #103).

*(Every `DataManager.swift` line in this table was re-derived on 2026-10-23, in the eighty-fifth pass,
by the words of each guard, on step 2's staged tree: step 2's Task 10 re-pointed `role` and `Role`
above and left the seven sites where `HEAD` `2e2f3a7` has them — `:592`, `:1294`, `:1215`, `:1931`,
`:1042`, `:1103`, `:1531` — each 41 to 137 lines short of the code; the eighth is new.
Before that, every line in this section was re-derived on 2026-10-20, in the seventy-fourth
pass, by the words of each guard, on 1.3.1's staged 6c: the section had stood since stage 5 while
the changes after it grew the file to 3,175 lines, so all nine had moved — `role` from `:1647`
to `:1787`, `Role` `:1656` to `:1796`, and the seven sites from `:551`, `:1162`, `:1083`, `:1709`,
`:969`, `:1000`, `:1329`. Before that, re-derived on 2026-10-14, for the redesign's
stage 5, by `grep` for each guard: the stage adds one comment line at `:1117`, so the five
citations below it moved by one — `role`, `Role`, the day stamp, the reschedule and the migration
— and `:551`, `:969`, `:1000` and `:1083` stand. The first build of this note moved only the first
two; a fresh reader found the other three. Before that, re-derived on 2026-10-11, in the fiftieth
pass, by `grep` for each guard: stage 3 adds 53 lines to the file, 15 of them above eight of these
nine citations, which each moved by 15; `:551` stands above them and did not move. Before that,
the forty-seventh pass, the same day: the file grew by 209 lines in stage 2 and the forty-sixth pass, which
recorded stage 2, left all eight citations where `b8a1386` had them — `role` documented at `:1400`,
standing at `:1549`. Before that, re-derived on 2026-10-09, in the fortieth pass: the
fix for #73 added four lines of DocC above the first site and nine in `loadFromStore()` above the last
three, so the six sites and the two in the code above all moved, by four or by thirteen. Before that, the
thirty-eighth pass's re-run the same day: all ten citations — the eight sites and the two in the code
above — had gone stale again: HEAD `be31994` already disagreed with every one (`role` documented at
`:1272`, standing at `:1380`), and that change's `usualSlot` moved three of them further. Previously
re-derived on 2026-10-07, when `requestReminderReschedule`'s guard was documented at `:847` and stood at
`:1067`.)*

Only `.phoneApp` answers `true` to any of them today. The fourth is the one whose wrong answer is
immediately user-visible: `ReminderPlan.Slot.identifier` is a pure function of day and hour, so a
second notification centre filing the same plan cannot dedupe against the first — two buzzes per
slot, or 28 silent `add` failures into a discarded `ReconcileOutcome`.

Pinned by `ProcessRoleTests` (`WaterSnapshotTests.swift:632`; `:519` until 6c's `WeekSnapshotTests`, added above it): `onlyThePhoneAppOwnsTheGroupsBookkeeping`,
`aWatchAppAnswersLikeAnExtensionAndNotLikeTheApp`, `theTestHostResolvesAsThePhoneApp`,
`everyRoleIsAccountedFor`.

**Two rule files named `!isAppExtension` for this until 2026-09-01** — `40-widget.md` and
`80-notifications.md` both quoted the same stale sentence about `requestReminderReschedule`. Fixed
on 2026-09-01, as part of the watchOS plan's final documentation task (owner edit, per rule
`99-docs-cascade`; `.claude/` is not something `/doc_sync` may touch on its own). See retired known
issue #15.

## Current state

**Set A's step 5 — roadmap item 1.4.7, the Monthly recap — is designed, specified, planned, built
test-first, walked, measured, reviewed, gated and staged whole; set A is on sale in code**, and a Release
build offers it only once the owner's privacy URL replaces the token (#159) — that, App Store Connect's
products (#155) and a device purchase (#156) are what stand between set A and a customer (2026-10-24;
HEAD `ad244c2`, nothing committed). Spec `docs/superpowers/specs/2026-10-24-monthly-recap-design.md`, with
§4a (Task 0's measurement), §4b (the walk) and §4c (the final review); plan
`docs/superpowers/plans/2026-10-24-monthly-recap.md`, executed inline.

- **What it is.** In Month mode a holder's finished month with water on seven or more days offers a
  *Monthly recap* row after its figures; the month holding today offers the month before's for its first
  seven days. The row opens a sheet: the card — the month, *23/30* days on goal, a dot a day, the litres,
  the daily average, the change from the month before — the best streak beside it, *Stays in the app, not
  on the image*, and *Share as an image* (`ShareLink`, the card rendered at 1,080 px, in memory only).
- **The model.** `MonthHistory.recap: Neighbour?` names the month a page offers, from rows `make` already
  has; `DataManager.recap(of:)` is a read — the month's two reads through `readMonth(_:)`, publishing
  nothing, writing neither store, behind `role.drawsHistory` — the **tenth guarded site** (*The process
  role*). No key, no stored figure.
- **The rulings** (the owner's, 2026-10-24): the turn of the month and the finished month's page; the
  streak in the sheet, off the image; Save to Photos left out if it needs the key; water on seven days;
  read when the sheet opens; the design's four sections; the spec; the plan. **Task 0 measured** that iOS
  offers *Save Image* only to an app with `NSPhotoLibraryAddUsageDescription` (27.0, 26.5, 18.6; a control
  with the key offered it), so `ShareLink` needs no exclusion and the app still asks for one permission.
- **Verified**: tests first (RED by compile, then behaviour; two mutation checks — the text-size pin and the
  shared PNG's pixels); the walk on *iPhone 17* (27.0) in a scratch copy — English, Russian, Uzbek, the
  largest text, Reduce Transparency forced, a lapse with the sheet open, a 31-day month at the maximum —
  three findings fixed and re-walked (W2–W4), one for the owner (#182); contrast off the renders, every
  pair over its floor after W4 (`docs/DESIGN.md`, *The recap, measured*); the final review, two Important
  fixed tests-first; the gate and the warnings below. **Not run**: anything on a device (#184).
- **The gate**, 2026-10-24, on the final code: 931 phone `@Test` — 929 passed, #157 skipped, #159 failing
  by design; UI 74 on 27.0 (1 skipped, #140's lost tap, passed alone) and 74 on 26.5 (1 skipped); 70 watch;
  both widget builds. **Warnings**: clean builds of a `HEAD` `ad244c2` export and of a copy of the index, by
  file and message — 20, 17, 2, 17 on both sides, 36 sites on the app scheme on both, no line new or gone.
- **Rule wording** for nine rule files — `70-privacy`'s *The recap's image, on the user's own tap* among
  them, and `25-shared-storage`'s tenth guarded site — is typed and unstaged for the owner.

**Set A's step 4 — roadmap item 1.4.12, Insights — is designed, specified, built test-first, walked,
measured, reviewed, gated and staged whole; no user meets it until step 5 puts set A on sale**
(2026-10-23, ~22:50, to 2026-10-24, ~02:30; HEAD `5b511bd`, nothing committed). Spec
`docs/superpowers/specs/2026-10-23-insights-design.md`, with §4a's amendments; no plan document — the
owner's "all ok go implementation".

- **What it is.** History's third mode, *Week · Month · Insights*. For a holder: *Insights*, then three
  frosted panes — *The one thing* (the week's range, the largest shortfall and a suggestion sized to the
  user's own vessel, or the best improvement and the average day), *What is working*, *Worth knowing* —
  and a footer saying who wrote it, *Not medical advice*. Below four days of water in the last finished
  week, *Insights need 4 days of water in a week · Next on …*. A free user meets the locked page, the
  locked month's view made one (`LockedPage`).
- **The app decides, the model words.** `WeekInsights` (pure, in `DataManager.swift`) works out the last
  finished calendar week from the locale's first weekday against the week before — six findings, a tenth
  of the goal and 50 ml as the threshold, figures to 50 ml — and picks the three parts; `DataManager`
  publishes it while asked (`showInsights(_:)`, the ninth `role.drawsHistory` site). `InsightCopy` writes
  the app's own sentences in three languages. `InsightWriter` — the one `import FoundationModels`,
  `SystemLanguageModel.default` only — rewords the English ones on an iPhone where the model is
  available, greedy, kept in memory, and draws its note only if each part adds no figure its fact lacks.
  Russian and Uzbek always read the app's sentences: the model speaks neither (measured).
- **The rulings**: the model writes, the app decides; a third mode; the last finished week; in memory,
  fixed wording; "Apple's on-device model", never *Apple Intelligence* (#164's naming half closed); the
  design's two sections; "all ok go implementation". The session's own, in §4a: the review's I1, I2,
  M3–M7 and the walk's W1, W2, W4.
- **Verified**: tests first (RED by compile, then by behaviour for the review's fixes); the walk on
  *WaterBuddy Probe 27* in a scratch copy — English, a stand-in model, Russian, Uzbek, the largest text,
  Reduce Transparency forced, the pending and the locked page — re-walked after the fixes; eleven colour
  pairs over 45 frames, all over their floors but the heading on the aurora (#177); the app run on iOS
  18.6 (the weak link); the gate and the warnings below. **Not run**: anything on a device (#178).
- **Gate**, on the final code: unit 908 in 102 suites — 906 passed, #157 skipped, #159 failing by
  design; UI on 27.0, 74 executed, 1 skipped, no failure; UI on 26.5, 74 executed, 1 skipped, 1 failure
  that passed alone; watch 70 of 70; both widget builds succeeded. **Warnings unchanged on all four
  schemes**, clean builds of a copy of the working tree against a clean build of a `HEAD` `5b511bd` export,
  by file and message: 20, 17, 2, 17 (36, 29, 2, 29 sites) — the watch widget's 17 are the phone app's,
  rebuilt into its empty DerivedData.
- **For the owner**: the rule wording, typed unstaged in ten rule files — `10-architecture`, `15-project`,
  `20-state`, `25-shared-storage`, `43-concurrency`, `50-views`, `65-accessibility`, `70-privacy`,
  `85-testing`, `95-dependencies` (spec §3.10); #177; #179; #181.

**Set A's step 3 — roadmap item 1.4.6, Patterns — is designed, specified, built test-first, walked,
measured, reviewed, gated and staged whole; no user meets it until step 5 puts set A on sale**
(2026-10-23, 20:15 to ~22:45; HEAD `24b2de4`, nothing committed). Spec
`docs/superpowers/specs/2026-10-23-patterns-design.md`; no plan document, on the owner's word; the ledger
at `.superpowers/sdd/2026-10-23-patterns/progress.md` (git-ignored; every command, figure and ruling).

- **What it is.** Under a holder's month in History's Month mode: *Patterns* and *From this month's
  finished days* on the aurora; *When you drink*, a bar an hour across the whole day on the day strip's
  axis, the busiest in `Aurora.cyan`, *Most around 13:00*; *Weekdays* and *Weekends*, each its average
  day against the goal, cyan when met; *First drink, usually* and *Last drink, usually*. Below seven days
  of water, *Patterns need 7 days of water*. The model: `MonthPatterns`, a pure `nonisolated` value in
  `DataManager.swift`, carried on `MonthHistory.patterns` and built in `MonthHistory.make` from the same
  rows — no new property, read, key or call site (`docs/STATE.md`).
- **The owner's rulings:** the month on screen, inline (not a rolling 30 days, not all history); finished
  days only, so today joins at midnight; after seven days of water, with one line below; approach A,
  carried on `MonthHistory`; the first three design sections "Yes, go on", the third answered "Yes, go to
  implementation. All sections are ok. Do not ask" — so the spec's §3.8–§3.11 were written on the
  session's recommendations and not shown section by section; and "go", after a refused `sed -i` on a
  scratch file was reported (`tasks/lessons.md`).
- **The walk**, on *WaterBuddy Probe 27*, seeded from June 26 in a scratch copy only, a lifetime purchase
  through an `SKTestSession`: October and September checked by hand against the seed; June's five days
  draw the pending line; Russian, Uzbek, the largest text size, Reduce Transparency (forced in the copy).
  No layout finding. **The colour pairs:** 22 — October's 20, September's met bar, June's line; one
  under its floor — the heading's line on the
  aurora, 4.17 over forty frames (#171, the owner's).
- **The cost**, measured beside a `HEAD` twin, alternated: `MonthPatterns.make` 0.5–0.7 ms a month read at
  500 days; end to end inside the run-to-run noise and under the owner's 6 ms.
- **The final review** (a fresh reviewer, read-only): no Critical; the Important — the cyan line
  unmeasured — was already measured (5.21). Fixed: the pending line's wording (M4), a median test that
  could not see a missing sort (M3, proved by mutation), bars kept present at zero (M6), the weekday
  tracks on `LiquidGlass.innerCornerRadius` (M7), a DocC (M2), the spec's drift (M8). Deferred: #172.
- **The gate, on the final code:** unit, *iPhone 17*, 842 — the URL test alone failing (#159), one skipped
  (#157); UI on *Gate 27* and *Gate 26.5*, 73 executed and 1 skipped on each, three load-timed failures in
  all, each passing alone (*Targets*); watch 70 of 70; both widget builds succeeded. **Warnings unchanged
  on all four schemes** — 20, 17, 2, 2 by file and message, 36, 29, 2, 2 sites, against a clean build of
  a `HEAD` `24b2de4` export.
- **Still the owner's:** the rules' wording for four files (unstaged — `30-rollover`, `43-concurrency`,
  `50-views`, `85-testing`); C1's look (#171); the deferred minors (#172); the device proofs (#173); the
  Russian and Uzbek (#175); the privacy URL (#159); the commit order — the spec as `docs`, the code as
  `feat(app)`, the records as `docs`, the rules as `chore(claude)`.

*(The block below is history: step 2 is now committed — `9fcdc48`, `40e7e41`, `95c343d`, `24b2de4`.)*

**Set A's step 2 — roadmap item 1.4.2, the month view and full history — is built test-first, walked,
measured, reviewed, gated and staged whole; no user meets it until step 5 puts set A on sale**
(2026-10-22 13:41 to 2026-10-23 ~02:00; HEAD `2e2f3a7`, nothing committed). Run inline from
`docs/superpowers/plans/2026-10-22-month-view.md`, the ledger at
`.superpowers/sdd/2026-10-22-month-view/progress.md` (git-ignored; every command, figure and ruling).

- **What it is.** History gains *Week · Month* under its header — for a holder always, for a free user
  only where the paywall is offered (`HistoryView.offersMonth(status:offered:)`), so a Release build's
  History is unchanged until step 5. Month shows one calendar month: a ring a day, cyan when the goal
  was met and white when part of it, days to come and days before the first serving quiet; ‹ › between
  the first serving's month and this one; a day opened under the card — its heading, its strip and its
  servings, **read-only** (adding and correcting stay the week's, for everyone); three tiles and the
  average line with the change on the month before. A free user's Month is a locked card over a drawn
  month that opens the paywall (`PaywallView.Entry.history`). The model: `MonthHistory`, a pure
  `nonisolated` value in `DataManager.swift`, and `month` / `monthLogs`, published only while History
  asks — stored nowhere, no key (`docs/STATE.md`).
- **The owner's rulings during the build:** the cost budget raised from 3 ms to **6 ms** (the month's
  two-month window read ~4.5 ms at 500 days); a pour reads the shown month **once** —
  `refresh(republishingMonth: false)` (measured at 500 days: `refresh()` +2.34 ms, a pour +2.77 ms);
  the walk driven by a throwaway XCUITest in a scratch copy; then, on the final review, History lets go
  of the month **when the page is removed** (`onDisappear`), spec §3.8 and plan M13 amended; the locked
  month **as built**; the Uzbek tiles' **column** kept; the tiles' figures **one size**.
- **Task 8 — the walk,** on *WaterBuddy Probe 27*, seeded from June 15 in the scratch copy only, Premium
  bought through an `SKTestSession`: free and held, days opened, ‹ to June and › back, every figure
  checked by hand against the seed; a refund with Month open; Russian and Uzbek; the largest text size;
  Reduce Transparency, forced in the copy (`simctl` cannot set it). **Two findings fixed and re-walked:**
  W1, the locked month's drawn month hidden behind its card — the pane now the board's 392 pt, the card
  centred on it as its background, growing with the card; L1, the month's name cut to *October 2…* at
  the largest size — two lines. A third, V1 (an arrow at a bound as a VoiceOver stop), was withdrawn
  before it was built: the XCUITest tree lists hidden views. **The colour pairs:** 51 readings off 60
  frames, none under its floor (`docs/DESIGN.md`, *The month, measured*; #169).
- **Task 9 — the final review** (a fresh reviewer, read-only): no Critical; **I1** a turn back to
  History inside the 0.45-s slide found Month on an empty card for good, **I2** the month emptied on the
  page sliding away — both from letting go at the turn; fixed on the owner's ruling, proved RED → GREEN
  in the walk harness (no in-tree UI test can hold Premium, and no XCUITest tap lands inside a slide);
  **I3** = W1's look, ruled as built; nine minors deferred (#167).
- **The gate, on the final code:** unit, *iPhone 17*, 815 — the URL test alone failing (#159), one
  skipped (#157); UI on *Gate 27* and *Gate 26.5*, 73 executed and 1 skipped on each, no failure; watch
  70 of 70; both widget builds succeeded. **Warnings unchanged on all four schemes** — 20, 17, 2, 2 by
  file and message against Task 0's `HEAD` `2e2f3a7` export, none new or gone, and the same sites by
  line.
- **Still the owner's:** the rules' wording for six files (unstaged — `20-state`, `30-rollover`,
  `43-concurrency`, `50-views`, `60-design-system`, `85-testing`); the commit order — the spec and the
  plan's amendments as `docs`, the code as `feat(app)`, the records as `docs`, the rules as
  `chore(claude)`; the privacy URL (#159); the device proofs (#168); the Russian and Uzbek wording
  (#170); the deferred minors (#167).

*(The block below is history: step 2 is now built and staged, above.)*

**Set A's step 2 — roadmap item 1.4.2, the month view and full history — is designed, drawn,
specified and planned; no code of it exists yet** (2026-10-22, afternoon; HEAD `a6e287b`, the spec and
the plan staged). Step 1 is committed: its spec and plan `4577d92`, its code `d5cf816`, its records
`fd12b7f`, its rule wording `a6e287b`. Recorded by the eighty-fourth `/doc_sync`, run by the owner.

- **The owner's rulings, in order:** a day older than the week is **seen, read-only** — adding and
  correcting stay the week's, for every user, so no way of logging is paid for; the free user's locked
  month blurs **a drawn month**, never their own; an opened day appears **inline, under the month**;
  **approach 1** — `DataManager` shows one month at a time, read only while it is asked for; the
  design's four sections, each "Yes, go on"; three boards drawn on the design canvas
  (https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, row *Set A, step 2*: *Week, with the switch*,
  *Month, a day open*, *Month, free user*), "Approved"; the spec, "ok"; the plan, "plan is ok now".
- **The spec**, `docs/superpowers/specs/2026-10-22-month-view-design.md` (435 lines): the switch drawn
  only once StoreKit has answered, for a holder always and for a free user only where the paywall is
  offered — so a Release build's History is unchanged until step 5; the switch on its own row under an
  unchanged header (beside the `+` it would have left a 375-pt phone 121 pt for the day's name); the
  counting rule — a past month every day, this month the days before today and today once it is met,
  the first month from the first serving; six figures; `MonthHistory` beside `DaySummary` in
  `DataManager.swift`; `month` and `monthLogs` mirroring `history` and `historyLogs`; `showMonth(_:)`;
  no key, no schema change, nothing for the widget or the watch; the change line names no month,
  because Russian would need the prepositional case. It withdraws the step-1 spec's per-feature
  shortcut row in Settings' held card (§3.5) as a second route to History (rule `50-views`).
- **The plan**, `docs/superpowers/plans/2026-10-22-month-view.md` (2,765 lines): Tasks 0–10 — the
  baseline, a probe (the reads' cost at 7 to 500 days against a 3 ms budget, a DST month, each
  language's first weekday), the rule wording for six rule files typed unstaged, then `MonthHistory`,
  the model's publishing, History's statics, 20 strings and the screens, each test-first; then the walk,
  the review, the gate and the records. Fourteen decisions, M1–M14, among them the UI tests joining
  `PremiumUITests` (rule `85-testing`'s sentence stays true), plain chevrons for the arrows and the
  opened day's heading on the aurora above its strip. Expected after it: 812 unit `@Test` (768 + 44),
  60 UI `func test`, 187 catalogue keys.
- **Not run in this session:** any gate, build or test — the last gate is step 1's (Task 9, 2026-10-22,
  ending 11:50; *Targets*).
- **Next:** the plan's Task 0, inline in this repository's own loop (`CLAUDE.md`: no implementation
  subagent).

*(The block below is history: step 1 is now committed, above.)*

**Premium's step 1 — the monthly plan, the paywall and the card — is built, walked, measured, gated
and staged whole; no user meets it until step 5 puts set A on sale** (Tasks 8–10, 2026-10-22 01:09 to
11:54; HEAD `b981374`, nothing committed). The ledger has every command, figure and ruling.

- **The final review** (a fresh reviewer, read-only, before the walk): two Important findings, fixed
  test-first — I1, *No purchases to restore.* stayed under *Thank you* after a restore then a
  purchase (three tests in `PremiumStoreTests`); I2, *Best value* showed on a yearly that saves
  nothing (`aYearlyThatSavesNothingIsNotMarkedBestValue`). Six minors deferred to the owner (M1, M2,
  M5–M8: a failed restore's wording, VoiceOver's extra announcements, the canary-list entries, the
  status line in English alone, the rules' wording, a long DocC line).
- **Task 8 — the walk, on *WaterBuddy Probe 27*,** driven by a throwaway XCUITest class in a scratch
  copy of the index, on the owner's word ("test it by yourself"), with an `SKTestSession` over the
  project's `.storekit`: every plan bought, *Thank you* held until *Done*, the held card, a refund, the
  monthly upgraded to the yearly, Ask to Buy approved with the sheet open, restore with nothing, Russian
  and Uzbek, the accessibility tree, the largest text size, Reduce Transparency. **Ten findings, each
  fixed and seen fixed on a re-walk:** W1 the card's *AI insights* caption 2–4 pt low; W2 the yearly's
  "a year · save 20%" breaking after its dot in all three languages — the saving now its own line,
  `save %1$@` (en/ru/uz: the approved values split at the dot); W3 the Russian badge cut; W4 = I1, seen;
  W5–W8 at the largest size — the card's captions and title broken mid-word, the badge over *Yearly*,
  the promise four lines in a capsule; W9 the yearly tile taller than the others; W10 the feature glyphs
  out of their tiles.
- **Task 8 Step 3 — the colour pairs,** a minute at each place, 20 frames 3 s apart, read on rings
  around each text's own ink (`docs/DESIGN.md`, *The paywall, measured*). The first measure found the
  sheet's text on the aurora at 2.8–4.0:1 — it had no `legibleOnBackdrop()`, which every other screen's
  has — the glyph tiles and the promise on `.sheer` at 1.0–3.5, the badge's cyan 1.74 on its pill's
  sheen, the trial note's cyan 4.1, the card's cyan sparkle 2.88. The shadows and `.frosted` went in on
  precedent; what remained changed the look, so it went to the owner, who ruled each (**R1–R4**, the
  recommended options): one `.frosted` card for the subtitle, the rows and the included line; every
  feature glyph cyan; BEST VALUE the yearly tile's first line, white, its pill gone; the note, the check
  and the sparkle white. The subtitle, at 4.32 in the card's lit corner, went to full white (the
  welcome's R5 precedent; 0.96 cleared by 0.04). **Final: 74 readings, none under its floor**, iOS 27.0
  — 26.5 and 18.6 not measured (#165).
- **Task 9 — the gate,** the scheme's stray launch argument and environment variable removed first
  (#163 retired): unit, *iPhone 17*, 768 tests, the URL test alone failing (#159), one skipped (#157);
  UI on *Gate 27* and *Gate 26.5*, 71 executed and 1 skipped on each, under another session's load —
  every failure a wait timing out, every failing test passing on re-run (*Targets*, #166); watch 70 of
  70; both widget builds succeeded. **Warnings unchanged on all four schemes** — 20, 17, 2, 2 by file
  and message against Task 0's `HEAD` export, none new or gone.
- **Still the owner's:** the privacy URL (#159), the `StoreKitTest` line (#160), #157, the rules'
  wording (unstaged), the six deferred minors, and the *Apple Intelligence* wording before set A goes
  on sale (#164).

*(The block below is history: step 1 is now walked, measured and gated, above.)*

**Premium's step 1 — the monthly plan, the paywall and the card — is built through its Task 7,
tests first, and staged; paused before Task 8, the owner's walk** (2026-10-21 23:11 to 2026-10-22
00:32; HEAD `b981374`, nothing committed). Run inline from
`docs/superpowers/plans/2026-10-21-premium-paywall-and-monthly.md`, the ledger at
`.superpowers/sdd/2026-10-21-premium-paywall-and-monthly/progress.md`. Recorded by the eighty-first
`/doc_sync`, run by the owner.

- **Task 0 — the warnings baseline:** clean builds of a `HEAD` `b981374` export into one empty
  DerivedData — unique warnings by file and message, line numbers stripped: `-scheme WaterBuddy` 20
  (the `StoreKitTest` header line among them, #160), `WaterBuddyWidgetExtension` 17,
  `WaterBuddyWatch` 2, `WaterBuddyWatchWidget` 2, as the plan expected. Step 1's own comparison is
  Task 9's, not run.
- **Task 1 — the probe** (a throwaway copy, removed): three products load; a monthly then a yearly in
  one group leaves only the yearly in current entitlements, in its free week — the spec's §3.1 claim
  measured; the percent reads *44%*, *44 %* (a plain no-break space) and *44%*. **Not as expected:
  `Product.price` reads 2, 19 and 39** on every simulator here (#162). The owner said go on the
  ruling to keep `Product.price`.
- **Task 2 — the rule wording**, typed into `70-privacy`, `60-design-system`, `43-concurrency` and
  `85-testing` and left **unstaged** for the owner; beyond the spec's §5, `PremiumSetTests` joins the
  two canary lists beside `PaywallScreenTests`.
- **Tasks 3–7, each RED then GREEN:** the monthly plan and the grace ruling in `PremiumAccess` (#161's
  fix, on disk); set A, not on sale, and the Release switch that also needs an `https` privacy link;
  the store's three plans, read number, restore states and manage check; 27 strings in en, ru and uz;
  `PremiumRim.swift`; the paywall rewritten; the Settings card first. Two of the plan's lines did not
  hold and were ruled in the ledger: a `switch` expression as an argument does not compile, and the
  monthly's words were held to Task 6 so their test failed first.
- **The owner's rulings this session:** "go" twice; WaterBuddy closed in Xcode before the `.storekit`
  and catalogue edits; the paywall's feature rows counted by their whole label in `PremiumUITests` —
  the plan's count also met each row's own title, which XCUITest lists beneath it
  (`tasks/lessons.md`, 2026-10-17). A mutation run without the row's `.combine` failed that check, 0 ≠ 1.
- **Run, this session:** the whole phone unit suite, *iPhone 17* (27.0), 00:31–00:32: `✘ Test run with
  764 tests in 94 suites failed … with 2 issues` — 761 passed; one skipped (#157); failing,
  `theLinksAreApplesTermsAndAPageOfOurs` (#159) and `theTestRunItselfIsNotOfferedThePaywall` (#163 —
  green on a copy of the index in Task 4, 2026-10-21 23:38–23:40). `PremiumUITests` alone on
  *WaterBuddy Gate 27*: `Executed 2 tests, with 0 failures`. **Not run:** the whole UI suite on 27.0 and
  26.5, the watch suite, both widget builds, the warning comparison, the final review — Task 9.
- **Next:** Task 8 with the owner — every plan bought, the monthly upgraded, a refund, Ask to Buy,
  restore with and without a purchase, the three languages, an accessibility size, VoiceOver, Reduce
  Transparency, the colour pairs measured — then Task 9 (the scheme's stray entries removed first,
  #163) and Task 10's records. Still the owner's: the privacy URL (#159), the `StoreKitTest` line
  (#160), #157.

*(The block below is history: step 1's spec and plan are now built through Task 7, above.)*

**Premium is redirected: 1.4.1's Task 6 was built and gated, then the owner judged its paywall on
their iPhone and chose a designed set A — five steps, step 1 specified and planned, no code of it
yet** (2026-10-21, evening; HEAD `b981374` — Tasks 0–5 committed as `e7b7f38`, their doc sync
`3d577bb`, the rule wording `b981374`). Recorded by the eightieth `/doc_sync`, run by the owner.

- **Built and staged — the foundation's Task 6, to the old plan, without the URL** (the owner: "go
  now without privacy policy URL"): `PaywallView.swift` (new), `PremiumCard` as Settings' fifth card,
  the store built in `WaterBuddyApp.init()` and read on every `.active`, the previews' silent store,
  two DocC sentences, `PaywallOfferTests` (4) and `PremiumUITests` (2). `privacyPolicy` is still
  `OWNER-PRIVACY-URL`, so `theLinksAreApplesTermsAndAPageOfOurs` fails by design (#159).
- **The final review** (a fresh, read-only reviewer): no Critical. **Important 1, fixed test-first** —
  *Not now* then *See Premium* while StoreKit's sheet was still coming up let a second purchase start;
  `prepare()` now keeps a purchase under way (`openingTheSheetAgainWhileBuyingKeepsThePurchase`, RED
  → GREEN). **Important 2, ruled by the owner, not yet on disk** — a subscriber in billing grace read
  as free (#161). Ten minors, folded into the step-1 plan. The report:
  `.superpowers/sdd/2026-10-21-premium-foundation/final-review.md`.
- **The gate, on that code** (19:09–21:18, the machine shared and often loaded): unit, *iPhone 17*
  27.0, `✘ Test run with 734 tests in 92 suites failed … with 1 issue` — 732 passed, one skipped
  (#157), the URL test the one failure; UI on *Gate 27* 71 executed, 1 skipped, 1 failure (#140's
  flake, below); UI on *Gate 26.5* 71, 1 skipped, 0 failures; watch, *WaterBuddy Watch 27*, `✔ Test
  run with 70 tests in 7 suites passed`; `WaterBuddyWidgetExtension` and `WaterBuddyWatchWidget`
  `** BUILD SUCCEEDED **`. **The #140 check**: alone on *Gate 27*, interleaved with a `HEAD` export
  that builds no store at launch — the change 1 passed, 2 failed at `:358`; `HEAD` 2 passed, 1
  failed at `:358`; every failure under a load spike that rose during the run (to 147, 353 and 875).
- **The warning comparison**, clean builds of the staged index against the 1.4.1 baseline of
  `0be24f9`, by file and message: the widget, the watch and the watch widget nothing new; the app
  **one new line**, Apple's own `StoreKitTest.framework/Headers/SKTestTransaction.h:34` deprecation,
  emitted when `PremiumStoreTests.swift` imports `StoreKitTest` (#160). Unique primary lines:
  `-scheme WaterBuddy` 36 = 29 + 6 + 1, `WaterBuddyWidgetExtension` 29, `WaterBuddyWatch` 2,
  `WaterBuddyWatchWidget` 2.
- **On the owner's iPhone** (an iPhone 15 Pro Max, through Xcode): no paywall — the launch argument
  had been entered as an environment variable, and then the app had not been relaunched. Fixed in
  the scheme by the owner; the app launched with the argument by `devicectl`. The owner then judged
  the paywall and the card "very poor", with nothing in Premium to sell.
- **The redirection, approved step by step** — on a design canvas,
  https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy (private to the owner): **set A —
  Understand — first**; **a monthly plan** — $2.99 with no trial, the yearly $19.99 with a free week,
  the lifetime $39.99; **personal AI insights on Apple's on-device model**, named *Personal AI
  insights* using Apple Intelligence, with the app's own written insights where the model is not
  available; and **five steps** — 1 the monthly plan, the paywall and the card; 2 month view and full
  history; 3 patterns; 4 AI insights; 5 the monthly recap, and set A put on sale.
- **Step 1, specified and planned, both approved ("ok") and staged; no code:**
  `docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md` (it amends the foundation's
  spec and supersedes its Task 6's paywall and card) and
  `docs/superpowers/plans/2026-10-21-premium-paywall-and-monthly.md` — eleven tasks, S1–S13, run
  inline; 764 unit `@Test` expected at the end.
- **Next:** step 1's plan from its Task 0. Still the owner's: the privacy URL (#159), the
  `StoreKitTest` header line (#160), `anExpiredYearlyReadsFree` (#157), and the Settings link for
  everyone (#159).

*(The block below is history: 1.4.1's Tasks 0–5 were committed as `e7b7f38`; its Task 6 is the block
above; its Tasks 7–9 move into step 1's plan.)*

**Roadmap item 1.4.1 — Premium's foundation — is begun, half built, staged and paused** (2026-10-21;
HEAD `0be24f9`: 1.3.2's 7c committed as `5194121`, its doc sync `0be24f9`). Recorded by the
seventy-ninth `/doc_sync`, run by the owner in the session that started it, at the pause. Taken
ahead of 1.3.3 on the owner's choice, after a brainstorm on making Premium worth paying for.

- **The roadmap amendment** (staged): *The Premium line* in §1 — no way of logging is ever Premium,
  Premium reads only what the free app stores, everything on the device; items 1.4.6–1.4.11 and
  1.5.4 with their sets and their rule rows in §8 (`docs/ROADMAP.md`).
- **The spec and the plan** (staged, both approved "ok"):
  `docs/superpowers/specs/2026-10-21-premium-foundation-design.md` and
  `docs/superpowers/plans/2026-10-21-premium-foundation.md`. Two products — a yearly with a free
  week, and lifetime; an app-only `PremiumStore` reading StoreKit and storing nothing; our own
  paywall in the app's glass and language; all of it hidden in a Release build until the first
  Premium set exists (`PremiumSet` has no case), shown in DEBUG with `-WaterBuddyPremium`.
- **Built, tests first, staged (Tasks 0–5 of 10):** `PremiumAccess.swift`, `PremiumSet.swift`,
  `PremiumStore.swift`, the 27 strings in `WaterBuddy/Localizable.xcstrings` (113 → 140 keys), the
  local `WaterBuddyTests/WaterBuddy.storekit`, and three test files' worth of suites — 46 tests.
  `StoreKit` is still imported by `HomeView.swift` and `PremiumStore.swift` alone. **Nothing draws
  yet:** the paywall, the Settings card and `WaterBuddyApp`'s store are Task 6.
- **Paused at Task 6, Step 1:** the paywall's *Privacy Policy* link needs the owner's URL (#159).
- **Task 1's probe** (a throwaway copy): the configuration loads through `SKTestSession` and stays
  in the test bundle; `purchase(confirmIn:)` completes in the unit-test host; Foundation names the
  trial's length in each language — *1 week*, *1 неделя*, *1 hafta*. The first purchase on a
  freshly booted simulator once went to the real sandbox and waited on a sign-in alert (#158).
- **Rulings in the ledger** (`.superpowers/sdd/2026-10-21-premium-foundation/progress.md`): the
  session suite resets its session and has a minute's limit; a purchase is hoisted out of `#expect`,
  which would not compile with `try await` inside a closure; `PremiumStore()` is a convenience init,
  because `.live()` as a default argument warned; refund and expiry tests wait up to five seconds —
  a refund lands 100–300 ms late; `anExpiredYearlyReadsFree` is disabled with its reason (#157); the
  catalogue's own `"key": value` format; Tasks 3–5 and the spec staged early against an Xcode
  rewrite (#50).
- **The rule wording** — spec §5 — is typed into seven rule files and `CLAUDE.md`, **unstaged**, for
  the owner's `/commit`.
- **Run:** the phone unit suite, *iPhone 17* (27.0), 14:48: `✔ Test run with 729 tests in 91 suites
  passed`, one skipped by design (#157); the attribute grep says 729. **Not run:** the UI suite, the
  watch suite, both widget builds and the warning comparison — Task 8. The warnings baseline, clean
  builds of a `HEAD` `0be24f9` export: `-scheme WaterBuddy` 35 lines (19 by file and message),
  `WaterBuddyWidgetExtension` 29 (17), `WaterBuddyWatch` 2, `WaterBuddyWatchWidget` 2 — the phone's
  not reprinted, its targets already built in the same folder.
- **Next:** the URL, then Tasks 6–9 — the paywall, the card and the app; the owner's walk in Xcode
  with the local StoreKit configuration; the review, the gate, the warnings; the records.

*(The 7c block below is history: 7c was committed as `5194121`, its doc sync as `0be24f9`.)*

**Roadmap item 1.3.2, stage 7c — the watch's three faces — is built, gated and staged, not
committed** (2026-10-20 evening to 2026-10-21; HEAD `3d1cda8`: 7b committed as `af388da`, its doc
sync `3d1cda8`). Written by the session that built it, not a `/doc_sync` pass. The plan's Tasks
9–11, run inline, tests first. With 7c, roadmap item 1.3.2 is built whole.

- **What changed.** The complication offers `.accessoryRectangular` and `.accessoryCorner` beside
  the circle, every face display-only. `WristWidgetEntry` carries a `WristPlan.Face` — the function
  the screen reads — and the phone's `AppLanguage`, from the mirror; `WristFaceRoot` injects
  `\.strings` and `\.locale` together. The circle is the ring it was; the corner draws the
  percentage, `.percent` in the chosen locale, with a curved gauge as its `widgetLabel`; the
  rectangle draws the drop, *Hydration* and the percentage, the screen's own line
  (*1,300 of 2,000 ml*) and a bar. Each shape is one VoiceOver element — *Today's hydration*, the
  vessel's sentence — every shown figure `.privacySensitive()`, and each has a quiet form under
  `.privacy` that draws and speaks no figure. The watch widget's catalogue gains three keys, value
  for value from the app's (5); `LocalizationTests` compares all four of its shared keys in every
  language. The kind, the gallery strings, the provider's store read and its `.atEnd` timeline are
  unchanged.
- **The owner's rulings this session.** (1) Xcode's unstaged rewrite of the watch widget's
  catalogue (#50) restored to `HEAD` before the keys went in. (2) watchOS 27.0 alone (#151). (3) The
  tinted corner on the final build skipped — the owner's swipe to the Infograph face did not reach
  the probe watch.
- **My rulings, in the ledger.** The rectangle's line and bar are marked only when shown
  (`.privacySensitive(!quiet)`): a marked blank line under the privacy reason drew the system's grey
  placeholder chip, a render showed. The corner's figure gained `.lineLimit(1)` — the probe drew
  Russian *100 %* on two lines. The corner's two label gauges gained `.widgetAccentable()` — on the
  tinted Infograph face its gauge stayed white beside a green circle (rule `60-design-system`).
- **The final review**, a fresh reviewer on the staged diff: 0 critical; 2 important, both
  verification still to do at the time (the tinted corner; the gate); 4 minor. One minor re-graded
  and fixed — the corner's label gauges hidden from VoiceOver (rule `65-accessibility`); three
  deferred for the owner (`HISTORY.md` lists them).
- **Seen on the simulator** (*WaterBuddy Probe Watch 46*, watchOS 27.0, a probe copy seeding the
  store through `WristModel.apply`): 110 renders of the three shapes at 62, 100 and 999%, en/ru/uz,
  shown and quiet — every quiet form without a figure; then **the owner placed all three** —
  the circle and the rectangle on Modular (multicolour), the corner and the circle on Infograph
  (tinted green). The faces followed the phone's Russian after the app's own reload. And **the
  midnight turnover with the app closed**: at 00:00:02 the Modular face fell from *65 % ·
  1 300 из 2 000 мл* to *0 % · 0 из 2 000 мл*, a second before the system's own date did.
- **Not seen:** the corner on a tinted face after the accentable fix; the quiet forms where watchOS
  draws them, VoiceOver on the wrist, the Smart Stack, and 26.x — #153 for the sweep, #151.
- **The gate**, on a copy of the index: unit `✔ Test run with 683 tests in 86 suites passed` (the
  grep says 683); watch on *Watch 27* `✔ Test run with 70 tests in 7 suites passed` (the grep says
  70); both widget schemes `** BUILD SUCCEEDED **`; UI on *Gate 26.5*, quiet: 69, 1 skipped by
  design, 0 failures; UI on *Gate 27*: 19 with 1 skipped, then — beside another project's iOS 18.6
  test run, loads up to 329 — a timing guard tripped in the second chunk (6.97 s against 6.5,
  passed alone) and `WelcomeUITests.testUseComesBackWhenTheGoalIsMovedAway` failed in the third,
  as `HEAD` failed it too (#140's 2026-10-21 note); once the other run ended, at loads of 5 to 7,
  both chunks again: 19 and 31, **0 failures** — 69, 1 skipped.
- **Warnings.** Clean builds of a `HEAD` `3d1cda8` export and of the index copy: `-scheme
  WaterBuddy` 35 and 35 (19 by file and message), `WaterBuddyWatch` 2 and 2, `WaterBuddyWatchWidget`
  and `WaterBuddyWidgetExtension` 29 and 29 each (17) — **nothing new**; after the review's fix, on
  a second index copy, the three schemes that compile the face again: 35, 2 and 29.
- **Next:** the owner's `/commit` and `/doc_sync`; 1.2.7's device sweep carries #151–#153.

*(The 7b block below is history: 7b was committed as `af388da`.)*

**Roadmap item 1.3.2, stage 7b — the watch's screen — is built, gated and staged, not committed**
(2026-10-20; HEAD `ca43a60`: 7a committed as `90fef5d`, its doc sync `63f8a46`, the rule wording
`ca43a60`). Written by the session that built it, not a `/doc_sync` pass. The plan's Tasks 4–8, run
inline, tests first.

- **What changed.** `WristPlan.Face` — today's total and goal, the progress held to `0...1`, the
  percentage held to `0...999`, the vessel's sentence and the millilitre line in the app's own keys
  — and `WristPlan.face(…)`, which `WristModel.face` reads, `displayGoal` and `todaysTotal` through
  it. The screen is the canvas's: `WristVessel` a display (one VoiceOver element), the line *1,240
  of 2,000 ml* under it, `WristPourRow` — Cup and Bottle as interactive glass discs, the Glass the
  primary surface (`ring: false`), a capsule carrying its amount where it fits, three discs where
  not, a sideways scroll past that — and the sync caption. A new `Layout`, `WristColumn`, sizes the
  vessel. The *More* sheet, `vesselHeightFraction`, `primaryIndex`, `readout(…)` and
  `diameter(fitting:reserving:)` are gone. The watch catalogue gains two keys and loses four (14).
- **The owner's rulings this session.** (1) 2,050 of 2,000 reads **102%**, as the phone and the
  complication round it in `Double` — the plan's test said 103 by hand. (2) The caption is the
  column's last child and gives way to the vessel (spec §3.4 over the plan). (3) The column fills
  the safe area **and the bottom inset down to the canvas's 22 pt margin**
  (`WristView.columnHeight`): the 46 mm safe area is 159 pt under a 53 pt clock, the plan had
  assumed ~210, and the vessel came out 63 pt; chosen from three renders, it is 77 pt there.
  (4) The `%` is drawn at **14 pt bold at least** (`WristVessel.signSize`): in the smaller vessel it
  was small text and read 3.99:1 over a full vessel against 4.5.
- **My rulings, in the ledger.** Below the accessibility sizes a disc gives way to its column's
  share, down to the 44 pt floor, and an amount may scale inside that share; at the accessibility
  sizes both keep their size and the row scrolls sideways (`WristView.discDiameter`, `columnShare`)
  — the 40 mm row had fallen to its sideways scroll at the default size, cutting *500 m*. The first
  cut kept a disc grown by type, which the final review showed would scroll the 40 mm row from
  xLarge; fixed, test first, and rendered at a forced xxxLarge. The scrim is full by **32%**, the
  percentage's ink measured at 0.106–0.115 of the diameter below the centre.
- **The final review**, a fresh reviewer on the staged diff: 0 critical, 2 important — the disc
  above, fixed; and no evidence a button pours, answered by the check below — and 6 minor, deferred
  for the owner (`HISTORY.md` lists them).
- **The press:** the owner clicked the three buttons in `DeviceHub.app`, and the line moved by each
  serving — 1 240 → 1 490 → 1 990 → … 3 740 — the watch's outbox holding twelve pours of 150, 250
  and 500 (#152, first recorded as failed by a check made before the clicks).
- **Rendered** on all five probe watches (27.0) at 0, 1,300 and 2,600 ml and with a 150/1,000/1,500
  set; on 46 and 40 mm in Russian, Uzbek, under forced Reduce Transparency and at a forced
  `.accessibility5` (`simctl` cannot set a watch's text size). Every capture looked at. The pairs are
  *The watch's screen, measured* (`docs/DESIGN.md`) — none under its floor.
- **Not done:** anything on watchOS 26.x (#151); a press on a device, by the crown or VoiceOver
  (#152); the faces, which are 7c.
- **The gate**, on a copy of the index: unit `✔ Test run with 683 tests in 86 suites passed` (the
  grep says 683); UI on *Gate 27* — 19 with 1 skipped, 19, then the other classes 31 with **1
  failure**, `WelcomeUITests.testAStepIsAsItWasLeftWhenBackReturnsToIt`'s lost tap (#140; alone five
  times, the change 3 of 5 and `HEAD` 4 of 5, loads 127–361 beside another project's simulator
  tests), re-run at a load of 8: 31, 0 failures; UI on *Gate 26.5*: 69, 1 skipped by design, 0
  failures; watch on *Watch 27* `✔ Test run with 70 tests in 7 suites passed` (the grep says 70);
  both widget schemes `** BUILD SUCCEEDED **`.
- **Warnings.** Clean builds of a `HEAD` `ca43a60` export and of the index copy: `-scheme
  WaterBuddy` 35 and 35 (19 by file and message), `WaterBuddyWatch` 2 and 2, `WaterBuddyWatchWidget`
  and `WaterBuddyWidgetExtension` 29 and 29 each (17) — **nothing new**. After the review's fix, on a
  second index copy: watch 70, unit 683, both widgets built, and `WaterBuddy`, `WaterBuddyWatch` and
  `WaterBuddyWatchWidget` 35, 2 and 29 again; the UI suites not re-run — no phone UI test reaches the
  watch's row.
- **Next: 7c**, the faces — after the owner's `/commit` and `/doc_sync`.

*(The 7a block below is history: 7a was committed as `90fef5d`.)*

**Roadmap item 1.3.2, stage 7a — Apple's glass on the watch — is built, gated and staged, not
committed** (2026-10-20; HEAD `ff7305b`). Written by the session that built it, not a `/doc_sync`
pass. The plan's P4 and Tasks 0–3, run inline.

- **The owner's rulings this session.** The rule wording of spec §5 approved as typed (it stays
  unstaged, in six rule files, for its own `chore(claude)` commit). Then **the watchOS 26.x half
  withdrawn** — "maybe you will change the runtime for different one that is exists": the runtime
  never arrived, and 11.5, the one other watch runtime here, is below the 26.0 floor. Everything is
  measured and run on watchOS 27.0 alone, the gate stays five invocations, and the 26.x half is known
  issue #151; the typed wording of `15-project`, `60-design-system` and `85-testing` was amended to
  match, and the spec and plan carry dated notes. Then **the tint kept at `0.64`**, the plan's own
  branch: the only pairs 7a moved under their floor are the serving sheet's `.secondary` amounts
  (2.83:1, from 4.87 on the hand-made stack), and 7b deletes the sheet.
- **What changed.** `LiquidGlassModifier.swift`: `systemGlassAvailable`, `sampling(_:)` with
  `systemGlass`, and `GlassGroupModifier` take `#available(iOS 26.0, watchOS 26.0, *)`, every
  `#if os(iOS)` round them gone, and six DocC passages no longer put the watch on the hand-made
  stack or the glass on iOS alone. `WristView.swift`: the *More* capsule and the sheet's rows `interactive: true` — #91(b)
  retired. `WristGlassTests.swift`, new: `theWatchDrawsAppleGlass`. `LiquidGlassTests.swift`: two
  DocC comments corrected, no assertion moved. On iOS every branch answers as before.
- **RED, then GREEN**, on *WaterBuddy Watch 27* (27.0): `✘` at `WristGlassTests.swift:21`,
  `LiquidGlass.systemGlassAvailable` false, the floor expectation passing; then `✔ 1 test`. The
  phone's five glass suites, 25 tests, passed; both widgets built.
- **Rendered** on *WaterBuddy Probe Watch 46* (27.0), from a probe copy of the working tree and of
  `HEAD`: the vessel at 0% and 62%, the capsule, the sheet, each again under Reduce Transparency —
  eleven captures, each looked at. The table is *The watch's glass, measured* (`docs/DESIGN.md`).
- **The gate**, on a copy of the index: unit `✔ Test run with 677 tests in 86 suites passed` (the
  attribute grep says 677); UI on *Gate 27* and *Gate 26.5*, each in three chunks — `GoalSetupUITests`
  19 with 1 skipped by design and 19, the other three classes 31 — **69, 0 failures** on each; watch
  on *Watch 27* `✔ Test run with 58 tests in 7 suites passed` (the attribute grep says 58); both
  widget schemes `** BUILD SUCCEEDED **`. Another project's `xcodebuild test` ran beside the unit
  run (load 159); the UI chunks ran after it ended, at one-minute loads of 4.0 to 19.9.
- **Warnings.** Clean builds of a `HEAD` `ff7305b` export and of the index copy: `-scheme
  WaterBuddy` 35 and 35 (19 by file and message); `WaterBuddyWatch` 2 and 2; `WaterBuddyWatchWidget`
  and `WaterBuddyWidgetExtension` 29 and 29 each (17) — **nothing new**, by line or by message.
- **Next: 7b**, the screen — after the owner's `/commit` and `/doc_sync`.

*(The block below, written by the seventy-fifth `/doc_sync` before any code, is superseded by the one
above: P4's three schemes are measured, Task 0 is typed and approved, and the 26.x runtime is no
longer waited for.)*

**Roadmap item 1.3.2, the watch's stage, is begun: spec and plan approved, preconditions under way, no
code yet** (2026-10-20; HEAD `06229be`). Written by the seventy-fifth `/doc_sync`, not by a build.

- **What it is.** The premium redesign's stage 7 plus two complication families, in three sub-stages,
  each gated and committed on its own: **7a**, Apple's glass on the watch; **7b**, the canvas's screen
  — the vessel a display showing the percentage, *1,300 of 2,000 ml* under it, a row of Cup, Glass
  and Bottle with the Glass as the primary surface, the *More* sheet gone; **7c**, rectangular and
  corner faces beside the circular one, display-only, all reading one `WristPlan.Face` with the
  screen, every figure `.privacySensitive()` with a quiet form. Spec
  `docs/superpowers/specs/2026-10-20-the-watch-stage-design.md`; plan
  `docs/superpowers/plans/2026-10-20-the-watch-stage.md`; both approved by the owner today.
- **Rulings.** D6 kept as approved on 2026-10-09: a watchOS 26 runtime is installed before the stage
  is measured, and the watch tests run on 26.x as well as 27.0 — the roadmap's "26 or later" reading
  is retired. Three families (no inline); display-only (no second writer to the watch's suite);
  redaction on all three, the circular face included; approach A. No key, wire field, entitlement or
  exception set moves.
- **Done.** The plan's P2 (the five catalogues clean; WaterBuddy not open in the running Xcode) and P3.
  P1 in part: five probe watches made (#90). P4 in part: a clean `build-for-testing` of a `HEAD`
  export, `-scheme WaterBuddy`, gives 35 unique primary warning lines — 29 outside the tests, 6 in two
  test files — `CLAUDE.md`'s figure; the three other schemes are not measured yet.
- **Waiting.** The watchOS 26.x runtime is not on this Mac — `xcrun simctl runtime list` shows
  watchOS 27.0 and 11.5 only (#77). The gate's watch device on it and the 26.x probe watch are not
  made. The rule wording of the spec's §5 (the plan's Task 0) is not typed. A command that bundled
  `chmod`, which `.claude/settings.json` denies, was refused, and the session stopped on it, as
  `CLAUDE.md` says; resuming needs the owner's word.

**Roadmap item 1.3.1, the widget's stage: 6c — the week in the cache, the *Week* widget and its link
to History — is built, gated and staged, not committed** (2026-10-19/20; HEAD `4c796a9`, where 6b and
its doc sync are committed, `ed77d9f` and `4c796a9`). *(Seventy-fifth pass: committed — 6c as
`fb1af96`, its doc sync as `cdc53da`, the rule wording as `06229be` — so the block below is history.)* Written by the session that built it, not a
`/doc_sync` pass. The plan's Tasks 3–7, run inline; the ten rule files with §5's approved wording
are still staged from before.

- **The week in the cache.** `Key.weekTotals` — the last seven days' totals by day ordinal, JSON — is
  rewritten from the rows exactly where today's total is recomputed: `init` and `saveAndRecompute()`,
  through `recomputeTodayAndTheWeek()`, in the app and in the widget extension alike, so a tap the
  morning after keeps yesterday. Never by `refresh()` or `dayDidTurn()`, never from a failed read,
  never when unchanged. One doorbell a pass: today's change rings through the `currentWater` setter,
  and the week rings only when it was missing or a past day moved. Read through
  `readWeekTotals(from:)` — a wrong count or a day outside `0...maximumDailyIntake` discards it
  whole — into `WaterSnapshot.weekTotals`, and drawn through `week(endingOn:calendar:)`, which takes
  today from the total and walks `DaySummary.window`, the walk History's card is summed over.
- **The *Week* widget.** `WeekWidget.swift`: kind `WaterBuddyWeek`, medium only, the Hydration widget's
  provider; History's week card at widget size, one VoiceOver element; *Open WaterBuddy to see your
  week.* when nothing is cached. A tap opens History through `WidgetLink.history`, answered in
  `RootTabView` by `AppTab(link:)` — no URL scheme registered, proved warm and cold on the simulator
  before any code.
- **Rulings in the session.** The owner: the fifth doorbell test the plan missed,
  `EarlierServingTests.aServingBackdatedIntoYesterdayRingsNoWidgetDoorbell`, is rewritten as
  `…RingsTheWidgetOnce` — the week widget draws past days. In the build: `WeekCorruption` internal; the
  stored `weekTotals` `nonisolated` too, as spec R5 says (the plan had dropped it); only `cardInset`
  and `cardPadding` lose `private`. Before the code: D1's five files restored to `HEAD`, Xcode closed.
- **Tests.** RED first, each on its own expectation; the green-first ones broken to be seen failing; the
  isolation keywords taken off one by one — `week(endingOn:calendar:)` and the stored `weekTotals`
  warn in the off-actor suite, `Key.weekTotals` in the reader, and `readWeekTotals(from:)` is a
  compile **error** in `snapshot`. 677 phone `@Test` (654 + 23), 57 watch, by the attribute grep.
- **A fresh final review** found nothing critical. Two findings were fixed: the week's type cap sat
  inside `WeekCard.body`, below the card's own `@ScaledMetric`, and capped nothing — #76's shape, from
  the plan's code. It was moved above the card, and rendered before and after at AX1 and AX5. And a
  corrupt negative row could write a week the reader rejects; each day is now clamped on the way
  in, RED then GREEN. Four minor findings were left, each in `HISTORY.md`.
- **The gate, on a copy of the index, run again after the fixes.** Unit `✔ Test run with 677 tests in
  86 suites passed`; UI 69 with 1 skipped by design and **0 failures** on iOS 27.0 **and** 26.5; watch
  `✔ 57 tests in 6 suites passed`; both widgets built. **No new warning** on any scheme: app 35 = 35
  (29 outside the tests; 19 by file and message), widget 29 = 29, watch 2 = 2, watch widget 29 = 29,
  clean builds of `HEAD` and the index. The first gate, before the fixes, read 676 and the same,
  but for one 26.5 failure, `testAScreenComesBackWholeAfterItsTabIsLeft`'s first tap, seen on `HEAD`
  too (#140's note).
- **Measured.** The week adds a median 0.42 ms (p90 0.82 ms) to a tap, against 0.14 ms for today's
  rows: 90 days of ten servings on disk, Debug, simulator.
- **On the simulator** (*Probe 27*): the gallery's sample; the placed week agreeing with History day by
  day; a serving added to Sunday reaching it; the midnight turn unattended; the link warm and cold;
  Russian and Uzbek; light and dark; the colour pairs, none under its floor (`docs/DESIGN.md`). The
  empty state only in a throwaway build: on the simulator the gallery offers no widget of an app that
  has not run, and the run writes the week (#149).

**Roadmap item 1.3.1, the widget's stage, is under way: 6a committed, 6b built, gated and staged —
not committed** (2026-10-19; HEAD `5a46609`). *(2026-10-20: 6b committed as `ed77d9f`, its doc sync as
`4c796a9`, so the block below is history.)* Spec `docs/superpowers/specs/2026-10-19-the-widget-stage-design.md`
and plan `docs/superpowers/plans/2026-10-19-the-widget-stage.md`, approved by the owner with D1–D4,
P1 and P2, committed in `1899aba`; the plan run inline, task by task. It is the premium redesign's
stage 6 plus a StandBy layout and a week widget, in three stages. §5's rule wording for ten rule
files, approved before any code, is staged and not yet committed.

- **6a, the white pour button — committed, `5a46609`.** In full colour the Home Screen widget's pour
  button is the redesign's primary surface — `PourSurface`, `.primarySurface(in:ring: false)`, so it
  stays exactly 44 pt and the vessel's clearance holds; on a template, white content in the lit rim.
  Its gate, as its commit records it: 654 unit; UI 69 on iOS 27.0 and on 26.5, one skipped by design;
  57 watch; both widget builds; no new warning; placed in light, dark and tinted.
- **6b, StandBy — staged.** When iOS removes the container background (on iPhone, StandBy) the small
  family draws no card: `SmallLayout(snapshot:bare:)` at an 8-pt inset, the vessel by the same
  clearance formula over the larger square, drawing its rim and its water but never its glass
  (`widgetPane(…, glass: false)`, D4). Its figures carry `.privacySensitive()`, and under `.privacy`
  it draws the Lock Screen widget's quiet form (D3). Medium unchanged. One file,
  `WaterBuddyWidget/WaterBuddyWidget.swift`; no key, test, target or catalogue change — no unit test
  reaches widget-only code (spec §7).
- **6b's gate, on a copy of the index.** Unit `✔ Test run with 654 tests in 84 suites passed`; UI on
  iOS 27.0, 69 with 1 skipped by design and 0 failures; on iOS 26.5, 38 with 1 skipped, then 31 with
  one failure — `testUseComesBackWhenTheGoalIsMovedAway`, at a low load, not seen again in 3 + 3
  interleaved runs or in the three classes rerun, 31 with 0 failures (#140's note); watch
  `✔ 57 tests in 6 suites passed`; both widgets built. **No new warning**: the app scheme 35 = 35
  primary lines (29 outside the tests), the widget scheme 29 = 29, clean builds of `HEAD` and the
  index, by line and by file and message.
- **On the simulator.** A throwaway build forced the bare layout on *WaterBuddy Probe 27*: in full
  colour the rim, the water and the white disc on black — the vessel 109.7 pt across on the
  simulator's 164.3-pt widget, the formula's own figure, the button 44.0 pt, 24 pt between them; in
  `.vibrant`, the silhouette and the rimmed button; under `.redacted(reason: .privacy)`, an empty rim.
  The ordinary card from `HEAD` and from the index, pixel-identical. Real StandBy is #148.
- **Next: 6c**, the week in the cache and the *Week* widget (plan Tasks 3–7). D1 — the five files
  Xcode rewrote go back to `HEAD`, with Xcode closed — is done before it (#50's note).

**Roadmap item 1.3.4, Siri's "how much water today", is built, gated and staged — not committed**
(2026-10-18; HEAD `88d694f`, where 1.2.8 and its records are committed). *(Seventy-third pass:
committed at 23:40 the same night — `4a7ece7` (spec and plan), `c2f1972` (feat), `7db34a2` (docs),
`41309e3` (rule wording) — so the block below is history.)* Spec
`docs/superpowers/specs/2026-10-18-todays-water-design.md` and plan
`docs/superpowers/plans/2026-10-18-todays-water.md`, both approved by the owner, the plan run inline.

- **What it is.** "How much water today in WaterBuddy" (and two more phrases, three in Russian):
  Siri answers *1,450 millilitres so far today — 1,050 millilitres to go.*, *… — you've reached your
  goal.*, or *Nothing logged yet today — 2,000 millilitres to go.* — today's total and what is left,
  never the streak. A *Today's Water* tile (drop, blue) after *Log a Glass* in Shortcuts and
  Spotlight. On a locked iPhone it asks for authentication first (`.requiresAuthentication`, the
  owner's ruling). It reads `DataManager.snapshot()` — the widget's read — and writes nothing.
- **The code.** `WaterBuddy/TodaysWaterIntent.swift` (new, app-only); `WaterSnapshot.remaining` and
  `hasReachedGoal`, `nonisolated` (#147); a second `AppShortcut`; five keys in the app catalogue and
  three phrases in `AppShortcuts.xcstrings`. No key, entitlement, exception set or `project.pbxproj`
  change. The rule wording (`70-privacy`, `15-project`, `20-state`, `43-concurrency`, `85-testing`)
  was approved by the owner before any code.
- **Tests.** `WaterBuddyTests/TodaysWaterTests.swift`, 16 `@Test`, each seen red, then green; the three
  answer keys join `LocalizationTests`' counted keys; the phrase tables hold six. **654 `@Test`** in
  `WaterBuddyTests` by the attribute grep (638 before); 57 on the watch, unchanged.
- **The gate, on a copy of the index.** Unit `✔ Test run with 654 tests in 84 suites passed`; UI on
  iOS 27.0 — `GoalSetupUITests` 38 with 1 skipped by design, the other classes 31 with one failure —
  and on iOS 26.5 the same with one failure; watch `✔ 57 tests in 6 suites passed`; both widgets
  built. Each failure was a tap lost under the owner's Xcode build and another project's simulator,
  seen on `HEAD` too or gone at a lower load (#140's note). **No new warning** on any of the four
  schemes, by clean builds of `HEAD` and the index compared per file and message; the app's 29 unique
  lines outside the tests stand.
- **On the simulator.** The tile registers in English and Russian; a tap on it showed nothing within
  four seconds, and `perform()` has not run anywhere (#63's note). What only a device shows is #146.
- **The final review** — a fresh reviewer, read-only: no Critical. Its three Important findings
  were taken: everything staged as reviewed, this checkpoint in `HISTORY.md`, and the canary —
  `TodaysWaterSnapshotTests` made `async` with its reads in locals, seen to warn with `nonisolated`
  removed and not with it back, the whole unit target green again (654). Five minors deferred
  (`HISTORY.md`).
- **New known issues:** #145 (a language not shipped), #146 (the device checks), #147 (what a suite
  off the main actor catches here, measured; what rules `43-concurrency` and `85-testing` say).

**Roadmap item 1.2.8, the iPhone store set, is built, captured, gated and staged — not committed**
(2026-10-18; the session that built it, then this sixty-ninth pass). *(Seventy-second pass: committed
at 20:33 the same evening — `eecb6a7` (plan), `efa9ed3` (feat), `4f21510` (docs), `88d694f` (rule
wording) — so the block below is history.)* HEAD is `93d23df`. The design
was approved in chat on 2026-10-17 and parked for the lag fix (#142, now retired); the owner resumed
it, and it is written down for the first time in `docs/superpowers/plans/2026-10-18-store-screenshots.md`.
*(2026-10-18, the seventy-first pass: #144 is fixed inside this staged change, as the owner chose,
and retired. The script refuses a run outside the window before it boots and builds, and freezes the
time it checked, so the status bar can no longer read earlier than the 1:30 PM row; the harness's,
the script's and `WaterBuddyApp`'s DocC say what the code and the logs show. Checked by fake-clock
runs before and after, and a `build-for-testing`; the five invocations were not run again, and no
PNG changed. `WaterBuddyApp.swift` joins 1.2.8's staged paths.)*

- **What changed.** `AppStoreScreenshotUITests.testCaptureAppStoreScreenshots` launches with
  `-WaterBuddyFreshStart` and `en_US`, refuses to start outside 1:45–11:45 PM, and builds a lived-in
  week through History's `+`: today's five servings at set times on the wheel (1,300 ml, 65 %), and
  six earlier days from the sheet's shortcuts, five of them meeting the goal — a *5 days* chip. Nothing
  is poured on Home. `Tools/CaptureScreenshots.sh` finds the iPhone 18 Pro Max on iOS 27.0 by name,
  drops the dirty-device gate, freezes the clock in 24-hour form and keeps its DerivedData. Rule
  `85-testing`'s wording, approved before any code, is staged with it; `CLAUDE.md`'s gate line 2
  follows it.
- **The four PNGs** in `Screenshots/en-US/iPhone-6.9/` are retaken, 1320 × 2868, at 15:06, and each
  was read. `VerifyScreenshots.sh` passed.
- **What the runs found.** The plan's wheel order — the half of the day first — failed: at 2:42 PM
  the hour wheel, asked for 12, read back 2. The log shows only the request and the read-back; that
  it snapped back from a time later than now is inferred, and the fix that rests on it — the wheel
  spun in the morning, its half of the day set last — passed twice. And `simctl status_bar --time` draws in the device's own hour cycle: `en_UZ` is 24-hour, so
  the owner chose a frozen 24-hour clock over changing the device.
- **The gate**, on the working tree: unit `✔ Test run with 638 tests in 80 suites passed`; UI on iOS
  27.0 — `GoalSetupUITests` 38 in four chunks, 1 skipped by design, the others 31, 0 failures; UI on
  iOS 26.5 the same, 0 failures; watch `✔ Test run with 57 tests in 6 suites passed`; both widget
  schemes built. The one Swift file changed, in the UI test target, prints no warning; no product
  source changed, so no clean-build comparison was run.
- **Left.** The census method and its script (#82, #45), the watch capture script (#45), and the
  watch shots (#88), which wait for the watch's redesign, 1.3.2.

*(2026-10-18, the sixty-ninth pass: the lag fix below was committed at 13:50–13:51 the same day —
`b1bbbc3` (specs and plan), `90eb5e4` (the streak), `258a67d` (the water) and `93d23df` (its sync).)*

**The lag fix is built, gated and staged — not committed** (2026-10-18; its records were written by
the session that built it, and the sixty-seventh pass read them). HEAD is `9999979`. The owner
reported lag on their iPhone — a Debug build run from Xcode — on Home when pouring, in History, in
Settings and the welcome: stutter, slow taps, slow screens, worse over time. Two changes, each with
its own spec and each test-first:

- **A — the water rests** (`docs/superpowers/specs/2026-10-18-the-waters-cost-design.md`, plan
  `docs/superpowers/plans/2026-10-18-the-waters-cost.md`). `WaterMotion` (new, app only, pure): after a
  pour the phase sets off at 1.1 rad/s and eases to a standstill over `settling`, 2.5 s, then stands,
  and carries on from where it stood at the next pour. Home's vessel runs its clock only while the
  water moves and the app is active; the slosh shares the window; the welcome's hello vessel moves for
  the window each time its step is shown. `WaterMotionTests`, 7 `@Test` — 8 cases, one taking two
  arguments.
- **B — the streak stops rereading the past** (`docs/superpowers/specs/2026-10-18-the-streaks-cost-design.md`).
  `DataManager.closedRun` keeps the run of days before today; it is forgotten wherever the app changes
  another day and on every `dayDidTurn()`. `StreakRecountTests`, 9. Known issue #99 retired.
- **Measured** (simulator, Debug): Home idle 17 % → 4 % of a core, the welcome 22 % → 3.5 % (0.176 s per
  5 s), a pour and its five seconds 36 % → 23 %; a pour's model work 6 → 1.4 ms at 45 days of history and
  75 → 1.7 ms at 500, a tab's refresh 3 → 0.4 and 37 → 0.6 ms. The aurora, ranked first by reading, was
  never switched off: History and Settings, which carry it and no water clock, idled at 2.1 % and
  2.6 % of a core — its ceiling, not a measurement of it. Moving the waves instead of redrawing them
  made the pour heavier and was reverted.
- **The gate**, on the working tree: unit `✔ Test run with 638 tests in 80 suites passed`; UI on iOS
  27.0 — `GoalSetupUITests` 38 in four chunks, 1 skipped by design, the others 31, 0 failures; UI on
  iOS 26.5 the same on its second run, on a quiet machine — the first, under another project's load,
  stopped after three of its four chunks with one failure in each (#140); watch `✔ 57 tests in 6 suites`; both widget schemes built. Warnings:
  identical by file and message to clean builds of a `HEAD` export on the app, watch and watch-widget
  schemes, and the app scheme's 29 unique lines.
- **Left** (#141): nothing in Release or on a device — the owner was asked to try *Edit Scheme → Run →
  Release*; the pour is still the costliest moment; the welcome's resting water was not rendered.
  Roadmap item 1.2.8 is parked (#142).

**Roadmap item 1.2.6, Russian plural forms, is built, gated and staged — not committed** (2026-10-17;
*(2026-10-18: committed on 2026-10-17 at 23:47 — `5bc7a0a` (spec and plan), `419868a` (feat),
`2451143` (docs), `9999979` (rule wording).)*
written by the session that built it, not a `/doc_sync` pass). HEAD is still `52ee815`. Spec
`docs/superpowers/specs/2026-10-16-plural-forms-design.md`, plan
`docs/superpowers/plans/2026-10-17-plural-forms.md` — both approved by the owner on 2026-10-17 and run
inline in the main loop, tests first; ledger `.superpowers/sdd/2026-10-17-plural-forms/progress.md`,
git-ignored, on this Mac only. The three rule files' wording (`50-views`, `65-accessibility`,
`70-privacy`) was approved as typed, before any code. D7: the owner chose to discard Xcode's rewrite of
the three catalogues (#50); it came back once mid-session from an IDE build and was put back to the
staged version.

- **What changed.**
  - `Bundle.localized(_:_:locale:)`, `nonisolated`, beside `figure` in `DataManager.swift`: a key with
    arguments, formatted with the injected locale. All 32 `String(format:)` sites over a resolved key
    moved — 31 to it, `WristVessel.readout` to `figure` — 18 in the app, 9 in the widget extension, 5
    on the watch; eleven types read `\.locale` for the first time.
  - The ten counted keys carry plural variations in every catalogue that holds them — English
    *one*/*other*, Russian *one*/*few*/*many*/*other* (*other*, reached only by a fraction, the
    genitive singular), Uzbek one value — and two new keys, `%1$d days` and `%1$d servings`, in the
    app's catalogue. App 105 keys, widget 19, watch 16.
  - Home's streak chip draws *12 days* — *12 дней*, *12 kun* — and the count alone where the noun does
    not fit beside the title, speaking the noun at every size. History's strip draws *5 servings*
    trailing its heading, or under it at the accessibility sizes; the heading speaks it as its value.
  - Every figure is grouped by the app's locale — spoken ones, both widgets' and the watch's rows —
    closing #39 with #40.
  - `LocalizationTests`' readers also read `Localizable.stringsdict`, where the build moves a key with
    forms, and compare bundles form by form; `PluralFormTests` (five tests) checks every counted key in
    every bundle at twelve counts in three languages, the no-locale finding, a German and a Japanese
    phone on *Follow device*, and the rule under them — `theFollowDeviceLocaleSpeaksTheBundlesLanguage`.
    UI tests read grouped figures; two new UI tests at the largest text size.
  - **The final review's one Important finding, fixed:** spec §8 said a Japanese phone on *Follow
    device* draws *1 millilitres*. Measured on the iOS 27.0 simulator under `-testLanguage`, the app's
    locale is English with the phone's region — `en_JP`, `en_DE`, `en_FR`, `en_UA` — because
    `.autoupdatingCurrent` takes the bundle's language: *1 millilitre*, no limitation. The invariant
    test was seen red in a scratch copy whose `.system` locale was built from the phone's language
    (*Follow device formats the en table with ja*), green on the real code; the German and Japanese
    tests were re-aimed at `en_DE` and `en_JP`; spec §8 carries a dated correction.
- **Rulings** (ledgered, each with its cost): the plan's comma literals in `WelcomeUITests` and
  `AppStoreScreenshotUITests` became `.formatted(.number)` — every simulator here is `en_UZ`, which
  groups with a space; of two `GoalSetupUITests` sites the plan missed, one was grouped the same way
  and the other made to count a figure's digits past its separator; the
  watch's `syncedCaption(composedAt: nil, …)` mention kept its ellipsis; the strip contrast went into
  `docs/DESIGN.md` as a dated note, not a row of the 3c table; Probe 27 was left with its widgets placed
  and 12,500 ml logged.
- **The owner's decision on the strip:** the plan's "the drawn count is not a second element" check
  was dropped — XCUITest lists hidden text in History's `List` rows, the hour labels and week figures
  at HEAD included — and known issue #139 records it, with a VoiceOver check in roadmap item 1.2.7.
- **Verification**, on a copy of the staged tree (`git checkout-index`):
  - unit `✔ Test run with 621 tests in 78 suites passed`; watch 57 in 6 suites;
  - UI on *WaterBuddy Gate 27* (iOS 27.0) and *Gate 26.5*: `GoalSetupUITests` 38 executed in four
    chunks, 1 skipped by design, 0 failures; the other classes 31, 0 failures — on each system;
  - both widget schemes built;
  - warnings, HEAD and the index each built clean, by file and message: none new on any scheme; a
    plain clean `build` of the app scheme has the 29 unique lines `CLAUDE.md` names;
  - renders from a scratch copy (Probe 27, Small 26.5): every chip and strip case in three languages at
    the default size and XXXL; the live switch to Русский; both Home Screen widgets in English at 1,500
    and 12,500 ml, light and dark; both Home Screen widgets and the Lock Screen rectangle and circle at
    12,500 ml in English, Russian and Uzbek, in one appearance — nothing cut;
  - the strip count's contrast, worst of a minute's sweep: 8.17:1 (iOS 27.0), 10.64:1 (26.5).
  - Not rendered: a tinted Home Screen, the Lock Screen's quiet form (needs a passcode), the inline
    Lock Screen shape, the watch's rows with a vessel of 1,000 ml or more — all in roadmap 1.2.7.
- **Counts:** 622 `@Test` (616 + five in `PluralFormTests` + one reader test; `HomeStringTests`
  replaced one), 57 on the watch, 56 UI `func test` (54 + two). The gate above ran before the review's
  fix added the fifth: unit 622 passed after it, and the three Follow-device tests passed again under
  `-testLanguage ja -testRegion JP`.
- **Waiting for the owner:** `/commit` — and the device sweep.

**Roadmap item 1.2.6, Russian plural forms (#40): the spec is written and staged, for the owner's
review — no code, no rule file, nothing in the repository built or run** (2026-10-16; written by the
sixty-fourth pass,
the owner's `/doc_sync` in the session that wrote the spec). HEAD is `52ee815`: 1.2.5, which the next
block describes as staged, was committed as `5241030` (its spec and plan), `86a44ed` (feat),
`314d63a` (docs, with `CLAUDE.md`'s three edits) and `52ee815` (the rule wording in the five files
the next block's *Waiting for the owner* names). Spec
`docs/superpowers/specs/2026-10-16-plural-forms-design.md`; no plan yet.

- **What the spec decides.** The owner approved its outline in three sections on 2026-10-16. The
  decisions:
  - **D1:** the fix brings back the two canvas details the redesign gave up for #40 — the streak chip's
    noun (*12 days*) and the strip card's count (*5 servings*).
  - **D2:** the counted keys get Apple's plural variations, formatted with the app's locale. Ten keys
    today and two new ones; Uzbek keeps its single values. Formatted with a locale, figures group —
    spoken ones too, so 18 lines of `WelcomeUITests` and three helpers in `GoalSetupUITests` change.
  - **D3:** the 32 sites that build a sentence as `String(format: strings.localizedString(…), …)` —
    18 in the app, 9 in the widget, 5 on the watch — move off it: 31 to one new
    `Bundle.localized(_:_:locale:)` beside `figure`, and `WristVessel.readout`, which hands over
    figures it has already formatted, to `figure`.
  - **D4, D5:** the chip draws the count alone where its noun does not fit; the strip's count trails its
    heading, or sits under it.
  - **D6:** the widgets' and the watch's drawn figures are included, so they group too, which would
    close #39.
  - **D7** (#50's catalogues) is open, for the owner.
  - **D8:** `Last %1$d days` gets forms though it is always 7.
- **Why the locale (measured on macOS, Darwin 27.0, by two throwaway probes in the session's
  scratchpad).**
  - A key with plural variations compiles into its table's `.stringsdict` and leaves its `.strings`
    (the probe's table was `Probe`).
  - `String(format:)` with no locale picks its form by the **English** rule under an English process
    locale (`en_UZ` and `en_US` were tried), the Russian table included: *Добавить 5 миллилитра*.
  - The rule follows the locale passed to the format, not the bundle.
  - Every locale tried that gives the Russian rule also groups `%d` (*1 240*); only `en_US_POSIX`
    printed *1240*, with the English rule.
  - Not yet seen on an iOS simulator — the spec's §6.1 tests show it once the forms exist; its red
    run, before them, cannot.
- **Waiting for the owner:** review of the spec, and of its Russian words (§3.3, written by a
  non-native speaker); D7; then the rule wording of its §5 (`50-views`, `65-accessibility`,
  `70-privacy`), to be typed into the rule files unstaged for approval before any code.
  *(2026-10-17, after the sixty-fifth pass: the owner answered the report of that pass with "go",
  taken as approval of the spec as it stands, its Russian words included. §5's wording is typed
  into the three rule files, unstaged, for the owner's approval. The plan is written and staged,
  `docs/superpowers/plans/2026-10-17-plural-forms.md`. Still waiting: approval of the rule wording,
  D7, and review of the plan; no code. At about 12:05 that day, by the folders' modification times,
  the repository moved from `~/Desktop/Projects/MobileApps/WaterBuddy` to
  `~/Desktop/Projects/MobileApps&Games/WaterBuddy` — not by this session. HEAD and the index came
  through unchanged.)*

**Roadmap item 1.2.5, the rating prompt, is built, gated and staged — not committed** (2026-10-15;
written by the session that built it, not a `/doc_sync` pass; one comment in
`DataManagerTests.swift` was reworded after the last unit run, comment only, and staged without
another). HEAD is `450d76f`: 1.2.4, which the
next block describes as staged, was committed as `2d233e1` (its spec and plan), `418fad3` (feat),
`fcfbc3c` (docs) and `450d76f` (its rule wording). Spec
`docs/superpowers/specs/2026-10-15-rating-prompt-design.md` (decisions D1–D5) and plan
`docs/superpowers/plans/2026-10-15-rating-prompt.md` (P1–P5), both approved on 2026-10-15 and run
inline in the main loop; ledger `.superpowers/sdd/2026-10-15-rating-prompt/progress.md`, the final
review beside it as `review-final.md` — git-ignored, on this Mac only.

- **What changed.** Apple's own rating request, `@Environment(\.requestReview)`, asked about 2.2 s
  after the user's own pour on Home takes today across the goal on the **third goal day in a row**
  (D1), at most **once per app version** (D2). `StoreKit` is imported by `HomeView.swift` alone
  (D3, the `70-privacy` amendment). A goal reached anywhere else — the widget, Siri, Control Center,
  a reminder's button, the watch, History's **+**, a `refresh()` on return — never starts one: only
  Home's own pour starts the wait (D5, for the return: that would be straight after launch; spec
  §3.7 for the rest). A wait Home's pour started can still end in a request when, after an *Undo*
  inside the pause, a watch or Siri pour takes today back over the goal — the final review set it
  aside, and it stands (the user is on Home, at the goal). `DataManager` gains `Key.reviewRequestedVersion`, the pure
  `mayRequestReview(reachedToday:streak:askedVersion:version:)` and `claimReviewRequest(version:)`,
  which writes the version before it answers `true`; the phone's suite holds ten keys. New app-only
  `ReviewPrompt.swift`: the pause, the version, and the DEBUG opt-in — **a DEBUG build never asks
  unless launched with `-WaterBuddyReviewPrompt`** (D4; the code checks that the argument is present,
  so any value after it, `NO` included, turns it on), because StoreKit shows the request
  every time in development and the UI suite pours on a long-gated simulator. Home waits with
  `.task(id: goalPours)` and asks only if it stayed the page shown and the app stayed active
  (`ratingWait`, cleared by the scene phase and, after the final review, by `RootTabView`'s new
  `pageIsShown`) and today is still at the goal. No string, entitlement, Info.plist key, privacy
  manifest or `project.pbxproj` line; only the app's binary links `StoreKit` (`otool -L` over the 24
  built binaries: `WaterBuddy.app/WaterBuddy.debug.dylib` alone).
- **Tests.** Twelve new `@Test`s in `ReviewRequestTests.swift` (`ReviewRequestTests` 8,
  `ReviewPromptTests` 4) and `everyKeyTheProductWritesIsOnTheRoster` widened. The nine of the
  decision, the claim and the roster were seen RED twice before the code — against a stub that always
  refused and one that always asked — and `ReviewPromptTests`' four once, against one stub; P1's read
  was proved by mutation (`string(forKey:)` turns a stored `1.2` into `"1.2"`).
- **On the simulator** (*WaterBuddy Probe 27*, iOS 27.0, a throwaway XCUITest probe on the DEBUG fresh
  start, deleted): the third goal day's pour showed iOS's *"Enjoying WaterBuddy?"* sheet after the
  confetti and never again in the version; an *Undo* inside the pause asked nothing and left the
  version for the next crossing; another tab early in the pause, the Home Screen and back, a run
  without the argument, and the goal reached from History's **+** each asked nothing. **The final
  review found one more:** a tab changed in the last ~0.45 s of the pause still asked, over the page
  sliding in, because a page that is left stays in the tree until its slide ends — seen, fixed with
  `pageIsShown`, and seen fixed: the tab tapped 1.96 s after the pour both times, by the probe's own
  stamp, the sheet over History before the fix and nothing after. After the fix only the ordinary
  request, the early tab and this case were run again; the *Undo*, the Home Screen, the run without
  the argument and History's **+** were seen before it.
- **Gate** (2026-10-15, after the fix pass):
  - unit, stock iOS 27.0 *iPhone 17*: `✔ Test run with 616 tests in 77 suites passed` (attribute grep
    616; 604 before);
  - UI, *WaterBuddy Gate 27* and *Gate 26.5*: `GoalSetupUITests` 36 executed in four chunks of nine, 1
    skipped (`testTheBarsCaptionsShareALine`), 0 failures; the other classes `Executed 31 tests, with 0
    failures`; on each system;
  - watch, *WaterBuddy Watch 27*: `✔ Test run with 57 tests in 6 suites passed`;
  - `WaterBuddyWidgetExtension` and `WaterBuddyWatchWidget`: `** BUILD SUCCEEDED **`.
- **Warnings.** Clean `build-for-testing` plus the widget build, HEAD against the staged index, each
  into an empty folder: the first comparison found one new line, in the new test file (an unneeded
  `try`), fixed; the second found none new and none gone — 36 unique by file and message, 52 whole
  lines, both sides. The two watch schemes, built clean at HEAD and from the index (the final
  review's Minor 8): 17 against 17, none new.
- **Review.** A fresh read-only reviewer (Opus): no Critical; one Important — the late tab change
  above, fixed test-first; ten Minor. Three re-graded and fixed as text (DocC that gave a false
  reason, a comment contradicting the one above it, and `WaterBuddyApp.freshStartManager`'s "a Debug
  build runs exactly what a Release one does", which this change made untrue); one taken as
  verification (the watch warnings); six deferred — #138.
- **Line citations.** This change moved lines in five files. Where a citation into them names a
  line of code in a sentence about that code as it stands — wherever the sentence sits — it now names
  that code's line and keeps the old number as "until 1.2.5": moved with the code where it was right
  at HEAD, and re-pointed where it already named another line (`role` and `enum Role`, #37's
  `:1312`, #104's `:1471`, #105's `:1476` and `:1448`, each found by a fresh reader). The chains in
  #103 and #109 that record where a line used to be are left as written. `docs/STATE.md`'s
  shorthand citations in *Who may write on behalf of the group* (`:551`, `:1162`, `:1083`, `:1709`,
  `:969`, `:1000`, `:1329`) already named other lines at HEAD and are left for a sync. #117's
  comments in `HomeView.swift` and `RootTabView.swift` — which it says go "with the next change to
  each file" — were not taken by this one, though it touched both: they are not this change's
  subject (rule `90-git`, one logical change).
- **Waiting for the owner:** the rule wording in `70-privacy`, `20-state`, `25-shared-storage`,
  `10-architecture` and `85-testing`, typed in and unstaged (`CLAUDE.md`'s three edits — the storage
  row, the writer list and the baseline clause — are staged with these records); the device check
  (#137); and the deferred minors (#138).

**Roadmap item 1.2.4, Log from a reminder, is built, gated and staged — not committed** (2026-10-15;
written by the session that built it, not a `/doc_sync` pass). HEAD is `6010e25`: stage 5, which the
next block describes as staged, was committed as `d6a3817` (its spec and plan), `2af8dbc` (feat),
`026ef71` (docs) and `6010e25` (its rule wording). Spec
`docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md` (decisions D1, D2) and plan
`docs/superpowers/plans/2026-10-15-log-from-a-reminder.md` (P1–P6), both approved on 2026-10-15 and
run inline in the main loop; ledger `.superpowers/sdd/2026-10-15-log-from-a-reminder/progress.md`,
the review beside it as `review.md` — git-ignored, on this Mac only, so what a reader elsewhere needs
is said here.

- **What changed.** A reminder now carries one button, *Log a Glass*, with the Glass's glyph. Pressed,
  it logs the Glass without opening the app. It is built to run without unlocking (owner's ruling D1,
  as the Siri phrase and the control: the action is not `.authenticationRequired`) and from Apple Watch
  (the iPhone app registers it), but only an unlocked simulator was tried — the locked phone, the
  watch and before the first unlock are device steps (#133). `ReminderResponder` (new,
  app-only) is the notification centre's main-actor delegate, installed in `WaterBuddyApp.init()`; it
  runs `LogServingIntent.logTheGlassInTheBackground()`, the three steps Siri's `perform()` took, now
  one function both call. The category is registered only by the app, in
  `requestReminderReschedule`'s queued operation, in the bundle the reminder copy is filed in;
  `reminderContent(in:)` names it, so reminders the widget files carry the button too. `reconcile`
  files again a reminder still in the plan that is pending in other words — title, body, category —
  than it would file now (D2), so reminders filed by 1.1 gain the button at the first launch and the `language`
  setter, which now re-plans, puts every pending reminder into the new language. The seam:
  `ReminderScheduler` is `nonisolated`, its pending read returns `PendingReminder`s, and it gains
  `setCategories`; `AppLanguage.bundle` is `nonisolated`. No string, key, entitlement, Info.plist key or
  `project.pbxproj` line was added.
- **Tests.** Eleven new `@Test`s — eight in `NotificationManagerTests`, one in `LocalizationTests`, two in
  `ReminderSeamTests` — and two widened (`theReminderCopyCarriesNoUserValues` reads the button's title;
  `theTranslatedReminderCopyStillCarriesNoUserValues` requires it in `ru` and `uz`). Each code task's
  tests ran before its code: tests naming new symbols failed to build, and the re-file and
  language-setter tests failed at run time. Four could not fail before their change: two were proved by
  mutation (ledger, Tasks 2 and 3), and the two digit checks on the button's title, which already
  shipped digit-free for Siri, were not.
- **Gate** (2026-10-15, after the review's fixes; logs in the session's scratchpad):
  - unit, stock iOS 27.0 *iPhone 17*: `✔ Test run with 604 tests in 75 suites passed` (attribute grep
    604; 593 before);
  - UI, *WaterBuddy Gate 27* and *Gate 26.5*: `GoalSetupUITests` 36 executed in four chunks of nine, 1
    skipped (`testTheBarsCaptionsShareALine`), 0 failures; the other classes `Executed 31 tests, with 0
    failures`; on each system;
  - watch, *WaterBuddy Watch 27*: `✔ Test run with 57 tests in 6 suites passed`;
  - `WaterBuddyWidgetExtension` and `WaterBuddyWatchWidget`: `** BUILD SUCCEEDED **`.
- **Warnings.** Clean `build-for-testing` plus the widget build, HEAD against the index as exported at
  13:21 (the readers' fixes after it changed comments only, line for line), each
  into an empty folder: no new line by file and message; two gone — `removePending` and
  `removeDelivered` in `NotificationManager.swift`, which `ReminderScheduler`'s `nonisolated` removed.
  52 unique whole lines against 54; the shipping sources 29 against `CLAUDE.md`'s 31.
- **On the simulator** (*WaterBuddy Probe 27*, iOS 27.0, a throwaway XCUITest probe, deleted; reminders
  pushed with `xcrun simctl push`):
  - with the app terminated, *Log a Glass* launched it in the background, left it there, and logged
    the Glass once (0 → 250) — `App.init()` installs the delegate early enough;
  - a Glass edited to 700 logged 700;
  - in Russian the button read *Записать стакан* — on a reminder delivered in English before the
    switch, because iOS looks the category up when it shows one;
  - a tap on a reminder's banner opened the app and logged nothing;
  - pressed with Notification Center pulled over the open app, the total rose by one Glass in the
    same process.

  The glyph is drawn before the title, not after as the spec first said (corrected). On this
  simulator a long press never opened a reminder — a lone one stayed in its short look, and two
  expanded the group; swiping one left and choosing *View* opened it with its button, and iOS also raised a keyboard and a reply bar under it — iOS's, not the
  app's. A tap on a reminder in Notification Center, three ways, did not open the app, so that case was
  proved on a banner.
- **Review.** A fresh read-only reviewer: no Critical, no Important, seven Minor. Three were re-graded
  and fixed as text — the DocC and the rule wording had rested the responder on "the centre calls its
  delegate on the main thread" and said nothing calls the scheduler on the main actor
  (`ReminderPermission` does), and rule 80's *Identifiers* contradicted its new section. Four are
  deferred: the *Follow device* case is not pinned by a test (#134); no test pins where the category
  is registered (#135); a rule line unwrapped and *Who reschedules*' lead sentence; `reconcile`
  composes the reminder twice.
- **Waiting for the owner:** rule wording in `80-notifications`, `70-privacy`, `43-concurrency` and
  `85-testing`, typed in and unstaged; the device sweep's eight steps (#133); and the vessels note,
  which does not name the reminder's button among the doors that log the Glass (#136, found by the
  sixty-first pass's `/doc_sync`).

**The redesign's stage 5, the welcome, is built, gated and staged — not committed** (2026-10-14;
written by the session that built it, not a `/doc_sync` pass). HEAD is `1438122`, level with
`origin/main`: stage 4, which the next block describes as staged, was committed and pushed on
2026-10-14 as `4e70235` (feat), `c7d2661` (plan), `d58116f` (docs) and `1438122` (its rule
wording). Spec `docs/superpowers/specs/2026-10-14-welcome-design.md` and plan
`docs/superpowers/plans/2026-10-14-premium-redesign-stage-5.md` (decisions P1–P10), both approved
by the owner on 2026-10-14 and run inline in the main loop; ledger
`.superpowers/sdd/2026-10-14-premium-redesign-stage-5/progress.md`, the final review beside it as
`review-final.md`. Roadmap item 1.2.3. **That folder is git-ignored** (`.gitignore:7`,
`.superpowers/sdd/`), so the ledger, the review, the readers' reports, the measurement tables and
the gate's logs it holds live only on this Mac; what a reader elsewhere needs is said here.
*(The gate bullet carries one sentence the fifty-ninth pass added, and says so.)*

- **What changed.** `GoalSetupView.swift` is deleted. The first-run screen is `WelcomeView`: four
  steps under one pinned bar of dots, *Back* and the main action — *Hello* (the vessel at half,
  *Welcome to WaterBuddy*, *Get Started*); *Daily goal* (the slider, and *Work it out for me*, which
  opens a calculator: a weight on a wheel in kg or lb, *Light*, *Moderate* or *Active*, and *Use*);
  *Quick-add vessels* (the three rows Settings draws, lifted into `VesselSliders`); *Reminders* (a
  preview of the reminder in its own words, seven bells over `ReminderPlan.hours`, *Turn on
  reminders* or *Not now*). The steps are mounted side by side and slid, a fade under Reduce
  Motion. Finishing runs `WelcomeView.finish(...)`: the vessels if they were moved, then the
  question if reminders were asked for, then the goal — and saving the goal is what closes the
  welcome, so the app opens on what was chosen.
- **The calculator** (`GoalSuggestion`): 30 ml a kilogram plus 0, 350 or 700 ml, in whole numbers —
  a pound converted with integer arithmetic — rounded half up to the slider's 100-ml step and held
  to its 1,000–4,000. Pounds come first only where the region measures in US units. Nothing is
  stored: a weight goes in and a goal comes out.
- **Asking for reminders has one door, `ReminderPermission`**: Settings' switch and the welcome's
  *Turn on reminders* ask through `enable(on:using:)`; `reconcile(_:using:)` reads the system's
  answer and turns reminders off when iOS says *denied* — when Settings appears, as before, and,
  new, on every return to the foreground. That is #100(d)'s fix, on disk; the revoke-and-return walk
  is a device check still to do (below).
- **`-WaterBuddyFreshStart`, DEBUG only:** the app opens on a throwaway suite,
  `uitest.waterbuddy.freshstart`, cleared at each launch, and an in-memory store — so
  `WelcomeUITests` sees the welcome on any simulator without erasing it. No other UI test passes it.
  *(2026-10-18, roadmap item 1.2.8: the store capture, `testCaptureAppStoreScreenshots`, passes it
  too, as rule `85-testing` now says — staged.)*
- **Strings:** 28 new keys in English, Russian and Uzbek, the Russian and Uzbek drafted by this
  session, for the owner to read.
- **The owner's rulings mid-stage (2026-10-14, R1–R5),** after the first sweep found eight things
  under their floor (nine rows of its table — the dots were read on two steps): the goal and
  vessels steps' lines move into their cards as each card's first line, and the reminders line
  stays on the aurora at full white (R1); the glyphs keep cyan and move — bells onto frosted discs,
  the sparkle after the words, the Cup clear of the sheen (R2); the inactive dots at white 0.6 (R3);
  the goal footnote at white 0.95 (R4); both card lines full white (R5). The vessels footnote took
  0.95 too, by this session's own ruling, so the two lines on the aurora share one white.
- **The final review's one Important finding, fixed:** a double tap on the bar skipped a step (and
  could finish from the vessels step unseen). A turn now runs to its end before the next is taken —
  `turning`, cleared by the slide's own completion, with the bar's buttons disabled meanwhile;
  `testADoubleTapMovesOneStep` red, then green. The UI tests tap the bar through `tapWhenReady(_:)`,
  because XCUITest's idle wait does not cover a SwiftUI slide. The review's rule-wording finding
  was rewritten in the unstaged rule edits; its other findings are deferred minors (#131, and #132
  for the one older than the stage).
- **Measured** (`docs/DESIGN.md`, *Welcome, measured*): 69 pairs listed a system — 59 on the
  welcome's steps and 10 on Settings after its vessel rows moved out — and 68 of them read (*Your
  weight* has no clean ground beside it), a minute's sweep on iOS 27.0, 26.5 and 18.6, none under
  its floor. Tightest, against 3: Settings' Cup glyph, 3.11 / 4.08 / 3.10, beside its card's
  sheen as at stage 4 (3.08 then); the welcome's Cup glyph, 3.28 / 4.39 / 3.25. Against 4.5:
  Hello's line, 4.76 on all three; on 27.0, *Work it out for me* 4.83 and the reminders line 4.84.
  Increase Contrast, Russian and Uzbek, Reduce Motion and Transparency, the 375-pt phone and the
  slide were rendered on the build before R1–R5 — so not with the sparkle moved or the bells on
  their new glass — and the small phone at the largest text size again after them, on iOS 26.5:
  nothing cut, and two steps scrolled up are clipped at the status bar's lower edge, not drawn
  under the clock (#89). Landscape: every step whole, but Hello's greeting is below the fold
  (#130).
- **Gate, run on an export of the index** — `git checkout-index` into the session's scratch
  folder, built into its own empty DerivedData — so the six files that sat unstaged from before the
  stage (`.claude/settings.json`, two watch schemes, three string catalogues) stayed out. The
  stage's 23 staged source, test, tool, string, spec and plan files were compared with that export
  afterwards and match it; the eight records changed after it. **Warnings:** 32 lines by the
  stage's own count — every `warning:` line, path, line and column stripped, so 21 by file and
  message (19 in the product, 2 in test files), 9 from `#expect` macros expanded, 1 from `@Test`
  and 1 from the App Intents metadata step — identical on HEAD's build and the index's by `comm`.
  *(Added by the fifty-ninth pass:)* counted as `CLAUDE.md` counts — whole lines, with line and
  column — the same two builds give 37 each, 31 outside `WaterBuddyTests/`, so `CLAUDE.md`'s 31
  stands. **Tests:** unit `✔ Test run with 593 tests in 75 suites passed`; UI on 27.0 and again on
  26.5, each 67 executed, 1 skipped by design, 0 failures — run in chunks, `GoalSetupUITests`
  split into four runs of nine tests named by flag files and the other classes in a fifth, because
  the whole UI suite outlasts the 600-s foreground limit. On 27.0 the first two chunks ran in one
  call, which the harness moved to the background past 600 s; the first chunk passed 9/0 in that
  call, and the second chunk's first test spent 1,948 s failing to launch the app while the Mac
  stalled, the tests after it taking up to an hour each. The device was rebooted by its UDID and
  that chunk re-run alone in the foreground: 9/0 in 209 s. Every later chunk ran alone. Watch
  `✔ Test run with 57 tests in 6 suites passed`; both widget builds `** BUILD SUCCEEDED **`, the
  watch widget's only other warnings #36's two. The logs are in the ledger folder's `final-gate/`.
- **Waiting for the owner:** the stage's rule wording, typed into six rule files and unstaged —
  `10-architecture`, `43-concurrency`, `50-views`, `70-privacy`, `80-notifications`, `85-testing`;
  three more pieces of governing text recorded and not typed — rule `60-design-system`'s list of
  haptic counters lacks the welcome's (#111), rule `43-concurrency`'s sentence naming the app-only
  `Task`s lacks the two the stage added (`WaterBuddyApp.swift:121`, `WelcomeView.swift:762`), and
  `CLAUDE.md`'s hard limit says tests get a UUID-named suite where the fresh start's has a fixed
  name; the translations; and the device checks in #130.

**The redesign's stage 4, Settings, is built, gated and staged — not committed** (2026-10-13
evening to 2026-10-14, just after midnight; written by the session that built it, not a `/doc_sync`
pass). HEAD is `c9d1f6b`, level with `origin/main`: stage 3c, which the next block describes as
staged, was committed and pushed on 2026-10-13 as `a58b9e6` (feat), `3b7bb1e` (spec and plan),
`6020076` (docs) and `c9d1f6b` (its rule wording). Design: the redesign's spec §7 and the canvas's
*Settings* board, read from its source; no separate spec. Plan
`docs/superpowers/plans/2026-10-13-premium-redesign-stage-4.md`, run under the 2026-10-09 ruling;
ledger `.superpowers/sdd/2026-10-13-premium-redesign-stage-4/progress.md`. Roadmap item 1.2.2.
The owner's rulings (2026-10-13, "go"): **S1**, the three notes share one style, 15 pt at white
0.92, where the canvas drew the language footnote at 13; **S2**, the new ticks are `Haptics.select`,
with stage 3b's haptics wording put to them unstaged.

- **What changed** (`WaterBuddy/SettingsView.swift` and one string). The four cards take the
  canvas's padding (20), gap (16), one title style and one note style (`SettingsStyle`); the goal's
  figure is 36-pt bold with its *ml* at white 0.9, the range labels white 0.88; a vessel's glyph
  sits in a 26-pt box, its name and amount at 17 pt, the amount full white and grouped
  (`strings.figure("%1$@ ml", …)`) — rule `50-views`' grouped volume, which Settings did not yet
  draw. The vessels note reads *"The Glass is the one your widget, Siri and Control Center log."*
  under a hairline, in English, Russian and Uzbek (*Виджет, Siri и Пункт управления записывают
  Стакан.* / *Vidjet, Siri va Boshqaruv markazi Stakanni qayd etadi.* — drafted by this session, for
  the owner to check); the old key is gone. Language rows are 50 pt with white 0.16 hairlines.
- **Behaviour.** `.onAppear { manager.refresh() }`; the goal and vessel cards, which copy the
  model once in `init`, take a re-read value through `onChange` unless a drag is in flight. A drag
  ticks `Haptics.select` at each step (100 ml goal, 50 ml vessels) from a `steps` counter bumped in
  the slider's binding; a language picked ticks `select` instead of `confirm`. A VoiceOver
  adjustment still commits at once with `confirm` and no tick.
- **Two things the stage's own checks found and fixed.** At `AccessibilityXXXL` on a 375-pt phone a
  vessel's amount was cut to "150…" — the row is now a `ViewThatFits`, measured at its widest
  (every vessel's name, the slider's largest amount) so all three rows choose together and a drag
  cannot flip one. And the final reviewer (`review-final.md` in the ledger folder) found the title
  would stand one point lower than Home's — the new top padding's point is taken back off the
  inset, as History does (`testTheTitleHoldsItsPlaceOnEveryTab`, green; not seen red).
- **#108 is fixed**: one point of top padding on the reader; rendered on four devices, scrolled,
  nothing drawn under the clock.
- **Measured** (`docs/DESIGN.md`, *Settings, measured*): nineteen pairs, a minute's sweep on iOS
  27.0, 26.5 and 18.6 — none under its floor; tightest the Cup's glyph (3.08 / 4.02 / 3.09 against 3)
  and the reminders explanation (4.89 / 6.37 / 4.93 against 4.5). Three frames a system at rest on
  the final source. On the probe build before the review's changes: Increase Contrast, Russian and
  Uzbek; the largest text size on the 375-pt phone, rendered again on the final source.
- **The gate, on the final source** (iOS 27.0 *iPhone 17* for unit tests, *WaterBuddy Gate 27* and
  *Gate 26.5* for UI, *WaterBuddy Watch 27*): **557 `@Test` in 69 suites passed**; UI on each system
  three `GoalSetupUITests` chunks of 12 by name and the other classes — **54 executed, 1 skipped,
  0 failures** on 27.0 (before midnight) and on 26.5 (after it); **57 watch tests passed**; both
  widget builds `** BUILD SUCCEEDED **`. **Warnings: no new line** — an export of the index built
  clean as HEAD was gives the same 21 unique lines (by file and message) and the same primary-line
  counts, 49 and 43. Two comments in `SettingsView.swift` changed after the gate — the DocC
  sentence that named `EditServingSheet` (#84(c)), and the Cup glyph's figure for iOS 18.6, 3.10 →
  3.09, the measurement after its box was moved; the app was built after them. An earlier run of the first UI chunk, at
  a load of 104, failed `testAnOlderPoursTimerDoesNotEndANewerOffer` on its own slow-machine guard
  (7.58 s against 6.5); the gate's run of the same chunk, at a load of 7.6, passed it.
- **Rule wording, unstaged, for the owner:** `50-views` (all three tabs refresh; a mirrored
  `@State` re-seeded from the model's change), `60-design-system` (stage 3b's haptics bullet naming
  `select` and `remove`, and `steps` among the counters — once approved, the haptics half of
  #111),
  `65-accessibility` (50 pt for a language row).
  *After the fifty-eighth pass, 2026-10-14, the owner approved the wording ("Approve rule
  wording"); the three files are staged as typed, with stage 4, for `/commit`.*
- **Not done here:** a device (the ticks are felt only there), Reduce Transparency on Settings (no
  pane changed), iOS 17. Known issue #129.

*(The block below is stage 3c's, as it was written. Its "not committed" is superseded above.)*

**The redesign's stage 3c, the look, is built, gated and staged — not committed** (2026-10-13,
afternoon; written by the session that built it, not a `/doc_sync` pass). HEAD is `684f3dd`, 104
commits, `## main...origin/main`: stage 3 and 3b, which this file's next block describes as waiting,
were committed and pushed that morning — eight commits, the plan's seven and a `CLAUDE.md` chore.
Spec
`docs/superpowers/specs/2026-10-13-the-look-design.md` (approved, "ok"), plan
`docs/superpowers/plans/2026-10-13-premium-redesign-stage-3c.md` (run under the 2026-10-09 ruling,
without its own review), ledger `.superpowers/sdd/2026-10-13-premium-redesign-stage-3c/progress.md`.
Roadmap item 1.2.1 (`docs/ROADMAP.md`).

- **The glass (a).** Apple's glass (iOS 26+) is tinted with `Aurora.top` at **0.64**
  (`LiquidGlass.systemTintColor`, `systemTintOpacity(for:)`), and the hand-made sheen and lit rim
  are laid over it, under the content (`litSurface`). The phone's hand-made pane (iOS 17–25) is
  scrimmed with `Aurora.top` at **sheer 0.30, frosted 0.70, opaque 0.80**; the widget's `.archived`
  base and the watch keep black at 0.16 / 0.28 / 0.40 — one pure function decides it,
  `LiquidGlass.scrim(density:scheme:base:onPhone:)`. `Density.scrimOpacity(for:)` is gone.
- **The vessel (b).** Home's `WaterVessel` draws the canvas's glow, halo and highlight, none of
  them under Reduce Transparency. `WaterSurface.swift` untouched.
- **The week card (c).** Rounded tracks and bars (`LiquidGlass.innerCornerRadius`), a dashed goal
  line, a ring on the shown day's track and a white disc behind its letter (`Selection.ringOpacity`,
  `.ringWidth`, `.discFill`; the disc placed from the letter's anchor), the other letters full white
  and the disclosure 0.88 as the canvas drew them. The row stands 16 pt in — with each bar's own 4,
  the outer tracks 20 pt from the card's edge, where the canvas's padding puts them — **or less**: a
  `DayRow` layout takes `HistoryView.dayRowInset(across:count:)`, 9.5 on a 375-pt phone, so each day
  stays 44 pt wide — the final review caught 42 pt there.
- **A serving's glyph (g).** White on an `Aurora.cyan` 0.16 wash; a cyan glyph read 2.46 against 3
  on it (2.66–2.79 on a 0.08 wash).
- **Measured** on iOS 27.0, 26.5 and 18.6, a minute's sweep per screen (the *Undo* pane two
  frames; empty History and the first run at rest): nothing measured that this stage draws is
  under its floor; the vessel's ml line over water stays under (4.05–4.20, #95). Tables:
  `docs/DESIGN.md`, *The look, measured*. #85 is closed for the phone's own panes as far as they
  were measured — the past-day empty state's line was not (#127) — and open for the widget and the
  watch.
- **Gate, on the final tree:** unit `✔ Test run with 556 tests in 69 suites passed`; UI on *Gate 27*
  and *Gate 26.5* each 52 run (`GoalSetupUITests` 34 in chunks 11 / 11 / 12, the other classes 18),
  0 failures, one self-skipping test (`testTheBarsCaptionsShareALine`, iOS 26+); watch `✔ Test run
  with 57 tests in 6 suites passed`; both widget builds `** BUILD SUCCEEDED **`. **Warnings: 21
  unique by file and message, identical to HEAD's 21** (clean builds of both). Counts by the
  attribute grep: 556 phone `@Test`, 57 watch, 39 UI `func test`. iOS 18.6's UI suite not run.
- **For the owner:** the rule wording in `60-design-system` and `65-accessibility` (typed into the
  rule files, unstaged, #126); the decisions L1–L11 of the spec's §9; #123 to #127; a device check.
  *After the fifty-seventh pass the owner approved the rule wording; both files are staged (#126),
  and #128 is one sentence beside it.*
- **Git, read at 15:25:** 17 staged (stage 3c's code, tests, spec, plan and docs, and — their own
  change — the App Store header, its HTML source and `docs/ROADMAP.md`), 8 unstaged (the two rule
  files, and six from before this session), 1 untracked (`Screenshots/census/`). Nothing committed;
  `HISTORY.md`'s newest checkpoint lists every path. *Re-read at 16:05 by the fifty-seventh pass,
  after its `git add`: 20 staged — the same 17 and `CLAUDE.md`, `docs/STATE.md`, `docs/WIDGET.md`;
  the same 8 unstaged and 1 untracked. See* Git.

*Superseded on the morning of 2026-10-13 (noted by the fifty-seventh pass): the owner approved the
plan, and stage 3 and stage 3b were committed and pushed — `e0762ab` to `684f3dd`, the block above.
This block stays as the record of that gate.*

**The staged tree — stage 3 alone — was gated by itself on the night of 2026-10-12 to 13,
before a commit plan was put to the owner. Nothing is committed and the plan is not approved**
(2026-10-13, the fifty-sixth pass). The owner ran `/commit`. The gate of 2026-10-12 ran on the
working tree, stage 3 and stage 3b together; stage 3 commits first, from the index, and that
tree had not been tested in this session. It was exported with
`git checkout-index -a --prefix=…` to a scratch folder — 161 files, the index's 161 — and
built and tested there, into its own DerivedData. No file of the working tree and no entry of
the index was changed. `git write-tree`, run to name the index's tree, wrote eight tree
objects under `.git/objects`.

| | Result |
|---|---|
| Phone unit, stock *iPhone 17*, iOS 27.0 | `✔ Test run with 479 tests in 60 suites passed` |
| Phone UI, *WaterBuddy Gate 27*, iOS 27.0 | `GoalSetupUITests`: 25 of 25 passed, **24 in their chunks and one alone after its runner was killed** (below); the other classes `Executed 18 tests, with 0 failures` |
| Phone UI, *WaterBuddy Gate 26.5*, iOS 26.5 | `GoalSetupUITests` 25 passed, 0 failures, in three chunks; the other classes `Executed 18 tests, with 0 failures` |
| Watch unit, *WaterBuddy Watch 27* | `✔ Test run with 57 tests in 6 suites passed` |
| `WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |

- **One chunk ended `** TEST FAILED **`.** The first chunk on iOS 27.0, nine tests from
  23:31:39: eight passed, and for `testAnUndoOfferExpires` the result bundle, read with
  `xcresulttool` that night, gave "Test crashed with signal term". That bundle has since gone
  from DerivedData; the log has "Restarting after unexpected exit, crash, or test timeout"
  32 seconds into the test, after a last logged step of `Waiting 5.0s for "Get Started"
  Button to exist`, and names the test under "Failing tests:". Run alone at 23:46 it passed
  in 21.5 s. On iOS 26.5 it passed in its chunk. What sent the signal is not known (#122).
- **Not run on iOS 18.6**, which stage 3's own gate had, and no warnings comparison: the
  warnings baseline of 2026-10-11 was built from an export of this index.
- The first chunk on iOS 27.0 did not carry `-collect-test-diagnostics never`, as rule
  `85-testing`'s commands do not. Every UI run after it, and the watch unit run, did (#101).
- The iOS 26.5 runs were held until 00:03 on the 13th, after the day had changed, with the
  simulator booted first.

**A plan of seven commits was then presented** — three for stage 3 from the index, four for
stage 3b from the working tree — and waits for the owner's word, with one question: whether
the two rule files that hold stage 3's wording go in. `/commit` changed no file of the working
tree.

---

**Stage 3b has had a second pass — the page slide and the small touches — finished, tested and
unstaged, on top of its first build; stage 3 is still in the index; nothing is committed**
(2026-10-12, the fifty-third pass). Spec
`docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md`; plan
`docs/superpowers/plans/2026-10-12-premium-redesign-stage-3b-motion.md`; both untracked.

**How it came about.** The owner built the first build of stage 3b to their iPhone 15 Pro Max
(iOS 27.0) and said: "there is no animation in page changes and add some micro-interactions
when working in app. it is not looks like premium." Asked what the content under the title does
on a change of tab: "It just appears." That build changed the page in one frame and let the
content rise 10 pt under a fade — checked frame by frame off recordings, never by eye on a
phone. They chose a **slide, by direction**, and **all four** groups of micro-interactions.

**What the second pass is.**

- **A change of tab slides the pages.** They sit side by side in the bar's order; the new page
  comes in from the side its tab is on while the old one leaves the other way, both on screen,
  0.45 s on `.smooth`. The backdrop holds still. Under Reduce Motion the page cross-fades in
  0.25 s and nothing travels.
- **`RootTabView` is one pager on every system.** One `AuroraBackground` for the three tabs,
  two pages at most (`PageTurn`, a pure value: shown, leaving, direction, a count of turns), the
  bar in a bottom `safeAreaInset`. **Apple's `TabView` is gone**: it cuts the old page away and
  offers no transition. Its bar stays — `SystemTabBar`, the same `UITabBar` standing alone —
  and on iOS 27.0 the screen's foot is close to what the `TabView` drew: no pixel of the bottom
  700 differs by more than 24 levels of 255 in grey, which is what was measured, and the bar
  itself by up to 11 (#119). *(The fifty-third pass wrote "pixel for pixel" here; the measure
  has a tolerance, and inside it the bar differs.)*
- **A page is rebuilt each time it is shown**, as before stage 3b. Kept screens, `isShownTab`
  and the two `onDisappear` resets are gone.
- **`Motion`** names the curves: `page`, `pageFade`, `settle`, `land`, `water`, `drop`.
- **Water:** a 22 pt drop flies from the pressed disc to the vessel in 0.42 s (`PourArc`), the
  vessel swells 2.5 % as it lands and the surface surges then; the level rises on a spring.
- **History:** one marker glides to the shown day; the strip's bars grow again on a change of
  day (simply there under Reduce Motion). **Settings:** a tick draws itself when the goal or a vessel is saved; the figure under a
  held slider grows 6 %. **Home:** the streak chip and *Undo*'s capsule land on a spring.
- **Scrolling:** a section of History or Settings shrinks toward 0.92 as it crosses the top or
  the foot of the screen (`ScrollDepth`). It does not fade.
- **The settle (`Arrival`) is the opening page's only.** A page that slides in has its
  sections whole — at full opacity, not risen. **History's bars are the exception, and meant:**
  the week card's and the strip's stand at nothing until the page's flag is set, 50 ms after
  it is built, and grow over half a second, so they are still growing as History comes to
  rest (`HistoryCard.grown`, `DayStrip.grown`; `Arrival`'s DocC: "History's bars on every
  page"). Under Reduce Motion they are simply there. *(The fifty-third pass wrote "a page that slides in is whole", without the
  exception.)*

**Decisions taken on the way, each the owner's to overturn** — the spec's §9, M1 to M11. The
ones that change what the owner asked for or had: **the bar's glass is darker on iOS 26.x**
than a `TabView`'s, and within 11 grey levels of it on 27.0 (M1, #119); **the scroll effect does not fade**, where
they chose "fade and shrink" — a fade took a measured line under its contrast floor (M8);
**a tap on the tab already shown does nothing**, where a `TabView`'s bar scrolled to the top
(M11); two more springs against a rule that names one (M3); one backdrop for the three tabs
against the rule that each screen stands its own (M5).

**The rules are not edited.** The spec's §7 has the wording, and it replaces stage 3b's §8
where they overlap (#111, #121).

**A fresh reviewer read the pass's diff**; its report is saved as it arrived, beside the
ledger. No critical finding, two important, eleven minor, thirteen things it declined to judge.

- **The scroll effect dimmed text still on screen.** Three things in the report, which the
  fifty-third pass ran into one sentence here. Its arithmetic: a 330 pt card with a third of
  itself past the top is drawn at about five sixths of its strength. Its two readings, off
  603 px video frames it called "indicative, not a `DESIGN.md` figure": with History's week
  card mostly out of the screen, *Measured against your current goal* at about
  **3.6–4.0:1**, where it is 5.49:1 at rest and the floor is 4.5; and with Settings' vessels
  card about a third out, its caption at about **5.9–6.9:1**, where the same kind of line in
  a whole card read 10–12:1 — dimmer, and over the floor. The reading under the floor is of
  the card mostly out, not of the card a third out, and "about 3.8:1" is the middle of the
  first range and in no report. And a card taller than the screen was never whole and
  jumped at the edge. Fixed: counted by what is left showing, and no fade.
- **Its figures were not the final tree's, and Reduce Motion had never been executed.** The
  gate below is on the final source. Reduce Motion was switched on through the simulator's own
  Settings app — the first time in this project — and eleven tests and a recorded walk ran
  under it.
- **Its own first build of the scroll effect, `scrollTransition`, was caught by eye before the
  review**: inside History's `List` every row stood dimmed and shrunk at rest.
- **A page arriving was mostly a header**: its sections faded in as it slid. Declined by the
  reviewer as the owner's to judge; changed — a page slides in with its sections whole.
- Minor, fixed: a slide's end is matched to the turn and not to the page (there, back and
  there again inside one slide ended the newest one early); the landing spring is on the
  capsule and the chip, not Home's root; Settings' cards move together; the tick takes no room
  in its row; a re-check after the tick's wait; geometry that is not a number is no span; the
  comments it listed as false. Deferred, for the owner: #120.

**The gate, on the final source** — foreground, `-parallel-testing-enabled NO`, 2026-10-12,
13:57 to 14:40, no `shutdown all`; the last source file was written at 13:42. **No test run
was retried. The warnings comparison was made twice**, which the fifty-third pass's "no run
was retried" left out. First: the clean build of the app scheme from 13:58:46 and the widget
build from 13:59:08. The ledger's only word on that attempt, at the time, is that it "used `build` and was
not like for like", which fits the app's build, whose baseline was taken with
`build-for-testing`; its commands are in no file. Again: the app with `build-for-testing`
from 13:59:50, into a new empty folder, and the widget with `build` from 14:00:14, as its
baseline was taken. The widget build is also the gate's fourth invocation, so that one ran
twice. The second attempt's logs replaced the first's and are what the table gives.

| | Result |
|---|---|
| Phone unit, stock *iPhone 17*, iOS 27.0 | `✔ Test run with 547 tests in 68 suites passed` |
| Phone UI, *WaterBuddy Gate 27*, iOS 27.0 | `GoalSetupUITests` 33 executed, 1 skipped, 0 failures, in three chunks; the other classes `Executed 18 tests, with 0 failures` |
| Phone UI, *WaterBuddy Gate 26.5*, iOS 26.5 | 33 executed, 1 skipped, 0 failures; 18, 0 failures |
| Phone UI, *WaterBuddy Gate 18.6*, iOS 18.6 | 33 executed, 1 skipped, 0 failures; 18, 0 failures |
| Watch unit, *WaterBuddy Watch 27* | `✔ Test run with 57 tests in 6 suites passed` |
| `WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |
| Warnings, a clean `build-for-testing` of the app scheme and a widget build into an empty folder, against the same of the index | 50 distinct lines and 38, the same sets |

**Under Reduce Motion, *WaterBuddy Probe 27*:** eleven tab and Home tests, 0 failures —
`testOnlyThePageShownIsInTheTreeAfterAChangeOfTab` among them, so the page left behind is
removed when the cross-fade ends. Not part of the gate: the gate's devices have it off.

**Rendered, on simulators, frame by frame:** the slide on iOS 27.0, 26.5 and 18.6; the same
change of tab under Reduce Motion; a pour's drop and the vessel's swell; the marker; the tick;
a section crossing the top in History and in Settings, 27.0 and 26.5; landscape and a change
of language under `SystemTabBar`; the first-run screen handing over to the app (a cross-fade
in place — Home does not slide in); the foot of the screen against the `TabView` build's on a
402 × 874 pt phone (27.0: no pixel of the bottom 700 differing by more than 24 levels in grey) and on
402 × 874 and 375 × 667 pt phones on 26.5 (same layout, darker glass).

**Not done.** Nothing on a device: the owner's phone is where this pass is judged. A second
tab chosen inside the 0.45 s of a slide — XCUITest waits between taps; the value's half is
unit-tested (#120). The bar's captions on iOS 26.5 are from seven frames — six of the walk and
one still of Home — not a minute of the aurora. iOS 17.x is compile-only, as before.

---

**Stage 3b's first build, as the fifty-first pass recorded it.** Kept as written. What the
second pass replaced in it: the `TabView` container and `SystemTabs`/`HandMadeTabs`, kept
screens and `isShownTab`, the settle as the whole of a page change, and *Undo* on `.smooth`.
Its header, its shade, its two haptics and its one clock for the backdrop stand. **Three
figures in the block below are the first build's and not the tree's** (added by the
fifty-fourth pass): a section rises **14 pt** now and each waits **50 ms** for the one above,
where the block says 10 pt and 40 ms (`Arrival.rise`, `Arrival.stagger`), and *Undo*'s capsule
arrives from **0.8** of its size, where it says 0.92 (`HomeView.swift:497`).

**The redesign's stage 3b — navigation and motion — is finished, tested and unstaged; stage 3 is
still in the index, and both wait for the owner's `/commit`, stage 3 first** (2026-10-12, the
fifty-first pass). Spec `docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md`; plan
`docs/superpowers/plans/2026-10-11-premium-redesign-stage-3b.md`; both untracked. Four stages
were to follow stage 3 directly. The owner, shown History, said instead that *Today* stood in a
different place on Home and History, that the change of page and the small interactions looked
poor, and that the bar should be iOS's own glass bar with its drag — and, shown the built screens
beside the canvas with seven differences marked **a** to **g**, said "go". That was read as: fix
them all. It was split: **3b**, this stage, is the title, the bar, the motion and the haptics
(letter **f**); **3c**, the look — the glass (**a**), the vessel (**b**), the week card (**c**),
a serving's glyph (**g**) — follows it; **d** and **e** stay as decided on 2026-10-09.

**What stage 3b is.**

- **One header.** `ScreenHeader` and `ScreenMetrics`, a new file: every tab opens with the title
  on one line, a line under it, and an accessory on the title's line. Home's date moved from
  above the title to under it. The title's origin is the same on all three tabs, at the ordinary
  text size and three sizes up; two UI tests hold it.
- **Apple's tab bar on iOS 26 and later**, the app's own below. `RootTabView` chooses between
  `SystemTabs` — a `TabView` of three `Tab`s — and `HandMadeTabs`, the old `ZStack`, by
  `if #available(iOS 26.0, *)`: the codebase's third version check. A press dragged along Apple's
  bar carries the selection. **A screen is kept while its tab is away** under Apple's bar, so
  what the rebuild did by accident is done on purpose: Home ends its *Undo* offer and History
  returns to today in `onDisappear`.
- **A shade under Apple's bar**, `BarShade`: the foot of each screen a quarter darker. Without it
  the selected tab's caption read 3.79–4.46:1 on iOS 26.5. The selected tab is white.
- **A screen arrives.** `Arrival`, a new file: everything under the title is drawn at 0.001 and
  then rises 10 pt and fades in, each section 40 ms after the one above; History's bars grow.
  The flag is set 50 ms after the tab is shown and cleared once a kept screen has gone.
- **One sky.** `AuroraClock` and `AuroraDrift` in `AuroraBackground.swift`: every backdrop's
  lights are placed by one clock, so the backdrop no longer changes at a change of tab.
- **Touches.** Two rungs on `Haptics`, `select` and `remove`: a tick for a change of tab, a day
  picked, a vessel shortcut and a slider's step; a light tap for a serving swiped away. A disc's
  glyph bounces when it is poured; the flame when the streak goes up; *Undo*'s capsule arrives
  from 0.92 of its size.
- **No key added** — eleven, as before. Nothing in `DataManager`, the widget or the watch; no
  target membership changed; no shared file edited. Four new files, eleven edited, all app-only
  or tests.

**Decisions taken on the way, each the owner's to overturn** — the spec's §10, N1 to N15. The
ones nothing the owner has seen showed them: the shade (N8); the selected tab white where the
canvas drew cyan (N10); Home's date under the title (N2); every backdrop on one clock, in a file
the plan did not list (N13); *Undo*'s capsule on `.smooth` and not the spring the spec first
described, because rule `60-design-system` names one spring (N12); the date's floor at 0.45
(N15). And two things left as found: one caption at 4.01:1 on the smallest phone at the largest
text size on iOS 26.5 (N9, #112), and Home's vessel at its floor on that phone at the ordinary
size (N14, #113).

**The rules are not edited.** The wording is written out in the spec's §8, for five rule files —
`50-views`, `60-design-system`, `65-accessibility`, `15-project`, `85-testing`. Until the owner
approves it the code contradicts two rules as they stand: `50-views` forbids `TabView`, and
`60-design-system` lists three haptics (#111). *(The fifty-second pass: two more bullets are
departed from by the letter. Two of the stage's haptics are triggered by a view's own state —
the shown tab, the amount under the finger — where rules `50-views` and `60-design-system` ask
for a counter, and §8 proposes no wording for it; and the arrival branches on Reduce Motion
where rule `65-accessibility` gives an animation that runs once per tap no branch, which §8
covers as a new bullet. #111.)*

**A fresh reviewer read the whole stage's diff** on 2026-10-12; its report is saved as it
arrived, beside the stage's ledger. No critical finding; four important, eight minor, seven
things it declined to judge. What came of it:

- **The title still stood at two heights** at the text sizes between the two that had been
  rendered. The test written for it failed by 4.7 pt, and found a second cause the reviewer had
  not: Home's column offered the title's line less than the title's height. Both fixed.
- **The test that a screen comes back whole could only fail for Home.** It reads the picture of
  all three screens now, on a first showing and a return; seen failing with History's arrival
  taken out.
- **The date's floor**: arithmetic said the widest Russian date would be cut; a test in iOS's own
  font confirmed it, 0.491 against a floor of 0.5.
- **Home on the smallest phone**, which it feared no longer fitted: rendered — whole above the
  bar, the vessel at its floor.
- **Two of the things it declined turned out to be defects, found by rendering them**: the
  backdrop changing at every change of tab, and on iOS 26.5 the screen being left standing empty
  for a quarter of a second. Both fixed, both seen on recordings before and after.
- Minor: the wait in the arrival's task re-checks for cancellation; the shade reaches the
  screen's edges in landscape; a tap on the day already shown no longer ticks; the flame no
  longer bounces when the streak drops; the comments the reviewer listed as made false by the
  stage are corrected, one in a shared file aside. #117 holds that one and two more: one in
  the capture harness, a file the stage did not open — found by the fifty-second pass's
  reader, and more than a comment (#82) — and one the stage wrote itself, a test's DocC that
  rounds its figures. *("the comments the stage had made false are corrected, one in a shared
  file aside (#117)" until that pass.)* Deferred, for the owner: #114.

**The gate, on the final source** — foreground, `-parallel-testing-enabled NO`, 2026-10-12,
02:27 to 03:45, no `shutdown all`; the last source file was written at 02:16.

| | Result |
|---|---|
| Phone unit, stock *iPhone 17*, iOS 27.0 | `✔ Test run with 500 tests in 64 suites passed` |
| Phone UI, *WaterBuddy Gate 27*, iOS 27.0 | `GoalSetupUITests` 32 executed, 1 skipped, 0 failures; the other classes `Executed 18 tests, with 0 failures` |
| Phone UI, *WaterBuddy Gate 26.5*, iOS 26.5 | 32 executed, 1 skipped, 0 failures; 18, 0 failures |
| Phone UI, *WaterBuddy Gate 18.6*, iOS 18.6 | 32 executed, 1 skipped, 0 failures; 18, 0 failures |
| Watch unit, *WaterBuddy Watch 27* | `✔ Test run with 57 tests in 6 suites passed` |
| `WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |
| Warnings, clean build into an empty folder against a clean build of the index | 50 distinct lines in the app's log and 38 in the widget's, the same lines as the baseline: none new, none gone |

- The skipped test is the caption test on iOS 27.0 and 26.5 — it is the app's own bar's — and
  the drag test on iOS 18.6, which is Apple's bar's. Each says so with `XCTSkip`.
- **The UI class ran in chunks by name**, three or four a system, each with
  `-collect-test-diagnostics never` (#110): 32 tests do not fit one foreground call.
- **Two chunks failed on their first run and passed on their second.** On iOS 27.0,
  `testAnUndoOfferDoesNotOutliveTheAppLeavingTheScreen` tripped its own guard — "too slow to
  tell" — with the Mac's load average over 400 from two other projects' test runs; the same
  eleven tests passed at a load of 55. On iOS 26.5, `testADiscAndUndoAnswerOffTheirGlyphs` failed
  once and then passed 23 times; **its cause is not established** (#115).
- The tree also held the build inputs that are not staged and differ from HEAD — Xcode's
  rewrites of three catalogues and the two watch schemes (#50) — as every gate since has.

**Rendered at the review, on simulators:** the smallest phone (375 × 667 pt, iOS 26.5) at the
ordinary size, and at the largest in Russian; Increase Contrast and a change of language under
Apple's bar on iOS 26.5; landscape on iOS 27.0, for the shade's edges; the final code recorded
on iOS 27.0, 26.5 and 18.6. **Not rendered:** Reduce Motion and Reduce Transparency. **Not on a
device:** anything — every haptic, the drag by feel, VoiceOver on Apple's bar (#116).

What follows is the fiftieth pass's account of stage 3, as written.

**The redesign's stage 3 — History — is finished, tested and staged; it waits for the owner's
`/commit`** (2026-10-11, the fiftieth pass). Eleven paths of source, tests and strings in the
index — nine are the stage's, two are known issue #92's fix — plus the plan and the docs this
pass writes. Four stages follow: Settings, the welcome, the widget, the watch. Spec
`docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §6; plan
`docs/superpowers/plans/2026-10-11-premium-redesign-stage-3.md`. The owner ran `/start_task` with
no task named, was shown the stage's outline and five decisions, and answered "go".

**What History is now.** One `List`, and everything on the screen is a row of it, each with the
list's own surfaces cleared; nothing is fixed above it, so the `+` scrolls away with the header.
Top to bottom: the shown day at `.largeTitle` and its total against the goal, straight on the
aurora with Home's two shadows, the `+` on the title's line; the week card, a day that reached
the goal cyan and one that did not white, with *Average*, *Best day* and *Goal met* beneath;
**When you drank**, new — one bar per serving placed by time of day, hour labels at 6, 12 and 18,
and on today a bell at the next reminder; the servings, each a vessel's glyph in a dark well, the
amount, the vessel's name when the amount is one of the current three, and the time. The sheet
gained three vessel shortcuts under its slider. No key added — eleven, as before; nothing in the
widget or on the watch; no target membership changed.

**What the model gained** (`DataManager`, compiled into four bundles): `DaySummary.reached(_:)`
and `daysMet(in:goal:)`; `dayFraction(of:)` and `hours(_:onDayOf:)`, each a `nonisolated static`
over a calendar with an instance wrapper that passes the model's own. `streak`,
`streakFillsWindow` and `closedDays` are respelt through `reached(_:)`; their behaviour is
unchanged and their tests untouched. Nothing is stored and nothing leaves the app.

**Decisions taken on the way, each the owner's to overturn.** The five the "go" took as
recommended: the header scrolls away with the list; #62's test is rewritten here; the sheet's
selected shortcut uses `LiquidGlass.Selection`, not white; #93 is left out; contrast is recorded
by both yardsticks of #95, clean ground as the floor. Made while building:

- **The list stops one point short of the top safe area** (`.padding(.top, 1)`). With nothing
  fixed above it, its rows were drawn on up under the status bar — the clock across a row's
  amount. A defect fix, and a visual one: panes are cut by a hard line there.
- **Each strip bar carries a 1 pt dark hairline.** Four servings inside fifteen minutes drew as
  one blob.
- **A row's glyph sits in a dark well** (`.black.opacity(0.4)`), not the canvas's cyan wash. On
  the hand-made pane a cyan glyph on a cyan wash read 2.00:1. The plan's remedy was that such a
  glyph "loses the disc's tint first, then goes white".
- **Layouts chosen by fit, where a line was cut at large text:** the week card's figures (three
  layouts), the sheet's shortcuts (two, the type capped at 30 pt), a serving row (two). The
  sheet's slider, shortcuts and wheel sit 8 pt apart, not 24: at 24, *Save* and *Cancel* were
  half off a 375 × 667 pt screen at the ordinary size.
- **The `+` shares the title's line and the total has the row's whole width**; the week's and
  the strip's titles may take two lines. The plan printed neither.
- **A past day's heading is two lines at an accessibility text size** — the weekday, then the
  date — chosen by the text size (`dynamicTypeSize.isAccessibilitySize`), not by `ViewThatFits`.
  It is the app's first branch on text size. The title may shrink to 0.5 where the header's
  other lines stop at 0.6.
- **Two marks ship under their floor**, each recorded with its figures below: the total under
  the heading, by the clean-ground yardstick (#95); the strip's cyan bar on the hand-made pane,
  at the plot's left end (#85).
- **Known issue #92 is fixed here**, as its own change of two test files, staged beside the
  stage.
- **The UI target ran as two invocations a system** (#110).

**The gate, in the working tree** — foreground, `-parallel-testing-enabled NO`, 2026-10-11, no
`shutdown all`. The eleven staged files were as staged. **The tree also held the five build
inputs that are not staged and differ from HEAD** (Xcode's rewrites of three catalogues and the
two watch schemes, #50), as stage 2's gate did. Another session's simulators were seen booted
at times — an *iPhone 18 Pro* when the stage began, an *iPhone 16 Pro* during the UI gate — and
left alone.

| Run | Where | Result |
|---|---|---|
| `-only-testing:WaterBuddyTests` | iOS 27.0, *iPhone 17* | `✔ Test run with 479 tests in 60 suites passed`, **five whole runs of five**, the first from a cold simulator |
| `-only-testing:WaterBuddyUITests`, the harness skipped, as two invocations | iOS 27.0, *WaterBuddy Gate 27* | `Executed 25 tests, with 0 failures` and `Executed 18 tests, with 0 failures` — **43** |
| the same | iOS 26.5, *WaterBuddy Gate 26.5* | 25 and 18, 0 failures — **43** |
| the same | iOS 18.6, *WaterBuddy Gate 18.6* | 25 and 18, 0 failures — **43** |
| `-only-testing:WaterBuddyWatchTests` | watchOS 27.0, *WaterBuddy Watch 27* | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | iOS 27.0, *WaterBuddy Gate 27* | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | watchOS 27.0, *WaterBuddy Watch 27* | `** BUILD SUCCEEDED **` |

- **Three whole-target unit runs came before those five: failed, passed, failed** — both
  failures #92's test, at `folded == 0`. See #92, retired in this pass.
- **The watch run and the two widget builds were made before the final review's fixes**, at
  17:47–17:49. The seven shared files were the same blobs after the fixes, which touched
  `HistoryView.swift`, three test files and `UnreadableStore.swift` — nothing a watch or widget
  target compiles. The pinned *Apple Watch Series 12 (46mm)* still fails to boot (#77).
- **Warnings: none new.** Clean builds of a `git archive` of HEAD and of a `git checkout-index`
  of the index, four schemes each (the app's a `build-for-testing`), into one build folder that
  only the app's build starts empty: **38 / 19 / 2 / 19** distinct lines after the path and the
  position are cut — the same lines and the same counts in both. The same unit as stage 2's row.

**Measured** — the worst frame of a minute of the aurora at rest and a minute scrolled, a
capture every three seconds, each system; 32 pairs a system. The sweeps ran before the final
review's fixes, which by the code change nothing they drew — today's screen at the ordinary
text size; no capture was compared after them. **On iOS 18.6 the final sweep's second minute
did not scroll** (the list had another page and did not move under the probe's swipe; why is
not shown), so that system's scrolled figures are an earlier sweep's of the same day. The
whole table, and how each rectangle was checked, is in `docs/DESIGN.md`, *History, measured*.

- **Under its floor on all three systems: the total under the heading**, white on the aurora at
  `.headline` — 4.45 / 4.44 / 4.34 on clean ground against 4.5, and 4.65 / 4.68 / 4.62 beside its
  glyphs (iOS 26.5 / 27.0 / 18.6). Nothing else is under on Apple's glass.
- **Nine more on iOS 18.6, all on the hand-made pane** (#85): weekday letters 3.41–3.93, the
  disclosure 4.15, the goal line 2.12–2.98, the week's cyan bar 2.78 beside the pane and 1.98
  over an empty track — each drawn as HEAD draws it — and the strip's cyan bar, new: **2.73 at
  the plot's left end**, the small hours, where the sweep's rectangle lay and that pane's
  highlight lies, and 3.80 and 3.69 at midday and in the evening, where the day's servings
  stood — measured afterwards, when a reader of the docs pointed out where the first lay.
- Tight and not under: the goal line over an empty day's track on iOS 27.0, 3.05 against 3.
- One capture a system, not a sweep: the sheet's shortcuts, and the empty state — whose second
  line reads 3.80 on iOS 18.6 against 4.5, on the same pane; the empty state is HEAD's.

**Rendered and driven, with a throwaway probe that is deleted again.**

- Every control answered off its glyph on iOS 26.5, 27.0 and 18.6 — a day off its bar, a row
  on its bare pane, a shortcut low and to one side, swipe-delete — **in walks made between
  15:30 and 16:03, on a build older than the final one and older than the settings passes**:
  before the shortcuts' and the row's second layouts, the sheet's spacing, the header's change
  and the review's fixes. On the final source the gate's UI tests tap a row on its bare glass
  and a shortcut off its glyph on all three systems, and the delete probes swiped a row away;
  a day tapped off its bar was not repeated.
- **Settings, iOS 27.0 only, on a build older than the final one** — before the large-text
  fixes, the header's change and the review's fixes. Increase Contrast read back on, then off;
  the walk passed under it; no figure was measured under it. Reduce Transparency flipped on and
  off under a running History, a day, a row and a shortcut operated each way. Reduce Motion on:
  the backdrop identical twelve seconds apart; only a day button was pressed under it.
- **Text sizes**, on a 402 × 874 pt phone: XXXL and Accessibility M, L, XL, XXL and XXXL in
  English and Russian; Uzbek at the ordinary size, and at Accessibility XXXL for the header.
  On a 375 × 667 pt phone: the ordinary size, XXXL in Russian, Accessibility XXXL.
- **Found by render and fixed:** five lines cut short at large text — the week's figures, the
  shortcuts' figures, a row's amount, the header's total, the week's title — and the sheet's
  two buttons half off the small phone at the ordinary size. **A sixth cut line, a past day's
  heading, was in a capture and not noticed** until the reviewer's estimate pointed at it.
- **Deleting down to nothing**, two cases. *A day's only serving*, added through the sheet and
  swiped away, on iOS 27.0 and 18.6: the strip and the row went, the empty state came back,
  the week card stayed, and the day's button and the heading read that day with 0. *The week's
  only water*, deleted while a past day was shown, on iOS 26.5 (the small phone) and 18.6: the
  card went too, and the heading read *Today* with 0. The `+` stood and the app was running
  each time.
- The strip's bell was drawn with a stand-in time on iOS 27.0 and 26.5; reminders could not be
  switched on on a simulator (#94).

**Not done:** anything on a device; VoiceOver itself (the tree was read, nothing was heard);
iOS 17 (no runtime); the strip's reminder mark from a real reminder; the three settings on the
final source, or on iOS 26.5 or 18.6; any contrast figure at a text size other than the
ordinary one or under Increase Contrast; deleting the week's last serving on iOS 27.0; the
longest Russian weekday together with a two-digit date in the heading, which is arithmetic —
this week's Monday is the 5th; the two-line heading looked at on iOS 18.6, where the gate's
test of it passed and no capture was read; a native reader for the Uzbek.

**The final review** (a fresh reviewer, read-only, on the staged diff; its report is saved
beside the stage's ledger as it arrived) found nothing critical, three things it called
important and thirteen minor. What came of it:

- **Fixed, test first.** Yesterday's test saw neither that a serving is listed nor that it is
  one control; it asserts both now, and was seen failing with a row drawn as both its layouts
  and with a past day's list left empty. A unit test that compared two literals in its own
  file is replaced by one that reads the built string table.
- **Fixed, though graded minor on an estimate: a past day's heading was cut at the largest
  text sizes** — *Saturday, 10 O…*, *Понедельник…*. **It was already in one of the stage's own
  captures**: the walk at the largest size had tapped yesterday at 16:29, an hour and more
  before the review, and kept the screenshot and a frame list that gave the heading 43 points
  where *Today* has 72. That line of the capture was not read (`tasks/lessons.md`).
- **Confirmed, and not this stage's to fix:** `nextDayBoundary` and a repeated midnight (#107).
- Comments this stage had made false were corrected; the rest of what it listed is #109.

**Rule wording, written and unstaged, for the owner:** `50-views` (History is one list and
stops a point short of the top; its statics and the model's two calendar answers) and
`65-accessibility` (the week card's summary and its two bar colours; History's heading, and its
two lines at large text; the strip; a row's name and the sheet's shortcuts).

<details>
<summary>The redesign's stage 2 — Home — as the forty-sixth to forty-ninth passes recorded it; committed since in <code>1ced514</code>, <code>e7406a5</code>, <code>6b5f319</code> and <code>e16221e</code></summary>

**The redesign's stage 2 — Home — is finished, tested and staged; it waits for the owner's
`/commit`** (2026-10-11, the forty-sixth pass). *(Committed the same day: `1ced514` the source,
tests and strings, `e7406a5` the plan, `6b5f319` the docs, `e16221e` the rule wording and
`CLAUDE.md`. Every "staged" below reads "committed".)* Thirteen paths in the index, plus the docs this pass
writes. Five stages follow — History, Settings, the welcome, the widget, the watch. Spec
`docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §5; plan
`docs/superpowers/plans/2026-10-10-premium-redesign-stage-2.md`, with a note at its end on where the
build left it.

**What Home is now.** Top to bottom: the date and *Today* as one heading, a streak chip (a flame
and a count, absent at zero) on the title's line; the vessel; `1 300 ml to go` or *Goal reached*;
one quiet line — *Next reminder 13:00* and *Last drink 11:19*, whichever apply — which for eight
seconds after a pour from this screen is an *Undo* capsule instead; the quick-add row, the Glass on
the screen's one primary surface between Cup and Bottle on glass. Volumes are grouped by the app's
locale (`Bundle.figure`, `%n$@` keys); spoken strings keep their `%d` keys.

**What the model gained** (`DataManager`, compiled into four bundles; no key added):
`addLog(amount:at:)` returns the row's id; `undoLog(id:)` deletes that row if it is one of today's,
read fresh; `remaining`, `hasReachedGoal`, `lastDrink` and `nextReminder` are derived on read;
`streak` is published behind `role.drawsHistory`, counted over windows of 30, 120, 480 and 1,920
days, judged against today's goal, and never leaves the app; `dayDidTurn()` — which both day-change
observers now call — republishes today's rows and the history when the day really turned, so a
screen left open over midnight no longer shows yesterday's servings under a zeroed total (the defect
spec §2 named).

**What the glass gained.** `LiquidGlassModifier.routed` branches on a pane's base only; on iOS 26
and later a `.material` pane always carries `glassEffect`, with `Glass.identity` when the pane is
not Apple's, so flipping Reduce Transparency rebuilds nothing inside a pane (#91a, retired).
`.glassGroup()` wraps sibling panes in Apple's `GlassEffectContainer`. **The widget draws what it
drew:** its four pane recipes rendered byte-identical from `b8a1386` and from the change, with
Reduce Transparency off and on; and both sizes, placed on a Home Screen from each build, differ in
no pixel of the widget.

**Decisions taken on the way, each the owner's to overturn** — the fourth's two outcomes are the
spec's, which the owner had already decided on 2026-10-09 (the capsule's `Added 250 ml` in §5.1;
the flame and a number in §5.2, §12 and D3), and the reason it gives for the capsule's wording is
the plan's; the rest were made while building, and the plan's ledger has those, most with what
each costs if wrong — the two large-text rulings at the foot of the list state no cost. *(One the ledger has and this list did not,
until the forty-seventh pass: Home's heading is the title text itself, with the date as its value,
and no wrapper element — so VoiceOver's focus ring covers the title's line and not the date drawn
above it. Three more, added in the forty-eighth: the *Undo* pane's density and the two header and
quiet-line rulings, at the foot of the list.)*

- **Text straight on the aurora carries two shadows** — the widget readout's recipe, as a private
  helper, `legibleOnBackdrop()` — and three whites the canvas dimmed are full white. On clean
  ground the Bottle's captions read 4.12 and 4.20:1 over the magenta light at its brightest.
  **Contrast for that text is measured beside its glyphs, where the shadow is, not on clean ground
  12 points out** — a change of yardstick, ruled by the building session when its first table, on
  clean ground, failed; #95 puts both sets of figures side by side.
- **The vessel's floor is 200 points, fixed — the plan's own value, restored.** A floor that rose
  with the text size was built first, on one phone at one size, and reversed on measurement: on a
  402-point phone it put the vessels' names under the tab bar at the second accessibility size, the
  discs' feet at the bar at the third, and the discs themselves under it from the fourth. The cost
  is #97.
- **An *Undo* offer also ends when the app goes to the background**, which the spec's list does not
  name (#96).
- **The *Undo* capsule reads *Added 250 ml*,** not the canvas's *Glass added, 250 ml*: Russian would
  need the vessel's gender in the verb. **The streak chip has no noun** — "12 days" needs plural
  forms this app's strings cannot produce (#40).
- **Home's column is a `Layout`,** `HomeColumn`. The plan's `layoutPriority` design cannot shrink
  anything inside a scroll view, and a stack squeezed the status line to 71 % on a shorter phone
  (18.7 points where 26.3 is its style; the ledger's "72 %" is a slip, and the title's 72 % is a
  different measurement).
- **The *Undo* pane is `.opaque`** where the discs are `.frosted`: it is the one pane on Home that
  carries a line of text, and on the hand-made stack that line read 4.48 at `.frosted` in one
  capture of three. One density on one pane.
- **The header and the quiet line at large text:** the date takes the row's whole width and the
  chip shares the title's line; the quiet line's stacked form may shrink to 0.6 and wrap to two
  lines.

**The gate, in the working tree** — foreground, `-parallel-testing-enabled NO`, 2026-10-11. The
thirteen staged source, test and string files were as staged, and have not been written since.
**The tree also held five build inputs that are not staged and differ from `b8a1386`**: Xcode's
rewrites of `WaterBuddy/AppShortcuts.xcstrings` and the two watch catalogues, and the two watch
schemes (known issue #50) — last written between 2026-10-07 and 2026-10-09, so earlier gates ran
over them too. A build of the index alone would compile the committed copies of those five. *(Headed "The gate, on the staged source" until the
forty-eighth pass.)*

| Run | Where | Result |
|---|---|---|
| `-only-testing:WaterBuddyTests` | iOS 27.0, *iPhone 17* | `✔ Test run with 444 tests in 56 suites passed` |
| `-only-testing:WaterBuddyUITests`, the screenshot harness skipped | iOS 27.0, a clean simulator | `Executed 38 tests, with 0 failures` |
| the same | iOS 26.5, a clean simulator | `Executed 38 tests, with 0 failures` |
| the same | iOS 18.6, a clean simulator | `Executed 38 tests, with 0 failures` |
| `-scheme WaterBuddyWatch -only-testing:WaterBuddyWatchTests` | watchOS 27.0, *WaterBuddy Watch 27* | `✔ Test run with 57 tests in 6 suites passed` — the pinned *Apple Watch Series 12 (46mm)* still has no data on disk (#77) and was tried first |
| `build -scheme WaterBuddyWidgetExtension` | iOS 27.0 | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | watchOS 27.0 | `** BUILD SUCCEEDED **` |
| warnings, builds of `b8a1386` (2026-10-10, 22:37) and of the index (2026-10-11, 12:15), four schemes each | — | app 38 = 38, widget 19 = 19, watch 2 = 2, watch widget 19 = 19 — **the lines the comparison's filter printed**: for a warning in a source file, the file and the message with line and column stripped; **for a warning inside a macro expansion, the line as it stands, position kept**. The four lists identical, counts included. **The app's 38 is `build-for-testing`**, which compiles the two test targets as well as the app and the three products it embeds: 19 of the 38 are in shipping sources, 2 in test files, and 17 are macro-expansion lines from the tests — which would be 10 with their positions stripped too, so by one unit throughout the app's figure is 31. *(The forty-eighth pass called all 38 "distinct warnings by file and message".)* **Only the app's build started in an empty DerivedData folder**; the other three followed in the same folder on each side, and recompiled. Counted `CLAUDE.md`'s way — whole lines, with line and column — the shipping sources give **31 unique lines and 44 in all** in the app's, the widget's and the watch widget's logs alike, which are `CLAUDE.md`'s two figures (#29). *(Until the forty-eighth pass this row said "clean builds … four schemes" and "38 unique lines", which read as four empty folders and as `CLAUDE.md`'s unit.)* |

**One unit run of twenty-two failed, on a test this stage does not touch** (#92):
`WristIngestTests.aFailedExistingLogsReadDeclinesTheWholeBatch…`, in the cold run straight after a
simulator boot. `b8a1386`'s own build passed ten warm runs of ten, and so did this change. The
same test had failed once the evening before as well, while two of this stage's tests still shared
its technique.

**Rendered and read, with throwaway probes that are deleted again.** Home on Apple's glass on iOS
27.0 and 26.5 and on the hand-made glass on iOS 18.6, each on a new simulator, on the final source:
empty, with reminders on, **every three seconds for a minute**, to the goal, and with a streak.
Figures in `docs/DESIGN.md`, *Home, measured*: no pair under its floor, beside the glyphs.
**Every accessibility text size** on a 402 × 874 pt phone in English, and the default and four of
the five in Russian; the default and three accessibility sizes in English and in Russian, and one
in Uzbek, on a 375 × 667 pt phone: no text cut, broken or outside its capsule. The 375-point
renders are of the final drawing; the 402-point ones are two small changes short of it — the
*Undo* word's line limit (three lines of code) and the date's smaller scale floor (one), both made for the narrower phone, and
neither applies at 402 points, where the word and the date already fitted. *(`HomeView.swift` was
written once more after both sets, at 11:15–11:16: four edits, all to comments — the session's own
record of its edits shows them — so "final source" in the ledger's L84 and L116 is true of
everything drawn. The largest phone the plan's Task 8 Step 9 names was never rendered at a large
size; see *Not done*.)* **Operated on all three systems, on the final source:** each disc tapped off its glyph,
*Undo* tapped off its label, a drag begun on the vessel.

**Three settings were tried earlier, on source that changed afterwards — none on the final one.**
Increase Contrast, iOS 27.0, and Reduce Transparency flipped on and off under a running Home on iOS
26.5: both on the source as it stood before the review's fix pass. Reduce Transparency on iOS 27.0:
switched on while the title regression was live, switched off after it was fixed. Reduce Motion,
iOS 27.0: after the title fix, before the fix pass. **What each showed differs.** Under Reduce
Transparency, on both systems, panes went opaque and came back, and after each flip Cup, Glass and
Bottle poured from taps off their glyphs and *Undo* took the last back. Under Reduce Motion Home
drew, a Glass was poured after each flip and *Undo* appeared; it was not pressed, and nothing goes
opaque under that setting. Increase Contrast was the contrast sweep, on iOS 27.0 alone: its probe
taps Cup, Bottle and Glass at their centres, photographs for a minute while the offer stands and
ends, and taps the Bottle once more — so the discs answered and an offer expired, and no control
was tapped off its glyph and *Undo* was not pressed. *(Read "In each, panes went opaque and came
back and every control answered" until the forty-eighth pass, which then wrote "figures, no
control operated" of Increase Contrast; the probe's own source says otherwise.)* `LiquidGlassModifier.swift` has not changed since before any of them, so
what they show of the routing stands; **Home's own views did change** — *Undo*'s three forms and
the chip's padding have not been seen under Reduce Transparency, and the wave's freeze under Reduce
Motion was not measured (`WaterSurface` is untouched).

**Not done:** anything on a device; VoiceOver itself (the tree was read, nothing was heard); iOS
17; Home rendered and read at the accessibility sizes on iOS 18.6 (the gate's one test at the
largest size passes there); the widget in dark or tinted; the watch app on a simulator (it builds,
and its tests pass). **And, not listed until the forty-eighth pass:** the largest phone — the
plan's Task 8 Step 9 asks for *WB2 Large 27* (an iPhone 17 Pro Max) at the default size, at the
largest text size and in Russian; it was walked once, all five probe tests at the default size in
English (01:09–01:14, one failure, the reminders switch of #94), that one test was run again a
minute later, and a second new simulator of the same size, *WB2 Cold 27*, ran two probe tests at
01:16 for the same finding — all at the default size, in English, before the title fix; that
size of phone was never rendered at a large text size, in Russian, or on the final source;
Increase Contrast on iOS 26.5 or 18.6; any of the three settings on
iOS 18.6; no size below the default anywhere.

**The final review** (a fresh reviewer, read-only, on the staged diff) found nothing critical and
four things that mattered. *No retained test taps a control off its centre* — one was added, and
what it can see was settled by mutation: with the pane's content shape removed on iOS 26.5 it still
passes, because a finger's tolerance reaches the glyph from anywhere on a 68-point disc; it fails
when a disc answers only at its foot. *The Undo capsule at large text* — rendered: *Added 25… |
Undo* at the largest size; it now draws the first of three forms that fits unshrunk. *The scaled
vessel floor* — rendered, and reversed. *Under VoiceOver the offer never ends* — it now ends when
the app leaves the screen; the rest is #96. Two tests it called weak were made to bite: the
older-timer test was seen failing under a deliberate mutation, and the failed-read test, under the
mutation the reviewer described, brought the runner down rather than failing an assertion (#93).
**On the yardstick the reviewer wrote: "sound, but the owner's to accept. … The yardstick changed,
though" — and asked that the change be put in front of the owner and #81 not be closed on it.** **The fix pass had two defects of its own**, caught from the
captures before anything was recorded: `ViewThatFits`, choosing among labels inside a button, was
sized as one form and drew another; and a one-line form without its old scale factor drew *Undo* as
*U…* (`tasks/lessons.md`, 2026-10-11).

**Rule wording, written and unstaged, for the owner:** `20-state` (the mutation surface, the id
`addLog` returns, `streak`, the derived figures), `30-rollover` (`dayDidTurn()`), `50-views`
(grouped figures, `HomeColumn`, the ranked Glass, ids not rows, `ViewThatFits`), `60-design-system`
(`.glassGroup()`, a pane's content never moved by a setting), `65-accessibility` (Home's elements,
Undo's timing, the vessel's floor, a line never cut short) and one sentence in `CLAUDE.md`. **No
rule was written for the two-shadow text or its yardstick** — that is #95, and the owner's first.
*(Committed in `e16221e`, 2026-10-11.)*

</details>

<details>
<summary>Stage 1, as the forty-fourth pass recorded it — committed since, in <code>c9ef45d</code></summary>

**The redesign's stage 1 was finished, tested and staged, and waited for the owner's `/commit`**
(2026-10-10, the forty-fourth pass). **It was committed that night:** `c9ef45d` *feat(design): draw
Apple's glass on iOS 26 and later*, with `97bda33`, `12ddfc4`, `96ca467`, `dba4646`, `e681154` and
`b8a1386` after it — the spec and plan, the capture tools, the 1.1 screenshots, the doc sync, and
the rule wording this block calls unstaged. What follows is that pass's text, unchanged. Six more stages follow — Home, History, Settings, the welcome, the
widget, the watch — and until they are built **the app does not look like the canvas**: stage 1 is
the glass, the two white buttons and the tab bar's lozenge, nothing else. The owner ruled on
2026-10-09 that the stages are built straight through, each plan written and executed without a
separate approval, stopping at each stage's `/commit` or at a real design decision.

**What the owner settled, and what came of it:**

- **The glass.** Apple's regular glass is darkened with Apple's own `Glass.tint`, through
  `LiquidGlass.systemTintOpacity(for:)`; the clear variant, the vessel, takes none. The value was
  climbed against measured contrast, each rung rendered: `0.40` (the owner's first choice) failed 17
  of 71 pairs — the goal line and every dimmed text where the pane lies over the magenta lobe, which
  the first table had not sampled; `0.44` failed 9; `0.48` failed none **at rest**, on iOS 27.0 or
  26.5, and was adopted — until the final review pointed out that the captures were taken three
  seconds after each screen appeared, and the aurora moves. Followed through a minute of its swing,
  `0.48` put the goal line under 3:1 in half the frames (2.85) and the dimmest text exactly on
  4.5:1. **`0.52`, the last rung of the owner's ladder, fails none through the swing:** white 0.70
  over the magenta lobe 4.86:1, and three and a half minutes on History found nothing worse.
  `docs/DESIGN.md`, *Apple's glass, measured*.
- **The goal line.** White 0.45 → 0.55. No tint in the ladder carried it at 0.45 (3.01 at `0.52`),
  and a one-point rule should not set the darkness of every pane. Through the swing it reads 3.74.
- **The labels.** The goal slider's two range labels go from white 0.6 to 0.75, in Settings and on
  the first-run screen.
- **The simulators.** The pinned ones never came back (#77). The owner ruled the tests onto iOS
  27.0 and onto simulators made for the purpose; rule `85-testing`'s pin is edited to match,
  **unstaged, for them to read**.

**A real bug, found by running on iOS 26.5, and fixed.** A serving row in History took a tap on its
text and ignored one on the bare glass between, which is most of the row. On iOS 26.5 the pane
`glassEffect` draws inside a `List` is not part of the button's hit region; on iOS 27.0 it is, so
every earlier run passed. `systemPane` now ends in `.contentShape(shape)`, and
`GoalSetupUITests.testAServingRowOpensItsSheetWhereverItIsTapped` was seen failing on 26.5 before the
fix and passing after.

**The gate, on the final source** — foreground, `-parallel-testing-enabled NO`:

| Run | Where | Result |
|---|---|---|
| `-only-testing:WaterBuddyTests` | iOS 27.0, *iPhone 17* | `✔ Test run with 387 tests in 48 suites passed` |
| `-only-testing:WaterBuddyUITests`, the screenshot harness skipped | iOS 27.0, a clean simulator | `Executed 27 tests, with 0 failures` |
| the same | iOS 26.5, a clean simulator | `Executed 27 tests, with 0 failures` |
| the same | iOS 18.6, a clean simulator | `Executed 27 tests, with 0 failures` — the first green UI run below iOS 26 |
| the same, on three simulators that held a night of probe servings (iOS 27.0's *iPhone 17*, and the 26.5 and 18.6 probe devices) | — | `Executed 27 tests, with 1 failure` each time: `testAServingAddedToYesterdayShowsUnderYesterday`, which `8a44e8f` fails identically on the first (#62) |
| `-scheme WaterBuddyWatch -only-testing:WaterBuddyWatchTests` | watchOS 27.0, a simulator made for it | `✔ Test run with 57 tests in 6 suites passed` — the first watch run since 2026-10-08 |
| `build -scheme WaterBuddyWidgetExtension` | iOS 27.0 | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | watchOS 27.0 | `** BUILD SUCCEEDED **` |
| warnings, clean builds of `8a44e8f` and of the change, four schemes | — | app 38 = 38 unique lines, widget 19 = 19, watch 2 = 2, watch widget 19 = 19; none in a changed file. *(Stage 2's ledger calls these "the same four figures", so most likely the same filter and the same shared folders as stage 2's row above, whose unit and conditions are spelt out there; stage 1's logs were not kept, so that is not shown.)* |

**Rendered and read, with a throwaway probe that is deleted again:** every screen on Apple's glass on
iOS 27.0 and iOS 26.5, and on the hand-made glass on iOS 18.6 — **the first time this product has run
below iOS 26**; the first-run screen on all three; Increase Contrast and Reduce Transparency on iOS
27.0; the sheet and the first-run screen at `AccessibilityXXXL`; the watch app on watchOS 27.0, which
draws what it drew. **Followed through the aurora's swing** on iOS 27.0: every screen shot every three
seconds for a minute, and History for three and a half. **Operated, on iOS 26.5, 27.0 and 18.6:**
the three kinds of slider, the switch (it raises the system's permission alert), *Open iOS Settings*
— a pane inside a pane — tapped off its label, the language rows, the sheet's wheels, swipe-to-delete,
and a scroll begun on a card and on a row's bare glass. All of them answer. **Not done:** anything on
a device; iOS 17; the pinned destinations by name; iOS 26.5 through the swing; the widget on a Home
Screen (its panes take the hand-made path, which is unchanged).

**The final review** (a fresh reviewer, read-only, on the staged diff) found nothing critical and four
things that mattered, all acted on: the tint had been judged on the resting frame (it moved to
`0.52`, and the goal line to 0.55); the row test cannot fail on iOS 27.0, the only system the gate
names (#87); controls inside panes had not been operated (they have been now); and two new sentences
in rule `60-design-system` had not been shown to the owner — they are **unstaged**, with rule
`85-testing`'s pin, for the owner to read. Its smaller findings are known issue #91.

**Found, and not this change's to fix** (known issues #85 and #86): the hand-made pane reads lighter
than this project's design records, on iOS 18.6 and in the shipped 1.1 on iOS 27.0.

**Screenshots, a separate change, unstaged.** The owner asked for new store screenshots and for the
old ones to go. Four iPhone captures of **1.1 as committed** are in `Screenshots/en-US/iPhone-6.9/`;
the owner then said the app "is not as like as canvas" — it is not, the redesign is one stage in —
and ruled that screenshots are retaken once it is. The old watch captures are kept until then (#88).

</details>

The forty-third pass's account, written while stage 1 was paused, retained:

**A premium redesign is under way, and its first stage is half built, staged and paused**
(2026-10-09, the forty-third pass). The owner put it ahead of StoreKit: "improve the UI/UX part and
make it premium before the add StoreKit".

- **The design.** Three Home directions were drawn on a canvas,
  <https://claude.ai/artifact/UYGcabBfVjduqkzvqtZ5bt>; the owner chose *Aurora, refined* with round
  quick-add buttons, the Glass larger and white, each with its amount and name beneath, and **Apple's
  own Liquid Glass**. The full set — four welcome steps, Home, Home with Undo, History, the serving
  sheet, Settings, the two widgets, the watch — was confirmed ("ok").
- **The spec**, `docs/superpowers/specs/2026-10-09-premium-redesign-design.md`, approved with its
  seven decisions as recommended ("ok, approve all"): the iOS floor stays 17.0 and iPhones below iOS 26
  keep the hand-made glass; a streak, a four-step welcome, History insights and Undo on Home are new
  and free; permission may be asked from the welcome's last step (rule wording in spec §10, applied in
  stage 5); History keeps one row per serving; the watch's vessel shrinks and stops being a button. It
  is delivered in **seven stages**, each with its own plan, gate and `/commit`: foundation, Home,
  History, Settings, welcome, widget, watch.
- **Stage 1's plan**, `docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md`, approved ("ok,
  go"). Its ledger is `.superpowers/sdd/2026-10-09-premium-redesign-stage-1/progress.md` (git-ignored).

**What stage 1 has built — staged, not committed, not gated:**

| Task | What | Proof so far |
|---|---|---|
| 1 | `LiquidGlass.rendering(base:reduceTransparency:systemGlassAvailable:)`, `systemGlassAvailable`, `systemVariant(density:interactive:)` | `LiquidGlassRoutingTests`, 7 tests, seen failing first |
| 2 | `LiquidGlassModifier` draws Apple's `glassEffect` for a `.material` base on iOS 26 and later, behind `#if os(iOS)` and `#available`; the hand-made stack otherwise; the opaque pane first, under Reduce Transparency. The stale "cannot be called here" comments corrected | the three glass suites; the widget, watch and watch-widget builds |
| 3 | `LiquidGlass.Primary` and `primarySurface(in:ring:)`; *Get Started* and the sheet's *Save* on it | `PrimarySurfaceTests`, 1 test, seen failing first |
| 4 | `LiquidGlass.Selection`; the tab bar's lozenge; History's shown day reads the same tokens | `AppTabTests`; no unit test of its own |
| 6 | Rule wording: `60-design-system` (the three panes, the primary surface, selection, interaction) and `15-project` (the second version check) | — |

**Not done:** Task 5 (render both glass paths and measure, on iOS 26.5 and 18.6), Task 7 (the gate and
the warning comparison) and Task 8 (the checkpoint, and stop). **Stage 1 is not finished, and nothing in
it has run on the pinned destination.**

**Why it is paused — two things only the owner can settle:**

1. **The simulators.** iOS 26.5's iPhone 17 and iOS 18.6's iPhone 16 still have no data on disk (#77).
   Two `xcrun simctl erase` lines were asked for twice; `simctl erase` is on the deny list.
2. **Apple's glass is too light for this app's text (#80).** A throwaway probe on iOS 27.0 walked
   every screen. Every tap on an interactive glass control landed — the three vessels, a serving row,
   *Cancel*, `+`, *Save*. But the panes read about sRGB `(0.07, 0.50, 0.88)` where the hand-made pane
   read `(0.21, 0.30, 0.44)`, and most dimmed text is under the 4.5:1 floor: the tab bar's inactive
   caption **2.47:1**, the week card's weekday letters **2.90:1**, Settings' vessels note **2.70:1**.
   The plan's one authorised fix, a black scrim capped at 0.28, cannot close it; the plan says stop.
   Two alternatives were measured and not adopted — a black layer at 0.40, and Apple's own
   `Glass.regular.tint(.black.opacity(0.4))` — and they read the same: everything passes except
   Settings' range labels at white 0.6, **3.8:1**. `docs/DESIGN.md`, *Apple's glass, measured*, has the
   table.

**Three items moved between stages while planning**, recorded in the spec's §14: Apple's glass on the
watch goes to stage 7, where it can be rendered; the glass container and the grouped-figure helper go
to stage 2, with their first users.

**No gate has run on any of this.** What ran, all on iOS 27.0's iPhone 17 (`41FBB1D3`), foreground,
`-parallel-testing-enabled NO`:

| Run | Result |
|---|---|
| `-only-testing:WaterBuddyTests/LiquidGlassRoutingTests` | `✔ Test run with 7 tests in 1 suite passed` |
| the three glass suites together, after Task 2 | `✔ Test run with 16 tests in 3 suites passed` |
| `-only-testing:WaterBuddyTests/PrimarySurfaceTests`, before and after the two call sites changed | `✔ Test run with 1 test in 1 suite passed` |
| `-only-testing:WaterBuddyTests/AppTabTests`, after Task 4 | `✔ Test run with 6 tests in 1 suite passed` |
| `build -scheme WaterBuddyWidgetExtension` (iOS 27.0); `WaterBuddyWatch` and `WaterBuddyWatchWidget` (generic watchOS Simulator), after Task 2 and again after Task 3 | each exit 0 |
| the throwaway UI probe, as built | `Executed 2 tests, with 0 failures` |
| **the whole unit suite, the UI suite, the watch tests, the warning comparison** | **not run** |

The four builds after Task 4 were not repeated for the other three targets: the app scheme built, and
the watch and widget targets last compiled `LiquidGlassModifier.swift` before `LiquidGlass.Selection`
was added. Task 7 covers it.

The forty-second pass's account, from the morning of the same day, retained:

**1.1 is with App Review, and the Siri phrase works — both on the owner's word** (2026-10-09, the
forty-second pass). The owner reports that Siri "is ok and working" and that the submission is in App
Store Connect's review. Nothing here can see App Store Connect; what this Mac does hold is Xcode's
Archives folder, and each archive's own `Info.plist`:

| Archived | Version (build) | Widget and watch app | Upload |
|---|---|---|---|
| 2026-10-08 23:10 | 1.0 (1) | build 1 | refused: 1.0 is the approved version |
| 2026-10-08 23:31 | 1.1 (1) | build 1 | recorded as uploaded |
| 2026-10-09 08:20 | 1.1 (2) | build **1** — the app alone was at 2 | recorded as uploaded |
| 2026-10-09 08:52 | 1.1 (3) | build 3 | recorded as uploaded |

- **Which build is in review is not known from here.** The latest upload is 1.1 (3).
- **The Siri failure (#78) was seen on 1.1 (1) or 1.1 (2):** it was reported before build 3 existed. On
  which of the two, the owner has not said; nor on which build it now works.
- **No source differs between those three archives.** The app's sources last changed at 23:19 on the
  8th, when the guard for #73 went in. Between (2) and (3) only the build numbers moved, and (3) is the
  first in which the app and its extensions agree. That is a correlation. Nothing shows it to be the
  cause, and an install that simply needed time to register its shortcut would look the same.
- **Every archive was made from the working tree,** not from a commit (#79).
- **What 1.1 carries that was not proved first:** the watch tests did not run for #73 (#77), and the
  Lock Screen widget and the Control Center control still have no recorded device check (#70, #75).
- **Not known:** the *What's New* text that was submitted, and whether it names the Siri phrase.

The forty-first pass's account of the failure, written a few minutes earlier, retained:

**The Siri phrase on a device: tried once, failed, cause not found** (2026-10-09, the forty-first pass;
known issue #78). The owner's account, from their iPhone: a TestFlight build of 1.1; Siri in English,
"Log water in WaterBuddy"; and the *Log a Glass* tile in Shortcuts. Each opens WaterBuddy, and no serving
is logged. So the phrase is matched, and it is the action that does not run.

Everything that can be read from here is as designed:

| Checked | Found |
|---|---|
| `LogServingIntent` | `openAppWhenRun = false`. `perform()`'s first wait, `waitUntilActivated()`, is bounded at about a second. Its second, `remindersSettled()`, has **no time limit** — `ReconcileQueue.settled()` returns when the reconciles queued before it have run — but it comes after the Glass is logged, so a stall there would still leave a serving, which the owner did not see |
| `Metadata.appintents`, Debug (simulator) and Release (device, built unsigned into scratch) | identical. One action, `LogServingIntent`: `openAppWhenRun: false`, `supportedModes: 1`, mangled name `10WaterBuddy16LogServingIntentV`. One shortcut over it, three phrase templates |
| `en.lproj` and `ru.lproj` `AppShortcuts.strings` | all three phrases in each, the two keys Xcode marked stale included (#50) |
| The Release binary | type and conformance records for `LogServingIntent: AppIntent` and `WaterBuddyShortcuts: AppShortcutsProvider` are present |
| Probe 1 — found by mangled name, cast and built from a detached task | `cast=ok`, `init=ok`; the provider lists 1 shortcut |
| Probe 2 — `perform()` run the same way, in the test host | returned `IntentResultContainer<Never, Never, Never, IntentDialog>`; water 0 → 250, rows 0 → 1; 3.87 seconds, on a loaded Mac |
| Probe 3 — `supportedModes` read at run time | raw 1, equal to `.background`; `.foreground` is 2 |
| Apple's forums and documentation | no report of this symptom. `openAppWhenRun` is deprecated from iOS 26 in favour of `supportedModes` |

The three probes ran on iOS 27.0's iPhone 17 simulator, as `WaterBuddyTests/ZZSiriProbe.swift`, deleted
after each; `git status` shows nothing left of it. Probe 2 added one Glass to that simulator's own data.
None of them is the system's path: the simulator still refuses an App Shortcut from a locally signed
build (#63).

**Not known:** the phone's iOS version; which build number the TestFlight build carried; whether *Water
logged.* shows before the app opens; anything from the device's log. **Asked of the owner, not yet
answered:** the phone's log through Console, or leave to sign simulator builds with their development
identity so the shortcut can be run here (#63 calls that theirs to decide).

**No code was changed for it.** Moving the intent to `supportedModes` would be a guess: the app already
reports the same mode through the older property.

**Gate — run on the evening of 2026-10-08, on Xcode 27.0, for known issue #73** (the fortieth pass), on
the final code: **four of the five, and none on its pinned destination.** That evening every simulator
on this Mac lost its data, and only some runtimes came back (#77). iOS 26.5's iPhone 17 would not boot —
"Unable to boot device because it cannot be located on disk" — and no watchOS 26 runtime was installed.
The phone runs therefore used iOS **27.0**'s iPhone 17, erased by the owner, and the watch widget was
built for the generic watchOS Simulator destination. Foreground, `-parallel-testing-enabled NO`;
`xcrun simctl shutdown all` was skipped, while other projects' (`AvtoLog`, `Glazzy`) simulators were in
use.

| Command | Destination | The final code |
|---|---|---|
| `-only-testing:WaterBuddyTests` | iOS 27.0, iPhone 17 | `✔ Test run with 377 tests in 46 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | iOS 27.0, iPhone 17 | `Executed 26 tests, with 0 failures` |
| `-only-testing:WaterBuddyWatchTests` | — | **not run** — no watchOS 26 runtime. `build-for-testing -scheme WaterBuddyWatch`, generic watchOS Simulator: `** TEST BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWidgetExtension` | iOS 27.0, iPhone 17 | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `generic/platform=watchOS Simulator` | `** BUILD SUCCEEDED **` |

**The UI run is 26 of 26**, the first since 2026-10-07. #62's test passed on the freshly erased
simulator: that is its cause seen from the other side, not a fix.

**All four shipping targets compiled the changed file.** These logs show a `SwiftCompile` of
`DataManager.swift` in `WaterBuddy`, `WaterBuddyWidgetExtension`, `WaterBuddyWatch` and
`WaterBuddyWatchWidget`.

**Warnings: none new.** Clean builds of the `WaterBuddy` scheme into empty DerivedData: a copy of the
tree with the two changed files put back to HEAD, and the final code. Unique `path:line:col: warning:`
lines 31/31, 44 occurrences each, and identical per file and message with positions stripped — the
positions themselves moved with the thirteen new lines.

**RED → GREEN, in three runs of `ReminderSeamTests`:**

1. The tests alone: three failed — on `!widget.currentReminderSlots().isEmpty`, on
   `widget.currentReminderSlots().isEmpty`, and on `manager.remindersEnabled` with `counter.count == 1`
   — and the guard's test passed.
2. An unguarded re-read: those three passed, and `aRefreshThatFindsTheFlagUnchangedDoesNotChurnObservers`
   failed on `counter.count == 0`.
3. The guard added: `✔ Test run with 19 tests in 1 suite passed`.

The first run's call passed its 600-second foreground limit while the erased simulator booted for the
first time, and finished in the background with its result already printed. Every later run finished in
the foreground.

**Not run:** the bug itself on a simulator or a device — it needs a widget extension kept alive across
the toggle, and nothing lists the pending set — and no widget was placed: this change is in no view tree.

**The version is 1.1 — the owner's own change, the same evening.** App Store Connect refused an upload
of 1.0: *"The train version '1.0' is closed for new build submissions"*, 1.0 being the approved version.
The owner moved `MARKETING_VERSION` from 1.0 to 1.1 at all fourteen sites in `project.pbxproj` — seven
targets, Debug and Release. Every run above after the first RED built with it. It is unstaged, and its
own commit.

**The build number is 3**, at all fourteen sites (2026-10-09). The owner had moved the app target alone
to 2, which left the widget, the watch app and the watch widget at 1 — and App Store Connect warns when
an extension's build number differs from its app's. They then named 3 for the next build, and all
fourteen were set to it. *(This paragraph read "`CURRENT_PROJECT_VERSION` is still 1" until the
forty-first pass: true when the fortieth wrote it, and stale within hours.)* The gate above built with
build number 1. Nothing has been archived or uploaded as 1.1 (3) by this work. *(Forty-second pass:
true of the session and wrong about the Mac. The owner had archived and uploaded 1.1 (3) at 08:52,
three minutes before that sentence was written; the forty-first pass did not look in the Archives
folder. The table at the top of this section has all four.)* An archive carries whatever the working tree
holds: that evening, HEAD plus the uncommitted fixes for #68 and #73.

The #68 fix's gate block, retained:

**Gate — all five run once on 2026-10-08, on Xcode 27.0, for known issue #68** (the thirty-ninth pass),
on the final code. Foreground, `-parallel-testing-enabled NO`, the commands as rule `85-testing` writes
them; `xcrun simctl shutdown all` was skipped before every run, while other projects' (`AvtoLog`, then
`Glazzy`) `xcodebuild test` ran.

| Command | The final code |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 373 tests in 46 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `Executed 26 tests, with 1 failure` — #62 |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |

**The UI failure is #62's**, at `GoalSetupUITests.swift:219` — "the new serving is not under yesterday",
as at HEAD; the change is inside the widget extension, which no UI test reaches.

**Warnings: none new.** Clean builds of `WaterBuddyWidgetExtension` — the scheme whose target compiles
the changed file — into empty DerivedData, before the first edit and on the final code. Both compiled the
same set (the phone targets arm64, the watch targets arm64 and x86_64): unique `path:line:col: warning:`
lines 31/31, identical with positions included, 44 occurrences each, none in `WaterBuddyWidget/`.

**RED → GREEN by a throwaway probe** (deleted before staging): no automated test can render the
extension — `WaterBuddyTests` only `@testable import`s the app. It placed a medium WaterBuddy widget on
the simulator's Home Screen (page 1), then, with the phone in English, chose Russian and then Uzbek in
the app's picker, waited each time until the widget's own button spoke that language, and read
SpringBoard's tree. Old code: `+250 мл` beside `7450 ml` and `of 2000 ml`; Uzbek's goal line `of 2000 ml`
— the assertion failed on the Russian goal line. Fixed code: `7450 мл` / `из 2000 мл` / `+250 мл`, and
`7450 ml` / `2000 ml dan` / `+250 ml`. The English card, 1059 × 498 px, is byte-identical before and after.
Captured in the simulator's own dark appearance and in light; **tinted not captured** — SpringBoard's
accessibility query timed out on the way out of its *Customize* sheet, under a load average of ~860 from
the other projects' tests, and was not retried: the change touches no rendering-mode branch, and the
full-colour card did not move a pixel. The app's language was put back to English, the Home Screen look
to Default and the appearance to dark; the medium widget stays placed on page 1.

The Control Center control's gate block, retained:

**Gate — all five run twice on 2026-10-08, on Xcode 27.0, for roadmap item 6, the Control Center
control** (the thirty-eighth pass): after the change, and again on the final code after the final
review's fixes. Foreground, `-parallel-testing-enabled NO`, the commands as rule `85-testing` writes
them; `xcrun simctl shutdown all` was skipped once, while another project's (`Glazzy`) `xcodebuild test`
ran, and used before every other test run.

| Command | Before the review's fixes | The final code |
|---|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 371 tests in 46 suites passed` | `✔ Test run with 373 tests in 46 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `Executed 26 tests, with 1 failure` — #62 | `Executed 26 tests, with 1 failure` — #62; a first attempt was refused launch as `Busy` with no test run (#57), and re-run unchanged once the device had booted |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` | `** BUILD SUCCEEDED **` |

**The UI failure is #62's**, at `GoalSetupUITests.swift:219`, the waiter timing out on the visible-row
count as it does at HEAD; nothing this change touches is on its path.

**Warnings: none new.** Clean builds into empty DerivedData of a copy of the tree taken before the first
edit and of the final code, all four schemes, compared per file, message and count with positions
stripped: identical — unique `path:line:col: warning:` lines 31/31 app, 31/31 widget, 2/2 watch, 31/31
watch widget. The watch widget's scheme compiles a different architecture set from one clean run to the
next (phone arm64 alone with the watch on two, or the reverse), and only the second shape prints #36's two
`actool` lines, so its runs were compared only against the baseline run of the same shape
(`tasks/lessons.md`).

**Two new tests** — `theUsualServingIsReadFromTheUsualSlot` and `theUsualSlotIsTheGlass` — RED on the
missing `usualSlot`, then GREEN; the control itself has no unit test (spec §6: no test target compiles
the extension). **On the simulator** (a throwaway probe, deleted): the control was offered, placed (a
small glyph-only tile) and titled in all three languages by the app's picker; a press ran
`AddWaterIntent.perform()` through `chronod` and logged the stored Glass — 400 after an edit from 250,
250 after the edit back, on the final code too — and a mutation run without the reload logged the Glass
from before each edit. What only a device can show is #75.

The Lock Screen widget's gate block, retained:

**Gate — all five run three times on 2026-10-08, on Xcode 27.0, for roadmap item 5, the Lock Screen
widget** (the thirty-seventh pass): after the plan's gate task, again after the ring's floor moved from
0.6 to 0.4, and a third time after the final review's fix pass — the last run is on the staged code.
Foreground, `-parallel-testing-enabled NO`; `xcrun simctl shutdown all` was skipped whenever another
project's (`AvtoLog`) `xcodebuild` was running.

| Command | The staged code (after the fix pass) |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 371 tests in 46 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `Executed 26 tests, with 1 failure` — `testAServingAddedToYesterdayShowsUnderYesterday` (#62); in the second of the three runs, a first attempt was refused launch as `Busy` (#57) and re-run |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |

**The UI failure is not this change's:** HEAD `562157e`'s `git archive` export fails the same test at the
same line (`GoalSetupUITests.swift:219`) on the same simulator. After that failure, `xcodebuild` spent up
to ten minutes in `simctl diagnose`; the results were read from the log.

**Warnings: none new.** Clean builds of HEAD's export and of the final code into empty DerivedData, all
four schemes, compared as unique `file: message` lines with line numbers stripped (the plan's Task 3,
Step 3): app 38/38, widget 19/19, watch 2/2, watch widget 2/2 — identical, and none in
`LockScreenWidget.swift`. (One app-log line once read differently: the same `#expect` warning, cut off
mid-line by the log; 16 full copies on both sides in the final comparison.)

**No new tests** — spec §6, approved: no test target compiles the extension, and WidgetKit lists no
families. **On the simulator**, a throwaway probe (deleted) placed all three shapes and captured them:
57% in the gallery; 38% and 113% in English, Russian (`750 мл`, `из 2000 мл`, `113 %`) and Uzbek
(`2000 ml dan`). The **+** reached `linkd`, which refused it (#63) — see #70 for what only a device can
show. A fresh final review returned "with fixes": the hidden flags and `.invalidatableContent()` it led
to are in the staged code.

The Siri phrase's gate block, retained:

**Gate — all five run twice on 2026-10-07, on Xcode 27.0, for roadmap item 4, the Siri phrase** (the
thirty-sixth pass): after the plan's last code task, and again after the final review's fix pass.
Foreground, `-parallel-testing-enabled NO`, the commands as rule `85-testing` writes them;
`xcrun simctl shutdown all` was skipped whenever another project's (`AvtoLog`) `xcodebuild` was
running, and the iPhone 17 was booted with `simctl bootstatus … -b` before a test run.

| Command | Before the fix pass | After it — the staged code |
|---|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 368 tests in 45 suites passed` | `✔ Test run with 371 tests in 46 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `Executed 26 tests, with 2 failures`; a full re-run, `with 1 failure` | `Executed 26 tests, with 1 failure` — `testAServingAddedToYesterdayShowsUnderYesterday`, pre-existing (#62) |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` | `** BUILD SUCCEEDED **` |

**The UI failure is not this change's.** HEAD `4a7f4dd`, built from `git archive` into its own
DerivedData, fails the same test at the same line on the same simulator (#62). The first run's second
failure, `testSettingsIsReachableFromHomeAsATab`, was a first tap dropped while another project's UI
tests ran beside it (#67); it passed in isolation and in both later full runs.

**Warnings: none new.** Clean builds of HEAD and of the change into empty DerivedData, the same sequence
on both sides, all four schemes: identical per file and message (app 68/68 lines, widget 44/44, watch
8/8, watch widget 8/8) — and identical again after the fix pass. The app's build-for-testing reads 37
unique lines and 50 occurrences on both sides, 31 shipping and 6 in tests: the thirty-fourth pass's
named-destination figures. The change compiles 171 steps to HEAD's 168.

**Thirteen new tests in five suites** (`SiriPhraseTests.swift`), each RED on a seam that compiled —
the Cup instead of the Glass (`UsualServingTests` 4 tests, 8 issues; `LogTheGlassTests` 3 tests, 5
issues), a settle that returned at once, an intent with the wrong policy and a reply in no table, no
phrase table — then GREEN. The idle settle, the widened settle test and the reply's figure check are
proven by mutation (a two-second settle; a settle that returns at once; *Water logged: 250 ml.*), each
restored and checked by `cmp`.

**On the simulator** (a throwaway XCUITest probe, deleted): the shortcut registers — *WaterBuddy → Log
a Glass*, mug glyph, blue tile, *Записать стакан* with Shortcuts in Russian — but cannot run: `linkd`
refuses the ad-hoc-signed build for want of a Team ID (#63). Siri never came up on the simulator, and
Spotlight's search field did not appear to the probe. Not checked: the Home Screen widget — its view
tree and storage are unchanged, and its serving is the same value under a new name.

*(The 2026-10-07 #60 gate block below is retained as that pass's record.)*

**Gate — all five run twice on 2026-10-07, on Xcode 27.0: before `/commit` committed roadmap item 3,
and after known issue #60's fix** (the thirty-fifth pass). Foreground, `-parallel-testing-enabled NO`,
the commands exactly as rule `85-testing` writes them. `xcrun simctl shutdown all` preceded every test
invocation but one — the commit's unit run, while another project's (`Glazzy`) `xcodebuild` was
running; `simctl` had listed nothing booted at 18:39. The commit's UI and watch runs waited until no
`xcodebuild` had run for ten seconds. The #60 phone UI-test run was **refused launch** the first time
(#57), and run again after `xcrun simctl bootstatus … -b` had booted the iPhone 17.

| Command | Before the commit | After #60 |
|---|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 358 tests in 41 suites passed` | `✔ Test run with 358 tests in 41 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `Executed 26 tests, with 0 failures` | `Executed 26 tests, with 0 failures`, on the second run. The first: `Busy ("Application failed preflight checks")`, no test executed, exit 65 |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` | `** BUILD SUCCEEDED **` |

**Warnings:** every build was incremental, so neither run gives a figure to set against the clean
baseline. Every warning printed is in `DataManager.swift`, `NotificationManager.swift` or
`WristView.swift`, in the baseline's two families; `HistoryView.swift`, which the #60 unit run
recompiled (`SwiftCompile … HistoryView.swift`), printed none. The committed code had been compared
against a clean build of HEAD by the thirty-fourth pass. **On the simulator:** #60's renders were not
re-taken — the fixed file hashes to `e083cfc`, the result of the patch those renders were of, on the
same base, `2e8b266`. Not checked: the Home Screen widget and the watch face — nothing they draw
changed.

*(The 2026-10-07 earlier-servings gate block below is retained as that pass's record.)*

**Gate — all five re-run 2026-10-07, on Xcode 27.0, after roadmap item 3: a serving added or fixed at
an earlier time or day** (the thirty-fourth pass). Foreground, `-parallel-testing-enabled NO`, the
commands exactly as rule `85-testing` writes them — **except `xcrun simctl shutdown all`, skipped**: no
other `xcodebuild` was running, but an iPhone 18 Pro (iOS 27.0) this session had not booted was, and
shutting it down could have ended someone else's work. The phone UI-test run was **refused launch** the
first time, as #57's was, and run again.

| Command | Result |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 358 tests in 41 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `** TEST SUCCEEDED **` — `Executed 26 tests, with 0 failures`, on the second run. The first: `Busy ("Application failed preflight checks")`, no test executed |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` — it compiled the changed `DataManager.swift` for all four targets |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |

**Twenty-seven new unit tests in six new suites, and two UI tests.** `HistoryLogsTests` (3),
`RetimingTests` (10), `HistoryWindowStartTests` (2, not `@MainActor`), `CorrectionRangeTests` (5),
`RetimedPourTests` (2) and `HistorySelectionTests` (5, not `@MainActor`), in the new
`EarlierServingTests.swift`. **RED on seams that compiled:** all 27 ran and 19 failed, each on its own
expectation. **The other eight, by mutation.** One run mutated `updateLog` (a missing time defaulting to
`now()`, the time applied before the amount guard, the nothing-changed guard removed), made `addLog`
ring the doorbell, and stopped `selection(forDay:in:)` clearing: exactly the five predicted new tests
failed, with the existing `loggingRingsTheWidgetDoorbellExactlyOnce` and
`mutationsRingTheWidgetDoorbellAndNoOpRefreshesDoNot`. Two more runs had `updateLog` re-insert the
serving under a new id, and re-file the applied ledger under the new day: each failed its one watch
test. The fixture guard passes by design. The files were restored from saved copies, `cmp`-identical,
no marker left. **UI:** `testTheWeekCardIsOneSummaryAndOneButtonPerDay` replaces
`testLoggingAServingRevealsTheWeekCardAsOneElement` — the card is one summary plus exactly one button
per day now — and `testAServingAddedToYesterdayShowsUnderYesterday` is new. Both were written after the
view, so their RED was taken against a `git archive HEAD` export with only the test file swapped in:
the first failed on the summary (HEAD resolves *two* elements labelled *Last 7 days*), the second on
yesterday's missing button.

**Warnings: none new, by two methods.** Clean builds of a `git archive HEAD` export (`cd09663`) and of
the same export plus only the change's five files, one empty DerivedData per side. With *named*
destinations, across all four schemes (`build-for-testing` of `WaterBuddy` and `WaterBuddyWatch`,
`build` of both widgets): identical per build, per file and message, and per location count. With a
*generic* destination, in the `WaterBuddy` build-for-testing — the baseline's own method: shipping **31
unique lines and 80 occurrences**, tests **6 and 12**, on both sides. **The named run counts 44 and 6**
for the same code: a generic simulator destination compiles `arm64` and `x86_64` separately and prints
each warning once per architecture — confirmed this session by building HEAD both ways. Compare
occurrences only between builds made the same way.

**On the simulator**, on the iPhone 17 and the iPhone 17e — at 390 pt the narrowest phone installed;
there is no 375-pt one. Screenshots came from a throwaway XCUITest probe, deleted afterwards: the day
picker, a past day, an empty past day, both sheets, Russian and Uzbek through launch arguments, and
`AccessibilityXXXL`. **Two layout bugs were found there and fixed** before the gate: the wheel's
natural width pushed the sheet past the screen's right edge, and the day row's `minHeight` floor let it
compress at `AccessibilityXXXL` until the bars rose through the title. **Contrast**, read off those
renders, clears its floor for every new mark — figures in `docs/DESIGN.md` — except the wheel's
neighbouring rows, 2.43–2.80:1 (#59). Not checked: the Home Screen widget and the watch face — nothing in
storage, entitlements, membership or the widget's view tree changed.

*(The 2026-10-07 complication gate block below is retained as that pass's record.)*

**Gate — all five re-run 2026-10-07, on Xcode 27.0, after the complication change** (the
thirty-third pass). Foreground, `-parallel-testing-enabled NO`, the commands exactly as rule
`85-testing` writes them — **except `xcrun simctl shutdown all`, skipped again**: another project's
(`Glazzy`) UI-test run was live just before the gate began, and some other session's `xcodebuild` was
counted again just before the watch run. The phone UI-test run was **refused launch**
the first time, and run again (#57).

| Command | Result |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 331 tests in 35 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures`, on the second run. The first ended `Testing failed: Simulator device failed to launch sardor.WaterBuddyUITests.xctrunner` — SpringBoard answered `Busy ("Application failed preflight checks")` — with no test executed |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 57 tests in 6 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |

**Fifteen new tests, in two new suites and one grown.** Phone, `WristMirrorNewsTests` (+3, not
`@MainActor`): the first mirror is news; one differing only in `composedAt` is not; a change to any
other field is, field by field. Watch, `WristModelTests` (+9): a pour reloads the face and a refused
one does not; a mirror that changes the total reloads, the same mirror twice reloads once, and one new
only in `composedAt` is taken but reloads nothing; an older mirror changes nothing; a tie is taken; a
held mirror 30 s ahead of the watch's clock still blocks an older one, and one an hour ahead does not.
And `WristLinkDeliveryTests` (+3, not `@MainActor`): the wait ends as soon as delivery is done, gives up
after its last check, and ends when its task is cancelled. **RED on seams that compiled:** `isNews`
returning `true` (the composed-at test failed) and then `false` (the other two, all nine fields by
name); then the reload closure stored but never called, no ordering rule, and `poll` returning `false`
unchecked — nine of the watch's twelve failed, each on its own expectation. **The other three, by
mutation:** the pour's reload moved above its guard, ties rejected, the clock escape removed and
`apply`'s reload made unconditional, in one run — exactly the five predicted tests failed, among them
the existing `aNewMirrorSwitchesTheLanguageForObservers`, whose mirrors share a stamp.

**Warnings, compared rather than counted, across all four schemes.** Clean `build-for-testing` of
`WaterBuddy` and `WaterBuddyWatch` and `build` of both widget schemes, generic simulator destinations,
one empty DerivedData folder per side: a `git archive HEAD` export (`05a6998`) against the same export
plus only the change's seven Swift files — the four files the Xcode app wrote (#50) kept out of both.
**Identical per file, message and count.** On the compiler's primary `File.swift:L:C: warning:` lines,
in the `WaterBuddy` build-for-testing — the baseline's own method — shipping targets 31 unique lines and
80 occurrences, test targets 6 and 12. Across all four builds, 31 and 160 — the phone widget's scheme
rebuilds the phone app and the watch app it embeds, and reprints the same 80, eight of them from the
watch's `WristView.swift` — and still 6 and 12. Counting every line that contains
` warning: ` in the `WaterBuddy` build-for-testing also counts Swift 6's caret echoes and macro
expansions, and reads 101/245 on the shipping targets — equally identical, and not the figure the
baseline means. *(Until the 2026-10-07 re-run, 31/80 stood here without its scope, under a heading
that names all four schemes.)*

**Not observed:** anything on the wire. The push, the waiting wake and the face's `.atEnd` policy have
no automated coverage and were not run on a simulator — none here has ever been seen running a
WatchConnectivity background task (spec 2026-08-31 §15), and the complication has never been placed on
a face. The owner's device check (spec 2026-10-07 §8.3) is what proves them (#52).

*(The 2026-10-07 known-issue #46 gate block below is retained as that pass's record.)*

**Gate — all five re-run 2026-10-07, on Xcode 27.0, after the known-issue #46 fix** (the
thirty-second pass). Foreground, `-parallel-testing-enabled NO`, the commands exactly as rule
`85-testing` writes them — **except `xcrun simctl shutdown all`, skipped.** Test runs for two other
projects (`AvtoLog`, `Glazzy`) were running on this Mac's simulators, and shutting them all down would
have killed theirs. Each run booted only its own destination — plus, for the watch run, the iPhone 17
that watch is paired with, which came up alongside it (#51). *(Until the 2026-10-07 re-run this said
every simulator, this session's included, "was found shut down between two of its runs", as if
another session had done it, and that each run "used one device". A two-second poller across two
later runs showed `xcodebuild` shutting down the devices it boots in the last seconds of its own run,
with no `simctl shutdown` from any session, and showed the watch run booting the pair.)*

| Command | Result |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 328 tests in 34 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures` |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 45 tests in 5 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` — reprinting known baseline warnings, because the scheme also builds the phone app, the watch app and the watch widget *(until the re-run: "from the shared files it recompiled" — `WristView.swift`, which is in no shared set, warned too)* |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` |

**Three new phone tests in one new suite**, `ReconcileQueueTests`, deliberately not `@MainActor`: a
slow operation asked for first still finishes first; an older plan cannot re-file the slot a newer
one dropped — the race itself, through the real `reconcile`, against `SharedCentre`, a lock-guarded
stand-in; and an operation asked for after the queue went idle still runs. **RED on wrong values** —
the tests came first, then `ReconcileQueue` with the hook's old one-`Task`-per-call shape as its
body: `order → ["newer", "older"]`, and the older plan re-filed the 13:00 slot. The idle test passed,
as it must against that shape. **Three mutations, each caught as predicted:** the old shape and a
worker that starts a `Task` per operation by the first two tests; a worker that stops after one
operation by all three, through the suite's one-minute time limit — 647 seconds, because `xcodebuild`
relaunched the host after each exceeded limit.

**Warnings, compared rather than counted.** Clean `build-for-testing -scheme WaterBuddy` into empty
DerivedData, generic iOS Simulator: a `git archive HEAD` export (`641e88c`) against the same export
plus only the change's four Swift files — the working tree also held four files the Xcode app had
written (#50), kept out of the comparison. **Identical per file and message:** shipping targets 31
unique lines and 80 occurrences, test targets 6 and 12.

**Not observed:** the real notification centre. No test may reach it and its pending set cannot be
read from the host, so the race was reproduced only against a stand-in; the hook's one-line wiring
to the queue has no test.

*(The 2026-10-06 smart-reminders gate block below is retained as that pass's record.)*

**Gate — all five re-run 2026-10-06, on Xcode 27.0, after the smart-reminders change** (the
thirty-first pass). Foreground, one simulator at a time, `xcrun simctl shutdown all` before each,
`-parallel-testing-enabled NO`, the commands exactly as rule `85-testing` writes them.

| Command | Result |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 325 tests in 33 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures` |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 45 tests in 5 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` — no warning printed |

**Nine new phone tests**, no suite added. `ReminderPlanTests` +7: a drink silences the slot due
within the hour; one ninety minutes ahead of a slot leaves it; the quiet ends exactly an hour after
the drink; a drink before nine silences the first slot; a drink stamped ahead of the clock silences
only the next hour; a late drink leaves tomorrow alone; and a day swept every five minutes, which
proves one drink drops at most one slot and never moves one. `ReminderSeamTests` +2: logging a drink
silences the slot through both the app's hook and `currentReminderSlots()`, and deleting it brings
the slot back. **RED on wrong values rather than a compile error** — the tests were written first,
then the parameter, accepted and ignored, so the RED run compiled and exactly the seven expected
tests failed (37 run, 8 issues); the other two are regression guards, proven by mutation instead.
*(Until the 2026-10-07 re-run this said "the parameter landed first", which had the order wrong.)* **Six mutations, each caught by its test:** `<`
→ `<=` and a 61-minute quiet by `theQuietHourEndsExactlyAnHourAfterTheDrink`, a 2-hour quiet by
`aDrinkMoreThanAnHourBeforeASlotLeavesItPlanned`, a 3-hour quiet by `oneDrinkSilencesAtMostOneSlot`,
a 12-hour quiet by `aLateDrinkLeavesTomorrowUntouched`, and a dropped clamp by
`aDrinkStampedAheadOfTheClockSilencesOnlyTheNextHour` and the sweep.

**Warnings, compared rather than counted.** The change reaches every binary through two shared
files, so the comparison ran on the scheme that carries the recorded baseline: clean
`-scheme WaterBuddy` builds into empty DerivedData, a `git archive HEAD` export (`5ac02f1`) against
the working tree, generic iOS Simulator — **31 against 31** unique lines and 80 against 80
occurrences, identical per file and message. None new, none gone.

**Not observed:** pending notifications on a simulator (not readable as a file), and either reminder
caption on screen in any language — Xcode 27 offers no tap route to Settings while the capture
scripts are stale (#45). `everyDrawnStringIsTranslatedUnlessDeliberatelyNot` found both new keys in
the built bundle's ru and uz tables — it proves a translation exists for every English key, not what
the translation says, and these two are the model's drafts, unreviewed by a native speaker. The
caption grows vertically, so a longer string cannot truncate. *(Until the 2026-10-07 re-run this said
the test "resolved" both keys, which claimed more than it checks.)*

*(The 2026-10-06 known-issue #35 gate block below is retained as that pass's record.)*

**Gate — all five re-run 2026-10-06, on Xcode 27.0, after the known-issue #35 fix** (the thirtieth
pass). Foreground, one simulator at a time, `xcrun simctl shutdown all` before each,
`-parallel-testing-enabled NO`, the commands exactly as rule `85-testing` writes them.

| Command | Result |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 316 tests in 33 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures` |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 45 tests in 5 suites passed` — and again after each of two later, comment-only DocC edits |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` — reprinting the known 31-line baseline, because it rebuilt the phone app and the watch app it embeds |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` — no warning at all: everything was up to date, so it compiled nothing |

**Three new watch tests** in `WristViewLogicTests`, no suite added: the empty vessel lays down no
scrim; below full strength the scrim rises with the water; and it is at full strength by the level at
which water first reaches the millilitre line, worked out by hand for diameters 60, 104, 123 and 170.
RED on a wrong value rather than a compile error — the seam first returned today's constant 1, and
exactly the first two failed — and a mutation run with the widget's ramp failed the third on all four
diameters.

**Warnings, compared rather than counted.** The fix compiles into one target, so the comparison ran on
clean `-scheme WaterBuddyWatch` builds into empty DerivedData — a `git archive HEAD` export against
the working tree, generic watchOS Simulator: **2 against 2** unique lines (the known `Combine` pair in
`WristView.swift`, identical down to line numbers), 8 against 8 compiler-emitted occurrences, none new
and none gone. *(This said "16 against 16" until the same day's re-run: that count included Swift's
caret annotation lines, one beneath each warning.)*
That scheme builds only the watch app, and the main-actor family does not appear in it at all —
consistent with known issue #30: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` sits on the app target's
two configurations and nowhere else. The `-scheme WaterBuddy` clean baseline (31) was not re-measured
this pass; of what it compiles, only the embedded watch app's one file changed.

**By hand, on simulators, measured off the renders:** the watch app built from the tree, on the
watchOS 26.5 Series 11 (46mm) and SE 3 (40mm), both at 0%. The vessel reads as glass, sRGB
`(36, 43, 95)` behind the text where the old captures read ≈`(24, 28, 62)`, and the millilitre line
holds **8.58:1** and **8.60:1** in its worst column. **Not observed:** levels between 0% and 20%
(bounded by the 0% figure, since only glass is behind the text there), Reduce Transparency (≈8.3:1,
worked out from a token rather than measured), the scrolled state, and real hardware.

*(The 2026-10-06 watch-localization gate block below is retained as that pass's record.)*

**Gate — all five re-run 2026-10-06, on Xcode 27.0**, after the watch localization. Foreground, one
simulator at a time, `xcrun simctl shutdown all` before each, `-parallel-testing-enabled NO`, the
commands exactly as rule `85-testing` writes them.

| Command | Result |
|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 316 tests in 33 suites passed` |
| `-only-testing:WaterBuddyUITests` (harness skipped) | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures` |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 42 tests in 5 suites passed` |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` — with exactly the two known `actool` lines |

**Seven new phone tests and twelve new watch tests**, no suite added. `LocalizationTests` +7: the
watch's two bundles, read through `Watch/WaterBuddyWatch.app` inside the built phone app — present,
every offered language shipped, every string shared with the phone identical to the phone's, the
watch's own keys present, format arguments kept, nothing extracted left untranslated, the product
name untranslated. `WristModelTests` +6: the language the watch draws in. `WristViewLogicTests` +6: a
bundle guard, every caption in Russian and Uzbek, a phone clock running ahead, serving names, the
grouped readout. The six existing caption tests now take the `en` bundle and keep their exact English
expectations. Tasks 1–4 each went RED before GREEN, filtered by suite, with the executed count read;
Task 5's wiring has no test that can observe it — there is no watch UI-test target (known issue #42)
— and Tasks 6–9 were the gate, the screens, the rules and the records.

**Warnings, compared rather than counted.** Clean builds of `-scheme WaterBuddy` into empty
DerivedData folders, generic iOS Simulator destination — a `git archive HEAD` export against the
working tree — compared per file and message: **31 against 31** unique lines, 19 against 19
file-and-message pairs, none new and none gone. The `WaterBuddyWatchWidget` scheme's two `actool`
warnings now have a cause (known issue #36): its checked-in scheme builds `WaterBuddy.app` as well,
which is also why that scheme reprints the phone targets' Swift warnings whenever they had to
rebuild. Incremental logs show only what they recompiled, which is why the comparison runs on clean
builds (`tasks/lessons.md`, 2026-09-02 and 2026-10-06).

**By hand, on simulators:** the watch app launched with `-AppleLanguages`/`-AppleLocale` —
argument-domain overrides, nothing persisted — on an SE 3 (40mm) and a Series 11 (46mm), in Russian
and in Uzbek. All four screens draw their language with nothing truncated: `0 / 2 000 мл`, "Нет
синхронизации · цель по умолчанию", "Синхронизировано 878 мин назад", "878 daqiqa oldin
sinxronlandi". **Not observed, at the owner's choice:** the live switch (the phone set to Русский,
the watch following), the "More" sheet in another language, and the complication's description in
the face editor. Under `.system` a missed injection would be invisible, so the live switch is the
check most worth one tap.

**Standing from 2026-10-05:** Xcode 27.0, with iOS and watchOS 27.0 runtimes beside 26.5; the second
iOS 26.5 "iPhone 17" renamed "iPhone 17 (spare)" so the gate's destination stays unique; the iPhone
17 and Series 11 (46mm) left paired, where the first mirror delivery on simulators was observed once
the watch app was installed *after* the phone app (`tasks/lessons.md`); and the complication on a
watch face and a real midnight turnover still unobserved, resting on the `WristPlan` tests.

*(The 2026-09-02 gate block below is retained as the record of the App Store preparation pass's run,
on Xcode 26.6.)*

**Gate — all five re-run 2026-09-02**, after the App Store preparation pass (iPad dropped,
`IPHONEOS_DEPLOYMENT_TARGET` 26.5/18.6 → **17.0**, `WATCHOS_DEPLOYMENT_TARGET` 26.5 → **26.0**, the
watch launcher icon fixed, four privacy manifests added, export compliance declared). Foreground,
one simulator at a time, `xcrun simctl shutdown all` before each, `-parallel-testing-enabled NO`.

| Command | Result | Warnings |
|---|---|---|
| `-only-testing:WaterBuddyTests` | `✔ Test run with 300 tests in 33 suites passed` | 31 |
| `-only-testing:WaterBuddyUITests` | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures` | 0 |
| `-only-testing:WaterBuddyWatchTests` | `✔ Test run with 29 tests in 5 suites passed` | 0 |
| `build -scheme WaterBuddyWidgetExtension` | `** BUILD SUCCEEDED **` | 38 |
| `build -scheme WaterBuddyWatchWidget` | `** BUILD SUCCEEDED **` | 0 |

Test counts are unchanged from the 2026-09-01 run — this pass added no `@Test` and no XCTest case
that the gate runs. `AppStoreScreenshotUITests` **is** a new XCTest class in `WaterBuddyUITests`, but
it is a capture harness rather than a test and the gate skips it explicitly
(`-skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests`, rule `85-testing`) — which is why the
UI figure is still 25 and not 26.

**On the warning counts: 31 and 38 are not new.** They are the pre-existing concurrency baseline now
recorded as known issue #29, and this pass proved it is pre-existing rather than assuming so —
the same scheme was built at the old floor and the new one and the warning sets diffed byte-for-byte
identical. Zero **new** warnings is the honest claim; zero warnings is not, and the older text below
that says this codebase compiles clean is superseded.

**Artifact-level verification, which the gate structurally cannot do** — read off a clean build into
empty DerivedData:

| Claim | Proof |
|---|---|
| iPhone-only | `UIDeviceFamily` → `[1]`; `Assets.car` → 4 `phone` renditions, 0 `pad` |
| iOS floor | `MinimumOSVersion` → `17.0`; `vtool -show-build` → `minos 17.0` on the app **and** the widget appex |
| watchOS floor | `vtool -show-build` → `minos 26.0` on the watch app **and** the watch widget appex |
| Watch launcher icon | `assetutil --info` on the watch `Assets.car` → `"Idiom" : "watch"` (was `"marketing"`) |
| Export compliance | `ITSAppUsesNonExemptEncryption` → `false` |
| Privacy manifests | `PrivacyInfo.xcprivacy` present in all four shipping bundles |

**Still unproven, and the gate cannot close it:** no iOS 17.x runtime and no watchOS 26.0 runtime is
installed on this machine, so neither floor has ever been *executed* — only compiled and linked.

*(The 2026-09-01 gate table below is retained as the record of the watchOS plan's own final run.)*

**Gate — all five run 2026-09-01, from the project directory, one simulator at a time,
`xcrun simctl shutdown all` before and after, no parallel cloning.** This is the watchOS plan's
final task, run once every prior task's work was in place (`6cee506`) and every doc/rule edit in
this same pass was written.

| Command | Result |
|---|---|
| `xcodebuild test -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO` | `✔ Test run with 300 tests in 33 suites passed` |
| `xcodebuild test -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -only-testing:WaterBuddyUITests -parallel-testing-enabled NO` | `** TEST SUCCEEDED **` — `Executed 25 tests, with 0 failures` (7 `GoalSetupUITests` + 2 template + 16 `testLaunch` launch-configuration runs) |
| `xcodebuild test -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO` | `✔ Test run with 29 tests in 5 suites passed` |
| `xcodebuild build -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'` | `** BUILD SUCCEEDED **` |
| `xcodebuild build -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'` | `** BUILD SUCCEEDED **` |

**Superseding note (final-review fix round, same 2026-09-01 pass):** the table above was re-run in
full after the C1/C2/C3/I5/I7 correctness fixes landed (299/33 phone, up from 292/31; 16/5 watch, up
from 15/5 — see this file's own header for exactly which new tests). Zero new warnings, verified via
a clean-build diff against an isolated worktree rather than an incremental-build grep — the stronger
check this document's own history already argues for, immediately below.

All five: `grep -c "warning:"` over each invocation's own log returned **0**. These were incremental
builds against a `DerivedData` already warm from the prior task's own work, not a forced-clean
rebuild — a caveat this document's own history records matters (Task 2 of this plan found a large,
pre-existing, unrelated warning baseline invisible to an incremental build: 44+ locations in test
macro-expansion code, none touching anything this session changed, since this session changed no
source at all). Zero **new** warnings is the honest claim; zero warnings *anywhere in the codebase*
would need a clean rebuild this pass did not perform.

**The watchOS scheme's name is `WaterBuddyWatchWidget`, with no "Extension" suffix** — unlike the
phone widget's `WaterBuddyWidgetExtension`. Confirmed directly against `xcodebuild -list`, not
assumed by analogy; the plan's own Task 16 ledger records this same discrepancy against its own
brief text.

*(The narrative that follows below — the destination-resolution re-probe, the UI-suite flake, the
per-suite isolation table, and everything through "Still not verified" — describes the 2026-08-31
role-model cascade's own gate run, from before this plan started. Retained as history rather than
rewritten, per rule `90-git`'s "supersede, never rewrite"; its per-suite counts are stale by the
same delta the tables above already correct.)*

**The documented destination resolves again.** The runs above used
`id=7DA32C6F-CED9-4D5F-A093-75A3199D8E2B`, following the standing advice below — but the documented
spelling was then re-probed the way rule `85-testing` requires (by running a test, not by asking
whether it resolves):

```
xcodebuild test … -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' \
  -only-testing:WaterBuddyTests/AppTabTests -parallel-testing-enabled NO
→ ✔ Test run with 6 tests in 1 suite passed
```

`CLAUDE.md` and rule `85-testing` are therefore **correct as written**, and the `id=` workaround is
no longer needed — which matters, because rule `85-testing` explicitly forbids pinning by device id
("resolves nothing on anybody else's machine"). Two iOS runtimes are installed, 18.6 and 26.5, so
pinning the runtime *by number* is more load-bearing than ever. Known issue #9 retired.

**The probe above is a historical record, and its destination is no longer the gate's.** It was run
when `OS=18.6,name=iPhone 16` was the documented pin; rule `85-testing` now pins
`OS=26.5,name=iPhone 17` on iOS and `OS=26.5,name=Apple Watch Series 11 (46mm)` on watchOS, and
those are the destinations every gate figure in this document comes from. The finding the probe
established — that the documented commands resolve as written and the `id=` workaround is
unnecessary — is what survives; the specific runtime number in it does not.

**The UI suite flaked once, and the gate's *order* looks load-bearing.** The first UI run this
session failed `testSettingsIsReachableFromHomeAsATab` with *"Failed to get matching snapshots:
Error getting main window Unknown kAXError value -25218"*. It passed alone, then the full suite
passed 15/15 from a clean `xcrun simctl shutdown all`. The difference was that the failing run had
the widget **build** between the two test invocations rather than last, leaving a booted simulator
the UI suite then tripped over. n=1 on the failure, so this is suspected rather than proven — but
run the gate in the documented order, and shut the simulator down first. Related to known issue #12.

**The test half is three invocations rather than one, and the whole gate is five.** The combined
run exceeds the 600s foreground limit available here, and rule `85-testing` forbids reporting on a
run nobody watched finish — so phone unit, phone UI and watch unit are gated separately, and the two
widget builds separately again because, as the rules have it, no scheme compiles a sibling's
sources (they do — known issue #69; the two builds stay in the gate all the same). *(This paragraph said
"two invocations" until the twenty-sixth pass, which was correct before the watch shipped and stale
for four passes afterwards.)*

- **0 failures** — **300** swift-testing `@Test` functions across **33** suites on
  `WaterBuddyTests`, a further **29** across **5** on `WaterBuddyWatchTests`, plus 10 declared XCTest
  cases in `WaterBuddyUITests` that execute as **25** (`WaterBuddyUITestsLaunchTests.testLaunch`
  runs once per launch configuration: 7 + 2 + 16). The unit runs print
  `✔ Test run with 300 tests in 33 suites passed` and `✔ Test run with 29 tests in 5 suites passed`,
  which only a non-parallel run emits. *(The figures in this bullet read 259/23 and 15 until the
  twenty-sixth pass. The seven that took the count to 259 and the twenty-third suite had arrived with
  the role model — `ProcessRoleTests`, in `WaterSnapshotTests.swift` — which is why that sentence
  existed; it is kept here as the record of where those particular tests came from.)*
- **One compiler warning, and it is pre-existing.** `DataManagerTests.swift:1102`'s
  `@Test(arguments:)` passes a non-`Sendable` `KeyPath<ClosedRange<Int>, Int>` across an isolation
  boundary — *"this is an error in the Swift 6 language mode"*. It fires on every full compile of
  the test module and predates this pass; rule `43-concurrency` documents the family. Known issue
  #8. The previous edition of this document claimed **0 compiler warnings**, which was wrong.
  **This session saw it on the targeted run and not on the full one** — by then the test module was
  already compiled, so `grep -c warning:` over the full unit log returned 0. That is a cache
  artefact, not a fix: the warning is still there. No new warning was introduced.
  (The `appintentsmetadataprocessor` line reporting no `AppIntents.framework` dependency for the
  `WaterBuddyTests` module is expected and is not a compiler warning: `AddWaterIntent` is compiled
  into the extension only. The log also carries transient `FBSOpenApplicationServiceErrorDomain`
  lines from the UI-test runner being retried; the retry succeeds and every case reports.)

| Suite | Cases | Isolation |
|---|---|---|
| `DataManagerTests` + `DailyGoalSetupTests` + `ReminderSeamTests` + `LanguageSeamTests` | 73 `@Test` | `@MainActor` |
| `DaySummaryTests` | 15 `@Test` | **deliberately not `@MainActor`** — the per-day roll-up is a pure transformation over `[WaterLog]` and a `Calendar`; if it ever reached instance state on `DataManager` this suite would stop compiling |
| `HistoryWindowTests` | 6 `@Test` | `@MainActor` — the published `history` window |
| `LocalizationTests` | 13 `@Test` | not `@MainActor` — reads the two built bundles' string tables |
| `ConfettiTests` + `HapticLadderTests` | 10 `@Test` | not `@MainActor` — a seeded burst and three numbers |
| `AuroraLightTests` | 6 `@Test` | not `@MainActor` — the backdrop's three lights |
| `AppLanguageTests` | 8 `@Test` | not `@MainActor` — a provider must be able to read the language |
| `LiquidGlassInteractionTests` | 7 `@Test` | not `@MainActor` — the press multipliers and the tint ceiling |
| `WaterLogStoreTests` | 23 `@Test` | `@MainActor` (a `ModelContext` is main-actor bound here) |
| `HistoryServingTests` | 5 `@Test` | `@MainActor` — the serving editor's offered range |
| `HomeServingTests` | 7 `@Test` | `@MainActor` — the quick-add row's offered vessels |
| `AppTabTests` | 6 `@Test` | **not `@MainActor`** — `AppTab` is top-level, so it has no isolation to inherit |
| `NotificationManagerTests` | 10 `@Test` | not `@MainActor` — reconcile runs in an extension |
| `ReminderPlanTests` | 15 `@Test` | **not `@MainActor`, and no `UserNotifications` import** |
| `WaterSnapshotTests` + `WidgetLanguageTests` | 28 `@Test` | **deliberately not `@MainActor`** |
| `GoalSetupUITests` | 6 XCTest | UI, hosted app — orientation pinned in `setUp` |
| template UI tests | 3 XCTest | UI, hosted app |

`WaterSnapshotTests` being non-isolated is load-bearing, and the SwiftData move did **not** cost
us that canary: the snapshot path still reads only `UserDefaults`, so the suite still compiles
without the main actor. If a future change made the widget's read path touch a `ModelContext`,
this suite would stop compiling — which is exactly the warning we want.

**Verified beyond the gate this run:** the **week card** was rendered on the simulator and read
back, because the unit suite injects its own store and clock and so cannot see a screen at all.

A temporary probe (`ZZHistoryProbe` plus a `-ZZSeedHistory` hook, both **deleted before staging** —
`grep -rn 'ZZ'` across all four targets now returns nothing) back-dated six days of servings through
`addLog(amount:at:)`, the product's own writer, then drove the History tab and captured it at the
default text size and at `UICTContentSizeCategoryAccessibilityXXXL`.

| Check | Result |
|---|---|
| The card draws seven bars, weekdays `M T W T F S S` with today last | yes — today was Sunday 30 August and the rightmost label is `S` |
| The accessibility category actually took hold | the card's frame grew **222.7pt → 478pt**. A silently-ignored category is a real trap here: `…AccessibilityExtraExtraExtraLarge` is *not* a category name and launches at the default size, which `tasks/lessons.md` records as a probe that passed while proving nothing |
| One VoiceOver stop, not fourteen | `app.otherElements.matching(identifier: "Last 7 days").count == 1`, now pinned permanently by `testLoggingAServingRevealsTheWeekCardAsOneElement` |
| Nothing truncates at the largest text size | only after two fixes — see below |

**Two defects that only a render could show**, both introduced by this work and both fixed:

- At `AccessibilityXXXL` the figures line truncated to *"Average 2871 ml · Best…"* and the
  disclosure to *"Measured again…"*. **Different causes.** The first was genuinely too wide for the
  `minimumScaleFactor` floor — a `.footnote` is around 44pt there, and 0.6 of it still overflows the
  pane. The second was **vertical** compression: the card sits above a `List` in a stack with no
  scroller, so `Text` gave up lines rather than pushing back. Fixed with `ViewThatFits` (row becomes
  column) and `fixedSize(horizontal:vertical:)` respectively.
- The disclosure caption at `white.opacity(0.55)` measured **4.06:1** against a 4.5:1 small-text
  floor, and the weekday captions at `0.60` measured **exactly 4.50:1** — the floor itself, with no
  margin under an aurora that moves continuously. Now `0.70` (5.49:1) and `0.72` (5.70:1).

**And one the adversarial review found after that.** A seven-surface rule-compliance review of the
diff, three refuters per candidate, produced **8 candidates and confirmed 0** — but two refutations
were 2-of-3 splits, and in both the dissenter was right:

- The bars were a `Aurora.blue` → `Aurora.cyan` gradient, published in `docs/DESIGN.md` at
  "3.33:1 at the blue end". That figure was sampled off a real rendered bar and was still wrong:
  a short bar's pixels are the *average* of the gradient, not its endpoint. Pure `Aurora.blue`
  composites to **2.72:1**, under the 3:1 non-text floor. The bars are now solid `Aurora.cyan`
  (**5.22:1**).
- `theDailyTotalSaturatesRatherThanTrappingOnACorruptRow` fed `[Int.max, 500]` and never reached the
  overflow branch: `0 + Int.max` does not overflow, so the clamp alone gave the right answer and the
  test passed even with a plain `+`. `aCorruptRowArrivingSecondSaturatesInsteadOfTrapping` covers the
  ordering that actually traps.

**A split verdict is not a refutation** — recorded in `tasks/lessons.md`.

**From a previous pass:** the interactive glass was **measured, not asserted**. A real
mid-press frame was captured (the press blocks the test thread, so the screenshot had to come from
another queue while the finger was still down) and sampled on bands inside the vessel in both the
resting and the scaled-to-0.93 pressed state:

| Region | at rest | pressed | change |
|---|---|---|---|
| glass left of the glyph | 84.6 | **91.3** | **+7.9%** |
| glass right of the glyph | 78.8 | **83.2** | **+5.6%** |
| control — bare backdrop | 86.5 | 86.5 | 0.0% |

The control matters: the aurora is animating, so a number that moved proves nothing until you know
what else moved. The *first* measurement said the button got **darker** — a fixed 120×120 box catches
more dark backdrop once `PressStyle` shrinks the button to 0.93. Recorded in `tasks/lessons.md`.

**From the previous pass:** the language genuinely switches **live**, driven by a
temporary `ZZLanguageProbe` and deleted before staging. In one running process, with no relaunch:
tapping *Русский* replaced `Home · History · Settings` with `Главная · История · Настройки` and
made the English labels *gone* (asserted, not just absent from a screenshot); Home followed, showing
`Стакан, добавить 250 миллилитров`; switching on to *O‘zbekcha* gave `Bosh sahifa`; and *Follow
device* restored English. That last step matters — it proves the picker is a switch and not a
one-way trip.

**Caught by a coverage check, not by a person:** Xcode's build extracts every `Text` / `Label`
literal into the catalogue itself, so the English table is the complete list of what the app can
draw. Comparing it against the Russian table surfaced `Label("Delete", systemImage: "trash")` on the
log's swipe action — no bundle, no translation, and invisible to every other check because it
*looks* fine in English. It is now translated and resolved through the chosen bundle, and
`everyDrawnStringIsTranslatedUnlessDeliberatelyNot` is the guard, with a four-entry allowlist for
the strings that genuinely are not words (`%`, the product name, and two `#Preview` literals).

**Caught before it shipped:** `AppLanguage.english.bundle` resolves `en.lproj`, and a String
Catalogue with `sourceLanguage: en` **emits no `en.lproj`** — the development language lives in the
binary. The resolver would have fallen back to `Bundle.main`, which is not English but *the
device's* language, so choosing English on a Russian phone would have kept drawing Russian. Fixed
by giving every key an explicit `en` value. Written up in `tasks/lessons.md`.

**From the previous pass**, one device, in the five places the suite structurally cannot reach:

- **The three-slot bar renders**, Home stays active with its cyan glow, and
  `testSettingsIsReachableFromHomeAsATab` proves the destination is reachable from *Home* — which
  it was not while Settings was a sheet on the log's header.
- **The aurora genuinely moves, and its resting frame is the old design.** Sampled a 260×260 region
  of backdrop away from the vessel: the static build measured sRGB `(10.8, 96.7, 206.4)`, the
  animated build at rest `(11.2, 96.5, 204.4)`, and seven seconds later `(15.9, 93.0, 175.5)`.
- **Confetti bursts from the vessel** on the crossing tap, and the quick-add row stays `isHittable`
  throughout — so `allowsHitTesting(false)` is doing its job and the celebration cannot eat a tap.
- **The icon is on the Home Screen** and legible at size. `AppIcon.appiconset` held only a
  `Contents.json` before this run, so the app shipped with no icon at all.
- **Russian and Uzbek render**, launched with `-AppleLanguages`: `мл` and
  `Главная · История · Настройки`; `ml` and `Bosh sahifa · Tarix · Sozlamalar`.

Two temporary probes drove the taps — `ZZGoalEditProbe` and `ZZConfettiProbe` — and both were
deleted before staging. `git ls-files --others --exclude-standard` is empty.

**One failure worth carrying forward.** The first `LocalizationTests` compared the two
`.xcstrings` files by reading them off disk with `#filePath`. These tests execute on the
**simulator**, and the repo sits under `~/Desktop`, which macOS protects with TCC — so the read
blocked on a privacy prompt no headless run can answer. It did not fail; it **hung the gate**, twice,
until killed. The rewrite asserts the *built bundles* instead, which is both immune to that and
strictly better: it is what caught the `membershipExceptions` failure, where the source files were
perfectly healthy and the widget shipped English anyway.

**From an earlier pass:** the goal editor was driven on the simulator and the result
read from the **App Group container**, not from the UI — one device, `-parallel-testing-enabled NO`,
by a temporary `ZZGoalEditProbe` deleted before staging.

| Step | `dailyGoal` in the shared suite | `ZWATERLOG` | `isGoalSet` |
|---|---|---|---|
| before | 2,000 | 9 rows / 3,150 ml | `true` |
| drag the card, release | **2,500** | **9 rows / 3,150 ml** — unchanged | `true` |
| second run, drag again | **3,400**, then **2,500** | unchanged | `true` |

So the commit reaches the container the widget reads, a goal edit logs no water, and editing does
not disturb setup. `GoalCard` renders and stays legible at
`UICTContentSizeCategoryAccessibilityXXXL` — label and figure still share one baseline, the slider
stays full-width and `isHittable`, nothing grows through the card.

Two probe bugs are worth knowing, both recorded in `tasks/lessons.md`, because both are traps this
repo will meet again: an assertion querying an accessibility tree the product **deliberately
closed** (`readoutRow` is `.accessibilityHidden(true)`), which could only ever fail while the
product was correct; and `UICTContentSizeCategoryAccessibilityExtraExtraExtraLarge`, which is not a
category — so the app launched at the default size, every assertion passed, and the screenshot
proved nothing.

**The `isGoalSet` bug below was found by a six-agent rule-compliance review of the diff**, one agent
per rule surface, every candidate then handed to two adversarial verifiers instructed to refute it.
Two candidates, one confirmed, one correctly refuted. The confirmed one survived both refuters and
the failing test written from it reproduced the path exactly.

**From the previous pass:** the portrait restriction was proved, not assumed. With the
device forced to `landscapeLeft`, `XCUIApplication().frame` is still `(0, 0, 393, 852)`, the
*History* tab sits at `(198.7, 764, 144.3, 44)` — on screen, full 44pt — and the tap succeeds.
Before the change the same button reported `{{428, 427.7}, {315, 44}}`, off any portrait screen.
The built bundle carries `UISupportedInterfaceOrientations~iphone = [Portrait]` and leaves
`~ipad` at all four.

The iPad run also surfaced a copy bug the phone never showed: `HistoryView`'s empty state still
read *"Tap + on the home screen to log 250 ml"*, naming a button deleted two checkpoints earlier.
It now reads *"Pick a vessel on the Home tab to log your first serving"* and names no amount —
three vessels make naming one of them a different kind of drift. The tab bar also gained a 420pt
width cap, because at 1,120pt wide on an iPad it read as a stretched toolbar rather than a
floating pill.

**From the previous pass:** both tabs were captured from inside the test run —
`simctl` cannot tap, so a temporary probe drove the bar and wrote the screenshots itself. The bar
renders, both destinations swap, `Done` is gone from the log and the gear survives.

**The tab labels' contrast was measured off those pixels, not derived** — the pane is a `Material`
over the aurora and cannot be computed analytically:

| Element | Measured | Floor | |
|---|---|---|---|
| pane itself | sRGB `(0.388, 0.282, 0.484)` | — | |
| active label, white | **7.66:1** | 4.5:1 small text | pass |
| inactive label, white @ 0.72 | **4.89:1** | 4.5:1 small text | pass |
| active glyph, `Aurora.cyan` | **4.34:1** | 3:1 non-text | pass |

The first draft tinted the *label* cyan too, which measured **4.34:1 against a 4.5:1 floor** and
was a real rule `65-accessibility` violation. The glyph keeps the cyan and the glow — an icon is
not text — and the label went white. Nothing but a rendered screenshot would have caught it.

**From the previous pass:** the quick-add row was driven on the simulator and the
result read from the **store**, not from the UI — `tasks/lessons.md` records a session where four
fixes went into a test that was misreading an accessibility value while the product had been
correct every time.

| Step | `ZWATERLOG` | cache `currentWater` |
|---|---|---|
| before | 6 rows, 2,250 ml | — |
| tap Cup, Glass, Bottle once each | **9 rows, 3,150 ml** — three new rows of **150, 250, 500** | **900** |

So each button logs *its own* amount and writes through to the cache the widget reads; the row is
not three copies of one serving. Rendering was checked at the default text size (the row centres,
and all three SF Symbols resolve — a missing one draws nothing at all) and at
`accessibility-extra-extra-extra-large`, where the buttons keep full size and the caption stays
smaller than the glyph it annotates.

**From an earlier pass:** reminders were driven on the simulator, and the pending set
was read from **inside the app's own process** rather than inferred from the UI — the notification
store is `usernotificationsd`'s and is not a readable file, so a probe hosted by the app was the
only ground truth available.

| Step | `UNUserNotificationCenter` pending | Flag |
|---|---|---|
| toggle on, permission granted | **21 requests, all ours** (3 days x 7; today was already past 21:00) | `remindersEnabled = true` |
| toggle off | **0 pending** | `remindersEnabled = false` |

Fire times resolved to the right *local* hour (09:00 shows as 04:00 UTC on this UTC+5 device), and
the copy delivered was value-free. Switching off genuinely clears what is already filed with the
system, which is the failure that would otherwise nag a user for days.

Earlier passes also verified the SwiftData store and cache agreeing after edits and deletes, and
both roots rendering at accessibility text sizes.

**Still not verified:**

- **Everything about real-device behaviour, on either the phone or the watch.** Task 8's paired-
  simulator probe (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §15) is the
  closest this plan came, and it explicitly could not distinguish "the simulator doesn't model
  `WatchConnectivity` delivery" from "the transport genuinely failed" — `sendMessage` never
  succeeded once across 48 attempts there, `isReachable` got stuck asymmetric, and
  `.backgroundTask(.watchConnectivity)` was never observed firing. No part of the automated gate
  exercises a real pairing. **The 2026-10-07 complication change sits entirely on this unverified
  ground:** the phone's push, the background wake that now waits for it, and the face reloading from
  the background. Its pure decisions are tested; the owner's own iPhone and Apple Watch are the check
  (spec 2026-10-07 §8.3, known issue #52), and it has not yet been run.
- **The watch widget's on-face rendering.** No automated coverage exists for widget rendering on
  either platform (rule `85-testing`'s standing note) — the phone widget's Home Screen appearance
  was never re-verified against the watchOS plan's changes (none touched it), and the watch's
  `.accessoryCircular` face has never been placed on a real or simulated watch face and looked at.
  *(2026-10-21, 1.3.2's stage 7c: placed on a simulated one — the circle, the rectangle and the
  corner, by the owner, on Modular and on a tinted Infograph, watchOS 27.0 — and seen turning over at
  midnight; a real watch is still #153.)*
- **Whether a widget extension may reach the notification service at runtime.** This is the one
  thing research could not settle: the *addressing* is proven (an `.appex` resolves through
  `LSPlugInKitProxy.containingBundle`, so its requests land in the app's pending set — established
  by disassembling the shipping framework), but the sandbox permission is not, and kernel sandbox
  profiles cannot be read. Apple denies this same call to Background Assets extensions.
  `AddWaterIntent` attempts it, and `DataManager.refresh()` reconciles on every foreground as the
  backstop, so a denial degrades to "reminders correct themselves next time you open the app"
  rather than to broken. **Placing the widget and tapping it is the test that would close this.**
- **The widget on a Home Screen** — the longstanding gap, and **it now covers more than it did**.
  Since the quick-add vessels became editable, the widget's button face and the amount it logs both
  come from `entry.snapshot.serving` rather than a compiled-in constant.
  `theWidgetsServingIsTheAppsMiddleVessel` proves the value crosses the process boundary; only a
  Home Screen proves it *draws*, and only a tap proves it logs the edited amount rather than 250.
  The route: run the **app** scheme, launch once, add *Hydration* from the gallery, then edit the
  middle vessel in Settings and watch the face. A tinted (templated) configuration is unseen too.
- **The midnight language fix, end to end.** `rolledOver()` is unit-tested and the old bug is
  understood, but nobody has watched a real widget cross local midnight and keep its language.
- **Reduce Transparency on `HistoryView`/`SettingsView`** — `simctl ui reduce_transparency` is not a
  supported option on this Xcode, so the path has not been seen.
- **Goal-met silencing, on device.** Covered by `ReminderPlanTests` and `ReminderSeamTests`, but the
  device run happened after 21:00 when today was empty anyway, so it was not independently exercised.

### Git

**Read at 17:20 on 2026-10-24, in set A's step 5's records and the eighty-ninth pass, after their `git add`
of 20 files by name: `ad244c2`, 180 commits, level with `origin/main`; 20 staged — 14 modified, 6 added —
15 unstaged, 1 untracked entry, none in both.** Staged: the step's eleven code and test files, its spec
and plan, `CLAUDE.md`, this file, `docs/STATE.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, `tasks/lessons.md`
and `HISTORY.md`. Unstaged: the nine rule files carrying the step's wording, for the owner; and, from
before the session and not this step's, `.claude/settings.json` (the owner's permission edit), two watch
schemes (Xcode dropped a `BlueprintName`) and three string catalogues Xcode re-wrote —
`WaterBuddy/AppShortcuts.xcstrings`, whose Siri phrases it marked `"extractionState" : "stale"`, worth a
look before anyone stages it. Untracked: `Screenshots/census/`. This file and `HISTORY.md` are added again
once their blocks are written. No `git commit` in this session.

**Read at 14:14 on 2026-10-24, in the eighty-eighth pass, after its `git add` of its four files by name:
`5b511bd`, 176 commits, level with `origin/main`; 21 staged — 16 modified, 5 added — 16 unstaged, 1
untracked entry, none in both.** The same sets as the block below: this pass's files — `docs/STATE.md`,
this file, `tasks/lessons.md`, `HISTORY.md` — were already staged by step 4's records. This file and
`HISTORY.md` are added again once their blocks are written. No `git commit` in this session.

**Read at 02:08 on 2026-10-24, in the eighty-seventh pass, after its `git add` of its five files by name:
`5b511bd`, 176 commits, level with `origin/main`; 21 staged — 16 modified, 5 added — 16 unstaged, 1
untracked entry, none in both.** The same sets as the block below: this pass's files — `CLAUDE.md`, this
file, `docs/DESIGN.md`, `tasks/lessons.md`, `HISTORY.md` — were already staged by step 4's records. This
file and `HISTORY.md` are added again once their blocks are written. No `git commit` in this session.

**Read at 02:04 on 2026-10-24, in set A's step 4's records, after its `git add` of its 21 files by name:
`5b511bd`, 176 commits, level with `origin/main`; 21 staged — 16 modified, 5 added — 16 unstaged, 1
untracked entry, none in both.** Staged: step 4's code and tests — `DataManager.swift`,
`HistoryView.swift`, `WaterBuddy/Localizable.xcstrings`, `PremiumSet.swift`, `RootTabView.swift`,
`WaterBuddyApp.swift`, `LocalizationTests.swift`, `PremiumSetTests.swift`, `PremiumUITests.swift`, and
`InsightCopy.swift`, `InsightWriter.swift`, `InsightCopyTests.swift`, `WeekInsightsTests.swift`, added;
its spec, added; and the records — `CLAUDE.md`, this file, `docs/STATE.md`, `docs/DESIGN.md`,
`docs/ROADMAP.md`, `tasks/lessons.md` and `HISTORY.md`. Unstaged: the ten rule files carrying step 4's
wording, for the owner; `.claude/settings.json` (the owner's); and five of Xcode's rewrites (#50).
Untracked: `Screenshots/census/`. Step 3 and its records were committed before this step began
(`3e17651`, `d9e7db7`, `c0c6705`, `5b511bd`). This file and `HISTORY.md` are added again once their
blocks are written. No `git commit` in this session.

**Read at 22:47 on 2026-10-23, in the eighty-sixth pass, after its `git add` of its five files by name:
`24b2de4`, 172 commits, level with `origin/main`; 15 staged — 13 modified, 2 added — 10 unstaged, 1
untracked entry, none in both.** The same sets as the block below: this pass's files — this file,
`docs/STATE.md`, `docs/DESIGN.md`, `tasks/lessons.md`, `HISTORY.md` — were already staged by step 3's
records. This file and `HISTORY.md` are added again once their blocks are written. No `git commit` in
this session.

**Read at 22:42 on 2026-10-23, in set A's step 3's records, after its `git add` of its fifteen files by
name: `24b2de4`, 172 commits, level with `origin/main`; 15 staged — 13 modified, 2 added — 10 unstaged,
1 untracked entry, none in both.** Staged: step 3's code and tests — `DataManager.swift`,
`HistoryView.swift`, `WaterBuddy/Localizable.xcstrings`, `HistoryViewTests.swift`,
`LocalizationTests.swift`, `MonthHistoryTests.swift`, and `MonthPatternsTests.swift`, added; its spec,
added; and the records — `CLAUDE.md`, this file, `docs/STATE.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`,
`tasks/lessons.md` and `HISTORY.md`. Unstaged: the four rule files carrying step 3's wording
(`30-rollover`, `43-concurrency`, `50-views`, `85-testing`), for the owner; `.claude/settings.json` (the
owner's); and five of Xcode's rewrites (#50). Untracked: `Screenshots/census/`. Step 2 — everything the
eighty-fifth pass staged, and its rule wording — was committed before this step began, as `9fcdc48`,
`40e7e41`, `95c343d` and `24b2de4`. This file and `HISTORY.md` are added again once their blocks are
written. No `git commit` in this session.

**Read at 19:50 on 2026-10-23, in the eighty-fifth pass, after its `git add` of its five files by name:
`2e2f3a7`, 168 commits, level with `origin/main`; 18 staged — 17 modified, 1 added — 12 unstaged, 1
untracked entry, none in both.** The same sets as the block below: this pass's files —
`CLAUDE.md`, `docs/AI_CONTEXT.md`, `docs/STATE.md`, `tasks/lessons.md`, `HISTORY.md` — were already
staged by Task 10. This file and `HISTORY.md` are added again once their blocks are written. No `git
commit` in this session.

**Read at 01:52 on 2026-10-23, in set A's step 2's Task 10, after its `git add` of its records by
name: `2e2f3a7`, 168 commits, level with `origin/main`; 18 staged — 17 modified, 1 added — 12
unstaged, 1 untracked entry, none in both.** Staged: step 2's code and tests — `DataManager.swift`,
`HistoryView.swift`, `PaywallView.swift`, `WaterBuddy/Localizable.xcstrings`, `HistoryViewTests.swift`,
`LocalizationTests.swift`, `PremiumUITests.swift`, and `MonthHistoryTests.swift`, added; the spec's and
the plan's dated amendments; and the records — `CLAUDE.md`, `docs/AI_CONTEXT.md`, `docs/STATE.md`,
`docs/DESIGN.md`, `docs/WIDGET.md`, `docs/ROADMAP.md`, `tasks/lessons.md` and `HISTORY.md`. Unstaged: the
six rule files carrying step 2's wording (`20-state`, `30-rollover`, `43-concurrency`, `50-views`,
`60-design-system`, `85-testing`), for the owner; `.claude/settings.json` (the owner's); and five of
Xcode's rewrites (#50) — the `WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes,
`WaterBuddy/AppShortcuts.xcstrings` and the watch's and the watch widget's catalogues. Untracked:
`Screenshots/census/`. This file and `HISTORY.md` are added again once their blocks are written. No
`git commit` in this session.

**Read at 13:18 on 2026-10-22, in the eighty-fourth pass, after its `git add` of its seven files by
name: `a6e287b`, 166 commits, level with `origin/main`; 9 staged — 7 modified, 2 added — 6 unstaged,
1 untracked entry, none in both.** Staged: step 2's spec and plan, added; and this pass's
`docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`,
`tasks/lessons.md` and `HISTORY.md`. Unstaged: `.claude/settings.json` (the owner's) and five of Xcode's
rewrites (#50) — the `WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes,
`WaterBuddy/AppShortcuts.xcstrings` and the watch's and the watch widget's catalogues. Untracked:
`Screenshots/census/`. Step 1 — everything the eighty-first pass staged, and its rule wording — was
committed since that pass, as `4577d92`, `d5cf816`, `fd12b7f` and `a6e287b`. This file and `HISTORY.md`
are added again once their blocks are written. No `git commit` in this session.

**Read at 00:42 on 2026-10-22, in the eighty-first pass, after its `git add` of its eight files by
name: `b981374`, 162 commits, level with `origin/main`; 27 staged — 21 modified, 6 added — 11
unstaged, 1 untracked entry, none in both.** Staged: everything the eightieth pass staged (1.4.1's
Task 6 and its review fix, step 1's spec and plan); step 1's Tasks 3–7 — `PremiumRim.swift` and
`PremiumSetTests.swift` added, `PremiumAccess.swift`, `PremiumSet.swift`, `PremiumStore.swift`,
`PaywallView.swift` (added since the eightieth pass, rewritten), `SettingsView.swift`,
`WaterBuddyApp.swift`, `WaterBuddy/Localizable.xcstrings`, `WaterBuddyTests/WaterBuddy.storekit`,
`PremiumAccessTests.swift`, `PremiumStoreTests.swift`, `LocalizationTests.swift` and
`PremiumUITests.swift` (added since the eightieth pass, rewritten); and this pass's `CLAUDE.md`,
`docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, `tasks/lessons.md`,
`HISTORY.md` and this file. Unstaged: the four rule files carrying step 1's wording (`43-concurrency`,
`60-design-system`, `70-privacy`, `85-testing`), for the owner; `.claude/settings.json` (the owner's);
the `WaterBuddy` scheme the owner edited in Xcode (#163 — step 1's Task 9 cleans and stages it); and
five of Xcode's rewrites (#50) — the `WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes,
`WaterBuddy/AppShortcuts.xcstrings` and the watch's and the watch widget's catalogues. Untracked:
`Screenshots/census/`. This file and `HISTORY.md` are added again once their blocks are written. No
`git commit` in this session.

**Read at 23:08 on 2026-10-21, in the eightieth pass, after its `git add` of its eight files by name:
`b981374`, 162 commits, level with `origin/main`; 20 staged — 16 modified, 4 added — 7 unstaged, 1
untracked entry, none in both.** Staged: 1.4.1's Task 6 and its review fix — `PaywallView.swift` and
`PremiumUITests.swift` added, `SettingsView.swift`, `WaterBuddyApp.swift`, `RootTabView.swift`,
`HomeView.swift`, `DataManager.swift`, `PremiumStore.swift`, `PremiumAccessTests.swift` and
`PremiumStoreTests.swift` modified; step 1's spec and plan, added; and this pass's `CLAUDE.md`,
`docs/STATE.md`, `docs/WIDGET.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, `tasks/lessons.md`,
`HISTORY.md` and this file. Unstaged: `.claude/settings.json` (the owner's); the `WaterBuddy` scheme
the owner edited in Xcode (the StoreKit configuration, the launch argument, and the stray environment
variable — step 1's Task 9 cleans and stages it); and five of Xcode's rewrites (#50) — the
`WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes, `WaterBuddy/AppShortcuts.xcstrings` and the
watch's and the watch widget's catalogues. Untracked: `Screenshots/census/`. This file and
`HISTORY.md` are added again once their blocks are written. No `git commit` in this session.

**Read at 14:55 on 2026-10-21, in the seventy-ninth pass, after its `git add` of its six files by
name: `0be24f9`, 158 commits, level with `origin/main`; 16 staged — 8 modified, 8 added — 12
unstaged, 1 untracked entry, none in both.** Staged: 1.4.1's roadmap amendment, spec and plan; its
Tasks 3–5 — `PremiumAccess.swift`, `PremiumSet.swift`, `PremiumStore.swift`,
`WaterBuddy/Localizable.xcstrings`, `WaterBuddyTests/WaterBuddy.storekit`, `PremiumAccessTests.swift`,
`PremiumStoreTests.swift`, `LocalizationTests.swift`; and this pass's `CLAUDE.md` (its warning trail,
and the spec's §5 *Architecture* bullet typed in Task 2), `docs/STATE.md`, `tasks/lessons.md`,
`HISTORY.md` and this file. Unstaged: the seven rule files carrying the spec's §5 wording, for the
owner; `.claude/settings.json` (the owner's); and four of Xcode's rewrites (#50) — the
`WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes, `WaterBuddy/AppShortcuts.xcstrings` and the
watch's catalogue. Untracked: `Screenshots/census/`. 7c and its doc sync were committed as `5194121`
and `0be24f9`. This file and `HISTORY.md` are added again once their blocks are written. No `git
commit` in this session.

**Read at 12:19 on 2026-10-21, in the seventy-eighth pass, after its `git add` of its six files by
name: `3d1cda8`, 156 commits, level with `origin/main`; 14 staged — 13 modified, 1 added — 5
unstaged, 1 untracked entry, none in both.** Staged: 7c's eleven (below) and this pass's `CLAUDE.md`,
`docs/STATE.md` and `docs/DESIGN.md`. Unstaged: `.claude/settings.json` (the owner's), and four of
Xcode's rewrites (#50) — the `WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes,
`WaterBuddy/AppShortcuts.xcstrings` and the watch's catalogue. Untracked: `Screenshots/census/`. This
file and `HISTORY.md` are added again once their blocks are written. No `git commit` in this pass.

**Read at 01:48 on 2026-10-21, in 1.3.2's stage 7c, after its last `git add` of its files by name:
`3d1cda8`, 156 commits, level with `origin/main`; 11 staged — 10 modified, 1 added — 5 unstaged, 1
untracked entry, none in both.** Staged: 7c's four code and test files (`WristFaceView.swift`
added), and `HISTORY.md`, this file, `docs/ROADMAP.md`, `docs/WIDGET.md`, the spec, the plan and
`tasks/lessons.md`. Unstaged: `.claude/settings.json` (the owner's), and four of Xcode's rewrites
(#50) — the `WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes, `WaterBuddy/AppShortcuts.xcstrings`
and the watch's catalogue; the fifth, the watch widget's catalogue, was restored to `HEAD` before 7c
edited it. Untracked: `Screenshots/census/`. 7b and its records were committed as `af388da` and
`3d1cda8`. This file and `HISTORY.md` are added again once their blocks are written. No `git commit`
was run.

**Read at 18:13 on 2026-10-20, in the seventy-seventh pass, after its `git add` of its five files by
name: `ca43a60`, 154 commits, level with `origin/main`; 20 staged — 19 modified, 1 added — 6
unstaged, 1 untracked entry, 1 in both.** Staged: 7b's eighteen (below) and this pass's `CLAUDE.md`
and `docs/STATE.md`. Unstaged: `.claude/settings.json` (the owner's), and Xcode's rewrites of five
files once WaterBuddy was opened in it (#50) — the `WaterBuddyWatch` and `WaterBuddyWatchWidget`
schemes, `WaterBuddy/AppShortcuts.xcstrings`, and the watch's and the watch widget's catalogues. In
both: `WaterBuddyWatch/Localizable.xcstrings` — the index holds 7b's, the tree Xcode's. Untracked:
`Screenshots/census/`. This file and `HISTORY.md` are added again once their blocks are written. No
`git commit` in this pass.

**Read at 18:07 on 2026-10-20, in 1.3.2's stage 7b, after its last `git add` of its files by name
(the review's fix and the corrected records; first read at 17:42, the same counts):
`ca43a60`, 154 commits, level with `origin/main`; 18 staged — 17 modified, 1 added — 1 unstaged, 1
untracked entry, none in both.** Staged: 7b's eleven code and test files (`WristColumn.swift`
added), and `HISTORY.md`, this file, `docs/DESIGN.md`, `docs/ROADMAP.md`, the spec, the plan and
`tasks/lessons.md`. Unstaged: `.claude/settings.json` (the owner's). Untracked: `Screenshots/census/`.
This file and `HISTORY.md` are added again once their blocks are written. No `git commit` was run.

**Read at 14:39 on 2026-10-20, in the seventy-sixth pass, after its `git add` of its four files by
name: `ff7305b`, 151 commits, level with `origin/main`; 13 staged — 12 modified, 1 added — 7
unstaged, 1 untracked entry, none in both.** Staged: 7a's eleven (below) and this pass's `CLAUDE.md`
and `docs/WIDGET.md`. Unstaged: the six rule files with spec §5's approved wording, for their own
commit, and `.claude/settings.json` (the owner's). Untracked: `Screenshots/census/`. This file and
`HISTORY.md` are added again once their blocks are written. No `git commit` in this pass.

**Read at 14:26 on 2026-10-20, in 1.3.2's stage 7a, after its `git add` of its files by name:
`ff7305b`, 151 commits, level with `origin/main`; 11 staged — 10 modified, 1 added — 7 unstaged, 1
untracked entry, none in both.** Staged: 7a's four Swift files (`WristGlassTests.swift` added), and
`HISTORY.md`, this file, `docs/DESIGN.md`, `docs/ROADMAP.md`, the spec, the plan and
`tasks/lessons.md`. Unstaged: the six rule files with spec §5's approved wording, for their own
commit, and `.claude/settings.json` (the owner's). Untracked: `Screenshots/census/`. The seventy-fifth
pass's eight were committed as `91fdbfa` and `ff7305b`. This file and `HISTORY.md` are added again
once their blocks are written. No `git commit` in this session.

**Read at 12:39 on 2026-10-20, in the seventy-fifth pass, after its `git add` of its eight files by
name: `06229be`, 149 commits, level with `origin/main`; 8 staged — 6 modified, 2 added — 1 unstaged, 1
untracked entry, none in both.** Staged: this pass's `CLAUDE.md`, this file, `docs/ROADMAP.md`, the
redesign spec's status note, `tasks/lessons.md` and `HISTORY.md`, and roadmap item 1.3.2's spec and
plan (added). Unstaged: `.claude/settings.json` (the owner's). Untracked: `Screenshots/census/`. 1.3.1
and its records were committed after the seventy-fourth pass: `fb1af96`, `cdc53da`, `06229be`. This
file and `HISTORY.md` are added again once their blocks are written. No `git commit` in this pass.

**Read at 21:43 on 2026-10-19, in the seventy-third pass, after its `git add` of its six files by
name: `5a46609`, 144 commits, level with `origin/main`; 18 staged, all modified, 6 unstaged, 1
untracked entry, none in both.** Staged: roadmap item 1.3.1's approved rule wording in ten
`.claude/rules/` files; stage 6b — `WaterBuddyWidget/WaterBuddyWidget.swift`, `tasks/lessons.md` —
and this pass's `CLAUDE.md`, this file, `docs/WIDGET.md`, `docs/DESIGN.md`, `docs/ROADMAP.md` and
`HISTORY.md`, which carries 6b's checkpoint and this pass's. Unstaged: `.claude/settings.json` (the
owner's), the two watch schemes, and the three catalogues Xcode rewrote (#50; D1 restores all five
before 6c). Untracked: `Screenshots/census/`. 1.3.4 and its records, staged at the block below, were
committed at 23:40 on 2026-10-18 (`4a7ece7`..`41309e3`); 1.3.1's spec and plan and its stage 6a at
20:22 today (`1899aba`, `5a46609`). No `git commit` in this pass.

**Read at 23:36 on 2026-10-18, in the seventy-second pass, after its `git add` of its six files by
name: `88d694f`, 138 commits, level with `origin/main`; 22 staged, 6 unstaged, 1 untracked entry, and
one path in both.** Staged: roadmap item 1.3.4 — `WaterBuddy/TodaysWaterIntent.swift` and
`WaterBuddyTests/TodaysWaterTests.swift` (added), `DataManager.swift`, `WaterBuddyShortcuts.swift`,
`Localizable.xcstrings`, `AppShortcuts.xcstrings`, `LocalizationTests.swift`, `SiriPhraseTests.swift`,
the five rule files with the approved wording, the spec and the plan (added), `tasks/lessons.md` — and
this pass's `CLAUDE.md`, this file, `docs/STATE.md`, `docs/WIDGET.md`, `docs/ROADMAP.md`,
`HISTORY.md`. Unstaged: `.claude/settings.json` (the owner's), the two watch schemes, and the three
catalogues the open Xcode rewrote again (#50). **In both: `WaterBuddy/AppShortcuts.xcstrings`** — the
index holds 1.3.4's reviewed six phrases, the working tree Xcode's rewrite of them; a `git add` of it
would stage the rewrite. Untracked: `Screenshots/census/`. 1.2.8 and its records, staged at the block
below, were committed at 20:33 (`eecb6a7`..`88d694f`). No `git commit` in this pass.

**Read at 20:12 on 2026-10-18, in the seventieth pass, after its `git add` of its five files by
name: `93d23df`, 134 commits, level with `origin/main`; 13 staged, 6 unstaged, 1 untracked entry,
none in both** — the same 13, 6 and 1 as the block below; the pass's five (`CLAUDE.md`, this file,
the plan, `tasks/lessons.md`, `HISTORY.md`) were already among the 13 and are re-staged. No
`git commit`.

**Read at 15:53 on 2026-10-18, in the sixty-ninth pass, after its `git add` of its four files by
name: `93d23df`, 134 commits, level with `origin/main`; 13 staged, 6 unstaged, 1 untracked entry,
none in both.** Staged: roadmap item 1.2.8 — `WaterBuddyUITests/AppStoreScreenshotUITests.swift`,
`Tools/CaptureScreenshots.sh`, `.claude/rules/85-testing.md`, the four PNGs in
`Screenshots/en-US/iPhone-6.9/`, `docs/superpowers/plans/2026-10-18-store-screenshots.md` (added),
`tasks/lessons.md` — and `HISTORY.md`, `CLAUDE.md`, this file, `docs/ROADMAP.md`. Unstaged:
`.claude/settings.json` (the owner's) and the five files the open Xcode app rewrites (#50). Untracked:
`Screenshots/census/`. The lag fix and the sixty-seventh and sixty-eighth passes, staged at the blocks
below, were committed at 13:50–13:51 (`b1bbbc3`..`93d23df`). No `git commit` in this pass.

**Read at 12:03 on 2026-10-17, in the sixty-fifth pass, after its last `git add` of its five files by
name: `52ee815`, 126 commits, level with `origin/main`; 5 staged, 6 unstaged, 1 untracked entry, none
in both** — the same five, six and one as the block below. No `git commit` between the two passes, and
none in this one. The block below says the blocks under it are 1.2.5's staging. They are 1.2.4's, at
`6010e25`, and 1.2.4's records were committed as `2d233e1` to `450d76f`. 1.2.5's staging was read only in
`HISTORY.md`, at 17:41 on 2026-10-15 and at 10:02 on 2026-10-16. It was committed as `5241030`,
`86a44ed`, `314d63a` and `52ee815`.

**Read at 12:34 on 2026-10-16, in the sixty-fourth pass, after its `git add` of its five files by
name: `52ee815`, 126 commits, level with `origin/main`; 5 staged, 6 unstaged, 1 untracked entry, none
in both.** Staged: 1.2.6's spec, `docs/superpowers/specs/2026-10-16-plural-forms-design.md` (added),
and this pass's `HISTORY.md`, `docs/AI_CONTEXT.md`, `docs/ROADMAP.md`, `tasks/lessons.md`. Unstaged:
the six from before (`.claude/settings.json`, the two watch schemes, `WaterBuddy/AppShortcuts.xcstrings`,
`WaterBuddyWatch/Localizable.xcstrings`, `WaterBuddyWatchWidget/Localizable.xcstrings`). Untracked:
`Screenshots/census/`. 1.2.5's records, staged at the blocks below, were committed by the owner
between passes (`5241030`..`52ee815`). No `git commit`.

**Read at 13:53 on 2026-10-15, in the sixty-first pass, after its `git add` of its five files by name:
`6010e25`, 118 commits, level with `origin/main`; 18 staged, 10 unstaged, 1 untracked entry, none in
both.** The same 18 and 10 as the block below — the pass's five files (`HISTORY.md`,
`docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/WIDGET.md`, `tasks/lessons.md`) were already among the 18
and are re-staged. No `git commit`.

**Read at 13:42 on 2026-10-15, by the session that built roadmap item 1.2.4, after its `git add` of
18 paths by name: `6010e25`, 118 commits, level with `origin/main`; 18 staged, 10 unstaged, 1
untracked entry, none in both.** Staged: `CLAUDE.md`, `HISTORY.md`, `tasks/lessons.md`,
`docs/AI_CONTEXT.md`, `docs/ROADMAP.md`, `docs/STATE.md`, `docs/WIDGET.md`, the spec and plan
`docs/superpowers/{specs,plans}/2026-10-15-log-from-a-reminder*` (added), `WaterBuddy/DataManager.swift`,
`LogServingIntent.swift`, `NotificationManager.swift`, `ReminderResponder.swift` (added),
`WaterBuddyApp.swift`, and `WaterBuddyTests/DataManagerTests.swift`, `LocalizationTests.swift`,
`NotificationManagerTests.swift`, `WelcomeTests.swift`. Unstaged: rules `43-concurrency`,
`70-privacy`, `80-notifications`, `85-testing` (1.2.4's wording, for the owner), and the six from
before (`.claude/settings.json`, the two watch schemes, `WaterBuddy/AppShortcuts.xcstrings`,
`WaterBuddyWatch/Localizable.xcstrings`, `WaterBuddyWatchWidget/Localizable.xcstrings`). Untracked:
`Screenshots/census/`. No `git commit`.

**Read at 23:38 on 2026-10-14, in the sixtieth pass, after its `git add` of its five files by name:
`1438122`, 114 commits, level with `origin/main`; 32 staged, 12 unstaged, 1 untracked entry, none in
both.** The same 32 and 12 as the block below — the pass's five files (`HISTORY.md`,
`docs/AI_CONTEXT.md`, `docs/DESIGN.md`, `docs/STATE.md`, `tasks/lessons.md`) were already among the
32 and are re-staged. No `git commit`.

```
$ git rev-parse --short HEAD
1438122
$ git log --oneline | wc -l
     114
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      32
$ git diff --name-only | wc -l
      12
$ git status --porcelain | grep -c '^??'
1
```

The fifty-ninth pass's block, kept. **Read at 23:17 on 2026-10-14, in the fifty-ninth pass, after its `git add` of its six files by
name: `1438122`, 114 commits, level with `origin/main`; 32 staged, 12 unstaged, 1 untracked entry,
none in both.** The same 32 and 12 as the block below — the pass's six files (`CLAUDE.md`,
`HISTORY.md`, `docs/AI_CONTEXT.md`, `docs/DESIGN.md`, `docs/STATE.md`, `docs/WIDGET.md`) were
already among the 32 and are re-staged; its one-sentence correction to the typed rule `50-views`
wording stays unstaged with the other five rule files, for the owner. No `git commit`.

```
$ git rev-parse --short HEAD
1438122
$ git log --oneline | wc -l
     114
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      32
$ git diff --name-only | wc -l
      12
$ git status --porcelain | grep -c '^??'
1
```

The stage's block, kept. **Read at 22:42 on 2026-10-14, after the redesign's stage 5 and its records were staged by name:
`1438122`, 114 commits, level with `origin/main`; 32 staged, 12 unstaged, 1 untracked entry, none
in both.** The 32 are the stage's code, strings, tests and two tool scripts (22,
`GoalSetupView.swift`'s deletion among them), its spec and plan, and the eight records — `CLAUDE.md`, `HISTORY.md`,
`docs/AI_CONTEXT.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, `docs/STATE.md`, `docs/WIDGET.md`,
`tasks/lessons.md`. The 12 unstaged are the six rule files with stage 5's wording, for the owner's
yes (`.claude/rules/10-architecture.md`, `43-concurrency.md`, `50-views.md`, `70-privacy.md`,
`80-notifications.md`, `85-testing.md`), and the six from before: `.claude/settings.json`, two watch
schemes, three string catalogues. The untracked entry is `Screenshots/census/`. No `git commit`.

```
$ git rev-parse --short HEAD
1438122
$ git log --oneline | wc -l
     114
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      32
$ git diff --name-only | wc -l
      12
$ git status --porcelain | grep -c '^??'
1
```

The block before, kept. **Read at 09:42 on 2026-10-14, after the owner approved stage 4's rule wording and the three rule
files were staged by name: `c9d1f6b`, 110 commits, level with `origin/main`; 16 staged, 6
unstaged, 1 untracked entry, none in both.** The 16 are the block below's 13 and
`.claude/rules/50-views.md`, `60-design-system.md` and `65-accessibility.md`; the 6 unstaged are
the six from before the stage's session. No `git commit`.

```
$ git diff --cached --name-only | wc -l
      16
$ git diff --name-only | wc -l
       6
$ git status --porcelain | grep -c '^??'
1
```

The fifty-eighth pass's block, kept. **Read in the fifty-eighth pass at 07:38 on 2026-10-14, from the commands themselves, after its
`git add` of its eight files by name: `c9d1f6b`, 110 commits, level with `origin/main`; 13 staged,
9 unstaged, 1 untracked entry, none in both.** The 13 staged are the stage's 10 (below) and the
three sheets this pass first touched: `CLAUDE.md`, `docs/STATE.md`, `docs/WIDGET.md`. The 9
unstaged are the same nine: the three rule files with stage 4's wording, for the owner's yes, and
the six from before. The untracked entry is `Screenshots/census/`. No `git commit`.

```
$ git rev-parse --short HEAD
c9d1f6b
$ git log --oneline | wc -l
     110
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      13
$ git diff --name-only | wc -l
       9
$ git status --porcelain | grep -c '^??'
1
```

The stage's block, kept. **Read at 00:26 on 2026-10-14, after the redesign's stage 4 was staged: `c9d1f6b`, 110 commits,
level with `origin/main`; 10 staged, 9 unstaged, 1 untracked entry, none in both.** The 10 staged
are stage 4's: `WaterBuddy/SettingsView.swift`, `WaterBuddy/Localizable.xcstrings`,
`WaterBuddyTests/LocalizationTests.swift`, `WaterBuddyUITests/GoalSetupUITests.swift`, its plan,
`docs/AI_CONTEXT.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, `HISTORY.md`, `tasks/lessons.md`. The 9
unstaged are the three rule files with stage 4's wording, for the owner's yes
(`.claude/rules/50-views.md`, `60-design-system.md`, `65-accessibility.md`), and the six from before:
`.claude/settings.json`, two watch schemes, three string catalogues. The untracked entry is
`Screenshots/census/`. No `git commit`.

```
$ git rev-parse --short HEAD
c9d1f6b
$ git log --oneline | wc -l
     110
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      10
$ git diff --name-only | wc -l
       9
```

The block from before stage 3c's commit, kept. **There is a git repository.** **Read at 16:32 on 2026-10-13, after the owner approved stage 3c's
rule wording and the two rule files were staged by name: `684f3dd`, 104 commits, level with
`origin/main`; 22 staged, 6 unstaged, 1 untracked entry, none in both.** The 22 are the block
below's 20 and `.claude/rules/60-design-system.md` and `65-accessibility.md`; the 6 unstaged are
the six from before the stage's session. No `git commit`.

```
$ git diff --cached --name-only | wc -l
      22
$ git diff --name-only | wc -l
       6
$ git status --porcelain | grep -c '^??'
1
```

The fifty-seventh pass's block, kept. **Read in the fifty-seventh pass at 16:05 on 2026-10-13, from the
commands themselves, after its last `git add`: `684f3dd`, 104 commits, level with `origin/main`;
20 staged, 8 unstaged, 1 untracked entry, none in both.** Stage 3 and 3b were committed and pushed
that morning, `e0762ab` to `684f3dd`. The 20 staged are stage 3c's 17 (its code, tests, spec, plan
and records, and — their own change — the App Store header, its HTML source and
`docs/ROADMAP.md`) and the three sheets this pass first touched: `CLAUDE.md`, `docs/STATE.md`,
`docs/WIDGET.md`. The 8 unstaged are the two rule files with stage 3c's wording, for the owner's
yes (#126), and six from before the stage's session: `.claude/settings.json`, two watch schemes,
three string catalogues. The untracked entry is `Screenshots/census/`. This pass ran `git add`
on its seven files by name, and no `git commit`.

```
$ git rev-parse --short HEAD
684f3dd
$ git log --oneline | wc -l
     104
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      20
$ git diff --name-only | wc -l
       8
$ git status --porcelain | grep -c '^??'
1
```

The fifty-sixth pass's block, kept. **Read in the fifty-sixth pass at 08:35 on 2026-10-13, from the
commands themselves: `e16221e`, 96 commits, level with `origin/main`; 18 staged, 27 unstaged,
17 untracked, 10 in both — the counts of the blocks below. The index is still the tree
`8c1afc06daceaef1476c9425bc1d6bc303f0f171`, the one gated by itself that night.** That pass
wrote `docs/AI_CONTEXT.md`, `tasks/lessons.md` and `HISTORY.md`, each already unstaged, and
ran no `git add` and no `git commit`; `git write-tree` during `/commit` had written eight tree
objects under `.git`.

The fifty-fifth pass's block, kept. **Read in the fifty-fifth pass at 23:24 on 2026-10-12, from the
commands themselves: `e16221e`, 96 commits, level with `origin/main`; 18 staged, 27 unstaged,
17 untracked, 10 in both — the counts of the two blocks below.** That pass wrote
`docs/AI_CONTEXT.md`, `docs/DESIGN.md`, `HISTORY.md`, `tasks/lessons.md` and the second pass's
spec and plan, each already unstaged or untracked, and ran no `git add` and no `git commit`.

The fifty-fourth pass's block, kept as that pass wrote it; its "after its last edit" was
saved before that pass's last edits to other documents (reader E), and its counts were right.
**Read last in the fifty-fourth pass (2026-10-12), from the
commands themselves, after its last edit: nothing differs from the fifty-third's block
below.** `e16221e`, 96 commits, level with `origin/main`; 18 staged, 27 unstaged, 17
untracked, 10 in both, and the unstaged and untracked lists are the same paths. Every file
this pass wrote was already unstaged or untracked — `docs/AI_CONTEXT.md`, `docs/DESIGN.md`,
`HISTORY.md`, `tasks/lessons.md`, and stage 3b's two specs and two plans. It ran no `git add`
and no `git commit`.

The fifty-third pass's block, kept. Read last in the fifty-third pass (2026-10-12), from the
commands themselves, after its last edit. The index is untouched — stage 3's eighteen paths —
and stage 3b's second pass sits in the working tree on top of its first build. That pass ran
no `git add` and no `git commit`.

```
$ git rev-parse --short HEAD
e16221e
$ git log --oneline | wc -l
      96
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      18
$ git diff --name-only | wc -l
      27
$ git status --short | grep '^??'
?? Screenshots/census/
?? WaterBuddy/Arrival.swift
?? WaterBuddy/Motion.swift
?? WaterBuddy/PageTurn.swift
?? WaterBuddy/PourDrop.swift
?? WaterBuddy/ScreenHeader.swift
?? WaterBuddy/ScrollDepth.swift
?? WaterBuddyTests/ArrivalTests.swift
?? WaterBuddyTests/MotionTests.swift
?? WaterBuddyTests/PageTurnTests.swift
?? WaterBuddyTests/PourDropTests.swift
?? WaterBuddyTests/ScreenHeaderTests.swift
?? WaterBuddyTests/ScrollDepthTests.swift
?? docs/superpowers/plans/2026-10-11-premium-redesign-stage-3b.md
?? docs/superpowers/plans/2026-10-12-premium-redesign-stage-3b-motion.md
?? docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md
?? docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md
$ comm -12 <(git diff --cached --name-only | sort) <(git diff --name-only | sort) | wc -l
      10
```

Against the fifty-second pass's block below: two paths more are unstaged,
`WaterBuddyTests/HistoryViewTests.swift` and `WaterBuddyUITests/AppStoreScreenshotUITests.swift`;
ten more are untracked, the pass's eight new Swift files and its spec and plan; and
`HistoryViewTests.swift` joins the nine paths that are in the index and changed again in the
tree. **The order is unchanged: stage 3 commits first, from the index as it stands. What
follows it is nineteen modified paths and sixteen new** — the twenty-seven less the eight that
are not the stage's (the two rule files with stage 3's wording, `.claude/settings.json`, the
two watch schemes and three catalogues), and the seventeen less `Screenshots/census/`.

The fifty-second pass's block, kept. Read last in the fifty-second pass (2026-10-12), from the
commands themselves, after its last edit: one path more is unstaged, `docs/STATE.md`, and
nothing else differs from the fifty-first's block below. That pass ran no `git add` and no
`git commit` either.

```
$ git rev-parse --short HEAD
e16221e
$ git log --oneline | wc -l
      96
$ git diff --cached --name-only | wc -l
      18
$ git diff --name-only | wc -l
      25
$ git status --short | grep -c '^??'
7
$ comm -12 <(git diff --cached --name-only | sort) <(git diff --name-only | sort)
docs/AI_CONTEXT.md
docs/DESIGN.md
docs/STATE.md
HISTORY.md
tasks/lessons.md
WaterBuddy/AuroraBackground.swift
WaterBuddy/HistoryView.swift
WaterBuddy/HomeView.swift
WaterBuddyUITests/GoalSetupUITests.swift
```

So what follows stage 3's commit is **seventeen modified paths and six new**: the fifty-first
pass's sixteen and six, below, and `docs/STATE.md`, in which this pass corrects one line
citation and one count. Nine paths are in the index and changed again in the tree.

The fifty-first pass's block, kept. Read last in the fifty-first pass (2026-10-12), from the commands
themselves. **That pass ran no `git add` and no `git commit`**: the index is the fiftieth
pass's, below, path for path, and everything of stage 3b is in the working tree.

```
$ git rev-parse --short HEAD
e16221e
$ git log --oneline | wc -l
      96
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only | wc -l
      18
$ git diff --name-only
.claude/rules/50-views.md
.claude/rules/65-accessibility.md
.claude/settings.json
CLAUDE.md
HISTORY.md
WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatch.xcscheme
WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatchWidget.xcscheme
WaterBuddy/AppShortcuts.xcstrings
WaterBuddy/AuroraBackground.swift
WaterBuddy/Haptics.swift
WaterBuddy/HistoryView.swift
WaterBuddy/HomeView.swift
WaterBuddy/RootTabView.swift
WaterBuddy/SettingsView.swift
WaterBuddyTests/AuroraBackgroundTests.swift
WaterBuddyTests/CelebrationTests.swift
WaterBuddyTests/HomeViewTests.swift
WaterBuddyTests/RootTabViewTests.swift
WaterBuddyUITests/GoalSetupUITests.swift
WaterBuddyWatch/Localizable.xcstrings
WaterBuddyWatchWidget/Localizable.xcstrings
docs/AI_CONTEXT.md
docs/DESIGN.md
tasks/lessons.md
$ git status --short | grep '^??'
?? Screenshots/census/
?? WaterBuddy/Arrival.swift
?? WaterBuddy/ScreenHeader.swift
?? WaterBuddyTests/ArrivalTests.swift
?? WaterBuddyTests/ScreenHeaderTests.swift
?? docs/superpowers/plans/2026-10-11-premium-redesign-stage-3b.md
?? docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md
```

- **Stage 3b is twenty-two paths, none staged**: sixteen modified — six app sources, four unit
  test files, the UI tests, and five docs (`HISTORY.md`, `tasks/lessons.md`, this file,
  `docs/DESIGN.md`, `CLAUDE.md`) — and six new: two sources, two test files, the stage's spec
  and its plan. Eight of the sixteen are also in the index with stage 3's changes, so for each
  the index's copy is stage 3's and the tree's is stage 3b's on top of it.
- **Stage 3 commits first, from the index as it stands.** Staging any of those eight before
  that commit would fold stage 3b into it.
- Unstaged and not this stage's: the two rule files with stage 3's wording, for the owner's
  yes; `.claude/settings.json`, three Xcode-rewritten catalogues and the two watch schemes
  (#50). `Screenshots/census/` is untracked.
- Stage 3b's own rule wording is in no file under `.claude/` (#111).

The fiftieth pass's block, kept. **Read last in the fiftieth pass (2026-10-11), after its `git add`
of seven paths — the four sheets, the lessons, the history and the plan — from the commands
themselves; the one `git add` that follows only re-adds this file and `HISTORY.md`, whose paths
are already listed:

```
$ git rev-parse --short HEAD
e16221e
$ git log --oneline | wc -l
      96
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only
HISTORY.md
WaterBuddy/AuroraBackground.swift
WaterBuddy/DataManager.swift
WaterBuddy/HistoryView.swift
WaterBuddy/HomeView.swift
WaterBuddy/Localizable.xcstrings
WaterBuddyTests/HistoryRangeTests.swift
WaterBuddyTests/HistoryViewTests.swift
WaterBuddyTests/LocalizationTests.swift
WaterBuddyTests/UnreadableStore.swift
WaterBuddyTests/WristSyncTests.swift
WaterBuddyUITests/GoalSetupUITests.swift
docs/AI_CONTEXT.md
docs/DESIGN.md
docs/STATE.md
docs/WIDGET.md
docs/superpowers/plans/2026-10-11-premium-redesign-stage-3.md
tasks/lessons.md
$ git diff --name-only
.claude/rules/50-views.md
.claude/rules/65-accessibility.md
.claude/settings.json
WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatch.xcscheme
WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatchWidget.xcscheme
WaterBuddy/AppShortcuts.xcstrings
WaterBuddyWatch/Localizable.xcstrings
WaterBuddyWatchWidget/Localizable.xcstrings
$ git status --short | grep '^??'
?? Screenshots/census/
```

- **The index is stage 3 of the redesign and one more change: eighteen paths.** Nine of source,
  tests and strings are the stage's, gated. Two test files —
  `WaterBuddyTests/WristSyncTests.swift` and `WaterBuddyTests/UnreadableStore.swift` — are known
  issue #92's fix, a change of its own that commits or reverts apart from the stage. Seven are
  docs: the four sheets, the lessons, the history and the stage's plan, which is a new file.
  **Nothing is committed**; HEAD is `e16221e`, level with `origin/main`.
- **Unstaged on purpose, for the owner's yes: the rule wording** — `.claude/rules/50-views.md`
  and `.claude/rules/65-accessibility.md`. They describe the staged code, so they belong with
  the stage's commit or after it. `CLAUDE.md` is unchanged.
- **Since the block below was written, four commits**: `1ced514` *feat(app): redraw Home for the
  redesign's stage 2*, `e7406a5` its plan, `6b5f319` its docs and `e16221e` its rule wording and
  `CLAUDE.md` — everything that block lists as staged or as unstaged for the owner.
- Still unstaged, untouched by this stage: `.claude/settings.json`, three Xcode-rewritten
  catalogues and the two watch schemes (#50). `Screenshots/census/` is untracked.
- No source or test file in the working tree differs from the index, the three Xcode-rewritten
  catalogues aside: `git diff --quiet` over the seven target folders, read after the last edit.

The forty-ninth pass's block, kept. **Read last in the forty-ninth pass (2026-10-11), after its
`git add` of six doc paths — the one that follows only re-adds this file and `HISTORY.md`,
whose paths are already listed — from the commands themselves. Every line is what the three
passes before it read**: the same twenty paths staged, the same twelve unstaged, the same head.
What moved in that pass is inside six of the staged files — the four sheets, the lessons and the
history; the plan was not touched — and inside `CLAUDE.md`. All of it has been committed since:

```
$ git rev-parse --short HEAD
b8a1386
$ git log --oneline | wc -l
      92
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only
HISTORY.md
WaterBuddy/DataManager.swift
WaterBuddy/HomeView.swift
WaterBuddy/LiquidGlassModifier.swift
WaterBuddy/Localizable.xcstrings
WaterBuddyTests/HistoryViewTests.swift
WaterBuddyTests/HomeModelTests.swift
WaterBuddyTests/HomeViewTests.swift
WaterBuddyTests/LocalizationTests.swift
WaterBuddyTests/StreakTests.swift
WaterBuddyTests/UnreadableStore.swift
WaterBuddyTests/WaterLogTests.swift
WaterBuddyUITests/AppStoreScreenshotUITests.swift
WaterBuddyUITests/GoalSetupUITests.swift
docs/AI_CONTEXT.md
docs/DESIGN.md
docs/STATE.md
docs/WIDGET.md
docs/superpowers/plans/2026-10-10-premium-redesign-stage-2.md
tasks/lessons.md
$ git diff --name-only
.claude/rules/20-state.md
.claude/rules/30-rollover.md
.claude/rules/50-views.md
.claude/rules/60-design-system.md
.claude/rules/65-accessibility.md
.claude/settings.json
CLAUDE.md
WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatch.xcscheme
WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatchWidget.xcscheme
WaterBuddy/AppShortcuts.xcstrings
WaterBuddyWatch/Localizable.xcstrings
WaterBuddyWatchWidget/Localizable.xcstrings
$ git status --short | grep '^??'
?? Screenshots/census/
```

- **The index is stage 2 of the redesign: twenty paths** — thirteen of source, tests and strings,
  gated, and seven of docs (four sheets, the plan, the lessons, the history). Three are new files in
  `WaterBuddyTests/`; the plan is new too. Nothing is committed; HEAD is `b8a1386`, level with
  `origin/main`.
- **Unstaged on purpose, for the owner's yes: the rule wording** — five files under
  `.claude/rules/` and one sentence in `CLAUDE.md` — **and, since the forty-seventh pass, five
  factual lines in `CLAUDE.md`** (the app's floor, the UI target's row, the mutation surface, four
  signed targets, the one *reset* path that deletes rows) **and, since the forty-eighth, seven
  more** (`WristPlan.swift` is not app-only; who opens the store; `dayDidTurn` and `refresh` on
  the mutation list; the other paths that insert a row; what constructing a `DataManager` in the
  widget would write; which stamp is guarded; "on the phone"); the forty-ninth tightened two of
  those. They describe the staged code — the seventh guard site, `undoLog`, `dayDidTurn` — so
  they belong with the stage's commit or after it. A separate commit when they want it.
- **Since the block below was written, seven commits**: `c9ef45d` *feat(design): draw Apple's glass
  on iOS 26 and later* — stage 1 — then `97bda33`, `12ddfc4`, `96ca467`, `dba4646`, `e681154` and
  `b8a1386`: the spec and stage 1's plan, the capture tools, the 1.1 screenshots, the doc sync, and
  the rule wording that block calls unstaged.
- Still unstaged, untouched by this stage: `.claude/settings.json`, three Xcode-rewritten
  catalogues (last written 2026-10-07 and 2026-10-08) and the two watch schemes (2026-10-09).
  `Screenshots/census/` is untracked.

The forty-fourth pass's block, kept — read on 2026-10-10 after that session's final `git add`, and
run again as the first act of the forty-fifth, which found every line of it still true. All of it
has been committed since:

```
$ git rev-parse --short HEAD
8a44e8f
$ git log --oneline | wc -l
      85
$ git status -sb | head -1
## main...origin/main
$ git diff --cached --name-only
.claude/rules/15-project.md
.claude/rules/60-design-system.md
WaterBuddy/GoalSetupView.swift
WaterBuddy/HistoryView.swift
WaterBuddy/LiquidGlassModifier.swift
WaterBuddy/PressStyle.swift
WaterBuddy/RootTabView.swift
WaterBuddy/SettingsView.swift
WaterBuddyTests/LiquidGlassTests.swift
WaterBuddyUITests/GoalSetupUITests.swift
docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md
docs/superpowers/specs/2026-10-09-premium-redesign-design.md
```

- **The index is stage 1 of the redesign, twelve paths, gated.** Nothing is committed; HEAD is
  where it was, level with `origin/main`.
- **Three changes are unstaged on purpose, each its own commit when the owner wants it:**
  the rule wording that needs their yes — two bullets in `.claude/rules/60-design-system.md` (the
  file is staged with the approved wording and carries these on top) and `.claude/rules/85-testing.md`;
  the screenshots — eight deletions and four changed captures under `Screenshots/`,
  `Tools/CaptureScreenshots.sh`, `Tools/CaptureFullCensus.sh` and
  `WaterBuddyUITests/AppStoreScreenshotUITests.swift`; and the docs — `docs/AI_CONTEXT.md`,
  `docs/DESIGN.md`, `docs/WIDGET.md`, `tasks/lessons.md`, `HISTORY.md`.
- Still unstaged since 2026-10-07, untouched: `.claude/settings.json`, the two watch schemes, three
  Xcode-rewritten catalogues. `Screenshots/census/` is untracked and now holds the watch captures
  only.

The forty-third pass's block, kept. Verified that pass (2026-10-09) before the docs were
edited, from the commands themselves:

```
$ git rev-parse --short HEAD
8a44e8f
$ git log --oneline | wc -l
      85
$ git diff --cached --name-only
.claude/rules/15-project.md
.claude/rules/60-design-system.md
WaterBuddy/GoalSetupView.swift
WaterBuddy/HistoryView.swift
WaterBuddy/LiquidGlassModifier.swift
WaterBuddy/PressStyle.swift
WaterBuddy/RootTabView.swift
WaterBuddyTests/LiquidGlassTests.swift
docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md
docs/superpowers/specs/2026-10-09-premium-redesign-design.md
$ git status --short | grep -v -E '^[MA]  '
 M .claude/settings.json
 M WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatch.xcscheme
 M WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddyWatchWidget.xcscheme
 M WaterBuddy/AppShortcuts.xcstrings
 M WaterBuddyWatch/Localizable.xcstrings
 M WaterBuddyWatchWidget/Localizable.xcstrings
?? Screenshots/census/
```

**Everything the forty-second pass described as waiting is committed.** The owner's `/commit` on
2026-10-09 made five commits on top of `78ff05a`, pushed, and `main` is level with `origin/main` at
`8a44e8f`:

| Commit | What |
|---|---|
| `5a5368e` | `fix(widget)`: the medium widget's figures in the app's language — known issue #68 |
| `15c35f9` | its docs |
| `5455e43` | `fix(store)`: the reminders toggle re-read on every refresh — known issue #73 |
| `eba1b1e` | `chore(project)`: version 1.1, build 3 |
| `8a44e8f` | docs: the sync after #73 and the submission |

So a checkout of `main` now builds what was submitted, and **known issue #79 is retired**. *(This
section went on describing HEAD `78ff05a`, 80 commits and an uncommitted tree until the forty-third
pass: the docs committed in `8a44e8f` were written before the commits they sit in. The retained account
follows, struck through where it is no longer true of the tree.)*

**Ten paths are staged now, all the redesign's:** the spec, stage 1's plan, six source files and two
rule files. Nothing of it is committed, and **it should not be committed as it stands**: stage 1 is
unfinished, ungated and waiting on known issue #80. This pass's own edits to `docs/` , `tasks/` and
`HISTORY.md` are listed in its checkpoint.

~~**Nothing is committed by this pass, and nothing is staged by it.** Three changes sit in the tree, and
only the first is in the index:~~

1. **The fix for #68 — staged by the thirty-ninth pass, 6 paths, still waiting for the owner's
   `/commit`:** `WaterBuddyWidget/WaterBuddyWidget.swift`, `docs/AI_CONTEXT.md`, `docs/WIDGET.md`,
   `docs/DESIGN.md`, `tasks/lessons.md` and `HISTORY.md`.
2. **The fix for #73 — unstaged, 7 paths:** `WaterBuddy/DataManager.swift`,
   `WaterBuddyTests/DataManagerTests.swift`, `docs/STATE.md`, and this pass's further edits to
   `docs/AI_CONTEXT.md`, `docs/WIDGET.md`, `tasks/lessons.md` and `HISTORY.md` — the four `MM` lines
   above. They were left unstaged on purpose: staging them would fold #73 into #68's commit, and rule
   `90-git` asks for one logical change per commit. Committing the index as it stands commits #68
   alone.
3. **The version, 1.1, and the build number, 3 — unstaged:** `WaterBuddy.xcodeproj/project.pbxproj`,
   28 lines each way. The version is the owner's own edit; the build number was set at their word.

~~No rule file, `CLAUDE.md` or spec changed. `main` is level with `origin/main` at `78ff05a`.~~ *(All
three numbered changes above are in `5a5368e`…`eba1b1e`.)*

**Six paths are deliberately left unstaged**, five of them as at every commit since 2026-10-07: the two
watch schemes and the two watch catalogues the Xcode app wrote (known issue #50), and
`.claude/settings.json`, which moves `git commit` and `git init` from *ask* to *allow* and leaves
`git push` under *ask*. The sixth is `WaterBuddy/AppShortcuts.xcstrings`, also the Xcode app's (#50's
note of 2026-10-09); the thirty-ninth pass counted five while it was already modified. None is this
change's to stage or revert.
`Screenshots/census/` (28 coverage captures, 51 MB) is still untracked, neither committed nor ignored;
whether it belongs in the tree is the owner's call.

Initialised under scoped, explicit owner authorization to enable the watchOS plan's SDD execution
process (root commit `69c5a39`), overriding the "owner declined twice" stance the design spec had
recorded — the authorization is in-conversation, scoped to this execution. 85 commits on `main` (the
figure read 80 until the forty-third pass, 76 until the thirty-ninth, and 68 until the thirty-eighth);
`.gitignore` lists `build/`, `DerivedData/`, `__pycache__/`, `**/xcuserdata/`, `.DS_Store`,
`.claude/settings.local.json` and `.superpowers/sdd/`, and does **not** ignore `xcshareddata/`,
matching rule `90-git`'s own requirement. *(This block read `6cee506` and 27 commits until the
twenty-eighth pass. It was accurate when the twenty-fourth pass wrote it — "the final-review fix
round's own in-progress work" — and stale from the twenty-fifth, whose header already records `HEAD
7f55364`: three passes carried it unchanged.)*

This section previously read "There is no git repository," true at the time it was written and
carried forward stale across several passes after it stopped being true — recorded here as an
instance of the same failure known issue #13 originally named (a doc written from an earlier
snapshot of the tree rather than the tree as it now stands), not a new one.

## Known issues / tech debt

*Resolved the same day and kept out of this list: the stale index entries and the template test
stub (second `HISTORY.md` checkpoint); the partial staging; and the stale "no `ModelContainer`"
claims in `CLAUDE.md` and six rule files, which were corrected once the owner authorised editing
`.claude/`.*

*Also resolved: `WaterLog`'s CRUD was built and unused (`HistoryView` is now its consumer), and the
app had no settings surface at all (`SettingsView` is now it).*

*Resolved on 2026-08-29: **the iPhone landscape gap.** The app carried the Xcode template's
`LandscapeLeft`/`LandscapeRight` on iPhone, where a 393pt-tall canvas cannot hold a 280pt vessel
and the tab bar fell off-screen. `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone` is now
`UIInterfaceOrientationPortrait` in both configurations. **iPad is deliberately left at all four**
— verified on an iPad Pro 11-inch, where the app is 1,210 x 834 in landscape, the vessel sits at
`(465, 156, 280, 280)` and the tab bar at `(607, 755, 553, 44)`: entirely on screen and reachable.
Restricting the iPad would also require `UIRequiresFullScreen`, which would disable Split View —
a much larger decision than this one, and unnecessary since nothing there is broken.*

> **Superseded 2026-09-02, on both of its claims.** The paragraph above is kept as the record of
> what was decided on 2026-08-29; neither sentence is true of the tree now, and one of them was
> never true.
>
> 1. **"iPad is deliberately left at all four" — reversed by owner decision.** iPad support was
>    dropped: `TARGETED_DEVICE_FAMILY` is `1` on all four phone-side targets (was `"1,2"`), and both
>    `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad` settings were deleted. The
>    `UIRequiresFullScreen`/Split View objection above no longer applies, because the app does not
>    run on iPad at all rather than running there in a restricted way. Built proof:
>    `UIDeviceFamily` reads `[1]` in the built `Info.plist`, and the compiled `Assets.car` carries 4
>    `phone` renditions and zero `pad`. The app had never been submitted (`MARKETING_VERSION = 1.0`,
>    no App Store Connect record), so there is no existing-user cost.
> 2. **"`…_iPhone` is now `UIInterfaceOrientationPortrait` in both configurations" was wrong when
>    written, and is still wrong.** Both configurations read
>    `"UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft
>    UIInterfaceOrientationLandscapeRight"` — at HEAD, in the index, and today. Three independent
>    probes found this on 2026-09-02. **The iPhone was never portrait-locked.** Consequences worth
>    knowing: `GoalSetupUITests.setUpWithError`'s comment calls its forced portrait "belt and braces
>    rather than the fix", which is backwards — that line is the only thing pinning orientation, and
>    `AppStoreScreenshotUITests` depends on it for the same reason (a landscape capture comes out
>    2868x1320, a size App Store Connect rejects for the portrait slot). Known issue #12's
>    parenthetical "lower risk than it was, since the iPhone is portrait-only now" rests on the same
>    false premise. **Whether to actually portrait-lock the iPhone is an open product decision, not
>    a documentation fix**, and is deliberately out of scope here — see known issue #31.

*Resolved on 2026-08-29: **the goal is editable after setup**, which was #1 and the largest product
gap on this list. `SettingsView` gained `GoalCard` — the same 1,000–4,000 range setup offers, read
from `GoalSetupView.goalRange` rather than re-declared, committing on drag-end so one gesture is one
write, one widget reload and one reminder re-plan. #2 went with it: the setup copy now says "You can
change this later in Settings", a line deliberately withheld while it would have been a lie.*

*That change also closed a defect it had itself created, found by an adversarial review of the diff
and fixed before staging: `saveDailyGoal(ml:)`'s `guard !storedIsGoalSet else { return }` skipped
the **only** write of `Key.isGoalSet` in the product. Harmless while `GoalSetupView` was the sole
caller — it is presented only while the flag is `false`, so the guard could never short-circuit —
and reachable the moment `GoalCard` became the second. On the upgrade path the flag is inferred and
never stored, so editing such a goal down to exactly `defaultDailyGoal` left nothing on disk, and
the next read re-derived `false` and cross-faded the whole app back into setup mid-session.
Persistence is now guarded on the key and observation on the in-memory flag. See `docs/STATE.md`
and `editingAnInferredGoalDownToTheDefaultPersistsTheFlag`.*

1. ~~**`AddWaterIntent`'s Shortcuts vocabulary is untranslated.**~~ **Retired 2026-10-06 — fixed on
   disk since before the repository's first commit (`69c5a39`), and never retired.** All five strings
   carry `ru` and `uz` in `WaterBuddyWidget/Localizable.xcstrings`, and
   `everyWidgetStringIsTranslatedUnlessDeliberatelyNot` and `theShortcutsVocabularyIsTranslated` guard
   them (both already in that first commit). The original entry follows, for the record: Found by the `/doc_sync` pass on
   2026-08-29 and deliberately not fixed there, because that command may not touch source. Five
   strings — `Log Water`, its `IntentDescription`, `Amount`, `Millilitres of water to log.` and
   `Log ${amount} ml of water` — carry no `ru` or `uz`, so a Russian or Uzbek user who adds the
   WaterBuddy action in Shortcuts gets an English one while the widget beside it draws their
   language. They are `LocalizedStringResource` and `@Parameter` macro arguments and therefore
   **compile-time constants**, so honouring the in-app picker may be impossible; following the
   *device* language is almost certainly just a matter of translating the keys.
   `everyDrawnStringIsTranslatedUnlessDeliberatelyNot` missed it because it checks the app bundle
   and not the extension's — extending it is the first half of the fix. Detail in `docs/WIDGET.md`.
   *(Also noticed: three dead keys in the widget catalogue — `+%lld`, `1,450 ml`, `Today` — extracted
   before the interpolated `Text` sites became `String(format:)` and no longer produced by any
   source. Noise, not a bug.)*

2. **Reminders are `.active`, so iOS may batch them.** `.timeSensitive` would break through a
   Notification Summary and needs the `com.apple.developer.usernotifications.time-sensitive`
   entitlement — rule `70-privacy` forbids adding a capability to improve something, so the cost is
   stated in `SettingsView` instead of hidden. Revisit only as a deliberate capability decision.
3. ~~**The reminder has no action button.**~~ **Retired 2026-10-15 (the sixty-first pass) — the fix is
   on disk, staged:** roadmap item 1.2.4 gave the reminder one action, *Log a Glass* (not a figure:
   it logs the Glass, whatever amount that is), answered by `ReminderResponder`, the app's new
   `NSObject` delegate, set in `WaterBuddyApp.init()`. Proved on the simulator; device steps in #133.
   The original entry follows, for the record: Tapping it just opens the app. A "Log 250 ml" action
   would fit the product's arc exactly, but it needs a `UNUserNotificationCenterDelegate`, which can
   only be set from the app and requires an `NSObject` conformer this codebase does not have. Its own
   change.
4. **`allLogs()` is still unused in production — re-verified this pass, and it came close to
   changing.** The final review's `ingest(_:)` fix (C1: a failed existence-read must decline the
   whole batch, not collapse to "nothing exists") needed the identical unbounded, unfiltered query
   `allLogs()` already wraps — but `allLogs()`'s own `[WaterLog]` return type flattens a failed read
   to `[]` via its own `fetch(nil) ?? []`, which is indistinguishable from "no rows" to a caller
   that has to tell the two apart. `ingest(_:)` therefore calls the private `fetch(nil)` directly,
   bypassing `allLogs()` rather than widening it, and says so in its own comment. `allLogs()` itself
   remains referenced only from a DocC comment (`todaysLogs`'s), same as before. The week card still
   takes a *bounded* window through `readLogs(from:to:)` instead, for the same reason as before —
   `allLogs()` passes no predicate, no `fetchLimit` and no `fetchOffset`, so it materialises every
   row fully faulted onto the main actor, and a naive per-day grouping would redo that on every
   screen appearance. Either give it a caller that genuinely wants everything, or delete it.
5. **The simulator's App Group holds test data** from this session's verification runs. The device was `simctl erase`d partway through to get a clean goal crossing, so the current contents are whatever the confetti probe logged — eight bottles against a 4,000 ml goal —
   the earlier six including a synthetic 1,000 ml serving, plus the 150/250/500 this run tapped in. Harmless, and only on the simulator; `simctl erase`
   clears it if a clean first-run state is wanted. *(2026-10-08, evening: no longer true of any device
   here. Every simulator's data was lost (#77), this one's with it; the iOS 27.0 iPhone 17 the gate now
   runs on was erased by the owner and holds only what one UI run wrote.)*
6. ~~**Six of the eight `DataManager(` sites in the test target omit `rescheduleReminders:`, so they
   drive the real notification centre.**~~ **Fixed 2026-08-31.** The six named were the right six —
   `WaterLogTests.swift:51, :265, :291, :293, :416` and `HistoryViewTests.swift:44` — but the
   **denominator was two changes stale**: re-derived from the tree there are **eleven** construction
   sites, not eight, because `ServingSeamTests` and `HistoryRangeTests` each added correct ones after
   this entry was last counted. Lesson recorded — a known issue's numbers rot like any other doc's.

   Not fixed as "one line per site". `WaterLogTests` held five of the six, and five construction
   sites in one file are five templates for the next copy — which is exactly how
   `tasks/lessons.md` records this trap spreading. One file-level
   `makeManager(defaults:container:now:onReload:onReschedule:)`, in the shape `DataManagerTests` and
   `ServingSeamTests` already use, now serves all five paths; `HistoryViewTests`' single site was
   wired in place. **The test target went from 11 construction sites to 7, and all 7 pass every
   argument** (re-verified this pass by script, not by eye).

   The guard is a pair of tests, because the two obvious guards are both forbidden here: a test may
   not read the source tree to count call sites (under TCC that *hangs the gate*, not fails it), and
   may not construct a real centre to inspect what was removed. What is observable is the seam
   firing, so `theStoreFixtureRoutesTheReminderPlanToTheInjectedSeam` and
   `theServingEditorFixtureRoutesTheReminderPlanToTheInjectedSeam` hand each fixture a spy and assert
   it was called. `DataManagerTests` turned out to have been guarded this way all along without
   anyone naming it — `togglingRemindersRePlansImmediately` fails on the same condition, which is why
   that file's fixture never rotted.

   **The same defect is still live in the app target**, and was deliberately left there: the
   `#Preview`s in `HomeView.swift:381`, `GoalSetupView.swift:267` and `HistoryView.swift:640` omit
   the argument, as rule `50-views` records. (`SettingsView` and `RootTabView` inject it, with
   comments.) Rule `90-git` defers a known one-line fix in an unrelated file to its own change — so
   this is now known issue #14 below.
7. **Three files under `.claude/` still describe the `+` button the quick-add row replaced** —
   `CLAUDE.md:135`, `.claude/rules/65-accessibility.md:33` and `.claude/rules/50-views.md:67`.
   Every underlying rule still holds; only the worked example is stale. Left untouched because
   rule `99-docs-cascade` says `.claude/` is not derived — it changes when the owner decides.
   **Retired 2026-10-11, the forty-seventh pass: the text is gone.** None of the three citations
   resolves — `CLAUDE.md:135` is a line of the gate, `65-accessibility.md:33` the widget backdrop's
   bullet, `50-views.md:67` the end of a sentence about `MainActor.assumeIsolated` — and a search
   of all three files for a `+` or plus button finds nothing, in the tree or at `b8a1386`. Which
   edit removed the examples was not traced.
8. ~~**No shared schemes are checked in.**~~ **No longer true as of 2026-09-01 — all four are now
   checked in, and must stay so.** Two of them (`WaterBuddyWatchWidget`, `WaterBuddyWidgetExtension`)
   were marked Shared in Xcode, which writes `SuppressBuildableAutocreation` for *every* target into
   `xcuserdata/…/xcschememanagement.plist` and stops Xcode auto-creating the others. The `WaterBuddy`
   and `WaterBuddyWatch` schemes vanished from the picker and from `xcodebuild -list`, making it
   impossible to build the app to a device at all. Fixed by writing the two missing `.xcscheme`
   files by hand (test targets wired into each); `xcodebuild -list` now reports four again and a
   `generic/platform=iOS` device build succeeds with the watch app correctly embedded. Rules
   `15-project` and `90-git` are updated to match. The superseded entry follows, for the record:
   A
   prior pass recorded this as retired, citing `WaterBuddy.xcodeproj/xcshareddata/xcschemes/`
   holding `WaterBuddy.xcscheme` and `WaterBuddyWidgetExtension.xcscheme`. Re-verified this pass —
   `git ls-files | grep xcscheme` returns **nothing**, and no `.xcscheme` file exists anywhere on
   disk. Whatever was true on 2026-08-31 23:48 is not true now: every scheme in this project (four,
   after the watch shipped) is auto-created from its target name and unshared, matching rule
   `15-project`'s own current, accurate statement — that rule was never wrong; this entry was. Rule
   `90-git`'s *"Do not ignore `xcshareddata/`"* stays a live instruction for the moment any of the
   four schemes does gain a shared state (a test plan, an environment variable), not a description
   of the present.
9. ~~**The gate command written into `CLAUDE.md` and rule `85-testing` no longer resolves.**~~
   **Retired 2026-09-01 — it resolves.** Re-probed by running a test rather than by asking:
   `-destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16'` with
   `-only-testing:WaterBuddyTests/AppTabTests` returns `✔ Test run with 6 tests in 1 suite passed`.
   The documented commands are correct as written and the `id=` workaround should be dropped —
   rule `85-testing` forbids pinning by device id because it resolves on nobody else's machine.
   **Note the `OS=18.6` is now doing more work than before:** two iOS runtimes are installed (18.6
   and 26.5), so an unpinned or `OS=latest` destination is ambiguous.

   *Why the earlier failure was real and is now gone is not established.* The likeliest reading is
   that installing the iOS 26.5 runtime rebuilt the device list. Recorded rather than explained.
10. ~~**`waterBuddyKeys(in:)` enumerates six of the seven keys.**~~ **Fixed 2026-08-30**, as the
   prerequisite it was called out as being: the helper now reduces over `DataManager.Key.all`, and
   the roster lives beside the declarations it mirrors. The eighth key landed after that, not before.

   **Correction, 2026-09-01: this entry's last clause was wrong.** It said
   `theTripwireHelperEnumeratesEveryStoredKey` "fails the moment the two disagree". It cannot —
   `waterBuddyKeys(in:)` **is** `Key.all.reduce(…)`, so the assertion is `Set(Key.all) ==
   Set(Key.all)` and holds for every possible content of the roster. That test's own DocC
   (`WaterSnapshotTests.swift:217-228`) now says so at length and explains why it is kept anyway:
   it pins that the helper is *exactly* the roster and no wider, so nobody reinstates the
   hand-written list it replaced. The guarantee this entry claimed lives in
   `DataManagerTests.everyKeyTheProductWritesIsOnTheRoster` (`:125`), which drives the real writers,
   reads the suite back, and carries an anti-vacuity floor.
11. ~~**The DocC on `refreshRepublishesLogsWrittenByAnotherInstance` describes code that is not
   there.**~~ **Retired 2026-10-08 — the fix is on disk:** the test's DocC (`WaterLogTests.swift:431`,
   above the test at `:450`) now reads "Pins the `republishTodaysLogs()` in `DataManager/refresh()`",
   says the rows come from the republish and the total from `loadFromStore()`, names the re-derive as
   tried and rejected, and records that an earlier edition claimed otherwise — citing this issue. It
   has stood so since the repository's first commit (`69c5a39`); the entry stayed open because no pass
   resolved its citation. The original entry follows, for the record: `WaterLogTests.swift:404` says it "Pins the `recomputeToday()` in
   ``DataManager/refresh()``" and reasons about "the re-derive". `refresh()` calls
   `loadFromStore()` → `resetIfNeeded()` → `republishTodaysLogs()` → `republishHistory()` →
   `rescheduleRemindersNow()`, and **not** `recomputeToday()` — while `republishTodaysLogs()`' own
   DocC records that making `refresh()` recompute was *tried and rejected* because it destroys
   water. The test is green for a different reason than its comment gives (`loadFromStore()` picks
   the cached total back up). DocC outranks the rule files in this repo, so a comment describing a
   rejected design is actively misleading.
12. ~~**This document claimed `GoalSetupUITests` pins orientation in `setUp`. It does not.**~~
   **Retired 2026-10-06 — it does:** `GoalSetupUITests.swift:31` sets
   `XCUIDevice.shared.orientation = .portrait`, present since the repository's first commit
   (`69c5a39`). The original entry follows, for the record: There is
   no `XCUIDevice` reference anywhere under `WaterBuddyUITests/`, although `tasks/lessons.md`
   records adding one after a landscape-state flake. The claim is corrected above; the mitigation
   itself was never applied. Lower risk than it was, since the iPhone is portrait-only now, but the
   suite still depends on how a simulator was last left.
13. ~~**There is no git repository.**~~ **Fixed** — a git repository now exists, initialised under
   scoped owner authorization to enable the watchOS plan's SDD execution process. See *Git* above
   for the current, re-verified state (27 commits, root `69c5a39` through the watchOS plan).

14. ~~**The three `#Preview`s that reconcile against a real notification centre.**~~ **Fixed** —
   `HomeView.swift`, `GoalSetupView.swift` and `HistoryView.swift`'s previews all now pass
   `rescheduleReminders: { _ in }` explicitly (verified by a fresh grep this pass), matching
   `SettingsView.swift`/`RootTabView.swift`'s own precedent. The line-number citations in the
   original entry (`:381`/`:267`/`:640`) are themselves stale regardless, since every one of those
   files has grown since this issue was opened.
   *(2026-10-11, the forty-eighth pass: still fixed — `HomeView.swift:973`,
   `GoalSetupView.swift:267`, `HistoryView.swift:932`. **Rule `50-views` still says the opposite**,
   at its line 134 (of the working-tree copy; 119 as committed): "`HomeView`, `GoalSetupView` and `HistoryView` currently omit it and reconcile
   against a real notification centre". A rule is the owner's to change; listed in #103.)*
   *(2026-10-14, the fifty-ninth pass, after stage 5: all five places that build a `DataManager`
   for a preview pass it — `HomeView.swift:1130`, `HistoryView.swift:1708` (one factory feeding
   that file's two previews, so six `#Preview`s in all), `SettingsView.swift:806`,
   `RootTabView.swift:512`, `WelcomeView.swift:1308`; `GoalSetupView.swift` is deleted. Stage 5's
   typed wording for rule `50-views`, unstaged for the owner, says so, in place of the sentence
   above; until it is approved the rule still says three previews — `HomeView`, `GoalSetupView`
   and `HistoryView` — omit it.)*

15. ~~**Two rule files mandate a guard the code no longer has.**~~ **Retired 2026-09-01** — as the
   final task of the watchOS plan, an owner edit per rule `99-docs-cascade` (`.claude/` is outside
   what `/doc_sync` may correct on its own). `.claude/rules/40-widget.md` and
   `.claude/rules/80-notifications.md` both now read `guard role.mayFileReminders else { return }`
   and explain why a watch is excluded too. **A third live instance, missed in this task's own
   first pass and caught in fix round 1**: `.claude/rules/30-rollover.md`'s "Guard the stamp with
   `!Self.isAppExtension`" (describing the identical fresh-install day-stamp guard in
   `resetIfNeeded()`) now reads `Self.role.ownsSharedStorage`. `.claude/rules/43-concurrency.md`
   also carried one live, brief-unmentioned instance in its own *Hops* section (`guard
   !isAppExtension else { return }`), fixed in the same first pass this issue's own retirement was
   written in — the sentence above claiming it "was already accurate" was itself wrong; see
   `HISTORY.md`'s checkpoint, which records the fix correctly. Re-verified with
   `grep -rn "isAppExtension" .claude/rules/ CLAUDE.md docs/` (see the sweep in this pass'
   `HISTORY.md` checkpoint) — outstanding, out-of-scope hits remain only in `.claude/commands/`,
   which this task's declared file list does not include.

16. ~~**Two DocC comments in `DataManager.swift` were left stale by the role model**~~ **Fixed
   2026-10-07**, by roadmap item 3. Both sat in `republishHistory()`'s DocC, which the change had to
   rewrite to describe the rows it now publishes; it now reads *"Guarded on `role.drawsHistory`"* and
   *"derivable from none of the cache keys"* — no count left to rot. The original entry follows, for
   the record: **Two DocC comments in `DataManager.swift` were left stale by the role model** — three until
   2026-10-07. Identified 2026-09-01; **still not fixed** — this is a documentation-only task and
   may not touch source (`.claude/rules/00-workspace.md`'s "no source, test, or project file
   changes"). Line numbers re-verified 2026-10-07; the code they describe is unchanged, only its
   position shifted.
   - `:773` (was `:721`, and `:614` before that) — *"Guarded on `isAppExtension`"*, above a body
     that reads `Self.role.drawsHistory`. This is known issue #11's exact shape: DocC outranks the
     rule files here, so a comment naming a symbol the code no longer uses actively misdirects.
   - ~~*"Returns immediately in an extension"*, at the `mayFileReminders` site.~~ **Fixed
     2026-10-07** — the #46 change rewrote that DocC, which now names the widget extension and both
     watch roles.
   - `:779` (was `:727`, and `:620` before that) — *"none of the seven cache keys"*; `Key.all`
     holds **eleven** now (was eight). Pre-existing since the `servings` key, not caused by the role
     model or the watch.

17. ~~**The role model is half-built by its own design's account.**~~ **Retired 2026-09-01.**
   Task 2 of the watchOS plan added the three `@available(watchOS, unavailable)` markers this issue
   named as missing — `grep -c '@available(watchOS, unavailable' WaterBuddy/DataManager.swift` now
   returns **3**, on `shared`, `sharedModelContainer`, and `init`. All six guard sites the role
   model gates are now unreachable by *compilation* from watchOS, not merely by discipline, per
   `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §3.2.

18. ~~**`WristView` draws hardcoded English throughout rather than routing through `\.strings`.**~~
   **Fixed 2026-10-06** (spec `docs/superpowers/specs/2026-10-06-watch-localization-design.md`). Every
   watch string — fifteen across `WristView`, `WristVessel` and the complication, not the eleven this
   entry counted — resolves through `\.strings`, injected together with `\.locale` by `WristRoot` from
   `WristModel.language`, and two new catalogues ship en/ru/uz. The original entry follows, for the
   record: **`WristView` draws hardcoded English throughout rather than routing through `\.strings` — and
   the 2026-09-01 redesign *widened* this rather than narrowing it.** The entry used to name two
   literals at `:78` and `:53`; both line numbers and the surfaces behind them are gone with the
   pour rows. Re-derived against the tree as it now stands, there are **eleven** such sites in
   `WaterBuddyWatch/WristView.swift`: three attribution strings returned from
   `attribution(mirror:now:)`/`syncedCaption(composedAt:now:)` (`:354`, `:355`, `:363`), the "More"
   button's own label (`:261`), two sheet-row strings (`:404`, `:409`), and — new, and the part
   worth noticing — **five VoiceOver strings** (`:222`, `:223`, `:224`, `:278`, `:279`), which the
   old three-row layout did not have because `WristVessel` carried its own. A screen-reader user in
   Russian or Uzbek now gets English for every control on this screen, not just the visible copy.
   The two sheet strings deliberately use `Text(verbatim:)` rather than an interpolated
   `LocalizedStringKey`, so the debt is stated rather than disguised as a key no catalogue holds.
   Every phone-side and phone-widget string in this product routes
   through the injected bundle (rule `70-privacy`'s Localization section); the watch has no
   `Localizable.xcstrings` catalogue of its own and no `\.strings`/`\.locale` injection anywhere in
   `WaterBuddyWatch/`. Not fixed here — this is a documentation-only task. §12 of the design spec
   ("Not in v1") does not name localization as deliberately deferred, so this reads as a genuine
   gap rather than a scoped-out feature, worth a decision (fix, or an explicit "not in v1" ruling)
   before the watch ships to a Russian- or Uzbek-language user.

**Deferred from the final whole-branch review's fix round (2026-09-01), Minor severity, tracked
rather than fixed — the review's own explicit call, not an oversight:**

19. ~~**`WristMirror.languageCode` is a dead wire field.**~~ **Fixed 2026-10-06** — `WristModel.language`
   reads it, and it decides the watch's strings and number formatting; `nil` resolves the watch's own
   language. The wire is unchanged. The original entry follows, for the record: `composeWristMirror` writes it
   (`resolveLanguage(in: defaults).code`), but nothing reads it anywhere under `WaterBuddyWatch/` or
   `WaterBuddyWatchWidget/` — the watch draws hard-coded English regardless (known issue #18, above).
   The field is not wrong, just unconsumed; wiring it up is the natural first step of actually fixing
   #18, not a separate feature.
20. **Four independent implementations of the identical percentage-rounding formula**
   (`Int((… * 100).rounded())`): `HomeView.percentage`, `WaterSnapshot.percentage`,
   `WristView.vessel(boxedInto:)`'s inline vessel percentage (it was `WristView.body`'s until the
   2026-09-01 redesign moved it into that method; the copy itself is unchanged), and
   `WaterBuddyWatchWidget.WristWidgetProvider.entry(at:mirror:outbox:calendar:)` (named
   `currentEntry()` until the #26 fix split it; the formula moved with it unchanged). All four
   currently agree by coincidence of being copied correctly, not by sharing one definition — rule `50-views`'s "a third copy is a bug waiting to round differently"
   already names this risk for the first two; the watch app and watch widget are a third and fourth
   copy the rule predates.
   *(2026-10-20, roadmap item 1.3.2's stage 7b, staged: the watch screen's copy is gone —
   `WristView.vessel(boxedInto:)` with it — and the screen reads `WristPlan.Face.percentage`, the
   provider's formula carried over with its `0...999` clamp. Still four: the complication's provider
   keeps its own until 7c makes it read the same `Face`, and the phone's two are out of scope.)*
21. ~~**`WristVessel.diameter(fitting:reserving:)`'s `reserving:` parameter is always passed `0`.**~~
   **Fixed 2026-09-01.** A second overload, `diameter(fitting:within:)`, clamps against *both*
   dimensions (`max(60, min(width, height))`) and `WristView` now calls that instead — height is the
   binding constraint on this screen and the old signature could not express it, which is why the
   call site kept passing a meaningless `0`. `WristVesselLayoutTests` now pins five real watch
   width/height pairs against both dimensions, and the populated screen has since been rendered on a
   46mm simulator (spec §16's ungating made it reachable) with the vessel fitting cleanly. The
   superseded entry follows, for the record:
   **`WristVessel.diameter(fitting:reserving:)`'s `reserving:` parameter is always passed `0`,**
   at its one call site (`WristView.swift`), so the formula `max(60, availableWidth - heightForRows *
   0.3)` always simplifies to `availableWidth` itself — the reduction the parameter exists to make,
   for the three pour rows below the vessel in the same `List`, never happens. The final review's own
   second pass reported this produces a real overflow on every real watch size, not merely a risk;
   this document has not independently re-confirmed that by rendering the populated screen (vessel
   plus rows together) on a simulator or device — only the code-level fact that `reserving: 0` is
   what ships is independently verified here (a grep, this pass). Every screenshot taken of
   `WristView` so far (Task 15's own verification) was of the *empty* state, before a mirror ever
   arrived, which never exercises this path at all.
22. **`WristLink.send(_:)`'s two transports are guarded asymmetrically.** `sendMessage` (the wake
   signal) is gated on `session.activationState == .activated && session.isReachable`;
   `transferUserInfo` (the durable carrier of record, called just above it in the same loop) is not
   gated on activation state at all. `transferUserInfo` is documented to queue regardless, so this
   may be intentional rather than a bug — recorded for a future pass to confirm rather than assumed
   either way.
23. **`WristInbox.reassemble` cannot distinguish two chunks sharing the same `chunkIndex` for one
   `batchId`.** Currently unreachable in practice — `WristModel.send`'s only caller
   (`pour(amount:)`) always builds each chunk with a distinct, sequential index — but nothing enforces
   that invariant at the reassembly boundary itself.
24. **`WaterBuddyWatchWidget`'s `CFBundleDisplayName` reads "WaterBuddy Widget"**, identical to the
   phone widget's, rather than a watch-specific name — cosmetic, surfaces only in system UI that
   lists installed complications by name.
25. ~~**`WaterBuddyWatchWidget`'s `Gauge` is fed a percentage clamped only at the low end.**~~
   **Retired 2026-10-06 — the premise was false.** The contrast with the phone widget does not hold:
   `WaterBuddyWidget.swift:350` draws `snapshot.percentage` unclamped too, and so does `HomeView` — an
   overachieving day reads above 100 on every surface, by design (`progressUnclamped`). The watch's
   `min(999, …)` only bounds the label's width. The original entry follows, for the record:
   `WristWidgetProvider.entry(at:mirror:outbox:calendar:)` (formerly `currentEntry()`) clamps to
   `min(999, max(0, percentage))` — the `Gauge(...,
   in: 0...100)` itself will visually cap the ring, but the printed `currentValueLabel` text can
   still read above 100 for an overachieving day, which the phone widget's own equivalent readout
   does not do.
26. ~~**`WaterBuddyWatchWidget`'s `TimelineProvider` never applies the day-ordinal rollover, and
   emits no midnight-dated entry.**~~ **Fixed 2026-10-05** (spec §17, owner-approved). The fault was
   wider than this title: `WristModel.todaysTotal` also added `mirror.currentWater` unconditionally,
   so the watch's *screen* drew yesterday's water every morning beside its face — and an existing
   test pinned that as policy (`todaysTotal == 1_800`, *"the number is still shown"*), changed with
   the owner's approval. The mirror now carries `phoneDayEnd`;
   `WristPlan.todaysTotal(mirror:outbox:now:calendar:)` counts the phone's total only before it, and
   both watch surfaces read that one function; the complication emits a timeline entry at each
   `WristPlan.dayBoundaries(after:mirror:calendar:)` instant — the phone's day end and the watch's
   own midnight — beside its unchanged 15-minute refresh. Deliberately *not* the watch's own midnight
   alone: under time-zone skew that comparison zeroes a mirror composed a minute ago, which §5 rules
   out. Pinned by nine phone tests and one watch test; the face itself is unobserved, at the owner's
   choice (see *Current state*). The superseded entry follows, for the record:
   **`WaterBuddyWatchWidget`'s `TimelineProvider` never applies the day-ordinal rollover, and
   emits no midnight-dated entry.** Unlike the phone's `HydrationProvider`, which always emits a
   second, zeroed, midnight-dated timeline entry (rule `40-widget`) so the widget turns over even if
   nothing else wakes it, `WristWidgetProvider.getTimeline(in:completion:)` emits exactly one entry
   on a flat 15-minute refresh policy, and `currentEntry()` reads `mirror.currentWater`/
   `.dailyGoal` with no comparison against `mirror.phoneDayStart` or the watch's own current day.
   A watch that does not receive a fresh phone→wrist publish exactly at or after midnight can show a
   stale, wrong percentage on its face indefinitely — A3's `refresh()` backstop (this same fix round)
   narrows the window this can persist for, but does not close it, since nothing on the watch side
   forces a republish at the boundary itself.

**Opened by the 2026-09-01 `WristView` redesign:**

27. ~~**`WristServingMenu` — the sheet holding the other two servings — has never been rendered by
   anyone.**~~ **Closed by observation 2026-09-02** — recorded in that day's `/doc_sync` checkpoint
   and in the twenty-seventh pass's header above, but left open in this list until the
   twenty-eighth pass. Rendered by driving the watch simulator's accessibility tree with `AXPress`
   from macOS, and correct: two glass capsules, Cup 150 ml and Bottle 500 ml, on its own aurora, with
   a close button. (That route went through `Simulator.app`, which Xcode 27 no longer ships —
   `tasks/lessons.md`, 2026-10-05.) The original entry follows, for the record: It compiles, its contents come from `WristView.secondary(from:)` which is unit-tested,
   and the whole screen was rendered on a 46mm and a 40mm — but the "More" button was never
   *pressed*, because `simctl` has no tap primitive for watchOS and this project has no watch UI-test
   target. So the sheet's own layout, its glass capsules, its aurora backdrop and its dismiss
   behaviour are all unverified by eye. This is the same class of gap rule `85-testing` already
   names for both widgets' rendering — "proved only by placing them and looking" — and the remedy is
   identical: one human tap on a simulator or a watch.

28. ~~**The "More" button now sits below the fold at rest on every watch size, and that it is reachable
   by crown is argued rather than observed.**~~ **Closed by observation 2026-09-02**, the same way and
   with the same late bookkeeping as #27: below the fold at rest on every size, entirely off-screen
   at 40mm, and it does arrive when scrolled (`AXScrollToVisible`). The trade itself — reach for
   presence — stands as the owner chose it. The original entry follows, for the record:
   `vesselHeightFraction` is `0.78125` after two
   owner-directed 25% enlargements, so on a 46mm only the capsule's top curve shows and on a 40mm it
   is off-screen entirely. The screen does scroll — `ScrollView` with `.frame(minHeight:)` and
   `.scrollBounceBehavior(.basedOnSize)` — and that contract is what the claim rests on; no one has
   actually turned the crown and watched the button arrive. Deliberate trade, not an oversight (the
   constant's DocC records why the button's 44pt floor and the caption's second line were *not* the
   things shrunk instead), but it makes #27 more pressing rather than less: the one control nobody
   has exercised is now also the one nobody can see.

**Opened by the 2026-09-02 App Store preparation pass:**

29. **`CLAUDE.md`'s "this codebase compiles clean" was false, and is now retired.** A full
    `xcodebuild build -scheme WaterBuddy` emits **38** warnings, every one of the *"main
    actor-isolated … cannot be referenced from a nonisolated context; this is an error in the Swift 6
    language mode"* class — 72 hits in `DataManager.swift` plus `NotificationManager.swift`,
    `ReminderPlan.swift`, `WaterLog.swift`, `WaterSurface.swift`, `LiquidGlassModifier.swift` and
    `WristPlan.swift` as those are recompiled for the other targets. They are **pre-existing and
    unrelated** to this pass, proven by building the same scheme at two different deployment targets
    and diffing the warning sets: identical. They are invisible to an incremental build, which is how
    the claim survived. `CLAUDE.md` now states the rule as *no **new** warnings against a
    38-warning baseline*. Closing the baseline is real work — every one is a Swift 6 error later —
    and it is its own task, deliberately not folded in (rule `90-git`).
    **Re-measured 2026-10-05, on Xcode 27.0** — the toolchain changed between sessions, so the 38
    compares nothing any more. A clean build into an empty DerivedData folder, generic iOS Simulator
    destination, counted as unique warning lines: **33** before the #26 fix and **31** after (84 → 80
    occurrences), compared per file and message with no new pair. Two classes now, not one: the
    main-actor isolation family in `DataManager.swift` and `NotificationManager.swift`, and a
    diagnostic new in Xcode 27 in `WristView.swift` — *"'Combine' was not imported by this file"*, on
    `Timer.publish`'s `Autoconnect` and `Publishers` (an `import Combine` there is the likely remedy;
    not attempted, rule `90-git`). `CLAUDE.md` now carries the Xcode 27 figure. Rule `85-testing`
    still says *"This codebase compiles clean"* — `.claude/` is the owner's to change, and a doc sync
    may not touch it. **Re-measured 2026-10-06** after the watch localization, the same way: 31
    against 31, no file-and-message pair new or gone. **Re-measured 2026-10-07** after the #46 fix,
    by `build-for-testing` so the test targets count too: the shipping targets 31 against 31 (80
    against 80 occurrences), and the test targets in their first clean-build count, 6 unique lines
    and 12 occurrences on both sides — `ReminderPlanTests.swift` 4 (*"main actor-isolated conformance of
    'ReminderPlan.Slot' to 'Hashable'"*) and `NotificationManagerTests.swift` 2 (`Slot.identifier`).
    No file-and-message pair new or gone. *(Until the re-run this said the test targets were
    "measured for the first time". An older pass had recorded one test-module warning,
    `DataManagerTests.swift:1102`; neither clean build shows it now.)* **Re-measured 2026-10-15**
    for roadmap item 1.2.4, HEAD `6010e25` against the index as exported at 13:21 (three files'
    comments changed after, line for line, which moves no warning), each a clean `build-for-testing`
    plus the widget build into an empty folder: **29** shipping lines against 31 (52 unique whole
    lines against 54) — `NotificationManager.swift`'s `removePending` and `removeDelivered` lines are
    gone, because `ReminderScheduler` is now
    `nonisolated`. No file-and-message pair new; the test targets' 6 unchanged.
    **Re-measured 2026-10-15 for roadmap item 1.2.5**, HEAD `450d76f` against the staged index, the
    same two clean builds: 52 unique whole lines both sides, 36 by file and message, none new and none
    gone — after one new line in the new `ReviewRequestTests.swift` (an unneeded `try`) was fixed.
    In those builds the shipping lines are `DataManager.swift` 21, `NotificationManager.swift` 6 and
    `WristView.swift` 2 — the app embeds the watch app, so its build compiles it — **29**, as
    `CLAUDE.md` says. The two watch schemes, built clean both sides: 17 by file and message, none
    new.

30. **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is set on the app target only, not on all seven.**
    Rule `43-concurrency` asserts it is "set on every native target" and builds a long argument on
    top of that: the explicit `nonisolated` keywords on `WristLink`, `vesselSlots`,
    `WristModel.requestSend` and `Key.wristApplied` exist because the setting would otherwise infer
    `@MainActor` onto them. If the setting is absent on the watch targets, that reasoning does not
    apply there — which may be the real explanation for the three failed probes that rule already
    records honestly under `WristLinkReachabilityTests` ("no diagnostic difference with or without
    the keyword"). The keywords are harmless either way; the *rule's stated justification* is what
    needs re-deriving. Found by two independent probes this pass. Not fixed here: it is a claim in
    `.claude/`, and correcting it properly means re-running those probes rather than editing prose.

31. **The iPhone is not portrait-locked, and two documents said it was.** Both app configurations
    carry `INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait
    UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight"`, unchanged at HEAD.
    See the superseding note above the resolved-issues list for the full consequences. The open
    question is a product one — *should* it be portrait-locked? The 2026-08-29 pass argued yes for
    iPhone on the evidence that a 393pt canvas cannot hold a 280pt vessel, then apparently never
    applied it. Deliberately out of scope for the App Store pass, which needed only that the
    *capture* be pinned, and it is (`XCUIDevice.shared.orientation = .portrait` in both UI suites).

32. **The shipped watch screenshot is the empty state, and that is a knowing trade.**
    `Screenshots/en-US/AppleWatch/01-wrist.png` exists, is 416x496, carries no alpha and is
    acceptable to App Store Connect — but it shows a 0% vessel captioned "Not yet synced · default
    goal". **App Review guideline 2.3.3** says screenshots "should show the app in use, and not
    merely the title art, login page, or splash screen", and a 0% vessel is a weak reading of "in
    use". The owner was shown this and chose the empty state on 2026-09-02. If review pushes back,
    the remedy is already built: drop `WATERBUDDY_SCREENSHOT_NOWAIT=1` and
    `bash Tools/CaptureWatchScreenshot.sh` pauses for a human to tap the pour button.
    - ~~**Why a human is unavoidable.**~~ **Corrected 2026-10-06 — half of this was never true.**
      `simctl` has no tap primitive for watchOS, but XCUITest *is* in the watchOS SDK
      (`XCUIAutomation.framework`, with `XCUIApplication` and `XCUIElement.tap`); what is missing is
      a watch UI-test target in this project — known issue #42. The original bullet, for the record:
      `simctl` has no tap, touch or click primitive for watchOS —
      re-verified against `simctl help` this pass, which offers `io` (screenshot, recordVideo,
      enumerate, poll) and `ui` (appearance, contrast, content size) and nothing that touches the
      screen — and Apple has never shipped XCUITest for watchOS, so there is no UI-test target to
      write. Same root cause as #27.
    - **Getting rid of the caption is a further step still.** Pouring locally raises the number but
      not the caption; only a real `WristMirror` arriving from a paired, booted iPhone simulator
      clears it, which is a manual setup no part of the gate performs.
      **Shown achievable on 2026-10-05, with no tap on the watch at all:** on a paired pair with the
      phone app installed **before** the watch app, the phone's activation publish lands and the
      watch draws the phone's own total as "Synced just now" — 13% · 250 / 2 000 ml there, the UI
      tests' own serving. In the opposite order the phone's `WCSession` reports `appInstalled: NO`
      and every publish fails (`tasks/lessons.md`). `Tools/CaptureWatchScreenshot.sh` installs only
      the watch app, so it cannot produce that state yet.
    - **The shipped image now shows a defect the product no longer has.** `01-wrist.png` is the 0%
      vessel under a full-strength scrim — the near-black disc known issue #35 fixed on 2026-10-06.
      A recapture would draw glass instead; none was taken, as that fix's scope ruled.
    - **As written, the script names a watch that no longer exists** (known issue #45).
    - **A capture-side trap worth knowing:** `simctl io … screenshot` writes PNG colour type 6
      (RGBA) on watchOS **even with `--mask=ignored`**, because the display is non-rectangular and
      the framebuffer carries a mask regardless of corner fill. App Store Connect rejects any
      screenshot with an alpha channel, so `Tools/FlattenPNG.swift` re-encodes to colour type 2 —
      proven lossless, RGB planes byte-identical over 619,008 bytes. `sips` cannot do this: it has
      no alpha/matte/flatten flag, and its only path to colour type 2 is a lossy JPEG roundtrip.

33. **Two iPad artifacts survive the device-family change and cannot be removed.** Xcode 26.6's
    `actool` emits `AppIcon76x76@2x~ipad.png` and a `CFBundleIcons~ipad` Info.plist key from a modern
    single-size universal icon unconditionally — with `TARGETED_DEVICE_FAMILY = 1`, with
    `--target-device iphone` alone, and on a clean build into empty DerivedData. The compiled
    `Assets.car` is correct (4 `phone` renditions, 0 `pad`), and iOS never reads `CFBundleIcons~ipad`
    on a family-1 app, so this is ~50KB of dead payload rather than a defect. Recorded so the next
    person does not mistake it for an incomplete iPad removal.

34. **`Tools/GenerateAppIcon.swift` does not own the watch icon, and the gap widened on 2026-09-02.**
    The script writes only `WaterBuddy/Assets.xcassets/AppIcon.appiconset` (three iOS variants at
    1024², plus that set's `Contents.json`). `WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset` is
    hand-managed. Until this pass the two were at least *related* — the watch icon was a byte-identical
    copy of the phone's **dark** variant. It is now a copy of the **light** one, which is the right
    artwork, but it is still a copy: re-running the generator regenerates the phone's three icons and
    silently leaves the watch's stale. `GenerateAppIcon.swift:5-6` claims "the icon and the product
    cannot drift apart"; that holds for the phone and has never held for the watch. Fixing it means
    teaching the script to emit the watch set **in the modern `universal` + `"platform" : "watchos"`
    form** — not the `watch-marketing` form it had, which compiles silently to no launcher icon at all.

35. ~~**The watch vessel does not scale its readability scrim, and it shipped that way.**~~ **Fixed
    2026-10-06.** `WristVessel.scrimIntensity(at:)` ramps the scrim from none at 0% to full strength
    by 20%. Measured on renders, the empty vessel now reads as glass and its millilitre line holds
    8.58:1 (46mm) and 8.60:1 (40mm) with no scrim at all. **Not the formula this entry named.** It
    quoted the widget's `min(1, level * 1.6)`, which is calibrated to the widget's large, centred
    percentage; on the watch it would have taken the small millilitre line to about 3.0:1 over water.
    The fix's own measurement opened #44. The shipped App Store image still shows the old disc (#32).
    The original entry follows, for the record:
    `WristVessel.swift:42` passes `WaterReadabilityScrim` at the default `intensity: 1` — the
    full-strength *app* value. Rule `60-design-system` says a small canvas scales the scrim with the
    level (`min(1, level * 1.6)`), and `WaterSurface.swift`'s own DocC gives the reason: "at 0% there
    is nothing bright to hold back and a full scrim only turns the vessel into a black hole." The
    phone widget's `MiniVessel` does scale it. The watch does not, and the consequence is visible in
    a shipped asset: compare `Screenshots/census/AppleWatch/01-series11-46mm.png` (0%, a near-black
    disc) against `06-wrist-water-63pct.png` (bright and legible). Found by looking at the captures,
    which is exactly the class of defect rule `85-testing` says no green suite can see.

**Opened by the 2026-10-05 pass:**

36. **On Xcode 27, the `WaterBuddyWatchWidget` scheme prints two `actool` warnings about the
    *phone's* asset catalogues.** `WaterBuddy/Assets.xcassets` and `WaterBuddyWidget/Assets.xcassets`
    each report *"Could not get trait set for device Watch7,18 with version 26.5"* — Watch7,18 being
    the gate's Series 11 (46mm). Pre-existing, proven by building the same scheme from a
    `git archive HEAD` export of the code before the #26 fix; absent from the phone-destination
    builds and from the `WaterBuddyWatch` scheme's runs. Why a watch-destination build compiles the
    phone's catalogues at all is not established. Recorded so "no new warnings" can be read against
    it: these two are this scheme's baseline on this toolchain, not a regression. **Cause
    established 2026-10-06:** the checked-in `WaterBuddyWatchWidget.xcscheme` lists `WaterBuddy.app`
    among its `buildForRunning` entries, so this scheme builds the phone app and the phone widget too
    — their asset catalogues, and their Swift warnings whenever they had to rebuild.
    *(2026-10-11: "the gate's Series 11 (46mm)" is the watch the gate named when this was written.
    Rule `85-testing` has named watchOS 27.0's *Apple Watch Series 12 (46mm)* since `b8a1386`; that
    device has no data on disk and the watch gate runs on *WaterBuddy Watch 27* (#77). Stage 2's
    two clean builds of this scheme, for `generic/platform=watchOS Simulator`, printed neither
    warning: no "trait set" line is among the 19 compared, for `b8a1386` or for the change.)*

37. **Three `@Test` names are each reused across two suites**, against rule `85-testing`'s "names are
    never reused across suites": `aCorruptZeroGoalFallsBackToTheDefault` and
    `progressUnclampedExceedsOneOnOverachievement` in both `DataManagerTests`
    (`DataManagerTests.swift:254`, `:242`; `:244`, `:232` until 1.2.5) and `WaterSnapshotTests` (`WaterSnapshotTests.swift:91`,
    `:280`), and `theOfferedRangeIsAWholeNumberOfSteps` in both `DailyGoalSetupTests`
    (`DataManagerTests.swift:1354` — read `:1312`, already off at HEAD, until 1.2.5, `:1246` until the fortieth pass, and `:1213` until
    2026-10-08) and `HistoryServingTests`
    (`HistoryViewTests.swift:80`). All
    pre-existing — found by this pass's own name sweep, not introduced by it. Every one passes; the
    cost is a name that no longer identifies one test in a report. Renaming them is test-only and
    mechanical, but it is its own change.

38. **`WristModel.isMirrorStale` is computed and tested, and has no reader.** `HISTORY.md` recorded
    that twice on 2026-09-01, but it never reached this list. Spec §17 kept it deliberately: it is the
    watch-calendar comparison, which is the wrong predicate for what to *count* — under skew it calls
    a minute-old mirror stale — and whether the attribution line should use it is a product decision.
    The existing "Synced Nm ago" caption already ages, but says nothing about a day boundary. Its
    DocC now says plainly that it decides nothing; it should either gain a reader or go, with its one
    test.

**Opened by the 2026-10-06 watch localization (spec §8, and the whole-branch review):**

39. ~~**The phone's `String(format:)` figures never group thousands.**~~ **Retired 2026-10-17 —
    fixed by roadmap item 1.2.6, staged and gated, not committed.** Every remaining site builds its
    sentence through `Bundle.localized(_:_:locale:)`, which formats with the injected locale, so a
    `%d` groups: the Home Screen widget's `%1$d ml`, `of %1$d ml` and `+%1$d ml`, the Lock Screen
    rectangle's first two, the watch's serving rows (`WristView.swift`'s `WristServingMenu`), and
    every spoken figure. `git grep 'format: strings.localizedString'` returns nothing in any target.
    Rendered at 12,500 ml in English, Russian and Uzbek on both widgets, nothing cut; the watch's rows
    with a vessel of 1,000 ml or more were not rendered (roadmap 1.2.7). The serving rows' comment
    about the phone's caption, noted below, is unchanged. The entry as it stood: `HomeView`'s vessel draws
    `1300 / 2000 ml` and the week card `Best 8050 ml`, in every language, because `%1$d` does no
    grouping — while `AppLanguage.locale`'s DocC, `WaterBuddyApp.swift`'s injection comment and
    `docs/STATE.md` all say `\.locale` groups numbers ("4 500"). Only `Text(_:format:)` sites, and
    now the watch's readout (`WristVessel.readout`), honour it. Found because the watch's readout
    already grouped (`1 250 / 2 000 ml`), and the owner chose to keep that rather than copy the
    phone's figure (spec §3, ruling 3). The fix is a phone change of its own: format the figures
    first and hand them to `%1$@` keys, in both phone catalogues.
    **2026-10-11: Home's half is on disk, staged.** `Bundle.figure(_:_:locale:)` formats each volume
    with the app's locale and hands it to a `%n$@` key: the vessel's line, the status line, the
    discs' captions and *Undo* all group (`1 300 of 2 000 ml` under this Mac's region), and
    `GroupedFigureTests` pins it. **Still ungrouped:** History's week card and rows, Settings, and
    both widgets — so Home now reads `2 000` where History reads `2000`, until stages 3, 4 and 6.
    **2026-10-11, the fiftieth pass: History's half is on disk, staged** (Home's was committed in
    `1ced514`). The header's total, the week card's figures and a row's amount go through
    `Bundle.figure`; the three keys that drew a raw number beside `ml` are removed with their
    readers; and `theOnlyRawVolumesLeftToDrawAreOtherScreens` reads the built table rather than a
    list: the keys that end in ` ml` and take a `%d` are exactly `%1$d ml`, `of %1$d ml` and
    `+%1$d ml`. **Still ungrouped:** Settings' vessel amounts, which draw from the first of those;
    and, from the widget catalogue's own copies of the same keys, the Home Screen widget (all
    three) and the Lock Screen widget (the first two).
    **2026-10-14, the fifty-eighth pass: Settings' half is on disk, staged** (History's was
    committed in `e0762ab`). Since the redesign's stage 4 a vessel's amount goes through
    `strings.figure("%1$@ ml", …)`; the goal's figure and the range labels were
    `Text(_:format: .number)` already. No file under `WaterBuddy/` draws any of the three keys now —
    the app's catalogue keeps them for the widget's and the watch's copies to be checked against.
    **Still ungrouped:** the two widgets, as above. And on the watch, which this issue never
    counted, the serving rows (`WristView.swift:445`, `%1$d ml` from the watch's catalogue), whose
    comment still says the phone draws that key under each vessel — Home has not since stage 2
    (`1ced514`). The stage's own records said Settings now groups, in their *Current state* block,
    and left this entry as it was; this pass found it.
    *(2026-10-16, the sixty-fourth pass: roadmap item 1.2.6's spec,
    `docs/superpowers/specs/2026-10-16-plural-forms-design.md`, takes the rest — decision D6, approved
    by the owner. Every sentence built from a key would be formatted with the app's locale, through
    `figure` or a new `Bundle.localized(_:_:locale:)`, which groups `%d` as the screen does: the Home
    Screen widget's three keys, the Lock Screen widget's two and the watch's serving rows. Spec only;
    nothing is built.)*

40. ~~**The shared Russian keys use a single plural form.**~~ **Retired 2026-10-17 — fixed by roadmap
    item 1.2.6, staged and gated, not committed.** The ten keys carry plural variations in every
    catalogue that holds them (English *one*/*other*, Russian *one*/*few*/*many*/*other*, Uzbek one
    value), with two new keys, `%1$d days` and `%1$d servings`, for the streak chip's noun and the
    strip's count; all are formatted with the app's locale. `PluralFormTests` checks every key, every
    bundle, at twelve counts, in three languages. The entry as it stood: `%1$d percent. %2$d of %3$d millilitres.`
    reads `62 процентов` (correct: `процента`), and `Add %1$d millilitres` reads `Добавить 222
    миллилитров` (correct: `миллилитра`) — wrong for counts ending in 1–4 except 11–14. The watch now
    inherits both, plus its own `Logs %1$d millilitres`. Heard rather than seen: these are VoiceOver
    strings. A fix means plural variations in every catalogue that holds the keys, at once, through a
    formatting path that honours them.
    *(2026-10-11: stage 2 added one more, the status line's spoken `%1$d millilitres to go` — in
    Russian `Осталось %1$d миллилитров`, the same single form.)*
    *(2026-10-14, the sixtieth pass: two more, found by a fresh reader. Stage 5's *Use* speaks
    `Use %1$d millilitres` — `Выбрать %1$d миллилитров` (`WelcomeView.swift:1095`). And
    `%1$d millilitres` — `%1$d миллилитров` — was never on this list though Settings' sliders spoke
    it before the stage; it is spoken now by Settings' goal (`SettingsView.swift:486`), every
    vessel row (`VesselSliders.swift:106`) and the welcome's goal (`WelcomeView.swift:804`).)*
    *(2026-10-16, the sixty-fourth pass: roadmap item 1.2.6 is this issue, and its spec is written and
    staged — `docs/superpowers/specs/2026-10-16-plural-forms-design.md`, for the owner's review. It
    counts ten keys: the six above, and `%1$d of %2$d millilitres`, `%1$@, add %2$d millilitres`,
    `Average … Goal met on %3$d of %4$d days.` and `Last %1$d days`. "A formatting path that
    honours them" turned out to need a locale: on macOS, under an English process locale,
    `String(format:)` with none picks a Russian table's form by the English rule, and every locale
    tried that gives the Russian rule also groups the figure — the spec's §2. Open until the fix is
    on disk.)*

41. **`WristView.syncedCaption(composedAt:now:strings:)`'s `nil` branch is unreachable from
    production.** `WristMirror.composedAt` is non-optional, and `attribution(mirror:now:strings:)`
    answers a missing mirror before it gets there; only `noMirrorYetReadsAsNeverSynced` exercises it.
    Kept, and translated, because the parameter is optional (spec §8.3). Either make the parameter
    non-optional and drop the branch with its test, or leave it. *(2026-10-17: since roadmap item
    1.2.6 both take a locale beside the bundle — `syncedCaption(composedAt:now:strings:locale:)`,
    `attribution(mirror:now:strings:locale:)`; the branch is unchanged.)*

42. **There is no watch UI-test target — and XCUITest is in the watchOS SDK.** Known issue #32 and
    the 2026-09-02 lesson said Apple never shipped XCUITest for watchOS; the installed SDK says
    otherwise (`Platforms/WatchOS.platform/…/XCUIAutomation.framework`: `XCUIApplication`,
    `XCUIElement.tap`, APIs marked `watchos(9.4)` and `watchos(10.0)`). A watch UI-test target would
    automate what is still done by hand or skipped: the live language switch, the "More" sheet, the
    three `Text(_:bundle:)` strings resolving through an `.lproj`, and the App Store watch
    screenshot's poured state. Adding one is a `project.pbxproj` change and a scheme entry — its own
    task.

43. **Deferred minors from the 2026-10-06 whole-branch review** — graded Minor by effect and left for
    the owner:
    - **Review focus 1 and 4 are only half pinned.** The watch's content checks in
      `LocalizationTests` iterate the literal `translated = ["ru", "uz"]`, so a new language with a
      *partial* watch catalogue would pass (a missing `.lproj` would not — those two tests iterate
      `AppLanguage.selectable`); deriving `translated` from `selectable` is one line. And
      `theVesselReadoutGroupsThousandsInTheChosenLanguage` checks the empty and five-digit figures in
      English only, though its DocC reads as if every language were covered.
    - **`WristRoot` rebuilds `WristView` on every mirror**, because it reads `model.language` and so
      tracks `mirror`; each rebuild creates a fresh `Timer.publish(…).autoconnect()`, restarting the
      caption's 30-second cadence. No visible effect.
    - **The only check that a watch literal reaches the catalogue lived in the session's scratch
      workspace** and is gone. A test cannot scan source — under TCC that hangs the gate
      (`tasks/lessons.md`) — so it would have to be a script under `Tools/`. Until then, a new watch
      `Text(…, bundle:)` or `forKey:` lookup missing from the catalogue draws English in every
      language with every test green.
    - **The Russian 40mm caption leads its second line with `·`** — the separator-in-a-format-string
      hazard `tasks/lessons.md` records from 2026-08-30. A no-break space would likely make it worse;
      the real fix is two strings, as the week card did.
    - **Four DocC and comment nits:** `WristModel.language` says an unrecognised code "says so under
      `#if DEBUG`" — not for `""`, and it prints twice per `WristRoot` body; `syncedCaption`'s DocC
      says "rounded" where it truncates; `watchOwnKeys`' DocC in `LocalizationTests` gives a partly
      wrong reason (two of the nine are `Text` literals; the real one is that an extracted key with
      no `en` value reaches no table); one ragged line left by a reflow in
      `WaterBuddyWatchApp.swift`'s `init()` comment ("Doing it here too"). *(Two until 2026-10-07,
      when the complication change rewrote the background-task comment that held the other.)*

**Opened by the 2026-10-06 known-issue #35 fix:**

44. *(2026-10-20: **retired — fixed on disk, staged in roadmap item 1.3.2's stage 7b.** The line
    left the water: *1,240 of 2,000 ml* sits under the vessel, `.footnote` semibold full white on the
    aurora, 6.72:1 on a 46mm and 6.87:1 on a 40mm (`docs/DESIGN.md`, *The watch's screen,
    measured*); the vessel draws the percentage only, and its scrim ramp was re-derived from the
    percentage's ink. The record below is history.)*
    **The watch's millilitre line falls under 4.5:1 whenever water is behind it.** Measured off the
    63% census capture under today's full-strength scrim, column by column across all 167 columns
    of the line, the ground sampled from the clean rows just above and below it: **3.34:1 at worst,
    4.13:1 median, 4.65:1 at best — under 4.5:1 across 77% of the line**, clearing it only in its
    middle 39 columns. It is small text — `WristVessel`'s readout at `diameter × 0.09`, white @ 0.8 —
    so the floor is 4.5:1 (rule `65-accessibility`), and water reaches it from about 20–24% full,
    which is most of a day. Two causes, both in the source: `WaterReadabilityScrim` is radial and thins
    toward the line's ends, and `WristVessel` reproduced `HomeView`'s readout without the two things
    that carry the app's own line — its 0.85 opacity and its text shadow `(0.3, radius 10, y 2)`.
    Pre-existing, found by the #35 fix's measurement, and left at the owner's ruling; it is also why
    the watch's scrim ramp must be full before water reaches the line. A fix is a design choice to
    measure on renders — the app's opacity and shadow, the widget's tight second shadow
    `(0.45, radius 2)`, or both. Rule `60-design-system` forbids trading the scrim away for a heavier
    shadow, not adding one beside it. The phone app's own vessel was not measured.
    **2026-10-11: the phone's line this compares itself with has changed, and has been measured.**
    Since the redesign's stage 2 the app's millilitre line is full white and bold, with two shadows
    from the readout — `(0.3, radius 10, y 2)` and `(0.45, radius 2)` — and two more of its own;
    there is no 0.85 left. It was measured on 2026-10-10 and again on the 11th (#81): 4.80–4.87
    beside its glyphs, 3.26–3.45 on clean ground. The watch's line is as it was. A fix here now has
    the phone's recipe to try on a render.
    *(First written as "≈4.7:1 at the line's centre and 3.3–3.5:1 toward its ends", from a sampler
    that read glyph ink as background; the same day's re-run corrected it, and the failure is wider
    than "toward its ends". The two DocC comments that quoted the first figures —
    `WristVessel.scrimIntensity(at:)`'s and `WristViewLogicTests`' — were corrected the same day, at
    the owner's word.)*

45. **The capture scripts have gone stale against the toolchain.** All three default to simulators
    that no longer exist: `Tools/CaptureScreenshots.sh` and `Tools/CaptureFullCensus.sh` to iPhone
    `EDF19A71…`, `Tools/CaptureWatchScreenshot.sh` to watch `A47014EF…`, and `xcrun simctl list
    devices` lists neither. The scripts date from 2026-09-02, and this machine's simulators have been
    recreated since (the watchOS 26.5 Series 11 (46mm) is now `93ADDD75…`). Each takes an override —
    `WATERBUDDY_SCREENSHOT_PHONE`, `WATERBUDDY_SCREENSHOT_WATCH` — that gets past the dead default;
    run as documented, each would stop at its first step that names the device. Both halves are read
    from the scripts, not observed: none was run, since each writes into `Screenshots/`. A fix should
    look a device up by name and runtime rather than hard-code another id that will rot the same way.
    **The watch script also carries two claims since found false.** Its comments say, twice
    (`:20–22`, `:92–94`), that Apple never shipped XCUITest for watchOS — it did (known issue #42) —
    and its interactive pause tells the human to "Open Simulator.app", which Xcode 27.0 does not
    ship: `Xcode.app/Contents/Applications/` holds `DeviceHub.app` in its place (`tasks/lessons.md`,
    2026-10-05). `Tools/` is outside a doc sync's write scope, so these are for the owner. *(This
    entry first said the override meant "passing one still works" — never tried — and named only the
    dead defaults; the same day's third `/doc_sync` run widened it.)*
    **2026-10-09: the override was tried, and it works.** `WATERBUDDY_SCREENSHOT_PHONE=<udid> bash
    Tools/CaptureScreenshots.sh` ran end to end, twice. The first run showed a second fault: the
    script froze the status bar at `date '+%-l:%M'`, twelve-hour whatever the device, and printed
    11:15 over History rows reading 23:14. Both iPhone scripts now leave the clock alone (unstaged).
    The dead defaults and the watch script's two false comments stand.
    *(2026-10-11: that fix was committed on 2026-10-10, in `12ddfc4`.)*
    *(2026-10-20, roadmap item 1.3.2's stage 7b: `Tools/CaptureWatchScreenshot.sh` also still tells
    the human to tap "the pour button" — since 7b the vessel is a display and the pours are the row
    of three, and to "Open Simulator.app", where Xcode 27 has `DeviceHub.app`, whose clicks do reach
    a watchOS 27.0 simulator (#152). For the owner.)*
    *(2026-10-18, roadmap item 1.2.8, staged: `Tools/CaptureScreenshots.sh` now finds its phone by
    name and runtime — iPhone 18 Pro Max, iOS 27.0 — and ran end to end; it freezes the clock again,
    at the run's start, in 24-hour form, because the device draws `--time` in its own hour cycle and
    this Mac's are `en_UZ`. `Tools/CaptureFullCensus.sh` and `Tools/CaptureWatchScreenshot.sh` still
    default to dead devices, and the watch script's two false comments stand.)*

**Opened by the 2026-10-06 smart-reminders change** — each a limit the change records rather than
fixes, and each stated in `DataManager.currentReminderSlots()`'s own DocC:

46. ~~**A mutation re-plans twice, and the two reconciles are unordered.**~~ **Fixed 2026-10-07.**
    A mutation still plans twice — `addLog`, `removeWater` and `ingest(_:)` start with `refresh()`,
    on the rows from *before* the change, and end in `recomputeToday()` — but
    `requestReminderReschedule` no longer files each in a `Task` of its own. It hands them to one
    process-wide `ReconcileQueue` (`NotificationManager.swift`), which runs them one at a time in the
    order they were asked for, so the plan from before a drink cannot finish after the plan from after
    it and re-file the slot the drink dropped. `anOlderPlanCannotRefileTheSlotANewerPlanDropped`
    stages exactly that race against a lock-guarded stand-in centre, and failed against the old shape
    before the queue existed (`HISTORY.md`, 2026-10-07). Two costs are recorded rather than fixed:
    the hook's one-line wiring has no test, because a test may not reach a real centre; and a
    reconcile that never returns now holds up every later one, where as its own `Task` it stranded
    only itself. The widget extension's own reconcile stays outside the queue — see #49.

47. **A zone change can bring a kept slot inside the hour.** A trigger resolves in whatever zone the
    device is in when it fires (`NotificationManager.swift`, the trigger's comment), while the quiet
    hour was measured in the zone the plan was made in, and the `NSSystemTimeZoneDidChange` observer
    re-plans only when the day also turns. Flying east soon after a drink can therefore deliver a
    slot less than an hour after it, until the app next re-plans — on its next foreground at the
    latest. Fixing it means re-planning from that observer, which rule `30-rollover` owns.

48. **The latest drink is the latest this process has read.** A cross-process read can succeed and
    still miss the other process's newest row (`republishTodaysLogs()`'s own DocC), so `refresh()`'s
    backstop can put back a slot a widget tap silenced, until a read sees the row; and a failed fetch
    after `deleteLog(_:)` skips the reschedule, leaving the deleted drink's slot silent until the next
    good read. Both degrade to one reminder too many or too few, never to a reminder outside the
    window.

**Opened by the 2026-10-07 known-issue #46 fix:**

49. **Two widget taps' reconciles stay outside the queue, and may race as #46's did — unverified.**
    `AddWaterIntent.perform()` awaits its own `NotificationManager.reconcile(...)` in the widget
    extension. The production hook returns there, because a reconcile queued from it would not
    outlive `perform()`, so #46's `ReconcileQueue` never sees it. If WidgetKit runs a second
    `perform()` while the first is suspended in its reconcile — not checked — the two plans reconcile
    concurrently, and the older can re-file a slot the newer dropped. Two taps seconds apart drop the
    same slot, so in practice the plans differ only when the second tap crosses the goal. The app's
    foreground reconcile in `refresh()` repairs it, within #48's limits. Awaiting the extension's
    reconcile through a queue of its own would close it; out of #46's scope.

50. **The Xcode app writes into four tracked files the code does not change.** Seen 2026-10-07, at
    08:17:58 and 08:21:20, while that session had written nothing to the repository:
    - `WaterBuddyWatch.xcscheme` and `WaterBuddyWatchWidget.xcscheme` lost `BlueprintName` from
      their `BuildableProductRunnable` references — the kind of normalisation Xcode writes on its own.
    - `WaterBuddyWatch/Localizable.xcstrings` (16 → 19 keys) and
      `WaterBuddyWatchWidget/Localizable.xcstrings` (2 → 6) were reformatted into Xcode's
      `"key" : value` style and gained empty entries. `Today`, `1,450 ml` and `+%lld` come from
      `LiquidGlassModifier.swift`'s `LiquidGlassPreview`, a private view only that file's two
      `#Preview`s use, which reaches both watch targets through the file's membership. `%lld`, in the
      widget's catalogue only, comes from the complication's own `Text("\(entry.percentage)")`.
    - Every existing value is unchanged, and the gate passed with all four in the tree.

    Most likely an IDE build: `xcodebuild` does not write extracted strings back (`tasks/lessons.md`,
    2026-10-06), and the Xcode app was open throughout. Expect the entries back whenever Xcode builds
    a watch target. The four files were left unstaged and unreverted for the owner. Keeping the
    entries out would mean `Text(verbatim:)` for the preview's literals and the complication's
    figure; not attempted. *(2026-10-09: a fifth, `WaterBuddy/AppShortcuts.xcstrings`, already modified
    when the #73 session began on the evening of the 8th and missed by the thirty-ninth pass's count of
    five unrelated paths. It is re-spaced into the same `"key" : value` style, and two keys gained
    `"extractionState" : "stale"`; ignoring whitespace those two lines are the whole diff. Every value
    is unchanged. Left unstaged and unreverted, like the four. Whether Xcode's "stale" on the Siri
    phrases means anything for the next archive has not been looked at.)* *(Later on 2026-10-09: looked
    at, for #78. A build from this tree still compiles all three phrases into `en.lproj` and
    `ru.lproj`'s `AppShortcuts.strings`, the two stale keys included, in Debug and in Release. The
    metadata lists the three as one shortcut's phrase templates; Xcode's catalogue most likely keys a
    shortcut by its first phrase, which would be why it calls the other two stale. That last part is an
    inference, not something read from Xcode.)*
    *(2026-10-16, the sixty-fourth pass: still in the tree — `git diff --stat` reads 479, 62 and 70
    lines changed in the two watch catalogues and `AppShortcuts.xcstrings`, and the two schemes 2 each.
    Roadmap item 1.2.6, as its spec plans it, would edit `WaterBuddyWatch/Localizable.xcstrings`, so
    its decision D7 asks the owner to commit, or discard, the three catalogues' rewrite as its own
    change first: committed
    with the plural forms, Xcode's re-spacing and the watch catalogue's three empty entries (16 keys
    at HEAD, 19 in the tree; `git diff -w --stat` reads 9 inserted lines) would ride in that change's
    commit.)*
    *(2026-10-17, roadmap item 1.2.6: D7 answered — the owner chose to discard. `git diff -w` showed
    only the empty entries and the two "stale" marks, and `git restore` put the three catalogues back
    to HEAD. Xcode.app was open, and at about 13:50 an IDE build wrote all three again; with the watch
    catalogue's plural forms already staged, `git restore` put each back to its staged version. The
    two schemes' `BlueprintName` lines are still unstaged. Open: expect the entries back whenever Xcode
    builds a watch target.)* *(2026-10-18, roadmap item 1.3.4: the open Xcode rewrote all four
    catalogues minutes after `TodaysWaterIntent.swift` appeared — the spacing, the intent's title and
    description extracted into the app catalogue with no values, two of *Log a Glass*'s phrases
    `stale`. None held an edit; the owner closed the project and chose to restore all four to `HEAD`,
    and the strings were then added by hand. By 23:34, in the seventy-second pass, Xcode had written
    `AppShortcuts.xcstrings` and both watch catalogues again — unstaged; in the shortcuts file the
    second and third phrase of each shortcut are marked `stale`, and nothing else changed but the
    spacing. The staged copies are the reviewed ones. A doc sync does not restore them; the owner
    decides, as in 1.2.6's D7.)* *(2026-10-19, the seventy-third pass: 1.3.4 was committed at 23:40
    with the reviewed copies, so the five unstaged files are now Xcode's rewrite against `HEAD` —
    `git diff --stat` reads 132 lines in `AppShortcuts.xcstrings`, 637 and 62 in the two watch
    catalogues, 2 in each scheme. The owner ruled on 2026-10-19, as roadmap item 1.3.1's D1, that all
    five go back to `HEAD` with Xcode closed first; it is left for stage 6c, which edits two
    catalogues, because Xcode was open through 6b (pid 2965).)* *(2026-10-20, the seventy-fourth pass:
    done at the start of 6c, on the evening of 2026-10-19 — the owner closed the project, `lsof` on the
    still-running Xcode showed no file under it, and the five went back to `HEAD` by name after
    `git diff -w` showed only Xcode's spacing, `stale` marks, empty preview keys and the dropped
    `BlueprintName`s. 6c's two catalogues were then edited with the project closed, and at the end
    of the pass the tree holds no rewrite: one unstaged file, the owner's `.claude/settings.json`.
    Open: expect it back whenever an open Xcode builds a watch target.)*
    *(2026-10-20, the seventy-seventh pass: back, with 1.3.2's stage 7b staged. Once WaterBuddy was
    open in Xcode, the working tree gained unstaged rewrites of five files: the watch's and the watch
    widget's catalogues in Xcode's `" : "` style, with `+%lld`, `1,450 ml`, `Today` (and `%lld` in
    the widget's) appended with no values — every staged key unchanged; `AppShortcuts.xcstrings`,
    four entries rewritten; and the `WaterBuddyWatch` and `WaterBuddyWatchWidget` schemes, each one
    `BlueprintName` line fewer. The index holds 7b's catalogue as gated; the watch's file now reads
    `MM`. A doc sync does not touch them: whether the rewrites are discarded, as D7 did, is the
    owner's, and `/commit`'s cached-against-unstaged check will show all five.)*
    *(2026-10-21, 1.3.2's stage 7c: one of the five discarded, on the owner's word — the watch
    widget's catalogue was restored to `HEAD` (`git restore`) with Xcode's project closed, because
    7c adds its three keys to that file and the rewrite would have been staged with them. The other
    four are left, unstaged. WaterBuddy was still open in Xcode when the session began; the owner
    closed it before the catalogue was edited.)*
    *(2026-10-21, evening, the eightieth pass: five again — the watch widget's catalogue rewritten
    once more after the owner ran the app from Xcode on their iPhone — and, beside them, the
    `WaterBuddy` scheme the owner edited on purpose: its Run action's StoreKit configuration
    (`identifier = "../../WaterBuddyTests/WaterBuddy.storekit"`), `-WaterBuddyPremium YES` among its
    launch arguments, and the same flag left by mistake among its environment variables. The step-1
    plan's Task 9 keeps the StoreKit reference and removes the other two before it stages the file.)*
    *(2026-10-22, the eighty-fourth pass: the scheme was cleaned and committed with step 1
    (`d5cf816`); the five rewrites are still in the tree against `HEAD` `a6e287b` — `git diff --stat`
    reads 132 lines in `AppShortcuts.xcstrings`, 605 and 263 in the two watch catalogues, 2 in each
    scheme — with the Siri phrases' `stale` marks among them. Set A's step 2 plan edits only
    `WaterBuddy/Localizable.xcstrings`, which none of the five is, with Xcode closed (its Task 6).)*

**Opened by the 2026-10-07 `/doc_sync` re-run:**

51. **Rule `85-testing`'s "one simulator at a time" cannot hold for the watch invocation.** The
    gate's watch destination, *Apple Watch Series 11 (46mm)* on watchOS 26.5, is paired with the
    gate's *iPhone 17* (`xcrun simctl list pairs`). Polled every two seconds through
    `-scheme WaterBuddyWatch -only-testing:WaterBuddyWatchTests`, the watch came up first and the
    iPhone 17 eight seconds later, and both went down as the run ended. A pair is not a clone, so the
    hazard the rule names — a cloned run writing into a container you cannot read back — is
    untouched. But a gate block that says "one simulator at a time" is wrong for that invocation
    whenever the pair exists, and when it was created is not recorded. Rule text is the owner's to
    change. Unpairing the two is not the fix either: `WristLink`'s live session is exercised by hand
    on paired simulators (rule `85-testing`).
    *(2026-10-11: the destination named here went with the simulator set on 2026-10-08. The rule
    now names watchOS 27.0's *Apple Watch Series 12 (46mm)*, which has no data, and the watch gate
    runs on *WaterBuddy Watch 27* (#77). Whether that one is paired with a phone, and so whether
    this still happens, was not looked at.)*

**Opened by the 2026-10-07 complication change (roadmap item 2):**

52. **The complication push is unverified on hardware.** The phone's
    `transferCurrentComplicationUserInfo`, the background wake that now waits for delivery, and the
    face reloading from the background are proved only by their pure halves' tests, the build and
    inspection: no simulator here has ever been seen running a WatchConnectivity background task
    (spec 2026-08-31 §15). Apple has said both things about whether the push reaches a WidgetKit complication — an
    Apple engineer on the Developer Forums said in July 2024 that it did not; Apple's own sample code
    does exactly this; WWDC26's watchOS group lab said updating widgets over Watch Connectivity "works
    now". So it should work on watchOS 27, and is uncertain on 26.x, inside the app's 26.0 floor.
    Where it fails nothing regresses: the application context still carries every mirror. The
    owner's device check (spec 2026-10-07 §8.3) is pending.
53. **A drink logged from the phone's Home Screen widget reaches the watch only when the phone app
    next comes forward.** An Apple engineer said in 2016 that `WCSession` is not available in iOS app
    extensions, so `AddWaterIntent.activateWristLinkIfNeeded()` is most likely inert, and the
    extension's publish throws into `requestWristPublish`'s `DEBUG`-only catch — skipping the push
    with it. Pre-existing; recorded now because the complication change makes it the largest gap left.
    Check 5 of the device check settles whether that activation does anything at all. *(2026-10-08:
    the Control Center control's press is the same extension-side `AddWaterIntent`, so this covers it
    too; the control spec's §7.4 step 1 settles it for that surface.)*
54. **Two deliberate limits of the push design** (spec 2026-10-07 §9). A complication added to a face
    mid-day shows what the watch last heard until the next change, because adding it is not news to
    the phone. And a phone whose clock is set *behind* real time, while the watch keeps real time,
    stalls the watch until the phone's clock catches up: `apply(_:)` refuses a mirror older than the
    one held, and its escape — a held mirror more than a minute ahead of the watch's own clock —
    fires only when the watch's clock moved with the phone's.
55. **Rule `70-privacy` describes the transfer queue for pours only.** Its *WatchConnectivity is a
    ruling* section says a payload handed to `transferUserInfo` lives in a system daemon until the
    counterpart runs. A pushed mirror now waits there too, holding the same fields the application
    context does — at most one at a time, since a new push cancels the one it replaces. Proposed in
    spec 2026-10-07 §5; rule text is the owner's to change.
56. **A test's DocC and Apple's documentation disagree about user-info ordering.** The comment on
    `WristInboxReassemblyTests.chunksArriveOutOfOrderButReassembleInOrder` says `transferUserInfo`
    "promises no ordering"; Apple's `transferUserInfo(_:)` page says such dictionaries "are queued on
    the other device and delivered in the order in which they were sent". Sorting by `chunkIndex` is
    right either way, so nothing breaks — the comment overstates its reason. A complication push,
    which jumps that queue while budget lasts, is the documented exception.
57. **A UI-test gate run was refused launch as "Busy".** On 2026-10-07 the first
    `-only-testing:WaterBuddyUITests` run ended `Simulator device failed to launch
    sardor.WaterBuddyUITests.xctrunner`, SpringBoard answering `Busy ("Application failed preflight
    checks")` at 11:41:07, with no test executed. Another project's `xcodebuild test` of its UI tests
    had been seen running just before 11:39:42 and was gone by 11:52:05 — two process checks that
    printed no time of their own: the first pinned only by the gate's `start 11:39:42` after it, the
    second between the failed run's `end 11:51:11` and the re-run's `start 11:52:05`. Whether it was
    still running at 11:41, and whether it caused the refusal, no sample shows. *(The third run of
    2026-10-07 corrected those two times, which read "at 11:39:42" and "by 11:51".)* `xcodebuild` then spent its full 600 seconds
    collecting simulator diagnostics, because the gate's UI command carries no
    `-collect-test-diagnostics never`. The re-run passed in 3 minutes 10 seconds. The gate's commands
    are the owner's to change (rule `85-testing`). *(Until the 2026-10-07 re-run, this was titled
    "refused launch while another project's UI tests ran", which said more than the two samples.)*
    **Seen again on 2026-10-07 at 19:03:59**, by the #60 gate (the thirty-fifth pass): the same
    refusal 22 seconds into the run, no test executed, and exit 65 at 19:14:03 after the same 600
    seconds. No other `xcodebuild` was running when that run started (`pgrep` at 19:03:37, after which
    `xcrun simctl shutdown all` ran and the run cold-booted its iPhone 17); whether one started in the
    next 22 seconds, no sample shows. The re-run, after `xcrun simctl bootstatus … -b` had booted the
    device and waited for it, passed in 3 minutes 11 seconds. One pass with the wait is not proof the
    wait is the cure: the commit's UI run the same evening, also from a cold boot and with no wait,
    launched normally. **At 22:28:06 the refusal hit the unit-test host itself** (`sardor.WaterBuddy`,
    a `-only-testing:WaterBuddyTests/LocalizationTests` run in the Siri-phrase work): no test executed,
    exit 65 after 40 seconds — a unit run spends no 600 seconds on diagnostics. It passed once
    `simctl bootstatus … -b` had booted the device. Later runs launched both with and without that wait,
    so it is still not shown to be the cure.
58. **Two comments the complication change wrote overstate what the old background wake missed.**
    `WaterBuddyWatchApp.swift`'s comment above `await WristLink.waitForPendingDelivery()` says
    "nothing has been delivered yet" at that point, and that returning there let the system suspend
    the app "before the mirror it was woken for ever landed"; `waitForPendingDelivery()`'s DocC in
    `DataManager.swift` says the same — "before anything had been delivered to it". But on watchOS
    `activate()`, called on the line before, re-reads `receivedApplicationContext` synchronously
    (`applyPersistedContext(from:)`), as it did at HEAD `05a6998` before the old closure's reload. A
    context already held could therefore reach the face — `WristModel`'s `queue: .main` observer,
    posted to from the main thread, runs before `post` returns, as the third run's probe showed on
    this Mac's Foundation — while returning at once left every delegate delivery, a pushed mirror
    included, unable to land while the task was still open. The behaviour is unaffected — waiting is
    right either way — but the comments are code, outside a doc sync's write scope. Found by the
    2026-10-07 re-run.

59. **The serving sheet's wheel draws the rows around the one being set under the text floor.**
    History's sheet picks a time with `DatePicker(…, displayedComponents: [.date, .hourAndMinute])`
    in `.wheel` style, the control the owner chose (spec 2026-10-07-earlier-servings §1). Read off a
    render on 2026-10-07, the row being set measures **5.47:1** against its band; the rows around it
    measure **2.43–2.80:1** against the card's `.frosted` pane — under the 4.5:1 rule
    `65-accessibility` sets for text. UIKit draws them in a dimmed grey that assumes a near-black
    backdrop, and no public API recolours a `UIDatePicker`'s wheel. The value being set is always the
    centred row, and VoiceOver reads the wheel's columns as adjustable elements, so the fault is the
    legibility of the neighbouring choices, not of the choice. **Accepted by the owner on
    2026-10-07** as the system control's own styling, over replacing the wheel with a hand-built
    picker whose rows the app colours — a larger change, and a different control from the one
    approved. Kept open as a record, not as work. A darker pane was considered: `.opaque` adds scrim
    and tint together, and is estimated — not measured — to darken it too little. Figures in
    `docs/DESIGN.md`.
    *(2026-10-14, the sixtieth pass: a second system wheel since stage 5 — the welcome
    calculator's weight `Picker(.wheel)` (`WelcomeView.swift:939`), on the `.frosted` calculator
    pane. Its neighbouring rows were not measured — *Welcome, measured* says only that *Your weight*
    was not read — and are presumably dimmed the same way. Not put to the owner; this acceptance
    was of the serving sheet's wheel.)*

60. ~~**The serving sheet's *Cancel* and *Save* overflow their capsules at `AccessibilityXXXL`.**~~
    **Fixed 2026-10-07** (the thirty-fifth pass), as its own change once the feature it shared
    `HistoryView.swift` with was committed (`9e8e6df`): the fix described below, byte-identical
    (`e083cfc`) to the version that was rendered. Seen on the 2026-10-07 render: *Cancel* runs past its capsule's left edge. **Pre-existing** — the two
    buttons are `EditServingSheet`'s, carried into `ServingSheet` unchanged — and newly more visible,
    because the sheet is now also how a serving is added. The labels carry no `.lineLimit(1)` or
    `.minimumScaleFactor`, unlike the screen's other capped type. A one-line fix, deferred to its own
    change (rule `90-git`: one logical change per commit). **Fix written and verified 2026-10-07, at
    the owner's word, and held out of the tree:** on both labels, `.lineLimit(1)`,
    `.minimumScaleFactor(0.4)` and `.padding(.horizontal, 12)` before `.frame(maxWidth: .infinity)`,
    with a comment naming this issue. Rendered at `AccessibilityXXXL` in English and Uzbek, all four
    labels sit inside their capsules, clear of the curved ends — at 0.5 with no clearance they fit
    edge to edge, and 0.5 with the clearance would have truncated *Bekor qilish*. It shares
    `HistoryView.swift` with the staged feature, and `/commit` commits whole files, so it lands as its
    own change once the feature is committed.

**Opened by the 2026-10-07 `/doc_sync` after #60 (the thirty-fifth pass):**

61. **`/commit`'s own gate block predates the watch.** `.claude/commands/commit.md` is unchanged since
    the root commit `69c5a39`. Its Step 1 pins every invocation to `OS=18.6,name=iPhone 16`, runs
    `-only-testing:WaterBuddyUITests` without `-skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests`
    — the skip rule `85-testing` makes mandatory, because that harness fails on any device where setup
    is done — and has no watch invocation at all; its Step 0 still says the project "is not a git
    repository yet". A `/commit` that followed it literally could stop on the screenshot harness, and
    would never run the watch unit tests. This pass's commit ran rule `85-testing`'s five instead,
    agreed with the owner beforehand. Command text is the owner's to change (rule `99-docs-cascade`).

**Opened by the 2026-10-07 Siri-phrase change (roadmap item 4; the thirty-sixth pass):**

62. ~~**`testAServingAddedToYesterdayShowsUnderYesterday` fails on a simulator that has kept enough
    servings.**~~ **Retired 2026-10-11 (the fiftieth pass) — the fix is on disk, staged with the
    redesign's stage 3.** The test reads yesterday's total off its own day button before and after
    the save, polled for five seconds, and counts no rows. It was seen failing where it should —
    with *Save* made to ignore the wheel, "("2250") is not greater than ("2250")". Since the
    stage's review it also asserts that a serving is listed under yesterday, as exactly one button
    in its row; seen failing with a row drawn as both its layouts and with a past day's list left
    empty. **A limit, seen:** with a past day's list read from the next day's key it passes —
    today's rows are listed under yesterday, and a row is a row; whose rows they are is
    `HistoryLogsTests`' to pin. Before the rewrite it failed once more, the one failure of 38 in
    the stage's first UI run on *WaterBuddy Gate 27*. The entry as it stood:
    It counts yesterday's rows before and after adding one, but a lazy list exposes only the
    rows on screen: once yesterday held eight servings — each gate run adds one — a row landing at the
    top pushed one off the bottom and the count stood still. The serving was saved; a frame of the
    failure's recording shows the new 22:44 row. HEAD `4a7f4dd` fails identically on the same simulator,
    so the earlier-servings gate (green at 18:53 and 19:14) passed only while the list was still short.
    It now fails on every run against this simulator's data, and the UI gate reads 25 of 26 until it
    is fixed. The fix is the test's — assert on the picked day's header total, which moves by the
    serving, or on the new row itself, never a count of visible rows — and it is its own change, the
    owner's call. Resetting the simulator is not ours either: `xcrun simctl erase` is on the deny list.
    **Seen again on 2026-10-10**, twice: on iOS 27.0's *iPhone 17*, whose 9 October held some seventy
    servings from stage 1's probes when it became yesterday, and on the iOS 18.6 simulator, with
    seven. `8a44e8f` fails identically on the first; clean simulators on iOS 27.0, 26.5 and 18.6
    pass. Seven rows are enough to trip it.
    *(2026-10-08, evening: it passed — 26 of 26 — on a freshly erased iOS 27.0 simulator (#77), which is
    the cause seen from the other side. The test is unchanged, and will fail again once yesterday holds
    eight servings there.)*
63. **The App Shortcut cannot run on this simulator, so `LogServingIntent.perform()` has never
    executed.** Registration is verified — Shortcuts lists *WaterBuddy → Log a Glass*, mug glyph, blue
    tile, *Записать стакан* in Russian — but a tap says *Unable to run App Shortcut*: `linkd` "Failed to
    generate bundleIdentity: -Not a platform binary, checking teamId... -Unable to get teamId", then
    "Rejecting invalid client due to requiresValidBundle". A simulator build is signed to run locally
    (`Signature=adhoc`, `TeamIdentifier=not set`) despite `DEVELOPMENT_TEAM = 4DT6XGJF29`.
    `LogTheGlassTests` covers the body between the two waits; the waits, the reply, Siri and Spotlight
    are proved only on a team-signed device — the owner's device check (spec §8.3). Signing simulator
    builds with the owner's identity would also reach it, and is theirs to decide. *(2026-10-08: not
    every intent surface goes through `linkd`. A Control Center control's press goes SpringBoard →
    `chronod`, which ran `AddWaterIntent.perform()` on this simulator — the first time that intent has
    executed in any verification here. The App Shortcut and the widgets' buttons are still refused.)* *(2026-10-09: it has now been tried on a
    build the system will run — the owner's TestFlight 1.1, on their iPhone — and it does not work
    there: #78. `perform()` has also executed once, in-process, in a throwaway probe on this simulator:
    it returned its dialog and logged the Glass. That is the body's first run anywhere, and it is not
    the system's path.)* *(Later the same morning: the owner reports the phrase works on their iPhone,
    which makes that the first run through the system's path — on their word; nothing of it was seen
    from here, and spec §8.3's steps were not reported one by one. #78 is closed on it.)*
    *(2026-10-18, roadmap item 1.3.4: a second App Shortcut, *Today's Water*, registers on *WaterBuddy
    Probe 27* — Shortcuts' WaterBuddy page shows its tile after *Log a Glass*, *Вода за сегодня* in
    Russian; `linkd` interpolated all six Russian phrases and the English ones, and `siriactionsd`
    wrote "2 contextual actions" to Spotlight's index for `app-shortcut-sardor.WaterBuddy`. A tap on the
    tile, by a throwaway probe, changed nothing on screen within four seconds: no *Unable to run App
    Shortcut* was seen this time, and the log search did not establish whether `linkd` refused it or
    ran it. `TodaysWaterIntent.perform()` has not run anywhere.)*
64. **Two deferred minors from the Siri phrase's final review.** (a) `LogServingIntent` and
    `WaterBuddyShortcuts` are nonisolated only because their protocols refine `Sendable` — the reviewer
    typechecked it under the app target's flags; stating `nonisolated` outright would document it, as
    `WristLink` does. (b) `ReconcileQueue.settled()` would never resume on a finished stream, because
    `enqueue` discards `yield`'s `.terminated` — unreachable while the production queue is a static that
    is never released.
65. **Rule `43-concurrency` (and `WristLink`'s DocC) say every native target sets
    `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; `project.pbxproj` has two such lines** — the app target's
    two configurations, by the final reviewer's reading. The widget and watch modules compile with no
    default isolation, which is why `AddWaterIntent` is nonisolated by module default and
    `LogServingIntent` by its protocol. Rule text is the owner's to change.
66. **`AddWaterIntent`'s DocC says a second copy in the app binary "would register the same action twice
    in Shortcuts" — unverified.** The 2026-10-07 research found no Apple source for it, and Apple's
    widget documentation tells developers to add an interactive widget's intent to both the extension and
    the app. Nothing depends on it — the Siri phrase got its own, differently named intent — but it
    should not be leaned on.
67. **A first tap after launch was dropped once, under load.** In the Siri-phrase gate's first UI run,
    `testSettingsIsReachableFromHomeAsATab`'s tap on Settings and the Yesterday test's tap on Glass took
    no effect while every later tap did; another project's UI tests ran beside it. It passed in isolation
    and in both later full runs. One sample, recorded, not explained.
68. ~~**The medium Home Screen widget draws its two figure lines in the device's language.**~~
    **Retired 2026-10-08 (the thirty-ninth pass) — the fix is on disk, rendered before and after:** the
    medium family's column is `MediumColumn` (`WaterBuddyWidget.swift:209`), a view of its own beneath
    `HydrationView`'s injection that reads `strings` itself, as `LockScreenView`'s shapes do;
    `HydrationView` (`:112`) declares no `strings`, and its DocC says why. With the phone in English and
    the app set to Russian, SpringBoard's tree read `+250 мл` beside `7450 ml` and `of 2000 ml` on the old
    code — the first render of this issue — and `7450 мл` / `из 2000 мл` on the fix; Uzbek's goal line
    went from `of 2000 ml` to `2000 ml dan`. The original entry follows, for the record:
    `HydrationView` injects `.environment(\.strings, entry.snapshot.language.bundle)` in its own `body`,
    and its `medium` property resolves `%1$d ml` and `of %1$d ml` through `HydrationView`'s own `strings`
    — which that injection never reaches, because a modifier in a body affects only the views beneath
    it. With the app in Russian on an English phone, the medium widget would draw `1150 ml` / `of 2000
    ml` beside a Russian button. Found by reading on 2026-10-08, while planning the Lock Screen widget
    (whose shapes read strings only in child views for this reason); **not rendered, not fixed** — its
    own change, after a render confirms it (`tasks/lessons.md`, 2026-10-08).
69. **The `WaterBuddy` scheme compiles the widget extension; three rules and a spec say it does not.**
    `xcodebuild build-for-testing -scheme WaterBuddy` compiled `LockScreenWidget.swift` "in target
    'WaterBuddyWidgetExtension'" on 2026-10-08 — the app embeds the `.appex`, so building it builds the
    extension. Rules `15-project` ("No scheme compiles a sibling's sources") and `40-widget` ("The app
    scheme does not compile the widget's sources"), `85-testing`, and the Lock Screen spec's §7.2 say
    otherwise. Their advice — build the extension's own scheme too — stays harmless. Rule text is the
    owner's to change. *(2026-10-08: `build -scheme WaterBuddy` also compiled `WaterBuddyWatch` and
    `WaterBuddyWatchWidget` — the app embeds the watch app as well.)*
70. **The Lock Screen widget is unverified on hardware** (spec `2026-10-08-lock-screen-widget-design.md`
    §7.5, nine steps). On the simulator the three shapes were placed, rendered and captured in all
    three languages, but: the **+** has never logged — `linkd` refuses the ad-hoc-signed extension
    ("Unable to get teamId from sardor.WaterBuddy.WaterBuddyWidget", #63); the quiet form needs a
    passcode and the *Lock Screen Widgets* setting, which the simulator has not exercised; and **what
    VoiceOver says is unknown** — SpringBoard's XCUITest tree lists the drawn texts beneath each
    combined element with or without `.accessibilityHidden(true)`, and wraps each widget in a
    SpringBoard button, so it shows SpringBoard's grouping rather than VoiceOver's stops (the ring's
    gauge also appears with value `100%` beside its label). Whether Dynamic Type reaches a Lock Screen
    widget is unconfirmed: at `accessibility-extra-large` the shapes drew at the same size as at
    `large`. The simulator's Lock Screen keeps the three widgets, and its store the 2,000 ml the probe
    logged (#5). *(2026-10-08: `AddWaterIntent.perform()` itself has now run on the simulator, from the
    Control Center control (#63's note), logging the stored Glass; the **+**'s own path to it, through
    `linkd`, is still unproved.)*
71. **Deferred minor from the Lock Screen widget's final review:** the ring's percentage `Text` has no
    `.lineLimit(1)`, though spec §3.5 says every text carries it. No behaviour changes — the gauge's
    label is already single-line, as the `38…` seen at the old 0.6 floor proved.

**Opened by the 2026-10-08 Control Center control (roadmap item 6; the thirty-eighth pass):**

72. **A press before the first unlock after a restart is an open risk** (spec
    `2026-10-08-control-center-design.md` §3.2). The App Group store and suite stay encrypted until that
    unlock, and `AddWaterIntent` is `.alwaysAllowed`. If iOS runs the control's intent then,
    `sharedModelContainer` falls to a local or in-memory rung and keeps it for the extension process's
    life; the pour lands where the app never reads; `recomputeToday()`, reading a store that
    *succeeded*, could write that one pour as today's total; and `remindersEnabled` reads `false`, so
    the awaited reconcile clears every pending reminder until the app next comes forward. The widgets'
    buttons never reach this — iOS holds them until an unlock. Whether iOS runs a control's intent before
    the first unlock at all is unknown, and the simulator cannot say: the device check's step 4. If it
    does, `perform()` declining unless the store resolved to the App Group rung is its own change;
    requiring the passcode would cross the owner's "log without unlocking" ruling. Found by the final
    review. *(Widened 2026-10-15, roadmap item 1.2.4: a reminder's *Log a Glass* reaches the same
    risk from the **app's** own process — not `.authenticationRequired`, by the same ruling — so a press
    before the first unlock, if iOS shows the reminder and runs the action then, launches the app in
    the background, where `WaterBuddyApp.init()`'s `prepareSharedStorage()` and
    `DataManager.shared` meet the unreadable group as the control's intent does. The same launch
    already happens for a Siri phrase or a WatchConnectivity wake. Step 6 of 1.2.4's device steps, in
    the 1.2.7 sweep, checks it — #133.)*
73. ~~**`loadFromStore()` never re-reads `remindersEnabled`.**~~ **Retired 2026-10-09 (the fortieth
    pass) — the fix is on disk, and its tests were seen RED first:** `loadFromStore()` re-reads the flag
    (`DataManager.swift:1233`) behind the equality guard its neighbours use, and reschedules nothing
    itself, because `refresh()` always ends in a reschedule. Four tests in `ReminderSeamTests` pin it
    (`DataManagerTests.swift:747`–`:793`): a second manager stands in for the long-lived extension, and
    the plan it hands back — what `AddWaterIntent` files — follows the app's toggle in both directions;
    the change is published once, and a refresh that finds nothing changed publishes nothing. **Still
    not reproduced** on a simulator or a device, before or after. The original entry follows, for the
    record: It is read once, in `init`, while
    `servings` and `language` are re-read on every `refresh()`. A widget extension that stays alive
    keeps the flag it read at launch: turn reminders on in the app, then press the control (or a
    widget's **+**) before iOS ends the extension, and its reconcile files an empty plan — clearing the
    pending set until the app next comes forward; turning them off in the same window refiles them.
    Pre-existing; the control makes a press while the extension lives more likely. The fix — re-read
    the flag behind the same equality guard, with a `refreshPicksUpAnExternalWrite`-style test — is its
    own change. Found by the final review's reading; not reproduced.
74. **With WaterBuddy open, a control press may leave Home's total stale** until the next activation or
    tab switch. The app re-reads on `scenePhase == .active` and on a tab's `onAppear`; an Action Button
    press may cause neither, and Control Center's dismissal can race the extension's write. No serving
    is lost — `addLog` re-reads first. Back Tap automations could do this before; the Action Button
    makes it routine. Unverified: the device check's step 6. A fix — a Darwin notification posted at
    the end of `perform()`, answered in the app with `refresh()`, say — would be its own change.
75. **The Control Center control is unverified on hardware** (spec `2026-10-08-control-center-design.md`
    §7.4, nine steps). On the simulator it was placed, titled in all three languages by the app's
    picker, and pressed — logging the stored Glass, an edited one included. Not shown there: a press on
    a locked iPhone (and whether iOS asks for the passcode despite `.alwaysAllowed`), a press before the
    first unlock (#72), a Lock Screen slot, the Action Button, VoiceOver, a wide tile's title on screen,
    the watch's reception (#53) and Home while the app is open (#74). The Action Button's hint follows
    the phone's language — iOS derives it from the display name — while the tile follows the app's.
    The simulator keeps the control placed, and nine presses' servings, 2,700 ml, in today's log (#5).
    *(2026-10-08, evening: that simulator's data is gone (#77), the placed control and the nine presses
    with it.)*

**Opened by the 2026-10-08 fix for #68 (the thirty-ninth pass):**

76. **The medium widget's hero is sized above its own Dynamic Type cap.** `MediumColumn.totalSize`
    (`WaterBuddyWidget.swift:217`) is a `@ScaledMetric`, and a view's own dynamic property reads the
    environment from *above* the view — the rule #68 broke — while the column's
    `.dynamicTypeSize(...DynamicTypeSize.accessibility1)` (`:255`) is applied inside its body, below it.
    So past AX1 the total and the goal line under it (`totalSize * 0.46`) would keep growing, held back
    only by `.minimumScaleFactor(0.6)` — where the cap's comment, `docs/WIDGET.md` and `docs/DESIGN.md`
    say the type "holds still". Pre-existing: `totalSize` sat on `HydrationView` with the same reach, and
    the #68 fix kept it exactly. Found by reading; **not rendered** at an accessibility size. Whether the
    cap moves above the metric or the comment changes is a design call, and its own change.
    *(2026-10-20, roadmap item 1.3.1's 6c: the week widget's card was written in this shape from the
    plan's code and caught by the final review. Its cap now sits in `WeekView`, above the card. Rendered
    on the simulator, the shape is real: before the move, at AX5 the title more than doubled and
    pressed the bars to slivers; after it, AX5 is pixel-identical to AX1. `MediumColumn` is unchanged
    and still has it.)*

**Opened by the 2026-10-08 fix for #73 (the fortieth pass):**

77. **The gate's pinned destinations do not resolve on this Mac.** On the evening of 2026-10-08 the
    simulator devices here lost their data while staying listed — the device folder held two, both
    created within the hour — and the installed runtimes fell to iOS 27.0 alone. The cause is not known.
    iOS 26.5, iOS 18.6 and watchOS 11.5 were back later that evening (another project's session
    downloaded 26.5); **watchOS 26.5 was not**, and the watch's floor is 26.0. What follows:
    - `WaterBuddyWatchTests` cannot run until a watchOS 26 runtime is installed. The #73 gate has no
      watch test run; the watch app and its tests were compiled instead.
    - iOS 26.5's iPhone 17 is listed and will not boot — "Unable to boot device because it cannot be
      located on disk" — until it is erased. `xcrun simctl erase` is on the deny list, so that is the
      owner's to run; they ran it for iOS 27.0's iPhone 17, which the #73 gate used.
    - Rule `85-testing` pins `OS=26.5` on both platforms, and says to update the pin when the installed
      runtime changes. Whether the gate returns to 26.5 or moves to 27.0 is the owner's call, and the
      rule's text is theirs to edit.
    - The old simulator's contents went with its data: the placed widgets and control, and the servings
      behind #5, #62 and #75's last line.
    - **2026-10-10.** The owner ruled the gate onto iOS 27.0; rule `85-testing` is edited to say so,
      unstaged. They installed **watchOS 27.0**, and `WaterBuddyWatchTests` ran on it: 57 tests in 6
      suites. **The listed devices are still without data** — iOS 26.5's and 27.0's other iPhones,
      iOS 18.6's iPhone 16, and every watch listed under watchOS 27.0, *Apple Watch Series 12
      (46mm)* among them, which is the name the rule's watch commands now use. Until that one is
      erased the two watch commands do not resolve as written; tonight's runs used simulators made
      with `xcrun simctl create` (#90).
    - **2026-10-11.** The rule edit was committed in `b8a1386`. *Apple Watch Series 12 (46mm)* is
      still without data: stage 2's gate tried it first — "Unable to boot device because it cannot
      be located on disk" — and ran the watch tests on *WaterBuddy Watch 27*, 57 in 6 suites. The
      watch widget's *build* resolves that name without booting it.
    - **2026-10-09, the forty-third pass: still so.** iOS 26.5's iPhone 17 (`EE56B958`) and iOS 18.6's
      iPhone 16 (`631501B6`) both answer "The device's data is no longer present". The redesign's
      stage 1 needs both erased (its plan's Task 0) and ran what it could on iOS 27.0's iPhone 17
      instead. The two `simctl erase` lines were given to the owner twice and had not run when this
      was written. No watchOS 26 runtime is installed either, so the redesign's watch stage cannot be
      rendered or tested here.
    - **2026-10-20, the seventy-fifth pass.** Roadmap item 1.3.2 keeps D6 as approved — a watchOS 26
      runtime before the watch's stage is measured (its spec §3.2). The owner reported the runtime
      installed; `xcrun simctl list runtimes` and `xcrun simctl runtime list`, read after, show
      watchOS 27.0 and 11.5 only, so it is not on this Mac yet — perhaps still downloading. 7a's code
      and failing tests may start on 27.0 without it; its measurements and the gate's watch run on
      26.x may not.
    - **2026-10-20, later — 7a's session.** Still watchOS 27.0 and 11.5, read twice, the second time
      after 13:14. The owner withdrew
      the 26.x half ("maybe you will change the runtime for different one that is exists"); 11.5 is
      below the watch's 26.0 floor, so 7a was measured and gated on 27.0 alone. What 26.x would have
      shown is #151.

**Opened by the owner's device report of 2026-10-09 (the forty-first pass):**

78. ~~**On the owner's iPhone the Siri phrase opens WaterBuddy and logs nothing.**~~ **Closed 2026-10-09
    (the forty-second pass) by the owner's observation — not fixed.** The owner reports that Siri "is ok
    and working". No code was changed for it, so there is no fix on disk to point to, and **why it
    failed is not known**. What is known: the failure was seen on 1.1 (1) or 1.1 (2), before build 3
    existed; all three 1.1 archives were built from the same sources; and (3) is the first whose app,
    widget and watch app carry one build number, where (2) had the app at 2 and the rest at 1. That is
    a correlation only. If the phrase fails again, start from the table under *Current state* and from
    the device's log, which was never obtained. The entry as opened follows, for the record: A
    TestFlight build of
    1.1; Siri in English, "Log water in WaterBuddy"; and the same from the *Log a Glass* tile in
    Shortcuts, by the owner's account. The phrase is matched, so this is not Siri mishearing: the action
    does not run, the app comes forward, and no serving appears. It is the App Shortcut's first try on a
    build the system will run (#63), and roadmap item 4 is therefore **not done**.
    - **The cause is not found.** Everything readable from here is as designed — the intent's
      declaration, the metadata in Debug and Release, the phrase tables, the records in the Release
      binary — and three probes on the simulator found the intent, ran `perform()` to a logged Glass,
      and read its mode as background-only. *Current state* has the table.
    - **What would settle it** is the device's own account of the tap: its log through Console, or a
      simulator build signed with the owner's identity, if the simulator will then run the shortcut.
      Both were asked for and neither is answered yet.
    - **One thing the reading did turn up:** `perform()`'s last wait, `DataManager.remindersSettled()`,
      has no time limit. It cannot explain a missing serving — the Glass is logged before it — but a
      reconcile that never returned in a background launch would hold Siri's reply open. Unverified.
    - **No code was changed.** `openAppWhenRun` is deprecated from iOS 26 for `supportedModes`; moving
      to it is worth doing with the fix, and is not the fix by itself — the intent already reports
      background-only through the older property.
    - **Until it is fixed,** the build that goes out as 1.1 carries the shortcut as it is: a tile in
      Shortcuts and Spotlight that opens the app. Fixing first, shipping as is, or holding the release
      is the owner's call. The *What's New* text drafted for 1.1 names the phrase; that line stays out
      until this works.

**Opened by the 2026-10-09 submission (the forty-second pass):**

79. ~~**The build in review has no commit.**~~ **Retired 2026-10-09 (the forty-third pass) — the fix is
    on disk.** The owner's `/commit` made `5a5368e` (#68), `5455e43` (#73) and `eba1b1e` (version 1.1,
    build 3), with their docs in `15c35f9` and `8a44e8f`, and pushed them; `main` now builds the
    submitted sources. No tag marks the build that went to review, and which of the three uploads is
    attached to the submission is still not known from here. What the submitted build was not gated on
    stands as written below. The entry as opened: Every archive uploaded as 1.1 was made from the working
    tree: HEAD `78ff05a`, plus the fix for #68 (staged), the fix for #73 (unstaged), the version and
    build number in `project.pbxproj` (unstaged), and the catalogues the Xcode app rewrote (#50). No
    commit reproduces the submitted binary until those are committed, and a checkout of `main` today
    builds 1.0 without either fix.
    - **The way to close it** is the owner's `/commit`, in the order the fortieth pass set out: #68
      from the index as it stands; then #73 with its docs; then the version and build number. A tag on
      the last would mark what went to review.
    - **What the submitted build was not gated on:** the watch tests (#77), and iOS 26.5 — #73's gate
      ran on iOS 27.0. Build 3 itself was never built by a gate run; its sources are the ones the gate
      ran on, with two build settings changed.
    - **Not known from here:** which of the three uploads is attached to the submission, and the
      *What's New* text that went with it.

**Opened by the redesign's stage 1 (2026-10-09, the forty-third pass):**

80. **RETIRED 2026-10-10 — the fix is on disk, staged.** The owner chose Apple's own tint and had it
    climbed until every pair passed: `LiquidGlass.systemTintOpacity(for:)` is `0.52` for the regular
    variant, and the goal line is white 0.55. None of 71 measured pairs is under its floor on iOS
    27.0 through a minute of the aurora's swing; the tightest is white 0.70 over the magenta lobe at
    4.86:1. iOS 26.5, whose glass is darker, passed with room at `0.48` at rest. The entry as it
    was opened follows; its figures are those of the untinted glass. **On Apple's glass most of the
    app's dimmed text is under its contrast floor, and the remedy is
    not chosen. This blocks the redesign's stage 1.** Stage 1 (staged) draws Apple's `glassEffect` on
    iOS 26 and later. Over this aurora the regular glass comes out light and saturated, and every text
    opacity in the app was chosen from samples of the darker hand-made pane. Measured off renders on
    iOS 27.0, worst pixel, against 4.5:1: the tab bar's inactive caption **2.47**, its active caption
    inside the new lozenge **3.01**; the week card's title **3.88**, weekday letters **2.90**,
    average and best **3.21**, disclosure **3.14**; a serving row's time **3.54**; Settings' goal
    title **3.91**, vessel names **3.65**, note **2.70**, reminder description **2.82**, range labels
    **2.35**. Glyphs against 3:1: the lozenge's cyan glyph **1.70**, its rim **1.88**, a row's drop
    **2.81**. What passes: a row's amount, `+`, *Cancel*, the quick-add glyphs (4.8–5.9).
    `docs/DESIGN.md`, *Apple's glass, measured*, has the table.
    - **The plan's one authorised fix cannot close it.** A black scrim under the content, capped at
      0.28, leaves the tab bar's inactive caption at about 3.9:1 by arithmetic. The plan says stop and
      report, and that is where stage 1 stands.
    - **Two alternatives were measured and not adopted:** a black layer at 0.40, and Apple's own
      `Glass.regular.tint(.black.opacity(0.4))`. They read the same to two decimals, and everything
      passes except Settings' range labels at white 0.6, **3.8:1**. About 0.48–0.50 would carry those
      too, by an estimate that was 0.3 too generous at 0.40.
    - **The choice is the owner's:** Apple's tint or our own layer, and how dark; or the bright glass
      with the text raised instead. At 0.40 the panes look close to the canvas the owner approved.
    - **Not yet known:** the same figures on iOS 26.5, the pinned destination; and anything about the
      hand-made path on iOS 18.6, including the tab bar's lozenge there (#77).
    - **Seen, not measured:** with the bright glass, text scrolled under the tab bar shows through it.
    - **Do not commit the staged stage 1 as it stands.** It would ship these figures.
    *(2026-10-11: the heading's "on disk, staged" is out of date — the fix, tint `0.52` and the goal
    line at white 0.55, was committed on 2026-10-10 in `c9ef45d`.)*
81. **Home's millilitre line read 3.10:1** — white @ 0.85 over water and `WaterReadabilityScrim`,
    against 4.5:1, with the vessel over-full, on iOS 27.0. The ground there is water, not glass, and
    the redesign draws neither the water nor the scrim, so this is **probably older than the
    redesign** and the same shape as the watch's #44. **Not shown:** no measurement of HEAD or of the
    hand-made path was taken. Stage 1's Task 5 is to confirm it on iOS 18.6.
    **Settled 2026-10-10: it is older than the redesign.** The line over water reads 2.91–2.93:1 in the
    shipped 1.1 (hand-made pane, 65%, iOS 27.0), 3.00 on Apple's clear glass (45%) and 3.04–3.07 on
    iOS 18.6 (45%); the `%` beside the figure 2.75–2.89 against 3. The same on every path. With the
    vessel empty, on Apple's clear glass, the line reads 4.41–4.50 and the `%` 4.11. **Still open**,
    and stage 2 redraws the readout.
    **2026-10-11, stage 2: redrawn, and open on one question only.** The line is full white, bold,
    with a halo of its own (two shadows) besides the readout's; the `%` is full white. **Beside its
    glyphs**, worst frame of a minute's sweep and of the captures to the goal: the line 4.80 (iOS
    27.0), 4.82 (26.5), 4.87 (18.6); the `%` 3.43, 3.44, 3.48 against 3. **On clean ground 12
    points out**, the way this entry's earlier figures were taken, same captures: the line
    3.26–3.39 over water on iOS 27.0, 3.29–3.39 on 26.5, 3.34–3.45 on 18.6, and 5.01 or more with
    the vessel empty; the `%` 2.71–2.75 over a full vessel and 3.13–3.33 at 45 to 70 %. Which of
    the two is the measure of a shadowed line is the owner's ruling (#95); by the first it is
    closed, by the second it is not.
82. **`AppStoreScreenshotUITests` has gone stale against History — by reading, not run** (the harness
    needs an erased device). It waits for `otherElements["Last 7 days"]`, and the card's title has been
    a static text since 2026-10-07 (`GoalSetupUITests` queries it as one); its shots 10 and 11 are named
    for two detents and the sheet is `.large` only. The redesign's stage 5 replaces the first-run screen
    and will break its *Get Started* preamble as well; the spec has that stage update both methods.
    Beside #45, which is about the capture scripts.
    **2026-10-09: the first half is fixed on disk, unstaged.** All three `otherElements["Last 7
    days"]` are `staticTexts[…]`, and the store method ran twice that evening, `Executed 1 test, with
    0 failures`. The census method has the same fix and has not been run; its shots 10 and 11 are
    still named for two detents.
    **2026-10-11:** that half was committed in `12ddfc4`. **Stage 2 edits the harness again,
    staged and not run:** Home's heading is now a static text *Today*, which is what both methods
    waited for to know History had come up — six waits now look for the `+` button, *Add a
    serving*. Compiled by the gate, skipped by it, and not run on an erased device.
    **2026-10-11, the fiftieth pass: stage 3 reshapes History and the harness was neither edited
    nor run.** By reading only: what it waits for there — *Add a serving*, *Last 7 days*, *Edit
    serving*, a row that ends " millilitres" — still exists, and it returns to the top by
    bouncing off another tab, which rebuilds the list. What a run would show is not known: the
    whole screen scrolls now, so `scrollHistoryList` moves the header and the cards away with the
    rows, and its shots of History will be of the new screen. Its comment cites
    `HistoryView.swift:159` for `allowsFullSwipe`; that line is `:433`.
    **2026-10-12, the fifty-second pass: stage 3b takes away what its `returnToTop` stands on,
    on iOS 26 and later — by reading only, not run.** The helper returns a screen to its top
    by tapping another tab and tapping back, and its comment
    (`AppStoreScreenshotUITests.swift:518–521`) says why that works: "`RootTabView`'s body is a
    `switch tab` inside a `ZStack` … identity does not survive the swap and the scroll
    container is rebuilt at offset 0", and "the swap cross-fades over 0.28 s". That is the
    app's own container, which stage 3b keeps below iOS 26 only. Under Apple's bar a screen is
    kept and comes back scrolled where it was left (#114(b)), so the four calls — History once,
    Settings three times — would leave the screen where it was, and the shots that follow
    would be of the wrong part of it; the helper's own check, that a named control exists,
    would still pass. The gate skips the harness and nobody ran it, so what a run shows is not
    known. A fix is a drag back to the top, or `#114(b)`'s ruling. Found by this pass's reader
    of the stage's text; the fifty-first pass and the stage's review did not look at the
    harness. `allowsFullSwipe` is at `HistoryView.swift:450` since stage 3b.
    **2026-10-12, the fifty-third pass: the paragraph above was true for one build.** Stage
    3b's second pass builds a page when its tab is shown and removes it when it has left, on
    every system, so `returnToTop` returns a screen to its top again; its comment
    (`AppStoreScreenshotUITests.swift:518–520`) now says so, and that the pages slide for
    0.45 s where it said they cross-fade over 0.28 — its 0.6 s wait still covers it. Still not
    run. `allowsFullSwipe` is at `HistoryView.swift:462`.
    **2026-10-13, the fifty-seventh pass:** `allowsFullSwipe` is at `HistoryView.swift:484` since
    stage 3c, which did not touch the harness. Still not run.
    **2026-10-14, the redesign's stage 5:** both methods walk the welcome now — *Get Started*, the
    goal step's shots, then *Continue*, *Continue* and *Not now* through `tapWhenReady(_:)`. Compiled in every gate run; still not run (#130(i)).
    **2026-10-18, roadmap item 1.2.8 — the store method is rewritten and was run; the census was
    not.** The store method launches with the fresh start, so it no longer needs an erased device,
    and builds its week through History's sheet rather than pouring on Home; it passed twice of three
    runs, the first failing on its own wheel order (`tasks/lessons.md`). The census method is
    untouched but for one sentence: it still needs an erased device, its shots 10 and 11 are still
    named for two detents, and its `allowsFullSwipe` citation is still `HistoryView.swift:159`.
83. **History's header gave a UI test no value.** In stage 1's probe `app.staticTexts["Today"].value`
    did not carry "N of M millilitres" (it parsed as −1). The header is
    `.accessibilityElement(children: .ignore)` with a label and a value. **Whether VoiceOver speaks the
    value has not been checked**, in the Accessibility Inspector or on a device. If it does not, that is
    an accessibility defect in a shipped screen; if it does, it is only how XCUITest reads the element.
    **2026-10-11, the fiftieth pass: answered for the new header, staged.** Stage 3 drops the
    wrapper and puts the label, the value and the header trait on the title's own text, as Home
    does. From outside, `app.staticTexts["Today"].value` read "850 of 1900 millilitres" in the
    stage's probe on iOS 26.5 and 27.0, and `testAPastDaysHeadingKeepsItsSizeAtTheLargestTextSize`
    asserts that today's and a past day's heading each resolve to one element whose value ends
    " millilitres" — passed on iOS 27.0, 26.5 and 18.6. **Whether VoiceOver speaks it is still
    unheard**, for the shipped header and for this one.
84. **Small things the redesign's read-only research turned up, none fixed:**
    (a) `LiquidGlassModifier.swift`'s `liquidGlass(in:)` comment says the content is placed on a pane
    "clipped to `shape`"; the pane is a background and the content is not clipped.
    (b) Four `Color(red:…)` literals in that file's preview backdrop are outside rule
    `60-design-system`'s permitted set. Preview only.
    (c) Stale comments: `GoalSetupUITests.swift:28-30` ("The iPhone is portrait-only now" — #31);
    `WaterBuddyApp.swift:18-20` (four integers and no `ModelContainer`) and `:67-68` (two
    destinations); `SettingsView.swift:13` (two cards) and `:348` (`EditServingSheet`);
    `HomeView.swift:170` (a *Today's log* button); `GoalSetupView.swift:14`.
    *(2026-10-11: the `HomeView.swift` one is gone — stage 2 rewrote the file and the comment went
    with it. The other citations still resolve.)*
    *(2026-10-12, the fifty-second pass: stage 3b moved one — `SettingsView.swift:348`, the
    `EditServingSheet` comment, is `:357`. `:13` and `GoalSetupUITests.swift:28-30` stand.)*
    *(2026-10-12, the fifty-third pass, after stage 3b's second pass: that comment is at
    `SettingsView.swift:366`; the other two stand.)*
    *(2026-10-14, the redesign's stage 4: both `SettingsView.swift` comments are fixed — the DocC
    names all four cards, and the `EditServingSheet` sentence now says History's serving sheet.
    `GoalSetupUITests.swift:28-30` stands.)*
    *(2026-10-14, the redesign's stage 5: `GoalSetupView.swift` is deleted, its comment with it.
    `WaterBuddyApp.swift`'s "four integers" sentence is `:19–21`, and `GoalSetupUITests.swift`'s
    "portrait-only" is `:29–31`; the stage did not touch either sentence — though it gave the same
    type `import SwiftData` and a `ModelContainer` of its own, the DEBUG fresh start's in-memory
    store, so "there is no `ModelContainer` alongside it" is now more wrong than it was. It did edit the `RootView` DocC
    (`:129–130`), "setup" to "the welcome", and left "two destinations" standing beside the edit —
    still stale, and still open here.)*
    *(2026-10-24, the eighty-eighth pass: "two destinations" is at `WaterBuddyApp.swift:157` — `:150`
    at `HEAD` `5b511bd`, moved by set A's step 4's seven lines above it — still stale; "four integers"
    stands at `:19`, and `GoalSetupUITests.swift`'s "portrait-only" at `:30`.)*
    (d) No production caller: `removeWater(amount:)`, `resetDailyProgress()` and
    `WristVessel.diameter(fitting:reserving:)`, like `allLogs()` (#4). Tests pin all three.
    *(2026-10-20, roadmap item 1.3.2's stage 7b, staged: `diameter(fitting:reserving:)` is removed,
    with `theVesselNeverExceedsTheAvailableWidth` and `reservingMoreSpaceShrinksTheVessel`; the first
    one's claim is held for the function that stays by `theVesselFitsInsideBothItsWidthAndItsHeight`.
    The other two remain.)*
    (e) The widget target's `WidgetBackground` and `AccentColor` colour sets appear to be referenced by
    nothing.
    (f) `HomeView` is rebuilt on every tab switch, so a goal crossed from another tab is not
    celebrated on return.
    (g) `SettingsView` reads Notification Summary's setting straight from `UNUserNotificationCenter`,
    outside the `ReminderScheduler` seam.
85. **The hand-made pane reads lighter than `docs/DESIGN.md` records, and several pairs the records
    show passing are under their floor — in the shipped 1.1 as well.** Found on 2026-10-10 by the
    fallback pass on iOS 18.6, and then in the store captures of `8a44e8f` taken the same night on
    iOS 27.0, which draw the hand-made stack. Beside the goal card's labels the pane is sRGB
    `(0.251, 0.367, 0.504)` on iOS 18.6 and `(0.251, 0.370, 0.507)` in the shipped app on 27.0; the
    record has `(0.21, 0.30, 0.44)`. Worst pixel of clean ground, shipped 1.1 on iOS 27.0: the week
    card's disclosure at white 0.70 **4.18:1** (recorded 5.49), the vessels note **4.32** (5.50), the
    tab bar's inactive caption **4.29** (4.89), the range labels at 0.6 **3.01**, the goal line
    **2.16** against 3 (3.26). On iOS 18.6 with stage 1: 4.38, 4.09, 3.91–4.98, 4.03 at the new 0.75,
    2.37. **Why is not established** — the records are from iOS 26.5's iPhone 17 and no hand-made
    pane was rendered there this time; the system, the screen's size and the moment of the aurora all
    differ. **Who it reaches:** today, every user of 1.1; after stage 1, iPhones on iOS 17 to 25 and,
    until its own stage, the watch. **A remedy to weigh:** raise the hand-made stack's dark scrim
    until its pane is as dark as the opacities were chosen for — measured the way stage 1 measured
    Apple's glass, on the lightest ground. It changes the look below iOS 26, the watch and perhaps
    the widget's derived fills, so it is the owner's decision and its own change.
    **2026-10-11, stage 2's two new panes on the hand-made stack, iOS 18.6:** *Undo*'s line, on an
    `.opaque` pane chosen because `.frosted` left it at 4.48, reads **4.64:1** against 4.5, its
    word 7.45, its cyan glyph 4.44 against 3; the streak chip's number 8.60, its flame **3.22**
    against 3 where the pane's highlight lies beside it (3.31 above, 4.38 below, 4.71 toward the
    number), over a minute's sweep. All pass, two of them narrowly, and the same remedy would
    widen both.
    **2026-10-11, the fiftieth pass: History on iOS 18.6, the redesign's stage 3, staged.** Over
    all eighteen pane samples of the week card and the strip in a minute's sweep — passing pairs
    included, the track's left out, each at its pair's worst frame — the pane read between
    (0.24, 0.34, 0.48) and (0.39, 0.47, 0.53), channel by channel. Nine of the swept pairs are
    under their floor on it. **Eight are drawn as HEAD draws them:** weekday letters at
    white 0.72, 3.41–3.93 against 4.5; the disclosure at 0.70, 4.15; the goal line, 2.65–2.98
    beside a bar and 2.12 over an empty day's track, against 3; the week's cyan bar, 2.78 beside
    the pane (3.32 at the card's other end) and 1.98 over an empty track. **One is new: the
    strip's cyan bar, 2.73 against 3 at the plot's left end** — the small hours, where the
    pane's highlight lies; it reads 3.80 at midday and 3.69 in the evening, where the day's
    servings stood. The same cyan on the same pane, with a dark hairline round it that the
    figures do not count. In the week card a white bar passes (4.91) where a cyan one does not,
    so on this pane a day that reached the goal is the fainter one. And, one capture and not a sweep, the empty
    state's second line at white 0.7 reads **3.80 against 4.5** (its title 5.37); the empty state
    is HEAD's. The stage's one mark of its own colour on this pane, a row's cyan glyph, was given
    a dark well and reads 4.48. Nothing was retuned in the hand-made stack. Table:
    `docs/DESIGN.md`, *History, measured*.
    **2026-10-13, stage 3c — closed for the phone's own panes as far as they were measured (the
    past-day empty state's line was not, #127), open for the widget and the watch.**
    The phone's hand-made pane (a `.material` base on iOS) is scrimmed with `Aurora.top` at sheer
    0.30 / frosted 0.70 / opaque 0.80, and on iOS 18.6, through a minute's sweep, nothing measured
    on it is under its floor: the cyan bar 3.38, the goal dashes 3.71, *Undo*'s line 5.05, the range
    labels 5.08, the tab bar's inactive caption 5.22 (`docs/DESIGN.md`, *The look, measured*). The
    widget's `.archived` base and the watch keep the black scrim at the old values, so whatever this
    entry found on the watch's pane stands.
86. **The tab bar's lozenge is faint on the hand-made bar.** On iOS 18.6 its rim, white 0.55, reads
    2.69–3.10:1 against 3, and the cyan glyph of the selected tab 2.83 at the *Home* slot, the bar's
    lightest end; the active caption inside it reads 5.00–6.16 and passes. The shipped 1.1 already
    has that glyph at 2.49–2.90 with no lozenge. On Apple's glass all three pass (rim 3.29–3.70,
    glyph 3.89–4.59). The selected tab is also carried by the caption's white, the glyph's colour
    and `.isSelected`. It follows from #85 and is cured by the same remedy.
87. **The gate runs on one iOS, and the system draws differently on another.** Stage 1's bug existed
    on iOS 26.5 and not on 27.0, and Apple's glass is visibly darker on 26.5. Rule `85-testing` now
    pins 27.0 alone. Until the owner rules otherwise, each remaining stage of the redesign also runs
    the UI suite on iOS 26.5 and on iOS 18.6, on the simulators in #90, and says so in its record.
    Making that part of the gate is a rule change, and the owner's. **The wording is written,
    unstaged, in rule `85-testing`:** one more bullet, the UI invocation again with `OS=26.5`.
    `testAServingRowOpensItsSheetWhereverItIsTapped` can fail on iOS 26.x only, so without it the
    `.contentShape` in `systemPane` is held by a comment. `theAvailabilityFlagMatchesTheRunningSystem`
    has the same shape: its `false` side runs only below iOS 26.
    **2026-10-11:** the wording was committed in `b8a1386`, so iOS 26.5 is in the rule. Stage 2 ran
    the UI suite on iOS 27.0, 26.5 and 18.6, each on a simulator made that hour (#102), not on
    #90's: `Executed 38 tests, with 0 failures` three times. The function this entry calls
    `systemPane` is `sampling(_:)` since stage 2; it still ends in `.contentShape(shape)`.
88. **The store screenshots are of 1.1, and half-replaced.** `Screenshots/en-US/iPhone-6.9/` holds
    four captures of `8a44e8f` taken at 23:19–23:24 on 2026-10-09, on iOS 27.0 — a late clock, and
    figures grouped as the Mac's region groups them ("2 000"). `en-US/AppleWatch/01-wrist.png` and
    the nine captures in `Screenshots/census/AppleWatch/` are from 2026-09-02 and are kept until a
    new watch capture exists; the owner ruled that every screenshot is retaken once the redesign is
    built. The iPhone 6.5″ and iPad 13″ sets and the census's iPhone captures are deleted. All of it
    is unstaged, with the two capture-script fixes and the harness fix of #82.
    *(2026-10-11: all of it was committed on 2026-10-10 — the captures and the eight deletions in
    `96ca467`, the scripts and the harness in `12ddfc4`. The captures are of 1.1 and now of a Home
    that stage 2 has redrawn; the owner's ruling stands, every screenshot is retaken once the
    redesign is built.)*
    *("All of it" overstates, corrected the same day: `96ca467` holds twelve paths, all under
    `Screenshots/en-US/`. **`Screenshots/census/` has never been tracked** — `git status` still
    shows it untracked — so the nine watch captures kept there are in no commit, and the census's
    iPhone captures were deleted from the working tree only.)*
    *(2026-10-18, roadmap item 1.2.8: **the iPhone half is retaken, of the redesign**, staged and not
    committed — the four shots over a lived-in week, at 15:06, figures and times in `en_US` (*1,300*,
    *1:30 PM*), the status bar's clock *15:01*. The watch shots are still from 2026-09-02: the watch's
    redesign is 1.3.2.)*
89. **At the largest text size the first-run screen scrolls under the status bar.** Seen on iOS 18.6
    and 27.0 in stage 1's probe: scrolled up, the question's first line runs beneath the clock. The
    screen is the old one, replaced in stage 5; recorded so the new one is checked for it.
    **2026-10-11: Home does it too**, now that it scrolls: at the accessibility sizes on a 375 ×
    667 pt phone, scrolled up, the date and title pass beneath the clock. Every scroll view in the
    app sits under the status bar this way; it is one decision, not Home's.
    **2026-10-14, the redesign's stage 5:** the old screen is gone. The welcome carries History's
    remedy (#108) — one point of top padding, `WelcomeView.swift:244`, so a step scrolled up is
    clipped under the clock rather than drawn across it. The stage's own render of the 375 × 667 pt
    phone at `AccessibilityXXXL` on iOS 26.5, after the owner's rulings, shows two steps scrolled
    up — the calculator and the foot of the vessels — clipped at the status bar's lower edge with
    nothing under the clock: the welcome holds it there. iOS 27.0 and 18.6 were not rendered
    scrolled up. *(This note first said no render had looked; a fresh reader of the fifty-ninth
    pass opened the render.)* Home's half is unchanged.
90. **Eight simulators were made on 2026-10-09 and 10 and are still there.** `xcrun simctl create`,
    after the owner ruled the tests onto made-for-purpose devices: *WaterBuddy Screenshots 6.9*
    (iPhone 18 Pro Max, iOS 27.0), *WaterBuddy Probe 27* and *WaterBuddy Gate 27* (iPhone 17, iOS
    27.0), *WaterBuddy Probe 26.5* and *WaterBuddy Gate 26.5* (iPhone 17, iOS 26.5), *WaterBuddy
    Fallback 18.6* and *WaterBuddy Gate 18.6* (iPhone 16, iOS 18.6), *WaterBuddy Watch 27* (Apple
    Watch Series 12 46mm, watchOS 27.0). **Probes pour on the Probe and Fallback devices and the
    gate runs on the Gate ones** — a probe device's days fill up and trip #62. The probe devices
    also had their goal, their Cup and their notification permission changed by the controls pass.
    One existing device was written to as well: the iOS 27.0 *iPhone 18 Pro Max* `D0D8B927` has
    WaterBuddy 1.1 and five servings from a discarded capture run.
    **2026-10-11:** stage 2 used one of these — *WaterBuddy Watch 27*, for the watch gate — the
    stock iOS 27.0 *iPhone 17* for the unit gate, and twenty-one it made for everything else
    (#102). *(Not only the gate: the unit runs of 2026-10-10 named the stock *iPhone 17* as well —
    the tasks' red runs and the eight whole-target runs. On 2026-10-11 the unit runs before the
    gate went to two of the stage's own devices instead — the fix pass's red and mutation runs,
    the one whole-target run that failed, and the twenty flake runs. The forty-eighth pass wrote
    "every development unit run … the flake runs" and "unit tests keep nothing on a device"; the
    first is wrong by the logs' own destinations, and the second by the project file — the unit
    target is hosted in the app, whose launch stamps the simulator's group container.)*
    **2026-10-11, the fiftieth pass: stage 3 reused these, and made one — nine now.** Probes
    that pour ran on *Probe 27*, *Probe 26.5*, *Fallback 18.6* and the new *Small 26.5*; the UI
    gate and the UI tests' red and green runs went to the *Gate* devices, and so did twenty-one
    probe runs that pour nothing — the text-size renders and the frame dumps, on *Gate 27*; the
    watch gate went to *Watch 27*, and every unit run whose log was kept — nineteen — to the
    stock iOS 27.0 *iPhone 17*. **Made: *WaterBuddy Small 26.5***,
    `D24E2190-9884-48D5-9C59-63D94A6A56D3`, an iPhone SE (3rd generation) on iOS 26.5 — a 375 ×
    667 pt screen, which none of the eight has. No `shutdown all`; each was shut by its own id.
    What the stage left on them: *Fallback 18.6* and *Small 26.5* had every serving deleted by
    the delete-path probe and hold one each; the *Gate* devices hold the servings each UI run
    pours. The session's scratch folder is 4.4 GB, most of it result bundles and two build
    folders; the data volume read 87 % used, 59 GiB free, at the end.
    **2026-10-20, the seventy-fifth pass: five more, for roadmap item 1.3.2's renders** (its plan's
    P1), all on watchOS 27.0, unpaired, each booted once and shut down by its id — *WaterBuddy Probe
    Watch 40* (SE 3 40mm, `C60FBB91-334A-45EC-AB3A-82FDA4991970`), *… 42* (Series 12 42mm,
    `DC08267C-81BF-491A-9A4B-309694EAF9AF`), *… 44* (SE 3 44mm, `08E01774-734C-4ED1-9BA1-E54F80041CD7`),
    *… 46* (Series 12 46mm, `EA3FF10C-2EC4-4377-A055-8D20D2AD64D9`) and *… 49* (Ultra 4 49mm,
    `EDFA3558-DF3C-42B6-8CCA-2EEC46D1B20A`). Nothing installed on them yet. *WaterBuddy Watch 26* and
    *WaterBuddy Probe Watch 26* wait for the runtime (#77). *WaterBuddy Probe 27*, found booted, was
    shut down by its id; *WareStack 18.6*, another project's, was left as it was.
91. **What the final review of stage 1 found and nothing was done about** — smaller things, each the
    owner's or a later stage's:
    **2026-10-11: (a) is retired — fixed on disk, staged in stage 2 — and two of (d)'s three
    comments are corrected.** `routed` branches on the base, the background alone changes with the
    setting, and Reduce Transparency was flipped on and off under a running Home on iOS 27.0 and
    26.5: every pane changed and every control still answered. `glassIsPressed`'s DocC names the
    primary surface and `systemGlassAvailable`'s gives the stage boundary as its reason;
    `LiquidGlassTests.swift:144` still says `Base` is not `Sendable`. In (e), `systemPane` is
    now `sampling(_:)`; the point stands under the new name.
    **2026-10-20: (b) is retired — fixed on disk, staged in roadmap item 1.3.2's stage 7a.** The
    watch's *More* capsule and the sheet's rows pass `interactive: true`, so on Apple's glass they
    take the regular, tinted variant; rendered on watchOS 27.0, their white labels read 8.68 and
    6.87–6.92:1 (*The watch's glass, measured*, `docs/DESIGN.md`).
    (a) **A Reduce Transparency flip rebuilds a pane's content.** `LiquidGlassModifier.routed` puts
    `content` in a different branch of a `switch` for each pane, where the old modifier branched only
    the background. Nothing inside a pane owns state today, so nothing is lost; a later stage that
    puts a `ScrollView`, a sheet or `@State` inside one would lose it on the flip. One structural
    path — branch the background only, and hand `glassEffect` `.identity` when the pane is not
    Apple's — avoids it. Stage 2 touches this code for the glass container.
    (b) **`systemVariant` knows the vessel as "sheer and not interactive".** The watch has two sheer,
    non-interactive capsules that carry labels (`WristView.swift`); when stage 7 turns Apple's glass
    on for the watch they would take the clear, untinted variant.
    (c) `PrimarySurfaceTests` does not cover the pressed shade (about 8.8:1 at the foot, by the
    reviewer's arithmetic) and assumes a white fill.
    (d) Comments: `LiquidGlassTests.swift` says `Base` is not `Sendable` because of `Material`, and
    the SDK declares `Material: Sendable`; `glassIsPressed`'s DocC does not name the primary surface
    as a reader; `systemGlassAvailable`'s DocC gives a missing runtime as its reason, and a watchOS
    27.0 runtime is installed now — the reason is the stage boundary.
    (e) Rule wording, the owner's: `60-design-system` says "both hand-made branches" where one of
    the two is the opaque pane, and "Raising the tint is the wrong fix" without "on the hand-made
    stack"; `15-project` says the flag test "keeps the two in step", and it compares the flag with
    the system, not with `systemPane`.
    (f) `lineWidth: 1` is a literal in both views that draw `LiquidGlass.Selection`'s rim, and the
    press spring is a literal in three places, kept equal by prose.
    (g) The empty vessel on Apple's clear glass reads 4.41–4.50:1 for its millilitre line, and no
    capture of the shipped app with an empty vessel exists to compare it with (#81).
    (h) On Apple's glass the goal slider's accessibility frame is its whole card (346 × 156 points);
    on the hand-made glass it is the slider's own. Seen in the probe's frame lists; `adjust` works
    on both. Whether VoiceOver's focus ring looks right there is a device check.
92. ~~**A test that corrupts a store and expects the next read to fail is a race, and it lost twice
    while stage 2 was built.**~~ **Retired 2026-10-11 (the fiftieth pass) — the fix is on disk,
    staged beside the redesign's stage 3 as its own change of two test files.** In stage 3's gate
    the whole unit target ran three times on the stage's source: **failed, passed, failed**, each
    failure this test at `folded == 0` (once with `manager.currentWater == 100` as well) — twice
    in three, with 35 more tests in the process than the one-in-twenty-two below. The test now
    builds its store with `UnreadableStore`, calls `breakReads()`, and asserts `!store.stillReads`
    before anything else; `folded == 0` and `currentWater == 100` are untouched. With the store
    left readable all three expectations fail. After it, five whole-target runs of five passed,
    the first from a cold simulator. `UnreadableStore.swift`'s DocC says the older technique is
    gone. The entry as it stood:
    `WristIngestTests.aFailedExistingLogsReadDeclinesTheWholeBatchRatherThanTreatingEverythingAsNew`
    overwrites the store file under an open context, deletes its `-wal` and `-shm`, and asserts the
    read fails; SQLite notices an unlinked file from a background queue. **First on 2026-10-10**,
    in the first whole-target run after two of stage 2's own tests had copied its technique
    (`folded == 0` read 1); one of those two then failed the same way, and both were moved onto
    `UnreadableStore`, which fails every time by renaming the table through a second connection.
    **Then on 2026-10-11, in one of the twenty-two whole-target runs made after that move** — the
    cold run straight after a simulator boot, 11.9 s where a warm run takes 6; the twenty-second
    is the gate's, which passed. Measured, not assumed: `b8a1386`'s own build passed ten warm runs
    of ten (387 tests) and so did stage 2 (444). Stage 2 adds 57 tests to its process.
    **The assertion is untouched and the file is outside stage 2.** Moving that one test onto
    `UnreadableStore` is about fifteen lines and its own change.
93. **Deleting a serving whose store has become unreadable crashes the app.** Found by a mutation
    in stage 2, not in use: with the servings' table gone, `modelContext.delete` on a row read
    earlier makes Core Data fault the row, fail, and throw `NSInternalInconsistencyException`
    ("Unhandled error occurred during faulting") out of `modelContext.save()` — an Objective-C
    exception, which `saveAndRecompute()`'s `do/catch` does not catch. `undoLog(id:)` cannot reach
    it: it reads today's rows fresh and stops when the read fails. **`deleteLog(_:)` can**, from
    History's swipe, on a row the screen is still drawing. Older than the redesign; the store
    failing under a running app has not been seen outside a test.
94. **On a new iOS 27.0 simulator's first boot the reminders switch raised no permission alert.**
    Two taps sixteen seconds apart, the switch hittable and fully drawn, no alert, the switch off —
    on two new *iPhone 17 Pro Max* simulators; on a new *iPhone 17* the second tap raised it.
    **`b8a1386`'s own build did the same on another new device**, and a second launch on a warm
    device raises it at once, every time since. A condition of the simulator, by that control; the
    cause was not shown, and it has not been tried on a device.
    **2026-10-11, the fiftieth pass: reminders could not be switched on for stage 3, and it cost a
    render.** The probe's reminders test tapped the switch in seven runs — five on *WaterBuddy
    Probe 27*, two on *WaterBuddy Probe 26.5*, devices made on the night of 2026-10-09 and used
    since, not new — and each time no alert was raised and the switch read off. **In three of the
    seven, on both devices, Settings listed *Open iOS Settings***, which is what a refused
    permission shows: there the cause may be an earlier refusal and not this entry's first-boot
    condition — #90 records that the probe devices' notification permission was changed by an
    earlier pass. Which it was is not shown. *(The stage's ledger says "three attempts on Probe
    27 and one on Probe 26.5 … on one run"; the logs say this.)* So the bell that History's strip draws at the next reminder was rendered from a
    stand-in time, and **its wiring to `manager.nextReminder` has not been seen drawing**.
95. **Home's text on the aurora passes by one yardstick and not by the other — the owner's ruling.**
    Stage 2 gave that text two shadows (`legibleOnBackdrop()`, the widget readout's recipe) and
    measured it beside its glyphs, where a shadow darkens the ground, off a minute's sweep; every
    earlier figure in this project was taken on clean ground a few points out. Side by side, the
    same captures, worst frame, iOS 27.0: the Bottle's amount **4.59 beside / 4.12 clean**, its name
    4.72 / 4.20, the quiet line 4.95 / 4.70, the date 4.87 / 4.78, the vessel's line 4.80 / 3.26
    (#81), its `%` 3.43 / 2.71 against 3, over a full vessel. **How it came about:** the first
    table of the stage was the clean-ground one, on iOS 26.5, and it failed; the building session
    then added the shadows and ruled that shadowed text is measured beside its glyphs, writing the
    cost down as "the beside-glyph method flatters text whose shadow a reader's eye does not
    credit". The clean-ground table for the final source, on all three systems, was not taken
    until the docs were written. The plan said clean ground, and reserved text that still failed
    at full white for the owner; the final reviewer called the ruling sound and the owner's to
    accept.
    **What the reviewer wrote, from the session's own record (2026-10-11, the forty-eighth pass):**
    "`legibleOnBackdrop` and measuring beside the glyphs: sound, but the owner's to accept. … The
    yardstick changed, though. Plan Task 8 Step 5 says clean ground, and Step 6 reserves text on
    the aurora that still fails at full white for the owner. … '0 of 12 under floor' and closing
    #81 both rest on the new method. Surface that to the owner rather than only recording it in
    `docs/DESIGN.md`." So the change was the session's own ledgered ruling **and** the reviewer
    pointed it out and asked that it go to the owner. The forty-seventh pass's records said the
    reviewer "did not find" it; that was written from a ledger line, not from the report, and is
    wrong. "Not taken until the docs were written", above, is right for the three-system table:
    it was computed over the three final sets of captures at 12:21, after the gate — by the
    session's own record of its commands; no file kept that time.
    **By the first, nothing on Home is under its floor on iOS 27.0, 26.5 or 18.6; by the second,
    four pairs are, on all three: the Bottle's two captions (4.12–4.43), the vessel's line
    (3.26–3.45) and its `%` over a full vessel (2.71–2.75).** **A fifth is at the edge:** the quiet
    line reads 4.58–4.70 on clean ground on the final source, and read 4.48 in that first table —
    an earlier build, before the column's layout moved the line, and another minute of the aurora.
    The Bottle's amount has 0.09 to spare even by the first. If the second is the measure, the remedies are a pane under the captions,
    and a heavier scrim or a pane under the vessel's line — the second is the watch's #44 again.
    **2026-10-11, the fiftieth pass: History has a line of the same kind, staged** (the redesign's
    stage 3). The owner's "go" to that stage took clean ground as its floor and both yardsticks
    as its record. History's heading and the total under it sit straight on the aurora with the
    same two shadows — `legibleOnBackdrop()` now lives in `AuroraBackground.swift`. Worst frame of
    a minute at rest and a minute scrolled, iOS 26.5 / 27.0 / 18.6: **the total, `.headline`,
    reads 4.45 / 4.44 / 4.34 on clean ground against 4.5, and 4.65 / 4.68 / 4.62 beside its
    glyphs**; the heading, large text with a floor of 3, reads 4.74 / 4.74 / 4.61 and 5.19 / 5.19
    / 5.07. So by the stage's own floor one line of History ships 0.05 to 0.16 under, on every
    system, and by the other yardstick it passes. It was not restyled: it is Home's recipe on
    Home's backdrop, and a darker halo in the one shared function would move Home's four lines
    with it. **One ruling settles both screens.**
    **2026-10-13, stage 3c:** the vessel's ml line over water, clean ground, worst frame of a
    minute: 4.05 (iOS 27.0), 4.05 (26.5), 4.20 (18.6), and 4.12 at rest under Increase Contrast —
    water, not glass. Stage 3c drew nothing over the water (its highlight is at the vessel's top
    left); no before-and-after figure was taken. The ruling still waits.
    **2026-10-14, the sixtieth pass:** the welcome is a third screen with text on the aurora
    through `legibleOnBackdrop()` — five sites in `WelcomeView.swift`. It was measured on clean
    ground, the stricter yardstick, and nothing is under its floor there (*Welcome, measured*), so
    the ruling would change no figure of its; it is named so the ruling is known to reach it.
96. **Under VoiceOver an *Undo* offer stands until something ends it, and while it stands the quiet
    line is not there.** Spec §5.2 gives VoiceOver no deadline. So a VoiceOver user who pours from
    Home and stays there does not hear *Next reminder* or *Last drink* again until the tab changes,
    because each pour stands a new offer. Stage 2 added one ending the spec does not list — **the
    app going to the background** — after the reviewer pointed out that an offer made in the
    morning was still there in the afternoon. Not decided: drawing the quiet line under the capsule
    while VoiceOver runs, or a long deadline in place of none; and Switch Control, whose users get
    the eight seconds.
97. **At its 200-point floor the vessel's millilitre line is 11 points, whatever the text size.**
    The line is a ratio of the vessel (rule `65-accessibility`), and large text makes the vessel
    give way to the quick-add row: on a 402 × 874 pt phone it is 245, 228 and 210 points at the
    first three accessibility sizes and 200 from the fourth. A floor that rose with the text size
    was built and reversed (`docs/DESIGN.md`, *Home, measured*). The status line under the vessel
    carries what is left in scaled type, and VoiceOver the whole of it.
98. **A time-zone change that does not change the day leaves Home's date behind.** `dayDidTurn()`
    republishes only when `resetIfNeeded()` reports a new day, which is what
    `aTurnThatIsNotANewDayRepublishesNothing` pins. `history.last?.date` is then the old zone's
    midnight, and flying west with the app open it formats as yesterday under *Today*, until the
    next foreground or tab change. By reading; the reviewer's finding.
99. ~~**The streak is re-read from its first window on every republish.**~~ **Retired 2026-10-18 —
    the fix is on disk, staged** (unstaged when its records were written; the lag fix's change B, spec
    `2026-10-18-the-streaks-cost-design.md`). `republishHistory()` runs
    twice in a pour, and `readStreak()` walks 30, then 120, 480 and 1,920 days until the run ends
    inside a window — so a run of four months costs 630 days of rows, twice, on the main actor,
    inside the tap. Nothing today; it grows with exactly the thing the feature rewards.
    *(2026-10-18: measured before the fix, Debug, simulator, in-memory store — a pour 1.7, 6.0, 20.8
    and 74.7 ms at 7, 45, 150 and 500 days of history, a `refresh()` 0.6, 3.0, 10.3 and 37.0 ms; after
    it, a pour 1.4–1.7 ms and a refresh 0.4–0.6 ms at every size. The run of days before today is
    kept in memory, `closedRun`, and counted again only when the app changes one of them, the goal
    moves, the zone changes or the day turns. A goal change and a launch still count it in full.)*
100. **Small things stage 2's review and renders turned up, none fixed** *(until stage 5, which
    fixed (d) on disk — its note below)*:
    (a) *Undo* plays its confirm haptic even when there was nothing left to undo.
    (b) `WristVessel.swift:126` cites the key `%1$d / %2$d ml` in a comment; stage 2 removed it
    from the phone's catalogue with its only reader. *(2026-10-17: gone — roadmap item 1.2.6 rewrote
    `readout`'s DocC when it moved to `figure`.)*
    (c) Russian and Uzbek dates begin lower-case — *воскресенье, 11 октября* — as iOS's own Lock
    Screen writes them. The ten new strings have not been read by a native speaker of either.
    (d) *Next reminder* shows the planned time even if permission has since been revoked in iOS
    Settings; stage 5's permission reconcile is what closes it. *(2026-10-14, stage 5: fixed on
    disk, staged — every return to the foreground reads the system's answer through
    `ReminderPermission.reconcile(_:using:)` and turns reminders off on *denied*, which empties the
    plan *Next reminder* is cut from; `aReReadTurnsRemindersOffWhenTheyAreRefused` pins the
    reconcile. The walk on a device is #130(c).)*
    (e) `testADiscAndUndoAnswerOffTheirGlyphs` pins the outcome on Home and cannot see the content
    shape: with it removed on iOS 26.5 the test still passes. Its DocC says so.
    (f) On a 375 × 667 pt phone at the largest text size in Russian, the stacked *Undo* capsule is
    191 points tall and the quick-add row is under the tab bar while it stands. The screen scrolls.
    (g) The streak chip's number and the status line animate with `contentTransition`; neither was
    watched frame by frame.
101. **A failed `xcodebuild test` does not exit for about ten minutes.** After a failing run it
    collects diagnostics; the tests had finished and the process sat at 0 % CPU until it was killed
    (twice on 2026-10-10; #57 saw the same 600 seconds on a UI run). `-collect-test-diagnostics
    never` ends it at once, and every development run of stage 2 carried it from then on. **The gate's commands
    in rule `85-testing` do not**, so a red gate run will outlast the 600-second foreground limit.
    Adding the flag there is a rule change, and the owner's.
    **2026-10-11, the fiftieth pass: stage 3 carried the flag until 17:43, lost it, and met this
    twice.** Of the 120 test logs the stage kept, 79 have `-collect-test-diagnostics never` —
    every run up to 17:43, the tasks' red runs among them — and the 41 from 17:47 on do not: the
    gate, which the rule writes without it, and with it the review's fix runs and the late
    probes. The session's context was summarised between those two minutes and the summary does
    not mention the flag. After that a UI run expected to fail finished in 47 seconds and its
    process sat for ten minutes, and a failed whole-target unit run (#92) sat for nine; both
    were moved to the background by the foreground limit and stopped by hand, their logs
    complete. **Not every failing run waits**: the gate's first failed unit run exited at once.
    Later runs expected to fail were watched for their suite's last line and stopped. The flag
    is still not in the gate's commands.
102. **Twenty-one more simulators were made on 2026-10-10 and 11, all named *WB2 …*, and are still
    there** — beside #90's eight, on a disk that is 90 % full. Stage 2 measured on new devices
    rather than on #90's probes, so that every pass started from an empty day: *Probe*, *Final2*
    and *Gate* on iOS 27.0, 26.5 and 18.6; *Final* and *Last* on 27.0 and 26.5; and *Small 26.5*
    (iPhone SE, 375 × 667 pt), *Large 27*, *Dev 27*, *Lang 27*, *Cold 27*, *Cold HEAD 27*,
    *Widget 27*, *Widget HEAD 27* — thirteen and eight, counted with `simctl`. The evidence is in
    the session's scratch directory, not in them; none is needed again. `xcrun simctl delete` on
    a name removes one. **And the session ran `xcrun simctl shutdown all` before most of its
    runs**, as rule `85-testing`'s gate block writes it, against a note that another project's
    simulators may be running on this Mac; nothing else was booted the one time it looked, and
    from the watch gate on it shut devices down by UDID.
    **2026-10-11, after the forty-seventh pass: the owner deleted all twenty-one.** `simctl list`
    names no *WB2* device and still names #90's eight *WaterBuddy …* ones. The data volume read
    90 % used, 45 GiB free, straight after the delete, and **82 %, 78 GiB free, twenty-five minutes
    later** — the space came back with a delay, some 33 GiB of it. *(This note first said "the
    devices were not what filled it", from the one reading taken at once. Both readings are this
    session's own `df`, at about 13:17 and 13:42, and are kept nowhere else. Nothing else was
    deleted in between by this session; what else the system reclaimed is not known.)* The half
    about `shutdown all` is a habit, not a state, and stays open with rule `85-testing`'s wording —
    **and with the stage's own plan, which wrote `xcrun simctl shutdown all` six times — in its
    preamble and in three of its steps — and the making of five *WB2* simulators into its first
    task and three more into its last**, before any of it ran. *("Into six of its steps" until the
    forty-ninth pass.)*
103. **Stage 2 left one rule's count and several comments behind, and a doc sync may edit neither.**
    Found by the forty-seventh pass's readers, each checked against the file. A comment-only
    change, and a rule edit that is the owner's:
    (a) **Rule `25-shared-storage` says "Six sites are guarded"** and gives `drawsHistory` one,
    `republishHistory()`. `republishStreak()` is a seventh (`DataManager.swift:985`), behind the
    same question — its own guard, because the `dailyGoal` setter calls it directly. *The process
    role*, above, and `docs/STATE.md` now say seven.
    (b) **`Role.drawsHistory`'s DocC** (`DataManager.swift:1588`) says it "Gates the seven-day
    roll-up". It gates the streak as well.
    (c) **`WaterBuddyWidget.swift` describes the app's old vessel in three comments**, in a file
    stage 2 did not open: `:331` "at 280pt is 5pt of surface" (300, and 5.4); `:375–378` "the app
    softens the same glyph to 0.8 … the app's 25pt" (the app's `%` is full white and 30 pt);
    `:386` "Two shadows where the app has one" (the app has two). The widget's own values in
    those comments are right. `WristVessel.swift:126` is #100(b).
    (d) **`testTheStatusLineIsNeverSqueezedToMakeRoomForTheVessel`'s DocC says "72 %".** 18.67 of
    26.33 points is 71 %. The title test's 72 % (29.3 of 40.7) is right.
    (e) Older, in the same files, found on the way: `DataManager.swift:58` and `:68` name
    `HomeView/servings` and `HomeView.servings(for:)` — it is `servings(amounts:)`; `:550` names
    `migrateFromStandardIfNeeded` — it is `migrateIfNeeded(from:into:)`; `:2269` cites
    "`DataManager.servings`, `:238-253`" — `:279–295`. `LiquidGlassModifier.swift:30` says ×1.35
    moves a 0.07 tint "four thousandths"; it is about 0.025, as `docs/DESIGN.md` has it.
    `AuroraBackground.swift:69` calls a light's `period` "one there-and-back" where the animation
    runs one leg in that time, and `:86` gives the composition 3.8 hours to repeat where that
    makes it 7.6 (`docs/DESIGN.md`, *The aurora moves*, recomputed in this pass). Rule
    `25-shared-storage` says "The watch's suite holds three keys" over a table that puts the
    third, `wristApplied`, in the phone's.
    **(f) More of both kinds, found by the forty-eighth pass's readers and each opened here.**
    *Left by stage 2:* `HomeView.swift:758`, in `HomeColumn`'s DocC, repeats (d)'s "72 %" for the
    status line. `WristVessel.swift:127`, the line after #100(b)'s, says "the phone draws
    `1300 / 2000 ml` in every language" — Home groups its figures now and has no such line
    *(2026-10-17: gone — roadmap item 1.2.6 rewrote `readout`'s DocC when it moved to `figure`)*. **Rule
    `65-accessibility`, line 123** (of the working-tree copy; 112 as committed)**:** "The widget
    draws its `%` glyph at full white rather than the app's `.white.opacity(0.8)`" — the app's `%`
    is full white since stage 2; the same fact as (c). *Older:* the DocC on `HydrationProvider`
    (`WaterBuddyWidget.swift:63–65`), unchanged since the first commit, says constructing a
    `DataManager` in the widget makes "four writes", materialising the goal and stamping the day
    among them; in an extension the goal's write and the **fresh-install** stamp are behind
    `role.ownsSharedStorage` and do not happen, while the rollover's stamp is unguarded and can
    (rule `40-widget` has it right; `docs/WIDGET.md` corrected, and `CLAUDE.md`, which said the
    same, in an unstaged edit; *listed under "left by stage 2" until the forty-ninth pass*).
    `HomeView.swift:56` calls `servings` "a `static let` evaluated once" — it
    is `static func servings(amounts:)`; `HomeView.swift:952`, in the preview, says "tapping + in
    the canvas" on a screen that has no `+`. The DocC on `Key.all` (`DataManager.swift:155–158`)
    says the roster sits "three lines under" its declarations and that
    `theTripwireHelperEnumeratesEveryStoredKey` "fails the moment they disagree" — that test's own
    DocC says it cannot (#10). `Haptics.swift:23–24` says intensity "can deliver only a quarter of
    the requested increase"; 0.8 to 1.0 of a requested 0.8 to 1.2 is half (`docs/DESIGN.md`
    corrected). `AuroraBackground.swift:34` says the three periods "never re-sync"; they do, every
    7.6 hours. **Rule `50-views`, line 134** (119 as committed), still says three previews omit
    `rescheduleReminders` (#14, fixed). And **`CLAUDE.md` and rules `15-project`, `40-widget` and
    `85-testing` still say no scheme compiles a sibling's sources** (#69) — today's saved logs
    show the app scheme's build compiling the widget extension, the watch app and the watch
    widget, and the widget scheme's compiling the app.
    **(g) Found by the forty-ninth pass's readers, each opened here. All older than stage 2 except
    the first.** *Source comments.* `DataManager.swift:1456`, on `usualSlot`: "Named once, because
    two things read it" — three since stage 2 (#104). `DataManager.swift:1119–1123`, in
    `saveDailyGoal`: "`WristView` gates its whole UI on `mirror.isGoalSet`, so their watch would
    be stuck on the empty state forever", and "the way every other publish site in this file
    does" — `WristView`'s own DocC says the screen is never gated, and `refresh()`,
    `applyDailyReset(on:)` and `WristLink`'s two session callbacks publish with no guard.
    `:1219–1220`, in `refresh()`: "there is no launch-time or activation-time publish anywhere
    else in this file" and "would sit on `WristView`'s empty state forever" — `:2640` publishes at
    activation. **The forty-eighth pass copied the first of these into `docs/STATE.md` as fact.**
    `:1381`: "`refresh()` always ends in one" (a reschedule; its last call is the wrist's
    publish). `:615`, on `addLog`: "This is the only way water enters the product" — `ingest(_:)`
    and the one-shot seed insert rows too. `:2148–2150`, on `WaterSnapshot`: the "four writes" of
    (f). `:2175–2176` and `:2207–2208`: "the app scheme never compiles" the widget (#69).
    `AddWaterIntent.swift:49`: "`addWater` does the real clamping regardless of what any caller
    asks" — it clamps nothing; the derived total is clamped. `WaterLog.swift:30`:
    "`fetchLogsForToday()` never compares instants" — its predicate compares the row's instant
    with two bounds; what it never consults is a stored day. `WaterSnapshotTests.swift:44`:
    "`theTripwireHelperEnumeratesEveryStoredKey` now pins the two together" (#10).
    `RootTabView.swift:130–131`: `.frosted` and `.floating` is "the only place in the app that
    uses it" — the first-run card (`GoalSetupView.swift:149`) and the serving sheet's card
    (`HistoryView.swift:824`) use the pair too, as they did at `b8a1386`, where rule
    `60-design-system` says "treat it as reserved". *Rule lines, the owner's.* `25-shared-storage`
    line 117: `Key.wristOutbox` "read by `WristModel`, on the watch" — the complication reads it
    as well. `00-workspace` line 31: "`WaterBuddy/` the app — SwiftUI, iOS 26.5" — the floor is
    17.0. `70-privacy` line 15: "the only entitlement on either signed target" — four. `40-widget`
    line 168 spells the Lock Screen button `AddWaterIntent(amount: entry.snapshot.serving)`; the
    code hands `snapshot.serving` down and writes `AddWaterIntent(amount: serving)`. `20-state`'s
    mutation list, at `b8a1386` and as reworded for stage 2, has no `ingest(_:)`. `10-architecture`'s
    diagram labels the SwiftData store "app only" while drawing `AddWaterIntent` writing through
    `DataManager` — the extension's write door opens that store. *And one in a file stage 2
    added:* `UnreadableStore.swift:23` says "Here nothing is unlinked", of how the fixture makes a
    read fail; its `remove()` does unlink the throwaway directory at the end and says so — the
    second of four parts of the stage reviewer's item 14, answered in one place and not the other.
    **(h) The fiftieth pass, after stage 3: where the lines above stand now, and what moved in the
    comments themselves.** Stage 3 adds 53 lines to `DataManager.swift` — 15 at `:882`, 14 at
    `:2128`, 24 at `:2773` — takes 15 out of `HomeView.swift` at `:934`, and rewrites
    `HistoryView.swift`. So, of the citations in (a) to (g), each re-read at its new line:
    `DataManager.swift:985` is `:1000`, `:1119–1123` `:1134–1138`, `:1219–1220` `:1234–1235`,
    `:1381` `:1396`, `:1456` `:1471`, `:1588` `:1603`, `:2148–2150` `:2177–2179`, `:2175–2176`
    `:2204–2205`, `:2207–2208` `:2236–2237`, `:2269` `:2298`, `:2640` `:2669`; `:58`, `:68`,
    `:155–158`, `:550` and `:615` stand where they did. `HomeView.swift:952` is `:937`; `:56` and
    `:758` stand. `HistoryView.swift:824`, the sheet's card, is `:1266`.
    `UnreadableStore.swift:23` is `:24`. **Two rule lines in (f) moved as well**, by this
    stage's own unstaged wording above them: rule `65-accessibility`'s "full white rather than
    the app's" is line 134 of the working-tree copy and 123 as committed, and rule `50-views`'s
    "currently omit it" is line 142 and 134. The four rule files (g) cites are not among the two
    this stage's wording touches.
    **None of those comments was changed** — stage 3 opened
    `DataManager.swift` to add, and `UnreadableStore.swift` for one paragraph above that line.
    *Corrected by stage 3, in `HistoryView.swift`, on its reviewer's list:* a row's "the idiom the
    vessel and this screen's own header use" (the header no longer wraps its title); the week
    bar's "`Aurora.cyan` alone measures 5.22:1. A 6–90pt bar loses nothing by being one colour"
    (two fills now, both with this stage's figures); the `+`'s "11.7:1" and the empty state's
    "8.0:1 … 5.2:1" (replaced by a reading of each system). *Left by stage 3:*
    `dayFraction(of:in:)`'s DocC says "from `0` at its first midnight to `1` at its last" with
    no word of #107's exception; and `AppStoreScreenshotUITests.swift:270` cites
    `HistoryView.swift:159` for `allowsFullSwipe`, which is `:433` (#82). *Rule lines, the
    owner's:* rule `85-testing` writes the UI gate as one invocation, which no longer fits a
    foreground call (#110).
    **(i) The fifty-second pass, after stage 3b: where the lines above stand now. The
    fifty-first pass did not do this**, so from the end of stage 3b until this pass every
    citation below pointed at the wrong line. Stage 3b edits six app files and moves lines in
    each — `AuroraBackground.swift` by 6 from `:38`, `Haptics.swift` by 1 from `:10`,
    `HomeView.swift` and `HistoryView.swift` from `:121` and `:156` on, `SettingsView.swift`
    from `:42`, and `RootTabView.swift` throughout — and no shared, widget or watch file, so
    every `DataManager.swift`, `WaterBuddyWidget.swift`, `WristVessel.swift`,
    `AddWaterIntent.swift`, `WaterLog.swift`, `WaterSnapshotTests.swift` and
    `UnreadableStore.swift` citation in (a) to (h) stands. Each of the rest was found again by
    its own words, on disk and in the index: in (e), `AuroraBackground.swift:69` is `:75` and
    `:86` is `:92`; in (f), `HomeView.swift:758` is `:789`, `HomeView.swift:952` (`:937` after
    stage 3) is `:968`, `Haptics.swift:23–24` is `:24–25`, and `HomeView.swift:56` and
    `AuroraBackground.swift:34` stand; in (g), `RootTabView.swift:130–131` is `:272–273`, and
    `HistoryView.swift:824` (`:1266` after stage 3) is `:1310`; in (h), `allowsFullSwipe` is
    `HistoryView.swift:450`. `GoalSetupView.swift:149` stands; the file is not the stage's.
    **None of those comments was changed by stage 3b, and one of them is now contradicted by
    the stage's own code in the same file:** `AuroraBackground.swift:75` still calls a period
    "one there-and-back", in the same file as `AuroraDrift`, whose own property is documented
    "Seconds for one leg of the journey" (`:189`) and whose test
    `aLightGoesThereAndBackInTwoPeriods` holds it (#117). `RootTabView.swift:272`'s
    "the only place in the app that uses it" now stands on `GlassTabBar`, the bar below iOS 26
    only, and is as untrue as it was. *Rule lines:* the two rule files (h) says carry stage 3's
    unstaged wording are as (h) left them; stage 3b edits no rule file (#111).
    **(j) The fifty-third pass, after stage 3b's second pass: where they stand now.** The pass
    edits `HomeView`, `HistoryView`, `SettingsView`, `RootTabView`, `AuroraBackground` and
    `Arrival` again, and no shared, widget or watch file. Found by their own words:
    `AuroraBackground.swift:75` is `:77` and `:92` is `:94`; `HomeView.swift:789` is `:862` and
    `:968` is `:1043`; `RootTabView.swift:272–273` is `:373–374`; `HistoryView.swift:1310`, the
    sheet's card, is `:1359`, and `allowsFullSwipe` is `:462`. `HomeView.swift:56`,
    `AuroraBackground.swift:34`, `Haptics.swift:24–25` and `GoalSetupView.swift:149` stand.
    None of those comments was changed. **Two that (i) and #117 listed are corrected:** the
    harness's comment on `returnToTop`, and the DocC on `AuroraDriftTests`, which gives the
    table's own figures now. And `AuroraBackground.swift`'s DocC on its fourth constraint,
    which said each screen stands its own backdrop, says what is true since this pass.
    **(k) The fifty-fourth pass: one line (j) moved its neighbours past and left.**
    `AuroraDrift`'s "Seconds for one leg of the journey", which (i) cites at `:189`, is at
    `AuroraBackground.swift:191` — the second pass's two added lines of DocC moved it with
    `:75` and `:92`, and (j) restated those two only. Found by a fresh reader opening each
    citation.
    **(l) The fifty-seventh pass, after stage 3c: where they stand now.** Stage 3c edits
    `HomeView`, `HistoryView`, `ScreenHeader` and `LiquidGlassModifier`, and nothing under
    `WaterBuddyWidget/` or the two watch folders. Found by their own words:
    `HomeView.swift:1043`, the preview's "tapping + in", is `:1109`; `HistoryView.swift:1359`, the
    sheet's card, is `:1472`, and `allowsFullSwipe` is `:484`; (e)'s `LiquidGlassModifier.swift:30`
    is `:36` — stage 3c added `innerCornerRadius` above the DocC and a sentence to it, and left
    "four thousandths" as it was. `HomeView.swift:56`, `:862` and `:267–270` (#106) stand; so do
    `RootTabView`, `AuroraBackground`, `Haptics` and `GoalSetupView`, which the stage did not
    touch. Four more moved, found by a fresh reader and given where they are cited: #111's
    `:1326`, `:597` and `:957`, and #117's `:173–174`. Then a sweep — every `File.swift:N` the
    sheets cite into the stage's eight files, HEAD's line `N` against the tree's: everything else
    it flagged is a dated record — #14's previews, #82's and #111's earlier notes, the earlier lists
    in this issue, the sheets' own dated headers — left as written.
    **(m) The redesign's stage 5: where they stand now.** The stage adds one comment line to
    `DataManager.swift` at `:1117`, so every citation below it is one further on; it rewrites
    `SettingsView.swift`'s vessel card, grows `WaterBuddyApp.swift` and
    `AppStoreScreenshotUITests.swift`, and shortens `GoalSetupUITests.swift` (1236 lines to 1204).
    Each citation below was opened and found by its own words. **Given where they are cited:** the
    Settings row's `:242`; the process role's `:1565`, `:1574`, `:1162`, `:1329` and `:1709`, in
    `docs/AI_CONTEXT.md` and `docs/STATE.md`; #84(c)'s three. **Given here:** (b)'s
    `drawsHistory` DocC is `DataManager.swift:1604`; (g)'s "Named once" is `:1472` and its
    `saveDailyGoal` comment `:1135–1139` — those three were already stale as (b) and (g) cite them
    (`:1588`, `:1456`, `:1119–1123`), and (h) moved them to `:1603`, `:1471`, `:1134–1138` at stage
    3; #104's `:1471` is `:1472`; #105's `:1476` is `:1477` and its `resolveServings(in:)` `:1448`
    is `:1449`; #73's re-read, cited at `:1233` since the fortieth pass, is `:1398`; #37's
    `DataManagerTests.swift:1312` is `:1313`; `AppStoreScreenshotUITests.swift:518–521` (#82,
    #117) is `:530–533`, #117's `:509–510` is `:521–522`, and this issue's `:270` is `:282`;
    #117's `GoalSetupUITests.swift:156–157` is `:148–149`. Everything else flagged is a dated
    record — the earlier *Current state* blocks' `GoalSetupUITests.swift:219` among them — and is
    left as written. (g)'s first-run card on `.frosted` and `.floating` is gone with
    `GoalSetupView.swift`; the welcome's cards are `.raised`, so the serving sheet's card is now the
    one pane besides the tab bar on that pair, and `RootTabView`'s "the only place" is still untrue
    by one. *(This entry's first build mapped the old numbers through the diff without
    opening them, so four of its mappings landed on the wrong lines, and its sweep looked only for
    citations spelled with a file name and missed the three bare ones in the process role. A fresh
    reader found both.)*
    **(h) 2026-10-23, the eighty-fifth pass: set A's step 2 (staged) widens (a) and (b).**
    `republishMonth()` (`DataManager.swift:1182`) is an **eighth** guarded site, a third behind
    `drawsHistory`, with its own guard because five callers reach it outside `republishHistory()`.
    *The process role*, `docs/STATE.md` and `CLAUDE.md` now say eight; rule `25-shared-storage` —
    not among the six rule files step 2's wording touches — still says six and gives `drawsHistory`
    one. `Role.drawsHistory`'s DocC (`DataManager.swift:1963–1965`) still says it "Gates the seven-day
    roll-up"; it gates the streak and the shown month as well. A comment and a rule, the owner's.

104. **The Glass's index has three spellings.** `DataManager.usualSlot` is the name the one-tap
    doors read — `usualServing(in:)`, the Control Center control's glyph and, since stage 2, Home's
    primary disc (`HomeView.swift:108`; `:107` until 1.2.5). Two others spell the same `1`: `HistoryView.swift:305`
    (`:283` until stage 3c, `:271` after stage 3b's first build, `:240` until it, `:143` until
    stage 3) seeds a new serving's amount with `manager.servings[1]`, under a comment that says
    why; and the watch has `nonisolated private static let primaryIndex = 1` (`WristView.swift:136`). Nothing
    disagrees today. Rule `40-widget` says "never spell the index here" of the control only, and
    until the forty-eighth pass two sheets said the index "is named once" / "is spelled once".
    Found by that pass's readers; both spellings are older than stage 2. A doc sync does not edit
    code. **The constant's own DocC still says it** — `DataManager.swift:1554` (read `:1471`, already off at HEAD, until 1.2.5; `:1456` until
    stage 3), "Named once,
    because two things read it"; three read it now — and `CLAUDE.md` calls `usualSlot` "the one
    name for that vessel's index", true of the phone's one-tap doors and not of the watch.
    **2026-10-11, the fiftieth pass:** stage 3 rewrote `HistoryView.swift` round that literal and
    left it a literal; and its new `HistoryView.vessel(forAmount:amounts:)` finds the Glass by
    `isUsual`, which `HomeView.servings(amounts:)` sets from `usualSlot` — no fourth spelling.
    *(2026-10-20, roadmap item 1.3.2's stage 7b, staged: the watch's spelling is gone —
    `primaryIndex` deleted, `WristView.primary(from:)` and `secondary(from:)` read
    `DataManager.usualSlot` — so `CLAUDE.md`'s "the one name for that vessel's index" is true of the
    watch now too. `HistoryView`'s `servings[1]` remains, so this stays open.)*

105. **Two fallbacks say nothing in `DEBUG`.** `CLAUDE.md`'s *Fail Soft, Loudly* says "a corrupt
    goal falls back to the default — but every fallback says so in `DEBUG`", and rule
    `75-diagnostics` that every fallback in the product is announced. `resolveDailyGoal(in:)`
    (`DataManager.swift:1559`; read `:1476`, already off at HEAD, until 1.2.5, and `:1461` until stage 3) returns `defaultDailyGoal` for a missing or corrupt goal with no
    diagnostic, and `resolveServings(in:)` (`:1531`; read `:1448`, already off at HEAD, until 1.2.5, and `:1433` before) discards a bad triple the same way. A missing
    key is the ordinary case for both — the vessels are never materialised — so a line that fired
    on absence would be noise; whether a *corrupt* value should speak is the owner's call, and
    until it is made the sentence in `CLAUDE.md` is wider than the code. Found by the
    forty-eighth pass's reader of `CLAUDE.md`; older than the redesign. Whether each fallback is
    covered by a test was not checked. **"Two" is the two that were looked at, not a census**: a
    later reader notes the clamp on a corrupt cached total in `init` is silent as well, and nobody
    has walked every fallback in the file.

106. **The goal-reached haptic is triggered by a model value.** Rule `60-design-system`: "Trigger
    `.sensoryFeedback` from a counter bumped by the user's own action … never directly from a
    model value". `HomeView.swift:257–260` (`:226–229` until stage 3b) is
    `.sensoryFeedback(trigger: manager.hasReachedGoal)`,
    playing `Haptics.goalReached` on the rising edge — so a goal crossed by the Siri phrase or a
    pour from the watch while Home is on screen would play it, one crossed by a widget tap would
    play it when the app next comes forward on Home, and one crossed from History's sheet does not
    (the modifier is Home's). Older than stage 2 in shape: `b8a1386`
    triggered on a view-computed `hasReachedGoal`, and stage 2 moved the property to the model.
    By reading only — no haptic can be felt on a simulator, and none of this was run. Whether the
    celebration should follow the goal or the finger is the owner's call. *(Related: #100(a) —
    `undos` is bumped whether or not a row was taken back.)*
    **2026-10-12, the fifty-second pass: "one crossed from History's sheet does not" holds
    below iOS 26 only since stage 3b.** Under Apple's bar Home is kept while History shows and
    its modifier goes on watching, so the goal crossed from the sheet may play it — #114(a),
    which the fifty-first pass opened without a word here. And the model value is no longer
    the only trigger that is not a counter: the tab's tick and the sheet's are driven by a
    view's own state (#111).
    **2026-10-12, the fifty-third pass: the note above held for one build.** Since stage 3b's
    second pass a page is rebuilt when its tab is shown, on every system, and Home does not
    exist while History shows: the sentence as first written is true again, and #114 is
    retired. The modifier is at `HomeView.swift:280–283` (`:267–270` until 1.2.5).

107. **`nextDayBoundary` answers the repeated midnight, in a zone whose clocks go back across
    it.** In America/Havana the clocks go back from 01:00 to 00:00, so 00:00–00:59 happens twice
    on that night. For an instant in the first of the two hours — tried at 00:30 and 00:59;
    at 00:00 itself the answer is right — `Calendar.nextDate(after:matching:matchingPolicy:
    .nextTime)`, which is what `DataManager.nextDayBoundary(after:calendar:)` asks, returns the
    **second 00:00 of the same day**, one hour after the day began; from the second 00:00 on it
    returns the next day's, 25 hours after the day began. Read off Foundation on this Mac's toolchain for 2 November 2025 and 1 November
    2026 with a script that reads and writes nothing; America/New_York's fall-back day, whose
    repeated hour is 01:00, is right throughout. Found by stage 3's reviewer by inference and
    then run. **The function is HEAD's, and rule `30-rollover` calls it "the single definition of
    when the day turns"; stage 3 did not change it.** Its callers: today's fetch bounds, the
    history fetch, the streak's windows, the wrist mirror's `phoneDayEnd`, `WristPlan` on the
    watch, the widget's timeline, and — new in stage 3 — `dayFraction`. Worked through for
    three, during that one hour: `fetchLogsForToday()` still holds every row, since in ordinary
    use no row is later than now; `dayFraction` measures the hour against a one-hour day, so a
    serving at 00:30 is drawn mid-strip; a widget timeline built then dates its zeroed entry an
    hour after the day began and reloads there. The others were not worked through. No test
    pins the right answer, and none could be added without the fix: it would be red. The fix is
    small — ask again while the answer is still the same day — and is a change to the rollover's
    own function, with its own test and its own review; the owner's call when. Other zones with
    a transition at midnight were not tried.

108. ~~**Settings scrolls under the status bar.**~~ **Retired 2026-10-14 — the fix is on disk,
    staged with the redesign's stage 4:** one point of top padding on Settings' reader, History's
    remedy, with the point taken back off the column's inset so the title holds its place;
    in scrolled captures on iOS 27.0, 26.5, 18.6 and the 375-pt phone, content is cut at the
    status bar's edge and nothing is drawn under the clock. The entry as it was: Seen in a stage 3 capture on iOS 27.0: the clock
    drawn over a card's slider as the screen scrolled. It is the defect stage 3 found and fixed
    in History — a scroll view whose top edge meets the safe area's draws its content on up
    under the status bar — in a screen stage 3 did not open. History's remedy was one point of
    top padding on the list. Older than stage 3 by its cause; when it began was not looked for.
    #89 is the same on the first-run screen at the largest text size. Stage 4 redraws Settings.

109. **What stage 3's final review found and nothing was done about** — each small, each the
    owner's. Its report is saved beside the stage's ledger as it arrived.
    (a) `bringIntoView`, in the UI tests, checks only a row's foot against the tab bar. After a
    flick on a small phone whose day holds a dozen servings, the first row built may sit mostly
    above the list's top edge, and the bare-glass test would fail with the hit-region message.
    No swipe is needed on the gate's phones.
    (b) `testTheStripIsOneHeadingOverADaysServings` would not fail if the plot's
    `accessibilityHidden` came off, and does not check the header trait.
    (c) The shortcut-figure test at the largest text size catches a figure cut to one character,
    not a partial cut. **And the shortcut tap test does not pin the content shape**: with
    `.contentShape(Rectangle())` removed it still passes on iOS 26.5. That much was seen; why
    the tap still lands — an unselected slot's background is a capsule filled at zero opacity —
    was not looked into.
    (d) `theModelPlacesAnInstantOnItsOwnCalendar` tells the model's calendar from
    `.waterBuddyDay` only on a host that is not on UTC; `theStripLabelsTheMorningNoonAndEvening`
    restates two constants; the two daylight-saving `daysMet` tests exercise `series`; nothing
    pins that `hours` leaves out an hour the calendar cannot place, or `dayFraction`'s
    `length > 0` guard, or that the week card's spoken summary carries the days met.
    (e) `.raised` panes now sit in list rows with no clip disabled (rule `60-design-system`).
    "Not sliced" was looked at on iOS 18.6 only — Apple's glass draws no hand-made shadow — and
    iOS 17 has no runtime here.
    (f) The week card's middle layout takes up a shortfall with `minimumScaleFactor(0.95)` where
    the 2026-10-11 lesson's remedy is `.fixedSize()`; no failing case was found. A shortcut's
    weight changes with selection, so at the width where the row only just fits it can change
    layout on a tap. A day's met state is drawn — the colour, the line — and spoken only as the
    count. A vessel under 50 ml, which only a hand-edited suite can hold, moves the slider's
    lower bound and its 50 ml grid.
    (g) **Stage 2's `onlyTheSpokenHomeStringTakesARawNumber`** compares one literal in the test
    file with another, as the History twin did until stage 3 replaced it; committed in
    `1ced514`. The new table-wide test covers what it meant to. *(2026-10-17: replaced by roadmap
    item 1.2.6 — `theHomeKeysThatTakeARawNumberAreTheCountedOnes` pins Home's two counted keys, the
    status line's and the streak's, since a `%d` key now groups too.)*
    (h) Seen by the stage's own probe, older than the stage: **the empty state is two elements
    to anything that walks the tree** — the combined one and its title inside it — on iOS 27.0
    and 18.6. `emptyState` and its `.accessibilityElement(children: .combine)` are HEAD's. Not
    heard with VoiceOver.
    (i) The two-line heading's lines shrink separately, so a long weekday is drawn smaller than
    the date under it — *Понедельник* at 0.67 over *5 окт.* at full size.

110. **The UI target no longer fits one foreground call, and rule `85-testing` writes it as
    one.** Twenty-five tests of `GoalSetupUITests` took 435 seconds on iOS 27.0, 366 on 26.5 and
    343 on 18.6; the other eighteen 129, 88 and 83 — 565 seconds for the whole target on iOS
    27.0, before any build, against the 600 a foreground call is given, and `CLAUDE.md` wants
    every `xcodebuild` watched to its end. Stage 3's gate ran it as two invocations a system that
    are complements: `-only-testing:WaterBuddyUITests/GoalSetupUITests`, and
    `-only-testing:WaterBuddyUITests` with the harness and `GoalSetupUITests` skipped — the same
    43 tests. On iOS 27.0 and 26.5 they ran in that order, which is the order one invocation
    runs the classes; **on iOS 18.6 the eighteen ran first**. What two invocations cannot show
    is a dependence between the two classes across one process, and none is known. The rule's gate
    block is the owner's, and the stages that follow will add UI tests to the same class.
    **Updated 2026-10-12, the fifty-first pass: the class itself no longer fits.** Stage 3b
    added seven tests — 32 — and with the Mac busy eleven of them took 543 seconds. Its gate ran
    the class in three or four chunks a system, each named test by test with `-only-testing:`
    from a sorted list of the class's `func test` names, and the other classes as before: 50
    executed a system, one of them skipped. Each chunk carried `-collect-test-diagnostics never`
    (#101), which changes nothing a test does. **A test in the class that measures time against
    a limit** — `testAnUndoOfferDoesNotOutliveTheAppLeavingTheScreen` — refused to conclude, as
    it is written to, at a load average over 400 from two other projects' runs; it passed when
    the load fell. Read `uptime` before a gate run.

111. **Stage 3b's rule wording is written in its spec and applied to no rule file, so the code
    contradicts two rules as they stand.** `50-views`, *Navigation*: "Do not introduce `TabView`"
    — `RootTabView` builds one on iOS 26 and later. `60-design-system`, *Haptics*: "Fire only
    through `Haptics.confirm`, `Haptics.pour` and `Haptics.goalReached`" — there are five. The
    replacement text for both, and new bullets for `65-accessibility` (the arrival under Reduce
    Motion; a kept view never at zero opacity), `15-project` (the third version check),
    `85-testing` (a test that holds for one bar skips on the other) and `60-design-system` (the
    shade; the aurora's clock), is in
    `docs/superpowers/specs/2026-10-11-navigation-and-motion-design.md` §8. It was not typed
    into the rule files because `50-views` and `65-accessibility` already hold stage 3's
    wording, unstaged and unapproved, and one diff could not then be approved without the
    other. Also stale by the same change and not a doc sync's to edit: rule `15-project`'s two
    version checks, which are three now, and rule `65-accessibility`'s "The tab bar is three
    slots", which is the app's own bar's.
    **2026-10-12, the fifty-second pass: "two rules" is an undercount by the letter, and §8
    has no wording for one of them.** Found by this pass's reader. (a) Rule `50-views`,
    *Bindings and controls*: "A haptic is driven by a monotonically-bumped `@State` counter",
    and rule `60-design-system`, *Haptics*: "Trigger `.sensoryFeedback` from a counter bumped
    by the user's own action". Two of stage 3b's triggers are not counters: the tab's tick,
    `.sensoryFeedback(Haptics.select, trigger: tab)` (`RootTabView.swift:108`), and the
    sheet's, `trigger: amount` (`HistoryView.swift:1277`). Each is a view's own `@State` that
    only the user's touch writes, which is what the rule is for — "so a background write or a
    rollover cannot fire one" — and each says so in a comment that cites the rule; neither is
    a model value. Of the app's thirteen `sensoryFeedback` sites ten are triggered by counters;
    the thirteenth is #106's model value. **The
    spec's §8 proposes nothing for either bullet** — its §7 does name "the value under the
    finger in the sheet" as a trigger, and not the shown tab; a dated note in §8 now says all
    of this — so the choice is still open: reword the
    two bullets to allow a view's own selection state, or bump a counter beside each. (b) Rule
    `65-accessibility`, *Reduce Motion*: an animation that runs once per tap "gets **no**
    branch". The arrival runs once per change of tab and branches: the rise is dropped
    (`Arrival.swift:85`) and History's bars are simply there (`HistoryView.swift:581`, `:913`).
    §8 does carry this one, as a new bullet under *Reduce Motion* — "it is travel across the
    screen and not feedback under a finger" — but this entry and the stage's records filed it
    as an addition and not as a departure from the bullet above it.
    **2026-10-12, the fifty-third pass: the second pass moves what is contradicted, and its
    wording is in the newer spec.** `50-views`' "Do not introduce `TabView`" is obeyed again —
    there is none. What the code departs from now is in
    `docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md` §7, which replaces the
    older spec's §8 where they overlap: #121. The lines cited above have moved: the tab's tick
    is `trigger: turn.shown` at `RootTabView.swift:183` (`:182` until 1.2.5), the sheet's is `HistoryView.swift:1326`,
    the arrival's branch is `Arrival.lift(arrived:settles:reduceMotion:)`
    (`Arrival.swift:70–72`, used at `:106`), and History's bars are `:597` and `:957`. The
    counter question of (a) is still open and still has no proposed wording.
    **2026-10-13, the fifty-seventh pass:** stage 3c moved the two in `HistoryView.swift` — the
    sheet's tick is at `:1439`, History's bars at `:625` and `:1068`. Found by a fresh reader.
    **2026-10-14, the redesign's stage 4:** stage 3b's wording for rule `60-design-system`'s
    *Haptics* bullet — five rungs, `select` and `remove` named — is typed into the rule file,
    unstaged, for the owner's yes, with `steps` added to the counter list. Settings' two new step
    ticks are counters, so they add nothing to (a). The other rule files' wording from §7 of the
    newer spec is still not typed.
    **2026-10-14, after the fifty-eighth pass: the owner approved that wording**, and
    `60-design-system.md` is staged as typed, with stage 4. When it is committed, the first
    sentence's haptics half — "there are five" against a rule that names three — is closed; the
    `TabView` half was closed by the second pass. (a)'s counter question, the tab's tick and the
    sheet's on a view's own state, is untouched by the wording and still open, as is (b).
    **2026-10-14, the redesign's stage 5: a third tick on a view's own state** — the welcome's
    `.sensoryFeedback(Haptics.select, trigger: step)` (`WelcomeView.swift:204`), which only the
    bar's taps change; its four other triggers are counters (`goalSteps`, `finishes`, `uses`, and
    `picks` in the calculator), none of them in the rule's list of counters. `docs/DESIGN.md`'s
    haptics note records both; no wording is typed.

112. **One tab caption reads 4.01:1, under the 4.5:1 floor, and is not cured.** A 375 × 667 pt
    phone at Accessibility XXXL on iOS 26.5: Home scrolls there, the white Glass disc rests
    under Apple's bar beside the selected tab, and the selected caption read 4.01 in one
    capture (*History* 4.92, *Settings* 5.47), by the first-read method `docs/DESIGN.md`
    describes. The shade cannot darken a white surface under the bar. A hard scroll edge gives
    6.13 and cuts content off square at the bar, so nothing shows through the glass on any
    phone. Left as it is; the spec's decision N9. Not swept through the aurora's minute, and
    not looked for on other phones or with History's or Settings' content under the bar at that
    size.
    **2026-10-12, the fifty-third pass: that was the `TabView`'s bar, and it is not the bar
    any more.** Since stage 3b's second pass the bar on iOS 26 and later is a standalone
    `UITabBar`, whose glass on iOS 26.5 is darker (#119): on a 402 × 874 pt phone at the
    ordinary size every caption read 8.0:1 or better in seven frames. **This configuration
    was not taken again** — the small phone, the largest text size, the white disc under the
    bar. It is likely cured and is not known to be.

113. **On the smallest phone, under Apple's bar, Home has no room to spare.** 375 × 667 pt, iOS
    26.5, ordinary text size: everything is on screen above the bar and the vessel is at its
    200 pt floor, where it was 214.5 pt under the app's own bar in stage 2 — the header is
    taller, 13 pt by the reviewer's arithmetic, and Apple's bar stands higher than the app's. The vessels' names stand inside
    the shade's ramp and read 5.6:1 or better in one capture. A slow swipe moved nothing and
    eight more rubber-banded the column back to where it began, so it is taller than the
    screen by less than can be read off a frame, if at all. **Not re-taken:** stage 2's figures
    for what stays on screen at each accessibility size (`HomeView.vesselRange`'s DocC,
    `docs/DESIGN.md`, *Large text: what gives way*) — they are the app's own bar's, on a
    402 × 874 pt phone. The spec's decision N14.

114. **A kept screen goes on living while its tab is away, and two consequences are the
    owner's to rule on.** (a) Home watches `manager.hasReachedGoal` for its goal haptic and its
    confetti, and `manager.streak` for the flame. Below iOS 26, and on every system before
    stage 3b, Home did not exist while History was showing, so a goal crossed from History's
    sheet played `pour` alone. Under Apple's bar Home exists: the haptic may play there and
    then, on top of `pour`, or on the return to Home, and the confetti may play unseen. Which
    happens was not established — a simulator plays no haptic. Gating the two on `isShownTab`
    restores the old behaviour. It also bears on #106. (b) A kept screen keeps its scroll
    position: History comes back on today, and wherever it was scrolled. The app's own
    container returned it to the top by rebuilding it. **2026-10-12, the fifty-second pass:
    one thing in the repository depends on the old behaviour** — the App Store capture
    harness's `returnToTop`, which bounces off another tab to get back to a screen's top
    (#82). By reading only.
    **RETIRED 2026-10-12, the fifty-third pass — the fix is on disk, unstaged.** Stage 3b's
    second pass builds a page when its tab is shown and removes it when it has left, on every
    system. Home does not exist while History shows, so (a) is as it was before stage 3b; a
    screen opens at its top and History on today, so (b) is gone and the harness's helper
    works. `testAnUndoOfferDoesNotOutliveItsScreen`,
    `testHistoryReturnsToTodayWhenItsTabIsLeft` and
    `testOnlyThePageShownIsInTheTreeAfterAChangeOfTab` hold it on three systems. One page is
    still reused: a tab returned to before its page had finished sliding out, inside 0.45 s,
    gets that page back with its state (#120).

115. **`testADiscAndUndoAnswerOffTheirGlyphs` failed once on iOS 26.5, and why is not known.**
    In stage 3b's gate, the first test after *WaterBuddy Gate 26.5* booted, on the day's first
    pour: a tap 12 % down the Cup's disc — clear of its glyph — and no *Undo* within five
    seconds, the total unchanged. The run's own recording shows the disc light, grow and recoil
    under the press. Then 23 passes: six from a cold boot, four and twelve in a row, and the
    chunk's rerun. The disc and the test are stage 2's (`1ced514`) and `PressStyle` is older —
    the first commit's, last touched by stage 1 (`c9ef45d`); *"The disc, `PressStyle` and the
    test are stage 2's" until the fifty-second pass.* None had failed before
    in this repository's records; stage 3b wrapped the quick-add row in the arrival's opacity
    and offset and gave each glyph a `symbolEffect`. Whether either matters, or the machine —
    its load average had just fallen from over 400 — is not known. **If a disc ever lights and
    pours nothing on a device, this is where to start.**
    **2026-10-12, the fifty-third pass: not seen again.** The test ran once on each of three
    systems in the second pass's gate and twice before it on iOS 27.0, and passed each time.
    Nothing the second pass changed bears on it by reading: the test presses a disc on the
    page the app opens on, which still settles in as it did, and each disc now also reports
    where it stands, for the drop. Still open: one failure, no cause.

116. **Stage 3b: what was not rendered, and what waits for a device.** Not rendered: Reduce
    Motion (the arrival should be a fade alone, History's bars simply there, the aurora at
    rest) and Reduce Transparency under Apple's bar — `simctl ui` has no switch for either;
    iOS 26.0 to 26.4; where the title stands at an accessibility text size since the review's
    fix, which no test reads; Uzbek anywhere in the stage's captures. On a device: every haptic,
    and whether iOS adds a tick of its own to a change of tab or a slider's step; the drag
    along the bar by feel; VoiceOver on Apple's bar; the bar in daylight; whether a change of
    tab ever shows the quarter-second the simulator shows on iOS 26.5. iOS 17.x is
    compile-verified only, as before, and the third version check with it.
    **2026-10-12, the fifty-third pass: Reduce Motion has been run and rendered.** There is a
    switch after all — the simulator's own Settings app, which a UI test can drive
    (Accessibility, Motion, *Reduce Motion*). Under it on iOS 27.0: a change of page is a
    cross-fade in place, a pour throws no drop, nothing shrinks as it scrolls, eleven tab and
    Home tests pass, and the page left behind is removed. **Reduce Transparency was not tried
    the same way** and is still unrendered under Apple's bar; iOS 26.0 to 26.4 and the title
    at an accessibility size are as they were. "The quarter-second on iOS 26.5" is gone with
    the `TabView`. On a device, everything still waits, and the second pass adds to it: the
    slide at speed, the drop, the frame rate of two pages of glass moving at once.

117. **Comments stage 3b made false and did not correct.** `DataManager.swift`, in
    `historyWindow`'s DocC: "`HistoryView`'s 28pt margins" — the margin is every tab's 24 pt
    now, and the arithmetic beside it still holds with room (46.7 pt a day button). The file
    is one of the six shared ones and the stage's plan kept them out of its diff; a DocC-only
    edit there is the owner's to allow. `AuroraBackground.swift`'s DocC still calls a period
    "one there-and-back" and gives 3.8 hours, which #103 already records.
    **2026-10-12, the fifty-second pass: the heading fits the first of those two only, and
    there is a third.** The aurora's comment was false before the stage (#103(e), which lists
    it as older than stage 2); what stage 3b did is edit the file round it and add
    `AuroraDrift`, whose own DocC says the opposite — it is at `:75` and `:92` now. **The third is in a file
    the stage did not open:** `AppStoreScreenshotUITests.swift:518–521`, on `returnToTop`,
    describes `RootTabView` as "a `switch tab` inside a `ZStack`" whose swap rebuilds the
    scroll container and "cross-fades over 0.28 s" — the app's own container, below iOS 26
    only now. That one is more than a comment: the helper relies on it (#82). And one of the
    stage's own, smaller: the DocC on `AuroraDriftTests`
    (`AuroraBackgroundTests.swift:106–107`) gives the backdrop's change as "12 to 16 levels at
    a cut against 3 to 5 for four seconds of drift"; `docs/DESIGN.md`'s table has three cuts
    at 12.5 to 16.3, a fourth at 5.7, and drift of 3.1 to 5.5. Found by this pass's two
    readers. A doc sync edits no source and no test.
    **2026-10-12, the fifty-third pass: two of the four are corrected** by stage 3b's second
    pass, which opened both files — the harness's comment and the DocC on `AuroraDriftTests`.
    Left: `DataManager.swift`'s "28pt margins", in a shared file, and
    `AuroraBackground.swift:77` and `:94`, "one there-and-back" and "3.8 hours" (#103).
    **2026-10-12, the fifty-fourth pass: the second pass left its own — eight seen by two
    fresh readers checking the docs, two (`RootTabView.swift`'s) found by the pass itself on
    a reader's finding about the docs — and each read again here against the code.** A doc
    sync edits none of them; they go with the next change to each file.
    *Say more than was measured* — the docs said the same until this pass:
    `RootTabView.swift:229`, "no pixel of the screen's foot differed", and `:308`, "the two
    are identical" (#119: within a tolerance, and the bar differs inside it; `:228` and `:286`
    until 1.2.5, which touched the file and left both, rule `90-git`);
    `ScrollDepth.swift:18–20`, which has the line reading "about 3.8:1 in a frame of" a card
    a third past the top — the reviewer read 3.6–4.0:1 with the week card mostly out, and
    5.9–6.9:1, over the floor, with a card about a third out (*Current state*).
    *Count wrongly:* `Motion.swift:19`, sixteen older call sites "at five lengths" — six, with
    `Arrival.duration`'s 0.4; and `:55–56`, which calls 0.3 "the commonest" of them — it is at
    two of the sixteen, and 0.5 at five.
    *Describe what the pass replaced:* `RootTabViewTests.swift:76`, "the shade the screens
    draw" — `RootTabView` draws it once; `GoalSetupUITests.swift:156–157`, a screen's content
    "arrives when its tab is shown" — only the opening page's settles;
    `AppStoreScreenshotUITests.swift:509–510`, History's header and week card as "*siblings*
    of the `List`" — rows of it since stage 3 (#82).
    *Name a mechanism that is gone, though what they promise still happens:*
    `HomeView.swift:229–230` (`:216–217` until 1.2.5, which touched the file and left it, rule
    `90-git`), the screen ends its *Undo* offer "when it disappears", and
    `HistoryView.swift:173–174`, the shown day reset "when the screen disappears" — there is
    no `onDisappear`; the page is removed and its state with it, except on a tab returned to
    inside its own slide (#120 (a)). *(2026-10-13, the fifty-seventh pass: that DocC is at
    `HistoryView.swift:195–196` since stage 3c; its words are as they were.)*

118. **Seen once under load, not reproduced.** In one recording on iOS 26.5, Settings' cards
    stood at a faint frame for 2.6 seconds on their first showing before they finished
    arriving; in the next recording of the same walk they took 0.3. The Mac's load average was
    over 100. Recorded because a section drawn at 0.001 that never arrives is invisible and
    still answers a tap — which is why the test that a screen comes back whole reads the
    picture.
    **2026-10-12, the fifty-third pass: it can no longer happen on a change of tab.** Since
    stage 3b's second pass a page that slides in draws its sections whole from its first
    frame; only the page the app opens on waits hidden for its flag. There it still could.

119. **On iOS 26.x Apple's tab bar is darker than it was.** Since stage 3b's second pass the
    bar is a `UITabBar` standing alone (`SystemTabBar`), because a `TabView` offers no
    transition between its pages. On iOS 27.0 the foot of the screen is close to the
    `TabView`'s: this build against that one on a 402 × 874 pt phone, no pixel of the bottom
    700 — the bar and the row above it — differs by more than 24 levels of 255 **in grey**.
    That is the whole of the first measure (`tools/samescreen.py`, the session's scratch
    folder, which turns the difference to grey, counts pixels over that tolerance and reports
    nothing finer). "Pixel for pixel" and "identical" say more than it does: this entry,
    *Current state*, `docs/DESIGN.md`'s section and the spec said so until the fifty-fourth
    pass; `HISTORY.md`'s checkpoint of the second pass, `docs/DESIGN.md`'s retained note and
    two comments in `RootTabView.swift` (#117) still do. **Taken finer in that pass, on a
    stored pair that reproduces it** — the `TabView` build's Home against this build's
    (`tools/maxdiff.py`, `tools/bands.py`): **in the bar's own 249 px, up to 11 levels in
    grey and 26 in blue, 14 pixels over 24 in that channel; in the 451 px above it, 2 and
    4.** Two captures of the `TabView` build against each other differ by 2 and 4 at most,
    bar and all. So what is above the bar is the same to within one capture and the next,
    and **the bar itself is not quite the `TabView`'s on iOS 27.0 either** — by about 4 % of
    the range in grey, read as the same in every side-by-side render. What in the bar differs
    was not looked into: one stored pair, Home selected. *(A share of pixels "differing by
    something", 21 %, was given here in the fifty-fourth pass and withdrawn in it: by the same count two captures
    of one build differ in 14 % and 36 %.)* On iOS 26.5 it is in
    the same place at the same size — on a 375 × 667 pt phone, this build against the
    `TabView` build, the header does not differ at all and under it the only pixels that do
    are the bar's own; the same of the spike's build on a 402 × 874 pt one — and **its glass
    is smoked where the `TabView`'s was vivid** over the same aurora. Not the bar's appearance objects (a transparent and a
    scroll-edge appearance were tried), and not cured by a tab controller only as tall as the
    bar: it seems to need the pages inside the controller. Its captions read better for it
    (`docs/DESIGN.md`, *Apple's tab bar, measured*). The cure is to host the pages in UIKit's
    tab controller with a UIKit transition: kept screens again (#114), a slide that cannot be
    interrupted, and the backdrop and the shade put into UIKit's hierarchy. The spec's
    decision M1; the owner's phone runs iOS 27.0 and does not show it.

120. **What stage 3b's second pass left for a hand, a device or the owner.**
    (a) **A second tab chosen inside the 0.45 s of a slide** is exercised by no test and no
    recording: XCUITest waits for the app to be idle between taps. `PageTurnTests` holds the
    value's half — two pages at most, a slide's end matched to its turn. In the view, the
    page that was leaving is dropped where it stands (after a fifth of a second it is three
    quarters out; sooner it is seen to go), and a tab returned to inside its own slide gets
    its page back with its state.
    *(2026-10-16, the sixty-third pass: the page sliding out is still in the tree for its slide,
    so its `.task`s run on — which let 1.2.5's rating request land on the page sliding in until
    `RootTabView`'s `pageIsShown` told Home at the turn. A Home page returned to inside its slide
    comes back without the request's wait, which the turn ended.)*
    (b) **A tap on the tab already shown does nothing.** Inside a `TabView` Apple's bar
    scrolled that screen to its top; alone it only reports the tap. The owner had that for
    one build. The spec's M11.
    (c) **The scroll effect shrinks and does not fade**, where the owner chose "fade and
    shrink": with the fade, *Measured against your current goal*, 5.49:1 at rest, read about
    3.6–4.0:1 on one of the two frames the reviewer sampled, History's week card mostly out
    of the screen; on the other, a caption on a card about a third out read 5.9–6.9:1, over
    the floor (this line gave the first range's middle, "about 3.8:1", "on a card part-way
    off the screen", until the fifty-fourth pass). The spec's M8.
    (d) **For half a second after leaving History its rows are still in the accessibility
    tree** beside the page arriving: the page leaving is hidden from accessibility, and a
    `List`'s rows do not honour it. Home and Settings do.
    (e) **By reading only:** two turns made in one update of the view would leave a page
    mounted off screen until the next turn — no finger does that; the strip's bars grow again
    each time the strip is scrolled far enough away to be rebuilt by the list (not under
    Reduce Motion, where they are simply there); the drop, when
    the quick-add row has fallen back to its sideways scroll and been scrolled, starts
    wherever the disc then is. `DayStrip`'s rule for when its bars are up is written inline
    and has no test.
    (f) **No scroll effect on Home**, which fits its screen and, when it does not, rests with
    its last row part-way out.
    (g) **Probe simulators were left changed** by the walks recorded on them: *WaterBuddy
    Probe 27*'s goal is 1,800 and *Probe 26.5*'s 2,400, not the 2,000 they were seeded with,
    and *Fallback 18.6*'s, 1,900 when its walk began, was moved and is not known now; the app
    was removed from and put back on *WaterBuddy Screenshots 6.9* to record the first-run
    screen, and setup was completed there. Reduce Motion was switched on on *Probe 27* and off
    again, the switch read back both times. No gate device was touched by a probe.

121. **Stage 3b's second pass: rule wording proposed and typed into no rule file.** In
    `docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md` §7. Rule
    `60-design-system`, *Interaction*: "State changes use `.smooth(duration:)`", beside one
    named spring — there are three more curves now, `Motion.land` and `.water` springs among
    them, and the proposed wording gives every new curve a name in `Motion`. *Colour*: "Every
    full-screen view on the phone stands its own `AuroraBackground()`" — the three tabs share
    `RootTabView`'s. Rule `50-views`, *Navigation*: the `ZStack` switching on `tab` with
    `GlassTabBar` is a pager under one of two bars; *Animation*: the pager and the drop use
    `.transaction(value:)` with `addAnimationCompletion`, where the rule names
    `.animation(_:value:)`. Rule `15-project`: the third version check is the bar's. Rule
    `65-accessibility`, *Reduce Motion*: the page, the drop and the scroll effect each branch
    on it; the swell has no branch of its own and does not happen because no drop lands
    (this sentence had all four branching until the fifty-fourth pass). Rule `00-workspace`,
    one type per file: `PourDrop.swift`,
    `ScrollDepth.swift` and `Arrival.swift` each hold a pure half with the views that use it.
    Stage 3b's own proposals for its header, its haptics and its shade (#111) stand, less the
    one for a kept screen.
    *(2026-10-14, the fifty-eighth pass: one of them is typed into a rule file now — stage 4 put
    the haptics proposal into `60-design-system`, unstaged, for the owner, as #111's note says. The
    wording above is still in none.)* *(The same day, after that pass: the owner approved the
    haptics wording, and it is staged.)* *(2026-10-14, the sixtieth pass: stage 5's welcome departs
    the same two ways — its steps turn in a `.transaction(value: step)` with
    `addAnimationCompletion` (`WelcomeView.swift:236`–`:238`), as the pager does, and a turn, which
    happens once per tap, branches on Reduce Motion into a cross-fade, as the page does. The
    stage's typed rule wording covers neither.)*

122. **A UI test's runner was killed once; what killed it is not known.** 2026-10-12, 23:33,
    *WaterBuddy Gate 27*, iOS 27.0, the staged tree (stage 3) built from an export of the
    index. `testAnUndoOfferExpires`, the fifth test of a chunk of nine, started at 23:33:35.
    Its last logged step, 4 s in, is `Waiting 5.0s for "Get Started" Button to exist`. A new
    runner logs "Running tests..." at 23:34:07, then comes "Restarting after unexpected exit,
    crash, or test timeout", and the remaining four tests pass. The log ends with the test
    under "Failing tests:". The result bundle, read with `xcresulttool` that night, gave
    "Test crashed with signal term" for it; that bundle has since gone from DerivedData,
    where only the four of the 13th are left. The same test run alone at 23:46 passed in
    21.5 s, and passed in its chunk on iOS 26.5.
    **Not shown to be a matter of the boot.** *Gate 27*'s `system.log` has a `syslogd` start
    a few seconds into each of the four later runs on it, so `xcodebuild` booted that
    simulator for each of them, as it must have for the first, which found it shut down:
    five runs, four passed. For iOS 26.5 the simulator was booted once beforehand, with
    `simctl boot`, and its four runs passed. Five one way with one killed, four the other
    with none.
    **Seen beside it, from the session's own `uptime` and `pgrep` output, kept in no log:**
    2.65 at 23:30, before any of the runs, and "16.01 68.30 53.59" at 23:41; no other
    `xcodebuild` running at 23:42; and across the one minute of the solo run the one-minute
    figure went from 1.37 to 39.47.
    **No crash report could be looked for.** `~/Library/Logs` holds nothing created before
    23:46:14 that night and has no `DiagnosticReports` folder.
    The chunk did not carry `-collect-test-diagnostics never`, and `xcodebuild` exited ten
    minutes after the suite ended (#101): the log has "Failure collecting diagnostics from
    simulator: Timed out after 600.0 seconds" at 23:45:42.
123. **Under Reduce Transparency the panes are purple-grey beside blue glass.** Stage 3c made every
    pane read blue; Reduce Transparency still fills them with `Base.archived.opaqueFill`,
    `(0.22, 0.19, 0.36)`, which the spec's §10 left untouched because it is the widget's derived
    fill. Seen on iOS 27.0 and 18.6, not measured. A colour for the opaque
    pane that matches the blue is the owner's call and its own change (the final review set it
    aside; stage 3c's ledger).
124. **On a pressed disc, Apple's glass lightens to lavender and the white glyph reads faint.**
    Recorded on iOS 27.0, stage 3c: pressing the Cup disc, Apple's interactive glass swells it and
    lifts it to a light lavender while the finger is down; the lit rim brightens with it — one
    reaction. The glyph on it was seen faint and **not measured**; no rule sets a floor for a
    pressed state (rule `65-accessibility`: a once-per-tap animation gets no branch). Whether the
    press lightened this much under stage 1's black tint was not compared.
125. **What stage 3c's final review found and nothing was done about** — minors, deferred
    (`.superpowers/sdd/2026-10-13-premium-redesign-stage-3c/review-final.md`): (a) the shown
    letter's colour (`.smooth(0.3)`) and its disc (`Motion.land`) run on different clocks, a brief
    navy-on-navy or white-on-white on long jumps; (b) bars are not clipped to their tracks — a bar
    under 24 pt has corners past the track's bottom curve, as the capsules did; (c)
    `LiquidGlass.systemTintColor = Aurora.top` moves an isolation crossing into a static
    initializer Swift 5 does not check — rule `43-concurrency`'s remedy is `nonisolated enum
    Aurora`; (d) `LiquidGlass.runsOnPhone` is pinned by no test; (e) three of the vessel's ratios
    are inline (`HomeView.swift`: the glow's offset 0.5, the gradient centre 0.4 / 0.4, the fade
    0.35), and the glow's comment says "just above the vessel's foot" where the code centres it at
    the foot.
126. ~~**Stage 3c's rule wording is typed into the rule files and unstaged.**~~ **Retired
    2026-10-14, in the fifty-eighth pass — on the condition the entry set:** the commit landed on
    2026-10-13 as `c9d1f6b` (rule `60-design-system`, rule `65-accessibility`, `CLAUDE.md`) and is
    on `origin/main`. #128, the one sentence beside the wording, stays open. The entry as it was:
    The spec's §8 — five changes in `60-design-system` *Glass* and one in `65-accessibility` *Reduce Transparency* — plus
    one more the final review asked for (rule 60 *Interaction*: the sheen and rim over Apple's glass
    read `glassIsPressed` too) and one pointer (*Apple's glass, measured* → *The look, measured*). Until
    the owner says yes, the code contradicts rule 60's "on Apple's glass none of them is drawn",
    "darkened with a black `Glass.tint`", "the dark-mode black scrim" and the selection sentence.
    **2026-10-13, after the fifty-seventh pass: the owner said yes** ("Approve rule wording"), and
    both rule files are staged as they were typed — with stage 3c, for `/commit`. Retired when that
    commit lands; one sentence beside the wording is #128.
127. **The past-day empty state's line was not re-measured on stage 3c's panes.** *Tap + to add a
    serving you forgot.* (white 0.7) read 3.80:1 on the hand-made pane before stage 3c (#85); the
    probe measured today's empty state — the same card, the same white 0.7 — at 5.25 / 6.86 / 5.43
    on iOS 27.0 / 26.5 / 18.6 at rest, not the past day's.
128. **"The lightest rung that passed" is no longer true of the tint.** Rule `60-design-system`
    (*Glass*, a line stage 3c left as it was) says the tint's value "is the lightest rung that
    passed", and the test that holds it is `theTintIsNoLighterThanTheLightestRungThatPassed`. True
    of stage 1's `0.52`: `0.48` fell under on the sweep. Not of stage 3c's `0.64`: `0.60` passed
    with 0.14 to spare, and `0.64` was taken as the first rung with room — so the code's DocC,
    `docs/DESIGN.md` and the spec say (`LiquidGlass.systemTintOpacity(for:)`; *The look,
    measured*; spec §3.1). The value and the test's floor agree; the sentence and the test's name
    do not. The rule is the owner's to word; renaming the test is a code change. Found when the
    wording was staged.
129. **Stage 4 (Settings): what waits for a device or the owner.** (a) The step ticks under a
    finger on the goal and vessel sliders, and the language pick's tick, have never been felt —
    a simulator plays no haptic. (b) The new vessels note's Russian and Uzbek were drafted by the
    session that built the stage (*Виджет, Siri и Пункт управления записывают Стакан.* / *Vidjet,
    Siri va Boshqaruv markazi Stakanni qayd etadi.*); *Пункт управления* is Apple's Russian name
    for Control Center as this session knows it, not checked on a device; *Boshqaruv markazi* is
    checked against nothing. (c) The Cup's glyph is the screen's tightest pair, 3.08:1 on iOS 27.0 against its
    3:1 floor, beside its card's top-left sheen. (d) The vessels card takes 20 pt of padding at its
    top where the canvas has 22 — one card modifier for all four (the final reviewer's note 7).
    (e) Not rendered: Settings under Reduce Transparency, and the *Open iOS Settings* button.
    *(2026-10-14, the fifty-eighth pass: (a) and (b) are on `docs/ROADMAP.md`'s device-check
    sweep, 1.2.7, now. The stage also lowered the reminders row's floor from 56 to 44 pt — the
    canvas sets the title and the switch on one line, and the switch is the control — which only
    `HISTORY.md`, the plan and the ledger said; and its three rule changes were not on that file's
    list of rule changes, §8, which has a note now.)*
130. **Stage 5 (the welcome): what waits for a device or the owner.** (a) The haptics — `select` on
    each turn of a step, each step of the goal slider and the vessel sliders and each pick in the
    calculator; `confirm` on *Use* and on finishing — have never been felt; a simulator plays none. (b) The 28 new strings'
    Russian and Uzbek were drafted by the session that built the stage and have not been read by a
    native speaker. (c) iOS's own question about notifications, asked from the welcome's last step:
    no automated test answers it (the UI tests take *Not now*, and the unit tests use a spy
    scheduler), so the prompt over the welcome, a grant and a refusal are a device walk. So is
    #100(d)'s fix — revoke the permission in iOS Settings, come back, and see *Next reminder* go.
    (d) What VoiceOver stops on: XCUITest's snapshot lists the children of a `.combine` or
    `.ignore` element beside it — the greeting's two lines, a bell's time and glyph, the ✓ line's
    text and image — as it did for `GoalSetupView`'s greeting; whether VoiceOver stops on them
    once or twice is read on a device. (e) On Apple's glass (iOS 26.5 and 27.0) the *Work it out
    for me* button's accessibility frame grows to the whole open card, 354 × 402 pt, where it is 56
    pt on 18.6; the hit area is right (a tap on blank space in the open panel leaves it open), but
    VoiceOver's outline would cover the card. Settings' goal slider does the same at HEAD (354 ×
    154 on 27.0). (f) On a 375 × 667 pt phone at the largest text size the bar is ~189 pt on the
    goal step and ~321 pt on reminders, about half the screen; every control answers and each step
    scrolls above it. (g) In landscape, Hello's greeting stands below the fold until scrolled — the
    232-pt vessel fills the view. (h) A bell's hour reads *09* under an English 24-hour region —
    iOS's own form for a bare 24-hour hour — where the plan expected *9*. (i) The capture harness
    walks the welcome now and has not been run (#82).
131. **Stage 5's final review: deferred minors, none fixed** (`review-final.md` in the ledger
    folder; "finding N" is the reviewer's own numbering, not a known issue). Finding 2: opening
    the calculator scrolls to the card's foot (`anchor: .bottom`), so at the accessibility sizes
    the row that was tapped scrolls off above. Finding 3: VoiceOver loses its place when *Use*
    turns into the ✓ line, and the ✓ line speaks the drawn figure. Finding 4: the calculator row's
    open or closed state is not spoken. Finding 5: the hairline, the Glass note and the card
    modifier are written twice, in Settings and the welcome. Finding 6: `VesselSliders`' comment
    on the Cup's glyph cites Settings' figures only (the welcome's are 3.28 / 4.39 / 3.25, in
    `docs/DESIGN.md`). Finding 7: `-WaterBuddyFreshStart` ignores its value (DEBUG only). Finding
    10: two elevations without a stated reason, *Use* and the bells' discs at `.resting`. Finding
    11: no UI test opens the calculator at the largest text size. Finding 9 is #132. Finding 8,
    the rule wording, was taken in part: it proposed three new canaries and the typed wording
    adds two, `WelcomeStepTests` and `GoalSuggestionTests`; `WelcomeStringTests`, also not
    `@MainActor`, is left off the lists as `HomeStringTests` and `HistoryStringTests` are. And one
    the fix brought: the bar's buttons are disabled for the 0.45 s a step slides, so VoiceOver
    would read them as dimmed in that time. *(2026-10-14, the fifty-ninth pass: and one stale
    comment — `WelcomeView.swift:409` says the calculator is "on the goal card's glass"; it is its
    own pane, `:450`, below the goal card.)* *(The sixtieth pass: and a second —
    `WelcomeView.swift:223`–`:224` says "a step that slides in is whole as it comes (``Arrival``)",
    crediting the `pageSettlesIn` of `false` set beside it; only Hello's two sections call
    `.arrives`, so the other steps are whole because nothing on them arrives, and nothing reads that
    value.)*
132. **`SettingsView` stores its notification scheduler**, `private let scheduler =
    ReminderScheduler.live()` (`SettingsView.swift:63` since set A's step 1, `:48` at `HEAD`), where rule `80-notifications` says to
    build it inside the `Task` that uses it. At HEAD too — older than stage 5, which routed the two
    calls through `ReminderPermission` and left the property where it was. The welcome builds its
    scheduler inside its task.

**Opened 2026-10-15 by roadmap item 1.2.4, Log from a reminder:**

133. **The reminder's button is proved on a simulator only.** Spec
    `2026-10-15-log-from-a-reminder-design.md` §7.4 lists eight device steps for the 1.2.7 sweep, and
    none has run:
    1. unlocked;
    2. locked;
    3. pressed on Apple Watch with the phone locked;
    4. Double Tap;
    5. the watch out of the phone's reach;
    6. before the first unlock (#72);
    7. an update over 1.1 with reminders on;
    8. VoiceOver.

    The simulator could not show four things, which the sweep should look at too:
    - whether a long press opens a reminder with its button — on the simulator it never did (a lone
      reminder stayed in its short look, and two expanded the group), and only swipe-left → *View* did;
    - whether a tap on a reminder in Notification Center opens the app — it did not on the simulator,
      three ways, though a banner's tap did;
    - whether the keyboard and reply bar iOS raised under the expanded reminder appear on a device;
    - whether a pressed reminder leaves Notification Center's list.

    Also for the sweep: an app language set in iOS Settings while WaterBuddy's own picker is on
    *Follow device* (#134).
134. **The *Follow device* case of "the app and the widget file reminders in the same words" is not
    pinned.** `theAppAndTheWidgetFileRemindersInTheSameWords` compares each explicit `.lproj`. With the
    picker on *Follow device* each process resolves its own `Bundle.main` — the app's, and the widget
    extension's `.appex` — under its own preferred languages. If a per-app language set in iOS Settings
    did not reach the extension (unconfirmed), every widget tap would file up to 28 reminders again in
    its language and every foreground would file them back. Cost and a flickering language, not a lost
    reminder. A `.system` case comparing the two main bundles, and the device sweep, would settle it
    (the final review's Minor 1, deferred).
135. **Where the reminder's category is registered is held by prose, not a test.** Every spy takes
    `setCategories: { _ in }`. No test fails if `reconcile` itself — which the widget extension runs —
    starts registering, nor if `requestReminderReschedule`'s queued operation stops registering, or
    registers after filing or in another bundle (rule `80-notifications`' *The button*). A spy that
    counts the calls, and the operation's body lifted into a function a test can run, would pin it (the
    final review's Minor 2, deferred).
136. **The vessels note does not name the reminder's button.** *"The Glass is the one your widget,
    Siri and Control Center log."* — drawn by Settings (`SettingsView.swift:776` since set A's step 1; `:604` at `HEAD`) and by the welcome's
    vessels step (`WelcomeView.swift:569`), in `en`, `ru` and `uz` — leaves out a reminder's *Log a
    Glass*, which since 2026-10-15 logs the Glass too. (It has never named the watch's primary pour,
    `WristView.swift:136`, which logs the Glass as well.) Not wrong about what it names; incomplete.
    *(2026-10-20, the seventy-seventh pass: since 1.3.2's stage 7b, staged, the watch's Glass is the
    white button in `WristPourRow` — the vessel no longer pours — and `primaryIndex` is gone; the
    note still leaves it out.)*
    Rewording it is product copy in three languages, the owner's to word (found by the sixty-first
    pass's `/doc_sync`). A rewording also changes the sheets that quote it in the present tense —
    `docs/DESIGN.md:1472` and this file's stage 4 block (*The vessels note reads …*); the quotes in
    `docs/DESIGN.md:512` and `docs/WIDGET.md:29` are dated.
137. **The rating request is proved on a simulator only.** Roadmap item 1.2.5's request was seen on
    *WaterBuddy Probe 27*, in a DEBUG build launched with `-WaterBuddyReviewPrompt YES` on the fresh
    start. Not seen, and for the 1.2.7 sweep:
    - on the owner's iPhone, an Xcode build with the argument on the scheme — the third goal day's
      pour asks after the confetti; *Undo* and a second crossing do not ask again;
    - that a DEBUG run **without** the argument writes no `reviewRequestedVersion`: the fresh start
      clears its suite at launch, so the probe could not read it; it rests on
      `askForARating(after:)`'s first guard returning before the claim, which the final review
      checked by reading;
    - whether iOS shows the request from an App Store build at all: Xcode builds always show it and
      TestFlight never does (spec §3.6), so the first release is the first real proof — watch for
      ratings arriving after 1.2 ships;
    - VoiceOver on the request, which is iOS's own sheet.
138. **The rating request's deferred minors** (the final review, 2026-10-15; `review-final.md` in the
    ledger folder):
    - `ReviewPrompt.pause` repeats the overlay's `+ 0.4` (`Celebration.swift`); change one and the
      request no longer waits for the confetti, and `theRequestWaitsForTheConfettiToLand` asserts only
      `pause > Confetti.duration`. A shared `Confetti` constant and an equality would pin it;
    - Home's `hasReachedGoal` guard before the claim repeats the claim's own `reachedToday` check;
    - "the claim rings no doorbell and reschedules nothing" (rule `20-state`'s amendment) has no test;
    - **the owner's call:** the request arrives inside the eight-second *Undo* offer, so a Bottle
      tapped by mistake that crosses the goal on the third day meets the request and spends the
      version. Waiting for the offer to end before claiming would avoid it;
    - `theVersionIsTheBundlesOwn`'s second `#expect` restates the implementation;
    - the `25-shared-storage` amendment's absence line runs past the file's wrap (the owner's text).

**Opened by roadmap item 1.2.6, 2026-10-17:**

139. **In History's `List` rows, XCUITest lists text marked `.accessibilityHidden(true)`; whether
    VoiceOver speaks it is unknown.** Found when a new UI assertion — the strip's drawn count "is not a
    second element" — failed with the count hidden. A throwaway probe on *WaterBuddy Gate 27* (iOS
    27.0), with controls, found:
    - listed, all in History's `List` rows: the strip's new count (*8 servings*), its hour labels
      (*06*, *12*, *18*, hidden on a plain `VStack`) and the week card's figures (*12 214 ml*,
      *Average*, *Best day*, *Goal met*, hidden on their `ViewThatFits`) — the last two at HEAD;
    - not listed, on Home: the hidden date under *Today*, and the quick-add captions (*Cup*, *Glass*,
      *Bottle*, hidden inside Home's own `ViewThatFits`);
    - neither `ViewThatFits` nor `.fixedSize()` is the cause; the strip's heading node also takes the
      whole cell's frame (402 × 173 pt), where the week card's title has its own;
    - children of any `.accessibilityElement(children: .ignore)` element are listed too — Home's vessel
      included — so XCUITest's tree is not VoiceOver's (`tasks/lessons.md`, 2026-10-08 and 2026-10-17).

    The owner's decision (2026-10-17): keep the spec's design — the count hidden, like every other
    hidden figure in History — drop the assertion, and check History with VoiceOver in roadmap item
    1.2.7's sweep: the strip's count, its hour labels and the week card's figures should each be silent,
    and the heading's focus should be the heading, not the whole card. The two strip tests keep their
    value and one-element checks (`assertTheStripHeadingSpeaksItsCount`, whose DocC says why).
    *(2026-10-22, step 1's Task 7: met again on the paywall, outside any `List` — each feature row,
    `.combine`d, is one element labelled *title, line*, and XCUITest also lists its title `Text`
    beneath it, as it lists an `.ignore` row's children; so the plan's "label begins with the title"
    count read 2. The owner ruled the check counts the whole row, `label BEGINSWITH "<title>, "`;
    without the row's `.combine` it reads 0 and fails. Whether VoiceOver stops once per row is Task 8's
    to hear.)*

**Opened 2026-10-18 by the lag fix** (specs `2026-10-18-the-waters-cost-design.md` and
`2026-10-18-the-streaks-cost-design.md`; the owner reported lag on an iPhone, Debug build from Xcode):

140. **On iOS 26.5, under another project's load, taps were dropped more often on the fix than on
    `HEAD`.** The gate's first 26.5 pass, with another project's simulators running beside it — a
    1-minute load of 30–140 by the `uptime` readings taken (5-minute 63–83), up to 204 while the
    failures were chased — stopped after three of its four `GoalSetupUITests` chunks, one failure in
    each, every one on a 5-second wait after a tap: `testAScreenAnswersATapWhenItIsShownAgain`
    (*Home*'s tab), `testAServingRowDrawsItsAmountWhole…` (the Glass, the first tap after launch —
    #67's shape) and `testSettingsSaysWhichVesselTheOneTapDoorsLog` (*Settings*' tab). The first two
    passed every re-run (4 of 4 and 3 of 3). The last, at those loads: `HEAD` 10 of 10, change A alone
    10 of 10, change B alone 9 of 10, and the fix 6 of 13 — 6 of 12 run alone, and the gate chunk's
    one. Only the Settings failure was opened: its hierarchy and screen recording show the tap
    synthesized on the system `UITabBar`'s *Settings*, the app idle again within a second, and Home
    still selected four seconds later — that tap lost, not late; the other two are inferred to be the
    same. **On a quiet machine there was no difference**: no other project's `xcodebuild` running, a
    1-minute load of 7 before the runs and 25–30 while they ran, interleaved, `HEAD` 10 of 10 and the fix 10 of 10, and the
    whole 26.5 UI target passed (38 with 1 skipped, and 31). Not understood; the owner's ruling was to
    dig only if the gap survived a quiet machine. **Some of this lives only in the session's output**:
    one 3-of-3 batch of the fix and the first interleaved round (`HEAD` 5 of 5, the fix 5 of 5) were
    overwritten by the next run's log of the same name, and no log records a load. Recorded so that a
    dropped tap on iOS 26 on a device starts here, beside #67 and #115.
    *(2026-10-18, roadmap item 1.3.4's gate, the owner's Xcode build service and another project's
    simulator beside it, every log carrying `uptime` at its start and end: two more tests lost a tap.
    On iOS 27.0, `WelcomeUITests.testAStepIsAsItWasLeftWhenBackReturnsToIt` — the tap on *Active*
    synthesized, *Moderate* still selected, *Use 2 800* never shown (`WelcomeUITests.swift:368`); run
    alone five times, the change 4 of 5 and `HEAD` 4 of 5, the identical error, 1-minute loads 20–111.
    On iOS 26.5, `GoalSetupUITests.testUndoAfterTwoPoursTakesBackOnlyTheLast` — *Undo* never appeared
    after the first Glass (`:990`), a load of 83 rising to 134; then five runs each, the change 5 of 5
    and `HEAD` 5 of 5, loads 40–73. So the first is now seen on iOS 27 too, and on `HEAD`. A comparison
    on a quiet machine was not run: the load did not fall far enough in the session.)*
    *(2026-10-19, roadmap item 1.3.1's stage 6b gate, on a copy of the index: on iOS 26.5,
    `WelcomeUITests.testUseComesBackWhenTheGoalIsMovedAway` failed once — `XCTAssertFalse failed` at
    `WelcomeUITests.swift:355`, *Use 2 500* still there when `.exists` read it 0.7 s after its tap,
    with no wait — and, unlike every entry above, **at a low load**, 4 to 9. Alone on the same
    simulator, interleaved, `HEAD` 3 of 3 and the change 3 of 3 at loads 12–219 (another project's
    simulator beside it); the three classes again, 31 with 0 failures. The change held no file the
    welcome runs. A lost tap and a button still leaving cannot be told apart: diagnostics were off. If
    it comes back, a `waitForNonExistence` on that line would separate the two.)*
    *(2026-10-20, roadmap item 1.3.1's stage 6c gate, on a copy of the index: on iOS 26.5,
    `GoalSetupUITests.testAScreenComesBackWholeAfterItsTabIsLeft` failed once — *Undo* never appeared
    after the first Glass of the launch (`GoalSetupUITests.swift:162`, "the Glass was not poured", #67's
    shape), at loads of 4 to 15. Alone on *Gate 26.5*, interleaved with a `HEAD` (`4c796a9`) export:
    the change 3 of 3, `HEAD` 2 of 3 — `HEAD`'s one failure the identical line and message — at loads
    of 7 to 58, another project's run beside it. The rest of the 26.5 pass, 19 + 31, had no failure.)*
    *(2026-10-21, roadmap item 1.3.2's stage 7c gate, on a copy of the index, with another project's
    iOS 18.6 `xctest` at ~95% CPU beside it — 1-minute loads up to 329: on iOS 27.0,
    `WelcomeUITests.testUseComesBackWhenTheGoalIsMovedAway` failed in the class chunk three times on
    the change — `XCTAssertFalse` at `WelcomeUITests.swift:355` at a starting load of 118 and again at
    47, and once `XCTAssertEqual` at `:358`, the slider dragged to its end reading *3 700*, *3 200* or
    *2 600 millilitres* where 4 000 was expected, at 25. Alone, interleaved: the change 2 of 3, `HEAD`
    1 of 3 — all three failures at `:358`. `HEAD`'s chunk, once: 31, 0 failures, at 20 to 36. Once the
    other run had ended, at loads of 5 to 7, the change's chunk passed 31 of 31, and the whole 26.5
    pass 69 with 1 skipped. The change held no file the phone's welcome runs. So the slider's
    `adjust(toNormalizedSliderPosition:)` falls short under load, on `HEAD` too — a second shape
    beside the lost tap — and `:355`'s cause is still not established. In the same gate,
    `GoalSetupUITests.testAnOlderPoursTimerDoesNotEndANewerOffer` tripped its own slow-machine guard
    once (6.97 s against 6.5) and passed alone and in its quiet chunk.)*
    *(2026-10-21, evening, 1.4.1's Task 6 gate — the first change that builds a `PremiumStore` at
    every launch, the welcome's fresh start included: on *Gate 27* the class chunk failed once at
    `:355`, starting at a load of 5.65. Alone, interleaved with a `HEAD` `b981374` export that builds
    no store: the change passed 1 and failed 2 at `:358` (the slider read *3 500* where 4 000 was
    expected), one more run starting at 5.97 and ending at **875** not counted; `HEAD` passed 2 and
    failed 1 at `:358`. Every failure came under a load spike that rose during the run — macOS's
    storage extensions at 180 % CPU, another project's `swiftpm-testing` at 760 % — and the class
    passed 13 of 13 on *Gate 26.5*. A comparison on a quiet machine was not possible that evening.)*

141. **What the lag fix measured and left.** Simulator, Debug, `XCTCPUMetric`, throwaway probes not
    in the tree. Fixed: Home idle 17 % → 4 % of a core, the welcome 22 % → 3.5 % (0.176 s per 5 s), a pour and its five
    seconds 36 % → 23 %, a pour's model work and every tab's refresh flat at any history (#99). Left:
    (a) the pour is still the costliest moment — what is left of it is the water moving under glass
    for 2.5 s; the drop, the swell, *Undo* and the level's spring each measured within the noise;
    (b) the aurora was never switched off: History and Settings, which carry it and no water clock,
    idled at 2.1 % and 2.6 % of a core — its ceiling on the main thread, not a measurement — and its
    GPU cost and its heat over a session are not measured; (c) the welcome's weight wheel formats its 171–375 rows twice a tick, and the watch
    publish runs twice a pour with no watch paired — both read, neither measured; (d) a goal change
    and a launch still count the whole streak (10.5 ms and 12.6 ms at 150 days); (e) nothing was run in Release or
    on a device, and the owner's phone runs a Debug build under the debugger — the check the owner
    was asked for (*Edit Scheme → Run → Release*) is outstanding; (f) the welcome's resting water was
    not rendered — Home's was, at rest, moving and settled. Two approaches were measured and dropped:
    moving the waves rather than redrawing them (Home idle only 12 %, and a pour heavier, 43 %), and
    sampling the wave every 4 pt (no saving — the cost is the redraw, not the arithmetic).

142. ~~**Roadmap item 1.2.8 is parked half-way, and rule `85-testing` describes a harness that does
    not exist yet.**~~ **Retired 2026-10-18 — the harness is on disk, staged, and was run** (the
    sixty-ninth pass): the store method launches with the fresh start and builds the week through
    History's sheet; `Tools/CaptureScreenshots.sh` drives it; the four PNGs are retaken; the rule's
    wording is staged with them. The plan is `docs/superpowers/plans/2026-10-18-store-screenshots.md`.
    The wheel's order this session's proposal and plan gave — the half of the day first — failed: at
    2:42 PM the hour, asked for 12, read back 2, inferred to have snapped back from a time later than
    now (`tasks/lessons.md`, 2026-10-18). *(Corrected by the seventieth pass: the sixty-ninth said
    "this entry implied" the order, and the text below implies none. And by the earlier session's
    transcript the owner approved the design and this wording at 23:59 on 2026-10-17; it was typed
    seconds after midnight, so "approved and typed on 2026-10-18" below is true of the typing only,
    and "the design approved in chat on 2026-10-18" is 2026-10-17.)*
    Its wording was approved and typed on 2026-10-18 — the store capture launches with
    `-WaterBuddyFreshStart` and starts clean on its own — and is in the tree, unstaged; the harness
    and `Tools/CaptureScreenshots.sh` are unchanged. A throwaway probe proved the History sheet's
    wheel can be set from XCUITest in `en_US` (hour, minute and AM/PM take `"7"`, `"40"`, `"AM"`; the
    date column takes `"Oct 16"`, not `"Fri, Oct 16"`). The capture must run between 1:45 PM and
    midnight. Resume from the design approved in chat on 2026-10-18, or take the wording back out.

143. **What the lag fix's tests do not reach, and two comments in its code that overstate.** Found by
    the sixty-eighth pass's readers; a doc sync may not edit code, so they wait for the next change
    to those files. (a) `closedRun`'s key has three parts, and only two are tested on their own: the
    day (`aRunCarriesOverMidnight`, and `theTurnOfTheDayMakesTheNextReadRecountTheRun`) and the goal
    (`StreakPublishingTests.changingTheGoalReJudgesTheStreak`, not in `StreakRecountTests`); no test
    changes the zone, which a fixed test calendar cannot. (b) `updateLog` forgets the run when a serving
    moves *onto* another day as well as off one; only the move off an earlier day into today is tested
    (`aServingMovedOffAnEarlierDayRecountsTheRun`). (c) `DataManager.swift`'s DocC on `closedRun` says
    the read "cost a pour 6 ms at 45 days of history in a Debug build and 75 ms at 500, twice" — the 6
    and 75 ms are the whole pour, both reads in them; "twice" reads as double. (d) The DocC on
    `theTurnOfTheDayMakesTheNextReadRecountTheRun` cites `aTurnThatIsNotANewDayRepublishesNothing` for
    "the hop … republishes nothing on a day that did not change"; that test observes `todaysLogs`, the
    widget doorbell and `currentWater`, not `streak` or `history` — rule `30-rollover` and
    `dayDidTurn()` itself are what say it.

144. ~~**Four sentences in 1.2.8's own code and script overstate, staged — a doc sync may not edit
    them.**~~ **Retired 2026-10-18 — fixed inside 1.2.8's staged change, before `/commit`** (the
    seventy-first pass). (a) The harness's and the script's header say the launch still resolves the
    App Group suite and runs the migration, and that the run's servings, goal and total live only in
    the throwaway. (b) `setTime` gives the request and the read-back and calls the snap-back
    inferred. (c) The `--time` comment gives what the 1.2.8 transcript shows — `14:53` accepted;
    `2:53 PM`, `2:53 ` and three ISO dates refused, against `simctl`'s own help — and the script now
    reads the clock once at the top, refuses a run outside 1:45–11:45 PM there, before the boot and
    the build, and freezes the time it checked: fake-clock runs proved the refusal missing before
    and present after. (d) `freshStartArgument` names no users; rule `85-testing` does — and
    `freshStartManager`'s "never opened by it" gains that `init()` resolves the suite first. Every
    Swift change is `///`; a `build-for-testing` succeeded with no warning in either file.
    Found by the seventieth pass's two readers, 2026-10-18; each checked at its source.
    (a) The harness's DocC (*Why it starts clean on its own*) and `Tools/CaptureScreenshots.sh`'s
    header say the device's own WaterBuddy data "is never opened". `WaterBuddyApp.init()` calls
    `DataManager.prepareSharedStorage()` before the fresh-start branch, as its own comment says ("It
    runs on a fresh start too"), and that resolves the App Group suite and runs the one-shot
    migration. What holds: the run's manager is built on a throwaway suite and an in-memory store, so
    no serving, goal or total of the device's is read into the shots or written. (b) The harness's
    DocC on `setTime` says the hour "went from 2 towards 12 by way of 3 PM, snapped back". The log
    shows only the request for 12 and the read-back *2 o’clock*; the path is inferred. (c) The script
    says `--time` "takes only an `HH:mm`", but its own first passing run gave it `2:53`, which was
    accepted and drawn *02:53*; refused were `2:53 PM`, `2:53 ` and full ISO dates. And it says a run
    outside the window "fails at once" — after the build and the boot — while the clock it freezes is
    read at the script's start, which the window does not guard: a build slow enough could freeze a
    time before 1:30 PM. (d) `WaterBuddyApp.freshStartArgument`'s DocC — "The argument the welcome's
    UI tests launch with" — no longer names every user; rule `85-testing` does. 1.2.8 is not
    committed, so (a)–(c) can be fixed in the change itself before `/commit`, if the owner wants.

145. **Siri's *Today's Water* in a language WaterBuddy does not ship.** The table falls back to
    English and the figures take that language's grouping and plural rule
    (spec `2026-10-18-todays-water-design.md`). German gives *1.450 millilitres so far today — 1.050
    millilitres to go.*, pinned by `aLanguageTheAppDoesNotShipHearsEnglishWithItsOwnFigures`.
    Japanese, which has one plural form, gives *1 millilitres* — seen in a throwaway macOS probe on
    2026-10-18, not pinned: it is Foundation's fallback, and the fix is shipping the language.
    1.2.6's *Follow device* tests met the same rule from the other side (`aJapanesePhoneOnFollowDevice…`)
    — and found the app's process on a Japanese phone running as `en_JP`, so if Siri resolves the line
    with the locale the resource carries (below, #146), a Japanese phone may hear *1 millilitre*
    after all. Unproven either way.

146. **What only a device shows of roadmap item 1.3.4**, *Today's Water* (spec §8.3). No simulator here
    has run `TodaysWaterIntent.perform()` (#63). On the owner's iPhone: asked unlocked; asked locked —
    what it asks for, then whether it answers; locked with the Apple Watch unlocked on the wrist, with
    AirPods, and in a car if there is one, since `.requiresAuthentication` is inferred, not documented,
    to accept an authenticated watch or remote device (spec §3.2); each of the three lines spoken;
    the device in Russian; asked after midnight with the app not run since; and whether Siri's card
    shows the line as written — the dialog has one line, the unit spelled out, because a shorter
    `supporting` line is promised only beside a snippet (spec §3.2). And **a phone whose Siri language
    differs from its device language**: the final review's probe found the resource carries the app
    process's own `Locale.current`, so a resolver that keeps it answers in the device's language, not
    Siri's — the intent's DocC and the tests' `said(_:in:)` state Siri's resolution as fact, which is
    inferred (deferred, the review's minor 5).

147. **What a suite off the main actor catches in this test target — measured, and what the rules
    say.** The plan did not give `WaterSnapshot.remaining` and `hasReachedGoal` the `nonisolated` the
    app target's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` makes necessary; the GREEN build of 1.3.4
    printed two new warnings at `TodaysWaterIntent.swift`, and the test target, reading the same two
    from a suite that is not `@MainActor`, printed none. Both are now marked, after `AppLanguage.code`'s
    precedent. The final review then asked whether that suite could be made a canary, and builds of the
    real target with the keyword taken off and put back (2026-10-18, logs `canary-*` in that session's
    scratchpad) showed: a **synchronous** test reading the property — nothing; an `async` test reading
    it **inside `#expect`** — nothing, the macro's closures swallow it; an `async` test reading it
    **into a local first** — "main actor-isolated property 'remaining' cannot be accessed from outside
    of the actor". `TodaysWaterSnapshotTests` is now that shape, and seen to warn and then not. For
    `TodaysWaterIntent.answer(for:)` no shape warned with its `nonisolated` removed — synchronous,
    `async`, or into a local — so **`TodaysWaterAnswerTests` is not a proven canary**, though rules
    `43-concurrency` and `85-testing`, as approved for 1.3.4, list it among them; its DocC says so.
    For the owner: (a) the two rules' lists could name `TodaysWaterSnapshotTests` instead, and say a
    canary reads into a local in an `async` test; (b) the older suites on those lists read inside
    `#expect` too, so what they catch is not established either; (c) rule `43-concurrency` says
    default main-actor isolation is set on every native target, and `project.pbxproj` sets it on the
    app target alone (`:938`, `:976` — the final review's reading), which the DocC on the two
    properties follows.

**Opened by roadmap item 1.3.1, stages 6a and 6b (2026-10-19):**

148. **What only a device shows of the widget's StandBy layout** (spec
    `2026-10-19-the-widget-stage-design.md` §8.3, for the 1.2.7 sweep). The simulator has no StandBy,
    and `showsWidgetContainerBackground` cannot be set, so the bare layout has been seen only through
    a throwaway build that forced it (`HISTORY.md`, 2026-10-19). On the owner's iPhone: StandBy by
    day — the vessel's rim and water and the white disc on black — and at night, where the rendering
    mode is **inferred** to be `.vibrant` and the red is iOS's own; a tap there that logs; and, locked
    with *Allow Access When Locked → Lock Screen Widgets* off, whether iOS hides the figure — whether
    it redacts a Home Screen widget in StandBy at all is inferred. That iPhone's StandBy shows small
    widgets only is inferred from Apple's documentation too, and is why the medium family has no
    bare layout. **One thing seen on the simulator, for the owner:** under a forced
    `.redacted(reason: .privacy)` the medium widget's vessel went quiet too, because `MiniVessel` is
    shared, while the medium's *700 ml* and *of 2,000 ml* stayed drawn. D3 scopes the marking to the
    small family; if a device ever redacts a medium Home Screen widget, its two lines need
    `.privacySensitive()` as well. Not placed for 6b: a tinted Home Screen (6a's commit records one
    for the button).

**Opened by roadmap item 1.3.1, stage 6c (2026-10-20):**

149. **What only a device shows of the week widget** (spec `2026-10-19-the-widget-stage-design.md`
    §8.3, for the 1.2.7 sweep). Seen on the simulator (`HISTORY.md`, 2026-10-20): the gallery's sample,
    the placed week agreeing with History's card day by day, a past-day serving reaching it, the
    midnight turn with nothing tapped, the link warm and cold, Russian and Uzbek, light and dark, and
    the colour pairs. Not seen: VoiceOver reading it (SpringBoard's tree is not VoiceOver's —
    `tasks/lessons.md`, 2026-10-08); a narrow iPhone; a tinted Home Screen, where a met bar takes
    iOS's accent; the morning after on a phone left alone; and **the empty state on a real
    placement**. On the simulator WidgetKit offered none of WaterBuddy's widgets — on a fresh install
    the gallery's search found nothing — until the app had run once, and that run writes the week, so
    *Open WaterBuddy to see your week.* was seen only in a throwaway build that passed no week (one
    line in English and Uzbek, two in Russian, uncut). Whether a phone offers a new widget kind
    after an App Store update and before the app is opened decides whether a user ever sees it.
    **And the extension's own write of the week has never run** — `republishHistory(cachingTheWeek:)`'s
    cache-only branch, role `.phoneExtension`, the case the cache exists for (a tap the morning after).
    Unit tests run as the app and the role is a `static let`; no widget tap ran on the simulator
    (`linkd` refuses the widgets' buttons, #63). A Control Center press, which `chronod` does perform
    on a simulator through the same `AddWaterIntent`, could prove it short of a device (the final
    review's minor finding, left).

150. **The week's two edges, by design** (spec §3.4). A change of time zone regroups History's card at
    once and the week widget only at the next mutation, because the cache is keyed by the day
    ordinals of the zone it was written in — `aWeekReadInAnotherZoneStillHasSevenDays` pins that it
    still draws seven days, the newest from today's total. And a clock moved back past the last write
    draws the oldest day as zero until something is logged. Neither writes anything wrong into the
    store; both are corrected by the next pour or edit.

151. **The watch's Apple glass has never run on watchOS 26** (roadmap item 1.3.2, stage 7a,
    2026-10-20; for the 1.2.7 sweep). The spec's §3.2 asked for every watch measurement on a 26.x
    runtime as well as 27.0, because the phone's glass rendered and hit-tested differently on iOS
    26.5 and 27.0. No watchOS 26.x runtime reached this Mac (#77), the one other watch runtime here,
    11.5, is below the watch's 26.0 floor, and the owner ruled the stage go on with 27.0 alone. So
    `theWatchDrawsAppleGlass`, the panes' renders and *The watch's glass, measured* (`docs/DESIGN.md`)
    are watchOS 27.0's; on 26.x the watch's glass — its contrast, its tint, a tap on a pane's bare
    glass — is compile-verified only. The gate stays rule `85-testing`'s five invocations. A watch
    running 26.x, or the runtime if it arrives, settles it.
    *(2026-10-20, stage 7b: the screen too — the row, the column, the renders and *The watch's
    screen, measured* are watchOS 27.0's.)*
    *(2026-10-21, stage 7c: and the faces — the probe's renders, the placement and the midnight
    turnover are watchOS 27.0's.)*
152. **The watch's pour row is proved on the simulator only by clicks in `DeviceHub.app`** (roadmap
    item 1.3.2, stage 7b, 2026-10-20). The owner clicked Cup, the Glass and Bottle on *WaterBuddy
    Probe Watch 46* (watchOS 27.0) in `DeviceHub.app` — Xcode 27 ships no `Simulator.app` — and a
    capture saved a frame at each change: *1 240 of 2 000 ml* → 1 490 (+250) → 1 990 (+500) → 2 240 →
    2 740 → 3 240 → 3 740, then the screen scrolled under the owner's drag; the probe watch's own
    outbox held twelve pours, 150 twice, 250 four times and 500 six times — each a button's own
    serving. The session first recorded the check as failed: it looked 19 seconds before the clicks
    began, and read the device log's *"Received an unexpected HID event of type 1. Ignoring."* —
    printed by every process, `Carousel` included, around the same touches — as the cause. Those lines
    are noise (`tasks/lessons.md`, 2026-10-20). Still open: the press of Apple's interactive glass on a
    device, the Digital Crown, VoiceOver's activate, and the row at the accessibility sizes, where it
    scrolls sideways — none was pressed here.

**Opened by roadmap item 1.3.2, stage 7c (2026-10-21):**

153. **What only a device shows of the watch's three faces** (spec `2026-10-20-the-watch-stage-design.md`
    §8.3, for the 1.2.7 sweep). Seen on the simulator (`HISTORY.md`, 2026-10-21): every shape
    rendered shown and quiet in en/ru/uz at 62, 100 and 999%; the three placed by the owner — the
    circle and the rectangle on Modular, the corner and the circle on a green Infograph — on
    *WaterBuddy Probe Watch 46*, watchOS 27.0; the faces following the phone's Russian; and the
    midnight turnover with the app closed. Not seen: **the quiet forms where watchOS draws them** —
    a locked watch, and Always On with the app's complication data turned off; when watchOS redacts
    at all is inferred, and the quiet forms have been drawn only under a forced
    `.redacted(reason: .privacy)`. **VoiceOver on the wrist** — one stop per face, the label and the
    vessel's sentence, the label alone when quiet; nothing reads a face's accessibility tree on a
    simulator. **The corner on a tinted face after its fix** — before it, its curved gauge stayed
    white beside a green circle; `.widgetAccentable()` was added and compiles, and the owner skipped
    the re-shoot. **The Smart Stack**, where watchOS also offers an `.accessoryRectangular` widget,
    out of the spec's scope and never looked at. And every face on watchOS 26.x (#151).

154. **A corrupt watch store can trap the watch's total, on the screen and on every face**
    (the 7c final review's declined item, checked at its source). `WristPlan.todaysTotal(from:now:calendar:)`
    sums the outbox with `reduce(0) { $0 + $1.amount }` (`WristPlan.swift:36`), and
    `todaysTotal(mirror:outbox:now:calendar:)` adds the mirror's `currentWater` with a plain `+`
    (`:55`); `Face.percentage` converts `Int(… .rounded())` before its `0...999` clamp. A persisted
    `WristMirror` or outbox holding an extreme value would overflow there and crash the watch app or
    its complication, where rule `75-diagnostics` saturates (`addingReportingOverflow`) on the phone.
    Not reachable from the product: the phone composes `currentWater` from its clamped
    `0...maximumDailyIntake` total, and a pour's amount is a vessel's, held to the same range.
    Pre-existing — the provider before 7c had the same arithmetic — and left for its own change.
155. **Premium's products exist only in the local configuration** (roadmap item 1.4.1, spec
    `2026-10-21-premium-foundation-design.md` §7.4, items 1–5). Before any release offers the
    paywall, the owner's App Store Connect steps: the Paid Apps Agreement, banking and tax active; the
    subscription group *WaterBuddy Premium* with `sardor.WaterBuddy.premium.yearly` at its price, a
    one-week free introductory offer and its name in en, ru and uz; the lifetime non-consumable
    `sardor.WaterBuddy.premium.lifetime`; Family Sharing on both; the App Privacy answers left at
    *Data Not Collected*. 1.4.1 ships hidden, so none of this blocks it.
    *(2026-10-21, evening: the owner added **a monthly plan** — `sardor.WaterBuddy.premium.monthly`,
    $2.99, no introductory offer, in the same group one level below the yearly — ruled in the step-1
    spec and not yet on disk; App Store Connect gains it with the rest.)*
    *(2026-10-22: the monthly is in the local configuration, staged (step 1's Task 5), and still only
    there; Family Sharing on all three.)*
156. **No purchase has been made on a device** (1.4.1, spec §7.4, item 6). A sandbox purchase,
    restore and refund on a real iPhone before the first Premium set ships — beside 1.2.7's sweep.
    Every purchase so far is the local StoreKit configuration's, on the simulator.
157. **`anExpiredYearlyReadsFree` is disabled, for the owner to rule on** (1.4.1, Task 4).
    StoreKit testing cannot end a free trial early: after `expireSubscription` on a trial,
    `Transaction.currentEntitlements` still answered the trial's transaction with its first expiry
    (a week out) for three seconds and more; a second purchase answered *bought* and changed nothing;
    a second expiry threw `SKServiceErrorDomain` 2 (measured on iOS 27.0, 2026-10-21). The test is
    kept as written, `.disabled(…)` with the reason in its DocC, and shows as *skipped* in every run.
    Expiry stays covered by `aYearlyEndingAtThisInstantIsOver`, `aYearlyThatEndedIsOver`, both
    `anExpiryPassing…` cases and the live `expires` in `aBoughtYearlyReadsPremium`. Keep, change or
    drop it.
    *(2026-10-21, evening: still open. Under the owner's grace ruling (#161) a lapse is StoreKit's to
    report — the plan was stopped listing — so the test asks the environment for exactly what it does
    not model; the step-1 plan keeps it disabled and rewrites its DocC's list of the tests that cover
    expiry, two of which that plan replaces.)*
    *(2026-10-22: done in step 1's Task 5, staged — the DocC now names
    `aSubscriptionStoreKitStopsListingReadsFree` and
    `anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead`; the test still skipped, still the
    owner's to keep, change or drop.)*
158. **A test purchase once reached the real sandbox** (1.4.1, Task 1's probe). The first purchase on
    a freshly booted *iPhone 17* (27.0), during a load spike from macOS's storage service, ignored
    the `SKTestSession` and waited on a *Sign in to Apple Account* alert until the run was stopped at
    600 s. It did not happen again in three runs, with or without `resetToDefaultState()`; the cause
    is unconfirmed. `StoreKitSessionTests` resets its session and carries `.timeLimit(.minutes(1))`,
    so a repeat fails that test instead of holding the gate.
159. **No privacy policy link in the app, and 1.4.1 waits for one** (spec O1). App Review 5.1.1(i)
    asks every app to link its privacy policy from inside the app; WaterBuddy has none today, Premium
    or not. The paywall's link will answer it where the paywall is offered; whether Settings carries
    it for everyone is the owner's ruling. 1.4.1 is paused at Task 6 for the URL.
    *(2026-10-21, evening: no longer a pause — the owner said to build without the URL, "I will give
    you later". `PaywallView.privacyPolicy` holds the token `OWNER-PRIVACY-URL`, so
    `theLinksAreApplesTermsAndAPageOfOurs` fails in every unit run until the URL lands, and the
    step-1 spec makes a Release build refuse to offer the paywall without an `https` link. The
    repository's root `PRIVACY.md` is a policy draft whose `[PLACEHOLDERS]` are unfilled; it is not
    hosted anywhere this file knows of.)*
    *(2026-10-22: the switch is on disk, staged — step 1's Task 4: a Release build offers the paywall
    only while a set is on sale **and** `privacyPolicy` is an `https` address, so the token cannot
    ship as a live link.)*
    *(2026-10-23, set A's step 2: still the one failing unit test, 815 run; and it now gates History's
    switch too — a free user's Month is drawn only where the paywall is offered,
    `HistoryView.offersMonth(status:offered:)`.)*
160. **One new warning line, from Apple's `StoreKitTest` header** (1.4.1's Task 4, found in Task 6's
    gate). `StoreKitTest.framework/Headers/SKTestTransaction.h:34:32: 'SKPaymentTransactionState' is
    deprecated: first deprecated in iOS 18.0`, emitted when the explicit module for the SDK's
    `StoreKitTest` is built — its one importer is `WaterBuddyTests/PremiumStoreTests.swift:9`. It is
    the SDK's, not the code's, and cannot be fixed in source: the choices are to accept it into the
    baseline, to silence it with a clang-importer flag (a `project.pbxproj` change), or to drop the
    live `StoreKitSessionTests`. The owner's ruling. Task 4's own check grepped the warnings for the
    names of our files and missed it (`tasks/lessons.md`).
161. ~~**A subscriber in billing grace reads as free — ruled, not yet on disk**~~ **Retired
    2026-10-22 (the eighty-first pass) — the fix is on disk, staged:** step 1's Task 3 —
    `PremiumAccess.resolve(_:)` takes no clock and holds what StoreKit's current entitlements list,
    `aSubscriptionInItsGracePeriodIsStillPaid` and `aListedYearlyPastItsEndIsStillHeld` replacing the
    two tests that asserted the opposite, and the status line naming the plan alone once its date has
    passed (`aPassedDateIsNotShown`). Grace itself is not reproducible in StoreKit testing here (#157).
    The issue as opened (1.4.1's final review,
    Important 2). `PremiumAccess.resolve` drops a subscription whose period ended at or before `now`
    (the foundation spec §3.2), which contradicts its §3.4 (*a billing grace period → still
    Premium*): in grace StoreKit still lists the plan with a period already ended. The owner ruled,
    in the step-1 spec §3.2, that StoreKit's current entitlements decide — `resolve` keeps revoked
    and unknown products out and takes no clock, and a lapse reads free when StoreKit stops listing
    it. The step-1 plan's Task 3 makes the change and replaces the two expiry tests that assert the
    opposite. Nobody can hold a subscription until set A is on sale (step 5).

**Opened 2026-10-22 by Premium's step 1** (spec `2026-10-21-premium-paywall-and-monthly-design.md`):

162. **In the local StoreKit configuration, `Product.price` is the price's whole number** (step 1's
    Task 1 probe, measured on *iPhone 17*, iOS 27.0, 2026-10-21). The three products answer
    `displayPrice` $2.99, $19.99 and $39.99 but `price` 2, 19 and 39 (exponent 0; parsing the
    `displayPrice` with the product's own `priceFormatStyle` gives 2.99, 19.99 and 39.99). The same
    with `-testLanguage en -testRegion US`, which sets the app's locale, not the device's. Every
    simulator on this Mac is `AppleLocale en_UZ`, whose decimal separator is a comma, and
    `Decimal(string: "39.99", locale: en_UZ)` reads 39 on the host (so do `uz_UZ` and `ru_RU`; `en_US`
    reads 39.99) — so StoreKit testing most likely reads the configuration's `displayPrice` under the
    device's region (inferred; a US-region simulator was not tried — setting one needs `defaults write`,
    which the deny list refuses). **The effect:** the yearly tile's saving, computed from
    `Plan.amount` = `Product.price`, reads **20 %** (1 − 19 ÷ 24) instead of 44 % in any local run
    here, and on the owner's iPhone if its region writes a decimal comma. The owner kept
    `Product.price`, as the spec says ("go"); App Store prices do not come from this file. The
    alternative, held in reserve: parse `displayPrice` with `priceFormatStyle`, falling back to
    `price`. To confirm with a sandbox purchase on a device (#156).
163. ~~**The owner's unstaged scheme edit launches every unit-test run with `-WaterBuddyPremium`**~~
    **Retired 2026-10-22, step 1's Task 9:** both stray entries removed with `Edit`, Xcode closed, the
    local StoreKit configuration kept, the scheme staged alone; `theTestRunItselfIsNotOfferedThePaywall`
    passes in the gate's unit run. What follows is the record. (step 1's Task 4). The `WaterBuddy` scheme's Run action carries `-WaterBuddyPremium YES` among its
    arguments — and, by mistake, as an environment variable — for the owner's device walk, and its
    Test action has `shouldUseLaunchSchemeArgsEnv = "YES"`, so the unit-test host is launched to offer
    the paywall and `theTestRunItselfIsNotOfferedThePaywall` fails in the working tree. On a copy of
    the index, which holds `HEAD`'s scheme (no such argument), it passes. The plan's Task 9 removes both
    stray entries before staging the scheme and before the gate; until then every working-tree unit run
    names this failure.
164. **The paywall says *Using Apple Intelligence, private on your iPhone* before anything uses it**
    (set A's step 1; the plan's Task 10). Set A's third feature row — *Personal AI insights* — names
    Apple's on-device model, which step 4 (roadmap item 1.4.12) builds. Nobody meets the row before
    step 5 puts the set on sale, but the line is shipped copy in three languages: before then, check it
    against what step 4 actually does (where the model is not available, the app writes its own
    insights), against Apple's naming of *Apple Intelligence*, and against App Review's rule on
    describing features accurately.
    *(2026-10-24, set A's step 4: **the naming half closed on disk.** The owner's ruling — "Apple's
    on-device model" — after Apple's trademark guidelines were read (a mark only in a referential phrase,
    never a feature's name): the row reads *Personal insights* / *Each week, from your own figures, on your
    iPhone*, the caption *Insights*, and no copy anywhere names *Apple Intelligence*;
    `theInsightsRowCarriesNoAppleMark` pins it in three languages. The accuracy half stands until a device
    shows the model writing (#178).)*
165. **The paywall's colour pairs are measured on iOS 27.0 alone** (step 1's Task 8, 2026-10-22). 74
    readings on *WaterBuddy Probe 27*, none under its floor — the tightest the title, 3.20 against its
    3; the card's calendar glyph, 3.35; the BEST VALUE line, 4.61; the terms, 4.65 (`docs/DESIGN.md`,
    *The paywall, measured*). Apple's glass hit-tests and renders differently on iOS 26, and below it
    the hand-made stack draws every pane: those figures do not carry over, and *Settings, measured*'s
    own cyan glyph read 3.08 on 27.0 and 4.02 on 26.5. Measure on 26.5 and 18.6 before set A goes on
    sale, by the same method (the ledger keeps the tool and the elements).
166. **`PremiumUITests` timed out on its first runs on iOS 26.5, under load** (step 1's gate,
    2026-10-22; its Task 7 form had run on 27.0 only). In the class chunk the card was not there in
    10 s; alone, once, the sheet's subtitle not in 5 s; in one class run, Settings' goal slider not in
    5 s — a path step 1 does not change. Each test passed alone twice and the class twice, at loads of
    38 to 144 from another session's builds, and a probe on 26.5 put the sheet's first lines 1.1 and
    2.2 s after the tap. Re-run the class on 26.5 on a quiet machine before calling it settled; if it
    times out there, the card's first StoreKit read with no configuration is the first suspect.
    *(2026-10-23, set A's step 2's gate: the class, now four tests, passed in its run on *WaterBuddy
    Gate 26.5*, started at a 1-minute load of 7.4 — once, so not yet "settled" by this item's own bar.)*
167. **The month view's nine deferred minors** (set A's step 2, the final review, 2026-10-23;
    `.superpowers/sdd/2026-10-22-month-view/t9-review.md` until the owner commits). M1
    `aServingStampedAfterTodayCountsNowhere` pins the total and `canOpen` only — a met future day
    regressing into `daysMet` would stay green; M2 `showMonth` with an ordinal that names no month,
    while a month is shown, keeps the old one and every later read reads nothing (unreachable from the
    UI); M3 a time-zone change that keeps the date regroups the shown month only at the next refresh;
    M4 a flight west across the 1st leaves Month on a month after this one, every day quiet, until ‹;
    M5 a watch batch reads the shown month twice (`ingest` keeps `refresh()`), not measured against the
    6 ms; M6 the day numbers are formatted with the device's current calendar — out of sequence, inferred,
    under a non-Gregorian calendar on *Follow device*; M7 litres round half to even (62,450 ml →
    *62.4 L*); M8 a month with no counted day speaks *0 of 0 days on goal*; M9 *Measured against your
    current goal* is not in `LocalizationTests` (before this step). The owner's to schedule.
168. **The month view's hand proofs owed to a device** (set A's step 2's walk, 2026-10-23). A pour from
    the widget, the control or Siri while Month is open — the walk's fresh start runs on a throwaway
    suite and an in-memory store the extension cannot reach; the path is `refresh()` on the way back
    to the foreground, pinned by `aSecondInstancesServingIsPickedUpByARefresh`. VoiceOver by ear — the
    switch, the month's heading, a day button's label, value and *Selected*, the tiles, the locked
    card, and that an arrow at a bound is not a stop (the XCUITest tree lists hidden views, so it proved
    nothing either way). Reduce Transparency was forced in a scratch copy, not set: Apple's tab bar kept
    its glass there, as the real setting would not.
169. **The month view's colour pairs are measured on iOS 27.0 alone, in English** (set A's step 2's
    Task 8, 2026-10-23). 51 readings, none under its floor — the tightest a met day's cyan arc, 4.36
    against 3; a quiet day's number at 0.7, 4.80; the letter M, 4.90 (`docs/DESIGN.md`, *The month,
    measured*). As #165: iOS 26.5 and 18.6 before set A goes on sale, and the Russian and Uzbek month,
    whose names and labels are wider over the same grounds.
170. **The month view's Russian and Uzbek are the plan's drafts** (spec §3.11, §8). The 20 keys are in
    all three languages and every figure and plural form was read in the walk (`HISTORY.md`,
    2026-10-23), but no speaker has read the wording — *Дни с целью*, *Частично*, *Maqsadli kunlar*,
    *Qisman* among them. For the owner's sweep before step 5.
171. **The patterns' heading line is under its contrast floor on the aurora** (set A's step 3's walk,
    2026-10-23; `docs/DESIGN.md`, *The patterns, measured*). *From this month's finished days*,
    `.subheadline` semibold white with the two shadows — `OpenedDayHeading`'s style — read **4.17**
    beside its glyphs at its worst of forty frames two seconds apart, where the aurora's cyan light
    passes behind it (4.53 and 4.74 in two shorter samples); the title above it holds at 5.73. It is
    already white at full opacity, so every fix changes the look — the spec's §3.8 sends it to the owner.
    Ways out, none taken: the line moved onto a pane (inside *When you drink*, or a pane of its own under
    the heading); the line kept only as the heading's spoken value; or the line accepted on another
    yardstick (#95's question). Until ruled, it ships as built — and nobody meets it before step 5.
172. **Patterns' deferred review minors** (set A's step 3's final review, 2026-10-23). M1: a time-zone
    change that keeps the date leaves the shown month unrepublished, so the bars stay in the old zone's
    hours while *Most around …* and the two tiles format their instants in the new zone — #167 M3's root,
    now visible as a contradiction; the fix, republishing the month from `dayDidTurn()` on every call,
    changes a rule `30-rollover` sentence and is the owner's. M5: VoiceOver hears a side's average but
    not whether it met the goal — the spec's §3.8 choice. M9: `MonthPatterns`' saturating helpers repeat
    `MonthHistory`'s private ones. The owner's to schedule.
173. **Patterns' hand proofs owed to a device** (set A's step 3's walk). VoiceOver by ear — the heading,
    the chart's one element and its value, each weekday/weekend row, the two tiles, the pending line; a
    pour from the widget, the control or Siri while the patterns are on screen (the walk's fresh start runs
    on a throwaway suite the extension cannot reach); Reduce Transparency set rather than forced.
174. **Patterns' colour pairs are measured on iOS 27.0 alone, in English** (as #169). iOS 26.5 and 18.6,
    Increase Contrast, and the Russian and Uzbek lines over the same grounds, before set A goes on sale.
175. **Patterns' Russian and Uzbek are drafts** (spec §3.9), following the paywall's own words for the
    feature — *Привычки*, *Когда вы пьёте*, *Будни*, *Выходные*, *Первая порция, обычно*, *Для привычек
    нужно 7 дней с водой*; *Odatlar*, *Qachon ichasiz*, *Ish kunlari*, *Dam olish kunlari*, *Birinchi
    porsiya, odatda*, *Odatlar uchun suv ichilgan 7 kun kerak*. For the owner's sweep with #170's.
176. **`HistoryView.swift` is 3,022 lines** after step 3, by `wc -l` (2,644 before it). Rule `50-views` keeps a
    helper view in the file that uses it, so the month's and the patterns' private structs live there;
    splitting the screen is a task of its own, as the step-2 spec §3.8 said of its 2,300.
    *(2026-10-24: **3,428** after set A's step 4, by `wc -l` — Insights' six private views and the locked
    page made one.)*
177. **White text on the aurora is measured too kindly where the aurora's cyan light passes** (set A's
    step 4's walk, 2026-10-24). Step 2's contrast tool (`t8-measure.swift`) sets aside a cyan pixel as
    "other ink", so where the aurora's cyan light is the ground it measures less of the ground than is
    there — and behind *Insights* it set aside all of it and read nothing. A second scratch script, the
    same ring-around-ink method without that mask, reads ***Insights*** (`.title3` bold, white, two
    shadows) **3.37** at its worst over 45 frames two seconds apart (median 4.55, best 5.22), and
    ***Patterns*' own title 3.14** in step 3's frames, which the tool had read 5.73 — both against the 4.5
    `docs/DESIGN.md` holds them to. #171's line, read by the tool at 4.17, is likely lower still. The
    every-tab heading style on the aurora is the question, not this step's heading alone; the owner's, with
    #171 (spec `2026-10-23-insights-design.md` §4a). The pane readings are sound: the tool set aside 0–1 %
    of their ground.
178. **Insights' hand proofs owed to a device** (set A's step 4). Apple's model was *not ready* on this
    Mac (`SystemLanguageModel.default.availability` → `.unavailable(.modelNotReady)`, 2026-10-23), so no
    note it wrote has been seen: its wording, that greedy sampling gives one week one wording across
    launches, how often `accepts(_:for:)` declines it, and *Writing…* to its note — the walk saw only a
    stand-in source. VoiceOver by ear on the panes and the switch's third segment, and how it reads *ml*
    inside a sentence. Reduce Transparency set rather than forced. The weak link was read with `otool`
    (`LC_LOAD_WEAK_DYLIB`) and the build ran on iOS 18.6; iOS 17 is compile-verified only.
179. **Insights' Russian and Uzbek are drafts** (spec §3.9), following step 1's word for the feature —
    *Советы*, *Главное*, *Что получается*, *Стоит знать*; *Tavsiyalar*, *Asosiysi*, *Nima yaxshi
    chiqyapti*, *Bilib qo‘ying* — and the 29 sentences. Every key drew in the walk; no speaker has read
    them. For the owner's sweep with #170's and #175's.
180. **`xcodebuild` sat after its tear-down twice in set A's step 4's gate** (2026-10-24): the unit run's
    908 tests finished at 00:39:53 and the process was stopped at 00:49; a single-test run did the same.
    The lesson of 2026-10-23 (*A walk run … hung for six hours*) held: read, not waited on. The cause is
    unknown; the results were read from the logs.
181. **Insights' deferred minors** (set A's step 4's final review and walk). At the accessibility sizes the
    switch scrolls but does not bring a chosen *Insights* into view (W3); no UI test holds Premium to walk
    a holder's Insights (as for Month); `onlyEnglishIsHandedToTheModel`'s `.system` case restates the
    implementation; a part of a note may still phrase a figure the check does not read (*a couple*, *a
    few*) — the footer names who wrote it. Insights' colour pairs on iOS 26.5 and 18.6, Increase
    Contrast, and in Russian and Uzbek, before set A goes on sale (as #174). The owner's to schedule.
182. **The recap card's tiles read grey-brown** (set A's step 5's walk, W1). They take `Base.archived` —
    the widget's derived fill, `white 0.24` at 50 % — over the card's `Aurora.gradient`, where the
    concept board drew a light white wash and the app's own panes on iOS 26 are Apple's glass tinted
    `Aurora.top`. Not retuned: rule `60-design-system` derives tokens and forbids choosing one by eye,
    and `archived` is the base rule `40-widget` names for a rendered pane. Every pair on them clears its
    floor (9.34 and over). For the owner: a measured flat base of the recap's own, or `archived` as it is.
183. **The paywall's close button outgrows its circle at the accessibility sizes** (found by set A's step
    5's walk, W3, on the recap's copy of it). `PaywallView`'s ✕ is `.body` in a fixed 44-pt circle; the
    recap's now sizes its glyph as a share of the circle (17/44). The two screens now write the same
    button twice (the final review's M5; `PaywallStyle` is private). The owner's: fix the paywall's, and
    whether the button earns a file of its own (rule `50-views`).
184. **The recap's hand proofs owed to a device** (set A's step 5, spec §4). Sharing into real apps
    (Messages, Instagram, AirDrop), *Save to Files* on a device, VoiceOver by ear on the row, the card and
    the streak pane, the first-week row on a real 1st–7th (proved by tests and a `#Preview` only — the
    simulator runs on today's date), and iOS 17.x (no runtime here; *Save Image* withheld without the key
    was measured on 27.0, 26.5 and 18.6).
185. **The recap's Russian and Uzbek are drafts** (spec §3.10), following step 1's word for the feature —
    *Итоги месяца*, *Oylik xulosa* — for the owner's sweep with #170, #175 and #179.
186. **The recap's deferred minors** (set A's step 5's final review and walk). `RecapCard.Rendered` pins the
    text size but not Reduce Transparency, Increase Contrast or Bold Text — an `ImageRenderer` inherits
    none of the screen's environment, so the image draws the design's own (spec §4b, **inferred**);
    `readingARecapWritesNothingAndPublishesNothing` compares values by their description and skips the
    published-month case; `setAOnSaleStillWaitsForThePrivacyLink` repeats an existing assertion with a
    literal token; `make` computes `firstDay(ofMonthHolding:)` twice; `premiumRim()`'s DocC still says
    "only the Settings card" (three users now); at an impossible 100 000 ml a day the two tiles end at
    slightly different heights. The recap's colour pairs on iOS 26.5 and 18.6 and with Increase Contrast.
    The owner's to schedule.

## Where the rest is written down

- `docs/STATE.md` — the stored shape: keys, types, clamps, the rollover, the migration, the reminder seam
- `.claude/rules/80-notifications.md` — the notification rulings: why the plan is pure, why `add`
  replaces and `remove` cannot be awaited, why the widget shares the app's pending set
- `docs/WIDGET.md` — the widget contract: families, timeline, rendering modes, intent parameters
- `docs/DESIGN.md` — the design tokens and the measurements behind them
- `docs/ROADMAP.md` — the owner's release plan, 1.2 to 2.0 (2026-10-13): what each release
  carries, and the rule changes the later ones would need. A plan, not a record of what exists
- `docs/superpowers/specs/` and `docs/superpowers/plans/` — each stage's design and its plan
- `tasks/lessons.md` — pitfalls learned, append-only
- `HISTORY.md` — checkpoints, append-only

`docs/ARCHITECTURE.md`, `docs/CAPABILITIES.md` and `docs/dependencies.md` do **not** exist. The
topology is fully carried by `.claude/rules/10-architecture.md`, the capability surface by
`25-shared-storage` + `15-project`, and there are no dependencies to record. A stub restating a
rule file reads as coverage and is worse than the file's absence.
