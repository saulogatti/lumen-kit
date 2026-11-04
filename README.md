# lumen_kit

[![CI](https://github.com/saulogatti/lumen-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/saulogatti/lumen-kit/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/saulogatti/lumen-kit/graph/badge.svg?token=oU4zJUQCy9)](https://codecov.io/gh/saulogatti/lumen-kit)

A Flutter widget kit with independently configurable colors and visual styles.
Choose a palette and pair it with neon, flat, glass, soft, or brutal styling.

## What's inside

| Category | Components |
| ------------- | -------------------------------------------------------------------- |
| Theme | `AppColors`, `LumenPalette`, `LumenPreset`, `LumenStyle`, `LumenThemeExt`, `LumenScope`, `AppTheme` |
| Background | `LumenAnimatedGridBackground`, `LumenGlowOrbSpec` |
| Structure | `LumenAppBar`, `LumenCard` |
| Action | `LumenCta`, `LumenButton`, `LumenIconButton`, `LumenFab`, `LumenMenuButton`, `LumenContextMenu` |
| Input | `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenRangeSlider`, `LumenDropdown`, `LumenSearchBar`, `LumenDatePicker`, `LumenTimePicker`, `LumenChip` (+ `LumenChoiceChips`, `LumenFilterChips`), `LumenQuantityStepper`, `LumenRating`, `LumenPinField` |
| Feedback | `LumenStatusChip`, `LumenBanner`, `LumenDialog`, `showLumenSnackBar`, `showLumenToast`, `LumenLinearProgress`, `LumenCircularProgress`, `LumenSkeleton`, `LumenTooltip`, `LumenLoadingPanel`, `LumenLoadingOverlay` (+ `showLumenLoading`) |
| Navigation | `LumenNavigationCard`, `LumenTabs`, `LumenSegmentedControl`, `LumenBottomNavBar`, `LumenNavRail`, `showLumenBottomSheet`, `LumenDrawer`, `LumenStepper`, `LumenPageIndicator`, `LumenCarousel` |
| Display | `LumenBadge`, `LumenTag`, `LumenAvatar`, `LumenAvatarGroup`, `LumenListTile`, `LumenList`, `LumenEmptyState`, `LumenDivider`, `LumenExpansionTile`, `LumenDataTable`, `LumenTableRow` |

The widgets take data, callbacks, and theme tokens so the app owns its business rules.

## Requirements

- Dart `^3.13.0` and Flutter `>=3.47.0`.
- Use `package:material_ui/material_ui.dart` for the Material app and its
  widgets. `flutter/material.dart` and `material_ui` have distinct
  `ThemeData` and `Material` types. See the
  [integration guide](skills/lumen-kit/SKILL.md#3-material-the-app-must-use-material_ui)
  when adding Lumen to an existing Flutter app.

## Installation

### Published package

Use the [pub.dev release](https://pub.dev/packages/lumen_kit) for the published
version. This example uses the `1.0.0` release constraints.

```yaml
dependencies:
  lumen_kit: ^1.0.0
  material_ui: ^1.7.0
```

### Git checkout

To try the `1.0.1` code before it is released, pin a commit on the repository.
The commit below includes the updates documented here and requires
`material_ui ^1.10.0`.

```yaml
dependencies:
  lumen_kit:
    git:
      url: https://github.com/saulogatti/lumen-kit.git
      ref: 43c30821d4b1f2460033a3dae1b290859cad3e69
  material_ui: ^1.10.0
```

Run `flutter pub get` from your app after choosing an installation method.

## Minimum usage

### Use the Lumen theme for the whole app

Use the full import to get `AppTheme`, which configures Material theme defaults
and registers the Lumen palette and style.

```dart
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(
  MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: const Scaffold(
      appBar: LumenAppBar(title: 'Dashboard'),
      body: Center(child: LumenCard(child: Text('Online service'))),
    ),
  ),
);
```

### Only the components (without the theme)

Use `components.dart` to keep your Material theme and avoid name collisions
with your own `AppTheme` or `AppColors`. Register a `LumenThemeExt` on each
theme that should supply a specific palette and style. The extension preserves
the app's typography and Material settings.

```dart
import 'package:lumen_kit/components.dart';
import 'package:material_ui/material_ui.dart';

ThemeData withLumen(ThemeData base) => base.copyWith(
  extensions: <ThemeExtension<dynamic>>[
    ...base.extensions.values.where((extension) => extension is! LumenThemeExt),
    LumenThemeExt(
      palette: LumenPalette.fromSeed(
        primary: base.colorScheme.primary,
        brightness: base.brightness,
      ),
      style: LumenStyle.flat,
    ),
  ],
);
```

Without a Lumen extension, the widgets use the kit's light or dark palette
according to the app's theme brightness, with the neon style.

### Style one part of a screen

`LumenScope` applies a palette and style to its subtree. Widgets read the
nearest scope first, then the theme extension, then the default palette and style.
Routes and overlays can sit above a scope that wraps only the caller.
`showLumenDialog` resolves its appearance from the dialog route, while
`showLumenBottomSheet` carries the caller's accent to the sheet.
`showLumenLoading` carries both the caller's palette and style.

```dart
Widget saveAction(BuildContext context, VoidCallback onSave) => LumenScope(
  palette: LumenPalette.fromSeed(
    primary: Colors.teal,
    brightness: Theme.of(context).brightness,
  ),
  style: LumenStyle.flat,
  child: LumenButton(label: 'Save', onPressed: onSave),
);
```

## Changing colors

Widgets that use Lumen color tokens resolve the active palette. Explicit color
overrides and typography supplied by the Material theme keep their own values.

```dart
// 1. Preset ready: neon (default), matrix, synthwave, ultraviolet, ember.
MaterialApp(theme: AppTheme.fromPreset(LumenPreset.matrix), home: ...);

// 2. One or two colors: backgrounds, surfaces, texts, glows and gradients
//    are derived automatically.
MaterialApp(
  theme: AppTheme.fromSeed(
    primary: Colors.greenAccent,
    secondary: Colors.orangeAccent, // optional
    brightness: Brightness.dark,     // or Brightness.light
  ),
  home: ...,
);

// 3. Fine-tuning specific tokens (gradients are recalculated automatically).
final palette = LumenPalette.defaultDark().copyWith(primary: Colors.greenAccent);
MaterialApp(theme: AppTheme.fromPalette(palette), home: ...);
```

`LumenThemeExt.lerp` interpolates palette changes during theme transitions.

> `accentCyan`, `accentMagenta` and `accentBlue` became `primary`, `secondary`
> and `tertiary`. The old names continue to function as `@Deprecated`.

Inside any widget, access via extension:

```dart
final p = LumenThemeExt.of(context).palette;
return Container(color: p.surface);
```

## Changing the style (in addition to color)

"Neon" (glow, gradients, grid) is just one of the styles. `LumenStyle` controls
shadow, fill, surface, border and background, and matches any palette:

| Style | Visual |
| ---------- | --------------------------------------------------------------- |
| `neon` | Colorful glow, gradients, grid + orbs (default) |
| `flat` | Neutral shadows and solid fills where the style is applied. The decorative background keeps its gradient and omits the grid and default orbs. |
| `glass` | Translucent surfaces with blur, soft glow |
| `soft` | Very round corners, diffuse shadows, and a dotted background. Removes borders drawn through `LumenStyle.borderAll`. |
| `brutal` | Straight corners, thick edge, offset hard shadow |

```dart
MaterialApp(
  theme: AppTheme.fromPreset(LumenPreset.matrix, style: LumenStyle.flat),
  home: ...,
);

// Fine-tuning starting from a preset.
final style = LumenStyle.soft.copyWith(
  background: LumenBackgroundKind.grid,
  radiusScale: 1.2,
);
```

## Assembling own components

The parts that kit widgets wear inside are also public
(`package:lumen_kit/components.dart`), then a widget of yours earns the same
behavior and follows palette and style without copying code:

```dart
final LumenPalette p = LumenThemeExt.of(context).palette;
final LumenStyle s = LumenStyle.of(context);

LumenPressable(                       // ripple, focus, disabled 0.55, semantics
  onTap: save,
  borderRadius: s.radius(14),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: LumenDecorations.panel(p, s, accent: p.secondary),
    child: LumenActionContent(color: p.textPrimary, icon: Icons.save, label: 'Salvar', busy: saving),
  ),
);
```

| Ask | For what |
| --- | --- |
| `LumenPressable` | Touchable area with ripple, keyboard, `selected`/`checked`/`toggled` for screen readers and opacity disabled |
| `LumenDecorations` | `panel` (dialog/toast/tooltip), `selectable` (navigation item), `iconBox`, `input` (`InputDecoration`), `accent`/`diagonal` (gradients) |
| `LumenActionContent` | Spinner or icon + text, as in buttons |
| `LumenLabeled` | Control + label (checkbox, radio, switch) |
| `LumenMotion` / `kLumen*` | Durations, disabled opacity and respect to "reduce animations" |

Skeleton and Lumen indeterminate progress animations hold a static state
when the system requests reduced motion. Transitions using
`LumenMotion.duration` become instantaneous.

## Configurable background

```dart
LumenAnimatedGridBackground(
  gridSpacing: 80,
  gridOpacity: 0.08,
  orbs: const <LumenGlowOrbSpec>[
    LumenGlowOrbSpec(color: Colors.cyanAccent, size: 380, top: -120, left: -120),
    LumenGlowOrbSpec(
      color: Colors.purpleAccent,
      size: 320,
      bottom: -100,
      right: -80,
    ),
  ],
  child: child,
);
```

## Large list and code

`LumenList` builds rows on demand. Supply a `separatorBuilder` to add
separators and an `empty` widget for zero items. Give the list a bounded
viewport for large data sets. The Git version also exposes scroll options such
as `physics`, `scrollDirection`, and `reverse`.

```dart
LumenList(
  itemCount: eventos.length,
  empty: const LumenEmptyState(
    icon: Icons.inbox_outlined,
    title: 'No events',
  ),
  itemBuilder: (context, i) => LumenListTile(
    title: eventos[i].titulo,
    onTap: () => abrir(eventos[i]),
  ),
)
```

`LumenPinField` is controlled by `value` and `onChanged`. Set
`onChanged` to `null` to disable input. `onCompleted` fires when typing
or pasting takes the code from incomplete to complete. Assigning a complete
`value` programmatically only updates the displayed code.

```dart
LumenPinField(
  value: _codigo,
  onChanged: (String v) => setState(() => _codigo = v),
  onCompleted: enviar,
)
```

`LumenBanner` stays visible until its parent removes it. To add a close
button, pass an `onDismiss` callback that updates the parent's state.

## Button variants

```dart
Row(
  children: <Widget>[
    LumenButton(label: 'CONFIRM', icon: Icons.check, onPressed: () {}),
    const SizedBox(width: 12),
    LumenButton.outline(label: 'EDIT', icon: Icons.edit, onPressed: () {}),
    const SizedBox(width: 12),
    LumenButton.ghost(label: 'CANCEL', onPressed: () {}),
  ],
);
```

- `solid` uses the accent gradient in gradient styles and a solid fill in
  flat and brutal, as does `LumenCta`.
- `outline` — glow edge + translucent background. Secondary action.
- `ghost` — only text/icon in accent color. Tertiary action.

## Selection inputs

```dart
LumenSwitch(value: on, onChanged: (v) => setState(() => on = v));

LumenCheckbox(value: checked, tristate: true, onChanged: (v) => …);

LumenRadio<String>(
  value: 'a',
  groupValue: selected,
  label: 'Option A',
  onChanged: (v) => setState(() => selected = v ?? selected),
);

LumenDropdown<String>(
  label: 'Accent',
  value: current,
  items: const [
    LumenDropdownItem(value: 'cyan', label: 'Cyan'),
    LumenDropdownItem(value: 'magenta', label: 'Magenta'),
  ],
  onChanged: (v) => setState(() => current = v ?? current),
);

LumenDatePicker(
  label: 'Start',
  value: date,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (d) => setState(() => date = d),
);

LumenTimePicker(
  label: 'Time',
  value: time,
  onChanged: (t) => setState(() => time = t),
);

LumenRangeSlider(
  values: preco,
  max: 500,
  divisions: 50,
  onChanged: (v) => setState(() => preco = v),
  onChangeEnd: (v) => buscar(v), // dispara a busca só ao soltar
);
```

## Chips, quantity and evaluation

```dart
// Escolha única.
LumenChoiceChips<String>(
  value: tamanho,
  onChanged: (v) => setState(() => tamanho = v),
  items: const [
    LumenChipItem(value: 'p', label: 'P'),
    LumenChipItem(value: 'm', label: 'M'),
  ],
);

// Filtros (vários marcados). Recebe e devolve um Set novo.
LumenFilterChips<String>(
  values: filtros,
  onChanged: (v) => setState(() => filtros = v),
  items: const [
    LumenChipItem(value: 'promo', label: 'Promotion'),
    LumenChipItem(value: 'frete', label: 'Free shipping'),
  ],
);

LumenQuantityStepper(value: qtd, min: 1, max: 10, onChanged: (v) => setState(() => qtd = v));

LumenRating(value: nota, allowHalf: true, onChanged: (v) => setState(() => nota = v));
LumenRating(value: 4.3, size: 16); // read-only, with fraction
```

## Menu, loading and carousel

```dart
// O "⋮" de card / app bar.
LumenMenuButton<String>(
  items: const [
    LumenMenuItem(value: 'edit', label: 'Edit', icon: Icons.edit),
    LumenMenuDivider(),
    LumenMenuItem(value: 'del', label: 'Delete', destructive: true),
  ],
  onSelected: (v) => …,
);

// Right-click (desktop/web) or long press (mobile).
LumenContextMenu<String>(items: itens, onSelected: …, child: linha);

// Locks the screen during submit and returns the result of the task.
final ok = await showLumenLoading(
  context: context,
  message: 'Enviando…',
  task: () => api.enviar(form),
);

// Or just an area, controlled by state.
LumenLoadingOverlay(loading: salvando, message: 'Salvando…', child: form);

// Gallery / onboarding with page dots.
LumenCarousel(
  itemCount: fotos.length,
  itemBuilder: (context, i) => Image.network(fotos[i], fit: BoxFit.cover),
);
// Or just the dots, linked to your PageView.
LumenPageIndicator(count: 4, controller: pageController);

// Stacked avatars with "+N".
LumenAvatarGroup(
  avatars: [for (final u in membros) LumenAvatar(initials: u.iniciais)],
  maxVisible: 3,
  total: totalDeMembros,
);
```

## Navigation

```dart
// Compact pill — great for switching views within a screen.
LumenSegmentedControl(
  selectedIndex: i,
  onChanged: (v) => setState(() => i = v),
  items: const [
    LumenTabItem(label: 'Dia'),
    LumenTabItem(label: 'Semana'),
    LumenTabItem(label: 'Mês'),
  ],
);

// Bottom nav with badge.
Scaffold(
  bottomNavigationBar: LumenBottomNavBar(
    selectedIndex: tab,
    onChanged: (v) => setState(() => tab = v),
    items: const [
      LumenNavItem(icon: Icons.home_outlined, label: 'Home'),
      LumenNavItem(icon: Icons.bolt_outlined, label: 'Events', badge: '3'),
      LumenNavItem(icon: Icons.person_outline, label: 'Account'),
    ],
  ),
);

// Themed modal bottom sheet.
showLumenBottomSheet<void>(
  context: context,
  builder: (_) => const Padding(
    padding: EdgeInsets.all(20),
    child: Text('Quick actions'),
  ),
);
```

## Styled dialog

```dart
await showLumenDialog<void>(
  context: context,
  title: 'Confirm action',
  icon: Icons.warning_amber_rounded,
  content: const Text('This operation cannot be undone.'),
  actions: <Widget>[
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
    LumenCta(label: 'CONFIRM', onPressed: () => Navigator.pop(context)),
  ],
);
```

## Example app

The [example gallery](https://github.com/saulogatti/lumen-kit/blob/main/example/README.md)
lets you toggle Lumen colors and component styles independently. Choose
**Material padrão** to compare with equivalent Material widgets using their
default colors and shapes.

```bash
cd example
flutter pub get
flutter run -d windows
```
