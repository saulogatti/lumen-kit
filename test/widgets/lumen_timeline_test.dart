import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

const List<LumenTimelineEntry> _history = <LumenTimelineEntry>[
  LumenTimelineEntry(
    title: 'Approved',
    subtitle: 'Ana Lima',
    description: 'Customer approved the quote by phone.',
    timestamp: 'Nov 12, 10:42',
    icon: Icons.check_rounded,
    tone: LumenStatusTone.success,
  ),
  LumenTimelineEntry(title: 'Waiting for approval', timestamp: 'Nov 11, 16:05'),
  LumenTimelineEntry(title: 'Opened'),
];

Widget _box(Widget child) => SizedBox(width: 360, child: child);

/// Decoration of the content surface (padding 12×8) of the entry titled [title].
BoxDecoration _surfaceOf(WidgetTester tester, String title) {
  final container = tester.widget<AnimatedContainer>(
    find.ancestor(of: find.text(title), matching: find.byType(AnimatedContainer)).first,
  );
  return container.decoration! as BoxDecoration;
}

/// Dot marker of the entry at [index], in build order.
AnimatedContainer _dot(WidgetTester tester, int index) => tester
    .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
    .where((c) => c.constraints?.maxWidth == 10 || c.constraints?.maxWidth == 14)
    .elementAt(index);

/// Decoration of the icon marker that holds [icon].
BoxDecoration _markerOf(WidgetTester tester, IconData icon) =>
    tester
            .widget<AnimatedContainer>(
              find.ancestor(of: find.byIcon(icon), matching: find.byType(AnimatedContainer)).first,
            )
            .decoration!
        as BoxDecoration;

Color? _iconColor(WidgetTester tester, IconData icon) =>
    tester.widget<Icon>(find.byIcon(icon)).color;

void main() {
  testWidgets('shows every text, icon and child without a registered theme', (tester) async {
    await pumpBare(
      tester,
      _box(
        const LumenTimeline(
          entries: <LumenTimelineEntry>[
            LumenTimelineEntry(
              title: 'Approved',
              subtitle: 'Ana Lima',
              description: 'Customer approved the quote by phone.',
              timestamp: 'Nov 12, 10:42',
              icon: Icons.check_rounded,
              child: Text('extra'),
            ),
            LumenTimelineEntry(title: 'Opened'),
          ],
        ),
      ),
    );

    for (final text in <String>[
      'Approved',
      'Ana Lima',
      'Customer approved the quote by phone.',
      'Nov 12, 10:42',
      'extra',
      'Opened',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('draws the line between markers but not past the ends', (tester) async {
    Iterable<Positioned> lines() =>
        tester.widgetList<Positioned>(find.byType(Positioned)).where((p) => p.child is ColoredBox);

    await pumpBare(tester, _box(const LumenTimeline(entries: _history)));
    // First: only down. Middle: up and down. Last: only up.
    expect(lines(), hasLength(4));
    expect(lines().where((p) => p.top == 0), hasLength(2));
    expect(lines().where((p) => p.bottom == 0), hasLength(2));

    await pumpBare(
      tester,
      _box(const LumenTimeline(entries: <LumenTimelineEntry>[LumenTimelineEntry(title: 'Only')])),
    );
    expect(lines(), isEmpty);

    await pumpBare(tester, _box(const LumenTimeline(entries: <LumenTimelineEntry>[])));
    expect(find.byType(Positioned), findsNothing);
  });

  testWidgets('spacing separates events and the line crosses the gap', (tester) async {
    const entries = <LumenTimelineEntry>[
      LumenTimelineEntry(title: 'A'),
      LumenTimelineEntry(title: 'B'),
    ];
    await pumpBare(tester, _box(const LumenTimeline(entries: entries, spacing: 0)));
    final tight = tester.getTopLeft(find.text('B')).dy - tester.getTopLeft(find.text('A')).dy;

    await pumpBare(tester, _box(const LumenTimeline(entries: entries, spacing: 20)));
    final loose = tester.getTopLeft(find.text('B')).dy - tester.getTopLeft(find.text('A')).dy;
    expect(loose - tight, 20);
  });

  testWidgets('tapping an event calls its onTap; events without it are not buttons', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpBare(
      tester,
      _box(
        LumenTimeline(
          entries: <LumenTimelineEntry>[
            LumenTimelineEntry(title: 'Tappable', onTap: () => taps++),
            const LumenTimelineEntry(title: 'Static'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Tappable'));
    await tester.pump();
    expect(taps, 1);
    expect(find.byType(LumenPressable), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Tappable')),
      isSemantics(label: 'Tappable', isButton: true, hasTapAction: true, isEnabled: true),
    );
    expect(
      tester.getSemantics(find.text('Static')),
      isSemantics(label: 'Static', isButton: false, hasTapAction: false),
    );

    await tester.tap(find.text('Static'));
    await tester.pump();
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('announces a list whose items read title, timestamp, subtitle and description', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpBare(tester, _box(const LumenTimeline(entries: _history)));

    final first = tester.getSemantics(find.text('Approved'));
    expect(
      first,
      isSemantics(
        label: 'Approved\nNov 12, 10:42\nAna Lima\nCustomer approved the quote by phone.',
      ),
    );
    expect(first.getSemanticsData().role, SemanticsRole.listItem);
    expect(first.parent!.getSemanticsData().role, SemanticsRole.list);
    expect(
      tester.getSemantics(find.text('Waiting for approval')),
      isSemantics(label: 'Waiting for approval\nNov 11, 16:05'),
    );
    expect(tester.getSemantics(find.text('Opened')).parent, same(first.parent));
    handle.dispose();
  });

  testWidgets('a tappable event keeps the controls inside its child as separate nodes', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var opened = 0;
    var changes = 0;
    await pumpBare(
      tester,
      _box(
        LumenTimeline(
          entries: <LumenTimelineEntry>[
            LumenTimelineEntry(
              title: 'Edited',
              timestamp: 'Nov 12',
              onTap: () => opened++,
              child: LumenButton.ghost(label: 'See changes', onPressed: () => changes++),
            ),
          ],
        ),
      ),
    );

    expect(
      tester.getSemantics(find.text('Edited')),
      isSemantics(label: 'Edited\nNov 12', isButton: true, hasTapAction: true),
    );
    expect(
      tester.getSemantics(find.text('See changes')),
      isSemantics(label: 'See changes', isButton: true, hasTapAction: true),
    );

    await tester.tap(find.text('See changes'));
    await tester.pump();
    expect((opened, changes), (0, 1));
    await tester.tap(find.text('Edited'));
    await tester.pump();
    expect((opened, changes), (1, 1));
    handle.dispose();
  });

  testWidgets('highlightedIndex tints only that event and enlarges its marker', (tester) async {
    await pumpBare(
      tester,
      _box(
        const LumenTimeline(
          highlightedIndex: 1,
          entries: <LumenTimelineEntry>[
            LumenTimelineEntry(title: 'Newest'),
            LumenTimelineEntry(title: 'Current'),
            LumenTimelineEntry(title: 'Oldest'),
          ],
        ),
      ),
    );

    expect(_surfaceOf(tester, 'Newest').color, Colors.transparent);
    expect(_surfaceOf(tester, 'Current').color, isNot(Colors.transparent));
    expect(_surfaceOf(tester, 'Current').border?.top.color, isNot(Colors.transparent));
    expect(_surfaceOf(tester, 'Oldest').color, Colors.transparent);
    expect(tester.widget<Text>(find.text('Current')).style?.fontWeight, FontWeight.w700);
    expect(tester.widget<Text>(find.text('Newest')).style?.fontWeight, FontWeight.w600);
    expect(_dot(tester, 0).constraints?.maxWidth, 10);
    expect(_dot(tester, 1).constraints?.maxWidth, 14);
    expect(_dot(tester, 1).decoration, isA<BoxDecoration>());
    expect((_dot(tester, 1).decoration! as BoxDecoration).boxShadow, isNotEmpty);
  });

  testWidgets('highlighted icon marker gets a tinted fill and glow', (tester) async {
    await pumpBare(
      tester,
      _box(
        const LumenTimeline(
          highlightedIndex: 0,
          entries: <LumenTimelineEntry>[
            LumenTimelineEntry(title: 'Now', icon: Icons.bolt_rounded),
            LumenTimelineEntry(title: 'Before', icon: Icons.history_rounded),
          ],
        ),
      ),
    );

    BoxDecoration markerOf(IconData icon) => _markerOf(tester, icon);
    expect(markerOf(Icons.bolt_rounded).boxShadow, isNotEmpty);
    expect(markerOf(Icons.history_rounded).boxShadow, isNull);
    expect(markerOf(Icons.bolt_rounded).color, isNot(markerOf(Icons.history_rounded).color));
  });

  testWidgets('an out-of-range highlightedIndex highlights nothing', (tester) async {
    await pumpBare(tester, _box(const LumenTimeline(entries: _history, highlightedIndex: 9)));
    for (final entry in _history) {
      expect(_surfaceOf(tester, entry.title).color, Colors.transparent);
    }
  });

  testWidgets('marker color: entry accentColor, then tone, then timeline accent, then primary', (
    tester,
  ) async {
    const custom = Color(0xFF123456);
    const timelineAccent = Color(0xFF654321);
    const entries = <LumenTimelineEntry>[
      LumenTimelineEntry(
        title: 'Custom',
        icon: Icons.star_rounded,
        accentColor: custom,
        tone: LumenStatusTone.danger,
      ),
      LumenTimelineEntry(title: 'Tone', icon: Icons.warning_rounded, tone: LumenStatusTone.warning),
      LumenTimelineEntry(title: 'Default', icon: Icons.circle_outlined),
    ];

    await pumpBare(tester, _box(const LumenTimeline(entries: entries)));
    final p = LumenThemeExt.of(tester.element(find.text('Default'))).palette;
    expect(_iconColor(tester, Icons.star_rounded), custom);
    expect(_iconColor(tester, Icons.warning_rounded), p.warning);
    expect(_iconColor(tester, Icons.circle_outlined), p.primary);

    await pumpBare(
      tester,
      _box(const LumenTimeline(entries: entries, accentColor: timelineAccent)),
    );
    expect(_iconColor(tester, Icons.star_rounded), custom);
    expect(_iconColor(tester, Icons.warning_rounded), p.warning);
    expect(_iconColor(tester, Icons.circle_outlined), timelineAccent);
  });

  testWidgets('follows a local LumenScope in every style, light and dark', (tester) async {
    for (final style in <LumenStyle>[
      LumenStyle.neon,
      LumenStyle.flat,
      LumenStyle.glass,
      LumenStyle.soft,
      LumenStyle.brutal,
    ]) {
      for (final palette in <LumenPalette>[LumenPalette.defaultDark(), LumenPalette.light()]) {
        await pumpBare(
          tester,
          LumenScope(
            palette: palette,
            style: style,
            child: _box(const LumenTimeline(entries: _history, highlightedIndex: 0)),
          ),
        );
        final surface = _surfaceOf(tester, 'Approved');
        expect(surface.borderRadius, style.radius(12));
        expect(surface.boxShadow, isNull, reason: 'a shadow would show through the tint');
        expect(_markerOf(tester, Icons.check_rounded).color?.a, 1, reason: 'opaque marker');
        expect(_iconColor(tester, Icons.check_rounded), palette.success);
        expect(
          tester.widget<Text>(find.text('Opened')).style?.color,
          palette.textPrimary,
          reason: '$style',
        );
      }
    }
    await pumpBare(
      tester,
      LumenScope(
        palette: LumenPalette.light(),
        style: LumenStyle.brutal,
        child: _box(const LumenTimeline(entries: _history, highlightedIndex: 0)),
      ),
    );
    expect(
      _markerOf(tester, Icons.check_rounded).boxShadow?.single.offset,
      const Offset(4, 4),
      reason: 'brutal turns the marker glow into a hard shadow',
    );
  });

  testWidgets('reduce motion makes the highlight change instant', (tester) async {
    await pumpBare(
      tester,
      _box(const LumenTimeline(entries: _history, highlightedIndex: 0)),
      reduceMotion: true,
    );
    for (final container in tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer))) {
      expect(container.duration, Duration.zero);
    }
  });

  testWidgets('builder builds events on demand, scrolls and highlights', (tester) async {
    final handle = tester.ensureSemantics();
    final built = <int>{};
    var tapped = -1;
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        height: 240,
        child: LumenTimeline.builder(
          itemCount: 100,
          highlightedIndex: 0,
          controller: controller,
          padding: const EdgeInsets.all(8),
          physics: const ClampingScrollPhysics(),
          entryBuilder: (context, i) {
            built.add(i);
            return LumenTimelineEntry(
              title: 'Event $i',
              timestamp: '$i min ago',
              onTap: () => tapped = i,
            );
          },
        ),
      ),
    );

    expect(find.text('Event 0'), findsOneWidget);
    expect(built.contains(99), isFalse, reason: 'only visible events are built');
    expect(_surfaceOf(tester, 'Event 0').color, isNot(Colors.transparent));
    expect(_surfaceOf(tester, 'Event 1').color, Colors.transparent);
    expect(
      tester.getSemantics(find.text('Event 1')),
      isSemantics(label: 'Event 1\n1 min ago', isButton: true),
    );
    await tester.tap(find.text('Event 1'));
    expect(tapped, 1);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();
    expect(find.text('Event 99'), findsOneWidget);
    final lastLines = tester
        .widgetList<Positioned>(
          find.descendant(
            of: find.ancestor(of: find.text('Event 99'), matching: find.byType(Stack)).first,
            matching: find.byType(Positioned),
          ),
        )
        .where((p) => p.child is ColoredBox);
    expect(lastLines.single.top, 0, reason: 'last event only has the line coming from above');
    handle.dispose();
  });

  testWidgets('builder with shrinkWrap fits inside another scroll view', (tester) async {
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        height: 400,
        child: ListView(
          children: <Widget>[
            LumenTimeline.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              entryBuilder: (context, i) => LumenTimelineEntry(title: 'Row $i'),
            ),
            const Text('after'),
          ],
        ),
      ),
    );
    expect(find.text('Row 2'), findsOneWidget);
    expect(find.text('after'), findsOneWidget);
  });

  group('title line', () {
    const longTime = 'Wednesday, November 12, 2026 at 10:42 AM';

    /// Render object of the title line that holds [timestamp].
    RenderBox titleRow(WidgetTester tester, String timestamp) => tester.renderObject<RenderBox>(
      find
          .ancestor(
            of: find.text(timestamp),
            matching: find.byWidgetPredicate((w) => w is MultiChildRenderObjectWidget),
          )
          .first,
    );

    testWidgets('a long timestamp in a narrow box with large text goes below the title', (
      tester,
    ) async {
      await pumpBare(
        tester,
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: SizedBox(
            width: 220,
            child: LumenTimeline(
              entries: <LumenTimelineEntry>[
                LumenTimelineEntry(title: 'Quote approved', timestamp: longTime),
              ],
            ),
          ),
        ),
      );

      final box = titleRow(tester, longTime);
      final row = box.localToGlobal(Offset.zero) & box.size;
      final title = tester.getRect(find.text('Quote approved'));
      final time = tester.getRect(find.text(longTime));
      expect(title.width, greaterThan(0));
      expect(time.width, greaterThan(0));
      expect(time.top, greaterThanOrEqualTo(title.bottom), reason: 'stacked');
      expect(time.right, moreOrLessEquals(row.right), reason: 'still at the end');
      for (final rect in <Rect>[title, time]) {
        expect(rect.left, greaterThanOrEqualTo(row.left));
        expect(rect.right, lessThanOrEqualTo(row.right));
      }
      expect(row.right, lessThanOrEqualTo(tester.getRect(find.byType(LumenTimeline)).right));
    });

    testWidgets('a long timestamp next to a long title takes at most 40% and wraps', (
      tester,
    ) async {
      const title = 'Quote approved by the customer';
      await pumpBare(
        tester,
        _box(
          const LumenTimeline(
            entries: <LumenTimelineEntry>[LumenTimelineEntry(title: title, timestamp: longTime)],
          ),
        ),
      );

      final box = titleRow(tester, longTime);
      final row = box.localToGlobal(Offset.zero) & box.size;
      final titleRect = tester.getRect(find.text(title));
      final time = tester.getRect(find.text(longTime));
      expect(time.width, lessThanOrEqualTo(row.width * 0.4 + 0.01));
      expect(time.height, greaterThan(titleRect.height), reason: 'the timestamp wrapped');
      expect(titleRect.right, lessThanOrEqualTo(time.left));
      expect(time.right, moreOrLessEquals(row.right));
      expect(time.top, lessThan(titleRect.bottom), reason: 'side by side');
    });

    testWidgets('a short timestamp leaves the rest of the line to the title', (tester) async {
      await pumpBare(
        tester,
        _box(
          const LumenTimeline(
            entries: <LumenTimelineEntry>[
              LumenTimelineEntry(
                title: 'A title long enough to need more than sixty percent of the line',
                timestamp: '10:42',
              ),
            ],
          ),
        ),
      );

      final row = titleRow(tester, '10:42');
      final title = tester.getRect(
        find.text('A title long enough to need more than sixty percent of the line'),
      );
      final time = tester.getRect(find.text('10:42'));
      expect(time.right, moreOrLessEquals(row.localToGlobal(Offset(row.size.width, 0)).dx));
      expect(title.width, greaterThan(row.size.width * 0.6));
      expect(time.left - title.right, greaterThanOrEqualTo(12));
    });

    testWidgets('keeps the longest timestamp word whole while the title words still fit', (
      tester,
    ) async {
      const time = '2026-11-12T18:12 UTC';
      await pumpBare(
        tester,
        _box(
          const LumenTimeline(
            entries: <LumenTimelineEntry>[
              LumenTimelineEntry(title: 'Opened by the front desk', timestamp: time),
            ],
          ),
        ),
      );

      final row = titleRow(tester, time);
      final longestWord = tester
          .renderObject<RenderBox>(find.text(time))
          .getMinIntrinsicWidth(double.infinity);
      expect(longestWord, greaterThan(row.size.width * 0.4), reason: 'beyond the plain cap');
      expect(tester.getSize(find.text(time)).width, greaterThanOrEqualTo(longestWord - 0.01));
      expect(
        tester.getRect(find.text('Opened by the front desk')).right,
        lessThanOrEqualTo(tester.getRect(find.text(time)).left),
      );
    });

    testWidgets('a long timestamp stays on one line when a short title leaves room', (
      tester,
    ) async {
      await pumpBare(
        tester,
        _box(
          const LumenTimeline(
            entries: <LumenTimelineEntry>[
              LumenTimelineEntry(title: 'Opened', timestamp: 'Nov 12, 10:42:05'),
            ],
          ),
        ),
      );

      final row = titleRow(tester, 'Nov 12, 10:42:05');
      final time = tester.getRect(find.text('Nov 12, 10:42:05'));
      expect(time.width, greaterThan(row.size.width * 0.4));
      expect(
        time.height,
        lessThanOrEqualTo(tester.getSize(find.text('Opened')).height),
        reason: 'one line',
      );
    });

    testWidgets('follows the text direction', (tester) async {
      Widget timeline(TextDirection direction) => Directionality(
        textDirection: direction,
        child: _box(
          const LumenTimeline(
            entries: <LumenTimelineEntry>[LumenTimelineEntry(title: 'Title', timestamp: '10:42')],
          ),
        ),
      );

      await pumpBare(tester, timeline(TextDirection.ltr));
      expect(
        tester.getRect(find.text('Title')).left,
        lessThan(tester.getRect(find.text('10:42')).left),
      );

      await pumpBare(tester, timeline(TextDirection.rtl));
      expect(
        tester.getRect(find.text('Title')).left,
        greaterThan(tester.getRect(find.text('10:42')).left),
      );

      await pumpBare(tester, timeline(TextDirection.rtl));
      expect(
        tester.getRect(find.text('Title')).left,
        greaterThan(tester.getRect(find.text('10:42')).left),
      );
    });

    testWidgets('sizes itself intrinsically inside an AlertDialog', (tester) async {
      await pumpBare(
        tester,
        const AlertDialog(
          title: Text('History'),
          content: IntrinsicHeight(
            child: LumenTimeline(
              entries: <LumenTimelineEntry>[
                LumenTimelineEntry(title: 'Approved', timestamp: longTime),
                LumenTimelineEntry(title: 'Opened', timestamp: 'Nov 8'),
              ],
            ),
          ),
        ),
      );
      expect(find.text(longTime), findsOneWidget);
      expect(find.text('Opened'), findsOneWidget);

      final row = titleRow(tester, longTime);
      expect(row.getMinIntrinsicWidth(100), greaterThan(12));
      expect(row.getMaxIntrinsicWidth(100), greaterThan(row.getMinIntrinsicWidth(100)));
      expect(row.getMinIntrinsicHeight(120), greaterThan(row.getMinIntrinsicHeight(1000)));
      expect(row.getMaxIntrinsicHeight(120), row.getMinIntrinsicHeight(120));
      expect(row.getMinIntrinsicHeight(double.infinity), greaterThan(0));
      expect(
        row.getDryLayout(const BoxConstraints(maxWidth: 300)).width,
        300,
        reason: 'fills the width it gets',
      );
    });

    testWidgets('tapping the timestamp taps the event', (tester) async {
      var taps = 0;
      await pumpBare(
        tester,
        _box(
          LumenTimeline(
            entries: <LumenTimelineEntry>[
              LumenTimelineEntry(title: 'Edited', timestamp: '10:42', onTap: () => taps++),
            ],
          ),
        ),
      );
      await tester.tap(find.text('10:42'));
      expect(taps, 1);
    });

    testWidgets('exposes the title baseline to a baseline-aligned parent', (tester) async {
      await pumpBare(
        tester,
        const SizedBox(
          width: 360,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text('Label'),
              Expanded(
                child: LumenTimeline(
                  entries: <LumenTimelineEntry>[LumenTimelineEntry(title: 'Title', timestamp: '1')],
                ),
              ),
            ],
          ),
        ),
      );
      expect(
        tester.getBottomLeft(find.text('Label')).dy,
        moreOrLessEquals(tester.getBottomLeft(find.text('Title')).dy, epsilon: 2),
      );
    });
  });
}
