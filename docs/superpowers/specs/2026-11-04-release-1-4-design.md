# Release 1.4, made ready to ship — design

Taken by `/start_task` with no task named, on the owner's choice *Prepare 1.4 to ship* (2026-11-04), then
two rulings asked for up front: **1.4 carries everything on `feature/premium-look`** — Apple Health, set B,
export and *One finish* beside set A — and **the store set is retaken, eight shots and two new ones**, the
schedule sheet and the export sheet. Known issues #82, #193 and #216 are this design's subject.

## 1. Why, and what done looks like

Nothing has been uploaded since 1.1. Since then `main` gained set A, and four stacked branches gained
Apple Health (1.3.3), set B (1.4.3, 1.4.9, 1.4.10), export (1.4.4) and the premium look.
`feature/premium-look` holds all of them: `main`, `feature/apple-health`, `feature/coaching` and
`feature/export` are each its ancestors, and it is 34 commits ahead of `main`.

The listing was written for set A alone. `README.md` says Apple Health "is **not** in it — it was never
built", and the description ends *No Apple Health*. Set B and export appear nowhere. App Review guideline
2.5.1 asks an app that uses HealthKit to name it in its marketing text. `Tools/Support.html` describes the
fixed reminder grid and set A's Premium. The store's iPhone set predates the finish: Insights' lead pane
and Settings' held card look different now.

**Done** is:
- every field the version page asks for, in `README.md`'s *App Store Connect* and in `AppStore/1.4/`,
  true of the build and inside Apple's limits by a count;
- the support page true of the build;
- ten iPhone shots of this build, in upload order;
- one build number for the build that will be uploaded;
- `main` at that tree, by fast-forward, on the owner's word.

What only the owner can do stays theirs, listed in §8.

## 2. Two phases, because of the calendar

The store capture refuses a run before the 8th of a month and outside 1:45–11:45 PM: Patterns need seven
finished days of the month that holds today, and the recap is then on the month before's page
(`AppStoreScreenshotUITests.earliestDay`). Today is the 4th.

- **Phase 1, now:** the text, the pages, the harness's two new shots, and the build number. The gate
  runs, then the owner's `/commit`.
- **Phase 2, from Sunday 8 November, 1:45 PM:** the capture, read by eye, copied into `AppStore/1.4/`,
  and the screenshot tables written. Then the gate on the final tree, the owner's `/commit`, and
  `main`'s fast-forward on their word.

## 3. The store text

`README.md`'s *App Store Connect* stays the master copy. Each field below goes into it and, byte for byte,
into its file in `AppStore/1.4/`, with no trailing newline. Every count is Python's `len` of the file, as
the 2026-10-25 counts were, and is printed again when the file is written.

### 3.1 Unchanged

Name (30/30), subtitle *One tap. No account. No cloud.* (30/30; still true — Health syncs through iCloud
only under the user's own Apple settings, never ours), category, age rating 4+, price, copyright, the URLs,
the EULA, and export compliance.

### 3.2 Promotional text — 161/170

```
One tap logs a glass from your widget, Lock Screen, Control Center or Apple Watch. New: Apple Health, a week widget and WaterBuddy Premium. No account, no cloud.
```

### 3.3 Keywords — 98/100 (D5)

```
drink,intake,reminder,goal,daily,glass,bottle,cup,log,widget,watch,streak,private,h2o,health,habit
```

`thirst` gives way to `health`. Neither the name nor the subtitle carries it, and it is the integration's
own word. Never `apple`: guideline 2.3.7 keeps other companies' marks out of the keywords.

### 3.4 Description — 3987/4000

What changed against the 1.4 text: an *APPLE HEALTH* section; Premium's list gains the schedule, the pace
line with *only when behind*, and export; *PRIVATE BY CONSTRUCTION* names Health and the export file;
*WHAT IT IS NOT* loses *No Apple Health*. To make room: *in 100 ml steps*, *and full history*, and the
reminder section's second sentence go; four lines shorten; the requirements line drops its *.0*s. The
first paragraph is still 170 characters and still the whole pitch.

```
One tap logs a glass - from your Home Screen, your Lock Screen, Control Center or your Apple Watch - and you watch it fill. No account, no server, nothing to sign up for.

A water tracker only earns its place if you are still using it in week three, and the surest way to keep using one is never having to stop what you are doing.

LOGGING
- Three quick-add vessels: Cup 150 ml, Glass 250 ml, Bottle 500 ml, each editable from 50 to 1,000 ml.
- A daily goal from 1,000 to 4,000 ml - or let WaterBuddy suggest one from your weight and how active you are. It keeps neither.
- A vessel of moving water shows today's percentage and the exact millilitres.
- Undo a pour with one tap. Reach your goal and the screen celebrates, and a day streak counts along.

WITHOUT OPENING THE APP
- Home Screen widgets: small and medium, with a button that logs your Glass, and a week widget of your last seven days. The small one also works in StandBy.
- Lock Screen widgets: a ring, a line, and a rectangle with its own button.
- A Log Water control for Control Center, the Lock Screen and the Action Button (iOS 18 and later).
- Siri: say "Log water in WaterBuddy", or ask "How much water today in WaterBuddy". In English and Russian.
- Log a Glass straight from a reminder, without opening the app.

APPLE WATCH
- Cup, Glass and Bottle on your wrist. It works with your iPhone out of range and syncs when it is back.
- Three complications - circular, rectangular and corner - put today's progress on your watch face.

LOOKING BACK
- Your last seven days as bars against your goal, with your average and your best day.
- Every serving with its time. Change an amount or a time, delete a mistap, or add one you forgot.

REMINDERS THAT KNOW WHEN TO STOP
Optional, and off until you turn them on: a nudge every two hours from 9 AM to 9 PM, skipped if you drank in the hour before it, and quiet once you reach your goal. Reminder text contains no numbers: a lock screen is a public surface.

APPLE HEALTH
Optional, and off until you turn it on in Settings: each serving is written to Apple Health as Water, and corrected or deleted there when you change it here. WaterBuddy reads nothing from Health.

WATERBUDDY PREMIUM
Optional extras:
- Month view: every day you have logged, a month at a glance.
- Your patterns: when in the day you drink, weekdays against weekends, your usual first and last drink.
- Personal insights each week, worked out from your own figures on your iPhone. Where Apple's on-device model is available, it can word them, in English. Not medical advice.
- A monthly recap: your month in one card, yours to share as an image.
- Your own reminder schedule: hours, interval and quiet days.
- A pace line on Home, and reminders only when you are behind.
- Export every serving as a CSV file.
Premium is a monthly or yearly subscription - the yearly plan starts with a free week - or a one-time lifetime purchase. Logging water is always free.

PRIVATE BY CONSTRUCTION
No account, no sign-up, no server, no cloud. No analytics, no tracking, no ads and no third-party code: every framework in WaterBuddy is Apple's own, and there is no networking code in it. What you log travels only between your own iPhone and Apple Watch, into Apple Health if you turn it on, and out as a recap image or an export file only when you share one.

MADE TO LIVE WITH
- A dark liquid-glass design over a slowly moving aurora.
- English, Russian and Uzbek, switched inside the app.
- VoiceOver, Dynamic Type, Reduce Motion and Reduce Transparency.

WHAT IT IS NOT
It is not a medical app and makes no health claims. No friends, no feeds, no leaderboards. Water, and nothing else.

Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period, in your Apple Account settings. Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

Requires iOS 17 or later on iPhone; the Log Water control needs iOS 18, and the Apple Watch app watchOS 26.
```

Each claim is checked against the code as the text is written, as the 2026-10-25 text was: the Health
lines against `HealthMirror` and rule `70-privacy`'s *HealthKit, for Apple Health*; the schedule against
`ReminderPlan.Schedule`; *only when behind* and the pace line against `ReminderPlan.due` and `pace`;
export against `ServingsExport`.

### 3.5 What's New — 1060/4000

Still written against 1.1, which is live.

```
WaterBuddy 1.4 - a new look, more ways in, Apple Health and Premium.

- Redesigned throughout: liquid glass over a moving aurora, a calmer Home, History rebuilt around your week, and a new Settings - where figures roll and charts draw themselves.
- A first-run welcome that can suggest a goal from your weight and how active you are - and keeps neither.
- Undo a pour with one tap, and a day streak for the days you reach your goal.
- A week widget for the Home Screen, and the small widget now works in StandBy.
- Three Apple Watch complications - circular, rectangular and corner - and a redesigned watch app.
- Log a Glass straight from a reminder, without opening the app.
- Ask Siri "How much water today in WaterBuddy".
- Apple Health, optional: your servings written to Health as Water.
- WaterBuddy Premium, optional: month view and full history, your patterns, weekly personal insights, a monthly recap to share, your own reminder schedule, a pace line, reminders only when you are behind, and an export of every serving. Logging water is always free.
```

### 3.6 Review notes — 2446/4000

The 1.4 notes gain set B's and export's places, an Apple Health paragraph and the export file. The rest
stands.

```
No account or login is required. On first launch a short welcome asks for a daily goal (it can suggest one from weight and activity level, which it does not keep); the app is fully usable straight after. No demo credentials are needed.

WaterBuddy Premium unlocks Month view, Patterns, Insights and the Monthly recap in the History tab; a custom reminder schedule, "Only when behind" and "Export your servings" in Settings; and a pace line on Home. It is sold through StoreKit as a monthly or yearly auto-renewable subscription (the yearly with a one-week free trial) or a one-time lifetime purchase. Open the paywall from Settings > See Premium, from any locked Premium row in Settings, or from History's locked Month or Insights; Restore Purchases is on the same screen. Logging water is free and never locked.

Premium's screens need some history before they show content. Month view shows at once; Insights and Patterns each say how many days of water they need until they have them. Servings can be added to today and the six days before it with the + in History. Insights appear once the last finished week holds four days with water, Patterns once the month holds seven finished days with water (today is not counted), and the Monthly recap for a finished month with seven days of water - so a new install shows no recap.

Apple Health is optional and off until the user turns on Settings > Apple Health; only then does iOS ask. The app asks to write Water and to read nothing. Each serving is written as a Water sample and corrected or deleted with the serving. No figure the app shows comes from Health.

Insights are decided by the app from the user's own weekly figures. Where Apple's on-device model is available and the app is in English, the model may reword them on the iPhone; otherwise the app's own sentences are shown. Nothing is sent off the device.

The app collects no data and contains no networking code. Everything is stored locally in an App Group container shared by the app and its widgets; the Apple Watch app syncs over WatchConnectivity between the user's own paired devices only. A recap image or a CSV export leaves the device only when the user shares it through the system share sheet.

Notification permission is requested only when the user turns on reminders (in Settings, or on the welcome's last step), never at launch.

Siri, in English: "Log water in WaterBuddy" and "How much water today in WaterBuddy".
```

### 3.7 The in-app purchases' review note

In `README.md` and in `AppStore/1.4/in-app-purchases.md`'s Step 6, the same for all three products:

```
Unlocks Month view, Patterns, Insights and the Monthly recap in History; a custom reminder schedule, "Only when behind" and "Export your servings" in Settings; and the pace line on Home. Logging water is never locked.
```

The products, their names, descriptions and prices do not change: *Every Premium extra* still describes
them.

### 3.8 App Privacy stays *Data Not Collected*

Apple counts data as collected when it leaves the device where the developer or a partner can reach it.
Nothing here does. Two bullets join the section's three:
- **Apple Health**, when the user turns it on, is written on the iPhone into Apple's own store. Health
  syncs it only under the user's own iCloud settings, and nothing reaches us.
- **The export file** leaves only through the system share sheet, on the user's tap, to a destination the
  app never learns.

The questionnaire's *Health* row stays *None*: it asks what is collected, not what is written on the
device.

### 3.9 The build number (D6)

`CURRENT_PROJECT_VERSION` goes from 4 to **5** on all fourteen sites, and `MARKETING_VERSION` stays 1.4.
It is read back from the four built products as `1.4 (5)`. Many trees have been installed on the owner's
iPhone as 1.4 (4) during *One finish*, and the uploaded build should be the one tree with its own number.
Connect accepts any number higher than one it has seen, so 5 is safe whether or not a 4 ever reached it.
The README's *version 1.4 (build 4)* lines and `AppStore/1.4/README.md`'s *Build* row follow.

## 4. `README.md`'s other sections

They describe 1.4 and are wrong about it in three places:
- *What it does* gains an **Apple Health** bullet: optional, written as Water, read never. Its *Optional
  reminders* bullet gains *or on Premium's own schedule*, and its Premium bullet gains the schedule, the
  pace line, *only when behind* and export.
- *Privacy* says `HealthKit` is banned and the App Group is the only entitlement. It becomes: HealthKit on
  the app alone, to write Water only on the user's switch, with `com.apple.developer.healthkit` beside the
  App Group; and data that leaves the device includes Health on the switch and an export file on the tap.
- *App Store Connect*'s opening: *Apple Health (1.3.3) is **not** in it* becomes the list of what 1.4
  carries.

*Screenshots* says *the 8 iPhone shots*, and becomes ten.

## 5. The support page

`Tools/Support.html`, read from the code as it stands, its *Last updated* the day it is written. Each new
answer follows `PRIVACY.md`, which already describes Health, set B and export:
- **Reminders.** *How do reminders work?* names the standard schedule, then Premium's own: the hours,
  the interval, quiet days, and *Only when behind*.
- **Apple Health**, a new section between *Reminders* and *Premium*:
  - *How do I copy my water to Apple Health?* — Settings › *Apple Health*, then iOS asks; WaterBuddy writes
    Water and reads nothing.
  - *A water entry I deleted in Health came back.* — WaterBuddy's log leads; delete the serving in
    WaterBuddy.
  - *A serving I logged from a widget is not in Health yet.* — it is written the next time WaterBuddy opens.
  - *How do I remove WaterBuddy's water from Health?* — Settings › Privacy & Security › Health ›
    WaterBuddy › *Data from "WaterBuddy"*. Turning the switch off deletes nothing.
- **Premium.** *What is Premium?* lists every extra. A new *How do I export my servings?* — Settings ›
  *Export your servings*, a CSV file of date, time and millilitres, sent through the share sheet.
- **Your data.** *How do I delete my data?* adds the copies in Health and any file exported.

The page keeps its shape: one self-contained file, no script, no web font, nothing fetched. The privacy
policy does not change: `PRIVACY.md` and `Tools/PrivacyPolicy.html` were brought up to Health, set B and
export in their own commits (`c446f0a`, `5e58863`, `c8ee254`).

## 6. The screenshots

### 6.1 Two new shots, in the held launch

After `06-insights`, the held launch goes to Settings:
- **`11-schedule`** — the *Schedule* row, scrolled clear of the bar as `CoachingUITests` does, opens the
  sheet; when *Every 2 hours* exists, *Sunday* is tapped once, so a quiet day shows (D4); the sheet has
  landed after `settle`; shot; *Done*.
- **`12-export`** — the *Export your servings* card, scrolled clear of the bar as `ExportUITests` does,
  opens the sheet; when *Share as a CSV file* exists, wait `settle`; shot; *Done*.

The tap on *Sunday* is a holder's own move, written to the fresh start's throwaway suite; no new DEBUG
argument and no app code. `02` and `04` stay the pair script's by-hand slots, so the new two are `11` and
`12`. `Tools/CaptureScreenshots.sh` names ten slugs, and the harness's DocC says ten.

### 6.2 Upload order (D3)

| # | File | Shows |
|---|---|---|
| 1 | `01-home.png` | Home at 65 %, *1,300 of 2,000 ml*, a five-day streak |
| 2 | `03-history.png` | History's week, *Month* and *Insights* locked for a free user |
| 3 | `05-month.png` | Premium: this month's calendar and figures |
| 4 | `06-insights.png` | Premium: last week's insights |
| 5 | `07-patterns.png` | Premium: the month's patterns |
| 6 | `08-recap.png` | Premium: the month before's recap card |
| 7 | `11-schedule.png` | Premium: your own reminder schedule, a quiet day |
| 8 | `12-export.png` | Premium: export, the file shown before it is sent |
| 9 | `09-goal-setup.png` | the welcome's goal step |
| 10 | `10-settings.png` | Settings, the Premium card first |

The first three, which search shows, do not change. The watch's `01-wrist` and the product page header are
kept: neither the watch nor the header changed.

### 6.3 Phase 2's run

On or after the 8th, 1:45–11:45 PM, `bash Tools/CaptureScreenshots.sh`. Every shot is read by eye: the
finish's motion must have stood: the Premium card's lap, Insights' rise, Home's opening water, each sheet's
landing. *One finish*'s plan found `settle`'s 3 s longer than any of its draws (P23); a shot caught
mid-move is the evidence against that, and is taken again with a longer wait. Then
`bash Tools/VerifyScreenshots.sh`, and the ten are copied into `AppStore/1.4/screenshots/iPhone-6.9/`,
renamed `1-home.png` to `10-settings.png`, byte-identical by `shasum`. A run that fails is fixed and run
again in its window, as the 2026-10-25 run was. Its steps are written by reading the existing tests' own
queries, so a first run may need a fix.

## 7. `main`

### 7.1 A branch for the release (D7)

The work is done on **`release/1.4`**, made from `feature/premium-look` at `27aa510`. The four feature
branches stay as they are, locally and on `origin`: deleting them is not this work.

### 7.2 The fast-forward (D8, D9)

After phase 2's `/commit`, and on the owner's word:
```bash
git checkout main
git merge --ff-only release/1.4
git push origin main          # on the owner's word, as every push is
```
A fast-forward because `main` is an ancestor: the history stays the history that was gated, commit by
commit, and no merge commit claims a tree nobody ran. **The gate** before it is the five invocations on
27.0 and the UI suite on 26.5, on the final tree. Any failure that is not already recorded — #191's taps,
#209, #215, the *Undo* offer's speed guard — and that does not pass alone stops the merge.

The six files the tree carries unstaged (`.claude/settings.json`, two schemes, three catalogues) and
`stash@{0}` are not part of it: nothing stages them and nothing pops the stash.

## 8. Still the owner's — blocking the upload

`README.md`'s *Before you submit* and `AppStore/1.4/README.md`'s section 1 list these. The first four were
already there; the last two are new:
- **The privacy policy and support pages live** (#159): `Tools/PrivacyPolicy.html` and `Tools/Support.html`
  published to `SardorAllaberganov.github.io`, `waterbuddy/privacy/` and `waterbuddy/support/`. With 1.4
  carrying Health, the branch's policy is the one to publish. #193's ruling, that `main`'s copies stay the
  1.4 upload's, is superseded by the owner's 2026-11-04 choice.
- **Premium in App Store Connect** (#155): the agreement, the group and the three products, with the review
  note of §3.7.
- **One real purchase** on an iPhone (#156), and the yearly saving read in a comma-decimal region (#162).
- **The HealthKit capability on the App ID**, and a distribution profile carrying it (#192). Without it, the
  upload is refused.
- **Health on a device**: a pour reaching Health from the app, a widget and the watch; refusing it; turning
  it off (#194, #195). App Review may well turn it on.
- *Your call, not blocking:* the Russian and Uzbek drafts — now set B's (#207) and export's (#210) beside
  set A's — and the device sweep (1.2.7).

## 9. Decisions

The owner's, made on 2026-11-04:
- **D1.** 1.4 carries everything on `feature/premium-look`.
- **D2.** The eight shots are retaken, and the schedule sheet and the export sheet are added.

Mine, recommended, for the owner to change at review:
- **D3.** Upload order as §6.2: the new two after the recap, before the welcome and Settings.
- **D4.** The schedule shot quiets Sunday through the sheet itself, so a quiet day shows; the standard
  schedule otherwise. No DEBUG seed: the coaching seed's 5 AM to 11 PM was made for a test, not a picture.
- **D5.** `health` replaces `thirst` in the keywords.
- **D6.** Build 5.
- **D7.** `release/1.4`, from `feature/premium-look`.
- **D8.** `main` moves by `--ff-only` after phase 2, never before: the upload is one tree, text and shots
  together.
- **D9.** The merge's gate is §7.2's, and an unrecorded failure stops it.

## 10. How it is proved

- **Counts:** a script prints every field's length from its file, and diffs each file against its block in
  `README.md`.
- **Claims:** each Health, schedule, pace and export sentence read against the code it names (§3.4).
- **The support page:** opened in Safari, light and dark, at a phone's width; no script, no external
  request (`grep` for `src=` and `http` outside its links).
- **The build number:** `1.4 (5)` read from the four built products.
- **The harness:** compiled by the gate (it is skipped there); run in phase 2's window, its ten shots read
  by eye and passed by `VerifyScreenshots.sh`.
- **The gate:** the five invocations and the UI suite on 26.5, phase 1 and phase 2 each; warnings compared
  by file and message against a clean build of `27aa510`.

## 11. Not in this work

- Any change to the app's behaviour, or to `PRIVACY.md` and its page.
- New store localizations: the listing stays English (U.S.).
- The widget, Lock Screen and watch-face shots: still the owner's 2026-10-26 ruling.
- The flaky UI tests (#191, #209, #215, the speed guard), #221 on 18.6 and *One finish*'s minors
  (#222–#224): each stays recorded, and a separate task.
- Uploading, App Store Connect, the GitHub pages and any push: the owner's.
