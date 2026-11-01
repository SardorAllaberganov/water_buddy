# Finishing export — design

**Status:** the owner's "ok", 2026-11-01, with the scope then widened: this is **stage 1 of
`2026-11-01-premium-look-design.md`**, and that spec's `Landing` replaces §3.2's `Arrival` rise (D4 there): 14 pt reads as
nothing (`tasks/lessons.md`, 2026-10-12). No code of it exists yet. Taken by
`/start_task` with no task named, on the owner's choice "Finish export". The owner then tried the build on their
iPhone: *"it looks like not premium and there is not animations, and there is no micro-interactions. how can we
improve them"*. Direction 2 on the board, *The file, shown*, is the owner's choice. Every other decision below is a
recommendation for the owner to change at review. As for finishing sets A and B, there is no plan document. The rule
wording in §5 is typed, then left unstaged for the owner (rule `99-docs-cascade`).

**The board:** https://claude.ai/artifact/MxsvntEKbdMGXbK1PJJqge, private to the owner. Frame 2 was changed after the
owner chose it, to fit the rules (§3.1); it is the frame this spec describes. The motion on it is CSS, so its feel is an
approximation: the owner's iPhone has the last word (§6).

**Also closed here:** known issues **#212**, **#213** and **#214** (`docs/AI_CONTEXT.md`).

**Out of scope:** #210 (Russian and Uzbek, the owner's sweep), #215 (its own change), #216 (the store copy, with the
release), and a real export into Mail, Numbers or Excel (#211, device-only).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`. Where it
contradicts the code, the code wins and this document changes.

**Provenance.** Every claim about the repository was read at `feature/export`'s HEAD `9086f06` on 2026-11-01.

---

## 1. What is being built

| # | Subject | Decision | Status |
|---|---|---|---|
| D1 | Direction | *The file, shown*: the sheet shows the file that will leave, not a sentence about it | Owner |
| D2 | Detent | `.presentationDetents([.large])`, as the recap. The card does not fit a medium sheet, and the app's only medium ground, which #213 was opened for, goes with it | Recommended |
| D3 | One card | The figure, the file and the note stand in one rimmed `.frosted` + `.raised` card. On the bare aurora, a line under a figure would have to hold 4.5:1 through the drift (rule `65-accessibility`, #171) | Recommended |
| D4 | The rows | The file's own first lines, literally, commas in, in monospace: the headings and up to five servings, with *and 1,199 more* beneath. Fixed English in every language, because that is what the file holds (the export spec's D3) | Recommended |
| D5 | The figure | Drawn large as a number over one plain label, *Servings in this file*: a stat's label, as *Days on goal* is, so it takes no plural forms. VoiceOver keeps the existing sentence, *1,204 servings* | Recommended |
| D6 | Arrival | **The sheet arrives whole; only the rows and the digits move once it has landed.** Rows rise through `arrives(_:order:)`, the digits roll once, then the share glyph bounces once. A sheet is a page that slides in (`Arrival`'s DocC, the owner's own ruling from holding that build) | Recommended |
| D7 | The Settings card | A bare `doc.text` glyph, as Premium's card carries `sparkles`. When the sheet opens, the glyph bounces and `Haptics.select` plays. No haptic on a refusal: the vocabulary has no refusal (finishing set B's D6). The problem line cross-fades in | Recommended |
| D8 | The share press | `Haptics.confirm` on the press, if it can be had without touching the share (§3.5). If it costs the tap or the scroll on any runtime, it is dropped, and the sheet ships without it | Recommended |
| D9 | The rim | `.premiumRim()` gains a fourth surface, the export sheet's card: only a holder ever reaches it, as with the recap's. Settings' card stays unrimmed, because a screen of rims marks nothing | Recommended |
| D10 | After the share | **No success moment.** `ShareLink` reports nothing, and rule `70-privacy` forbids a completion handler. Unchanged, and stated so nobody adds one | Recommended |
| D11 | #214, the stale line | `.onChange(of: manager.currentWater)` clears `exportProblem`, so a watch pour, or a widget tap read on coming forward, takes the line away. Nothing in the suite can drive either: stated, not tested, as finishing set B's D4 | Recommended |
| D12 | #214, a lapse | The card draws a problem only while it is open: `SettingsView.exportLine(_:gate:)`, pure and tested. A lock never stands over the line, and VoiceOver says *Premium* | Recommended |
| D13 | #214, the tap's cost | **No code.** About 60 ms at 3,000 rows, the fetch dominating, and moving it off the main actor needs a second `ModelContext`, which is new architecture for a rare, lossless cost. Recorded as accepted | Recommended |
| D14 | #214, the first read | `PremiumAccess.gate` answers `.hidden` while `status` is `nil`. `HistoryView.offersMonth` and Premium's card already wait for the first read, so the gate is the odd one out, and a holder's tap in that window opens the paywall. Set B's rows change too. The cost: they appear a moment late, beside Premium's card, which does too | Recommended |
| D15 | #214, wording | Rule `70-privacy`'s third limit names the card and `SettingsView.exporting`, and `ExportSheetTests` joins both canary lists | Recommended |
| D16 | #212 and the gate | After the code, the whole UI suite on iOS 26.5 and 27.0, one class per plain foreground `xcodebuild`, with no script and no hold on other sessions. A test failing under load is run alone once, and reported either way | Recommended |
| D17 | A lapse with the sheet open | Moved to #211's list. No automated route reaches it: `-WaterBuddyPremiumHeld` cannot lapse. The `.onChange` that closes the sheet stands as written | Recommended |

## 2. Where it lands

- **`WaterBuddy/ExportSheet.swift`**: the card, the arrival, the share press (D1–D6, D8).
- **`WaterBuddy/ServingsExport.swift`**: `preview`, `moreServings` (D4). Still Foundation alone, and the file's bytes do
  not change.
- **`WaterBuddy/SettingsView.swift`**: the card's glyph and its feedback, `exportLine(_:gate:)`, the clearing (D7, D11,
  D12). `Hairline` leaves for its own file.
- **`WaterBuddy/Hairline.swift`** (new, app-only): a second screen wants it (rule `50-views`), and `hairlineOpacity`
  moves with it.
- **`WaterBuddy/PremiumAccess.swift`**, **`WaterBuddy/PremiumRim.swift`**: D14; the rim's DocC, which still says only
  the Settings card carries it.
- **`WaterBuddy/Localizable.xcstrings`**: two keys, *Servings in this file* and *and %1$d more*, en with ru and uz
  drafts, added to #210. App-only, so neither joins `sharedKeys`. Both join `premiumKeys`.
- Tests: `ServingsExportTests`, `ExportSheetTests`, `PremiumAccessTests`, `LocalizationTests`, `ExportUITests`.
- `docs/superpowers/specs/2026-10-30-coaching-design.md` line 206 is marked amended by D14.

No key in either store, no exception-set or entitlement change, nothing the widget or the watch draws. Every file
changed is app-only, so neither widget's scheme compiles a line of it.

## 3. How it works

### 3.1 The sheet

From the top: the heading and *Done*, as today. Then one card, `.liquidGlass(density: .frosted, elevation: .raised)`
then `.premiumRim()`, holding:

1. The figure: `export.count.formatted(.number.locale(locale))`, `@ScaledMetric(relativeTo: .largeTitle)` 52 pt, heavy
   and rounded, capped at 76 pt, `.monospacedDigit()`, `.lineLimit(1)`, `.minimumScaleFactor(0.5)`.
2. *Servings in this file*, `.headline`, and the dates, `.subheadline`.
3. A `Hairline`.
4. The file's name in `.subheadline.weight(.semibold)`, beside a small `doc.text`, one line, `.truncationMode(.middle)`.
5. The rows, `.system(.footnote, design: .monospaced)`, each one line, and *and 1,199 more* in `.footnote.weight(.semibold)`.
   Rows and name are capped at `.dynamicTypeSize(...DynamicTypeSize.accessibility1)`, with `.minimumScaleFactor(0.6)`: a
   line of a file cannot wrap and stay a line of a file, and everything they say is spoken elsewhere.
6. A `Hairline`, and today's note.

Then a `Spacer(minLength:)` and the primary surface, at the foot of the sheet where the screen allows, and scrolled to at
the accessibility sizes through today's `GeometryReader`/`ScrollView`.

**What changed on the board after the owner chose it:** the figure moved off the aurora and into the card (D3); the card and
the button no longer rise (D6); the rows show the file's commas and all stay at full white, since a fade would put small
text under 4.5:1 (D4); the card's glyph lost its filled square, a hand-rolled pane (rule `60-design-system`).

### 3.2 The arrival

```swift
@State private var arrived = false   // the rows and the digits
@State private var settled = false   // the share glyph
```

A `.task` waits `landing` (350 ms, tuned on the iPhone), sets `arrived`, waits `Arrival.longestDelay + Arrival.duration`, sets
`settled`, and returns if cancelled at either wait (rule `43-concurrency`).

- Each row and *and 1,199 more* take `.arrives(arrived, order: index)`, so its rise, stagger, floor and Reduce Motion fade
  are `Arrival`'s. **The sheet sets `.environment(\.pageSettlesIn, true)`:** `RootTabView` sets it `false` for a turned page, and
  a sheet presented from one inherits that, so without this line the rows would never move.
- The digits: `.contentTransition(.numericText(value: Double(shown)))`, `.animation(Motion.land, value: arrived)`, where
  `shown` is `0` until `arrived`, or `count` throughout under Reduce Motion. They roll once, in the app's own vocabulary; it is
  not a ticking counter.
- The glyph: `.symbolEffect(.bounce, value: settled)`, the value held `false` under Reduce Motion.

Nothing repeats, so nothing here is a perpetual animation.

### 3.3 The preview

```swift
/// The file's first lines, headings first, as they are in the file.
let preview: [String]
/// How many servings the preview leaves out.
var moreServings: Int { count - (preview.count - 1) }
private static let previewServings = 5
```

`outcome(of:today:calendar:)` already builds `lines`; `preview` is `Array(lines.prefix(previewServings + 1))`, so it cannot
drift from the bytes. It holds what `data` holds, in memory, and goes with the sheet. *and N more* is drawn only while
`moreServings > 0`, through `strings.localized("and %1$d more", n, locale:)`, which groups the figure.

### 3.4 The card

`ExportCard` gains `opens: Int` and draws `doc.text` before the title, `.title2.weight(.semibold)`, white, hidden from
VoiceOver, `.symbolEffect(.bounce, value: opens)`. `SettingsView` bumps `exportOpens` in `startExport()`'s `.file` case
alone and declares `.sensoryFeedback(Haptics.select, trigger: exportOpens)`. The note's `Text` takes
`.contentTransition(.opacity)`; the stack's `Motion.settle` already animates it.

### 3.5 The share press

```swift
ShareLink(...) { ... }
    .buttonStyle(PressStyle())
    .simultaneousGesture(TapGesture().onEnded { shares += 1 })
    .sensoryFeedback(Haptics.confirm, trigger: shares)
```

**Measured first:** a gesture on a button in a scroll view can steal the tap or the drag, and that has moved between iOS
versions. Before anything else is built, run this alone on iOS 27.0, 26.5 and 18.6: the share sheet still opens, and the
sheet still scrolls at the largest text size. If either fails, D8 falls and the sheet ships without the haptic. `shares` is
presentation state, gone with the sheet and read by nothing else, so it is not a count of exports (rule `70-privacy`).

### 3.6 The gate

```swift
static func gate(status: Status?, offered: Bool) -> Gate {
    guard let status else { return .hidden }
    if status.isPremium { return .open }
    return offered ? .locked : .hidden
}
```

`.locked`'s DocC loses *"Also while the first read is still out."*, and `gate(status: nil, offered: true)`'s expectation in
`PremiumAccessTests` moves from `.locked` to `.hidden`. **That is a changed ruling, not a weakened test**: this section is the
ruling. `.onChange(of: premiumGate)` sees `.hidden` to `.open` at launch and closes nothing, since nothing is open.

### 3.7 VoiceOver

The card is one element, `.accessibilityElement(children: .ignore)`, its label the existing sentence, then the dates, the file's
name and the note, joined with commas. `testAHoldersExportShowsItsSummaryAndOffersTheShareSheet` already expects that one label.
The drawn figure, the rows and *and N more* are not spoken: what they say is in the label, and a row of commas read aloud is
noise. The Settings card's glyph is hidden; its label, hint and value do not change, but for D12.

### 3.8 The words

| Key | en | ru draft | uz draft |
|---|---|---|---|
| Servings in this file | Servings in this file | Порций в файле | Fayldagi porsiyalar |
| and %1$d more | and %1$d more | и ещё %1$d | yana %1$d ta |

*and %1$d more* carries no noun, so it takes no plural forms (rule `70-privacy`).

## 4. Tests first

Each seen RED, then GREEN (rule `85-testing`):

- `ServingsExportTests`: `thePreviewIsTheFilesOwnFirstLines`, split from `data` and compared; `aShortFileIsPreviewedWhole`,
  with `moreServings == 0`; `theMoreCountIsWhatThePreviewLeavesOut`, on six servings and on 1,204.
- `ExportSheetTests`: `theMoreLineGroupsItsFigureInEveryLanguage`; `aLapsedCardDrawsNoProblem`, over `exportLine` for
  `.open`, `.locked` and `.hidden`.
- `PremiumAccessTests`: the `nil` line above, and `theGateAgreesWithTheMonthWhileTheFirstReadIsOut`, pinning `gate` and
  `offersMonth` together, so they cannot part again.
- `LocalizationTests`: both keys in `premiumKeys`, proved by removing one and seeing it fail, not by a green run
  (`tasks/lessons.md`, 2026-11-01).
- `ExportUITests`: `testAHoldersExportShows…` also finds the file's name in the one label.

Motion, haptics and layout have no automated coverage: §6.

## 5. Rule wording (approved with this spec, then typed unstaged)

- **`60-design-system`, *Glass*:** "Premium's Settings card, History's locked month, the recap's card **and the export sheet's
  card** are marked with `.premiumRim()`".
- **`65-accessibility`, *VoiceOver*:** "Its **card** is one element, **its label the count, the dates, the file's name and the
  note; the drawn figure, the rows and the line under them are hidden**, and *Share as a CSV file* is one button".
- **`70-privacy`, *The export file*:** third limit, "Built when the **card** is tapped, held in **Settings'** state". Fifth limit,
  added: "The press's haptic is presentation state, gone with the sheet", if D8 stands.
- **`43-concurrency`, `85-testing`:** `ExportSheetTests` joins both lists of suites that are not `@MainActor`.

## 6. Verification

1. **The render, read at last.** A throwaway UI test attaches the card and the sheet, on iOS 27.0, at the default and the largest
   text size, in English and Russian, and with Reduce Motion on. Removed afterwards.
2. **Measured, #213.** On the `.large` sheet, through one full drift period, by `docs/DESIGN.md`'s method: white on the card at
   the figure, the rows, *and N more* and the note, and the rim beside it; the heading on the aurora; the glyph on Settings' card.
   Figures go into `docs/DESIGN.md`. Anything under its floor stops the work and is reported.
3. **The gate.** All five invocations on 27.0, then D16's UI run on 26.5. `tasks/lessons.md`'s count: passed plus failed
   against what the filter chose, and a grep for *Restarting after unexpected exit*.
4. **Warnings.** A clean build of `-scheme WaterBuddy` against an export of `9086f06`, by file and message.
5. **The owner's iPhone, last.** Installed as on 2026-11-01, on the fresh start with `-WaterBuddyStoreSample`, so the real log is
   not touched. Motion and haptics are judged there; a simulator has no haptics, and `landing` is tuned there. **The work is not
   finished until the owner has held it.**
6. **The records.** `/doc_sync` writes #212, #213 and #214 closed, with D13 as accepted, adds the lapse to #211 and the two
   strings to #210, and corrects `docs/ROADMAP.md` and `docs/AI_CONTEXT.md`, which still say export is not committed: it is,
   `3ec547b` to `9086f06`, and pushed.

Stage and stop; the owner runs `/commit`.
