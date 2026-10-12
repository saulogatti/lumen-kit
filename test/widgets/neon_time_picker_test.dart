import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

void main() {
  testWidgets('NeonTimePicker mostra o horário e devolve o escolhido', (
    WidgetTester tester,
  ) async {
    TimeOfDay? picked;
    await pumpBare(
      tester,
      NeonTimePicker(
        label: 'Horário',
        value: const TimeOfDay(hour: 9, minute: 5),
        use24HourFormat: true,
        onChanged: (TimeOfDay t) => picked = t,
      ),
    );
    expect(find.text('09:05'), findsOneWidget);

    await tester.tap(find.byType(NeonTimePicker));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, const TimeOfDay(hour: 9, minute: 5));
  });

  testWidgets('NeonTimePicker usa o format customizado e o hint', (
    WidgetTester tester,
  ) async {
    await pumpBare(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          NeonTimePicker(
            value: const TimeOfDay(hour: 14, minute: 30),
            format: (TimeOfDay t) => '${t.hour}h${t.minute}',
            onChanged: (_) {},
          ),
          const NeonTimePicker(
            value: null,
            hint: 'Escolha a hora',
            onChanged: null,
          ),
        ],
      ),
    );
    expect(find.text('14h30'), findsOneWidget);
    expect(find.text('Escolha a hora'), findsOneWidget);

    // Desabilitado: tocar não abre nada.
    await tester.tap(find.text('Escolha a hora'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsNothing);
  });

  testWidgets('showNeonTimePicker aplica o accent no ponteiro', (
    WidgetTester tester,
  ) async {
    const accent = Color(0xFFFF2E88);
    late BuildContext ctx;
    await pumpBare(
      tester,
      Builder(
        builder: (BuildContext c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );
    unawaited(
      showNeonTimePicker(
        context: ctx,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
        accentColor: accent,
      ),
    );
    await tester.pumpAndSettle();
    final BuildContext dialog = tester.element(find.byType(TimePickerDialog));
    expect(TimePickerTheme.of(dialog).dialHandColor, accent);
  });
}
