import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/file_upload_panel_section.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  LumenFileUploadPanel panel(WidgetTester tester) =>
      tester.widget<LumenFileUploadPanel>(find.byType(LumenFileUploadPanel));
  List<LumenUploadItem> items(WidgetTester tester) => panel(tester).items;
  Finder tooltip(String message) =>
      find.byWidgetPredicate((widget) => widget is Tooltip && widget.message == message);

  testWidgets('choose files adds uploads, the second fails and can be retried', (tester) async {
    await _pumpSection(tester);
    expect(items(tester), isEmpty);
    expect(find.byType(LumenFileUpload), findsNothing);

    await tester.tap(find.text('Choose files'));
    await tester.pump();
    expect(panel(tester).busy, isTrue);
    await tester.pump(const Duration(milliseconds: 400));
    expect(panel(tester).busy, isFalse);
    expect(items(tester).single.name, 'document-1.pdf');
    expect(items(tester).single.status, LumenUploadStatus.uploading);

    await tester.tap(find.text('Choose files'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(items(tester).map((item) => item.name), <String>['document-1.pdf', 'document-2.pdf']);

    await tester.pump(const Duration(seconds: 1));
    expect(items(tester)[0].status, LumenUploadStatus.completed);
    expect(items(tester)[1].status, LumenUploadStatus.failed);
    expect(items(tester)[1].progress, 0.5);
    expect(find.text('Connection lost'), findsOneWidget);

    await tester.tap(tooltip('Retry'));
    await tester.pump();
    expect(items(tester)[1].status, LumenUploadStatus.uploading);
    expect(items(tester)[1].progress, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(items(tester)[1].status, LumenUploadStatus.completed);
    expect(tooltip('Retry'), findsNothing);

    await tester.tap(tooltip('Remove').first);
    await tester.pump();
    expect(items(tester).single.name, 'document-2.pdf');
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag over switch highlights the panel', (tester) async {
    await _pumpSection(tester);
    expect(panel(tester).highlighted, isFalse);

    await tester.tap(find.byType(LumenSwitch));
    await tester.pumpAndSettle();
    expect(panel(tester).highlighted, isTrue);
  });

  testWidgets('leaving while picking or uploading stops the simulation', (tester) async {
    await _pumpSection(tester);
    await tester.tap(find.text('Choose files'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Choose files'));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpSection(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(padding: EdgeInsets.all(20), child: FileUploadPanelSection()),
      ),
    ),
  );
}
