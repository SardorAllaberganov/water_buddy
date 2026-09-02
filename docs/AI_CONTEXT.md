# AI_CONTEXT — WaterBuddy

Orientation for anyone (human or model) picking this repo up cold.
Authority order is unchanged: **DocC on the type you are changing** → `.claude/rules/` →
`CLAUDE.md` → this file. This document records *where the work stands*, never what the rules say.

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

## Targets

| Target | Bundle id | Sources | Status |
|---|---|---|---|
| `WaterBuddy` | `sardor.WaterBuddy` | `WaterBuddy/` | **LIVE** — SwiftUI, `@Observable` `DataManager` over SwiftData |
| `WaterBuddyWidgetExtension` | `sardor.WaterBuddy.WaterBuddyWidget` | `WaterBuddyWidget/` **+ 6 shared files** | **LIVE** — `StaticConfiguration`, interactive `AddWaterIntent` |
| `WaterBuddyTests` | `sardor.WaterBuddyTests` | `WaterBuddyTests/` | **LIVE** — swift-testing, 300 `@Test` functions in 33 suites |
| `WaterBuddyUITests` | `sardor.WaterBuddyUITests` | `WaterBuddyUITests/` | **LIVE** — `GoalSetupUITests` (7 real tests), the Xcode template's 3, and `AppStoreScreenshotUITests`' 2 capture harnesses. **12 declared, 25 executed** — the 2 harnesses are skipped by the gate, and `testLaunch` runs once per launch configuration |
| `WaterBuddyWatch` | `sardor.WaterBuddy.watchkitapp` | `WaterBuddyWatch/` **+ 6 shared files** | **LIVE** — SwiftUI, `@Observable` `WristModel` over its own local App Group suite; no SwiftData |
| `WaterBuddyWatchWidget` | `sardor.WaterBuddy.watchkitapp.WaterBuddyWatchWidget` | `WaterBuddyWatchWidget/` **+ 6 shared files** | **LIVE** — `.accessoryCircular` percentage ring, reads the watch's own suite directly |
| `WaterBuddyWatchTests` | `sardor.WaterBuddyWatchTests` | `WaterBuddyWatchTests/` | **LIVE** — swift-testing, 29 `@Test` functions in 5 suites |

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

**`WaterBuddyWatchWidget`'s own set (five files, a minimal subset of the watch app's):**

```
DataManager.swift
LiquidGlassModifier.swift
ReminderPlan.swift
WaterLog.swift
WaterSurface.swift
```

Omits both `NotificationManager.swift` (same reason) and `WristPlan.swift` — the widget reads
`DataManager.sharedDefaults`/`Key.wristMirror` directly and never buckets pours itself.
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
WaterBuddy/DataManager.swift                    2223   shared — the model, the log CRUD, the cache, WaterSnapshot, DaySummary, AppLanguage, the four-state Role, the Wrist wire structs, WristLink (behind #if canImport(WatchConnectivity))
WaterBuddy/GoalSetupView.swift                   283   app only — first-run goal setup
WaterBuddy/Haptics.swift                          53   app only — the three-rung feedback ladder
WaterBuddy/HistoryView.swift                     672   app only — the week card, today's log, swipe-to-delete, the serving editor
WaterBuddy/HomeView.swift                        379   app only — the vessel, the editable quick-add row, the goal burst (vesselSlots moved out, Task 14)
WaterBuddy/LiquidGlassModifier.swift             501   shared — design tokens + the glass modifier
WaterBuddy/NotificationManager.swift             203   shared — ReminderScheduler + reconcile; the only UN caller
WaterBuddy/PressStyle.swift                       31   app only — the shared press recoil
WaterBuddy/ReminderPlan.swift                    121   shared — WHEN to remind, as a pure value
WaterBuddy/RootTabView.swift                     260   app only — AppTab (3 cases), the container, the glass tab bar (the 420pt cap's comment rewritten 2026-09-02: it justified itself in iPad measurements, and iPad is gone — the cap is kept, because 420 is below the widest iPhone's content width)
WaterBuddy/SettingsView.swift                    658   app only — the goal editor, the vessel editor, reminders, the language picker
WaterBuddy/WaterBuddyApp.swift                   108   app only — RootView, the setup gate, the strings/locale injection, WristInbox.shared + WristLink.live.activate() at launch
WaterBuddy/WaterLog.swift                         57   shared — the SwiftData @Model, source of truth
WaterBuddy/WaterSurface.swift                    194   shared — waves, scrim, Aurora palette, vesselSlots (moved in from HomeView, Task 14 — a second, non-view consumer: WristView)
WaterBuddy/WristInbox.swift                       90   app only, NOT shared — reassembles chunked WristBatch payloads (wrist → phone), calls DataManager.ingest(_:)
WaterBuddy/WristPlan.swift                        37   shared (in the watch's own exception set, not the widget's) — the watch's pure day-bucketing twin to ReminderPlan
WaterBuddyTests/AppLanguageTests.swift           112   AppLanguageTests — the menu and each bundle
WaterBuddyTests/AuroraBackgroundTests.swift       98   AuroraLightTests — the backdrop's lights
WaterBuddyTests/CelebrationTests.swift           108   HapticLadderTests + ConfettiTests
WaterBuddyTests/DataManagerTests.swift          1232   DataManagerTests + DailyGoalSetupTests + ReminderSeamTests + LanguageSeamTests
WaterBuddyTests/HistoryRangeTests.swift          439   DaySummaryTests (pure, not @MainActor) + HistoryWindowTests
WaterBuddyTests/HistoryViewTests.swift           132   HistoryServingTests — the editor's offered range, and the fixture's own tripwire
WaterBuddyTests/HomeViewTests.swift              180   HomeServingTests — the quick-add row's offered vessels
WaterBuddyTests/LiquidGlassTests.swift           135   LiquidGlassInteractionTests + LiquidGlassBaseTests — the press response
WaterBuddyTests/LocalizationTests.swift          345   both bundles' string tables, en/ru/uz
WaterBuddyTests/NotificationManagerTests.swift   215   applying a plan, against a spy scheduler
WaterBuddyTests/ReminderPlanTests.swift          180   the plan — pure, and no UserNotifications import
WaterBuddyTests/RootTabViewTests.swift            70   AppTabTests — the tab bar's offered destinations
WaterBuddyTests/ServingSeamTests.swift           279   ServingResolutionTests (pure, not @MainActor) + ServingSeamTests
WaterBuddyTests/WaterLogTests.swift              504   WaterLogStoreTests — one makeManager factory is the file's only DataManager( site
WaterBuddyTests/WaterSnapshotTests.swift         565   WaterSnapshotTests + WidgetLanguageTests + ProcessRoleTests
WaterBuddyTests/WristSyncTests.swift             661   WristWireTests + WristIngestTests + WristPlanTests + WristInboxReassemblyTests + WristPublishTests + WristLinkDecodingTests + WristLinkChunkingTests
WaterBuddyUITests/AppStoreScreenshotUITests.swift  541   NOT a test — the App Store capture harness. Two methods, both deliberately non-idempotent and both SKIPPED by the gate (`-skip-testing:`): the 4-shot store set and the 25-shot full census
WaterBuddyUITests/GoalSetupUITests.swift         245   setup, the a11y tree, the tab swap, the Settings tab, the week card
WaterBuddyUITests/WaterBuddyUITests.swift         41   template
WaterBuddyUITests/WaterBuddyUITestsLaunchTests.swift   33   template
WaterBuddyWidget/AddWaterIntent.swift            138   writes: runs DataManager in the extension
WaterBuddyWidget/WaterBuddyWidget.swift          590   reads the cache only, never SwiftData
WaterBuddyWidget/WaterBuddyWidgetBundle.swift     17
WaterBuddyWatch/WaterBuddyWatchApp.swift          54   watch app only — activates WristLink.live, hosts WristView, .backgroundTask(.watchConnectivity)
WaterBuddyWatch/WristAurora.swift                 48   watch app only — WidgetAurora's proportional-geometry shape, mirrored for the watch canvas
WaterBuddyWatch/WristModel.swift                 222   watch app only, NOT shared — @Observable @MainActor, the watch's only writer to its own local suite
WaterBuddyWatch/WristVessel.swift                 88   watch app only — the one vessel, WaterSurface + WaterReadabilityScrim + readout; NOT self-describing to VoiceOver since it became a Button's label
WaterBuddyWatch/WristView.swift                  432   watch app only — the one screen: the vessel IS the pour button, one "More" button over a sheet, "Synced Nm ago"
WaterBuddyWatchTests/WristLinkCompileTests.swift  21   compile-time canary — WristLink stays non-@MainActor and Sendable
WaterBuddyWatchTests/WristModelTests.swift       172   WristModelTests — pour, apply, isMirrorStale, todaysTotal, reconstruction
WaterBuddyWatchTests/WristPlanCompileTests.swift  20   compile-time canary — WristPlan stays free of actor isolation
WaterBuddyWatchTests/WristVesselLayoutTests.swift 49   diameter(fitting:within:) against five real watch width/height pairs
WaterBuddyWatchTests/WristViewLogicTests.swift   149   the pure logic WristView composes — servings resolution, which one the vessel pours, what the menu gets, attribution
WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift 71   .accessoryCircular percentage ring — reads DataManager.sharedDefaults/Key.wristMirror directly, never WristModel.shared
WaterBuddyWatchWidget/WaterBuddyWatchWidgetBundle.swift 9
```

**53 `.swift` files across the seven target folders**, all listed above. Re-derived 2026-09-02 with
`find` over all seven and a two-way `comm` against the table: no undocumented file, no phantom row.
Every line count above was re-checked against `wc -l`, not spot-checked — one was stale
(`RootTabView.swift`, 252 → 260) and 51 were current.

### Outside every target

`Tools/` sits outside all seven `PBXFileSystemSynchronizedRootGroup`s, so nothing in it is compiled
into anything (rule `15-project`). It is **not** part of the 53 above, which is why earlier passes'
"every file is documented" claim was true while omitting it:

```
Tools/GenerateAppIcon.swift                      267   generates the three iOS icon variants at 1024². Run: swift Tools/GenerateAppIcon.swift. Does NOT own the watch icon — see known issue #34
Tools/FlattenPNG.swift                            99   re-encodes a PNG to colour type 2, RGB untouched. Required for every watch capture: simctl writes RGBA on watchOS even with --mask=ignored
Tools/CaptureScreenshots.sh                        —   the iPhone App Store set. WATERBUDDY_SCREENSHOT_SLOT picks iPhone-6.9 (default) or iPhone-6.5
Tools/CaptureFullCensus.sh                         —   the 25-shot coverage run, every screen/state/scroll position
Tools/CaptureWatchScreenshot.sh                    —   the watch capture. WATERBUDDY_SCREENSHOT_NOWAIT=1 shoots the empty state unattended
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
Screenshots/en-US/iPhone-6.9/*.png                4    the 6.9" store set, 1320x2868
Screenshots/en-US/iPhone-6.5/*.png                4    the 6.5" store set, 1284x2778
Screenshots/en-US/AppleWatch/01-wrist.png         1    416x496 — the empty state (known issue #32)
Screenshots/census/iPhone-6.9/*.png              19    coverage run, 1260x2736 — NOT store assets
Screenshots/census/AppleWatch/*.png               9    coverage run, five sizes plus four driven states
```

The four `PrivacyInfo.xcprivacy` files are a **submission blocker**, not paperwork: `UserDefaults` is
a required-reason API and Apple does not accept an upload that fails to declare one. See rule
`15-project`'s *Submission* section for the reason codes and why all four bundles need their own.

`AuroraBackground` and `PressStyle` were `private` inside `HomeView.swift` until `GoalSetupView`
became a second consumer. They are **app-only**: the widget re-expresses the same lights itself in
`WidgetAurora`, because the app's absolute ±240pt offsets mean nothing on a 158pt canvas. Only the
colours in `Aurora` are shared between the two processes.

Plus `Entitlements/WaterBuddy.entitlements`, `Entitlements/WaterBuddyWidgetExtension.entitlements`
(both declaring `group.sardor.WaterBuddy`) and `WaterBuddyWidget-Info.plist`
(`NSExtensionPointIdentifier = com.apple.widgetkit-extension` only).

And four non-Swift build inputs, plus one file that is deliberately *not* one:

| | |
|---|---|
| `WaterBuddy/Localizable.xcstrings` | **58** keys — 54 translated into en/ru/uz, 4 deliberately not (`%`, `+%lld`, `1,450 ml`, `WaterBuddy`). The explicit `en` values are what make the build emit an `en.lproj` to select |
| `WaterBuddyWidget/Localizable.xcstrings` | **19** keys — 10 hand-written as a strict subset of the app's (a membership exception cannot carry a resource), plus **9 the build extracted**, all untranslated. Five of those nine are `AddWaterIntent`'s Shortcuts vocabulary — known issue #1 |
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
    a constant would fail it.
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
    their own, with different membership (six, six, and five files respectively — see *The six
    shared files* above). A file reaching one target through its set is invisible to the other two
    unless it is also listed in theirs.

## The process role

`DataManager.role` (`DataManager.swift:1149`) resolves once, `nonisolated static let`, from
`isAppExtension` plus `#if os(watchOS)` — never a second runtime probe, which rule
`25-shared-storage` forbids because two probes can disagree and leave one guard open.

```
enum Role: Sendable, CaseIterable {   // DataManager.swift:1158
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
| `ownsSharedStorage` | *is this container my own first-class home?* | `:420` goal materialisation, `:760` fresh-install day stamp |
| `mayHaveLegacyStandardDefaults` | *has my `.standard` ever held WaterBuddy state?* | `:691` `seedFromCachedTotalIfNeeded`, `:1175` `migrateIfNeeded` |
| `drawsHistory` | *do I have a history surface to draw?* | `:627` `republishHistory` |
| `mayFileReminders` | *may I file notifications for this user?* | `:847` `requestReminderReschedule` |

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
  exercises a real pairing.
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

**There is a git repository.** Verified this pass:

```
$ git rev-parse --short HEAD
6cee506
$ git log --oneline | wc -l
      27
$ git status --short
(clean, aside from the final-review fix round's own in-progress work)
```

Initialised under scoped, explicit owner authorization to enable the watchOS plan's SDD execution
process (root commit `69c5a39`), overriding the "owner declined twice" stance the design spec had
recorded — the authorization is in-conversation, scoped to this execution. 27 commits on `main`,
root through the watchOS plan's own work; `.gitignore` exists and lists `build/`, `DerivedData/`,
`**/xcuserdata/`, `.DS_Store` and `.claude/settings.local.json`, and does **not** ignore
`xcshareddata/`, matching rule `90-git`'s own requirement.

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

1. **`AddWaterIntent`'s Shortcuts vocabulary is untranslated.** Found by the `/doc_sync` pass on
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
   clears it if a clean first-run state is wanted.
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
11. **The DocC on `refreshRepublishesLogsWrittenByAnotherInstance` describes code that is not
   there.** `WaterLogTests.swift:404` says it "Pins the `recomputeToday()` in
   ``DataManager/refresh()``" and reasons about "the re-derive". `refresh()` calls
   `loadFromStore()` → `resetIfNeeded()` → `republishTodaysLogs()` → `republishHistory()` →
   `rescheduleRemindersNow()`, and **not** `recomputeToday()` — while `republishTodaysLogs()`' own
   DocC records that making `refresh()` recompute was *tried and rejected* because it destroys
   water. The test is green for a different reason than its comment gives (`loadFromStore()` picks
   the cached total back up). DocC outranks the rule files in this repo, so a comment describing a
   rejected design is actively misleading.
12. **This document claimed `GoalSetupUITests` pins orientation in `setUp`. It does not.** There is
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

16. **Three DocC comments in `DataManager.swift` were left stale by the role model.** Identified
   2026-09-01; **still not fixed** — this is a documentation-only task and may not touch source
   (`.claude/rules/00-workspace.md`'s "no source, test, or project file changes"). Line numbers
   below re-verified against the tree as it stands after the watchOS plan; the underlying code
   they describe is unchanged, only its position shifted as ~500 lines landed above it.
   - `:721` (was `:614`) — *"Guarded on `isAppExtension`"*, above a body that reads
     `Self.role.drawsHistory`. This is known issue #11's exact shape: DocC outranks the rule files
     here, so a comment naming a symbol the code no longer uses actively misdirects.
   - `:949` (was `:842`) — *"Returns immediately in an extension"*, at the `mayFileReminders` site.
     Now also true of a watch, which is the entire point of the role model.
   - `:727` (was `:620`) — *"none of the seven cache keys"*; `Key.all` holds **eleven** now (was
     eight). Pre-existing since the `servings` key, not caused by the role model or the watch.

17. ~~**The role model is half-built by its own design's account.**~~ **Retired 2026-09-01.**
   Task 2 of the watchOS plan added the three `@available(watchOS, unavailable)` markers this issue
   named as missing — `grep -c '@available(watchOS, unavailable' WaterBuddy/DataManager.swift` now
   returns **3**, on `shared`, `sharedModelContainer`, and `init`. All six guard sites the role
   model gates are now unreachable by *compilation* from watchOS, not merely by discipline, per
   `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §3.2.

18. **`WristView` draws hardcoded English throughout rather than routing through `\.strings` — and
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

19. **`WristMirror.languageCode` is a dead wire field.** `composeWristMirror` writes it
   (`resolveLanguage(in: defaults).code`), but nothing reads it anywhere under `WaterBuddyWatch/` or
   `WaterBuddyWatchWidget/` — the watch draws hard-coded English regardless (known issue #18, above).
   The field is not wrong, just unconsumed; wiring it up is the natural first step of actually fixing
   #18, not a separate feature.
20. **Four independent implementations of the identical percentage-rounding formula**
   (`Int((… * 100).rounded())`): `HomeView.percentage`, `WaterSnapshot.percentage`,
   `WristView.vessel(boxedInto:)`'s inline vessel percentage (it was `WristView.body`'s until the
   2026-09-01 redesign moved it into that method; the copy itself is unchanged), and
   `WaterBuddyWatchWidget.WristWidgetProvider
   .currentEntry()`. All four currently agree by coincidence of being copied correctly, not by
   sharing one definition — rule `50-views`'s "a third copy is a bug waiting to round differently"
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
25. **`WaterBuddyWatchWidget`'s `Gauge` is fed a percentage clamped only at the low end.**
   `WristWidgetProvider.currentEntry()` clamps to `min(999, max(0, percentage))` — the `Gauge(...,
   in: 0...100)` itself will visually cap the ring, but the printed `currentValueLabel` text can
   still read above 100 for an overachieving day, which the phone widget's own equivalent readout
   does not do.
26. **`WaterBuddyWatchWidget`'s `TimelineProvider` never applies the day-ordinal rollover, and
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

27. **`WristServingMenu` — the sheet holding the other two servings — has never been rendered by
   anyone.** It compiles, its contents come from `WristView.secondary(from:)` which is unit-tested,
   and the whole screen was rendered on a 46mm and a 40mm — but the "More" button was never
   *pressed*, because `simctl` has no tap primitive for watchOS and this project has no watch UI-test
   target. So the sheet's own layout, its glass capsules, its aurora backdrop and its dismiss
   behaviour are all unverified by eye. This is the same class of gap rule `85-testing` already
   names for both widgets' rendering — "proved only by placing them and looking" — and the remedy is
   identical: one human tap on a simulator or a watch.

28. **The "More" button now sits below the fold at rest on every watch size, and that it is reachable
   by crown is argued rather than observed.** `vesselHeightFraction` is `0.78125` after two
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
    - **Why a human is unavoidable.** `simctl` has no tap, touch or click primitive for watchOS —
      re-verified against `simctl help` this pass, which offers `io` (screenshot, recordVideo,
      enumerate, poll) and `ui` (appearance, contrast, content size) and nothing that touches the
      screen — and Apple has never shipped XCUITest for watchOS, so there is no UI-test target to
      write. Same root cause as #27.
    - **Getting rid of the caption is a further step still.** Pouring locally raises the number but
      not the caption; only a real `WristMirror` arriving from a paired, booted iPhone simulator
      clears it, which is a manual setup no part of the gate performs.
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

35. **The watch vessel does not scale its readability scrim, and it shipped that way.**
    `WristVessel.swift:39` passes `WaterReadabilityScrim` at the default `intensity: 1` — the
    full-strength *app* value. Rule `60-design-system` says a small canvas scales the scrim with the
    level (`min(1, level * 1.6)`), and `WaterSurface.swift`'s own DocC gives the reason: "at 0% there
    is nothing bright to hold back and a full scrim only turns the vessel into a black hole." The
    phone widget's `MiniVessel` does scale it. The watch does not, and the consequence is visible in
    a shipped asset: compare `Screenshots/census/AppleWatch/01-series11-46mm.png` (0%, a near-black
    disc) against `06-wrist-water-63pct.png` (bright and legible). Found by looking at the captures,
    which is exactly the class of defect rule `85-testing` says no green suite can see.

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
