# Log from a reminder — design

**Status:** the outline and its two decisions were approved by the owner in conversation on 2026-10-15
("go") — **D1**, a press on a locked phone runs without unlocking, and **D2**, a pending reminder whose
wording differs from what would be filed now is filed again — both as recommended. This document
writes that outline out, with §5's rule wording, for the owner's review **before** the plan and before
any code (`docs/ROADMAP.md` §8). Roadmap item **1.2.4**.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `6010e25` on 2026-10-15. **SDK** is
`iPhoneOS27.0.sdk/System/Library/Frameworks/UserNotifications.framework/Headers/` in Xcode 27.0
(27A266a) on this machine. Claims about how iOS and watchOS deliver and run a notification action come
from a research pass on 2026-10-15, whose report — every source quoted with its URL — is saved as
`research-notification-actions.md` in that session's scratchpad. Each claim below is marked
**stated** (an Apple source says it), **measured** (run on this toolchain), **inferred**, or
**unconfirmed**; every unconfirmed one is either designed so that either answer is safe, or named in
§7. Amended on 2026-10-15, after approval, from three sources: the plan's measurements
(`docs/superpowers/plans/2026-10-15-log-from-a-reminder.md`, P1–P4), the final review, and the
simulator; the build's ledger lists each change.

## 1. What is being built

A *Log a Glass* button on the reminder notification itself. Pressing it logs the user's Glass — the
serving the widget's **+**, the Siri phrase and the Control Center control log — without opening the
app. The product's arc is *log → see → log again without opening the app*; the reminder is the one
surface that asks the user to drink and offers no way to say they did.

It is done when a press logs the Glass's stored amount exactly once; Home, both widgets and the watch
show the new total; the next reminder is re-planned around the drink; and the button's words carry no
digit in English, Russian or Uzbek.

## 2. What happens today

- `NotificationManager.reminderContent(in:)` builds the reminder: a title, a body, the default sound,
  `.active`. It sets no `categoryIdentifier`, so iOS offers no action.
- Nothing in any target registers a `UNNotificationCategory`, conforms to
  `UNUserNotificationCenterDelegate`, or declares a `UIApplicationDelegateAdaptor` (grep, all four
  source folders). A tap on a reminder opens the app through iOS's default; a reminder due while the
  app is open is not shown.
- Reminders are filed by two processes: the app, through `DataManager.requestReminderReschedule`'s
  queue (`ReconcileQueue`), and the widget extension, whose `AddWaterIntent.perform()` awaits
  `NotificationManager.reconcile(...)` itself. Both compose the content through `reminderContent(in:)`.
- `reconcile` skips any slot whose identifier is already pending. `ReminderPlan.horizonDays` is 3, so
  up to 28 reminders (seven hours × four days) sit pending, each with the wording it was filed with.
- `DataManager.language`'s setter writes the key, reloads the widgets and publishes to the watch. It
  does not reschedule, so a language change leaves every pending reminder in the language it was filed
  in, until each fires. Nothing records this.

## 3. The design

### 3.1 What the user sees

A reminder, expanded — long-pressed on the iPhone (on the simulator only swipe-left → *View* opened
one, §7.3), or as Apple Watch shows it — offers one button,
*Log a Glass*, with the Glass's glyph beside its title — **before** it on iOS 27.0 (**measured** on the
simulator, 2026-10-15; this said "after", from a source describing the trailing side). Pressing it
dismisses the reminder (**stated**, WWDC16 707: the action
"will dismiss the notification"; whether it also leaves Notification Center's list is
**unconfirmed**, §7.4). The app does not come forward. The Glass is in today's total the next time any
surface draws it: the widgets at once, through the doorbell `addWater` already rings; the watch through
the mirror the app publishes; Home when the app is next opened.

A tap on the reminder itself still opens the app, as today. Nothing else changes about the reminder:
its title, body, sound, schedule and interruption level stay as they are.

### 3.2 The locked phone, and privacy (D1)

**The press runs without unlocking.** The action is not `.authenticationRequired` (**stated**, *Declaring
your actionable notification types*: without it the action runs while the device is locked). This
follows the owner's standing ruling — logging water is harmless, and the Siri phrase
(`LogServingIntent.authenticationPolicy = .alwaysAllowed`) and the Control Center control
(`AddWaterIntent`, `.alwaysAllowed`) already log without unlocking — and it is what makes the button
work from the wrist: a reminder reaches the watch exactly when the phone is locked (§3.8). Whether
`.authenticationRequired` on a forwarded reminder would ask for the *phone's* passcode is
**unconfirmed**, which would have made it no button there at all.

**What the button says is fixed.** *Log a Glass* — the existing key, the Siri phrase's own title —
carries no digit in any shipped language, and the press says nothing back: no follow-up notification,
no badge, no sound. Rule `70-privacy`'s *The lock screen is a public surface* gains a bullet (§5).

**Before the first unlock after a restart — known issue #72, now reachable from a reminder too.** The
App Group's files and suite are unreadable until that unlock (**stated**: the default protection class
is "complete until first user authentication", and `UserDefaults` silently reads defaults until then).
Whether iOS even shows a reminder, or runs its action, before that unlock is **unconfirmed**. If it
does, the background launch's `DataManager.shared` meets the risk #72 records for the control — and,
being the app's own process, `WaterBuddyApp.init()`'s `prepareSharedStorage()` too. That is not this
change's to fix: the same launch already happens for a Siri phrase or a WatchConnectivity wake. #72 is
widened to say so, and §7.4 checks it on the device. Requiring the passcode would cross the owner's
ruling; declining a press unless the store resolved to the App Group rung is #72's own proposed fix,
its own change.

### 3.3 Where it lives

| File | Target(s) | Change |
|---|---|---|
| `WaterBuddy/NotificationManager.swift` | app, phone widget | the two identifiers; the category; `reminderContent(in:)` sets the category; `PendingReminder`; `reconcile` re-files a pending reminder whose wording differs (§3.7); the seam's pending read carries wording, and a `setCategories` closure |
| `WaterBuddy/ReminderResponder.swift` | app — **new** | the notification centre's delegate (§3.6) |
| `WaterBuddy/LogServingIntent.swift` | app | the three awaited steps of `perform()` move into `logTheGlassInTheBackground()`, which the responder calls too |
| `WaterBuddy/WaterBuddyApp.swift` | app | installs the delegate in `init()` |
| `WaterBuddy/DataManager.swift` | app, phone widget, watch, watch widget | the language setter reschedules; `requestReminderReschedule` registers the category before it reconciles; `AppLanguage.bundle` becomes `nonisolated` (plan P2) |
| `WaterBuddyTests/…` | tests | §6 |

No new string (§3.4), no key, no stored shape, no entitlement, no Info.plist key, no privacy manifest,
no `project.pbxproj` line: `ReminderResponder.swift` joins the app through its synchronized folder, and
no exception set changes. `NotificationManager.swift` stays out of both watch targets. The watch and its
complication are not touched (§3.8).

### 3.4 The button

- **Two identifiers, constants on `NotificationManager`**: `reminderCategoryIdentifier`
  (`"sardor.WaterBuddy.reminderCategory"`) and `logTheGlassActionIdentifier`
  (`"sardor.WaterBuddy.logTheGlass"`). They are not built from `ReminderPlan.identifierPrefix`: that
  prefix names *requests*, and `reconcile` filters the pending set by it; a category or an action is
  another namespace, and a name that began with the prefix would read as a request it is not. The
  category identifier is stored inside every pending request, so renaming it later strands the button
  until §3.7 re-files them — it is permanent in practice.
- **`reminderContent(in:)` sets `categoryIdentifier`**, so a reminder the widget extension files
  carries the button too: iOS looks up the app's registered categories by identifier when it presents
  the notification (**stated**, `setNotificationCategories`' documentation), and an extension files
  under the containing app's identity (`tasks/lessons.md`, 2026-08-28).
- **`NotificationManager.reminderCategory(in:)`** builds it: the category, with one
  `UNNotificationAction` and no category options.
  - **Title:** `bundle.localizedString(forKey: "Log a Glass", …)`. The key already ships in the app's
    catalogue in all three languages (*Log a Glass*, *Записать стакан*, *Stakanni qayd etish*) as the
    Siri phrase's title — the same act in the same words, so one string serves both (rule `50-views`:
    one string per idea). The bundle is a parameter and **never defaulted**, as on `reconcile` and
    `reminderContent` (rule `80-notifications`).
  - **Options:** empty. Not `.foreground` — the point is not opening the app; not
    `.authenticationRequired` (§3.2); not `.destructive`.
  - **Icon:** `UNNotificationActionIcon(systemImageName:)` with the Glass's glyph,
    `vesselSlots[DataManager.usualSlot].symbol` (`mug.fill`) — the control's glyph, from the same
    name for the same slot. iOS 15 and later (**SDK**), so the 17.0 floor needs no version check.
- **The title is resolved only in the app.** Only the app registers the category (§3.5), so the widget
  extension's catalogue needs no copy of *Log a Glass* — the one reminder string in the app's catalogue
  alone. Rule `80-notifications`' "both catalogues" line gains that exception (§5).

**Double Tap.** On an Apple Watch with Double Tap, the gesture "invokes the first nondestructive action"
(**stated**, HIG), so a pinch on a reminder logs the Glass. That is the feature reaching the wrist's
quickest gesture, not a side effect to suppress; §7.4 checks it.

### 3.5 Who registers it

`setNotificationCategories(_:)` replaces the app's whole set (**stated**), and must run in every launch
(**stated**: register "at launch time"; persistence across launches is not documented). The app
registers it **inside the queued reconcile**:

- `ReminderScheduler` gains `setCategories: (Set<UNNotificationCategory>) -> Void`; `live()` calls
  `UNUserNotificationCenter.current().setNotificationCategories` inside its own body, as the other
  closures do.
- **`ReminderScheduler` becomes `nonisolated`** (plan P1). It took the app target's default
  main-actor isolation, so a synchronous closure read off it from nonisolated code warns —
  `reconcile`'s reads of `removePending` and `removeDelivered` did, while its awaited reads did not
  (**measured** at HEAD). `setCategories` is synchronous and read from the nonisolated queue, so it
  would warn too (**inferred** from those lines; not built). With the keyword, a clean build has those
  two warnings fewer and none new (**measured**). `AppLanguage.bundle` becomes `nonisolated` too (plan P2, **measured**), so the queued
  operation can read it once.
- `DataManager.requestReminderReschedule`'s queued operation resolves the bundle once, registers
  `[NotificationManager.reminderCategory(in: strings)]`, then reconciles in the same bundle.

So the button's title is always in the language of the copy filed beside it, in the same ordered pass,
from the one process allowed to file reminders on the group's behalf (`role.mayFileReminders`). It runs
at launch (`init` reschedules), on every foreground (`refresh()`), after every mutation, and — with
§3.7 — on every change of language. Most of those calls register the category it already has, which
replaces it with itself; the reconcile beside each one already calls the centre more than once.

**Never from the extension.** `NotificationManager.reconcile` itself does not register, so
`AddWaterIntent`'s inline reconcile cannot. Whether an extension's `setNotificationCategories` reaches
the app's set is **unconfirmed**, and if it does it would replace it.

### 3.6 The responder

`ReminderResponder` — `WaterBuddy/ReminderResponder.swift`, app-only — is the centre's delegate.

- **Main-actor, unlike `WristLink`.** The class is declared `@MainActor`, as `DataManager` is — the
  target's default, written out. The centre calls
  its delegate on the main thread (**stated**, an Apple DTS answer) — though the design does not rest
  on it: whichever queue the centre calls on, the thunk below hops (review, 2026-10-15) — and the
  responder implements the
  `async` form of `userNotificationCenter(_:didReceive:)` as a main-actor method. Under the app
  target's flags — Swift 5, default isolation `MainActor`, approachable concurrency — the conformance is
  inferred main-actor-isolated and compiles with **no diagnostic**, and the `@objc` thunk hops to the
  main actor, awaits the body, then calls the system's completion (**measured** on a probe, SILGen).
  `@preconcurrency` on the
  conformance warns ("has no effect"), and a `nonisolated` `didReceive` would run the body on the global
  executor and complete off the main thread, which is reported to trip UIKit's main-thread assertion
  (**inferred** from non-Apple reports). `WristLink` is the opposite case for the opposite reason:
  `WCSession` calls its delegate on "a non-main serial queue" (rule `43-concurrency`). Re-proved in
  the real app target while planning: no diagnostic (plan P4).
- **Installed in `WaterBuddyApp.init()`**, beside `WristLink.live.activate()` and after the fresh
  start's early return — so a UI test's fresh start installs nothing. Apple says the delegate "must be
  set before the application returns from `application:didFinishLaunchingWithOptions:`" (**SDK**
  header comment). `App.init()` runs before that; that ordering is **inferred** (SwiftUI must build the
  `App` value before it can read an adaptor declared on it), and §7.3's cold background launch proves
  it. If it does not hold, the fallback is `@UIApplicationDelegateAdaptor` with the install in
  `application(_:willFinishLaunchingWithOptions:)`, Apple's documented place, and this section is
  amended.
- **Held by a `private static let shared`, which `static func install()` hands the centre.** The
  centre's `delegate` is `weak` (**SDK**).
- **What a press does.** One `nonisolated static func logsTheGlass(for actionIdentifier: String) ->
  Bool`, true for `logTheGlassActionIdentifier` alone, decides. For the button, `didReceive` awaits
  `LogServingIntent.logTheGlassInTheBackground()`: the three steps `perform()` already takes — wait for
  the watch link (`WristLink.waitUntilActivated()`, at most a second), log the Glass through
  `logTheGlass(into: .shared, from: DataManager.sharedDefaults)`, await `DataManager.remindersSettled()`
  — moved into one function both doors call. Returning is the completion, after which iOS may suspend
  the launch; Apple names no figure for that time beyond "a short amount" (**stated**, WWDC16 707). For
  any other response — in practice the default action, a tap on the reminder — it returns at once. A
  dismissal never arrives: the category does not set `.customDismissAction`.
- **The Glass is read when pressed**, not when the reminder was filed: `usualServing(in:)`, so a Glass
  edited after filing logs its new amount, as the Siri phrase does. `addWater` re-reads the store and
  rolls the day over first, so a reminder left from yesterday logs into today.
- **No `willPresent`.** Implementing it would start showing reminders while the app is open — a
  behaviour change nobody asked for. Left unimplemented, iOS keeps today's default.

### 3.7 Reminders already filed (D2)

`reconcile` skips a slot already pending **with the wording it would be filed with now** — the title,
body and category `reminderContent(in:)` gives it in the bundle passed — and files again one whose
wording differs. `add` with a pending request's identifier replaces it (rule `80-notifications`
already relies on this), so nothing is removed first and no slot moves.

- **What it is for.** Anyone updating from 1.1 has up to 28 reminders pending with no category. Under
  the current rule they would show no button for up to four days — the release whose notes announce
  the button. With this, the first reconcile after the update — the launch — files them again with it.
- **The same comparison closes §2's language gap.** The language setter now calls
  `rescheduleRemindersNow()`, after the writes and doorbells it already rings; the queued reconcile then
  registers the category in the new language and files every pending reminder again in it. A language
  change moves no slot, so rule `80-notifications`' *Who reschedules* gains the setter as the one
  member that changes wording rather than the plan.
- **The seam.** `ReminderScheduler.pendingIdentifiers: () async -> [String]` becomes
  `pending: () async -> [PendingReminder]`, a `Sendable`, `Equatable` value of the identifier, title,
  body and category, built from a `UNNotificationRequest` by `init(_:)` in `live()` — an initializer
  marked `nonisolated` in an extension, which otherwise took the main actor (plan P3, **measured**).
  `reconcile` filters
  it by `identifierPrefix` before anything else, as now; the remove-only pass still ends on an awaited
  `pending()` round trip. `PendingReminder` lives in `NotificationManager.swift`, beside
  `ReconcileQueue`, because a file of its own would have to join the widget's exception set
  (rule `40-widget`: no seventh file).
- **No churn between the two processes.** The extension composes in `DataManager.shared.language`'s
  bundle, which `addWater`'s `refresh()` re-reads (`loadFromStore()`), and `sharedKeys` holds both
  reminder strings identical in the app's and the widget's bundles in every language — so the two
  processes compute the same wording and neither re-files the other's reminders.
- **What it does not reach:** a reminder already *delivered* — in Notification Center, or shown — keeps
  the wording it had. Only pending requests are re-filed. Its button is another matter: iOS looks the
  category up when it shows the reminder, so one delivered in English before a switch to Russian
  showed *Записать стакан* (**measured** on the simulator, 2026-10-15); one delivered by 1.1 names no
  category, so it has none to look up (**inferred** — every reminder the probe pushed named it).

### 3.8 The watch

No watch code. On a forwarded reminder, the buttons come from the categories **the iPhone app**
registered, and a background action "runs in the background on their iPhone" (**stated**, *Adding
actions to notifications on watchOS*; WWDC16 211 limits watch-side delivery to background actions
"scheduled on the Watch itself"). `WaterBuddyWatch` is a dependent companion app
(`WKCompanionAppBundleIdentifier`, no `WKRunsIndependentlyOfCompanionApp`); nothing found changes
forwarding for an independent one. The iPhone logs; the mirror `logTheGlassInTheBackground()` waits
for the watch link to carry it there. A tap on the reminder's body on the wrist opens the watch app,
as today. Whether the watch draws the action's icon, and what a press does while the watch cannot reach
the phone, are **unconfirmed** (§7.4).

## 4. What it touches beyond the app

`NotificationManager.swift` and `DataManager.swift` are shared. In the widget extension the change is
the content's category and the reconcile's re-file — `AddWaterIntent.perform()`'s code does not change.
Of `DataManager.swift`'s two edits, the registration sits inside `requestReminderReschedule`'s
existing `#if !os(watchOS)` block, beside the queue; the language setter's new call goes through the
injected hook, whose production default returns at once on both watch roles and in the extension
(`role.mayFileReminders`). The phone widget, the watch and the watch widget must still build (rule
`85-testing`'s five invocations).

## 5. What this amends

Typed into the rule files unstaged, for the owner, once this spec is approved — as stages 4 and 5 did.

**`80-notifications`** — *Never clear what you did not name*: "Never operate on the raw result of
`pendingIdentifiers()`" reads `pending()`. *The applier holds no policy*: the remove-only bullet's
round trip reads `scheduler.pending()`, and

```markdown
- Skip a slot already pending **with the wording it would be filed with now** — the title, body and
  category `reminderContent(in:)` gives it in the bundle passed. File again a pending reminder of ours
  whose wording differs: `add` replaces it under the same identifier, so nothing is removed and no
  slot moves. That is how a reminder filed before an update gains the button, and one filed before a
  language change is put into the new language. Never unconditionally re-`add` the whole plan
```

replaces "Skip any slot whose identifier is already pending; never unconditionally re-`add` the whole
plan". *Content*'s "both catalogues" bullet gains: "— except the button's title, *Log a Glass*, which
only the app resolves: it is the Siri phrase's title, the same act in the same words". *Who
reschedules*' list gains "the `language` setter — which moves no slot, but every pending reminder's
wording —". *The applier holds no policy*'s `ReminderScheduler` bullet gains: "It is `nonisolated`:
its closures are called on both sides of the main actor — off it by the app's queue, on it by
`ReminderPermission` — and a synchronous closure read off a main-actor struct from nonisolated code
warns." *Identifiers*' "Every identifier is built from the `identifierPrefix` constant" reads "Every
request identifier", so it does not contradict the button's section. *Who reschedules*' `LogServingIntent` bullet reads
"`LogServingIntent.logTheGlassInTheBackground()` — what `perform()` and the reminder's button both
run — holds the app process open …". And a new section after *Content*:

```markdown
## The button
- A reminder carries one action, *Log a Glass*, in one category. Both identifiers are constants on
  `NotificationManager` — `reminderCategoryIdentifier` and `logTheGlassActionIdentifier`, never a
  literal at a call site, and never built from `identifierPrefix`, which names requests — and
  `reminderContent(in:)` sets the category, so a reminder the widget extension files carries the
  button too
- The category is built by `NotificationManager.reminderCategory(in:)`, whose bundle is never
  defaulted, and registered **only by the app**: `DataManager.requestReminderReschedule` registers it
  through the scheduler's `setCategories`, inside its queued operation, in the bundle it files the
  copy in, before the reconcile. Never from `reconcile` itself, which the extension runs —
  `setNotificationCategories` replaces every category the app has
- The action's options are empty: not `.foreground`, because the press logs without opening the app;
  not `.authenticationRequired` (rule `70-privacy`); not `.destructive`. Its icon is the Glass's glyph,
  `vesselSlots[DataManager.usualSlot].symbol`
- The press is answered by `ReminderResponder`, the app's notification delegate, installed in
  `WaterBuddyApp.init()` and held by its `static let shared` — the centre holds its delegate weakly.
  It logs only for `logTheGlassActionIdentifier`; a tap on the reminder opens the app as it always
  did. It implements no `willPresent`, so a reminder due while the app is open is still not shown
- The press logs the Glass read when it is pressed, through `LogServingIntent.logTheGlassInTheBackground()`
  — the steps the Siri phrase takes — and returns only after it has awaited the watch link and
  `DataManager.remindersSettled()`: returning is the completion, after which iOS may suspend the launch
```

**`70-privacy`** — under *The lock screen is a public surface*, after the control's bullet:

```markdown
- **The reminder's button says nothing either.** *Log a Glass* carries no digit in any shipped
  language — the reminder copy's tests read it too — and its press says nothing back. It runs without
  unlocking, as the Siri phrase and the control do: the action is not `.authenticationRequired`,
  because logging water is harmless, and a reminder reaches Apple Watch exactly when the phone is
  locked. What iOS does with a press before the first unlock after a restart is proved only on a
  device (known issue #72)
```

**`43-concurrency`** — after the two `WristLink` bullets:

```markdown
- **`ReminderResponder` is main-actor, the opposite of `WristLink`.** Everything a press does is
  main-actor work, and the responder implements the `async` `userNotificationCenter(_:didReceive:)`
  as a main-actor method: under this target's approachable concurrency the conformance is inferred
  main-actor-isolated and compiles clean, and whichever queue the centre calls on, the thunk hops to
  the main actor, awaits the body, then completes — so everything a press needs is awaited before the
  method returns. Never `@preconcurrency` on the conformance (it warns, "has no effect"), and never a
  `nonisolated` `didReceive`, which completes off the main thread
```

**`85-testing`** — *A green suite is not proof the product works*, the paragraph on what to do after a
change: "— and put the control in Control Center" becomes "— put the control in Control Center, and,
after a change to reminders, press a reminder's *Log a Glass* with the app not running".

`CLAUDE.md` — the doors paragraph gains the reminder as a fifth way in to the same serving — and the
sheets follow in the docs pass (rule `99-docs-cascade`).

## 6. Testing

Written first and run RED; then GREEN. No new suite: every test joins an existing one, so no rule's
list of suites changes.

- **`NotificationManagerTests`** (not `@MainActor`, and must not become so):
  - the content carries `reminderCategoryIdentifier`;
  - `reminderCategory(in:)` has that identifier, exactly one action with `logTheGlassActionIdentifier`,
    empty action options, and its title is the bundle's *Log a Glass*;
  - `theReminderCopyCarriesNoUserValues` reads the action's title too;
  - a pending reminder of ours in other wording — another title, or no category — is filed again under
    its identifier, and nothing is removed;
  - one in the same wording is left alone (`reconcileIsIdempotent` already pins this; it is kept);
  - a reconcile in Russian after one in English files every pending reminder again, in Russian;
  - `PendingReminder(_:)` reads a request's identifier, title, body and category;
  - `ReminderResponder.logsTheGlass(for:)` is true for the button and false for
    `UNNotificationDefaultActionIdentifier` and `UNNotificationDismissActionIdentifier`.
- **`LocalizationTests`**: the translated-copy test reads *Log a Glass* in the app's bundle, in every
  shipped language, for a digit.
- **`ReminderSeamTests`** (`DataManagerTests.swift`): changing the language hands the hook a plan;
  setting the same language does not.
- **Changed, not new:** the three spies (`SchedulerSpy`, `SharedCentre`, `WelcomeTests`' scheduler)
  answer `pending` with `PendingReminder`s and take a no-op `setCategories`.
- **Not unit-testable, and proved on the simulator instead (§7.3):** the delegate's `didReceive` —
  `UNNotificationResponse` cannot be constructed — the install in `init()`, and the registration in the
  production hook, which every fixture replaces with `{ _ in }` (rule `85-testing`).

## 7. Verification

### 7.1 The gate

Rule `85-testing`'s five invocations on iOS 27.0, and the UI suite again on 26.5, as it stands.

### 7.2 Warnings

Clean builds before (HEAD) and after, compared per file and message. No new line is the bar.

### 7.3 On the simulator

One simulator, through a throwaway XCUITest probe driving SpringBoard, deleted before staging:

1. Turn reminders on in the app and allow notifications.
2. With the app **terminated**, deliver a reminder-shaped notification naming
   `reminderCategoryIdentifier` with `xcrun simctl push`. Expand it in Notification Center: one button,
   *Log a Glass*. Press it. The app does not come forward.
3. Open the app: today's total rose by the Glass, once. Edit the Glass (250 → 400 ml), terminate the
   app, repeat: it logs 400.
4. Switch the app to Russian, terminate it, repeat: the button reads *Записать стакан*.
5. Tap a delivered reminder's body: the app opens, and nothing is logged.

Step 2 is the cold background launch that proves §3.6's install in `init()`. Whether `simctl push`
reaches a background action's response at all is **unconfirmed**; if it does not, the probe build files
a reminder a few seconds ahead through the live centre instead — a throwaway change, never staged.
*(2026-10-15: it does — a pushed reminder's button, pressed with the app terminated, launched it in the
background and logged the Glass once, so the install in `init()` holds and no fallback was needed. On
this simulator a long press never opened a reminder: on a lone one it left the short look, and with
two present it expanded the group. Swiping a reminder left and choosing View opened it with its
button. A tap in Notification Center did not open the app, so step 5
was proved on a banner.)*

### 7.4 The owner's device check

Added to the release's device sweep (`docs/ROADMAP.md` 1.2.7), on the owner's iPhone and Apple Watch:

1. Unlocked: press *Log a Glass* on a reminder; the total rises by the Glass on the widgets and, on
   opening, on Home. Is the reminder gone from Notification Center?
2. Locked: the same, without unlocking.
3. On the wrist, the phone locked: press it on the watch; the phone logs, and the watch shows the new
   total. Does the watch draw the glyph?
4. Double Tap, on a watch that has it: the pinch logs the Glass.
5. The watch out of the phone's reach: press it; record what happens, and whether it logs later.
6. **Before the first unlock** (#72): restart the phone, wait for a reminder, press it before unlocking
   if iOS offers it, then unlock and check today's total, today's rows and that reminders are still
   pending. Record whether the reminder was shown at all.
7. An update: with 1.1 installed and reminders on, install the build, open it once, and see the next
   reminder carry the button.
8. VoiceOver reads the button as *Log a Glass*.

## 8. Known limitations, and what is not in scope

- **The Glass only.** A button per vessel, or a choice, was not asked for.
- **No figure, anywhere.** The press says nothing back; the new total is seen on the widgets.
- **A reminder already delivered** before the update, or before a language change, keeps its old
  wording; only pending reminders are re-filed (§3.7). One delivered before a language change shows the
  button in the new language (measured); one delivered by 1.1 shows none (inferred) — §3.7.
- **The button exists once the app has run since the update.** A widget tap before that files
  reminders naming a category this version has not registered yet, so they show no button until the
  app's first launch registers it (presentation-time lookup, §3.4).
- **A reminder left from yesterday logs into today**, as the Siri phrase does when spoken after
  midnight.
- **Before the first unlock after a restart** — #72's open risk, widened to this door (§3.2).
- **What a press does while the watch cannot reach the phone** — one 2018 third-party report says
  background actions queue until it reconnects; **unconfirmed** (§7.4, step 5).
- No `willPresent`: reminders still do not appear while the app is open.

## 9. Sequence

This spec → the owner's review → the plan → the delegate's isolation re-proved in the real target →
RED → GREEN, a part at a time: the seam and the re-file, the button, the language setter, the
responder and its install → the rule wording (§5), unstaged → warnings (§7.2) → the gate (§7.1) → the
simulator (§7.3) → a review of the diff → the docs pass, `HISTORY.md`, staging.
