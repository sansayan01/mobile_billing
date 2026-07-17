# Rules

## Development Rules

### Code Quality
- Follow Clean Architecture (data/domain/presentation layers)
- BLoC for all state management — no setState for complex state
- Use `equatable` for state and event classes
- Run `build_runner` after modifying `@JsonSerializable` models
- Write widget tests for critical flows

### Git Rules
- **main** branch is stable — always deployable
- Feature branches: `feature/<feature-name>`
- Commit messages: imperative mood ("Add", "Fix", "Update")

### Naming Conventions
- **Files**: `snake_case.dart` (Flutter convention)
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Blocs**: `XxxBloc`, `XxxEvent`, `XxxState`
- **Routes**: `/kebab-case`

### State Management Rules
- Events are immutable (freezed or equatable)
- Blocs emit only through `emit()`, never direct state mutation
- Loading states must be handled in UI (show shimmer/skeleton)

### Database Rules
- All Hive operations run on the main isolate (Hive is sync within Flutter)
- Migrations via Hive TypeAdapter version bumps

## Project Rules
- Flutter SDK: `>=3.1.0 <4.0.0`
- Use `Material 3` design
- Theme colors via `AppTheme` — don't hardcode colors in widgets

## Update Rule (CRITICAL — Electricity issues)

**Har file edit ke baad ye karna hai:**
1. ✅ **memory.md** — update with what was done, decisions, remaining todos
2. ✅ **graphify** — run `/graphify --update` to sync knowledge graph
3. ✅ **RPD.md / phases.md / architecture.md / design.md** — update jo bhi change hua hai
4. ✅ **CLAUDE.md** — update if config/instructions change

**Agar multiple files edit ho rahi hain (e.g. ek feature ke liye):**
- Har file edit ke immediately baad update karo — wait mat karo ki "poora feature complete ho jaye"
- Memory aur graphify dono ko har edit ke baad refresh karo
- Taaki electricity jane par bhi sab kuch saved rahe

## Parallel Work Rule (CRITICAL — Speed)

**Har kaam ko multiple subagents mein baant kar parallel karo.**
- Kabhi bhi sequentially ek task khatam karke dusra shuru mat karo agar wo parallel ho sakta hai
- **Example:** Phase 1 mein 10 tasks hain → at least 5 agents ek saath laga do
- Har agent ko ek specific, independent kaam do
- Agents file edit karein results ke saath, main unhe merge kare
- Helper agents use karo: ek schema bana raha hai, doosra auth kar raha hai, teesra UI bana raha hai

**Kyun?** Time bahut limited hai. Har kaam jitna parallel hoga, utna jaldi complete hoga.

## Graphify Rules
- Run `/graphify --update` after significant code changes
- Knowledge graph lives in `graphify-out/`
