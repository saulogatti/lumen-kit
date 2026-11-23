import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

Finder _action(String label) =>
    find.byWidgetPredicate((widget) => widget is Tooltip && widget.message == label);

void main() {
  testWidgets('renders items in order and invokes each action independently', (tester) async {
    final pressed = <String>[];
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        child: LumenActionList(
          items: <LumenActionListItem>[
            LumenActionListItem(
              title: 'Project brief',
              subtitle: 'Updated today',
              icon: Icons.description_outlined,
              primaryAction: LumenListAction(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onPressed: () => pressed.add('edit'),
              ),
              secondaryAction: LumenListAction(
                icon: Icons.archive_outlined,
                label: 'Archive',
                onPressed: () => pressed.add('archive'),
              ),
            ),
            LumenActionListItem(
              title: 'Meeting notes',
              secondaryAction: LumenListAction(
                icon: Icons.visibility_outlined,
                label: 'Preview',
                onPressed: () => pressed.add('preview'),
              ),
            ),
            const LumenActionListItem(title: 'Shared references'),
          ],
        ),
      ),
    );

    final title = tester.getRect(find.text('Project brief'));
    final icon = tester.getRect(find.byIcon(Icons.description_outlined));
    final edit = tester.getRect(_action('Edit'));
    final archive = tester.getRect(_action('Archive'));
    expect(icon.right, lessThan(title.left));
    expect(edit.left, greaterThan(title.right));
    expect(archive.left, greaterThan(edit.right));
    expect(title.top, lessThan(tester.getTopLeft(find.text('Meeting notes')).dy));
    expect(find.text('Updated today'), findsOneWidget);
    expect(find.text('Shared references'), findsOneWidget);
    expect(find.byType(LumenIconButton), findsNWidgets(3));
    expect(tester.state<ScrollableState>(find.byType(Scrollable)).position.maxScrollExtent, 0);

    await tester.tap(_action('Archive'));
    await tester.tap(_action('Edit'));
    await tester.tap(_action('Preview'));
    expect(pressed, <String>['archive', 'edit', 'preview']);
  });

  testWidgets('uses default and custom scroll and spacing settings', (tester) async {
    const items = <LumenActionListItem>[
      LumenActionListItem(title: 'First'),
      LumenActionListItem(title: 'Second'),
    ];
    final viewport = find.byType(ListView);
    final rows = find.byType(LumenActionListItem);

    double gapBetweenRows() =>
        tester.getTopLeft(rows.last).dy - tester.getBottomLeft(rows.first).dy;

    Future<void> pumpList({bool? primary, EdgeInsetsGeometry? padding, double? spacing}) =>
        pumpBare(
          tester,
          LumenActionList(items: items, primary: primary, padding: padding, spacing: spacing),
        );

    await pumpList();
    expect(tester.widget<ListView>(viewport).primary, isFalse);
    expect(tester.getTopLeft(rows.first), tester.getTopLeft(viewport));
    expect(gapBetweenRows(), closeTo(8, 0.001));

    await pumpList(primary: true, padding: const EdgeInsets.all(16), spacing: 20);
    expect(tester.widget<ListView>(viewport).primary, isTrue);
    expect(tester.getTopLeft(rows.first) - tester.getTopLeft(viewport), const Offset(16, 16));
    expect(gapBetweenRows(), closeTo(20, 0.001));
  });

  testWidgets('announces independent buttons and skips disabled actions in traversal', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var presses = 0;
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        child: LumenActionList(
          items: <LumenActionListItem>[
            LumenActionListItem(
              title: 'Project brief',
              primaryAction: const LumenListAction(icon: Icons.edit_outlined, label: 'Edit'),
              secondaryAction: LumenListAction(
                icon: Icons.archive_outlined,
                label: 'Archive',
                onPressed: () => presses++,
              ),
            ),
          ],
        ),
      ),
    );

    final edit = tester.getSemantics(find.bySemanticsLabel('Edit'));
    final archive = tester.getSemantics(find.bySemanticsLabel('Archive'));
    expect(edit, isSemantics(label: 'Edit', isButton: true, isEnabled: false, hasTapAction: false));
    expect(
      archive,
      isSemantics(label: 'Archive', isButton: true, isEnabled: true, hasTapAction: true),
    );
    await tester.tap(_action('Edit'));
    expect(presses, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(presses, 1);
    handle.dispose();
  });

  testWidgets('moves actions below wrapped text in a narrow viewport', (tester) async {
    await pumpBare(
      tester,
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2)),
        child: SizedBox(
          width: 180,
          child: LumenActionList(
            items: <LumenActionListItem>[
              LumenActionListItem(
                title: 'A longer project description',
                subtitle: 'Updated today',
                icon: Icons.description_outlined,
                primaryAction: LumenListAction(icon: Icons.edit, label: 'Edit'),
                secondaryAction: LumenListAction(icon: Icons.archive, label: 'Archive'),
              ),
            ],
          ),
        ),
      ),
    );

    final subtitle = tester.getRect(find.text('Updated today'));
    final edit = tester.getRect(_action('Edit'));
    final archive = tester.getRect(_action('Archive'));
    expect(edit.top, greaterThan(subtitle.bottom));
    expect(archive.top, edit.top);
    expect(edit.size, const Size(48, 48));
  });

  testWidgets('an empty list takes up no space', (tester) async {
    await pumpBare(tester, const LumenActionList(items: <LumenActionListItem>[]));
    expect(tester.getSize(find.byType(LumenActionList)), Size.zero);
  });

  testWidgets('scrolls to a row outside the initial viewport and builds it on demand', (
    tester,
  ) async {
    var presses = 0;
    await pumpBare(
      tester,
      SizedBox(
        width: 360,
        height: 120,
        child: LumenActionList(
          items: <LumenActionListItem>[
            for (var index = 1; index < 50; index++) LumenActionListItem(title: 'Item $index'),
            LumenActionListItem(
              title: 'Item 50',
              primaryAction: LumenListAction(
                icon: Icons.edit_outlined,
                label: 'Edit item 50',
                onPressed: () => presses++,
              ),
            ),
          ],
        ),
      ),
    );

    final last = find.text('Item 50');
    expect(find.text('Item 1').hitTestable(), findsOneWidget);
    expect(last, findsNothing);

    await tester.scrollUntilVisible(last, 160, scrollable: find.byType(Scrollable));
    expect(last.hitTestable(), findsOneWidget);
    await tester.tap(_action('Edit item 50'));
    expect(presses, 1);
  });
}
