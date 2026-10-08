# Log a glass by voice — design

**Status:** approved by the owner in conversation on 2026-10-07, in three sections — what the user
gets, how it runs, and the proof, rules and limits — then "Yes, write the spec". **Implemented the same
day**, from `docs/superpowers/plans/2026-10-07-siri-phrase.md`, and staged for the owner's `/commit`:
the gate green but for one pre-existing UI failure (HEAD fails it identically), no new warning, and a
fresh final review whose fix pass added `LogServingIntent.logTheGlass(into:from:)` and its tests.
**Execution is unproven:** on the simulator the shortcut registers but `linkd` refuses to run an
ad-hoc-signed build (`docs/AI_CONTEXT.md` #63), so the owner's device check (§8.3) is the first run of
`perform()`. Roadmap item 4 (the first of the roadmap's *Next* group). The rule wording in §5 was a
proposal — rules change only when the owner decides (rule `99-docs-cascade`) — and the owner approved
it on 2026-10-08 ("Write §5 as proposed"); it is written.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `4a7f4dd` on 2026-10-07. Claims
about Apple's platform carry their source: **SDK** is
`iPhoneOS.sdk/…/AppIntents.swiftmodule/arm64e-apple-ios.swiftinterface` in Xcode 27.0 on this
machine; the rest are Apple's documentation and WWDC sessions, or are marked as reported or inferred.

---

## 1. What is being built

A user says **"Log water in WaterBuddy"** and their Glass is logged — without opening the app, without
setting anything up first, and with nothing private said back. The same action appears on its own as
a tile in Spotlight and the Shortcuts app.

The owner's rulings, in the order they were asked:

- **What it logs:** the widget's serving — the middle quick-add vessel, the Glass, at whatever amount
  the user set. Not a named vessel, not an amount Siri asks for.
- **What Siri says, and when it runs:** it works on a locked iPhone and replies with a fixed
  confirmation — no amount, no total, no digit.
- **Where it lives:** the app target, not the widget extension and not a new App Intents extension.

## 2. What happens today

- `AddWaterIntent` (`WaterBuddyWidget/AddWaterIntent.swift`) is the product's only App Intent, compiled
  into the widget extension only. It is a Shortcuts action, *Log Water*, so a user *can* reach it by
  voice — but only after building a shortcut by hand, and that shortcut logs the action's pre-filled
  250 ml, not their Glass: `init()` seeds `DataManager.defaultServing`, and rule `40-widget` forbids
  `perform()` from re-reading the serving at run time, because a decoded `@Parameter` is what a caller
  asked for.
- There is no `AppShortcutsProvider`, no phrase, and no `AppShortcuts` catalogue.
- The widget's snapshot reads the Glass as `resolveServings(in: defaults)[1]` — a bare index, spelled
  once, in `DataManager.snapshot(defaults:calendar:now:)`.

## 3. The design

### 3.1 What the user gets

- **Phrases.** English: *Log water in ${applicationName}*, *Add water in ${applicationName}*, *Log a
  glass in ${applicationName}*. Russian: *Запиши воду в ${applicationName}*, *Добавь воду в
  ${applicationName}*, *Запиши стакан в ${applicationName}* — *стакан* is the same word in the
  accusative, so no ending changes. They work from install: an App Shortcut needs no setup.
- **The tile.** Title *Log a Glass*, glyph `mug.fill` — the Glass's own (`vesselSlots`) — tile colour
  `.blue`.
- **What it logs.** The Glass, read from the shared store at the moment Siri runs, so an amount edited
  a minute ago is honoured.
- **What Siri says.** *Water logged.* — fixed, digit-free, in en/ru/uz.
- **Locked iPhone.** It runs: `authenticationPolicy` is `.alwaysAllowed`, written out although it is
  the default (Apple's documentation: it "allows the intent to run without authentication, including
  when the device is locked"), so the choice is visible where it is made.
- **In the Shortcuts app** the user sees two WaterBuddy actions: *Log Water* (any amount — for
  automations) and *Log a Glass* (their Glass). Named differently on purpose.

### 3.2 Strings and languages

| Where | Key (en) | ru | uz |
|---|---|---|---|
| intent title, tile title | `Log a Glass` | Записать стакан | Stakanni qayd etish |
| intent description | `Adds your Glass to today's total in WaterBuddy.` | Добавляет ваш стакан к сегодняшнему итогу в WaterBuddy. | WaterBuddy’dagi bugungi umumiy hisobga stakaningizni qo‘shadi. |
| Siri's reply | `Water logged.` | Вода записана. | Suv qayd etildi. |
| description category | `Hydration` (existing key) | — | — |

- These live in the **app's** `Localizable.xcstrings`, translated in all three languages — Apple keeps
  localized strings in the bundle that holds the App Intents types (WWDC22 10032).
- **The phrases** live in a new **`WaterBuddy/AppShortcuts.xcstrings`**, in **English and Russian
  only.** Siri has no Uzbek: Xcode 27's own Siri App Shortcuts models cover ru and not uz (inferred from
  `SiriSSUKitModel.framework`'s per-locale folders; Apple's language page could not be read). Every
  phrase must contain `${applicationName}` (WWDC25 244; the build warns otherwise).
- **All of it follows the device language**, not the in-app language picker: Siri and Shortcuts
  resolve the strings themselves. The widget's gallery strings already have this limit
  (`docs/WIDGET.md`).

### 3.3 Where it lives

Three new files, all **app-only** — the app's synchronized folder gives them membership, none joins any
exception set, and `project.pbxproj` does not change:

- `WaterBuddy/LogServingIntent.swift` — the intent.
- `WaterBuddy/WaterBuddyShortcuts.swift` — the provider. **One provider per app** (WWDC25 244), in the
  **same target as the intent it names**: Apple's article says to "define your shortcuts in the same
  place you define the app intents that those shortcuts use", and the build reports an intent that is
  not.
- `WaterBuddy/AppShortcuts.xcstrings` — the phrases (§3.2).

**Why the app target.** It is the documented home of a provider, and an intent there with
`openAppWhenRun` false "will be run in the background… your app will launch in a special mode without
scenes being brought up" (WWDC22 10032). It is also the only process that can reach the watch: known
issue #53 records that `WCSession` is most likely unavailable to an extension. The widget extension was
rejected because no Apple source says Siri finds a provider there; a new App Intents extension because
it would be a fifth signed target — entitlement, privacy manifest, exception set, catalogues, and a
fifth answer to `DataManager.role` — that still could not reach the watch.

`AddWaterIntent` is untouched, and stays in the widget extension only.

### 3.4 The intent

```swift
struct LogServingIntent: AppIntent {
    static let title: LocalizedStringResource = "Log a Glass"
    static let description = IntentDescription("Adds your Glass to today's total in WaterBuddy.",
                                               categoryName: "Hydration")
    static let openAppWhenRun = false
    static let authenticationPolicy: IntentAuthenticationPolicy = .alwaysAllowed

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog { … }
}
```

No `@Parameter`: the amount is not the caller's to give. `openAppWhenRun` is deprecated on iOS 26 in
favour of `supportedModes` (SDK), which is not a warning at a 17.0 deployment target — the same as
`AddWaterIntent`. `perform()` is `@MainActor` on a `nonisolated` requirement, as `AddWaterIntent`'s is.

**`perform()`, in order:**

1. **Wait briefly for the watch link** — `await WristLink.waitUntilActivated()`, new: at most about a
   second, polling `WCSession.default.activationState` every 100 ms through the existing, tested
   `WristLink.poll(until:every:atMost:)`. `WaterBuddyApp.init()` starts activation on this same launch,
   and step 3's publish is skipped if it has not finished (`requestWristPublish` throws into its
   `DEBUG` catch). With no watch, or a slow one, it carries on; the publish on activation
   (`activationDidCompleteWith`) still fires if the process lives that long.
2. **Read the Glass** — `DataManager.usualServing(in: DataManager.sharedDefaults)`, new.
3. **Log it** — `DataManager.shared.addWater(amount:)`, the existing door: it re-reads, rolls the day if
   it turned, writes the row, recomputes, rings the widget doorbell, publishes to the watch and asks
   for a reminder re-plan.
4. **Wait for the reminder queue to drain** — `await DataManager.remindersSettled()`, new, so the
   re-plan step 3 queued reaches the notification centre before the system can suspend the app. Never
   a direct `NotificationManager.reconcile`: it would run outside the queue, which is how #46 raced.
5. **Reply** — `.result(dialog: "Water logged.")`.

No hand-written widget reload: step 3 rings the doorbell on any real change. `AddWaterIntent` reloads by
hand because it runs in the widget's own process and covers a total pinned at the cap.

### 3.5 The provider

```swift
struct WaterBuddyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: LogServingIntent(), phrases: [ … §3.1 … ],
                    shortTitle: "Log a Glass", systemImageName: "mug.fill")
    }
    static let shortcutTileColor: ShortcutTileColor = .blue
}
```

`AppShortcut(intent:phrases:shortTitle:systemImageName:)` with a non-optional title and image is
iOS 17.0 (SDK; the optional overload is deprecated in 17). `appShortcuts` is a computed `static var`
because the protocol's builder requires one — the second such property in the product after
`AddWaterIntent.parameterSummary`, which rule `43-concurrency` named as the only one until §5's wording
was written; it now names both.

### 3.6 The model's three additions

- **`DataManager.usualServing(in:)`** — `nonisolated static`, `resolveServings(in:)[1]` with a name and
  a DocC: the serving every one-tap door logs. `snapshot(defaults:calendar:now:)` switches to it, so the
  widget and Siri read one definition rather than two `[1]`s.
- **`ReconcileQueue.settled()`** — returns once everything enqueued before the call has run. It
  enqueues an operation that resumes a continuation, so it rides the same worker and cannot overtake
  work asked for earlier. Work enqueued after the call does not hold it.
- **`DataManager.remindersSettled()`** — `nonisolated static`, awaits `reminderReconciles.settled()`.
  The queue itself stays `private`.

And one to `WristLink`, beside `waitForPendingDelivery()` in `DataManager.swift`:

- **`WristLink.waitUntilActivated()`** — `nonisolated static`, returns when `WCSession` reports
  `.activated`, after about a second, or at once when `WCSession` is unsupported or the task is
  cancelled. Its pure half is `poll`, already tested.

## 4. What it touches beyond the intent

- **Storage:** no key, no stored byte, no schema change. `addWater` is the existing mutation; nothing
  new joins rule `20-state`'s mutation surface.
- **The widget:** its snapshot's serving comes from `usualServing(in:)` — the same value as before.
  Its view tree, timeline and `AddWaterIntent` are unchanged.
- **The watch:** reached through the existing publish, now with a bounded wait for activation. Siri
  on the watch is not part of this (§9).
- **Reminders:** re-planned by the existing hook; the intent only waits for the queue (§3.4).
- **Entitlements, exception sets, privacy manifests, `Info.plist`:** unchanged. App Shortcuts are an
  App Intents feature and, unlike SiriKit, are not documented as needing the Siri capability or a usage
  description — **inferred, not verified**. The simulator pass (§8.3) settles it; if Siri turns out to
  need either, the work stops for the owner, because rule `70-privacy` keeps the App Group the only
  entitlement and allows no `NS*UsageDescription`.

## 5. What this amends — written 2026-10-08, at the owner's word

The owner approved this wording after the implementation; it is in `.claude/rules/` as written below,
staged on its own paths so `/commit` can make it its own change.

- **`70-privacy`**, *The lock screen is a public surface*: "Siri's reply to *Log a Glass* is a public
  surface held to the same standard: one fixed, digit-free `IntentDialog`, no user value, in every
  shipped language — `theSiriReplyCarriesNoUserValues` asserts it as `theReminderCopyCarriesNoUserValues`
  does. `LogServingIntent.authenticationPolicy` is `.alwaysAllowed` on purpose: logging water on a
  locked phone is harmless, and the reply says nothing."
- **`70-privacy`**, *Localization*: "`WaterBuddy/AppShortcuts.xcstrings` holds Siri's phrases in
  English and Russian only — Siri has no Uzbek. It is the one catalogue exempt from shipping all three;
  the intent's own strings live in the app's `Localizable.xcstrings` in all three."
- **`80-notifications`**, *Who reschedules*: "`LogServingIntent.perform()` holds the app process open
  until the reminder queue has run what its mutation asked for — `await DataManager.remindersSettled()`
  — never by calling `reconcile` itself, which would run outside the queue."
- **`15-project`**, *Membership*: "`LogServingIntent` and `WaterBuddyShortcuts` are app-only and stay
  out of every exception set: a provider and its intents share a target. `AddWaterIntent` stays the
  widget extension's own, differently named action." *Localization*: a fifth catalogue,
  `WaterBuddy/AppShortcuts.xcstrings`, phrases only, en and ru.
- **`40-widget`**, *The read path*: "`WaterSnapshot.serving` comes from `DataManager.usualServing(in:)`
  — the one definition the Siri shortcut also logs."
- **`43-concurrency`**: the "one `static var`" becomes two — `AddWaterIntent.parameterSummary` and
  `WaterBuddyShortcuts.appShortcuts`, both computed, both required by their protocols. `20-state`'s and
  `43-concurrency`'s lists of `nonisolated static` members the widget's read path reaches gain
  `usualServing(in:)`.

`CLAUDE.md`'s "Two front doors, one serving" is `/doc_sync`'s to bring up to date: Siri is a third way
to log the same serving, through the app's own process.

## 6. Privacy

- **Nothing leaves the device from WaterBuddy.** The intent sends Siri one fixed string. Recognising
  the phrase is Siri's, under the user's own Siri settings.
- **The Lock Screen.** The reply carries no digit and no user value (§5). Logging needs no unlock.
- **No new framework banned by rule `70-privacy`.** `AppIntents` is already imported by the widget
  extension; the app gains it. No entitlement, no usage description.

## 7. Testing

Written first, run RED on seams that compile, then GREEN (rule `85-testing`). New file
`WaterBuddyTests/SiriPhraseTests.swift`; a UUID-named suite per test where defaults are touched.

- **`usualServing(in:)`** — in a suite **not** `@MainActor`, a canary that it is `nonisolated`:
  nothing stored gives 250; an edited triple gives its middle; a short, out-of-range or wrongly typed
  triple gives the default, as `resolveServings` does; and for each, `snapshot(…).serving` equals it.
- **`ReconcileQueue.settled()`** — not `@MainActor`, like `ReconcileQueueTests`: it returns only after
  a slow operation enqueued before it has finished; it returns at once on an idle queue; an operation
  enqueued after the call, still blocked, does not hold it.
- **The intent's contract** — `authenticationPolicy == .alwaysAllowed`; `openAppWhenRun == false`;
  the reply resolves in en, ru and uz from the app bundle, each bundle first proven to resolve, and
  carries no digit.
- **The phrases** — the built app carries an English and a Russian phrase table and every phrase names
  `${applicationName}`, if the build emits a table a test can read. If it does not, the build's own
  phrase validation is the check, and the implementation says so rather than writing a test that
  cannot fail.
- **Not automatable:** the live wait for `WCSession` (rule `85-testing`: no real session in a test) and
  Siri itself.

## 8. Verification

### 8.1 The gate

All five invocations, foreground, commands as rule `85-testing` writes them.

### 8.2 Warnings

A clean build of the code before and after, into empty DerivedData, compared per file and message.
`DataManager.swift` and `NotificationManager.swift` change, so every scheme is compared. Expect the app
target's `appintentsmetadataprocessor` step to change: it now has intents to extract.

### 8.3 On the simulator, then the owner's device

- **Simulator:** the *Log a Glass* tile in the Shortcuts app and in Spotlight; running it adds the
  Glass to today, the widget follows, and the reply reads *Water logged.*; with the device in Russian
  the tile and the reply are Russian. Siri itself by text, if the simulator offers it.
- **The owner's iPhone and Apple Watch:** the phrase spoken, locked and unlocked; the total, the
  widget and the watch face follow; a reminder due within the hour is dropped (rule
  `80-notifications`).

## 9. Known limitations, and what is not in scope

- **Siri on the watch.** "App Shortcuts from a paired iOS device cannot be run on the Watch" (WWDC23
  10102); it would need the watch app's own provider.
- **Uzbek phrases** — Siri has no Uzbek. Uzbek users reach the action through Shortcuts and Spotlight.
- **The in-app language picker** does not reach Siri or Shortcuts (§3.2).
- **Another vessel or an amount by voice** — the owner chose one serving. *Log Water* still takes any
  amount for automations.
- **A failed save still replies *Water logged.*** — as the widget's button gives no sign either:
  `addWater` reports nothing to its callers.
- **The watch update is best effort** — bounded at about a second (§3.4).

## 10. Sequence

1. This spec, staged.
2. Seams that compile — every new member present with wrong behaviour.
3. The tests in §7, run RED, each failing on its own expectation.
4. The model's additions (§3.6), then the intent, the provider and the strings (§3.2–§3.5) — GREEN.
5. The gate (§8.1) and the warning comparison (§8.2).
6. The simulator pass (§8.3), then the owner's device check.
7. `HISTORY.md`, `/doc_sync`, and §5's rule wording put to the owner.
8. Staged by explicit path; no commit until the owner's `/commit`.
