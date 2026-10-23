# WIDGET — the contract

The widget's surface as it actually stands. The *reasoning* lives in the DocC on
`WaterBuddyWidget.swift` / `AddWaterIntent.swift` and in `.claude/rules/40-widget`.

**Last updated:** 2026-10-23 (set A's step 2's own Task 10 — not a `/doc_sync` pass). **No contract
here moved.** Step 2 changed one of the six shared files, `DataManager.swift` — `MonthHistory`, a
`nonisolated` value at file scope, and the app's `month`, `monthLogs` and `showMonth(_:)` behind
`role.drawsHistory` — and nothing on the widget's read path: no key, no field on `WaterSnapshot`, no
file under `WaterBuddyWidget/`, no change to `AddWaterIntent`'s pour beyond the re-read it already made
(`addWater` reaches `addLog`, whose re-read now leaves an unasked-for month alone). Both widget builds
in its gate, on the final code: `WaterBuddyWidgetExtension` (iOS 27.0) and `WaterBuddyWatchWidget`
(watchOS 27.0), each `** BUILD SUCCEEDED **`; a clean build of a copy of the index gives the widget
scheme the same 17 warning messages as the `HEAD` export, and the watch widget's 2. Nothing placed on a
Home Screen: no widget's view tree changed.

**Last updated:** 2026-10-22 (eighty-fourth pass — `/doc_sync` after set A's step 2 was specified and
planned). **No contract here moved; nothing was built.** Step 1 is committed (`d5cf816`). Step 2's
plan changes one of the six shared files, `DataManager.swift` — a new value type, `MonthHistory`, and
the app's month — and nothing on the widget's read path: no key, no field on `WaterSnapshot`, no file
under `WaterBuddyWidget/`. Both widget builds are in its gate.

**Last updated:** 2026-10-22 (eighty-second pass — step 1's Task 10). Checked: **still no file under
`WaterBuddyWidget/` and none of the six shared files changed in step 1** — its walk's fixes are in
`PaywallView.swift`, `PremiumAccess.swift`, `PremiumStore.swift` and `SettingsView.swift`, all app-only
— and no contract here did. `WaterBuddyWidgetExtension` built in step 1's gate, `** BUILD SUCCEEDED **`,
and a clean build of a copy of its index gives the same 17 warning messages as the `HEAD` export.

**Last updated:** 2026-10-22 (eighty-first pass — `/doc_sync` after set A's step 1, Tasks 0–7). **No
file under `WaterBuddyWidget/` changed, none of the six shared files did** (`DataManager.swift`'s
staged diff is still 1.4.1's DocC sentence, untouched by step 1), **and no contract here did.**
Everything step 1 adds — the monthly plan, set A, the paywall, `PremiumRim` — is app-only and
compiled into no extension. `WaterBuddyWidgetExtension` was not built after step 1's code in this
session (Task 0 built it from a `HEAD` export only: 17 messages by file and message); step 1's own
build is Task 9's.

**Last updated:** 2026-10-21 (eightieth pass — `/doc_sync` after roadmap item 1.4.1's Task 6). **No
file under `WaterBuddyWidget/` changed, and no contract here did.** One of the six shared files,
`DataManager.swift`, changed in a DocC sentence only (rule `70-privacy`'s StoreKit section renamed).
`WaterBuddyWidgetExtension` built in this session's gate, `** BUILD SUCCEEDED **`, and a clean build
of the staged index printed the same 17 messages by file and message — 29 unique lines — as the
1.4.1 baseline. Premium reaches no widget: nothing it adds is compiled into the extension.

**Last updated:** 2026-10-21 (roadmap item 1.3.2's stage 7c, written by the session that built it —
not a `/doc_sync` pass). **No file under `WaterBuddyWidget/` changed, and no contract here did.** The
watch's complication gained a rectangle and a corner beside its circle; that contract is the watch
stage's spec, `docs/superpowers/specs/2026-10-20-the-watch-stage-design.md` §3.6, and this sheet
covers the phone's widgets. None of the six shared files changed. `WaterBuddyWidgetExtension` built
from a copy of the stage's index, `** BUILD SUCCEEDED **`, with the same 29 warning lines as a clean
build of `HEAD`.

**Last updated:** 2026-10-20 (the seventy-sixth pass's `/doc_sync`, after roadmap item 1.3.2's stage
7a, staged). **No file under `WaterBuddyWidget/` changed, and no contract here did.** One of the six
shared files did: `LiquidGlassModifier.swift` draws Apple's glass on the watch too —
`#available(iOS 26.0, watchOS 26.0, *)` where it said `#if os(iOS)` and iOS alone. On iOS every
branch answers as before, and this extension's panes are `.archived`, so they take the hand-made
stack and never meet `glassEffect`. The extension was built from a copy of the stage's index,
`** BUILD SUCCEEDED **`, and a clean build of it against one of `HEAD` gave the same 29 warning
lines, none new. Nothing was placed or rendered. The watch's face draws no glass, and 7a did not
touch it.

**Last updated:** 2026-10-20 (the seventy-fourth pass's `/doc_sync`, after roadmap item 1.3.1's stage
6c, staged). **A fourth widget, `WeekWidget` (kind `WaterBuddyWeek`, medium), and a fifth snapshot
field, `weekTotals`.** *The week widget* has its own section; the read path, the provider's sample and
the bundle carry dated notes. Written by the build and read again in this pass against the staged
code: the cap on the week's type sits in `WeekView` since the final review, and the section says so.

**Last updated:** 2026-10-19 (the seventy-third pass's `/doc_sync`, after roadmap item 1.3.1's stages
6a, committed in `5a46609`, and 6b, staged). **The Home Screen widget's view tree changed; no family,
timeline, intent, kind or key did.** 6a: the pour button is the redesign's primary surface in full
colour and white in the lit rim on a template. 6b: when iOS removes the container background —
StandBy — the small family draws the bare layout, and its vessel has a quiet form under `.privacy`.
*The two rendering modes*, *Layout* and *Accessibility* carry both, with dated notes where they said
otherwise. *(2026-10-20, written by the session that built 6c, staged: a fourth widget and a fifth
snapshot field — *The week widget*, the read path's `weekTotals`, the bundle note under
*Configuration*.)*

**Last updated:** 2026-10-18 (roadmap item 1.3.4's records, then the seventy-second pass's
`/doc_sync`). **No widget contract changed** — no family, timeline, intent, kind or view tree.
`WaterSnapshot` computes two more values, `remaining` and `hasReachedGoal`, which no widget reads:
they are for Siri's *Today's Water*, in the app. A dated note under the snapshot's field table says
so; both widget schemes built with no new warning.

**Last updated:** 2026-10-17 (roadmap item 1.2.6's records, written by the session that built it —
not a `/doc_sync` pass). **No widget contract changed** — no family, timeline, intent or kind. What
the widgets draw changed: every figure is formatted with the snapshot's locale and grouped, and two
shared keys carry plural forms; a dated note under the strings table says so.

**Last updated:** 2026-10-15 (twenty-seventh pass — roadmap item 1.2.4's records, checked by the
owner's `/doc_sync`). **No widget contract changed:** `AddWaterIntent.perform()`'s code is the same.
One bullet, in *The intent also reschedules reminders*, says what it now files:
- the reminders name the *Log a Glass* button's category, which only the app registers;
- its reconcile files again a planned reminder pending in other words;
- both processes compose the same words in every explicitly chosen language, with *Follow device*
  not pinned (`docs/AI_CONTEXT.md` #134).

The paragraph below is the twenty-sixth pass's, as it was written.

**Last updated:** 2026-10-14, night (twenty-sixth pass — `/doc_sync` after the redesign's stage 5.
No contract changed. Two sentences corrected, both found by a fresh reader: the app's catalogue,
of which the widget's ten shared keys are a strict subset, is 103 keys, not 75; and the stage's
run line said every staged file matched the gate's export, which is true of the code, tests,
tools, strings, spec and plan, and not of the records, written after it.)
Before that: 2026-10-14, evening (the redesign's stage 5, the welcome, staged and not
committed; written by the session that built it. **No file under `WaterBuddyWidget/` changed, of
the six shared files only a comment in `DataManager.swift` did, and no contract here did.** The
stage added no key to `sharedKeys` and did not touch the widget catalogue. *Building it* has the
stage's run.)
Before that: 2026-10-14 (twenty-fifth pass — `/doc_sync` after the redesign's stage 4,
Settings, staged and not committed. **No file under `WaterBuddyWidget/` changed, none of the six
shared files did, and no contract here did.** The stage's one string is the app's own: Settings'
vessels note now says *"The Glass is the one your widget, Siri and Control Center log."* — the
slot `DataManager.usualSlot` names, which this extension's button and control log, put in the
words the screen draws. The widget catalogue was not touched; the stage changed no key in
`sharedKeys`. The extension was built in the stage's gate at 00:13, `** BUILD SUCCEEDED **`; two
comment-only edits to `SettingsView.swift`, which this scheme compiles through its
`WaterBuddy.app` entry, came after it (the app scheme was built after each). The warning
comparison built this scheme after a clean `build-for-testing` of HEAD (`c9d1f6b`) and of the
index as exported at 23:51 on 2026-10-13 — the staged tree but for those two comments — each into
its own folder: the same 19 distinct warnings by file and message, none from `WaterBuddyWidget/`.
**Nothing was rendered: no widget was placed.** Stage 3c, which the pass below calls staged, was
committed in `a58b9e6`.)
Previously: 2026-10-13 (twenty-fourth pass — `/doc_sync` after the redesign's stage 3c, the
look, staged and not committed. **No file under `WaterBuddyWidget/` changed, and no contract here
did.** One of the six shared files did: `LiquidGlassModifier.swift` tints Apple's glass with
`Aurora.top`, lays the hand-made sheen and lit rim over it, and scrims the phone's own hand-made
panes with `Aurora.top` — through `LiquidGlass.scrim(density:scheme:base:onPhone:)`, which answers
**black at 0.16 / 0.28 / 0.40, the values this extension always drew, for a `.flat` base**. The
widget's panes are `.archived`, so they take the hand-made stack and that black scrim as before, and
never reach Apple's glass or the sheen laid over it; the new `Selection` and `innerCornerRadius`
tokens are not read here. The extension was built from the stage's source, `** BUILD SUCCEEDED
**` — its own sources and the six shared files as they are staged; four comment-only hunks in
`HistoryView.swift`, which this scheme also compiles through its `WaterBuddy.app` entry, came
seventeen minutes later. HEAD and the tree were each built the stage's way — `build-for-testing`
of the app into an empty folder, then this scheme into the same folder — and this scheme's two
logs printed the same 19 distinct warnings by file and message, twelve in `DataManager.swift`,
five in `NotificationManager.swift`, two in `WristView.swift`, none from `WaterBuddyWidget/`.
(The app's two logs print 21: one more each in two test files.) **Nothing was rendered: no widget was
placed.** Stage 3, which the pass below calls staged, was committed in `e0762ab`.)
Previously: 2026-10-11 (twenty-third pass — `/doc_sync` at the end of the redesign's stage 3,
History, staged and not committed. **No file under `WaterBuddyWidget/` changed, and no contract
here did.** One of the six shared files did: `DataManager.swift` gained four derived answers for
History's screen (`reached(_:)`, `daysMet(in:goal:)`, `dayFraction(of:in:)`,
`hours(_:onDayOf:in:)`), none of which the extension calls or the snapshot carries. The extension
was built from the stage's source, `** BUILD SUCCEEDED **`, and a build of the staged tree —
into the folder the app scheme's clean build had just filled, not an empty one — printed the
same 19 distinct warnings as HEAD's did the same way — *Building it*, below. The app's catalogue holds
75 keys now, not 73; the ten this catalogue shares with it are untouched. **Nothing was rendered:
no widget was placed.** One caveat is new and older than the stage: on the one night a year a
zone's clocks go back across midnight, the timeline's midnight entry can be dated an hour after
the day began (`docs/AI_CONTEXT.md` known issue #107). Stage 2, which the passes below call
staged, was committed in `1ced514`.)
Previously, the same day (twenty-second pass — a fourth `/doc_sync` the same day, checking only
what the twenty-first had added. **No source changed, no contract did, nothing was built or
rendered.** The warning paragraph's figures all reproduce from the saved logs. Tightened: why this
scheme's build compiles the app — the scheme lists `WaterBuddy.app` as a second build entry, and
the app embeds the watch products; "half a minute earlier" — the app's build had ended 16 and 9
seconds before; which of the Lock Screen's gauges are hidden; "the publish `addWater` ends in";
the Lock Screen button's spelling, `AddWaterIntent(amount: serving)`; and a flag put beside the
bold sentence under *Building it*, which says what rule `40-widget` says and not what the build
does (#69). In the header below: of the old "four writes" one is guarded outright and one only
on a fresh install, not "two … guarded"; the two builds were on consecutive days, thirteen and
a half hours apart; the radius sample also folds the code's `proportional` step into one line;
and the sentence on the fourteen key names the two catalogues share was not listed.)
Previously, the same day (twenty-first pass — a third `/doc_sync` the same day. **No source
changed and no contract here did. Nothing was built or rendered.** A fresh reader checked the
sheet against the extension's five files, the catalogue, the plist and the project file; the
configuration, the timeline, the intent's table and every count held. Corrected: "constructing a
`DataManager` … four writes" — two of the four are guarded and do not happen in an extension;
"`addWater` does the real clamping" — it clamps nothing, the derived total is clamped; the Lock
Screen line carries no `accessibilityHidden` and needs none; **both of `AddWaterIntent`'s
initialisers activate the wrist link**, which the table did not say; a second sentence claiming
"the app scheme never compiles this target" (#69); and the twentieth pass's own warning sentence —
the build was not into an empty DerivedData folder, the two sides were built a day apart, and
"19" counts distinct warnings by file and message, which is 31 unique lines and 44 in all the way
`CLAUDE.md` counts. Left as it is: the radius sample, which drops the `: CGFloat` annotations the
code has, under a sentence that says "typed steps".)
Previously, the same day (twentieth pass — `/doc_sync` run again by the owner the same day, on
the same staged tree. **No source changed and no contract here did; five statements that were
already stale are corrected**, each with what it read before: the *Gallery name* row (a build
setting this target does not have), "the app's 56" strings (73) and which of this catalogue's 19
keys are hand-written (fifteen, not ten), `Log Water` drawn by the control and spoken by the Lock
Screen button though it is not one of the ten shared keys, a flat base "always hand-made" (opaque
under Reduce Transparency), and *Building it*'s `OS=26.5` and "38 warnings" from 2026-09-02 (27.0;
19 unique lines for this scheme). Stage 1's "staged" under *The two rendering modes* is now its
commit, `c9ef45d`. **Nothing was built or rendered in this pass**; the renders described next are
the nineteenth's.)
Previously, the same day (nineteenth pass — `/doc_sync` at the end of the redesign's stage 2,
Home, staged. **No file under `WaterBuddyWidget/` changed, and no contract here did.** Two of the six
shared files did. `LiquidGlassModifier.swift`: the modifier now branches on a pane's **base** — the
widget's `.archived` is a `.flat` base, which draws its own pane as before and never meets
`glassEffect` — and gained `.glassGroup()`, which the widget does not call. `DataManager.swift`
gained `undoLog(id:)`, four derived figures, a published `streak` and `dayDidTurn()`; none reaches
`WaterSnapshot`, and `streak` is computed behind `role.drawsHistory`, which the extension answers
`false` to. **This time the widget was rendered, both ways.** Its four `.archived` pane recipes,
drawn in a window from `b8a1386` and from the change, gave identical digests with Reduce
Transparency off and identical ones with it on — and the two settings differ from each other, so
both of a flat pane's branches ran. **And it was placed on a Home Screen**, small and medium, from
each build (iOS 27.0, light): SpringBoard's tree reads `25 percent. 500 of 2000 millilitres.`,
`500 ml`, `of 2000 ml` and `+250 ml`, and the two captures differ in no pixel of either widget —
0 of 573,408 in the medium cell, and 34 by one level in the small cell, all outside the widget's
rectangle. Not done: dark and tinted placements, the Lock Screen widget, the control. The extension
built for the simulator from the staged source, `** BUILD SUCCEEDED **`.
Previously: 2026-10-10 (eighteenth pass — `/doc_sync` after the redesign's stage 1 was finished
and staged. **No file under `WaterBuddyWidget/` changed, and no contract here did.** The shared
`LiquidGlassModifier.swift` gained two things since the last pass, both inside the branch that draws
Apple's glass: a black tint on the regular variant and an explicit hit region. The widget passes
`.archived`, takes the hand-made stack, and reaches neither. The extension built for the simulator
from the final source (`** BUILD SUCCEEDED **`, iOS 27.0); it was **not placed on a Home Screen**, so
"draws exactly what it drew" rests on the routing test and on the hand-made branch being unchanged,
not on a render.
Previously: 2026-10-09, seventeenth pass — `/doc_sync` during the redesign's stage 1, which was
staged and not finished. **No file under `WaterBuddyWidget/` changed, and the widget draws exactly
what it drew.** One shared file did, `LiquidGlassModifier.swift`: the app now draws Apple's glass on
iOS 26 and later, and *The two rendering modes* says why the widget cannot and does not. The
extension built for the simulator with the change; it was not placed on a Home Screen this pass.
Previously: sixteenth pass — `/doc_sync` after known issue #73: the reminder plan
`AddWaterIntent` files now follows the app's reminders toggle as it stands at the press, because
`refresh()` re-reads the flag. One bullet under *The intent also reschedules reminders*; no file under
`WaterBuddyWidget/` changed, and no other contract.
Previously: 2026-10-08, fifteenth pass — `/doc_sync` after known issue #68: the medium family's
two figure lines now follow the app's language like the rest of the widget. Its column is `MediumColumn`,
a view beneath `HydrationView`'s injection, and `HydrationView` reads no string itself. No contract
changed; known issue #76, found while moving the column, is pointed to from *Accessibility*.
Previously: fourteenth pass — `/doc_sync` after roadmap item 6: the extension also
holds **a control**, `LogWaterControl`, listed from iOS 18 inside `if #available(iOS 18.0, *)` — its own
section below. `AddWaterIntent` writes out its default `authenticationPolicy`, and
`DataManager.requestWidgetReload()` now reloads controls as well as timelines. Neither widget's contract
changed. Previously: thirteenth pass — `/doc_sync` after roadmap item 5: the extension now
holds **two widgets**, and the second, `LockScreenWidget`, has its own section below. The Home Screen
widget's contract is unchanged except that `PourButton` is no longer `private` — its `minimumTarget` is
the Lock Screen button's floor too. Previously: twelfth pass — `/doc_sync` after roadmap item 4, the Siri phrase: the snapshot's `serving` now reads `DataManager.usualServing(in:)` — the same value, given one name the Siri shortcut also calls; the "Shortcuts vocabulary" section corrected from "not translated", stale since known issue #1 was fixed on 2026-10-06; and a note that Shortcuts now lists the app's own *Log a Glass* beside *Log Water*. No widget contract changed. Previously: eleventh pass — `/doc_sync` after known issue #46: one sentence below still said `DataManager`'s reminder hook "spawns a detached `Task`"; it now queues each reconcile on one `ReconcileQueue`, in call order. No widget contract changed. Previously: tenth pass — /doc_sync after the App Store preparation work: the build command here was still pinned to `OS=18.6,name=iPhone 16` and is now `OS=26.5,name=iPhone 17`, and the extension's deployment target moved 26.5 → 17.0 to close a live defect where the widget did not exist on any device below 26.5 while its host app deployed to 18.6. The widget contract itself — families, timeline, rendering modes, intent parameters — is unchanged. Previously: ninth pass — one sentence: the reminder hook's early return is
`role.mayFileReminders`, not `isAppExtension`. No widget contract changed. Previously: eighth pass — every `WaterSnapshot` field documented, and the timeline's code sample corrected: it still showed the memberwise midnight entry that was fixed. Previously: the button now logs `entry.snapshot.serving`, and `rolledOver()` fixes the midnight entry that dropped the chosen language)

---

## Configuration

| | |
|---|---|
| Type | `StaticConfiguration` — there is nothing to configure |
| `kind` | `"WaterBuddyHydration"` (`WaterBuddyWidget.kind`) |
| Families | `.systemSmall`, `.systemMedium` |
| Provider | `HydrationProvider` (`TimelineProvider`) |
| Entry view | `HydrationView` |
| `configurationDisplayName` | `"Hydration"` — **static literal** |
| `description` | `"Track today's hydration and log a glass without opening the app."` — **static literal** |
| Content margins | `.contentMarginsDisabled()` |
| Bundle | `WaterBuddyWidgetBundle` (`@main`), two widgets and a control — this one, `LockScreenWidget` (*The Lock Screen widget*, below) and, inside `if #available(iOS 18.0, *)`, `LogWaterControl` (*The Control Center control*, below) |
| Gallery name | `.configurationDisplayName("Hydration")`, the row above — the gallery reads no plist key for it. The extension's own bundle name is `CFBundleDisplayName = WaterBuddy Widget`, written by hand in `WaterBuddyWidget-Info.plist`. *(This row read `INFOPLIST_KEY_CFBundleDisplayName = Hydration` until the twentieth pass: no such build setting exists on this target — it has `GENERATE_INFOPLIST_FILE = NO` — and the only two in the project are the watch app's, `"Water Buddy"`.)* |
| Info.plist | `WaterBuddyWidget-Info.plist` → `NSExtensionPointIdentifier = com.apple.widgetkit-extension` |

*(2026-10-20, roadmap item 1.3.1's 6c, staged: the bundle lists **three** widgets and a control — this
one, `WeekWidget` (*The week widget*, below) right after it, `LockScreenWidget` and `LogWaterControl`.
This table is the Hydration widget's; the week widget's own is in its section.)*

**Both gallery strings must stay static literals.** They are read by the system, not rendered by
us, so WidgetKit cannot carry format arguments across that boundary: interpolating either — by the
`LocalizedStringKey` or the `Text` overload, both were tried — traps the moment `body` is
evaluated, with *"Formatted text for `description` is not supported"*. That happens in the gallery
on device, not only in the Xcode preview.

So the serving is deliberately **not named** in the description — and since the vessels became
editable it could not be even if that were desirable, because the gallery renders before any entry
exists and any figure written there would be wrong for every user who changed theirs. The widget's
face draws `entry.snapshot.serving`.

`.contentMarginsDisabled()` because the system's ~16pt margin is a fifth of a 158pt canvas; the
card supplies its own inset (`cardInset = 10`, `cardPadding = 12`) — or, when there is no card
(StandBy, *Layout* below), the bare layout its own (`bareInset = 8`).

## The read path

`HydrationProvider` is `nonisolated` throughout — `TimelineProvider` carries no isolation — so
nothing in it may touch the `@MainActor` `DataManager.shared`. It reads through
`DataManager.snapshot(defaults:calendar:now:)`, which is also the **only way to read without
writing**: constructing a `DataManager` in this process can still roll the day over — zero the
total, stamp the day and ring the widget doorbell, none of it guarded — and it recomputes today
from the rows, which is not guarded either. *(Until the twenty-first pass this read "materialises
the goal, stamps the day, can zero the total and rings the widget doorbell — four writes". Two of
those are behind `role.ownsSharedStorage` and do not happen in an extension: materialising the
goal, and the fresh-install stamp. Rule `40-widget` has it right; the DocC on `HydrationProvider`
still says four — `docs/AI_CONTEXT.md` known issue #103.)*

**Everything the widget knows is on `WaterSnapshot`, and every field of it is derivable from the
`UserDefaults` cache alone** — that is the whole bar for living there, because the widget may never
open SwiftData (rule `40-widget`).

| Field | Resolved from | Why it has to cross |
|---|---|---|
| `currentWater` | `Key.currentWater`, with the day-ordinal rollover applied to the *returned value only* | the figure the vessel fills to |
| `dailyGoal` | `resolveDailyGoal(in:)` | the denominator; a missing key read as `0` would draw the first sip as 100% |
| `language` | `resolveLanguage(in:)` | the widget has its own strings table and its own process; without this it draws the *device* language while the app draws the chosen one |
| `serving` | `DataManager.usualServing(in:)` — `resolveServings(in:)[1]` with a name: the **middle** quick-add vessel, and the one definition the Siri shortcut (`LogServingIntent`, app-only) logs too | the vessels are user-editable, so the button's face and the amount it logs are no longer a constant both processes compile. They agree by reading one key instead |

*(2026-10-20, roadmap item 1.3.1's 6c, staged: a fifth field, `weekTotals: [Int: Int]?`, resolved by
`readWeekTotals(from:)` from `Key.weekTotals` — the last seven days by day ordinal, `nil` when absent or
not a week this build wrote (a failed decode, a count other than seven, a day outside
`0...maximumDailyIntake` — discarded whole). It crosses because the week widget may never open
SwiftData. Defaulted, like `serving`, so every memberwise call builds unchanged; `nonisolated`. Drawn
only through `week(endingOn:calendar:)`, which walks `DaySummary.window` — History's own walk — and
takes the day of `instant` from `currentWater`, so the midnight entry, `rolledOver()`, shifts the week
by itself. The snapshot still writes nothing: `readingACachedWeekLeavesTheStoreUntouched`.)*

`serving` is the newest and the one to reason about carefully: it is why `PourButton` takes an
`Int` and builds `AddWaterIntent(amount:)` rather than `init()`. Taking it from the snapshot rather
than resolving it live in the extension is deliberate — the face is rendered into an archive ahead
of time, so a live read could disagree with the number already drawn beside it. From one snapshot
they can be stale together but never inconsistent with each other.

*(2026-10-18, roadmap item 1.3.4, staged: `WaterSnapshot` also computes `remaining` and
`hasReachedGoal` — no new field, nothing new crosses, and **no widget reads them**. They are for
Siri's *Today's Water* (`TodaysWaterIntent`, app-only), which reads the same
`DataManager.snapshot()` the timeline does, so what Siri says is what the widget draws. Both are
`nonisolated`, twins of `DataManager.remaining` and `hasReachedGoal`, held together by
`theSnapshotAgreesWithTheManager`. The read path, the timeline and the widgets' view trees are
unchanged; both widget schemes built with no new warning.)*

| Method | Returns |
|---|---|
| `placeholder(in:)` | `WaterSnapshot.sample` |
| `getSnapshot(in:)` | `WaterSnapshot.sample` when `context.isPreview`, else `DataManager.snapshot(now:)` |
| `getTimeline(in:)` | two entries + `.after(midnight)` |

`WaterSnapshot.sample` is **1,150 of 2,000** — past halfway, so the water has a visible surface and
the readout has two digits. A brand-new install would otherwise advertise itself with an empty
vessel. *(2026-10-20, 1.3.1's 6c, staged: now `WaterSnapshot.sample(at:)`, the same 1,150 of 2,000 and
a week — 2,100 · 1,600 · 2,000 · 2,300 · 1,200 · 2,050 · 1,150, four days met — keyed by the days
ending on the date it is asked for, so the week widget's gallery shows bars rather than its empty
state. `placeholder(in:)` and `getSnapshot(in:)`'s preview both take it at `Date()`.)*

### The timeline

```swift
let midnight = DataManager.nextDayBoundary(after: now)
let current  = DataManager.snapshot(now: now)
[
    HydrationEntry(date: now,      snapshot: current),
    HydrationEntry(date: midnight, snapshot: current.rolledOver()),
]
Timeline(entries: entries, policy: .after(midnight))
```

An entry's `date` is when WidgetKit *renders* it, so the second entry is a scheduled visual change
that costs no wake-up. Without it, a widget nobody touches still shows yesterday's water tomorrow
morning.

**`rolledOver()`, never a memberwise call — and this is a fixed bug, not a preference.** That line
read `WaterSnapshot(currentWater: 0, dailyGoal: current.dailyGoal)` until 2026-08-30. `language`
carries a default of `.system`, so **every field the author did not name was silently reset at local
midnight**: a user who chose Russian in the app watched the widget revert to the *device* language
overnight and stay there until something else reloaded the timeline. It shipped for two releases and
nothing could see it — the widget's rendering has no automated coverage at all. *(This sentence
also said "the app scheme never compiles this target" until the twenty-first pass. It does — the
app embeds the extension; known issue #69 — and a compile would not have shown a wrong language
either.)*

`rolledOver()` copies `self` and zeroes one field, so a field added later is carried across for free
rather than needing to be remembered. `serving` was added an hour after the fix and inherited it
without a line of work. `rollingOverChangesNothingExceptTheTotal` asserts the **whole value** rather
than a list of fields, so the test cannot go stale the way the initialiser did.

`nextDayBoundary(after:calendar:)` uses the **same** `Calendar.waterBuddyDay` as the rollover, so
the app and the widget never disagree about when the day turns. It falls back to
`date + 24h` if `nextDate` ever returns `nil`.

## The two rendering modes

`@Environment(\.widgetRenderingMode)`, checked in `MiniVessel`, `WidgetPane`,
`WidgetCardBackdrop` and `WidgetAurora`.

**`.fullColor`** — the ordinary Home Screen. The hand-made glass, with
`LiquidGlass.Base.archived` standing in for the material because there is no live backdrop to
sample. **It is no longer "the app's glass exactly" on iOS 26 and later:** since the redesign's stage
1 (2026-10-09; committed 2026-10-10 in `c9ef45d`) the app draws Apple's glass there, and the widget
does not. `.archived` is a `.flat` base, and `LiquidGlass.rendering(…)` never answers `.system` for
a `.flat` base on any OS: it answers `.handMade`, or `.opaque` under Reduce Transparency, which the
function tests first. `aFlatBaseIsAlwaysHandMade` pins the first, with Reduce Transparency off and
the availability flag both ways; `reduceTransparencyAlwaysDrawsTheOpaquePane` pins the second for
`.archived` as well as for a material; and both branches were rendered in stage 2 (the header
above). So nothing in this extension reaches `glassEffect`. *(Read "answers `.handMade` for a
`.flat` base on every OS" until the twentieth pass, which left Reduce Transparency out.)* The widget's
own pass of the redesign is stage 6 — roadmap item 1.3.1 — *(seventy-third pass: 6a, the pour
button, committed in `5a46609`; 6b, StandBy, staged; 6c, the week, not built. This sentence read
"is stage 6 and is not built" until then.)* *(2026-10-20: 6b committed in `ed77d9f`; 6c, the week
widget, built and staged — its card goes through the same `WidgetPane`, `.archived`, never
`glassEffect`.)*

**Anything else** — a tinted Home Screen, and StandBy at night, where the mode is **inferred** to be
`.vibrant` (spec 2026-10-19 §3.3; the SDK says nothing of StandBy). The system treats the whole
widget as a template: **colour is discarded and only alpha survives**, so every layer `LiquidGlass`
stacks becomes additive — including the black scrim, which would *brighten* the pane, and the
shadows, which would ring it in haze. *(Read "a tinted Home Screen, StandBy" until the seventy-third
pass. StandBy by day is `.fullColor` with the container background removed — *Layout*, below.)*

| Element | `.fullColor` | templated |
|---|---|---|
| Pane | full `liquidGlass(base: .archived, …)` — or, with `widgetPane(…, glass: false)`, the rim alone | `shape.strokeBorder(.white.opacity(0.45), lineWidth: 1)` only |
| Water | `WaterSurface` (two gradient waves) + `WaterReadabilityScrim` | one opaque `WaveShape` at `.white.opacity(0.55)` |
| Pour button (6a) | `PourSurface`: `.primarySurface(in:ring: false)` — solid white, `Aurora.top` content, no ring, so exactly 44 pt | white content in the rim above — a white shape with dark content would come back as one blank disc |
| Card backdrop | `WidgetAurora` scaled `1.22`, blurred `12`, saturated `1.1` | `Color.clear` |
| Container background | `WidgetAurora` (gradient + three lights) | `Color.black` |

Parts that change with the data carry `.invalidatableContent()`; tintable artwork carries
`.widgetAccentable()`.

## Layout

Small — vessel and button on a **diagonal**. They cannot stack (a 138pt card will not hold a
legible vessel *and* a 44pt target beneath it) and they must not overlap (two glass discs sharing
an edge read as one dented shape, not two controls).

Medium — vessel beside the numbers: hero volume, `of N ml` under it, full-width quick-add capsule.

**Small, bare — StandBy (6b, staged 2026-10-19).** `HydrationView` reads
`showsWidgetContainerBackground` once; when it is `false` — iOS removed the container background,
on iPhone StandBy — the small family draws `SmallLayout(snapshot:bare: true)` at `bareInset = 8`
instead of the card: no card pane, no `WidgetCardBackdrop`, the vessel and the button on the
system's black, on the same diagonal. The vessel is sized by the same formula below over the larger
square and draws its rim and its water, never its glass (`widgetPane(…, glass: false)`: glass never
goes over a flat background). The flag is a parameter because the environment value is get-only, so
three `#Preview`s draw the bare layout directly — by day, at night (`.vibrant`) and locked. Medium
has no bare layout: iPhone's StandBy shows small widgets only (**inferred** from Apple's
documentation). Rendered only through a throwaway build that forced the branch — the simulator has
no StandBy — where, on the simulator's 164.3-pt small widget, the vessel measured 109.7 pt across
(the formula's figure; about 105 on a 158-pt widget, where the card leaves 84), the button 44.0 pt,
24 pt between them (`HISTORY.md`, 2026-10-19). Real StandBy is known issue #148.

### The vessel radius is derived from the button, not from the canvas

```swift
static func radius(fitting side: CGFloat, besides target: CGFloat, gap: CGFloat = 4) -> CGFloat {
    let root2  = 2.0.squareRoot()
    let button = target / 2
    let reach  = root2 * (side - button)
    let cap    = (reach - button - gap) / (1 + root2)
    return max(0, min(side * 0.37, cap))
}
```

With the vessel's centre at `(r, r)` and the button's at `(side - t/2, side - t/2)`, the centres
are `√2·(side - t/2 - r)` apart and that must beat `r + t/2` by the gap.

A flat proportion cannot do this job: **74% of the short side clears by 6pt on a 158pt widget and
overlaps by 3pt on the 141pt one an iPhone SE-class device gets.** The 0.37 proportion still
governs everywhere it fits. (It is spelled out in typed steps because the one-line form takes the
type checker past its time limit.)

`PourButton.minimumTarget = 44` and **WidgetKit does not pad a button out** — the hit region is
exactly the label's frame.

## The interactive half

`Button(intent:)` is the **only** kind of button a widget can have: the archive carries the intent
and the system runs it on tap. `.buttonStyle(.plain)`, or the system draws
`WidgetBorderedButtonStyle`'s capsule over the button's own surface — glass until 6a, the primary
surface since. (A control is not a widget: its button is a
`ControlWidgetButton` — *The Control Center control*, below.)

### `AddWaterIntent`, as Shortcuts sees it

| | |
|---|---|
| `title` | `"Log Water"` (a `let` — a `static var` on a `Sendable` type is an error in the Swift 6 mode) |
| `description` | `"Adds a serving of water to today's total in WaterBuddy."`, `categoryName: "Hydration"` |
| `openAppWhenRun` | `false` |
| `authenticationPolicy` | `.alwaysAllowed` — the protocol's default, written out on 2026-10-08 because the control's locked-phone ruling rests on it (rule `70-privacy`) |
| `@Parameter amount` | title `"Amount"`, description `"Millilitres of water to log."`, `default: 250`, `inclusiveRange: (1, 100_000)` |
| `parameterSummary` | `"Log \(\.$amount) ml of water"` |
| `init()` | sets `amount = DataManager.defaultServing` — the `AppIntent` requirement and the Shortcuts default, **not** the path the widget button takes |
| both initialisers | also call `WristLink.live.activate()` (behind `#if canImport(WatchConnectivity)`), so the extension's `WCSession` is activating before a tap: the button builds its intent on every timeline render, and without it the publish to the watch that `addWater` reaches — through `refresh()` and the `currentWater` setter — throws `sessionNotActivated` in this process (by the DocC on the intent; not run). *(Not in this table until the twenty-first pass.)* |
| `init(amount:)` | explicit amount — **this is what every button uses**: both widgets' with `entry.snapshot.serving`, the control's with its provider's `snapshot.serving` |
| `perform()` | `@MainActor` → `DataManager.shared.addWater(amount:)`, then `WidgetCenter.shared.reloadAllTimelines()`, then **`await NotificationManager.reconcile(…)`** |

`@Parameter` is a macro and its arguments must be compile-time constants, so they **cannot** spell
`DataManager.defaultServing` or `maximumDailyIntake` — and especially cannot spell a value the user
edits at runtime. Those literals are only what Shortcuts pre-fills and validates against when a
person builds an automation by hand; every button goes through `init(amount:)` — both widgets' with
`entry.snapshot.serving`, the control's with its provider's `snapshot.serving`. **`addWater` does
not clamp the amount**: it refuses anything not above zero and stores the row as given. What is
clamped is the total derived from the rows — the sum saturates and the `currentWater` setter
holds it to `0...maximumDailyIntake`. *(Read "`addWater` does the real clamping regardless of what
any caller asks for" until the twenty-first pass.)*

`@MainActor` on the implementation of a `nonisolated` protocol requirement is legal and
warning-free in **both** language modes — verified by compiling under `-swift-version 5` and
`-swift-version 6`. It is what lets the body touch `DataManager.shared` without hopping by hand.

**The explicit reload is not redundant.** WidgetKit reloads after an interactive intent on its own,
but only the timeline it owns and only if it decides something changed — which covers neither this
intent run from Shortcuts nor a total already pinned at `maximumDailyIntake`, where
`currentWater`'s setter returns early and never rings the doorbell.

`AddWaterIntent` is compiled into the **extension only**. The app's own button already holds the
`DataManager`, and a second copy in the app binary would register the same action twice in
Shortcuts.

### The intent also reschedules reminders, and it is the only place that can

`perform()` ends on an **awaited** `NotificationManager.reconcile(…)`. That is not the "call the
side effect again to make sure" rule `20-state` forbids — it is the only place the work can happen
at all:

- A widget extension is guaranteed to live exactly as long as the *awaited* work inside
  `perform()`. `DataManager`'s injected reminder hook queues its reconcile for a background
  worker (one `ReconcileQueue` per process, so reconciles run in call order), which in this
  process would be torn down before it reached the system — so that hook returns immediately
  unless `role.mayFileReminders`, which only `.phoneApp` answers `true`. (It read
  `!isAppExtension` until 2026-08-31; the predicate now also excludes a watch, for a second and
  independent reason — `ReminderPlan.Slot.identifier` is a pure function of day and hour, so a
  separate notification centre would file identifiers it cannot dedupe against the phone's.)
- The centre reached from here is the **containing app's**. An `.appex` has no notification identity
  of its own: `UNUserNotificationCenter.current()` sees a non-`APPL` bundle and resolves through
  `LSPlugInKitProxy.containingBundle`, so these requests join the same pending set the app manages.
  Which is why `reconcile` only ever removes identifiers under `ReminderPlan.identifierPrefix` —
  `removeAllPendingNotificationRequests()` from here would clear the app's entire set.
- The plan it files is `DataManager.shared.currentReminderSlots()`, and since 2026-10-08 that plan
  follows the app's reminders toggle as it stands at the press. `addWater(amount:)` starts with
  `refresh()`, which now re-reads `remindersEnabled` with the goal, the vessels and the language. Until
  then an extension that had outlived the toggle planned from the flag it launched with: a press after
  reminders were switched on filed an empty plan, which cleared them, and a press after they were
  switched off filed them again (known issue #73, retired — pinned by tests, never reproduced on a
  device).
- Since 2026-10-15 (roadmap item 1.2.4) the reminders it files name the *Log a Glass* button's
  category, which only the app registers, and its reconcile files again a reminder still in the plan
  that is pending in other words than its own. In every language the user picks explicitly, both processes compose the
  same words — `theAppAndTheWidgetFileRemindersInTheSameWords` pins it — so neither re-files the
  other's; *Follow device* is not pinned (`docs/AI_CONTEXT.md` known issue #134). `perform()`'s code
  is unchanged.

**Unverified:** whether WidgetKit's sandbox *permits* the call at runtime. The addressing is proven;
the permission is not, and sandbox profiles are kernel-compiled. `DataManager.refresh()` reconciles
on every foreground as the backstop, so a denial degrades to "reminders correct themselves next time
you open the app" rather than breaking. Full reasoning in rule `80-notifications`.

`ReminderPlan.swift` and `NotificationManager.swift` are on the extension's `membershipExceptions`
list for exactly this reason — six shared files now, not four.

## Accessibility

- The vessel is one element: `.accessibilityElement(children: .ignore)`, label
  `"Today's hydration"`, value `"\(percentage) percent. \(currentWater) of \(dailyGoal) millilitres."`
- **Its quiet form (6b).** The vessel's water and percentage carry `.privacySensitive()`; when
  `redactionReasons` contains `.privacy` it draws an empty rim — no water, no figure — and speaks its
  label alone, as the Lock Screen widget does (rule `70-privacy`: StandBy is a locked-phone
  surface). `MiniVessel` is shared, so the medium vessel has the form too; the medium's two figure
  lines do not (#148). The bare layout carries the card's `.accessibilityElement(children: .contain)`.
- In the medium family the visible hero figure and the `of N ml` line are hidden
  **individually** — both numbers are already in the vessel's value, and left visible they become
  two more stops, the second of which is a fragment. Never hide the enclosing stack: it also holds
  the button, and the widget's only control would become unreachable.
- The button carries `.accessibilityLabel("Add \(entry.snapshot.serving) millilitres")`; a
  bare `+` does not say what it adds.
- The medium column caps at `.dynamicTypeSize(...DynamicTypeSize.accessibility1)` — a widget
  cannot scroll or reflow, so past the first accessibility size the type holds still rather than
  eating the 44pt control. *(By reading, the cap does not reach the hero's own `@ScaledMetric`, which
  sits above it — known issue #76, not rendered.)*

## The extension carries its own localisation

The widget ships in English, Russian and Uzbek, and **it has its own `Localizable.xcstrings`** —
`WaterBuddyWidget/Localizable.xcstrings`, 19 keys. **Fifteen are hand-written** — marked `manual`,
in all three languages: ten it shares with the app, a strict subset of the app's 103 (75 until the
redesign's stage 5, staged 2026-10-14, which added 28 and touched none of the ten; 73 until stage
3, staged 2026-10-11, which touched none of them either) and the ten
`LocalizationTests`' `sharedKeys` names, and the five of `AddWaterIntent`'s Shortcuts vocabulary,
which the app's catalogue does not hold. The other four are literals the build extracted, with no
translation: `%`, `+%lld`, `1,450 ml` and `Today` (see below). Those four names are in the app's
catalogue too — fourteen of the nineteen names are in both — but only the ten carry values here
that a test holds equal to the app's; `Today` is translated there and empty here. *(Read "the 10 hand-written ones
are a strict subset of the app's 56; the other nine were extracted by the build" until the
twentieth pass: the app's catalogue has grown to 73, and five of those nine are the hand-written
Shortcuts strings.)*

That duplication is not a preference. The catalogue was first placed in `WaterBuddy/` and added to
the widget's `membershipExceptions`, exactly the arrangement the six shared `.swift` files use. It
does not work: `xcodebuild` ran `xcstringstool` against the **app** target's build directory only,
the `.appex` came out with no `.lproj` at all, and the build then rewrote `project.pbxproj` to
delete the entry. A synchronized-folder membership exception carries source, not resources.

**Which language it draws in comes from the snapshot.** `WaterSnapshot.language` is read by
`DataManager.snapshot(defaults:calendar:now:)` out of the App Group cache — the provider is
`nonisolated` and never touches the model — and `HydrationView` injects it as
`EnvironmentValues.strings` and `\.locale`, reading neither itself: a view's own `@Environment` comes
from above it, so every string is resolved in a view below — `MiniVessel`, `PourButton`, and the medium
family's `MediumColumn`. Without it the widget would render in the *device*
language while the app rendered in the chosen one: two front doors disagreeing. `serving` travels
in the same snapshot for the same reason, and `rolledOver()` is what carries **both** across the
midnight entry — which it did not before, so the widget silently reverted to the device language at
local midnight until something else reloaded it.

Two limits worth stating plainly:

- **The gallery strings do not follow.** `.configurationDisplayName` and `.description` are read by
  the system for the widget picker, not rendered by us, so they stay in the device language.
- **The face follows on the next refresh, not instantly.** Changing the language rings the widget
  doorbell, but a timeline already built is an archive another process replays, and WidgetKit
  decides when to redraw. `SettingsView`'s language card says so rather than implying otherwise.

The catalogue now holds **19 keys**: ten shared with the app, five for Shortcuts (the next
section) and four the build put there. Xcode's build extracts every `Text` / `Label` /
`LocalizedStringResource` literal in the target and appends it, so the file is part hand-authored
contract and part build output. The ten shared ones are what the Home Screen widget *draws or
files* — **and one more string is used on a face that is not among them:** `Log Water`, one of the
five Shortcuts strings, is also the Control Center control's title and what VoiceOver calls the
Lock Screen rectangle's button in its quiet form, each in the app's chosen language, from the
snapshot's bundle. The ten:

| Key | Where |
|---|---|
| `Hydration` | `.configurationDisplayName` |
| `Track today's hydration and log a glass without opening the app.` | `.description` |
| `Today's hydration` | the vessel's accessibility label |
| `%1$d ml` · `of %1$d ml` · `+%1$d ml` | the readout and the button's face |
| `%1$d percent. %2$d of %3$d millilitres.` | the vessel's accessibility value |
| `Add %1$d millilitres` | the button's accessibility label |
| `Time for water` · `A glass now keeps you on track for the day.` | the reminder copy |

The last two are on the list because `NotificationManager` is one of the six shared files and
`AddWaterIntent` files reminders **from the extension** — so the copy is composed in the widget
process, where `Bundle.main` is the `.appex`.

The gallery strings stay **static literals**, as rule `40-widget` requires: a localisation key is
still a literal, and nothing is interpolated into either.

Formats are positional (`%1$d`) rather than bare `%d` so a translator may reorder — Uzbek turns
"X of Y" into "Y dan X". `LocalizationTests` asserts the extension actually ships both languages,
that its table agrees with the app's value for value, and that every translation carries the same
format arguments as its key.

*(2026-10-17, roadmap item 1.2.6:)* every figure the widgets draw or speak is formatted with the
snapshot's locale, through `Bundle.localized(_:_:locale:)` in `DataManager.swift` — so the readout,
the goal line, the button's face and both spoken sentences are grouped (`12 500 мл`, `из 2 000 мл`,
`12,500 ml`), where they grouped in no language before (#39, closed). Two of the ten keys carry
**plural forms**: `%1$d percent. %2$d of %3$d millilitres.` (its last volume; in Russian its percentage too) and
`Add %1$d millilitres` — English *one*/*other*, Russian *one*/*few*/*many*/*other*, Uzbek one value —
value for value the app's. A key with forms leaves `Localizable.strings` for `Localizable.stringsdict`
in the built `.appex`; `LocalizationTests` reads both and compares the two bundles form by form. The
Lock Screen rectangle's `spokenFigures(in:locale:)` takes the locale too. Rendered on the simulator at
12,500 ml in English, Russian and Uzbek, on the Home Screen and the Lock Screen: nothing cut.

### `AddWaterIntent`'s Shortcuts vocabulary is translated

*(This section said "**not** translated" until 2026-10-07. Known issue #1 was fixed on 2026-10-06 and
the section was not updated with it; the code won.)*

Five strings in the widget's catalogue are `AddWaterIntent`'s entire Shortcuts-facing vocabulary, and
all five ship in English, Russian and Uzbek:

| String | Where the user sees it |
|---|---|
| `Log Water` | `static let title` — the action's name in Shortcuts |
| `Adds a serving of water to today's total in WaterBuddy.` | `IntentDescription` |
| `Amount` | the `@Parameter` title |
| `Millilitres of water to log.` | the `@Parameter` description |
| `Log ${amount} ml of water` | `parameterSummary` |

They are `LocalizedStringResource` and `@Parameter` macro arguments — **compile-time constants** — so
they cannot take a runtime bundle the way `Text(_:bundle:)` does: they follow the **device** language,
resolved by the system, not the in-app language picker. `everyWidgetStringIsTranslatedUnlessDeliberatelyNot`
checks the extension's own catalogue, the half `everyDrawnStringIsTranslatedUnlessDeliberatelyNot`
(app bundle only) could never see.

**Shortcuts lists a second WaterBuddy action** since 2026-10-07: *Log a Glass*, the app-only
`LogServingIntent` behind the Siri phrase. Its strings live in the **app's** catalogue, not this
one — it is not part of the extension (`docs/superpowers/specs/2026-10-07-siri-phrase-design.md`).

## The Lock Screen widget

Added 2026-10-08 (roadmap item 5; spec `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`,
the authority for everything below; rules `40-widget`, `60-design-system`, `65-accessibility`,
`70-privacy`).

| | |
|---|---|
| Type | `StaticConfiguration` — `LockScreenWidget`, in `WaterBuddyWidget/LockScreenWidget.swift` |
| `kind` | `"WaterBuddyLockScreen"` (`LockScreenWidget.kind`) |
| Families | `.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline` — iOS 16.0, under the 17.0 floor |
| Provider | **the same `HydrationProvider`** — the same snapshot read, gallery sample, midnight `rolledOver()` entry and `.after(midnight)` policy |
| Gallery strings | the Home Screen widget's two literals, `"Hydration"` and its description |
| Content margins | iOS's own — **no** `.contentMarginsDisabled()` (configuration-wide; the Home Screen's) |
| Container background | an empty `containerBackground(for: .widget)`: the Lock Screen draws none, but iOS overlays a warning on a widget without one |

**What each shape draws.** The circle: an `.accessoryCircularCapacity` ring filled to `progress`, with
`Text(snapshot.percentage, format: .percent.locale(locale))` inside at a `0.4` scale floor — `MiniVessel`'s
floor; at 0.6 Russian's `38 %` truncated to `38…`. The rectangle: `%1$d ml` and `of %1$d ml` (the medium
family's keys), an `.accessoryLinearCapacity` bar, and the **+** —
`Button(intent: AddWaterIntent(amount: serving))` — the serving handed down from `entry.snapshot` — `.buttonStyle(.plain)`, a `plus` over
`AccessoryWidgetBackground`, framed to `PourButton.minimumTarget`. The line: a `drop.fill` and the
percentage. The gallery draws `WaterSnapshot.sample`: **57%** (1,150 of 2,000 — `57.49999999999999`
rounds down).

**Rendering.** The iPhone Lock Screen is always the vibrant mode, so there is no branch on
`widgetRenderingMode`, no glass, no `Aurora` colour and no `colorScheme` override — capacity gauges,
`.primary`/`.secondary` and `AccessoryWidgetBackground` only.

**Privacy.** Every figure-bearing view, fills included, is `.privacySensitive()`; each shape reads
`redactionReasons` and, under `.privacy`, draws its quiet form — the drop, an empty ring or bar,
*Hydration* — and speaks its label alone, the button *Log Water*. Both answer the one trigger iOS applies
when the user turns off *Allow Access When Locked → Lock Screen Widgets*.

**Language.** `LockScreenView` injects `\.strings` and `\.locale` from `entry.snapshot.language` and reads
neither itself — each shape is a child view, because a view's own `@Environment` comes from above it
(known issue #68 was the Home Screen medium family's version of that trap, fixed on 2026-10-08 the same
way: its column, `MediumColumn`, is a view of its own).

**Accessibility.** One combined element per shape (label `Today's hydration`, the vessel's
percent-and-millilitres value), the button its own; in the circle and the rectangle the drawn
figures and glyphs also carry `.accessibilityHidden(true)`, and so does the rectangle's gauge, in
both of its forms; the circle's gauge is itself the combined element and carries none. The line does not need it and
has none: its `Label` is the one element, with `children: .ignore`. The card's figures carry `.invalidatableContent()`, so a tap shows at once.

**Proved and not.** On the simulator: registered in the gallery, placed, rendered and captured in all
three languages and at three digits. **Not proved:** the **+** (`linkd` refuses the ad-hoc-signed
extension, #63), the quiet form, and what VoiceOver says — SpringBoard's XCUITest tree lists the drawn
texts beneath each combined element whatever the flags (#70). The owner's device check (spec §7.5) is
the proof.

## The week widget

*Added 2026-10-20 — roadmap item 1.3.1's stage 6c, built and staged, not committed.* History's week
card at widget size, on the Home Screen
(`docs/superpowers/specs/2026-10-19-the-widget-stage-design.md` §3.4–§3.6).

| | |
|---|---|
| Type | `StaticConfiguration`, in `WeekWidget.swift` |
| `kind` | `"WaterBuddyWeek"` (`WeekWidget.kind`) — permanent once shipped |
| Families | `.systemMedium` only |
| Provider | `HydrationProvider` — the Hydration widget's, never a second one: one snapshot, one midnight, one reload |
| Entry view | `WeekView` → `WeekCard`, drawn with `widgetCard()`, the card the Hydration widget draws |
| `configurationDisplayName` | `"Week"` — **static literal** |
| `description` | `"Your last seven days against your goal."` — **static literal**, no figure |
| Content margins | `.contentMarginsDisabled()`, `HydrationView.cardInset` around the card |
| Link | `.widgetURL(WidgetLink.history)` — `waterbuddy://history`, answered in `RootTabView` by `AppTab(link:)`; **no URL scheme is registered**, and none is needed for a widget's own app (proved warm and cold on the simulator before any code) |

**What it draws.** `entry.snapshot.week(endingOn: entry.date, calendar: .waterBuddyDay)`: the title
*Last 7 days*, the days met over *Goal met* (*2 of 7*, through `%1$@ of %2$@` as History draws it), seven
bars on white 0.10 tracks — cyan for a met day, white for the rest, a 2-pt sliver for an empty day and
4 pt at least for any water — against a 1.5-pt dashed goal line at white 0.62, and the narrow weekday
letters, today's heavier. The scale is the goal or the best day, whichever is larger, so a met bar
always stands at or above the line. **No button.** When the snapshot's week is `nil` it says *Open
WaterBuddy to see your week.* — two lines allowed — and draws no bars, never a week of zeros.

**Rendering modes.** The card is the same `WidgetPane` over `.archived` as the Hydration widget's; on a
template a met bar is `.widgetAccentable()`. Not placed on a tinted Home Screen yet (#149).

**Accessibility.** One element: label *Last 7 days*, value History's sentence — *Average 2,607
millilitres. Best 12,500 millilitres. Goal met on 2 of 7 days.* — or, with no week, the line it
draws. Type is capped at `.accessibility1` — **in `WeekView`, above the card**, because the card's own
`@ScaledMetric` reads the environment from above it, and every font in it is a ratio of that metric.
Written first inside the card's body, as the medium column's still is (#76), it capped nothing: at AX5
the title more than doubled and pressed the bars to slivers. Moved after the final review, and rendered
before and after; at AX5 the widget is now pixel-identical to AX1. With `.lineLimit(1)` and
`.minimumScaleFactor(0.6)` beside it.

**Measured on the simulator** (2026-10-20, *Probe 27*, iOS 27.0): the gallery shows the sample, four
days met; the placed widget agreed with History's card day by day, took a serving added to Sunday,
turned over at midnight with nothing tapped, opened History warm and cold, and drew Russian and
Uzbek. The colour pairs are in `docs/DESIGN.md`. **On the simulator the gallery offered none of an
app's widgets until the app had run once**, and that run writes the week, so the empty state was
seen only in a throwaway build (#149).

**Localisation.** Seven keys in the widget's catalogue, all in `sharedKeys`: *Week*, *Your last seven
days against your goal.* and *Open WaterBuddy to see your week.* (new in both catalogues), and *Last
%1$d days*, *Goal met*, *%1$@ of %2$@* and History's spoken sentence, copied from the app's with their
plural forms.

## The Control Center control

Added 2026-10-08 (roadmap item 6; spec `docs/superpowers/specs/2026-10-08-control-center-design.md`,
the authority for everything below; rules `40-widget`, `70-privacy`, `15-project`,
`60-design-system`, `85-testing`).

| | |
|---|---|
| Type | `ControlWidget` — `LogWaterControl`, in `WaterBuddyWidget/LogWaterControl.swift`, `@available(iOS 18.0, *)`; the bundle lists it inside `if #available(iOS 18.0, *)`, the codebase's first version check |
| `kind` | `"WaterBuddyLogWater"` (`LogWaterControl.kind`) — permanent: iOS identifies every placed control by it |
| Configuration | `StaticControlConfiguration(kind:provider:)` |
| Provider | `LogWaterControlProvider` (`ControlValueProvider`, private, file scope): `currentValue()` returns `DataManager.snapshot(now: Date())`; `previewValue` is the default Glass in `.system` |
| Button | `ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving))` — the Glass, from the snapshot |
| Title | *Log Water*, resolved from `snapshot.language.bundle` and handed over as a `String` — the app's chosen language |
| Glyph | `vesselSlots[DataManager.usualSlot].symbol` — `mug.fill`, the slot `usualServing(in:)` reads |
| Gallery strings | `.displayName("Log Water")`, `.description("Adds a serving of water to today's total in WaterBuddy.")` — `AddWaterIntent`'s own, static; iOS draws them, and the Action Button's hint, in the phone's language |
| Figures | **none** — no total, goal, percentage or serving size (rule `70-privacy`) |

**Where it appears.** Control Center (a small tile draws the glyph alone), the Lock Screen's two control
slots, and the Action Button on iPhone 15 Pro and later — one control for all three.

**What keeps it current.** iOS builds the control from a value it reads when it chooses; a reload is
Apple's documented way to have it read again. `DataManager.requestWidgetReload()` — rung by every setter
that can change the Glass or the language — calls `ControlCenter.shared.reloadAllControls()` beside
`reloadAllTimelines()`, inside `#if os(iOS)` and `if #available(iOS 18.0, *)`. Measured on the
simulator: without it, a press made after an edit logged the previous Glass.

**A press** runs `AddWaterIntent.perform()` in the extension, as the widgets' **+** does — through
`chronod`, which on the simulator runs it where `linkd` refuses the widgets' buttons (#63). With
`.alwaysAllowed` it is meant to log without unlocking; whether iOS honours that on a locked iPhone, and
what happens before the first unlock after a restart (#72), is the device check's.

**Proved and not.** On the simulator: offered in the controls gallery, placed, its title following the
app's picker in all three languages, a press logging the stored Glass — an edited one included — and
a mutation run showing the reload is what delivers the edit. **Not proved:** a locked phone, a press
before the first unlock, a Lock Screen slot, the Action Button and VoiceOver (spec §7.4, #75).

## Building it

**The app scheme does not compile the extension's own sources.** A widget-only break passes a green
test run completely untouched — *so rule `40-widget` has it, and it is not what the build does:
see the note at the foot of this section and known issue #69. The command stays in the gate
either way:*

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
                 -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17'
```

Last run 2026-10-14 at 18:10, on the redesign's staged stage 5, with the command above and its own
DerivedData folder, from a `git checkout-index` export of the index (every staged source, test,
tool, string, spec and plan file compared with the export afterwards: none differs; the records
were written after it): `** BUILD SUCCEEDED **`, straight after a clean
`build-for-testing` of the app into the same empty folder, and no warning from `WaterBuddyWidget/`.
The stage changed no file under `WaterBuddyWidget/` and, of the six shared files, only a comment in
`DataManager.swift`. Stage 4's account follows, kept: run 2026-10-14 at 00:13, on the redesign's
staged stage 4, with the command above:
`** BUILD SUCCEEDED **` — before two comment-only edits to `SettingsView.swift`. Stage 4's warning
comparison built this scheme from a `git archive` of `c9d1f6b` and from a `git checkout-index`
export of the index, made at 23:51 on 2026-10-13, each straight after a clean `build-for-testing`
of the app into its own folder: the same 19 distinct warnings by file and message, none from
`WaterBuddyWidget/`. Stage 3c's account follows, kept: run 2026-10-13, on the redesign's staged
stage 3c, with the command above:
`** BUILD SUCCEEDED **`. Stage 3c's warning comparison built this scheme from a `git archive` of
`684f3dd` and from a copy of the working tree, each straight after a clean `build-for-testing` of
the app into its own folder, and each printed the same 19 distinct warnings by file and message
as stage 3's below. The account that follows is stage 3's, kept: run 2026-10-11, on the redesign's
staged stage 3 (on *WaterBuddy Gate 27*, iOS 27.0): `** BUILD SUCCEEDED **`. Stage 3's warning
comparison built this scheme twice more the same day —
from a `git archive` of `e16221e` and from a `git checkout-index` of the staged tree — each into
the build folder the app scheme's `build-for-testing` had just filled, and each printed the same
19 distinct warnings by file and message: twelve in `DataManager.swift`, five in
`NotificationManager.swift`, two in `WaterBuddyWatch/WristView.swift`. The account that follows
is stage 2's, kept: on the redesign's stage 2, then staged: `** BUILD SUCCEEDED **`. The warning
comparison built this scheme twice — from `b8a1386` on 2026-10-10 and from the change on
2026-10-11 — each time into the DerivedData folder that the app scheme's `build-for-testing` had
just filled (that build ended 16 and 9 seconds before this one began), **not an empty one**; it
recompiled all the same (135 Swift compile
tasks). Both builds printed the same **19 distinct warnings, counted by file and message**:
seventeen in `DataManager.swift` and `NotificationManager.swift`, the pre-existing concurrency
baseline (`docs/AI_CONTEXT.md` known issue #29), and two in `WaterBuddyWatch/WristView.swift` —
this scheme's build compiled the app, the watch app and the watch widget as well: **the
checked-in scheme lists `WaterBuddy.app` as a second build entry beside the extension**, and the
app embeds the two watch products (the embedding known issue #69 records for the app scheme).
**Zero originate in `WaterBuddyWidget/`.** Counted the
way `CLAUDE.md` counts — whole lines, with their line and column — the same set is 31 unique
lines and 44 in all, which are `CLAUDE.md`'s two figures.
*(The twentieth pass wrote "a clean build … into an empty DerivedData folder the same day" and
"19 unique warning lines"; corrected in the twenty-first from the saved logs.)*
*(Until the twentieth pass this read "Last run 2026-09-02 … 38 warnings" beside a destination of
`OS=26.5`: the pin moved to 27.0 on 2026-10-10, and 38 was the app scheme's figure on Xcode 26.6.
Not run in the twentieth pass itself.)*

*(Corrected 2026-09-02: this command read `OS=18.6,name=iPhone 16` until then, which had been stale
since the runtime pin moved. Rule `85-testing` is the authority for every gate destination; when the
two disagree, the rule wins and this file changes.)*

**The extension's deployment target is `IPHONEOS_DEPLOYMENT_TARGET = 17.0`** as of 2026-09-02, down
from 26.5 — and it moved because it *had* to. The app target had drifted to 18.6 while the extension
stayed at 26.5, which meant the widget did not exist on any device between those versions: a live
defect in a shipped configuration, invisible to every build and test. Both are now 17.0. The drop
cost no source changes at all, proven by building at both floors and diffing the warning sets.

Neither this nor the unit suite can see a widget that renders blank. After any change to the
widget's view tree, entitlements or target membership, place it on a Home Screen — the Lock Screen
widget on a Lock Screen, and the control in Control Center.

*(2026-10-08: "The app scheme does not compile the extension's own sources", above, is not what the
build does — `build-for-testing -scheme WaterBuddy` compiled `LockScreenWidget.swift` in target
`WaterBuddyWidgetExtension`, because the app embeds the `.appex`. Known issue #69; the sentence mirrors
rule `40-widget`, whose text is the owner's, so it is flagged here rather than rewritten. Seen again on
2026-10-08: `build -scheme WaterBuddy` also compiled both watch targets, which the app embeds too.)*
