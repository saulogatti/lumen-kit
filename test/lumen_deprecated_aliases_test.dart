// Os nomes antigos (prefixo neon/accent*) continuam públicos por compatibilidade;
// este arquivo é justamente o que garante que eles ainda apontam para os novos.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/_harness.dart';

void main() {
  test('accentCyan/Magenta/Blue leem primary/secondary/tertiary', () {
    final p = LumenPalette.light();
    expect(p.accentCyan, p.primary);
    expect(p.accentMagenta, p.secondary);
    expect(p.accentBlue, p.tertiary);
  });

  test('copyWith ainda aceita os nomes antigos', () {
    final p = LumenPalette.defaultDark().copyWith(
      accentCyan: const Color(0xFF000001),
      accentMagenta: const Color(0xFF000002),
      accentBlue: const Color(0xFF000003),
    );
    expect(p.primary, const Color(0xFF000001));
    expect(p.secondary, const Color(0xFF000002));
    expect(p.tertiary, const Color(0xFF000003));
    expect(p.accentGradient.colors.first, const Color(0xFF000001));
  });

  testWidgets('neonMenuPositionAt é o mesmo que lumenMenuPositionAt', (tester) async {
    late BuildContext ctx;
    await pumpBare(
      tester,
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );
    const point = Offset(40, 60);
    expect(neonMenuPositionAt(ctx, point), lumenMenuPositionAt(ctx, point));
  });
}
