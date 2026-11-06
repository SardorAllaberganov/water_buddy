# Framed store screenshots — design

*2026-11-06. Release 1.4's iPhone set, framed for the App Store the way the owner's three references are.*

> **Since the owner's merge (2026-11-06, evening)**, `AppStore/` is the one store folder. The raw captures live in
> `AppStore/screenshots/captures/iPhone-6.9/`, and the framed set is written straight into
> `AppStore/screenshots/iPhone-6.9/` under its upload names. Where §6, §7 and §9 below name
> `Screenshots/en-US/…` or a copy into `AppStore/1.4/`, read these paths instead; there is no copy step.

## 1. What, and why

The owner, 2026-11-06: *"make this kind of ASO screenshots for the current version of the app"*, pointing at
three Dribbble sets — an AI photo editor's (orange), a tarot app's (violet, clouds running across the panels)
and a vitamin-D wellness app's (off-white). They share one pattern:

- a two-line headline at the top, one word in an accent colour;
- the real screen in a phone frame, the bottom of the phone cropped by the canvas;
- one piece of that screen lifted out, larger, with a shadow, overlapping the phone's edge;
- a brand-coloured background, in the tarot set continuous from one panel to the next.

Today's store set is **raw**: the screen as the simulator draws it, no frame and no headline (the store
page's spec, `2026-10-25-store-page-design.md` §1, from the owner's rulings of 2026-10-17 and 2026-10-18).
**This supersedes that for the ten iPhone shots.** The raw captures stay exactly as they are and become the
framing's input; nothing about how they are taken changes.

## 2. Rulings

The owner's, 2026-11-06:

- **F1. The look is the aurora, flowing.** The app's own aurora, deeper and brighter than the screens, with
  its lights running continuously from shot to shot, white type and one word in cyan.
- **F2. Shot 1 leads with *One tap. Watch it fill.*** — the product page header's phrase, over Home — with a
  small *No account · No cloud* line under it.

Taken as recommended (the owner's standing instruction for follow-ups, ledgered here):

- **F3. An HTML page rendered by headless Chrome** (§3), as `Tools/ProductPageHeader.html` already is.
- **F4. Every lifted-out piece is a crop of the same capture**, shown larger. Nothing is redrawn, retouched
  or invented, so no shot can show a screen the app does not draw.
- **F5. The six Premium shots carry a *Premium* tag** above the headline. App Review Guideline 2.3.2: when
  screenshots show features that need a purchase, the listing must make that clear.
- **F6. No badge says anything that is not true.** The references' *1M+ downloads* laurels have no WaterBuddy
  equivalent, so there are none. No price, and no *Free*, appears in any shot (Guideline 2.3.7 keeps pricing out
  of metadata; the header's 2026-10-13 reasoning about *Never pay to log water* holds here too).
- **F7. The ten shots, their order and their captures are unchanged** (release 1.4's spec §6.2, D3). The watch
  shot stays raw and the product page header is untouched: neither is part of this.
- **F8. The phone frame is drawn, not Apple's.** A plain dark frame with a Dynamic Island, in CSS. Apple's
  product bezels come from Apple Design Resources behind a licence; using them would mean downloading and
  accepting terms, which is the owner's call, not a default.
- **F9. English only**, as the store set already is.

## 3. Approach

**Chosen — one HTML page and one script.** `Tools/StoreScreenshots.html` lays out a shot at 660 × 1434 CSS px;
Chrome renders it at 2× to exactly 1320 × 2868, the 6.9″ size App Store Connect scales down for every smaller
iPhone. `Tools/FrameScreenshots.sh` renders the ten in turn. The header was made this way and passed upload, the
type and gradients are the browser's, and changing a headline is one line.

Rejected:

- **A Swift script drawing with SwiftUI's `ImageRenderer`** (`swift Tools/FrameScreenshots.swift`). No browser
  needed, but text layout, gradients and masks are several times the code, and every change is a compile.
- **Figma or similar, by hand.** The owner's time, ten times over, and redone whenever a capture changes.

## 4. The page

One file, in no target (rule `15-project`'s `Tools/`). `?shot=<slug>` draws one shot — `01-home` …
`12-export`, the capture's own names — and nothing else is on the page.

**The canvas.** Each shot is a 660-px-wide window onto one strip ten shots wide (6,600 CSS px), so a light
that starts near one shot's right edge carries on into the next — F1. The strip is `Aurora.top` (`#0A2185`) to
`Aurora.bottom` (`#5C1A9E`) at the header's 160°, with soft lights of `Aurora.blue` (`#008CFF`),
`Aurora.magenta` (`#C740FA`) and `Aurora.cyan` (`#00D9D9`) placed along it, several straddling a seam. Along
the bottom runs one water wave behind the phone, the header's own wave and gradient (`#3D9BFF` → `#0B46C9`),
continuous across the ten. The hex values are the tokens in `WaterSurface.swift`'s `Aurora`, copied, as the
header copies them.

**The headline.** SF Pro Rounded, loaded from `/System/Library/Fonts/SFNSRounded.ttf` as the header does,
heavy, about 60 px, white, centred, two lines broken by hand (§5). The accent word takes the header's cyan
gradient (`#7FF6F6` → `#8FD0FF`). Above it, on Premium shots, a small pill: the sparkle glyph and *Premium*,
its rim the app's Premium rim (cyan, magenta, blue). Under shot 1's headline, a glass pill: *No account · No
cloud*.

**The phone.** The capture, 470 CSS px wide (0.356 of its pixels), its corners rounded to the display's,
inside a 12-px dark frame with a Dynamic Island drawn over the status bar's middle, which the capture leaves
empty. Centred, its top about 400 px down, so the canvas crops its bottom edge. Its status bar is the capture's:
the clock frozen at the run's start (the 2026-10-17 ruling, kept).

**The lifted piece.** One rectangle of the capture, measured in its own pixels, drawn at 1.2× its size on the
phone, nudged toward one edge so it overlaps the frame (left and right alternate down the set), its corners
`LiquidGlass.cornerRadius` (28 pt, 84 px in the capture) scaled to match. It casts the design system's two
shadows: a wide ambient and a tight contact (rule `60-design-system`). Home's piece is the vessel, cut as a
circle and lifted where it stands. The recap's card is turned 3° — the one card that is a picture to share.
Each rectangle lives in the page's table beside its headline, so the crop and its words change together.

**Privacy.** Every figure in a shot is `StoreSample`'s, drawn on the fresh start's throwaway store; no shot
carries the owner's data, and the framing adds no figure of its own.

## 5. The ten

| # | Capture | Headline (accent in bold) | Premium | Lifted out |
|---|---|---|---|---|
| 1 | `01-home` | One tap. / Watch it **fill.** — *No account · No cloud* | | the vessel, as a circle |
| 2 | `03-history` | Your **week,** / day by day | | the *Last 7 days* card |
| 3 | `05-month` | A whole **month** / on one page | ✓ | the month's calendar card |
| 4 | `06-insights` | **Insights** from / your own week | ✓ | *The one thing* pane |
| 5 | `07-patterns` | Learn **when** / you drink | ✓ | the *When you drink* chart |
| 6 | `08-recap` | **Share** / your month | ✓ | the recap card, turned 3° |
| 7 | `11-schedule` | Reminders on / **your hours** | ✓ | the hours and the days, measured Sunday |
| 8 | `12-export` | Your servings, / as a **CSV file** | ✓ | the export card, measured Sunday |
| 9 | `09-goal-setup` | A goal that / **fits** you | | the *Daily goal* card |
| 10 | `10-settings` | Set your own / **serving sizes** | | the *Quick-add vessels* card |

The words are drafts for the owner to change; each is checked against the owner's `humanize` skill before it
is final. A headline names what the screen shows, never more: Insights are decided by the app and only worded
by Apple's on-device model, so no headline calls them AI, and none names Apple Intelligence (the owner's
ruling on #164).

## 6. The script

`bash Tools/FrameScreenshots.sh [out-dir]`, from the repository root:

1. For each of the ten slugs, checks `Screenshots/en-US/iPhone-6.9/<slug>.png` exists and is 1320 × 2868.
   A missing one is reported and skipped; the run then exits non-zero.
2. Renders `Tools/StoreScreenshots.html?shot=<slug>` with headless Chrome — the header's own flags, a
   throwaway `--user-data-dir`, `--allow-file-access-from-files`, `--window-size=660,1434`,
   `--force-device-scale-factor=2` and a virtual-time budget so the capture has loaded — to
   `<out-dir>/<slug>.png`, by default `Screenshots/en-US/Store/iPhone-6.9/`.
3. Reads each output back with `sips`: 1320 × 2868, PNG, no alpha, or the run fails. `swift
   Tools/FlattenPNG.swift` is the fix if Chrome ever writes alpha.

`Tools/VerifyScreenshots.sh` already checks every PNG under `Screenshots/` and keys the 6.9″ sizes on
`/iPhone-6.9/` in the path, so the framed set is checked by the same run as the raw one.

## 7. When

- **Now (6 November): nothing.** This line first planned a preview from the 26 October captures. The owner had
  those deleted the same evening, so the first look also waits for Sunday.
- **Sunday, after phase 2's capture** (release spec §6.3). First the eight measured shots, which the owner sees and
  changes the words and the look on. Then the rest of this step. The two new crops are measured; every rectangle is
  checked against the new captures, since the finish moved some screens; the ten are rendered into
  `Screenshots/en-US/Store/iPhone-6.9/`, read by eye, passed by `VerifyScreenshots.sh` and copied into
  `AppStore/1.4/screenshots/iPhone-6.9/` as `1-home.png` … `10-settings.png`, byte-identical by `shasum` to the
  framed files. This replaces §6.3's copy of the raw ones.

## 8. Proving it

There is nothing for the gate to run: no product file changes. The evidence is:

- each of the ten read by eye at full size: the headline unclipped on two lines, the lifted piece's edges on
  the pane's own edges with no aurora showing inside its corners, the phone's crop clear of anything the
  headline names;
- the script's own size and alpha check, and `VerifyScreenshots.sh`;
- the owner's look at the set before upload, and App Store Connect's own preview after it.

## 9. Files

- New: `Tools/StoreScreenshots.html`, `Tools/FrameScreenshots.sh`, this spec.
- Sunday: `Screenshots/en-US/Store/iPhone-6.9/` (ten, new), `AppStore/1.4/screenshots/iPhone-6.9/` (ten,
  replaced), `AppStore/1.4/README.md` §3 and the main `README.md`'s screenshot table (each file a copy of its
  framed shot, with its headline), and the docs cascade: `HISTORY.md`, `docs/AI_CONTEXT.md`. Release 1.4's
  spec §6.3 is superseded here, not rewritten.

## 10. Not in this

The watch shot and the product page header (F7); other languages (F9); the 6.5″ and iPad slots, which Connect
fills from the 6.9″ or does not need; an app preview video.

## 11. The creative pass (2026-11-06, late evening)

The owner, on the first preview: *"make them more creative as like as given references, more clear cut outs of elements
in screenshot, flowless design of the screens"*. Their answers: the shots **flow across their seams**; **all four** of
the references' moves; **the phone on some shots, not all**. This section supersedes §4's single lifted piece and
fixed phone.

- **F10. One scene, ten windows.** Every phone, cut-out and decoration is placed on the strip, not in a shot, so a
  piece near a seam is drawn in both neighbours: a swipe through the ten reads as one picture, and the first three,
  which search shows side by side, as one panorama. A piece crosses a seam only where the scene says so (`flow`);
  any other piece must sit inside its own shot.
- **F11. Several cut-outs a shot, and each one crisp.** Two to four of the screen's own elements per shot — panes,
  tiles, rows, buttons, the vessel — each cut on its own edges, with a hairline rim, a glow and the two shadows. None is
  drawn larger than 0.5 CSS px per capture pixel, which at 2× is one capture pixel per output pixel: a cut-out is never
  upscaled, so it stays as sharp as the screen it came from. The page refuses a larger scale.
- **F12. Phones vary.** Turned, moved, cropped by the canvas or by a seam, and absent where one element is the
  story: Month and the recap are frameless, their cut-outs floating on the aurora alone.
- **F13. Hand-drawn notes**, in Bradley Hand Bold — a macOS font, loaded from the system as the rounded face is —
  with a drawn arrow: a few words that point at what a feature does, true to the app (no *AI*, no claim the screen
  does not make).
- **F14. Floating drops and sparkles**, drawn in SVG from the water's own gradient: decoration, never UI, never a
  figure.
- **F15. A preview mode** (`&preview`) draws a dashed placeholder where a capture or a crop is missing; the script
  never passes it, so the upload set can only be rendered whole.
- **F16. A measuring mode** (`?measure=<slug>`) draws one capture at 0.5, filling the canvas, with every rectangle
  the scene cuts from it outlined and named. Each rectangle is set there, and checked there again on Sunday.
