# lumen_kit

Flutter widget kit with the same designs and free color. The neon look (glow, gradient, grid and orbs) is the default style; flat, glass, soft and brutal use any palette. Designed to be reused between projects without rewriting tokens and styles for each new app.

## What's inside

| Category | Components |
| ------------- | -------------------------------------------------------------------- |
| Theme | `AppColors`, `LumenPalette`, `LumenPreset`, `LumenStyle`, `LumenThemeExt`, `AppTheme` |
| Background | `LumenAnimatedGridBackground`, `LumenGlowOrbSpec` |
| Structure | `LumenAppBar`, `LumenCard` |
| Action | `LumenCta`, `LumenButton`, `LumenIconButton`, `LumenFab`, `LumenMenuButton`, `LumenContextMenu` |
| Input | `LumenTextField`, `LumenSwitch`, `LumenCheckbox`, `LumenRadio`, `LumenSlider`, `LumenRangeSlider`, `LumenDropdown`, `LumenSearchBar`, `LumenDatePicker`, `LumenTimePicker`, `LumenChip` (+ `LumenChoiceChips`, `LumenFilterChips`), `LumenQuantityStepper`, `LumenRating`, `LumenPinField` |
| Feedback | `LumenStatusChip`, `LumenBanner`, `LumenDialog`, `LumenSnackBar`, `LumenToast`, `LumenLinearProgress`, `LumenCircularProgress`, `LumenSkeleton`, `LumenTooltip`, `LumenLoadingOverlay` (+ `showLumenLoading`) |
| Navigation | `LumenNavigationCard`, `LumenTabs`, `LumenSegmentedControl`, `LumenBottomNavBar`, `LumenNavRail`, `LumenBottomSheet`, `LumenDrawer`, `LumenStepper`, `LumenPageIndicator`, `LumenCarousel` |
| Display | `LumenBadge`, `LumenTag`, `LumenAvatar`, `LumenAvatarGroup`, `LumenListTile`, `LumenList`, `LumenEmptyState`, `LumenDivider`, `LumenExpansionTile`, `LumenDataTable`, `LumenTableRow` |

Everything decoupled from domain — receives `child`, callbacks and tokens; does not know any business rules.

## Installation

```yaml
dependencies:
  lumen_kit: any

```

## Only the components (without the theme)

If your app already has `ThemeData` itself, just import the widgets:

```dart
import 'package:lumen_kit/components.dart';
```

This import does not contain `AppTheme` or `AppColors` (no name conflict) and
does not require registering anything in the theme: widgets use the default palette, clear or
dark depending on the brightness of your subject. For other colors or other style in
a part of the screen, without touching `ThemeData`, use `LumenScope`:

```dart
LumenScope(
  palette: LumenPalette.fromSeed(primary: Colors.teal),
  style: LumenStyle.flat,
  child: LumenButton(label: 'Save', onPressed: salvar),
)
```

Typography comes from your app's `textTheme`. The complete import
(`package:lumen_kit/lumen_kit.dart`) remains the same, with everything.

## Minimum usage

```dart
import 'package:lumen_kit/lumen_kit.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        appBar: const LumenAppBar(title: 'Dashboard', subtitle: 'in real time'),
        body: LumenAnimatedGridBackground(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LumenCard(
              glow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Online service'),
                  const SizedBox(height: 12),
                  const LumenStatusChip(label: 'OK', tone: LumenStatusTone.success),
                  const SizedBox(height: 20),
                  LumenCta(
                    label: 'EXECUTE ',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Changing colors

All widgets read the theme palette, so changing the theme changes the entire kit.
From the simplest to the most detailed:

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

Theme changes at runtime are animated (`LumenThemeExt.lerp` interpolates the
palette). The `example/` app has a preset selector and light/dark mode.

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
| `flat` | No glow or gradient, neutral shadow, plain background |
| `glass` | Translucent surfaces with blur, soft glow |
| `soft` | Very round corners, diffuse shadows, no border, dotted background |
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

Widget animations (hover, transitions, toasts) remain the same in all
the styles.

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

Loop animations (skeleton, indeterminate progress) and transitions stop or
become instantaneous when the system asks to reduce animations.

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

`LumenList` uses `ListView.builder`: only what is on the screen is built. With
`itemCount: 0` it shows `empty`.

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

`LumenPinField` is controlled (`value` + `onChanged`). `onChanged == null`
disables. `onCompleted` fires when the last square fills.

```dart
LumenPinField(
  value: _codigo,
  onChanged: (String v) => setState(() => _codigo = v),
  onCompleted: enviar,
)
```

`LumenBanner` stays on the screen until `onDismiss`. Without this callback there is no button
to close.

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

- `solid` — full neon gradient (same identity as `LumenCta`).
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

There is a demo app in [`example/`](example/) with a single screen that exercises all the components of the kit — cards, status, buttons, icon buttons, FAB, inputs (text, search, switch, checkbox, radio, slider, range slider, dropdown, date and time picker), choice and filter chips, quantity stepper, rating, action and context menu, loading overlay, carousel, linear/circular progress, skeleton, snackbar, toast, dialog, bottom sheet, tabs, segmented, bottom nav, drawer, stepper, avatar, avatar group, badge, tag, list tile, divider, expansion tile, data table and navigation cards.

```bash
cd example
flutter pub get
flutter run
```

## Status

In active development — API may still change between `0.x` versions. Use `ref: <commit-sha>` or tags (`ref: v1.0.0`) in production to avoid silent breaks coming from `main`.
