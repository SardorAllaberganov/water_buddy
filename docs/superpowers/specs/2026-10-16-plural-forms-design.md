# Plural forms — design

**Status:** the outline was approved by the owner in conversation on 2026-10-16, section by section
("Looks right" to each of three), with six decisions taken as recommended: **D1**, the scope brings
back both counted nouns the redesign held back — the streak chip's and the strip's; **D2**, Apple's
plural variations, formatted with the app's locale, over hand-rolled rules; **D3**, every sentence
formatted from a key goes through one of two helpers — a new one, or the existing `figure` — not only
the counted ones; **D4** and **D5**, where the
two nouns sit and how each yields at large text; **D6**, the widgets' and the watch's figures are
included, closing known issue #39. **D7** (known issue #50's catalogues) is open, for the owner. **D8**
was taken in writing this document, inside the table the owner approved: `Last %1$d days` gets its
forms although it is always 7 today. This document writes the outline out, with §5's rule wording,
for the owner's review **before** the plan and before any code (`docs/ROADMAP.md` §8). Roadmap item
**1.2.6**, known issue **#40**.

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md` (rule `99-docs-cascade`). Where it contradicts the code, the code wins and this document
changes.

**Provenance.** Every claim about the repository was read at HEAD `52ee815` on 2026-10-16, except
those added on 2026-10-17, when a second pair of fresh readers was answered: they were read that day,
at the same HEAD. The
toolchain is Xcode 27.0 on this machine. Two throwaway probes were run on 2026-10-16 in the session's
scratchpad, outside the repository: a three-key catalogue compiled with
`xcrun xcstringstool compile`, and two Swift programs that resolved it through `Bundle` and
formatted it, run on **macOS** (Darwin 27.0) — the first under the process locales `en_UZ` and
`en_US`, the second under an English one its output does not record. Each
claim below is marked **measured** (read or run on this toolchain), **inferred**, or **unconfirmed**.
Nothing has been run on an iOS simulator yet. §6.1's tests are the first to run there, and only
their run once the forms exist shows which locale picks the form (§8).

## 1. What is being built

Every sentence the app, the widgets and the watch build from a key with a count reads in the right
grammatical form: *1 миллилитр, 2 миллилитра, 5 миллилитров, 21 миллилитр* in Russian; *1 millilitre,
2 millilitres* in English. Uzbek, which puts a noun after a number in the singular, is unchanged. With
that in place, the two canvas details the redesign gave up for it come back: Home's streak chip reads
*🔥 12 days*, and History's strip card reads *5 servings*. And since every such sentence is now
formatted with the app's locale, every figure in one is grouped as the screen groups it — including
the widgets' and the watch's, which closes known issue #39.

It is done when:
- for every counted key, in every bundle that holds it, the formatted sentence for 0, 1, 2, 5, 11,
  12, 21, 22, 25, 101, 111 and 1,001 is the form §3.3 lists, in English, Russian and Uzbek;
- the app, the widget and the watch format each shared key into the same sentence for those counts;
- Home's chip and History's strip draw and speak their nouns, and fit, in the three languages, at the
  default text size and the largest accessibility size, on the smallest phone;
- the Home Screen widget, the Lock Screen widget and the watch's serving rows draw grouped figures
  without a figure being cut;
- the gate is green with no new warning.

## 2. What happens today

**One way of formatting, without a locale.** 32 call sites build a sentence as
`String(format: strings.localizedString(forKey: key, value: nil, table: nil), …)`, with no locale
(measured, by grep on `format: (strings|bundle).localizedString`):

| Target | File | Sites |
|---|---|---|
| App | `HistoryView.swift` | 7 |
| App | `HomeView.swift` | 5 |
| App | `WelcomeView.swift` | 4 |
| App | `SettingsView.swift`, `VesselSliders.swift` | 1 each |
| Widget | `WaterBuddyWidget.swift` | 5 |
| Widget | `LockScreenWidget.swift` | 4 |
| Watch | `WristView.swift` | 4 |
| Watch | `WristVessel.swift` | 1 |

The visible volumes on Home, History and Settings do not use it: they go through
`Bundle.figure(_:_:locale:)`, which formats each figure with the locale first and hands it to a
`%n$@` key (`DataManager.swift`, `extension Bundle`).

**Ten keys carry a counted noun, each with one form** (measured, from the four catalogues):

| Key | Holds it | Russian today |
|---|---|---|
| `%1$d millilitres` | app | `%1$d миллилитров` |
| `%1$@, add %2$d millilitres` | app | `%1$@, добавить %2$d миллилитров` |
| `%1$d millilitres to go` | app | `Осталось %1$d миллилитров` |
| `%1$d of %2$d millilitres` | app | `%1$d из %2$d миллилитров` |
| `%1$d percent. %2$d of %3$d millilitres.` | app, widget, watch | `%1$d процентов. %2$d из %3$d миллилитров.` |
| `Add %1$d millilitres` | app, widget | `Добавить %1$d миллилитров` |
| `Use %1$d millilitres` | app | `Выбрать %1$d миллилитров` |
| `Average %1$d millilitres. Best %2$d millilitres. Goal met on %3$d of %4$d days.` | app | `В среднем %1$d миллилитров. Лучший день %2$d миллилитров. Цель достигнута в %3$d из %4$d дней.` |
| `Last %1$d days` | app | `Последние %1$d дней` |
| `Logs %1$d millilitres` | watch | `Записывает %1$d миллилитров` |

Each Russian value is right for only some counts: where no preposition governs the count —
*миллилитров*, *процентов*, *дней* after *Последние* — only for the *many* form (0, 5–20, 25–30, …);
after *из*, which takes the genitive, for every count but the *one* form (1, 21, 101, …). The English ones say
*1 millilitres*. The streak chip draws a flame and a bare number, and the strip card
no count, for exactly this reason (`docs/superpowers/specs/2026-10-09-premium-redesign-design.md`
§12, decision D3; `HomeView.streakChip`'s DocC).

**What the probes found** (measured, on macOS — §8 says why the simulator is still owed):
1. A key given plural variations in a catalogue is compiled into its table's `.stringsdict` and
   **removed from its `.strings`** (the probe's table was `Probe`; the app's is `Localizable`, read
   with `table: nil`). `localizedString(forKey:)` then returns its format key —
   `%#@value@`, or `%1$#@arg1@. %2$d из %3$#@arg3@.` for one with two counted arguments — as an
   `__NSLocalizedString` that carries the forms with it.
2. **`String(format:)` with no locale chooses the form by the English rule**, whatever the table's
   language, under both process locales tried — `en_UZ` and `en_US`, both English; no Russian
   process locale was tried: the Russian table gave *Добавить 5 миллилитра*, *Добавить 21
   миллилитра*, *Добавить 111 миллилитра*. On a phone in English with the app in Russian — the
   case the app's own language setting exists for — plural variations alone would only trade
   errors in this code. Where no preposition governs the count, *1 миллилитр* and the *few* counts
   come right, *5*, *11* and *111 миллилитров* turn into *миллилитра*, and *21* and *101* stay
   wrong. After *из* it runs the other way: *из 2001 миллилитра* comes right, and *из 2000* and
   *из 2002 миллилитров*, right today, turn into *миллилитра*.
3. **The rule follows the locale passed to the format, not the bundle**: the Russian table formatted
   with `en_US` gave the English rule's forms; with every Russian locale tried it gave the right
   ones — *1 миллилитр, 5 миллилитров, 11 миллилитров, 21 миллилитр, 111 миллилитров,
   1 241 миллилитр*.
4. **Every locale tried that gives the Russian rule also groups `%d`**, `%ld` and `%lld`: *1 240*.
   Tried: `ru`, `ru_RU`, `ru_RU_POSIX`, `ru@numbers=latn`, `ru_RU@numbers=latn`, `ru-u-nu-latn`, and a
   `Locale.Components` with `ru` and `latn`. Only `en_US_POSIX` printed *1240* — with the English
   rule. None of the seven Russian locales tried gives Russian forms and ungrouped figures.
5. `String.localizedStringWithFormat` formats with the process's locale, as it is documented to — the
   second probe, under an English process locale it did not record, gave *Добавить 5 миллилитра*
   and *1,240* — so it is (2) again on a phone whose language is not the app's.

## 3. The design

### 3.1 A second helper beside `figure` (D2, D3)

```swift
extension Bundle {
    nonisolated func localized(_ key: String, _ arguments: any CVarArg..., locale: Locale) -> String {
        String(format: localizedString(forKey: key, value: nil, table: nil),
               locale: locale, arguments: arguments)
    }
}
```

It sits beside `figure(_:_:locale:)` in `DataManager.swift`, which all four targets already compile,
so the shared set does not grow (rule `15-project`). It is `nonisolated`, as `figure` is, so a suite
off the main actor can pin it and the widget's views can call it.

**31 of the 32 sites move to it** — the counted ones and the rest (`Step %1$d of %2$d`,
`Synced %1$dm ago`, the weights, *Next reminder* / *Last drink*'s time, and the widgets' and the
watch's `ml` figures). The 32nd,
`WristVessel.readout`, hands over figures it has already formatted, and moves to `figure` instead,
which is what it does by hand. So a sentence formatted from a key with an argument goes one of two
ways, `localized` or `figure`, both with the locale; under §5's rule, a counted noun added later is not formatted the way
that gets it wrong.

`figure` keeps its `%n$@` keys and its code. Only its DocC changes: its reason, "`%1$d` never
groups", is true only without a locale, and its ruling that spoken strings keep ungrouped figures is
retired by §3.6.

### 3.2 The locale

The injected `\.locale`, set beside `\.strings` at every root — `RootView` in the app,
`HydrationView` and `LockScreenView` in the widget, `WristRoot` on the watch (measured: all four
inject both). It is `AppLanguage.locale`: `Locale(identifier: code)` for a chosen language,
`.autoupdatingCurrent` for *Follow device*.

The view that holds a site reads it, as `figure`'s callers do. Of the types that hold a site, these
read it already: `HomeView`, `WaterVessel`, `HistoryView`, `HistoryCard`, `ServingRow`,
`CalculatorPanel` and `VesselSliders`, and `WristVessel`, whose site moves to `figure`. These gain
the same `@Environment(\.locale)` (measured, each site mapped to its enclosing type): `WelcomeView`,
`ServingSheet`, `DayStrip` (for the new count), `GoalCard`; `LockScreenCard`, `LockScreenPourButton`, `MediumColumn`, `MiniVessel`, `PourButton`;
`WristView`, `WristServingMenu`.

Three helpers outside a view format a count from a `strings:` parameter and take no locale, so each
gains a `locale:` parameter, as `WristVessel.readout` already has one: `WristView`'s
`nonisolated static` `syncedCaption(composedAt:now:strings:)` and `attribution(mirror:now:strings:)`,
which calls it, for *Synced %1$dm ago*; and the Lock Screen widget's
`WaterSnapshot.spokenFigures(in:)`, a `private extension` in `LockScreenWidget.swift`, for the
percentage sentence. Nothing else outside a view formats a count: the reminder's copy and Siri's
reply are digit-free (rule `70-privacy`), and `AddWaterIntent`'s Shortcuts summary is formatted by the
system.

### 3.3 The forms

A key with one counted argument gets `variations.plural` on its localization. A key with a count
elsewhere in the sentence, or with two, gets `substitutions` — one per counted argument, by
`argNum` — and its value names them as `%#@name@` (measured: `xcstringstool` compiles that to
`%n$#@name@` on the argument's own position). English gets *one* and *other*; Russian *one*, *few*,
*many* and *other*; **Uzbek keeps its single value**, because Uzbek puts a noun after a number in the
singular (*5 kun*), which is what its strings already do. Russian's *other* is reached only by a
fraction, which this app never formats; it takes the genitive singular — *1,5 миллилитра*,
*из 1,5 миллилитра*, *1,5 процента*, *из 1,5 дня* — which is the *few* form's word where no
preposition governs the count, and the *one* form's after *из*.

Russian, by category — *one* (1, 21, 101), *few* (2–4, 22–24), *many* (0, 5–20, 25–30, 111):

| Key | English *one* | Russian *one* / *few* / *many* |
|---|---|---|
| `%1$d millilitres` | `%1$d millilitre` | `%1$d миллилитр` / `миллилитра` / `миллилитров` |
| `Add %1$d millilitres` | `Add %1$d millilitre` | `Добавить %1$d миллилитр` / `миллилитра` / `миллилитров` |
| `Use %1$d millilitres` | `Use %1$d millilitre` | `Выбрать %1$d миллилитр` / `миллилитра` / `миллилитров` |
| `Logs %1$d millilitres` | `Logs %1$d millilitre` | `Записывает %1$d миллилитр` / `миллилитра` / `миллилитров` |
| `%1$@, add %2$d millilitres` | *…, add 1 millilitre* | *…, добавить 1 миллилитр* / *2 миллилитра* / *5 миллилитров* |
| `%1$d millilitres to go` | `%1$d millilitre to go` | `Остался %1$d миллилитр` / `Осталось %1$d миллилитра` / `Осталось %1$d миллилитров` |
| `%1$d of %2$d millilitres` | *1 of 1 millilitre* | after *из*, genitive: *из 1 миллилитра* / *из 2 миллилитров* / *из 5 миллилитров* |
| `%1$d percent. %2$d of %3$d millilitres.` | *… of 1 millilitre.* (*percent* does not change) | *1 процент* / *2 процента* / *5 процентов*; and *из 1 миллилитра* / *из 2 миллилитров* / *из 5 миллилитров* |
| `Average … Best … Goal met on %3$d of %4$d days.` | *1 millilitre* (twice), *of 1 day* | *1 миллилитр* / *2 миллилитра* / *5 миллилитров* (twice); and *из 1 дня* / *из 2 дней* / *из 5 дней* |
| `Last %1$d days` (D8) | `Last %1$d day` | `Последние %1$d день` / `Последние %1$d дня` / `Последние %1$d дней` |
| **new** `%1$d days` | `%1$d day` | `%1$d день` / `дня` / `дней` — Uzbek `%1$d kun` |
| **new** `%1$d servings` | `%1$d serving` | `%1$d порция` / `порции` / `порций` — Uzbek `%1$d porsiya` |

A sentence's other words follow its count: *Остался* agrees with *one*. After *из* the noun is
genitive, so *few* and *many* share *миллилитров* and *дней*. The keys keep their English text, so
no reader's key changes and every other catalogue entry stays as it is. The two new keys are added to
the app's catalogue only, with `extractionState` `manual`, as the other keys resolved in code are.

`Last %1$d days` is drawn with `DataManager.historyWindow`, which is 7; its forms cost nothing and
hold if roadmap item 1.4.2 changes the window (D8). Its *one* form keeps the plural adjective —
*Последние 21 день*, as a preposed adjective usually stays plural before a compound numeral ending
in *один*; the
first draft's *Последний* was changed on a reader's doubt — and *Последние 1 день* reads oddly,
which is harmless while the window is 7.

The words are the session's, written by a non-native speaker, and are for the owner to read (§9).

### 3.4 Home: the streak chip (D4)

The number becomes one `Text`, `strings.localized("%1$d days", manager.streak, locale: locale)`:
*12 days*, *12 дней*, *12 kun*. The flame, the font, the white, the capsule and its arrival stay;
the count still rolls (`.contentTransition(.numericText(value:))`) when it rises.

VoiceOver keeps one element: label *Day streak*, and its value becomes the count with its noun —
*12 days*, what the chip draws where the noun fits — rather than a bare number (rule
`65-accessibility`, amended in §5).

The chip shares a row with the title *Today* — *Сегодня* in Russian — in `ScreenHeader`'s accessory.
Where the noun does not fit beside it at the largest text sizes, the chip draws the count alone
rather than being cut to *12 д…*; its spoken value keeps the noun at every size. The mechanism —
`ViewThatFits`, or a rule decided from the header's width — is the plan's, settled by rendering the
smallest phone at the accessibility sizes.

### 3.5 History: the strip's count (D5)

The strip card's heading line reads *When you drank* at the leading edge and the count at the
trailing one — *5 servings*, from `strings.localized("%1$d servings", logs.count, locale: locale)` —
in the week card's label style: `.footnote.weight(.medium)`, white at 0.9. That pair is already
measured on the same pane: the strip's hour label, white 0.9 on `.frosted` + `.raised`, reads
7.72 / 10.04 / 7.71 against a 4.5 floor (`docs/DESIGN.md`, *Strip: hour label*). The count is
measured in its own place before it is recorded (§7.3).

Where the count does not fit beside the heading, it moves under it: a `ViewThatFits` offered the row's
whole width, its one-line candidate `.fixedSize()` (rule `50-views`).

The count is the shown day's servings — the rows the strip draws its bars from. The card appears only
when the day has one (`HistoryView`: `if shownLogs.isEmpty`), so it never reads *0*.

VoiceOver: the heading stays one element — label *When you drank*, value *5 servings*, the header
trait — and the drawn count is hidden, so it is not read twice (rule `65-accessibility`, amended in
§5).

### 3.6 Figures, spoken and drawn (D2, D6)

A count formatted with a locale is grouped. So:
- **Spoken figures group.** VoiceOver says *2,000 millilitres* where it said *2000*, and the Home
  disc's label is *Bottle, add 1,000 millilitres*. The screen already draws *2,000 ml* beside it.
- **The widgets' and the watch's drawn figures group** — the last of known issue #39: the Home Screen
  widget's `%1$d ml`, `of %1$d ml` and `+%1$d ml`, the Lock Screen widget's `%1$d ml` and
  `of %1$d ml`, and the watch's serving rows' `%1$d ml`. *1300 ml* becomes *1,300 ml* — *1 300 мл*.
  Each is one character longer from 1,000; the medium widget's hero scales with
  `@ScaledMetric` and its column's `minimumScaleFactor`, and every one is rendered before it is called
  fitted (§7.3).

### 3.7 What does not change

- The keys, as text — every reader resolves the same key.
- Every `ml` key: an abbreviation does not decline. *мин* and *кг* likewise.
- `figure`'s `%n$@` keys, and their translations. Turning them back into `%d` keys formatted by
  `localized` would now give the same figures, and is not this change.
- The reminder's copy, *Log a Glass*, Siri's reply: digit-free, and untouched.
- The watch complication's `Text("\(entry.percentage)")`: a number with no noun.
- `WaterSnapshot`'s fields, the stores, the keys on `DataManager.Key`, target membership,
  entitlements.

## 4. What it touches beyond the app

- **`WaterBuddyWidget/Localizable.xcstrings`:** `%1$d percent. %2$d of %3$d millilitres.` and
  `Add %1$d millilitres` gain the same forms as the app's, value for value — `LocalizationTests`
  compares them (§6).
- **`WaterBuddyWatch/Localizable.xcstrings`:** the shared percentage key, and the watch's own
  `Logs %1$d millilitres`.
- **`WaterBuddyWatchWidget/Localizable.xcstrings`:** nothing.
- **`DataManager.swift`** is one of the files all three exception sets name, so the helper reaches
  every target with no `project.pbxproj` edit.
- **Known issue #50 (D7).** The watch catalogue holds an unstaged rewrite by Xcode — re-spaced into
  its `"key" : value` style, with three empty extracted entries added (16 keys at HEAD, 19 in the
  tree) — beside Xcode's re-spacing of `WaterBuddyWatchWidget/Localizable.xcstrings` (four empty
  entries added, 2 keys to 6) and of `WaterBuddy/AppShortcuts.xcstrings` (no key added; two phrases
  marked `"extractionState" : "stale"`). Measured: `git diff --stat`, 479, 62 and 70 lines changed,
  and the key counts read from HEAD and the tree. This change edits the first of them. Committed together, the plural forms would ride in the same commit
  as Xcode's reformat, against rule `90-git`'s one logical change per commit.

## 5. What this amends

Typed into the rule files unstaged for the owner's approval, before any code — the order 1.2.5 kept.

**`50-views`**, *Arithmetic belongs to the model*. Now:

> - A visible volume is grouped: `strings.figure("%1$@ ml", amount, locale: locale)`, a `%n$@` key
>   fed a formatted figure. A spoken string keeps its `%n$d` key, so VoiceOver's values do not move

Proposed:

> - A sentence built from a key with an argument goes through one of two helpers, with the injected
>   `\.locale`: `strings.figure(_:_:locale:)` for a `%n$@` key fed volumes it formats itself, and
>   `strings.localized(_:_:locale:)` for everything else. Never `String(format:)` over a resolved
>   key: without a locale Foundation does not take a counted noun's form from the app's language,
>   and groups nothing. A figure is grouped wherever it appears — drawn or spoken

**`65-accessibility`**, *VoiceOver*, History's heading. Now:

> The strip is one heading, *When you drank*, and its bars, hours and reminder mark are hidden: the
> rows under it speak every serving

Proposed:

> The strip is one heading — label *When you drank*, value the count of servings it draws, which is
> hidden — and its bars, hours and reminder mark are hidden: the rows under it speak every serving

**`65-accessibility`**, *VoiceOver*, Home's heading. Now:

> The streak chip is one element — label *Day streak*, value the count — and is absent at zero. The
> status line speaks millilitres from a `%d` key while it draws a grouped figure

Proposed:

> The streak chip is one element — label *Day streak*, value the count with its noun, what it draws
> where the noun fits — and is absent at zero. Where the noun does not fit beside the title, the
> chip draws the count alone and still speaks the noun. The status line speaks millilitres from a
> `%d` key with plural forms while it draws them from a `%@` key

**`70-privacy`**, *Localization*. Now:

> - Use positional format specifiers (`%1$d`, `%2$@`) in every key, never bare `%d`, and never drop or
>   invent one in a translation

Proposed:

> - Use positional format specifiers (`%1$d`, `%2$@`) in every key, never bare `%d`, and never drop or
>   invent one in a translation — in each plural form and substitution as in a plain value
> - A count beside a noun takes plural variations in every catalogue that holds the key: *one* and
>   *other* in English; *one*, *few*, *many* and *other* in Russian, where *other* — reached only by
>   a fraction — takes the genitive singular. Uzbek keeps one value, because Uzbek puts a noun after
>   a number in the singular

**DocC** rewritten with the code: `Bundle.figure` (§3.1), `HomeView.streakChip` ("No noun"), the strip
card's heading, `GoalSetupUITests.total(in:)` ("why that spoken string keeps its `%d` keys"),
`WelcomeView.spokenMillilitres` ("a `%1$d` key, never the grouped figure") and
`WristVessel.readout` ("`%d` never groups" — the rest of that sentence, "which is why the phone draws
`1300 / 2000 ml`", is false already: known issue #103(f)).

## 6. Testing

Tests first, run **red** before the forms exist (rule `85-testing`).

1. **`PluralFormTests`** — new, in `LocalizationTests.swift` beside `GroupedFigureTests`, not
   `@MainActor`. For each counted key, in each bundle that holds it — the app, and the widget and the
   watch reached through the built app as the file already does — `localized(…)` formats 0, 1, 2, 5,
   11, 12, 21, 22, 25, 101, 111 and 1,001 and each is compared with §3.3's form, the figure formatted
   by the same locale — in English, Russian and Uzbek, at every count. The two new keys likewise. In
   a key with more than one counted argument, each is varied in turn, the others held at 5.
   One test pins §2's finding 2 on the iOS simulator: the Russian *Add* key formatted with
   `String(format:)` and no locale gives *5 миллилитра* — the reason the helper takes a locale. Like
   the probes, it means something only under an English process locale, so it checks that first.
   **Red first:** with §3.1's helper on disk and the catalogues untouched, a count
   fails wherever §3.3's form differs from today's single value: in Russian, every count outside
   *many*, except the *few* counts after *из*, whose genitive is already right; every English *one*
   of a noun that changes (*percent* does not); the two new keys, which no catalogue holds yet, at
   every count in Russian and Uzbek; and the test of §2's finding 2, which gets *5 миллилитров*.
2. **`LocalizationTests`' readers**, which the move into `.stringsdict` would otherwise break or
   blind. A key that gains forms leaves the `.strings` of English and Russian but not of Uzbek, which
   keeps a plain value; and its resolved value becomes a `%#@…@` format key, whose arguments the
   suite's `%\d+\$[@ds]` pattern does not see. So:
   - `table(_:_:)` also reads `Localizable.stringsdict`, so the coverage tests —
     `bothLanguagesCoverExactlyTheSameKeys`, which would otherwise fail on a key translated into
     Uzbek and missing from Russian, `everyDrawnStringIsTranslatedUnlessDeliberatelyNot`, the
     widget's `everyWidgetStringIsTranslatedUnlessDeliberatelyNot` and the watch's twin — still see
     every key;
   - the format-argument checks — `everyTranslationKeepsTheFormatArgumentsOfItsKey`,
     `noTranslationAnywhereLosesAFormatArgument`, `noWatchTranslationLosesAFormatArgument` and the
     Home, History and welcome suites' `…KeepsItsArguments`, which would otherwise fail — read each
     form and each substitution of a plural key, not its `%#@…@` format key;
   - the agreement tests — app and widget, phone and watch — compare the **formatted sentences** for
     §6.1's counts. Comparing raw values would compare one bundle's `%#@value@` with another's and
     pass for nothing;
   - `onlyTheSpokenHomeStringTakesARawNumber` and `theOnlyRawVolumesLeftToDrawAreOtherScreens` are
     re-read against the new keys and kept, or changed with a stated reason.
3. **Spoken figures** (§3.6), as product speech changing on purpose — no assertion is narrowed:
   - `WelcomeUITests`: 18 lines name a four-digit figure — *1000*, *2000*, *2500*, *2800*, *2100*,
     *2400*, *4000* — and read *1,000* and so on; *(2026-10-17, as built: they read each figure
     grouped by the device's own region, through a private `spoken(_:)` that formats with
     `.formatted(.number)` — the welcome runs on *Follow device*, and every simulator here is `en_UZ`,
     which groups with a space, *1 000*. The screenshot harness does the same through `grouped(_:)`.)*
   - `GoalSetupUITests`: `millilitres(on:)` and `total(in:)` read a grouped figure, and
     `waitForTotal` waits for one. Its `ENDSWITH " millilitres"` predicates hold for every amount the
     suite pours (none is 1);
   - `AppStoreScreenshotUITests`, outside the gate, gets the same edits so the next capture runs;
   - no unit test outside `LocalizationTests` asserts a counted sentence (measured: a grep of both
     unit targets on 2026-10-16). `WristViewLogicTests`' calls to `syncedCaption` and `attribution`
     pass the new `locale:` (§3.2), and keep their expected strings: a count of minutes under 1,000
     formats the same.
4. **The nouns:** a UI test reaches the goal and reads the chip's value — a count with its noun's
   form for that count, *1 day* or *N days*, since a gate device keeps the servings earlier runs
   poured and its streak can be longer than a day — and the strip heading's — *N servings* — each as
   exactly one element (rule `65-accessibility`).
5. **`LocalizationTests`' lists:** the two new keys join `homeKeys` and `historyKeys`.

## 7. Verification

### 7.1 The gate

Rule `85-testing`'s, with the devices and the chunking `docs/AI_CONTEXT.md` records for this machine,
and the UI suite again on iOS 26.5.

### 7.2 Warnings

No new warning against a clean build of HEAD, compared per file and message (`CLAUDE.md`). A variadic
`any CVarArg` crossing into a `nonisolated` function from a main-actor view is the likeliest new one
(inferred; `CLAUDE.md`'s baseline of 29 warning lines names `DataManager.swift`,
`NotificationManager.swift` and `WristView.swift` only, none of them at a `figure` call site).

### 7.3 On the simulator

Rendered and looked at, in English, Russian and Uzbek:
- Home's chip with a streak of 1, 2, 5 and 21 days, at the default size and at
  `UICTContentSizeCategoryAccessibilityXXXL`, on *WaterBuddy Small 26.5* and the iPhone 17;
- History's strip with 1, 2 and 5 servings, at the same sizes, and the count's contrast measured off
  the render and recorded in `docs/DESIGN.md`;
- the Home Screen widget, small and medium, light, dark and tinted, with a total over 1,000; the Lock
  Screen widget in its three shapes; the watch app's serving rows with a vessel over 1,000.

### 7.4 What only a real device shows

For the 1.2.7 sweep: VoiceOver reading a grouped figure — *2 000* in Russian, *2 000* in Uzbek — as
one number and not two, and the chip and the strip in Russian on the owner's iPhone.

## 8. Known limitations, and what is not in scope

- **The probes ran on macOS.** That the iOS simulator's Foundation chooses the form by the format's
  locale, as macOS's does, is inferred until §6.1's tests pass once the forms exist. The red run
  cannot show it: with the catalogues untouched, no key has forms to choose between. *(2026-10-17:
  shown — with the forms in, `PluralFormTests` passed on the iOS 27.0 simulator, the no-locale test
  included.)*
- **A phone set to a language the app does not ship.** Under *Follow device*, the strings fall back to
  English and the locale is the phone's, so a language with no singular form — Japanese, say — gives
  *1 millilitres*, as every count gives today. Choosing *English* in the app gives *1 millilitre*.
  *(2026-10-17, corrected by the build's final review — measured, and this bullet's middle was wrong:
  `AppLanguage.system`'s `.autoupdatingCurrent` takes its language from the bundle's resolved
  localization, so the locale is English with the phone's region — `en_JP`, `en_DE`, `en_FR`, `en_UA`
  on the iOS 27.0 simulator under `-testLanguage`/`-testRegion`. A Japanese phone gives *1 millilitre*,
  with the region's grouping; there is no such limitation. `theFollowDeviceLocaleSpeaksTheBundlesLanguage`
  pins the rule.)*
- **VoiceOver and grouped figures** are unproven until §7.4.
- Not in scope: turning `figure`'s keys into `%d` keys; the *Undo* line's verb, which would need the
  vessel's gender in Russian (`docs/AI_CONTEXT.md`, the redesign's stage 2); new languages (roadmap
  1.5.3); the widget's and the watch's redesigns (1.3.1, 1.3.2).

## 9. Decisions

| | Decision | Taken |
|---|---|---|
| D1 | Bring back the streak's noun and the strip's count with the fix | The owner, 2026-10-16 |
| D2 | Apple's plural variations, formatted with the app's locale; figures group | The owner, 2026-10-16 |
| D3 | Every sentence built from a key goes through one of two helpers — the new `localized`, or `figure` — not only the counted ones | The owner, 2026-10-16 (section 1) |
| D4 | The chip draws the count alone where its noun does not fit, and always speaks it | The owner, 2026-10-16 (section 2) |
| D5 | The strip's count trails its heading, and moves under it where it does not fit | The owner, 2026-10-16 (section 2) |
| D6 | The widgets' and the watch's figures are included; #39 closes | The owner, 2026-10-16 |
| D7 | Known issue #50: Xcode's reformat of three catalogues is committed, or discarded, as its own change **before** this change edits the watch's | **Open** — recommended: the owner's `/commit` of the three as one `chore` change first |
| D8 | `Last %1$d days` gets its forms although it is always 7 | This document; inside the table the owner approved |
| — | The Russian words in §3.3 | **For the owner to read** |

## 10. Sequence

The owner reviews this document and the §3.3 words, and answers D7; the rule wording in §5 is typed
into the rule files unstaged for their approval; then the plan, under `docs/superpowers/plans/`,
dated the day it is written; then the work in the main loop, tests first, the
gate, `/doc_sync`, staged for the owner's `/commit`.
