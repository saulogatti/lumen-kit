import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_kit/components.dart';
import 'package:lumen_kit_example/sections/control_states_section.dart';
import 'package:lumen_kit_example/sections/foundation_section.dart';
import 'package:lumen_kit_example/sections/stepper_section.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final entry in LumenStyle.presets.entries) {
      testWidgets(
        'new sections fit a narrow viewport in ${brightness.name} ${entry.key}',
        (tester) async {
          tester.view.physicalSize = const Size(420, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final palette = LumenPreset.neon.palette(brightness: brightness);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness),
              home: LumenScope(
                palette: palette,
                style: entry.value,
                child: Scaffold(
                  backgroundColor: palette.backgroundDeep,
                  body: MediaQuery(
                    data: const MediaQueryData(
                      disableAnimations: true,
                      textScaler: TextScaler.linear(1.3),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 28,
                        children: const <Widget>[
                          FoundationSection(),
                          ControlStatesSection(),
                          StepperSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));
          expect(tester.takeException(), isNull);

          final scrollable = find.byType(Scrollable).first;
          final position = tester.state<ScrollableState>(scrollable).position;
          while (position.pixels < position.maxScrollExtent) {
            await tester.drag(scrollable, const Offset(0, -600));
            await tester.pump(const Duration(milliseconds: 100));
            expect(tester.takeException(), isNull);
          }
          expect(find.byType(StepperSection), findsOneWidget);
        },
      );
    }
  }
}
