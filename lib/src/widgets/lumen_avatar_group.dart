import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';
import 'lumen_avatar.dart';

/// Stacked avatars with overlap and a "+N" for the remaining people.
/// For participants, team members, people who liked something…
///
/// The [avatars] are redrawn using the group's [radius]: each [LumenAvatar]'s
/// `radius` and `statusColor` are ignored here.
///
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
  /// Creates the group.
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
  }) : assert(maxVisible > 0),
       assert(overlap >= 0 && overlap < 1);

  /// Group avatars, in display order.
  final List<LumenAvatar> avatars;

  /// Number of avatars shown before "+N".
  final int maxVisible;

  /// Actual number of people when [avatars] contains only a sample (e.g. the
  /// API returns 3 photos and "128 participants"). Default: `avatars.length`.
  final int? total;

  /// Radius of each avatar.
  final double radius;

  /// Fraction of the diameter each avatar covers from the previous one (0 to 1).
  final double overlap;

  /// Accent color for the rings and "+N". Default: `palette.primary`.
  final Color? accentColor;

  /// Color of the outline separating the avatars. Default:
  /// `palette.backgroundDeep`.
  final Color? ringColor;

  /// Called when "+N" is tapped. `null` = not tappable.
  final VoidCallback? onOverflowTap;

  /// Group label for screen readers (e.g. "5 participants").
  final String? semanticLabel;

  static const double _ring = 2;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle s = LumenStyle.of(context);
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
          // The group label already says how many there are; a bare "+3" would be noise.
          ? ExcludeSemantics(excluding: semanticLabel != null, child: chip)
          : LumenPressable(
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
            if (overflow != null)
              Positioned(left: stepX * visible, child: overflow),
          ],
        ),
      ),
    );
  }
}
