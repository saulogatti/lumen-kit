# Copilot instructions for `lumen_kit`

## Project and commands

`lumen_kit` is an unpublished Flutter widget package (`publish_to: none`) for
domain-agnostic, configurable futuristic UI components. It requires Dart
`^3.13.0` and Flutter `>=3.47.0`.

Run commands from the repository root:

```bash
flutter pub get
dart format lib test example/lib
flutter analyze
flutter test
```

Run one test file or one named test with:

```bash
flutter test test/widgets/lumen_button_test.dart
flutter test test/widgets/lumen_button_test.dart --plain-name "renders solid variant"
```

The package and `example/` form a Dart workspace; `flutter pub get` at the root
resolves both. Launch the component gallery with:

```bash
cd example && flutter run -d chrome
```

The analyzer is intentionally strict. Preserve explicit non-obvious types,
single quotes, package imports within `lib/` (`package:lumen_kit/src/...`,
never relative), 100-column formatting (`page_width: 100`), and the other
rules in `analysis_options.yaml`.

## Architecture

- `lib/lumen_kit.dart` is the full public API: it re-exports
  `components.dart`, `AppTheme`, and `AppColors`.
- `lib/components.dart` is the embeddable widget-only API. It exports widgets,
  shared foundation helpers, palette/style APIs, and background APIs, but must
  **not** export `AppTheme` or `AppColors` because host apps may define classes
  with those names. Keep its exports alphabetized.
- `lib/src/theme/` owns palette generation, presets, `LumenStyle`,
  `LumenScope`, `LumenThemeExt`, and full `ThemeData` construction. `AppTheme`
  installs `LumenThemeExt` on `ThemeData`.
- Widgets resolve active theme data in this order:
  nearest `LumenScope`, `LumenThemeExt` in `ThemeData`, then a brightness-aware
  default palette with the neon style. This fallback is a public compatibility
  guarantee for consumers importing only `components.dart`.
- `lib/src/foundation/` contains the shared interaction, decoration, label,
  action-content, motion, and token primitives that keep widgets consistent.
  Reuse these rather than recreating per-widget versions.
- `example/lib/main.dart` is the gallery for the complete public component
  surface. Add new public widgets there and update the README/ROADMAP entries
  when expanding the package.

## Implementation conventions

- Import `package:material_ui/material_ui.dart` in `lib/`; do not mix it with
  `package:flutter/material.dart`. The packages expose incompatible Material
  types.
- Resolve colors and style at build time:

  ```dart
  final LumenPalette p = LumenThemeExt.of(context).palette;
  final LumenStyle s = LumenStyle.of(context);
  ```

  Do not use `AppColors` in widgets or foundation code. It freezes colors and
  bypasses seeds, presets, brightness, and `LumenScope`.
- Route visual effects through `LumenStyle`: use `s.radius`, `s.shadows`,
  `s.fill`, `s.borderAll`, `s.surfaceAlpha`, and `s.frost`. This preserves the
  distinct neon, flat, glass, soft, and brutal styles.
- Palette alpha is semantic: use `p.surfaceOutline.outlineAlpha(...)` for
  outlines and `scaleAlpha(...)` for tokens already carrying alpha
  (`textMuted`, `textSecondary`, `surfaceHighlight`). Use `withValues` only
  when replacing alpha is intended, such as for opaque accent colors.
- Public widgets are generally controlled from outside (`value` plus
  `onChanged`). A null `onChanged`/`onPressed` means disabled and uses
  `kLumenDisabledOpacity`; `busy: true` renders inline progress with
  `LumenActionContent`.
- Use `LumenPressable` for tappable controls so keyboard focus, ripple,
  disabled behavior, and accessibility semantics stay consistent. Use
  `LumenLabeled` for control-and-label layouts.
- New animations must use `LumenMotion.duration` with `kLumen*Duration`;
  repeating animations must synchronize through `LumenMotion.syncRepeat` and
  respect `MediaQuery.disableAnimations`.
- Public APIs require English `///` documentation. `showLumenX` helpers
  take a required `BuildContext`, derive their theme from it, and return a
  `Future`.

## Tests

Widget tests live in `test/widgets/`. Build new widget tests on `pumpBare` from
`test/widgets/_harness.dart`: it deliberately provides no `LumenThemeExt`, so
tests verify the `components.dart` fallback contract. Cover interactive,
disabled, semantic, and reduced-motion behavior where applicable.

Do not directly `await` a `showLumenX` future in a widget test: it completes
only after its route closes. Start it with `unawaited(showLumenX(...).then(...))`
and advance the test with `tester.pump`.
