# Memory — Session Log & Context

## Project Context
- **Project**: Flutter Billing App
- **Repo**: `mobile_billing` → https://github.com/sansayan01/mobile_billing.git
- **Stack**: Flutter 3.x, Bloc, Hive, go_router, get_it
- **Purpose**: Barcode-based billing with thermal receipt printing for small shops

## Key Decisions
| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-07-17 | Hive over SQLite | Simpler, no SQL schema, perfect for single-device offline |
| 2026-07-17 | Bloc over Provider/Riverpod | Predictable state, easy to test, scales well |
| 2026-07-17 | go_router | Official Flutter navigation, deep linking support |
| 2026-07-17 | Clean Architecture | Maintainable, testable, separates concerns |

## Installed Tools
- **graphify** v0.9.17 — knowledge graph for codebase 🕸️
- **gh CLI** — authenticated as `sansayan01`

## Known Issues / TODOs
- Printer error handling needs improvement
- No invoice history yet (Phase 2)
- Graphify graph not built yet

## Related Files
- [RPD.md](RPD.md) — Requirements & product definition
- [architecture.md](architecture.md) — Architecture docs
- [rules.md](rules.md) — Dev rules
- [phases.md](phases.md) — Roadmap phases
- [design.md](design.md) — Design system
