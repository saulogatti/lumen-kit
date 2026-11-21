import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/date_time_section.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('start date opens the Lumen picker and keeps the chosen day', (tester) async {
    await _pumpSection(tester);
    final start = find.widgetWithText(LumenDatePicker, 'Start date');
    expect(tester.widget<LumenDatePicker>(start).value, isNull);

    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byType(LumenDialog), findsOneWidget);
    await tester.tap(find.byTooltip('Switch to input'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '04/18/2027');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(LumenDialog), findsNothing);
    expect(tester.widget<LumenDatePicker>(start).value, DateTime(2027, 4, 18));
    expect(find.text('18/04/2027'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('birth date jumps through the year list', (tester) async {
    await _pumpSection(tester);
    final birth = find.widgetWithText(LumenDatePicker, 'Birth date');
    expect(find.text('15/06/1990'), findsOneWidget);

    await tester.tap(birth);
    await tester.pumpAndSettle();
    await tester.tap(find.text('June 1990'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1988'));
    await tester.pumpAndSettle();
    expect(find.text('June 1988'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(tester.widget<LumenDatePicker>(birth).value, DateTime(1988, 6, 15));
    expect(tester.takeException(), isNull);
  });

  testWidgets('time field keeps the picked time', (tester) async {
    await _pumpSection(tester);
    final time = find.widgetWithText(LumenTimePicker, 'Time');
    await tester.tap(time);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(tester.widget<LumenTimePicker>(time).value, isNotNull);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSection(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(padding: EdgeInsets.all(20), child: DateTimeSection()),
      ),
    ),
  );
}
