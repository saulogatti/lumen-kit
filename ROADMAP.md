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
