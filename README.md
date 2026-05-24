# neon_ui

Kit de UI com tema futurístico **dark neon** para Flutter — paleta opinativa, fundo com grid + glow orbs nos cantos e um conjunto de widgets prontos com identidade visual consistente. Pensado para reaproveitar entre projetos sem precisar reescrever tokens e estilos a cada novo app.

## O que vem dentro

| Categoria   | Componentes                                                        |
|-------------|--------------------------------------------------------------------|
| Tema        | `AppColors`, `NeonPalette`, `NeonThemeExt`, `AppTheme`             |
| Background  | `AnimatedGridBackground`, `GlowOrbSpec`                            |
| Estrutura   | `NeonAppBar`, `NeonCard`                                           |
| Ação        | `GradientCta`, `NeonButton`, `NeonIconButton`, `NeonFab`           |
| Input       | `NeonTextField`, `NeonSwitch`, `NeonCheckbox`, `NeonRadio`, `NeonSlider`, `NeonDropdown`, `NeonSearchBar`, `NeonDatePicker` |
| Feedback    | `StatusChip`, `NeonDialog`, `NeonSnackBar`, `NeonToast`, `NeonLinearProgress`, `NeonCircularProgress`, `NeonSkeleton`, `NeonTooltip` |
| Navegação   | `NavigationCard`, `NeonTabs`, `NeonSegmentedControl`, `NeonBottomNavBar`, `NeonNavRail`, `NeonBottomSheet`, `NeonDrawer`, `NeonStepper` |
| Display     | `NeonBadge`, `NeonTag`, `NeonAvatar`, `NeonListTile`, `NeonDivider`, `NeonExpansionTile`, `NeonDataTable`, `NeonTableRow` |

Tudo desacoplado de domínio — recebe `child`, callbacks e tokens; não conhece nenhuma regra de negócio.

## Instalação

```yaml
dependencies:
  neon_ui:
    git:
      url: https://github.com/saulogatti/flutter-neon-ui.git
      ref: main
```

## Uso mínimo

```dart
import 'package:flutter/material.dart';
import 'package:neon_ui/neon_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        appBar: const NeonAppBar(title: 'Dashboard', subtitle: 'em tempo real'),
        body: AnimatedGridBackground(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: NeonCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Serviço online'),
                  const SizedBox(height: 12),
                  const StatusChip(label: 'OK', tone: StatusTone.success),
                  const SizedBox(height: 20),
                  GradientCta(
                    label: 'EXECUTAR',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Customizando a paleta

```dart
final palette = NeonPalette.defaultDark().copyWith(
  accentCyan: Colors.greenAccent,
  accentMagenta: Colors.orangeAccent,
);

MaterialApp(theme: AppTheme.fromPalette(palette), home: ...);
```

Dentro de qualquer widget, acesse via extension:

```dart
final p = NeonThemeExt.of(context).palette;
return Container(color: p.surface);
```

## Background configurável

```dart
AnimatedGridBackground(
  gridSpacing: 80,
  gridOpacity: 0.08,
  orbs: const <GlowOrbSpec>[
    GlowOrbSpec(color: Colors.cyanAccent, size: 380, top: -120, left: -120),
    GlowOrbSpec(color: Colors.purpleAccent, size: 320, bottom: -100, right: -80),
  ],
  child: child,
);
```

## Variantes de botão

```dart
Row(
  children: <Widget>[
    NeonButton(label: 'CONFIRMAR', icon: Icons.check, onPressed: () {}),
    const SizedBox(width: 12),
    NeonButton.outline(label: 'EDITAR', icon: Icons.edit, onPressed: () {}),
    const SizedBox(width: 12),
    NeonButton.ghost(label: 'cancelar', onPressed: () {}),
  ],
);
```

- `solid` — gradiente neon cheio (mesma identidade do `GradientCta`).
- `outline` — borda glow + fundo translúcido. Ação secundária.
- `ghost` — só texto/ícone na cor de accent. Ação terciária.

## Inputs de seleção

```dart
NeonSwitch(value: on, onChanged: (v) => setState(() => on = v));

NeonCheckbox(value: checked, tristate: true, onChanged: (v) => …);

NeonRadio<String>(
  value: 'a',
  groupValue: selected,
  label: 'Opção A',
  onChanged: (v) => setState(() => selected = v ?? selected),
);

NeonDropdown<String>(
  label: 'Accent',
  value: current,
  items: const [
    NeonDropdownItem(value: 'cyan', label: 'Cyan'),
    NeonDropdownItem(value: 'magenta', label: 'Magenta'),
  ],
  onChanged: (v) => setState(() => current = v ?? current),
);

NeonDatePicker(
  label: 'Início',
  value: date,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (d) => setState(() => date = d),
);
```

## Navegação

```dart
// Pílula compacta — ótima para alternar visões dentro de uma tela.
NeonSegmentedControl(
  selectedIndex: i,
  onChanged: (v) => setState(() => i = v),
  items: const [
    NeonTabItem(label: 'Dia'),
    NeonTabItem(label: 'Semana'),
    NeonTabItem(label: 'Mês'),
  ],
);

// Bottom nav com badge.
Scaffold(
  bottomNavigationBar: NeonBottomNavBar(
    selectedIndex: tab,
    onChanged: (v) => setState(() => tab = v),
    items: const [
      NeonNavItem(icon: Icons.home_outlined, label: 'Home'),
      NeonNavItem(icon: Icons.bolt_outlined, label: 'Eventos', badge: '3'),
      NeonNavItem(icon: Icons.person_outline, label: 'Conta'),
    ],
  ),
);

// Modal bottom sheet temático.
showNeonBottomSheet<void>(
  context: context,
  builder: (_) => const Padding(
    padding: EdgeInsets.all(20),
    child: Text('Ações rápidas'),
  ),
);
```

## Dialog estilizado

```dart
await showNeonDialog<void>(
  context: context,
  title: 'Confirmar ação',
  icon: Icons.warning_amber_rounded,
  content: const Text('Esta operação não pode ser desfeita.'),
  actions: <Widget>[
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
    GradientCta(label: 'CONFIRMAR', onPressed: () => Navigator.pop(context)),
  ],
);
```

## App de exemplo

Há um app demo em [`example/`](example/) com uma única tela que exercita todos os componentes do kit — cards, status, botões, icon buttons, FAB, inputs (texto, busca, switch, checkbox, radio, slider, dropdown, date picker), progresso linear/circular, skeleton, snackbar, toast, dialog, bottom sheet, tabs, segmented, bottom nav, drawer, stepper, avatar, badge, tag, list tile, divider, expansion tile, data table e navigation cards.

```bash
cd example
flutter pub get
flutter run
```

## Status

Em desenvolvimento ativo — API ainda pode mudar entre versões `0.x`. Use `ref: <commit-sha>` ou tags (`ref: v0.1.0`) em produção para evitar quebras silenciosas vindas da `main`.
