import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// TextField estilizado para o formulário de cadastro.
/// Mantém o próprio controller para preservar foco/cursor entre rebuilds.
class NeonTextField extends StatefulWidget {
  const NeonTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    super.key,
    this.errorText,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  @override
  State<NeonTextField> createState() => _NeonTextFieldState();
}

class _NeonTextFieldState extends State<NeonTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        prefixIcon: widget.icon == null
            ? null
            : Icon(widget.icon, color: AppColors.accentCyan),
        suffixIcon: widget.suffix,
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.7),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.accentCyan.withValues(alpha: 0.35),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentCyan, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        ),
      ),
    );
  }
}
