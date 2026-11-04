# Kit review

Reading from the repository on Oct 12, 2026, when the package was still called `neon_ui`.
After that it was renamed to `lumen_kit` and the prefix `Neon` became `Lumen`.
The names below are those from that reading.

Flutter package 0.1.0, unpublished. 7,482 lines in `lib`, 41 files
widget, five visual styles and a theme base that already separates color from effect.
The kit is well designed; the remaining debt is testing and distribution. The theme
Of course it was the item addressed in the `fix/tema-claro-alpha` branch.

| Measure | Value |
| --- | --- |
| Widget Files | 41 |
| Sem nenhum teste | 13 |
| Files with broken alpha in clear | 12 na leitura; the path was closed on this branch |
| CI Workflows | 0 |

Row counts: `lib` 7,482, `test` 1,399, gallery 1,014.

## The public example teaches the wrong import

The README imports `package:flutter/material.dart` along with `neon_ui`. The kit
uses `material_ui`, and the two `ThemeData` are not the same type. THE `AGENTS.md`
Warning that this mixture sometimes compiles and breaks at runtime. Quem copia o
Minimal usage falls into this trap.

## O que segura o kit

**Orthogonal theme.** `NeonPalette` and `NeonStyle` are independent. Preset,
`fromSeed`, `NeonScope` and the fallback with nothing registered in `ThemeData` cover
the three ways to use the kit. New widgets are already created in `bareApp`.

**Reusable base.** `NeonPressable`, `NeonDecorations`,
`NeonActionContent`, `NeonLabeled` and `NeonMotion` focus touch, semantics,
panel and reduce animations. The catalog does not redeploy `InkWell` on each
file.

**Stable API Agreement.** Two public imports, `components.dart` without
`AppTheme` and `AppColors`, const constructor, `onChanged` null disables,
`busy` shows spinner. The skill and `AGENTS.md` repeat the same rules as the
code follows.

**Real accessibility.** There are semantic tests, keyboard on the switch,
`Form` in the text field and animations that stop with `disableAnimations`. That's it
Rare in a visual kit and worth preserving.

## Coverage of 41 widget files

Crossing of `lib/src/widgets` with `test/` on October 12, 2026.

| Type | Files | What counts |
| --- | ---: | --- |
| With assertion | 22 | Interaction or semantics |
| Just render | 6 | It only enters a pump that cannot explode |
| Absent from the test | 13 | File is not referenced |

## Where does it hurt

**Testnet covers the new wave, not the catalog.** 1,399 test lines
against 7,482 from `lib`. PR widgets for menu, chips, rating, carousel and
loading have their own file. Dialog, dropdown, drawer, sheet, stepper, table
and search do not appear in any test. There is no golden: a regression of flat,
glass or brutal passes `flutter test`.

**Clear theme replaced alpha instead of multiply.** `surfaceOutline` no
clear is already translucent. `withValues(alpha: 0.9)` changes this alpha and becomes
almost black. In reading, checkbox, radio, switch, slider, progress, tabs,
stepper, data table, list tile, expansion, bottom nav and border disabled
from `LumenDecorations` still passed this way. This has been closed:
contour uses `outlineAlpha`, and token that is born translucent uses
`scaleAlpha`. Details in the following section.

**Distribution is git on `main`, version 0.1.0.** `publish_to: none`, without
CHANGELOG, sem tag e sem CI. O README pede `ref: main`. Quem consome o kit
there is no way to fix a revision or know what broke between a `pub get` and
the following.

## Files that the test never opens

| Widget | Area | What remains to be proven |
| --- | --- | --- |
| NeonDialog | overlay | Open route; Future only completes when closing |
| NeonDropdown | form | Selection, disabled item, null value |
| NeonDrawer | navigation | Selected item and closing |
| NeonBottomSheet | overlay | `showNeonBottomSheet` and close gesture |
| NeonStepper | navigation | Current step, error and direction |
| NeonDataTable | data | Header, line and scroll |
| NeonSearchBar | form | Controller, clean, `onChanged` |
| NeonTooltip | feedback | Hover, focus and reduce motion |
| NeonFab | action | null `onPressed` and `busy` |
| GradientCta | action | Disabled and semantics |
| NeonAppBar | structure | Title, subtitle and actions |
| NavigationCard | navigation | Hover and `onTap` |
| NeonDivider | display | Gradient disappears in flat style |
| NeonBottomNavBar | navigation | The rail has a test; the bar does not |
| NeonSegmentedControl | navigation | Only `NeonTabs` is exercised |
| NeonTag | display | The badge only appears when riding on the rail |

## Improvements, in the order they are worth the effort

1. **CI with `flutter analyze` and `flutter test`.** The analyzer is strict and today
It only runs on the machine of those who remember it.
2. **Correct the README import for `material_ui`.** It is the first code
that a new app copies.
3. **Tests the 13 missing files, overlays first.** Dialog, sheet and
menu are the ones that crash the test if the Future is awaited.
4. **Alpha helper (`c.a * x`) and fix light theme.** Done. See below.
5. **Exchange `ref: main` for tag and open a CHANGELOG.** 0.1.0 not stopped
communicates what the nine new widgets have already delivered.
6. **Align public names to the prefix `Lumen`.** `LumenCta`,
`LumenNavigationCard` and `LumenStatusChip` were already right. In this branch
the background and menu positioning were missing. Done, alias deprecated.
7. **Slice `example/lib/main.dart` (1,014 lines) and take `Colors.white` /
`Colors.black`.** The gallery is the only place that showcases all five styles.
Badge, slider thumb, menu shadow and sheet barrier ignore the
palette.

## Made at `fix/tema-claro-alpha`

**`Color.scaleAlpha`.** Multiplies the alpha that the color already has (`a * factor`),
with roof in `1`. `outlineAlpha` continues the contour path: in the dark the
order goes straight in, in light the weak black is just scaled and is nothing more than
`0.28`. Opaque accent follows in `withValues`, because there the requested alpha is
absolute.

The helper came in where the token was already translucent or the code already multiplied:

- `textMuted` in the rating, in the thumb off the switch, in the bottom handle
sheet and in the inactive point of the page indicator
- `LumenStyle.borderAll` edge and adapted shadow glow
- background dots, which compensate the opacity of the grid with `scaleAlpha(3)`

**`LumenPalette.fromSeed` in the clear.** `surfaceOutline` and `surfaceHighlight`
become the faint black of `LumenPalette.light` (`0x15000000` and
`0x08000000`). Before the contour was the accent at 25%, and `outlineAlpha` went up
this for `0.6`–`0.9`.

**Names.** `animated_grid_background.dart` turned
`lumen_animated_grid_background.dart`. `AnimatedGridBackground` and
`GlowOrbSpec` became `LumenAnimatedGridBackground` and `LumenGlowOrbSpec`.
`neonMenuPositionAt` became `lumenMenuPositionAt`. The three ancient names
continue, marked as deprecated.

##Roadmap

Still open in that reading: banner, empty state, pin field, timeline and
file upload. The “To do” section is almost completely marked and no longer serves as a
flat.
