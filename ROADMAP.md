# Roadmap — lumen_kit

Components planned for the kit. Check them off as they are delivered.

## Already implemented

- [x] **Theme**: `AppColors`, `LumenPalette` (+ `fromSeed`), `LumenPreset`, `LumenStyle` (neon / flat / glass / soft / brutal), `LumenThemeExt`, `AppTheme`
- [x] **Background**: `LumenAnimatedGridBackground`, `LumenGlowOrbSpec`
- [x] **Reusable foundation**: `LumenPressable`, `LumenDecorations`, `LumenActionContent`, `LumenLabeled`, `LumenMotion`
- [x] **Structure**: `LumenAppBar`, `LumenCard`
- [x] **Actions**: `LumenCta`, `LumenButton` (solid / outline / ghost), `LumenIconButton`, `LumenFab`, `LumenMenuButton` / `LumenContextMenu` (+ `showLumenMenu`)
- [x] **Inputs**: `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenDropdown`, `LumenRangeSlider`, `LumenSearchBar`, `LumenDatePicker` (+ `showLumenDatePicker`), `LumenTimePicker` (+ `showLumenTimePicker`), `LumenChip` / `LumenChoiceChips` / `LumenFilterChips`, `LumenQuantityStepper`, `LumenRating`
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

### Feedback / status

- [x] `LumenSnackBar` (+ `showLumenSnackBar`)
- [x] `LumenToast`
- [x] `LumenProgressIndicator` (linear and circular with glow)
- [x] `LumenSkeleton` / shimmer loader
- [x] `LumenTooltip`

### Navigation / layout

- [x] `LumenTabs` / `LumenSegmentedControl`
- [x] `LumenBottomNavBar` or `LumenNavRail`
- [x] `LumenBottomSheet` (+ `showLumenBottomSheet`)
- [x] `LumenDrawer`
- [x] `LumenStepper`

### Display / data

- [x] `LumenBadge` / `LumenTag` (smaller variant of `LumenStatusChip`)
- [x] `LumenAvatar`
- [x] `LumenListTile`
- [x] `LumenDivider` (with gradient)
- [x] `LumenExpansionTile`
- [x] `LumenDataTable` (or at least `LumenTableRow`)

## Conventions

- One file per widget in `lib/src/widgets/`.
- Always access the palette via `LumenThemeExt.of(context).palette` — never
  import `AppColors` directly in widgets (otherwise the color ignores
  `AppTheme.fromSeed` and presets).
- Always use `LumenStyle.of(context)` for shadows, gradients, radius, and
  borders (`shadows`, `fill`, `radius`, `borderAll`, `surfaceAlpha`) — never raw
  `BoxShadow`/`BorderRadius.circular`, or the widget will ignore the style.
- Export widgets in `lib/components.dart` (`lib/lumen_kit.dart` re-exports it).
  No global theme (`AppTheme`/`AppColors`) inside widgets.
- Default states to support when relevant: `onPressed == null` → disabled
  (`kLumenDisabledOpacity`), `busy: true` → inline spinner.
- Before writing `Opacity` + `InkWell`, diagonal gradients, a bordered/glowing
  panel, or `InputDecoration` by hand, use the pieces in `lib/src/foundation/`
  (`LumenPressable`, `LumenDecorations`, `LumenActionContent`, `LumenLabeled`).
- No `GestureDetector` for actions: it has no keyboard focus or semantics. Use
  `LumenPressable`.
- Animations: create controllers and `CurvedAnimation` once in `State` (never
  in `build`); use `LumenMotion.duration` for durations and
  `LumenMotion.syncRepeat` for loops.
- Use `spacing:` between `Row`/`Column` children instead of interleaved
  `SizedBox` widgets.
- Document minimal usage in `README.md` when a component leaves the roadmap.

## Next

- [x] Selectable `LumenChip` (`LumenChoiceChips` / `LumenFilterChips`)
- [x] `LumenTimePicker`
- [x] `LumenRangeSlider`
- [x] `LumenMenuButton` / `LumenContextMenu`
- [x] `LumenBanner` / inline alert that stays until dismissed
- [x] `LumenEmptyState` (icon, text, and CTA)
- [x] `LumenPinField` (OTP)
- [x] `LumenList` (`ListView.builder` for large lists)
- [x] `LumenPageIndicator` / `LumenCarousel`
- [x] `LumenQuantityStepper`
- [x] `LumenRating`
- [x] `LumenAvatarGroup`
- [ ] `LumenTimeline` (order and activity history)
- [x] `LumenLoadingOverlay` (+ `showLumenLoading`)
- [ ] `LumenFileUpload` / drop zone (only if the kit is used on web/desktop)
