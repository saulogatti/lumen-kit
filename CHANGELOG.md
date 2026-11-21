# Changelog

## Unreleased

- `showLumenDatePicker` and `LumenDatePicker` now open a dialog drawn by the
  kit instead of Material's date picker: the selected date, a month grid with
  previous and next month buttons, a year list opened from the month title,
  and a text field for typing the date. The parameters are unchanged. The
  grid follows the palette and style in the five styles, light and dark, and
  works without a registered theme. Arrow keys move the day, Page Up and Page
  Down the month (Shift for a year), Enter confirms and Escape cancels.
  Screen readers read each day as a full date. Labels and date formats come
  from `MaterialLocalizations`, as before. `initialDate` outside the range is
  now moved to the nearest end by the helper too, not only by the field.
  Tests that looked for `DatePickerDialog` or `CalendarDatePicker` need to
  look for the text or semantics instead.
  ([#40](https://github.com/saulogatti/lumen-kit/issues/40))
- Added `LumenFileUpload`, a list of files with name, percentage, progress
  bar, and a status label colored by `LumenUploadStatus` (pending, uploading,
  completed, failed). Each file is an immutable `LumenUploadItem`; the app
  picks and uploads the files and rebuilds the list with `copyWith` as
  progress changes. Screen readers announce each file name with its
  percentage. Picking and dropping files stay with the app, so the kit adds no
  plugin dependency.
  ([#41](https://github.com/saulogatti/lumen-kit/issues/41))
- `LumenCircularProgress.glowColor` now colors the blurred glow behind the
  arc. It used to be ignored. Without it the glow still follows the arc
  gradient, so the default look is unchanged; apps that already pass
  `glowColor` will see that color in the glow.
  ([#42](https://github.com/saulogatti/lumen-kit/issues/42))

## 1.4.0

- Added `LumenTimeline`, a vertical list of events with markers joined by a
  line, for order and activity history. Each `LumenTimelineEntry` takes a
  title, optional subtitle, description, preformatted timestamp, icon, tone or
  accent color, extra child and `onTap`. `highlightedIndex` marks the current
  event. The default constructor doesn't scroll, so it fits inside cards and
  dialogs; `LumenTimeline.builder` builds long histories on demand. Screen
  readers announce a list whose items read the title, timestamp, subtitle and
  description.
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
- Added `LumenNumberField`, a numeric text field controlled by `double?` with
  configurable decimals, decimal and group separators, prefix and suffix text,
  and `min`/`max` applied when focus leaves or the field is submitted.
- Added `LumenEntrance` and `LumenAnimatedSwitcher` with configurable duration,
  easing, and slide offset, reduced motion support, and gallery examples.
- `LumenDialog` content now scrolls when it does not fit (keyboard open,
  short or landscape windows), while the title and actions stay in view.
  Content is still laid out with unbounded height, so lists inside it need
  `shrinkWrap: true` or a bounded height, as before.
- Minimum `material_ui` is now `1.11.1`.
- Fixed `LumenAnimatedGridBackground` throwing an infinite size error inside a
  `Column`, `Row`, `ListView` or `SingleChildScrollView`. In an axis without a
  bound, the child now sets the size and the background covers it; with
  bounds it still fills the space. It also reports its intrinsic size from the
  child. `gridSpacing` must be greater than zero (it used to hang the painter),
  and `gridOpacity`, `LumenGlowOrbSpec.size` and `LumenGlowOrbSpec.opacity`
  are checked in debug.
- Fixed `LumenLinearProgress` with a `value`: the filled part was laid out
  with zero height, so the bar looked empty and did not follow the value. It
  now fills the bar's height and grows from the start side, right to left in
  RTL.

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
