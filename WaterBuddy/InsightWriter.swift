//
//  InsightWriter.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 23/10/26.
//

import Foundation
import FoundationModels
import Observation

/// Rewords a week's insights with Apple's on-device model — the one file that imports
/// `FoundationModels` (rule `70-privacy`, spec `2026-10-23-insights-design.md` §3.5).
///
/// **The app decides; the model only words it.** It is handed the app's own English sentences
/// (``InsightCopy/Page``) — what the page would draw anyway — and the suggested vessel's name, and
/// nothing else: never a row, a timestamp, the goal history, the streak or the user's language. Its note
/// is taken only when ``accepts(_:for:)`` passes: every part present and short, and **every figure in a
/// part one its own fact already had** — digits read whole, quantities, units and days in words too.
/// Anything else is declined and the app's sentences stand. What the check cannot read — a figure
/// phrased some way it does not know — is why the footer names who wrote the words.
///
/// **On the phone, and only Apple's.** ``Source/live()`` uses `SystemLanguageModel.default` and nothing
/// else — never Private Cloud Compute, never another provider's model (the owner's ruling, roadmap
/// 1.4.12). It speaks English among WaterBuddy's three languages, and only English is ever handed to it
/// (``speaksEnglish(_:main:)``); measured on 2026-10-23, it supports neither Russian nor Uzbek.
///
/// **Kept in memory, never stored.** A note is written once per run of the app for one week's facts, and
/// a decline is remembered for the run too, so a refused week is not asked for again on every visit.
/// Greedy sampling asks for the single most likely wording, so the same facts should read the same
/// after a relaunch. Nothing here writes either store.
///
/// **The model only through ``Source``**, a struct of closures built by ``Source/live()`` —
/// `PremiumStore.Source`'s shape — so every decision here is testable without the model (rule
/// `43-concurrency`). App-only; the widget and the watch never compile it.
@MainActor
@Observable
final class InsightWriter {

    /// Every way the model is reached. Main-actor, as `PremiumStore.Source` is: only the writer calls
    /// these.
    struct Source {
        /// Whether Apple's model can write here, now, in English.
        var isAvailable: () -> Bool
        /// The model's note for the facts, or a throw.
        var write: (_ facts: InsightCopy.Page) async throws -> InsightCopy.Page
    }

    /// The longest a part of a note may be — the panes are sized for a sentence or two.
    nonisolated static let longestPart = 200

    /// Accepted notes, by the facts they reword.
    private(set) var notes: [InsightCopy.Page: InsightCopy.Page] = [:]

    /// The facts a note is being written for, so the page can say *Writing…*.
    private(set) var writing: Set<InsightCopy.Page> = []

    /// Facts whose note was declined or failed this run — never asked for again until the app relaunches.
    @ObservationIgnored private var declined: Set<InsightCopy.Page> = []

    @ObservationIgnored private let source: Source

    init(source: Source) {
        self.source = source
    }

    /// Apple's model itself (``Source/live()``).
    convenience init() {
        self.init(source: .live())
    }

    /// The accepted note for `facts`, if one has been written this run.
    func note(for facts: InsightCopy.Page) -> InsightCopy.Page? {
        notes[facts]
    }

    func isWriting(_ facts: InsightCopy.Page) -> Bool {
        writing.contains(facts)
    }

    /// Asks the model for a note on `facts`, unless one is kept, was declined, is being written, the page
    /// is not in English (``speaksEnglish(_:main:)``) or the model is not available. Called from the page's
    /// `.task(id:)`; a cancelled task declines nothing, so the next visit may ask again.
    func write(_ facts: InsightCopy.Page, language: AppLanguage) async {
        guard Self.speaksEnglish(language), notes[facts] == nil, !declined.contains(facts), !writing.contains(facts),
              source.isAvailable()
        else { return }
        writing.insert(facts)
        defer { writing.remove(facts) }
        do {
            let note = try await source.write(facts)
            guard Self.accepts(note, for: facts) else {
                declined.insert(facts)
                return
            }
            notes[facts] = Self.trimmed(note, to: facts)
        } catch is CancellationError {
            return
        } catch is Retry {
            // Busy or not yet ready: the next visit asks again (the final review's M3).
            return
        } catch where Task.isCancelled {
            // A cancellation the model reports as its own error is still a cancellation.
            return
        } catch {
            declined.insert(facts)
        }
    }

    /// Whether `note` may stand in for `facts`: every part the facts have is present, not blank and at
    /// most ``longestPart`` characters, and says no figure **its own fact** does not — a part the facts lack
    /// is ignored, never drawn (spec §3.5).
    ///
    /// **Part by part**, never against the facts pooled: pooled, the headline's *1,500* moved into the
    /// suggestion passed, and the page advised six times the amount the app chose (the final review's I1).
    /// A figure is a run of digits read whole — *1,500* and *1500* are one, *1:30* and *1.5* are not *1*
    /// and *30* or *1* and *5* — and a digit outside ASCII is refused outright. A quantity, a unit or a day
    /// spelled in words is a figure too (``statedWords``): the model is never told the locale's weekend,
    /// so *Saturday and Sunday* would be wrong where Friday is off.
    nonisolated static func accepts(_ note: InsightCopy.Page, for facts: InsightCopy.Page) -> Bool {
        let pairs: [(String?, String?)] = [
            (note.oneThing, facts.oneThing),
            (note.detail, facts.detail),
            (note.working, facts.working),
            (note.worthKnowing, facts.worthKnowing),
        ]
        for (written, fact) in pairs {
            guard let fact else { continue }
            guard let written,
                  !written.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  written.count <= longestPart,
                  !written.contains(where: { $0.isNumber && !$0.isASCII }),
                  figures(in: written).isSubset(of: figures(in: fact)),
                  stated(in: written).isSubset(of: stated(in: fact))
            else { return false }
        }
        return true
    }

    /// Whether the app's strings are English, the one language of WaterBuddy's three the model speaks:
    /// *English* chosen, or *Follow device* on a phone whose localisation of this app is English.
    nonisolated static func speaksEnglish(_ language: AppLanguage, main: Bundle = .main) -> Bool {
        switch language {
        case .english: true
        case .system: main.preferredLocalizations.first == "en"
        case .russian, .uzbek: false
        }
    }

    /// What the model is asked: the facts, a line each, and the vessel's name — nothing else.
    nonisolated static func prompt(for facts: InsightCopy.Page) -> String {
        var lines = ["The one thing: \(facts.oneThing)"]
        if let detail = facts.detail { lines.append("Detail: \(detail)") }
        if let working = facts.working { lines.append("What is working: \(working)") }
        if let worthKnowing = facts.worthKnowing { lines.append("Worth knowing: \(worthKnowing)") }
        if let vessel = facts.vessel { lines.append("The suggested vessel is called: \(vessel)") }
        return lines.joined(separator: "\n")
    }

    /// How the model is told to write.
    nonisolated static let instructions = """
        You reword short facts about how someone drank water last week into a brief, warm note for them. \
        Rewrite each fact you are given as one short, plain sentence, speaking to the reader as "you". \
        Keep every number, time and amount exactly as given, and add none. \
        Say nothing about health, medicine, illness, dehydration or the body. \
        Give no advice beyond the suggestion in the facts. \
        Leave a part empty when no fact is given for it. Write in English.
        """

    /// Words that state a quantity, a unit or a day — a figure with no digit in it. English only, the one
    /// language the model is handed.
    nonisolated static let statedWords: Set<String> = [
        "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve",
        "dozen", "hundred", "thousand", "half", "once", "twice", "double", "triple",
        "litre", "litres", "liter", "liters", "ounce", "ounces", "oz", "percent",
        "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday",
    ]

    /// Every figure in `text`, each read whole and spelled as its digits and its `.` or `:` — the grouping
    /// separators dropped, so *1,500* and *1500* are one figure and *1:30* is not *1*.
    nonisolated private static func figures(in text: String) -> Set<String> {
        Set(text.matches(of: /[0-9]+(?:[,\u{00A0}\u{202F}\u{2009}][0-9]{3})*(?:[.:][0-9]+)?/).map { match in
            String(match.output.filter { $0.isASCII && ($0.isNumber || $0 == "." || $0 == ":") })
        })
    }

    /// The ``statedWords`` in `text`, lower-cased.
    nonisolated private static func stated(in text: String) -> Set<String> {
        Set(text.lowercased().split { !$0.isLetter }.map(String.init).filter(statedWords.contains))
    }

    /// `note` with only the parts `facts` has, and no vessel — what the page draws.
    nonisolated private static func trimmed(_ note: InsightCopy.Page, to facts: InsightCopy.Page) -> InsightCopy.Page {
        InsightCopy.Page(
            oneThing: note.oneThing,
            detail: facts.detail == nil ? nil : note.detail,
            working: facts.working == nil ? nil : note.working,
            worthKnowing: facts.worthKnowing == nil ? nil : note.worthKnowing,
            vessel: nil
        )
    }
}

extension InsightWriter.Source {

    /// Apple's on-device model, and nothing else. Every closure reaches it in its own body; nothing from
    /// `FoundationModels` is stored (rule `43-concurrency`). Below iOS 26 it is never available.
    static func live() -> Self {
        Self(
            isAvailable: {
                guard #available(iOS 26.0, *) else { return false }
                let model = SystemLanguageModel.default
                return model.availability == .available && model.supportsLocale(Locale(identifier: "en"))
            },
            write: { facts in
                guard #available(iOS 26.0, *) else { throw InsightWriter.Unavailable() }
                let session = LanguageModelSession(model: SystemLanguageModel.default, instructions: InsightWriter.instructions)
                do {
                    let response = try await session.respond(
                        to: InsightWriter.prompt(for: facts),
                        generating: WrittenNote.self,
                        // The single most likely wording, so one week's facts read one way (spec §3.5).
                        options: GenerationOptions(samplingMode: .greedy)
                    )
                    return response.content.page
                } catch let error as LanguageModelSession.GenerationError {
                    // A busy model, or one still downloading, may write on the next visit; anything else
                    // — a refusal, a guardrail, a decoding failure — is declined for the run.
                    switch error {
                    case .rateLimited, .concurrentRequests, .assetsUnavailable: throw InsightWriter.Retry()
                    default: throw error
                    }
                }
            }
        )
    }

    /// A source that is never available and reaches no model — for a `#Preview` and the tests.
    static func silent() -> Self {
        Self(isAvailable: { false }, write: { _ in throw InsightWriter.Unavailable() })
    }
}

extension InsightWriter {

    /// The model could not be reached here.
    nonisolated struct Unavailable: Error {}

    /// The model was busy or not yet ready: the facts are asked for again on the next visit rather than
    /// declined for the run.
    nonisolated struct Retry: Error {}
}

/// The note the model writes, part by part — the shape guided generation fills.
@available(iOS 26.0, *)
@Generable
nonisolated private struct WrittenNote {
    @Guide(description: "The one thing, reworded as one short sentence.")
    let oneThing: String
    @Guide(description: "The detail, reworded as one short sentence; empty when no detail is given.")
    let detail: String
    @Guide(description: "What is working, reworded as one short sentence; empty when none is given.")
    let working: String
    @Guide(description: "Worth knowing, reworded as one short sentence; empty when none is given.")
    let worthKnowing: String

    var page: InsightCopy.Page {
        InsightCopy.Page(oneThing: oneThing, detail: detail, working: working, worthKnowing: worthKnowing, vessel: nil)
    }
}
