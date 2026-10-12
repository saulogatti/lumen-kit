import 'package:material_ui/material_ui.dart';

import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';
import 'neon_avatar.dart';

/// Avatares empilhados com sobreposição e um "+N" para o excedente.
/// Para participantes, membros de equipe, quem curtiu…
///
/// Os [avatars] são redesenhados com o [radius] do grupo: o `radius` e o
/// `statusColor` de cada [NeonAvatar] são ignorados aqui.
///
/// ```dart
/// NeonAvatarGroup(
///   avatars: <NeonAvatar>[
///     for (final User u in membros) NeonAvatar(initials: u.iniciais),
///   ],
///   maxVisible: 3,
///   onOverflowTap: abrirLista,
/// )
/// ```
class NeonAvatarGroup extends StatelessWidget {
  /// Cria o grupo.
  const NeonAvatarGroup({
    required this.avatars,
    super.key,
    this.maxVisible = 4,
    this.total,
    this.radius = 18,
    this.overlap = 0.3,
    this.accentColor,
    this.ringColor,
    this.onOverflowTap,
    this.semanticLabel,
  }) : assert(maxVisible > 0),
       assert(overlap >= 0 && overlap < 1);

  /// Avatares do grupo, na ordem de exibição.
  final List<NeonAvatar> avatars;

  /// Quantos avatares aparecem antes do "+N".
  final int maxVisible;

  /// Total real de pessoas, quando [avatars] traz só uma amostra (ex.: a API
  /// devolve 3 fotos e "128 participantes"). Default: `avatars.length`.
  final int? total;

  /// Raio de cada avatar.
  final double radius;

  /// Fração do diâmetro que cada avatar cobre do anterior (0 a 1).
  final double overlap;

  /// Accent dos anéis e do "+N". Default: `palette.primary`.
  final Color? accentColor;

  /// Cor do contorno que separa os avatares. Default:
  /// `palette.backgroundDeep`.
  final Color? ringColor;

  /// Chamado ao tocar no "+N". `null` = não tocável.
  final VoidCallback? onOverflowTap;

  /// Rótulo do grupo para leitores de tela (ex.: "5 participantes").
  final String? semanticLabel;

  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle s = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final Color ring = ringColor ?? p.backgroundDeep;
    final int count = total ?? avatars.length;
    final int visible = avatars.length < maxVisible
        ? avatars.length
        : maxVisible;
    final int extra = count - visible;
    final double outer = (radius + _ring) * 2;
    final double stepX = outer * (1 - overlap);
    final int slots = visible + (extra > 0 ? 1 : 0);
    if (slots == 0) return const SizedBox.shrink();

    Widget ringed(Widget child) => Container(
      width: outer,
      height: outer,
      padding: const EdgeInsets.all(_ring),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
      child: child,
    );

    Widget? overflow;
    if (extra > 0) {
      final Widget chip = ringed(
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.alphaBlend(accent.withValues(alpha: 0.16), p.surface),
            border: s.borderAll(color: accent.withValues(alpha: 0.6)),
          ),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                '+$extra',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: radius * 0.7,
                ),
              ),
            ),
          ),
        ),
      );
      overflow = onOverflowTap == null
          // O rótulo do grupo já diz quantos são; "+3" solto seria ruído.
          ? ExcludeSemantics(excluding: semanticLabel != null, child: chip)
          : NeonPressable(
              onTap: onOverflowTap,
              customBorder: const CircleBorder(),
              child: chip,
            );
    }

    return Semantics(
      container: true,
      label: semanticLabel,
      child: SizedBox(
        width: outer + stepX * (slots - 1),
        height: outer,
        child: Stack(
          children: <Widget>[
            for (int i = 0; i < visible; i++)
              Positioned(
                left: stepX * i,
                child: ExcludeSemantics(
                  child: ringed(
                    NeonAvatar(
                      image: avatars[i].image,
                      initials: avatars[i].initials,
                      radius: radius,
                      accentColor: avatars[i].accentColor ?? accent,
                      showRing: avatars[i].showRing,
                    ),
                  ),
                ),
              ),
            if (overflow != null)
              Positioned(left: stepX * visible, child: overflow),
          ],
        ),
      ),
    );
  }
}
