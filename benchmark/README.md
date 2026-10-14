# Toast animation benchmark

The harness in `example/integration_test/animation_benchmark_test.dart` runs
entrance, hover expansion/collapse, 16 drag updates, spring return and dismissal.
It uses three variable toast heights with text, borders and shadows. Each
configuration (3, 12, 30 toasts in one viewer; 12 toasts in each of two viewers)
gets one unmeasured warm-up and three measured repetitions with a fresh provider.

The integration binding uses `fullyLive` so every animation vsync is rendered
between pumps. `watchPerformance` records engine `FrameTiming` values in profile
mode. The shared fixture also counts toast builder calls, content layouts and
content paints; these counters do not measure the Stack's layout passes.

Run from `example/`, using the same Flutter SDK and device for both revisions:

```sh
ZENTOAST_BENCHMARK_OUTPUT=../benchmark/results/before.json flutter drive \
  -d DEVICE_ID --profile --no-dds \
  --driver=test_driver/animation_benchmark.dart \
  --target=integration_test/animation_benchmark_test.dart \
  --dart-define=BENCHMARK_LABEL=before
```

Run again after applying the optimization, replacing `before` with `after` in
both places. Then run `python3 benchmark/compare.py` from the repository root.
Use a separate checkout for each library revision, with the same harness files.
The report uses the median of three per-run means, rather than pooling frames
from runs that contain different numbers of frames. Per-frame durations,
percentiles and sample counts are preserved in the JSON files.

The checked-in measurements use a physical Pixel 7a, Android 17, display mode
90 Hz, 1080 × 2400 at density 420, connected over USB. Flutter 3.44.4 stable
(framework `ad70ec4617`, Dart 3.12.2), Motor 1.1.0 and oref 2.8.0 were held
constant. The original library revision is
`6deb04f71961c540b3334988cf8e348e017b2585`; see `RESULTS.md` for the results.

Golden frames were captured from the original library using the same stable SDK
before modifying its animation. `flutter test` checks 83 frames at nine
alignments plus responsive, multi-viewer and hover scenarios. Another test
asserts content builders are not called by animation ticks or drag updates.
Eight frames exercise interruption and retargeting while a spring is running.

The workload is synthetic and the fixture's builder returns new widgets each
time. Applications that already return cached/const widgets may gain less.
Hover is simulated to exercise the expansion path on Android. The measurements
include scenario setup and teardown. UI and raster time are separate pipeline
stages; lowering UI time does not imply the same increase in displayed FPS.
Thermal snapshots are retained, as repeated runs on a phone can be affected by
temperature and scheduling. This is a same-device comparison, not a guarantee
for every toast implementation or device.
