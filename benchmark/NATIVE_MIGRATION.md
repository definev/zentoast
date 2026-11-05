# Native motion and direct signals migration

Validated on 2026-11-05. The library now requires Dart 3.8 / Flutter 3.32,
uses `alien_signals` privately, and no longer depends on Motor or oref.
The styled example retains its Flutter 3.47 / Dart 3.13 requirement because
it uses the separately packaged Material UI library.

## Compatibility and behavior

| SDK | Signals version resolved | Validation |
| --- | --- | --- |
| Flutter 3.32.0 / Dart 3.8.0 | 2.3.5 | Analyzer clean; 45 non-golden tests pass |
| Flutter 3.47.1 / Dart 3.13.0 | 2.4.0 | Analyzer clean; 45 non-golden tests pass |
| Flutter 3.50.0-1.0.pre-284 / Dart 3.15.0-95.0.dev | 2.3.5 | Analyzer clean; all 57 tests pass, including 83 unchanged golden frames |

The last SDK is the local migration comparison environment (framework
`666d2c4e83`); the older golden-generation history remains in README.md.
Pixels also match the original library running on this same SDK. The
Flutter 3.32 run initially attempted the golden comparisons: those 12 tests
failed pixel comparison against the newer-engine baselines while the other
45 passed. Golden tests are now explicitly tagged and excluded from the
multi-SDK behavior matrix; they remain enabled by default locally.

The lifecycle regressions cover timer configuration changes, disposal,
identity after removal, simultaneous drag participation in two viewers,
unmount during drag, immutable snapshots and duplicate show/hide. Existing
phase, reduced-motion, interruption, shared-exit and content-rebuild guards
remain. The macOS debug example hot restart succeeds without runtime errors.

## Desktop profile comparison

Baseline: repository commit `49ecee146cc70c97855d81f5ae25c759d7c6e531`,
Motor 1.1.0 and oref 2.10.0. Candidate: this working-tree migration. Both
profile builds use Flutter `666d2c4e83`, alien_signals 2.3.5, the same
integration-test harness and the same Apple M5 macOS host. Each configuration
has one warm-up and three measured repetitions. Baseline ran before candidate.
These results are separate from the historical Android measurements.

The macOS sandbox initially prevented the harness from opening its local VM
service WebSocket. For both successful profile builds, network-client
entitlement was enabled only in temporary test copies. The repository's
example entitlements were not changed.

Each cell is the median of three per-run means, using `compare.py`:

| Toasts/viewer × viewers | UI mean ms before → after | Raster mean ms before → after | Content builder calls before → after |
| --- | --- | --- | --- |
| 3 × 1 | 0.183 → 0.171 | 0.505 → 0.482 | 20 → 17 |
| 12 × 1 | 0.913 → 0.643 | 1.166 → 1.067 | 72 → 60 |
| 30 × 1 | 1.262 → 1.185 | 1.160 → 1.270 | 180 → 150 |
| 12 × 2 | 0.916 → 0.794 | 1.273 → 1.324 | 120 → 96 |

Content layouts/paints remain 3/3, 12/4, 30/4 and 24/7. Median content
builder calls decrease by 15%, 16.7%, 16.7% and 20%. Animation and drag
frames continue to reuse content, independently asserted in widget tests.
One candidate 30-toast repetition recorded 179 builder calls instead of 150;
the other two recorded 150. All repetitions are retained in the raw data.

### Limits

Frame sample counts vary sharply: baseline 45–549 and candidate 44–549 per
run. The 3-toast case records roughly 540 frames, while other cases record
roughly 45–49. Foreground/window state and scheduling were not controlled,
and other development work ran on the host during collection. Thermal state
was not recorded. These factors limit timing comparability even on the same
machine. UI means are lower in this sample, but raster means increase in two
configurations; this does not establish an FPS gain or a general performance
improvement. A controlled foreground run on a physical target device is
needed for stronger timing conclusions.

Raw data: `results/before-native-macos.json`, `results/after-native-macos.json`
and `results/comparison-native-macos.json`. Reproduce the comparison with:

```sh
python3 benchmark/compare.py \
  --before benchmark/results/before-native-macos.json \
  --after benchmark/results/after-native-macos.json \
  --output benchmark/results/comparison-native-macos.json
```

## Motion compatibility decisions

The native curve simulation retains the original finite-difference velocity
sampling, including its scale and zero-duration boundary, so drag-return and
interruption trajectories match the existing goldens. Changing that legacy
impulse is deliberately separate from removing dependencies. The existing
asymmetric top-swipe threshold is also retained. Hover still expands the
stack without pausing auto-dismiss; the README now describes that behavior.
