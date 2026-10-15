import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motor/motor.dart';
import 'package:zentoast/zentoast.dart';

const _instant = Motion.linear(Duration.zero);
ToastMotionTransition _transition(int ms) => ToastMotionTransition(
  position: Motion.linear(Duration(milliseconds: ms)),
  scale: Motion.linear(Duration(milliseconds: ms)),
  opacity: Motion.linear(Duration(milliseconds: ms)),
);

class Harness {
  late ToastProvider provider;
  ToastMotionConfig? motion;
  ToastMotionConfig? secondMotion;
  ToastMotionConfig theme = const ToastMotionConfig();
  bool disableAnimations = false;
  bool showViewer = true;
  Alignment alignment = Alignment.topRight;
  List<ToastCategory>? categories;
  int builds = 0;

  Widget get widget => ToastProvider.create(
    child: MaterialApp(
      home: Builder(
        builder: (context) {
          provider = ToastProvider.of(context);
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: ToastThemeProvider(
              data: ToastTheme(
                viewerPadding: const EdgeInsets.all(12),
                gap: 8,
                motion: theme,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (showViewer)
                    ToastViewer(
                      alignment: alignment,
                      delay: null,
                      motion: motion,
                      categories: categories,
                    ),
                  if (secondMotion != null)
                    ToastViewer(
                      alignment: Alignment.bottomLeft,
                      delay: null,
                      motion: secondMotion,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Toast show(String label, {ToastCategory category = ToastCategory.general}) {
    final toast = Toast(
      category: category,
      builder: (_) {
        builds++;
        return SizedBox(
          height: 64,
          child: ColoredBox(color: Colors.blue, child: Text(label)),
        );
      },
    );
    provider.show(toast);
    return toast;
  }
}

Future<void> enter(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pumpAndSettle();
}

Finder gestureFor(String label) =>
    find
        .ancestor(of: find.text(label), matching: find.byType(GestureDetector))
        .first;
double opacityFor(WidgetTester tester, String label) =>
    tester
        .widgetList<Opacity>(
          find.ancestor(of: find.text(label), matching: find.byType(Opacity)),
        )
        .last
        .opacity;

void main() {
  test(
    'motion copyWith and theme lerp retain immutable phase configuration',
    () {
      final exit = _transition(1000);
      final motion = const ToastMotionConfig().copyWith(exit: exit);
      expect(motion.enter, same(const ToastMotionTransition()));
      expect(motion.exit, same(exit));
      expect(
        motion.enter.copyWith(position: _instant).scale,
        motion.enter.scale,
      );
      expect(
        motion.dragReturn.copyWith(opacity: _instant).position,
        motion.dragReturn.position,
      );
      const a = ToastTheme(viewerPadding: EdgeInsets.all(12), gap: 8);
      final b = a.copyWith(gap: 16, motion: motion) as ToastTheme;
      expect((a.lerp(b, 0.25) as ToastTheme).motion, same(a.motion));
      expect((a.lerp(b, 0.75) as ToastTheme).motion, same(motion));
      expect((a.lerp(b, 0.5) as ToastTheme).gap, 12);
    },
  );

  testWidgets(
    'viewer motion overrides theme and enter remains selected while moving',
    (tester) async {
      final h =
          Harness()
            ..theme = const ToastMotionConfig(policy: ToastMotionPolicy.none)
            ..motion = ToastMotionConfig(
              enter: _transition(1000),
              reposition: _transition(10),
            );
      await tester.pumpWidget(h.widget);
      h.show('a');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityFor(tester, 'a'), closeTo(0.1, 0.01));
      h.show('b');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityFor(tester, 'a'), lessThan(0.5));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'long exits retain identity and reindex deletion and drag atomically',
    (tester) async {
      final h = Harness()..motion = ToastMotionConfig(exit: _transition(1000));
      await tester.pumpWidget(h.widget);
      final first = h.show('first');
      final middle = h.show('middle');
      final last = h.show('last');
      await enter(tester);
      h.provider.hide(middle);
      h.provider.onDragToastIndex.add(2);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final added = h.show('added');
      await tester.pump();
      expect(h.provider.data, containsAll([first, middle, last, added]));
      await tester.pumpAndSettle();
      expect(h.provider.data, [first, last, added]);
      expect(h.provider.willDeleteToastIndex, isEmpty);
      expect(h.provider.onDragToastIndex, {1});
      h.provider.hide(first);
      h.provider.hide(last);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(h.provider.data, [added]);
      expect(h.provider.onDragToastIndex, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('all viewers complete exit and unmount releases a participant', (
    tester,
  ) async {
    final h =
        Harness()
          ..motion = ToastMotionConfig(exit: _transition(100))
          ..secondMotion = ToastMotionConfig(exit: _transition(1000));
    await tester.pumpWidget(h.widget);
    final toast = h.show('shared');
    await enter(tester);
    h.provider.hide(toast);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(h.provider.data, [toast]);
    h.secondMotion = null;
    await tester.pumpWidget(h.widget);
    await tester.pump();
    expect(h.provider.data, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hide before entrance and no matching viewer clean up safely', (
    tester,
  ) async {
    final h = Harness()..motion = ToastMotionConfig(exit: _transition(1000));
    await tester.pumpWidget(h.widget);
    final toast = h.show('early');
    await tester.pump();
    h.provider.hide(toast);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(h.provider.data, [toast]);
    await tester.pumpAndSettle();
    expect(h.provider.data, isEmpty);
    h.categories = [ToastCategory.error];
    await tester.pumpWidget(h.widget);
    final unseen = h.show('unseen');
    h.provider.hide(unseen);
    await tester.pump();
    expect(h.provider.data, isEmpty);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('none applies targets immediately and exits without a timer', (
    tester,
  ) async {
    final h =
        Harness()
          ..motion = const ToastMotionConfig(policy: ToastMotionPolicy.none);
    await tester.pumpWidget(h.widget);
    final toast = h.show('instant');
    await tester.pump();
    expect(opacityFor(tester, 'instant'), 1);
    expect(tester.getTopLeft(find.text('instant')).dy, 12);
    h.provider.hide(toast);
    await tester.pump();
    await tester.pump();
    expect(h.provider.data, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'runtime system policy snaps unchanged targets and releases entrance hold',
    (tester) async {
      final h = Harness();
      await tester.pumpWidget(h.widget);
      h.show('motion');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      h.disableAnimations = true;
      await tester.pumpWidget(h.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      expect(opacityFor(tester, 'motion'), 1);
      expect(tester.getTopLeft(find.text('motion')).dy, 12);
      h.disableAnimations = false;
      await tester.pumpWidget(h.widget);
      h.show('new');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 50));
      h.disableAnimations = true;
      await tester.pumpWidget(h.widget);
      expect(tester.getTopLeft(find.text('motion')).dy, 20);
      h.motion = const ToastMotionConfig(policy: ToastMotionPolicy.none);
      await tester.pumpWidget(h.widget);
      expect(opacityFor(tester, 'new'), 1);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'reposition and drag return select independent configured motions',
    (tester) async {
      final h =
          Harness()
            ..motion = ToastMotionConfig(
              reposition: _transition(1000),
              dragReturn: const ToastDragReturnMotion(
                position: Motion.linear(Duration(milliseconds: 1000)),
                opacity: _instant,
              ),
            );
      await tester.pumpWidget(h.widget);
      h.show('a');
      h.show('b');
      await enter(tester);
      await tester.tap(find.text('b'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(find.text('a')).dy, closeTo(26.4, 1));
      await tester.pumpAndSettle();
      final detector = tester.widget<GestureDetector>(gestureFor('b'));
      detector.onVerticalDragStart!(DragStartDetails());
      detector.onVerticalDragUpdate!(
        DragUpdateDetails(
          globalPosition: Offset.zero,
          delta: const Offset(0, -40),
          primaryDelta: -40,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      detector.onVerticalDragCancel!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(find.text('b')).dy, closeTo(-24, 1));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('b')).dy, closeTo(12, 1));
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('shared toast waits for slowest viewer and opacity controller', (
    tester,
  ) async {
    final h =
        Harness()
          ..motion = ToastMotionConfig(exit: _transition(100))
          ..secondMotion = const ToastMotionConfig(
            exit: ToastMotionTransition(
              position: Motion.linear(Duration(milliseconds: 100)),
              scale: Motion.linear(Duration(milliseconds: 100)),
              opacity: Motion.linear(Duration(milliseconds: 1000)),
            ),
          );
    await tester.pumpWidget(h.widget);
    final toast = h.show('shared');
    await enter(tester);
    h.provider.hide(toast);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    expect(h.provider.data, [toast]);
    await tester.pump(const Duration(milliseconds: 650));
    expect(h.provider.data, [toast]);
    await tester.pumpAndSettle();
    expect(h.provider.data, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'same-frame show and hide registers newly mounted presentations',
    (tester) async {
      final h =
          Harness()
            ..motion = const ToastMotionConfig(policy: ToastMotionPolicy.none);
      await tester.pumpWidget(h.widget);
      final toast = h.show('early');
      h.provider.hide(toast);
      await tester.pump();
      expect(h.provider.data, [toast]);
      await tester.pump();
      expect(h.provider.data, isEmpty);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('exit retarget before deferred removal waits for new completion', (
    tester,
  ) async {
    final h = Harness()..motion = ToastMotionConfig(exit: _transition(100));
    await tester.pumpWidget(h.widget);
    final toast = h.show('exiting');
    await enter(tester);
    h.provider.hide(toast);
    await tester.pump();
    // Exit finishes and schedules removal for the next frame.
    await tester.pump(const Duration(milliseconds: 150));
    expect(h.provider.data, [toast]);
    h.show('new');
    await tester.pump();
    // The new toast changes the exiting toast's stack offset. Its presentation
    // must rejoin the pending set before the previous removal callback runs.
    expect(h.provider.data, contains(toast));
    await tester.pumpAndSettle();
    expect(h.provider.data.length, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('real bottom drag remains direct and reduced return snaps', (
    tester,
  ) async {
    final h =
        Harness()
          ..alignment = Alignment.bottomLeft
          ..motion = const ToastMotionConfig(policy: ToastMotionPolicy.reduced);
    await tester.pumpWidget(h.widget);
    h.show('drag');
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();
    final resting = tester.getCenter(find.text('drag'));
    final gesture = await tester.startGesture(resting);
    await gesture.moveBy(const Offset(0, 24));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 32));
    await tester.pump();
    expect(
      tester.getCenter(find.text('drag')).dy,
      closeTo(resting.dy + 32, 0.1),
    );
    await gesture.cancel();
    await tester.pump();
    expect(tester.getCenter(find.text('drag')).dy, resting.dy);
    expect(h.provider.willDeleteToastIndex, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'system policy works without MediaQuery and disposal guards callbacks',
    (tester) async {
      final h = Harness();
      await tester.pumpWidget(
        ToastProvider.create(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                h.provider = ToastProvider.of(context);
                return const ToastViewer(delay: null);
              },
            ),
          ),
        ),
      );
      final toast = h.show('no-media');
      await enter(tester);
      expect(opacityFor(tester, 'no-media'), closeTo(1, 0.001));
      h.provider.hide(toast);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
