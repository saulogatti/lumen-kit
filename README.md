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
| Input | `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenRangeSlider`, `LumenDropdown`, `LumenSearchBar`, `LumenDatePicker`, `LumenTimePicker`, `showLumenColorPicker`, `LumenColorField`, `LumenFileUpload`, `LumenChip` (+ `LumenChoiceChips`, `LumenFilterChips`), `LumenQuantityStepper`, `LumenNumberField`, `LumenRating`, `LumenPinField` |
| Motion | `LumenEntrance`, `LumenAnimatedSwitcher` |
| Feedback | `LumenStatusChip`, `LumenBanner`, `LumenDialog`, `showLumenSnackBar`, `showLumenToast`, `LumenLinearProgress`, `LumenCircularProgress`, `LumenSkeleton`, `LumenTooltip`, `LumenLoadingPanel`, `LumenLoadingOverlay` (+ `showLumenLoading`) |
| Navigation | `LumenNavigationCard`, `LumenTabs`, `LumenSegmentedControl`, `LumenBottomNavBar`, `LumenNavRail`, `showLumenBottomSheet`, `LumenDrawer`, `LumenStepper`, `LumenPageIndicator`, `LumenCarousel` |
| Display | `LumenBadge`, `LumenTag`, `LumenAvatar`, `LumenAvatarGroup`, `LumenListTile`, `LumenList`, `LumenEmptyState`, `LumenDivider`, `LumenExpansionTile`, `LumenDataTable`, `LumenTableRow`, `LumenTimeline` |

The widgets take data, callbacks, and theme tokens so the app owns its business rules.

## File uploads

`LumenFileUpload` displays the name, status label, and progress of each file.
The app owns file selection, drop handling, and uploads. `LumenUploadItem` is
immutable: when a file's progress or status changes, rebuild the widget with
a new list, replacing that item with `copyWith`.

```dart
LumenFileUpload(
  items: <LumenUploadItem>[
    const LumenUploadItem(
      name: 'invoice.pdf',
      status: LumenUploadStatus.uploading,
      statusLabel: 'Uploading',
      progress: 0.65,
    ),
  ],
)

// On the next progress report:
setState(() => _invoice = _invoice.copyWith(progress: 0.8));
```

Progress is a fraction from `0.0` to `1.0`. The constructor rejects values
outside that range, including `NaN`, when assertions are enabled; without
them, the row clamps the value it displays.
`status` colors the label: pending uses muted text, uploading uses primary,
completed uses success, and failed uses danger. Supply a localized
`statusLabel` for each file. The gallery shows pending, uploading, completed,
and failed files, and its Upload button simulates one upload.

## Transitions

`LumenEntrance` reveals content once; give it a new key to replay.
`LumenAnimatedSwitcher` animates between children with different types or keys.
Both accept `duration`, `curve`, and a fractional slide `offset` (use
`Offset.zero` for fade only), and show content immediately with reduced motion.
They preserve the child's palette and visual style.

```dart
LumenAnimatedSwitcher(
  duration: const Duration(milliseconds: 350),
  curve: Curves.easeInOut,
  child: Text(status, key: ValueKey(status)),
)
```

## Requirements

- Dart `^3.14.0` and Flutter `>=3.50.0`.
- Use `package:material_ui/material_ui.dart` for the Material app and its
  widgets. `flutter/material.dart` and `material_ui` have distinct
  `ThemeData` and `Material` types. See the
  [integration guide](skills/lumen-kit/SKILL.md#3-material-the-app-must-use-material_ui)
  when adding Lumen to an existing Flutter app.

## Installation

### Published package

Use the [pub.dev release](https://pub.dev/packages/lumen_kit) for the published
version. This example uses the `1.4.0` release constraints.

```yaml
dependencies:
  lumen_kit: ^1.4.0
  material_ui: ^1.11.1
```

### Git checkout

To try unreleased code from `main`, pin a commit on the repository instead.

```yaml
dependencies:
  lumen_kit:
    git:
      url: https://github.com/saulogatti/lumen-kit.git
      ref: <commit-sha>
  material_ui: ^1.11.1
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

### Semantic colors

`success` and `warning` use the `AppColors` defaults. `danger` uses
`AppColors.danger` in dark palettes and the darker `AppColors.dangerLight` in
light ones, which keeps AA contrast (4.5:1) on light surfaces. Pass your own
colors to `AppTheme.fromSeed` or `LumenPalette.fromSeed`, for example the
Material error color, which already follows brightness:

```dart
MaterialApp(
  theme: AppTheme.fromSeed(
    primary: Colors.red,
    brightness: Brightness.light,
    danger: scheme.error,
  ),
  home: ...,
);
```

A custom `danger` whose hue is within 30 degrees of `primary` and whose
saturation is below 50% becomes 20% more saturated, so it does not read as an
off-tone primary. Other colors are kept as given. Any palette also accepts
semantic colors through `copyWith`.

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
    child: LumenActionContent(color: p.textPrimary, icon: Icons.save, label: 'Save', busy: saving),
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
viewport for large data sets. Scroll options such as `shrinkWrap`, `physics`,
`scrollDirection`, and `reverse` work as in `ListView`.

```dart
LumenList(
  itemCount: events.length,
  empty: const LumenEmptyState(
    icon: Icons.inbox_outlined,
    title: 'No events',
  ),
  itemBuilder: (context, i) => LumenListTile(
    title: events[i].title,
    onTap: () => open(events[i]),
  ),
)
```

`LumenPinField` is controlled by `value` and `onChanged`. Set
`onChanged` to `null` to disable input. `onCompleted` fires when typing
or pasting takes the code from incomplete to complete. Assigning a complete
`value` programmatically only updates the displayed code.

```dart
LumenPinField(
  value: _code,
  onChanged: (String v) => setState(() => _code = v),
  onCompleted: submit,
)
```

`LumenNumberField` is a typed numeric field controlled by `value` (`double?`,
`null` when empty) and `onChanged`. `decimals` sets the fraction digits,
`min` and `max` apply when focus leaves or the field is submitted, and
`decimalSeparator` and `groupSeparator` adapt it to the app's locale.

```dart
LumenNumberField(
  label: 'Price',
  value: _price,
  decimals: 2,
  min: 0,
  decimalSeparator: ',',
  groupSeparator: '.',
  padDecimals: true,
  prefixText: r'R$ ',
  onChanged: (double? v) => setState(() => _price = v),
)
```

`LumenBanner` stays visible until its parent removes it. To add a close
button, pass an `onDismiss` callback that updates the parent's state.

## Timeline

`LumenTimeline` shows order or activity history as events joined by a line.
Pass the events already sorted and `timestamp` already formatted: the kit
doesn't sort or format dates. `highlightedIndex` marks the current event, and
`tone` (or `accentColor`) colors each marker from the palette. The default
constructor is a `Column` that fits inside cards and dialogs;
`LumenTimeline.builder` scrolls and builds events on demand.

```dart
LumenTimeline(
  highlightedIndex: 0,
  entries: <LumenTimelineEntry>[
    for (final change in history)
      LumenTimelineEntry(
        title: change.label,
        subtitle: change.authorName,
        description: change.notes,
        timestamp: formatDate(change.changedAt),
        tone: change.isCanceled ? LumenStatusTone.danger : LumenStatusTone.success,
        onTap: () => open(change),
      ),
  ],
)
```

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

Pass a `LumenStatusTone` as `tone` to give any variant a semantic color from
the palette. A solid button with a tone fills with that color instead of the
accent gradient, and `LumenButton.danger` is the shortcut for destructive
actions:

```dart
showLumenDialog<void>(
  context: context,
  title: 'Delete category?',
  accent: LumenThemeExt.of(context).palette.danger,
  content: const Text('This cannot be undone.'),
  actions: <Widget>[
    LumenButton.ghost(label: 'Cancel', onPressed: () => Navigator.pop(context)),
    LumenButton.danger(label: 'Delete', icon: Icons.delete_outline, onPressed: onDelete),
  ],
);
```

`accentColor` still overrides the shadow of a solid button and the color of
outline and ghost buttons, but never the solid fill.

Labels stay on one line. In a narrow space, the label is truncated with an
ellipsis instead of overflowing.

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

// Opens the kit's month grid, with a year list and a text field.
LumenDatePicker(
  label: 'Start',
  value: date,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onChanged: (d) => setState(() => date = d),
);

// Hour and minute columns, AM/PM in 12-hour format, and a text input mode.
LumenTimePicker(
  label: 'Time',
  value: time,
  onChanged: (t) => setState(() => time = t),
);

// Saturation/brightness area, hue track, hex field, and swatches.
// The default swatches are the palette accents; pass [] to hide them.
final Color? picked = await showLumenColorPicker(
  context: context,
  initialColor: color,
  swatches: const <Color>[Color(0xFF00E5FF), Color(0xFFFF4081), Color(0xFFFFD740)],
);
if (picked != null) {
  setState(() => color = picked);
}

// Read-only field that opens the picker. showAlpha adds an opacity track,
// and translucent colors show as #AARRGGBB over a checkerboard.
LumenColorField(
  label: 'Accent',
  value: color,
  showAlpha: true,
  onChanged: (c) => setState(() => color = c),
);

LumenRangeSlider(
  values: price,
  max: 500,
  divisions: 50,
  onChanged: (v) => setState(() => price = v),
  onChangeEnd: (v) => search(v), // search only when released
);
```

## Chips, quantity and evaluation

```dart
// Single selection.
LumenChoiceChips<String>(
  value: size,
  onChanged: (v) => setState(() => size = v),
  items: const [
    LumenChipItem(value: 's', label: 'S'),
    LumenChipItem(value: 'm', label: 'M'),
  ],
);

// Filters (multiple selections). Accepts and returns a new Set.
LumenFilterChips<String>(
  values: filters,
  onChanged: (v) => setState(() => filters = v),
  items: const [
    LumenChipItem(value: 'promo', label: 'Promotion'),
    LumenChipItem(value: 'shipping', label: 'Free shipping'),
  ],
);

LumenQuantityStepper(value: quantity, min: 1, max: 10, onChanged: (v) => setState(() => quantity = v));

LumenRating(value: rating, allowHalf: true, onChanged: (v) => setState(() => rating = v));
LumenRating(value: 4.3, size: 16); // read-only, with fraction
```

## Menu, loading and carousel

```dart
// The card / app bar overflow menu.
LumenMenuButton<String>(
  items: const [
    LumenMenuItem(value: 'edit', label: 'Edit', icon: Icons.edit),
    LumenMenuDivider(),
    LumenMenuItem(value: 'del', label: 'Delete', destructive: true),
  ],
  onSelected: (v) => …,
);

// Right-click (desktop/web) or long press (mobile).
LumenContextMenu<String>(items: items, onSelected: …, child: row);

// Locks the screen during submit and returns the result of the task.
final ok = await showLumenLoading(
  context: context,
  message: 'Submitting…',
  task: () => api.submit(form),
);

// Or just an area, controlled by state.
LumenLoadingOverlay(loading: saving, message: 'Saving…', child: form);

// Gallery / onboarding with page dots.
LumenCarousel(
  itemCount: photos.length,
  itemBuilder: (context, i) => Image.network(photos[i], fit: BoxFit.cover),
);
// Or just the dots, linked to your PageView.
LumenPageIndicator(count: 4, controller: pageController);

// Stacked avatars with "+N".
LumenAvatarGroup(
  avatars: [for (final u in members) LumenAvatar(initials: u.initials)],
  maxVisible: 3,
  total: totalMembers,
);
```

## Navigation

```dart
// Compact pill — great for switching views within a screen.
LumenSegmentedControl(
  selectedIndex: i,
  onChanged: (v) => setState(() => i = v),
  items: const [
    LumenTabItem(label: 'Day'),
    LumenTabItem(label: 'Week'),
    LumenTabItem(label: 'Month'),
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
**Default Material** to compare with equivalent Material widgets using their
default colors and shapes.

The gallery also demonstrates foundation building blocks, enabled and disabled
controls, loading and validation states, and horizontal and vertical steppers.

```bash
cd example
flutter pub get
flutter run -d windows
```
