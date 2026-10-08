# The Lock Screen Widget — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: `superpowers:executing-plans`, **in this session** —
> `CLAUDE.md` allows no implementation subagent ("Planning, test authorship, implementation and review
> all happen in the main loop"). Steps use checkbox (`- [ ]`) syntax for tracking. **No step commits:**
> each task ends by staging its paths, and nothing is committed until the owner runs `/commit`.

**Goal:** WaterBuddy on the iPhone Lock Screen — a ring, a card whose **+** logs the Glass, and a line
above the clock — showing the user's figures unless their own iOS lock setting hides them.

**Architecture:** A second widget, `LockScreenWidget` (`kind` `"WaterBuddyLockScreen"`), in the
existing widget extension, over the same `HydrationProvider` and `HydrationEntry` as the Home Screen
widget. Its view injects the snapshot's language at the root and draws each family in a child view of
its own, from the system's accessory vocabulary (capacity gauges, `AccessoryWidgetBackground`), with
every figure `.privacySensitive()` and a quiet form for `redactionReasons.contains(.privacy)`. The
rectangle's button runs the existing `AddWaterIntent(amount: entry.snapshot.serving)`.

**Tech Stack:** Swift (language mode 5; the widget module has no default actor isolation, known issue
#65), SwiftUI, WidgetKit accessory families, App Intents (`Button(intent:)`), XCTest (one throwaway
probe), Xcode 27.0.

**Spec:** `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md` — read it first; this plan
argues from it. Its §5 rule wording is **approved** (owner, 2026-10-08, "go").

**Executed 2026-10-08, with three changes to Task 1's code** — each a ruling in the execution ledger
and recorded in the spec, which is the authority: the ring's percentage takes `.minimumScaleFactor(0.4)`,
not 0.6 (Russian's `38 %` truncated to `38…` on the simulator at 0.6; spec §3.5); and, after the final
review, every drawn figure, gauge and glyph inside the ring and the card carries
`.accessibilityHidden(true)` (rule `65-accessibility`), and the card's figures carry
`.invalidatableContent()` (rule `40-widget`). The code below is the plan as written, not as shipped —
read `WaterBuddyWidget/LockScreenWidget.swift` for that.

## Global Constraints

- **Floor iOS 17.0.** `.accessoryCircular`, `.accessoryRectangular`, `.accessoryInline`,
  `.accessoryCircularCapacity`, `.accessoryLinearCapacity`, `AccessoryWidgetBackground` and
  `WidgetRenderingMode` are iOS 16.0 (SDK) — no `#available` anywhere.
- **Source files:** create `WaterBuddyWidget/LockScreenWidget.swift`; modify
  `WaterBuddyWidget/WaterBuddyWidgetBundle.swift` and, by one word plus its DocC,
  `WaterBuddyWidget/WaterBuddyWidget.swift`. **Nothing else under a target folder** — no shared file,
  no `DataManager.Key`, no catalogue, no entitlement, no Info.plist key, no `PrivacyInfo.xcprivacy`, no
  `project.pbxproj` edit.
- **Strings:** exactly spec §3.7's seven keys. The gallery literals are `"Hydration"` and `"Track
  today's hydration and log a glass without opening the app."`, verbatim. The percentage is
  `Text(snapshot.percentage, format: .percent.locale(locale))` — no `%` key, no new rounding.
- **Read `\.strings`, `\.locale` and `\.redactionReasons` only in a view *below* the injection** — never
  in `LockScreenView` itself. A view's own `@Environment` comes from above it; `HydrationView.medium`
  resolves its two lines through its own `strings` and so draws them in the device language (found while
  planning; recorded in Task 5, not fixed here).
- **Privacy:** `.privacySensitive()` on every figure-bearing view; each shape's quiet form under
  `redactionReasons.contains(.privacy)` draws no figure and no fill and speaks its label alone; the
  button's VoiceOver label is *Log Water* in the quiet form.
- **The button:** `Button(intent: AddWaterIntent(amount: serving))`, `.buttonStyle(.plain)`, a
  `PourButton.minimumTarget` square, the glyph sized as a ratio of it (rule `60-design-system`).
- **No branch on `widgetRenderingMode`, no glass, no `Aurora` colour, no `colorScheme` override.**
- **No `PreviewProvider`** — its `static var previews` would be a third `static var` against rule
  `43-concurrency`'s census of two. `#Preview` only.
- **Rule wording is spec §5's, verbatim** — the one approved copy. Never re-word it while applying it.
- Every `xcodebuild` in the foreground, `-parallel-testing-enabled NO`, destination
  `'platform=iOS Simulator,OS=26.5,name=iPhone 17'` (watch runs:
  `'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)'`). Run
  `xcrun simctl shutdown all` before a test run **only if no other `xcodebuild` is running**
  (`pgrep -x xcodebuild`).
- **Edits with `Edit`/`Write` only** — `Bash(sed -i:*)` is on the deny list. Never write into the
  Mac's own `group.sardor.WaterBuddy` or `UserDefaults.standard`; the simulator's suite changes only
  through the app's own UI, and is put back (Task 4).
- No new warning against a clean build of HEAD (Task 3).

## Review Focus

Conditions the spec implies that no unit test can drive — WidgetKit lists no families and no test
target compiles the extension — most likely to bite first, each with the check that owns it:

1. **The app's language differs from the phone's** (app in Russian, phone in English). Every string on
   the Lock Screen and the percent sign must follow the app. → Structure (Global Constraints: strings
   read only below the injection), and Task 4's captures in ru and uz on an English simulator.
2. **The user has told iOS to hide Lock Screen widgets.** No figure in sight or in speech; the button
   says *Log Water*. → Task 1's "Quiet forms" preview, and the spec's device check, step 4 (§7.5).
3. **Overachievement and long numbers** — 150%, a five-digit total, a long locale. Ring and bar stop
   at 100% (`progress`); text shrinks (`.minimumScaleFactor(0.6)`). → the 3,000-of-2,000 preview
   entries (Task 1) and Task 4's capture at `accessibility-extra-large`.
4. **Midnight with nothing opened.** → the shared provider's `rolledOver()` entry, already pinned by
   `rollingOverChangesNothingExceptTheTotal`; no new code path. The device check, step 8.
5. **The **+** logging a different amount from the one the face implies, or acting while locked.** →
   `serving` comes from the same `entry.snapshot` as every figure (Task 1's code); the locked hold is
   iOS's (device check, step 5); Task 4 measures one tap on the simulator.

---

## File structure

| File | Change | Responsibility |
|---|---|---|
| `WaterBuddyWidget/LockScreenWidget.swift` | create | the widget, its root view, the three shapes, the button, the spoken sentence, the previews |
| `WaterBuddyWidget/WaterBuddyWidgetBundle.swift` | modify | lists `LockScreenWidget()` after `WaterBuddyWidget()` |
| `WaterBuddyWidget/WaterBuddyWidget.swift` | modify | `PourButton` loses `private` (and says why), so both buttons read one `minimumTarget` |
| `.claude/rules/{70-privacy,40-widget,60-design-system,65-accessibility,85-testing}.md` | modify | spec §5, verbatim |
| `WaterBuddyUITests/LockScreenProbe.swift` | create, then **delete** | Task 4's throwaway captures |

Shell variable used below — **each `Bash` call is a fresh shell**, so set it in every command, to **your
session's** scratchpad:

```bash
SP=/private/tmp/claude-501/-Users-sardorallaberganov-Desktop-Projects-MobileApps-WaterBuddy/<session>/scratchpad
```

The widget build, used by Task 1:

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' > $SP/w.log 2>&1; echo "exit $?"
grep -E 'error:|warning:|\*\* BUILD' $SP/w.log | grep -vE '^\s+\|' | sed -E 's#^/[^ ]*/##' | sort -u | cut -c1-220
```

---

### Task 1: The Lock Screen widget

**Files:**
- Modify: `WaterBuddyWidget/WaterBuddyWidgetBundle.swift:14-16`
- Create: `WaterBuddyWidget/LockScreenWidget.swift`
- Modify: `WaterBuddyWidget/WaterBuddyWidget.swift:377-379`

**Interfaces:**
- Consumes: `HydrationProvider`, `HydrationEntry` (`WaterBuddyWidget.swift`, internal);
  `WaterSnapshot.percentage: Int`, `.progress: Double`, `.currentWater: Int`, `.dailyGoal: Int`,
  `.serving: Int`, `.language: AppLanguage` (`DataManager.swift`); `AppLanguage.bundle: Bundle`,
  `.locale: Locale`; `EnvironmentValues.strings: Bundle`; `AddWaterIntent(amount: Int)`;
  `PourButton.minimumTarget: CGFloat` (44).
- Produces: `struct LockScreenWidget: Widget` with `static let kind = "WaterBuddyLockScreen"`;
  `struct LockScreenView: View` (`init(entry: HydrationEntry)`).

- [ ] **Step 1: Register the widget before it exists (RED)**

In `WaterBuddyWidgetBundle.swift`, the body becomes:

```swift
    var body: some Widget {
        WaterBuddyWidget()
        LockScreenWidget()
    }
```

- [ ] **Step 2: Build — it must fail on the missing type**

Run the widget build above.
Expected: `exit 65`, `error: cannot find 'LockScreenWidget' in scope`, `** BUILD FAILED **`.

- [ ] **Step 3: Write the widget**

Create `WaterBuddyWidget/LockScreenWidget.swift`:

```swift
//
//  LockScreenWidget.swift
//  WaterBuddyWidget
//
//  Created by Sardor Allaberganov on 08/10/26.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - Widget

/// Today's hydration on the iPhone Lock Screen — a ring, a card with a pour button, or a line above
/// the clock.
///
/// **A second widget, not three more families on ``WaterBuddyWidget``.** That widget's configuration
/// is glass over an aurora with the system margins disabled, and every one of those applies to every
/// family a configuration lists. The Lock Screen wants none of them: iOS renders it in the vibrant
/// mode, which desaturates a widget into its own material, so this one is drawn from the system's
/// accessory vocabulary and keeps the system's margins.
///
/// **The same provider, deliberately.** ``HydrationProvider`` hands both widgets one snapshot, one
/// midnight and one reload, so the Lock Screen cannot disagree with the Home Screen about today.
///
/// **What it may show is a ruling** (rule `70-privacy`): the user's own figures, because the user put
/// the widget there — every one marked privacy-sensitive, so the user's own *Allow Access When Locked →
/// Lock Screen Widgets* setting hides them, as it hides a notification's preview.
///
/// Design: `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`.
struct LockScreenWidget: Widget {

    static let kind = "WaterBuddyLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HydrationProvider()) { entry in
            LockScreenView(entry: entry)
        }
        // The Home Screen widget's two literals, static for the reason they are static there: the
        // gallery is drawn by the system, which cannot carry a format argument (rule `40-widget`).
        // The description holds for this widget too — its rectangle logs a glass.
        .configurationDisplayName("Hydration")
        .description("Track today's hydration and log a glass without opening the app.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

// MARK: - Entry view

/// Injects the snapshot's language and picks the shape.
///
/// **It reads no string itself, and that is why every shape is a view of its own.** A view's own
/// `@Environment` comes from *above* it, so the bundle this body injects reaches only the views below.
/// A string resolved here would come from `Bundle.main` — the device's language — while the app drew
/// the chosen one.
struct LockScreenView: View {

    let entry: HydrationEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        shape
            // The Lock Screen draws no container background, but iOS overlays a warning on any widget
            // that does not declare its background removable.
            .containerBackground(for: .widget) { Color.clear }
            // The language travels in the snapshot, as on the Home Screen (rule `40-widget`).
            .environment(\.strings, entry.snapshot.language.bundle)
            .environment(\.locale, entry.snapshot.language.locale)
    }

    @ViewBuilder
    private var shape: some View {
        switch family {
        case .accessoryRectangular: LockScreenCard(snapshot: entry.snapshot)
        case .accessoryInline: LockScreenLine(snapshot: entry.snapshot)
        default: LockScreenRing(snapshot: entry.snapshot)
        }
    }
}

// MARK: - Circle

/// A ring that fills to today's progress, with the percentage inside.
///
/// A *closed* ring that fills — `.accessoryCircularCapacity` — because it reads as the app's vessel:
/// how full, not where on a dial. The watch's complication keeps its open ring with a marker; matching
/// the two is a separate change (spec §3.1).
private struct LockScreenRing: View {

    let snapshot: WaterSnapshot

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            // The quiet form: no figure and no fill — only the drop, so the widget is still
            // recognisably WaterBuddy to the person it belongs to.
            Gauge(value: 0.0) {
                EmptyView()
            } currentValueLabel: {
                Image(systemName: "drop.fill")
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            Gauge(value: snapshot.progress) {
                EmptyView()
            } currentValueLabel: {
                Text(snapshot.percentage, format: .percent.locale(locale))
                    .minimumScaleFactor(0.6)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .privacySensitive()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(snapshot.spokenFigures(in: strings))
        }
    }
}

// MARK: - Rectangle

/// Today's millilitres, the goal under them, a bar that fills — and the pour button.
private struct LockScreenCard: View {

    let snapshot: WaterSnapshot

    @Environment(\.strings) private var strings
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        HStack(spacing: 8) {
            figures
                .frame(maxWidth: .infinity, alignment: .leading)

            LockScreenPourButton(serving: snapshot.serving)
        }
    }

    @ViewBuilder
    private var figures: some View {
        if redactionReasons.contains(.privacy) {
            VStack(alignment: .leading, spacing: 4) {
                // *Hydration*, the widget's own name: in Russian *Today's hydration* is 24 characters.
                Label {
                    Text("Hydration", bundle: strings)
                } icon: {
                    Image(systemName: "drop.fill")
                }
                .font(.headline)

                Gauge(value: 0.0) {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            VStack(alignment: .leading, spacing: 2) {
                // The medium Home Screen widget's own two keys, so the two surfaces word today alike.
                Text(String(format: strings.localizedString(forKey: "%1$d ml", value: nil, table: nil), snapshot.currentWater))
                    .font(.headline)

                Text(String(format: strings.localizedString(forKey: "of %1$d ml", value: nil, table: nil), snapshot.dailyGoal))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Gauge(value: snapshot.progress) {
                    EmptyView()
                }
                .gaugeStyle(.accessoryLinearCapacity)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .privacySensitive()
            // One stop for the figures, in the vessel's own sentence. The button beside this column is
            // its own element — the stack does not contain it, so `.ignore` hides no control
            // (rule `65-accessibility`).
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(snapshot.spokenFigures(in: strings))
        }
    }
}

// MARK: - Line

/// A drop and the percentage, beside the date above the clock.
///
/// iOS draws an inline widget in its own font and colour, and the whole line is one tap target that
/// opens the app — so it carries no button.
private struct LockScreenLine: View {

    let snapshot: WaterSnapshot

    @Environment(\.strings) private var strings
    @Environment(\.locale) private var locale
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        if redactionReasons.contains(.privacy) {
            // *Hydration*, not *Today's hydration*: this line shares its width with the date.
            Label {
                Text("Hydration", bundle: strings)
            } icon: {
                Image(systemName: "drop.fill")
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
        } else {
            Label {
                Text(snapshot.percentage, format: .percent.locale(locale))
            } icon: {
                Image(systemName: "drop.fill")
            }
            .privacySensitive()
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("Today's hydration", bundle: strings))
            .accessibilityValue(snapshot.spokenFigures(in: strings))
        }
    }
}

// MARK: - Pour button

/// The rectangle's one control: logs the Glass, as the Home Screen widget's button does.
///
/// While the phone is locked iOS holds the tap until the owner authenticates — on a locked device
/// "buttons and toggles are inactive" — so a stranger cannot log water on it, and with Face ID the
/// owner has usually authenticated by the time they look.
private struct LockScreenPourButton: View {

    /// The middle quick-add vessel, from the same snapshot as every figure beside it — never read live
    /// (rule `40-widget`).
    let serving: Int

    @Environment(\.strings) private var strings
    @Environment(\.redactionReasons) private var redactionReasons

    var body: some View {
        Button(intent: AddWaterIntent(amount: serving)) {
            Image(systemName: "plus")
                // The Home Screen button's 19pt, as a ratio of the disc it sits in: a glyph inside a
                // fixed container is sized off the container, never off a text style
                // (rule `60-design-system`).
                .font(.system(size: PourButton.minimumTarget * 0.43, weight: .semibold))
                .frame(width: PourButton.minimumTarget, height: PourButton.minimumTarget)
                .background {
                    // The system's own Lock Screen backing — black in the vibrant mode, which reads as
                    // a dim, fully blurred disc. `PourButton`'s tinted fallback would draw a white rim
                    // at 0.45 opacity, the transparent colour this mode advises against.
                    AccessoryWidgetBackground()
                        .clipShape(Circle())
                }
                .contentShape(Circle())
        }
        // Without it the system draws its own bordered button over the backing.
        .buttonStyle(.plain)
        .accessibilityLabel(spokenLabel)
    }

    /// What VoiceOver calls the button. A serving size is a figure too, so the quiet form says only what
    /// the button does — the intent's own title, already translated in this catalogue.
    private var spokenLabel: String {
        if redactionReasons.contains(.privacy) {
            strings.localizedString(forKey: "Log Water", value: nil, table: nil)
        } else {
            String(format: strings.localizedString(forKey: "Add %1$d millilitres", value: nil, table: nil), serving)
        }
    }
}

// MARK: - Speech

private extension WaterSnapshot {

    /// The Home Screen vessel's own sentence — the percentage and both volumes — so VoiceOver says the
    /// same thing about today on either screen.
    func spokenFigures(in strings: Bundle) -> String {
        String(format: strings.localizedString(forKey: "%1$d percent. %2$d of %3$d millilitres.", value: nil, table: nil), percentage, currentWater, dailyGoal)
    }
}

// MARK: - Preview

#Preview("Circle", as: .accessoryCircular) {
    LockScreenWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

#Preview("Rectangle", as: .accessoryRectangular) {
    LockScreenWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

#Preview("Line", as: .accessoryInline) {
    LockScreenWidget()
} timeline: {
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 0, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000))
    HydrationEntry(date: .now, snapshot: WaterSnapshot(currentWater: 3_000, dailyGoal: 2_000))
}

/// The quiet forms — what each shape draws once the user has turned off *Lock Screen Widgets* under
/// *Allow Access When Locked*. Drawn outside a widget, so the sizes are approximate.
#Preview("Quiet forms") {
    let snapshot = WaterSnapshot(currentWater: 1_150, dailyGoal: 2_000)

    VStack(spacing: 24) {
        LockScreenRing(snapshot: snapshot)
        LockScreenCard(snapshot: snapshot)
        LockScreenLine(snapshot: snapshot)
    }
    .padding()
    .redacted(reason: .privacy)
}
```

- [ ] **Step 4: Build — it must fail on `PourButton`'s privacy**

Run the widget build.
Expected: `exit 65`, `** BUILD FAILED **`, and errors in `LockScreenWidget.swift` that name
`PourButton` and nothing else — Swift reports a `private` type used from another file either as
`'PourButton' is inaccessible due to 'private' protection level` or as `cannot find 'PourButton' in
scope`; either is this RED. Any other error is a defect in Step 3's code: fix it there, never by
loosening anything else.

- [ ] **Step 5: Give `PourButton` its one word**

In `WaterBuddyWidget.swift`, replace

```swift
/// The interactive half. `Button(intent:)` is the only kind of button a widget can have: the
/// archive carries the intent, and the system runs it when the user taps.
private struct PourButton: View {
```

with

```swift
/// The interactive half. `Button(intent:)` is the only kind of button a widget can have: the
/// archive carries the intent, and the system runs it when the user taps.
///
/// Not `private`, for one reason: the Lock Screen widget's button reads ``minimumTarget``, so the 44pt
/// floor both widgets' buttons honour has one definition rather than two.
struct PourButton: View {
```

- [ ] **Step 6: Build — GREEN, and nothing new to say**

Run the widget build.
Expected: `exit 0`, `** BUILD SUCCEEDED **`, and **no** `warning:` line naming `LockScreenWidget.swift`,
`WaterBuddyWidgetBundle.swift` or `WaterBuddyWidget.swift` (the incremental build recompiles all three,
so it would print theirs). The clean comparison is Task 3's.

- [ ] **Step 7: The catalogue stayed as it was**

```bash
git diff --stat -- WaterBuddyWidget/Localizable.xcstrings
```

Expected: no output. If the build appended anything, read the diff: an extracted key the spec's §3.7
does not list is a string Step 3 introduced by mistake — remove it from the code, not just from the
catalogue.

- [ ] **Step 8: Stage**

```bash
git add WaterBuddyWidget/LockScreenWidget.swift WaterBuddyWidget/WaterBuddyWidgetBundle.swift \
        WaterBuddyWidget/WaterBuddyWidget.swift
git diff --cached --name-status
```

---

### Task 2: The rules, as approved

**Files:** modify `.claude/rules/70-privacy.md`, `40-widget.md`, `60-design-system.md`,
`65-accessibility.md`, `85-testing.md` — each with `Edit`, inserting spec §5's wording **verbatim**,
quotation marks dropped, bullets kept as bullets. Spec §5 is the one approved copy; this task copies it
and changes no word.

- [ ] **Step 1: `70-privacy.md`, *The lock screen is a public surface*** — after the bullet ending
  "`.alwaysAllowed` on purpose: logging water on a locked phone is harmless, and the reply says
  nothing" (line 77), insert §5's two bullets ("**The phone's Lock Screen widget may show the user's own
  figures** …" and "Never add an entitlement to hide the Lock Screen widget harder. …").
- [ ] **Step 2: `70-privacy.md`, *WatchConnectivity is a ruling, not an omission*** — in the second
  condition, replace "with one named carve-out: the watch's own complication, on the watch's own face."
  with §5's "with two named carve-outs: …" sentence, and append §5's closing sentence after "and the
  original wording simply never said so" (line 49).
- [ ] **Step 3: `40-widget.md`** — insert §5's `## The Lock Screen widget` section immediately before
  `## Proving it` (line 153), and append §5's clause to *Proving it*'s last bullet, after "and in a
  tinted (templated) configuration" (line 157).
- [ ] **Step 4: `60-design-system.md`, *In the widget*** — append §5's bullet after the section's last
  bullet, the one ending "cross over at the accessibility sizes (rule `65-accessibility`)" (line 110).
- [ ] **Step 5: `65-accessibility.md`, *VoiceOver*** — append §5's bullet after the section's last
  bullet, the one ending "an unknown symbol draws nothing at all" (line 99), before `## Contrast`.
- [ ] **Step 6: `85-testing.md`** — replace the sentence at line 146 with §5's "**No widget's rendering
  has any automated coverage, on either platform** — …" sentence.
- [ ] **Step 7: Check the copy against the approval, then stage**

```bash
grep -c 'Lock Screen widget' .claude/rules/70-privacy.md .claude/rules/40-widget.md \
  .claude/rules/60-design-system.md .claude/rules/65-accessibility.md .claude/rules/85-testing.md
git diff --stat -- .claude/rules/
```

Expected: every file counts at least 1; five files changed. Then reread each inserted passage beside
spec §5 — word for word — and stage:

```bash
git add .claude/rules/70-privacy.md .claude/rules/40-widget.md .claude/rules/60-design-system.md \
        .claude/rules/65-accessibility.md .claude/rules/85-testing.md
```

---

### Task 3: The gate and the warning comparison

**Files:** none changed.

- [ ] **Step 1: The five invocations**, foreground, exactly as rule `85-testing` writes them:

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyTests -parallel-testing-enabled NO > $SP/g1.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|Expectation failed|\*\* TEST' $SP/g1.log | cut -c1-220
```

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' \
  -only-testing:WaterBuddyUITests -parallel-testing-enabled NO \
  -skip-testing:WaterBuddyUITests/AppStoreScreenshotUITests > $SP/g2.log 2>&1; echo "exit $?"
grep -E 'Executed [0-9]+ test|error:|\*\* TEST' $SP/g2.log | sort -u | cut -c1-220
```

```bash
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' \
  -only-testing:WaterBuddyWatchTests -parallel-testing-enabled NO > $SP/g3.log 2>&1; echo "exit $?"
grep -E '✔ Test run|✘ Test run|\*\* TEST' $SP/g3.log | cut -c1-220
```

```bash
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' > $SP/g4.log 2>&1; echo "exit $?"
xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
  -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' > $SP/g5.log 2>&1; echo "exit $?"
grep -h '\*\* BUILD' $SP/g4.log $SP/g5.log
```

Expected — no test changed, so the last recorded figures: `✔ Test run with 371 tests in 46 suites
passed`; `Executed 26 tests` with at most one failure, `GoalSetupUITests.testAServingAddedToYesterdayShowsUnderYesterday`
(#62, pre-existing); `✔ Test run with 57 tests in 6 suites passed`; `** BUILD SUCCEEDED **` twice.
If #62's test fails, run it alone on Step 2's base export (`-project $SP/wc/base/WaterBuddy.xcodeproj
-only-testing:WaterBuddyUITests/GoalSetupUITests/testAServingAddedToYesterdayShowsUnderYesterday`) and
record HEAD's result beside it. A UI run refused as `Busy` (#57): `xcrun simctl bootstatus
EE56B958-E33F-40A3-99EA-B14D45963685 -b` (the iOS 26.5 *iPhone 17* here; re-read the UDID with
`xcrun simctl list devices` elsewhere), then run it again and record both.

- [ ] **Step 2: Clean builds of HEAD and of the change, into empty DerivedData, same sequence both sides**

```bash
rm -rf $SP/wc && mkdir -p $SP/wc/base
git archive HEAD | tar -x -C $SP/wc/base
cp -R $SP/wc/base $SP/wc/change
for f in WaterBuddyWidget/LockScreenWidget.swift WaterBuddyWidget/WaterBuddyWidgetBundle.swift \
         WaterBuddyWidget/WaterBuddyWidget.swift; do cp "$f" "$SP/wc/change/$f"; done
for side in base change; do
  xcodebuild build-for-testing -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddy \
    -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-app.log 2>&1; echo "$side app exit $?"
done
```

Then the other three schemes, each its own foreground invocation — never one loop over all four (the
600 s limit):

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
    -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-widget.log 2>&1; echo "$side widget exit $?"
done
```

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWatch \
    -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-watch.log 2>&1; echo "$side watch exit $?"
done
```

```bash
for side in base change; do
  xcodebuild build -project $SP/wc/$side/WaterBuddy.xcodeproj -scheme WaterBuddyWatchWidget \
    -destination 'platform=watchOS Simulator,OS=26.5,name=Apple Watch Series 11 (46mm)' -derivedDataPath $SP/wc/dd-$side > $SP/wc/$side-watchwidget.log 2>&1; echo "$side watchwidget exit $?"
done
```

If one invocation nears the limit, split it into its two sides.

- [ ] **Step 3: Compare per log, per file and message, line numbers stripped**

```bash
for log in app widget watch watchwidget; do
  for side in base change; do
    grep -E ': warning: ' $SP/wc/$side-$log.log | grep -vE '^\s+\|' \
      | sed -E 's#^/[^ ]*/(WaterBuddy[A-Za-z]*/[^:]+):[0-9]+:[0-9]+: #\1: #' | sort | uniq -c > $SP/wc/$side-$log.warn
  done
  echo "== $log"; diff $SP/wc/base-$log.warn $SP/wc/change-$log.warn && echo identical
done
grep -l 'LockScreenWidget.swift' $SP/wc/change-*.warn || echo "no warning in LockScreenWidget.swift"
```

Expected: `identical` for all four, and `no warning in LockScreenWidget.swift`. Any difference is a new
warning: fix it, then run Steps 1–3 again.

---

### Task 4: On the simulator — a throwaway probe

**Files:** create `WaterBuddyUITests/LockScreenProbe.swift`, then **delete it** before anything else is
staged (`tasks/lessons.md`, 2026-10-07, *Renders without a product hook*). Run **after** Task 3: this
task logs a real serving into the simulator's store and changes its language for a while, and the gate
must not see either.

**The placing is attempted, not promised** (spec §7.4). The Lock Screen editor is SpringBoard's, and its
labels on iOS 26.5 are not known in advance: each step dumps SpringBoard's accessibility tree, the next
step is written from the dump, and **two failed attempts at any one step end the task** — the probe is
deleted, and the report says what was and was not placed. macOS accessibility (System Events,
`tasks/lessons.md` 2026-09-02) is the fallback route for a step XCUITest cannot reach, under the same
two-attempt rule.

- [ ] **Step 1: Record what this task will change, to put it back**

```bash
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 content_size
```

Expected: `large` (read 2026-10-08). Write the value down; Step 7 restores it.

- [ ] **Step 2: Write the probe's first test — open the editor and dump it**

```swift
// THROWAWAY — deleted before anything is staged. Captures for spec 2026-10-08-lock-screen-widget §7.4.
import XCTest

final class LockScreenProbe: XCTestCase {

    private let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    private func shot(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// What SpringBoard exposes right now. The next step's labels are read from here, never guessed
    /// a second time.
    private func tree(_ name: String) {
        let attachment = XCTAttachment(string: springboard.debugDescription)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// One labelled tap — or, when the label is not there, the tree and a screenshot, and a failure.
    private func tap(_ label: String, timeout: TimeInterval = 5) {
        let element = springboard.descendants(matching: .any)[label].firstMatch
        guard element.waitForExistence(timeout: timeout) else {
            tree("missing \(label)")
            shot("missing \(label)")
            XCTFail("SpringBoard shows no element labelled \(label)")
            return
        }
        element.tap()
        sleep(1)
    }

    /// Sleeps the screen, then wakes it on the Lock Screen. `pressLockButton` is `XCUIDevice`'s private
    /// side-button press — acceptable in a probe that never ships.
    private func showTheLockScreen() {
        let side = NSSelectorFromString("pressLockButton")
        guard XCUIDevice.shared.responds(to: side) else {
            return XCTFail("no side-button press on this toolchain — use the macOS accessibility route")
        }
        XCUIDevice.shared.perform(side)
        sleep(2)
        XCUIDevice.shared.perform(side)
        sleep(2)
    }

    /// Home's vessel value — "N percent. X of Y millilitres." — the probe's measure of a logged Glass.
    /// The app reopens on whichever tab it was on, so it asks for *Home* first (`AppTab.title(in:)`).
    private func homeTotal(_ app: XCUIApplication) -> String {
        app.activate()
        sleep(2)                  // the foreground `refresh()` re-reads the total the extension wrote
        app.buttons["Home"].firstMatch.tap()
        let vessel = app.descendants(matching: .any)["Today's hydration"].firstMatch
        guard vessel.waitForExistence(timeout: 10) else { return "no vessel" }
        return vessel.value as? String ?? "no value"
    }

    func test1_theEditorOpens() {
        XCUIApplication().launch()   // registers both widget kinds with the system
        showTheLockScreen()
        shot("1 lock screen"); tree("1 lock screen")
        springboard.press(forDuration: 2)
        sleep(2)
        shot("2 long press"); tree("2 long press")
    }
}
```

- [ ] **Step 3: Run it and read the dump**

```bash
pgrep -x xcodebuild >/dev/null || xcrun simctl shutdown all
rm -rf $SP/probe.xcresult $SP/probe
xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
  -destination 'platform=iOS Simulator,OS=26.5,name=iPhone 17' -parallel-testing-enabled NO \
  -only-testing:WaterBuddyUITests/LockScreenProbe/test1_theEditorOpens \
  -resultBundlePath $SP/probe.xcresult > $SP/probe.log 2>&1; echo "exit $?"
xcrun xcresulttool export attachments --path $SP/probe.xcresult --output-path $SP/probe
ls $SP/probe
```

Look at the screenshots with `Read`, and grep the tree attachments for the editor's buttons.

- [ ] **Step 4: Place the three shapes** — a second test, written from Step 3's dump. On iOS 17 and 18
  the route was *Customize* → the Lock Screen's preview → *Add Widgets* → *WaterBuddy* → the circle,
  then the rectangle → close → the date above the clock → *WaterBuddy* → the line → *Done*; on iOS 26.5
  it is whatever the dump shows. The first draft, in iOS 17/18's labels — each one is replaced by the
  dump's before the run that reaches it:

```swift
    func test2_placeTheWidgets() {
        XCUIApplication().launch()
        showTheLockScreen()
        springboard.press(forDuration: 2)
        sleep(2)
        tap("Customize");   tree("3 customize");   shot("3 customize")
        tap("Lock Screen"); tree("4 editor");      shot("4 editor")
        tap("Add Widgets"); tree("5 gallery");     shot("5 gallery")
        tap("WaterBuddy");  tree("6 waterbuddy");  shot("6 waterbuddy")
        // The app's sizes are cells in the order its `supportedFamilies` lists them: circle, then
        // rectangle. Tapping a cell adds that size.
        springboard.cells.element(boundBy: 0).tap(); sleep(1)
        springboard.cells.element(boundBy: 1).tap(); sleep(1)
        tap("Close");       tree("7 closed");      shot("7 closed")
        tap("Date")                                  // the inline slot above the clock
        tap("WaterBuddy")
        springboard.cells.element(boundBy: 0).tap(); sleep(1)
        tap("Close")
        tap("Done");        tree("8 done");        shot("8 done")
        showTheLockScreen()
        shot("9 placed")
    }
```

  Run it as in Step 3 with `-only-testing:WaterBuddyUITests/LockScreenProbe/test2_placeTheWidgets`,
  fixing one step per run from the dump — **two failed attempts at one step, and the task stops here**.

- [ ] **Step 5: Captures — English, Russian, Uzbek, then large text** — a third test. The app's own
  language rows are buttons labelled `English`, `Русский`, `O‘zbekcha` and, in English, `Follow device`
  (`SettingsView.row(_:)`); the Settings tab is `Settings` while the app is in English, and the app
  reopens on the tab it was on.

```swift
    func test3_capture() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Settings"].firstMatch.tap()

        showTheLockScreen()
        shot("10 en")

        app.activate()
        app.buttons["Русский"].firstMatch.tap()
        sleep(3)                  // the language setter rings the widget doorbell; give WidgetKit a beat
        showTheLockScreen()
        shot("11 ru")

        app.activate()
        app.buttons["O‘zbekcha"].firstMatch.tap()
        sleep(3)
        showTheLockScreen()
        shot("12 uz")

        // Put the language back: English names itself in every language, then *Follow device*.
        app.activate()
        app.buttons["English"].firstMatch.tap()
        app.buttons["Follow device"].firstMatch.tap()
        sleep(3)
        showTheLockScreen()
        shot("13 back to follow device")
    }
```

  Run it as in Step 3. Then large text, captured by `test1_theEditorOpens`'s first half (it shoots the
  Lock Screen before the long press):

```bash
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 content_size accessibility-extra-large
```

  Run `test1_theEditorOpens` again as in Step 3, keep its `1 lock screen` shot, then **restore**:

```bash
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 content_size large
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 content_size
```

  Expected: `large` (or Step 1's value). Look at every shot: the ru shot must read *62 %*-style with a
  space and Russian millilitres (*мл*, *из*); the uz shot *ml dan* after the goal; nothing truncated.

- [ ] **Step 6: One tap of the + — and, only if it does nothing, the control** — a fourth test:

```swift
    func test4_thePlusLogsTheGlass() {
        let app = XCUIApplication()
        app.launch()
        let before = homeTotal(app)
        showTheLockScreen()
        // The Lock Screen's button is labelled "Add N millilitres" — N is the user's Glass.
        let plus = springboard.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Add '")).firstMatch
        XCTAssertTrue(plus.waitForExistence(timeout: 5), "no pour button on the Lock Screen")
        plus.tap()
        sleep(3)
        let after = homeTotal(app)
        let attachment = XCTAttachment(string: "before: \(before)\nafter: \(after)")
        attachment.name = "14 the plus"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
```

  Run it as in Step 3 and read `14 the plus`. **A changed total** is the Lock Screen's **+** working on
  this simulator. **An unchanged one** sends the same tap to the Home Screen widget's **+** (placed by
  the same dump-driven route, same two-attempt rule), and reads `linkd` for a refusal:

```bash
xcrun simctl spawn EE56B958-E33F-40A3-99EA-B14D45963685 log show --last 5m \
  --predicate 'process == "linkd"' | grep -iE 'reject|teamId|bundleIdentity' | head
```

  Both unchanged, with `linkd` rejecting: the simulator refuses intents (#63), and both buttons go to
  the owner's device. Home's **+** working while the Lock Screen's does not: a defect — **stop and
  report it** before Task 5.

- [ ] **Step 7: Put everything back, then delete the probe**

```bash
xcrun simctl ui EE56B958-E33F-40A3-99EA-B14D45963685 content_size
rm WaterBuddyUITests/LockScreenProbe.swift
git status --short WaterBuddyUITests/
```

Expected: Step 1's value; `git status` prints nothing for `WaterBuddyUITests/` (the file joined the
target the moment it existed, and leaves it the moment it is gone). The app's language must read
*Follow device* — Step 5's last shot shows it. **If `test3_capture` stopped before that shot**, put the
language back before deleting the probe: a two-line test that launches the app, taps `Settings` if the
app is in English, then `English`, then `Follow device` — run it, confirm with a screenshot, and only
then delete the file. The serving Step 6 logged stays in the simulator's store as test data (known
issue #5).

---

### Task 5: Records, docs — then stop

**Files:** `HISTORY.md`, `tasks/lessons.md`, `docs/AI_CONTEXT.md`, `docs/WIDGET.md`, `CLAUDE.md`; the
spec's status line.

- [ ] **Step 1: `@Test` counts by the attribute** (rule `85-testing`) — unchanged by this work:

```bash
grep -chE '^[[:space:]]*@Test' WaterBuddyTests/*.swift | awk '{s+=$1} END {print s}'
grep -chE '^[[:space:]]*@Test' WaterBuddyWatchTests/*.swift | awk '{s+=$1} END {print s}'
```

Expected: `371` and `57`.

- [ ] **Step 2: `HISTORY.md` checkpoint**, appended with `Edit` at the end of the file:
  `## [2026-10-08] — WaterBuddy on the Lock Screen` — what changed, the owner's rulings (spec §1),
  files touched with line counts, the two RED builds and the GREEN one, the gate's exact lines, the
  warning comparison, every simulator finding (placed or not, the captures, the **+**), and what was not
  run (the owner's device check, spec §7.5).
- [ ] **Step 3: `tasks/lessons.md`**, appended:
  - *A view's own `@Environment` comes from above it.* `.environment(\.strings, …)` in a body reaches
    only the views below; `HydrationView.medium` reads its own `strings` and so draws its two lines in
    the device's language. The Lock Screen widget reads strings only in child views.
  - *A percentage at exactly .5 is the `Double`'s to decide.* 1,150 of 2,000 is `57.49999999999999` and
    rounds to 57; it was said as 58 in conversation, uncomputed.
- [ ] **Step 4: `/doc_sync`** — `docs/AI_CONTEXT.md` (the new file and its line count, the counts, the
  gate, the simulator findings; **known issue #68**: `HydrationView.medium` resolves `%1$d ml` and
  `of %1$d ml` through `HydrationView`'s own `strings`, so a medium widget draws those two lines in the
  device language while the rest follows the app — found by reading on 2026-10-08, not yet rendered,
  not fixed here; the device check pending), `docs/WIDGET.md` (a Lock Screen section, the configuration
  table, a bundle of two widgets), `CLAUDE.md` (the target table's extension line; "put the widget on
  the Home Screen" gains the Lock Screen), `docs/STATE.md` and `docs/DESIGN.md` checked (no stored shape
  and no token changes).
- [ ] **Step 5: The spec's status line** — "**Not implemented.**" becomes what was done, with the gate
  and the simulator's results, and "**Not done until the owner's device check** (§7.5)".
- [ ] **Step 6: Stage by explicit path and stop** — the plan, the spec (re-staged), the three source
  files, the five rule files, and the docs Steps 2–5 touched:

```bash
git add docs/superpowers/plans/2026-10-08-lock-screen-widget.md \
        docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md \
        HISTORY.md tasks/lessons.md docs/AI_CONTEXT.md docs/WIDGET.md CLAUDE.md
git diff --cached --name-status
git diff --name-status
```

  The second list must hold only the five set-aside paths (#50's four and `.claude/settings.json`). No
  `git commit` until the owner runs `/commit`; `/commit` groups the rule files as their own change. The
  owner's device check (spec §7.5) follows.
