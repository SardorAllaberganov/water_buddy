<!--
  WaterBuddy's privacy policy — the repository's copy. Its published form is
  `Tools/PrivacyPolicy.html`, served at https://sardorallaberganov.github.io/waterbuddy/privacy/
  (`PaywallView.privacyPolicy`). The two change together: an edit to one is an edit to both.
  Written from the code (spec `docs/superpowers/specs/2026-10-24-privacy-policy-design.md`).
  The contact address is the owner's, chosen on 2026-10-29.
-->

# WaterBuddy Privacy Policy

**App:** WaterBuddy, for iPhone and Apple Watch
**Developer:** Sardor Allaberganov
**Contact:** [sardorallaberganov96@gmail.com](mailto:sardorallaberganov96@gmail.com)
**Effective date:** 24 October 2026
**Last updated:** 30 October 2026

---

## In one sentence

WaterBuddy keeps what you log on your own iPhone and Apple Watch: it has no account and no server, and it sends nothing to us — your water travels only between your own iPhone and your own Watch, and into Apple Health if you turn that on, and anything else that leaves a device does so through Apple (a purchase, a Siri request) or because you chose to share it (a monthly recap image).

---

## Why we can say "we collect nothing" and mean it

Most privacy policies ask you to trust a promise. This one describes how the app is built.

**WaterBuddy has no server, and no networking code.** There is no `URLSession`, no `Network` framework, no web view and no HTTP request of any kind in the app's source. The only web addresses in it are two links — Apple's standard Terms of Use and this page — which open in Safari when you tap them; the app never loads them itself.

The Apple frameworks the app is built from are Foundation, SwiftUI, SwiftData, Observation, WidgetKit, AppIntents, UserNotifications, WatchConnectivity, UIKit, Core Graphics, **StoreKit**, **FoundationModels** and **HealthKit**. Three of them deserve a sentence each:

- **StoreKit** is Apple's own in-app purchase system. It talks to Apple's App Store — never to us — when you look at or buy Premium, restore a purchase, or when the app asks iOS to show its rating request. See *Premium* and *The rating request* below.
- **FoundationModels** is Apple's on-device language model. It runs on your iPhone. See *Personal insights* below.
- **HealthKit** is Apple Health's own framework. WaterBuddy uses it only if you turn on *Apple Health* in Settings, to write your servings there — and it reads nothing from Health. See *Apple Health, if you turn it on* below.

There are **no third-party libraries** in the project: no Swift packages, no CocoaPods, no embedded frameworks. Nothing was added by anyone but the developer, so nothing can report back behind the developer's back.

We have no server, no database with your name in it, and no way to receive what you log. We do not have your name.

---

## What the app stores, and where

Everything below lives on your own devices, in WaterBuddy's own storage. None of it is uploaded by the app.

**On your iPhone:**

| What | Details |
|---|---|
| Your water servings | For each serving you log: the amount in millilitres, the moment you logged it, and a random identifier made for that serving. This is your history. |
| Today's total | Worked out again from your servings after every change, and kept so the widgets can show it at once. |
| The last seven days' totals | Seven daily figures, kept for the week widget, which cannot read your history directly. |
| Your daily goal | A number of millilitres. |
| The current day | A date marker, used to start a new day at midnight. |
| Your three quick-add amounts | Three amounts in millilitres — the Cup, the Glass and the Bottle. |
| Your chosen language | English, Russian or Uzbek — or nothing at all, if the app follows your device's language. |
| Your reminders setting | Whether you turned reminders on, the schedule they follow if you set your own, and whether they come only when you're behind. |
| Your Apple Health setting | Whether you turned Apple Health on. |
| Two internal flags | Whether you have chosen a goal yet, and whether a one-time move of older settings has already happened. |
| The rating request | The app version in which WaterBuddy last asked iOS to show its rating request, so it never asks twice in one version. |
| Which Watch servings are already counted | The identifiers of servings your Watch sent, grouped by day, so one is never counted twice — or brought back after you delete it. Entries older than about 90 days are dropped the next time a Watch serving is recorded. |

**On your Apple Watch:**

| What | Details |
|---|---|
| Servings logged on the Watch that your iPhone has not confirmed yet | The amount, the moment and the identifier of each. Removed as soon as your iPhone confirms it. |
| A copy of what your iPhone last sent | Today's total, your goal, your three amounts, your language, whether you have chosen a goal, when the copy was made, when your iPhone's day starts and ends, and the identifiers of up to 256 Watch servings your iPhone has already counted — so the Watch and its complications can show the right figures before the next sync. |

**Held by iOS itself, on your iPhone:** up to 64 pending reminder notifications, if you turn reminders on. See *Notifications*.

**Worked out when shown, and stored nowhere:** your streak, your month view, your patterns, your insights, your monthly recap and your pace are all computed from your servings on your iPhone each time they are drawn.

**Never stored:** whether you have Premium (the app asks Apple's StoreKit each time it starts and keeps the answer in memory); the weight and activity level you may enter in the first-run goal calculator (they suggest a goal on screen and are forgotten when the screen closes — only the goal you then choose is saved); the wording Apple's on-device model writes for an insight (kept in memory until the app closes); and the recap image (made in memory when you open the recap).

**That is the complete list.** WaterBuddy stores no name, no email address, no account, no password, no payment details, no device identifier, no advertising identifier, no location, no health record of its own, no contacts, no photos, no audio, no IP address, no crash report and no analytics event. None of these is ever created, so none can be stored.

**Copied to Apple Health, only if you turn it on:** each serving's amount and moment, as Water. See *Apple Health, if you turn it on* below.

The app uses no Keychain, no iCloud storage and no CloudKit sync, so it does not back your history up itself. If your device's own backups are on, those are made by Apple under Apple's terms.

**Where exactly it lives.** On your iPhone, WaterBuddy and its widgets — the Home Screen, week and Lock Screen widgets and the Control Center control — share one storage container, because they show you the same numbers; your history itself is read only by the app. On your Apple Watch, the Watch app and its complications share a second container, on the Watch. Apple confines each container to WaterBuddy: no other company's app can read it.

---

## What leaves your device

**Nothing is ever sent to us, to a server of ours, or to a third party chosen by us.** What does leave a device, and how:

### 1. Between your iPhone and your own Apple Watch

Your iPhone and the Apple Watch paired with it exchange data through Apple's WatchConnectivity, which links two devices you own and personally paired. It needs no account, no server and no special permission. This is everything that travels on it:

**From your Watch to your iPhone**, when you log water on your wrist:
- the amount in millilitres
- the moment you logged it
- a random identifier for that serving
- a batch identifier and a few numbers used to put a split message back together
- a "wake" signal that carries no data at all, so your iPhone takes the serving promptly

**From your iPhone to your Watch**, so the Watch shows the right figures:
- today's total, your goal and your three amounts, in millilitres
- your language (or nothing, if you follow your device's language)
- whether you have chosen a goal
- when the message was composed, and when your iPhone's day starts and ends
- the identifiers of servings your iPhone has already counted, so your Watch can stop resending them

Your iPhone may also send that same summary straight to your Watch's complication. Nothing else travels between the two: no name, no device identifier, no account, no location.

**A qualification we would rather state than hide:** when your Watch hands a serving to iOS for delivery, iOS holds it in a system queue outside the app until your iPhone can be reached, and that queue survives the app being closed. If you delete a serving on your iPhone before its Watch copy arrives, the copy is not cancelled; your iPhone recognises it on arrival and discards it, so the deleted serving does not come back.

### 2. Premium, through Apple

WaterBuddy is free, and logging water is free for everyone, always. **Premium** is an optional purchase — monthly, yearly or once — that adds a month view and full history, patterns, personal insights, a monthly recap, your own reminder schedule, a pace line and reminders only when you're behind.

Premium is sold and paid for entirely through Apple's App Store, under your Apple Account. When you open the Premium screen, the app asks the App Store for the plans and their prices in your country, and whether a free week is open to you; buying, restoring a purchase, asking a parent to approve one (*Ask to Buy*) and managing a subscription all take place in Apple's own sheets. Apple processes the payment, and StoreKit checks the purchase on your iPhone.

**We receive nothing about you from any of this** — not your name, your email, your Apple Account or your payment details. The app stores nothing about a purchase: it asks StoreKit whether you have Premium each time it starts, and keeps the answer in memory. Apple gives developers anonymous, aggregate sales reports through App Store Connect, which are not tied to anything you log. If a subscription ends, the extras go quiet; no serving, setting or figure is lost or hidden.

### 3. The rating request

At most once per app version — after you reach your goal on the Home screen on the third day in a row — WaterBuddy asks iOS to show Apple's standard rating request. iOS decides whether it appears. If you rate the app or write a review, that goes to Apple, under Apple's terms; the app learns nothing of what you chose. The app keeps only the version number in which it asked.

### 4. Siri and the Shortcuts app

WaterBuddy offers three actions in the Shortcuts app; the first two can also be asked of Siri by phrase, and appear in Spotlight:

- **Log a Glass** — logs your Glass amount. Siri replies with the same two words every time, *"Water logged."*, which carry no number. It works on a locked iPhone, because logging water reveals nothing.
- **Today's Water** — Siri says aloud today's total and how much is left to your goal. **On a locked iPhone, Siri asks you to unlock first**, so your figures are said only once you have authenticated. Bear in mind that Siri speaks them out loud.
- **Log Water** — logs an amount you choose, in a Shortcut; it is also what the widgets' buttons and the Control Center control run.

Your request to Siri is handled by Apple, under Apple's privacy policy. WaterBuddy does not volunteer or donate your activity to Siri. If **you** build a Shortcut with one of these actions, Apple's Shortcuts app stores it, and it may sync through your own iCloud if Shortcuts syncing is on — your Shortcut, in your iCloud, under Apple's terms, not something WaterBuddy sends.

### 5. A monthly recap you choose to share

The monthly recap (Premium) can be shared as an image, **only when you tap *Share as an image***. The image shows the month's name, the days you met your goal out of the days counted, a dot for each day, the litres you drank, your daily average and the change from the month before. It never shows your streak, a single serving, a time of day or your goal. It is made in memory and written to no file by the app. Where it goes is your choice in iOS's share sheet, and once it arrives there it is governed by whatever app or person you sent it to. WaterBuddy does not ask for access to your photo library, so iOS does not offer to save the image to Photos.

### 6. Links you tap

*Terms of Use* (Apple's standard licence) and *Privacy Policy* (this page) open in Safari when you tap them. This page is hosted by GitHub Pages, so a visit to it is handled by GitHub under GitHub's privacy statement, which may include your IP address; the app itself sends nothing when you tap.

### 7. Apple Health, if you turn it on

*Apple Health* in Settings is **off until you turn it on**. When you do, iOS asks whether WaterBuddy may write **Water** to Health — and WaterBuddy asks to read nothing.

- **What is written:** each serving you log — its amount in millilitres and the moment you logged it — as a Water entry, with the serving's random identifier, a version number and a mark that you entered it yourself, so that correcting or deleting the serving in WaterBuddy corrects or deletes its entry in Health. Nothing else: no goal, no streak, no name, no language.
- **Everything you have logged is written once** when you turn it on, and each new serving after that — whichever way you log it. A serving logged from a widget or Control Center reaches Health the next time WaterBuddy opens. Entries WaterBuddy wrote before — from an earlier install, or on another iPhone — are left as they are.
- **WaterBuddy's log leads.** While it is on, an entry you delete in Health comes back as long as its serving is still in WaterBuddy: to remove water from both, delete the serving in WaterBuddy.
- **Nothing is read.** WaterBuddy reads back only the entries it wrote itself, to keep them in step. Water other apps write to Health is never read, and no figure WaterBuddy shows comes from Health.
- **Health is Apple's.** Health keeps its data on your iPhone, encrypted, and syncs it through iCloud only if Health is turned on in your iCloud settings — under Apple's terms, not ours. Nothing is sent to us.
- **Turning it off** stops the writing. It deletes nothing: what is in Health is yours, and you can delete it in your iPhone's Settings — *Privacy & Security*, then *Health*, then *WaterBuddy*, then *Data from "WaterBuddy"*. Deleting WaterBuddy leaves it in Health too.

---

## Personal insights, written on your iPhone

Insights (Premium) describe your last finished week — what changed, what went well and one suggestion. **WaterBuddy decides what an insight says.** It writes its own sentences from your weekly figures — averages, the days you met your goal, when in the day you drank — on your iPhone.

When the app is in English, on an iPhone where Apple's on-device model is available and turned on, WaterBuddy may hand **those sentences, and the name of the vessel it suggests**, to Apple's on-device language model to word them more naturally. It never hands over your servings, their times or anything else. The model runs on your iPhone: WaterBuddy uses only the on-device model, never Apple's Private Cloud Compute and never any other provider. The wording it returns is kept in memory until the app closes, and shown only if every number in it is one the app gave it; otherwise the app's own sentences are shown. Each insight says who wrote it — WaterBuddy or Apple's on-device model. **An insight is not medical advice.**

---

## Where your figures appear outside the app

Widgets and complications show your figures because you put them there:

- **Home Screen widgets**, including the week widget, show today's progress and your last seven days.
- **The Lock Screen widget** and **StandBy** show your percentage and total. If you turn off *Allow Access When Locked → Lock Screen Widgets* in iOS Settings, they show no figure until your iPhone is unlocked.
- **Your Watch's complications** show today's figures, and hide them whenever watchOS asks apps to hide private data.
- **The Control Center control** shows a button and a name, and no figure.

A notification never shows a figure (below).

---

## Notifications

Reminders are **optional, and off until you turn them on.**

- They are **local notifications only**: WaterBuddy has no push service and no server that could message you.
- When you turn them on, the app asks iOS for permission to show alerts and play a sound — nothing else: no badge, no critical alerts, no provisional permission. If you decline, reminders stay off.
- They follow the standard daily schedule, or one you set on your iPhone; at most 64 are pending at once. A reminder due within an hour of a drink is skipped, so is one whose share of your goal you have already drunk if you choose *only when behind*, and the rest of today's are skipped once you reach your goal.
- **A reminder contains no number and no personal information.** Each uses the same fixed title and line, in your language. Your total, your goal, your amounts and your times never appear in one, because a lock screen can be read by anyone nearby.
- Each reminder carries a **Log a Glass** button. Pressing it logs your Glass amount without opening the app and without unlocking your iPhone, and shows nothing in return.
- iOS may group reminders into its Notification Summary, and may mirror them to your Apple Watch; either way the text carries no number.
- Turning reminders off removes WaterBuddy's pending reminders from your device.

---

## Analytics, tracking and advertising

WaterBuddy performs **no tracking of any kind.**

- It does not use Apple's advertising identifier, the vendor identifier or any other device identifier, and never shows the App Tracking Transparency prompt, because it has nothing to ask for.
- It has no analytics, no usage counting, no session logging, no telemetry and no crash reporting of its own.
- It writes nothing to the clipboard and no file outside its own storage.
- The only identifiers it creates are random ones for a single serving or a single sync message. They name a glass of water, not a person, and they travel no further than your own Watch.
- The app's privacy manifest, which Apple requires and which ships inside every part of the app, declares tracking **off**, no tracking domains and **no collected data**. It also declares, as Apple asks, the two system features the app reads and why: its own settings storage (to share your figures with its widgets), and the time since your device started (to move the background's slow lights smoothly — used only to measure time passing inside the app).

---

## The App Store privacy label

WaterBuddy's App Store privacy label says **"Data Not Collected."** That label, this policy and the code agree: the developer collects nothing, receives nothing and shares nothing with anyone.

---

## Apple's own role

WaterBuddy is distributed through Apple's App Store, and some of what it offers is provided by Apple: payments and subscriptions, Siri, notifications, the link between your iPhone and Watch, and the on-device model. Apple handles those under **Apple's** privacy policy, which we do not control: <https://www.apple.com/legal/privacy/>.

---

## Children's privacy

WaterBuddy is a hydration tracker for a general audience. It collects no personal information from anyone, including children: there is no sign-up, no profile, no messaging, no advertising and no way for the app to send anything to us. A purchase made by a child in a Family Sharing group goes through Apple's *Ask to Buy*, which Apple runs. If a parent or guardian has a question, please write to [sardorallaberganov96@gmail.com](mailto:sardorallaberganov96@gmail.com).

---

## How long data is kept, and how to delete it

**We keep nothing, because we receive nothing.** What is kept is on your own devices, and you control it.

- **Your servings are kept until you delete them.** The app never prunes your history: if you have logged water for years, every serving is still on your iPhone.
- **Delete or correct a serving** in History's week view, which shows the last seven days. A serving you have just logged can also be taken back with *Undo* on the Home screen. If a deleted serving came from your Watch and a copy is still queued by iOS, your iPhone discards the copy on arrival. Servings older than the week are shown, read-only, in the month view; they cannot be removed one by one in the app.
- **Delete everything** by deleting WaterBuddy from your iPhone, and the Watch app from your Apple Watch. iOS removes an app's storage with it — including the container the app shares with its widgets, once no app that uses it is left on the device, and no other app of ours uses it. Your servings, your goal, your settings, the Watch's copies and any pending reminders go with it.
- The record of which Watch servings are already counted keeps about 90 days and drops older days.
- **Copies in Apple Health**, if you turned it on, are Health's: deleting WaterBuddy leaves them there. Delete them in your iPhone's Settings — *Privacy & Security*, then *Health*, then *WaterBuddy*, then *Data from "WaterBuddy"*.

Nothing was ever sent to us, so there is no copy on a server to chase: deleting the app is the end of it, but for any copies in Apple Health you chose to make.

---

## Your rights under GDPR, UK GDPR, CCPA/CPRA and similar laws

These laws give you rights over personal information that a company **collects, processes or holds about you**: to access it, correct it, delete it, port it, object to its processing, and — under CCPA/CPRA — to know whether it is sold or shared and to opt out.

**WaterBuddy's developer collects, processes and holds none of your personal information.** There is no server, no account, no database and no code that could send us your data. So:

- **Access and portability:** there is nothing on our side to give you. What the app knows is shown in the app, on your device.
- **Correction:** correct a serving in History's week view, and your goal and amounts in Settings.
- **Deletion:** delete a serving, or delete the app — see above. There is no other copy to erase.
- **Sale or sharing:** your personal information has never been sold or shared, for any purpose including cross-context behavioural advertising, because we never receive it. There is nothing to opt out of.
- **Objection and restriction:** there is no processing by us to object to.
- **Non-discrimination:** logging water is free for everyone, and nothing you do about your privacy changes what you get.

Purchases, Siri and the other services Apple provides are Apple's to answer for, under Apple's privacy policy.

If you believe anything here is wrong, or want it confirmed in writing, write to [sardorallaberganov96@gmail.com](mailto:sardorallaberganov96@gmail.com) and you will get a straight answer. In the EU, the EEA or the UK you may also complain to your national data protection authority.

Where a legal basis is needed at all: the app keeps your water log on your own device to do what you opened it for; reminders and insights run only when you turn them on or open them; and a purchase is a contract you make with Apple.

---

## Changes to this policy

If WaterBuddy changes in a way that affects this page, the page is updated before or with that change, and its *Last updated* date changes. If a version ever added a network connection, an account, analytics or a third-party service, it would be said here plainly, and the App Store privacy label would change to match.

A version already installed on your device is not changed by an edit to this page: what it does is fixed by the code it shipped with.

---

## Contact

Questions, corrections or concerns about privacy in WaterBuddy:

**[sardorallaberganov96@gmail.com](mailto:sardorallaberganov96@gmail.com)**

---

## About this document

This is a factual description of how WaterBuddy works, written from a reading of the app's own source code. It is not legal advice and not a certificate of compliance with any law. If your circumstances call for one, have it reviewed by a qualified lawyer.
