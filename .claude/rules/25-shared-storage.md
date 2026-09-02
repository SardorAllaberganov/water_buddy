---
description: The App Group — two stores, one suite, and who may write on behalf of the group
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "Entitlements/**", "**/*.entitlements", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# Shared Storage

Both stores live in one App Group, `group.sardor.WaterBuddy`: the SwiftData file
`WaterBuddy.store` and the `UserDefaults` suite. The suite is a **derived cache** of the logs, and
it is the only thing the widget can read.

## The group identifier
- Spell it in code only as `DataManager.appGroupIdentifier`. A second spelling resolves a different
  (or nil) container: the app writes one suite, the widget reads another, and the Home Screen shows
  stale water with no error anywhere
- Every signed target that touches WaterBuddy state ships its own file under `Entitlements/` listing
  the group in `com.apple.security.application-groups`, wired via `CODE_SIGN_ENTITLEMENTS` in
  **both** Debug and Release
- Probe availability with
  `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier:) != nil`. **Never** by
  checking that `UserDefaults(suiteName:)` returned non-nil — it hands back a live object that
  silently writes process-locally when the entitlement is missing, so the nil-check always passes
  and the missing-capability diagnostic never fires
- `isAppExtension` is `Bundle.main.bundleURL.pathExtension == "appex"`, resolved once as a
  `static let`. Do not add a competing detection scheme; two checks can disagree and leave one guard
  open. It is a **two-state answer to a four-state question** — see `DataManager.role` below

## Keys
- Every key is a `static let` on `DataManager.Key`, built from the private `"sardor.WaterBuddy."`
  prefix. No raw key string appears anywhere else
- An App Group domain is shared by every target that joins it, so an un-prefixed key is a collision
  waiting for the next extension
- Absence carries meaning for `Key.isGoalSet` and `Key.language`: never materialise a sentinel for
  "not chosen". The `language` setter calls `removeObject(forKey:)` for `.system`, because a stored
  code would pin the app to today's system language forever
- Validate on the way out, not just on the way in: read the goal with `object(forKey:) as? Int` (not
  `integer(forKey:)`, which reads a missing key as 0), clamp `currentWater` to
  `0...maximumDailyIntake`, and fall back to `.system` for an unrecognised language code

## Only the app writes on behalf of the group

**Six** sites are guarded, not four — the census below was wrong from 2026-08-29 until
2026-09-01, undercounting by two (`republishHistory()` and `requestReminderReschedule`), and every
site has since been converted from `!Self.isAppExtension` to `DataManager.role`, a **four-state**
`nonisolated static let` (`.phoneApp`, `.phoneExtension`, `.watchApp`, `.watchExtension`) resolved
from `isAppExtension` plus `#if os(watchOS)`. `isAppExtension` answered wrongly for a watch: a
watchOS app is a `.app`, not an `.appex`, so `pathExtension == "appex"` is `false` and every
`!isAppExtension` guard would have *opened* on the wrist. The six sites ask **four different
questions**, each an exhaustive `switch` with no `default`, so a fifth binary fails to compile until
somebody answers all four for it — a grep for `!Self.isAppExtension` in the tree now returns zero:

- **`role.ownsSharedStorage`** — *is this container my own first-class home?* Gates materialising
  the goal in `init` (so a widget reading the plist directly never sees a missing key as goal 0 —
  a non-owner doing it plants a key the migration then reads as "already migrated") and the
  fresh-install day stamp in `resetIfNeeded()` (when `Key.lastActiveDay` is absent only the app may
  adopt today, and the function returns `false` rather than reporting a rollover)
- **`role.mayHaveLegacyStandardDefaults`** — *has my `.standard` ever held WaterBuddy state?* Gates
  `seedFromCachedTotalIfNeeded()` (keep all three guards — the role check, no rows today, and the
  cached total stamped *today*; dropping the second doubles the user's water on next launch,
  dropping the third resurrects yesterday's total as a serving logged today) and
  `migrateIfNeeded(from:into:)` (a non-owner's `UserDefaults.standard` is its own domain — an
  `.appex`'s own bundle, or a different physical device entirely for a watch — and has never held
  WaterBuddy state; it would copy nothing while still burning the flag)
- **`role.drawsHistory`** — *do I have a history surface to draw?* Gates `republishHistory()`. Cost
  rather than correctness: `recomputeToday()` is deliberately unguarded, so `AddWaterIntent` still
  reaches `saveAndRecompute()` on every widget tap
- **`role.mayFileReminders`** — *may I file notifications for this user?* Gates
  `requestReminderReschedule` (rule `80-notifications`). The one question whose wrong answer is
  immediately user-visible: `ReminderPlan.Slot.identifier` is a pure function of day and hour, so a
  second notification centre filing the identical plan cannot dedupe against the first

Only `.phoneApp` answers `true` to any of the four today. `ProcessRoleTests`
(`WaterSnapshotTests.swift`) pins all four, including the watch case explicitly.

The extension's legitimate write door is `AddWaterIntent.perform()`, which is `@MainActor` and goes
through `DataManager.shared.addWater(amount:)` — a normal mutation, safe because it re-reads first.
The watch's own legitimate write door is `WristModel`, which never touches this App Group at all —
see *The watch's own, separate suite* below. It is the *unguarded group bookkeeping* above that a
non-owner process may never do.

## The one-shot migration
- Copy **key by key**, skipping any key already present in the suite. Never abandon or perform the
  whole set based on probing one key: a widget tap that lands before the first post-update launch
  writes `currentWater` and nothing else
- `Key.didMigrateFromStandard` is set once, unconditionally, in the `defer` — so a partial migration
  still cannot rerun
- Treat it as **burn-once**. Never set, clear or hand-edit it in the real `group.sardor.WaterBuddy`
  suite from a script, a test or a debug helper; there is no path inside the app to undo it, and a
  burned flag permanently strands an upgrading user's data
- `DataManager.prepareSharedStorage()` is called in `WaterBuddyApp.init()` so the migration lands at
  app launch rather than wherever the lazy global happens to be touched first

## Failing soft
- When the container is unreachable, `sharedDefaults` falls back to `.standard` and prints inside
  `#if DEBUG`, naming the missing capability. Never `fatalError`, never force-unwrap, never fail
  silently
- The store follows the same ladder: App Group file → process-local → in-memory, each failure
  announced in `DEBUG`. `try!` is reachable only for the terminal in-memory container
- Do not change the store's file name or path. It orphans every existing `WaterLog` — the user's
  whole history disappears with no error

## The watch's own, separate suite

`WaterBuddyWatch` and `WaterBuddyWatchWidget` both call `DataManager.sharedDefaults`, which resolves
the **same App Group identifier string**, `group.sardor.WaterBuddy` — but the watch is a different
physical device with its own filesystem, so this is a **different container** on disk, not a second
reader of the phone's. Never confuse the two: nothing written into the watch's suite is visible to
the phone's suite, or vice versa, except by an explicit `WatchConnectivity` transfer (rule
`70-privacy`). Both suites are reached through the identical `DataManager.sharedDefaults` accessor
because that is the only code path either binary has for resolving an App Group suite — not because
they share storage.

The watch's suite holds three keys, all on `DataManager.Key`, none shared with the phone's eight:

| Key | Written by | Read by | Holds |
|---|---|---|---|
| `Key.wristOutbox` | `WristModel`, on the watch | `WristModel`, on the watch | The watch's own pending pours not yet acknowledged by the phone, JSON-encoded `[WristPour]` |
| `Key.wristMirror` | `WristModel`, on the watch | `WristModel` **and** `WaterBuddyWatchWidget`, on the watch | The last `WristMirror` received from the phone, JSON-encoded — what the watch draws before its first `updateApplicationContext` of a fresh launch |
| `Key.wristApplied` | `DataManager.ingest(_:)`, on the **phone** | `DataManager.ingest(_:)`, on the **phone** | The phone's own per-day applied ledger, JSON-encoded `[Int: [UUID]]` — day ordinal → ids already folded into `WaterLog`. Lives in the *phone's* suite, not the watch's, despite the `wrist` prefix: it is the phone's record of which wrist-authored pours it has already applied, closing the conjunction guard spec §4 requires (a deleted-then-resent pour must not resurrect) |

`wristOutbox` and `wristMirror` are the watch's own local bookkeeping — a phone reading them would
find nothing, because they live in a container on a different device. `wristApplied` is the mirror
case: it lives in the phone's container and the watch never reads or writes it. All three are still
namespaced under the shared `"sardor.WaterBuddy."` prefix and listed in `Key.all`, because the
App Group identifier string, and therefore the key-collision hazard the prefix defends against, is
identical on both devices even though the physical containers are not.

## Target membership
- Any Swift file more than one target needs is listed in a
  `PBXFileSystemSynchronizedBuildFileExceptionSet` in `project.pbxproj`. The `target` field on each
  set is **scalar** — one set can never serve two targets — so `project.pbxproj` currently carries
  **three** such sets, one per native target that reaches into the `WaterBuddy/` folder:
  `WaterBuddyWidgetExtension` (six files), `WaterBuddyWatch` (six files, including `WristPlan.swift`),
  and `WaterBuddyWatchWidget` (six files as of 2026-09-01 — it gained `WristPlan.swift` when spec §16
  made the complication count pending outbox pours). Full membership and
  the reasoning behind each omission are in rule `40-widget`'s *Target membership* section. The
  synchronized root group gives none of them anything by default
- A new shared file, or a rename, that is missing from the relevant exception set fails to compile
  **only** in that one target — which neither the phone app scheme's nor the watch app scheme's
  green test run touches for the others. Build every extension separately to prove it
  (rule `15-project`)
