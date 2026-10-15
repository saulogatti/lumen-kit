# AGENTS.md — lumen_kit

Guide for agents (and humans in a hurry) working on this repository.
The README is for people **using** the kit; this file is for people **changing**
the kit. To apply the kit to another app, see the skill at
[`skills/lumen-kit/SKILL.md`](skills/lumen-kit/SKILL.md).

## What it is

`lumen_kit` is a Flutter package (not published on pub.dev, `publish_to: none`)
with a futuristic theme and ~45 widgets. It is consumed via a git dependency.
Everything is domain-agnostic: widgets receive data, callbacks, and tokens,
never business rules.

## Toolchain

- Dart `^3.13.0`, Flutter `>=3.47.0` (the current stable channel works).
- **Material comes from the `material_ui` package, not `flutter/material.dart`.**
  Every file in `lib/` imports `package:material_ui/material_ui.dart` (which
  already re-exports `package:flutter/widgets.dart`). Do not mix it with
  `package:flutter/material.dart`: these are different libraries with different
  types (`ThemeData`, `Theme`, `Material`…), and the result only compiles
  sometimes and fails at runtime otherwise.
- The code uses recent Dart 3.13 syntax (private named parameters such as
  `this._backgroundGradient`, and dot shorthands such as `.vibrant`). Do not
  "fix" these.

## Commands

```bash
flutter pub get                 # at the root; the flutter tool resolves example/ too
flutter analyze                 # must report "No issues found!"
flutter test                    # package tests (test/)
cd example && flutter run -d chrome   # gallery with preset/style/brightness selectors
```

No `flutter` in the container? Run `git clone --depth 1 -b stable
https://github.com/flutter/flutter.git` and use `flutter/bin/flutter`. For gallery
screenshots: run `flutter build web --no-web-resources-cdn` in `example/` and use
Playwright with `locale: 'en-US'` (without a locale the app crashes with
"Incorrect locale information").

`analysis_options.yaml` is very strict (`strict-casts`, `strict-inference`,
`always_put_control_body_on_new_line`, `prefer_relative_imports`,
`specify_nonobvious_*`…). Zero issues from `flutter analyze` is the repository
standard.

Formatting: `dart format` at 80 columns (there is no `page_width` in
`analysis_options.yaml`). The whole repository is already formatted, so
`dart format lib test example/lib` should not create diffs beyond yours.

## Structure

```
lib/
  lumen_kit.dart          # full import: components.dart + AppTheme + AppColors
  components.dart         # widgets + palette/style only, without AppTheme/AppColors
  src/
    theme/              # LumenPalette, LumenPreset, LumenThemeExt, LumenScope, LumenStyle, AppTheme, AppColors
    foundation/         # reusable pieces: LumenPressable, LumenDecorations,
                        #   LumenActionContent, LumenLabeled, LumenMotion + kLumen* tokens
    backgrounds/        # LumenAnimatedGridBackground, LumenGlowOrbSpec
    widgets/            # one file per widget (or family: lumen_tabs.dart has LumenTabs + LumenSegmentedControl)
test/
  widgets/_harness.dart # bareApp/pumpBare: app WITHOUT LumenThemeExt registered
  widgets/*_test.dart   # one test per new widget
  components_import_test.dart  # ensures components.dart works without the kit theme
example/lib/main.dart   # gallery; every new widget appears here
```

### The two public imports

- `package:lumen_kit/lumen_kit.dart`: everything. Exports `components.dart` +
  `AppTheme` + `AppColors`.
- `package:lumen_kit/components.dart`: widgets, foundation, `LumenPalette`,
  `LumenStyle`, `LumenScope`, `LumenThemeExt`. Does **not** export `AppTheme` or
  `AppColors`, to avoid colliding with same-named classes in the user's app
  (`test/components_import_test.dart` covers this).

New widget → `export` in `lib/components.dart` (alphabetical order, enforced by
the `directives_ordering` lint). Never export anything from `src/theme/app_*.dart`
through `components.dart`.

## Theme rules (the ones that break things when ignored)

**Color.** Always use `final LumenPalette p = LumenThemeExt.of(context).palette;`.
Never use `AppColors.x` inside a widget or foundation: the color gets frozen and
ignores `AppTheme.fromSeed`, presets, light mode, and `LumenScope`. Tokens:
`backgroundDeep/Mid/Soft`, `surface`, `surfaceOutline`, `surfaceHighlight`,
`primary`, `secondary`, `tertiary`, `textPrimary/Secondary/Muted`,
`success`, `warning`, `danger`, `backgroundGradient`, `accentGradient`.
`accentCyan/Magenta/Blue` are `@Deprecated` aliases; do not use them in new code.

**Style.** Always use `final LumenStyle s = LumenStyle.of(context);` and pass
effects through it:

| Instead of                    | Use                                  |
|-------------------------------|--------------------------------------|
| `BorderRadius.circular(r)`    | `s.radius(r)`                        |
| `boxShadow: [BoxShadow(...)]` | `s.shadows([...glows])`              |
| `gradient: g`                 | `s.fill(g)` (becomes a solid color in flat/brutal) |
| `Border.all(...)`             | `s.borderAll(color: c, width: w)`    |
| `surface.withValues(alpha: a)`| `surface.withValues(alpha: s.surfaceAlpha(a))` |
| floating panel                | `s.frost(child: ..., borderRadius: ...)` + `LumenDecorations.panel(p, s, accent: a)` |

Otherwise the widget looks the same in all five styles (neon, flat, glass, soft,
brutal).

**Theme resolution.** `LumenThemeExt.of(context)` searches in this order:
nearest `LumenScope` → `LumenThemeExt` in `ThemeData` → default palette (dark
or light, according to `Theme.of(context).brightness`) with `LumenStyle.neon`.
Every widget must work in this third case, with nothing registered; this is what
`bareApp` tests.

**Alpha in palette colors.** `Color.withValues(alpha: x)` **replaces** alpha; it
does not multiply it. The default light `surfaceOutline` is already translucent
(`0x15000000`), so `p.surfaceOutline.withValues(alpha: 0.5)` becomes nearly
opaque black. Use `p.surfaceOutline.outlineAlpha(0.5)` for outlines: in dark
mode, the requested alpha is applied directly (cyan stays visible), and in
light mode the faint black is only scaled. Tokens that are translucent by
default (`textMuted`, `textSecondary`, `surfaceHighlight`) use `c.scaleAlpha(x)`,
which computes `c.a * x`. Opaque accents can use `withValues(alpha:)` freely.
Do not multiply an opaque accent expecting to soften a token that already had
alpha.

**Material 3 and typography.** Text uses `Theme.of(context).textTheme` with
`copyWith(color: p.textX)`. Do not set `fontFamily`.

## Widget conventions

- One file per widget in `lib/src/widgets/`, named `lumen_<thing>.dart`.
- `const` constructor, `super.key` immediately after `required` parameters,
  color overrides such as `Color? accentColor` (default `p.primary`).
- Controlled externally: `value` + `onChanged`. `onChanged == null` (or
  `onPressed == null`) means disabled, with `kLumenDisabledOpacity` opacity.
  `busy: true` means an inline spinner (`LumenActionContent`).
- Tappable area: `LumenPressable` (ripple, keyboard focus, `selected`/`checked`/
  `toggled` semantics), not a bare `GestureDetector`. Control + label:
  `LumenLabeled`.
- Animations: pass `kLumenFastDuration`/`kLumenMediumDuration` durations through
  `LumenMotion.duration(context, d)`; use `LumenMotion.syncRepeat` for loops in
  `didChangeDependencies`/`didUpdateWidget`. Everything must stop when the
  system requests "reduce animations" (`MediaQuery.disableAnimations`).
- `showLumenX` functions (dialog, bottom sheet, menu, toast, loading…) follow
  the same pattern: `required BuildContext context`, read palette/style from
  `context`, and return a `Future`.
- Document every public member with `///` comments in English. Use ` ```dart `
  blocks for examples.

## New widget checklist

1. `lib/src/widgets/lumen_x.dart` following the rules above.
2. `export` in `lib/components.dart`.
3. `test/widgets/lumen_x_test.dart` using `pumpBare` (works without a theme),
   covering interaction, disabled state, semantics, and reduce motion when
   animated.
   In tests, **never directly `await` `showLumenX`** (dialog, picker, toast,
   loading): the `Future` only completes when the route closes, so the test
   waits forever. Use `unawaited(showLumenX(...).then(...))` (from `dart:async`),
   which satisfies the `unawaited_futures` lint, and pump with `tester.pump`.
4. A section in the gallery (`example/lib/main.dart`).
5. A row in the README's "What's included" table + a short example if the API
   is not obvious; update `ROADMAP.md`.
6. Clean `dart format lib test example/lib`, `flutter analyze`, and `flutter test`.

## Git

Commits in Portuguese, using conventional style (`feat:`, `fix:`, `refactor:`).
PRs describe what changes visually; gallery screenshots help when visuals change.
