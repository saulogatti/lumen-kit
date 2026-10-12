---
name: neon-ui
description: Aplica o kit neon_ui (saulogatti/flutter-neon-ui) em um app Flutter existente — instala via git, escolhe o import, configura tema/preset/NeonScope e troca widgets Material pelos equivalentes Neon.
---

# Aplicar o neon_ui em um app Flutter

Use quando o usuário pedir para usar o `neon_ui` / "componentes neon" /
"esse kit" em um app Flutter que não é o próprio repositório do kit. Para
alterar o kit em si, leia o `AGENTS.md` do repositório.

O mapeamento completo de widgets (Material → Neon, com assinaturas) está em
[`references/widgets.md`](references/widgets.md). Leia antes de trocar
qualquer widget; as APIs **não** são cópias das do Material.

## 1. Inspecione o app antes de mexer

Descubra, no `pubspec.yaml` e no código:

- Versões: o kit exige Dart `^3.13.0` e Flutter `>=3.47.0`. Se o app trava
  numa versão menor, pare e avise; não há como contornar.
- **Qual biblioteca Material o app importa.** `grep -rn
  "package:flutter/material.dart\|package:material_ui/material_ui.dart" lib`.
  Isso decide o passo 3 e é o erro mais caro de pular.
- Se já existe `ThemeData` próprio, `ThemeExtension`s, e classes chamadas
  `AppTheme` ou `AppColors` (colisão de nome com o kit).
- Se o app tem modo claro e escuro (`theme` + `darkTheme`/`themeMode`).

## 2. Instale

```yaml
dependencies:
  material_ui: ^1.6.0
  neon_ui:
    git:
      url: https://github.com/saulogatti/flutter-neon-ui.git
      ref: main   # para builds reproduzíveis, fixe um SHA de commit
```

`flutter pub get`. O pacote não está no pub.dev.

## 3. Material: o app precisa usar `material_ui`

O kit é construído sobre o pacote `material_ui`, não sobre
`package:flutter/material.dart`. São bibliotecas diferentes com tipos
diferentes. Num app que usa `flutter/material.dart`, verificado no Flutter
3.47:

- `MaterialApp(theme: AppTheme.dark)` **não compila** (`ThemeData` de um
  não é o `ThemeData` do outro).
- Os widgets neon não enxergam o `Theme` do app: caem na paleta default
  **clara**, mesmo com o app em `ThemeData.dark()`.
- `NeonTextField` (e tudo que usa `TextField`/`InkWell` do material_ui sem
  um `Material` do material_ui acima) quebra com "No Material widget found".

Portanto, o caminho padrão é migrar o app:

```bash
grep -rl "package:flutter/material.dart" lib test \
  | xargs sed -i "s#package:flutter/material.dart#package:material_ui/material_ui.dart#"
flutter analyze
```

`material_ui` reexporta `package:flutter/widgets.dart`, então imports
duplicados de `widgets.dart` podem virar aviso de import desnecessário;
limpe-os. Se o app depende de pacotes de terceiros que entregam widgets de
`flutter/material` (ex.: um date picker de outro pacote), eles continuam
funcionando, mas não herdam o tema; avise o usuário.

Se o usuário **recusar** a migração, pare e explique: não há modo suportado
de misturar. Envolver os widgets neon num `Material` do `material_ui` só
troca o erro por "No MaterialLocalizations found", e o tema do app continua
invisível para eles.

## 4. Escolha o import

| Situação | Import |
|---|---|
| App novo, ou o usuário quer o visual do kit no app inteiro | `package:neon_ui/neon_ui.dart` (inclui `AppTheme`, `AppColors`) |
| App já tem `ThemeData` próprio, ou tem classes `AppTheme`/`AppColors` | `package:neon_ui/components.dart` (só widgets, `NeonPalette`, `NeonStyle`, `NeonScope`, `NeonThemeExt`) |

Na dúvida, `components.dart`: nunca colide e não exige tema.

## 5. Configure o tema

Os widgets acham paleta e estilo nesta ordem: `NeonScope` mais próximo →
`NeonThemeExt` registrado no `ThemeData` → paleta default (escura ou clara
conforme o brilho do tema) com estilo `neon`. Escolha um caminho:

**A. Tema do kit no app inteiro** (import `neon_ui.dart`):

```dart
MaterialApp(
  theme: AppTheme.fromPreset(NeonPreset.neon, brightness: Brightness.light),
  darkTheme: AppTheme.fromPreset(NeonPreset.neon),
  themeMode: ThemeMode.system,
  home: ...,
);
```

- Presets (`NeonPreset`): `neon` (cyan/magenta, default), `matrix`,
  `synthwave`, `ultraviolet`, `ember`.
- Cor da marca do usuário: `AppTheme.fromSeed(primary: marca, secondary:
  opcional, brightness: ...)`. Fundos, textos e gradientes são derivados.
- Token a token: `AppTheme.fromPalette(NeonPalette.defaultDark().copyWith(primary: ...))`.
- Estilo além da cor, em qualquer um dos três: `style: NeonStyle.flat`
  (`neon`, `flat`, `glass`, `soft`, `brutal`, ou `NeonStyle.soft.copyWith(...)`).
  App corporativo/sóbrio → `flat` ou `soft`; o glow do `neon` é bem
  opinativo, confirme com o usuário antes de impor.

**B. Manter o `ThemeData` do app e só registrar o kit** (import
`components.dart`): adicione a extensão ao tema existente, sem perder as
outras.

```dart
ThemeData comNeon(ThemeData base) => base.copyWith(
  extensions: [
    ...base.extensions.values,
    NeonThemeExt(
      palette: NeonPalette.fromSeed(
        primary: base.colorScheme.primary,
        brightness: base.brightness,
      ),
      style: NeonStyle.flat,
    ),
  ],
);

MaterialApp(theme: comNeon(temaClaro), darkTheme: comNeon(temaEscuro), ...);
```

Isso deixa o `ColorScheme`, a tipografia e os widgets Material do app
intactos; os neon passam a seguir a cor do app.

**C. Só uma parte da tela diferente**: `NeonScope(palette: ..., style: ...,
child: ...)`. Tem prioridade sobre o tema.

**D. Nada**: com `components.dart` e sem registrar nada, funciona com a
paleta default. Aceitável para protótipo, não para entregar.

## 6. Troque os widgets

Siga [`references/widgets.md`](references/widgets.md). Regras:

- Troque por tela, não o app inteiro de uma vez; rode `flutter analyze` a
  cada tela.
- Os widgets neon são **controlados**: recebem `value`/`selectedIndex` e
  `onChanged`, sem controller interno (exceto `NeonTextField`, que aceita
  `controller`). Ao trocar `TabBar`+`TabController`, mova o índice para o
  estado da tela.
- Desabilitar = `onPressed`/`onChanged: null`. Carregando = `busy: true` nos
  botões, em vez de trocar o filho por um `CircularProgressIndicator`.
- Muitos widgets recebem `String` onde o Material recebe `Widget` (`title`
  de `NeonAppBar`, `NeonListTile`, `NeonDialog`, `NeonExpansionTile`;
  `label` dos botões). Se o original monta um `Text` com estilo especial,
  avise que o estilo vem do tema agora.
- Funções `showDialog`/`showModalBottomSheet`/`showDatePicker`/... têm
  versões `showNeonX` com o mesmo papel; prefira-as a envolver o widget neon
  em `showDialog` na mão.
- Não troque o que não tem equivalente (Autocomplete, Stepper com
  conteúdo horizontal, tabelas paginadas…); deixe o Material e diga quais
  ficaram de fora.
- Fundo do kit: envolva o `body` com `AnimatedGridBackground(child: ...)`.
  Ele respeita o estilo (grid, pontos ou liso).
- Componente próprio do app que precisa combinar com o kit: use
  `NeonThemeExt.of(context).palette`, `NeonStyle.of(context)`,
  `NeonDecorations.panel/selectable/input`, `NeonPressable`. Nunca cores
  fixas ou `AppColors` (ignoram preset, seed e modo claro).

## 7. Verifique

1. `flutter analyze` sem erros novos.
2. `flutter test`. Testes que procuram `find.byType(ElevatedButton)`,
   `find.byType(TextField)` etc. vão quebrar onde o widget foi trocado;
   atualize para o tipo neon (`find.byType(NeonButton)`) ou para
   `find.text`/`find.bySemanticsLabel`. Testes que usam
   `MaterialApp`/`ThemeData` de `flutter/material.dart` precisam do mesmo
   import de `material_ui` do passo 3.
3. Rode o app nos dois brilhos se ele tem modo claro. No claro, bordas de
   alguns controles antigos do kit (radio, checkbox, switch, trilho de
   slider/progress, tabs, stepper, data table) saem quase pretas: bug
   conhecido do kit (`surfaceOutline.withValues(alpha:)`), não do app.
   Reporte em vez de "consertar" no app.
4. Resuma para o usuário: import escolhido, caminho de tema (A/B/C), widgets
   trocados, o que ficou Material e por quê.
