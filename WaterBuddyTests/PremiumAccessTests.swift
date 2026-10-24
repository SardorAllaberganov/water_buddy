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

private func monthly(expires: Date?, revoked: Date? = nil) -> PremiumAccess.Entitlement {
    PremiumAccess.Entitlement(productID: PremiumAccess.monthlyID, expires: expires, revoked: revoked)
}

/// A price as StoreKit gives it — from a string, so `2.99` is not a binary approximation.
private func price(_ text: String) -> Decimal {
    Decimal(string: text)!
}

// MARK: - The decision

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
    PremiumAccess.Plan(id: PremiumAccess.yearlyID, kind: .yearly, price: "$19.99", amount: price("19.99"), trial: trial)
}
private let week = PremiumAccess.Plan.Period(value: 1, unit: .week)
private let lifetimePlan = PremiumAccess.Plan(id: PremiumAccess.lifetimeID, kind: .lifetime, price: "$39.99", amount: price("39.99"), trial: nil)
private let monthlyPlan = PremiumAccess.Plan(id: PremiumAccess.monthlyID, kind: .monthly, price: "$2.99", amount: price("2.99"), trial: nil)

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
        #expect(monthlyPlan.period(in: strings) == "a month")
        #expect(monthlyPlan.note(in: strings, locale: en) == "Cancel any time")
        #expect(yearlyPlan(trial: week).period(in: strings) == "a year")
        #expect(yearlyPlan(trial: week).savingLine(in: strings, locale: en, saving: 0.44) == "save 44%")
        #expect(yearlyPlan(trial: week).savingLine(in: strings, locale: en, saving: nil) == nil)
        #expect(monthlyPlan.savingLine(in: strings, locale: en, saving: 0.44) == nil)
        #expect(lifetimePlan.savingLine(in: strings, locale: en, saving: 0.44) == nil)
        #expect(yearlyPlan(trial: week).note(in: strings, locale: en) == "1 week free")
        #expect(yearlyPlan(trial: nil).note(in: strings, locale: en) == nil)
        #expect(lifetimePlan.period(in: strings) == "once")
        #expect(lifetimePlan.note(in: strings, locale: en) == "Yours for good")
    }

    @Test(arguments: [("ru", "в месяц", "1 неделя бесплатно"), ("uz", "Oyiga", "1 hafta bepul")])
    func theNewLinesReadInTheirOwnLanguage(code: String, perMonth: String, freeWeek: String) {
        let locale = Locale(identifier: code)
        #expect(monthlyPlan.priceLine(in: table(code), locale: locale).contains(perMonth))
        #expect(yearlyPlan(trial: week).note(in: table(code), locale: locale) == freeWeek)
        let saving = yearlyPlan(trial: week).savingLine(in: table(code), locale: locale, saving: 0.44) ?? ""
        #expect(saving.contains("44"), "\(code): \(saving)")
        #expect(!saving.contains("save"), "\(code) fell back to English: \(saving)")
    }

    /// Step 1's final review, I2 (Review Focus 2): a yearly that saves nothing claims nothing.
    @Test func aYearlyThatSavesNothingIsNotMarkedBestValue() {
        #expect(yearlyPlan(trial: week).showsBestValue(saving: 0.44))
        #expect(!yearlyPlan(trial: week).showsBestValue(saving: nil))
        #expect(!monthlyPlan.showsBestValue(saving: 0.44))
        #expect(!lifetimePlan.showsBestValue(saving: 0.44))
    }

    /// Plan P4: a length in a button would need another case in Russian.
    @Test(arguments: ["en", "ru", "uz"])
    func theButtonsNameNoLength(code: String) {
        for plan in [monthlyPlan, yearlyPlan(trial: week), yearlyPlan(trial: nil), lifetimePlan] {
            let action = plan.action(in: table(code))
            #expect(!action.isEmpty)
            #expect(!action.contains { $0.isNumber }, "\(code): \(action)")
        }
    }
}

// MARK: - The switch

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

    /// Set A on sale is not the paywall offered: a Release build still waits for the privacy policy's
    /// address (#159), so the token can never ship as a live link.
    @Test func setAOnSaleStillWaitsForThePrivacyLink() {
        #expect(!PaywallView.isOffered(debug: false, arguments: [], setsOnSale: PremiumSet.onSale.count,
                                       privacyPolicy: URL(string: "OWNER-PRIVACY-URL")))
        #expect(PaywallView.shownSets(debug: false) == [.understand])
    }

    @Test func theLinksAreApplesTermsAndAPageOfOurs() {
        #expect(PaywallView.termsOfUse?.absoluteString == "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
        #expect(PaywallView.privacyPolicy?.scheme == "https")
    }
}

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
