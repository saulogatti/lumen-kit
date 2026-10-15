import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Circular avatar with a gradient border and optional glow. Accepts an image
/// ([image]) or falls back to initials ([initials]).
class LumenAvatar extends StatelessWidget {
  /// Creates a circular avatar with an image, initials, or text fallback.
  const LumenAvatar({
    super.key,
    this.image,
    this.initials,
    this.radius = 22,
    this.accentColor,
    this.statusColor,
    this.showRing = true,
  });

  /// Image displayed in the avatar.
  ///
  /// When provided, takes precedence over [initials].
  final ImageProvider? image;

  /// Initials displayed when [image] is `null`.
  final String? initials;

  /// Avatar radius in logical pixels.
  final double radius;

  /// Override for the ring accent color. Default: `palette.primary`.
  final Color? accentColor;

  /// Small indicator (presence) at the bottom right. Not drawn when null.
  final Color? statusColor;

  /// If `true`, draws a gradient ring around the avatar.
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;
    final double size = radius * 2;

    final Widget base = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(showRing ? 2 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: style.fill(
          showRing ? LumenDecorations.accent(p, accent) : null,
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

    if (statusColor == null) {
      return base;
    }
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
