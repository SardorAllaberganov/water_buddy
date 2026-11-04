# Release 1.4, polished before the capture — design

Taken by `/start_task` with no task named, on the owner's choice *Polish 1.4 before Sunday* (2026-11-04): the four
minors *One finish*'s final review left — known issues #221, #222, #223 and #224 — closed on `release/1.4` before
phase 2's capture, so Sunday's shots and phase 2's gate are of the polished build
(`2026-11-04-release-1-4-design.md` §2).

## 1. What was found, before any fix

Each was investigated first, in a `git checkout-index` copy of `ea67781` in the scratchpad, never in the tree.

### 1.1 #221 — the close button's test, on iOS 18.6

`SheetCloseButtonTests.theGlyphDoesNotGrowWithTheTextSize` renders the ✕ at `.large` and `.accessibility5` and
compares the PNGs. A probe rendered four variants on *iPhone 16* (18.6), each twice at `.large` and once at the largest
size, and compared them pixel by pixel:

| Variant | `.large` against `.large` | `.large` against `.accessibility5` |
|---|---|---|
| The whole button | 13,399 px differ | 13,406 px differ |
| The ✕ alone | identical | identical |
| The glass alone | 13,912 px differ | 13,920 px differ |
| The ✕ in its `Button` and `PressStyle` | identical | identical |
| The whole button, Reduce Transparency on | identical | identical |

**The ✕ does not grow. The test cannot tell, because its backdrop is drawn differently every time.** Below iOS 26 the
pane is the hand-made stack, whose base is `.ultraThinMaterial`, and an `ImageRenderer` cannot draw a `Material` —
rule `40-widget`'s reason for `Base.archived`. It comes back a flat grey whose shade changes from one render to the
next (read off the PNGs). On 27.0 the pane is Apple's glass and the test passes. The product is right; the test
compares the wrong pixels on 18.6, and its message blames the text size for what the renderer did.

### 1.2 #222 — a purchase's two laps

`PremiumRim` animates `lapDuration × laps`: 1.5 s × 2 = **3.0 s**. Spec `2026-11-01-premium-look-design.md` M6, which
the owner approved, says **two laps in 1.9 s**, beside 28 pieces of confetti over 1.5 s. No refinement recorded the
change; the plan's Task 3 multiplied. At 3.0 s the light circles on for a second and a half after the confetti has
gone.

### 1.3 #223 — Settings' Premium lap

Two causes, both read in the code:
- **It starts before the slide ends.** Settings raises its lap flag through `tracksLanding`, `Landing.wait` (350 ms)
  after the page is built, but a page slides in for `Motion.pageDuration` (450 ms). Under load the build is late too,
  so the gap moves (`tasks/lessons.md`, 2026-11-03, *A wait counted from a view's build…*); the final review saw the
  light come up over the slide's last 20 pt.
- **A late card never laps.** The card is drawn only once StoreKit's first read has answered
  (`SettingsView.showsPremium`). A card inserted after the flag rose is built with `lit` already `true`, so
  `PremiumRim`'s `.animation(_:value: lit)` sees no change and the light starts at its end: a lap lost.

### 1.4 #224 — a month's page turn

The issue was read in the code: positional day cells change branch on a turn, and under the card's
`.smooth(duration: 0.3)` the old view might fade out with its ring as it stood. **Recorded and read frame by frame on
18.6, 26.5 and 27.0, it does not happen.** A probe held a Premium launch on the store sample and turned November →
October → November, then October → November again 0.25 s into the rings' draw. On every system and every turn, the old
month — its title, its rings, half-drawn ones included — is gone between two captured frames, 15–46 ms apart, and the
new month's rings draw from nothing in their wave. A per-cell change scan over each turn shows one large frame and
nothing sustained after it, while the same scan reads a tab's slide as a run of changed frames, so it does see a fade.
Not covered: a six-week month, which the store sample does not reach (September, October and November 2026 each take
five rows).

## 2. The changes

### 2.1 #221 — the test proves its render first (D1)

`SheetCloseButtonTests` keeps its claim and its assertion, and gains what makes the comparison mean something:
- **First, two renders at `.large` must be identical**, as a suite that reads a bundle first proves the bundle resolved
  (rule `85-testing`). On 18.6 today this is the line that fails, with a message that names the renderer.
- **Both renders are made with Reduce Transparency on**, through `EnvironmentValues._accessibilityReduceTransparency`,
  SwiftUI's own setter for the value `accessibilityReduceTransparency` reads. The pane then draws its opaque fill
  (`LiquidGlass.rendering`), the same on every system, and the whole button — glyph, pane, edge, `PressStyle` — is still
  what is rendered. A DocC line on the test says why.

The brightness check stays. No app code changes.

### 2.2 #222 — the purchase's laps take the spec's time (D2)

`PremiumRim` gains `purchaseDuration = 1.9` and `duration(laps:)`: a purchase's laps in their own time, any other count
at a lap's pace. Its `.animation` reads `duration(laps:)`. A purchase's lap is then 0.95 s — still a full lap you can
follow, and the arrival's 1.5 s lap is unchanged. `PremiumRimTests` pins `duration(laps: purchaseLaps) == 1.9` and
`duration(laps: 1) == lapDuration`.

### 2.3 #223 — the lap waits for the slide's end, and a late card laps on its own (D3)

- **`PageTurn.hasLanded(_:)`** — `true` for the page shown once no page is still leaving, which is the slide's end as
  the app already defines it: `settle(_:)` clears `leaving` from the slide's own animation completion. The page the app
  opens on has landed at once, and an older slide's end never lands a newer page.
- **`EnvironmentValues.pageHasLanded`**, set by `RootTabView` beside `pageIsShown`, `true` for a screen standing alone.
- **`SettingsView`** reads it instead of keeping its own `landed` through `tracksLanding`, and hands it to the card.
- **`PremiumCard`** keeps its own `lit`, raised by `onChange(of: landed, initial: true)` once the page has landed. A card
  inserted later raises it as it appears, so it runs its lap then: the lap belongs to the card's arrival, not to a flag
  it may have missed.

`Landing` is the sheets' alone again. Rule `60-design-system`'s line on the rim does not change: one lap as it arrives.

### 2.4 #224 — retired on the recordings (D4)

No code. The issue is retired with what was read, and the six-week month is named as not covered.

## 3. Decisions

Mine, recommended, for the owner to change at review:
- **D1.** Fix #221 in the test, by Reduce Transparency, with the determinism check first. *Alternative:* move the ✕
  into its own view and render that alone — no underscored API, but app code changes and the button is no longer
  rendered whole.
- **D2.** Match the approved spec: 1.9 s. *Alternative:* write 3.0 s into M6, and change no code.
- **D3.** Wait for the slide's end, from `PageTurn`. *Alternative:* wait `Motion.pageDuration` from the build — one
  constant, but a lower bound under load, which the 2026-11-03 lesson argues against. The late card is fixed either way.
- **D4.** Retire #224 with no code. *Alternative:* `.transition(.identity)` on the cells as a guard — a change no
  recording can show working, since nothing fades today.
- **D5.** Three commits by subject, on `release/1.4`, at the owner's `/commit`: the test (#221), the purchase's laps
  (#222), Settings' lap (#223), then the records. Their files do not overlap.

## 4. How it is proved

- **Tests first, each seen failing:** #221's determinism line on 18.6 before Reduce Transparency is added;
  `PremiumRimTests`' 1.9 against today's 3.0, after `duration(laps:)` is first written as today's arithmetic;
  `PageTurnTests`' landing tests against a `hasLanded` first written as `tab == shown`, Settings' behaviour today.
- **#221 green on 18.6, 26.5 and 27.0.**
- **#222 and #223 read off recordings on *iPhone 17* (27.0)**, frame by frame: a turn to Settings, the lap's first
  light after the slide's last frame; a late card, through a delayed `PremiumStore.Source.held()` in a scratch copy
  only, lapping as it appears; a purchase's laps can't be shot without a store and stay with the owner's real
  purchase (#156), where the 1.9 s is felt.
- **The gate**, on a `git checkout-index` copy of the index: the five invocations on 27.0, the UI suite on 26.5, and the
  phone unit suite on 18.6 too — it failed there only on #221, so the whole suite should now pass. Warnings compared
  by file and message against a clean build of `ea67781`. Recorded flakes (#191, #209, #215, #225, the speed guard)
  are run alone before they are read.

## 5. Records

`docs/AI_CONTEXT.md` (#221–#224 retired, the gate), `docs/DESIGN.md` (the rim's two rows and Settings' lap row),
`HISTORY.md`, `tasks/lessons.md` (a pixel comparison proves its render repeats first; an issue read in the code was a
hypothesis the recording disproved), `CLAUDE.md` only if its description of the finish moves. `.claude/` is not
touched.

## 6. Not in this work

The flaky UI tests, #219, #220, any other behaviour, the store text, the capture itself, and every push.
