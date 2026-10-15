import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:material_ui/material_ui.dart';

/// Block for when there is no data: icon, title, text and a CTA.
/// Without [onPressed], the button does not appear.
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
  /// Creates the empty state with [title].
  const LumenEmptyState({
    required this.title,
    super.key,
    this.icon,
    this.message,
    this.actionLabel,
    this.onPressed,
  });

  /// Icon above the title.
  final IconData? icon;

  /// Empty state title.
  final String title;

  /// Supporting text below the title.
  final String? message;

  /// CTA label.
  ///
  /// Without [onPressed], the button is not drawn.
  final String? actionLabel;

  /// CTA callback.
  ///
  /// `null` omits the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final showAction = actionLabel != null && onPressed != null;
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
