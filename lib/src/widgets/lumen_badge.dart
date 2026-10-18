import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Small stamp (usually for accountants) that can be left free or anchored to
/// [child] in the upper right corner.
class LumenBadge extends StatelessWidget {
  /// Creates a badge with text or anchored to [child].
  const LumenBadge({
    required this.label,
    super.key,
    this.color,
    this.child,
    this.dot = false,
    this.dense = false,
  });

  /// "Dot" mode (no text), useful for indicating activity.
  const LumenBadge.dot({super.key, this.color, this.child}) : label = '', dot = true, dense = false;

  /// Text displayed inside the badge when [dot] is `false`.
  final String label;

  /// Badge background color.
  ///
  /// Default: `palette.danger`.
  final Color? color;

  /// Optional widget used as an anchor to position the badge.
  final Widget? child;

  /// If `true`, renders only one point without [label].
  final bool dot;

  /// Smaller version, for navigation icons.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final c = color ?? p.danger;

    // Texto legível sobre qualquer cor de fundo, não só sobre vermelho.
    final fg = ThemeData.estimateBrightnessForColor(c) == Brightness.dark
        ? Colors.white
        : Colors.black;

    final Widget badge = Container(
      padding: switch ((dot, dense)) {
        (true, _) => EdgeInsets.zero,
        (false, true) => const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        (false, false) => const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      },
      constraints: switch ((dot, dense)) {
        (true, _) => const BoxConstraints(minWidth: 10, minHeight: 10),
        (false, true) => null,
        (false, false) => const BoxConstraints(minWidth: 18, minHeight: 18),
      },
      decoration: BoxDecoration(
        color: c,
        borderRadius: style.radius(dot ? 10 : (dense ? 8 : 12)),
        boxShadow: style.shadows(<BoxShadow>[
          BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: dense ? 6 : 8),
        ]),
      ),
      alignment: dense ? null : Alignment.center,
      child: dot
          ? null
          : Text(
              label,
              style: TextStyle(
                fontSize: dense ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: fg,
                height: dense ? null : 1,
              ),
            ),
    );

    if (child == null) {
      return badge;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child!,
        Positioned(right: -4, top: -4, child: badge),
      ],
    );
  }
}

/// Compact tag — lightweight variation of `LumenStatusChip`, with no required
/// icon and no strong glow.
///
/// Good for metadata in lists.
class LumenTag extends StatelessWidget {
  /// Creates a compact tag for metadata or filters.
  const LumenTag({required this.label, super.key, this.color, this.icon, this.onTap});

  /// Text displayed in the tag.
  final String label;

  /// Tag highlight color.
  ///
  /// Default: `palette.primary`.
  final Color? color;

  /// Optional icon displayed before [label].
  final IconData? icon;

  /// Callback executed when touching the tag.
  /// When `null`, the tag is rendered without interactive behavior.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final c = color ?? p.primary;

    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: style.radius(20),
        border: style.borderAll(color: c.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: <Widget>[
          if (icon != null) Icon(icon, size: 12, color: c),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }
    return LumenPressable(onTap: onTap, borderRadius: style.radius(20), child: content);
  }
}
