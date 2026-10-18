import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_avatar.dart';
import 'package:material_ui/material_ui.dart';

/// Stacked avatars with overlay and a "+N" for overflow.
///
/// For participants, team members, anyone who liked…
/// The [avatars] are redesigned with the [radius] from the group: the `radius`
/// and the `statusColor` of each [LumenAvatar] are ignored here.
/// ```dart
/// LumenAvatarGroup(
///   avatars: <LumenAvatar>[
///     for (final User u in membros) LumenAvatar(initials: u.iniciais),
///   ],
///   maxVisible: 3,
///   onOverflowTap: abrirLista,
/// )
/// ```
class LumenAvatarGroup extends StatelessWidget {
  /// Create the group.
  const LumenAvatarGroup({
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
  }) : assert(maxVisible > 0, 'maxVisible must be greater than 0'),
       assert(overlap >= 0 && overlap < 1, 'overlap must be between 0 and 1');

  /// Group avatars, in display order.
  final List<LumenAvatar> avatars;

  /// How many avatars appear before the "+N".
  final int maxVisible;

  /// Real total of people, when [avatars] only brings a sample (e.g.
  ///
  /// the API returns 3 photos and "128 participants"). Default: `avatars.length`.
  final int? total;

  /// Radius of each avatar.
  final double radius;

  /// Fraction of the diameter that each avatar covers the previous one (0 to 1).
  final double overlap;

  /// Accent of rings and "+N".
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Color of the outline that separates the avatars.
  ///
  /// Default: `palette.backgroundDeep`.
  final Color? ringColor;

  /// Called by touching "+N".
  ///
  /// `null` = not touchable.
  final VoidCallback? onOverflowTap;

  /// Group label for screen readers (e.g.
  ///
  /// "5 participants").
  final String? semanticLabel;

  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;
    final ring = ringColor ?? p.backgroundDeep;
    final count = total ?? avatars.length;
    final visible = avatars.length < maxVisible ? avatars.length : maxVisible;
    final extra = count - visible;
    final outer = (radius + _ring) * 2;
    final stepX = outer * (1 - overlap);
    final slots = visible + (extra > 0 ? 1 : 0);
    if (slots == 0) {
      return const SizedBox.shrink();
    }

    Widget ringed(Widget child) => Container(
      width: outer,
      height: outer,
      padding: const EdgeInsets.all(_ring),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle),
      child: child,
    );

    Widget? overflow;
    if (extra > 0) {
      final chip = ringed(
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
          : LumenPressable(onTap: onOverflowTap, customBorder: const CircleBorder(), child: chip);
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
                    LumenAvatar(
                      image: avatars[i].image,
                      initials: avatars[i].initials,
                      radius: radius,
                      accentColor: avatars[i].accentColor ?? accent,
                      showRing: avatars[i].showRing,
                    ),
                  ),
                ),
              ),
            if (overflow != null) Positioned(left: stepX * visible, child: overflow),
          ],
        ),
      ),
    );
  }
}
