# The Lock Screen widget — design

**Status:** approved by the owner in conversation on 2026-10-08 — three rulings (what the Lock Screen
may show, which shapes, what a tap does), the approach (a second widget in the existing extension),
then three sections: what the user sees, how it is built, and the proof, rules and limits. **The
written spec was approved by the owner the same day ("go"), §5's rule wording with it, as written** —
the roadmap flagged this item as one where rule `70-privacy` must decide, and rules change only when
the owner decides (rule `99-docs-cascade`), so that approval came before any code. **Implemented
the same day**, from `docs/superpowers/plans/2026-10-08-lock-screen-widget.md`, and staged for the
owner's `/commit`: the gate green but for #62 (pre-existing — HEAD's export fails it identically), no
new warning by clean builds, and all three shapes placed on the simulator's Lock Screen and captured
in English, Russian and Uzbek. A fresh final review ("with fixes") led to two additions, both in §3.5.
**Not done until the owner's device check (§7.5):** the **+** has never logged — the simulator's
`linkd` refuses the ad-hoc-signed extension (#63) — and the quiet form and VoiceOver's reading can be
seen only on a device. Roadmap item 5, the second of the roadmap's *Next* group. Three details
differ from what was said in conversation, each settled on evidence here: the gallery's sample reads
**57%**, not 58% (§3.1); the quiet form's text is *Hydration*, not *Today's hydration* (§3.2); and the
quiet form's button speaks *Log Water* rather than its amount (§3.6).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `562157e` on 2026-10-08. Claims about
Apple's platform carry their source. **SDK** is
`iPhoneSimulator27.0.sdk/System/Library/Frameworks/<Framework>.framework/Modules/<Module>.swiftmodule/arm64-apple-ios-simulator.swiftinterface`
in Xcode 27.0 (27A266a) on this machine. **Re-read** marks a quotation fetched and read verbatim in
this session, from Apple's documentation (the JSON behind `developer.apple.com/documentation/…`) or a
WWDC session page. **Reported** marks one from this session's research pass, with its URL, not re-read.
Anything else is marked computed, inferred or unconfirmed.

---

## 1. What is being built

A user adds WaterBuddy to their iPhone Lock Screen and sees today's water without unlocking: a ring
that fills, a card with the millilitres and a **+** that logs their Glass, or a drop and a percentage
beside the date. If they have told iOS to hide Lock Screen widgets while locked, every figure
disappears until the phone unlocks.

The owner's rulings, in the order they were asked:

- **What the Lock Screen may show:** the user's own figures, each marked privacy-sensitive, so the
  user's iOS setting hides them as it hides notification previews. Shown by default, because the user
  placed the widget. Not a ring without digits, and not the Data Protection entitlement.
- **Which shapes:** all three — the circle, the rectangle, and the line above the clock.
- **What a tap does:** the rectangle's **+** logs the Glass; every other tap opens the app.
- **How it is built:** a second widget in the existing extension — not new families on the Home
  Screen widget, and not a new extension.

## 2. What happens today

- `WaterBuddyWidgetExtension` holds one widget, `WaterBuddyWidget` (`kind` `"WaterBuddyHydration"`):
  `.systemSmall` and `.systemMedium`, `.contentMarginsDisabled()`, glass over `WidgetAurora`, and a
  `PourButton` that runs `AddWaterIntent(amount: entry.snapshot.serving)`. `WaterBuddyWidgetBundle`
  lists it alone.
- WaterBuddy draws nothing on the iPhone Lock Screen. The watch's `.accessoryCircular` complication
  (`WaterBuddyWatchWidget`) is a different target on a different device.
- Rule `70-privacy` holds the lock screen to a public-surface standard for two things, reminder copy
  and Siri's reply, both digit-free. Its *WatchConnectivity* carve-out names one surface outside the
  apps' own screens, the watch's complication, and cites the phone's Home Screen widget as precedent.
  Its description line reads "nothing on a lock screen the user did not consent to".
- `PourButton` — and with it `PourButton.minimumTarget`, the 44pt floor rules `40-widget` and
  `65-accessibility` name — is `private` to `WaterBuddyWidget.swift`.

## 3. The design

### 3.1 What the user sees

```
            normal                          quiet form (the user's setting hides
                                            Lock Screen widgets; phone locked)
 line:      💧 62%                          💧 Hydration

 circle:    ( 62% )  ring fills to 62%      (  💧  )  ring empty

 rectangle: ┌──────────────────────┐        ┌──────────────────────┐
            │ 1150 ml         ╭───╮│        │ 💧 Hydration    ╭───╮│
            │ of 2000 ml      │ + ││        │                 │ + ││
            │ ▓▓▓▓▓▓░░░░      ╰───╯│        │ ░░░░░░░░░░      ╰───╯│
            └──────────────────────┘        └──────────────────────┘
```

- **The gallery.** Customize → Lock Screen offers one WaterBuddy widget in three sizes, under the Home
  Screen widget's two gallery strings: *Hydration*, and *"Track today's hydration and log a glass
  without opening the app."* — true of this widget because its rectangle logs a Glass. The gallery
  draws `WaterSnapshot.sample`, never the user's own figures: 1,150 of 2,000 ml, which reads **57%**
  (**computed** — `1150/2000 × 100` is `57.49999999999999` as a `Double`, and `.rounded()` takes it
  down; it was called 58% in conversation).
- **The circle** — `.accessoryCircular`: a ring that fills to today's progress, the percentage in the
  middle.
- **The rectangle** — `.accessoryRectangular`: today's millilitres, the goal under it, a bar that
  fills, and a 44pt **+** on the trailing edge.
- **The line** — `.accessoryInline`: a drop and the percentage, beside the date above the clock.
- **The figures.** The percentage is `WaterSnapshot.percentage` — the rounding the app and the Home
  Screen widget use, so no fifth copy of the formula (known issue #20) — formatted with
  `IntegerFormatStyle`'s `.percent` under the snapshot's locale: *62%* in English and Uzbek, *62 %* in
  Russian (**computed** — an `Int` formats as itself, not ×100). Ring and bar draw
  `WaterSnapshot.progress`, which stops at 100%; the percentage does not, so a big day reads *150%*.
  The millilitre lines reuse the medium widget's own keys, `%1$d ml` and `of %1$d ml`, so they read
  *1150 ml* ungrouped, exactly as the Home Screen does (known issue #39).
- **Taps.** The **+** logs the Glass — `entry.snapshot.serving`, the amount the Home Screen widget's
  button logs. Every other tap, on any shape, opens the app.
- **Language** follows the app's own picker through `entry.snapshot.language`, as on the Home Screen;
  the gallery strings follow the device, as they do there.
- **Midnight.** The shared provider's midnight entry rolls it to zero with nothing opened.
- **One deliberate difference from the watch.** The phone's ring *fills*
  (`.accessoryCircularCapacity`), like the app's vessel; the watch's complication keeps its open ring
  with a marker (`.accessoryCircular`). Matching them is a separate change.

### 3.2 Privacy

- **iOS shows Lock Screen widgets while locked unless the user says otherwise.** "On the iOS Lock
  Screen, the default behavior is to show your content even while the device is locked … However, this
  is configurable in Settings, and users can choose to redact their widget when locked, much like
  Notifications." (**re-read**, WWDC22 session 10050, *Complications and widgets: Reloaded*). The
  setting is *Settings → Face ID & Passcode → Allow Access When Locked → Lock Screen Widgets*
  (**reported**, an Apple Frameworks Engineer at `developer.apple.com/forums/thread/716031`: "Lock
  Screen Widgets and Live Activities both are enabled by default").
- **How the figures are hidden — one trigger, two parts.** Every view that draws a figure — the
  percentage, the millilitres, a fill — carries `.privacySensitive()`, and each shape reads
  `@Environment(\.redactionReasons)` and, when it contains `.privacy`, draws its **quiet form**
  instead: the drop, an empty ring or bar, and the widget's name. Both parts answer the same trigger:
  "SwiftUI redacts views marked with this modifier when you apply the privacy redaction reason."
  (**re-read**, `View.privacySensitive(_:)`), and "To apply a custom treatment the redaction reason can
  be read out of the environment." (**re-read**, `RedactionReasons.privacy`, whose own example branches
  exactly this way). The marks carry a second job: "By default, the privacy mode will show a redacted
  version of the placeholder view your TimelineProvider creates. If you have some elements that are
  sensitive and others that don't need to be redacted, you can use the .privacySensitive modifier to
  mark only some of the views to be redacted." (**re-read**, WWDC22 10050) — so the marks are
  plausibly what tells WidgetKit to render this widget's own private variant, with `.privacy`
  applied, which the quiet form then answers (**inferred**). If WidgetKit draws its redacted
  placeholder instead, the owner sees iOS's standard grey shapes rather than the quiet form — and in
  neither case a figure. *(Corrected after the final review: this bullet said there were two
  independent mechanisms, "either alone" keeping a figure off the Lock Screen; Apple's own page shows
  they share one trigger.)*
- **The quiet form's text is *Hydration*, not *Today's hydration*** as the sketch in conversation had
  it. In Russian, *Today's hydration* is *Потребление воды сегодня* — 24 characters, which the line
  beside the date would cut off. *Hydration* (*Гидратация*, *Suv iste’moli*) is the widget's own name,
  already translated in both catalogues.
- **VoiceOver follows the same split** (§3.5, §3.6): figures are spoken normally, and the quiet form
  speaks none.
- **The button is inert while locked, by Apple's rule.** "On a locked device, buttons and toggles are
  inactive and the system doesn't perform actions unless a person authenticates and unlocks their
  device." (**re-read**, *Adding interactivity to widgets and Live Activities*). `AddWaterIntent`
  declares no `authenticationPolicy`, so it carries the default, `.alwaysAllowed` — "which allows the
  intent to run without authentication, including when the device is locked" (**reported**,
  `AppIntent.authenticationPolicy`) — the same default `LogServingIntent` spells out. Whether that
  default lifts the widget rule is **unconfirmed**, and one developer reports it does not
  (**reported**, `developer.apple.com/forums/thread/738252`, no Apple answer). The design does not
  depend on it: with Face ID the unlock usually happens as the owner looks at the phone, and either way
  a stranger cannot log water on it.
- **Ruled out:** forcing the figures hidden with the Data Protection entitlement,
  `com.apple.developer.default-data-protection` at `NSFileProtectionComplete` — "WidgetKit hides widget
  content when the device is locked" (**reported**, *Creating a widget extension*), and the extension
  then gets no runtime while locked (**reported**, Apple DTS). It would be a second entitlement, which
  rule `70-privacy` forbids without a written justification, and it would blank the Home Screen widget
  in StandBy, which shows while the phone is locked.

### 3.3 Where it lives

| File | Change |
|---|---|
| `WaterBuddyWidget/LockScreenWidget.swift` | **New.** The widget, its view, its button, its previews |
| `WaterBuddyWidget/WaterBuddyWidgetBundle.swift` | `body` lists `LockScreenWidget()` after `WaterBuddyWidget()` |
| `WaterBuddyWidget/WaterBuddyWidget.swift` | One word: `private struct PourButton` → `struct PourButton`, so the new button reads the one `minimumTarget` rather than spelling a second 44 |

The new file sits in the extension's own synchronized folder, so it joins `WaterBuddyWidgetExtension`
and no other target: no `project.pbxproj` edit, no exception set, no scheme.

**Untouched:** the six shared files; every `DataManager.Key`; all four entitlement files; every
Info.plist key; all four `PrivacyInfo.xcprivacy` files (no new required-reason API); both widget
catalogues (§3.7); the app (§4); every watch target; `AddWaterIntent`.

### 3.4 The widget

```swift
struct LockScreenWidget: Widget {

    static let kind = "WaterBuddyLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: HydrationProvider()) { entry in
            LockScreenView(entry: entry)
        }
        .configurationDisplayName("Hydration")
        .description("Track today's hydration and log a glass without opening the app.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
```

- **The same provider, deliberately.** `HydrationProvider` gives the Lock Screen exactly what the Home
  Screen gets: `getSnapshot` draws `.sample` in the gallery and `DataManager.snapshot(now:)` otherwise,
  and `getTimeline` emits the current entry and the midnight `rolledOver()` entry with
  `.after(midnight)`. A second provider would be a second read path to keep identical.
- **No `.contentMarginsDisabled()`.** It is configuration-wide: the Home Screen needs it for its
  edge-to-edge aurora, and the Lock Screen wants iOS's own margins.
- **The two gallery strings are the Home Screen widget's static literals**, so rule `40-widget`'s ban
  on interpolation holds and nothing new needs translating.
- **The families are available at the floor.** `.accessoryCircular`, `.accessoryRectangular`,
  `.accessoryInline`, `WidgetRenderingMode` and `AccessoryWidgetBackground` are iOS 16.0;
  `.accessoryCircularCapacity` and `.accessoryLinearCapacity` iOS 16.0 (**SDK**). The extension
  deploys to 17.0, so no `#available` is needed.
- The `kind` is a new string. It names the widget to WidgetKit and appears nowhere a user reads.

### 3.5 The view

`LockScreenView` (`entry: HydrationEntry`) reads `\.widgetFamily`, `\.redactionReasons` and
`\.strings`, and switches on the family. At its root, as `HydrationView` does, it injects
`.environment(\.strings, entry.snapshot.language.bundle)` and
`.environment(\.locale, entry.snapshot.language.locale)`, and it declares a
`containerBackground(for: .widget)` that holds nothing: "If a widget doesn't support removable
background views or doesn't explicitly mark a background as nonremovable, the system displays a warning
message that overlays the widget during development with Xcode", while the Lock Screen draws widgets
"without a background" anyway (**re-read**, *Displaying the right widget background*).

| | normal | quiet form (`redactionReasons.contains(.privacy)`) |
|---|---|---|
| circle | `Gauge(value: progress)` in `.accessoryCircularCapacity`, its current value `Text(percentage, format: .percent)` | the same gauge at `0`, a `drop.fill` in the middle |
| rectangle | `Text` from `%1$d ml` (headline), `Text` from `of %1$d ml` (`.secondary`), `Gauge(value: progress)` in `.accessoryLinearCapacity`; the button trailing | `Label` *Hydration* with `drop.fill`, the bar at `0`; the button trailing |
| line | `Label { Text(percentage, format: .percent) } icon: { Image(systemName: "drop.fill") }` | `Label` *Hydration* with `drop.fill` |

- Every figure-bearing view in the normal column carries `.privacySensitive()` (§3.2).
- Text uses text styles with `.lineLimit(1)` and `.minimumScaleFactor(0.6)` — the medium widget's own
  floor — so a five-digit total or a long locale shrinks rather than truncating. **The ring's
  percentage takes 0.4**, the Home Screen vessel readout's floor (`MiniVessel.readout`, the other
  percentage drawn inside a circle). *(Corrected during implementation: this read 0.6 for every text.
  On the simulator, Russian's wider* 38 % *truncated to* 38… *inside the ring at 0.6, and drew whole at
  0.4.)*
- **Accessibility.** The circle and the line are one element each, and so is the rectangle's text
  column — which does not contain the button, so `.accessibilityElement(children: .ignore)` on it hides
  no control (rule `65-accessibility`): label `Today's hydration`, value
  `%1$d percent. %2$d of %3$d millilitres.` with `percentage`, `currentWater` and `dailyGoal` — the
  Home Screen vessel's own pair. In the quiet form, the label alone. The drop glyph is decorative and
  hidden. Inside the ring and the rectangle, each drawn figure, gauge and glyph also carries
  `.accessibilityHidden(true)`, as rule `65-accessibility` hides "the widget's hero total and goal
  lines" — added after the final review. **What VoiceOver actually says is unproven here:** on the
  simulator, SpringBoard's tree (read through XCUITest) lists the drawn texts beneath each combined
  element *with or without* those flags, and wraps each widget in a SpringBoard button of its own, so
  it shows SpringBoard's grouping rather than VoiceOver's stops. The owner's device check reads it
  (§7.5, step 9).
- **The card's figures carry `.invalidatableContent()`** — rule `40-widget`'s marking for the figures an
  intent changes — so a tap of the **+** shows at once that it registered, rather than leaving a stale
  total looking current until the reload and inviting a second tap and a second Glass. Added after the
  final review; its effect is visible only where the intent runs, on the owner's device (step 5).
- **No branch on `widgetRenderingMode`.** "it renders widgets on the Lock Screen on iPhone using the
  vibrant mode" (**re-read**, `WidgetRenderingMode`); the accessory families appear on iPhone only
  there, and the app is iPhone-only (`TARGETED_DEVICE_FAMILY = 1`, rule `15-project`). Vibrant mode
  "desaturates the widget, making a monochrome version" (**re-read**, the same page), so gauge styles
  and hierarchical foreground styles (`.primary`, `.secondary`) carry the hierarchy, not colour; "To
  ensure legibility, avoid using transparent colors in this mode" (**re-read**, WWDC22 10050). No
  glass, no `Aurora` colour, no `colorScheme` override.

### 3.6 The button

A private view in the new file:

- `Button(intent: AddWaterIntent(amount: serving)) { label }`, with `serving` from
  `entry.snapshot.serving` — `init(amount:)`, never `init()`, exactly as `PourButton` does, so the
  amount logged comes from the same snapshot as everything drawn beside it (rule `40-widget`).
- Its label is `Image(systemName: "plus")` over `AccessoryWidgetBackground()` clipped to a circle,
  framed to a `PourButton.minimumTarget` square, with `.contentShape(Circle())`.
  `AccessoryWidgetBackground` is "black in the vibrant environment, which results in a low brightness
  and full blur" (**re-read**, WWDC22 10050) — the system's own backing, where `PourButton`'s tinted
  fallback would draw a white rim at 0.45 opacity, the transparent colour vibrant mode advises against.
- `.buttonStyle(.plain)`.
- **Its VoiceOver label carries the amount only when the figures show.** Normally it is the existing
  `Add %1$d millilitres` with `serving`. In the quiet form it is *Log Water* — the intent's own title,
  already in the widget's catalogue in all three languages and checked by
  `theShortcutsVocabularyIsTranslated` — because a serving size is a figure too, and §3.2's split
  covers speech as well as sight. This detail was not in the conversation.
- No `.privacySensitive()` on the button: its face draws no figure.

### 3.7 Strings

Every string the widget draws or speaks is already in the widget's catalogue in all three languages:

| Key | Where | Checked by |
|---|---|---|
| `Hydration` | gallery name; the quiet form's text | `sharedKeys` |
| `Track today's hydration and log a glass without opening the app.` | gallery description | `sharedKeys` |
| `Today's hydration` | every figure element's VoiceOver label | `sharedKeys` |
| `%1$d percent. %2$d of %3$d millilitres.` | every figure element's VoiceOver value | `sharedKeys` |
| `%1$d ml` · `of %1$d ml` | the rectangle's two lines | `sharedKeys` |
| `Add %1$d millilitres` | the button's VoiceOver label | `sharedKeys` |
| `Log Water` | the button's VoiceOver label, quiet form | `theShortcutsVocabularyIsTranslated` |

The percentage needs no key (`.percent`). **No catalogue change is expected.** The build appends every
extracted literal to its target's catalogue (`tasks/lessons.md`, 2026-08-29, *half contract and half
build output*), and the Xcode app rewrites tracked catalogues on its own (known issue #50), so after
the first build `git diff WaterBuddyWidget/Localizable.xcstrings` is read, and anything it shows is
examined rather than staged blind.

## 4. What it touches beyond the widget

- **Reloads.** `DataManager.requestWidgetReload()` — the production default of the `reloadWidgets`
  hook — calls `WidgetCenter.shared.reloadAllTimelines()`, which "Reloads the timelines for all
  configured widgets belonging to the containing app" (**reported**), so the app's every write and
  `AddWaterIntent.perform()`'s own explicit reload refresh both kinds. "Interactions with a toggle or
  button always guarantee a timeline reload." (**re-read**, *Adding interactivity…*).
- **Budget.** "WidgetKit maintains different budgets for each active widget the user adds to their
  device" (**reported**, *Keeping a widget up to date*); the Lock Screen widget's timeline is the Home
  Screen's — two entries a day, plus reloads.
- **The intent's process.** "By default, the system runs the app intent in the same process as the
  widget extension." (**re-read**). That is the `.phoneExtension` role and `AddWaterIntent.perform()`
  as it runs today — its awaited reconcile, and its known gaps (#49, #53).
- **Nothing else:** no app code, no watch code, no shared file.

## 5. What this amends — approved as written by the owner on 2026-10-08

Exact wording, for `.claude/rules/`, approved with the written spec ("go") before any code. It is
written into the rule files with the implementation and staged on its own paths, so `/commit` can make
it its own change, as the Siri phrase's was.

- **`70-privacy`**, *The lock screen is a public surface* — two bullets after the Siri one:
  - "**The phone's Lock Screen widget may show the user's own figures** — the percentage, today's
    total, the goal — because the user put it there, as the watch's complication may on the watch
    face; a notification may not, because it arrives unasked. In return, every view that draws a
    figure carries `.privacySensitive()`, and every shape draws a quiet form — the drop, an empty ring
    or bar, *Hydration* — whenever `redactionReasons` contains `.privacy`, so a user who turns off
    *Allow Access When Locked → Lock Screen Widgets* sees no figure until the phone unlocks, as iOS
    hides a notification's preview. The quiet form speaks no figure either: its elements carry their
    label alone, and its button says *Log Water*"
  - "Never add an entitlement to hide the Lock Screen widget harder. The Data Protection entitlement
    would hide every widget in the extension while locked and give it no runtime — the Home Screen
    widget would go blank in StandBy — and *Nothing leaves the device* already forbids a second
    entitlement without a written justification here"
- **`70-privacy`**, *WatchConnectivity is a ruling, not an omission* — the second condition's opening
  changes from "with one named carve-out: the watch's own complication, on the watch's own face." to
  "with two named carve-outs: the watch's own complication, on the watch's own face, and the phone's
  own Lock Screen widget, on the phone's own Lock Screen." The condition gains a closing sentence: "The
  phone's Lock Screen widget joined it in
  `docs/superpowers/specs/2026-10-08-lock-screen-widget-design.md`: `currentWater` counts pours the
  watch authored, so the total it draws is wire-derived too, and it is held to the marking *The lock
  screen is a public surface* sets out."
- **`40-widget`** — a new section before *Proving it*:

  > ## The Lock Screen widget
  > - `LockScreenWidget` is a second widget in the same extension, in its own file: its own `kind`
  >   (`"WaterBuddyLockScreen"`), its own `StaticConfiguration`, and the three accessory families only.
  >   Never add an accessory family to `WaterBuddyWidget` — its configuration is glass over an aurora
  >   with the margins disabled, and every one of those applies to every family it lists
  > - It reads through the same `HydrationProvider` and `HydrationEntry` — never a second provider — so
  >   both widgets draw one snapshot, turn over at one midnight and reload together
  > - It keeps iOS's own margins: `.contentMarginsDisabled()` belongs to the Home Screen configuration.
  >   It still declares an empty `containerBackground(for: .widget)`, which the Lock Screen never draws
  >   — without one, iOS overlays a warning on the widget during development
  > - Its gallery strings are the Home Screen widget's two static literals
  > - Its percentage is `WaterSnapshot.percentage` formatted with `.percent` under the snapshot's
  >   locale — never a second rounding, and never a `%` key
  > - Every figure carries `.privacySensitive()`, and every shape has its quiet form (rule `70-privacy`)
  > - The rectangle's button is `Button(intent: AddWaterIntent(amount: entry.snapshot.serving))`,
  >   `.buttonStyle(.plain)`, framed to `PourButton.minimumTarget` — the one definition both widgets
  >   read. The circle and the line carry no button: two 44pt targets do not fit in the circle, and the
  >   line is a single tap target that only opens the app
  > - It injects `entry.snapshot.language.bundle` and `.locale` at its root, as `HydrationView` does

  And *Proving it*'s last bullet gains a clause: "— and the Lock Screen widget on the Lock Screen, in
  all three shapes, with *Lock Screen Widgets* under *Allow Access When Locked* both on and off".
- **`60-design-system`**, *In the widget* — one bullet: "The Lock Screen widget draws no glass and no
  `Aurora` colour. iOS renders the iPhone Lock Screen in the vibrant mode, which desaturates the widget
  into its own material, so it is built from the system's accessory vocabulary instead —
  `.accessoryCircularCapacity` and `.accessoryLinearCapacity` gauges, `.primary`/`.secondary`
  foreground styles, `AccessoryWidgetBackground` behind the button — with no branch on
  `widgetRenderingMode` and no `colorScheme` override"
- **`65-accessibility`**, *VoiceOver* — one bullet: "The Lock Screen widget's figures are one element
  per shape — label *Today's hydration*, value the vessel's own percent-and-millilitres string — and
  its quiet form speaks no figure: the label alone, and *Log Water* on the button. A figure hidden from
  sight is hidden from speech"
- **`85-testing`**, *A green suite is not proof the product works* — "**Neither widget's rendering has
  any automated coverage, on either platform** — the phone widget and the watch's `.accessoryCircular`
  face are both proved only by placing them and looking." becomes "**No widget's rendering has any
  automated coverage, on either platform** — the phone's Home Screen and Lock Screen widgets and the
  watch's `.accessoryCircular` face are all proved only by placing them and looking."

`/doc_sync`'s, not this section's: `CLAUDE.md`'s target table and its "put the widget on the Home
Screen" line, `docs/WIDGET.md` (a Lock Screen section, the configuration table, a bundle of two), and
`docs/AI_CONTEXT.md`.

## 6. Testing

- **No new unit test, and why.** Everything the Lock Screen computes is already pinned:
  `WaterSnapshot.percentage`, `.progress` and `rolledOver()` by `WaterSnapshotTests`; a read path that
  writes nothing by `readingLeavesTheStoreUntouched` and `readingAnEmptySuiteDoesNotCreateKeys`; every
  string it draws or speaks, in every shipped language, by `LocalizationTests` (§3.7). What is new is a
  view in a target that no test target compiles, and WidgetKit has no API that lists a widget's
  families. A test written so that one exists would test nothing (rule `85-testing`).
- **RED is the widget build.** `LockScreenWidget()` goes into `WaterBuddyWidgetBundle` first, and
  `xcodebuild build -scheme WaterBuddyWidgetExtension` must fail on the missing type. The new file's
  first draft reads `PourButton.minimumTarget` while `PourButton` is still `private`, and the build must
  fail on that too. Then the visibility change and the widget, and the build passes.
- **The existing suites stay green across the change** — the gate (§7.1).

## 7. Verification

### 7.1 The gate

Rule `85-testing`'s five invocations, `xcrun simctl shutdown all` first, one simulator at a time,
`-parallel-testing-enabled NO`. The phone UI run's pre-existing failure (#62) is reported as itself,
with HEAD's result beside it, never hidden.

### 7.2 Warnings

`-scheme WaterBuddyWidgetExtension`, built clean into an empty DerivedData folder at HEAD and again
with the change; unique primary warning lines compared per file and message. That scheme also builds
the app and the watch targets, so it reprints their baseline (`docs/AI_CONTEXT.md`). The change passes
with no new line, and with none in `LockScreenWidget.swift`. No other scheme compiles a file this
change touches.

### 7.3 Previews

In `LockScreenWidget.swift`, in the house style: `#Preview(as:)` for each family, with entries at 0,
1,150 and 3,000 of 2,000 ml; and one plain `#Preview` of the three shape views under
`.redacted(reason: .privacy)`, for the quiet forms. *(Corrected while planning: this read "in a
`WidgetPreviewContext` of its family". `WidgetPreviewContext` is iOS 14.0 (**SDK**), but it is applied
through a `PreviewProvider`, whose `static var previews` would be a third `static var` against rule
`43-concurrency`'s census of two.)* They compile in the widget build. Looking at them is the owner's,
in Xcode's canvas — nothing here renders a canvas.

### 7.4 On the simulator

- iPhone 17 on iOS 26.5: the three shapes on the Lock Screen, in the app's three languages and at an
  accessibility text size, captured and looked at. **The placing is attempted, not promised.** The
  Lock Screen editor opens on a long press; the routes are a throwaway UI probe, deleted before
  anything is staged (`tasks/lessons.md`, 2026-10-07, *Renders without a product hook*), and macOS
  accessibility (`tasks/lessons.md`, 2026-09-02). If neither can drive it, that is reported, and
  placement becomes the owner's device check alone.
- The Lock Screen's **+** is tried once it is placed. If it logs, nothing more is needed. If it does
  not, the Home Screen widget's **+** is tried as the control, to tell this simulator refusing intents
  — as `linkd` refused the App Shortcut (#63) — from a defect; if both refuse, both buttons are proved
  on the owner's device only. *(Reordered while planning: this read "the Home Screen widget's **+**
  goes first, as the control" — the control is only needed when the Lock Screen's fails.)*
- The quiet form is seen here only in the previews. The setting that triggers it is checked on the
  owner's device.

### 7.5 The owner's device check

On the owner's own iPhone, beside the checks roadmap items 2 and 4 still wait on:

1. The Lock Screen gallery offers WaterBuddy in three sizes and shows the sample, 57% — not your
   figures.
2. Placed, the three shapes show the same figures as the app and the Home Screen widget.
3. Locked, the figures still show — iOS's default.
4. With *Settings → Face ID & Passcode → Allow Access When Locked → Lock Screen Widgets* off, locked
   and looking away: the quiet form — the drop, an empty ring and bar, *Hydration*, no figure. iOS's
   standard grey redaction shapes instead of the quiet form also pass (§3.2: WidgetKit drew its
   placeholder); **any figure at all fails**. Then looking at the phone: whether Face ID brings the
   figures back while the Lock Screen still shows (§3.2, unconfirmed either way).
5. Locked, **+** asks for Face ID; after it a Glass is logged, and both widgets update.
6. The circle and the line open the app.
7. With the app switched to Russian, the Lock Screen reads *62 %*-style on its next refresh.
8. The next morning, 0% without the app having been opened.
9. **VoiceOver**, swiping through the Lock Screen: each shape is one stop speaking *Today's
   hydration* and the percent-and-millilitres sentence, and the rectangle's **+** a second stop,
   *Add N millilitres*. A figure spoken as a stop of its own, or the ring answering *100%* beside its
   percentage, is a defect (§3.5 — the simulator cannot show this). With step 4's setting off and the
   phone locked: the label alone, and *Log Water* on the button. *(Added after the final review.)*

## 8. Known limitations, and what is not in scope

- **Inherited, exactly as on the Home Screen:** ungrouped *1150 ml* (#39); Russian's single plural in
  the spoken value (#40); a Glass logged from a widget reaches the watch when the phone app next comes
  forward (#53); two quick taps' reconciles may race (#49).
- **Unconfirmed, safe either way:** whether WidgetKit sets `.privacy` in the environment for the Lock
  Screen's private variant (§3.2); how iOS styles its own redaction of a gauge; whether Face ID reveals
  the figures while the Lock Screen still shows; whether Dynamic Type reaches a Lock Screen widget
  (at `accessibility-extra-large` the simulator drew the shapes at the same size as at `large`);
  whether `.alwaysAllowed` lifts the locked-button rule; what VoiceOver says on the Lock Screen
  (§3.5, step 9).
- **No first-hand Apple source covers iOS 27's Lock Screen** — the research found no 2026 entry on
  WidgetKit's updates page. The design uses only iOS 16 API.
- **Not in scope:** the watch's ring style (§3.1); a Lock Screen-only gallery line; StandBy, which keeps
  the Home Screen widget; Control Center, the next roadmap item; the fixes for #39 and #40.

## 9. Sequence

1. This spec, staged by explicit path and not committed — `CLAUDE.md`'s "never commit until the owner
   runs `/commit`" overrides the brainstorming skill's commit step. The owner reviews it, and gives or
   withholds written approval of §5's wording.
2. An implementation plan, `docs/superpowers/plans/2026-10-08-lock-screen-widget.md`; the owner
   chooses how it runs.
3. Implementation: the RED build, the widget, the GREEN build; the gate; the warning comparison; the
   simulator (§7.4); §5's wording as approved, on its own paths; `/doc_sync`; a `HISTORY.md`
   checkpoint; staging; a stop for `/commit`.
4. The owner's device check (§7.5).
