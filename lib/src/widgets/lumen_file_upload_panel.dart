import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_button.dart';
import 'package:lumen_kit/src/widgets/lumen_file_upload.dart';
import 'package:material_ui/material_ui.dart';

/// A framed upload area: icon, title, hint, an add button, and the
/// [LumenFileUpload] list below.
///
/// The panel only draws. The app decides how files arrive: [onPick] opens the
/// picker the app chooses (`file_picker`, camera, a dialog), and [highlighted]
/// is set by the app's own drop handler while a drag is over the panel. The kit
/// adds no picker or drop dependency and does not know about single or
/// multiple selection.
///
/// [items], [onRemove], [onRetry], [removeLabel], and [retryLabel] are passed
/// to [LumenFileUpload]. The list is omitted while [items] is empty.
///
/// ```dart
/// LumenFileUploadPanel(
///   title: 'Attach documents',
///   hint: 'PDF or PNG, up to 10 MB',
///   actionLabel: 'Choose files',
///   onPick: _pickFiles,
///   busy: _opening,
///   highlighted: _dragging,
///   items: _files,
///   onRemove: (index) => setState(() => _files = [..._files]..removeAt(index)),
/// )
/// ```
class LumenFileUploadPanel extends StatelessWidget {
  /// Heading shown under the icon.
  final String title;

  /// Supporting text under [title], such as accepted types and size limit.
  ///
  /// `null` omits it.
  final String? hint;

  /// Icon at the top of the panel.
  final IconData icon;

  /// Text of the add button.
  final String actionLabel;

  /// Icon before [actionLabel].
  final IconData actionIcon;

  /// Called when the add button is pressed. The app opens its picker here.
  ///
  /// `null` disables the button with [kLumenDisabledOpacity].
  final VoidCallback? onPick;

  /// Whether the add button shows the inline spinner and ignores presses.
  ///
  /// Use it while the app's picker is open or files are being read.
  final bool busy;

  /// Whether to draw the drag-over state: accent border, tinted fill, and glow.
  ///
  /// The app sets it from its own drop handler. Changes animate over
  /// [kLumenFastDuration] unless the system asks to reduce animations.
  final bool highlighted;

  /// Files shown in the [LumenFileUpload] list, in display order.
  final List<LumenUploadItem> items;

  /// Passed to [LumenFileUpload.onRemove].
  final ValueChanged<int>? onRemove;

  /// Passed to [LumenFileUpload.onRetry].
  final ValueChanged<int>? onRetry;

  /// Passed to [LumenFileUpload.removeLabel].
  final String removeLabel;

  /// Passed to [LumenFileUpload.retryLabel].
  final String retryLabel;

  /// Accent of the icon, the add button, and the drag-over state.
  ///
  /// Default: [LumenPalette.primary].
  final Color? accentColor;

  /// Creates an upload panel.
  ///
  /// [onPick] is required so the app states whether adding is available;
  /// pass `null` to disable it.
  const LumenFileUploadPanel({
    required this.title,
    required this.actionLabel,
    required this.onPick,
    super.key,
    this.hint,
    this.icon = Icons.cloud_upload_outlined,
    this.actionIcon = Icons.add,
    this.busy = false,
    this.highlighted = false,
    this.items = const <LumenUploadItem>[],
    this.onRemove,
    this.onRetry,
    this.removeLabel = 'Remove',
    this.retryLabel = 'Retry',
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final s = LumenStyle.of(context);
    final textTheme = Theme.of(context).textTheme;
    final accent = accentColor ?? p.primary;
    final duration = LumenMotion.duration(context, kLumenFastDuration);

    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlighted
            ? accent.withValues(alpha: 0.1)
            : p.surface.withValues(alpha: s.surfaceAlpha(0.35)),
        borderRadius: s.radius(16),
        border: s.borderAll(
          color: highlighted ? accent.withValues(alpha: 0.9) : p.surfaceOutline.outlineAlpha(0.5),
          width: highlighted ? 1.6 : 1.2,
        ),
        boxShadow: s.shadows(
          highlighted
              ? <BoxShadow>[BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 22)]
              : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: <Widget>[
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(12),
                decoration: LumenDecorations.iconBox(
                  s,
                  accent: accent,
                  radius: 14,
                  fillAlpha: highlighted ? 0.24 : 0.12,
                  borderAlpha: highlighted ? 0.8 : 0.45,
                ),
                child: Icon(icon, size: 28, color: accent),
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: p.textPrimary),
              ),
              if (hint case final hint?)
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: p.textSecondary),
                ),
              const SizedBox(height: 4),
              LumenButton.outline(
                label: actionLabel,
                icon: actionIcon,
                busy: busy,
                accentColor: accentColor,
                onPressed: onPick,
              ),
            ],
          ),
          if (items.isNotEmpty)
            LumenFileUpload(
              items: items,
              onRemove: onRemove,
              onRetry: onRetry,
              removeLabel: removeLabel,
              retryLabel: retryLabel,
            ),
        ],
      ),
    );
  }
}
