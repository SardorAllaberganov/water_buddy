# CLAUDE.md — WaterBuddy Workflow Orchestration

> Project-specific rules live in `.claude/rules/` (auto-loaded by Claude Code).
>
> **Repo layout — one Xcode project, seven targets:**
>
> | Target | Status |
> |---|---|
> | `WaterBuddy/` | **LIVE** — the app: SwiftUI, iOS 26.5, `@Observable` `DataManager` over SwiftData |
> | `WaterBuddyWidget/` | **LIVE** — WidgetKit extension: `StaticConfiguration` + interactive `AddWaterIntent` |
> | `WaterBuddyTests/` | **LIVE** — swift-testing (`@Test` / `#expect`), run in parallel, own suite per test |
> | `WaterBuddyUITests/` | **LIVE** — `GoalSetupUITests` (real coverage) plus the Xcode template's launch tests |
> | `WaterBuddyWatch/` | **LIVE** — the watch app: `WristView`, `@Observable` `WristModel` over its own local App Group suite (no SwiftData) |
> | `WaterBuddyWatchWidget/` | **LIVE** — `.accessoryCircular` percentage-ring complication, reads the watch's own suite directly, never `WristModel.shared` |
> | `WaterBuddyWatchTests/` | **LIVE** — swift-testing, watch side |
> | `Entitlements/` | the App Group entitlement, one file per signed target (four signed targets) |
> | `Tools/` | standalone scripts, in **no** build target — the icon generator, and the screenshot harness |
> | `Screenshots/` | the App Store assets (`en-US/`) and the coverage run (`census/`), in no target |
>
> **Every shipping bundle also carries its own `PrivacyInfo.xcprivacy`** — four of them, byte-identical,
> one beside each target's sources. `UserDefaults` is a required-reason API, and since 1 May 2024 an
> upload that does not declare one is **rejected** by App Store Connect. All four bundles compile
> `DataManager.swift`, so all four need it; declaring only the iOS pair still fails. Each target's
> synchronized root group grants membership, so **adding one needs no `project.pbxproj` edit** — and a
> new target added later needs its own, which nothing will remind you of (`docs/STATE.md`,
> rule `15-project`'s *Submission* section).
>
> **`DataManager.swift`, `WaterLog.swift`, `WaterSurface.swift`, `LiquidGlassModifier.swift`,
> `ReminderPlan.swift` and `NotificationManager.swift` are compiled into both the app and the
> widget extension** — they live in `WaterBuddy/` and reach
> the extension through the synchronized-folder membership exception in `project.pbxproj`.
> Everything else under `WaterBuddy/` is app-only. That shared set is a contract, not a
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
| SwiftData — `WaterBuddy.store` | every `WaterLog` (`id`, `amount`, `timestamp`) — the **source of truth** | the app only |
| `UserDefaults` — nine keys | today's total, the goal, the day ordinal, three flags, the chosen language, the three quick-add amounts, the phone's applied-pours ledger — a **derived cache** | the app *and* the widget |

**Today's total is not stored as an authored value.** It is the sum of today's logs, recomputed
after every mutation and written through to the cache. **The widget never opens SwiftData** — a
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
     **mandatory**: `AppStoreScreenshotUITests` is the App Store capture harness, deliberately
     non-idempotent, and fails on any device where setup has already been completed
  3. `xcodebuild test -scheme WaterBuddyWatch -only-testing:WaterBuddyWatchTests` — watch unit tests
  4. `xcodebuild build -scheme WaterBuddyWidgetExtension` — the phone widget, its own scheme
  5. `xcodebuild build -scheme WaterBuddyWatchWidget` — the watch widget, its own scheme (no
     "Extension" suffix — not parallel to the phone widget's scheme name)
  — **no scheme compiles a sibling's sources**, so a widget-only or watch-only break passes a
  green `WaterBuddy`-scheme test run untouched. Both widget builds are as mandatory as the three
  test runs
- Treat every new warning as a failure, on **every** invocation, and a concurrency warning here is a
  Swift 6 error later. **"This codebase compiles clean" is no longer true and was retired on
  2026-09-02.** On **Xcode 27.0** (re-measured 2026-10-05; the 38 measured on Xcode 26.6 no longer
  compares), a clean `-scheme WaterBuddy` build into an empty DerivedData folder emits **31** unique
  warning lines (80 occurrences): the *"main actor-isolated … cannot be referenced from a nonisolated
  context"* family in `DataManager.swift` and `NotificationManager.swift`, plus two Xcode 27
  *"'Combine' was not imported by this file"* warnings in `WristView.swift`. The
  `WaterBuddyWatchWidget` scheme adds two `actool` trait-set warnings on the phone's catalogues
  (known issue #36). All are **pre-existing** — proven by building the code from before a change and
  comparing, never assumed. They are invisible to an incremental build, which is how "compiles
  clean" survived so long. The rule is therefore *no **new** warnings against a baseline measured by
  a clean build on the current toolchain*, compared per file and message, and closing the baseline is
  its own task (`docs/AI_CONTEXT.md` known issue #29)
- **A green suite is not proof the product works.** The suite injects its own `UserDefaults`,
  `Calendar` and clock, so it structurally cannot see an entitlement that was not added, a file
  missing from a target, or a widget that renders blank. Run the app on the simulator and put the
  widget on the Home Screen after any change to storage, entitlements, target membership or the
  widget's view tree — and the same for the watch face's complication, which no part of the
  automated gate renders
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
- **`DataManager` is the only writer.** Every mutation in the product goes through
  `addWater` / `removeWater` / `saveDailyGoal` / `resetIfNeeded`. No view, no intent and no
  provider reaches `UserDefaults` directly (rule `20-state`)
- **Two front doors, one serving — now by a shared read, not a shared constant.** The quick-add
  vessels are user-editable, and the middle one is what the widget's button logs and its face
  draws. Both doors resolve it from `Key.servings` in the App Group suite, carried to the extension
  by `WaterSnapshot.serving`. `defaultServing` (formerly `standardServing`) is only the fallback
  and the middle of `defaultServings`; a widget that logged a different amount is still a bug the
  user could only find by arithmetic, and the key is what prevents it (rule `20-state`)
- **`addLog` is how water enters.** `addWater(amount:)` is a synonym kept so `HomeView`'s button
  and the widget's `AddWaterIntent` did not change when the store did
- **Today's total is derived, never authored** — `recomputeToday()` sums today's logs and writes
  the figure through the `currentWater` setter, so the clamp, the equality guard and the widget
  doorbell all still fire exactly once per real change (rule `20-state`)
- **Mutate only after a re-read.** `addLog` and `removeWater` call `refresh()` first. Two
  processes hold their own `DataManager`, and an instance that has been idle would otherwise
  compute `staleTotal + amount` and write it over a newer figure (rule `20-state`)
- **The widget reads through `WaterSnapshot`, never through `DataManager.shared`.** A timeline
  provider is `nonisolated` and cannot touch a `@MainActor` singleton — and *constructing* a
  `DataManager` would materialise the goal, stamp the day, roll the total over and ring the
  widget doorbell: four writes from a process whose job is to draw (rule `40-widget`)
- **Only the app writes on behalf of the group.** Materialising the goal, stamping the day and
  the one-shot migration are all guarded by `DataManager.role` — a four-state
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
- **Import direction**: the widget may import from the shared six; nothing shared may import
  from the widget or from `HomeView`

## Storage — SwiftData, cached in the App Group
- **The App Group holds both stores** — `group.sardor.WaterBuddy`, declared in `Entitlements/` on
  both signed targets: the SwiftData file `WaterBuddy.store` **and** the `UserDefaults` suite.
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
  stays as history and `resetDailyProgress()` is the only path that deletes rows
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
