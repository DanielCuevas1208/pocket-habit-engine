# Pocket Habit Engine

[![CI status](https://github.com/DanielCuevas1208/pocket-habit-engine/actions/workflows/flutter.yml/badge.svg)](https://github.com/DanielCuevas1208/pocket-habit-engine/actions)

Pocket Habit Engine is a calm, offline app for testing one routine at a time.

Build one small experiment. Record each day. Then review the latest seven days in one chart.

Every record stays on the device. The app needs no account, no login, and no network access. It sends no notifications and reports no analytics.

## Why an experiment

Habits are easy to guess and hard to observe. A short experiment makes a routine visible.

Define three things:

1. A cue. This is the trigger that starts the routine.
2. An action. This is the smallest useful step.
3. A length. This is the number of days to observe.

The app turns these into one clear statement:

> After I finish my first coffee, I will step outside for five minutes.

Each day, mark the routine complete or leave it empty. Add a note when you notice something. The app draws one chart from the records.

## First look

The app has two tabs.

**Today** shows your experiments and the day's progress.

```text
Test one small change.
Notice what helps. Keep what fits.

     1                   1
  Active               Today

Your experiments

Morning light
After I finish my first coffee, I will step outside for five minutes.
[###############......]
7 of 14 days                71% observed
```

**Review** shows one chart per experiment.

```text
Look for a pattern.
A record is useful even when the routine changes.

Morning light                          71% this week
5 completed days so far

Day 1  Day 2  Day 3  Day 4  Day 5  Day 6  Day 7
  #      #      .      #      .      #      #

Overall observation: 71%
```

The figures above match the seeded sample data.

## Features

- Create an experiment with a cue, action, and length.
- Mark any of the latest seven days complete or missed.
- Add a short note for context on any day.
- Review completion across the latest seven days.
- Start with a useful local sample experiment.

## Architecture

The project uses four small layers:

- `ui/` renders the screens and shared interaction pieces.
- `state/` coordinates loading, changes, and screen updates.
- `domain/` calculates dates, windows, and completion rates.
- `data/` stores experiments and check-ins in SQLite.

SQLite enforces one check-in per experiment per day.

`ChangeNotifier` keeps state management local and easy to inspect.

The chart uses Flutter canvas primitives. It needs no chart library and no network.

## Data model

Two tables hold all records.

`experiments` stores the title, cue, action, start date, and target days.

`check_ins` stores one row per experiment per day, with a completed flag and an optional note.

The unique constraint on `(experiment_id, day)` prevents duplicate rows.

## Setup

Install Flutter 3.22 or newer.

Run this once when the mobile folders are absent:

```bash
flutter create --platforms=android,ios .
```

Install the project packages:

```bash
flutter pub get
```

Run the app on a connected device:

```bash
flutter run
```

The first run creates one local sample experiment.

## Sample output

The seeded fixture has five completed days in the latest seven.

```text
Morning light
After I finish my first coffee, I will step outside for five minutes.
5 completed days
71% this week
```

This output shows the seeded fixture. It does not report user results.

## Verification

Format the Dart source:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Analyze the project:

```bash
flutter analyze
```

Run the deterministic tests:

```bash
flutter test
```

GitHub Actions runs these checks on pushes and pull requests.

## Test status

Deterministic tests cover date tools, date windows, completion rates, and storage map round trips.

See `test/` for the suite.

The build environment for this document did not include Flutter.

Run the verification commands after you install Flutter.

## Limitations

- Records stay on one device.
- The app has no reminders or notifications.
- The app has no account, sync, or export flow.
- Review shows the latest seven days only.
- SQLite support targets mobile Flutter builds.
- The first run adds sample data when the database is empty.

These limits keep the project small and focused.

## Contributing

See CONTRIBUTING.md for the development workflow.

## Changelog

See CHANGELOG.md for the version history.

## License

MIT. See LICENSE for details.
