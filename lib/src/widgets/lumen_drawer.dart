import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_decorations.dart';
import '../foundation/lumen_pressable.dart';
import '../foundation/lumen_tokens.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Side drawer with a gradient background and vertical accent border.
///
/// Use directly in `Scaffold(drawer: LumenDrawer(...))`. Children can be any
/// widgets — usually a custom header followed by [LumenDrawerItem]s.
class LumenDrawer extends StatelessWidget {
  /// Creates a neon drawer with a list of [children].
  const LumenDrawer({
    required this.children,
    super.key,
    this.accentColor,
    this.header,
    this.footer,
    this.width = 300,
  });

  /// Widgets displayed in the drawer's scrollable area.
  final List<Widget> children;

  /// Optional header displayed before the list.
  final Widget? header;

  /// Optional footer displayed after the list.
  final Widget? footer;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Drawer width in logical pixels.
  final double width;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: style.fill(
            LumenDecorations.diagonal(
              p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.98)),
              p.backgroundDeep.withValues(alpha: 0.98),
            ),
          ),
          border: Border(
            right: BorderSide(
              color: accent.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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

/// Standardized item for [LumenDrawer], with a glow in the selected state.
class LumenDrawerItem extends StatelessWidget {
  /// Creates an interactive item for use inside [LumenDrawer].
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

  /// Main item text.
  final String label;

  /// Callback run when the item is tapped.
  ///
  /// When `null`, the item appears disabled.
  final VoidCallback? onTap;

  /// If `true`, applies visual selection highlighting.
  final bool selected;

  /// Accent color override. Default: `palette.primary`.
  final Color? accentColor;

  /// Optional widget displayed at the end of the row.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

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
