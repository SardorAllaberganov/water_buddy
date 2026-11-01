# Export — design

**Status:** **approved by the owner, 2026-11-01 ("ok"), D4–D15 as recommended.** Roadmap item **1.4.4**, Premium,
size Small. Taken by `/start_task` with no task named, on the owner's choice *Export* over set C, the workout-aware
goal and other drinks. D1–D3 are the owner's, chosen in chat the same day. That "ok" also approves the rule wording in
§3.12 (`docs/ROADMAP.md` §8 asks for that approval before any code); the wording is typed and left unstaged for the
owner's `/commit`.

**Out of scope:** a date range, an import, any format but CSV, the store listing, and merging: `main` stays the 1.4
upload.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`. Where it
contradicts the code, the code wins and this document changes.

**Provenance.** Every claim about the repository was read at `feature/coaching`'s HEAD `5c2bc7f` on 2026-11-01, the
commit `feature/export` was made from. SDK claims were read from the iOS 27.0 simulator SDK's interfaces.

---

## 1. Where this sits

The roadmap's whole text for the item: *"Every serving as a CSV file, through the share sheet. The file stays on the
phone until the user sends it."* It is sold beside the sets, not in one (§5, *Sold as sets*: "and 1.4.4, export").

**The intent.** A Premium holder can take their whole history out of the app and open it in a spreadsheet. It is the
second thing that leaves on the user's own tap, after the recap's image, and it carries far more: every serving and
its minute. So the design shows what is about to leave before it leaves, and the privacy rule and policy move first.

**Done means:** a holder taps *Export your servings* in Settings, sees how many servings and which dates, taps *Share
as a CSV file*, and gets a dated file with every serving in it. A free user's tap opens the paywall. Nothing leaves
without the tap, and the app keeps no copy.

## 2. What exists today (read from the code)

- `DataManager.logs(since:)` already reads every serving for `nil`, newest first, and answers `nil` when the store
  cannot be read, never `[]`. `HealthMirror` is its one caller. `DataManager` needs no change.
- `HealthPlan` is the precedent for a pure, app-only value fed plain rows: `HealthMirror` maps each `WaterLog` to a
  `HealthPlan.Serving`, so nothing past the read holds a model object.
- `RecapSheet` is the precedent for the screen: aurora, a heading, `SheetCloseButton(label: "Done")`, sentences on
  frosted panes, one `.primarySurface(in: Capsule())` label inside a `ShareLink` with `PressStyle`.
- `CoachingRows.scheduleRow` is the precedent for the row: a chevron while open, `lock.fill` while locked, *Premium*
  in the spoken value, and a tap that opens the paywall when not open.
- `PremiumAccess.gate(status:offered:)` answers `.hidden`, `.locked` or `.open` for any extra drawn in place.
- The paywall lists features flat, `shownSets(debug:).flatMap(\.features)`, so a set has no heading of its own.
- `%1$d servings` already exists in en, ru and uz, with plural forms in the two languages that take them.
- `Transferable.suggestedFileName(_:)` taking a closure is iOS 17.0, the floor. `UTType.commaSeparatedText`,
  `ShareLink` and a title-only `SharePreview` are older. No version check is needed.

## 3. The design

### 3.1 What the user sees

**Settings.** A new card under *Apple Health*, above *Language*:

```
┌──────────────────────────────────────────────┐
│ Export your servings                       › │
│ Every serving as a CSV file, yours to keep   │
└──────────────────────────────────────────────┘
```

For a free user the chevron is a lock and a tap opens the paywall (`.settings`). Where nothing is held and the paywall
is not offered, the card is not drawn.

**The sheet**, for a holder with at least one serving. The whole of it:

```
┌──────────────────────────────┐
│ Export your servings       ✕ │
│                              │
│ ┌ frosted pane ────────────┐ │
│ │ 1,204 servings           │ │
│ │ 3 March 2026 – 1 Nov 2026│ │
│ │                          │ │
│ │ Date, time and amount in │ │
│ │ millilitres, nothing else│ │
│ │ The file leaves your     │ │
│ │ phone only when you send │ │
│ │ it.                      │ │
│ └──────────────────────────┘ │
│                              │
│ [ ↑  Share as a CSV file   ] │
└──────────────────────────────┘
```

Every serving falling on one day draws that one date, not a range. *Share as a CSV file* opens iOS's share sheet.

**The file**, `WaterBuddy-2026-11-01.csv`:

```
date,time,amount_ml
2026-03-03,09:14,250
2026-03-03,13:02,500
```

### 3.2 Decisions

| # | Decision | Whose |
|---|---|---|
| D1 | A tap reads once and opens a summary sheet; the share sheet is the sheet's one action | Owner |
| D2 | A Settings card of its own, under *Apple Health* | Owner |
| D3 | The headings are fixed English, `date,time,amount_ml`, in every language: a format, not copy. Plain ASCII, so no byte-order mark and no translation | Owner |
| D4 | Every serving, always. No date range: the roadmap asks for none | Recommended |
| D5 | Three columns and nothing else: no id, goal, streak, total, time zone or device. An id means nothing outside the app and there is no import | Recommended |
| D6 | A row's date and time are its instant's wall clock on `Calendar.waterBuddyDay`, in the zone the phone is in at export, as History reads them. `WaterLog` keeps no zone, so a serving logged while travelling reads in today's zone | Recommended |
| D7 | Oldest first. `yyyy-MM-dd`, 24-hour `HH:mm`, the amount exactly as stored, never clamped. Comma, CRLF, a final line ending, no quoting: no field can hold a comma | Recommended |
| D8 | In memory: `DataRepresentation` with `suggestedFileName`. The app writes no file, so no full history is left in a temporary folder. Plan Task 0 measures that the name survives (§3.5) | Recommended |
| D9 | `WaterBuddy-yyyy-MM-dd.csv`, today from `premium.now()`, so two exports in Files do not collide | Recommended |
| D10 | `PremiumAccess.gate`, as set B's rows: open for Premium, locked where offered, hidden elsewhere. A lapse locks it and stores nothing; a lapse while the sheet is open closes the sheet. Nothing is lost: the servings stay in the app, and Apple Health stays a free copy | Recommended |
| D11 | A third `PremiumSet` case, `.portable`, listing one `Feature.export`, on sale, as the roadmap sells it beside the sets. Its paywall row is the card's own two strings, glyph `square.and.arrow.up`, and no caption on the Settings card. The paywall gains an eighth row | Recommended |
| D12 | *Nothing to export* and a failed read are said on the card, in place of its line. The sheet opens only with at least one serving, so it has no empty state | Recommended |
| D13 | `ServingsExport`, pure and app-only, takes plain rows; `DataManager` does not change. Keeps all of this out of the widget and the watch, whose builds compile `DataManager.swift` | Recommended |
| D14 | Built on `feature/export`, made from `feature/coaching`, because export needs `logs(since:)` from Apple Health's work | Recommended |
| D15 | Excel with a `;` list separator, common on Russian-locale Windows, may open the file in one column until it is imported. No `sep=` line: it is an Excel-only hack that other readers show as data. Recorded as a known issue, unmeasured here | Recommended |

### 3.3 Approaches considered

- **A. Read on tap, then a sheet (chosen, D1).** Shows what will leave, and can say why nothing can. Two taps and a
  new view of about 100 lines.
- **B. A `ShareLink` in the row, read when iOS asks for the data.** One tap and no new view. A failed read could only
  surface as a blank share sheet, against *fail soft, loudly*, and an empty history would send headings alone.
- **C. `UIActivityViewController` from the row.** One tap, read first. It needs a UIKit bridge of its own and a file
  URL for the name, so a temporary file holding the whole history. Set aside.

### 3.4 The pieces

**`WaterBuddy/ServingsExport.swift`, new, app-only, `Foundation` alone, `nonisolated`.**

```swift
nonisolated struct ServingsExport: Identifiable, Sendable, Equatable {
    nonisolated struct Serving: Sendable, Equatable { let amount: Int; let timestamp: Date }
    nonisolated enum Outcome: Sendable, Equatable { case file(ServingsExport), nothing, unreadable }

    let name: String      // WaterBuddy-2026-11-01.csv
    let data: Data        // UTF-8, ASCII in practice
    let count: Int
    let first: Date       // the oldest serving
    let last: Date        // the newest serving
    var id: String { name + String(count) }

    /// `nil` rows is a failed read, and stays distinct from none.
    static func outcome(of rows: [Serving]?, today: Date, calendar: Calendar) -> Outcome
}
```

It takes no locale and no bundle, so the file cannot vary with the app's language. Digits come from calendar
components through `String(format:)`, the idiom `ReminderPlan.Slot.identifier` uses, never a date style.

**`WaterBuddy/ExportSheet.swift`, new, app-only.** `ExportSheet(export:)`, `RecapSheet`'s shape:
`AuroraBackground`, the `GeometryReader`-and-`ScrollView` form, `.presentationDetents([.medium, .large])`. A
`nonisolated` `ServingsFile: Transferable, Sendable` wraps the export:

```swift
DataRepresentation(exportedContentType: .commaSeparatedText) { $0.export.data }
    .suggestedFileName { $0.export.name }
```

`ShareLink(item:preview:)` uses `SharePreview(export.name)` and `PressStyle`. One `nonisolated static` builds the
dates' line from `first`, `last`, `locale` and the calendar, through Foundation's `Date.IntervalFormatStyle` (§6), one
date when they share a day, so it is testable.

**`WaterBuddy/SettingsView.swift`.** A `private struct ExportCard`, beside `CoachingRows`, taking the gate, the line
to draw and two closures. `SettingsView` holds `exporting: ServingsExport?`, the `.sheet(item:)` selection, and
`exportProblem`. The problem lives on `SettingsView`, not the card, and takes the stack's
`.animation(Motion.settle, value:)`: a card that changes height on its own grew while its neighbour jumped, the
comment on that stack says. The tap, in full:

```swift
exportProblem = nil
let rows = manager.logs(since: nil)?.map { ServingsExport.Serving(amount: $0.amount, timestamp: $0.timestamp) }
switch ServingsExport.outcome(of: rows, today: premium.now(), calendar: .waterBuddyDay) {
case .file(let export): exporting = export
case .nothing: exportProblem = .nothing
case .unreadable: exportProblem = .unreadable
}
```

`exportProblem` clears when Settings leaves the screen, so a pour elsewhere cannot leave *Nothing to export yet.*
standing. `LanguageCard` and the policy link each move down one `arrives` order.

**`WaterBuddy/PremiumSet.swift`.** D11's case, feature, keys and glyph. `isOnSale` is `true`.

### 3.5 Measured before the code (plan Task 0)

Run on a scratch copy, one throwaway sheet, on the iOS 27.0, 26.5 and 18.6 runtimes:

1. *Save to Files* is offered with no usage key, and what lands is named `WaterBuddy-yyyy-MM-dd.csv`, not a generic
   name, with the file's exact bytes.
2. What Mail or another destination offered on the simulator receives as an attachment carries the same name.

**If the name does not survive,** the fallback is `FileRepresentation`: a file of that name in
`FileManager.default.temporaryDirectory`, written when iOS asks for it and removed when the sheet closes, with the
third limit in §3.12 reworded to say so and the change reported to the owner.

### 3.6 Failures

| Case | What happens |
|---|---|
| The store cannot be read | No sheet. The card reads *Your servings could not be read. Try again.* Never an empty file (rule `20-state`) |
| No servings yet | No sheet. The card reads *Nothing to export yet.* |
| The user cancels the share sheet | Back on the export sheet. Nothing is recorded |
| A lapse with the sheet open | `exporting` clears on the gate's change and the sheet closes, as the recap's does |
| A corrupt amount | Written as stored. Nothing sums, so nothing can overflow |

### 3.7 Concurrency

The tap runs on the main actor, where `logs(since:)` and the map both belong. Nothing past the map holds a
`WaterLog`. `ServingsExport` and `ServingsFile` are `Sendable` and `nonisolated`, stated outright because the
target's default isolation is the main actor, and `suggestedFileName`'s closure is `@Sendable`.

### 3.8 Accessibility

- The card is one button: label *Export your servings*, its line the hint, value *Premium* while locked, or the line
  saying why nothing opened (§6). The glyph is hidden.
- The sheet's heading carries the header trait, and the close button is *Done*.
- The pane is one element, count, dates and sentences read in order, with the count grouped by the app's locale.
- *Share as a CSV file* is one button whose label is the words it draws.
- At the accessibility sizes the sheet scrolls and the primary button stays whole.

### 3.9 The words

Six new keys, app catalogue only, not in `sharedKeys`. Russian and Uzbek are drafts for the owner's sweep.

| Key | Where |
|---|---|
| *Export your servings* | The card, the sheet's heading, the paywall's row |
| *Every serving as a CSV file, yours to keep* | The card's line, the paywall's row |
| *Date, time and amount in millilitres, nothing else. The file leaves your phone only when you send it.* | The pane |
| *Share as a CSV file* | The primary surface |
| *Nothing to export yet.* | The card |
| *Your servings could not be read. Try again.* | The card |

`%1$d servings`, *Done* and *Premium* are reused. No copy names a figure beyond the count the user is looking at, and
none of it appears outside the app's screens.

### 3.10 Privacy and the policy

Rule `70-privacy` gains a section, §3.12, five limits on the recap's pattern. The App Store label stays *Data Not
Collected*: the developer receives nothing, and the user sends the file where they choose.

`PRIVACY.md` and `Tools/PrivacyPolicy.html` change together, on this branch, and publish only with the release that
carries export, as Health's copy does (#193):

- **What leaves your device** gains *8. A file of your servings you choose to share*, at the end so no section is
  renumbered: Premium, only on the user's tap, the date, time and amount of every serving and nothing else, made in
  memory, and once sent it is governed by wherever it went.
- **Your rights**, *Access and portability*, gains one sentence: Premium can export every serving as a file.

### 3.11 What does not change

No key in either store. No change to `DataManager`, the widgets, the watch, `WristMirror`, Siri, the control, the
reminders or Apple Health. No exception set, entitlement, usage key or `PrivacyInfo.xcprivacy` (no required-reason
API is added). `README.md` and `AppStore/1.4/` stay the 1.4 upload's. The next release's listing has to name export,
and a known issue will say so.

### 3.12 What it amends in the rules (approved with this spec, then typed unstaged)

**`70-privacy`, *Nothing leaves the device*.** Replace the line beginning *The one thing that leaves on the user's
own tap* with: "Two things leave on the user's own tap, each on the conditions below: the recap's image and the
export file." Then add, after *The recap's image, on the user's own tap*:

> ## The export file, on the user's own tap
>
> Premium may export every serving as a CSV file (roadmap 1.4.4,
> `docs/superpowers/specs/2026-11-01-export-design.md`). It leaves the phone the way a document the user sends does:
> the system's share sheet, on their tap, to a destination they choose. The app sends nothing on its own and learns
> nothing of where it went.
>
> Five limits are conditions of the permission:
> - **One way out.** Only through the system share sheet, from *Share as a CSV file* in the export sheet — `ShareLink`
>   in `ExportSheet.swift`. Never from the widget, the watch, Siri, the control, a notification or a reminder's button,
>   and never without the tap
> - **Three columns, and nothing else.** `date`, `time`, `amount_ml`, the headings fixed and in English in every
>   language: a format, not copy. Never a serving's id, the goal, the streak, a total, a time zone, the language or
>   the device's name
> - **In memory only.** Built when the row is tapped, held in the sheet's state, written to no file and to neither
>   store. iOS may write the copy a destination asks for; the app does not
> - **No usage key.** *Add no `NS*UsageDescription` key* stands. *Save to Files* needs none
> - **Nothing recorded.** No completion handler, no count of exports, no diagnostic of the destination

**`20-state`.** The `logs(since:)` bullet gains: "Export's card reads it too, and says so on a failed read rather than
sending an empty file."

**`50-views`, *Navigation*.** Add: "The export sheet is presented with `.sheet(item:)` bound to an optional
`ServingsExport`, read once by the card's tap and handed to `ExportSheet` through `init`, for Premium alone — the card
opens the paywall for anyone else. With no servings, or a failed read, the sheet does not open and the card says so. A
lapse clears the selection, so the sheet closes."

**`60-design-system`, *The primary surface*.** "The recap sheet's is *Share as an image*" becomes "The recap sheet's is
*Share as an image*, the export sheet's *Share as a CSV file*".

**`65-accessibility`, *VoiceOver*.** Add: "Settings' *Export your servings* is one button — label the title it draws,
its line the hint, value *Premium* while locked, or the line saying why nothing opened. The export sheet's heading carries the header trait and its close
button is *Done*. Its pane is one element, and *Share as a CSV file* is one button whose label is the words it draws."

**`15-project`, *Membership*.** Add: "`ServingsExport` and `ExportSheet` are app-only and stay out of every exception
set; the read they need, `logs(since:)`, is already in `DataManager.swift`. The closure form of `suggestedFileName` is
iOS 17.0, the floor, so export adds no version check."

**`43-concurrency`, *The model is main-actor*.** Add: "`ServingsExport` is `nonisolated` and imports `Foundation`
alone." Add `ServingsExportTests` to the list of suites never given `@MainActor`, and to the same list in `85-testing`.

**`85-testing`.** The `-WaterBuddyFreshStart` and `-WaterBuddyPremiumHeld` paragraphs name `ExportUITests` among those
that pass them. *A green suite is not proof the product works* gains: "After a change to export, share to *Save to
Files* and open the file."

### 3.13 Testing, first

Every test is written and seen RED before its code.

**`ServingsExportTests`, new, not `@MainActor`, `Foundation` alone:** the exact bytes of a two-row file, headings and
CRLF included; newest-first input written oldest first; the same instant in Paris and in Los Angeles; both rows of a
fall-back night's repeated hour; two servings in one minute stay two rows; an amount written as stored; the name's day
taken from `today` on the injected calendar; `count`, `first` and `last`; no rows is `.nothing`; `nil` is
`.unreadable`, never `.nothing`; the same bytes when the calendar's locale is Arabic.

**`ExportSheetTests`, new:** the dates' line for a range and for one day; on iOS 18.2 and later `ServingsFile` exports
as `.commaSeparatedText` to the exact bytes, as `RecapImageTests.theSharedPictureKeepsItsPixels` does.

**`PremiumSetTests`:** `allCases` gains `.portable`, its one feature, on sale, no caption, worded in every language.
The glyph is covered by `everyFeatureGlyphResolves`.

**`ExportUITests`, new, fresh start with `-WaterBuddyPremiumHeld`, each label asserted to one element:** with no
servings the card says so and no sheet opens; after a pour the line goes, the sheet opens on *1 serving*, and *Share
as a CSV file* brings up iOS's share sheet. **`PremiumUITests`:** a free user's card opens the paywall, and the paywall
carries the eighth row. The failed read has no route from the UI, so it is held by the outcome's unit test.

## 4. Verification

- **The gate**, five invocations (rule `85-testing`), and the UI suite again on `OS=26.5`.
- **Warnings** by clean builds into empty DerivedData against a `HEAD` export, by file and message and by site, on all
  four schemes. The baseline is 20/36, 17/29, 2/2, 17/29.
- **The walk**, on *iPhone 17* (27.0): the card free, locked and open; the sheet at the default and the largest text
  sizes and at 320 pt; *Save to Files*, then the file read back byte for byte; a Premium paywall's eight rows. The pane
  reuses the recap's pair, and the card's line its siblings', so no new colour pair is drawn; if the walk draws one, it
  is measured off a render.
- **Device-only, to 1.2.7's sweep:** a real export into Files, Mail and Numbers; VoiceOver by ear; the file opened in
  Excel (D15).

## 5. Open, for the owner

The Russian and Uzbek of the six keys. D4–D15 stand as approved.

## 6. Refinements made while planning (2026-11-01)

- **The problem line is the card's value, not its hint** (§3.8, and the wording in §3.12). VoiceOver may not reach a
  hint, and this line is the answer to the tap. XCUITest cannot read a hint either, so as a hint it could not be
  tested.
- **The dates' line is Foundation's interval** (§3.4), not two dates joined by hand: it follows each language's own
  punctuation and trims what the two ends share, so the same year reads *3 March – 1 November 2026*. It needs no
  string of its own.
- **`coachingGate` is renamed `premiumGate`** in `SettingsView`, since the export card reads it too.
- **`settingsCard(interactive:)`**, default `false`: this card's pane is the control, so `interactive` is passed for it
  alone (rule `60-design-system`).

## 7. Refinements from the final review (2026-11-01)

- **The policy changed in more places than §3.10 named.** With a file in the user's hands, *deleting the app is the end
  of it* and *There is no other copy to erase* were false, and the one-sentence summary, Premium's list and *Never
  stored* left export out. All six are changed, in both files, with a retention bullet of its own.
- **`.onDisappear` is removed** from §3.4's design. `RootTabView` builds a page again each time it is shown, so
  `exportProblem` already goes with the page. A pour made while Settings stays on screen — a widget tap from the Home
  Screen, a watch pour — still leaves the line until the next tap, which reads again and opens the sheet.
