import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentoast/zentoast.dart';

void main() {
  test('theme interpolation preserves null and interpolates spacing', () {
    const a = ToastTheme(viewerPadding: EdgeInsets.all(12), gap: 8);
    const b = ToastTheme(
      viewerPadding: EdgeInsets.all(28),
      gap: 24,
      motion: ToastMotionConfig(policy: ToastMotionPolicy.none),
    );

    expect(a.lerp(null, 0.75), same(a));
    expect(a.lerp(b, 0).viewerPadding, a.viewerPadding);
    expect(a.lerp(b, 1).viewerPadding, b.viewerPadding);
    final halfway = a.lerp(b, 0.5);
    expect(halfway.viewerPadding, const EdgeInsets.all(20));
    expect(halfway.gap, 16);
    expect(halfway.motion, same(b.motion));
    expect(a.copyWith().viewerPadding, a.viewerPadding);
    expect(a.copyWith().gap, a.gap);
    expect(a.copyWith().motion, same(a.motion));
  });

  testWidgets('theme lookup defaults without a provider or app', (
    tester,
  ) async {
    late ToastTheme actual;
    final reader = Builder(
      builder: (context) {
        actual = ToastThemeProvider.of(context);
        return const SizedBox.shrink();
      },
    );
    await tester.pumpWidget(reader);
    expect(actual, same(ToastTheme.kDefault));
    await tester.pumpWidget(ToastThemeProvider(child: reader));
    expect(actual, same(ToastTheme.kDefault));
  });

  testWidgets('nearest provider wins and only changed data rebuilds readers', (
    tester,
  ) async {
    const outer = ToastTheme(viewerPadding: EdgeInsets.all(20), gap: 10);
    const inner = ToastTheme(viewerPadding: EdgeInsets.all(30), gap: 15);
    late ToastTheme actual;
    var builds = 0;
    final reader = Builder(
      builder: (context) {
        builds++;
        actual = ToastThemeProvider.of(context);
        return const SizedBox.shrink();
      },
    );

    Widget tree(ToastTheme theme) => ToastThemeProvider(
      data: outer,
      child: ToastThemeProvider(data: theme, child: reader),
    );

    await tester.pumpWidget(tree(inner));
    expect(actual, same(inner));
    expect(builds, 1);
    await tester.pumpWidget(tree(inner));
    expect(builds, 1);
    final updated = inner.copyWith(gap: 24);
    await tester.pumpWidget(tree(updated));
    expect(actual, same(updated));
    expect(builds, 2);
  });

  testWidgets('existing viewer reacts to padding, gap and motion changes', (
    tester,
  ) async {
    late ToastProvider provider;
    var theme = const ToastTheme(
      viewerPadding: EdgeInsets.all(12),
      gap: 8,
      motion: ToastMotionConfig(policy: ToastMotionPolicy.none),
    );
    const viewer = ToastViewer(delay: null);
    Widget tree() => ToastProvider.create(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            provider = ToastProvider.of(context);
            return ToastThemeProvider(data: theme, child: viewer);
          },
        ),
      ),
    );
    final first = Toast(
      builder: (_) => const SizedBox(key: ValueKey('first'), height: 64),
    );
    final second = Toast(
      builder: (_) => const SizedBox(key: ValueKey('second'), height: 64),
    );

    await tester.pumpWidget(tree());
    provider.show(first);
    provider.show(second);
    await tester.pump();
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(const ValueKey('first'))).dy, 20);
    expect(tester.getTopLeft(find.byKey(const ValueKey('second'))).dy, 12);

    theme = theme.copyWith(viewerPadding: const EdgeInsets.all(24), gap: 16);
    await tester.pumpWidget(tree());
    expect(tester.getTopLeft(find.byKey(const ValueKey('first'))).dy, 40);
    expect(tester.getTopLeft(find.byKey(const ValueKey('second'))).dy, 24);

    theme = theme.copyWith(
      motion: const ToastMotionConfig(policy: ToastMotionPolicy.reduced),
    );
    await tester.pumpWidget(tree());
    provider.hide(second);
    await tester.pump();
    expect(provider.data, contains(second));
    await tester.pump(const Duration(milliseconds: 75));
    expect(provider.data, contains(second));

    theme = theme.copyWith(
      motion: const ToastMotionConfig(policy: ToastMotionPolicy.none),
    );
    await tester.pumpWidget(tree());
    await tester.pump();
    expect(provider.data, [first]);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
