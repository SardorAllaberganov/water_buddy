# Premium's Paywall, Card and Monthly Plan — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (this repository's
> `CLAUDE.md`: *there is no implementation subagent* — planning, tests, implementation and review
> happen in the main loop). Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Step 1 of 5 of set A — add the monthly plan, rule the grace period, declare set A (not on
sale), and rebuild the paywall and the Settings card to the design the owner approved.

**Architecture:** The pure decision (`PremiumAccess`) learns the monthly plan and trusts StoreKit's
current entitlements; `PremiumSet` gains set A with an `isOnSale` switch that stays off; the store
(`PremiumStore`) loads three plans and gains a read number, restore states and a manage check; the
sheet (`PaywallView`) and the card (`PremiumCard` in `SettingsView`) are redrawn, with one new
modifier, `.premiumRim()`. Nothing is stored; nothing reaches the widget or the watch.

**Tech Stack:** Swift 5 mode, SwiftUI, StoreKit 2 (iOS 17 floor), swift-testing, XCTest UI tests,
StoreKitTest's `SKTestSession` over `WaterBuddyTests/WaterBuddy.storekit`.

**Spec:** `docs/superpowers/specs/2026-10-21-premium-paywall-and-monthly-design.md` (approved
2026-10-21, "ok"), amending `docs/superpowers/specs/2026-10-21-premium-foundation-design.md`. The
design canvas: https://claude.ai/artifact/1dyjwFfRVsLYzcvwQ6poGy (private to the owner).

**Starting point:** HEAD `b981374`; staged — the foundation plan's Task 6 (`PaywallView.swift`,
`PremiumUITests.swift`, `SettingsView.swift`, `WaterBuddyApp.swift`, `RootTabView.swift`,
`HomeView.swift`, `DataManager.swift`, `PremiumAccessTests.swift`), its review fix
(`PremiumStore.swift`, `PremiumStoreTests.swift`) and the spec. This plan rewrites the staged paywall
and card rather than shipping them.

## Decisions this plan takes

Each is a reading of the spec where its text left a choice; each says what it costs if wrong.

- **S1 — the yearly's saving rides in its own key.** The spec's `Save %1$@` becomes
  `a year · save %1$@`, the yearly tile's whole third line, so no separator is spliced in code
  between two translated pieces. Cost if wrong: one key renamed.
- **S2 — the tiles stack by `dynamicTypeSize.isAccessibilitySize`** (an `AnyLayout`), not
  `ViewThatFits` — the spec's intent is "at the accessibility text sizes", and this is exact at
  those sizes. The footer links, whose width moves with the language, do use `ViewThatFits`.
- **S3 — the *Best value* badge is cyan words on opaque glass**: not a bare fill (rule
  `60-design-system`), not the primary surface (the buy button is the screen's one). `.opaque`
  because it sits across the tile's rim, where sheer glass would show the rim through the word.
- **S4 — `PremiumAccess.holdsSubscription(_:)` and `PremiumStore.holdsSubscription`** answer the
  final review's minor 3; `Status` stays one answer.
- **S5 — `PremiumStore.now` becomes `internal`** so the card and the sheet pass the store's clock to
  `Status.line(in:locale:now:)` (rule `30-rollover`'s *The clock*).
- **S6 — `PremiumStore.Source` gains `canManage: () -> Bool`** (minor 6).
- **S7 — the card's previews are a glyph over a caption, with no pane of their own** — glass inside
  the card's glass is avoided; the card's own mark is a glyph, not a tile.
- **S8 — `PaywallView.screen(status:purchase:)`** decides offer, thanks or held as a pure function,
  so Review Focus 1 and 5 are unit tests.
- **S9 — `anUnknownProductIsIgnored` takes a weekly ID**: the monthly is ours now. The assertion is
  unchanged.
- **S10 — two session tests follow the product order**: `bothProductsLoad…` becomes
  `allThreeProductsLoad…`; `aTrialUsedOnceIsNotOfferedAgain` finds the yearly by kind instead of
  reading `plans.first`.
- **S11 — the warnings baseline is a clean build of a `HEAD` `b981374` export**, which already
  carries the `StoreKitTest` header line (the owner's open ruling), so this step's comparison shows
  only its own lines.
- **S12 — `PaywallScreenTests` joins the canary lists** in rules `43-concurrency` and `85-testing`
  (typed in Task 2, unstaged), beside `PaywallOfferTests`.
- **S13 — the card, being first, may appear a beat after Settings draws** — only once the first
  StoreKit read has answered (the spec's *not `.checking`*). Accepted: the read takes well under a
  second, and a paying user must never see the free card flash.

## Global Constraints

- iOS floor **17.0**, no `#available` for anything here: `Product.price` and
  `isEligibleForIntroOffer` are iOS 15, `purchase(confirmIn:)` iOS 17.
- **`StoreKit` is imported by `WaterBuddy/HomeView.swift` and `WaterBuddy/PremiumStore.swift` only;
  `StoreKitTest` by `WaterBuddyTests/PremiumStoreTests.swift` only.**
- Product IDs, spelled once, in this order: `sardor.WaterBuddy.premium.monthly`,
  `sardor.WaterBuddy.premium.yearly`, `sardor.WaterBuddy.premium.lifetime`.
- Local prices: **$2.99** a month (no introductory offer), **$19.99** a year (one week free),
  **$39.99** once. The app draws whatever StoreKit returns.
- **Nothing stored**: no `DataManager.Key`, no `UserDefaults`, no App Group write; no exception set,
  `project.pbxproj`, entitlement, Info.plist or privacy manifest change.
- `PaywallView.launchArgument == "-WaterBuddyPremium"`. Terms of Use:
  `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`. Privacy Policy:
  `OWNER-PRIVACY-URL` **stays** until the owner gives the URL; `theLinksAreApplesTermsAndAPageOfOurs`
  stays red until then and is reported by name.
- Tests first: write, run, **see RED by a stub** (never by a compile failure), implement, run GREEN.
  Never narrow an assertion; the four expiry tests the grace ruling replaces are named in Task 3.
- **No new warning** against Task 0's baseline, all four schemes, by file and message.
- Edit with `Edit`/`Write` only — no `sed -i`, no script into the tree. Scratch work in this session's
  scratchpad (`$SCRATCH`).
- **Xcode closed** while `WaterBuddy/Localizable.xcstrings` or the scheme is edited (lesson
  2026-10-18; #50).
- Simulators: unit and probe on the stock *iPhone 17* (iOS 27.0); UI on *WaterBuddy Gate 27* and
  *WaterBuddy Gate 26.5*; watch on *WaterBuddy Watch 27*. `uptime` before each run, wait while the
  1-minute load is above 6. Shut down **by UDID**, never `simctl shutdown all` while another
  `xcodebuild` runs (lesson 2026-10-07). `-parallel-testing-enabled NO`; `-collect-test-diagnostics
  never` on runs meant to fail.
- **The owner's iPhone is screenshotted only when the owner says "done"** (2026-10-21: an unasked
  capture caught another app's receipt).
- Never write the real App Group suite or `UserDefaults.standard`. **Never commit**; stage explicit
  paths. Rule files stay unstaged for the owner.

## Review Focus

Five inputs a person will meet that the spec's tests do not reach as written, each pinned in the task
that owns it:

1. **A refund landing while the sheet says *Thank you*** → the sheet returns to the offer, with no
   stale thank-you → `aRefundAfterAThankYouReturnsTheOffer` (Task 7).
2. **A yearly price at or above twelve months of the monthly** (a monthly sale, a currency's
   rounding) → no saving shown, never 0 % or a negative → `aYearlyDearerThanTwelveMonthsSavesNothing`
   (Task 3).
3. ***Restore Purchases* tapped twice** → one App Store sync → `aSecondRestoreWhileOneRunsAsksOnce`
   (Task 5).
4. **A subscriber in grace opening Settings** → the plan's name, never a date in the past →
   `aPassedDateIsNotShown` (Task 3).
5. **A monthly subscriber opening the paywall** → what they hold and *Done*, not three plans to buy
   again → `aSubscriberSeesWhatTheyHold` (Task 7).

## File structure

| File | Target | Change |
|---|---|---|
| `WaterBuddy/PremiumAccess.swift` | app | `.monthly`, the grace ruling, `holdsSubscription`, `amount`, `yearlySaving`, `Status.line(…now:)` (Task 3); `period`, `note` (Task 6) |
| `WaterBuddy/PremiumSet.swift` | app | `.understand`, `Feature`, `isOnSale`, `onSale` (Task 4) |
| `WaterBuddy/PremiumStore.swift` | app | `now` internal (Task 3); three plans, read number, `holdsSubscription`, `Restoring`, `canManage` (Task 5) |
| `WaterBuddy/PaywallView.swift` | app | the switch (Task 4); rewritten (Task 7) |
| `WaterBuddy/PremiumRim.swift` | app — **new** | `.premiumRim()` (Task 7) |
| `WaterBuddy/SettingsView.swift` | app | `line(…now:)` (Task 3); the card first, rewritten (Task 7) |
| `WaterBuddy/WaterBuddyApp.swift` | app | one comment (Task 7) |
| `WaterBuddy/Localizable.xcstrings` | app | 27 keys (Task 6) |
| `WaterBuddyTests/WaterBuddy.storekit` | tests | the monthly product (Task 5) |
| `WaterBuddyTests/PremiumAccessTests.swift` | tests | `PremiumAccessTests`, `PremiumWordsTests`, `PaywallOfferTests`, **`PaywallScreenTests`** |
| `WaterBuddyTests/PremiumSetTests.swift` | tests — **new** | `PremiumSetTests` (Task 4) |
| `WaterBuddyTests/PremiumStoreTests.swift` | tests | `PremiumStoreTests`, `StoreKitSessionTests` |
| `WaterBuddyTests/LocalizationTests.swift` | tests | `premiumKeys` + 27 (Task 6) |
| `WaterBuddyUITests/PremiumUITests.swift` | UI tests | two tests rewritten (Task 7) |
| `WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme` | — | the StoreKit reference kept, the stray entries removed (Task 9) |
| `.claude/rules/70-privacy.md`, `60-design-system.md`, `43-concurrency.md`, `85-testing.md` | — | wording, **unstaged** (Task 2) |
| `docs/…`, `CLAUDE.md`, `HISTORY.md`, `tasks/lessons.md` | — | records (Task 10) |

Expected counts after the work, by the attribute grep, not trusted from here: unit `@Test`
734 + 30 = **764**; watch **70**; UI `func test` **58** (two rewritten, none added).

## Commands used below

```bash
# UNIT <filters>: swift-testing on the stock iOS 27.0 iPhone 17
W=.superpowers/sdd/2026-10-21-premium-paywall-and-monthly
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' <-only-testing:WaterBuddyTests/Suite> -parallel-testing-enabled NO -collect-test-diagnostics never > $W/<name>.log 2>&1; grep -E "Test run with|✘|error:" $W/<name>.log | tail -40
```

A swift-testing filter names a suite, or a test **with its parentheses** —
`-only-testing:WaterBuddyTests/PremiumStoreTests/aSecondRestoreWhileOneRunsAsksOnce()` (lesson
2026-08-31). Read a run's executed count, never its last line alone.

---

### Task 0: The ledger and the baselines

**Files:** `$W/progress.md` (git-ignored); `$SCRATCH/base/*`.

- [ ] **Step 1: The workspace.** `sdd-workspace docs/superpowers/plans/2026-10-21-premium-paywall-and-monthly.md`;
  write `progress.md` with its identity line, the starting state (`git status --short`), and a note
  that the foundation's ledger ends at its *Redirected by the owner* entry.
- [ ] **Step 2: The warnings baseline** (S11), from a `HEAD` export into one empty DerivedData:

```bash
rm -rf "$SCRATCH/head" "$SCRATCH/head-dd"; mkdir -p "$SCRATCH/head"; git archive b981374 | tar -x -C "$SCRATCH/head"
xcodebuild build-for-testing -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-widget.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-watch.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/head/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/head-dd" > "$SCRATCH/base-watchwidget.log" 2>&1; echo "exit $?"
for s in app widget watch watchwidget; do grep -E '^/.*: warning: ' "$SCRATCH/base-$s.log" | sed -E 's#^.*/head/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/base-$s-messages.txt"; echo "$s $(wc -l < "$SCRATCH/base-$s-messages.txt")"; done
```

  Expected: four `exit 0`; app **20** messages (Task 0 of the foundation's 19 plus the `StoreKitTest`
  header line), widget 17, watch 2, watch widget 2. A different count is read and ledgered before
  going on.

---

### Task 1: The probe — three products, an upgrade, the percent

**Files:** a throwaway copy in `$SCRATCH/probe`, removed after.

- [ ] **Step 1: The copy.** `git checkout-index -a --prefix="$SCRATCH/probe/"`; in the copy, add Task
  5 Step 3's monthly product to `WaterBuddyTests/WaterBuddy.storekit`.
- [ ] **Step 2: A probe suite** in the copy, `WaterBuddyTests/ProbeTests.swift`:

```swift
import Foundation
import StoreKit
import StoreKitTest
import Testing
@testable import WaterBuddy

private final class ProbeBundle {}

@MainActor
@Suite(.serialized, .timeLimit(.minutes(1)))
struct ProbeTests {

    private func session() throws -> SKTestSession {
        let url = try #require(Bundle(for: ProbeBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        return session
    }

    @Test func threeProductsAndTheirPrices() async throws {
        let session = try session()
        defer { session.clearTransactions() }
        let products = try await Product.products(for: [
            "sardor.WaterBuddy.premium.monthly", "sardor.WaterBuddy.premium.yearly", "sardor.WaterBuddy.premium.lifetime",
        ])
        for product in products {
            print("PROBE product", product.id, product.displayPrice, product.price, product.subscription?.subscriptionPeriod.unit as Any)
        }
        #expect(products.count == 3)
    }

    @Test func aMonthlyThenAYearly() async throws {
        let session = try session()
        defer { session.clearTransactions() }
        let scene = try #require(PremiumStore.foregroundScene())
        for id in ["sardor.WaterBuddy.premium.monthly", "sardor.WaterBuddy.premium.yearly"] {
            let product = try #require(try await Product.products(for: [id]).first)
            let result = try await product.purchase(confirmIn: scene)
            print("PROBE bought", id, result)
        }
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                print("PROBE entitled", transaction.productID, transaction.expirationDate as Any,
                      transaction.revocationDate as Any, transaction.isUpgraded)
            }
        }
    }

    @Test func thePercentInEachLanguage() {
        for code in ["en_US", "ru_RU", "uz_UZ"] {
            print("PROBE percent", code, (0.44).formatted(.percent.locale(Locale(identifier: code))))
        }
    }
}
```

- [ ] **Step 3: Run it in the copy** (UNIT against `$SCRATCH/probe/WaterBuddy.xcodeproj`,
  `-only-testing:WaterBuddyTests/ProbeTests`), and ledger every `PROBE` line. Expected: three
  products with prices 2.99, 19.99, 39.99; after the yearly, the entitlements hold the yearly (the
  monthly upgraded or gone); percents *44%*, *44 %* (Russian, with a narrow no-break space), and
  Uzbek's own. If the upgrade leaves the monthly listed with a **later** end than the yearly, stop
  and re-plan with the owner (§3.2's precedence would read it as monthly).
- [ ] **Step 4:** `rm -rf "$SCRATCH/probe"`. Ledger: Task 1 complete (probe).

---

### Task 2: The rule wording, typed and unstaged

**Files:** `.claude/rules/70-privacy.md`, `.claude/rules/60-design-system.md`,
`.claude/rules/43-concurrency.md`, `.claude/rules/85-testing.md` — **not staged**.

- [ ] **Step 1: `70-privacy`**, *StoreKit, for the review request and for Premium*:
  - "Premium's two products, `PremiumAccess.productIDs` — a yearly subscription and a lifetime
    purchase" → "Premium's three products, `PremiumAccess.productIDs` — a monthly and a yearly
    subscription and a lifetime purchase";
  - *Named calls*: after "`Transaction.currentEntitlements`," insert
    "`Product.price`, `Product.SubscriptionInfo.isEligibleForIntroOffer`,";
  - *The paywall's moment*, its last sentence → "A Release build offers it only while a set is on
    sale and the privacy policy link is set (`PaywallView.isOffered(arguments:)`)".
- [ ] **Step 2: `60-design-system`**, *Glass*, a bullet after the selection bullet:

  > - Premium's card is marked with `.premiumRim()` — `Aurora.cyan`, `Aurora.magenta` and
  >   `Aurora.blue` stroked around a standard pane — and nowhere else. Never a gradient stroke written
  >   in a view

- [ ] **Step 3: `43-concurrency`** (*Tests*' list of suites never to annotate) and **`85-testing`**
  (*Isolation*'s list of suites that are not `@MainActor`): add `PaywallScreenTests` after
  `PaywallOfferTests` (S12).
- [ ] **Step 4:** `git diff --stat -- .claude/rules` shows four files; none staged. Ledger: Task 2
  complete (no tests — the wording, unstaged).

---

### Task 3: The decision — the monthly plan and the grace ruling

**Files:**
- Modify: `WaterBuddy/PremiumAccess.swift` (lines 21–200, the declarations below)
- Modify: `WaterBuddy/PremiumStore.swift` (`now`, `refresh`, `Plan(product)`)
- Modify: `WaterBuddy/PaywallView.swift`, `WaterBuddy/SettingsView.swift` (one call each)
- Test: `WaterBuddyTests/PremiumAccessTests.swift`, `WaterBuddyTests/PremiumStoreTests.swift`

**Interfaces — produces:**
- `PremiumAccess.monthlyID: String`; `productIDs == [monthlyID, yearlyID, lifetimeID]`
- `PremiumAccess.Plan.Kind.monthly`; `Plan(id:kind:price:amount:trial:)`, `amount: Decimal`
- `PremiumAccess.Status.monthly(until: Date)`; `Status.line(in: Bundle, locale: Locale, now: Date) -> String?`
- `PremiumAccess.resolve(_: [Entitlement]) -> Status` (no `now:`)
- `PremiumAccess.holdsSubscription(_: [Entitlement]) -> Bool`
- `PremiumAccess.yearlySaving(yearly: Decimal, monthly: Decimal) -> Double?`;
  `PremiumAccess.yearlySaving(among: [Plan]) -> Double?`
- `PremiumStore.now: () -> Date` (internal)

- [ ] **Step 1: The tests.** In `WaterBuddyTests/PremiumAccessTests.swift`:
  - after `lifetime(revoked:)` add:

```swift
private func monthly(expires: Date?, revoked: Date? = nil) -> PremiumAccess.Entitlement {
    PremiumAccess.Entitlement(productID: PremiumAccess.monthlyID, expires: expires, revoked: revoked)
}

/// A price as StoreKit gives it — from a string, so `2.99` is not a binary approximation.
private func price(_ text: String) -> Decimal {
    Decimal(string: text)!
}
```

  - replace the whole `struct PremiumAccessTests { … }` with:

```swift
/// Not `@MainActor`, on purpose: a canary for ``PremiumAccess`` staying off the main actor
/// (rule `43-concurrency`). Fix the declaration it reads, never this suite.
struct PremiumAccessTests {

    @Test func nothingHeldIsFree() {
        #expect(PremiumAccess.resolve([]) == .free)
    }

    @Test func aYearlyStillRunningIsPaidUntilItsPeriodEnds() {
        #expect(PremiumAccess.resolve([yearly(expires: later)]) == .yearly(until: later))
    }

    /// The owner's grace ruling (spec `2026-10-21-premium-paywall-and-monthly-design.md` §3.2):
    /// StoreKit listing a subscription is what holds it. Replaces `aYearlyEndingAtThisInstantIsOver`.
    @Test func aListedYearlyPastItsEndIsStillHeld() {
        #expect(PremiumAccess.resolve([yearly(expires: now)]) == .yearly(until: now))
    }

    /// In a billing grace period the period has ended and StoreKit still lists the plan. Replaces
    /// `aYearlyThatEndedIsOver`.
    @Test func aSubscriptionInItsGracePeriodIsStillPaid() {
        #expect(PremiumAccess.resolve([yearly(expires: earlier)]) == .yearly(until: earlier))
        #expect(PremiumAccess.resolve([monthly(expires: earlier)]) == .monthly(until: earlier))
    }

    @Test func aRefundedYearlyIsFree() {
        #expect(PremiumAccess.resolve([yearly(expires: later, revoked: earlier)]) == .free)
    }

    /// StoreKit gives every subscription an end; a missing one is not evidence of payment.
    @Test func aYearlyWithNoEndIsNotTakenAsPaid() {
        #expect(PremiumAccess.resolve([yearly(expires: nil)]) == .free)
    }

    @Test func theLifetimePurchaseIsPremiumForGood() {
        #expect(PremiumAccess.resolve([lifetime()]) == .lifetime)
    }

    @Test func theLifetimeWinsOverAYearlyBesideIt() {
        #expect(PremiumAccess.resolve([yearly(expires: later), lifetime()]) == .lifetime)
    }

    @Test func aRefundedLifetimeLeavesTheYearlyStanding() {
        #expect(PremiumAccess.resolve([yearly(expires: later), lifetime(revoked: earlier)]) == .yearly(until: later))
    }

    /// The monthly is ours now (plan S9); an identifier never sold stays ignored.
    @Test func anUnknownProductIsIgnored() {
        let weekly = PremiumAccess.Entitlement(productID: "sardor.WaterBuddy.premium.weekly", expires: later, revoked: nil)
        let elsewhere = PremiumAccess.Entitlement(productID: "com.example.other.lifetime", expires: nil, revoked: nil)
        #expect(PremiumAccess.resolve([weekly, elsewhere]) == .free)
    }

    @Test func twoYearlyPeriodsReadTheLaterEnd() {
        #expect(PremiumAccess.resolve([yearly(expires: later), yearly(expires: nextYear)]) == .yearly(until: nextYear))
    }

    /// Review Focus 5 of the foundation, under the grace ruling: a lapsed plan reads free on the next
    /// read in which StoreKit no longer lists it. Replaces
    /// `anExpiryPassingWhileTheAppRunsReadsFreeOnTheNextRead`.
    @Test func aSubscriptionStoreKitStopsListingReadsFree() {
        #expect(PremiumAccess.resolve([monthly(expires: later)]) == .monthly(until: later))
        #expect(PremiumAccess.resolve([]) == .free)
    }

    @Test func aMonthlyIsPaidUntilItsPeriodEnds() {
        #expect(PremiumAccess.resolve([monthly(expires: later)]) == .monthly(until: later))
    }

    @Test func theLifetimeWinsOverAMonthlyBesideIt() {
        #expect(PremiumAccess.resolve([monthly(expires: later), lifetime()]) == .lifetime)
    }

    @Test func theSubscriptionEndingLaterIsTheOneHeld() {
        #expect(PremiumAccess.resolve([monthly(expires: nextYear), yearly(expires: later)]) == .monthly(until: nextYear))
        #expect(PremiumAccess.resolve([monthly(expires: later), yearly(expires: nextYear)]) == .yearly(until: nextYear))
    }

    @Test func onATieTheYearlyIsHeld() {
        #expect(PremiumAccess.resolve([monthly(expires: later), yearly(expires: later)]) == .yearly(until: later))
    }

    /// The final review's minor 3: *Manage Subscription* follows a subscription, beside a lifetime
    /// purchase too.
    @Test func aSubscriptionBesideALifetimeIsStillOneToManage() {
        #expect(PremiumAccess.holdsSubscription([lifetime(), monthly(expires: later)]))
        #expect(PremiumAccess.holdsSubscription([yearly(expires: earlier)]))
        #expect(!PremiumAccess.holdsSubscription([lifetime()]))
        #expect(!PremiumAccess.holdsSubscription([monthly(expires: later, revoked: earlier)]))
        #expect(!PremiumAccess.holdsSubscription([]))
    }

    @Test func theYearlySavesWhatTwelveMonthsWouldCost() {
        #expect(PremiumAccess.yearlySaving(yearly: price("19.99"), monthly: price("2.99")) == 0.44)
        #expect(PremiumAccess.yearlySaving(yearly: 24, monthly: price("2.5")) == 0.2)
    }

    /// Review Focus 2.
    @Test func aYearlyDearerThanTwelveMonthsSavesNothing() {
        #expect(PremiumAccess.yearlySaving(yearly: 40, monthly: price("2.99")) == nil)
        #expect(PremiumAccess.yearlySaving(yearly: price("35.88"), monthly: price("2.99")) == nil)
        #expect(PremiumAccess.yearlySaving(yearly: price("35.6"), monthly: price("2.99")) == nil)
        #expect(PremiumAccess.yearlySaving(yearly: price("19.99"), monthly: 0) == nil)
        #expect(PremiumAccess.yearlySaving(yearly: 0, monthly: price("2.99")) == nil)
    }

    @Test func theSavingNeedsBothSubscriptionsLoaded() {
        let monthlyOffer = PremiumAccess.Plan(id: PremiumAccess.monthlyID, kind: .monthly, price: "$2.99", amount: price("2.99"), trial: nil)
        let yearlyOffer = PremiumAccess.Plan(id: PremiumAccess.yearlyID, kind: .yearly, price: "$19.99", amount: price("19.99"), trial: nil)
        #expect(PremiumAccess.yearlySaving(among: [monthlyOffer, yearlyOffer]) == 0.44)
        #expect(PremiumAccess.yearlySaving(among: [yearlyOffer]) == nil)
    }

    @Test func theProductIDsAreThreeAndOurs() {
        #expect(PremiumAccess.productIDs == [
            "sardor.WaterBuddy.premium.monthly", "sardor.WaterBuddy.premium.yearly", "sardor.WaterBuddy.premium.lifetime",
        ])
        #expect(Set(PremiumAccess.productIDs).count == 3)
        #expect(PremiumAccess.productIDs.allSatisfy { $0.hasPrefix("sardor.WaterBuddy.premium.") })
    }

    @Test func onlyTheFreeStatusIsNotPremium() {
        #expect(!PremiumAccess.Status.free.isPremium)
        #expect(PremiumAccess.Status.monthly(until: later).isPremium)
        #expect(PremiumAccess.Status.yearly(until: later).isPremium)
        #expect(PremiumAccess.Status.lifetime.isPremium)
    }
}
```

  - the words' fixtures: `yearlyPlan(trial:)` → `PremiumAccess.Plan(id: PremiumAccess.yearlyID, kind: .yearly, price: "$19.99", amount: price("19.99"), trial: trial)`;
    `lifetimePlan` → `PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "$39.99", amount: price("39.99"), trial: nil)`;
  - in `PremiumWordsTests`, replace `theHeldPlanReadsItsDate` with:

```swift
    @Test func theHeldPlanReadsItsDate() {
        let strings = table("en")
        let until = ISO8601DateFormatter().date(from: "2027-10-21T12:00:00Z")!
        let yearlyLine = PremiumAccess.Status.yearly(until: until).line(in: strings, locale: en, now: now)
        #expect(yearlyLine?.hasPrefix("Yearly, until ") == true)
        #expect(yearlyLine?.contains("2027") == true)
        let monthlyLine = PremiumAccess.Status.monthly(until: until).line(in: strings, locale: en, now: now)
        #expect(monthlyLine?.hasPrefix("Monthly, until ") == true)
        #expect(PremiumAccess.Status.lifetime.line(in: strings, locale: en, now: now) == "Lifetime")
        #expect(PremiumAccess.Status.free.line(in: strings, locale: en, now: now) == nil)
    }

    /// Review Focus 4: in grace the date has passed; the line names the plan held, never a date in
    /// the past.
    @Test func aPassedDateIsNotShown() {
        let strings = table("en")
        #expect(PremiumAccess.Status.yearly(until: earlier).line(in: strings, locale: en, now: now) == "Yearly")
        #expect(PremiumAccess.Status.monthly(until: now).line(in: strings, locale: en, now: now) == "Monthly")
    }
```

  In `WaterBuddyTests/PremiumStoreTests.swift`:
  - the fixtures: `yearlyPlan` gains `amount: Decimal(string: "19.99")!,` before `trial:`;
    `lifetimePlan` gains `amount: Decimal(string: "39.99")!,`; in `anAskToBuyIsPendingUntilApproved`
    the literal plan gains `amount: 0,`;
  - in `StoreKitSessionTests`, every `PremiumAccess.resolve(await source.entitlements(), now: .now)`
    → `PremiumAccess.resolve(await source.entitlements())` (four sites, `grep -n 'now: .now'`).

- [ ] **Step 2: Land the API as a stub** in `WaterBuddy/PremiumAccess.swift`, so the tests compile
  and fail on their values: Step 4's declarations with these bodies — `productIDs` stays
  `[yearlyID, lifetimeID]`; `resolve` returns `.free`; `holdsSubscription` returns `false`; both
  `yearlySaving`s return `nil`; `Status.line` returns `nil`. Make Step 4's three call-site edits
  (`PremiumStore`, `PaywallView`, `SettingsView`) now, so the target compiles.
- [ ] **Step 3: Run it RED.** `UNIT -only-testing:WaterBuddyTests/PremiumAccessTests -only-testing:WaterBuddyTests/PremiumWordsTests`
  (log `t3-red`). Expected: the build succeeds; most of `PremiumAccessTests` fails (all but
  `nothingHeldIsFree`, `aRefundedYearlyIsFree`, `aYearlyWithNoEndIsNotTakenAsPaid`,
  `anUnknownProductIsIgnored`, `onlyTheFreeStatusIsNotPremium` and `aYearlyDearer…`, which a
  `.free`/`nil` stub satisfies — each named in the ledger as first seen green), and
  `theHeldPlanReadsItsDate` and `aPassedDateIsNotShown` fail.
- [ ] **Step 4: The real declarations.** In `WaterBuddy/PremiumAccess.swift`:
  - the IDs (replacing the two `static let`s and `productIDs`):

```swift
    /// The monthly subscription — group *WaterBuddy Premium*, one level below the yearly, no
    /// introductory offer.
    static let monthlyID = "sardor.WaterBuddy.premium.monthly"

    /// The yearly subscription — the same group, its highest level, one week free for the eligible.
    static let yearlyID = "sardor.WaterBuddy.premium.yearly"

    /// The lifetime purchase, a non-consumable.
    static let lifetimeID = "sardor.WaterBuddy.premium.lifetime"

    /// The one spelling of all three, in the order the paywall draws them. Nothing else in the
    /// product writes any of these strings.
    static let productIDs = [monthlyID, yearlyID, lifetimeID]
```

  - `Status` (replacing it whole):

```swift
    /// What the user holds.
    nonisolated enum Status: Sendable, Equatable {
        case free
        /// A subscription, paid through the end of its current period — which is all a transaction
        /// says; whether it renews is Apple's own sheet's to say. In a billing grace period that date
        /// has already passed and the plan is still held (spec
        /// `2026-10-21-premium-paywall-and-monthly-design.md` §3.2).
        case monthly(until: Date)
        case yearly(until: Date)
        case lifetime

        var isPremium: Bool { self != .free }

        /// *Monthly, until 21 November 2026*, *Yearly, until 21 October 2027* or *Lifetime* — the
        /// Settings card's line and the paywall's once something is held. Once the date has passed —
        /// a subscriber in grace — the plan's name alone. `nil` when nothing is held. `now` is
        /// ``PremiumStore/now``, never a bare `Date()` in a view (rule `30-rollover`).
        func line(in strings: Bundle, locale: Locale, now: Date) -> String? {
            switch self {
            case .free:
                return nil
            case .lifetime:
                return strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            case .monthly(let until):
                guard until > now else {
                    return strings.localizedString(forKey: "Monthly", value: nil, table: nil)
                }
                return strings.localized("Monthly, until %1$@", Self.day(until, locale: locale), locale: locale)
            case .yearly(let until):
                guard until > now else {
                    return strings.localizedString(forKey: "Yearly", value: nil, table: nil)
                }
                return strings.localized("Yearly, until %1$@", Self.day(until, locale: locale), locale: locale)
            }
        }

        /// A period's end, as the locale writes a date in full.
        private static func day(_ date: Date, locale: Locale) -> String {
            date.formatted(Date.FormatStyle(date: .long, time: .omitted).locale(locale))
        }
    }
```

  - `resolve` and its neighbours (replacing `resolve` whole):

```swift
    /// The answer, from whatever StoreKit said.
    ///
    /// **StoreKit's current entitlements say whether a subscription is held** — the owner's ruling
    /// of 2026-10-21 (spec `2026-10-21-premium-paywall-and-monthly-design.md` §3.2). They carry a
    /// subscription that is subscribed or in its billing grace period and leave out one that has
    /// lapsed; checking the period's end again here, as the foundation did, read a subscriber in
    /// grace — and one opening the app between a period's end and the renewal's transaction — as
    /// free. So this ignores an unknown product and anything revoked, and nothing else, and takes no
    /// clock.
    ///
    /// A subscription with no end is not taken as paid: StoreKit gives every subscription one, and a
    /// missing one is not evidence of payment. A lifetime purchase wins; else the subscription with
    /// the later end, the yearly on a tie.
    static func resolve(_ entitlements: [Entitlement]) -> Status {
        let standing = entitlements.filter { $0.revoked == nil }
        if standing.contains(where: { $0.productID == lifetimeID }) {
            return .lifetime
        }
        let held = standing.compactMap { entitlement -> (kind: Plan.Kind, until: Date)? in
            guard let until = entitlement.expires else { return nil }
            switch entitlement.productID {
            case yearlyID: return (.yearly, until)
            case monthlyID: return (.monthly, until)
            default: return nil
            }
        }
        let latest = held.max { first, second in
            first.until != second.until
                ? first.until < second.until
                : first.kind == .monthly && second.kind == .yearly
        }
        guard let latest else { return .free }
        return latest.kind == .yearly ? .yearly(until: latest.until) : .monthly(until: latest.until)
    }

    /// Whether a subscription stands among the entitlements — beside a lifetime purchase too, which
    /// ``resolve(_:)`` reads as ``Status/lifetime``. What *Manage Subscription* manages (the final
    /// review's minor 3).
    static func holdsSubscription(_ entitlements: [Entitlement]) -> Bool {
        entitlements.contains { entitlement in
            entitlement.revoked == nil
                && entitlement.expires != nil
                && (entitlement.productID == yearlyID || entitlement.productID == monthlyID)
        }
    }

    /// What the yearly saves against twelve months of the monthly, `1 − yearly ÷ (12 × monthly)`,
    /// rounded **down** to a whole percent — never more than is true — as a fraction (`0.44`).
    /// Computed in `Decimal`, so a price like 2.99 is exact. `nil` when either price is not positive
    /// or the saving is under one percent (Review Focus 2).
    static func yearlySaving(yearly: Decimal, monthly: Decimal) -> Double? {
        guard yearly > 0, monthly > 0 else { return nil }
        var percent = (1 - yearly / (monthly * 12)) * 100
        var whole = Decimal()
        NSDecimalRound(&whole, &percent, 0, .down)
        guard whole >= 1 else { return nil }
        return NSDecimalNumber(decimal: whole).doubleValue / 100
    }

    /// The saving among the plans the paywall loaded; `nil` while either subscription is missing.
    static func yearlySaving(among plans: [Plan]) -> Double? {
        guard let yearly = plans.first(where: { $0.kind == .yearly }),
              let monthly = plans.first(where: { $0.kind == .monthly }) else { return nil }
        return yearlySaving(yearly: yearly.amount, monthly: monthly.amount)
    }
```

  - in `Plan`: `Kind` → `case monthly, yearly, lifetime`; after `price` add

```swift
        /// StoreKit's `price` — for the yearly's saving alone, never drawn (spec §3.2).
        let amount: Decimal
```

    the `trial` comment's "the product is yearly by its identity (plan P5)" → "the product is
    monthly or yearly by its identity (foundation plan P5)"; and each word gains its monthly case:

```swift
        /// *Monthly*, *Yearly* or *Lifetime* — the tile's name and its VoiceOver label.
        func name(in strings: Bundle) -> String {
            switch kind {
            case .monthly: strings.localizedString(forKey: "Monthly", value: nil, table: nil)
            case .yearly: strings.localizedString(forKey: "Yearly", value: nil, table: nil)
            case .lifetime: strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            }
        }
```

    in `priceLine`, `case .monthly: return strings.localized("%1$@ a month", price, locale: locale)`
    before `case .yearly:`; in `terms`, before `case .yearly:`:

```swift
            case .monthly:
                return strings.localized(
                    "%1$@ is charged each month until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
                    price, locale: locale
                )
```

    and in `action`, `case .monthly: "Subscribe"` before `case .yearly:`.
  - `WaterBuddy/PremiumStore.swift`: `@ObservationIgnored private let now: () -> Date` →

```swift
    /// The store's clock — the one the card and the sheet hand to ``PremiumAccess/Status/line(in:locale:now:)``
    /// (rule `30-rollover`'s *The clock*).
    @ObservationIgnored let now: () -> Date
```

    `refresh()`'s first line → `let status = PremiumAccess.resolve(await source.entitlements())`;
    in `Plan(product)`'s `self.init(…)`:

```swift
        self.init(
            id: product.id,
            kind: switch product.id {
            case PremiumAccess.lifetimeID: .lifetime
            case PremiumAccess.monthlyID: .monthly
            default: .yearly
            },
            price: product.displayPrice,
            amount: product.price,
            trial: trial
        )
```

  - `WaterBuddy/PaywallView.swift`: `status.line(in: strings, locale: locale)` →
    `status.line(in: strings, locale: locale, now: premium.now())`;
    `WaterBuddy/SettingsView.swift`: `premium.state.status?.line(in: strings, locale: locale)` →
    `premium.state.status?.line(in: strings, locale: locale, now: premium.now())`.
- [ ] **Step 5: Run it GREEN.** The same filters (log `t3-green`): every test passes; then
  `UNIT -only-testing:WaterBuddyTests/PremiumStoreTests -only-testing:WaterBuddyTests/StoreKitSessionTests`
  — all pass but two, each ledgered by name: `anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead`,
  which the grace ruling turns red until Task 5 rewrites it, and
  `bothProductsLoadAndTheYearlyOffersAFreeWeek`, which now asks for three products the local
  configuration does not yet hold (Task 5 adds the monthly and rewrites it); `anExpiredYearlyReadsFree`
  is skipped (#157). No warning names a Premium file (`grep -E ': warning:' … | grep -i premium`).
- [ ] **Step 6:** stage `WaterBuddy/PremiumAccess.swift WaterBuddy/PremiumStore.swift
  WaterBuddy/PaywallView.swift WaterBuddy/SettingsView.swift WaterBuddyTests/PremiumAccessTests.swift
  WaterBuddyTests/PremiumStoreTests.swift`. Ledger the runs.

---

### Task 4: Set A and the switch

**Files:**
- Modify: `WaterBuddy/PremiumSet.swift` (whole)
- Modify: `WaterBuddy/PaywallView.swift` (the switch's statics)
- Create: `WaterBuddyTests/PremiumSetTests.swift`
- Modify: `WaterBuddyTests/PremiumAccessTests.swift` (`PaywallOfferTests`)

**Interfaces — produces:** `PremiumSet.understand`; `PremiumSet.Feature` (`monthView`, `patterns`,
`insights`, `recap`; `title(in:)`, `line(in:)`, `caption(in:) -> String?`, `symbol`);
`PremiumSet.features`, `isOnSale`, `static let onSale: [PremiumSet]`;
`PaywallView.isOffered(debug:arguments:setsOnSale:privacyPolicy:) -> Bool`,
`PaywallView.isDebug: Bool`, `PaywallView.shownSets(debug:) -> [PremiumSet]`.

- [ ] **Step 1: The tests.** `WaterBuddyTests/PremiumSetTests.swift`:

```swift
//
//  PremiumSetTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import Testing
import UIKit
@testable import WaterBuddy

/// Set A as the paywall and the card draw it (spec `2026-10-21-premium-paywall-and-monthly-design.md`
/// §3.6). The suite is not `@MainActor`: the switch reads the sets from off it.
struct PremiumSetTests {

    @Test func setAListsItsFourFeaturesInOrder() {
        #expect(PremiumSet.allCases == [.understand])
        #expect(PremiumSet.understand.features == [.monthView, .patterns, .insights, .recap])
    }

    /// Step 5 of the spec's §1 puts set A on sale, with the recap — and changes this test with it.
    @Test func setAIsNotOnSaleUntilItsLastFeatureIsBuilt() {
        #expect(!PremiumSet.understand.isOnSale)
        #expect(PremiumSet.onSale.isEmpty)
    }

    /// An unknown symbol draws nothing at all (rule `65-accessibility`).
    @Test @MainActor func everyFeatureGlyphResolves() {
        for feature in PremiumSet.Feature.allCases {
            #expect(UIImage(systemName: feature.symbol) != nil, "\(feature.symbol) draws nothing")
        }
    }

    @Test func theCardPreviewsEveryFeatureButTheRecap() {
        let strings = Bundle.main
        #expect(PremiumSet.Feature.recap.caption(in: strings) == nil)
        #expect(PremiumSet.Feature.allCases.filter { $0.caption(in: strings) != nil } == [.monthView, .patterns, .insights])
    }
}
```

  And replace `struct PaywallOfferTests { … }` in `WaterBuddyTests/PremiumAccessTests.swift`:

```swift
/// Not `@MainActor`: the switch is read from off it (rule `43-concurrency`).
struct PaywallOfferTests {

    private let link = URL(string: "https://example.com/privacy")

    @Test func aDebugBuildOffersThePaywallOnlyWhenLaunchedToOfferIt() {
        #expect(PaywallView.launchArgument == "-WaterBuddyPremium")
        #expect(!PaywallView.isOffered(debug: true, arguments: [], setsOnSale: 0, privacyPolicy: nil))
        #expect(!PaywallView.isOffered(debug: true, arguments: ["-WaterBuddyFreshStart", "YES"], setsOnSale: 3, privacyPolicy: link))
        #expect(PaywallView.isOffered(debug: true, arguments: ["-WaterBuddyPremium", "YES"], setsOnSale: 0, privacyPolicy: nil))
    }

    /// Spec §3.6: a set on sale **and** a privacy link — a release cannot ship a dead link.
    @Test func aReleaseBuildOffersItOnlyWithASetOnSaleAndAPrivacyLink() {
        #expect(!PaywallView.isOffered(debug: false, arguments: [], setsOnSale: 0, privacyPolicy: link))
        #expect(!PaywallView.isOffered(debug: false, arguments: ["-WaterBuddyPremium", "YES"], setsOnSale: 0, privacyPolicy: link))
        #expect(!PaywallView.isOffered(debug: false, arguments: [], setsOnSale: 1, privacyPolicy: nil))
        #expect(!PaywallView.isOffered(debug: false, arguments: [], setsOnSale: 1, privacyPolicy: URL(string: "OWNER-PRIVACY-URL")))
        #expect(!PaywallView.isOffered(debug: false, arguments: [], setsOnSale: 1, privacyPolicy: URL(string: "http://example.com/privacy")))
        #expect(PaywallView.isOffered(debug: false, arguments: [], setsOnSale: 1, privacyPolicy: link))
    }

    /// The gate's own runs are not launched to offer it, so nothing in them meets the card.
    @Test func theTestRunItselfIsNotOfferedThePaywall() {
        #if DEBUG
        #expect(!PaywallView.isOfferedHere)
        #endif
    }

    @Test func aDebugSheetListsEverySetAndAReleaseOneOnlyThoseOnSale() {
        #expect(PaywallView.shownSets(debug: true) == PremiumSet.allCases)
        #expect(PaywallView.shownSets(debug: false) == PremiumSet.onSale)
    }

    @Test func theLinksAreApplesTermsAndAPageOfOurs() {
        #expect(PaywallView.termsOfUse?.absoluteString == "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        #expect(PaywallView.privacyPolicy?.scheme == "https")
    }
}
```

- [ ] **Step 2: Land a stub** so both compile: `PremiumSet` with `case understand`, `Feature` with
  its four cases, `title`/`line` returning `""`, `caption` returning `nil`, `symbol` returning `""`,
  `features` returning `[]`, `isOnSale` `true`, `onSale` `allCases`; in `PaywallView`, Step 4's
  statics with `isOffered(debug:arguments:setsOnSale:privacyPolicy:)` returning `true` and
  `shownSets` returning `[]`.
- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/PremiumSetTests -only-testing:WaterBuddyTests/PaywallOfferTests`
  (log `t4-red`). Expected: every `PremiumSetTests` test fails; in `PaywallOfferTests` the first,
  second, third and fourth fail, and `theLinksAre…` fails on its `https` alone, as it has since the
  foundation.
- [ ] **Step 4: The real code.** `WaterBuddy/PremiumSet.swift`, whole:

```swift
//
//  PremiumSet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation

/// The sets Premium sells — one case per set (`docs/ROADMAP.md` §5, *Sold as sets*).
///
/// **A case is not a sale.** ``isOnSale`` says whether every feature a set lists is built. Only a set
/// on sale turns the paywall on in a Release build (``PaywallView/isOffered(arguments:)``), and only
/// those are listed there; a DEBUG build launched to offer the paywall lists every set, so it can be
/// seen whole while its features are still being built (spec
/// `2026-10-21-premium-paywall-and-monthly-design.md` §3.6, amending the foundation's *no case*).
///
/// `nonisolated`, so the switch reads it from off the main actor (rule `43-concurrency`).
nonisolated enum PremiumSet: CaseIterable, Sendable, Equatable {

    /// Set A — month view and full history, patterns, personal AI insights, the monthly recap.
    case understand

    /// One thing a set does, as the paywall and the Settings card name it.
    nonisolated enum Feature: CaseIterable, Sendable, Hashable {
        case monthView, patterns, insights, recap

        /// The paywall row's title.
        func title(in strings: Bundle) -> String {
            strings.localizedString(forKey: titleKey, value: nil, table: nil)
        }

        /// The paywall row's one line.
        func line(in strings: Bundle) -> String {
            strings.localizedString(forKey: lineKey, value: nil, table: nil)
        }

        /// The Settings card's caption for its preview — `nil` for the recap, which the card does
        /// not preview.
        func caption(in strings: Bundle) -> String? {
            captionKey.map { strings.localizedString(forKey: $0, value: nil, table: nil) }
        }

        /// The row's glyph. `PremiumSetTests` proves each resolves: an unknown symbol draws nothing.
        var symbol: String {
            switch self {
            case .monthView: "calendar"
            case .patterns: "chart.bar.fill"
            case .insights: "sparkles"
            case .recap: "doc.text.image"
            }
        }

        private var titleKey: String {
            switch self {
            case .monthView: "Month view and full history"
            case .patterns: "Your patterns"
            case .insights: "Personal AI insights"
            case .recap: "A monthly recap"
            }
        }

        private var lineKey: String {
            switch self {
            case .monthView: "Every day you have logged, a month at a glance"
            case .patterns: "When you drink, weekdays against weekends"
            case .insights: "Using Apple Intelligence, private on your iPhone"
            case .recap: "Your month in one card, yours to share"
            }
        }

        private var captionKey: String? {
            switch self {
            case .monthView: "Month view"
            case .patterns: "Patterns"
            case .insights: "AI insights"
            case .recap: nil
            }
        }
    }

    /// What the set does, in the order the paywall lists it.
    var features: [Feature] {
        switch self {
        case .understand: [.monthView, .patterns, .insights, .recap]
        }
    }

    /// Whether every feature the set lists is built. **Set A goes on sale in step 5**, with the
    /// recap; `PremiumSetTests` pins the `false` and names that step.
    var isOnSale: Bool {
        switch self {
        case .understand: false
        }
    }

    /// The sets on sale, in declaration order.
    static let onSale: [PremiumSet] = allCases.filter(\.isOnSale)
}
```

  In `WaterBuddy/PaywallView.swift`, replace `isOffered(debug:arguments:sets:)` and
  `isOffered(arguments:)` with:

```swift
    /// The switch, as a pure function of the build, the arguments, the sets on sale and the privacy
    /// link: DEBUG offers it when launched to; Release only while a set is on sale **and** the link
    /// is an `https` address — so a release cannot ship a paywall with a dead privacy link (spec
    /// `2026-10-21-premium-paywall-and-monthly-design.md` §3.6).
    nonisolated static func isOffered(debug: Bool, arguments: [String], setsOnSale: Int, privacyPolicy: URL?) -> Bool {
        debug ? arguments.contains(launchArgument) : setsOnSale > 0 && privacyPolicy?.scheme == "https"
    }

    /// The switch for this build.
    nonisolated static func isOffered(arguments: [String]) -> Bool {
        isOffered(debug: isDebug, arguments: arguments, setsOnSale: PremiumSet.onSale.count, privacyPolicy: privacyPolicy)
    }

    /// Whether this is a DEBUG build.
    nonisolated static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    /// The sets the sheet and the card list: every set in DEBUG, so a set can be seen whole while it
    /// is built; in Release only those on sale.
    nonisolated static func shownSets(debug: Bool) -> [PremiumSet] {
        debug ? PremiumSet.allCases : PremiumSet.onSale
    }
```

- [ ] **Step 5: GREEN.** The same filters (log `t4-green`): `PremiumSetTests` 4 passed;
  `PaywallOfferTests` 4 passed, `theLinksAre…` red on its `https` alone (the URL). No new warning
  names `PremiumSet` or `PaywallView`; `everyFeatureGlyphResolves` raised no isolation warning.
- [ ] **Step 6:** stage `WaterBuddy/PremiumSet.swift WaterBuddy/PaywallView.swift
  WaterBuddyTests/PremiumSetTests.swift WaterBuddyTests/PremiumAccessTests.swift`. Ledger.

---

### Task 5: The store — three plans, the read number, restore, manage

**Files:**
- Modify: `WaterBuddy/PremiumStore.swift`
- Modify: `WaterBuddyTests/WaterBuddy.storekit`
- Test: `WaterBuddyTests/PremiumStoreTests.swift`

**Interfaces — produces:** `PremiumStore.Restoring` (`idle`, `restoring`, `nothingFound`);
`PremiumStore.restoring`; `PremiumStore.holdsSubscription: Bool`; `PremiumStore.canManage: Bool`;
`PremiumStore.Source.canManage: () -> Bool`.

- [ ] **Step 1: The tests.** In `WaterBuddyTests/PremiumStoreTests.swift`:
  - fixtures, after `lifetimePlan`:

```swift
private let monthlyPlan = PremiumAccess.Plan(
    id: PremiumAccess.monthlyID, kind: .monthly, price: "$2.99", amount: Decimal(string: "2.99")!, trial: nil
)
private let heldMonthly = PremiumAccess.Entitlement(productID: PremiumAccess.monthlyID, expires: later, revoked: nil)
```

  - `FakeAppStore`: `plans` defaults to `.success([monthlyPlan, yearlyPlan, lifetimePlan])`; add

```swift
    /// Set, the next read waits here — holding what it read before the wait — until resumed.
    var holdsNextRead = false
    var readGate: CheckedContinuation<Void, Never>?
    private(set) var reads = 0
    /// Set, a restore waits here until resumed.
    var holdsRestore = false
    var restoreGate: CheckedContinuation<Void, Never>?
    /// Whether Apple's manage sheet works here.
    var manages = true
```

    rename the existing counter `manages` → `manageCalls` (and its use in `manageOpensApplesSheet`);
    and the `source`:

```swift
    var source: PremiumStore.Source {
        PremiumStore.Source(
            entitlements: {
                self.reads += 1
                let held = self.held
                if self.holdsNextRead {
                    self.holdsNextRead = false
                    await withCheckedContinuation { self.readGate = $0 }
                }
                return held
            },
            updates: { self.updates },
            plans: { try self.plans.get() },
            buy: { productID in
                self.bought.append(productID)
                if self.holdsPurchase {
                    await withCheckedContinuation { self.gate = $0 }
                }
                let outcome = try self.outcome.get()
                if outcome == .bought { self.held = self.boughtLeaves }
                return outcome
            },
            restore: {
                self.restores += 1
                if self.holdsRestore {
                    await withCheckedContinuation { self.restoreGate = $0 }
                }
                if self.restoreFails { throw Refused() }
            },
            manage: { self.manageCalls += 1 },
            canManage: { self.manages }
        )
    }
```

  - the suite gains `@Suite(.timeLimit(.minutes(1)))` above `struct PremiumStoreTests` (minor 9);
  - `plansLoadBoth` → `plansLoadAllThree`, expecting `.loaded([monthlyPlan, yearlyPlan, lifetimePlan])`;
    `oneProductMissingIsUnavailable` sets `fake.plans = .success([yearlyPlan, lifetimePlan])`;
    `aFailedLoadIsUnavailableAndTryingAgainRecovers` and `openingTheSheetAgainForgetsTheLastFailure`
    recover to and expect the three;
  - `restoreAsksTheAppStoreThenReads` gains `#expect(store.restoring == .idle)`;
    `aFailedRestoreStillReads` gains `#expect(store.restoring == .idle)` (a yearly is held);
  - `anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead` becomes (name and last assertion
    kept, spec §6):

```swift
    /// Review Focus 5 of the foundation, under the grace ruling: the store reads free once StoreKit
    /// stops listing the plan. Named apart from `PremiumAccessTests`' case (rule `85-testing`).
    @Test func anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead() async {
        let fake = FakeAppStore()
        fake.held = [heldYearly]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        #expect(store.state == .known(.yearly(until: later)))
        fake.held = []
        await store.refresh()
        #expect(store.state == .known(.free))
    }
```

  - and these, before it:

```swift
    @Test func aRestoreThatFindsNothingSaysSo() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.restore()
        #expect(fake.restores == 1)
        #expect(store.restoring == .nothingFound)
        #expect(store.state == .known(.free))
    }

    /// Review Focus 3.
    @Test func aSecondRestoreWhileOneRunsAsksOnce() async {
        let fake = FakeAppStore()
        fake.holdsRestore = true
        let store = PremiumStore(source: fake.source, now: { now })
        let first = Task { await store.restore() }
        await settle { fake.restoreGate != nil }
        #expect(store.restoring == .restoring)
        // A guard left open shows as a second restore that lands, not as a run that waits forever.
        fake.holdsRestore = false
        await store.restore()
        #expect(fake.restores == 1)
        fake.restoreGate?.resume()
        await first.value
        #expect(fake.restores == 1)
    }

    @Test func openingTheSheetAgainForgetsNothingToRestore() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.restore()
        #expect(store.restoring == .nothingFound)
        await store.prepare()
        #expect(store.restoring == .idle)
    }

    /// The final review's minor 4: two reads in flight, the older finishing last, never publishes.
    @Test func aReadOvertakenByANewerOneDoesNotPublish() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await settle { fake.reads >= 2 }
        fake.holdsNextRead = true
        let older = Task { await store.refresh() }
        await settle { fake.readGate != nil }
        fake.held = [heldLifetime]
        await store.refresh()
        #expect(store.state == .known(.lifetime))
        fake.readGate?.resume()
        await older.value
        #expect(store.state == .known(.lifetime))
    }

    /// The final review's minor 6.
    @Test func manageIsOfferedOnlyWhereItWorks() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        #expect(store.canManage)
        fake.manages = false
        #expect(!store.canManage)
    }

    /// The final review's minor 3.
    @Test func aLifetimeBesideAMonthlyStillHasASubscriptionToManage() async {
        let fake = FakeAppStore()
        fake.held = [heldLifetime, heldMonthly]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        #expect(store.state == .known(.lifetime))
        #expect(store.holdsSubscription)
    }
```

  - in `StoreKitSessionTests`: `bothProductsLoadAndTheYearlyOffersAFreeWeek` becomes

```swift
    @Test func allThreeProductsLoadAndOnlyTheYearlyOffersAFreeWeek() async throws {
        try await withSession { _ in
            let plans = try await PremiumStore.Source.live().plans()
            #expect(plans.map(\.id) == PremiumAccess.productIDs)
            #expect(plans.map(\.kind) == [.monthly, .yearly, .lifetime])
            #expect(plans.allSatisfy { !$0.price.isEmpty && $0.amount > 0 })
            #expect(plans.first { $0.kind == .yearly }?.trial == PremiumAccess.Plan.Period(value: 1, unit: .week))
            #expect(plans.first { $0.kind == .monthly }?.trial == nil)
            #expect(plans.first { $0.kind == .lifetime }?.trial == nil)
        }
    }

    /// The configuration's monthly plan is a month.
    @Test func theConfigurationsMonthlyRenewsEveryMonth() throws {
        let url = try #require(Bundle(for: TestBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let text = try String(contentsOf: url, encoding: .utf8)
        #expect(text.contains("\"recurringSubscriptionPeriod\" : \"P1M\""))
    }

    @Test func aBoughtMonthlyReadsMonthly() async throws {
        try await withSession { _ in
            let source = PremiumStore.Source.live()
            let outcome = try await source.buy(PremiumAccess.monthlyID)
            #expect(outcome == .bought)
            let status = PremiumAccess.resolve(await source.entitlements())
            guard case .monthly(let until) = status else {
                Issue.record("a bought monthly read \(status)")
                return
            }
            #expect(until > .now)
        }
    }

    /// The upgrade in one group (spec §3.1, measured in Task 1's probe).
    @Test func aMonthlyThenAYearlyReadsTheYearly() async throws {
        try await withSession { _ in
            let source = PremiumStore.Source.live()
            let first = try await source.buy(PremiumAccess.monthlyID)
            #expect(first == .bought)
            let second = try await source.buy(PremiumAccess.yearlyID)
            #expect(second == .bought)
            var status = PremiumAccess.resolve(await source.entitlements())
            for _ in 0..<50 {
                if case .yearly = status { break }
                try await Task.sleep(for: .milliseconds(100))
                status = PremiumAccess.resolve(await source.entitlements())
            }
            guard case .yearly = status else {
                Issue.record("a monthly then a yearly read \(status)")
                return
            }
        }
    }
```

    `aTrialUsedOnceIsNotOfferedAgain`'s two last lines → `let yearly = try #require(plans.first { $0.kind == .yearly })`
    and `#expect(yearly.trial == nil)` (S10); `anExpiredYearlyReadsFree`'s DocC sentence naming
    `aYearlyEndingAtThisInstantIsOver`, `aYearlyThatEndedIsOver` and both `anExpiryPassing…` cases →
    "Under the owner's grace ruling a lapsed plan reads free when StoreKit stops listing it
    (`aSubscriptionStoreKitStopsListingReadsFree`, `anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead`);
    this test asks the environment to stop listing it, which it does not."
- [ ] **Step 2: A stub**, so the tests compile: `Restoring`, `restoring` (never set),
  `holdsSubscription` (`false`), `canManage` (`true`), `Source.canManage` (`live`:
  `{ !ProcessInfo.processInfo.isiOSAppOnMac }`, `silent`: `{ false }`); `loadPlans` and `refresh`
  unchanged.
- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/PremiumStoreTests` (log `t5-red`).
  Expected failures: `plansLoadAllThree`, `aFailedLoad…` and `openingTheSheetAgainForgetsTheLastFailure`
  (three plans are *unavailable* under the stub's count of 2), `oneProductMissingIsUnavailable` (two of
  three are *loaded* under it), `aRestoreThatFindsNothingSaysSo`, `aSecondRestoreWhileOneRunsAsksOnce`,
  `openingTheSheetAgainForgetsNothingToRestore`, `aReadOvertakenByANewerOneDoesNotPublish`,
  `manageIsOfferedOnlyWhereItWorks`, `aLifetimeBesideAMonthly…`. First seen green, each ledgered:
  `restoreAsksTheAppStoreThenReads` and `aFailedRestoreStillReads` (on `.idle`), and the rewritten
  `anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead` (Task 3's `resolve` already reads an
  unlisted plan as free).
- [ ] **Step 4: The store.** In `WaterBuddy/PremiumStore.swift`:
  - `Plans`' DocC: "The two plans" → "The three plans"; `.unavailable`'s "did not return both
    products" → "did not return all three products";
  - after `Outcome`:

```swift
    /// Where a restore stands — *Restore Purchases* shows its progress, and says so when nothing was
    /// found (the final review's minor 5).
    nonisolated enum Restoring: Sendable, Equatable {
        case idle, restoring, nothingFound
    }
```

  - in `Source`, after `manage`:

```swift
        /// Whether Apple's manage sheet works here — not on a Mac ([MS] in the foundation spec).
        var canManage: () -> Bool
```

  - the published state, after `purchase`:

```swift
    private(set) var restoring: Restoring = .idle
    /// Whether a subscription stands — beside a lifetime purchase too — so *Manage Subscription*
    /// has something to manage (the final review's minor 3).
    private(set) var holdsSubscription = false
```

    and after `listener`:

```swift
    /// Numbers every read, so a read that a newer one overtook does not publish (minor 4).
    @ObservationIgnored private var reads = 0
```

  - `refresh()`, whole:

```swift
    /// Reads what is held, and publishes it only when it changed — and only if no newer read began
    /// while this one waited on StoreKit.
    func refresh() async {
        reads += 1
        let read = reads
        let entitlements = await source.entitlements()
        guard read == reads else { return }
        let status = PremiumAccess.resolve(entitlements)
        if state != .known(status) {
            state = .known(status)
        }
        let subscribed = PremiumAccess.holdsSubscription(entitlements)
        if holdsSubscription != subscribed {
            holdsSubscription = subscribed
        }
    }
```

  - `prepare()`'s body gains, before `await loadPlans()`:

```swift
        if restoring != .restoring {
            restoring = .idle
        }
```

  - `loadPlans()`: the `complete` line →
    `let complete = loaded.count == 3 && Set(loaded.map(\.kind)) == [.monthly, .yearly, .lifetime]`;
    its DocC "Reads both plans" → "Reads the three plans";
  - `restore()`, whole:

```swift
    /// Asks the App Store for the user's purchases again, then reads them — App Review asks every
    /// app that sells something restorable for this (foundation spec §3.3). A second tap while one
    /// runs asks nothing; what it found is said either way.
    func restore() async {
        guard restoring != .restoring else { return }
        restoring = .restoring
        do {
            try await source.restore()
        } catch {
            #if DEBUG
            print("WaterBuddy: restoring purchases failed; the state is read as it stands.")
            #endif
        }
        await refresh()
        restoring = state.status?.isPremium == true ? .idle : .nothingFound
    }
```

  - after `manage()`:

```swift
    /// Whether *Manage Subscription* is offered here.
    var canManage: Bool {
        source.canManage()
    }
```

  - `live()` gains `canManage: { !ProcessInfo.processInfo.isiOSAppOnMac }` after `manage:`;
    `silent()` gains `canManage: { false }`.
- [ ] **Step 3b: The configuration.** Xcode closed. In `WaterBuddyTests/WaterBuddy.storekit`, read
  the file, then insert into `subscriptionGroups[0].subscriptions`, after the yearly's object and in
  the file's own `"key" : value` format, the monthly:

```json
        {
          "adHocOffers" : [

          ],
          "codeOffers" : [

          ],
          "displayPrice" : "2.99",
          "familyShareable" : true,
          "groupNumber" : 2,
          "internalID" : "6754000004",
          "localizations" : [
            {
              "description" : "Every Premium extra, renewed each month.",
              "displayName" : "Premium Monthly",
              "locale" : "en_US"
            }
          ],
          "productID" : "sardor.WaterBuddy.premium.monthly",
          "recurringSubscriptionPeriod" : "P1M",
          "referenceName" : "Premium Monthly",
          "subscriptionGroupID" : "21754001",
          "type" : "RecurringSubscription",
          "winbackOffers" : [

          ]
        }
```

  (match the file's indentation and empty-array spelling as read). `python3 -c "import json;json.load(open('WaterBuddyTests/WaterBuddy.storekit'))"`
  prints nothing — read-only, a parse check.
- [ ] **Step 5: GREEN.** `UNIT -only-testing:WaterBuddyTests/PremiumStoreTests -only-testing:WaterBuddyTests/StoreKitSessionTests -only-testing:WaterBuddyTests/PremiumAccessTests`
  (log `t5-green`): every test passes, `anExpiredYearlyReadsFree` skipped. `import StoreKit` still in
  two files (`grep -rln 'import StoreKit$' WaterBuddy WaterBuddyWidget WaterBuddyWatch WaterBuddyWatchWidget`).
- [ ] **Step 6:** stage `WaterBuddy/PremiumStore.swift WaterBuddyTests/WaterBuddy.storekit
  WaterBuddyTests/PremiumStoreTests.swift`. Ledger.

---

### Task 6: The words

**Files:**
- Modify: `WaterBuddy/PremiumAccess.swift` (`Plan.period`, `Plan.note`)
- Modify: `WaterBuddy/Localizable.xcstrings` (27 keys) — **Xcode closed**
- Test: `WaterBuddyTests/PremiumAccessTests.swift` (`PremiumWordsTests`),
  `WaterBuddyTests/LocalizationTests.swift` (`premiumKeys`)

**Interfaces — produces:** `Plan.period(in: Bundle, locale: Locale, saving: Double?) -> String`;
`Plan.note(in: Bundle, locale: Locale) -> String?`.

- [ ] **Step 1: The tests.** In `PremiumAccessTests.swift`, after `lifetimePlan`:

```swift
private let monthlyPlan = PremiumAccess.Plan(id: PremiumAccess.monthlyID, kind: .monthly, price: "$2.99", amount: price("2.99"), trial: nil)
```

  `theButtonsNameNoLength`'s list gains `monthlyPlan`; and in `PremiumWordsTests`:

```swift
    @Test func theMonthlyReadsAsDesigned() {
        let strings = table("en")
        #expect(monthlyPlan.name(in: strings) == "Monthly")
        #expect(monthlyPlan.priceLine(in: strings, locale: en) == "$2.99 a month")
        #expect(monthlyPlan.action(in: strings) == "Subscribe")
        #expect(monthlyPlan.terms(in: strings, locale: en)
                == "$2.99 is charged each month until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.")
    }

    @Test func theTilesReadAsDrawn() {
        let strings = table("en")
        #expect(monthlyPlan.period(in: strings, locale: en, saving: 0.44) == "a month")
        #expect(monthlyPlan.note(in: strings, locale: en) == "Cancel any time")
        #expect(yearlyPlan(trial: week).period(in: strings, locale: en, saving: 0.44) == "a year · save 44%")
        #expect(yearlyPlan(trial: week).period(in: strings, locale: en, saving: nil) == "a year")
        #expect(yearlyPlan(trial: week).note(in: strings, locale: en) == "1 week free")
        #expect(yearlyPlan(trial: nil).note(in: strings, locale: en) == nil)
        #expect(lifetimePlan.period(in: strings, locale: en, saving: 0.44) == "once")
        #expect(lifetimePlan.note(in: strings, locale: en) == "Yours for good")
    }

    @Test(arguments: [("ru", "в месяц", "1 неделя бесплатно"), ("uz", "Oyiga", "1 hafta bepul")])
    func theNewLinesReadInTheirOwnLanguage(code: String, perMonth: String, freeWeek: String) {
        let locale = Locale(identifier: code)
        #expect(monthlyPlan.priceLine(in: table(code), locale: locale).contains(perMonth))
        #expect(yearlyPlan(trial: week).note(in: table(code), locale: locale) == freeWeek)
        let saving = yearlyPlan(trial: week).period(in: table(code), locale: locale, saving: 0.44)
        #expect(saving.contains("44"), "\(code): \(saving)")
        #expect(!saving.contains("save"), "\(code) fell back to English: \(saving)")
    }
```

  In `LocalizationTests.swift`, `premiumKeys` gains, after `"Yearly, until %1$@",`, every key in
  Step 4's table (27 lines, in its order).
- [ ] **Step 2: A stub**: `period` returns `""`, `note` returns `nil` (catalogue untouched).
- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/PremiumWordsTests -only-testing:WaterBuddyTests/PremiumStringTests`
  (log `t6-red`). Expected: `theTilesReadAsDrawn` and `theNewLinesReadInTheirOwnLanguage` fail;
  `PremiumStringTests` fails for `ru` and `uz` on the new keys; `theMonthlyReadsAsDesigned` passes
  in English on the keys themselves (first seen green, ledgered).
- [ ] **Step 4: The real words.** In `Plan`, after `action(in:)`:

```swift
        /// The tile's third line: *a month*; *a year* — with the saving when there is one, in the
        /// locale's own percent (plan S1); *once*.
        func period(in strings: Bundle, locale: Locale, saving: Double?) -> String {
            switch kind {
            case .monthly:
                return strings.localizedString(forKey: "a month", value: nil, table: nil)
            case .lifetime:
                return strings.localizedString(forKey: "once", value: nil, table: nil)
            case .yearly:
                guard let saving else {
                    return strings.localizedString(forKey: "a year", value: nil, table: nil)
                }
                return strings.localized("a year · save %1$@", saving.formatted(.percent.locale(locale)), locale: locale)
            }
        }

        /// The tile's last line: *Cancel any time*; the free week — Foundation's words for its length
        /// (foundation plan P3) — when StoreKit offers it; *Yours for good*. `nil` for a yearly with
        /// no free week.
        func note(in strings: Bundle, locale: Locale) -> String? {
            switch kind {
            case .monthly:
                return strings.localizedString(forKey: "Cancel any time", value: nil, table: nil)
            case .lifetime:
                return strings.localizedString(forKey: "Yours for good", value: nil, table: nil)
            case .yearly:
                guard let length = trial?.formatted(locale: locale) else { return nil }
                return strings.localized("%1$@ free", length, locale: locale)
            }
        }
```

  Then the catalogue, Xcode closed. Each key below becomes one entry in the file's own shape —

```json
    "<key>": {
      "extractionState": "manual",
      "localizations": {
        "en": { "stringUnit": { "state": "translated", "value": "<en>" } },
        "ru": { "stringUnit": { "state": "translated", "value": "<ru>" } },
        "uz": { "stringUnit": { "state": "translated", "value": "<uz>" } }
      }
    },
```

  — written out with the file's own line breaks and indentation (as `"%1$@ a year"`'s entry reads),
  inserted as one block after the `"Yearly, until %1$@"` entry's closing brace. `en` is the key
  unless the table says otherwise.

| Key | `ru` | `uz` |
|---|---|---|
| `Monthly` | `На месяц` | `Oylik` |
| `a month` | `в месяц` | `oyiga` |
| `a year` | `в год` | `yiliga` |
| `once` | `один раз` | `bir marta` |
| `%1$@ a month` | `%1$@ в месяц` | `Oyiga %1$@` |
| `a year · save %1$@` | `в год · выгода %1$@` | `yiliga · %1$@ tejash` |
| `%1$@ free` | `%1$@ бесплатно` | `%1$@ bepul` |
| `Best value` | `Выгоднее всего` | `Eng foydali` |
| `Cancel any time` | `Отмена в любой момент` | `Istalgan vaqtda bekor qilish` |
| `Yours for good` | `Навсегда ваш` | `Butunlay sizniki` |
| `%1$@ is charged each month until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.` | `%1$@ списывается каждый месяц, пока вы не отмените подписку. Отмените её не позднее чем за 24 часа до продления в настройках аккаунта Apple.` | `Obunani bekor qilmaguningizcha har oy %1$@ yechiladi. Uni yangilanishdan kamida 24 soat oldin Apple hisobingiz sozlamalarida bekor qiling.` |
| `Monthly, until %1$@` | `На месяц, до %1$@` | `Oylik, %1$@ gacha` |
| `See how you really drink, and what would help.` | `Узнайте, как вы на самом деле пьёте и что вам поможет.` | `Qanday ichishingizni va sizga nima yordam berishini bilib oling.` |
| `Month view and full history` | `Месяц целиком и вся история` | `Oy ko‘rinishi va to‘liq tarix` |
| `Every day you have logged, a month at a glance` | `Каждый записанный день и весь месяц на одном экране` | `Har bir yozilgan kun va butun oy bir qarashda` |
| `Your patterns` | `Ваши привычки` | `Odatlaringiz` |
| `When you drink, weekdays against weekends` | `Когда вы пьёте, будни и выходные` | `Qachon ichasiz, ish va dam olish kunlari` |
| `Personal AI insights` | `Личные советы ИИ` | `Shaxsiy AI tavsiyalari` |
| `Using Apple Intelligence, private on your iPhone` | `С Apple Intelligence, только на вашем iPhone` | `Apple Intelligence bilan, faqat iPhone’ingizda` |
| `A monthly recap` | `Итоги месяца` | `Oylik xulosa` |
| `Your month in one card, yours to share` | `Ваш месяц в одной карточке — можно поделиться` | `Oyingiz bitta kartada — ulashish mumkin` |
| `New Premium features arrive in updates, included.` | `Новые возможности Premium приходят с обновлениями и уже включены.` | `Yangi Premium imkoniyatlari yangilanishlar bilan keladi va narxga kiradi.` |
| `Month view` | `Месяц` | `Oy` |
| `Patterns` | `Привычки` | `Odatlar` |
| `AI insights` | `Советы ИИ` | `AI tavsiyalari` |
| `Done` | `Готово` | `Tayyor` |
| `No purchases to restore.` | `Нет покупок для восстановления.` | `Tiklash uchun xaridlar yo‘q.` |

  `python3 -c "import json;json.load(open('WaterBuddy/Localizable.xcstrings'))"` prints nothing, and
  the key count is 140 + 27 = **167** (a read-only `python3` count).
- [ ] **Step 5: GREEN.** `UNIT -only-testing:WaterBuddyTests/PremiumWordsTests -only-testing:WaterBuddyTests/PremiumStringTests -only-testing:WaterBuddyTests/LocalizationTests -only-testing:WaterBuddyTests/PremiumSetTests`
  (log `t6-green`): every test passes.
- [ ] **Step 6:** stage `WaterBuddy/PremiumAccess.swift WaterBuddy/Localizable.xcstrings
  WaterBuddyTests/PremiumAccessTests.swift WaterBuddyTests/LocalizationTests.swift`. Ledger.

---

### Task 7: The paywall, the rim and the card

**Files:**
- Create: `WaterBuddy/PremiumRim.swift`
- Modify: `WaterBuddy/PaywallView.swift` (whole), `WaterBuddy/SettingsView.swift` (the stack, the
  properties, `PremiumCard`), `WaterBuddy/WaterBuddyApp.swift` (one comment)
- Test: `WaterBuddyTests/PremiumAccessTests.swift` (`PaywallScreenTests`),
  `WaterBuddyUITests/PremiumUITests.swift`

**Interfaces — consumes:** Tasks 3–6. **Produces:** `PaywallView.Screen` (`offer`, `thanks`,
`held`); `PaywallView.screen(status:purchase:) -> Screen`; `View.premiumRim()`.

- [ ] **Step 1: The tests.** In `PremiumAccessTests.swift`, after `PaywallOfferTests`:

```swift
/// What the sheet shows, decided off the main actor (plan S8).
struct PaywallScreenTests {

    @Test func aFreeUserIsOffered() {
        #expect(PaywallView.screen(status: .free, purchase: .idle) == .offer)
        #expect(PaywallView.screen(status: nil, purchase: .idle) == .offer)
    }

    @Test func aPurchaseLandingSaysThankYou() {
        #expect(PaywallView.screen(status: .yearly(until: later), purchase: .bought) == .thanks)
    }

    /// Review Focus 1.
    @Test func aRefundAfterAThankYouReturnsTheOffer() {
        #expect(PaywallView.screen(status: .free, purchase: .bought) == .offer)
    }

    /// Review Focus 5.
    @Test func aSubscriberSeesWhatTheyHold() {
        #expect(PaywallView.screen(status: .monthly(until: later), purchase: .idle) == .held)
        #expect(PaywallView.screen(status: .lifetime, purchase: .pending) == .held)
    }
}
```

  And `WaterBuddyUITests/PremiumUITests.swift`'s two tests, replaced:

```swift
    @MainActor
    func testAnOrdinaryRunHasNoPremiumCard() throws {
        let app = XCUIApplication()
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        // The card waits for the first StoreKit read; give it the time it would take to come.
        XCTAssertFalse(app.buttons["See Premium"].waitForExistence(timeout: 3),
                       "the card showed in a run not launched to offer it")
    }

    @MainActor
    func testTheCardLeadsSettingsAndOpensThePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyPremium", "YES"]
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["Settings"].tap()
        let see = app.buttons["See Premium"]
        XCTAssertTrue(see.waitForExistence(timeout: 10), "no Premium card")
        XCTAssertEqual(app.buttons.matching(identifier: "See Premium").count, 1)
        let goal = app.sliders["Daily water goal"]
        XCTAssertTrue(goal.waitForExistence(timeout: 5))
        XCTAssertLessThan(see.frame.minY, goal.frame.minY, "the Premium card is not first")
        tapWhenReady(see)

        XCTAssertTrue(app.staticTexts["See how you really drink, and what would help."].waitForExistence(timeout: 5),
                      "no paywall")
        XCTAssertTrue(app.staticTexts["Logging water is free, always."].exists)
        for title in ["Month view and full history", "Your patterns", "Personal AI insights", "A monthly recap"] {
            let rows = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH %@", title))
            XCTAssertEqual(rows.count, 1, "\(title) is not one element")
        }
        for label in ["Restore Purchases", "Terms of Use", "Privacy Policy", "Not now"] {
            XCTAssertEqual(count(label, in: app), 1, "\(label) is not one element")
        }

        app.buttons["Not now"].tap()
        XCTAssertTrue(see.waitForExistence(timeout: 5), "Not now did not close the paywall")
    }
```

- [ ] **Step 2: A stub**: `PaywallView.Screen` and `screen(status:purchase:)` returning `.offer`;
  nothing else changes yet.
- [ ] **Step 3: RED.** `UNIT -only-testing:WaterBuddyTests/PaywallScreenTests` (log `t7-red-unit`):
  `aPurchaseLandingSaysThankYou` and `aSubscriberSeesWhatTheyHold` fail; the other two pass on
  `.offer` (first seen green, ledgered). Then the UI class on *WaterBuddy Gate 27*:

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO -collect-test-diagnostics never > $W/t7-red-ui.log 2>&1; grep -E "Executed|error: -\[" $W/t7-red-ui.log | tail -6
```

  Expected: `testTheCardLeadsSettingsAndOpensThePaywall` fails — the card is last, or *no paywall*
  (the old sheet has no such line); `testAnOrdinaryRunHasNoPremiumCard` passes (as before).
- [ ] **Step 4: `WaterBuddy/PremiumRim.swift`**:

```swift
//
//  PremiumRim.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import SwiftUI

/// Premium's mark: `Aurora`'s cyan, magenta and blue stroked around a standard pane (spec
/// `2026-10-21-premium-paywall-and-monthly-design.md` §3.5, rule `60-design-system`). The one place
/// the gradient is spelled. The pane under it stays the screen's own glass — the canvas's near-opaque
/// fill is not taken — and the rim is drawn over it, outside the pane's content, so it never changes
/// what a reader sees inside.
struct PremiumRim: ViewModifier {

    /// The canvas's 1.5 pt.
    static let width: CGFloat = 1.5

    func body(content: Content) -> some View {
        content.overlay {
            RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Aurora.cyan, Aurora.magenta, Aurora.blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: Self.width
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }
}

extension View {

    /// Marks a pane as Premium's — only the Settings card carries it (rule `60-design-system`).
    func premiumRim() -> some View {
        modifier(PremiumRim())
    }
}
```

- [ ] **Step 5: `WaterBuddy/PaywallView.swift`**, whole (the switch from Task 4 kept as written):

```swift
//
//  PaywallView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import SwiftUI

/// WaterBuddy Premium's paywall — our own, in the app's glass and the app's language, as the owner
/// approved it on the design canvas (spec `2026-10-21-premium-paywall-and-monthly-design.md` §3.4,
/// amending the foundation's §3.7).
///
/// **Never imports StoreKit.** It reads ``PremiumStore`` from the environment and draws
/// ``PremiumAccess/Plan``s; StoreKit's own views would draw their words in the device's language, not
/// the app's (rule `50-views`, rule `70-privacy`).
///
/// **Offered only when ``isOffered(arguments:)`` says so.** A DEBUG build shows it when launched with
/// ``launchArgument``; a Release build only while a ``PremiumSet`` is on sale and the privacy link is
/// set (§3.6).
///
/// **Opened only by the user** — Settings' *See Premium* today, a later step's locked state
/// tomorrow — never at launch, after a pour or from any other surface (rule `70-privacy`).
struct PaywallView: View {

    /// Where the sheet was opened from — its `.sheet(item:)` selection (rule `50-views`).
    enum Entry: Identifiable, Hashable {
        case settings

        var id: Self { self }
    }

    /// What the sheet shows (plan S8).
    nonisolated enum Screen: Sendable, Equatable {
        /// The plans, to buy — nothing is held, or the first read has not answered yet.
        case offer
        /// The user's own purchase has just landed.
        case thanks
        /// Something is held — bought earlier, restored, or approved by a parent.
        case held
    }

    /// DEBUG's opt-in (rule `85-testing`).
    nonisolated static let launchArgument = "-WaterBuddyPremium"

    /// Apple's standard licence, which an app without its own uses (foundation spec §3.7).
    nonisolated static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")

    /// The owner's privacy policy. App Review asks every app for one inside it (spec §8).
    nonisolated static let privacyPolicy = URL(string: "OWNER-PRIVACY-URL")

    /// The switch, as a pure function of the build, the arguments, the sets on sale and the privacy
    /// link: DEBUG offers it when launched to; Release only while a set is on sale **and** the link
    /// is an `https` address — so a release cannot ship a paywall with a dead privacy link (spec
    /// `2026-10-21-premium-paywall-and-monthly-design.md` §3.6).
    nonisolated static func isOffered(debug: Bool, arguments: [String], setsOnSale: Int, privacyPolicy: URL?) -> Bool {
        debug ? arguments.contains(launchArgument) : setsOnSale > 0 && privacyPolicy?.scheme == "https"
    }

    /// The switch for this build.
    nonisolated static func isOffered(arguments: [String]) -> Bool {
        isOffered(debug: isDebug, arguments: arguments, setsOnSale: PremiumSet.onSale.count, privacyPolicy: privacyPolicy)
    }

    /// Whether this is a DEBUG build.
    nonisolated static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    /// The sets the sheet and the card list: every set in DEBUG, so a set can be seen whole while it
    /// is built; in Release only those on sale.
    nonisolated static func shownSets(debug: Bool) -> [PremiumSet] {
        debug ? PremiumSet.allCases : PremiumSet.onSale
    }

    /// The switch for this process.
    nonisolated static var isOfferedHere: Bool {
        isOffered(arguments: ProcessInfo.processInfo.arguments)
    }

    /// What the sheet shows, from what is held and the last purchase: a refund landing after a
    /// thank-you returns the offer (Review Focus 1), and a subscriber sees what they hold, never the
    /// plans again (Review Focus 5).
    nonisolated static func screen(status: PremiumAccess.Status?, purchase: PremiumStore.Purchase) -> Screen {
        guard let status, status.isPremium else { return .offer }
        return purchase == .bought ? .thanks : .held
    }

    let entry: Entry

    @Environment(PremiumStore.self) private var premium
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var typeSize

    /// The plan picked — the yearly when the sheet opens.
    @State private var chosen: PremiumAccess.Plan.Kind = .yearly

    /// Bumped by a pick, so the selection tick fires on the tap (rule `60-design-system`).
    @State private var picks = 0

    /// Bumped when the user's own purchase lands.
    @State private var purchases = 0

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: PaywallStyle.sectionGap) {
                        topBar
                        preview
                        heading
                        switch Self.screen(status: premium.state.status, purchase: premium.purchase) {
                        case .offer:
                            features
                            offer
                        case .thanks:
                            held(thanks: true)
                        case .held:
                            held(thanks: false)
                        }
                        footer
                    }
                    .padding(.horizontal, PaywallStyle.margin)
                    .padding(.vertical, PaywallStyle.verticalInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        // Never swiped away mid-purchase: StoreKit's own sheet is over it, and the answer lands here.
        // The close button stays, so a purchase that never answers cannot trap the user.
        .interactiveDismissDisabled(premium.purchase == .buying)
        .sensoryFeedback(Haptics.select, trigger: picks)
        .sensoryFeedback(Haptics.confirm, trigger: purchases)
        .animation(Motion.settle, value: premium.plans)
        .animation(Motion.settle, value: premium.purchase)
        .animation(Motion.settle, value: premium.restoring)
        .task { await premium.prepare() }
    }

    // MARK: - The top

    /// The close button — *Not now* to VoiceOver, the welcome's own word for declining — and the
    /// promise on its own capsule (`docs/ROADMAP.md` §1).
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: PaywallStyle.closeSize, height: PaywallStyle.closeSize)
                    .liquidGlass(in: Circle(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(Text("Not now", bundle: strings))

            Spacer(minLength: 0)

            Label {
                Text("Logging water is free, always.", bundle: strings)
            } icon: {
                Image(systemName: "checkmark")
                    .foregroundStyle(Aurora.cyan)
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, PaywallStyle.capsuleInset)
            .padding(.vertical, PaywallStyle.capsuleInset / 2)
            .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting)
        }
    }

    /// Decoration — a month of dots and a day of bars, with no figure, no date and no name. It is not
    /// the user's data and does not pretend to be (spec §3.4, 2).
    private var preview: some View {
        HStack(spacing: PaywallStyle.previewGap) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(PaywallStyle.dot), spacing: PaywallStyle.dotGap), count: 7),
                spacing: PaywallStyle.dotGap
            ) {
                ForEach(0..<35, id: \.self) { day in
                    Circle()
                        .fill(PaywallStyle.quietDays.contains(day) ? .white.opacity(PaywallStyle.restOpacity) : Aurora.cyan)
                        .frame(width: PaywallStyle.dot, height: PaywallStyle.dot)
                }
            }
            .fixedSize()

            HStack(alignment: .bottom, spacing: PaywallStyle.barGap) {
                ForEach(PaywallStyle.bars.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == PaywallStyle.tallestBar ? Aurora.cyan : .white.opacity(PaywallStyle.barOpacity))
                        .frame(height: PaywallStyle.barHeight * PaywallStyle.bars[index])
                }
            }
            .frame(maxWidth: .infinity, maxHeight: PaywallStyle.barHeight, alignment: .bottom)
        }
        .padding(PaywallStyle.previewInset)
        .frame(maxWidth: .infinity)
        .liquidGlass(density: .frosted, elevation: .resting)
        .accessibilityHidden(true)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("WaterBuddy Premium", bundle: strings)
                .font(.largeTitle.weight(.heavy))
                .foregroundStyle(.white)
                .accessibilityAddTraits(.isHeader)
            Text("See how you really drink, and what would help.", bundle: strings)
                .font(.body)
                .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - The set

    /// One row per feature of the sets shown (``shownSets(debug:)``), then the promise that later
    /// features come included.
    private var features: some View {
        VStack(alignment: .leading, spacing: PaywallStyle.rowGap) {
            ForEach(Self.shownSets(debug: Self.isDebug).flatMap(\.features), id: \.self) { feature in
                featureRow(feature)
            }
            Text("New Premium features arrive in updates, included.", bundle: strings)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// A glyph, a title and one line — one element to VoiceOver.
    private func featureRow(_ feature: PremiumSet.Feature) -> some View {
        HStack(spacing: 14) {
            Image(systemName: feature.symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(Self.tint(feature))
                .frame(width: PaywallStyle.glyphTile, height: PaywallStyle.glyphTile)
                .liquidGlass(
                    in: RoundedRectangle(cornerRadius: LiquidGlass.innerCornerRadius, style: .continuous),
                    density: .sheer,
                    elevation: .flush
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title(in: strings))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                Text(feature.line(in: strings))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    /// Each feature's glyph colour, from `Aurora` (rule `60-design-system`).
    private static func tint(_ feature: PremiumSet.Feature) -> Color {
        switch feature {
        case .monthView: Aurora.cyan
        case .patterns: Aurora.blue
        case .insights: Aurora.magenta
        case .recap: .white
        }
    }

    // MARK: - The offer

    @ViewBuilder
    private var offer: some View {
        switch premium.plans {
        case .notLoaded, .loading:
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
        case .unavailable:
            unavailable
        case .loaded(let plans):
            planTiles(plans)
            if let plan = plans.first(where: { $0.kind == chosen }) {
                outcome
                buyButton(plan)
                Text(plan.terms(in: strings, locale: locale))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(PaywallStyle.footnoteOpacity))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var unavailable: some View {
        VStack(spacing: 14) {
            Text("The App Store can't be reached right now.", bundle: strings)
                .font(.body)
                .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await premium.loadPlans() }
            } label: {
                Text("Try Again", bundle: strings)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, PaywallStyle.capsuleInset * 1.7)
                    .frame(minHeight: PaywallStyle.linkHeight)
                    .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
        }
        .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
    }

    /// The three plans side by side — in a column at the accessibility text sizes, where three
    /// abreast would squeeze a price (rule `65-accessibility`, plan S2).
    private func planTiles(_ plans: [PremiumAccess.Plan]) -> some View {
        let saving = PremiumAccess.yearlySaving(among: plans)
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: PaywallStyle.tileGap + PaywallStyle.badgeLift))
            : AnyLayout(HStackLayout(alignment: .top, spacing: PaywallStyle.tileGap))
        return layout {
            ForEach(plans) { plan in
                planTile(plan, saving: saving)
            }
        }
        .padding(.top, PaywallStyle.badgeLift)
        .glassGroup()
    }

    /// One plan: its name, its price — the largest figure — its period and its note; one button whose
    /// label is the name and whose value is the full price line, the selected trait on the one picked
    /// (rule `65-accessibility`).
    private func planTile(_ plan: PremiumAccess.Plan, saving: Double?) -> some View {
        let isSelected = plan.kind == chosen
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)

        return Button {
            guard !isSelected else { return }
            chosen = plan.kind
            picks += 1
        } label: {
            VStack(alignment: .leading, spacing: 3) {
                Text(plan.name(in: strings))
                    .font(.subheadline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(plan.price)
                    .font(.title2.weight(.heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(plan.period(in: strings, locale: locale, saving: saving))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                if let note = plan.note(in: strings, locale: locale) {
                    Text(note)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(plan.kind == .yearly ? Aurora.cyan : .white.opacity(PaywallStyle.textOpacity))
                }
            }
            .foregroundStyle(.white)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, PaywallStyle.tileInset)
            .padding(.top, PaywallStyle.tileTop)
            .padding(.bottom, PaywallStyle.tileInset)
            .frame(maxWidth: .infinity, minHeight: PaywallStyle.tileHeight, alignment: .topLeading)
            .background { selectionMark(isSelected, in: shape) }
            .liquidGlass(in: shape, density: .frosted, elevation: .resting, interactive: true)
            .overlay(alignment: .top) {
                if plan.kind == .yearly {
                    badge.alignmentGuide(.top) { $0[VerticalAlignment.center] }
                }
            }
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(plan.name(in: strings))
        .accessibilityValue(plan.priceLine(in: strings, locale: locale))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// The yearly's mark — cyan words on opaque glass (plan S3): not a fill of its own, and not the
    /// primary surface, which is the button's.
    private var badge: some View {
        Text("Best value", bundle: strings)
            .font(.caption2.weight(.heavy))
            .textCase(.uppercase)
            .foregroundStyle(Aurora.cyan)
            .lineLimit(1)
            .padding(.horizontal, PaywallStyle.capsuleInset * 0.65)
            .padding(.vertical, PaywallStyle.capsuleInset * 0.3)
            .liquidGlass(in: Capsule(), density: .opaque, elevation: .resting)
            .accessibilityHidden(true)
    }

    /// What became of the last purchase, when there is something to say. A purchase that landed is
    /// the thank-you screen's, never a line here (Review Focus 1).
    @ViewBuilder
    private var outcome: some View {
        switch premium.purchase {
        case .pending: note("Waiting for approval.")
        case .failed: note("The purchase didn't go through.")
        case .idle, .buying, .bought: EmptyView()
        }
    }

    private func note(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    /// The screen's one primary surface (rule `60-design-system`). It does not close the sheet: the
    /// thank-you does, on the user's own *Done* (the final review's minors 1 and 2).
    private func buyButton(_ plan: PremiumAccess.Plan) -> some View {
        Button {
            Task {
                await premium.buy(plan)
                if premium.purchase == .bought { purchases += 1 }
            }
        } label: {
            ZStack {
                Text(plan.action(in: strings))
                    .opacity(premium.purchase == .buying ? 0 : 1)
                ProgressView()
                    .opacity(premium.purchase == .buying ? 1 : 0)
            }
            .font(.body.weight(.bold))
            .frame(maxWidth: .infinity, minHeight: PaywallStyle.buttonHeight)
            .primarySurface(in: Capsule())
        }
        .buttonStyle(PressStyle())
        .disabled(premium.purchase == .buying)
        .accessibilityLabel(plan.action(in: strings))
    }

    // MARK: - Held

    /// *Thank you* after the user's own purchase, *You have Premium.* otherwise; the plan's line;
    /// *Done* on the primary surface.
    private func held(thanks: Bool) -> some View {
        VStack(spacing: 14) {
            VStack(spacing: 6) {
                if thanks {
                    Text("Thank you", bundle: strings)
                        .font(.title2.weight(.bold))
                } else {
                    Text("You have Premium.", bundle: strings)
                        .font(.title2.weight(.bold))
                }
                if let line = premium.state.status?.line(in: strings, locale: locale, now: premium.now()) {
                    Text(line)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                }
            }
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .combine)

            Button {
                dismiss()
            } label: {
                Text("Done", bundle: strings)
                    .font(.body.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: PaywallStyle.buttonHeight)
                    .primarySurface(in: Capsule())
            }
            .buttonStyle(PressStyle())
        }
        .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
    }

    // MARK: - Footer

    /// What a restore found, then *Restore Purchases* while nothing is held and the two links — in a
    /// row where they fit, a column where they do not (rule `50-views`).
    private var footer: some View {
        VStack(spacing: 6) {
            if premium.restoring == .nothingFound {
                Text("No purchases to restore.", bundle: strings)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 16) { footerLinks }
                    .fixedSize()
                VStack(spacing: 0) { footerLinks }
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var footerLinks: some View {
        if premium.state.status?.isPremium != true {
            Button {
                Task { await premium.restore() }
            } label: {
                ZStack {
                    footerLabel("Restore Purchases")
                        .opacity(premium.restoring == .restoring ? 0 : 1)
                    ProgressView()
                        .tint(.white)
                        .opacity(premium.restoring == .restoring ? 1 : 0)
                }
            }
            .buttonStyle(PressStyle())
            .disabled(premium.restoring == .restoring)
        }
        if let terms = Self.termsOfUse {
            Link(destination: terms) { footerLabel("Terms of Use") }
        }
        if let privacy = Self.privacyPolicy {
            Link(destination: privacy) { footerLabel("Privacy Policy") }
        }
    }

    private func footerLabel(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            .multilineTextAlignment(.center)
            .frame(minHeight: PaywallStyle.linkHeight)
            .contentShape(Rectangle())
    }

    /// ``LiquidGlass/Selection``'s fill and rim, present at nothing when not picked
    /// (rule `60-design-system`) — the welcome's own mark.
    private func selectionMark<S: InsettableShape>(_ isSelected: Bool, in shape: S) -> some View {
        shape
            .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
            .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            .scaleEffect(isSelected ? 1 : 0.9)
            .animation(Motion.land, value: isSelected)
    }
}

/// The paywall's measures. The two text opacities are the welcome's, measured on the same aurora, and
/// are measured again on this sheet before they are recorded (Task 8, `docs/DESIGN.md`).
private enum PaywallStyle {
    static let margin: CGFloat = 20
    static let verticalInset: CGFloat = 12
    static let sectionGap: CGFloat = 18
    static let rowGap: CGFloat = 12
    /// The 44 floor (rule `65-accessibility`).
    static let closeSize: CGFloat = 44
    static let capsuleInset: CGFloat = 14
    static let glyphTile: CGFloat = 40
    static let previewGap: CGFloat = 20
    static let previewInset: CGFloat = 16
    static let dot: CGFloat = 14
    static let dotGap: CGFloat = 6
    static let barGap: CGFloat = 4
    static let barHeight: CGFloat = 34
    /// The preview's bars, as fractions of its height — fixed, no one's own hours.
    static let bars: [CGFloat] = [0.3, 0.55, 0.45, 1, 0.6, 0.35, 0.48, 0.2]
    static let tallestBar = 3
    /// The preview's quiet days — fixed, so it never reads as anyone's own month.
    static let quietDays: Set<Int> = [2, 9, 15, 23, 24, 30, 31, 32, 33, 34]
    static let restOpacity = 0.22
    static let barOpacity = 0.6
    static let tileGap: CGFloat = 10
    static let tileInset: CGFloat = 12
    static let tileTop: CGFloat = 18
    /// Four lines of type at the ordinary sizes, past the 44 floor.
    static let tileHeight: CGFloat = 124
    /// Half the *Best value* badge's height, which stands across the yearly tile's top edge.
    static let badgeLift: CGFloat = 11
    /// The primary buttons' 56 (rule `65-accessibility`).
    static let buttonHeight: CGFloat = 56
    /// The 44 floor.
    static let linkHeight: CGFloat = 44
    /// Where the plans stand while they load, or when they cannot.
    static let quietHeight: CGFloat = 150
    static let textOpacity = 0.92
    static let footnoteOpacity = 0.88
}

#Preview {
    PaywallView(entry: .settings)
        .environment(PremiumStore(source: .silent()))
}
```

- [ ] **Step 6: `WaterBuddy/SettingsView.swift`.**
  - after `@State private var paywall: PaywallView.Entry?`:

```swift
    /// Premium's card shows where the paywall is offered, once the first read has answered — so a
    /// paying user never sees the free card flash (plan S13).
    private var showsPremium: Bool {
        PaywallView.isOfferedHere && premium.state != .checking
    }

    /// The other cards' arrival order starts after Premium's when it is drawn (``Arrival``).
    private var lead: Int {
        showsPremium ? 1 : 0
    }
```

  - the stack, from `// The goal leads:` to the closing brace of the Premium `if`, becomes:

```swift
                    // Premium leads where it is offered — the owner's ruling (spec
                    // `2026-10-21-premium-paywall-and-monthly-design.md` §3.5), which reverses *the
                    // goal leads*.
                    if showsPremium {
                        PremiumCard { paywall = .settings }
                            .arrives(arrived, order: 0)
                            .scrollDepth()
                    }
                    // Then the goal: it is the number the whole product is measured against, and
                    // reminders are a preference about it.
                    GoalCard(currentGoal: manager.dailyGoal).arrives(arrived, order: lead).scrollDepth()
                    ServingsCard(current: manager.servings).arrives(arrived, order: lead + 1).scrollDepth()
                    remindersCard.arrives(arrived, order: lead + 2).scrollDepth()
                    LanguageCard().arrives(arrived, order: lead + 3).scrollDepth()
```

  - the bottom-padding comment's first lines → "The language card is the tallest on this screen
    and sits last, so without this its footnote rests under the floating tab bar at the
    un-scrolled position." (its wording before the foundation's Task 6);
  - `PremiumCard`, whole, replacing the staged one:

```swift
// MARK: - Premium

/// Premium's card, first on the screen where the paywall is offered (spec
/// `2026-10-21-premium-paywall-and-monthly-design.md` §3.5). While nothing is held: what Premium adds
/// and the way in, on the screen's one primary surface, with Premium's rim. Once something is: the
/// plan held, and Apple's manage sheet for a subscription.
private struct PremiumCard: View {

    @Environment(PremiumStore.self) private var premium
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// Opens the paywall.
    let open: () -> Void

    var body: some View {
        if let status = premium.state.status, status.isPremium {
            held(status)
        } else {
            offer
        }
    }

    private var offer: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Aurora.cyan)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("WaterBuddy Premium", bundle: strings)
                        .cardTitle()
                    Text("Extras for the way you drink. Logging water stays free.", bundle: strings)
                        .cardNote()
                }
            }
            previews
            Button(action: open) {
                Text("See Premium", bundle: strings)
                    .font(.body.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: PremiumCardStyle.buttonHeight)
                    .primarySurface(in: Capsule())
            }
            .buttonStyle(PressStyle())
        }
        // `.frosted` and `.raised`, matching every sibling on this screen, and Premium's rim.
        .settingsCard()
        .premiumRim()
    }

    /// What the sets add, as a glyph over a caption — decoration, with no pane of its own (plan S7);
    /// the paywall names each in full.
    private var previews: some View {
        HStack(alignment: .top, spacing: 10) {
            ForEach(PaywallView.shownSets(debug: PaywallView.isDebug).flatMap(\.features), id: \.self) { feature in
                if let caption = feature.caption(in: strings) {
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: feature.symbol)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Aurora.cyan)
                        Text(caption)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func held(_ status: PremiumAccess.Status) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("You have Premium.", bundle: strings)
                .cardTitle()
                .padding(.bottom, 6)
            if let line = status.line(in: strings, locale: locale, now: premium.now()) {
                Text(line)
                    .cardNote()
            }
            // Apple's sheet manages a subscription — beside a lifetime purchase too — and is not
            // offered where it does not work (the final review's minors 3 and 6).
            if premium.holdsSubscription, premium.canManage {
                cardButton("Manage Subscription") {
                    Task { await premium.manage() }
                }
            }
        }
        // `.frosted` and `.raised`, matching every sibling on this screen.
        .settingsCard()
    }

    /// The reminders card's capsule — glass: managing is not the screen's main action.
    private func cardButton(_ key: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(key, bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        .padding(.top, 12)
    }
}

/// The card's own measure.
private enum PremiumCardStyle {
    /// The primary buttons' 56 (rule `65-accessibility`).
    static let buttonHeight: CGFloat = 56
}
```

  - `WaterBuddy/WaterBuddyApp.swift`: "Built before anything else, fresh start included," →
    "Built right after the App Group is resolved, before anything draws — fresh start included —"
    (the final review's minor 10).
- [ ] **Step 7: GREEN.** `UNIT -only-testing:WaterBuddyTests/PaywallScreenTests -only-testing:WaterBuddyTests/PaywallOfferTests`
  (log `t7-green-unit`): `PaywallScreenTests` 4 passed; `PaywallOfferTests` as in Task 4. The UI class
  again (Step 3's command, log `t7-green-ui`): `Executed 2 tests, with 0 failures`. Then the whole
  unit suite once — `UNIT -only-testing:WaterBuddyTests` (log `t7-unit-all`): the attribute grep's
  count, every test passed but `theLinksAreApplesTermsAndAPageOfOurs` (the URL) and
  `anExpiredYearlyReadsFree` skipped. No warning names a file this task touched.
- [ ] **Step 8:** stage `WaterBuddy/PremiumRim.swift WaterBuddy/PaywallView.swift
  WaterBuddy/SettingsView.swift WaterBuddy/WaterBuddyApp.swift WaterBuddyTests/PremiumAccessTests.swift
  WaterBuddyUITests/PremiumUITests.swift`. Ledger.

---

### Task 8: By hand, with the owner

**Files:** none in the tree; `$SCRATCH/shots/*`; measurements for `docs/DESIGN.md` (written in Task 10).

- [ ] **Step 1:** The owner runs the `WaterBuddy` scheme from Xcode with ⌘R — on their iPhone or on
  *WaterBuddy Probe 27* — with `-WaterBuddyPremium YES` under **Arguments Passed On Launch** and the
  local StoreKit configuration (both already in the scheme from 2026-10-21). On the iPhone the
  session captures with `xcrun devicectl device capture screenshot --device <udid> --destination
  "$SCRATCH/shots/<n>.png"` **only after the owner says "done"**; on the simulator with
  `xcrun simctl io 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA screenshot`. Each shot is read before the
  next step.
- [ ] **Step 2: The walk**, one capture each:
  1. Settings: the Premium card first, its rim, three previews, *See Premium*.
  2. The paywall in English: the close button, the promise, the preview, the title, four feature
     rows, the three tiles (yearly selected, *Best value*, *a year · save 44%*, *1 week free*),
     *Start Free Trial*, the terms, the footer.
  3. Monthly picked: *Subscribe* and the monthly terms; Lifetime picked: *Buy Lifetime*.
  4. The yearly bought → *Thank you*, the plan's line, *Done*; the sheet stays until *Done*; the card
     then reads *You have Premium.*, *Yearly, until …*, *Manage Subscription*.
  5. Xcode's transaction manager: refund it → back in the app, the card is free again.
  6. The monthly bought, then the yearly from *Manage Subscription*'s sheet or a second purchase →
     the card reads *Yearly*.
  7. Ask to Buy on, *Buy Lifetime* → *Waiting for approval.*; approved with the sheet open → it turns
     to *You have Premium.*
  8. Transactions deleted; *Restore Purchases* → its progress, then *No purchases to restore.*
  9. Russian, then Uzbek (Settings → Language): the sheet and the card — the saving in each
     language's own percent, the free week in its own words, no English.
  10. VoiceOver: each tile one element (name, price line, *Selected* on one); the close button
      *Not now*; the feature rows one element each.
  11. Larger Text at the largest accessibility size: the tiles in a column, the footer in a column,
      nothing cut; Reduce Transparency: the panes opaque, the rim still drawn.
- [ ] **Step 3: Measure the colour pairs** off step 2's shots (a device shot converted to sRGB first:
  `sips --matchTo '/System/Library/ColorSync/Profiles/sRGB Profile.icc' in.png --out out.png`), by
  the method `docs/DESIGN.md`'s *Settings, measured* records, at the aurora's brightest frame: the
  tile lines (white 0.92 on the tile), the yearly note (`Aurora.cyan` on the tile), the badge
  (`Aurora.cyan` on opaque glass), the feature lines (white 0.92 on the aurora), the terms (white
  0.88), the footer (white 0.92), the card's note and captions. Every text pair holds 4.5:1, every
  glyph 3:1. One that does not is raised to the lowest value that passes, measured again, and its
  constant's comment updated — never a figure estimated from another.

---

### Task 9: The review, the gate, the warnings

- [ ] **Step 1: The scheme**, Xcode closed: read
  `git diff -- WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme`; with `Edit`, remove
  the `<CommandLineArguments>` block and the `<EnvironmentVariables>` block, keeping
  `<StoreKitConfigurationFileReference identifier = "../../WaterBuddyTests/WaterBuddy.storekit">`;
  stage that file alone. `git diff --stat` over the tree: anything Xcode rewrote beyond #50's four
  is read and, with the owner's word, restored from the index.
- [ ] **Step 2: A fresh reviewer**, read-only, on the most capable model, over a package of
  `git diff --cached -U10 b981374` (code, tests, rules, the scheme), the spec, this plan, its ledger's
  `Ruling:` lines and this plan's *Review Focus*; it also confirms `StoreKit` in two files, nothing
  written to any `UserDefaults`, the paywall opened from Settings alone, and no `#available`. Save its
  report beside the ledger; check every finding against the code; fix Critical and Important ones
  test-first in the owning task; ledger minors.
- [ ] **Step 3: The gate** — rule `85-testing`'s invocations, `uptime` before each, by UDID between
  systems:
  1. Unit, *iPhone 17*: `-only-testing:WaterBuddyTests` — the attribute grep's count (**764** by this
     plan), every one passed but the URL test, one skipped (#157).
  2. UI, *WaterBuddy Gate 27*, in three runs under 600 s — `GoalSetupUITests` in two halves, then the
     rest — the foundation plan's Task 8 commands; together **71** executed, 1 skipped.
  3. The same three on *WaterBuddy Gate 26.5*.
  4. Watch, *WaterBuddy Watch 27*: 70.
  5. `WaterBuddyWidgetExtension` and 6. `WaterBuddyWatchWidget` builds — `** BUILD SUCCEEDED **`.
  A UI failure in `WelcomeUITests.testUseComesBackWhenTheGoalIsMovedAway` (#140) is re-run alone,
  interleaved with the `HEAD` export, before it is called the flake.
- [ ] **Step 4: The warning comparison** from the staged index (`git checkout-index -a
  --prefix="$SCRATCH/after/"`), the four schemes into one empty DerivedData, compared with Task 0's
  files. Expected: every `new:` list empty.

---

### Task 10: Records, docs — then stop

- [ ] `docs/AI_CONTEXT.md`: a *Current state* block for this step and the foundation's close (its Task
  6 rewritten here); *Files on disk* rows by `wc -l` (`PremiumRim.swift`, `PremiumSetTests.swift`
  new; the changed ones); the gate and the warnings; known issues — the monthly product joins #155;
  #159 (the privacy URL) and the `StoreKitTest` header line stay open; the grace ruling recorded; and
  "Apple Intelligence" wording to be checked before set A goes on sale (step 4).
- [ ] `docs/STATE.md`: a dated note — still no key; the paid state read, never stored; the store
  holds three products.
- [ ] `docs/DESIGN.md`: Task 8's measured pairs, each with its figure; `.premiumRim()`'s three
  colours.
- [ ] `docs/WIDGET.md`: checked — no shared file changed in this step (`DataManager.swift` untouched
  since the foundation's comment).
- [ ] `docs/ROADMAP.md` §1: *Pricing is yearly plus lifetime; no weekly plans* → *Pricing is
  monthly, yearly and lifetime — a free week on the yearly alone; no weekly plans* (the owner's,
  2026-10-21); §5: set A's AI insights item and the five steps; 1.4.1's line: step 1 built, gated and
  staged.
- [ ] `CLAUDE.md`: the warning trail gains this step's measurement as `docs/AI_CONTEXT.md` gives it.
- [ ] `HISTORY.md` appended with `Edit`, anchored on its last lines; `tasks/lessons.md` if the work
  earned a lesson (the unasked device screenshot is one).
- [ ] Before the records are final, search every sheet for "monthly", "Premium", "paywall",
  "grace", "two products" and check every `File.swift:N` cited against the tree.
- [ ] Stage by explicit path: the code and tests of Tasks 3–7, the scheme, the plan, the spec,
  `CLAUDE.md`, the five docs, `HISTORY.md` (and `tasks/lessons.md`). The rule files stay unstaged.
  Write the git block last, from `git status --short` and `git diff --cached --name-status` run then.
- [ ] **Stop.** Report: what was built and that no user meets it until step 5; the probe's answers;
  the walk with its shots; the gate's counts and the warnings; the rule wording waiting; the commit
  order — the spec and this plan as `docs`; the code as `feat(app)`; the records as `docs`; the rules
  as `chore(claude)`.
