# Set B, to be coached — design

**Status:** written for the owner's review, 2026-10-30. Taken by `/start_task` with no task named, on the
owner's "go" to the recommendation *design set B*. The owner ruled four questions in conversation, each the
recommended option: **three items now, the workout-aware goal later** (D1); **what you set keeps working on a
lapse** (D2); **a share per reminder** for the pace (D3); **locked rows in Settings** for a free user (D4). Every
other decision below (D5–D13) is a recommendation for the owner to change at review. **The written spec is
approved** (2026-10-30, "go"), D5–D13 as recommended. No code is written until the plan is approved and the rule
wording in §3.12 is approved as typed (roadmap §8).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`. Where
this spec and a rule disagree, the rule stands until the owner approves §3.12's amendment.

**Provenance.** Every claim about the repository was read at `feature/apple-health`'s HEAD `470a469` on
2026-10-30, with nothing staged. Line numbers are that commit's.

## 1. Where this sits

Roadmap §5, release 1.4 — Premium. Set A, *to understand*, is built and on sale in code. Set B, *to be
coached*, is the roadmap's second set: **1.4.3, a custom reminder schedule; 1.4.9, a pace line; 1.4.10, remind
only when behind**; and 1.4.11, the workout-aware goal, "once it can be built". Three earlier sessions chose
other work over it. Nothing a free user can do today moves behind it (*The Premium line*, roadmap §1).

**1.4.11 is not in this spec (D1).** It needs Apple Health to *read* workouts — a second HealthKit permission
and `NSHealthShareUsageDescription`, on a branch that is write-only by design — and a per-day goal that the
widget, the watch, the streak and History would all have to agree on. It gets its own design later; set B goes
on sale with three features.

## 2. What exists today (measured)

- **The plan is pure** (`ReminderPlan.swift`, Foundation alone). `ReminderPlan.hours` is a fixed grid,
  `[9, 11, 13, 15, 17, 19, 21]` (:43). `slots(enabled:currentWater:dailyGoal:lastDrink:now:calendar:horizonDays:)`
  (:109) drops a slot for two reasons only — today's goal reached, and a drink less than `quietAfterDrink`
  (an hour) before it — and never moves one. The horizon is three days beyond today; `7 × 4 = 28` pending
  requests, under iOS's 64 (:66–73). A slot's identifier is `prefix + dayOrdinal + "." + HH`, whole hours (:90).
- **Two processes plan.** The app files through `DataManager.requestReminderReschedule`; the widget extension's
  `AddWaterIntent.perform()` files `DataManager.shared.currentReminderSlots()` itself, awaited
  (`WaterBuddyWidget/AddWaterIntent.swift:136`). Both plan from what their own `DataManager` read out of the App
  Group suite (`DataManager.swift:1746–1761`). **Whatever the plan reads must therefore be in the suite** — a
  plan input held only in the app's memory would make a widget tap re-file a different schedule.
- **Premium is one status for every set, and never stored.** `PremiumAccess.Status` (`free`, `monthly`,
  `yearly`, `lifetime`; `isPremium`), read by views as `premium.state.status?.isPremium == true`. `PremiumStore`
  is app-only and writes no key (`PremiumStore.swift:17–21`); the privacy policy says so in so many words:
  *"Never stored: whether you have Premium"* (`PRIVACY.md:75`). The widget and the watch cannot know.
- **Who reads the hours.** `nextReminder` (`DataManager.swift:629`), the first of today's slots, drawn by Home's
  quiet line (`HomeView.swift:542`) and History's strip mark (`HistoryView.swift:2875`); the welcome's bells,
  `WelcomeView.bellTimes(in:)` over `ReminderPlan.hours` (`WelcomeView.swift:609`). Nothing on the watch or in a
  widget reads a reminder.
- **Settings' reminders card** (`SettingsView.swift:175`): the *Smart reminders* toggle, whose hint and
  explanation both spell *every two hours from 9 AM to 9 PM* (:208, :227–237), and *Open Settings* when iOS
  blocks notifications. Settings' order: Premium, Goal, Servings, Reminders, Apple Health, Language, the policy.
- **Home's status** (`HomeView.swift:487`): the title2 *1,200 ml to go* / *Goal reached*, then the 44-pt quiet
  line — *Next reminder* · *Last drink*, or *Undo* for eight seconds after a pour. `HomeColumn` gives the vessel
  whatever height is left (:937).
- **The paywall lists every shown set's features as one flat list** under *See how you really drink, and what
  would help.* (`PaywallView.swift:259–265`). Settings' Premium card previews each feature that has a caption,
  three abreast (`SettingsView.swift:530–562`); at the accessibility sizes they stack.
- **A reminder says nothing of the user**: *Time for water* / *A glass now keeps you on track for the day.*, the
  same for every slot (`NotificationManager.swift:191`).

## 3. The design

### 3.1 What the user sees

**A Premium user**, in Settings' reminders card, finds two new rows under the explanation:

- **Schedule** — *9 AM – 9 PM, every 2 hours* (and *· not Sat, Sun* when there are quiet days). It opens a sheet:
  *First reminder*, *Last reminder*, *Every* (1, 2 or 3 hours), the seven *Days*, and *Standard schedule*. Each
  change is saved as it is made and re-plans the reminders at once.
- **Only when behind** — a switch, its line: *Skips a reminder when you've already drunk your share for its hour.*

On Home, between *1,200 ml to go* and the quiet line, **the pace line**: *On track*, or *150 ml behind*. It is
drawn while something is due and the goal is not reached; it moves on the hour, when a new share falls due.

**A free user** sees the same two rows, each with a lock. *Schedule* opens the paywall; turning *Only when
behind* on opens the paywall. Home is unchanged. The paywall lists set B's three features after set A's four.

**A user whose subscription lapses** (D2) keeps what they set: the schedule still fires, *Only when behind* still
skips. The rows lock — the schedule can no longer be edited, *Only when behind* can no longer be turned on — and
the pace line leaves Home. Turning an extra **off** is always free: under a locked custom schedule Settings offers
*Use the standard schedule*, and the switch turns off for anyone.

### 3.2 Decisions

| # | Decision | Status |
|---|---|---|
| D1 | Set B is 1.4.3, 1.4.9 and 1.4.10; 1.4.11 waits for its own design (§1) | **The owner's** |
| D2 | On a lapse, what the user set keeps working; editing it and the pace line are the extras that go quiet; turning an extra off is free. Nothing about Premium is stored, so `PRIVACY.md`'s *Never stored* line stands. Cost: a month's subscription buys a schedule that lasts — the vessel library's lapse rule (roadmap 1.4.8) | **The owner's**; "off is free" is this spec's |
| D3 | The pace is **a share per reminder**: by a reminder's hour, `goal × k ÷ n` is due, where `k` counts the schedule's hours at or before it and `n` is their number. One function for both features (§3.4) | **The owner's** |
| D4 | A free user sees locked rows in Settings' reminders card, which open the paywall; Home shows a free user nothing new | **The owner's** |
| D5 | **The schedule's shape:** a first and a last reminder at whole hours from 05:00 to 23:00, the last on the grid (first + k × every); *every* 1, 2 or 3 hours; up to six quiet weekdays — at least one day keeps its reminders; never across midnight | Recommended |
| D6 | **The horizon shrinks with the schedule** so that `slots a day × (horizon + 1) ≤ 64`; every schedule the menu offers keeps today and at least two more days | Recommended |
| D7 | **Two keys** — `Key.reminderSchedule`, a positional `[Int]` of four, and `Key.onlyWhenBehind`, a `Bool`. Absence means the standard schedule and off; choosing *Standard schedule* removes the key | Recommended |
| D8 | *Schedule* is always on the reminders card — it shapes the pace as well as the reminders; *Only when behind* only while reminders are on and not blocked. The schedule is edited in a sheet | Recommended |
| D9 | The pace line is its own line on Home, between the status and the quiet line, for Premium alone — never in the quiet line, which *Undo* replaces for eight seconds | Recommended |
| D10 | Set B joins the paywall's list. Settings' Premium card keeps its three previews: set B's features carry no caption | Recommended |
| D11 | The code is built on `feature/coaching`, made from `feature/apple-health` — Health's rule wording and keys are its base — so set B ships with or after Apple Health | Recommended |
| D12 | The welcome keeps the standard bells: before setup nobody has chosen a schedule | Recommended |
| D13 | One new UI test class holds Premium through DEBUG's fresh start and `-WaterBuddyPremiumHeld`, to prove the sheet's controls (amends rule `85-testing`, which keeps that argument for the store capture) | Recommended |

### 3.3 Approaches considered

- **A — the schedule as a stored setting, and the plan and the pace as pure functions of it (chosen).** Every
  process that builds a `DataManager` reads the schedule and the switch from the suite, so the app and a widget
  tap file the same plan; `ReminderPlan` stays pure and the grid stays a grid.
- **B — a free set of hours** (any hours, tapped on a dial). More expressive, but a 19-hour dial is a hard
  control on a phone and harder still for VoiceOver, its validation is a set rather than three numbers, and the
  roadmap names *hours and interval*. Rejected.
- **C — the app plans, the extension only removes.** A widget tap would drop the slots it silenced from the
  pending set instead of re-planning, and need no schedule. Rejected: the pace needs the grid anyway, a day-turn
  tap could not plant tomorrow, and two planning paths that can disagree are what the shared files exist to
  prevent.

### 3.4 The pieces

**`ReminderPlan.Schedule`** — a new pure value in `ReminderPlan.swift`, so it reaches the widget extension and
both watch targets through the exception sets they already have; no seventh file, no `project.pbxproj` edit.

```swift
struct Schedule: Equatable, Hashable, Sendable {
    let first: Int                 // 5...22
    let last: Int                  // first + k × every, ≤ 23, k ≥ 1
    let every: Int                 // 1, 2 or 3
    let quietWeekdays: Set<Int>    // Gregorian weekdays, 1 = Sunday; at most six
    static let standard: Schedule  // 9, 21, 2, []
    var hours: [Int]               // first, first + every, …, last
    var horizonDays: Int           // min(ReminderPlan.horizonDays, 64 ÷ hours.count − 1)
    init?(first:last:every:quietWeekdays:)   // nil outside D5
    init?(stored: [Int])           // [first, last, every, quietMask]; nil on any anomaly
    var stored: [Int]
    // The sheet's moves, each returning a valid schedule: with(first:), with(last:), with(every:) —
    // the last snapped down to the grid — and toggling(weekday:), which keeps one day on.
}
```

`ReminderPlan.hours` stays, as `Schedule.standard.hours`, so the welcome's bells and the pinning test keep their
one spelling. The menu — which first hours, which last hours for a first and an interval — is a `static` on the
sheet's view (rule `50-views`: a menu belongs to the screen that offers it), checked against `Schedule`'s
validation by a test.

**The plan** — `slots(…)` gains `schedule:` and `onlyWhenBehind:`, defaulting to `.standard` and `false` so
every existing call and test reads as before; `DataManager` passes both explicitly. Inside the loop:

1. today is skipped once the goal is met (unchanged);
2. **a quiet weekday plants nothing** — the weekday of the planted day on the injected calendar;
3. for each hour of `schedule.hours`: a fire at or before now is skipped (unchanged), a drink within the hour
   drops it (unchanged), and **on today only, with `onlyWhenBehind`, a slot whose share is already covered —
   `currentWater ≥ due(at: its fire)` — is dropped**;
4. the horizon is `schedule.horizonDays` unless a caller passes one (`nextReminder` passes 0).

Since `due` grows through the day, the slots *Only when behind* drops are always a run at the front of today's:
"you're ahead until 15:00, so the next reminder is 17:00". Nothing is moved. A drink still drops at most one
slot, because no interval on the menu is shorter than `quietAfterDrink`.

**The pace** — `ReminderPlan.due(goal:schedule:at:calendar:) -> Int`, the one definition: the hours of the
instant's day whose fire is at or before it, `k`, and `(goal × k + n ÷ 2) ÷ n` — rounded to the nearest
millilitre in `Int`, and exactly the goal when `k = n`. The plan calls it at each slot's fire; Home calls it
now. `ReminderPlan.pace(water:goal:schedule:now:calendar:) -> Pace?` wraps it for a screen: `nil` while nothing
is due or the goal is reached, `.onTrack` when the water covers the due amount, `.behind(Int)` otherwise. The
pace runs every day, quiet ones included: quiet days silence reminders, not the goal.

**`DataManager`** — stores and serves the two settings; decides nothing about Premium.

- `Key.reminderSchedule` and `Key.onlyWhenBehind` — `Key.all` 14 → 16, the phone's suite 12 → 14.
- `reminderSchedule: ReminderPlan.Schedule` — its setter writes `stored` (or removes the key for `.standard`)
  and reschedules; `onlyWhenBehind: Bool` — writes and reschedules. Neither rings the widget doorbell or
  publishes to the wrist: nothing either draws reads them (`remindersEnabled`'s shape, `DataManager.swift:511`).
- `nonisolated static func resolveReminderSchedule(in:) -> Schedule` — `object(forKey:) as? [Int]` through
  `Schedule(stored:)`; any anomaly is the standard schedule, never a repaired one (`resolveServings`' rule).
- Both read in `init` and re-read by `loadFromStore()` behind equality guards, so the extension's long-lived
  `DataManager.shared` plans from what the app last wrote — `addWater` refreshes first, as it does today.
- `reminderSlots(horizonDays:)` passes both; `currentReminderSlots()` uses `schedule.horizonDays`.
- `var pace: ReminderPlan.Pace?` — computed on read, stored nowhere, beside `remaining`; `access` on the inputs,
  as `nextReminder` does.

**Settings** (`SettingsView.swift`, app-only)

- The reminders card gains *Schedule* (D8), *Use the standard schedule* (only for a non-Premium user whose
  schedule is not the standard), and *Only when behind* with its line. The binding to *Only when behind* writes
  `false` for anyone and `true` only for Premium; for anyone else, turning it on opens the paywall and leaves it
  off.
- The explanation and the toggle's hint keep their 9-to-9 sentences for the standard schedule — the strings, the
  catalogues and the store capture's match on *A nudge every two hours* do not move — and say *at the hours of
  your schedule* for any other (§3.8).
- `ReminderScheduleSheet` — a new app-only file: the four controls and *Standard schedule*, under the shared
  `SheetCloseButton`, presented with `.sheet(item:)` (rule `50-views`). The days in the app's locale's order,
  as the month grid's are (rule `30-rollover`); a discs row in `.glassGroup()`, each a toggle, and the last day
  still on cannot be turned off.

**Home** (`HomeView.swift`) — the pace line, a third child of `status`, inside its own
`TimelineView(.everyMinute)`, drawn when `premium.state.status?.isPremium == true` and `manager.pace != nil`, in
the quiet line's measured style: footnote medium, full white, `legibleOnBackdrop()`, a glyph before the words.

**Premium** — `PremiumSet.coached`, features `.schedule`, `.pace`, `.onlyWhenBehind`, each with a title, a line
and a glyph (proved to resolve), no caption (D10), on sale once all three are built. The paywall's headline
already says *what would help*; its decorative preview stays set A's.

### 3.5 Failures

- A stored schedule that fails validation is the standard schedule, announced in `#if DEBUG` without its values
  (rule `75-diagnostics`), and covered by a test.
- A failed log read changes nothing here: the plan's water is today's cached total, as now.
- Premium still *checking* at launch draws the rows locked and Home without a pace line — never a flash of
  either the other way.

### 3.6 Concurrency

`Schedule`, `Pace` and the two new statics are `nonisolated` and `Sendable`; `ReminderPlanTests` stays the
canary (no `@MainActor`, no `UserNotifications`). The sheet's menu statics are `nonisolated`, because a
non-`@MainActor` test reads them (rule `43-concurrency`). No new `Task`; the setters reschedule through the
existing queue.

### 3.7 Accessibility

- *Schedule* is one button — label *Schedule*, value the summary in words, *Premium* added to the value while
  locked (History's switch does the same).
- *Only when behind* is one switch, its line as the hint, on the `Toggle` itself.
- In the sheet: each picker one element with its label and the hour as value; *Every* one control; each day one
  button — label the weekday's full name, `.isSelected` while it keeps reminders; *Standard schedule* one button.
  The heading carries the header trait; close is *Done*.
- The pace line is one element — label *Pace*, value *On track* or *150 millilitres behind* from a `%d` key with
  plural forms, while it draws a `%@` figure (Home's status line's rule).
- Tap targets 44 pt by `minHeight`; the days row scrolls rather than shrink a disc below 44
  (`ViewThatFits`, rule `65-accessibility`).

### 3.8 The words

English below; Russian and Uzbek drafted for the owner's sweep, with plural forms where a count meets a noun
(rule `70-privacy`'s *Localization*). App-only — no widget or watch catalogue changes, nothing in `sharedKeys`.

- Settings: *Schedule*; *%1$@ – %2$@, every hour* / *every %3$d hours*; *not %1$@*; *Use the standard schedule*;
  *Only when behind*; *Skips a reminder when you've already drunk your share for its hour.*; *A nudge at each
  hour of your schedule, skipped if you drank in the hour before it. Reaching your goal silences the rest of the
  day.* and its Notification Summary twin; the hint *Reminds you to drink at the hours of your schedule*.
- The sheet: *Schedule*, *First reminder*, *Last reminder*, *Every*, *Days*, *Standard schedule*, *Done*.
- Home: *On track*; *%1$@ ml behind*; spoken *%1$d millilitres behind*; *Pace*.
- The paywall: *Your own reminder schedule* — *Your hours, your interval, your quiet days*; *A pace line* —
  *Where you should be by now, on Home*; *Reminders only when behind* — *A nudge only when you need one*.

**The reminders themselves do not change**: the same digit-free title and line for every slot.

### 3.9 Project and signing

No entitlement, no usage key, no exception-set change, no new framework. One new app-only Swift file,
`ReminderScheduleSheet.swift`; the widget and the watch compile `ReminderPlan.swift` and `DataManager.swift`
as they do now.

### 3.10 Privacy and the policy

Nothing new leaves the device and nothing about Premium is stored (D2). `PRIVACY.md` and
`Tools/PrivacyPolicy.html` change together, before release:

- *Stored* — the reminders row adds *your reminder schedule and whether reminders come only when you're behind*;
- *Held by iOS* and *Notifications* — *up to 28* becomes *up to 64*, and *a fixed daily schedule* becomes *the
  standard daily schedule, or one you set*; *only when behind* joins the reasons a reminder is skipped;
- *Worked out when shown* — adds the pace;
- *Premium* — the list adds the three features.

### 3.11 What does not change

The notification's copy, category and button; identifiers (whole hours); `quietAfterDrink`; the goal's
silencing; the widgets, the control, the Lock Screen, Siri, the watch and its faces; `WaterSnapshot` and
`WristMirror`; the welcome (D12); History, but for its strip mark following `nextReminder` as it already does.
The App Store's Home screenshot gains the pace line the next time it is captured with Premium held — not this
change's capture.

### 3.12 What it amends in the rules (typed unstaged, for the owner, before any code)

- **`80-notifications`** — the grid is the standard schedule or the user's own; a quiet weekday plants nothing;
  a third reason to drop a slot, *Only when behind*, today only, from `ReminderPlan.due`; the horizon shrinks
  with the schedule, so *"The code clamps nothing"* becomes *"`Schedule.horizonDays` clamps it, and a test
  sweeps every schedule the menu offers"*; whole hours keep the identifier's shape.
- **`20-state`** — `reminderSchedule` and `onlyWhenBehind` join the mutation surface (write and reschedule, no
  doorbell, no wrist publish); `pace` joins the values computed on read.
- **`25-shared-storage`** — the two keys; absence means the standard schedule and off; the schedule discarded
  whole on any anomaly.
- **`10-architecture`** and **`CLAUDE.md`** — fourteen keys; Premium still never stored — a lapse keeps what
  the user set.
- **`30-rollover`** — a quiet weekday is read on the injected calendar; its order on screen is the locale's.
- **`15-project`** — `ReminderScheduleSheet` is app-only and stays out of every exception set.
- **`50-views`** — the schedule sheet's `.sheet(item:)`; the pace line's place on Home.
- **`65-accessibility`** — §3.7's elements.
- **`43-concurrency`** and **`85-testing`** — any new canary suite in both lists; D13's UI class.

### 3.13 Testing, first

Each seen RED before its code (rule `85-testing`).

- **`ReminderPlanTests`** (the canary): the standard schedule's hours are today's seven; a plan with the
  standard schedule and the switch off equals today's plan, swept through a day; every menu schedule stays
  ≤ 64 and plans at least three days; a quiet weekday plants nothing and leaves the others; *Only when behind*
  drops only today's slots, only a run at the front, and none when nothing is drunk; a slot whose share is
  covered by exactly its amount is dropped; one drink still drops at most one slot for every interval; `due` is
  0 before the first hour, the goal at the last, never decreasing, and the same instant gives the same figure on
  a DST day; `pace` is `nil` before anything is due and after the goal.
- **`ReminderScheduleTests`** (new, not `@MainActor`): validation at each edge of D5; `stored` round-trips; every
  anomaly — the wrong arity, an hour off the grid, all seven days quiet — is `nil`; snapping the last hour when
  *every* changes; the sheet's menus offer only valid schedules.
- **`DataManager`** (`@MainActor`): absent keys read as the standard schedule and off; a stored schedule is read
  back; a corrupt one is the standard; the setters write their key alone and reschedule; *Standard schedule*
  removes the key; `refresh()` picks up a schedule another instance wrote; `currentReminderSlots()` and
  `nextReminder` follow the stored schedule and switch; `pace` agrees with `ReminderPlan.pace`;
  `readingLeavesTheStoreUntouched` and the key roster gain the two keys.
- **`PremiumSetTests`**: two sets, both on sale; each new glyph resolves.
- **UI** (D13): for a free user, *Schedule* and *Only when behind* each open the paywall and each is one element;
  holding Premium, the sheet's controls are one element each and a change of schedule shows in the row.

## 4. Verification

- The full gate — five invocations, one simulator at a time, `-parallel-testing-enabled NO` — and the UI suite
  on iOS 26.5 too; warnings compared by file and message against a clean build of the branch's base.
- **The walk**, by hand or by scratch XCUITest on a throwaway simulator: set a schedule and a quiet day, and see
  *Next reminder* and History's mark follow; turn *Only when behind* on, pour past a share, and see the next
  reminder move to a later slot; pour from the Home Screen widget and see the custom slots kept (the next
  reminder on Home after returning); the pace line through an hour's turn; a free user's locks and the paywall;
  *Use the standard schedule* after a lapse (StoreKit's local configuration, an expired monthly); VoiceOver on
  each new element; the largest text size on the sheet and on Home; contrast of the pace line on the aurora.
- **Device-only**, to the device sweep: a reminder arriving at a custom hour on a locked iPhone and on the watch.

## 5. Open, for the owner

- D5–D13 above, each a recommendation.
- The Russian and Uzbek drafts, at the sweep.
- When `feature/apple-health` and set B merge, and in which version.

## 6. Refinements made while planning (2026-10-30)

Found while writing `docs/superpowers/plans/2026-10-30-coaching.md`; each is the recommended option, for the
owner's review with the plan.

- **D8, refined: both rows stand on the card wherever set B is shown**, *Only when behind* included while
  reminders are off — setting it ahead is harmless, and a UI test cannot turn reminders on without iOS's
  permission prompt, so a switch shown only then could never be proved one element.
- **The rows are absent where the paywall is not offered**, `PremiumAccess.gate(status:offered:)` — History's
  switch's rule (`HistoryView.offersMonth(status:offered:)`). An ordinary DEBUG run, and every UI test but
  `PremiumUITests` and `CoachingUITests`, sees the reminders card as it is today.
- **§3.7 and §3.8: *Every* is three buttons** — *Every hour*, *Every 2 hours*, *Every 3 hours* — each one element
  with `.isSelected`, the welcome's choice pattern; there is no *Every* heading. The locked switch's hint is
  *Opens Premium*.
- **§3.12 names ten rule files** — `15-project` among them — and `CLAUDE.md`; this spec's first summary said
  nine.

## 7. Refinements from the walk and the final review (2026-10-31)

Each taken as the recommended option during the run, for the owner's review; every one is in the ledger.

- **W1 — the pace hides once every share is due.** From the last reminder hour to midnight, *behind* is
  exactly the *to go* Home's status already draws (seen on the walk at 23:34: "2 000 ml to go" over
  "2 000 ml behind"). `ReminderPlan.pace` is `nil` once `due == goal`, so §3.1's and §3.4's "otherwise on
  track or behind" now reads "while some share is still to come". Cost: a schedule ending at 17:00 shows no
  pace line from 17:00. `thePaceIsNothingOnceEveryShareIsDue`.
- **W2 — the sheet's hour rows stack at the largest sizes.** One line broke *First reminder* into syllables
  and *09:00* across two lines; each row now chooses between a one-line menu and one with the hour under its
  title (`ViewThatFits` over whole menus). Seen fixed on the re-walk.
- **Important 1 — the horizon counts reminder days.** A quiet day uses none of it: a Thursday plan with
  Friday to Sunday quiet files Monday to Wednesday, where it had filed nothing after the weekend. Today always
  counts, so a horizon of 0 is today alone; the loop looks at most `7 × horizon` days ahead, and the cap holds,
  since quiet days plant nothing. D6's "today and at least two more days" now means reminder days. Rule
  `80-notifications`' loop-bound line is re-typed, unstaged.
- **Important 2 — the locked switch says what a tap does.** *Opens Premium* only while it is off; a lapsed
  user's switch that is still on hears its own line and turns off for free (D2). One rule,
  `SettingsView.behindTapOpensPaywall(gate:isOn:)`, drives the hint and the binding.
- **Deferred minors, for the owner:** the days row has no scroll fallback for a 320-pt Display Zoom screen
  (§3.7 asked for one); the hour rows' density pair has no stated reason; the sheet's draft never re-reads
  the model; the row speaks abbreviated weekdays; the last day still on gives no reason it will not turn off;
  the pace line's transition is unscoped; a lapsed switch has no end-to-end UI test.
