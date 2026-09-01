# WaterBuddy on the Wrist — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a real Apple Watch companion for WaterBuddy that pours water and shows the phone's
hydration state, kept in sync over WatchConnectivity — no account, no server, nothing leaving the
paired pair of devices.

**Architecture:** The phone's SwiftData store stays the single source of truth; the watch holds no
SwiftData store at all, only an append-only *outbox* of pours it authored and a *mirror* of what the
phone last told it, both in its own watch-local App Group suite. The watch authors exactly one verb —
**pour** — positive, commutative, idempotent under `WaterLog.id`. Pours travel wrist→phone over
`transferUserInfo` (durable, chunked, does not coalesce), opportunistically woken by `sendMessage`;
the mirror travels phone→wrist over `updateApplicationContext` (a property, not an event). An
explicit per-day "applied" ledger, checked together with a full scan of existing rows, is what makes
a re-sent or already-deleted pour a no-op instead of a duplicate or a resurrection.

**Tech Stack:** Swift 5 (`SWIFT_VERSION = 5.0`), SwiftUI, SwiftData (phone only), WatchConnectivity,
swift-testing (`@Test`/`#expect`) + XCTest, Xcode 26.6, iOS 26.5 + watchOS 26.5 SDKs.

**Spec:** `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` (see §14 for the owner
approval and the reconciliation against this session's placeholder watch target; §11 for the
sequence this plan implements; §4 for the wire protocol; §6 for the concurrency constraints; §8 for
the watch screen; §9/§9.1/§9.2 for the rule amendments). This plan argues from that spec — read both.

## Global Constraints

These apply to every task below, copied from `CLAUDE.md` and `.claude/rules/` (the spec cites the
same rules per-section; this collects the ones that recur across tasks):

- **TDD, verified RED before GREEN.** Write the failing test, run it, confirm the failure message
  matches what's expected, *then* implement (rule `00-workspace`, `85-testing`).
- **No floating-point millilitres.** Every volume is `Int`.
- **No unpinned `Date()` in logic.** The clock is injected (`now: () -> Date` or a parameter);
  `Date()`/`Date.init` is a default argument only, never called inside a function body that isn't a
  composition root (rule `30-rollover`).
- **The day is an ordinal, an instant is a `Date`.** Never persist a day as a `Date`; never derive a
  day boundary from anything but `Calendar.waterBuddyDay` (rule `30-rollover`).
- **A failed read is never written back as data loss.** `nil` means "could not tell", `[]` means
  "nothing" — the two must never collapse into each other (rule `20-state`).
- **Treat every new compiler warning as a failure.** This codebase compiles clean at zero warnings on
  every target; a new one blocks the task (rule `43-concurrency`, `85-testing`).
- **A test fixture may never reach real data.** Every fixture builds a throwaway `UserDefaults`
  suite (`UUID`-named, torn down in a `defer`) and an in-memory `ModelContainer` where applicable;
  never touch `group.sardor.WaterBuddy` or `UserDefaults.standard` from a test (rule `85-testing`).
- **`@MainActor` is not free.** `WCSessionDelegate` callbacks land on a non-main serial queue — never
  assume main-actor isolation there; hop explicitly with `Task { @MainActor in ... }`, never
  `MainActor.assumeIsolated` (rule `43-concurrency`, spec §6).
- **No bare `print`.** Every diagnostic is `#if DEBUG`, names the failing condition, never a user
  value (rule `75-diagnostics`).
- **Run the gate in the foreground, one simulator, `-parallel-testing-enabled NO`.** Shut down all
  simulators first each time (`xcrun simctl shutdown all`) (rule `85-testing`).
- **Stage, never commit.** Every task ends with `git add` of exactly the files it touched (this repo
  has no `.git` yet — see Task 0). Nobody runs `git commit` except the owner, via `/commit`
  (rule `90-git`).
- **Checkpoint in `HISTORY.md` and run `/doc_sync` after the plan completes**, not after every task —
  the spec's own convention is one reconciliation pass covering a batch of related changes, not one
  per commit (see `docs/superpowers/specs/...design.md` HISTORY.md entries for the pattern to match).

## File Structure

**New, shared** (land in `WaterBuddy/`, reachable by the watch target through a new
`PBXFileSystemSynchronizedBuildFileExceptionSet` — Task 9):
- `WaterBuddy/WristPlan.swift` — pure day-bucketing of the watch's local outbox, `ReminderPlan`'s
  twin. `import Foundation` only, no `Date()`, clock and calendar injected.

**Modified, shared:**
- `WaterBuddy/DataManager.swift` — gains, behind `#if canImport(WatchConnectivity)`: `WristPour`,
  `WristBatch`, `WristMirror` (the wire structs), `WristLink` (the `WCSessionDelegate` wrapper), and
  three new `Key`s. Gains, unconditionally: `ingest(_:)` (folds received pours through the applied
  ledger) and the `@available(watchOS, unavailable)` markers on `shared`, `sharedModelContainer` and
  `init`.
- `WaterBuddy/WaterSurface.swift` — gains a relocated `vesselSlots` constant (moved out of
  `HomeView.swift`, which is app-only and therefore unreachable from the watch) so both `HomeView`
  and the watch's own vessel view can name the same three vessels the same way.
- `WaterBuddy/HomeView.swift` — `vesselSlots` removed (now reads the relocated constant).
- `WaterBuddy/WaterBuddyApp.swift` — `init()` gains `WristLink.live.activate()` and constructs
  `WristInbox.shared`.

**New, app-only** (physically in `WaterBuddy/`, but *not* added to the watch's exception set —
the phone never needs the watch to see these):
- `WaterBuddy/WristInbox.swift` — `@MainActor` class; the chunk-reassembly buffer for incoming
  `WristBatch` transfers, calling `DataManager.shared.ingest(_:)` once a batch is complete and
  composing/publishing the next `WristMirror` after every phone-side mutation.

**New, watch-only** (physically in `WaterBuddyWatch/`, the watch's own synchronized folder — no
exception-set entry needed, since nothing else reads them):
- `WaterBuddyWatch/WristModel.swift` — `@MainActor @Observable`; the watch's whole state: the local
  outbox, the last-received mirror, `pour(amount:)`.
- `WaterBuddyWatch/WristAurora.swift` — proportional-`UnitPoint` aurora sized for a watch canvas,
  `WidgetAurora`'s twin (not `AuroraBackground`'s — that one uses absolute phone-screen offsets).
- `WaterBuddyWatch/WristVessel.swift` — the glass vessel, composed from the shared `WaterSurface` +
  `LiquidGlassModifier` + `Aurora` palette, watch-sized.
- `WaterBuddyWatch/WristView.swift` — the one screen (§8): vessel, three pour rows, "Synced Nm ago".
- `WaterBuddyWatch/WaterBuddyWatchApp.swift` — rewritten from the placeholder `Text("WaterBuddy")`.
- `WaterBuddyWatch/ContentView.swift` — **deleted**; `WristView.swift` replaces it.

**New test files:**
- `WaterBuddyTests/WristSyncTests.swift` — wire struct round-trips, `ingest(_:)`'s conjunction guard
  (both halves), `WristPlan` bucketing, `WristInbox` chunk reassembly. All run by the *existing* iOS
  gate — no new build target needed for this file (matches spec §11 step 4: "no new build target
  yet").
- `WaterBuddyWatchTests/` (new watchOS unit-test target, Task 10) — `WristModelTests.swift`,
  `WristLinkCompileTests.swift` (a compile-time canary, see Task 10).

**Modified project files:**
- `WaterBuddy.xcodeproj/project.pbxproj` — Task 9 (watch target rework, entitlement wiring, deployment
  target fix), Task 10 (new `WaterBuddyWatchTests` target), Task 18 (new `WaterBuddyWatchWidget`
  target).
- `Entitlements/WaterBuddyWatch.entitlements` — new file, same App Group string as the other two.
- `.claude/rules/*.md`, `CLAUDE.md`, `docs/*.md` — Task 19 (the doc/rule cascade).

**Deliberately not created:** any watch-side delete/edit of a pour, a goal editor, settings, history,
or reminders on the watch (owner-confirmed v1 scope, §12, §14).

---

### Task 1: Fix the watchOS compile blocker in `LiquidGlassModifier`

**Files:**
- Modify: `WaterBuddy/LiquidGlassModifier.swift:111-117`
- Test: `WaterBuddyTests/LiquidGlassTests.swift`

**Interfaces:**
- Consumes: `LiquidGlass.Base.archived` (existing, `LiquidGlassModifier.swift:106-109`)
- Produces: `LiquidGlass.Base.opaqueFill` now returns the same `Color` for `.material` as
  `.archived` does, instead of `Color(.secondarySystemBackground)` — which every task touching the
  watch's vessel or glass panes (Tasks 15, 16) depends on compiling at all.

This is the one and only reason `WaterSurface.swift` cannot currently be compiled into a watchOS
target: `Color(.secondarySystemBackground)` doesn't exist on watchOS. Rather than adding a second
copy of the literal `Color(red: 0.22, green: 0.19, blue: 0.36)` — which would violate rule
`60-design-system`'s "the only permitted literals outside Aurora are ... `LiquidGlass.Base.archived`"
— `.material`'s case delegates to `.archived.opaqueFill`, so there is exactly one place the number
lives.

- [ ] **Step 1: Write the failing test**

Add to `WaterBuddyTests/LiquidGlassTests.swift` (new suite in the same file, alongside
`LiquidGlassInteractionTests` — not `@MainActor`, these are pure values):

```swift
/// The **flat** half of the design system: what a pane draws when it cannot sample a backdrop —
/// a WidgetKit widget, or (after this suite) a watchOS target, which has no
/// `Color(.secondarySystemBackground)` at all.
struct LiquidGlassBaseTests {

    /// `.material`'s Reduce-Transparency fill must equal `.archived`'s — not merely "some
    /// colour". If a future edit reintroduces a system-material colour here, this is the test
    /// that catches it before the watch target stops compiling again.
    @Test
    func materialAndArchivedAgreeUnderReduceTransparency() {
        #expect(LiquidGlass.Base.material(.thin).opaqueFill == LiquidGlass.Base.archived.opaqueFill)
    }

    /// `.flat`'s own opaque fill is returned verbatim, never substituted.
    @Test
    func flatReturnsItsOwnOpaqueFillUnchanged() {
        let fill = Color(red: 0.5, green: 0.1, blue: 0.9)
        let base = LiquidGlass.Base.flat(translucent: .clear, opaque: fill)
        #expect(base.opaqueFill == fill)
    }
}
```

- [ ] **Step 2: Run the test to verify it fails**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/LiquidGlassBaseTests -parallel-testing-enabled NO
```

Expected: `materialAndArchivedAgreeUnderReduceTransparency` **FAILS** — `.material`'s fill is
`Color(.secondarySystemBackground)`, `.archived`'s is `Color(red: 0.22, green: 0.19, blue: 0.36)`,
and they are not equal. `flatReturnsItsOwnOpaqueFillUnchanged` **PASSES** already (this is the
existing, correct behaviour) — that's expected and fine; the point of writing it alongside the
failing one is that Task 1's fix must not disturb it.

- [ ] **Step 3: Make the fix**

In `WaterBuddy/LiquidGlassModifier.swift`, replace:

```swift
        /// The fill that replaces the whole stack when Reduce Transparency is on.
        var opaqueFill: Color {
            switch self {
            case .material: Color(.secondarySystemBackground)
            case .flat(_, let opaque): opaque
            }
        }
```

with:

```swift
        /// The fill that replaces the whole stack when Reduce Transparency is on.
        ///
        /// `.material` delegates to `.archived.opaqueFill` rather than a system colour: the app
        /// and the widget already agree here (rule `65-accessibility`: "the widget draws ... a
        /// contrast threshold, not taste"), and `Color(.secondarySystemBackground)` does not exist
        /// on watchOS — this is the fix for the one compile error that blocks `WaterSurface.swift`
        /// from joining a watch target (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md`
        /// §13). Never add a second literal here: `Base.archived` is the one place the number lives.
        var opaqueFill: Color {
            switch self {
            case .material: Base.archived.opaqueFill
            case .flat(_, let opaque): opaque
            }
        }
```

- [ ] **Step 4: Run the test to verify it passes**

Same command as Step 2. Expected: both tests **PASS**.

- [ ] **Step 5: Run the full existing gate — this line is read by every glass pane in the app**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: all three `** TEST SUCCEEDED **` / `** BUILD SUCCEEDED **`, zero new warnings. This is a
production behaviour change (Reduce Transparency's appearance moves for every `.material`-based pane
in the shipping app) — run the app on the simulator with Reduce Transparency on afterward and confirm
no pane reads as a flat system grey.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/LiquidGlassModifier.swift WaterBuddyTests/LiquidGlassTests.swift
```

---

### Task 2: The `@available(watchOS, unavailable)` compile guard

**Files:**
- Modify: `WaterBuddy/DataManager.swift:140` (`shared`), `:394-401` (`init`), `:1132` (`sharedModelContainer`)
- Test: `WaterBuddyTests/DataManagerTests.swift` (a compile-time canary — see Step 1)

**Interfaces:**
- Consumes: nothing new.
- Produces: `DataManager.shared`, `DataManager.sharedModelContainer`, and `DataManager.init(...)`
  become **unusable from watchOS code**, at compile time. Every later task that writes watch-side
  code (Tasks 13, 14) must never reference any of these three — that is now enforced by the
  compiler, not by discipline, which is the whole point of this task per spec §3.2.

This step turns six *runtime* guards (`Self.role.ownsSharedStorage` etc., already landed) into a
*compile* guard on the three entry points a watch process could otherwise reach them through. It
does **not** touch the `Role` enum, which is already correct and already four-state — do not "fix"
it back to three states; that was a defect in the spec's first draft, not a target.

There is no failing runtime test possible here — this is a compile-time property. Per the spec:
"An unavailable declaration may reference other unavailable declarations, so `shared`'s initialiser
and `init`'s default arguments still type-check." That claim is unproven against this Xcode version;
Step 1 below proves it before Step 2 commits to it everywhere.

- [ ] **Step 1: Probe — does an unavailable default argument actually type-check here?**

This is not a spike to throw away (unlike Task 8) — it's a two-minute check inline, because if it
fails the whole approach needs rethinking before editing production code. In a scratch file
(anywhere outside the four synchronized folders, e.g. `/tmp/probe.swift`):

```swift
struct Probe {
    @available(watchOS, unavailable)
    static func a() -> Int { 1 }

    @available(watchOS, unavailable)
    static func b(x: Int = Probe.a()) -> Int { x }
}
```

```
xcrun -sdk watchos swiftc -typecheck -target arm64_32-apple-watchos11.0 -swift-version 5 /tmp/probe.swift
```

Expected: **no error** — an unavailable declaration may reference another unavailable declaration in
its default argument. If this fails, stop and report before touching `DataManager.swift`; the guard
would need a different shape (e.g. splitting `init`'s defaulted parameters out).

- [ ] **Step 2: Apply the three markers**

In `WaterBuddy/DataManager.swift`:

```swift
    // MARK: - Shared instance

    @available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores. Use WristModel and WristPlan.")
    static let shared = DataManager()
```

```swift
    @available(watchOS, unavailable, message: "The watch holds no WaterLog store. See rule 25-shared-storage.")
    nonisolated static let sharedModelContainer: ModelContainer = {
```
(the existing body of `sharedModelContainer` is unchanged — only the marker is added above its
declaration)

```swift
    @available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores.")
    init(
        defaults: UserDefaults = DataManager.sharedDefaults,
        modelContainer: ModelContainer = DataManager.sharedModelContainer,
        calendar: Calendar = .waterBuddyDay,
        now: @escaping () -> Date = Date.init,
        reloadWidgets: @escaping () -> Void = DataManager.requestWidgetReload,
        rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule
    ) {
```
(the existing body of `init` is unchanged — only the marker is added above its signature)

- [ ] **Step 3: Verify the iOS gate is untouched — these markers must be invisible on the platform that actually uses them**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

Expected: unchanged pass count (259 tests before this task; still 259 after — `@available(watchOS,
unavailable)` has zero effect when compiling for iOS), zero new warnings.

- [ ] **Step 4: Verify the guard actually blocks watchOS — compile a probe that tries to use it**

In the same scratch location as Step 1 (never inside a synchronized folder):

```swift
// probe2.swift — expected to FAIL to compile once WaterBuddy/DataManager.swift, WaterBuddy/WaterLog.swift,
// WaterBuddy/ReminderPlan.swift are copied alongside it (copy, don't move — this is a throwaway check)
_ = DataManager.shared
```

```
xcrun -sdk watchos swiftc -typecheck -target arm64_32-apple-watchos11.0 -swift-version 5 \
  probe2.swift DataManager.swift WaterLog.swift ReminderPlan.swift
```

Expected: `error: 'shared' is unavailable in watchOS`. This is the proof the guard works — a watch
target genuinely cannot construct a `DataManager` any more, not "shouldn't", "can't".

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/DataManager.swift
```

---

### Task 3: The wire structs — `WristPour`, `WristBatch`, `WristMirror`

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — new section near `WaterSnapshot` (`:1479`)
- Test: `WaterBuddyTests/WristSyncTests.swift` (new file)

**Interfaces:**
- Produces: `WristPour { let id: UUID; let amount: Int; let at: Date }`,
  `WristBatch { let schemaVersion: Int; let batchId: UUID; let chunkIndex: Int; let chunkCount: Int; let pours: [WristPour] }`
  with `static let currentSchemaVersion = 1` and `static let maximumPoursPerChunk = 64`,
  `WristMirror { let schemaVersion: Int; let currentWater: Int; let dailyGoal: Int; let servings: [Int]; let languageCode: String?; let isGoalSet: Bool; let composedAt: Date; let phoneDayStart: Date; let acked: [UUID] }`
  with `static let currentSchemaVersion = 1` and `static let maximumAckedIds = 256`. All three:
  `Codable, Sendable, Equatable`. Every later task that touches the wire (Tasks 5, 7, 12, 13, 14)
  consumes these exact three types.

Per spec §4: everything is JSON-encoded to `Data` under one dictionary key, because WatchConnectivity
accepts property-list types only and `UUID`/`Date` are not among them. `schemaVersion` is what lets
the two independently-updatable binaries refuse a payload from the other's future.

- [ ] **Step 1: Write the failing tests**

New file `WaterBuddyTests/WristSyncTests.swift`:

```swift
//
//  WristSyncTests.swift
//  WaterBuddyTests
//

import Foundation
import Testing
@testable import WaterBuddy

/// The wire protocol's own round-trip. Not `@MainActor` — these are plain `Codable` values with no
/// actor isolation, and keeping the suite off the main actor is the same canary
/// `LiquidGlassInteractionTests` already is (rule `43-concurrency`).
struct WristWireTests {

    @Test
    func aWristPourRoundTripsThroughJSON() throws {
        let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
        let data = try JSONEncoder().encode(pour)
        let decoded = try JSONDecoder().decode(WristPour.self, from: data)
        #expect(decoded == pour)
    }

    @Test
    func aWristBatchRoundTripsThroughJSON() throws {
        let batch = WristBatch(
            schemaVersion: WristBatch.currentSchemaVersion,
            batchId: UUID(),
            chunkIndex: 0,
            chunkCount: 1,
            pours: [WristPour(id: UUID(), amount: 150, at: Date(timeIntervalSince1970: 2_000))]
        )
        let data = try JSONEncoder().encode(batch)
        let decoded = try JSONDecoder().decode(WristBatch.self, from: data)
        #expect(decoded == batch)
    }

    @Test
    func aWristMirrorRoundTripsThroughJSON() throws {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion,
            currentWater: 500,
            dailyGoal: 2_000,
            servings: [150, 250, 500],
            languageCode: "ru",
            isGoalSet: true,
            composedAt: Date(timeIntervalSince1970: 3_000),
            phoneDayStart: Date(timeIntervalSince1970: 2_900),
            acked: [UUID(), UUID()]
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = try JSONDecoder().decode(WristMirror.self, from: data)
        #expect(decoded == mirror)
    }

    /// `languageCode == nil` means "follow the device" (rule `70-privacy`'s "absence carries
    /// meaning") — it must round-trip as `nil`, not coerce into a sentinel string.
    @Test
    func aNilLanguageCodeRoundTripsAsNil() throws {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: nil, isGoalSet: false,
            composedAt: .now, phoneDayStart: .now, acked: []
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = try JSONDecoder().decode(WristMirror.self, from: data)
        #expect(decoded.languageCode == nil)
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/WristWireTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `cannot find 'WristPour' in scope` (and likewise for the other two).
This is a compile-red, not a runtime-red, and that's fine — the type doesn't exist yet.

- [ ] **Step 3: Implement the three structs**

In `WaterBuddy/DataManager.swift`, add a new section immediately after `WaterSnapshot`'s closing
brace (after `:1547` — search for `struct WaterSnapshot` and insert after its extension/closing, ahead
of `DaySummary`):

```swift
// MARK: - WatchConnectivity wire protocol

#if canImport(WatchConnectivity)

/// One pour, as the watch authored it. `id` becomes `WaterLog.id` verbatim on the phone — the merge
/// key already exists (`WaterLog.swift:33-37`, deliberately not `@Attribute(.unique)`), so this
/// struct invents no identity scheme of its own.
struct WristPour: Codable, Sendable, Equatable, Identifiable {
    let id: UUID
    /// Millilitres, like every other volume in this product (Global Constraints).
    let amount: Int
    /// An **instant**. Deliberately no `dayOrdinal` — a day stamped on one device and re-read on
    /// another names a day neither device may still be in (rule `30-rollover`, one device further
    /// out: `WristPlan` derives "today" itself, on read, from this instant).
    let at: Date
}

/// A batch of pours, wrist → phone. Chunked at ``maximumPoursPerChunk`` because
/// `WCErrorCodePayloadTooLarge` has no numeric threshold anywhere in the SDK — the cap is by
/// construction, not by catching the error after the fact.
struct WristBatch: Codable, Sendable, Equatable {
    /// An unrecognised version is **not** acked by the phone, so the watch keeps retrying rather
    /// than silently losing pours to a binary that doesn't understand them yet.
    let schemaVersion: Int
    /// Groups this batch's chunks back together and doubles as the coalescing key if the same
    /// batch is ever re-sent.
    let batchId: UUID
    let chunkIndex: Int
    let chunkCount: Int
    let pours: [WristPour]

    static let currentSchemaVersion = 1
    static let maximumPoursPerChunk = 64
}

/// What the phone last told the watch, phone → wrist. Delivered as a **property**
/// (`updateApplicationContext`/`receivedApplicationContext`), never an event stream — the watch
/// reads whatever the phone most recently composed, with no ordering dependency and no callback
/// needed on wake.
struct WristMirror: Codable, Sendable, Equatable {
    let schemaVersion: Int
    let currentWater: Int
    let dailyGoal: Int
    /// All three quick-add vessels, positional, so the wrist's row is the phone's row
    /// (`DataManager.servings`, `:238-253`) — never a single "the" serving.
    let servings: [Int]
    /// `nil` means "follow the device" — the same absence-carries-meaning rule
    /// `AppLanguage`/`Key.language` already follow (rule `70-privacy`). Never a sentinel string.
    let languageCode: String?
    let isGoalSet: Bool
    /// An instant: when the phone composed this mirror, for the watch's "Synced Nm ago" line.
    let composedAt: Date
    /// The phone's `startOfDay`, **as an instant** — compared against the watch's own day, never
    /// stored as an ordinal the watch would have to re-interpret under its own time zone
    /// (rule `30-rollover`, spec §5).
    let phoneDayStart: Date
    /// Pour ids the phone has already folded, oldest-applied first, capped at
    /// ``maximumAckedIds`` — this is what lets the watch retire a pour from its own outbox.
    let acked: [UUID]

    static let currentSchemaVersion = 1
    static let maximumAckedIds = 256
}

#endif
```

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all four `WristWireTests` **PASS**.

- [ ] **Step 5: Run the existing gate**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: both green, zero new warnings. The widget build matters here specifically: `#if
canImport(WatchConnectivity)` is `true` on iOS (the framework exists there too, for the phone side of
the pairing), so these three structs now compile into the **widget extension** as well as the app —
confirm that doesn't introduce a name collision or an unused-import warning.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/WristSyncTests.swift
```

---

### Task 4: Three new `Key`s and `ingest(_:)` — the conjunction guard

**Files:**
- Modify: `WaterBuddy/DataManager.swift:90-136` (the `Key` enum), new `ingest(_:)` method near
  `addLog(amount:at:)` (`:493`)
- Test: `WaterBuddyTests/DataManagerTests.swift` (existing `everyKeyTheProductWritesIsOnTheRoster`),
  `WaterBuddyTests/WristSyncTests.swift` (new `WristIngestTests`)

**Interfaces:**
- Consumes: `WristPour` (Task 3), `DataManager.allLogs()` (existing, `:541`), `DataManager.now`,
  `DataManager.calendar`, `DataManager.dayOrdinal(for:in:)` (existing, `:987`), `DataManager.refresh()`
  and `saveAndRecompute()` (existing, private, `:801`/`:647`).
- Produces: `func ingest(_ pours: [WristPour]) -> Int` (returns the count actually folded). `Key.wristOutbox`,
  `Key.wristMirror`, `Key.wristApplied`, added to `Key.all`. Task 7 (`WristInbox`) calls `ingest(_:)`
  once a batch is fully reassembled; Task 13 (`WristModel`) writes `wristOutbox`/`wristMirror` on the
  watch's own suite.

This closes both open questions spec §4 raised and left for this step to settle:

- **The scope of `existing`.** Checked against **all** rows, `allLogs()`, not just today's — a pour
  authored near midnight and delivered late could otherwise land past "today" on the phone while
  still being a duplicate of a row from days ago that the ledger's own day-bucket doesn't cover.
- **The ledger's day key.** Bucketed by the **pour's own day** (`dayOrdinal(for: pour.at, in:
  calendar)`), not "today" — the ledger's job is "was this specific pour already applied", which
  doesn't depend on what day it is on the phone right now.

`ingest(_:)` deliberately does **not** call `saveAndRecompute()` when nothing was folded — an
all-already-applied batch (the expected steady state once outbox and ledger agree) must cost no
write and ring no doorbell.

- [ ] **Step 1: Write the failing tests**

Add to `WaterBuddyTests/WristSyncTests.swift`:

```swift
/// `ingest(_:)`'s conjunction guard — the mechanism spec §4 built specifically because either half
/// alone leaves a real hole: without the applied ledger, an ordinary delete un-does itself when the
/// watch re-sends; without a full-history existence check, a resend past the ledger's own horizon
/// double-counts a serving forever.
@MainActor
struct WristIngestTests {

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

    private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
        let name = "test.waterbuddy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name); UserDefaults.standard.removeSuite(named: name) }
        return try body(defaults)
    }

    private func inMemoryContainer() -> ModelContainer {
        try! ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    private func makeManager(_ defaults: UserDefaults, now: @escaping () -> Date) -> DataManager {
        DataManager(
            defaults: defaults, modelContainer: inMemoryContainer(), calendar: Self.utc, now: now,
            reloadWidgets: {}, rescheduleReminders: { _ in }
        )
    }

    @Test
    func aFreshPourIsFolded() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let folded = manager.ingest([pour])
            #expect(folded == 1)
            #expect(manager.currentWater == 250)
        }
    }

    @Test
    func aResentPourAlreadyOnTheLedgerIsANoOp() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            _ = manager.ingest([pour])
            let secondPass = manager.ingest([pour])
            #expect(secondPass == 0)
            #expect(manager.currentWater == 250, "a resend must not double the total")
        }
    }

    /// The half `applied` alone cannot cover: the row was deleted, so it's no longer in `allLogs()`,
    /// but it's still on the ledger — must stay a no-op, or a delete undoes itself the moment the
    /// watch's outbox retries.
    @Test
    func aDeletedPourStillOnTheLedgerIsNotResurrected() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            _ = manager.ingest([pour])
            let log = manager.allLogs().first { $0.id == pour.id }!
            manager.deleteLog(log)
            #expect(manager.currentWater == 0)

            let resend = manager.ingest([pour])
            #expect(resend == 0, "the ledger must block the resend even though the row is gone")
            #expect(manager.currentWater == 0)
        }
    }

    /// The half `existing` alone cannot cover: past the ledger's own day-bucket, a resend must
    /// still not duplicate a row that is still there.
    @Test
    func aPourStillPresentButOffTheLedgerIsNotDuplicated() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let id = UUID()
            // Insert directly, bypassing ingest, so nothing is on the applied ledger for it —
            // simulates a row that predates this feature, or whose ledger entry aged out.
            manager.addLog(amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let existing = manager.allLogs().first!
            #expect(existing.amount == 250)

            let pour = WristPour(id: existing.id, amount: 250, at: Date(timeIntervalSince1970: 1_000))
            let folded = manager.ingest([pour])
            #expect(folded == 0, "existing must catch this even with no ledger entry")
            #expect(manager.allLogs().count == 1)
        }
    }

    @Test
    func anOutOfRangeAmountIsRejected() {
        withTempDefaults { defaults in
            let manager = makeManager(defaults, now: { Date(timeIntervalSince1970: 1_000) })
            let zero = WristPour(id: UUID(), amount: 0, at: Date(timeIntervalSince1970: 1_000))
            let negative = WristPour(id: UUID(), amount: -5, at: Date(timeIntervalSince1970: 1_000))
            let tooLarge = WristPour(id: UUID(), amount: DataManager.maximumDailyIntake + 1, at: Date(timeIntervalSince1970: 1_000))
            #expect(manager.ingest([zero, negative, tooLarge]) == 0)
        }
    }

    @Test
    func ingestingNothingNewRingsNoDoorbell() {
        withTempDefaults { defaults in
            var reloadCount = 0
            let manager = DataManager(
                defaults: defaults, modelContainer: inMemoryContainer(), calendar: Self.utc,
                now: { Date(timeIntervalSince1970: 1_000) },
                reloadWidgets: { reloadCount += 1 }, rescheduleReminders: { _ in }
            )
            let pour = WristPour(id: UUID(), amount: 250, at: Date(timeIntervalSince1970: 1_000))
            _ = manager.ingest([pour])
            let countAfterFirst = reloadCount
            _ = manager.ingest([pour])
            #expect(reloadCount == countAfterFirst, "a fully-applied batch must not write, and must not reload widgets")
        }
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/WristIngestTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `ingest` doesn't exist yet.

- [ ] **Step 3: Add the three keys**

In `WaterBuddy/DataManager.swift`'s `Key` enum:

```swift
    static let currentWater = prefix + "currentWater"
    static let dailyGoal = prefix + "dailyGoal"
    static let lastActiveDay = prefix + "lastActiveDay"
    static let isGoalSet = prefix + "isGoalSet"
    static let didMigrateFromStandard = prefix + "didMigrateFromStandardDefaults"
    static let remindersEnabled = prefix + "remindersEnabled"
    static let language = prefix + "language"
    static let servings = prefix + "servings"
    /// The watch's own pending pours, JSON-encoded `[WristPour]`. Written only by `WristModel`, in
    /// the watch's local App Group suite — never read or written from the phone.
    static let wristOutbox = prefix + "wristOutbox"
    /// The watch's last-received `WristMirror`, JSON-encoded. Written only by `WristModel`, so the
    /// watch has something to draw before the first `updateApplicationContext` of a fresh launch.
    static let wristMirror = prefix + "wristMirror"
    /// The phone's per-day applied ledger, JSON-encoded `[Int: [UUID]]` (day ordinal → ids already
    /// folded into `WaterLog`). Written only by `ingest(_:)`, in the phone's App Group suite.
    static let wristApplied = prefix + "wristApplied"
    static let all = [
        currentWater, dailyGoal, lastActiveDay, isGoalSet,
        didMigrateFromStandard, remindersEnabled, language, servings,
        wristOutbox, wristMirror, wristApplied,
    ]
```

- [ ] **Step 4: Implement `ingest(_:)`**

In `WaterBuddy/DataManager.swift`, immediately after `addLog(amount:at:)` (`:493-499`):

```swift
    #if canImport(WatchConnectivity)
    /// Folds pours received from the watch into the ledger.
    ///
    /// The guard is a **conjunction**, and each half closes a hole the other leaves open
    /// (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §4):
    /// - Without the applied ledger, an ordinary swipe-to-delete un-acks a pour still in the
    ///   watch's outbox; the resend finds nothing and re-inserts it. The deletion undoes itself.
    /// - Without a full-history existence check, a resend past the ledger's own day-bucket inserts
    ///   a **second** `WaterLog` with the same id — legal, since `WaterLog.id` is deliberately not
    ///   `@Attribute(.unique)` (two processes insert here) — and the serving counts twice, forever.
    ///
    /// The ledger is keyed by **the pour's own day**, not "today": its job is "was this specific
    /// pour already applied", which does not depend on what day it happens to be on the phone right
    /// now.
    ///
    /// - Returns: how many pours were actually folded. `0` — the expected steady state once the
    ///   watch's outbox and this ledger agree — writes nothing and rings no doorbell.
    @discardableResult
    func ingest(_ pours: [WristPour]) -> Int {
        refresh()

        var appliedByDay = readAppliedLedger()
        let existingIds = Set(allLogs().map(\.id))
        var foldedCount = 0

        for pour in pours where pour.amount > 0 && pour.amount <= Self.maximumDailyIntake {
            let day = Self.dayOrdinal(for: pour.at, in: calendar)
            guard !(appliedByDay[day]?.contains(pour.id) ?? false),
                  !existingIds.contains(pour.id) else { continue }
            modelContext.insert(WaterLog(id: pour.id, amount: pour.amount, timestamp: pour.at))
            appliedByDay[day, default: []].insert(pour.id)
            foldedCount += 1
        }

        guard foldedCount > 0 else { return 0 }
        // Real calendar-day subtraction, never arithmetic on the encoded ordinal: `dayOrdinal` is
        // `year*10_000 + month*100 + day`, and subtracting 90 from that integer is not "90 days
        // ago" — it borrows across the month/day radix incorrectly on every call, since 90 always
        // exceeds the maximum day-of-month, silently shortening retention to as little as a few
        // weeks. (Caught by task review, not by the six ingest tests, none of which exercised
        // trimming across a boundary — the fix task must add one that does.)
        let cutoffDate = calendar.date(byAdding: .day, value: -Self.appliedLedgerRetentionDays, to: now()) ?? now()
        let cutoff = Self.dayOrdinal(for: cutoffDate, in: calendar)
        Self.writeAppliedLedger(appliedByDay, to: defaults, keepingDaysSince: cutoff)
        saveAndRecompute()
        return foldedCount
    }

    /// How many days of the applied ledger to keep. Unbounded growth is bounded because every
    /// day's array only ever holds the ids the watch resent while offline for that long — but a
    /// number here is still safer than none, matching the spirit of the wire protocol's own
    /// construction bounds (`WristBatch.maximumPoursPerChunk`, `WristMirror.maximumAckedIds`).
    private static let appliedLedgerRetentionDays = 90

    /// `nonisolated static`, not a private instance method, so `requestWristPublish()` (Task 7) —
    /// which composes a `WristMirror`'s `acked` list — can read the same ledger from a context that
    /// holds no `DataManager` instance, exactly as `WaterSnapshot.snapshot(defaults:calendar:now:)`
    /// reads `currentWater` without one.
    nonisolated static func readAppliedLedger(from defaults: UserDefaults) -> [Int: Set<UUID>] {
        guard let data = defaults.data(forKey: Key.wristApplied),
              let raw = try? JSONDecoder().decode([Int: [UUID]].self, from: data) else { return [:] }
        return raw.mapValues(Set.init)
    }

    private func readAppliedLedger() -> [Int: Set<UUID>] {
        Self.readAppliedLedger(from: defaults)
    }

    nonisolated private static func writeAppliedLedger(
        _ ledger: [Int: Set<UUID>], to defaults: UserDefaults, keepingDaysSince cutoff: Int
    ) {
        let trimmed = ledger.filter { $0.key >= cutoff }
        let raw = trimmed.mapValues(Array.init)
        guard let data = try? JSONEncoder().encode(raw) else { return }
        defaults.set(data, forKey: Key.wristApplied)
    }
    #endif
```

- [ ] **Step 5: Run the tests to verify they pass**

Same command as Step 2. Expected: all six `WristIngestTests` **PASS**.

- [ ] **Step 6: Extend and re-run `everyKeyTheProductWritesIsOnTheRoster`**

```
grep -n "everyKeyTheProductWritesIsOnTheRoster" -A 30 WaterBuddyTests/DataManagerTests.swift
```

Add a driven call `manager.ingest([WristPour(id: UUID(), amount: 100, at: now())])` alongside the
test's other driven mutations, and raise `#expect(live.count >= 7)` to `#expect(live.count >= 8)`.

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/DataManagerTests/everyKeyTheProductWritesIsOnTheRoster \
  -parallel-testing-enabled NO
```

Expected: **PASSES** — `wristApplied` is now on both the roster and the live-write list.

- [ ] **Step 7: Run the full existing gate**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: all green, zero new warnings.

- [ ] **Step 8: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/DataManagerTests.swift WaterBuddyTests/WristSyncTests.swift
```

---

### Task 5: `WristPlan` — the watch's own pure day-bucketing

**Files:**
- Create: `WaterBuddy/WristPlan.swift`
- Test: `WaterBuddyTests/WristSyncTests.swift` (new `WristPlanTests`)

**Interfaces:**
- Consumes: `WristPour` (Task 3), `DataManager.dayOrdinal(for:in:)` (existing, `nonisolated static`).
- Produces: `WristPlan.todaysTotal(from pours: [WristPour], now: Date, calendar: Calendar) -> Int` —
  Task 12 (`WristModel`) is its only caller.

`ReminderPlan`'s twin, per spec §5: `import Foundation` alone, pure, no `Date()` inside, clock and
calendar injected — and it **filters**, it never rolls anything over, because the watch has no day
marker to stamp. There is deliberately no stored `dayOrdinal` on a `WristPour` (Task 3) — a stamp
made in one time zone and re-read in another names a day the device may no longer be in — so bucketing
happens here, on read, from each pour's own instant.

- [ ] **Step 1: Write the failing tests**

Add to `WaterBuddyTests/WristSyncTests.swift`:

```swift
/// Pure day-bucketing, `ReminderPlan`'s twin — no `UserNotifications`, no `WatchConnectivity`, no
/// `DataManager`. A compile-time canary in the same spirit as `ReminderPlanTests`: if a future edit
/// makes this suite need `@MainActor` or a store, something has leaked into the wrong layer.
struct WristPlanTests {

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

    @Test
    func sumsOnlyTodaysPours() {
        let now = Date(timeIntervalSince1970: 1_756_800_000) // an arbitrary fixed instant
        let today = WristPour(id: UUID(), amount: 250, at: now)
        let yesterday = WristPour(id: UUID(), amount: 500, at: now.addingTimeInterval(-86_400))
        let total = WristPlan.todaysTotal(from: [today, yesterday], now: now, calendar: Self.utc)
        #expect(total == 250)
    }

    @Test
    func emptyOutboxSumsToZero() {
        let total = WristPlan.todaysTotal(from: [], now: .now, calendar: Self.utc)
        #expect(total == 0)
    }

    /// A pour stamped just before midnight and one just after both count on their own day, never
    /// the other's — this is the seam a naive "within the last 24 hours" filter would get wrong.
    @Test
    func aPourAtTheDayBoundaryCountsOnItsOwnDay() {
        // 2026-01-02 00:00:00 UTC
        let midnight = Date(timeIntervalSince1970: 1_767_312_000)
        let justBefore = WristPour(id: UUID(), amount: 100, at: midnight.addingTimeInterval(-1))
        let justAfter = WristPour(id: UUID(), amount: 200, at: midnight)
        let total = WristPlan.todaysTotal(from: [justBefore, justAfter], now: midnight, calendar: Self.utc)
        #expect(total == 200)
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/WristPlanTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `cannot find 'WristPlan' in scope`.

- [ ] **Step 3: Implement**

New file `WaterBuddy/WristPlan.swift`:

```swift
//
//  WristPlan.swift
//  WaterBuddy
//
//  `ReminderPlan`'s twin (rule `80-notifications`'s "the plan decides, the applier only files and
//  unfiles" idiom, one layer over): this decides nothing about *whether* to sync, only *which* of
//  the watch's own outbox pours belong to today. Pure — `import Foundation` alone, no `Date()`
//  inside, the clock and calendar injected — so it is testable from the existing iOS gate with no
//  watch target and no `WatchConnectivity` import at all
//  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §5, §11 step 4).
//
//  Physically lives in `WaterBuddy/` rather than `WaterBuddyWatch/`, alongside the other files a
//  second target reaches through an exception set — not because the phone calls it (it doesn't),
//  but because this is where the existing test gate can prove it correct before any watch target
//  exists to run it on. It reaches the watch target through the exception set Task 9 adds.
//

import Foundation

enum WristPlan {

    /// The sum of `pours` whose `at` falls within `now`'s day, in `calendar`.
    ///
    /// **Never rolls anything over** — there is no marker to stamp, and no cache to reset. This
    /// simply filters, on every call, from each pour's own instant. A pour carries no stored day of
    /// its own (`WristPour` has none, deliberately): a stamp made in one time zone and re-read in
    /// another would name a day the watch may no longer be in.
    nonisolated static func todaysTotal(from pours: [WristPour], now: Date, calendar: Calendar) -> Int {
        let startOfToday = calendar.startOfDay(for: now)
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return 0
        }
        return pours
            .filter { $0.at >= startOfToday && $0.at < startOfTomorrow }
            .reduce(0) { $0 + $1.amount }
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all three `WristPlanTests` **PASS**.

- [ ] **Step 5: Run the existing gate**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: both green, zero new warnings. `WristPlan.swift` is **not** in the widget's
`membershipExceptions` (six files, unchanged by this task) and is not referenced from any widget
source, so the widget build should be identical to before this task — a regression here would mean
something reached across the boundary it shouldn't have.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/WristPlan.swift WaterBuddyTests/WristSyncTests.swift
```

---

### Task 6: `WristInbox` — reassembling chunked batches

**Files:**
- Create: `WaterBuddy/WristInbox.swift` (app-only — physically in `WaterBuddy/`, but never added to
  the watch's exception set: nothing on the watch reads it)
- Test: `WaterBuddyTests/WristSyncTests.swift` (new `WristInboxTests`)

**Interfaces:**
- Consumes: `WristBatch`, `WristPour` (Task 3), `DataManager.ingest(_:)` (Task 4).
- Produces: `@MainActor final class WristInbox { static let shared: WristInbox; func receive(_
  chunk: WristBatch) }`. Task 11 (`WristLink`) is `WristInbox`'s only caller, from
  `didReceiveUserInfo`.

Buffers `WristBatch` chunks by `batchId` until `chunkCount` chunks have arrived, then hands the
concatenated `pours` (chunks sorted by `chunkIndex` first — `transferUserInfo` promises no ordering)
to `DataManager.shared.ingest(_:)`. A chunk that never arrives is left in the buffer indefinitely
rather than dropped — the batch simply never completes, and the watch's own outbox (Task 12) is the
retry mechanism: it keeps resending until every pour is acked, so a stalled buffer self-heals on the
next successful full transfer rather than needing a timeout here.

- [ ] **Step 1: Write the failing tests**

Add to `WaterBuddyTests/WristSyncTests.swift`:

```swift
/// `WristInbox`'s only reference to `DataManager` is `.shared`, which cannot be swapped in a test —
/// so these tests drive `WristInbox` against a throwaway suite by constructing `DataManager.shared`
/// is not possible from a test at all (rule `85-testing` forbids reaching the real App Group). Test
/// the reassembly logic directly instead: `WristInbox.reassemble(_:)` is the pure half (sorts and
/// concatenates chunks, decides completeness) and is `nonisolated static` for exactly this reason —
/// it takes no dependency on `DataManager.shared` and so needs no fixture at all.
struct WristInboxReassemblyTests {

    private func chunk(_ batchId: UUID, _ index: Int, of count: Int, pours: [WristPour]) -> WristBatch {
        WristBatch(schemaVersion: WristBatch.currentSchemaVersion, batchId: batchId, chunkIndex: index, chunkCount: count, pours: pours)
    }

    @Test
    func aSingleChunkBatchIsCompleteImmediately() {
        let id = UUID()
        let pour = WristPour(id: UUID(), amount: 250, at: .now)
        let result = WristInbox.reassemble([chunk(id, 0, of: 1, pours: [pour])])
        #expect(result?.map(\.id) == [pour.id])
    }

    @Test
    func aPartialBatchIsNotYetComplete() {
        let id = UUID()
        let pour = WristPour(id: UUID(), amount: 250, at: .now)
        let result = WristInbox.reassemble([chunk(id, 0, of: 2, pours: [pour])])
        #expect(result == nil)
    }

    /// `transferUserInfo` promises no ordering — chunks must be sorted by `chunkIndex`, not by
    /// arrival order, before concatenation.
    @Test
    func chunksArriveOutOfOrderButReassembleInOrder() {
        let id = UUID()
        let first = WristPour(id: UUID(), amount: 150, at: .now)
        let second = WristPour(id: UUID(), amount: 250, at: .now)
        let result = WristInbox.reassemble([
            chunk(id, 1, of: 2, pours: [second]),
            chunk(id, 0, of: 2, pours: [first]),
        ])
        #expect(result?.map(\.amount) == [150, 250])
    }

    /// Chunks from a different `batchId` must never be mixed into this one's reassembly.
    @Test
    func chunksFromADifferentBatchAreIgnored() {
        let idA = UUID(); let idB = UUID()
        let pourA = WristPour(id: UUID(), amount: 150, at: .now)
        let pourB = WristPour(id: UUID(), amount: 999, at: .now)
        let result = WristInbox.reassemble([
            chunk(idA, 0, of: 1, pours: [pourA]),
            chunk(idB, 0, of: 1, pours: [pourB]),
        ])
        // Both are individually complete single-chunk batches — reassemble(_:) operates on
        // exactly one batch's accumulated chunks at a time; see Step 3's DocC for how the buffer
        // partitions by batchId before calling this.
        #expect(result?.map(\.amount) == [150])
    }

    @Test
    func anUnrecognisedSchemaVersionIsExcludedFromReassembly() {
        let id = UUID()
        let pour = WristPour(id: UUID(), amount: 250, at: .now)
        let stale = WristBatch(schemaVersion: WristBatch.currentSchemaVersion + 1, batchId: id, chunkIndex: 0, chunkCount: 1, pours: [pour])
        #expect(WristInbox.reassemble([stale]) == nil)
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/WristInboxReassemblyTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `cannot find 'WristInbox' in scope`.

- [ ] **Step 3: Implement**

New file `WaterBuddy/WristInbox.swift`:

```swift
//
//  WristInbox.swift
//  WaterBuddy
//
//  The chunk-reassembly buffer for pours arriving from the watch. App-only: it is the only thing in
//  this design that calls `DataManager.shared.ingest(_:)`, and only the phone ever does that.
//
//  Physically sits in `WaterBuddy/` but is **not** part of the watch's exception set — nothing on
//  the watch ever reads this file (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md`
//  §7: "a watch target's own exception set is a different contract ... and the watch's files are
//  invisible to the widget" — the same boundary holds in the other direction here).
//

#if canImport(WatchConnectivity)
import Foundation

@MainActor
final class WristInbox {

    static let shared = WristInbox()
    private init() {}

    /// Chunks accumulated so far, keyed by `batchId`. A batch missing a chunk stays here
    /// indefinitely — see the file's own header comment for why that's the right default rather
    /// than a ticking timeout.
    private var pending: [UUID: [WristBatch]] = [:]

    /// Called from `WristLink.session(_:didReceiveUserInfo:)`, already hopped onto the main actor.
    func receive(_ chunk: WristBatch) {
        pending[chunk.batchId, default: []].append(chunk)
        guard let pours = Self.reassemble(pending[chunk.batchId] ?? []) else { return }
        pending.removeValue(forKey: chunk.batchId)

        let folded = DataManager.shared.ingest(pours)
        if folded > 0 {
            DataManager.requestWristPublish()
        }
    }

    /// The pure half: given every chunk accumulated for **one** batch, decide whether it's complete
    /// and — if so — return its pours in `chunkIndex` order. `nil` means "not yet, or never will
    /// be" (a stale `schemaVersion` is folded into the same `nil`, rather than a separate case,
    /// because the caller's response is identical either way: keep waiting for a batch the sender
    /// will eventually retry at a version this binary understands).
    ///
    /// `nonisolated static` and free of `DataManager` on purpose — this is the half worth testing
    /// without a `DataManager.shared` a test fixture cannot swap out (rule `85-testing`).
    nonisolated static func reassemble(_ chunks: [WristBatch]) -> [WristPour]? {
        guard let batchId = chunks.first?.batchId else { return nil }
        let sameBatch = chunks.filter { $0.batchId == batchId && $0.schemaVersion == WristBatch.currentSchemaVersion }
        guard let expectedCount = sameBatch.first?.chunkCount, sameBatch.count == expectedCount else { return nil }
        return sameBatch
            .sorted { $0.chunkIndex < $1.chunkIndex }
            .flatMap(\.pours)
    }
}
#endif
```

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all five `WristInboxReassemblyTests` **PASS**.

- [ ] **Step 5: Run the existing gate**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: both green, zero new warnings. `DataManager.requestWristPublish()` is referenced here but
not implemented until Task 7 — **do this task's Step 5 together with Task 7**, since `WristInbox.swift`
will not compile on its own until `requestWristPublish` exists. (If executing strictly task-by-task,
implement Task 7 immediately after this task's Step 3, before running Step 5's gate.)

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/WristInbox.swift WaterBuddyTests/WristSyncTests.swift
```

---

### Task 7: `DataManager.requestWristPublish()` — the outgoing mirror

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — new static func near `requestWidgetReload` (`:1210`), new
  `publishWrist` parameter on `init` (`:394-401`)
- Test: `WaterBuddyTests/WristSyncTests.swift` (new `WristPublishTests`)

**Interfaces:**
- Consumes: `WristMirror` (Task 3), `DataManager.readAppliedLedger(from:)` (Task 4),
  `WaterSnapshot`-style nonisolated statics already on `DataManager` (`resolveServings(in:)`,
  `resolveLanguage(in:)`, `Calendar.waterBuddyDay`).
- Produces: `nonisolated static func requestWristPublish()`, and `init`'s `publishWrist: @escaping ()
  -> Void = DataManager.requestWristPublish` parameter — every mutation that already calls
  `reloadWidgets()` now also calls `publishWrist()` alongside it.

This is the same "fire from either process" idiom `requestWidgetReload`/`requestReminderReschedule`
already are, extended to a third destination. It reaches `WCSession` directly — **not** through
`WristLink** — because `updateApplicationContext(_:)` is a plain session method, not a delegate
callback; nothing here needs a delegate to exist yet, which is why this task has no dependency on
Task 11.

- [ ] **Step 1: Write the failing tests**

Add to `WaterBuddyTests/WristSyncTests.swift`:

```swift
/// `requestWristPublish()` composes a `WristMirror` from the shared suite. `WCSession` itself is
/// not reachable from a unit test (there is no paired watch in CI or on a bare simulator run), so
/// these tests cover the **composition**, not the transmission — the same split
/// `WristInboxReassemblyTests` draws between the pure half and the SDK-touching half.
@MainActor
struct WristPublishTests {

    private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
        let name = "test.waterbuddy.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name); UserDefaults.standard.removeSuite(named: name) }
        return try body(defaults)
    }

    @Test
    func composesFromTheCurrentSuite() {
        withTempDefaults { defaults in
            defaults.set(500, forKey: DataManager.Key.currentWater)
            defaults.set(2_000, forKey: DataManager.Key.dailyGoal)
            defaults.set([150, 250, 500], forKey: DataManager.Key.servings)
            defaults.set(true, forKey: DataManager.Key.isGoalSet)

            let mirror = DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: .now)
            #expect(mirror.currentWater == 500)
            #expect(mirror.dailyGoal == 2_000)
            #expect(mirror.servings == [150, 250, 500])
            #expect(mirror.isGoalSet == true)
            #expect(mirror.schemaVersion == WristMirror.currentSchemaVersion)
        }
    }

    @Test
    func ackedIsCappedAtTheMaximumAcrossTheWholeLedgerNotJustToday() {
        withTempDefaults { defaults in
            // Split across two days on purpose — `composeWristMirror` must flatten every retained
            // day's bucket, not just today's, or a pour whose own day has already passed would
            // never be named in `acked` and the watch could never retire it from its outbox.
            let today = DataManager.dayOrdinal(for: .now, in: .waterBuddyDay)
            let yesterday = today - 1
            let todaysIds = (0..<(WristMirror.maximumAckedIds)).map { _ in UUID() }
            let yesterdaysIds = (0..<10).map { _ in UUID() }
            let encoded = try! JSONEncoder().encode([yesterday: yesterdaysIds, today: todaysIds])
            defaults.set(encoded, forKey: DataManager.Key.wristApplied)

            let mirror = DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: .now)
            #expect(mirror.acked.count == WristMirror.maximumAckedIds)
        }
    }

    @Test
    func aSystemLanguageComposesAsNil() {
        withTempDefaults { defaults in
            // Key.language absent == follow the device (rule `70-privacy`) — must round-trip as nil.
            let mirror = DataManager.composeWristMirror(from: defaults, calendar: .waterBuddyDay, now: .now)
            #expect(mirror.languageCode == nil)
        }
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/WristPublishTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `composeWristMirror` doesn't exist yet.

- [ ] **Step 3: Implement**

In `WaterBuddy/DataManager.swift`, add near `requestWidgetReload` (`:1208-1213`):

```swift
    #if canImport(WatchConnectivity)
    /// Composes the current state into a `WristMirror` — the pure half of publishing, kept separate
    /// from the `WCSession` call so it is testable without a paired watch (`WristPublishTests`).
    nonisolated static func composeWristMirror(from defaults: UserDefaults, calendar: Calendar, now: Date) -> WristMirror {
        // Flattened across **every** retained day, not just today's bucket: a watch pour authored
        // while offline, or from a day before the outbox last synced, still needs to be named in
        // `acked` before the watch will retire it — restricting this to today's day-ordinal would
        // strand any pour whose own day has already passed by the time it's folded.
        let ledger = readAppliedLedger(from: defaults)
        let acked = Array(ledger.sorted { $0.key < $1.key }.flatMap(\.value).prefix(WristMirror.maximumAckedIds))

        return WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion,
            currentWater: defaults.integer(forKey: Key.currentWater).clamped(to: 0...maximumDailyIntake),
            dailyGoal: resolveDailyGoal(in: defaults),
            servings: resolveServings(in: defaults),
            languageCode: resolveLanguage(in: defaults).code,
            isGoalSet: resolveIsGoalSet(in: defaults, goal: resolveDailyGoal(in: defaults)),
            composedAt: now,
            phoneDayStart: calendar.startOfDay(for: now),
            acked: acked
        )
    }

    /// Sends the current state to the watch. A no-op when `WCSession` isn't supported (e.g. no
    /// paired watch) or hasn't activated yet — `updateApplicationContext` throws in both cases, and
    /// this is a best-effort push: `refresh()`'s own reconcile-on-foreground backstop (rule
    /// `80-notifications`'s equivalent for reminders) is not duplicated here for v1, so a push that
    /// fails silently degrades to "the watch shows a stale mirror until the next successful one" —
    /// stated, not hidden, per rule `75-diagnostics`.
    nonisolated static func requestWristPublish() {
        guard WCSession.isSupported() else { return }
        let mirror = composeWristMirror(from: sharedDefaults, calendar: .waterBuddyDay, now: Date())
        guard let data = try? JSONEncoder().encode(mirror) else { return }
        do {
            try WCSession.default.updateApplicationContext(["mirror": data])
        } catch {
            #if DEBUG
            print("[WaterBuddy] Could not publish the wrist mirror: \(error.localizedDescription)")
            #endif
        }
    }
    #endif
```

Then extend `init`'s signature (from Task 2's already-marked-unavailable version) to add the new
parameter, and call it alongside every existing `reloadWidgets()` call site:

```swift
    @available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores.")
    init(
        defaults: UserDefaults = DataManager.sharedDefaults,
        modelContainer: ModelContainer = DataManager.sharedModelContainer,
        calendar: Calendar = .waterBuddyDay,
        now: @escaping () -> Date = Date.init,
        reloadWidgets: @escaping () -> Void = DataManager.requestWidgetReload,
        rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule,
        publishWrist: @escaping () -> Void = DataManager.requestWristPublish
    ) {
        // ... existing body unchanged, plus:
        self.publishWrist = publishWrist
    }
```

adding `@ObservationIgnored private let publishWrist: () -> Void` alongside the other injected
dependencies (`:148`), and calling `publishWrist()` immediately after each existing `reloadWidgets()`
call site: the `currentWater` setter (`:179`), the `dailyGoal` setter (`:211`), the `servings` setter
(`:251`), and `applyDailyReset`'s direct-write path (rule `30-rollover`'s "any new side effect added
to [the `currentWater`] setter has to be repeated here too" — this is that repetition, one layer
wider).

**Every existing test fixture still compiles unchanged** — `publishWrist` is defaulted, and its
default (`DataManager.requestWristPublish`) is inert in a test (no `WCSession` reaches a paired watch
from a simulator with no pairing) — but three existing tests that count `reloadWidgets` calls
(`loggingRingsTheWidgetDoorbellExactlyOnce` and its siblings) must keep passing unchanged, since this
task adds a call, not a replacement.

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all three `WristPublishTests` **PASS**.

- [ ] **Step 5: Run the full existing gate, including the widget**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: all green, zero new warnings, and specifically zero change in the three widget-doorbell
tests' pass/fail (they assert *count*, and this task must not have changed how many times
`reloadWidgets` itself fires — only added a sibling call).

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/WristSyncTests.swift
```

---

### Task 8: The paired-simulator probe — a spike, not shipped code

**Files:**
- Create (throwaway, outside this project entirely): a scratch Xcode project, e.g.
  `/tmp/wristconnectivity-probe/` — never inside `WaterBuddy/`, `WaterBuddyWidget/`,
  `WaterBuddyWatch/`, or any synchronized folder.
- Modify: nothing in this repository except the spec/plan documents recording the finding (Step 4).

**Interfaces:** none — this task produces a **finding**, not an interface later tasks import.

This is spec §11 step 5, run **before** Task 9's `project.pbxproj` surgery rather than after, exactly
as the spec's own reconciliation (§14, and the earlier HISTORY.md entry) already re-sequenced it:
the irreversible, high-effort work (rewriting the real project file) should not happen before the
cheapest test of whether the design's central mechanism — the watch waking the phone with
`sendMessage`, and both sides seeing each other as reachable — actually works on this machine's
simulators at all. Two claims from spec §13 are genuinely unproven, not merely unverified by this
codebase's own tests:

- Whether the `sendMessage` wake (`"If the counterpart app is not running the counterpart app will
  be launched"`) has ever been observed working between two simulators.
- Whether `.backgroundTask(.watchConnectivity)` fires for an app the user has not manually launched
  — relevant later, for Task 17, but cheap to probe alongside this one.

- [ ] **Step 1: Build the throwaway project**

Outside this repository, create a minimal two-target Xcode project (iOS app + paired watchOS app,
no widget, no SwiftData, no design system — the smallest thing that can activate a `WCSession` on
each side). Each side's `ContentView` shows: reachability state, a button that calls `sendMessage`
if reachable, a counter of `didReceiveUserInfo` calls, and a `Text` updated by
`.backgroundTask(.watchConnectivity)` firing.

- [ ] **Step 2: Run it — paired iPhone + Apple Watch simulators**

```
xcrun simctl list devices | grep -i "iPhone 17\|Apple Watch"
```

Pair an iPhone 17 simulator with an Apple Watch Series 11 (46mm) simulator via the CLI — corrected
from this plan's first draft, which wrongly assumed pairing needs Xcode's GUI:

```
xcrun simctl pair <watch-udid> <phone-udid>
xcrun simctl bootstatus <phone-udid> -b
xcrun simctl bootstatus <watch-udid> -b
```

Build and install the throwaway app on both, then launch both.

- [ ] **Step 3: Observe, and record exactly what happened — not what should have happened**

Specifically:
1. With the phone app in the foreground, tap the watch's send button. Does `isReachable` read `true`?
   Does the phone's counter increment?
2. **Force-quit the phone app.** Tap the watch's send button again. Does the phone app relaunch? Does
   the counter still increment? (This is the `sendMessage` wake — spec §13's "never observed
   working" claim.)
3. With both apps backgrounded, wait — does `.backgroundTask(.watchConnectivity)` ever fire on
   either side, and after how long? (Simulator background execution is known to be less strictly
   throttled than a device; note this caveat when recording the finding.)

- [ ] **Step 4: Record the finding — in the spec, not in code**

Append a short, dated entry to `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md`
(after §14), stating plainly what was observed, e.g.:

```markdown
## 15. The paired-simulator probe, 2026-09-0X

Observed on [iPhone 17 / Apple Watch Series 11] simulators, Xcode 26.6:
- Reachability while both apps foregrounded: [true/false].
- `sendMessage` after force-quitting the phone app: [woke it / did not — error was ...].
- `.backgroundTask(.watchConnectivity)`: [fired after ~Ns / never observed firing].

**Decision:** [proceed as designed / the design's reliance on `sendMessage` as a wake mechanism is
downgraded to "best effort, `updateApplicationContext` + the next foreground open is the real
delivery path" / other — state the actual consequence for Task 17's `.backgroundTask` reliance].
```

If `sendMessage`'s wake does **not** work on simulator, that is not necessarily a "device only"
conclusion or a blocker — note it as unresolved-on-simulator and proceed, since Task 17's own
`.backgroundTask(.watchConnectivity)` and `updateApplicationContext`'s "stores the most recently
received, readable on the watch's own wake" are the two paths that do not depend on the wake at all.
Only downgrade the design if a **device** test (outside this plan's scope — the owner's to run) later
contradicts it.

- [ ] **Step 5: Discard the scratch project**

Per the spike checklist: the code is not kept. Delete `/tmp/wristconnectivity-probe/` (or wherever it
was built) once the finding is recorded — nothing from it is imported by any later task.

- [ ] **Step 6: Stage the spec update only**

```bash
git add docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md
```

---

### Task 9: Rework the watch target — exception set, entitlement, deployment target

**Files:**
- Modify: `WaterBuddy.xcodeproj/project.pbxproj`
- Create: `Entitlements/WaterBuddyWatch.entitlements`

**Interfaces:** none new — this task makes the *existing* placeholder `WaterBuddyWatch` target
(object id `BFEFF83A095BBD4658E8A453`) actually reachable by `DataManager.swift`, `WaterLog.swift`,
`WaterSurface.swift`, `LiquidGlassModifier.swift`, `WristPlan.swift` and `ReminderPlan.swift`, and
gives it the App Group it needs for its own local suite (Task 13's `Key.wristOutbox`/`wristMirror`).

This is the "riskiest step, and the only unrecoverable one" (spec §11 step 6) — **before touching
`project.pbxproj`, copy it, both files under `Entitlements/`, and the deployment-target lines
elsewhere in the same file somewhere durable outside `/private/tmp`** (the scratchpad does not
outlive the session that created it, and a corrupted `project.pbxproj` loses every target's
configuration at once — this repo has no `.git` yet to fall back on, per rule `90-git`, "Initialising
one remains the owner's call"). A plain `cp` to a dated folder under, e.g., `~/Desktop/` is enough.

**Six files, not five — the correction to spec §11 step 6's own list.** The spec names
`DataManager.swift`, `WaterLog.swift`, `WaterSurface.swift`, `LiquidGlassModifier.swift`,
`ReminderPlan.swift`. `WristPlan.swift` (Task 5) is also needed: `WristModel` (Task 12) calls
`WristPlan.todaysTotal(from:now:calendar:)` directly, and it is not one of the widget's existing six
— it did not exist when spec §11 was first written. Confirm this exact set against
`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §11 step 6 before typing anything;
if the spec and this plan ever disagree about the list, the **spec** is what to re-derive from, per
this document's own header, not this paragraph.

**`NotificationManager.swift` is deliberately excluded** — `mayFileReminders` is `false` on
`.watchApp` (already landed, Task 2 makes it a compile error for the watch to reach `DataManager`'s
constructor at all, so the question is moot for anything that *would* call `NotificationManager`).

- [ ] **Step 1: Snapshot first**

```bash
mkdir -p ~/Desktop/waterbuddy-pbxproj-snapshots/$(date +%Y%m%d-%H%M%S)
cp WaterBuddy.xcodeproj/project.pbxproj Entitlements/WaterBuddy.entitlements \
   Entitlements/WaterBuddyWidgetExtension.entitlements WaterBuddyWidget-Info.plist \
   ~/Desktop/waterbuddy-pbxproj-snapshots/$(date +%Y%m%d-%H%M%S)/
```

- [ ] **Step 2: Create the watch's entitlement file**

New file `Entitlements/WaterBuddyWatch.entitlements` — byte-identical in content to the other two
(same App Group string; the watch's own copy of the container it creates is entirely separate from
the phone's, since they are different physical devices — rule `25-shared-storage`'s "spell it only
as `DataManager.appGroupIdentifier`" still holds, this is that same identifier, just entitled on a
third target):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.application-groups</key>
	<array>
		<string>group.sardor.WaterBuddy</string>
	</array>
</dict>
</plist>
```

- [ ] **Step 3: Add the exception set, targeting the watch**

In `WaterBuddy.xcodeproj/project.pbxproj`, in the existing `/* Begin
PBXFileSystemSynchronizedBuildFileExceptionSet section */` (currently holding only the widget's
`4D91E460176EB1EE87230C86`), add a second entry immediately before the section's closing marker:

```
		3B60BAE6703F44AE6C46153F /* Exceptions for "WaterBuddy" folder in "WaterBuddyWatch" target */ = {
			isa = PBXFileSystemSynchronizedBuildFileExceptionSet;
			membershipExceptions = (
				DataManager.swift,
				LiquidGlassModifier.swift,
				ReminderPlan.swift,
				WaterLog.swift,
				WaterSurface.swift,
				WristPlan.swift,
			);
			target = BFEFF83A095BBD4658E8A453 /* WaterBuddyWatch */;
		};
```

Then extend the `WaterBuddy` app's own sync group (`9947C21D3046293D00972CEA`) to list **both**
exception sets — it currently has only the widget's:

```
		9947C21D3046293D00972CEA /* WaterBuddy */ = {
			isa = PBXFileSystemSynchronizedRootGroup;
			exceptions = (
				4D91E460176EB1EE87230C86 /* Exceptions for "WaterBuddy" folder in "WaterBuddyWidgetExtension" target */,
				3B60BAE6703F44AE6C46153F /* Exceptions for "WaterBuddy" folder in "WaterBuddyWatch" target */,
			);
			path = WaterBuddy;
			sourceTree = "<group>";
		};
```

- [ ] **Step 4: Wire the entitlement and fix the deployment target**

In both `XCBuildConfiguration` blocks for the watch target (object ids `166749F680B0C532534134D7`
Debug and `4E055122807EF3DDABB4DC02` Release), add `CODE_SIGN_ENTITLEMENTS` and correct
`WATCHOS_DEPLOYMENT_TARGET` — it currently reads `11.6` in both, which matches neither installed
watchOS runtime (`11.5`, `26.5`) as cleanly as the rest of the project's `26.5` pin does, and is very
likely a value Xcode substituted the last time it opened the project rather than one anybody chose:

```
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = Entitlements/WaterBuddyWatch.entitlements;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4DT6XGJF29;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
				INFOPLIST_KEY_WKApplication = YES;
				INFOPLIST_KEY_WKCompanionAppBundleIdentifier = "sardor.WaterBuddy";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = sardor.WaterBuddy.watchkitapp;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = watchos;
				SKIP_INSTALL = YES;
				STRING_CATALOG_GENERATE_SYMBOLS = NO;
				SUPPORTED_PLATFORMS = "watchsimulator watchos";
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 4;
				WATCHOS_DEPLOYMENT_TARGET = 26.5;
```

(only `CODE_SIGN_ENTITLEMENTS` is new and `WATCHOS_DEPLOYMENT_TARGET` changes from `11.6` to `26.5`
— every other line already present, unchanged, in both Debug and Release.)

- [ ] **Step 5: Verify the pbxproj still parses**

```bash
plutil -lint WaterBuddy.xcodeproj/project.pbxproj
xcodebuild -list -project WaterBuddy.xcodeproj
```

Expected: `project.pbxproj: OK`, and the target/scheme list unchanged from before this task (five
targets, three schemes — this task adds no new target, only reworks an existing one).

- [ ] **Step 6: Build the watch target and confirm the five shared files actually compile into it**

```
xcrun simctl shutdown all
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

Expected: `** BUILD SUCCEEDED **`. If it fails on `LiquidGlassModifier.swift` specifically, Task 1
was skipped or reverted — confirm `Task 1`'s fix is actually staged before re-running.

- [ ] **Step 7: Confirm the exception set actually took — a positive check, not just "it built"**

A successful build here could in principle mean the six files simply aren't referenced by anything
yet (the placeholder `ContentView.swift` is still just `Text("WaterBuddy")`) — Task 5's `WristPlan`
and this task's exception set need a real reference to prove the membership, not just the sync group
existing. Temporarily add one line to `WaterBuddyWatch/ContentView.swift`:

```swift
// Temporary, deleted at the end of this step:
let _: Int = WristPlan.todaysTotal(from: [], now: .now, calendar: .waterBuddyDay)
```

Rebuild (same command as Step 6). Expected: still `** BUILD SUCCEEDED **` — if `WristPlan` were not
actually reachable from the watch target, this would fail with `cannot find 'WristPlan' in scope`.
Remove the temporary line immediately after confirming.

- [ ] **Step 8: Rebuild the phone app and widget — the exception-set change touches the same sync group they read**

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

Expected: all green. The widget's own exception set (`4D91E460176EB1EE87230C86`) is untouched by
this task — confirm `grep -c` for the six widget filenames still returns exactly six.

- [ ] **Step 9: Stage**

```bash
git add WaterBuddy.xcodeproj/project.pbxproj Entitlements/WaterBuddyWatch.entitlements
```

---

### Task 10: A `WaterBuddyWatchTests` target — the fifth gate invocation

**Files:**
- Modify: `WaterBuddy.xcodeproj/project.pbxproj`
- Create: `WaterBuddyWatchTests/` (new synchronized folder, empty except a placeholder below)

**Interfaces:** none new — infrastructure only. Task 12 (`WristModel`) is the first task to actually
put a test file in this folder.

Spec §9.1: "the gate becomes five invocations: iOS unit, iOS UI, watchOS unit (no simulator pair
needed), phone widget build, and a watch app + watch widget build" — this task builds the target that
makes "watchOS unit" possible. It follows the exact pattern `WaterBuddyTests` already uses
(`PBXFileSystemSynchronizedRootGroup`, `com.apple.product-type.bundle.unit-test`, `TEST_HOST` /
`BUNDLE_LOADER` pointing at the watch app), just on `SDKROOT = watchos`.

- [ ] **Step 1: Snapshot again — this is a second, independent edit to the same irreplaceable file**

```bash
mkdir -p ~/Desktop/waterbuddy-pbxproj-snapshots/$(date +%Y%m%d-%H%M%S)
cp WaterBuddy.xcodeproj/project.pbxproj ~/Desktop/waterbuddy-pbxproj-snapshots/$(date +%Y%m%d-%H%M%S)/
```

- [ ] **Step 2: Create the folder with a placeholder**

```bash
mkdir -p WaterBuddyWatchTests
```

New file `WaterBuddyWatchTests/WristPlanCompileTests.swift` — a real, passing test (not a stub to
delete later), proving the target can see `WristPlan` through the exception set added in Task 9:

```swift
//
//  WristPlanCompileTests.swift
//  WaterBuddyWatchTests
//
//  The canary that this target can actually reach the shared files at all — if the exception set
//  in `project.pbxproj` (Task 9) or this target's own `fileSystemSynchronizedGroups` regresses,
//  this is the first thing that stops compiling, before any real behavioural test gets the chance
//  to fail for the wrong reason.
//

import Testing
@testable import WaterBuddyWatch

struct WristPlanCompileTests {
    @Test
    func wristPlanIsReachableFromTheWatchTestTarget() {
        let total = WristPlan.todaysTotal(from: [], now: .now, calendar: .waterBuddyDay)
        #expect(total == 0)
    }
}
```

- [ ] **Step 3: Add the target's product reference, sync group, and build phases**

In `project.pbxproj`'s `PBXFileReference` section:

```
		9B845F8E9AAEB910C75A2CE7 /* WaterBuddyWatchTests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = WaterBuddyWatchTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };
```

In `PBXFileSystemSynchronizedRootGroup`:

```
		276C3683D8F5A527885E5BD5 /* WaterBuddyWatchTests */ = {
			isa = PBXFileSystemSynchronizedRootGroup;
			path = WaterBuddyWatchTests;
			sourceTree = "<group>";
		};
```

In `PBXFrameworksBuildPhase`, `PBXResourcesBuildPhase`, `PBXSourcesBuildPhase` — one empty phase each,
following the exact pattern every other target's empty phases already use:

```
		AE44B8280DA4486FB085CC7D /* Frameworks */ = { isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		576D4B98E86CC9E166272A27 /* Resources */ = { isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
		3EBE7CE2F43C6CFA0C8CC79B /* Sources */ = { isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = ( ); runOnlyForDeploymentPostprocessing = 0; };
```

(Write these multi-line, matching the existing file's formatting, rather than the single-line form
shown here for brevity.)

In `PBXGroup`, add the new folder to the main group's `children` and the new product to `Products`:

```
		9947C2123046293D00972CEA = {
			isa = PBXGroup;
			children = (
				9947C21D3046293D00972CEA /* WaterBuddy */,
				B22D6BC9248B2BC94D56417A /* WaterBuddyWidget */,
				AA36CF88D9D704ABB6AEC20D /* WaterBuddyWatch */,
				276C3683D8F5A527885E5BD5 /* WaterBuddyWatchTests */,
				9947C22B3046293E00972CEA /* WaterBuddyTests */,
				9947C2353046293F00972CEA /* WaterBuddyUITests */,
				9947C21C3046293D00972CEA /* Products */,
			);
			sourceTree = "<group>";
		};
```
(inserted after `WaterBuddyWatch`), and in `Products`:
```
				9B845F8E9AAEB910C75A2CE7 /* WaterBuddyWatchTests.xctest */,
```
(appended after `WaterBuddyWatch.app`).

- [ ] **Step 4: The container item proxy and target dependency — this test target depends on the watch app, exactly as `WaterBuddyTests` depends on `WaterBuddy`**

In `PBXContainerItemProxy`:

```
		5BDEE20387D2F666E60A3E32 /* PBXContainerItemProxy */ = {
			isa = PBXContainerItemProxy;
			containerPortal = 9947C2133046293D00972CEA /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = BFEFF83A095BBD4658E8A453;
			remoteInfo = WaterBuddyWatch;
		};
```

In `PBXTargetDependency`:

```
		33CAC42545952CC094C9B970 /* PBXTargetDependency */ = {
			isa = PBXTargetDependency;
			target = BFEFF83A095BBD4658E8A453 /* WaterBuddyWatch */;
			targetProxy = 5BDEE20387D2F666E60A3E32 /* PBXContainerItemProxy */;
		};
```

- [ ] **Step 5: The native target**

In `PBXNativeTarget`:

```
		1D32EA877A3E52E18AB4EDAF /* WaterBuddyWatchTests */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = 64F729822A17C6F165E23DDE /* Build configuration list for PBXNativeTarget "WaterBuddyWatchTests" */;
			buildPhases = (
				3EBE7CE2F43C6CFA0C8CC79B /* Sources */,
				AE44B8280DA4486FB085CC7D /* Frameworks */,
				576D4B98E86CC9E166272A27 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				33CAC42545952CC094C9B970 /* PBXTargetDependency */,
			);
			fileSystemSynchronizedGroups = (
				276C3683D8F5A527885E5BD5 /* WaterBuddyWatchTests */,
			);
			name = WaterBuddyWatchTests;
			packageProductDependencies = (
			);
			productName = WaterBuddyWatchTests;
			productReference = 9B845F8E9AAEB910C75A2CE7 /* WaterBuddyWatchTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		};
```

- [ ] **Step 6: Project-level wiring — targets list and `TargetAttributes`**

In `PBXProject`'s `attributes.TargetAttributes`:

```
					1D32EA877A3E52E18AB4EDAF = {
						CreatedOnToolsVersion = 26.6;
						TestTargetID = BFEFF83A095BBD4658E8A453;
					};
```

In `targets`:

```
			targets = (
				9947C21A3046293D00972CEA /* WaterBuddy */,
				9947C2273046293E00972CEA /* WaterBuddyTests */,
				9947C2313046293F00972CEA /* WaterBuddyUITests */,
				6273D2F7D706C59BE59C7434 /* WaterBuddyWidgetExtension */,
				BFEFF83A095BBD4658E8A453 /* WaterBuddyWatch */,
				1D32EA877A3E52E18AB4EDAF /* WaterBuddyWatchTests */,
			);
```

- [ ] **Step 7: Build configurations**

In `XCBuildConfiguration`:

```
		E7DEC8FDC293EF8377B4022B /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4DT6XGJF29;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = sardor.WaterBuddyWatchTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = watchos;
				STRING_CATALOG_GENERATE_SYMBOLS = NO;
				SUPPORTED_PLATFORMS = "watchsimulator watchos";
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 4;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/WaterBuddyWatch.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/WaterBuddyWatch";
				WATCHOS_DEPLOYMENT_TARGET = 26.5;
			};
			name = Debug;
		};
		AD050E9E74F1CEE218FB1167 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = 4DT6XGJF29;
				GENERATE_INFOPLIST_FILE = YES;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = sardor.WaterBuddyWatchTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SDKROOT = watchos;
				STRING_CATALOG_GENERATE_SYMBOLS = NO;
				SUPPORTED_PLATFORMS = "watchsimulator watchos";
				SWIFT_APPROACHABLE_CONCURRENCY = YES;
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = 4;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/WaterBuddyWatch.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/WaterBuddyWatch";
				WATCHOS_DEPLOYMENT_TARGET = 26.5;
			};
			name = Release;
		};
```

And in `XCConfigurationList`:

```
		64F729822A17C6F165E23DDE /* Build configuration list for PBXNativeTarget "WaterBuddyWatchTests" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				E7DEC8FDC293EF8377B4022B /* Debug */,
				AD050E9E74F1CEE218FB1167 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
```

- [ ] **Step 8: Verify the pbxproj parses and the scheme exists**

```bash
plutil -lint WaterBuddy.xcodeproj/project.pbxproj
xcodebuild -list -project WaterBuddy.xcodeproj
```

Expected: `OK`, six targets now listed (`WaterBuddy`, `WaterBuddyTests`, `WaterBuddyUITests`,
`WaterBuddyWidgetExtension`, `WaterBuddyWatch`, `WaterBuddyWatchTests`). Xcode auto-creates the
`WaterBuddyWatchTests` scheme is **not** guaranteed the way it was for the app/widget/watch targets
— unit test targets typically run through their host's scheme rather than getting their own. If no
new scheme appears, run the test via the `WaterBuddyWatch` scheme with `-only-testing:`.

- [ ] **Step 9: Run it — the canary test, and confirm the target genuinely needs no simulator pair**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
```

Expected: `** TEST SUCCEEDED **`, `wristPlanIsReachableFromTheWatchTestTarget` passes. Confirm this
runs against a **single, unpaired** watch simulator — spec §9.1's "no simulator pair needed" for the
unit half; pairing only matters for Task 8's spike and any future manual UI verification.

- [ ] **Step 10: Confirm the other four gate invocations are still green**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

Expected: all four green. **The gate is now five invocations** (spec §9.1) — this is the point where
`.claude/rules/85-testing.md`'s fenced gate block stops matching reality; Task 18 amends it.

- [ ] **Step 11: Stage**

```bash
git add WaterBuddy.xcodeproj/project.pbxproj WaterBuddyWatchTests/WristPlanCompileTests.swift
```

---

### Task 11: `WristModel` — the watch's own manager

**Files:**
- Create: `WaterBuddyWatch/WristModel.swift`
- Test: `WaterBuddyWatchTests/WristModelTests.swift`

**Interfaces:**
- Consumes: `WristPour`, `WristMirror` (Task 3), `WristPlan.todaysTotal(from:now:calendar:)`
  (Task 5), `DataManager.Key` (readable from the watch target through the exception set — the `Key`
  *type* compiles in; nothing stops the watch reading its own three keys with it, only
  `DataManager.shared`/`.init` are blocked, per Task 2).
- Produces: `@MainActor @Observable final class WristModel { static let shared: WristModel; var
  mirror: WristMirror?; var todaysTotal: Int; var isMirrorStale: Bool; func pour(amount: Int); func
  apply(_ mirror: WristMirror) }`. Task 12 (`WristLink`) calls `apply(_:)` from
  `didReceiveApplicationContext`; Task 15 (`WristView`) reads `todaysTotal`/`isMirrorStale`/`mirror`
  and calls `pour(amount:)`.

Built and tested **before** `WristLink` (Task 12), deliberately reversing spec §11's step-7-then-8
ordering: `WristLink`'s watch-side delegate method needs something to call `apply(_:)` *on* — building
`WristModel` first means `WristLink` references a real, already-tested method rather than a stub.

This task settles spec §4's remaining open question — **the display formula**:
`todaysTotal = mirror.currentWater + WristPlan.todaysTotal(from: outbox not yet acked)`. The
"double-counts in the window where the phone has folded a pour but not yet acked it" failure mode
spec §4 warns about is avoided **by construction**, not by a check: `apply(_:)` is the *only* place
that both replaces `mirror` and removes now-acked entries from the outbox, in one synchronous
`@MainActor` method with no suspension point between the two — so `todaysTotal` can never read a
mirror that already reflects a pour while the same pour is still sitting in the outbox being added a
second time. Either both have moved, or neither has.

For spec §5's "withheld and attributed, never a confident zero": rather than the two rejected
designs (both zeroed the base when `phoneDayStart` disagrees with the watch's own day), this exposes
`isMirrorStale: Bool` and **still shows the number** — `todaysTotal` never drops to a false zero.
`WristView` (Task 15) is what actually softens the display when this is `true`.

- [ ] **Step 1: Write the failing tests**

New file `WaterBuddyWatchTests/WristModelTests.swift`:

```swift
//
//  WristModelTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

@MainActor
struct WristModelTests {

    private static let utc = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "UTC")!; return c }()

    private func withTempDefaults<T>(_ body: (UserDefaults) throws -> T) rethrows -> T {
        let name = "test.waterbuddywatch.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name); UserDefaults.standard.removeSuite(named: name) }
        return try body(defaults)
    }

    private func makeModel(_ defaults: UserDefaults, now: @escaping () -> Date, sent: @escaping ([WristPour]) -> Void = { _ in }) -> WristModel {
        WristModel(defaults: defaults, calendar: Self.utc, now: now, send: sent)
    }

    @Test
    func withNoMirrorYetTotalIsJustTheOutbox() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.pour(amount: 250)
            #expect(model.todaysTotal == 250)
        }
    }

    @Test
    func pouringAppendsToTheOutboxAndCallsSend() {
        withTempDefaults { defaults in
            var sent: [WristPour] = []
            let model = makeModel(defaults, now: { Date(timeIntervalSince1970: 1_000) }, sent: { sent.append(contentsOf: $0) })
            model.pour(amount: 150)
            #expect(sent.map(\.amount) == [150])
        }
    }

    @Test
    func applyingAMirrorRetiresAckedPoursFromTheOutbox() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.pour(amount: 250)
            let pouredId = model.pendingOutbox.first!.id

            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 250, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: now, phoneDayStart: Self.utc.startOfDay(for: now), acked: [pouredId]
            ))

            #expect(model.pendingOutbox.isEmpty)
            #expect(model.todaysTotal == 250, "the mirror's own total now carries it, not the outbox")
        }
    }

    @Test
    func anUnackedPourStaysInTheOutboxAcrossAMirrorUpdate() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let model = makeModel(defaults, now: { now })
            model.pour(amount: 150) // never acked below

            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 500, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: now, phoneDayStart: Self.utc.startOfDay(for: now), acked: []
            ))

            #expect(model.pendingOutbox.count == 1)
            #expect(model.todaysTotal == 650, "mirror's 500 plus the still-unacked 150")
        }
    }

    @Test
    func isMirrorStaleWhenThePhonesDayDisagreesWithTheWatchsOwnDay() {
        withTempDefaults { defaults in
            let today = Date(timeIntervalSince1970: 1_000)
            let yesterday = today.addingTimeInterval(-90_000)
            let model = makeModel(defaults, now: { today })
            model.apply(WristMirror(
                schemaVersion: WristMirror.currentSchemaVersion, currentWater: 1_800, dailyGoal: 2_000,
                servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
                composedAt: yesterday, phoneDayStart: Self.utc.startOfDay(for: yesterday), acked: []
            ))
            #expect(model.isMirrorStale == true)
            #expect(model.todaysTotal == 1_800, "never a confident zero — the number is still shown")
        }
    }

    @Test
    func stateSurvivesReconstruction() {
        withTempDefaults { defaults in
            let now = Date(timeIntervalSince1970: 1_000)
            let first = makeModel(defaults, now: { now })
            first.pour(amount: 250)

            let second = makeModel(defaults, now: { now })
            #expect(second.pendingOutbox.map(\.amount) == [250], "the outbox is persisted, not just in-memory")
        }
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristModelTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `cannot find 'WristModel' in scope`.

- [ ] **Step 3: Implement**

New file `WaterBuddyWatch/WristModel.swift`:

```swift
//
//  WristModel.swift
//  WaterBuddyWatch
//
//  The watch's whole state — `DataManager`'s replacement on this side, named in its own
//  `@available(watchOS, unavailable)` message (`WaterBuddy/DataManager.swift`). Holds no SwiftData
//  store: an append-only outbox of pours authored here, and a mirror of what the phone last said,
//  both in this device's own local App Group suite
//  (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §1).
//
//  Watch-only by *placement*, not by an availability marker: nothing outside `WaterBuddyWatch/`
//  references this type, so there is nothing to guard against the way `DataManager`'s three
//  entry points guard against the watch.
//

import Foundation
import Observation

@MainActor
@Observable
final class WristModel {

    static let shared = WristModel()

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let now: () -> Date
    /// Hands new pours to the transport. Injected so tests never touch `WCSession`
    /// (`WristLinkTests` would need a paired watch to reach the real one at all).
    @ObservationIgnored private let send: ([WristPour]) -> Void

    private var storedMirror: WristMirror?
    private var storedOutbox: [WristPour]

    init(
        defaults: UserDefaults = DataManager.sharedDefaults,
        calendar: Calendar = .waterBuddyDay,
        now: @escaping () -> Date = Date.init,
        send: @escaping ([WristPour]) -> Void = WristModel.requestSend
    ) {
        self.defaults = defaults
        self.calendar = calendar
        self.now = now
        self.send = send
        self.storedOutbox = Self.readOutbox(from: defaults)
        self.storedMirror = Self.readMirror(from: defaults)
    }

    /// Pending pours not yet acked by the phone. Exposed (not just `todaysTotal`) so `WristView`
    /// can show an in-flight indicator, and so tests can assert the outbox shrinks on `apply(_:)`
    /// without depending on the arithmetic in `todaysTotal` to prove it.
    var pendingOutbox: [WristPour] {
        access(keyPath: \.pendingOutbox)
        return storedOutbox
    }

    var mirror: WristMirror? {
        access(keyPath: \.mirror)
        return storedMirror
    }

    /// `true` when the mirror's own day and the watch's own day disagree — the phone may not have
    /// rolled over yet, or the two devices are in different time zones right now. The number is
    /// still shown; this only tells the UI to soften how confidently it presents it (spec §5:
    /// "withheld and attributed, never a confident zero").
    ///
    /// Reads through `self.mirror`, not `storedMirror` directly — Observation tracks a computed
    /// property's dependencies transitively through the tracked properties its getter reads, so
    /// this needs no `access(keyPath:)`/`withMutation(keyPath:)` of its own: it changes exactly
    /// when `mirror` does, because that's the only tracked state it touches.
    var isMirrorStale: Bool {
        guard let mirror else { return false }
        return !calendar.isDate(mirror.phoneDayStart, inSameDayAs: now())
    }

    /// The mirror's own total, plus whatever's still in the outbox waiting to be acked. Reads
    /// through `self.mirror` and `self.pendingOutbox` for the same reason `isMirrorStale` does —
    /// no separate tracking of its own; it changes exactly when either of those does, which is
    /// what keeps this from ever double-counting a pour the phone has folded but not yet acked
    /// (see this task's own header note: `apply(_:)` moves both together, synchronously).
    var todaysTotal: Int {
        let base = mirror?.currentWater ?? 0
        return base + WristPlan.todaysTotal(from: pendingOutbox, now: now(), calendar: calendar)
    }

    /// Records a pour the user just made, and hands it to the transport. Non-positive amounts are
    /// rejected — the same floor `DataManager.addLog` holds, even though nothing here shares its
    /// code (rule `20-state`'s clamp-on-the-way-in, restated for the second writer this design
    /// introduces — see spec §7's "one honest weakening").
    func pour(amount: Int) {
        guard amount > 0 else { return }
        let pour = WristPour(id: UUID(), amount: amount, at: now())
        withMutation(keyPath: \.pendingOutbox) {
            storedOutbox.append(pour)
        }
        persistOutbox()
        send([pour])
    }

    /// The one entry point for a fresh `WristMirror`: replaces it and retires every outbox pour the
    /// phone has now acked, together, in one synchronous method with no suspension point between
    /// the two — so nothing reads a torn mix of the two.
    func apply(_ mirror: WristMirror) {
        withMutation(keyPath: \.mirror) {
            storedMirror = mirror
        }
        withMutation(keyPath: \.pendingOutbox) {
            storedOutbox.removeAll { mirror.acked.contains($0.id) }
        }
        persistOutbox()
        persistMirror()
    }

    // MARK: - Persistence

    private func persistOutbox() {
        guard let data = try? JSONEncoder().encode(storedOutbox) else { return }
        defaults.set(data, forKey: DataManager.Key.wristOutbox)
    }

    private func persistMirror() {
        guard let mirror = storedMirror, let data = try? JSONEncoder().encode(mirror) else { return }
        defaults.set(data, forKey: DataManager.Key.wristMirror)
    }

    private static func readOutbox(from defaults: UserDefaults) -> [WristPour] {
        guard let data = defaults.data(forKey: DataManager.Key.wristOutbox),
              let outbox = try? JSONDecoder().decode([WristPour].self, from: data) else { return [] }
        return outbox
    }

    private static func readMirror(from defaults: UserDefaults) -> WristMirror? {
        guard let data = defaults.data(forKey: DataManager.Key.wristMirror) else { return nil }
        return try? JSONDecoder().decode(WristMirror.self, from: data)
    }

    /// The production default for `send:` — installed by `WristLink` once it exists (Task 12).
    /// A placeholder that does nothing is correct *here*: this task has no transport yet, and
    /// `pour(amount:)`'s own test (`pouringAppendsToTheOutboxAndCallsSend`) injects its own `send`
    /// rather than relying on this one.
    static func requestSend(_ pours: [WristPour]) {}
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all six `WristModelTests` **PASS**.

- [ ] **Step 5: Run the watch build + full gate so far**

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

Expected: all green, zero new warnings. `WristModel.swift` compiles into the watch target only
(it's in `WaterBuddyWatch/`, never added to any exception set) — confirm the iOS app/widget builds
are byte-for-byte unaffected by grepping for `WristModel` across `WaterBuddy/` and
`WaterBuddyWidget/` and getting zero hits.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddyWatch/WristModel.swift WaterBuddyWatchTests/WristModelTests.swift
```

---

### Task 12: `WristLink` — the `WCSessionDelegate` wrapper

**Files:**
- Modify: `WaterBuddy/DataManager.swift` — new section near the wire structs (Task 3)
- Test: `WaterBuddyTests/WristSyncTests.swift` (new `WristLinkDecodingTests`),
  `WaterBuddyWatchTests/WristLinkCompileTests.swift` (new file)

**Interfaces:**
- Consumes: `WristBatch`, `WristMirror` (Task 3), `WristInbox.shared.receive(_:)` (Task 6),
  `WristModel.shared.apply(_:)` (Task 11), `WristModel.requestSend` (Task 11 — this task overwrites
  its no-op body with a real one, Step 5 below).
- Produces: `final class WristLink: NSObject, WCSessionDelegate, Sendable { static let live:
  WristLink; func activate(); static func send(_ pours: [WristPour]) }`. Task 13 calls
  `WristLink.live.activate()` from both app entry points; `WristModel.requestSend` (Task 11, wired
  for real in Step 5) is `send(_:)`'s only caller.

Per spec §6: never `@MainActor` (`WCSessionDelegate` callbacks land on a non-main serial queue per
the SDK's own header; a `@MainActor` type conforming to a nonisolated delegate protocol produces
`#ConformanceIsolation`, a warning today and an error at Swift 6). `Sendable` is **earned**, not
asserted: this type holds zero stored properties, so there is nothing for the compiler to reject.

One type, compiled into **both** the phone and the watch (it lives in `DataManager.swift`, already
in both the widget's and the watch's exception sets) — its delegate methods branch by `#if
os(watchOS)` rather than being parameterised with different closures per side, so there is exactly
one `static let live` to retain for the whole process lifetime, on either platform.

**This is also where the outbox actually leaves the watch.** Spec §11 step 7 names three
components — "`WristLink`, `WristInbox`, `LinkTransport`" — and this plan's Tasks 6 and 11 built the
first two of those three names' *jobs* without a component literally called `LinkTransport`. Rather
than add a fourth type, the sending half is `WristLink.send(_:)`, on the same type as receiving —
one wrapper around one `WCSession`, both directions, matching how `WristLink`'s delegate methods
already branch by platform rather than existing as separate types per direction. `LinkTransport` was
a name for a job, not a type this plan is committed to; this is that job, done.

- [ ] **Step 1: Write the failing tests — the pure decode half**

Add to `WaterBuddyTests/WristSyncTests.swift`:

```swift
/// The half of `WristLink` worth testing without a paired watch: decoding the two payload shapes
/// WatchConnectivity hands a delegate — a `[String: Any]` dictionary, which `WCSession` itself is
/// never reachable to produce in a unit test.
struct WristLinkDecodingTests {

    @Test
    func decodesAWellFormedBatch() throws {
        let batch = WristBatch(schemaVersion: WristBatch.currentSchemaVersion, batchId: UUID(), chunkIndex: 0, chunkCount: 1, pours: [])
        let data = try JSONEncoder().encode(batch)
        let decoded = WristLink.decodeBatch(from: ["batch": data])
        #expect(decoded == batch)
    }

    @Test
    func rejectsUserInfoWithNoBatchKey() {
        #expect(WristLink.decodeBatch(from: [:]) == nil)
    }

    @Test
    func rejectsMalformedBatchData() {
        #expect(WristLink.decodeBatch(from: ["batch": Data([0xFF, 0x00])]) == nil)
    }

    @Test
    func decodesAWellFormedMirror() throws {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 500, dailyGoal: 2_000,
            servings: [150, 250, 500], languageCode: nil, isGoalSet: true,
            composedAt: .now, phoneDayStart: .now, acked: []
        )
        let data = try JSONEncoder().encode(mirror)
        let decoded = WristLink.decodeMirror(from: ["mirror": data])
        #expect(decoded == mirror)
    }

    @Test
    func rejectsContextWithNoMirrorKey() {
        #expect(WristLink.decodeMirror(from: [:]) == nil)
    }
}

/// The pure half of sending: how `[WristPour]` splits into one or more `WristBatch`es. The actual
/// `WCSession.transferUserInfo` call is not reachable from a unit test — no paired watch exists in
/// this environment — so this is the half worth pinning, the same split every other WCSession-facing
/// piece in this design draws.
struct WristLinkChunkingTests {

    @Test
    func aSinglePourIsOneChunk() {
        let pours = [WristPour(id: UUID(), amount: 250, at: .now)]
        let batches = WristLink.chunk(pours, batchId: UUID())
        #expect(batches.count == 1)
        #expect(batches[0].chunkIndex == 0)
        #expect(batches[0].chunkCount == 1)
        #expect(batches[0].pours == pours)
    }

    @Test
    func moreThanTheMaximumSplitsIntoMultipleChunks() {
        let pours = (0..<(WristBatch.maximumPoursPerChunk + 10)).map { _ in WristPour(id: UUID(), amount: 100, at: .now) }
        let batches = WristLink.chunk(pours, batchId: UUID())
        #expect(batches.count == 2)
        #expect(batches[0].pours.count == WristBatch.maximumPoursPerChunk)
        #expect(batches[1].pours.count == 10)
        #expect(batches.allSatisfy { $0.chunkCount == 2 })
        #expect(batches.map(\.chunkIndex) == [0, 1])
    }

    @Test
    func everyChunkSharesTheSameBatchIdAndSchemaVersion() {
        let batchId = UUID()
        let pours = [WristPour(id: UUID(), amount: 150, at: .now)]
        let batches = WristLink.chunk(pours, batchId: batchId)
        #expect(batches.allSatisfy { $0.batchId == batchId && $0.schemaVersion == WristBatch.currentSchemaVersion })
    }

    @Test
    func emptyPoursProducesNoChunks() {
        #expect(WristLink.chunk([], batchId: UUID()).isEmpty)
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests/WristLinkDecodingTests \
  -only-testing:WaterBuddyTests/WristLinkChunkingTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `cannot find 'WristLink' in scope`.

- [ ] **Step 3: Implement**

In `WaterBuddy/DataManager.swift`, immediately after the wire structs' closing `#endif` (Task 3):

```swift
#if canImport(WatchConnectivity)
import WatchConnectivity

/// The WatchConnectivity session, wrapped the way `NotificationManager.ReminderScheduler` wraps
/// `UNUserNotificationCenter` — but as a class, not a struct of closures: `WCSessionDelegate` is a
/// real delegate protocol a type conforms to, not a sealed-`init` singleton that forbids
/// subclassing the way `UNUserNotificationCenter` does.
///
/// **Never `@MainActor`.** `WCSession`'s own header states delegate callbacks land on "a non-main
/// serial queue" — a `@MainActor` type conforming to a nonisolated delegate protocol produces
/// `#ConformanceIsolation`, a warning at this project's `SWIFT_VERSION = 5.0` and an error at Swift
/// 6, and rule `43-concurrency` treats a new warning as a gate failure today (spec §6). Every hop to
/// the main actor below is an explicit `Task { @MainActor in }`, never `MainActor.assumeIsolated` —
/// that traps unless the call is already guaranteed on the main queue, which a WatchConnectivity
/// callback is not.
///
/// One type, one behaviour that **branches by platform** rather than one instance configured
/// differently per side — `Sendable` is earned by holding zero stored properties, so there is
/// nothing for the compiler to reject, and exactly one `static let live` retains it for the whole
/// process, on either side of the pairing.
final class WristLink: NSObject, WCSessionDelegate, Sendable {

    /// The **strong** retainer. `WCSession.delegate` is `weak` (`WCSession.h:43`) and nothing else
    /// in this design holds one — without this, ARC frees the delegate the instant `activate()`
    /// returns, and every transfer afterward fails `SessionMissingDelegate` (7003) with no
    /// diagnostic in Debug or Release.
    static let live = WristLink()

    private override init() { super.init() }

    /// Activates the session and installs `self` as its delegate. `WCSession` tolerates redundant
    /// `activate()` calls, so this is safe to call more than once.
    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    // MARK: - Sending (wrist → phone)

    /// Splits `pours` into one or more `WristBatch`es of at most `WristBatch.maximumPoursPerChunk`
    /// each, all sharing `batchId`. The pure half of sending — no `WCSession`, testable with no
    /// paired watch.
    nonisolated static func chunk(_ pours: [WristPour], batchId: UUID) -> [WristBatch] {
        guard !pours.isEmpty else { return [] }
        let groups = stride(from: 0, to: pours.count, by: WristBatch.maximumPoursPerChunk).map {
            Array(pours[$0..<min($0 + WristBatch.maximumPoursPerChunk, pours.count)])
        }
        return groups.enumerated().map { index, chunkPours in
            WristBatch(
                schemaVersion: WristBatch.currentSchemaVersion, batchId: batchId,
                chunkIndex: index, chunkCount: groups.count, pours: chunkPours
            )
        }
    }

    /// Sends pours to the phone. `WristModel.requestSend` (Task 11) is this function's only caller —
    /// wired for real in Task 12's own Step 5, replacing that task's no-op default.
    ///
    /// `transferUserInfo` is the carrier of record: durable across sender exit, survives the
    /// process being killed, needs no reachability (spec §4's wire table). `sendMessage` alongside
    /// it is "a deliberate heresy" — the only documented way to wake the phone app — and its
    /// failure is swallowed on purpose: the identical batch is already durably queued above, and
    /// folding is idempotent under `WaterLog.id`, so both landing produces exactly one serving.
    nonisolated static func send(_ pours: [WristPour]) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        for batch in chunk(pours, batchId: UUID()) {
            guard let data = try? JSONEncoder().encode(batch) else { continue }
            session.transferUserInfo(["batch": data])
        }
        if session.activationState == .activated, session.isReachable {
            session.sendMessage(["wake": true], replyHandler: nil, errorHandler: { _ in })
        }
    }

    // MARK: - Decoding (the pure half — testable with no paired watch)

    nonisolated static func decodeBatch(from userInfo: [String: Any]) -> WristBatch? {
        guard let data = userInfo["batch"] as? Data else { return nil }
        return try? JSONDecoder().decode(WristBatch.self, from: data)
    }

    nonisolated static func decodeMirror(from context: [String: Any]) -> WristMirror? {
        guard let data = context["mirror"] as? Data else { return nil }
        return try? JSONDecoder().decode(WristMirror.self, from: data)
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        #if DEBUG
        if let error {
            print("[WaterBuddy] WCSession activation failed: \(error.localizedDescription)")
        }
        #endif
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}

    /// A different watch may be paired next — Apple's own documented recovery is to reactivate.
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif

    /// Wrist → phone. Only meaningful on `iOS` — the watch never receives a batch, it authors one.
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        #if !os(watchOS)
        guard let batch = Self.decodeBatch(from: userInfo), batch.schemaVersion == WristBatch.currentSchemaVersion else { return }
        Task { @MainActor in
            WristInbox.shared.receive(batch)
        }
        #endif
    }

    /// Phone → wrist. Only meaningful on `watchOS` — the phone composes a mirror, it never applies
    /// one to itself.
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        #if os(watchOS)
        guard let mirror = Self.decodeMirror(from: applicationContext), mirror.schemaVersion == WristMirror.currentSchemaVersion else { return }
        Task { @MainActor in
            WristModel.shared.apply(mirror)
        }
        #endif
    }
}
#endif
```

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all five `WristLinkDecodingTests` and all four
`WristLinkChunkingTests` **PASS**.

- [ ] **Step 5: Wire `WristModel.requestSend` to the real transport**

In `WaterBuddyWatch/WristModel.swift` (Task 11), replace:

```swift
    /// The production default for `send:` — installed by `WristLink` once it exists (Task 12).
    /// A placeholder that does nothing is correct *here*: this task has no transport yet, and
    /// `pour(amount:)`'s own test (`pouringAppendsToTheOutboxAndCallsSend`) injects its own `send`
    /// rather than relying on this one.
    static func requestSend(_ pours: [WristPour]) {}
```

with:

```swift
    /// The production default for `send:`. `pour(amount:)`'s own tests inject their own `send`
    /// (`WristModelTests.pouringAppendsToTheOutboxAndCallsSend` and its siblings), so this wiring
    /// has no behavioural test of its own beyond Task 12's `WristLinkChunkingTests` — the same split
    /// every WCSession-facing seam in this design draws between "the pure logic, tested" and "the
    /// one line that hands it to the SDK, verified by inspection and the simulator run below."
    static func requestSend(_ pours: [WristPour]) {
        WristLink.send(pours)
    }
```

Re-run `WristModelTests` (Task 11) to confirm nothing regressed — its own tests never depended on
this default, so this should be a no-op change from their perspective:

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristModelTests -parallel-testing-enabled NO
```

- [ ] **Step 6: Add the watchOS-side compile canary**

New file `WaterBuddyWatchTests/WristLinkCompileTests.swift`:

```swift
//
//  WristLinkCompileTests.swift
//  WaterBuddyWatchTests
//
//  `WristLink` is shared (it lives in `WaterBuddy/DataManager.swift`) and reaches this target
//  through the exception set Task 9 added. This test proves it actually compiles for watchOS with
//  its `#if os(watchOS)` branch live, and that `Sendable`, `NSObject` and `WCSessionDelegate`
//  conformance all hold together on this platform — the claim spec §13 records as "proven to
//  compile, not proven correct".
//

import Testing
@testable import WaterBuddyWatch

struct WristLinkCompileTests {
    @Test
    func wristLinkIsReachableAndSendableOnWatchOS() {
        let link: any Sendable = WristLink.live
        #expect(link is WristLink)
    }
}
```

- [ ] **Step 7: Run the full gate**

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: all four green, **zero new warnings on every platform** — this is the task most likely to
surface a real Swift 6 concurrency warning if the `Sendable`/`NSObject` combination doesn't hold as
cleanly as reasoned above; if one appears, stop and resolve it here rather than silencing it, per
this project's own "treat every new warning as a failure" rule.

- [ ] **Step 8: Stage**

```bash
git add WaterBuddy/DataManager.swift WaterBuddyTests/WristSyncTests.swift \
  WaterBuddyWatchTests/WristLinkCompileTests.swift WaterBuddyWatch/WristModel.swift
```

---

### Task 13: Activate `WristLink` from both app entry points

**Files:**
- Modify: `WaterBuddy/WaterBuddyApp.swift:23-33` (`init()`)
- Modify: `WaterBuddyWatch/WaterBuddyWatchApp.swift` (currently the placeholder `@main` — this task
  only touches `init()`; Task 15 replaces its `body`)

**Interfaces:** none new — pure wiring. This is the task that makes every earlier task's code
actually run, on both sides.

No new test here: activation itself has no observable behaviour a unit test can assert (it either
reaches a real `WCSession` or it silently no-ops when unsupported), and `WristLink`'s own testable
behaviour is already covered by Task 12. This task's verification is the simulator run in Step 3.

- [ ] **Step 1: Wire the phone side**

In `WaterBuddy/WaterBuddyApp.swift`, `init()` currently reads:

```swift
    init() {
        DataManager.prepareSharedStorage()
        manager = DataManager.shared
    }
```

Change to:

```swift
    init() {
        DataManager.prepareSharedStorage()
        manager = DataManager.shared
        #if canImport(WatchConnectivity)
        WristLink.live.activate()
        #endif
    }
```

(`WristInbox.shared` needs no explicit construction call here — it's a lazy `static let`, resolved
the first time `WristLink`'s `didReceiveUserInfo` actually reaches it, exactly as `DataManager.shared`
itself is never explicitly "started" beyond being referenced.)

- [ ] **Step 2: Wire the watch side**

In `WaterBuddyWatch/WaterBuddyWatchApp.swift`, replace the placeholder `@main` entirely:

```swift
//
//  WaterBuddyWatchApp.swift
//  WaterBuddyWatch
//

import SwiftUI

@main
struct WaterBuddyWatchApp: App {
    init() {
        WristLink.live.activate()
    }

    var body: some Scene {
        WindowGroup {
            WristView()
        }
    }
}
```

(No `#if canImport(WatchConnectivity)` guard needed here — this file only ever compiles for
watchOS, where the framework always exists. `WristView` doesn't exist until Task 15; this task will
not build on its own until that task lands — see Step 3's note.)

- [ ] **Step 3: Verify — together, since neither half builds alone**

```
xcrun simctl shutdown all
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: `** BUILD SUCCEEDED **` — the phone side has no dependency on `WristView`, so this half is
independently verifiable now.

The watch half references `WristView`, which Task 15 creates — **do this task's Step 2 together
with Task 15** (or, if executing strictly in order, leave `WaterBuddyWatchApp.swift` on the
placeholder `ContentView()` for now and revisit this step once `WristView` exists). Once both are in
place:

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Run the phone app on the simulator — a real smoke test, not just a compile**

```bash
xcrun simctl boot "iPhone 17" 2>&1 || true
```

Install and launch `WaterBuddy.app` (same pattern as the earlier migration's smoke test:
`xcrun simctl install`, `xcrun simctl launch`). Confirm no crash on launch and no new console
warnings about `WCSession` beyond the expected "no watch paired" state on a bare (unpaired)
simulator.

- [ ] **Step 5: Stage**

```bash
git add WaterBuddy/WaterBuddyApp.swift WaterBuddyWatch/WaterBuddyWatchApp.swift
```

---

### Task 14: The app icon, `WristAurora`, and `WristVessel`

**Files:**
- Modify: `WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Create: `WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset/AppIcon.png` (copied, not regenerated)
- Create: `WaterBuddyWatch/WristAurora.swift`
- Create: `WaterBuddyWatch/WristVessel.swift`
- Test: `WaterBuddyWatchTests/WristVesselLayoutTests.swift` (the parts of this that are pure numbers)

**Interfaces:**
- Consumes: `Aurora` (existing, `WaterSurface.swift:148-160`, shared via the exception set),
  `WaterSurface`, `WaterReadabilityScrim` (existing, `WaterSurface.swift`), `.liquidGlass(in:density:elevation:)`
  (existing, `LiquidGlassModifier.swift`, Task 1 makes it watchOS-safe), the relocated `vesselSlots`
  (Task 14a, below — done first because `WristView`, Task 15, needs it too).
- Produces: `struct WristAurora: View` (parameterless `init`), `struct WristVessel: View { let level:
  Double; let percentage: Int; let volume: Int; let goal: Int; let diameter: CGFloat }`. Task 15
  (`WristView`) is the only consumer of both.

**"Logos"**: the watch app icon. Rather than re-running `Tools/GenerateAppIcon.swift` (which targets
the phone's specific `AppIcon.appiconset` layout), this reuses the same Aurora-derived artwork
already shipping on the phone — one source of the brand, not a second generator to keep in sync.
watchOS's modern icon slot is a single `1024x1024` "watch-marketing" image, already scaffolded in
`Contents.json` (see below) but with no `filename` yet.

**Vessel composition.** `HomeView.swift`'s private `WaterVessel` (`:270-338`) is the closest existing
template — glass circle, `WaterSurface` beneath a `WaterReadabilityScrim`, a percentage readout — but
it is app-only and cannot be imported. `WristVessel` reproduces the same composition, sized for a
watch face rather than a phone screen, from the same shared primitives.

**Aurora, proportional not absolute.** Per rule `60-design-system`: "Share `Aurora`'s colours between
app and widget, but never its geometry: absolute offsets belong to `AuroraBackground`, proportional
`UnitPoint`s to `WidgetAurora`." A watch canvas is closer in scale to a widget's than to a phone
screen, so `WristAurora` follows `WidgetAurora`'s shape (`WaterBuddyWidget/WaterBuddyWidget.swift:527-568`)
— proportional `UnitPoint` positions scaled by the view's own size — not `AuroraBackground`'s
absolute point offsets.

- [ ] **Step 0 (prerequisite, not a separate task): relocate `vesselSlots` out of `HomeView`**

`HomeView.vesselSlots` (`HomeView.swift:90-94`) is app-only and unreachable from the watch. Move it
to `WaterSurface.swift` (already shared, already the home of `Aurora` — a design-token file, the
right category for vessel taxonomy, not `DataManager.swift`, which is state):

In `WaterBuddy/WaterSurface.swift`, add at file scope (outside any type), near `Aurora`:

```swift
/// The three quick-add vessels' presentation — names and SF Symbols, smallest first: Cup, Glass,
/// Bottle. The **amounts** live on `DataManager.servings` (state); this is presentation, and lives
/// here — a shared design-token file, not `DataManager.swift` — because `HomeView`, which used to
/// own it, is app-only and unreachable from the watch (`WristView`, Task 15, is the second
/// consumer). Order is load-bearing the same way `DataManager.servings`' order is: index 1 is the
/// vessel the widget's own button draws and logs.
nonisolated let vesselSlots: [(nameKey: String, symbol: String)] = [
    (nameKey: "Cup", symbol: "cup.and.saucer.fill"),
    (nameKey: "Glass", symbol: "mug.fill"),
    (nameKey: "Bottle", symbol: "waterbottle.fill"),
]
```

In `WaterBuddy/HomeView.swift`, delete the `nonisolated static let vesselSlots` declaration
(`:90-94`) and its two call sites (`Self.vesselSlots` → `vesselSlots`, `HomeView.vesselSlots` → the
plain top-level name, wherever `servings(amounts:)` and any preview reference it).

Run the existing gate to confirm the move didn't change behaviour:

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
```

Expected: unchanged pass count — this is a pure relocation, no behaviour moves. This is also the
point to amend rule `50-views.md`'s sentence "`HomeView.vesselSlots` owns the names, glyphs and
order" — fold that into Task 17's doc cascade rather than editing rules mid-task.

- [ ] **Step 1: The app icon**

```bash
cp WaterBuddy/Assets.xcassets/AppIcon.appiconset/AppIcon-dark.png \
   WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

Update `WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset/Contents.json`:

```json
{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "watch-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

- [ ] **Step 2: Write the failing test for the one genuinely pure piece — the derived vessel cap**

`WristVessel`'s sizing needs the same **derived clearance formula** rule `40-widget` already names
for the widget's small family (`MiniVessel.radius(fitting:besides:gap:)`) rather than a flat
proportion — a watch face is exactly the same "cramped, fixed-size canvas" problem the widget already
solved. New file `WaterBuddyWatchTests/WristVesselLayoutTests.swift`:

```swift
//
//  WristVesselLayoutTests.swift
//  WaterBuddyWatchTests
//

import Testing
@testable import WaterBuddyWatch

struct WristVesselLayoutTests {
    @Test
    func theVesselNeverExceedsTheAvailableWidth() {
        let diameter = WristVessel.diameter(fitting: 180, reserving: 60)
        #expect(diameter <= 180)
        #expect(diameter > 0)
    }

    @Test
    func reservingMoreSpaceShrinksTheVessel() {
        let generous = WristVessel.diameter(fitting: 180, reserving: 40)
        let tight = WristVessel.diameter(fitting: 180, reserving: 100)
        #expect(tight < generous)
    }
}
```

- [ ] **Step 3: Run the test to verify it fails**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristVesselLayoutTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `WristVessel` doesn't exist yet.

- [ ] **Step 4: Implement `WristAurora`**

New file `WaterBuddyWatch/WristAurora.swift`:

```swift
//
//  WristAurora.swift
//  WaterBuddyWatch
//
//  `WidgetAurora`'s twin, for the same reason: a watch face is a small, fixed canvas with no
//  wallpaper to sample, so this uses `Aurora`'s **colours** with proportional `UnitPoint` geometry,
//  never `AuroraBackground`'s absolute phone-screen offsets (rule `60-design-system`).
//

import SwiftUI

struct WristAurora: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Aurora.gradient
                blob(at: UnitPoint(x: 0.2, y: 0.15), color: Aurora.blue, in: proxy.size)
                blob(at: UnitPoint(x: 0.85, y: 0.25), color: Aurora.magenta, in: proxy.size)
                blob(at: UnitPoint(x: 0.5, y: 0.9), color: Aurora.cyan, in: proxy.size)
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    private func blob(at point: UnitPoint, color: Color, in size: CGSize) -> some View {
        Circle()
            .fill(color.opacity(0.55))
            .frame(width: size.width * 0.9, height: size.width * 0.9)
            .blur(radius: size.width * 0.35)
            .position(x: size.width * point.x, y: size.height * point.y)
    }
}

#Preview {
    WristAurora()
}
```

- [ ] **Step 5: Implement `WristVessel`**

New file `WaterBuddyWatch/WristVessel.swift`:

```swift
//
//  WristVessel.swift
//  WaterBuddyWatch
//
//  The glass vessel, watch-sized. Reproduces `HomeView.swift`'s private `WaterVessel`
//  composition — glass circle, water, a readability scrim, the percentage readout — from the
//  shared primitives, since that type is app-only and cannot be imported here.
//

import SwiftUI

struct WristVessel: View {
    let level: Double
    let percentage: Int
    let volume: Int
    let goal: Int
    let diameter: CGFloat

    var body: some View {
        ZStack {
            WaterSurface(level: level, phase: 0, amplitude: diameter * 0.02)
                .clipShape(Circle())
                .padding(6)
            WaterReadabilityScrim(diameter: diameter)
            VStack(spacing: 0) {
                Text("\(percentage)")
                    .font(.system(size: diameter * 0.28, weight: .bold, design: .rounded))
                    + Text("%")
                    .font(.system(size: diameter * 0.14, weight: .semibold, design: .rounded))
                Text("\(volume) / \(goal) ml")
                    .font(.system(size: diameter * 0.09, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .foregroundStyle(.white)
        }
        .frame(width: diameter, height: diameter)
        .liquidGlass(in: Circle(), density: .sheer, elevation: .floating)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Today's hydration"))
        .accessibilityValue(Text("\(percentage) percent, \(volume) of \(goal) millilitres"))
    }

    /// The derived clearance formula, `MiniVessel.radius(fitting:besides:gap:)`'s twin (rule
    /// `40-widget`) — a flat proportion of screen width would either clip against the three pour
    /// rows below it on a 41mm screen or waste space on a 49mm one.
    ///
    /// `nonisolated static` and free of any view state, exactly so `WristVesselLayoutTests` can
    /// pin it without instantiating a view at all.
    nonisolated static func diameter(fitting availableWidth: CGFloat, reserving heightForRows: CGFloat) -> CGFloat {
        max(60, availableWidth - heightForRows * 0.3)
    }
}

#Preview {
    WristVessel(level: 0.62, percentage: 62, volume: 1_240, goal: 2_000, diameter: 140)
        .background(WristAurora())
}
```

- [ ] **Step 6: Run the tests to verify they pass**

```
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristVesselLayoutTests -parallel-testing-enabled NO
```

Expected: both `WristVesselLayoutTests` **PASS**.

- [ ] **Step 7: Build the watch target**

```
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

Expected: `** BUILD SUCCEEDED **`, zero new warnings. This is the first task where `LiquidGlassModifier`
and `WaterSurface` are actually exercised by watch-target code (not just linked) — if Task 1's fix
were incomplete, this is where it would surface.

- [ ] **Step 8: Stage**

```bash
git add WaterBuddy/WaterSurface.swift WaterBuddy/HomeView.swift \
  WaterBuddyWatch/Assets.xcassets/AppIcon.appiconset WaterBuddyWatch/WristAurora.swift \
  WaterBuddyWatch/WristVessel.swift WaterBuddyWatchTests/WristVesselLayoutTests.swift
```

---

### Task 15: `WristView` — the one screen

**Files:**
- Create: `WaterBuddyWatch/WristView.swift`
- Delete: `WaterBuddyWatch/ContentView.swift`
- Test: `WaterBuddyWatchTests/WristViewLogicTests.swift`

**Interfaces:**
- Consumes: `WristModel.shared` (Task 11), `WristAurora`, `WristVessel` (Task 14), `vesselSlots`
  (Task 14, Step 0), `DataManager.defaultServings` (existing, `nonisolated static`, unaffected by
  Task 2's guard).
- Produces: `struct WristView: View`. `WaterBuddyWatchApp.body` (Task 13) is its only host.

Per spec §8: a vertical `List` — "both the native watch idiom and what keeps three 44pt targets from
needing `ViewThatFits`" — vessel, three pour rows from `mirror.servings`, then "Synced Nm ago",
**always present, never an alert**. **Deliberately absent**: settings, a goal editor, history,
reminders — each would author state the watch cannot own (v1 scope, owner-confirmed, spec §12/§14).
When no goal has been set yet, the whole screen collapses to one line: *Open WaterBuddy on your
iPhone.*

Every pour row keeps rule `65-accessibility`'s 44pt floor via `.frame(minHeight: 44)` — "a 41mm
screen does not get an exemption" (spec §8).

- [ ] **Step 1: Write the failing tests — the pure parts**

New file `WaterBuddyWatchTests/WristViewLogicTests.swift`:

```swift
//
//  WristViewLogicTests.swift
//  WaterBuddyWatchTests
//

import Foundation
import Testing
@testable import WaterBuddyWatch

/// The two pure functions `WristView` reads from — resolving which servings to offer, and
/// formatting "Synced Nm ago" — pulled out so they're testable without instantiating a `View` at
/// all (rule `43-concurrency`'s "a value type a non-@MainActor suite reads is declared at file
/// scope" extended to functions for the same reason).
struct WristViewLogicTests {

    @Test
    func fallsBackToTheDefaultServingsWithNoMirrorYet() {
        let resolved = WristView.resolveServings(from: nil)
        #expect(resolved == DataManager.defaultServings)
    }

    @Test
    func usesTheMirrorsServingsWhenPresent() {
        let mirror = WristMirror(
            schemaVersion: WristMirror.currentSchemaVersion, currentWater: 0, dailyGoal: 2_000,
            servings: [100, 200, 300], languageCode: nil, isGoalSet: true,
            composedAt: .now, phoneDayStart: .now, acked: []
        )
        #expect(WristView.resolveServings(from: mirror) == [100, 200, 300])
    }

    @Test
    func syncedJustNowReadsAsNow() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_030))
        #expect(text == "Synced just now")
    }

    @Test
    func syncedMinutesAgoReadsInWholeMinutes() {
        let text = WristView.syncedCaption(composedAt: Date(timeIntervalSince1970: 1_000), now: Date(timeIntervalSince1970: 1_000 + 245))
        #expect(text == "Synced 4m ago")
    }

    @Test
    func noMirrorYetReadsAsNeverSynced() {
        #expect(WristView.syncedCaption(composedAt: nil, now: .now) == "Not yet synced")
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests/WristViewLogicTests -parallel-testing-enabled NO
```

Expected: build **FAILS** — `cannot find 'WristView' in scope`.

- [ ] **Step 3: Implement**

Delete `WaterBuddyWatch/ContentView.swift`. New file `WaterBuddyWatch/WristView.swift`:

```swift
//
//  WristView.swift
//  WaterBuddyWatch
//
//  The one screen (`docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §8):
//  vessel, three pour rows, "Synced Nm ago" — always present, never an alert. Deliberately no
//  settings, goal editor, history or reminders here; each would author state the watch cannot own
//  (v1 scope, owner-confirmed).
//

import SwiftUI

struct WristView: View {

    @State private var model = WristModel.shared
    @State private var now = Date()

    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            WristAurora()

            if let mirror = model.mirror, mirror.isGoalSet {
                List {
                    Section {
                        VStack {
                            GeometryReader { proxy in
                                let diameter = WristVessel.diameter(fitting: proxy.size.width, reserving: 0)
                                WristVessel(
                                    level: mirror.dailyGoal > 0 ? min(1, Double(model.todaysTotal) / Double(mirror.dailyGoal)) : 0,
                                    percentage: mirror.dailyGoal > 0 ? Int((Double(model.todaysTotal) / Double(mirror.dailyGoal) * 100).rounded()) : 0,
                                    volume: model.todaysTotal,
                                    goal: mirror.dailyGoal,
                                    diameter: diameter
                                )
                                .frame(maxWidth: .infinity)
                                .position(x: proxy.size.width / 2, y: diameter / 2)
                            }
                            .frame(height: 140)
                        }
                        .listRowBackground(Color.clear)
                    }

                    Section {
                        ForEach(Array(zip(vesselSlots, Self.resolveServings(from: mirror))), id: \.0.nameKey) { slot, amount in
                            Button {
                                model.pour(amount: amount)
                            } label: {
                                HStack {
                                    Label(slot.nameKey, systemImage: slot.symbol)
                                    Spacer()
                                    Text("\(amount) ml")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(minHeight: 44)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.white.opacity(0.08))
                        }
                    }

                    Section {
                        Text(Self.syncedCaption(composedAt: mirror.composedAt, now: now))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                    }
                }
                .scrollContentBackground(.hidden)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "iphone")
                        .font(.title)
                    Text("Open WaterBuddy on your iPhone")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                }
                .foregroundStyle(.white)
                .padding()
            }
        }
        .onReceive(clock) { now = $0 }
    }

    /// `mirror.servings` when a mirror has arrived; `DataManager.defaultServings` before the first
    /// sync — never an empty row, and never invented amounts the phone hasn't confirmed once one
    /// has arrived.
    nonisolated static func resolveServings(from mirror: WristMirror?) -> [Int] {
        mirror?.servings ?? DataManager.defaultServings
    }

    /// "Synced Nm ago", rounded to whole minutes; "Synced just now" under a minute; "Not yet
    /// synced" before the first mirror ever arrives — attribution, always present, never an alert
    /// (spec §8).
    nonisolated static func syncedCaption(composedAt: Date?, now: Date) -> String {
        guard let composedAt else { return "Not yet synced" }
        let minutes = Int(now.timeIntervalSince(composedAt) / 60)
        return minutes < 1 ? "Synced just now" : "Synced \(minutes)m ago"
    }
}

#Preview {
    WristView()
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Same command as Step 2. Expected: all five `WristViewLogicTests` **PASS**.

- [ ] **Step 5: Finish Task 13's watch-side wiring — it depends on this file existing**

`WaterBuddyWatch/WaterBuddyWatchApp.swift` already references `WristView()` from Task 13; confirm it
still does (that task may have been left on the placeholder if executed strictly in order).

- [ ] **Step 6: Build and run — a real screen, not just a compiling one**

```
xcrun simctl shutdown all
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
```

Expected: both green, zero new warnings. Then install and launch on the watch simulator directly
(`xcrun simctl install`/`launch` against the booted `Apple Watch Series 11 (46mm)` simulator, same
pattern as the phone smoke test) and take a screenshot (`xcrun simctl io ... screenshot`) — confirm:
the "Open WaterBuddy on your iPhone" state renders correctly with no `WristModel.mirror` (the
expected state on a bare, unsynced simulator run), the Aurora background and app icon both actually
appear, and nothing clips or overlaps at the watch's own screen size.

- [ ] **Step 7: Stage**

```bash
git add WaterBuddyWatch/WristView.swift WaterBuddyWatchTests/WristViewLogicTests.swift
git rm WaterBuddyWatch/ContentView.swift
```

---

### Task 16: The watch widget, and `.backgroundTask(.watchConnectivity)`

**Files:**
- Create: `WaterBuddy.xcodeproj/project.pbxproj` — new `WaterBuddyWatchWidget` target
- Create: `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift`,
  `WaterBuddyWatchWidget/WaterBuddyWatchWidgetBundle.swift`,
  `WaterBuddyWatchWidget-Info.plist`, `Entitlements/WaterBuddyWatchWidgetExtension.entitlements`
- Modify: `WaterBuddyWatch/WaterBuddyWatchApp.swift` — the `.backgroundTask(.watchConnectivity)`
  scene modifier

**Interfaces:**
- Consumes: `WristModel` (Task 11, read-only — the widget's `TimelineProvider` reads the same
  persisted `Key.wristMirror`/`Key.wristOutbox` directly from `UserDefaults` rather than touching
  `WristModel.shared`, mirroring `HydrationProvider`'s own rule against touching `DataManager.shared`
  from a timeline provider — rule `40-widget`, one platform over), `WristAurora`'s colour palette
  (not the view itself — an `accessoryCircular`/`accessoryRectangular` family draws far less).

Spec §11 step 9: "together, never apart" — the widget needs the background task to have any chance
of showing fresher-than-launch data (a watch widget has no reliable network wake of its own beyond
what `WCSession` already provides), and the background task's only real payoff *is* refreshing the
widget's timeline.

This is the **least specified part of the design** — spec §8 details the app's one screen in full;
it says nothing about the widget's own layout beyond naming it as in-scope. Scope it conservatively:
one family (`.accessoryCircular`, a percentage ring — the watch face complication people actually
use this shape for), reading the same mirror `WristView` does, no interactivity (no `Button(intent:)`
— the phone widget's `AddWaterIntent` has no watch equivalent in v1, and inventing one is exactly the
kind of scope growth spec §12 rules out for a first version).

- [ ] **Step 1: The Info.plist and entitlement**

New `Entitlements/WaterBuddyWatchWidgetExtension.entitlements` — identical App Group entitlement as
the other three files under `Entitlements/`.

New `WaterBuddyWatchWidget-Info.plist` (outside any synchronized folder, same reasoning as
`WaterBuddyWidget-Info.plist`: `GENERATE_INFOPLIST_FILE` cannot express the `NSExtension` dictionary
a WidgetKit extension needs, confirmed empirically in this session's own earlier migration):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDisplayName</key>
	<string>WaterBuddy Widget</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
	<key>CFBundleShortVersionString</key>
	<string>$(MARKETING_VERSION)</string>
	<key>CFBundleVersion</key>
	<string>$(CURRENT_PROJECT_VERSION)</string>
	<key>NSExtension</key>
	<dict>
		<key>NSExtensionPointIdentifier</key>
		<string>com.apple.widgetkit-extension</string>
	</dict>
</dict>
</plist>
```

- [ ] **Step 2: The widget source**

New folder `WaterBuddyWatchWidget/`. `WaterBuddyWatchWidget/WaterBuddyWatchWidgetBundle.swift`:

```swift
import WidgetKit
import SwiftUI

@main
struct WaterBuddyWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        WaterBuddyWatchWidget()
    }
}
```

`WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift`:

```swift
//
//  WaterBuddyWatchWidget.swift
//  WaterBuddyWatchWidget
//
//  One family: `.accessoryCircular`, a percentage ring — the shape people actually use this
//  complication family for. No interactivity: the phone widget's `AddWaterIntent` has no watch
//  equivalent in v1 (spec §12).
//

import WidgetKit
import SwiftUI

struct WristWidgetEntry: TimelineEntry {
    let date: Date
    let percentage: Int
}

struct WristWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WristWidgetEntry {
        WristWidgetEntry(date: .now, percentage: 62)
    }

    func getSnapshot(in context: Context, completion: @escaping (WristWidgetEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WristWidgetEntry>) -> Void) {
        completion(Timeline(entries: [currentEntry()], policy: .after(Date().addingTimeInterval(15 * 60))))
    }

    /// Reads the persisted mirror directly, never through `WristModel.shared` — a `TimelineProvider`
    /// is `nonisolated`, and `WristModel` is `@MainActor` (rule `40-widget`'s "the provider reads
    /// `WaterSnapshot`, never `DataManager.shared`", one platform over).
    private func currentEntry() -> WristWidgetEntry {
        guard let data = DataManager.sharedDefaults.data(forKey: DataManager.Key.wristMirror),
              let mirror = try? JSONDecoder().decode(WristMirror.self, from: data),
              mirror.dailyGoal > 0 else {
            return WristWidgetEntry(date: .now, percentage: 0)
        }
        let percentage = Int((Double(mirror.currentWater) / Double(mirror.dailyGoal) * 100).rounded())
        return WristWidgetEntry(date: .now, percentage: min(999, max(0, percentage)))
    }
}

struct WaterBuddyWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WaterBuddyWatchWidget", provider: WristWidgetProvider()) { entry in
            Gauge(value: Double(entry.percentage), in: 0...100) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(entry.percentage)")
            }
            .gaugeStyle(.accessoryCircular)
            .tint(Aurora.blue)
        }
        .configurationDisplayName("WaterBuddy")
        .description("Today's hydration.")
        .supportedFamilies([.accessoryCircular])
    }
}
```

- [ ] **Step 3: `project.pbxproj` — a fourth target, following the exact same recipe as Tasks 9-10**

Snapshot first (same as every earlier `project.pbxproj` task). Add, mirroring the phone widget's own
target structure exactly, but on `SDKROOT = watchos`:

- `PBXFileReference`: `0F905F94E31358A8DA684AD1 /* WaterBuddyWatchWidget.appex */`
- `PBXFileSystemSynchronizedRootGroup`: `33DC46EA11D3C04703593F86 /* WaterBuddyWatchWidget */`, `path = WaterBuddyWatchWidget;`
- Empty `Sources`/`Frameworks`/`Resources` phases: `E5FD1B49B0845E339CC40D3D`, `962AF6F908BA794E64141D8D`, `B713E4FD3EF6F044A6B875BD`
- `PBXBuildFile`: `1D738DC68CF7FBA33FA89534 /* WaterBuddyWatchWidget.appex in Embed Foundation Extensions */`
- `PBXCopyFilesBuildPhase` on the **`WaterBuddyWatch`** target (not `WaterBuddy`): `B6DA5435030114F606F1D773 /* Embed Foundation Extensions */`, `dstSubfolderSpec = 13`, `dstPath = ""`
- `PBXContainerItemProxy` + `PBXTargetDependency`: `0458C69E759D4FC94F0700B3` / `90A806523B8C042A25ED3F9C`, remote target `7781D68288C3A844B1E2C373`, added to `WaterBuddyWatch`'s own `buildPhases`/`dependencies` (not `WaterBuddy`'s — this widget embeds into the **watch app**, exactly as `WaterBuddyWidgetExtension` embeds into the **phone app**, never the other way round)
- `PBXNativeTarget` `7781D68288C3A844B1E2C373 /* WaterBuddyWatchWidget */`, `productType = "com.apple.product-type.app-extension"`, `fileSystemSynchronizedGroups = ( 33DC46EA11D3C04703593F86 )`
- `XCBuildConfiguration` Debug/Release (`EF33FF31651EA0BB9FABD461` / `486A8CC96231B7D520FB84D0`): `CODE_SIGN_ENTITLEMENTS = Entitlements/WaterBuddyWatchWidgetExtension.entitlements;`, `GENERATE_INFOPLIST_FILE = NO;`, `INFOPLIST_FILE = "WaterBuddyWatchWidget-Info.plist";`, `PRODUCT_BUNDLE_IDENTIFIER = sardor.WaterBuddy.watchkitapp.WaterBuddyWatchWidget;`, `SDKROOT = watchos;`, `SUPPORTED_PLATFORMS = "watchsimulator watchos";`, `TARGETED_DEVICE_FAMILY = 4;`, `WATCHOS_DEPLOYMENT_TARGET = 26.5;`, `SKIP_INSTALL = YES;`
- `XCConfigurationList` `A86BA9E9038A371A1AEC1B29`
- `PBXProject`: add to `targets`, add `TargetAttributes` entry `{ CreatedOnToolsVersion = 26.6; }`

Follow Task 9's Steps 1-9 pattern exactly (snapshot, add, `plutil -lint`, `xcodebuild -list`, build,
positive-reference check) rather than repeating the full mechanical listing here.

- [ ] **Step 4: The background task**

In `WaterBuddyWatch/WaterBuddyWatchApp.swift`:

```swift
    var body: some Scene {
        WindowGroup {
            WristView()
        }
        .backgroundTask(.watchConnectivity) {
            WristLink.live.activate()
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadAllTimelines()
            #endif
        }
    }
```

- [ ] **Step 5: Verify**

```
xcrun simctl shutdown all
plutil -lint WaterBuddy.xcodeproj/project.pbxproj
xcodebuild -list -project WaterBuddy.xcodeproj
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidgetExtension \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
```

Expected: **the gate is now the full five invocations** spec §9.1 names (iOS unit, iOS UI, watchOS
unit, phone widget, watch app + watch widget) — all green, zero new warnings. Confirm
`WaterBuddyWatch.app/PlugIns/WaterBuddyWatchWidget.appex` exists in the built product, the same
positive check Task 9 ran for the phone side.

- [ ] **Step 6: Stage**

```bash
git add WaterBuddy.xcodeproj/project.pbxproj WaterBuddyWatchWidget/ WaterBuddyWatchWidget-Info.plist \
  Entitlements/WaterBuddyWatchWidgetExtension.entitlements WaterBuddyWatch/WaterBuddyWatchApp.swift
```

---

### Task 17: The doc and rule cascade

**Files:**
- Modify: `.claude/rules/70-privacy.md`, `40-widget.md`, `25-shared-storage.md`, `30-rollover.md`,
  `43-concurrency.md`, `80-notifications.md`, `20-state.md`, `85-testing.md`, `15-project.md`,
  `10-architecture.md`, `50-views.md`
- Modify: `CLAUDE.md`, `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/WIDGET.md`
- Modify: `HISTORY.md`, `tasks/lessons.md` (both append-only — new entries, nothing rewritten)
- Modify: each rule file's YAML frontmatter `globs:` key (spec §9.1's "glob problem")

**Interfaces:** none — documentation only. No source, test, or project file changes in this task.

Per rule `99-docs-cascade`: this runs **last**, because the code wins and a doc written from the plan
rather than from the finished tree is exactly the failure this repo's own `HISTORY.md` already
recorded once (`docs/AI_CONTEXT.md`'s "the verification step has to run before the entry that reports
it, not after"). Every claim below must be re-derived against the tree **as it stands after Task 16**,
not copied from this plan.

- [ ] **Step 1: The glob problem first — spec §9.1's own priority**

"Every rule file is scoped by a `globs:` frontmatter key... a new `WaterBuddyWatch/` folder auto-loads
3 of 18 rules." Check each rule file's frontmatter:

```bash
for f in .claude/rules/*.md; do echo "=== $f ==="; sed -n '1,10p' "$f" | grep -A3 "^globs:"; done
```

Widen every rule whose `globs:` currently matches only the four pre-watch folders (or a subset) to
also match `WaterBuddyWatch/**`, `WaterBuddyWatchTests/**` and `WaterBuddyWatchWidget/**` — at
minimum `65-accessibility` (spec explicitly names this one — its 44pt floor is load-bearing for
`WristView`'s pour rows), `43-concurrency`, `20-state`, `70-privacy`, `60-design-system`,
`40-widget`, `25-shared-storage`, `85-testing`, `15-project`, `10-architecture`, `50-views`,
`30-rollover`, `80-notifications`. Confirm the three already-`**/*`-globbed rules
(`00-workspace`, `90-git`, `95-dependencies`) need no change.

- [ ] **Step 2: `70-privacy.md` — the WatchConnectivity ruling**

Insert after "Nothing leaves the device" the amendment spec §9 already drafted in full (owner-approved
per this plan's spec, §14):

```markdown
## WatchConnectivity is a ruling, not an omission

The banned list names `URLSession`, `Network`, `CloudKit`, `HealthKit`. It does not name
`WatchConnectivity`, and that absence is not permission — this rule's bar is *"Adding any other
capability requires a written justification in this file first."* Here is the justification.

`WatchConnectivity` links two devices the same person owns and has personally paired. There is
no account, no server, no third party, and **no entitlement** — it is the only inter-device
transport in the Apple SDK that needs none. Nothing is transmitted that the user did not author
on one of the two devices. On that basis it is inside the principle "nothing leaves the device",
read as "nothing reaches anyone else", and it is permitted.

Three limits are conditions of the permission:
- **The system's transfer queue is outside the App Group.** A payload handed to
  `transferUserInfo` lives in a system daemon until the counterpart runs and **survives app
  termination**. `deleteLog(_:)` removes the row and does not cancel the transfer. The apply
  ledger is what makes a re-sent copy of a deleted serving a no-op rather than a resurrection —
  a privacy mechanism as much as a correctness one.
- **No wire field may reach a notification, a Live Activity, or any surface outside the two
  apps' own screens.**
- **No third framework rides in behind it.** `HealthKit`, `CoreLocation` and `CloudKit` remain
  banned by name, and a watch app is exactly where someone will propose all three.
```

- [ ] **Step 3: `40-widget.md` — the second exception set, and the live divergence**

Add, after the existing "Target membership" section: a short paragraph stating the watch's
exception set (`3B60BAE6703F44AE6C46153F`, Task 9) is a **separate contract** from the widget's six
— the `target` field on a `PBXFileSystemSynchronizedBuildFileExceptionSet` is scalar, so one set can
never serve two targets, and the watch's own files (`WristModel.swift`, `WristView.swift`, etc.) are
invisible to the widget and vice versa.

**Fix the live divergence spec §9.2 names**, independent of the watch: line 77 (as read earlier this
session) reads *"`DataManager.requestReminderReschedule` keeps its `guard !isAppExtension else {
return }`"*. The code has read `guard role.mayFileReminders else { return }` since the role model
landed (2026-08-31). Correct the sentence to name the current predicate, and add the reason a watch
excludes it too: `.watchApp`/`.watchExtension` both answer `mayFileReminders == false`.

- [ ] **Step 4: `80-notifications.md` — the same live divergence, second file**

Line 101 (as read earlier this session) carries the identical stale sentence,
*"`DataManager.requestReminderReschedule` keeps its `guard !isAppExtension else { return }`"* —
verbatim, per spec §9.2's "two rule files ... quote the same sentence." Same fix as Step 3.

- [ ] **Step 5: `25-shared-storage.md` — verify the six-site census is current, and add the watch-local suite**

The six-site table (spec §3.1) should already read correctly if it was fixed in the role-model
cascade HISTORY.md records — confirm with `grep -n "isAppExtension\|role\."
.claude/rules/25-shared-storage.md` and correct only what's actually stale. Add a new subsection
naming the watch's **own, separate** App Group container (same identifier string, different physical
device — never confuse the two) and its three keys (`Key.wristOutbox`, `Key.wristMirror` on the
watch; `Key.wristApplied` on the phone).

- [ ] **Step 6: `30-rollover.md`, `43-concurrency.md`, `20-state.md`, `10-architecture.md`, `50-views.md`, `15-project.md`, `85-testing.md`**

- `30-rollover.md`: note `WristPour.at`/`WristPlan` follow the same instant-vs-ordinal split
  `WaterLog.timestamp` already does — an instant that doesn't move, bucketed on read, never stored
  as a day.
- `43-concurrency.md`: add `WristLink` as the second instance of "never `@MainActor`" (alongside
  whatever the file already names for `NotificationManager`'s constraints), and record the
  `Task { @MainActor in }` hop pattern as the sanctioned one for a `WCSessionDelegate` callback,
  distinct from the `queue: .main` + `MainActor.assumeIsolated` pattern used elsewhere.
- `20-state.md`: add the "one honest weakening" from spec §7 — "`DataManager` is the only writer"
  becomes "one writer per store: `DataManager` for the phone's pair, `WristModel` for the watch's
  suite" — stated plainly, not hidden.
- `10-architecture.md`: the same weakening, spec §9.1 flags it belongs in **both** files, not one.
- `50-views.md`: correct "`HomeView.vesselSlots` owns the names, glyphs and order" (Task 14, Step 0
  moved it to `WaterSurface.swift`) — name the new home and why (a second, non-view consumer).
- `15-project.md`: the target/scheme/exception-set counts are now stale in every direction — six
  targets, four schemes (confirm which actually exist per `xcodebuild -list`), **two**
  `PBXFileSystemSynchronizedBuildFileExceptionSet`s not one, four synchronized-folder-bearing
  targets become six. Re-derive every number from `xcodebuild -list` and a `grep -c` over
  `project.pbxproj` rather than incrementing what was there.
- `85-testing.md`: replace the three-invocation fenced gate block with the five spec §9.1/§10
  describes, each with its exact `-destination` string (including the watchOS ones — Task 9's Step
  6/10 already pin `OS=26.5,name=Apple Watch Series 11 (46mm)`; use those verbatim rather than
  re-deriving a possibly-different one now), and add the watchOS-fixture guidance §9.1 says is
  missing: throwaway suite, injected clock, same as the iOS side.

- [ ] **Step 7: `CLAUDE.md` and `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/WIDGET.md`**

`CLAUDE.md`'s target table gains two rows (`WaterBuddyWatch`, `WaterBuddyWatchWidget`, `LIVE`) and a
line on the watch's own local App Group suite. `docs/AI_CONTEXT.md` gets the new file list, new test
counts (re-derive with the `grep -cE '^\s*@Test'` command rule `85-testing` specifies — never a
number carried over from this plan), the five-invocation gate result, and retires any known issue
this plan closed. `docs/STATE.md` gains the three new keys with justification, matching its existing
per-key format. `docs/WIDGET.md` is unaffected unless the phone widget's own contract changed (it
didn't in this plan) — verify with `grep -c 'Wrist\|WatchConnectivity' docs/WIDGET.md` before
deciding whether to touch it at all, per rule `99-docs-cascade`'s "never publish a doc change nothing
required."

- [ ] **Step 8: `HISTORY.md` and `tasks/lessons.md`**

One `HISTORY.md` checkpoint (append-only, dated, following the existing entries' own format exactly:
What/Resolutions/Files touched/Verification/Not verified/Next steps), covering this plan's full arc
in one entry — not seventeen. State plainly what remains **not verified**: real device behaviour
(everything Task 8's simulator probe couldn't reach), and the watch widget's on-face rendering
(no automated coverage exists for widget rendering on either platform, per rule `85-testing`'s
standing note). `tasks/lessons.md` gets one entry per genuinely new pitfall this plan's execution
actually hit — not a restatement of the spec's own already-recorded lessons.

- [ ] **Step 9: Verify the doc sweep itself**

```bash
grep -rn "isAppExtension" .claude/ CLAUDE.md docs/ 2>/dev/null
```

Expected: **zero** hits outside historical/quoted context (e.g., inside a "was" table cell showing
the old vs. new predicate) — this is the same closing check the role-model cascade's own HISTORY.md
entry used to catch the `WIDGET.md` miss it later had to correct in a second entry. Run it **before**
writing the checkpoint that reports the sweep clean, not after (that entry's own recorded lesson).

- [ ] **Step 10: Final full gate, one more time, after every doc edit**

```
xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17'
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidgetExtension \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'
```

Expected: all five green, zero warnings anywhere. This is the number that goes in the `HISTORY.md`
checkpoint — run it in the foreground and read the actual output, never carried over from an earlier
task's run.

- [ ] **Step 11: Stage everything from this task**

```bash
git add .claude/ CLAUDE.md docs/ HISTORY.md tasks/lessons.md
```

**Do not run `/commit`.** Per rule `90-git`, that is the owner's call — this plan's last task ends
on staged, verified, documented work, exactly as every task before it did.
