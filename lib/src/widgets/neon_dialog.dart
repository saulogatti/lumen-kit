import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

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

  /// Cor de destaque (borda + ícone). Default: [AppColors.accentCyan].
  final Color? accent;

  /// Ícone opcional exibido antes do título.
  final IconData? icon;

  /// Largura máxima do diálogo.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color a = accent ?? AppColors.accentCyan;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.surface.withValues(alpha: 0.98),
                AppColors.backgroundMid.withValues(alpha: 0.95),
              ],
            ),
            border: Border.all(color: a.withValues(alpha: 0.5), width: 1.2),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: a.withValues(alpha: 0.25),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: a.withValues(alpha: 0.12),
                        border: Border.all(color: a.withValues(alpha: 0.45)),
                      ),
                      child: Icon(icon, color: a, size: 22),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(child: Text(title, style: text.headlineMedium)),
                ],
              ),
              const SizedBox(height: 18),
              DefaultTextStyle.merge(
                style: text.bodyMedium ?? const TextStyle(),
                child: content,
              ),
              if (actions.isNotEmpty) ...<Widget>[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    for (int i = 0; i < actions.length; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: 12),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
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
