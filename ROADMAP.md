# Roadmap — neon_ui

Componentes planejados para o kit. Marque conforme forem entregues.

## Já implementado

- [x] **Tema**: `AppColors`, `NeonPalette` (+ `fromSeed`), `NeonPreset`, `NeonStyle` (neon / flat / glass / soft / brutal), `NeonThemeExt`, `AppTheme`
- [x] **Background**: `AnimatedGridBackground`, `GlowOrbSpec`
- [x] **Base reaproveitável**: `NeonPressable`, `NeonDecorations`, `NeonActionContent`, `NeonLabeled`, `NeonMotion`
- [x] **Estrutura**: `NeonAppBar`, `NeonCard`
- [x] **Ações**: `GradientCta`, `NeonButton` (solid / outline / ghost), `NeonIconButton`, `NeonFab`
- [x] **Input**: `NeonTextField`, `NeonSwitch`, `NeonCheckbox`, `NeonRadio`, `NeonSlider`, `NeonDropdown`, `NeonSearchBar`, `NeonDatePicker` (+ `showNeonDatePicker`)
- [x] **Feedback**: `StatusChip`, `NeonDialog` (+ `showNeonDialog`), `NeonSnackBar` (+ `showNeonSnackBar`), `NeonToast`, `NeonProgressIndicator`, `NeonSkeleton`, `NeonTooltip`
- [x] **Navegação**: `NavigationCard`, `NeonTabs`, `NeonSegmentedControl`, `NeonBottomNavBar`, `NeonNavRail`, `NeonBottomSheet` (+ `showNeonBottomSheet`), `NeonDrawer` (+ `NeonDrawerItem`), `NeonStepper`
- [x] **Display**: `NeonBadge`, `NeonTag`, `NeonAvatar`, `NeonListTile`, `NeonDivider`, `NeonExpansionTile`, `NeonDataTable` (+ `NeonTableRow`)

## A fazer

### Inputs / formulários

- [x] `NeonSwitch`
- [x] `NeonCheckbox`
- [x] `NeonRadio`
- [x] `NeonSlider`
- [x] `NeonDropdown` / `NeonSelect`
- [x] `NeonSearchBar`
- [x] `NeonDatePicker` (wrapper temático)

### Feedback / status

- [x] `NeonSnackBar` (+ `showNeonSnackBar`)
- [x] `NeonToast`
- [x] `NeonProgressIndicator` (linear e circular com glow)
- [x] `NeonSkeleton` / shimmer loader
- [x] `NeonTooltip`

### Navegação / layout

- [x] `NeonTabs` / `NeonSegmentedControl`
- [x] `NeonBottomNavBar` ou `NeonNavRail`
- [x] `NeonBottomSheet` (+ `showNeonBottomSheet`)
- [x] `NeonDrawer`
- [x] `NeonStepper`

### Display / dados

- [x] `NeonBadge` / `NeonTag` (variação menor que `StatusChip`)
- [x] `NeonAvatar`
- [x] `NeonListTile`
- [x] `NeonDivider` (com gradiente)
- [x] `NeonExpansionTile`
- [x] `NeonDataTable` (ou ao menos `NeonTableRow`)

## Convenções

- Arquivo por widget em `lib/src/widgets/`.
- Paleta sempre acessada via `NeonThemeExt.of(context).palette` — nunca importar `AppColors` diretamente em widgets (senão a cor ignora `AppTheme.fromSeed` e os presets).
- Sombra, gradiente, raio e borda sempre via `NeonStyle.of(context)` (`shadows`, `fill`, `radius`, `borderAll`, `surfaceAlpha`) — nunca `BoxShadow`/`BorderRadius.circular` crus, senão o widget ignora o estilo.
- Exportar widgets em `lib/components.dart` (o `lib/neon_ui.dart` reexporta). Nada de tema global (`AppTheme`/`AppColors`) dentro de widgets.
- Estados padrão a suportar quando fizer sentido: `onPressed == null` → desabilitado (`kNeonDisabledOpacity`), `busy: true` → spinner inline.
- Antes de escrever `Opacity` + `InkWell`, gradiente diagonal, painel com borda/glow ou `InputDecoration` na mão, use as peças de `lib/src/foundation/` (`NeonPressable`, `NeonDecorations`, `NeonActionContent`, `NeonLabeled`).
- Nada de `GestureDetector` para ações: sem foco de teclado nem semântica. Use `NeonPressable`.
- Animações: controllers e `CurvedAnimation` criados uma vez no `State` (nunca no `build`), durações via `NeonMotion.duration` e loops via `NeonMotion.syncRepeat`.
- Espaço entre filhos de `Row`/`Column` com `spacing:` em vez de `SizedBox` intercalado.
- Documentar uso mínimo no `README.md` quando o componente sair do roadmap.



O kit já cobre o básico com folga: 33 arquivos em `lib/src/widgets` no main, incluindo NavRail, SegmentedControl e Tag. O que falta, do mais útil para o menos:

1. **NeonChip selecionável (filter/choice)**: hoje `StatusChip` e `NeonTag` só exibem, e não dá pra montar filtros com eles.
2. **NeonTimePicker**: já existe o de data, e um formulário de agendamento fica pela metade sem hora.
3. **NeonRangeSlider**: filtro de preço ou intervalo é caso clássico, e o slider atual tem um valor só.
4. **NeonMenu / popup menu**: não existe menu contextual nem o "⋮" de ações em card ou app bar.
5. **NeonBanner / alerta inline**: Toast e SnackBar somem sozinhos. Falta um aviso que fica na tela até alguém fechar.
6. **NeonEmptyState**: tela vazia com ícone, texto e CTA aparece em qualquer app, e hoje cada um vai reinventar.
7. **NeonPinField (OTP)**: login com código é padrão, e o `NeonTextField` não resolve isso.
8. **NeonPageIndicator / Carousel**: onboarding e galerias precisam dos pontinhos de página.
9. **NeonQuantityStepper (− 1 +)**: input numérico de carrinho e configurações. É diferente do `NeonStepper`, que é de etapas.
10. **NeonRating**: estrelas para avaliação, barato de fazer e muito pedido.
11. **NeonAvatarGroup**: avatares empilhados com "+3", complementa o `NeonAvatar`.
12. **NeonTimeline**: histórico de pedidos e atividades. O `NeonStepper` não serve para isso.
13. **NeonLoadingOverlay**: bloquear a tela com spinner durante um submit. Hoje cada tela improvisa o seu.
14. **NeonFileUpload / dropzone**: só vale se o kit for usado em formulários web ou desktop.

Fora da lista, mas pior do que qualquer item dela: o `NeonTextField` (`lib/src/widgets/neon_text_field.dart:23-44`) não aceita `controller`, `focusNode`, `maxLines`, validator nem `textInputAction`. Ele não serve como textarea, não limpa o campo por código e não entra num `Form`. Eu corrigiria isso antes de criar widget novo, e vale avisar a thread que está refatorando o kit.