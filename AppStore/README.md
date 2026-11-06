# WaterBuddy 1.4 (build 5) — the App Store upload

Everything the 1.4 version page asks for, in one place: the text, one file per field, and every screenshot.
This folder holds **the current version only** (the owner's ruling, 2026-11-06, when `AppStore/1.4/` and
`Screenshots/` became this one folder). **The main `README.md` stays the master copy** of the text — change
both, or neither.

Each `.txt` file is exactly what goes in its field: open it, select all, copy, paste. The files end
without a newline, so the paste is exact. Every count below was computed from the file, not typed.

## 1. Before you upload — blocking, and yours

- [x] **The privacy policy is live** (#159, 2026-11-06). `Tools/PrivacyPolicy.html` is published as
      `waterbuddy/privacy/index.html` in the `SardorAllaberganov.github.io` repository, and
      `https://sardorallaberganov.github.io/waterbuddy/privacy/` answers with it, byte for byte — the
      branch's policy, which describes Apple Health.
- [ ] **Premium exists in App Store Connect** (#155): the Paid Apps Agreement with banking and tax,
      then the three products — step by step in [`in-app-purchases.md`](in-app-purchases.md).
      *(2026-11-06: **all but the screenshots done.** The agreement, bank account and tax forms read Active.
      Made in Connect: the group *WaterBuddy Premium* (its en-US name, *Use App Name*); *Premium Yearly*
      (1 year upfront, 175 countries, $19.99 US, a free week from 6 Nov 2026 with no end, level 1);
      *Premium Monthly* (1 month, 175 countries, $2.99 US, level 2); *Premium Lifetime* (non-consumable,
      175 countries, $39.99 US) — each with its en-US name and description, Family Sharing **on** and the
      Step 6 note. Still missing on all three: **the review screenshot** of the paywall (Step 6). Left as
      Connect set them: *Monthly with a 12-Month Commitment* not set up, *Multiseat Purchases* allowed,
      tax category matched to the app.)*
- [ ] **Connect's two addresses name 1.1's pages.** App Privacy's *Privacy Policy URL* is a Notion page
      and the live version's *Support URL* a Telegram link (read 2026-11-06). Connect changes the policy's
      address only with a new version: on the 1.4 version, set both to the two pages in section 2.
- [ ] **One real purchase** (#156): a sandbox purchase, a restore and a refund on a real iPhone.
- [x] **The support page is live** (2026-11-06). `Tools/Support.html` is published as
      `waterbuddy/support/index.html` in the same repository, and
      `https://sardorallaberganov.github.io/waterbuddy/support/` answers with it, byte for byte.
- [ ] **The HealthKit capability on the App ID** (#192): `sardor.WaterBuddy` needs it in the developer
      portal — automatic signing adds it when Xcode next signs for a device — and the distribution
      profile must carry it before an archive, or the upload is refused. *(2026-11-06: the App ID has
      it — the development profile carries it. The App Store profile on this Mac predates it; check
      the archive's entitlements before the upload.)*

## 2. The version page

| Field | File | Count |
|---|---|---|
| What's New in This Version | [`whats-new.txt`](whats-new.txt) | 1060 / 4000 |
| Promotional Text | [`promotional-text.txt`](promotional-text.txt) | 161 / 170 |
| Description | [`description.txt`](description.txt) | 3987 / 4000 |
| Keywords | [`keywords.txt`](keywords.txt) | 98 / 100 |
| Support URL | `https://sardorallaberganov.github.io/waterbuddy/support/` — live first (section 1) | |
| Marketing URL | optional | |
| Copyright | `2026 Sardor Allaberganov` | |
| Build | **1.4 (5)** | |
| In-App Purchases and Subscriptions | select **all three** products | |
| App Review notes | [`review-notes.txt`](review-notes.txt) — sign-in **not** required, no demo account | 2446 / 4000 |
| App Review contact | Sardor Allaberganov, `sardorallaberganov96@gmail.com`, 🔴 your phone | |

What's New is written against **1.1**, which is live. P## 3. Screenshots — delete the old ones first, then drag these in name order

Delete every shot already in Connect — 1.1's, and any 6.5″ ones left from 1.0 — since they show the
old app. Fill **only the 6.9″ well**: Connect scales it down for the smaller iPhones. Only the first
three show on search results.

**iPhone 6.9″** — `screenshots/iPhone-6.9/`, 1320 × 2868, PNG, no alpha, **framed**: a headline, the screen
in a drawn phone, one pane lifted out, the six Premium shots tagged *Premium*
(`docs/superpowers/specs/2026-11-06-framed-store-screenshots-design.md`). **The ten are in** (2026-11-06):
`bash Tools/CaptureScreenshots.sh` (1:45–11:45 PM) wrote the raw screens into `screenshots/captures/iPhone-6.9/`,
and `bash Tools/FrameScreenshots.sh` framed them in here. Upload these, not the captures.

| # | File | Headline | Shows |
|---|---|---|---|
| 1 | `1-home.png` | One tap. Watch it fill. | Home at 65 %, *1,300 of 2,000 ml*, a five-day streak |
| 2 | `2-history.png` | Your week, day by day | History's week; *Month* and *Insights* locked for a free user |
| 3 | `3-month.png` | A whole month on one page | Premium: the month before's calendar and figures, a whole month |
| 4 | `4-insights.png` | Insights from your own week | Premium: last week's insights |
| 5 | `5-patterns.png` | Learn when you drink | Premium: the month's patterns |
| 6 | `6-recap.png` | Share your month | Premium: the month before's recap card |
| 7 | `7-schedule.png` | Reminders on your hours | Premium: your own reminder schedule, a quiet day |
| 8 | `8-export.png` | Your servings, as a CSV file | Premium: export, the file shown before it is sent |
| 9 | `9-goal-setup.png` | A goal that fits you | the welcome's goal step |
| 10 | `10-settings.png` | Set your own serving sizes | Settings, the quick-add vessels lifted out |

**Apple Watch** — `screenshots/AppleWatch/1-wrist.png`, 416 × 496: the watch app, synced, at 65 %.
Required, because the app embeds a watch app; one shot meets it.

**Product page header** — `screenshots/ProductPageHeader/1-one-tap.png`, 3840 × 1646:
*One tap. Watch it fill.*

`screenshots/captures/` is not uploaded: it holds the raw captures the framed set is made from, kept so a
changed headline or crop is rendered again without a new capture.

heir own names (`01-home`, `03-history` … `10-settings`).

## 4. Unchanged since 1.1 — check, don't edit

| Field | Value |
|---|---|
| Name | `WaterBuddy - Hydration Tracker` (30/30) |
| Subtitle | `One tap. No account. No cloud.` (30/30) |
| Category | Health & Fitness; Lifestyle secondary (optional) |
| Age rating | **4+** — on a new question, answer on the same facts: no medical or treatment advice |
| Price | Free, with in-app purchases |
| App Privacy | **Data Not Collected** — tick no data type |
| Export compliance | answered in the build (`ITSAppUsesNonExemptEncryption = NO`) |
| Privacy Policy URL | `https://sardorallaberganov.github.io/waterbuddy/privacy/` — live first (section 1) |
| Terms of Use (EULA) | Apple's standard licence — leave the field at its default |

## 5. In-App Purchases — WaterBuddy Premium

**Field by field in [`in-app-purchases.md`](in-app-purchases.md)**: the agreement, the group, each of
the three products, the free week, the levels, the review screenshot and how to take it, the purchase
on a real iPhone, attaching them to 1.4, and what to leave off. In short:

| Product ID | Type | Display name | Description | Price | Offer |
|---|---|---|---|---|---|
| `sardor.WaterBuddy.premium.yearly` | auto-renewable, 1 year, level 1 | `Premium Yearly` | `Every Premium extra, renewed each year.` | $19.99 | free trial, 1 week, new subscribers |
| `sardor.WaterBuddy.premium.monthly` | auto-renewable, 1 month, level 2 | `Premium Monthly` | `Every Premium extra, renewed each month.` | $2.99 | none |
| `sardor.WaterBuddy.premium.lifetime` | non-consumable | `Premium Lifetime` | `Every Premium extra, paid once.` | $39.99 | — |

All three must exist with exactly these IDs: if one fails to load, the paywall sells nothing. Family
Sharing is on for all three, and in Connect it can't be turned off once saved. Select all three on
the 1.4 version page before you submit.
