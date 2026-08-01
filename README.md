# Pocket Habit Engine

Pocket Habit Engine helps one person test a routine without pressure.

Create an experiment. Record each day. Review the pattern.

The app stores every record on the device. It uses no account, notification, or remote analytics service.

## Value

The app turns a vague routine into a short, observable experiment.

A calm interface keeps attention on noticing, not winning.

A seven-day view makes small patterns easy to scan.

## First release

- Create a habit experiment with a cue, action, and length.
- Record a day with one accessible control.
- Add a short note for context.
- Review completion across the latest seven days.
- Start with useful local sample data.

## Architecture

The project uses four small layers:

- `ui/` contains the mobile screens and reusable interaction pieces.
- `state/` coordinates loading, mutations, and screen updates.
- `domain/` calculates dates, windows, and completion rates.
- `data/` stores experiments and check-ins in SQLite.

SQLite enforces one check-in per experiment per day.

`ChangeNotifier` keeps state management local and easy to inspect.

The chart uses Flutter canvas primitives. It needs no chart service.

## Setup

Install Flutter 3.22 or newer.

Run this once when the mobile folders are absent:

```bash
flutter create --platforms=android,ios .
```

Install project packages:

```bash
flutter pub get
```

Run the app on a connected device:

```bash
flutter run
```

The first run creates one local sample experiment.

## Example fixture output

The sample fixture contains five completed days across seven recent days.

```text
Morning light
After I finish my first coffee, I will step outside for five minutes.
5 completed days
71% this week
```

This output demonstrates the seeded fixture. It does not report user results.

## Verification

Format the Dart source:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Analyze the project:

```bash
flutter analyze
```

Run deterministic tests:

```bash
flutter test
```

GitHub Actions runs these checks for pushes and pull requests.

## Test status

Deterministic tests cover date windows, completion rates, and storage map round trips.

The local environment used for this build did not include Flutter.

Run the verification commands after installing Flutter.

## Limitations

- Records stay on one device.
- The app has no reminders or notifications.
- The app has no account, sync, or export flow.
- Review shows the latest seven days only.
- SQLite support targets mobile Flutter builds.
- The first run adds sample data when the database is empty.

These limits keep the supporting project small and focused.