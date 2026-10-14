# Pixel 7a animation results

Measured on 2026-10-14 with Flutter 3.44.4 stable in profile mode, Android 17, 90 Hz. Baseline library: `6deb04f71961c540b3334988cf8e348e017b2585`. Each table cell is the median of three warmed repetitions.

| Toast/viewer × viewers | UI mean ms before → after | UI reduction | Raster mean ms before → after | Builder calls before → after |
| --- | --- | --- | --- | --- |
| 3 × 1 | 1.511 → 1.229 | 18.7% | 2.782 → 2.773 | 997 → 18 |
| 12 × 1 | 3.368 → 1.991 | 40.9% | 3.118 → 3.233 | 4320 → 72 |
| 30 × 1 | 4.123 → 2.037 | 50.6% | 2.536 → 2.252 | 10858 → 180 |
| 12 × 2 | 2.627 → 2.078 | 20.9% | 2.944 → 3.702 | 5727 → 120 |

## What changed

- Reuse the toast content outside animation callbacks.
- Observe manual drag position in its own SignalBuilder.
- Anchor Positioned once and apply vertical translation at paint time, outside scale; reverse the translation sign for bottom alignment.
- Share one ListenableBuilder per motion group while retaining independent Motor controllers, motion configurations, update order and velocity.
- Preserve both opacity groups and the existing outer repaint boundary. An extra content boundary was tried and removed because content paint counts did not improve.

## Validation

- 32 widget tests pass, including 83 original-versus-optimized golden frames with exact pixel comparison.
- Covers nine alignments, different heights, responsive width, two viewers, hover, drag/cancel, dismissal, and mid-spring retargeting.
- Animation/drag rebuild regression test passes.
- `flutter analyze --no-pub lib test`: no issues. Hot reload succeeded in the macOS debug example; no runtime errors were reported.

## Limits and repeat check

UI time improved in every primary configuration. Raster time did not improve consistently: two viewers rose from 2.944 to 3.702 ms (25.7%). Content layouts and paints stayed unchanged in the fixture, so these results establish a build-work reduction, not a content-paint reduction.

The phone reached thermal status 1 during testing (started at 0). A second run of the unchanged baseline APK was recorded after the optimized run to inspect drift:

| Configuration | Initial baseline UI / raster ms | Repeated baseline UI / raster ms |
| --- | --- | --- |
| 3 × 1 | 1.511 / 2.782 | 1.385 / 2.395 |
| 12 × 1 | 3.368 / 3.118 | 2.774 / 2.833 |
| 30 × 1 | 4.123 / 2.536 | 3.916 / 2.404 |
| 12 × 2 | 2.627 / 2.944 | 3.222 / 3.486 |

Baseline raster time also varied (two viewers: 2.944 → 3.486 ms). This indicates measurement drift but does not prove the optimized raster regression is entirely caused by temperature. Do not claim a consistent GPU improvement or an FPS gain from these numbers. The raw JSON includes per-frame timings and 90 Hz budget counts; Flutter’s built-in missed-budget counters assume 60 Hz.

A repeat of the optimized APK also completed, with three measured repetitions per configuration:

| Configuration | Repeated baseline UI / raster ms | Repeated optimized UI / raster ms |
| --- | --- | --- |
| 3 × 1 | 1.385 / 2.395 | 0.942 / 2.166 |
| 12 × 1 | 2.774 / 2.833 | 1.413 / 2.545 |
| 30 × 1 | 3.916 / 2.404 | 2.805 / 3.120 |
| 12 × 2 | 3.222 / 3.486 | 1.960 / 3.622 |

Screen locking was reported during this optimized repeat. Measured runs contained 403–413 frames, but the preserved output does not establish exactly when the lock affected the run. This interruption can affect temperature and scheduling, so the repeat is supplementary; the primary comparison above remains the reported result. UI reduction persisted in all four configurations, while raster variation remains unresolved. Raw repeats are in `results/before-repeat.json` and `results/after-repeat.json`.

After the user unlocked the phone, the optimized APK was run once more with the screen kept awake throughout. The plugged-in awake setting was restored afterward. All twelve measured runs completed:

| Configuration | Unlocked repeat UI / raster ms |
| --- | --- |
| 3 × 1 | 0.970 / 1.784 |
| 12 × 1 | 1.584 / 2.773 |
| 30 × 1 | 2.707 / 3.163 |
| 12 × 2 | 2.241 / 3.783 |

This final check (`results/after-unlocked.json`) retains the build-time reduction relative to both baseline passes, with 398–413 frames per measured run. It also reproduces raster variability, including higher raster time for two viewers. It does not replace the primary comparison with more favorable numbers.

The primary scenarios contain about 400–415 frames each. Both versions still have occasional long frames. Repeat on a cool device and with application-specific toast content before drawing broader conclusions. See [README.md](README.md) for reproduction instructions.
