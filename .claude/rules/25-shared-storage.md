---
description: The App Group — two stores, one suite, and who may write on behalf of the group
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "Entitlements/**", "**/*.entitlements"]
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
  open

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
Four sites are guarded by `!Self.isAppExtension`, and each guard has its own reason:
- **Materialising the goal** in `init` — so a widget reading the plist directly never sees a missing
  key as goal 0. An extension doing it plants a key the migration then reads as "already migrated"
- **The fresh-install day stamp** in `resetIfNeeded()` — when `Key.lastActiveDay` is absent only the
  app may adopt today, and the function returns `false` rather than reporting a rollover
- **`seedFromCachedTotalIfNeeded()`** — keep all three guards (`!isAppExtension`, no rows today, and
  the cached total stamped *today*). Dropping the second doubles the user's water on next launch;
  dropping the third resurrects yesterday's total as a serving logged today
- **`migrateIfNeeded(from:into:)`** — an extension's `UserDefaults.standard` is its own `.appex`
  domain and has never held WaterBuddy state; it would copy nothing while still burning the flag

The extension's legitimate write door is `AddWaterIntent.perform()`, which is `@MainActor` and goes
through `DataManager.shared.addWater(amount:)` — a normal mutation, safe because it re-reads first.
It is the *unguarded group bookkeeping* above that an extension may never do.

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

## Target membership
- Any Swift file both processes need is listed in `membershipExceptions` for the "WaterBuddy folder
  in WaterBuddyWidgetExtension" exception set in `project.pbxproj`. The synchronized root group
  gives the extension nothing by default
- A new shared file, or a rename, that is missing from that list fails to compile **only** in the
  widget target — which the app scheme's green test run never touches. Build the extension
  separately to prove it (rule `15-project`)
