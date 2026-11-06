# Lumen Kit gallery

Run the following command from the `example` directory to open the gallery.

```powershell
flutter run -d windows
```

## Comparing themes

Use the **Colors and style** section to toggle the palette and component style
independently. Both controls are enabled when the gallery opens.

| Lumen colors | Component style | Result in the Lumen gallery |
| --- | --- | --- |
| On | On | Selected palette and style. |
| Off | On | Material colors with the selected style. |
| On | Off | Selected palette with the kit's base corners and borders. |
| Off | Off | Material colors with the kit's base corners and borders. |

With component styling disabled, the gallery uses solid fills without shadows
or background decorations. Light or dark mode and Material typography apply
to every combination.

**Default Material** opens a separate screen with native Material colors and
shapes. It includes equivalents for cards, buttons, fields, selection,
navigation, feedback, and tables. The back arrow restores the previous Lumen
gallery configuration.

## How the example applies the theme

The [Lumen gallery](lib/main.dart) combines the selected palette and style
through `LumenThemeExt`. When Lumen colors are disabled, it maps the Material
`ColorScheme` to a `LumenPalette` and uses green and amber for success and
warning. The [comparison screen](lib/material_gallery.dart) uses the default
`ThemeData` and widgets from `material_ui`.

## Exploring component states

The **Foundation** section demonstrates `LumenPressable`, `LumenActionContent`,
and `LumenLabeled` directly. Try the interactive and selected states, use Tab
and Enter to explore keyboard focus, and compare disabled controls. A custom
action combines the foundation widgets with `LumenDecorations`.

The **Control states** section compares enabled, disabled, loading, and
indeterminate controls. Text fields demonstrate help text, read-only values,
and form validation. Dropdowns show selection and errors; PIN fields and
sliders demonstrate disabled input. Use the form controls to compare invalid
and valid submissions.

The **Stepper** section presents horizontal and vertical layouts with separate
selection and reset controls. Only the active vertical step expands its content.

All demonstrations follow the selected palette, style, and brightness. The new
sections live in [`lib/sections/`](lib/sections/) and own their demonstration
state; the main gallery composes them and supplies the theme.

## Running checks

From the repository root, run `flutter analyze` and `flutter test`. Run
`flutter test` from `example/` for gallery interaction and smoke tests. The
section layout tests cover all five styles in light and dark modes at a narrow
viewport with enlarged text and reduced motion.
