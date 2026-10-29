# CLAUDE.md — WaterBuddy Workflow Orchestration

> Project-specific rules live in `.claude/rules/` (auto-loaded by Claude Code).
>
> **Repo layout — one Xcode project, seven targets:**
>
> | Target | Status |
> |---|---|
> | `WaterBuddy/` | **LIVE** — the app: SwiftUI, iOS 17.0 and later (Apple's glass and Apple's tab bar from iOS 26), `@Observable` `DataManager` over SwiftData |
> | `WaterBuddyWidget/` | **LIVE** — WidgetKit extension: three `StaticConfiguration`s over one provider — the Home Screen widget, the week widget (`WeekWidget`, medium, a tap opens History) and the Lock Screen widget (`LockScreenWidget`) — + interactive `AddWaterIntent`, + from iOS 18 the Control Center control (`LogWaterControl`), listed inside the codebase's first `if #available` |
> | `WaterBuddyTests/` | **LIVE** — swift-testing (`@Test` / `#expect`), run in parallel, own suite per test |
> | `WaterBuddyUITests/` | **LIVE** — `GoalSetupUITests` (real coverage), `WelcomeUITests` (the first-run welcome, on a DEBUG fresh start), `PremiumUITests` (Settings' Premium card and the paywall, and History's *Week · Month · Insights* switch, its locked month and its locked Insights — the one class launched with DEBUG's `-WaterBuddyPremium`) plus the Xcode template's launch tests, and `AppStoreScreenshotUITests`, the store capture harness the gate skips |
> | `WaterBuddyWatch/` | **LIVE** — the watch app: `WristView`, `@Observable` `WristModel` over its own local App Group suite (no SwiftData) |
> | `WaterBuddyWatchWidget/` | **LIVE** — the complication's three display-only faces, `.accessoryCircular`, `.accessoryRectangular` and `.accessoryCorner` (`WristFaceView`), each drawing `WristPlan.Face` — the screen's own figures — in the phone's chosen language, with a quiet form when watchOS redacts; reads the watch's own suite directly, never `WristModel.shared` |
> | `WaterBuddyWatchTests/` | **LIVE** — swift-testing, watch side |
> | `Entitlements/` | the App Group entitlement, one file per signed target (four signed targets) |
> | `Tools/` | standalone scripts and pages, in **no** build target — the icon generator, the screenshot harness, and the two pages for the owner's user site: the privacy policy and the support page (`Support.html`, the *Support URL*) |
> | `Screenshots/` | the App Store assets (`en-US/`), in no target; the coverage run writes `census/` beside them when it is run — deleted 2026-10-29, untracked |
> | `AppStore/` | the upload folder, one per version (`1.4/`): `README.md`'s *App Store Connect* text one file per field, and `Screenshots/en-US/` copied and renamed into upload order — a copy, in no target; `README.md` stays the master |
>
> **Every shipping bundle also carries its own `PrivacyInfo.xcprivacy`** — four of them, byte-identical,
> one beside each target's sources. `UserDefaults` is a required-reason API, and since 1 May 2024 an
> upload that does not declare one is **rejected** by App Store Connect. All four bundles compile
> `DataManager.swift`, so all four need it; declaring only the iOS pair still fails. Each target's
> synchronized root group grants membership, so **adding one needs no `project.pbxproj` edit** — and a
> new target added later needs its own, which nothing will remind you of (`docs/STATE.md`,
> rule `15-project`'s *Submission* section). **Since 2026-10-24 they declare a second category, the
> system boot time (`35F9.1`)**: `AuroraClock` has read `ProcessInfo.systemUptime` since stage 3b, and
> nothing noticed until the privacy policy's audit read the code. `PrivacyManifestTests` reads the four
> built manifests and pins what they declare — not what the code calls, so a new required-reason call
> still passes the gate (`docs/AI_CONTEXT.md` #190).
>
> **The privacy policy** is `PRIVACY.md`, published as `Tools/PrivacyPolicy.html` on the owner's user
> site; `PaywallView.privacyPolicy` is its one address, linked from the paywall and from Settings for
> every user. A change that alters what the app stores, sends or shows outside its screens changes the
> policy too (rule `70-privacy`; `docs/superpowers/specs/2026-10-24-privacy-policy-design.md`).
>
> **`DataManager.swift`, `WaterLog.swift`, `WaterSurface.swift`, `LiquidGlassModifier.swift`,
> `ReminderPlan.swift` and `NotificationManager.swift` are compiled into both the app and the
> widget extension** — they live in `WaterBuddy/` and reach
> the extension through the synchronized-folder membership exception in `project.pbxproj`.
> Everything else under `WaterBuddy/` is app-only on the phone (`WristPlan.swift` also reaches the
> two watch targets — below). That shared set is a contract, not a
> convenience: it is what keeps the two front doors logging the same serving and drawing the same
> water.
>
> **The watch is a third, separately-signed process pair with its own local App Group suite** — same
> identifier string (`group.sardor.WaterBuddy`), a different physical container, because the watch
> is a different device. `WaterBuddyWatch` and `WaterBuddyWatchWidget` each carry their own
> `PBXFileSystemSynchronizedBuildFileExceptionSet` (six files each — not the widget extension's own
> six, and not each other's) to reach into `WaterBuddy/` for the parts they need:
> `DataManager.swift`, `LiquidGlassModifier.swift`, `ReminderPlan.swift`, `WaterLog.swift`,
> `WaterSurface.swift`, plus `WristPlan.swift` — which the watch widget gained on 2026-09-01 when
> spec §16 made its complication count pending outbox pours, and which since spec §17 (2026-10-05)
> also decides how long the phone's mirrored total counts: until the phone's own day ends, carried
> on the wire as `WristMirror.phoneDayEnd`. They exchange data with the
> phone solely through `WristLink`'s `WatchConnectivity` session, never through the phone's own App
> Group container (rule `70-privacy`, rule `25-shared-storage`).

## Product context
This repo builds **WaterBuddy** — an iPhone hydration tracker on the arc *log → see → log again
without opening the app*. There is no account and no server.

**Storage is two stores in one App Group on the phone, and which is authoritative is the whole
design:**

| Store | Holds | Read by |
|---|---|---|
| SwiftData — `WaterBuddy.store` | every `WaterLog` (`id`, `amount`, `timestamp`) — the **source of truth** | the app — and, to log a serving only, the extension's `AddWaterIntent` through `DataManager.shared` (which recomputes today and the week from the rows in the same pass); never the widget's draw path |
| `UserDefaults` — eleven keys | today's total, the goal, the day ordinal, three flags, the chosen language, the three quick-add amounts, the phone's applied-pours ledger, the version the app last asked for a rating in, the last seven days' totals — a **derived cache** | the app *and* the widget |

**Today's total is not stored as an authored value.** It is the sum of today's logs, recomputed
after every mutation and written through to the cache. **The widget's draw path never opens
SwiftData** — a
timeline provider is `nonisolated` and a `ModelContext` is not `Sendable`, so reading the cache is
what keeps the widget's read path synchronous. **`DataManager` is the only writer to either of
these two stores** — the one honest weakening (rule `20-state`): the watch is a **third**,
physically separate store (its own local App Group suite of two keys, on the watch device), written
only by `WristModel`, never by `DataManager`. See the target table above and rule
`25-shared-storage`.

Authority for what to build, in order: **the DocC comments on the type you are changing** (they
carry the rulings — why the day is stored as an ordinal and not a `Date`, why a widget process may
never write, why the readability scrim exists) → **`.claude/rules/`** → this file →
**`docs/AI_CONTEXT.md`** for where the work currently stands. The repository is authoritative on
**what exists**, never on what should exist.

Specs and plans for in-flight work live in `docs/`, created by `/doc_sync` the first time there is
something to record.

## Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately — don't keep pushing
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

## Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### Implementation — one loop, tests first
- There is **no implementation subagent.** Planning, test authorship, implementation and review all
  happen in the main loop.
- **Flow:** write the spec → write the failing tests → **run them and verify RED** → implement →
  run them GREEN → review your own diff against the rules → run the full gate.
- Subagents remain available for **research, exploration and parallel analysis** (see above) —
  never for writing implementation code.

### Hard limits
- **A DENIED TOOL CALL IS A STOP SIGN, NEVER A DETOUR.** If a tool refuses an action —
  permission rule, deny list, blocked path — that is the owner declining it. Report it and stop.
  No `Bash` heredoc after `Write` is refused, no `sed -i` after `Edit` is refused, no `python3 -c`
  to route around either. If the denial looks wrong, say so — that is the whole remedy.
- **Never reshape data or weaken an assertion to make a number pass.** If a test and the code
  disagree, STOP and report it. A `#expect` that was narrowed to go green is a deleted test that
  still looks like a test.
- **Never run an ad-hoc script that writes into the real App Group suite**
  (`group.sardor.WaterBuddy`) or into `UserDefaults.standard`. Both are live user data on this
  machine, and `didMigrateFromStandard` is a one-shot flag — burning it by hand is not
  recoverable from inside the app. Tests get their own UUID-named throwaway suite; so does
  anything you run to look at something.
- Run `xcodebuild` in the **foreground**. A build you did not watch finish is not a build you can
  report on.
- **One simulator at a time.** `xcrun simctl shutdown all`, boot the single device you are testing
  on, and always pass `-parallel-testing-enabled NO`. A cloned run writes into a container you
  cannot then read back, which is exactly how a real bug gets mistaken for a broken test
  (rule `85-testing`).

## Self-Improvement Loop
- After ANY correction from the user: append the pattern to `tasks/lessons.md`
- The DocC comments in `DataManager.swift`, `WaterBuddyWidget.swift` and `LiquidGlassModifier.swift`
  are **required reading before touching those files** — they document the cases where the natural
  implementation is wrong and the test suite cannot always see the difference: the stale-instance
  re-read in `addWater`, the extension guards on the migration and the day stamp, the ordering of
  the two writes in `applyDailyReset`, and why a widget's glass cannot use a `Material`
- Write rules for yourself that prevent the same mistake
- Review lessons at session start

## Verification Before Done
- Never mark a task complete without proving it works
- Run the full gate — **five invocations, not two, since the watch shipped** (rule `85-testing` has
  the exact, current commands; do not re-derive them by hand or copy stale ones from memory). One
  simulator at a time, never a cloned parallel run, `xcrun simctl shutdown all` first:
  1. `xcodebuild test -scheme WaterBuddy -only-testing:WaterBuddyTests` — phone unit tests
  2. `xcodebuild test -scheme WaterBuddy -only-testing:WaterBuddyUITests
     -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests` — phone UI tests. The skip is
     **mandatory**: `AppStoreScreenshotUITests` is the App Store capture harness. Its store method
     starts clean on its own through the fresh start, but runs for minutes, fails as it starts
     outside 1:45–11:45 PM or before the 8th of a month, and is driven only by
     `Tools/CaptureScreenshots.sh`, which writes the PNGs into `Screenshots/`; its lived-in method
     fails on any phone that has finished its welcome, and is driven only by
     `Tools/CapturePairScreenshots.sh setup`, on a phone that script makes; its census method is
     still deliberately non-idempotent, and fails on any device where setup has already been
     completed
  3. `xcodebuild test -scheme WaterBuddyWatch -only-testing:WaterBuddyWatchTests` — watch unit tests
  4. `xcodebuild build -scheme WaterBuddyWidgetExtension` — the phone widget, its own scheme
  5. `xcodebuild build -scheme WaterBuddyWatchWidget` — the watch widget, its own scheme (no
     "Extension" suffix — not parallel to the phone widget's scheme name)
  — **no scheme compiles a sibling's sources**, so a widget-only or watch-only break passes a
  green `WaterBuddy`-scheme test run untouched. Both widget builds are as mandatory as the three
  test runs
- Treat every new warning as a failure, on **every** invocation, and a concurrency warning here is a
  Swift 6 error later. **"This codebase compiles clean" is no longer true and was retired on
  2026-09-02.** On **Xcode 27.0** (re-measured 2026-10-05, unchanged on 2026-10-06 and again on
  2026-10-08, and on 2026-10-13 from a clean `build-for-testing` with the six lines in two
  `WaterBuddyTests` files set aside, before and after the redesign's stage 3c, again before
  and after stage 4, and on 2026-10-14 before and after stage 5; the 38 measured on Xcode 26.6
  no longer compares), a clean
  `-scheme WaterBuddy` build into an empty DerivedData folder emits **31** unique warning lines —
  **29 since 2026-10-15**, when roadmap item 1.2.4's `nonisolated` `ReminderScheduler` removed the
  `removePending` and `removeDelivered` lines in `NotificationManager.swift`, measured on the staged
  tree, unchanged by roadmap item 1.2.5 the same day, unchanged by roadmap item 1.2.6 on
  2026-10-17, measured on its staged tree against a clean build of `HEAD`, unchanged by the lag
  fix on 2026-10-18, measured on its working tree against a clean build of a `HEAD` export,
  unchanged by roadmap item 1.3.4 the same day, measured on a copy of its index against a clean build
  of a `HEAD` export, and unchanged by roadmap item 1.3.1's stages 6a and 6b on 2026-10-19, 6b
  measured the same way, and by 6c on 2026-10-20, measured on two copies of its index — before and
  after its final review's fixes — against a clean build of a `HEAD` export, on all four schemes,
  and read again from a clean build of a `HEAD` `06229be` export later that day, before roadmap item
  1.3.2, `-scheme WaterBuddy` alone: 35 = 29 + 6, and unchanged by 1.3.2's stage 7a the same day,
  measured on a copy of its index against a clean build of a `HEAD` `ff7305b` export, on all four
  schemes — the watch's 2 and both widget schemes' 29 included — and unchanged by stage 7b the same
  day, measured on a copy of its index against a clean build of a `HEAD` `ca43a60` export, on all
  four schemes, and again on `WaterBuddy`, `WaterBuddyWatch` and `WaterBuddyWatchWidget` after its
  final review's fix, and unchanged by stage 7c on 2026-10-21, measured on a copy of its index
  against a clean build of a `HEAD` `3d1cda8` export, on all four schemes, and again on those three
  after its final review's fix, and read again on 2026-10-21 from a clean build of a `HEAD`
  `0be24f9` export before roadmap item 1.4.1's code — `-scheme WaterBuddy` 35 = 29 + 6,
  `WaterBuddyWidgetExtension` 29, `WaterBuddyWatch` 2; and 1.4.1's own comparison, on 2026-10-21
  from a clean build of a copy of its index (Tasks 0–6 and the final review's fix), against that
  export, by file and message: **one new line** on `-scheme WaterBuddy` — Apple's own
  `StoreKitTest.framework/Headers/SKTestTransaction.h:34` deprecation, there because the tests import
  `StoreKitTest` — so 36 = 29 + 6 + 1, the owner's to rule (`docs/AI_CONTEXT.md` #160); the widget
  29, the watch 2 and the watch widget 2 unchanged; and read again on 2026-10-21 from a clean build of
  a `HEAD` `b981374` export before set A's step 1's code, by file and message with line numbers
  stripped — `-scheme WaterBuddy` 20 (the `StoreKitTest` line among them), `WaterBuddyWidgetExtension`
  17, `WaterBuddyWatch` 2, `WaterBuddyWatchWidget` 2; and step 1's own comparison, on 2026-10-22 from
  a clean build of a copy of its index (Tasks 3–7, the final review's fixes and the walk's), against
  that export, the same way: unchanged on all four schemes — 20, 17, 2, 2, no line new or gone; and
  read again on 2026-10-22 from a clean build of a `HEAD` `2e2f3a7` export before set A's step 2's code
  — 20, 17, 2, 2 — and step 2's own comparison, on 2026-10-23 from a clean build of a copy of its index
  (Tasks 3–7, the walk's fixes and the final review's), against that export, the same way: unchanged on
  all four schemes — 20, 17, 2, 2, no line new or gone, and the same sites by line; and set A's step
  3's own comparison, on 2026-10-23 from a clean build of a copy of its index against a clean build of
  a `HEAD` `24b2de4` export, the same way: unchanged on all four schemes — 20, 17, 2, 2 by message,
  36, 29, 2, 2 sites by line, none inside the new code; and set A's step 4's own comparison, on
  2026-10-24 from a clean build of a copy of its working tree against a clean build of a `HEAD`
  `5b511bd` export, the same way: unchanged on all four schemes — 20, 17, 2, 17 by message, 36, 29, 2,
  29 sites, none new or gone (the watch widget's 17 the phone app's own, rebuilt into its empty
  DerivedData, on both sides); and set A's step 5's own comparison, on 2026-10-24 from a clean build of a
  copy of its index against a clean build of a `HEAD` `ad244c2` export, the same way, `-scheme WaterBuddy`
  by `build-for-testing`: unchanged on all four schemes — 20, 17, 2, 17 by message, no line new or gone;
  36 sites on the app scheme on both sides; and the privacy policy's own comparison, on 2026-10-24 from a
  clean build of a copy of its index against a clean build of a `HEAD` `4c76e61` export, the same way:
  unchanged on all four schemes — 20, 17, 2, 17 by message, 36, 29, 2, 29 sites, no line new or gone and
  every site on its line; and finishing set A's own comparison, on 2026-10-25 from a clean build of a
  `HEAD` `128630c` export with the change's eleven files laid over it, against a clean build of that
  export, the same way, `-scheme WaterBuddy` by `build-for-testing`: unchanged on all four schemes — 20,
  17, 2, 17 by message, 36, 29, 2, 29 sites, no line new or gone and every site on its line; and the
  store page's own comparison, on 2026-10-25 from a clean build of a `HEAD` `e674d59` export with the
  change's seven Swift files laid over it, against a clean build of that export, the same way: unchanged
  on all four schemes — 20, 17, 2, 17 by message, 36, 29, 2, 29 sites, no line new or gone and every site
  on its line
  — counting primary `file:line:col: warning:` lines only, since Xcode 27 also
  prints a `` `- warning: `` line under each quoted snippet (`tasks/lessons.md`) — 29 outside the
  tests on both, 35 on `HEAD` with the six in two
  `WaterBuddyTests` files (80
  occurrences as counted then; 44 primary lines on 2026-10-08 — occurrences move with the
  architectures a build compiles, the unique lines do not): the *"main actor-isolated …
  cannot be referenced from a nonisolated context"* family in `DataManager.swift` and
  `NotificationManager.swift`, plus two Xcode 27 *"'Combine' was not imported by this file"* warnings
  in `WristView.swift`. The `WaterBuddyWatchWidget` scheme adds two `actool` trait-set warnings on the
  phone's catalogues (known issue #36), in only one of the two architecture sets its clean builds
  alternate between (2026-10-08) — its checked-in scheme builds `WaterBuddy.app` too, so it also
  reprints the phone targets' Swift warnings whenever they had to rebuild. All are **pre-existing** —
  proven by building the code from before a change and
  comparing, never assumed. They are invisible to an incremental build, which is how "compiles
  clean" survived so long. The rule is therefore *no **new** warnings against a baseline measured by
  a clean build on the current toolchain*, compared per file and message, and closing the baseline is
  its own task (`docs/AI_CONTEXT.md` known issue #29)
- **A green suite is not proof the product works.** The suite injects its own `UserDefaults`,
  `Calendar` and clock, so it structurally cannot see an entitlement that was not added, a file
  missing from a target, or a widget that renders blank. Run the app on the simulator and put the
  widget on the Home Screen after any change to storage, entitlements, target membership or the
  widget's view tree — the Lock Screen widget on the Lock Screen too, the control in Control
  Center, the week widget on the Home Screen and tapped into History, and the same for the watch's
  three faces, a tinted watch face among them, which no part of the automated gate renders — on
  Modular or Infograph, since the default Numerals Duo has no complication slots
  (`tasks/lessons.md`, 2026-10-21). On the simulator the gallery
  offers no widget of an app that has not run, and a placed widget redraws from a new build after
  `xcrun simctl install`, not after `xcodebuild test`'s own install (`tasks/lessons.md`, 2026-10-20).
  The small widget's StandBy layout cannot be placed at all on a simulator, which has no StandBy:
  draw it through its `#Preview`, and take it into StandBy on a device, by day and at night
- Ask yourself: "Would a staff engineer approve this?"

## Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes — don't over-engineer
- Challenge your own work before presenting it

## Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests — then resolve them
- Zero context switching required from the user
- Go fix a failing build without being told how

## Task Management
1. **Plan First**: Outline the plan with checkable items before implementing
2. **Verify Plan**: Check in before starting implementation
3. **Track Progress**: Mark items complete as you go
4. **Explain Changes**: High-level summary at each step
5. **Document Results**: Summarize outcomes when done
6. **Docs Cascade**: After code changes, run `/doc_sync` per rule `99-docs-cascade`

## Architecture — One Writer, Two Front Doors
- **`DataManager` is the only writer.** Every mutation of the phone's two stores goes through one
  of its methods — `addLog` / `addWater` / `removeWater` / `deleteLog` / `undoLog` / `updateLog` /
  `saveDailyGoal` / `resetIfNeeded` / `dayDidTurn` / `resetDailyProgress` / `refresh`, and
  `ingest` for a pour the watch sent, and `claimReviewRequest` for the rating request's mark — or
  one of its setters; construction and the launch-time
  `prepareSharedStorage()` do the group's bookkeeping. On the phone no view, no intent and no
  provider reaches `UserDefaults` directly (rule `20-state` lists the surface, `ingest` aside);
  the watch's complication reads the watch's own suite itself, as the target table says
- **Two front doors, one serving — now by a shared read, not a shared constant.** The quick-add
  vessels are user-editable, and the middle one is what the widget's button logs and its face
  draws. Both doors resolve it from `Key.servings` in the App Group suite, carried to the extension
  by `WaterSnapshot.serving`. `defaultServing` (formerly `standardServing`) is only the fallback
  and the middle of `defaultServings`; a widget that logged a different amount is still a bug the
  user could only find by arithmetic, and the key is what prevents it (rule `20-state`). **The Siri
  phrase is a third way in to the same serving:** "Log water in WaterBuddy" runs `LogServingIntent`,
  app-only, in the app's own process, and logs `DataManager.usualServing(in:)` — the one definition
  of the middle vessel, which the widget's snapshot reads too
  (`docs/superpowers/specs/2026-10-07-siri-phrase-design.md`). **The Control Center control is a
  fourth:** `LogWaterControl` runs `AddWaterIntent(amount: snapshot.serving)` from the same snapshot,
  draws the glyph at `DataManager.usualSlot` — the one name for that vessel's index — and is kept
  current by `requestWidgetReload()`'s `reloadAllControls()`
  (`docs/superpowers/specs/2026-10-08-control-center-design.md`). **A reminder's *Log a Glass* is a
  fifth:** pressed on the notification, it runs `LogServingIntent.logTheGlassInTheBackground()` in
  the app's own process through `ReminderResponder`, without opening the app — proved on the iPhone
  simulator; from Apple Watch and on a locked phone it is built for but device-unproven
  (`docs/superpowers/specs/2026-10-15-log-from-a-reminder-design.md`, `docs/AI_CONTEXT.md` #133)
- **`addLog` is how a logged serving enters.** (Two other paths insert rows: `ingest` for a pour
  the watch sent, and the one-shot seed from a cached total.) `addWater(amount:)` is a synonym kept for the two callers that
  log the usual serving — the widget's `AddWaterIntent` and the Siri shortcut's `LogServingIntent`;
  `HomeView`'s row offers three vessels and calls `addLog` directly. It returns the id of the row
  it inserted, which is what Home's *Undo* hands back to `undoLog(id:)` — a view holds the id,
  never the row
- **Today's total is derived, never authored** — `recomputeToday()` sums today's logs and writes
  the figure through the `currentWater` setter, so the clamp, the equality guard and the widget
  doorbell all still fire exactly once per real change (rule `20-state`)
- **Mutate only after a re-read.** `addLog` and `removeWater` call `refresh()` first — its private
  form, `refresh(republishingMonth: false)`, which re-reads everything but History's shown month, left
  to the save after the write (the owner's read-once ruling, 2026-10-22). Two
  processes hold their own `DataManager`, and an instance that has been idle would otherwise
  compute `staleTotal + amount` and write it over a newer figure (rule `20-state`)
- **The widget reads through `WaterSnapshot`, never through `DataManager.shared`.** A timeline
  provider is `nonisolated` and cannot touch a `@MainActor` singleton — and *constructing* a
  `DataManager` there could still roll the day over (zero the total, stamp the day, ring the
  widget doorbell) and recompute today from the rows, none of which is guarded: writes from a
  process whose job is to draw (rule `40-widget`). **Siri's question reads the same snapshot:**
  "How much water today in WaterBuddy" runs `TodaysWaterIntent`, app-only, which answers from
  `DataManager.snapshot()` — today's total and what is left, through `WaterSnapshot.remaining` and
  `hasReachedGoal` — writes nothing, and answers a locked iPhone only after authentication
  (`docs/superpowers/specs/2026-10-18-todays-water-design.md`, rule `70-privacy`). It is the one Siri
  reply that carries figures; *Log a Glass*'s stays fixed and digit-free. **The week widget reads it
  too:** `WaterSnapshot.weekTotals`, the cached `Key.weekTotals`, drawn through
  `week(endingOn:calendar:)` with today taken from the total; its tap opens History through
  `WidgetLink.history`, answered by `AppTab(link:)` — no URL scheme registered
  (`docs/superpowers/specs/2026-10-19-the-widget-stage-design.md`)
- **The week is cached, never authored.** `Key.weekTotals` is rewritten from the rows exactly where
  today's total is recomputed — `init` and `saveAndRecompute()`, through `recomputeTodayAndTheWeek()`,
  in the app and the widget extension alike, so the extension's tap the morning after keeps
  yesterday. Never by `refresh()` or `dayDidTurn()`, never from a failed read, never when unchanged;
  each day clamped on the way in and the whole week validated on the way out. One widget doorbell a
  pass: the `currentWater` setter rings for today, the week only when it was missing or a past day
  moved (rule `20-state`)
- **Only the app writes on behalf of the group.** Materialising the goal, stamping the day on a
  fresh install, the one-shot migration, the seed from a cached total, drawing the history, the
  streak, History's shown month, its week's insights and a finished month's recap, and filing reminders
  are all guarded by `DataManager.role` — ten sites, the seventh the redesign's stage 2's, the eighth
  set A's step 2's (`republishMonth()`), the ninth set A's step 4's (`republishInsights()`), the tenth
  set A's step 5's (`recap(of:)`, a read that publishes nothing) — a four-state
  `nonisolated static let` (`.phoneApp`, `.phoneExtension`, `.watchApp`, `.watchExtension`) that
  replaced the two-state `isAppExtension` at every guard site on 2026-08-31. A grep for
  `!Self.isAppExtension` now returns zero. An extension that stamped an empty group would
  manufacture exactly the state the migration checks for; a *watch* would do the same and is not
  caught by an `.appex` test at all, which is why the question has four answers
  (rule `25-shared-storage`, `docs/STATE.md`)
- **Layer boundaries are sacred** — view → `DataManager` → SwiftData + `UserDefaults`. Views own presentation
  state and nothing else; arithmetic the app and the widget both show belongs on `DataManager` or
  `WaterSnapshot`, not in a `body`
- **Reminders are scheduled from a pure plan** — `ReminderPlan` decides *when* (a pure value, no
  `UserNotifications`), `NotificationManager` only files and unfiles, and neither ever calls
  `removeAllPendingNotificationRequests()`: from the extension that would clear the app's entire
  set (rule `80-notifications`)
- **Premium is read, never stored.** `PremiumStore` reads StoreKit for the app alone and writes
  neither store; StoreKit is imported in `HomeView.swift` and `PremiumStore.swift` only (rule
  `70-privacy`, rule `10-architecture`)
- **Insights: the app decides, Apple's model only words it.** `WeekInsights`, a pure value in
  `DataManager.swift`, decides what the last finished week says, published while History asks
  (`showInsights(_:)`); `InsightCopy` writes it as the app's own sentences; `InsightWriter`, app-only
  and the one file that imports `FoundationModels`, may hand those English sentences — never a row —
  to `SystemLanguageModel.default` on the phone, keeps its note in memory and draws it only if no part
  adds a figure its fact lacks. Writes neither store
  (`docs/superpowers/specs/2026-10-23-insights-design.md`; rule `70-privacy`'s *FoundationModels, for
  the insights*)
- **The recap: a finished month, read when asked, shared on the user's tap.** `MonthHistory.recap`
  names the month a page offers — a finished month with water on seven days, or the month before's for
  the new month's first seven days — and `DataManager.recap(of:)` reads it once for `RecapSheet`,
  publishing nothing and writing neither store, behind `role.drawsHistory`. `RecapCard`, app-only, is
  drawn and rendered by `ImageRenderer` (1,080 px, the default text size) and shared through `ShareLink`
  in memory; the best streak is drawn beside it, never on it. iOS offers *Save Image* only to an app with
  a Photos usage key, which this one never carries (measured)
  (`docs/superpowers/specs/2026-10-24-monthly-recap-design.md`; rule `70-privacy`'s *The recap's image, on
  the user's own tap*, admitted in `4c76e61`)
- **Import direction**: the widget may import from the shared six; nothing shared may import
  from the widget or from `HomeView`

## Storage — SwiftData, cached in the App Group
- **The App Group holds both stores** — `group.sardor.WaterBuddy`, declared in `Entitlements/` on
  all four signed targets (the phone's two share this container; the watch's two resolve the same
  identifier on another device): the SwiftData file `WaterBuddy.store` **and** the `UserDefaults`
  suite.
  `UserDefaults(suiteName:)` returns a working object even when the entitlement is missing, so the
  container URL is the real probe for both; without it the app silently degrades to private
  storage and the widget goes blank (rule `25-shared-storage`)
- **`WaterLog` is the source of truth; the cache is derived from it.** They cannot
  drift silently — the cache is rewritten from the logs after every mutation, so a disagreement
  means the log side is already wrong
- **A failed read must never be written back.** `recomputeToday()` leaves the total exactly as it
  stands when the store cannot be read. Returning `[]` from a failed fetch once turned a transient
  failure into permanent, persisted data loss (rule `20-state`)
- **A `timestamp` is a `Date` and the *day* is still an ordinal.** Those are not in conflict: an
  instant records a moment, which does not move; a stored *day* would be re-read under whatever
  time zone is current. `fetchLogsForToday()` derives its bounds from `Calendar.waterBuddyDay`,
  the same calendar the ordinal uses (rule `30-rollover`)
- **The quick-add amounts are stored, not compiled in.** `Key.servings` is a positional `[Int]` of
  exactly three; index 1 is the vessel the widget follows. Absence means the user kept the defaults,
  so it is never materialised, and any anomaly discards the whole triple rather than repairing one
  element (rule `20-state`)
- **Keys are namespaced and centralised** in `DataManager.Key` — an App Group domain is shared by
  every target that joins it, so an un-prefixed key is a collision waiting for the next extension
- **The day is stored as an ordinal (`yyyyMMdd`), never as a `Date`** — an instant has to be
  re-read under whatever time zone is current, and a user flying west would have a day of water
  wiped on a date that never changed (rule `30-rollover`)
- **Reset writes the zero before it stamps the day.** A crash between the two leaves a stale
  marker that simply resets again; the opposite order launders yesterday's water into today
  (rule `30-rollover`). It clears only the **cache** — no `WaterLog` row is touched, so yesterday
  stays as history and `resetDailyProgress()` is the only **reset** path that deletes rows
  (`deleteLog`, `undoLog` and `removeWater` delete rows as ordinary edits)
- **Every value is clamped on the way in** — `0...maximumDailyIntake` for the total, `1...` for the
  goal, so a corrupt suite cannot divide by zero or overflow the running figure

## Core Principles
- **Simplicity First**: Make every change as simple as possible. Impact minimal code.
- **No Laziness**: Find root causes. No temporary fixes. Senior developer standards.
- **Minimal Impact**: Changes should only touch what's necessary. Avoid introducing bugs.
- **Fail Soft, Loudly**: The app degrades rather than crashes — a missing App Group falls back to
  private defaults, a corrupt goal falls back to the default — but every fallback says so in
  `DEBUG` and is covered by a test.
- **Explicit Over Implicit**: No magic. If behavior isn't obvious from reading the code, add a
  comment or rename things until it is. This codebase explains *why*, not *what* — match it.
- **No bare `print`** — diagnostics go inside `#if DEBUG`, and never carry user data
  (rule `75-diagnostics`)
- **No unpinned `Date()` in logic** — the clock is injected (`now: () -> Date`) so the rollover is
  testable without waiting a day
- **No floating-point millilitres** — volumes are `Int`, and `Double` appears only as a drawing
  fraction (`progress`)
- **Never let workflow config into the app bundle** — `CLAUDE.md` and `.claude/**` are never
  members of a build target (rule `15-project`)
- **Never commit until the owner runs `/commit`** — stage the work and stop

## Commands
`/start_task` `/add_feature` `/fix_bug` `/review` `/doc_sync` `/log` `/commit`
