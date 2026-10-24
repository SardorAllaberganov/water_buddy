//
//  InsightCopyTests.swift
//  WaterBuddyTests
//
//  Created by Sardor Allaberganov on 23/10/26.
//

import Foundation
import Testing
@testable import WaterBuddy

// MARK: - Fixtures

private let english = AppLanguage.english.bundle
private let russian = AppLanguage.russian.bundle
private let uzbek = AppLanguage.uzbek.bundle
private let en = Locale(identifier: "en")

private let onTheFirst = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 10, day: 11, hour: 13))!

/// One of every finding, with figures that group.
private let everyFinding: [WeekInsights.Finding] = [
    .weekendsLower(1_500),
    .weekdaysLower(1_500),
    .lessThanBefore(1_500),
    .shortOfGoal(1_500),
    .everyDayMet,
    .everyWeekdayMet,
    .everyWeekendDayMet,
    .moreDaysMet(5, before: 3),
    .moreThanBefore(1_500),
    .earlierStart(minutes: 40),
    .daysMet(5, of: 7),
    .emptyDays(2),
    .laterStart(minutes: 40),
    .halfBy(onTheFirst),
    .average(1_500, goal: 2_000),
]

private let everyWhen: [WeekInsights.When] = [.weekendDays, .weekdays, .each(.morning), .each(.afternoon), .each(.evening)]

// MARK: - The words

/// The one mapping from a finding to a sentence (spec `2026-10-23-insights-design.md` §3.5, §3.9).
/// Not `@MainActor`, on purpose: a canary for ``InsightCopy`` staying a pure, `Foundation`-only value
/// (rule `43-concurrency`). Fix the declaration it reads, never this suite.
struct InsightCopyTests {

    /// Every assertion below is vacuous against a bundle that silently fell back to `Bundle.main`.
    @Test func theThreeLanguagesResolve() {
        #expect(english.bundleURL.lastPathComponent == "en.lproj")
        #expect(russian.bundleURL.lastPathComponent == "ru.lproj")
        #expect(uzbek.bundleURL.lastPathComponent == "uz.lproj")
    }

    @Test func theEnglishSentencesReadAsWritten() {
        let cases: [(WeekInsights.Finding, String)] = [
            (.weekendsLower(1_500), "Weekends ran 1,500 ml a day below weekdays."),
            (.weekdaysLower(700), "Weekdays ran 700 ml a day below weekends."),
            (.lessThanBefore(300), "300 ml a day less than the week before."),
            (.shortOfGoal(500), "An average day was 500 ml short of your goal."),
            (.everyDayMet, "Every day on goal."),
            (.everyWeekdayMet, "Your goal on every weekday."),
            (.everyWeekendDayMet, "Your goal on every weekend day."),
            (.moreDaysMet(5, before: 3), "Goal met on 5 days, up from 3."),
            (.moreDaysMet(1, before: 0), "Goal met on 1 day, up from 0."),
            (.moreThanBefore(1_200), "1,200 ml a day more than the week before."),
            (.earlierStart(minutes: 40), "Your first drink came 40 minutes earlier than the week before."),
            (.daysMet(5, of: 7), "5 of 7 days on goal"),
            (.emptyDays(1), "Nothing was logged on 1 day."),
            (.emptyDays(2), "Nothing was logged on 2 days."),
            (.laterStart(minutes: 60), "Your first drink came 60 minutes later than the week before."),
            (.average(2_050, goal: 2_000), "An average day: 2,050 ml, against a goal of 2,000 ml."),
        ]
        for (finding, sentence) in cases {
            #expect(InsightCopy.sentence(for: finding, in: english, locale: en) == sentence)
        }
    }

    /// Through the phone's own 12- or 24-hour form, as every time in History.
    @Test func theHalfWayHourReadsAsATimeOfDay() {
        let time = onTheFirst.formatted(.dateTime.hour().minute().locale(en))
        #expect(InsightCopy.sentence(for: .halfBy(onTheFirst), in: english, locale: en)
                == "Half your water came before \(time).")
    }

    @Test func eachSuggestionReadsAsWritten() {
        let cases: [(WeekInsights.When, String)] = [
            (.weekendDays, "Another 1,000 ml on each weekend day would help close the gap."),
            (.weekdays, "Another 1,000 ml on each weekday would help close the gap."),
            (.each(.morning), "Another 1,000 ml each morning would help close the gap."),
            (.each(.afternoon), "Another 1,000 ml each afternoon would help close the gap."),
            (.each(.evening), "Another 1,000 ml each evening would help close the gap."),
        ]
        for (when, sentence) in cases {
            let suggestion = WeekInsights.Suggestion(gap: 900, when: when)
            #expect(InsightCopy.suggestion(suggestion, amount: 1_000, in: english, locale: en) == sentence)
        }
    }

    @Test func everySentenceIsTranslatedWithItsFiguresGrouped() {
        for (bundle, code) in [(russian, "ru"), (uzbek, "uz")] {
            let locale = Locale(identifier: code)
            let grouped = 1_500.formatted(.number.locale(locale))
            for finding in everyFinding {
                let translated = InsightCopy.sentence(for: finding, in: bundle, locale: locale)
                #expect(translated != InsightCopy.sentence(for: finding, in: english, locale: en), "\(code): \(finding) is not translated")
                #expect(!translated.contains("%"), "\(code): \(finding) left a specifier")
                if case .weekendsLower = finding {
                    #expect(translated.contains(grouped), "\(code): the figure is not grouped")
                }
            }
            for when in everyWhen {
                let suggestion = WeekInsights.Suggestion(gap: 1_500, when: when)
                let translated = InsightCopy.suggestion(suggestion, amount: 1_500, in: bundle, locale: locale)
                #expect(translated != InsightCopy.suggestion(suggestion, amount: 1_500, in: english, locale: en))
                #expect(translated.contains(grouped), "\(code): \(when)'s figure is not grouped")
            }
        }
    }

    @Test func aShortfallsPageCarriesItsSuggestionAndNamesTheVessel() {
        let content = WeekInsights.Content(
            oneThing: .weekendsLower(1_500),
            suggestion: WeekInsights.Suggestion(gap: 300, when: .weekendDays),
            detail: nil,
            working: .everyWeekdayMet,
            worthKnowing: .emptyDays(2)
        )
        let page = InsightCopy.page(for: content, vessels: [200, 250, 750], in: english, locale: en)
        #expect(page.oneThing == "Weekends ran 1,500 ml a day below weekdays.")
        // 250 is nearest 300: the Glass.
        #expect(page.detail == "Another 250 ml on each weekend day would help close the gap.")
        #expect(page.working == "Your goal on every weekday.")
        #expect(page.worthKnowing == "Nothing was logged on 2 days.")
        #expect(page.vessel == "Glass")
    }

    @Test func anImprovementsPageCarriesTheAverageAndNoVessel() {
        let content = WeekInsights.Content(
            oneThing: .everyDayMet,
            suggestion: nil,
            detail: .average(2_200, goal: 2_000),
            working: nil,
            worthKnowing: nil
        )
        let page = InsightCopy.page(for: content, vessels: [200, 250, 750], in: english, locale: en)
        #expect(page.oneThing == "Every day on goal.")
        #expect(page.detail == "An average day: 2,200 ml, against a goal of 2,000 ml.")
        #expect(page.working == nil)
        #expect(page.worthKnowing == nil)
        #expect(page.vessel == nil)
    }
}

// MARK: - The model's part

/// Every call `write` makes, counted.
@MainActor
private final class Calls {
    var count = 0
}

private func page(
    _ oneThing: String,
    _ detail: String? = nil,
    _ working: String? = nil,
    _ worthKnowing: String? = nil,
    vessel: String? = nil
) -> InsightCopy.Page {
    InsightCopy.Page(oneThing: oneThing, detail: detail, working: working, worthKnowing: worthKnowing, vessel: vessel)
}

private let facts = page(
    "Weekends ran 1,500 ml a day below weekdays.",
    "Another 250 ml on each weekend day would help close the gap.",
    "Your goal on every weekday.",
    "Half your water came before 1 PM.",
    vessel: "Glass"
)

private let goodNote = page(
    "Your weekends came in 1,500 ml a day under your weekdays.",
    "A Glass of 250 ml more on each weekend day would help.",
    "You reached your goal every weekday.",
    "By 1 PM, half your water was in."
)

/// The writer's own decisions (spec §3.5), with the model replaced by `Source` closures — no test
/// reaches Apple's model (rule `85-testing`).
@MainActor
struct InsightWriterTests {

    // MARK: What is accepted

    @Test func aNoteWithOnlyTheFactsFiguresIsAccepted() {
        #expect(InsightWriter.accepts(goodNote, for: facts))
    }

    @Test func aFigureTheFactsDoNotHaveIsDeclined() {
        let invented = page(goodNote.oneThing.replacingOccurrences(of: "1,500", with: "1,600"),
                            goodNote.detail, goodNote.working, goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(invented, for: facts))

        let extra = page(goodNote.oneThing, goodNote.detail, "You reached your goal on 5 weekdays.", goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(extra, for: facts))
    }

    /// Each part is checked against its own fact: the headline's 1,500 moved into the suggestion would
    /// advise six times the amount the app chose (the final review's I1).
    @Test func aFigureMovedBetweenPartsIsDeclined() {
        let moved = page(goodNote.oneThing, "Add 1,500 ml on each weekend day to close the gap.", goodNote.working, goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(moved, for: facts))
    }

    /// A quantity spelled out carries no digit, and is a figure all the same.
    @Test func aSpelledNumberTheFactLacksIsDeclined() {
        let spelled = page(goodNote.oneThing, goodNote.detail, "You reached your goal on all five weekdays.", goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(spelled, for: facts))
        let doubled = page(goodNote.oneThing, "Twice the water on each weekend day would help.", goodNote.working, goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(doubled, for: facts))
    }

    /// The model is never told the locale's weekend: *Saturday and Sunday* is wrong where Friday is off.
    @Test func aWeekdayTheFactLacksIsDeclined() {
        let named = page(goodNote.oneThing, "A Glass of 250 ml more on Saturday and Sunday would help.", goodNote.working, goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(named, for: facts))
    }

    /// A time or a decimal is one figure: *1:30* is not *1* and *30*, nor *1.5* a *1* and a *5* — even
    /// where the facts hold each digit on its own.
    @Test func aTimeOrADecimalIsReadWhole() {
        let timed = page("Goal met on 5 days, up from 1.", nil, nil, "Your first drink came 30 minutes later than the week before.")
        #expect(!InsightWriter.accepts(page("You met your goal on 5 days, up from 1.", nil, nil, "Your first drink came at 1:30."), for: timed))
        #expect(!InsightWriter.accepts(page("Goal met on 1.5 days, up from 5.", nil, nil, "Your first drink came 30 minutes later."), for: timed))
    }

    @Test func aDigitOutsideASCIIIsDeclined() {
        let arabic = page("Your weekends came in ١٥٠٠ ml a day under your weekdays.", goodNote.detail, goodNote.working, goodNote.worthKnowing)
        #expect(!InsightWriter.accepts(arabic, for: facts))
    }

    @Test func aGroupedAndAnUngroupedFigureAreOneFigure() {
        let ungrouped = page("Weekends ran 1500 ml a day below weekdays.", goodNote.detail, goodNote.working, goodNote.worthKnowing)
        #expect(InsightWriter.accepts(ungrouped, for: facts))
    }

    @Test func aNoteMissingAPartIsDeclined() {
        #expect(!InsightWriter.accepts(page(goodNote.oneThing, goodNote.detail, "", goodNote.worthKnowing), for: facts))
        #expect(!InsightWriter.accepts(page(goodNote.oneThing, goodNote.detail, "   ", goodNote.worthKnowing), for: facts))
        #expect(!InsightWriter.accepts(page(goodNote.oneThing, nil, goodNote.working, goodNote.worthKnowing), for: facts))
    }

    @Test func aPartLongerThanTwoHundredCharactersIsDeclined() {
        let long = String(repeating: "a", count: 201)
        #expect(!InsightWriter.accepts(page(long, goodNote.detail, goodNote.working, goodNote.worthKnowing), for: facts))
        let enough = String(repeating: "a", count: 200)
        #expect(InsightWriter.accepts(page(enough, goodNote.detail, goodNote.working, goodNote.worthKnowing), for: facts))
    }

    /// A part the facts do not have is not the model's to add, and is never drawn.
    @Test func aPartTheFactsLackIsIgnored() {
        let short = page("Every day on goal.")
        #expect(InsightWriter.accepts(page("You met your goal every day.", "Something about 999.", "x", "y"), for: short))
    }

    // MARK: When it asks

    @Test func anUnavailableModelIsNeverAsked() async {
        let calls = Calls()
        let writer = InsightWriter(source: .init(isAvailable: { false }, write: { _ in calls.count += 1; return goodNote }))
        await writer.write(facts, language: .english)
        #expect(calls.count == 0)
        #expect(writer.note(for: facts) == nil)
    }

    /// The model speaks no Russian or Uzbek: a page in either is never handed to it.
    @Test func aPageNotInEnglishIsNeverHandedToTheModel() async {
        let calls = Calls()
        let writer = InsightWriter(source: .init(isAvailable: { true }, write: { _ in calls.count += 1; return goodNote }))
        await writer.write(facts, language: .russian)
        await writer.write(facts, language: .uzbek)
        #expect(calls.count == 0)
    }

    /// A busy or not-yet-ready model is asked again on the next visit, not declined for the run (the
    /// final review's M3).
    @Test func aPassingFailureIsAskedAgain() async {
        let calls = Calls()
        let writer = InsightWriter(source: .init(isAvailable: { true }, write: { _ in
            calls.count += 1
            if calls.count == 1 { throw InsightWriter.Retry() }
            return goodNote
        }))

        await writer.write(facts, language: .english)
        #expect(writer.note(for: facts) == nil)
        await writer.write(facts, language: .english)

        #expect(calls.count == 2)
        #expect(writer.note(for: facts) != nil)
    }

    @Test func anAcceptedNoteIsKeptWithOnlyTheFactsPartsAndNotAskedForAgain() async {
        let calls = Calls()
        let short = page("Every day on goal.")
        let answer = page("You met your goal every day.", "Extra.", "Extra.", "Extra.", vessel: "Bottle")
        let writer = InsightWriter(source: .init(isAvailable: { true }, write: { _ in calls.count += 1; return answer }))

        await writer.write(short, language: .english)
        await writer.write(short, language: .english)

        #expect(calls.count == 1)
        #expect(writer.note(for: short) == page("You met your goal every day."))
        #expect(!writer.isWriting(short))
    }

    @Test func aDeclinedNoteIsNotAskedForAgain() async {
        let calls = Calls()
        let invented = page("Weekends ran 9,999 ml a day below weekdays.", goodNote.detail, goodNote.working, goodNote.worthKnowing)
        let writer = InsightWriter(source: .init(isAvailable: { true }, write: { _ in calls.count += 1; return invented }))

        await writer.write(facts, language: .english)
        await writer.write(facts, language: .english)

        #expect(calls.count == 1)
        #expect(writer.note(for: facts) == nil)
    }

    @Test func aFailureIsDeclined() async {
        struct Refused: Error {}
        let calls = Calls()
        let writer = InsightWriter(source: .init(isAvailable: { true }, write: { _ in calls.count += 1; throw Refused() }))

        await writer.write(facts, language: .english)
        await writer.write(facts, language: .english)

        #expect(calls.count == 1)
        #expect(writer.note(for: facts) == nil)
    }

    @Test func onlyEnglishIsHandedToTheModel() {
        #expect(InsightWriter.speaksEnglish(.english))
        #expect(!InsightWriter.speaksEnglish(.russian))
        #expect(!InsightWriter.speaksEnglish(.uzbek))
        #expect(InsightWriter.speaksEnglish(.system) == (Bundle.main.preferredLocalizations.first == "en"))
    }

    @Test func thePromptCarriesTheFactsAndNothingElse() {
        let prompt = InsightWriter.prompt(for: facts)
        for sentence in [facts.oneThing, facts.detail, facts.working, facts.worthKnowing].compactMap({ $0 }) {
            #expect(prompt.contains(sentence))
        }
        #expect(prompt.contains("Glass"))

        let short = InsightWriter.prompt(for: page("Every day on goal."))
        #expect(short.contains("Every day on goal."))
        #expect(!short.contains("What is working"))
        #expect(!short.contains("Worth knowing"))
    }

    @Test func thePreviewsSourceIsNeverAvailable() {
        #expect(!InsightWriter.Source.silent().isAvailable())
    }
}
