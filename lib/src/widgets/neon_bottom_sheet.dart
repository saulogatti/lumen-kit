import 'package:material_ui/material_ui.dart';

import '../theme/neon_palette.dart';

/// Abre um modal bottom sheet com a estética do tema neon (gradiente de fundo,
/// borda accent no topo e handle).
///
/// [builder] cria o conteúdo interno. As flags [isScrollControlled],
/// [isDismissible] e [enableDrag] são repassadas ao [showModalBottomSheet].
Future<T?> showNeonBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? accentColor,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final NeonPalette p = NeonThemeExt.of(context).palette;
  final Color accent = accentColor ?? p.accentCyan;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (BuildContext ctx) =>
        _NeonBottomSheetShell(accent: accent, child: builder(ctx)),
  );
}

class _NeonBottomSheetShell extends StatelessWidget {
  const _NeonBottomSheetShell({required this.accent, required this.child});

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            p.backgroundMid.withValues(alpha: 0.98),
            p.backgroundDeep.withValues(alpha: 0.98),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: accent.withValues(alpha: 0.55), width: 1.2),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, -6),
          ),
        ],
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
                color: p.textMuted.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
