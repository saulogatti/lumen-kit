import 'package:lumen_kit/src/foundation/lumen_upload_item.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_progress_indicator.dart';
import 'package:lumen_kit/src/widgets/lumen_status_chip.dart';
import 'package:material_ui/material_ui.dart';

LumenStatusTone _statusTone(LumenUploadStatus status) => switch (status) {
  LumenUploadStatus.pending => LumenStatusTone.neutral,
  LumenUploadStatus.uploading => LumenStatusTone.info,
  LumenUploadStatus.completed => LumenStatusTone.success,
  LumenUploadStatus.failed => LumenStatusTone.danger,
};

/// A list of file names, status labels, and upload percentages.
///
/// The app selects, receives, and uploads files. Each row listens to its
/// [LumenUploadItem]. Update [LumenUploadItem.progress], [LumenUploadItem.status],
/// and [LumenUploadItem.statusLabel] on that item. Rebuild this widget only
/// when [items] gains, loses, or replaces a file.
///
/// [LumenUploadItem.status] colors [LumenUploadItem.statusLabel]. The label
/// text comes from the app; an empty label is still shown. The visible
/// percentage clamps [LumenUploadItem.progress] to `0.0`–`1.0`, multiplies by
/// 100, rounds to an integer, and formats it with
/// [MaterialLocalizations.formatDecimal]. The progress bar announces the file
/// name and that percentage.
class LumenFileUpload extends StatelessWidget {
  /// Files in display order.
  ///
  /// Read when this widget builds. Later changes to an item's progress, status,
  /// or status label update that row without a new list.
  final List<LumenUploadItem> items;

  /// Creates an upload progress list.
  const LumenFileUpload({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final textTheme = Theme.of(context).textTheme;
    final localizations = MaterialLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: <Widget>[
        for (final item in items) _itemUpload(p, s, item, textTheme, localizations),
      ],
    );
  }

  Widget _itemUpload(
    LumenPalette p,
    LumenStyle s,
    LumenUploadItem item,
    TextTheme textTheme,
    MaterialLocalizations localizations,
  ) {
    return ListenableBuilder(
      listenable: item,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: p.surface.withValues(alpha: s.surfaceAlpha(0.45)),
            borderRadius: s.radius(12),
            border: s.borderAll(color: p.surfaceOutline.outlineAlpha(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: <Widget>[
                Row(
                  spacing: 8,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(color: p.textPrimary),
                      ),
                    ),
                    ExcludeSemantics(
                      child: Text(
                        '${localizations.formatDecimal((item.progress.clamp(0.0, 1.0) * 100).round())}%',
                        style: textTheme.labelMedium?.copyWith(color: p.textPrimary),
                      ),
                    ),
                  ],
                ),
                LumenLinearProgress(value: item.progress, semanticsLabel: item.name),
                Text(
                  item.statusLabel,
                  style: textTheme.bodySmall?.copyWith(color: _statusTone(item.status).colorOf(p)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
