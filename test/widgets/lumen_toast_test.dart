import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('showLumenToast no topo ancora pela borda de cima', (tester) async {
    late BuildContext ctx;
    await pumpBare(
      tester,
      Builder(
        builder: (c) {
          ctx = c;
          return const SizedBox();
        },
      ),
    );

    unawaited(
      showLumenToast(
        context: ctx,
        message: 'no topo',
        position: LumenToastPosition.top,
        margin: 16,
        duration: const Duration(milliseconds: 500),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final pos = tester.widget<Positioned>(
      find.ancestor(of: find.text('no topo'), matching: find.byType(Positioned)).first,
    );
    expect(pos.top, 16);
    expect(pos.bottom, isNull);

    await tester.pump(const Duration(milliseconds: 600)); // timer dispara
    await tester.pumpAndSettle();
    expect(find.text('no topo'), findsNothing);
  });
}
