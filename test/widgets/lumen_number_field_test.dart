import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Widget _sized(Widget child) => SizedBox(width: 320, child: child);

final Finder _input = find.descendant(
  of: find.byType(LumenNumberField),
  matching: find.byType(TextField),
);

String _text(WidgetTester tester) => tester.widget<TextField>(_input).controller!.text;

TextInputFormatter _formatter(WidgetTester tester) =>
    tester.widget<TextField>(_input).inputFormatters!.single;

/// Aplica o formatador do campo a uma edição de [before] para [after], com o
/// cursor nas posições marcadas por `|`.
TextEditingValue _edit(WidgetTester tester, String before, String after) {
  TextEditingValue value(String marked) {
    final at = marked.indexOf('|');
    return TextEditingValue(
      text: marked.replaceFirst('|', ''),
      selection: TextSelection.collapsed(offset: at),
    );
  }

  return _formatter(tester).formatEditUpdate(value(before), value(after));
}

/// Texto com `|` na posição do cursor.
String _marked(TextEditingValue value) =>
    value.text.replaceRange(value.selection.baseOffset, value.selection.baseOffset, '|');

void main() {
  testWidgets('LumenNumberField funciona sem tema e mostra o valor arredondado', (tester) async {
    await pumpBare(
      tester,
      _sized(
        LumenNumberField(
          label: 'Price',
          value: 12.5,
          decimals: 2,
          prefixText: r'$ ',
          suffixText: 'each',
          hint: '0.00',
          helperText: 'Tax included',
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Tax included'), findsOneWidget);
    expect(_text(tester), '12.5');

    final field = tester.widget<TextField>(_input);
    expect(field.keyboardType, const TextInputType.numberWithOptions(signed: true, decimal: true));
    expect(field.decoration!.prefixText, r'$ ');
    expect(field.decoration!.suffixText, 'each');

    await pumpBare(
      tester,
      _sized(
        LumenNumberField(
          label: 'Price',
          value: 12.3456,
          decimals: 2,
          padDecimals: true,
          onChanged: (_) {},
        ),
      ),
    );
    expect(_text(tester), '12.35');
  });

  testWidgets('LumenNumberField sem casas decimais usa teclado de inteiros', (tester) async {
    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Stock', value: null, min: 0, onChanged: (_) {})),
    );
    expect(_text(tester), '');
    final field = tester.widget<TextField>(_input);
    expect(field.keyboardType, TextInputType.number);
  });

  testWidgets('LumenNumberField filtra a digitação e avisa só quando o número muda', (
    tester,
  ) async {
    final changes = <double?>[];
    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Quantity', value: null, onChanged: changes.add)),
    );

    await tester.enterText(find.byType(TextField), '12a3');
    expect(_text(tester), '123');
    await tester.enterText(find.byType(TextField), '123.5');
    expect(_text(tester), '1235');
    await tester.enterText(find.byType(TextField), '007');
    expect(_text(tester), '7');
    await tester.enterText(find.byType(TextField), '7');
    await tester.enterText(find.byType(TextField), '');
    expect(changes, <double?>[123, 1235, 7, null]);
  });

  testWidgets('LumenNumberField limita as casas decimais e recusa segundo separador', (
    tester,
  ) async {
    final changes = <double?>[];
    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Stock', value: null, decimals: 3, onChanged: changes.add)),
    );

    await tester.enterText(find.byType(TextField), '1.23456');
    expect(_text(tester), '1.234');
    await tester.enterText(find.byType(TextField), '.5');
    expect(_text(tester), '0.5');
    await tester.enterText(find.byType(TextField), '1.');
    expect(_text(tester), '1.');
    expect(changes, <double?>[1.234, 0.5, 1]);

    expect(_marked(_edit(tester, '1.5|', '1.5.|')), '1.5|');
    expect(_marked(_edit(tester, '1.|5', '1.9|5')), '1.9|5');
    expect(_marked(_edit(tester, '1.234|', '1.2345|')), '1.234|');
  });

  testWidgets('LumenNumberField aceita sinal só com min negativo ou ausente', (tester) async {
    final changes = <double?>[];
    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Balance', value: null, onChanged: changes.add)),
    );
    await tester.enterText(find.byType(TextField), '-');
    expect(_text(tester), '-');
    await tester.enterText(find.byType(TextField), '-0');
    await tester.enterText(find.byType(TextField), '-42');
    expect(_text(tester), '-42');
    expect(_marked(_edit(tester, '42|', '42-|')), '42|');
    expect(changes, <double?>[0, -42]);
    expect(changes[0]!.isNegative, isFalse);

    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Balance', value: null, min: 0, onChanged: (_) {})),
    );
    await tester.enterText(find.byType(TextField), '-7');
    expect(_text(tester), '7');
  });

  testWidgets('LumenNumberField agrupa milhares com separadores configuráveis', (tester) async {
    final changes = <double?>[];
    await pumpBare(
      tester,
      _sized(
        LumenNumberField(
          label: 'Preço',
          value: -1234567.5,
          decimals: 2,
          decimalSeparator: ',',
          groupSeparator: '.',
          onChanged: changes.add,
        ),
      ),
    );
    expect(_text(tester), '-1.234.567,5');

    await tester.enterText(find.byType(TextField), '1.234.567,891');
    expect(_text(tester), '1.234.567,89');
    expect(changes, <double?>[1234567.89]);

    // O cursor fica junto do dígito digitado, antes do separador de grupo.
    expect(_marked(_edit(tester, '123|', '1234|')), '1.234|');
    expect(_marked(_edit(tester, '1|.234', '15|.234')), '15|.234');
    expect(_marked(_edit(tester, '-1|.234', '-12|.234')), '-12|.234');
    expect(_marked(_edit(tester, '|1.234', 'x|1.234')), '|1.234');
    expect(_marked(_edit(tester, '1.234,5|', '1.234,56|')), '1.234,56|');
  });

  testWidgets('LumenNumberField troca . ou , digitado pelo separador decimal', (tester) async {
    await pumpBare(
      tester,
      _sized(
        LumenNumberField(
          label: 'Preço',
          value: null,
          decimals: 2,
          decimalSeparator: ',',
          groupSeparator: '.',
          onChanged: (_) {},
        ),
      ),
    );
    expect(_marked(_edit(tester, '1.234|', '1.234.|')), '1.234,|');
    expect(_marked(_edit(tester, '12|', '12,|')), '12,|');
    expect(_marked(_edit(tester, '|', '.|')), '0,|');
    // Colado (mais de um caractere), o ponto é separador de grupo.
    expect(_marked(_edit(tester, '|', '12.5|')), '125|');

    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Rate', value: null, decimals: 1, onChanged: (_) {})),
    );
    expect(_marked(_edit(tester, '12|', '12,|')), '12.|');
  });

  testWidgets('LumenNumberField apaga o dígito ao lado do separador de grupo', (tester) async {
    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Stock', value: null, groupSeparator: ',', onChanged: (_) {})),
    );
    // Backspace logo depois da vírgula apaga o dígito antes dela.
    expect(_marked(_edit(tester, '1,|234', '1|234')), '|234');
    // Delete logo antes da vírgula apaga o dígito depois dela.
    expect(_marked(_edit(tester, '1|,234', '1|234')), '1|34');
    // Apagar um dígito comum só reagrupa.
    expect(_marked(_edit(tester, '1,234|', '1,23|')), '123|');
  });

  testWidgets('LumenNumberField mantém a seleção e recusa número grande demais', (tester) async {
    await pumpBare(
      tester,
      _sized(LumenNumberField(label: 'Stock', value: null, groupSeparator: ',', onChanged: (_) {})),
    );
    final formatter = _formatter(tester);
    final selected = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '12345',
        selection: TextSelection(baseOffset: 1, extentOffset: 4),
      ),
    );
    expect(selected.text, '12,345');
    expect(selected.selection, const TextSelection(baseOffset: 1, extentOffset: 5));

    final noSelection = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1234'),
    );
    expect(noSelection.text, '1,234');
    expect(noSelection.selection, const TextSelection.collapsed(offset: 5));

    const old = TextEditingValue(text: '1');
    expect(formatter.formatEditUpdate(old, const TextEditingValue(text: '1234567890123456')), old);
  });

  testWidgets('LumenNumberField aplica min e max ao perder o foco e ao confirmar', (tester) async {
    final changes = <double?>[];
    final submitted = <double?>[];
    double? value = 5;
    await pumpBare(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _sized(
              LumenNumberField(
                label: 'Discount',
                value: value,
                decimals: 2,
                min: 1,
                max: 100,
                padDecimals: true,
                suffixText: '%',
                textInputAction: TextInputAction.done,
                onSubmitted: submitted.add,
                onChanged: (v) {
                  changes.add(v);
                  setState(() => value = v);
                },
              ),
            ),
            const SizedBox(width: 320, child: TextField(key: Key('other'))),
          ],
        ),
      ),
    );
    expect(_text(tester), '5.00');

    // Durante a digitação o valor passa do limite sem ser corrigido.
    await tester.enterText(find.byType(LumenNumberField), '150');
    expect(_text(tester), '150');
    expect(changes, <double?>[150]);

    await tester.tap(find.byKey(const Key('other')));
    await tester.pump();
    expect(_text(tester), '100.00');
    expect(changes, <double?>[150, 100]);
    expect(value, 100);

    await tester.enterText(find.byType(LumenNumberField), '0.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(_text(tester), '1.00');
    expect(submitted, <double?>[1]);
    expect(value, 1);

    // Campo vazio continua null, mesmo com min.
    await tester.enterText(find.byType(LumenNumberField), '');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(_text(tester), '');
    expect(submitted, <double?>[1, null]);

    // Dentro dos limites, só completa as casas.
    await tester.enterText(find.byType(LumenNumberField), '42.5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(_text(tester), '42.50');
    expect(submitted.last, 42.5);
  });

  testWidgets('LumenNumberField limita ao confirmar mesmo sem onSubmitted e com foco', (
    tester,
  ) async {
    final changes = <double?>[];
    await pumpBare(
      tester,
      _sized(
        LumenNumberField(
          label: 'Quantity',
          value: null,
          max: 10,
          textInputAction: TextInputAction.continueAction,
          onChanged: changes.add,
        ),
      ),
    );
    await tester.enterText(_input, '50');
    await tester.testTextInput.receiveAction(TextInputAction.continueAction);
    await tester.pump();

    // A ação mantém o foco, então não há blur: quem limita é o submit.
    expect(tester.widget<TextField>(_input).focusNode!.hasFocus, isTrue);
    expect(_text(tester), '10');
    expect(changes, <double?>[50, 10]);
  });

  testWidgets('LumenNumberField arredonda min e max para dentro do intervalo', (tester) async {
    Future<String> commit(String typed, {double? min, double? max}) async {
      final changes = <double?>[];
      await tester.pumpWidget(const SizedBox());
      await pumpBare(
        tester,
        _sized(
          LumenNumberField(
            label: 'Price',
            value: null,
            decimals: 2,
            min: min,
            max: max,
            textInputAction: TextInputAction.continueAction,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.enterText(_input, typed);
      await tester.testTextInput.receiveAction(TextInputAction.continueAction);
      await tester.pump();
      // O valor informado é o mesmo do texto, já arredondado.
      expect(changes.last, double.tryParse(_text(tester)));
      return _text(tester);
    }

    // O max desce e o min sobe para a casa permitida.
    expect(await commit('2', max: 1.236), '1.23');
    expect(await commit('1', min: 1.234), '1.24');
    expect(await commit('-5', min: -1.236), '-1.23');
    // Limites que já cabem nas casas não mudam (0.29 e 1.1 não são exatos em binário).
    expect(await commit('0.1', min: 0.29), '0.29');
    expect(await commit('5', max: 1.1), '1.1');
    // Sem valor representável entre min e max, vale o min arredondado.
    expect(await commit('5', min: 1.231, max: 1.239), '1.24');
    expect(await commit('0', min: 1.231, max: 1.239), '1.24');
  });

  testWidgets('LumenNumberField sem onChanged fica desabilitado e esmaecido', (tester) async {
    await pumpBare(
      tester,
      _sized(const LumenNumberField(label: 'Locked', value: 3, onChanged: null)),
    );
    expect(tester.widget<TextField>(_input).enabled, isFalse);
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.byType(TextField), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, kLumenDisabledOpacity);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tester.testTextInput.hasAnyClients, isFalse);
  });

  testWidgets('LumenNumberField segue o valor externo sem atropelar a digitação', (tester) async {
    double? value = 2;
    var decimalSeparator = '.';
    late StateSetter rebuild;
    await pumpBare(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return _sized(
            LumenNumberField(
              label: 'Price',
              value: value,
              decimals: 2,
              decimalSeparator: decimalSeparator,
              onChanged: (v) => setState(() => value = v),
            ),
          );
        },
      ),
    );

    // O valor repassado é o mesmo do texto: "3." continua na tela.
    await tester.enterText(find.byType(TextField), '3.');
    await tester.pump();
    expect(value, 3);
    expect(_text(tester), '3.');

    // Outro valor vindo de fora substitui o texto.
    rebuild(() => value = 9.99);
    await tester.pump();
    expect(_text(tester), '9.99');

    rebuild(() => value = null);
    await tester.pump();
    expect(_text(tester), '');

    rebuild(() => value = double.nan);
    await tester.pump();
    expect(_text(tester), '');

    // Trocar o separador regrava o texto no formato novo.
    rebuild(() => value = 1.5);
    await tester.pump();
    rebuild(() => decimalSeparator = ',');
    await tester.pump();
    expect(_text(tester), '1,5');

    // Rebuild sem mudança não mexe no texto.
    await tester.enterText(find.byType(TextField), '1,');
    rebuild(() {});
    await tester.pump();
    expect(_text(tester), '1,');
  });

  testWidgets('LumenNumberField troca o FocusNode externo sem perder o blur', (tester) async {
    final first = FocusNode();
    final second = FocusNode();
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    final changes = <double?>[];
    Widget field(FocusNode? node) => _sized(
      LumenNumberField(label: 'Qty', value: null, max: 10, focusNode: node, onChanged: changes.add),
    );

    await pumpBare(tester, field(first));
    await pumpBare(tester, field(null));
    await pumpBare(tester, field(second));
    second.requestFocus();
    await tester.pump();
    await tester.enterText(find.byType(TextField), '50');
    second.unfocus();
    await tester.pump();
    expect(_text(tester), '10');
    expect(changes, <double?>[50, 10]);
  });

  testWidgets('LumenNumberField valida o número num Form', (tester) async {
    final form = GlobalKey<FormState>();
    await pumpBare(
      tester,
      Form(
        key: form,
        child: _sized(
          LumenNumberField(
            label: 'Price',
            value: null,
            errorText: 'Server error',
            validator: (v) => v == null ? 'Required' : null,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(find.text('Server error'), findsOneWidget);
    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '4');
    expect(form.currentState!.validate(), isTrue);
  });

  testWidgets('LumenNumberField expõe rótulo e valor à semântica', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpBare(
      tester,
      _sized(
        LumenNumberField(
          label: 'Stock',
          value: 1234,
          groupSeparator: ',',
          accentColor: Colors.pink,
          textAlign: TextAlign.end,
          autofocus: true,
          onChanged: (_) {},
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.getSemantics(find.byType(TextField)),
      isSemantics(
        label: 'Stock',
        value: '1,234',
        isTextField: true,
        isEnabled: true,
        isFocused: true,
      ),
    );
    handle.dispose();
  });
}
