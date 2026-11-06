import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenCircularProgress para o loop ao virar determinado', (tester) async {
    await tester.pumpWidget(bareApp(const LumenCircularProgress()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pumpWidget(bareApp(const LumenCircularProgress(value: 0.4)));
    // Se o loop continuasse, pumpAndSettle estouraria o tempo.
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(bareApp(const LumenCircularProgress()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);
  });
}
