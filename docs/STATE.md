# STATE — the stored shape

What is actually on disk in the App Group, as of the source in this tree. This is the derived
reference; the *rulings* behind these choices are in the DocC on `DataManager` and in
`.claude/rules/20-state`, `25-shared-storage` and `30-rollover`.

**Last updated:** 2026-10-24, evening (set A's step 5's own records, not a `/doc_sync` pass). **No key and
no stored byte moved**: 13 keys on `DataManager.Key`. A section, *`recap(of:)`*, under *The rows are
published too*: the month a page offers is derived on `MonthHistory`, and the recap is a read that
publishes nothing. *Who may write on behalf of the group*: the tenth guarded site, `recap(of:)`, and
every line under it re-derived — this step's insertions in `DataManager.swift` begin after line 1191 —
with the `role` declaration's comment (`:2024`, `:1996` at `HEAD` `ad244c2`); the literal
`manager.servings[1]` at `HistoryView.swift:447`.

**Last updated:** 2026-10-24 (eighty-eighth pass — `/doc_sync` run by the owner straight after the
eighty-seventh; no code changed since step 4's gate). **No key and no stored byte moved**: 13 keys on
`DataManager.Key`, counted from the source. **Drift, one citation:** the `role` declaration's comment in
*Who may write on behalf of the group*'s code block still read `DataManager.swift:1924`, `HEAD` `5b511bd`'s
line, where the declaration stands at `:1996` — step 4's records re-derived the nine guard lines under it
and `docs/AI_CONTEXT.md`'s own `role` citation, and left this one; the eighty-seventh pass checked the
guard lines and missed it too. Re-pointed, its old number kept. Every other line citation here into
`DataManager.swift` past line 216 or `HistoryView.swift` past line 52 — where step 4's insertions begin —
printed with the text it lands on: current ones land on what they name, the rest are dated notes.

**Last updated:** 2026-10-24, early morning (set A's step 4's own records — not a `/doc_sync` pass). **No
key and no stored byte moved**: 13 keys on `DataManager.Key`. A new subsection, *`insights`*, after
*`month.patterns`*: the last finished week, asked for and let go as the month is, its two reads, the ninth
`role.drawsHistory` site, and the model's words kept in memory only. *Who may write on behalf of the
group*: every guard's line re-derived by its words (step 4's insertions in `DataManager.swift` begin at
line 217) and the ninth site added; the `usualSlot` row's pointer to History's `servings[1]` re-pointed
`:397` → `:419`.

**Last updated:** 2026-10-23, evening (eighty-sixth pass — `/doc_sync` run by the owner on set A's step
3's staged tree; this header was the drift: step 3's records added a section and left it). **No key and
no stored byte moved**: 13 keys on `DataManager.Key`, counted from the source. A new subsection,
*`month.patterns`*, under *`month` and `monthLogs`*: the shown month's patterns, carried on `MonthHistory`
— which days count, what the value holds, the weekend handed in, the wall clock, and the cost measured
beside a `HEAD` twin (`MonthPatterns.make` 0.51–0.69 ms at 500 days). The `usualSlot` row of
*Constants both processes agree on*: its pointer to History's literal `servings[1]` re-pointed `HistoryView.swift:363` → `:397`, its old numbers kept. The
guard sites (*Who may write on behalf of the group*) all sit above the first line step 3 moved in
`DataManager.swift` (2,633) and are unchanged.

**Last updated:** 2026-10-23 (eighty-fifth pass — `/doc_sync` run by the owner on step 2's staged
tree). **No key and no stored byte moved**: 13 keys on `DataManager.Key`, counted from the source.
**Drift, fixed:** *Who may write on behalf of the group*'s guard list still cited `HEAD` `2e2f3a7`'s
seven lines, every one 41 to 137 short of the code, and said three further sites where step 2 made
four — `republishMonth()` (`:1182`) is the eighth, behind `drawsHistory`. Re-derived by the words of
each guard; the old lines kept in the note under it.

**Last updated:** 2026-10-23 (set A's step 2's own Task 10, after its walk, its review and its gate —
not a `/doc_sync` pass). **No key and no stored byte moved**: 13 `static let`s on `DataManager.Key`,
counted from the source, no schema change. A new section, *`month` and `monthLogs` — one month, only
while History asks for it*, after *`historyLogs`*: the two published values, the two reads and their
measured cost against the owner's 6 ms, the read-once pour, the counting rule, and the release moved to
the page's removal on the owner's ruling of 2026-10-23. The walk ran on a throwaway suite
(`-WaterBuddyFreshStart`, seeded in a scratch copy only) and wrote nothing to the App Group.

**Last updated:** 2026-10-22 (eighty-fourth pass — `/doc_sync` after set A's step 2 was specified and
planned). **No key and no stored byte moved; nothing was built.** Step 1, recorded below as staged, is
committed (`d5cf816`). Step 2's plan (`docs/superpowers/plans/2026-10-22-month-view.md`) adds to the
model two published values, `month` and `monthLogs`, read from the rows only while History asks for a
month and stored nowhere — no key, no schema change (its spec §3.7). This sheet records them when they
are built, with the probe's measured cost.

**Last updated:** 2026-10-22 (eighty-second pass — step 1's Task 10, after its walk, its fixes and its
gate). **Still no key moved**: 13 `static let`s on `DataManager.Key`, counted from the source. The
review's fix to `PremiumStore.refresh()` — a purchase clears *No purchases to restore.* — changes a
published value held in memory only; the paid state is still read from StoreKit, never stored, and the
store still holds three products. The walk ran on a throwaway suite (`-WaterBuddyFreshStart`) and wrote
nothing to the App Group.

**Last updated:** 2026-10-22 (eighty-first pass — `/doc_sync` after set A's step 1, Tasks 0–7, built
and staged). **No key moved**: 13 `static let`s on `DataManager.Key`, 11 on the phone and 2 on the
watch, counted from the source. One dated note under *Derived on read*: the monthly plan and the grace
ruling are on disk, and the store's two new published values are stored nowhere. Searched for
`StoreKit`, `Premium`, `keys`, `required-reason` and `locale`: nothing else moved — the privacy
manifests are untouched and step 1 adds no required-reason API.

**Last updated:** 2026-10-21 (eightieth pass — `/doc_sync` after 1.4.1's Task 6 and the owner's
redirection to set A). **No key moved**: 13 `static let`s on `DataManager.Key`, 11 on the phone and 2
on the watch. One dated note under *Derived on read*: the store is now built at launch and read on
every `.active`, as the paragraph already said; the monthly plan and the grace ruling are specified
for step 1 and not on disk. Searched for `StoreKit`, `Premium`, `review`, `keys` and `locale`: nothing
else moved.

**Last updated:** 2026-10-21 (seventy-ninth pass — `/doc_sync` with roadmap item 1.4.1 half built,
staged and paused). **No key moved**: 13 `static let`s on `DataManager.Key`, 11 on the phone and 2 on
the watch. 1.4.1's paid state is read from StoreKit and stored nowhere, by design — a dated paragraph
under *Derived on read, and a streak that is published and not stored*, and one under *What Apple is
told about all of this*. Searched for `StoreKit`, `review`, `keys` and `locale`: nothing else moved.

**Last updated:** 2026-10-21 (seventy-eighth pass — `/doc_sync` after roadmap item 1.3.2's stage 7c,
staged, before its `/commit`). **No key moved**: 13 `static let`s on `DataManager.Key`, 11 on the
phone and 2 on the watch, and 7c writes nothing to either suite. What changed is a reader: the
watch's faces read `WristMirror.languageCode` as the screen does, and format their figures with its
locale — two dated notes under *The language*.

**Last updated:** 2026-10-20 (seventy-seventh pass — `/doc_sync` after roadmap item 1.3.2's stage 7b,
staged, before its `/commit`). **No key moved**: 13 `static let`s on `DataManager.Key`, 11 on the
phone and 2 on the watch, and 7b writes nothing new to either suite — `WristPlan.Face` is read, never
stored. One dated note: `primaryIndex`, the watch's spelling of the Glass's index, is gone.

**Last updated:** 2026-10-20 (seventy-fourth pass — `/doc_sync` after roadmap item 1.3.1's stage 6c,
staged). **One key joins the phone's suite: `weekTotals`**, the last seven days' totals by day
ordinal, derived like `currentWater` and written where it is recomputed, by the app and the
extension; 13 `static let`s on `DataManager.Key`, 11 on the phone. Its row, the notes on the
doorbell paragraph, `history`'s guard and `Key.all` were written by the build; this pass moved the
counts that still said ten and re-derived the guard sites' lines and `role`'s by their words.

**Last updated:** 2026-10-18 (seventy-second pass — `/doc_sync` after roadmap item 1.3.4, Siri's
*Today's Water*, staged). **No key, no stored byte and no writer changed**; 12 `static let`s on
`DataManager.Key`, as before. What changed is a reader: `TodaysWaterIntent`, in the app's process,
answers from `DataManager.snapshot()` — `currentWater` with the rollover applied in memory,
`dailyGoal` — and writes nothing. A dated note on the `currentWater` row says so.

**Last updated:** 2026-10-18 (seventy-first pass — `/doc_sync` after known issue #144's fix).
**No key and no stored byte changed.** The test-isolation paragraph named `WelcomeUITests` as the one
UI suite launched on the fresh start; since roadmap item 1.2.8 the store capture is the second, and a
dated note says so. Its account of the launch — `prepareSharedStorage()` still runs first, against
the simulator's group container — was checked against `WaterBuddyApp.init()` and stands; it is what
#144 corrected the harness's DocC to say.

**Last updated:** 2026-10-18 (sixty-eighth pass — the owner's `/doc_sync` again). **No key and
no stored byte changed.** The streak paragraph forgot the kept run for "an earlier date"; the code
forgets it for any day other than today, and for `updateLog` when the serving was or becomes another
day's. Its claim that the tests pin both halves now says what they pin and what they do not
(`docs/AI_CONTEXT.md` #143).

**Last updated:** 2026-10-18 (sixty-seventh pass of `docs/AI_CONTEXT.md` — the owner's `/doc_sync`
after the lag fix). **No key and no stored byte changed.** One passage changed, *`streak` is observed
state with no key*: the run of days before today is now counted once and kept in memory
(`closedRun`) until the app changes one of them, the goal moves, the zone changes or the day turns.
It is not stored, so no key was added and *What Apple is told about all of this* has nothing to
answer.

**Last updated:** 2026-10-17 (roadmap item 1.2.6's records, written by the session that built it —
not a `/doc_sync` pass). **No key and no stored byte changed:** the plural forms live in the
catalogues, not the store. One passage changed, the language section's *Only sites that format
against the locale honour this*: every sentence with an argument now formats with the locale, so
both widgets, the watch's rows and every spoken figure are grouped (#39 closed). No key was added, so
*What Apple is told about all of this* has nothing to answer.

**Last updated:** 2026-10-16 (thirty-eighth pass — the owner's `/doc_sync` after roadmap item
1.2.5, on the staged tree). **No key and no stored byte changed.** Checked and standing: twelve keys
on `DataManager.Key`, ten in the phone's suite, as `CLAUDE.md` says; the new row and its claims
against the code. One gap: *What Apple is told about all of this* asks, for any added key, whether it
brings a new required-reason category, and nothing had answered it for `reviewRequestedVersion` — a
dated note there now does (none). The paragraph below is the thirty-seventh pass's, as it was
written.

**Last updated:** 2026-10-15 (thirty-seventh pass — roadmap item 1.2.5's records, the rating
request). **One key joins the phone's suite: `reviewRequestedVersion`**, the version the app last
asked iOS for a rating in — absent means never asked, written only by
`DataManager.claimReviewRequest(version:)`, read with `object(forKey:) as? String`, never
materialised, not migrated, not in the snapshot or the mirror. The phone's suite holds **ten** keys,
`Key.all` **twelve**. Two citations re-pointed: `HomeView.swift:108`, moved with its code, and the
`role` declaration's, now `DataManager.swift:1647` — it had named a line of the DocC above it. The
shorthand ones in *Who may write on behalf of the group* already named other lines at HEAD
`450d76f` and are left for a sync.

The paragraph below is the thirty-sixth pass's, as it was written.

**Last updated:** 2026-10-15 (thirty-sixth pass — roadmap item 1.2.4's records, then the owner's
`/doc_sync` on the staged tree). **No key and no stored byte changed:** the words a reminder was filed
in live in the notification centre's own requests, not in either store.
- The reminder hook fires from seven places — the `language` setter joined.
- *What the reconcile reads back* is new: `pending()` returns `PendingReminder`s; a planned reminder
  pending in other words is filed again in place; the category is the app's alone to register.
- The `usualSlot` and `servings` rows name the reminder's *Log a Glass* among what draws and logs the
  Glass (the second by the sync).

The paragraph below is the thirty-fifth pass's, as it was written.

**Last updated:** 2026-10-14, night (thirty-fifth pass — `/doc_sync` run again on the same tree. **No
key and no stored byte changed.** One sentence: the `isGoalSet` publish's account called the
welcome's goal slider "the setup slider"; it says the first-run goal, as the code's comment does.
And, from a fresh reader, *The language is why nothing asks `Bundle.main`* names the welcome among
the screens whose figures group by the locale. The key counts — eleven on `DataManager.Key`, nine
in the phone's suite — were checked again.)
Before that: 2026-10-14, night (thirty-fourth pass — `/doc_sync` after the redesign's stage 5,
staged and not committed. **No key and no stored byte changed.** *Tests that pin this* gains a
paragraph for stage 5's three suites that pin stored state — `ReminderPermissionTests`,
`WelcomeFinishTests`, `FreshStartTests`, 15 `@Test` — counted per suite; the eleven keys on
`DataManager.Key`, nine in the phone's suite, were checked against the code and stand. Then, from
two fresh readers: the test-isolation paragraph says the launch's own `prepareSharedStorage()`
still runs on a fresh start, and that the fresh start's side effects are off as a fixture's are;
the new paragraph's gloss of `WelcomeFinishTests` claims no test the suite does not hold, and its
list of the stage's other suites names `WelcomeStringTests`.)
Before that: 2026-10-14, evening (the redesign's stage 5, the welcome, staged and not
committed; written by the session that built it. **No key and no stored byte changed**, and no
shared file but a comment in `DataManager.swift`. The first-run screen is `WelcomeView`, named
where `GoalSetupView` was; *The sixth key* says who sets `remindersEnabled` now; four line
citations into `DataManager.swift` moved by one — the role and three of its guard sites; the test
isolation paragraph names the fresh start's fixed-name suite and `WelcomeUITests`' launch. The
guard sites and the isolation paragraph were found by a fresh reader, and so was the first
version of *The sixth key*'s note being wrong about who sets the flag.)
Before that: 2026-10-14 (thirty-third pass — `/doc_sync` after the redesign's stage 4,
Settings, staged and not committed. **No key, no stored byte, and no shared file changed.**
Settings now calls `refresh()` when it appears, as Home and History already did — the same path,
with the same rollover and reconcile, so nothing this sheet describes moved. One sentence was
wrong: the one that says which figures group by the locale still listed History's week card and
rows, grouped since stage 3, and Settings, grouped since stage 4 — it lists both widgets and the
watch's serving rows now. The literal `manager.servings[1]` is still at
`HistoryView.swift:305`; `LocalizationTests`, where the stage's one new unit test is, is not
among *Tests that pin this*. Stage 3c, which the pass below calls staged, was committed in
`a58b9e6`.)
Previously: 2026-10-13 (thirty-second pass — `/doc_sync` after the redesign's stage 3c, the
look, staged and not committed. **No key, no stored byte.** One shared file changed —
`LiquidGlassModifier.swift`, tokens and drawing only — and nothing this sheet describes. One line
citation moved with the stage: the literal `manager.servings[1]` is at `HistoryView.swift:305`.
*Tests that pin this* is unchanged: the stage's new tests are of the glass and the week card's
layout, and `HistoryServingTests` (6) and `HistorySelectionTests` (5) were recounted by script
and stand.)
Previously: 2026-10-12 (thirty-first pass — after the second pass of the redesign's stage
3b, the page slide and the small touches, unstaged. **No key, no stored byte.** It touches no
shared file and nothing this sheet describes. One line citation moved with it: the literal
`manager.servings[1]` is at `HistoryView.swift:283`. *Tests that pin this* is unchanged — the
pass's 47 new tests are of motion and layout.)
Previously: 2026-10-12 (thirtieth pass — `/doc_sync` run by the owner straight after the one
that closed the redesign's stage 3b, navigation and motion, which is unstaged. **No key, no stored
byte, and no source change since that sync.** Stage 3b touches no shared file, no stored shape and
nothing this sheet describes, and the sync that closed it left the sheet alone on that ground. Two
things here were wrong all the same, and this pass corrects them, **unstaged**: one line citation
— stage 3b moved the literal `manager.servings[1]` from `HistoryView.swift:240` to `:271` — and
one count that had been one short since stage 3, `HistoryServingTests` at 5 where it is 6, so
*Tests that pin this* is seventeen suites and 204 `@Test`, recounted per suite by script. The
sheet's other line citations — four that name a file, and the seven guard sites — were re-read
and stand.)
Previously: 2026-10-11 (twenty-ninth pass — `/doc_sync` at the end of the redesign's stage 3,
History, staged and not committed. **No key, no stored byte.** The model gained four derived
answers and stores none of them: `DaySummary.reached(_:)` and `daysMet(in:goal:)`, and
`dayFraction(of:)` and `hours(_:onDayOf:)` — see *The week's summaries* below. `DataManager.swift`
grew by 53 lines, so **seven of this sheet's eight line citations into it moved by 15** — `role`
and six of the seven guard sites — and are re-derived by `grep`; `HistoryView.swift`'s one moved
to `:240`. One caveat is new, on the day
boundary: `docs/AI_CONTEXT.md` known issue #107. Stage 2, which the passes recorded below call
staged, was committed in `1ced514`.)
Previously: 2026-10-11 (twenty-eighth pass — a fourth `/doc_sync` the same day, which checked
only what the twenty-seventh had added. **No key, no stored byte, no source change.** Two of its
added sentences were wrong, both copied from a stale comment in `DataManager.swift` instead of
read off the code: that `saveDailyGoal`'s publish to the wrist is unguarded "unlike every other
publish in the file" — four others are — and that without it the watch "would never leave its
empty state" — `WristView` is never gated on a mirror. Tightened: a recompute follows a reset in
three mutators as well as in `init` and `resetDailyProgress()`; the roster's test covers the
phone's nine keys and nothing covers the watch's two; the unit tests' own code touches no real
suite, but the unit target is hosted in the app, whose launch does; "every one ends in
`recomputeToday()`"; one more "named once"; and a seventh inline note that still carried
`AI_CONTEXT.md`'s pass number. The header below says "fourteen were loose"; its own diff holds
two more, the roster's "three lines under" and "`refresh()` always ends in a reschedule".)
Previously: 2026-10-11 (twenty-seventh pass — a third `/doc_sync` the same day, read by
another fresh reader against `DataManager.swift`. **No key, no stored byte, no source change.**
All nine line citations and the seven-site census held, and every test the sheet names exists.
**Four statements were wrong:** the roster's tripwire test was said to fail "the moment the two
disagree" — it compares the roster with itself, and the test that catches an omission is
`everyKeyTheProductWritesIsOnTheRoster`; a second copy of "the user-facing 'start over'" stood
thirty lines under the one the last pass corrected; `wristOutbox` was "read by `WristModel` only",
and the complication reads it too; and "`refresh()` now ends in `republishTodaysLogs()`". **Fourteen
were loose and are tightened**, each saying what it read before where that matters: the
`saveDailyGoal` sample left out its unconditional publish to the wrist; where a recompute follows
a reset; `schemaVersion` among the mirror's fields; the previews; `DaySummary.average`; which rule
forbids `@Query`; unit tests against UI suites; the phone table's heading; which keys the migration
carries; what `DayTurnTests` and the streak's test do and do not pin; `fetchLogsForToday()`'s
wording; `usualSlot`, which is not the index's only spelling (`docs/AI_CONTEXT.md` known issue
#104); and six inline notes that had named this sheet's twenty-sixth pass by `AI_CONTEXT.md`'s
number, the forty-seventh.)
Previously: 2026-10-11 (twenty-sixth pass — `/doc_sync` run again by the owner the same day,
soon after the twenty-fifth, and read by a fresh reader against `DataManager.swift` rather than against the
session's memory of its own edits. **The twenty-fifth pass's four new passages held; the text
around them did not.** Stage 2 had moved all seven line citations in *Who may write on behalf of
the group* and added a seventh guarded site there, `republishStreak()`; made `HomeView` a reader of
`todaysLogs` and of `history`, both still described as `HistoryView`'s alone; added a fourth site
that republishes the history; grouped Home's figures, which the language section still said
nothing on the phone did; and given the window's start a more general definition. **Older, found
on the way and corrected:** `lastActiveDay` and `language`'s "Written by" cells, the arithmetic
paragraph that still described the pre-SwiftData model, `percentage` placed on `DataManager`,
"the only path that deletes rows", a `#Preview` defect long since fixed, two entitlement files
where there are four, and three counts beside the key table. No key, no stored byte.)
Previously: 2026-10-11 (twenty-fifth pass — `/doc_sync` at the end of the redesign's stage 2,
Home, staged. **No key added, removed or renamed — still eleven — and no stored byte changed.**
What the model gained is derived or published, never stored: `addLog` returns the id of the row it
inserted and `undoLog(id:)` takes that row back; `remaining`, `hasReachedGoal`, `lastDrink` and
`nextReminder` are computed on read; `streak` is one more observed property, published with the
history and never written to the suite, the snapshot or the wrist's mirror; and the two day-change
observers now call `dayDidTurn()`, which republishes the rows when the day really turned. A new
section, *Derived on read, and a streak that is published and not stored*; *The rollover* and
*Tests that pin this* updated.)
Previously: 2026-10-09 (twenty-fourth pass — `/doc_sync` after known issue #73. **No key added,
removed or renamed** — still eleven — and no stored byte changed: `refresh()` now re-reads
`remindersEnabled`, which until then was read once, in `init`. Recorded under *The sixth key, and the
seam that reads it*. *Tests that pin this* gains four: seventeen suites, 203 `@Test`. The seven
`DataManager.swift` line numbers moved with the thirteen new lines and were re-derived.
Previously: 2026-10-08, twenty-third pass — `/doc_sync` after roadmap item 6, the Control Center
control (`docs/superpowers/specs/2026-10-08-control-center-design.md`). **No key added, removed or
renamed** — still eleven — and no stored byte changed: one constant, `usualSlot`, now names the index
`usualServing(in:)` reads, and the servings row names the control as a third reader. Re-verified the
same day by a second `/doc_sync`, which found the seven `DataManager.swift` line numbers here stale —
the six guard sites (last checked 2026-09-01) and `role` in the code sample — and re-derived them.
Previously: 2026-10-07, twenty-second pass — `/doc_sync` after roadmap item 4, the Siri phrase (`docs/superpowers/specs/2026-10-07-siri-phrase-design.md`). **No key added, removed or renamed** — still eleven — and no stored byte changed: the servings row now names `DataManager.usualServing(in:)`, the one definition of the middle vessel that the widget's snapshot and the Siri shortcut both read. Previously: twenty-first pass — `/doc_sync` after roadmap item 3, a serving added or
fixed at an earlier time or day (`docs/superpowers/specs/2026-10-07-earlier-servings-design.md`). **No
key added, removed or renamed**: still **eleven**, re-derived from `DataManager.Key`, and no schema
change — `WaterLog.timestamp` was already a `var`. What changed is derived state: a sixth observed
property, `historyLogs`, the window's rows from the fetch `history` is summed from; one definition of
where the window starts; and `updateLog` taking a time, which can move a serving's water between two
days — all under *`historyLogs`* below. *Tests that pin this* gains the change's six suites:
seventeen, 199 `@Test`, counted per suite. Previously: twentieth pass — `/doc_sync` after roadmap item 2, the complication kept
current (`docs/superpowers/specs/2026-10-07-complication-current-design.md`). **No key added, removed
or renamed**: still **eleven**, re-derived from `DataManager.Key`. The JSON `WristMirror` stored under
`Key.wristMirror` keeps its shape — `composedAt` became a `var` in Swift, which changes no byte on the
wire or at rest. What changed is where that stored mirror can come from: a complication push as well
as the application context, with the watch keeping whichever was composed later — recorded in the
`wristMirror` row below. *Tests that pin this* is unchanged: the new tests are wire and watch suites,
outside its eleven. Previously: nineteenth pass — `/doc_sync` after known issue #46 was fixed. **No key
added, removed or renamed**: still **eleven**, re-derived from `DataManager.Key`. The reminder seam
lost the first of its three limits — the production hook now queues every reconcile, in the order it
was asked for — and *Tests that pin this* gains `ReconcileQueueTests`: eleven suites, 172 `@Test`.
Previously: eighteenth pass — `/doc_sync` after smart reminders learned to skip
the one due within an hour of a drink. **No key added, removed or renamed**: still **eleven**,
re-derived from `DataManager.Key`. What changed is the reminder seam: the plan gained an input, the
latest drink, read off today's rows — recorded under *The plan depends on the goal* below. And
*Tests that pin this* had drifted before the change: its own figures summed to 152 against the 151 it
printed, while the tree held 160; corrected to the 169 that stand now. Previously: seventeenth pass —
`/doc_sync` after the watch was localized, known
issues #18 and #19. **No key added, removed or renamed**: still **eleven**, re-derived this pass from
`DataManager.Key` itself. What changed is that a stored value gained a reader: `languageCode`, inside
the `WristMirror` the watch keeps under `Key.wristMirror`, was composed and persisted but read by
nothing; `WristModel.language` now reads it, and it decides the watch's strings and number
formatting. Recorded in the `language` row and in *The seventh key*, below. The wire is unchanged —
`schemaVersion` stays 1. *Re-verified by a second `/doc_sync` run the same day: the key count
re-derived again, and one line corrected — an empty code falls back silently; only a non-empty
unrecognised one is announced under `#if DEBUG`.* Previously: sixteenth pass, 2026-10-05 — `/doc_sync` after known issue #26's
fix. **No key added, removed or renamed**: still **eleven**, re-derived this pass from
`DataManager.Key` itself.
What changed is the shape of one *value*: the JSON `WristMirror` stored under `Key.wristMirror` on
the watch gained an optional `phoneDayEnd` — the instant the phone's day ends — and the watch now
counts the mirror's `currentWater` only before it (spec §17). The change is additive: a value
persisted before it still decodes, with the field absent, and `schemaVersion` stays 1. Recorded in
the `wristMirror` row below. Previously: fifteenth pass — `/doc_sync` after the App Store
preparation work.
**No key added, removed or renamed**: the stored shape is unchanged at **eleven**, re-derived this
pass from `DataManager.Key` itself (a twelfth `static let` exists, `Key.all`, which is the collection
rather than a key) and confirmed against `Key.all`'s own eleven entries and `CLAUDE.md`'s count. One
section added — *What Apple is told about all of this* — documenting the four `PrivacyInfo.xcprivacy`
manifests that declare this product's `UserDefaults` access as a required-reason API. That is a
declaration **about** the keys, not a change **to** them, and it is recorded here because anyone
adding a key has to ask whether it drags a new required-reason category in with it. Previously:
fourteenth pass — `/doc_sync` after spec §16. **No key added, removed
or renamed**: the stored shape is unchanged at eleven, and `Key.all` still lists all eleven. What
changed is what the *absence* of `Key.wristMirror` means on the read side — it used to leave the
watch on a dead-end "Open WaterBuddy on your iPhone" screen, and now falls back to
`DataManager.defaultDailyGoal` so the watch draws a usable screen and attributes the goal it is
using. `WaterBuddyWatchWidget` takes the same fallback and additionally reads `Key.wristOutbox`.
Both are recorded in the `wristMirror` row below. Previously: thirteenth pass — the watchOS plan's
final task. **Three new keys**,
the first stored shape change since the eighth key: `Key.wristOutbox` and `Key.wristMirror` in the
watch's own local App Group suite, `Key.wristApplied` in the phone's. `Key.all` grows from eight to
**eleven**. A new section below documents the watch's suite as a physically separate container
under the identical App Group *identifier*, never to be confused with the phone's two stores. The
stale `!isAppExtension` reference in *Who reschedules* is corrected, and the two rule files it
pointed at as still wrong (`AI_CONTEXT.md` known issue #15) are themselves fixed in this same pass.
Previously: twelfth pass — **no stored shape changed**, but *who may write on
behalf of the group* is now asked in four states rather than two. `isAppExtension` feeds
`DataManager.role` and is read at no guard site; the section of that name is rewritten, the
migration and reminder-seam code samples updated, and `republishHistory`'s guard renamed.
Previously: eleventh pass — the reminder-seam claim in *Testing* was aspirational and is now true: the six fixtures that reached a real `UNUserNotificationCenter` were closed. No stored shape changed. Previously: tenth pass — `Key.all`, the roster the widget tripwires read. Previously: **an eighth key**: the three editable quick-add vessels, and the shared read that replaced `standardServing`)

---

## Two stores, one App Group

There is no network and no server, but there **is** a database now. The App Group holds two things,
and which is authoritative matters more than either on its own:

| | `WaterBuddy.store` (SwiftData) | `group.sardor.WaterBuddy` (`UserDefaults`) |
|---|---|---|
| Holds | every ``WaterLog`` — `id`, `amount`, `timestamp` | eleven keys (below; ten until 2026-10-20, `weekTotals` the eleventh) |
| Status | **source of truth** | **derived cache** |
| Written by | `DataManager` (app *and* `AddWaterIntent` in the extension) | `DataManager` only |
| Read by | the app — and the extension's own `DataManager`, inside `AddWaterIntent.perform()` and nowhere else | the app **and the widget** |

**Today's total is not stored anywhere as an authored value.** It is the sum of today's logs,
recomputed after every mutation by `DataManager.recomputeToday()` and written through the
`currentWater` setter — so the clamp, the equality guard and the widget doorbell all still fire
exactly once per real change.

**The widget's draw path never opens SwiftData** — rule `10-architecture`'s wording, and the exact
one: the extension *process* does open the store, when a tap runs `AddWaterIntent.perform()`
through `DataManager.shared`. A `TimelineProvider` carries no isolation and a
`ModelContext` is not `Sendable`; reading through the cache is what keeps `HydrationProvider`
synchronous and `nonisolated` (rule `43-concurrency`). This is the entire reason the cache exists,
and it is why the SwiftData move required no change to the widget at all.

The cache cannot drift silently: it is rewritten from the logs after every mutation, so a
disagreement means the log side is already wrong.

### Failure modes

- **Store unreadable.** `recomputeToday()` writes *nothing* and the total stands. An earlier draft
  returned `[]` from the failed fetch, which was written through as a total of zero — turning a
  transient read failure into permanent, persisted data loss. Distinguishing "no water today" from
  "could not tell" is load-bearing.
- **App Group unreachable.** The SwiftData container falls back to a process-local store and
  prints a `DEBUG` diagnostic, mirroring what `sharedDefaults` does for the suite.

When the App Group container is unreachable, `DataManager.sharedDefaults` falls back to
`.standard`, prints a `DEBUG`-only diagnostic naming the missing capability, and
`isSharedStorageAvailable` reports `false`. The app keeps working; the widget goes blank, because
it is reading a different container.

The probe is the **container URL**, not the suite object:

```swift
FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) != nil
```

`UserDefaults(suiteName:)` returns a live, silently process-local object when the entitlement is
missing. It only returns `nil` for the app's own bundle identifier or the global domain, so
checking it for `nil` proves nothing.

## Constants both processes agree on

All `nonisolated static` on `DataManager`, so a timeline provider can reach them.

| Constant | Value | Notes |
|---|---|---|
| `appGroupIdentifier` | `group.sardor.WaterBuddy` | also spelled in **four** entitlement files, one per signed target, invisible to the compiler *(read "two" since before the watch's two joined)* |
| `defaultDailyGoal` | `2_000` ml | also the value `isGoalSet`'s inference treats as ambiguous |
| `defaultServing` | `250` ml | the middle vessel **before the user edits it**, and the resolver's fallback. Renamed from `standardServing`, which asserted an invariant the editable vessels removed |
| `defaultServings` | `[150, 250, 500]` | the three vessels before the user edits them; `[1]` is `defaultServing` |
| `usualSlot` | `1` | which vessel the one-tap doors log — the Glass. `usualServing(in:)` reads its amount there, the Control Center control draws that slot's glyph — as, since 2026-10-15, does the reminder's *Log a Glass* button (`NotificationManager.reminderCategory(in:)`) — and — since the redesign's stage 2 — Home marks its primary disc by it (`HomeView.swift:108`; `:107` until 1.2.5); `theUsualSlotIsTheGlass` pins it to the Glass by name. Added 2026-10-08. **The index is not spelled only here:** `HistoryView.swift:447` (`:419` until set A's step 5, `:397` until set A's step 4, `:363` until set A's step 3, `:305` until set A's step 2, `:283` until the redesign's stage 3c, `:271` after the first build of stage 3b, `:240` until it) seeds a new serving with `manager.servings[1]`, and the watch has its own `primaryIndex = 1` (`WristView.swift:136`) — `docs/AI_CONTEXT.md` known issue #104. *(Read "so the index is spelled once" until the twenty-seventh pass.)* *(2026-10-20, the seventy-seventh pass: roadmap item 1.3.2's stage 7b, staged, deletes `primaryIndex` — the watch reads `usualSlot` — so History's literal is the one other spelling left.)* |
| `maximumDailyIntake` | `100_000` ml | upper clamp for both the total and the goal |

## The eight phone keys, plus a ninth: the phone's ledger of the watch's pours — and a tenth, the rating request's mark

Every key is built in `DataManager.Key` from the prefix **`sardor.WaterBuddy.`**. An App Group
domain is shared by every target that joins it, so an un-prefixed key is a collision waiting for
the next extension. `Key.all` — the roster the widget tripwires read — now lists **twelve** keys in
total: the ten in this table — the eight, `wristApplied` and `reviewRequestedVersion` — and the
watch's two, documented in *The watch's own suite* further down. *(Read "the eight below plus three
more, all documented" there until the twenty-sixth pass; the table has had nine rows since
`wristApplied` joined it, and ten since 2026-10-15, roadmap item 1.2.5.)* *(2026-10-20, roadmap item
1.3.1's stage 6c, staged: **thirteen** in `Key.all` — the eleven in this table, `weekTotals` the
eleventh, and the watch's two.)*

| Stored key | Type | Range / clamp | Written by | Why it exists |
|---|---|---|---|---|
| `sardor.WaterBuddy.currentWater` | `Int` | `0...100_000` | app + extension | Today's total in ml — **derived**, the sum of today's `WaterLog` rows. The key the widget actually reads. *(2026-10-18, roadmap item 1.3.4, staged: and the one Siri's *Today's Water* reads, through the same `DataManager.snapshot()`, in the app's process — no new writer.)* |
| `sardor.WaterBuddy.dailyGoal` | `Int` | `1...100_000` | **app only** | The target. Clamped to ≥ 1 so `progress` cannot divide by zero. Materialised at app launch so a widget never reads a missing key as `0` and shows the first sip as 100%. |
| `sardor.WaterBuddy.lastActiveDay` | `Int` | `yyyyMMdd` ordinal | app + extension — **the fresh-install stamp is the app's alone**; the rollover's is unguarded, so a widget tap that is the first act of a new day writes it, in the same call that zeroes `currentWater` | The day `currentWater` belongs to. An ordinal, not a `Date`, so travel cannot re-interpret it (see below). |
| `sardor.WaterBuddy.isGoalSet` | `Bool` | — | app only | Whether the user has *chosen* a goal, so setup is shown once. **Deliberately never materialised — its absence carries meaning.** |
| `sardor.WaterBuddy.servings` | `[Int]` | exactly 3, each `1...100_000` | **app only** | The three quick-add vessel amounts, positional: Cup, Glass, Bottle. **Index 1 is the vessel the widget draws and logs, and the one the Siri shortcut, the Control Center control and — since 2026-10-15 — a reminder's *Log a Glass* log** — read through `DataManager.usualServing(in:)`, the one definition they all call, at the index `DataManager.usualSlot` names — which is how the front doors agree now that the amount is no longer a shared constant. Never materialised — absence means the user kept the defaults. Never sorted or deduped: sorting would move which vessel the widget follows. Any anomaly (failed cast, wrong arity, an element out of range) discards the **whole** triple rather than repairing one element, because a partly-repaired triple is a row nobody authored. |
| `sardor.WaterBuddy.remindersEnabled` | `Bool` | — | app only | The reminders toggle. **Absent until switched on** — see below. |
| `sardor.WaterBuddy.language` | `String` | — | app only — the `language` setter, whose one caller is `SettingsView`. The widget *reads* it, and the watch reads it secondhand, as `WristMirror.languageCode` | The chosen UI language (`"en"`/`"ru"`/`"uz"`). **Absent means follow the device**, so it is never materialised either. |
| `sardor.WaterBuddy.didMigrateFromStandardDefaults` | `Bool` | — | **app only** | The one-shot flag for the migration below. Cannot be reset from inside the app. |
| `sardor.WaterBuddy.wristApplied` | `Data` (JSON `[Int: [UUID]]`) | **unbounded per day, until the 90-day trim** — see note below | **app only, via `ingest(_:)`** | The phone's per-day applied ledger for wrist-authored pours — day ordinal → the `WaterLog.id`s already folded in. `nonisolated`, unlike the eight keys above it (and the watch's two), because `readAppliedLedger(from:)`/`writeAppliedLedger(_:to:keepingDaysSince:)` are themselves `nonisolated static` and a nested type's members otherwise infer the enclosing `@MainActor` class's isolation. Trimmed to the last `appliedLedgerRetentionDays` (90) real calendar days on every write — never by subtracting a raw integer from the `yyyyMMdd` ordinal, which borrows across the month/day radix incorrectly (a real bug this plan introduced and fixed in its own Task 4, before it shipped). A write also protects any day it just folded into, even one already older than the 90-day cutoff, so the same write that adds an entry can never be the write that trims it (final review, `ingest(_:)`'s cutoff is `min(normalCutoff, foldedDaysThisPass.min() ?? normalCutoff)`). |
| `sardor.WaterBuddy.reviewRequestedVersion` | `String` | — (read with `object(forKey:) as? String`; anything else reads as never asked) | **app only, via `claimReviewRequest(version:)`** | The app's version (`CFBundleShortVersionString`, e.g. `"1.2"`) the last time it asked iOS for a rating (roadmap 1.2.5, `docs/superpowers/specs/2026-10-15-rating-prompt-design.md`). **Absent means never asked**, so it is never materialised. The claim writes it **before** answering `true`, so nothing asks without recording it, and Home asks at most once per version. It writes nothing else: no row, no widget doorbell, no reschedule — no widget, snapshot, mirror or notification reads it. Not `string(forKey:)`, which hands back a stored number as a string: a stored `1.2` would read as version 1.2 asked (`aStoredNumberCountsAsNeverAsked`, seen to fail against that read). No role guard: `streak` is zero in every process but the phone app, so the claim refuses there by construction. |
| `sardor.WaterBuddy.weekTotals` | `Data` (JSON `[Int: Int]`) | exactly 7 days, each `0...100_000` — each day clamped on the way **in** by `cacheWeek` (a corrupt negative row would otherwise write a week its own reader rejects: `aCorruptNegativeServingIsClampedInTheCachedDay`, from the final review), and validated on the way **out** by `readWeekTotals(from:)`, which discards the whole week on a failed decode, the wrong count or one day out of range, never repairing it | app + extension, via `recomputeTodayAndTheWeek()` — `init` and `saveAndRecompute()` only | The last `historyWindow` days' totals by day ordinal, zeros included, for the week widget, which may never open SwiftData (roadmap 1.3.1, `docs/superpowers/specs/2026-10-19-the-widget-stage-design.md` §3.4). **Derived**, like `currentWater`: rewritten from the rows wherever today's total is recomputed, in every process that builds a `DataManager`, so the extension's tap the morning after keeps yesterday after its `init` rolled the cached total over. **Absent means not yet known** — the widget says *Open WaterBuddy to see your week.* — so it is never materialised. Never written by `refresh()` or `dayDidTurn()` (a read across processes can miss the other's newest row), never from a failed read, never when unchanged. Rings the widget when it was missing or unreadable, or a day **before** today moved; today's change is the `currentWater` setter's ring, so one pass rings once. `nonisolated`, for the reader on the widget's path. The snapshot carries it as `WaterSnapshot.weekTotals`, and `week(endingOn:calendar:)` lays today's total over it. |

> **The `wristApplied` ledger is not capped at `maximumAckedIds` (256).** That cap belongs to a different, related
> but distinct thing: `WristMirror.acked`, the wire mirror's own array, sent phone → wrist on every
> publish. The mirror flattens *this* ledger across every retained day and truncates the result to
> 256 ids, newest day first, so the cap is a property of what goes out over `WatchConnectivity`, not
> of what this key holds on disk. Conflating the two is exactly the shape of the bug the final
> whole-branch review found: an ascending flatten kept the ledger's *oldest* ids under the mirror's
> cap instead of the newest, permanently stranding freshly-folded pours the ledger itself had
> recorded correctly the whole time.

> Note the migration flag's *stored string* is `…didMigrateFromStandardDefaults` while the constant is
> named `Key.didMigrateFromStandard`. The string is the thing that persists; do not "tidy" one to
> match the other without a migration.

## The watch's own suite

`WaterBuddyWatch` and `WaterBuddyWatchWidget` resolve the identical App Group *identifier string*,
`group.sardor.WaterBuddy`, through the same `DataManager.sharedDefaults` accessor the phone uses —
but the watch is a **different physical device**, so this is a different container on disk, holding
none of the phone's eleven keys above and read by none of the phone-side code. Never confuse "same
identifier" with "same storage": nothing written on one device is visible on the other except
through an explicit `WatchConnectivity` transfer (rule `70-privacy`).

| Stored key | Type | Range / clamp | Written by | Read by | Why it exists |
|---|---|---|---|---|---|
| `sardor.WaterBuddy.wristOutbox` | `Data` (JSON `[WristPour]`) | at most 64 pours per chunk sent, unbounded at rest | `WristModel`, **watch only** | `WristModel` **and** `WaterBuddyWatchWidget`, watch only — the complication counts the pending pours beside the mirror (spec §16) | The watch's own pending pours not yet durably queued to the phone (or queued but not yet acknowledged back). Local to the watch; the phone never reads or writes this key. |
| `sardor.WaterBuddy.wristMirror` | `Data` (JSON `WristMirror`) | one value, no clamp — the phone's own values are already clamped when composed | `WristModel`, **watch only**, from a decoded `WCSession` application context **or a complication push** (spec 2026-10-07 §4.5) — either way through `apply(_:)`, which never takes a mirror composed before the one held, unless the one held is stamped more than a minute ahead of the watch's own clock | `WristModel` **and** `WaterBuddyWatchWidget`, watch only | The last mirror received from the phone — `schemaVersion`, `currentWater`, `dailyGoal`, `servings`, `languageCode`, `isGoalSet`, `composedAt`, `phoneDayStart`, `phoneDayEnd`, `acked`. **`currentWater` is the phone's total for `[phoneDayStart, phoneDayEnd)` and for nothing after it (spec §17, 2026-10-05):** `WristPlan.todaysTotal(mirror:outbox:now:calendar:)` counts it only while `now < phoneDayEnd`, for `WristModel` and the complication alike, so a phone that slept through midnight no longer leaves yesterday's water on the wrist. `phoneDayEnd` is an instant composed on the phone's own calendar, not a day the watch re-reads under its own zone; it is optional only so a value persisted before it existed still decodes, and when absent the watch falls back to its own next midnight after `phoneDayStart`. The phone composes `currentWater` through `DataManager.snapshot`'s rollover, so a stale cached total never goes out under today's window. What the watch draws before its first `updateApplicationContext` of a fresh launch. **Its absence is no longer a dead end (spec §16, 2026-09-01):** `WristModel.displayGoal` falls back to `DataManager.defaultDailyGoal` and `WristView` draws a usable screen anyway, saying so in its attribution line — the key's absence now means "nothing from the phone yet", not "show a nag instead of a screen". `WaterBuddyWatchWidget` reads it directly, never through `WristModel.shared` (the identical discipline rule `40-widget` holds the phone widget to), and now takes the same fallback and adds `Key.wristOutbox`'s pending pours, so the face cannot read 0% while the app beside it shows real water. |

Both are written **only** by `WristModel`, never by `DataManager` — the one honest weakening rule
`20-state` now states plainly: one writer per store, not one writer full stop. `WristModel` never
opens SwiftData and never touches the phone's own App Group container.

**Of the phone's eleven keys, four are carried by the migration** — `currentWater`, `dailyGoal`,
`lastActiveDay`, `isGoalSet` (`migrateIfNeeded(from:into:)` names exactly those).
`didMigrateFromStandardDefaults` is not, because it *is* the bookkeeping; and `language` is not,
because it did not exist before the App Group did, so there is nothing in a pre-capability
`UserDefaults.standard` to carry. `remindersEnabled`, `servings` and `wristApplied` are not in
the list either; this sheet has never recorded a reason for those three. `reviewRequestedVersion`
is not, for `language`'s reason: it was born in the App Group, in 1.2.5 — and `weekTotals` is not,
for the same reason, born in 1.3.1's 6c (2026-10-20). *(This paragraph is
about the phone's suite and sits under the watch's table; the twenty-seventh pass left it where
it stood and said so.)*


### `WaterLog` (SwiftData)

| Property | Type | Notes |
|---|---|---|
| `id` | `UUID` | Stable across edits. **Not** `@Attribute(.unique)`: two processes insert here, and a unique constraint turns a benign collision into a failed save in whichever lost the race. |
| `amount` | `Int` | Millilitres. Positive; non-positive servings are rejected by `addLog`, not stored as zero rows. |
| `timestamp` | `Date` | When the serving happened. |

**A `Date` here does not contradict rule `30-rollover`.** That rule forbids storing *the day* as an
instant, because an instant re-read under a different time zone moves — which is how a user flying
west loses a day. A `timestamp` records *a moment*, which is real and does not move. The
distinction is in the read: `fetchLogsForToday()` never asks a stored day, and never compares
ordinals, to decide which day a serving belongs to. It compares the row's instant with two bounds:
it derives the half-open `[startOfDay, nextDayBoundary)` from
`Calendar.waterBuddyDay` — the same calendar the ordinal uses — so the log view and the rollover
cannot disagree. The `yyyyMMdd` ordinal remains the marker for *whether* the day turned.

### The seed migration

A user upgrading from the `UserDefaults`-only build has a total but no rows. `DataManager`
seeds one `WaterLog` from the cached total on first launch, guarded three ways so it cannot
double the water or resurrect an old day: it never runs in an extension, never runs when a log for
today already exists, and only runs when `lastActiveDay` is **today**.

This is the same discipline as the App Group migration (rule `25-shared-storage`): without it,
adopting a new store looks exactly like data loss.
### `Key.all` — the roster the tripwires read

`DataManager.Key.all` lists all twelve keys — the phone's own ten plus the watch's two
(`wristOutbox`, `wristMirror`) — directly under the declarations it mirrors, below its own DocC.
*(2026-10-20, 1.3.1's 6c, staged: thirteen — the phone's eleven with `weekTotals`. Every
`DataManager` writes it in `init`, so `everyKeyTheProductWritesIsOnTheRoster` reads it back and
requires it, and `readingACachedWeekLeavesTheStoreUntouched` compares it as one of the roster.)*
Production code never reads it; it exists so the widget's two read-path tripwires —
`readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys` — can prove a snapshot
read created and altered *nothing*.

Those tripwires are only ever as wide as the list they are handed, and that list used to be
hand-written **in the test file**. It enumerated six of the seven keys for two releases, omitting
`remindersEnabled`, so both tripwires were blind to a whole key while their own DocC claimed they
covered "everything WaterBuddy has ever written into a suite". Rule `30-rollover` warns about
precisely this: the helper "will not notice a new one on its own".

Keeping the roster beside the declarations is what makes the omission hard rather than likely.
**What catches an omission is `DataManagerTests.everyKeyTheProductWritesIsOnTheRoster`**: it drives
`DataManager`'s real writers and the migration, reads back every `sardor.WaterBuddy.` key that
landed in the suite, and requires the roster to hold it — and, since 1.2.5, requires the claim's
own key among them, because its count guard (`>= 8`) cannot see the claim: the other writers meet
it without it (measured: it held on a stub claim that wrote nothing). **That covers the phone's eleven keys and
not the watch's two** (ten until 2026-10-20; `weekTotals` is written by every `init`, so the test reads
it back without a change of its own): `wristOutbox` and `wristMirror` are written only by `WristModel`, in a
target the phone's tests cannot reach, and no watch test reads `Key.all` — so nothing would catch
either of those two going missing from the roster. `theTripwireHelperEnumeratesEveryStoredKey` does not — the helper
it checks *is* `Key.all`, so it compares the roster with itself and pins only that the helper is
no wider than the roster; its own DocC says so. *(Until the twenty-seventh pass this sentence said
that test "fails the moment the two disagree". The DocC on `Key.all` still says it —
`docs/AI_CONTEXT.md` known issue #103.)* The roster was fixed **before** the eighth key was added,
not after.

## How a value is resolved on the way out

**`dailyGoal`** — `resolveDailyGoal(in:)`:

```
object(forKey:) as? Int, and >= 1   → min(stored, maximumDailyIntake)
otherwise                           → defaultDailyGoal
```

A missing key reads as `0` through `integer(forKey:)`, and a `0` goal would make the first sip
read as 100%. Anything below 1 is therefore "never set".

**`isGoalSet`** — `resolveIsGoalSet(in:goal:)`:

```
flag present    → the stored Bool
flag absent     → goal != defaultDailyGoal
```

A missing flag means a build from before the flag existed, not necessarily a user who never chose.
Only `saveDailyGoal(ml:)` ever stores a goal that differs from the default, so a non-default stored
goal can only have come from the user. A stored goal that *is* the default stays genuinely
ambiguous, and the safe reading of an ambiguity is to ask once.

`isGoalSet` cannot be inferred from the *presence* of `dailyGoal`: `init` materialises the
resolved goal, so that key exists from first launch whether or not anybody chose it.

**The inferred `true` and the stored `true` are different facts, and `saveDailyGoal(ml:)` guards on
the store.** An instance on the upgrade path holds `isGoalSet == true` with the key *absent* — the
inference above produced it, and materialising the key is forbidden. So the write is guarded on
what the key says, not on what the instance believes:

```swift
if defaults.object(forKey: Key.isGoalSet) as? Bool != true {   // persistence — on the KEY
    defaults.set(true, forKey: Key.isGoalSet)
}
publishWrist(defaults)                                          // the wrist — unconditional
guard !storedIsGoalSet else { return }                          // observation — still guarded
withMutation(keyPath: \.isGoalSet) { storedIsGoalSet = true }
```

**The publish between the two is not behind the setter's equality guard.** A user who accepts the
first-run goal unchanged — the welcome's goal step since stage 5 — saves exactly `defaultDailyGoal`; the `dailyGoal` setter treats that as a
no-op and publishes nothing, yet `isGoalSet` has just changed and the mirror carries it — the
watch's attribution line reads *Set your goal in WaterBuddy on iPhone* until a mirror says
otherwise. This call sends that mirror at once rather than on the next foreground. It is one of
several publishes with no guard: `refresh()`'s, `applyDailyReset(on:)`'s and the two in
`WristLink`'s session callbacks have none either; only the four setters' are guarded.
*(This sample left the line out until the twenty-seventh pass, which then added two sentences
copied from the comment above the call in `DataManager.swift` — "unlike every other publish in
the file", and that `WristView` "gates its screen" on `isGoalSet` so the watch "would never leave
its empty state". Both are wrong, and the comment is stale: `WristView` has drawn a usable
screen without a mirror since spec §16, and its own DocC says the screen is never gated.
Corrected in the twenty-eighth; the comment is `docs/AI_CONTEXT.md` known issue #103.)*

Guarding both on `storedIsGoalSet` skips the only write of that key in the product. Edit such a
goal down to exactly `defaultDailyGoal` and the inference re-derives `false` on the next read, and
`RootView` cross-fades the app back into setup mid-session. This was unreachable while
`saveDailyGoal(ml:)` had one caller — `GoalSetupView` (since stage 5, `WelcomeView`) is presented
only while the flag is `false`, so the guard could never short-circuit — and became reachable when
`SettingsView`'s `GoalCard` became the second. `editingAnInferredGoalDownToTheDefaultPersistsTheFlag` pins it.

## How a value is clamped on the way in

Both setters clamp, then guard on equality before writing:

```swift
let clamped = newValue.clamped(to: 0...Self.maximumDailyIntake)   // dailyGoal: 1...
guard clamped != storedCurrentWater else { return }                // no-op writes do not churn
withMutation(keyPath: \.currentWater) {
    storedCurrentWater = clamped
    defaults.set(clamped, forKey: Key.currentWater)                // write-through in the same statement
}
reloadWidgets()                                                    // once, per real change
publishWrist(defaults)                                             // and the watch's mirror, the same
```

The equality guard is what keeps a no-op write from invalidating SwiftUI observers and from
ringing the widget doorbell. **The total is a sum, and the sum saturates:** `recomputeToday()` adds
today's rows with `addingReportingOverflow` and pins at `maximumDailyIntake` rather than trapping
on a corrupt row. `DaySummary.series` does the same for each day's total; `DaySummary.average`
also adds without trapping, and pins its running sum at `Int.max` before it divides. Non-positive amounts are refused by `addLog`
and by `removeWater`. *(Until the twenty-sixth pass this paragraph put the arithmetic in
`addWater` / `removeWater` and named `subtractingReportingOverflow`, which is nowhere in the tree:
it described the model from before the total was derived from the rows. `addWater` only forwards to
`addLog`, and `removeWater` takes water off the rows themselves.)*

`addLog` — and so `addWater` — and `removeWater` call `refresh()` **before** they touch the rows,
because two processes hold their own instance and an idle one would otherwise act on a stale day.

## The rows are published too, and only reads may cross

`todaysLogs` is a fourth observed property — today's servings, newest first — alongside
`currentWater`, `dailyGoal` and `isGoalSet`. It exists because `fetchLogsForToday()` reads the
store directly and calls no `access(keyPath:)`, so a view reading it never redraws, and a SwiftData
`@Query` is forbidden from a view (rule `50-views`; the layer boundary is rule `10-architecture`'s). `HistoryView` lists it; **since the
redesign's stage 2 `HomeView` reads it too** — to know whether the serving an *Undo* offer names
is still one of today's — and `lastDrink` and `nextReminder` are derived from it.

*("Fourth", and the "fifth" and "sixth" below, count the order these four were added in, not the
properties the model publishes. It publishes ten: `currentWater`, `dailyGoal`, `isGoalSet`,
`todaysLogs`, `history`, `historyLogs`, `streak`, `remindersEnabled`, `language` and `servings`.)*

Two properties of it are deliberate and both have tests:

- **No equality guard**, where `currentWater` and `dailyGoal` both have one. `WaterLog` is a
  `@Model` class whose `Hashable` conformance is by `persistentModelID`, so the array after an
  *amount edit* compares equal to the array before it; a guard would swallow exactly the change a
  history row needs to see (`editingALogInvalidatesObserversOfTodaysLogs`).
- **Read-only**, for the reason `isGoalSet` is: it is a consequence of the logs.

`refresh()` republishes the rows with `republishTodaysLogs()` — a **read**. It re-reads the rows
and does *not* recompute the total from them:

```swift
func refresh() {
    loadFromStore()            // the total, out of the cache
    resetIfNeeded()            // the day, if it turned
    republishTodaysLogs()      // the rows — never the total
    republishHistory()         // the last seven days and the streak — reads, app-only
    rescheduleRemindersNow()
    publishWrist(defaults)     // the watch's mirror, when one is paired
}
```

Recomputing the total here was tried and rejected. `AddWaterIntent` writes a row *and* the cache
from the extension; a cross-process SwiftData read can succeed while returning rows that do not yet
include it, and re-deriving from those would overwrite the other process's serving with a smaller
figure and ring the doorbell to announce it. `refreshPicksUpAnExternalWrite` is the test that
caught it. A stale list beside a correct total is a display inconsistency the next mutation heals;
the other way round destroys water — the failed-read rule, one step further out, because a fetch
can be wrong without throwing.

### `history` — the same shape, one store read wider

`history` is a fifth observed property: `[DaySummary]`, the last `DataManager.historyWindow` (7)
local days, oldest first, today last. `HistoryView` draws from it — the week card, whether
the card is drawn at all, and since 2026-10-07 the header's total for a past day and which day is
shown — and **since the redesign's stage 2 `HomeView` reads its last day for the date in its
header**, which is why the header follows the model across midnight (`dayDidTurn()`, below).
*(Until 2026-10-07 this read "the week card is its only consumer", which `HistoryView`'s own
`hasSomethingToShow` already contradicted; and until the twenty-sixth pass, "`HistoryView` is its
only consumer".)* It **stores
nothing** — no eighth key, no schema change, no column on `WaterLog` — and is recomputed from the
rows on every republish, so it belongs to this document only as *derived* state.

It differs from `todaysLogs` in three ways, each for a stated reason:

- **It carries an equality guard**, where `todaysLogs` deliberately does not. The hazard that
  forbids one there is the element type: `WaterLog` is a `@Model` class hashed by
  `persistentModelID`, so the array after an amount edit compares equal to the array before it.
  `DaySummary` is a value compared by its fields, so an equal array genuinely means nothing moved —
  and `refresh()` runs on every foreground, where an unconditional mutation would redraw the card
  for nothing. Pinned by `aRefreshThatChangesNothingDoesNotChurnHistoryObservers`.
- **Its republish is guarded on `role.drawsHistory`.** The four guards in the section below stop a
  non-owner *writing* group state; this one stops it doing work it can never draw.
  `recomputeToday()` is deliberately unguarded, so `AddWaterIntent` reaches `saveAndRecompute()` on
  every widget tap — without the guard, that tap runs a seven-day fetch and a full roll-up inside
  the `.appex`. Nothing about history crosses to the widget: a per-day series is derivable from
  none of the phone's ten keys. *(2026-10-20, roadmap item 1.3.1's 6c, staged: no longer — the
  week crosses as `weekTotals`. The guard now covers what the app draws — the rows, the series, the
  streak — and `republishHistory(cachingTheWeek: true)`, from `init` and `saveAndRecompute()` only,
  runs the seven-day fetch and roll-up in the extension too, to keep the cache. Measured: a median
  0.42 ms a tap on the simulator, against 0.14 ms for today's rows.)*
- **It is republished from four sites**, not one — `init`, `refresh()`, `saveAndRecompute()` and,
  since the redesign's stage 2, `dayDidTurn()` — because a mutation must show up on the card
  immediately, `addLog` calls `refresh()` *before* it inserts, and a day that turns under an open
  screen has no mutation to ride on. Each republish also republishes the streak.

The fetch behind it is `readLogs(from:to:)`, the first range query in the product. It reuses the
half-open `[start, end)` predicate shape that `readTodaysLogs()` uses — which now routes through it,
so there is still exactly **one** `#Predicate` in the codebase — and it honours the same
`Optional` contract: a failed read returns `nil` and `republishHistory()` returns early, leaving the
last published window standing. Publishing an empty window instead would draw a chart
indistinguishable from a user who never drank.

Grouping happens in Swift, not in the store: a `#Predicate` cannot call `Calendar` or group, and
`WaterLog` may never gain a day column (rule `30-rollover`). So `DaySummary.series(...)` buckets by
`DataManager.dayOrdinal(for:in:)` on the injected calendar, walks the window with
`date(byAdding: .day,)` rather than by seconds, sums with `addingReportingOverflow`, and zero-fills
a day nobody drank on — a window that omitted empty days would draw a seven-bar axis describing some
other number of days.

**A past day has no goal of its own, and never will retroactively.** `Key.dailyGoal` is a single
scalar overwritten in place, and `SettingsView.GoalCard` lets the user move it at any time, so
`DaySummary` deliberately carries **no `goal` field**: today's figure stamped onto seven days would
look like a record of something the store cannot know. The card compares against the current goal
and discloses that it does.

**The week's summaries, since the redesign's stage 3** (staged 2026-10-11). Four more answers are
derived, and none is stored, cached in the suite, or sent to the widget or the wrist:

- `DaySummary.reached(_ goal:)` — `total >= goal`, the goal a parameter and still not a field —
  and `DaySummary.daysMet(in:goal:)`, a count over a series. History's card draws a day that
  reached the goal in another colour and counts them; `streak`, `streakFillsWindow` and
  `closedDays` ask the same `reached(_:)`, so for a day's summary "reached the goal" has one
  spelling. Today's has its own two: `hasReachedGoal` (`currentWater >= dailyGoal`) and the
  reminder plan's comparison of the same two figures.
- `DataManager.dayFraction(of:in:)` — where an instant falls in its local day, `0` at the day's
  start and under `1` at its last minute, as a fraction of **that day's real length**: from
  `startOfDay` to `nextDayBoundary(after:calendar:)`, never of 86,400 seconds. Noon is past the
  middle of a 25-hour day and short of it on a 23-hour one (`DayFractionTests`).
- `DataManager.hours(_:onDayOf:in:)` — the instants of the given clock hours on that day, through
  `Calendar.date(bySettingHour:minute:second:of:)`, an hour the calendar cannot place left out.

  Both are `nonisolated static`, take the calendar as a parameter, and have an instance wrapper
  that passes the model's injected one. History's strip is their only caller.

**One caveat, older than stage 3 and found by it** (`docs/AI_CONTEXT.md` known issue #107). In a
zone whose clocks go back across midnight — America/Havana, 01:00 to 00:00 —
`nextDayBoundary(after:)` answers the *second* 00:00 of the same day for an instant in the first
of the two 00:00–00:59 hours (tried at 00:30 and 00:59; at 00:00 itself the answer is right).
Worked through for three callers, by reading each code path with that answer — nothing was run
in the app: `fetchLogsForToday()`'s bounds
still hold every row during that hour, since in ordinary use no row is later than now;
`dayFraction` measures that hour against a one-hour day and puts a 00:30 serving mid-strip; and
a widget timeline built in that hour dates its zeroed entry at the second 00:00, an hour after
the day began, and reloads there. The wrist mirror's `phoneDayEnd`, the history fetch, the
streak's windows and `WristPlan` — twice, one of them the watch complication's timeline
boundaries, the twin of the widget's entry — call it too and were not worked through. Read off
Foundation with a script that stores nothing; not fixed.

### `historyLogs` — the window's rows, from the same fetch

`historyLogs` is a sixth observed property: `[Int: [WaterLog]]`, the window's servings keyed by day
ordinal, newest first within each day, a day with none having no key. History lists a past day from
it. It is published by `republishHistory()` **from the fetch `history` is summed from**, so a bar
and the list under it are one reading of the store — the reason `recomputeToday()` publishes today's
rows and total from one fetch.

- **No equality guard**, for `todaysLogs`' reason: a `[WaterLog]` compares by `persistentModelID`.
  It is published *before* the series' guard returns, because a serving re-timed inside a past day
  moves no total — `history` compares equal and stays put — while that day's rows reorder. Pinned by
  `retimingAServingWithinAPastDayRepublishesItsRows`.
- **App-only**, under the same `role.drawsHistory` guard; the widget extension never builds it.
  *(2026-10-20: still true — since 6c the extension reads the same window to cache the week, and
  publishes none of its rows.)*
- **Stores nothing.** Like `history`, it is derived on every republish.

The window's start has one definition: `DataManager.windowStart(days:endingOn:calendar:)` — which
`historyWindowStart(endingOn:calendar:)` forwards to with the seven-day window, and which the
streak's wider windows call directly since the redesign's stage 2 — beside
`nextDayBoundary(after:calendar:)`, stepped in calendar days — never 86,400 seconds, which lands an
hour off midnight across a DST change (`theWindowsOpeningWalksCalendarDaysAcrossTheEndOfDaylightTime`).
The bars' fetch and History's sheet both call it. The sheet's wheel offers
`correctionRange()` — that start up to `now()` — and that range is an **offer, not a floor**: `addLog`
and `updateLog` accept any instant, as they accept any positive amount while the editor offers 50–1,000
ml. `fetchLogsForTodayExcludesOtherDays` logs a serving dated tomorrow through `addLog`, and rejecting
future instants there would have left it green while it tested nothing.

`updateLog(_:newAmount:timestamp:)` corrects an amount, a time, or both, in one save; `timestamp: nil`
keeps the time. Moving a serving across midnight moves its water between two days, and
`saveAndRecompute()` follows it: today's total is re-derived through the `currentWater` setter, so the
cache key, the widget doorbell and the wrist publish move **only if today's total did** — a serving
added to or re-timed inside a past day wakes nothing (`aServingBackdatedIntoYesterdayRingsNoWidgetDoorbell`,
`aMoveAcrossMidnightRingsTheWidgetDoorbellOnce`). *(2026-10-20, roadmap item 1.3.1's 6c, staged: the
widget doorbell no longer — a past day is a bar the week widget draws, so a serving added to or
re-timed inside one rings it **once**, through `weekTotals` (`aServingBackdatedIntoYesterdayRingsTheWidgetOnce`,
the test renamed and inverted on the owner's ruling; `anEditToAnEarlierDayRingsTheWidgetOnce`); a move
across midnight still rings once (`aServingMovedToYesterdayRingsOnce`). The `currentWater` key and the
wrist publish still move only with today's total.)* A watch pour can be re-timed safely: the applied
ledger is keyed by the pour's own `at`, which a resend repeats, and the existence check finds the row
by `id` wherever its time moved (`aRetimedWatchPourStaysDeletedWhenTheWatchResendsIt`).

### `month` and `monthLogs` — one month, only while History asks for it

*Added 2026-10-23, set A's step 2 (roadmap 1.4.2), staged; spec
`docs/superpowers/specs/2026-10-22-month-view-design.md` §3.4–3.7.*

`month` is a `MonthHistory?` and `monthLogs` its rows, `[Int: [WaterLog]]` by day ordinal as
`historyLogs` is. **Both are published, and neither is stored**: no key, no schema change, nothing for
the widget or the watch. They exist only while History has asked for a month through
`showMonth(_:)` — a holder choosing Month, an arrow, Premium bought with Month on screen — and
`showMonth(nil)` lets go of both: choosing Week, Premium ceasing to be held, and the page being removed
when its slide out has ended (`onDisappear`, the owner's ruling of 2026-10-23 on the final review's I1
and I2 — at the turn it emptied the month on the page sliding away). `showMonth(_:)` writes neither
store.

- **What is wanted is an ordinal, the month's 1st** (`wantedMonth`, private, in memory), and `thisMonth`
  answers this month's. A month's bounds come from the injected calendar's `dateInterval(of: .month,
  for:)` and its days from `date(byAdding: .day, …)`; the grid's first weekday is the app's locale's.
- **Two reads, wherever the history's length:** `republishMonth()` fetches the rows from the 1st of
  the month before to the end of the wanted month — the change line needs last month's average — and
  `readOldestLog()` fetches the first serving (forward sort, `fetchLimit` 1, pending changes included),
  which bounds ‹ and starts the first month's count. Either read failing returns before either value is
  touched: a failed read leaves the month as it stands, never empty.
- **Published from** `showMonth`, `refresh()`, `saveAndRecompute()`, `dayDidTurn()` (so a month ending
  on screen stays shown and becomes past) and the `dailyGoal` setter (every day is judged against the
  current goal) — **never `init`**: `wantedMonth` starts `nil`. Behind `role.drawsHistory`, as
  `history` is. `month` has an equality guard; `monthLogs`, like `historyLogs`, has none.
- **A pour reads the shown month once.** `addLog` and `removeWater` re-read through the private
  `refresh(republishingMonth: false)`, and the `saveAndRecompute()` after their write republishes it
  (the owner's ruling of 2026-10-22). `ingest(_:)` keeps `refresh()`, so a watch batch reads it twice.
- **The counting rule** (`MonthHistory.make`): every day is judged against the **current** goal; a past
  month counts every day; this month counts the days before today, and today once it has reached the
  goal; the first month counts from the first serving's day; a day after today counts nowhere and
  cannot be opened. Sums saturate at `maximumDailyIntake` a day.
- **Measured cost**, on the built code, a probe in a copy of the index (iPhone 17, iOS 27.0), at 500
  days of rows: `refresh()` 0.59 ms alone, **+2.34 ms** with a month shown; a pour 3.68 ms alone,
  **+2.77 ms** with a month shown — inside the owner's **6 ms** (the spec's 3 ms, amended on 2026-10-22).
  The month's two-month window is the cost (~4.5 ms for ~490 rows before the read-once ruling); the
  first-serving read is 0.05–0.6 ms from 7 to 500 days.

### `month.patterns` — the shown month's patterns, carried on the month

*Added 2026-10-23, set A's step 3 (roadmap 1.4.6), staged; spec
`docs/superpowers/specs/2026-10-23-patterns-design.md` §3.1–3.6.*

`MonthHistory` carries `patterns: MonthPatterns?`, built by `MonthHistory.make` from the rows it is
already handed. **No new property, no new read, no key, no schema change**: the patterns are published,
equality-guarded, kept through a failed read and let go exactly as `month` is, and reach neither the
widget nor the watch.

- **Which days:** the shown month's days on or after the first serving's and **before today** — today
  joins at midnight, through `dayDidTurn()`'s republish. A serving stamped after today counts nowhere.
  `nil` until **seven** of those days hold water (`MonthPatterns.minimumDays`); seven days with water
  among consecutive finished days span a week, so both sides of the split always have days.
- **What it holds:** each hour's water (24 entries, saturated at `Int.max`) and the busiest hour (a tie
  to the earlier); each weekday's water and count of days, Sunday first, a day's water saturated at
  `maximumDailyIntake`; the usual first and last drink — the median of the days' wall-clock minutes, the
  earlier middle for an even count, rounded to five minutes and held at 23:55; the goal it was judged
  against; and three instants on the month's 1st, for formatting only.
- **The weekend is handed in** — `split(weekend:)` takes the app's locale's weekend from
  `HistoryView.weekend(in:)`, so a language change needs no republish. Empty counted days stay in each
  side's denominator, as the month's average does.
- **A serving's hour and minute are the wall clock's** on the injected calendar (`minuteOfDay`), never
  seconds since midnight; the day is `dayOrdinal(for:in:)`'s (rule `30-rollover`).
- **Measured cost**, on the built code, a probe in a copy of the index beside its twin on a `HEAD`
  `24b2de4` export, alternated twice (iPhone 17, iOS 27.0), at 500 days: `MonthPatterns.make` alone
  **0.51–0.69 ms** over the two-month window's 458 rows; with a month shown, `refresh()` added +2.80 /
  +4.37 ms and a pour +4.30 / +5.97 ms, against `HEAD`'s +2.58 / +3.27 and +2.92 / +6.32 in the same
  rounds — the difference inside the run-to-run noise, every figure under the owner's 6 ms. Each run
  started at a load of 7 or under and drove it to 83–136 by its own simulator boot.

### `insights` — the last finished week, while History's Insights asks

*Added 2026-10-24, set A's step 4 (spec `docs/superpowers/specs/2026-10-23-insights-design.md`).* **No
key and no stored byte**: `insights: WeekInsights?` is derived on every read and published like `month`.

- **Asked for** through `showInsights(_ request: WeekInsights.Request?)` — the app's locale's first
  weekday and weekend, because the model's calendar is fixed to `en_US_POSIX` — and let go with `nil`:
  when Week or Month is chosen, when the page is removed, when Premium stops being held.
- **Two reads**, as the month's: the rows from the first day of the week before to the first day of the
  week now running (`WeekInsights.interval(of:now:calendar:)`), and the first serving. Either failing
  leaves `insights` as it stands; equality-guarded.
- **Republished** beside every `republishMonth()` — the `dailyGoal` setter, `saveAndRecompute()`,
  `dayDidTurn()`, `refresh()`'s public form — and from `showInsights(_:)`; never from `init`, never from
  the `servings` setter: the suggestion's vessel is chosen when drawn (`Suggestion.vessel(in:)`).
- **Behind `role.drawsHistory`**, the ninth guarded site (*Who may write on behalf of the group*).
- **What it holds**: the week's first and last day and the next week's first, for formatting only; and,
  when the week has four counted days with water, the three parts as `Finding`s with the shortfall's
  `Suggestion`. Counted days start at the first serving's day; every day is judged against the current
  goal; a negative row reads as nothing.
- **The model's words are not state.** `InsightWriter` keeps the notes Apple's on-device model wrote in
  memory, for the run of the app, keyed by the English sentences it was handed; nothing reaches either
  store, the widget, the watch or a notification (rule `70-privacy`).

### `recap(of:)` — a finished month, read for its sheet, published nowhere

*Added 2026-10-24, set A's step 5 (spec `docs/superpowers/specs/2026-10-24-monthly-recap-design.md`).*
**No key and no stored byte**, and — unlike `month` and `insights` — **nothing published**.

- **Which month a page offers** is `MonthHistory.recap: Neighbour?`, worked out in `make` from the rows it
  already has: a finished month offers its own once `MonthPatterns.minimumDays` (7) of its days hold
  water; the month holding today offers the month before's, on the same bar, while today is one of its
  first `MonthHistory.recapDays` (7) days, today's day of the month read off its ordinal on the model's
  calendar. It takes part in `month`'s equality, so the row appears and goes through the republish that
  already runs (`dayDidTurn()` at the 7th→8th turn).
- **Read once, on the row's tap**, through `recap(of firstDay:)`: the month's own two reads, spelled once in
  `readMonth(_:)`, which `republishMonth()` calls too — the rows from the 1st of the month before to the
  end of the month, and the first serving. It returns the month only when its own `recap` names itself; a
  failed read is `nil`, never an empty month.
- **Writes nothing**: neither store, no doorbell, no reschedule; `month` and `monthLogs` stand as they were.
  Behind `role.drawsHistory`, the **tenth guarded site** (*Who may write on behalf of the group*).
- **The shared image is not state.** `RecapSheet` renders the card with `ImageRenderer` into a `UIImage` it
  holds while it is open, and `ShareLink` exports it as PNG on the user's tap; no file is written, no key,
  and the app records nothing of where it went (rule `70-privacy`). The streak is drawn beside the card,
  never on it (rule `20-state`).

## The sixth key, and the seam that reads it

`remindersEnabled` is a `Bool`, **absent until the user turns reminders on**. Like `isGoalSet` and
unlike `dailyGoal` it is never materialised: scheduling notifications for someone who never asked is
the wrong default, so "missing" and "off" have to mean the same thing.

It is settable — it is a genuine preference rather than a consequence — and carries the same
write-through and equality guard as `currentWater` and `dailyGoal`, so a no-op write neither
invalidates observers nor re-plans the day. Setting it re-plans **in both directions**: switching
reminders off has to *clear* what is already filed with the system, not merely stop adding to it.

*(2026-10-14, the redesign's stage 5: who sets it, all app-only. Turning reminders **on** — Settings'
switch, or *Turn on reminders* on the welcome's last step — stores iOS's answer through
`ReminderPermission.enable(on:using:)`, which asks only when iOS has not been asked. Settings'
switch turning **off** writes `false` itself (`SettingsView.swift:213` since set A's step 1; `:189` at
`HEAD`). And
`ReminderPermission.reconcile(_:using:)` clears it when iOS reads *denied* and changes nothing
otherwise; it runs whenever the app comes forward (`WaterBuddyApp`) and whenever Settings appears
or comes back to the foreground (`SettingsView.readSystemState()`). Every write is the one setter,
so the write-through, the guard and the re-plan are unchanged; nothing new is stored.)*

**It is re-read on every `refresh()`** (2026-10-08, known issue #73). Only the app writes it, but a
widget extension's `DataManager.shared` can outlive the write, and `AddWaterIntent` files that
instance's plan. Until then `loadFromStore()` re-read the goal, the vessels and the language and left
this flag as `init` had read it. A press made after the toggle moved therefore filed an empty plan over
reminders just switched on, or a full one over reminders just switched off. The re-read sits behind the
same equality guard as its neighbours and reschedules nothing itself: `refresh()` always
reschedules, after the re-read (its last call is the wrist's publish). `aLongLivedExtensionPlansRemindersTurnedOnInTheApp` and
`aLongLivedExtensionStopsPlanningRemindersTurnedOffInTheApp` pin the two directions;
`refreshPublishesARemindersFlagChangedByAnotherProcess` and
`aRefreshThatFindsTheFlagUnchangedDoesNotChurnObservers` pin the publish and the guard.

`DataManager` takes a sixth injected dependency and hands out a plan; it never touches
`UserNotifications` itself:

```swift
rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule
```

Fired from **seven** places, because one is not enough (six until 2026-10-15, when the `language`
setter joined):

| Where | Why |
|---|---|
| `recomputeToday()` | every log mutation, from either process, with the fresh total in hand |
| `applyDailyReset(on:)` | it bypasses the `currentWater` setter, so a setter-only hook would miss **midnight** |
| `refresh()` | idempotent reconciliation on foreground — the backstop for a widget tap |
| the `remindersEnabled` setter | the preference itself, in both directions |
| the `dailyGoal` setter | **the goal is half of "goal reached"** — see below |
| the `language` setter | it moves no slot, but every pending reminder is in the old words; the queued operation registers the button in the new language and the reconcile files each reminder again in it (2026-10-15) |
| `init` | an instance that never mutates anything still has to arrive at a correct schedule |

**What the reconcile reads back** (2026-10-15, roadmap item 1.2.4). The scheduler's pending read,
`pending()`, returns each request with the words it was filed in — a `PendingReminder` of its
identifier, title, body and category — and `reconcile` files again, under its own identifier, a
reminder still in the plan that is pending in other words than it would file now (one no longer in
the plan is removed, as before). `add` replaces a request
with the same identifier, so nothing is removed and no slot moves. That is how reminders filed before
the update gain the *Log a Glass* button, and how a change of language reaches reminders already
filed. The category the button lives in is registered by the app alone, through the scheduler's
`setCategories`, inside the queued operation that reconciles — never by the widget extension: whether
an extension's call reaches the app's set is unconfirmed, and if it does it replaces it (spec §3.5). Nothing new is stored: the words live in the notification
centre's own requests (`docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md` §3.5, §3.7).

**The plan depends on the goal exactly as much as on the water.** `ReminderPlan` silences today
once `currentWater >= dailyGoal`, so raising the goal un-meets a met goal and the rest of today has
to come back; lowering it past the total has to stop the nagging. The hook sits on the `dailyGoal`
*setter* rather than in `saveDailyGoal(ml:)` so it is symmetrical with `remindersEnabled` and so the
setter's equality guard covers the re-plan exactly as it covers the widget doorbell — a no-op goal
write still costs nothing. `raisingTheGoalPastAMetTotalRePlansToday` and
`loweringTheGoalBelowTheTotalSilencesToday` pin both directions; both failed before the call
existed.

**And on the latest drink** (2026-10-06). The plan drops any slot due less than
`ReminderPlan.quietAfterDrink` — one hour — after the latest of today's rows: dropped, never moved,
so the grid holds, and the drink clamped to `now`, because a watch pour carries the watch's own clock.
That input needs no trigger of its own. Only a log mutation can move it, and every one goes
through `saveAndRecompute()` and so `recomputeToday()`, which republishes the rows from the same
fetch before it reschedules.
`currentReminderSlots()` reads it off `todaysLogs` for the app's hook and for `AddWaterIntent` alike,
so the two front doors silence the same slot (`loggingADrinkSilencesTheReminderDueWithinTheHour`).
Its limits — a zone change before the next re-plan, and a cross-process read that misses a row — are
in that method's DocC and in `AI_CONTEXT.md`'s known issues #47–#48. A third, two unordered
reconciles per mutation, was closed on 2026-10-07 (#46, retired): the production hook hands every
reconcile to one `ReconcileQueue`, which runs them one at a time in the order they were asked for, so
the plan from before a drink can no longer finish after the plan from after it.

The production default returns immediately unless `role.mayFileReminders` — that is, in any process
but the phone app. Two independent reasons now sit behind one predicate. For an extension: a
reconcile queued from the hook would not outlive `perform()` returning, so `AddWaterIntent` awaits
the reconcile itself instead. For a watch: `ReminderPlan.Slot.identifier` is a pure function of day and hour, so a
second notification centre would file byte-identical identifiers it cannot dedupe against the
phone's. Full reasoning in rule `80-notifications`, corrected in this same pass to name
`role.mayFileReminders` rather than the `!isAppExtension` it described until 2026-09-01
(`AI_CONTEXT.md`'s retired known issue #15).

## The seventh key, and why it crosses to the widget

`language` is a `String` holding a code, **absent until the user picks one**. That makes it the
third key whose absence carries meaning, alongside `isGoalSet` and `remindersEnabled` — and for the
same reason: "I never chose" and "I chose to follow the device" must not be distinguishable, or a
user who later adds a language to their phone would be stuck on whatever they were pinned to.
Returning to *Follow device* therefore **removes** the key rather than storing a sentinel.

```
flag present  → AppLanguage(code:), falling back to .system for anything unrecognised
flag absent   → .system
```

`AppLanguage` lives in `DataManager.swift` rather than a file of its own, because a seventh shared
`.swift` file would change the six-file contract that `CLAUDE.md` and four rule files spell out.

**The setter rings the widget doorbell**, which `remindersEnabled` does not. The widget has its own
strings table and its own process; a timeline it has already built is an archive another process
replays, so without the doorbell it would keep drawing the previous language indefinitely.
`WaterSnapshot` carries the language for the same reason it carries the goal — the provider reads
the cache and never the model (rule `40-widget`).

### …and why it crosses to the watch

**The setter also publishes to the wrist.** The code travels as `WristMirror.languageCode` —
`resolveLanguage(in:).code`, so `nil` for *Follow device* — and the watch keeps it inside the mirror
it persists under `Key.wristMirror`. No key was added for it, on either device.
`WristModel.language` resolves it through the phone's own `AppLanguage(code:)`:

```
mirror with "en" / "ru" / "uz"   → that language's .lproj in the watch app
mirror with nil (Follow device)  → .system — the WATCH's own Bundle.main
no mirror yet                    → .system
unrecognised code                → .system, announced under #if DEBUG unless empty
```

"Follow device", read on the wrist, means *this* device: the two usually agree, because watchOS
mirrors the iPhone's language by default, but only the watch knows its own. The choice survives a
relaunch because the mirror is persisted, and switches the moment a new mirror arrives — Observation
tracks `language` through `mirror`, and `WristRoot` re-injects the bundle and the locale
(`docs/superpowers/specs/2026-10-06-watch-localization-design.md` §4.1). The complication's
`.description` cannot follow the in-app choice: WidgetKit resolves it before any entry exists, so it
follows the watch's system language, exactly as the phone widget's description and the Shortcuts
vocabulary follow the phone's. *(2026-10-21, 1.3.2's stage 7c, staged: the faces themselves now
follow the in-app choice. Their provider resolves `AppLanguage(code: mirror?.languageCode)` — the
table above, read from the same stored mirror — into each entry, and `WristFaceRoot` injects that
language's bundle and locale from the complication's own `.lproj`; with no mirror, or *Follow
device*, the complication's own `Bundle.main`. Until 7c the circle drew a bare number in no language.
Only the `.description` still follows the watch's system language.)*

### The language is why nothing asks `Bundle.main`

iOS resolves `Bundle.main`'s localisation **once at launch and never again**, so an in-app picker
that only wrote a preference would need a relaunch to take effect. Every user-facing string in this
product instead resolves through `EnvironmentValues.strings`, a `Bundle` injected at each root from
`DataManager.language` — on the watch, from `WristModel.language`. Changing the model invalidates
observers, the roots re-evaluate, a different bundle travels down, and the tree redraws in place.

`.locale` is injected alongside it. Switching the strings without the locale leaves `4 500` wearing
the device's grouping separator inside a Russian sentence — half-translated reads as a bug in the
app rather than as a language it does not have. *Only sites that format against the locale honour
this:* `Text(_:format:)` on the phone, the watch's own readout (`WristVessel.readout`), and — since
the redesign's stage 2 — everything Home draws through `Bundle.figure(_:_:locale:)`, which formats
each volume with the locale and hands it to a `%n$@` key: the vessel's `1 300 of 2 000 ml`, the
status line, the discs' captions, *Undo*; since stage 3, History's header, week card and rows; since
stage 4, Settings' vessel amounts; since stage 5, the welcome's — its vessel amounts, which are
Settings' rows (`VesselSliders`), and the calculator's *Your goal is …* and *Use …*. Since roadmap
item 1.2.6, every other sentence built from a key with an argument goes through
`Bundle.localized(_:_:locale:)`, which formats the resolved key with the same locale — so a `%1$d` is
grouped too, and a counted noun takes the plural form the locale's language gives it: both widgets'
figures (`12 500 мл`, `из 2 000 мл`), the watch's serving rows, and every spoken string
(*2,000 millilitres*). No site builds a sentence with `String(format:)` over a resolved key any more
(rule `50-views`). *(Until 1.2.6 this sentence said both widgets and the watch's rows grouped in no
language at all — known issue #39, closed by it — and that spoken strings kept `%d` on purpose. Until
the thirty-third pass it still listed the week card's `Best 8050 ml`, History's rows and Settings —
History's stale since stage 3.)* *(2026-10-21, 1.3.2's stage 7c, staged: the watch's three faces
join the sites that format against the locale — the percentage through `.number` and `.percent`
under the entry's locale, and the rectangle's `1 240 из 2 000 мл` through
`WristPlan.Face.millilitreLine(in:locale:)`, which is `Bundle.figure(_:_:locale:)`, as the screen's
line under the vessel is.)*

## The day ordinal

```swift
(year * 10_000) + (month * 100) + day        // 2026-08-28 → 20260828
```

Built with `Calendar.waterBuddyDay`: Gregorian, `en_US_POSIX`, `TimeZone.autoupdatingCurrent`,
**rebuilt on every access** so a time-zone change takes effect.

A stored *instant* has to be re-interpreted under whatever zone is current when it is read. A user
who logs water at 14:00 in Paris and lands in London an hour behind would have yesterday's stored
midnight re-read as the day before — wiping a day of water on a date that never changed. Comparing
ordinals still rolls over correctly flying the other way, where the local date genuinely does
advance.

## The rollover

`applyDailyReset(on:)` — **the order is the safety**:

```swift
defaults.set(0, forKey: Key.currentWater)      // zero FIRST
defaults.set(day, forKey: Key.lastActiveDay)   // stamp SECOND
```

A crash between the two leaves a stale marker, which simply resets again on the next launch. The
opposite order launders yesterday's water into today with no way back.

**Since the log became the source of truth, this clears only the cache.** No `WaterLog` row is
touched: yesterday's servings stay on disk as history, and today reads as empty because nothing
has been logged today — not because anything was destroyed. Where a recompute follows the reset,
`recomputeToday()` refills the cache from the logs: in `init`, in `resetDailyProgress()`, and in
the three mutators that open with `refresh()` and end in `saveAndRecompute()` — `addLog` (and so
`addWater`), `removeWater` and `ingest` — when that `refresh()` is what rolled the day, the first
tap after midnight. `refresh()` and `dayDidTurn()` themselves recompute nothing; they only
republish the rows (below).

`resetDailyProgress()` is the only **reset** that deletes rows, and it deletes **today's** only:
yesterday is history and a start-over has no business reaching into it. *(Until the twenty-sixth
pass this called it "the user-facing 'start over'" and "the only path that deletes rows". No screen
calls it — it has no production caller (`AI_CONTEXT.md` known issue #84d) — and three paths delete
rows: this one, `deleteLog(_:)`, which History's swipe and Home's *Undo* reach, and
`removeWater(amount:)`, which also has no caller. Rule `30-rollover`'s wording was the exact one.)*

`resetIfNeeded()`:

| Stored `lastActiveDay` | Behaviour | Returns |
|---|---|---|
| absent | **adopts today** (app only) and does not reset — a fresh install, or a build from before the marker | `false` |
| == today | nothing | `false` |
| != today | `applyDailyReset(on: today)` | `true` |

Called from `init`, from `refresh()`, and — through `dayDidTurn()` — from the
`NSCalendarDayChanged` / `NSSystemTimeZoneDidChange` observers that catch the app sitting open
across midnight or the user crossing a zone. Those observers register with `queue: .main` and use
`MainActor.assumeIsolated` rather than a `Task` — the main queue *is* the main actor, and hopping
would open a window where two notifications interleave.

**`dayDidTurn()` (2026-10-11) is what the observers call**, where they called `resetIfNeeded()`
itself: it runs the reset and, **only when the reset reports a new day**, republishes today's rows
and the history. Until then a screen left open over midnight showed a zeroed total above
yesterday's servings, and Home's date — which is the last day of `history` — would have stayed
yesterday's. It never recomputes the total from the rows. `DayTurnTests` pins the two halves of
the republish — a new day republishes, a turn that is not one republishes nothing; no test there
tells a republish from a recompute, since an empty new day reads zero either way. A zone
change that does not change the day republishes nothing (`docs/AI_CONTEXT.md` known issue #98).

`resetDailyProgress()` is unconditional and leaves `dailyGoal` alone. Its DocC calls it "a
user-facing 'start over' action"; no screen calls it (above, and known issue #84d).

**The widget never resets.** `DataManager.snapshot(defaults:calendar:now:)` applies the same rule
**in the returned value only** and leaves the store exactly as it found it, so a widget rendered at
00:01 cannot race the app into clearing the day. It mirrors the missing-marker case with `if let`,
not `guard let … else { water = 0 }`:

```swift
if let lastActiveDay = defaults.object(forKey: Key.lastActiveDay) as? Int,
   lastActiveDay != dayOrdinal(for: now, in: calendar) {
    water = 0
}
```

## Who may write on behalf of the group

`DataManager.isAppExtension` is `Bundle.main.bundleURL.pathExtension == "appex"` — the only signal
available before any extension point has loaded, and constant for the life of the process, so it
is a `static let`. **It is no longer read at any guard site.** Since 2026-08-31 it feeds
`DataManager.role`, and the guards ask that instead:

```swift
nonisolated static let role: Role = {          // DataManager.swift:2024 (read :1996 until set A's step 5; :1924 until set A's step 4; :1787 until set A's step 2; :1647 until 2026-10-20; :1565, a line of its DocC, until 1.2.5)
    #if os(watchOS)
    return isAppExtension ? .watchExtension : .watchApp
    #else
    return isAppExtension ? .phoneExtension : .phoneApp
    #endif
}()
```

The reason is that `isAppExtension` is a **two-state answer to a four-state question**, and it
answers it wrongly for a watch: a watchOS app is a `.app`, so `pathExtension == "appex"` is `false`
and every `!isAppExtension` guard would *open* on the wrist — materialising the goal into a
container the phone never sees, stamping its own day, seeding a phantom serving, burning the
burn-once migration flag, and filing a duplicate reminder plan. Resolved from `isAppExtension` plus
the compile-time platform rather than from a second runtime probe, because rule `25-shared-storage`
forbids a competing detection scheme: two probes can disagree and leave one guard open.

**Four writes are guarded, by two of the four questions** (line numbers re-derived 2026-10-11 by
`grep` for each guard, twice: stage 3 put 15 lines above six of the seven sites, which moved by
15, and none above the first; and before it the redesign's stage 2 grew the file by 209 lines and
moved all of them, and
the pass that recorded stage 2 left them where `b8a1386` had them. Before that, 2026-10-09: the fix
for #73 moved all six, by four lines or by thirteen; and 2026-10-08: all six had moved since the
2026-09-01 check that followed the watchOS plan's ~500-line addition. *This sentence said "by three
different questions" until the twenty-sixth pass; the four writes have only ever asked two.*):

1. **Materialising `dailyGoal` in `init`** (`:654`, `ownsSharedStorage`) — the write exists *for*
   the extensions; a non-owner doing it to itself puts a key in the group that the migration then
   mistakes for state the app already wrote.
2. **Stamping `lastActiveDay` on a fresh install** (`:1513`, `ownsSharedStorage`) — same reason.
3. **`seedFromCachedTotalIfNeeded`** (`:1434`, `mayHaveLegacyStandardDefaults`).
4. **The migration itself** (`:2168`, `mayHaveLegacyStandardDefaults`).

Six further sites are guarded by the same enum but are not group bookkeeping:
`republishHistory` (`:1106`, `drawsHistory`, cost rather than correctness); `republishStreak`
(`:1167`, `drawsHistory` again — **new with stage 2, the seventh site**, with a guard of its own
because the `dailyGoal` setter calls it outside `republishHistory`); `republishMonth` (`:1201`,
`drawsHistory` a third time — **new with set A's step 2, the eighth site**, with a guard of
its own for the same reason: `showMonth(_:)`, `refresh()`, `saveAndRecompute()`, `dayDidTurn()` and
the `dailyGoal` setter call it outside `republishHistory`); `recap(of:)` (`:1229`, `drawsHistory` a
fourth time — **new with set A's step 5, staged, the tenth site**: a read for the recap's sheet, which
returns a value and publishes nothing, guarded for `republishMonth()`'s reason); `republishInsights`
(`:1287`, `drawsHistory` a fifth time — **new with set A's step 4, the ninth site**, called beside each
`republishMonth()` and from `showInsights(_:)`); and `requestReminderReschedule` (`:1768`,
`mayFileReminders`, the one whose wrong answer is immediately user-visible).
*(Lines re-derived by `grep` for each guard's own words on 2026-10-24, set A's step 5, on its staged tree —
its insertions in `DataManager.swift` begin after line 1191; at `HEAD` `ad244c2` they read `:1485`,
`:1406`, `:2140`, `:1203`, `:1259` and `:1740`; `:654`, `:1106` and `:1167` did not move.)*
*(Lines re-derived by their words on 2026-10-24, set A's step 4, on its working tree — they read `:633`,
`:1416`, `:1337`, `:2068`, `:1085`, `:1146`, `:1182` and `:1668` at `HEAD` `5b511bd`.)* Rule `25-shared-storage`
still counts six (`docs/AI_CONTEXT.md` known issue #103).
*(Lines re-derived by their words on 2026-10-23, the eighty-fifth pass, on step 2's staged tree —
they read `:592`, `:1294`, `:1215`, `:1931`, `:1042`, `:1103` and `:1531`, `HEAD` `2e2f3a7`'s lines,
and the paragraph said three further sites. Before that, re-derived on 2026-10-20, the
seventy-fourth pass, on the staged tree — they
read `:551`, `:1162`, `:1083`, `:1709`, `:969`, `:1000` and `:1329`, several passes old. Since 1.3.1's
6c, `republishHistory`'s guard is `draws || cachingTheWeek`: the week's cache runs in any process
that recomputes today, and only what the app draws stays behind `drawsHistory` — no new role
question, spec §3.4 W7.)*

Only `.phoneApp` answers `true` to any of the four questions today. Each is an exhaustive `switch`
with **no `default`**, so a fifth binary fails to compile until somebody answers all four for it.
Pinned by `ProcessRoleTests` (`WaterSnapshotTests.swift:519`).

## What Apple is told about all of this

Added 2026-09-02. **No key changed** — this section documents a *declaration* about the keys, not a
change to them, and it is here because anyone adding a key needs to know the declaration exists.

`UserDefaults` is one of Apple's **required-reason APIs**. Since 1 May 2024, an upload that uses one
without declaring it in a privacy manifest is *not accepted by App Store Connect* — a rejection, not
a warning. Every store on this page is reached through `DataManager.sharedDefaults`, so the whole
product depends on that declaration being right.

Four byte-identical `PrivacyInfo.xcprivacy` files carry it, one per shipping bundle — `WaterBuddy/`,
`WaterBuddyWidget/`, `WaterBuddyWatch/`, `WaterBuddyWatchWidget/`. All four are needed because all
four compile `DataManager.swift` and therefore all four touch `UserDefaults`; declaring only the two
iOS bundles would still be rejected. Each target's `PBXFileSystemSynchronizedRootGroup` grants
membership, so **no `project.pbxproj` edit was required** — verified by finding all four in the built
bundles and in the Release archive.

Two reason codes, and they map onto the two-store split this document opens with:

| Code | Apple's meaning | This app |
|---|---|---|
| `1C8F.1` | access confined to the App Group shared by the app and its extensions | `sharedDefaults` resolving `group.sardor.WaterBuddy` — the derived cache every target reads |
| `CA92.1` | access confined to the app itself | the `.standard` fallback when the container is unreachable, and `migrateIfNeeded(from:into:)` below |

`NSPrivacyTracking` is `false` with `NSPrivacyTrackingDomains` and `NSPrivacyCollectedDataTypes` both
empty. That is true by construction rather than by assertion: no account, no server, no analytics,
and no networking import anywhere in the tree (rule `70-privacy`, rule `95-dependencies`).

**If a key is added, ask whether it brings a new required-reason category with it.** The likely ones
are file timestamp, disk space, system boot time and active keyboard — none of which this product
touches today. A new category means editing all four manifests together, exactly as a new key means
touching both this file's count and `CLAUDE.md`'s.

*(2026-10-16, the thirty-eighth pass: asked for `reviewRequestedVersion`, the key roadmap item 1.2.5
added — it brings none. It is `UserDefaults` in the App Group, the use `1C8F.1` already declares, and
StoreKit's review request, the one other thing 1.2.5 brought, is not a required-reason API. The four
manifests are unchanged, and no networking framework is imported.)*

*(2026-10-21, roadmap item 1.4.1, staged: Premium's purchases add no key and no required-reason API —
StoreKit's product, transaction and purchase calls are none of Apple's listed categories, and the
paid state is not written to `UserDefaults`. The four manifests are unchanged. The App Privacy answers
stay *Data Not Collected*: Apple takes the payment, and nothing about a purchase reaches the owner
(spec §7.4, known issue #155).)*

Separately and unrelated to privacy: `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` on the app
target's two configurations only. Extensions and the watch app inherit the containing app's answer;
duplicating it is wrong. Without it every upload stalls on a manual export-compliance questionnaire.

## The one-shot migration

`migrateIfNeeded(from:into:)` carries state written before the App Groups capability existed into
the shared suite, once. Without it, enabling the capability looks like data loss.

```swift
guard role.mayHaveLegacyStandardDefaults else { return }
guard !suite.bool(forKey: Key.didMigrateFromStandard) else { return }
defer { suite.set(true, forKey: Key.didMigrateFromStandard) }

for key in [Key.currentWater, Key.dailyGoal, Key.lastActiveDay, Key.isGoalSet] {
    guard suite.object(forKey: key) == nil, let value = source.object(forKey: key) else { continue }
    suite.set(value, forKey: key)
}
```

Three properties are not negotiable:

- **Extensions return immediately.** An extension's `UserDefaults.standard` is its own bundle's
  domain, which has never held this app's state — a widget that resolved the suite first would
  copy nothing while still burning the one-shot flag.
- **The decision is per key, not per suite.** A widget tap that landed before the app was first
  opened after the update writes `currentWater` and nothing else; probing one key to decide about
  all of them would strand every other value or overwrite that tap.
- **It never clobbers** — `guard suite.object(forKey: key) == nil` before every copy.

`source` is a parameter only so the one-shot can be tested: it runs inside a lazy global that
resolves the real App Group, which a test cannot stand in front of.

It is driven from `WaterBuddyApp.init()` via `prepareSharedStorage()`. Every step happens anyway,
lazily, on first touch of `sharedDefaults`; calling it deliberately fixes **when** — which for a
one-shot only the app may run is the whole point.

## Derived values, computed identically in two places

`progress` and `progressUnclamped` exist on **both** `DataManager` and `WaterSnapshot`, computed
the same way, because the app and the widget must round to the same number. **`percentage` does
not live on `DataManager`:** the snapshot has one, and the app's is `HomeView.percentage`, a private
property of the view that spells the same expression — two copies kept equal by reading
(`AI_CONTEXT.md` known issue #20, and rule `50-views`). *(This sentence put all three on both
types until the twenty-sixth pass.)*

```
progress          = clamp(progressUnclamped, 0...1)
progressUnclamped = goal > 0 ? Double(currentWater) / Double(goal) : 0
percentage        = Int((progressUnclamped * 100).rounded())
```

A `body` that computes a displayed figure for itself is how the two start disagreeing.

## Derived on read, and a streak that is published and not stored

Added by the redesign's stage 2 (2026-10-11) for Home. **None of it is a key, and none of it
crosses a process or the wire.**

| Member | What it is | Where it comes from |
|---|---|---|
| `addLog(amount:at:) -> UUID?` | the id of the row it inserted, `nil` for a refused amount | `@discardableResult`; Home's *Undo* is the one caller that keeps it |
| `undoLog(id:)` | deletes that row through `deleteLog(_:)` | the row is looked up among **today's, read fresh** — after midnight it is yesterday's and stays; a failed read is not "no such row" and nothing is done |
| `remaining` | `max(0, dailyGoal - currentWater)` | computed on read |
| `hasReachedGoal` | `currentWater >= dailyGoal` | computed on read |
| `lastDrink` | today's latest `timestamp`, never later than `now()` | `todaysLogs`; a watch pour stamped ahead of the phone's clock is clamped, as `ReminderPlan` clamps it |
| `nextReminder` | the first slot of today's plan, or `nil` | `ReminderPlan.slots(… horizonDays: 0)` over the same inputs `currentReminderSlots()` files — one definition, so the line on Home and the notifications filed cannot disagree. It is the planned time, not a promise of delivery, and not a check of the system's permission |
| `streak` | days in a row the goal was reached | published, get-only, see below |

**`streak` is observed state with no key.** `republishStreak()` runs first in `republishHistory()`
and at the end of the `dailyGoal` setter, behind `role.drawsHistory` — so only the phone app
computes one — with an equality guard. `readStreak()` is the run of days before today plus today,
once today has reached the goal, read from today's rows alone. The run of days before today is
counted by `readClosedRun(at:)` — a window of 30 days ending today, and while the run fills the whole
window a wider one: 120, 480, then 1,920 (`streakWindows`) — and **kept in memory**, `closedRun`,
keyed by today's ordinal, the goal and the calendar's zone. Not a key and not stored: it is forgotten
wherever the app changes a day other than today — `addLog(amount:at:)` with a date on another day,
`deleteLog(_:)` of another day's serving, `updateLog(_:newAmount:timestamp:)` when the serving was or
becomes another day's, `ingest(_:)` folding a pour onto another day — and on every `dayDidTurn()`, and
a new day, goal or zone finds its key stale. So a pour, an *Undo* and a tab's `refresh()` no longer
read the past; with it, a whole pour cost 6 ms at 45 days of history and 75 ms at 500 (2026-10-18,
spec `2026-10-18-the-streaks-cost-design.md`). `StreakRecountTests` pins that a pour and a refresh
read no further back, and that the add, the delete, the move into today, a watch pour, the day's turn
and midnight recount; the goal is pinned by `changingTheGoalReJudgesTheStreak`; a change of zone and a
serving moved off today are not tested (`docs/AI_CONTEXT.md` #143). It returns `nil` if any read fails, and a `nil` publishes nothing: **a failed read
leaves the streak as it stands, never zero** (the same ruling as the total's). Every day is judged against **the goal as
it is now**; today counts once it reaches the goal and does not break the run before it does. The
arithmetic is `DaySummary.streak(of:goal:)`, pure. `theStreakStaysOutOfTheSnapshotAndTheWristMirror`
pins that it reaches neither `WaterSnapshot` nor `WristMirror`. That no notification carries it is
true by reading — the reminder copy takes no value at all (rule `80-notifications`) — and is not
what that test asserts.

*(2026-10-21, roadmap item 1.4.1, staged, half built.)* **Premium's paid state is published and not
stored either — by decision D4 of `docs/superpowers/specs/2026-10-21-premium-foundation-design.md`.**
`PremiumStore` (app-only, not `DataManager`) reads `Transaction.currentEntitlements` when it is built,
whenever the app comes forward and after every transaction update, and keeps
`PremiumAccess.resolve`'s answer — `.free`, `.yearly(until:)` or `.lifetime` — in memory. No key on
`DataManager.Key`, no App Group write, no `UserDefaults` read: StoreKit keeps purchases on the device
and answers offline, and a cached flag could still say Premium after a refund. Until the first read
the state is `.checking`, and nothing Premium draws. The widget and the watch do not learn it; a
later item that needs them to writes a *derived* key through `DataManager`, and this sheet gains its
row then.

*(2026-10-21, evening, 1.4.1's Task 6, staged.)* The read now happens where the paragraph above says:
`WaterBuddyApp.init()` builds the store right after `prepareSharedStorage()` — before the DEBUG fresh
start returns, so a UI test's run has one too — and reads it again on every `.active`. Still no key.
**Specified for set A's step 1 and not on disk** (`docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`):
a third product, the monthly plan, and the owner's grace ruling — `PremiumAccess.resolve` will take
StoreKit's current entitlements as the answer to whether a subscription is held, with no clock of its
own (`docs/AI_CONTEXT.md` #161). Neither adds a key.

*(2026-10-22, set A's step 1, Tasks 3–7, staged.)* Both are on disk now. The answer in memory is one of
`.free`, `.monthly(until:)`, `.yearly(until:)` or `.lifetime`, and `PremiumStore` also keeps
`holdsSubscription` — whether a subscription stands beside whatever `resolve` answers, for *Manage
Subscription* — and `restoring`; all three published, none stored. `resolve(_:)` takes no clock: a
subscription is held for as long as StoreKit lists it, so one in its billing grace period stays
Premium, and the status line names the plan alone once its date has passed. A read that a newer read
overtook publishes nothing. Still no key on `DataManager.Key`, no App Group write and no `UserDefaults`
read; `PremiumSet.understand` and its `isOnSale` are compiled constants, not stored state.

## Tests that pin this

**Roadmap item 1.2.5 adds two suites, 12 `@Test`** (counted per suite by the attribute grep on
2026-10-15), in `ReviewRequestTests.swift`: `ReviewRequestTests` (8) — the decision (a streak of 2
refused and 3 asked, a run ending yesterday refused, a version asked in refused and a new one asked,
an empty version refused) and the claim (it records before answering and answers once per version;
a refusal writes nothing, on the second goal day and with today short; a stored number reads as
never asked) — and `ReviewPromptTests` (4), which pin no stored state: DEBUG asks only with its
launch argument, the gate's own run is not launched to ask, the pause outlasts the confetti, the
version is the bundle's. `everyKeyTheProductWritesIsOnTheRoster` drives the claim and requires
`reviewRequestedVersion` among the keys it reads back. Not pinned: that the claim rings no doorbell
and reschedules nothing (the final review's Minor 6, deferred).

**Stage 5 adds three suites that pin stored state, 15 `@Test`** (counted per suite by the attribute
grep on 2026-10-14, the fifty-ninth pass of `docs/AI_CONTEXT.md`), all in `WelcomeTests.swift`:
`ReminderPermissionTests` (7) — what reaches `remindersEnabled` from iOS's answer, asked or re-read;
`WelcomeFinishTests` (6) — vessels left as they were store nothing, vessels set are stored,
finishing saves the goal and closes the welcome, reminders are asked for before it closes, a
refusal still opens the app with reminders off, and *Not now* asks nothing (that the vessels are
stored before the goal is the code's order, `WelcomeView.finish`, and no test pins it); and
`FreshStartTests` (2, DEBUG only) — the fresh start's fixed-name suite, cleared at each launch, and
nothing without the argument. The stage's other three new suites, `WelcomeStepTests`,
`GoalSuggestionTests` and `WelcomeStringTests`, pin no stored state. `DailyGoalSetupTests` now reads the goal's menu from
`WelcomeView`. The paragraphs below are older and were not recounted for it.

**Stage 2 adds five suites and 43 `@Test` to the ones counted below** (counted per suite by script
on 2026-10-11): `UndoTests` (7), `HomeFiguresTests` (14) and `DayTurnTests` (3) in
`HomeModelTests.swift`; `StreakCountTests` (11, pure) and `StreakPublishingTests` (8) in
`StreakTests.swift`. The two that need a read to fail use `UnreadableStore`, a file-backed store
whose servings' table is renamed away through a second connection — it fails every time, where
overwriting the file under an open context is a race (`docs/AI_CONTEXT.md` known issue #92). The
paragraph below is the twenty-fourth pass's and was not recounted then.

**Recounted per suite by script on 2026-10-12, the thirtieth pass: it had been one short since
stage 3.** Stage 3 gave `HistoryServingTests` a sixth test,
`theSliderBoundsContainEveryVesselShortcut` — the paragraph said 5, and 203 — and the
twenty-ninth pass did not recount. The other sixteen figures stand, stage 2's five above with
them, and stage 3b changes none of the twenty-two. **Neither count includes stage 3's two
suites on the model's derived answers**, `DaysMetTests` (8) and `DayFractionTests` (9) in
`HistoryRangeTests.swift`, which pin `reached(_:)` and `daysMet(in:goal:)`, and `dayFraction`
and `hours` (*The week's summaries*, above).

Seventeen suites, 204 `@Test` in total. `DataManagerTests`, `DailyGoalSetupTests` and
`ReminderSeamTests` (72 between them) cover the write path, the rollover, observation, the goal and
the reminder seam; `WaterSnapshotTests` (28) covers the read path, the day boundary and the
migration; `WaterLogStoreTests` (23) covers the log CRUD, the published rows and the seed migration;
`ReminderPlanTests` (22) pins *when* to remind, the quiet hour after a drink included, and
`NotificationManagerTests` (10) pins what happens to the plan, and `ReconcileQueueTests` (3) the
order plans are applied in; `HomeServingTests` (7) pins the quick-add row, `AppTabTests` (6) the tab
menu, and `HistoryServingTests` (6) the serving editor's offered range and its own fixture's
reminder seam. `HistoryLogsTests` (3), `RetimingTests` (10), `HistoryWindowStartTests` (2),
`CorrectionRangeTests` (5) and `RetimedPourTests` (2) pin the window's published rows, re-timing a
serving, where the window starts, what the History sheet offers and where it opens, and a re-timed
watch pour; `HistorySelectionTests` (5) the screen's day selection. *(Counted per suite by line range
on 2026-10-06. Until then this read 151 — its own figures summed to 152 — while the tree held 160.
2026-10-07: +3, the new `ReconcileQueueTests`; then +27, the six suites of the earlier-servings
change, re-counted per suite — the first eleven still sum to 172. 2026-10-08: +4, `ReminderSeamTests`'
four for the re-read of the reminders flag; re-counted per suite on 2026-10-09 — 32 + 21 + 19, and the
first eleven now sum to 176.)*

Named cases worth knowing: `travellingWestwardDoesNotWipeTheDay`,
`travellingEastwardAcrossTheDateStartsANewDay`, `theDayBoundaryHoldsAcrossADstTransition`,
`aMissingDayMarkerReportsTheStoredTotal`, `readingLeavesTheStoreUntouched`,
`readingAnEmptySuiteDoesNotCreateKeys`, `migrationFillsTheGapsAroundAValueAlreadyInTheGroup`,
`savingAGoalRingsTheWidgetDoorbellExactlyOnce`, and — for the two rulings above —
`editingAnInferredGoalDownToTheDefaultPersistsTheFlag`,
`raisingTheGoalPastAMetTotalRePlansToday`, `loweringTheGoalBelowTheTotalSilencesToday`.

No unit test's own code ever reads or writes a key in `group.sardor.WaterBuddy` or
`UserDefaults.standard` — every suite that needs a store builds a UUID-named throwaway one and
removes it (the fixtures do call `UserDefaults.standard.removeSuite(named:)` to detach that suite,
which touches no key; sixteen test files need no suite and build none — "eight" until this was
re-counted for stage 5, 2026-10-14, when it was already fifteen). The one exception since stage 5
is `FreshStartTests`, which clears the DEBUG fresh start's fixed-name suite,
`uitest.waterbuddy.freshstart`, because that name is what it tests. **The process the tests run
in is another matter.** The unit target is hosted in the app (`TEST_HOST` is `WaterBuddy.app`), so
before any test runs the host's own launch has called `prepareSharedStorage()` and built
`DataManager.shared` against the group container of the simulator it runs in — as a launch of the
app does. The UI suites launch that same real app, with no store override — except
`WelcomeUITests`, which since stage 5 launches it with `-WaterBuddyFreshStart` *(2026-10-18: and,
since roadmap item 1.2.8, the store capture, `AppStoreScreenshotUITests.testCaptureAppStoreScreenshots`
— rule `85-testing` names both)*: in a DEBUG build the
app then runs on that throwaway suite, cleared at launch, and an in-memory store. The launch's own
`prepareSharedStorage()` still runs first, against the simulator's group container, as on every
launch — the app's bookkeeping on its own group, as `WaterBuddyApp.init()`'s comment says, not
test data — and the manager built on the throwaway suite has its widget doorbell, reminder
reschedule and wrist publish turned off, as a test fixture's are. (The app's return-to-foreground
re-read still asks the real notification centre for its authorization status; it files and removes
nothing.) No test constructs a real `UNUserNotificationCenter`
either: `ReminderScheduler` is a struct of closures precisely so one can be stood behind.

**That second sentence was aspirational until 2026-08-31, and is now true.** `DataManager.init`
ends in `rescheduleRemindersNow()`, and the `rescheduleReminders:` parameter above defaults to
`DataManager.requestReminderReschedule`, which builds a real centre — so *merely constructing* a
manager reconciles against it. Six fixtures omitted the argument and had been doing exactly that
(`docs/AI_CONTEXT.md` known issue #6, now retired). All eleven construction sites in the test target
were audited; the six were closed, and the two files that held them each carry a test that fails if
the argument goes missing again. The same defect was live in three `#Preview`s as well — known
issue #14, **fixed since**: each of the app's five sites that build a `DataManager` for a preview —
one per file, feeding six `#Preview`s, since `HistoryView`'s two share a factory — now
passes `rescheduleReminders: { _ in }` (`HomeView`, `GoalSetupView`, `HistoryView`, `RootTabView`,
`SettingsView`; checked by `grep` in the twenty-sixth pass, which found this sentence still calling
it live). *(2026-10-14, stage 5: `GoalSetupView` is gone; `WelcomeView`'s preview takes its place
and passes it too.)*
