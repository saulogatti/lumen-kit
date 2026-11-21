import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/file_upload_section.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  LumenUploadItem invoice(WidgetTester tester) =>
      tester.widget<LumenFileUpload>(find.byType(LumenFileUpload)).items.first;
  LumenButton button(WidgetTester tester) => tester.widget<LumenButton>(find.byType(LumenButton));

  testWidgets('upload button sends the invoice and can run again', (tester) async {
    await _pumpSection(tester);
    expect(invoice(tester).status, LumenUploadStatus.pending);
    expect(find.text('Uploading'), findsOneWidget);
    expect(find.text('Uploaded'), findsOneWidget);
    expect(find.text('Connection lost'), findsOneWidget);

    await tester.tap(find.text('Upload'));
    await tester.pump();
    expect(invoice(tester).status, LumenUploadStatus.uploading);
    expect(button(tester).onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));
    expect(invoice(tester).progress, 0.5);

    await tester.pump(const Duration(seconds: 1));
    expect(invoice(tester).status, LumenUploadStatus.completed);
    expect(invoice(tester).progress, 1);
    expect(button(tester).onPressed, isNotNull);

    await tester.tap(find.text('Upload'));
    await tester.pump();
    expect(invoice(tester).status, LumenUploadStatus.uploading);
    expect(invoice(tester).progress, 0);
    await tester.pump(const Duration(seconds: 2));
    expect(invoice(tester).status, LumenUploadStatus.completed);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving mid-upload stops the simulation', (tester) async {
    await _pumpSection(tester);
    await tester.tap(find.text('Upload'));
    await tester.pump(const Duration(milliseconds: 500));

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
        body: SingleChildScrollView(padding: EdgeInsets.all(20), child: FileUploadSection()),
      ),
    ),
  );
}
