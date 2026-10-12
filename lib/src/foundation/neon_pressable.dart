import 'package:material_ui/material_ui.dart';

import 'neon_tokens.dart';

/// Base tocável do kit: aplica a opacidade de desabilitado, o ripple recortado
/// em [borderRadius], foco de teclado e semântica de botão.
///
/// Use para construir componentes próprios com o mesmo comportamento dos
/// botões do kit:
///
/// ```dart
/// NeonPressable(
///   onTap: save,
///   borderRadius: NeonStyle.of(context).radius(14),
///   child: myDecoratedBox,
/// )
/// ```
class NeonPressable extends StatelessWidget {
  /// Cria uma área tocável. Fica desabilitada quando [onTap] e [onLongPress]
  /// são `null` ou [enabled] é `false`.
  const NeonPressable({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.borderRadius,
    this.customBorder,
    this.dimWhenDisabled = true,
    this.semanticLabel,
    this.button = true,
    this.selected,
    this.checked,
    this.toggled,
    this.mergeSemantics = true,
  });

  /// Conteúdo visual.
  final Widget child;

  /// Callback de toque.
  final VoidCallback? onTap;

  /// Callback de toque longo.
  final VoidCallback? onLongPress;

  /// Força o estado desabilitado mesmo com callbacks presentes (ex.: `busy`).
  final bool enabled;

  /// Raio usado no recorte do ripple e do [Material].
  final BorderRadius? borderRadius;

  /// Forma alternativa ao [borderRadius] (ex.: [CircleBorder]).
  final ShapeBorder? customBorder;

  /// Se `true`, aplica [kNeonDisabledOpacity] quando desabilitado.
  final bool dimWhenDisabled;

  /// Rótulo de acessibilidade, somado ao texto dos filhos. Use quando o
  /// conteúdo não tem texto (ex.: só ícone).
  final String? semanticLabel;

  /// Anuncia o widget como botão para leitores de tela.
  final bool button;

  /// Estado de seleção anunciado (abas, itens de navegação).
  final bool? selected;

  /// Estado marcado anunciado (checkbox, radio).
  final bool? checked;

  /// Estado ligado anunciado (switch).
  final bool? toggled;

  /// Junta os textos dos filhos num único nó (como o `ListTile` faz), para o
  /// leitor de tela ler "Aceito, marcado" em vez de dois itens. Desligue
  /// quando o filho tiver outros controles dentro (ex.: card com botões).
  final bool mergeSemantics;

  /// Se o widget responde a toque com as props atuais.
  bool get isEnabled => enabled && (onTap != null || onLongPress != null);

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled;
    final Widget ink = Material(
      type: MaterialType.transparency,
      borderRadius: customBorder == null ? borderRadius : null,
      shape: customBorder,
      child: InkWell(
        onTap: active ? onTap : null,
        onLongPress: active ? onLongPress : null,
        borderRadius: borderRadius,
        customBorder: customBorder,
        // A semântica vem do Semantics abaixo; evita nó duplicado.
        excludeFromSemantics: true,
        child: child,
      ),
    );

    final Widget semantics = Semantics(
      container: true,
      button: button && checked == null && toggled == null ? true : null,
      enabled: active,
      selected: selected,
      checked: checked,
      toggled: toggled,
      label: semanticLabel,
      onTap: active ? onTap : null,
      onLongPress: active ? onLongPress : null,
      child: dimWhenDisabled && !active
          ? Opacity(opacity: kNeonDisabledOpacity, child: ink)
          : ink,
    );
    return mergeSemantics ? MergeSemantics(child: semantics) : semantics;
  }
}
