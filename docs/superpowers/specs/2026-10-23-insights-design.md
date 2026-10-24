# Insights — design

**Status:** approved by the owner in conversation on 2026-10-23, in this order: **the app decides and
the model only writes** ("Model writes, app decides"); Insights is **History's third mode**, *Week ·
Month · Insights* ("Third History mode"); it describes **the last finished calendar week** against the
week before ("Last finished week"); the model's sentences are **kept in memory, with fixed wording**
("In memory, fixed wording"); the feature names **Apple's on-device model, never *Apple
Intelligence*** ("Apple's on-device model", closing known issue #164's naming half); the design's
first section, *what the page says* ("ok go"); its second, *how it is built*, answered "all ok go
implementation". **§3.5 to §3.11 (the words, accessibility, the rule wording, the tests) were written
after that answer, on the recommendations below, and were not shown section by section**; the owner
reads them here. No board was drawn for this step: the concept board *Insights* on the design canvas
(https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, 2026-10-21) is the look this step follows, where
§3.4 does not differ from it.

It is **step 4 of 5** of set A (`docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`,
§1) and roadmap item 1.4.12. It builds on steps 2 and 3 and amends step 1's insights row (§3.5).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `5b511bd` on 2026-10-23. Claims are
marked **measured** (read or run on this toolchain), **stated** (an Apple source says it), **inferred**,
or **unconfirmed**.

## 1. Where this sits

| Step | Builds | Roadmap |
|---|---|---|
| 1 | the monthly plan, the paywall and the Settings card — committed `d5cf816` | 1.4.1, amended |
| 2 | the month view and full history — committed `40e7e41` | 1.4.2 |
| 3 | patterns — committed `d9e7db7` | 1.4.6 |
| **4** | **this document** — insights, written on the phone | 1.4.12 |
| 5 | the monthly recap, and set A put on sale | 1.4.7 |

Nobody meets it until step 5 puts set A on sale.

## 2. What exists today (measured)

- **Apple's model on this Mac** (macOS 27.0.1, Xcode 27.0, a throwaway probe in the session's
  scratchpad): `SystemLanguageModel.default.availability` is
  `.unavailable(.modelNotReady)`. The simulator runs on the Mac's model, so until the Mac's model is
  ready only the app's own sentences can be seen here (inferred from the simulator sharing the host's
  model).
- **Its languages**: 24, of which **English is the only one WaterBuddy ships** — `supportsLocale` is
  `true` for `en`, `false` for `ru` and `uz`. A Russian or Uzbek user always reads the app's own
  sentences.
- **The SDK** (`iPhoneSimulator27.0.sdk`): `FoundationModels` is iOS 26.0 and later and **unavailable
  on watchOS's `SystemLanguageModel`**; `LanguageModelSession.respond(to:generating:options:)` with a
  `@Generable` type; `GenerationOptions(samplingMode: .greedy)`, back-deployed to iOS 26. The same SDK
  also offers `PrivateCloudComputeLanguageModel` and a `LanguageModel` protocol for other providers —
  the owner set both aside, and §3.10 forbids them by name.
- **Apple's naming** (stated, *Guidelines for Using Apple Trademarks and Copyrights*): a developer may
  use an Apple word mark only in a referential phrase — *runs on*, *for use with*, *for*, *compatible
  with* — never as part of a product or feature name, less prominent than the product's own, and
  never implying endorsement. The page does not name *Apple Intelligence*. Apple's iOS 27 developer
  guide calls the framework "the same on-device model that powers Apple Intelligence".
- **The copy step 1 shipped for this row**: *Personal AI insights* / *Using Apple Intelligence, private
  on your iPhone*, and the card's caption *AI insights* (Russian *Личные советы ИИ*, *Советы ИИ*;
  Uzbek *Shaxsiy AI tavsiyalari*, *AI tavsiyalari*).
- **History** (`WaterBuddy/HistoryView.swift`, 3,022 lines): `HistoryMode` is `.week, .month`;
  `ModeSwitch` draws two segments, Month locked for a free user; `LockedMonth` is the free user's Month;
  `offersMonth(status:offered:)` decides whether the switch is drawn; `firstWeekday(in:)` and
  `weekend(in:)` read the app's locale. The month is asked for through `DataManager.showMonth(_:)`,
  republished from `saveAndRecompute()`, `refresh()`, `dayDidTurn()` and the `dailyGoal` setter,
  behind `role.drawsHistory`, and let go on the page's removal.
- **`MonthPatterns`** (`DataManager.swift`): the lower median of a set of wall-clock minutes, rounded to
  five (`usual`), `minuteOfDay(_:in:)`, saturating sums.

## 3. The design

### 3.1 Which week

- **The week** is the last *finished* calendar week: it starts on the app's locale's first weekday
  (`HistoryView.firstWeekday(in:)` — Sunday in US English, Monday in Russian and Uzbek, the user's own
  under *Follow device*) and ends before the current week's first day. **The week before** is the seven
  days before it. Both are walked with `calendar.date(byAdding: .day, …)` on the model's calendar,
  never 86,400 seconds (rule `30-rollover`).
- **Counted days** are a week's days on or after the first serving's day — the first week after an
  install is averaged over the days the user had the app, as the month is.
- **A week qualifies** when **four** of its counted days hold water. The page needs the week to qualify;
  the comparisons need the week before to qualify too, and are left out when it does not.
- Every day is judged against the **current** goal, as everything in History is.
- It changes at midnight as a new week starts. Until then it is the same week, all week.

### 3.2 What the app works out (`WeekInsights`, in `DataManager.swift`)

From the two weeks' rows, on the model's calendar, with the locale's weekend handed in:

| Figure | How |
|---|---|
| **Average day** | the counted days' water over the counted days, empty days included, saturated |
| **Days on goal** | counted days whose water reached the goal |
| **Weekends against weekdays** | each side's average over its counted days; both sides need a day |
| **Usual first drink** | the lower median of the watered days' first serving, as wall-clock minutes, rounded to five (`MonthPatterns`' `usual`) |
| **Where the water falls** | the week's water by part of the day — morning before 12:00, afternoon 12:00 to 17:00, evening from 17:00 — and the minute by which half of it was in |
| **Empty days** | counted days with no serving |

**A difference is said only when it is at least a tenth of the goal, and never under 50 ml**
(`threshold = max(goal / 10, 50)`). **Figures are rounded to 50 ml, half up**, for the app and the model
alike. A first drink moves when it moves by 30 minutes or more.

### 3.3 What it picks

Three parts, the board's: **the one thing**, **what is working**, **worth knowing**. Each is a
`WeekInsights.Finding`; a part with nothing to say is left out.

**The one thing** is the largest **shortfall**, scored as millilitres missed across the week; a tie
goes to the earlier in this list:

| Shortfall | When | Score | Its suggestion |
|---|---|---|---|
| weekends lower | weekday average − weekend average ≥ threshold | gap × counted weekend days | another *vessel* on each weekend day |
| weekdays lower | weekend average − weekday average ≥ threshold | gap × counted weekdays | another *vessel* on each weekday |
| down on the week before | the week before's average − this week's ≥ threshold | drop × counted days | another *vessel* each morning, afternoon or evening |
| short of the goal | goal − average ≥ threshold | shortfall × counted days | another *vessel* each morning, afternoon or evening |

**The suggestion** names an amount: the user's own vessel (`DataManager.servings`) nearest the gap a
day, a tie to the smaller — chosen when drawn, so an edited vessel is followed without a re-read — and,
for the last two, the part of the day that held the least water this week, a tie to the earlier. Its
sentence promises only that it *would help close the gap*, which is true of any amount.

With **no shortfall**, the one thing is the first **improvement** in the order below, with the average
day as its detail; with none of those either, the average day against the goal stands alone.

**What is working** is the first of these not already used: every counted day on goal; every counted
weekday on goal (three or more); every counted weekend day on goal; more days on goal than the week
before; the average up on the week before by the threshold; the first drink 30 minutes or more
earlier; some days on goal (*n of m days on goal*).

**Worth knowing** is the first of these not already used: days with nothing logged; the first drink 30
minutes or more later; when half the week's water was in, drawn as the next whole hour (*Half your
water came before 1 PM*), held to 23:55.

`WeekInsights` is `nonisolated`, `Sendable` and `Equatable`, derived on every read, stored nowhere —
pending (and when the next week starts) or ready (the week's first and last day for formatting, the
three parts). It sits at file scope in `DataManager.swift`, for `MonthPatterns`' reason: `DataManager`
publishes it, and a seventh shared file is not allowed (rule `40-widget`).

### 3.4 The screen

- **The switch** draws three segments, *Week · Month · Insights*, the same capsule; Insights carries
  Month's lock, drawn and not spoken, for a free user. It is a control inside the screen, not a route
  (rule `50-views`).
- **A holder's Insights**, top to bottom, every row a row of History's one list:
  1. **Insights** — the heading, white on the aurora at `.title3` bold, as *Patterns* (5.73:1 there);
     **no subtitle on the aurora** (#171's 4.17).
  2. **The one thing** — a frosted, raised pane: a label line, *The one thing* and the week's range
     (*13–19 Oct*, the app's locale) at `.footnote` semibold; the headline at `.title3` bold; the
     detail at `.body`, the vessel's glyph before a suggestion.
  3. **What is working** and **Worth knowing** — a frosted, raised pane each: a glyph (checkmark,
     clock), the title at `.subheadline` bold, the sentence at `.subheadline`.
  4. **The footer** — a frosted pane: a lock glyph and who wrote it, *Not medical advice.* inside it.
     On a pane, not on the aurora, for #171's reason.
- **Before the week qualifies**: the heading, then one pane — *Insights need 4 days of water in a
  week* and *Next on Monday, 27 October* (the date the current week finishes).
- **A free user's Insights**: the locked page — `LockedMonth`'s shape, generalised to take its glyph,
  title and line, with a drawn, blurred insight card behind it (three bars of text, no words), *See
  Premium* (the paywall, entry `.history`), *Back to this week*, and the promise.
- **Glass** is the existing frosted/raised pair; no premium rim except on the locked card, which takes
  `.premiumRim()` as the locked month does (rule `60-design-system`). Colour is white text only — no
  cyan text under 24 pt (the paywall's R4).
- **The model's state**: on an English iPhone where the model is available, the panes draw the app's
  own sentences and the footer reads *Writing…* until the model's note is accepted, then the note,
  cross-faded (`.smooth(duration:)`, scoped to the note); a note refused or failed leaves the app's
  sentences and the WaterBuddy footer.

### 3.5 Who writes the words (`InsightWriter`, app-only)

- **`WaterBuddy/InsightWriter.swift`** is the only file that imports `FoundationModels`. `@MainActor
  @Observable final class`, built in `WaterBuddyApp.init()` and injected beside `PremiumStore`.
- It reaches the model only through **`InsightWriter.Source`**, a struct of closures — `isAvailable`
  and `write` — built by `static func live()`, each closure building what it needs in its own body
  (`ReminderScheduler`'s and `PremiumStore.Source`'s shape), and `static func silent()` (never
  available) for previews and tests. `live()` uses **`SystemLanguageModel.default` and nothing else**.
- **What the model is given**: the app's own **English** sentences for the three parts — the facts the
  page would draw anyway — and the suggested vessel's name. Never a row, a timestamp, the goal history,
  the streak or the user's language.
- **Instructions**: rewrite each fact as one short, warm, plain sentence to "you"; keep every number,
  time and amount exactly as given and add none; say nothing about health, medicine, illness or the
  body; write in English. **Greedy sampling** (`GenerationOptions(samplingMode: .greedy)`), so one
  week's facts give one wording (inferred; to confirm on a device, known issue).
- **Output**: a `@Generable` note — the one thing, its detail, what is working, worth knowing — taken
  only when `InsightWriter.accepts(_:for:)` passes: every part the facts have is present and at most
  200 characters, and **every number in it is one of the facts' numbers** (digits read with their
  grouping separators removed). Anything else — a refusal, a guardrail, a throw, an extra figure — is
  **declined**, and the app's sentences stand.
- **When**: only for a holder, only on the Insights page (`.task(id:)` on the facts), only when the
  app's strings are English (`AppLanguage.english`, or `.system` with `Bundle.main` resolving `en`) and
  `isAvailable()` says so. **Kept in memory** by facts, written once per run of the app, declined once
  per run; never written to either store.
- **Copy** (`WaterBuddy/InsightCopy.swift`, app-only, `Foundation` alone): the one mapping from a
  `Finding` and a suggestion to a sentence, through `strings.localized` and `strings.figure` with the
  locale (rule `50-views`) — the view draws it and the writer is handed its English.

### 3.6 The model (`WaterBuddy/DataManager.swift`)

- `showInsights(_ request: WeekInsights.Request?)` — the locale's first weekday and weekend — and
  `insights: WeekInsights?`, equality-guarded, `nil` while none is asked for. **Two reads**: the rows
  from the first day of the week before to the first day of the current week, and the first serving
  (`readOldestLog()`). Either failing returns and leaves `insights` as it stands.
- Republished wherever the month is: `saveAndRecompute()`, `refresh()` (not its mutation form, for the
  month's reason), `dayDidTurn()`, the `dailyGoal` setter, and `showInsights`. Not the `servings`
  setter: the vessel is chosen when drawn.
- Behind **`role.drawsHistory`** — the **ninth** guard site (rule `25-shared-storage`). It writes
  neither store, rings no doorbell and reschedules nothing.
- History asks for it when Insights is chosen by a holder, lets go (`nil`) when Week or Month is
  chosen, when the page is removed and when Premium stops being held — the month's own lifecycle.

### 3.7 The view (`WaterBuddy/HistoryView.swift`)

- `HistoryMode` gains `.insights`; `ModeSwitch` takes the modes in order and locks both paid ones.
- New private views: `InsightsHeading`, `OneThingPane`, `InsightPane`, `InsightFooter`,
  `InsightsPending`, `DrawnInsight`; `LockedMonth` becomes `LockedPage`, taking its glyph, title and
  line, so the two locked pages are one view. The file grows past 3,400 lines; splitting it stays #176.

### 3.8 Accessibility

- The heading is one element with the header trait; its value is the week's range.
- Each pane is one element: label its title (*The one thing*, *What is working*, *Worth knowing*),
  value its sentences in reading order. The vessel's glyph and the panes' glyphs are hidden.
- The footer is one element, its text. *Writing…* is spoken as the footer's text while it stands.
- The switch's Insights segment: label *Insights*, value *Premium* for a free user, `.isSelected` when
  shown — the Month segment's own form.
- Figures carry *ml* as drawn; VoiceOver's reading of *ml* inside a sentence is a device proof (§4).
- Reduce Motion: the cross-fade is a once-per-change animation, not a repeating one — no branch
  (rule `65-accessibility`).

### 3.9 The words

Every key in all three languages; the Russian and Uzbek are drafts for the owner's sweep, following
step 1's word for the feature (*Советы*, *Tavsiyalar*). Counted keys take plural forms where a count
stands beside a noun (rule `70-privacy`).

| English | Counted |
|---|---|
| Insights · The one thing · What is working · Worth knowing · Writing… | |
| Written by WaterBuddy from your own figures, on your iPhone. Not medical advice. | |
| Written by Apple's on-device model from your own figures, on your iPhone. Not medical advice. | |
| Insights need %1$d days of water in a week · Next on %1$@ | the first |
| A few lines each week on how you drank · Premium writes them from your own figures, on your iPhone, with one thing to try. | |
| Personal insights · Each week, from your own figures, on your iPhone | |
| Weekends ran %1$@ ml a day below weekdays. · Weekdays ran %1$@ ml a day below weekends. | |
| %1$@ ml a day less than the week before. · %1$@ ml a day more than the week before. | |
| An average day was %1$@ ml short of your goal. · An average day: %1$@ ml, against a goal of %2$@ ml. | |
| Another %1$@ ml on each weekend day / on each weekday / each morning / each afternoon / each evening would help close the gap. | |
| Every day on goal. · Your goal on every weekday. · Your goal on every weekend day. | |
| Goal met on %1$d days, up from %2$d. | yes |
| Your first drink came %1$d minutes earlier than the week before. · … later than the week before. | yes |
| Nothing was logged on %1$d days. | yes |
| Half your water came before %1$@. | |
| %1$d of %2$d days on goal (reused) | yes |

Step 1's *Personal AI insights*, *Using Apple Intelligence, private on your iPhone* and *AI insights*
leave the catalogue; the paywall row reads *Personal insights* / *Each week, from your own figures, on
your iPhone*, and the Settings card's caption *Insights* (the switch's own word). The `sparkles` glyph
stays.

### 3.10 What it amends in the rules (typed unstaged, for the owner)

- **`70-privacy`** — *FoundationModels, for the insights*: imported by `InsightWriter.swift` alone;
  `SystemLanguageModel.default` only — never `PrivateCloudComputeLanguageModel`, never another
  `LanguageModel` provider; given only the app's own English sentences; its output taken only after
  `accepts(_:for:)`; never in a notification, a widget, the watch, Siri or the control; the footer says
  who wrote it, with *Not medical advice*; the name *Apple Intelligence* appears nowhere.
- **`95-dependencies`** — `FoundationModels` is an SDK framework, not a dependency; it enters in one
  file, as `StoreKit` enters in two.
- **`10-architecture`** — the import direction and *Forbidden* list gain it.
- **`15-project`** — `InsightWriter`, `InsightCopy` app-only, out of every exception set; the third
  version check is the insights' (`if #available(iOS 26.0, *)`).
- **`20-state`** — `insights` joins the get-only consequences, published like `month`.
- **`25-shared-storage`**, **`CLAUDE.md`** — nine guard sites.
- **`43-concurrency`**, **`85-testing`** — `WeekInsightsTests` and `InsightCopyTests` join the canary
  lists; `InsightWriter` is `@MainActor`, its `Source` main-actor closures; no test reaches the model.
- **`50-views`** — History's switch has three modes; Insights asks for its week as Month asks for its
  month.

### 3.11 Testing

- **`WeekInsightsTests`** (not `@MainActor`): the week's bounds under a Sunday and a Monday first
  weekday, across a DST change; pending under four days, with no rows, before the first full week;
  counted days from the first serving; each figure; the threshold and the 50-ml floor; rounding;
  each shortfall's score and the tie order; improvements; *what is working* and *worth knowing*
  orders, nothing used twice; the half-way hour held to 23:55; a corrupt `Int.max` row saturating.
- **`InsightCopyTests`** (not `@MainActor`): every finding and suggestion resolves in all three
  languages with its figures grouped; the vessel nearest the gap, the tie to the smaller.
- **`InsightWriterTests`** (`@MainActor`): `accepts` — an extra figure, a missing part, an over-long
  part, grouped digits; the writer never calls `write` when unavailable or not English; caches a
  note, declines once, never asks twice for the same facts.
- **`DataManagerTests`/a new `InsightsModelTests`** (`@MainActor`): `showInsights` publishes and lets
  go; a pour republishes; a failed read leaves it; it writes no key.
- **`LocalizationTests`**: the keys in every language, the counted ones' forms, the removed keys gone.
- **`PremiumSetTests`**: the row's new title, line and caption.
- **`PremiumUITests`**: the switch's third segment; the free user's locked Insights; a holder's
  heading.

## 4. Verification

The five-invocation gate, the UI suite again on iOS 26.5, warnings by file and message against a clean
build of a `HEAD` export, and a walk on the simulator — the locked page, the pending page, a ready week
in all three languages, Reduce Transparency, an accessibility text size. Owed to a device: the model's
own writing and its fixed wording across launches; VoiceOver by ear; the app on iOS 17 and 18 not
loading `FoundationModels` (the binary's weak link is read with `otool`).

## 4a. Amendments after the walk and the final review (2026-10-24)

The session's own calls, each built test-first; the owner's to overrule.

- **§3.3, M7** — weekends lower (or weekdays lower) is a shortfall only while that side's average is
  **itself short of the goal**. Without it, *Another 500 ml on each weekend day* could stand beside *Your
  goal on every weekend day*. A drop on the week before stays a shortfall with the goal met, as built.
- **§3.3, I2** — *n of m days on goal* is left out beside *Goal met on n days, up from m* as beside *Every
  day on goal*: it said the count twice.
- **§3.3, M4** — the half-way line is left out when half the water was in only at 23:55 or later, where
  *before 23:55* would be untrue.
- **§3.3, M5** — a negative row reads as nothing, so a corrupt store cannot trap a score's
  multiplication.
- **§3.5, I1** — `accepts(_:for:)` checks **each part against its own fact**, never the facts pooled
  (pooled, the headline's *1,500* passed as the suggestion's amount); reads a figure whole (*1:30*, *1.5*);
  refuses a digit outside ASCII; and refuses a quantity, a unit or a weekday in words that its fact lacks
  (`InsightWriter.statedWords`) — the model is never told the locale's weekend.
- **§3.5, M3** — a busy or not-yet-ready model (`rateLimited`, `concurrentRequests`,
  `assetsUnavailable`, carried as `InsightWriter.Retry`) and a cancellation are asked again on the next
  visit, not declined for the run. The English-only gate moved into the writer
  (`write(_:language:)`), where a test pins it.
- **§3.4, the walk** — W1: the week's range stands at the pane's trailing edge; W2: the three-segment
  switch scrolls at the accessibility sizes, where *Insights* was cut to *Insig…*; W4: the locked page's
  drawn lines show beside its card, as the locked month's rings do.
- **§3.4, the heading's contrast** — *Insights* on the aurora reads **3.37** at its worst over 45 frames
  two seconds apart (median 4.55), where the aurora's cyan light passes behind it, against the 4.5
  `docs/DESIGN.md` holds *Patterns*' title to. Step 2's tool masks that cyan as other ink and finds no
  ground, so the figure is a second script's, which by the same method reads *Patterns*' own title 3.14
  in step 3's frames (the tool: 5.73). For the owner with #171.

## 5. Open questions

- The Russian and Uzbek wording (§3.9), for the owner's sweep with #170's and #175's.
- Whether a model note should say it is a suggestion, not a fact — the footer says who wrote it.
