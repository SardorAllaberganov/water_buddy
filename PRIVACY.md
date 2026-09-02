> **Placeholders:** every `[SQUARE-BRACKETED]` item below must be filled in by the app owner before publishing.

# WaterBuddy Privacy Policy

**App:** WaterBuddy (iPhone and Apple Watch)
**Developer:** [DEVELOPER NAME OR LEGAL ENTITY]
**Contact:** [CONTACT EMAIL ADDRESS]
**Effective date:** [EFFECTIVE DATE, e.g. 1 October 2026]
**Last updated:** [DATE THIS VERSION WAS PUBLISHED]

---

## In one sentence

WaterBuddy keeps everything you log on your own devices, sends nothing to us or to anyone else, and contains no code capable of contacting a server — the only data that ever leaves your iPhone is the water you logged, travelling to your own paired Apple Watch and back.

---

## Why we can say "we collect nothing" and mean it

Most privacy policies ask you to trust a promise. This one describes a structural fact about how the app is built.

WaterBuddy contains **no networking code at all**. There is no `URLSession`, no `URLRequest`, no `Network` framework, no web view, no HTTP request of any kind anywhere in the app's source. A search across all four shipping parts of the app (the iPhone app, the Home Screen widget, the Watch app and the Watch complication) returns zero matches for every networking API. There is not a single server address, domain name or API endpoint anywhere in the code or its resources.

The complete list of Apple frameworks the shipping app uses is: Foundation, SwiftUI, SwiftData, WidgetKit, Observation, UserNotifications, WatchConnectivity, AppIntents, and UIKit (used in exactly one place, to open the iOS Settings app so you can change notification permissions). None of them can reach a network on the app's behalf, and none of them is used to.

There are also **zero third-party libraries** in the project. No Swift packages, no CocoaPods, no embedded frameworks. Nothing was added by anyone but the developer, so nothing can phone home behind the developer's back.

Because there is no way for the app to send anything anywhere, there is no data for us to collect, store, sell, share, lose or be compelled to hand over. We do not have a server. We do not have a database with your name in it. We do not have your name.

---

## What the app stores, and where

Everything below lives on your device, inside the app's own private storage (an Apple "App Group" container). Nothing here is uploaded.

**On your iPhone:**

| What | Details |
|---|---|
| Your water servings | Each serving you log: an amount in millilitres, the date and time you logged it, and a random identifier generated fresh for that serving. This is the app's record of your history. |
| Today's total | Recalculated from your servings, kept so the widget can display it quickly. |
| Your daily goal | A number of millilitres. |
| The current day marker | Used to reset your total at midnight. |
| Your three quick-add serving sizes | Three amounts in millilitres. |
| Your chosen language | `en`, `ru` or `uz`, or nothing at all if you let the app follow your device's language. |
| Two internal flags | Whether you have set a goal yet, and whether a one-time internal data move has already happened. |
| Your reminders on/off setting | A yes/no value. |
| A record of which Watch servings have already been counted | A list of serving identifiers grouped by day, so a serving logged on your Watch is never counted twice. This list is kept for 90 days and then discarded. |

**On your Apple Watch:**

| What | Details |
|---|---|
| Servings you logged on the Watch that your iPhone has not confirmed yet | Amount, time and identifier for each. Cleared as soon as your iPhone confirms them. |
| A copy of what your iPhone last sent | Your total, goal, serving sizes, language and goal-set flag, so the Watch face and complication can show something before the next sync. |

**Also on your iPhone, held by iOS itself:** up to 28 pending reminder notifications, if you turn reminders on. See *Notifications* below.

**That is the complete list.** WaterBuddy stores no name, no email address, no account, no password, no device identifier, no advertising identifier, no location, no health record, no contacts, no photos, no audio, no IP address, no crash report and no analytics event. None of those things is ever created, so none of them can be stored.

The app uses no Keychain storage, no iCloud storage and no CloudKit sync. Your history is not backed up to iCloud by the app itself. (If you have iOS device backups enabled, your device backup is handled by Apple under Apple's terms, not by us.)

**One honest note about "private":** the app's storage container is shared between the four parts of WaterBuddy — the app, the Home Screen widget, the Watch app and the Watch complication — because they need to show you the same numbers. Apple scopes this kind of shared container to a single developer, so no other company's app can read it. But it is accurate to say the data is readable by all four parts of WaterBuddy, rather than by the main app alone.

---

## What leaves your device

**Nothing is ever sent to us, to a server, or to any third party.** There is no code in the app that could do so.

There is exactly one thing that does leave a device, and it deserves to be stated precisely rather than glossed over: **your iPhone and your own paired Apple Watch exchange data with each other.**

This uses Apple's WatchConnectivity, which links two devices that you own and that you personally paired. It involves no account, no server, no third party, and no special permission. Here is everything that travels on that link:

**From your Watch to your iPhone**, when you log water on your wrist:
- the amount in millilitres
- the moment you logged it
- a random identifier for that serving
- a batch identifier and a couple of numbers used to reassemble a split message

**From your iPhone to your Watch**, so the Watch can show the right numbers:
- today's total in millilitres
- your daily goal
- your three quick-add serving sizes
- your chosen language code (or nothing, if you follow your device's language)
- whether you have set a goal yet
- when the message was composed, and when your phone's day started
- a list of serving identifiers your phone has already counted, so the Watch knows it can stop resending them

The app also sends your Watch a one-word "wake up" signal that carries no data at all.

That is the entire contents of the link. No name, no device identifier, no account, no health data, no location — because none of those exist in the app.

**A qualification we would rather state than hide:** when your Watch hands a serving to iOS for delivery, iOS holds it in a system queue outside the app until your iPhone is reachable. That queue survives the app being closed. If you delete a serving on your iPhone before its Watch copy has arrived, the copy is not cancelled — instead, your iPhone recognises it as one it has already handled and discards it on arrival, so the deleted serving does not come back. It is discarded, not re-added, but it is technically true that it sat in an Apple system queue for a while.

---

## Third parties

There are none.

No advertising network. No analytics provider. No crash reporting service. No A/B testing service. No attribution or "growth" SDK. No payment processor — the app is free and contains no purchases. No third-party code of any kind is compiled into WaterBuddy.

We sell nothing, share nothing and disclose nothing to anyone, because we receive nothing in the first place.

---

## Analytics, tracking and advertising

WaterBuddy performs **no tracking, of any kind, ever.**

- It does not use Apple's advertising identifier, the vendor identifier, or any other device identifier.
- It never shows the App Tracking Transparency prompt, because it has nothing to ask for.
- It contains no analytics events, no usage counters sent anywhere, no session logging, no telemetry.
- It generates no crash reports of its own and uploads none.
- The app's own privacy manifest, which Apple requires and which is included in the shipped build, declares tracking as **false**, its list of tracking domains as **empty**, and its list of collected data types as **empty**.

The only identifiers the app creates at all are random ones attached to a single serving of water or a single sync message. A new one is made each time you tap a button, and they are never reused. They identify a glass of water, not a person, and they never travel further than your own paired Watch.

The app writes nothing to the clipboard, and writes no files anywhere outside its own storage.

---

## Notifications

Reminders are **entirely optional and off until you turn them on.**

- They are **local notifications only.** WaterBuddy does not use push notifications, does not register with Apple's push service, and has no push capability in its build. There is no server that could send you a message.
- When you turn reminders on, the app asks iOS for permission to show alerts and play a sound. Nothing else is requested — no badge, no critical alerts, no provisional authorisation. If you decline, reminders stay off.
- Every reminder is scheduled by the app on your own device, on a fixed daily schedule.
- **A reminder contains no personal information and no numbers at all.** Every reminder uses the same two fixed sentences — a title and a line of encouragement — in whichever of the three languages you use. Your total, your goal, your serving sizes and your logging times never appear in a notification. This is deliberate: a lock screen can be read by anyone standing nearby, so nothing about your day is put there.
- Turning reminders off removes the app's pending reminders from your device.

If you have your Apple Watch set to mirror iPhone notifications, iOS may show these reminders on your wrist. That is iOS doing the mirroring, and the reminder text is digit-free either way.

---

## Siri and the Shortcuts app

WaterBuddy provides a "log water" action that appears in Apple's Shortcuts app and can be used with Siri. The action itself carries no personal data, and the app never volunteers or donates your activity to Siri.

One thing worth flagging, because it is outside our control: if **you** build a Shortcut that uses this action, that Shortcut is stored by Apple's Shortcuts app, and it may sync through your own iCloud if you have Shortcuts syncing enabled. In that case a phrase such as "add 250 ml of water" could exist in your own iCloud account. That is your Shortcut in your iCloud, governed by Apple's privacy policy — not something WaterBuddy sends or stores. We mention it rather than claim an absolute containment we cannot promise.

---

## The App Store privacy label

WaterBuddy's App Store privacy label says **"Data Not Collected."** That answer and this policy agree, and both match the code: the app collects nothing, transmits nothing to any server, and shares nothing with any third party.

---

## Apple's own role

WaterBuddy is distributed through Apple's App Store. Apple collects its own information about downloads, purchases, device details and App Store usage under **Apple's** privacy policy, and Apple may provide the developer with anonymous, aggregate sales and usage statistics through App Store Connect. That data comes from Apple, not from inside the app, and it is not tied to anything you log in WaterBuddy.

We have no control over what Apple collects. If you want to know, read Apple's privacy policy at <https://www.apple.com/legal/privacy/>.

---

## Children's privacy

WaterBuddy is a hydration tracker suitable for general audiences. It collects no personal information from anyone, including children, because it collects no personal information at all — there is no sign-up, no profile, no messaging, no advertising and no way for the app to transmit anything to us.

Since nothing is ever collected from any user of any age, there is nothing for a parent or guardian to request, correct or ask us to delete. If a parent or guardian has a question, please write to [CONTACT EMAIL ADDRESS].

---

## How long data is kept, and how to delete it

**We keep nothing, because we never receive anything.** Retention is entirely a matter of what sits on your own devices, and you control all of it.

- **Your servings are kept until you delete them.** The app does not prune your history automatically. If you have logged water for years, every one of those entries is still on your iPhone. (The History screen shows a recent window of days, but that is only what is displayed — nothing older is being thrown away.)
- **Delete a single serving** from the History screen. It is removed from your records immediately. If that serving was logged on your Watch and a copy is still queued for delivery by iOS, your iPhone recognises and discards it on arrival rather than re-adding it.
- **Clear today** using the app's reset for today's progress, which removes only today's entries.
- **Delete everything** by deleting the app from your iPhone (and from your Apple Watch, if you installed it there). iOS removes the app's storage container along with the app, taking your servings, your goal, your settings and the Watch's own stored copies with it. Any pending reminders are removed too.
- The internal record of which Watch servings have already been counted is discarded automatically after 90 days.

Because none of this data was ever sent anywhere, deleting the app is genuinely the end of it. There is no copy on a server to chase.

---

## Your rights under GDPR, CCPA/CPRA and similar laws

We are not claiming a certification here — no one certifies a privacy policy. What follows is the factual position, which you can check against the description above.

Laws such as the EU/UK GDPR and the California Consumer Privacy Act give you rights over personal information that a company **collects, processes or holds about you**: the right to access it, correct it, delete it, port it, object to its processing, and — under CCPA/CPRA — to know whether it has been sold or shared and to opt out.

**WaterBuddy's developer collects, processes and holds none of your personal information.** There is no server, no account, no database, no log file, and no code capable of transmitting your data. Every one of those rights would attach to data we simply do not have:

- **Access / portability:** there is nothing on our side to give you. Everything the app knows is visible in the app itself, on your own device.
- **Correction:** you can edit or delete any serving directly in the app.
- **Deletion:** delete a serving, reset today, or delete the app — see above. There is no copy anywhere else to erase.
- **Sale or sharing:** your personal information has never been sold or shared, for any purpose including cross-context behavioural advertising, because it is never received. There is nothing to opt out of.
- **Objection / restriction:** there is no processing by us to object to or restrict.
- **Non-discrimination:** the app is free and identical for everyone; exercising a privacy right cannot change what you get, because it does not change anything we hold.

If you believe any of the above is wrong, or you want it confirmed in writing, contact [CONTACT EMAIL ADDRESS] and you will get a straight answer. If you are in the EU, EEA or UK, you also have the right to lodge a complaint with your national data protection authority.

To the extent a legal basis under GDPR is needed at all: the app stores your water log on your own device to provide the function you opened it for, and reminders are sent only on your explicit opt-in, which you can withdraw at any time by turning reminders off.

---

## Changes to this policy

If the app changes in a way that affects this document, this document will be updated before or alongside that change, and the "Last updated" date at the top will change. If a future version of WaterBuddy were ever to add a network connection, an account, analytics, or any third-party service, that would be described here plainly — and the App Store privacy label would be updated to match.

Older versions of the app already installed on your device are not changed by an update to this page. What an installed version does is fixed by the code that shipped in it.

---

## Contact

Questions, corrections or concerns about privacy in WaterBuddy:

**[CONTACT EMAIL ADDRESS]**
[OPTIONAL: POSTAL ADDRESS, IF THE OWNER WANTS OR NEEDS TO PUBLISH ONE]
[OPTIONAL: NAME AND CONTACT OF AN EU/UK REPRESENTATIVE, IF ONE IS REQUIRED]

---

## About this document

This is a factual description of how WaterBuddy works, written from a line-by-line audit of the app's own source code. It is not legal advice, and it is not a certification of compliance with any law. If your circumstances call for it — a change in where the app is distributed, a change in what it does, or a specific regulator's requirements — have this reviewed by a qualified lawyer before relying on it.
