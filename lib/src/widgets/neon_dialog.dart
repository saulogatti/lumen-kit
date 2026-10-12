import 'package:material_ui/material_ui.dart';

import '../foundation/neon_decorations.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Dialog estilizado com surface gradiente, borda accent e tipografia do tema.
/// Pode ser usado direto via [showNeonDialog].
class NeonDialog extends StatelessWidget {
  /// Cria um diálogo neon com conteúdo customizado.
  const NeonDialog({
    required this.title,
    required this.content,
    super.key,
    this.actions = const <Widget>[],
    this.accent,
    this.icon,
    this.maxWidth = 460,
  });

  /// Título exibido no cabeçalho do diálogo.
  final String title;

  /// Conteúdo principal do diálogo.
  final Widget content;

  /// Ações exibidas no rodapé, alinhadas à direita.
  final List<Widget> actions;

  /// Cor de destaque (borda + ícone). Default: `palette.primary`.
  final Color? accent;

  /// Ícone opcional exibido antes do título.
  final IconData? icon;

  /// Largura máxima do diálogo.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color a = accent ?? p.primary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: style.frost(
          borderRadius: style.radius(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: NeonDecorations.panel(
              p,
              style,
              accent: a,
              radius: 20,
              borderAlpha: 0.5,
              glowAlpha: 0.25,
              glowBlur: 32,
              glowOffset: const Offset(0, 16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  spacing: 14,
                  children: <Widget>[
                    if (icon != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: NeonDecorations.iconBox(style, accent: a),
                        child: Icon(icon, color: a, size: 22),
                      ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: text.headlineMedium),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                DefaultTextStyle.merge(
                  style: text.bodyMedium ?? const TextStyle(),
                  child: content,
                ),
                if (actions.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 24),
                  // Wrap: ações longas quebram linha em vez de estourar.
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 8,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper para exibir um [NeonDialog] com `showDialog`.
///
/// Retorna o mesmo resultado de [showDialog]. [barrierDismissible] controla se
/// o toque fora do diálogo fecha a rota modal.
Future<T?> showNeonDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget> actions = const <Widget>[],
  Color? accent,
  IconData? icon,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext ctx) => NeonDialog(
      title: title,
      content: content,
      actions: actions,
      accent: accent,
      icon: icon,
    ),
  );
}
