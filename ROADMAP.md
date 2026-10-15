# Roadmap — lumen_kit

Components planned for the kit. Mark as they are delivered.

## Already implemented

- [x] **Theme**: `AppColors`, `LumenPalette` (+ `fromSeed`), `LumenPreset`, `LumenStyle` (neon / flat / glass / soft / brutal), `LumenThemeExt`, `AppTheme`
- [x] **Background**: `LumenAnimatedGridBackground`, `LumenGlowOrbSpec`
- [x] **Reusable base**: `LumenPressable`, `LumenDecorations`, `LumenActionContent`, `LumenLabeled`, `LumenMotion`
- [x] **Structure**: `LumenAppBar`, `LumenCard`
- [x] **Actions**: `LumenCta`, `LumenButton` (solid / outline / ghost), `LumenIconButton`, `LumenFab`, `LumenMenuButton` / `LumenContextMenu` (+ `showLumenMenu`)
- [x] **Input**: `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenDropdown`, `LumenRangeSlider`, `LumenSearchBar`, `LumenDatePicker` (+ `showLumenDatePicker`), `LumenTimePicker` (+ `showLumenTimePicker`), `LumenChip` / `LumenChoiceChips` / `LumenFilterChips`, `LumenQuantityStepper`, `LumenRating`
- [x] **Feedback**: `LumenStatusChip`, `LumenDialog` (+ `showLumenDialog`), `LumenSnackBar` (+ `showLumenSnackBar`), `LumenToast`, `LumenProgressIndicator`, `LumenSkeleton`, `LumenTooltip`, `LumenLoadingOverlay` (+ `showLumenLoading`)
- [x] **Navigation**: `LumenNavigationCard`, `LumenTabs`, `LumenSegmentedControl`, `LumenBottomNavBar`, `LumenNavRail`, `LumenBottomSheet` (+ `showLumenBottomSheet`), `LumenDrawer` (+ `LumenDrawerItem`), `LumenStepper`, `LumenPageIndicator`, `LumenCarousel`
- [x] **Display**: `LumenBadge`, `LumenTag`, `LumenAvatar`, `LumenAvatarGroup`, `LumenListTile`, `LumenDivider`, `LumenExpansionTile`, `LumenDataTable` (+ `LumenTableRow`)

## To do

### Inputs / forms

- [x] `LumenSwitch`
- [x] `LumenCheckbox`
- [x] `LumenRadio`
- [x] `LumenSlider`
- [x] `LumenDropdown` / `LumenSelect`
- [x] `LumenSearchBar`
- [x] `LumenDatePicker` (themed wrapper)

### Feedback/status

- [x] `LumenSnackBar` (+ `showLumenSnackBar`)
- [x] `LumenToast`
- [x] `LumenProgressIndicator` (linear and circular with glow)
- [x] `LumenSkeleton` / shimmer loader
- [x] `LumenTooltip`

### Navigation/layout

- [x] `LumenTabs` / `LumenSegmentedControl`
- [x] `LumenBottomNavBar` or `LumenNavRail`
- [x] `LumenBottomSheet` (+ `showLumenBottomSheet`)
- [x] `LumenDrawer`
- [x] `LumenStepper`

### Display/data

- [x] `LumenBadge` / `LumenTag` (smaller variation than `LumenStatusChip`)
- [x] `LumenAvatar`
- [x] `LumenListTile`
- [x] `LumenDivider` (with gradient)
- [x] `LumenExpansionTile`
- [x] `LumenDataTable` (or at least `LumenTableRow`)

## Conventions

- File per widget in `lib/src/widgets/`.
- Palette always accessed via `LumenThemeExt.of(context).palette` — never import `AppColors` directly in widgets (otherwise the color ignores `AppTheme.fromSeed` and the presets).
- Shadow, gradient, radius and border always via `LumenStyle.of(context)` (`shadows`, `fill`, `radius`, `borderAll`, `surfaceAlpha`) — never raw `BoxShadow`/`BorderRadius.circular`, otherwise the widget ignores the style.
- Export widgets in `lib/components.dart` (`lib/lumen_kit.dart` re-exports). No global theme (`AppTheme`/`AppColors`) within widgets.
- Default states to support when it makes sense: `onPressed == null` → disabled (`kLumenDisabledOpacity`), `busy: true` → inline spinner.
- Before writing `Opacity` + `InkWell`, diagonal gradient, border/glow panel or `InputDecoration` on your hand, use the `lib/src/foundation/` pieces (`LumenPressable`, `LumenDecorations`, `LumenActionContent`, `LumenLabeled`).
- No `GestureDetector` for actions: no keyboard focus or semantics. Use `LumenPressable`.
- Animations: controllers and `CurvedAnimation` created once in `State` (never in `build`), durations via `LumenMotion.duration` and loops via `LumenMotion.syncRepeat`.
- Space between children of `Row`/`Column` with `spacing:` instead of `SizedBox` interspersed.
- Document minimal usage in `README.md` when the component leaves the roadmap.

## Upcoming

- [x] `LumenChip` selectable (`LumenChoiceChips` / `LumenFilterChips`)
- [x] `LumenTimePicker`
- [x] `LumenRangeSlider`
- [x] `LumenMenuButton` / `LumenContextMenu`
- [x] `LumenBanner` / inline alert that stays until someone closes
- [x] `LumenEmptyState` (icon, text and CTA)
- [x] `LumenPinField` (OTP)
- [x] `LumenList` (`ListView.builder` for large lists)
- [x] `LumenPageIndicator` / `LumenCarousel`
- [x] `LumenQuantityStepper`
- [x] `LumenRating`
- [x] `LumenAvatarGroup`
- [ ] `LumenTimeline` (order and activity history)
- [x] `LumenLoadingOverlay` (+ `showLumenLoading`)
- [ ] `LumenFileUpload` / dropzone (only if the kit is used on web/desktop)
