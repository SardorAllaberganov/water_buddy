# ROADMAP — WaterBuddy

**What this is.** The order in which WaterBuddy grows, release by release, as the owner approved it
on 2026-10-13. It says **what** comes next and **why in that order**. It does not say how anything
is built: every item still gets its own design when its turn comes — a short one in chat if small,
a spec under `docs/superpowers/specs/` and a plan under `docs/superpowers/plans/` if large — and
each design is approved before its code.

**Authority.** Below the DocC on the type being changed, `.claude/rules/` and `CLAUDE.md`. A line
here never licenses a rule change: where an item needs one (§8), the rule stands as written until
the owner approves the amendment's wording in writing, and that approval comes **before** any code.

**Where things stand.** `docs/AI_CONTEXT.md` is the record of what exists; this file is the record of
what is meant to. When an item ships, mark it here with its commits and move on — do not rewrite
the history of an item.

---

## 1. The goal, and the one promise

The owner's goal (2026-10-06): **stand out on the App Store and get users**, with a Plus/Premium
in-app subscription later.

The pitch, which every item below must keep true: **"WaterBuddy never charges you to log water."**
Premium sells extras — never logging. Pricing is monthly, yearly and lifetime — a free week on the
yearly alone; no weekly plans. *(The owner, 2026-10-21: the monthly plan added, $2.99 beside $19.99
a year and $39.99 once; until then this line read "yearly plus lifetime".)*

Why that pitch: a read-only scan on 2026-10-06 of about 430 recent US App Store reviews of six
hydration apps ranked complaints by how often they appeared, and paying to log water was first
(about 65 mentions, across every competitor read). The scan's figures are from that session's
record; the scan itself is not in this repository.

**The Premium line** (the owner's, 2026-10-21). Every Premium item below is held to three lines:
1. **No way of logging is ever Premium** — the app's row, the widget, the watch, Siri, Control
   Center, the reminder's *Log a Glass*, and every drink type 1.5.1 adds.
2. **Premium reads only what the free app already stores.** When a subscription lapses the extras
   go quiet; no serving, setting or figure is lost or hidden.
3. **Everything is worked out on the device** — no server, no account, no location.

## 2. Shipped so far

The first list, approved 2026-10-06 and worked in order:

| Item | Commit | Not done until |
|---|---|---|
| Skip the reminder due within an hour of a drink | `e6aa8ad` | — |
| Keep the watch complication current | `3010338` | the owner's device check, its spec §8.3 |
| Add or fix a serving at an earlier time or day | `9e8e6df` | — |
| Log the Glass by voice with a Siri phrase | `1bedde7` | the owner's device check, its spec §8.3 (#78, closed by observation, cause not found) |
| Today's water on the Lock Screen | `0f4f1be` | the owner's device check, its spec §7.5 |
| Log the Glass from Control Center | `809e848` | the owner's device check, its spec §7.4 |

**Version 1.1** (build 3, `eba1b1e`) was submitted to App Review on 2026-10-09, by the owner's
account; its outcome is not recorded in this repository. Version 1.0 is on the App Store.

**The premium redesign** (`docs/superpowers/specs/2026-10-09-premium-redesign-design.md`) is
committed through stage 3b and is in **no release yet**: stage 1, the glass (`c9ef45d`); stage 2,
Home (`1ced514`); stage 3, History (`e0762ab`); stage 3b, navigation and motion (`7368dec`).
*(2026-10-14: and stage 3c, the look — item 1.2.1 — as `a58b9e6`, committed and pushed on
2026-10-13. Stage 4, Settings — item 1.2.2 — is built and staged, not committed.)*
*(2026-10-14, evening: stage 4 — item 1.2.2 — is committed as `4e70235`, with its plan `c7d2661`,
docs `d58116f` and rule wording `1438122`. **Stage 5, the welcome — item 1.2.3 — is built, gated and
staged, not committed:** spec `docs/superpowers/specs/2026-10-14-welcome-design.md`, plan
`docs/superpowers/plans/2026-10-14-premium-redesign-stage-5.md`.)*
*(2026-10-16: stage 5 — item 1.2.3 — was committed as `d6a3817` (spec and plan), `2af8dbc` (feat),
`026ef71` (docs) and `6010e25` (rule wording). The redesign's stages 1 to 5 are all committed; this
file records no release after 1.1.)*

**The App Store product page header** — new on iOS 27, 3840 × 1646 px — is made and staged, not
committed: `Screenshots/en-US/ProductPageHeader/01-one-tap.png`, *"One tap. Watch it fill."*, from
`Tools/ProductPageHeader.html`. It shows the redesign, so it goes up with 1.2, not before.
*(2026-10-14: committed and pushed on 2026-10-13 as `6499619`, and this file as `2991495`.)*

---

## 3. Release 1.2 — the redesign, on the phone

**Why first.** Nothing built since 1.1 has reached a user. The redesign's own spec says stages 1 to
5 are the phone app and can ship as one version; this release is that version, plus the two small
items that make the first week better.

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 1.2.1 | **Stage 3c, the look** — the glass (**a**), the vessel (**b**), the week card (**c**), a serving's glyph (**g**) | Free | Medium |
| 1.2.2 | **Stage 4, Settings** — the redesign's §7 | Free | Medium |
| 1.2.3 | **Stage 5, the welcome**, with the **goal calculator** in its goal step | Free | Medium |
| 1.2.4 | **Log from a reminder** | Free | Small |
| 1.2.5 | **Rating prompt** | Free | Small |
| 1.2.6 | **Russian plural forms** (#40) | Free | Small |
| 1.2.7 | **Device-check sweep** before submitting | — | Owner's time |
| 1.2.8 | **Store page**: new screenshots and the header | — | Small |

**1.2.1 — Stage 3c.** The four letters the owner marked on 2026-10-11 against the approved canvas.
**Ruled 2026-10-13: the contrast floors hold** — where the canvas's look and a floor collide (the
glass, the glyph, the week's cyan bars), the build gets as near the canvas as it can without any
measured pair falling under its floor, and shows the owner where it lands. Open when paused: which
approach for the glass (**a**) — re-tinting Apple's glass and drawing the lit rim over it, the
canvas's own recipe on every system, or lighter glass with brighter text. #85 — the hand-made pane,
which the shipped 1.1 draws, reads lighter than recorded and several pairs fall under their floor —
is in the same work: its own proposed remedy is to raise that pane's dark scrim.

**1.2.3 — The goal calculator.** The welcome's goal step offers a suggestion from a weight and an
activity level the user types in. Only the chosen goal is stored; the weight is used once and kept
nowhere. No Health access: that is 1.3. *(2026-10-14, stage 5: built — the weight is picked on a
wheel, in kilograms or pounds, not typed, and the activity is one of three choices.)*

**1.2.4 — Log from a reminder.** A *Log a Glass* button on the reminder notification itself, which
logs the usual serving without opening the app — the product's arc, *log without opening the app*,
reaching the one surface it does not reach yet. Its design must answer: the category and action are
registered by the app at launch, while reminders are also filed by the widget extension
(`AddWaterIntent` reconciles), so the content's category identifier lives in the shared
`NotificationManager`; the button's text is digit-free in all three languages (rule `70-privacy`);
and what a press does on a locked phone. *(2026-10-15: built in the tree, awaiting `/commit` and the
device sweep's eight steps (spec `2026-10-15-log-from-a-reminder-design.md` §7.4). Only the app
registers the category, in its queued reconcile; the action is not `.authenticationRequired`, so a
press is meant to run without unlocking, as the Siri phrase and the control do — proved only on an
unlocked simulator; and pending reminders still in the plan are filed again when their words differ,
so ones filed by 1.1 gain the button and ones filed before a change of language are put into the new
language.)* *(2026-10-16: committed as `2d233e1` (spec and plan), `418fad3` (feat), `fcfbc3c` (docs)
and `450d76f` (rule wording); the device sweep's steps still stand.)*

**1.2.5 — Rating prompt.** Apple's own review request, asked at a moment of success (say, a goal
reached on a later day, never in the first session). Apple caps how often it can show. **Needs a
rule change:** `StoreKit` is banned by name in rule `70-privacy` (§8). *(2026-10-15: built in the
tree, awaiting `/commit` and the device sweep (#137). Spec `2026-10-15-rating-prompt-design.md`: asked
about 2.2 s after the user's own pour on Home reaches the goal on the third day in a row, at most
once per app version; only Home's own pour starts the wait, so a goal reached anywhere else never
starts a request; a DEBUG build asks only when launched with the `-WaterBuddyReviewPrompt` argument. Whether it should wait for the eight-second *Undo* offer to end
is open, for the owner (#138).)* *(2026-10-16: committed as `5241030` (spec and plan), `86a44ed`
(feat), `314d63a` (docs) and `52ee815` (rule wording); #137's device check and #138 still stand.)*

**1.2.6 — Russian plurals (#40).** The shared Russian keys use one plural form. The redesign's
streak shows a bare number with no noun until this is fixed (decision D3, 2026-10-09).
*(2026-10-16: the spec is written and staged, for the owner's review —
`docs/superpowers/specs/2026-10-16-plural-forms-design.md`; no plan or code yet. The owner chose to
bring back both counted nouns, the streak's *12 days* and the strip's *5 servings*, and Apple's plural
variations formatted with the app's locale, through a new helper beside `figure`. Built, that locale
would group the figures too, spoken ones included, and with them the widgets' and the watch's,
closing #39.
Open: its D7, whether the three catalogues Xcode rewrote (#50) are committed or discarded first, as
their own change.)* *(2026-10-17: **built, gated and staged — not committed.** Plan
`docs/superpowers/plans/2026-10-17-plural-forms.md`, run inline. D7: the owner chose to discard
Xcode's rewrite. The chip draws *12 days* (*12 дней*, *12 kun*), the count alone where the noun does
not fit; the strip draws *5 servings*, trailing its heading or under it; every figure, spoken ones
and both widgets' and the watch's included, is grouped by the app's locale — closing #40 and #39. The
gate passed on the staged tree, iOS 27.0 and 26.5, before the final review's test-only fix; the unit
suite passed again after it. One open question became known issue #139, by the
owner's decision; what only a device shows joins 1.2.7.)* *(2026-10-18: committed on 2026-10-17 as
`5bc7a0a` (spec and plan), `419868a` (feat), `2451143` (docs) and `9999979` (rule wording).)*

**1.2.7 — The device-check sweep.** One sitting with the owner's iPhone and Apple Watch, before the
1.2 submission, working through every check still open: the complication (its spec §8.3), the Siri
phrase (§8.3), the Lock Screen widget (§7.5), the Control Center control (§7.4), and what stage 3b
left for a device (#116, #120). *(2026-10-14: and what stage 4 left — #129: Settings' step ticks
and language tick, never felt, and the vessels note's Russian name for Control Center.)*
*(2026-10-14, evening: and what stage 5 left — #130: the welcome's haptics; iOS's question about
notifications asked from the welcome, granted and refused; #100(d)'s walk — revoke the permission
in iOS Settings, come back, and see *Next reminder* go; what VoiceOver stops on in the welcome; and
the Russian and Uzbek of its 28 new strings.)* *(2026-10-15: and what 1.2.4 left — #133: its spec
§7.4's eight steps for the reminder's *Log a Glass* — unlocked, locked, on the watch, Double Tap, the
watch out of reach, before the first unlock (#72), an update over 1.1, VoiceOver — and whether a long
press and a tap in Notification Center behave on a device as the simulator did not; and #134's
*Follow device* case.)* *(2026-10-17: and what 1.2.6 left — VoiceOver reading a grouped figure as one
number, *2 000* in Russian and Uzbek, on Home's vessel and History's rows; the chip (*12 дней*) and
the strip (*5 порций*) in Russian on the iPhone; History under VoiceOver, where XCUITest lists hidden
text (#139) — the strip's count, its hour labels and the week card's figures each silent, the
strip's heading focused on itself; the Lock Screen widget's quiet form with *Allow Access When Locked
→ Lock Screen Widgets* off, which the simulator cannot reach without a passcode; the inline Lock
Screen shape, never placed on the simulator; a tinted Home Screen; and the watch's serving rows with a
vessel of 1,000 ml or more, grouped.)* *(2026-10-18: and what the lag fix left — #141(e): the owner
runs the app on the iPhone in Release (*Edit Scheme → Run → Release*) and in Debug, and says whether
the lag is gone; #140: whether a tap on iOS 26 is ever lost on a device.)*

**1.2.8 — Store page.** New iPhone screenshots of the redesign (the owner's 2026-10-09 ruling was
none until the redesign is built), the header, and the pitch in the subtitle or description — not in
the art, where Apple's asset guidance discourages pricing claims. A Russian header too, if the
store listing has a Russian localization. *(2026-10-18: begun and parked for the owner's lag report.
Designed and approved in chat — the same four screens over a lived-in week built through History's
`+`, raw, English only, no listing copy — with rule `85-testing`'s wording typed and unstaged and no
code changed; known issue #142 says where to resume.)* *(2026-10-18, later: **resumed, built,
captured, gated and staged — not committed.** Plan `docs/superpowers/plans/2026-10-18-store-screenshots.md`.
The four iPhone shots are retaken of the redesign over a lived-in week — 65 % today, five of six
earlier days met, a *5 days* chip — in `en_US`, with a 24-hour status-bar clock by the owner's ruling,
since the capture device's own region draws it. The header was already done. Not done: the pitch in
the listing copy — the owner chose screenshots only for this task on 2026-10-17 — and the watch shot,
which waits for 1.3.2.)* *(2026-10-18, evening: committed at 20:33 as `eecb6a7` (the plan), `efa9ed3`
(feat), `4f21510` (docs) and `88d694f` (the rule wording).)*

## 4. Release 1.3 — every surface

**Why second.** The widget and the watch are where the product's *log without opening the app*
arc lives, and they still draw the old look. Apple Health is the integration the competitors read
on 2026-10-06 offer and WaterBuddy does not (that session's record). Siri's question is small, and
sits here beside the other surfaces that answer without opening the app.

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 1.3.1 | **Stage 6, the widget**, plus a **StandBy** layout and a **week widget** | Free | Medium |
| 1.3.2 | **Stage 7, the watch**, plus **rectangular and corner complications** | Free | Medium |
| 1.3.3 | **Apple Health** | Free | Medium |
| 1.3.4 | **Siri: "how much today?"** | Free | Small |

**1.3.1 — The week widget** cannot read SwiftData (rule `40-widget`: the draw path never opens
it), so a week of daily totals must enter the App Group cache as a new key — a change to the stored
shape, cascading to `docs/STATE.md` and the snapshot's read-only tests. *(2026-10-19: **under way, in
three stages.** Spec `docs/superpowers/specs/2026-10-19-the-widget-stage-design.md` and plan
`docs/superpowers/plans/2026-10-19-the-widget-stage.md`, approved with D1–D4, committed in `1899aba`.
**6a**, the pour button on the primary surface, is committed (`5a46609`). **6b**, the small widget
on StandBy's black — the vessel's rim and water, the white disc, and the figure hidden when iOS
asks — is built, gated and staged, not committed. **6c**, the week as `Key.weekTotals` and a medium
*Week* widget that opens History, is next. StandBy itself is for 1.2.7's sweep, known issue #148.)*
*(2026-10-20: 6b committed as `ed77d9f`, its doc sync as `4c796a9`. **6c — `Key.weekTotals`, the *Week*
widget and its link to History — is built, gated and staged, not committed**, the plan's Tasks 3–7.
The owner ruled one test the plan missed, rewritten. The link needs no URL scheme. The week adds a
median 0.42 ms to a widget tap. What only a device shows of it — VoiceOver, a narrow iPhone, a
tinted Home Screen, the morning after, and whether a phone offers the new widget before the updated
app is opened — joins 1.2.7's sweep as known issue #149; the week's two designed edges are #150.)*
*(2026-10-20, later: **1.3.1 is committed whole** — 6c as `fb1af96`, its doc sync as `cdc53da`, the ten
rule files' wording as `06229be`.)*

**1.3.2 — The watch** needs a watchOS 26 or later runtime to render the redesign's watch stage
(decision D6); watchOS 27.0 is installed. The new complication families read the watch's own suite,
as the circular one does. *(2026-10-20: **begun.** Spec
`docs/superpowers/specs/2026-10-20-the-watch-stage-design.md` and plan
`docs/superpowers/plans/2026-10-20-the-watch-stage.md`, approved by the owner: three sub-stages — 7a,
Apple's glass on the watch; 7b, the canvas's screen with a row of three pour buttons; 7c, rectangular
and corner faces beside the circular one, display-only, redacted when watchOS asks. The owner kept D6
as first approved — a watchOS **26** runtime before the stage is measured, so "26 or later" above is
superseded — and that runtime is not yet on this Mac (known issue #77). No code yet; the rule wording
for six files is the plan's first step.)* *(2026-10-20, later: **7a is built, gated and staged** —
Apple's glass on the watch. The runtime never arrived, and the owner withdrew the 26.x half: the stage
is measured and gated on watchOS 27.0 alone, and what 26.x would show is known issue #151. The tint
stays `0.64`; the serving sheet's `.secondary` amounts read 2.83:1 until 7b deletes the sheet.)*
*(2026-10-20, later still: 7a is committed as `90fef5d`. **7b is built, gated and staged** — the
canvas's screen: a vessel that shows the percentage, the millilitre line under it, Cup, the Glass and
Bottle in a row, the sheet gone. On the owner's rulings the 46 mm vessel is 77 pt, not 100 — the
canvas does not fit below the real clock — and the `%` is never under 14 pt bold. Every pair clears its
floor on watchOS 27.0, and each button, pressed in `DeviceHub.app`, pours its own serving. A press
on a device is still owed (known issue #152). 7c, the faces, is next.)*
*(2026-10-21: 7b is committed as `af388da`. **7c is built, gated and staged** — the circle, a
rectangle and a corner, all display-only, each drawing `WristPlan.Face` in the phone's language and
hiding its figures when watchOS redacts. The owner placed all three on simulated watch faces, and
the face turned over at midnight with the app closed. With it **1.3.2 is built whole**; what only a
device shows of the faces — the quiet forms on a locked watch and in Always On, VoiceOver on the
wrist, the corner on a tinted face, the Smart Stack — joins 1.2.7's sweep as known issue #153, beside
#151 and #152.)* *(2026-10-21, later: 7c is committed as `5194121`, its doc sync as `0be24f9` —
**1.3.2 is committed whole.**)*

**1.3.3 — Apple Health.** Each serving written as dietary water, and removed when the serving is
deleted or edited. Whether it also *reads* water other apps logged is the design's first question.
**Needs rule changes** (§8): HealthKit is banned by name; it adds an entitlement beside the App
Group, the only one any target has today; and it needs a usage-description key, where the project
carries none.

**1.3.4 — Siri: "how much today?"** A second Siri phrase that answers with today's total and
what is left. **Needs a rule change** (§8): today every Siri reply is one fixed, digit-free line.
Its design must decide whether it answers on a locked phone. *(2026-10-18: **built, gated and staged
— not committed.** Spec `docs/superpowers/specs/2026-10-18-todays-water-design.md`, plan
`docs/superpowers/plans/2026-10-18-todays-water.md`. The owner ruled that a locked iPhone asks for
authentication before it answers (`.requiresAuthentication`), and that the answer carries today's
total and what is left: *1,450 millilitres so far today — 1,050 millilitres to go.* It reads the
widget's snapshot and writes nothing; a *Today's Water* tile follows *Log a Glass*. What only a
device shows — the unlock prompt, with the watch, AirPods and the car, the three lines spoken, and
Russian — joins 1.2.7's sweep as known issue #146.)* *(2026-10-19: committed at 23:40 on 2026-10-18,
`4a7ece7`..`41309e3`.)*

## 5. Release 1.4 — Premium

**Why third.** It comes after the product looks and feels finished everywhere, so the first thing a
paying user buys is the extras, never the basics. Nothing a free user can do today moves behind it.

**Sold as sets** (the owner's, 2026-10-21). Premium launches as sets, not single features, so the
paywall sells more than one thing: **to understand** — 1.4.2, 1.4.6, 1.4.7; **to be coached** —
1.4.3, 1.4.9, 1.4.10, and 1.4.11 once it can be built; **to make it theirs** — 1.4.5, 1.4.8; and
1.4.4, export. Every item is held to *The Premium line* (§1). Nothing here ships before 1.4.1.
*(2026-10-21, evening, the owner's: **set A, to understand, comes first** and gains **1.4.12,
personal AI insights**; it is built in five steps — 1 the monthly plan, the paywall and the Settings
card as designed (1.4.1, amended); 2 1.4.2; 3 1.4.6; 4 1.4.12; 5 1.4.7 — and goes on sale with the
last, so the paywall never lists a feature that is not built. The design canvas:
https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, private to the owner.)*

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 1.4.1 | **StoreKit subscriptions and the paywall** — monthly, yearly and lifetime | — | Medium |
| 1.4.2 | **Full history and a month view** | Premium | Medium |
| 1.4.3 | **Custom reminder schedule** | Premium | Medium |
| 1.4.4 | **Export** | Premium | Small |
| 1.4.5 | **Themes and app icons** | Premium | Medium |
| 1.4.6 | **Patterns** | Premium | Medium |
| 1.4.7 | **Monthly recap** | Premium | Small |
| 1.4.8 | **Vessel library** | Premium | Medium |
| 1.4.9 | **Pace line** | Premium | Small |
| 1.4.10 | **Remind only when behind** | Premium | Small |
| 1.4.11 | **Workout-aware goal** | Premium | Medium |
| 1.4.12 | **Personal AI insights** — Apple's on-device model | Premium | Medium |

**1.4.1 — StoreKit.** Purchases are verified on the device by StoreKit itself, so Premium needs no
server and keeps the product's *no account, no server* shape. **Needs a rule change** (§8), the
same one as the rating prompt. The streak stays free (the owner's choice, 2026-10-09).
*(2026-10-21: **begun, ahead of 1.3.3, on the owner's choice — half built, staged, paused.** Spec
`docs/superpowers/specs/2026-10-21-premium-foundation-design.md` and plan
`docs/superpowers/plans/2026-10-21-premium-foundation.md`, both approved: the foundation built now and
hidden until the first set (D1); a free week on the yearly plan (D2); our own paywall in the app's
glass and language (D3); the paid state read from StoreKit and stored nowhere. Its `StoreKit`
amendment — two files, named calls, the paywall's moment — is typed into rule `70-privacy`,
unstaged. Tasks 0–5 are built and staged: the decision, the store, the words, 46 tests. Paused at
Task 6 for the privacy policy's URL (known issue #159); App Store Connect's steps are #155, a device
purchase #156.)*
*(2026-10-21, evening: Task 6 built without the URL, on the owner's word, and gated; the owner then
judged its paywall "very poor" on their iPhone and approved a redesign. **Set A's step 1 amends
1.4.1**: a monthly plan, the grace-period ruling, set A declared and not on sale, the paywall and
the Settings card as designed — spec `docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`
and plan `docs/superpowers/plans/2026-10-21-premium-paywall-and-monthly.md`, both approved, no code
of them yet. Task 6's paywall and card are superseded and never ship.)*
*(2026-10-22: step 1 **built through its Task 7, tests first, and staged** — the monthly plan, the
grace ruling on disk, set A declared and not on sale, three plans in the store, 27 strings, the
paywall and the Settings card as designed; 764 unit `@Test`. Waiting on Task 8, the owner's walk, then
the gate and the review. Its rule wording — rules `70-privacy` and `60-design-system`, and two
canary lists — is typed and unstaged for the owner.)*
*(2026-10-22, later: step 1 **built, walked, measured, gated and staged** — the final review's two
fixes, ten findings of the walk fixed and seen fixed, the paywall's colour pairs all at their floors
after the owner's four rulings (one card for the features, cyan glyphs, BEST VALUE inside the yearly
tile, white small marks); 768 unit `@Test`, the UI suite on 27.0 and 26.5, the watch, both widgets,
warnings unchanged. Nobody meets it until step 5 puts set A on sale; the privacy URL (#159) still
gates a Release build.)*

*(2026-10-22, afternoon: step 1 **committed** — its spec and plan `4577d92`, the code `d5cf816`, its
records `fd12b7f`, its rule wording `a6e287b`.)*

**1.4.2 — Full history.** History beyond the week shown today: a month calendar of goal days, and
trends. Free users keep today's week. **No serving is ever deleted or hidden from the store because
a user is not paying** — only the longer view is the extra.
*(2026-10-22, afternoon: **set A's step 2 — designed, drawn, specified and planned, no code of it
yet.** The owner's rulings: an older day is seen read-only, so adding and correcting stay the week's
for everyone; the locked month blurs a drawn month, not the user's; an opened day appears under the
month; the model shows one month at a time. Boards on the canvas, row *Set A, step 2*; spec
`docs/superpowers/specs/2026-10-22-month-view-design.md` and plan
`docs/superpowers/plans/2026-10-22-month-view.md`, both approved. Nobody meets it until step 5 puts
set A on sale.)*
*(2026-10-23: **set A's step 2 — built test-first, walked, measured, reviewed, gated and staged; not
committed.** The month view as specified, with the owner's rulings made on the way: the reads' budget
6 ms, a pour reading the shown month once, History letting go of the month when its page is removed,
the locked month as drawn. 815 unit `@Test`, 60 UI `func test`, warnings unchanged. Nobody meets it
until step 5; the Russian and Uzbek wording waits for the owner's sweep.)*

**1.4.3 — Custom reminder schedule.** The user's own hours and interval, and quiet days, in place of
the fixed grid of seven hours (`ReminderPlan.hours`). Any schedule must keep the plan within
iOS's 64 pending requests (`ReminderPlan.maximumPendingRequests`, rule `80-notifications`).

**1.4.4 — Export.** Every serving as a CSV file, through the share sheet. The file stays on the
phone until the user sends it.

**1.4.5 — Themes and app icons.** Alternative aurora palettes and app icons. Every colour comes
from `Aurora` today (rule `60-design-system`), so a theme is a second set of those colours, and each
theme's contrast is measured to the same floors before it ships.

*(Items 1.4.6 to 1.4.11 were added on 2026-10-21, approved by the owner in that session's chat.)*

**1.4.6 — Patterns.** When in the day the user drinks, weekdays against weekends, and their usual
first and last drink — read from the same rows as 1.4.2's full history, and worked out on the
device.
*(2026-10-23, evening: **set A's step 3 — designed, specified, built test-first, walked, measured and
reviewed, staged; not committed.** The owner's rulings: the patterns describe **the month on screen**,
inline in Month mode under its figures; **finished days only**, so today joins at midnight; **after
seven days of water**, with one line below that; the model **carried on `MonthHistory`**; then "go to
implementation… Do not ask". Spec `docs/superpowers/specs/2026-10-23-patterns-design.md`, no plan
document, no board — the 2026-10-21 concept board is the look. One colour pair is under its floor for
the owner (#171). Nobody meets it until step 5 puts set A on sale.)*

**1.4.7 — Monthly recap.** At the turn of each month, a card: the days the goal was met, the best
streak, the litres drunk, and the change from the month before. It may be shared as an image, which
leaves the phone only on the user's own tap, as 1.4.4's file does. **Needs a rule change** (§8).
The streak never leaves the app today (rule `20-state`), so whether the shared image carries it is
its design's question.

**1.4.8 — Vessel library.** More than three vessels, each with its own name and glyph; Home's row of
three is picked from them. Every one-tap door still logs the Glass, slot `DataManager.usualSlot`.
On a lapse, the three on Home stay as they are and still log; only picking from the library is the
extra. Today `Key.servings` holds exactly three amounts and the names and glyphs are fixed in
`vesselSlots`, which the watch draws too. **Needs rule changes** (§8).

**1.4.9 — Pace line.** Where the user should be by now across the reminder hours
(`ReminderPlan.hours`, or 1.4.3's own), against where they are — *On track*, or how far behind.
Worked out when shown and stored nowhere, as `remaining` is (rule `20-state`).

**1.4.10 — Remind only when behind.** A slot today is dropped when what the user has already drunk
covers what 1.4.9's pace asks for by that slot's hour — a third reason beside the goal and a drink
within the hour. The plan still only drops slots and never moves one, so it stays pure (rule
`80-notifications`). **Needs a rule change** (§8).

**1.4.11 — Workout-aware goal.** A workout recorded in Apple Health raises that day's goal; no
location and no weather (§9). Only if 1.3.3 also *reads* from Health — otherwise it waits. Whether
the widget and the watch draw the raised goal is its design's question. **Needs rule changes** (§8).

**1.4.12 — Personal AI insights.** *(Added 2026-10-21, evening, on the owner's choice, into set A.)*
A short insight each week — what changed, what is working, one concrete suggestion — written by
Apple's **on-device** model (`FoundationModels`, iOS 26 and later, on an iPhone with Apple
Intelligence on, in a language the model speaks), from the user's own summarised figures — never the
raw servings — and never as medical advice. Everywhere else the app writes the same kinds of insight
from fixed sentences in all three languages, and each says how it was made. Nothing leaves the
phone: Apple's Private Cloud Compute and a cloud model were set aside by the owner ("a"). The name
*Apple Intelligence* in the app's copy is checked against Apple's guidelines for it before set A goes
on sale. **Needs a rule change** (§8).
*(2026-10-24, early morning: **set A's step 4 — designed, specified, built test-first, walked, measured,
reviewed, gated and staged; not committed.** The owner's rulings: **the app decides and the model only
words it** — Apple's model speaks English alone of the three languages (measured), so Russian and Uzbek
always read the app's own sentences; Insights is **History's third mode**; **the last finished week**
against the week before; the model's words **kept in memory, with fixed wording**; the copy names
**Apple's on-device model, never *Apple Intelligence*** — the paywall's row is now *Personal insights*
(#164's naming half); then "all ok go implementation". Spec
`docs/superpowers/specs/2026-10-23-insights-design.md`, no plan document. Its rule wording — `70-privacy`'s
*FoundationModels, for the insights* among ten files — is typed and unstaged for the owner. The model has
not yet been seen writing: this Mac's was not ready (#178). Nobody meets it until step 5 puts set A on
sale.)*

## 6. Release 1.5 — more to log, more people

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 1.5.1 | **Other drinks** — tea, coffee, juice, milk | Free | Large |
| 1.5.2 | **Live Activity** | Free | Medium |
| 1.5.3 | **New languages** | Free | Medium per language |
| 1.5.4 | **Caffeine** | Premium | Medium |

**1.5.1 — Other drinks.** A drink type stored on every serving: a change to `WaterLog`, the source
of truth, and so a SwiftData migration, with consequences for the widget, the watch's wire format,
Siri, Control Center and Apple Health. Questions for its design: whether every drink counts in full
toward the goal; whether the one-tap doors (widget, Siri, Control Center, the watch, and since
2026-10-15 the reminder's *Log a Glass*) keep logging water only. *(2026-10-21: and whether a drink
counts toward the goal at its own share of water — decided here, for every user, never as a Premium
extra: a total that changed when a subscription lapsed would break *The Premium line*, §1.)*

**1.5.2 — Live Activity.** Today's progress on the Lock Screen and in the Dynamic Island. **With no
server, it can only be updated when the app or one of its intents runs** — a pour from the app, a
widget tap, a watch pour arriving — never pushed. **Needs a rule change** (§8): rule `70-privacy`
forbids a Live Activity today, because the total it would show counts pours the watch sent.

**1.5.3 — New languages.** More App Store storefronts reached in their own language. Each one means
all four string catalogues, the store listing, the header's phrase, and `knownRegions`
(rule `15-project`). Added here, after the copy has settled, so no feature is translated twice.
Which languages is a decision for that time.

**1.5.4 — Caffeine.** Milligrams of caffeine counted from coffee and tea servings, a daily limit,
and a reminder at a cut-off hour the user chooses. After 1.5.1, which stores the drink on each
serving; how much caffeine a serving carries is its design's first question. The cut-off is a
second kind of reminder beside the hydration grid — its own identifiers, inside the 64-request cap,
and no digit in its copy. **Needs rule changes** (§8). *(Added on 2026-10-21, approved by the
owner in that session's chat.)*

## 7. Release 2.0 — your data everywhere

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 2.0.1 | **iCloud backup and sync** | open | Large |

**Why last.** It is the largest change in this file: history survives a new phone and stays in step
across devices, but it reaches the store's whole design.
- CloudKit is banned by name, and it adds entitlements (rule `70-privacy`, rule `15-project`).
- SwiftData syncs through CloudKit only when every model property is optional or has a default
  value. `WaterLog`'s three properties — `id`, `amount`, `timestamp` — have none today; it already
  carries no unique constraint, which CloudKit also forbids.
- Rows arriving from iCloud are a second way in to the source of truth, beside `DataManager`'s own
  writes, so *today's total is derived* and *a failed read is never written back* must hold for
  them too (rule `20-state`), and the watch's apply ledger must still stop a deleted serving coming
  back.
- Whether it is free or Premium is open.

## 8. The rule changes this file needs

Each is written as an amendment for the owner to approve, before its item's code.

| Rule | What changes | For |
|---|---|---|
| `70-privacy` | `StoreKit` may be imported | 1.2.5, 1.4.1 |
| `70-privacy`, `15-project` | `HealthKit`, its entitlement, and its usage description | 1.3.3 |
| `70-privacy` | Siri's reply to the question may carry figures | 1.3.4 |
| `70-privacy` | A Live Activity may show today's figures | 1.5.2 |
| `70-privacy`, `15-project`, `20-state`, `25-shared-storage` | `CloudKit`, its entitlements, and a second way in to the store | 2.0.1 |
| `80-notifications` | A reminder carries an action | 1.2.4 |
| `60-design-system` | The glass, per stage 3c's chosen approach | 1.2.1 |
| `60-design-system` | A second set of `Aurora` colours | 1.4.5 |
| `70-privacy` | What leaves the app on the user's own tap — the export file, the recap's image | 1.4.4, 1.4.7 |
| `20-state`, `25-shared-storage`, `10-architecture`, `50-views` | A library of vessels beside `Key.servings`' three, named by the user | 1.4.8 |
| `80-notifications` | A slot dropped when the user is ahead of pace | 1.4.10 |
| `70-privacy`, `15-project` | Reading workouts from `HealthKit`, beyond 1.3.3's row | 1.4.11 |
| `70-privacy`, `95-dependencies` | `FoundationModels` — Apple's on-device model — may be imported, by the insights' file alone | 1.4.12 |
| `80-notifications`, `70-privacy` | A second kind of reminder, the caffeine cut-off, with no digit | 1.5.4 |

*(2026-10-14: 1.2.1's was approved on 2026-10-13 and committed as `c9d1f6b`. 1.2.2 needed three
this table did not list — rule `50-views` (all three tabs refresh; a mirrored `@State` takes a
re-read value while no drag is in flight), `60-design-system` (stage 3b's haptics wording, and
`steps` among the counters) and `65-accessibility` (50 pt for a language row). They were typed into
the rule files unstaged, and the owner approved them the same day; they are staged as typed. The
stage's code was built and staged first, under the 2026-10-09 ruling to build the stages straight
through and the owner's S1 and S2 — the reverse of the order this section asks for.)*
*(2026-10-14, evening: 1.2.3 needed six this table did not list, typed into the rule files
unstaged for the owner — most of it written in its spec §11, and the rest after the stage's final
review: `70-privacy` (asking for reminders from the welcome's *Turn on reminders* as well as
Settings' switch — wording the owner approved in the redesign's spec on 2026-10-09 as D1 — and the
calculator keeping no weight), `80-notifications` (the same, and the re-read on every return to the
foreground), `85-testing` (the welcome's DEBUG fresh start; after the review, the two new canary
suites and `tapWhenReady(_:)`), `50-views` (the menu on `WelcomeView`; after the review, the one
`withTransaction` scroll), `43-concurrency` (the screen's new name; `WelcomeView.goalRange` /
`goalStep` carry `nonisolated`; after the review, the two new canaries) and `10-architecture` (the
screen's new name). As with 1.2.2, the code came first. Not typed, and the owner's to word: rule
`60-design-system`'s list of haptic counters does not name the welcome's (`goalSteps`, `finishes`,
`uses`, `picks`), and the welcome's step tick is triggered by the step itself, a view's own state,
as #111 records.)*
*(2026-10-15: 1.2.4 needed three besides `80-notifications`, typed into the rule files unstaged for
the owner as its spec §5 words them: `70-privacy` (the button says nothing and runs without
unlocking), `43-concurrency` (`ReminderResponder` is main-actor) and `85-testing` (press a reminder's
*Log a Glass* with the app not running). After the final review, `80-notifications` and
`43-concurrency` were reworded — the scheduler is called on both sides of the main actor, the
responder does not rest on the centre's thread, and *Identifiers* names request identifiers.)*
*(2026-10-15, later: 1.2.5's `StoreKit` row was approved for the review request only — one file,
`HomeView.swift`, one call (decision D3) — so 1.4.1 writes its own amendment. It also needed four
the table did not list, worded in its spec §5 and typed into the rule files unstaged: `20-state`
(the claim joins the mutation surface), `25-shared-storage` (its key's absence means never asked),
`10-architecture` (ten keys) and `85-testing` (the DEBUG opt-in). This time the wording came before
the code.)*
*(2026-10-16: 1.2.2's wording was committed as `1438122`, 1.2.3's as `6010e25`, 1.2.4's as
`450d76f`, and 1.2.5's as `52ee815`. 1.2.6 needs three
this table does not list, worded in its spec §5 and not yet typed: `50-views` (every sentence with an
argument through one of two helpers, with the locale; figures grouped, spoken ones too),
`65-accessibility` (the streak chip's value and the strip heading's) and `70-privacy` (plural forms
in every catalogue that holds a counted key).)* *(2026-10-17: typed into the three rule files and
approved by the owner as typed, before any code; staged with 1.2.6's records, for the owner's
`/commit`.)*
*(2026-10-18: 1.3.4's `70-privacy` row — Siri's answer to *Today's Water* may say the user's own
figures, only to someone the system has authenticated, never the streak — and four the table did not
list: `15-project` (the intent is app-only), `20-state` (the streak never reaches Siri; the snapshot
carries `remaining` and `hasReachedGoal`), `43-concurrency` and `85-testing` (the new suite that is
not `@MainActor`). Worded in its spec §5, typed into the rule files unstaged and approved by the owner
before any code, as 1.2.5's were. Known issue #147 asks the owner to reword the last two.)*
*(2026-10-19: 1.3.4's wording was committed as `41309e3`. 1.3.1 needed ten this table does not list,
worded in its spec §5 — the week's key in `10-architecture`, `20-state`, `25-shared-storage` and
`30-rollover`, and its snapshot in `40-widget`; the pour button, the StandBy layout, the week widget
and its link across `40-widget`, `50-views`, `60-design-system`, `65-accessibility` and
`70-privacy`; StandBy and the week in `85-testing`'s device list. Approved by the owner before any
code and staged; not yet committed — 6a was committed ahead of its wording.)*
*(2026-10-21: the last five rows were added with items 1.4.6 to 1.4.11 and 1.5.4. The first also
covers 1.4.4, which had no row here before: an export file is the user's data leaving the app. Each
row is still worded and approved when its item's turn comes, before its code.)*

## 9. Not planned

- **Charging to log**, in any form, and weekly subscription plans.
- **Anything that needs a server or an account.** StoreKit and iCloud are the two Apple services
  this file brings in, and both work without either.
- **Location and weather.** A goal that follows the weather needs the network and location, both
  outside the product's privacy shape.
