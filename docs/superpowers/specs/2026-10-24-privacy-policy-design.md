# The privacy policy, published and linked — design

**Status:** approved by the owner in conversation on 2026-10-24 ("Ok"), after four rulings. Known issue
**#159** (`docs/AI_CONTEXT.md`) — the last code switch before a Release build offers set A. No roadmap
item of its own: it unblocks 1.2, 1.3 and set A, all committed and none released. The rule wording in
§5 is a proposal, typed and left unstaged for the owner (rule `99-docs-cascade`).

**Authority.** Subordinate to the DocC on the type being changed, then `.claude/rules/`, then
`CLAUDE.md`. Where it contradicts the code, the code wins and this document changes.

**Provenance.** Every claim about the repository was read at HEAD `4c76e61` on 2026-10-24, most of
them by a read-only audit of `PRIVACY.md` against the code in this session. Claims about Apple's
platform carry their source: **[ARG]** is the App Review Guidelines; **[PM]** is Apple's *Describing
use of required reason API* (the privacy-manifest documentation); the rest are marked as inferred.

---

## 1. What is being built

Three things, and a fourth the audit found:

1. **The policy, rewritten and filled.** `PRIVACY.md` was written before Premium and set A. Sixteen of
   its statements are now false or stale — "the app is free and contains no purchases", "not a single
   server address", the framework list without `StoreKit` and `FoundationModels`, a *Clear today*
   reset the app does not offer, a "wake up" signal sent the wrong way — and it says nothing of the
   insights, the recap's image, Siri's spoken total, the rating request, *Log a Glass*, the Lock
   Screen widget, StandBy or the goal calculator. It is rewritten from the code, its placeholders
   filled, and given a publishable form, `Tools/PrivacyPolicy.html`.
2. **The address in code.** `PaywallView.privacyPolicy` becomes
   `https://sardorallaberganov.github.io/waterbuddy/privacy/`.
3. **A *Privacy Policy* row in Settings, for every user.** [ARG] 5.1.1(i): every app links its privacy
   policy "within the app in an easily accessible manner". Today only the paywall carries it.
4. **The boot-time declaration.** `AuroraClock` (`AuroraBackground.swift:174`, `:178`) reads
   `ProcessInfo.processInfo.systemUptime`, a required-reason API ([PM]: *System boot time APIs*), and
   no `PrivacyInfo.xcprivacy` declares it. It came in with stage 3b (`7368dec`), after 1.1, so it has
   never been uploaded; App Store Connect refuses an upload that uses one undeclared (rule
   `15-project`'s *Submission*). All four manifests gain
   `NSPrivacyAccessedAPICategorySystemBootTime` with reason **`35F9.1`** — the elapsed time between
   events within the app, the aurora's lights placed by the seconds since the first backdrop drew.

The owner's rulings, in the order they were asked:

- **The task:** unblock the release, over set B, Apple Health and export.
- **Hosting:** the owner's GitHub user site — a repository `SardorAllaberganov.github.io` holding
  `waterbuddy/privacy/index.html`. It stays up if the app's repository is made private. That
  repository does not exist yet; creating it and pushing the page is the owner's.
- **Settings:** yes, under the language card.
- **Contact:** an address other than the account's — not yet given; the policy carries one marked
  token, `CONTACT-EMAIL`, until it is.
- **Languages:** English only, for now.
- **The developer's name and the effective date:** *Sardor Allaberganov*, and the day the page is
  published — written as 24 October 2026, for the owner to move.
- **The boot-time API:** declared, not engineered away (approved with the plan).

## 2. What happens today

- `PaywallView.privacyPolicy` is `URL(string: "OWNER-PRIVACY-URL")` (`PaywallView.swift:53`). A
  Release build offers the paywall only while a set is on sale **and** that address is `https`
  (`isOffered(debug:arguments:setsOnSale:privacyPolicy:)`, `:59`), so no Release build offers it, and
  History's Month switch, drawn only where the paywall is offered, is absent too.
- `theLinksAreApplesTermsAndAPageOfOurs` (`PremiumAccessTests.swift:349`) fails in every run, by
  design, until the address lands.
- Settings carries five cards — Premium where offered, the goal, the vessels, reminders, the language —
  and no link (`SettingsView.swift:79`).

## 3. How it works

### 3.1 The address

One constant, `PaywallView.privacyPolicy`, as now. Settings reads the paywall's declaration rather
than spelling the address a second time (rule `50-views`: a second screen asking the same question
reads the first screen's). The test pins the whole address, as `termsOfUse` is pinned, not its scheme
alone.

**What it changes:** a Release build now offers the paywall — set A is on sale — and with it History's
Month switch. Before that build is submitted, the products must exist in App Store Connect (#155) and
a purchase must have been made on a device (#156). A DEBUG build is unchanged: it offers the paywall
only when launched with `-WaterBuddyPremium`.

### 3.2 The Settings row

- After the language card, the last thing on the screen: `Link(destination:)` with the label
  *Privacy Policy*, the paywall's key, already in en, ru and uz — one string for the drawn label and
  the spoken one (rule `65-accessibility`).
- Drawn only while `PaywallView.privacyPolicy` is an `https` address — the paywall's own condition, so
  no build can draw a dead link.
- Text on the aurora, not a pane: the paywall's footer link is the precedent — `.footnote`, semibold,
  white at `PaywallStyle.textOpacity` (0.92), `.legibleOnBackdrop()`. Its contrast is measured from a
  rendered screenshot over the aurora's swing (rule `65-accessibility`), never derived.
- `minHeight` 44, the whole row's width the target (`.frame(maxWidth: .infinity)` +
  `.contentShape(Rectangle())`).
- It arrives with the cards, last (``Arrival``), and recedes with them (``ScrollDepth``).
- No haptic: it leaves the app, and Safari's arrival is the answer.

### 3.3 The manifests

All four `PrivacyInfo.xcprivacy` files gain the boot-time entry and stay byte-identical (rule
`15-project`): only the app binary calls `systemUptime` today — `AuroraBackground.swift` is app-only;
the widget and the watch draw `WidgetAurora` and `WristAurora` — but the rule keeps the four together,
and a declaration for an API a bundle does not call is harmless, where a missing one is a refused
upload [inferred from PM]. The header comment, which says UserDefaults is "the one required-reason
API this product does use", is corrected.

### 3.4 The policy

`PRIVACY.md` stays the repository's copy; `Tools/PrivacyPolicy.html` is its published form, in no
target, beside `Tools/ProductPageHeader.html` — one self-contained page, the aurora's colours, light
and dark, a phone's width. A comment at the head of each names the other: they change together. The
owner copies the HTML to `waterbuddy/privacy/index.html` in the user-site repository.

## 4. Tests, written first and seen RED

1. `theLinksAreApplesTermsAndAPageOfOurs` — pins the full address. RED today (the token).
2. `aReleaseBuildWithSetAOnSaleOffersThePaywall` — `isOffered(debug: false, arguments: [],
   setsOnSale: PremiumSet.onSale.count, privacyPolicy: PaywallView.privacyPolicy)` is `true`. RED today.
3. `PrivacyManifestTests` (new, phone unit target) — reads `PrivacyInfo.xcprivacy` out of each of the
   four **built** bundles (the app, `PlugIns/WaterBuddyWidgetExtension.appex`,
   `Watch/WaterBuddyWatch.app` and its `PlugIns/WaterBuddyWatchWidget.appex`), first proving each
   resolved; asserts the four are byte-identical, that tracking is off with no domains and no
   collected types, and that the declared categories and reasons are exactly UserDefaults
   (`1C8F.1`, `CA92.1`) and SystemBootTime (`35F9.1`). RED today on the boot-time entry.
4. `testSettingsLinksThePrivacyPolicyForEveryone` (UI) — an ordinary run, no `-WaterBuddyPremium`,
   finds exactly one *Privacy Policy* element in Settings, a link. RED today.
5. **A risk measured, not assumed:** `PremiumUITests.testTheCardLeadsSettingsAndOpensThePaywall`
   counts *Privacy Policy* as one element while the paywall sheet stands over Settings. If XCUITest
   lists the Settings row beneath it, that count becomes two. If it does, the work stops and the owner
   rules — the assertion is not narrowed to go green (rule `85-testing`).
   *(2026-10-24, measured once the row existed: it did — `("2") is not equal to ("1") - Privacy
   Policy is not one element`, *Restore Purchases* and *Terms of Use* one each. The work stopped; the
   owner ruled **"Count what the sheet adds"**: the test reads each footer label's count on Settings
   before the sheet opens and asserts the sheet adds exactly one. It still fails if the paywall's link
   becomes two elements or none; Settings' own is pinned to one by test 4. Whether VoiceOver reaches
   Settings' link beneath the sheet — a SwiftUI sheet is modal to it — is for a device.)*

## 5. The rules, proposed

- `70-privacy`, *Nothing leaves the device*: Settings' *Privacy Policy* opens the owner's page in
  Safari on the user's tap; the app fetches nothing.
- `65-accessibility`, *Tap targets* / *VoiceOver*: the Settings row is one link, its label the
  paywall's string, 44 pt tall.
- `15-project`, *Submission*: the declared reasons are `1C8F.1`, `CA92.1` and `35F9.1`, the last for
  `AuroraClock`'s `systemUptime`.

## 6. What is not in scope, and what stays the owner's

- Creating the user-site repository, pushing the page and seeing it answer — and with it closing #159.
- The contact address (`CONTACT-EMAIL`), and the App Store Connect *Privacy Policy URL* field.
- App Store Connect's products (#155), a device purchase (#156), 1.2.7's sweep.
- Russian and Uzbek versions of the policy.
- Making the source repository private, or not.
