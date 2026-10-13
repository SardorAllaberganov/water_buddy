# The page slide and the small touches — stage 3b, second pass

**Date:** 2026-10-12
**Status:** design, written by the session that builds it. The owner chose its three answers;
everything else here is that session's reading and is theirs to overturn (§9). **Built on
2026-10-12 and unstaged**; brought up to the code after the build's review, and again the same
day after fresh readers (the fifty-fourth and fifty-fifth passes of `docs/AI_CONTEXT.md`).
Most of their corrections are marked where they fall; the clauses about Reduce Motion and
History's bars are not.
**Builds on:** `2026-10-11-navigation-and-motion-design.md` (stage 3b), which it supersedes in
part (§8). Stage 3b is unstaged in the working tree and this is built on top of it.

## 1. Why

The owner built stage 3b to their iPhone 15 Pro Max (iOS 27.0) on 2026-10-12 and said:

> there is no animation in page changes and add some micro-interactions when working in app. it
> is not looks like premium.

Asked what the content under the title does on a change of tab: **"It just appears."** Stage 3b
changed the page in one frame and let the content rise 10 pt and fade in over 0.4 s. That had
been judged frame by frame off simulator recordings and never by eye, at speed, on a phone. On
the phone it is nothing.

Their answers:

- **A change of tab: a slide, by direction.** The pages sit side by side like the tabs. Going to
  a tab on the right, the new page comes in from the right as the old one leaves to the left.
  The sky stays still.
- **Micro-interactions: all four groups** — water that reacts; rows and cards that move;
  controls that answer; scrolling with depth.

## 2. The page change

### 2.1 What it looks like

Both pages are on screen while the page changes. They move together, a full screen's width, in
the direction of the tab chosen, over 0.45 s on `.smooth`. The backdrop does not move. The bar
does not move; on Apple's bar its lens crosses as it always did. Each page carries its own
header, so a title leaves with its page and the next one arrives with its page.

Under Reduce Motion nothing travels: the old page fades out and the new one in, 0.25 s.

### 2.2 Why not inside Apple's `TabView`

`TabView` removes the old page in one frame on iOS 27.0 and holds it for a quarter of a second
on iOS 26.5; it offers no transition. A throwaway spike (the stage's ledger has it) tried the
alternatives:

- **A standalone `UITabBar` over a pager the app draws.** On iOS 27.0 the bar matches the
  `TabView`'s once it is given its own height and reaches the foot of the screen: no pixel
  differing by more than 24 levels of 255 in grey, which is the whole of what the spike
  measured (this line read "pixel for pixel" until the fifty-fourth pass of
  `docs/AI_CONTEXT.md`). A tap and
  a press dragged along the bar both change the tab. On iOS 26.5 it is in the same place at the
  same size, and **its glass is darker** than the `TabView`'s over the same aurora (§9, M1).
- Keeping all three pages mounted and offsetting them failed three UI tests: a page off screen
  stayed in the accessibility tree whatever it was told, and nothing ever "disappeared".

### 2.3 The container

`RootTabView` is one container on every system:

```
ZStack
  AuroraBackground          one sky for the three tabs
  the pages                 two at most: the one shown and, while it slides, the one leaving
  the shade                 under Apple's bar only, still
.safeAreaInset(bottom)      the bar: Apple's UITabBar on iOS 26 and later, GlassTabBar below
```

**`PageTurn`** is the pure half, a value with no view in it: which page is shown, which is
leaving, and which way the shown one came (`+1` from the right, `-1` from the left). It answers
which pages are mounted, where each stands for a given width, and where a new page enters from.
A turn to the tab already shown is nothing. A second turn before the first has ended drops the
page that was leaving and makes the one that was shown the leaving one: two pages at most.

**A page is built when it is shown and removed when its slide ends** — as it was until stage
3b. The page shown enters by an insertion transition, because the direction is known when it is
inserted. The page leaving is not "removed" at the turn: it stays mounted, is moved by an
explicit offset, and is removed when the slide's animation completes
(`Transaction.addAnimationCompletion`), with a check that no newer turn has started: turns are
counted, and a slide's end is matched to the turn that began it, not to the page it brought in.
While it leaves it takes no touch and is hidden from accessibility — which Home and Settings
honour and History's rows, a `List`'s, do not: for the length of a slide away from History its
rows are still in the tree.

**The bar on iOS 26 and later** is `SystemTabBar`, a `UIViewRepresentable` over `UITabBar`:
three `UITabBarItem`s from `AppTab`'s titles and symbols, a white tint, a delegate that turns
the page. It takes the height `UITabBar` asks for (83 pt on a phone with a home indicator) and
is pulled down by the bottom safe-area inset, so it stands where the system stands its own and
the pages' safe area ends at its top — the layout `TabView` gave.

**The backdrop moves out of the three screens.** A backdrop inside a page slides with it. The
three tabs share the one `RootTabView` stands; the first-run screen and the serving sheet keep
theirs.

**The shade** is drawn once, by the container, over the pages and under the bar.

### 2.4 What this removes

`SystemTabs` and its `TabView`; kept screens, and with them `EnvironmentValues.isShownTab`, the
arrival flag's clearing in `onDisappear`, and the two resets Home and History made when they
disappeared — a rebuilt screen starts clean. Known issues #114 (a kept Home answering a goal
crossed from History's sheet; a kept scroll position) and #82's second half (the capture
harness's `returnToTop`) end with them.

`Arrival` stays for the page the app opens on, which has nowhere to slide in from: under its
title its sections settle in, each a moment after the one above. **A page that slides in has
its sections whole as it comes.** It settled too in the first build of this pass, and the review's reading
of the frames was that the page crossing the screen was mostly a header: its first section was
at half strength with two thirds of the way gone. A slide is seen as one only if the thing
sliding is there to see. History's bars still grow as its page arrives, unless Reduce Motion
is on.

## 3. One vocabulary for motion

`Motion`, a `nonisolated enum` in its own file, app-only. What this pass adds names a curve
where `Motion` has one. *(This read "Call sites name a curve; none spells one" until the
fifty-fourth pass of `docs/AI_CONTEXT.md`, against §7's own note. Sixteen call sites outside
`Motion.swift` still spell `.smooth(duration:)`, at six lengths from 0.28 to 0.5 s — all
older than this pass, which took four away; one of them, the strip's, now also drives the
regrow this pass added — and the swell spells its two lengths in `PourDrop.swift`.)*

| Name | Curve | For |
|---|---|---|
| `page` | `.smooth(duration: 0.45)` | a page changing |
| `pageFade` | `.smooth(duration: 0.25)` | the same, under Reduce Motion |
| `settle` | `.smooth(duration: 0.3)` | a state changing — a length the app already uses, at two of those sixteen sites; 0.5 is the commonest, at five |
| `land` | `.spring(response: 0.5, dampingFraction: 0.68)` | something that arrives: it passes its place a little and comes back |
| `water` | `.spring(response: 0.8, dampingFraction: 0.62)` | the level in the vessel |
| `drop` | `.easeIn(duration: 0.42)` | a drop on its way to the vessel |

The press keeps its own spring in `PressStyle` and `LiquidGlassModifier`, untouched.

`land` and `water` are a second and a third spring. Rule `60-design-system` names one and gives
every state change `.smooth` (§7).

## 4. The touches

### 4.1 Water that reacts

- **The level lands.** It rises on `Motion.water`, passes its mark and settles, where it glided.
- **A drop goes from the disc to the vessel.** On a pour a drop leaves the centre of the disc
  that was pressed and falls, on an arc, into the vessel, in 0.42 s. It is 22 pt across: at 16
  it was a speck on the first recording. `PourArc` is the pure half: a point on a quadratic
  curve between two points, lifted above the straight line.
- **The vessel answers the drop.** When it lands the vessel swells by 2.5 % and returns, and
  the slosh the waves already had starts then, not at the tap.
- Under Reduce Motion there is no drop and no swell; the level still moves.

The drop is decoration: hidden from accessibility, takes no touch, and the pour is logged at
the tap, not at the landing.

### 4.2 Rows and cards that move

- **The shown day's marker glides.** One capsule that moves from day to day on `Motion.land`,
  where every day had its own that faded. The same two `LiquidGlass.Selection` tokens.
- **The strip's bars grow again when the day shown changes**, from their baseline, as they do
  when the screen arrives (not under Reduce Motion, §5).
- A serving added to or deleted from History's list already slides (the list animates on row
  identity); that is checked on a recording, not rebuilt.

### 4.3 Controls that answer

- **A tick that draws itself** beside *Daily goal* and *Quick-add vessels* when a change is
  saved, and fades after a moment. A stroked shape trimmed from nothing to whole on
  `Motion.land`, drawn over its row and taking no room in it.
- **The figure under a finger grows** by 6 % while its slider is held, and lands back.
- **The language's checkmark bounces** when a language is picked.
- **The streak chip and *Undo*'s capsule arrive on `Motion.land`** from 0.8 of their size.
  This reverses stage 3b's decision N12, which kept the capsule on `.smooth` because the rule
  names one spring.
- **Settings' cards move together** when the reminders card changes what it says and, with
  it, its height.

### 4.4 Scrolling with depth

`scrollDepth()`: a section crossing the top or the foot of its scroll view shrinks toward
0.92 of its size, by how little of it is left showing, drawing back from the edge it is
crossing. On every section of History and Settings, the header included. `ScrollDepth` is the
pure half. Under Reduce Motion nothing recedes.

**It does not fade.** The owner's choice was "fade and shrink", and for an hour it did both. A
fade is a loss of contrast on text still on screen. By the reviewer's arithmetic, a 330 pt
card with a third of itself past the top was drawn at about five sixths of its strength while
the rest of it was being read. It read two 603 px video frames, which it called indicative.
With History's week card mostly out of the screen, a line measured at 5.49:1 at rest read
about 3.6–4.0:1, under the 4.5:1 floor. With Settings' vessels card about a third out, its
caption read about 5.9–6.9:1 against 10–12:1 in a whole card: dimmer, and over the floor. A
list can come to rest anywhere. The shrink costs no contrast (§9, M8). *(Until the
fifty-fourth pass of `docs/AI_CONTEXT.md` this ran them together — "about 3.8:1 in a frame
of" the card a third out. That reading is of the card mostly out, and 3.8 is the middle of
its range.)*

**It works out its own position.** SwiftUI's `scrollTransition` was built first; inside
History's `List` it never reported a row at rest and every row stood dimmed.

**Not on Home.** Home is a screen that fits: it scrolls only at the large text sizes, where its
last row rests partly past the foot of its scroll view — and a section that rests part-way out
would rest part-shrunk, on the one screen whose every line was measured at rest.

## 5. Accessibility

| | Ordinary | Reduce Motion |
|---|---|---|
| Page change | slide, 0.45 s | cross-fade, 0.25 s |
| Sections of the opening page | rise and fade | fade |
| Level | spring | spring (a value changing, once) |
| Drop, vessel's swell | yes | no |
| History's bars, the week's and the strip's | grow from the baseline as the page arrives; the strip's again on a change of day | simply there |
| Marker, tick, chip, capsule | spring | spring (once per tap, under a finger) |
| Scroll depth | shrink | none |

Only the page shown is in the accessibility tree once a slide has ended; during it the leaving
page is hidden, History's rows aside (§2.3). Every label, value and trait is unchanged. The
drop, the tick and the marker are decoration and hidden. No new string.

## 6. Testing

Tests first, each seen failing.

- **Unit, pure, not `@MainActor`:** `PageTurnTests` (direction, two pages at most, an older
  turn's end does not end a newer turn — nor there, back and there again inside one slide —
  nothing travels under Reduce Motion), `MotionTests` (the page is quicker than half a second;
  `land` overshoots and does not ring; neither spring is as quick as the press's),
  `PourArcTests` (starts at the disc, ends in the vessel, rises above the line between),
  `ScrollDepthTests` (whole at rest, whole while a tall card fills the screen, nothing jumps at
  the edge, a span of nonsense is no span), four in `ArrivalTests` (a page that slid in is
  whole from its first frame) and two on the marker's place in `HistoryLayoutTests`.
- **UI:** `testOnlyThePageShownIsInTheTreeAfterAChangeOfTab` — after Home → History → Home,
  one heading named *Today* and no *Add a serving*. Every existing tab test, unchanged, on iOS
  27.0, 26.5 and 18.6.
- **By eye and by frame:** recordings of the page change on the three systems; the bar beside
  the `TabView`'s on iOS 27.0 and 26.5.
- **On a device:** the owner's. Nothing here has been felt or seen on one.

## 7. Rules this departs from — proposed, not edited

No rule file is edited by this pass, for the reason stage 3b's spec gives. This replaces that
spec's §8 where they overlap.

**`50-views`, *Navigation*** — the first bullet becomes:

> Navigation is `RootTabView`: one `AuroraBackground`, the page shown — and, while it slides,
> the page leaving — and a bar mounted through `.safeAreaInset(edge: .bottom, spacing: 0)`.
> `PageTurn` decides which pages are mounted and where each stands. The bar is Apple's
> `UITabBar` on iOS 26 and later (`SystemTabBar`) and the app's own `GlassTabBar` below. Do not
> introduce `TabView`, `NavigationStack` or `NavigationLink` — there are none in the project

and stage 3b's proposed bullet about a kept screen is withdrawn: a screen is built when shown.

**`50-views`, *Animation*** — the first bullet gains: "or, where the animation's end has to be
known, `.transaction(value:)` with `addAnimationCompletion`".

**`60-design-system`, *Interaction*** — the last bullet becomes:

> The press curve is `.spring(response: 0.28, dampingFraction: 0.62)` and stays identical in
> `PressStyle` and `LiquidGlassModifier`. New motion takes its curve from `Motion` — `page`,
> `settle`, `land`, `water`, `drop` — and does not spell one of its own: `settle` for a state
> that changes, `land` for something that arrives. Scoped with `.animation(_:value:)` — never a
> bare `withAnimation`

*(Not "a call site never spells one": sixteen older call sites still write `.smooth(duration:)`
themselves and this pass does not rename them.)*

**`60-design-system`, *Colour*** — "Every full-screen view on the phone stands its own
`AuroraBackground()`" becomes: the three tabs share the one `RootTabView` stands; every other
full-screen view stands its own.

**`65-accessibility`, *Reduce Motion*** — the bullet stage 3b proposed for the arrival gains
the page: a page change is a cross-fade, the drop and the vessel's swell are not drawn, and
no section recedes as it scrolls. *(Three of the four read the setting. The swell has no
branch: it answers a drop landing, and no drop is thrown.)*

**Bent, and said here:** rule `00-workspace`'s one type per file. `PourDrop.swift` holds the
drop's view with its pure half, its two anchor types and the vessel's swell, and
`ScrollDepth.swift` and `Arrival.swift` each a pure half with the modifiers that use it — as
stage 3b's `ScreenHeader.swift` and `Arrival.swift` already did. `PourDropTests.swift` holds
`PourArcTests`.

**`15-project`** — the third version check is the bar's: `SystemTabBar` inside
`if #available(iOS 26.0, *)`.

## 8. What this supersedes in stage 3b's spec

§4 (the `TabView` container and kept screens), §5's "the title does not move", N12 (*Undo* on
`.smooth`), and §8's `50-views` wording. Stage 3b's header, its shade, its two haptics, its one
clock for the backdrop and its `Arrival` stand.

## 9. Decisions taken here, for the owner

- **M1. On iOS 26.x the bar's glass is darker than it was.** A standalone `UITabBar` there is
  smoked where a `TabView`'s is vivid; on iOS 27.0 the two builds' foot of the screen agree to
  within 11 levels of grey in 255 (26 in blue), and that difference is in the bar itself:
  above it the two agree to 2 levels, as two captures of one build do. "Identical", as this
  read until the fifty-fourth pass of `docs/AI_CONTEXT.md`, was more than was measured. The
  cure is to host the
  pages in UIKit's tab controller with a UIKit transition: kept screens again, a slide that
  cannot be interrupted, and the backdrop and the shade put into UIKit's hierarchy.
- **M2. A screen is rebuilt each time it is shown**, as before stage 3b. It returns to its top
  and to today, and Home's *Undo* ends when the tab is left.
- **M3. Two more springs** (`land`, `water`) against a rule that names one.
- **M4. The title moves with its page** during a change. Stage 3b held it still.
- **M5. One backdrop for the three tabs**, against the rule that every screen stands its own.
- **M6. No swipe across the screen to change tab.** A sideways drag belongs to History's rows
  and to the sliders.
- **M7. The page does not follow a finger dragged along the bar**; it turns when the tab does.
- **M8. The scroll effect shrinks and does not fade**, where the owner chose "fade and
  shrink": a fade took a measured line under its contrast floor at rest (§4.4). To have the
  fade back, the floor has to give for a section part-way off the screen.
- **M9. A page that slides in has its sections whole**; only the page the app opens on
  settles in section by section (§2.4). History's bars are not part of that: they grow from
  nothing on every page, sliding in or not, unless Reduce Motion is on.
- **M10. A second tab chosen inside a slide drops the page that was leaving where it
  stands.** After a fifth of a second it is three quarters out; sooner, it is seen to go.
- **M11. A tap on the tab already shown does nothing.** Inside a `TabView` Apple's bar scrolls
  that screen to its top; standing alone it only reports the tap, and nothing is built on it.

## 10. Not in scope

The watch and the widgets. The look of the glass, the vessel, the week card and a serving's
glyph — stage 3c. Settings' redesign — stage 4.
