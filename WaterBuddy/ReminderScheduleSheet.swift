//
//  ReminderScheduleSheet.swift
//  WaterBuddy
//
//  Created by Sardor Allaberganov on 30/10/26.
//

import SwiftData
import SwiftUI

/// Set B's schedule, edited (spec `2026-10-30-coaching-design.md` §3.4, D5): the first and the last reminder,
/// how often, and the days that keep their reminders.
///
/// **Each change is saved as it is made**, through ``DataManager/reminderSchedule``, which re-plans at once —
/// there is no *Save* to forget. Every move goes through ``ReminderPlan/Schedule``'s own, so the sheet can only
/// write a schedule the plan accepts (`theSheetsMenusOfferOnlySchedulesThePlanAccepts`).
///
/// Opened only for a Premium holder: Settings' row opens the paywall for anyone else (D4).
struct ReminderScheduleSheet: View {

    @Environment(DataManager.self) private var manager
    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale

    /// What the sheet shows, seeded from the schedule it was opened on (rule `50-views`).
    @State private var draft: ReminderPlan.Schedule

    /// Bumped by every choice, for the selection tick (rule `60-design-system`).
    @State private var picks = 0

    init(schedule: ReminderPlan.Schedule) {
        _draft = State(initialValue: schedule)
    }

    var body: some View {
        ZStack {
            AuroraBackground()

            // Whole at every ordinary size, scrolling once the type outgrows the sheet (rule `65-accessibility`).
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: Self.gap) {
                        topBar
                        hourRow("First reminder", hour: draft.first, choices: Self.firstHours(every: draft.every)) {
                            commit(draft.with(first: $0))
                        }
                        hourRow("Last reminder", hour: draft.last, choices: Self.lastHours(for: draft)) {
                            commit(draft.with(last: $0))
                        }
                        intervals
                        days
                        if draft != .standard {
                            standardButton
                        }
                    }
                    .padding(.horizontal, ScreenMetrics.margin)
                    .padding(.vertical, Self.verticalInset)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: proxy.size.height, alignment: .top)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sensoryFeedback(Haptics.select, trigger: picks)
        // Seeded through `init`, re-read from the model (rule `50-views`). Today only the sheet writes the
        // schedule while it is open, so its own write comes back equal to `draft` and changes nothing.
        .onChange(of: manager.reminderSchedule) { _, schedule in
            draft = schedule
        }
    }

    private func commit(_ schedule: ReminderPlan.Schedule) {
        guard schedule != draft else { return }
        draft = schedule
        manager.reminderSchedule = schedule
        picks += 1
    }

    // MARK: - Parts

    /// The heading and the shared close button, labelled *Done*: there is nothing to save.
    private var topBar: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Schedule", bundle: strings)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            SheetCloseButton(label: "Done")
        }
    }

    /// One hour, chosen from a menu: the row's title, the hour, and the system's menu over it — on one line
    /// where they fit, the hour under the title where they do not. At the accessibility sizes one line broke
    /// *First reminder* into syllables and the hour across two lines (the walk, W2). The choice is between
    /// whole menus, never labels inside one (rule `50-views`).
    private func hourRow(_ title: LocalizedStringKey, hour: Int, choices: [Int],
                         choose: @escaping (Int) -> Void) -> some View {
        ViewThatFits(in: .horizontal) {
            hourMenu(title, hour: hour, choices: choices, choose: choose, stacked: false)
            hourMenu(title, hour: hour, choices: choices, choose: choose, stacked: true)
        }
        .frame(maxWidth: .infinity)
    }

    private func hourMenu(_ title: LocalizedStringKey, hour: Int, choices: [Int],
                          choose: @escaping (Int) -> Void, stacked: Bool) -> some View {
        Menu {
            ForEach(choices, id: \.self) { choice in
                Button(Self.hourLabel(choice, locale: locale)) { choose(choice) }
            }
        } label: {
            Group {
                if stacked {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title, bundle: strings)
                            .font(.body)
                        HStack(spacing: 12) {
                            hourText(hour)
                            Spacer(minLength: 8)
                            chevron
                        }
                    }
                    .padding(.vertical, 12)
                } else {
                    HStack(spacing: 12) {
                        Text(title, bundle: strings)
                            .font(.body)
                            .lineLimit(1)
                            .fixedSize()
                        Spacer(minLength: 8)
                        hourText(hour)
                        chevron
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .contentShape(Rectangle())
        }
        // The intervals' and the days' pair: sibling panes on one screen share one (rule `60-design-system`).
        // Interactive, because the row is the menu's pressable surface.
        .liquidGlass(cornerRadius: LiquidGlass.cornerRadius, density: .sheer, elevation: .resting, interactive: true)
        .accessibilityLabel(Text(title, bundle: strings))
        .accessibilityValue(Self.hourLabel(hour, locale: locale))
    }

    /// The hour, whole: a time cut in two says nothing.
    private func hourText(_ hour: Int) -> some View {
        Text(Self.hourLabel(hour, locale: locale))
            .font(.body.weight(.semibold))
            .monospacedDigit()
            .lineLimit(1)
            .fixedSize()
    }

    private var chevron: some View {
        Image(systemName: "chevron.up.chevron.down")
            .font(.footnote.weight(.semibold))
            .accessibilityHidden(true)
    }

    /// The three intervals, side by side where they fit and stacked where they do not.
    private var intervals: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { intervalButtons }
            VStack(spacing: 8) { intervalButtons }
        }
        .glassGroup()
    }

    private var intervalButtons: some View {
        ForEach(ReminderPlan.Schedule.intervals, id: \.self) { every in
            let isSelected = draft.every == every
            let label = Self.intervalLabel(every, strings: strings, locale: locale)
            Button {
                commit(draft.with(every: every))
            } label: {
                Text(label)
                    .font(.subheadline.weight(isSelected ? .bold : .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background {
                        selectionMark(isSelected, in: RoundedRectangle(cornerRadius: LiquidGlass.cornerRadius, style: .continuous))
                    }
                    .liquidGlass(cornerRadius: LiquidGlass.cornerRadius, density: .sheer, elevation: .resting, interactive: true)
            }
            .buttonStyle(PressStyle())
            .accessibilityLabel(label)
            .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        }
    }

    /// The seven days in the locale's order, each a disc: lit while it keeps its reminders. Across the row
    /// where it fits; where it does not — seven 44-pt discs need 308 pt, and a 320-pt Display Zoom screen
    /// leaves 272 inside the margins — the discs scroll rather than shrink below the floor (rule
    /// `65-accessibility`). Under the row, while one day is left, why it will not turn off.
    private var days: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Days", bundle: strings)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white)
                .legibleOnBackdrop()
                .accessibilityHidden(true)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 0) {
                    ForEach(Self.weekdays(in: locale), id: \.self) { weekday in
                        dayDisc(weekday)
                            .frame(maxWidth: .infinity)
                    }
                }
                ScrollView(.horizontal) {
                    // Apart, so no two glass discs share an edge.
                    HStack(spacing: Self.discGap) {
                        ForEach(Self.weekdays(in: locale), id: \.self) { weekday in
                            dayDisc(weekday)
                        }
                    }
                }
                // The discs' glass is not cut square at the margins as they scroll.
                .scrollClipDisabled()
            }
            .glassGroup()
            if lastDayKept != nil {
                // Drawn for the eye; the disc's hint says it to VoiceOver (rule `65-accessibility`).
                Text("One day always keeps its reminders.", bundle: strings)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .legibleOnBackdrop()
                    .accessibilityHidden(true)
            }
        }
        .animation(.smooth(duration: 0.3), value: lastDayKept)
    }

    /// The one day the schedule will not let go of — the last keeping reminders — or `nil` while any may.
    private var lastDayKept: Int? {
        (1...7).first { !draft.mayToggle(weekday: $0) }
    }

    private func dayDisc(_ weekday: Int) -> some View {
        let keeps = !draft.quietWeekdays.contains(weekday)
        let mayToggle = draft.mayToggle(weekday: weekday)
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        return Button {
            commit(draft.toggling(weekday: weekday))
        } label: {
            Text(calendar.veryShortStandaloneWeekdaySymbols[weekday - 1])
                // A share of its circle, never a text style: the disc is a fixed 44-pt target (rule `65-accessibility`).
                .font(.system(size: Self.disc * Self.letter, weight: keeps ? .bold : .regular))
                .foregroundStyle(.white.opacity(keeps ? 1 : Self.quietOpacity))
                .frame(width: Self.disc, height: Self.disc)
                .background { selectionMark(keeps, in: Circle()) }
                .liquidGlass(in: Circle(), density: .sheer, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
        // The last day keeping reminders: VoiceOver says *dimmed*, and the hint says why (D6).
        .disabled(!mayToggle)
        .accessibilityLabel(calendar.standaloneWeekdaySymbols[weekday - 1])
        .accessibilityHint(mayToggle ? Text(verbatim: "") : Text("One day always keeps its reminders.", bundle: strings))
        .accessibilityAddTraits(keeps ? [.isSelected] : [])
    }

    private var standardButton: some View {
        Button {
            commit(.standard)
        } label: {
            Text("Standard schedule", bundle: strings)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .liquidGlass(in: Capsule(), density: .sheer, elevation: .resting, interactive: true)
        }
        .buttonStyle(PressStyle())
    }

    /// ``LiquidGlass/Selection``'s fill and rim, present at nothing when not picked (rule `60-design-system`).
    private func selectionMark<S: InsettableShape>(_ isSelected: Bool, in shape: S) -> some View {
        shape
            .fill(.white.opacity(isSelected ? LiquidGlass.Selection.fillOpacity : 0))
            .strokeBorder(.white.opacity(isSelected ? LiquidGlass.Selection.rimOpacity : 0), lineWidth: 1)
            .animation(Motion.land, value: isSelected)
    }

    // MARK: - The menus and the words

    private static let gap: CGFloat = 16
    private static let verticalInset: CGFloat = 24
    /// A day's disc: the 44-pt floor (rule `65-accessibility`). Seven fit inside the margins of a 375-pt
    /// iPhone's 327; on a 320-pt Display Zoom screen they scroll.
    private static let disc: CGFloat = 44
    /// Between two discs where they scroll: the intervals' gap.
    private static let discGap: CGFloat = 8
    /// The letter's share of its disc: 17 pt in 44, `SheetCloseButton`'s glyph.
    private static let letter: CGFloat = 17.0 / 44.0
    /// A quiet day's letter — still 4.5:1 on its glass, to be measured on the walk.
    private static let quietOpacity = 0.7

    /// The first hours on offer: early enough to leave one interval before 23:00.
    nonisolated static func firstHours(every: Int) -> [Int] {
        Array(ReminderPlan.Schedule.earliest...(ReminderPlan.Schedule.latest - every))
    }

    /// The last hours on offer: on the schedule's grid, at least one interval after its first.
    nonisolated static func lastHours(for schedule: ReminderPlan.Schedule) -> [Int] {
        Array(stride(from: schedule.first + schedule.every, through: ReminderPlan.Schedule.latest, by: schedule.every))
    }

    /// An hour as the phone writes a time — *9:00 AM*, *21:00* — in the app's locale. Main-actor, as every
    /// reader is: its default calendar, `Calendar.waterBuddyDay`, is an extension member of the app's default
    /// isolation.
    static func hourLabel(_ hour: Int, locale: Locale, calendar: Calendar = .waterBuddyDay) -> String {
        guard let date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15, hour: hour)) else {
            return String(hour)
        }
        return date.formatted(Date.FormatStyle(locale: locale, calendar: calendar, timeZone: calendar.timeZone).hour().minute())
    }

    /// The weekdays, 1 = Sunday, from the locale's first — History's month grid's answer (rule `30-rollover`).
    nonisolated static func weekdays(in locale: Locale) -> [Int] {
        let first = HistoryView.firstWeekday(in: locale)
        return (0..<7).map { (first - 1 + $0) % 7 + 1 }
    }

    /// *Every hour*, *Every 2 hours* — the sheet's buttons.
    static func intervalLabel(_ every: Int, strings: Bundle, locale: Locale) -> String {
        every == 1
            ? strings.localizedString(forKey: "Every hour", value: nil, table: nil)
            : strings.localized("Every %1$d hours", every, locale: locale)
    }

    /// Settings' row: the hours drawn, the same spoken, and the quiet days, if any — drawn short, spoken in
    /// full, as the sheet's discs speak them (spec `2026-10-31-finish-set-b-design.md` D5).
    struct Summary: Equatable {
        let hours: String
        let spoken: String
        let quiet: String?
        let spokenQuiet: String?
    }

    static func summary(of schedule: ReminderPlan.Schedule, strings: Bundle, locale: Locale,
                        calendar: Calendar = .waterBuddyDay) -> Summary {
        let every = schedule.every == 1
            ? strings.localizedString(forKey: "every hour", value: nil, table: nil)
            : strings.localized("every %1$d hours", schedule.every, locale: locale)
        let from = hourLabel(schedule.first, locale: locale, calendar: calendar)
        let to = hourLabel(schedule.last, locale: locale, calendar: calendar)
        var named = Calendar(identifier: .gregorian)
        named.locale = locale
        // One key for both forms: every translation takes the days as a list, never declined.
        let quiet = { (symbols: [String]) -> String? in
            guard !schedule.quietWeekdays.isEmpty else { return nil }
            let names = weekdays(in: locale).filter(schedule.quietWeekdays.contains).map { symbols[$0 - 1] }
            return strings.localized("Not on %1$@", names.formatted(.list(type: .and).locale(locale)), locale: locale)
        }
        return Summary(
            hours: strings.localized("%1$@ – %2$@, %3$@", from, to, every, locale: locale),
            spoken: strings.localized("From %1$@ to %2$@, %3$@", from, to, every, locale: locale),
            quiet: quiet(named.shortStandaloneWeekdaySymbols),
            spokenQuiet: quiet(named.standaloneWeekdaySymbols)
        )
    }
}

#Preview {
    // A throwaway suite and an in-memory store, every side effect silenced (rule `50-views`).
    let defaults = UserDefaults(suiteName: "preview.waterbuddy.schedule")!
    defaults.removePersistentDomain(forName: "preview.waterbuddy.schedule")
    let manager = DataManager(
        defaults: defaults,
        modelContainer: try! ModelContainer(for: WaterLog.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)),
        reloadWidgets: {},
        rescheduleReminders: { _ in },
        publishWrist: { _ in }
    )
    return ReminderScheduleSheet(schedule: .standard).environment(manager)
}
