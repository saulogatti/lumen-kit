import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:neon_ui/components.dart';

import '_harness.dart';

void main() {
  testWidgets('NeonRangeSlider arrasta os thumbs e informa o intervalo', (
    WidgetTester tester,
  ) async {
    RangeValues values = const RangeValues(20, 80);
    RangeValues? ended;
    await tester.pumpWidget(
      bareApp(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => SizedBox(
            width: 400,
            child: NeonRangeSlider(
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
    final Offset endThumb = Offset(
      trackStart + trackWidth * 0.8,
      box.center.dy,
    );
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
        child: NeonRangeSlider(
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
    expect(dim.opacity, kNeonDisabledOpacity);
  });

  testWidgets('NeonRangeSlider usa o accent do tema nos trilhos', (
    WidgetTester tester,
  ) async {
    const Color teal = Color(0xFF00BFA5);
    await pumpBare(
      tester,
      NeonScope(
        palette: NeonPalette.fromSeed(primary: teal),
        child: SizedBox(
          width: 300,
          child: NeonRangeSlider(
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
