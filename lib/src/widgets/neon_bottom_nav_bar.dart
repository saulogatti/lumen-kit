import 'package:flutter/material.dart';

import '../theme/neon_palette.dart';

/// Item de [NeonBottomNavBar] / [NeonNavRail].
class NeonNavItem {
  const NeonNavItem({required this.icon, required this.label, this.badge});

  final IconData icon;
  final String label;

  /// Pequeno texto exibido como badge sobre o ícone (ex: "3", "•").
  final String? badge;
}

/// Barra inferior com 3-5 itens, item selecionado destacado com pílula glow.
class NeonBottomNavBar extends StatelessWidget {
  const NeonBottomNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
  });

  final List<NeonNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;

    return Container(
      decoration: BoxDecoration(
        color: p.backgroundMid.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: p.surfaceOutline.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: List<Widget>.generate(items.length, (int i) {
            final bool selected = i == selectedIndex;
            final NeonNavItem it = items[i];
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected
                        ? accent.withValues(alpha: 0.16)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? accent.withValues(alpha: 0.55)
                          : Colors.transparent,
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: accent.withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          Icon(
                            it.icon,
                            color: selected ? accent : p.textMuted,
                            size: 22,
                          ),
                          if (it.badge != null)
                            Positioned(
                              right: -6,
                              top: -4,
                              child: _Badge(text: it.badge!, color: p.danger),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        it.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? p.textPrimary : p.textMuted,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Variante lateral (tablet / desktop).
class NeonNavRail extends StatelessWidget {
  const NeonNavRail({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
    this.accentColor,
    this.leading,
    this.trailing,
  });

  final List<NeonNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final Color? accentColor;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final NeonPalette p = NeonThemeExt.of(context).palette;
    final Color accent = accentColor ?? p.accentCyan;

    return Container(
      width: 84,
      decoration: BoxDecoration(
        color: p.backgroundMid.withValues(alpha: 0.95),
        border: Border(
          right: BorderSide(color: p.surfaceOutline.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              const SizedBox(height: 12),
              leading!,
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemBuilder: (BuildContext _, int i) {
                  final bool selected = i == selectedIndex;
                  final NeonNavItem it = items[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      onTap: () => onChanged(i),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: selected
                              ? accent.withValues(alpha: 0.16)
                              : Colors.transparent,
                          border: Border.all(
                            color: selected
                                ? accent.withValues(alpha: 0.55)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Icon(
                              it.icon,
                              color: selected ? accent : p.textMuted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              it.label,
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    selected ? p.textPrimary : p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (trailing != null) ...<Widget>[
              trailing!,
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: <BoxShadow>[
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
