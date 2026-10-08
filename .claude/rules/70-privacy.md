---
description: No network, no analytics, no account — and nothing on a lock screen the user did not consent to
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "Entitlements/**", "WaterBuddyWatch/**/*.swift", "WaterBuddyWatchWidget/**/*.swift"]
---

# Privacy

WaterBuddy has no account and no server. Everything it knows stays in one App Group on one device.
That is a property to defend, not a phase.

## Nothing leaves the device
- Import no networking, analytics or sensor framework: `URLSession`, `Network`, `CoreLocation`,
  `HealthKit`, `CloudKit`, `StoreKit`, `AdSupport`, `AppTrackingTransparency` — and no third-party
  SDK (rule `95-dependencies`)
- Keep `com.apple.security.application-groups` the only entitlement on either signed target. Adding
  any other capability requires a written justification in this file first
- Add no `NS*UsageDescription` key to any Info.plist. The project carries zero, and notification
  authorization is the only permission this product ever asks for

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
  apps' own screens — with two named carve-outs: the watch's own complication, on the watch's own
  face, and the phone's own Lock Screen widget, on the phone's own Lock Screen.**
  `WaterBuddyWatchWidget/WaterBuddyWatchWidget.swift` renders a percentage derived from the
  stored `WristMirror` as an `.accessoryCircular` complication, which is a wire-derived value
  reaching a surface other than `WristView`'s own screen — but it is the exact precedent the phone
  side already permits for its own Home Screen widget (`WaterBuddyWidget`, drawing from
  `WaterSnapshot`, which is itself the phone's own non-screen surface for the identical class of
  state). The underlying protection is unchanged and still absolute: a notification and a Live
  Activity remain forbidden on both devices, in both directions, with no carve-out of any kind — this
  amendment only recognises that each device's own face-level complication was always meant to sit
  beside its device's own Home Screen widget as the one sanctioned "outside the app's own screen,
  inside the device's own ambient surfaces" reading, and the original wording simply never said so.
  The phone's Lock Screen widget joined it in
  `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`: `currentWater` counts pours the
  watch authored, so the total it draws is wire-derived too, and it is held to the marking *The lock
  screen is a public surface* sets out
- **No third framework rides in behind it.** `HealthKit`, `CoreLocation` and `CloudKit` remain
  banned by name, and a watch app is exactly where someone will propose all three.

Approved by the owner: `docs/superpowers/specs/2026-08-31-waterbuddy-watchos-design.md` §14 records
the explicit ruling ("§9's `70-privacy` amendment is approved as written") that made this text live
policy rather than a draft, closing that document's own §9.3.

## The lock screen is a public surface
- Never put a water total, a goal, a serving size, a percentage, or **any digit** into a
  notification `title` or `body`. Compose a reminder only from the fixed, digit-free keys
- `theReminderCopyCarriesNoUserValues` asserts `!text.contains { $0.isNumber }` over
  `title + " " + body`. Never narrow it to a substring or key check
- Any new reminder string must be digit-free in **every** shipped language and in **both** bundles —
  extend the translated-copy test, never bypass it
- Request exactly `[.alert, .sound]`. Never add `.badge`, `.provisional`, `.criticalAlert`, or
  `.providesAppNotificationSettings`
- Never add an entitlement to unblock a feature: keep `interruptionLevel = .active` rather than
  `.timeSensitive`, and **state the resulting cost** — batched delivery in the Notification Summary —
  in the settings copy rather than hiding it
- Ask for authorization only from the `set` branch of the reminders toggle, where the user has just
  asked for reminders. Never at launch, never from the setup screen, never from a `.task`
- Never store `remindersEnabled = true` on a refused authorization; set it from the grant result and
  clear it when the system state reads `.denied`
- Touch only identifiers carrying `ReminderPlan.identifierPrefix` (rule `80-notifications`)
- Siri's reply to *Log a Glass* is a public surface held to the same standard: one fixed, digit-free
  `IntentDialog`, no user value, in every shipped language — `theSiriReplyCarriesNoUserValues` asserts
  it as `theReminderCopyCarriesNoUserValues` does. `LogServingIntent.authenticationPolicy` is
  `.alwaysAllowed` on purpose: logging water on a locked phone is harmless, and the reply says nothing
- **The phone's Lock Screen widget may show the user's own figures** — the percentage, today's
  total, the goal — because the user put it there, as the watch's complication may on the watch
  face; a notification may not, because it arrives unasked. In return, every view that draws a
  figure carries `.privacySensitive()`, and every shape draws a quiet form — the drop, an empty ring
  or bar, *Hydration* — whenever `redactionReasons` contains `.privacy`, so a user who turns off
  *Allow Access When Locked → Lock Screen Widgets* sees no figure until the phone unlocks, as iOS
  hides a notification's preview. The quiet form speaks no figure either: its elements carry their
  label alone, and its button says *Log Water*
- Never add an entitlement to hide the Lock Screen widget harder. The Data Protection entitlement
  would hide every widget in the extension while locked and give it no runtime — the Home Screen
  widget would go blank in StandBy — and *Nothing leaves the device* already forbids a second
  entitlement without a written justification here

## Diagnostics carry no user data
- A `#if DEBUG` diagnostic may name the failing condition and the App Group identifier only — never
  an amount, a goal, a timestamp, a log id, or a language code's surrounding user context
- Prefer returning a structured outcome the caller can act on over logging. `ReconcileOutcome` is the
  reporting channel for `reconcile`; do not add a `print` or `Logger` beside it (rule `75-diagnostics`)

## The user's data is theirs
- Delete a serving through `DataManager.deleteLog(_:)` — or `resetDailyProgress()` for today — never
  by writing the cache directly, and keep `resetDailyProgress()` scoped to today's rows only

## Localization

- Route every user-facing string through `@Environment(\.strings)` and
  `bundle.localizedString(forKey:value:table:)`. No view, intent or notification composer may read
  `Bundle.main` for copy
- Write every literal as `Text("…", bundle: strings)`. Where an API has no bundle parameter
  (`Label(_:systemImage:)`, `Button(_:action:)`), use the closure form
- Inject `\.strings` and `\.locale` together at every root — never one without the other
- The widget takes its language from `entry.snapshot.language`, never `Bundle.main` or the device
  locale
- The watch takes its language from `WristMirror.languageCode`, through `WristModel.language`,
  injected at `WristRoot`. `nil` — the phone set to *Follow device* — and the time before the first
  mirror both resolve the watch's own `Bundle.main`. The complication's `.description` is resolved by
  WidgetKit and follows the watch's system language
- The product ships exactly `en`, `ru` and `uz`. Never add a case to `AppLanguage.selectable` without
  shipping the matching translations in **all four** `Localizable.xcstrings` files, and keep
  `knownRegions` in step
- Keep the four catalogues separate — `WaterBuddy/`, `WaterBuddyWidget/`, `WaterBuddyWatch/` and
  `WaterBuddyWatchWidget/`. A string catalogue is not shareable through a `membershipExceptions` entry
- `WaterBuddy/AppShortcuts.xcstrings` holds Siri's phrases in English and Russian only — Siri has no
  Uzbek. It is the one catalogue exempt from shipping all three; the intent's own strings live in the
  app's `Localizable.xcstrings` in all three
- Every key in `sharedKeys` must resolve to the identical value in both bundles, in every language.
  Add any new widget-drawn or widget-filed string to it. The watch's copies of phone strings are held
  to the same standard: `LocalizationTests` compares them against the app bundle in every language
- Give every key an explicit `en` value so a real `en.lproj` is emitted, and keep the
  deliberately-English-only list short and argued
- Use positional format specifiers (`%1$d`, `%2$@`) in every key, never bare `%d`, and never drop or
  invent one in a translation
- Store "follow the device" as the **absence** of `Key.language`, never the string `"system"`, and
  reject `"system"` in `AppLanguage(code:)`
- Fall back to `.system` / `Bundle.main` for an unrecognised code, and say so only under `#if DEBUG`
- Name each language in its own script and untranslated (`English`, `Русский`, `O‘zbekcha`);
  translate only *Follow device*
- Never read a `.xcstrings` file off disk with `#filePath` in a test — assert against the built
  bundle via `Bundle.main`, `PlugIns/WaterBuddyWidgetExtension.appex`, `Watch/WaterBuddyWatch.app`
  and its `PlugIns/WaterBuddyWatchWidget.appex`
- Keep `.configurationDisplayName` and `.description` bare static literals with no interpolation, and
  never name the serving amount there
