# Apple Health — design

**Status:** the design approved by the owner in conversation on 2026-10-29, in this order: the order of
work, *Upload, then Health* — what the repository can do toward the 1.4 upload first, then this item on a
branch of its own; **write only** ("Write only (Recommended)"); **all of the user's history** when it is
turned on; **Settings only**; on turning it off, **leave what is in Health and stop writing**; approach
**A, reconcile**; then, at the first section of the design, "all sections are right and do not ask me all
one by one". **The written spec is approved** (2026-10-29, "Approved, write the plan"), with D6 ruled the
same day ("It comes back"). The plan follows it, and no code is written until the rule wording in §3.12 is
approved as typed (roadmap §8).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`.
Where this spec and a rule disagree, the rule stands until the owner approves §3.12's amendment.

**Provenance.** Every claim about the repository was read at HEAD `e4c70e4` on 2026-10-29, with the day's
staged documentation changes over it (no code staged). Claims about HealthKit that this Mac has not shown
are marked **to be measured** and are Task 0's (§4a); nothing built rests on one before it is measured.

## 1. Where this sits

Roadmap item 1.3.3, the one unbuilt item of release 1.3. Premium's 1.4.1 started ahead of it on the
owner's choice (2026-10-21), and the 1.4 upload carries 1.2, 1.3 without it and set A. The roadmap's reason
for it: Apple Health is the integration the competitors read on 2026-10-06 offer and WaterBuddy does not.
It is free (roadmap §4), and 1.4.11, the workout-aware goal, waits on it — though that item reads workouts,
which this one does not (§3.2, D1).

**It ships after 1.4.** The code is built on a branch, `feature/apple-health`, made from `main` once the
owner has committed this spec and the day's staged records, so `main` stays exactly the 1.4 upload. The
merge, and the version it ships in, are the owner's.

## 2. What exists today (measured)

- **A serving** is a `WaterLog`: `id: UUID`, `amount: Int`, `timestamp: Date` (`WaterLog.swift`). The `id`
  is stable across an edit, which is what a Health sample needs to be found again.
- **Every path that changes a row ends in `saveAndRecompute()`** (`DataManager.swift:1383`): `addLog`,
  `removeWater`, `ingest`, `deleteLog`, `updateLog`, `resetDailyProgress` — and through them `addWater` and
  `undoLog`. It returns whether the save succeeded.
- **The widget's button writes rows in the widget extension's process** (`AddWaterIntent`), and so does the
  Control Center control; the app sees them on its next `refresh()`, which republishes and does not save.
  Siri's *Log a Glass*, the reminder's button and the watch's pours (`ingest`) run in the app's process.
- **`DataManager.swift` compiles into all four targets** — the app, the widget extension, the watch app and
  the watch widget (rule `15-project`). It cannot import HealthKit, and no type it names can live in an
  app-only file.
- **`DataManager.shared` is `DataManager()`** with production defaults (`DataManager.swift:188`); the app
  takes it in `WaterBuddyApp.init()` and injects it with `PremiumStore` and `InsightWriter` beside it.
- **The pattern already exists for reminders.** `ReminderPlan` decides what should be pending — a pure value
  importing Foundation alone — and `NotificationManager` files and unfiles to match, through one
  `ReconcileQueue` (`NotificationManager.swift:361`): a `nonisolated` queue of `@Sendable () async -> Void`
  operations, run in the order asked for, with `settled()`. It names nothing about notifications, so a
  second queue of the same class can carry Health's passes.
- **Permission is asked only from a tap** and re-read when the app comes forward: `ReminderPermission`'s
  `enable(on:using:)` and `reconcile(_:using:)`, the second called from `WaterBuddyApp`'s `scenePhase`
  handler beside `manager.refresh()` and `premium.refresh()`.
- **Signing:** `com.apple.security.application-groups` is the only entitlement on any of the four signed
  targets, and the four files are byte-identical. **No `NS*UsageDescription` key** exists in the project.
- **The phone's suite holds eleven keys** (`DataManager.Key`); `Key.all` rosters them, and
  `DataManagerTests` checks that every key the product writes is on it.
- **The privacy policy** (`PRIVACY.md`, `Tools/PrivacyPolicy.html`, not yet published) lists the frameworks
  the app is built from — HealthKit is not among them — and says the app stores "no health record".

## 3. The design

### 3.1 What the user sees

- **Settings** gains an **Apple Health** card under *Smart reminders*: one switch, *Save water to Apple
  Health*, and under it *Each serving is saved to Health as water. WaterBuddy reads nothing from Health.*
- **Turning it on** shows iOS's Health sheet, which asks to write *Water* and to read nothing. Allowed: the
  switch is on, and every serving the user has ever logged is written into Health once. Refused: the switch
  stays off, and since iOS does not show its sheet twice, a line under it says where to allow it (the path
  measured in Task 0, §4a).
- **While on**, a serving appears in Health whichever way it was logged — Home, History, Siri, a reminder's
  *Log a Glass*, the watch, the widget, Control Center. An edit moves it, a delete or *Undo* removes it, a
  reset of today removes today's. A pour made in the widget extension's process lands in Health the next
  time WaterBuddy runs.
- **If the user withdraws the permission** in Health, the switch reads off the next time the app comes
  forward, as reminders do.
- **Turning it off** writes nothing more, and deletes nothing: what is in Health stays, the user's to keep
  or delete in Health. Turning it on again catches Health up, writing nothing twice.
- **Free for everyone.** No figure WaterBuddy draws changes; the widgets, the watch and Siri do not change.
  Health appears in Settings and nowhere else.

### 3.2 Decisions

- **D1 — Write only** (the owner's). WaterBuddy's own log stays the source of truth for every figure; it
  asks Health for write permission alone and reads nothing another app wrote. Reading water other apps
  logged, shown or counted, is a later item with its own amendment.
- **D2 — The whole history** (the owner's), written in one pass when the switch turns on.
- **D3 — Settings only** (the owner's). The welcome is unchanged.
- **D4 — Turning off deletes nothing** (the owner's).
- **D5 — Reconcile** (the owner's approach A): a pure plan diffs the log against what WaterBuddy already
  wrote, and an app-only writer makes Health match, through one queue — reminders' shape.
- **D6 — A sample the user deletes in the Health app comes back while its serving stands**, on the next
  pass that covers its day: Health is a copy of the log, and the way to remove water is to delete the
  serving in WaterBuddy. The alternative — remembering every sample written, so one deleted in Health stays
  deleted — needs a stored record of the user's servings in a second place, and a turn-off and turn-on would
  still have to choose. **The owner's, 2026-10-29: "It comes back".**
- **D7 — The widget's and the control's pours reach Health at the next pass in the app's process** — the
  app coming forward, or any later change made there — never from the extension (approach A over C). No
  door waits for Health before it answers: a Siri phrase or a reminder's button that returns before the
  pass ends leaves it to the next one.

### 3.3 The pieces

**`WaterBuddy/HealthPlan.swift`, new, app-only.** A pure value, `nonisolated`, importing Foundation alone —
`ReminderPlan`'s position. It decides what Health should be told, and nothing else:

- `HealthPlan.Serving` — `id: UUID`, `amount: Int`, `at: Date`: a serving as Health needs it.
- `HealthPlan.Sample` — `object: UUID` (Health's own id for the sample), `serving: UUID?` (its sync
  identifier, read back as a serving's id), `amount: Int` (whole millilitres, rounded on the way in by the
  writer), `at: Date`, `version: Int`.
- `HealthPlan.Changes` — `saves: [Save]`, each a `Serving` and the `version` to write it at, and
  `deletions: [UUID]` (sample objects); `Equatable`, so a test compares a whole answer.
- `HealthPlan.changes(servings:samples:) -> Changes`, over servings and samples taken from **the same
  interval**:
  - a serving with no sample is saved at version 1;
  - a serving whose sample differs in amount or instant is saved again one version above the sample's —
    HealthKit replaces a sample whose sync identifier matches and whose version is lower (**to be measured**,
    §4a);
  - a serving with more than one sample keeps the highest version and the rest are deleted;
  - a sample whose serving is not among the servings is deleted — the serving was deleted, or its day left
    the interval by an edit;
  - a sample with no sync identifier is left alone: WaterBuddy never writes one, so it is not WaterBuddy's to
    judge.
- `HealthPlan.Scope` — `.all`, or `.recent`: the last `recentDays` days to the end of today, on
  `Calendar.waterBuddyDay`. `recentDays` **is** `DataManager.appliedLedgerRetentionDays` — 90, the span the
  phone's applied ledger keeps a watch pour's day, the latest a serving can still arrive or change — by name,
  so the two cannot drift; History's own edits reach only its week, well inside it.

**`WaterBuddy/HealthMirror.swift`, new, app-only — the one file that imports HealthKit.**
`@MainActor @Observable final class HealthMirror`, `PremiumStore`'s and `InsightWriter`'s shape:

- `HealthMirror.Source`, a struct of closures built by `static func live()`, the only way to Health:
  `isAvailable()`, `status()` (`.notDetermined`, `.allowed`, `.denied`, from
  `authorizationStatus(for: .dietaryWater)`, which is accurate for a write type), `requestWrite() async ->
  Bool`, `samples(in: DateInterval?) async -> [HealthPlan.Sample]?` (`nil` on a failed read), `save(_:) async
  -> Bool`, `delete(_:) async -> Bool`. A sample is written as `HKQuantityType(.dietaryWater)` in millilitres,
  start and end at the serving's instant, with `HKMetadataKeySyncIdentifier` (the serving's id),
  `HKMetadataKeySyncVersion` and `HKMetadataKeyWasUserEntered`. `samples` queries only WaterBuddy's own
  source (`HKSource.default()`).
- `enable(_ manager: DataManager) async` — the one place the permission is asked, from the switch's tap:
  asks only while `status()` is `.notDetermined`; sets `manager.healthEnabled` from the answer; on `true`,
  asks for an `.all` pass. `disable(_:)` sets it `false`.
- `reconcile(_ manager:) async` — called when the app comes forward: reads `status()`, turns
  `healthEnabled` off when it reads `.denied`, and asks for a `.recent` pass while on.
- `request(_ scope:)` — coalesces: while a pass is waiting, a second request widens it (`.all` over
  `.recent`) and enqueues nothing; otherwise it enqueues one pass on its own `ReconcileQueue`. A pass runs
  only while `healthEnabled` is `true`, reads the servings when it starts — never when it was asked for —
  and `settled()` passes through to the queue, for tests.
- It observes `DataManager.logsDidSaveNotification` with `queue: .main` and `MainActor.assumeIsolated`
  (rule `43-concurrency`'s idiom) and asks for a `.recent` pass.
- `static let shared`, built by `WaterBuddyApp.init()` beside the manager — in the app's process only.

**`DataManager.swift`, changed — no HealthKit, no Health type.**

- `Key.healthEnabled` — a `Bool`; absent is off, never materialised. On `Key.all`. The phone's suite: 12.
- `var healthEnabled: Bool` — observable, read from the key, written only by its setter, as
  `remindersEnabled` is. It rings no doorbell and reschedules nothing: no widget, reminder or watch reads it.
- `func logs(since start: Date?) -> [WaterLog]?` — a read beside `recap(of:)`: the rows from `start`
  (or every row for `nil`), oldest first, and **`nil` on a failed read**, never `[]`, so a failed read can
  never be turned into deletions in Health (rule `20-state`). Publishes nothing, writes nothing.
- `appliedLedgerRetentionDays` loses `private` and becomes `nonisolated static let`, so `HealthPlan` can
  name it; its value and its use in `ingest(_:)` are unchanged.
- `static let logsDidSaveNotification`, posted at the end of `saveAndRecompute()` when the save succeeded.
  Posting from the widget extension's process reaches no observer there; the app's `HealthMirror` is the
  only one.

**`WaterBuddyApp.swift`** builds `HealthMirror.shared`, injects it with `.environment(health)`, and in its
`scenePhase` handler runs `Task { await health.reconcile(manager) }` beside reminders'. The DEBUG fresh start
builds no mirror of its own: its throwaway suite has no `Key.healthEnabled`, so no pass runs.

**`SettingsView.swift`** draws the Health card under the reminders card, from `@Environment(HealthMirror.self)`,
hidden when `isAvailable()` is `false`. Its switch's binding calls `enable` on, `disable` off — one call each.
The card is the reminders card's pane — the same `density`/`elevation` pair.

### 3.4 When a pass runs, and over what

| Moment | Scope |
|---|---|
| The switch turns on and Health allows it | `.all` |
| A save in the app's process (`logsDidSaveNotification`) | `.recent` |
| The app comes forward | `.recent`, after the status re-read |

A pass: `manager.logs(since: scope's start)` → `source.samples(in: scope's interval)` →
`HealthPlan.changes` → `source.delete`, then `source.save`. Both reads must succeed before anything is
written. The cost of a `.recent` pass on a lived-in store — a year of servings, eight a day — is measured in
the plan's walk; if its row read is over the month view's 6 ms read budget, the save-triggered pass narrows
to History's week, which is every day an in-app edit can reach.

### 3.5 Failures

- **A failed row read** — `logs(since:)` returns `nil`: the pass ends and asks Health nothing.
- **A failed sample read** — on a locked iPhone, HealthKit's store cannot be read (**to be measured** on a
  device, §4a): the pass ends and writes nothing. The next pass — the app coming forward — catches up.
- **A failed save or delete**: nothing is recorded and nothing is retried in place; the next pass sees the
  same difference and writes it again. Diagnostics under `#if DEBUG` name the condition, never an amount, an
  instant or an id (rule `75-diagnostics`).
- **Refused, or withdrawn**: `healthEnabled` is `false`, and a pass does not run.
- **No Health on the device**: the card is not drawn. (Every iPhone has it; the check costs one line.)
- **Never a deletion from an empty read**, by construction: deletions come only from samples read in the
  same pass as the servings.

### 3.6 Concurrency

`HealthPlan` is `nonisolated` and `Sendable` throughout, and its suite is a compile-time canary that is not
`@MainActor` (rule `43-concurrency`). `HealthMirror` is `@MainActor`; its passes run on a `ReconcileQueue`
whose operations call the mirror's main-actor `pass(_:)` — no `MainActor.run`, no `DispatchQueue`. Whether
`HKHealthStore` is `Sendable` in this SDK decides whether `live()` captures one store in its closures or each
closure builds its own in its own body, as `ReminderScheduler.live()` does (**to be measured**, §4a); nothing
from HealthKit is held in a `static let`.

### 3.7 Accessibility

The switch is one `Toggle` with its label, *Save water to Apple Health*, and the card's line as its hint,
on the control itself (rule `65-accessibility`); the refusal line is a separate `Text` read after it. The
card's heading carries the header trait. A 44-point floor on the row, as the reminders row has.

### 3.8 The words

English, digit-free in every language:

| Key | English |
|---|---|
| card heading | Apple Health |
| switch | Save water to Apple Health |
| line | Each serving is saved to Health as water. WaterBuddy reads nothing from Health. |
| refusal | WaterBuddy can't save to Health yet. Allow it in the Health app: [the path Task 0 measures]. |
| `NSHealthUpdateUsageDescription` | WaterBuddy saves each serving you log to Apple Health as water. It reads nothing from Health. |

The refusal line's last clause is written from Task 0's measurement, not before (§4a, item d). Russian and
Uzbek are drafted in the plan, following Apple's own name for the Health app in each language, and are
drafts until the owner's sweep, as set A's were (#170, #175, #179, #185). The usage description is
localised through a new `WaterBuddy/InfoPlist.xcstrings` in `en`, `ru` and `uz`.

### 3.9 Project and signing

- `Entitlements/WaterBuddy.entitlements` gains `com.apple.developer.healthkit` = `true`. The other three
  files are unchanged, so the four are no longer identical — the app's is the one that differs.
- The app target's two configurations gain `INFOPLIST_KEY_NSHealthUpdateUsageDescription`.
  `NSHealthShareUsageDescription` is added **only** if Task 0 measures that iOS or the upload demands it of
  an app that reads nothing, with wording that says so.
- `HealthPlan.swift` and `HealthMirror.swift` are app-only: in no exception set. HealthKit is linked by its
  `import` alone (rule `95-dependencies`).
- **The owner's, outside the repository:** the HealthKit capability on the App ID `sardor.WaterBuddy` in the
  developer portal (automatic signing adds it when Xcode next signs), and confirming a distribution profile
  carries it before an archive.
- The privacy manifests do not change: HealthKit is not a required-reason API, and nothing is collected
  (`PrivacyManifestTests` unchanged).

### 3.10 Privacy, the policy and the listing

- **The policy changes with the release that carries Health**, never before it, and is published before
  that release is submitted. `PRIVACY.md` and `Tools/PrivacyPolicy.html` together: HealthKit joins the
  frameworks with a sentence of its own; a section *Apple Health, if you turn it on* — each serving's amount
  and moment written to Health on the iPhone as Water, with its id so an edit replaces it; nothing read from
  Health; Health is Apple's, kept on the device and synced through iCloud only under the user's own Health
  setting; turning it off stops writing and deletes nothing, and the Health app deletes by source; *no
  health record* reworded to say what WaterBuddy keeps and what it hands to Health; *Last updated*.
- **The App Store privacy label stays *Data Not Collected*** — nothing reaches the developer.
- **The listing** names the integration in its description, as guideline 2.5.1 asks of an app that uses
  HealthKit; the sentence is written with the release's listing, not here.

### 3.11 What does not change

The figures, the widgets' read path, the snapshot, the watch and its wire format, Siri's replies, the
reminders, Premium. `WaterLog` gains no field. The watch writes nothing to Health: its pours reach Health
through the phone, once ingested, and Health on the watch shows them through Apple's own sync.

### 3.12 What it amends in the rules (typed unstaged, for the owner, before any code)

- **`70-privacy`** — a section *HealthKit, for Apple Health*, with its conditions: one file
  (`HealthMirror.swift`) imports HealthKit and reaches it through `HealthMirror.Source`; write only, Water
  only — reading anything, or a second type, needs its own amendment (1.4.11's workouts among them);
  asked only from Settings' switch, through `HealthMirror.enable`, never at launch or from any other door; the
  log stays the source of truth and nothing from Health reaches a figure, a widget, the watch, Siri, a
  notification or the recap; a sample carries the amount, the instant and the serving's id, and nothing else;
  turning off deletes nothing; no diagnostic carries a sample. **The two exceptions, each for this alone:**
  `com.apple.developer.healthkit` on the app target beside the App Group, and `NSHealthUpdateUsageDescription`.
  *Nothing leaves the device*'s banned list and the WatchConnectivity section's *No third framework rides in
  behind it* stop naming HealthKit for the phone and keep it banned on the watch.
- **`15-project`** — *Signing*: the app's entitlements carry HealthKit too, the other three only the group;
  *Membership*: the two app-only files; *Localization*: `InfoPlist.xcstrings`, a sixth catalogue, `en`, `ru`
  and `uz`; *Submission*: the capability on the App ID.
- **`10-architecture`** — the ruling *Apple Health is a copy, written by the app*; *Forbidden*: `import
  HealthKit` outside `HealthMirror.swift`; the suite's key count, 12.
- **`20-state`** — `healthEnabled` and `logs(since:)` on the surface; `saveAndRecompute()` posts
  `logsDidSaveNotification` after a successful save.
- **`25-shared-storage`** — `Key.healthEnabled`, whose absence means off.
- **`43-concurrency`** — `HealthMirror`'s shape; `HealthPlan` and its suite `nonisolated`.
- **`50-views`** — Settings' Health card, and the mirror from the environment.
- **`65-accessibility`** — the switch's label and hint on the control.
- **`85-testing`** — HealthKit only through `HealthMirror.Source`'s closures, never `live()`;
  `HealthPlanTests` on the canary lists; the hand proofs of §4.

### 3.13 Testing, first

Every test below is written and seen red before its code (rule `85-testing`).

- **`HealthPlanTests`** (not `@MainActor`): a new serving is saved at version 1; an unchanged one is left
  alone; an edited amount, and a moved instant, are saved one version above the sample's; a sample whose
  serving is gone is deleted; a second sample of one serving is deleted, the highest version kept; a sample
  with no sync identifier is left alone; the two scopes' intervals, from an injected calendar and clock,
  across a DST day.
- **`HealthMirrorTests`** (`@MainActor`, a fake `Source` and a throwaway manager): turning on asks once and
  writes the whole history; a refusal leaves it off and writes nothing; a denial already recorded asks
  nothing; turning off writes nothing more and deletes nothing; a failed row read and a failed sample read
  each write nothing; a save posts a pass only while on; passes run in the order asked for and coalesce;
  coming forward turns it off on `.denied`; a pass reads the servings when it starts.
- **`DataManagerTests`**: `healthEnabled` is off with the key absent, and its setter writes only its key;
  `Key.healthEnabled` is on the roster; `logs(since:)` reads from its bound, oldest first; a successful save
  posts `logsDidSaveNotification`, from every mutation. The snapshot's read-only tests still pass, their
  helper extended for the new key (rule `30-rollover`).
- **`LocalizationTests`**: the new keys in `en`, `ru` and `uz`, digit-free; the usage description resolves
  from the built bundle in each.
- **`WaterBuddyUITests`**: Settings carries exactly one element labelled *Save water to Apple Health*. The
  switch is not pressed in a UI test: the sheet behind it is Health's.

## 4. Verification

- **The gate**, all five invocations, the UI run on iOS 26.5 too, on the branch; warnings compared with a
  clean build of `main` by file and message.
- **By hand, on the iPhone simulator** (27.0, then 26.5 and 18.6): turn it on → Health's sheet asks to write
  Water and to read nothing → allow → the Health app's Water shows every serving, its source WaterBuddy; a
  pour on Home appears; an edit in History moves it; a delete and an *Undo* remove it; a widget pour appears
  once the app comes forward; turn off, pour, see nothing new; turn on, see it caught up with nothing
  doubled; refuse on a fresh install and read the line; withdraw it in Health and see the switch off on
  return; VoiceOver on the card.
- **On a device, for 1.2.7's sweep:** a reminder's *Log a Glass* on a locked iPhone reaches Health after
  unlock; a watch pour reaches Health on the phone and on the watch.

## 4a. Task 0 — measured before any code

On the iOS 27.0 simulator, in a scratch app outside this repository — never the real App Group — and
written into this section before Task 1:

- **a.** With write permission alone, a query returns WaterBuddy's own samples and none written by another
  source.
- **b.** `requestAuthorization(toShare: [Water], read: [])` with only `NSHealthUpdateUsageDescription` set:
  no exception, and the sheet asks to write Water alone.
- **c.** A save with an existing sync identifier and a higher version replaces the sample; an equal or lower
  version — what happens.
- **d.** The path in the Health app on iOS 27.0 to an app's permission, for §3.8's refusal line.
- **e.** Whether `HKHealthStore` is `Sendable` in this SDK, for §3.6.
- **On a device only**, for the sweep: whether a read fails on a locked iPhone (§3.5).

If **a** or **c** fails, the plan stops and this spec is revised: they are what approach A rests on.

## 5. Open, for the owner

- ~~**D6**~~ — ruled 2026-10-29: a sample deleted in the Health app comes back while its serving stands.
- The version the branch ships in, and when it is merged — after the 1.4 upload.

## 6. Refinements made while planning (2026-10-29)

Found by reading the code the plan quotes, after the owner's approval; each supersedes the sentence it
names, and the plan (`docs/superpowers/plans/2026-10-29-apple-health.md`) follows this section.

- **The card is the reminders card's twin** (supersedes §3.1's and §3.7's heading plus switch): its switch's
  label, *Apple Health*, is its title, drawn and spoken, and the line under it is the switch's hint —
  `SettingsView`'s *Smart reminders* row exactly. §3.8's keys become: *Apple Health*; *Saves each serving to
  Apple Health as water. WaterBuddy reads nothing from Health.*; and the refusal, *Health access is off for
  WaterBuddy. Turn it on in Settings › Privacy & Security › Health › WaterBuddy.* — the path Task 0 (d)
  confirms on iOS 27.0, and the string changes with it if it does not hold. §3.13's UI test counts one
  switch labelled *Apple Health*.
- **`Source.requestWrite` returns nothing** (supersedes §3.3's `-> Bool`): HealthKit's request succeeds
  whether or not Water was allowed, so the mirror reads `status()` after it. `delete` takes a `Set<UUID>`,
  and `HealthPlan.changes` takes the interval itself — `changes(servings:samples:within:)` — so the writer's
  query may be loose at the edges and both sides are still cut to the same half-open interval.
- **`logs(since:)` is newest first**, as every read in `DataManager` is (supersedes §3.3's "oldest first");
  the plan does not depend on the order.
- **Instants are compared to the millisecond**, so a date HealthKit hands back a hair different is not
  written again on every pass; Task 0 gains **f.** — whether an instant and an amount come back exactly.
  §4a's **e.**, whether `HKHealthStore` is `Sendable`, is answered by Task 5's build instead: a warning
  there moves the store into each closure.
- **Two more rule files** (supersedes §3.12's nine): `00-workspace` and `60-design-system` say a `Double`
  of millilitres may exist only as a drawing fraction; `HealthKit` takes one, so both add *or at HealthKit's
  boundary, in `HealthMirror.Source.live()`, from an `Int` and rounded back to one*.
- **The order of work**: Task 0 before the rule wording — the plan was first asked for the other way
  round — since the wording names what Task 0 measures, the one usage key (b) and the refusal's path (d),
  and Task 0 builds nothing that stays. Still no product code before the wording is approved.
