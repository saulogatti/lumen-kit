---
name: lumen-kit
description: Apply the lumen_kit package (saulogatti/lumen-kit) to an existing Flutter app. Install the published package or a pinned Git revision, choose a theme integration, and swap Material widgets for Lumen equivalents.
---

# Applying lumen_kit to a Flutter app

Use this when the user asks to use `lumen_kit`, "the neon components" or
"this kit" in a Flutter app that is not the kit's own repository. To change
the kit itself, read the repository's `AGENTS.md`. Talk to the user in
their language; the kit's own documentation and comments are in English.

The full widget map (Material → Lumen, with signatures) is in
[`references/widgets.md`](references/widgets.md). Read it before swapping
any widget: the APIs are **not** copies of Material's.

## 1. Inspect the app first

Find out, from `pubspec.yaml` and the code:

- Check the Dart, Flutter, and `material_ui` constraints in the
  [requirements and installation guide](../../README.md#requirements).
  If the app is below the minimum, explain the toolchain upgrade first.
- Find which Material library the app imports.
  `rg -n 'package:(flutter/material|material_ui/material_ui)\.dart' lib test`.
- Whether it already has its own `ThemeData`, `ThemeExtension`s, or
classes named `AppTheme` or `AppColors` (name clash with the kit).
- Whether it has light and dark modes (`theme` + `darkTheme`/`themeMode`).

## 2. Install

Follow the [installation examples](../../README.md#installation). Use the
published package unless the app needs a change available only in Git. For
Git, pin a commit and use the matching `material_ui` constraint. Run
`flutter pub get` in the app.

## 3. Material: the app must use `material_ui`

The kit is built on the `material_ui` package, not on
`package:flutter/material.dart`. They are separate libraries with distinct
types. In an app that uses `flutter/material.dart` (verified on Flutter
3.47):

- `MaterialApp(theme: AppTheme.dark)` **does not compile** (one
`ThemeData` is not the other).
- Lumen widgets can't see the app's `Theme`: they fall back to the default
**light** palette even when the app uses `ThemeData.dark()`.
- `LumenTextField` (and anything using material_ui's `TextField`/`InkWell`
without a material_ui `Material` above it) throws "No Material widget
found".

Migrate the app's Material imports in `lib/` and `test/`. Review uses of
Material types at third-party package boundaries, then run `flutter analyze`.

`material_ui` re-exports `package:flutter/widgets.dart`, so existing
`widgets.dart` imports may become unnecessary-import warnings; remove them.
Third-party widgets built with `flutter/material.dart` use a different theme
and Material ancestors. Check those widgets separately during migration.

If the user **refuses** the migration, stop and explain: there is no
supported way to mix them. Wrapping neon widgets in a material_ui
`Material` only turns the error into "No MaterialLocalizations found", and
the app's theme remains invisible to them.

## 4. Pick the import

| Situation | Import |
| --- | --- |
| New app, or the user wants the kit's look across the whole app | `package:lumen_kit/lumen_kit.dart` (includes `AppTheme`, `AppColors`) |
| App already has its own `ThemeData`, or has `AppTheme`/`AppColors` classes | `package:lumen_kit/components.dart` (widgets, `LumenPalette`, `LumenStyle`, `LumenScope`, `LumenThemeExt` only) |

When in doubt, `components.dart`: it never clashes and needs no theme.

## 5. Set up the theme

Use the [README theme examples](../../README.md#minimum-usage) to select the
integration that matches the app.

- For an app-wide Lumen theme, configure `AppTheme` for each supported
  brightness. Pair a preset or brand palette with the desired style.
- To keep the app's `ThemeData`, add `LumenThemeExt` to its light and dark
  themes as applicable. Preserve any other extensions.
- For a local variation, wrap the relevant subtree in `LumenScope`.

The nearest scope takes precedence over the registered theme extension.
Without either, the widgets use the kit's light or dark palette according to
the app theme's brightness, with the neon style.

## 6. Swap the widgets

Follow [`references/widgets.md`](references/widgets.md). Rules:

- Go screen by screen, not the entire app at once; run `flutter analyze`
after each screen.
- Keep selection in the screen's state for controls that take
  `value`/`selectedIndex` and `onChanged`. When replacing `TabBar` plus
  `TabController`, pass the selected index to `LumenTabs`.
- Disabled = `onPressed`/`onChanged: null`. Loading = `busy: true` on
buttons, instead of swapping the child for a `CircularProgressIndicator`.
- Many widgets take a `String` where Material takes a `Widget` (`title` on
`LumenAppBar`, `LumenListTile`, `LumenDialog`, `LumenExpansionTile`; `label`
on buttons). If the original builds a specially styled `Text`, tell the
user the style now comes from the theme.
- `showDialog`/`showModalBottomSheet`/`showDatePicker`/... have `showLumenX`
versions with the same role; prefer them over wrapping a neon widget in
`showDialog` by hand.
- Don't replace what has no equivalent (Autocomplete, paginated tables…);
keep Material and say which ones were left out.
- Kit background: wrap the `body` in `LumenAnimatedGridBackground(child: ...)`.
It follows the style (grid, dots or plain).
- An app's own component that must match the kit: use
`LumenThemeExt.of(context).palette`, `LumenStyle.of(context)`,
`LumenDecorations.panel/selectable/input`, `LumenPressable`. Never hardcoded
colors or `AppColors` (they ignore presets, seed and light mode).

## 7. Verify

1. `flutter analyze` with no new errors.
2. `flutter test`. Tests that look for `find.byType(ElevatedButton)`,
`find.byType(TextField)` etc. break where the widget was swapped; update
them to the kit type (`find.byType(LumenButton)`) or to
`find.text`/`find.bySemanticsLabel`. Tests using `MaterialApp`/`ThemeData`
from `flutter/material.dart` need the same `material_ui` import as step 3.
   For a route or overlay helper, start the future with `unawaited(...)`,
   pump, and complete the interaction before awaiting the result.
3. Run the app in both brightnesses if it has a light mode. Outline colors
in the kit go through `Color.outlineAlpha`, which keeps the light
`surfaceOutline` from turning into a near-opaque black border. Tokens that
already carry alpha (`textMuted`, `surfaceHighlight`) use `scaleAlpha`,
which multiplies instead of replacing it.
4. Summarize the import, theme integration, and widgets migrated. Identify
   Material widgets that require separate handling.
