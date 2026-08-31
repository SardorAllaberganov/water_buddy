# /add_feature <surface> <feature>

Follow the layer rules — build bottom-up, tests first. Never skip layers, and never let a view do
arithmetic the widget also has to do.

1. **Spec** — write it down before any code. Which of the two front doors it touches (the app, the
   widget, or both), what it stores, and what it must still do after a day rollover
2. **Failing tests** (`WaterBuddyTests/<Feature>Tests.swift`)
   - One `@Suite` per feature, its own UUID-named throwaway `UserDefaults` suite and an in-memory
     `ModelContainer` — never the real `group.sardor.WaterBuddy` suite, never `UserDefaults.standard`
   - Inject the `Calendar` and the `now: () -> Date` clock; pass `reloadWidgets: {}` and
     `rescheduleReminders: { _ in }` so the fixture cannot reach the real notification centre
   - **Run them and verify RED** before writing the implementation
3. **Model** (if new stored shape)
   - A new `@Model` property on `WaterLog`, or a new key on `DataManager.Key` — namespaced
     `sardor.WaterBuddy.<name>`, because an App Group domain is shared by every target that joins it
   - Decide whether it is authored or **derived**; if derived, it is recomputed after every
     mutation, never stored as an authored value
4. **`DataManager`** — the only writer
   - Add the mutation to the public surface; `refresh()` first if it computes from current state
   - Write through the property setter, not `defaults.set` — that is where the clamp, the equality
     guard and the widget doorbell live
   - Clamp on the way in, and guard anything that writes on behalf of the group with `isAppExtension`
5. **Widget** (only if the widget shows it)
   - Carry it on `WaterSnapshot`, read through `DataManager.snapshot(defaults:calendar:now:)` —
     never `DataManager.shared` from a timeline provider
   - Branch on `widgetRenderingMode` for anything tinted, and keep the read path `nonisolated`
6. **Views** (`WaterBuddy/<Feature>View.swift`)
   - Presentation state only; everything else comes from `DataManager`
   - Use the design-system modifiers and tokens — no ad-hoc colour, radius or spacing literals
   - Every user-facing string goes through the string catalog, in all three languages
7. **Accessibility** — label, value and traits on anything interactive; hide decorative layers;
   honour Reduce Motion and Reduce Transparency; check it at the largest Dynamic Type size
8. **Reminders** (if the feature changes when a reminder should fire)
   - The decision goes in `ReminderPlan` as a pure value; only `NotificationManager` files and
     unfiles, and only identifiers under `ReminderPlan.identifierPrefix`
9. **Gate** — tests GREEN, widget extension builds, zero new warnings, then run the app and put the
   widget on the Home Screen if this touched storage, entitlements, target membership or the
   widget's view tree
10. **/doc_sync**

## File naming
- One type per file, named for the type: `WaterLog.swift`, `ReminderPlan.swift`, `HistoryView.swift`
- Types `PascalCase`, members `camelCase`, cases `camelCase`
- A view is `<Name>View.swift`; a `ViewModifier` and its `View` extension share one file
- A new file under `WaterBuddy/` is **app-only by default** — adding it to the widget means editing
  the `membershipExceptions` list in `project.pbxproj`, which changes the shared-file contract
