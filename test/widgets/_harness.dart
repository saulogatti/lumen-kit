import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// App sem `LumenThemeExt` registrado: os widgets novos precisam funcionar só
/// com o import de `components.dart`.
Widget bareApp(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: Center(child: child)),
  ),
);

/// Bombeia [widget] num [bareApp] e garante que nada explodiu.
Future<void> pumpBare(WidgetTester tester, Widget widget, {bool reduceMotion = false}) async {
  await tester.pumpWidget(bareApp(widget, reduceMotion: reduceMotion));
  expect(tester.takeException(), isNull);
}
