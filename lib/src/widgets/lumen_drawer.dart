import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Side drawer with gradient background and vertical accent border.
/// Use directly on `Scaffold(drawer: LumenDrawer(...))`. Children can be any
/// widgets — usually a custom header followed by [LumenDrawerItem]s.
class LumenDrawer extends StatelessWidget {
  /// Creates a neon drawer with list of [children].
  const LumenDrawer({
    required this.children,
    super.key,
    this.accentColor,
    this.header,
    this.footer,
    this.width = 300,
  });

  /// Widgets displayed in the scrollable drawer area.
  final List<Widget> children;

  /// Optional header displayed before the list.
  final Widget? header;

  /// Optional footer displayed after the list.
  final Widget? footer;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Drawer width in logical pixels.
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: style.fill(
            LumenDecorations.diagonal(
              p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.98)),
              p.backgroundDeep.withValues(alpha: 0.98),
            ),
          ),
          border: Border(right: BorderSide(color: accent.withValues(alpha: 0.55), width: 1.2)),
          boxShadow: style.shadows(<BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(4, 0),
            ),
          ]),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              ?header,
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: children,
                ),
              ),
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

/// Item defaults to [LumenDrawer], with glow in the selected state.
class LumenDrawerItem extends StatelessWidget {
  /// Creates an interactive item for use within [LumenDrawer].
  const LumenDrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
    this.selected = false,
    this.accentColor,
    this.trailing,
  });

  /// Icon displayed before the text.
  final IconData icon;

  /// Main text of the item.
  final String label;

  /// Callback executed when touching the item.
  /// When `null`, the item is visually disabled.
  final VoidCallback? onTap;

  /// Whether to apply visual selection highlighting.
  final bool selected;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Optional widget displayed at the end of the line.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = accentColor ?? p.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: LumenPressable(
        onTap: onTap,
        selected: selected,
        borderRadius: style.radius(14),
        child: AnimatedContainer(
          duration: LumenMotion.duration(context, kLumenFastDuration),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: LumenDecorations.selectable(
            p,
            style,
            accent: accent,
            selected: selected,
            radius: 14,
          ),
          child: Row(
            spacing: 14,
            children: <Widget>[
              Icon(icon, color: selected ? accent : p.textMuted, size: 20),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? p.textPrimary : p.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
