# The Watch's Stage Implementation Plan

> **For the session that runs it:** executed in the main loop, task by task, tests first — `CLAUDE.md`
> has no implementation subagent. Steps use checkboxes (`- [ ]`). **Nothing is committed**: each
> sub-stage ends with its files staged by name and a stop; the owner runs `/commit` (rule `90-git`)
> and, after it, `/doc_sync`.

**Goal:** roadmap item 1.3.2 — the watch draws Apple's glass (7a); its screen becomes the canvas's —
a vessel that only shows the percentage, the millilitre line under it, and a row of three pour
buttons with the Glass as the primary surface (7b); and its complication offers rectangular and
corner faces beside the circular one, every face reading the app's own arithmetic and hiding its
figures when watchOS redacts (7c).

**Architecture:** 7a widens three `#if os(iOS)` branches in the shared `LiquidGlassModifier.swift`
to `#available(iOS 26.0, watchOS 26.0, *)`. 7b adds `WristPlan.Face` — nested in the shared
`WristPlan.swift` — which `WristModel` reads, a `Layout` (`WristColumn`) that gives the vessel what
the line and the row leave, and rewrites `WristView`/`WristVessel` around them. 7c gives
`WristWidgetEntry` a `Face` and an `AppLanguage`, and draws three shapes from a new
`WristFaceView.swift`. No key, wire field, entitlement or exception set changes.

**Tech Stack:** Swift 5 mode, SwiftUI, WidgetKit, String Catalogs, swift-testing, Xcode 27.0,
watchOS 26.x and 27.0 simulators.

**Spec:** `docs/superpowers/specs/2026-10-20-the-watch-stage-design.md` — approved by the owner on
2026-10-20. §3 holds the design, §5 the rule wording, §7 the tests, §8 the verification. Read it with
this plan.

**What was checked in writing it** (2026-10-20, HEAD `06229be`): every type, member, key, test and
helper named below was read from the tree — `LiquidGlass.systemGlassAvailable`
(`LiquidGlassModifier.swift:256`), `sampling(_:)` (`:499`), `systemGlass` (`:544`),
`GlassGroupModifier` (`:741`), `primarySurface(in:ring:)` (`:821`), `WristView` (all 471 lines),
`WristVessel`, `WristModel`, `WristPlan`, `WristWidgetProvider`, `HomeColumn`
(`HomeView.swift:937`), `DataManager.usualSlot` (`DataManager.swift:1679`), `Bundle.localized` and
`Bundle.figure` (`:2224`, `:2241`), `WaterSnapshot.spokenFigures` (`LockScreenWidget.swift:303`),
`LocalizationTests`' `watchSharedKeys`, `watchOwnKeys`, `countedKeys`, `expected(…)` and `shipped(…)`,
`WristViewLogicTests`, `WristVesselLayoutTests`, `WristModelTests`' fixtures, `WristPlanTests`
(`WristSyncTests.swift:401`). The watchOS 27.0 SDK's interfaces were read for `Glass`,
`glassEffect(_:in:)`, `GlassEffectContainer` (all `watchOS 26.0`), `WidgetFamily.accessoryCorner`
(`watchOS 9.0`), `widgetLabel`, `widgetAccentable`, `privacySensitive`, `widgetFamily` (get-only),
`widgetRenderingMode` (settable) and `ImageRenderer` (present). A probe typechecked
`if #available(iOS 26.0, watchOS 26.0, *)` around `glassEffect` for `arm64-apple-watchos26.0-simulator`
and `arm64-apple-ios17.0-simulator`: **no warning on either**. Both watch catalogues round-trip
byte-identically through `json.dumps(…, ensure_ascii=False, indent=2) + "\n"`, keys in code-point
order. **None of the code below was compiled.**

**Two corrections to the spec, found while planning.** (1) §7 names one test removed with
`diameter(fitting:reserving:)`; there are two — `theVesselNeverExceedsTheAvailableWidth` calls it
too. Its claim is held for the function that stays by `theVesselFitsInsideBothItsWidthAndItsHeight`.
(2) §3.3 says the tint is measured "through a minute of `WristAurora`": `WristAurora` does not move
(it has no clock), so one render per pane is the whole swing. (3, an addition) The watch face's
configuration declares no `containerBackground`; iOS overlays a warning on a widget that does not,
and watchOS 10 and later ask the same (**inferred**). 7c adds `.containerBackground(for: .widget)
{ Color.clear }`, which changes nothing drawn.

## Global Constraints

- Floors stay `IPHONEOS_DEPLOYMENT_TARGET = 17.0` and `WATCHOS_DEPLOYMENT_TARGET = 26.0`. Zero
  dependencies; `project.pbxproj` does not change; no file joins an exception set — new files go in
  synchronized folders (`WaterBuddyWatch/`, `WaterBuddyWatchWidget/`, the test folders) (rule
  `15-project`).
- The glass's version check is `#available(iOS 26.0, watchOS 26.0, *)`, spelled once per site; no
  call site writes `glassEffect` or `GlassEffectContainer` (rule `60-design-system`).
- `WristPlan.swift` imports `Foundation` alone, calls no `Date()`, and everything added to it is
  `nonisolated` — it compiles into the phone app, where the default isolation is the main actor.
- `WristModel` stays the only writer to the watch's suite; no face writes, no face has a button.
- No new string is authored. Every key the watch gains is the app catalogue's entry, value for value,
  with `extractionState: manual` and its plural variations (spec §3.7).
- Every colour from `Aurora`, every corner and density from `LiquidGlass`; no literal size in a view
  without a named constant; volumes are `Int` (rule `60-design-system`, rule `00-workspace`).
- One primary surface on the screen — the Glass — `ring: false`; its label takes no
  `.foregroundStyle` of its own.
- Every figure on a face is `.privacySensitive()`; each shape has a quiet form and is one VoiceOver
  element.
- Never weaken an assertion; a test that disagrees with the code is a stop (rule `85-testing`).
- No new warning against a clean baseline of HEAD, compared per file and message, on every scheme.
- The tree is edited with Edit and Write only — no `sed -i`, no heredoc or script writing into it.
  Scripts may *read* the tree and write into the scratchpad. Probes run in a copy, never the tree.
- `xcodebuild` in the foreground, one simulator, `-parallel-testing-enabled NO`; shut simulators down
  by UDID, never `shutdown all`. `-collect-test-diagnostics never` on a run expected to fail.
- Devices: phone unit tests on the stock iOS 27.0 *iPhone 17*; UI tests on *WaterBuddy Gate 27* and
  *WaterBuddy Gate 26.5*; watch tests on *WaterBuddy Watch 27* and *WaterBuddy Watch 26* (P1); every
  render on a *WaterBuddy Probe Watch* (P1) — never a gate device. A probe seeds only a probe
  simulator's own store, and only through the app's own `WristModel.apply(_:)`.
- Xcode is closed while a catalogue is edited (`tasks/lessons.md`, 2026-10-18; #50).
- `.claude/settings.json` (modified) and `Screenshots/census/` (untracked) are the owner's: never
  staged, never touched (spec D2).

## Review Focus

The five inputs the spec implies and its tests do not name, most likely first, each pinned in the
task that owns it:

1. **A mirror carrying too few servings, or none** — the wire's `[Int]` is not re-checked on the
   watch. A person expects the row still to offer a Glass that pours the default, and never an empty
   row. Pinned by `theRowKeepsTheGlassForAShortOrEmptyMirror` (Task 5).
2. **A vessel of 1,000 ml or more** — the amount under a disc, inside the capsule and in the button's
   spoken label. A person expects *1,000 ml*, grouped as the phone groups it. Pinned by
   `aVesselOfAThousandIsGroupedEverywhereTheRowSaysIt` (Task 5).
3. **A goal of zero, or a total far past the goal** — a corrupt mirror. A person expects no crash, a
   full vessel, and a readout that still fits. Pinned by `aFaceNeverDividesByZeroOrOverflowsItsReadout`
   (Task 4).
4. **The phone's day ending with nothing arriving overnight.** A person expects the screen and every
   face to fall to the watch's own pours at the same instant. Pinned by
   `theFaceTurnsOverWhenThePhonesDayEnds` and `theModelsFaceIsThePlansFace` (Task 4).
5. **The phone set to Russian while the watch speaks English.** A person expects the line, the
   buttons' labels and the faces to follow the phone's choice, with Russian grouping. Pinned by
   `theLineAndTheLabelsFollowThePhonesLanguage` (Task 5); the faces by the probe in Russian (Task 10).

---

## Preconditions — before any code

- [x] **P1 — the runtime and the simulators (spec D1).** The owner installs the newest watchOS 26.x
  simulator runtime Xcode 27.0 offers. Then read its version and identifier, and create the devices:

```bash
xcrun simctl list runtimes | grep -i watchos
# W26 = the 26.x version printed, e.g. 26.5; R26 = its identifier, e.g. com.apple.CoreSimulator.SimRuntime.watchOS-26-5
R27=com.apple.CoreSimulator.SimRuntime.watchOS-27-0
xcrun simctl create "WaterBuddy Probe Watch 40" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-3-40mm $R27
xcrun simctl create "WaterBuddy Probe Watch 42" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-12-42mm $R27
xcrun simctl create "WaterBuddy Probe Watch 44" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-SE-3-44mm $R27
xcrun simctl create "WaterBuddy Probe Watch 46" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Series-12-46mm $R27
xcrun simctl create "WaterBuddy Probe Watch 49" com.apple.CoreSimulator.SimDeviceType.Apple-Watch-Ultra-4-49mm $R27
```

  On the 26.x runtime, create *WaterBuddy Watch 26* (the gate's) and *WaterBuddy Probe Watch 26*,
  each from the newest 46mm type it accepts — try `Apple-Watch-Series-12-46mm`, then `-11-46mm`, then
  `-10-46mm`; `simctl create` refuses a type the runtime does not support. Record every UDID in the
  session log. Boot each once and shut it down by UDID, so a listed device is proved to have data
  (`tasks/lessons.md`, 2026-10-08).
- [x] **P2 — the catalogues are clean and Xcode is closed.** This must print nothing, and no running
  Xcode may hold a WaterBuddy file:

```bash
git diff --stat -- WaterBuddy/Localizable.xcstrings WaterBuddyWidget/Localizable.xcstrings WaterBuddy/AppShortcuts.xcstrings WaterBuddyWatch/Localizable.xcstrings WaterBuddyWatchWidget/Localizable.xcstrings
pgrep -l Xcode && lsof -c Xcode 2>/dev/null | grep -c WaterBuddy
```

- [x] **P3 — read the DocC** on `WristView`, `WristServing`, `WristVessel`, `WristModel`
  (`displayGoal`, `todaysTotal`, `pour`, `apply`), `WristPlan`, `WristWidgetProvider`,
  `LiquidGlass.systemGlassAvailable`, `systemVariant`, `systemTintOpacity`, `sampling(_:)`,
  `PrimarySurfaceModifier`, `GlassGroupModifier` — rule `00-workspace`, and `CLAUDE.md`'s required
  reading for `LiquidGlassModifier.swift`.
- [x] **P4 — the warning baseline**, before 7a's first edit: **The warning comparison** (below) on
  HEAD alone, every scheme. Expected: 29 unique primary lines for `-scheme WaterBuddy`; the watch's 2
  (`WristView.swift`, *'Combine' was not imported*); the watch widget scheme's lines as its log
  shows them. Write the four counts into the session log; these are what "no new warning" compares
  against.

  *(2026-10-20, the seventy-fifth `/doc_sync`: P2 and P3 done — Xcode was running with WaterBuddy not
  open in it. P1 in part: the five 27.0 probe watches made (`docs/AI_CONTEXT.md` #90); the 26.x
  runtime is not on this Mac yet (#77), so the two 26.x devices are not made. P4 in part:
  `-scheme WaterBuddy` gives 35 primary lines on `HEAD` `06229be`. The next call, which bundled a
  `chmod` the settings deny, was refused and the session stopped (`tasks/lessons.md`, 2026-10-20);
  the other three schemes wait for the owner's word.)*

  *(2026-10-20, later: P4 done — clean builds of a `HEAD` `ff7305b` export: `WaterBuddyWatch` 2
  primary lines, `WaterBuddyWatchWidget` 29 and `WaterBuddyWidgetExtension` 29, the two widget lists
  identical. **P1's 26.x half is withdrawn by the owner's ruling** ("maybe you will change the
  runtime for different one that is exists"): the 26.x runtime never arrived, and the one other
  watchOS runtime here, 11.5, is below the watch's 26.0 floor and cannot run it. Everything this plan
  measures or runs on "both runtimes" is measured and run on watchOS 27.0 alone; the gate stays five
  invocations; the 26.x half goes to the owner's device as a known issue. The rule wording of Task 0
  was amended to match.)*

## Files

| File | Change | Task |
|---|---|---|
| `.claude/rules/15-project.md`, `60-design-system.md`, `65-accessibility.md`, `70-privacy.md`, `85-testing.md`, `00-workspace.md` | the wording of spec §5, typed unstaged for the owner | 0 |
| `WaterBuddy/LiquidGlassModifier.swift` | three availability sites; DocC; `systemTintOpacity(for:onPhone:)` only if Task 2 rules it | 1, 2 |
| `WaterBuddyWatchTests/WristGlassTests.swift` | new: `WristGlassTests` (not `@MainActor`) | 1 |
| `WaterBuddyWatch/WristView.swift` | 7a: two panes `interactive: true`. 7b: the row, the line, the column, `pourRow`, `pourLabel`, `amountLabel`, `vesselRange`; removals; `usualSlot` | 1, 5, 6 |
| `WaterBuddy/WristPlan.swift` | `WristPlan.Face`, `WristPlan.face(…)` | 4 |
| `WaterBuddyTests/WristSyncTests.swift` | Face tests in `WristPlanTests` | 4 |
| `WaterBuddyWatch/WristModel.swift` | `face`; `displayGoal`, `todaysTotal` through it | 4 |
| `WaterBuddyWatchTests/WristModelTests.swift` | `theModelsFaceIsThePlansFace` | 4 |
| `WaterBuddyWatchTests/WristViewLogicTests.swift` | the row's tests, the line's, the labels'; the scrim's | 5, 7 |
| `WaterBuddyWatch/Localizable.xcstrings` | +2 keys (Task 5), −4 keys (Task 6) | 5, 6 |
| `WaterBuddyTests/LocalizationTests.swift` | watch lists, `countedKeys`, `expected`, `shipped`, the watch widget's shared keys | 5, 6, 9 |
| `WaterBuddyWatch/WristColumn.swift` | new: `WristColumn: Layout` | 6 |
| `WaterBuddyWatch/WristVessel.swift` | a display: takes a `Face`, one VoiceOver element; `readout` and `diameter(fitting:reserving:)` removed; the ramp re-derived | 6, 7 |
| `WaterBuddyWatchTests/WristVesselLayoutTests.swift` | two tests removed; `WristColumn` and `vesselRange` tests | 6 |
| `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift` | the entry, the provider, the configuration | 10 |
| `WaterBuddyWatchWidget/WristFaceView.swift` | new: `WristFaceRoot`, `WristFaceView` and three private shapes | 10 |
| `WaterBuddyWatchWidget/Localizable.xcstrings` | +3 keys | 9 |
| `HISTORY.md`, `docs/AI_CONTEXT.md`, `docs/ROADMAP.md`, `docs/DESIGN.md`, `tasks/lessons.md`, the spec's and this plan's status lines | records | 3, 8, 11 |

`S` is the session's scratchpad directory. A shell's variables do not carry from one call to the
next, so every block that uses one sets it first (`S=<that directory>`; `W26=<P1's version>`).

**A phone unit run**, changing only the `-only-testing:` list:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests/<Suite> -parallel-testing-enabled NO 2>&1 | tee "$S/<name>-$(date +%H%M%S).log" | grep -E '✔|✘|error:|warning:|Test run with|TEST (SUCCEEDED|FAILED)'
```

**A watch unit run**, on 27.0 — and, for the gate and wherever a step says *both*, again with
`OS=$W26,name=WaterBuddy Watch 26`:

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests/<Suite> -parallel-testing-enabled NO 2>&1 | tee "$S/<name>-$(date +%H%M%S).log" | grep -E '✔|✘|error:|warning:|Test run with|TEST (SUCCEEDED|FAILED)'
```

**A watch widget build** — the only compile proof the faces have below the probe:

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | tee "$S/watchwidget-$(date +%H%M%S).log" | grep -E 'error:|warning:.*WaterBuddyWatch|BUILD (SUCCEEDED|FAILED)'
```

**The gate**, on the staged tree. Copy the index out and gate the copy, so what is gated is what the
owner will commit. `G` is a new directory named for the time (`G="$S/gate-$(date +%H%M)"`); each run
tees to its own timestamped log, with `uptime` written into it at its start and end:

```bash
git checkout-index -a --prefix="$G/"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -only-testing:WaterBuddyTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=26.5,name=WaterBuddy Gate 26.5' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -parallel-testing-enabled NO -collect-test-diagnostics never -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild test -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination "platform=watchOS Simulator,OS=$W26,name=WaterBuddy Watch 26" -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-dd"
xcodebuild build -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -derivedDataPath "$G-dd"
```

If a UI run would pass the ten-minute foreground limit, run its classes in chunks by name. Expected:
unit `✔ Test run with N tests passed`, N from the attribute grep; UI `GoalSetupUITests` with 1 skipped
by design and 0 failures on each system; both watch runs `✔ Test run with M tests in K suites
passed`, M from the attribute grep over `WaterBuddyWatchTests/`; both builds `** BUILD SUCCEEDED **`.
A watch run boots its paired phone (#51): shut both down by UDID after it. Read every count off its
log.

**The warning comparison.** A clean `build-for-testing` of HEAD and of the index copy, each into an
empty folder, primary `file:line:col: warning:` lines only — Xcode 27 prints a `` `- warning: `` line
under each snippet (`tasks/lessons.md`, 2026-10-19) — unique by file and message. `H` is a new
directory named for the time; the block runs once per scheme, `-scheme WaterBuddy` with the iOS
destination, `-scheme WaterBuddyWatch` and `-scheme WaterBuddyWatchWidget` with `generic/platform=watchOS
Simulator`, `-scheme WaterBuddyWidgetExtension` with `generic/platform=iOS Simulator` (`build` for the
two widget schemes):

```bash
mkdir -p "$H" && git archive HEAD | tar -x -C "$H"
xcodebuild build-for-testing -project "$H/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$H-clean" 2>&1 | tee "$S/head-build-$(date +%H%M%S).log" | grep -E '^/.*:[0-9]+:[0-9]+: warning:' | sed -E "s|^.*/${H:t}/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/head-warnings.txt"
xcodebuild build-for-testing -project "$G/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$G-clean" 2>&1 | tee "$S/index-build-$(date +%H%M%S).log" | grep -E '^/.*:[0-9]+:[0-9]+: warning:' | sed -E "s|^.*/${G:t}/||; s/:[0-9]+:[0-9]+:/:/" | sort -u > "$S/index-warnings.txt"
wc -l < "$S/head-warnings.txt"
head -3 "$S/head-warnings.txt" "$S/index-warnings.txt"
comm -13 "$S/head-warnings.txt" "$S/index-warnings.txt"
```

The paths are stripped by each export folder's own name (`${H:t}`, zsh's last path component): the
compiler prints `/tmp/…` where the scratchpad resolves `/private/tmp/…`, and stripping `$H` matched
nothing (`tasks/lessons.md`, 2026-10-20). The `head -3` must show relative paths —
`WaterBuddy/DataManager.swift: warning: …` — on both sides. Check the counter first: HEAD's list must
give P4's count before it is trusted. Expected: `comm -13`
prints nothing. A new line is a failure, fixed before going on.

**The screen probe** — how the watch screen is looked at. In a **copy** of the index, `P` (a new
directory named for the time; `git checkout-index -a --prefix="$P/"`), never the tree, add this file
as `$P/WaterBuddyWatch/WristProbe.swift`:

```swift
import Foundation

/// Throwaway — a probe copy only. Seeds the running watch's own store through the app's own write
/// path, from launch arguments, so a render needs no paired phone and no tap.
enum WristProbe {
    @MainActor static func seedIfAsked() {
        let arguments = ProcessInfo.processInfo.arguments
        func value(_ name: String) -> String? {
            guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else { return nil }
            return arguments[index + 1]
        }
        guard let total = value("-WristProbeTotal").flatMap(Int.init) else { return }
        let calendar = Calendar.waterBuddyDay
        let now = Date()
        WristModel.shared.apply(WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion,
            currentWater: total,
            dailyGoal: value("-WristProbeGoal").flatMap(Int.init) ?? 2_000,
            servings: value("-WristProbeServings")?.split(separator: ",").compactMap { Int($0) } ?? [150, 250, 500],
            languageCode: value("-WristProbeLanguage"),
            isGoalSet: true,
            composedAt: now,
            phoneDayStart: calendar.startOfDay(for: now),
            phoneDayEnd: DataManager.nextDayBoundary(after: now, calendar: calendar),
            acked: []
        ))
    }
}
```

and, in `$P/WaterBuddyWatch/WaterBuddyWatchApp.swift`'s `init()`, after `_ = WristModel.shared`:
`WristProbe.seedIfAsked()`. `simctl` cannot set Reduce Transparency (`xcrun simctl ui` offers
appearance, increase contrast and content size only), so a probe forces it with
`-WristProbeReduceTransparency`: in `$P/WaterBuddy/LiquidGlassModifier.swift` and
`$P/WaterBuddyWatch/WristAurora.swift`, rename the `@Environment(\.accessibilityReduceTransparency)`
property to `systemReduceTransparency` and add
`private var reduceTransparency: Bool { systemReduceTransparency || ProcessInfo.processInfo.arguments.contains("-WristProbeReduceTransparency") }`.
A text size is set with `xcrun simctl ui $UDID content_size accessibility-extra-extra-extra-large`
(and `large` to restore), then a relaunch. For 7a only, two more copy-only edits in `$P/WaterBuddyWatch/WristView.swift`:
`@State private var isMenuPresented = ProcessInfo.processInfo.arguments.contains("-WristProbeMenu")`,
and `.defaultScrollAnchor(ProcessInfo.processInfo.arguments.contains("-WristProbeBottom") ? .bottom : .top)`
on the `ScrollView` — so the *More* capsule, below the fold at rest, and the sheet can be drawn
without a tap. Build, install and shoot:

```bash
xcodebuild build -project "$P/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination "platform=watchOS Simulator,id=$UDID" -derivedDataPath "$P-dd" 2>&1 | tail -3
xcrun simctl boot $UDID
xcrun simctl install $UDID "$P-dd/Build/Products/Debug-watchsimulator/WaterBuddyWatch.app"
xcrun simctl launch --terminate-running-process $UDID sardor.WaterBuddy.watchkitapp -WristProbeTotal 1240 -WristProbeGoal 2000
# take shots until two in a row are identical — the screen has settled — then keep the last
prev=""; for i in $(seq 1 20); do xcrun simctl io $UDID screenshot "$S/probe.png" >/dev/null 2>&1; h=$(shasum "$S/probe.png" | cut -c1-40); [ "$h" = "$prev" ] && break; prev=$h; done
cp "$S/probe.png" "$S/<name>.png"
```

If `simctl install` refuses an unpaired watch, pair the probe watch with a probe phone
(`xcrun simctl pair <watch> <phone>`), install the phone app first and the watch app after
(`tasks/lessons.md`, 2026-10-05). **Look at every shot before writing a word about it**
(`tasks/lessons.md`, 2026-10-18).

**The contrast sampler**, read-only, written to `$S/contrast.py` and run with `python3 -I`:

```python
# python3 -I contrast.py shot.png x0 y0 x1 y1 [clean]
# Light ink on a darker pane. The box is the label's own box widened by `clean` px above and below,
# into rows that hold no ink; each column's background is the median of those clean rows, its ink
# the brightest pixel between them (the clean-row sampler that replaced #44's biased one).
import sys
from PIL import Image

def channel(c):
    c = c / 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def luminance(p):
    r, g, b = p[:3]
    return 0.2126 * channel(r) + 0.7152 * channel(g) + 0.0722 * channel(b)

image = Image.open(sys.argv[1]).convert("RGB")
x0, y0, x1, y1 = map(int, sys.argv[2:6])
clean = int(sys.argv[6]) if len(sys.argv) > 6 else 3
ratios = []
for x in range(x0, x1):
    column = [luminance(image.getpixel((x, y))) for y in range(y0, y1)]
    rows = column[:clean] + column[-clean:]
    background = sorted(rows)[len(rows) // 2]
    ink = max(column[clean:-clean])
    if ink - background < 0.05:
        continue
    ratios.append((ink + 0.05) / (background + 0.05))
ratios.sort()
print(f"columns {len(ratios)}  worst {ratios[0]:.2f}  median {ratios[len(ratios) // 2]:.2f}  best {ratios[-1]:.2f}")
```

A box is found by cropping the shot and looking (`Image.crop(...).save(...)`, then Read). Floors:
text 4.5:1, a glyph 3:1, the vessel's percentage (large, bold) 3:1.

---

### Task 0: The rule wording — typed unstaged, for the owner

**Files:** the six rule files named in the table. Each edit replaces the sentence quoted (found by
reading the file first) with the text given; nothing else in the file moves.

- [x] **Step 1: `15-project`**, *Targets and schemes*, the bullet beginning "**The second version
  check is the glass's.**" becomes:

  > **The second version check is the glass's.** `LiquidGlassModifier` draws Apple's glass inside
  > `if #available(iOS 26.0, watchOS 26.0, *)`, and `LiquidGlass.systemGlassAvailable` answers the
  > same question for the pure routing function; `theAvailabilityFlagMatchesTheRunningSystem` on the
  > phone and `theWatchDrawsAppleGlass` on the watch keep the two in step. The watch's floor is 26.0,
  > so the watch always takes it; the widget extension passes `.archived` and never meets it. Below
  > iOS 26 the path is run-verified on iOS 18.6 and compile-verified only at 17.0; the watch's is
  > run-verified on watchOS 26.x and 27.0 (the redesign's stage 7)

- [x] **Step 2: `60-design-system`.**
  - *Glass*, second bullet: "the hand-made stack everywhere else — a `.flat` base, iOS 17 to 25, and
    the watch until its own stage." → "the hand-made stack everywhere else — a `.flat` base, and iOS 17
    to 25. The watch draws Apple's glass from its floor, watchOS 26.0."
  - *Glass*, the `.glassGroup()` bullet: "Apple's `GlassEffectContainer` on iOS 26 and later" →
    "Apple's `GlassEffectContainer` on iOS 26 and later and on the watch".
  - *Glass*, the tint bullet, appended: "The watch is measured on its own renders, on both watch
    runtimes, never estimated from the phone's."
  - *The primary surface*, a new last bullet: "On the watch the Glass pour button is the primary
    surface — a capsule carrying its amount where the row has room, a disc where it has not —
    `ring: false`, as the widget's: the ring is the phone's."
  - *Interaction*, the first bullet (beginning "**Currently unreachable on the watch.**") becomes:
    "**No press response of the app's own on the watch.** `PressStyle.swift` and `Haptics.swift` are
    in none of the watch's exception sets, so its buttons take `.buttonStyle(.plain)` and play no
    haptic — deliberate: haptics were not in the approved watch scope. Its glass controls take
    `Glass.interactive()`, whose press response is the system's; the white Glass has none. A task that
    wants either on the watch adds the file to that exception set first"
  - *Water*, the ramp bullet: "and the watch's vessel (`WristVessel.scrimIntensity(at:)`, full
    strength by 20%)" → "and the watch's vessel (`WristVessel.scrimIntensity(at:)`, full strength by
    the level at which water reaches the percentage's ink, its lowest readout)".
  - A new section after *In the widget*:

    > ## On the watch face
    > - A face draws no glass and no aurora. Its gauges are tinted `Aurora.blue`, and on a tinted face
    >   the header and the gauges are `.widgetAccentable()`
    > - Every figure on a face carries `.privacySensitive()`, and every shape draws its quiet form —
    >   the drop and an empty gauge, and on the rectangle *Hydration* over an empty bar — whenever
    >   `redactionReasons` contains `.privacy`
    > - The rectangle draws the app screen's own line, `WristPlan.Face.millilitreLine(in:locale:)`;
    >   the faces and the screen read one `WristPlan.Face`

- [x] **Step 3: `65-accessibility`**, *VoiceOver*:
  - "The vessel is exactly **one** element in both processes" → "The vessel is exactly **one**
    element in all three processes that draw it — the app, the widget and the watch".
  - After the Lock Screen widget's bullet, two new bullets: "Each pour button on the watch is one
    button whose label is the phone's `%1$@, add %2$d millilitres`; the amounts drawn under its discs
    are hidden" and "Each watch face is one element — label *Today's hydration*, value the vessel's own
    sentence through `WristPlan.Face.spokenFigures(in:locale:)` — and its quiet form speaks its label
    alone".

- [x] **Step 4: `70-privacy`.**
  - *WatchConnectivity*, the carve-out: "renders a percentage derived from the stored `WristMirror` as
    an `.accessoryCircular` complication" → "renders today's figures, derived from the stored
    `WristMirror`, in three faces — circular, rectangular and corner —". At the end of that bullet:
    "Since the redesign's stage 7 the watch's faces carry the Lock Screen widget's marking: every
    figure `.privacySensitive()`, and a quiet form whenever `redactionReasons` contains `.privacy`."
  - *Localization*: "The complication's `.description` is resolved by WidgetKit and follows the watch's
    system language" → "The faces draw in `WristMirror.languageCode`'s language, resolved by their
    provider; their `.description` is resolved by WidgetKit and follows the watch's system language".

- [x] **Step 5: `85-testing`**, *The gate*: "**Five invocations, not three**" → "**Six invocations**";
  the watch invocation is followed by its twin on `OS=26.x,name=WaterBuddy Watch 26`; a new bullet
  after the iOS 26 one: "**While watchOS 26 is supported, the watch unit tests also run on a watchOS
  26 runtime** — the floor, where Apple's glass on the watch began." *A green suite is not proof*:
  "and the watch's `.accessoryCircular` face" → "and the watch's three faces"; "add the widget to a
  watch face by hand" → "add each of its three faces to a watch face by hand, a tinted face among
  them, on both watch runtimes".

- [x] **Step 6: `00-workspace`**, *Layout*: "the watch WidgetKit extension — .accessoryCircular
  percentage ring" → "the watch WidgetKit extension — circular, rectangular and corner faces".

- [x] **Step 7: Show and stop.** `git diff -- .claude/rules/` to the owner. **Stop until the owner
  approves the wording.** It stays unstaged; the owner commits it when they choose, as
  `chore(claude): …` after the stage (precedent `06229be`).

---

### Task 1: 7a — Apple's glass on the watch

**Files:**
- Create: `WaterBuddyWatchTests/WristGlassTests.swift`
- Modify: `WaterBuddy/LiquidGlassModifier.swift` (`:248`–`:261`, `:492`–`:518`, `:544`–`:559`,
  `:731`–`:751`); `WaterBuddyWatch/WristView.swift` (`:287`, `:456`)

**Interfaces:**
- Produces: `LiquidGlass.systemGlassAvailable == true` on watchOS. Unchanged signatures.

- [x] **Step 1: Write the failing test**, `WaterBuddyWatchTests/WristGlassTests.swift`:

```swift
//
//  WristGlassTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// The watch's half of `theAvailabilityFlagMatchesTheRunningSystem`: the flag the glass modifier
/// passes has to be the truth about the system it runs on, and on the watch that is always yes — its
/// floor is watchOS 26.0, where Apple's glass begins (spec 2026-10-20 §3.3).
///
/// Not `@MainActor`, like the phone's glass suites: the answer is a value (rule `43-concurrency`).
struct WristGlassTests {

    @Test func theWatchDrawsAppleGlass() {
        let floor = OperatingSystemVersion(majorVersion: 26, minorVersion: 0, patchVersion: 0)
        #expect(ProcessInfo.processInfo.isOperatingSystemAtLeast(floor),
                "this runtime is below the watch's own floor — the run proves nothing")
        #expect(LiquidGlass.systemGlassAvailable)
    }
}
```

- [x] **Step 2: Run it and verify RED** — a watch unit run, `-only-testing:WaterBuddyWatchTests/WristGlassTests`,
  with `-collect-test-diagnostics never`. Expected: `✘` on `#expect(LiquidGlass.systemGlassAvailable)`
  — the flag is `false` by `#if os(iOS)`, a wrong value, not a compile error.

- [x] **Step 3: Widen the three sites.** In `LiquidGlassModifier.swift`:

  `systemGlassAvailable` (`:248`–`:261`) becomes:

```swift
    /// Whether this process can draw Apple's glass.
    ///
    /// On the phone, from iOS 26. On the watch, always: its floor is watchOS 26.0, where the API
    /// begins, and the redesign's watch stage rendered and measured its panes on it (spec
    /// `2026-10-20-the-watch-stage-design.md` §3.3).
    ///
    /// A `static let`, resolved once: the answer cannot change while the process lives.
    nonisolated static let systemGlassAvailable: Bool = {
        if #available(iOS 26.0, watchOS 26.0, *) { return true }
        return false
    }()
```

  `sampling(_:)` (`:499`–`:518`): delete `#if os(iOS)`, the `#else` branch with its
  `content.background(ownPane(systemGlassDrawn: false))` and `#endif`, and change
  `if #available(iOS 26.0, *) {` to `if #available(iOS 26.0, watchOS 26.0, *) {`. In its DocC, "The
  `else` and the `#else` draw this file's own pane." → "The `else` draws this file's own pane."

  `systemGlass` (`:544`–`:559`): delete the `#if os(iOS)` line and its `#endif`, and change
  `@available(iOS 26.0, *)` to `@available(iOS 26.0, watchOS 26.0, *)`.

  `GlassGroupModifier` (`:731`–`:751`): the body becomes

```swift
    func body(content: Content) -> some View {
        if #available(iOS 26.0, watchOS 26.0, *) {
            GlassEffectContainer { content }
        } else {
            content
        }
    }
```

  and its DocC's "On iOS 26 and later this is Apple's `GlassEffectContainer`" → "On iOS 26 and later,
  and on the watch, this is Apple's `GlassEffectContainer`"; "`#if os(iOS)` keeps the watch on the
  pass-through until its own stage, as ``LiquidGlass/systemGlassAvailable`` does for the panes." is
  deleted. Then correct every other sentence in the file that says the watch is on the hand-made
  stack — `grep -n -iE "watch" WaterBuddy/LiquidGlassModifier.swift` lists them; at HEAD they are the
  type DocC (`:28`–`:29`, "on the watch until its own stage") and `scrim(…)`'s DocC (`:340`–`:341`).
  What is now true: the watch draws Apple's glass, or the opaque fill under Reduce Transparency, so it
  never draws the hand-made stack and its scrim; `scrim(…)`'s `onPhone: false` answer is reached by
  no production pane and is kept for the test that asks the watch's question. No code in `scrim(…)`
  changes.

- [x] **Step 4: The watch's two labelled panes become controls.** In `WristView.swift`, the *More*
  capsule (`:287`) and the sheet's rows (`:456`): `.liquidGlass(in: Capsule(), density: .sheer)` →
  `.liquidGlass(in: Capsule(), density: .sheer, interactive: true)`, each with the comment "Interactive:
  the glass is what is pressed, and on Apple's glass a sheer control takes the regular, tinted
  variant — the clear one would leave its label on untinted glass (#91(b))."

- [x] **Step 5: Run it GREEN**, on **both** watch runtimes (`WristGlassTests`). Expected:
  `✔ Test run with 1 test in 1 suite passed` on each.
- [x] **Step 6: The phone's glass suites still hold** — a phone unit run,
  `-only-testing:WaterBuddyTests/LiquidGlassInteractionTests -only-testing:WaterBuddyTests/LiquidGlassScrimTests`.
  Expected: all pass. Then **a watch widget build** and the phone widget build
  (`-scheme WaterBuddyWidgetExtension`): both `** BUILD SUCCEEDED **`, no warning naming
  `LiquidGlassModifier.swift`.

---

### Task 2: 7a — the renders and the tint

**Files:** none in the tree unless Step 4 rules a watch rung.

- [x] **Step 1: Shoot the panes** with **the screen probe**, on *WaterBuddy Probe Watch 46* (27.0)
  and *WaterBuddy Probe Watch 26*, each with:
  - `-WristProbeTotal 0` — the vessel empty on clear glass;
  - `-WristProbeTotal 1240` — the vessel at 62%;
  - `-WristProbeTotal 1240 -WristProbeBottom` — the *More* capsule;
  - `-WristProbeTotal 1240 -WristProbeMenu` — the sheet's two rows;
  - each again with `-WristProbeReduceTransparency` (the probe's own switch, above).
  Look at all twenty.
- [x] **Step 2: Measure** with **the contrast sampler**: the *More* label; each row's name; each row's
  amount (`.secondary`); on each runtime. And the 62% vessel's percentage over the water.
- [x] **Step 3: Write the table** into the session log: pair, runtime, worst, median, best, floor.
- [x] **Step 4: The tint ruling.**
  - **Every pair clears its floor on both runtimes** → `systemTintOpacity` stays one value, 0.64. Go
    to Task 3.
  - **The only pair under its floor is a row's `.secondary` amount** → **stop and show the owner the
    table.** 7b deletes the sheet; climbing the watch's tint for a pane about to go would set the
    discs' glass by a label they do not carry. The owner rules: keep 0.64, or climb anyway.
  - **A pair 7b keeps fails** (the *More* label stands in for a white label on regular glass) → climb
    in a fresh probe copy: 0.68, 0.72, … , one rung at a time on both runtimes, until every pair
    clears; the lightest that passes on both is the watch's rung. Then in the tree:

```swift
    nonisolated static func systemTintOpacity(for variant: SystemVariant, onPhone: Bool) -> Double {
        switch variant {
        case .regular: return onPhone ? 0.64 : <the watch's rung>
        case .clear: return 0
        }
    }
```

    with `systemGlass` calling `LiquidGlass.systemTintOpacity(for: variant, onPhone: LiquidGlass.runsOnPhone)`,
    the phone's three tests passing `onPhone: true`, the DocC carrying the watch's measured table, and
    in `WristGlassTests`:

```swift
    /// Measured on the watch's own renders, both runtimes (spec 2026-10-20 §3.3): every lighter
    /// rung left a label under 4.5:1. A lighter glass is a new measurement first, and then this.
    @Test func theWatchsTintIsNoLighterThanTheLightestRungThatPassedOnTheWatch() {
        #expect(LiquidGlass.systemTintOpacity(for: .regular, onPhone: false) >= <the watch's rung>)
    }
```

    RED first (with 0.64 still returned for both), then GREEN.

---

*(2026-10-20, as run: on watchOS 27.0 only (P1's note) — eight shots, not twenty, plus three from a
`HEAD` probe for the hand-made column. Three departures from the text above. **The probe copied the
working tree**, not the index: 7a's code was unstaged when Task 2 ran, and `git checkout-index` would
have built `HEAD`. **The floor figure is the clean-ground one**: the sampler's worst column is a
glyph's anti-aliased edge — the white *Cup* read 1.41 there — so each pair is also read as the
label's full-strength ink against the lightest clean-ground pixel, `docs/DESIGN.md`'s method, and
that figure is the one ruled on. **The ruling was Step 4's second branch**: the sheet's `.secondary`
amounts, 2.83:1, were the only pairs 7a moved under a floor; the owner kept `0.64`. The table is
*The watch's glass, measured*, `docs/DESIGN.md`.)*

### Task 3: 7a — verification, records, staging

- [x] **Step 1: The gate** (above), on the staged tree. Expected as written there.
- [x] **Step 2: The warning comparison** (above), every scheme — a shared file changed.
- [x] **Step 3: Records.** `HISTORY.md`, a checkpoint `## [2026-10-20] — Roadmap item 1.3.2, stage 7a:
  Apple's glass on the watch` (or the date it runs): what changed, the rulings, the RED run, the gate
  and warning comparison as their logs show them, the twenty shots looked at, the tint table.
  `docs/DESIGN.md`: the watch's measured pairs beside *The look, measured*; the rendering table's
  "the watch, for now" row and `:772`–`:776`'s paragraph corrected; the watch's glass in the density
  and elevation lists. `docs/AI_CONTEXT.md`: a *Current state* block; rows for the changed files
  (`wc -l`); the `@Test` counts by the attribute grep; #91(b) retired. `docs/ROADMAP.md`: 1.3.2's
  entry, dated. The spec's status line and this plan's checkboxes.
- [ ] **Step 4: Stage by name and show the two diffs.** The spec and this plan ride with 7a unless the
  owner has committed them first, as `1899aba` did for 1.3.1:

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddyWatch/WristView.swift WaterBuddyWatchTests/WristGlassTests.swift HISTORY.md docs/AI_CONTEXT.md docs/DESIGN.md docs/ROADMAP.md docs/superpowers/specs/2026-10-20-the-watch-stage-design.md docs/superpowers/plans/2026-10-20-the-watch-stage.md
git diff --cached --name-status
git diff --name-status
```

- [ ] **Step 5: Stop.** The owner runs `/commit`, then `/doc_sync`. 7b begins on the next HEAD.

---

### Task 4: 7b — `WristPlan.Face`, and the model reading it

**Files:**
- Modify: `WaterBuddy/WristPlan.swift` (append); `WaterBuddyWatch/WristModel.swift` (`:94`–`:163`)
- Test: `WaterBuddyTests/WristSyncTests.swift` (`WristPlanTests`); `WaterBuddyWatchTests/WristModelTests.swift`

**Interfaces:**
- Produces:
  - `WristPlan.Face(total: Int, goal: Int)` — `nonisolated struct`, `Equatable`, `Sendable`, with
    `var progress: Double`, `var percentage: Int`, `func spokenFigures(in: Bundle, locale: Locale) -> String`,
    `func millilitreLine(in: Bundle, locale: Locale) -> String`, `static let sample: Face`
  - `WristPlan.face(mirror: WristMirror?, outbox: [WristPour], now: Date, calendar: Calendar) -> WristPlan.Face`
  - `WristModel.face: WristPlan.Face`

- [ ] **Step 1: Write the failing tests**, appended inside `WristPlanTests` after the timeline tests:

```swift
    // MARK: - The face both watch surfaces draw (spec 2026-10-20 §3.5)

    /// The app's own English, from the test host — this suite is hosted by the phone app.
    private static var english: Bundle? {
        Bundle.main.url(forResource: "en", withExtension: "lproj").flatMap(Bundle.init(url:))
    }

    @Test
    func aFaceBeforeAnySyncDrawsAgainstTheDefaultGoal() {
        let now = Date(timeIntervalSince1970: 1_767_279_600) // 2026-01-01 15:00 UTC
        let pour = WristPour(id: UUID(), amount: 500, at: now)
        let face = WristPlan.face(mirror: nil, outbox: [pour], now: now, calendar: Self.utc)
        #expect(face == WristPlan.Face(total: 500, goal: DataManager.defaultDailyGoal))
        #expect(face.percentage == 25)
        #expect(face.progress == 0.25)
    }

    @Test
    func aFaceCountsThePhonesTotalAndTheWatchsOwnPours() {
        let mirror = Self.mirror(
            phoneDayStart: Date(timeIntervalSince1970: 1_767_225_600), // 2026-01-01 00:00 UTC
            phoneDayEnd: Date(timeIntervalSince1970: 1_767_312_000)    // 2026-01-02 00:00 UTC
        )
        let now = Date(timeIntervalSince1970: 1_767_279_600)
        let pour = WristPour(id: UUID(), amount: 250, at: now)
        let face = WristPlan.face(mirror: mirror, outbox: [pour], now: now, calendar: Self.utc)
        #expect(face == WristPlan.Face(total: 2_050, goal: 2_000))
        #expect(face.percentage == 103, "past the goal the readout keeps counting")
        #expect(face.progress == 1, "the water stops at the rim")
    }

    /// Review focus 4: the phone slept through midnight and nothing arrived. At the instant its day
    /// ends, the face falls to the watch's own pours — the same instant `WristModel` does, because
    /// both read this function.
    @Test
    func theFaceTurnsOverWhenThePhonesDayEnds() {
        let end = Date(timeIntervalSince1970: 1_767_312_000)
        let mirror = Self.mirror(phoneDayStart: Date(timeIntervalSince1970: 1_767_225_600), phoneDayEnd: end)
        let newDaysPour = WristPour(id: UUID(), amount: 250, at: end)
        #expect(WristPlan.face(mirror: mirror, outbox: [], now: end.addingTimeInterval(-1), calendar: Self.utc).total == 1_800)
        #expect(WristPlan.face(mirror: mirror, outbox: [newDaysPour], now: end, calendar: Self.utc)
                == WristPlan.Face(total: 250, goal: 2_000))
    }

    /// The provider's formula, carried over unchanged: schoolbook rounding of the exact share.
    @Test(arguments: [
        (1_240, 2_000, 62), (1_245, 2_000, 62), (1_250, 2_000, 63), (333, 1_000, 33), (0, 2_000, 0),
    ])
    func theFaceRoundsAsTheComplicationAlwaysHas(total: Int, goal: Int, percentage: Int) {
        #expect(WristPlan.Face(total: total, goal: goal).percentage == percentage)
    }

    /// Review focus 3: a corrupt mirror. No division by zero, a full vessel, and a readout that
    /// still fits in three digits.
    @Test
    func aFaceNeverDividesByZeroOrOverflowsItsReadout() {
        #expect(WristPlan.Face(total: 500, goal: 0).percentage == 0)
        #expect(WristPlan.Face(total: 500, goal: 0).progress == 0)
        #expect(WristPlan.Face(total: 100_000, goal: 2_000).percentage == 999)
        #expect(WristPlan.Face(total: 100_000, goal: 2_000).progress == 1)
    }

    @Test
    func aFaceSpeaksAndDrawsItsFiguresInTheAppsSentences() throws {
        let english = try #require(Self.english)
        let face = WristPlan.Face(total: 1_240, goal: 2_000)
        let locale = Locale(identifier: "en")
        #expect(face.spokenFigures(in: english, locale: locale) == "62 percent. 1,240 of 2,000 millilitres.")
        #expect(face.millilitreLine(in: english, locale: locale) == "1,240 of 2,000 ml")
    }
```

  and inside `WristModelTests`:

```swift
    /// Review focus 4, the screen's half: the model draws exactly what the complication computes
    /// from the same store.
    @Test
    func theModelsFaceIsThePlansFace() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 1_000, dailyGoal: 1_600,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: now, phoneDayStart: Date(timeIntervalSince1970: 0), phoneDayEnd: Self.endOfFirstDay, acked: []
            ))
            model.pour(amount: 250)
            #expect(model.face == WristPlan.face(mirror: model.mirror, outbox: model.pendingOutbox, now: now, calendar: Self.utc))
            #expect(model.face == WristPlan.Face(total: 1_250, goal: 1_600))
            #expect(model.face.percentage == 78)
        }
    }
```

- [ ] **Step 2: Run RED** — a phone unit run, `-only-testing:WaterBuddyTests/WristPlanTests`, and a
  watch unit run, `-only-testing:WaterBuddyWatchTests/WristModelTests`. Expected: both fail to
  compile — *cannot find 'Face' in scope*, *value of type 'WristModel' has no member 'face'*. (A new
  type's RED is its absence.)

- [ ] **Step 3: Implement.** Appended to `WaterBuddy/WristPlan.swift`:

```swift
// MARK: - The face

extension WristPlan {

    /// Today's figures as both watch surfaces draw them — the screen through `WristModel.face`, the
    /// complication through its entry — so the two cannot disagree (spec 2026-10-20 §3.5).
    ///
    /// **Nested here, not a file of its own:** a new file would grow two exception sets
    /// (rule `15-project`); `ReminderPlan.Slot` is the precedent. `nonisolated`, because this file
    /// compiles into the phone app, whose default isolation is the main actor, and the complication's
    /// provider reads it off the main actor.
    nonisolated struct Face: Equatable, Sendable {

        let total: Int
        let goal: Int

        /// How full the vessel is: the share of the goal, held to `0...1` — the water stops at the
        /// rim — and 0 for a goal of 0, which a corrupt mirror is the only way to carry.
        var progress: Double {
            guard goal > 0 else { return 0 }
            return min(1, max(0, Double(total) / Double(goal)))
        }

        /// The readout: the share in whole percent, rounded as the complication always rounded it,
        /// held to `0...999` so it fits a face in three digits. 0 for a goal of 0.
        var percentage: Int {
            guard goal > 0 else { return 0 }
            return min(999, max(0, Int((Double(total) / Double(goal) * 100).rounded())))
        }

        /// The vessel's own sentence — `WaterSnapshot.spokenFigures(in:locale:)`'s twin, the same key —
        /// so the screen and every face speak today alike.
        func spokenFigures(in strings: Bundle, locale: Locale) -> String {
            strings.localized("%1$d percent. %2$d of %3$d millilitres.", percentage, total, goal, locale: locale)
        }

        /// *1,240 of 2,000 ml* — the line under the vessel and the rectangle's middle line, the phone's
        /// own key, both figures grouped as `locale` groups them.
        func millilitreLine(in strings: Bundle, locale: Locale) -> String {
            strings.figure("%1$@ of %2$@ ml", total, goal, locale: locale)
        }

        /// What a face draws in the gallery and as its placeholder: 62%, the figure the circular face
        /// has always shown there.
        static let sample = Face(total: 1_240, goal: 2_000)
    }

    /// Today's face from the watch's store: ``todaysTotal(mirror:outbox:now:calendar:)`` against the
    /// phone's goal, or ``DataManager/defaultDailyGoal`` before the first sync — the fallback
    /// `WristModel.displayGoal` has always used.
    nonisolated static func face(mirror: WristMirror?, outbox: [WristPour], now: Date, calendar: Calendar) -> Face {
        Face(
            total: todaysTotal(mirror: mirror, outbox: outbox, now: now, calendar: calendar),
            goal: mirror?.dailyGoal ?? DataManager.defaultDailyGoal
        )
    }
}
```

  In `WristModel.swift`, `displayGoal`'s body becomes `face.goal` and `todaysTotal`'s body becomes
  `face.total`, each DocC keeping its reasoning and gaining "— read through ``face``"; and above
  `displayGoal`:

```swift
    /// Today's figures, as the complication computes them from the same store —
    /// `WristPlan.face(mirror:outbox:now:calendar:)` — so the screen and the face cannot disagree
    /// (spec 2026-10-20 §3.5). Reads through `mirror` and `pendingOutbox`, so it needs no tracking of
    /// its own; the phone's day ending is caught by `WristView`'s 30-second clock.
    var face: WristPlan.Face {
        WristPlan.face(mirror: mirror, outbox: pendingOutbox, now: now(), calendar: calendar)
    }
```

- [ ] **Step 4: Run GREEN** — the same two runs. Expected: `WristPlanTests` and `WristModelTests` pass,
  every pre-existing `todaysTotal` and `displayGoal` test among them.

---

### Task 5: 7b — the row's logic and its strings

**Files:**
- Modify: `WaterBuddyWatch/WristView.swift` (the pure functions); `WaterBuddyWatch/Localizable.xcstrings`
  (+2 keys); `WaterBuddyTests/LocalizationTests.swift` (`watchSharedKeys`, `countedKeys`)
- Test: `WaterBuddyWatchTests/WristViewLogicTests.swift`

**Interfaces:**
- Consumes: `WristPlan.Face` (Task 4); `DataManager.usualSlot`
- Produces: `WristView.pourRow(from: WristMirror?) -> [WristServing]`,
  `WristView.pourLabel(for: WristServing, strings: Bundle, locale: Locale) -> String`,
  `WristView.amountLabel(_ amount: Int, strings: Bundle, locale: Locale) -> String`

- [ ] **Step 1: Write the failing tests**, in `WristViewLogicTests`, a new section after
  `aMirrorWithNoServingsOffersAnEmptyMenuRatherThanInventedAmounts`:

```swift
    // MARK: - The pour row (spec 2026-10-20 §3.4)

    /// Cup, Glass, Bottle — `vesselSlots`' order — each with the phone's amount. Membership and
    /// order both, so a slot sliding onto the wrong amount fails too (lesson (b)).
    @Test
    func theRowOffersCupGlassAndBottleInTheirSlotsOrder() {
        let row = WristView.pourRow(from: Self.mirror(isGoalSet: true, servings: [100, 200, 300]))
        #expect(row == [
            WristServing(nameKey: "Cup", symbol: "cup.and.saucer.fill", amount: 100),
            WristServing(nameKey: "Glass", symbol: "mug.fill", amount: 200),
            WristServing(nameKey: "Bottle", symbol: "waterbottle.fill", amount: 300),
        ])
        #expect(WristView.pourRow(from: nil).map(\.amount) == DataManager.defaultServings)
    }

    /// Review focus 1: the wire's `[Int]` is not re-checked on this side. A short or empty mirror
    /// leaves a smaller row — never an empty one, and never one without the Glass.
    @Test
    func theRowKeepsTheGlassForAShortOrEmptyMirror() {
        let short = WristView.pourRow(from: Self.mirror(isGoalSet: true, servings: [100]))
        #expect(short == [
            WristServing(nameKey: "Cup", symbol: "cup.and.saucer.fill", amount: 100),
            WristServing(nameKey: "Glass", symbol: "mug.fill", amount: DataManager.defaultServing),
        ])
        let empty = WristView.pourRow(from: Self.mirror(isGoalSet: true, servings: []))
        #expect(empty == [WristServing(nameKey: "Glass", symbol: "mug.fill", amount: DataManager.defaultServing)])
    }

    /// Review focus 2: a vessel of a litre is grouped wherever the row says it.
    @Test
    func aVesselOfAThousandIsGroupedEverywhereTheRowSaysIt() throws {
        let english = try #require(shipped("en"))
        let en = AppLanguage.english.locale
        let bottle = WristServing(nameKey: "Bottle", symbol: "waterbottle.fill", amount: 1_000)
        #expect(WristView.amountLabel(bottle.amount, strings: english, locale: en) == "1,000 ml")
        #expect(WristView.pourLabel(for: bottle, strings: english, locale: en) == "Bottle, add 1,000 millilitres")
    }

    /// The phone's own sentence for a quick-add vessel, in each language, in the form its count takes.
    @Test(arguments: ["en", "ru", "uz"])
    func eachButtonIsLabelledWithThePhonesSentence(language: String) throws {
        let strings = try #require(shipped(language))
        let glass = WristServing(nameKey: "Glass", symbol: "mug.fill", amount: 250)
        let expected = [
            "en": "Glass, add 250 millilitres",
            "ru": "Стакан, добавить 250 миллилитров",
            "uz": "Stakan, 250 millilitr qo‘shish",
        ]
        #expect(WristView.pourLabel(for: glass, strings: strings, locale: Locale(identifier: language)) == expected[language])
    }

    /// Review focus 5: the phone set to Russian, whatever the watch speaks — the line and the labels
    /// take the bundle and the locale `WristModel.language` resolves from the mirror.
    @Test
    func theLineAndTheLabelsFollowThePhonesLanguage() {
        let russian = AppLanguage(code: "ru")
        let line = WristPlan.Face(total: 1_250, goal: 2_000).millilitreLine(in: russian.bundle, locale: russian.locale)
        let label = WristView.pourLabel(for: WristServing(nameKey: "Glass", symbol: "mug.fill", amount: 250),
                                        strings: russian.bundle, locale: russian.locale)
        #expect(line.hasSuffix(" мл") && line.contains(" из "), "\(line) is not the Russian line")
        #expect(!line.contains(","), "\(line) groups with the English separator")
        #expect(label.hasPrefix("Стакан"), "\(label) is not the Russian label")
    }
```

  and `theVesselReadoutGroupsThousandsInTheChosenLanguage` (`:246`–`:272`) is **rewritten** for the
  line that replaces the readout — same name pattern, same three figures:

```swift
    /// Review focus: the empty state and five-digit figures as well as the everyday four. English is
    /// pinned exactly. Russian and Uzbek group with a no-break space whose exact code point has
    /// changed between OS releases, so it is matched as "a non-digit splits the figure". Uzbek puts
    /// the goal first (*2 000 dan 1 250 ml*).
    @Test
    func theLineUnderTheVesselGroupsThousandsInTheChosenLanguage() throws {
        let english = try #require(shipped("en"))
        let russian = try #require(shipped("ru"))
        let uzbek = try #require(shipped("uz"))
        let en = AppLanguage.english.locale

        #expect(WristPlan.Face(total: 1_250, goal: 2_000).millilitreLine(in: english, locale: en) == "1,250 of 2,000 ml")
        #expect(WristPlan.Face(total: 0, goal: 2_000).millilitreLine(in: english, locale: en) == "0 of 2,000 ml")
        #expect(WristPlan.Face(total: 12_500, goal: 10_000).millilitreLine(in: english, locale: en) == "12,500 of 10,000 ml")

        let others: [(Bundle, Locale, String, String)] = [
            (russian, AppLanguage.russian.locale, "мл", "12502000"),
            (uzbek, AppLanguage.uzbek.locale, "ml", "20001250"),
        ]
        for (strings, locale, unit, digitsInOrder) in others {
            let text = WristPlan.Face(total: 1_250, goal: 2_000).millilitreLine(in: strings, locale: locale)
            #expect(text.hasSuffix(" \(unit)"), "\(text) does not end in its own unit")
            #expect(text.filter(\.isNumber) == digitsInOrder, "\(text) lost, gained or misplaced a digit")
            #expect(!text.contains("1250") && !text.contains("2000"), "\(text) is not grouped")
            #expect(!text.contains(","), "\(text) groups with the English separator")
        }
    }
```

  In `LocalizationTests.swift`: `watchSharedKeys` gains `"%1$@ of %2$@ ml"` and
  `"%1$@, add %2$d millilitres"`; in `countedKeys`, `"%1$@, add %2$d millilitres"`'s `bundles: ["app"]`
  → `bundles: ["app", "watch"]`.

- [ ] **Step 2: Run RED.** A watch unit run, `-only-testing:WaterBuddyWatchTests/WristViewLogicTests`:
  fails to compile (`pourRow`, `pourLabel`, `amountLabel`). A phone unit run,
  `-only-testing:WaterBuddyTests/LocalizationTests -only-testing:WaterBuddyTests/PluralFormTests`:
  fails on values — the two keys missing from the watch's tables.

- [ ] **Step 3: Implement the functions**, in `WristView`, after `secondary(from:)`:

```swift
    /// The row under the vessel: every serving the screen offers, in `vesselSlots` order, the Glass
    /// always among them.
    ///
    /// **Built from ``primary(from:)`` and ``secondary(from:)``, never from the raw servings** (the
    /// redesign's §9.2): a mirror too short to name a middle vessel still leaves a Glass that pours
    /// the default, because on this screen the row is the only action there is. A slot whose amount
    /// the mirror does not carry is left out, as the menu always left it out.
    nonisolated static func pourRow(from mirror: WristMirror?) -> [WristServing] {
        let primary = primary(from: mirror)
        let others = secondary(from: mirror)
        return vesselSlots.compactMap { slot in
            slot.nameKey == primary.nameKey ? primary : others.first { $0.nameKey == slot.nameKey }
        }
    }

    /// A pour button's VoiceOver label — the phone's own quick-add sentence (`HomeView`), so a
    /// serving is spoken alike on both devices, in the form its count takes.
    nonisolated static func pourLabel(for serving: WristServing, strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$@, add %2$d millilitres", serving.name(in: strings), serving.amount, locale: locale)
    }

    /// The amount a button carries — inside the Glass's capsule, under a disc — grouped as `locale`
    /// groups it.
    nonisolated static func amountLabel(_ amount: Int, strings: Bundle, locale: Locale) -> String {
        strings.localized("%1$d ml", amount, locale: locale)
    }
```

  `primaryIndex` (`:126`–`:137`) is **deleted**, its DocC with it, and `primary(from:)` and
  `secondary(from:)` read `DataManager.usualSlot` in its place — the one name for the slot every
  one-tap door logs (#104).

- [ ] **Step 4: Add the two keys** to `WaterBuddyWatch/Localizable.xcstrings`, with Xcode closed (P2).
  Print each entry exactly as the app catalogue holds it, nested for the watch file's depth:

```bash
python3 -I -c '
import json, sys
app = json.load(open("WaterBuddy/Localizable.xcstrings"))["strings"]
for key in ["%1$@ of %2$@ ml", "%1$@, add %2$d millilitres"]:
    block = json.dumps({key: app[key]}, ensure_ascii=False, indent=2)
    print("\n".join("  " + line for line in block.splitlines()[1:-1]) + ",")
'
```

  Insert each with Edit, in code-point order: `"%1$@ of %2$@ ml"` and then
  `"%1$@, add %2$d millilitres"` directly after `"%1$@ / %2$@ ml"`'s entry (removed in Task 6) and
  before `"%1$d ml"`'s. Then check, read-only, that the file still round-trips and holds the app's
  values:

```bash
python3 -I -c '
import json
raw = open("WaterBuddyWatch/Localizable.xcstrings", encoding="utf-8").read(); d = json.loads(raw)
app = json.load(open("WaterBuddy/Localizable.xcstrings"))["strings"]
assert json.dumps(d, ensure_ascii=False, indent=2) + "\n" == raw, "does not round-trip"
assert list(d["strings"]) == sorted(d["strings"]), "keys out of order"
for k in ["%1$@ of %2$@ ml", "%1$@, add %2$d millilitres"]: assert d["strings"][k] == app[k], k
print("ok")
'
```

- [ ] **Step 5: Run GREEN** — the same two runs. Expected: `WristViewLogicTests` passes (the three
  readout-era tests still compile: `WristVessel.readout` goes in Task 6); `LocalizationTests` and
  `PluralFormTests` pass.

---

### Task 6: 7b — the screen

**Files:**
- Create: `WaterBuddyWatch/WristColumn.swift`
- Modify: `WaterBuddyWatch/WristVessel.swift`, `WaterBuddyWatch/WristView.swift`,
  `WaterBuddyWatch/Localizable.xcstrings` (−4 keys), `WaterBuddyTests/LocalizationTests.swift`
- Test: `WaterBuddyWatchTests/WristVesselLayoutTests.swift`

**Interfaces:**
- Consumes: `WristPlan.Face`, `WristModel.face` (Task 4); `pourRow`, `pourLabel`, `amountLabel`
  (Task 5)
- Produces: `WristColumn(height: CGFloat, vessel: ClosedRange<CGFloat>)`, `WristColumn.gap`,
  `WristColumn.diameter(available:others:range:)`; `WristView.vesselRange(screenWidth:)`;
  `WristVessel(face: WristPlan.Face, diameter: CGFloat)`

- [ ] **Step 1: Write the failing tests.** In `WristVesselLayoutTests`, delete
  `theVesselNeverExceedsTheAvailableWidth` and `reservingMoreSpaceShrinksTheVessel` — they test
  `diameter(fitting:reserving:)`, removed in this task (#84(d)); the first one's claim is held for the
  function that stays by `theVesselFitsInsideBothItsWidthAndItsHeight`. Add:

```swift
    /// The vessel takes what the line and the row leave, between its floor and its ceiling
    /// (spec 2026-10-20 §3.4) — `HomeView.vesselDiameter`'s arithmetic, one device over.
    @Test
    func theVesselTakesWhatTheLineAndTheRowLeave() {
        #expect(WristColumn.diameter(available: 210, others: 100, range: 60...100) == 100, "held at its ceiling")
        #expect(WristColumn.diameter(available: 180, others: 100, range: 60...100) == 80)
        #expect(WristColumn.diameter(available: 140, others: 100, range: 60...100) == 60, "held at its floor; the screen scrolls")
    }

    /// The canvas drew a 100 pt vessel on the 46 mm screen's 208 pt; every watch keeps that share as
    /// its ceiling, and none goes under the 60 pt floor below which the readout stops being legible.
    @Test(arguments: [(CGFloat(162), CGFloat(77.88)), (CGFloat(208), CGFloat(100)), (CGFloat(100), CGFloat(60))])
    func theCeilingIsTheCanvasShareOfTheScreen(width: CGFloat, ceiling: CGFloat) {
        let range = WristView.vesselRange(screenWidth: width)
        #expect(range.lowerBound == 60)
        #expect(abs(range.upperBound - ceiling) < 0.01)
    }
```

  In `LocalizationTests.swift`: `watchOwnKeys` loses `"%1$@ / %2$@ ml"`, `"Logs %1$d millilitres"`,
  `"More"` and `"Shows the other serving sizes"`; `countedKeys` loses the `"Logs %1$d millilitres"`
  entry; `expected(…)` loses its three `"Logs %1$d millilitres"` cases.

- [ ] **Step 2: Run RED** — a watch unit run, `-only-testing:WaterBuddyWatchTests/WristVesselLayoutTests`:
  fails to compile (`WristColumn`, `vesselRange`).

- [ ] **Step 3: `WaterBuddyWatch/WristColumn.swift`:**

```swift
//
//  WristColumn.swift
//  WaterBuddyWatch
//

import SwiftUI

/// The watch screen's column: the vessel, the line under it and the pour row, with the vessel given
/// what the other two leave of the visible height (spec 2026-10-20 §3.4).
///
/// A `Layout`, not a stack, for `HomeColumn`'s reason one device over (rule `50-views`): a stack
/// inside a scroll view is never offered less than its ideal height, so it cannot shrink the vessel
/// to make room for the row. Here every other child is measured at its own height, the vessel takes
/// ``diameter(available:others:range:)``, and the height still spare is split above the vessel and
/// above the row. Below the vessel's floor the column outgrows the screen, and the screen scrolls —
/// on 40 mm and 42 mm, as the redesign's §9.2 allows. The sync caption sits below the column, outside
/// it, reached by a turn of the crown, as the canvas drew it.
struct WristColumn: Layout {

    /// The visible height to fill.
    var height: CGFloat

    /// The diameters the vessel may take.
    var vessel: ClosedRange<CGFloat>

    /// Which child is the vessel.
    private static let vesselIndex = 0

    /// Between the vessel and the line, and between the line and the row. The canvas's figure.
    nonisolated static let gap: CGFloat = 6

    /// What the rest of the column leaves of the visible height, held inside `range`.
    nonisolated static func diameter(available: CGFloat, others: CGFloat, range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(available - others, range.lowerBound), range.upperBound)
    }

    private func arrangement(width: CGFloat, _ subviews: Subviews) -> (heights: [CGFloat], spare: CGFloat) {
        var heights = subviews.map { $0.sizeThatFits(ProposedViewSize(width: width, height: nil)).height }
        guard heights.indices.contains(Self.vesselIndex) else { return (heights, 0) }

        heights[Self.vesselIndex] = 0
        let gaps = Self.gap * CGFloat(max(0, subviews.count - 1))
        let others = heights.reduce(0, +) + gaps
        let diameter = min(Self.diameter(available: height, others: others, range: vessel), width)
        heights[Self.vesselIndex] = diameter
        return (heights, max(0, height - others - diameter))
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.replacingUnspecifiedDimensions().width
        let plan = arrangement(width: width, subviews)
        let gaps = Self.gap * CGFloat(max(0, subviews.count - 1))
        return CGSize(width: width, height: plan.heights.reduce(0, +) + gaps + plan.spare)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = arrangement(width: bounds.width, subviews)
        var y = bounds.minY + plan.spare / 2

        for (index, subview) in subviews.enumerated() {
            if index > 0 { y += Self.gap }
            if index == subviews.count - 1, index != Self.vesselIndex { y += plan.spare / 2 }
            let height = plan.heights[index]
            let width = index == Self.vesselIndex ? height : bounds.width
            subview.place(at: CGPoint(x: bounds.midX, y: y), anchor: .top,
                          proposal: ProposedViewSize(width: width, height: height))
            y += height
        }
    }
}
```

- [ ] **Step 4: `WristVessel` becomes a display.** Its stored properties become
  `let face: WristPlan.Face` and `let diameter: CGFloat`; its body:

```swift
    var body: some View {
        ZStack {
            WaterSurface(level: face.progress, phase: 0, amplitude: diameter * 0.02)
                .clipShape(Circle())
                .padding(6)
            WaterReadabilityScrim(diameter: diameter, intensity: Self.scrimIntensity(at: face.progress))
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                // `HomeView`'s own spelling: formatted against the injected locale.
                Text(face.percentage, format: .number)
                    .font(.system(size: diameter * Self.figureShare, weight: .bold, design: .rounded))
                Text("%")
                    .font(.system(size: diameter * Self.signShare, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        // One element again, now that it is no control (rule `65-accessibility`): the label and the
        // value the pour button used to carry for it.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(face.spokenFigures(in: strings, locale: locale))
    }

    /// The percentage and its sign as shares of the diameter — the canvas's 32 and 14 pt in its 100 pt
    /// vessel. A ratio, never a text style: the vessel is a capped container (rule `65-accessibility`).
    nonisolated static let figureShare: CGFloat = 0.32
    nonisolated static let signShare: CGFloat = 0.14
```

  Delete `diameter(fitting:reserving:)` and `readout(volume:goal:strings:locale:)`, and the
  `diameter(fitting:within:)` DocC's paragraph comparing it with the deleted function. Rewrite the
  type's DocC: the vessel draws and describes itself — one element with the label and the value —
  because since stage 7 it is a display, not the pour button; the button-era history moves to one
  sentence citing spec 2026-10-20 §3.4. The `#Preview` becomes
  `WristVessel(face: .sample, diameter: 100).background(WristAurora())`.

- [ ] **Step 5: `WristView`.** Add, at file scope beside the other layout constants, each with DocC:

```swift
/// A pour disc's diameter: the canvas's 46 pt, scaled with type and held between the 44 pt floor rule
/// `65-accessibility` sets and ``wristDiscCeiling``.
nonisolated let wristDiscDiameter: CGFloat = 46

/// The most a disc grows with type. Past it the row stops fitting and scrolls sideways instead
/// (rule `65-accessibility`: never shrink a control to make the set fit).
nonisolated let wristDiscCeiling: CGFloat = 56

/// The least air between two panes in the row — glass discs may never share an edge
/// (rule `60-design-system`). The spare width is spread between them, so on the 46 mm screen the
/// gaps come out at the canvas's 8 pt.
nonisolated let wristRowMinimumGap: CGFloat = 4

/// Between a disc and the amount under it.
nonisolated let wristAmountSpacing: CGFloat = 3

/// Inside the Glass's capsule, either side of its glyph and amount — the canvas's 84 pt capsule
/// around a 20 pt glyph, a 4 pt gap and a ~48 pt amount, rounded up. Wider, and the capsule row
/// would not fit the 46 mm screen's 192 pt with its 4 pt gaps.
nonisolated let wristCapsuleSideInset: CGFloat = 8

/// A pour glyph as a share of its disc — the canvas's 22 pt in 46 pt, rounded down. A ratio, never a
/// text style: the disc is a capped container (rule `60-design-system`).
nonisolated let wristGlyphShare: CGFloat = 0.46
```

  and in `WristView`:

```swift
    /// The canvas's vessel against its screen: 100 pt on the 46 mm watch's 208 pt.
    nonisolated static let canvasVesselShare: CGFloat = 100.0 / 208.0

    /// The diameters the vessel may take on a screen this wide: the 60 pt floor below which its
    /// readout stops being legible, up to the canvas's share of the screen.
    nonisolated static func vesselRange(screenWidth: CGFloat) -> ClosedRange<CGFloat> {
        60...max(60, screenWidth * canvasVesselShare)
    }
```

  The `body` becomes:

```swift
    var body: some View {
        let face = model.face

        return ZStack {
            WristAurora()

            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: WristColumn.gap) {
                        WristColumn(height: proxy.size.height, vessel: Self.vesselRange(screenWidth: proxy.size.width)) {
                            vessel(face)
                            lineUnderTheVessel(face)
                            WristPourRow(
                                servings: Self.pourRow(from: model.mirror),
                                glassID: Self.primary(from: model.mirror).id
                            ) { model.pour(amount: $0) }
                        }
                        attributionLine
                    }
                    .padding(.horizontal, wristScreenInset)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .onReceive(clock) { now = $0 }
    }

    /// The vessel, drawn and spoken; no longer a button (D5).
    private func vessel(_ face: WristPlan.Face) -> some View {
        GeometryReader { proxy in
            WristVessel(face: face, diameter: WristVessel.diameter(fitting: proxy.size.width, within: proxy.size.height))
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }
    }

    /// *1,240 of 2,000 ml*, out of the water and under the vessel (#44). Hidden: the vessel speaks
    /// the same figures (rule `65-accessibility`).
    private func lineUnderTheVessel(_ face: WristPlan.Face) -> some View {
        Text(face.millilitreLine(in: strings, locale: locale))
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
```

  and a new `private struct` after `WristView`, replacing `WristServingMenu`:

```swift
/// The three pour buttons (spec 2026-10-20 §3.4). Two whole rows, one chosen — the Glass as a capsule
/// carrying its amount where the row has room, three discs where it has not — and a sideways scroll
/// past the largest text sizes, where even three discs do not fit (rule `65-accessibility`).
private struct WristPourRow: View {

    let servings: [WristServing]
    let glassID: String
    let pour: (Int) -> Void

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @ScaledMetric(relativeTo: .body) private var scaledDisc: CGFloat = wristDiscDiameter

    private var disc: CGFloat { min(max(scaledDisc, wristMinimumTarget), wristDiscCeiling) }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            row(glassCarriesItsAmount: true)
            row(glassCarriesItsAmount: false)
            ScrollView(.horizontal) { row(glassCarriesItsAmount: false) }
        }
        .frame(maxWidth: .infinity)
        .glassGroup()
    }

    private func row(glassCarriesItsAmount: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(servings.enumerated()), id: \.element.id) { index, serving in
                if index > 0 { Spacer(minLength: wristRowMinimumGap) }
                column(serving, glassCarriesItsAmount: glassCarriesItsAmount)
            }
        }
    }

    private func column(_ serving: WristServing, glassCarriesItsAmount: Bool) -> some View {
        let isGlass = serving.id == glassID
        let inside = isGlass && glassCarriesItsAmount
        return VStack(spacing: wristAmountSpacing) {
            Button { pour(serving.amount) } label: { face(of: serving, isGlass: isGlass, carriesAmount: inside) }
                .buttonStyle(.plain)
                .accessibilityLabel(WristView.pourLabel(for: serving, strings: strings, locale: locale))
            if !inside {
                Text(WristView.amountLabel(serving.amount, strings: strings, locale: locale))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize()
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private func face(of serving: WristServing, isGlass: Bool, carriesAmount: Bool) -> some View {
        if carriesAmount {
            HStack(spacing: wristAmountSpacing) {
                Image(systemName: serving.symbol)
                Text(WristView.amountLabel(serving.amount, strings: strings, locale: locale)).fixedSize()
            }
            .font(.footnote.weight(.heavy))
            .fontDesign(.rounded)
            .padding(.horizontal, wristCapsuleSideInset)
            .frame(minWidth: disc, minHeight: disc)
            // The screen's one primary surface; it sets its label's colour (rule `60-design-system`).
            .primarySurface(in: Capsule(), ring: false)
            .contentShape(Capsule())
        } else if isGlass {
            Image(systemName: serving.symbol)
                .font(.system(size: disc * wristGlyphShare, weight: .semibold))
                .frame(width: disc, height: disc)
                .primarySurface(in: Circle(), ring: false)
                .contentShape(Circle())
        } else {
            Image(systemName: serving.symbol)
                .font(.system(size: disc * wristGlyphShare, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: disc, height: disc)
                // A control: the glass is what is pressed, so Apple's regular, tinted variant.
                .liquidGlass(in: Circle(), density: .sheer, interactive: true)
                .contentShape(Circle())
        }
    }
}
```

  Delete: `vesselHeightFraction`, `isMenuPresented`, the `.sheet`, `vessel(boxedInto:)`,
  `menuButton(offering:)`, `WristServingMenu`, and `wristCapsuleInset` and `wristCapsuleVerticalInset`
  with their DocC — only the menu and the sheet used them (`grep -n wristCapsule WaterBuddyWatch/`
  proves it after the edit). Rewrite the file's header comment: the one screen —
  the vessel, the line, the row of three pour buttons, the sync caption — per the redesign's §9 and
  spec 2026-10-20 §3.4; the earlier tap-to-pour vessel and *More* sheet were reversed by D5. Update
  `body`'s DocC: the screen is never gated on the phone (kept), a `ScrollView` not a `List` (kept),
  and the column replacing the fraction. Update `primary(from:)`'s DocC ("The serving the vessel
  itself pours" → "The serving the Glass button pours") and `secondary(from:)`'s ("the menu's whole
  contents" → "Cup and Bottle — the rest of the row").

- [ ] **Step 6: Remove the four keys** from `WaterBuddyWatch/Localizable.xcstrings` with Edit, Xcode
  closed: `"%1$@ / %2$@ ml"`, `"Logs %1$d millilitres"`, `"More"`, `"Shows the other serving sizes"`.
  Re-run Task 5's read-only round-trip check, with `assert not set(["%1$@ / %2$@ ml", "Logs %1$d millilitres", "More", "Shows the other serving sizes"]) & set(d["strings"])` added. Then check every key the watch's code asks for is in its
  catalogue (`tasks/lessons.md`, 2026-10-06):

```bash
grep -ohE '(Text\("|forKey: "|localized\("|figure\(")[^"]+' WaterBuddyWatch/*.swift WaterBuddy/WristPlan.swift | sed -E 's/^[^"]*"//' | sort -u
```

  — each printed key must be in the watch catalogue (`%` included).

- [ ] **Step 7: Run GREEN** — a watch unit run, the whole `WaterBuddyWatchTests`, on both runtimes;
  a phone unit run, `-only-testing:WaterBuddyTests/LocalizationTests -only-testing:WaterBuddyTests/PluralFormTests`;
  a watch widget build. Expected: all pass; `** BUILD SUCCEEDED **`; no warning naming a watch file
  beyond the two known `Combine` lines.

- [ ] **Step 8: Shoot the screen** with **the screen probe** on *WaterBuddy Probe Watch 46*,
  `-WristProbeTotal 1300 -WristProbeGoal 2000`, and look at it beside the canvas's board *Watch*
  (spec Provenance): the vessel's size against 100 pt, the line, the capsule, the discs and their
  amounts. If the 46 mm render's vessel is not within 4 pt of the canvas's, or the row is not the
  capsule row, stop and show the owner the shot before going on.

---

### Task 7: 7b — the scrim, re-derived

**Files:**
- Modify: `WaterBuddyWatch/WristVessel.swift` (`scrimFullStrengthLevel` and its DocC,
  `scrimIntensity(at:)`'s DocC)
- Test: `WaterBuddyWatchTests/WristViewLogicTests.swift` (`:274`–`:322`)

- [ ] **Step 1: Measure where the percentage's ink ends.** In a probe copy (`P`, as **the screen
  probe** makes one), a throwaway test file `$P/WaterBuddyWatchTests/InkProbe.swift` renders the empty
  vessel with `ImageRenderer` at each diameter and prints the lowest ink row below the centre, as a
  share of the diameter:

```swift
import SwiftUI
import Testing
@testable import WaterBuddyWatch

@MainActor
struct InkProbe {
    @Test(arguments: [60.0, 80, 100, 123])
    func inkBelowCentre(diameter: Double) throws {
        let view = WristVessel(face: WristPlan.Face(total: 0, goal: 2_000), diameter: diameter)
            .environment(\.strings, Bundle.main).environment(\.locale, Locale(identifier: "en"))
            .background(Color.black)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let image = try #require(renderer.uiImage?.cgImage)
        let data = try #require(image.dataProvider?.data as Data?)
        let width = image.width, height = image.height, row = image.bytesPerRow
        var lowest = 0
        // Down to 0.3 of the height below the centre: the figure cannot reach lower, and the lit
        // rim's bottom arc, at 0.5, must not be read as ink.
        for y in (height / 2)..<(height / 2 + Int(Double(height) * 0.3)) {
            for x in (width / 4)..<(3 * width / 4) {
                let i = y * row + x * 4
                if data[i] > 200 && data[i + 1] > 200 && data[i + 2] > 200 { lowest = y }
            }
        }
        print("INK diameter=\(diameter) share=\(Double(lowest - height / 2) / Double(height))")
    }
}
```

  Run it on *WaterBuddy Probe Watch 46* (`-only-testing:WaterBuddyWatchTests/InkProbe`) and read the
  four `INK` lines. Take the largest share, rounded **up** to two decimals, so the ink is assumed lower
  than it is: `ink`. Expected near 0.12; outside 0.08…0.16, stop — the render is not what was
  assumed — and show the owner. Check one render by eye (save it with `pngData()` to `$S`).
- [ ] **Step 2: Rewrite the scrim tests** (`:274`–`:322`) for the percentage. Keep
  `anEmptyWatchVesselLaysDownNoScrim` and `theWatchScrimRampsUpWithTheWaterBelowFullStrength`
  unchanged. Replace `theWatchScrimIsAtFullStrengthBeforeWaterCanReachTheMillilitreLine` with these
  two, `<ink>` being Step 1's figure written as a literal:

```swift
    /// Where water first reaches the percentage — since stage 7 the vessel's lowest readout, the
    /// millilitre line having moved out of the water (#44) — worked out from the vessel's own
    /// geometry, not from the code under test: the water sits in a well inset 6 pt from the rim, its
    /// wave peaks `0.02 × diameter` above the mean surface, and the figure's lowest ink sits
    /// `<ink> × diameter` below the centre — measured off `ImageRenderer` renders at 60, 80, 100 and
    /// 123 pt and rounded up (spec 2026-10-20 §3.4).
    private static func waterReachesThePercentage(_ diameter: Double) -> Double {
        let inset = 6.0
        let crest = 0.02 * diameter
        let inkBottom = <ink> * diameter
        return (diameter / 2 - inset - crest - inkBottom) / (diameter - 2 * inset)
    }

    /// Full strength before water can be behind the figure, on every size: the percentage is large
    /// text held to 3:1, and a ramp still climbing as water reaches it would give contrast away.
    @Test(arguments: [60.0, 80, 100, 123])
    func theWatchScrimIsAtFullStrengthBeforeWaterCanReachThePercentage(diameter: Double) {
        #expect(WristVessel.scrimIntensity(at: Self.waterReachesThePercentage(diameter)) == 1)
        #expect(WristVessel.scrimIntensity(at: 1) == 1)
    }

    /// And no sooner than it needs to be: below where water reaches the figure, only glass is behind
    /// it, and the scrim is "only as much shade as there is water to hold back"
    /// (`WaterReadabilityScrim`). The ramp the millilitre line needed — full by 20% — darkened the
    /// vessel for nothing once the line left the water.
    @Test
    func belowWhereWaterReachesThePercentageTheScrimIsStillRamping() {
        let earliest = [60.0, 80, 100, 123].map(Self.waterReachesThePercentage).min()!
        #expect(WristVessel.scrimIntensity(at: earliest - 0.05) < 1)
    }
```

- [ ] **Step 3: Run RED** — a watch unit run, `-only-testing:WaterBuddyWatchTests/WristViewLogicTests`.
  Expected: `belowWhereWaterReachesThePercentageTheScrimIsStillRamping` fails — at 0.2 the ramp is
  already full there, a wrong value.
- [ ] **Step 4: Implement.** `scrimFullStrengthLevel` = the least of the four
  `waterReachesThePercentage` values, rounded **down** to two decimals. Its DocC and
  `scrimIntensity(at:)`'s are rewritten from the millilitre line to the percentage: the formula, the
  four measured shares, the 3:1 floor, and that the line's 4.5:1 figures (#44) no longer apply because
  the line is no longer over water.
- [ ] **Step 5: Run GREEN**, on both runtimes. Expected: `WristViewLogicTests` passes.

---

### Task 8: 7b — verification, records, staging

- [ ] **Step 1: The gate** (above), on the staged tree.
- [ ] **Step 2: The warning comparison**, every scheme.
- [ ] **Step 3: The simulator pass** (spec §8.3), with **the screen probe**:
  - On all five *WaterBuddy Probe Watch* sizes (27.0) and *WaterBuddy Probe Watch 26*:
    `-WristProbeTotal 0`, `1300`, `2600` (past the goal), and `-WristProbeServings 150,1000,1500`.
  - On 46 mm and 40 mm: `-WristProbeLanguage ru` and `uz`; `-WristProbeReduceTransparency`; and the
    largest accessibility text size (`xcrun simctl ui $UDID content_size accessibility-extra-extra-extra-large`,
    a relaunch, then `large` again) — where the row must fall to its sideways scroll rather than
    shrink a disc.
  - Look at every shot. Measure, with **the contrast sampler**: the line (4.5:1), each disc's glyph
    (3:1), each amount under a disc (4.5:1), the percentage at 62% and at 100% over water (3:1), on
    both runtimes. A pair under its floor stops the stage and goes to the owner.
  - The owner pours once from each button on *WaterBuddy Probe Watch 46* by clicking it, and the
    amount on screen moves by that button's serving.
- [ ] **Step 4: Records.** `HISTORY.md`, `## [<date>] — Roadmap item 1.3.2, stage 7b: the watch's
  screen`. `docs/DESIGN.md`: the watch's pairs, the ramp's new derivation, the disc and capsule tokens.
  `docs/AI_CONTEXT.md`: *Current state*; rows (`WristColumn.swift` new; every changed file re-counted);
  `@Test` counts; **retired** #44, #84(d), #104; **#20** noted (the watch's two copies are one); a note
  on #45 — `Tools/CaptureWatchScreenshot.sh` still tells a human to tap "the pour button", which is
  now the row. `docs/ROADMAP.md`; the spec's status; this plan's boxes.
- [ ] **Step 5: Stage by name** — every file Tasks 4–8 changed, and the records — and show
  `git diff --cached --name-status` beside `git diff --name-status`.
- [ ] **Step 6: Stop.** The owner runs `/commit`, then `/doc_sync`.

---

### Task 9: 7c — the faces' strings

**Files:**
- Modify: `WaterBuddyWatchWidget/Localizable.xcstrings` (+3 keys); `WaterBuddyTests/LocalizationTests.swift`

**Interfaces:**
- Produces: `watchWidgetSharedKeys` in `LocalizationTests.swift`; the three keys in the watch widget's
  catalogue, which Task 10's faces draw.

- [ ] **Step 1: Write the failing test.** In `LocalizationTests.swift`, after `watchOwnKeys`:

```swift
/// Every phone string a watch face draws or speaks, copied into the complication's own catalogue
/// value for value (spec 2026-10-20 §3.7). *Today's hydration* is also its gallery description.
private let watchWidgetSharedKeys = [
    "Today's hydration",
    "Hydration",
    "%1$@ of %2$@ ml",
    "%1$d percent. %2$d of %3$d millilitres.",
]
```

  In `theWatchAgreesWithThePhoneOnEverySharedString`, the three lines from
  `let description = "Today's hydration"` to the end of its `#expect` become:

```swift
        for key in watchWidgetSharedKeys {
            let phone = sentences(appBundle, language, key)
            #expect(phone != nil, "\"\(key)\" is missing from the phone's \(language) table — nothing to agree with")
            #expect(sentences(watchWidgetBundle, language, key) == phone,
                    "\"\(key)\" differs between the phone and the watch's faces in \(language)")
        }
```

  In `countedKeys`, `"%1$d percent. %2$d of %3$d millilitres."`'s bundles gain `"watchWidget"`, and
  `shipped(_:)` gains `case "watchWidget": watchWidgetBundle`.

- [ ] **Step 2: Run RED** — a phone unit run,
  `-only-testing:WaterBuddyTests/LocalizationTests -only-testing:WaterBuddyTests/PluralFormTests`.
  Expected: failures on values — three keys missing from the watch widget's tables.

- [ ] **Step 3: Add the three keys** to `WaterBuddyWatchWidget/Localizable.xcstrings`, Xcode closed:
  print them with Task 5's script over `["%1$@ of %2$@ ml", "%1$d percent. %2$d of %3$d millilitres.", "Hydration"]`
  (`Hydration` from the app catalogue; the sentence is the app's, value for value), insert with Edit
  before `"Today's hydration"` in code-point order — `%1$@ of …`, `%1$d percent …`, `Hydration` — and
  run the round-trip check over this file with those three keys.

- [ ] **Step 4: Run GREEN** — the same phone run. Expected: pass.

---

### Task 10: 7c — the entry and the three faces

**Files:**
- Modify: `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift`
- Create: `WaterBuddyWatchWidget/WristFaceView.swift`

**Interfaces:**
- Consumes: `WristPlan.face(…)`, `WristPlan.Face.sample` (Task 4); `AppLanguage(code:)`; the keys
  Task 9 added
- Produces: `WristWidgetEntry(date: Date, face: WristPlan.Face, language: AppLanguage)`,
  `WristFaceRoot(entry:)`, `WristFaceView(face: WristPlan.Face, family: WidgetFamily)`

Steps 1 and 2 land together: the app scheme compiles the watch widget (#69), so the tree must not be
built between them.

- [ ] **Step 1: The entry and the provider.** In `WaterBuddyWatchWidget.swift`:

```swift
struct WristWidgetEntry: TimelineEntry {
    let date: Date
    /// Today's figures, from `WristPlan.face(…)` — the function the screen reads too.
    let face: WristPlan.Face
    /// The phone's choice, carried on the mirror, as `WristModel.language` resolves it — so the
    /// faces draw the screen's language, not the watch's (rule `70-privacy`).
    let language: AppLanguage
}
```

  `placeholder(in:)` returns `WristWidgetEntry(date: .now, face: .sample, language: .system)`.
  `entry(at:mirror:outbox:calendar:)` becomes:

```swift
    private func entry(at date: Date, mirror: WristMirror?, outbox: [WristPour], calendar: Calendar) -> WristWidgetEntry {
        // The face has to agree with the app beside it: same store, same fallback, same arithmetic.
        WristWidgetEntry(
            date: date,
            face: WristPlan.face(mirror: mirror, outbox: outbox, now: date, calendar: calendar),
            language: AppLanguage(code: mirror?.languageCode)
        )
    }
```

  The configuration's view closure becomes `WristFaceRoot(entry: entry)` and
  `.supportedFamilies([.accessoryCircular])` → `.supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])`.
  The file's header comment: three families, all display-only (spec 2026-10-20 §3.6).

- [ ] **Step 2: Write `WristFaceView.swift`:**

```swift
//
//  WristFaceView.swift
//  WaterBuddyWatchWidget
//
//  The complication's three faces — circular, rectangular, corner — all display-only: a tap opens
//  the watch app. Every figure is `.privacySensitive()`, and each shape draws a quiet form when
//  watchOS redacts (spec 2026-10-20 §3.6, rule `70-privacy`).
//

import SwiftUI
import WidgetKit

/// Injects the language and the background once, above every face — a view cannot read an
/// environment value it injects itself (`tasks/lessons.md`, 2026-10-08).
struct WristFaceRoot: View {

    let entry: WristWidgetEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        WristFaceView(face: entry.face, family: family)
            // watchOS asks every widget to declare its background, as iOS does; a face draws none.
            .containerBackground(for: .widget) { Color.clear }
            .environment(\.strings, entry.language.bundle)
            .environment(\.locale, entry.language.locale)
    }
}

/// The shape for a family. Takes the family as a parameter — `widgetFamily` cannot be set — so a
/// render can draw any shape outside a face.
struct WristFaceView: View {

    let face: WristPlan.Face
    let family: WidgetFamily

    var body: some View {
        switch family {
        case .accessoryRectangular: WristFaceCard(face: face)
        case .accessoryCorner: WristFaceCorner(face: face)
        default: WristFaceRing(face: face)
        }
    }
}

// MARK: - Circle

/// Today's open ring, the drop and the percentage — unchanged to the eye.
private struct WristFaceRing: View {

    let face: WristPlan.Face

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            Gauge(value: 0.0) {
                EmptyView()
            } currentValueLabel: {
                Image(systemName: "drop.fill")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Aurora.blue)
            .widgetAccentable()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            Gauge(value: face.progress) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text(face.percentage, format: .number.locale(locale))
                    .minimumScaleFactor(0.4)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Aurora.blue)
            .widgetAccentable()
            .privacySensitive()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(face.spokenFigures(in: strings, locale: locale))
        }
    }
}

// MARK: - Corner

/// The percentage in the corner, a curved gauge along the bezel.
private struct WristFaceCorner: View {

    let face: WristPlan.Face

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            Image(systemName: "drop.fill")
                .font(.title3.weight(.semibold))
                .widgetAccentable()
                .widgetLabel {
                    Gauge(value: 0.0) { EmptyView() }
                        .tint(Aurora.blue)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            // `.percent` under the injected locale: Russian writes *100 %*, so three digits are
            // checked in every language (`tasks/lessons.md`, 2026-10-08).
            Text(face.percentage, format: .percent.locale(locale))
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .minimumScaleFactor(0.4)
                .widgetAccentable()
                .privacySensitive()
                .widgetLabel {
                    Gauge(value: face.progress) { EmptyView() }
                        .tint(Aurora.blue)
                        .privacySensitive()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("Today's hydration", bundle: strings))
                .accessibilityValue(face.spokenFigures(in: strings, locale: locale))
        }
    }
}

// MARK: - Rectangle

/// A header — the drop, *Hydration*, the percentage — the app screen's own line, and a bar.
private struct WristFaceCard: View {

    let face: WristPlan.Face

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        let quiet = redactionReasons.contains(.privacy)

        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Label {
                    Text("Hydration", bundle: strings)
                } icon: {
                    Image(systemName: "drop.fill")
                }
                Spacer(minLength: 4)
                if !quiet {
                    Text(face.percentage, format: .percent.locale(locale))
                        .privacySensitive()
                }
            }
            .font(.headline)
            .widgetAccentable()

            // The quiet form keeps the line's height, so the bar does not move up the face.
            Text(quiet ? " " : face.millilitreLine(in: strings, locale: locale))
                .font(.body.weight(.semibold))
                .privacySensitive()

            Gauge(value: quiet ? 0 : face.progress) { EmptyView() }
                .gaugeStyle(.accessoryLinearCapacity)
                .tint(Aurora.blue)
                .widgetAccentable()
                .privacySensitive()
        }
        .lineLimit(1)
        .minimumScaleFactor(0.6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration", bundle: strings))
        .accessibilityValue(quiet ? "" : face.spokenFigures(in: strings, locale: locale))
    }
}

// MARK: - Previews

#Preview("Circle", as: .accessoryCircular) {
    WaterBuddyWatchWidget()
} timeline: {
    WristWidgetEntry(date: .now, face: .sample, language: .system)
}

#Preview("Rectangle", as: .accessoryRectangular) {
    WaterBuddyWatchWidget()
} timeline: {
    WristWidgetEntry(date: .now, face: .sample, language: .system)
}

#Preview("Corner", as: .accessoryCorner) {
    WaterBuddyWatchWidget()
} timeline: {
    WristWidgetEntry(date: .now, face: .sample, language: .system)
}
```

- [ ] **Step 3: Build** — **a watch widget build**, then a phone unit run of
  `-only-testing:WaterBuddyTests/LocalizationTests` (the app scheme compiles the watch widget too).
  Expected: `** BUILD SUCCEEDED **` with no warning naming `WaterBuddyWatchWidget/`, and the run
  passing. A failure here is a compile error to fix, not a test to reshape.
- [ ] **Step 4: The face probe.** In a probe copy, copy `WaterBuddyWatchWidget/WristFaceView.swift`
  into `$P/WaterBuddyWatch/` with `WristFaceRoot` and the previews deleted (the watch app has no
  `WristWidgetEntry` or `WaterBuddyWatchWidget`), and add `$P/WaterBuddyWatchTests/FaceProbe.swift`:

```swift
import SwiftUI
import Testing
import WidgetKit
@testable import WaterBuddyWatch

@MainActor
struct FaceProbe {
    private static let out = URL(fileURLWithPath: ProcessInfo.processInfo.environment["FACE_PROBE_OUT"]!)
    private static let sizes: [WidgetFamily: CGSize] = [
        .accessoryCircular: CGSize(width: 50, height: 50),
        .accessoryRectangular: CGSize(width: 178, height: 64),
        .accessoryCorner: CGSize(width: 40, height: 40),
    ]

    @Test(arguments: ["en", "ru", "uz"])
    func renderEveryFace(language: String) throws {
        let app = AppLanguage(code: language)
        for (family, size) in Self.sizes {
            for (name, face) in [("62", WristPlan.Face.sample), ("100", WristPlan.Face(total: 2_000, goal: 2_000)),
                                 ("999", WristPlan.Face(total: 40_000, goal: 2_000))] {
                for quiet in [false, true] {
                    for mode in [WidgetRenderingMode.fullColor, .accented] {
                        let view = WristFaceView(face: face, family: family)
                            .redacted(reason: quiet ? .privacy : [])
                            .environment(\.widgetRenderingMode, mode)
                            .environment(\.strings, app.bundle).environment(\.locale, app.locale)
                            .frame(width: size.width, height: size.height)
                            .background(Color.black)
                        let renderer = ImageRenderer(content: view)
                        renderer.scale = 2
                        let png = try #require(renderer.uiImage?.pngData())
                        let file = "face-\(family)-\(name)-\(language)-\(quiet ? "quiet" : "shown")-\(mode == .accented ? "accented" : "full").png"
                        try png.write(to: Self.out.appending(path: file))
                    }
                }
            }
        }
    }
}
```

  Run it (`-only-testing:WaterBuddyWatchTests/FaceProbe`, with `TEST_RUNNER_FACE_PROBE_OUT=$S/faces`
  in the environment and `$S/faces` created first) on *WaterBuddy Probe Watch 46*. Look at every image:
  each quiet form shows no figure and no fill; Russian and Uzbek fit at three digits; the rectangle's
  line reads as the screen's. The probe cannot draw the corner's curved label or a real face's
  vibrancy — the owner's placement (Task 11) shows those.

---

### Task 11: 7c — verification, records, staging

- [ ] **Step 1: The gate**, on the staged tree.
- [ ] **Step 2: The warning comparison**, every scheme.
- [ ] **Step 3: The faces on a face** (spec §8.3). Install the index copy's watch app on
  *WaterBuddy Probe Watch 46* and *WaterBuddy Probe Watch 26*, launched once with
  `-WristProbeTotal 1300` so the gallery offers the widget (`tasks/lessons.md`, 2026-10-20). **The
  owner** places the circle, the rectangle and the corner on a watch face on each — one face tinted —
  by hand in the simulator; then `xcrun simctl io <udid> screenshot` of each, and every shot looked
  at. Relaunch with `-WristProbeTotal 0` and with `-WristProbeLanguage ru`, and shoot again: the faces
  follow, after the app's own reload.
- [ ] **Step 4: Records.** `HISTORY.md`, `## [<date>] — Roadmap item 1.3.2, stage 7c: three faces`.
  `docs/AI_CONTEXT.md`: *Current state*; rows (`WristFaceView.swift` new); counts; a **new known
  issue** for the device sweep — the faces' quiet form on a locked watch and in Always On with
  complication data off, VoiceOver on the wrist for the row and the faces, the discs' press, the
  screen on a watch running 26.x — joining 1.2.7's sweep. `docs/ROADMAP.md`: 1.3.2 built; its device
  checks into 1.2.7. `docs/WIDGET.md`: a note that the watch's faces are spec 2026-10-20's (the sheet
  covers the phone's widgets). The spec's status; this plan's boxes. `CLAUDE.md` is `/doc_sync`'s: the
  target table's watch widget row, the gate's six invocations, the faces among the things placed by
  hand.
- [ ] **Step 5: Stage by name**, show both diffs.
- [ ] **Step 6:** A fresh read-only reviewer on the whole staged change before the closing report;
  its findings checked at their source. **Stop** — the owner runs `/commit`, then `/doc_sync`.
