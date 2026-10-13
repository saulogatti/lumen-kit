# lumen_kit

Kit de widgets Flutter com os mesmos desenhos e a cor livre. O visual neon (glow, gradiente, grid e orbs) é o estilo padrão; flat, glass, soft e brutal usam qualquer paleta. Pensado para reaproveitar entre projetos sem reescrever tokens e estilos a cada novo app.

## O que vem dentro

| Categoria   | Componentes                                                        |
|-------------|--------------------------------------------------------------------|
| Tema        | `AppColors`, `LumenPalette`, `LumenPreset`, `LumenStyle`, `LumenThemeExt`, `AppTheme` |
| Background  | `LumenAnimatedGridBackground`, `LumenGlowOrbSpec`                  |
| Estrutura   | `LumenAppBar`, `LumenCard`                                           |
| Ação        | `LumenCta`, `LumenButton`, `LumenIconButton`, `LumenFab`, `LumenMenuButton`, `LumenContextMenu` |
| Input       | `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenRangeSlider`, `LumenDropdown`, `LumenSearchBar`, `LumenDatePicker`, `LumenTimePicker`, `LumenChip` (+ `LumenChoiceChips`, `LumenFilterChips`), `LumenQuantityStepper`, `LumenRating`, `LumenPinField` |
| Feedback    | `LumenStatusChip`, `LumenBanner`, `LumenDialog`, `LumenSnackBar`, `LumenToast`, `LumenLinearProgress`, `LumenCircularProgress`, `LumenSkeleton`, `LumenTooltip`, `LumenLoadingOverlay` (+ `showLumenLoading`) |
| Navegação   | `LumenNavigationCard`, `LumenTabs`, `LumenSegmentedControl`, `LumenBottomNavBar`, `LumenNavRail`, `LumenBottomSheet`, `LumenDrawer`, `LumenStepper`, `LumenPageIndicator`, `LumenCarousel` |
| Display     | `LumenBadge`, `LumenTag`, `LumenAvatar`, `LumenAvatarGroup`, `LumenListTile`, `LumenList`, `LumenEmptyState`, `LumenDivider`, `LumenExpansionTile`, `LumenDataTable`, `LumenTableRow` |

Tudo desacoplado de domínio — recebe `child`, callbacks e tokens; não conhece nenhuma regra de negócio.

## Instalação

```yaml
dependencies:
  lumen_kit:
    git:
      url: https://github.com/saulogatti/lumen-kit.git
      ref: main
```

## Só os componentes (sem o tema)

Se o seu app já tem o próprio `ThemeData`, importe só os widgets:

```dart
import 'package:lumen_kit/components.dart';
```

Esse import não traz `AppTheme` nem `AppColors` (nada de conflito de nomes) e
não exige registrar nada no tema: os widgets usam a paleta default, clara ou
escura conforme o brilho do seu tema. Para outras cores ou outro estilo em
uma parte da tela, sem tocar no `ThemeData`, use `LumenScope`:

```dart
LumenScope(
  palette: LumenPalette.fromSeed(primary: Colors.teal),
  style: LumenStyle.flat,
  child: LumenButton(label: 'Salvar', onPressed: salvar),
)
```

Tipografia vem do `textTheme` do seu app. O import completo
(`package:lumen_kit/lumen_kit.dart`) continua igual, com tudo.

## Uso mínimo

```dart
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        appBar: const LumenAppBar(title: 'Dashboard', subtitle: 'em tempo real'),
        body: LumenAnimatedGridBackground(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LumenCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Serviço online'),
                  const SizedBox(height: 12),
                  const LumenStatusChip(label: 'OK', tone: LumenStatusTone.success),
                  const SizedBox(height: 20),
                  LumenCta(
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
MaterialApp(theme: AppTheme.fromPreset(LumenPreset.matrix), home: ...);

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
final palette = LumenPalette.defaultDark().copyWith(primary: Colors.greenAccent);
MaterialApp(theme: AppTheme.fromPalette(palette), home: ...);
```

Trocas de tema em runtime são animadas (`LumenThemeExt.lerp` interpola a
paleta). O app de `example/` tem um seletor de preset e modo claro/escuro.

> `accentCyan`, `accentMagenta` e `accentBlue` viraram `primary`, `secondary`
> e `tertiary`. Os nomes antigos continuam funcionando como `@Deprecated`.

Dentro de qualquer widget, acesse via extension:

```dart
final p = LumenThemeExt.of(context).palette;
return Container(color: p.surface);
```

## Trocando o estilo (além da cor)

O "neon" (glow, gradientes, grid) é só um dos estilos. `LumenStyle` controla
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
  theme: AppTheme.fromPreset(LumenPreset.matrix, style: LumenStyle.flat),
  home: ...,
);

// Ajuste fino a partir de um preset.
final style = LumenStyle.soft.copyWith(
  background: LumenBackgroundKind.grid,
  radiusScale: 1.2,
);
```

As animações dos widgets (hover, transições, toasts) continuam iguais em todos
os estilos.

## Montando componentes próprios

As peças que os widgets do kit usam por dentro também são públicas
(`package:lumen_kit/components.dart`), então um widget seu ganha o mesmo
comportamento e acompanha paleta e estilo sem copiar código:

```dart
final LumenPalette p = LumenThemeExt.of(context).palette;
final LumenStyle s = LumenStyle.of(context);

LumenPressable(                       // ripple, foco, desabilitado 0.55, semântica
  onTap: save,
  borderRadius: s.radius(14),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: LumenDecorations.panel(p, s, accent: p.secondary),
    child: LumenActionContent(color: p.textPrimary, icon: Icons.save, label: 'Salvar', busy: saving),
  ),
);
```

| Peça | Para quê |
|---|---|
| `LumenPressable` | Área tocável com ripple, teclado, `selected`/`checked`/`toggled` para leitores de tela e opacidade de desabilitado |
| `LumenDecorations` | `panel` (dialog/toast/tooltip), `selectable` (item de navegação), `iconBox`, `input` (`InputDecoration`), `accent`/`diagonal` (gradientes) |
| `LumenActionContent` | Spinner ou ícone + texto, como nos botões |
| `LumenLabeled` | Controle + rótulo (checkbox, radio, switch) |
| `LumenMotion` / `kLumen*` | Durações, opacidade de desabilitado e respeito a "reduzir animações" |

Animações em loop (skeleton, progresso indeterminado) e transições param ou
viram instantâneas quando o sistema pede para reduzir animações.

## Background configurável

```dart
LumenAnimatedGridBackground(
  gridSpacing: 80,
  gridOpacity: 0.08,
  orbs: const <LumenGlowOrbSpec>[
    LumenGlowOrbSpec(color: Colors.cyanAccent, size: 380, top: -120, left: -120),
    LumenGlowOrbSpec(
      color: Colors.purpleAccent,
      size: 320,
      bottom: -100,
      right: -80,
    ),
  ],
  child: child,
);
```

## Lista grande e código

`LumenList` usa `ListView.builder`: só o que está na tela é construído. Com
`itemCount: 0` ele mostra o `empty`.

```dart
LumenList(
  itemCount: eventos.length,
  empty: const LumenEmptyState(
    icon: Icons.inbox_outlined,
    title: 'Nenhum evento',
  ),
  itemBuilder: (context, i) => LumenListTile(
    title: eventos[i].titulo,
    onTap: () => abrir(eventos[i]),
  ),
)
```

`LumenPinField` é controlado (`value` + `onChanged`). `onChanged == null`
desabilita. `onCompleted` dispara quando a última casa preenche.

```dart
LumenPinField(
  value: _codigo,
  onChanged: (String v) => setState(() => _codigo = v),
  onCompleted: enviar,
)
```

`LumenBanner` fica na tela até `onDismiss`. Sem esse callback não há botão
de fechar.

## Variantes de botão

```dart
Row(
  children: <Widget>[
    LumenButton(label: 'CONFIRMAR', icon: Icons.check, onPressed: () {}),
    const SizedBox(width: 12),
    LumenButton.outline(label: 'EDITAR', icon: Icons.edit, onPressed: () {}),
    const SizedBox(width: 12),
    LumenButton.ghost(label: 'cancelar', onPressed: () {}),
  ],
);
```

- `solid` — gradiente neon cheio (mesma identidade do `LumenCta`).
- `outline` — borda glow + fundo translúcido. Ação secundária.
- `ghost` — só texto/ícone na cor de accent. Ação terciária.

## Inputs de seleção

```dart
LumenSwitch(value: on, onChanged: (v) => setState(() => on = v));

LumenCheckbox(value: checked, tristate: true, onChanged: (v) => …);

LumenRadio<String>(
  value: 'a',
  groupValue: selected,
  label: 'Opção A',
  onChanged: (v) => setState(() => selected = v ?? selected),
);

LumenDropdown<String>(
  label: 'Accent',
  value: current,
  items: const [
    LumenDropdownItem(value: 'cyan', label: 'Cyan'),
    LumenDropdownItem(value: 'magenta', label: 'Magenta'),
  ],
  onChanged: (v) => setState(() => current = v ?? current),
);

LumenDatePicker(
  label: 'Início',
  value: date,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (d) => setState(() => date = d),
);

LumenTimePicker(
  label: 'Horário',
  value: time,
  onChanged: (t) => setState(() => time = t),
);

LumenRangeSlider(
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
LumenChoiceChips<String>(
  value: tamanho,
  onChanged: (v) => setState(() => tamanho = v),
  items: const [
    LumenChipItem(value: 'p', label: 'P'),
    LumenChipItem(value: 'm', label: 'M'),
  ],
);

// Filtros (vários marcados). Recebe e devolve um Set novo.
LumenFilterChips<String>(
  values: filtros,
  onChanged: (v) => setState(() => filtros = v),
  items: const [
    LumenChipItem(value: 'promo', label: 'Promoção'),
    LumenChipItem(value: 'frete', label: 'Frete grátis'),
  ],
);

LumenQuantityStepper(value: qtd, min: 1, max: 10, onChanged: (v) => setState(() => qtd = v));

LumenRating(value: nota, allowHalf: true, onChanged: (v) => setState(() => nota = v));
LumenRating(value: 4.3, size: 16); // somente leitura, com fração
```

## Menu, loading e carrossel

```dart
// O "⋮" de card / app bar.
LumenMenuButton<String>(
  items: const [
    LumenMenuItem(value: 'edit', label: 'Editar', icon: Icons.edit),
    LumenMenuDivider(),
    LumenMenuItem(value: 'del', label: 'Excluir', destructive: true),
  ],
  onSelected: (v) => …,
);

// Clique direito (desktop/web) ou toque longo (mobile).
LumenContextMenu<String>(items: itens, onSelected: …, child: linha);

// Bloqueia a tela durante o submit e devolve o resultado da tarefa.
final ok = await showLumenLoading(
  context: context,
  message: 'Enviando…',
  task: () => api.enviar(form),
);

// Ou só uma área, controlada por estado.
LumenLoadingOverlay(loading: salvando, message: 'Salvando…', child: form);

// Galeria / onboarding com os pontinhos de página.
LumenCarousel(
  itemCount: fotos.length,
  itemBuilder: (context, i) => Image.network(fotos[i], fit: BoxFit.cover),
);
// Ou só os pontos, ligados ao seu PageView.
LumenPageIndicator(count: 4, controller: pageController);

// Avatares empilhados com "+N".
LumenAvatarGroup(
  avatars: [for (final u in membros) LumenAvatar(initials: u.iniciais)],
  maxVisible: 3,
  total: totalDeMembros,
);
```

## Navegação

```dart
// Pílula compacta — ótima para alternar visões dentro de uma tela.
LumenSegmentedControl(
  selectedIndex: i,
  onChanged: (v) => setState(() => i = v),
  items: const [
    LumenTabItem(label: 'Dia'),
    LumenTabItem(label: 'Semana'),
    LumenTabItem(label: 'Mês'),
  ],
);

// Bottom nav com badge.
Scaffold(
  bottomNavigationBar: LumenBottomNavBar(
    selectedIndex: tab,
    onChanged: (v) => setState(() => tab = v),
    items: const [
      LumenNavItem(icon: Icons.home_outlined, label: 'Home'),
      LumenNavItem(icon: Icons.bolt_outlined, label: 'Eventos', badge: '3'),
      LumenNavItem(icon: Icons.person_outline, label: 'Conta'),
    ],
  ),
);

// Modal bottom sheet temático.
showLumenBottomSheet<void>(
  context: context,
  builder: (_) => const Padding(
    padding: EdgeInsets.all(20),
    child: Text('Ações rápidas'),
  ),
);
```

## Dialog estilizado

```dart
await showLumenDialog<void>(
  context: context,
  title: 'Confirmar ação',
  icon: Icons.warning_amber_rounded,
  content: const Text('Esta operação não pode ser desfeita.'),
  actions: <Widget>[
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
    LumenCta(label: 'CONFIRMAR', onPressed: () => Navigator.pop(context)),
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
