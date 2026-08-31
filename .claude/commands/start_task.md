# /start_task

1. Read `CLAUDE.md`
2. Read the relevant `.claude/rules/` family for the surface you'll touch — `20-state` / `25-shared-storage` / `30-rollover` for the store, `40-widget` for the extension, `50-views` / `60-design-system` / `65-accessibility` for a screen, `80-notifications` for reminders; `00-workspace`, `10-architecture` and `43-concurrency` always apply
3. Read the **DocC comments on the type you are changing** — they outrank the rules and carry the rulings the test suite cannot see (the stale-instance re-read, the ordered rollover, why a widget's glass cannot use a `Material`)
4. Check `tasks/lessons.md` for past mistakes on similar work
5. Identify the affected target(s) and surface — app only, widget only, or one of the six files compiled into **both** (`DataManager`, `LiquidGlassModifier`, `NotificationManager`, `ReminderPlan`, `WaterLog`, `WaterSurface`), and whether it touches storage, entitlements, target membership or the widget's view tree
6. Read `docs/AI_CONTEXT.md` for current project state, then the sheet that owns the subject — `docs/STATE.md` (stored shape), `docs/WIDGET.md` (widget contract), `docs/DESIGN.md` (tokens and measurements)
7. Check `HISTORY.md` for recent changes and context
8. Propose approach — outline which files will be created/modified in which order, and write the failing tests before the implementation (rule `85-testing`)
9. Wait for user approval before writing code
