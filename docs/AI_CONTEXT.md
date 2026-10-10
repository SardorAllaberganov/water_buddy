# AI_CONTEXT — WaterBuddy

Orientation for anyone (human or model) picking this repo up cold.
Authority order is unchanged: **DocC on the type you are changing** → `.claude/rules/` →
`CLAUDE.md` → this file. This document records *where the work stands*, never what the rules say.

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
| SwiftData — `WaterBuddy.store` | every ``WaterLog`` (`id`, `amount`, `timestamp`) — the **source of truth** | the app only |
| `UserDefaults` — nine keys | today's total, goal, day ordinal, three flags, the chosen language, the three quick-add amounts, and the phone's applied-pours ledger — a **derived cache** | the app *and* the widget |

Today's total is not stored; it is the sum of today's logs, recomputed after every mutation and
written through to the cache. **The widget never opens SwiftData.** A `TimelineProvider` carries no
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
same snapshot; the Glass's index is named once, `DataManager.usualSlot`, for its amount and its glyph.

## Targets

| Target | Bundle id | Sources | Status |
|---|---|---|---|
| `WaterBuddy` | `sardor.WaterBuddy` | `WaterBuddy/` | **LIVE** — SwiftUI, `@Observable` `DataManager` over SwiftData |
| `WaterBuddyWidgetExtension` | `sardor.WaterBuddy.WaterBuddyWidget` | `WaterBuddyWidget/` **+ 6 shared files** | **LIVE** — two `StaticConfiguration`s over one provider: the Home Screen widget (small, medium) and the Lock Screen widget (circle, rectangle, line); interactive `AddWaterIntent`; and, from iOS 18 behind the codebase's first `if #available`, the Control Center control `LogWaterControl` |
| `WaterBuddyTests` | `sardor.WaterBuddyTests` | `WaterBuddyTests/` | **LIVE** — swift-testing, 387 `@Test` functions in 48 suites, all run on 2026-10-10 (`LiquidGlassRoutingTests` and `PrimarySurfaceTests` are the redesign's, staged) |
| `WaterBuddyUITests` | `sardor.WaterBuddyUITests` | `WaterBuddyUITests/` | **LIVE** — `GoalSetupUITests` (9 real tests; the ninth, staged, taps a serving row on its bare glass), the Xcode template's 3, and `AppStoreScreenshotUITests`' 2 capture harnesses. **14 declared, 27 executed** — the 2 harnesses are skipped by the gate, and `testLaunch` runs once per launch configuration |
| `WaterBuddyWatch` | `sardor.WaterBuddy.watchkitapp` | `WaterBuddyWatch/` **+ 6 shared files** | **LIVE** — SwiftUI, `@Observable` `WristModel` over its own local App Group suite; no SwiftData |
| `WaterBuddyWatchWidget` | `sardor.WaterBuddy.watchkitapp.WaterBuddyWatchWidget` | `WaterBuddyWatchWidget/` **+ 6 shared files** | **LIVE** — `.accessoryCircular` percentage ring, reads the watch's own suite directly |
| `WaterBuddyWatchTests` | `sardor.WaterBuddyWatchTests` | `WaterBuddyWatchTests/` | **LIVE** — swift-testing, 57 `@Test` functions in 6 suites |

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

They live in `WaterBuddy/` and compile into **both** targets. Everything else under `WaterBuddy/`
— `RootTabView.swift`, `HomeView.swift`, `WaterBuddyApp.swift`, `GoalSetupView.swift`,
`HistoryView.swift`, `SettingsView.swift`, `AuroraBackground.swift`, `PressStyle.swift` — is
app-only. Editing one of the
six edits two processes; adding a seventh means editing that list.

## Files on disk

```
WaterBuddy/AuroraBackground.swift                156   app only — the moving backdrop all four screens share
WaterBuddy/Celebration.swift                     213   app only — ConfettiPiece, the seeded burst, the overlay
WaterBuddy/DataManager.swift                    2583   shared — the model, the log CRUD (updateLog takes a time), the window's published rows (historyLogs) and where the window starts (historyWindowStart), the cache, WaterSnapshot, DaySummary, AppLanguage, the four-state Role, usualServing(in:) (the Glass — the widget's, Siri's and the control's one definition) at usualSlot (its index, named once), requestWidgetReload() (timelines and, on iOS 18, controls), remindersSettled() (not on watchOS), the Wrist wire structs and WristMirror.isNews(since:), WristLink (behind #if canImport(WatchConnectivity)) — its push to the face and waitUntilActivated() on iOS, its wait for delivery on watchOS, poll on both
WaterBuddy/GoalSetupView.swift                   273   app only — first-run goal setup; Get Started on the primary surface, range labels at white 0.75 (staged 2026-10-10)
WaterBuddy/Haptics.swift                          53   app only — the three-rung feedback ladder
WaterBuddy/HistoryView.swift                     959   app only — (staged 2026-10-10: Save on the primary surface; the shown day reads LiquidGlass.Selection; the goal line at white 0.55) the week card that picks the day, that day's log, swipe-to-delete, the + and one add/edit sheet with a day · hour · minute wheel
WaterBuddy/HomeView.swift                        379   app only — the vessel, the editable quick-add row, the goal burst (vesselSlots moved out, Task 14)
WaterBuddy/LiquidGlassModifier.swift             768   shared — design tokens + the glass modifier; staged 2026-10-10: the routing (rendering, systemGlassAvailable, systemVariant), Apple's glass on iOS 26+ behind #if os(iOS) + #available, darkened by systemTintOpacity(for:) (0.52 regular, 0 clear) and given its hit region by .contentShape(shape), LiquidGlass.Primary and primarySurface(in:ring:), LiquidGlass.Selection
WaterBuddy/LogServingIntent.swift                 78   app only — the Siri phrase's intent ("Log a Glass"): wait for the watch link, logTheGlass, wait for the reminder queue, reply "Water logged."
WaterBuddy/NotificationManager.swift             283   shared — ReminderScheduler + reconcile, the only UN caller; ReconcileQueue, which runs the app's reconciles one at a time in call order (known issue #46), and settled(), which waits for it to drain
WaterBuddy/PressStyle.swift                       32   app only — the shared press recoil
WaterBuddy/ReminderPlan.swift                    149   shared — WHEN to remind, as a pure value
WaterBuddy/RootTabView.swift                     274   app only — AppTab (3 cases), the container, the glass tab bar with a lozenge behind the selected tab (staged 2026-10-09) (the 420pt cap's comment rewritten 2026-09-02: it justified itself in iPad measurements, and iPad is gone — the cap is kept, because 420 is below the widest iPhone's content width)
WaterBuddy/SettingsView.swift                    660   app only — the goal editor (range labels at white 0.75, staged 2026-10-10), the vessel editor, reminders, the language picker
WaterBuddy/WaterBuddyApp.swift                   108   app only — RootView, the setup gate, the strings/locale injection, WristInbox.shared + WristLink.live.activate() at launch
WaterBuddy/WaterBuddyShortcuts.swift              38   app only — the one AppShortcutsProvider: three phrases (en + ru, AppShortcuts.xcstrings), the "Log a Glass" tile
WaterBuddy/WaterLog.swift                         57   shared — the SwiftData @Model, source of truth
WaterBuddy/WaterSurface.swift                    194   shared — waves, scrim, Aurora palette, vesselSlots (moved in from HomeView, Task 14 — a second, non-view consumer: WristView)
WaterBuddy/WristInbox.swift                       90   app only, NOT shared — reassembles chunked WristBatch payloads (wrist → phone), calls DataManager.ingest(_:)
WaterBuddy/WristPlan.swift                        80   shared (in both watch exception sets, not the phone widget's) — ReminderPlan's pure twin: buckets the outbox by the watch's day, counts the phone's total until the phone's day ends, names the complication's turnover instants (spec §17)
WaterBuddyTests/AppLanguageTests.swift           112   AppLanguageTests — the menu and each bundle
WaterBuddyTests/AuroraBackgroundTests.swift       98   AuroraLightTests — the backdrop's lights
WaterBuddyTests/CelebrationTests.swift           108   HapticLadderTests + ConfettiTests
WaterBuddyTests/DataManagerTests.swift          1331   DataManagerTests + DailyGoalSetupTests + ReminderSeamTests + WristPublishSeamTests + LanguageSeamTests
WaterBuddyTests/EarlierServingTests.swift        429   HistoryLogsTests + RetimingTests + HistoryWindowStartTests (not @MainActor) + CorrectionRangeTests + RetimedPourTests + HistorySelectionTests (not @MainActor) — the window's published rows, re-timing a serving, where the week starts, what the sheet offers and where it opens, a watch pour re-timed, the screen's day selection
WaterBuddyTests/HistoryRangeTests.swift          439   DaySummaryTests (pure, not @MainActor) + HistoryWindowTests
WaterBuddyTests/HistoryViewTests.swift           132   HistoryServingTests — the editor's offered range, and the fixture's own tripwire
WaterBuddyTests/HomeViewTests.swift              180   HomeServingTests — the quick-add row's offered vessels
WaterBuddyTests/LiquidGlassTests.swift           247   LiquidGlassInteractionTests + LiquidGlassBaseTests — the press response; staged 2026-10-10: LiquidGlassRoutingTests (which pane, which of Apple's variants, the availability flag, only the regular variant darkened, and no lighter than the lightest rung that passed) + PrimarySurfaceTests (the derived contrast); none @MainActor
WaterBuddyTests/LocalizationTests.swift          481   the four bundles' string tables, en/ru/uz — the phone's two and, through the built phone app's Watch/ folder, the watch's two; the Shortcuts vocabulary test also pins the control's two strings
WaterBuddyTests/NotificationManagerTests.swift   352   NotificationManagerTests — applying a plan, against a spy scheduler — + ReconcileQueueTests (not @MainActor), against SharedCentre, a lock-guarded stand-in two reconciles can reach at once
WaterBuddyTests/ReminderPlanTests.swift          251   the plan — pure, and no UserNotifications import
WaterBuddyTests/RootTabViewTests.swift            70   AppTabTests — the tab bar's offered destinations
WaterBuddyTests/ServingSeamTests.swift           297   ServingResolutionTests (pure, not @MainActor; usualSlot is the Glass, and usualServing reads it) + ServingSeamTests
WaterBuddyTests/SiriPhraseTests.swift            277   UsualServingTests + ReconcileQueueSettledTests (both not @MainActor) + LogServingIntentTests + LogTheGlassTests + AppShortcutPhraseTests
WaterBuddyTests/WaterLogTests.swift              504   WaterLogStoreTests — one makeManager factory is the file's only DataManager( site
WaterBuddyTests/WaterSnapshotTests.swift         565   WaterSnapshotTests + WidgetLanguageTests + ProcessRoleTests
WaterBuddyTests/WristSyncTests.swift             889   WristWireTests + WristIngestTests + WristPlanTests + WristInboxReassemblyTests + WristPublishTests + WristMirrorNewsTests (not @MainActor) + WristLinkDecodingTests + WristLinkChunkingTests + WristLinkReachabilityTests
WaterBuddyUITests/AppStoreScreenshotUITests.swift  541   NOT a test — the App Store capture harness. Two methods, both deliberately non-idempotent and both SKIPPED by the gate (`-skip-testing:`): the 4-shot store set (run 2026-10-09, after its stale *Last 7 days* query was fixed — unstaged) and the 25-shot full census (same fix, not run)
WaterBuddyUITests/GoalSetupUITests.swift         353   setup, the a11y tree, the tab swap, the Settings tab, the week card (one summary, one button per day), a serving added to yesterday, a serving row tapped on its bare glass (staged 2026-10-10)
WaterBuddyUITests/WaterBuddyUITests.swift         41   template
WaterBuddyUITests/WaterBuddyUITestsLaunchTests.swift   33   template
WaterBuddyWidget/AddWaterIntent.swift            148   writes: runs DataManager in the extension — for both widgets' + and the Control Center control; authenticationPolicy written out, .alwaysAllowed
WaterBuddyWidget/LockScreenWidget.swift          344   the Lock Screen widget (kind "WaterBuddyLockScreen"): circle, rectangle with the + (AddWaterIntent(amount: entry.snapshot.serving)), line — over the same HydrationProvider; every figure privacySensitive, a quiet form under .privacy; strings read only in child views
WaterBuddyWidget/LogWaterControl.swift            83   the Control Center control (kind "WaterBuddyLogWater", iOS 18): ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving)), titled Log Water in the snapshot's language, the glyph at DataManager.usualSlot, no figure; LogWaterControlProvider reads DataManager.snapshot(now:)
WaterBuddyWidget/WaterBuddyWidget.swift          615   reads the cache only, never SwiftData — the Home Screen widget; HydrationView reads no string itself, MediumColumn does; PourButton internal (its minimumTarget is the Lock Screen button's too)
WaterBuddyWidget/WaterBuddyWidgetBundle.swift     23   two widgets, WaterBuddyWidget and LockScreenWidget, and inside if #available(iOS 18.0, *) the control, LogWaterControl
WaterBuddyWatch/WaterBuddyWatchApp.swift          77   watch app only — activates WristLink.live, .backgroundTask(.watchConnectivity) (which now awaits WristLink.waitForPendingDelivery() rather than returning at once), and WristRoot: \.strings + \.locale from WristModel.language, above WristView
WaterBuddyWatch/WristAurora.swift                 48   watch app only — WidgetAurora's proportional-geometry shape, mirrored for the watch canvas
WaterBuddyWatch/WristModel.swift                 305   watch app only, NOT shared — @Observable @MainActor, the watch's only writer to its own local suite; language, the phone's in-app choice read off the mirror; reloads the complication on every pour and every mirror that is news, and never takes a mirror older than the one held
WaterBuddyWatch/WristVessel.swift                145   watch app only — the one vessel, WaterSurface + WaterReadabilityScrim + readout; scrimIntensity(at:) is its own scrim ramp, none at 0% and full by 20% (known issue #35), never the widget's; readout(volume:goal:strings:locale:) groups per language; NOT self-describing to VoiceOver since it became a Button's label
WaterBuddyWatch/WristView.swift                  468   watch app only — the one screen: the vessel IS the pour button, one "More" button over a sheet, "Synced Nm ago"; every string through \.strings
WaterBuddyWatchTests/WristLinkCompileTests.swift  21   compile-time canary — WristLink stays non-@MainActor and Sendable
WaterBuddyWatchTests/WristLinkDeliveryTests.swift 56   WristLinkDeliveryTests (not @MainActor) — how long a background wake is held open: WristLink.poll stops when delivery is done, gives up after its last check, ends when cancelled
WaterBuddyWatchTests/WristModelTests.swift       443   WristModelTests — pour, apply, isMirrorStale, todaysTotal, reconstruction, the phone's day end through the model, the language the watch draws in, when the face reloads, and which mirror wins
WaterBuddyWatchTests/WristPlanCompileTests.swift  20   compile-time canary — WristPlan stays free of actor isolation
WaterBuddyWatchTests/WristVesselLayoutTests.swift 49   diameter(fitting:within:) against five real watch width/height pairs
WaterBuddyWatchTests/WristViewLogicTests.swift   323   the pure logic WristView composes — servings resolution, which one the vessel pours, what the menu gets, attribution in en/ru/uz, serving names, the grouped readout, and the vessel's scrim ramp (full before water can reach the millilitre line, on every diameter)
WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift 95   .accessoryCircular percentage ring — reads Key.wristMirror + Key.wristOutbox directly, never WristModel.shared; WristPlan's arithmetic; entries at the phone's day end and the watch's midnight, policy .atEnd (no longer a 15-minute timer); its description is the phone's own "Today's hydration"
WaterBuddyWatchWidget/WaterBuddyWatchWidgetBundle.swift 9
```

**60 `.swift` files across the seven target folders**, all listed above. Re-derived 2026-10-09 in
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
into anything (rule `15-project`). It is **not** part of the 60 above (read "53" until the
thirty-eighth pass), which is why earlier passes' "every file is documented" claim was true while
omitting it:

```
Tools/GenerateAppIcon.swift                      267   generates the three iOS icon variants at 1024². Run: swift Tools/GenerateAppIcon.swift. Does NOT own the watch icon — see known issue #34
Tools/FlattenPNG.swift                            99   re-encodes a PNG to colour type 2, RGB untouched. Required for every watch capture: simctl writes RGBA on watchOS even with --mask=ignored
Tools/ComposeStoreScreenshot.swift               161   composites an unaltered iPhone screen onto the product's own aurora at a target slot size — how the iPad 13" set was made (see below)
Tools/CaptureScreenshots.sh                        —   the iPhone App Store set. WATERBUDDY_SCREENSHOT_SLOT picks iPhone-6.9 (default) or iPhone-6.5. Its default device is gone — known issue #45. It no longer overrides the status bar's clock (2026-10-09, unstaged)
Tools/CaptureFullCensus.sh                         —   the 25-shot coverage run, every screen/state/scroll position. Its default device is gone — #45
Tools/CaptureWatchScreenshot.sh                    —   the watch capture. WATERBUDDY_SCREENSHOT_NOWAIT=1 shoots the empty state unattended. Its default device is gone, and it repeats two claims since found false — #45
Tools/VerifyScreenshots.sh                         —   proves each capture's size/alpha/format against the slot it will be uploaded to
Tools/RenameScreenshots.py                         —   xcresult attachment UUIDs → slot names, via manifest.json
```

None of these carries the executable bit: `Bash(chmod:*)` is on this project's permission deny list,
so they are invoked as `bash Tools/<name>.sh` and `swift Tools/<name>.swift`.

### Shipped, but not Swift

```
WaterBuddy/PrivacyInfo.xcprivacy                  —   \
WaterBuddyWidget/PrivacyInfo.xcprivacy            —    | four byte-identical manifests, one per shipping
WaterBuddyWatch/PrivacyInfo.xcprivacy             —    | bundle. Each target's synchronized root group
WaterBuddyWatchWidget/PrivacyInfo.xcprivacy       —   /  gives membership with NO project.pbxproj edit
Screenshots/en-US/iPhone-6.9/*.png                4    the 6.9" store set, 1320x2868 — recaptured 2026-10-09 from 8a44e8f (1.1) on iOS 27.0; unstaged (#88)
Screenshots/en-US/AppleWatch/01-wrist.png         1    416x496 — the empty state (known issue #32), from 2026-09-02; kept until a new watch capture exists
Screenshots/census/AppleWatch/*.png               9    coverage run, five sizes plus four driven states, from 2026-09-02; untracked
```

Gone from disk since 2026-10-09, on the owner's word ("delete the all other items"): `Screenshots/en-US/iPhone-6.5/`
and `Screenshots/en-US/iPad-13/` (four files each — still in `8a44e8f`, their deletion unstaged) and
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
became a second consumer. They are **app-only**: the widget re-expresses the same lights itself in
`WidgetAurora`, because the app's absolute ±240pt offsets mean nothing on a 158pt canvas. Only the
colours in `Aurora` are shared between the two processes.

Plus four entitlements files, one per signed target — `Entitlements/WaterBuddy.entitlements`,
`Entitlements/WaterBuddyWidgetExtension.entitlements`, `Entitlements/WaterBuddyWatch.entitlements`
and `Entitlements/WaterBuddyWatchWidgetExtension.entitlements`, each declaring
`group.sardor.WaterBuddy` (rule `15-project`'s *Signing*) — and `WaterBuddyWidget-Info.plist`
(`NSExtensionPointIdentifier = com.apple.widgetkit-extension` only). *(This sentence named only the
first two files until the twenty-eighth pass; the watch's two have existed since 2026-09-01.)*

And five non-Swift build inputs — the four string catalogues and the app icon set — plus one file
that is deliberately *not* one. *(This line said "four" with three listed until the twenty-ninth
pass, and that pass's own "six" was off by one too; corrected by the same day's re-run.)*

| | |
|---|---|
| `WaterBuddy/Localizable.xcstrings` | **64** keys — 60 translated into en/ru/uz, 4 deliberately not (`%`, `+%lld`, `1,450 ml`, `WaterBuddy`). The explicit `en` values are what make the build emit an `en.lproj` to select. *(Read 58 until the thirty-sixth pass — three passes after the earlier-servings change had made it 61.)* |
| `WaterBuddy/AppShortcuts.xcstrings` | **3** phrases, **en and ru only** — Siri has no Uzbek, so this is the one catalogue that does not ship all three. Keys are the English phrases with `${applicationName}`; the build compiles `en.lproj`/`ru.lproj` `AppShortcuts.strings` (`AppShortcutPhraseTests`) |
| `WaterBuddyWidget/Localizable.xcstrings` | **19** keys — **15** in en/ru/uz: the 10 hand-written as a strict subset of the app's (a membership exception cannot carry a resource) plus `AddWaterIntent`'s five Shortcuts strings, translated since before the repository's first commit (known issue #1, retired this pass); and **4 the build extracted** (`%`, `+%lld`, `1,450 ml`, `Today`) with no values at all, which reach no compiled table. *(This row called all nine extracted keys untranslated until the twenty-ninth pass.)* |
| `WaterBuddyWatch/Localizable.xcstrings` | **16** keys — 15 in en/ru/uz (six copied value for value from the app's catalogue, nine the watch's own) and `%`, en only. Written by a script that copies the shared keys, and held to the phone's own strings by `LocalizationTests` through the built phone app |
| `WaterBuddyWatchWidget/Localizable.xcstrings` | **2** keys — `Today's hydration` (the complication's description, the phone's own string) in en/ru/uz, and `WaterBuddy`, en only and never translated |
| `WaterBuddy/Assets.xcassets/AppIcon.appiconset/AppIcon-{light,dark,tinted}.png` | 1024², generated |
| `Tools/GenerateAppIcon.swift` | **not in any target.** `Tools/` is not a synchronized root, which is the point — a `.swift` file in `WaterBuddy/` would join the app, and this one imports AppKit |

## Non-negotiables

These are the ones that a passing test suite cannot protect. Full reasoning lives in the DocC and
in `.claude/rules/`.

1. **`DataManager` is the only writer to the phone's SwiftData/`UserDefaults` pair** — one writer
   per store, not "the only writer" full stop, since `WristModel` is the identical thing for the
   watch's own local suite (non-negotiable #23). Views, intents and providers never touch
   `UserDefaults` or a `ModelContext` directly.
2. **`addWater` / `removeWater` call `refresh()` first.** Two processes hold their own instance;
   a stale one would write `staleTotal + amount` over a newer figure.
3. **The widget reads through `WaterSnapshot`, never `DataManager.shared`.** Constructing a
   `DataManager` is four writes from a process whose job is to draw.
4. **Reset writes the zero *before* it stamps the day.** The opposite order launders yesterday's
   water into today. Since the log became the source of truth this only clears the **cache** —
   yesterday's rows stay as history, and `resetDailyProgress()` is the one path that deletes rows.
5. **The day is a `yyyyMMdd` ordinal, never a `Date`.** An instant is re-read under the current
   time zone and travel would wipe a day.
6. **The container URL is the App Group probe** — `UserDefaults(suiteName:)` returns a live object
   even when the entitlement is missing.
7. **Only the app writes on behalf of the group** — the goal materialisation, the day stamp and
   the one-shot migration are all guarded by `DataManager.role`, which as of 2026-08-31 replaced
   the two-state `isAppExtension` at every guard site. See *The process role* below.
8. **`isGoalSet` is never materialised.** Its absence carries meaning.
9. **No `Material` in the widget** — `LiquidGlass.Base.archived` is the measured stand-in.
10. **Today's total is derived, never authored.** It is the sum of today's logs, written through
    the `currentWater` setter so the clamp, the equality guard and the widget doorbell all still
    fire exactly once.
11. **A failed read must not write.** `recomputeToday()` leaves the total untouched when the store
    cannot be read; returning `[]` on error once turned a transient failure into permanent loss.
12. **Every test builds an in-memory `ModelContainer`.** Omitting it resolves the *real* App Group
    store — see `tasks/lessons.md`.
13. **Reminders decide nothing at delivery time.** There is no fire-time hook for a local
    notification, so "skip this one" is an absence, not a filter — `ReminderPlan` is a pure value
    computed in advance. `removeAllPendingNotificationRequests()` is never called: from the
    extension it would clear the *app's* entire set (rule `80-notifications`).
14. **A read path may re-publish, but must not write back.** `refresh()` republishes
    `todaysLogs` and deliberately does *not* recompute the total from them: a cross-process
    SwiftData fetch can succeed while returning stale rows, and re-deriving would overwrite the
    widget's serving. See `tasks/lessons.md`.
15. **Nothing from `.claude/` or `CLAUDE.md` is a build input.** All four
    `PBXResourcesBuildPhase` sections are currently empty — verified this run.
16. **A type `DataManager` exposes lives *inside* `DataManager.swift`.** `WaterSnapshot`,
    `AppLanguage` and now `DaySummary` are declared at file scope in that one file rather than in
    files of their own. `DataManager.swift` is one of the six compiled into the widget extension,
    so a type it references from a separate app-only file is a break that appears **only** in the
    widget build — which the app scheme's green run never touches (rule `15-project`).
17. **History never reaches the widget.** `republishHistory()` opens with
    `guard Self.role.drawsHistory`, because `recomputeToday()` deliberately carries no such guard and
    `AddWaterIntent` therefore reaches `saveAndRecompute()` on every widget tap. Without it, that
    tap would run a seven-day fetch and a full Swift-side roll-up inside a process whose entire job
    is to draw one number. A per-day series is derivable from none of the phone's nine cache keys, so
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

`DataManager.role` (`DataManager.swift:1400`) resolves once, `nonisolated static let`, from
`isAppExtension` plus `#if os(watchOS)` — never a second runtime probe, which rule
`25-shared-storage` forbids because two probes can disagree and leave one guard open.

```
enum Role: Sendable, CaseIterable {   // DataManager.swift:1409
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
| `ownsSharedStorage` | *is this container my own first-class home?* | `:483` goal materialisation, `:1020` fresh-install day stamp |
| `mayHaveLegacyStandardDefaults` | *has my `.standard` ever held WaterBuddy state?* | `:942` `seedFromCachedTotalIfNeeded`, `:1544` `migrateIfNeeded` |
| `drawsHistory` | *do I have a history surface to draw?* | `:864` `republishHistory` |
| `mayFileReminders` | *may I file notifications for this user?* | `:1164` `requestReminderReschedule` |

*(Every `DataManager.swift` line in this section was re-derived on 2026-10-09, in the fortieth pass: the
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

Pinned by `ProcessRoleTests` (`WaterSnapshotTests.swift:519`): `onlyThePhoneAppOwnsTheGroupsBookkeeping`,
`aWatchAppAnswersLikeAnExtensionAndNotLikeTheApp`, `theTestHostResolvesAsThePhoneApp`,
`everyRoleIsAccountedFor`.

**Two rule files named `!isAppExtension` for this until 2026-09-01** — `40-widget.md` and
`80-notifications.md` both quoted the same stale sentence about `requestReminderReschedule`. Fixed
in this pass, as part of the watchOS plan's final documentation task (owner edit, per rule
`99-docs-cascade`; `.claude/` is not something `/doc_sync` may touch on its own). See retired known
issue #15.

## Current state

**The redesign's stage 1 is finished, tested and staged; it waits for the owner's `/commit`**
(2026-10-10, the forty-fourth pass). Six more stages follow — Home, History, Settings, the welcome, the
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
| warnings, clean builds of `8a44e8f` and of the change, four schemes | — | app 38 = 38 unique lines, widget 19 = 19, watch 2 = 2, watch widget 19 = 19; none in a changed file |

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
widget builds separately again because no scheme compiles a sibling's sources. *(This paragraph said
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

**There is a git repository.** Read last in the forty-fourth pass (2026-10-10), after the session's
final `git add`, from the commands themselves — and **run again as the first act of the forty-fifth,
which found every line of it still true**: no commit, the same twelve staged paths, the same
unstaged set. That pass staged nothing.

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
3. **The reminder has no action button.** Tapping it just opens the app. A "Log 250 ml" action would
   fit the product's arc exactly, but it needs a `UNUserNotificationCenterDelegate`, which can only
   be set from the app and requires an `NSObject` conformer this codebase does not have. Its own
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
    `DataManagerTests.swift:1102`; neither clean build shows it now.)*

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

37. **Three `@Test` names are each reused across two suites**, against rule `85-testing`'s "names are
    never reused across suites": `aCorruptZeroGoalFallsBackToTheDefault` and
    `progressUnclampedExceedsOneOnOverachievement` in both `DataManagerTests`
    (`DataManagerTests.swift:244`, `:232`) and `WaterSnapshotTests` (`WaterSnapshotTests.swift:91`,
    `:280`), and `theOfferedRangeIsAWholeNumberOfSteps` in both `DailyGoalSetupTests`
    (`DataManagerTests.swift:1312` — read `:1246` until the fortieth pass, and `:1213` until
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

39. **The phone's `String(format:)` figures never group thousands.** `HomeView`'s vessel draws
    `1300 / 2000 ml` and the week card `Best 8050 ml`, in every language, because `%1$d` does no
    grouping — while `AppLanguage.locale`'s DocC, `WaterBuddyApp.swift`'s injection comment and
    `docs/STATE.md` all say `\.locale` groups numbers ("4 500"). Only `Text(_:format:)` sites, and
    now the watch's readout (`WristVessel.readout`), honour it. Found because the watch's readout
    already grouped (`1 250 / 2 000 ml`), and the owner chose to keep that rather than copy the
    phone's figure (spec §3, ruling 3). The fix is a phone change of its own: format the figures
    first and hand them to `%1$@` keys, in both phone catalogues.

40. **The shared Russian keys use a single plural form.** `%1$d percent. %2$d of %3$d millilitres.`
    reads `62 процентов` (correct: `процента`), and `Add %1$d millilitres` reads `Добавить 222
    миллилитров` (correct: `миллилитра`) — wrong for counts ending in 1–4 except 11–14. The watch now
    inherits both, plus its own `Logs %1$d millilitres`. Heard rather than seen: these are VoiceOver
    strings. A fix means plural variations in every catalogue that holds the keys, at once, through a
    formatting path that honours them.

41. **`WristView.syncedCaption(composedAt:now:strings:)`'s `nil` branch is unreachable from
    production.** `WristMirror.composedAt` is non-optional, and `attribution(mirror:now:strings:)`
    answers a missing mirror before it gets there; only `noMirrorYetReadsAsNeverSynced` exercises it.
    Kept, and translated, because the parameter is optional (spec §8.3). Either make the parameter
    non-optional and drop the branch with its test, or leave it.

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

44. **The watch's millilitre line falls under 4.5:1 whenever water is behind it.** Measured off the
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

62. **`testAServingAddedToYesterdayShowsUnderYesterday` fails on a simulator that has kept enough
    servings.** It counts yesterday's rows before and after adding one, but a lazy list exposes only the
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
    review.
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
    - **2026-10-09, the forty-third pass: still so.** iOS 26.5's iPhone 17 (`EE56B958`) and iOS 18.6's
      iPhone 16 (`631501B6`) both answer "The device's data is no longer present". The redesign's
      stage 1 needs both erased (its plan's Task 0) and ran what it could on iOS 27.0's iPhone 17
      instead. The two `simctl erase` lines were given to the owner twice and had not run when this
      was written. No watchOS 26 runtime is installed either, so the redesign's watch stage cannot be
      rendered or tested here.

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
83. **History's header gave a UI test no value.** In stage 1's probe `app.staticTexts["Today"].value`
    did not carry "N of M millilitres" (it parsed as −1). The header is
    `.accessibilityElement(children: .ignore)` with a label and a value. **Whether VoiceOver speaks the
    value has not been checked**, in the Accessibility Inspector or on a device. If it does not, that is
    an accessibility defect in a shipped screen; if it does, it is only how XCUITest reads the element.
84. **Small things the redesign's read-only research turned up, none fixed:**
    (a) `LiquidGlassModifier.swift`'s `liquidGlass(in:)` comment says the content is placed on a pane
    "clipped to `shape`"; the pane is a background and the content is not clipped.
    (b) Four `Color(red:…)` literals in that file's preview backdrop are outside rule
    `60-design-system`'s permitted set. Preview only.
    (c) Stale comments: `GoalSetupUITests.swift:28-30` ("The iPhone is portrait-only now" — #31);
    `WaterBuddyApp.swift:18-20` (four integers and no `ModelContainer`) and `:67-68` (two
    destinations); `SettingsView.swift:13` (two cards) and `:348` (`EditServingSheet`);
    `HomeView.swift:170` (a *Today's log* button); `GoalSetupView.swift:14`.
    (d) No production caller: `removeWater(amount:)`, `resetDailyProgress()` and
    `WristVessel.diameter(fitting:reserving:)`, like `allLogs()` (#4). Tests pin all three.
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
88. **The store screenshots are of 1.1, and half-replaced.** `Screenshots/en-US/iPhone-6.9/` holds
    four captures of `8a44e8f` taken at 23:19–23:24 on 2026-10-09, on iOS 27.0 — a late clock, and
    figures grouped as the Mac's region groups them ("2 000"). `en-US/AppleWatch/01-wrist.png` and
    the nine captures in `Screenshots/census/AppleWatch/` are from 2026-09-02 and are kept until a
    new watch capture exists; the owner ruled that every screenshot is retaken once the redesign is
    built. The iPhone 6.5″ and iPad 13″ sets and the census's iPhone captures are deleted. All of it
    is unstaged, with the two capture-script fixes and the harness fix of #82.
89. **At the largest text size the first-run screen scrolls under the status bar.** Seen on iOS 18.6
    and 27.0 in stage 1's probe: scrolled up, the question's first line runs beneath the clock. The
    screen is the old one, replaced in stage 5; recorded so the new one is checked for it.
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
91. **What the final review of stage 1 found and nothing was done about** — smaller things, each the
    owner's or a later stage's:
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

## Where the rest is written down

- `docs/STATE.md` — the stored shape: keys, types, clamps, the rollover, the migration, the reminder seam
- `.claude/rules/80-notifications.md` — the notification rulings: why the plan is pure, why `add`
  replaces and `remove` cannot be awaited, why the widget shares the app's pending set
- `docs/WIDGET.md` — the widget contract: families, timeline, rendering modes, intent parameters
- `docs/DESIGN.md` — the design tokens and the measurements behind them
- `tasks/lessons.md` — pitfalls learned, append-only
- `HISTORY.md` — checkpoints, append-only

`docs/ARCHITECTURE.md`, `docs/CAPABILITIES.md` and `docs/dependencies.md` do **not** exist. The
topology is fully carried by `.claude/rules/10-architecture.md`, the capability surface by
`25-shared-storage` + `15-project`, and there are no dependencies to record. A stub restating a
rule file reads as coverage and is worse than the file's absence.
