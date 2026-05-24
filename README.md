# neon_ui

Kit de UI com tema futurístico **dark neon** para Flutter — paleta opinativa, fundo com grid + glow orbs nos cantos e um conjunto de widgets prontos com identidade visual consistente. Pensado para reaproveitar entre projetos sem precisar reescrever tokens e estilos a cada novo app.

## O que vem dentro

| Categoria   | Componentes                                                        |
|-------------|--------------------------------------------------------------------|
| Tema        | `AppColors`, `NeonPalette`, `NeonThemeExt`, `AppTheme`             |
| Background  | `AnimatedGridBackground`, `GlowOrbSpec`                            |
| Estrutura   | `NeonAppBar`, `NeonCard`                                           |
| Ação        | `GradientCta`                                                      |
| Input       | `NeonTextField`                                                    |
| Feedback    | `StatusChip`, `NeonDialog`, `NeonSnackBar`, `NeonToast`, `NeonLinearProgress`, `NeonCircularProgress`, `NeonSkeleton`, `NeonTooltip` |
| Navegação   | `NavigationCard`                                                   |

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

## Status

Em desenvolvimento ativo — API ainda pode mudar entre versões `0.x`. Use `ref: <commit-sha>` ou tags (`ref: v0.1.0`) em produção para evitar quebras silenciosas vindas da `main`.
