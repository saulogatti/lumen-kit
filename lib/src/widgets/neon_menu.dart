import 'package:material_ui/material_ui.dart';

import '../foundation/neon_tokens.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';
import 'neon_icon_button.dart';

/// Entrada de um menu neon: [NeonMenuItem] ou [NeonMenuDivider].
sealed class NeonMenuEntry<T> {
  const NeonMenuEntry();
}

/// Ação de um menu neon.
class NeonMenuItem<T> extends NeonMenuEntry<T> {
  /// Cria uma ação com [value] devolvido ao ser escolhida.
  const NeonMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
    this.destructive = false,
  });

  /// Valor devolvido por [showNeonMenu] / `onSelected`.
  final T value;

  /// Texto da ação.
  final String label;

  /// Ícone opcional antes do [label].
  final IconData? icon;

  /// Se `false`, a ação aparece apagada e não pode ser escolhida.
  final bool enabled;

  /// Pinta a ação com `palette.danger` (ex.: "Excluir").
  final bool destructive;
}

/// Linha separando grupos de ações.
class NeonMenuDivider<T> extends NeonMenuEntry<T> {
  /// Cria um separador.
  const NeonMenuDivider();
}

/// Abre um menu flutuante com [items] e devolve o valor escolhido, ou `null`
/// se o menu for fechado sem escolha.
///
/// Sem [position], o menu abre ancorado logo abaixo do widget dono de
/// [context] (como o "⋮" de um card). Para abrir num ponto da tela (ex.:
/// clique direito), use [neonMenuPositionAt].
Future<T?> showNeonMenu<T>({
  required BuildContext context,
  required List<NeonMenuEntry<T>> items,
  RelativeRect? position,
  Color? accentColor,
  T? initialValue,
}) {
  assert(items.isNotEmpty, 'O menu precisa de ao menos uma entrada.');
  final NeonPalette p = NeonThemeExt.of(context).palette;
  final NeonStyle s = NeonStyle.of(context);
  final Color accent = accentColor ?? p.primary;
  final TextStyle? text = Theme.of(context).textTheme.bodyMedium;
  final Border border = s.borderAll(
    color: accent.withValues(alpha: 0.45),
    width: 1.2,
  );

  return showMenu<T>(
    context: context,
    position: position ?? _anchorBelow(context),
    initialValue: initialValue,
    color: p.surface.withValues(alpha: s.surfaceAlpha(0.98)),
    surfaceTintColor: Colors.transparent,
    elevation: s.shadow == NeonShadowKind.none ? 0 : 10,
    shadowColor: s.shadow == NeonShadowKind.glow
        ? accent.withValues(alpha: 0.45 * s.shadowStrength)
        : Colors.black54,
    shape: RoundedRectangleBorder(
      borderRadius: s.radius(14),
      side: s.borderScale == 0 ? BorderSide.none : border.top,
    ),
    clipBehavior: Clip.antiAlias,
    popUpAnimationStyle: NeonMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : null,
    items: <PopupMenuEntry<T>>[
      for (final NeonMenuEntry<T> entry in items)
        switch (entry) {
          NeonMenuDivider<T>() => PopupMenuDivider(
            height: 9,
            color: p.surfaceOutline,
          ),
          final NeonMenuItem<T> item => PopupMenuItem<T>(
            value: item.value,
            enabled: item.enabled,
            height: 44,
            child: _NeonMenuRow(
              item: item,
              color: item.destructive ? p.danger : p.textPrimary,
              iconColor: item.destructive ? p.danger : accent,
              selected: initialValue != null && initialValue == item.value,
              selectedColor: accent,
              style: text,
            ),
          ),
        },
    ],
  );
}

/// Posição para [showNeonMenu] num ponto global da tela (ex.:
/// `TapUpDetails.globalPosition` de um clique direito).
RelativeRect neonMenuPositionAt(BuildContext context, Offset globalPosition) {
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final Offset local = overlay.globalToLocal(globalPosition);
  return RelativeRect.fromRect(local & Size.zero, Offset.zero & overlay.size);
}

RelativeRect _anchorBelow(BuildContext context) {
  final box = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final Offset topLeft = box.localToGlobal(
    Offset(0, box.size.height),
    ancestor: overlay,
  );
  final Offset bottomRight = box.localToGlobal(
    box.size.bottomRight(Offset.zero),
    ancestor: overlay,
  );
  return RelativeRect.fromRect(
    Rect.fromPoints(topLeft, bottomRight),
    Offset.zero & overlay.size,
  );
}

class _NeonMenuRow<T> extends StatelessWidget {
  const _NeonMenuRow({
    required this.item,
    required this.color,
    required this.iconColor,
    required this.selected,
    required this.selectedColor,
    required this.style,
  });

  final NeonMenuItem<T> item;
  final Color color;
  final Color iconColor;
  final bool selected;
  final Color selectedColor;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? selectedColor : color;
    final Widget row = Row(
      spacing: 12,
      children: <Widget>[
        if (item.icon != null) Icon(item.icon, size: 18, color: iconColor),
        Expanded(
          child: Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w600 : null,
            ),
          ),
        ),
        if (selected) Icon(Icons.check_rounded, size: 18, color: fg),
      ],
    );
    return item.enabled
        ? row
        : Opacity(opacity: kNeonDisabledOpacity, child: row);
  }
}

/// Botão "⋮" (ou outro [icon]) que abre um menu de ações ancorado nele.
/// Para cards, list tiles e app bars.
///
/// ```dart
/// NeonMenuButton<String>(
///   items: const <NeonMenuEntry<String>>[
///     NeonMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
///     NeonMenuDivider(),
///     NeonMenuItem(value: 'del', label: 'Excluir', destructive: true),
///   ],
///   onSelected: handle,
/// )
/// ```
class NeonMenuButton<T> extends StatelessWidget {
  /// Cria o botão de menu. Com [onSelected] `null`, fica desabilitado.
  const NeonMenuButton({
    required this.items,
    required this.onSelected,
    super.key,
    this.icon = Icons.more_vert_rounded,
    this.tooltip,
    this.accentColor,
    this.initialValue,
    this.variant = NeonIconButtonVariant.ghost,
    this.size = 40,
    this.onCanceled,
  });

  /// Ações do menu.
  final List<NeonMenuEntry<T>> items;

  /// Chamado com o valor da ação escolhida.
  final ValueChanged<T>? onSelected;

  /// Chamado quando o menu fecha sem escolha.
  final VoidCallback? onCanceled;

  /// Ícone do botão.
  final IconData icon;

  /// Tooltip do botão. Default: rótulo "mostrar menu" do Material.
  final String? tooltip;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  /// Valor marcado com um check no menu.
  final T? initialValue;

  /// Variante visual do botão.
  final NeonIconButtonVariant variant;

  /// Lado do botão.
  final double size;

  @override
  Widget build(BuildContext context) {
    return NeonIconButton(
      icon: icon,
      variant: variant,
      size: size,
      accentColor: accentColor,
      tooltip: tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
      onPressed: onSelected == null
          ? null
          : () async {
              final T? value = await showNeonMenu<T>(
                context: context,
                items: items,
                accentColor: accentColor,
                initialValue: initialValue,
              );
              if (!context.mounted) {
                return;
              }
              if (value == null) {
                onCanceled?.call();
              } else {
                onSelected?.call(value);
              }
            },
    );
  }
}

/// Abre um menu de contexto com clique direito (desktop/web) ou toque longo
/// (mobile) sobre [child], na posição do ponteiro.
///
/// Usa `GestureDetector` porque precisa da posição do ponteiro, que o
/// `NeonPressable` não expõe; leitores de tela abrem o menu pela ação de
/// toque longo.
class NeonContextMenu<T> extends StatelessWidget {
  /// Cria a região de menu de contexto.
  const NeonContextMenu({
    required this.items,
    required this.onSelected,
    required this.child,
    super.key,
    this.accentColor,
  });

  /// Ações do menu.
  final List<NeonMenuEntry<T>> items;

  /// Chamado com o valor da ação escolhida. `null` desliga o menu.
  final ValueChanged<T>? onSelected;

  /// Conteúdo que recebe o gesto.
  final Widget child;

  /// Override do accent. Default: `palette.primary`.
  final Color? accentColor;

  Future<void> _open(BuildContext context, Offset global) async {
    final T? value = await showNeonMenu<T>(
      context: context,
      items: items,
      accentColor: accentColor,
      position: neonMenuPositionAt(context, global),
    );
    if (value != null && context.mounted) {
      onSelected?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (onSelected == null) {
      return child;
    }
    return Semantics(
      onLongPress: () {
        final box = context.findRenderObject()! as RenderBox;
        _open(context, box.localToGlobal(box.size.center(Offset.zero)));
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onSecondaryTapUp: (TapUpDetails d) => _open(context, d.globalPosition),
        onLongPressStart: (LongPressStartDetails d) =>
            _open(context, d.globalPosition),
        child: child,
      ),
    );
  }
}
