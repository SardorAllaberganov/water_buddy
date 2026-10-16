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
Premium sells extras — never logging. Pricing is yearly plus lifetime; no weekly plans.

Why that pitch: a read-only scan on 2026-10-06 of about 430 recent US App Store reviews of six
hydration apps ranked complaints by how often they appeared, and paying to log water was first
(about 65 mentions, across every competitor read). The scan's figures are from that session's
record; the scan itself is not in this repository.

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
language.)*

**1.2.5 — Rating prompt.** Apple's own review request, asked at a moment of success (say, a goal
reached on a later day, never in the first session). Apple caps how often it can show. **Needs a
rule change:** `StoreKit` is banned by name in rule `70-privacy` (§8). *(2026-10-15: built in the
tree, awaiting `/commit` and the device sweep (#137). Spec `2026-10-15-rating-prompt-design.md`: asked
about 2.2 s after the user's own pour on Home reaches the goal on the third day in a row, at most
once per app version; only Home's own pour starts the wait, so a goal reached anywhere else never
starts a request; a DEBUG build asks only when launched with the `-WaterBuddyReviewPrompt` argument. Whether it should wait for the eight-second *Undo* offer to end
is open, for the owner (#138).)*

**1.2.6 — Russian plurals (#40).** The shared Russian keys use one plural form. The redesign's
streak shows a bare number with no noun until this is fixed (decision D3, 2026-10-09).

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
*Follow device* case.)*

**1.2.8 — Store page.** New iPhone screenshots of the redesign (the owner's 2026-10-09 ruling was
none until the redesign is built), the header, and the pitch in the subtitle or description — not in
the art, where Apple's asset guidance discourages pricing claims. A Russian header too, if the
store listing has a Russian localization.

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
shape, cascading to `docs/STATE.md` and the snapshot's read-only tests.

**1.3.2 — The watch** needs a watchOS 26 or later runtime to render the redesign's watch stage
(decision D6); watchOS 27.0 is installed. The new complication families read the watch's own suite,
as the circular one does.

**1.3.3 — Apple Health.** Each serving written as dietary water, and removed when the serving is
deleted or edited. Whether it also *reads* water other apps logged is the design's first question.
**Needs rule changes** (§8): HealthKit is banned by name; it adds an entitlement beside the App
Group, the only one any target has today; and it needs a usage-description key, where the project
carries none.

**1.3.4 — Siri: "how much today?"** A second Siri phrase that answers with today's total and
what is left. **Needs a rule change** (§8): today every Siri reply is one fixed, digit-free line.
Its design must decide whether it answers on a locked phone.

## 5. Release 1.4 — Premium

**Why third.** It comes after the product looks and feels finished everywhere, so the first thing a
paying user buys is the extras, never the basics. Nothing a free user can do today moves behind it.

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 1.4.1 | **StoreKit subscriptions and the paywall** — yearly and lifetime | — | Medium |
| 1.4.2 | **Full history and a month view** | Premium | Medium |
| 1.4.3 | **Custom reminder schedule** | Premium | Medium |
| 1.4.4 | **Export** | Premium | Small |
| 1.4.5 | **Themes and app icons** | Premium | Medium |

**1.4.1 — StoreKit.** Purchases are verified on the device by StoreKit itself, so Premium needs no
server and keeps the product's *no account, no server* shape. **Needs a rule change** (§8), the
same one as the rating prompt. The streak stays free (the owner's choice, 2026-10-09).

**1.4.2 — Full history.** History beyond the week shown today: a month calendar of goal days, and
trends. Free users keep today's week. **No serving is ever deleted or hidden from the store because
a user is not paying** — only the longer view is the extra.

**1.4.3 — Custom reminder schedule.** The user's own hours and interval, and quiet days, in place of
the fixed grid of seven hours (`ReminderPlan.hours`). Any schedule must keep the plan within
iOS's 64 pending requests (`ReminderPlan.maximumPendingRequests`, rule `80-notifications`).

**1.4.4 — Export.** Every serving as a CSV file, through the share sheet. The file stays on the
phone until the user sends it.

**1.4.5 — Themes and app icons.** Alternative aurora palettes and app icons. Every colour comes
from `Aurora` today (rule `60-design-system`), so a theme is a second set of those colours, and each
theme's contrast is measured to the same floors before it ships.

## 6. Release 1.5 — more to log, more people

| # | Item | Free / Premium | Size |
|---|---|---|---|
| 1.5.1 | **Other drinks** — tea, coffee, juice, milk | Free | Large |
| 1.5.2 | **Live Activity** | Free | Medium |
| 1.5.3 | **New languages** | Free | Medium per language |

**1.5.1 — Other drinks.** A drink type stored on every serving: a change to `WaterLog`, the source
of truth, and so a SwiftData migration, with consequences for the widget, the watch's wire format,
Siri, Control Center and Apple Health. Questions for its design: whether every drink counts in full
toward the goal; whether the one-tap doors (widget, Siri, Control Center, the watch, and since
2026-10-15 the reminder's *Log a Glass*) keep logging water only.

**1.5.2 — Live Activity.** Today's progress on the Lock Screen and in the Dynamic Island. **With no
server, it can only be updated when the app or one of its intents runs** — a pour from the app, a
widget tap, a watch pour arriving — never pushed. **Needs a rule change** (§8): rule `70-privacy`
forbids a Live Activity today, because the total it would show counts pours the watch sent.

**1.5.3 — New languages.** More App Store storefronts reached in their own language. Each one means
all four string catalogues, the store listing, the header's phrase, and `knownRegions`
(rule `15-project`). Added here, after the copy has settled, so no feature is translated twice.
Which languages is a decision for that time.

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

## 9. Not planned

- **Charging to log**, in any form, and weekly subscription plans.
- **Anything that needs a server or an account.** StoreKit and iCloud are the two Apple services
  this file brings in, and both work without either.
- **Location and weather.** A goal that follows the weather needs the network and location, both
  outside the product's privacy shape.
