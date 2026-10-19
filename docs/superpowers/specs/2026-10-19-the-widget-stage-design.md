# The widget's stage — the white button, StandBy and the week — design

**Status:** approved by the owner in conversation on 2026-10-18, in three sections — the pour button
and StandBy, the week's stored shape, and the week widget with its link to History — after four
rulings: one spec in three stages, the week alone in a medium widget, the vessel and the button on
black in StandBy, and the week cached beside today's total (approach A, §3.1). Written on 2026-10-19
for the owner's review; **no plan, no rule text and no code yet.** Roadmap item **1.3.1**
(`docs/ROADMAP.md` §4), which is the premium redesign's stage 6
(`docs/superpowers/specs/2026-10-09-premium-redesign-design.md` §8) plus a StandBy layout and a week
widget. Section 4 of the conversation — the rules, the tests, the delivery — was not presented
in chat; it is §5 to §11 here, for review with the rest. The rule wording in §5 is a proposal —
rules change only when the owner decides (rule `99-docs-cascade`) — typed for approval **before**
the code, as for 1.2.5 and 1.3.4.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `41309e3` on 2026-10-18 and
2026-10-19. Claims about Apple's platform carry their source: **SDK** is
`iPhoneOS27.0.sdk/…/WidgetKit.swiftmodule/arm64e-apple-ios.swiftinterface` in Xcode 27.0 on this
machine; anything else is marked **inferred**, and the plan proves it before building on it.

---

## 1. What is being built

Three changes to the phone's widget extension, built and gated in this order:

- **6a — the white pour button.** The Home Screen widget's one action becomes the redesign's primary
  surface: a white disc in the small family, a white capsule in the medium one, `Aurora.top` content.
- **6b — StandBy.** When iOS takes the small widget into StandBy and removes its background, the
  widget stops drawing a card floating on black and draws its vessel and button on the black itself.
- **6c — the week.** A new medium widget, *Week*: the last seven days as bars against the goal, the
  way History's week card draws them, and a tap that opens History. It needs the week in the App
  Group cache — a new key, the first change to the stored shape since 1.2.5.

The owner's rulings, in the order they were asked:

- **Delivery:** one spec, three stages, each gated on its own (6a, 6b, 6c). They share the widget's
  file and the device check; only 6c changes stored state.
- **What the week widget shows:** the week alone, in `.systemMedium` — History's card at widget size,
  no pour button. It sits beside the Hydration widget in a stack rather than repeating it.
- **StandBy:** the vessel and the button on black, so a tap from the nightstand still logs; night
  mode is iOS's own red tint.
- **How the week reaches the widget:** approach A (§3.1) — cached beside today's total, by every
  phone process that recomputes it.
- **The week's tap:** straight to History.

## 2. What happens today

- **The pour button is glass.** `PourButton` draws a `+` (small) or *+250 ml* (medium) in white on a
  `.frosted` pane (`WaterBuddyWidget.swift:441-463`). The redesign's stage 1 made the primary surface
  and gave it a `ring: false` mode for exactly this button
  (`LiquidGlassModifier.swift:681-683`); nothing passes it yet.
- **StandBy draws a card on black.** iOS removes a removable container background in StandBy, so the
  `WidgetAurora` behind the card goes. `WidgetCardBackdrop` is drawn inside the card and is opaque,
  "so in StandBy the card brings its own light rather than floating on bare black"
  (`WaterBuddyWidget.swift:521-522`). Nothing reads `showsWidgetContainerBackground`. *(Not observed
  on a device for this spec: the DocC's account.)*
- **No widget draws a past day.** `republishHistory()`'s DocC says a per-day series "is derivable
  from none of the cache keys", and it returns early outside the app (`role.drawsHistory`,
  `DataManager.swift:1003-1004`), "cost rather than correctness".
- **A widget tap the morning after rolls the day over in the extension.** `AddWaterIntent` reaches
  `DataManager.shared`, whose `init` runs `resetIfNeeded()` (`DataManager.swift:583`), which runs
  `applyDailyReset(on:)` (`:1544`) — zero written to `Key.currentWater`, the day stamped — before the
  tap's own row is logged. Yesterday's total leaves the cache. Harmless today, because nothing reads
  it; fatal to a week drawn from the cache alone (§3.1).
- **A tap on a widget opens the app wherever it was.** There is no `onOpenURL` and no `widgetURL`
  anywhere in the tree (`git grep`, 0 hits). `RootTabView`'s page is `@State`, so a cold launch opens
  Home and a warm one the last tab.

## 3. The design

### 3.1 Approaches — how the week reaches the widget

The widget may not open SwiftData (rule `40-widget`), so the week has to be in the cache. Two writers
make that hard: the app, and the widget extension, which logs a serving on every tap and — the
morning after — rolls the day over first (§2).

- **A — cache the week where today's total is cached. Chosen.** A new key, rewritten from the rows by
  exactly the paths that recompute today's total, in both phone processes. A failed read writes
  nothing; `refresh()` never writes it. Cost: a seven-day fetch on every widget tap, in the process
  `republishHistory()`'s guard was keeping it out of. The rollover is not touched.
- **B — fold the outgoing day in at the rollover.** Only the app computes the week;
  `applyDailyReset` writes the outgoing day's cached total into the key before zeroing it. No fetch
  in the extension, but it amends the most delicate function in the codebase (rule `30-rollover`
  names its two writes), builds history from a cache rather than from rows, and still misses the
  day's widget taps until the next rollover — so the reader needs a second overlay, at
  `lastActiveDay` as well as today.
- **Rejected: an app-only key, no fold.** The morning-after tap empties yesterday's bar.

### 3.2 Stage 6a — the pour button

As the redesign spec §8 decided, unchanged:

- **In `.fullColor`** the label sits on `.primarySurface(in: Circle(), ring: false)` (small) or
  `.primarySurface(in: Capsule(), ring: false)` (medium). The surface sets its content's colour, so
  the label's own `.foregroundStyle(.white)` goes (rule `60-design-system`). The button stays exactly
  `PourButton.minimumTarget` — 44 pt, no ring — so `MiniVessel.radius(fitting:besides:gap:)`, the
  diagonal and the 4-pt gap do not move.
- **Outside `.fullColor`** — a tinted Home Screen, StandBy at night — it keeps today's white content
  inside the lit rim: on a template only alpha survives, and white with dark content would come back
  as one blank disc.
- **One small modifier** beside `WidgetPane`, branching on `widgetRenderingMode` as `WidgetPane`
  does: the primary surface in full colour, the rim and white content otherwise.
- **Contrast** is already derived for the pair: `thePrimaryLabelClearsSevenToOneEvenAtTheFootOfTheShade`.
- Unchanged: the vessel, the card, the aurora, the frozen phase, the scrim ramp, both timeline
  entries, the `.archived` glass, the Lock Screen widget and the control. `LockScreenWidget.swift`'s
  comment on `PourButton`'s tinted fallback (`:274`) stays true, because the fallback stays.

### 3.3 Stage 6b — StandBy

- **The signal is Apple's own.** `@Environment(\.showsWidgetContainerBackground)` is `false` when the
  system removed the container background — on iPhone, StandBy. **SDK:** iOS 17.0 and later, inside
  the floor; **get-only**, so no preview can set it.
- **Read once, handed down.** `HydrationView` reads it and passes the small family a flag, so a
  `#Preview` can build the bare layout directly — the environment cannot be set to it.
- **The bare layout** draws no card, no card pane and no `WidgetCardBackdrop`. The vessel and the pour
  button stand on the system's black, on the same diagonal, the vessel sized by the same
  `MiniVessel.radius(fitting:besides:gap:)` over the larger square: on a 158-pt widget about 105 pt
  across instead of 84 (by the formula; to be rendered), the button still clear by the 4-pt gap.
- **The vessel draws its lit rim and its water, not its glass** — rule `60-design-system`: glass
  never goes over a flat background, and an empty sheer pane on black reads as a grey disc. *(A
  refinement found while writing, not in the section the owner approved: §10 D4.)*
- **At night** StandBy renders the widget in a non-full-colour mode — **inferred** to be `.vibrant`
  (the **SDK** declares `.fullColor`, `.accented` and `.vibrant` and says nothing of StandBy). Every
  layer already has its non-full-colour form — the wave silhouette, the rim, the rimmed button — and
  iOS tints them red. Night needs no code of its own.
- **The percentage** keeps its rule, `min(readoutSize, diameter × 0.33)`. StandBy already draws the
  whole widget at about twice its size.
- **A locked phone may hide the figure** (§10 D3, ruled yes). The small family's figures — the
  vessel's percentage and its water — carry `.privacySensitive()`, and when `redactionReasons`
  contains `.privacy` the vessel draws the Lock Screen widget's quiet form: the rim of an empty vessel,
  no water, no figure, and for VoiceOver its label alone. Whether iOS redacts a Home Screen widget in
  StandBy, and under which setting, is **inferred** — the device check settles it. On an unlocked
  Home Screen nothing is redacted, so nothing there changes.
- **Medium is unchanged.** iPhone's StandBy shows small widgets only — **inferred** from Apple's
  documentation, not the SDK — and the DocC says so.
- **The simulator has no StandBy.** The bare layout is drawn on the simulator through its `#Preview`
  and a throwaway render; real StandBy, by day and at night, is the owner's device check (§8.3).

### 3.4 Stage 6c — the week in the cache

**The key — `DataManager.Key.weekTotals`.**

- A JSON-encoded `[Int: Int]` — day ordinal (`yyyyMMdd`, `dayOrdinal(for:in:)`) to millilitres —
  after `Key.wristApplied`'s precedent, the other ordinal-keyed value in the phone's suite.
- Exactly `DataManager.historyWindow` entries: the seven days ending on the writer's today, zeros
  included. **A day that is present is known; the key's absence means unknown**, so it is never
  materialised and never written as zeros on anybody's behalf (rule `25-shared-storage`).
- Listed in `Key.all`, which puts it under `readingLeavesTheStoreUntouched`,
  `readingAnEmptySuiteDoesNotCreateKeys` and `theTripwireHelperEnumeratesEveryStoredKey`.
- The phone's suite goes from ten keys to eleven; `Key.all` from twelve to thirteen.

**The writer — `DataManager`, and only where today's total is recomputed.**

- **W1.** Written by `init` (`DataManager.swift:585`) and by `saveAndRecompute()` (`:1112`), straight
  after `recomputeToday()`, in every process that builds a `DataManager` — the app and the widget
  extension. Every mutation ends in `saveAndRecompute()`: a pour, a deletion, an edit, an undo, a
  reset, a watch pour, the seed. So a widget tap the morning after rewrites the week from the rows,
  yesterday included.
- **W2.** Never by `refresh()`, `dayDidTurn()`, `resetIfNeeded()`, `applyDailyReset(on:)` or
  `loadFromStore()`. `refresh()` must not recompute today's total because a read across processes can
  succeed while missing the other process's newest row (`refreshPicksUpAnExternalWrite`); the week
  is the same figure over more days, and takes the same rule. `applyDailyReset` keeps its two writes.
- **W3.** From one fetch of `[historyWindowStart(endingOn:), nextDayBoundary(after:))`, rolled up by
  the code `DaySummary.series(from:days:endingOn:in:)` already runs. In the app the mutation's one
  fetch feeds both the cache and the week card on that pass — no second fetch.
- **W4.** A failed read writes nothing and leaves the key as it stands (rule `20-state`).
- **W5.** An unchanged week writes nothing.
- **W6.** The write rings `reloadWidgets()` when the key was missing or unreadable before, or when a
  day **before** today moved — an edit in History, a late watch pour. A change to today is announced
  by the `currentWater` setter, as now, so a real change still rings exactly once.
- **W7.** No new role question. Both phone roles write, as both recompute today's total; the watch
  cannot build a `DataManager` at all (`init` is `@available(watchOS, unavailable)`). The four role
  questions and their seven sites are unchanged.
- `republishHistory()`'s DocC — "a per-day series is derivable from none of the cache keys" — is
  rewritten, and its `drawsHistory` guard stays: the week card's observable state is still the app's
  alone.

**The reader — `WaterSnapshot`.**

- **R1.** `WaterSnapshot` gains `weekTotals: [Int: Int]?`, defaulted to `nil`, so the existing
  memberwise calls — 29 occurrences of `WaterSnapshot(` by `git grep` at `41309e3`, DocC mentions
  included, 17 of them in the widget target, which the app scheme's tests never compile — still
  build unchanged.
- **R2.** `snapshot(defaults:calendar:now:)` reads and validates it on the way out: a failed decode,
  a count other than `historyWindow`, or any value outside `0...maximumDailyIntake` discards the
  **whole** map to `nil` — never a partial repair, as `resolveServings(in:)` treats its triple. It
  writes nothing.
- **R3.** `nonisolated func week(endingOn: Date, calendar: Calendar) -> [DaySummary]?` — `nil` when
  `weekTotals` is `nil`; otherwise exactly `historyWindow` days, oldest first, walked by the code
  `DaySummary.series` walks, factored out so the week card and the widget cannot name different days.
  The day containing `endingOn` takes `currentWater`; every other day its cached total, or zero when
  the cache does not hold it (a day newer than the last write had nothing logged).
- **R4.** At the midnight entry `endingOn` is midnight: the week shifts by one, yesterday comes from
  the key, today is the rolled-over zero. `rolledOver()` still changes only the total, and
  `rollingOverChangesNothingExceptTheTotal` holds as written.
- **R5.** `weekTotals` and `week(endingOn:calendar:)` are `nonisolated` when written — the app
  target's `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` would infer them `@MainActor` (#147,
  `tasks/lessons.md` 2026-10-18).

**What it costs.**

- A seven-day fetch and roll-up on every widget tap, in the extension. Measured in the plan, the way
  the lag fix measured (§7), and reported before 6c's code is kept.
- After a change of time zone the cached days stay bucketed in the old zone until the next mutation;
  the week card regroups at once (`dayDidTurn()`). Documented, not fixed.
- A clock moved back past the last write leaves the oldest day uncached, drawn as zero. Documented.

### 3.5 Stage 6c — the week widget

**Configuration.**

- `WeekWidget`, a fourth widget in the extension, in its own file `WaterBuddyWidget/WeekWidget.swift`.
  The synchronised folder brings it in; `project.pbxproj` is not edited.
- Kind `"WaterBuddyWeek"` — permanent once shipped, as the control's is.
- Listed in `WaterBuddyWidgetBundle` after `WaterBuddyWidget`.
- `StaticConfiguration` over the **same** `HydrationProvider` and `HydrationEntry`: one snapshot, one
  midnight, one reload for every widget. Its view draws
  `entry.snapshot.week(endingOn: entry.date, calendar: .waterBuddyDay)`.
- `.systemMedium` only. `.contentMarginsDisabled()`, the card inset and padding, the `.frosted` /
  `.raised` card pane, `WidgetCardBackdrop` and `WidgetAurora` — the Hydration widget's, made visible
  to the new file inside the target rather than copied.
- Its root injects `entry.snapshot.language.bundle`, `.locale` and the dark colour scheme, as
  `HydrationView` does (rule `40-widget`).
- Gallery strings, static literals naming no figure: *"Week"* and *"Your last seven days against your
  goal."*

**What it draws.**

- **History's card, at widget size:** the title *Last 7 days*, seven bars on their tracks, the dashed
  goal line, the narrow weekday letters (`.dateTime.weekday(.narrow)` under the snapshot's locale),
  and one figure, *Goal met · 5 of 7* — History's own label and its `%1$@ of %2$@` figure. Whether the
  figure trails the title on one row or stands under the bars is settled with renders in the plan, on
  the narrowest and widest medium widget, at default type and at the cap.
- **Today** is the last bar; its letter is drawn heavier — the mark History gives its shown day,
  without the ring and the disc, because nothing here is selected.
- **The scale** is `max(goal, best day, 1)`, as History's, so a day over the goal stands above the
  line rather than clipped to it. Every day is judged against the current goal, as History's.
- **The values are History's** — `Aurora.cyan` for a met day, white for the rest, tracks at white
  0.10, the goal line 1.5 pt at white 0.62, dashed `[4.5, 3]` — and **each pair is measured again on
  the widget's own rendered pane**, never carried over: History's figures were read on its own panes.
  Non-text marks hold 3:1, the letters and the figure 4.5:1. A pair that falls under its floor stops
  the stage and comes to the owner (the floors hold, as ruled for stage 3c).
- **Left out:** History's footnote, *Measured against your current goal* — there is no room; History
  keeps saying it. The average and the best day are spoken, not drawn.
- **Type** is capped at `...DynamicTypeSize.accessibility1`, `.lineLimit(1)` and
  `.minimumScaleFactor(0.6)`, as the medium column is; the bars take the height that is left.
- **Nothing moves.** No animation and no clock-driven phase — a widget gets snapshots, not frames.

**In the other rendering modes.**

- A tinted Home Screen: the panes are rims, the aurora is black, the tracks and the goal line white;
  a met bar carries `.widgetAccentable()` and takes iOS's accent, an unmet one stays white. A met day
  still stands at or above the line, so colour is never its only sign (rule `65-accessibility`).
- Reduce Transparency: the card follows `WidgetPane` and `WidgetCardBackdrop` as the Hydration
  widget's does.

**For VoiceOver.**

- The card is one element: label *Last 7 days*, value the sentence History's card speaks —
  *Average … millilitres. Best … millilitres. Goal met on 5 of 7 days.* The bars, the letters and the
  drawn figure are hidden.

**With no week yet.**

- When `week(endingOn:)` is `nil` — 1.3 installed and never opened, nothing tapped yet, or a corrupt
  key — the card draws its title and *Open WaterBuddy to see your week.*, and speaks the same. It
  never draws a week of zeros. Any first write rings the widget (W6), so it turns over as soon as the
  app or the Hydration widget's button runs.

### 3.6 Stage 6c — the link to History

- **One spelling.** `WidgetLink`, a file-scope `nonisolated` enum in `DataManager.swift` beside
  `WaterSnapshot`, holds the link as a `URL?` built without a force-unwrap (rule `75-diagnostics`:
  never trap). Both processes compile that file; the shared set does not grow (rule `15-project`).
- **The widget** sets `.widgetURL(WidgetLink.history)` on the whole card. The Hydration widget keeps
  no link; its behaviour is unchanged.
- **The app.** `AppTab(link:)` — pure, `nonisolated`, in `RootTabView.swift` — answers which tab a URL
  names, or `nil`. `RootTabView` gains `.onOpenURL`, which turns to History through `PageTurn`
  exactly as a tap on its tab would, cross-fading under Reduce Motion. No haptic: the user tapped the
  widget, not the bar.
- **Before setup** `RootTabView` does not exist — the welcome is the root while `isGoalSet` is false
  (`WaterBuddyApp.swift:150`) — so the link is ignored and the welcome stays.
- **Whether iOS delivers the link without a registered URL scheme is inferred, not known.** It is the
  first thing 6c proves on the simulator. If it needs one, the stage stops and comes to the owner: a
  scheme is an entry point any app or web page can open, and it is not added unasked.
- Rule `50-views` gains one sentence (§5): a widget's link is an entrance from outside, not a second
  route inside the app.

### 3.7 Strings

- **New, in both catalogues** (`WaterBuddyWidget/` draws them; `sharedKeys` asks the app's bundle to
  agree), `en`, `ru`, `uz` — the translations are for the owner's check (§10 D2):

  | Key | `ru` | `uz` |
  |---|---|---|
  | *Week* | *Неделя* | *Hafta* |
  | *Your last seven days against your goal.* | *Последние семь дней в сравнении с вашей целью.* | *Oxirgi yetti kun — maqsadingizga nisbatan.* |
  | *Open WaterBuddy to see your week.* | *Откройте WaterBuddy, чтобы увидеть свою неделю.* | *Haftangizni ko‘rish uchun WaterBuddy’ni oching.* |

- **Copied into the widget's catalogue from the app's**, byte for byte, plural variations included:
  *Last %1$d days*, *Goal met*, *%1$@ of %2$@*, and *Average %1$d millilitres. Best %2$d millilitres.
  Goal met on %3$d of %4$d days.*
- All seven join `sharedKeys` in `LocalizationTests`.
- None carries a user value into a notification; the gallery strings name no figure (rule
  `40-widget`).

## 4. What it touches beyond the widget

- **Storage:** one key, derived, written by `DataManager` only (§3.4). No `WaterLog` change, no
  schema change, no migration.
- **`DataManager.swift`** (compiled into all four targets): the key, the write, the snapshot's field
  and function, the factored day walk, `WidgetLink`, and the DocC on `republishHistory()`, `Key` and
  `WaterSnapshot`.
- **The app:** `RootTabView` — `.onOpenURL` and `AppTab(link:)`. Nothing else in the app changes.
- **The watch:** nothing. Its two targets compile the new members and never call them.
- **Reminders:** none. The week moves no slot.
- **Entitlements, exception sets, privacy manifests, `Info.plist`:** unchanged — unless the link
  needs a URL scheme, which stops the stage (§3.6).
- **The Lock Screen widget and the control:** unchanged.

## 5. What this amends — proposed, for the owner's word

Typed into the rule files unstaged, **before 6a's code**, for the owner to approve as typed.

- **`60-design-system`**, *The primary surface*, a new bullet after "a screen carries at most one":
  "In the Home Screen widget the pour button is the primary surface in `.fullColor` —
  `.primarySurface(in:ring: false)`, so it stays exactly its 44-pt target and the vessel's clearance
  holds (rule `40-widget`). Outside `.fullColor` it is white content in the lit rim, as every pane
  there is."
- **`60-design-system`**, *In the widget*, two new bullets:
  "When the system removes the container background — `showsWidgetContainerBackground` is `false`,
  on iPhone StandBy — the small family draws no card, no card pane and no backdrop: the vessel and
  the pour button stand on the system's black. The vessel draws its lit rim and its water, never its
  glass, because glass never goes over a flat background." *(Its last sentence stands or falls with
  §10 D4.)*
  "The week widget draws History's week card from History's values — `Aurora.cyan` for a met day,
  white for the rest, white 0.10 tracks, the dashed goal line at white 0.62 — each pair measured on
  the widget's own rendered pane (`docs/DESIGN.md`), never carried over from History's figures.
  Outside `.fullColor` a met bar is `.widgetAccentable()`."
- **`40-widget`**, a new section, *The week widget*:
  "- `WeekWidget` is a fourth widget in the same extension, in its own file: its own kind
  (`"WaterBuddyWeek"`, permanent once shipped), its own `StaticConfiguration`, `.systemMedium` only,
  listed after `WaterBuddyWidget`.
  - It reads through the same `HydrationProvider` and `HydrationEntry` — never a second provider —
  and draws `entry.snapshot.week(endingOn: entry.date, calendar: .waterBuddyDay)`, so the midnight
  entry shifts its week from the same snapshot that zeroes the total.
  - It keeps the Home Screen widget's `.contentMarginsDisabled()`, card, backdrop and aurora, and
  injects `entry.snapshot.language.bundle` and `.locale` at its root.
  - It carries no button. A tap opens History through `.widgetURL(WidgetLink.history)`, the one
  spelling of the link, which the app reads too.
  - When the snapshot's week is `nil` it says so — *Open WaterBuddy to see your week* — and never
  draws a week of zeros.
  - Its gallery strings are static literals that name no figure."
- **`40-widget`**, *The read path*, a new bullet: "`WaterSnapshot.weekTotals` is the cached week,
  validated on the way out — a failed decode, the wrong count or a value outside
  `0...maximumDailyIntake` discards the whole map to `nil`, never repairs it — and
  `week(endingOn:calendar:)` is the one place the bars are computed. Both are `nonisolated`."
- **`40-widget`**, *Glass and rendering*, a new bullet: "The small family reads
  `showsWidgetContainerBackground` once, in `HydrationView`, and hands its layout a flag, so a
  `#Preview` can draw the bare layout the environment cannot be set to."
- **`40-widget`**, *Proving it*, appended: "The simulator has no StandBy: draw the bare layout through
  its `#Preview`, and take the small widget into StandBy on a device, by day and at night. Place the
  week widget, tap it, and see History open."
- **`20-state`**, *Today's total is derived, never authored*, a new bullet: "The week is derived the
  same way. `Key.weekTotals` — the last `historyWindow` days' totals by day ordinal — is rewritten
  from the rows by exactly the two paths that recompute today's total, `init` and
  `saveAndRecompute()`, in every process that builds a `DataManager`; in the app from the same fetch
  as the week card. Never by `refresh()` or `dayDidTurn()`, for `refresh()`'s reason. A failed read
  writes nothing and an unchanged week writes nothing. It rings the widget doorbell when it was
  missing or a day before today moved; today's own change is the `currentWater` setter's ring, so a
  real change still rings once."
- **`25-shared-storage`**, *Keys*: "Absence carries meaning for `Key.isGoalSet`, `Key.language`,
  `Key.reviewRequestedVersion` (never asked) and `Key.weekTotals` (not yet known — the week widget
  says to open the app)". And *Only the app writes on behalf of the group*, the `role.drawsHistory`
  bullet, appended: "The week's cache is not group bookkeeping but a derived figure, like today's
  total: `saveAndRecompute()` writes it in the extension too, and no role answers for it — the watch
  cannot build a `DataManager` at all."
- **`30-rollover`**, *The widget rolls itself over*, a new bullet: "The week widget turns over from
  the same midnight entry: `week(endingOn:)` at the entry's date takes yesterday from
  `Key.weekTotals` and today from the rolled-over total. `rolledOver()` still changes only the total."
- **`10-architecture`**, the diagram's "10 keys, derived cache" becomes "11 keys, derived cache", and
  the paragraph under it, after "brings it to 10": "; `Key.weekTotals`, the last seven days' totals
  the week widget draws, brings it to 11."
- **`50-views`**, *Navigation*, after "Every destination has exactly one route to it": "A widget's
  link from outside the app is an entrance, not a second route: `RootTabView` answers
  `WidgetLink.history` in `.onOpenURL`, through `AppTab(link:)`, by turning to History as its tab
  would. Before setup the link is ignored."
- **`65-accessibility`**, *VoiceOver*, a new bullet: "The week widget is one element: label *Last 7
  days*, value the sentence History's card speaks — the average, the best day and the days met. Its
  bars, letters and figure are hidden. With no week, its value is the line it draws."
- **`70-privacy`**, *WatchConnectivity is a ruling*, the second limit, after the sentence on the Lock
  Screen widget: "The week widget is a Home Screen widget, as the Hydration widget is: its totals
  count the watch's pours, as `currentWater` does, and it takes no carve-out of its own."
- **`70-privacy`**, *The lock screen is a public surface*, a new bullet after the Lock Screen widget's
  (§10 D3, ruled yes): "**StandBy is a locked-phone surface too.** The small Home Screen widget's
  figures — the vessel's percentage and its water — carry `.privacySensitive()`, and the vessel draws
  the Lock Screen widget's quiet form — an empty rim, no water, no figure — whenever
  `redactionReasons` contains `.privacy`, so iOS's own lock settings decide what a phone on a
  nightstand shows. On an unlocked Home Screen nothing is redacted."
- **`65-accessibility`**, *VoiceOver*, appended to the Lock Screen widget's bullet: "The small Home
  Screen widget's quiet form is the same: its vessel keeps its label and speaks no figure."
- **`85-testing`**, *A green suite is not proof the product works*, after "put the control in Control
  Center": "put the week widget on the Home Screen and tap it into History; take the small widget into
  StandBy on a device, by day and at night, since the simulator has none".

Left to `/doc_sync`, not to this amendment: `CLAUDE.md`'s target table (three `StaticConfiguration`s,
not two) and its "ten keys"; `docs/STATE.md`'s key table; `docs/WIDGET.md`'s configuration, read
path and rendering sections; `docs/DESIGN.md`'s measured figures; `docs/ROADMAP.md`'s 1.3.1 entry.

## 6. Privacy

- **Nothing leaves the device.** No framework, entitlement, usage description or network.
- **The week widget is a Home Screen widget** showing the user's own totals, counting watch pours, as
  the Hydration widget does (§5's `70-privacy` sentence). It has no Lock Screen family, and as a
  medium widget it does not appear in StandBy.
- **StandBy is a locked-phone surface.** The small widget already shows its percentage there today,
  with no `.privacySensitive()`. By the owner's ruling (§10 D3) it now carries `.privacySensitive()`
  and the Lock Screen widget's quiet form (§3.3), so iOS's own lock settings can hide the figure.
- **The streak** is not drawn: *Goal met · 5 of 7* counts the week's met days, which History already
  shows; the run never leaves the app (rule `20-state`).

## 7. Testing

Written first, run RED on seams that compile, then GREEN (rule `85-testing`). Every fixture: its own
UUID-named suite torn down in a `defer`, an in-memory container, `reloadWidgets` counted, and
`rescheduleReminders: { _ in }`.

**What the test target cannot reach.** `WaterBuddyTests` is hosted by the app
(`TEST_HOST = …/WaterBuddy.app/…`), which compiles none of the widget's own sources — no existing test
names a widget-only type. So 6a and 6b, which change only views in `WaterBuddyWidget/`, have **no
unit seam**: they are proved by both widget builds, their `#Preview`s and renders (§8). Everything 6c
decides lives in `DataManager.swift` or `RootTabView.swift`, where the tests can reach it.

- **`WeekCacheTests`** (new file `WaterBuddyTests/WeekCacheTests.swift`, `@MainActor`):
  - `aPourCachesTheWeek` — servings today and on two earlier days; the key decodes to seven ordinals
    with those totals and zeros.
  - `theMorningAfterATapKeepsYesterday` — a manager on day D logs through the day; a second manager on
    the same suite and container, its clock on D+1 (the extension's fresh process), logs one serving;
    the snapshot's week on D+1 shows D's whole total and D+1's serving. The test the gap in §2 fails.
  - `anEditToAPastDayRewritesTheWeekAndRingsOnce` and `aPourTodayRingsOnce` — the doorbell counts.
  - `theFirstWeekRingsTheWidget` — no key before `init`, one after, and a ring for it.
  - `refreshWritesNoWeek` and `aDayTurnWritesNoWeek` — a valid sentinel week survives both, rows
    added behind the manager's back notwithstanding.
  - `aFailedReadLeavesTheWeekAsItStands` — through `UnreadableStore`, proved unreadable first.
  - `theWeekWidgetAgreesWithTheWeekCard` — after a set of pours, `manager.history` equals the
    snapshot's `week(endingOn: now)`, including across a daylight-saving day.
- **`WaterSnapshotTests`** (existing, not `@MainActor`):
  - the snapshot carries the cached week; an absent key, undecodable data, the wrong count, a negative
    value and one over `maximumDailyIntake` each read as `nil`;
  - `week(endingOn:)` — seven days oldest first, today from `currentWater`, a day newer than the
    cache as zero; at midnight, shifted by one, yesterday from the key and today zero;
  - `readingLeavesTheStoreUntouched`, `readingAnEmptySuiteDoesNotCreateKeys` and
    `rollingOverChangesNothingExceptTheTotal` stay green unedited; the tripwire roster gains the key
    through `Key.all`.
  - The isolation check, as #147 established it: one `async` test that reads `weekTotals` and the
    result of `week(endingOn:)` **into locals** before `#expect`, and is seen to warn with
    `nonisolated` taken off and to stop with it back. No rule or DocC calls it a canary until that is
    seen (`tasks/lessons.md` 2026-10-18).
- **`RootTabViewTests`** (existing): `AppTab(link:)` answers `.history` for `WidgetLink.history`, and
  `nil` for another scheme, another host and a bare URL.
- **`LocalizationTests`**: `sharedKeys` gains the seven keys; the three new ones resolve to the
  table's values in `en`, `ru` and `uz` in both bundles, each bundle proved to resolve first.
- **No UI test for the link.** `XCUIApplication.open(_:)` asks the system to route a URL, which needs
  a registered scheme this design avoids. The link is proved by tapping the placed widget (§8.3).
- **Measured, not tested: the extension's fetch.** A throwaway probe, not kept, times the window fetch
  and roll-up against today's fetch on a lived-in week (ten servings a day), on the simulator, with
  its own timestamped log and the load written into it (`tasks/lessons.md` 2026-10-18). The figure
  goes into `HISTORY.md`; the owner sees it before 6c's code is kept.

## 8. Verification

### 8.1 The gate

After each stage: all five invocations, in the foreground, as rule `85-testing` writes them, and the
UI suite again on iOS 26.5.

### 8.2 Warnings

A clean build of the code before and after each stage, into empty DerivedData, compared per file and
message. `DataManager.swift` changes in 6c, so every scheme is compared then; 6a and 6b change only
`WaterBuddyWidget/`, so the widget scheme's comparison is the one that can move.

### 8.3 On the simulator, then the owner's device

- **Simulator (iOS 27.0):** the Hydration widget, small and medium, placed on the Home Screen in
  light, dark and tinted — the white disc and capsule, the button still logging; the bare small layout
  through its `#Preview` and a throwaway render, in full colour and `.vibrant`, and its quiet form
  under `.redacted(reason: .privacy)`; the week widget placed
  — bars agreeing with History, a past-day edit in History reaching it, its empty state before the
  key exists, a tap opening History on a warm and on a cold launch, and in Russian and Uzbek. The
  colour pairs measured off its render into `docs/DESIGN.md`.
- **The owner's iPhone, joining 1.2.7's sweep:** StandBy by day and at night — the bare layout, the
  red tint, a tap that logs, and whether the figure is hidden while locked with *Allow Access When
  Locked → Lock Screen Widgets* off; the week widget at midnight with the app not run since, and the morning
  after a tap; VoiceOver on the week; the week on the narrowest iPhone to hand.

## 9. Known limitations, and what is not in scope

- **No week anywhere but the Home Screen** — not on the Lock Screen, the watch, a large family or in
  StandBy. A configurable week (`AppIntentConfiguration`) is not built.
- **The week widget has no pour button.** The Hydration widget beside it has one.
- **A change of time zone** regroups the week card at once and the week widget only at the next
  mutation (§3.4). **A clock moved back** past the last write draws its oldest day as zero.
- **History's footnote** is not on the widget (§3.5).
- **StandBy is device-only**, and what iOS does with a removable background in other places is not
  examined: iPhone is the only device the app ships for.
- **The Hydration widget keeps no link.** Its tap opens the app as today.
- **The rendering mode at night in StandBy** is inferred to be `.vibrant` (§3.3); the device check
  settles it.

## 10. Open before the plan

- **D1 — the catalogues.** 6c edits `WaterBuddy/Localizable.xcstrings` and
  `WaterBuddyWidget/Localizable.xcstrings`. Xcode must not have the project open while they are
  edited by hand (`tasks/lessons.md`, 2026-10-18: an open Xcode rewrote the catalogues the moment new
  Swift files appeared). The working tree also holds Xcode's unstaged rewrite of
  `WaterBuddy/AppShortcuts.xcstrings` and both watch catalogues, and two watch schemes without
  `BlueprintName` (#50). This change touches none of them; restoring or keeping them is the owner's.
- **D2 — the Russian and Uzbek** of the three new strings (§3.7), for the owner's check.
- **D3 — StandBy and privacy.** Recommended: in the small family, the figures carry
  `.privacySensitive()` and the vessel draws the Lock Screen widget's quiet form when
  `redactionReasons` contains `.privacy` — no percentage, no water — so a locked phone in StandBy hides
  the figure whenever iOS's own lock rules say to. On an unlocked Home Screen nothing changes. Or:
  leave it as today, figure always shown.
- **D4 — the vessel on black.** Found while writing §3.3: rule `60-design-system` forbids glass over a
  flat background, so in the bare layout the vessel draws its lit rim and its water, not its glass.
  It was not in the section the owner approved, which said only "the vessel and the button on black".

*(2026-10-19: the owner approved this spec as written and ruled all four in one reply — D1, restore
the five files to `HEAD`, with Xcode closed first; D2, the translations as written; D3, mark the
figures, with the quiet form; D4, the rim and the water only. §3.3, §5, §6 and §8.3 now carry D3.)*

## 11. Sequence

1. This spec, staged.
2. §10's D1 to D4, by the owner.
3. §5's rule wording, typed unstaged, for the owner's approval.
4. The implementation plan.
5. **6a:** the button's modifier and both families — builds, previews, renders — then the gate and
   the warning comparison. Staged.
6. **6b:** the flag, the bare layout and its previews — builds, renders — then the gate and the
   warning comparison. Staged.
7. **6c:** first the link's delivery proved on the simulator (§3.6); then the fetch measured (§7);
   then the seams that compile, every new member present with the wrong behaviour; the tests in §7
   run RED, each failing on its own expectation; the key, the write, the snapshot, the widget, the
   link and the strings — GREEN; the gate, the warning comparison and the simulator pass (§8.3).
8. `HISTORY.md` and `/doc_sync` after each stage the owner chooses to commit.
9. Staged by explicit path; no commit until the owner's `/commit`.
