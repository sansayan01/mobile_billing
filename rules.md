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

## Graphify Rules
- Run `/graphify --update` after significant code changes
- Knowledge graph lives in `graphify-out/`
