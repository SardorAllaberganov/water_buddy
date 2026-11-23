//
//  ReminderScheduleSheetTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 30/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

/// The schedule sheet's menus and words, and Settings' reset (spec `2026-10-30-coaching-design.md` §3.4).
@MainActor
struct ReminderScheduleSheetTests {

    private let english = Locale(identifier: "en_US")
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    /// Every pair the two hour menus offer, at every interval, is a schedule the plan accepts — so the sheet
    /// can never write one the model would read back as the standard schedule.
    @Test func theSheetsMenusOfferOnlySchedulesThePlanAccepts() {
        for every in ReminderPlan.Schedule.intervals {
            let firsts = ReminderScheduleSheet.firstHours(every: every)
            #expect(firsts.first == ReminderPlan.Schedule.earliest)
            for first in firsts {
                let base = ReminderPlan.Schedule.standard.with(every: every).with(first: first)
                #expect(base.first == first, "\(first) every \(every) was moved")
                let lasts = ReminderScheduleSheet.lastHours(for: base)
                #expect(!lasts.isEmpty)
                for last in lasts {
                    #expect(ReminderPlan.Schedule(first: first, last: last, every: every) != nil)
                    #expect(base.with(last: last).last == last)
                }
            }
        }
    }

    @Test func theDaysRunInTheLocalesOwnOrder() {
        #expect(ReminderScheduleSheet.weekdays(in: english) == [1, 2, 3, 4, 5, 6, 7])
        #expect(ReminderScheduleSheet.weekdays(in: Locale(identifier: "ru_RU")) == [2, 3, 4, 5, 6, 7, 1])
    }

    @Test func theSummaryNamesTheHoursAndTheInterval() throws {
        let strings = AppLanguage.english.bundle
        let nine = ReminderScheduleSheet.hourLabel(9, locale: english, calendar: utc)
        let twentyOne = ReminderScheduleSheet.hourLabel(21, locale: english, calendar: utc)
        #expect(nine.hasPrefix("9") && twentyOne.hasPrefix("9"), "\(nine), \(twentyOne)")

        let standard = ReminderScheduleSheet.summary(of: .standard, strings: strings, locale: english, calendar: utc)
        #expect(standard.hours == "\(nine) – \(twentyOne), every 2 hours")
        #expect(standard.spoken == "From \(nine) to \(twentyOne), every 2 hours")
        #expect(standard.quiet == nil)
        #expect(standard.spokenQuiet == nil)

        let hourly = try #require(ReminderPlan.Schedule(first: 9, last: 21, every: 1, quietWeekdays: [7, 1]))
        let summary = ReminderScheduleSheet.summary(of: hourly, strings: strings, locale: english, calendar: utc)
        #expect(summary.hours.hasSuffix(", every hour"))
        #expect(summary.quiet == "Not on Sun and Sat", "Sunday first, as the en_US week runs")
        // Spoken in full, as the sheet's discs are (spec `2026-10-31-finish-set-b-design.md` D5).
        #expect(summary.spokenQuiet == "Not on Sunday and Saturday")
    }

    /// The final review's Important 2: a tap on *Only when behind* opens the paywall only where it would turn
    /// the switch on without Premium. A lapsed user whose switch is still on turns it off for free, so the
    /// hint must not promise the paywall then.
    @Test func onlyAnOffSwitchWithoutPremiumOpensThePaywall() {
        #expect(SettingsView.behindTapOpensPaywall(gate: .locked, isOn: false))
        #expect(!SettingsView.behindTapOpensPaywall(gate: .locked, isOn: true), "turning off is free")
        #expect(!SettingsView.behindTapOpensPaywall(gate: .open, isOn: false))
        #expect(!SettingsView.behindTapOpensPaywall(gate: .open, isOn: true))
    }

    /// Review Focus 4 — after a lapse, the free way back to the standard schedule.
    @Test func theStandardResetIsOfferedOnlyToALockedCustomSchedule() throws {
        let custom = try #require(ReminderPlan.Schedule(first: 7, last: 22, every: 3))
        #expect(SettingsView.offersStandardReset(gate: .locked, schedule: custom))
        #expect(!SettingsView.offersStandardReset(gate: .locked, schedule: .standard))
        #expect(!SettingsView.offersStandardReset(gate: .open, schedule: custom), "the sheet has its own")
        #expect(!SettingsView.offersStandardReset(gate: .hidden, schedule: custom))
    }

    /// Review Focus 4: the free way back is offered to a locked holder whose Home is not the standard three.
    @Test func theStandardVesselsAreOfferedToALockedHolderOnly() throws {
        let standard = VesselLibrary.standard(amounts: [150, 250, 500])
        let mine = try #require(standard.adding(glyph: .flask, name: "Office", amount: 400, id: "o")?.puttingOnHome(id: "o", slot: 1))
        #expect(SettingsView.offersStandardVessels(gate: .locked, library: mine))
        #expect(!SettingsView.offersStandardVessels(gate: .open, library: mine), "a holder uses the library itself")
        #expect(!SettingsView.offersStandardVessels(gate: .hidden, library: mine))
        #expect(!SettingsView.offersStandardVessels(gate: .locked, library: standard))
    }

    /// Aurora is free for everyone — the way back after a lapse (D5); the others choose for Premium alone.
    @Test func auroraIsFreeAndTheOtherThemesOpenThePaywallWhereLocked() {
        for theme in AppTheme.allCases {
            #expect(!SettingsView.themeOpens(theme, gate: .open))
        }
        #expect(!SettingsView.themeOpens(.aurora, gate: .locked))
        #expect(AppTheme.allCases.dropFirst().allSatisfy { SettingsView.themeOpens($0, gate: .locked) })
    }

    @Test func theVesselsMenuRunsFromFiftyMillilitresToTwoLitres() {
        #expect(VesselSliders.range == 50...2_000)
        #expect(VesselSliders.step == 50)
    }
}
