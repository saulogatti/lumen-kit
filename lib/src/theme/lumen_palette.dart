import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'lumen_style.dart';

/// Paleta instanciável do tema neon. Permite criar variantes (ex. branca, com
/// outras accents) sem alterar os tokens default de [AppColors].
///
/// Para trocar as cores sem configurar token por token, use
/// [LumenPalette.fromSeed] ou um [LumenPreset].
@immutable
class LumenPalette {
  /// Cria uma paleta completa para o tema neon.
  ///
  /// Os gradientes são opcionais: quando omitidos, são derivados dos tons de
  /// fundo e dos accents, e acompanham qualquer troca feita via [copyWith].
  ///
  /// [accentCyan], [accentMagenta] e [accentBlue] são aliases antigos de
  /// [primary], [secondary] e [tertiary], mantidos só por compatibilidade.
  const LumenPalette({
    required this.backgroundDeep,
    required this.backgroundMid,
    required this.backgroundSoft,
    required this.surface,
    required this.surfaceOutline,
    required this.surfaceHighlight,
    Color? primary,
    Color? secondary,
    Color? tertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.danger,
    this._backgroundGradient,
    this._accentGradient,
    @Deprecated('Use primary') Color? accentCyan,
    @Deprecated('Use secondary') Color? accentMagenta,
    @Deprecated('Use tertiary') Color? accentBlue,
  }) : assert(
         (primary ?? accentCyan) != null &&
             (secondary ?? accentMagenta) != null &&
             (tertiary ?? accentBlue) != null,
         'primary, secondary e tertiary são obrigatórios.',
       ),
       primary = primary ?? accentCyan ?? const Color(0x00000000),
       secondary = secondary ?? accentMagenta ?? const Color(0x00000000),
       tertiary = tertiary ?? accentBlue ?? const Color(0x00000000);

  /// Paleta default — mesmas cores expostas em [AppColors].
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

  /// Variante clara com os accents default.
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

  /// Gera uma paleta completa a partir de uma ou duas cores.
  ///
  /// Fundos, superfícies, contornos e textos recebem um leve tom de
  /// [primary]/[tertiary], para que o visual continue coeso com a cor
  /// escolhida. Quando omitidos, [secondary] é o complementar de [primary] e
  /// [tertiary] é o meio do caminho entre os dois. As cores semânticas
  /// (success / warning / danger) seguem os defaults do kit.
  ///
  /// ```dart
  /// AppTheme.fromPalette(
  ///   LumenPalette.fromSeed(primary: Colors.greenAccent),
  ///   brightness: Brightness.dark,
  /// );
  /// ```
  factory LumenPalette.fromSeed({
    required Color primary,
    Color? secondary,
    Color? tertiary,
    Brightness brightness = Brightness.dark,
  }) {
    final p = HSLColor.fromColor(primary);
    final HSLColor s = secondary != null
        ? HSLColor.fromColor(secondary)
        : p.withHue((p.hue + 150) % 360);
    final Color sec = s.toColor();
    // Meio do caminho pelo arco mais curto do círculo de matiz: laranja +
    // rosa dá vermelho, não ciano.
    final double delta = ((s.hue - p.hue + 540) % 360) - 180;
    final Color ter =
        tertiary ??
        HSLColor.lerp(
          p,
          s,
          0.5,
        )!.withHue((p.hue + delta / 2 + 360) % 360).toColor();

    // Fundos e textos herdam o matiz do accent intermediário, como o default
    // (azul escuro sob cyan + magenta).
    final double hue = HSLColor.fromColor(ter).hue;
    Color tone(double saturation, double lightness, [double alpha = 1]) =>
        HSLColor.fromAHSL(alpha, hue, saturation, lightness).toColor();

    final dark = brightness == Brightness.dark;
    return LumenPalette(
      backgroundDeep: dark ? tone(0.5, 0.04) : tone(0.3, 0.96),
      backgroundMid: dark ? tone(0.5, 0.09) : tone(0.3, 1),
      backgroundSoft: dark ? tone(0.5, 0.15) : tone(0.3, 0.98),
      surface: dark ? tone(0.5, 0.15) : tone(0.3, 0.995),
      surfaceOutline: primary.withValues(alpha: dark ? 0.2 : 0.25),
      surfaceHighlight: primary.withValues(alpha: dark ? 0.1 : 0.06),
      primary: primary,
      secondary: sec,
      tertiary: ter,
      textPrimary: dark ? tone(1, 0.96) : tone(0.3, 0.06),
      textSecondary: dark ? tone(1, 0.96, 0.7) : tone(0.15, 0.27),
      textMuted: dark ? tone(1, 0.96, 0.5) : tone(0.1, 0.52),
      success: AppColors.success,
      warning: AppColors.warning,
      danger: AppColors.danger,
    );
  }

  /// Tom mais profundo do fundo da aplicação.
  final Color backgroundDeep;

  /// Tom intermediário usado em gradientes de fundo.
  final Color backgroundMid;

  /// Tom mais claro do fundo, usado para suavizar o gradiente.
  final Color backgroundSoft;

  /// Cor base para cards, overlays e superfícies elevadas.
  final Color surface;

  /// Contorno translúcido usado em bordas de superfícies.
  final Color surfaceOutline;

  /// Realce sutil aplicado dentro de superfícies translúcidas.
  final Color surfaceHighlight;

  /// Accent primário usado em bordas, ícones e estados ativos.
  final Color primary;

  /// Accent secundário usado em glows e composições de gradiente.
  final Color secondary;

  /// Accent intermediário que conecta [primary] e [secondary] nos gradientes.
  final Color tertiary;

  /// Cor de maior contraste para títulos e conteúdo principal.
  final Color textPrimary;

  /// Cor de contraste médio para textos de apoio.
  final Color textSecondary;

  /// Cor de menor contraste para legendas, hints e conteúdo auxiliar.
  final Color textMuted;

  /// Cor semântica para estados de sucesso.
  final Color success;

  /// Cor semântica para estados de alerta.
  final Color warning;

  /// Cor semântica para estados de erro ou perigo.
  final Color danger;

  final LinearGradient? _backgroundGradient;
  final LinearGradient? _accentGradient;

  /// Alias antigo de [primary].
  @Deprecated('Use primary')
  Color get accentCyan => primary;

  /// Alias antigo de [secondary].
  @Deprecated('Use secondary')
  Color get accentMagenta => secondary;

  /// Alias antigo de [tertiary].
  @Deprecated('Use tertiary')
  Color get accentBlue => tertiary;

  /// Gradiente padrão de fundo da aplicação.
  LinearGradient get backgroundGradient =>
      _backgroundGradient ??
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[backgroundDeep, backgroundMid, backgroundSoft],
        stops: const <double>[0.0, 0.55, 1.0],
      );

  /// Gradiente de destaque usado em CTAs, indicadores e elementos ativos.
  LinearGradient get accentGradient =>
      _accentGradient ??
      LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[primary, tertiary, secondary],
      );

  /// Retorna uma nova paleta preservando os tokens não informados.
  ///
  /// Se algum tom de fundo ou accent mudar e o gradiente correspondente não
  /// for informado, o gradiente é recalculado a partir das novas cores.
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
    final bool backgroundChanged =
        backgroundDeep != null ||
        backgroundMid != null ||
        backgroundSoft != null;
    final bool accentChanged =
        primary != null || secondary != null || tertiary != null;
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
      backgroundGradient:
          backgroundGradient ??
          (backgroundChanged ? null : _backgroundGradient),
      accentGradient:
          accentGradient ?? (accentChanged ? null : _accentGradient),
    );
  }

  /// Interpola duas paletas, permitindo que trocas de tema sejam animadas.
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
      backgroundGradient: LinearGradient.lerp(
        a.backgroundGradient,
        b.backgroundGradient,
        t,
      ),
      accentGradient: LinearGradient.lerp(
        a.accentGradient,
        b.accentGradient,
        t,
      ),
    );
  }
}

/// Paletas prontas. Cada preset gera uma [LumenPalette] clara ou escura.
enum LumenPreset {
  /// Cyan + magenta original do kit.
  neon(Color(0xFF00E5FF), Color(0xFFB14BFF)),

  /// Verde terminal com toque de ciano.
  matrix(Color(0xFF39FF14), Color(0xFF00FFC6)),

  /// Laranja e rosa de pôr do sol oitentista.
  synthwave(Color(0xFFFF8A00), Color(0xFFFF2E88)),

  /// Violeta e azul elétrico.
  ultraviolet(Color(0xFF8C5BFF), Color(0xFF2E9BFF)),

  /// Vermelho e âmbar.
  ember(Color(0xFFFF3B3B), Color(0xFFFFB020));

  const LumenPreset(this.primary, this.secondary);

  /// Accent primário do preset.
  final Color primary;

  /// Accent secundário do preset.
  final Color secondary;

  /// Gera a paleta do preset. [LumenPreset.neon] devolve exatamente
  /// [LumenPalette.defaultDark] / [LumenPalette.light].
  LumenPalette palette({Brightness brightness = Brightness.dark}) {
    if (this == LumenPreset.neon) {
      return brightness == Brightness.dark
          ? LumenPalette.defaultDark()
          : LumenPalette.light();
    }
    return LumenPalette.fromSeed(
      primary: primary,
      secondary: secondary,
      brightness: brightness,
    );
  }
}

/// ThemeExtension para acessar a paleta via `Theme.of(context).extension<LumenThemeExt>()`.
@immutable
class LumenThemeExt extends ThemeExtension<LumenThemeExt> {
  /// Cria uma extensão de tema que transporta a [palette] e o [style].
  const LumenThemeExt({required this.palette, this.style = LumenStyle.neon});

  /// Paleta disponível para os widgets que leem o [ThemeData] atual.
  final LumenPalette palette;

  /// Estilo de efeitos (sombra, borda, fundo…) usado pelos widgets.
  final LumenStyle style;

  @override
  LumenThemeExt copyWith({LumenPalette? palette, LumenStyle? style}) =>
      LumenThemeExt(
        palette: palette ?? this.palette,
        style: style ?? this.style,
      );

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

  /// Obtém a paleta e o estilo neon ativos para [context].
  ///
  /// Ordem de busca: o [LumenScope] mais próximo, depois a extensão registrada
  /// no [ThemeData], e por fim a paleta default ([LumenPalette.defaultDark] ou
  /// [LumenPalette.light], conforme o brilho do tema do app) com
  /// [LumenStyle.neon]. Assim os widgets funcionam em apps que mantêm o
  /// próprio `ThemeData` e nunca registram nada do kit.
  static LumenThemeExt of(BuildContext context) {
    final LumenScope? scope = context
        .dependOnInheritedWidgetOfExactType<LumenScope>();
    if (scope != null) {
      return scope.data;
    }
    final ThemeData theme = Theme.of(context);
    return theme.extension<LumenThemeExt>() ??
        (theme.brightness == Brightness.dark ? _fallbackDark : _fallbackLight);
  }

  static final LumenThemeExt _fallbackDark = LumenThemeExt(
    palette: LumenPalette.defaultDark(),
  );
  static final LumenThemeExt _fallbackLight = LumenThemeExt(
    palette: LumenPalette.light(),
  );
}

/// Define paleta e estilo neon para uma subárvore sem mexer no `ThemeData`.
///
/// Útil quando o app tem o próprio tema e só quer usar alguns componentes do
/// kit com outras cores:
///
/// ```dart
/// LumenScope(
///   palette: LumenPalette.fromSeed(primary: Colors.teal),
///   style: LumenStyle.flat,
///   child: LumenButton(label: 'Salvar', onPressed: salvar),
/// )
/// ```
///
/// Tem prioridade sobre a [LumenThemeExt] registrada no tema.
class LumenScope extends InheritedWidget {
  /// Cria um escopo com [palette] e [style] para [child].
  LumenScope({
    required LumenPalette palette,
    LumenStyle style = LumenStyle.neon,
    required super.child,
    super.key,
  }) : data = LumenThemeExt(palette: palette, style: style);

  /// Paleta e estilo fornecidos à subárvore.
  final LumenThemeExt data;

  @override
  bool updateShouldNotify(LumenScope oldWidget) =>
      oldWidget.data.palette != data.palette ||
      oldWidget.data.style != data.style;
}
