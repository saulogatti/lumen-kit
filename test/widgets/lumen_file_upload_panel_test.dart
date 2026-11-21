import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  const failed = LumenUploadItem(
    name: 'notes.txt',
    status: LumenUploadStatus.failed,
    statusLabel: 'Connection lost',
    progress: 0.3,
  );
  const done = LumenUploadItem(
    name: 'report.pdf',
    status: LumenUploadStatus.completed,
    statusLabel: 'Uploaded',
    progress: 1,
  );

  Widget panel({
    VoidCallback? onPick,
    String? hint = 'PDF or PNG, up to 10 MB',
    bool busy = false,
    bool highlighted = false,
    List<LumenUploadItem> items = const <LumenUploadItem>[],
    ValueChanged<int>? onRemove,
    ValueChanged<int>? onRetry,
    Color? accentColor,
  }) => SizedBox(
    width: 320,
    child: LumenFileUploadPanel(
      title: 'Attach documents',
      hint: hint,
      actionLabel: 'Choose files',
      onPick: onPick,
      busy: busy,
      highlighted: highlighted,
      items: items,
      onRemove: onRemove,
      onRetry: onRetry,
      removeLabel: 'Delete',
      retryLabel: 'Send again',
      accentColor: accentColor,
    ),
  );

  BoxDecoration frame(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find
                    .descendant(
                      of: find.byType(LumenFileUploadPanel),
                      matching: find.byType(DecoratedBox),
                    )
                    .first,
              )
              .decoration
          as BoxDecoration;

  testWidgets('shows the app header and calls onPick from the add button', (tester) async {
    var picks = 0;
    await pumpBare(tester, panel(onPick: () => picks++));

    expect(find.text('Attach documents'), findsOneWidget);
    expect(find.text('PDF or PNG, up to 10 MB'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(LumenFileUpload), findsNothing);

    await tester.tap(find.text('Choose files'));
    await tester.pump();
    expect(picks, 1);
    expect(
      tester.getSemantics(find.byType(LumenButton)),
      isSemantics(label: 'Choose files', isButton: true, isEnabled: true, hasTapAction: true),
    );
  });

  testWidgets('omits the hint when the app gives none and uses custom icons', (tester) async {
    await pumpBare(
      tester,
      const LumenFileUploadPanel(
        title: 'Photos',
        icon: Icons.photo_outlined,
        actionLabel: 'Take photo',
        actionIcon: Icons.photo_camera_outlined,
        onPick: null,
      ),
    );

    expect(find.text('Photos'), findsOneWidget);
    expect(find.byIcon(Icons.photo_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_outlined), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('without onPick the add button is dimmed and does nothing', (tester) async {
    await pumpBare(tester, panel());

    final dim = tester.widget<Opacity>(
      find.descendant(of: find.byType(LumenButton), matching: find.byType(Opacity)),
    );
    expect(dim.opacity, kLumenDisabledOpacity);
    expect(
      tester.getSemantics(find.byType(LumenButton)),
      isSemantics(label: 'Choose files', isButton: true, hasEnabledState: true, isEnabled: false),
    );
    await tester.tap(find.text('Choose files'), warnIfMissed: false);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('busy shows the spinner instead of the icon and ignores presses', (tester) async {
    var picks = 0;
    await pumpBare(tester, panel(onPick: () => picks++, busy: true));

    expect(
      find.descendant(
        of: find.byType(LumenButton),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.add), findsNothing);
    await tester.tap(find.text('Choose files'), warnIfMissed: false);
    await tester.pump();
    expect(picks, 0);
  });

  testWidgets('add button works from the keyboard', (tester) async {
    var picks = 0;
    await pumpBare(tester, panel(onPick: () => picks++));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(picks, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(picks, 2);
  });

  testWidgets('highlighted draws the accent border, fill and glow', (tester) async {
    final palette = LumenPalette.defaultDark();
    Future<void> render({required bool highlighted, Color? accentColor}) => pumpBare(
      tester,
      LumenScope(
        palette: palette,
        child: panel(onPick: () {}, highlighted: highlighted, accentColor: accentColor),
      ),
      reduceMotion: true,
    );

    await render(highlighted: false);
    final idle = frame(tester);
    expect((idle.border! as Border).top.color, palette.surfaceOutline.outlineAlpha(0.5));
    expect(idle.boxShadow, isNull);

    await render(highlighted: true);
    await tester.pump();
    final over = frame(tester);
    expect((over.border! as Border).top.color, palette.primary.withValues(alpha: 0.9));
    expect((over.border! as Border).top.width, 1.6);
    expect(over.color, palette.primary.withValues(alpha: 0.1));
    expect(over.boxShadow, isNotEmpty);

    await render(highlighted: true, accentColor: palette.danger);
    await tester.pump();
    expect((frame(tester).border! as Border).top.color, palette.danger.withValues(alpha: 0.9));
    expect(tester.widget<Icon>(find.byIcon(Icons.cloud_upload_outlined)).color, palette.danger);
  });

  testWidgets('highlighted border, glow and radius follow the style', (tester) async {
    final palette = LumenPalette.light();
    await pumpBare(
      tester,
      LumenScope(
        palette: palette,
        style: LumenStyle.flat,
        child: panel(onPick: () {}, highlighted: true),
      ),
      reduceMotion: true,
    );

    final over = frame(tester);
    final expected = LumenStyle.flat.borderAll(
      color: palette.primary.withValues(alpha: 0.9),
      width: 1.6,
    );
    expect(over.border, expected);
    expect(
      over.boxShadow,
      LumenStyle.flat.shadows(<BoxShadow>[
        BoxShadow(color: palette.primary.withValues(alpha: 0.3), blurRadius: 22),
      ]),
    );
    expect(over.borderRadius, LumenStyle.flat.radius(16));
  });

  testWidgets('drag-over change animates, and is instant with reduce motion', (tester) async {
    final palette = LumenPalette.defaultDark();
    Future<void> render({required bool highlighted, required bool reduceMotion}) => pumpBare(
      tester,
      LumenScope(
        palette: palette,
        child: panel(onPick: () {}, highlighted: highlighted),
      ),
      reduceMotion: reduceMotion,
    );
    final target = palette.primary.withValues(alpha: 0.9);
    Color border() => (frame(tester).border! as Border).top.color;

    await render(highlighted: false, reduceMotion: false);
    await render(highlighted: true, reduceMotion: false);
    await tester.pump(kLumenFastDuration ~/ 2);
    expect(border(), isNot(target));
    await tester.pumpAndSettle();
    expect(border(), target);

    await render(highlighted: false, reduceMotion: true);
    await tester.pumpAndSettle();
    await render(highlighted: true, reduceMotion: true);
    await tester.pump();
    expect(border(), target);
    expect(
      tester.widget<AnimatedContainer>(find.byType(AnimatedContainer).first).duration,
      Duration.zero,
    );
  });

  testWidgets('passes items and per-file actions to the list', (tester) async {
    final removed = <int>[];
    final retried = <int>[];
    await pumpBare(
      tester,
      panel(
        onPick: () {},
        items: const <LumenUploadItem>[done, failed],
        onRemove: removed.add,
        onRetry: retried.add,
      ),
    );

    final list = tester.widget<LumenFileUpload>(find.byType(LumenFileUpload));
    expect(list.items, const <LumenUploadItem>[done, failed]);
    expect(list.removeLabel, 'Delete');
    expect(list.retryLabel, 'Send again');

    await tester.tap(_tooltip('Delete').first);
    await tester.tap(_tooltip('Send again'));
    await tester.pump();
    expect(removed, <int>[0]);
    expect(retried, <int>[1]);
  });
}

Finder _tooltip(String message) =>
    find.byWidgetPredicate((widget) => widget is Tooltip && widget.message == message);
