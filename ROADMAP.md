# Roadmap — neon_ui

Componentes planejados para o kit. Marque conforme forem entregues.

## Já implementado

- [x] **Tema**: `AppColors`, `NeonPalette`, `NeonThemeExt`, `AppTheme`
- [x] **Background**: `AnimatedGridBackground`, `GlowOrbSpec`
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
- Paleta sempre acessada via `NeonThemeExt.of(context).palette` — nunca importar `AppColors` diretamente em widgets novos.
- Exportar em `lib/neon_ui.dart`.
- Estados padrão a suportar quando fizer sentido: `onPressed == null` → desabilitado (opacidade 0.55), `busy: true` → spinner inline.
- Documentar uso mínimo no `README.md` quando o componente sair do roadmap.
