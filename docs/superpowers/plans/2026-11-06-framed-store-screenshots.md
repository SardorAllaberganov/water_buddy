# Framed Store Screenshots Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task
> (this repository allows no implementation subagent — `CLAUDE.md`, *Implementation — one loop, tests first*).
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the ten raw iPhone captures into framed App Store screenshots — headline, phone, one lifted pane,
over an aurora that runs across the set — rendered at 1320 × 2868 by one script.

**Architecture:** `Tools/StoreScreenshots.html` draws one shot, chosen by `?shot=<slug>`, and reports whether it
drew it correctly on `<body data-status>`. `Tools/FrameScreenshots.sh` asks headless Chrome for that status, takes
the shot only when it reads `ready`, and reads the PNG back. Both live in `Tools/`, in no target.

**Tech Stack:** HTML, CSS, plain JavaScript; Google Chrome headless (`--headless=new`); bash; `sips`. Python 3 with
PIL only for throwaway measuring in the scratchpad, never in the repository.

**Spec:** `docs/superpowers/specs/2026-11-06-framed-store-screenshots-design.md`

**Done 2026-11-06, evening — read this first.** The owner approved the plan and merged `AppStore/1.4/` and
`Screenshots/` into one `AppStore/`. Tasks 1–3 were then run against eight 26 October captures restored from
git into the scratchpad, as a preview. **The files on disk outrank this plan's code blocks** where they
differ:
- the default paths are `AppStore/screenshots/captures/iPhone-6.9/` in, and `AppStore/screenshots/iPhone-6.9/`
  out, under the upload names `1-home.png` … `10-settings.png`, so Task 4 copies nothing;
- the page starts the capture's and the face's loads before its first `await`. Started after the face had
  loaded, the capture was never waited for by headless Chrome's virtual clock, and every shot stayed `loading`
  (measured);
- Home's vessel is raised 30 px (`dy: -30`). Lifted in place, it covered *700 ml to go*.
- **The creative pass (spec §11), the same night, replaced the page's single lifted piece with a scene.** Phones,
  cut-outs, drops, sparkles and hand-drawn notes are placed along the strip. A cut-out marked `on` is lifted from its own
  place on its turned phone; one that flies across a seam (`away`, `flow`) leaves a dark slot where it was cut. Its
  refusals now read: `<cut> is not measured yet`, `<cut> runs outside its capture`, `<cut> is drawn at <s>, past one
  capture pixel per output pixel (0.5)`, `<cut> runs out of its shot`, `<cut> covers the headline`, `the phone of <slug>
  runs out of its shot`, `the hand face did not load`, `set= wants name.field:value` and `set= names no cut-out <name>`.
  `lift=` is gone. Try a rectangle with `set=<cut>.rect:x,y,w,h`, and check every rectangle with `measure=<slug>`, which
  replaces `&guide`. **In Task 4:** measure `schedule.hours` and `export.card` in `measure=11-schedule` and
  `measure=12-export`, write their `rect`s, and re-measure every other rectangle the same way.

**When:** every task runs after release 1.4's phase 2 capture (8 November, 1:45–11:45 PM). The plan was written
to preview the look today from the 26 October captures, but the owner had those deleted the same evening
(2026-11-06), so there is nothing to frame before Sunday. On Sunday the ten raw captures are in place, and
`11-schedule` and `12-export` are captured but not yet measured until Task 4.

## Global Constraints

- Every output PNG is exactly **1320 × 2868**, PNG, **no alpha**; the page is laid out at **660 × 1434** CSS px and
  rendered at **2×**.
- Colours are the app's `Aurora` tokens, copied: top `#0A2185`, bottom `#5C1A9E`, blue `#008CFF`, magenta
  `#C740FA`, cyan `#00D9D9`; the strip's middle stop `#1A1F92` and the accent `#7FF6F6 → #5EF0F0 → #8FD0FF`
  are the header's; the water is `#3D9BFF → #1667EA → #0B46C9`.
- The face is SF Pro Rounded from `/System/Library/Fonts/SFNSRounded.ttf`, loaded, never copied in.
- English only. No price, no *Free*, no award, no *AI*, no *Apple Intelligence* in any shot. The only claim
  outside a headline is shot 1's *No account · No cloud*.
- Shots 3–8 (`05-month`, `06-insights`, `07-patterns`, `08-recap`, `11-schedule`, `12-export`) carry the
  *Premium* tag; the other four do not.
- Every lifted piece is the capture's own pixels, enlarged 1.2×. Nothing is redrawn.
- The upload order, the raw captures, the watch shot and the product page header do not change.
- No file in a build target changes. **Never commit:** stage explicit paths and stop; the owner runs `/commit`.
  No AI attribution anywhere.
- Chrome runs with a throwaway `--user-data-dir`, never the owner's profile.

## Review Focus

1. **A capture that does not load, or loads at another size** — a moved folder, a typo in `--in`. Expected: the
   shot is not written and the run names it; never a phone with nothing in it. (Task 1, Step 4.)
2. **The rounded face missing** — a macOS update moves the file. Expected: the run fails; never a fallback face,
   wider, that clips a headline nobody reads again. (Task 1, Step 4.)
3. **A headline the owner rewrites too long for its line.** Expected: the run names the line; never a word cut at
   the canvas edge. (Task 1, Step 4.)
4. **This repository's own path holds an `&`** (`MobileApps&Games`), which a query string reads as a separator.
   Expected: `--in` with that path renders exactly as the default does. (Task 2, Step 4.)
5. **Sunday's captures move a pane** — the finish changed some screens since 26 October. Expected: every rectangle
   is measured again and checked with `?guide` before the set is rendered; a rectangle outside the capture or a
   piece off the canvas fails the run. (Task 1, Step 4; Task 4, Steps 2–4.)

---

### Task 1: The page

**Files:**
- Create: `Tools/StoreScreenshots.html`

**Interfaces:**
- Produces: `Tools/StoreScreenshots.html?shot=<slug>[&in=<dir>][&guide][&lift=x,y,w,h[,dx]][&font=<path>][&l1=…&l2=…]`. `<slug>` is
  one of `01-home 03-history 05-month 06-insights 07-patterns 08-recap 11-schedule 12-export 09-goal-setup
  10-settings`; `in` is a percent-encoded absolute directory holding `<slug>.png`, default
  `../Screenshots/en-US/iPhone-6.9` relative to the page. After load, `<body data-status>` is `ready` or
  `error: <what>` (anything else, such as `loading`, also means not ready).

- [x] **Step 1: Write the check helper (the test)**

Run in zsh from the repository root. `S` is this session's scratchpad.

```bash
S=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-Games-WaterBuddy/58a9635a-92d4-401f-9844-108d00eb7a75/scratchpad/aso
mkdir -p "$S/profile"
status() {
  local page; page=$(python3 -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$PWD/Tools/StoreScreenshots.html")
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 --window-size=660,1434 --allow-file-access-from-files \
    --user-data-dir="$S/profile" --virtual-time-budget=3000 --dump-dom "file://$page?$1" 2>/dev/null \
    | grep -o 'data-status="[^"]*"' | head -1
}
```

- [x] **Step 2: Run it before the page exists — RED**

Run: `status 'shot=01-home'; echo "exit=$?"`
Expected: no `data-status` printed, `exit=1` (Chrome dumps its own error page).

- [x] **Step 3: Write the page**

Create `Tools/StoreScreenshots.html` with exactly this content:

```html
<!doctype html>
<!--
  StoreScreenshots.html
  Tools

  The App Store's iPhone shots, framed: a two-line headline, the raw capture in a drawn phone, one pane of it
  lifted out, over WaterBuddy's aurora running across all ten. Spec:
  docs/superpowers/specs/2026-11-06-framed-store-screenshots-design.md.

  Render the ten with `bash Tools/FrameScreenshots.sh`. One shot by hand, from the repository root (the
  throwaway profile keeps a headless run off the owner's own Chrome profile):

    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu \
      --hide-scrollbars --force-device-scale-factor=2 --window-size=660,1434 \
      --allow-file-access-from-files --user-data-dir="$(mktemp -d)" --virtual-time-budget=3000 \
      --screenshot=out.png "file://$PWD/Tools/StoreScreenshots.html?shot=01-home"

  THE QUERY. shot=<slug>, required: the capture's own name. in=<directory>, percent-encoded: where the
  captures are, Screenshots/en-US/iPhone-6.9 by default. guide: outlines the lifted rectangle where it
  stands on the phone, for measuring. lift=x,y,w,h[,dx]: try a rectangle before it goes in the table.
  font=<path>, l1= and l2=: try another face or other words. The script passes only shot and in.

  THE STATUS. <body data-status> reads "ready" only once the capture has decoded at 1320 x 2868, the rounded
  face has loaded, each headline line fits on one line, and the lifted rectangle lies inside the capture
  and its piece inside the canvas. Otherwise "error: <what>". The script reads it before it takes the shot,
  so an empty phone or a clipped headline is never written.

  HONESTY. A lifted piece is the capture's own pixels, enlarged; nothing is redrawn. The six Premium shots
  carry the Premium tag (App Review Guideline 2.3.2). No price, no "Free", no award.

  THE LOOK. Each shot is a 660-px window onto one strip ten shots wide, so a light near one shot's edge
  carries on into the next. Colours are the app's Aurora tokens (WaterSurface.swift), copied as the header
  copies them; the two waves keep the app's two frequencies, 1.1 and 1.7, as periods 260 and 168.
-->
<html lang="en">
<head>
<meta charset="utf-8">
<title>Store Screenshots</title>
<style>
:root { --top: #0A2185; --bottom: #5C1A9E; --blue: #008CFF; --magenta: #C740FA; --cyan: #00D9D9; }
html, body { margin: 0; padding: 0; width: 660px; height: 1434px; overflow: hidden; background: var(--top); }
#canvas { position: relative; width: 660px; height: 1434px; overflow: hidden; color: #fff;
  font-family: "WB Rounded", ui-rounded, -apple-system, sans-serif; }
#strip { position: absolute; top: 0; width: 6600px; height: 1434px;
  background: linear-gradient(180deg, var(--top) 0%, #1A1F92 45%, var(--bottom) 100%); }
#strip .light { position: absolute; border-radius: 50%; opacity: .5; }
#strip svg { position: absolute; left: 0; bottom: 0; }
#head { position: absolute; left: 0; top: 0; width: 660px; height: 392px; box-sizing: border-box; padding: 0 40px;
  display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 22px; }
h1 { margin: 0; width: 580px; font-weight: 750; font-size: 60px; line-height: 66px; letter-spacing: -1.2px;
  text-align: center; text-shadow: 0 2px 18px rgba(6, 10, 60, .35); }
h1 .line { display: block; white-space: nowrap; overflow: hidden; }
h1 em { font-style: normal; background: linear-gradient(90deg, #7FF6F6 0%, #5EF0F0 40%, #8FD0FF 100%);
  -webkit-background-clip: text; background-clip: text; color: transparent; text-shadow: none; }
.pill { display: none; align-items: center; gap: 8px; padding: 8px 18px; border-radius: 999px;
  font-weight: 650; font-size: 22px; line-height: 28px; }
.pill.on { display: inline-flex; }
#premium { border: 2px solid transparent;
  background: linear-gradient(rgba(20, 24, 110, .85), rgba(20, 24, 110, .85)) padding-box,
              linear-gradient(90deg, var(--cyan), var(--magenta), var(--blue)) border-box; }
#premium svg { width: 20px; height: 20px; fill: #7FF6F6; }
#note { background: rgba(255, 255, 255, .12); border: 1px solid rgba(255, 255, 255, .28); font-size: 21px; }
#phone { position: absolute; left: 83px; top: 400px; width: 494px; box-sizing: border-box; padding: 12px;
  border-radius: 78px; background: linear-gradient(160deg, #2E3140 0%, #15171F 55%, #262935 100%);
  box-shadow: inset 0 0 0 1px rgba(255, 255, 255, .18), 0 60px 120px rgba(4, 6, 40, .55), 0 14px 30px rgba(4, 6, 40, .45); }
#screen { position: relative; width: 470px; border-radius: 66px; overflow: hidden; background: #000; }
#screen img { display: block; width: 470px; }
#island { position: absolute; left: 168px; top: 12px; width: 134px; height: 40px; border-radius: 20px; background: #000; }
#lift { position: absolute; display: none; background-repeat: no-repeat;
  box-shadow: 0 50px 90px rgba(4, 6, 40, .6), 0 12px 24px rgba(4, 6, 40, .45); }
.guide { position: absolute; outline: 2px dashed #FFD60A; }
</style>
</head>
<body data-status="loading">
<div id="canvas">
  <div id="strip"></div>
  <div id="head">
    <div id="premium" class="pill"><svg viewBox="0 0 24 24"><path d="M12 0C13 7 17 11 24 12C17 13 13 17 12 24C11 17 7 13 0 12C7 11 11 7 12 0Z"/></svg>Premium</div>
    <h1 id="headline"></h1>
    <div id="note" class="pill"></div>
  </div>
  <div id="phone"><div id="screen"><img id="capture" alt=""><div id="island"></div></div></div>
  <div id="lift"></div>
</div>
<script>
// The ten, in upload order: index i is the strip's i-th window. A lift is a rectangle in the capture's own
// pixels — measured on the pane's lit rim with 4 px kept round it — drawn 1.2x and moved dx, dy CSS px.
const SHOTS = [
  { slug: '01-home', lines: ['One tap.', 'Watch it <em>fill.</em>'], premium: false, note: 'No account · No cloud',
    lift: { x: 199, y: 660, w: 920, h: 920, shape: 'circle' } },
  { slug: '03-history', lines: ['Your <em>week,</em>', 'day by day'], premium: false,
    lift: { x: 68, y: 657, w: 1184, h: 825, dx: -48 } },
  { slug: '05-month', lines: ['A whole <em>month</em>', 'on one page'], premium: true,
    lift: { x: 68, y: 657, w: 1184, h: 1212, dx: 48 } },
  { slug: '06-insights', lines: ['<em>Insights</em> from', 'your own week'], premium: true,
    lift: { x: 68, y: 813, w: 1184, h: 425, dx: -48 } },
  { slug: '07-patterns', lines: ['Learn <em>when</em>', 'you drink'], premium: true,
    lift: { x: 68, y: 1293, w: 1184, h: 477, dx: 48 } },
  { slug: '08-recap', lines: ['<em>Share</em>', 'your month'], premium: true,
    lift: { x: 68, y: 436, w: 1184, h: 1144, dx: -36, turn: -3 } },
  { slug: '11-schedule', lines: ['Reminders on', '<em>your hours</em>'], premium: true,
    lift: null },  // measured on Sunday's capture (plan Task 4)
  { slug: '12-export', lines: ['Your servings,', 'as a <em>CSV file</em>'], premium: true,
    lift: null },  // measured on Sunday's capture (plan Task 4)
  { slug: '09-goal-setup', lines: ['A goal that', '<em>fits</em> you'], premium: false,
    lift: { x: 68, y: 416, w: 1184, h: 729, dx: 48 } },
  { slug: '10-settings', lines: ['Set your own', '<em>serving sizes</em>'], premium: false,
    lift: { x: 68, y: 1675, w: 1184, h: 925, dx: -48 } },
];

// The strip's lights, [x, y, radius, colour] in strip px; several straddle a seam at a multiple of 660.
const LIGHTS = [
  [560, 260, 300, 'var(--blue)'], [120, 1100, 260, 'var(--magenta)'], [1250, 900, 320, 'var(--cyan)'],
  [1900, 300, 300, 'var(--magenta)'], [2600, 1150, 320, 'var(--blue)'], [3300, 500, 300, 'var(--cyan)'],
  [3950, 1000, 320, 'var(--magenta)'], [4620, 280, 300, 'var(--blue)'], [5300, 1100, 320, 'var(--cyan)'],
  [5940, 420, 300, 'var(--magenta)'], [6500, 1200, 260, 'var(--blue)'],
];

const CAPTURE = { w: 1320, h: 2868 };
const S = 470 / CAPTURE.w;                    // the phone's screen: capture px to CSS px
const LIFT = 1.2;                             // a lifted piece against its size on the phone
const SCREEN = { left: 83 + 12, top: 400 + 12 };
const RADIUS = 88;                            // LiquidGlass.cornerRadius, 28 pt = 84 px, plus the 4-px margin

const P = new URLSearchParams(location.search);
const $ = id => document.getElementById(id);

class Refusal extends Error {}
function fail(what) { throw new Refusal(what); }

// A file: URL for an absolute path: each segment encoded, since this repository's own path holds an "&".
function fileURL(path) { return 'file://' + path.split('/').map(encodeURIComponent).join('/'); }

function drawStrip(index) {
  const strip = $('strip');
  strip.style.left = (-660 * index) + 'px';
  for (const [x, y, r, colour] of LIGHTS) {
    const light = document.createElement('div');
    light.className = 'light';
    Object.assign(light.style, { left: (x - r) + 'px', top: (y - r) + 'px', width: 2 * r + 'px', height: 2 * r + 'px',
      background: `radial-gradient(circle, ${colour} 0%, transparent 70%)` });
    strip.appendChild(light);
  }
  const wave = (base, amp, period, phase) => {
    let d = `M ${-phase} ${base}`;
    for (let x = -phase; x < 6600 + period; x += period) d += ` q ${period / 4} ${-amp} ${period / 2} 0 t ${period / 2} 0`;
    return d + ` V 260 H ${-phase} Z`;
  };
  strip.insertAdjacentHTML('beforeend', `
    <svg width="6600" height="260" viewBox="0 0 6600 260">
      <defs><linearGradient id="water" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#3D9BFF"/><stop offset=".46" stop-color="#1667EA"/><stop offset="1" stop-color="#0B46C9"/>
      </linearGradient></defs>
      <path d="${wave(50, 12, 260, 0)}" fill="url(#water)" opacity=".45"/>
      <path d="${wave(74, 9, 168, 60)}" fill="url(#water)" opacity=".9"/>
    </svg>`);
}

async function main() {
  const slug = P.get('shot');
  const index = SHOTS.findIndex(s => s.slug === slug);
  if (index < 0) fail('unknown shot ' + slug);
  const shot = SHOTS[index];
  const asked = P.has('lift') ? P.get('lift').split(',').map(Number) : null;
  if (asked && (asked.length < 4 || asked.length > 5 || asked.some(Number.isNaN))) fail('lift= wants x,y,w,h or x,y,w,h,dx');
  const L = asked ? { ...(shot.lift ?? {}), x: asked[0], y: asked[1], w: asked[2], h: asked[3], dx: asked[4] ?? shot.lift?.dx ?? 0 }
                  : shot.lift;
  if (!L) fail('no lifted piece measured for ' + slug);
  if (L.x < 0 || L.y < 0 || L.x + L.w > CAPTURE.w || L.y + L.h > CAPTURE.h) fail('the lifted rectangle runs outside the capture');

  const face = new FontFace('WB Rounded', `url("${fileURL(P.get('font') ?? '/System/Library/Fonts/SFNSRounded.ttf')}")`, { weight: '100 1000' });
  try { await face.load(); } catch { fail('the rounded face did not load'); }
  document.fonts.add(face);

  const capture = $('capture');
  const dir = P.get('in');
  capture.src = dir ? fileURL(dir + '/' + slug + '.png') : '../Screenshots/en-US/iPhone-6.9/' + slug + '.png';
  try { await capture.decode(); } catch { fail('capture did not load: ' + slug + '.png'); }
  if (capture.naturalWidth !== CAPTURE.w || capture.naturalHeight !== CAPTURE.h)
    fail(`capture is ${capture.naturalWidth} x ${capture.naturalHeight}, not ${CAPTURE.w} x ${CAPTURE.h}`);

  drawStrip(index);

  const lines = [P.get('l1') ?? shot.lines[0], P.get('l2') ?? shot.lines[1]];
  $('headline').innerHTML = lines.map(l => `<span class="line">${l}</span>`).join('');
  $('premium').classList.toggle('on', shot.premium);
  if (shot.note) { $('note').textContent = shot.note; $('note').classList.add('on'); }
  await document.fonts.ready;
  [...$('headline').children].forEach((line, i) => {
    if (line.scrollWidth > line.clientWidth + 0.5) fail(`headline line ${i + 1} is too wide`);
  });

  const c = S * LIFT;
  const cx = SCREEN.left + (L.x + L.w / 2) * S + (L.dx ?? 0);
  const cy = SCREEN.top + (L.y + L.h / 2) * S + (L.dy ?? 0);
  const lift = $('lift');
  Object.assign(lift.style, {
    display: 'block', width: L.w * c + 'px', height: L.h * c + 'px',
    left: (cx - L.w * c / 2) + 'px', top: (cy - L.h * c / 2) + 'px',
    backgroundImage: `url("${capture.src}")`, backgroundSize: `${CAPTURE.w * c}px ${CAPTURE.h * c}px`,
    backgroundPosition: `${-L.x * c}px ${-L.y * c}px`,
    borderRadius: L.shape === 'circle' ? '50%' : RADIUS * c + 'px',
    transform: `rotate(${L.turn ?? 0}deg)`,
  });
  const box = lift.getBoundingClientRect();
  if (box.left < 0 || box.top < 0 || box.right > 660 || box.bottom > 1434) fail('the lifted piece runs off the canvas');

  if (P.has('guide')) {
    lift.style.opacity = '.35';
    const guide = document.createElement('div');
    guide.className = 'guide';
    Object.assign(guide.style, { left: SCREEN.left + L.x * S + 'px', top: SCREEN.top + L.y * S + 'px',
      width: L.w * S + 'px', height: L.h * S + 'px', borderRadius: L.shape === 'circle' ? '50%' : RADIUS * S + 'px' });
    $('canvas').appendChild(guide);
  }

  document.body.dataset.status = 'ready';
}

main().catch(e => { document.body.dataset.status = 'error: ' + (e instanceof Refusal ? e.message : 'the page failed: ' + e.message); });
</script>
</body>
</html>
```

- [x] **Step 4: Run every check — GREEN**

```bash
enc() { python3 -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$1"; }
mkdir -p "$S/small" && sips -Z 700 Screenshots/en-US/iPhone-6.9/01-home.png --out "$S/small/01-home.png" >/dev/null
status 'shot=01-home'
status 'shot=nope'
status 'shot=11-schedule'
status "shot=01-home&in=$(enc /nonexistent)"
status "shot=01-home&in=$(enc "$S/small")"
status 'shot=01-home&font=%2Fnonexistent.ttf'
status 'shot=01-home&l2=Watch%20it%20fill%2C%20every%20single%20day'
status 'shot=03-history&lift=68,2500,1184,825'
status 'shot=03-history&lift=68,657,1184,825,300'
status 'shot=03-history&lift=68,657'
```

Expected, in order:

```
data-status="ready"
data-status="error: unknown shot nope"
data-status="error: no lifted piece measured for 11-schedule"
data-status="error: capture did not load: 01-home.png"
data-status="error: capture is 322 x 700, not 1320 x 2868"
data-status="error: the rounded face did not load"
data-status="error: headline line 2 is too wide"
data-status="error: the lifted rectangle runs outside the capture"
data-status="error: the lifted piece runs off the canvas"
data-status="error: lift= wants x,y,w,h or x,y,w,h,dx"
```

Then every measured shot must read ready: `for s in 01-home 03-history 05-month 06-insights 07-patterns 08-recap 09-goal-setup 10-settings; do echo "$s $(status "shot=$s")"; done` → eight `data-status="ready"`.

If a check prints something else, fix the page, never the expectation.

- [x] **Step 5: Look at two shots**

```bash
shot() {
  local page; page=$(python3 -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$PWD/Tools/StoreScreenshots.html")
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=2 --window-size=660,1434 --allow-file-access-from-files \
    --user-data-dir="$S/profile" --virtual-time-budget=3000 --screenshot="$S/$2.png" "file://$page?$1" 2>/dev/null
}
shot 'shot=01-home' try-home; shot 'shot=06-insights&guide' try-insights-guide
sips -g pixelWidth -g pixelHeight -g hasAlpha "$S/try-home.png"
```

Expected: `1320`, `2868`, `hasAlpha: no`. Read both PNGs with the Read tool: the headline on two lines with *fill.*
in cyan; the phone cropped at the bottom; the vessel lifted where it stands; on the guide shot, the dashed outline
on the pane's rim with the lifted copy at 35 % over it.

- [x] **Step 6: Stage**

```bash
git add Tools/StoreScreenshots.html
```

---

### Task 2: The script

**Files:**
- Create: `Tools/FrameScreenshots.sh`

**Interfaces:**
- Consumes: Task 1's page and its `data-status` contract.
- Produces: `bash Tools/FrameScreenshots.sh [--in DIR] [--out DIR]` — writes `<out>/<slug>.png` for each capture
  found; prints `ok`, `missing` or `FAIL` per slug and `N of 10 framed into <out>`; exits `0` only when all ten
  were framed, `1` otherwise, `2` on a usage error or no Chrome.

- [x] **Step 1: Make the two fixtures (the test)**

```bash
mkdir -p "$S/empty"; rm -rf "$S/out-empty" "$S/out"
```

- [x] **Step 2: Run before the script exists — RED**

Run: `bash Tools/FrameScreenshots.sh --in "$S/empty" --out "$S/out-empty"; echo "exit=$?"`
Expected: `bash: Tools/FrameScreenshots.sh: No such file or directory`, `exit=127`.

- [x] **Step 3: Write the script**

Create `Tools/FrameScreenshots.sh` with exactly this content:

```bash
#!/bin/bash
#
#  Tools/FrameScreenshots.sh — frames the ten raw iPhone captures for the App Store.
#
#  Run:  bash Tools/FrameScreenshots.sh [--in DIR] [--out DIR]
#
#  Reads   Screenshots/en-US/iPhone-6.9/<slug>.png        Tools/CaptureScreenshots.sh's ten, 1320 x 2868
#  Writes  Screenshots/en-US/Store/iPhone-6.9/<slug>.png  by default
#
#  Each shot is Tools/StoreScreenshots.html drawn by headless Chrome. The page reports on
#  <body data-status>; a shot is taken only when it reads "ready", then read back: 1320 x 2868, PNG, no
#  alpha. A missing capture is reported and skipped, and the run exits 1, so a partial set is never taken
#  for the whole (docs/superpowers/specs/2026-11-06-framed-store-screenshots-design.md §6).
#  Tools/VerifyScreenshots.sh checks the default output too: it keys the 6.9" sizes on /iPhone-6.9/.
#
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IN="$ROOT/Screenshots/en-US/iPhone-6.9"
OUT="$ROOT/Screenshots/en-US/Store/iPhone-6.9"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# Upload order, as the page's own table lists them.
SLUGS="01-home 03-history 05-month 06-insights 07-patterns 08-recap 11-schedule 12-export 09-goal-setup 10-settings"

while [ $# -gt 0 ]; do
  case "$1" in
    --in)  [ $# -ge 2 ] && IN="$(cd "$2" 2>/dev/null && pwd)" || { echo "no such directory: ${2:-}" >&2; exit 2; }; shift 2 ;;
    --out) [ $# -ge 2 ] || { echo "usage: FrameScreenshots.sh [--in DIR] [--out DIR]" >&2; exit 2; }; OUT="$2"; shift 2 ;;
    *)     echo "usage: FrameScreenshots.sh [--in DIR] [--out DIR]" >&2; exit 2 ;;
  esac
done

[ -x "$CHROME" ] || { echo "Google Chrome is not at $CHROME" >&2; exit 2; }
mkdir -p "$OUT"
PROFILE="$(mktemp -d)"
trap 'rm -rf "$PROFILE"' EXIT

# Percent-encode a path: this repository's own path holds an "&", which a query reads as a separator.
encode() { python3 -I -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=sys.argv[2]))' "$1" "$2"; }
PAGE="file://$(encode "$ROOT/Tools/StoreScreenshots.html" /)"
QUERY_IN="$(encode "$IN" "")"

chrome() {
  "$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 \
    --window-size=660,1434 --allow-file-access-from-files --user-data-dir="$PROFILE" \
    --virtual-time-budget=3000 "$@" 2>/dev/null
}

fail=0
made=0
for slug in $SLUGS; do
  if [ ! -f "$IN/$slug.png" ]; then
    echo "  missing  $slug — no capture at $IN/$slug.png"
    fail=1
    continue
  fi
  url="$PAGE?shot=$slug&in=$QUERY_IN"
  status=$(chrome --dump-dom "$url" | grep -o 'data-status="[^"]*"' | head -1 | sed 's/^data-status="//; s/"$//')
  if [ "$status" != "ready" ]; then
    echo "  FAIL     $slug — ${status:-the page reported nothing}"
    fail=1
    continue
  fi
  png="$OUT/$slug.png"
  rm -f "$png"
  chrome --screenshot="$png" "$url" >/dev/null
  w=$(sips -g pixelWidth "$png" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$png" 2>/dev/null | awk '/pixelHeight/{print $2}')
  alpha=$(sips -g hasAlpha "$png" 2>/dev/null | awk '/hasAlpha/{print $2}')
  fmt=$(sips -g format "$png" 2>/dev/null | awk '/format:/{print $2}')
  if [ "${w}x${h}" != "1320x2868" ] || [ "$alpha" != "no" ] || [ "$fmt" != "png" ]; then
    echo "  FAIL     $slug — wrote ${w:-?}x${h:-?}, alpha ${alpha:-?}, ${fmt:-?} (want 1320x2868, no alpha, png; swift Tools/FlattenPNG.swift removes alpha)"
    rm -f "$png"
    fail=1
    continue
  fi
  echo "  ok       $slug"
  made=$((made + 1))
done

echo
echo "$made of 10 framed into $OUT"
exit $fail
```

- [x] **Step 4: Run the three cases — GREEN**

```bash
bash Tools/FrameScreenshots.sh --in "$S/empty" --out "$S/out-empty"; echo "exit=$?"; ls "$S/out-empty" | wc -l
bash Tools/FrameScreenshots.sh --in "$PWD/Screenshots/en-US/iPhone-6.9" --out "$S/out"; echo "exit=$?"
bash Tools/FrameScreenshots.sh --bogus; echo "exit=$?"
```

Expected:
- First: ten `missing` lines, `0 of 10 framed`, `exit=1`, `0` files.
- Second — the path with the `&` (Review Focus 4): eight `ok`, then
  `FAIL     11-schedule — error: no lifted piece measured for 11-schedule` and the same for `12-export` (their
  captures exist, their rectangles come in Task 4), `8 of 10 framed`, `exit=1`.
- Third: the usage line, `exit=2`.

Then check every output: `for f in "$S"/out/*.png; do sips -g pixelWidth -g pixelHeight -g hasAlpha "$f" | tail -3 | tr '\n' ' '; echo; done` → eight lines of `1320 2868 no`.

- [x] **Step 5: Stage**

```bash
git add Tools/FrameScreenshots.sh
```

---

### Task 3: The look, by eye, and the owner's first view

**Files:**
- Modify: `Tools/StoreScreenshots.html` (only `LIGHTS`, the wave numbers, a lift's `dx`/`dy` or a rectangle — by eye)
- Modify: `HISTORY.md` (append), `docs/AI_CONTEXT.md` (top block, Current state, Git block)

**Interfaces:**
- Consumes: Task 2's `$S/out/*.png`.
- Produces: eight approved-looking shots and a contact sheet at `$S/sheet.png` for the owner.

- [x] **Step 1: Read each of the eight at full size**

Read `$S/out/<slug>.png` for each with the Read tool. Each must show, or the page changes:
- the headline on exactly two lines, centred, its accent word cyan, nothing touching the canvas edge;
- the *Premium* pill on `05-month`, `06-insights`, `07-patterns`, `08-recap` only (of these eight), and
  *No account · No cloud* on `01-home` only;
- the lifted piece's edges on its pane's own rim: no aurora inside its corners, no cut-off text at its edges
  (`10-settings`' bottom edge is cut above the tab bar on purpose and rounded by the mask);
- the piece overlapping one side of the phone's frame, alternating down the set;
- the aurora's lights and the wave continuing across each pair of neighbours (`01-home` → `03-history` and so on).

For any rectangle in doubt, render it with `&guide` (Task 1, Step 5's `shot` helper) and move the rectangle until the
dashed line sits on the rim.

- [x] **Step 2: Make the contact sheet**

Write `$S/sheet.py` (throwaway, scratchpad only):

```python
import sys
from PIL import Image

out, files = sys.argv[1], sys.argv[2:]
thumbs = [Image.open(f).convert("RGB").resize((330, 717)) for f in files]
sheet = Image.new("RGB", (20 + 350 * len(thumbs), 757), (18, 18, 28))
for i, t in enumerate(thumbs):
    sheet.paste(t, (20 + 350 * i, 20))
sheet.save(out)
```

Run, in upload order:

```bash
cd "$S/out" && python3 -I "$S/sheet.py" "$S/sheet.png" 01-home.png 03-history.png 05-month.png 06-insights.png 07-patterns.png 08-recap.png 09-goal-setup.png 10-settings.png; cd -
```

Expected: `$S/sheet.png`, 2820 × 757. Read it: the strip must read as one picture across the eight.

- [x] **Step 3: Show the owner**

`open "$S/sheet.png"` (Preview, on the owner's Mac), and give the paths of the eight. Ask for changes to words, look
or crops; make them in the page's `SHOTS` table, re-run Task 2 Step 4's second command, and show again until the
owner is content. A headline change runs Task 1 Step 4's line check by itself, through the script's status read.

- [ ] **Step 4: Checkpoint and stage**

Append to `HISTORY.md` a checkpoint `## [2026-11-06] — The store's iPhone shots framed: the page and the script`
with what changed, the rulings F1–F9, the files, and the verification actually run (Task 1 Step 4's six checks,
Task 2 Step 4's three cases, the eight read by eye). In `docs/AI_CONTEXT.md`: a `Last updated` line, one *Current
state* bullet (the framing built, eight rendered from 26 October's captures, the final ten on Sunday after phase 2),
and — written last — the Git block from a fresh `git diff --cached --name-status`.

```bash
git add Tools/StoreScreenshots.html HISTORY.md docs/AI_CONTEXT.md docs/superpowers/plans/2026-11-06-framed-store-screenshots.md
git diff --cached --name-status
```

---

### Task 4: Sunday — the ten from 1.4's captures, into the upload folder

Runs after release 1.4's phase 2 capture (`bash Tools/CaptureScreenshots.sh`, 8 November, 1:45–11:45 PM) has
written the ten raw shots and they have been read by eye (release spec §6.3).

**Files:**
- Modify: `Tools/StoreScreenshots.html` (`SHOTS`' lifts)
- Create: `Screenshots/en-US/Store/iPhone-6.9/*.png` (ten)
- Replace: `AppStore/1.4/screenshots/iPhone-6.9/` (ten; `7-goal-setup.png` and `8-settings.png` removed)
- Modify: `AppStore/1.4/README.md` §3, `README.md` (its screenshot table), `HISTORY.md`, `docs/AI_CONTEXT.md`

**Interfaces:**
- Consumes: Tasks 1–3; the ten raw captures in `Screenshots/en-US/iPhone-6.9/`.
- Produces: the upload set, `AppStore/1.4/screenshots/iPhone-6.9/1-home.png` … `10-settings.png`.

- [ ] **Step 1: Write the rim finder (throwaway, scratchpad)**

`$S/measure.py`:

```python
"""Find a glass pane's lit rim in a raw capture: rows / columns where luminance peaks.

usage: python3 -I measure.py <png> col <x> <y0> <y1>   rows along column x
       python3 -I measure.py <png> row <y> <x0> <x1>   columns along row y
"""
import sys
from PIL import Image

img = Image.open(sys.argv[1]).convert("RGB")
mode = sys.argv[2]
a, b, c = (int(v) for v in sys.argv[3:6])

def lum(p):
    return 0.2126 * p[0] + 0.7152 * p[1] + 0.0722 * p[2]

values = [lum(img.getpixel((a, i) if mode == "col" else (i, a))) for i in range(b, c)]
for i in range(2, len(values) - 2):
    if values[i] > values[i - 1] and values[i] >= values[i + 1] and values[i] - min(values[i - 2], values[i + 2]) > 12:
        print((b + i, round(values[i])))
```

- [ ] **Step 2: Measure every rectangle again**

For each pane shot: `python3 -I $S/measure.py AppStore/screenshots/captures/iPhone-6.9/<slug>.png col 110 300 2700` gives the
rim's crossings 38 px inside the pane's left edge; the true top is the crossing **minus 14** and the bottom the
crossing **plus 14** (the 84-px corner, 38 px in). `row <y> 0 200` and `row <y> 1120 1320` at a y inside the pane give
its left and right rims (on 26 October, 72 and 1248 on every pane). A rectangle keeps 4 px round the rim: `x = left − 4`,
`y = top − 4`, `w = right − left + 8`, `h = bottom − top + 8`. Home's vessel: `row 1127 0 1320` and `col 660 500 1800`
give the circle's rims; centre and radius plus 8 px give `x, y, w = h`.

For `11-schedule`, the lifted piece is the pane holding the hours and the interval, or — if the hours and the days
sit in two panes — the days' pane; for `12-export`, the export sheet's card. Read each capture first and choose the one
pane the headline names. Write each rectangle into `SHOTS`, replacing `lift: null` and its comment; keep the `dx` the
set alternates (`11-schedule` +48, `12-export` −48).

- [ ] **Step 3: Check every rectangle with the guide**

A rectangle can be tried before it is written: `shot "shot=11-schedule&guide&lift=68,600,1184,700,48" try-schedule`
(Task 1 Step 5's helper), then read `$S/try-schedule.png`. Once all ten are in the table:
`for s in 01-home 03-history 05-month 06-insights 07-patterns 08-recap 11-schedule 12-export 09-goal-setup 10-settings; do shot "shot=$s&guide" "guide-$s"; done`
Read each: the dashed outline on the rim all round. Move any rectangle that is not, and look again.

- [ ] **Step 4: Render the ten into the store folder**

Run: `bash Tools/FrameScreenshots.sh; echo "exit=$?"`
Expected: ten `ok`, `10 of 10 framed into …/AppStore/screenshots/iPhone-6.9`, `exit=0`.

Run: `bash Tools/VerifyScreenshots.sh`
Expected: every file `ok`, the ten new ones among them as `iPhone 6.9"`.

- [ ] **Step 5: Read the ten, and the owner's go**

Task 3 Step 1's checklist, for all ten, at full size; then the contact sheet of the ten (Task 3 Step 2's script,
upload order, `11-schedule.png 12-export.png` after `08-recap.png`), opened for the owner. Nothing is copied until
the owner says the set is right.

- [ ] **Step 6: Nothing to copy**

Since the merge, Step 4's run writes the upload names straight into `AppStore/screenshots/iPhone-6.9/`, so there is no
separate store folder and no copy. Check the ten names:
`ls AppStore/screenshots/iPhone-6.9/` → `1-home.png` … `10-settings.png`, ten files.

- [ ] **Step 7: The docs, then stage**

- `AppStore/1.4/README.md` §3: drop the *"taken from 8 November … do not upload them"* paragraph; the table lists the
  ten with their headlines; *"Each file is a byte-identical copy of its original in `Screenshots/en-US/`"* becomes
  *"Each file is a byte-identical copy of its framed shot in `Screenshots/en-US/Store/iPhone-6.9/`, made by
  `bash Tools/FrameScreenshots.sh` from the raw captures beside it."*
- `README.md`'s screenshot table: the same ten and the same sentence.
- `HISTORY.md`: a checkpoint `## [2026-11-08] — The ten framed from 1.4's captures and copied into the upload folder`,
  naming the spec's supersession of release spec §6.3's raw copy.
- `docs/AI_CONTEXT.md`: the *Current state* bullet updated, and the Git block written last.

```bash
git add Tools/StoreScreenshots.html Screenshots/en-US/Store/iPhone-6.9 AppStore/1.4/screenshots/iPhone-6.9 \
  AppStore/1.4/README.md README.md HISTORY.md docs/AI_CONTEXT.md
git diff --cached --name-status
```

Stop there: the owner runs `/commit`.
