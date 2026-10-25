# The store page, retaken for everything built — design

**Roadmap item 1.2.8**, taken again: the store page's 2026-10-18 set shows the redesign of releases
1.2 alone. Since then 1.3 (the widgets, the Lock Screen, the watch's redesign and its faces) and set A
(Premium: the month, Patterns, Insights, the recap) were built, and a Release build now offers the
paywall to every user. Known issues #32, #45, #82 and #88 are this design's subject.

Taken by `/start_task` with no task named, on the owner's choice *Store page* over set B, splitting
`HistoryView.swift` and export (2026-10-25, 01:57).

## 1. What the page shows

**iPhone 6.9″** — iPhone 18 Pro Max, iOS 27.0, 1320 × 2868, ten shots, the most Apple takes, in this
order (the first three are what search results show):

| # | File | Screen | Made by |
|---|---|---|---|
| 1 | `01-home.png` | Home: 65 %, *1,300 of 2,000*, the *5 days* chip | the store harness, free |
| 2 | `02-widgets.png` | The Home Screen: the small and medium Hydration widgets and the week widget | the pair script, by hand |
| 3 | `03-history.png` | History's week, today shown, the *Week · Month · Insights* switch | the store harness, free |
| 4 | `04-lock-screen.png` | The Lock Screen: the ring, the line and the rectangle, and the *Log Water* control in a bottom corner slot | the pair script, by hand |
| 5 | `05-month.png` | Month mode, this month's calendar and figures | the store harness, held |
| 6 | `06-insights.png` | Insights, last week's panes in the app's own sentences | the store harness, held |
| 7 | `07-patterns.png` | Month mode scrolled to Patterns | the store harness, held |
| 8 | `08-recap.png` | The previous month's recap sheet: the card and the best streak | the store harness, held |
| 9 | `09-goal-setup.png` | The welcome's goal step | the store harness, free |
| 10 | `10-settings.png` | Settings' top, the Premium card leading it | the store harness, free |

**Apple Watch** — Series 12 (46mm), watchOS 27.0, three shots:

| # | File | Screen |
|---|---|---|
| 1 | `01-wrist.png` | The watch app, synced from the phone: the vessel at the phone's total, *Synced just now* |
| 2 | `02-face-modular.png` | A face carrying the rectangle and the circle (Modular) |
| 3 | `03-face-infograph.png` | A face carrying the corner and the circle (Infograph) |

Every shot is **raw** — the screen as the simulator draws it, no frame and no headline — English only,
figures and times in `en_US`, the status bar's clock frozen at the run's start in 24-hour form (the
owner's rulings of 2026-10-17 and 2026-10-18, kept).

*Free* means a Release build's free user: the paywall offered, so History draws its switch and
Settings its Premium card. *Held* means a Premium holder. *By hand* means a human places the widgets,
the control and the complications at the script's pauses — XCUITest cannot place a widget.

## 2. Rulings

The owner's, 2026-10-25: the task (*Store page*); the scope — the watch shot, the iPhone four as a
Release build draws them, Premium shots, widget shots; the approach — two DEBUG arguments (§3.1,
§3.2); all four Premium screens — the month, Patterns, Insights, the recap; raw shots and one sentence
for the description (§3.7); all four widget surfaces — the Home Screen, the Lock Screen, the watch
face, Control Center; a new simulator pair per run (§3.5); and then *"do not ask nothing go with
recommendations"*, under which these were taken as recommended:

- **Eleven become ten** by putting the *Log Water* control in a Lock Screen corner slot (iOS 18 and
  later) instead of a Control Center shot of its own, in the order of §1.
- **Two face shots**: no watch face holds the rectangle, the circle and the corner together.
- **The lived-in run builds its week at the sheet's own times**, not on the wheel (§3.4): no shot it
  makes draws a serving's time.

## 3. Design

### 3.1 The seed — `StoreSample`, DEBUG only

History's sheet offers seven days (`DataManager.historyWindow`), so a UI test cannot enter what the
month, Patterns and the recap need: Patterns want seven finished days of the month holding today
(`MonthPatterns.minimumDays`), and the recap a finished month with water on seven days
(`MonthHistory.recap`, `recapDays`). The capture is given its history instead.

- **`WaterBuddy/StoreSample.swift`**, app-only, in no exception set, its whole body inside
  `#if DEBUG`: a `nonisolated enum StoreSample` importing `Foundation` alone, with one function —
  `servings(endingAt now: Date, calendar: Calendar) -> [(at: Date, amount: Int)]`. Pure: no
  `Date()`, no `DataManager`, no store.
- **What it holds**, every amount one of the fresh start's vessels — Cup 150, Glass 250, Bottle 500:
  - **today**: Glass 7:40, Cup 9:15, Bottle 10:50, Glass 12:25, Cup 13:30 — 1,300 ml, the set's figure
    since 1.1;
  - **the six days before**, oldest first: 1,650, 2,000, 2,250, 2,150, 2,500, 2,000 — five met, so the
    chip reads *5 days* — the 2026-10-18 set's week, now at times of day a person drinks;
  - **every day before those, back to the 1st of the month two months before today's** (on
    2026-10-25: 1 August): a weekday day and a weekend day, each in a met and a short form, the short
    form on a fixed share of days, so the month has goal days and misses, the recap a change from the
    month before, Patterns a weekday/weekend difference and a usual serving, and Insights a week before
    to compare with. The exact table is the plan's.
  - **nothing later than `now`**: a serving after it is dropped, so a launch before 1:30 PM never holds
    a future serving.
- Days come from `calendar.date(byAdding: .day, …)` and times from
  `calendar.date(bySettingHour:minute:second:of:)` — never 86,400 seconds (rule `30-rollover`).
- **`-WaterBuddyStoreSample`**, `WaterBuddyApp.storeSampleArgument`. `freshStartManager(arguments:now:)`
  — `now` defaulted to `Date.init`, the composition root's one bare clock — logs every serving through
  `DataManager.addLog(amount:at:)`, the one writer, after building the throwaway manager, **only when
  the fresh start's argument is present too**. Alone it does nothing: a seed can only ever land in the
  fresh start's in-memory store, never in a device's App Group.

### 3.2 The held Premium — DEBUG only

- **`PremiumStore.Source.held()`**, inside `#if DEBUG` in `PremiumStore.swift`: `silent()` with one
  verified lifetime entitlement — the source History's *Month, held* preview builds inline today
  (`HistoryView.swift:3490`), which takes it instead.
- **`-WaterBuddyPremiumHeld`**, `WaterBuddyApp.premiumHeldArgument`. `WaterBuddyApp.init()` builds
  `PremiumStore(source: .held())` in place of `PremiumStore()` when both it and the fresh start's
  argument are present, through a DEBUG static the tests can call. Nothing is bought, verified against
  the App Store or stored: the state is read from the source, in memory, as every run reads it (rule
  `70-privacy`'s *Premium is read, never stored*).

### 3.3 The store harness — `testCaptureAppStoreScreenshots`, rewritten

Two launches, one method. Both pass `-WaterBuddyFreshStart YES -WaterBuddyStoreSample YES
-AppleLanguages (en) -AppleLocale en_US`.

- **Gates**, failing at once and saying why: the local time between 13:45 and 23:45 (today's last
  serving is at 1:30 PM, and a run across midnight would split the week); and **the day of the month
  at least 8**, so this month holds seven finished days for Patterns and the recap is on the previous
  month's page.
- **The free launch** adds `-WaterBuddyPremium` — a Release build's free user. The welcome's goal step →
  `09-goal-setup`; *Continue*, *Continue*, *Not now*. Home's vessel and chip asserted → `01-home`.
  History, today selected, the switch present → `03-history`. Settings, the Premium card first →
  `10-settings`.
- **The held launch** adds `-WaterBuddyPremiumHeld`, walks the welcome with *Not now*, then History:
  *Month* → `05-month`; scrolled to Patterns → `07-patterns`; back one month, *Monthly recap* →
  `08-recap`; closed; *Insights* → `06-insights`, its footer the app's own (*Written by WaterBuddy*).
- No wheel is spun: the seed holds today's five. The census method is untouched.

### 3.4 The lived-in week — `testBuildTheLivedInWeek`, new

The widgets and the watch read the device's own App Group, which the fresh start never opens, so the
seed cannot reach them. A second method of the same class, also skipped by the gate, run only by the
pair script on a new device:

- launches with `-AppleLanguages (en) -AppleLocale en_US` and **no** fresh start, walks the welcome
  with *Not now*;
- builds the same week through History's sheet — the six earlier days' totals, and today's 1,300 as
  the five vessels — each serving at the time the sheet opens on, since no shot draws one; reads each
  day's total back off its button;
- leaves the app on Home. It fails after 23:45, so a run cannot split the week, and needs no
  afternoon: no wheel is spun.

### 3.5 The pair script — `Tools/CapturePairScreenshots.sh`

Replaces `Tools/CaptureWatchScreenshot.sh`, whose dead device, false comments and retired pour button
(#45) it would otherwise carry.

1. Deletes any simulator named *WaterBuddy Store iPhone* or *WaterBuddy Store Watch*, creates them —
   iPhone 18 Pro Max on iOS 27.0, Apple Watch Series 12 (46mm) on watchOS 27.0 — and pairs them. Clean
   by construction (erase is denied, and not needed); the pair is kept for a re-shoot until the next
   run deletes it.
2. Shuts down every other simulator, boots the pair, pins the appearance and text size and freezes the
   phone's status bar, as `CaptureScreenshots.sh` does.
3. Runs `testBuildTheLivedInWeek` on the phone, then installs the watch app — **after** the phone app,
   the order in which the phone's activation publish reaches the watch (`tasks/lessons.md`,
   2026-10-05) — and launches it.
4. Stops, printing five steps for a human in `DeviceHub.app`. Each is shot by its own
   `bash Tools/CapturePairScreenshots.sh shoot <name>` — one `simctl io … screenshot`: the Home Screen
   with the three widgets → `02-widgets`; the Lock Screen with its three widgets and the control →
   `04-lock-screen`; the watch app, *Synced just now* → `01-wrist`; Modular with the rectangle and the
   circle → `02-face-modular`; Infograph with the corner and the circle → `03-face-infograph`. *(The
   plan's first draft paused on `read`; a shot of its own lets the script run where no terminal can
   answer — 2026-10-25.)*
5. Each `shoot` flattens its PNG (`Tools/FlattenPNG.swift` leaves one without alpha alone), then
   runs `Tools/VerifyScreenshots.sh`.

`Tools/CaptureScreenshots.sh` keeps its device and its window and renames its eight shots by the
table's numbers. Neither script deletes the other's files.

### 3.6 What leaves the tree

`Screenshots/en-US/iPhone-6.9/02-history.png`, `03-settings.png` and `04-goal-setup.png` (renumbered),
and `Tools/CaptureWatchScreenshot.sh` (replaced). `Screenshots/census/` stays untracked and untouched.

### 3.7 The sentence for the description

For the owner to paste into App Store Connect's description, which guideline 2.3.2 asks to say what a
featured item costs:

> Month view, Patterns, Insights and the Monthly recap are part of WaterBuddy Premium, an optional
> subscription or one-time purchase. Logging water is always free.

## 4. Tests

Written first and seen RED (rule `85-testing`):

- **`StoreSampleTests`** — not `@MainActor`, a canary for `StoreSample`'s isolation: today's five at
  their times, 1,300; the six days' totals in order; nothing after `now`; every amount a vessel's; the
  first serving on the 1st of the month two months back; the previous month with water on seven days
  or more; a DST day — 2026-11-01 in New York — keeps every serving on its own day.
- **`FreshStartTests`**, made `.serialized` (its tests share the fixed suite): the seed lands only
  with both arguments — through a manager built with a pinned `now`, its total 1,300, its streak 5 and
  its previous month's recap offered; without the fresh start's argument, `freshStartManager` is still
  `nil`; the held source reads `.lifetime`, and the store a free user's without its argument.
- The harness compiles in every gate run and runs only in the two captures. Both methods are new or
  rewritten, so a capture run is their test.

## 5. Rule wording, typed and left unstaged for the owner

- **`85-testing`**: `-WaterBuddyStoreSample` and `-WaterBuddyPremiumHeld`, DEBUG only, effective only
  beside `-WaterBuddyFreshStart`, passed by the store capture alone; the lived-in method and the pair
  script — the one capture that opens a device's own App Group, always on a pair the script made.
- **`15-project`** / **`00-workspace`**: `StoreSample.swift` app-only; `Tools/` gains
  `CapturePairScreenshots.sh` and loses `CaptureWatchScreenshot.sh`.

## 6. Verification

The full gate, five invocations, and the UI run again on iOS 26.5; warnings compared against a clean
build of a `HEAD` export, by file and message. `bash Tools/CaptureScreenshots.sh` in its window, and
`bash Tools/CapturePairScreenshots.sh` with a human at its pauses; every PNG read by eye;
`VerifyScreenshots.sh` green.

## 7. Open, and what only a run shows

- ~~**Whether a Series 12 (46mm) screenshot is a size App Store Connect takes.**~~ *Settled
  2026-10-25, before the script:* its device-type profile's `ScreenDimensionsCapability` reads 416 ×
  496 at scale 2 — the size on `VerifyScreenshots.sh`'s list.
- **Whether installing the phone app on a paired simulator installs the watch app with it**, which
  would reverse the order §3.5 relies on. Probed with the script.
- Lock Screen customisation and Control Center's controls on an iOS 27.0 simulator, by hand —
  expected, not yet done.
- Russian and Uzbek shots and the listing copy beyond §3.7: out of scope, as on 2026-10-17.
