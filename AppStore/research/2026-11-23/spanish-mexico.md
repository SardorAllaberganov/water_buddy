*Research for WaterBuddy's Spanish (Mexico) page, 2026-11-23. Figures are as read that day by
`python3 ~/.claude/skills/aso/scripts/rank.py 6807675132 <store> <terms file>`, the top 50 of Apple's search API for
each term, one search a line as listed below.*

# Spanish (Mexico): a second set of search words in the US store

Apple's *App Store localizations* page
(https://developer.apple.com/help/app-store-connect/reference/app-information/app-store-localizations, read
2026-11-23) lists Spanish (Mexico) among the United States storefront's languages, beside English (U.S.). It is also
the default language of Mexico and of 15 other Latin American storefronts: Argentina, Bolivia, Chile, Colombia, Costa
Rica, the Dominican Republic, Ecuador, El Salvador, Guatemala, Honduras, Nicaragua, Panama, Paraguay, Peru and
Venezuela. Apple doesn't say whether the Spanish page's words combine with the English page's in one search.

WaterBuddy was in no top 50 for any of the 21 searches below. *Median* is the top 10's median count of ratings, a
proxy for how hard a term is, not for how often it is searched (that stays unmeasured: no Astro, no Apple Search Ads).
*Titled* is how many of the top 10 carry every word of the term in their name.

## United States (`us`)

| Search | Median | Titled | Leader (ratings) |
|---|---|---|---|
| water alarm | 23,443 | 1/10 | Drink Water Reminder N Tracker (152,232) |
| water reminder alarm | 2,866 | 1/10 | My Water Reminder & Tracker (328) |
| drink water alarm | 11,546 | 0/10 | Drink Water Reminder N Tracker (152,232) |
| water alert | 17,004 | 2/10 | Rivercast: River Levels USA (11,393) |
| water glass | 64,995 | 2/10 | Happy Glass (98,657) |
| water liter | 13,306 | 0/10 | My Water: Daily Drink Tracker (24,272) |
| water health | 16,696 | 0/10 | Oasis: Personal Health (13,579) |
| water schedule | 5,077 | 2/10 | My Water: Daily Drink Tracker (24,272) |
| hydrate | 22,043 | 4/10 | HidrateSpark Water Tracker (19,814) |
| thirst | 16 | 6/10 | Thirst Drinks (12) |
| beber agua | 4,225 | 0/10 | Water Reminder - Daily Tracker (79,525) |
| tomar agua | 12,496 | 0/10 | Water Reminder - Daily Tracker (79,525) |
| recordatorio de agua | 2,171 | 0/10 | Drink water reminder (820) |

## Mexico (`mx`)

| Search | Median | Titled | Leader (ratings) |
|---|---|---|---|
| agua | 1,324 | 8/10 | Clear Wave: Water Eject (11,598) |
| beber agua | 876 | 4/10 | Water Tracker (8,285) |
| tomar agua | 880 | 3/10 | Recordatorio de Tomar Agua + (768) |
| recordatorio de agua | 520 | 4/10 | Aqua Reminder - Beber agua (3,428) |
| recordatorio beber agua | 193 | 3/10 | Beber agua - Recordatorio agua (273) |
| contador de agua | 876 | 0/10 | Water Tracker (8,285) |
| hidratacion | 27 | 0/10 | Water Time: tomar agua tracker (985) |
| recordatorio de hidratacion | 0 | 0/10 | Recordatorio De Agua Potable (19) |

## What it decided (the owner's OK, 2026-11-23)

- **Name, `Beber Agua - WaterBuddy`:** the keyword first, as the en-US name has it. "beber agua" is lighter than
  "tomar agua" in the US (4,225 against 12,496) and as light in Mexico (876 against 880), so "tomar" went into the
  keywords.
- **Subtitle, `Recordatorio y contador diario`:** no top-10 app in Mexico carries "contador de agua" in its name.
  "agua" is already in the name, and "widget" in the en-US subtitle.
- **Keywords:** no word from the en-US page or from the Spanish name and subtitle, and no accents: a search for
  "habitos" returned apps named "Hábitos" the same day, so Apple's search ignores them.
- **Left out:** `oz` (the app counts in millilitres only), `ml` (Apple ignores a keyword of two characters or fewer),
  `alert` (river-level apps lead it), `thirst` (not a feature, and drink apps lead it), `wellness` (too broad), `agua`
  and `beber` (in the name).
- **Ratings first:** with no top-50 place anywhere, keywords alone won't lift WaterBuddy (the 2026-11-20 report).