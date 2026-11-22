# Set C, to make it theirs — design

**Status:** written for the owner's review, 2026-11-22. Started by another session on the owner's question
*what is the next feature?* — set C is next in the roadmap's approved order. The owner ruled four questions in
conversation, each the recommended option, and chose four themes: **a theme reaches the app, the Home Screen and
week widgets, and the watch app** (D1); **Lagoon, Dusk, Midnight and Bloom beside Aurora** (D2); **any vessel may
stand in Home's middle slot** (D3); **the app icon is its own choice** (D4). Every other decision (D5–D22) is a
recommendation for the owner to change at review. **The written spec and the rule wording in §3.13 are approved**
(2026-11-22, "Approve both"), D5–D22 as recommended. No code is written until the plan is approved (roadmap §8).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then `CLAUDE.md`. Where
this spec and a rule disagree, the rule stands until the owner approves §3.13's amendment.

**Provenance.** Every claim about the repository was read at `285e195`, where `main` and this worktree's branch
both stand, on 2026-11-22, with nothing staged. Line numbers are that commit's. The sketch board,
<https://claude.ai/artifact/8ohircYRmsUSDeCtVKJaxt> (private to the owner), shows the five skies, their icons and the
library: hue identity only. No colour on it is final, and no figure on it is a measurement. The 2026-10-21 design
canvas could not be opened from this session's account, so this design does not build on it.

## 1. Where this sits

Roadmap §5, release 1.4 — Premium. Sets A (*to understand*) and B (*to be coached*) and export shipped in 1.4, live
since 2026-11-13; 1.4.1, a fix release, is waiting for review. Set C, *to make it theirs*, is the last set of 1.4
not built: **1.4.5, themes and app icons**, and **1.4.8, a vessel library**. Roadmap §8 names its rule rows:
`60-design-system` for a second set of `Aurora` colours, and `20-state`, `25-shared-storage`, `10-architecture` and
`50-views` for the library. 1.4.11 still waits for its own design. Nothing a free user can do today moves behind
set C (*The Premium line*, roadmap §1).

## 2. What exists today (measured)

**Colour.**
- `enum Aurora` (`WaterBuddy/WaterSurface.swift:148–160`): five `static let` colours — `top`, `bottom`, `blue`,
  `magenta`, `cyan` — and a computed `gradient`. Main-actor in the app target, by its default isolation
  (`LiquidGlassModifier.swift:356`). Nothing reads `bottom` but `gradient`.
- **`cyan` is the accent**, at about forty sites: the switches and sliders (`SettingsView.swift:267, 351, 677,
  1114`; `VesselSliders.swift:99`), the glyphs on panes (Settings' feature glyphs `:927`, the paywall's
  `PaywallView.swift:301`, Home's streak and *Undo* `HomeView.swift:436, 814`), every met mark (the week card
  `HistoryView.swift:1274`, the month's rings `:1773`, the patterns' bars `:2205, :2314`, the recap's dots
  `RecapCard.swift:157`, the week widget `WeekWidget.swift:214`), the tab bar's active glyph
  (`RootTabView.swift:496`) — and some **text**: the busiest hour (`HistoryView.swift:2187`), an insight's first
  line (`:2818`), the recap's month name (`RecapCard.swift:96`).
- **`top` is the ink and the tint.** The primary surface's label, wash and shade (`LiquidGlassModifier.swift:688,
  700, 716`); the shown day's letter and the opened month day on their white discs (`HistoryView.swift:1227,
  1792`); the recap image's margin (`RecapCard.swift:314`); Apple's glass tint, `systemTintColor`, at 0.64
  (`LiquidGlassModifier.swift:290, 305`); the phone's hand-made scrim at 0.30 / 0.70 / 0.80 (`:350–359`).
- **`blue` and `magenta` are lights**: `AuroraBackground.lights` (`AuroraBackground.swift:98–114`, each light
  drifting to another palette colour), the confetti (`Celebration.swift:64`), the premium rim (`PremiumRim.swift:58`).
  `blue` is also **water**: the falling drop's foot (`PourDrop.swift:101`) and every watch-face gauge
  (`WristFaceView.swift:66, 78, 108, 126, 178`). The vessel's glow is `cyan` (`HomeView.swift:1250`); the waves are
  two literals (`WaterSurface.swift:37–48`).
- **Five values are derived from today's palette.** `systemTintOpacity` 0.64, the first rung with room on iOS 27.0,
  whose glass is the lightest (`docs/DESIGN.md`, *The look, measured*); the scrims, on iOS 18.6; `Base.archived` —
  translucent white 0.24 at 0.5 from the dark ultra-thin material recipe, opaque (0.22, 0.19, 0.36) "composited down
  over the aurora", with no arithmetic recorded (`LiquidGlassModifier.swift:150–166`); `RecapCard.tileFill`, a
  least-squares fit to 27.0 renders over `Aurora.gradient` (`RecapCard.swift:251–274`); the tab bar's `BarShade`
  ≥ 0.25 (`RootTabView.swift:418`). `WidgetCardBackdrop`'s `saturation(1.1)` is the recipe's own boost.
- **Tests pin them**: `LiquidGlassTests.swift:208, 214, 244, 315, 330`, `RecapImageTests.swift:68`,
  `AuroraBackgroundTests.swift:43, 53`, `CelebrationTests.swift:84`, `RootTabViewTests.swift:100`.
- **The margins are thin.** The week widget's goal line clears 3 by 0.06; Home's Bottle amount, beside its glyphs,
  clears 4.5 by 0.09; Settings' Cup glyph clears 3 by 0.10; the recap's unmet ring by 0.10; the paywall's
  *BEST VALUE* by 0.11. Several lines on the aurora's clean ground are already under 4.5, for the owner's ruling
  (#95). Blue and magenta glyphs read 1.5–1.7 even on frosted glass, which is why only white and `cyan` mark glass.
- **The measuring rig was thrown away.** The probes lived in a scratch copy and their scripts were not kept
  (`docs/DESIGN.md` L1730). The method: a frame every 3 s for a minute, the worst frame; the lightest ground (the
  magenta lobe, a card's lit sheen); ink boxes from the accessibility tree, other ink masked; clean ground recorded
  beside the in-force yardstick. The iOS 26.5 runtime is gone from this Mac (#230). The Home Screen widget's pairs
  on its pane have never been recorded.
- **The icon.** `Tools/GenerateAppIcon.swift` draws three 1024² PNGs — light, dark (every colour × 0.52) and tinted
  (grey × 0.85) — from its own transcription of `Aurora` (`:44–50`) into `AppIcon.appiconset`; the watch's icon is a
  hand-kept copy of the light one (#34). No alternate icon exists; `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`
  (`project.pbxproj:911, 951`). The app is dark only.

**Vessels.**
- `Key.servings`: three amounts, positional — Cup, Glass, Bottle — absent meaning `[150, 250, 500]`, the whole
  triple discarded on any anomaly (`DataManager.swift:135–144, 2021–2027`). `usualSlot = 1` (`:2061`),
  `usualServing(in:)` (`:2052`).
- Names and glyphs are compiled in: `vesselSlots` (`WaterSurface.swift:162–172`). The three names are translated in
  the app's and the watch's catalogues alone; `watchSharedKeys` compares them.
- **Home identifies a vessel by its name key** (`HomeView.swift:85`), and so do `poured[…]`, `PourFlight.slot` and
  `PourPlace.disc` (`:991–993`, `PourDrop.swift:60–65`). Two vessels with one name would collide. Each name is drawn
  under its disc on one line, on the aurora, through `legibleOnBackdrop()` (`HomeView.swift:899–905`).
- Settings' *Quick-add vessels* (`SettingsView.swift:1202–1265`) — free — edits the three on `VesselSliders`,
  50–1,000 ml by 50 (`HistoryView.servingRange`). Its note, *The Glass is the one your widget, Siri and Control
  Center log.*, leaves out the reminder's button and the watch (#136). The welcome's vessels step reuses the sliders.
- History infers a serving's vessel from its amount among Home's three (`HistoryView.swift:151–154`) — drawn, never
  spoken; its serving sheet offers Home's three (`:3384–3454`); `startingAmount: manager.servings[1]` spells the
  slot as a literal (`:500`, #104).
- Insights suggest the Home vessel nearest the gap (`DataManager.swift:3327–3341`) and hand its name to Apple's model
  (`InsightWriter.swift:150–158`); a note is drawn only if every number in it is a fact's (`:120–138`).
- **The one-tap doors.** The widgets' buttons draw a `plus` or an amount, never a glyph or a name
  (`WaterBuddyWidget.swift:486–526`). Control Center draws `vesselSlots[usualSlot].symbol`, compiled in
  (`LogWaterControl.swift:49`); so does the reminder's *Log a Glass* (`NotificationManager.swift:237`). Siri's tile
  is a literal `mug.fill` (`WaterBuddyShortcuts.swift:35`).
- **The watch** receives the three amounts and nothing else about vessels (`WristMirror.servings`,
  `DataManager.swift:3852–3854`) and draws its own compiled names and glyphs (`WristView.swift:255–259`), identified
  by name key. A new mirror field must be optional: `schemaVersion` must match exactly, so bumping it would make every
  older watch drop every new mirror (`:3886, 3997`). `phoneDayEnd` is the precedent.

**Premium.**
- `PremiumSet` (`PremiumSet.swift:19–133`): `understand`, `coached`, `portable`. Each `Feature` has a glyph, a title,
  a line and an optional Settings caption; `isOnSale` per set. One purchase unlocks every set. The paywall lists every
  on-sale set's rows in declaration order (`PaywallView.swift:271–314`) — eight today.
- Set B's lapse: no Premium bit stored; the setters know nothing of Premium; locked rows draw `lock.fill`, speak
  *Premium* and open the paywall; turning an extra off is free (`SettingsView.swift:561–703`).
- The foundation spec imagined "a derived key written by `DataManager`" for themes, so the widget and the watch could
  know Premium (`2026-10-21-premium-foundation-design.md` §3.3). Set B's lapse ruling removes the need (D5).

## 3. The design

### 3.1 What the user sees

**Themes (1.4.5).** Settings gains an **Appearance** card above *Language*. Its first row, *Theme*, is five round
swatches — Aurora, Lagoon, Dusk, Midnight, Bloom — each its own sky with its accent, its name under it, the chosen
one ringed. A tap changes the theme at once: the app's sky, lights, glass and accent cross-fade to the new palette,
the Home Screen and week widgets redraw, and the watch app follows at its next sync. The water stays blue (D6). Its
second row, *App icon*, is the five icons in the same order; a tap changes the Home Screen icon, and iOS says so in
its own alert. The theme and the icon are separate choices (D4).

**The vessel library (1.4.8).** Settings' *Quick-add vessels* keeps its three sliders, free for everyone, now showing
Home's own names and glyphs. Under them, a **Your vessels** row opens a sheet:

- *On Home* — the three, left to right. The middle one is marked as **your Glass**: the vessel the widget, Siri,
  Control Center, the reminder's button and the watch's middle button log (D3).
- *More vessels* — up to nine more.
- *Add a vessel* — the sheet's one primary surface.

Tapping a vessel opens its editor: an icon from seven, a name, an amount from 50 ml to 2 litres. A vessel in *More
vessels* can be **put on Home** in place of any of the three; the one it replaces moves to *More vessels*. The
standard three — Cup, Glass and Bottle — always belong to the library, under their own translated names, and cannot
be deleted (D10). The card's note becomes *The middle one is your Glass: your widget, Siri, Control Center, reminders
and your watch log it.*

**A free user** sees the four new swatches and icons locked, and the *Your vessels* row locked; each opens the
paywall. Home and the one-tap doors are as they are today. The paywall lists set C's three rows after export's.

**A user whose subscription lapses** (D5) keeps what they chose: the theme, the icon and Home's three vessels, which
still log. Choosing again locks — except **Aurora, the standard icon and *Use the standard vessels***, which stay
free: the card offers the last only while Home holds anything but Cup, Glass and Bottle in their own places. Home's
amounts stay editable on the card, as for everyone. The library's other vessels stay stored and come back with
Premium; nothing is deleted.

### 3.2 Decisions

| # | Decision | Status |
|---|---|---|
| D1 | A theme reaches the app, the Home Screen and week widgets, and the watch app. The Lock Screen widget and the Control Center control draw no aurora (rule `60-design-system`), and the watch faces draw water (D6): all three stay as they are | **The owner's** |
| D2 | Four themes beside Aurora — **Lagoon, Dusk, Midnight, Bloom** — with the board's colours (§3.4) as their starting values. A palette's colours are design choices, confirmed on renders in the app with the owner; the values derived from them are measured (D7), never chosen | **The owner's**; "starting values" is this spec's |
| D3 | Any library vessel may stand in Home's middle slot. Every one-tap door logs it; Control Center and the reminder's button draw its glyph. Their words stay *Log a Glass* / *Log Water*: Siri's phrase is registered once with the system and a notification may carry no user value (rule `70-privacy`) — "the Glass" is the middle slot's role | **The owner's**; the wording is this spec's |
| D4 | The icon is its own choice, one per theme, five in all. A theme never changes the icon | **The owner's** |
| D5 | **On a lapse, what was chosen keeps working**: the theme, the icon, Home's three. Choosing again locks; Aurora, the standard icon and *Use the standard vessels* are always free. Nothing about Premium is stored, so the widget and the watch never need to know — the foundation spec's derived key is not built, and `PRIVACY.md`'s *Never stored: whether you have Premium* stands. Set B's D2, and roadmap 1.4.8's own lapse rule | Recommended |
| D6 | **Water is water.** The waves, the falling drop, the vessel's glow and the watch faces' gauges keep Aurora's colours in every theme. A theme colours the sky, the lights, the glass and the accent | Recommended |
| D7 | **A theme is measured as Aurora was.** Every pair `docs/DESIGN.md` records is measured for each theme on iOS 27.0 and 18.6, on the widgets, and on the watch on watchOS 27.0; every pair reaches its floor, and where Aurora itself is under on clean ground (#95), the theme reads no lower than Aurora. The five derived values — the glass tint, the hand-made scrims, the Reduce Transparency fill, the recap's tile fill, the tab bar's shade — are taken per theme, climbing from Aurora's by the same rungs, adopting the first rung with room. 26.5 is measured when its runtime returns (#230), as every other table will be | Recommended |
| D8 | **The measuring harness is kept** this time: a DEBUG `-WaterBuddyTheme` argument, a theme census in the capture class the gate already skips, and a measuring script in `Tools/` (§3.9). Five themes cannot be measured by throwaway probes | Recommended |
| D9 | **One key for the theme**, `Key.theme`: the theme's code, absent meaning Aurora — choosing Aurora removes it, as `.system` removes `Key.language`. Written by the app alone; read by every `DataManager`, by the widget's snapshot, and by the watch through a new optional mirror field. No schema bump | Recommended |
| D10 | **The library.** The standard three — Cup, Glass, Bottle — always belong to it, keep their glyph and translated name, and are never deleted. Up to nine more of the user's own, each an icon from seven, a name of 1–20 characters and an amount. Home shows any three, in any order. Home's three amounts, whichever vessels stand there, stay editable by anyone on the card's sliders, as today | Recommended |
| D11 | **One key for the library**, `Key.vessels`: JSON `{home: [three], more: [up to nine]}`, absent meaning no library was ever made, and created from Home's three on the first library change. **`Key.servings` stays the one-tap doors' read**: every library change writes the library first and `Key.servings` — Home's three amounts — after it; the app's launch heals a `Key.servings` a crash left behind | Recommended |
| D12 | Vessel amounts run **50 ml to 2,000 ml by 50** on the editor and on the card's sliders (today 1,000) — a library is where a 1.2-litre bottle lives. History's serving sheet already widens to every vessel (`HistoryView.sliderBounds`) | Recommended |
| D13 | **Seven icons**, each on iOS 17 and watchOS 26: `cup.and.saucer.fill`, `mug.fill`, `waterbottle.fill`, `wineglass.fill`, `takeoutbag.and.cup.and.straw.fill`, `flask.fill`, `drop.fill` — read from this Mac's SF Symbols availability table. `cup.and.heat.waves.fill` needs iOS 18 and is left out | Recommended |
| D14 | Settings' vessels card keeps its sliders for everyone and gains the *Your vessels* row; *Use the standard vessels* appears for a locked holder whose Home is anything but Cup, Glass and Bottle in their own places. The note is reworded to name the reminder's button and the watch, closing #136's omission | Recommended |
| D15 | The library is a sheet from that row, and a vessel's editor a sheet from the library. Changes save as they are made, as set B's schedule sheet does; a new vessel is added by its editor's *Add to your vessels* | Recommended |
| D16 | Settings gains an **Appearance** card above *Language*: *Theme* and *App icon*, five choices each | Recommended |
| D17 | **Home's vessels are identified by slot**, never by name, on the phone and on the watch: names may repeat now | Recommended |
| D18 | **The mirror carries Home's three vessels** — each an icon's code and the user's name, or none for a standard vessel — as an optional field, and the theme's code as another. An older watch app ignores both and draws Aurora with the standard names and the new amounts until it is updated | Recommended |
| D19 | **The snapshot carries Home's middle glyph**, for the Control Center control. The reminder's category takes the glyph from the app, and the app registers it again when the middle vessel's glyph changes. Siri's tile stays `mug.fill`: an App Shortcut's image is static | Recommended |
| D20 | A user's vessel name may reach Apple's model as the suggested vessel's name, as a standard name does today. A digit in it can make the model's note decline; the app's own sentence then stands. No change to `InsightWriter` | Recommended |
| D21 | **Alternate icons are made as the primary is**: asset-catalogue icon sets in three appearances, written by the extended generator with a preview image each, listed in `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`. Apple's newest sample asks for Icon Composer files, for iOS 18 and later; the app's floor is 17 and its primary icon is an icon set. Moving the whole family to Icon Composer is not this spec's | Recommended |
| D22 | Set C is sold as one set, `PremiumSet.personal`, with three paywall rows after export's — *Themes*, *App icons*, *Your vessels* — and no Settings caption (set B's D10). Not on sale until its last step. Built on `feature/set-c` from `main`, in five steps (§3.15), each gated and committed by the owner; it ships in the version after 1.4.1 | Recommended |

### 3.3 Approaches considered

**Themes.**
- **A — a stored choice and a palette value read through the environment (chosen).** `AppTheme` is stored like the
  language; `Aurora` becomes a value with one instance per theme; every root injects the theme beside the strings
  and the locale; each derived value is a function of the theme, beside today's number and its DocC.
- **B — a global current palette** that `Aurora.top` reads. Rejected: nonisolated global mutable state (rule
  `43-concurrency`), and a widget's archive is drawn from a snapshot, not from a process-wide variable.
- **C — asset-catalogue colour sets.** Rejected: a colour set's appearances are light, dark and high contrast, not
  themes; the widget extension and the watch would each need a catalogue; and five of a theme's values are opacities
  and fits, not colours.

**The library.**
- **A — one key for the library, `Key.servings` kept as the doors' read (chosen).** One write holds every vessel; the
  doors, the snapshot and the mirror keep reading what they read today.
- **B — the amounts in `Key.servings`, the faces and the rest in a second key.** A swap writes two authored values,
  and a crash between them leaves a face wearing another vessel's amount. Rejected.
- **C — a fixed catalogue of named vessels, no names typed.** Simpler and fully translated, but roadmap §8 names
  vessels "named by the user". Rejected.

### 3.4 The palettes

A theme is five colours. **`top`** is the sky's head: the primary surface's ink, the selection discs' ink, Apple's
glass tint and the phone's scrim. **`bottom`** is the sky's foot. **`first`** and **`second`** are the two broad
lights — Aurora's blue and magenta — and the confetti and the premium rim. **`accent`** is the third light and every
mark, switch and accent line — Aurora's cyan. The lights keep Aurora's geometry, opacities and drift, each crossing
to another colour of its own palette (`first` → `accent`, `second` → `first`, `accent` → `second`).

| Theme | `top` | `bottom` | `first` | `second` | `accent` |
|---|---|---|---|---|---|
| Aurora (default) | `#0A2185` (0.04, 0.13, 0.52) | `#5C1A9E` (0.36, 0.10, 0.62) | `#008CFF` (0.00, 0.55, 1.00) | `#C740FA` (0.78, 0.25, 0.98) | `#00D9D9` (0.00, 0.85, 0.85) |
| Lagoon | `#032642` (0.01, 0.15, 0.26) | `#004554` (0.00, 0.27, 0.33) | `#0099C7` (0.00, 0.60, 0.78) | `#0D9480` (0.05, 0.58, 0.50) | `#40E0BF` (0.25, 0.88, 0.75) |
| Dusk | `#2B0A33` (0.17, 0.04, 0.20) | `#6B1738` (0.42, 0.09, 0.22) | `#F26138` (0.95, 0.38, 0.22) | `#E63880` (0.90, 0.22, 0.50) | `#FFBD4C` (1.00, 0.74, 0.30) |
| Midnight | `#0A0D17` (0.04, 0.05, 0.09) | `#1C1F2E` (0.11, 0.12, 0.18) | `#47619E` (0.28, 0.38, 0.62) | `#6B668C` (0.42, 0.40, 0.55) | `#66D1FF` (0.40, 0.82, 1.00) |
| Bloom | `#33082E` (0.20, 0.03, 0.18) | `#5C0F57` (0.36, 0.06, 0.34) | `#EB4C9E` (0.92, 0.30, 0.62) | `#9E4CF5` (0.62, 0.30, 0.96) | `#FFA8C7` (1.00, 0.66, 0.78) |

**What arithmetic already says** (WCAG relative luminance, sRGB; no render needed, as the tests derive them):

| Theme | `top`'s luminance | Primary label at the shade's foot (floor 7) | `accent`'s luminance |
|---|---|---|---|
| Aurora | 0.028 | 10.59 | 0.546 |
| Lagoon | 0.018 | 12.18 | 0.582 |
| Dusk | 0.010 | 13.68 | 0.582 |
| Midnight | 0.004 | 14.97 | 0.556 |
| Bloom | 0.011 | 13.44 | 0.534 |

The palettes were drawn inside Aurora's envelope: every `top` darker than Aurora's, so its tinted glass starts no
lighter; every light within about 0.05 of the luminance of the light it replaces (Midnight's dimmer); every accent at
or above 0.53, near Aurora's 0.546, because the accent is also text (the busiest hour, an insight's first line). That
is a reason to expect them to pass, never a figure: D7 decides. Two things only the owner's eye can settle, on the
rendered app: that each accent reads apart from the unmet days' white — Bloom's blush is the palest — and that each
sky still gives the glass something to blur.

### 3.5 The pieces — themes

**`AppTheme`** — in `DataManager.swift`, beside `AppLanguage`, for its reason: the snapshot and the mirror carry it,
and no seventh shared file is added (rule `40-widget`).

```swift
nonisolated enum AppTheme: String, CaseIterable, Sendable {
    case aurora, lagoon, dusk, midnight, bloom
    init(code: String?)        // nil → .aurora; an unknown code → .aurora, said under #if DEBUG
    var code: String? { get }  // nil for .aurora: absence carries meaning (D9)
    var nameKey: String { get }
}
```

**`DataManager.theme`** — an observed property over `Key.theme`, read in `init` and `loadFromStore()` like the
language. Its setter writes the code, or removes the key for Aurora, then rings the widget doorbell and publishes to
the wrist. It reschedules nothing: a theme moves no reminder. It knows nothing of Premium (D5). `snapshot(defaults:
calendar:now:)` resolves it into **`WaterSnapshot.theme`** (defaulted, so the memberwise callers build); the mirror
composer writes **`WristMirror.themeCode`** (optional).

**`Aurora`** — in `WaterSurface.swift`, becomes a value:

```swift
nonisolated struct Aurora: Equatable, Sendable {
    let top: Color, bottom: Color, first: Color, second: Color, accent: Color
    var gradient: LinearGradient { get }
    static let classic: Aurora   // today's five, unchanged — and the water's colours in every theme (D6)
    static let lagoon: Aurora, dusk: Aurora, midnight: Aurora, bloom: Aurora
}
extension AppTheme { var palette: Aurora { get } }   // §6 R1
```

**The environment.** `EnvironmentValues.theme` (stored, default `.aurora`) and `EnvironmentValues.aurora` (computed
from it, through `AppTheme.palette`). Injected at every root that draws the aurora, beside `\.strings` and `\.locale` — the app's `RootView`
(`WaterBuddyApp.swift:259`), the two widget roots that draw it (`WaterBuddyWidget.swift:160`, `WeekWidget.swift:67`),
the watch's root (`WaterBuddyWatchApp.swift:74`) and the recap's renderer (`RecapCard.swift:290`). The Lock Screen
widget's root and the watch faces' take none. A view reads `@Environment(\.aurora) private var aurora` and draws `aurora.accent`
where it drew `Aurora.cyan`, `aurora.top` where it drew `Aurora.top`, and `aurora.first` / `aurora.second` for the
lights, the confetti and the rim. **Water reads `Aurora.classic`** by name — the drop, the glow, the faces' gauges —
which is the one reason a view may name a palette.

**The derived values, per theme**, each beside today's number and its DocC, each a function of the theme:
`LiquidGlass.systemTintColor(for:)` (the theme's `top`) and `systemTintOpacity(for:theme:)`;
`LiquidGlass.scrim(density:scheme:base:onPhone:theme:)`; `LiquidGlass.Base.archived(for:)` — the translucent fill
re-derived from the recipe (it stays white 0.24 at 0.5 while every colour of the theme is under the recipe's first
stop), and the opaque fill composited down over the theme's sky. No arithmetic was recorded for Aurora's (0.22, 0.19,
0.36), so the plan first writes one that gives Aurora's back within 2/255 and only then applies it to the other four;
if none does, that is a ruling for the owner before any theme's fill is set. `RecapCard.tileFill(for:)`, fitted per
theme as Aurora's was; `BarShade.opacity(for:)`. Aurora's values are
today's, unchanged. Every other theme starts at Aurora's and keeps a value only once D7's measurement has said so.

**Lights.** `AuroraBackground.lights` becomes `lights(in: Aurora)`, a `nonisolated static func` with today's geometry.
`WidgetAurora` and `WristAurora` read the environment's `aurora`.

**Switching.** The Appearance card sets `manager.theme` — one call into the model (rule `50-views`) — and plays
`Haptics.select`. The root animates the change with `.smooth(duration: 0.4)` scoped to the theme: a tap's one-off
change, not a loop, so it keeps its curve under Reduce Motion; the aurora's lights keep resting under Reduce Motion as
they do today.

**The watch.** `WristModel.theme` comes from `mirror.themeCode`, injected at the watch's root; `WristAurora` and the
watch's glass draw it. The faces draw no aurora and their gauges are water (D6): `WaterBuddyWatchWidget` does not
change.

### 3.6 The pieces — the vessel library

**`VesselGlyph`** — in `WaterSurface.swift`, beside `vesselSlots`, which all three exception sets already compile:

```swift
nonisolated enum VesselGlyph: String, CaseIterable, Codable, Sendable {
    case cup, glass, bottle, wineGlass, takeaway, flask, drop   // D13, in this order
    var symbol: String { get }      // cup.and.saucer.fill, mug.fill, waterbottle.fill, …
    var spokenKey: String { get }   // the editor's buttons: "Cup", "Mug", "Bottle", "Wine glass", …
}
```

`vesselSlots` stays: the standard three's names and glyphs, in order, which a library that was never made draws.

**`Vessel` and `VesselLibrary`** — in `DataManager.swift`, beside `WristMirror`, because the snapshot and the mirror
composer read them:

```swift
nonisolated struct Vessel: Codable, Sendable, Equatable, Identifiable {
    let id: String          // "cup", "glass", "bottle" for the standard three; a UUID's string for the user's
    let glyph: VesselGlyph  // the standard three keep theirs
    let name: String?       // nil for the standard three — translated; 1–20 characters for the user's
    let amount: Int         // 1...maximumDailyIntake on the way in
}
nonisolated struct VesselLibrary: Codable, Sendable, Equatable {
    let home: [Vessel]      // exactly three, positional; home[DataManager.usualSlot] is the Glass
    let more: [Vessel]      // at most nine
}
```

**Validated on the way out, discarded whole on any anomaly** (rule `20-state`'s triple rule): `home.count != 3`;
`more.count > 9`; an id twice; a standard id missing, changed or carrying a name or a foreign glyph; a user's vessel
without a valid name; an amount out of `1...maximumDailyIntake`; a glyph code this build does not know. A discarded
library reads as none — Home's three are the standard ones at `Key.servings`' amounts — and a `#if DEBUG` line says
so; the stored value is left as it is until the next library change rewrites it. A name is trimmed and must hold 1–20
characters, as Swift counts `Character`s, and no line break; it is stored as typed.

**`DataManager`** gains, on its mutation surface (rule `20-state`):
- `vessels: VesselLibrary` — observed, get-only: the stored library, or the standard one built from `servings`.
- `addVessel(glyph:name:amount:) -> String?`, `updateVessel(id:glyph:name:amount:)`, `deleteVessel(id:)` (not a
  standard vessel, not one on Home), `putOnHome(id:slot:)` (the one it replaces moves to *more*, where the incoming one
  stood), `useStandardVessels()` (Cup, Glass and Bottle back to slots 0, 1 and 2, the others to *more*).
- Each change writes `Key.vessels`, **then** `Key.servings` — Home's three amounts — through the `servings` path's
  own side effects: the widget doorbell and the wrist publish. It calls `rescheduleRemindersNow()` only when Home's
  middle glyph changed, so the app registers the reminder's category with its new icon (D19).
- The `servings` setter keeps its contract — three amounts, clamped, guarded, never sorted — and, when a library
  exists, writes the three amounts into Home's vessels first.
- `init`, behind `role.ownsSharedStorage`, heals: a library whose Home amounts differ from `Key.servings` rewrites
  `Key.servings`. Only a crash between the two writes leaves them apart; until the app runs, a widget tap logs the
  amount `Key.servings` holds.
- Neither the library nor `useStandardVessels()` knows Premium (D5). Settings decides who may call what.

**The menu.** `VesselSliders` and the editor offer 50–2,000 ml by 50 (D12), a menu of its own on the view that
offers it, beside `HistoryView.servingRange` (rule `50-views`).

**Home.** `HomeView.Serving` is identified by its **slot** (D17), and `poured`, `PourFlight` and `PourPlace` key by
it. `servings(amounts:)` becomes `servings(library:)`, joining Home's three vessels to their presentation:
`isUsual` stays `slot == usualSlot`. A name is drawn on one line, scaled to 0.8 and then cut at its end; VoiceOver
speaks it whole.

**History** infers from Home's three as today, drawing their names; `startingAmount` reads `usualSlot`, closing #104.
**Insights** suggest among Home's three as today (D20).

**The one-tap doors.** `WaterSnapshot.servingGlyph` (defaulted to `vesselSlots[usualSlot].symbol`) carries Home's
middle glyph; `LogWaterControl` draws it. `NotificationManager.reminderCategory(in:glyph:)` takes the glyph, its
bundle and glyph never defaulted; `DataManager.requestReminderReschedule` passes Home's middle glyph. `AddWaterIntent`,
`LogServingIntent` and the reminder's press log `usualServing(in:)` as today.

**The watch.** `WristMirror.vessels: [WristVessel]?` — Home's three, positional, each `{ glyph: String, name:
String? }`, a glyph code and the user's name, or `nil` for a standard vessel, whose name the watch translates from its
own catalogue in the phone's language. `WristView` draws them, identified by slot; an unknown glyph code draws the
slot's standard glyph. `isNews` compares the new fields with no change of its own.

### 3.7 The pieces — app icons

- **The generator.** `Tools/GenerateAppIcon.swift` gains the four palettes, transcribed beside Aurora's as today and
  pointing at `WaterSurface.swift`, and writes, for each theme, `AppIcon-<Theme>.appiconset` with its light, dark and
  tinted 1024² images, and a 180-px `IconPreview-<Theme>.imageset` for the picker — Aurora's preview included. The
  drawing does not change: the drop on the theme's sky, × 0.52 for dark, grey × 0.85 for tinted. It writes neither the
  watch's icon nor any other catalogue.
- **The project.** `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES = "AppIcon-Lagoon AppIcon-Dusk AppIcon-Midnight
  AppIcon-Bloom"` on the app target, Debug and Release. Xcode writes `CFBundleAlternateIcons`; nobody edits the
  Info.plist (`GENERATE_INFOPLIST_FILE = YES`).
- **The seam.** `AppIconSwitcher`, app-only: a struct of closures — the current name, whether icons can change, and
  the change itself — built by `static func live()`, each closure reaching `UIApplication.shared` in its own body
  (`ReminderScheduler`'s shape). `AppTheme.iconName` names each icon, `nil` for Aurora's — the primary.
- **Nothing is stored.** iOS keeps the choice; the card reads `alternateIconName` each time it appears. A failed
  change leaves the selection as it was, says so under `#if DEBUG`, and is not retried.
- **The watch** keeps one icon: watchOS has no alternate icons.

### 3.8 The Appearance card and the library sheet

- **Appearance** (D16): *Theme* — five swatches, each a 44-pt-or-larger button: a circle of the theme's gradient, its
  accent's light, its name under it; the chosen one ringed by `LiquidGlass.Selection`'s ring, never colour alone.
  *App icon* — five preview images in the same order. Each row is `ViewThatFits(in: .horizontal) { row;
  ScrollView(.horizontal) { row } }` (rule `65-accessibility`). Locked choices carry `lock.fill` and open the paywall
  from `.settings`. Drawn where `PremiumAccess.gate` is not `.hidden`, as set B's rows are.
- **Your vessels** (D15): a sheet presented with `.sheet(item:)` from the card's row, its heading *Your vessels*, its
  close *Done*, its content arriving through `Landing`. *On Home*, *More vessels*, *Add a vessel*. At twelve vessels
  *Add a vessel* is dimmed and its line says *Twelve is the most.*
- **The editor**: a second `.sheet(item:)`, handed the vessel being edited — or a new one — through `init`. Seven icon
  buttons, a name field, an amount slider; *Put on Home* (three choices, *In place of …* each Home vessel's name) and
  *Delete* for a vessel in *More vessels*; *Add to your vessels* for a new one. A standard vessel's editor offers its
  amount alone.
- No `NavigationStack` (rule `50-views`): two sheets, each with one route to it.

### 3.9 Measuring a theme (D7, D8)

1. **Render.** `-WaterBuddyTheme <code>`, read by a DEBUG build beside `-WaterBuddyFreshStart` alone, sets the theme
   through its setter in the fresh start's own suite. A theme census — a method in `AppStoreScreenshotUITests`, which
   the gate already skips — launches with it, `-WaterBuddyStoreSample` and `-WaterBuddyPremiumHeld`, all beside
   `-WaterBuddyFreshStart`, and captures
   every screen `docs/DESIGN.md` measures, set C's new ones and the paywall: a frame every 3 s for a minute on each
   screen that stands on the aurora, with each measured element's frame from the accessibility tree written beside it.
   iPhone 17 on iOS 27.0 for Apple's glass, iPhone 16 on 18.6 for the hand-made stack.
2. **The widgets.** Placed by hand once on each phone; the census then sets each theme, goes to the Home Screen and
   captures it. Their backgrounds are still, so one frame each.
3. **The watch.** On watchOS 27.0, both sizes, after the mirror carrying the theme arrives: one frame each. If the
   watch needs another rung than the phone for a theme, the value takes `onPhone`, as the scrim does — never one
   estimated from the other.
4. **Read.** `Tools/MeasureContrast.swift`, kept, run with `swift`, reads the captures and frames: ink from the
   element's frame, other ink masked, the worst pixel of the ground, the in-force yardstick beside clean ground —
   the method `docs/DESIGN.md` records, now in one place.
5. **Climb.** A pair under its floor moves its derived value one rung — the tint by 0.04, a scrim by 0.05 — until
   every pair passes; the value adopted is one rung past the first that passes, as 0.64 was (`docs/DESIGN.md`, #128).
   A theme that cannot pass at any rung gets its lights dimmed, as a ruling recorded for the owner; the floor never
   moves.
6. **Record.** One table per theme in `docs/DESIGN.md`, Aurora's taken again as the control — which also records the
   Home Screen widget's pairs for the first time. Each derived value's test cites its table.

### 3.10 Failures

- An unknown `Key.theme` code reads as Aurora; a corrupt `Key.vessels` reads as no library. Each says so under
  `#if DEBUG`, and neither is written back.
- A crash between `Key.vessels` and `Key.servings` leaves `Key.servings` stale until the app's next launch heals it;
  the extension never heals (rule `25-shared-storage`).
- A phone that predates set C sends no theme and no vessels: the watch draws Aurora and the standard names. An older
  watch app ignores both fields.
- `setAlternateIconName` failing leaves the icon and the selection as they were.
- A widget reading a theme from a newer build cannot happen: the app and its extension ship together.

**What does not change.** A serving records no vessel and no theme: `WaterLog` keeps its three properties, and the
export, Apple Health and the history read the same rows. Every way of logging is free and logs the middle slot's
amount (rule `20-state`). The welcome draws Aurora and the standard three: nobody has chosen before setup. The Lock
Screen widget, Control Center's title, Siri's phrases and tile, a reminder's words and the watch faces are as they
are. No new framework, entitlement, permission or shared file.

### 3.11 Concurrency

`AppTheme`, `Aurora`, `VesselGlyph`, `Vessel`, `VesselLibrary` and `WristVessel` are `nonisolated` and `Sendable`;
the five palettes are `nonisolated static let`. The derived-value functions and `AuroraBackground.lights(in:)` are
`nonisolated static func`s taking the theme as a parameter (rule `43-concurrency`). `AppIconSwitcher`'s closures are
`@MainActor`, as `UIApplication` is. The new pure suites are compile-time canaries and stay off the main actor.

### 3.12 Accessibility, words, privacy

**Accessibility.** Each swatch and icon is one button: label the theme's name (*Lagoon icon* for an icon),
`.isSelected` on the chosen one, value *Premium* and hint *Opens Premium* while locked. Each library row is one
button: label the vessel's name, value its amount in millilitres, the middle one's hint *Your Glass*. Each of the
editor's icons is one button, label its `spokenKey`, `.isSelected` on the chosen; the name field's label is *Name*;
the slider speaks the vessel's name and millilitres (rule `65-accessibility`). Home's and the watch's buttons say the
user's name in their existing sentence. Every theme is measured with Increase Contrast and under Reduce Transparency,
whose fill is the theme's own.

**Words**, in English, Russian and Uzbek, the Russian and Uzbek drafted for the owner's sweep as set B's were (#207):
the five theme names; *Appearance*, *Theme*, *App icon*; *Your vessels*, *On Home*, *More vessels*, *Add a vessel*,
*Add to your vessels*, *Put on Home*, *In place of %1$@*, *Delete*, *Name*, *Amount*, *Twelve is the most.*, *Use the
standard vessels*, *Your Glass*; the seven icons' spoken names; the reworded note (D14); the paywall's three rows. The
watch catalogue needs nothing new: a user's name arrives as text, and the standard names are there already.

**Privacy** (rule `70-privacy`, `PRIVACY.md`). The iPhone stores two more things: the chosen theme, and the vessels —
each one's icon, the name the user typed and its amount. The Watch's copy gains the theme and Home's three vessels'
icons and names. A vessel's name is the user's own words: it is drawn in the app and on the Watch, spoken by
VoiceOver, and may reach Apple's on-device model as the suggested vessel's name (D20); it never reaches a
notification, a widget, Siri, Control Center, the export or the recap's image. The app icon is iOS's to keep, and the
app stores nothing about it. No framework, entitlement or permission is added; the privacy label stays *Data Not
Collected*. `PRIVACY.md` and `Tools/PrivacyPolicy.html` change with set C's last step, before it is on sale.

### 3.13 What it amends in the rules (typed unstaged, for the owner, before any code)

| File | What changes |
|---|---|
| `60-design-system` | *Colour*: a theme is a palette of five colours; every colour comes from the theme's `Aurora`, read from the environment; water keeps `Aurora.classic` in every theme; a theme ships only with its measured table. *Glass*: the tint colour is the theme's `top` and its opacity is measured per theme; the scrim and `Base.archived` are per theme. *The primary surface*: its ink is the theme's `top`. The recap's `tileFill` is fitted per theme. *Icons*: generated per theme, three appearances each. The watch face unchanged |
| `20-state` | The mutation surface gains `theme` and the library's five changes; the library first, `Key.servings` after; the whole library discarded on any anomaly; the standard three never deleted; `vessels` get-only |
| `25-shared-storage` | `Key.theme` and `Key.vessels`: what their absence means, who writes and who reads; the heal; the watch's wire gains the theme and Home's three vessels |
| `10-architecture` | Sixteen phone keys; themes and the library in *The rulings*; still six shared files |
| `50-views` | The theme injected at every root with the strings and the locale; `aurora` read from the environment, `Aurora.classic` named only for water; Home's vessels identified by slot; the vessels' menu; the Appearance card and the two sheets |
| `65-accessibility` | The swatches, the icons, the library's rows, the editor's icons and field |
| `70-privacy` | What is stored and sent to the Watch; where a vessel's name may and may not go; alternate icons store nothing and ask nothing |
| `40-widget` | The snapshot carries the theme and Home's middle glyph; the widgets draw the theme; the control draws the snapshot's glyph |
| `80-notifications` | The button's icon is Home's middle glyph, handed to `reminderCategory(in:glyph:)`; a library change that moves that glyph reschedules |
| `15-project` | The alternate icons and their build setting; the new app-only files out of every exception set; no seventh shared file |
| `43-concurrency` | The new nonisolated types and the canary suites |
| `85-testing` | `-WaterBuddyTheme`, the theme census, set C's UI test class; the by-hand checks for themes, icons and the library |
| `CLAUDE.md` | The key counts, and themes and the library in *Architecture* |

### 3.14 Testing, first

Every suite below is written and seen red before its code (rule `85-testing`).

- **Pure, off the main actor** (canaries): `AppThemeTests` — codes, absence, an unknown code, the names in every
  language; `AuroraPaletteTests` — for every theme, the primary label at 7:1 or more at the shade's foot and pressed,
  the selection discs' ink at 7:1, every light painted from its own palette and changing colour, the accent the third
  light, water `Aurora.classic` in every theme; `VesselLibraryTests` — every anomaly discards the whole library, the
  standard three present once, nine at most, names trimmed and bounded, *put on Home* swaps, *use the standard
  vessels* restores, Home's amounts are what `Key.servings` would hold; `VesselGlyphTests` — codes stable, every
  symbol resolves on the running system (the watch suite too).
- **`DataManager`**: the theme's setter (writes, removes for Aurora, rings once, publishes, reschedules nothing); every
  library change (the order of the two writes, one doorbell, the publish, the reschedule only for a new middle glyph);
  the `servings` setter with a library; the heal, app only; `Key.all` and `everyKeyTheProductWritesIsOnTheRoster` with
  the two keys; the read-path tripwires untouched by a snapshot carrying both.
- **The snapshot and the mirror**: `theme` and `servingGlyph` resolved and defaulted; a mirror without the new fields
  still decodes; `isNews`' field list pin extended.
- **Per theme**, from D7's tables: the tint rung, the scrims, the archived fills, the tile fill within 2/255 of the
  measured glass, the bar shade.
- **Notifications**: the category's icon is the glyph handed in.
- **Localization**: every new key in every language; the note still names the Glass by its own name.
- **UI** (`AppearanceUITests`, new, fresh start with `-WaterBuddyPremiumHeld`): each swatch and icon is one element,
  selection follows a tap; a vessel added and put on Home changes Home's button; a lapsed holder's choices lock and
  *Use the standard vessels* restores Cup, Glass and Bottle.
- **The watch**: the row from the mirror's vessels by slot, a user's name and a standard one; the theme from the mirror.

### 3.15 Build order

1. **The library** — the model, Settings' card and both sheets, Home, History, the snapshot's glyph, the control, the
   reminder's icon, the watch's wire and row. Its new pairs measured on Aurora.
2. **Themes in code** — `AppTheme`, `Aurora` as a value, the environment, every call site, the widgets, the watch,
   `-WaterBuddyTheme` — every theme's derived values set to Aurora's.
3. **The measurement** — the harness kept (§3.9), five themes measured, the values climbed and recorded.
4. **The icons** — the generator, the catalogue, the build setting, the picker.
5. **On sale** — `PremiumSet.personal`, the paywall's rows, `PRIVACY.md` and its page, the docs, the final review.

Each step ends gated and staged for the owner's `/commit`.

## 4. Verification

- **The gate**, five invocations (rule `85-testing`), and the warning baseline compared by file and message against a
  clean build of `main`. The UI suite on 26.5 waits for its runtime (#230).
- **By hand**: each theme on Home, History, Settings, the paywall and the recap's image; the widgets placed, in each
  theme, and the week widget tapped into History; the control's glyph and the reminder's button following the middle
  vessel; the watch app in each theme, with a user's names on its row; each icon in light, dark and tinted, and in
  iOS 26's clear mode, on 27.0 and 18.6 — and from a TestFlight install on the owner's iPhone, because a forum report
  says an alternate icon's dark and tinted forms do not survive distribution; VoiceOver over the Appearance card, the
  library and Home's renamed buttons.

## 5. Open, for the owner

- The palettes' final colours, settled on the rendered app with D7's tables — first Bloom's blush against white.
- The Russian and Uzbek words (§3.12), and the note's new wording in all three languages (D14).
- Whether a later store page shows a theme: the release's own design, not this one.

## 6. Refinements made while planning (2026-11-22)

Written while the plan, `docs/superpowers/plans/2026-11-22-set-c.md`, was drafted; none changes a decision.

- **R1 — the palette's accessor is `AppTheme.palette`**, not `aurora` as §3.5's sketch named it: an instance member
  named like the case `.aurora` is a redeclaration Swift may refuse. `EnvironmentValues.aurora` keeps its name.
- **R2 — the archived opaque fill's arithmetic is not yet known.** The first candidate — the archived frosted stack
  composited over the mean of Aurora's two sky colours — gives `[55, 48, 87]` against the recorded `[56, 48, 92]`
  (blue 5/255 off). The plan tries two more skies, the rendered widget's and the app's at rest, and stops for the
  owner's ruling if none lands within 2/255 (§3.5 already said so).
- **R3 — each theme's recap tile fill is fitted with a probe in a scratch copy of the tree**, not kept, exactly as
  Aurora's was on 2026-10-25. §3.9's kept harness is the census and the script; a probe that draws flat panes over a
  bare gradient would be a new DEBUG screen and a new rule line for one derivation a theme.
- **R4 — the theme reaches the test runner as `TEST_RUNNER_WATERBUDDY_THEME`**, which `xcodebuild` hands the census
  as `WATERBUDDY_THEME`; the app itself reads only `-WaterBuddyTheme`, as §3.9 says. A census run also takes one
  group of screens (`TEST_RUNNER_WATERBUDDY_SCREENS`), at most three sweeps, after one `build-for-testing`: every
  command ends inside 600 s, and none shuts down another project's simulator (the parent session's word, 2026-11-22).
- **R5 — `AppTheme`'s preview images are named by the theme's code, capitalised** (`IconPreview-Lagoon`), and the
  alternate icon sets the same way (`AppIcon-Lagoon`), so one rule names both.
