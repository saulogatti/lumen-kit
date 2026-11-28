import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_icon_button.dart';
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
  /// [name] is displayed and announced with the progress. [status] determines
  /// the label color, not its text; [statusLabel] is supplied by the app.
  /// [progress] defaults to `0` and is independent of [status].
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
/// Set [onRemove] to show a remove button on every row and [onRetry] to show
/// a retry button on rows whose status is [LumenUploadStatus.failed]. Both
/// receive the row index in [items]. The app updates its list and rebuilds
/// this widget; the kit neither removes the item nor restarts the upload.
///
/// ```dart
/// LumenFileUpload(
///   items: _files,
///   onRemove: (index) => setState(() => _files = [..._files]..removeAt(index)),
///   onRetry: (index) => uploads.restart(_files[index]),
/// )
/// ```
class LumenFileUpload extends StatelessWidget {
  /// Files in display order.
  final List<LumenUploadItem> items;

  /// Called with a row index when its remove button is pressed.
  ///
  /// `null` hides the remove button on every row.
  final ValueChanged<int>? onRemove;

  /// Called with a row index when its retry button is pressed.
  ///
  /// The button only appears on rows with [LumenUploadStatus.failed]. `null`
  /// hides it.
  final ValueChanged<int>? onRetry;

  /// Tooltip of the remove button.
  ///
  /// Screen readers announce it followed by the file name, as in
  /// `Remove report.pdf`, so each row's button has a distinct label.
  final String removeLabel;

  /// Tooltip of the retry button.
  ///
  /// Screen readers announce it followed by the file name, as in
  /// `Retry report.pdf`, so each row's button has a distinct label.
  final String retryLabel;

  /// Creates an upload progress list.
  ///
  /// [removeLabel] and [retryLabel] default to English text; pass localized
  /// strings when the app uses another language.
  /// [items] supplies the rows in display order. [onRemove], when provided,
  /// shows a remove button on every row; [onRetry] shows a retry button only
  /// for failed rows. Each callback receives the row index, and the app owns
  /// the resulting list or upload updates. Both callbacks default to `null`.
  /// The labels default to `Remove` and `Retry` respectively, serve as
  /// tooltips, and are announced with the file name. [key] identifies the
  /// widget in the tree.
  const LumenFileUpload({
    required this.items,
    super.key,
    this.onRemove,
    this.onRetry,
    this.removeLabel = 'Remove',
    this.retryLabel = 'Retry',
  });

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
        for (var index = 0; index < items.length; index++)
          _itemUpload(p, s, index, items[index], textTheme, localizations),
      ],
    );
  }

  Widget _itemUpload(
    LumenPalette p,
    LumenStyle s,
    int index,
    LumenUploadItem item,
    TextTheme textTheme,
    MaterialLocalizations localizations,
  ) {
    final retry = onRetry;
    final remove = onRemove;
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
                if (retry != null && item.status == LumenUploadStatus.failed)
                  _action(
                    key: const ValueKey<String>('retry'),
                    icon: Icons.refresh,
                    tooltip: retryLabel,
                    semanticLabel: '$retryLabel ${item.name}',
                    onPressed: () => retry(index),
                  ),
                if (remove != null)
                  _action(
                    key: const ValueKey<String>('remove'),
                    icon: Icons.close,
                    tooltip: removeLabel,
                    semanticLabel: '$removeLabel ${item.name}',
                    accentColor: p.textSecondary,
                    onPressed: () => remove(index),
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

/// Row action button.
///
/// [tooltip] is the short text shown on hover and long press. [semanticLabel]
/// goes on the focusable button node. [key] keeps each button's element, and
/// so its keyboard focus, when the other button of the row appears or goes.
Widget _action({
  required Key key,
  required IconData icon,
  required String tooltip,
  required String semanticLabel,
  required VoidCallback onPressed,
  Color? accentColor,
}) => Tooltip(
  key: key,
  message: tooltip,
  excludeFromSemantics: true,
  child: LumenIconButton.ghost(
    icon: icon,
    semanticLabel: semanticLabel,
    accentColor: accentColor,
    size: 36,
    iconSize: 18,
    onPressed: onPressed,
  ),
);
