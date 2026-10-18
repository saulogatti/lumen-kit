# AGENTS.md — lumen_kit

Guide for agents (and humans in a hurry) who will touch this repository.
The README is for anyone **using** the kit; this file is for those who **change** the kit.
To apply the kit in another app, see the skill in
[`skills/lumen-kit/SKILL.md`](skills/lumen-kit/SKILL.md).

## What is it

`lumen_kit` is a Flutter package (not published on pub.dev, `publish_to: none`)
with futuristic theme and ~45 widgets. Consumed via git dependency. Everything is
domain decoupled: widgets receive data, callbacks and tokens, never
business rules.

##Toolchain

- Dart `^3.13.0`, Flutter `>=3.47.0` (current stable channel will do).
- **Material comes from package `material_ui`, not `flutter/material.dart`.**
Every file in `lib/` imports `package:material_ui/material_ui.dart` (which
already re-exports `package:flutter/widgets.dart`). Do not mix with
`package:flutter/material.dart`: they are different libraries with types
different types (`ThemeData`, `Theme`, `Material`…), and the result compiles only at
times and fails at runtime other times.
- Code uses recent Dart 3.13 syntax (private named parameters
as `this._backgroundGradient`, dot shorthands as `.vibrant`). No
"fix" this.

## Commands

```bash
flutter pub get                 # na raiz; o flutter tool resolve example/ junto
flutter analyze                 # precisa sair "No issues found!"
flutter test                    # testes do pacote (test/)
cd example && flutter run -d chrome   # galeria com seletor de preset/estilo/brilho
```

There is no `flutter` in the container? `git clone --depth 1 -b stable
https://github.com/flutter/flutter.git` and use `flutter/bin/flutter`. To
gallery screenshots: `flutter build web --no-web-resources-cdn` on
`example/` and Playwright with `locale: 'en-US'` (without locale the app breaks with
"Incorrect locale information").

`analysis_options.yaml` is very strict (`always_use_package_imports`,
`directives_ordering`, `strict_top_level_inference`, `specify_nonobvious_*`,
several inference/null-safety checks promoted to `error`…). Imports inside
`lib/` are package imports (`package:lumen_kit/src/...`), never relative.
`flutter analyze` with zero issues is the default repo.

Formatting: `dart format` at 100 columns (`formatter: page_width: 100` in
`analysis_options.yaml`). The entire repo is already formatted, so
`dart format lib test example/lib` should not generate diff other than yours.

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
example/lib/main.dart   # galeria; todo widget novo aparece aqui
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
- Animations: `kLumenFastDuration`/`kLumenMediumDuration` durations passed by
`LumenMotion.duration(context, d)`; loops via `LumenMotion.syncRepeat` on
`didChangeDependencies`/`didUpdateWidget`. Everything needs to stop
"reduce animations" (`MediaQuery.disableAnimations`).
- `showLumenX` functions (dialog, bottom sheet, menu, toast, loading…) follow the
same pattern: `required BuildContext context`, read palette/style
`context` and return `Future`.
- Docs (`///`) in English, on every public member. Block examples
` ```dart `.

## Checklist for new widget

1. `lib/src/widgets/lumen_x.dart` following the rules above.
2. `export` in `lib/components.dart`.
3. `test/widgets/lumen_x_test.dart` using `pumpBare` (works without theme),
covering interaction, disabled state, semantics and reduce motion when
there is animation.
In testing, **never give `await` directly to `showLumenX`** (dialog, picker,
toast, loading): `Future` only completes when the route closes, and the test
hangs forever waiting. Use `unawaited(showLumenX(...).then(...))`
(from `dart:async`), which is what the `unawaited_futures` lint accepts, and
pump with `tester.pump`.
4. Section in the gallery (`example/lib/main.dart`).
5. Row in the `README.md` "What's inside" table + short example if the API
is not obvious; score on `ROADMAP.md`.
6. Clean `dart format lib test example/lib`, `flutter analyze` and `flutter test`.

## Git

Use Portuguese conventional commits (`feat:`, `fix:`,
`refactor:`). PRs describe what changes visually; screenshot from gallery
It helps when the look changes.
