import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenRangeSlider arrasta os thumbs e informa o intervalo', (
    tester,
  ) async {
    var values = const RangeValues(20, 80);
    RangeValues? ended;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 400,
            child: LumenRangeSlider(
              values: values,
              max: 100,
              onChanged: (v) => setState(() => values = v),
              onChangeEnd: (v) => ended = v,
            ),
          ),
        ),
      ),
    );

    final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
    final box = tester.getRect(find.byType(RangeSlider));
    // Arrasta o thumb da direita para perto do fim.
    final trackStart = box.left + 24;
    final trackWidth = box.width - 48;
    final endThumb = Offset(trackStart + trackWidth * 0.8, box.center.dy);
    await tester.dragFrom(endThumb, Offset(trackWidth * 0.15, 0));
    await tester.pumpAndSettle();

    expect(slider.min, 0);
    expect(values.start, 20);
    expect(values.end, greaterThan(90));
    expect(ended, values);
  });

  testWidgets('valores fora do intervalo são limitados e null desabilita', (
    tester,
  ) async {
    await pumpBare(
      tester,
      const SizedBox(
        width: 300,
        child: LumenRangeSlider(
          values: RangeValues(-10, 150),
          max: 100,
          onChanged: null,
        ),
      ),
    );
    final slider = tester.widget<RangeSlider>(find.byType(RangeSlider));
    expect(slider.values, const RangeValues(0, 100));
    expect(slider.onChanged, isNull);
    final dim = tester.widget<Opacity>(
      find.ancestor(
        of: find.byType(RangeSlider),
        matching: find.byType(Opacity),
      ),
    );
    expect(dim.opacity, kLumenDisabledOpacity);
  });

  testWidgets('LumenRangeSlider usa o accent do tema nos trilhos', (
    tester,
  ) async {
    const teal = Color(0xFF00BFA5);
    await pumpBare(
      tester,
      LumenScope(
        palette: LumenPalette.fromSeed(primary: teal),
        child: SizedBox(
          width: 300,
          child: LumenRangeSlider(
            values: const RangeValues(0.2, 0.6),
            onChanged: (_) {},
          ),
        ),
      ),
    );
    final BuildContext ctx = tester.element(find.byType(RangeSlider));
    expect(SliderTheme.of(ctx).activeTrackColor, teal);
  });
}
