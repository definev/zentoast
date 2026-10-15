import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/animation_fixture.dart';

void main() {
  testWidgets('motion and drag frames reuse toast content', (tester) async {
    final fixture = AnimationFixture();
    await tester.pumpWidget(fixture.widget);
    fixture.show(3);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final enterBuilds = fixture.builderCalls;
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(fixture.builderCalls, enterBuilds);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(400, 400));
    await mouse.moveTo(
      tester.getCenter(find.byKey(const ValueKey('content-2'))),
    );
    await tester.pump(const Duration(milliseconds: 200));
    final hoverBuilds = fixture.builderCalls;
    for (var i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(fixture.builderCalls, hoverBuilds);
    await mouse.removePointer();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 700));

    final drag = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('content-2'))),
    );
    await drag.moveBy(const Offset(0, -24));
    await tester.pump(const Duration(milliseconds: 16));
    final dragBuilds = fixture.builderCalls;
    for (var i = 0; i < 12; i++) {
      await drag.moveBy(const Offset(0, -2));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(fixture.builderCalls, dragBuilds);
    await drag.cancel();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
