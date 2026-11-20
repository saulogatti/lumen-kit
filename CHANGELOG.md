# Changelog

## Unreleased

- Added `showLumenColorPicker`, a dialog with a saturation and brightness area,
  a hue track, the original color next to the new one, a hex field, and
  swatches (palette accents by default). It supports keyboard arrows and
  screen reader adjustments. OK returns the color and Cancel returns null.
- Added `showAlpha` to `showLumenColorPicker`, an opacity track below the hue
  track over a checkerboard, with the same keyboard and screen reader support
  (`alphaLabel`). It is off by default. Translucent colors in the comparison
  and the swatches are drawn over the checkerboard too.
- Added `LumenColorField`, a read-only field that shows a color swatch and its
  hex code and opens `showLumenColorPicker` on tap. Cancel leaves `onChanged`
  uncalled.
- Added `LumenEntrance` and `LumenAnimatedSwitcher` with configurable duration,
  easing, and slide offset, reduced motion support, and gallery examples.

## 1.3.0

- Added optional `success`, `warning`, and `danger` parameters to
  `LumenPalette.fromSeed`, so apps can set their own semantic colors. Omitted
  values keep the `AppColors` defaults.
  ([#27](https://github.com/saulogatti/lumen-kit/issues/27))
- A custom `danger` passed to `LumenPalette.fromSeed` becomes 20% more
  saturated when its hue is within 30 degrees of `primary` and its saturation
  is below 50%, so it stays distinct from the primary color. Other colors are
  kept as given, and the default `danger` is never changed.
  ([#27](https://github.com/saulogatti/lumen-kit/issues/27))
- Added `AppColors.dangerLight`, a darker `danger` with about 5:1 contrast on
  white. `LumenPalette.light()` and light `LumenPalette.fromSeed` palettes use
  it by default, so danger text, outlines and chips meet WCAG AA on light
  surfaces. Dark palettes keep `AppColors.danger`.
  ([#27](https://github.com/saulogatti/lumen-kit/issues/27))
- `AppTheme.fromSeed` accepts `success`, `warning`, and `danger` and passes
  them to `LumenPalette.fromSeed`.
- Raised the minimum Dart SDK to `3.14.0` and Flutter to `3.50.0`.
- Raised the minimum `material_ui` version to `1.11.0`.

## 1.2.0

- Added `LumenButton.tone`, a `LumenStatusTone` that gives any variant a
  semantic palette color. Solid buttons with a tone fill with a gradient
  derived from that color, or the plain color in styles without gradients,
  and pick `backgroundDeep` or `textPrimary` for the text, whichever contrasts
  more. Buttons without a tone look the same as before. ([#25](https://github.com/saulogatti/lumen-kit/issues/25))
- Added `LumenButton.danger`, a solid button with `LumenStatusTone.danger` for
  destructive actions. ([#25](https://github.com/saulogatti/lumen-kit/issues/25))
- Fixed `LumenActionContent` overflowing when its label doesn't fit. The label
  now stays on one line and ends with an ellipsis, which applies to
  `LumenButton`, `LumenCta` and the extended `LumenFab`, busy or not.
  ([#24](https://github.com/saulogatti/lumen-kit/issues/24))

## 1.1.0

- Added standalone foundation demos, control state comparisons, and independent
  horizontal and vertical steppers to the example gallery.

- Standardized documentation, gallery text, and default widget labels in English.

- The example gallery can toggle Lumen colors and styles independently.
- The example includes a **Default Material** gallery that uses native Material
  widgets and theme defaults for comparison.
- Added `LumenListTile.contentPadding` to control padding outside the tile.
- Added scroll configuration to `LumenList`, including `shrinkWrap`,
  `physics`, `scrollDirection`, and `reverse`.
- Kept `LumenDivider` visible when the selected style uses solid fills.
- Raised the minimum `material_ui` version to `1.10.0`.

## [1.0.0]

- Initial release
