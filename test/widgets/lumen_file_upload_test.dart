import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  test('accepts progress from zero to one and rejects values outside that range', () {
    LumenUploadItem item(double progress) => LumenUploadItem(
      name: 'report.pdf',
      status: LumenUploadStatus.uploading,
      statusLabel: 'Uploading',
      progress: progress,
    );

    expect(item(0).progress, 0);
    expect(item(1).progress, 1);
    expect(() => item(-0.01), throwsAssertionError);
    expect(() => item(1.01), throwsAssertionError);
    expect(() => item(double.nan), throwsAssertionError);
  });

  test('copyWith replaces only the given fields and keeps the progress rule', () {
    const item = LumenUploadItem(name: 'report.pdf', statusLabel: 'Waiting');

    expect(item.status, LumenUploadStatus.pending);
    expect(item.progress, 0);

    final failed = item.copyWith(status: LumenUploadStatus.failed, statusLabel: 'Connection lost');
    expect(failed.name, 'report.pdf');
    expect(failed.status, LumenUploadStatus.failed);
    expect(failed.statusLabel, 'Connection lost');
    expect(failed.progress, 0);

    final renamed = failed.copyWith(name: 'invoice.pdf', progress: 0.5);
    expect(renamed.name, 'invoice.pdf');
    expect(renamed.status, LumenUploadStatus.failed);
    expect(renamed.statusLabel, 'Connection lost');
    expect(renamed.progress, 0.5);

    expect(() => item.copyWith(progress: 1.5), throwsAssertionError);
    expect(() => item.copyWith(progress: double.nan), throwsAssertionError);
  });

  testWidgets('updates a row when the app rebuilds with a copied item', (tester) async {
    final palette = LumenPalette.defaultDark();
    const item = LumenUploadItem(name: 'report.pdf', statusLabel: 'Waiting');
    Future<void> render(LumenUploadItem item) => pumpBare(
      tester,
      LumenScope(
        palette: palette,
        child: SizedBox(width: 240, child: LumenFileUpload(items: <LumenUploadItem>[item])),
      ),
      reduceMotion: true,
    );

    await render(item);
    expect(find.text('0%'), findsOneWidget);

    await render(
      item.copyWith(status: LumenUploadStatus.uploading, statusLabel: 'Uploading', progress: 0.6),
    );

    final bar = find.byType(LumenLinearProgress);
    expect(find.text('Waiting'), findsNothing);
    expect(find.text('60%'), findsOneWidget);
    expect(tester.widget<Text>(find.text('Uploading')).style?.color, palette.primary);
    expect(tester.widget<LumenLinearProgress>(bar).value, 0.6);
    expect(tester.getSemantics(bar).value, '60%');
  });

  testWidgets('shows app-provided statuses and announces each file percentage', (tester) async {
    const items = <LumenUploadItem>[
      LumenUploadItem(name: 'waiting.pdf', statusLabel: 'Na fila'),
      LumenUploadItem(
        name: 'report.pdf',
        status: LumenUploadStatus.uploading,
        statusLabel: 'Enviando',
        progress: 0.425,
      ),
      LumenUploadItem(
        name: 'finished.pdf',
        status: LumenUploadStatus.completed,
        statusLabel: 'Concluído',
        progress: 1,
      ),
      LumenUploadItem(
        name: 'failed.pdf',
        status: LumenUploadStatus.failed,
        statusLabel: 'Conexão perdida',
        progress: 0.25,
      ),
    ];
    final palette = LumenPalette.light();
    const style = LumenStyle.brutal;
    await pumpBare(
      tester,
      LumenScope(
        palette: palette,
        style: style,
        child: const SizedBox(width: 240, child: LumenFileUpload(items: items)),
      ),
    );

    final bars = find.byType(LumenLinearProgress);
    expect(bars, findsNWidgets(items.length));
    final percentages = <String>['0%', '43%', '100%', '25%'];
    final colors = <Color>[palette.textMuted, palette.primary, palette.success, palette.danger];
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      expect(find.text(item.name), findsOneWidget);
      expect(find.text(percentages[index]), findsOneWidget);
      expect(tester.widget<Text>(find.text(item.statusLabel)).style?.color, colors[index]);
      expect(tester.widget<LumenLinearProgress>(bars.at(index)).value, item.progress);
      final semantics = tester.getSemantics(bars.at(index));
      expect(semantics.label, item.name);
      expect(semantics.value, percentages[index]);
    }
  });

  testWidgets('reflects list and progress changes supplied by the app', (tester) async {
    const empty = LumenFileUpload(items: <LumenUploadItem>[]);
    await pumpBare(tester, empty);
    expect(find.byType(LumenLinearProgress), findsNothing);

    Future<void> render(double progress, LumenUploadStatus status, String statusLabel) => pumpBare(
      tester,
      LumenFileUpload(
        items: <LumenUploadItem>[
          LumenUploadItem(
            name: 'report.pdf',
            status: status,
            statusLabel: statusLabel,
            progress: progress,
          ),
        ],
      ),
      reduceMotion: true,
    );

    await render(0.3, LumenUploadStatus.uploading, 'Uploading');
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('Uploading'), findsOneWidget);

    await render(1, LumenUploadStatus.completed, 'Uploaded');
    await tester.pumpAndSettle();
    expect(find.text('30%'), findsNothing);
    expect(find.text('Uploading'), findsNothing);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Uploaded'), findsOneWidget);

    await pumpBare(tester, empty);
    expect(find.byType(LumenLinearProgress), findsNothing);
  });
}
