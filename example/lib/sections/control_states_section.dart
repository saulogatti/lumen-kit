import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

/// Demonstrates interactive, disabled, loading, and validation states.
class ControlStatesSection extends StatefulWidget {
  /// Creates the control state demonstrations.
  const ControlStatesSection({super.key});

  @override
  State<ControlStatesSection> createState() => _ControlStatesSectionState();
}

class _ControlStatesSectionState extends State<ControlStatesSection>
    with AutomaticKeepAliveClientMixin<ControlStatesSection> {
  static const _accents = <LumenDropdownItem<String>>[
    LumenDropdownItem(value: 'primary', label: 'Primary'),
    LumenDropdownItem(value: 'secondary', label: 'Secondary'),
  ];

  final _formKey = GlobalKey<FormState>();
  int _actions = 0;
  bool? _checked;
  bool _notifications = true;
  String _radio = 'primary';
  String? _accent = 'primary';
  String? _requiredAccent;
  bool _valid = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final LumenPalette p = LumenThemeExt.of(context).palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: <Widget>[
        _heading(context, 'Button states'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            LumenButton(
              label: 'Run action',
              onPressed: () => setState(() => _actions++),
            ),
            const LumenButton(label: 'Disabled action', onPressed: null),
            LumenButton(
              label: 'Working',
              busy: true,
              onPressed: () => setState(() => _actions++),
            ),
          ],
        ),
        Text(
          'Actions completed: $_actions',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: p.textSecondary),
        ),
        _heading(context, 'Selection states'),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: <Widget>[
            LumenCheckbox(
              label: 'Three-state checkbox',
              value: _checked,
              tristate: true,
              onChanged: (value) => setState(() => _checked = value),
            ),
            const LumenCheckbox(
              label: 'Disabled checkbox',
              value: true,
              onChanged: null,
            ),
          ],
        ),
        Text(
          'Checkbox: ${_checked == null
              ? 'indeterminate'
              : _checked!
              ? 'checked'
              : 'unchecked'}',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: p.textSecondary),
        ),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: <Widget>[
            for (final accent in _accents)
              LumenRadio<String>(
                value: accent.value,
                groupValue: _radio,
                label: '${accent.label} option',
                onChanged: (value) => setState(() => _radio = value!),
              ),
            LumenRadio<String>(
              value: 'disabled',
              groupValue: _radio,
              label: 'Disabled option',
              onChanged: null,
            ),
          ],
        ),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: <Widget>[
            LumenSwitch(
              label: 'Live notifications',
              value: _notifications,
              onChanged: (value) => setState(() => _notifications = value),
            ),
            const LumenSwitch(
              label: 'Disabled notifications',
              value: false,
              onChanged: null,
            ),
          ],
        ),
        _heading(context, 'Text field states'),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: <Widget>[
              LumenTextField(
                key: const ValueKey('state-project-name'),
                label: 'Project name to validate',
                helperText: 'Enter at least three characters.',
                validator: (value) => (value ?? '').trim().length < 3
                    ? 'Use at least three characters.'
                    : null,
                onChanged: (_) {
                  if (_valid) setState(() => _valid = false);
                },
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: LumenButton.outline(
                  label: 'Validate project',
                  onPressed: () => setState(
                    () => _valid = _formKey.currentState!.validate(),
                  ),
                ),
              ),
              if (_valid)
                Text(
                  'Project is valid.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: p.success),
                ),
            ],
          ),
        ),
        const LumenTextField(
          label: 'Read-only project',
          initialValue: 'Telemetry dashboard',
          readOnly: true,
          helperText: 'Select and copy this value.',
        ),
        const LumenTextField(
          label: 'Disabled project',
          initialValue: 'Archived dashboard',
          enabled: false,
        ),
        _heading(context, 'Dropdown states'),
        LumenDropdown<String>(
          key: const ValueKey('state-accent'),
          label: 'Editable accent',
          value: _accent,
          items: _accents,
          onChanged: (value) => setState(() => _accent = value),
        ),
        const LumenDropdown<String>(
          label: 'Disabled accent',
          value: 'primary',
          items: _accents,
          onChanged: null,
        ),
        LumenDropdown<String>(
          label: 'Required accent',
          value: _requiredAccent,
          hint: 'Choose an accent',
          errorText: _requiredAccent == null
              ? 'Choose an accent to clear this error.'
              : null,
          items: _accents,
          onChanged: (value) => setState(() => _requiredAccent = value),
        ),
        _heading(context, 'Disabled PIN and sliders'),
        const LumenPinField(
          value: '123456',
          onChanged: null,
          semanticLabel: 'Disabled verification code',
        ),
        Text(
          'Disabled volume: 40%',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: p.textSecondary),
        ),
        const LumenSlider(value: 0.4, onChanged: null),
        Text(
          'Disabled range: 20–80',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: p.textSecondary),
        ),
        const LumenRangeSlider(
          values: RangeValues(20, 80),
          max: 100,
          onChanged: null,
        ),
      ],
    );
  }

  Widget _heading(BuildContext context, String text) {
    final LumenPalette p = LumenThemeExt.of(context).palette;
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: p.textPrimary),
    );
  }
}
