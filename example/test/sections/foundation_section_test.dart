import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/foundation_section.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpSection(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: const FoundationSection(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'selection changes on tap and disabled pressable cannot change it',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester);
      final selected = find.byKey(const ValueKey('foundation-select'));
      final disabled = find.byKey(const ValueKey('foundation-disabled'));

      expect(tester.widget<LumenPressable>(selected).selected, isFalse);
      await tester.tap(selected);
      await tester.pump();
      expect(tester.widget<LumenPressable>(selected).selected, isTrue);
      expect(tester.widget<LumenPressable>(disabled).isEnabled, isFalse);
      expect(
        tester.getSemantics(selected),
        isSemantics(
          label: 'Select item',
          isSelected: true,
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(disabled),
        isSemantics(label: 'Disabled item', isButton: true),
      );

      await tester.tap(disabled);
      await tester.pump();
      expect(tester.widget<LumenPressable>(selected).selected, isTrue);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('pressable can be focused and activated from the keyboard', (
    tester,
  ) async {
    await _pumpSection(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(find.textContaining('Keyboard focus active'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(
      tester
          .widget<LumenPressable>(
            find.byKey(const ValueKey('foundation-select')),
          )
          .selected,
      isTrue,
    );
  });

  testWidgets(
    'custom composition responds and labeled checkbox keeps its state',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpSection(tester);
      final checkbox = find.byKey(const ValueKey('foundation-notifications'));
      expect(
        tester.getSemantics(checkbox),
        isSemantics(
          label: 'Email notifications',
          hasCheckedState: true,
          isChecked: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.text('Email notifications'));
      await tester.pump();
      expect(
        tester.getSemantics(checkbox),
        isSemantics(
          label: 'Email notifications',
          hasCheckedState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      final custom = find.byKey(const ValueKey('foundation-custom-action'));
      await tester.ensureVisible(custom);
      await tester.tap(custom);
      await tester.pump();
      expect(find.text('Custom actions: 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );
}
