import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

const List<NeonChipItem<String>> _sizes = <NeonChipItem<String>>[
  NeonChipItem<String>(value: 'p', label: 'P'),
  NeonChipItem<String>(value: 'm', label: 'M'),
  NeonChipItem<String>(value: 'g', label: 'G', enabled: false),
];

void main() {
  testWidgets('NeonChoiceChips marca um valor por vez', (
    WidgetTester tester,
  ) async {
    String? value = 'p';
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              NeonChoiceChips<String>(
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

    // Tocar no marcado não desmarca sem allowDeselect.
    await tester.tap(find.text('M'));
    await tester.pump();
    expect(value, 'm');

    // Desabilitado não muda nada.
    await tester.tap(find.text('G'));
    await tester.pump();
    expect(value, 'm');
  });

  testWidgets('allowDeselect manda null ao tocar no marcado', (
    WidgetTester tester,
  ) async {
    final List<String?> calls = <String?>[];
    await pumpBare(
      tester,
      NeonChoiceChips<String>(
        items: _sizes,
        value: 'p',
        allowDeselect: true,
        onChanged: calls.add,
      ),
    );
    await tester.tap(find.text('P'));
    expect(calls, <String?>[null]);
  });

  testWidgets('NeonFilterChips alterna vários valores e mostra o check', (
    WidgetTester tester,
  ) async {
    Set<String> values = <String>{'p'};
    final Set<String> original = values;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) =>
              NeonFilterChips<String>(
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

  testWidgets('NeonChip anuncia seleção e usa o accent quando marcado', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      NeonChip(label: 'Promoção', selected: true, onSelected: (_) {}),
    );
    expect(
      tester.getSemantics(find.byType(NeonChip)),
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
      NeonPalette.light().primary,
    );
    handle.dispose();
  });
}
