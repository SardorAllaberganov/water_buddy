# The premium redesign — design

**Status:** the look was approved by the owner in conversation on 2026-10-09, on a canvas of twelve
boards ("ok"), and **this document was approved by the owner the same day ("ok, approve all")**, with
all seven decisions of §13 taken as recommended. Nothing is implemented yet. Stage 1's plan is
`docs/superpowers/plans/2026-10-09-premium-redesign-stage-1.md`; writing it moved three items between
stages, recorded in §3.2 and §14.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes. Where it proposes a rule change (§10), the rule stands as written until the owner approves
the new wording.

**Provenance.** Every claim about the repository was read at HEAD `8a44e8f` on 2026-10-09. **SDK** is
`iPhoneSimulator27.0.sdk` and `WatchSimulator27.0.sdk` in Xcode 27.0 (27A266a) on this machine: the
`SwiftUICore` `.swiftinterface` for a declaration, its `.swiftdoc` for a doc comment. A claim about
how iOS draws something that no SDK line states is marked **unconfirmed**, and each one is either
designed so that either answer is safe or named in §11.

**The canvas.** <https://claude.ai/artifact/UYGcabBfVjduqkzvqtZ5bt>, page *Aurora full set*: four
welcome steps, Home, Home just after a pour, History, the serving sheet, Settings, the small and
medium widgets, the watch. The canvas is HTML and its glass is an approximation; §12 lists every
place the build differs from it.

## 1. What is being built

One visual and interaction pass over every surface the user sees, so the app looks worth paying for
before StoreKit and a paid tier arrive. It ships as its own version after 1.1.

**The owner's rulings, all 2026-10-09:**

1. The redesign comes before StoreKit.
2. Scope is everything: the phone app, the Home Screen widget, the watch app.
3. It may add free features. Four were chosen: a streak, a multi-step welcome, insights in History,
   and Undo on Home.
4. The look is direction A, *Aurora, refined*: today's aurora and round vessel. The quick-add buttons
   become round discs with the Glass larger and white, each with its amount and then its name beneath.
5. The app uses Apple's own Liquid Glass.
6. The iOS floor stays 17.0. iPhones below iOS 26 keep the hand-made glass.
7. "ok" on the full set, which this document takes as yes to: a reminders step in the welcome, the
   watch without its *More* sheet, vessel shortcuts in the serving sheet, and a free streak.

**What does not change:** the stored shape (no new `UserDefaults` key, no change to `WaterLog`), the
one-writer rule, the widget's read path, the reminder schedule, the Lock Screen widget, the Control
Center control, the watch complication, and every string a notification or Siri shows.

## 2. What happens today

- **Glass is hand-made.** `LiquidGlassModifier` stacks a system material, a black scrim, a white tint,
  a specular gradient, a lit rim and two shadows. Its comments say Apple's API "cannot be called
  here" because the project "builds against 18.5". That is stale: the installed SDK declares
  `glassEffect(_:in:)`, `Glass` and `GlassEffectContainer` for iOS 26.0 and watchOS 26.0.
- **The shared glass file serves two floors.** `LiquidGlassModifier.swift` compiles into the app and
  the widget extension (iOS 17.0) and into the watch app and watch widget (watchOS 26.0).
- **Only the widget passes a `base`.** Every glass call site takes the default
  `.material(.ultraThinMaterial)` except `WidgetPane`, which passes `.archived`, a flat fill, because
  a widget cannot sample what is behind it.
- **Home is a vessel and three equal buttons.** No header, no figure for what is left, nothing about
  the last drink or the next reminder, and no way to take back a mis-tap short of opening History.
- **`addLog` returns nothing**, so a caller cannot name the row it just added.
- **History fixes its header and week card and scrolls only the rows.** The card shows an average and
  a best figure; nothing counts the days the goal was met.
- **First run is one screen.** `GoalSetupView` commits with `saveDailyGoal(ml:)`, which is also the
  only thing that flips `isGoalSet` and so switches the root from setup to the tabs.
- **Notification permission is asked in exactly one place**, `SettingsView.enableReminders()`, and the
  status is read only by that screen. `DataManager` never knows whether a planned reminder can be
  delivered.
- **When the day turns with the app open**, the observer calls `resetIfNeeded()` alone. Today's rows
  and the history window are not republished until the next `refresh()` or mutation.
- **The phone's visible volumes are not grouped** (`1300 / 2000 ml`, known issue #39). The watch's
  are.
- **On the watch the vessel is the Glass button**, sized at 0.78125 of the screen's height by an
  owner ruling, with Cup and Bottle behind a *More* sheet that sits below the fold on every size.

## 3. The look

### 3.1 Ground, colour and type

- **The aurora is unchanged**: the same five `Aurora` colours, the same three lights, the same motion.
  `LiquidGlass.Base.archived` is derived from those colours and so stands as it is.
- **The accent stays `Aurora.cyan`.** The canvas drew a lighter shade; that was the drawing, not a
  new token.
- **One new surface, the primary surface** (§3.3), needs a dark content colour. It is `Aurora.top`,
  the existing deep blue, which computes to about 13:1 on white. No new colour token is added.
- **Figures are set in the system's rounded design**, as every hero readout and the widget already
  are. The rule extends to the amounts in rows, the stats in History and the watch buttons. There is
  no custom font.
- **Visible volumes are grouped under the app's locale** (`1,300 of 2,000 ml`), on every surface this
  redesign touches, by formatting the number first and passing it to a `%1$@` key. Spoken strings
  keep their `%1$d` keys and their wording, so every VoiceOver value the UI tests assert is
  unchanged. This closes known issue #39 for the touched screens.

### 3.2 Glass

`.liquidGlass(…)` stays the only way to put content on glass (rule `60-design-system`). What it draws
becomes a three-way choice, made in this order:

| Condition | What is drawn |
|---|---|
| Reduce Transparency is on | Today's opaque fill and lit rim, on every OS. Unchanged. |
| The base is `.flat` (the widget's `.archived`) | Today's hand-made stack. Unchanged. |
| The base is `.material`, on iOS 26 or watchOS 26 and later | Apple's glass, `glassEffect(_:in:)` |
| The base is `.material`, below iOS 26 | Today's hand-made stack. Unchanged. |

- **No call site changes and no parameter is added.** The existing `base` already separates "can
  sample its backdrop" from "cannot".
- **The choice is a pure function**, `LiquidGlass.rendering(base:reduceTransparency:appleGlass:)`,
  declared `nonisolated static` so a test outside the main actor can pin the table above.
- **Reduce Transparency keeps our own branch, first.** The SDK's doc comments say nothing about how
  Apple's glass behaves under that setting (**unconfirmed**), so the design does not depend on it.
- **The widget never draws Apple's glass.** It keeps `.archived`. Whether `glassEffect` could draw
  inside a widget archive is not tested and not needed.
- **The watch draws Apple's glass at every `.material` site**, because its floor is already 26.0 —
  **from the watch stage (§14), not before.** Until then the routing answers "available" on iOS only:
  no watchOS 26 simulator runtime is installed, and a pane nobody has rendered is not one to ship.

How the existing options map onto Apple's glass. These are starting values; §11.3 says how they are
settled.

| Option | On Apple's glass |
|---|---|
| `density: .sheer` | `Glass.clear` for the vessel, whose readout has its own scrim; `Glass.regular` wherever the pane carries text |
| `density: .frosted`, `.opaque` | `Glass.regular` |
| `interactive: true` | `.interactive()`. `PressStyle` keeps its recoil and stays the only writer of `glassIsPressed`, which the fallback still reads |
| `elevation` | Not drawn. Apple's glass brings its own depth; our two shadows belong to the hand-made stack |
| `tint`, `tintOpacity` | Not passed today. A dark `.tint(…)` is added only if a measured contrast figure requires it |

Sibling panes that sit close together (the quick-add row, the tab bar's slots) are wrapped in a
`GlassEffectContainer` on Apple's path. The SDK's doc comment says the modifier is typically used
with one, "to combine multiple glass shapes". Below iOS 26 the wrapper is a pass-through. It arrives
with its first user, the quick-add row, in stage 2.

The stale "cannot be called here" comments in `LiquidGlassModifier.swift`, `PressStyle.swift`,
`LiquidGlassTests.swift` and `docs/DESIGN.md` are corrected in the same change.

### 3.3 The primary surface

Each screen has at most one main action, and it is drawn the same way everywhere: **a solid white
shape with `Aurora.top` content.** It is the Glass button on Home, *Get Started*, *Continue* and
*Turn on reminders* in the welcome, *Save* in the sheet, the widget's pour button, and the Glass on
the watch.

- It is a second surface class beside glass, which rule `60-design-system` does not allow today
  ("Every surface in WaterBuddy is glass over an aurora"). §10 proposes the wording.
- It is drawn by one modifier, `primarySurface(in:)`, in `LiquidGlassModifier.swift`, so the widget
  and the watch can draw it without a seventh shared file.
- The fill is white, shaded toward the bottom with `Aurora.top` at low opacity. No colour literal.
- It carries the two shadows of `Elevation.raised`, and on the phone a soft outer ring.
- It replaces the cyan glow that *Get Started* and *Save* carry today.
- Secondary actions (*Cancel*, *Not now*, *Back*, *Undo*, *Open iOS Settings*) stay glass or plain
  text.

### 3.4 Controls and the tab bar

- **Sliders and the switch are the system's**, tinted `Aurora.cyan`, as today. On iOS 26 they already
  draw in the new system style.
- **The tab bar stays the app's own three-slot bar** (`GlassTabBar`), mounted as it is now. The
  selected slot gains a lighter lozenge behind it in addition to the cyan glyph, the white caption
  and the `.isSelected` trait. `theBarHoldsThreeTabs` and the rest of `AppTabTests` stand.
- The system `TabView` is not adopted. Rule `50-views` bans it, and the UI tests address the bar's
  three buttons by label.

## 4. The welcome

Canvas boards *Welcome 1* to *Welcome 4*.

### 4.1 What the user sees

| Step | Content | Buttons |
|---|---|---|
| Hello | A half-full vessel, *Welcome to* / *WaterBuddy*, one line of what the app does | *Get Started* |
| Daily goal | The existing question, the goal figure, the 1,000 to 4,000 slider, "You can change this later in Settings." | *Back*, *Continue* |
| Vessels | Cup, Glass and Bottle, each with its slider, and the note that the Glass is what the widget, Siri and Control Center log | *Back*, *Continue* |
| Reminders | The existing description of the schedule, and a strip of the seven daily slots | *Back*, *Turn on reminders*, *Not now* |

Four dots show the position. The first step keeps the button title *Get Started*.

### 4.2 Behaviour

- **`WelcomeView` replaces `GoalSetupView`.** The steps are a file-scope `enum WelcomeStep` and a
  state-switched `ZStack`, the idiom `RootTabView` uses. No `NavigationStack`.
- **Nothing is stored until the last step.** Goal and vessel amounts live in view state. Quitting
  part-way stores nothing, and the next launch starts the welcome again.
- **The last step commits in a fixed order**, because the final call is what dismisses the welcome:
  1. `manager.servings = amounts`. The setter does nothing when the amounts are unchanged, so the
     defaults are still never materialised.
  2. For *Turn on reminders* only: ask for permission and set `remindersEnabled` from the answer
     (§4.3).
  3. `manager.saveDailyGoal(ml: goal)`. This flips `isGoalSet`, and the root cross-fades to the tabs.
- **Existing users never see it.** The root gate is still `manager.isGoalSet`.
- **`goalRange` and `goalStep` move to `WelcomeView`**, the first screen that offers them. Settings'
  goal card and `DailyGoalSetupTests` read them from there.

### 4.3 Permission

Asking from the welcome contradicts two rules as written (§10). The design is:

- **One implementation, `ReminderPermission`**, an app-only type in its own file, holding what
  `SettingsView.enableReminders()` and `readSystemState()` do today:
  - `enable(on:using:)`: request if the status is `.notDetermined`, then set `remindersEnabled` from
    the grant; otherwise set it to "not denied".
  - `reconcile(_:using:)`: read the status and clear `remindersEnabled` if it reads `.denied`.
- **It is asked only in answer to a tap that asks for reminders**: the Settings switch turning on, or
  *Turn on reminders*. Never when a step appears.
- **A refusal stores `false`.** *Not now* asks nothing and stores nothing.
- **`reconcile` also runs each time the app comes forward**, beside the existing `manager.refresh()`.
  Today only the Settings screen notices that permission was revoked in iOS Settings; §5's "next
  reminder" line would otherwise show a time that can never fire.

## 5. Home

Canvas boards *Home* and *Home · just poured*.

### 5.1 What the user sees

Top to bottom:

1. **Header.** The date, the title *Today*, and on the trailing side the streak chip.
2. **The vessel**, as today, slightly larger. Its readout is the percentage and `1,300 of 2,000 ml`.
3. **Status.** `700 ml to go`, or *Goal reached*.
4. **One quiet line**, with whichever of these apply: *Next reminder 17:00* and *Last drink 14:25*.
   Straight after a pour from this screen it is replaced by `Added 250 ml` and an *Undo* button.
5. **The quick-add row.** Cup and Bottle as glass discs, the Glass between them as a larger primary
   disc. Under each, its amount and then its name.
6. The tab bar.

### 5.2 Behaviour

- **The screen can scroll.** It uses the app's existing idiom for type-heavy screens
  (`GeometryReader`, `ScrollView`, `minHeight`, bounce only when needed), and the vessel's diameter
  is also bounded by the height available. On the smallest supported phone (375 by 667 points) and at
  accessibility text sizes the content does not otherwise fit.
- **Sizes, as starting values settled by render:** the vessel's base diameter goes from 280 to 300
  points, still scaled with text size and capped at 340. The side discs are 68 points and the Glass
  88, both scaled, never under the 44-point floor, and the row keeps its sideways-scroll fallback for
  large text.
- **The Glass is ranked above the other two.** This reverses a comment in `HomeView` ("ranking one
  above the others would be a claim about the user's glass that this app cannot make"). The reason
  is that the app now does make that claim everywhere else: slot 1 is what the widget, Siri, the
  Control Center control and the watch all log.
- **The streak chip** shows a flame and a number. It is hidden at zero.
- **Next reminder** is shown only while reminders are on and a slot remains today. It is the planned
  time, not a delivery promise: iOS may batch it into a summary, which Settings already discloses.
  The line sits in a `TimelineView(.everyMinute)` so a slot that has passed stops being "next".
- **Last drink** is today's latest log, never shown later than now.
- **Undo** is offered only for a pour made from this screen. It lasts eight seconds, or until the
  next pour replaces it, or the tab changes. While VoiceOver is running it does not time out.
  Tapping it removes that one log; the total, the widget and the reminder plan follow as they do for
  any delete.
- The confetti, the goal haptic and the pour haptic are unchanged.

### 5.3 The model

All of this is derived. Nothing is stored.

| Addition to `DataManager` | What it is |
|---|---|
| `addLog(amount:at:)` returns `UUID?`, `@discardableResult` | The id of the row it inserted, or `nil` for a refused amount. Existing callers compile unchanged. |
| `undoLog(id:)` | Finds that row among today's and deletes it through `deleteLog(_:)`. Does nothing if the row is gone or today's rows cannot be read. Joins the public mutation surface in rule `20-state`. |
| `remaining: Int` | `max(0, dailyGoal - currentWater)` |
| `hasReachedGoal: Bool` | `currentWater >= dailyGoal`, the one spelling `HomeView` reads |
| `lastDrink: Date?` | The latest timestamp in `todaysLogs`, clamped to now |
| `nextReminder: Date?` | The first of `ReminderPlan.slots(…, horizonDays: 0)`, computed from the observable properties so a view that reads it redraws |
| `streak: Int`, get-only | See below |

**The streak** is the number of consecutive days on which the day's total reached the goal: counted
back from today if today has reached it, otherwise from yesterday.

- A pure `DaySummary.streak(of:goal:)` does the counting, beside `average(of:)` and `best(of:)`.
- `DataManager` publishes it from `republishHistory()` and from the `dailyGoal` setter, with an
  equality guard, behind `role.drawsHistory`.
- It reads a 30-day window and widens it (120, 480, 1,920 days) only while the run reaches the
  window's far edge. `historyWindowStart` gains a parameterised sibling and delegates to it, so there
  is still one definition of where a window starts.
- **A failed read leaves the published streak as it stands**, never zero (rule `20-state`).
- **Every day is judged against the current goal**, because no past goal is stored. Raising the goal
  can shorten a streak. The week card already says "Measured against your current goal".
- Days are bucketed from each log's instant on `Calendar.waterBuddyDay`, so a change of time zone can
  regroup them, as it already does for History.
- It never leaves the app: not in the snapshot, the widget, a notification or the watch's mirror.

**The day turning with the app open.** The two day-change observers call a new `dayDidTurn()`, which
runs `resetIfNeeded()` and, when it reports a new day, republishes today's rows and the history.
Without this the last-drink line, the streak and the week card would show yesterday until the next
refresh.

## 6. History

Canvas boards *History* and *Add a serving*.

### 6.1 What the user sees

1. **Header**: the shown day and its total against the goal, with the `+` button.
2. **The week card**: seven bars with the goal line. A day that reached the goal is cyan; one that did
   not is white; the shown day is ringed. Beneath: *Average*, *Best day* and *Goal met* (`6 of 7`),
   then "Measured against your current goal".
3. **When you drank**: one bar per serving of the shown day, placed by time of day and sized by
   amount. On today it also marks the next reminder.
4. **The servings**, newest first: a vessel glyph, the amount, the vessel's name, the time.

### 6.2 Behaviour

- **The whole screen scrolls as one list.** The header and the two cards become rows of the `List`
  the servings already use, with the list's own surfaces cleared. Today only the rows scroll, which
  leaves no room for them once a second card is added.
- **Servings stay one glass row each**, restyled lighter, with swipe-to-delete and tap-to-edit as
  now. The canvas drew one grouped card; see decision D2.
- **Goal met** is a pure `DaySummary.daysMet(in:goal:)`.
- **The strip spans the whole day**, midnight to midnight, not 06:00 to 24:00 as drawn: a drink at
  00:30 has to appear. Positions are fractions of that day's real length, so a 23- or 25-hour day
  draws correctly.
- **A row names its vessel only when its amount equals one of the current three**, checking the
  Glass first. Any other amount shows the drop glyph and no name. A log stores an amount and nothing
  else, so the name is an inference from today's vessels and is never spoken.
- Selecting a day, the empty states and their copy are unchanged.

### 6.3 The serving sheet

- **Three vessel shortcuts** under the slider set the amount to the Cup, the Glass or the Bottle. The
  one matching the current amount is selected.
- *Save* is the primary surface; *Cancel* is glass.
- **The sheet stays full height with its own aurora**, as today. The canvas drew a floating
  part-height sheet; at that height the wheel, the slider and the shortcuts do not fit at larger text
  sizes.

## 7. Settings

Canvas board *Settings*. A restyle, with three small corrections:

- The four card titles share one text style, and the footnotes share one. They differ today.
- The vessels note changes from "The middle vessel is the one your widget logs." to **"The Glass is
  the one your widget, Siri and Control Center log."** The same sentence is used in the welcome.
- The screen gains `.onAppear { manager.refresh() }`, which rule `50-views` records as missing.

The reminders switch calls `ReminderPermission.enable` (§4.3). Its three descriptions, the denied
state and *Open iOS Settings* are unchanged.

## 8. The Home Screen widget

Canvas boards *Widget · small* and *Widget · medium*.

- **The pour button becomes the primary surface in full colour**: a white disc in the small family, a
  white capsule in the medium one, with `Aurora.top` content.
- **Outside full colour it keeps today's fallback**: white content inside the lit rim. On a tinted
  Home Screen only alpha survives, and a white shape with dark content would come back as one blank
  disc.
- **The disc stays exactly 44 points with no outer ring.** `MiniVessel.radius(fitting:besides:gap:)`
  derives the vessel from that target and a 4-point gap, and on the smallest widget the gap is met
  exactly.
- The vessel, the card, the aurora, the frozen wave phase, the scrim ramp and both timeline entries
  are unchanged. The glass stays `.archived`.
- The medium family's figures take the grouped form (`1,300 ml`), through a `%1$@` key added to
  `sharedKeys`.
- The Lock Screen widget and the control are not touched. Two comments in `LockScreenWidget.swift`
  that describe `PourButton`'s size and fallback are checked and corrected if they go stale.
- Known issue #76 (the medium hero's size above its Dynamic Type cap) is not part of this.

## 9. The watch

Canvas board *Watch*. **This stage reverses two recorded rulings and cannot be gated on this Mac
today**; see decisions D5 and D6.

### 9.1 What the user sees

- The vessel, smaller, showing the percentage.
- **A row of three pour buttons**: Cup, Glass, Bottle. The Glass is the primary surface. Each shows
  its vessel's glyph; the amounts sit beneath.
- The sync caption, below the row.
- No *More* button and no sheet.

### 9.2 Behaviour

- **The vessel stops being a button.** Today a tap on it pours the Glass, and the amount it pours is
  shown nowhere. It becomes a display, one VoiceOver element with the label and value it has now.
- **Every button is at least 44 points** (rule `65-accessibility`). By arithmetic three 44-point
  targets fit across the narrowest watch with a few points between them; that is not yet rendered.
  The Glass widens to carry its amount inside when the row has room.
- **The row is built from `primary(from:)` plus `secondary(from:)`**, not from the raw servings, so a
  short or missing mirror still leaves a Glass that pours the default. The screen must never lose
  its only action.
- **The vessel is sized from the space left** after the row, with the existing 60-point floor. The
  pour row is the thing kept on screen at rest; on the smallest watches the amounts and the caption
  may need a turn of the crown.
- **The millilitre line leaves the vessel.** Inside a smaller vessel it would fall to about 6 points,
  and it already measures under 4.5:1 over water (known issue #44). Where it goes, and the scrim
  ramp's re-derivation that follows, are settled with renders in this stage's plan.
- Glass on the watch is Apple's (§3.2). There is still no `PressStyle` and no haptic on the watch;
  that stays out of scope.
- Removed: `WristServingMenu`, the *More* button, and the keys *More*, *Shows the other serving
  sizes* and *Logs %1$d millilitres*. The buttons' VoiceOver label is the phone's
  `%1$@, add %2$d millilitres`, added to the watch catalogue and to `watchSharedKeys`.

## 10. What this amends

`.claude/` changes only when the owner decides. The two permission rules are written out in full
because they need explicit approval; the rest are one line each, with exact wording in the stage that
makes the change.

**Rule `70-privacy`, *The lock screen is a public surface*.** Today:

> Ask for authorization only from the `set` branch of the reminders toggle, where the user has just
> asked for reminders. Never at launch, never from the setup screen, never from a `.task`

Proposed:

> Ask for authorization only in answer to the user's own tap asking for reminders: the `set` branch of
> the Settings toggle, or *Turn on reminders* on the welcome's last step. Never at launch, never when
> a screen or a step appears, never from a `.task`. Both taps run one implementation,
> `ReminderPermission.enable(on:using:)`

**Rule `80-notifications`, *Authorization*.** Today:

> Requested only from `SettingsView.enableReminders()`, at the moment the user flips the toggle on. A
> refusal leaves `manager.remindersEnabled` **false** — never store the intent and hope
>
> Re-read the status every time the settings screen comes forward and flip the toggle off when it
> reads `.denied`. Do not cache the status from launch

Proposed:

> Requested only through `ReminderPermission.enable(on:using:)`, and only from the two taps that ask
> for reminders: the Settings toggle turning on, and *Turn on reminders* in the welcome. A refusal
> leaves `manager.remindersEnabled` **false** — never store the intent and hope
>
> Re-read the status every time the app comes forward (`ReminderPermission.reconcile`) and whenever
> the settings screen appears, and clear `remindersEnabled` when it reads `.denied`. Do not cache the
> status from launch

**The rest, in summary:**

| Rule | Change |
|---|---|
| `60-design-system` | Glass: the three-way choice of §3.2; the scrim, the tint ceiling and the two shadows described as properties of the hand-made stack. A new *Primary surface* section. *Interaction*: `interactive` maps to `.interactive()` on Apple's glass. *In the widget*: the pour button's two forms. |
| `50-views` | Home scrolls; the Glass is ranked; `goalRange`/`goalStep` live on `WelcomeView`; the line saying Settings does not refresh is retired. |
| `20-state` | `undoLog(id:)` joins the mutation surface; `addLog` returns an id; `streak` joins the get-only consequences. |
| `30-rollover` | The day-change observers call `dayDidTurn()`. |
| `65-accessibility` | Home's header, chip and status elements; Undo's timing under VoiceOver; the watch vessel as an element again. |
| `40-widget` | `PourButton`'s primary surface in full colour and its unchanged fallback. |
| `15-project` | A second availability check, `#available(iOS 26.0, watchOS 26.0, *)`, in the shared glass file. |
| `85-testing` | The UI tests' welcome helper. |
| `CLAUDE.md` | The matching lines. |

## 11. Testing and verification

### 11.1 Tests, written first

Each is written and seen to fail before the code it covers (rule `85-testing`).

- **Glass**: the rendering table of §3.2, one case per row, in a suite that is not `@MainActor`. The
  existing `LiquidGlassInteractionTests` and `LiquidGlassBaseTests` keep pinning the fallback.
- **Model**, in `@MainActor` suites with the standard fixture (throwaway suite, in-memory container,
  injected clock, all seven `init` arguments):
  - `addLog` returns the id of the row it inserted, and `nil` for a refused amount.
  - `undoLog` removes exactly that row, re-plans reminders, and does nothing for an unknown id.
  - `remaining`, `hasReachedGoal`, `lastDrink` and `nextReminder`, each including its `nil` or zero
    case and its observation.
  - `streak`: today counts only once reached; a missed day ends it; a run longer than the first
    window is counted in full; a goal change re-judges it; a failed read leaves it as it stands.
  - The day turning republishes today's rows and the history.
- **Pure functions**, in suites that are not `@MainActor`: `DaySummary.streak` and `daysMet`
  (including 23- and 25-hour days), the strip's positions, the vessel-name inference, `WelcomeStep`'s
  order.
- **Permission**, against a spy `ReminderScheduler`, never a real centre: a grant stores `true`; a
  refusal stores `false`; `.denied` clears the flag; *Not now* asks nothing.
- **Welcome**: the commit order of §4.2, and that unchanged vessel amounts materialise no key.
- **Strings**: every new key has explicit `en`, `ru` and `uz` values, keeps its positional
  specifiers, and joins `sharedKeys` or `watchSharedKeys` where a second bundle draws it. The removed
  watch keys leave `watchOwnKeys` in the same change.
- **UI tests**: the *Get Started* preamble, copied inline eight times, becomes one helper that walks
  the four steps and chooses *Not now*, so no permission alert appears in a test run. New assertions:
  the three quick-add buttons still resolve to one element each, *Undo* appears after a pour and
  removes it, the welcome's steps go forward and back. Tests that find History by a static text
  *Today* are pointed at the *Add a serving* button, since Home now has a *Today* title too.
- **The two capture harnesses** in `AppStoreScreenshotUITests` are updated to walk the welcome and to
  shoot `04-goal-setup` on the goal step. Their other staleness is left as it is.

Every label and value the UI tests query today is kept: the vessel as one element with its spoken
value, `<Name>, add N millilitres` on the quick-add buttons, `N millilitres` on the serving rows, the
day buttons, *Last 7 days*, *Add a serving*, *Save*, *Cancel*, and the Settings controls.

### 11.2 The gate

The five invocations of rule `85-testing`, for every stage, with the warning baseline measured by a
clean build before the first edit.

- **The watch tests cannot run here**: no watchOS 26 runtime is installed (known issue #77). Stage 7
  waits for one.
- **The pinned phone destination, iOS 26.5's iPhone 17, needs an erase** that only the owner can run.
  Until then the gate can run on iOS 27.0, as it did on 2026-10-08. Which it is, is the owner's call.

### 11.3 On the simulator

A green suite cannot see a pane that renders wrong. For each stage:

- **Both glass paths are rendered**: Apple's on iOS 26.5 or 27.0, and the fallback on iOS 18.6, whose
  runtime is installed. iOS 17 itself remains unrun.
- **Every text-on-glass pair is measured off a screenshot** on both paths against 4.5:1 (3:1 for a
  glyph), and the figures go into `docs/DESIGN.md`. The mapping in §3.2 is settled by these figures,
  not by eye. The tab bar's caption, which measured 4.34:1 in cyan on today's pane, is the tight one.
- Reduce Transparency, Increase Contrast, Reduce Motion and the largest accessibility text size are
  each switched on and rendered.
- Home is rendered on the smallest and the largest phone.
- The widget is placed on a Home Screen in full colour, tinted and clear, and in StandBy.

### 11.4 The owner's device check

What a simulator cannot show: Apple's glass on real hardware in daylight, the permission prompt
inside the welcome on a fresh install, Undo by feel, the widget's tap, and the watch on a wrist.

## 12. Where the build differs from the canvas

| On the canvas | In the build | Why |
|---|---|---|
| Glass drawn with CSS | Apple's glass on iOS 26 and later; the hand-made glass below | The canvas can only approximate it |
| A lighter cyan | `Aurora.cyan` | No new token |
| A streak reading `12 days` | A flame and `12` | A counted noun needs plural forms in English and Russian, which the app's string path cannot yet produce (known issue #40) |
| `5 servings` on the strip's card | No count | The same |
| The strip from 06 to 24 | The whole day | A drink before 06:00 must appear |
| Servings as one grouped card | One glass row per serving | Decision D2 |
| A floating part-height sheet | Full height, as today | It does not fit at larger text sizes |
| Custom-drawn sliders and switch | The system's | They follow the OS |
| A 46-point widget button with a ring | 44 points, no ring | The vessel's clearance is derived from 44 |
| One watch layout | Sizes derived per watch | Five screen sizes |
| Times as `17:00` | The phone's own 12- or 24-hour setting | As every timestamp in the app |

## 13. Decisions for the owner

| | Decision | Recommendation |
|---|---|---|
| D1 | The rule wording in §10 for asking permission from the welcome | Approve as written |
| D2 | History's servings: one glass row each with swipe-to-delete, or the canvas's single grouped card, which costs the swipe and puts *Delete* in the sheet | One row each |
| D3 | The streak without its noun, and the strip without its count, until known issue #40 is fixed as its own change | Accept |
| D4 | On Home the Glass is ranked above Cup and Bottle, reversing the earlier ruling that the three are peers | Confirm, as drawn |
| D5 | On the watch: the vessel shrinks and stops being a button, reversing "25% bigger, twice" and the tap-to-pour vessel | Confirm, as drawn |
| D6 | The watch stage needs a watchOS 26 simulator runtime installed before it can be tested | Install it when stage 7 is next |
| D7 | Delivery in the seven stages of §14, each with its own plan, gate and `/commit` | Approve |

**All seven were decided as recommended by the owner on 2026-10-09** ("ok, approve all"). D1's rule
wording in §10 is therefore approved; it is applied in stage 5, the stage that needs it.

## 14. Delivery

This is too large for one plan. It is seven stages; each leaves the app shippable, and each gets its
own plan, tests first, the full gate, a docs pass and the owner's `/commit`.

| Stage | What | Depends on |
|---|---|---|
| 1. Foundation | The glass routing on the phone, the primary surface (on *Get Started* and *Save*), the selection tokens and the tab bar's lozenge, the stale comments | — |
| 2. Home | Header, status, the quiet line, Undo, the streak, the quick-add row and its glass container, the grouped-figure helper, the day-turn fix | 1 |
| 3. History | The one-list layout, the week card, the strip, the rows, the sheet's shortcuts | 1, and 2 for the streak's helpers |
| 4. Settings | The restyle, the note, the refresh | 1 |
| 5. Welcome | `WelcomeView`, `ReminderPermission`, the two rule amendments, the UI-test helper | 1, 4 |
| 6. Widget | The pour button, grouped figures | 1 |
| 7. Watch | The row, the vessel, the removals, Apple's glass on the watch | 1, and a watchOS 26 runtime |

Stages 1 to 5 are the phone app and could ship as one version, with the widget and the watch
following. The first plan to write is stage 1.

**Moved while planning stage 1 (2026-10-09):** the grouped-figure helper and the glass container go
to stage 2, where each has its first caller; Apple's glass on the watch goes to stage 7, where it
can be rendered.

## 15. Not in scope

- StoreKit, Premium and Apple Health.
- Plural forms (known issue #40), and with them the streak's noun.
- Themes, a light appearance, custom fonts.
- Haptics or a press response on the watch.
- The Lock Screen widget, the Control Center control, the watch complication.
- Known issues #62 (a UI test that fails on an unerased simulator) and #76 (the medium widget's hero
  size).
- A new App Store screenshot set. The shipped ones will show the old look until they are retaken.
