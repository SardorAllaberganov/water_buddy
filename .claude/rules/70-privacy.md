---
description: No network, no analytics, no account — and nothing on a lock screen the user did not consent to
globs: ["WaterBuddy/**/*.swift", "WaterBuddyWidget/**/*.swift", "Entitlements/**"]
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
- The product ships exactly `en`, `ru` and `uz`. Never add a case to `AppLanguage.selectable` without
  shipping the matching translations in **both** `Localizable.xcstrings` files, and keep
  `knownRegions` in step
- Keep the two catalogues separate — one in `WaterBuddy/`, one in `WaterBuddyWidget/`. A string
  catalogue is not shareable through a `membershipExceptions` entry
- Every key in `sharedKeys` must resolve to the identical value in both bundles, in every language.
  Add any new widget-drawn or widget-filed string to it
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
  bundle via `Bundle.main` and `PlugIns/WaterBuddyWidgetExtension.appex`
- Keep `.configurationDisplayName` and `.description` bare static literals with no interpolation, and
  never name the serving amount there
