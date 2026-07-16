# CLAUDE.md — Flutter Billing App

## Project
**Flutter Billing App** — Barcode scanner, cart management, thermal receipt printing, UPI QR payments for small shops.

## Tech Stack
- **Framework**: Flutter 3.x (Dart)
- **State Management**: flutter_bloc (BLoC pattern)
- **Local DB**: Hive
- **Navigation**: go_router
- **DI**: get_it
- **Printer**: print_bluetooth_thermal (ESC/POS)
- **Scanner**: mobile_scanner

## Architecture
Clean Architecture — Presentation (Bloc+UI) / Domain (Entities+UseCases) / Data (Repos+Hive)

## Key Files & Their Use Cases

| File | Kab Update Karna Hai |
|---|---|
| **[RPD.md](RPD.md)** — Requirements | Jab bhi koi **new feature add/remove** kare, ya existing feature change kare |
| **[architecture.md](architecture.md)** — Architecture | Jab **project structure, folder layout, patterns** change kare |
| **[rules.md](rules.md)** — Dev Rules | Jab koi **naya convention, naming style, git rule** decide kare |
| **[phases.md](phases.md)** — Roadmap | Jab koi **phase complete ho, ya naya phase/task add** kare |
| **[memory.md](memory.md)** — Session Log | Har session ke **end mein** — kya kiya, kya decision liya, kya todo bacha |
| **[design.md](design.md)** — Design System | Jab **UI, theme, colors, typography, components** change kare |

## When Answering
- Keep answers in Hinglish (Hindi + English mix)
- Keep it concise and to the point
- Remember: "bro", "bhai" is fine
- Always update memory.md, RPD.md, phases.md with any significant changes
- Graphify installed — use `/graphify .` for knowledge graph when needed
- Repo: https://github.com/sansayan01/mobile_billing.git

## Build Commands
```bash
flutter pub get          # install dependencies
flutter run              # run on connected device
flutter build apk        # build APK
dart run build_runner build  # run code generation
```
