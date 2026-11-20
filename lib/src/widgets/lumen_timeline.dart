import 'package:flutter/semantics.dart';
import 'package:lumen_kit/src/foundation/lumen_decorations.dart';
import 'package:lumen_kit/src/foundation/lumen_pressable.dart';
import 'package:lumen_kit/src/foundation/lumen_tokens.dart';
import 'package:lumen_kit/src/theme/lumen_palette.dart';
import 'package:lumen_kit/src/theme/lumen_style.dart';
import 'package:lumen_kit/src/widgets/lumen_status_chip.dart';
import 'package:material_ui/material_ui.dart';

/// Builds the [LumenTimelineEntry] at [index] for [LumenTimeline.builder].
typedef LumenTimelineEntryBuilder = LumenTimelineEntry Function(BuildContext context, int index);

/// One event shown by [LumenTimeline].
///
/// The kit doesn't format dates: pass [timestamp] already formatted by the
/// app (`'Nov 12, 10:42'`, `'2 h ago'`…).
class LumenTimelineEntry {
  /// Creates a timeline event with [title].
  const LumenTimelineEntry({
    required this.title,
    this.subtitle,
    this.description,
    this.timestamp,
    this.icon,
    this.tone,
    this.accentColor,
    this.child,
    this.onTap,
  });

  /// Main text of the event (e.g. `'Pending → Approved'`).
  final String title;

  /// Short secondary line below [title] (e.g. who made the change).
  final String? subtitle;

  /// Longer text below [subtitle] (e.g. notes or a change summary).
  ///
  /// Wraps over as many lines as it needs.
  final String? description;

  /// Time of the event, already formatted by the app.
  ///
  /// Shown at the end of the [title] line.
  final String? timestamp;

  /// Icon inside the marker.
  ///
  /// When `null`, the marker is a dot.
  final IconData? icon;

  /// Semantic tone that colors the marker from the active palette.
  ///
  /// Ignored when [accentColor] is set.
  final LumenStatusTone? tone;

  /// Marker and highlight color override for this event.
  ///
  /// Default: the color of [tone], then [LumenTimeline.accentColor], then
  /// `palette.primary`.
  final Color? accentColor;

  /// Extra content below the texts (status chip, button row…).
  ///
  /// Controls inside it stay separate nodes for screen readers.
  final Widget? child;

  /// Called when the event is tapped.
  ///
  /// When `null`, the event is informational and doesn't react to touch.
  final VoidCallback? onTap;
}

/// Vertical list of events with markers joined by a line, for order and
/// activity history.
///
/// The default constructor lays the events out in a [Column] that doesn't
/// scroll, so it fits inside cards, panels and dialogs. Use
/// [LumenTimeline.builder] for long histories: it builds events on demand
/// inside its own scroll view.
///
/// The app passes the events already sorted; events are drawn in list order.
/// [highlightedIndex] marks the current or most recent event, so it works for
/// both orders: `0` when the newest is on top, `entries.length - 1` when it's
/// at the bottom.
///
/// Screen readers announce each event as one item with its title, timestamp,
/// subtitle and description, in that order.
///
/// ```dart
/// LumenTimeline(
///   highlightedIndex: 0,
///   entries: <LumenTimelineEntry>[
///     for (final change in history)
///       LumenTimelineEntry(
///         title: change.label,
///         subtitle: change.authorName,
///         description: change.notes,
///         timestamp: formatDate(change.changedAt),
///         tone: change.isCanceled ? LumenStatusTone.danger : LumenStatusTone.success,
///       ),
///   ],
/// )
/// ```
class LumenTimeline extends StatelessWidget {
  /// Creates a non-scrolling timeline that shows every event in `entries`.
  const LumenTimeline({
    required List<LumenTimelineEntry> this._entries,
    super.key,
    this.highlightedIndex,
    this.accentColor,
    this.spacing = 4,
  }) : _itemCount = null,
       _entryBuilder = null,
       controller = null,
       padding = null,
       shrinkWrap = false,
       physics = null;

  /// Creates a scrolling timeline that builds the event at each index on
  /// demand with `entryBuilder`, for `itemCount` events.
  ///
  /// Give it a bounded height, or set [shrinkWrap] when it sits inside
  /// another scroll view.
  const LumenTimeline.builder({
    required int this._itemCount,
    required LumenTimelineEntryBuilder this._entryBuilder,
    super.key,
    this.highlightedIndex,
    this.accentColor,
    this.spacing = 4,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : _entries = null;

  final List<LumenTimelineEntry>? _entries;
  final int? _itemCount;
  final LumenTimelineEntryBuilder? _entryBuilder;

  /// Index of the event drawn as current: stronger marker, tinted surface and
  /// glow.
  ///
  /// `null` (or an index outside the list) highlights nothing.
  final int? highlightedIndex;

  /// Default marker color for events without their own `tone` or
  /// `accentColor`.
  ///
  /// Default: `palette.primary`.
  final Color? accentColor;

  /// Vertical space between two events. The connecting line crosses it.
  final double spacing;

  /// Scroll controller. Only used by [LumenTimeline.builder].
  final ScrollController? controller;

  /// Space around the events inside the scroll view. Only used by
  /// [LumenTimeline.builder].
  final EdgeInsetsGeometry? padding;

  /// Whether the scroll view sizes itself to its events. Only used by
  /// [LumenTimeline.builder].
  final bool shrinkWrap;

  /// Scroll physics. Only used by [LumenTimeline.builder].
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (_entries case final List<LumenTimelineEntry> entries) {
      return Semantics(
        container: true,
        role: SemanticsRole.list,
        explicitChildNodes: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (var i = 0; i < entries.length; i++) _tile(entries[i], i, entries.length, true),
          ],
        ),
      );
    }
    final count = _itemCount!;
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: count,
      itemBuilder: (context, i) => _tile(_entryBuilder!(context, i), i, count, false),
    );
  }

  Widget _tile(LumenTimelineEntry entry, int index, int count, bool listItem) => _TimelineTile(
    entry: entry,
    isFirst: index == 0,
    isLast: index == count - 1,
    highlighted: index == highlightedIndex,
    defaultAccent: accentColor,
    spacing: spacing,
    listItem: listItem,
  );
}

const double _kRailWidth = 28;
const double _kMarkerTop = 4;
const double _kLineWidth = 2;

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.highlighted,
    required this.defaultAccent,
    required this.spacing,
    required this.listItem,
  });

  final LumenTimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final bool highlighted;
  final Color? defaultAccent;
  final double spacing;
  final bool listItem;

  @override
  Widget build(BuildContext context) {
    final p = LumenThemeExt.of(context).palette;
    final style = LumenStyle.of(context);
    final accent = entry.accentColor ?? entry.tone?.colorOf(p) ?? defaultAccent ?? p.primary;
    final lineColor = p.surfaceOutline.outlineAlpha(0.6);
    const markerCenter = _kMarkerTop + _kRailWidth / 2;
    const lineLeft = (_kRailWidth - _kLineWidth) / 2;

    Widget content = AnimatedContainer(
      duration: LumenMotion.duration(context, kLumenFastDuration),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: LumenDecorations.selectable(
        p,
        style,
        accent: accent,
        selected: highlighted,
        fillAlpha: 0.1,
        borderAlpha: 0.45,
        // A shadow shows through the translucent fill (solid in brutal, grey in
        // flat); the marker carries the glow instead.
        glow: false,
      ),
      child: _TimelineContent(entry: entry, palette: p, highlighted: highlighted),
    );
    if (entry.onTap case final VoidCallback onTap) {
      content = LumenPressable(
        onTap: onTap,
        borderRadius: style.radius(12),
        // A child may hold its own controls; keep them as separate nodes.
        mergeSemantics: entry.child == null,
        child: content,
      );
    }

    return Semantics(
      container: true,
      role: listItem ? SemanticsRole.listItem : null,
      child: Stack(
        children: <Widget>[
          if (!isFirst)
            Positioned(
              top: 0,
              height: markerCenter,
              left: lineLeft,
              width: _kLineWidth,
              child: ColoredBox(color: lineColor),
            ),
          if (!isLast)
            Positioned(
              top: markerCenter,
              bottom: 0,
              left: lineLeft,
              width: _kLineWidth,
              child: ColoredBox(color: lineColor),
            ),
          Positioned(
            top: _kMarkerTop,
            left: 0,
            child: _Marker(icon: entry.icon, accent: accent, palette: p, highlighted: highlighted),
          ),
          Padding(
            padding: EdgeInsets.only(left: _kRailWidth + 4, bottom: isLast ? 0 : spacing),
            child: content,
          ),
        ],
      ),
    );
  }
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({required this.entry, required this.palette, required this.highlighted});

  final LumenTimelineEntry entry;
  final LumenPalette palette;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 12,
          children: <Widget>[
            Expanded(
              child: Text(
                entry.title,
                style: text.titleSmall?.copyWith(
                  color: p.textPrimary,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            if (entry.timestamp case final String timestamp)
              Text(timestamp, style: text.labelSmall?.copyWith(color: p.textMuted)),
          ],
        ),
        if (entry.subtitle case final String subtitle)
          Text(subtitle, style: text.labelMedium?.copyWith(color: p.textMuted)),
        if (entry.description case final String description)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(description, style: text.bodyMedium?.copyWith(color: p.textSecondary)),
          ),
        if (entry.child case final Widget child)
          Padding(padding: const EdgeInsets.only(top: 8), child: child),
      ],
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.icon,
    required this.accent,
    required this.palette,
    required this.highlighted,
  });

  final IconData? icon;
  final Color accent;
  final LumenPalette palette;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final style = LumenStyle.of(context);
    final glow = style.shadows(
      highlighted
          ? <BoxShadow>[
              BoxShadow(color: accent.withValues(alpha: 0.55), blurRadius: 12, spreadRadius: -2),
            ]
          : null,
    );
    final duration = LumenMotion.duration(context, kLumenMediumDuration);
    final Widget marker;
    if (icon case final IconData icon) {
      // Opaque fill: the line and the glow must not show through the marker.
      final base = palette.backgroundDeep.withValues(alpha: 1);
      marker = AnimatedContainer(
        duration: duration,
        width: _kRailWidth,
        height: _kRailWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.alphaBlend(
            highlighted ? accent.withValues(alpha: 0.22) : palette.surface,
            base,
          ),
          border: style.borderAll(
            color: highlighted ? accent : accent.withValues(alpha: 0.55),
            width: highlighted ? 2 : 1.4,
          ),
          boxShadow: glow,
        ),
        child: Icon(icon, size: 14, color: accent),
      );
    } else {
      marker = SizedBox.square(
        dimension: _kRailWidth,
        child: Center(
          child: AnimatedContainer(
            duration: duration,
            width: highlighted ? 14 : 10,
            height: highlighted ? 14 : 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              border: style.borderAll(
                color: highlighted ? palette.backgroundDeep : accent,
                width: highlighted ? 2.5 : 1,
              ),
              boxShadow: glow,
            ),
          ),
        ),
      );
    }
    // The marker repeats the entry's color; the texts carry the meaning.
    return ExcludeSemantics(child: marker);
  }
}
