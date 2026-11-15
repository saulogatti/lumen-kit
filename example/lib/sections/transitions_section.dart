import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Interactive entrance and keyed content transition examples.
class TransitionsSection extends StatefulWidget {
  /// Creates the transition examples.
  const TransitionsSection({super.key});

  @override
  State<TransitionsSection> createState() => _TransitionsSectionState();
}

class _TransitionsSectionState extends State<TransitionsSection> {
  int _version = 0;

  @override
  Widget build(BuildContext context) => Column(
    spacing: 16,
    children: <Widget>[
      LumenButton(label: 'Replay transitions', onPressed: () => setState(() => _version++)),
      LumenEntrance(
        key: ValueKey<int>(_version),
        duration: const Duration(milliseconds: 500),
        child: const LumenCard(child: Text('Fade and slide entrance')),
      ),
      LumenAnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: LumenCard(key: ValueKey<int>(_version), child: Text('Content version $_version')),
      ),
    ],
  );
}
