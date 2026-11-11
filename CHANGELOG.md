# Changelog

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
