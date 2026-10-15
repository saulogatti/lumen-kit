# Kit review

Repository review on 12 Oct 2026, when the package was still named `neon_ui`.
It was renamed to `lumen_kit` afterward, and the `Neon` prefix became `Lumen`.
Names below are from that review.

Flutter package 0.1.0, unpublished. 7,482 lines in `lib`, 41 widget files, five
visual styles, and a theme foundation that already separates color from effects.
The kit is well designed; the remaining debt is testing and distribution. The
light theme was the item handled on the `fix/tema-claro-alpha` branch.

| Metric | Value |
| --- | --- |
| Widget files | 41 |
| No tests at all | 13 |
| Files with broken alpha in light mode | 12 in the review; fixed on this branch |
| CI workflows | 0 |

Line counts: `lib` 7,482, `test` 1,399, gallery 1,014.

## The public example teaches the wrong import

The README imports `package:flutter/material.dart` alongside `neon_ui`. The kit
uses `material_ui`, and the two `ThemeData` types are not the same. `AGENTS.md`
already warns that this mix sometimes compiles and fails at runtime. Anyone
copying the minimal usage example hits this trap.

## What holds the kit together

**Orthogonal theme.** `NeonPalette` and `NeonStyle` are independent. Presets,
`fromSeed`, `NeonScope`, and the fallback when nothing is registered in
`ThemeData` cover the three ways to use the kit. New widgets already work in
`bareApp`.

**Reusable foundation.** `NeonPressable`, `NeonDecorations`,
`NeonActionContent`, `NeonLabeled`, and `NeonMotion` centralize touch behavior,
semantics, panels, and reduce-motion behavior. The catalog does not reimplement
`InkWell` in every file.

**Stable API contract.** Two public imports, `components.dart` without
`AppTheme` and `AppColors`, const constructors, null `onChanged` disables, and
`busy` shows a spinner. The skill and `AGENTS.md` repeat the same rules the code
follows.

**Real accessibility.** There are tests for semantics, keyboard use on the
switch, `Form` support in the text field, and animations that stop with
`disableAnimations`. That is rare in a visual kit and worth preserving.

## Coverage of the 41 widget files

Cross-reference of `lib/src/widgets` with `test/` on 12 Oct 2026.

| Type | Files | What counts |
| --- | ---: | --- |
| With assertions | 22 | Interaction or semantics |
| Render only | 6 | Only included in a pump that must not throw |
| Missing from tests | 13 | The file is not referenced |

## Pain points

**The test suite covers the new batch, not the catalog.** 1,399 lines of tests
against 7,482 in `lib`. Widgets from the menu, chips, rating, carousel, and
loading PRs have their own files. Dialog, dropdown, drawer, sheet, stepper,
table, and search do not appear in any test. There are no goldens: a regression
in flat, glass, or brutal passes `flutter test`.

**The light theme replaced alpha instead of multiplying it.** `surfaceOutline`
is already translucent in light mode. `withValues(alpha: 0.9)` replaces that
alpha and turns it nearly black. In the review, checkbox, radio, switch,
slider, progress, tabs, stepper, data table, list tile, expansion, bottom nav,
and the disabled border in `LumenDecorations` still took this path. This has
been fixed: outlines use `outlineAlpha`, and tokens that are already
translucent use `scaleAlpha`. Details in the next section.

**Distribution is git on `main`, version 0.1.0.** `publish_to: none`, no
CHANGELOG, no tag, and no CI. The README asks for `ref: main`. Consumers of the
kit cannot pin a revision or know what changed between one `pub get` and the
next.

## Files tests never open

| Widget | Area | What needs to be proven |
| --- | --- | --- |
| NeonDialog | overlay | Opens a route; the Future only completes when closed |
| NeonDropdown | form | Selection, disabled item, null value |
| NeonDrawer | navigation | Selected item and closing |
| NeonBottomSheet | overlay | `showNeonBottomSheet` and dismiss gesture |
| NeonStepper | navigation | Current step, error, and direction |
| NeonDataTable | data | Header, row, and scrolling |
| NeonSearchBar | form | Controller, clearing, `onChanged` |
| NeonTooltip | feedback | Hover, focus, and reduce motion |
| NeonFab | action | Null `onPressed` and `busy` |
| GradientCta | action | Disabled state and semantics |
| NeonAppBar | structure | Title, subtitle, and actions |
| NavigationCard | navigation | Hover and `onTap` |
| NeonDivider | display | Gradient disappears in flat style |
| NeonBottomNavBar | navigation | The rail is tested; the bar is not |
| NeonSegmentedControl | navigation | Only `NeonTabs` is exercised |
| NeonTag | display | The badge only appears incidentally in the rail |

## Improvements, in order of effort vs. value

1. **CI with `flutter analyze` and `flutter test`.** The analyzer is strict and
   currently only runs on the machine of whoever remembers.
2. **Fix the README import to `material_ui`.** It is the first code a new app
   copies.
3. **Tests for the 13 missing files, overlays first.** Dialog, sheet, and menu
   are the ones that hang a test if the Future is awaited.
4. **Alpha helper (`c.a * x`) and fix the light theme.** Done. See below.
5. **Replace `ref: main` with a tag and add a CHANGELOG.** A stalled 0.1.0 does
   not communicate what the nine new widgets have delivered.
6. **Align public names with the `Lumen` prefix.** `LumenCta`,
   `LumenNavigationCard`, and `LumenStatusChip` were already correct. In this
   branch, the background and menu positioning were missing. Done, with
   deprecated aliases.
7. **Split `example/lib/main.dart` (1,014 lines) and remove `Colors.white` /
   `Colors.black`.** The gallery is the only place showing all five styles.
   Badge, slider thumb, menu shadow, and sheet barrier ignore the palette.

## Completed on `fix/tema-claro-alpha`

**`Color.scaleAlpha`.** Multiplies the alpha the color already has (`a * factor`),
capped at `1`. `outlineAlpha` remains the path for outlines: in dark mode the
requested value is used directly; in light mode the faint black is only scaled
and does not exceed `0.28`. Opaque accents continue to use `withValues`, since
the requested alpha there is absolute.

The helper was added where the token was already translucent or the code was
already multiplying:

- `textMuted` in rating, the disabled switch thumb, the bottom sheet handle, and
  the inactive page indicator dot
- `LumenStyle.borderAll` border and the adapted shadow glow
- Background dots, which compensate for grid opacity with `scaleAlpha(3)`

**`LumenPalette.fromSeed` in light mode.** `surfaceOutline` and
`surfaceHighlight` now use the faint black from `LumenPalette.light`
(`0x15000000` and `0x08000000`). Previously, the outline was the accent at 25%,
and `outlineAlpha` raised it to `0.6`–`0.9`.

**Names.** `animated_grid_background.dart` became
`lumen_animated_grid_background.dart`. `AnimatedGridBackground` and
`GlowOrbSpec` became `LumenAnimatedGridBackground` and `LumenGlowOrbSpec`.
`neonMenuPositionAt` became `lumenMenuPositionAt`. All three old names remain,
marked deprecated.

## Roadmap

Still open in that review: banner, empty state, pin field, timeline, and file
upload. The "To do" section is almost entirely checked off and no longer serves
as a plan.
