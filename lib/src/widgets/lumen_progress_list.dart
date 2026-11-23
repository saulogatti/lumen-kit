import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/widgets/lumen_progress_indicator.dart';
import 'package:material_ui/material_ui.dart';

/// A named task and its app-owned progress source.
class LumenProgressItem {
  /// Creates a task for a [LumenProgressList].
  const LumenProgressItem({required this.label, required this.progress});

  /// Task name displayed in the row and announced with the progress bar.
  final String label;

  /// Fraction completed from 0 to 1, or null while the total is unknown.
  final ValueListenable<double?> progress;
}

/// A scrollable list of tasks with independently updated progress bars.
///
/// Give the list a bounded height with [SizedBox] or [Expanded]. Rows are
/// built on demand and read the current progress as they enter the viewport.
/// Keep each source in the app's controller and dispose it when finished.
/// Rebuild the list when task labels, membership, or order change.
///
/// ```dart
/// // Keep this notifier in the controller and update it as work completes.
/// final indexing = ValueNotifier<double?>(0);
/// final list = SizedBox(
///   height: 200,
///   child: LumenProgressList(
///     items: [LumenProgressItem(label: 'Index records', progress: indexing)],
///   ),
/// );
/// indexing.value = 0.65;
/// ```
class LumenProgressList extends StatelessWidget {
  /// Creates a vertically scrolling task list.
  const LumenProgressList({required this.items, super.key});

  /// Tasks in display order.
  final List<LumenProgressItem> items;

  @override
  Widget build(BuildContext context) => ListView.builder(
    primary: false,
    padding: EdgeInsets.zero,
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      final palette = LumenThemeExt.of(context).palette;
      final textTheme = Theme.of(context).textTheme;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ValueListenableBuilder<double?>(
          valueListenable: item.progress,
          builder: (context, value, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        item.label,
                        style: textTheme.titleSmall?.copyWith(color: palette.textPrimary),
                      ),
                    ),
                  ),
                  if (value != null)
                    ExcludeSemantics(
                      child: Text(
                        '${MaterialLocalizations.of(context).formatDecimal((value.clamp(0.0, 1.0) * 100).round())}%',
                        style: textTheme.labelMedium?.copyWith(color: palette.textSecondary),
                      ),
                    ),
                ],
              ),
              LumenLinearProgress(value: value, semanticsLabel: item.label),
            ],
          ),
        ),
      );
    },
  );
}
