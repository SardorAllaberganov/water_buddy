//
//  Arrival.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 11/10/26.
//

import SwiftUI

/// How the first page's content settles into place when the app opens.
///
/// The page the app opens on has nowhere to slide in from, so under its title each section
/// rises a little and fades in, a moment after the one above. The title is not part of it:
/// every page opens with ``ScreenHeader`` in one place, already whole.
///
/// **A page that slides in does not settle: it is whole as it comes.** For one build this was
/// the whole of a change of tab — the page changed in a single frame and its sections rose
/// 10 pt under a fade — and the owner, holding that build on a phone, saw the screen "just
/// appear". For the next it ran on top of the slide, and the page that crossed the screen was
/// a header over sections still fading in: at half strength with two thirds of the way gone.
/// A slide is seen as one only if the thing sliding is there to see, so a page that arrives by
/// a turn is told so (``EnvironmentValues/pageSettlesIn``) and draws its sections at once.
///
/// A value at file scope and `nonisolated`, so `ArrivalTests` reads it off the main actor (rule
/// `43-concurrency`).
nonisolated enum Arrival {

    /// How far a section rises, in points.
    static let rise: CGFloat = 14

    /// How long one section takes.
    static let duration: Double = 0.4

    /// How long each section waits for the one above it.
    static let stagger: Double = 0.05

    /// The longest any section waits, however far down the screen it is.
    static let longestDelay: Double = 0.2

    /// How long a page that has just been built is drawn hidden before it starts to arrive:
    /// a few frames, so there is a frame to arrive from.
    static let hiddenFirst: Duration = .milliseconds(50)

    /// What a section is drawn at before it has arrived. **Never exactly zero.**
    ///
    /// At zero SwiftUI drops a view from hit-testing and from the accessibility tree, and it
    /// has not always given one back: a screen kept alive while its tab was away came back
    /// from zero with every day in History's week card drawn, answering a finger, and reported
    /// as impossible to press until something redrew it — which is what VoiceOver reads
    /// (`testAScreenAnswersATapWhenItIsShownAgain`). A page is rebuilt each time it is
    /// shown now, and the floor stays: a section is present from its first frame, for a test
    /// that looks for it and a finger that is early. Under one part in 255 it is drawn as
    /// nothing all the same (`aSectionThatHasNotArrivedIsNeverAtExactlyNothing`).
    static let hiddenOpacity: Double = 0.001

    /// How long the section at `order` waits before it starts; `0` is the first under the title.
    static func delay(order: Int) -> Double {
        min(Double(max(order, 0)) * stagger, longestDelay)
    }

    /// What a section is drawn at: whole once it has arrived, and whole from the start on a
    /// page that does not settle in.
    static func opacity(arrived: Bool, settles: Bool) -> Double {
        arrived || !settles ? 1 : hiddenOpacity
    }

    /// How far below its place a section is drawn. Nothing once it has arrived, nothing on a
    /// page that does not settle in, and nothing under Reduce Motion, where a section of the
    /// opening page fades in where it stands (rule `65-accessibility`).
    static func lift(arrived: Bool, settles: Bool, reduceMotion: Bool) -> CGFloat {
        arrived || !settles || reduceMotion ? 0 : rise
    }
}

private struct PageSettlesInKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {

    /// Whether this page's sections settle in, or are simply there.
    ///
    /// `true` for the page the app opens on, and for a screen standing alone on the canvas.
    /// `RootTabView` sets it `false` for every page a turn brings in: that page arrives by
    /// sliding, whole.
    var pageSettlesIn: Bool {
        get { self[PageSettlesInKey.self] }
        set { self[PageSettlesInKey.self] = newValue }
    }
}

private struct ArrivalModifier: ViewModifier {

    let arrived: Bool
    let order: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.pageSettlesIn) private var settles

    func body(content: Content) -> some View {
        content
            .opacity(Arrival.opacity(arrived: arrived, settles: settles))
            // **Under Reduce Motion it is the fade alone.** It runs once, which the rule
            // exempts — but it is travel across the screen, not feedback under a finger
            // (rule `65-accessibility`).
            .offset(y: Arrival.lift(arrived: arrived, settles: settles, reduceMotion: reduceMotion))
            // Scoped to the flag, never a bare `withAnimation` (rule `50-views`). There is no
            // way out to animate: a page leaves whole, and its flag goes with it.
            .animation(
                arrived ? .smooth(duration: Arrival.duration).delay(Arrival.delay(order: order)) : nil,
                value: arrived
            )
    }
}

extension View {

    /// Draws this view as arriving with its page: on the page the app opens on, hidden until
    /// `arrived` and then risen and faded in, `order` sections after the first; on a page that
    /// slid in, simply there.
    ///
    /// The screen owns the flag and keeps it with ``tracksArrival(_:)``.
    func arrives(_ arrived: Bool, order: Int) -> some View {
        modifier(ArrivalModifier(arrived: arrived, order: order))
    }

    /// Keeps a screen's arrival flag: set a few frames after the screen is built.
    ///
    /// **In a task, and not in `onAppear`.** A flag set as the screen appears is set before its
    /// first frame is drawn, and the screen then has nothing to arrive from; a task runs a turn
    /// later and waits ``Arrival/hiddenFirst``, so one frame is drawn before it. Whatever takes
    /// its start from the flag — the opening page's sections, History's bars on every page —
    /// has that frame to start from. Not set again on a return from the background or a sheet.
    func tracksArrival(_ arrived: Binding<Bool>) -> some View {
        modifier(ArrivalTracker(arrived: arrived))
    }
}

private struct ArrivalTracker: ViewModifier {

    @Binding var arrived: Bool

    func body(content: Content) -> some View {
        content
            .task {
                // Cancelled, and so never set, if the page is gone before the wait is over —
                // and asked again after it, for a page gone in the turn the wait ended
                // (rule `43-concurrency`).
                do { try await Task.sleep(for: Arrival.hiddenFirst) } catch { return }
                guard !Task.isCancelled else { return }
                arrived = true
            }
    }
}
