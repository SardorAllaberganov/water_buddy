# Release 1.4.1 — a listing that search can find, two new shots, the comma fix and an earlier rating — design

Taken by `/start_task` with no task named. On 2026-11-20 the owner asked for WaterBuddy to be analysed by
their `aso` skill (`~/.claude/skills/aso`), its rivals listed, and what people want and pay for read. The
research report, *WaterBuddy ASO and competitor demand*, came back the same day (kept as §5.5 says). Shown
it, the owner chose **Plan 1.4.1 listing**, then answered four rulings asked up front (§12, R1–R4). Known
issue #162 is this design's code subject.

## 1. Why, and what done looks like

Apple's Lookup API, read on 2026-11-20, shows **1.4 live since 2026-11-13** — App Review approved it; the
records still say *Waiting for Review* — and **0 ratings in all eight storefronts read** (us, gb, ca, au,
de, ru, uz, kz). The playbook's own measurements, run that day:

- WaterBuddy is **outside the top 50 on all 42 English searches** in the US, UK, Canada and Australia, and
  not among the 181–193 apps Apple's Search API returns for the US head terms. It matches no Russian search.
- The name leads with a brand **six other apps share**; searching *waterbuddy* puts it 4th. Apps with 0
  ratings reach the US top 10 when their name *starts* with the phrase searched ("Hydration – Tracker" #8
  for *hydration tracker*). "Water" exists only inside the compound "WaterBuddy", and earns nothing there.
- The subtitle, *One tap. No account. No cloud.*, is a slogan, which the playbook rules out.
- The listing is en-US only. Russia would show a Russian listing; **Uzbekistan and Kazakhstan show only
  English (U.K.)**, and Apple has no Uzbek or Kazakh listing language.
- **No screenshot shows logging without opening the app**, the one thing no rival does as fully. Six of the
  ten are Premium, the third among them.
- Prices are Apple's equalised conversions of the US prices, not tiered by income, and the paywall shows the
  yearly plan saving **20% instead of 44%** wherever numbers use a decimal comma (#162).
- The rating request waits for the third goal day in a row, reached by a pour on Home. With a small install
  base and most logging done from widgets and the Watch, that moment almost never comes.

**Done** is:
- #162 fixed, tests first, and seen fixed on this Mac's own decimal-comma simulators;
- the rating asked on the first goal day, the rule and the privacy policy saying so first;
- three listings — en-US rewritten, en-GB and Russian new — in files, every field counted by script;
- the research written down beside the words;
- ten framed iPhone shots, two of them new: the Home Screen's widgets and the Lock Screen;
- the build numbered 1.4.1 (7), gated, and archived in Release from a clean export;
- what only the owner can do, or what I may do in their Chrome only on their word, listed in §11.

## 2. The order of the work

1. **The code** — #162 (§3), the rating moment and its rule (§4), the version (§8). The gate (§13).
2. **The words** — the three listings (§5), the privacy policy (§4.3), the research (§5.5).
3. **The shots** — the pair, the two new captures, the ten framed, the 6.3″ set (§6).
4. **The release** — the owner's `/commit`, the archive, the policy published, the upload and App Store
   Connect, the prices (§7, §11), each on the owner's word.

No step waits on the calendar: the store capture's window (1:45–11:45 PM) is not needed, since none of the
eight kept captures is retaken.

## 3. The comma fix (#162)

**What is wrong.** `PremiumAccess.Plan.amount`, used for the yearly plan's saving alone and never drawn, is
StoreKit's `Product.price`. On a device whose region writes a decimal comma, StoreKit hands back the
price's whole number: `price` 2, 19 and 39 beside `displayPrice` $2.99, $19.99 and $39.99. Measured in the
local StoreKit configuration on 2026-10-21 and against the App Store sandbox on 2026-11-13; the device's
region is the cause (`-AppleLocale` on the app changes nothing). The saving then reads 1 − 19 ÷ 24, 20 %.
Russian, Uzbek, Kazakh, German, Brazilian, Turkish and Indonesian formats are among those affected — the
markets the app's languages aim at.

**The fix** is the reserve the owner held on 2026-10-21: read the amount back from what StoreKit shows.
- `PremiumAccess` gains `nonisolated static func amount(shown: String, format: Decimal.FormatStyle.Currency,
  otherwise price: Decimal) -> Decimal`. It parses `shown` with `format` and returns the parsed value when
  it is positive; otherwise `price`. Foundation alone, so the file keeps its single import, and a suite off
  the main actor can hold it (rule `43-concurrency`).
- `PremiumAccess.Plan.init(_ product:)` in `PremiumStore.swift` passes `amount:
  PremiumAccess.amount(shown: product.displayPrice, format: product.priceFormatStyle, otherwise:
  product.price)`. `priceFormatStyle` and the parse are iOS 15; no version check (rule `15-project`).
- `Plan.amount`'s DocC says where the figure now comes from, and why `price` is only the fallback.
- No other figure reads `amount`, and `price`, the drawn string, does not change.

**Tests, first** (rule `85-testing`):
- In `PremiumAccessTests` (not `@MainActor`, a canary): an amount formatted with a currency style and read
  back with the same style is itself, for USD in en_US and en_UZ, EUR in de_DE, RUB in ru_RU, TRY in
  tr_TR, BRL in pt_BR, IDR in id_ID, KZT in kk_KZ, MXN in es_MX, GBP in en_GB and JPY in ja_JP; a wrong
  `otherwise` (19 for 19.99) is ignored when the shown price reads; an unreadable or non-positive shown
  price falls back to `otherwise`; and the saving from amounts read back is 0.44 in every pair.
- **RED** by a stub that returns `otherwise` — today's behaviour — so the failures name the bug, not a
  missing symbol. Then the parse, **GREEN**.
- **The probe the lessons ask for** (2026-10-22): in `StoreKitSessionTests`, the three local products'
  amounts are 2.99, 19.99 and 39.99 and the saving among them is 0.44. On this Mac every simulator is
  `en_UZ`, so it fails before the fix and passes after; on a decimal-point region it passes either way, and
  the pure tests above carry the proof there.
- By hand: the paywall on *iPhone 17* (27.0, `en_UZ`) reads **save 44%**.

## 4. The rating moment (R1)

### 4.1 The code

`DataManager.reviewStreak` goes from **3 to 1**: the first day the user's own pour on Home reaches the goal.
`mayRequestReview(reachedToday:streak:askedVersion:version:)` keeps its shape and every other condition —
today reached, a known version, once per version — and `HomeView` keeps its wait for the confetti, its
re-checks after the pause and `ReviewPrompt`'s DEBUG opt-in (`-WaterBuddyReviewPrompt`). The DocC on
`reviewStreak` and `mayRequestReview` is rewritten to the new moment and cites this spec; the 2026-10-15
spec's D1 gains a dated note.

`ReviewRequestTests` change first: `reviewStreak` is 1; a streak of 1 with today reached asks; today short
does not; a claim on the first goal day records the version before it answers; a claim on a second goal day
in the same version writes nothing. **RED** against 3, then **GREEN**. Tests that pinned the third day are
rewritten to the ruling, not narrowed: the old answer is no longer the product's.

### 4.2 The rule, worded for the owner

Rule `70-privacy`, *StoreKit, for the review request and for Premium*, *The review request's moment* — the
one sentence that changes:

> Asked only after the user's own pour on Home reaches the ~~goal on the third day in a row~~ **day's goal**,
> at most once per app version, after the confetti lands — never at launch, never from a button whose answer
> is the request, never from the widget, Siri, the control, a reminder's button, the watch or History

Typed into the rule file unstaged, for the owner's `/commit` (rule `99-docs-cascade`: `.claude/` is not
derived). R1 is the owner's approval of the change; this is its exact text.

### 4.3 The privacy policy, first

`PRIVACY.md` §3 and `Tools/PrivacyPolicy.html` say *after you reach your goal on the Home screen three days
in a row*. The policy promises it is updated *before or with* any change that affects it (its last
paragraph), and rule `70-privacy` asks the same. Both become:

> At most once per app version, after a pour on the Home screen reaches your daily goal, WaterBuddy asks
> iOS to show Apple's standard rating request.

The rest of §3 stands. *Last updated* becomes the day it is written, in both. The page is published to the
owner's user site, `waterbuddy/privacy/index.html`, **before 1.4.1 is submitted** (§11).

## 5. The listing

`README.md`'s *App Store Connect* stays the master copy of the en-US text. Every field is written to its
own file with no trailing newline. Every count below is Python's `len` (characters) or, for keywords, the
UTF-8 byte count, and `Tools/VerifyListing.sh` (D7) prints them again from the files. Every new text here,
English and Russian, and §6.2's two headlines go through the owner's `humanize` skill before they are final,
and are counted again after it.

### 5.1 en-US

| Field | Text | Count |
|---|---|---|
| Name | `Water Tracker - WaterBuddy` | 26/30 |
| Subtitle | `Stay Hydrated: Reminder Widget` | 30/30 |
| Keywords | `drink,hydration,intake,watch,daily,diary,log,fluid,habit,h2o,goal,streak,bottle,counter,balance,cup` | 99/100 bytes |
| Promotional text | `One tap logs a glass from your widget, Lock Screen, Control Center or Apple Watch. Logging is always free: no ads, no account, no cloud.` | 136/170 |
| What's New | `The yearly plan now shows its real saving in every region. It read too low wherever prices are written with a decimal comma.` | 124/4000 |

The research's set 1. "Water Tracker" opens the name, where 0-rating apps are seen to rank, and "Water"
stands as a word of its own. The subtitle holds *stay hydrated* (top-10 median 0–20 ratings in all four
English stores) and, with the name, *water reminder widget*, *water reminder* and *water widget* — all real
features. The keyword field keeps *drink* and *hydration*, so *drink water*, *drink reminder* and *hydration
tracker* still form across fields, and adds the lightly held long tail. *health*, *private*, *glass*,
*reminder* and *widget* leave: the first three are broad or unsearched, the last two are in the subtitle.
No word repeats the name or subtitle; no *apple*, no rival's name (checked by script).

*No account. No cloud.* moves out of the subtitle into the promotional text, which people read, and stays
on shot 1's pill. The **description** (3987/4000) and the **review notes** (2446/4000) do not change: both
are true of 1.4.1, and the description already says what the app does on the Watch.

### 5.2 en-GB

The en-US text, field for field, but for the keywords — `hydro` and `drinking` in, `h2o`, `counter` and
`cup` out:

| Field | Text | Count |
|---|---|---|
| Keywords | `drink,hydration,intake,watch,daily,diary,log,fluid,habit,hydro,goal,streak,bottle,drinking,balance` | 98/100 bytes |

In the UK and Australia *hydro* brings up water apps; in the US a rowing machine. *drinking water reminder*
is lightly held in the UK (548) and Australia (328). This listing is also what Uzbekistan, Kazakhstan and
Türkiye show, and Australia while there is no en-AU listing; Canada reads en-US and needs no en-CA (R2).

### 5.3 Russian (ru)

| Field | Text | Count |
|---|---|---|
| Name | `Трекер воды: WaterBuddy` | 23/30 |
| Subtitle | `Напоминание пить воду, баланс` | 29/30 |
| Keywords | `водный,норма,питья,дневник,виджет,часы,учет,пей,h2o,вода` | 100/100 bytes |
| Promotional text | `Один тап записывает стакан — с виджета, экрана блокировки, Пункта управления или Apple Watch. Записывать воду всегда бесплатно: без рекламы, аккаунта и облака.` | 159/170 |
| What's New | `Годовой план теперь показывает настоящую экономию в любом регионе. Раньше там, где цены пишут с запятой, она выглядела меньше.` | 126/4000 |
| Description | below | 3971/4000 |

The research's R1. *Трекер воды* opens the name; the subtitle holds *напоминание пить воду*, the phrase
Russia's leaders use, and *баланс* (→ *баланс воды*, *водный баланс* with the keyword *водный*). Russian
search matches word forms separately, so *воды*, *воду* and *вода* each appear once. *учет* also means
utility metering; it stays, as the cheapest of the fillers.

The description is the English one in Russian, in the app's own words (`Localizable.xcstrings`): *Стакан*,
*Чашка*, *Бутылка*, *Записать стакан*, *Записать воду*, *Apple Здоровье*, *Итоги месяца*, *Расписание*,
*Только при отставании*, *Экспорт порций*, *Советы*, *Привычки*, *Серия дней*, *Темп*, and Siri's own
Russian phrases (`AppShortcuts.xcstrings`): *Запиши воду в WaterBuddy*, *Сколько воды сегодня в WaterBuddy*.
One sentence differs on purpose: Apple's model words the insights in English only, so the Russian text says
that in Russian the app writes them itself. The draft:

```
Один тап записывает стакан — с экрана «Домой», экрана блокировки, из Пункта управления или с Apple Watch, — и вы видите, как наполняется сосуд. Без аккаунта, без сервера, без регистрации.

Трекер воды полезен, только если вы пользуетесь им и на третьей неделе. Проще всего, когда для записи не нужно отрываться от дел.

ЗАПИСЬ
- Три быстрые порции: Чашка 150 мл, Стакан 250 мл, Бутылка 500 мл. Каждую можно изменить — от 50 до 1000 мл.
- Дневная цель от 1000 до 4000 мл. Или WaterBuddy предложит её по вашему весу и активности — и не сохранит ни то, ни другое.
- Сосуд с живой водой показывает процент за сегодня и точные миллилитры.
- Порцию можно отменить одним тапом. Цель достигнута — экран празднует, а серия дней растёт.

НЕ ОТКРЫВАЯ ПРИЛОЖЕНИЕ
- Виджеты для экрана «Домой»: малый и средний — с кнопкой, которая записывает ваш Стакан, — и виджет недели за последние семь дней. Малый работает и в режиме ожидания (StandBy).
- Виджеты экрана блокировки: кольцо, строка и прямоугольник со своей кнопкой.
- Кнопка «Записать воду» для Пункта управления, экрана блокировки и кнопки действия (iOS 18 и новее).
- Siri: скажите «Запиши воду в WaterBuddy» или спросите «Сколько воды сегодня в WaterBuddy». На русском и английском.
- «Записать стакан» прямо из напоминания, не открывая приложение.

APPLE WATCH
- Чашка, Стакан и Бутылка на запястье. Работает без iPhone рядом и синхронизируется, когда он вернётся.
- Три расширения — круглое, прямоугольное и угловое — показывают прогресс на циферблате.

ИСТОРИЯ
- Последние семь дней — столбики на фоне цели, среднее и лучший день.
- Каждая порция со временем. Измените объём или время, удалите случайную или добавьте забытую.

НАПОМИНАНИЯ, КОТОРЫЕ ЗНАЮТ, КОГДА ЗАМОЛЧАТЬ
Включаются по желанию: каждые два часа с 9:00 до 21:00, пропускаются, если вы пили в предыдущий час, и затихают, когда цель достигнута. В тексте напоминаний нет цифр: экран блокировки видят и другие.

APPLE ЗДОРОВЬЕ
Включается по желанию в Настройках: каждая порция записывается в «Здоровье» как вода и исправляется или удаляется там, когда вы меняете её здесь. WaterBuddy ничего не читает из «Здоровья».

WATERBUDDY PREMIUM
Дополнительные возможности:
- Месяц: все дни с записями, целый месяц на одном экране.
- Привычки: когда вы пьёте в течение дня, будни и выходные, ваша обычная первая и последняя порция.
- Советы каждую неделю — из ваших собственных данных, прямо на iPhone. Модель Apple на устройстве может их сформулировать, но только на английском; по-русски их пишет само приложение. Не медицинская рекомендация.
- Итоги месяца: ваш месяц на одной карточке, которой можно поделиться картинкой.
- Своё расписание напоминаний: часы, интервал и тихие дни.
- Темп на главном экране и напоминания только при отставании.
- Экспорт всех порций в файл CSV.
Premium — подписка на месяц или на год (годовая начинается с бесплатной недели) или разовая покупка навсегда. Записывать воду всегда бесплатно.

ПРИВАТНО ПО УСТРОЙСТВУ
Без аккаунта, регистрации, сервера и облака. Без аналитики, слежки, рекламы и чужого кода: все фреймворки в WaterBuddy — от Apple, а сетевого кода в нём нет. Записи идут только между вашими iPhone и Apple Watch, в «Здоровье», если вы его включите, и наружу — картинкой итогов или файлом экспорта, когда вы сами ими делитесь.

ДЛЯ КАЖДОГО ДНЯ
- Тёмный дизайн из жидкого стекла над медленно плывущим сиянием.
- Английский, русский и узбекский — переключаются прямо в приложении.
- VoiceOver, крупный текст, «Уменьшение движения» и «Понижение прозрачности».

ЧЕГО ЗДЕСЬ НЕТ
Это не медицинское приложение, и оно ничего не обещает вашему здоровью. Ни друзей, ни лент, ни рейтингов. Только вода.

Подписка продлевается автоматически, если не отменить её минимум за 24 часа до конца текущего периода в настройках Аккаунта Apple. Условия использования: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/

Нужна iOS 17 или новее на iPhone; кнопке «Записать воду» нужна iOS 18, а приложению для Apple Watch — watchOS 26.
```

Every Russian text here is a draft. Before it is final it goes through the owner's `humanize` skill, as
the store page and the support page did, and is counted again. The Russian listing shows the English
screenshots until a Russian set exists (R3).

### 5.4 Where the words live

- **en-US:** `README.md`'s *App Store Connect* (master) and `AppStore/`'s root files, as today, plus two new
  files there, `name.txt` and `subtitle.txt`, so every field has its file.
- **en-GB and ru:** `AppStore/en-GB/` and `AppStore/ru/`, each with the full set — `name.txt`,
  `subtitle.txt`, `keywords.txt`, `promotional-text.txt`, `whats-new.txt`, `description.txt` — so a paste
  never needs a second file. `README.md` links both folders and gains no Russian text of its own.
- `AppStore/README.md` becomes 1.4.1's: its title and *Build* row (which still say build 5, as the
  2026-11-13 records noted), the stray fragment `01cbe67` left, the two localizations' steps, and §3's
  table for the new ten.

### 5.5 The research, beside the words

The playbook's step 5. `AppStore/research/2026-11-20/` holds:
- `report.md` — the research report, its links to local files made relative to the repository or removed;
- `ranks/` — the `rank.py` outputs (us, gb, ca, au, and the Russian terms in ru and kz, the Uzbek terms in
  uz) and the term lists they were run from.

**No review text and no reviewer's name**: Apple's review feeds carry both, and only the counts reach the
report. The scratch notes and the raw feeds stay in the session's scratchpad.

## 6. The screenshots (R4)

### 6.1 The two new captures

`Tools/CapturePairScreenshots.sh` already names both slots; on 2026-10-26 they were cut only because no
session could touch a simulator. This one has a tool that taps, long-presses and drags.
- `bash Tools/CapturePairScreenshots.sh setup` makes the new pair, *WaterBuddy Store iPhone* and *WaterBuddy
  Store Watch*, and writes the lived-in week into the phone's own stores: Home at 65 %, *1,300 of 2,000 ml*,
  the week behind it, the clock frozen.
- **`02-widgets`** — a Home Screen page holding WaterBuddy's small widget (the vessel and its pour button)
  and the week widget, the dock as iOS draws it.
- **`04-lock-screen`** — the Lock Screen: WaterBuddy's line above the clock, its ring and its rectangle
  below, and *Log Water* in a bottom control slot (the script's own instructions).
- Arranged with the simulator tool. **No pour button is ever tapped**: placing widgets by hand logged five
  pours on 2026-10-26. Before each `shoot`, a scratch picture of that device is read (lesson 2026-10-25): the
  surface the slot names, and 65 % and 1,300 ml on every figure. If any figure moved, `setup` runs again —
  a new pair — rather than a pour being deleted by hand.
- If the tool cannot place a widget or a Lock Screen widget, the owner arranges that surface in
  DeviceHub, as the script expects, and the scratch picture decides.

### 6.2 The ten, in upload order

| # | Upload name | Capture | Headline (accent in bold) | Premium | Lifted out |
|---|---|---|---|---|---|
| 1 | `1-home` | `01-home` | One tap. / Watch it **fill.** — *No account · No cloud* | | the vessel |
| 2 | `2-widgets` | `02-widgets` | Log without / **opening the app** | | the small widget, the week widget |
| 3 | `3-lock-screen` | `04-lock-screen` | Right on your / **Lock Screen** | | the rectangle with its button, the ring |
| 4 | `4-history` | `03-history` | Your **week,** / day by day | | the *Last 7 days* card |
| 5 | `5-settings` | `10-settings` | Set your own / **serving sizes** | | the *Quick-add vessels* card |
| 6 | `6-schedule` | `11-schedule` | Reminders on / **your hours** | ✓ | the hours and the days |
| 7 | `7-month` | `05-month` | A whole **month** / on one page | ✓ | the calendar card |
| 8 | `8-insights` | `06-insights` | **Insights** from / your own week | ✓ | *The one thing* pane |
| 9 | `9-patterns` | `07-patterns` | Learn **when** / you drink | ✓ | the *When you drink* chart |
| 10 | `10-recap` | `08-recap` | **Share** / your month | ✓ | the recap card, turned 3° |

The free core takes 1–5, Premium 6–10. The schedule leads Premium because reminder control is the one
Premium item reviewers ask for. **`09-goal-setup` and `12-export` leave the set**; their captures stay in
`captures/`. The two new headlines are drafts, passed through `humanize` like the rest; each names only what
its screen shows — no claim about a locked phone, which only a device can prove (#72).

### 6.3 The framing

`Tools/StoreScreenshots.html` gains the two shots — their headlines, the phone, and pieces cut from the same
capture (F4 of the framing spec), measured with its `measure=` mode — and its `SHOTS` order becomes the
table's. Every scene entry's `shot` index is renumbered, so the aurora's lights still run on from panel to
panel. `Tools/FrameScreenshots.sh`'s `SHOTS` map gives the new upload names. Then `bash
Tools/FrameScreenshots.sh`; the ten are read by eye; the 6.3″ set is made from them with `sips`, as
`AppStore/README.md` §3 says; `bash Tools/VerifyScreenshots.sh` passes every file.

The Apple Watch shot (`1-wrist.png`) and the product page header do not change.

## 7. Prices by country

Set in App Store Connect, not in the build. The playbook's three tiers by the World Bank's income groups
(its `references/price-tiers.md`, the 2027 fiscal year's lists), keeping each plan's ratio so the yearly
saving stays near 44 % and lifetime twice the yearly:

| Tier | Monthly | Yearly | Lifetime | Yearly saves |
|---|---|---|---|---|
| High income — full price | $2.99 | $19.99 | $39.99 | 44.3 % |
| Upper-middle — about 40 % off | $1.79 | $11.99 | $23.99 | 44.2 % |
| Lower-middle and low — about 70 % off | $0.89 | $5.99 | $11.99 | 43.9 % |

- $0.89 breaks the playbook's .49/.59 endings under a dollar on purpose: $0.99 would make the yearly *save
  50 %*. Whether each point exists in Connect for both subscriptions and the lifetime purchase is checked
  when it is set; where it does not, the nearest point that keeps the saving within 43–45 % is taken.
- After each tier, every sample storefront's proposed price is read, and any yearly saving outside 43–45 %
  is set by hand (the euro stores today read 36 %).
- **When:** the day 1.4.1 is released, so the paywall that shows the saving is the one that reads it right.
  A price decrease cannot be taken back and existing subscribers renew at it; with almost none yet, this is
  the cheapest moment.
- Uzbekistan is billed in US dollars, at the lower tier.
- The app never mentions another country's price (the playbook; App Review).

## 8. The version

`MARKETING_VERSION` 1.4 → **1.4.1** and `CURRENT_PROJECT_VERSION` 6 → **7** on all fourteen sites, read
back from the four built products as `1.4.1 (7)` — the watch app and both extensions carry the iPhone app's
own, as the playbook's checklist asks.

## 9. Branch and `main`

The work goes on **`release/1.4.1`**, made from `main` at `752a0a3`. `main` fast-forwards to it only after
the Release archive of the final tree has passed (lesson 2026-11-07), and only on the owner's word, as
every push is.

## 10. The playbook's release checklist

1. **Versions:** §8.
2. **Can a version start?** 1.4 is live by the Lookup API (2026-11-20), so it should read *Ready for
   Distribution*; that status is read in Connect itself before *+ Version*.
3. **What's New:** §5.1, §5.3; en-GB's is en-US's.
4. **Promotional text:** §5; checked present on the new version after it is created.
5. **Name, subtitle, keywords:** §5, against §5.5's research, counted by `Tools/VerifyListing.sh`.
6. **Screenshots:** §6 — iPhone 6.3″ and 6.9″; the watch's one shot kept.
7. **Description:** en-US unchanged and already describes the Watch; the Russian one too.
8. **Rating prompt:** §4.
9. **Prices by country:** §7.
10. **Notes for App Review:** unchanged; nothing new needs reaching.
11. **After release:** reply to every review; rerun `rank.py` monthly for *water tracker*, *stay
    hydrated*, *water reminder widget*, *water diary* and *fluid intake* in us, gb, ca and au, and the
    Russian terms in ru, writing each run into `AppStore/research/`; a Product Page Optimization test of the
    new order against the old once the page has visitors.

## 11. The owner's — or mine in their Chrome, on their word

- **Publish the policy** before the submission: `Tools/PrivacyPolicy.html` as `waterbuddy/privacy/index.html`
  in the `SardorAllaberganov.github.io` repository.
- **App Store Connect:** + Version 1.4.1; *App Information* — the en-US name and subtitle, and English (U.K.)
  and Russian added with theirs; the version page — each language's fields from its files; the screenshots
  (the old ten deleted from each iPhone well first); build 7; *Submit for Review*. If Connect refuses a name
  as taken, `Water Tracker: WaterBuddy` and `Трекер воды — WaterBuddy` are the fallbacks, counted again.
- **The prices** of §7, the day 1.4.1 is released.
- Still open from 1.4, unchanged: a purchase on a real iPhone (#156).

## 12. Decisions

The owner's, 2026-11-20:
- **R1.** The rating is asked the first time a pour on Home reaches the day's goal, once per version.
- **R2.** The en-GB keyword field is English, for the UK and Australia.
- **R3.** The Russian listing shows the English screenshots for now.
- **R4.** The Home Screen's widgets and the Lock Screen join the set; the goal step and export leave it.

Mine, recommended, for the owner to change at review:
- **D1.** en-US: the research's set 1, and the promotional text and What's New of §5.1; description and
  review notes unchanged.
- **D2.** en-GB: the en-US text with the keyword swap of §5.2; no en-AU or en-CA.
- **D3.** Russian: R1's name, subtitle and keywords, and the drafts of §5.3 in the app's own words, through
  `humanize` before they are final.
- **D4.** The words live as §5.4 says: `README.md` stays en-US's master; `AppStore/en-GB/` and
  `AppStore/ru/` hold full sets.
- **D5.** The research is kept in `AppStore/research/2026-11-20/`, without any review text or name.
- **D6.** #162 is fixed by reading `displayPrice` back with `priceFormatStyle`, falling back to `price`,
  in a pure `PremiumAccess.amount(shown:format:otherwise:)`.
- **D7.** `Tools/VerifyListing.sh`, in no target, counts every field file in `AppStore/`, `AppStore/en-GB/`
  and `AppStore/ru/` against Apple's limits and runs the playbook's keyword checks; it fails on any breach.
- **D8.** The ten and their order as §6.2; the schedule leads Premium.
- **D9.** The two new shots are arranged with the simulator tool, the owner in DeviceHub as the fallback,
  and a new pair if any figure moves.
- **D10.** Prices as §7, set the day 1.4.1 is released.
- **D11.** 1.4.1 (7), on `release/1.4.1`; `main` moves after the archive, on the owner's word.

## 13. How it is proved

- **#162:** RED then GREEN (§3); the probe in `StoreKitSessionTests` on this Mac's `en_UZ` simulators; the
  paywall read by hand — *save 44%*.
- **The rating:** RED then GREEN (§4.1); by hand on a simulator launched with `-WaterBuddyReviewPrompt`, a
  first goal day's pour on Home shows iOS's request after the confetti, and a second goal day in the same
  version does not.
- **The words:** `bash Tools/VerifyListing.sh` passes every file; each file diffed against its block in
  `README.md` for en-US; every claim in the Russian description read against what the build does.
- **The policy:** `PRIVACY.md` and the page say the same sentence; the page opened in Safari, light and
  dark.
- **The shots:** each scratch picture read before its `shoot`; each framed shot read by eye; `bash
  Tools/VerifyScreenshots.sh` passes the 6.9″ and 6.3″ sets.
- **The gate:** the five invocations on 27.0 and the UI suite on 26.5 (rule `85-testing`); warnings
  compared by file and message against a clean build of a `752a0a3` export.
- **The archive:** Release, `generic/platform=iOS`, from a clean export of the final commit, before `main`
  moves and before any upload: the four bundles `1.4.1 (7)`, both Health keys, the App Group on all four
  and HealthKit on the app alone, one privacy-manifest hash, no `held` or `StoreSample` symbol.

## 14. Not in this work

- Other drinks (roadmap 1.5.1) and every other roadmap item; the research ranks them for later.
- A Russian screenshot set (R3), the watch-face shots (`02-face-modular`, `03-face-infograph`), an en-AU,
  en-CA or Uzbek listing.
- The US prices themselves, and a test of the lifetime price.
- The flaky UI tests (#209, #215 and #228, #225, #226) and a purchase on a device (#156).
- The records: `docs/AI_CONTEXT.md` (1.4 live, #162 retired once fixed), `docs/ROADMAP.md`, `CLAUDE.md`'s
  `AppStore/` row (the new `en-GB/`, `ru/` and `research/` folders), `HISTORY.md` and `tasks/lessons.md`
  follow through `/doc_sync`.
- Any upload, push, App Store Connect change or published page without the owner's word.
