# Calorie Tracker Flutter

A **Flutter cross-platform starter app** focused on calorie tracking, hydration, recipes, mindful eating, Middle Eastern food education, and a roadmap-friendly architecture for future AI / backend integrations.

## Included in this starter
- Welcome + onboarding flow
- Guest entry and profile setup
- Daily dashboard
- Food logging with Middle Eastern / Lebanese sample foods
- Mock AI photo recognition action
- Mock barcode lookup action
- Recipes explorer
- Weekly meal planner + shopping list
- Weight progress tracker
- Mindful eating journal
- Hydration tracker
- Cultural food education section
- Community placeholder section
- Settings & preferences

## Notes on scope
This is an **MVP starter** with local in-memory demo data. The requested product scope is much larger than a first version, so this code is intentionally structured as a foundation you can extend into:
- real authentication
- SQLite / Isar / Drift persistence
- API-backed food database
- camera + ML food recognition
- barcode scanning
- reminders / notifications
- charts and analytics
- community features and cloud sync

## Open the project
1. Install Flutter.
2. Unzip this folder.
3. In the project folder, run:

```bash
flutter pub get
flutter run
```

## Build an Android APK
For a quick installable release APK:

```bash
flutter build apk --release
```

For smaller device-specific APKs:

```bash
flutter build apk --split-per-abi
```

On modern Samsung flagships, the correct output is usually the **arm64-v8a** APK.

## Suggested next phase
- Add local persistence
- Add JWT auth + backend
- Add camera and barcode plugins
- Add Arabic localization
- Add polished charts and reminders
- Add production Android signing config
