import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_progress_indicator.dart';
import 'package:lumen_kit/src/widgets/lumen_status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Color key for a file's [LumenUploadItem.statusLabel] in a [LumenFileUpload] row.
///
/// The label text comes from the app. These values only choose its color.
enum LumenUploadStatus {
  /// Waiting to upload. The label uses the muted text color.
  pending,

  /// Upload in progress. The label uses the primary color.
  uploading,

  /// Upload finished successfully. The label uses the success color.
  completed,

  /// Upload failed. The label uses the danger color.
  failed;

  LumenStatusTone get _tone => switch (this) {
    pending => LumenStatusTone.neutral,
    uploading => LumenStatusTone.info,
    completed => LumenStatusTone.success,
    failed => LumenStatusTone.danger,
  };
}

/// The name, status label, and progress of one file in a [LumenFileUpload].
///
/// Immutable. To update a row, rebuild [LumenFileUpload] with a new list,
/// replacing the item with one made by [copyWith]. [status] selects the label
/// color. [statusLabel] is the text and is not derived from [status].
class LumenUploadItem {
  /// File name displayed in the row and announced with its progress.
  final String name;

  /// State used to color [statusLabel].
  final LumenUploadStatus status;

  /// App-provided status text, including any error details to show.
  ///
  /// Independent of [status]. The upload row shows this string as given.
  final String statusLabel;

  /// Upload fraction from `0.0` to `1.0`, independent of [status].
  final double progress;

  /// Describes a file, its status label, and its reported progress.
  ///
  /// [progress] must be from `0.0` to `1.0` inclusive. A value outside that
  /// range, including `NaN`, throws an assertion error when assertions are
  /// enabled. Otherwise the row clamps the value it displays. [status] defaults
  /// to [LumenUploadStatus.pending]. [statusLabel] defaults to an empty string.
  const LumenUploadItem({
    required this.name,
    this.status = LumenUploadStatus.pending,
    this.statusLabel = '',
    this.progress = 0,
  }) : assert(progress >= 0 && progress <= 1, 'Progress must be between 0 and 1 inclusive');

  /// Returns a copy with the given fields replaced.
  ///
  /// [progress] follows the same rule as the constructor.
  LumenUploadItem copyWith({
    String? name,
    LumenUploadStatus? status,
    String? statusLabel,
    double? progress,
  }) => LumenUploadItem(
    name: name ?? this.name,
    status: status ?? this.status,
    statusLabel: statusLabel ?? this.statusLabel,
    progress: progress ?? this.progress,
  );
}

/// A list of file names, status labels, and upload percentages.
///
/// The app selects, receives, and uploads files, and rebuilds this widget with
/// new [items] whenever a file's progress, status, or label changes.
///
/// [LumenUploadItem.status] colors [LumenUploadItem.statusLabel]. The label
/// text comes from the app; an empty label is still shown. The visible
/// percentage clamps [LumenUploadItem.progress] to `0.0`–`1.0`, multiplies by
/// 100, rounds to an integer, and formats it with
/// [MaterialLocalizations.formatDecimal]. The progress bar announces the file
/// name and that percentage.
///
/// ```dart
/// LumenFileUpload(
///   items: <LumenUploadItem>[
///     const LumenUploadItem(
///       name: 'invoice.pdf',
///       status: LumenUploadStatus.uploading,
///       statusLabel: 'Uploading',
///       progress: 0.65,
///     ),
///   ],
/// )
/// ```
class LumenFileUpload extends StatelessWidget {
  /// Files in display order.
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
              style: textTheme.bodySmall?.copyWith(color: item.status._tone.colorOf(p)),
            ),
          ],
        ),
      ),
    );
  }
}
