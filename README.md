# neon_ui

Kit de UI com tema futurístico **dark neon** para Flutter — paleta opinativa, fundo com grid + glow orbs nos cantos e um conjunto de widgets prontos com identidade visual consistente. Pensado para reaproveitar entre projetos sem precisar reescrever tokens e estilos a cada novo app.

## O que vem dentro

| Categoria   | Componentes                                                        |
|-------------|--------------------------------------------------------------------|
| Tema        | `AppColors`, `NeonPalette`, `NeonPreset`, `NeonStyle`, `NeonThemeExt`, `AppTheme` |
| Background  | `AnimatedGridBackground`, `GlowOrbSpec`                            |
| Estrutura   | `NeonAppBar`, `NeonCard`                                           |
| Ação        | `GradientCta`, `NeonButton`, `NeonIconButton`, `NeonFab`, `NeonMenuButton`, `NeonContextMenu` |
| Input       | `NeonTextField`, `NeonSwitch`, `NeonCheckbox`, `NeonRadio`, `NeonSlider`, `NeonRangeSlider`, `NeonDropdown`, `NeonSearchBar`, `NeonDatePicker`, `NeonTimePicker`, `NeonChip` (+ `NeonChoiceChips`, `NeonFilterChips`), `NeonQuantityStepper`, `NeonRating` |
| Feedback    | `StatusChip`, `NeonDialog`, `NeonSnackBar`, `NeonToast`, `NeonLinearProgress`, `NeonCircularProgress`, `NeonSkeleton`, `NeonTooltip`, `NeonLoadingOverlay` (+ `showNeonLoading`) |
| Navegação   | `NavigationCard`, `NeonTabs`, `NeonSegmentedControl`, `NeonBottomNavBar`, `NeonNavRail`, `NeonBottomSheet`, `NeonDrawer`, `NeonStepper`, `NeonPageIndicator`, `NeonCarousel` |
| Display     | `NeonBadge`, `NeonTag`, `NeonAvatar`, `NeonAvatarGroup`, `NeonListTile`, `NeonDivider`, `NeonExpansionTile`, `NeonDataTable`, `NeonTableRow` |

Tudo desacoplado de domínio — recebe `child`, callbacks e tokens; não conhece nenhuma regra de negócio.

## Instalação

```yaml
dependencies:
  neon_ui:
    git:
      url: https://github.com/saulogatti/flutter-neon-ui.git
      ref: main
```

## Só os componentes (sem o tema)

Se o seu app já tem o próprio `ThemeData`, importe só os widgets:

```dart
import 'package:neon_ui/components.dart';
```

Esse import não traz `AppTheme` nem `AppColors` (nada de conflito de nomes) e
não exige registrar nada no tema: os widgets usam a paleta default, clara ou
escura conforme o brilho do seu tema. Para outras cores ou outro estilo em
uma parte da tela, sem tocar no `ThemeData`, use `NeonScope`:

```dart
NeonScope(
  palette: NeonPalette.fromSeed(primary: Colors.teal),
  style: NeonStyle.flat,
  child: NeonButton(label: 'Salvar', onPressed: salvar),
)
```

Tipografia vem do `textTheme` do seu app. O import completo
(`package:neon_ui/neon_ui.dart`) continua igual, com tudo.

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

## Trocando as cores

Todos os widgets leem a paleta do tema, então trocar o tema troca o kit inteiro.
Do mais simples ao mais detalhado:

```dart
// 1. Preset pronto: neon (default), matrix, synthwave, ultraviolet, ember.
MaterialApp(theme: AppTheme.fromPreset(NeonPreset.matrix), home: ...);

// 2. Uma ou duas cores: fundos, superfícies, textos, glows e gradientes
//    são derivados automaticamente.
MaterialApp(
  theme: AppTheme.fromSeed(
    primary: Colors.greenAccent,
    secondary: Colors.orangeAccent, // opcional
    brightness: Brightness.dark,     // ou Brightness.light
  ),
  home: ...,
);

// 3. Ajuste fino de tokens específicos (gradientes se recalculam sozinhos).
final palette = NeonPalette.defaultDark().copyWith(primary: Colors.greenAccent);
MaterialApp(theme: AppTheme.fromPalette(palette), home: ...);
```

Trocas de tema em runtime são animadas (`NeonThemeExt.lerp` interpola a
paleta). O app de `example/` tem um seletor de preset e modo claro/escuro.

> `accentCyan`, `accentMagenta` e `accentBlue` viraram `primary`, `secondary`
> e `tertiary`. Os nomes antigos continuam funcionando como `@Deprecated`.

Dentro de qualquer widget, acesse via extension:

```dart
final p = NeonThemeExt.of(context).palette;
return Container(color: p.surface);
```

## Trocando o estilo (além da cor)

O "neon" (glow, gradientes, grid) é só um dos estilos. `NeonStyle` controla
sombra, preenchimento, superfície, borda e fundo, e combina com qualquer paleta:

| Estilo   | Visual                                                        |
|----------|---------------------------------------------------------------|
| `neon`   | Glow colorido, gradientes, grid + orbs (default)              |
| `flat`   | Sem glow nem gradiente, sombra neutra, fundo liso             |
| `glass`  | Superfícies translúcidas com blur, glow suave                 |
| `soft`   | Cantos bem redondos, sombras difusas, sem borda, fundo pontilhado |
| `brutal` | Cantos retos, borda grossa, sombra dura deslocada             |

```dart
MaterialApp(
  theme: AppTheme.fromPreset(NeonPreset.matrix, style: NeonStyle.flat),
  home: ...,
);

// Ajuste fino a partir de um preset.
final style = NeonStyle.soft.copyWith(
  background: NeonBackgroundKind.grid,
  radiusScale: 1.2,
);
```

As animações dos widgets (hover, transições, toasts) continuam iguais em todos
os estilos.

## Montando componentes próprios

As peças que os widgets do kit usam por dentro também são públicas
(`package:neon_ui/components.dart`), então um widget seu ganha o mesmo
comportamento e acompanha paleta e estilo sem copiar código:

```dart
final NeonPalette p = NeonThemeExt.of(context).palette;
final NeonStyle s = NeonStyle.of(context);

NeonPressable(                       // ripple, foco, desabilitado 0.55, semântica
  onTap: save,
  borderRadius: s.radius(14),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: NeonDecorations.panel(p, s, accent: p.secondary),
    child: NeonActionContent(color: p.textPrimary, icon: Icons.save, label: 'Salvar', busy: saving),
  ),
);
```

| Peça | Para quê |
|---|---|
| `NeonPressable` | Área tocável com ripple, teclado, `selected`/`checked`/`toggled` para leitores de tela e opacidade de desabilitado |
| `NeonDecorations` | `panel` (dialog/toast/tooltip), `selectable` (item de navegação), `iconBox`, `input` (`InputDecoration`), `accent`/`diagonal` (gradientes) |
| `NeonActionContent` | Spinner ou ícone + texto, como nos botões |
| `NeonLabeled` | Controle + rótulo (checkbox, radio, switch) |
| `NeonMotion` / `kNeon*` | Durações, opacidade de desabilitado e respeito a "reduzir animações" |

Animações em loop (skeleton, progresso indeterminado) e transições param ou
viram instantâneas quando o sistema pede para reduzir animações.

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

NeonTimePicker(
  label: 'Horário',
  value: time,
  onChanged: (t) => setState(() => time = t),
);

NeonRangeSlider(
  values: preco,
  max: 500,
  divisions: 50,
  onChanged: (v) => setState(() => preco = v),
  onChangeEnd: (v) => buscar(v), // dispara a busca só ao soltar
);
```

## Chips, quantidade e avaliação

```dart
// Escolha única.
NeonChoiceChips<String>(
  value: tamanho,
  onChanged: (v) => setState(() => tamanho = v),
  items: const [
    NeonChipItem(value: 'p', label: 'P'),
    NeonChipItem(value: 'm', label: 'M'),
  ],
);

// Filtros (vários marcados). Recebe e devolve um Set novo.
NeonFilterChips<String>(
  values: filtros,
  onChanged: (v) => setState(() => filtros = v),
  items: const [
    NeonChipItem(value: 'promo', label: 'Promoção'),
    NeonChipItem(value: 'frete', label: 'Frete grátis'),
  ],
);

NeonQuantityStepper(value: qtd, min: 1, max: 10, onChanged: (v) => setState(() => qtd = v));

NeonRating(value: nota, allowHalf: true, onChanged: (v) => setState(() => nota = v));
NeonRating(value: 4.3, size: 16); // somente leitura, com fração
```

## Menu, loading e carrossel

```dart
// O "⋮" de card / app bar.
NeonMenuButton<String>(
  items: const [
    NeonMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
    NeonMenuDivider(),
    NeonMenuItem(value: 'del', label: 'Excluir', destructive: true),
  ],
  onSelected: (v) => …,
);

// Clique direito (desktop/web) ou toque longo (mobile).
NeonContextMenu<String>(items: itens, onSelected: …, child: linha);

// Bloqueia a tela durante o submit e devolve o resultado da tarefa.
final ok = await showNeonLoading(
  context: context,
  message: 'Enviando…',
  task: () => api.enviar(form),
);

// Ou só uma área, controlada por estado.
NeonLoadingOverlay(loading: salvando, message: 'Salvando…', child: form);

// Galeria / onboarding com os pontinhos de página.
NeonCarousel(
  itemCount: fotos.length,
  itemBuilder: (context, i) => Image.network(fotos[i], fit: BoxFit.cover),
);
// Ou só os pontos, ligados ao seu PageView.
NeonPageIndicator(count: 4, controller: pageController);

// Avatares empilhados com "+N".
NeonAvatarGroup(
  avatars: [for (final u in membros) NeonAvatar(initials: u.iniciais)],
  maxVisible: 3,
  total: totalDeMembros,
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

Há um app demo em [`example/`](example/) com uma única tela que exercita todos os componentes do kit — cards, status, botões, icon buttons, FAB, inputs (texto, busca, switch, checkbox, radio, slider, range slider, dropdown, date e time picker), chips de escolha e filtro, quantity stepper, rating, menu de ações e de contexto, loading overlay, carrossel, progresso linear/circular, skeleton, snackbar, toast, dialog, bottom sheet, tabs, segmented, bottom nav, drawer, stepper, avatar, avatar group, badge, tag, list tile, divider, expansion tile, data table e navigation cards.

```bash
cd example
flutter pub get
flutter run
```

## Status

Em desenvolvimento ativo — API ainda pode mudar entre versões `0.x`. Use `ref: <commit-sha>` ou tags (`ref: v0.1.0`) em produção para evitar quebras silenciosas vindas da `main`.
