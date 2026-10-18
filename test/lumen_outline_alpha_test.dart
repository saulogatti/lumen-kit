import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('outlineAlpha mantém o cyan do escuro e o preto fraco do claro', () {
    final dark = LumenPalette.defaultDark().surfaceOutline.outlineAlpha(0.8);
    expect(dark.a, closeTo(0.8, 0.001));

    final light = LumenPalette.light().surfaceOutline.outlineAlpha(0.9);
    expect(light.a, lessThan(0.3));
    expect(light.r, lessThan(0.05));
    expect(light.g, lessThan(0.05));
    expect(light.b, lessThan(0.05));

    final seededDark = LumenPalette.fromSeed(primary: const Color(0xFF00E5FF)).surfaceOutline
        .outlineAlpha(0.6);
    expect(seededDark.a, closeTo(0.6, 0.02));

    final seededLight = LumenPalette.fromSeed(
      primary: const Color(0xFF00E5FF),
      brightness: Brightness.light,
    ).surfaceOutline.outlineAlpha(0.6);
    expect(seededLight.a, lessThan(0.3));
    expect(seededLight.r, lessThan(0.05));
    expect(seededLight.g, lessThan(0.05));
    expect(seededLight.b, lessThan(0.05));
  });

  test('scaleAlpha multiplica o alpha que a cor já tem', () {
    const faint = Color(0x15000000);
    expect(faint.scaleAlpha(0.5).a, closeTo(faint.a * 0.5, 0.001));

    const muted = Color(0x80EAF6FF);
    expect(muted.scaleAlpha(0.6).a, closeTo(muted.a * 0.6, 0.001));
    expect(muted.withValues(alpha: 0.6).a, closeTo(0.6, 0.001));

    const opaque = Color(0xFF00E5FF);
    expect(opaque.scaleAlpha(0.4).a, closeTo(0.4, 0.001));
    expect(opaque.scaleAlpha(3).a, 1);
  });
}
