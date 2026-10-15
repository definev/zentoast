import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/animation_fixture.dart';

void main() {
  for (final (name, alignment) in [
    ('top', Alignment.topRight),
    ('bottom', Alignment.bottomLeft),
  ]) {
    testWidgets('interrupted animations preserve velocity: $name', (
      tester,
    ) async {
      final fixture = AnimationFixture(alignment: alignment, visibleCount: 5);
      await tester.pumpWidget(fixture.widget);
      fixture.show(3);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      fixture.show(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 60));
      await _snapshot(tester, fixture, '${name}_interrupt_enter');
      final target = find.byKey(const ValueKey('content-3'));
      await tester.tap(target);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 70));
      await tester.tap(target);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await _snapshot(tester, fixture, '${name}_interrupt_expand');
      fixture.provider.hide(fixture.toasts[1]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await _snapshot(tester, fixture, '${name}_interrupt_dismiss');
      await tester.tap(target);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await _snapshot(tester, fixture, '${name}_interrupt_retarget');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final (name, alignment) in [
    ('top_left', Alignment.topLeft),
    ('top_center', Alignment.topCenter),
    ('top_right', Alignment.topRight),
    ('bottom_left', Alignment.bottomLeft),
    ('bottom_center', Alignment.bottomCenter),
    ('bottom_right', Alignment.bottomRight),
    ('center_left', Alignment.centerLeft),
    ('center', Alignment.center),
    ('center_right', Alignment.centerRight),
  ]) {
    testWidgets('animation frames and hit testing: $name', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fixture = AnimationFixture(alignment: alignment, visibleCount: 5);
      await tester.pumpWidget(fixture.widget);
      fixture.show(4);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 80));
      await _snapshot(tester, fixture, '${name}_enter');
      await tester.pump(const Duration(milliseconds: 620));
      await _snapshot(tester, fixture, '${name}_collapsed');

      final target = find.byKey(const ValueKey('content-3'));
      // Tap uses the real hit test path and pauses/expands the viewer.
      await tester.tap(target);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      await _snapshot(tester, fixture, '${name}_expand');
      await tester.pump(const Duration(milliseconds: 700));
      await _snapshot(tester, fixture, '${name}_expanded');

      final direction = alignment.y > 0 ? 1.0 : -1.0;
      final drag = await tester.startGesture(tester.getCenter(target));
      await drag.moveBy(Offset(0, direction * 24));
      await tester.pump(const Duration(milliseconds: 16));
      await drag.moveBy(Offset(0, direction * 32));
      await tester.pump(const Duration(milliseconds: 80));
      await _snapshot(tester, fixture, '${name}_drag');
      await drag.cancel();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await _snapshot(tester, fixture, '${name}_return');
      await tester.pump(const Duration(milliseconds: 700));

      fixture.provider.hide(fixture.toasts[1]);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await _snapshot(tester, fixture, '${name}_dismiss');
      await tester.pump(const Duration(milliseconds: 700));
      await _snapshot(tester, fixture, '${name}_dismissed');
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('hover, overlapping viewers and responsive width', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final fixture = AnimationFixture(viewerCount: 2, visibleCount: 5);
    await tester.pumpWidget(fixture.widget);
    fixture.show(4);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 700));
    await _snapshot(tester, fixture, 'responsive_collapsed');
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(250, 350));
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('content-3'))),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 120));
    await _snapshot(tester, fixture, 'responsive_hover');
    await tester.pump(const Duration(milliseconds: 700));
    // The oldest expanded toast is away from the fixed layout anchor. Verify
    // that tapping it still reaches the GestureDetector after translation.
    await tester.tap(find.byKey(const ValueKey('content-0')));
    await mouse.moveTo(const Offset(250, 350));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 120));
    await _snapshot(tester, fixture, 'responsive_collapse');
    await mouse.removePointer();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _snapshot(
  WidgetTester tester,
  AnimationFixture fixture,
  String name,
) async {
  await expectLater(
    find.byKey(fixture.boundaryKey),
    matchesGoldenFile('goldens/animation/$name.png'),
  );
}
