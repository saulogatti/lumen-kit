# Material → neon_ui

Assinaturas resumidas (parâmetros principais; `accentColor`/`accent`
opcional existe em quase todos e default é `palette.primary`). Na dúvida,
leia o construtor em `lib/src/widgets/` do pacote (`.dart_tool/package_config.json`
aponta onde o pub baixou o git).

## Estrutura

| Material | Neon | Notas |
|---|---|---|
| `AppBar(title: Text(t))` | `NeonAppBar(title: t, subtitle:, leading:, actions:)` | `title` é `String`. Implementa `PreferredSizeWidget`, vai direto em `Scaffold.appBar`. |
| `Card(child:)` | `NeonCard(child:, onTap:, glow: false, padding:)` | Padding default 20; passe `EdgeInsets.zero` se o filho já tem. |
| fundo do `Scaffold` | `AnimatedGridBackground(child: body)` | Grid/pontos/liso conforme `NeonStyle`. |
| `Divider()` / `VerticalDivider()` | `NeonDivider()` / `NeonDivider(vertical: true)` | `label:` desenha texto no meio. |

## Ações

| Material | Neon | Notas |
|---|---|---|
| `ElevatedButton`/`FilledButton` | `NeonButton(label:, onPressed:, icon:, busy:, expand:)` | `label` é `String`. |
| `OutlinedButton` | `NeonButton.outline(...)` | |
| `TextButton` | `NeonButton.ghost(...)` | |
| CTA principal da tela | `GradientCta(label:, onPressed:, icon:, busy:)` | Gradiente cheio; um por tela. |
| `IconButton` | `NeonIconButton(icon:, onPressed:, tooltip:)` | Variantes `.solid`, `.ghost`; `shape: NeonIconButtonShape.rounded`. |
| `FloatingActionButton` / `.extended` | `NeonFab(icon:, onPressed:)` / `NeonFab.extended(icon:, label:, onPressed:)` | Vários FABs na árvore → `heroTag` distinto. |
| `PopupMenuButton` | `NeonMenuButton<T>(items:, onSelected:)` | Itens: `NeonMenuItem(value:, label:, icon:, destructive:)`, `NeonMenuDivider()`. |
| `showMenu` | `showNeonMenu<T>(context:, items:, position:)` | |
| menu de clique direito | `NeonContextMenu<T>(items:, onSelected:, child:)` | Clique direito no desktop/web, toque longo no mobile. |

## Inputs

| Material | Neon | Notas |
|---|---|---|
| `TextField` / `TextFormField` | `NeonTextField(label:, controller:, onChanged:, validator:, errorText:, hint:, icon:, obscure:, keyboardType:, ...)` | `label` obrigatório. Aceita `validator` (funciona dentro de `Form`). `icon` é `IconData`, `suffix` é `Widget`. |
| `SearchBar` / campo de busca | `NeonSearchBar(onChanged:, hint:, onSubmitted:)` | Tem botão de limpar embutido. |
| `Switch` / `SwitchListTile` | `NeonSwitch(value:, onChanged:, label:)` | `label` vira o rótulo clicável (substitui o `ListTile`). |
| `Checkbox` / `CheckboxListTile` | `NeonCheckbox(value:, onChanged:, label:, tristate:)` | |
| `Radio` / `RadioListTile` | `NeonRadio<T>(value:, groupValue:, onChanged:, label:)` | Sem `RadioGroup`: cada radio recebe `groupValue`. |
| `Slider` | `NeonSlider(value:, onChanged:, min:, max:, divisions:, label:)` | |
| `RangeSlider` | `NeonRangeSlider(values:, onChanged:, min:, max:, divisions:, labels:, onChangeEnd:)` | |
| `DropdownButton(FormField)` | `NeonDropdown<T>(value:, items:, onChanged:, label:, validator:)` | Itens: `NeonDropdownItem(value:, label:, icon:)` em vez de `DropdownMenuItem`. |
| `showDatePicker` | `showNeonDatePicker(context:, initialDate:, firstDate:, lastDate:)` | |
| campo de data | `NeonDatePicker(value:, firstDate:, lastDate:, onChanged:, label:)` | Campo somente-leitura que abre o picker. |
| `showTimePicker` | `showNeonTimePicker(context:, initialTime:)` | |
| campo de hora | `NeonTimePicker(value:, onChanged:, label:, use24HourFormat:)` | |
| `FilterChip` / `ChoiceChip` | `NeonChip(label:, selected:, onSelected:)` | Grupo pronto: `NeonChoiceChips<T>(items:, value:, onChanged:)` (um) e `NeonFilterChips<T>(items:, values:, onChanged:)` (`Set<T>`, devolve um Set novo). Itens: `NeonChipItem(value:, label:)`. |
| `+`/`−` de quantidade | `NeonQuantityStepper(value:, onChanged:, min:, max:, step:)` | `int`. |
| estrelas | `NeonRating(value:, onChanged:, allowHalf:)` | `onChanged: null` = somente leitura, aceita fração. |

## Feedback

| Material | Neon | Notas |
|---|---|---|
| `showDialog` + `AlertDialog` | `showNeonDialog<T>(context:, title:, content:, actions:, icon:)` | `title` é `String`, `content` é `Widget`. Widget: `NeonDialog`. |
| `ScaffoldMessenger.showSnackBar` | `showNeonSnackBar(context:, message:, tone:, action:)` | `tone`: `StatusTone.neutral/info/success/warning/danger`. Usa o `ScaffoldMessenger`. |
| toast sem Scaffold | `showNeonToast(context:, message:, tone:, position:)` | Overlay; `Future` completa quando some. |
| `LinearProgressIndicator` | `NeonLinearProgress(value:)` | `value: null` = indeterminado. |
| `CircularProgressIndicator` | `NeonCircularProgress(value:, size:)` | |
| bloqueio de tela durante submit | `showNeonLoading<T>(context:, task: () => ..., message:)` | Devolve o resultado de `task`; fecha sozinho, inclusive em erro. Por área: `NeonLoadingOverlay(loading:, child:)`. |
| shimmer/placeholder | `NeonSkeleton(width:, height:)`, `NeonSkeleton.circle(size:)` | |
| `Tooltip` | `NeonTooltip(message:, child:)` | |
| chip de status | `StatusChip(label:, tone:)` | |
| `Badge` | `NeonBadge(label:, child:)`, `NeonBadge.dot(child:)` | Etiqueta pequena: `NeonTag(label:)`. |

## Navegação

| Material | Neon | Notas |
|---|---|---|
| `TabBar` + `TabController` | `NeonTabs(items:, selectedIndex:, onChanged:)` | Controlado por índice, sem `TabController`; o conteúdo você troca (ex.: `IndexedStack` ou `PageView` com o mesmo índice). Itens: `NeonTabItem(label:, icon:)`. |
| `SegmentedButton` | `NeonSegmentedControl(items:, selectedIndex:, onChanged:)` | Seleção única. |
| `BottomNavigationBar` / `NavigationBar` | `NeonBottomNavBar(items:, selectedIndex:, onChanged:)` | Itens: `NeonNavItem(icon:, label:, badge:)`. 3 a 5 itens. |
| `NavigationRail` | `NeonNavRail(items:, selectedIndex:, onChanged:, leading:, trailing:)` | Mesmos `NeonNavItem`. |
| `Drawer` + `ListTile`s | `NeonDrawer(children:, header:, footer:)` + `NeonDrawerItem(icon:, label:, onTap:, selected:)` | |
| `showModalBottomSheet` | `showNeonBottomSheet<T>(context:, builder:)` | `isScrollControlled` default `true`. |
| `Stepper` | `NeonStepper(steps:, currentStep:, onStepTapped:, direction:)` | Steps: `NeonStep(title:, subtitle:, content:)`. Sem botões continuar/cancelar: coloque os seus. `content` só aparece no vertical. |
| `PageView` com indicador | `NeonCarousel(itemCount:, itemBuilder:, height:)` | Só os pontos: `NeonPageIndicator(count:, controller:)`. |
| card de menu/módulo | `NavigationCard(title:, subtitle:, icon:, accent:, onTap:)` | `accent` obrigatório. |

## Display

| Material | Neon | Notas |
|---|---|---|
| `ListTile` | `NeonListTile(title:, subtitle:, leading:, trailing:, onTap:, selected:)` | `title`/`subtitle` são `String`. |
| `ExpansionTile` | `NeonExpansionTile(title:, children:, subtitle:, leading:)` | `title` é `String`. |
| `CircleAvatar` | `NeonAvatar(image:, initials:, radius:, statusColor:)` | `image` é `ImageProvider`. Pilha: `NeonAvatarGroup(avatars:, maxVisible:, total:)`. |
| `DataTable` | `NeonDataTable(columns:, rows:)` | Recebe `DataColumn`/`DataRow` normais. Linha avulsa: `NeonTableRow(cells:, isHeader:)`. |

## Sem equivalente (deixe Material)

`Autocomplete`, `PaginatedDataTable`, `SearchAnchor` com sugestões,
`ReorderableListView`, `MenuAnchor`/`MenuBar` com submenus, `Banner`,
`showAboutDialog`, `CupertinoX`. Para combinar visualmente, use
`NeonDecorations.input(...)` no `InputDecoration` ou
`NeonDecorations.panel(...)` num `Container` em volta.
