# Other drinks — tea, coffee, juice and milk — design

Taken on the owner's answer of 2026-11-27 to *"Which feature should come next?"*: *"Other drinks"* — roadmap item 1.5.1,
which the roadmap lists as free and large. Written whole for one approval, as the owner prefers: seven rulings asked (§2), the
rest recommended (§11).

## 1. What was asked, and what done looks like

**Said:** other drinks next.

**Taken to mean** (correct anything here):
- A serving can be water, tea, coffee, juice or milk. Every user can log every drink: no way of logging is ever Premium
  (`docs/ROADMAP.md` §1, *The Premium line*, which names 1.5.1's drinks).
- Home stays one tap for water; another drink is one tap more.
- The day's total, the goal, the streak, the week, the month, Insights, the recap, Apple Health and the watch all count every
  drink.
- History shows each serving's drink and lets it be changed.

**Read on 2026-11-27** (`file:line` as read on `main` at `4b5c8f3`):
- **`WaterLog`** (`WaterLog.swift:34-57`) holds `id`, `amount` and `timestamp`, none optional, none defaulted. It is compiled
  into all four targets; the watch's two open no store.
- **The store has no schema versions.** `sharedModelContainer` (`DataManager.swift:2449-2480`) opens `WaterBuddy.store` with
  `try?`. If that fails it falls back to a process-local store, then to memory, and only a DEBUG build says so. No test opens a
  store an earlier build wrote.
- **Every total is a plain sum of `amount`**, in six places: today (`DataManager.swift:1260`), `DaySummary.series` (`:3158`),
  the month (`:3444`), patterns (`:3627`), insights (`:3873`) and the watch's outbox (`WristPlan.swift:34`). Apple Health and
  the export read `amount` too.
- **One insert, `addLog(amount:at:)`** (`:953`), behind Home, History's `+`, and — through `addWater` — the widgets, Control
  Center, Siri and the reminder's button. The watch's pours enter through `ingest` (`:1009`). `updateLog` (`:1184`) changes an
  amount or a time, and refuses an edit that changes neither.
- **History's row** draws a vessel's glyph and name **guessed from the amount** (`HistoryView.swift:144-154`: *"a log stores
  an amount and nothing else"*), drawn and never spoken. Its sheet edits the amount and the time.
- **Symbols:** iOS has no symbol for milk or a carton, on any version (the system's symbol list, read on this Mac). Tea,
  coffee and juice could borrow `cup.and.saucer.fill`, `mug.fill` and `takeoutbag.and.cup.and.straw.fill`, but those are
  already the Cup's, the Glass's and the takeaway vessel's glyphs (`WaterSurface.swift:238-247`).
- **Three rules close the door today:**
  - rule `70-privacy`: the export is *"Three columns, and nothing else"*; a Health sample is Water, and carries amount,
    instant, id, version and the user-entered mark, *"and nothing else"*;
  - rule `20-state`: the public mutation surface is a fixed list;
  - rule `40-widget`: every one-tap door logs the snapshot's serving, the Glass.
- **The evidence on counting:** in a randomized trial of a *beverage hydration index* (Maughan et al., *American Journal of
  Clinical Nutrition*, 2016; `https://researchonline.ljmu.ac.uk/id/eprint/12468`), the body kept coffee, tea and orange juice
  no differently from water over four hours, and kept milk better.

**Done** is:
- Five drinks in a row on Home and in History's sheet, in four languages.
- `WaterLog` versioned: today's shape frozen as version 1, the drink added in version 2, and a test that opens a store version
  1 wrote.
- Every total counting every drink; History naming each serving's drink; the export carrying it.
- The tests written first and green, the gate passed, the walk on the simulator, and the rules, the policy and the store text
  saying so.
- Released as 1.5 after 1.4.3, each outward step on the owner's word.

## 2. Rulings

- **R1 — which drinks.** Recommended: **the roadmap's four beside water: tea, coffee, juice and milk.** They cover most of what
  people pour, and each drink costs a name in four languages and a place in the row. More can come with 1.5.4. The alternative
  is more now (sparkling water, soda, a sports drink) or an *Other*.
- **R2 — how a drink counts.** Recommended: **in full, every drink, for every user.** 250 ml of coffee adds 250 ml to the day.
  It is what the hydration-index trial found for these four. Every total stays a plain sum, so the six sums, the widgets, the
  watch and Health do not change. And no percentage appears on screen that could read as a health claim. The alternative is
  each drink at its water share (about 99 % for tea, 98 % coffee, 88 % juice, 87 % milk). That changes the six sums, the watch's
  outbox and Health together, and would still be the same for every user, never a Premium setting (`docs/ROADMAP.md` §1).
- **R3 — where a drink is chosen on Home.** Recommended: **a row of five drinks above the vessels — Water, Tea, Coffee, Juice,
  Milk — on Water when the app opens.** A tap chooses a drink. Every pour after that is that drink until another is chosen or
  the app goes to the background; when it comes back, Home is on Water again. So water stays one tap and a coffee is two, and
  someone who drinks tea all afternoon taps *Tea* once. A pour of the wrong drink changes no total (R2) and is fixed in History.
  Alternatives:
  - the choice holds for one pour, then returns to Water: no slip is possible, but every tea is two taps;
  - no row: a drink from a long press on a vessel, or only from History's `+`. Home is unchanged, but the drinks are hard to
    find.
- **R4 — the one-tap doors.** Recommended: **they keep logging water**: the Home Screen and Lock Screen widgets' buttons,
  Control Center, Siri's *Log water*, the reminder's *Log a Glass* and the watch's three pours. Their names say water or the
  Glass, they read one serving from the cache, and the watch's wire format stays as it is. The alternative is drinks on the
  watch, which changes `WristPour`, its outbox and both apps' decoding: a release of its own.
- **R5 — Apple Health.** Recommended: **every drink written as Water at its full amount**, so Health's Water equals the app's
  total, as today. A sample carries exactly what it carries now; the drink is not in it. The alternative is water alone in
  Health, which leaves Health's total short of the app's whenever another drink is logged.
- **R6 — the export.** Recommended: **a fourth column, `drink`**, its value a fixed English word (`water`, `tea`, `coffee`,
  `juice`, `milk`), like the headings. Rule `70-privacy`'s three columns become four (§12). The alternative keeps three
  columns, and a coffee reads as water in the file.
- **R7 — the version.** Recommended: **1.5 (10), after 1.4.3 is released**, as release 1.5's first item. The alternative is
  1.4.4.

## 3. The drink, stored

### 3.1 The model

- `WaterLog` gains `var drinkCode: String?`, absent for water. Every existing row is water with nothing rewritten. Absence
  carries meaning, as it does for `Key.language` and `Key.theme`.
- `Drink`, a `nonisolated` `Sendable` enum in `WaterLog.swift`: `water`, `tea`, `coffee`, `juice`, `milk`. Its raw values are
  the stored codes, in the row's order.
- `WaterLog.drink` reads the code through `Drink(code:)`. A missing code, or one this build does not know, reads as water, and
  says so in DEBUG (rule `75-diagnostics`). Setting water removes the code.
- Nothing else is stored: no new `UserDefaults` key, and no change to the snapshot, the watch's mirror or the wire.

### 3.2 The schema

The shared procedure for a new SwiftData field (the `app-dev` skill's *schema* reference):
1. A probe test reads today's model hashes once, and is then deleted.
2. `WaterBuddySchemaV1` freezes today's `WaterLog` (`id`, `amount`, `timestamp`) as a nested copy, field for field, and a test
   checks it against the probe's hashes.
3. `WaterBuddySchemaV2` lists the live `WaterLog`, with `drinkCode`.
4. `WaterBuddyMigrationPlan` holds one `.lightweight` stage, from 1 to 2.
5. **In the same change**, `sharedModelContainer` opens `Schema(versionedSchema: WaterBuddySchemaV2.self)` with the plan, on
   every rung of its ladder, and a test pins the current schema to the plan's last. A container left on the frozen version
   would open with the frozen class while the code saves the live one (Glazzy's lesson in that reference).

- All of it lives in `WaterLog.swift`, already in all three exception sets, so no target's membership changes (rule
  `15-project`). The entity keeps its name, so the table stays `ZWATERLOG` and the tests' `UnreadableStore` still works.
- The app and the widget extension both open the store, with the same plan, so whichever runs first after the update
  migrates it.
- The ladder is not changed: an App Group store that fails to open still falls back as today. What this change adds is the
  migration, and §9's test opens a real store file that version 1 wrote.

### 3.3 The mutations (rule `20-state`)

- `addLog(amount:at:drink:)`, with `drink` defaulting to `.water`, so every existing caller still logs water. `addWater(amount:)`
  stays water.
- `updateLog(_:newAmount:timestamp:drink:)`, with `drink` defaulting to the row's own. An edit that changes only the drink is
  saved, recomputed and announced like any other (`saveAndRecompute`, `logsDidSaveNotification`).
- `ingest`, the seed from a cached total and `removeWater` stay water.

## 4. Counting

- With R2 no sum changes: today's total, the week's cache, the streak, the month, patterns, Insights, the recap, the widgets'
  figures and the watch's all count every drink in full.
- The words stay. The day's total is still called water, as in *1,300 of 2,000 ml* and in Siri's answer: a drink counts as
  water.
- `lastDrink`, which quiets the next reminder, already reads any row.
- Caffeine is 1.5.4's: it will read the coffee and tea rows. Nothing here counts it.

## 5. Home

- **The row (R3):** Water, Tea, Coffee, Juice, Milk, by name, with no glyphs: iOS has no milk symbol, and the cup, mug and
  takeaway glyphs already name vessels.
  - Each drink is a glass capsule at least 44 pt high. The chosen one takes `LiquidGlass.Selection`'s fill and rim, as any
    selected slot does (rule `60-design-system`).
  - The row sits between the status and the vessels, so the drink and the amount read together.
- **What it costs:** the row's height comes out of the vessel's, through `HomeColumn`, which already gives the vessel what is
  left. Large text raises the vessel's ceiling and never its floor (rule `65-accessibility`). Below the floor the page scrolls,
  as it does today.
- **Large text:** when the five do not fit, the row scrolls sideways (`ViewThatFits`). A capsule never shrinks below 44 pt.
- **The choice** is presentation state, an `@State` on `HomeView`, never stored. It is Water when the app opens, and again
  when the app goes to the background, where the *Undo* offer already ends.
- **A pour** makes one call, `manager.addLog(amount:drink:)`, with the chosen drink (rule `50-views`). *Undo* is unchanged: it
  takes back the row it was handed.
- **VoiceOver:** each drink is one button, labelled with its name, with `.isSelected` on the chosen one. The vessels' labels
  are unchanged.
- **Haptics:** choosing a drink plays `Haptics.select`, the tick for a choice among peers, from a counter the tap bumps.

## 6. History

- **A row** shows its drink where it shows a vessel name today: *Coffee* for a coffee, and for water the vessel guessed from
  the amount, as now. The glyph stays the vessel's, or the drop. A drink is stored, not guessed, so VoiceOver says it: *Coffee,
  150 millilitres*. Water rows speak as today.
- **The sheet** gains the same five capsules, above the amount.
  - `+` starts on Water; editing starts on the serving's own drink.
  - *Save* writes the drink with the amount and the time.
  - Month mode stays read-only.
- The day strip's bars and the week card count every drink.

## 7. What leaves the app

- **Apple Health (R5):** no change. A serving is Water at its full amount. `HealthPlan` compares the amount and the instant,
  and a change of drink alone changes neither, so nothing is saved again.
- **The export (R6):** `date,time,amount_ml,drink`, one row a serving, oldest first. `ServingsExport.Serving` gains the drink,
  and the sheet's line, *Date, time and amount in millilitres, nothing else*, names the drink, in four languages.
- **The watch (R4):** no change. Its pours are water, and its figures come from the phone's total.
- **The widgets, the control, Siri and the reminder's button (R4):** no change.
- **The privacy policy** (`PRIVACY.md`, published as `Tools/PrivacyPolicy.html`): a serving is its amount, its time *and what
  was drunk*, and the export has its fourth column. It is published before 1.5 is submitted, on the owner's word.

## 8. The words

- **New keys**, in all four languages, in the app's catalogue alone:
  - the five drinks' names;
  - a row's spoken label, *%1$@, %2$d millilitres*, with plural forms;
  - the export sheet's reworded line.
- A drink's name stands alone, as a label, and is never inflected into a sentence, so no language needs a case for it.
- The names, for a second agent to check against the app's glossary, as was done for Spanish:

  | English | Russian | Uzbek | Spanish |
  |---|---|---|---|
  | Water | Вода | Suv | Agua |
  | Tea | Чай | Choy | Té |
  | Coffee | Кофе | Qahva | Café |
  | Juice | Сок | Sharbat | Jugo |
  | Milk | Молоко | Sut | Leche |

- **The store text**, in four listings: one line in the description's LOGGING (*Water, tea, coffee, juice or milk: each counts
  toward your goal*), and What's New.
- **The screenshots:** Home's row changes shot 1, so the store set is captured again for 1.5 (lesson of 2026-11-26: a feature
  that changes a captured screen leaves its shot stale). The capture's sample week gains a morning coffee and an afternoon tea,
  so History's shot 4 shows the names. The header's drawing is an illustration, not a capture, and keeps its vessel.

## 9. How it is proved

- **Tests first, each run RED:**
  - the schema: the frozen version 1 matches the probe's hashes. A store that version 1 wrote, on disk in a temporary folder,
    opens under version 2 with every row water and every amount and time intact. A drink saved survives a reopen. The current
    schema is the plan's last;
  - `Drink`: its codes, its order, and an unknown code reading as water;
  - `DataManager`: `addLog` stores a drink; every total counts every drink in full (today, the week's cache, the streak, the
    month); a drink-only `updateLog` is saved and announced, and `everyWayAServingChangesAnnouncesTheSave` gains it;
  - `ServingsExport`: the four columns, byte for byte;
  - Home's choice, as a pure static: Water at first, kept across pours, Water after the background;
  - `LocalizationTests`: the new keys in every language;
  - UI tests: the row is five buttons with one selected; *Coffee* and then the Glass makes a row History names *Coffee*; the
    sheet changes a serving's drink.
- **The gate:** the five invocations on iOS 27.0, and the UI suite on 18.6. Warnings are compared by file and message with a
  clean build of `main`.
- **The walk**, on the simulator:
  - the row at the default and the largest text size, in English and Russian, on the smallest and the largest iPhone;
  - a coffee poured, undone, poured again, changed in History and exported;
  - the widgets and the watch drawing a total with a coffee in it;
  - a real migration: 1.4.3 installed and used first, then this build installed over it, its servings all still there.

## 10. The order of the work

1. **The branch:** `feature/other-drinks` from `main` at `4b5c8f3`.
2. **The probe,** then the failing tests, run RED.
3. **The schema and the model,** then the mutations; GREEN.
4. **Home's row, History's row and sheet, and the export.**
5. **The words:** written, checked by a second agent, and a table for you.
6. **The rules, the policy and the docs.**
7. **The gate and the walk.**
8. **The release** as R7: the captures, the store text, the version and the archive, each outward step on your word.

## 11. Decisions

Mine, recommended, for you to change at review:
- **D1.** `drinkCode: String?`, absent for water; an unknown code reads as water.
- **D2.** Version 1 frozen and version 2 live, in `WaterLog.swift`; the store's fallback ladder unchanged.
- **D3.** Drinks by name, with no glyphs.
- **D4.** Home's choice is not stored, and goes back to Water in the background.
- **D5.** *Undo* unchanged.
- **D6.** The day's total is still called water.
- **D7.** No per-drink figures in History, Insights or the recap: that is 1.5.4's, or later.
- **D8.** A drink's name is never inflected into a sentence.
- **D9.** The spec is the plan, as for Spanish and 1.4.2: §10's order, built in the main loop, tests first (`CLAUDE.md`).

## 12. The rules this needs

The rule files are yours; approving this design lets me change these lines:
- `70-privacy`: the export's columns become four, `drink` the fourth, a fixed English word. Health's section is unchanged:
  every drink is Water, and the sample carries nothing new.
- `20-state`: the mutation surface reads `addLog(amount:at:drink:)` and `updateLog(_:newAmount:timestamp:drink:)`; a
  serving's missing drink means water.
- `65-accessibility`: Home's drink row, and History's spoken drink.
- `50-views`: Home's choice is presentation state; History's sheet edits the drink.
- `43-concurrency` and `85-testing`: `DrinkTests` joins the suites that are deliberately not `@MainActor`. The schema's test
  may open a store on disk, in a temporary folder of its own, never the App Group's.
- None for `15-project`, `25-shared-storage` or `40-widget`.

And through `/doc_sync`: `CLAUDE.md`'s storage table and `docs/STATE.md`'s `WaterLog` (with the schema versions),
`docs/ROADMAP.md`'s 1.5.1, `docs/AI_CONTEXT.md`, `HISTORY.md`, and a lesson where one is learned.

## 13. Risks

- **The migration** is the one way this change could lose data. §3.2 versions the schema, §9 tests it on a real store file,
  and the walk installs over 1.4.3.
- **Home's room:** the row costs the vessel about 52 pt. The walk measures it on the smallest iPhone at the largest text size.
- **A drink forgotten:** a drink chosen and left logs the next pours as that drink. R3 limits that to one visit, and no total
  changes.
- **The words:** five names in four languages, checked as §8 says.

## 14. Yours, or mine on your word

- Approve this design, and rule R1–R7.
- Read the names' table when it comes.
- **On your word, each time:** each push, the policy's publication, the upload, the version page and *Submit for Review*.
- **Before 1.5:** 1.4.3's TestFlight checks and its release.

## 15. Not in this work

- Caffeine (1.5.4), per-drink figures, and drinks on the watch, the widgets or Siri.
- A drink of the user's own, or a drink set on a vessel of the library, which is Premium.
- Any change to the store's fallback ladder.
