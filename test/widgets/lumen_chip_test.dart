import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

const List<LumenChipItem<String>> _sizes = <LumenChipItem<String>>[
  LumenChipItem<String>(value: 'p', label: 'P'),
  LumenChipItem<String>(value: 'm', label: 'M'),
  LumenChipItem<String>(value: 'g', label: 'G', enabled: false),
];

void main() {
  testWidgets('LumenChoiceChips marca um valor por vez', (
    WidgetTester tester,
  ) async {
    String? value = 'p';
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              LumenChoiceChips<String>(
                items: _sizes,
                value: value,
                onChanged: (String? v) => setState(() => value = v),
              ),
        ),
      ),
    );

    await tester.tap(find.text('M'));
    await tester.pump();
    expect(value, 'm');

    // Tapping the selected chip does not deselect it without allowDeselect.
    await tester.tap(find.text('M'));
    await tester.pump();
    expect(value, 'm');

    // Disabled state does not change anything.
    await tester.tap(find.text('G'));
    await tester.pump();
    expect(value, 'm');
  });

  testWidgets('allowDeselect manda null ao tocar no marcado', (
    WidgetTester tester,
  ) async {
    final calls = <String?>[];
    await pumpBare(
      tester,
      LumenChoiceChips<String>(
        items: _sizes,
        value: 'p',
        allowDeselect: true,
        onChanged: calls.add,
      ),
    );
    await tester.tap(find.text('P'));
    expect(calls, <String?>[null]);
  });

  testWidgets('LumenFilterChips alterna vários valores e mostra o check', (
    WidgetTester tester,
  ) async {
    var values = <String>{'p'};
    final original = values;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              LumenFilterChips<String>(
                items: _sizes,
                values: values,
                onChanged: (Set<String> v) => setState(() => values = v),
              ),
        ),
      ),
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('M'));
    await tester.pump();
    expect(values, <String>{'p', 'm'});
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));

    await tester.tap(find.text('P'));
    await tester.pump();
    expect(values, <String>{'m'});
    expect(original, <String>{'p'}, reason: 'não muta o set recebido');
  });

  testWidgets('LumenChip anuncia seleção e usa o accent quando marcado', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      LumenChip(label: 'Promoção', selected: true, onSelected: (_) {}),
    );
    expect(
      tester.getSemantics(find.byType(LumenChip)),
      isSemantics(
        label: 'Promoção',
        isSelected: true,
        isButton: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.widget<Text>(find.text('Promoção')).style?.color,
      LumenPalette.light().primary,
    );
    handle.dispose();
  });
}
