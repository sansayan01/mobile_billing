# CLAUDE.md — Flutter Billing App

## Project
**Flutter Billing App** — Barcode + QR scanner, cart management, thermal receipt printing, UPI QR payments, inventory management, real-time multi-user (Supabase) for phone & accessories shop.

## Tech Stack
- **Framework**: Flutter 3.x (Dart)
- **State Management**: flutter_bloc (BLoC pattern)
- **Cloud DB**: Supabase (PostgreSQL + Realtime)
- **Local Cache**: Hive (offline fallback)
- **Auth**: Supabase Auth
- **Navigation**: go_router
- **DI**: get_it
- **Printer**: print_bluetooth_thermal (ESC/POS)
- **Scanner**: mobile_scanner (barcode + QR)
- **QR Gen**: pretty_qr_code

## Architecture
Clean Architecture — Presentation (Bloc+UI) / Domain (Entities+UseCases) / Data (Repos+Supabase+Hive)

## Key Files & Their Use Cases

| File | Kab Update Karna Hai |
|---|---|
| **[RPD.md](RPD.md)** — Requirements | Jab bhi koi **new feature add/remove** kare, ya existing feature change kare |
| **[architecture.md](architecture.md)** — Architecture | Jab **project structure, folder layout, patterns** change kare |
| **[rules.md](rules.md)** — Dev Rules | Jab koi **naya convention, naming style, git rule** decide kare |
| **[phases.md](phases.md)** — Roadmap | Jab koi **phase complete/change** ho, ya naya task add kare |
| **[memory.md](memory.md)** — Session Log | **Har edit ke baad** — kya kiya, kya decision liya, kya todo bacha |
| **[design.md](design.md)** — Design System | Jab **UI, theme, colors, typography, components** change kare |

## CRITICAL — Update Rule ⚡
**Har file edit ke baad turant (electricity jane se pehle):**
1. ✅ memory.md update
2. ✅ `/graphify --update` run
3. ✅ RPD.md / phases.md / architecture.md / design.md update
4. ✅ Agar multiple files edit ho rahi hain — har file ke baad update karo, end mein nahi

## AUTO-PILOT MODE — No Questions, Just Execute 🤖⚡
**Mujhse kuch mat poochh — auto-pilot me kaam karte rehna hai.**
- Kabhi bhi mujhse permission, confirmation, ya suggestion mat maang
- Seedha kaam shuru kar, khatam kar, aur next step pe badh
- Agar kuch unclear hai to best guess le aur proceed kar
- Har session end pe agla step automatically start kar de
- Sirf tabhi ruk jab code compile na ho raha ho ya koi critical error aaye

## CRITICAL — Parallel Work Rule ⚡⚡
**Multiple subagents use karo jitna possible ho. Sequential mat karo!**
- Phase 1 ke 10 tasks = at least 5 agents ek saath
- Har agent independent kaam kare, main merge karun
- File create/edit karne vale agents ko general-purpose do

## When Answering
- Keep answers in Hinglish (Hindi + English mix)
- Keep it concise and to the point
- Remember: "bro", "bhai" is fine
- Graphify installed — keep graph updated after every edit
- Repo: https://github.com/sansayan01/mobile_billing.git

## Build Commands
```bash
flutter pub get          # install dependencies
flutter run              # run on connected device
flutter build apk        # build APK
dart run build_runner build  # run code generation
```

## Herder CLI — Live Pane Monitoring ⚡
**Herder** (terminal agent multiplexer) installed hai: `C:\Users\msrib\AppData\Local\Programs\Herdr\bin\herdr`
- App run karne par **Flutter live logcat** right vertical pane (`w5:p8`) mein stream hota hai — `com.example.billing_app` (MainActivity).
- Layout: horizontal split — left main pane, right narrow vertical strip = logs.
- Monitor karne ke liye: `herdr pane read w5:p8 --source recent --lines N --format text`
- Pane list: `herdr pane list` | Layout: `herdr pane layout --pane w5:p8`
- **Auto-pilot rule:** Jab bhi app run/debug ho rahi ho, `w5:p8` ko Monitor se watch karo (errors `E/` `F/`, warnings `W/`, crash/ANR). Normal noise (`BufferQueueProducer`, `FlutterJNI`, `WindowOnBackDispatcher`) filter karo. Har session auto-start karo, user se poochhna nahi.

## Supabase Migration Rule ⚡⚡
- Supabase MCP connected hai (`mcp__supabase__*`). Schema change ke liye `apply_migration` use karo.
- **Agar SQL editor ya kisi aur tareeke se direct SQL run bhi ho raha ho**, tab bhi **HAMESHA ek migration file banao** (DDL changes ke liye) taaki history aur rollback rahe.
- Flow: `list_tables` (existing structure samajhne) → migration file create → `apply_migration` se apply.
- Pehle `get_logs` / `get_advisors` check karo before schema change.
- `get_project_url` + `get_publishable_keys` client config ke liye.

## CRITICAL — Dart-Only Fix Preference ⚡
- **Try to fix Dart only.** Prefer fixing issues in Flutter/Dart code (UI, BLoC, repos, models) over touching the database.
- **Avoid SQL migration files** jitna possible ho — sirf tabhi banao jab schema sach mein badalna pade (new table/column/constraint). Existing schema ke against Dart code adjust karo instead of migrating.
- Agar koi bug DB structure ke wajah se ho, pehle dekho kya Dart side se workaround mil sakta hai (e.g. client-side validation, default values handle karna) before reaching for a migration.

## CRITICAL — Next Time Auto-Recall ⚡
- Herder `w5:p8` = Flutter app log pane — auto-monitor karo.
- Supabase direct SQL run ho ya na ho, migration file zaroor banao.
- In dono ko graphify knowledge graph mein bhi note rakho.
