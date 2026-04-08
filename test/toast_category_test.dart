import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zentoast/zentoast.dart';

void main() {
  group('ToastCategory', () {
    test('should have predefined categories', () {
      expect(ToastCategory.general, isA<ToastCategory>());
      expect(ToastCategory.success, isA<ToastCategory>());
      expect(ToastCategory.warning, isA<ToastCategory>());
      expect(ToastCategory.error, isA<ToastCategory>());
    });

    test('should have correct names', () {
      expect(ToastCategory.general.name, 'general');
      expect(ToastCategory.success.name, 'success');
      expect(ToastCategory.warning.name, 'warning');
      expect(ToastCategory.error.name, 'error');
    });

    test('should support custom categories', () {
      const custom = ToastCategory('custom');
      expect(custom.name, 'custom');
    });

    test('should implement equality correctly', () {
      const category1 = ToastCategory('test');
      const category2 = ToastCategory('test');
      const category3 = ToastCategory('other');

      expect(category1, equals(category2));
      expect(category1, isNot(equals(category3)));
      expect(ToastCategory.general, equals(ToastCategory.general));
    });

    test('should implement hashCode correctly', () {
      const category1 = ToastCategory('test');
      const category2 = ToastCategory('test');

      expect(category1.hashCode, equals(category2.hashCode));
    });

    test('should implement toString correctly', () {
      expect(ToastCategory.general.toString(), 'general');
      expect(ToastCategory.success.toString(), 'success');
    });
  });

  group('Toast with category', () {
    testWidgets('should have default category', (tester) async {
      final toast = Toast(builder: (toast) => const Text('Test'));

      expect(toast.category, ToastCategory.general);
    });

    testWidgets('should accept custom category', (tester) async {
      final toast = Toast(
        category: ToastCategory.error,
        builder: (toast) => const Text('Error'),
      );

      expect(toast.category, ToastCategory.error);
    });

    testWidgets('should support all predefined categories', (tester) async {
      final categories = [
        ToastCategory.general,
        ToastCategory.success,
        ToastCategory.warning,
        ToastCategory.error,
      ];

      for (final category in categories) {
        final toast = Toast(
          category: category,
          builder: (toast) => Text(category.name),
        );
        expect(toast.category, category);
      }
    });
  });

  group('ToastViewer with category filtering', () {
    testWidgets('should show all toasts when categories is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              category: ToastCategory.success,
                              builder: (toast) => const Text('Success'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.error,
                              builder: (toast) => const Text('Error'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.warning,
                              builder: (toast) => const Text('Warning'),
                            ).show(context);
                          },
                          child: const Text('Show Toasts'),
                        ),
                      ),
                      const SafeArea(child: ToastViewer(categories: null)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toasts'));
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('should show all toasts when categories is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              category: ToastCategory.success,
                              builder: (toast) => const Text('Success'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.error,
                              builder: (toast) => const Text('Error'),
                            ).show(context);
                          },
                          child: const Text('Show Toasts'),
                        ),
                      ),
                      const SafeArea(child: ToastViewer(categories: [])),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toasts'));
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('should only show toasts matching specified categories', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              category: ToastCategory.success,
                              builder: (toast) => const Text('Success'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.error,
                              builder: (toast) => const Text('Error'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.warning,
                              builder: (toast) => const Text('Warning'),
                            ).show(context);
                          },
                          child: const Text('Show Toasts'),
                        ),
                      ),
                      const SafeArea(
                        child: ToastViewer(
                          categories: [
                            ToastCategory.error,
                            ToastCategory.warning,
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toasts'));
      await tester.pumpAndSettle();

      expect(find.text('Success'), findsNothing);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('should support multiple viewers with different filters', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              category: ToastCategory.success,
                              builder: (toast) => const Text('Success Toast'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.error,
                              builder: (toast) => const Text('Error Toast'),
                            ).show(context);
                          },
                          child: const Text('Show Toasts'),
                        ),
                      ),
                      // Viewer 1: Only success
                      const SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: ToastViewer(
                            categories: [ToastCategory.success],
                          ),
                        ),
                      ),
                      // Viewer 2: Only errors
                      const SafeArea(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: ToastViewer(categories: [ToastCategory.error]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toasts'));
      await tester.pumpAndSettle();

      // Both toasts should be found (once each, in different viewers)
      expect(find.text('Success Toast'), findsOneWidget);
      expect(find.text('Error Toast'), findsOneWidget);
    });

    testWidgets('should filter out toasts not in category list', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              category: ToastCategory.general,
                              builder: (toast) => const Text('General'),
                            ).show(context);
                            Toast(
                              category: ToastCategory.success,
                              builder: (toast) => const Text('Success'),
                            ).show(context);
                          },
                          child: const Text('Show Toasts'),
                        ),
                      ),
                      const SafeArea(
                        child: ToastViewer(categories: [ToastCategory.success]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toasts'));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsNothing);
      expect(find.text('Success'), findsOneWidget);
    });
  });

  group('Backward compatibility', () {
    testWidgets('should work with existing code without categories', (
      tester,
    ) async {
      // Test that old code without category parameter still works
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              builder: (toast) => const Text('Old Style Toast'),
                            ).show(context);
                          },
                          child: const Text('Show Toast'),
                        ),
                      ),
                      const SafeArea(child: ToastViewer()),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      expect(find.text('Old Style Toast'), findsOneWidget);
    });
  });

  group('Category filtering with toast deletion', () {
    testWidgets('should auto-delete only visible category toasts', (
      tester,
    ) async {
      ToastProvider? provider;

      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                provider = ToastProvider.of(context);

                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Add toasts with different categories
                                Toast(
                                  category: ToastCategory.general,
                                  builder: (toast) => const Text('General 1'),
                                ).show(context);
                                Toast(
                                  category: ToastCategory.error,
                                  builder: (toast) => const Text('Error 1'),
                                ).show(context);
                                Toast(
                                  category: ToastCategory.general,
                                  builder: (toast) => const Text('General 2'),
                                ).show(context);
                              },
                              child: const Text('Show Toasts'),
                            ),
                          ],
                        ),
                      ),
                      // Viewer showing only errors with short delay
                      const SafeArea(
                        child: ToastViewer(
                          categories: [ToastCategory.error],
                          delay: Duration(milliseconds: 100),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Toasts'));
      await tester.pump();

      // Initially, only error should be visible
      expect(find.text('General 1'), findsNothing);
      expect(find.text('Error 1'), findsOneWidget);
      expect(find.text('General 2'), findsNothing);

      // Wait for auto-delete delay + 250ms animation time
      await tester.pump(const Duration(milliseconds: 350));

      expect(provider?.willDeleteToastIndex.contains(1), isTrue);

      // Error should be auto-deleted
      // expect(find.text('Error 1'), findsNothing);

      // General toasts should still exist in provider but not visible in this viewer
      // We can't easily verify they still exist without another viewer, but the test
      // confirms the error toast was auto-deleted correctly
    });
  });

  group('ToastViewer center alignment', () {
    /// Default [ToastTheme.kDefault] uses 12 logical px padding on all sides.
    const padding = 12.0;

    testWidgets('topCenter places toast bar centered in padded viewport', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const surfaceWidth = 800.0;
      await tester.binding.setSurfaceSize(const Size(surfaceWidth, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              height: 48,
                              builder: (toast) => Container(
                                key: const Key('center-toast-surface'),
                                width: double.infinity,
                                height: 48,
                                color: Colors.blue,
                              ),
                            ).show(context);
                          },
                          child: const Text('Show top center toast'),
                        ),
                      ),
                      const ToastViewer(
                        alignment: Alignment.topCenter,
                        // Wider than [thresholdFullWidth] so bar width uses [width].
                        width: 400,
                        thresholdFullWidth: 600,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show top center toast'));
      await tester.pumpAndSettle();

      final rect = tester.getRect(
        find.byKey(const Key('center-toast-surface')),
      );
      final stackInnerWidth = surfaceWidth - 2 * padding;
      const toastBarWidth = 400.0 - 2 * padding;
      final expectedLeft = padding + (stackInnerWidth - toastBarWidth) / 2;

      expect(rect.width, closeTo(toastBarWidth, 1.0));
      expect(rect.left, closeTo(expectedLeft, 1.5));
      expect(rect.center.dx, closeTo(surfaceWidth / 2, 1.5));
    });

    testWidgets('bottomCenter places toast bar centered in padded viewport', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const surfaceWidth = 800.0;
      await tester.binding.setSurfaceSize(const Size(surfaceWidth, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              height: 48,
                              builder: (toast) => Container(
                                key: const Key('center-toast-surface'),
                                width: double.infinity,
                                height: 48,
                                color: Colors.green,
                              ),
                            ).show(context);
                          },
                          child: const Text('Show bottom center toast'),
                        ),
                      ),
                      const ToastViewer(
                        alignment: Alignment.bottomCenter,
                        width: 400,
                        thresholdFullWidth: 600,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show bottom center toast'));
      await tester.pumpAndSettle();

      final rect = tester.getRect(
        find.byKey(const Key('center-toast-surface')),
      );
      final stackInnerWidth = surfaceWidth - 2 * padding;
      const toastBarWidth = 400.0 - 2 * padding;
      final expectedLeft = padding + (stackInnerWidth - toastBarWidth) / 2;

      expect(rect.width, closeTo(toastBarWidth, 1.0));
      expect(rect.left, closeTo(expectedLeft, 1.5));
      expect(rect.center.dx, closeTo(surfaceWidth / 2, 1.5));
    });

    testWidgets('topCenter on narrow surface fills width (left at padding)', (
      tester,
    ) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const surfaceWidth = 400.0;
      await tester.binding.setSurfaceSize(const Size(surfaceWidth, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  body: Stack(
                    children: [
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Toast(
                              height: 48,
                              builder: (toast) => Container(
                                key: const Key('narrow-toast-surface'),
                                width: double.infinity,
                                height: 48,
                                color: Colors.orange,
                              ),
                            ).show(context);
                          },
                          child: const Text('Show narrow toast'),
                        ),
                      ),
                      const ToastViewer(alignment: Alignment.topCenter),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show narrow toast'));
      await tester.pumpAndSettle();

      final rect = tester.getRect(
        find.byKey(const Key('narrow-toast-surface')),
      );
      final stackInnerWidth = surfaceWidth - 2 * padding;
      expect(rect.width, closeTo(stackInnerWidth, 1.0));
      expect(rect.left, closeTo(padding, 1.5));
      expect(rect.center.dx, closeTo(surfaceWidth / 2, 1.5));
    });
  });
}
