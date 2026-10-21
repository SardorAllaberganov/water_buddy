# Premium's Foundation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent. Steps use checkbox (`- [ ]`) syntax. **No step
> commits:** code is staged by explicit path in Task 7, everything else in Task 9, and nothing is
> committed until the owner runs `/commit`.

**Goal:** Two StoreKit products, a purchase, a restore and a paid state read from StoreKit, with a
paywall in the app's own glass and language — all hidden in a Release build until the first Premium
set exists.

**Architecture:** A pure `PremiumAccess` (Foundation only, `nonisolated`) decides what is held from
plain facts and words every price line. An app-only `@MainActor @Observable PremiumStore` — the one
new file that imports StoreKit — reads StoreKit through `PremiumStore.Source`, a struct of closures,
and keeps the answer in memory only. `PaywallView` (a sheet) and a fifth Settings card read the
store from the environment; `PaywallView.isOffered(arguments:)` keeps both hidden unless a DEBUG
build is launched with `-WaterBuddyPremium` or `PremiumSet` has a case.

**Tech Stack:** Swift (language mode 5; the app target defaults to main-actor isolation, with
approachable concurrency), SwiftUI, StoreKit 2, StoreKitTest, swift-testing, XCTest, Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-21-premium-foundation-design.md` (approved 2026-10-21,
"ok"). Roadmap item **1.4.1**.

**Ledger:** `.superpowers/sdd/2026-10-21-premium-foundation/progress.md` (git-ignored).

## Decisions this plan takes

- **P1 — the purchase call is `purchase(confirmIn: some UIScene, options:)`.** Measured in the iOS
  27.0 simulator SDK's `StoreKit.swiftinterface`: `@available(iOS 17.0, …)`, `@MainActor`, not
  deprecated. [PO] states Apple recommends it for UIKit over `purchase(options:)`; `PurchaseAction`,
  its SwiftUI recommendation, would put `StoreKit` into a view. Settles spec §9's first unknown.
- **P2 — `PremiumStore.Source` is main-actor, unlike `ReminderScheduler`.** Its closures are called
  only by `PremiumStore`, on the main actor; `purchase(confirmIn:)` and
  `showManageSubscriptions(in:)` are `@MainActor` themselves, and so is `UIApplication`. The value
  enums the store publishes (`State`, `Plans`, `Purchase`, `Outcome`) are `nonisolated` and
  `Sendable`, so their `Equatable` is never an isolated conformance.
- **P3 — the trial's length is Foundation's words, not ours.** `DateComponentsFormatter`, `.full`,
  one unit, its calendar's locale set to the app's: *1 week*, *1 неделя*, *1 hafta*. No catalogue key
  counts a noun for it, so a trial changed in App Store Connect cannot outrun the plural forms.
  **Task 1 probes it in all three languages first; if any language is not in its own words, stop and
  re-plan with the owner** (the fallback is a plural key per unit).
- **P4 — the buttons name no length:** *Start Free Trial*, *Subscribe*, *Buy Lifetime*. *Try 1 Week
  Free* (spec §3.7) would need *1 неделю* in Russian — the accusative — and a formatter gives the
  nominative. The length is drawn where the nominative reads: *1 неделя бесплатно, затем …* and
  *Пробный период: 1 неделя.*
- **P5 — the yearly's subscription period is not read.** The product is yearly by its identifier;
  the local configuration's `P1Y` is pinned by a test, and App Store Connect's by the owner (spec
  §7.4). `Plan` carries no period, and the price line says *a year*.
- **P6 — the sets section is not written in 1.4.1.** `PremiumSet` has no case, and a `switch` over
  none draws nothing; the first set writes the section with its first row.
- **P7 — the plans are *loaded* only when both products return.** Anything less is *unavailable* —
  never an empty or a half paywall.
- **P8 — the owner sets the scheme's StoreKit configuration in Xcode** (Edit Scheme → Run → Options →
  StoreKit Configuration), because the path format the scheme file stores is unconfirmed and a wrong
  one fails silently. The session reads the diff and stages that hunk alone. Xcode is closed while
  any catalogue is edited (`tasks/lessons.md`, 2026-10-18).
- **P9 — the paywall offers *Not now*** — the welcome's existing key — so it closes without the drag,
  for VoiceOver and Switch Control.
- **P10 — every sentence the paywall draws is a `nonisolated` function on `PremiumAccess`** taking the
  strings bundle and the locale — `Plan.name`, `Plan.priceLine`, `Plan.terms`, `Plan.action`,
  `Status.line` — so a suite off the main actor reads every sentence in every language off the built
  bundle (`tasks/lessons.md`, 2026-10-16: test plural forms by formatting sentences).
- **P11 — "the yearly's trial only when eligible" is tested through the live `Source`**
  (`aTrialUsedOnceIsNotOfferedAgain`), where eligibility is StoreKit's answer, not a fake's.
- **P12 — previews inject `PremiumStore(source: .silent())`**, a `Source` that answers nothing and
  reaches no store, so a canvas never reads StoreKit.
- **P13 — the paywall's text opacities start at the welcome's measured `0.92` and `0.88`**, on the
  same aurora, and are measured on the sheet itself in Task 7 before they are recorded.

## Global Constraints

- iOS floor **17.0**, no `#available`: every StoreKit call used is available by 17.0 (measured —
  `products(for:)`, `Transaction.updates`, `currentEntitlements`, `finish()`, `AppStore.sync()`,
  `showManageSubscriptions(in:)`, `isEligibleForIntroOffer` at 15.0; `purchase(confirmIn:)` at 17.0).
- **`StoreKit` is imported by `WaterBuddy/HomeView.swift` and `WaterBuddy/PremiumStore.swift` only.**
  `StoreKitTest` by `WaterBuddyTests/PremiumStoreTests.swift` only. Never `DataManager.swift`, never a
  view, never under `WaterBuddyWidget/`, `WaterBuddyWatch/` or `WaterBuddyWatchWidget/`.
- Product IDs, spelled once in `PremiumAccess`: `sardor.WaterBuddy.premium.yearly` and
  `sardor.WaterBuddy.premium.lifetime`.
- **Nothing stored:** no new `DataManager.Key`, no `UserDefaults` read or write, no App Group write.
  No exception set change, no `project.pbxproj` change, no entitlement, no Info.plist key, no privacy
  manifest change.
- `PaywallView.launchArgument == "-WaterBuddyPremium"`. `PremiumSet` has **no case**.
- Terms of Use: `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`. Privacy Policy:
  the owner's URL, asked for at the start of Task 6.
- Tests come first: write, run, **see RED**, implement, run GREEN. RED by a stub, never by a compile
  failure. Never narrow an assertion.
- **No new warning** against Task 0's clean baselines of HEAD `0be24f9`, all four schemes, compared
  per file and message.
- Edit with `Edit`/`Write` only: no `sed -i`, no heredoc or script into the tree. Scratch work goes in
  this session's scratchpad (`$SCRATCH`).
- Simulators:
  - Unit tests and the probe run on the stock iOS 27.0 *iPhone 17*.
  - UI tests run on *WaterBuddy Gate 27* and *WaterBuddy Gate 26.5*.
  - The by-hand checks run on *WaterBuddy Probe 27* (`43E0B902-C6D5-48DD-B513-F22AF3BE9BEA`).
  - Watch tests run on *WaterBuddy Watch 27*.
  - `uptime` before each run; if the 1-minute load is above 6, wait. Shut down **by UDID** between
    systems. Every test run takes `-parallel-testing-enabled NO` and `-collect-test-diagnostics
    never`, in the foreground. No UI run may cross midnight.
- Never write the real App Group suite or `UserDefaults.standard` from a test or a script.
- Never commit. Stage explicit paths. The seven rule files stay unstaged for the owner.

## Review Focus

Five inputs a person will meet that the spec's tests do not reach as written. Each is pinned by the
test named here, in the task that owns it.

1. **The buy button pressed twice** while StoreKit's sheet is coming up. One purchase, never two. →
   `aSecondTapWhileBuyingBuysNothing` (Task 4).
2. **An Ask to Buy approved while the paywall is still open.** The sheet turns to *You have Premium*.
   → `anApprovalArrivingAsAnUpdateReadsPremium` (Task 4), and seen by hand (Task 7).
3. **The paywall opened again after a failed or cancelled purchase.** It opens clean, not on *The
   purchase didn't go through*. → `openingTheSheetAgainForgetsTheLastFailure` (Task 4).
4. **One product missing** — not yet in App Store Connect, or not sold in this storefront. Never a
   half paywall. → `oneProductMissingIsUnavailable` (Task 4).
5. **A subscription period ending while the app runs** — a year turning over with the app open. Free
   on the next read. → `anExpiryPassingWhileTheAppRunsReadsFreeOnTheNextRead` (Task 3) and
   `anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead` (Task 4).

## File structure

| File | Target | Change |
|---|---|---|
| `WaterBuddy/PremiumAccess.swift` | app — **new** | IDs, `Entitlement`, `Status`, `resolve`, `Plan`, `Period`; the words (P10) |
| `WaterBuddy/PremiumSet.swift` | app — **new** | the empty `nonisolated enum PremiumSet: CaseIterable, Sendable` |
| `WaterBuddy/PremiumStore.swift` | app — **new** | the store, `Source`, `live()`, `silent()`; `import StoreKit` |
| `WaterBuddy/PaywallView.swift` | app — **new** | the sheet; `Entry`; `isOffered`; the two links |
| `WaterBuddy/WaterBuddyApp.swift` | app | builds the store first, injects it, reads it on `.active` |
| `WaterBuddy/SettingsView.swift` | app | `PremiumCard`; the sheet; the preview's store |
| `WaterBuddy/RootTabView.swift` | app | the preview's store |
| `WaterBuddy/Localizable.xcstrings` | app | 27 keys (Task 5) |
| `WaterBuddy/HomeView.swift` | app | DocC: one use of two |
| `WaterBuddy/DataManager.swift` | all four | DocC: one use of two |
| `WaterBuddyTests/WaterBuddy.storekit` | tests — **new** | the local configuration |
| `WaterBuddyTests/PremiumAccessTests.swift` | tests — **new** | `PremiumAccessTests` (14), `PremiumWordsTests` (5), `PaywallOfferTests` (4) |
| `WaterBuddyTests/PremiumStoreTests.swift` | tests — **new** | `PremiumStoreTests` (18), `StoreKitSessionTests` (8) |
| `WaterBuddyTests/LocalizationTests.swift` | tests | `premiumKeys`, `PremiumStringTests` (1) |
| `WaterBuddyUITests/PremiumUITests.swift` | UI tests — **new** | 2 tests |
| `WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme` | — | the Run action's StoreKit configuration (P8) |
| `.claude/rules/70-privacy.md`, `10-architecture.md`, `15-project.md`, `43-concurrency.md`, `85-testing.md`, `50-views.md`, `65-accessibility.md`, `CLAUDE.md` | — | spec §5's wording, **typed and unstaged** (Task 2) |
| the spec | — | amended for P1, P3–P6, P11 (Task 0) |
| `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/DESIGN.md`, `docs/WIDGET.md`, `docs/ROADMAP.md`, `HISTORY.md` (and `tasks/lessons.md` if earned) | — | records (Task 9) |

Expected counts after the work, read by the attribute grep, not trusted from here: unit `@Test`
683 + 50 = **733**; watch 70, unchanged; UI `func test` 56 + 2 = **58**.

## Commands used below

`$SCRATCH` is this session's scratchpad directory. Shorthand, expanded where a step runs it:

```bash
# UNIT <filters>: swift-testing on the stock iOS 27.0 iPhone 17
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' <-only-testing:…> -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘|error:" | tail -40
```

Read a run's **executed** count, never its last line alone.

---

### Task 0: The ledger, the baselines, the spec's amendments

**Files:** the ledger; the spec; scratch.

- [ ] **Step 1: The starting state.** `git status --short` and `git diff --cached --name-status`.
  Expect staged: `docs/ROADMAP.md` (M), the spec (A) and this plan (A); unstaged:
  `.claude/settings.json` and Xcode's four rewrites (#50) — the `WaterBuddyWatch` and
  `WaterBuddyWatchWidget` schemes, `WaterBuddy/AppShortcuts.xcstrings`,
  `WaterBuddyWatch/Localizable.xcstrings`; untracked `Screenshots/census/`. Write them into the
  ledger as the starting state, with P1–P13.
- [ ] **Step 2: The warnings baselines** — clean builds of a `HEAD` export, all four schemes, into
  one empty DerivedData folder:

```bash
mkdir -p "$SCRATCH/base" && git archive HEAD | tar -x -C "$SCRATCH/base"
xcodebuild build-for-testing -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-widget.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-watch.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/base/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/base-dd" > "$SCRATCH/base-watchwidget.log" 2>&1; echo "exit $?"
for s in app widget watch watchwidget; do grep -E '^/.*: warning: ' "$SCRATCH/base-$s.log" | sed -E 's#^.*/base/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/base-$s-messages.txt"; echo "$s $(wc -l < "$SCRATCH/base-$s-messages.txt")"; done
```

  Expect all four to exit 0. `CLAUDE.md` records 35 unique primary lines for `-scheme WaterBuddy`
  with the tests, 2 for the watch, 29 for each widget scheme; the message counts here are by file and
  message. Record what comes, as it comes — a different figure is recorded, not reconciled.

- [ ] **Step 3: Amend the spec**, with `Edit`, each change naming its decision:
  - *Provenance*: append "Amended on 2026-10-21 by the plan's decisions
    (`docs/superpowers/plans/2026-10-21-premium-foundation.md`, P1, P3–P6, P11); each amendment says
    so."
  - §3.2, the `Plan` bullet: "the subscription period and the introductory offer's length (value and
    unit) when the user is eligible" → "the introductory offer's length (value and unit) when the user
    is eligible — not the subscription's period, which is a year by the product's identity (plan P5)".
  - §3.3, *Buying*: "the store makes the call itself, given the active `UIWindowScene` — which call,
    and at which availability, is the plan's first task (§9, unconfirmed)" → "the store makes the call
    itself, `purchase(confirmIn:options:)` on the active `UIWindowScene` — available from iOS 17.0
    and not deprecated, measured in the iOS 27.0 SDK's interface (plan P1)".
  - §3.7, item 2: "None in 1.4.1, so the section is not drawn." → "None in 1.4.1, so the section is not
    written; the first set writes it (plan P6)."
  - §3.7, item 3: "The words around them — the period, the trial's length — are ours, built from the
    `Plan`'s period and offer through the strings bundle with plural forms, so a trial changed in App
    Store Connect cannot leave the copy saying one week." → "The words around them are ours, through
    the strings bundle; the trial's length is Foundation's own words for it, in the app's language, so
    a trial changed in App Store Connect cannot leave the copy saying one week (plan P3)."
  - §3.7, item 4: "*Try 1 Week Free*, *Subscribe*, or *Buy Lifetime*" → "*Start Free Trial*,
    *Subscribe*, or *Buy Lifetime* — no length in the label, which Russian would need in another case
    (plan P4)".
  - §3.8: "a count beside a noun — the trial's days or weeks — takes plural variations (rule
    `70-privacy`, *Localization*)" → "no key counts a noun: the trial's length is Foundation's
    (plan P3)".
  - §6, `PremiumStoreTests`: delete "; the plans keep the yearly's trial only when eligible"; and in
    `StoreKitSessionTests` append "; a trial used once is not offered again (plan P11)".
  - §9, step 1: "which purchase call the store makes, and from which iOS version, without a new
    warning;" → "(the purchase call is settled, plan P1)".

---

### Task 1: The probe — the four unknowns, in a throwaway copy

Nothing here enters the tree. **If any check fails, stop and report to the owner before Task 2.**

**Files:** `$SCRATCH/probe/` only.

- [ ] **Step 1: A copy of `HEAD`.**

```bash
mkdir -p "$SCRATCH/probe" && git archive HEAD | tar -x -C "$SCRATCH/probe"
shasum "$SCRATCH/probe/WaterBuddy.xcodeproj/project.pbxproj" WaterBuddy.xcodeproj/project.pbxproj
```

  Expect the two sums equal.

- [ ] **Step 2: Write the configuration** to `$SCRATCH/probe/WaterBuddyTests/WaterBuddy.storekit`,
  exactly as Task 4 Step 1 gives it (with `Write`).
- [ ] **Step 3: Write the probe suite** to `$SCRATCH/probe/WaterBuddyTests/PremiumProbeTests.swift`:

```swift
import Foundation
import StoreKit
import StoreKitTest
import Testing
import UIKit
@testable import WaterBuddy

private final class ProbeBundle {}

@MainActor
@Suite(.serialized)
struct PremiumProbeTests {

    @Test func theConfigurationIsInTheTestBundleAlone() {
        #expect(Bundle(for: ProbeBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit") != nil)
        #expect(Bundle.main.url(forResource: "WaterBuddy", withExtension: "storekit") == nil)
    }

    @Test func aSessionLoadsBothProductsAndBuysInTheHost() async throws {
        let url = try #require(Bundle(for: ProbeBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }

        let products = try await Product.products(for: ["sardor.WaterBuddy.premium.yearly", "sardor.WaterBuddy.premium.lifetime"])
        #expect(products.count == 2)
        let yearly = try #require(products.first { $0.id == "sardor.WaterBuddy.premium.yearly" })
        #expect(yearly.subscription?.introductoryOffer?.paymentMode == .freeTrial)
        #expect(yearly.subscription?.introductoryOffer?.period.unit == .week)
        #expect(yearly.subscription?.introductoryOffer?.period.value == 1)
        #expect(await yearly.subscription?.isEligibleForIntroOffer == true)

        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        print("PROBE scenes:", scenes.map { String(describing: $0.activationState) })
        let scene = try #require(scenes.first { $0.activationState == .foregroundActive } ?? scenes.first)
        let result = try await yearly.purchase(confirmIn: scene)
        guard case .success(.verified(let transaction)) = result else {
            Issue.record("PROBE purchase answered \(result)")
            return
        }
        await transaction.finish()

        var held: [String] = []
        for await entitlement in Transaction.currentEntitlements {
            if case .verified(let current) = entitlement { held.append(current.productID) }
        }
        #expect(held == ["sardor.WaterBuddy.premium.yearly"])
    }

    @Test(arguments: ["en", "ru", "uz"])
    func aLengthReadsInItsOwnLanguage(code: String) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: code)
        let formatter = DateComponentsFormatter()
        formatter.calendar = calendar
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        var lines: [String] = []
        formatter.allowedUnits = [.weekOfMonth]
        lines += [1, 2, 5].map { formatter.string(from: DateComponents(weekOfMonth: $0)) ?? "nil" }
        formatter.allowedUnits = [.day]
        lines += [1, 3, 5].map { formatter.string(from: DateComponents(day: $0)) ?? "nil" }
        formatter.allowedUnits = [.month]
        lines += [1, 2].map { formatter.string(from: DateComponents(month: $0)) ?? "nil" }
        print("PROBE \(code):", lines.joined(separator: " | "))
    }
}
```

- [ ] **Step 4: Run it**, into its own DerivedData:

```bash
uptime
xcodebuild test -project "$SCRATCH/probe/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' -derivedDataPath "$SCRATCH/probe-dd" -only-testing:WaterBuddyTests/PremiumProbeTests -parallel-testing-enabled NO -collect-test-diagnostics never > "$SCRATCH/probe.log" 2>&1; echo "exit $?"
grep -E "PROBE|Test run with|✘|error:" "$SCRATCH/probe.log"
find "$SCRATCH/probe-dd/Build/Products" -name 'WaterBuddy.storekit'
shasum "$SCRATCH/probe/WaterBuddy.xcodeproj/project.pbxproj" WaterBuddy.xcodeproj/project.pbxproj
```

  **Expected:** 5 tests pass; the scenes line names at least one scene; the `find` prints one path,
  inside `WaterBuddyTests.xctest`, and none directly inside `WaterBuddy.app`; the two `project.pbxproj`
  sums still equal. The three `PROBE` language lines read, in their own words:
  - en: *1 week | 2 weeks | 5 weeks | 1 day | 3 days | 5 days | 1 month | 2 months*
  - ru: *1 неделя | 2 недели | 5 недель | 1 день | 3 дня | 5 дней | 1 месяц | 2 месяца*
  - uz: Uzbek words — *hafta*, *kun*, *oy* — not English.

  Record every line in the ledger. A purchase that does not complete, a configuration StoreKit
  rejects (the error is in the log), a file in the wrong bundle, or a language in English: **stop and
  report** — each is a plan change for the owner (P3's fallback, P8, or the configuration's format).
- [ ] **Step 5:** `rm -rf "$SCRATCH/probe" "$SCRATCH/probe-dd"` once the ledger holds the results.

---

### Task 2: The rule wording, typed

**Files:** `.claude/rules/70-privacy.md`, `10-architecture.md`, `15-project.md`,
`43-concurrency.md`, `85-testing.md`, `50-views.md`, `65-accessibility.md`, `CLAUDE.md`.

- [ ] **Step 1:** Type spec §5's wording into the seven rule files and `CLAUDE.md` with `Edit`,
  verbatim, each at the place §5 names. The owner approved it by approving the spec.
- [ ] **Step 2:** `git diff --stat -- .claude/rules CLAUDE.md` — eight files changed, none staged.
  Read each hunk against §5 once more. They stay **unstaged** to the end, for the owner.

---

### Task 3: `PremiumAccess` and `PremiumSet` — the decision

**Files:**
- Create: `WaterBuddy/PremiumAccess.swift`, `WaterBuddy/PremiumSet.swift`
- Test: `WaterBuddyTests/PremiumAccessTests.swift` (new)

**Interfaces:**
- Produces: `PremiumAccess.yearlyID`, `.lifetimeID`, `.productIDs: [String]`;
  `PremiumAccess.Entitlement(productID: String, expires: Date?, revoked: Date?)`;
  `PremiumAccess.Status` — `.free`, `.yearly(until: Date)`, `.lifetime`, `var isPremium: Bool`;
  `PremiumAccess.resolve(_: [Entitlement], now: Date) -> Status`;
  `PremiumAccess.Plan(id: String, kind: Kind, price: String, trial: Period?)`, `Plan.Kind` —
  `.yearly`, `.lifetime`; `Plan.Period(value: Int, unit: Unit)`, `Period.Unit` — `.day`, `.week`,
  `.month`, `.year`; `PremiumSet: CaseIterable` with no case.

- [ ] **Step 1: Write the failing tests** — `WaterBuddyTests/PremiumAccessTests.swift`:

```swift
//
//  PremiumAccessTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

/// Noon on 21 October 2026, UTC — the instant every case here calls now.
private let now = ISO8601DateFormatter().date(from: "2026-10-21T12:00:00Z")!

/// An hour either side of ``now``, and a year on.
private let earlier = now.addingTimeInterval(-3_600)
private let later = now.addingTimeInterval(3_600)
private let nextYear = ISO8601DateFormatter().date(from: "2027-10-21T12:00:00Z")!

private func yearly(expires: Date?, revoked: Date? = nil) -> PremiumAccess.Entitlement {
    PremiumAccess.Entitlement(productID: PremiumAccess.yearlyID, expires: expires, revoked: revoked)
}

private func lifetime(revoked: Date? = nil) -> PremiumAccess.Entitlement {
    PremiumAccess.Entitlement(productID: PremiumAccess.lifetimeID, expires: nil, revoked: revoked)
}

// MARK: - The decision

/// Not `@MainActor`, on purpose: a canary for ``PremiumAccess`` staying off the main actor
/// (rule `43-concurrency`). Fix the declaration it reads, never this suite.
struct PremiumAccessTests {

    @Test func nothingHeldIsFree() {
        #expect(PremiumAccess.resolve([], now: now) == .free)
    }

    @Test func aYearlyStillRunningIsPaidUntilItsPeriodEnds() {
        #expect(PremiumAccess.resolve([yearly(expires: later)], now: now) == .yearly(until: later))
    }

    @Test func aYearlyEndingAtThisInstantIsOver() {
        #expect(PremiumAccess.resolve([yearly(expires: now)], now: now) == .free)
    }

    @Test func aYearlyThatEndedIsOver() {
        #expect(PremiumAccess.resolve([yearly(expires: earlier)], now: now) == .free)
    }

    @Test func aRefundedYearlyIsFree() {
        #expect(PremiumAccess.resolve([yearly(expires: later, revoked: earlier)], now: now) == .free)
    }

    /// StoreKit gives every subscription an end; a missing one is not evidence of payment.
    @Test func aYearlyWithNoEndIsNotTakenAsPaid() {
        #expect(PremiumAccess.resolve([yearly(expires: nil)], now: now) == .free)
    }

    @Test func theLifetimePurchaseIsPremiumForGood() {
        #expect(PremiumAccess.resolve([lifetime()], now: now) == .lifetime)
    }

    @Test func theLifetimeWinsOverAYearlyBesideIt() {
        #expect(PremiumAccess.resolve([yearly(expires: later), lifetime()], now: now) == .lifetime)
    }

    @Test func aRefundedLifetimeLeavesTheYearlyStanding() {
        #expect(PremiumAccess.resolve([yearly(expires: later), lifetime(revoked: earlier)], now: now)
                == .yearly(until: later))
    }

    @Test func anUnknownProductIsIgnored() {
        let monthly = PremiumAccess.Entitlement(productID: "sardor.WaterBuddy.premium.monthly", expires: later, revoked: nil)
        let elsewhere = PremiumAccess.Entitlement(productID: "com.example.other.lifetime", expires: nil, revoked: nil)
        #expect(PremiumAccess.resolve([monthly, elsewhere], now: now) == .free)
    }

    @Test func twoYearlyPeriodsReadTheLaterEnd() {
        #expect(PremiumAccess.resolve([yearly(expires: later), yearly(expires: nextYear)], now: now)
                == .yearly(until: nextYear))
    }

    /// Review Focus 5: the same purchase, read again once its period has passed.
    @Test func anExpiryPassingWhileTheAppRunsReadsFreeOnTheNextRead() {
        let held = [yearly(expires: later)]
        #expect(PremiumAccess.resolve(held, now: now) == .yearly(until: later))
        #expect(PremiumAccess.resolve(held, now: later.addingTimeInterval(1)) == .free)
    }

    @Test func theProductIDsAreTwoAndOurs() {
        #expect(PremiumAccess.productIDs == ["sardor.WaterBuddy.premium.yearly", "sardor.WaterBuddy.premium.lifetime"])
        #expect(Set(PremiumAccess.productIDs).count == 2)
        #expect(PremiumAccess.productIDs.allSatisfy { $0.hasPrefix("sardor.WaterBuddy.premium.") })
    }

    @Test func onlyTheFreeStatusIsNotPremium() {
        #expect(!PremiumAccess.Status.free.isPremium)
        #expect(PremiumAccess.Status.yearly(until: later).isPremium)
        #expect(PremiumAccess.Status.lifetime.isPremium)
    }
}
```

- [ ] **Step 2: Land the API as a stub** — `WaterBuddy/PremiumAccess.swift` with the final
  declarations (Step 4's file) but three bodies wrong: `productIDs` is `[]`, `resolve` answers
  `.yearly(until: .distantPast)`, `isPremium` answers `false`. And `WaterBuddy/PremiumSet.swift`
  final (Step 4).
- [ ] **Step 3: Run it RED.**
  `UNIT -only-testing:WaterBuddyTests/PremiumAccessTests`.
  Expected: it compiles; **14 tests, 14 failures**. A test that passes against the stub is rewritten
  until it fails for the right reason.
- [ ] **Step 4: The real bodies.** `WaterBuddy/PremiumAccess.swift`:

```swift
//
//  PremiumAccess.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation

/// What Premium is, decided without StoreKit.
///
/// `ReminderPlan`'s shape for `ReminderPlan`'s reason: a pure function of plain facts, so every case
/// of the decision is testable without the framework, the App Store or a simulator's purchases
/// (spec `2026-10-21-premium-foundation-design.md` §3.2). ``PremiumStore`` reads StoreKit and hands
/// this file what it found. Nothing here imports StoreKit, and nothing here is stored: the paid state
/// is read again every time (rule `70-privacy`).
///
/// `nonisolated`, and every nested type with it, stated outright: the app's default isolation is the
/// main actor, and `PremiumAccessTests` reads all of this from off it, as a canary
/// (rule `43-concurrency`).
nonisolated enum PremiumAccess {

    /// The yearly subscription — group *WaterBuddy Premium*, one week free for the eligible.
    static let yearlyID = "sardor.WaterBuddy.premium.yearly"

    /// The lifetime purchase, a non-consumable.
    static let lifetimeID = "sardor.WaterBuddy.premium.lifetime"

    /// The one spelling of both. Nothing else in the product writes either string.
    static let productIDs = [yearlyID, lifetimeID]

    /// The facts read off one verified transaction — and nothing else of it.
    nonisolated struct Entitlement: Sendable, Equatable {
        let productID: String
        /// When a subscription's current period ends. `nil` for the lifetime purchase.
        let expires: Date?
        /// When Apple refunded or revoked it. `nil` while it stands.
        let revoked: Date?
    }

    /// What the user holds.
    nonisolated enum Status: Sendable, Equatable {
        case free
        /// The yearly plan, paid through the end of its current period — which is all a transaction
        /// says. Whether it renews is Apple's own sheet's to say (spec §3.6).
        case yearly(until: Date)
        case lifetime

        var isPremium: Bool { self != .free }
    }

    /// The answer, from whatever StoreKit said.
    ///
    /// Ignores a product ID it does not know, anything revoked, and a subscription whose period ended
    /// at or before `now`. StoreKit's current entitlements already leave out a refund, but an
    /// ``Entitlement`` also arrives from `Transaction.updates`, and a rule that held for one caller's
    /// input only would not be a rule. A subscription with no end is not taken as paid: StoreKit gives
    /// every subscription one, and a missing one is not evidence of payment. The lifetime purchase wins
    /// over a yearly plan held beside it; of two yearly periods, the later end.
    static func resolve(_ entitlements: [Entitlement], now: Date) -> Status {
        let standing = entitlements.filter { $0.revoked == nil }
        if standing.contains(where: { $0.productID == lifetimeID }) {
            return .lifetime
        }
        let until = standing
            .filter { $0.productID == yearlyID }
            .compactMap(\.expires)
            .filter { $0 > now }
            .max()
        return until.map(Status.yearly(until:)) ?? .free
    }

    /// One plan as the paywall draws it — a plain value, so no view holds a StoreKit `Product`
    /// (rule `50-views`).
    nonisolated struct Plan: Sendable, Equatable, Identifiable {

        nonisolated enum Kind: Sendable, Equatable, Hashable {
            case yearly, lifetime
        }

        /// A length of time, as StoreKit gives an offer's.
        nonisolated struct Period: Sendable, Equatable {

            nonisolated enum Unit: Sendable, Equatable {
                case day, week, month, year
            }

            let value: Int
            let unit: Unit
        }

        /// The product's identifier.
        let id: String
        let kind: Kind
        /// StoreKit's `displayPrice`, in the storefront's currency — drawn as it comes.
        let price: String
        /// The free introductory offer's length — present only when StoreKit says this user is
        /// eligible for it. The subscription's own period is not carried: the product is yearly by
        /// its identity (plan P5).
        let trial: Period?
    }
}
```

  And `WaterBuddy/PremiumSet.swift`:

```swift
//
//  PremiumSet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation

/// The sets Premium sells — one case per set, added by the item that builds it (`docs/ROADMAP.md`
/// §5, *Sold as sets*: *understand*, *coached*, *theirs*, *export*).
///
/// **No case in 1.4.1, on purpose.** ``PaywallView/isOffered(arguments:)`` offers the paywall in a
/// Release build only while this has a case, so the first set to land turns the paywall on with it
/// and nothing waits to be remembered. App Review asks an app to say what a subscription buys before
/// asking for it (spec §3.5); with no case there is nothing to say. The paywall's section that lists
/// the sets is written by the first set, with its first row (plan P6).
///
/// `nonisolated`, so the switch counts it from off the main actor (rule `43-concurrency`).
nonisolated enum PremiumSet: CaseIterable, Sendable {}
```

- [ ] **Step 5: Run it GREEN.** `UNIT -only-testing:WaterBuddyTests/PremiumAccessTests`. Expected:
  `✔ Test run with 14 tests … passed`. Then `git diff --stat` — only the three new files are new.

---

### Task 4: `PremiumStore`, its `Source`, and the local configuration

**Files:**
- Create: `WaterBuddy/PremiumStore.swift`, `WaterBuddyTests/WaterBuddy.storekit`
- Test: `WaterBuddyTests/PremiumStoreTests.swift` (new)

**Interfaces:**
- Consumes: Task 3's `PremiumAccess` types.
- Produces: `@MainActor @Observable final class PremiumStore` —
  `init(source: Source = .live(), now: @escaping () -> Date = Date.init)`;
  `private(set) var state: State` (`.checking`, `.known(PremiumAccess.Status)`,
  `var status: PremiumAccess.Status?`); `private(set) var plans: Plans` (`.notLoaded`, `.loading`,
  `.loaded([PremiumAccess.Plan])`, `.unavailable`); `private(set) var purchase: Purchase` (`.idle`,
  `.buying`, `.pending`, `.bought`, `.failed`); `func refresh() async`, `func prepare() async`,
  `func loadPlans() async`, `func buy(_: PremiumAccess.Plan) async`, `func restore() async`,
  `func manage() async`. `PremiumStore.Outcome` — `.bought`, `.pending`, `.cancelled`, `.unverified`.
  `PremiumStore.Source(entitlements:updates:plans:buy:restore:manage:)`, `static func live()`,
  `static func silent()`.

- [ ] **Step 1: The local configuration** — `WaterBuddyTests/WaterBuddy.storekit`, with `Write`. The
  prices are placeholders (spec §3.1); the owner's are set in App Store Connect.

```json
{
  "identifier" : "6C0E2A71",
  "nonRenewingSubscriptions" : [

  ],
  "products" : [
    {
      "displayPrice" : "39.99",
      "familyShareable" : true,
      "internalID" : "6754000001",
      "localizations" : [
        {
          "description" : "Every Premium extra, paid once.",
          "displayName" : "Premium Lifetime",
          "locale" : "en_US"
        }
      ],
      "productID" : "sardor.WaterBuddy.premium.lifetime",
      "referenceName" : "Premium Lifetime",
      "type" : "NonConsumable"
    }
  ],
  "settings" : {
    "_failTransactionsEnabled" : false,
    "_locale" : "en_US",
    "_storefront" : "USA",
    "_storeKitErrors" : [

    ]
  },
  "subscriptionGroups" : [
    {
      "id" : "21754001",
      "localizations" : [

      ],
      "name" : "WaterBuddy Premium",
      "subscriptions" : [
        {
          "adHocOffers" : [

          ],
          "codeOffers" : [

          ],
          "displayPrice" : "19.99",
          "familyShareable" : true,
          "groupNumber" : 1,
          "internalID" : "6754000002",
          "introductoryOffer" : {
            "internalID" : "6754000003",
            "paymentMode" : "free",
            "subscriptionPeriod" : "P1W"
          },
          "localizations" : [
            {
              "description" : "Every Premium extra, renewed each year.",
              "displayName" : "Premium Yearly",
              "locale" : "en_US"
            }
          ],
          "productID" : "sardor.WaterBuddy.premium.yearly",
          "recurringSubscriptionPeriod" : "P1Y",
          "referenceName" : "Premium Yearly",
          "subscriptionGroupID" : "21754001",
          "type" : "RecurringSubscription",
          "winbackOffers" : [

          ]
        }
      ]
    }
  ],
  "version" : {
    "major" : 4,
    "minor" : 0
  }
}
```

  If Task 1 had to correct this file to load, write the corrected one.

- [ ] **Step 2: Write the failing tests** — `WaterBuddyTests/PremiumStoreTests.swift`:

```swift
//
//  PremiumStoreTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import StoreKitTest
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private let now = ISO8601DateFormatter().date(from: "2026-10-21T12:00:00Z")!
private let later = now.addingTimeInterval(3_600)

private let yearlyPlan = PremiumAccess.Plan(
    id: PremiumAccess.yearlyID, kind: .yearly, price: "$19.99",
    trial: PremiumAccess.Plan.Period(value: 1, unit: .week)
)
private let lifetimePlan = PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "$39.99", trial: nil)

private let heldLifetime = PremiumAccess.Entitlement(productID: PremiumAccess.lifetimeID, expires: nil, revoked: nil)
private let heldYearly = PremiumAccess.Entitlement(productID: PremiumAccess.yearlyID, expires: later, revoked: nil)

private struct Refused: Error {}

/// StoreKit as a test answers it: what is held, the plans, what a purchase says — and a count of
/// every call, so a test sees what the store asked for. Every closure is a plain one: ``PremiumStore``
/// calls them on the main actor (plan P2).
@MainActor
private final class FakeAppStore {
    var held: [PremiumAccess.Entitlement] = []
    var plans: Result<[PremiumAccess.Plan], any Error> = .success([yearlyPlan, lifetimePlan])
    var outcome: Result<PremiumStore.Outcome, any Error> = .success(.bought)
    /// What a successful purchase leaves held, as the real one's finished transaction would.
    var boughtLeaves: [PremiumAccess.Entitlement] = [heldLifetime]
    var restoreFails = false
    /// Set, a purchase waits here until the test resumes it.
    var holdsPurchase = false
    var gate: CheckedContinuation<Void, Never>?
    private(set) var bought: [String] = []
    private(set) var restores = 0
    private(set) var manages = 0
    let (updates, update) = AsyncStream<Void>.makeStream()

    var source: PremiumStore.Source {
        PremiumStore.Source(
            entitlements: { self.held },
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
                if self.restoreFails { throw Refused() }
            },
            manage: { self.manages += 1 }
        )
    }
}

/// Gives the store's listener its turns, until `condition` holds or a thousand have passed.
@MainActor
private func settle(_ condition: () -> Bool) async {
    for _ in 0..<1_000 where !condition() {
        await Task.yield()
    }
}

// MARK: - The store

@MainActor
struct PremiumStoreTests {

    @Test func theStateWaitsForItsFirstRead() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        #expect(store.state == .checking)
        await store.refresh()
        #expect(store.state == .known(.free))
    }

    @Test func aLifetimePurchaseHeldReadsPremium() async {
        let fake = FakeAppStore()
        fake.held = [heldLifetime]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        #expect(store.state == .known(.lifetime))
        #expect(store.state.status?.isPremium == true)
    }

    @Test func aVerifiedPurchaseIsBoughtAndReadsPremium() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(lifetimePlan)
        #expect(fake.bought == [PremiumAccess.lifetimeID])
        #expect(store.purchase == .bought)
        #expect(store.state == .known(.lifetime))
    }

    @Test func anUnverifiedPurchaseFailsAndStaysFree() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.unverified)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .failed)
        #expect(store.state == .known(.free))
    }

    @Test func aPendingPurchaseIsPending() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.pending)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .pending)
        #expect(store.state == .known(.free))
    }

    @Test func aCancelledPurchaseChangesNothing() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.cancelled)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .idle)
        #expect(store.state == .known(.free))
    }

    @Test func aPurchaseThatThrowsFails() async {
        let fake = FakeAppStore()
        fake.outcome = .failure(Refused())
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .failed)
        #expect(store.state == .known(.free))
    }

    /// Review Focus 1.
    @Test func aSecondTapWhileBuyingBuysNothing() async {
        let fake = FakeAppStore()
        fake.holdsPurchase = true
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        let first = Task { await store.buy(lifetimePlan) }
        await settle { fake.gate != nil }
        #expect(store.purchase == .buying)
        await store.buy(lifetimePlan)
        #expect(fake.bought.count == 1)
        fake.gate?.resume()
        await first.value
        #expect(store.purchase == .bought)
        #expect(fake.bought.count == 1)
    }

    @Test func aRefundArrivingAsAnUpdateReadsFree() async {
        let fake = FakeAppStore()
        fake.held = [heldLifetime]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        #expect(store.state == .known(.lifetime))
        fake.held = []
        fake.update.yield()
        await settle { store.state == .known(.free) }
        #expect(store.state == .known(.free))
    }

    /// Review Focus 2.
    @Test func anApprovalArrivingAsAnUpdateReadsPremium() async {
        let fake = FakeAppStore()
        fake.outcome = .success(.pending)
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .pending)
        fake.held = [heldYearly]
        fake.update.yield()
        await settle { store.state == .known(.yearly(until: later)) }
        #expect(store.state == .known(.yearly(until: later)))
    }

    @Test func plansLoadBoth() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        #expect(store.plans == .notLoaded)
        await store.loadPlans()
        #expect(store.plans == .loaded([yearlyPlan, lifetimePlan]))
    }

    /// Review Focus 4.
    @Test func oneProductMissingIsUnavailable() async {
        let fake = FakeAppStore()
        fake.plans = .success([yearlyPlan])
        let store = PremiumStore(source: fake.source, now: { now })
        await store.loadPlans()
        #expect(store.plans == .unavailable)
    }

    @Test func aFailedLoadIsUnavailableAndTryingAgainRecovers() async {
        let fake = FakeAppStore()
        fake.plans = .failure(Refused())
        let store = PremiumStore(source: fake.source, now: { now })
        await store.loadPlans()
        #expect(store.plans == .unavailable)
        fake.plans = .success([yearlyPlan, lifetimePlan])
        await store.loadPlans()
        #expect(store.plans == .loaded([yearlyPlan, lifetimePlan]))
    }

    /// Review Focus 3.
    @Test func openingTheSheetAgainForgetsTheLastFailure() async {
        let fake = FakeAppStore()
        fake.outcome = .failure(Refused())
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        await store.buy(yearlyPlan)
        #expect(store.purchase == .failed)
        await store.prepare()
        #expect(store.purchase == .idle)
        #expect(store.plans == .loaded([yearlyPlan, lifetimePlan]))
    }

    @Test func restoreAsksTheAppStoreThenReads() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.refresh()
        fake.held = [heldLifetime]
        await store.restore()
        #expect(fake.restores == 1)
        #expect(store.state == .known(.lifetime))
    }

    @Test func aFailedRestoreStillReads() async {
        let fake = FakeAppStore()
        fake.restoreFails = true
        fake.held = [heldYearly]
        let store = PremiumStore(source: fake.source, now: { now })
        await store.restore()
        #expect(fake.restores == 1)
        #expect(store.state == .known(.yearly(until: later)))
    }

    @Test func manageOpensApplesSheet() async {
        let fake = FakeAppStore()
        let store = PremiumStore(source: fake.source, now: { now })
        await store.manage()
        #expect(fake.manages == 1)
    }

    /// Review Focus 5, through the store's own clock. Named apart from `PremiumAccessTests`' case:
    /// no name is used twice across suites (rule `85-testing`).
    @Test func anExpiryPassingWhileTheAppRunsReadsFreeOnTheStoresNextRead() async {
        let fake = FakeAppStore()
        fake.held = [heldYearly]
        var clock = now
        let store = PremiumStore(source: fake.source, now: { clock })
        await store.refresh()
        #expect(store.state == .known(.yearly(until: later)))
        clock = later.addingTimeInterval(1)
        await store.refresh()
        #expect(store.state == .known(.free))
    }
}

// MARK: - The live source, against the local configuration

private final class TestBundle {}

/// StoreKit itself, through ``PremiumStore/Source/live()``, against
/// `WaterBuddyTests/WaterBuddy.storekit` — never the App Store or its sandbox (rule `85-testing`).
/// Serialized: a session is the simulator's own state, shared by every test in the run.
@MainActor
@Suite(.serialized)
struct StoreKitSessionTests {

    private func withSession(_ body: (SKTestSession) async throws -> Void) async throws {
        let url = try #require(Bundle(for: TestBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.disableDialogs = true
        session.clearTransactions()
        defer { session.clearTransactions() }
        try await body(session)
    }

    @Test func bothProductsLoadAndTheYearlyOffersAFreeWeek() async throws {
        try await withSession { _ in
            let plans = try await PremiumStore.Source.live().plans()
            #expect(plans.map(\.id) == PremiumAccess.productIDs)
            #expect(plans.map(\.kind) == [.yearly, .lifetime])
            #expect(plans.allSatisfy { !$0.price.isEmpty })
            #expect(plans.first?.trial == PremiumAccess.Plan.Period(value: 1, unit: .week))
            #expect(plans.last?.trial == nil)
        }
    }

    /// Plan P5's premise: the local configuration's yearly plan is a year.
    @Test func theConfigurationsYearlyRenewsEveryYear() throws {
        let url = try #require(Bundle(for: TestBundle.self).url(forResource: "WaterBuddy", withExtension: "storekit"))
        let text = try String(contentsOf: url, encoding: .utf8)
        #expect(text.contains("\"recurringSubscriptionPeriod\" : \"P1Y\""))
    }

    @Test func aBoughtYearlyReadsPremium() async throws {
        try await withSession { _ in
            let source = PremiumStore.Source.live()
            #expect(try await source.buy(PremiumAccess.yearlyID) == .bought)
            let status = PremiumAccess.resolve(await source.entitlements(), now: .now)
            guard case .yearly(let until) = status else {
                Issue.record("a bought yearly read \(status)")
                return
            }
            #expect(until > .now)
        }
    }

    @Test func aBoughtLifetimeReadsPremiumForGood() async throws {
        try await withSession { _ in
            let source = PremiumStore.Source.live()
            #expect(try await source.buy(PremiumAccess.lifetimeID) == .bought)
            #expect(PremiumAccess.resolve(await source.entitlements(), now: .now) == .lifetime)
        }
    }

    @Test func anExpiredYearlyReadsFree() async throws {
        try await withSession { session in
            let source = PremiumStore.Source.live()
            #expect(try await source.buy(PremiumAccess.yearlyID) == .bought)
            try session.expireSubscription(productIdentifier: PremiumAccess.yearlyID)
            #expect(PremiumAccess.resolve(await source.entitlements(), now: .now) == .free)
        }
    }

    @Test func aRefundedLifetimeReadsFree() async throws {
        try await withSession { session in
            let source = PremiumStore.Source.live()
            #expect(try await source.buy(PremiumAccess.lifetimeID) == .bought)
            let bought = try #require(session.allTransactions().first { $0.productIdentifier == PremiumAccess.lifetimeID })
            try session.refundTransaction(identifier: bought.identifier)
            #expect(PremiumAccess.resolve(await source.entitlements(), now: .now) == .free)
        }
    }

    /// Plan P11: eligibility is StoreKit's answer.
    @Test func aTrialUsedOnceIsNotOfferedAgain() async throws {
        try await withSession { session in
            let source = PremiumStore.Source.live()
            #expect(try await source.buy(PremiumAccess.yearlyID) == .bought)
            try session.expireSubscription(productIdentifier: PremiumAccess.yearlyID)
            let plans = try await source.plans()
            #expect(plans.first?.kind == .yearly)
            #expect(plans.first?.trial == nil)
        }
    }

    @Test func anAskToBuyIsPendingUntilApproved() async throws {
        try await withSession { session in
            session.askToBuyEnabled = true
            let store = PremiumStore(source: .live())
            await store.refresh()
            await store.buy(PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "", trial: nil))
            #expect(store.purchase == .pending)
            let asked = try #require(session.allTransactions().first { $0.pendingAskToBuyConfirmation })
            try session.approveAskToBuyTransaction(identifier: asked.identifier)
            for _ in 0..<50 where store.state != .known(.lifetime) {
                try await Task.sleep(for: .milliseconds(100))
            }
            #expect(store.state == .known(.lifetime))
        }
    }
}
```

- [ ] **Step 3: Land the store as a stub** — `WaterBuddy/PremiumStore.swift` with Step 5's
  declarations, `live()` and `silent()` as written, but every method body of the class a no-op
  (`refresh`, `prepare`, `loadPlans`, `buy`, `restore`, `manage` each `{}`), and `init` assigning its
  stored properties and starting nothing.
- [ ] **Step 4: Run it RED.**
  `UNIT -only-testing:WaterBuddyTests/PremiumStoreTests -only-testing:WaterBuddyTests/StoreKitSessionTests`.
  Expected: it compiles; in `PremiumStoreTests` every test fails but none whose expectation the stub
  happens to meet — `theStateWaitsForItsFirstRead`'s first `#expect` passes and its second fails;
  `plansLoadBoth`'s first passes and its second fails. The session suite exercises `live()`, which is
  real, so it may pass already: that is recorded, not reshaped — its RED is Task 1's probe, which ran
  the same calls first. A `PremiumStoreTests` case that passes whole against the stub is rewritten.
- [ ] **Step 5: The real store.** `WaterBuddy/PremiumStore.swift`:

```swift
//
//  PremiumStore.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import Foundation
import Observation
import StoreKit
import UIKit

/// Premium's paid state, read from StoreKit — one of the two files that import it (rule
/// `70-privacy`, *StoreKit, for the review request and for Premium*). No `SwiftUI` here: its
/// `Transaction` would shadow StoreKit's.
///
/// **Read, never stored.** The state is read from `Transaction.currentEntitlements` when the store is
/// built, whenever the app comes forward, and after every transaction update, and is kept in memory
/// only. StoreKit keeps purchases on the device and answers offline; a cached flag would be a second
/// source of truth that could still say Premium after a refund (spec
/// `2026-10-21-premium-foundation-design.md` §3.3, decision D4). No key, no App Group write.
///
/// **Waiting, not free.** Until the first read the state is ``State/checking``, and nothing Premium
/// draws — so a paying user never sees a paywall flash at launch.
///
/// **StoreKit only through ``Source``**, a struct of closures built by ``Source/live()`` —
/// `ReminderScheduler`'s shape — so every decision here is testable without the App Store (rule
/// `43-concurrency`). App-only: the widget and the watch never compile this and never ask StoreKit
/// (rule `10-architecture`).
@MainActor
@Observable
final class PremiumStore {

    /// What is known of the user's purchases.
    nonisolated enum State: Sendable, Equatable {
        case checking
        case known(PremiumAccess.Status)

        /// What is held, or `nil` while the first read is outstanding.
        var status: PremiumAccess.Status? {
            guard case .known(let status) = self else { return nil }
            return status
        }
    }

    /// The two plans, as the paywall offers them.
    nonisolated enum Plans: Sendable, Equatable {
        case notLoaded
        case loading
        case loaded([PremiumAccess.Plan])
        /// StoreKit could not be reached, or did not return both products: never an empty or a half
        /// paywall (plan P7).
        case unavailable
    }

    /// Where a purchase stands.
    nonisolated enum Purchase: Sendable, Equatable {
        case idle, buying, pending, bought, failed
    }

    /// How StoreKit answered a purchase.
    nonisolated enum Outcome: Sendable, Equatable {
        case bought, pending, cancelled
        /// A purchase StoreKit could not verify. Never Premium.
        case unverified
    }

    /// Every way StoreKit reaches the store. Main-actor, unlike `ReminderScheduler`: only the store
    /// calls these, on the main actor, and the purchase, the manage sheet and the scene they need are
    /// main-actor themselves (plan P2).
    struct Source {
        /// The verified current entitlements, as plain facts.
        var entitlements: () async -> [PremiumAccess.Entitlement]
        /// One element for each verified transaction update, after it has been finished.
        var updates: () -> AsyncStream<Void>
        /// Both plans, the yearly's trial only for the eligible.
        var plans: () async throws -> [PremiumAccess.Plan]
        var buy: (_ productID: String) async throws -> Outcome
        var restore: () async throws -> Void
        var manage: () async -> Void
    }

    private(set) var state: State = .checking
    private(set) var plans: Plans = .notLoaded
    private(set) var purchase: Purchase = .idle

    @ObservationIgnored private let source: Source
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var listener: Task<Void, Never>?

    /// Listens at once — so a renewal, a refund or an approved Ask to Buy is never missed while the
    /// app runs — and reads the state for the first time.
    init(source: Source = .live(), now: @escaping () -> Date = Date.init) {
        self.source = source
        self.now = now
        let updates = source.updates()
        listener = Task { [weak self] in
            for await _ in updates {
                await self?.refresh()
            }
        }
        Task { [weak self] in
            await self?.refresh()
        }
    }

    deinit {
        listener?.cancel()
    }

    /// Reads what is held, and publishes it only when it changed.
    func refresh() async {
        let status = PremiumAccess.resolve(await source.entitlements(), now: now())
        if state != .known(status) {
            state = .known(status)
        }
    }

    /// Opens the paywall clean: the last purchase's outcome forgotten, the plans read again.
    func prepare() async {
        purchase = .idle
        await loadPlans()
    }

    /// Reads both plans; anything less is ``Plans/unavailable`` (plan P7).
    func loadPlans() async {
        plans = .loading
        do {
            let loaded = try await source.plans()
            let complete = loaded.count == 2 && Set(loaded.map(\.kind)) == [.yearly, .lifetime]
            plans = complete ? .loaded(loaded) : .unavailable
        } catch {
            plans = .unavailable
        }
    }

    /// Buys one plan. A second tap while one is under way buys nothing.
    func buy(_ plan: PremiumAccess.Plan) async {
        guard purchase != .buying else { return }
        purchase = .buying
        do {
            switch try await source.buy(plan.id) {
            case .bought:
                await refresh()
                purchase = .bought
            case .pending:
                purchase = .pending
            case .cancelled:
                purchase = .idle
            case .unverified:
                purchase = .failed
            }
        } catch {
            purchase = .failed
        }
    }

    /// Asks the App Store for the user's purchases again, then reads them — App Review asks every
    /// app that sells something restorable for this (spec §3.3).
    func restore() async {
        do {
            try await source.restore()
        } catch {
            #if DEBUG
            print("WaterBuddy: restoring purchases failed; the state is read as it stands.")
            #endif
        }
        await refresh()
    }

    /// Apple's own sheet for the subscription, which says whether it renews.
    func manage() async {
        await source.manage()
    }

    /// The scene a purchase is confirmed in and the manage sheet is shown on: the one in the
    /// foreground, else any.
    static func foregroundScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }

    /// Neither a product nor a scene to buy it in. `fileprivate`, not `private`: ``Source/live()``
    /// throws it from an extension outside this declaration.
    fileprivate struct Unreachable: Error {}
}

extension PremiumStore.Source {

    /// StoreKit itself. Every closure calls it in its own body; nothing StoreKit is stored.
    static func live() -> Self {
        Self(
            entitlements: {
                var found: [PremiumAccess.Entitlement] = []
                for await result in Transaction.currentEntitlements {
                    // An unverified transaction is not taken as paid, here or anywhere.
                    guard case .verified(let transaction) = result else { continue }
                    found.append(PremiumAccess.Entitlement(transaction))
                }
                return found
            },
            updates: {
                let (stream, continuation) = AsyncStream<Void>.makeStream()
                let listener = Task {
                    for await result in Transaction.updates {
                        guard case .verified(let transaction) = result else { continue }
                        await transaction.finish()
                        continuation.yield()
                    }
                    continuation.finish()
                }
                continuation.onTermination = { _ in listener.cancel() }
                return stream
            },
            plans: {
                let products = try await Product.products(for: PremiumAccess.productIDs)
                var plans: [PremiumAccess.Plan] = []
                for id in PremiumAccess.productIDs {
                    guard let product = products.first(where: { $0.id == id }) else { continue }
                    plans.append(await PremiumAccess.Plan(product))
                }
                return plans
            },
            buy: { productID in
                guard let product = try await Product.products(for: [productID]).first,
                      let scene = PremiumStore.foregroundScene() else {
                    throw PremiumStore.Unreachable()
                }
                switch try await product.purchase(confirmIn: scene) {
                case .success(.verified(let transaction)):
                    await transaction.finish()
                    return .bought
                case .success(.unverified):
                    return .unverified
                case .pending:
                    return .pending
                case .userCancelled:
                    return .cancelled
                @unknown default:
                    return .unverified
                }
            },
            restore: {
                try await AppStore.sync()
            },
            manage: {
                // Apple's sheet is not supported on a Mac ([MS] in the spec).
                guard !ProcessInfo.processInfo.isiOSAppOnMac,
                      let scene = PremiumStore.foregroundScene() else { return }
                do {
                    try await AppStore.showManageSubscriptions(in: scene)
                } catch {
                    #if DEBUG
                    print("WaterBuddy: the manage-subscriptions sheet could not be shown.")
                    #endif
                }
            }
        )
    }

    /// A source that answers nothing and reaches no store — for a `#Preview` (plan P12).
    static func silent() -> Self {
        Self(
            entitlements: { [] },
            updates: { AsyncStream { $0.finish() } },
            plans: { [] },
            buy: { _ in .cancelled },
            restore: {},
            manage: {}
        )
    }
}

private extension PremiumAccess.Entitlement {

    init(_ transaction: Transaction) {
        self.init(
            productID: transaction.productID,
            expires: transaction.expirationDate,
            revoked: transaction.revocationDate
        )
    }
}

private extension PremiumAccess.Plan {

    /// The plan a product offers this user — the trial only when it is a free one and StoreKit says
    /// they are eligible for it.
    init(_ product: Product) async {
        var trial: Period?
        if let subscription = product.subscription,
           let offer = subscription.introductoryOffer,
           offer.paymentMode == .freeTrial,
           await subscription.isEligibleForIntroOffer {
            trial = Period(offer.period, count: offer.periodCount)
        }
        self.init(
            id: product.id,
            kind: product.id == PremiumAccess.lifetimeID ? .lifetime : .yearly,
            price: product.displayPrice,
            trial: trial
        )
    }
}

private extension PremiumAccess.Plan.Period {

    init?(_ period: Product.SubscriptionPeriod, count: Int) {
        let unit: Unit
        switch period.unit {
        case .day: unit = .day
        case .week: unit = .week
        case .month: unit = .month
        case .year: unit = .year
        @unknown default: return nil
        }
        self.init(value: period.value * max(1, count), unit: unit)
    }
}
```

- [ ] **Step 6: Run it GREEN.**
  `UNIT -only-testing:WaterBuddyTests/PremiumStoreTests -only-testing:WaterBuddyTests/StoreKitSessionTests`.
  Expected: **26 tests passed**. Then `UNIT -only-testing:WaterBuddyTests/PremiumAccessTests` again: 14.
  If a session test fails, read why before touching it: a StoreKit behaviour the spec did not expect
  is reported to the owner, not fitted.
- [ ] **Step 7:** `grep -rln 'import StoreKit' WaterBuddy WaterBuddyWidget WaterBuddyWatch WaterBuddyWatchWidget`
  prints `WaterBuddy/HomeView.swift` and `WaterBuddy/PremiumStore.swift` and nothing else;
  `grep -rln 'import StoreKitTest' WaterBuddyTests` prints `WaterBuddyTests/PremiumStoreTests.swift`.

---

### Task 5: The words

**Files:**
- Modify: `WaterBuddy/PremiumAccess.swift` (inside `Plan`, `Period` and `Status`),
  `WaterBuddy/Localizable.xcstrings`, `WaterBuddyTests/PremiumAccessTests.swift`,
  `WaterBuddyTests/LocalizationTests.swift`

**Interfaces:**
- Produces: `Plan.name(in: Bundle) -> String`, `Plan.priceLine(in: Bundle, locale: Locale) -> String`,
  `Plan.terms(in: Bundle, locale: Locale) -> String`, `Plan.action(in: Bundle) -> String`,
  `Period.formatted(locale: Locale) -> String?`, `Status.line(in: Bundle, locale: Locale) -> String?`.

- [ ] **Step 1: Before the catalogue — Xcode closed.** Ask the owner to confirm the project is not
  open in Xcode (`tasks/lessons.md`, 2026-10-18); then
  `git diff --stat -- '*.xcstrings'` — expect only #50's two (`AppShortcuts`, the watch's), and
  `WaterBuddy/Localizable.xcstrings` not among them.
- [ ] **Step 2: Write the failing tests.** Append to `WaterBuddyTests/PremiumAccessTests.swift`:

```swift
// MARK: - The words

/// One shipped language's table inside the built app — never the catalogue off disk
/// (rule `70-privacy`).
private func table(_ code: String) -> Bundle {
    Bundle(url: Bundle.main.bundleURL.appending(path: "\(code).lproj"))!
}

private let en = Locale(identifier: "en_US")
private let ru = Locale(identifier: "ru_RU")
private let uz = Locale(identifier: "uz_UZ")

private func yearlyPlan(trial: PremiumAccess.Plan.Period?) -> PremiumAccess.Plan {
    PremiumAccess.Plan(id: PremiumAccess.yearlyID, kind: .yearly, price: "$19.99", trial: trial)
}
private let week = PremiumAccess.Plan.Period(value: 1, unit: .week)
private let lifetimePlan = PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "$39.99", trial: nil)

/// Every sentence the paywall draws, formatted as it draws them — plural forms included, which
/// comparing resolved values cannot see (`tasks/lessons.md`, 2026-10-16). Not `@MainActor`: the words
/// are plain functions (plan P10).
struct PremiumWordsTests {

    @Test func theEnglishLinesReadAsDesigned() {
        let strings = table("en")
        #expect(yearlyPlan(trial: week).priceLine(in: strings, locale: en) == "1 week free, then $19.99 a year")
        #expect(yearlyPlan(trial: nil).priceLine(in: strings, locale: en) == "$19.99 a year")
        #expect(lifetimePlan.priceLine(in: strings, locale: en) == "$39.99, once")
        #expect(yearlyPlan(trial: week).name(in: strings) == "Yearly")
        #expect(lifetimePlan.name(in: strings) == "Lifetime")
        #expect(yearlyPlan(trial: week).action(in: strings) == "Start Free Trial")
        #expect(yearlyPlan(trial: nil).action(in: strings) == "Subscribe")
        #expect(lifetimePlan.action(in: strings) == "Buy Lifetime")
        #expect(yearlyPlan(trial: week).terms(in: strings, locale: en)
                == "Free trial: 1 week. Then $19.99 is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.")
        #expect(yearlyPlan(trial: nil).terms(in: strings, locale: en)
                == "$19.99 is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.")
        #expect(lifetimePlan.terms(in: strings, locale: en) == "One payment. It never renews.")
    }

    @Test(arguments: [("ru", "1 неделя", "в год"), ("uz", "1 hafta", "yiliga")])
    func aTrialReadsInItsOwnLanguage(code: String, length: String, perYear: String) {
        let locale = Locale(identifier: code)
        let line = yearlyPlan(trial: week).priceLine(in: table(code), locale: locale)
        #expect(line.contains(length), "\(code): \(line)")
        #expect(line.contains(perYear), "\(code): \(line)")
        #expect(line.contains("$19.99"), "\(code): \(line)")
        #expect(yearlyPlan(trial: week).terms(in: table(code), locale: locale).contains(length))
    }

    @Test func aLongerTrialTakesItsOwnForm() {
        let ruTable = table("ru")
        let twoWeeks = PremiumAccess.Plan.Period(value: 2, unit: .week)
        let threeDays = PremiumAccess.Plan.Period(value: 3, unit: .day)
        let fiveDays = PremiumAccess.Plan.Period(value: 5, unit: .day)
        #expect(yearlyPlan(trial: twoWeeks).priceLine(in: ruTable, locale: ru).contains("2 недели"))
        #expect(yearlyPlan(trial: threeDays).priceLine(in: ruTable, locale: ru).contains("3 дня"))
        #expect(yearlyPlan(trial: fiveDays).priceLine(in: ruTable, locale: ru).contains("5 дней"))
        #expect(yearlyPlan(trial: threeDays).priceLine(in: table("en"), locale: en) == "3 days free, then $19.99 a year")
    }

    @Test func theHeldPlanReadsItsDate() {
        let strings = table("en")
        let until = ISO8601DateFormatter().date(from: "2027-10-21T12:00:00Z")!
        let line = PremiumAccess.Status.yearly(until: until).line(in: strings, locale: en)
        #expect(line?.hasPrefix("Yearly, until ") == true)
        #expect(line?.contains("2027") == true)
        #expect(PremiumAccess.Status.lifetime.line(in: strings, locale: en) == "Lifetime")
        #expect(PremiumAccess.Status.free.line(in: strings, locale: en) == nil)
    }

    /// Plan P4: a length in a button would need another case in Russian.
    @Test(arguments: ["en", "ru", "uz"])
    func theButtonsNameNoLength(code: String) {
        for plan in [yearlyPlan(trial: week), yearlyPlan(trial: nil), lifetimePlan] {
            let action = plan.action(in: table(code))
            #expect(!action.isEmpty)
            #expect(!action.contains { $0.isNumber }, "\(code): \(action)")
        }
    }
}
```

  And in `WaterBuddyTests/LocalizationTests.swift`, after `welcomeKeys` — `premiumKeys`:

```swift
/// The paywall's and the Premium card's strings (spec 2026-10-21 §3.8). Most are resolved by name in
/// `PremiumAccess`, where the build's extraction cannot see them.
private let premiumKeys = [
    "WaterBuddy Premium",
    "Logging water is free, always.",
    "Restore Purchases",
    "Terms of Use",
    "Privacy Policy",
    "The App Store can't be reached right now.",
    "Try Again",
    "Waiting for approval.",
    "The purchase didn't go through.",
    "Thank you",
    "You have Premium.",
    "Premium",
    "Extras for the way you drink. Logging water stays free.",
    "See Premium",
    "Manage Subscription",
    "Yearly",
    "Lifetime",
    "%1$@ free, then %2$@ a year",
    "%1$@ a year",
    "%1$@, once",
    "Start Free Trial",
    "Subscribe",
    "Buy Lifetime",
    "Free trial: %1$@. Then %2$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
    "%1$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
    "One payment. It never renews.",
    "Yearly, until %1$@",
]
```

  and after `WelcomeStringTests`:

```swift
/// The paywall's own strings, in every language the app ships.
struct PremiumStringTests {

    @Test(arguments: ["en"] + translated)
    func everyPremiumStringExistsAndKeepsItsArguments(language: String) {
        for key in premiumKeys {
            let resolved = sentences(appBundle, language, key)
            #expect(resolved != nil, "\(language) has no value for \"\(key)\"")
            for sentence in resolved ?? [] {
                #expect(specifiers(in: sentence) == specifiers(in: key),
                        "\"\(key)\" in \(language) does not carry the same format arguments: \(sentence)")
            }
        }
    }
}
```

- [ ] **Step 3: Land the functions as stubs** — inside `PremiumAccess.Plan`, `Plan.Period` and
  `PremiumAccess.Status` in `WaterBuddy/PremiumAccess.swift`, Step 5's signatures with bodies that
  answer `""` (or `nil` for the two optionals).
- [ ] **Step 4: Run it RED.**
  `UNIT -only-testing:WaterBuddyTests/PremiumWordsTests -only-testing:WaterBuddyTests/PremiumStringTests`.
  Expected: it compiles; every `PremiumWordsTests` case fails; `PremiumStringTests` fails for `ru` and
  `uz` on every key (missing) and for `en` on the keys no `Text` literal carries.
- [ ] **Step 5: The real functions.** In `WaterBuddy/PremiumAccess.swift`, inside `Plan` (after
  `trial`):

```swift
        /// *Yearly* or *Lifetime* — the row's name and its VoiceOver label.
        func name(in strings: Bundle) -> String {
            switch kind {
            case .yearly: strings.localizedString(forKey: "Yearly", value: nil, table: nil)
            case .lifetime: strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            }
        }

        /// The row's second line and its VoiceOver value: *1 week free, then $19.99 a year*,
        /// *$19.99 a year*, or *$39.99, once*. The price is StoreKit's string; the trial's length is
        /// Foundation's, in `locale`'s language (plan P3).
        func priceLine(in strings: Bundle, locale: Locale) -> String {
            switch kind {
            case .lifetime:
                return strings.localized("%1$@, once", price, locale: locale)
            case .yearly:
                if let length = trial?.formatted(locale: locale) {
                    return strings.localized("%1$@ free, then %2$@ a year", length, price, locale: locale)
                }
                return strings.localized("%1$@ a year", price, locale: locale)
            }
        }

        /// What happens after the purchase, drawn under the button (spec §3.7, 5).
        func terms(in strings: Bundle, locale: Locale) -> String {
            switch kind {
            case .lifetime:
                return strings.localizedString(forKey: "One payment. It never renews.", value: nil, table: nil)
            case .yearly:
                if let length = trial?.formatted(locale: locale) {
                    return strings.localized(
                        "Free trial: %1$@. Then %2$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
                        length, price, locale: locale
                    )
                }
                return strings.localized(
                    "%1$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.",
                    price, locale: locale
                )
            }
        }

        /// The primary surface's label. No length in it: Russian would need another case (plan P4).
        func action(in strings: Bundle) -> String {
            let key = switch kind {
            case .lifetime: "Buy Lifetime"
            case .yearly: trial == nil ? "Subscribe" : "Start Free Trial"
            }
            return strings.localizedString(forKey: key, value: nil, table: nil)
        }
```

  inside `Plan.Period` (after `unit`):

```swift
            /// *1 week*, *1 неделя*, *1 hafta* — Foundation's own words for a length, in `locale`'s
            /// language (plan P3). `nil` only if Foundation cannot say it; then the line is drawn
            /// without it.
            func formatted(locale: Locale) -> String? {
                var calendar = Calendar(identifier: .gregorian)
                calendar.locale = locale
                let formatter = DateComponentsFormatter()
                formatter.calendar = calendar
                formatter.unitsStyle = .full
                formatter.maximumUnitCount = 1
                var components = DateComponents()
                switch unit {
                case .day:
                    formatter.allowedUnits = [.day]
                    components.day = value
                case .week:
                    formatter.allowedUnits = [.weekOfMonth]
                    components.weekOfMonth = value
                case .month:
                    formatter.allowedUnits = [.month]
                    components.month = value
                case .year:
                    formatter.allowedUnits = [.year]
                    components.year = value
                }
                return formatter.string(from: components)
            }
```

  and inside `Status` (after `isPremium`):

```swift
        /// *Yearly, until 21 October 2027* or *Lifetime* — the Settings card's line and the paywall's
        /// once it is held. `nil` when nothing is.
        func line(in strings: Bundle, locale: Locale) -> String? {
            switch self {
            case .free:
                return nil
            case .lifetime:
                return strings.localizedString(forKey: "Lifetime", value: nil, table: nil)
            case .yearly(let until):
                let date = until.formatted(Date.FormatStyle(date: .long, time: .omitted).locale(locale))
                return strings.localized("Yearly, until %1$@", date, locale: locale)
            }
        }
```

- [ ] **Step 6: The catalogue.** Edit `WaterBuddy/Localizable.xcstrings` with `Edit`: insert the 27
  entries below as one block inside `"strings"`, before the first existing key's entry (`Edit`'s
  anchor: the line `  "strings" : {` and the line after it). Every value `"state" : "translated"`;
  `"extractionState" : "manual"`. Uzbek uses the catalogue's own ‘ (U+2018) and ’ (U+2019).

| Key | en | ru | uz |
|---|---|---|---|
| `WaterBuddy Premium` | WaterBuddy Premium | WaterBuddy Premium | WaterBuddy Premium |
| `Logging water is free, always.` | = key | Записывать воду — бесплатно. Всегда. | Suv yozib borish — doim bepul. |
| `Restore Purchases` | = key | Восстановить покупки | Xaridlarni tiklash |
| `Terms of Use` | = key | Условия использования | Foydalanish shartlari |
| `Privacy Policy` | = key | Политика конфиденциальности | Maxfiylik siyosati |
| `The App Store can't be reached right now.` | = key | Сейчас не удаётся связаться с App Store. | Hozir App Store bilan bog‘lanib bo‘lmayapti. |
| `Try Again` | = key | Повторить | Qayta urinish |
| `Waiting for approval.` | = key | Ждём одобрения. | Tasdiq kutilmoqda. |
| `The purchase didn't go through.` | = key | Покупка не прошла. | Xarid amalga oshmadi. |
| `Thank you` | = key | Спасибо | Rahmat |
| `You have Premium.` | = key | У вас есть Premium. | Sizda Premium bor. |
| `Premium` | Premium | Premium | Premium |
| `Extras for the way you drink. Logging water stays free.` | = key | Дополнения под ваш ритм. Записывать воду — по-прежнему бесплатно. | Odatingizga mos qo‘shimchalar. Suv yozib borish bepulligicha qoladi. |
| `See Premium` | = key | Открыть Premium | Premium’ni ochish |
| `Manage Subscription` | = key | Управлять подпиской | Obunani boshqarish |
| `Yearly` | = key | На год | Yillik |
| `Lifetime` | = key | Навсегда | Umrbod |
| `%1$@ free, then %2$@ a year` | = key | %1$@ бесплатно, затем %2$@ в год | %1$@ bepul, keyin yiliga %2$@ |
| `%1$@ a year` | = key | %1$@ в год | Yiliga %1$@ |
| `%1$@, once` | = key | %1$@, один раз | %1$@, bir marta |
| `Start Free Trial` | = key | Начать пробный период | Bepul sinovni boshlash |
| `Subscribe` | = key | Подписаться | Obuna bo‘lish |
| `Buy Lifetime` | = key | Купить навсегда | Umrbod sotib olish |
| `Free trial: %1$@. Then %2$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.` | = key | Пробный период: %1$@. Затем %2$@ списывается каждый год, пока вы не отмените подписку. Отмените её не позднее чем за 24 часа до продления в настройках аккаунта Apple. | Bepul sinov: %1$@. So‘ng obunani bekor qilmaguningizcha har yili %2$@ yechiladi. Uni yangilanishdan kamida 24 soat oldin Apple hisobingiz sozlamalarida bekor qiling. |
| `%1$@ is charged each year until you cancel. Cancel at least 24 hours before it renews, in your Apple Account settings.` | = key | %1$@ списывается каждый год, пока вы не отмените подписку. Отмените её не позднее чем за 24 часа до продления в настройках аккаунта Apple. | Obunani bekor qilmaguningizcha har yili %1$@ yechiladi. Uni yangilanishdan kamida 24 soat oldin Apple hisobingiz sozlamalarida bekor qiling. |
| `One payment. It never renews.` | = key | Один платёж. Без продлений. | Bir martalik to‘lov. Yangilanmaydi. |
| `Yearly, until %1$@` | = key | На год, до %1$@ | Yillik, %1$@ gacha |

  Each entry has this shape (the first, written out; the other 26 the same with their row's values):

```json
    "%1$@ a year" : {
      "extractionState" : "manual",
      "localizations" : {
        "en" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "%1$@ a year"
          }
        },
        "ru" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "%1$@ в год"
          }
        },
        "uz" : {
          "stringUnit" : {
            "state" : "translated",
            "value" : "Yiliga %1$@"
          }
        }
      }
    },
```

  Then prove the file parses and holds them, read-only:
  `python3 -I -c 'import json,sys; d=json.load(open(sys.argv[1])); print(len(d["strings"]))' WaterBuddy/Localizable.xcstrings`
  — 113 before, **140** after.
- [ ] **Step 7: Run it GREEN.**
  `UNIT -only-testing:WaterBuddyTests/PremiumWordsTests -only-testing:WaterBuddyTests/PremiumStringTests -only-testing:WaterBuddyTests/LocalizationTests`.
  Expected: every test passes — `everyDrawnStringIsTranslatedUnlessDeliberatelyNot` among them. Then
  `PremiumAccessTests` again: 14.

---

### Task 6: The paywall, the card, the app

**Files:**
- Create: `WaterBuddy/PaywallView.swift`, `WaterBuddyUITests/PremiumUITests.swift`
- Modify: `WaterBuddy/WaterBuddyApp.swift`, `WaterBuddy/SettingsView.swift`,
  `WaterBuddy/RootTabView.swift` (preview), `WaterBuddy/HomeView.swift` (DocC),
  `WaterBuddy/DataManager.swift` (DocC), `WaterBuddyTests/PremiumAccessTests.swift`

**Interfaces:**
- Consumes: `PremiumStore` (Task 4), the words (Task 5), `PremiumSet` (Task 3).
- Produces: `PaywallView(entry: PaywallView.Entry)`, `PaywallView.Entry.settings`,
  `PaywallView.launchArgument`, `.termsOfUse: URL?`, `.privacyPolicy: URL?`,
  `.isOffered(debug: Bool, arguments: [String], sets: Int) -> Bool`,
  `.isOffered(arguments: [String]) -> Bool`, `.isOfferedHere: Bool`.

- [ ] **Step 1: The Privacy Policy's URL.** Ask the owner for it (they agreed to give it before this
  task). Write it into the ledger. It replaces `OWNER-PRIVACY-URL` in Step 5; Step 6 greps that the
  token is gone. Without it, stop here.
- [ ] **Step 2: Write the failing tests.** Append to `WaterBuddyTests/PremiumAccessTests.swift`:

```swift
// MARK: - The switch

/// Not `@MainActor`: the switch is read from off it (rule `43-concurrency`).
struct PaywallOfferTests {

    @Test func aDebugBuildOffersThePaywallOnlyWhenLaunchedToOfferIt() {
        #expect(PaywallView.launchArgument == "-WaterBuddyPremium")
        #expect(!PaywallView.isOffered(debug: true, arguments: [], sets: 0))
        #expect(!PaywallView.isOffered(debug: true, arguments: ["-WaterBuddyFreshStart", "YES"], sets: 3))
        #expect(PaywallView.isOffered(debug: true, arguments: ["-WaterBuddyPremium", "YES"], sets: 0))
    }

    @Test func aReleaseBuildOffersItOnlyWithASetToSell() {
        #expect(!PaywallView.isOffered(debug: false, arguments: [], sets: 0))
        #expect(!PaywallView.isOffered(debug: false, arguments: ["-WaterBuddyPremium", "YES"], sets: 0))
        #expect(PaywallView.isOffered(debug: false, arguments: [], sets: 1))
    }

    /// The gate's own runs are not launched to offer it, so nothing in them meets the card.
    @Test func theTestRunItselfIsNotOfferedThePaywall() {
        #if DEBUG
        #expect(!PaywallView.isOfferedHere)
        #endif
    }

    @Test func theLinksAreApplesTermsAndAPageOfOurs() {
        #expect(PaywallView.termsOfUse?.absoluteString == "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        #expect(PaywallView.privacyPolicy?.scheme == "https")
    }
}
```

  And `WaterBuddyUITests/PremiumUITests.swift`:

```swift
//
//  PremiumUITests.swift
//  WaterBuddyUITests
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import XCTest

/// Premium's card and sheet (spec `2026-10-21-premium-foundation-design.md` §6). The only class that
/// launches with `-WaterBuddyPremium` (rule `85-testing`). It asserts nothing that needs a product to
/// load: a gate run has no StoreKit configuration, so the plans read as unavailable.
final class PremiumUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
    }

    /// One element by its label, whether SwiftUI exposes it as a button or a link.
    private func count(_ label: String, in app: XCUIApplication) -> Int {
        app.buttons.matching(identifier: label).count + app.links.matching(identifier: label).count
    }

    @MainActor
    func testAnOrdinaryRunHasNoPremiumCard() throws {
        let app = XCUIApplication()
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["Settings"].tap()
        XCTAssertTrue(app.sliders["Daily water goal"].waitForExistence(timeout: 5))
        app.swipeUp()
        app.swipeUp()
        XCTAssertFalse(app.buttons["See Premium"].exists, "the card showed in a run not launched to offer it")
    }

    @MainActor
    func testTheCardOpensThePaywall() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-WaterBuddyPremium", "YES"]
        app.launch()
        completeWelcomeIfShown(app)

        app.buttons["Settings"].tap()
        let see = app.buttons["See Premium"]
        XCTAssertTrue(see.waitForExistence(timeout: 10), "no Premium card")
        // The card sits last, under the language card.
        for _ in 0..<4 where !see.isHittable {
            app.swipeUp()
        }
        XCTAssertEqual(app.buttons.matching(identifier: "See Premium").count, 1)
        tapWhenReady(see)

        XCTAssertTrue(app.staticTexts["WaterBuddy Premium"].waitForExistence(timeout: 5), "no paywall")
        XCTAssertEqual(app.staticTexts.matching(identifier: "Logging water is free, always.").count, 1)
        for label in ["Restore Purchases", "Terms of Use", "Privacy Policy", "Not now"] {
            XCTAssertEqual(count(label, in: app), 1, "\(label) is not one element")
        }

        app.buttons["Not now"].tap()
        XCTAssertTrue(see.waitForExistence(timeout: 5), "Not now did not close the paywall")
    }
}
```

- [ ] **Step 3: Land the view as a stub** — `WaterBuddy/PaywallView.swift` with Step 5's statics and
  `Entry`, `isOffered(debug:arguments:sets:)` answering `true`, `termsOfUse` and `privacyPolicy`
  `nil`, and `body` an `EmptyView()`. No card in Settings yet.
- [ ] **Step 4: Run it RED.**
  `UNIT -only-testing:WaterBuddyTests/PaywallOfferTests` — expected 4 tests: the first three fail on
  their `false` expectations, the fourth on its `nil`s. Then the UI class on *WaterBuddy Gate 27*:

```bash
uptime
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests/PremiumUITests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
```

  Expected: `testTheCardOpensThePaywall` fails at *no Premium card*; `testAnOrdinaryRunHasNoPremiumCard`
  passes — there is no card for it to find yet. That one is recorded as first seen green, and Step 7
  is where it earns its keep: it fails if the card ever shows without the argument.
- [ ] **Step 5: The real view, the card and the wiring.**

  `WaterBuddy/PaywallView.swift`:

```swift
//
//  PaywallView.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 21/10/26.
//

import SwiftUI

/// WaterBuddy Premium's paywall — our own, in the app's glass and the app's language
/// (spec `2026-10-21-premium-foundation-design.md` §3.7, decision D3).
///
/// **Never imports StoreKit.** It reads ``PremiumStore`` from the environment and draws
/// ``PremiumAccess/Plan``s; StoreKit's own views would draw their words in the device's language, not
/// the app's (rule `50-views`, rule `70-privacy`).
///
/// **Offered only when ``isOffered(arguments:)`` says so.** A DEBUG build shows it when launched with
/// ``launchArgument``; a Release build only while ``PremiumSet`` has a set to sell — none in 1.4.1, so
/// no user meets it yet (decision D1).
///
/// **Opened only by the user** — Settings' *See Premium* today, a later set's locked state tomorrow —
/// never at launch, after a pour or from any other surface (rule `70-privacy`).
struct PaywallView: View {

    /// Where the sheet was opened from — its `.sheet(item:)` selection (rule `50-views`). Each set
    /// adds the locked state it opens from.
    enum Entry: Identifiable, Hashable {
        case settings

        var id: Self { self }
    }

    /// DEBUG's opt-in (rule `85-testing`).
    nonisolated static let launchArgument = "-WaterBuddyPremium"

    /// Apple's standard licence, which an app without its own uses (spec §3.7).
    nonisolated static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")

    /// The owner's privacy policy. App Review asks every app for one inside it (spec §8, O1).
    nonisolated static let privacyPolicy = URL(string: "OWNER-PRIVACY-URL")

    /// The switch, as a pure function of the build, the arguments and the number of sets.
    nonisolated static func isOffered(debug: Bool, arguments: [String], sets: Int) -> Bool {
        debug ? arguments.contains(launchArgument) : sets > 0
    }

    /// The switch for this build (spec §3.5).
    nonisolated static func isOffered(arguments: [String]) -> Bool {
        #if DEBUG
        isOffered(debug: true, arguments: arguments, sets: PremiumSet.allCases.count)
        #else
        isOffered(debug: false, arguments: arguments, sets: PremiumSet.allCases.count)
        #endif
    }

    /// The switch for this process.
    nonisolated static var isOfferedHere: Bool {
        isOffered(arguments: ProcessInfo.processInfo.arguments)
    }

    /// How long the thank-you stays before the sheet closes.
    static let thanksPause: Duration = .seconds(1.2)

    let entry: Entry

    @Environment(PremiumStore.self) private var premium
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    /// The plan picked — the yearly when the sheet opens.
    @State private var chosen: PremiumAccess.Plan.Kind = .yearly

    /// Bumped by a pick, so the selection tick fires on the tap (rule `60-design-system`).
    @State private var picks = 0

    /// Bumped when the user's own purchase lands.
    @State private var purchases = 0

    var body: some View {
        ZStack {
            AuroraBackground()

            // Centred at every ordinary size, scrolling once the type outgrows the sheet
            // (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: PaywallStyle.sectionGap) {
                        Spacer(minLength: 8)
                        header
                        if let status = premium.state.status, status.isPremium {
                            held(status)
                        } else {
                            offer
                        }
                        footer
                        Spacer(minLength: 8)
                    }
                    .padding(.horizontal, PaywallStyle.margin)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        // Never swiped away mid-purchase: StoreKit's own sheet is over it, and the answer lands here.
        .interactiveDismissDisabled(premium.purchase == .buying)
        .sensoryFeedback(Haptics.select, trigger: picks)
        .sensoryFeedback(Haptics.confirm, trigger: purchases)
        .animation(Motion.settle, value: premium.plans)
        .animation(Motion.settle, value: premium.purchase)
        .task { await premium.prepare() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 10) {
            Text("WaterBuddy Premium", bundle: strings)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            // The promise, on its own line: Premium sells extras, never logging (`docs/ROADMAP.md` §1).
            Text("Logging water is free, always.", bundle: strings)
                .font(.headline)
                .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
                .multilineTextAlignment(.center)
        }
        .fixedSize(horizontal: false, vertical: true)
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
            VStack(spacing: PaywallStyle.planGap) {
                ForEach(plans) { plan in
                    planRow(plan)
                }
            }
            .glassGroup()

            if let plan = plans.first(where: { $0.kind == chosen }) {
                outcome
                buyButton(plan)
                Text(plan.terms(in: strings, locale: locale))
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(PaywallStyle.footnoteOpacity))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
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
                    .padding(.horizontal, 24)
                    .frame(minHeight: PaywallStyle.linkHeight)
                    .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
        }
        .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
    }

    /// One plan: its name over its price line, one button whose label is the name and whose value is
    /// the line, the selected trait on the one picked (rule `65-accessibility`).
    private func planRow(_ plan: PremiumAccess.Plan) -> some View {
        let isSelected = plan.kind == chosen
        let shape = RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous)

        return Button {
            guard !isSelected else { return }
            chosen = plan.kind
            picks += 1
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.name(in: strings))
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(plan.priceLine(in: strings, locale: locale))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, PaywallStyle.rowInset)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: PaywallStyle.rowHeight, alignment: .leading)
            .background { selectionMark(isSelected, in: shape) }
            .liquidGlass(in: shape, density: .frosted, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        .accessibilityLabel(plan.name(in: strings))
        .accessibilityValue(plan.priceLine(in: strings, locale: locale))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    /// What became of the last purchase, when there is something to say.
    @ViewBuilder
    private var outcome: some View {
        switch premium.purchase {
        case .pending: note("Waiting for approval.")
        case .failed: note("The purchase didn't go through.")
        case .bought: note("Thank you")
        case .idle, .buying: EmptyView()
        }
    }

    private func note(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// The screen's one primary surface (rule `60-design-system`).
    private func buyButton(_ plan: PremiumAccess.Plan) -> some View {
        Button {
            Task {
                await premium.buy(plan)
                guard premium.purchase == .bought else { return }
                purchases += 1
                try? await Task.sleep(for: Self.thanksPause)
                // Still bought after the pause — a re-check, not a promise (rule `43-concurrency`).
                if premium.purchase == .bought { dismiss() }
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

    private func held(_ status: PremiumAccess.Status) -> some View {
        VStack(spacing: 8) {
            Text("You have Premium.", bundle: strings)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
            if let line = status.line(in: strings, locale: locale) {
                Text(line)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            }
        }
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, minHeight: PaywallStyle.quietHeight)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Footer

    /// *Restore Purchases* while nothing is held, the two links always, and *Not now* (plan P9).
    private var footer: some View {
        VStack(spacing: 0) {
            if premium.state.status?.isPremium != true {
                Button {
                    Task { await premium.restore() }
                } label: {
                    footerLabel("Restore Purchases")
                }
                .buttonStyle(PressStyle())
            }
            if let terms = Self.termsOfUse {
                Link(destination: terms) { footerLabel("Terms of Use") }
            }
            if let privacy = Self.privacyPolicy {
                Link(destination: privacy) { footerLabel("Privacy Policy") }
            }
            Button {
                dismiss()
            } label: {
                footerLabel("Not now")
            }
            .buttonStyle(PressStyle())
        }
    }

    private func footerLabel(_ key: LocalizedStringKey) -> some View {
        Text(key, bundle: strings)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(PaywallStyle.textOpacity))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: PaywallStyle.linkHeight)
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

/// The paywall's measures. The two text opacities are the welcome's, measured on the same aurora,
/// and are measured on this sheet before they are recorded (plan P13, `docs/DESIGN.md`).
private enum PaywallStyle {
    static let margin: CGFloat = 24
    static let sectionGap: CGFloat = 22
    static let planGap: CGFloat = 12
    static let rowInset: CGFloat = 18
    /// Past the 56 a serving row takes, for two lines (rule `65-accessibility`).
    static let rowHeight: CGFloat = 64
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

  `WaterBuddy/SettingsView.swift`:
  - two properties after `@Environment(\.scenePhase) private var scenePhase`:

```swift
    @Environment(PremiumStore.self) private var premium

    /// The paywall, while it is open — its `.sheet(item:)` selection (rule `50-views`).
    @State private var paywall: PaywallView.Entry?
```

  - in the `VStack`, after `LanguageCard().arrives(arrived, order: 3).scrollDepth()`:

```swift
                    // Premium, last: the goal still leads. Drawn only where the paywall is offered,
                    // and only once the first read has answered (spec §3.6).
                    if PaywallView.isOfferedHere, premium.state != .checking {
                        PremiumCard { paywall = .settings }
                            .arrives(arrived, order: 4)
                            .scrollDepth()
                    }
```

  - the comment above `.padding(.bottom, 16)` — "The language card is the tallest on this screen and
    sits last, so without this its footnote rests under the floating tab bar" → "The last card — the
    language card, or Premium's where it is offered — would otherwise rest under the floating tab
    bar";
  - after `.task { await readSystemState() }`: `.sheet(item: $paywall) { entry in PaywallView(entry: entry) }`;
  - the card, after `LanguageCard`'s closing brace:

```swift
// MARK: - Premium

/// Premium's card: what it adds and the way in while nothing is held; the plan held, and Apple's
/// manage sheet for a subscription, once something is (spec §3.6).
private struct PremiumCard: View {

    @Environment(PremiumStore.self) private var premium
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// Opens the paywall.
    let open: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Premium", bundle: strings)
                .cardTitle()
                .padding(.bottom, 6)

            if let line = premium.state.status?.line(in: strings, locale: locale) {
                Text(line)
                    .cardNote()
                if holdsAYearly {
                    cardButton("Manage Subscription") {
                        Task { await premium.manage() }
                    }
                }
            } else {
                Text("Extras for the way you drink. Logging water stays free.", bundle: strings)
                    .cardNote()
                cardButton("See Premium", action: open)
            }
        }
        // `.frosted` and `.raised`, matching every sibling on this screen.
        .settingsCard()
    }

    private var holdsAYearly: Bool {
        if case .yearly? = premium.state.status { return true }
        return false
    }

    /// The reminders card's capsule — glass, not the primary surface: a purchase is not the screen's
    /// main action.
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
```

  - the `#Preview`'s last line → `return SettingsView().background { AuroraBackground() }.environment(manager).environment(PremiumStore(source: .silent()))`.

  `WaterBuddy/RootTabView.swift`, the `#Preview`'s last line →
  `return RootTabView().environment(manager).environment(PremiumStore(source: .silent()))`.

  `WaterBuddy/WaterBuddyApp.swift`:
  - after `private let manager: DataManager`:

```swift

    /// Premium's paid state, read from StoreKit and kept in memory only (``PremiumStore``).
    private let premium: PremiumStore
```

  - in `init()`, after `DataManager.prepareSharedStorage()` and before `#if DEBUG`:

```swift

        // Built before anything else, fresh start included, so its listener hears every transaction
        // from launch — a renewal, a refund, an approved Ask to Buy (spec §3.3). It reads StoreKit and
        // writes nothing.
        premium = PremiumStore()
```

  - `.environment(manager)` on `RootView()` → `.environment(manager)` then `.environment(premium)` on
    the next line;
  - in `.onChange(of: scenePhase)`, after `manager.refresh()`:

```swift

                // A purchase may have been refunded or renewed while the app was away.
                Task { await premium.refresh() }
```

  DocC: `WaterBuddy/HomeView.swift:198` "the one use of StoreKit in the product (rule `70-privacy`)" →
  "one of StoreKit's two uses in the product (rule `70-privacy`)"; any other sentence in
  `HomeView.swift` and `DataManager.swift` that calls the review request *the one use of StoreKit* —
  `grep -n 'one use of StoreKit' WaterBuddy/*.swift` — becomes *StoreKit, for the review request and
  for Premium*, the section's new name.

- [ ] **Step 6: Run it GREEN.** `grep -n 'OWNER-PRIVACY-URL' WaterBuddy/PaywallView.swift` prints
  nothing. `UNIT -only-testing:WaterBuddyTests/PaywallOfferTests` — 4 passed. The UI class again on
  *WaterBuddy Gate 27* (Step 4's command) — `Executed 2 tests, with 0 failures`. Then the whole unit
  suite once: `UNIT -only-testing:WaterBuddyTests` — expect the attribute grep's count, every test
  passed.

---

### Task 7: On the simulator, by hand — with the owner

**Files:** `WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme`; `docs/DESIGN.md`
(measurements, written in Task 9); scratch.

- [ ] **Step 1: Stage the code and tests by explicit path first**, so an Xcode rewrite (#50) cannot
  take them: `WaterBuddy/PremiumAccess.swift`, `WaterBuddy/PremiumSet.swift`,
  `WaterBuddy/PremiumStore.swift`, `WaterBuddy/PaywallView.swift`, `WaterBuddy/WaterBuddyApp.swift`,
  `WaterBuddy/SettingsView.swift`, `WaterBuddy/RootTabView.swift`, `WaterBuddy/HomeView.swift`,
  `WaterBuddy/DataManager.swift`, `WaterBuddy/Localizable.xcstrings`,
  `WaterBuddyTests/WaterBuddy.storekit`, `WaterBuddyTests/PremiumAccessTests.swift`,
  `WaterBuddyTests/PremiumStoreTests.swift`, `WaterBuddyTests/LocalizationTests.swift`,
  `WaterBuddyUITests/PremiumUITests.swift`.
- [ ] **Step 2: The owner, in Xcode** (P8): open the project; Edit Scheme → *WaterBuddy* → Run →
  Options → StoreKit Configuration → `WaterBuddy.storekit`; Run → Arguments → add
  `-WaterBuddyPremium YES`; run on *WaterBuddy Probe 27*.
- [ ] **Step 3: Walk it**, the session capturing each step with
  `xcrun simctl io 43E0B902-C6D5-48DD-B513-F22AF3BE9BEA screenshot "$SCRATCH/shots/<n>.png"` and
  reading every shot before the next step:
  1. Settings: the Premium card last, *See Premium*; the bottom of the stack clear of the tab bar.
  2. The paywall in English: title, promise, Yearly selected with *1 week free, then $19.99 a year*,
     Lifetime *$39.99, once*, *Start Free Trial*, the terms, *Restore Purchases*, both links, *Not now*.
  3. Lifetime picked: *Buy Lifetime* and its terms. Yearly again.
  4. *Start Free Trial*: StoreKit's sheet, confirmed → *Thank you*, the sheet closes; the card reads
     *Yearly, until …* with *Manage Subscription*; *Manage Subscription* opens Apple's sheet.
  5. Xcode → Debug → StoreKit → Manage Transactions: refund it → back in the app (Home Screen and
     back) the card reads free again.
  6. Ask to Buy on (the same window's settings), *Buy Lifetime* → *Waiting for approval.*; approve in
     the transaction manager with the sheet open → it turns to *You have Premium.* (Review Focus 2).
  7. Delete the transactions; *Restore Purchases* → nothing held, the paywall unchanged.
  8. The app's language → Русский, then O‘zbekcha (Settings → Language): the paywall in each — the
     trial's length in its own words, no English.
  9. VoiceOver (the simulator's Accessibility Inspector): each plan one element with its name, its
     price line and *Selected* on one; the terms read whole.
  10. Accessibility → Larger Text at the largest size: the sheet scrolls, nothing cut; Reduce
      Transparency on: the panes opaque.
- [ ] **Step 4: Measure the colour pairs** off the shots of step 2 — the price line (white 0.92) on
  its pane, the terms (white 0.88) and the footer labels (white 0.92) on the aurora, the promise on
  the aurora — by the method `docs/DESIGN.md` records for *Settings, measured*, at the light's
  brightest frame. Every pair holds 4.5:1. One that does not is raised to the lowest opacity that
  passes, measured again, and its token's comment updated — never a figure estimated from another.
- [ ] **Step 5: The owner closes Xcode.** Then:
  - `git diff -- WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme` — expect a
    `StoreKitConfigurationFileReference` and a `CommandLineArguments` block. Remove the arguments
    block with `Edit`, so only the StoreKit reference remains; record the path format Xcode wrote in
    the ledger.
  - `git diff --stat` over the tree — anything Xcode rewrote beyond #50's four is read and, with the
    owner's word, restored from the index.
  - One Release run without the argument, by the owner, from Xcode (Edit Scheme → Run → Build
    Configuration → Release, then back to Debug): no Premium card. The scheme's configuration back to
    Debug is checked in the diff.

---

### Task 8: The review, the gate, the warning comparison

- [ ] **Step 1: A fresh reviewer.** Stage the scheme's hunk with the code (`git add
  WaterBuddy.xcodeproj/xcshareddata/xcschemes/WaterBuddy.xcscheme`), so the review reads
  `git diff --cached`. A read-only subagent reviews it against the spec, P1–P13, the rules — the
  seven amended ones as typed in the working tree, with `20-state`, `25-shared-storage`,
  `60-design-system` and `75-diagnostics` — and the DocC of the types changed. Its brief includes the
  five Review Focus lines and: confirm `StoreKit` is imported in two files only, that nothing is
  written to any `UserDefaults`, and that no surface but Settings opens the paywall. Save its report
  to the ledger folder as it arrives. Check every finding against the code before acting on it; a fix
  goes through the task that owns the file, tests first.
- [ ] **Step 2: The gate.** Rule `85-testing`'s invocations on this machine's destinations, `uptime`
  before each, shut down by UDID between systems:
  1. Unit, *iPhone 17* (27.0): `UNIT -only-testing:WaterBuddyTests`. Expect the attribute grep's
     count (`grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'`),
     **733** by this plan.
  2. UI on *WaterBuddy Gate 27*, in chunks under the 600-second limit — `GoalSetupUITests` in two
     halves, then the rest:

```zsh
grep -oE "func test[A-Za-z0-9]+" WaterBuddyUITests/GoalSetupUITests.swift | sed 's/^func //' | sort > "$SCRATCH/goalsetup.txt"; N=$(wc -l < "$SCRATCH/goalsetup.txt"); H=$(( (N + 1) / 2 )); echo "$N $H"
FLAGS=$(sed -n "1,${H}p" "$SCRATCH/goalsetup.txt" | sed 's#^#-only-testing:WaterBuddyUITests/GoalSetupUITests/#' | tr '\n' ' '); xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
FLAGS=$(sed -n "$(( H + 1 )),${N}p" "$SCRATCH/goalsetup.txt" | sed 's#^#-only-testing:WaterBuddyUITests/GoalSetupUITests/#' | tr '\n' ' '); xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' ${=FLAGS} -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy -destination 'platform=iOS Simulator,OS=27.0,name=WaterBuddy Gate 27' -only-testing:WaterBuddyUITests -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests -skip-testing:WaterBuddyUITests/GoalSetupUITests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Executed|error:|failed" | tail -8
```

     Read each run's **executed** count; together, **71** with 1 skipped by design (69 + 2).
  3. The same three UI runs on *WaterBuddy Gate 26.5* (`OS=26.5`).
  4. Watch, *WaterBuddy Watch 27*:
     `xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO -collect-test-diagnostics never 2>&1 | grep -E "Test run with|✘" | tail -10`
     — 70.
  5. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension -destination 'platform=iOS Simulator,OS=27.0,name=iPhone 17' 2>&1 | grep -E "error:|BUILD" | tail -3`.
  6. `xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget -destination 'platform=watchOS Simulator,OS=27.0,name=WaterBuddy Watch 27' 2>&1 | grep -E "error:|BUILD" | tail -3`.
- [ ] **Step 3: The warning comparison**, from the staged index, the same four schemes as Task 0:

```bash
rm -rf "$SCRATCH/after" "$SCRATCH/after-dd"; git checkout-index -a --prefix="$SCRATCH/after/"
xcodebuild build-for-testing -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddy -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-app.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddyWidgetExtension -destination 'generic/platform=iOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-widget.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddyWatch -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-watch.log" 2>&1; echo "exit $?"
xcodebuild build -project "$SCRATCH/after/WaterBuddy.xcodeproj" -scheme WaterBuddyWatchWidget -destination 'generic/platform=watchOS Simulator' -derivedDataPath "$SCRATCH/after-dd" > "$SCRATCH/after-watchwidget.log" 2>&1; echo "exit $?"
for s in app widget watch watchwidget; do grep -E '^/.*: warning: ' "$SCRATCH/after-$s.log" | sed -E 's#^.*/after/##; s#^(Water[^:]+):[0-9]+:[0-9]+: #\1: #' | sort -u > "$SCRATCH/after-$s-messages.txt"; echo "$s new:"; comm -13 "$SCRATCH/base-$s-messages.txt" "$SCRATCH/after-$s-messages.txt"; echo "$s gone:"; comm -23 "$SCRATCH/base-$s-messages.txt" "$SCRATCH/after-$s-messages.txt"; done
```

  Expected: every `new:` list empty. A new line is fixed before reporting — through its task, tests
  first — or, if it cannot be, reported as a failure.

---

### Task 9: Records, docs — then stop

- [ ] `docs/AI_CONTEXT.md`:
  - a block at the head of *Current state* for 1.4.1, and a *Last updated* paragraph;
  - *Files on disk*: the four new app files, the three new test files, `WaterBuddy.storekit`, and the
    changed files' line counts and descriptions, each by `wc -l`;
  - the gate's results and counts from Task 8, by the attribute grep, and the warning comparison;
  - new known issues: (a) App Store Connect's steps, spec §7.4 1–5, before any release offers the
    paywall; (b) a sandbox purchase, restore and refund on a device, §7.4 6, joining 1.2.7's sweep;
    (c) O1 — no privacy policy link in the app outside the paywall (App Review 5.1.1(i)), the owner's
    to rule on; and anything Task 7 could not show.
- [ ] `docs/STATE.md`: a dated note where it lists what is stored — Premium's paid state is **not**
  stored, by decision D4: read from StoreKit, kept in memory, no key. Search the sheet for `StoreKit`,
  `review`, `keys` and `locale` first (`tasks/lessons.md`, 2026-10-21); change only what this moved.
- [ ] `docs/DESIGN.md`: the paywall's measured pairs from Task 7 Step 4, each with its figure.
- [ ] `docs/WIDGET.md`: a dated line — `DataManager.swift` changed in a comment; the contract did not.
- [ ] `docs/ROADMAP.md`: 1.4.1 built, gated and staged, hidden until a set exists; the owner's App
  Store Connect steps open.
- [ ] `CLAUDE.md`: its bullet is already typed (Task 2); check it again; the warning trail gains this
  item's measurement as `docs/AI_CONTEXT.md` gives it.
- [ ] `HISTORY.md` appended with `Edit`, anchored on its last lines. `tasks/lessons.md` only if the
  work earned a lesson.
- [ ] Before the readers, search every sheet and the known issues for the subject in plain words —
  "StoreKit", "Premium", "paywall", "purchase", "the one use" — and check every `File.swift:N` the
  sheets cite against the tree.
- [ ] **Two fresh readers** (read-only subagents) on the records, briefed by line range and pointed at
  the ledger, the gate's output, Task 7's shots and the saved review. Save each report as it arrives,
  check its findings against their primary source, and fix by deleting or by quoting the source.
- [ ] Stage by explicit path: Task 7 Step 1's fifteen, the scheme, this plan, `CLAUDE.md`,
  `docs/AI_CONTEXT.md`, `docs/STATE.md`, `docs/DESIGN.md`, `docs/WIDGET.md`, `docs/ROADMAP.md`,
  `HISTORY.md` (and `tasks/lessons.md` if touched). The spec was staged before this plan and is
  staged again with its amendments. The seven rule files stay unstaged. Write the git block last,
  from `git status --short` and `git diff --cached --name-status` run at that moment.
- [ ] **Stop.** Report:
  - what was built, and that no user can meet it until the first set;
  - what Task 1's probe found;
  - what Task 7 showed, with its shots, and what it could not;
  - the gate's counts and the warning comparison;
  - the rule wording waiting, unstaged;
  - the commit order: the roadmap amendment, the spec and this plan as `docs`; the code as
    `feat(app)`; the records as `docs`; the rules as `chore(claude)`.
