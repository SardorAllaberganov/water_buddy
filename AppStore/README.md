# WaterBuddy 1.4.1 (build 7) — the App Store upload

Everything the 1.4.1 version page asks for, in one place: the text, one file per field and per language, and
every screenshot. This folder holds **the current version only** (the owner's ruling, 2026-11-06). **The main
`README.md` stays the master copy of the en-US text** — change both, or neither. `en-GB/` and `ru/` are their
own: English (U.K.) is en-US's text word for word but for its keywords, and Russian is written for Russian
searches. After any change to any field, run `bash Tools/VerifyListing.sh`: it counts every field in every
language, checks the keyword rules, and compares en-US with `README.md` and en-GB with en-US.

Each `.txt` file is exactly what goes in its field: open it, select all, copy, paste. The files end without a
newline, so the paste is exact. Every count below is the one `VerifyListing.sh` printed on 2026-11-20.

The search research the words come from is in [`research/2026-11-20/`](research/2026-11-20): the report, the
terms tried, and the ranks read in the US, Russian and Uzbek stores.

## 1. Before you submit — in order, and yours

1. **Publish the policy again, first.** 1.4.1 changes when the app asks for a rating, and the policy says so:
   publish `Tools/PrivacyPolicy.html` as `waterbuddy/privacy/index.html` in the `SardorAllaberganov.github.io`
   repository, then check that `https://sardorallaberganov.github.io/waterbuddy/privacy/` reads *after a pour
   on the Home screen reaches your daily goal* and *Last updated 20 November 2026*. The policy promises it
   changes before or with the app.
2. **A new version.** 1.4 is live (released 2026-11-13, read from Apple's lookup on 2026-11-20), so Connect
   offers **+ Version**: make **1.4.1**.
3. **App Information — the names.** en-US: the name and subtitle in section 2. Then add **English (U.K.)** and
   **Russian** as localizations, each with its own name and subtitle. Connect changes a name only with a new
   version, which is why it happens now. If Connect refuses a name as taken, use `Water Tracker: WaterBuddy`
   or `Трекер воды — WaterBuddy`: write it into the language's `name.txt`, run `VerifyListing.sh`, then paste.
   If a new language asks for its own Privacy Policy URL, it is the same address (section 4).
4. **The version page, language by language** (the language menu at the top right): Promotional Text,
   Description, Keywords, What's New and Support URL, each from section 2.
5. **The screenshots** — section 3. English (U.K.) and Russian show en-US's set (the ruling R3 of
   `docs/superpowers/specs/2026-11-20-release-1-4-1-design.md`); check that each language shows the ten.
6. **Build 7** — *1.4.1 (7)*, once Connect has processed it.
7. **The three purchases** were sold with 1.4: check that they read *Approved*. One that does not is selected
   on this version page.
8. **Three checks by hand, on an iOS 27 simulator, before submitting** — nothing automated sees them:
   - the paywall on a simulator in a decimal-comma region (this Mac's are `en_UZ`) says *save 44%* (#162);
   - with `-WaterBuddyReviewPrompt`, the first pour on Home that reaches the goal brings the rating request
     after the confetti, and an *Undo* inside that pause brings none;
   - Settings' *Only when behind*: for a free user a tap opens the paywall, and with Premium held it turns on
     and off. App Review's notes send reviewers to this row. On 2026-11-21 a quick tap there did nothing while
     the app was busy, a person's tap and not only the UI tests' (#229). It was fixed the same day, and this
     check passed by hand on the fixed build.

   All three passed on 2026-11-21, the third after its fix. Run them again only if the code changes before you
   submit.
9. **Submit for Review.**
10. **On the day 1.4.1 is released:** the prices by country — section 5.

Still open from 1.4, unchanged: **one real purchase** (#156) — a sandbox purchase, a restore and a refund on a
real iPhone.

## 2. The fields

The name and subtitle are on *App Information*; the rest is on the version page.

| Field | Limit | en-US — `AppStore/` | English (U.K.) — `en-GB/` | Russian — `ru/` |
|---|---|---|---|---|
| Name | 30 characters | [`name.txt`](name.txt) — 26 | [`name.txt`](en-GB/name.txt) — 26 | [`name.txt`](ru/name.txt) — 23 |
| Subtitle | 30 characters | [`subtitle.txt`](subtitle.txt) — 30 | [`subtitle.txt`](en-GB/subtitle.txt) — 30 | [`subtitle.txt`](ru/subtitle.txt) — 29 |
| Keywords | 100 bytes | [`keywords.txt`](keywords.txt) — 99 | [`keywords.txt`](en-GB/keywords.txt) — 98 | [`keywords.txt`](ru/keywords.txt) — 100 |
| Promotional Text | 170 characters | [`promotional-text.txt`](promotional-text.txt) — 136 | [`promotional-text.txt`](en-GB/promotional-text.txt) — 136 | [`promotional-text.txt`](ru/promotional-text.txt) — 168 |
| What's New | 4000 characters | [`whats-new.txt`](whats-new.txt) — 133 | [`whats-new.txt`](en-GB/whats-new.txt) — 133 | [`whats-new.txt`](ru/whats-new.txt) — 123 |
| Description | 4000 characters | [`description.txt`](description.txt) — 3987 | [`description.txt`](en-GB/description.txt) — 3987 | [`description.txt`](ru/description.txt) — 3993 |

What's New is written against **1.4**, which is live. Promotional Text can be changed later without a new
build; the name, subtitle and keywords cannot.

The rest of the page, as 1.4 had it:

| Field | Value |
|---|---|
| Support URL | `https://sardorallaberganov.github.io/waterbuddy/support/` — the same in every language |
| Marketing URL | optional |
| Copyright | `2026 Sardor Allaberganov` |
| Build | **1.4.1 (7)** |
| In-App Purchases and Subscriptions | the three of section 5, approved with 1.4 |
| App Review notes | [`review-notes.txt`](review-notes.txt) — 2446 / 4000 bytes, unchanged; sign-in **not** required, no demo account |
| App Review contact | Sardor Allaberganov, `sardorallaberganov96@gmail.com`, 🔴 your phone |

## 3. Screenshots — remove 1.4's ten, then drag in these in name order

Open **View All Sizes in Media Manager** from the version page. In each iPhone well, **Remove All** (1.4's ten),
then drag in the folder's ten in name order:

1. *iPhone with Dynamic Island (medium display)*, the one Connect requires — `screenshots/iPhone-6.3/`. It
   takes only 1206 × 2622 or 1179 × 2556 and refuses a 6.9″ shot (read 2026-11-13).
2. *iPhone with Dynamic Island (large display)*, optional — `screenshots/iPhone-6.9/`.

The *Apple Watch Series 12* well keeps `screenshots/AppleWatch/1-wrist.png` (416 × 496: the watch app, synced,
at 65 %), and the product page header keeps `screenshots/ProductPageHeader/1-one-tap.png` (3840 × 1646, *One
tap. Watch it fill.*). Neither changes. Only the first three iPhone shots show on search results.

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
| 9 | `9-patterns.png` | Learn when you drink | Premium: the month's patterns |
| 10 | `10-recap.png` | Share your month | Premium: the month before's recap card |

The free core takes 1–5 and Premium 6–10, each Premium shot tagged *Premium*. 1.4's goal step and export leave
the set (R4); their captures stay in `captures/`.

*(2026-11-21: the two new captures were taken on the capture pair with the simulator tool, every figure at 65 %
and 1,300 ml, and the ten framed; `iPhone-6.9/` and `iPhone-6.3/` hold 1.4.1's ten under the names above. 1.4's
ten are gone from both folders.)*

How each set is made:

- `bash Tools/CaptureScreenshots.sh` (1:45–11:45 PM) writes the app's own screens into
  `screenshots/captures/iPhone-6.9/`, on a throwaway store seeded with three months of servings. 1.4's capture
  of 2026-11-06 is kept there.
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
| Privacy Policy URL | `https://sardorallaberganov.github.io/waterbuddy/privacy/` — published again first (section 1) |
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

**Prices by country — set in Connect, not in the build, on the day 1.4.1 is released.** Three tiers by the
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
- Uzbekistan is billed in US dollars, at the lower tier.
- **Never mention another country's price**, in the app or on the page: App Review can read it as misleading.
- Which country is in which group: the World Bank's lists, as the release playbook keeps them, in
  `~/.claude/skills/aso/references/price-tiers.md` (the 2027 fiscal year's lists, published each July).
