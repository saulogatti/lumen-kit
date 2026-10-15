import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// App without `LumenThemeExt` registered: new widgets must work with only
/// the `components.dart` import.
Widget bareApp(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

/// Pumps [widget] in a [bareApp] and ensures nothing throws.
Future<void> pumpBare(
  WidgetTester tester,
  Widget widget, {
  bool reduceMotion = false,
}) async {
  await tester.pumpWidget(bareApp(widget, reduceMotion: reduceMotion));
  expect(tester.takeException(), isNull);
}
