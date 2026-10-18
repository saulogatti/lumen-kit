# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Read [`AGENTS.md`](AGENTS.md) first.** It is the source of truth for theme
rules (palette/style resolution, alpha handling), widget conventions and the
new-widget checklist. This file only adds what AGENTS.md does not say.

## Commands

```powershell
flutter pub get                       # root; resolves the example/ workspace too
flutter analyze                       # must report "No issues found!"
flutter test                          # whole suite
flutter test test/widgets/lumen_button_test.dart                          # one file
flutter test test/widgets/lumen_button_test.dart --plain-name "renders"  # one test
dart format lib test example/lib      # never `dart format .` at the root
cd example; flutter run -d chrome     # gallery (preset / style / brightness picker)
```

`docs/` is committed dartdoc HTML output (config in `dartdoc_options.yaml`); do
not edit it by hand.

## Big picture

- Two public entry points: `lib/lumen_kit.dart` (everything) and
  `lib/components.dart` (widgets only, no `AppTheme`/`AppColors`, so it does not
  collide with host-app classes). `test/components_import_test.dart` guards this.
- Color (`LumenPalette`) and effect (`LumenStyle`: neon/flat/glass/soft/brutal)
  are orthogonal. Widgets never hardcode either; they resolve both from
  `context` at build time, with a fallback that works when nothing is
  registered. `test/widgets/_harness.dart` (`pumpBare`) tests exactly that
  fallback.
- Material types come from the `material_ui` package, not
  `package:flutter/material.dart`; mixing them breaks at runtime.
- `example/lib/main.dart` is the gallery covering the whole public surface.
- `skills/lumen-kit/SKILL.md` is the guide for applying the kit in another app.
- `REVISAO.md` is a past review written when the package was still `neon_ui`
  (names there use the old `Neon` prefix).
