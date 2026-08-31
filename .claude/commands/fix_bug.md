# /fix_bug <description>

Autonomous bug fix — don't ask for hand-holding, just fix it.

1. **Reproduce** — find the failing `@Test`, the compiler diagnostic, or reproduce on the simulator. A bug that only shows on the Home Screen widget needs the widget on the Home Screen, not a green suite
2. **Locate** — trace it through the layers: view → `DataManager` → SwiftData + `UserDefaults`. For a widget bug, decide first whether it is in the **read path** (`WaterSnapshot`, the timeline provider) or the **write path** (`AddWaterIntent`)
3. **Root cause** — identify the actual bug, not the symptom. Read the DocC on the type you are about to change: the case you are looking at may be one the comment already rules on
4. **Write the failing test first** — add a `@Test` that reproduces it, run it, and **verify RED** before touching the implementation (rule `85-testing`). Never reshape data or weaken a `#expect` to make a number pass
5. **Fix** — make the minimal change needed. Respect the layer boundaries and the one-writer rule (`20-state`)
6. **Verify** — run the failing test GREEN, then the full gate:
   ```bash
   xcrun simctl shutdown all
   xcodebuild test -project WaterBuddy.xcodeproj -scheme WaterBuddy \
     -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16' \
     -only-testing:WaterBuddyTests -parallel-testing-enabled NO
   xcodebuild build -project WaterBuddy.xcodeproj -scheme WaterBuddyWidgetExtension \
     -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16'
   ```
   Treat every new warning as a failure
7. **Run it** — if the fix touched storage, entitlements, target membership or the widget's view tree, launch the app and put the widget on the Home Screen. The suite injects its own defaults and clock, so it structurally cannot see a missing entitlement or a blank widget
8. **Log** — `/log` the fix with the root cause, and append the pattern to `tasks/lessons.md` if it is one a future change could repeat
9. **/doc_sync** if the fix changed stored shape, the widget contract, or a documented behaviour
