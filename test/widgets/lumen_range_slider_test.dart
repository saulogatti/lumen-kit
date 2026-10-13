import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

import '_harness.dart';

void main() {
  testWidgets('LumenRangeSlider arrasta os thumbs e informa o intervalo', (
    WidgetTester tester,
  ) async {
    var values = const RangeValues(20, 80);
    RangeValues? ended;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => SizedBox(
            width: 400,
            child: LumenRangeSlider(
              values: values,
              max: 100,
              onChanged: (RangeValues v) => setState(() => values = v),
              onChangeEnd: (RangeValues v) => ended = v,
            ),
          ),
        ),
      ),
    );

    final RangeSlider slider = tester.widget(find.byType(RangeSlider));
    final Rect box = tester.getRect(find.byType(RangeSlider));
    // Arrasta o thumb da direita para perto do fim.
    final double trackStart = box.left + 24;
    final double trackWidth = box.width - 48;
    final endThumb = Offset(trackStart + trackWidth * 0.8, box.center.dy);
    await tester.dragFrom(endThumb, Offset(trackWidth * 0.15, 0));
    await tester.pumpAndSettle();

    expect(slider.min, 0);
    expect(values.start, 20);
    expect(values.end, greaterThan(90));
    expect(ended, values);
  });

  testWidgets('valores fora do intervalo são limitados e null desabilita', (
    WidgetTester tester,
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
    final RangeSlider slider = tester.widget(find.byType(RangeSlider));
    expect(slider.values, const RangeValues(0, 100));
    expect(slider.onChanged, isNull);
    final Opacity dim = tester.widget(
      find.ancestor(
        of: find.byType(RangeSlider),
        matching: find.byType(Opacity),
      ),
    );
    expect(dim.opacity, kLumenDisabledOpacity);
  });

  testWidgets('LumenRangeSlider usa o accent do tema nos trilhos', (
    WidgetTester tester,
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
