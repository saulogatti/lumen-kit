import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

/// Checkbox quadrado com borda accent e marcador em gradiente quando ativo.
class NeonCheckbox extends StatelessWidget {
  const NeonCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.label,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Color? accentColor;
  final String? label;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;
    final bool disabled = onChanged == null;
    final bool isChecked = value == true;
    final bool isIndeterminate = value == null && tristate;

    void toggle() {
      if (disabled) return;
      if (tristate) {
        if (value == false) {
          onChanged!(true);
        } else if (value == true) {
          onChanged!(null);
        } else {
          onChanged!(false);
        }
      } else {
        onChanged!(!isChecked);
      }
    }

    final Widget box = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: isChecked || isIndeterminate
            ? LinearGradient(
                colors: <Color>[accent, p.accentMagenta],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: (isChecked || isIndeterminate)
            ? null
            : p.surface.withValues(alpha: 0.7),
        border: Border.all(
          color: (isChecked || isIndeterminate)
              ? accent
              : p.surfaceOutline.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: (isChecked || isIndeterminate)
            ? <BoxShadow>[
                BoxShadow(
                  color: accent.withValues(alpha: 0.45),
                  blurRadius: 10,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      child: isIndeterminate
          ? Center(
              child: Container(
                width: 10,
                height: 2,
                color: p.textPrimary,
              ),
            )
          : isChecked
              ? Icon(Icons.check_rounded, size: 16, color: p.textPrimary)
              : null,
    );

    final Widget content = Opacity(
      opacity: disabled ? 0.55 : 1,
      child: InkWell(
        onTap: disabled ? null : toggle,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: label == null
              ? box
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    box,
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        label!,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color:
                                      disabled ? p.textMuted : p.textPrimary,
                                ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );

    return content;
  }
}
