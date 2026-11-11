import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

/// Palette and style as the active theme, without a registered `ThemeData`.
Widget _scoped(Widget child, {LumenPalette? palette, LumenStyle style = LumenStyle.neon}) =>
    LumenScope(palette: palette ?? LumenPalette.defaultDark(), style: style, child: child);

BoxDecoration _decorationOf(WidgetTester tester) {
  final box = tester.widget<Container>(
    find.descendant(of: find.byType(LumenPressable), matching: find.byType(Container)).first,
  );
  return box.decoration! as BoxDecoration;
}

Color _contentColor(WidgetTester tester) =>
    tester.widget<LumenActionContent>(find.byType(LumenActionContent)).color;

void main() {
  group('rótulo em largura estreita (#24)', () {
    for (final busy in <bool>[false, true]) {
      for (final expand in <bool>[false, true]) {
        testWidgets('não estoura com busy: $busy e expand: $expand', (tester) async {
          await pumpBare(
            tester,
            SizedBox(
              width: 160,
              child: LumenButton(
                label: 'Save all pending changes',
                icon: Icons.save_outlined,
                busy: busy,
                expand: expand,
                onPressed: () {},
              ),
            ),
          );

          final label = tester.widget<Text>(find.text('Save all pending changes'));
          expect(label.maxLines, 1);
          expect(label.overflow, TextOverflow.ellipsis);
          expect(tester.getSize(find.byType(LumenButton)).width, lessThanOrEqualTo(160));
        });
      }
    }

    testWidgets('com espaço sobrando, expand centraliza o conteúdo', (tester) async {
      await pumpBare(
        tester,
        SizedBox(
          width: 400,
          child: LumenButton(
            label: 'Save',
            icon: Icons.save_outlined,
            expand: true,
            onPressed: () {},
          ),
        ),
      );

      final button = tester.getRect(find.byType(LumenButton));
      final icon = tester.getRect(find.byIcon(Icons.save_outlined));
      final text = tester.getRect(find.text('Save'));
      final contentCenter = (icon.left + text.right) / 2;
      expect(contentCenter, moreOrLessEquals(button.center.dx, epsilon: 0.5));
    });

    testWidgets('sem limite de largura, o botão fica do tamanho do conteúdo', (tester) async {
      await pumpBare(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LumenButton(label: 'Save changes', icon: Icons.save_outlined, onPressed: () {}),
          ],
        ),
      );

      final label = tester.widget<Text>(find.text('Save changes'));
      final textWidth = tester.getSize(find.text('Save changes')).width;
      expect(textWidth, greaterThan(0));
      expect(label.overflow, TextOverflow.ellipsis);
      expect(tester.getSize(find.byType(LumenButton)).width, greaterThan(textWidth));
    });
  });

  group('tone (#25)', () {
    testWidgets('sem tone, o sólido continua no degradê de destaque', (tester) async {
      final palette = LumenPalette.defaultDark();
      await pumpBare(
        tester,
        _scoped(
          LumenButton(label: 'Run', onPressed: () {}),
          palette: palette,
        ),
      );

      expect(_decorationOf(tester).gradient, palette.accentGradient);
      expect(_contentColor(tester), palette.backgroundDeep);
    });

    for (final style in LumenStyle.presets.entries) {
      for (final brightness in Brightness.values) {
        testWidgets('sólido de perigo no estilo ${style.key}, ${brightness.name}', (tester) async {
          final palette = brightness == Brightness.dark
              ? LumenPalette.defaultDark()
              : LumenPalette.light();
          await pumpBare(
            tester,
            _scoped(
              LumenButton(label: 'Delete', tone: LumenStatusTone.danger, onPressed: () {}),
              palette: palette,
              style: style.value,
            ),
          );

          final gradient = _decorationOf(tester).gradient!;
          expect(gradient.colors.first, palette.danger);
          expect(gradient.colors, isNot(contains(palette.primary)));
          if (!style.value.gradients) {
            expect(gradient.colors.toSet(), <Color>{palette.danger});
          }

          final shadows = _decorationOf(tester).boxShadow;
          if (style.value.shadow == LumenShadowKind.glow) {
            expect(shadows!.single.color.withValues(alpha: 1), palette.danger);
          }

          // Text and icon take the palette tone with the higher contrast.
          final fg = _contentColor(tester);
          expect(fg, anyOf(palette.backgroundDeep, palette.textPrimary));
          expect(_contrast(fg, palette.danger), greaterThanOrEqualTo(4.5));
        });
      }
    }

    testWidgets('LumenButton.danger é o sólido com tom de perigo', (tester) async {
      const button = LumenButton.danger(label: 'Delete', onPressed: null);
      expect(button.variant, LumenButtonVariant.solid);
      expect(button.tone, LumenStatusTone.danger);
    });

    testWidgets('accentColor ainda manda na sombra do sólido com tom', (tester) async {
      const glow = Color(0xFF00FF00);
      await pumpBare(
        tester,
        _scoped(
          LumenButton(
            label: 'Delete',
            tone: LumenStatusTone.danger,
            accentColor: glow,
            onPressed: () {},
          ),
        ),
      );

      expect(_decorationOf(tester).boxShadow!.single.color.withValues(alpha: 1), glow);
    });

    testWidgets('outline e ghost usam a cor do tom no conteúdo', (tester) async {
      final palette = LumenPalette.defaultDark();
      await pumpBare(
        tester,
        _scoped(
          LumenButton.outline(label: 'Delete', tone: LumenStatusTone.danger, onPressed: () {}),
          palette: palette,
        ),
      );
      expect(_contentColor(tester), palette.danger);

      await pumpBare(
        tester,
        _scoped(
          LumenButton.ghost(label: 'Retry', tone: LumenStatusTone.warning, onPressed: () {}),
          palette: palette,
        ),
      );
      expect(_contentColor(tester), palette.warning);

      // An explicit accent wins over the tone.
      await pumpBare(
        tester,
        _scoped(
          LumenButton.outline(
            label: 'Delete',
            tone: LumenStatusTone.danger,
            accentColor: palette.secondary,
            onPressed: () {},
          ),
          palette: palette,
        ),
      );
      expect(_contentColor(tester), palette.secondary);
    });

    testWidgets('tom neutro preenche com cor opaca', (tester) async {
      final palette = LumenPalette.defaultDark();
      await pumpBare(
        tester,
        _scoped(
          LumenButton(label: 'Skip', tone: LumenStatusTone.neutral, onPressed: () {}),
          palette: palette,
        ),
      );

      final gradient = _decorationOf(tester).gradient!;
      expect(gradient.colors.every((c) => c.a == 1), isTrue);
    });

    testWidgets('sólido com tom funciona sem tema registrado e desabilita', (tester) async {
      var taps = 0;
      await pumpBare(tester, LumenButton.danger(label: 'Delete', onPressed: () => taps++));
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(taps, 1);

      await pumpBare(tester, const LumenButton.danger(label: 'Delete', onPressed: null));
      expect(tester.widget<LumenPressable>(find.byType(LumenPressable)).onTap, isNull);
      expect(_decorationOf(tester).boxShadow, isNull);

      await pumpBare(tester, LumenButton.danger(label: 'Delete', busy: true, onPressed: () {}));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
