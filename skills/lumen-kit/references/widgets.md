# Material → lumen_kit

Abridged signatures (main parameters only; an optional `accentColor`/`accent`
exists on almost every widget and defaults to `palette.primary`). When in
doubt, read the constructor in the package's `lib/src/widgets/`
(`.dart_tool/package_config.json` points to where pub checked out the git
dependency).

## Structure

| Material | Lumen | Notes |
| --- | --- | --- |
| `AppBar(title: Text(t))` | `LumenAppBar(title: t, subtitle:, leading:, actions:)` | `title` is a `String`. Implements `PreferredSizeWidget`, goes straight into `Scaffold.appBar`. |
| `Card(child:)` | `LumenCard(child:, onTap:, glow: false, padding:)` | Default padding is 20; pass `EdgeInsets.zero` if the child already has its own. |
| `Scaffold` background | `LumenAnimatedGridBackground(child: body)` | Grid/dots/plain depending on `LumenStyle`. |
| `Divider()` / `VerticalDivider()` | `LumenDivider()` / `LumenDivider(vertical: true)` | `label:` draws text in the middle. |

## Actions

| Material | Lumen | Notes |
| --- | --- | --- |
| `ElevatedButton`/`FilledButton` | `LumenButton(label:, onPressed:, icon:, busy:, expand:)` | `label` is a `String`. |
| `OutlinedButton` | `LumenButton.outline(...)` | |
| `TextButton` | `LumenButton.ghost(...)` | |
| main call to action of a screen | `LumenCta(label:, onPressed:, icon:, busy:)` | Full gradient; one per screen. |
| `IconButton` | `LumenIconButton(icon:, onPressed:, tooltip:)` | Variants `.solid`, `.ghost`; `shape: LumenIconButtonShape.rounded`. |
| `FloatingActionButton` / `.extended` | `LumenFab(icon:, onPressed:)` / `LumenFab.extended(icon:, label:, onPressed:)` | Several FABs in the tree → distinct `heroTag`s. |
| `PopupMenuButton` | `LumenMenuButton<T>(items:, onSelected:)` | Items: `LumenMenuItem(value:, label:, icon:, destructive:)`, `LumenMenuDivider()`. |
| `showMenu` | `showLumenMenu<T>(context:, items:, position:)` | |
| right-click menu | `LumenContextMenu<T>(items:, onSelected:, child:)` | Right click on desktop/web, long press on mobile. |

## Inputs

| Material | Lumen | Notes |
| --- | --- | --- |
| `TextField` / `TextFormField` | `LumenTextField(label:, controller:, onChanged:, validator:, errorText:, hint:, icon:, obscure:, keyboardType:, ...)` | `label` is required. Accepts `validator` (works inside a `Form`). `icon` is `IconData`, `suffix` is a `Widget`. |
| `SearchBar` / search field | `LumenSearchBar(onChanged:, hint:, onSubmitted:)` | Built-in clear button. |
| `Switch` / `SwitchListTile` | `LumenSwitch(value:, onChanged:, label:)` | `label` becomes the tappable label (replaces the `ListTile`). |
| `Checkbox` / `CheckboxListTile` | `LumenCheckbox(value:, onChanged:, label:, tristate:)` | |
| `Radio` / `RadioListTile` | `LumenRadio<T>(value:, groupValue:, onChanged:, label:)` | In `RadioGroup`: each radio gets `groupValue`. |
| `Slider` | `LumenSlider(value:, onChanged:, min:, max:, divisions:, label:)` | |
| `RangeSlider` | `LumenRangeSlider(values:, onChanged:, min:, max:, divisions:, labels:, onChangeEnd:)` | |
| `DropdownButton(FormField)` | `LumenDropdown<T>(value:, items:, onChanged:, label:, validator:)` | Items: `LumenDropdownItem(value:, label:, icon:)` instead of `DropdownMenuItem`. |
| `showDatePicker` | `showLumenDatePicker(context:, initialDate:, firstDate:, lastDate:)` | |
| date field | `LumenDatePicker(value:, firstDate:, lastDate:, onChanged:, label:)` | Read-only field that opens the picker. |
| `showTimePicker` | `showLumenTimePicker(context:, initialTime:)` | |
| time field | `LumenTimePicker(value:, onChanged:, label:, use24HourFormat:)` | |
| `FilterChip` / `ChoiceChip` | `LumenChip(label:, selected:, onSelected:)` | Ready-made groups: `LumenChoiceChips<T>(items:, value:, onChanged:)` (single) and `LumenFilterChips<T>(items:, values:, onChanged:)` (`Set<T>`, returns a new Set). Items: `LumenChipItem(value:, label:)`. |
| quantity `+`/`−` | `LumenQuantityStepper(value:, onChanged:, min:, max:, step:)` | `int`. |
| stars | `LumenRating(value:, onChanged:, allowHalf:)` | `onChanged: null` = read-only, accepts fractions. |
| OTP/pin | `LumenPinField(value:, onChanged:, length:, onCompleted:, obscure:)` | One field, digits only. `onChanged: null` disables. Paste fills the cells. |

## Feedback

| Material | Lumen | Notes |
| --- | --- | --- |
| `showDialog` + `AlertDialog` | `showLumenDialog<T>(context:, title:, content:, actions:, icon:)` | `title` is a `String`, `content` is a `Widget`. Widget: `LumenDialog`. |
| `ScaffoldMessenger.showSnackBar` | `showLumenSnackBar(context:, message:, tone:, action:)` | `tone`: `LumenStatusTone.neutral/info/success/warning/danger`. Use the `ScaffoldMessenger`. |
| toast without a scaffold | `showLumenToast(context:, message:, tone:, position:)` | Overlay; the `Future` completes when it's gone. |
| `LinearProgressIndicator` | `LumenLinearProgress(value:)` | `value: null` = indeterminate. |
| `CircularProgressIndicator` | `LumenCircularProgress(value:, size:)` | |
| blocking the screen during submit | `showLumenLoading<T>(context:, task: () => ..., message:)` | Returns `task`'s result; closes by itself, including on error. Per area: `LumenLoadingOverlay(loading:, child:)`. |
| shimmer/placeholder | `LumenSkeleton(width:, height:)`, `LumenSkeleton.circle(size:)` | |
| `Tooltip` | `LumenTooltip(message:, child:)` | |
| chip status | `LumenStatusChip(label:, tone:)` | |
| inline alert that stays | `LumenBanner(message:, tone:, actionLabel:, onAction:, onDismiss:)` | Not a toast. No `onDismiss` means no close button. |
| `Badge` | `LumenBadge(label:, child:)`, `LumenBadge.dot(child:)` | Small tag: `LumenTag(label:)`. |

## Navigation

| Material | Lumen | Notes |
| --- | --- | --- |
| `TabBar` + `TabController` | `LumenTabs(items:, selectedIndex:, onChanged:)` | Driven by index, in `TabController`; you switch the content (e.g. `IndexedStack` or a `PageView` on the same index). Items: `LumenTabItem(label:, icon:)`. |
| `SegmentedButton` | `LumenSegmentedControl(items:, selectedIndex:, onChanged:)` | Single selection. |
| `BottomNavigationBar` / `NavigationBar` | `LumenBottomNavBar(items:, selectedIndex:, onChanged:)` | Items: `LumenNavItem(icon:, label:, badge:)`. 3 to 5 items. |
| `NavigationRail` | `LumenNavRail(items:, selectedIndex:, onChanged:, leading:, trailing:)` | Same `LumenNavItem`s. |
| `Drawer` + `ListTile`s | `LumenDrawer(children:, header:, footer:)` + `LumenDrawerItem(icon:, label:, onTap:, selected:)` | |
| `showModalBottomSheet` | `showLumenBottomSheet<T>(context:, builder:)` | `isScrollControlled` defaults to `true`. |
| `Stepper` | `LumenStepper(steps:, currentStep:, onStepTapped:, direction:)` | Steps: `LumenStep(title:, subtitle:, content:)`. No continue/cancel buttons: add your own. `content` only shows in vertical mode. |
| `PageView` with indicator | `LumenCarousel(itemCount:, itemBuilder:, height:)` | Dots only: `LumenPageIndicator(count:, controller:)`. |
| menu/module card | `LumenNavigationCard(title:, subtitle:, icon:, accent:, onTap:)` | `accent` is required. |

## Display

| Material | Lumen | Notes |
| --- | --- | --- |
| `ListTile` | `LumenListTile(title:, subtitle:, leading:, trailing:, onTap:, selected:)` | `title`/`subtitle` are `String`s. |
| long `ListView.builder` | `LumenList(itemCount:, itemBuilder:, separatorBuilder:, empty:)` | Only visible rows are built. `itemCount: 0` shows `empty`. Give it a bounded height. |
| empty placeholder | `LumenEmptyState(title:, message:, icon:, actionLabel:, onPressed:)` | No `onPressed` means no button. |
| `ExpansionTile` | `LumenExpansionTile(title:, children:, subtitle:, leading:)` | `title` is a `String`. |
| `CircleAvatar` | `LumenAvatar(image:, initials:, radius:, statusColor:)` | `image` is a `ImageProvider`. Stack: `LumenAvatarGroup(avatars:, maxVisible:, total:)`. |
| `DataTable` | `LumenDataTable(columns:, rows:)` | Takes regular `DataColumn`/`DataRow`. Standalone row: `LumenTableRow(cells:, isHeader:)`. |

## No equivalent (keep Material)

`Autocomplete`, `PaginatedDataTable`, `SearchAnchor` with suggestions,
`ReorderableListView`, `MenuAnchor`/`MenuBar` with submenus,
`showAboutDialog`, `CupertinoX`. To make them match visually, use
`LumenDecorations.input(...)` for the `InputDecoration` or
`LumenDecorations.panel(...)` on a surrounding `Container`.
