import 'dart:math' as math;
import 'dart:ui' show ColorSpace;

import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:material_ui/material_ui.dart';

/// Picks the foreground with the strongest minimum contrast across the fills.
/// Prefers palette tones when they reach 4.5:1. Without a palette, compares
/// black and white. Translucent fills are evaluated over [backdrop].
Color lumenContrastingForeground(
  List<Color> fills, {
  required Color backdrop,
  LumenPalette? palette,
}) {
  final surface = backdrop.withValues(colorSpace: ColorSpace.sRGB);
  final backgrounds = <Color>[
    for (final fill in fills)
      Color.alphaBlend(fill.withValues(colorSpace: ColorSpace.sRGB), surface),
  ];
  double score(Color foreground) {
    final ink = foreground.withValues(colorSpace: ColorSpace.sRGB);
    var minimum = double.infinity;
    for (final background in backgrounds) {
      final bg = background.computeLuminance();
      final fg = Color.alphaBlend(ink, background).computeLuminance();
      minimum = math.min(minimum, (math.max(bg, fg) + 0.05) / (math.min(bg, fg) + 0.05));
    }
    return minimum;
  }

  var best = Colors.black;
  var bestScore = 0.0;
  if (palette != null) {
    final deep = score(palette.backgroundDeep);
    final text = score(palette.textPrimary);
    best = deep >= text ? palette.backgroundDeep : palette.textPrimary;
    bestScore = math.max(deep, text);
    if (bestScore >= 4.5) return best;
  }
  for (final neutral in <Color>[Colors.black, Colors.white]) {
    final neutralScore = score(neutral);
    if (neutralScore > bestScore) {
      best = neutral;
      bestScore = neutralScore;
    }
  }
  return best;
}
