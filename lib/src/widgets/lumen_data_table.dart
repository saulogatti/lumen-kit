import 'package:material_ui/material_ui.dart';

import '../foundation/lumen_pressable.dart';
import '../theme/lumen_palette.dart';
import '../theme/lumen_style.dart';

/// Themed wrapper about [DataTable].
///
/// Apply the theme colors, glow in the header and a subtle alternating line.
/// Accepts `columns`/`rows` directly from the API Material; Anyone who needs
/// something simpler can assemble it with [LumenTableRow] inside a [Column].
class LumenDataTable extends StatelessWidget {
  /// Create a [DataTable] with a neon visual theme.
  const LumenDataTable({
    required this.columns,
    required this.rows,
    super.key,
    this.accentColor,
    this.sortColumnIndex,
    this.sortAscending = true,
  });

  /// Columns passed to [DataTable.columns].
  final List<DataColumn> columns;

  /// Lines forwarded to [DataTable.rows].
  final List<DataRow> rows;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Index of the currently sorted column.
  final int? sortColumnIndex;

  /// Whether to indicate ascending sorting.
  final bool sortAscending;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final LumenStyle style = LumenStyle.of(context);
    final Color accent = accentColor ?? p.primary;

    return Container(
      decoration: BoxDecoration(
        color: p.surface.withValues(alpha: style.surfaceAlpha(0.5)),
        borderRadius: style.radius(16),
        border: style.borderAll(color: p.surfaceOutline.outlineAlpha(0.6)),
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

/// "By hand" line for those who want to compose a light table without
/// [DataTable] (ex: inside cards).
///
/// Each cell is a widget and configurable flex.
class LumenTableRow extends StatelessWidget {
  /// Creates a flexible row for manual table composition.
  const LumenTableRow({
    required this.cells,
    super.key,
    this.isHeader = false,
    this.onTap,
    this.flex,
    this.accentColor,
  });

  /// Cells displayed in the row.
  final List<Widget> cells;

  /// Whether to apply header visual style and disables ringing.
  final bool isHeader;

  /// Callback executed when touching the line.
  /// Ignored when [isHeader] is `true`.
  final VoidCallback? onTap;

  /// Same cardinality as [cells]; default all with flex 1.
  final List<int>? flex;

  /// Highlight color override.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.primary;
    final List<int> flexValues = flex ?? List<int>.filled(cells.length, 1);

    final Widget row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isHeader ? accent.withValues(alpha: 0.1) : null,
        border: Border(
          bottom: BorderSide(color: p.surfaceOutline.outlineAlpha(0.35)),
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

    if (onTap == null || isHeader) {
      return row;
    }
    return LumenPressable(onTap: onTap, child: row);
  }
}
