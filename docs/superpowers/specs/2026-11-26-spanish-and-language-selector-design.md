# Spanish in the app, and a new look for the language selector — design

Taken on the owner's message of 2026-11-26, about 11:00: *"Need to add the spanish to the app itself language and the Language
selector should be different look."* Written whole for one approval, as the owner prefers: six rulings asked (§2), the rest
recommended (§9).

R2, the selector's look, was ruled over two more messages, after the pictures of three looks:
- *"it should be C version with drop-down menu, because when we add more languages to the app, it will be difficult to manage
  all languages in other variants"*;
- then, shown a drop-down: *"no not dropdown select, it should open bottom menu the language selector"*.

The pictures are in `build/spanish/` (ignored by git, drawn from `build/spanish/mock.html` in Aurora's colours):
- `1-today.png`: today's card with Spanish added;
- `2-` to `4-option-…png`: the three looks first offered;
- `5-option-c-drop-down.png`: the drop-down, set aside;
- `6-option-c-bottom-sheet.png`: the ruled look, a row that opens a sheet from the bottom.

## 1. What was asked, and what done looks like

**Said:**
- Spanish as a language of the app;
- a language selector that looks different: one row in Settings that opens the languages in a sheet from the bottom, because a
  list in its own sheet still works when more languages are added.

**Taken to mean** (correct anything here):
- Spanish is chosen in Settings like English, Russian and Uzbek. It switches straight away, and it reaches everything that draws
  words: the app, the three widgets, the Control Center control, reminders and their button, Siri, Apple Health's permission
  sheet and the watch.
- This is roadmap 1.5.3, *New languages*, brought forward for one language. It does not change 1.4.2, which is in review.

**Read on 2026-11-26:**
- **`AppLanguage`** (`DataManager.swift`) has `system`, `en`, `ru` and `uz`. `selectable` lists the three in the picker's
  order. Each language names itself in its own script. `bundle` is the `.lproj` of the code, and `locale` is
  `Locale(identifier: code)`.
- **`LanguageCard`** (`SettingsView.swift`) draws four 50-pt rows with hairlines between them, a check on the chosen one, and
  the note *The app switches straight away. The widget follows on its next refresh.* It is the tallest card on Settings.
- **The catalogues** hold about 370 strings to write:

  | Catalogue | Keys |
  |---|---|
  | the app's | 309 (29 with plural forms, about 8,900 English characters) |
  | the widget's | 26 |
  | the watch's | 17 |
  | the watch widget's | 8 |
  | Siri's phrases | 6, English and Russian only |
  | the Info.plist's | 3 |

- **The tests:** `LocalizationTests`' `translated = ["ru", "uz"]` drives every bundle check, `PluralFormTests` runs `en`, `ru`
  and `uz`, and `AppLanguageTests` pins `selectable` to the `.lproj` folders that ship.
- **The policy:** it names the languages: *English, Russian or Uzbek* (`PRIVACY.md`, *Your chosen language*).
- **Measured on this Mac,** with Foundation's own language matching and formatting:
  - an app that ships `es-419` gives that table to a phone in `es-MX`, `es-ES`, `es-US`, `es-AR` and plain `es`;
  - `es-419` writes *2,000*, *65%* and *10:13 a.m.*, as the Spanish (Mexico) store page does;
  - plain `es` writes Spain's *2000*, *65 %* and *10:13*.

**Done** is:
- *Español* in the new sheet.
- Every string of every bundle in Spanish.
- The tests extended and green, the gate passed, and the Spanish screens walked on the simulator.
- The policy and the four store listings saying so.
- 1.4.3 (9) uploaded on your word, once 1.4.2 is released.

## 2. Rulings

- **R1 — which Spanish.** Recommended: **Latin American Spanish, `es-419`.** It is the store page's Spanish (Mexico and 15
  Latin American stores, and the US store's second language). Every Spanish phone gets it, and an explicit *Español* writes
  figures as Mexico does (*2,000 ml*, *10:13 a.m.*). The alternative is plain `es`, which writes figures as Spain does
  (*2000 ml*, 24-hour time) for everyone who chooses *Español*.
- **R2 — the selector's look. Ruled: one row that opens a sheet from the bottom** (§4), look C as first drawn, on the owner's
  word and for their reason: a list in its own sheet holds any number of languages, where tiles or capsules grow with each one.
  Set aside:
  - A, tiles that say hello;
  - B, capsules;
  - a drop-down menu in place of the sheet.
- **R3 — Siri in Spanish.** Recommended: **yes**, six phrases in Spanish beside the English and Russian ones (§3.3). They
  are proved by hand, with Siri set to Spanish: no automated test can speak to Siri.
- **R4 — the version.** Recommended: **1.4.3 (9)**, after 1.4.2 is released. Connect starts a new version only once the
  current one is *Ready for Distribution*, so 1.4.2's TestFlight check and its release come first. The alternative is to wait
  and ship Spanish with release 1.5.
- **R5 — who reads the Spanish.** Recommended: **I write it, a second agent reviews it, and you get a table.** The second
  agent starts fresh, without my reasoning, and checks the Spanish against the English and the glossary (§3.2). You get a
  table of every key, in English, Russian and Spanish side by side, as for set C's strings. Anything nobody changes ships as
  written. The alternative is that a Spanish speaker you know reads the table before the archive.
- **R6 — the theme names.** Recommended: **translated, as Russian and Uzbek translate them**: Aurora, Laguna, Crepúsculo,
  Medianoche, Floración. The alternative is to keep the English names in Spanish, as the store page does today.

## 3. Spanish

### 3.1 The language

- `AppLanguage` gains `case spanish = "es-419"`, named *Español*. `selectable` becomes English, Русский, O‘zbekcha, Español:
  Spanish goes last, so nobody's list moves.
- `knownRegions` gains `es-419`. All six catalogues gain `es-419`: the app's, the widget's, the watch's, the watch widget's,
  Siri's phrases (R3) and the Info.plist's.
- `locale` stays `Locale(identifier: code)`. For `es-419` that writes figures and times as Latin America does (R1).
- **Follow device:** a Spanish phone gets `es-419` by iOS's own matching. A test pins it on the simulator, where it is measured
  again (§7).
- **The watch** takes the phone's language through the mirror, which now carries `"es-419"`. A watch app from before this
  version reads an unknown code as *Follow device* (`AppLanguage(code:)` falls back), so it draws its own device language until
  it updates. Nothing breaks.
- **Stored state:** none new. `Key.language` holds `"es-419"` the way it holds `"ru"` (rule `25-shared-storage`).

### 3.2 The words

- **Register:** Latin American Spanish, *tú*, as the store page writes it. Apple's own Latin American terms:

  | English | Spanish |
  |---|---|
  | Home Screen | pantalla de inicio |
  | Lock Screen | pantalla bloqueada |
  | Control Center | Centro de control |
  | StandBy | En espera |
  | Action Button | botón de acción |
  | Settings (iOS) | Configuración |
  | Health | Salud |
  | Shortcuts | Atajos |
  | Privacy & Security | Privacidad y seguridad |
  | Apple Account | cuenta de Apple |
  | complication | complicación |
  | Reduce Motion | Reducir movimiento |
  | Reduce Transparency | Reducir transparencia |
  | Larger Text | Texto más grande |

- **Names:**
  - the vessels are *Taza*, *Vaso* and *Botella*, as on the store page;
  - the themes follow R6;
  - *Premium*, *WaterBuddy*, *Siri* and *Apple Watch* stay as they are;
  - the language names stay in their own script, untranslated.
- **Counted nouns** take *one* and *other* in every catalogue that holds the key. Spanish's third form, *many*, applies only to
  whole millions, and no figure the app draws reaches a million.
- **Format specifiers** stay positional (`%1$d`, `%2$@`), never dropped or invented (rule `70-privacy`).
- **Reminder copy** carries no digit. The test that reads every translated language reads Spanish once it joins `translated`.
- **One risk to check by eye:** the Settings tab's title is *Configuración*, 13 letters in a three-slot bar. If it does not
  fit at the default text size, it takes the bar's existing scale-down, never a cut. The walk checks it (§6).

### 3.3 Siri (R3)

- Six phrases in `AppShortcuts.xcstrings`'s `es-419`, one for each English phrase, each with `${applicationName}`:
  - *Registra agua en WaterBuddy*
  - *Registra un vaso en WaterBuddy*
  - *Agrega agua en WaterBuddy*
  - *Cuánta agua llevo hoy en WaterBuddy*
  - *Cuánta agua he tomado en WaterBuddy*
  - *Revisa mi agua en WaterBuddy*

  Without *¿?*, as the English and Russian phrases carry no punctuation: a phrase is what is spoken.
- Siri's replies live in the app's catalogue and are translated with it. *Log a Glass*'s reply stays fixed and digit-free in
  Spanish too (`theSiriReplyCarriesNoUserValues`).

### 3.4 Where Spanish shows outside the app

- **The widgets' gallery** (name and description) is in the phone's language: iOS reads it from the widget's catalogue.
  Their faces follow the app's choice from the next refresh, as now.
- **Apple Health's sheet** reads the Info.plist's two purpose strings in Spanish.
- **The Control Center control's title** and **the reminder's button** follow the app's choice, as now.

## 4. The selector: one row and a sheet from the bottom (R2)

### 4.1 The row

- The Language card keeps its place on Settings and becomes one row, drawn like Export's:
  - the `globe` symbol;
  - *Language*, with the chosen language's name under it, in that language's own script, or *Follow device*;
  - a chevron at the trailing edge.
- The note stays under the row: *The app switches straight away. The widget follows on its next refresh.*
- **The whole row is one button,** at least 44 pt, and it grows with the text (rule `65-accessibility`). It carries
  `PressStyle` and `Haptics.select`, as Export's does.
- **VoiceOver:** the row's label is *Language*, and its value is the chosen language's name.

### 4.2 The sheet

- **`LanguageSheet`,** new and app-only, in its own file. It is presented with `.sheet(item:)` from the row (rule `50-views`)
  and handed the language chosen when it opened. It reads the live choice from `manager`.
- **It rises from the bottom to half the screen,** `.presentationDetents([.medium, .large])`, with the drag indicator shown. It
  is the app's first sheet that opens at half height: a swipe up shows the whole list when more languages come, and the list
  scrolls past that.
- **Like every sheet in the app:**
  - its own aurora, and `.preferredColorScheme(.dark)`;
  - its heading, *Language*, carries the header trait;
  - the app's close button, spoken *Done*;
  - its content arrives through `Landing`.
- **The list,** on one glass card:
  - *Follow device* first, with the `iphone` symbol and a second line naming the language it means: *Your iPhone's language:
    English*. That language is the one *Follow device* draws today, read from `Bundle.main.preferredLocalizations`, so it is
    English on a phone in a language the app does not ship.
  - Then the languages, in `selectable`'s order. Each row has the language's greeting in its own words, large (*Hello*,
    *Привет*, *Salom*, *Hola*), its own name beside it, and the check on the chosen one in the theme's `accent`.
- **A tap on a language switches the app and closes the sheet:** one call, `manager.language = …`, `Haptics.select`, then
  `dismiss()`. A tap on the chosen one only closes it. Settings is already in the new language when the sheet has gone.

### 4.3 Accessibility and design

- **Each entry is one button.** Its label is the language's own name. For *Follow device* the label is its translated name and
  the second line is the value. The chosen one carries `.isSelected`. The greeting is decoration, hidden from VoiceOver.
- **Each row is at least 56 pt,** a serving row's height, and grows with the text.
- **At an accessibility text size** the greeting stands above the name, so neither is cut.
  *(Built 2026-11-26, after the walk: the tick stands on that first line too, beside the greeting or *Follow device*'s glyph,
  and the name below takes the row's whole width. With the tick beside the name, *dispositivo* broke with a hyphen at the
  largest size.)*
- **The card, the check and the press** come from the design system: `.liquidGlass`, `Hairline`, the theme's `accent` and
  `PressStyle`. No colour, radius or opacity is written as a literal in a view (rule `60-design-system`).
- **No flags,** now or later. A language is not a country: Spanish is Mexico's and Spain's, and Uzbek's flag would speak for a
  state, not a language.
- **The greetings** are a constant on `AppLanguage`, `greeting`, untranslated as the names are.

### 4.4 What goes

- The card's four 50-pt rows and their hairlines, and the 50-pt floor for a language row (rule `65-accessibility`).

### 4.5 New keys

- One, in every language: *Follow device*'s second line, `Your iPhone's language: %1$@`.
- The row's title and the sheet's heading are the existing *Language*.

## 5. What else changes

- **The privacy policy:** `PRIVACY.md` and `Tools/PrivacyPolicy.html` change together.
  - *Your chosen language* becomes *English, Russian, Uzbek or Spanish*, and the policy is dated.
  - It is published before 1.4.3 is submitted (rule `70-privacy`), on your word, as R3 of 1.4.2 was.
- **The store text, in four listings:**
  - the description's language line, and in Spanish (Mexico) both *no en español* and *Solo en inglés y ruso* (R3);
  - What's New for 1.4.3.
  - The screenshots and the header stay English, as for Russian. `VerifyListing.sh` counts every field.
- **The rules** are your files. This approval lets me change these lines:
  - `70-privacy`: *the product ships exactly `en`, `ru` and `uz`* gains `es-419`, and Siri's catalogue *in English and
    Russian only* gains it too (R3);
  - `15-project`: `knownRegions` and the catalogues' languages;
  - `65-accessibility`: *50 for a language row* becomes the Language row's 44-pt floor and the sheet's 56-pt rows, and the
    sheet's elements join the VoiceOver list;
  - `50-views`: the language sheet joins the sheets presented with `.sheet(item:)`, and it is the one that opens at half
    height;
  - `85-testing`: `LanguageUITests` joins the UI tests that launch with DEBUG's fresh start, so a language chosen in its
    test never outlives it — added in the build, since the rule names every such test.
- **The docs,** through `/doc_sync`:
  - `docs/STATE.md`: `Key.language`'s values;
  - `docs/ROADMAP.md`: 1.5.3, Spanish brought forward;
  - `docs/AI_CONTEXT.md`, `CLAUDE.md`, `HISTORY.md` and a lesson where one is learned.

## 6. The order of the work

The spec is the plan, as 1.4.2's was.

1. **The branch:** `feature/spanish` from `main` at `ab1c3b1`.
2. **The failing tests, run RED:**
   - `AppLanguageTests`: Spanish's code, name and greeting; `selectable` against the shipped `.lproj`; the locale's
     *2,000*; *Follow device*'s second line naming the bundle's language.
   - `LocalizationTests`: `translated` gains `es-419`, so every bundle and every shared key must hold Spanish.
   - `PluralFormTests`: `es-419`, with Spanish's forms written out by hand.
   - The Health purpose test and Siri's phrase test (R3).
   - A UI test:
     - the Language row is one element;
     - it opens the sheet, where each language is one button;
     - choosing *Español* closes the sheet and turns Settings' title into *Configuración*, and choosing *English* turns it
       back.
3. **The Spanish:**
   - the catalogues written;
   - the second agent's review;
   - R5's table to you.
4. **The selector,** then GREEN.
5. **The rest:** the policy, the store text, the rule lines and the docs.
6. **The gate:** the five invocations on iOS 27.0, and the UI suite on iOS 18.6. Warnings are compared by file and message
   with a clean build of `ab1c3b1`. AvtoLog's gate holds the Mac's simulators until its *done*, so test runs wait for it or
   for its word, and only WaterBuddy's own simulators are used.
7. **The walk,** in Spanish, on the simulator:
   - Home, History (week, month, insights), Settings and its language sheet at half and full height, every other sheet, the
     paywall, the welcome;
   - the widgets on the Home Screen and the Lock Screen, and the control;
   - a reminder and its button, and the watch;
   - Siri in Spanish, by hand (R3);
   - each at the default text size and the largest; the sheet on iOS 27.0 and on 18.6, where iOS draws a sheet's glass
     differently.
8. **The release:**
   - 1.4.3 (9) on all fourteen sites, then archive and gate;
   - the upload, the policy's publication and the version page, each on your word;
   - all of it after 1.4.2 is released.

## 7. How it is proved

- **The tests of §6.2,** RED first and then GREEN. One of them pins `Bundle.preferredLocalizations` on the simulator: `es-MX`,
  `es-ES` and `es-US` must each get `es-419`.
- **Every Spanish string** has a value in every bundle that holds its key. Shared keys are equal across bundles, and every
  specifier is kept. All of it comes from the existing tests once `es-419` joins `translated`.
- **The selector:** its UI test, the walk's pictures of the row and the open sheet at two text sizes and on two iOS versions,
  and VoiceOver's reading of the row and of one entry, by hand.
- **The gate** as §6.6. A green suite is not proof the product works, so the walk of §6.7 is required.

## 8. Risks

- *Configuración* in the tab bar (§3.2).
- **Siri's matching** of an `es-419` phrase table to a phone set to Spanish (Mexico): it is unproven until it is tried by
  hand (R3).
- **The half-height sheet** is new to the app: its arrival through `Landing` and the drag to full height are read on both
  runtimes in the walk.
- **The translation's quality** is the main risk, and R5 is how it is met.

## 9. Decisions

Yours: R1–R6 (§2), R2 ruled.

Mine, recommended, for you to change at review:
- **D1.** `es-419`'s code is the stored value, the bundle and the locale, one spelling for the three, as `ru` and `uz` have
  one each.
- **D2.** Spanish goes last in `selectable`.
- **D3.** A tap on a language closes the sheet, as a menu would. The sheet opens at half height and can go to full.
- **D3a.** Greetings are a constant beside the names, never in a catalogue.
- **D4.** No flags.
- **D5.** *Follow device*'s second line reads `Bundle.main.preferredLocalizations`. It reads no device setting the app does
  not already use.
- **D6.** `feature/spanish` from `ab1c3b1`. `main` moves only on your word, after the archive.
- **D7.** The spec is the plan.

## 10. Yours, or mine on your word

- Approve this design, and rule R1 and R3–R6.
- Read R5's table, or pass it to a Spanish speaker.
- **On your word, each time:** each push, the policy's publication, the 1.4.3 upload, the version page and *Submit for
  Review*.
- **Before any of 1.4.3:** 1.4.2's TestFlight check and its release.

## 11. Not in this work

- Spanish screenshots and a Spanish header, which stay English, as Russian's do.
- Any language but Spanish.
- A second Spanish (Spain's `es-ES`).
- Any change to 1.4.2, which is in review.
- 1.4.2's own open items, #236 and #237.
