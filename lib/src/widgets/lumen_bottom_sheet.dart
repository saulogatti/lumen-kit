import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:material_ui/material_ui.dart';

/// Opens a bottom sheet modal with the neon theme aesthetic (background
/// gradient, accent border on top and handle).
/// [builder] creates the internal content. The [isScrollControlled] flags,
/// [isDismissible] and [enableDrag] are passed to [showModalBottomSheet].
Future<T?> showLumenBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? accentColor,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final p = LumenThemeExt.of(context).palette;
  final accent = accentColor ?? p.primary;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (ctx) => _LumenBottomSheetShell(accent: accent, child: builder(ctx)),
  );
}

class _LumenBottomSheetShell extends StatelessWidget {
  const _LumenBottomSheetShell({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final sheetRadius = BorderRadius.vertical(top: Radius.circular(24 * style.radiusScale));
    return style.frost(
      borderRadius: sheetRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: style.fill(
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                p.backgroundMid.withValues(alpha: style.surfaceAlpha(0.98)),
                p.backgroundDeep.withValues(alpha: 0.98),
              ],
            ),
          ),
          borderRadius: sheetRadius,
          border: Border(top: BorderSide(color: accent.withValues(alpha: 0.55), width: 1.2)),
          boxShadow: style.shadows(<BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: -4,
              offset: const Offset(0, -6),
            ),
          ]),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: p.textMuted.scaleAlpha(0.45),
                  borderRadius: style.radius(2),
                ),
              ),
              const SizedBox(height: 14),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
