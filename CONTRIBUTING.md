# Contributing

Thanks for helping to improve Pocket Habit Engine.

## Setup

Follow the Setup section in README.md.

## Checks

Run these commands before you open a pull request.

Format the code:

```bash
dart format lib test
```

Analyze the code:

```bash
flutter analyze
```

Run the tests:

```bash
flutter test
```

## Design notes

Keep the app calm and offline by default.

One experiment is easier to review than many.

SQLite keeps the database small and portable.

## Reporting issues

Describe the expected behavior and the observed behavior.

Include the Flutter version from `flutter --version`.
