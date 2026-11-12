import 'package:lumen_kit/src/theme/app_colors.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Color tokens for a Lumen theme.
///
/// Allows you to create variants (e.g. white, with other accents) without
/// changing the default tokens of [AppColors].
/// To derive a palette instead of setting each token, use
/// [LumenPalette.fromSeed] or a [LumenPreset].
@immutable
class LumenPalette {
  /// Deeper tone of the application background.
  final Color backgroundDeep;

  /// Intermediate tone used in background gradients.
  final Color backgroundMid;

  /// Lighter tone of the background, used to soften the gradient.
  final Color backgroundSoft;

  /// Base color for cards, overlays and raised surfaces.
  final Color surface;

  /// Translucent outline used on surface edges.
  final Color surfaceOutline;

  /// Subtle highlighting applied within translucent surfaces.
  final Color surfaceHighlight;

  /// Primary accent used on borders, icons, and active states.
  final Color primary;

  /// Secondary accent used in glows and gradient compositions.
  final Color secondary;

  /// Intermediate accent that connects [primary] and [secondary] in the
  /// gradients.
  final Color tertiary;

  /// Higher contrast color for titles and main content.
  final Color textPrimary;

  /// Medium contrast color for supporting texts.
  final Color textSecondary;

  /// Lower contrast color for subtitles, hints and auxiliary content.
  final Color textMuted;

  /// Semantic color for success states.
  final Color success;

  /// Semantic color for alert states.
  final Color warning;

  /// Semantic color for error or danger states.
  final Color danger;

  final LinearGradient? _backgroundGradient;

  final LinearGradient? _accentGradient;

  /// Creates a complete palette for the neon theme.
  /// Gradients are optional: when omitted, they are derived from the background
  /// and accents, and monitor any changes made via [copyWith].
  /// [accentCyan], [accentMagenta] and [accentBlue] are old aliases of [primary],
  /// [secondary] and [tertiary], maintained for compatibility only.
  const LumenPalette({
    required this.backgroundDeep,
    required this.backgroundMid,
    required this.backgroundSoft,
    required this.surface,
    required this.surfaceOutline,
    required this.surfaceHighlight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    this._backgroundGradient,
    this._accentGradient,
    @Deprecated('Use primary') Color? accentCyan,
    @Deprecated('Use secondary') Color? accentMagenta,
    @Deprecated('Use tertiary') Color? accentBlue,
  }) : assert(
         (primary ?? accentCyan) != null &&
             (secondary ?? accentMagenta) != null &&
             (tertiary ?? accentBlue) != null,
         'primary, secondary and tertiary are required.',
       ),
       primary = primary ?? accentCyan ?? const Color(0x00000000),
       secondary = secondary ?? accentMagenta ?? const Color(0x00000000),
       tertiary = tertiary ?? accentBlue ?? const Color(0x00000000);

  /// Default palette — same colors displayed in [AppColors].
  factory LumenPalette.defaultDark() => const LumenPalette(
    backgroundDeep: AppColors.backgroundDeep,
    backgroundMid: AppColors.backgroundMid,
    backgroundSoft: AppColors.backgroundSoft,
    surface: AppColors.surface,
    surfaceOutline: AppColors.surfaceOutline,
    surfaceHighlight: AppColors.surfaceHighlight,
    primary: AppColors.accentCyan,
    secondary: AppColors.accentMagenta,
    tertiary: AppColors.accentBlue,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    backgroundGradient: AppColors.backgroundGradient,
    accentGradient: AppColors.accentGradient,
  );

  /// Generates a palette from [primary] and optional [secondary] and [tertiary].
  ///
  /// When omitted, [secondary] uses a hue 150 degrees from [primary], and
  /// [tertiary] blends the two along the shorter hue arc. Background and text
  /// tones use the tertiary hue and the requested [brightness]. Success,
  /// warning, and danger use the kit defaults.
  ///
  /// ```dart
  /// AppTheme.fromPalette(
  ///   LumenPalette.fromSeed(primary: Colors.greenAccent),
  ///   brightness: Brightness.dark,
  /// );
  /// ```
  /// 
  /// [success], [warning] and [danger] are optional parameters that can be used to override the default semantic colors.
  /// If not provided, the default semantic colors will be used.
  /// The default semantic colors are:
  /// - success: AppColors.success
  /// - warning: AppColors.warning
  /// - danger: AppColors.danger
  /// 
  /// when [danger] is provided, it will be used to override the default danger color. If the danger color is within 30 degrees of the primary color and the danger color is less than 50% saturated, it will be made more saturated by 20%.
  factory LumenPalette.fromSeed({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Brightness brightness = Brightness.dark,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    final p = HSLColor.fromColor(primary);
    final s = secondary != null ? HSLColor.fromColor(secondary) : p.withHue((p.hue + 150) % 360);
    final sec = s.toColor();
    final successResult = success ?? AppColors.success;
    final warningResult = warning ?? AppColors.warning;
    final dangerResult = danger ?? AppColors.danger;
    var dangerHSL = HSLColor.fromColor(dangerResult);
    if (danger != null && p.hue - dangerHSL.hue.abs() < 30 && dangerHSL.saturation < 0.5) {
      dangerHSL = dangerHSL.withSaturation(dangerHSL.saturation * 1.2);
    }
    final successHSL = HSLColor.fromColor(successResult);
    final warningHSL = HSLColor.fromColor(warningResult);

    // Halfway along the shorter hue arc: orange +
    // pink produces red rather than cyan.
    final delta = ((s.hue - p.hue + 540) % 360) - 180;
    final ter =
        tertiary ?? HSLColor.lerp(p, s, 0.5)!.withHue((p.hue + delta / 2 + 360) % 360).toColor();

    // Backgrounds and text inherit the intermediate accent hue, like the default
    // (dark blue under cyan + magenta).
    final hue = HSLColor.fromColor(ter).hue;
    Color tone(double saturation, double lightness, [double alpha = 1]) =>
        HSLColor.fromAHSL(alpha, hue, saturation, lightness).toColor();

    final dark = brightness == Brightness.dark;
    return LumenPalette(
      backgroundDeep: dark ? tone(0.5, 0.04) : tone(0.3, 0.96),
      backgroundMid: dark ? tone(0.5, 0.09) : tone(0.3, 1),
      backgroundSoft: dark ? tone(0.5, 0.15) : tone(0.3, 0.98),
      surface: dark ? tone(0.5, 0.15) : tone(0.3, 0.995),
      // Light outlines use faint black, as in LumenPalette.light.
      // A primary at 25% would make outlineAlpha apply 0.6–0.9 and draw an
      // almost opaque border. In dark mode, cyan at 20% remains the token
      // that widgets treat as absolute alpha.
      surfaceOutline: dark ? primary.withValues(alpha: 0.2) : const Color(0x15000000),
      surfaceHighlight: dark ? primary.withValues(alpha: 0.1) : const Color(0x08000000),
      primary: primary,
      secondary: sec,
      tertiary: ter,
      textPrimary: dark ? tone(1, 0.96) : tone(0.3, 0.06),
      textSecondary: dark ? tone(1, 0.96, 0.7) : tone(0.15, 0.27),
      textMuted: dark ? tone(1, 0.96, 0.5) : tone(0.1, 0.52),
      success: successHSL.toColor(),
      warning: warningHSL.toColor(),
      danger: dangerHSL.toColor(),
    );
  }

  /// Clear variant with default accents.
  factory LumenPalette.light() => const LumenPalette(
    backgroundDeep: Color(0xFFF5F5F5),
    backgroundMid: Color(0xFFFFFFFF),
    backgroundSoft: Color(0xFFFAFAFA),
    surface: Color(0xFFFEFEFE),
    surfaceOutline: Color(0x15000000),
    surfaceHighlight: Color(0x08000000),
    primary: AppColors.accentCyan,
    secondary: AppColors.accentMagenta,
    tertiary: AppColors.accentBlue,
    textPrimary: Color(0xFF0D0D0D),
    textSecondary: Color(0xFF424242),
    textMuted: Color(0xFF858585),
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    accentGradient: AppColors.accentGradient,
  );

  /// Old alias of [tertiary].
  @Deprecated('Use tertiary')
  Color get accentBlue => tertiary;

  /// Old alias of [primary].
  @Deprecated('Use primary')
  Color get accentCyan => primary;

  /// Highlight gradient used in CTAs, indicators and active elements.
  LinearGradient get accentGradient =>
      _accentGradient ??
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[primary, tertiary, secondary],
      );

  /// Old alias of [secondary].
  @Deprecated('Use secondary')
  Color get accentMagenta => secondary;

  /// Gradient application background pattern.
  LinearGradient get backgroundGradient =>
      _backgroundGradient ??
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[backgroundDeep, backgroundMid, backgroundSoft],
        stops: const <double>[0, 0.55, 1],
      );

  /// Returns a new palette preserving unspecified tokens.
  ///
  /// Supplying a background tone or accent recalculates its corresponding
  /// gradient unless a replacement gradient is also provided.
  LumenPalette copyWith({
    Color? backgroundDeep,
    Color? backgroundMid,
    Color? backgroundSoft,
    Color? surface,
    Color? surfaceOutline,
    Color? surfaceHighlight,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? danger,
    LinearGradient? backgroundGradient,
    LinearGradient? accentGradient,
    @Deprecated('Use primary') Color? accentCyan,
    @Deprecated('Use secondary') Color? accentMagenta,
    @Deprecated('Use tertiary') Color? accentBlue,
  }) {
    primary ??= accentCyan;
    secondary ??= accentMagenta;
    tertiary ??= accentBlue;
    final backgroundChanged =
        backgroundDeep != null || backgroundMid != null || backgroundSoft != null;
    final accentChanged = primary != null || secondary != null || tertiary != null;
    return LumenPalette(
      backgroundDeep: backgroundDeep ?? this.backgroundDeep,
      backgroundMid: backgroundMid ?? this.backgroundMid,
      backgroundSoft: backgroundSoft ?? this.backgroundSoft,
      surface: surface ?? this.surface,
      surfaceOutline: surfaceOutline ?? this.surfaceOutline,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      tertiary: tertiary ?? this.tertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      backgroundGradient: backgroundGradient ?? (backgroundChanged ? null : _backgroundGradient),
      accentGradient: accentGradient ?? (accentChanged ? null : _accentGradient),
    );
  }

  /// Interpolates two palettes, allowing theme changes to be animated.
  static LumenPalette lerp(LumenPalette a, LumenPalette b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return LumenPalette(
      backgroundDeep: c(a.backgroundDeep, b.backgroundDeep),
      backgroundMid: c(a.backgroundMid, b.backgroundMid),
      backgroundSoft: c(a.backgroundSoft, b.backgroundSoft),
      surface: c(a.surface, b.surface),
      surfaceOutline: c(a.surfaceOutline, b.surfaceOutline),
      surfaceHighlight: c(a.surfaceHighlight, b.surfaceHighlight),
      primary: c(a.primary, b.primary),
      secondary: c(a.secondary, b.secondary),
      tertiary: c(a.tertiary, b.tertiary),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textMuted: c(a.textMuted, b.textMuted),
      success: c(a.success, b.success),
      warning: c(a.warning, b.warning),
      danger: c(a.danger, b.danger),
      backgroundGradient: LinearGradient.lerp(a.backgroundGradient, b.backgroundGradient, t),
      accentGradient: LinearGradient.lerp(a.accentGradient, b.accentGradient, t),
    );
  }
}

/// Ready-made palettes.
///
/// Each preset generates a light or dark [LumenPalette].
enum LumenPreset {
  /// Cyan + magenta original from the kit.
  neon(Color(0xFF00E5FF), Color(0xFFB14BFF)),

  /// Terminal green with a touch of cyan.
  matrix(Color(0xFF39FF14), Color(0xFF00FFC6)),

  /// Orange and pink of an 1980s sunset.
  synthwave(Color(0xFFFF8A00), Color(0xFFFF2E88)),

  /// Violet and electric blue.
  ultraviolet(Color(0xFF8C5BFF), Color(0xFF2E9BFF)),

  /// Red and amber.
  ember(Color(0xFFFF3B3B), Color(0xFFFFB020));

  /// Preset's primary accent.
  final Color primary;

  /// Secondary accent of the preset.
  final Color secondary;

  LumenPreset(this.primary, this.secondary);

  /// Generates the preset palette.
  ///
  /// [LumenPreset.neon] returns exactly [LumenPalette.defaultDark] /
  /// [LumenPalette.light].
  LumenPalette palette({Brightness brightness = Brightness.dark}) {
    if (this == LumenPreset.neon) {
      return brightness == Brightness.dark ? LumenPalette.defaultDark() : LumenPalette.light();
    }
    return LumenPalette.fromSeed(primary: primary, secondary: secondary, brightness: brightness);
  }
}

/// Overrides the Lumen palette and style for a widget subtree.
///
/// The nearest scope takes priority over the theme extension. A route or
/// overlay inserted above the scope needs to carry the override explicitly.
///
/// ```dart
/// LumenScope(
///   palette: LumenPalette.fromSeed(primary: Colors.teal),
///   style: LumenStyle.flat,
///   child: LumenButton(label: 'Save', onPressed: save),
/// )
/// ```
class LumenScope extends InheritedWidget {
  /// Palette and style provided to the subtree.
  final LumenThemeExt data;

  /// Applies [palette] and [style] to [child].
  ///
  /// The default [style] is [LumenStyle.neon].
  LumenScope({
    required LumenPalette palette,
    required super.child,
    LumenStyle style = LumenStyle.neon,
    super.key,
  }) : data = LumenThemeExt(palette: palette, style: style);

  @override
  bool updateShouldNotify(LumenScope oldWidget) =>
      oldWidget.data.palette != data.palette || oldWidget.data.style != data.style;
}

/// Stores the Lumen palette and style in [ThemeData].
///
/// Use [of] to resolve local scopes and defaults as well.
@immutable
class LumenThemeExt extends ThemeExtension<LumenThemeExt> {
  static final LumenThemeExt _fallbackDark = LumenThemeExt(palette: LumenPalette.defaultDark());

  static final LumenThemeExt _fallbackLight = LumenThemeExt(palette: LumenPalette.light());

  /// Palette available for widgets that read the current [ThemeData].
  final LumenPalette palette;

  /// Effects style (shadow, border, background…) used by widgets.
  final LumenStyle style;

  /// Creates a theme extension that carries [palette] and [style].
  const LumenThemeExt({required this.palette, this.style = LumenStyle.neon});

  @override
  LumenThemeExt copyWith({LumenPalette? palette, LumenStyle? style}) =>
      LumenThemeExt(palette: palette ?? this.palette, style: style ?? this.style);

  @override
  LumenThemeExt lerp(ThemeExtension<LumenThemeExt>? other, double t) {
    if (other is! LumenThemeExt) {
      return this;
    }
    return LumenThemeExt(
      palette: LumenPalette.lerp(palette, other.palette, t),
      style: t < 0.5 ? style : other.style,
    );
  }

  /// Resolves the active Lumen palette and style for [context].
  ///
  /// Uses the nearest [LumenScope] or the extension registered in [ThemeData].
  /// Otherwise, uses [LumenPalette.defaultDark] or [LumenPalette.light] based
  /// on the theme brightness, paired with [LumenStyle.neon].
  static LumenThemeExt of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LumenScope>();
    if (scope != null) {
      return scope.data;
    }
    final theme = Theme.of(context);
    return theme.extension<LumenThemeExt>() ??
        (theme.brightness == Brightness.dark ? _fallbackDark : _fallbackLight);
  }
}

/// Adjusts opacity for Lumen palette colors.
///
/// Use [scaleAlpha] to multiply the current alpha and [outlineAlpha] to
/// preserve faint neutral outlines.
extension LumenOutlineColor on Color {
  /// Applies [alpha] while preserving faint neutral outlines.
  ///
  /// For saturation below `0.15` and existing alpha below `0.35`, multiplies
  /// the existing alpha by `alpha / 0.2` and caps it at `0.28`. Other colors
  /// use the requested alpha directly.
  Color outlineAlpha(double alpha) {
    final faintNeutral = HSLColor.fromColor(this).saturation < 0.15 && a < 0.35;
    if (!faintNeutral) {
      return withValues(alpha: alpha);
    }
    // Cap below 1: in light mode, `0.9` must not become black at 36% opacity.
    return withValues(alpha: (a * (alpha / 0.2)).clamp(0.0, 0.28));
  }

  /// Multiplies the current alpha by [factor], limited to `0`–`1`.
  /// Use on tokens that are already translucent (`textMuted`, `textSecondary`,
  /// `surfaceHighlight`). Opaque accent continues in [Color.withValues]: the
  /// requested there is an absolute alpha, and `1 * factor` would only match it.
  Color scaleAlpha(double factor) => withValues(alpha: (a * factor).clamp(0.0, 1.0));
}
