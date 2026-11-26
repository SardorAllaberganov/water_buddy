# WaterBuddy 1.4.3 (build 9) — the App Store upload

Everything the 1.4.3 version page asks for, in one place: the text, one file per field and per language, and
every screenshot. This folder holds **the current version only** (the owner's ruling, 2026-11-06). **The main
`README.md` stays the master copy of the en-US text** — change both, or neither. `en-GB/`, `ru/` and `es-MX/` are
their own: English (U.K.) is en-US's text word for word but for its keywords and its name, and Russian and Spanish
(Mexico) are written for their own searches. After any change to any field, run `bash Tools/VerifyListing.sh`: it
counts every field in every language, checks the keyword rules, and compares en-US with `README.md` and en-GB with
en-US.

Each `.txt` file is exactly what goes in its field: open it, select all, copy, paste. The files end without a
newline, so the paste is exact. Every count below is the one `VerifyListing.sh` printed on 2026-11-27.

The search research the words come from is in [`research/2026-11-20/`](research/2026-11-20) — the report, the
terms tried, and the ranks read in the US, Russian and Uzbek stores — and, for Spanish (Mexico), in
[`research/2026-11-23/`](research/2026-11-23).

## 1. Before you submit — in order, and yours

1.4.2 (8) is live since 2026-11-26: approved at 21:47 and released by hand at 22:26. How its upload and submission
went is in this file's history in git. 1.4.3 is Spanish's version
(`docs/superpowers/specs/2026-11-26-spanish-and-language-selector-design.md` §5 and §6.8): Latin American Spanish in
the app, its widgets, reminders, Siri and the Watch, and Settings' *Language* as one row that opens a sheet. It changes
no product, screenshot, name, subtitle, keyword or promotional text.

1. **Upload build 9**, on your word: the archive in `build/release-1.4.3/`, with 1.4.2's export settings.
2. **Publish the policy again.** 1.4.3 names Spanish among the app's languages (`2f2da53`): publish
   `Tools/PrivacyPolicy.html` as `waterbuddy/privacy/index.html` in the `SardorAllaberganov.github.io` repository,
   then check that `https://sardorallaberganov.github.io/waterbuddy/privacy/` reads *Last updated 26 November 2026*
   and *English, Russian, Uzbek or Spanish*. On 2026-11-27 the live page still read 25 November's, without Spanish.
   The policy promises it changes before or with the app.
3. **A new version.** 1.4.2 is live, so Connect offers **+ Version**: make **1.4.3**. Connect copies 1.4.2's text,
   header and screenshots into it.
4. **The version page, language by language** (the language menu at the top right): Description and What's New,
   from section 2 and, for Spanish (Mexico), section 6. Promotional Text, Keywords and Support URL stay as copied.
5. **The screenshots** — section 3: nothing to upload; check that each well still holds its set.
6. **Build 9** — *1.4.3 (9)*, once Connect has processed it.
7. **The three purchases** read *Approved*, as they have since 1.4.
8. **App Review notes** — [`review-notes.txt`](review-notes.txt), which now opens with 1.4.3's Spanish.
9. **Manually release this version**, so step 11 comes before the release.
10. **Submit for Review**, on your word.
11. **On your iPhone and Apple Watch, from TestFlight, before the release:** the app in Spanish; the Lock Screen
    widgets; the watch following the phone's *Español*, and its three faces; and Siri in Spanish — *"Registra agua en
    WaterBuddy"* with Siri set to Spanish (the spec's R3). The simulators could not show these
    (`docs/AI_CONTEXT.md`, *Current state*). If Siri does not answer in Spanish, the description's Siri lines change
    before the release.

*(2026-11-27, on your "do all of it except sending it to review for now only testflight the end point, i need to test it out
first": step 1 at 02:19–02:23, *Upload succeeded*; step 2 as `7002c42` on your site, live at 02:34 and byte for byte
`Tools/PrivacyPolicy.html`; step 3 in your Chrome, Connect copying 1.4.2's text, header, screenshots and *Manually release*;
step 4, the four languages' Description and What's New and the review notes, typed in and read back from Connect's API, each
equal to its file by SHA-256, with the promotional text and keywords as copied also equal to theirs; step 6, build 9 attached
once Connect had processed it (02:35), *In beta testing* for the internal group; steps 7 and 9 as copied. **Step 10 is not done,
on your word**: the end point is TestFlight, for step 11.)*

The prices by country stay as set on 2026-11-24 (section 5). Still open from 1.4: **one real purchase** (#156) — a
sandbox purchase, a restore and a refund on a real iPhone. Still open from 1.4.2, unless you saw them before its
release: each alternate icon from a TestFlight install (#237) and the walk in each theme (#236).

## 2. The fields

The name and subtitle are on *App Information*; the rest is on the version page.

| Field | Limit | en-US — `AppStore/` | English (U.K.) — `en-GB/` | Russian — `ru/` |
|---|---|---|---|---|
| Name | 30 characters | [`name.txt`](name.txt) — 26 | [`name.txt`](en-GB/name.txt) — 25 | [`name.txt`](ru/name.txt) — 24 |
| Subtitle | 30 characters | [`subtitle.txt`](subtitle.txt) — 30 | [`subtitle.txt`](en-GB/subtitle.txt) — 30 | [`subtitle.txt`](ru/subtitle.txt) — 29 |
| Keywords | 100 bytes | [`keywords.txt`](keywords.txt) — 99 | [`keywords.txt`](en-GB/keywords.txt) — 98 | [`keywords.txt`](ru/keywords.txt) — 100 |
| Promotional Text | 170 characters | [`promotional-text.txt`](promotional-text.txt) — 136 | [`promotional-text.txt`](en-GB/promotional-text.txt) — 136 | [`promotional-text.txt`](ru/promotional-text.txt) — 168 |
| What's New | 4000 characters | [`whats-new.txt`](whats-new.txt) — 320 | [`whats-new.txt`](en-GB/whats-new.txt) — 320 | [`whats-new.txt`](ru/whats-new.txt) — 364 |
| Description | 4000 characters | [`description.txt`](description.txt) — 3994 | [`description.txt`](en-GB/description.txt) — 3994 | [`description.txt`](ru/description.txt) — 3990 |

What's New is written against **1.4.2**, which is live: Latin American Spanish, and Settings' *Language* as one row.
The descriptions name Spanish among the app's languages and Siri's; in English the vessels' line becomes *Put any on
Home.* so the description stays inside 4,000 characters. The name, subtitle, keywords and promotional text are
1.4.1's in all three languages. Promotional Text can be changed later without a new build; the name, subtitle and
keywords cannot.

*(2026-11-22: Connect saved en-US's new name, then refused the same name for English (U.K.) as "already being used",
most likely because en-US's was still pending. It then refused *Трекер воды: WaterBuddy* for Russian. Each language
took section 1's fallback, written into its `name.txt` first: `Water Tracker: WaterBuddy` and `Трекер воды — WaterBuddy`.
`VerifyListing.sh` now reports the U.K. name as different from en-US's, because its rule predates the fallback (#233).)*

The rest of the page, as 1.4 had it:

| Field | Value |
|---|---|
| Support URL | `https://sardorallaberganov.github.io/waterbuddy/support/` — the same in every language |
| Marketing URL | optional |
| Copyright | `2026 Sardor Allaberganov` |
| Build | **1.4.3 (9)** |
| In-App Purchases and Subscriptions | the three of section 5, approved with 1.4 |
| App Review notes | [`review-notes.txt`](review-notes.txt) — 3094 / 4000 bytes, a 1.4.3 paragraph on Spanish first and Siri's other languages last; sign-in **not** required, no demo account |
| App Review contact | Sardor Allaberganov, `sardorallaberganov96@gmail.com`, 🔴 your phone |

## 3. Screenshots — 1.4.2's ten, kept

1.4.3 changes no screenshot: the set and the header stay English in every language, as for Russian (spec §5), and
Connect copies 1.4.2's into the new version. Open **View All Sizes in Media Manager** from the version page and check
that each iPhone well holds the ten below and the watch well its one. Should a well be empty, drag in its folder's ten
in name order:

1. *iPhone with Dynamic Island (medium display)*, the one Connect requires — `screenshots/iPhone-6.3/`. It
   takes only 1206 × 2622 or 1179 × 2556 and refuses a 6.9″ shot (read 2026-11-13).
2. *iPhone with Dynamic Island (large display)*, optional — `screenshots/iPhone-6.9/`.

The *Apple Watch Series 12* well keeps `screenshots/AppleWatch/1-wrist.png` (416 × 496: the watch app, synced,
at 65 %), unchanged. Only the first three iPhone shots show on search results.

**The product page header loops since 1.4.1:** `screenshots/ProductPageHeader/1-one-tap.mp4`, 8 s, 3840 × 1646,
30 fps, H.264, no audio. A tap on the Glass fills the vessel from 1,050 to 1,300 of 2,000 ml, then the water drains
back to 1,050 with the figures counting down (a fade back read as a swap, the owner's ruling of 2026-11-22). The slot holds one asset, so *Remove* the still first, then *Upload* the video. The still,
`1-one-tap.png` (*One tap. Watch it fill.*), stays in the folder and in Connect's Asset Library.

| # | File | Headline | Shows |
|---|---|---|---|
| 1 | `1-home.png` | One tap. Watch it fill. | Home at 65 %, *1,300 of 2,000 ml*, a five-day streak; the vessel lifted out |
| 2 | `2-widgets.png` | Log without opening the app | the Home Screen: WaterBuddy's small widget and the week widget |
| 3 | `3-lock-screen.png` | Right on your Lock Screen | the Lock Screen: the line, the ring, the rectangle, *Log Water* |
| 4 | `4-history.png` | Your week, day by day | History's week, *Month* and *Insights* locked for a free user |
| 5 | `5-settings.png` | Set your own serving sizes | Settings, the quick-add vessels lifted out |
| 6 | `6-schedule.png` | Reminders on your hours | Premium: your own reminder schedule, a quiet day |
| 7 | `7-month.png` | A whole month on one page | Premium: the month before's calendar and figures |
| 8 | `8-insights.png` | Insights from your own week | Premium: last week's insights |
| 9 | `9-themes.png` | Make it yours | Premium: Settings' Appearance card in Lagoon, its five themes and icons; the card lifted out |
| 10 | `10-recap.png` | Share your month | Premium: the month before's recap card |

The free core takes 1–5 and Premium 6–10, each Premium shot tagged *Premium*. 1.4's goal step and export leave
the set (R4); their captures stay in `captures/`.

*(2026-11-21: the two new captures were taken on the capture pair with the simulator tool, every figure at 65 %
and 1,300 ml, and the ten framed; `iPhone-6.9/` and `iPhone-6.3/` hold 1.4.1's ten under the names above. 1.4's
ten are gone from both folders.)*

*(2026-11-25, 1.4.2: the themes take slot 9 from the patterns (spec R2). The app's own screens were taken again at
21:21–21:36 with the new `13-themes`, because set C changed Settings' vessels card, which shot 5 shows; the pair's
two of 2026-11-21 are kept. Insights' two cut-outs were measured again on the new capture, and the ten framed and
read; `9-patterns.png` is gone from both folders.)*

How each set is made:

- `bash Tools/CaptureScreenshots.sh` (1:45–11:45 PM) writes the app's own screens into
  `screenshots/captures/iPhone-6.9/`, on a throwaway store seeded with three months of servings, and Settings'
  Appearance card in Lagoon as `13-themes`. The capture of 2026-11-25 is kept there. The script begins with
  `xcrun simctl shutdown all`; while other projects' sessions hold simulators on this Mac, run its steps by hand
  instead, shutting down only the capture phone.
- `bash Tools/CapturePairScreenshots.sh setup` makes the capture pair, *WaterBuddy Store iPhone* and *WaterBuddy
  Store Watch*, with a lived-in week on it (also before 11:45 PM). Once a surface is placed — never by tapping a
  widget's pour button — `bash Tools/CapturePairScreenshots.sh shoot 02-widgets`, `shoot 04-lock-screen` or
  `shoot 01-wrist` writes its capture. Read a picture of the device first: every figure at 65 % and 1,300 ml.
- `bash Tools/FrameScreenshots.sh` frames the captures into `screenshots/iPhone-6.9/` under their upload names:
  1320 × 2868, PNG, no alpha, a two-line headline, the screen in a drawn phone, one pane lifted out
  (`docs/superpowers/specs/2026-11-06-framed-store-screenshots-design.md`). Read each one by eye.
- The 6.3″ set is the 6.9″ set scaled evenly to a height of 2622 and trimmed by one pixel column. From
  `screenshots/`: `sips -z 2622 1207 iPhone-6.9/*.png --out <an empty scratch folder>`, then
  `sips -c 2622 1206 <that folder>/*.png --out iPhone-6.3/`. `FrameScreenshots.sh` writes only the 6.9″ set,
  so make this one again whenever it runs.
- `bash Tools/VerifyScreenshots.sh` checks every file's size, alpha and format against its well.
- `python3 Tools/RenderHeaderVideo.py <an empty frames folder> AppStore/screenshots/ProductPageHeader/1-one-tap.mp4`
  makes the header's video. It draws `Tools/ProductPageHeader.html` at each of the loop's 240 frames with headless
  Chrome, four at once (about 3½ minutes; tell the other sessions on this Mac first), then encodes them with
  `Tools/EncodeHeaderVideo.swift`. Check a decoded frame's colour in sRGB: AVFoundation returns frames in BT.709.

`screenshots/captures/` is not uploaded: it holds the raw captures, kept so a changed headline or crop is
framed again without a new capture.

## 4. Unchanged since 1.4 — check, don't edit

| Field | Value |
|---|---|
| Category | Health & Fitness; Lifestyle secondary (optional) |
| Age rating | **4+** — on a new question, answer on the same facts: no medical or treatment advice |
| Price | Free, with in-app purchases |
| App Privacy | **Data Not Collected** — tick no data type |
| Export compliance | answered in the build (`ITSAppUsesNonExemptEncryption = NO`) |
| Privacy Policy URL | `https://sardorallaberganov.github.io/waterbuddy/privacy/` — published again first (section 1), and set for English (U.K.) and Russian too, which Connect left empty (2026-11-22) |
| Terms of Use (EULA) | Apple's standard licence — leave the field at its default |

## 5. In-App Purchases and prices by country

**Field by field in [`in-app-purchases.md`](in-app-purchases.md).** The three products, approved with 1.4:

| Product ID | Type | Display name | Description | Price (US) | Offer |
|---|---|---|---|---|---|
| `sardor.WaterBuddy.premium.yearly` | auto-renewable, 1 year, level 1 | `Premium Yearly` | `Every Premium extra, renewed each year.` | $19.99 | free trial, 1 week, new subscribers |
| `sardor.WaterBuddy.premium.monthly` | auto-renewable, 1 month, level 2 | `Premium Monthly` | `Every Premium extra, renewed each month.` | $2.99 | none |
| `sardor.WaterBuddy.premium.lifetime` | non-consumable | `Premium Lifetime` | `Every Premium extra, paid once.` | $39.99 | — |

All three must exist with exactly these IDs: if one fails to load, the paywall sells nothing. Family Sharing is
on for all three, and in Connect it cannot be turned off once saved.

**Prices by country — set in Connect, not in the build; set on 2026-11-24, every store's in
[`prices-by-country.md`](prices-by-country.md).** Three tiers by the
World Bank's income groups, each plan's ratio kept so the yearly saving stays near 44 % and the lifetime is
twice the yearly (spec §7):

| Tier | Monthly | Yearly | Lifetime | Yearly saves |
|---|---|---|---|---|
| High income — full price | $2.99 | $19.99 | $39.99 | 44.3 % |
| Upper-middle income — about 40 % off | $1.79 | $11.99 | $23.99 | 44.2 % |
| Lower-middle and low income — about 70 % off | $0.89 | $5.99 | $11.99 | 43.9 % |

- **Why the release day:** 1.4.1 is the build whose paywall reads the saving right in every region (#162).
  A price decrease cannot be taken back, and subscribers renew at it; with almost none yet, this is the cheapest
  moment.
- **$0.89, not $0.99:** $0.99 would make the yearly *save 50 %*. Where a price point does not exist in Connect
  for both subscriptions and the lifetime purchase, take the nearest one that keeps the saving within 43–45 %.
- **After each tier, read every sample storefront's proposed price**, and set by hand any yearly saving outside
  43–45 % (the euro stores read 36 % today).
- **Done on 2026-11-24**, two days after the release: the lifetime purchase at once, both subscriptions from
  25 November, the earliest start Connect allows. Each tier is Connect's comparable prices for the US prices above.
  Where the saving then fell outside 43–45 %, the monthly price was kept and the yearly price set by hand: in 46
  tier stores, and in 42 high-income ones, 29 down (the euro stores to €19.99) and 13 up, with existing subscribers
  kept at their price. Every store now saves 43.5–45.0 %.
- Uzbekistan is billed in US dollars, at the lower tier.
- **Never mention another country's price**, in the app or on the page: App Review can read it as misleading.
- Which country is in which group: the World Bank's lists, as the release playbook keeps them, in
  `~/.claude/skills/aso/references/price-tiers.md` (the 2027 fiscal year's lists, published each July).

## 6. Spanish (Mexico) — new with 1.4.2, and the app in Spanish since 1.4.3

Approved by the owner on 2026-11-23 ("Wait for set C"). Apple's localization page lists Spanish (Mexico) among the US
store's languages, so this page's name, subtitle and keywords add a second set of search words there. It is also the
default page in Mexico and 15 other Latin American stores. Connect changes a name only with a new version, and 1.4.1 is
live, so the page goes up with 1.4.2, set C's version. The screenshots stay en-US's, Connect's default for a new
language.

| Field | Limit | Spanish (Mexico) — `es-MX/` |
|---|---|---|
| Name | 30 characters | [`name.txt`](es-MX/name.txt) — 23 |
| Subtitle | 30 characters | [`subtitle.txt`](es-MX/subtitle.txt) — 30 |
| Keywords | 100 bytes | [`keywords.txt`](es-MX/keywords.txt) — 96 |
| Promotional Text | 170 characters | [`promotional-text.txt`](es-MX/promotional-text.txt) — 168 |
| Description | 4000 characters | [`description.txt`](es-MX/description.txt) — 3953 |
| What's New | 4000 characters | [`whats-new.txt`](es-MX/whats-new.txt) — 397 |
| Support URL, Privacy Policy URL | — | en-US's addresses: Connect leaves a new language's empty (section 1) |

- **The description is 1.4.1's in Spanish, shortened to fit,** because Spanish runs longer: its second paragraph is
  cut. Set C's changes to the English page are in it: the 2,000 ml, set C's two Premium lines (the themes keep the
  English names the app shows), and the same cuts, the privacy line among them. **Since 1.4.3** it says the app is in
  Spanish, English, Russian and Uzbek, quotes Siri's Spanish phrases — *"Registra agua en WaterBuddy"* and *"¿Cuánta
  agua llevo hoy en WaterBuddy?"* — and takes the app's own words, *Inicio* for the Home screen and *solo si te
  atrasas* for *Only when behind*. 1.4.2's page said *not Spanish* and *only in English and Russian*.
- **The keywords** take no word already on the en-US page or in the Spanish name and subtitle, and no accents. The
  research is in [`research/2026-11-23/spanish-mexico.md`](research/2026-11-23/spanish-mexico.md).
- **`VerifyListing.sh` reads `es-MX/` since 1.4.2**, its What's New written; the counts above are its own, printed on
  2026-11-27.
