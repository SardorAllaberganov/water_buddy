# Today's water, asked of Siri — design

**Status:** approved by the owner in conversation on 2026-10-18, in three sections — what the user
gets, how it runs, and the rules, tests and limits — after two rulings: Siri asks for an unlock before
it answers on a locked iPhone, and the answer carries today's total and what is left. Written the same
day, for the owner's review; **no plan, no rule text and no code yet.** Roadmap item **1.3.4**
(`docs/ROADMAP.md` §4). The rule wording in §5 is a proposal — rules change only when the owner
decides (rule `99-docs-cascade`) — and, as for 1.2.5, it is typed for approval **before** the code.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `88d694f` on 2026-10-18. Claims
about Apple's platform carry their source: **SDK** is
`iPhoneOS27.0.sdk/…/AppIntents.swiftmodule/arm64e-apple-ios.swiftinterface` in Xcode 27.0 on this
machine; the rest are Apple's documentation, WWDC sessions or the developer forums, or are marked as
inferred.

---

## 1. What is being built

A user asks **"How much water today in WaterBuddy"** and Siri answers with today's total and what is
left — *"1,450 millilitres so far today — 1,050 millilitres to go."* — without opening the app. The
same action appears as a tile in Spotlight and the Shortcuts app, *Today's Water*.

The owner's rulings, in the order they were asked:

- **Locked iPhone:** Siri asks for authentication first, then answers (`.requiresAuthentication`).
  No figure reaches anyone who has not authenticated. Recommended for being the reversible choice: a
  locked answer can be granted later; one taken away after people rely on it is a regression. *(The
  owner chose it as "Ask to unlock first", described as Face ID or the passcode. Apple's documentation,
  read after the ruling, is narrower about what authenticates — §3.2.)*
- **What the answer carries:** today's total and what is left — the roadmap's two figures, and two
  numbers are easy to take in by ear. Not the goal on its own, not the percentage, never the streak.
- **How it reads:** the widget's own snapshot (approach A, §3.1) — so Siri says what the widget draws.

## 2. What happens today

- `LogServingIntent` (`WaterBuddy/LogServingIntent.swift`) is the app's only App Intent, and
  `WaterBuddyShortcuts` (`WaterBuddy/WaterBuddyShortcuts.swift`) its only `AppShortcutsProvider`, with
  one `AppShortcut`: *Log a Glass*, three phrases in English and Russian, `mug.fill`, `.blue`.
- Its reply is one fixed line, *Water logged.* — rule `70-privacy` holds every Siri reply to that
  standard today: "one fixed, digit-free `IntentDialog`, no user value, in every shipped language".
- `DataManager.snapshot(defaults:calendar:now:)` is the widget's read: `nonisolated static`, it
  writes no key and applies the midnight rollover to its returned value only (rule `30-rollover`).
  `WaterSnapshot` carries `currentWater`, `dailyGoal`, `language`, `serving`, and computes
  `progress`, `progressUnclamped` and `percentage`. It has no `remaining` and no `hasReachedGoal`;
  `DataManager` has both, on its observable state (`DataManager.swift:501`, `:507`).
- `AppShortcutPhraseTests.everyPhraseNamesTheAppInEnglishAndRussian` reads the built app's
  `AppShortcuts.strings` in `en` and `ru` and expects exactly three phrases in each.
- No simulator here can run an App Shortcut: `linkd` refuses an ad-hoc-signed build (known issue
  #63). *Log a Glass* first ran through the system's path on the owner's iPhone.

## 3. The design

### 3.1 Approaches

- **A — read the widget's snapshot. Chosen.** `perform()` reads `DataManager.snapshot()` and hands it
  to a pure function that builds the line. Asking writes nothing; Siri and the widget draw one
  figure, rollover included; there is no queue to drain and no watch to wait for; and the part no
  simulator can run shrinks to one line, the rest a pure function of a `WaterSnapshot` a test feeds
  any state.
- **B — read through `DataManager.shared` after `refresh()`.** The same figures in the ordinary
  case, but `refresh()` re-plans reminders, so the intent would have to await
  `remindersSettled()` before the system can suspend it: a question that sets off the app's
  bookkeeping, and logic on a `@MainActor` instance instead of a value.
- **C — A, waiting for the watch link first**, to count a pour the watch sent while the phone app
  slept. Rejected: activation does not mean the queued pours have been delivered and ingested, and
  nothing signals when they have. Up to a second for an unprovable gain; recorded as a limitation
  (§9) the widget already shares.

### 3.2 What the user gets

**The answer** — one line, the unit spelled out, spoken and shown wherever Siri shows text.

`IntentDialog(full:supporting:)` exists (SDK), but its shorter `supporting` line is promised only
beside a visual. That much is *reported*, from a web search's summaries rather than read in full: an
Apple DTS engineer ties it to a snippet being shown (developer.apple.com/forums/thread/769667), and
WWDC26 session 343 to the system showing UI; the initializer's reference page, fetched, carried no
text on it. With no snippet (§9), a `supporting` line might never be
shown; so there is one line, written to read correctly both heard and read, and three strings to
translate rather than six. Which form the card shows is part of the device check (§8.3).

| Case | When | English |
|---|---|---|
| Under the goal | `0 < currentWater < dailyGoal` | *1,450 millilitres so far today — 1,050 millilitres to go.* |
| Met, or over | `currentWater >= dailyGoal` | *2,600 millilitres so far today — you've reached your goal.* |
| Nothing yet | `currentWater == 0` | *Nothing logged yet today — 2,500 millilitres to go.* |

`dailyGoal` is at least 1 (rule `20-state`), so *Nothing yet* and *Met* never overlap. Every figure
is grouped and every noun takes its plural form in the language Siri resolves the line in (§3.4).

**The phrases** — English and Russian only; Siri has no Uzbek. No Russian phrase uses a gendered
verb (*выпил* / *выпила*):

| English | Russian |
|---|---|
| *How much water today in ${applicationName}* | *Сколько воды сегодня в ${applicationName}* |
| *How much water have I had in ${applicationName}* | *Сколько осталось выпить в ${applicationName}* |
| *Check my water in ${applicationName}* | *Проверь воду в ${applicationName}* |

**The tile and the Shortcuts action.** Title and short title *Today's Water*; glyph `drop.fill`,
Home's tab glyph (`RootTabView.swift:68`); the provider's existing `.blue`. Shortcuts then lists three
WaterBuddy actions: *Log Water*, *Log a Glass*, *Today's Water*.

**Behaviour.**
- **Locked:** `authenticationPolicy` is `.requiresAuthentication`. The SDK has three cases, and
  Apple's documentation (`IntentAuthenticationPolicy`, read 2026-10-18) describes them as:
  `alwaysAllowed`, "allows the app intent to run at any time, including when the device is locked";
  `requiresAuthentication`, "requires authentication before running the app intent"; and
  `requiresLocalDeviceAuthentication`, "requires the person to unlock the device running the
  intent", which "asks the person to unlock their device if it's currently locked, **even if the
  request originated from an already authenticated Apple Watch or remote device**". So
  `.requiresAuthentication` is *inferred*, from that contrast, to accept an authenticated Apple Watch
  or remote device as well as an unlock of the iPhone itself — still no figure to anyone
  unauthenticated, and friendlier hands-free. The stricter case was not chosen: it guards data that
  is unreadable while the phone is locked, and the answer reads none. What actually authenticates —
  an unlocked watch on the wrist, AirPods, CarPlay — is proved only on a device (§8.3, §9). With
  *Allow Siri When Locked* off, Siri is not offered on a locked iPhone at all.
- **Never opens the app:** `openAppWhenRun` is `false`, as on *Log a Glass*.
- **Language:** Siri's — or the device's, in Shortcuts and Spotlight — as *Water logged.* is
  (spec 2026-10-07-siri-phrase §3.2). The in-app picker does not reach it.
- **Figures:** the total and goal the widget draws at that moment. After midnight, with the app not
  run since, the total is zero: the snapshot applies the rollover in memory.

### 3.3 Strings

All in the **app's** `Localizable.xcstrings` (the bundle that holds the intent), translated in `en`,
`ru` and `uz`. The three answer keys are explicit and positional (§3.4). Russian takes *one*, *few*,
*many* and *other* — *other*, reached only by a fraction, in the genitive singular (rule
`70-privacy`); English *one* and *other*; Uzbek one value. Where the app already says the same thing,
the translation is reused: *Nothing logged yet today*, *Goal reached*, *… millilitres to go*.

| Key (en value) | ru | uz |
|---|---|---|
| `%1$lld millilitres so far today — %2$lld millilitres to go.` | *Сегодня уже* `%#@arg1@` *—* `%#@arg2@`*.* — arg1: *%arg миллилитр / миллилитра / миллилитров / миллилитра*; arg2: *остался %arg миллилитр / осталось %arg миллилитра / осталось %arg миллилитров / осталось %arg миллилитра* | *Bugun %1$lld millilitr — %2$lld millilitr qoldi.* |
| `%1$lld millilitres so far today — you've reached your goal.` | *Сегодня уже* `%#@arg1@` *— цель достигнута.* (arg1 as above) | *Bugun %1$lld millilitr — maqsadga erishildi.* |
| `Nothing logged yet today — %1$lld millilitres to go.` | *Сегодня ещё ничего не записано —* `%#@arg1@`*.* (arg1 as the first key's arg2) | *Bugun hali hech narsa qayd etilmagan — %1$lld millilitr qoldi.* |
| `Today's Water` | *Вода за сегодня* | *Bugungi suv* |
| `Tells you how much water you've had today in WaterBuddy, and how much is left.` | *Сообщает, сколько воды вы выпили сегодня в WaterBuddy и сколько осталось.* | *WaterBuddy’da bugun qancha suv ichganingizni va qancha qolganini aytadi.* |

English plural *one* reads *millilitre* in each figure. The Russian and Uzbek lines were written from
the existing keys, not by a native speaker: **the owner checks them** before they are committed.

The six phrases go into `WaterBuddy/AppShortcuts.xcstrings` beside the existing six, `en` and `ru`.
The category is the existing key *Hydration*.

### 3.4 The intent

One new file, **app-only**: `WaterBuddy/TodaysWaterIntent.swift`. The app's synchronized folder gives
it membership; it joins no exception set, and `project.pbxproj` does not change.

```swift
struct TodaysWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Today's Water"
    static let description = IntentDescription(
        "Tells you how much water you've had today in WaterBuddy, and how much is left.",
        categoryName: "Hydration")
    static let openAppWhenRun = false
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    nonisolated static func answer(for snapshot: WaterSnapshot) -> LocalizedStringResource

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        .result(dialog: IntentDialog(Self.answer(for: DataManager.snapshot())))
    }
}
```

- **`perform()` awaits nothing.** It writes nothing, publishes nothing to the watch and re-plans no
  reminder, so it has nothing to hold the process open for — unlike `LogServingIntent`, which awaits
  the watch link and `remindersSettled()`. It carries the explicit `@MainActor` its two siblings
  carry: it needs none, and the three conformances stay spelled alike under the target's default
  main-actor isolation. `static let` throughout, as on its siblings (rule `43-concurrency`).
- **`answer(for:)` is `nonisolated static`** and is the whole decision: *Nothing yet* when
  `currentWater == 0`, *Met* when `snapshot.hasReachedGoal`, otherwise *Under*, with
  `snapshot.currentWater` and `snapshot.remaining` as its figures. A non-`@MainActor` suite reads it,
  so it is a compile-time canary too.
- **Each line is built with an explicit key** —
  `LocalizedStringResource("<key>", defaultValue: "\(water) … \(remaining) …")` — so the catalogue key
  is the positional `%1$lld`/`%2$lld` form of §3.3 (rule `70-privacy`), where a bare interpolated
  literal would key itself `%lld … %lld` and could not carry Russian's word order. The arguments ride
  in the `defaultValue`'s interpolation.
- **Siri resolves the line, not the app.** A `LocalizedStringResource` travels unresolved and the
  system formats it in the requester's language, as it does *Water logged.* — inferred from the
  type's design and the first phrase's behaviour, not from a document. The tests resolve each line
  with its `locale` set to `en`, `ru` and `uz` (§7) and expect grouped figures and the right plural.
  **If Foundation does not group a `%lld` resolved that way**, the plan's first seam shows it, and the
  work stops for the owner before anything else is built: there is no fallback that both groups and
  stays in Siri's language without being decided anew.

### 3.5 The snapshot's two additions

`WaterSnapshot` gains two computed properties, no stored field:

- **`remaining`** — `max(0, dailyGoal - currentWater)`: millilitres still to drink, never negative.
- **`hasReachedGoal`** — `currentWater >= dailyGoal`.

Rule `50-views` puts arithmetic a front door shows on `DataManager` or `WaterSnapshot`, never in the
caller; Siri is a front door that shows *what is left*. They mirror `DataManager.remaining` and
`hasReachedGoal` as `progress`, `progressUnclamped` and `percentage` already do, and a test pins that
the two agree in every case (§7). Both are derivable from the cache alone, the bar for living on a
`WaterSnapshot` (rule `40-widget`). `DataManager.swift` compiles into all four targets, so both widget
builds and the watch run cover the change; no widget or watch file reads the new properties.

### 3.6 The provider

`WaterBuddyShortcuts.appShortcuts` gains a second `AppShortcut` —
`AppShortcut(intent: TodaysWaterIntent(), phrases: [ … §3.2 … ], shortTitle: "Today's Water",
systemImageName: "drop.fill")` — **listed after** *Log a Glass*, so the existing tile keeps its place.
`appShortcuts` stays the one computed `static var` the protocol's builder requires.

## 4. What it touches beyond the intent

- **Storage:** no key, no stored byte, no schema change, and no mutation — rule `20-state`'s mutation
  surface is unchanged. Asking writes nothing.
- **The widget and the watch:** `WaterSnapshot` gains two computed properties neither reads. Their
  view trees, timelines, `AddWaterIntent` and `WristModel` are unchanged.
- **Reminders:** none. Nothing the answer does can move the plan.
- **Entitlements, exception sets, privacy manifests, `Info.plist`:** unchanged. The first phrase
  needed none of them on the owner's iPhone; the device check here confirms it for a second intent.
- **A background launch:** when the app is not running, Siri launches it in the background and
  `WaterBuddyApp.init()` does its ordinary launch work, as it already does for *Log a Glass*. The
  answer does not wait for any of it.

## 5. What this amends — proposed, for the owner's word

Typed into the rule files unstaged, **before any code**, for the owner to approve as typed.

- **`70-privacy`**, *The lock screen is a public surface*, a new paragraph after the one on *Log a
  Glass*: "**Siri's answer to *Today's Water* may say the user's own figures** — today's total and
  what is left — because the user asked for them, and only to someone the system has authenticated:
  `TodaysWaterIntent.authenticationPolicy` is `.requiresAuthentication`, so a locked iPhone asks
  for authentication before it answers. `theAnswerWaitsForAnUnlock` pins it. Never the streak. A
  figure in any other Siri reply, or this answer given without authentication, needs its own ruling
  here first."
- **`15-project`**, *Membership*: "`LogServingIntent`, `TodaysWaterIntent` and `WaterBuddyShortcuts`
  are app-only and stay out of every exception set: a provider and its intents share a target."
- **`20-state`**, *Clamps and guards*: the streak "never leaves the app: not the snapshot, not a
  notification, not the wrist's mirror" gains "not Siri"; and the line on `remaining`,
  `hasReachedGoal`, `lastDrink` and `nextReminder` gains "`WaterSnapshot` carries `remaining` and
  `hasReachedGoal` too, for Siri's answer; `theSnapshotAgreesWithTheManager` pins the two pairs
  together".
- **`43-concurrency`** and **`85-testing`**: `TodaysWaterAnswerTests` joins both lists of suites that
  are deliberately not `@MainActor`.

Left to `/doc_sync`, not to this amendment: `CLAUDE.md`'s *Two front doors* passage, where Siri now
answers as well as logs; `docs/ROADMAP.md` §8's row for 1.3.4; `docs/STATE.md`, which gains no key.

## 6. Privacy

- **Nothing leaves the device from WaterBuddy.** The intent hands Siri one line. Recognising the
  phrase and speaking the answer are Siri's, under the user's own Siri settings.
- **The lock screen.** No figure is said to anyone unauthenticated: on a locked iPhone the system asks
  for authentication before `perform()` runs (§3.2). The Lock Screen widget the user placed stays the only figure a locked iPhone
  shows (rule `70-privacy`).
- **The streak never leaves the app** (rule `20-state`); the answer carries the day's two figures
  only.
- **No new framework, entitlement or usage description.**

## 7. Testing

Written first, run RED on seams that compile, then GREEN (rule `85-testing`). New file
`WaterBuddyTests/TodaysWaterTests.swift`; a UUID-named suite per test where defaults are touched; each
language's bundle proven to resolve before anything is read from it.

- **`TodaysWaterAnswerTests`** — **not** `@MainActor`, a canary that `answer(for:)`, `remaining` and
  `hasReachedGoal` stay nonisolated:
  - which key the answer takes, and with which figures, at zero, under, exactly at and over the goal;
  - the resolved line, exactly, in `en`, `ru` and `uz`, for each of the three cases — figures grouped
    (*1,450* in English; the Russian and Uzbek separator as `Locale`'s own number format gives it);
  - plural forms: 1 in English (*millilitre*); 1, 2, 5 and 21 in Russian (*миллилитр*,
    *миллилитра*, *миллилитров*, *миллилитр*, with *остался* on 1 and 21); Uzbek's one form;
  - `remaining` and `hasReachedGoal` on the snapshot at zero, under, at and over the goal;
  - the contract: `authenticationPolicy == .requiresAuthentication` (`theAnswerWaitsForAnUnlock`),
    `openAppWhenRun == false`, and the title and description resolve in all three languages.
- **`@MainActor` agreement** — `theSnapshotAgreesWithTheManager`: a throwaway manager (its own suite,
  an in-memory store, every side effect a no-op, an injected clock) taken through zero, under, at and
  over the goal; at each, `DataManager.snapshot(defaults:calendar:now:)` on the same suite gives the
  manager's `remaining` and `hasReachedGoal`.
- **The phrases** — `everyPhraseNamesTheAppInEnglishAndRussian` expects six phrases in each table,
  not three, every one naming `${applicationName}`.
- **The provider** — `WaterBuddyShortcuts.appShortcuts` lists two shortcuts, *Log a Glass* first, if
  `AppShortcut` exposes enough to read; if it does not, the phrase count and the simulator pass are
  the check, and the plan says so rather than writing a test that cannot fail.
- **Not automatable:** Siri, the unlock prompt, and `perform()` itself (#63).

## 8. Verification

### 8.1 The gate

All five invocations, foreground, commands as rule `85-testing` writes them, and the UI suite again
on iOS 26.5.

### 8.2 Warnings

A clean build of the code before and after, into empty DerivedData, compared per file and message.
`DataManager.swift` changes, so every scheme is compared. Expect the app target's
`appintentsmetadataprocessor` step to report a second intent.

### 8.3 On the simulator, then the owner's device

- **Simulator:** the *Today's Water* tile in the Shortcuts app and in Spotlight, `drop.fill`, blue,
  with the device in English and then Russian. Running it is refused there (#63).
- **The owner's iPhone, joining the device checks:** asked unlocked, then locked — what it asks
  for, then the answer; each of the three lines; the device in Russian; after midnight with the app
  not run since; locked with the Apple Watch unlocked on the wrist, with AirPods, and in the car if
  there is one to hand — whether each answers, asks for an unlock, or refuses; and whether the card
  shows the line as written.

## 9. Known limitations, and what is not in scope

- **Siri on the watch** — App Shortcuts from the phone do not run there (WWDC23 10102), as for *Log a
  Glass*.
- **Uzbek phrases** — Siri has no Uzbek; Uzbek users reach the action through Shortcuts and
  Spotlight, where the answer is in Uzbek.
- **The in-app language picker** does not reach Siri or Shortcuts.
- **A pour the watch has not yet delivered** is not counted, as the widget does not draw it (§3.1 C).
- **No snippet, and no value returned to Shortcuts** — either can be added later without changing
  §3.4.
- **What authenticates on a locked iPhone** — an unlocked Apple Watch, AirPods, CarPlay — is inferred
  from Apple's documentation, not stated by it, and device-unproven (§3.2). It may ask for an unlock
  where the user wanted an answer hands-free; that cost is the owner's ruling (§1).
- ***Log a Glass* still replies *Water logged.*** — giving it the total is a separate question.

## 10. Open before the plan

- **D1 — Xcode's rewrite of `WaterBuddy/AppShortcuts.xcstrings`.** The working tree holds an
  unstaged rewrite of this file, and of `WaterBuddyWatch/Localizable.xcstrings` and
  `WaterBuddyWatchWidget/Localizable.xcstrings`, made by the open Xcode app (known issue #50): its
  colon spacing, `extractionState: stale` on two phrases, and empty keys it extracted. This change
  edits the first. For 1.2.6 the owner chose to discard the rewrite first (its D7). The owner says
  whether to do the same here — discarding is the owner's to run or to approve, as the files are not
  this change's. *(2026-10-18: the owner approved the spec and the discard in one reply — "ok" — and
  the three catalogues were restored to `HEAD` with `git restore` before any work. The two scheme
  files and `.claude/settings.json` were left as they were.)*

## 11. Sequence

1. This spec, staged.
2. §10's D1, by the owner.
3. §5's rule wording, typed unstaged, for the owner's approval.
4. The implementation plan.
5. Seams that compile — every new member present with wrong behaviour.
6. The tests in §7, run RED, each failing on its own expectation.
7. The snapshot's two properties, the intent, the provider and the strings — GREEN.
8. The gate (§8.1) and the warning comparison (§8.2).
9. The simulator pass (§8.3).
10. `HISTORY.md` and `/doc_sync`.
11. Staged by explicit path; no commit until the owner's `/commit`.
