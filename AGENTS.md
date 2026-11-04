# AGENTS.md — lumen_kit

Guide for agents (and humans in a hurry) who will touch this repository.
The README is for anyone **using** the kit; this file is for those who **change** the kit.
To apply the kit in another app, see the skill in
[`skills/lumen-kit/SKILL.md`](skills/lumen-kit/SKILL.md).

## What is it

`lumen_kit` is a Flutter widget package with configurable palettes and visual
styles. Widgets receive data, callbacks, and tokens. The app owns its
business rules. See the [installation guide](README.md#installation) for
the published package and pinned Git checkouts.

## Toolchain

- Dart `^3.13.0`, Flutter `>=3.47.0` (current stable channel will do).
- Use `package:material_ui/material_ui.dart` for Material types. It re-exports
  `package:flutter/widgets.dart`. Mixing it with `package:flutter/material.dart`
  can produce incompatible `ThemeData`, `Theme`, and `Material` types.
- Preserve Dart 3.13 syntax, including private named parameters such as
  `this._backgroundGradient` and dot shorthands such as `.vibrant`.

## Commands

```bash
flutter pub get
dart format lib test example/lib example/test
flutter analyze
flutter test
```

Run these commands from the repository root. Dependency resolution includes
the `example/` workspace. The analyzer should report `No issues found!`.
Run `flutter test --coverage` to generate `coverage/lcov.info` as CI does.

Run `flutter test` from `example/` for the gallery smoke tests. See the
[example README](example/README.md) for running the Windows gallery and
using its Material comparison. Hot reload and hot restart are debugging
tools. Use them when useful in an active debug session or when requested.

`docs/` contains generated Dart API documentation. Change the source Dartdoc
or `dartdoc_options.yaml` when updating it.

`analysis_options.yaml` is very strict (`always_use_package_imports`,
`directives_ordering`, `strict_top_level_inference`, `specify_nonobvious_*`,
several inference/null-safety checks promoted to `error`…). Imports inside
`lib/` are package imports (`package:lumen_kit/src/...`), never relative.
`flutter analyze` with zero issues is the default repo.

Use `dart format` with the analysis options for each package. The root
package sets `formatter.page_width` to 100.

## Structure

```
lib/
  lumen_kit.dart          # import completo: components.dart + AppTheme + AppColors
  components.dart       # só widgets + paleta/estilo, sem AppTheme/AppColors
  src/
    theme/              # lumen_palette.dart (LumenPalette, LumenPreset, LumenScope, LumenThemeExt),
                        #   lumen_style.dart, app_theme.dart, app_colors.dart
    foundation/         # peças reaproveitáveis: LumenPressable, LumenDecorations,
                        #   LumenActionContent, LumenLabeled; lumen_tokens.dart (LumenMotion + kLumen* tokens)
    backgrounds/        # LumenAnimatedGridBackground, LumenGlowOrbSpec
    widgets/            # um arquivo por widget (ou família: lumen_tabs.dart tem LumenTabs + LumenSegmentedControl)
test/
  widgets/_harness.dart # bareApp/pumpBare: app SEM LumenThemeExt registrado
  widgets/*_test.dart   # um teste por widget novo
  components_import_test.dart  # garante que components.dart funciona sem o tema do kit
example/lib/main.dart              # galeria de componentes Lumen
example/lib/material_gallery.dart  # comparação com o Material padrão
example/test/smoke_test.dart       # testes da galeria
```

### The two public imports

- `package:lumen_kit/lumen_kit.dart`: everything. Exports `components.dart`+
`AppTheme` + `AppColors`.
- `package:lumen_kit/components.dart`: widgets, foundation, `LumenPalette`,
`LumenStyle`, `LumenScope`, `LumenThemeExt`. **Doesn't** export `AppTheme` or
`AppColors`, to not collide with classes with the same name in the user's app
(`test/components_import_test.dart` covers this).

New widget → `export` in `lib/components.dart` (alphabetical order, lint
`directives_ordering` snake). Never export anything from `src/theme/app_*.dart`
by `components.dart`.

## Theme rules (the ones that break things when ignored)

**Color.** Always `final LumenPalette p = LumenThemeExt.of(context).palette;`.
Never `AppColors.x` inside a widget or foundation: the color is frozen and
ignores `AppTheme.fromSeed`, presets, light mode and `LumenScope`. Tokens:
`backgroundDeep/Mid/Soft`, `surface`, `surfaceOutline`, `surfaceHighlight`,
`primary`, `secondary`, `tertiary`, `textPrimary/Secondary/Muted`,
`success`, `warning`, `danger`, `backgroundGradient`, `accentGradient`.
`accentCyan/Magenta/Blue` are `@Deprecated` aliases; do not use in new code.

**Style.** Always `final LumenStyle s = LumenStyle.of(context);` and pass
effects for him:

| Instead of | Use |
|-------------------------------|--------------------------------------|
| `BorderRadius.circular(r)` | `s.radius(r)` |
| `boxShadow: [BoxShadow(...)]` | `s.shadows([...glows])` |
| `gradient: g` | `s.fill(g)` (turns solid color in flat/brutal) |
| `Border.all(...)` | `s.borderAll(color: c, width: w)` |
| `surface.withValues(alpha: a)`| `surface.withValues(alpha: s.surfaceAlpha(a))` |
| floating panel | `s.frost(child: ..., borderRadius: ...)` + `LumenDecorations.panel(p, s, accent: a)` |

Otherwise, the widget looks the same in the five styles (neon, flat, glass, soft, brutal).

**Theme resolution.** `LumenThemeExt.of(context)` searches, in this order:
nearest `LumenScope` → `LumenThemeExt` in `ThemeData` → default palette
(dark or light according to `Theme.of(context).brightness`) with
`LumenStyle.neon`. Every widget has to work in the third case, without anything
registered; This is what `bareApp` tests.

**Alpha in palette colors.** `Color.withValues(alpha: x)` **replaces** the
alpha, does not multiply. `surfaceOutline` in the clear default is already translucent
(`0x15000000`), then `p.surfaceOutline.withValues(alpha: 0.5)` turns black
almost opaque. For contouring use `p.surfaceOutline.outlineAlpha(0.5)`: no
in dark the requested alpha goes straight in (the cyan remains visible) and in light the
weak black is just scaled. Token that is born translucent (`textMuted`,
`textSecondary`, `surfaceHighlight`) uses `c.scaleAlpha(x)`, which makes `c.a * x`.
Opaque Accent can use `withValues(alpha:)` at will. Don't multiply one
opaque accent thinking that it is softening a token that already had alpha.

**Material 3 and typography.** Text uses `Theme.of(context).textTheme` with
`copyWith(color: p.textX)`. Do not set `fontFamily`.

## Widget conventions

- One file per widget in `lib/src/widgets/`, name `lumen_<coisa>.dart`.
- Constructor `const`, `super.key` right after `required`, color overrides
as `Color? accentColor` (default `p.primary`).
- Controlled from outside: `value` + `onChanged`. `onChanged == null` (or
`onPressed == null`) = disabled, with opacity `kLumenDisabledOpacity`.
`busy: true` = inline spinner (`LumenActionContent`).
- Touchable area: `LumenPressable` (ripple, keyboard focus, semantics
`selected`/`checked`/`toggled`), not raw `GestureDetector`. Control +
label: `LumenLabeled`.
- Use `spacing:` for uniform spacing between children of a `Row` or `Column`.
- Animations: `kLumenFastDuration`/`kLumenMediumDuration` durations passed by
`LumenMotion.duration(context, d)`; loops via `LumenMotion.syncRepeat` on
`didChangeDependencies`/`didUpdateWidget`. Everything needs to stop
"reduce animations" (`MediaQuery.disableAnimations`).
- `showLumenX` functions take a required `BuildContext` and resolve palette
  and style from it. Route and overlay helpers return a `Future`.
  `showLumenSnackBar` returns a `ScaffoldFeatureController`.
- Docs (`///`) in English, on every public member. Block examples
` ```dart `.

## Checklist for new widget

1. `lib/src/widgets/lumen_x.dart` following the rules above.
2. `export` in `lib/components.dart`.
3. `test/widgets/lumen_x_test.dart` using `pumpBare` (works without theme),
covering interaction, disabled state, semantics and reduce motion when
there is animation.
   Start route or overlay helpers with
   `unawaited(showLumenX(...).then(...))` from `dart:async`, then pump and
   complete the interaction. Awaiting their futures before pumping can
   hang a widget test.
4. Section in the gallery (`example/lib/main.dart`).
5. Update the README catalog and add a short example when the API needs one.
   Remove the corresponding item from `ROADMAP.md` if it was planned there.
6. Run formatting, analysis, and the package and gallery tests as appropriate.

## Git

Use Portuguese conventional commits (`feat:`, `fix:`,
`refactor:`). PRs describe what changes visually; screenshot from gallery
It helps when the look changes.
