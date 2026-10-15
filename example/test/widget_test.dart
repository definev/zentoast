import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:material_ui/material_ui.dart' show Icons;
import 'package:zentoast/zentoast.dart';

void main() {
  testWidgets('example shows and dismisses a custom toast', (tester) async {
    await tester.pumpWidget(ToastProvider.create(child: const MyApp()));
    expect(find.text('Sonner'), findsOneWidget);
    expect(find.text('Your changes have been saved.'), findsNothing);

    await tester.tap(find.text('Success').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(SonnerToast), findsOneWidget);
    expect(find.text('Your changes have been saved.'), findsOneWidget);

    final context = tester.element(find.byType(SonnerToast));
    final provider = ToastProvider.of(context);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(SonnerToast), findsNothing);
    expect(provider.data, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
