# /review

Check recent changes against `.claude/rules/`:

### Layer Boundaries
- [ ] View → `DataManager` → SwiftData + `UserDefaults` — no layer skipping
- [ ] No view, intent or timeline provider writes `UserDefaults` directly
- [ ] Arithmetic both front doors show lives on `DataManager` or `WaterSnapshot`, not in a `body`
- [ ] Nothing shared imports from the widget or from a view
- [ ] A new file under `WaterBuddy/` is app-only unless `membershipExceptions` was edited deliberately

### State & Storage
- [ ] Every mutation goes through `DataManager`; today's total is derived, never authored
- [ ] Written through the property setter, not `defaults.set` — clamp, equality guard and widget
      doorbell all still fire exactly once per real change
- [ ] `refresh()` before any mutation that computes from current state
- [ ] A failed store read returns `nil` and is **never** written back as zero
- [ ] New keys namespaced `sardor.WaterBuddy.` and declared on `DataManager.Key`
- [ ] Writes on behalf of the group guarded by `isAppExtension`

### Rollover
- [ ] The day is a `yyyyMMdd` ordinal, never a stored `Date`
- [ ] `applyDailyReset` still writes the zero **before** it stamps the day
- [ ] Day bounds derived from `Calendar.waterBuddyDay`
- [ ] No unpinned `Date()` in logic — the clock is injected

### Widget
- [ ] The provider reads `WaterSnapshot`, never `DataManager.shared`
- [ ] The read path stays `nonisolated` and synchronous; no `ModelContext` in the extension's draw path
- [ ] Tinted mode handled — anything scrimmed, tinted or gradient branches on `widgetRenderingMode`
- [ ] No `Material` in widget glass
- [ ] `.invalidatableContent()` still on the figures an intent changes

### Concurrency
- [ ] `@MainActor` where it belongs; the widget read path deliberately outside it
- [ ] No `static var` on a `Sendable` type
- [ ] No new concurrency warnings — one here is a Swift 6 error later

### Views, Design & Accessibility
- [ ] Views own presentation state and nothing else
- [ ] Design-system tokens and modifiers — no ad-hoc colour, radius or spacing literals
- [ ] Reduce Motion and Reduce Transparency honoured
- [ ] Labels, values and traits on interactive elements; decorative layers hidden
- [ ] Readable at the largest Dynamic Type size; meaning never carried by colour alone
- [ ] Every user-facing string in the catalog, in all three languages

### Notifications & Privacy
- [ ] `ReminderPlan` stays pure — no `UserNotifications` import
- [ ] No `removeAllPendingNotificationRequests()`; only identifiers under `ReminderPlan.identifierPrefix`
- [ ] No notification body carries a figure the lock screen shouldn't show
- [ ] No network, no analytics, no account

### Quality
- [ ] Tests added/updated, and they were seen RED before they went GREEN
- [ ] No `#expect` narrowed to make a number pass
- [ ] Every fixture injects its own defaults, clock, `reloadWidgets` and `rescheduleReminders`
- [ ] No bare `print` outside `#if DEBUG`, and no diagnostic carrying user data
- [ ] Gate green: `WaterBuddyTests`, `WaterBuddyUITests`, widget extension builds — zero new warnings
- [ ] Ran on the simulator if this touched storage, entitlements, target membership or the widget's view tree
- [ ] Docs updated (`/doc_sync`)
