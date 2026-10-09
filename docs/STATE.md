# STATE — the stored shape

What is actually on disk in the App Group, as of the source in this tree. This is the derived
reference; the *rulings* behind these choices are in the DocC on `DataManager` and in
`.claude/rules/20-state`, `25-shared-storage` and `30-rollover`.

**Last updated:** 2026-10-09 (twenty-fourth pass — `/doc_sync` after known issue #73. **No key added,
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
| Holds | every ``WaterLog`` — `id`, `amount`, `timestamp` | nine keys (below) |
| Status | **source of truth** | **derived cache** |
| Written by | `DataManager` (app *and* `AddWaterIntent` in the extension) | `DataManager` only |
| Read by | the app | the app **and the widget** |

**Today's total is not stored anywhere as an authored value.** It is the sum of today's logs,
recomputed after every mutation by `DataManager.recomputeToday()` and written through the
`currentWater` setter — so the clamp, the equality guard and the widget doorbell all still fire
exactly once per real change.

**The widget never opens SwiftData.** A `TimelineProvider` carries no isolation and a
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
| `appGroupIdentifier` | `group.sardor.WaterBuddy` | also spelled in **two** entitlement files, invisible to the compiler |
| `defaultDailyGoal` | `2_000` ml | also the value `isGoalSet`'s inference treats as ambiguous |
| `defaultServing` | `250` ml | the middle vessel **before the user edits it**, and the resolver's fallback. Renamed from `standardServing`, which asserted an invariant the editable vessels removed |
| `defaultServings` | `[150, 250, 500]` | the three vessels before the user edits them; `[1]` is `defaultServing` |
| `usualSlot` | `1` | which vessel the one-tap doors log — the Glass. `usualServing(in:)` reads its amount there and the Control Center control draws that slot's glyph, so the index is spelled once; `theUsualSlotIsTheGlass` pins it to the Glass by name. Added 2026-10-08 |
| `maximumDailyIntake` | `100_000` ml | upper clamp for both the total and the goal |

## The eight phone keys, plus a ninth shared with the watch's side of the wire

Every key is built in `DataManager.Key` from the prefix **`sardor.WaterBuddy.`**. An App Group
domain is shared by every target that joins it, so an un-prefixed key is a collision waiting for
the next extension. `Key.all` — the roster the widget tripwires read — now lists **eleven** keys in
total; the eight below plus three more, all documented in *The watch's own suite* further down.

| Stored key | Type | Range / clamp | Written by | Why it exists |
|---|---|---|---|---|
| `sardor.WaterBuddy.currentWater` | `Int` | `0...100_000` | app + extension | Today's total in ml — **derived**, the sum of today's `WaterLog` rows. The key the widget actually reads. |
| `sardor.WaterBuddy.dailyGoal` | `Int` | `1...100_000` | **app only** | The target. Clamped to ≥ 1 so `progress` cannot divide by zero. Materialised at app launch so a widget never reads a missing key as `0` and shows the first sip as 100%. |
| `sardor.WaterBuddy.lastActiveDay` | `Int` | `yyyyMMdd` ordinal | **app only** | The day `currentWater` belongs to. An ordinal, not a `Date`, so travel cannot re-interpret it (see below). |
| `sardor.WaterBuddy.isGoalSet` | `Bool` | — | app only | Whether the user has *chosen* a goal, so setup is shown once. **Deliberately never materialised — its absence carries meaning.** |
| `sardor.WaterBuddy.servings` | `[Int]` | exactly 3, each `1...100_000` | **app only** | The three quick-add vessel amounts, positional: Cup, Glass, Bottle. **Index 1 is the vessel the widget draws and logs, and the one the Siri shortcut and the Control Center control log** — read through `DataManager.usualServing(in:)`, the one definition they all call, at the index named once as `DataManager.usualSlot` — which is how the front doors agree now that the amount is no longer a shared constant. Never materialised — absence means the user kept the defaults. Never sorted or deduped: sorting would move which vessel the widget follows. Any anomaly (failed cast, wrong arity, an element out of range) discards the **whole** triple rather than repairing one element, because a partly-repaired triple is a row nobody authored. |
| `sardor.WaterBuddy.remindersEnabled` | `Bool` | — | app only | The reminders toggle. **Absent until switched on** — see below. |
| `sardor.WaterBuddy.language` | `String` | — | app + widget; the watch reads it secondhand, as `WristMirror.languageCode` | The chosen UI language (`"en"`/`"ru"`/`"uz"`). **Absent means follow the device**, so it is never materialised either. |
| `sardor.WaterBuddy.didMigrateFromStandardDefaults` | `Bool` | — | **app only** | The one-shot flag for the migration below. Cannot be reset from inside the app. |
| `sardor.WaterBuddy.wristApplied` | `Data` (JSON `[Int: [UUID]]`) | **unbounded per day, until the 90-day trim** — see note below | **app only, via `ingest(_:)`** | The phone's per-day applied ledger for wrist-authored pours — day ordinal → the `WaterLog.id`s already folded in. `nonisolated`, unlike its seven neighbours above, because `readAppliedLedger(from:)`/`writeAppliedLedger(_:to:keepingDaysSince:)` are themselves `nonisolated static` and a nested type's members otherwise infer the enclosing `@MainActor` class's isolation. Trimmed to the last `appliedLedgerRetentionDays` (90) real calendar days on every write — never by subtracting a raw integer from the `yyyyMMdd` ordinal, which borrows across the month/day radix incorrectly (a real bug this plan introduced and fixed in its own Task 4, before it shipped). A write also protects any day it just folded into, even one already older than the 90-day cutoff, so the same write that adds an entry can never be the write that trims it (final review, `ingest(_:)`'s cutoff is `min(normalCutoff, foldedDaysThisPass.min() ?? normalCutoff)`). |

> **This ledger is not capped at `maximumAckedIds` (256).** That cap belongs to a different, related
> but distinct thing: `WristMirror.acked`, the wire mirror's own array, sent phone → wrist on every
> publish. The mirror flattens *this* ledger across every retained day and truncates the result to
> 256 ids, newest day first, so the cap is a property of what goes out over `WatchConnectivity`, not
> of what this key holds on disk. Conflating the two is exactly the shape of the bug the final
> whole-branch review found: an ascending flatten kept the ledger's *oldest* ids under the mirror's
> cap instead of the newest, permanently stranding freshly-folded pours the ledger itself had
> recorded correctly the whole time.

> Note the ninth key's *stored string* is `…didMigrateFromStandardDefaults` while the constant is
> named `Key.didMigrateFromStandard`. The string is the thing that persists; do not "tidy" one to
> match the other without a migration.

## The watch's own suite

`WaterBuddyWatch` and `WaterBuddyWatchWidget` resolve the identical App Group *identifier string*,
`group.sardor.WaterBuddy`, through the same `DataManager.sharedDefaults` accessor the phone uses —
but the watch is a **different physical device**, so this is a different container on disk, holding
none of the phone's nine keys above and read by none of the phone-side code. Never confuse "same
identifier" with "same storage": nothing written on one device is visible on the other except
through an explicit `WatchConnectivity` transfer (rule `70-privacy`).

| Stored key | Type | Range / clamp | Written by | Read by | Why it exists |
|---|---|---|---|---|---|
| `sardor.WaterBuddy.wristOutbox` | `Data` (JSON `[WristPour]`) | at most 64 pours per chunk sent, unbounded at rest | `WristModel`, **watch only** | `WristModel`, watch only | The watch's own pending pours not yet durably queued to the phone (or queued but not yet acknowledged back). Local to the watch; the phone never reads or writes this key. |
| `sardor.WaterBuddy.wristMirror` | `Data` (JSON `WristMirror`) | one value, no clamp — the phone's own values are already clamped when composed | `WristModel`, **watch only**, from a decoded `WCSession` application context **or a complication push** (spec 2026-10-07 §4.5) — either way through `apply(_:)`, which never takes a mirror composed before the one held, unless the one held is stamped more than a minute ahead of the watch's own clock | `WristModel` **and** `WaterBuddyWatchWidget`, watch only | The last mirror received from the phone — `currentWater`, `dailyGoal`, `servings`, `languageCode`, `isGoalSet`, `composedAt`, `phoneDayStart`, `phoneDayEnd`, `acked`. **`currentWater` is the phone's total for `[phoneDayStart, phoneDayEnd)` and for nothing after it (spec §17, 2026-10-05):** `WristPlan.todaysTotal(mirror:outbox:now:calendar:)` counts it only while `now < phoneDayEnd`, for `WristModel` and the complication alike, so a phone that slept through midnight no longer leaves yesterday's water on the wrist. `phoneDayEnd` is an instant composed on the phone's own calendar, not a day the watch re-reads under its own zone; it is optional only so a value persisted before it existed still decodes, and when absent the watch falls back to its own next midnight after `phoneDayStart`. The phone composes `currentWater` through `DataManager.snapshot`'s rollover, so a stale cached total never goes out under today's window. What the watch draws before its first `updateApplicationContext` of a fresh launch. **Its absence is no longer a dead end (spec §16, 2026-09-01):** `WristModel.displayGoal` falls back to `DataManager.defaultDailyGoal` and `WristView` draws a usable screen anyway, saying so in its attribution line — the key's absence now means "nothing from the phone yet", not "show a nag instead of a screen". `WaterBuddyWatchWidget` reads it directly, never through `WristModel.shared` (the identical discipline rule `40-widget` holds the phone widget to), and now takes the same fallback and adds `Key.wristOutbox`'s pending pours, so the face cannot read 0% while the app beside it shows real water. |

Both are written **only** by `WristModel`, never by `DataManager` — the one honest weakening rule
`20-state` now states plainly: one writer per store, not one writer full stop. `WristModel` never
opens SwiftData and never touches the phone's own App Group container.

Four keys are carried by the migration — `currentWater`, `dailyGoal`, `lastActiveDay`,
`isGoalSet`. `didMigrateFromStandardDefaults` is not, because it *is* the bookkeeping; and
`language` is not, because it did not exist before the App Group did, so there is nothing in a
pre-capability `UserDefaults.standard` to carry.


### `WaterLog` (SwiftData)

| Property | Type | Notes |
|---|---|---|
| `id` | `UUID` | Stable across edits. **Not** `@Attribute(.unique)`: two processes insert here, and a unique constraint turns a benign collision into a failed save in whichever lost the race. |
| `amount` | `Int` | Millilitres. Positive; non-positive servings are rejected by `addLog`, not stored as zero rows. |
| `timestamp` | `Date` | When the serving happened. |

**A `Date` here does not contradict rule `30-rollover`.** That rule forbids storing *the day* as an
instant, because an instant re-read under a different time zone moves — which is how a user flying
west loses a day. A `timestamp` records *a moment*, which is real and does not move. The
distinction is in the read: `fetchLogsForToday()` never compares instants to decide which day a
serving belongs to. It derives the half-open bounds `[startOfDay, nextDayBoundary)` from
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

`DataManager.Key.all` lists all eleven keys — the phone's own nine plus the watch's two
(`wristOutbox`, `wristMirror`) — three lines under the declarations it mirrors.
Production code never reads it; it exists so the widget's two read-path tripwires —
`readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys` — can prove a snapshot
read created and altered *nothing*.

Those tripwires are only ever as wide as the list they are handed, and that list used to be
hand-written **in the test file**. It enumerated six of the seven keys for two releases, omitting
`remindersEnabled`, so both tripwires were blind to a whole key while their own DocC claimed they
covered "everything WaterBuddy has ever written into a suite". Rule `30-rollover` warns about
precisely this: the helper "will not notice a new one on its own".

Keeping the roster beside the declarations is what makes the omission hard rather than likely, and
`theTripwireHelperEnumeratesEveryStoredKey` fails the moment the two disagree. It was fixed
**before** the eighth key was added, not after.

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
guard !storedIsGoalSet else { return }                          // observation — still guarded
withMutation(keyPath: \.isGoalSet) { storedIsGoalSet = true }
```

Guarding both on `storedIsGoalSet` skips the only write of that key in the product. Edit such a
goal down to exactly `defaultDailyGoal` and the inference re-derives `false` on the next read, and
`RootView` cross-fades the app back into setup mid-session. This was unreachable while
`saveDailyGoal(ml:)` had one caller — `GoalSetupView` is presented only while the flag is `false`,
so the guard could never short-circuit — and became reachable when `SettingsView`'s `GoalCard`
became the second. `editingAnInferredGoalDownToTheDefaultPersistsTheFlag` pins it.

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
```

The equality guard is what keeps a no-op write from invalidating SwiftUI observers and from
ringing the widget doorbell. Arithmetic in `addWater` / `removeWater` uses
`addingReportingOverflow` / `subtractingReportingOverflow` and **saturates** — `.max` passed twice
pins at `maximumDailyIntake` rather than trapping. Non-positive amounts are ignored in both
directions.

`addWater` and `removeWater` call `refresh()` **before** computing the new total, because the
getter returns this instance's cached figure and two processes hold their own instance.

## The rows are published too, and only reads may cross

`todaysLogs` is a fourth observed property — today's servings, newest first — alongside
`currentWater`, `dailyGoal` and `isGoalSet`. It exists because `fetchLogsForToday()` reads the
store directly and calls no `access(keyPath:)`, so a view reading it never redraws, and a SwiftData
`@Query` is forbidden from a view (rule `10-architecture`). `HistoryView` is its only consumer.

Two properties of it are deliberate and both have tests:

- **No equality guard**, where `currentWater` and `dailyGoal` both have one. `WaterLog` is a
  `@Model` class whose `Hashable` conformance is by `persistentModelID`, so the array after an
  *amount edit* compares equal to the array before it; a guard would swallow exactly the change a
  history row needs to see (`editingALogInvalidatesObserversOfTodaysLogs`).
- **Read-only**, for the reason `isGoalSet` is: it is a consequence of the logs.

`refresh()` now ends in `republishTodaysLogs()` — a **read**. It re-reads the rows and does *not*
recompute the total from them:

```swift
func refresh() {
    loadFromStore()            // the total, out of the cache
    resetIfNeeded()            // the day, if it turned
    republishTodaysLogs()      // the rows — never the total
    republishHistory()         // the last seven days — a read, app-only
    rescheduleRemindersNow()
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
local days, oldest first, today last. `HistoryView` is its only consumer — the week card, whether
the card is drawn at all, and since 2026-10-07 the header's total for a past day and which day is
shown. *(Until then this read "the week card is its only consumer", which `HistoryView`'s own
`hasSomethingToShow` already contradicted.)* It **stores
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
  none of the phone's nine keys.
- **It is republished from three sites**, not one — `init`, `refresh()` and `saveAndRecompute()` —
  because a mutation must show up on the card immediately, and `addLog` calls `refresh()` *before*
  it inserts.

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
- **Stores nothing.** Like `history`, it is derived on every republish.

The window's start has one definition: `DataManager.historyWindowStart(endingOn:calendar:)`, beside
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
`aMoveAcrossMidnightRingsTheWidgetDoorbellOnce`). A watch pour can be re-timed safely: the applied
ledger is keyed by the pour's own `at`, which a resend repeats, and the existence check finds the row
by `id` wherever its time moved (`aRetimedWatchPourStaysDeletedWhenTheWatchResendsIt`).

## The sixth key, and the seam that reads it

`remindersEnabled` is a `Bool`, **absent until the user turns reminders on**. Like `isGoalSet` and
unlike `dailyGoal` it is never materialised: scheduling notifications for someone who never asked is
the wrong default, so "missing" and "off" have to mean the same thing.

It is settable — it is a genuine preference rather than a consequence — and carries the same
write-through and equality guard as `currentWater` and `dailyGoal`, so a no-op write neither
invalidates observers nor re-plans the day. Setting it re-plans **in both directions**: switching
reminders off has to *clear* what is already filed with the system, not merely stop adding to it.

**It is re-read on every `refresh()`** (2026-10-08, known issue #73). Only the app writes it, but a
widget extension's `DataManager.shared` can outlive the write, and `AddWaterIntent` files that
instance's plan. Until then `loadFromStore()` re-read the goal, the vessels and the language and left
this flag as `init` had read it. A press made after the toggle moved therefore filed an empty plan over
reminders just switched on, or a full one over reminders just switched off. The re-read sits behind the
same equality guard as its neighbours and reschedules nothing itself: `refresh()` always ends in a
reschedule. `aLongLivedExtensionPlansRemindersTurnedOnInTheApp` and
`aLongLivedExtensionStopsPlanningRemindersTurnedOffInTheApp` pin the two directions;
`refreshPublishesARemindersFlagChangedByAnotherProcess` and
`aRefreshThatFindsTheFlagUnchangedDoesNotChurnObservers` pin the publish and the guard.

`DataManager` takes a sixth injected dependency and hands out a plan; it never touches
`UserNotifications` itself:

```swift
rescheduleReminders: @escaping ([ReminderPlan.Slot]) -> Void = DataManager.requestReminderReschedule
```

Fired from **six** places, because one is not enough:

| Where | Why |
|---|---|
| `recomputeToday()` | every log mutation, from either process, with the fresh total in hand |
| `applyDailyReset(on:)` | it bypasses the `currentWater` setter, so a setter-only hook would miss **midnight** |
| `refresh()` | idempotent reconciliation on foreground — the backstop for a widget tap |
| the `remindersEnabled` setter | the preference itself, in both directions |
| the `dailyGoal` setter | **the goal is half of "goal reached"** — see below |
| `init` | an instance that never mutates anything still has to arrive at a correct schedule |

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
That input needs no trigger of its own. Only a log mutation can move it, and every one ends in
`recomputeToday()`, which republishes the rows from the same fetch before it reschedules.
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
vocabulary follow the phone's.

### The language is why nothing asks `Bundle.main`

iOS resolves `Bundle.main`'s localisation **once at launch and never again**, so an in-app picker
that only wrote a preference would need a relaunch to take effect. Every user-facing string in this
product instead resolves through `EnvironmentValues.strings`, a `Bundle` injected at each root from
`DataManager.language` — on the watch, from `WristModel.language`. Changing the model invalidates
observers, the roots re-evaluate, a different bundle travels down, and the tree redraws in place.

`.locale` is injected alongside it. Switching the strings without the locale leaves `4 500` wearing
the device's grouping separator inside a Russian sentence — half-translated reads as a bug in the
app rather than as a language it does not have. *Only sites that format against the locale honour
this:* `Text(_:format:)` on the phone and the watch's own readout (`WristVessel.readout`) group, but
every phone figure built with `String(format:)` and `%1$d` — the vessel's `1300 / 2000 ml`, the week
card's `Best 8050 ml` — groups in no language at all (`AI_CONTEXT.md` known issue #39).

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
has been logged today — not because anything was destroyed. `recomputeToday()` then refills the
cache from the logs.

`resetDailyProgress()` — the user-facing "start over" — is now the *only* path that deletes rows,
and it deletes **today's** only. Yesterday is history and a start-over button has no business
reaching into it.

`resetIfNeeded()`:

| Stored `lastActiveDay` | Behaviour | Returns |
|---|---|---|
| absent | **adopts today** (app only) and does not reset — a fresh install, or a build from before the marker | `false` |
| == today | nothing | `false` |
| != today | `applyDailyReset(on: today)` | `true` |

Called from `init`, from `refresh()`, and from the `NSCalendarDayChanged` /
`NSSystemTimeZoneDidChange` observers that catch the app sitting open across midnight or the user
crossing a zone. Those observers register with `queue: .main` and use `MainActor.assumeIsolated`
rather than a `Task` — the main queue *is* the main actor, and hopping would open a window where
two notifications interleave.

`resetDailyProgress()` is the user-facing "start over": unconditional, leaves `dailyGoal` alone.

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
nonisolated static let role: Role = {          // DataManager.swift:1400
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

**Four writes are guarded, by three different questions** (line numbers re-verified 2026-10-09 against
each guard's own line — the fix for #73 moved all six, by four lines or by thirteen. Before that,
2026-10-08: all six had moved since the 2026-09-01 check that followed the watchOS plan's ~500-line
addition):

1. **Materialising `dailyGoal` in `init`** (`:483`, `ownsSharedStorage`) — the write exists *for*
   the extensions; a non-owner doing it to itself puts a key in the group that the migration then
   mistakes for state the app already wrote.
2. **Stamping `lastActiveDay` on a fresh install** (`:1020`, `ownsSharedStorage`) — same reason.
3. **`seedFromCachedTotalIfNeeded`** (`:942`, `mayHaveLegacyStandardDefaults`).
4. **The migration itself** (`:1544`, `mayHaveLegacyStandardDefaults`).

Two further sites are guarded by the same enum but are not group bookkeeping: `republishHistory`
(`:864`, `drawsHistory`, cost rather than correctness) and `requestReminderReschedule` (`:1164`,
`mayFileReminders`, the one whose wrong answer is immediately user-visible).

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

`progress`, `progressUnclamped` and `percentage` exist on **both** `DataManager` and
`WaterSnapshot`, computed the same way, because the app and the widget must round to the same
number:

```
progress          = clamp(progressUnclamped, 0...1)
progressUnclamped = goal > 0 ? Double(currentWater) / Double(goal) : 0
percentage        = Int((progressUnclamped * 100).rounded())
```

A `body` that computes a displayed figure for itself is how the two start disagreeing.

## Tests that pin this

Seventeen suites, 203 `@Test` in total. `DataManagerTests`, `DailyGoalSetupTests` and
`ReminderSeamTests` (72 between them) cover the write path, the rollover, observation, the goal and
the reminder seam; `WaterSnapshotTests` (28) covers the read path, the day boundary and the
migration; `WaterLogStoreTests` (23) covers the log CRUD, the published rows and the seed migration;
`ReminderPlanTests` (22) pins *when* to remind, the quiet hour after a drink included, and
`NotificationManagerTests` (10) pins what happens to the plan, and `ReconcileQueueTests` (3) the
order plans are applied in; `HomeServingTests` (7) pins the quick-add row, `AppTabTests` (6) the tab
menu, and `HistoryServingTests` (5) the serving editor's offered range and its own fixture's
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

No test ever touches `group.sardor.WaterBuddy` or `UserDefaults.standard` — every test builds a
UUID-named throwaway suite and removes it. No test constructs a real `UNUserNotificationCenter`
either: `ReminderScheduler` is a struct of closures precisely so one can be stood behind.

**That second sentence was aspirational until 2026-08-31, and is now true.** `DataManager.init`
ends in `rescheduleRemindersNow()`, and the `rescheduleReminders:` parameter above defaults to
`DataManager.requestReminderReschedule`, which builds a real centre — so *merely constructing* a
manager reconciles against it. Six fixtures omitted the argument and had been doing exactly that
(`docs/AI_CONTEXT.md` known issue #6, now retired). All eleven construction sites in the test target
were audited; the six were closed, and the two files that held them each carry a test that fails if
the argument goes missing again. The same defect is still live in three `#Preview`s — known issue
#14, deliberately deferred to its own change.
