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
      expect(ToastCategory.general.toString(), 'ToastCategory(general)');
      expect(ToastCategory.success.toString(), 'ToastCategory(success)');
    });
  });

  group('Toast with category', () {
    testWidgets('should have default category', (tester) async {
      final toast = Toast(
        builder: (toast) => const Text('Test'),
      );

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
    testWidgets('should show all toasts when categories is null',
        (tester) async {
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
                          categories: null,
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

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('should show all toasts when categories is empty',
        (tester) async {
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
                      const SafeArea(
                        child: ToastViewer(
                          categories: [],
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

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
    });

    testWidgets('should only show toasts matching specified categories',
        (tester) async {
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

    testWidgets('should support multiple viewers with different filters',
        (tester) async {
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
                          child: ToastViewer(
                            categories: [ToastCategory.error],
                          ),
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

    testWidgets('should filter out toasts not in category list',
        (tester) async {
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
                        child: ToastViewer(
                          categories: [ToastCategory.success],
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

      expect(find.text('General'), findsNothing);
      expect(find.text('Success'), findsOneWidget);
    });
  });

  group('Backward compatibility', () {
    testWidgets('should work with existing code without categories',
        (tester) async {
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
                      const SafeArea(
                        child: ToastViewer(),
                      ),
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
    testWidgets('should correctly handle toast deletion with filtered viewer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ToastProvider.create(
            child: Builder(
              builder: (context) {
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
                                  builder: (toast) => ElevatedButton(
                                    onPressed: () => toast.hide(context),
                                    child: const Text('General Toast'),
                                  ),
                                ).show(context);
                                Toast(
                                  category: ToastCategory.error,
                                  builder: (toast) => ElevatedButton(
                                    onPressed: () => toast.hide(context),
                                    child: const Text('Error Toast'),
                                  ),
                                ).show(context);
                                Toast(
                                  category: ToastCategory.warning,
                                  builder: (toast) => ElevatedButton(
                                    onPressed: () => toast.hide(context),
                                    child: const Text('Warning Toast'),
                                  ),
                                ).show(context);
                              },
                              child: const Text('Show Toasts'),
                            ),
                          ],
                        ),
                      ),
                      // Viewer showing only errors and warnings
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

      // Only error and warning should be visible
      expect(find.text('General Toast'), findsNothing);
      expect(find.text('Error Toast'), findsOneWidget);
      expect(find.text('Warning Toast'), findsOneWidget);

      // Hide the error toast
      await tester.tap(find.text('Error Toast'));
      await tester.pumpAndSettle();

      // Error should be gone, warning should still be there
      expect(find.text('Error Toast'), findsNothing);
      expect(find.text('Warning Toast'), findsOneWidget);
    });
  });
}
