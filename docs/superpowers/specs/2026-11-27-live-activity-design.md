# Live Activity — today's water on the Lock Screen and in the Dynamic Island — design

Taken on the owner's *"go next"* of 2026-11-27, after Other drinks was committed and pushed: the next item on the roadmap is
1.5.2, *Live Activity*, listed as free and medium (`docs/ROADMAP.md` §6). Written whole for one approval, as the owner prefers:
seven rulings asked (§2), the rest recommended (§11).

## 1. What was asked, and what done looks like

**Said:** go next.

**Taken to mean** (correct anything here):
- The roadmap's next item, 1.5.2: today's progress on the Lock Screen and in the Dynamic Island, updated only when the app or
  one of its intents runs, never pushed, since there is no server.
- Free for every user. Its button is a way of logging, and no way of logging is ever Premium (`docs/ROADMAP.md` §1, *The
  Premium line*).
- It ships in 1.5 (10) beside Other drinks, after 1.4.3 is released.

**Read on 2026-11-27** (`file:line` on `feature/other-drinks` at `de99d6c`):
- **Four widgets, one extension.** `WaterBuddyWidgetBundle` (`WaterBuddyWidgetBundle.swift:14-23`) lists the Home Screen, week
  and Lock Screen widgets and, from iOS 18, the control. Nothing imports ActivityKit, nothing declares an
  `ActivityConfiguration`, and the app's generated Info.plist has no `NSSupportsLiveActivities` (its Health keys are at
  `project.pbxproj:923` and `:964`).
- **Where water changes, by process.**
  - In the app's: Home, History, *Undo*, Settings, a watch's pours (`WristInbox.swift:64`), and two background runs, Siri's
    phrase and a reminder's *Log a Glass*. Both run `LogServingIntent.logTheGlassInTheBackground()`
    (`LogServingIntent.swift:71`), which awaits the watch link and the reminders before it returns.
  - In the widget extension's: both widgets' buttons and the Control Center control run `AddWaterIntent` there
    (`AddWaterIntent.swift`), through that process's own `DataManager.shared`.
- **The app comes forward** in `WaterBuddyApp.body`'s `.onChange(of: scenePhase)` (`WaterBuddyApp.swift:207-222`): `refresh()`,
  Premium, the reminders' permission and Apple Health. `init()` (`:35-91`) builds the manager, Health's mirror, the watch link
  and the reminder's responder, on a background launch too.
- **Apple Health's mirror is the pattern for an app-only owner** (`HealthMirror.swift:26-110`): `@MainActor @Observable`, its
  framework reached only through a `Source` of closures, its passes on one `ReconcileQueue`, built once in `init()`.
- **The Lock Screen widget already shows today there** (`LockScreenWidget.swift:132-212`): the total over the goal and a bar,
  every figure `.privacySensitive()`, a quiet form when `redactionReasons` contains `.privacy`. Its button speaks *Add 250
  millilitres*, or *Log Water* in the quiet form (`:286-292`). Those strings are in the widget's catalogue in all four languages.
- **Rule `70-privacy` forbids a Live Activity today**, in its WatchConnectivity section (`70-privacy.md:49`): *"a notification and
  a Live Activity remain forbidden on both devices, in both directions, with no carve-out of any kind"*.
- **Rule `40-widget`** allows no seventh file in the shared set (`40-widget.md:65`).

**What ActivityKit allows** (Apple's documentation, its forums and WWDC sessions, read by a research agent on 2026-11-27;
sources at the end):
- **Starting.** Only while the app is in the foreground, or from an intent conforming to `LiveActivityIntent` that iOS performs
  in the app's process (Siri, Shortcuts, a control, an interactive widget). The widget extension's own intent cannot start one.
  iOS 26 can schedule a start, but only with an alert; push-to-start needs a server.
- **Updating.** From the app's process, in the foreground or the background. The widget extension does not see the app's
  activities (developers' reports; Apple documents updates from the app only).
- **Lasting.** Eight hours, then up to four more on the Lock Screen. Nothing local restarts it, and nothing local ends it at
  midnight: a stale date is the only signal.
- **Showing.** The Lock Screen, the Dynamic Island and StandBy. iOS also puts it in Apple Watch's Smart Stack (watchOS 11), in
  CarPlay and in the Mac's menu bar (iOS 26) by itself. An app cannot keep it off the watch; from iOS 18 it can give the watch a
  small layout of its own. CarPlay shows no buttons.
- **Buttons.** In the Lock Screen view and the expanded Island, from iOS 17. A `LiveActivityIntent` runs in the app's process.
  Apple's pages disagree on whether a locked phone asks for Face ID first.
- **Privacy.** Apple documents no redaction for Live Activities. iOS Settings has a per-app switch, and *Allow Access When
  Locked* has a *Live Activities* switch whose effect Apple does not describe.
- **Size.** 4 KB of data in all.
- **Apple's guidance.** The Human Interface Guidelines offer Live Activities *"for tasks and events that have a defined
  beginning and end"*, lasting no more than eight hours. App Review's guideline 4.5.3 bans Live Activities used for spam.
  WaterLog, SupaHydrate, WaterFlow and Waterllama ship one.

**Done** is:
- A *Live Activity* switch in Settings, off until turned on, for every user.
- While it is on: today's percentage, total and goal on the Lock Screen and in the Dynamic Island, with a button that logs the
  Glass, following every change the app's process makes.
- The tests written first and green, the gate passed, the walk on the simulator, and the rules, the policy and the docs saying
  so.
- Released in 1.5 after 1.4.3, each outward step on the owner's word.

## 2. Rulings

- **R1 — how it starts.** Recommended: **a switch in Settings, *Live Activity*, off until the user turns it on.** Turning it on
  starts one. While it is on, the app starts a new one whenever it comes forward and none is running: iOS ends each after eight
  hours, and with no server only the app's foreground can start the next. The alternative is starting one by itself after each
  day's first pour, which nobody asked for, and which App Review's spam rule is written against.
- **R2 — what it shows.** Recommended: **the Lock Screen widget's figures and nothing more**: the percentage, today's total and
  the goal.
  - On the Lock Screen: a ring holding the percentage, *1 300 ml* over *of 2 000 ml*, and the button (R3).
  - In the Dynamic Island: a drop and the percentage when compact, the ring alone when minimal, and the Lock Screen's figures and
    button when expanded.
  - No streak, serving, drink, reminder time or vessel name.

  The alternative is the percentage alone, the guidelines' *"innocuous summary"*.
- **R3 — the button.** Recommended: **one button that logs the Glass in the app's own process**, as Siri's phrase does, so the
  activity shows the pour at once and the watch hears it. Its intent conforms to `LiveActivityIntent`, which iOS runs in the app.
  No simulator here can run it (the App Intents daemon refuses an ad-hoc build, as `LogServingIntent`'s DocC records), so the
  owner's TestFlight install is its first proof. The alternative is no button: a picture of today, whose tap opens the app.
- **R4 — when it ends.** Recommended: **it runs for as long as the switch is on**: past the goal, which its figures show, and
  across midnight, where its stale date (the day's end) turns it into an empty new day, as the widgets' midnight entry does.
  Turning the switch off ends it at once; iOS ends it after eight hours, and the app starts the next when it comes forward. The
  alternative is ending it when the goal is reached, a *defined end* closer to the guidelines' words, at the cost of a switch
  that sometimes shows nothing: turned on after the goal, it would show nothing until the next day.
- **R5 — the watch.** Recommended: **a small layout of its own for Apple Watch's Smart Stack**: the ring, the percentage and the
  total. iOS puts the activity there by itself and an app cannot keep it off, though the wearer can. The watch app's own
  complication already shows the same day. The alternative is iOS's default, built from the Island's compact views.
- **R6 — privacy.** Recommended: **rule `70-privacy` amended** to let the Live Activity show the percentage, today's total and
  the goal, because the user turned it on, as the Lock Screen widget may. It shows them on the Lock Screen and in the Dynamic
  Island, and wherever iOS carries it: StandBy, Apple Watch, CarPlay and the Mac. Every figure is marked `.privacySensitive()`,
  and every view draws the Lock Screen widget's quiet form whenever `redactionReasons` contains `.privacy`. Apple documents
  neither for Live Activities, so the sure protections are the user's own: the switch, iOS's per-app setting and *Allow Access
  When Locked › Live Activities*. The privacy policy names it before 1.5 goes on sale. The alternative is R2's: the percentage
  alone.
- **R7 — the version.** Recommended: **1.5 (10), with Other drinks, after 1.4.3 is released.** The alternative is a later
  1.5.x, after Other drinks is out.

## 3. The switch and the content

- **The switch** is `Key.liveActivity`, the phone suite's seventeenth key. Absent and `false` both mean off, as for
  `Key.healthEnabled`. Only the app reads or writes it. `DataManager.liveActivityEnabled` writes the key and nothing else: no
  doorbell, no reschedule and no wrist publish, since nothing outside the app draws it.
- **The content** is a plain value in `DataManager.swift` beside `WaterSnapshot`, Foundation only, so both phone targets compile
  it with no seventh shared file. `LiveWaterAttributes` holds nothing. Its `ContentState` holds today's total, the goal, the
  Glass's amount and glyph, the language's code and the theme's code. It is built from a `WaterSnapshot` by one function, so the
  activity and the widgets cannot round differently, and it is never stored. Encoded, it is a few hundred bytes of the 4 KB.
- **Its conformance to `ActivityAttributes`** is declared in the two files that import ActivityKit (§4, §5), so
  `DataManager.swift` imports nothing new.
- **The stale date** is the day's end, `DataManager.nextDayBoundary(after:calendar:)`: the widgets' midnight.

## 4. Who starts, updates and ends it

- **One app-only owner, `LiveWater`**, in the shape of Apple Health's mirror:
  - `@MainActor @Observable`;
  - ActivityKit only through a `Source` of closures, built by `live()`, with `silent()` for the fresh start and previews;
  - its passes on one `ReconcileQueue`;
  - a `static let shared` the intents can reach.
- **It watches the manager** through Observation: today's total, the goal, the Glass, the language, the theme and the switch. It
  asks for a pass on each change, and `WaterBuddyApp` asks for one each time the app comes forward. So every change the app's
  process makes reaches it: Home, History, *Undo*, Settings, a watch pour, Siri's phrase, a reminder's *Log a Glass*, `refresh()`
  and the day turning.
- **A pure plan decides each pass.** `LiveWaterPlan` is Foundation only, in the shape of `HealthPlan` and `ReminderPlan`. From
  the switch, iOS's permission, whether the app is in the foreground, the activity running (if any) and the content wanted, it
  answers *start*, *update*, *end* or *nothing*:
  - switch off, or iOS's Live Activities off: end the one running, at once;
  - switch on, one running: update it when its content or its stale date differs;
  - switch on, none running: start one, in the foreground only, after removing any ended one still on the Lock Screen.
- **iOS saying no clears the switch.** When the app comes forward and iOS reports WaterBuddy's Live Activities off (its per-app
  setting, or *Don't Allow*), the switch turns off, as the reminders' does when notifications are refused (rule
  `80-notifications`).
- **Background runs update, never start.** Siri, a reminder's button and a watch pour run the app in the background, where iOS
  refuses a start. After the reminders, `logTheGlassInTheBackground()` also awaits the owner's pass before it returns, so iOS
  cannot suspend the launch before the activity shows the pour.
- **What it cannot see.** A pour from the widgets' buttons or Control Center runs in the widget extension, which cannot reach the
  activity. The activity shows it the next time the app runs; the Lock Screen widget beside it shows it at once.
- **The button's intent** conforms to `LiveActivityIntent` and is not discoverable: no Shortcuts action, no Siri, no Spotlight.
  It runs without unlocking where iOS allows, and logs through `logTheGlassInTheBackground()`. It is declared twice under one
  name: the app's copy, which iOS runs, and a copy in the widget extension, there for the button's view to name, whose
  `perform()` does nothing. Declaring it once in a shared file would have `DataManager.swift` call into the widget's code, which
  rule `10-architecture`'s import direction forbids.

## 5. The views — `LiveWaterWidget`, in the widget extension

- **`ActivityConfiguration(for: LiveWaterAttributes.self)`**, listed in the bundle after the Lock Screen widget. It reads only
  the content iOS hands it: never `DataManager.shared`, never a snapshot read, never SwiftData (rule `40-widget`).
- **The Lock Screen**, which iOS also uses for the banner, StandBy's tap, CarPlay and the Mac:
  - the theme's widget aurora behind (`WidgetAurora`: flat, no `Material`, for the widget's reason);
  - the ring in water's colours (`Aurora.classic`: water is water), with the percentage inside;
  - *1 300 ml* over *of 2 000 ml*, in white;
  - the button: the primary surface, drawing the Glass's glyph, at `PourButton.minimumTarget`.
- **The Dynamic Island**, on the system's black:
  - compact: a drop in water's colour and the percentage;
  - minimal: the ring;
  - expanded: the ring, the figures and the button.
- **Apple Watch** (`.small`, iOS 18 and later: the codebase's fourth version check): the ring, the percentage and the total.
- **Stale**, past midnight: the same views with an empty ring and *0 ml*, the goal kept, until the app updates it.
- **The quiet form**, whenever `redactionReasons` contains `.privacy`: the Lock Screen widget's (the drop, *Hydration*, an empty
  ring), with the button saying *Log Water*.
- **The language and the theme** come from the content: its code's bundle and locale and its theme, injected at the root, as
  every widget's are.
- A tap anywhere but the button opens the app.

## 6. Settings

- **A *Live Activity* card** for everyone, after *Smart reminders* and before *Apple Health*. It holds one switch, titled
  *Live Activity*, with its line under it: *Today's water on the Lock Screen and in the Dynamic Island.* When iOS has Live
  Activities off for WaterBuddy, the line says so and the reminders card's *Open Settings* row follows.
- **The switch reads `@Environment(LiveWater.self)`.** Its binding calls the owner, which writes `liveActivityEnabled` and asks
  for a pass, as Apple Health's switch calls `enable()` and `disable()`.

## 7. What leaves the app

- **No server, no push, no token.** The activity is requested with no push type, so ActivityKit never hands the app an APNs
  token.
- **Only R2's figures,** on the user's switch, to the surfaces R6 lists. No diagnostic carries a figure (rule `75-diagnostics`).

## 8. The words

- **Reused, from the widget's catalogue:** *Today's hydration*, *Hydration*, *%1$d ml*, *of %1$d ml*, *Log Water*, *Add %1$d
  millilitres*, and the vessel's spoken sentence.
- **New, in the app's catalogue, in four languages:** the card's title, *Live Activity*; its line; and the line for iOS's
  refusal. *Live Activity* and *Dynamic Island* take the names Apple uses in Russian and Spanish. Uzbek, which iOS is not
  translated into, takes the wording the app's other iOS terms already use.
- **Reviewed by a second agent**, as Spanish was.

## 9. How it is proved

- **Tests first** (rule `85-testing`):
  - `LiveWaterPlanTests`: pure, not `@MainActor` (a canary); every answer of §4's plan.
  - `LiveWaterContentTests`: pure; the content from a snapshot, its figures equal to `WaterSnapshot`'s, the stale view's empty
    day, and a round trip through JSON under 4 KB.
  - `LiveWaterTests`: `@MainActor`, through a recording `Source`:
    - the switch starting it and ending it;
    - a pour, an *Undo*, the goal, the Glass, the language and the theme each updating it once, and an unchanged pass updating
      nothing;
    - a background run updating it and never starting one;
    - iOS's refusal clearing the switch;
    - `logTheGlassInTheBackground()` returning only after the update.
  - `LiveActivityUITests`: on the DEBUG fresh start with a silent source, Settings' switch is one element with its title and line.
  - `LocalizationTests`: the new keys in every language.
- **The gate:** all five invocations, the UI suite on 27.0 and 18.6, and no new warning.
- **The walk on the simulator**, which shows Live Activities (iPhone 17 has the Island):
  - turn it on;
  - the Lock Screen and the Island's three forms in light and dark, in each theme, in Russian and Spanish, at the default and the
    largest text size, and under Reduce Transparency;
  - a pour from Home and from History, an *Undo*, a goal change, a theme change, a language change and a watch pour, each followed
    on the activity;
  - the white figures' contrast measured on each theme's renders (rule `65-accessibility`);
  - the switch turned off, ending it.
- **On a device, by the owner from TestFlight:**
  - the button's press, also on a locked phone;
  - StandBy, Apple Watch's Smart Stack and CarPlay;
  - the stale view after midnight;
  - whether iOS asks *Allow* under the first activity.

## 10. The order of the work

1. The rules' wording (§12), typed for the owner.
2. The tests, run RED.
3. The switch and the content in `DataManager.swift`; `LiveWaterPlan`.
4. `LiveWater` and the app's intent; `WaterBuddyApp`; `logTheGlassInTheBackground()`.
5. `LiveWaterWidget` and the extension's intent; the bundle; `NSSupportsLiveActivities`.
6. Settings' card; the words, reviewed.
7. GREEN; the gate; the warnings compared by file and message.
8. The walk; the contrast tables.
9. The policy, the docs and the records, staged for the owner's `/commit`.

## 11. Decisions

- **D1.** One activity at a time. Its attributes hold nothing; everything is in its content.
- **D2.** ActivityKit in two files, `LiveWater.swift` (the app's) and `LiveWaterWidget.swift` (the extension's). The content in
  `DataManager.swift`, Foundation only.
- **D3.** The button's intent declared twice; the extension's copy is never run (§4).
- **D4.** One owner, in the shape of Apple Health's mirror, watching the manager through Observation; a pure plan.
- **D5.** Starts in the foreground only; background runs update.
- **D6.** iOS's refusal clears the switch, read each time the app comes forward.
- **D7.** The stale date is the day's end; past it, an empty day.
- **D8.** The widget extension's pours reach it when the app next runs.
- **D9.** `Key.liveActivity`, absent for off, written by `DataManager` alone.
- **D10.** On the widget aurora: water's colours for the ring, white figures, the button the primary surface. Contrast is measured
  on each theme's renders. Where a figure falls short, it stands on the widget's archived pane, as the Home Screen widget's
  figures do, never on a heavier shadow.
- **D11.** A tap on the activity opens the app on Home.
- **D12.** No Siri phrase starts it in 1.5 (§15).
- **D13.** The spec is the plan, as for Other drinks: §10's order, in the main loop, tests first.

## 12. The rules this needs

- **`70-privacy`:** the WatchConnectivity section's ban keeps notifications out and lets the phone's Live Activity in on R6's
  terms; a new section, *The Live Activity, on the user's switch*: what it shows, where, the quiet form, no push type, ActivityKit
  in two files.
- **`40-widget`:** a fifth widget, the Live Activity, in its own file: it reads only its content, its button's intent runs in the
  app, the stale view, the watch's layout behind iOS 18.
- **`10-architecture`:** ActivityKit's two files; `LiveWater` beside the other app-only owners; the forbidden list.
- **`15-project`:** `NSSupportsLiveActivities` on the app target's two configurations; the new files' membership; the fourth
  version check.
- **`20-state`:** `liveActivityEnabled` joins the mutation surface.
- **`25-shared-storage`:** `Key.liveActivity` and its absence; seventeen keys, in rule `10-architecture`'s count and
  `CLAUDE.md`'s table too.
- **`30-rollover`:** the activity's stale date and its empty day.
- **`43-concurrency`:** `LiveWater`'s shape; `LiveWaterPlan` `nonisolated`; the intent's `perform()`.
- **`50-views`:** Settings' card and its switch.
- **`60-design-system`:** a section, *In the Live Activity*.
- **`65-accessibility`:**
  - the figures one element: label *Today's hydration*, value the vessel's sentence;
  - the button its own: *Add 250 millilitres*, or *Log Water* in the quiet form;
  - the Island's compact and minimal forms one element each;
  - the switch in the shape of the *Apple Health* switch.
- **`85-testing`:** the new suites, the fresh start's silent source, and the proofs only a device can give.

## 13. Risks

- **Apple's framing.** An all-day tracker stretches the guidelines' *"defined beginning and end"*. Each activity still lasts at
  most eight hours, starts only on the user's switch and ends at once when the switch goes off. If App Review objects, R4's
  alternative, ending at the goal, is the fallback.
- **The button cannot be pressed on a simulator here**, and Apple's pages disagree on a locked phone. The owner's TestFlight
  install is the first proof.
- **A widget's pour lags** on the activity until the app runs (D8).
- **After eight hours, a gap** until the app comes forward again. iOS keeps the ended activity's last figures on the Lock Screen
  for up to four hours, and the app cannot choose that dismissal.
- **Redaction is undocumented**, so the quiet form may never be drawn.
- **iOS may ask *Allow*** under the first activity, and may slow frequent updates. A pour updates it once.

## 14. Yours, or mine on your word

- Approving this spec, or changing a ruling.
- The rules' wording (§12), staged for your `/commit`.
- The device checks in §9, from TestFlight.
- 1.5's release steps, each on your word, as for Other drinks.

## 15. Not in this work

- **A Siri phrase that starts it.** The guidelines suggest one, and Siri's phrases are in `AppShortcuts.xcstrings`, which holds
  your own uncommitted edits.
- **Push updates**, which need a server.
- **Drinks or caffeine on the activity** (1.5.4).
- **The widgets' buttons updating it.** They would have to run in the app's process: a change to `AddWaterIntent` and to rule
  `40-widget`.

## Sources

- Displaying live data with Live Activities:
  `https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities`
- `LiveActivityIntent`: `https://developer.apple.com/documentation/appintents/liveactivityintent`
- Adding interactivity to widgets and Live Activities:
  `https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities`
- A scheduled start (iOS 26):
  `https://developer.apple.com/documentation/activitykit/activity/request(attributes:content:pushtype:style:alertconfiguration:start:)`
- The Human Interface Guidelines, Live Activities: `https://developer.apple.com/design/human-interface-guidelines/live-activities`
- Live Activities on Apple Watch (WWDC24): `https://developer.apple.com/videos/play/wwdc2024/10068/`
- App Review Guidelines, 4.5.3: `https://developer.apple.com/app-store/review/guidelines/`
