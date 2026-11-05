import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentoast/zentoast.dart';

class _Harness {
  late ToastProvider provider;
  Duration? delay = const Duration(seconds: 1);
  List<ToastCategory>? categories;
  bool visible = true;
  bool secondViewer = false;

  Widget get widget => ToastProvider.create(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (context) {
          provider = ToastProvider.of(context);
          return Stack(
            children: [
              if (visible)
                ToastViewer(
                  key: const ValueKey('primary'),
                  delay: delay,
                  categories: categories,
                  motion: const ToastMotionConfig(
                    policy: ToastMotionPolicy.none,
                  ),
                ),
              if (secondViewer)
                ToastViewer(
                  key: const ValueKey('secondary'),
                  alignment: Alignment.bottomLeft,
                  delay: delay,
                  motion: const ToastMotionConfig(
                    policy: ToastMotionPolicy.none,
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );

  Toast show(String label, {ToastCategory category = ToastCategory.general}) {
    final toast = Toast(category: category, builder: (_) => Text(label));
    provider.show(toast);
    return toast;
  }
}

void main() {
  testWidgets(
    'snapshots are read-only and showing the same toast is idempotent',
    (tester) async {
      final h = _Harness()..delay = null;
      await tester.pumpWidget(h.widget);
      final toast = h.show('one');
      final snapshot = h.provider.data;
      h.provider.show(toast);
      expect(h.provider.data, [toast]);
      expect(() => snapshot.clear(), throwsUnsupportedError);
      h.show('two');
      expect(snapshot, [toast]);
      h.provider.hide(toast);
      h.provider.hide(toast);
      await tester.pump();
      await tester.pump();
      expect(h.provider.data, hasLength(1));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('ordinary rebuilds preserve the auto-dismiss deadline', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.widget);
    final toast = h.show('timer');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(h.widget);
    await tester.pump(const Duration(milliseconds: 401));
    expect(h.provider.isDismissing(toast), isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('delay and category changes replace the pending timer', (
    tester,
  ) async {
    final h = _Harness()..categories = [ToastCategory.success];
    await tester.pumpWidget(h.widget);
    final success = h.show('success', category: ToastCategory.success);
    final error = h.show('error', category: ToastCategory.error);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    h.delay = const Duration(milliseconds: 100);
    h.categories = [ToastCategory.error];
    await tester.pumpWidget(h.widget);
    await tester.pump(const Duration(milliseconds: 101));
    expect(h.provider.isDismissing(error), isTrue);
    expect(h.provider.isDismissing(success), isFalse);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(h.provider.data, [success]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('disabling auto-dismiss and disposing cancels pending timers', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.widget);
    final toast = h.show('retained');
    await tester.pump();
    h.delay = null;
    await tester.pumpWidget(h.widget);
    await tester.pump(const Duration(seconds: 2));
    expect(h.provider.isDismissing(toast), isFalse);
    h.delay = const Duration(seconds: 1);
    await tester.pumpWidget(h.widget);
    h.visible = false;
    await tester.pumpWidget(h.widget);
    await tester.pump(const Duration(seconds: 2));
    expect(h.provider.data, [toast]);
    expect(h.provider.isDismissing(toast), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'removing an earlier toast keeps the dragged toast paused by identity',
    (tester) async {
      final h = _Harness();
      await tester.pumpWidget(h.widget);
      final first = h.show('first');
      final dragged = h.show('dragged');
      await tester.pump();
      final detector = tester.widget<GestureDetector>(
        find
            .ancestor(
              of: find.text('dragged'),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
      detector.onVerticalDragStart!(DragStartDetails());
      h.provider.hide(first);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(h.provider.data, [dragged]);
      expect(h.provider.isDismissing(dragged), isFalse);
      detector.onVerticalDragCancel!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1001));
      expect(h.provider.isDismissing(dragged), isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('each presentation releases only its own drag participation', (
    tester,
  ) async {
    final h = _Harness()..secondViewer = true;
    await tester.pumpWidget(h.widget);
    final toast = h.show('shared');
    await tester.pump();
    final gestures = tester
        .widgetList<GestureDetector>(
          find.ancestor(
            of: find.text('shared'),
            matching: find.byType(GestureDetector),
          ),
        )
        .toList();
    expect(gestures, hasLength(2));
    for (final detector in gestures) {
      detector.onVerticalDragStart!(DragStartDetails());
    }
    gestures.first.onVerticalDragCancel!();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(h.provider.isDismissing(toast), isFalse);
    gestures.last.onVerticalDragCancel!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1001));
    expect(h.provider.isDismissing(toast), isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'unmounting a dragging viewer releases auto-dismiss in other viewers',
    (tester) async {
      final h = _Harness()..secondViewer = true;
      await tester.pumpWidget(h.widget);
      final toast = h.show('shared');
      await tester.pump();
      final primary = find
          .ancestor(
            of: find.descendant(
              of: find.byKey(const ValueKey('primary')),
              matching: find.text('shared'),
            ),
            matching: find.byType(GestureDetector),
          )
          .first;
      tester.widget<GestureDetector>(primary).onVerticalDragStart!(
        DragStartDetails(),
      );
      await tester.pump();
      h.visible = false;
      await tester.pumpWidget(h.widget);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1001));
      expect(h.provider.isDismissing(toast), isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('hover keeps the existing expansion and auto-dismiss behavior', (
    tester,
  ) async {
    final h = _Harness();
    await tester.pumpWidget(h.widget);
    final toast = h.show('hover');
    await tester.pump();
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(400, 400));
    await mouse.moveTo(tester.getCenter(find.text('hover')));
    await tester.pump(const Duration(milliseconds: 201));
    await tester.pump(const Duration(milliseconds: 800));
    expect(h.provider.isDismissing(toast), isTrue);
    await mouse.removePointer();
    await tester.pumpWidget(const SizedBox());
  });
}
