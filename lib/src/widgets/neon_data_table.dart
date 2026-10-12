import 'package:material_ui/material_ui.dart';

import '../foundation/neon_pressable.dart';
import '../theme/neon_palette.dart';
import '../theme/neon_style.dart';

/// Wrapper temático sobre [DataTable]. Aplica as cores do tema, glow no header
/// e uma linha alternada sutil. Aceita `columns`/`rows` direto da API do
/// Material; quem precisar de algo mais simples pode montar com
/// [NeonTableRow] dentro de uma [Column].
class NeonDataTable extends StatelessWidget {
  /// Colunas repassadas para [DataTable.columns].
  final List<DataColumn> columns;

  /// Linhas repassadas para [DataTable.rows].
  final List<DataRow> rows;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Índice da coluna atualmente ordenada.
  final int? sortColumnIndex;

  /// Se `true`, indica ordenação ascendente.
  final bool sortAscending;

  /// Cria uma [DataTable] com o tema visual neon.
  const NeonDataTable({
    required this.columns,
    required this.rows,
    super.key,
    this.accentColor,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final NeonStyle style = NeonStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Container(
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.5)),
        borderRadius: style.radius(16),
        border: style.borderAll(color: p.surfaceOutline.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            accent.withValues(alpha: 0.1),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            if (s.contains(WidgetState.selected)) {
              return accent.withValues(alpha: 0.16);
            }
            return null;
          }),
          headingTextStyle: TextStyle(
            color: p.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          dataTextStyle: TextStyle(color: p.textSecondary),
          dividerThickness: 0.6,
          decoration: BoxDecoration(
            border: style.borderAll(color: Colors.transparent),
          ),
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          columns: columns,
          rows: rows,
        ),
      ),
    );
  }
}

/// Linha "à mão" para quem quer compor uma tabela leve sem [DataTable] (ex:
/// dentro de cartões). Cada célula é um widget e flex configurável.
class NeonTableRow extends StatelessWidget {
  /// Células exibidas na linha.
  final List<Widget> cells;

  /// Se `true`, aplica estilo visual de cabeçalho e desativa o toque.
  final bool isHeader;

  /// Callback executado ao tocar na linha.
  ///
  /// Ignorado quando [isHeader] é `true`.
  final VoidCallback? onTap;

  /// Mesma cardinalidade de [cells]; default todas com flex 1.
  final List<int>? flex;

  /// Override da cor de destaque. Default: `palette.primary`.
  final Color? accentColor;

  /// Cria uma linha flexível para composição manual de tabelas.
  const NeonTableRow({
    required this.cells,
    super.key,
    this.isHeader = false,
    this.onTap,
    this.flex,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
    final List<int> flexValues = flex ?? List<int>.filled(cells.length, 1);

    final Widget row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHeader ? accent.withValues(alpha: 0.1) : null,
        border: Border(
          bottom: BorderSide(color: p.surfaceOutline.withValues(alpha: 0.35)),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: isHeader ? p.textPrimary : p.textSecondary,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          letterSpacing: isHeader ? 0.4 : 0,
        ),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < cells.length; i++)
              Expanded(flex: flexValues[i], child: cells[i]),
          ],
        ),
      ),
    );

    if (onTap == null || isHeader) return row;
    return NeonPressable(onTap: onTap, child: row);
  }
}
