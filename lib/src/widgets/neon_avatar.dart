import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Avatar circular com borda em gradiente e glow opcional. Aceita imagem
/// ([image]) ou caem nas iniciais ([initials]).
class NeonAvatar extends StatelessWidget {
  /// Cria um avatar circular com imagem, iniciais ou fallback textual.
  const NeonAvatar({
    super.key,
    this.image,
    this.initials,
    this.radius = 22,
    this.accentColor,
    this.statusColor,
    this.showRing = true,
  });

  /// Imagem exibida no avatar.
  ///
  /// Quando informada, tem precedência sobre [initials].
  final ImageProvider? image;

  /// Iniciais exibidas quando [image] é `null`.
  final String? initials;

  /// Raio do avatar em pixels lógicos.
  final double radius;

  /// Override da cor de destaque do anel. Default: `palette.primary`.
  final Color? accentColor;

  /// Pequeno indicador (presença) no canto inferior direito. Quando null, não
  /// é desenhado.
  final Color? statusColor;

  /// Se `true`, desenha o anel em gradiente ao redor do avatar.
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final double size = radius * 2;

    final Widget base = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(showRing ? 2 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.fill(
          showRing
              ? LinearGradient(
                  colors: <Color>[accent, p.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        boxShadow: style.shadows(
          showRing
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: p.surface,
          image: image == null
              ? null
              : DecorationImage(image: image!, fit: BoxFit.cover),
        ),
        alignment: Alignment.center,
        child: image != null
            ? null
            : Text(
                (initials ?? '?').toUpperCase(),
                style: TextStyle(
                  color: p.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: radius * 0.75,
                ),
              ),
      ),
    );

    if (statusColor == null) return base;
    final double dot = (size * 0.28).clamp(8, 18);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          base,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: style.borderAll(color: p.backgroundDeep, width: 2),
                boxShadow: style.shadows(<BoxShadow>[
                  BoxShadow(
                    color: statusColor!.withValues(alpha: 0.6),
                    blurRadius: 6,
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
