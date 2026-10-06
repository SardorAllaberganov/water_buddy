# WaterBuddy on the Wrist — design

**Status:** **approved by the owner, 2026-09-01 — full sync, v1 scope as written.** See §14.

When this was first written (2026-08-31, 23:16) nothing had been built, and that sentence was true.
It stopped being true 18 minutes later. **Sequence steps 1 and 3 have both landed**, and the
`Role` enum that step 3 added shifted every `DataManager.swift` line past ~1010 by ~78 lines, so
every citation into that region was stale. The reconciliation, in full:

| What changed | Where |
|---|---|
| Step 3 (the role model) **landed**, and as a **four**-state enum, not the three this document specified | §3, §11 |
| Step 1 (the tripwire) was **already done** before this document was written | §10, §11 |
| §2's headline chain **no longer runs** — the guard it turns on is now role-based | §2 |
| Citations into `DataManager.swift` past ~1010 re-derived (`:1057`→`:1138`, `:1094`→`:1175`, `:1345`→`:1417`) | §2, §3.1, §5 |
| "`:847` appears in no rule file" was **false**, and two of those rule files are now wrong about the code | §3.1, §9 |
| §8's UI has a **proven** watchOS compile blocker, which is what step 2 really is | §8, §11, §13 |
| §9's amendment list was missing `85-testing`, `15-project` and `10-architecture` | §9 |

**Authority.** This document is subordinate to the DocC on the type being changed, then
`.claude/rules/`, then `CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the
code wins and this document changes. It just did, in seven places.

**Provenance.** Every claim about the repository is read from the line cited, **re-derived against
the tree on 2026-09-01** — the first edition's citations were correct when written and were
invalidated by a refactor that landed the same evening, which is the argument for re-deriving them
rather than trusting them. Every claim about WatchConnectivity is the SDK header's, quoted, from
probes compiled against `iPhoneSimulator26.5.sdk` and `WatchSimulator26.5.sdk` at both
`-swift-version 5` and `6`.

**No runtime behaviour has been observed** — §13 lists what that leaves unproven. (The first
edition pointed at a "§14" that does not exist.) One *compile* fact has now been observed and is
no longer a guess: §8's shared design files do not build for watchOS. See §13.

---

## 1. What is being built

A **full peer Apple Watch app**: a real watch app the user pours from, which reconciles with the
phone. Chosen by the owner over three cheaper readings (a complication-only wrist surface, a
notification action, or HealthKit export).

**Name: One Ledger, One Outbox, One Reconciler.**

The phone's SwiftData store stays the single source of truth. **`WaterLog` is not touched** — no
schema migration, no new fields, no tombstones. The watch holds **no SwiftData store at all**: an
append-only *outbox* of pours it authored, and a *mirror* of what the phone last told it, both in
its own watch-local App Group suite.

The watch authors exactly one verb — **pour** — which is positive, commutative and idempotent
under `WaterLog.id`, a `UUID` that already exists and is already deliberately *not*
`@Attribute(.unique)` (`WaterLog.swift:38-43`).

---

## 2. Why not a replicated ledger

The first design pass produced a peer-CRDT — both devices holding a replica, exchanging
id-stamped events. It is rejected, and the reason is a **class of failure**, not a count of bugs:
every one of its failure modes is an *absorbing state*. It ships mutations and never ships a
value, so no message's arrival repairs a divergence.

- `publishedAt` is one scalar answering a per-peer question. A second paired watch
  (`WCSession.h:148`) silently strands every event published while it was selected. No re-send,
  ever.
- A correction or tombstone that overtakes its target is either dropped (permanent over-count) or
  needs a buffer with a retention policy. **`transferUserInfo` promises ordering nowhere.**
- A phone restored from an older backup cannot be repaired by the watch, because `publishedAt` is
  already stamped. The field that makes it a ledger forecloses recovery.

Its headline break was a chain entirely inside code that existed when this was written. **That
chain has since been cut**, by the role model of §3 — which is worth recording precisely, because
the argument it supported is what the owner accepted this design on.

As first written, and true against the tree of 2026-08-31:

> A five-field `WaterLog` migration is the most likely thing to make `sharedModelContainer`'s
> `try?` (`DataManager.swift:1138`, cited as `:1057` before the shift) fall through to a
> **process-local, empty** store — one `#if DEBUG` line, nothing in Release. `init` then runs
> `seedFromCachedTotalIfNeeded()` (`:425`), whose guards were `!isAppExtension` (**false** on a
> watch `.app`), `cached > 0`, `fetchLogsForToday().isEmpty` (**true** against the empty
> fallback) and `stamped == today`. **All open.** It mints a `WaterLog` for the whole day's total
> (`:701`). Under a ledger that phantom row is a publishable event. The phone folds it.
> **The user's day doubles.**

**What is true now.** That first guard is no longer `!isAppExtension`. It reads
`guard Self.role.mayHaveLegacyStandardDefaults else { return }` (`:691`), and `.watchApp` answers
**false** — so a watch cannot reach the mint at all, whatever it does with its store. The role
model closed this chain on 2026-08-31 at 23:34, before any watch code existed, which is exactly
what §11 step 3 was for.

Two corrections to how this section argued, both of which survive the cut:

- **The guard count.** This section said "four guards". The repository's own vocabulary
  consistently says **three** — the function's DocC (`:687`), rule `25-shared-storage` and rule
  `30-rollover:74` all exclude `cached > 0` as a precondition rather than a guard. Use three.
- **The invariant was too strong.** "No design in which the watch holds no store can reach that
  chain" put the safety in the wrong place. The phantom row is minted by **the phone**, on any
  store-open failure, and the accepted design ships that hazard untouched — §12 defers the
  `VersionedSchema` that would address it. What the no-store-on-the-watch design actually buys is
  narrower and still decisive: **the watch never authors a row it did not observe a human make**,
  so there is no phantom to publish. State it that way rather than as a property of the chain.

The rejection of the replicated ledger stands on the three absorbing-state bullets above, which
are untouched by any of this.

---

## 3. The role model — a compile error, not a runtime check

### 3.1 The census in rule `25-shared-storage` is wrong

The rule says *"Four sites are guarded by `!Self.isAppExtension`"*. There were **six**, and they do
not ask the same question. **All six have since been converted to the role model** — the table below
gives the current line and the current spelling:

| Line | Site | The question it is really asking | Now reads |
|---|---|---|---|
| `:420` | materialise the goal | *is this container my own first-class home?* | `role.ownsSharedStorage` |
| `:760` | fresh-install day stamp | same | `role.ownsSharedStorage` |
| `:691` | `seedFromCachedTotalIfNeeded` | *has my `.standard` ever held WaterBuddy state?* | `role.mayHaveLegacyStandardDefaults` |
| `:1175` | `migrateIfNeeded` | same | `role.mayHaveLegacyStandardDefaults` |
| `:627` | `republishHistory` | *do I have a history surface to draw?* | `role.drawsHistory` |
| **`:847`** | **`requestReminderReschedule`** | ***may I file notifications for this user?*** | `role.mayFileReminders` |

A grep for `!Self.isAppExtension` in the tree now returns **zero** hits. Read the table as history
plus a map, not as a to-do.

`:847` is the site that ships a user-visible bug the moment a watch constructs a `DataManager`:
`Slot.identifier` is a pure function of day and hour (`ReminderPlan.swift:70`), so a watch would
file **byte-identical identifiers into a second notification centre that cannot dedupe against the
phone's** — two buzzes per slot, or 28 silent `add` failures into a `ReconcileOutcome` that
`requestReminderReschedule` discards.

**One claim here was false, and its falsity now costs something.** The first edition said `:847`
"appears in **no rule file**". It appears in three:

- `.claude/rules/40-widget.md:77` — "`DataManager.requestReminderReschedule` keeps its
  `guard !isAppExtension else { return }`"
- `.claude/rules/80-notifications.md:101` — the same sentence, verbatim
- `.claude/rules/43-concurrency.md:75` — names it as the instance of the fire-and-forget-`Task` guard

The first two **mandate a guard spelling the code no longer has.** They are now wrong about the
tree, and rule `99-docs-cascade` puts `.claude/` outside what a doc sync may correct — so this is
an owner edit, and it is live today whether or not a watch is ever built. Added to §9.

### 3.2 The guard

The watch never constructs a `DataManager`. Make that a fact of the type system:

```swift
@available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores. Use WristModel and WristPlan.")
static let shared = DataManager()

@available(watchOS, unavailable, message: "The watch holds no WaterLog store. See rule 25-shared-storage.")
nonisolated static let sharedModelContainer: ModelContainer = { /* unchanged */ }()

@available(watchOS, unavailable, message: "The watch is not a writer of the phone's stores.")
init(…, publishWrist: @escaping () -> Void = DataManager.requestWristPublish)
```

An unavailable declaration may reference other unavailable declarations, so `shared`'s initialiser
and `init`'s default arguments still type-check. **All six guard sites become unreachable by
compilation rather than by discipline** — the codebase's own idiom, the compile-time canary.

A `role` still replaces `isAppExtension` for the questions that survive, written as an exhaustive
`switch` with no `default`, so a new binary fails to compile until somebody answers for it.

> **This half has landed — and it is better than what this section specified. Do not "implement"
> it.** `DataManager.Role` (`:1041`) is **four**-state, not the three proposed here:
> `.phoneApp`, `.phoneExtension`, `.watchApp`, **`.watchExtension`**. This document's
> "phone app / phone widget / watch" has no case for a watch *widget* extension, and a watchOS
> complication is exactly the surface §12 defers rather than forbids. It exposes the four
> questions as `ownsSharedStorage`, `mayHaveLegacyStandardDefaults`, `drawsHistory` and
> `mayFileReminders`, each an exhaustive `switch` with no `default`, resolved once as
> `nonisolated static let role` from `isAppExtension` plus `#if os(watchOS)` — never a second
> runtime probe, which rule `25-shared-storage` forbids. `ProcessRoleTests`
> (`WaterSnapshotTests.swift:519`) covers it with four tests, including
> `aWatchAppAnswersLikeAnExtensionAndNotLikeTheApp` and `everyRoleIsAccountedFor`.
>
> **Anyone executing §11 in order must not regress this to three states.**

**Still outstanding:** the `@available(watchOS, unavailable)` half above. A grep for `@available`
in `DataManager.swift` returns nothing — the guard is currently a *runtime* answer, not the
compile error this section's title promises. That is the part of §3 that remains to be built, and
it is what makes the four sites unreachable by compilation rather than by discipline.

**Cost, stated.** `DataManager.swift` and `WaterLog.swift` still *compile* into the watch target
(it needs `dayOrdinal`, `Calendar.waterBuddyDay`, `Key`, `AppLanguage`, the resolvers, the
constants), so the watch **links SwiftData without ever opening a store**. Extracting the pure
surface into its own file would remove the link; it is a seventh shared file plus a move of `Key`.
Recorded as debt, not v1.

---

## 4. The wire

Everything is JSON-encoded to `Data` under one dictionary key — WC accepts property-list types
only (`WCErrorCodePayloadUnsupportedTypes`, 7010) and a `UUID` is not one. The blob is what lets
both payloads carry a `schemaVersion`, which two independently-updatable binaries need.

### Wrist → phone

```swift
struct WristBatch: Codable, Sendable, Equatable {
    let schemaVersion: Int   // unrecognised version is NOT acked, so the watch keeps retrying
    let batchId: UUID        // groups chunks; also the coalescing key
    let chunkIndex: Int
    let chunkCount: Int
    let pours: [WristPour]   // at most 64
}

struct WristPour: Codable, Sendable, Equatable, Identifiable {
    let id: UUID     // becomes WaterLog.id verbatim — the merge key already exists
    let amount: Int  // Int, like every volume in this product
    let at: Date     // an INSTANT. Deliberately no dayOrdinal — see §5
}
```

### Phone → wrist

```swift
struct WristMirror: Codable, Sendable, Equatable {
    let schemaVersion: Int
    let currentWater: Int
    let dailyGoal: Int
    let servings: [Int]      // all three, so the wrist's row is the phone's row
    let languageCode: String?// nil == follow the device. Absence carries meaning; no sentinel
    let isGoalSet: Bool
    let composedAt: Date     // an instant: freshness and the "last synced" line
    let phoneDayStart: Date  // startOfDay AS AN INSTANT — see §5
    let acked: [UUID]        // at most 256, oldest-applied first
}
```

### Transport, per direction

| Traffic | Primitive | Why |
|---|---|---|
| Pours, wrist→phone | `transferUserInfo`, chunked at 64 | The only primitive durable across sender exit (`WCSession.h:101-105`), needing no reachability, that **does not coalesce**. Coalescing here eats servings. |
| Pours, wrist→phone, *additionally* | `sendMessage` when `isReachable`, errors swallowed | **A deliberate heresy.** `WCSession.h:93`: *"If the counterpart app is not running the counterpart app will be launched upon receiving the message (iOS counterpart app only)."* The only documented way to wake the iOS app. It is **never the carrier of record** — the identical batch is already durably queued and the fold is idempotent under `id`, so both landing produces one serving. Its failure costs nothing. |
| Mirror, phone→wrist | `updateApplicationContext` | `receivedApplicationContext` *"stores the most recently received"* (`:111-112`) — a **property**, readable on the watch's own wake with no callback and no ordering dependency. |

**Forbidden on the wire**, each for its own reason: any `yyyyMMdd` ordinal (§5);
`Key.didMigrateFromStandard` (burn-once, per-container by definition); a total the watch authored
(a design where both sides send totals cannot distinguish *"you already counted this"* from
*"here is more"*); a `WaterLog`, `ModelContext` or `PersistentIdentifier`; any delete or edit in
v1; any reminder plan, slot or identifier; `remindersEnabled`.

### The ack, and the conjunction that closes two fatal holes

The ack is **not** derived from rows and **not** a time window used alone. It is an explicit,
persisted, day-keyed applied ledger, and the apply guard is a **conjunction**:

```swift
for pour in pours where pour.amount > 0 && pour.amount <= Self.maximumDailyIntake {
    guard !applied[day, default: []].contains(pour.id),
          !existing.contains(pour.id) else { continue }
    …
}
```

- **Without `applied`:** an ordinary swipe-to-delete (`HistoryView.swift:163` → `deleteLog(_:)`)
  un-acks a pour still in the outbox; the watch re-sends; the fetch finds nothing and re-inserts.
  **The user's deletion undoes itself, repeatably.**
- **Without `existing`:** past the ledger's horizon a re-send inserts a **second `WaterLog` with
  the same `UUID`**, which SwiftData accepts because `WaterLog.swift:40-42` deliberately declines
  `@Attribute(.unique)`. **The serving is counted twice, permanently, in history.**

Both rival designs had exactly one of these. The conjunction closes both.

---

## 5. The day, across two devices in two time zones

**The watch never rolls anything over. It filters** — and it filters on a comparison between two
*instants*, never two stored ordinals.

`WristPlan` is `ReminderPlan`'s twin: `import Foundation` alone, pure, no `Date()` inside, the
clock and calendar injected. It buckets today's outbox pours from each pour's own instant, using
the **watch's** `Calendar.waterBuddyDay`.

There is deliberately no stored `dayOrdinal` on a `WristPour`: a stamp made in Tokyo and re-read
in Los Angeles names a day the watch is no longer in, and the pour vanishes from a display that
should show it. This is `DaySummary.series`' move (`DataManager.swift:1417`) and
`WaterLog.timestamp`'s argument, one device further out.

When the phone's `phoneDayStart` and the watch's own day disagree, the base is **withheld and
attributed** — never rendered as a confident zero. Both rival designs zeroed it, which shows
**0 ml on the wrist while the phone reads 1,800**, and their stated mitigation ("it re-syncs on the
next mirror") is wrong: every subsequent mirror carries the same stale ordinal until the *phone's*
zone flips.

---

## 6. Concurrency — no trap

`WCSession.h:135-140`: *"All delegate methods will be called on the same queue. The delegate queue
is a **non-main serial queue**."*

This kills the codebase's only sanctioned hop twice over. Rule `43-concurrency` sanctions
`queue: .main` + `MainActor.assumeIsolated`; here that would **trap** (`HomeView.swift:62-63`
already records `assumeIsolated` as *"a `precondition` in all but name"* in a codebase with zero),
and a probe showed it is a hard `error: sending 'self' risks causing data races` at Swift 6 anyway.

**A `@MainActor` type cannot conform to `WCSessionDelegate`.** It produces `#ConformanceIsolation`
— a **warning at this project's `SWIFT_VERSION = 5.0`**, an error at Swift 6 — and rule
`43-concurrency` makes a new warning a gate failure *today*. So `DataManager` is disqualified as
the delegate by the SDK itself, not by preference.

`WristLink` is therefore a separate, non-`@MainActor`, `final class` whose `Sendable` is **earned**
— every stored property an immutable reference to a global-actor-isolated class. The first `var`
added breaks it, and at Swift 5 it breaks as a *warning*. That is why the chunk buffer lives on
`WristInbox` (a `@MainActor` class) instead.

`WCSession.delegate` is **`weak`** (`WCSession.h:43`) and no rival design named a retainer: ARC
frees it, every transfer fails with `SessionMissingDelegate` (7003) through a `Void`-returning
doorbell, and there is no diagnostic in Debug or Release. `WristLink.live` is a `static let`, with
the DocC that says why.

---

## 7. Where the seam lives, and the one honest weakening

The brief posed rules `20-state`, `10-architecture` and `40-widget` as unable to all hold. **Two
survive untouched.**

- **`20-state` holds.** The SDK forces a separate delegate type anyway, and it never writes a key:
  it decodes, hops, and calls `ingest`, whose last mile is `saveAndRecompute()` →
  `recomputeToday()` → the `currentWater` setter. A watch pour and a widget tap take the identical
  final path.
- **`40-widget` holds textually.** `project.pbxproj:96` scopes the exception set to
  `target = WaterBuddyWidgetExtension`. The `target` field is **scalar**, so one set can never
  serve two targets. A watch target's own exception set is a *different contract*, not a widening
  of the widget's six — and the watch's files are invisible to the widget.
- **`10-architecture` holds** because `WaterBuddyWidget/`'s own sources gain no import.

`WristLink` lives **in `DataManager.swift`**, beside `WaterSnapshot`, `AppLanguage` and
`DaySummary` — the established answer to "two processes need this and a seventh file changes a
contract" — behind `#if canImport(WatchConnectivity)`, mirroring the existing
`#if canImport(WidgetKit)` at `:13-15`.

**Cost, stated:** the widget extension links `WatchConnectivity`, a framework it never calls,
guarded at one entry point exactly as it already links `UserNotifications` and never files a
reminder outside `AddWaterIntent`. `DataManager.swift` grows by roughly 150 lines.

**The one honest weakening.** Rule `20-state`'s *"`DataManager` is the only writer"* becomes
**one writer per store**: `DataManager` for the phone's pair, `WristModel` for the watch's suite.
That is a genuinely weaker sentence and this document does not pretend otherwise.

---

## 8. The watch UI — one screen

```
┌─────────────────────┐
│      ●  62%         │  WaterSurface + WaterReadabilityScrim + readout.
│    (vessel)         │  ONE VoiceOver element: children: .ignore + label +
│  1,240 / 2,000 ml   │  .accessibilityValue carrying percent AND millilitres.
├─────────────────────┤
│  Cup        150 ml  │  Three rows from mirror.servings — the same three vessels
│  Glass      250 ml  │  HomeView offers, so the third front door logs what the
│  Bottle     500 ml  │  other two log. HomeView.vesselSlots is already nonisolated.
├─────────────────────┤
│  Synced 4m ago      │  Attribution, always present, never an alert.
└─────────────────────┘
```

Each pour row is `.frame(minHeight: 44)` + `.contentShape(Rectangle())`, never a fixed `height` —
**a 41mm screen does not get an exemption from rule `65-accessibility`'s 44pt floor.** A vertical
`List` is both the native watch idiom and what keeps three 44pt targets from needing
`ViewThatFits`.

**Deliberately absent:** settings, a goal editor, history, and reminders. Each would author state
the watch cannot own. When `isGoalSet` is false the watch shows one line: *Open WaterBuddy on your
iPhone.*

---

## 9. Rule amendments

**`70-privacy` — approved by the owner, and load-bearing.** Insert after "Nothing leaves the
device":

> ## WatchConnectivity is a ruling, not an omission
>
> The banned list names `URLSession`, `Network`, `CloudKit`, `HealthKit`. It does not name
> `WatchConnectivity`, and that absence is not permission — this rule's bar is *"Adding any other
> capability requires a written justification in this file first."* Here is the justification.
>
> `WatchConnectivity` links two devices the same person owns and has personally paired. There is
> no account, no server, no third party, and **no entitlement** — it is the only inter-device
> transport in the Apple SDK that needs none. Nothing is transmitted that the user did not author
> on one of the two devices. On that basis it is inside the principle "nothing leaves the device",
> read as "nothing reaches anyone else", and it is permitted.
>
> Three limits are conditions of the permission:
> - **The system's transfer queue is outside the App Group.** A payload handed to
>   `transferUserInfo` lives in a system daemon until the counterpart runs and **survives app
>   termination**. `deleteLog(_:)` removes the row and does not cancel the transfer. The apply
>   ledger is what makes a re-sent copy of a deleted serving a no-op rather than a resurrection —
>   a privacy mechanism as much as a correctness one.
> - **No wire field may reach a notification, a Live Activity, or any surface outside the two
>   apps' own screens.**
> - **No third framework rides in behind it.** `HealthKit`, `CoreLocation` and `CloudKit` remain
>   banned by name, and a watch app is exactly where someone will propose all three.

Also required: `40-widget` (the second-exception-set clarification, drafted in full),
`25-shared-storage` (the largest edit — the six-site census and the third process state),
`30-rollover`, `43-concurrency`, `80-notifications`, `20-state` (the per-store qualification).

### 9.1 Missing from the list above

**`85-testing` — the largest omission.** §10 replaces this rule's operative content outright: its
fenced block is three `xcodebuild` invocations, every one pinned to
`platform=iOS Simulator,OS=18.6,name=iPhone 16`, and its "`OS=18.6` is load-bearing" bullet and
its "the test half is two invocations, not one" are both written for one platform. §10 makes the
gate five invocations across two platforms and supplies **no watchOS destination string**, in the
one class of failure this repo has already paid for (known issue #9). It also gives no watch-fixture
rules — no throwaway-suite, in-memory-container or injected-clock guidance for a watch suite.

**`15-project`.** §11 step 5 *is* a `15-project` change and nothing else, yet the rule is not on
the list. It asserts four targets, two signed, two schemes, four synchronized root groups and one
six-file exception set. After step 5 every one of those numbers is wrong.

**`10-architecture`.** §7 claims this rule "holds", but its Forbidden list carries the same
one-writer sentence §7 concedes is weakened in `20-state` — so the weakening lands in **two** rule
files, not one, and "the one honest weakening" is arithmetically wrong.

**The glob problem — the one that makes all of the above worse.** Every rule file is scoped by a
`globs:` frontmatter key to the four folders that exist today. Counting them: a new
`WaterBuddyWatch/` folder auto-loads **3 of 18** rules — `00-workspace`, `90-git` and
`95-dependencies`, the only three globbed `**/*`. `65-accessibility`, whose 44pt floor §8 leans on
explicitly, is **not** among them; nor is `43-concurrency`, `20-state`, `70-privacy` or
`60-design-system`. A watch test folder is no better: `85-testing` globs `WaterBuddyTests/**`,
which does not match `WaterBuddyWatchTests/`.

**So the newest and least-reviewed code in the product would be written with 15 of 18 rules
silently not loaded.** Every amendment above is worth less than the one-line glob edit that makes
the rules reach the watch at all. Do that first.

### 9.2 A live divergence, independent of the watch

Two rule files state that `requestReminderReschedule` "keeps its
`guard !isAppExtension else { return }`" — `40-widget.md:77` and `80-notifications.md:101`. The
code reads `guard role.mayFileReminders else { return }` and the tree contains zero
`!isAppExtension` guards. This is wrong **today**, with or without a watch, and `99-docs-cascade`
makes it an owner edit rather than something `/doc_sync` may fix.

### 9.3 Two claims in §9 that need the owner's word

- The `70-privacy` amendment is introduced as **"approved by the owner"**. Nothing in `HISTORY.md`
  or `tasks/lessons.md` records that approval, in a repo whose convention is to record exactly
  this. Not a claim that it is false — a claim that the tree cannot corroborate it, and it is the
  permission on which an inter-device transport enters a product whose stated property is
  "Nothing leaves the device".
- §11 step 10 bundles seven rule rewrites into the `/doc_sync` step, which `99-docs-cascade`
  forbids in its first bullet. `/doc_sync` cannot reach `.claude/`; §9 is the only mechanism, and
  it needs the owner.

---

## 10. Testing

**~~A live defect first.~~ Already closed — before this document was written.**

`theTripwireHelperEnumeratesEveryStoredKey` (`WaterSnapshotTests.swift:230`) does assert
`Set(waterBuddyKeys(in: defaults).keys) == Set(DataManager.Key.all)` where the helper's key set
**is** `Key.all`, so that assertion is a tautology and cannot fail for any content of the roster.
That description is accurate. The conclusion drawn from it was not.

The test this section demands — "one that drives the real writers and reads the suite back rather
than the roster" — **already exists**: `DataManagerTests.everyKeyTheProductWritesIsOnTheRoster`
(`DataManagerTests.swift:125`). It drives `saveDailyGoal`, `servings`, `language`,
`remindersEnabled`, `addLog`, `resetIfNeeded` and `migrateIfNeeded`, reads
`defaults.dictionaryRepresentation()` back, subtracts `Key.all`, and carries its own anti-vacuity
guard (`#expect(live.count >= 7)`). Its red-then-green is recorded: it was watched failing with
`servings` removed from `Key.all`, while the tautological one passed.

The tautology is **kept deliberately**, and its own DocC (`:217-228`) says so in this document's own
words — it pins that the helper is exactly the roster and no wider, so nobody reinstates the
hand-written list it replaced. It needs no work.

**What actually remains** is small and belongs where the keys land, not before them: when §11's
watch work adds its three keys, add their writers to `everyKeyTheProductWritesIsOnTheRoster` and
raise its `live.count >= 7` floor. That is part of step 4, not a blocking prerequisite.

*(Related, and worth fixing in the same pass: `docs/AI_CONTEXT.md` known issue #10 still says
`theTripwireHelperEnumeratesEveryStoredKey` "fails the moment the two disagree" — the claim this
section correctly attacked, and which the test's own DocC now contradicts.)*

The gate becomes **five invocations**: iOS unit, iOS UI, watchOS unit (no simulator pair needed),
phone widget build, and a watch app + watch widget build **against the device SDK** — which is what
catches watchOS-only, simulator-hidden breaks.

**Three conditions on that, learned the expensive way.**

- **Write the two new destinations down, pinned.** This document specified two new invocations
  with no `-destination` at all, in the one class of failure this repo has already documented
  (known issue #9: the `name=iPhone 16` spelling stopped resolving and only the device `id=` works
  — and rule `85-testing` separately forbids pinning by `id=`, because an id resolves on nobody
  else's machine). **Two watchOS runtimes are installed here — 11.5 and 26.5** — so `OS=latest` is
  as ambiguous as it is on the iOS side. Pin by number, against whatever `WATCHOS_DEPLOYMENT_TARGET`
  step 5 sets.
- **The fifth invocation is the first device-signed build in the gate**, for two bundle ids that
  do not exist yet. Its failure mode — a provisioning error — is indistinguishable at the console
  from the corrupted `project.pbxproj` that step 5 risks. Run it once on its own, before trusting
  it as a gate.
- **`85-testing` must be amended before this is the gate** (§9.1), and its `globs:` widened, or
  the rule does not load for the folder it governs.

Also: this document tells step 5 to verify with "a full five-invocation gate", but the fifth
invocation names a watch widget that step 9 has not created. At step 5 the gate is four.

---

## 11. Sequence

0. ~~`git init`~~ — **the owner has declined this twice.** The design names it as Step 0 because
   step 5 hand-rewrites `project.pbxproj` with no undo and a corrupted project file loses every
   target's configuration at once. Mitigation in force instead: scratchpad snapshots before each
   destructive edit, and the smallest verifiable increments.
1. ~~**Fix the tautological tripwire**~~ — **DONE, and done before this document existed.**
   `everyKeyTheProductWritesIsOnTheRoster` is the test this step asked for (§10). There is no RED
   left to reach, so the red-then-green cycle rule `85-testing` requires cannot be performed here.
   The residual work moved into step 4. **Do not "fix" the tautology it points at** — it is kept
   deliberately and its DocC explains why.
2. **Settle `LiquidGlass.Base.material.opaqueFill`.** **This is not an aesthetic step — it is a
   hard watchOS compile blocker**, and this document did not say so. Detail in §13; the short
   version is that `opaqueFill`'s `.material` case returns `Color(.secondarySystemBackground)`
   (`LiquidGlassModifier.swift:114`), which is unavailable on watchOS, and it is the **only**
   distinct compile error stopping `WaterSurface.swift` + `LiquidGlassModifier.swift` from joining
   a watch target.

   **Owner decision, taken 2026-09-01: match the widget's composited fill** —
   `Color(red: 0.22, green: 0.19, blue: 0.36)`, the value `Base.archived` already ships, derived as
   the glass stack composited down over the aurora. It makes the app and the widget agree under
   Reduce Transparency, satisfies rule `65-accessibility`'s *"never a neutral system grey"*, and
   removes the blocker without a `#if os(watchOS)` in a shared file.

   Still ships separately — *it changes the shipping app's Reduce Transparency appearance* and
   belongs in no commit with a watch in it. Sample the composite off a render and put the figure in
   `docs/DESIGN.md` as this step always said; note the repo has recorded that sampling method as
   currently unavailable, so if it cannot be done, say so rather than inventing a figure.
3. ~~**The role model**~~ — **DONE 2026-08-31 23:34**, all six sites, `ProcessRoleTests` green.
   **Landed as four states, not the three §3.2 specified.** Executing this step as written would
   delete `.watchExtension` and regress the tree. The part of §3 that remains is the
   `@available(watchOS, unavailable)` compile guard — currently zero `@available` in
   `DataManager.swift` — which is genuine work and is now **step 3′** below.

   3′. **The compile guard** (§3.2) — mark `shared`, `sharedModelContainer` and `init` unavailable
   on watchOS, turning six runtime answers into compile errors. Unproven: whether an unavailable
   declaration may be referenced from a **default argument expression**, which is what
   `init`'s `= DataManager.requestWristPublish` needs. Probe it before relying on it.
4. **`WristPlan`, `WristBatch`, `WristMirror`, `ingest`, the applied ledger** — all in the app
   target, all testable by the existing gate, no new build target yet. Largest body of work,
   cheapest place to be wrong. **The one step this reconciliation found no defect in**, and with
   steps 1 and 3 struck it is the next thing to build. Its three new keys carry step 1's residue:
   add their writers to `everyKeyTheProductWritesIsOnTheRoster` and raise its floor (§10).

   Settle these before writing `ingest`, because §4 does not: the **display formula** the watch
   uses (mirror total plus un-acked local pours is the obvious reading, and it double-counts in
   the window where the phone has folded a pour but not yet acked it); the **scope of `existing`**
   (today's rows, or all rows — the conjunction's duplicate-insert protection is only as wide as
   this); whether `ingest` takes the `refresh()` head that rules `20-state` and `30-rollover`
   require of every mutator that computes from current state; and what happens to a **chunk that
   never arrives**.
5. **The paired-simulator experiment** — *moved ahead of the project edit.* It was sequenced after
   it, while this document also says its result "changes what the product may promise". Running the
   one genuinely irreversible act in the plan before the cheapest test of whether the product is
   viable at all is the wrong order. It needs no watch target: probe `WCSession` reachability and
   the `sendMessage` wake from a scratch project.
6. **`project.pbxproj`** — the watch target, its exception set, the embed phase, entitlements, the
   watchOS test target. **The riskiest step**, and the only unrecoverable one. Do it in the Xcode
   GUI wherever possible and verify with `xcodebuild -list` before a line of watch UI. At this
   point the gate is **four** invocations, not five — the watch widget does not exist yet.

   **Enumerate the exception set before opening the file.** This document never does. It is not
   the widget's six: the watch needs `DataManager.swift`, `WaterLog.swift`, `WaterSurface.swift`,
   `LiquidGlassModifier.swift` (blocked until step 2), `ReminderPlan.swift` — and §8's UI reads
   `HomeView.vesselSlots`, which is on an **app-only view file** whose own dependencies
   (`AuroraBackground`, `PressStyle`, `Haptics`, `Celebration`) would follow it in. Either move the
   vessel names and glyphs somewhere shareable or drop them from the watch; do not add `HomeView`
   to a watch target.

   **On the no-git mitigation.** "Scratchpad snapshots" names no files and the scratchpad is a
   session-scoped `/private/tmp` path that does not outlive the thing it protects. Copy
   `project.pbxproj`, both files under `Entitlements/`, and `WaterBuddyWidget-Info.plist` somewhere
   durable and outside `/private/tmp` first. Note also that `xcuserdata` schemes are not in the
   snapshot: a restored `project.pbxproj` can still leave `-scheme WaterBuddy` unresolvable.
7. `WristLink`, `WristInbox`, `LinkTransport`, wired from `WaterBuddyApp.init()` beside
   `prepareSharedStorage()`.
8. The watch app's one screen and the watchOS test suites.
9. The watch widget and `.backgroundTask(.watchConnectivity)` — together, never apart.
10. `/doc_sync`, `HISTORY.md`, and the §9 amendments **last**, because the code wins.

---

## 12. Not in v1

A watch-side delete or edit (the moment the watch authors a negative, the G-Set becomes a CRDT and
every absorbing state returns); watch settings, goal editor or history; reminders from the watch in
any form; `transferCurrentComplicationUserInfo`; an interactive complication (a second `AppIntent`
is a duplicate Shortcuts registration); a watch-only independent mode; a `VersionedSchema` for
`WaterLog` (overdue, and the `try?` at `:1138` is the most dangerous single line in the tree — but
its own change); extracting `DataManager`'s pure surface to stop the watch linking SwiftData.

---

## 13. What is unproven

**One thing here is no longer unproven, and it is a blocker.**

> **§8's watch UI does not compile for watchOS as the shared files stand.** Observed
> 2026-09-01, not inferred:
>
> **All six shared files, compiled together, in the SIL-running mode §13 itself demands:**
>
> ```
> $ xcrun -sdk watchos swiftc -c -wmo -module-name WaterBuddy \
>       DataManager.swift WaterLog.swift ReminderPlan.swift \
>       NotificationManager.swift WaterSurface.swift LiquidGlassModifier.swift \
>       -target arm64_32-apple-watchos11.0 -swift-version 5
> LiquidGlassModifier.swift:114:36: error: 'secondarySystemBackground' is unavailable in watchOS
>
> → 1 distinct error, 0 warnings
> ```
>
> **`DataManager.swift` — SwiftData, `@Observable`, the whole model — compiles clean for watchOS,
> as do `WaterLog`, `ReminderPlan`, `NotificationManager` and `WaterSurface`.** §3's "Cost,
> stated" is therefore confirmed rather than merely argued: the watch links SwiftData without
> opening a store, and it builds. **Zero warnings** matters independently — rule `43-concurrency`
> makes a new warning a gate failure, and this is the `-c` mode that surfaces region-isolation
> diagnostics `-typecheck` hides.
>
> Exactly **one** distinct error, and it is not in any of the files this design adds. It is
> `LiquidGlass.Base.opaqueFill`'s `.material` case — precisely what §11 step 2 calls an owner
> decision, though this document presented step 2 as an aesthetic call about Reduce Transparency
> and never connected it to the watch building at all. `WaterSurface.swift:177` calls
> `.liquidGlass(in: Circle(), …)`, so the two files cannot be separated: taking `WaterSurface` to
> the watch takes `LiquidGlassModifier` with it.
>
> `Material` itself was checked and is **fine** on watchOS (available since watchOS 10), so the
> `case material(Material)` declaration is not the problem; only the `opaqueFill` body is.
>
> **How close to sufficient this is.** A Swift compile does not stop at the first error, so "one
> error across all six files" means the compiler found nothing else wrong in them — materially
> stronger than a first-failure report. It is still not a green build: the probe patching a scratch
> copy to confirm the fix compiles was **declined**, and these are the six shared files only, not a
> watch target (no `@main`, no `WKApplication`, no Info.plist, no entitlement, and none of the
> watch-side types §4 adds). Treat "one error, zero warnings" as measured and "one-line fix" as
> strongly indicated but unbuilt.

**Every other runtime claim here is the header's, not an observation.**

- `transferUserInfo`'s own method comment is a **copy-paste defect** — *"if the **file** has
  successfully arrived"* inside a dictionary-transfer method — so even the durability guarantee
  comes from the section banner at `WCSession.h:101-105`, one level removed.
- **The `sendMessage` wake has never been observed working.** If it does not, the reminder
  regression ships as a disclosed limitation: a user who meets their goal entirely on the wrist
  gets further reminders that day, because `ReminderPlan.slots` silences on the *phone's*
  `currentWater`.
- `.backgroundTask(.watchConnectivity)` has never been observed firing for an app the user has not
  launched.
- The `#Predicate` over `Array.contains` on a `UUID` has never been compiled.
- `WristLink`'s earned `Sendable` was proven to **compile**, not proven correct.
- 90 days and 256 acks are construction bounds with stated consequences, not measured quantities.
  `WCErrorCodePayloadTooLarge` has **no numeric threshold anywhere in the SDK**, which is why the
  batch is capped by construction rather than by catching 7009.

**A methodological note worth keeping:** `swiftc -typecheck` does **not** run the SIL
`TransferNonSendable` pass, so region-isolation diagnostics are invisible to it. A probe pass
reported eight results "clean at Swift 6" that were errors; known-bad controls caught it. **Any
future concurrency probing in this repo must use `swiftc -c`.**

---

## 14. Owner approval and reconciliation, 2026-09-01 (second pass)

**The owner approved this design in full**, in the same conversation that migrated the product from
a broken sibling checkout (`WaterBuddy1`, since deleted) into this tree. Two explicit rulings:

- **§9's `70-privacy` amendment is approved as written.** This closes the open item §9.3 raised —
  the amendment text in §9 is live policy as of this approval, not a draft.
- **§12's "Not in v1" list is approved as scoped** — no watch-side delete/edit, no settings/goal
  editor/history/reminders on the watch. Re-confirmed explicitly rather than inferred from silence.

**One fact this document did not know about itself: a placeholder `WaterBuddyWatch` target already
exists**, added earlier in the same session, before this spec was read. It is **not** step 6 —
it was built to answer a narrower request ("the project structure should have a watch target") with
no knowledge of this design. Concretely, it is wrong in exactly the ways step 6 warns about:

- Its `fileSystemSynchronizedGroups` carries no exception set at all — none of `DataManager.swift`,
  `WaterLog.swift`, `WaterSurface.swift`, `LiquidGlassModifier.swift` or `ReminderPlan.swift` reach
  it. Step 6's five-file set (not the widget's six — no `NotificationManager.swift`, since
  `mayFileReminders` is false on `.watchApp` and shipping the notification surface to a process that
  can never use it is pointless) still needs to be added.
- It carries no entitlement and is not in `Entitlements/`. `WatchConnectivity` itself needs no
  entitlement (§9), but the App Group identifier this design's `WristModel` suite will use does.
- `PRODUCT_BUNDLE_IDENTIFIER` is `sardor.WaterBuddy.watchkitapp` — the classic-era suffix. Nothing
  in this design depends on that spelling; keep it unless step 6's execution finds a reason to
  change it.
- Its one file, `ContentView.swift`, is a one-line placeholder (`Text("WaterBuddy")`) with no Aurora,
  no vessel, no glass. §8's screen replaces it outright — nothing there survives.

**This does not change the sequence in §11.** Step 6 remains "the riskiest step, and the only
unrecoverable one" — it now means *rework* the placeholder rather than create from nothing, which is
if anything narrower than the step as written, since the target, its product reference and its
build-configuration list already exist and only need the exception set, the entitlement, and the
`WATCHOS_DEPLOYMENT_TARGET`/capability wiring added.

**Next step:** an implementation plan for steps 2, 3′, 4, 5, 6 (as reconciled above), 7, 8, 9 and 10,
via the `writing-plans` skill.

---

## 15. The paired-simulator probe, 2026-09-01

Observed on iPhone 17 / Apple Watch Series 11 (46mm) simulators (iOS 26.5 / watchOS 26.5 runtimes),
Xcode 26.6 (17F113). Paired via `xcrun simctl pair <watch-udid> <phone-udid>` — the corrected,
CLI-only Step 2 worked exactly as predicted; no GUI automation was needed or available.

**Method note:** this sandbox has no GUI automation to tap the probe app's on-screen "Send ping"
button, so both probe apps called the identical `sendPing()` / `transferUserInfo()` code the button
would call, on an 8–10s timer, instead of a literal tap. Functionally identical for what's being
measured (whether `sendMessage`/`transferUserInfo` wake and deliver); noted here since it is a
deviation from a literal reading of Step 3.

- **Reachability while both apps foregrounded: true** on both sides at first launch — screenshot-
  confirmed within ~5s of both processes starting. This did **not** stay reliable: later in the
  session, after the watch app was sent to the background and back, the two sides' `isReachable`
  went **out of sync** — the watch kept reporting the phone reachable (`true`) while the phone
  reported the watch unreachable (`false`), continuously, for 4+ minutes, surviving three fresh
  relaunches of the phone app (`activationDidComplete` returned `reachable=false` immediately each
  time). It never self-corrected inside this session's observation window. Take-away for later
  tasks: `isReachable` cannot be assumed symmetric or self-healing on this simulator setup.

- **`sendMessage` after force-quitting the phone app: did not deliver — but does appear to trigger a
  relaunch.** `sendMessage` **never once succeeded** anywhere in this session (48 attempts total,
  spanning both-foregrounded, phone-backgrounded, and phone-force-quit-then-relaunched states).
  Every attempt's `errorHandler` fired — predominantly `WCErrorDomain` code **7014** ("Payload could
  not be delivered"), with some **7012** (reply timed out) — even while `isReachable` read `true` on
  the sender. `didReceiveMessage`/`didReceiveUserInfo` were never invoked on either side, in the
  entire session (checked against the full unified log). That said: immediately after
  `xcrun simctl terminate` on the phone app (confirmed gone from `launchctl list`), the next
  watch-side `sendMessage` attempt (07:12:18.942) was followed **~0.76s later** (07:12:19.703) by a
  **new phone process spawning with no external launch command issued** —
  `SessionManager init` → `activationDidComplete reachable=true`. That timing is the strongest
  evidence this session gathered that `sendMessage` **does** trigger an OS-level background launch
  of a force-quit companion app here — but the specific message that triggered it still failed with
  the same 7014 error, and since `sendMessage` never succeeded even between two already-foregrounded
  apps, this session **cannot** cleanly separate "the wake mechanism is broken" from "message
  delivery is broken independent of wake, on this Xcode 26.6 simulator pairing." Both look true;
  only the second is certain.

- **`.backgroundTask(.watchConnectivity)`: does not exist on iOS at all, and never observed firing on
  watchOS.** Confirmed directly from the SDK: the iOS 26.5 SwiftUI `.swiftinterface` declares
  `BackgroundTask.watchConnectivity` as `@available(watchOS 9.0, *)` / `@available(iOS,
  unavailable, ...)`, and a real build of the iOS target failed with `error: 'watchConnectivity' is
  unavailable in iOS` until the modifier was removed from the iOS scene. It compiled fine on the
  watchOS target. With the watch app backgrounded for ~2 continuous minutes while the phone queued
  10 unconditional `transferUserInfo` calls toward it (chosen because, unlike `sendMessage`,
  `transferUserInfo` is queued and not gated on `isReachable` — the more direct probe of the path
  `.backgroundTask(.watchConnectivity)` exists for), the watch's background-task closure **never
  fired**: no log line, and the watch's `UserDefaults` domain for the probe app never even came into
  existence. Since `transferUserInfo` was itself never observed being delivered anywhere in this
  session (consistent with the same broken-delivery symptom seen in `sendMessage`), this session
  cannot separate "the background task doesn't fire" from "nothing ever arrived for it to fire on" —
  but the fact that matters for later tasks is the same either way: zero observed firings, and the
  API is unavailable on iOS by construction, not by convention.

**Decision:** the design's reliance on `sendMessage` as a wake/delivery mechanism is downgraded to
"best effort, unverified on simulator" — not contradicted (a device test is outside this spike's
scope), but not confirmed either: 0/48 successful deliveries, and only correlational evidence for
the wake side-effect. `updateApplicationContext` (delivers the most-recently-set state, readable
whenever the counterpart next wakes on its own, independent of reachability or a live send) remains
the real delivery path, exactly as spec §13 already anticipated as the fallback. Task 17's
`.backgroundTask(.watchConnectivity)` handler must be implemented on the **watch** target only — it
cannot exist on iOS, confirmed by the SDK and a real compiler error, not merely by this design's
intent — and no user-visible behavior should depend on it firing, since this environment never
observed it firing even once. This is not a blocker: proceed with Task 9 onward as designed, per the
brief's own guidance that an unresolved-on-simulator result is not a "device only" conclusion.

---

## 16. Amendment (2026-09-01): the watch is usable before its first sync

**Owner-approved**, reversing one line of §12's *Not in v1* list: *"a watch-only independent mode."*
That exclusion still holds for everything it was written to exclude — a watch-authored goal, watch
settings, watch history, watch delete/edit, a watch-local SwiftData store. What it should not have
excluded, and what this amendment permits, is the watch **drawing its own screen before a mirror has
ever arrived**.

### Why the original wording was wrong in practice

§8 specified one sentence — *"Open WaterBuddy on your iPhone"* — for the case `isGoalSet == false`.
The implementation gated on `mirror != nil && mirror.isGoalSet`, so two unrelated states fell
through to it, and only one of them was fixable by doing what the sentence said. Worse, it produced
a **first-mirror deadlock**: the only watch-side action that causes the phone to publish is a pour,
and the pour rows sat behind the gate that a mirror was needed to open. A watch that had never
synced could not do the one thing that would make it sync.

It also stranded work this design had already paid for: `WristView.resolveServings(from: nil)` and
`syncedCaption(composedAt: nil, …)` were both written, documented and unit-tested *for the pre-sync
case*, and the gate made them unreachable in production while their tests stayed green.

### What changes

- `WristView` is no longer gated. The vessel and the three pour rows are always drawn.
- The goal drawn against is `WristModel.displayGoal` — the mirror's `dailyGoal` when one has
  arrived, `DataManager.defaultDailyGoal` before that. The fallback is not a guess: it is the same
  figure the phone materialises into its own suite for a fresh install, so the two devices already
  agree on it before they have ever spoken.
- The attribution line moves **outside** every branch, as §8 always said it should be
  (*"always present, never an alert"*), and now distinguishes three states rather than collapsing
  them: `"Not yet synced · default goal"`, `"Set your goal in WaterBuddy on iPhone"` (the one case
  where reaching for the phone genuinely is the fix), and the ordinary `"Synced Nm ago"`.
- `WaterBuddyWatchWidget` takes the same fallback and the same outbox arithmetic, so the
  complication cannot read 0% while the app beside it shows real water. This adds `WristPlan.swift`
  to that target's exception set, which §7's target-membership table must now show as **six** files.

### What this deliberately does not change

Pours remain the only thing the watch authors, they remain UUID-keyed, and they remain reconciled by
the phone's applied-ledger conjunction guard — so **pours cannot diverge**. The only value that can
differ between the two devices is the *displayed percentage*, for as long as the watch is drawing
against the default goal and the phone's real goal is something else; it converges on the first
mirror, and the attribution line says so while it lasts. This is §5's *"withheld and attributed,
never a confident zero"* extended from the stale-day case to the never-synced case, which is the
same argument, one state further out.

§12's remaining exclusions are unaffected and were re-confirmed, not relaxed.

---

## 17. Amendment (2026-10-05): the mirror carries the end of the phone's day

**Owner-approved** on 2026-10-05, closing `docs/AI_CONTEXT.md`'s known issue #26. It **refines §5
rather than reversing it**: the watch still rolls nothing over, still filters on instants rather
than stored ordinals, and still never shows a false zero. What changes is the instant it compares
against.

### What was wrong

§5 asked for the base to be "withheld and attributed — never rendered as a confident zero" when
`phoneDayStart` and the watch's own day disagree. The implementation plan read that as *still show
the number, and soften it*. The number half shipped — `WristModel.todaysTotal` counts
`mirror.currentWater` unconditionally, pinned by `WristModelTests`'
`isMirrorStaleWhenThePhonesDayDisagreesWithTheWatchsOwnDay` (*"never a confident zero — the number
is still shown"*) — and the softening never did: `isMirrorStale` has no reader.
`WaterBuddyWatchWidget` added the same base on a flat 15-minute refresh, with no entry at any day
boundary.

The consequence was daily, not exotic. The phone publishes on a mutation, a foreground or a
`WCSession` activation, and at midnight it is usually suspended. So every morning — until the phone
app was opened, the phone widget tapped, or a watch pour reached the phone — the watch's screen and
its complication both drew **yesterday's** total as today's, at whatever percentage the evening
ended on, beside a phone that read zero.

The watch's own calendar cannot fix this alone, because it answers the wrong question. *"Is the
phone's day the watch's day?"* is exactly what goes wrong under the time-zone skew §5 was written
for: with the watch five hours behind the phone, a mirror composed a minute ago still compares as a
different day for nineteen hours of every twenty-four. Zeroing on that comparison is the *"0 ml on
the wrist while the phone reads 1,800"* §5 rejected.

### What changes

- `WristMirror` gains **`phoneDayEnd: Date?`** — the instant the phone's day ends, composed with
  `DataManager.nextDayBoundary(after:calendar:)` on the phone's own calendar: an instant, not an
  ordinal, for §5's reason.
- The watch counts `mirror.currentWater` only while **`now < phoneDayEnd`**. The question becomes
  *"has the phone's own day ended?"*, which has one answer on both devices whatever their zones. In
  one time zone the base drops at midnight. Under skew it is never dropped while the phone's day is
  still running, so the watch cannot read zero while the phone reads its real total. The watch's
  own outbox pours are untouched — still bucketed by the watch's day, as §5 says.
- The decision lives in `WristPlan` — `todaysTotal(mirror:outbox:now:calendar:)` and
  `dayBoundaries(after:mirror:calendar:)` — pure, as §5 requires, and **both** watch surfaces read
  it, so the screen and the complication cannot disagree.
- The complication emits a timeline entry at every instant the total can change with no new input:
  the phone's day end and the watch's own midnight, one entry when they coincide. That is the
  watch's twin of the phone widget's midnight entry (rule `40-widget`). The 15-minute refresh stays —
  it is how the complication picks up pours made in the watch app.
- `composeWristMirror` reads the total through the same rollover `DataManager.snapshot(...)`
  applies, so a mirror never carries yesterday's cached total under today's `phoneDayStart`. Every
  path traced to it was transient — a correct publish always followed — but the mirror's window is
  now load-bearing, so its total has to belong to that window by construction.
- `phoneDayEnd` is **optional** so a mirror persisted before this change, or sent by a phone build
  that predates it, still decodes. A missing value falls back to the watch's own boundary after
  `phoneDayStart` — exact whenever both devices share a zone. The change is additive, so
  `schemaVersion` stays 1: an older watch ignores the unknown key.

### What this deliberately does not change

- The watch still stores no day and rolls nothing over; it filters on every read (rule
  `30-rollover`).
- `isMirrorStale` keeps its meaning — the watch-calendar comparison — and still has no reader.
  Wiring it into the attribution line remains its own decision.
- Within the phone's day the number is still shown. §5's *"never a confident zero"* holds for exactly
  the case it was written for, and is now pinned by a time-zone test of its own instead of by the
  assertion this amendment changes.
