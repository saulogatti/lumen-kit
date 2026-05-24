# Roadmap — neon_ui

Componentes planejados para o kit. Marque conforme forem entregues.

## Já implementado

- [x] **Tema**: `AppColors`, `NeonPalette`, `NeonThemeExt`, `AppTheme`
- [x] **Background**: `AnimatedGridBackground`, `GlowOrbSpec`
- [x] **Estrutura**: `NeonAppBar`, `NeonCard`
- [x] **Ações**: `GradientCta`, `NeonButton` (solid / outline / ghost), `NeonIconButton`, `NeonFab`
- [x] **Input**: `NeonTextField`
- [x] **Feedback**: `StatusChip`, `NeonDialog` (+ `showNeonDialog`)
- [x] **Navegação**: `NavigationCard`

## A fazer

### Inputs / formulários
- [ ] `NeonSwitch`
- [ ] `NeonCheckbox`
- [ ] `NeonRadio`
- [ ] `NeonSlider`
- [ ] `NeonDropdown` / `NeonSelect`
- [ ] `NeonSearchBar`
- [ ] `NeonDatePicker` (wrapper temático)

### Feedback / status
- [ ] `NeonSnackBar` (+ `showNeonSnackBar`)
- [ ] `NeonToast`
- [ ] `NeonProgressIndicator` (linear e circular com glow)
- [ ] `NeonSkeleton` / shimmer loader
- [ ] `NeonTooltip`

### Navegação / layout
- [ ] `NeonTabs` / `NeonSegmentedControl`
- [ ] `NeonBottomNavBar` ou `NeonNavRail`
- [ ] `NeonBottomSheet` (+ `showNeonBottomSheet`)
- [ ] `NeonDrawer`
- [ ] `NeonStepper`

### Display / dados
- [ ] `NeonBadge` / `NeonTag` (variação menor que `StatusChip`)
- [ ] `NeonAvatar`
- [ ] `NeonListTile`
- [ ] `NeonDivider` (com gradiente)
- [ ] `NeonExpansionTile`
- [ ] `NeonDataTable` (ou ao menos `NeonTableRow`)

## Convenções

- Arquivo por widget em `lib/src/widgets/`.
- Paleta sempre acessada via `NeonThemeExt.of(context).palette` — nunca importar `AppColors` diretamente em widgets novos.
- Exportar em `lib/neon_ui.dart`.
- Estados padrão a suportar quando fizer sentido: `onPressed == null` → desabilitado (opacidade 0.55), `busy: true` → spinner inline.
- Documentar uso mínimo no `README.md` quando o componente sair do roadmap.
