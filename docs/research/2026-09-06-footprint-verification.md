# Footprint calculator: verification record

Date: 2026-09-06. Covers tasks 1 to 17 of
`docs/superpowers/plans/2026-09-05-footprint-calculator.md`.

## Automated gates

| Gate | Result |
|---|---|
| `flutter analyze` | clean, no issues |
| `dart format --set-exit-if-changed lib test` | clean |
| `flutter test` | 340 passed |
| `flutter build apk --debug --flavor full` | built |
| `cargo clippy` on the new modules | clean |
| `cargo test --test ideas_context --test app_events` | 17 passed |

Two pre-existing failures were confirmed against a clean tree and are not
related to this work: `scraping_e2e::test_manual_db_insert` fails on a
duplicate key in the papers table, and clippy warns in `build.rs` and
`papers_scorer.rs`.

## Device coverage

Every new screen renders on all sixteen profiles in
`test/helpers/responsive_test_helper.dart`, in English and in Arabic:

iPhone 5 (320x568), 360x640, 350x950, baseline 375x812, iPhone 14 (390x844),
Motorola G32 (393x873), Pixel 4 (412x732), iPhone 14 Plus (428x926), 390x860,
390x861, 640x360 landscape, 1280x720 landscape, 360x1000, 500x960,
Fold outer (584x680), iPhone 14 landscape (844x390).

Also verified at 200% OS text scale, and with the OS reduce-motion setting on.

## What the tests actually caught

Each of these was a real defect, not a test that needed adjusting.

- The particle cloud gave the dominant habit the whole 400-dot budget, so
  every smaller habit vanished. With values spanning nine orders of magnitude
  that is the normal case. It now reserves one dot per habit.
- `buildTestableWidget` hardcoded a locale list that omitted Arabic while the
  app uses the generated one, so every Arabic widget test rendered English and
  passed without testing anything.
- The same helper applied its MediaQuery around `home`, so a pushed route
  inherited none of it. A screen with a running animation then hung
  `pumpAndSettle` forever.
- The chapter-answered flag was wiped by the value change, because both
  callbacks build from the same stale input.
- The cloud's fixed 2:1 aspect ratio ate short landscape screens.
- Back and Next did not fit side by side at 200% text scale.
- The Explore icon was under the 44dp minimum tap target on a 320-wide phone.
- An early Explore placement stole height the category grid needs, breaking
  five existing layout tests; an early auto-route covered the screen under
  test, which is exactly what it would have done to a real user on launch.
- `AppError::InvalidInput` maps to 400 in this codebase, not the 422 the spec
  assumed.
- The context helper split `score_idea`'s doc comment, orphaning its parameter
  documentation onto a constant.

## Mutation testing

Tests are only worth what they catch, so each critical guarantee was verified
by breaking the code and confirming the suite went red. Twenty-three mutations
across the work, all red, all restored:

model coefficients and the car multiplier; the answered-chapter filter; the
cooler-jug unknown tag; mass ordering; RTL bidi isolates; one-significant-
figure rounding; slider unit keys; category-key mapping; duplicate control
fields; reduce-motion; the dot budget; per-habit dot reservation; shape coding;
the cloud's semantic label; the event dictionary; the uuid-only install id; the
batch cap and its off-by-one; the analytics off switch; response-status
checking; context size and object validation; prompt-injection filtering in the
scorer; the log bar scale; the consent gate; the optional habit context; and
`NeverScrollableScrollPhysics` on the story.

One test was found to be worthless and rewritten: a failed flush was asserted
with a 500 response, but `http` returns a 500 normally rather than throwing, so
the failure path was never exercised. The service now checks the status, and
both failure modes are covered.

## Not done

- **No run on a real handset.** No device was attached and none could be
  reached over the network. The APK builds for the full flavour, which covers
  compilation, assets and Gradle, but not touch, fonts or performance in the
  hand.
- **Migrations 048 and 049 are committed and unapplied.** Run `sqlx migrate
  run` against the live database before the Help door or the usage funnel is
  used in anger.
- **The three-student test has not been run.** The protocol is in the umbrella
  spec; results belong in this directory.
- **Two sources still read only as abstracts**: the Water Research 2026 storage
  study behind the 9.3x hot-car multiplier, and Choi 2025 behind the
  story-plus-numbers rule. Read both before the numbers ship publicly.
- **Translations** for Czech, Spanish, French and Russian. English and Arabic
  ship together; the rest fall back and are queued in `docs/l10n-queue.md`. A
  test fails the build if English is pasted into those files.
