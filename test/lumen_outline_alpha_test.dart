import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('outlineAlpha mantém o cyan do escuro e o preto fraco do claro', () {
    final Color dark = LumenPalette.defaultDark().surfaceOutline.outlineAlpha(
      0.8,
    );
    expect(dark.a, closeTo(0.8, 0.001));

    final Color light = LumenPalette.light().surfaceOutline.outlineAlpha(0.9);
    expect(light.a, lessThan(0.3));
    expect(light.r, lessThan(0.05));
    expect(light.g, lessThan(0.05));
    expect(light.b, lessThan(0.05));

    final Color seeded = LumenPalette.fromSeed(
      primary: const Color(0xFF00E5FF),
      brightness: Brightness.light,
    ).surfaceOutline.outlineAlpha(0.6);
    expect(seeded.a, closeTo(0.6, 0.02));
  });
}
