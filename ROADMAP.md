# Roadmap — lumen_kit

Componentes planejados para o kit. Marque conforme forem entregues.

## Já implementado

- [x] **Tema**: `AppColors`, `LumenPalette` (+ `fromSeed`), `LumenPreset`, `LumenStyle` (neon / flat / glass / soft / brutal), `LumenThemeExt`, `AppTheme`
- [x] **Background**: `LumenAnimatedGridBackground`, `LumenGlowOrbSpec`
- [x] **Base reaproveitável**: `LumenPressable`, `LumenDecorations`, `LumenActionContent`, `LumenLabeled`, `LumenMotion`
- [x] **Estrutura**: `LumenAppBar`, `LumenCard`
- [x] **Ações**: `LumenCta`, `LumenButton` (solid / outline / ghost), `LumenIconButton`, `LumenFab`, `LumenMenuButton` / `LumenContextMenu` (+ `showLumenMenu`)
- [x] **Input**: `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenDropdown`, `LumenRangeSlider`, `LumenSearchBar`, `LumenDatePicker` (+ `showLumenDatePicker`), `LumenTimePicker` (+ `showLumenTimePicker`), `LumenChip` / `LumenChoiceChips` / `LumenFilterChips`, `LumenQuantityStepper`, `LumenRating`
- [x] **Feedback**: `LumenStatusChip`, `LumenDialog` (+ `showLumenDialog`), `LumenSnackBar` (+ `showLumenSnackBar`), `LumenToast`, `LumenProgressIndicator`, `LumenSkeleton`, `LumenTooltip`, `LumenLoadingOverlay` (+ `showLumenLoading`)
- [x] **Navegação**: `LumenNavigationCard`, `LumenTabs`, `LumenSegmentedControl`, `LumenBottomNavBar`, `LumenNavRail`, `LumenBottomSheet` (+ `showLumenBottomSheet`), `LumenDrawer` (+ `LumenDrawerItem`), `LumenStepper`, `LumenPageIndicator`, `LumenCarousel`
- [x] **Display**: `LumenBadge`, `LumenTag`, `LumenAvatar`, `LumenAvatarGroup`, `LumenListTile`, `LumenDivider`, `LumenExpansionTile`, `LumenDataTable` (+ `LumenTableRow`)

## A fazer

### Inputs / formulários

- [x] `LumenSwitch`
- [x] `LumenCheckbox`
- [x] `LumenRadio`
- [x] `LumenSlider`
- [x] `LumenDropdown` / `LumenSelect`
- [x] `LumenSearchBar`
- [x] `LumenDatePicker` (wrapper temático)

### Feedback / status

- [x] `LumenSnackBar` (+ `showLumenSnackBar`)
- [x] `LumenToast`
- [x] `LumenProgressIndicator` (linear e circular com glow)
- [x] `LumenSkeleton` / shimmer loader
- [x] `LumenTooltip`

### Navegação / layout

- [x] `LumenTabs` / `LumenSegmentedControl`
- [x] `LumenBottomNavBar` ou `LumenNavRail`
- [x] `LumenBottomSheet` (+ `showLumenBottomSheet`)
- [x] `LumenDrawer`
- [x] `LumenStepper`

### Display / dados

- [x] `LumenBadge` / `LumenTag` (variação menor que `LumenStatusChip`)
- [x] `LumenAvatar`
- [x] `LumenListTile`
- [x] `LumenDivider` (com gradiente)
- [x] `LumenExpansionTile`
- [x] `LumenDataTable` (ou ao menos `LumenTableRow`)

## Convenções

- Arquivo por widget em `lib/src/widgets/`.
- Paleta sempre acessada via `LumenThemeExt.of(context).palette` — nunca importar `AppColors` diretamente em widgets (senão a cor ignora `AppTheme.fromSeed` e os presets).
- Sombra, gradiente, raio e borda sempre via `LumenStyle.of(context)` (`shadows`, `fill`, `radius`, `borderAll`, `surfaceAlpha`) — nunca `BoxShadow`/`BorderRadius.circular` crus, senão o widget ignora o estilo.
- Exportar widgets em `lib/components.dart` (o `lib/lumen_kit.dart` reexporta). Nada de tema global (`AppTheme`/`AppColors`) dentro de widgets.
- Estados padrão a suportar quando fizer sentido: `onPressed == null` → desabilitado (`kLumenDisabledOpacity`), `busy: true` → spinner inline.
- Antes de escrever `Opacity` + `InkWell`, gradiente diagonal, painel com borda/glow ou `InputDecoration` na mão, use as peças de `lib/src/foundation/` (`LumenPressable`, `LumenDecorations`, `LumenActionContent`, `LumenLabeled`).
- Nada de `GestureDetector` para ações: sem foco de teclado nem semântica. Use `LumenPressable`.
- Animações: controllers e `CurvedAnimation` criados uma vez no `State` (nunca no `build`), durações via `LumenMotion.duration` e loops via `LumenMotion.syncRepeat`.
- Espaço entre filhos de `Row`/`Column` com `spacing:` em vez de `SizedBox` intercalado.
- Documentar uso mínimo no `README.md` quando o componente sair do roadmap.

## Próximos

- [x] `LumenChip` selecionável (`LumenChoiceChips` / `LumenFilterChips`)
- [x] `LumenTimePicker`
- [x] `LumenRangeSlider`
- [x] `LumenMenuButton` / `LumenContextMenu`
- [x] `LumenBanner` / alerta inline que fica até alguém fechar
- [x] `LumenEmptyState` (ícone, texto e CTA)
- [x] `LumenPinField` (OTP)
- [x] `LumenList` (`ListView.builder` para listas grandes)
- [x] `LumenPageIndicator` / `LumenCarousel`
- [x] `LumenQuantityStepper`
- [x] `LumenRating`
- [x] `LumenAvatarGroup`
- [ ] `LumenTimeline` (histórico de pedidos e atividades)
- [x] `LumenLoadingOverlay` (+ `showLumenLoading`)
- [ ] `LumenFileUpload` / dropzone (só se o kit for usado em web/desktop)
