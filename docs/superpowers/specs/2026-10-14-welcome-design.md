# The welcome — stage 5

**Date:** 2026-10-14
**Status:** design, written by the session that will build it, from a canvas and three sections the
owner approved in chat on 2026-10-14 ("ok" to each). Their rulings are marked *(owner)*; everything
else is this session's reading and is theirs to overturn (§12). Nothing is built.
**Builds on:** `2026-10-09-premium-redesign-design.md` §4 (the welcome) and §10 (the permission
wording, approved there as D1). Where this document and that section differ, this one is the later
word and says so (§2).
**Roadmap:** item 1.2.3 of `docs/ROADMAP.md` — stage 5, the welcome, with the goal calculator.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md`. Where it proposes a rule change (§11), the rule stands as written until the owner
approves the wording.

**Provenance.** Every claim about the repository was read at HEAD `1438122` on 2026-10-14. The
canvas is <https://claude.ai/artifact/ACaiHVsHL7pXhKuFdGGb65> ("WaterBuddy welcome", five boards);
every canvas value below was read from the boards' own source (`project/*.dc.html`), not from a
render. A claim nobody has rendered is marked **unrendered**.

---

## 1. What is being built

The first-run screen becomes four steps — Hello, Daily goal, Vessels, Reminders — and the goal
step gains an optional calculator that suggests a goal from a weight and an activity level. It
replaces `GoalSetupView`, the one-screen setup every install has shown since 1.0.

**The owner's rulings, 2026-10-14:**

1. The four approved welcome boards of 2026-10-09 are lost — that canvas reads "not found" and no
   saved copy holds them — so the welcome is **redrawn as a canvas and approved before code**.
2. The calculator is **optional, inside the goal step**: a *Work it out for me* row under the goal
   card. A user who never opens it stores 2,000 ml, as today.
3. The formula is **30 ml per kg of body weight, plus 0 / 350 / 700 ml for Light / Moderate /
   Active**, rounded to the slider's 100 ml step and kept within its 1,000–4,000.
4. Weight starts in **the device region's unit** — pounds where the region measures in them —
   with a **kg | lb switch** beside it. The unit follows the region, not the app's language.
5. Weight is entered on **a wheel**.
6. Settings' three vessel rows are **extracted into one shared view**, used by Settings and the
   welcome.
7. The welcome's UI tests reach it through **a DEBUG-only fresh start** (§9).
8. The canvas ("ok"), and §§5–7 and §10 of this document as presented in chat ("ok" to each).

**What does not change:** the stored shape (no new key, no change to `WaterLog`), `DataManager`'s
API, the root gate (`manager.isGoalSet`), the widget, the watch, every notification and Siri string,
and the reminder schedule. Existing users never see the welcome.

## 2. What happens today, and what this changes in the 2026-10-09 spec

- **`GoalSetupView`** (`WaterBuddy/GoalSetupView.swift`) is one screen: the greeting, the question,
  a hero figure with a 1,000–4,000 slider, *Get Started*. *Get Started* calls `saveDailyGoal(ml:)`,
  which flips `isGoalSet`; `RootView` in `WaterBuddyApp.swift` cross-fades to `RootTabView`.
- **`goalRange` and `goalStep`** are `static let`s on `GoalSetupView`, read by Settings' `GoalCard`
  and by `DailyGoalSetupTests` (`WaterBuddyTests/DataManagerTests.swift`). They are not
  `nonisolated` — rule `43-concurrency` lists them as latent warnings.
- **Permission is asked in one place**, `SettingsView.enableReminders()`, and re-read only by
  `SettingsView.readSystemState()`. So a permission revoked in iOS Settings is noticed only when
  Settings is shown, and Home's *Next reminder* goes on showing a time that cannot fire (known
  issue #100(d)).
- **The UI tests start with an eleven-times-copied preamble** that taps *Get Started* if it exists
  (`WaterBuddyUITests/GoalSetupUITests.swift`). The 2026-10-09 spec counted eight.
- **Every gate simulator finished setup long ago**, so no automated run has shown the first-run
  screen since those devices were made.

**Against the 2026-10-09 spec's §4:** §4.1's table stands, with the calculator added to the goal
step and a reminder preview added to the last (§3). §4.2 and §4.3 stand as written, made concrete
in §§5–6. §11.1's "copied inline eight times" is eleven.

## 3. The look

The canvas's five boards, 390 × 844 pt, on the aurora every screen stands on, glass through
`.liquidGlass(…)`, the main action through `.primarySurface(in:)`. Figures below are the canvas's;
**they are starting values**, and every text-on-glass pair is measured off a render against its floor
before it is kept (the floors hold, as ruled for stage 3c).

**On every step after the first** — a title in the tabs' place (34 pt bold, `ScreenMetrics.margin`
and `ScreenMetrics.topInset`), a one-line subtitle under it (17 pt, white 0.92), and **a pinned bar**
at the foot: four dots (8 pt; the current one 22 pt wide; white, others white 0.35), then *Back* (a
glass capsule, 112 pt wide) and the step's primary action (a primary capsule filling the rest), both
56 pt tall. The step's content scrolls above the bar.

| Step | Canvas board | What it draws |
|---|---|---|
| Hello | *Welcome 1 · Hello* | A half-full vessel, 232 pt, its waves moving; *Welcome to* (22 pt semibold, 0.92) over *WaterBuddy* (42 pt heavy); "One tap logs a glass. Watch your day fill up." (17 pt, 0.92); the dots; *Get Started* (primary) — no *Back* |
| Daily goal | *Welcome 2 · Daily goal* | Title *Daily goal*; the existing question as its subtitle; a frosted card with the figure (60 pt rounded bold; *ml* 22 pt, 0.9) over the slider and its *1,000* / *4,000* (13 pt semibold, 0.88); "You can change this later in Settings." (13 pt, 0.88); a frosted *Work it out for me* row, 56 pt, a sparkle glyph in `Aurora.cyan` and a chevron |
| Daily goal, open | *Welcome 2 · Work it out for me (scrolled)* | The row opens into the calculator (§4): *Your weight* over the wheel and the kg \| lb switch on the left; *How active are you?* over three choices on the right; *Use 2,500 ml* (a glass capsule); "A starting point, not medical advice." (13 pt, 0.88) |
| Vessels | *Welcome 3 · Vessels* | Title *Quick-add vessels*; "Home pours these in one tap. Set each to what yours holds."; one frosted card holding the three vessel rows Settings draws, a hairline and the Glass note; "You can change these later in Settings." |
| Reminders | *Welcome 4 · Reminders* | Title *Reminders*; "A gentle nudge when it has been a while."; a glass pane shaped like a notification carrying the real reminder's two strings (*Time for water*, "A glass now keeps you on track for the day.") beside a tile of `Aurora` with a drop; a frosted card titled *Smart reminders* with seven bell discs on a line and their times, then the existing schedule sentence; *Back* and *Turn on reminders* (primary), and *Not now* as plain text under them (44 pt) |

- **The Hello vessel is drawn from `WaterSurface`'s waves inside a sheer glass circle** — the parts
  Home's vessel is built from — and not from Home's `WaterVessel`, which brings a readout, a scrim, a
  slosh tied to pours and an accessibility element that a decoration needs none of. It is
  decorative and hidden from accessibility.
- **The bells are one row of glass discs in a `.glassGroup()`**; the times are formatted from
  `ReminderPlan.hours` in the phone's own 12- or 24-hour setting (the canvas draws 12-hour).
- **Every rounded pane takes `LiquidGlass.cornerRadius`**; the notification tile, the wheel's well
  and the choices take `LiquidGlass.innerCornerRadius`. No radius literal.
- **The selected activity and unit are marked with `LiquidGlass.Selection`'s fill and rim**
  (rule `60-design-system`).

## 4. The calculator

**The suggestion** is a pure function, `GoalSuggestion.goal(weight:unit:activity:)`:

```
millilitres = weight in kilograms × 30 + activity      activity: Light 0, Moderate 350, Active 700
goal        = millilitres rounded half-up to WelcomeView.goalStep (100),
              then clamped to WelcomeView.goalRange (1,000…4,000)
```

- **Integers only.** A pound is 0.45359237 kg exactly, so a weight in pounds contributes
  `(pounds × 30 × 45_359_237 + 50_000_000) / 100_000_000` ml — 13.6077711 ml a pound, rounded to the
  whole millilitre — computed in `Int`. No `Double` touches a volume (`CLAUDE.md`, *No
  floating-point millilitres*). Half-up rounding of a positive total is `(total + 50) / 100 × 100`.
- **The approved figures** *(owner)*:

  | | Light | Moderate | Active |
  |---|---|---|---|
  | 50 kg | 1,500 | 1,900 | 2,200 |
  | 60 kg | 1,800 | 2,200 | 2,500 |
  | 70 kg | 2,100 | 2,500 | 2,800 |
  | 85 kg | 2,600 | 2,900 | 3,300 |
  | 100 kg | 3,000 | 3,400 | 3,700 |

- **Units.** `GoalSuggestion.Unit` is `.kilograms` (30…200, starting at 70) or `.pounds` (66…440,
  starting at 155). The starting unit is `.pounds` when `Locale.current.measurementSystem` is `.us`
  and `.kilograms` otherwise — the device's region, deliberately not `manager.language.locale`:
  choosing English in the app must not make an Uzbek user weigh in pounds *(owner)*. The switch
  converts the weight shown, rounded to the nearest whole unit and kept in the new unit's range
  (70 kg → 154 lb → 70 kg). Neither the unit nor the weight is stored.
- **Activity.** `GoalSuggestion.Activity` is `.light` (*Mostly sitting*), `.moderate` (*Exercise some
  days*) and `.active` (*Exercise most days*). It starts at `.moderate`.
- **Nothing above moves until *Use* is tapped.** Turning the wheel, switching the unit and picking
  an activity change only the figure on the *Use* button. *Use* sets the goal step's figure and
  slider to the suggestion — the figure counts to it, the slider glides — and plays `confirm`. While
  the goal equals the suggestion, the button reads *✓ Your goal is 2,500 ml* and does nothing; it
  returns as soon as the suggestion changes. The slider stays free to adjust after.
- **Opening the row scrolls the panel into view**; closing it leaves the goal as it stands.
- **"A starting point, not medical advice."** under the panel. The suggestion is an estimate for a
  hydration app's daily target, not guidance about anyone's health.

## 5. The parts

All app-only. Each target's synchronized folder gives membership, so no `project.pbxproj` edit
and no exception set changes; nothing here is compiled into the widget or the watch.

| File | What it holds |
|---|---|
| `WaterBuddy/WelcomeView.swift` *(new)* | `WelcomeView`; a file-scope `nonisolated enum WelcomeStep` (`hello`, `goal`, `vessels`, `reminders`), the way `AppTab` sits beside `RootTabView`; the calculator panel and the Hello vessel as private views; `nonisolated static let goalRange = 1_000...4_000` and `goalStep = 100`, moved from `GoalSetupView`; `static func finish(goal:amounts:asksForReminders:on:using:) async` |
| `WaterBuddy/GoalSuggestion.swift` *(new)* | `nonisolated enum GoalSuggestion` with nested `Unit` and `Activity`, the arithmetic of §4. `Foundation` alone |
| `WaterBuddy/ReminderPermission.swift` *(new)* | `@MainActor enum ReminderPermission`: `enable(on:using:) async` and `reconcile(_:using:) async -> UNAuthorizationStatus` (spec 2026-10-09 §4.3) |
| `WaterBuddy/VesselSliders.swift` *(new)* | The three vessel rows — glyph, name, amount, slider, the step tick, the held figure's swell — lifted out of `SettingsView`'s `ServingsCard` and bound to a `Binding<[Int]>`, reporting a drag's start and end. Its second user is what earns it a file (rule `50-views`) |
| `WaterBuddy/GoalSetupView.swift` | **Deleted** |
| `WaterBuddy/WaterBuddyApp.swift` | `RootView` shows `WelcomeView`; the foreground also runs `ReminderPermission.reconcile`; the DEBUG fresh start (§9) |
| `WaterBuddy/SettingsView.swift` | `enableReminders()` and `readSystemState()` go through `ReminderPermission`; `ServingsCard` draws `VesselSliders` and keeps its title, note, save-on-release, re-read and saved tick; `GoalCard` reads `WelcomeView.goalRange` |
| `WaterBuddy/Localizable.xcstrings` | The new keys (§8) |
| Comments naming `GoalSetupView` | Repointed: `AuroraBackground.swift`, `DataManager.swift`, `HistoryView.swift`, `HomeView.swift`, the tests |

**Where state lives.** The step, the goal, the three amounts, the calculator's weight, unit,
activity and open state are `@State` on `WelcomeView` — presentation state until the last step
(rule `50-views`). **The weight is written nowhere**, and is gone when the welcome is replaced.

**Finishing** is one function, so its order can be tested without a screen:

```swift
@MainActor
static func finish(goal: Int, amounts: [Int], asksForReminders: Bool,
                   on manager: DataManager, using scheduler: ReminderScheduler) async {
    manager.servings = amounts                    // unchanged amounts write nothing
    if asksForReminders {
        await ReminderPermission.enable(on: manager, using: scheduler)
    }
    manager.saveDailyGoal(ml: goal)               // flips isGoalSet: the root moves on
}
```

`saveDailyGoal` is last because it is what dismisses the welcome (spec 2026-10-09 §4.2).
`ReminderScheduler.live()` is built inside the `Task` that calls it, never stored (rule
`80-notifications`).

## 6. Behaviour

- **Steps slide by direction**: *Continue* brings the next step in from the trailing edge, *Back*
  from the leading edge, both steps moving, on `Motion.page`; under Reduce Motion they cross-fade
  on `Motion.pageFade` and nothing travels (rule `65-accessibility`). Each step's cards rise in as
  they arrive (`Arrival`, the stagger Settings uses).
- **The Hello vessel's waves travel** in a `TimelineView(.animation)`, and stand at their resting
  frame under Reduce Motion — a perpetual animation resolves to `nil`, never to a gentler curve.
- **Haptics**, each from a counter the user's own action bumps (rule `60-design-system`): `select` on
  a step change, a goal-slider step, a vessel-slider step (inside `VesselSliders`, as today), an
  activity or unit pick; `confirm` on *Use* and on finishing. The wheel plays the system's own tick.
- ***Not now*** finishes at once without asking anything: `remindersEnabled` stays as it is
  (`false` on a fresh install).
- ***Turn on reminders*** finishes through `ReminderPermission.enable`: iOS's prompt appears over
  the welcome, and when it is answered the goal is saved and the root moves on. **Both finishing
  buttons are disabled from the first tap** until `finish` returns, so a second tap cannot finish
  twice. A refusal stores `false` and the app still opens on Home.
- **`ReminderPermission.enable`** asks only when the status is `.notDetermined` and stores the
  grant (`false` on a refusal or a thrown error); for any other status it stores "not denied",
  asking nothing — Settings' behaviour today, moved.
- **`ReminderPermission.reconcile`** reads the status, clears `remindersEnabled` when it reads
  `.denied`, never asks, and returns the status so Settings can draw its denied state. It runs as
  Settings appears and returns to the foreground (as `readSystemState()` does today) **and every
  time the app comes to the foreground**, beside `manager.refresh()` — which closes #100(d).
  Settings keeps reading the notification summary setting itself; that is not a permission.
- **The title stands one point clear of the status bar** — History's remedy for #108 — with the
  inset that compensates for it, so it stands where the tabs' titles do and a scrolled step never
  runs under the clock (#89).
- **The welcome is a root screen**: it declares `.preferredColorScheme(.dark)` and stands its own
  `AuroraBackground()`, as `GoalSetupView` did, and `RootView`'s cross-fade to the tabs is unchanged.

## 7. Accessibility and large text

- Each step's title is a header and takes VoiceOver focus when the step changes. The dots are one
  element, *Step 2 of 4*.
- The goal figure and its slider keep `GoalSetupView`'s elements: the figure one element (*Daily
  goal*, *N millilitres*), the slider labelled *Daily water goal* with a millilitre value, the range
  labels hidden.
- The calculator row is one button, *Work it out for me*. The wheel is labelled *Your weight*. Each
  activity is one button whose label is its name and its line together — *Moderate, Exercise some
  days* — with `.isSelected` on the chosen one; the unit switch is two buttons, the same way.
- *Use* draws *Use 2,500 ml* (`%1$@`, grouped) and speaks *Use 2500 millilitres* (`%1$d`) — a
  spoken figure keeps its `%d` key (rule `50-views`).
- The vessel, the notification tile's art and the bells' glyphs are hidden; the strip is one element
  speaking its seven times as a sentence; the preview pane is one element.
- **At the accessibility sizes** the wheel and the activity choices stack, the bar's two buttons
  stack (`ViewThatFits`, never a control under 44 pt), every tap target keeps a `minHeight` of at
  least 44, the hero figures are capped and scale down, and each step scrolls above the pinned bar
  (rule `65-accessibility`). On the 375 × 667 pt phone at the largest size the bar takes more of the
  screen than anywhere else in the app — **unrendered**, measured in the plan.

## 8. Strings

About twenty keys, in `WaterBuddy/Localizable.xcstrings` only, each with explicit `en`, `ru` and
`uz` values and positional specifiers. The welcome draws nothing in the widget's or the watch's
catalogue, so `sharedKeys` gains nothing. The preview reuses the two reminder keys the app's
catalogue already holds. *Welcome to*, *Get Started*, the question and "You can change this later
in Settings." are kept.

New: the Hello line; *Work it out for me*; *Your weight*; *kg*, *lb*, `%1$d kg`, `%1$d lb`; *How
active are you?*; the three names and their three lines; `Use %1$@ ml` (drawn) and `Use %1$d
millilitres` (spoken); `Your goal is %1$@ ml`; "A starting point, not medical advice."; *Continue*;
*Back*; the vessels subtitle and its "these" footnote; *Reminders* and its subtitle; *Turn on
reminders*; *Not now*; `Step %1$d of %2$d`.

**The Russian and Uzbek values are this session's and have not been read by a native speaker**,
as #100(c) records for stage 2's.

## 9. The DEBUG fresh start

**Why** *(owner)*: the welcome is the first thing every new user sees, and no gate simulator has
shown it since the devices were made. A UI test of it needs a fresh install every run.

- `WaterBuddyApp.init()`, inside `#if DEBUG`, reads one launch argument, `-WaterBuddyFreshStart`.
  When present it builds the app's manager on a throwaway suite with a fixed name
  (`uitest.waterbuddy.freshstart`), its persistent domain removed first, and an in-memory
  `ModelContainer`, passing `reloadWidgets: {}`, `rescheduleReminders: { _ in }` and
  `publishWrist: { _ in }` — the fixture discipline rule `85-testing` sets — and skips activating
  the watch link. **The real App Group suite and store are never touched by it.**
- Without the argument, a Debug build runs exactly what it runs today; a Release build does not
  contain the branch.
- `prepareSharedStorage()` still runs, as on every launch: it is the app's own idempotent
  bookkeeping on the real group, not test data.
- Only `WelcomeUITests` passes the argument. Every other UI test keeps running against the
  device's own state, as now.

## 10. Testing and verification

**Tests first**, each run and seen RED before its code (rule `85-testing`):

- **`GoalSuggestionTests`** (not `@MainActor`): the fifteen approved cells; 155 lb Moderate is
  2,500; the clamps (30 kg Light is 1,000; 200 kg Active is 4,000); half-up exactly at a half (85 kg
  Light, 2,550 → 2,600); the starting unit for `.us`, `.metric` and `.uk`; kg → lb → kg returns the
  weight across the whole range; each unit's start is inside its range; and for **every** weight of
  both units at every level, the goal is inside `goalRange`, on a `goalStep`, and never falls as
  the weight or the activity rises.
- **`WelcomeStepTests`** (not `@MainActor`): four steps in order; the first has no previous, the last
  no next.
- **`ReminderPermissionTests`** (`@MainActor`, a spy `ReminderScheduler`, never a real centre): a
  grant stores `true`; a refusal and a thrown error store `false`; `.authorized` stores `true` without
  asking; `.denied` stores `false` without asking; `reconcile` clears the flag on `.denied`, leaves it
  otherwise, never asks, and returns the status.
- **`WelcomeFinishTests`** (`@MainActor`, the standard fixture): unchanged amounts write no
  `Key.servings`, edited ones are stored; the goal is saved and `isGoalSet` flips; with reminders
  asked, the spy's request sees `isGoalSet` still `false` — the order, proved — and its answer lands
  in `remindersEnabled`; without, the spy is never called.
- **Moved, not changed:** `DailyGoalSetupTests` reads `WelcomeView.goalRange` and `goalStep`.
- **UI:** the eleven preambles become one helper, `completeWelcomeIfShown(_:)`, which walks
  *Get Started* → *Continue* → *Continue* → *Not now*. A new `WelcomeUITests`, launched with the fresh
  start: forward and back through every step; *Use* moves the figure; *Not now* lands on Home;
  each control resolves to exactly one element; at the largest accessibility size *Continue* and
  *Not now* are reachable. Settings' existing tests stand after the extraction.
- **The capture harness** (`AppStoreScreenshotUITests`) walks the welcome and shoots
  `04-goal-setup` on the goal step. Not run: it needs an erased device, which only the owner can
  make (#82).

**The gate:** rule `85-testing`'s five invocations, plus the UI run on iOS 26.5; the warnings
compared per file and message against a clean baseline measured before the first edit.

**On the simulator**, because a green suite cannot see a step that renders wrong: every step on iOS
27.0 and 26.5 (Apple's glass) and 18.6 (the hand-made glass), on the 375-pt phone, at the largest
accessibility size, under Reduce Motion, Reduce Transparency and Increase Contrast. Every
text-on-glass pair measured off the captures, each sampling box drawn on an annotated capture and
looked at before its figure is kept, into a *Welcome, measured* section of `docs/DESIGN.md`. The step
slide recorded, its travel stated in points and seconds. Settings re-rendered after the extraction
and its *Settings, measured* pairs re-read. The permission prompt itself is a device check: on the
simulator its answer is whatever this device last gave.

## 11. Rule wording, for approval

Typed into the rule files unstaged, for the owner's yes before `/commit`.

**`70-privacy`, *The lock screen is a public surface*** — approved on 2026-10-09 (D1), applied now.
Replaces "Ask for authorization only from the `set` branch of the reminders toggle, where the user
has just asked for reminders. Never at launch, never from the setup screen, never from a `.task`":

> Ask for authorization only in answer to the user's own tap asking for reminders: the `set` branch of
> the Settings toggle, or *Turn on reminders* on the welcome's last step. Never at launch, never when
> a screen or a step appears, never from a `.task`. Both taps run one implementation,
> `ReminderPermission.enable(on:using:)`

**`70-privacy`, *The user's data is theirs*** — new:

> The welcome's goal calculator takes a weight and an activity level and keeps neither: they live in
> `WelcomeView`'s state and are gone when it closes — never written to either store, never sent to
> the watch, never in a diagnostic. Only the goal the user then chooses is stored. Reading a weight
> from Apple Health is not this feature (`docs/ROADMAP.md` 1.3.3)

**`80-notifications`, *Authorization*** — approved on 2026-10-09 (D1), applied now. Replaces both
bullets:

> Requested only through `ReminderPermission.enable(on:using:)`, and only from the two taps that ask
> for reminders: the Settings toggle turning on, and *Turn on reminders* in the welcome. A refusal
> leaves `manager.remindersEnabled` **false** — never store the intent and hope
>
> Re-read the status every time the app comes forward (`ReminderPermission.reconcile`) and whenever
> the settings screen appears, and clear `remindersEnabled` when it reads `.denied`. Do not cache the
> status from launch

**`50-views`:** `GoalSetupView.goalRange`/`goalStep` → `WelcomeView.goalRange`/`goalStep` in
*Composition* (twice); and in *Previews*, `GoalSetupView` leaves the list of previews that omit
`rescheduleReminders` (its successor's passes it).

**`43-concurrency`:** in *`View` is `@MainActor`*, `GoalSetupView.goalRange` / `.goalStep` leave the
list of latent warnings — `WelcomeView`'s carry `nonisolated`, because `GoalSuggestion` reads them.

**`10-architecture`:** the diagram's `GoalSetupView` → `WelcomeView`.

**`85-testing`**, in *A fixture may never reach real data* — new:

> The welcome's UI tests launch with `-WaterBuddyFreshStart`, which only a DEBUG build reads, in
> `WaterBuddyApp.init()`: the manager is built on a throwaway suite, cleared at launch, and an
> in-memory store, with no widget, reminder or watch side effects. No other test passes it. Every
> other UI test walks the welcome through `completeWelcomeIfShown(_:)` and chooses *Not now*, so no
> permission prompt appears in a run

`CLAUDE.md` names no `GoalSetupView`; its *Architecture* section is unchanged.

## 12. Decisions taken for the owner

Not ruled by the owner; each is this session's, shown on the canvas or in chat, and theirs to
overturn.

| | Decision | Why |
|---|---|---|
| W1 | *Use* is an explicit button; the wheel and the choices alone move nothing | Nobody's goal changes until they ask; a wheel turned past their weight would otherwise drag the figure with it |
| W2 | The calculator starts at 70 kg / 155 lb and *Moderate* | Round figures; 70 kg Moderate suggests 2,500, beside today's 2,000 default |
| W3 | The activities' lines: *Mostly sitting*, *Exercise some days*, *Exercise most days* | Short enough for the narrow column; they say what each level means |
| W4 | The one-line "A starting point, not medical advice." | A suggested intake is an estimate; saying so costs one line |
| W5 | A pinned bar, the step scrolling above it | *Continue* is always where the thumb is, whatever the step's height |
| W6 | A notification preview on the reminders step, using the real reminder's strings | Shows exactly what the user is agreeing to before iOS asks |
| W7 | A subtitle under each step's title, and the "change these later" line on Vessels | Each step says what it is for; the goal step already had its line |
| W8 | *WaterBuddy* larger than *Welcome to* on Hello | The name is the point of the line; today both are one size |
| W9 | The Hello vessel from `WaterSurface`, not Home's `WaterVessel` | §3 |
| W10 | Both finishing buttons disabled from the first tap until `finish` returns | One finish, whatever the prompt does |
| W11 | The fresh start's suite has a fixed name, cleared at launch | One file at most in the app's own preferences, never an accumulating set |

## 13. Not in scope

- Apple Health, and storing a weight anywhere (roadmap 1.3.3).
- A part-height sheet for the calculator.
- The welcome on the watch or in the widget.
- Plural forms (#40).
- Re-running the capture harness (#82) and retaking the store's screenshots (roadmap 1.2.8).
- Settings' own layout, beyond the rows it now draws through `VesselSliders`.
