import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../test/support/animation_fixture.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Render every vsync while waiting between gestures, rather than only the
  // frames explicitly requested by tester.pump().
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  const label = String.fromEnvironment(
    'BENCHMARK_LABEL',
    defaultValue: 'local',
  );

  testWidgets('toast animation profile benchmark', (tester) async {
    expect(kProfileMode, isTrue, reason: 'Run this benchmark with --profile.');
    final rows = <Map<String, Object?>>[];
    for (final (count, viewers) in [(3, 1), (12, 1), (30, 1), (12, 2)]) {
      // Warm the content, shaders and scenario before recording each case.
      await _scenario(tester, count, viewers);
      for (var repeat = 0; repeat < 3; repeat++) {
        late AnimationFixture fixture;
        final key = '${count}x${viewers}_$repeat';
        await binding.watchPerformance(() async {
          fixture = await _scenario(tester, count, viewers);
        }, reportKey: key);
        rows.add({
          'toasts_per_viewer': count,
          'viewers': viewers,
          'repeat': repeat,
          ...fixture.counters,
          'frames': binding.reportData![key],
        });
        debugPrint('Benchmark $label $key: ${fixture.counters}');
      }
    }
    final result = {
      'label': label,
      'platform': defaultTargetPlatform.name,
      'runs': rows,
    };
    // Single machine-readable line preserved by the runner in before/after logs.
    // ignore: avoid_print
    print('ZENTOAST_BENCHMARK ${jsonEncode(result)}');
    binding.reportData!['zentoast'] = result;
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<AnimationFixture> _scenario(
  WidgetTester tester,
  int count,
  int viewers,
) async {
  // Unmount the provider so each repetition starts with a fresh toast queue.
  await tester.pumpWidget(const SizedBox.shrink());
  final fixture = AnimationFixture(viewerCount: viewers);
  await tester.pumpWidget(fixture.widget);
  fixture.show(count);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1000));

  final target = find.byKey(ValueKey('content-${count - 1}'));
  final mouse = await tester.createGesture(
    kind: PointerDeviceKind.mouse,
    pointer: 10,
  );
  await mouse.addPointer(location: const Offset(400, 400));
  await mouse.moveTo(tester.getCenter(target));
  await tester.pump(const Duration(milliseconds: 1000));
  await mouse.moveTo(const Offset(400, 400));
  await tester.pump(const Duration(milliseconds: 1000));
  await mouse.removePointer();

  final gesture = await tester.startGesture(tester.getCenter(target));
  for (var i = 0; i < 16; i++) {
    await gesture.moveBy(const Offset(0, -3));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await gesture.cancel();
  await tester.pump(const Duration(milliseconds: 700));

  fixture.provider.hide(fixture.toasts[count - 1]);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
  expect(tester.takeException(), isNull);
  return fixture;
}
