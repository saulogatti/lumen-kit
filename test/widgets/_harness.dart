import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// App without a registered `LumenThemeExt`: new widgets must work with only
/// the `components.dart` import.
///
/// [reduceMotion] wraps the navigator, so dialogs, sheets and overlays opened
/// from [child] see it too. The rest of the test view's [MediaQueryData]
/// (size, padding, text scale) is kept.
Widget bareApp(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
  builder: (context, navigator) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: navigator!,
  ),
  home: Scaffold(body: Center(child: child)),
);

/// Bombeia [widget] num [bareApp] e garante que nada explodiu.
Future<void> pumpBare(WidgetTester tester, Widget widget, {bool reduceMotion = false}) async {
  await tester.pumpWidget(bareApp(widget, reduceMotion: reduceMotion));
  expect(tester.takeException(), isNull);
}
