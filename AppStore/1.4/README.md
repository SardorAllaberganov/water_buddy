# WaterBuddy 1.4 (build 4) — the App Store upload

Everything the 1.4 version page asks for, in one place. Copied on **2026-10-28** from the main
`README.md`'s *App Store Connect* section and from `Screenshots/en-US/` (the store set retaken on
2026-10-26). **The main `README.md` stays the master copy** — change both, or neither.

Each `.txt` file is exactly what goes in its field: open it, select all, copy, paste. The files end
without a newline, so the paste is exact. Every count below was computed from the file, not typed.

## 1. Before you upload — blocking, and yours

- [ ] **The privacy policy is live** (#159). Replace `CONTACT-EMAIL` in `PRIVACY.md` and
      `Tools/PrivacyPolicy.html`, publish the HTML at
      `https://sardorallaberganov.github.io/waterbuddy/privacy/`, and open it to see it load.
- [ ] **Premium exists in App Store Connect** (#155): the Paid Apps Agreement with banking and tax,
      then the three products — step by step in [`in-app-purchases.md`](in-app-purchases.md).
- [ ] **One real purchase** (#156): a sandbox purchase, a restore and a refund on a real iPhone.
- [ ] **A Support URL.**

## 2. The version page

| Field | File | Count |
|---|---|---|
| What's New in This Version | [`whats-new.txt`](whats-new.txt) | 830 / 4000 |
| Promotional Text | [`promotional-text.txt`](promotional-text.txt) | 164 / 170 |
| Description | [`description.txt`](description.txt) | 3992 / 4000 |
| Keywords | [`keywords.txt`](keywords.txt) | 98 / 100 |
| Support URL | 🔴 yours | |
| Marketing URL | optional | |
| Copyright | 🔴 e.g. `2026 Sardor Allaberganov` | |
| Build | **1.4 (4)** | |
| In-App Purchases and Subscriptions | select **all three** products | |
| App Review notes | [`review-notes.txt`](review-notes.txt) — sign-in **not** required, no demo account | 1998 / 4000 |
| App Review contact | 🔴 your name, phone, email | |

What's New is written against **1.1**, which is live. Promotional Text can be changed later
without a new build.

## 3. Screenshots — delete the old ones first, then drag these in name order

Delete every shot already in Connect — 1.1's, and any 6.5″ ones left from 1.0 — since they show the
old app. Fill **only the 6.9″ well**: Connect scales it down for the smaller iPhones. Only the first
three show on search results.

**iPhone 6.9″** — `screenshots/iPhone-6.9/`, 1320 × 2868, PNG, no alpha:

| # | File | Shows |
|---|---|---|
| 1 | `1-home.png` | Home at 65 %, *1,300 of 2,000 ml*, a five-day streak |
| 2 | `2-history.png` | History's week; *Month* and *Insights* locked for a free user |
| 3 | `3-month.png` | Premium: October's calendar — 20 of 25 days on goal |
| 4 | `4-insights.png` | Premium: last week's insights, 18–24 October |
| 5 | `5-patterns.png` | Premium: the month's patterns |
| 6 | `6-recap.png` | Premium: September's recap card |
| 7 | `7-goal-setup.png` | the welcome's goal step |
| 8 | `8-settings.png` | Settings, the Premium card first |

**Apple Watch** — `screenshots/AppleWatch/1-wrist.png`, 416 × 496: the watch app, synced, at 65 %.
Required, because the app embeds a watch app; one shot meets it.

**Product page header** — `screenshots/ProductPageHeader/1-one-tap.png`, 3840 × 1646:
*One tap. Watch it fill.*

Each file is a byte-identical copy of its original in `Screenshots/en-US/`, where the capture
scripts keep their own names (`01-home`, `03-history` … `10-settings`).

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
