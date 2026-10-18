import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('LumenPalette', () {
    test('defaultDark mantém exatamente os tokens de AppColors', () {
      final p = LumenPalette.defaultDark();
      expect(p.primary, AppColors.accentCyan);
      expect(p.secondary, AppColors.accentMagenta);
      expect(p.tertiary, AppColors.accentBlue);
      expect(p.accentGradient, AppColors.accentGradient);
      expect(p.backgroundGradient, AppColors.backgroundGradient);
    });

    test('fromSeed deriva accents e gradientes da cor informada', () {
      const green = Color(0xFF39FF14);
      final p = LumenPalette.fromSeed(primary: green);
      expect(p.primary, green);
      expect(p.secondary, isNot(green));
      expect(p.accentGradient.colors, <Color>[p.primary, p.tertiary, p.secondary]);
      expect(p.backgroundDeep.computeLuminance(), lessThan(0.01));

      final light = LumenPalette.fromSeed(primary: green, brightness: Brightness.light);
      expect(light.backgroundDeep.computeLuminance(), greaterThan(0.8));
      expect(light.textPrimary.computeLuminance(), lessThan(0.05));
    });

    test('copyWith recalcula o gradiente quando um accent muda', () {
      final p = LumenPalette.defaultDark().copyWith(primary: const Color(0xFFFF8A00));
      expect(p.accentGradient.colors.first, const Color(0xFFFF8A00));
      expect(p.backgroundGradient, AppColors.backgroundGradient);
    });

    // Os aliases depreciados (accentCyan…) ficam em lumen_deprecated_aliases_test.dart.

    test('copyWith sem trocar accent nem fundo preserva gradientes customizados', () {
      const accent = LinearGradient(colors: <Color>[Color(0xFF000001), Color(0xFF000002)]);
      const background = LinearGradient(colors: <Color>[Color(0xFF000003), Color(0xFF000004)]);
      final p = LumenPalette.defaultDark()
          .copyWith(accentGradient: accent, backgroundGradient: background)
          .copyWith(surface: const Color(0xFF101010));
      expect(p.surface, const Color(0xFF101010));
      expect(p.primary, AppColors.accentCyan);
      expect(p.accentGradient, accent);
      expect(p.backgroundGradient, background);
    });

    test('light() usa contorno translúcido e fundo claro', () {
      final p = LumenPalette.light();
      expect(p.surfaceOutline.a, lessThan(0.2));
      expect(p.backgroundGradient.colors.first.computeLuminance(), greaterThan(0.8));
    });
  });

  testWidgets('widgets seguem a paleta do tema, não AppColors', (tester) async {
    const orange = Color(0xFFFF8A00);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.fromSeed(primary: orange),
        home: const Scaffold(
          body: LumenAnimatedGridBackground(
            child: Column(
              children: <Widget>[
                LumenStatusChip(label: 'info', tone: LumenStatusTone.info),
                LumenCard(child: Text('card')),
                LumenTextField(label: 'nome', icon: Icons.person, onChanged: _ignore),
              ],
            ),
          ),
        ),
      ),
    );

    final chipLabel = tester.widget<Text>(find.text('info'));
    expect(chipLabel.style?.color, orange);
    final fieldIcon = tester.widget<Icon>(find.byIcon(Icons.person));
    expect(fieldIcon.color, orange);
  });

  group('resolução do tema', () {
    setUp(_seen.clear);

    testWidgets('sem nada registrado, tema escuro cai na paleta escura padrão', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const _Probe(),
        ),
      );
      expect(_seen.last, LumenPalette.defaultDark().primary);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: const _Probe(),
        ),
      );
      expect(_seen.last, LumenPalette.light().primary);
    });

    testWidgets('LumenScope só reconstrói dependentes quando paleta ou estilo mudam', (
      tester,
    ) async {
      final teal = LumenPalette.fromSeed(primary: const Color(0xFF009688));
      final pink = LumenPalette.fromSeed(primary: const Color(0xFFE91E63));
      Widget scoped(LumenPalette p, [LumenStyle s = LumenStyle.neon]) => MaterialApp(
        home: LumenScope(palette: p, style: s, child: const _Probe()),
      );

      await tester.pumpWidget(scoped(teal));
      expect(_seen, <Color>[teal.primary]);

      await tester.pumpWidget(scoped(teal));
      expect(_seen, hasLength(1), reason: 'mesma paleta e estilo: não notifica');

      await tester.pumpWidget(scoped(pink));
      expect(_seen.last, pink.primary);

      await tester.pumpWidget(scoped(pink, LumenStyle.flat));
      expect(_seen, hasLength(3));
    });

    test('LumenThemeExt.copyWith troca só o que foi pedido', () {
      final base = LumenThemeExt(palette: LumenPalette.defaultDark());
      final flat = base.copyWith(style: LumenStyle.flat);
      expect(flat.palette, same(base.palette));
      expect(flat.style, LumenStyle.flat);

      final light = base.copyWith(palette: LumenPalette.light());
      expect(light.style, same(base.style));
      expect(light.palette.primary, LumenPalette.light().primary);
    });

    test('AppTheme.dark e AppTheme.light registram a paleta padrão', () {
      final dark = AppTheme.dark;
      expect(dark.brightness, Brightness.dark);
      expect(dark.extension<LumenThemeExt>()!.palette.primary, LumenPalette.defaultDark().primary);

      final light = AppTheme.light;
      expect(light.brightness, Brightness.light);
      expect(light.extension<LumenThemeExt>()!.palette.primary, LumenPalette.light().primary);
    });
  });
}

void _ignore(String _) {}

/// Cores que [_Probe] leu a cada build.
final List<Color> _seen = <Color>[];

/// Lê a paleta do contexto; `const` para só reconstruir por dependência.
class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) {
    _seen.add(LumenThemeExt.of(context).palette.primary);
    return const SizedBox();
  }
}
