# Pregnancy Tracker

An advanced, next-gen pregnancy tracker built with Flutter. Offline-first, privacy-first,
and designed to go beyond existing apps with an interactive 3D baby, a Bring-Your-Own-Key
AI assistant, and emotional keepsake features.

## Features (MVP foundation)

- **Onboarding & due-date calculator** — supports LMP, known due date, conception, and IVF
  transfer methods.
- **Today screen** — current week & day, progress ring, baby size comparison, and
  week-by-week development summaries (weeks 4–40).
- **Interactive 3D-style baby** — drag to rotate and scrub a timeline to watch the baby
  grow and change shape week by week. Fully offline; designed to upgrade to photorealistic
  glTF/AR models per week.
- **Tracking**
  - Kick counter with session history
  - Contraction timer with 5-1-1 guidance
  - Symptom & mood daily log
  - Weight & blood pressure with trend chart and high-BP awareness
- **BYOK AI Assistant** — bring your own OpenAI or Google Gemini API key. The key is stored
  only on-device in the secure enclave (Keychain/Keystore) and is never sent to any server.
- **Time Capsule** — write notes and letters to your baby to keep as a keepsake.

## Architecture

- **Flutter** (Material 3) single codebase for iOS, Android, and web.
- **Riverpod** for state management (`lib/state/app_state.dart`).
- **Offline-first persistence** via a JSON-backed `LocalStore`
  (`lib/data/local_store.dart`) over `shared_preferences`. The interface is designed to be
  swapped for a full local database (Drift/Isar) + cloud sync without touching the UI.
- **flutter_secure_storage** for the BYOK API key.
- Feature-first folder layout under `lib/features/`.

```
lib/
  core/        theme + week-by-week baby data
  data/        local persistence
  models/      pregnancy profile + log entry models
  state/       Riverpod providers
  features/
    onboarding/  today/  baby3d/  tracking/  ai/  memory/  settings/  home/
```

## Getting started

```bash
flutter pub get
flutter run            # mobile / desktop
flutter run -d chrome  # web
```

## Testing & quality

```bash
flutter analyze
flutter test
```

## Roadmap

This is the MVP foundation. Planned next: cloud sync & auth (Supabase), per-week
photorealistic 3D + AR mode, food/medication safety checkers, fetal-movement AI,
ultrasound/lab explainers, partner sharing, and postpartum continuity.

## Safety

This app provides educational information only and is **not** medical advice or a diagnostic
tool. Always consult a qualified healthcare provider for medical decisions and any warning
signs.
