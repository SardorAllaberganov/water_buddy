# Navigation and motion — design

**Status:** written on 2026-10-11 under the owner's "go" of that evening, which was given to a list
of marked differences and not to this document. Nothing here has been read by the owner. §10 lists
every decision this document takes for them, each theirs to overturn. **Built on 2026-10-11 and 12
and unstaged; §12 says where the build left this document**, and §§4, 5, 8 and 10 are brought up
to date with it.

**Superseded in part on 2026-10-12** (added by the fifty-fourth pass of `docs/AI_CONTEXT.md`; the
text below is kept as written). The owner ran this build on a phone and asked for a page change
that can be seen; the second pass, built the same day on top of this one, is
`docs/superpowers/specs/2026-10-12-page-slide-and-touches-design.md`, and its §8 names what it
replaces. What below is no longer what the tree does: **§4's container** — there is no `TabView`,
`RootTabView` is one pager under Apple's bar standing alone, and no screen is kept; **§5** — a
page a change of tab brings in slides in with its sections whole and its title with it, only
the page the app opens on settles in section by section, and History's bars still grow on
every page unless Reduce Motion is on; **N12** — *Undo*'s capsule lands on a spring; and **§8's
wording for rule `50-views`**. The header (§3), the shade under Apple's bar (N8), the haptics
(§7), the backdrop's one clock (N13) and `Arrival` itself stand.

**What it is.** An addition to the premium redesign
(`docs/superpowers/specs/2026-10-09-premium-redesign-design.md`), delivered as **stage 3b**, between
History (stage 3) and Settings (stage 4). It supersedes that document's §3.4 on iOS 26 and later and
one line of its §5.1; §8 below says exactly what.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md`. Where it proposes a rule change (§8), the rule stands as written until the owner
approves the wording.

**Provenance.** Every claim about the repository was read from the index on 2026-10-11 (HEAD
`e16221e`, stage 3 staged). Every measurement was taken that evening from a scratch export of the
index on the iOS 27.0 and 26.5 simulators, and is recorded with its method in
`.superpowers/sdd/2026-10-11-navigation-and-motion/progress.md`. **SDK** is `iPhoneSimulator27.0.sdk`
in Xcode 27.0. A claim nobody has rendered is marked **unrendered**.

## 1. What is being built

The owner, 2026-10-11, shown the proposal for stage 4:

> the position of the application's Today word in different position when changing the screen
> between home and history, the page change animation or micro-interactions are so poor, it should
> be look like premium. the bottom menu should be new ios bottom liquid glass effect styled design
> with all drag interactions and look. it should be more premium look and some interactions and
> haptics appears in actions.

Their rulings since, each by a question with written options:

1. **The bar is Apple's own** on iOS 26 and later. The option said it reverses rule `50-views` and
   the redesign's §3.4, and that the page change is then Apple's and not ours to design.
2. Asked whether the still look is right, they asked to see it side by side, then to have the
   differences marked, then said **"go"** to seven marked differences, **a** to **g**.

This stage is the first half of that: **where the title stands, how the tabs change, and what a
touch feels like.** The look itself — the glass (**a**), the vessel (**b**), the week card (**c**),
a serving's glyph (**g**) — is stage 3c, with its own document. **f**, the tab bar, is here.

## 2. What happens today

Measured on iOS 27.0, iPhone 17, 402 × 874 pt, at the ordinary text size.

- **The title's frame** is `(24.0, 90.0)` on Home and `(28.0, 88.67)` on History: 4 pt across and
  1.3 pt down. Home's column starts 8 pt from the top with a 24 pt margin and draws the date above
  the title; History's header row starts 24 pt down with a 28 pt margin and draws the total below.
  Settings' title is `.title2` at `(28.0, 86.0)`.
- **The page changes by a cross-fade** of about eight frames at 30 fps. Both titles are on screen
  at once, 4 pt apart. `RootTabView` switches a `ZStack` on `@State tab`, so each screen is rebuilt
  on every change — which is also what ends Home's *Undo* offer and returns History to today.
- **The bar is three buttons on the app's own glass.** A press that drags along it does nothing.
  Its captions are not on one line: *Home* at y 813.67, *History* at 811.33, *Settings* at 814.0,
  because each caption hangs under a glyph of its own height.
- **The approved canvas has the larger fault.** By their CSS the title's top is at 82 px on the
  *Home* board and 62 px on *History*. They were approved as still boards.
- **Three haptics exist**: `confirm`, `pour`, `goalReached`. Changing tab, picking a day, a slider's
  step and a delete have none.
- **Apple's bar, rendered from a scratch build**, changes the page in one frame — a cut — and moves
  only its own lozenge. A press dragged along it carries the lens across the tabs and changes the
  page on release. The page's content shows through it.

## 3. One header

Every tab opens with the same header, in the same place.

- **`ScreenHeader`**, a view in its own file, app-only: a title, an optional line under it, and an
  optional accessory on the title's line. Home passes *Today*, the date and the streak chip; History
  the shown day, its total and the `+`; Settings its title alone.
- **The title comes first on every screen.** Home's date moves from above the title to under it.
  This is the one way both screens can show *Today* in one place without History carrying an empty
  line; it differs from the approved *Home* board (§10, N2).
- **One set of numbers**, in `ScreenMetrics` beside the header: `margin`, 24 pt, and `topInset`,
  16 pt, both `nonisolated static`. `HomeView.columnPadding`, `HistoryView.margin` and Settings'
  padding read them. History's week card budgets its seven day buttons against the margin:
  `(375 − 2 × 24) / 7 = 46.7` pt, still over the 44 pt floor.
- **The title's line has one height**, 44 pt at least (`ScreenMetrics.titleLine`), whatever the
  accessory: a 36 pt chip and a 44 pt `+` otherwise centre the title a point and a half apart.
  **And the accessory never sets it.** Both grow with the text — the `+` to 53 pt three sizes
  above the ordinary one, where the title's line is 48 — so the accessory is laid out at the
  line's floor and drawn at its own size, and the line is rigid: a line that is only floored
  reports less than its title when a stack offers it less, which Home's column did (§12).
- The title is `.largeTitle` bold with `legibleOnBackdrop()`; the line under it is `.headline`. Each
  screen keeps what it says to VoiceOver: one heading, its value, the header trait.
- History's list still stops one point short of the top safe area; its header row's top inset is
  the shared inset less that point.

**The check** is a UI test that reads the title's frame on each tab and requires one origin.

## 4. The tabs

### 4.1 iOS 26 and later: Apple's bar

- `RootTabView` holds a `TabView(selection:)` of three `Tab`s, built from `AppTab`'s existing
  titles and symbols, inside `if #available(iOS 26.0, *)`. `Tab` is an iOS 18 API and is named
  nowhere else. The floor stays iOS 17.0.
- **The bar never minimises**: `tabBarMinimizeBehavior(.never)`. Three destinations on a screen the
  user returns to all day are not something to hide on scroll.
- **The selected tab is white, and the ground under the bar is shaded.** With `Aurora.cyan` as the
  tint a first read gave the selected caption 6.3:1 on iOS 27.0 and about 4.0:1 on iOS 26.5, where
  the system draws the selected lozenge lighter than the bar. **White did no better there:
  3.79–4.46:1.** The system mixes the caption toward the lozenge — about sRGB (255, 218, 255) on
  (130, 57, 240) — so no tint reaches 4.5:1. The lozenge follows what is behind the bar, so that is
  what is darkened: **`BarShade`, black at `0.25`**, over the foot of each tab's screen and under
  the bar, fading in over 20 pt above it. At `0.20` the worst frame of a minute read 4.78:1; at
  `0.25` every caption reads 5.10:1 or better on iOS 26.5 and 6.77:1 or better on iOS 27.0. It is
  drawn on iOS 26 and later only. Decision N8.
- **A kept screen is told when it is the one showing**: `EnvironmentValues.isShownTab`. It cannot
  learn that from appearing — iOS builds the tab beside the selected one ahead of time (§5).
- **A screen is no longer rebuilt when its tab is left**, so what the rebuild did by accident is
  done on purpose: Home ends its *Undo* offer, and History returns to today, when the screen
  disappears. `testAnUndoOfferDoesNotOutliveItsScreen` already pins the first.
- `.onAppear { manager.refresh() }` stays on each screen. It fires each time a tab is shown —
  except the first showing of a tab iOS built ahead of time, which appeared when it was built
  (§5). That costs nothing here: the screens share one `DataManager`, and the app refreshes on
  every return to the foreground.
- `preferredColorScheme(.dark)` stays on `RootTabView`.
- **What shows through the bar is measured, not assumed.** Read over the bare aurora, over
  History's rows and over Settings' controls, on a 402 pt phone at the ordinary text size, every
  caption passes with the shade. **One case does not**: on a 375 × 667 pt phone at the largest
  accessibility text size Home scrolls, the quick-add row rests under the bar, and with the white
  Glass disc beside the selected tab that tab's caption read **4.01:1 on iOS 26.5** (one capture).
  The system's `.soft` scroll edge is what is already drawn and changes nothing; `.hard` reads
  6.13:1 and cuts the content off square at the bar's top edge, so that nothing shows through the
  glass on any phone. Neither is adopted. Decision N9.

### 4.2 iOS 17 to 25: the app's bar

- The `ZStack` and `GlassTabBar` stay as they are, tap only. Apple's bar below iOS 26 is the flat
  one, and a second look on older phones is not what was asked for (§10, N1).
- **The captions go onto one line**: each glyph sits in a box of one height, so the caption under
  it starts at one y.
- The cross-fade stays. With one header it no longer shows two titles apart.

### 4.3 What the tests address

Both bars expose one button per tab, labelled by `AppTab.title(in:)`; every UI test that taps
`app.buttons["History"]` is unchanged. Confirmed on the scratch build for Apple's bar.

## 5. A screen arriving

Apple's bar cuts from one page to the next. What moves is the page: its content settles into place.

- **The title does not move.** It is in the same place on the screen being left and the one being
  shown, so it reads as standing still while everything under it changes.
- **Everything under the header rises 10 pt and fades in**, each section 40 ms after the one above
  it, over 0.4 s. Home: the vessel, the status, the quick-add row. History: the week card, the
  strip, the servings. Settings: its cards.
- **Under Reduce Motion it is the fade alone.** It runs once per tap, which rule `65-accessibility`
  exempts, but it is travel across the screen and not feedback under a finger (§8).
- It plays when a tab is shown and when the app first opens. It does not play on returning from
  the background or from a sheet: neither changes which tab is showing.
- **`Arrival`**, a file-scope `nonisolated` value with the numbers and a pure
  `delay(order:)`; `View.arrives(_:order:)`, which draws a section; and `View.tracksArrival(_:)`,
  which keeps the screen's one `@State` flag.
- **The flag is keyed on the tab being shown, and set a few frames after.** A flag set in
  `onAppear` is set before the first frame is drawn, and the screen has nothing to arrive from; and
  a screen iOS built ahead of time has "appeared" before it is shown. So the flag is set in a task
  keyed on `isShownTab`, 50 ms after the tab is shown (`Arrival.hiddenFirst`).
- **The flag is cleared once a kept screen has gone, and not as its tab is left.** iOS 27.0
  changes the page in one frame. iOS 26.5 goes on showing the old page for about a quarter of a
  second after the selection moves; cleared at the tap, the screen being left stood there with its
  title and nothing under it until the new page came. So it is cleared in `onDisappear`, and only
  for a screen that is not the one showing — the app's own container rebuilds a screen each time
  and has nothing to clear.
- **The backdrop does not change at a cut.** Each screen stands its own `AuroraBackground`, and a
  kept screen's goes on running; started when each was first shown, the three stood out of step
  and the backdrop jumped at every change of tab. `AuroraDrift` places a light by `AuroraClock`,
  which every copy reads, and not by how long that copy has been running.
- **A section that has not arrived is drawn at `0.001`, never at zero** (`Arrival.hiddenOpacity`).
  At exactly zero SwiftUI drops a view from the accessibility tree, and a screen kept while its tab
  was away did not get it back: its sections were drawn and answered a finger, and were reported as
  impossible to press until something redrew them.
- History's bars — the week's seven and the strip's — also grow from their baseline as the screen
  arrives.

## 6. What a touch does

Small, and each one tied to something the user did.

| Where | What | 
|---|---|
| A quick-add disc | Its glyph bounces once when it is pressed (`symbolEffect(.bounce)`), beside the recoil it already has. |
| *Undo* | The capsule arrives from 0.92 of its size instead of fading in — on `.smooth`, as every change of state is. The first text said "on a spring"; rule `60-design-system` names one spring, the press's (N12). |
| The streak chip | The flame bounces once when the count goes up, and not when it drops. The first day of a streak is the chip itself arriving. |
| A day in the week card | A selection tick, when the day shown changes. |
| A vessel shortcut in the sheet | A selection tick. |
| The sheet's slider | A tick at each 50 ml step. |
| A serving swiped away | A light tap. |
| Changing tab | A selection tick. |

The confetti, the pour haptic and the goal haptic are unchanged. Settings' sliders and its language
rows take their ticks in stage 4, when that screen is opened.

## 7. Haptics

Two rungs join the three in `Haptics`.

- **`Haptics.select`** — `.selection`. A choice among peers: a tab, a day, a vessel, a step.
- **`Haptics.remove`** — a light impact at `confirm`'s intensity. Something taken away.
- Each is fired through `.sensoryFeedback` from a counter bumped by the user's own action, or from
  the value under the finger in the sheet — never from a model value (rule `60-design-system`).
- **Unfelt until a device.** A simulator plays no haptic; whether iOS plays one of its own when a
  tab is changed on Apple's bar is **unrendered**, and the device check asks.

## 8. What this amends

**The redesign's document.** §3.4's two sentences — "The tab bar stays the app's own three-slot
bar" and "The system `TabView` is not adopted" — hold below iOS 26 only. §5.1's header, "The date,
the title *Today*", becomes the title and then the date. §12 gains both as differences from the
canvas.

**Rules.** The wording is proposed here and **no rule file is edited by this stage**: `50-views`
and `65-accessibility` already carry stage 3's wording, unstaged and not yet approved, and two
stages' proposals in one diff could not be approved one without the other. Until the owner says
yes, the code contradicts two rules as they stand — the `TabView` ban and the list of three
haptics — and says so here.

*Added 2026-10-12 by the doc sync after the build, from its reader's report: by the letter it is
more than two, and one of them has no wording below.* Rule `50-views` says "A haptic is driven by
a monotonically-bumped `@State` counter" and rule `60-design-system` "Trigger `.sensoryFeedback`
from a counter bumped by the user's own action". Two of this stage's triggers are a view's own
state and not a counter: the shown tab, for the tab's tick, and the amount under the finger in
the serving sheet — §7 names the second and not the first. Neither is a model value and only a touch writes either, which is what those
bullets are for; the owner chooses between rewording them to allow a view's own selection state
and bumping a counter beside each. And the bullet proposed below for `65-accessibility`'s
*Reduce Motion* is a departure from the one above it there — "runs once per tap … gets **no**
branch" — and not only an addition.

**`50-views`, *Navigation*** — the first bullet becomes:

> Navigation is `RootTabView`, and it is one of two containers chosen by the system alone. On iOS
> 26 and later: a `TabView(selection:)` of three `Tab`s, under Apple's bar. Below: a `ZStack`
> switching on `@State private var tab: AppTab`, with the app's own `GlassTabBar` mounted through
> `.safeAreaInset(edge: .bottom, spacing: 0)`. `TabView` and `Tab` are written in `RootTabView` and
> nowhere else. Do not introduce `NavigationStack` or `NavigationLink` — there are none in the
> project

and three bullets join it:

> A screen is kept while its tab is away, on iOS 26 and later. It ends its own presentation state
> in `.onDisappear` — Home's *Undo* offer, History's shown day — and never relies on being rebuilt
>
> Every tab opens with `ScreenHeader`, placed by `ScreenMetrics.margin` and `ScreenMetrics.topInset`:
> the title first, a line under it, an accessory on the title's line. A title stands in one place
> on every tab, at every text size: `testTheTitleHoldsItsPlaceOnEveryTab` and
> `testTheTitleHoldsItsPlaceWhereItsAccessoryIsTaller` hold it. The title's line is rigid and its
> accessory is laid out at `ScreenMetrics.titleLine` whatever it draws; never let either take its
> height from the other
>
> Everything under a screen's header carries `.arrives(_:order:)`, and the screen keeps its flag
> with `.tracksArrival(_:)`. Never set an arrival flag in `onAppear`: it is set before the first
> frame, and a screen iOS built ahead of time has appeared before it is shown. And never clear one
> as a tab is left: iOS 26.5 goes on showing the old page for a quarter of a second

**`60-design-system`, *Haptics*** — the first bullet becomes:

> Fire only through `Haptics.confirm`, `Haptics.pour`, `Haptics.goalReached`, `Haptics.select` and
> `Haptics.remove`. `select` is the system's selection tick, for a choice among peers — a tab, a
> day, a vessel, a slider's step; `remove` is a light impact, for something taken away. Never spell
> `.impact(weight:intensity:)` or `.selection` at a call site, and never play one from the widget
> extension

and under *Glass*, the tab bar's bullet gains "— the app's own bar, below iOS 26", with one new
bullet:

> Under Apple's tab bar the foot of each screen is shaded with `BarShade`. Its opacity is the first
> rung that passed with room when the selected tab's caption was rendered on iOS 26.5 and followed
> through the aurora's swing, and `theShadeIsNoLighterThanTheFirstRungWithRoom` holds it. Never
> retune it by eye

and under *Colour*, beside the lights' footprint and periods, one new bullet:

> An aurora light is placed by `AuroraClock`, through `AuroraDrift` — never by a built-in repeating
> animation, which counts from the moment it starts. Every screen stands its own backdrop, a kept
> screen's goes on running, and all of them have to be the same sky: started apart, they changed
> the backdrop at every change of tab

**`65-accessibility`** — under *Reduce Motion*:

> A screen's arrival is a fade under Reduce Motion: the rise and the growing bars are dropped, the
> opacity stays. It runs once per tap, but it is travel across the screen and not feedback under a
> finger

under *VoiceOver*:

> A view that is kept while it is not shown is never drawn at exactly zero opacity:
> `Arrival.hiddenOpacity`. At zero it leaves the accessibility tree, and a kept screen did not get
> it back — its buttons were drawn and could not be pressed
> (`testAKeptScreenAnswersATapWhenItIsShownAgain`)

and under *Tap targets*, "The tab bar is three slots" becomes "The app's own tab bar is three
slots, and its three captions share a line".

**`15-project`** — one more bullet under the two version checks:

> **The third version check is the tab container's.** `RootTabView` builds a `TabView` inside
> `if #available(iOS 26.0, *)` and the app's own bar below it. `Tab` is an iOS 18 API and is named
> only inside the check; the floor stays 17.0. Below iOS 26 the path is run on iOS 18.6 and
> compile-verified only at 17.0

**`85-testing`** — one bullet under *Writing assertions*:

> A UI test that holds for one tab bar and not the other skips, with `XCTSkip`, on the system that
> draws the other, and says which in the message. Never an `if` that lets it pass having asserted
> nothing

## 9. Testing and verification

### 9.1 Tests, written first

- **Pure, off the main actor.** `Arrival.delay(order:)` grows with the order and stays under a
  ceiling; the header's margin leaves each of seven day buttons 44 pt on a 375 pt phone; the three
  screens read one margin and one top inset; `Haptics.remove` is no firmer than `confirm`.
- **UI.**
  - *The title holds its place*: the heading's origin is the same on Home, History and Settings.
    Fails today by 4 pt and 1.3 pt.
  - *A press dragged along the bar changes the tab*, on iOS 26 and later; skipped below.
  - *The bar's captions share a line*, on the app's own bar; skipped where Apple's is drawn.
  - *History returns to today when its tab is left.* Passes today by the rebuild, and is the pin
    that fails once the container stops rebuilding.
  - The 43 that exist are unchanged and run on both bars.

### 9.2 The gate

Rule `85-testing`'s five invocations, the UI target as its two complementary invocations per
system, on iOS 27.0 and 26.5 — Apple's bar — and iOS 18.6 — the app's own. Warnings compared with a
clean build of the index.

### 9.3 On the simulator

- A recording of every tab change and of the drag, on iOS 27.0 and 26.5; of the tab change on 18.6.
- Each caption on Apple's bar, through a minute of the aurora, over the four grounds of §4.1, on
  both systems, by the project's method: white composited over the worst pixel of the ground.
- The header's frames on a 375 × 667 pt phone and at the largest text size, in Russian.
- Reduce Motion, Reduce Transparency and Increase Contrast switched on, each rendered with
  Apple's bar.

### 9.4 The owner's device check

The drag by feel; every haptic; whether iOS adds a tick of its own to a tab change; VoiceOver on
Apple's bar; the bar in daylight.

## 10. Decisions taken here, for the owner

| | Decision | Taken as |
|---|---|---|
| N1 | Below iOS 26 the bar stays the app's own, tap only | Yes — stated to the owner on 2026-10-11 and not contradicted |
| N2 | Home's date moves under the title, unlike the approved board | Yes — it is what puts *Today* in one place |
| N3 | The selected tab on Apple's bar is white if cyan stays under 4.5:1 on iOS 26.5 | Yes |
| N4 | The page changes by Apple's cut; the motion is the content arriving | Yes — the option the owner chose said the page change would be Apple's |
| N5 | Two haptics are added, and the eight touches of §6 | Yes |
| N6 | **d** (servings as rows) and **e** (no counted nouns, three hour labels, *Added 250 ml*) stay as decided on 2026-10-09 | Yes — "go" named no letter, and both were marked as decisions already made |
| N7 | The look — **a**, **b**, **c**, **g** — is stage 3c, after this stage's `/commit` | Yes |
| N8 | **The foot of every screen is shaded by a quarter under Apple's bar**, on iOS 26 and later. Nothing the owner has seen drew it | Yes — without it the selected tab's caption is 3.79–4.46:1 on iOS 26.5, and "step it up until every pair passes" is the owner's ruling of 2026-10-09 for the glass's tint. The alternatives are to ship that caption under its floor, or to keep the app's own bar on iOS 26.x |
| N9 | On the smallest phone at the largest text size, on iOS 26.5, the selected tab's caption can read 4.01:1 with the white Glass disc under the bar. It is recorded and not cured | Yes — the cure, a hard scroll edge, stops content showing through the glass on every phone, which is what the bar was asked for |
| N10 | The selected tab is white, where the canvas drew cyan | Yes — cyan read 3.98:1 on iOS 26.5 before the shade, and white is the lighter of the two on a lozenge lighter than the bar. With the shade white reads 5.10:1 or better; **cyan was not measured with the shade** |
| N11 | The rule wording is written in §8 and no rule file is edited | Yes — two of the files hold stage 3's wording, still waiting for the owner |
| N12 | *Undo*'s capsule arrives on `.smooth`, not on the spring §6 first described | Yes — rule `60-design-system` names one spring, the press's, and no amendment was proposed for a second. One line brings it back if the owner amends the rule |
| N13 | **Every backdrop reads one clock** (`AuroraClock`, `AuroraDrift`), in `AuroraBackground.swift` — a file the plan did not list | Yes — found at the final review: with kept screens the backdrop changed at every change of tab, which is the complaint this stage answers. The journey and its curve are the ones the lights had |
| N14 | On a 375 × 667 pt phone under Apple's bar, Home's vessel is at its 200 pt floor at the ordinary text size (214.5 under the app's own bar), and the vessels' names stand in the shade's ramp | Yes — rendered: everything is on screen above the bar and the names read 5.6:1 or better. A shorter header or a lower floor is the owner's to ask for |
| N15 | The date under *Today* may shrink to 0.45 of its size, where 0.5 was measured for one day | Yes — the widest date, a Monday late in September in Russian, needs 0.491 on the narrowest phone at the largest text size |

**Left for the owner to say, and built neither way:** whether Home's goal haptic and confetti
should play when the goal is crossed from History's sheet, now that Home is kept while its tab is
away; and whether a kept screen should come back scrolled where it was left — it does.

## 11. Not in scope

- The glass, the vessel, the week card and a serving's glyph: stage 3c.
- Settings, beyond its header: stage 4. Its sliders' ticks and its language rows' go with it.
- A drag on the app's own bar below iOS 26.
- The bar minimising on scroll; a search tab; a bottom accessory.
- Plural forms (known issue #40).
- The widget and the watch.

## 12. Where the build left this document

Built on 2026-10-11 and 12. What the first text did not have, and the build found:

- **A shade under Apple's bar** (§4.1, N8). The first text expected a tint to settle the selected
  caption. No tint could: the system mixes the caption toward a lozenge it draws light on iOS 26.5.
- **A screen is told when it is shown** (§4.1, §5). The first text set the arrival flag "on appear".
  Read frame by frame off a recording, History then appeared whole on its first visit: iOS had
  built it ahead of time.
- **Hidden is not zero** (§5). The first text hid a section at no opacity. After a tab was left and
  shown again, every button in a returning section was drawn, answered a finger, and was reported
  as impossible to press. A throwaway walk found it; a test now holds it.
- **One caption is under its floor and stays there** (§4.1, N9).
- **The rules are proposed here and not edited** (§8, N11).

What a fresh reviewer and the renders it asked for found, on 2026-10-12:

- **The title still stood at two heights, at the text sizes between the two that had been
  rendered** (§3). Two causes: History's `+` outgrew the title's line and took it over, and Home's
  column offered the line less than the title's height. The line is rigid now and the accessory
  does not set its height; a second title test runs three sizes above the ordinary one.
- **The backdrop changed at every change of tab** (§5, N13). Nothing in the first text or the
  plan looked at the aurora across a cut; the recording that had been read was taken half a
  second after launch, when every backdrop was still in step.
- **On iOS 26.5 the screen being left stood empty for a quarter of a second** (§5). The first
  text cleared the flag when the tab was left; iOS 27.0, where the recordings had been read,
  changes the page in one frame and showed nothing.
- **The date's floor held for the day it was measured on and not for every day** (N15).
- **Home is tight on the smallest phone** (N14), and **the capsule's spring was against a rule**
  (N12).
- The test that a screen comes back whole could fail for Home alone; it looks at all three now.

Rendered at that review: Increase Contrast with Apple's bar on iOS 26.5; the header in Russian at
the largest text size on a 375 pt phone; a change of language under Apple's bar; the final code
recorded on iOS 27.0, 26.5 and 18.6; landscape, for the shade's edges only.

Not done, and said in the stage's records: Reduce Motion and Reduce Transparency rendered with
Apple's bar — the simulator has no switch for either; anything on a device, where every haptic and
the drag by feel still wait. One UI test failed once on iOS 26.5 and passed 23 times after — a
tap high on the Cup's disc that lit the disc and poured nothing — and its cause is not known.

**Since then (2026-10-12, the second pass).** One sentence above did not last the day: the
simulator's Settings app does have a switch for Reduce Motion, a UI test can press it and read it
back, and the second pass ran under it. Reduce Transparency is still unrendered. What the second
pass replaced in this document is listed under *Status*, at its head.
