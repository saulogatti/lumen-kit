# Material → neon_ui

Abridged signatures (main parameters only; an optional `accentColor`/`accent`
exists on almost every widget and defaults to `palette.primary`). When in
doubt, read the constructor in the package's `lib/src/widgets/`
(`.dart_tool/package_config.json` points to where pub checked out the git
dependency).

## Structure

| Material | Neon | Notes |
|---|---|---|
| `AppBar(title: Text(t))` | `NeonAppBar(title: t, subtitle:, leading:, actions:)` | `title` is a `String`. Implements `PreferredSizeWidget`, goes straight into `Scaffold.appBar`. |
| `Card(child:)` | `NeonCard(child:, onTap:, glow: false, padding:)` | Default padding is 20; pass `EdgeInsets.zero` if the child already has its own. |
| `Scaffold` background | `AnimatedGridBackground(child: body)` | Grid/dots/plain depending on `NeonStyle`. |
| `Divider()` / `VerticalDivider()` | `NeonDivider()` / `NeonDivider(vertical: true)` | `label:` draws text in the middle. |

## Actions

| Material | Neon | Notes |
|---|---|---|
| `ElevatedButton`/`FilledButton` | `NeonButton(label:, onPressed:, icon:, busy:, expand:)` | `label` is a `String`. |
| `OutlinedButton` | `NeonButton.outline(...)` | |
| `TextButton` | `NeonButton.ghost(...)` | |
| main call to action of a screen | `GradientCta(label:, onPressed:, icon:, busy:)` | Full gradient; one per screen. |
| `IconButton` | `NeonIconButton(icon:, onPressed:, tooltip:)` | Variants `.solid`, `.ghost`; `shape: NeonIconButtonShape.rounded`. |
| `FloatingActionButton` / `.extended` | `NeonFab(icon:, onPressed:)` / `NeonFab.extended(icon:, label:, onPressed:)` | Several FABs in the tree → distinct `heroTag`s. |
| `PopupMenuButton` | `NeonMenuButton<T>(items:, onSelected:)` | Items: `NeonMenuItem(value:, label:, icon:, destructive:)`, `NeonMenuDivider()`. |
| `showMenu` | `showNeonMenu<T>(context:, items:, position:)` | |
| right-click menu | `NeonContextMenu<T>(items:, onSelected:, child:)` | Right click on desktop/web, long press on mobile. |

## Inputs

| Material | Neon | Notes |
|---|---|---|
| `TextField` / `TextFormField` | `NeonTextField(label:, controller:, onChanged:, validator:, errorText:, hint:, icon:, obscure:, keyboardType:, ...)` | `label` is required. Accepts `validator` (works inside a `Form`). `icon` is `IconData`, `suffix` is a `Widget`. |
| `SearchBar` / search field | `NeonSearchBar(onChanged:, hint:, onSubmitted:)` | Built-in clear button. |
| `Switch` / `SwitchListTile` | `NeonSwitch(value:, onChanged:, label:)` | `label` becomes the tappable label (replaces the `ListTile`). |
| `Checkbox` / `CheckboxListTile` | `NeonCheckbox(value:, onChanged:, label:, tristate:)` | |
| `Radio` / `RadioListTile` | `NeonRadio<T>(value:, groupValue:, onChanged:, label:)` | No `RadioGroup`: each radio gets `groupValue`. |
| `Slider` | `NeonSlider(value:, onChanged:, min:, max:, divisions:, label:)` | |
| `RangeSlider` | `NeonRangeSlider(values:, onChanged:, min:, max:, divisions:, labels:, onChangeEnd:)` | |
| `DropdownButton(FormField)` | `NeonDropdown<T>(value:, items:, onChanged:, label:, validator:)` | Items: `NeonDropdownItem(value:, label:, icon:)` instead of `DropdownMenuItem`. |
| `showDatePicker` | `showNeonDatePicker(context:, initialDate:, firstDate:, lastDate:)` | |
| date field | `NeonDatePicker(value:, firstDate:, lastDate:, onChanged:, label:)` | Read-only field that opens the picker. |
| `showTimePicker` | `showNeonTimePicker(context:, initialTime:)` | |
| time field | `NeonTimePicker(value:, onChanged:, label:, use24HourFormat:)` | |
| `FilterChip` / `ChoiceChip` | `NeonChip(label:, selected:, onSelected:)` | Ready-made groups: `NeonChoiceChips<T>(items:, value:, onChanged:)` (single) and `NeonFilterChips<T>(items:, values:, onChanged:)` (`Set<T>`, returns a new Set). Items: `NeonChipItem(value:, label:)`. |
| quantity `+`/`−` | `NeonQuantityStepper(value:, onChanged:, min:, max:, step:)` | `int`. |
| stars | `NeonRating(value:, onChanged:, allowHalf:)` | `onChanged: null` = read-only, accepts fractions. |

## Feedback

| Material | Neon | Notes |
|---|---|---|
| `showDialog` + `AlertDialog` | `showNeonDialog<T>(context:, title:, content:, actions:, icon:)` | `title` is a `String`, `content` a `Widget`. Widget: `NeonDialog`. |
| `ScaffoldMessenger.showSnackBar` | `showNeonSnackBar(context:, message:, tone:, action:)` | `tone`: `StatusTone.neutral/info/success/warning/danger`. Uses the `ScaffoldMessenger`. |
| toast without a Scaffold | `showNeonToast(context:, message:, tone:, position:)` | Overlay; the `Future` completes when it's gone. |
| `LinearProgressIndicator` | `NeonLinearProgress(value:)` | `value: null` = indeterminate. |
| `CircularProgressIndicator` | `NeonCircularProgress(value:, size:)` | |
| blocking the screen during submit | `showNeonLoading<T>(context:, task: () => ..., message:)` | Returns `task`'s result; closes by itself, including on error. Per area: `NeonLoadingOverlay(loading:, child:)`. |
| shimmer/placeholder | `NeonSkeleton(width:, height:)`, `NeonSkeleton.circle(size:)` | |
| `Tooltip` | `NeonTooltip(message:, child:)` | |
| status chip | `StatusChip(label:, tone:)` | |
| `Badge` | `NeonBadge(label:, child:)`, `NeonBadge.dot(child:)` | Small tag: `NeonTag(label:)`. |

## Navigation

| Material | Neon | Notes |
|---|---|---|
| `TabBar` + `TabController` | `NeonTabs(items:, selectedIndex:, onChanged:)` | Driven by index, no `TabController`; you switch the content (e.g. `IndexedStack` or a `PageView` on the same index). Items: `NeonTabItem(label:, icon:)`. |
| `SegmentedButton` | `NeonSegmentedControl(items:, selectedIndex:, onChanged:)` | Single selection. |
| `BottomNavigationBar` / `NavigationBar` | `NeonBottomNavBar(items:, selectedIndex:, onChanged:)` | Items: `NeonNavItem(icon:, label:, badge:)`. 3 to 5 items. |
| `NavigationRail` | `NeonNavRail(items:, selectedIndex:, onChanged:, leading:, trailing:)` | Same `NeonNavItem`s. |
| `Drawer` + `ListTile`s | `NeonDrawer(children:, header:, footer:)` + `NeonDrawerItem(icon:, label:, onTap:, selected:)` | |
| `showModalBottomSheet` | `showNeonBottomSheet<T>(context:, builder:)` | `isScrollControlled` defaults to `true`. |
| `Stepper` | `NeonStepper(steps:, currentStep:, onStepTapped:, direction:)` | Steps: `NeonStep(title:, subtitle:, content:)`. No continue/cancel buttons: add your own. `content` only shows in vertical mode. |
| `PageView` with indicator | `NeonCarousel(itemCount:, itemBuilder:, height:)` | Dots only: `NeonPageIndicator(count:, controller:)`. |
| menu/module card | `NavigationCard(title:, subtitle:, icon:, accent:, onTap:)` | `accent` is required. |

## Display

| Material | Neon | Notes |
|---|---|---|
| `ListTile` | `NeonListTile(title:, subtitle:, leading:, trailing:, onTap:, selected:)` | `title`/`subtitle` are `String`s. |
| `ExpansionTile` | `NeonExpansionTile(title:, children:, subtitle:, leading:)` | `title` is a `String`. |
| `CircleAvatar` | `NeonAvatar(image:, initials:, radius:, statusColor:)` | `image` is an `ImageProvider`. Stack: `NeonAvatarGroup(avatars:, maxVisible:, total:)`. |
| `DataTable` | `NeonDataTable(columns:, rows:)` | Takes regular `DataColumn`/`DataRow`. Standalone row: `NeonTableRow(cells:, isHeader:)`. |

## No equivalent (keep Material)

`Autocomplete`, `PaginatedDataTable`, `SearchAnchor` with suggestions,
`ReorderableListView`, `MenuAnchor`/`MenuBar` with submenus, `Banner`,
`showAboutDialog`, `CupertinoX`. To make them match visually, use
`NeonDecorations.input(...)` for the `InputDecoration` or
`NeonDecorations.panel(...)` on a surrounding `Container`.
