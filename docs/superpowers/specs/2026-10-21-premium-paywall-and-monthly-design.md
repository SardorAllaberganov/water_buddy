# Premium's paywall, its card and the monthly plan — design

**Status:** approved by the owner in conversation on 2026-10-21, in this order: the paywall and card
drawn on the design canvas (https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy, private to the owner)
after the owner judged 1.4.1's first paywall "very poor"; **set A — Understand** first ("A"); **a
monthly plan** beside the yearly and the lifetime ("also monthly subs"); the prices and trial —
**Monthly $2.99 with no trial, Yearly $19.99 with a free week, Lifetime $39.99** ("a"); **personal AI
insights on Apple's on-device model**, named *Personal AI insights* using Apple Intelligence ("a",
then "personal AI insights that is using Apple Intelligence"); the five-step order (§1, "yes"); and
this step's design, presented in eight parts with the grace-period ruling inside it ("ok"). This
document writes that design out for the owner's review **before** the plan and before any code.

It is **step 1 of 5** and amends `docs/superpowers/specs/2026-10-21-premium-foundation-design.md`
(**the foundation spec**) where it says so; everything it does not amend stands, D1–D8 included. It
supersedes the paywall view and the Settings card built in that spec's plan, Task 6
(`docs/superpowers/plans/2026-10-21-premium-foundation.md`), which were staged and never shipped.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `b981374` with the foundation's
Task 6 staged, on 2026-10-21. Claims are marked **stated** (an Apple source says it — the foundation
spec's [CE], [MS], [STS], [PO] and [ARG], read that day), **measured** (read or run on this toolchain),
**inferred**, or **unconfirmed**.

## 1. Where this sits

Premium launches as **set A — Understand**, in five steps, each with its own spec, plan and gate:

| Step | Builds | Roadmap |
|---|---|---|
| **1** | **this document** — the monthly plan, the paywall and the Settings card as designed, set A declared and not on sale | 1.4.1, amended |
| 2 | month view and full history; History's locked Month tab for a free user | 1.4.2 |
| 3 | patterns | 1.4.6 |
| 4 | personal AI insights — Apple's on-device model, the app's own written insights where it is unavailable | new item, set A |
| 5 | the monthly recap, and set A put on sale | 1.4.7 |

Nothing anyone pays for is missing at any point: a Release build offers the paywall only once step 5
has put set A on sale (§3.6). Until then a DEBUG build launched with `-WaterBuddyPremium` shows all of
it, as today.

## 2. What exists today (measured)

- **The foundation, committed** (`e7b7f38`): `PremiumAccess` (the decision and its words),
  `PremiumSet` (no case), `PremiumStore` and its `Source`, 27 strings, `WaterBuddyTests/WaterBuddy.storekit`
  with two products — `sardor.WaterBuddy.premium.yearly` ($19.99, a one-week free introductory offer,
  `groupNumber` 1) and `sardor.WaterBuddy.premium.lifetime` ($39.99) — and 46 tests.
- **Staged, never shipped**: the foundation's Task 6 — the first `PaywallView`, a `PremiumCard` as the
  fifth Settings card, the store wired into `WaterBuddyApp`, `PaywallOfferTests` (4) and
  `PremiumUITests` (2) — and one review fix: `prepare()` keeps a purchase under way
  (`openingTheSheetAgainWhileBuyingKeepsThePurchase`).
- **The scheme's Run action** names the local configuration
  (`identifier = "../../WaterBuddyTests/WaterBuddy.storekit"`), written by the owner in Xcode
  (unstaged), with `-WaterBuddyPremium YES` among its launch arguments and, by mistake, its
  environment variables.
- **Settings carries no primary surface** (no `.primarySurface` in `SettingsView.swift`).
- **`resolve` drops a subscription whose `expires` is at or before `now`** — the foundation spec §3.2
  — which contradicts its own §3.4 (*a billing grace period → still Premium*): in grace the latest
  transaction's period has already ended (inferred from [CE]'s inclusion of `inGracePeriod`).

## 3. The design

### 3.1 The products

| Product ID | Type | Group level | Introductory offer |
|---|---|---|---|
| `sardor.WaterBuddy.premium.yearly` | auto-renewable, group *WaterBuddy Premium* | 1 (highest) | one week free |
| `sardor.WaterBuddy.premium.monthly` | auto-renewable, same group | 2 | none |
| `sardor.WaterBuddy.premium.lifetime` | non-consumable | — | — |

**New: the monthly plan.** In the same group, so a subscriber holds one of the two, never both; the
yearly ranks above it, so moving from monthly to yearly is an upgrade (the effect of an upgrade —
immediate, with the unused month refunded pro rata — is **unconfirmed**: read in the plan's probe).
Eligibility for the free week is StoreKit's answer per group, so someone who has held the monthly
plan may not be offered the trial — StoreKit decides, and the paywall draws what it says. Prices are
the owner's in App Store Connect; this document and the local configuration use **$2.99**, **$19.99**
and **$39.99**, and the app draws whatever StoreKit returns. Family Sharing is on for all three.

### 3.2 `PremiumAccess` — the decision (amends the foundation spec §3.2)

- `productIDs` — three, in the order the paywall draws them: monthly, yearly, lifetime.
- `Plan.Kind` gains `.monthly`. `Status` gains `.monthly(until: Date)`.
- **The grace-period ruling (the owner's).** `resolve(_ entitlements:)` **trusts StoreKit's current
  entitlements for whether a subscription is held**: it ignores an unknown product ID and anything with
  a `revoked` date, and nothing else. [CE] states current entitlements carry a subscription that is
  subscribed or in its billing grace period, and leave out one that has lapsed; checking the period's
  end again, as the foundation did, read a subscriber in grace — and one opening the app in the
  moment between a period's end and the renewal's transaction — as free. The function **loses its
  `now:` parameter**, which had no other use. A lapsed subscription now reads free on the next read in
  which StoreKit no longer lists it — the foundation's *next read* (§3.4), with StoreKit, not our
  clock, deciding.
- **Precedence**: a lifetime purchase wins; else the subscription with the latest `expires`, the yearly
  on a tie; else `.free`.
- `Status.line(in:locale:now:)` — *Yearly, until 21 October 2027* / *Monthly, until 21 November 2026*
  while the date is ahead; the plan's name alone once it has passed, which is what a subscriber in
  grace holds; *Lifetime*. `now` is the store's injected clock, which the card and the sheet take from
  `PremiumStore` — never a bare `Date()` in a view (rule `30-rollover`'s *The clock*).
- `Plan` gains `amount: Decimal` — StoreKit's `Product.price` — beside `price`, the `displayPrice`
  string still drawn as it comes.
- **The saving**: `static func yearlySaving(yearly: Decimal, monthly: Decimal) -> Double?` —
  `1 − yearly ÷ (12 × monthly)`, rounded **down** to a whole percent, `nil` when it is under 1 % or
  either price is not positive. At the configuration's prices, 44 %. It is formatted with the
  locale's own percent style, never by a `%` in a key.

### 3.3 `PremiumStore` (amends the foundation spec §3.3)

- **Plans are loaded only when all three products return** (plan P7, extended): anything less is
  *unavailable*, never a paywall with a plan missing.
- **A read that a newer read overtook does not publish** (the final review's minor 4): every `refresh`
  takes a number; only the latest one sets `state`.
- **Restore** has an in-flight state and an answer (minor 5): *restoring*, then either the held plan or
  *No purchases to restore.*
- **Manage** is offered only where `AppStore.showManageSubscriptions(in:)` works — not on a Mac
  (minor 6, [MS]).

### 3.4 The paywall (replaces the foundation spec §3.7's layout)

`WaterBuddy/PaywallView.swift`, still `.sheet(item:)` on `PaywallView.Entry`, its own
`AuroraBackground()` and `.preferredColorScheme(.dark)`. As drawn on the canvas, top to bottom:

1. **A close button** — glass, 44 pt, *×*, its label *Not now* — and **the promise** in a glass
   capsule: a check and *Logging water is free, always.*
2. **A preview** — decoration, hidden from VoiceOver: a month of goal dots and a row of hour bars in
   `Aurora.cyan` and white, **no figure, no date and no name**. It is not the user's data and does not
   pretend to be; step 2 may draw the user's own month here.
3. **WaterBuddy Premium**, and *See how you really drink, and what would help.*
4. **The set's features**, one row each — a glass icon tile, a title, one line — read from
   `PremiumSet.allCases` (§3.6): *Month view and full history*, *Your patterns*, *Personal AI insights*
   (*Using Apple Intelligence, private on your iPhone*), *A monthly recap*. Under them, *New Premium
   features arrive in updates, included.* The insights row's wording on a phone without Apple
   Intelligence is step 4's to decide; the paywall is not offered in Release before then.
5. **Three plans**, side by side, the **yearly selected** when the sheet opens:
   - *Monthly* — the price, *a month*, *Cancel any time*;
   - *Yearly* — a *Best value* badge, the price, *a year · Save 44 %* (the saving, §3.2; left out when
     `nil`), and, when StoreKit says the user is eligible, *1 week free* (Foundation's words for the
     length, plan P3);
   - *Lifetime* — the price, *once*, *Yours for good*.
   **The price charged is the largest figure on each tile**; the trial is a smaller line under it
   ([ARG] 3.1.2(a), inferred from its wording on clear pricing). Each tile is one button — label the
   plan's name, value its full price line, `.isSelected` on the chosen one — marked with
   `LiquidGlass.Selection`'s fill and rim (rule `60-design-system`). At the accessibility text sizes
   the three stand in a column instead (`ViewThatFits`), each at least 44 pt tall (rule
   `65-accessibility`).
6. **The primary surface**, for the chosen plan: *Subscribe* for the monthly, and for the yearly when
   no free week is offered; *Start Free Trial* for the yearly with its free week; *Buy Lifetime* — no
   length in a label (plan P4).
7. **The terms** for the chosen plan, then **Restore Purchases · Terms of Use · Privacy Policy**, each
   at least 44 pt tall, wrapping to a column when they do not fit.

**Its states** (amends the foundation spec §3.7's table):

| State | What the sheet shows |
|---|---|
| loading | the three tiles' places held quiet; the button disabled |
| unavailable | *The App Store can't be reached right now.* and *Try Again* |
| buying | the button's progress; the sheet cannot be swiped away; the close button stays (a purchase that never answers must not trap the user — the foundation plan's Task 8 ruling) |
| pending | *Waiting for approval.* |
| failed | *The purchase didn't go through.*; the sheet stays |
| bought | **Thank you** and the plan held, with a *Done* primary surface — the sheet **does not close itself** (the final review's minors 1 and 2: the thank-you was never drawn, and a timed close left VoiceOver behind) |
| restoring | *Restore Purchases* shows its progress |
| nothing to restore | *No purchases to restore.* |
| already Premium | *You have Premium.*, the plan's line, and *Done* in place of the plans |

### 3.5 The Settings card (replaces the foundation spec §3.6)

- **First on the screen**, above the goal — the owner's ruling, reversing *the goal still leads*. The
  comment that says so in `SettingsView.swift` changes with it. Drawn only where the paywall is offered
  and the store is not `.checking`, as before.
- **Free**: a sparkle tile, **WaterBuddy Premium**, *Extras for the way you drink. Logging water stays
  free.*, three decorative previews (*Month view*, *Patterns*, *AI insights* — shapes, no figures,
  hidden from VoiceOver), and **See Premium** on the primary surface — Settings' only one (rule
  `60-design-system`: a screen carries at most one).
- **Held**: *You have Premium.*, the status line (§3.2), and *Manage Subscription* — shown whenever a
  **subscription** is among the entitlements, beside a lifetime purchase too (the final review's minor
  3), and never on a Mac. Each set A feature adds its shortcut row here in its own step; step 1 adds
  none.
- **The rim**: the free card's pane is the standard `.settingsCard()` glass with a 1.5-pt rim stroked
  in `Aurora.cyan` → `Aurora.magenta` → `Aurora.blue`, drawn by one new modifier, `.premiumRim()`
  (`WaterBuddy/PremiumRim.swift`, app-only), the only place that gradient is spelled. The canvas's
  near-opaque fill behind the card is not taken: the pane stays glass (rule `60-design-system`).

### 3.6 The switch and `PremiumSet` (amends the foundation spec §3.5)

- `PremiumSet` gains **`.understand`**, with its features in order — month view, patterns, AI insights,
  recap — each a title key, a line key and a symbol, so the paywall and the card draw from the set
  rather than from a list of their own.
- **`isOnSale: Bool`**, `false` for `.understand` until step 5 changes it, pinned by a test that names
  the step. A case existing no longer turns the paywall on — a set is on sale only when every feature
  it lists is built.
- **The Release switch** becomes: offered only when **a set is on sale and `PaywallView.privacyPolicy`
  is an `https` URL** (the final review's minor 7) — so a release cannot ship a paywall with a dead
  privacy link, whatever is forgotten. DEBUG is unchanged: the launch argument alone.

### 3.7 The words

New keys in `WaterBuddy/Localizable.xcstrings` only (app-only; none joins `sharedKeys`), each with
`en`, `ru` and `uz`, positional specifiers, no counted noun:

| Key | Use |
|---|---|
| `Monthly` | the tile, its VoiceOver label |
| `a month` · `a year` · `once` | the tiles' period lines |
| `%1$@ a month` | the monthly's full price line (VoiceOver) |
| `Save %1$@` | the yearly's saving, `%1$@` the formatted percent |
| `%1$@ free` | the trial line, `%1$@` Foundation's length |
| `Best value` · `Cancel any time` · `Yours for good` | the tiles |
| `%1$@ is charged each month until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.` | the monthly's terms |
| `Monthly, until %1$@` | the status line |
| `See how you really drink, and what would help.` | the paywall's line under the title |
| `Month view and full history` · `Every day you have logged, a month at a glance` | feature row |
| `Your patterns` · `When you drink, weekdays against weekends` | feature row |
| `Personal AI insights` · `Using Apple Intelligence, private on your iPhone` | feature row |
| `A monthly recap` · `Your month in one card, yours to share` | feature row |
| `New Premium features arrive in updates, included.` | under the rows |
| `Month view` · `Patterns` · `AI insights` | the card's previews' captions |
| `Done` · `No purchases to restore.` | the states |

Kept from the foundation: *WaterBuddy Premium*, *Logging water is free, always.*, *Not now*, *Yearly*,
*Lifetime*, the yearly and lifetime price lines and terms, *Start Free Trial*, *Subscribe*, *Buy
Lifetime*, *Restore Purchases*, *Terms of Use*, *Privacy Policy*, the five state lines, *Premium*,
*See Premium*, *Manage Subscription*, *Extras for the way you drink. Logging water stays free.*, *You
have Premium.*, *Thank you*, *Yearly, until %1$@*. **"Apple Intelligence" in user-facing copy is
checked against Apple's guidelines for the name before set A goes on sale** (step 4); until then it is
seen only in DEBUG. The Russian and Uzbek are the plan's draft, for the owner's sweep.

## 4. What it touches

| File | Change |
|---|---|
| `WaterBuddy/PremiumAccess.swift` | `.monthly`, `resolve` without `now`, precedence, `Status.line(…now:)`, `amount`, `yearlySaving` |
| `WaterBuddy/PremiumSet.swift` | `.understand`, its features, `isOnSale` |
| `WaterBuddy/PremiumStore.swift` | three products, the read number, restore's states, manage's Mac check, the monthly `Plan` |
| `WaterBuddy/PaywallView.swift` | rewritten — §3.4; the switch — §3.6 |
| `WaterBuddy/PremiumRim.swift` | new — §3.5 |
| `WaterBuddy/SettingsView.swift` | the card first, rewritten — §3.5 |
| `WaterBuddy/WaterBuddyApp.swift` | comment only — "Built before anything else" (the final review's minor 10) |
| `WaterBuddy/Localizable.xcstrings` | §3.7 |
| `WaterBuddyTests/WaterBuddy.storekit` | the monthly product, `groupNumber` 2 |
| `WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme` | the StoreKit reference kept; the stray environment variable and the launch argument removed before staging |
| `WaterBuddyTests/…`, `WaterBuddyUITests/…` | §6 |

No `project.pbxproj` edit (every file lands in a synchronized folder), no exception set change, no
key, no entitlement, no Info.plist key. Nothing reaches the widget or the watch.

## 5. What this amends in the rules

Typed into the rule files **unstaged**, for the owner, before any code. Approving this document
approves this wording.

- **`70-privacy`**, *StoreKit, for the review request and for Premium*: "Premium's two products,
  `PremiumAccess.productIDs` — a yearly subscription and a lifetime purchase" becomes "Premium's three
  products, `PremiumAccess.productIDs` — a monthly and a yearly subscription and a lifetime purchase";
  *Named calls* gains `Product.SubscriptionInfo.isEligibleForIntroOffer` and `Product.price` (the
  final review's minor 8); *The paywall's moment*'s last sentence becomes "A Release build offers it
  only while a set is on sale and the privacy policy link is set (`PaywallView.isOffered(arguments:)`)".
- **`60-design-system`**, *Glass*, a bullet after the selection bullet: "Premium's card is marked with
  `.premiumRim()` — `Aurora.cyan`, `Aurora.magenta` and `Aurora.blue` stroked around a standard pane —
  and nowhere else. Never a gradient stroke written in a view".
- **`docs/ROADMAP.md`** §1, *Pricing is yearly plus lifetime; no weekly plans* becomes *Pricing is
  monthly, yearly and lifetime — a free week on the yearly alone; no weekly plans* (the owner's,
  2026-10-21); §5 gains the AI insights item in set A, and the five steps.

## 6. Testing

Tests first, each run and seen **RED** before its code (rule `85-testing`). **Changed by the owner's
grace ruling, not narrowed to pass:** `aYearlyEndingAtThisInstantIsOver` and `aYearlyThatEndedIsOver`
assert the opposite of the new rule and are **replaced** by `aListedYearlyPastItsEndIsStillHeld` and
`aSubscriptionInItsGracePeriodIsStillPaid`; `anExpiryPassingWhileTheAppRunsReadsFreeOnTheNextRead`
becomes `aSubscriptionStoreKitStopsListingReadsFree`; and the store's
`anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead` keeps its name and its last assertion,
the fake's held entitlements emptied on the second read instead of the clock moved. Every other
foundation test stands, its `resolve` call without `now:`.

- **`PremiumAccessTests`** (not `@MainActor`): a monthly → `.monthly(until:)`; a monthly beside a
  lifetime → `.lifetime`; a monthly and a yearly → the later `expires`, the yearly on a tie;
  `productIDs` three, distinct, ours, in the paywall's order; the status line with its date ahead and
  passed, in `en`, `ru`, `uz`; `yearlySaving` at 19.99/2.99 → 44 %, under 1 % → `nil`, a zero price →
  `nil`.
- **`PremiumWordsTests`**: every tile line and the monthly terms in all three languages, the saving
  formatted by the locale's percent style, no digit in any button label.
- **`PremiumSetTests`** (new, not `@MainActor`): `.understand` lists its four features in order, every
  key resolves; `.understand.isOnSale == false` — the test says step 5 changes it.
- **`PaywallOfferTests`**: DEBUG unchanged; Release offered only with a set on sale **and** an `https`
  privacy URL — a set on sale with no link → not offered; a link with nothing on sale → not offered.
  `theLinksAreApplesTermsAndAPageOfOurs` stands and stays red until the owner's URL.
- **`PremiumStoreTests`** (gains `.timeLimit(.minutes(1))`, minor 9): three plans load; two → unavailable;
  a read overtaken by a newer one does not publish; restore → *restoring* then the held state, or
  *nothing to restore*; manage is not offered on a Mac.
- **`StoreKitSessionTests`**: all three products load, the yearly with its free week and the monthly
  with none; a bought monthly reads `.monthly`; a monthly then a yearly in the same group reads
  `.yearly` (the upgrade, measured against §3.1's unconfirmed claim).
- **`LocalizationTests`**: every new key resolves in `en`, `ru` and `uz`.
- **`PremiumUITests`**: an ordinary run has no card, read after the first StoreKit read has had time
  to answer (minor 9); with `-WaterBuddyPremium` the card is the first card, one element, and opens the
  sheet, where the title, the promise, the four feature titles, *Restore Purchases*, *Terms of Use*,
  *Privacy Policy* and *Not now* each resolve to one element, and *Not now* closes it. It asserts
  nothing that needs products to load.

## 7. Verification

- **The gate**: rule `85-testing`'s five invocations, and the UI suite again on `OS=26.5`. The known
  red test (the privacy URL) and the known flake (#140) are reported by name, never hidden.
- **Warnings**: clean builds of a `HEAD` export and of the change, all four schemes, by file and
  message. The `StoreKitTest` header line found in the foundation's gate is the owner's open ruling
  (§8) and is reported, not counted as this step's.
- **By hand, with the owner**: the foundation's walk (its §7.3), on the owner's iPhone or on *WaterBuddy
  Probe 27*, now with three plans — each bought, the monthly upgraded to the yearly, a refund, Ask to
  Buy, restore with and without a purchase, *Manage Subscription*; the sheet and the card in English,
  Russian and Uzbek, at an accessibility text size, under VoiceOver and with Reduce Transparency. The
  new colour pairs — the tiles' lines on their panes, the promise, the terms, the footer — measured
  off renders into `docs/DESIGN.md`; one that falls short of 4.5:1 is raised to the lowest value that
  passes and measured again.

## 8. Open questions and what is not in scope

- **The privacy policy URL** — the owner's (#159). Building does not wait for it; a Release offer
  cannot happen without it (§3.6).
- **The `StoreKitTest` header warning** — accept it into the baseline, suppress it with a build
  setting (a `project.pbxproj` change), or drop the live session tests: the owner's.
- **#157** — `anExpiredYearlyReadsFree` stays disabled; under the grace ruling it asserts StoreKit's
  behaviour, which the test environment does not model. Keep, change or drop: the owner's.
- **App Store Connect** (#155) gains the monthly product, its group level and its prices.
- **Not in scope**: the month view, patterns, AI insights and the recap (steps 2–5); the user's own
  month in the preview; offer codes, promotional and win-back offers; price testing; a paywall
  opened from anywhere but Settings — the locked Month tab is step 2's.

## 9. Sequence

1. Probe, in a throwaway copy: the monthly product loads beside the other two from the local
   configuration; a monthly-then-yearly purchase in one group — what `currentEntitlements` answers
   (§3.1's unconfirmed claim).
2. Type §5's wording into the rule files, unstaged.
3. `PremiumAccess` and `PremiumSet` — tests first, the grace ruling's replacements among them.
4. `PremiumStore` — tests first; then `StoreKitSessionTests`.
5. The words; `PremiumRim`; the paywall; the card — then the UI tests.
6. By hand with the owner (§7), the gate, the warnings, a final review, the records — the
   foundation's records included, since its Task 6 never shipped as built.
