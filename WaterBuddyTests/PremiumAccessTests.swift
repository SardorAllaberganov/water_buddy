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
