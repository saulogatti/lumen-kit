---
name: neon-ui
description: Apply the neon_ui kit (saulogatti/flutter-neon-ui) to an existing Flutter app — install it from git, pick the import, set up theme/preset/NeonScope, and swap Material widgets for their Neon equivalents.
---

# Applying neon_ui to a Flutter app

Use this when the user asks to use `neon_ui`, "the neon components" or
"this kit" in a Flutter app that is not the kit's own repository. To change
the kit itself, read the repository's `AGENTS.md`. Talk to the user in
their language; the kit's own docs and comments are in Portuguese.

The full widget map (Material → Neon, with signatures) is in
[`references/widgets.md`](references/widgets.md). Read it before swapping
any widget: the APIs are **not** copies of Material's.

## 1. Inspect the app first

Find out, from `pubspec.yaml` and the code:

- Versions: the kit needs Dart `^3.13.0` and Flutter `>=3.47.0`. If the app
  is pinned below that, stop and tell the user; there is no workaround.
- **Which Material library the app imports.** `grep -rn
  "package:flutter/material.dart\|package:material_ui/material_ui.dart" lib`.
  This decides step 3 and is the most expensive thing to skip.
- Whether it already has its own `ThemeData`, `ThemeExtension`s, or
  classes named `AppTheme` or `AppColors` (name clash with the kit).
- Whether it has light and dark modes (`theme` + `darkTheme`/`themeMode`).

## 2. Install

```yaml
dependencies:
  material_ui: ^1.6.0
  neon_ui:
    git:
      url: https://github.com/saulogatti/flutter-neon-ui.git
      ref: main   # pin a commit SHA for reproducible builds
```

Run `flutter pub get`. The package is not on pub.dev.

## 3. Material: the app must use `material_ui`

The kit is built on the `material_ui` package, not on
`package:flutter/material.dart`. They are separate libraries with distinct
types. In an app that uses `flutter/material.dart` (verified on Flutter
3.47):

- `MaterialApp(theme: AppTheme.dark)` **does not compile** (one
  `ThemeData` is not the other).
- Neon widgets can't see the app's `Theme`: they fall back to the default
  **light** palette even when the app uses `ThemeData.dark()`.
- `NeonTextField` (and anything using material_ui's `TextField`/`InkWell`
  without a material_ui `Material` above it) throws "No Material widget
  found".

So the default path is to migrate the app:

```bash
grep -rl "package:flutter/material.dart" lib test \
  | xargs sed -i "s#package:flutter/material.dart#package:material_ui/material_ui.dart#"
flutter analyze
```

`material_ui` re-exports `package:flutter/widgets.dart`, so existing
`widgets.dart` imports may become unnecessary-import warnings; remove them.
Third-party packages that ship `flutter/material` widgets (e.g. another
package's date picker) keep working but won't inherit the theme; tell the
user.

If the user **refuses** the migration, stop and explain: there is no
supported way to mix them. Wrapping neon widgets in a material_ui
`Material` only turns the error into "No MaterialLocalizations found", and
the app's theme stays invisible to them.

## 4. Pick the import

| Situation | Import |
|---|---|
| New app, or the user wants the kit's look across the whole app | `package:neon_ui/neon_ui.dart` (includes `AppTheme`, `AppColors`) |
| App already has its own `ThemeData`, or has `AppTheme`/`AppColors` classes | `package:neon_ui/components.dart` (widgets, `NeonPalette`, `NeonStyle`, `NeonScope`, `NeonThemeExt` only) |

When in doubt, `components.dart`: it never clashes and needs no theme.

## 5. Set up the theme

Widgets resolve palette and style in this order: nearest `NeonScope` →
`NeonThemeExt` registered on `ThemeData` → default palette (dark or light,
following the theme's brightness) with the `neon` style. Pick one path:

**A. The kit's theme for the whole app** (import `neon_ui.dart`):

```dart
MaterialApp(
  theme: AppTheme.fromPreset(NeonPreset.neon, brightness: Brightness.light),
  darkTheme: AppTheme.fromPreset(NeonPreset.neon),
  themeMode: ThemeMode.system,
  home: ...,
);
```

- Presets (`NeonPreset`): `neon` (cyan/magenta, default), `matrix`,
  `synthwave`, `ultraviolet`, `ember`.
- The user's brand color: `AppTheme.fromSeed(primary: brand, secondary:
  optional, brightness: ...)`. Backgrounds, text and gradients are derived.
- Token by token: `AppTheme.fromPalette(NeonPalette.defaultDark().copyWith(primary: ...))`.
- Style beyond color, on any of the three: `style: NeonStyle.flat`
  (`neon`, `flat`, `glass`, `soft`, `brutal`, or `NeonStyle.soft.copyWith(...)`).
  Corporate/sober app → `flat` or `soft`; the `neon` glow is very
  opinionated, so confirm with the user before imposing it.

**B. Keep the app's `ThemeData` and just register the kit** (import
`components.dart`): add the extension to the existing theme without
dropping the others.

```dart
ThemeData withNeon(ThemeData base) => base.copyWith(
  extensions: [
    ...base.extensions.values,
    NeonThemeExt(
      palette: NeonPalette.fromSeed(
        primary: base.colorScheme.primary,
        brightness: base.brightness,
      ),
      style: NeonStyle.flat,
    ),
  ],
);

MaterialApp(theme: withNeon(lightTheme), darkTheme: withNeon(darkTheme), ...);
```

This leaves the app's `ColorScheme`, typography and Material widgets
untouched; the neon widgets follow the app's color.

**C. Only part of a screen looks different**: `NeonScope(palette: ...,
style: ..., child: ...)`. It takes precedence over the theme.

**D. Nothing**: with `components.dart` and nothing registered, it works with
the default palette. Fine for a prototype, not for shipping.

## 6. Swap the widgets

Follow [`references/widgets.md`](references/widgets.md). Rules:

- Go screen by screen, not the whole app at once; run `flutter analyze`
  after each screen.
- Neon widgets are **controlled**: they take `value`/`selectedIndex` and
  `onChanged`, with no internal controller (except `NeonTextField`, which
  accepts a `controller`). When replacing `TabBar` + `TabController`, move
  the index into the screen's state.
- Disabled = `onPressed`/`onChanged: null`. Loading = `busy: true` on
  buttons, instead of swapping the child for a `CircularProgressIndicator`.
- Many widgets take a `String` where Material takes a `Widget` (`title` on
  `NeonAppBar`, `NeonListTile`, `NeonDialog`, `NeonExpansionTile`; `label`
  on buttons). If the original builds a specially styled `Text`, tell the
  user the style now comes from the theme.
- `showDialog`/`showModalBottomSheet`/`showDatePicker`/... have `showNeonX`
  versions with the same role; prefer them over wrapping a neon widget in
  `showDialog` by hand.
- Don't replace what has no equivalent (Autocomplete, paginated tables…);
  keep Material and say which ones were left out.
- Kit background: wrap the `body` in `AnimatedGridBackground(child: ...)`.
  It follows the style (grid, dots or plain).
- An app's own component that must match the kit: use
  `NeonThemeExt.of(context).palette`, `NeonStyle.of(context)`,
  `NeonDecorations.panel/selectable/input`, `NeonPressable`. Never hardcoded
  colors or `AppColors` (they ignore presets, seed and light mode).

## 7. Verify

1. `flutter analyze` with no new errors.
2. `flutter test`. Tests that look for `find.byType(ElevatedButton)`,
   `find.byType(TextField)` etc. break where the widget was swapped; update
   them to the neon type (`find.byType(NeonButton)`) or to
   `find.text`/`find.bySemanticsLabel`. Tests using `MaterialApp`/`ThemeData`
   from `flutter/material.dart` need the same `material_ui` import as step 3.
   Never `await` a `showNeonX(...)` call directly in a test: the `Future`
   only completes when the route closes, so the test hangs. Use
   `unawaited(...)` and pump.
3. Run the app in both brightnesses if it has a light mode. In light mode,
   borders of some older kit controls (radio, checkbox, switch,
   slider/progress track, tabs, stepper, data table) come out nearly black:
   a known kit bug (`surfaceOutline.withValues(alpha:)`), not the app's.
   Report it instead of "fixing" it in the app.
4. Summarize for the user: import chosen, theme path (A/B/C), widgets
   swapped, what stayed Material and why.
