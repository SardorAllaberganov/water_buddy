# The Control Center control — design

**Status:** approved by the owner in conversation on 2026-10-08 — one ruling (what the tile shows: its
name and glyph only), the approach (a value provider over the existing `AddWaterIntent`), then two
sections, what gets built and its behaviour, privacy and rule changes ("all ok"). The owner then asked to
go straight to implementation, so this document and §5's rule wording were written as the record rather
than reviewed as a gate: §5 writes out what section 2 approved, and it sits in the staged diff for the
owner to read before `/commit`. Roadmap item 6, the last of the roadmap's *Next* group. **Implemented the
same day** and staged for the owner's `/commit`. On the simulator a press ran end to end —
`AddWaterIntent.perform()` logged the stored Glass, an edited one included — and a run without §3.6's
reload logged the previous Glass instead (§7.3). A fresh final review found no critical issue; its
corrections are folded in — chiefly `usualSlot` (§3.4), four rule sentences (§5) and an open risk before
the first unlock after a restart (§3.2). **Not done until the owner's device check (§7.4):** a locked
iPhone, a press before that first unlock, a Lock Screen slot, the Action Button and VoiceOver are
device-only.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `be31994` on 2026-10-08. **SDK** is
`iPhoneSimulator27.0.sdk/System/Library/Frameworks/<Framework>.framework/Modules/<Module>.swiftmodule/arm64-apple-ios-simulator.swiftinterface`
(or its `.swiftdoc`, for a doc comment) in Xcode 27.0 (27A266a) on this machine. A claim about how iOS
draws or runs a control that no SDK line states is marked **unconfirmed**; each one is either designed
so that either answer is safe or named in §7.4.

## 1. What is being built

A control that logs the Glass without opening the app. iOS 18 lets one `ControlWidget` appear in three
places: Control Center, the Lock Screen's two control slots (where the torch and the camera sit by
default), and the Action Button (iPhone 15 Pro and later).

## 2. What happens today

- The widget extension has two `StaticConfiguration`s over one `HydrationProvider` — the Home Screen
  widget (`"WaterBuddyHydration"`) and the Lock Screen widget (`"WaterBuddyLockScreen"`) — and both
  buttons run `AddWaterIntent(amount: entry.snapshot.serving)`.
- No version check exists anywhere in the source. The three `@available(watchOS, unavailable)` markers
  in `DataManager.swift` are the only `@available`s, and there is no `#available`.
- `DataManager.requestWidgetReload()` is the widget doorbell — `WidgetCenter.shared.reloadAllTimelines()`
  — rung by the `currentWater`, `dailyGoal`, `servings` and `language` setters and by
  `applyDailyReset(on:)`.
- `AddWaterIntent` leaves `authenticationPolicy` at the protocol's default, `.alwaysAllowed` —
  `LogServingIntent` writes the same value out and calls it "The default".
- The widget catalogue already holds *Log Water* and *Adds a serving of water to today's total in
  WaterBuddy.* in English, Russian and Uzbek — `AddWaterIntent`'s own title and description — and
  `theShortcutsVocabularyIsTranslated` pins both in every shipped language.

## 3. The design

### 3.1 What the user sees

- A tile with the Glass's glyph (`mug.fill`) and the title *Log Water* — *Записать воду*, *Suvni qayd
  etish* — in the app's chosen language. iOS decides how much of it to draw: a small Control Center tile
  draws the glyph alone (seen on the simulator, §7.3); a Lock Screen slot and a wide tile are unobserved.
- **No figure** — no total, no goal, no percentage, no serving size (the owner's ruling).
- The gallery offers it as *Log Water*, "Adds a serving of water to today's total in WaterBuddy.", in
  the phone's language: iOS resolves the two gallery strings itself, as it does both widgets'.
- On the Action Button iOS derives the hint from the display name — its documented default reads
  "Hold for '<display name>'" (SDK doc comment on `controlWidgetActionHint`) — so the control sets none.
- A press logs the Glass. The new total appears on the widgets and in the app, not on the tile.
- On iOS 17 the control is not offered at all.

### 3.2 Privacy

- The tile draws nothing about the user, so it needs neither `.privacySensitive()` — which controls do
  honour: "The system redacts controls marked with this modifier when those controls are displayed on
  the Lock Screen and the device is locked" (SDK doc comment on `ControlWidgetTemplate.privacySensitive`)
  — nor a quiet form. On a locked iPhone it reveals that WaterBuddy is installed, which the Lock Screen
  widget's quiet form reveals too.
- A press is allowed on a locked iPhone without unlocking: `AddWaterIntent` declares `.alwaysAllowed`,
  the default, written out as the Siri phrase writes out its own — logging water is harmless, and
  nothing is said back. That iOS honours it on a locked device is unconfirmed here; §7.4 checks it. If
  iOS asks for the passcode instead, what follows the unlock is unconfirmed too.
- **Before the first unlock after a restart — an open risk.** The App Group store and suite stay
  encrypted until that unlock (the default protection class), so a press iOS ran then would find
  neither. `sharedModelContainer` would fall to a local or in-memory rung and keep it for the life of
  the extension process; the pour would land where the app never reads; `recomputeToday()`, reading a
  store that *succeeded*, could write that one pour as today's total; and `remindersEnabled` would read
  `false`, so the awaited reconcile would clear every pending reminder until the app next came forward.
  The widgets' buttons never reach this state — iOS holds them until an unlock — so the control is the
  first door that might. Whether iOS runs a control's intent before the first unlock at all is unknown
  and untestable on the simulator (§7.4, step 4). If it does, the fix is its own change: `perform()`
  declines unless the store resolved to the App Group rung — or, against the owner's ruling, the intent
  asks for the passcode.
- A figure added to the tile later needs its own ruling in rule `70-privacy` first (§5).

### 3.3 Where it lives

| File | Change |
|---|---|
| `WaterBuddyWidget/LogWaterControl.swift` | new — widget extension only; its synchronized folder gives membership, no `project.pbxproj` edit |
| `WaterBuddyWidget/WaterBuddyWidgetBundle.swift` | one `if #available(iOS 18.0, *)` block (§3.5) |
| `WaterBuddy/DataManager.swift` | `requestWidgetReload()` also reloads controls (§3.6) — compiled into all four signed targets, the call inside `#if os(iOS)`; and `usualSlot`, the one name for the slot the one-tap doors log (§3.4) |
| `WaterBuddyWidget/AddWaterIntent.swift` | `authenticationPolicy` written out as `.alwaysAllowed` — the default, so no behaviour changes — and the control named as a caller (§3.2) |
| `WaterBuddyTests/ServingSeamTests.swift` | two tests pinning `usualSlot` (§6) |
| `WaterBuddyTests/LocalizationTests.swift` | DocC only: the Shortcuts vocabulary test also pins the control's two strings |

### 3.4 The control

- `@available(iOS 18.0, *) struct LogWaterControl: ControlWidget`, with `static let kind =
  "WaterBuddyLogWater"`. **The kind is permanent:** iOS identifies every placed control by it, so a
  renamed kind no longer matches the controls people have already placed.
- `StaticControlConfiguration(kind:provider:content:)` — SDK: `init<Provider>(kind: String, provider:
  Provider, content: @escaping (Provider.Value) -> Content) where Provider : ControlValueProvider`.
- The provider, `private struct LogWaterControlProvider: ControlValueProvider` with `Value ==
  WaterSnapshot`, at file scope as `HydrationProvider` is, so it takes no isolation from the control:
  - `currentValue()` returns `DataManager.snapshot(now: Date())` — the read `HydrationProvider` makes.
    Never `DataManager.shared`, and never a `DataManager` (rule `40-widget`). It is `async throws` only
    because the protocol is; it awaits nothing and throws nothing.
  - `previewValue` is a fixed `WaterSnapshot` — the default Glass, `.system` language — for the
    gallery, which draws before anything has been read.
- The content: `ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving))`, labelled with
  the title and the glyph.
  - The amount is the snapshot's — the Glass, through `DataManager.usualServing(in:)` — never
    `AddWaterIntent()`, whose `init()` seeds `defaultServing`, and never an amount resolved at the press
    (rule `40-widget`).
  - The title is resolved here — `snapshot.language.bundle.localizedString(forKey: "Log Water", value:
    nil, table: nil)` — and handed to `Text` as a finished `String`. Whether iOS resolves a control's
    `Text(key, bundle:)` in the extension or in Control Center's own process is unconfirmed; a finished
    string is in the chosen language either way.
  - The glyph is `vesselSlots[DataManager.usualSlot].symbol` — the Glass's own, read from the menu that
    owns the vessels' glyphs (rule `50-views`), at the one named slot `usualServing(in:)` also reads. A
    second spelling of the index is how the glyph and the amount would drift apart, on a tile with no
    figure to show it (the final review's finding; `usualSlot` replaced a bare `[1]` here).
- `.displayName("Log Water")` and `.description("Adds a serving of water to today's total in
  WaterBuddy.")` — static literals, already translated.
- No `.controlWidgetActionHint`, no tint, no `.privacySensitive()`.

### 3.5 The bundle

```swift
var body: some Widget {
    WaterBuddyWidget()
    LockScreenWidget()
    if #available(iOS 18.0, *) {
        LogWaterControl()
    }
}
```

`WidgetBundleBuilder` takes an `if #available` — SDK (SwiftUI): `buildLimitedAvailability(_ widget: some
ControlWidget)`, itself `@available(iOS 18.0, …)`, over a `buildOptional` that needs iOS 16.1, below
the 17.0 floor. This is the codebase's first version check.

### 3.6 The doorbell

`DataManager.requestWidgetReload()` gains, inside its `#if canImport(WidgetKit)` and an `#if os(iOS)`:

```swift
if #available(iOS 18.0, *) {
    ControlCenter.shared.reloadAllControls()
}
```

- **Why.** iOS builds the control from a value it reads when it chooses, and that value is the Glass
  the button logs and the language of its title. A reload is Apple's documented way to have it read
  again — `reloadAllControls()` "Reloads the templates for all configured controls belonging to the
  containing app" (SDK doc comment). It does not re-read on its own when Control Center opens —
  measured on the iOS 26.5 simulator: with the reload removed, a press made after an edit of the
  Glass logged the previous Glass (§7.3).
- Every path that changes the Glass or the language already rings this function — the `servings` and
  `language` setters.
- `reloadAllControls()`, not `reloadControls(ofKind:)`: a shared file may not name a type that lives only
  in the widget extension (rule `10-architecture`'s import direction), just as `reloadAllTimelines()`
  names no kind.
- `#if os(iOS)`: the two watch targets compile this file and have no control. `ControlCenter` exists on
  watchOS 26 as well (SDK), so the guard states intent rather than making the file compile.
- **Cost:** every pour now also has iOS rebuild the control's template — waking the extension for a
  template that has not changed (`chronod` logs it as `Reload live control … externalRequest`).
  Accepted: one more request beside the timeline reload already made.

## 4. What it touches beyond the widget

`DataManager.swift` is the only shared file changed — §3.6's reload and §3.4's `usualSlot`, which
`usualServing(in:)` now reads: no key, no stored shape, no setter changes. `AddWaterIntent` writes out
the policy it already had. No catalogue, entitlement, Info.plist key, privacy manifest or
`project.pbxproj` line changes.

## 5. What this amends

Section 2's approved substance, written out, as each now stands in its rule file — after the
simulator's findings (§7.3) and the final review, which between them corrected four sentences: the
press's simulator claim, the locked-phone claim, the kind's consequence, and the glyph's index.

**`40-widget`** — a new section after *The Lock Screen widget*, titled so it cannot be mistaken for the
existing *The control*, which is the widgets' in-view button. That section's first bullet is scoped to
match: "The only control **in a widget's view tree** is `Button(intent:)` …".

```markdown
## The Control Center control
- `LogWaterControl` is a third widget in the same extension, in its own file: a `ControlWidget` with
  its own kind (`"WaterBuddyLogWater"`), `@available(iOS 18.0, *)`, listed in `WaterBuddyWidgetBundle`
  inside `if #available(iOS 18.0, *)`. The kind is permanent — iOS identifies every placed control
  by it, so a renamed kind no longer matches the controls people have already placed
- Its `ControlValueProvider` reads only through `DataManager.snapshot(...)` — never
  `DataManager.shared`, and never by constructing a `DataManager`, for the reason the timeline
  provider may not. `currentValue()` is `async` because the protocol is; it awaits nothing
- The button is `ControlWidgetButton(action: AddWaterIntent(amount: snapshot.serving))` — the Glass
  from the snapshot, as both widgets' buttons take it. Never `AddWaterIntent()`, whose `init()` seeds
  `defaultServing`, and never an amount resolved when the control is pressed
- It draws no figure — its title and the Glass's glyph, `vesselSlots[DataManager.usualSlot].symbol`,
  and nothing else (rule `70-privacy`). `usualSlot` is the one name for the slot the one-tap doors
  log; `usualServing(in:)` reads it too, so never spell the index here
- Its title is resolved in the extension's process from `snapshot.language.bundle` and handed to
  `Text` as a finished `String`, so it is in the app's language whichever process draws it
- Its gallery strings are `AddWaterIntent`'s own title and description, as static literals
- `DataManager.requestWidgetReload()` also calls `ControlCenter.shared.reloadAllControls()` on iOS 18:
  iOS builds a control from a value it reads when it chooses — the Glass its button logs, the
  language of its title — and a reload is Apple's documented way to have it read again. Without it, a
  press made after an edit logs the previous Glass (measured on the simulator). Never remove it as
  redundant beside the timeline reload
```

and *Proving it* gains a bullet:

```markdown
- The Control Center control has no automated coverage either: place it in Control Center, in a Lock
  Screen slot and on the Action Button. Its press does run on a simulator — `chronod` performs it,
  where `linkd` refuses the widgets' buttons — so prove there that it logs the stored Glass; a locked
  phone, the Lock Screen slot, the Action Button and VoiceOver need a device
```

**`70-privacy`** — under *The lock screen is a public surface*, after the Lock Screen widget's bullets:

```markdown
- **The control draws no figure.** `LogWaterControl` — in Control Center, in the Lock Screen's
  control slots and on the Action Button, all of them reachable on a locked iPhone — shows its title
  and the Glass's glyph only, so it needs no `.privacySensitive()` and no quiet form. Its press is
  allowed without unlocking — `AddWaterIntent` declares `.alwaysAllowed`, as the Siri phrase does:
  logging water is harmless, and nothing is said back. What iOS does with that press on a locked
  iPhone, and before the first unlock after a restart, is proved only on a device. A figure added to
  the control later needs its own ruling here first
```

**`15-project`** — under the deployment-target bullet:

```markdown
  - **The first version check is the control's.** `LogWaterControl` needs iOS 18, so
    `WaterBuddyWidgetBundle` lists it inside `if #available(iOS 18.0, *)` and
    `DataManager.requestWidgetReload()` reloads controls inside one. The floor stays 17.0, and an
    iPhone on 17 never offers the control. Like the floor itself, the 17.0 side of the check is
    compile-verified only
```

**`60-design-system`** — under *In the widget*:

```markdown
- The Control Center control draws nothing of its own — iOS draws its glyph and title in Control
  Center's own style — so it takes no glass, no `Aurora` colour and no tint
```

**`85-testing`** — *A green suite is not proof the product works*: the list of surfaces proved only by
placing them reads "the phone's Home Screen and Lock Screen widgets, its Control Center control, and
the watch's `.accessoryCircular` face", and the paragraph on what to do after a change gains "— and put
the control in Control Center".

`CLAUDE.md`'s target table and *Verification Before Done* follow in the docs pass (rule
`99-docs-cascade`).

## 6. Testing

- **No unit test of the control itself.** No test target compiles the widget extension —
  `WaterBuddyTests` asserts against the built `.appex`'s bundle but compiles none of its sources — and
  nothing in the control is computed: the snapshot, the serving and both strings are existing ones,
  already pinned (`WaterSnapshotTests`, `ServingSeamTests`, `theShortcutsVocabularyIsTranslated`). The
  Lock Screen widget's §6 is the precedent.
- **`usualSlot`, test-first.** `theUsualServingIsReadFromTheUsualSlot` and `theUsualSlotIsTheGlass`
  (`ServingResolutionTests`) were written before the constant existed: RED on "type 'DataManager' has
  no member 'usualSlot'", GREEN once it did — 11 of 11 in the suite.
- **RED:** the bundle names `LogWaterControl` first, and `xcodebuild build -scheme
  WaterBuddyWidgetExtension` must fail on the missing type. **GREEN:** the same build succeeds once the
  file exists.
- The doorbell's extra call has no unit seam, like the `reloadAllTimelines()` beside it. A throwaway UI
  probe on the simulator (§7.3) proved it end to end, and — run once without it — proved it necessary.

## 7. Verification

### 7.1 The gate

Rule `85-testing`'s five invocations. #62 (`testAServingAddedToYesterdayShowsUnderYesterday`) is
expected to fail, as it does at HEAD.

### 7.2 Warnings

Clean builds of all four schemes, before (a copy of the working tree taken before the first edit) and
after, compared per file and message. No new line is the bar.

### 7.3 On the simulator — run 2026-10-08

iPhone 17, iOS 26.5, through a throwaway XCUITest probe driving SpringBoard (deleted before staging):

- **Offered and placed.** The controls gallery lists *WaterBuddy → Log Water* with the mug glyph. Placed,
  it is a small tile drawing the glyph alone, and Control Center's one button is `WaterBuddyLogWater`,
  labelled *Log Water*.
- **Its title follows the app's picker**, the phone left in English: *Записать воду* after choosing
  Русский, *Suvni qayd etish* after O‘zbekcha, *Log Water* after English — each switch logged by
  `chronod` as `Reload live control … externalRequest` from the app's process.
- **A press runs.** Unlike the widgets' button and the App Shortcut (#63), the control's action goes
  through `chronod`, which ran `AddWaterIntent.perform()` in the extension (`Invoking
  AddWaterIntent.perform()`, `Successfully ran action`).
- **It logs the stored Glass.** Glass dragged 250 → 400 ml in Settings, then a press: today's total rose
  by 400. Dragged back to 250, then a press: by 250. Between each edit and its press the only reload of
  the control was the app's.
- **The reload is necessary.** Run once with §3.6's call removed: after 250 → 400 a press logged 250, and
  after 400 → 250 it logged 400 — each time the Glass from before the edit, the control reloaded only by
  iOS's own reload after a press (`interaction`). The call was then restored, and the function is
  identical to the build the warning comparison measured.
- **On the final code.** After the final review's fixes (§3.4's `usualSlot`, `AddWaterIntent`'s written-out
  policy), the edit-and-press run was repeated: 250 → 400, a press logged 400; back to 250, a press
  logged 250.
- **Not exercised here:** the Lock Screen's control slots, the Action Button, a locked phone, VoiceOver,
  and a wide tile's title on screen (the title was read from SpringBoard's tree).
- **Left on the simulator:** the control, placed; nine presses' servings in today's log, 2,700 ml in
  all (test data, as #5); the Glass and the language as found (250 ml, English).

### 7.4 The owner's device check

On the owner's iPhone (iOS 18 or later), from a team-signed build:

1. Add *Log Water* to Control Center and press it, unlocked: today's total rises by the Glass, and the
   Home Screen and Lock Screen widgets show it. The watch is expected to show it only once the phone
   app next comes forward — known issue #53, which this step also settles for the control.
2. Lock the phone, open Control Center, press: it logs without unlocking. If iOS asks for the passcode
   instead, record it, and what the press does after the unlock (§3.2).
3. Put it in a Lock Screen slot and press it while locked: the same.
4. **Before the first unlock:** set a Glass other than 250, restart the phone, and press the Lock Screen
   control before unlocking. Then unlock and check today's total, today's rows, and that reminders are
   still pending (§3.2's open risk). Record whether the press ran at all.
5. Assign it to the Action Button, if the phone has one, and press: it logs, and iOS shows the glyph and
   *Log Water*.
6. With WaterBuddy open on Home, press the control — from the Action Button, and from Control Center
   pulled over the app: does Home's total move without leaving the app? If not, record it (§8).
7. Change the Glass in the app (say 250 → 300 ml), then press the control: it logs 300.
8. Switch the app to Russian: the tile reads *Записать воду*. Switch back to *Follow device*.
9. With VoiceOver on, the tile speaks *Log Water*.

## 8. Known limitations, and what is not in scope

- No figure on the tile — the owner's ruling; the new total is seen on the widgets.
- The Glass only. A control that asks which vessel to log (an `AppIntentControlConfiguration` with a
  vessel parameter) was not asked for.
- No watch control, though watchOS 26 has `ControlWidget` (SDK) — its own item if wanted.
- In the seconds between an edit of the Glass and iOS reading the control again, a press can log the old
  Glass — the window the Home Screen **+** already has.
- The gallery's two strings follow the phone's language, as both widgets' do: iOS resolves them. So does
  the Action Button's hint, derived from the display name — a Russian tile can sit beside "Hold for
  'Log Water'" on an English phone.
- **Before the first unlock after a restart** — §3.2's open risk, until §7.4 step 4 has run.
- **With WaterBuddy open**, a press may leave Home's total stale: the app re-reads on becoming active and
  on a tab's appearance, and an Action Button press may cause neither. No serving is lost — `addLog`
  re-reads first — but Home disagrees with the widgets until the next activation. Back Tap automations
  could do this before; the Action Button makes it routine. §7.4 step 6 checks it; a fix is its own
  change.
- A drink logged by the control reaches the watch only when the phone app next comes forward, as one
  from the widgets' **+** does (#53).
- **Not this change's, but its exposure grows:** `loadFromStore()` never re-reads `remindersEnabled`, so
  a widget extension that is still alive reconciles against the flag it read at launch. Turning reminders
  on in the app, then pressing the control before iOS ends the extension, files an empty plan and
  clears the pending set until the app next comes forward. Recorded as a known issue; its own fix.
- The iOS 17 side of the version check is compile-verified only — no iOS 17 runtime is installed.

## 9. Sequence

This spec → RED (the bundle) → GREEN (the control) → the doorbell → the rules → warnings (§7.2) → the
gate (§7.1) → the simulator (§7.3) → a review of the diff → the docs pass, `HISTORY.md`, staging.
