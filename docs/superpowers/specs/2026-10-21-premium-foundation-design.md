# Premium's foundation — design

**Status:** the outline was approved by the owner in conversation on 2026-10-21, section by section
(four "yes"), with three decisions taken as recommended: **D1**, 1.4.1 is built as a foundation and
ships **hidden** until the first set exists; **D2**, the yearly plan opens with a **one-week free
trial**; **D3**, the paywall is **our own**, drawn in the app's glass and the app's language, not
StoreKit's views. **D4** to **D8** were presented inside the four sections and approved with them.
This document writes the outline out, with §5's rule wording, for the owner's review **before** the
plan and before any code (`docs/ROADMAP.md` §8). Roadmap item **1.4.1**, taken ahead of 1.3.3 on the
owner's choice the same day. The written document was approved by the owner on 2026-10-21 ("ok"),
before the plan (`docs/superpowers/plans/2026-10-21-premium-foundation.md`).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `0be24f9` on 2026-10-21. **SDK** is
Xcode 27.0's; the deployment floor is iOS 17.0 (rule `15-project`). Six Apple pages were read on
2026-10-21 through their documentation JSON: `Transaction.currentEntitlements` (**[CE]**),
`AppStore.showManageSubscriptions(in:)` (**[MS]**), `SKTestSession` and its
`init(configurationFileNamed:)` (**[STS]**), `Product.purchase(options:)` (**[PO]**), and the App
Review Guidelines (**[ARG]**, 3.1.1, 3.1.2 and 5.1.1(i)). Each claim below is marked **stated** (an
Apple source says it), **measured** (read or run on this toolchain), **inferred**, or
**unconfirmed**. Amended on 2026-10-21 by the plan's decisions
(`docs/superpowers/plans/2026-10-21-premium-foundation.md`, P1, P3–P6, P11); each amendment says so.

## 1. What is being built

Everything a paying user will need, and nothing they can buy yet: two products, a purchase, a
restore, a paid state read from StoreKit, and a paywall in the app's own glass and language — all
switched off in a Release build until the first Premium set exists (`docs/ROADMAP.md` §5, *Sold as
sets*). A DEBUG build launched with `-WaterBuddyPremium` shows all of it.

It stores nothing. The paid state is read from StoreKit at launch, on every return to the foreground
and on every transaction update, and kept in memory only. Nothing reaches the widget, the watch or
either store.

It is held to *The Premium line* (`docs/ROADMAP.md` §1): no way of logging is ever Premium; Premium
reads only what the free app stores, so a lapse loses and hides nothing; everything is worked out on
the device.

## 2. What exists today

- **StoreKit is one call in one file** (measured). `HomeView.swift` imports it for
  `@Environment(\.requestReview)`; rule `70-privacy`'s *The review request is the one use of
  StoreKit* permits exactly that and says 1.4.1 "writes its own amendment here". Two DocC comments
  repeat the ruling — `HomeView.swift:198` and `DataManager.swift:1422` — and go stale with it (§4).
- **No product code, no `.storekit` file, no `StoreKitTest` import** anywhere in the repository
  (measured).
- **Settings is four cards** — goal, vessels, reminders, language — in one `ScrollView`, each
  arriving and receding (`SettingsView.swift`, measured). The bar holds three tabs and
  `theBarHoldsThreeTabs` is the tripwire (rule `65-accessibility`), so Premium gets no tab.
- **A DEBUG opt-in has a precedent**: `ReviewPrompt.isEnabled(arguments:)` reads
  `-WaterBuddyReviewPrompt` in DEBUG and answers `true` in Release (measured).
- **A struct of closures over a system service has a precedent**: `ReminderScheduler`, with
  `static func live()` building every closure fresh (rule `80-notifications`, rule `43-concurrency`).
- **The app shows no privacy policy link** (measured: no URL in any source file). [ARG] 5.1.1(i)
  states that every app must link to its privacy policy "within the app in an easily accessible
  manner". See §8, O1.

## 3. The design

### 3.1 The products (D2)

| Product ID | Type | Notes |
|---|---|---|
| `sardor.WaterBuddy.premium.yearly` | auto-renewable subscription, group *WaterBuddy Premium* | introductory offer: one week free |
| `sardor.WaterBuddy.premium.lifetime` | non-consumable | wins over the yearly plan when both are held |

Created by the owner in App Store Connect (§7.4). Family Sharing is assumed on for both — a setting
there, not code; a family-shared purchase counts like any other. Prices are the owner's: this
document and the local configuration use **$19.99 a year** and **$39.99 once** as placeholders, and
the app draws whatever StoreKit returns.

### 3.2 `PremiumAccess` — the decision

`WaterBuddy/PremiumAccess.swift`, app-only, `Foundation` alone, `nonisolated`, every type `Sendable`
— `ReminderPlan`'s shape for the same reason: the decision is testable without the framework.

- `productIDs` — the one spelling of the two identifiers. Nothing else writes either string.
- `Entitlement` — the plain facts read off one verified transaction: `productID`, `expires: Date?`,
  `revoked: Date?`.
- `Status` — `.free`, `.yearly(until: Date)`, `.lifetime`.
- `static func resolve(_ entitlements: [Entitlement], now: Date) -> Status` — ignores an unknown
  product ID, anything with a `revoked` date, and a subscription whose `expires` is at or before
  `now`; answers `.lifetime` when a lifetime purchase remains, else `.yearly(until:)` with the latest
  remaining expiry, else `.free`.
- `Plan` — a plain value the paywall draws: which product, StoreKit's `displayPrice` string, and the
  introductory offer's length (value and unit) when the user is eligible — not the subscription's
  period, which is a year by the product's identity (plan P5).
  The view never sees a StoreKit `Product`.

[CE] states that refunded or revoked products do not appear in current entitlements; `resolve`
checks again anyway, because an `Entitlement` also arrives from `Transaction.updates`, and because a
pure rule that held only for one caller's input is not a rule.

### 3.3 `PremiumStore` — reading StoreKit (D4, D7)

`WaterBuddy/PremiumStore.swift`, app-only, `@MainActor @Observable final class` — **the one new file
that imports StoreKit**. Built in `WaterBuddyApp.init()` and injected with `.environment(premium)`
beside the manager.

- **State**: `.checking` until the first read, then `.known(PremiumAccess.Status)`. Anything Premium
  waits while `.checking`, so a paying user never sees a paywall flash at launch.
- **Reading**: `Transaction.currentEntitlements` at launch and whenever the scene becomes active,
  verified transactions only, mapped to `Entitlement`s and passed to `PremiumAccess.resolve`.
- **Listening**: one `Transaction.updates` listener, a long-lived `Task` started in `init`, held by
  the store and cancelled in `deinit`. Each verified update is `finish()`ed and the state read again
  — so a renewal, a refund or an approved Ask to Buy is never missed while the app runs.
- **Plans**: `Product.products(for: PremiumAccess.productIDs)` when the paywall opens, mapped to
  `Plan`s, with the yearly product's `isEligibleForIntroOffer`. A failure is a state —
  *unavailable* — with *Try again*, never an empty paywall.
- **Buying**: the purchase result maps to *bought* (verified, `finish()`ed, state read again),
  *pending* (Ask to Buy), *cancelled* (nothing changes), or *failed* — and a purchase StoreKit cannot
  verify is *failed*, never Premium. [PO] states that Apple recommends `PurchaseAction` for SwiftUI
  and `purchase(confirmIn:options:)` for UIKit over `purchase(options:)`; `PurchaseAction` would put
  `StoreKit` into a view, so the store makes the call itself, `purchase(confirmIn:options:)` on the
  active `UIWindowScene` — available from iOS 17.0 and not deprecated, measured in the iOS 27.0
  SDK's interface (plan P1).
- **Restoring**: `AppStore.sync()`, then read again — [ARG] 3.1.1 states a restore mechanism is
  required.
- **Managing**: `AppStore.showManageSubscriptions(in:)` on the active `UIWindowScene` ([MS], iOS 15).
  [MS] states the sheet is unsupported on a Mac; the store skips it when
  `ProcessInfo.isiOSAppOnMac`.
- **The seam**: StoreKit reaches the store only through `PremiumStore.Source`, a struct of closures
  — the entitlements read, the update stream, the plans, the purchase, the restore and the manage
  sheet — built by `static func live()`, every closure calling StoreKit in its own body
  (`ReminderScheduler`'s shape, rule `43-concurrency`). Tests build their own `Source`; the plan
  fixes the signatures.

**Nothing is stored (D4).** StoreKit keeps purchases on the device and answers offline. A cached
"is Premium" flag would be a second source of truth that could still say Premium after a refund, so
there is no new `DataManager.Key`, no App Group write and no `UserDefaults` read. When a later item
needs the widget or the watch to know — themes, say — that item adds a **derived** key written by
`DataManager` alone; the widget and the watch never ask StoreKit (rule `40-widget`, rule
`25-shared-storage`).

### 3.4 What a lapse, a refund and a grace period do

- **A subscription expires** → the next read or update resolves `.free`.
- **A refund** → [CE] drops it from current entitlements; the update carries a `revocationDate`;
  `.free`.
- **A billing grace period** → still Premium: [CE] states current entitlements include a
  subscription whose renewal state is `inGracePeriod`.
- **Billing retry outside a grace period** → not in [CE]'s list; `.free` until it recovers
  (inferred from [CE]'s wording).
- In every case **every serving, setting and figure stays** — *The Premium line*, 2. In 1.4.1 there
  is nothing to go quiet; each later item says what going quiet means for it.

### 3.5 The switch and `PremiumSet` (D5)

- `WaterBuddy/PremiumSet.swift`: `enum PremiumSet: CaseIterable` with **no cases** in 1.4.1. Each
  set adds its case when it is built (`docs/ROADMAP.md` §5: *understand*, *coached*, *theirs*,
  *export*).
- `PaywallView.isOffered(arguments:)`, a `nonisolated static`: in DEBUG, `true` only when the
  arguments contain `-WaterBuddyPremium`; in Release, `true` only when `PremiumSet.allCases` is not
  empty. It is built on a pure function of the build, the arguments and the number of sets, which
  the tests read.
- So the paywall turns itself on in the first release that has something to sell, and no flag waits
  to be remembered. [ARG] 3.1.2(c) states that before asking a customer to subscribe the app should
  clearly describe what the user gets for the price — a paywall with no sets would describe nothing.

### 3.6 The Settings card (D6)

`PremiumCard`, a `private struct` in `SettingsView.swift`, the **fifth card, last**, below the
language card — the goal still leads, as the screen's own comment rules. Drawn only when
`PaywallView.isOffered(arguments:)` is true and the store is not `.checking`.

- **Free**: *Premium*, one line on what it adds, and *See Premium* — a glass button, not the primary
  surface (the screen's one main action is not a purchase).
- **Yearly**: *Yearly, until 21 October 2027* — the current period's end, which is true whether or not
  it renews — and *Manage Subscription*, where Apple's own sheet says whether it renews.
- **Lifetime**: *Lifetime*.

It sits under the bar's reserved height like the language card does today, so the stack's bottom
padding is re-checked against the floating bar (rule `50-views`).

### 3.7 The paywall (D3)

`WaterBuddy/PaywallView.swift`, a sheet presented with `.sheet(item:)` bound to an optional
`PaywallView.Entry` — where it was opened from; `.settings` is the only case in 1.4.1, and each later
item's locked state adds its own (rule `50-views`). It declares its own
`.preferredColorScheme(.dark)` and stands its own `AuroraBackground()`.

Top to bottom:
1. **WaterBuddy Premium**, and the promise on its own line: *Logging water is free, always.*
2. **The sets**, one row each, read from `PremiumSet`. None in 1.4.1, so the section is not written; the first set writes it (plan P6).
3. **Two plans** on glass panes, the yearly selected when the sheet opens, the selection marked with
   `LiquidGlass.Selection`'s fill and rim (rule `60-design-system`):
   - *Yearly* — *1 week free, then $19.99 a year* when eligible, *$19.99 a year* otherwise;
   - *Lifetime* — *$39.99, once*.
   The prices are StoreKit's `displayPrice`, in the storefront's currency. The words around them
   are ours, through the strings bundle; the trial's length is Foundation's own words for it, in the
   app's language, so a trial changed in App Store Connect cannot leave the copy saying one week
   (plan P3).
4. **One primary surface**, labelled for the chosen plan: *Start Free Trial*, *Subscribe*, or *Buy
   Lifetime* — no length in the label, which Russian would need in another case (plan P4) — the
   screen's one main action (rule `60-design-system`).
5. **The terms**: the renewal sentence — the yearly price is charged when the free week ends, and
   every year after, unless cancelled at least a day before in the Apple Account's settings —
   *Restore Purchases*, and two links, **Terms of Use** (Apple's standard licence) and **Privacy
   Policy** (the owner's URL), which open in Safari. The app fetches neither.

**Its states:**

| State | What the sheet shows |
|---|---|
| loading | the plans quiet, the button disabled |
| unavailable | *The App Store can't be reached right now.* and *Try Again* |
| buying | the button's progress; the sheet cannot be swiped away |
| pending | *Waiting for approval.* — Ask to Buy |
| bought | a short thank-you, then the sheet closes |
| failed | *The purchase didn't go through.*; the sheet stays |
| already Premium | the plan held, in place of the two plans — after a restore, say |

**Feel and access.** Each plan is one button: label the plan's name, value its price line,
`.isSelected` on the chosen one (rule `65-accessibility`). Every target is at least 44 pt; the sheet
scrolls at the accessibility sizes, in the `GeometryReader`/`ScrollView` form rule `65-accessibility`
gives a screen that is mostly type. `Haptics.select` when a plan is picked, from a counter the tap
bumps; `Haptics.confirm` when a purchase lands. Nothing moves forever, so Reduce Motion needs no
branch; Reduce Transparency is the glass's own (rule `60-design-system`). Every new colour pair is
measured off a render into `docs/DESIGN.md` before it ships.

### 3.8 The words

All in `WaterBuddy/Localizable.xcstrings` only — app-only, so none joins `sharedKeys`. Every key has
`en`, `ru` and `uz` values; no key counts a noun: the trial's length is Foundation's
(plan P3); positional specifiers throughout. Sentences with an
argument go through `strings.localized(_:_:locale:)` (rule `50-views`). The Russian and Uzbek are the
plan's draft, for the owner's reading in the sweep, as 1.2.3's were.

## 4. What it touches

| File | Change |
|---|---|
| `WaterBuddy/PremiumAccess.swift` | new — §3.2 |
| `WaterBuddy/PremiumSet.swift` | new — §3.5 |
| `WaterBuddy/PremiumStore.swift` | new — §3.3; the second file to import `StoreKit` |
| `WaterBuddy/PaywallView.swift` | new — §3.7, and `isOffered(arguments:)` |
| `WaterBuddy/WaterBuddyApp.swift` | builds the store, injects it, reads it again when the scene is active |
| `WaterBuddy/SettingsView.swift` | `PremiumCard`, the fifth card |
| `WaterBuddy/Localizable.xcstrings` | §3.8's keys |
| `WaterBuddy/HomeView.swift` | DocC only: "the one use of StoreKit" becomes one of two |
| `WaterBuddy/DataManager.swift` | DocC only, line 1422, the same |
| `WaterBuddyTests/WaterBuddy.storekit` | new — the local configuration, §3.1's two products |
| `WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme` | the Run action's StoreKit configuration |
| `WaterBuddyTests/…`, `WaterBuddyUITests/…` | §6 |

**No `project.pbxproj` edit** is expected: every new file lands in a synchronized folder (inferred —
the plan's first task proves the `.storekit` file reaches the test bundle and no shipping bundle).
**No exception set changes**: nothing new reaches the widget or the watch. Because `DataManager.swift`
changes, even by a comment, both widget schemes are built in the gate as always.

## 5. What this amends

Typed into the rule files **unstaged**, for the owner, before any code. Approving this document
approves this wording.

**`70-privacy`**, *Nothing leaves the device*, the first bullet's `StoreKit` (one exception, below)
becomes `StoreKit` (two uses, below), and the section *The review request is the one use of
StoreKit* is replaced by:

> ## StoreKit, for the review request and for Premium
>
> `StoreKit` stays banned outside two files in the app target. `HomeView.swift` imports it for
> `@Environment(\.requestReview)` and nothing else. `PremiumStore.swift` imports it for Premium's two
> products, `PremiumAccess.productIDs` — a yearly subscription and a lifetime purchase. iOS draws the
> rating request and the purchase sheet; Apple takes the payment and holds the purchase under the
> user's own Apple Account; StoreKit verifies it on the device. The app sends nothing anywhere — no
> figure, no identifier, no account, no receipt — and stores nothing about a purchase: the paid state
> is read from StoreKit each time and kept in memory only. Neither use needs an entitlement or a
> usage-description key.
>
> Six limits are conditions of the permission:
> - **Two files.** No other file imports `StoreKit` — no view, no widget or watch file, and not
>   `DataManager.swift`, which compiles into all four targets. A view reads `PremiumStore` from the
>   environment and is handed plain values. Only the unit tests may import `StoreKitTest`, and only
>   against `WaterBuddyTests/WaterBuddy.storekit`, never the App Store
> - **Named calls.** For the review request, `requestReview` alone. For Premium, `Product.products(for:)`
>   and its purchase call, `Transaction.updates`, `Transaction.currentEntitlements`, `finish()`,
>   `AppStore.sync()` and `AppStore.showManageSubscriptions(in:)`. No offer codes, promoted purchases,
>   app account tokens or consumables until an amendment here names them. A *Rate WaterBuddy* link to
>   the App Store is not part of this permission
> - **The review request's moment.** Asked only after the user's own pour on Home reaches the goal on
>   the third day in a row, at most once per app version, after the confetti lands — never at launch,
>   never from a button whose answer is the request, never from the widget, Siri, the control, a
>   reminder's button, the watch or History
> - **The paywall's moment.** Shown only when the user opens it — Settings' *See Premium*, or a later
>   item's own locked state — never at launch, never in the welcome, never after a pour, and never
>   from the widget, Siri, the control, a reminder's button or the watch. A Release build offers it
>   only while there is a set to sell (`PaywallView.isOffered(arguments:)`)
> - **Two links, on the user's own tap.** *Terms of Use* (Apple's standard licence) and *Privacy
>   Policy* open in Safari. The app fetches neither
> - **What never moves behind it.** No way of logging, and nothing a free user can do today —
>   *The Premium line*, `docs/ROADMAP.md` §1

**`10-architecture`**, *The rulings*, a bullet after *Reminders are scheduled from a pure plan*:

> - **Premium is read, never stored.** `PremiumStore`, app-only and `@MainActor @Observable`, is
>   injected beside `DataManager`. It reads StoreKit and writes neither store: the paid state lives in
>   memory and is read again at launch, on every return to the foreground and on every transaction
>   update. The widget and the watch never compile it and never ask StoreKit — a later item that needs
>   them to know writes a derived key through `DataManager` (rule `70-privacy`)

and *Forbidden* gains:

> - `import StoreKit` outside `HomeView.swift` and `PremiumStore.swift`

**`15-project`**, *Membership*, a bullet after `LogServingIntent`'s:

> - `PremiumAccess`, `PremiumSet`, `PremiumStore` and `PaywallView` are app-only and stay out of every
>   exception set. `WaterBuddyTests/WaterBuddy.storekit` is the local StoreKit configuration: a test
>   resource, in no shipping bundle. The checked-in `WaterBuddy` scheme's Run action names it, so a
>   run from Xcode buys from it and never from the App Store; an archive carries none

**`43-concurrency`**, *The model is main-actor; the read path is not*, two bullets at its end:

> - `PremiumStore` is `@MainActor @Observable`. Its one `Transaction.updates` listener is a long-lived
>   `Task` started in its `init`, held by the store and cancelled in `deinit`. StoreKit reaches it only
>   through `PremiumStore.Source`, a struct of closures built by `static func live()`, each closure
>   calling StoreKit in its own body — `ReminderScheduler`'s shape — so no StoreKit value sits in a
>   `static let`
> - `PremiumAccess` is `nonisolated` and imports `Foundation` alone, as `ReminderPlan` does

and *Tests*' list of suites never to annotate gains `PremiumAccessTests` and `PaywallOfferTests`.

**`85-testing`**, *Isolation*'s list of suites that are not `@MainActor` gains `PremiumAccessTests` and
`PaywallOfferTests`; *A fixture may never reach real data* gains, after the review prompt's bullet:

> - `-WaterBuddyPremium` is DEBUG's opt-in to the paywall, read through
>   `PaywallView.isOffered(arguments:)`. `PremiumUITests` passes it and no other UI test does, so no
>   other run meets the Premium card. A purchase through the sheet has no automated coverage: prove it
>   by hand on a simulator, with the scheme's local StoreKit configuration
> - StoreKit is reached in a test only through `PremiumStore.Source`'s closures or an `SKTestSession`
>   over `WaterBuddyTests/WaterBuddy.storekit` — never the App Store or its sandbox. A suite that opens
>   an `SKTestSession` is `.serialized` and clears its transactions in a `defer`: a session is the
>   simulator's own state, shared by every test in the run

and *A green suite is not proof the product works*'s sentence of what to do by hand gains, after the
reminder clause: *"after a change to Premium, buy each plan, restore, refund and approve an Ask to Buy
through the local StoreKit configuration;"*.

**`50-views`**, *Getting the model*, a bullet at its end:

> - Premium's state comes from `@Environment(PremiumStore.self)`. A view never imports `StoreKit` and
>   never holds a `Product`; it is handed `PremiumAccess.Plan`s

and *Navigation*, a bullet after the sheet bullet:

> - The paywall is presented with `.sheet(item:)` bound to an optional `PaywallView.Entry` — where it
>   was opened from — never a `Bool`

**`65-accessibility`**, *VoiceOver*, a bullet after the week card's:

> - Each of the paywall's plans is one button — label the plan's name, value its price line,
>   `.isSelected` on the chosen one. The renewal terms are spoken in full, never hidden

**`CLAUDE.md`** (the owner's, as the rules are): *Architecture* gains a bullet after *Reminders are
scheduled from a pure plan*: *"**Premium is read, never stored.** `PremiumStore` reads StoreKit for
the app alone and writes neither store; StoreKit is imported in `HomeView.swift` and
`PremiumStore.swift` only (rule `70-privacy`, rule `10-architecture`)"*.

## 6. Testing

Tests first, each run and seen **RED** before its code (rule `85-testing`).

- **`PremiumAccessTests`** — not `@MainActor`, a canary for §3.2's isolation: no entitlements →
  `.free`; an unexpired yearly → `.yearly(until:)` with its date; an expiry **at** `now` → `.free`; a
  revoked yearly → `.free`; a lifetime → `.lifetime`; a lifetime beside a yearly → `.lifetime`; an
  unknown product ID → ignored; two yearly entitlements → the later expiry; `productIDs` are two,
  distinct, and both under `sardor.WaterBuddy.`.
- **`PaywallOfferTests`** — not `@MainActor`, over the pure switch: DEBUG without the argument → not
  offered; DEBUG with it → offered; Release with no set → not offered; Release with one → offered.
  It never needs editing when the first set lands.
- **`PremiumStoreTests`** — `@MainActor`, every StoreKit call a closure in a test `Source`: the state
  starts `.checking` and becomes `.known` after the first read; a verified purchase is finished and
  reads Premium; an unverified one is *failed* and stays `.free`; pending is *pending*; cancelled
  changes nothing; an update carrying a refund resolves `.free`; a failed plans load is *unavailable*
  and *Try again* recovers.
- **`StoreKitSessionTests`** — `@MainActor`, `.serialized`, `import StoreKitTest`, an `SKTestSession`
  over the local configuration, opened through `init(contentsOf:)` from the test bundle's URL ([STS]),
  dialogs disabled, transactions cleared in a `defer`. Through the **live** `Source`: both products
  load and the yearly carries a one-week introductory offer; a bought yearly reads Premium; an expired
  one reads free; a refunded one reads free; with Ask to Buy on, a purchase is pending, and approving
  it reads Premium; a trial used once is not offered again (plan P11).
- **`LocalizationTests`** — every new key resolves in `en`, `ru` and `uz` in the app bundle, with the
  plural forms rule `70-privacy` asks of a counted noun.
- **`PremiumUITests`** — an ordinary run has no Premium card (`completeWelcomeIfShown`, then Settings);
  with `-WaterBuddyPremium`, the card is one element and opens the sheet, where the title, the promise
  line, *Restore Purchases*, *Terms of Use* and *Privacy Policy* each resolve to exactly one element.
  It asserts nothing that needs products to load, so it holds whatever StoreKit returns.

## 7. Verification

### 7.1 The gate

The five invocations of rule `85-testing`, in the foreground, one simulator, `-parallel-testing-enabled
NO`, and the UI suite again on `OS=26.5` while iOS 26 is supported.

### 7.2 Warnings

Clean builds of a `HEAD` export and of the change, all four schemes, compared by file and message.
Nothing new. A deprecation on the purchase call is a new warning (§9, task 1).

### 7.3 On the simulator

With the `WaterBuddy` scheme's local StoreKit configuration, launched with `-WaterBuddyPremium`: the
card; the paywall in English, Russian and Uzbek; the yearly bought with its free week shown, and the
lifetime bought; Ask to Buy pending, then approved in Xcode's transaction manager; a refund there
turning the card free; *Restore Purchases*; *Manage Subscription*; the sheet under VoiceOver, at an
accessibility text size and with Reduce Transparency. Then one run in the **Release** configuration,
without the argument: no card. The new colour pairs measured off renders into `docs/DESIGN.md`.

### 7.4 What only App Store Connect and a device show

Not needed to merge 1.4.1, which ships hidden — needed before any release offers the paywall, and
each opened as a known issue:
1. The Paid Apps Agreement, banking and tax, active.
2. The subscription group *WaterBuddy Premium*, the yearly product at its price with the one-week
   free introductory offer, and its display name in `en`, `ru` and `uz`.
3. The lifetime non-consumable.
4. Family Sharing on both.
5. The privacy policy's URL for the paywall's link; the App Privacy answers stay *Data Not
   Collected* — Apple takes the payment, and nothing reaches the owner.
6. A sandbox purchase, restore and refund on a real iPhone, before the first set ships — beside
   1.2.7's sweep.

## 8. Open questions, known limitations, and what is not in scope

- **O1 — the privacy policy link.** [ARG] 5.1.1(i) states every app must link to its privacy policy
  within the app; WaterBuddy shows none today, Premium or not. The paywall's link answers it only
  where the paywall is offered. Whether Settings carries the link for everyone is the owner's
  question, outside this item, and is opened as a known issue.
- **O2 — subscriptions on every device.** [ARG] 3.1.2(a) states a subscription must work on all of
  the user's devices where the app is available. 1.4.1 unlocks nothing; each later set that reaches
  the watch says how the watch learns it is paid (§3.3, a derived key).
- **Not in scope:** any set, feature or locked state; offer codes, promotional offers, win-back
  offers; a paywall anywhere but Settings; price testing; a monthly plan (`docs/ROADMAP.md` §1:
  yearly plus lifetime).

## 9. Sequence

1. **Prove the unknowns first**, in a throwaway copy: (the purchase call is settled, plan P1); that `WaterBuddyTests/WaterBuddy.storekit` reaches the
   test bundle and no shipping bundle, with no `project.pbxproj` edit; that `SKTestSession(contentsOf:)`
   loads it under swift-testing on the simulator.
2. Type §5's wording into the rule files, unstaged, for the owner — before any code.
3. `PremiumAccess`, then `PremiumSet` and the switch — tests first.
4. `PremiumStore` and its `Source` — tests first; then `StoreKitSessionTests` over the live `Source`.
5. `PaywallView`, the Settings card, the words — then the UI test.
6. By hand (§7.3), the gate (§7.1), the warnings (§7.2), a final review, the records.
