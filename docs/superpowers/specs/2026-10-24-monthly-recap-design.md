# Monthly recap — design

**Status:** approved by the owner in conversation on 2026-10-24, in this order: step 5 is the session's
task ("Step 5: Monthly recap"); the recap appears on **every finished month's page, and on the new month's
page for its first seven days** ("Finished month + new month's first week"); the month's best streak sits
**in the sheet, off the image** ("In the sheet, off the image"); if the share sheet's *Save Image* needs a
usage key, **Save to Photos is left out** ("Leave Save to Photos out"); a month has a recap once it holds
**water on seven or more days** ("Water on 7 or more days"); approach A, **the finished month read when the
sheet opens** ("ok"); then the design's four sections — what you see, how it is built, the words and
accessibility, the rules and the proof — each answered "ok". This document writes those sections down;
where it adds a detail they did not show, the detail is marked **decided here** for the owner to read.

The look follows the concept board *Monthly recap* on the design canvas
(https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, `project/Recap.dc.html`, 2026-10-21), except where §3
differs from it: the change line compares daily averages, as the month view's does, not goal days (§3.4);
the sheet's heading is *Monthly recap*, not *Your month* (§3.10); the way in is a row in Month mode (§3.2),
which the board did not draw.

It is **step 5 of 5** of set A (`docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md`,
§1) and roadmap item 1.4.7. It builds on step 2's month and **puts set A on sale** (§3.8).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`
(rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document changes.

**Provenance.** Every claim about the repository was read at HEAD `ad244c2` on 2026-10-24. Claims are
marked **measured** (read or run on this toolchain), **stated** (an Apple source says it), **inferred**, or
**unconfirmed**.

## 1. Where this sits

| Step | Builds | Roadmap |
|---|---|---|
| 1 | the monthly plan, the paywall and the Settings card — committed `d5cf816` | 1.4.1, amended |
| 2 | the month view and full history — committed `40e7e41` | 1.4.2 |
| 3 | patterns — committed `d9e7db7` | 1.4.6 |
| 4 | insights — committed `ab86efa` | 1.4.12 |
| **5** | **this document** — the monthly recap, and set A put on sale | 1.4.7 |

## 2. What exists today (measured)

- **`MonthHistory`** (`WaterBuddy/DataManager.swift:2650`) already carries every figure the recap draws:
  `daysMet` and `daysCounted`, `bestRun` (the longest run of met days inside the month, not carried over),
  `total` (saturated), `average` and `change` — **this month's average less the month before's**, not a
  count of goal days. Every day is judged against the current goal; the first month counts from the first
  serving's day. `make` (`:2755`) is pure, `nonisolated`, and takes rows that reach into the month before.
  `Neighbour` (a month's 1st and its first instant, "for formatting an arrow's label and nothing else")
  exists for the arrows.
- **`republishMonth()`** (`:1202`) makes two reads — one range query from the 1st of the month before to
  the end of the wanted month, and `readOldestLog()` — and returns on either failing, behind
  `role.drawsHistory`. `MonthHistory.firstDay(ofMonthHolding:in:)` is at `:2715`.
- **`MonthPatterns.minimumDays`** is `7` (`:2907`): patterns say something once seven finished days hold
  water.
- **History's month page** (`WaterBuddy/HistoryView.swift`, 3,428 lines): `monthRows` (`:541`) draws the
  month card, `MonthFigures` (`:1776`) when a day counts, then the patterns. `MonthFigures` draws *Days on
  goal* (`%1$@/%2$@`), *Best streak* (`%1$d days`), *This month* (`%1$@ L`, through
  `HistoryView.litres(_:locale:)`, `:229`), *Average %1$@ ml a day* and the change line — *Up / Down %1$@
  ml on the month before*, *The same as the month before* — which names no month, because Russian would
  need the prepositional case Foundation does not produce. Every drawn figure has a spoken twin in
  millilitres. History presents two sheets with `.sheet(item:)` (`:413`, `:426`) and lets go of the month
  on `.onChange(of: holdsPremium)` (`:387`).
- **The free user's locked month** already promises the recap: *Every day you have logged is kept. Premium
  shows it as months, with your patterns and a recap.* (`:2498`).
- **`PremiumSet`** (`WaterBuddy/PremiumSet.swift`): `Feature.recap` — `doc.text.image`, *A monthly recap*,
  *Your month in one card, yours to share* (ru *Итоги месяца*; uz *Oylik xulosa*) — and `isOnSale`, `false`
  for `.understand` (`:95`), pinned by `PremiumSetTests.setAIsNotOnSaleUntilItsLastFeatureIsBuilt`.
  **`PaywallView.isOffered(arguments:)`** (`WaterBuddy/PaywallView.swift:59`): DEBUG reads
  `-WaterBuddyPremium`; Release needs a set on sale **and** an `https` `privacyPolicy`, which is still the
  token `OWNER-PRIVACY-URL` (`:53`, known issue #159).
- **The paywall's close button** (`PaywallView.swift:186`): an `xmark` in a `.sheer`, `.resting`,
  interactive glass circle of `PaywallStyle.closeSize`, `PressStyle`, labelled *Not now*.
- **No share code**: no `ImageRenderer`, `ShareLink`, `UIActivityViewController` or `Transferable` anywhere
  in `WaterBuddy/`. No Info.plist carries an `NS*UsageDescription` key, and rule `70-privacy` forbids one.
- **Nothing presents itself** at launch or on returning to the foreground; there is no "has seen" flag
  among the 13 keys.
- **No UI test can hold Premium**: every `PremiumUITests` run is a free user, and no DEBUG argument makes a
  holder. Steps 2–4 proved a holder's pages by hand, through the scheme's local StoreKit configuration.
- **Whether *Save Image* in the share sheet needs `NSPhotoLibraryAddUsageDescription`**: **measured**
  (Task 0, §4a) — **iOS does not offer *Save Image* at all to an app without the key**, on 27.0, 26.5 and
  18.6, so it cannot end the app; with the key it is offered and works. (Before the measurement this read
  *unconfirmed*: the widely reported crash said it did; one Apple Developer Forums thread on `ShareLink`
  crashed for a different reason with the key present; nothing found spoke of iOS 27.)

## 3. The design

### 3.1 Which months have a recap

A **finished** month — one before the month holding today, on the model's calendar — has a recap when
**seven or more of its days hold water** (`MonthPatterns.minimumDays`, by name, so the two bars cannot
drift). A day holds water when its total is above zero; a day before the first serving holds none, so the
first month is judged on its own days.

Each month page offers at most one recap:

- **a finished month's page** offers its own, when it qualifies;
- **the month holding today**, while today is one of its first seven days (`MonthHistory.recapDays`, `7`,
  **decided here** as a named constant beside `minimumDays`), offers **the month before's**, when that
  qualifies — so the recap meets the user at the turn of the month without a key or a launch-time
  presentation;
- otherwise none. The month holding today never offers itself.

The day of the month is today's on the injected calendar (rule `30-rollover`): a traveller crossing a date
line moves the first-week window with the day, as the month does.

### 3.2 The way in: the *Monthly recap* row

In Month mode, straight after the month's figures (or where they would be, when no day counts yet) and
before the patterns, a
frosted, raised glass row: the feature's glyph `doc.text.image` on the left, *Monthly recap* as its title,
the offered month's name and year under it — `Text(date, format: .dateTime.month(.wide).year())`, the
month card's own spelling, never keyed — and a chevron. It is drawn only where `MonthHistory.recap` (§3.6)
is not `nil`. The month's name is never put inside a sentence: Russian would need a case Foundation does
not produce, and Uzbek writes *your* as a suffix (*Sentabringiz*).

A tap reads the recap once (§3.6) and opens the sheet. A read that fails opens nothing. A free user never
reaches Month mode, so never meets the row.

### 3.3 The sheet

On its own `AuroraBackground()`, `.preferredColorScheme(.dark)` declared on it (rule `50-views`), wrapped in
the screen-of-type pattern (`GeometryReader { ScrollView { … .frame(minHeight:) } }`) so it centres at
ordinary sizes and scrolls at the accessibility ones:

1. a header row — *Monthly recap*, the header trait — and the close button, the paywall's own (an
   `xmark` in a `.sheer` interactive circle of `PaywallStyle.closeSize`, `PressStyle`), labelled *Done*
   (**decided here** — the paywall's *Not now* answers an offer; this sheet has none, and *Done* is an
   existing key);
2. **the card** (§3.4), on screen at the sheet's width less the margins;
3. **the best streak**, a frosted, raised glass pane: *Best streak* and `%1$d days`, and under it *Stays
   in the app, not on the image*;
4. **Share as an image**, the screen's one primary surface (`.primarySurface(in:)`), with the share glyph
   `square.and.arrow.up`; disabled until the image is rendered;
5. *The image leaves your phone only when you send it.*, a footnote — on its own frosted, raised pane,
   the streak pane's pair (corrected while planning, 2026-10-24: sentence-length text never stands bare
   on the aurora, `tasks/lessons.md` 2026-10-22; the heading takes `legibleOnBackdrop()`, as every
   screen's text on the aurora does).

Small cyan text is assumed to fail until a render says otherwise (the same lesson): the card's month
label is measured in the walk, and drawn white if it reads under 4.5:1.

If Premium stops being held while it is open, History clears the sheet's selection and it closes, on the
same `.onChange(of: holdsPremium)` that lets go of the month.

### 3.4 The card, and the image

The card is the image: one view, `RecapCard`, drawn on screen and rendered, from the same values.

- **Its canvas** is `Aurora.gradient` in a `LiquidGlass.cornerRadius` rounded rectangle, marked with
  `.premiumRim()`. It is not glass, so glass rules about backdrops do not reach it.
- **Its header**: the month's name and year, upper-cased in the app's locale, in `Aurora.cyan`; at the
  trailing edge the drop glyph and *WaterBuddy*.
- **The hero**: `%1$@/%2$@` (days met over days counted) in a large rounded bold, over *Days on goal*.
- **The dots**: one per day of the month, in date order, rows of ten — no weekday alignment, so no first
  weekday enters the image. A met day is a filled `Aurora.cyan` dot; an unmet counted day a white ring; a
  day that counts in nothing (before the first serving) a faint filled dot. Met and unmet differ in shape,
  never in colour alone (rule `65-accessibility`).
- **Two tiles**, side by side: the month's litres (`%1$@ L`) over *This month*; the average (`%1$@ ml`) over
  *A day, on average*. Each is `.liquidGlass(…, base: .archived)` — the widget's flat base, because a still
  image, like a widget snapshot, has no live backdrop to sample and a `Material` would resolve against
  nothing (rule `40-widget`'s ruling, applied to its second case). The average tile is absent when
  `average` is `nil`.
- **The change line**, when `change` is not `nil`: the month view's glyph (`arrow.up.right`,
  `arrow.down.right`, `equal`) in `Aurora.cyan` and its drawn line, *Up / Down %1$@ ml on the month before*
  or *The same as the month before*.

No streak, no goal, no serving and no time of day is on the card.

**The image** (`RecapCard.image(of:strings:locale:)`, `@MainActor`, a `static func` in `RecapCard.swift`):
`ImageRenderer` over the card on a margin of `Aurora.top`, **360 pt wide, at scale 3 — 1,080 px wide**,
height as the content needs, with `\.strings` and `\.locale` injected from the app's language,
`\.colorScheme` set to `.dark` (a renderer has no hosting controller for `.preferredColorScheme` to reach —
the one app use of the widget's spelling, argued in §3.11), and `.dynamicTypeSize(.large)` so the picture
never depends on the sender's text size. It is rendered when the sheet appears and kept in the sheet's
`@State` as a `UIImage` — in memory only: no file, no key, neither store. Under Reduce Transparency the
tiles take their opaque fill, in the image as on screen.

### 3.5 Sharing

**Task 0 decides the control** (§4): on iOS 27.0 and 26.5, in a scratch copy of the app, does pressing
*Save Image* in the share sheet terminate an app that carries no `NSPhotoLibraryAddUsageDescription`?

- **It does not**: `ShareLink(item: Image(uiImage:), preview: SharePreview(…))`, the preview titled *Monthly
  recap* with the image.
- **It does**: `ShareSheet.swift`, a `UIViewControllerRepresentable` around `UIActivityViewController` with
  the image as its one item and `excludedActivityTypes = [.saveToCameraRoll]`, presented with
  `.sheet(item:)` on the rendered image's selection (rule `50-views`). The rule's *one permission, no usage
  key* stands as written. The user can still send the image to Messages, AirDrop, Mail and other apps, or
  save it to Files.

Either way the app learns nothing of where the image went: no completion handler records anything.

### 3.6 The model (`WaterBuddy/DataManager.swift`)

- **`MonthHistory.recap: Neighbour?`** — the month whose recap this page offers (§3.1): its 1st and its
  first instant, the latter for formatting the row's label only, as an arrow's is. (**Decided here**: the
  section shown named it `recapMonth: Int?`; a `Neighbour` also carries the instant the row formats, so
  the view works out no date of its own.) Worked out in `make`
  from the rows it is handed, which already reach the month before (`republishMonth()` reads them for
  `change`), so it costs no read. `make`'s DocC gains that its rows must reach the month before for the
  first-week offer as well as the change.
- **`MonthHistory.recapDays`**, `7`, `nonisolated static let`.
- **`MonthHistory: Identifiable`**, `id` its `firstDay`, so a month can be a `.sheet(item:)` selection —
  declared on the type, in this file, where its isolation is the type's.
- **`DataManager.recap(of firstDay: Int) -> MonthHistory?`** — a read, returning a value and publishing
  nothing. Behind `role.drawsHistory` (`nil` elsewhere, for `republishMonth()`'s reason). It makes the same
  two reads, through one private helper that `republishMonth()` now calls too —
  `readMonth(_:) -> (rows: [WaterLog], month: MonthHistory)?` — and returns the month only when its own
  `recap` names itself; `nil` on a failed read or a month that does not qualify. **It writes neither
  store**, rings no doorbell, reschedules nothing and touches neither `month` nor `monthLogs`: it is not on
  rule `20-state`'s mutation surface, and joins `showMonth(_:)` among the reads.

No key and no stored figure. (*Corrected in the records, 2026-10-24:* this line also said "no new `role`
site", against the bullet above — `recap(of:)`'s `role.drawsHistory` guard is the **tenth guarded site**,
by the census's own reckoning, which counts `republishMonth()` and `republishInsights()`, reads too.)

### 3.7 The views (app-only)

- **`WaterBuddy/RecapCard.swift`** — the card (§3.4) and its `image(of:strings:locale:)`.
- **`WaterBuddy/RecapSheet.swift`** — the sheet (§3.3), handed its `MonthHistory` through `init`.
- **`WaterBuddy/ShareSheet.swift`** — only if Task 0 says *Save Image* needs the key (§3.5).
- **`WaterBuddy/HistoryView.swift`** — the row, as a `private struct` beside `MonthFigures`; `@State private
  var recap: MonthHistory?`; a third `.sheet(item: $recap) { RecapSheet(month: $0) }`; the tap
  `recap = manager.recap(of: offered.firstDay)`; `recap = nil` in `.onChange(of: holdsPremium)` when it
  turns false. Roughly fifty lines; the sheet and the card stay out of a file already at 3,428 (#176).

None joins an exception set: the widget and the watch never draw a recap (rule `15-project`).

### 3.8 Going on sale

`PremiumSet.isOnSale` answers `true` for `.understand`: every feature it lists is built.
`PremiumSetTests.setAIsNotOnSaleUntilItsLastFeatureIsBuilt` becomes `setAIsOnSaleNowEveryFeatureIsBuilt`;
`PaywallOfferTests` is re-read against it — a set on sale with no `https` link is still not offered, so
its Release cases hold. A DEBUG build is unchanged. **A Release build offers the paywall only once the
privacy policy's URL replaces the token** (#159): step 5 puts the set on sale in code, and the owner's URL
and App Store Connect's products (#155) put it in front of a customer.

### 3.9 Accessibility

- **The row** is one button: label *Monthly recap*, value the month's name and year, `minHeight` 56,
  `.contentShape`, `PressStyle`.
- **The heading** carries the header trait; the close button is labelled *Done*.
- **The card** is one element: label *Monthly recap*; value the month's name and year, then *%1$d of %2$d
  days on goal*, `%1$d millilitres` (the month's water), *Average %1$d millilitres a day* and the spoken
  change — every one an existing key. The dots, the rim, the glyphs and the mark are hidden.
- **The streak pane** is one element (`.combine`), its footnote included.
- **The button** is labelled by the words it draws; the footnote is plain text.
- **Text size**: on screen the card follows it — the tiles a row or a column through `ViewThatFits`, as
  `MonthFigures`' are, the hero bounded with `.lineLimit(1)`, `.minimumScaleFactor` and the card's width.
  The image is always the default size (§3.4).
- **Reduce Motion**: nothing moves. **Reduce Transparency**: the tiles' opaque fill.
- **Contrast**: every pair measured off renders — on screen and on the PNG — never derived from a token: the
  cyan month label on the gradient, the white labels, the met and unmet dots at the 3:1 non-text floor.
  iOS 27.0 in English; 26.5 and 18.6 named unmeasured, as steps 2–4 did.

### 3.10 The words

Reused, already in three languages: *Days on goal*, `%1$@/%2$@`, *This month*, `%1$@ L`, `%1$@ ml`, *Best
streak*, `%1$d days`, the three drawn and three spoken change lines, *%1$d of %2$d days on goal*, `%1$d
millilitres`, *Average %1$d millilitres a day*, *Done*.

New, in the app's catalogue only (no widget or watch string, so `sharedKeys` is untouched). The Russian and
Uzbek are **drafts**, following step 1's word for the feature, for the owner's sweep with #170, #175 and
#179:

| Key (`en`) | ru (draft) | uz (draft) | Where |
|---|---|---|---|
| *Monthly recap* | *Итоги месяца* | *Oylik xulosa* | the row, the heading, the card's spoken label, the share preview |
| *A day, on average* | *В среднем за день* | *Kuniga o‘rtacha* | the average tile |
| *Share as an image* | *Поделиться картинкой* | *Rasm sifatida ulashish* | the button |
| *Stays in the app, not on the image* | *Остаётся в приложении, не на картинке* | *Ilovada qoladi, rasmda emas* | under the streak |
| *The image leaves your phone only when you send it.* | *Картинка покидает телефон, только когда вы её отправите.* | *Rasm telefoningizdan faqat siz yuborganingizda chiqadi.* | under the button |
The card's mark, *WaterBuddy*, is **not new** (corrected while planning, 2026-10-24: the section shown
counted it as a sixth key): the app's catalogue already holds it, English only, and
`LocalizationTests.everyDrawnStringIsTranslatedUnlessDeliberatelyNot` already lists it as deliberately
untranslated — the product's name. Five keys are new.

No key carries a digit or a format specifier the translation could drop.

### 3.11 What it amends in the rules (typed unstaged, for the owner)

- **`70-privacy`** — a section *The recap's image, on the user's own tap*: the image leaves only through the
  system share sheet, from *Share as an image* in the recap sheet — never from the widget, the watch, Siri,
  the control or a notification; it carries the card's figures alone — the month, days met of days counted,
  the dots, the litres, the average, the change — never the streak, a serving, a time of day or the goal;
  it is rendered in memory, written to no file and neither store; no usage key, and *Save to Photos* is
  left out if it would need one (per Task 0); the app records nothing about where it went. *Nothing leaves
  the device* gains a pointer to it.
- **`20-state`** — the streak "never leaves the app", **the recap's image included**; `recap(of:)` named
  beside `showMonth(_:)` as a read that writes neither store; `MonthHistory.recap` a consequence, derived.
- **`60-design-system`** — `.premiumRim()` marks the recap card too; the card's tiles take `base:
  .archived` in the app, the one use outside the widget, for a rendered image's reason; *Share as an image*
  is the recap sheet's primary surface.
- **`50-views`** — the row drawn where `MonthHistory.recap` says, the recap sheet `.sheet(item:)` on a
  `MonthHistory` read once on the tap; the first-week entrance argued as a second way in to one sheet; the
  renderer's `\.colorScheme` environment as the app's one use of that spelling.
- **`65-accessibility`** — the row, the card as one element, the streak pane, the image at the default
  text size.
- **`15-project`** — `RecapCard`, `RecapSheet` (and `ShareSheet`) app-only, in no exception set.
- **`85-testing`**, **`43-concurrency`** — `MonthRecapTests` on the canary lists; the share sheet proved
  only by hand.

`CLAUDE.md` and the sheets follow in `/doc_sync`.

### 3.12 Testing

Each written first and run RED — by compile, then by behaviour:

- **`MonthRecapTests`** (`WaterBuddyTests/`, not `@MainActor`; `make` with an injected calendar and clock):
  a finished month with water on seven days offers itself, on six offers nothing; the month holding today
  never offers itself; on its 1st and its 7th it offers the month before when that qualifies, on its 8th
  nothing; a month before that falls short is not offered; a first month is judged on its own days; the
  window follows the injected calendar's day across a time-zone change; the offer's `start` is the offered
  month's first instant.
- **`RecapReadingTests`** (`@MainActor`, a UUID-named suite, an in-memory store, `reloadWidgets` counted,
  `rescheduleReminders: { _ in }`): `recap(of:)` returns a qualifying month whose figures equal
  `MonthHistory.make`'s over the same rows; `nil` for one that falls short and for the month holding today;
  the suite's keys and values are identical before and after; no reload rings; `month` and `monthLogs` stay
  as they were, published or not.
- **`RecapImageTests`** (`@MainActor`): the image is 1,080 px wide; rendered with the environment set to
  the largest accessibility size it is the same size as at the default; it renders in all three
  languages.
- **`PremiumSetTests`** — set A on sale; **`PaywallOfferTests`** re-read.
- **`LocalizationTests`** — the five new keys join `historyKeys`, so each resolves in `en`, `ru` and `uz`
  from the app bundle with its arguments kept; *WaterBuddy* is already on the English-only list.
- **UI**: no change — no UI run can hold Premium (§2); the ordinary runs' *no month switch* tests stand.

## 4. Verification

- **Task 0, the measurement**, before any product code: a scratch copy of the app under the session's
  scratchpad, never the repository; a throwaway button sharing a rendered image; *Save Image* pressed with
  the key absent, on iOS 27.0 and 26.5; the result — and whether the copy kept running — recorded in this
  document and the code's DocC. It picks §3.5's branch.
- **The gate** (rule `85-testing`): the five invocations, one simulator at a time, `-parallel-testing-enabled
  NO`, and the UI suite again on 26.5; warnings compared by file and message against a clean build of a
  `HEAD` export.
- **The walk**, on the simulator, holding Premium through the scheme's local StoreKit configuration: a
  finished month's row and sheet; the share sheet — *Save Image* absent or working, as Task 0 ruled — the
  image sent to Files and opened there; the image and the sheet in Russian and Uzbek and at the largest text
  size; Reduce Transparency; a lapse while the sheet is open (refund in the StoreKit configuration). The
  simulator runs on today's date, the 24th, so **the first-week row is proved by the tests and a
  `#Preview`**, not the walk.
- **Contrast** off the walk's renders, on screen and on the PNG (§3.9), into `docs/DESIGN.md`.
- **Owed to a device**: sharing into real apps, VoiceOver by ear, #156's purchase.

## 4a. Task 0's measurement (2026-10-24)

A throwaway probe in a scratch copy of the app (never the repository): a `ShareLink` sharing one image
rendered by `ImageRenderer`, launched by a throwaway UI test that opened the share sheet, opened *View More*
where there is one, saved a screenshot and queried every cell for *Save Image*.

| Runtime | Key | *Save Image* | What the sheet offered |
|---|---|---|---|
| iOS 27.0, *iPhone 17* | absent | **not offered** | Copy, Assign to Contact, Print; behind *View More*: Add to Shared Album, Create Watch Face, Save to Files |
| iOS 27.0, *iPhone 17* | present (a command-line build setting, the control) | offered, in the first row; pressed, the app kept running (state 4) | — |
| iOS 26.5, *iPhone 17* | absent | **not offered** | as 27.0 |
| iOS 18.6, *iPhone 16e* | absent | **not offered** (no *Save Image* cell anywhere in the sheet's tree) | Copy, Assign to Contact, Print, Add to Shared Album, Create Watch Face, … (18's list layout; it has no *View More*) |

**§3.5 takes the `ShareLink` branch.** The owner's ruling — *Save to Photos* left out, one permission, no
usage key — holds by iOS's own behaviour, with no exclusion code; `ShareSheet.swift` is not written. iOS
17.x is unmeasured (no runtime installed — the floor is compile-verified only, rule `85-testing`). *Add to
Shared Album* and *Create Watch Face* are share targets like any other: the image reaches them only on the
user's own tap.

## 4b. The walk (2026-10-24)

On *iPhone 17*, iOS 27.0, in a scratch copy: the fresh start's in-memory store seeded with August and
September, a lifetime purchase from a stand-in StoreKit source, Reduce Transparency forced by a launch
argument, each rendered image written to the scratchpad; a throwaway XCUITest walked History → Month →
September → the row → the sheet → the share sheet, in English, Russian, Uzbek, at the largest
accessibility text size and under Reduce Transparency, and let the purchase lapse with the sheet open.

**Seen as designed**: the row on a finished month's page, one button; the sheet; VoiceOver's value for
the card in all three languages (*September 2026, 23 of 30 days on goal, 69 600 millilitres, Average 2 320
millilitres a day, Up 420 millilitres on the month before*); the share sheet with the card as its preview,
titled *Monthly recap*, and no *Save Image*; the image 1,080 × 1,197 px, the card alone, no streak; the
Russian change line wrapping to two lines, never cut; the image at the largest text size **identical in
size** to the default; under Reduce Transparency every pane opaque and legible; a lapse closing the sheet
when the app returned to the foreground (Review Focus 5).

**Findings, and what was done**:
- **W1 — the tiles read grey-brown.** `Base.archived`'s derived fill (`white 0.24` at 50 %) over the card's
  gradient, where the concept board drew a light white wash and the app's own panes on iOS 26 are Apple's
  glass tinted `Aurora.top`. Not retuned: rule `60-design-system` derives every token and forbids choosing
  one by eye, and `archived` is the base rule `40-widget` names for a rendered pane. **For the owner** — a
  measured flat base of the recap's own, or `archived` as it stands.
- **W2 — at the largest text size the header cut both the month (*SEPTE…*) and the mark (*Wate…*).** Fixed:
  `ViewThatFits` takes the one line where it fits and stacks the two where it does not, the month allowed
  to wrap. Re-walked: *SEPTEMBER / 2026* and the mark whole; the English image byte-identical to before.
- **W3 — at the largest text size the close button's ✕ outgrew its 44-pt circle.** Fixed: the glyph is
  sized as a share of the circle (17/44), rule `65-accessibility`'s ratio. Re-walked. The paywall's close
  button is written the same way — not changed here (one logical change), for the owner.
- **W4 — the row's cyan glyph read 2.6:1** on frosted glass where the aurora's cyan light passes (known
  issue #177's effect; the identical glyph on the average line read 5.6:1). Fixed: white, re-measured
  5.12:1.

**A correction to §3.4** (**inferred**, not seen — the walk forced Reduce Transparency inside the glass
modifier itself, which reaches the renderer too, so it could only show opaque tiles): an
`ImageRenderer` does not inherit the screen's environment, so the image is rendered **without** Reduce
Transparency whatever the sender's setting, as it is at the default text size — a picture sent to
someone else carries the design's own tiles. On screen the card follows the setting, as above.

**The sheet is top-aligned**, where §3.3 said it centres at ordinary sizes: its heading carries the
close button, which belongs at the top, and the content is shorter than the sheet at every ordinary
size. Recorded after the final review (M8).

## 4c. The final review (2026-10-24)

A fresh reviewer read the staged diff with this document, the plan and the rules. No critical finding.
**I1** — whether `ShareLink`'s exported picture keeps the image's 1,080 px: measured, not assumed —
`RecapImageTests.theSharedPictureKeepsItsPixels` exports `RecapSheet.sharedItem(_:)` as PNG through
`Transferable.exported(as:)` (iOS 18.2 and later; the gate runs 27.0) and reads 1,080 px; a mutation to
a system glyph failed it. SwiftUI's `Image` keeps the pixels, so no wrapper type was added. **I2** —
`theLargestMonthStillRenders` now renders a 31-day month at `maximumDailyIntake` every day, the one
layout with a fourth row of a single dot, and asserts it is taller than a 30-day month. The minors are
the owner's, in `docs/AI_CONTEXT.md`.

**Contrast**, off the renders (WCAG, ground at its 90th-percentile brightness): on the image — the cyan
month label **7.35:1** (7.36 Russian; it stays cyan), the mark at 0.86 9.86, *23/30* 12.43, *Days on goal*
12.17, a tile's figure 12.03, its label at 0.86 9.34 (6.67 Russian), the change line 10.20, its glyph
5.79, a met dot 6.67, an unmet ring **3.10** (floor 3:1), the rim 5.91; on the sheet — the heading on the
aurora 9.60, *Best streak* 5.57, its days 8.84, its footnote at 0.9 5.04, *Share as an image* on white
11.45, the footnote's pane 6.33, the ✕ 9.89; under Reduce Transparency the footnotes 9.94 and 12.03 and a
tile's label 9.34; the row — its title 6.17, the month at 0.9 5.52, the glyph (white) 5.12, the chevron
9.38. iOS 27.0, English but where named; 26.5 and 18.6 unmeasured.

## 5. Open questions

- **The privacy policy's URL** (#159): the one thing between set A on sale in code and a Release build
  offering it. Step 5 does not wait for it.
- The Russian and Uzbek drafts (§3.10), for the owner's sweep with #170, #175 and #179.
- App Store Connect's products and a device purchase (#155, #156) stay the owner's, before any release.
