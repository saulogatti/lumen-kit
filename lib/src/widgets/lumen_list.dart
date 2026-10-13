import 'package:material_ui/material_ui.dart';

/// Lista preguiçosa para muitos itens. O corpo é um [ListView.builder]: só
/// o que está na tela é construído.
///
/// Com [itemCount] `0`, mostra [empty] (ou nada, se [empty] for `null`).
/// A altura vem do pai. Não use `shrinkWrap` aqui: numa lista longa isso
/// constrói todos os filhos e anula o builder.
///
/// ```dart
/// LumenList(
///   itemCount: eventos.length,
///   empty: const LumenEmptyState(title: 'Nenhum evento'),
///   itemBuilder: (BuildContext context, int i) => LumenListTile(
///     title: eventos[i].titulo,
///     onTap: () => abrir(eventos[i]),
///   ),
/// )
/// ```
class LumenList extends StatelessWidget {
  /// Cria a lista. [itemBuilder] só é chamado para índices visíveis.
  const LumenList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.separatorBuilder,
    this.controller,
    this.empty,
    this.padding,
  });

  /// Quantidade de itens. `0` mostra [empty].
  final int itemCount;

  /// Constrói o item em [index]. Em geral um `LumenListTile`.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Widget entre dois itens. Sem ele, os itens ficam colados.
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Controller opcional da rolagem.
  final ScrollController? controller;

  /// Conteúdo quando [itemCount] é `0`.
  final Widget? empty;

  /// Espaço interno da lista.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) {
      return empty ?? const SizedBox.shrink();
    }
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder!,
      );
    }
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
