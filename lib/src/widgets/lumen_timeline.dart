import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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
    final Widget title = Text(
      entry.title,
      style: text.titleSmall?.copyWith(
        color: p.textPrimary,
        fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: <Widget>[
        if (entry.timestamp case final String timestamp)
          _TitleRow(
            textDirection: Directionality.of(context),
            children: <Widget>[
              title,
              Text(
                timestamp,
                textAlign: TextAlign.end,
                style: text.labelSmall?.copyWith(color: p.textMuted),
              ),
            ],
          )
        else
          title,
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

/// Share of the width the timestamp may take before it wraps.
const double _kTimestampMaxFraction = 0.4;
const double _kTitleGap = 12;

/// Title and timestamp on one line, aligned by baseline, with the timestamp at
/// the end.
///
/// A long localized time or a large text scale can't push the line past its
/// box:
/// - both texts fit on one line: nothing wraps;
/// - otherwise the timestamp takes at most [_kTimestampMaxFraction] of the
///   width (but never less than its longest word) and wraps; the title takes
///   the rest and wraps too;
/// - not even the longest word of each fits side by side: the timestamp goes
///   below the title, still at the end.
///
/// A `Row` can't cap a non-flex child by a share of its width, and a
/// `LayoutBuilder` would break intrinsic sizing (`AlertDialog` wraps its
/// content in `IntrinsicWidth`).
class _TitleRow extends MultiChildRenderObjectWidget {
  const _TitleRow({required this.textDirection, required super.children});

  final TextDirection textDirection;

  @override
  _RenderTitleRow createRenderObject(BuildContext context) =>
      _RenderTitleRow(textDirection: textDirection);

  @override
  void updateRenderObject(BuildContext context, _RenderTitleRow renderObject) =>
      renderObject.textDirection = textDirection;
}

class _TitleRowParentData extends ContainerBoxParentData<RenderBox> {
  // Same as the defaults; the class only gives the row its own parent data type.
}

class _RenderTitleRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _TitleRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _TitleRowParentData> {
  _RenderTitleRow({required this._textDirection});

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  RenderBox get _title => firstChild!;
  RenderBox get _time => lastChild!;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _TitleRowParentData) child.parentData = _TitleRowParentData();
  }

  /// Sizes the children for [constraints]; lays them out for real unless [dry].
  ({Size size, Offset title, Offset time}) _compute(
    BoxConstraints constraints, {
    required bool dry,
  }) {
    (Size, double) place(RenderBox child, BoxConstraints c) {
      if (dry) {
        final size = child.getDryLayout(c);
        return (size, child.getDryBaseline(c, TextBaseline.alphabetic) ?? size.height);
      }
      child.layout(c, parentUsesSize: true);
      return (
        child.size,
        child.getDistanceToBaseline(TextBaseline.alphabetic) ?? child.size.height,
      );
    }

    final maxWidth = constraints.maxWidth;
    final rtl = textDirection == TextDirection.rtl;
    final titleWord = _title.getMinIntrinsicWidth(double.infinity);
    final timeWord = _time.getMinIntrinsicWidth(double.infinity);

    if (titleWord + _kTitleGap + timeWord > maxWidth) {
      // Not even the longest words fit side by side: the timestamp goes below.
      final (titleSize, _) = place(_title, BoxConstraints(maxWidth: maxWidth));
      final (timeSize, _) = place(_time, BoxConstraints(maxWidth: maxWidth));
      final width = constraints.constrainWidth(maxWidth);
      final timeTop = titleSize.height + 2;
      return (
        size: constraints.constrain(Size(width, timeTop + timeSize.height)),
        title: Offset(rtl ? width - titleSize.width : 0, 0),
        time: Offset(rtl ? 0 : width - timeSize.width, timeTop),
      );
    }

    // When both texts fit on one line nothing wraps. Otherwise the timestamp
    // gets the share cap, but never less than its longest word nor so much that
    // the title's longest word stops fitting.
    final leftByTitle = maxWidth - _kTitleGap - _title.getMaxIntrinsicWidth(double.infinity);
    final timeMax = math
        .max(maxWidth * _kTimestampMaxFraction, leftByTitle)
        .clamp(timeWord, maxWidth - _kTitleGap - titleWord);
    final (timeSize, timeBaseline) = place(_time, BoxConstraints(maxWidth: timeMax));
    final (titleSize, titleBaseline) = place(
      _title,
      BoxConstraints(maxWidth: maxWidth - timeSize.width - _kTitleGap),
    );
    final width = constraints.constrainWidth(
      maxWidth.isFinite ? maxWidth : titleSize.width + _kTitleGap + timeSize.width,
    );
    final baseline = math.max(titleBaseline, timeBaseline);
    final titleTop = baseline - titleBaseline;
    final timeTop = baseline - timeBaseline;
    final height = math.max(titleTop + titleSize.height, timeTop + timeSize.height);
    return (
      size: constraints.constrain(Size(width, height)),
      title: Offset(rtl ? width - titleSize.width : 0, titleTop),
      time: Offset(rtl ? 0 : width - timeSize.width, timeTop),
    );
  }

  // Stacked, the line needs only the wider of the two longest words.
  @override
  double computeMinIntrinsicWidth(double height) => math.max(
    _title.getMinIntrinsicWidth(double.infinity),
    _time.getMinIntrinsicWidth(double.infinity),
  );

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _title.getMaxIntrinsicWidth(double.infinity) +
      _kTitleGap +
      _time.getMaxIntrinsicWidth(double.infinity);

  @override
  double computeMinIntrinsicHeight(double width) =>
      _compute(BoxConstraints(maxWidth: width), dry: true).size.height;

  @override
  double computeMaxIntrinsicHeight(double width) => computeMinIntrinsicHeight(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => _compute(constraints, dry: true).size;

  @override
  void performLayout() {
    final result = _compute(constraints, dry: false);
    size = result.size;
    (_title.parentData! as _TitleRowParentData).offset = result.title;
    (_time.parentData! as _TitleRowParentData).offset = result.time;
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
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
