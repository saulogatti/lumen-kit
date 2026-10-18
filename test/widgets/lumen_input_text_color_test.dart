import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  // App claro com um LumenScope escuro: o texto digitado precisa seguir a
  // paleta do scope, não o ThemeData (antes saía escuro sobre fundo escuro).
  final dark = LumenPalette.defaultDark();

  Widget scoped(Widget child) => LumenScope(palette: dark, child: child);

  testWidgets('LumenTextField usa textPrimary da paleta no texto digitado', (tester) async {
    await pumpBare(tester, scoped(const LumenTextField(label: 'Nome')));

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.style.color, dark.textPrimary);
  });

  testWidgets('LumenSearchBar usa textPrimary da paleta no texto digitado', (tester) async {
    await pumpBare(tester, scoped(LumenSearchBar(onChanged: (_) {})));

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.style.color, dark.textPrimary);
  });

  testWidgets('LumenDropdown usa textPrimary da paleta no valor', (tester) async {
    await pumpBare(
      tester,
      scoped(
        LumenDropdown<String>(
          value: 'cyan',
          items: const <LumenDropdownItem<String>>[LumenDropdownItem(value: 'cyan', label: 'Cyan')],
          onChanged: (_) {},
        ),
      ),
    );

    final button = tester.widget<DropdownButton<String>>(find.byType(DropdownButton<String>));
    expect(button.style?.color, dark.textPrimary);
  });
}
