import 'package:material_ui/material_ui.dart';

import '../theme/lumen_palette.dart';
import 'lumen_button.dart';

/// Bloco para quando não há dados: ícone, título, texto e um CTA.
///
/// Sem [onPressed], o botão não aparece.
///
/// ```dart
/// LumenEmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'Nada por aqui',
///   message: 'Quando chegar um evento, ele aparece nesta lista.',
///   actionLabel: 'Atualizar',
///   onPressed: atualizar,
/// )
/// ```
class LumenEmptyState extends StatelessWidget {
  /// Cria o estado vazio com [title].
  const LumenEmptyState({
    required this.title,
    super.key,
    this.icon,
    this.message,
    this.actionLabel,
    this.onPressed,
  });

  /// Ícone acima do título.
  final IconData? icon;

  /// Título do estado vazio.
  final String title;

  /// Texto de apoio abaixo do título.
  final String? message;

  /// Rótulo do CTA. Sem [onPressed], o botão não é desenhado.
  final String? actionLabel;

  /// Callback do CTA. `null` omite o botão.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final bool showAction = actionLabel != null && onPressed != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: <Widget>[
          if (icon != null) Icon(icon, size: 36, color: p.textMuted),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: p.textPrimary),
          ),
          if (message != null)
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: p.textSecondary),
            ),
          if (showAction) ...<Widget>[
            const SizedBox(height: 8),
            LumenButton(label: actionLabel!, onPressed: onPressed),
          ],
        ],
      ),
    );
  }
}
