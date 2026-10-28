# WaterBuddy Premium — In-App Purchases and Subscriptions, step by step

Every value below is read from the code on 2026-10-28: the product IDs from `WaterBuddy/PremiumAccess.swift`,
everything else from `WaterBuddyTests/WaterBuddy.storekit`, the local StoreKit configuration the app was
built and tested against. Character counts were computed, not typed. The prices are a recommendation.

## What the app needs, or the paywall breaks

- **All three products, with exactly these IDs** (case matters). The app asks for the three together; if
  any one does not load, the paywall shows *"The App Store can't be reached right now."* and sells nothing
  (`PremiumStore.loadPlans`).
- **The monthly and the yearly in one subscription group**, so a subscriber can switch between them.
- **A 1.4 build shows the paywall whatever Connect holds** (#187). Submitted without the three products
  attached, App Review meets that error message.
- The paywall draws its own plan names in English, Russian and Uzbek, and takes only the **price** from
  App Store Connect. The display names and descriptions you enter below appear in Apple's purchase sheet
  and in *Settings → Apple Account → Subscriptions*.

| Product ID | Type | Price | Offer |
|---|---|---|---|
| `sardor.WaterBuddy.premium.yearly` | auto-renewable subscription, 1 year | $19.99 | free trial, 1 week |
| `sardor.WaterBuddy.premium.monthly` | auto-renewable subscription, 1 month | $2.99 | none |
| `sardor.WaterBuddy.premium.lifetime` | non-consumable | $39.99 | — |

---

## Step 0 — the agreement (once per account)

**Agreements, Tax, and Banking → Paid Apps Agreement**: accept it, add a bank account, fill in the tax
forms. Until it reads **Active**, nothing can be sold.

## Step 1 — the subscription group

Your app → **Monetization → Subscriptions → Create** (subscription group).

| Field | Enter |
|---|---|
| Reference name | `WaterBuddy Premium` |
| Localization → English (U.S.) → Subscription Group Display Name | `WaterBuddy Premium` (18) |
| App Name Display Options | **Use App Name** |

## Step 2 — the yearly subscription

In the group → **Create** (subscription).

| Field | Enter |
|---|---|
| Reference name | `Premium Yearly` |
| Product ID | `sardor.WaterBuddy.premium.yearly` |
| Subscription Duration | **1 Year** |
| Availability | the same territories as the app |
| Subscription Prices | base country **United States**, **$19.99**; let Connect fill in every other country |
| Family Sharing | **On** — once saved, it can never be turned off |
| App Store Localization → English (U.S.) → Display Name | `Premium Yearly` (14 / 30) |
| App Store Localization → English (U.S.) → Description | `Every Premium extra, renewed each year.` (39 / 45) |
| Review Information → Screenshot | the paywall — Step 6 |
| Review Information → Review Notes | the note in Step 6 |
| Image (optional) | leave empty — used only if you promote the purchase on the App Store |

**Introductory offer** — under *Subscription Prices*, set up an introductory offer:

| Field | Enter |
|---|---|
| Countries or regions | all |
| Start date | today |
| End date | **No end date** |
| Type | **Free** |
| Duration | **1 Week** |

Apple gives it only to someone who has never had an introductory offer in this group. The app asks
StoreKit (`isEligibleForIntroOffer`) and offers the free week only when StoreKit says yes.

## Step 3 — the monthly subscription

In the same group → **Create**.

| Field | Enter |
|---|---|
| Reference name | `Premium Monthly` |
| Product ID | `sardor.WaterBuddy.premium.monthly` |
| Subscription Duration | **1 Month** |
| Availability | the same territories as the app |
| Subscription Prices | base country **United States**, **$2.99** |
| Family Sharing | **On** |
| Display Name | `Premium Monthly` (15 / 30) |
| Description | `Every Premium extra, renewed each month.` (40 / 45) |
| Review Information | the same screenshot and note — Step 6 |
| Introductory offer | **none** |

## Step 4 — the levels in the group

On the group's page, order the two: **level 1 Premium Yearly, level 2 Premium Monthly**, as the local
configuration has them. Moving from monthly to yearly is then an upgrade, which Apple applies at once
with a prorated refund. Moving from yearly to monthly is a downgrade, which takes effect at the next
renewal.

## Step 5 — the lifetime purchase

Your app → **Monetization → In-App Purchases → Create**.

| Field | Enter |
|---|---|
| Type | **Non-Consumable** |
| Reference name | `Premium Lifetime` |
| Product ID | `sardor.WaterBuddy.premium.lifetime` |
| Availability | the same territories as the app |
| Price Schedule | base country **United States**, **$39.99** |
| Family Sharing | **On** — once saved, it can never be turned off |
| Display Name | `Premium Lifetime` (16 / 30) |
| Description | `Every Premium extra, paid once.` (31 / 45) |
| Review Information | the same screenshot and note — Step 6 |

## Step 6 — the review screenshot and note

**The note**, the same for all three products (103 characters):

```
Unlocks Month view, Patterns, Insights and the Monthly recap in History. Logging water is never locked.
```

**The screenshot** is seen only by App Review. One picture of the paywall, used for all three products,
at least 640 × 920 pixels — a simulator screenshot is larger than that. To take it:

1. In Xcode, **Product → Scheme → Edit Scheme → Run → Arguments**, and add `-WaterBuddyPremium` under
   *Arguments Passed On Launch*. A debug build offers the paywall only with it, and the checked-in scheme
   carries none.
2. Run the `WaterBuddy` scheme on an iPhone simulator. The run buys from the local StoreKit
   configuration, so the three prices draw.
3. Finish the welcome, then open **Settings → See Premium**, and save the screen with **⌘S**.
4. **Check the yearly plan's saving before you use the picture.** At these prices it is **44 %**. The
   simulators on this Mac are set to the Uzbekistan region (`en_UZ`), and there StoreKit testing reads
   the prices as whole numbers: the tile says **20 %** (#162). If it does, set the simulator's region to
   United States in its own *Settings → General → Language & Region*, and open the paywall again. That
   this fixes it is inferred, never tried.
5. Remove the `-WaterBuddyPremium` argument afterwards, and don't commit the scheme with it. The test
   action reuses the run arguments, and one unit test fails while the argument is there (#163).

Once a product has its localization, price and screenshot, its status reads **Ready to Submit**.

## Step 7 — buy it once yourself (#156)

Nothing but the local configuration has ever been bought from. Before you submit, on a real iPhone:

- Install the 1.4 build from **TestFlight**. TestFlight purchases use Apple's sandbox, and you are not
  charged. Alternatively, make a sandbox account (**Users and Access → Sandbox → Test Accounts**) and
  sign in with it in the iPhone's sandbox account setting. Where that setting lives (*Developer*, or
  *App Store*) depends on the iOS version.
- **Buy the yearly**: the free week shows, Month, Patterns, Insights and the recap unlock, and Settings'
  Premium card names the plan. In sandbox, periods are shortened: a week lasts minutes, a year about an
  hour.
- **Restore**: delete the app, install it again, and tap *Restore Purchases* on the paywall. Premium
  comes back.
- **Lifetime**: buy it with a second sandbox account, which has no subscription.
- **A refund**, or a lapse: the app must drop Premium when StoreKit no longer lists the purchase. How
  to refund a sandbox purchase is not written down here; this session did not check it.
- **The yearly saving reads 44 %** at the US prices (#162). In another storefront it is whatever that
  storefront's two prices give.

## Step 8 — attach them to 1.4

On the **1.4 version page**, under **In-App Purchases and Subscriptions**, select **all three**, then
submit the version. Apple reviews first-time in-app purchases only together with a new app version.

## Leave alone

The app makes only the StoreKit calls rule `70-privacy` names. None of these is used, so leave each one
off or empty:

- promotional offers, offer codes, win-back offers
- promoting the purchases on the App Store
- the App Store Server Notifications URL — there is no server

**Billing Grace Period** (under *Subscriptions*) is your choice. If it's on, the app keeps Premium
through the grace period, for as long as StoreKit lists the subscription (#161).

## Localizations — optional

English (U.S.) is enough to submit. Russian names are optional. If Connect offers Uzbek, the same goes
for it. They show only in Apple's sheets, since the paywall draws its own text.
