# AGENTS.md — neon_ui

Guia para agentes (e humanos com pressa) que vão mexer neste repositório.
O README é para quem **usa** o kit; este arquivo é para quem **altera** o kit.
Para aplicar o kit em outro app, veja a skill em
[`skills/neon-ui/SKILL.md`](skills/neon-ui/SKILL.md).

## O que é

`neon_ui` é um pacote Flutter (não publicado no pub.dev, `publish_to: none`)
com tema futurístico e ~45 widgets. Consumido via dependência git. Tudo é
desacoplado de domínio: widgets recebem dados, callbacks e tokens, nunca
regras de negócio.

## Toolchain

- Dart `^3.13.0`, Flutter `>=3.47.0` (o canal stable atual serve).
- **Material vem do pacote `material_ui`, não de `flutter/material.dart`.**
  Todo arquivo em `lib/` importa `package:material_ui/material_ui.dart` (que
  já reexporta `package:flutter/widgets.dart`). Não misture com
  `package:flutter/material.dart`: são bibliotecas diferentes com tipos
  diferentes (`ThemeData`, `Theme`, `Material`…), e o resultado compila só às
  vezes e falha em runtime nas outras.
- O código usa sintaxe recente do Dart 3.13 (parâmetros nomeados privados
  como `this._backgroundGradient`, dot shorthands como `.vibrant`). Não
  "corrija" isso.

## Comandos

```bash
flutter pub get                 # na raiz; o flutter tool resolve example/ junto
flutter analyze                 # precisa sair "No issues found!"
flutter test                    # testes do pacote (test/)
cd example && flutter run -d chrome   # galeria com seletor de preset/estilo/brilho
```

Não há `flutter` no container? `git clone --depth 1 -b stable
https://github.com/flutter/flutter.git` e use `flutter/bin/flutter`. Para
screenshots da galeria: `flutter build web --no-web-resources-cdn` em
`example/` e Playwright com `locale: 'en-US'` (sem locale o app quebra com
"Incorrect locale information").

`analysis_options.yaml` é bem estrito (`strict-casts`, `strict-inference`,
`always_put_control_body_on_new_line`, `prefer_relative_imports`,
`specify_nonobvious_*`…). `flutter analyze` com zero issues é o padrão do
repo.

Formatação: `dart format` no padrão de 80 colunas (sem `page_width` no
`analysis_options.yaml`). O repo inteiro já está formatado, então
`dart format lib test example/lib` não deve gerar diff além do seu.

## Estrutura

```
lib/
  neon_ui.dart          # import completo: components.dart + AppTheme + AppColors
  components.dart       # só widgets + paleta/estilo, sem AppTheme/AppColors
  src/
    theme/              # NeonPalette, NeonPreset, NeonThemeExt, NeonScope, NeonStyle, AppTheme, AppColors
    foundation/         # peças reaproveitáveis: NeonPressable, NeonDecorations,
                        #   NeonActionContent, NeonLabeled, NeonMotion + kNeon* tokens
    backgrounds/        # AnimatedGridBackground, GlowOrbSpec
    widgets/            # um arquivo por widget (ou família: neon_tabs.dart tem NeonTabs + NeonSegmentedControl)
test/
  widgets/_harness.dart # bareApp/pumpBare: app SEM NeonThemeExt registrado
  widgets/*_test.dart   # um teste por widget novo
  components_import_test.dart  # garante que components.dart funciona sem o tema do kit
example/lib/main.dart   # galeria; todo widget novo aparece aqui
```

### Os dois imports públicos

- `package:neon_ui/neon_ui.dart`: tudo. Exporta `components.dart` +
  `AppTheme` + `AppColors`.
- `package:neon_ui/components.dart`: widgets, foundation, `NeonPalette`,
  `NeonStyle`, `NeonScope`, `NeonThemeExt`. **Não** exporta `AppTheme` nem
  `AppColors`, para não colidir com classes de mesmo nome no app do usuário
  (`test/components_import_test.dart` cobre isso).

Widget novo → `export` em `lib/components.dart` (ordem alfabética, o lint
`directives_ordering` cobra). Nunca exporte nada de `src/theme/app_*.dart`
por `components.dart`.

## Regras de tema (as que quebram coisas quando ignoradas)

**Cor.** Sempre `final NeonPalette p = NeonThemeExt.of(context).palette;`.
Nunca `AppColors.x` dentro de widget ou foundation: a cor fica congelada e
ignora `AppTheme.fromSeed`, presets, modo claro e `NeonScope`. Tokens:
`backgroundDeep/Mid/Soft`, `surface`, `surfaceOutline`, `surfaceHighlight`,
`primary`, `secondary`, `tertiary`, `textPrimary/Secondary/Muted`,
`success`, `warning`, `danger`, `backgroundGradient`, `accentGradient`.
`accentCyan/Magenta/Blue` são aliases `@Deprecated`; não use em código novo.

**Estilo.** Sempre `final NeonStyle s = NeonStyle.of(context);` e passe
efeitos por ele:

| Em vez de                     | Use                                  |
|-------------------------------|--------------------------------------|
| `BorderRadius.circular(r)`    | `s.radius(r)`                        |
| `boxShadow: [BoxShadow(...)]` | `s.shadows([...glows])`              |
| `gradient: g`                 | `s.fill(g)` (vira cor sólida no flat/brutal) |
| `Border.all(...)`             | `s.borderAll(color: c, width: w)`    |
| `surface.withValues(alpha: a)`| `surface.withValues(alpha: s.surfaceAlpha(a))` |
| painel flutuante              | `s.frost(child: ..., borderRadius: ...)` + `NeonDecorations.panel(p, s, accent: a)` |

Senão o widget fica igual nos cinco estilos (neon, flat, glass, soft, brutal).

**Resolução de tema.** `NeonThemeExt.of(context)` procura, nesta ordem:
`NeonScope` mais próximo → `NeonThemeExt` no `ThemeData` → paleta default
(escura ou clara conforme `Theme.of(context).brightness`) com
`NeonStyle.neon`. Todo widget tem que funcionar no terceiro caso, sem nada
registrado; é o que `bareApp` testa.

**Alpha em cores da paleta.** `Color.withValues(alpha: x)` **substitui** o
alpha, não multiplica. `surfaceOutline` já é translúcido (`0x15000000` no
claro), então `p.surfaceOutline.withValues(alpha: 0.5)` vira preto quase
opaco no tema claro. Vários widgets antigos (radio, checkbox, switch, trilhos
de slider/progress, tabs, stepper, data table) ainda têm esse bug, deixado de
propósito porque corrigir muda o visual; não repita o padrão em código novo.
Multiplique (`c.withValues(alpha: c.a * x)`) ou use o accent translúcido
como `NeonDecorations.input` faz.

**Material 3 e tipografia.** Texto usa `Theme.of(context).textTheme` com
`copyWith(color: p.textX)`. Não fixe `fontFamily`.

## Convenções de widget

- Um arquivo por widget em `lib/src/widgets/`, nome `neon_<coisa>.dart`.
- Construtor `const`, `super.key` logo após os `required`, overrides de cor
  como `Color? accentColor` (default `p.primary`).
- Controlado de fora: `value` + `onChanged`. `onChanged == null` (ou
  `onPressed == null`) = desabilitado, com opacidade `kNeonDisabledOpacity`.
  `busy: true` = spinner inline (`NeonActionContent`).
- Área tocável: `NeonPressable` (ripple, foco de teclado, semântica
  `selected`/`checked`/`toggled`), não `GestureDetector` cru. Controle +
  rótulo: `NeonLabeled`.
- Animações: durações `kNeonFastDuration`/`kNeonMediumDuration` passadas por
  `NeonMotion.duration(context, d)`; loops via `NeonMotion.syncRepeat` em
  `didChangeDependencies`/`didUpdateWidget`. Tudo precisa parar com
  "reduzir animações" (`MediaQuery.disableAnimations`).
- Funções `showNeonX` (dialog, bottom sheet, menu, toast, loading…) seguem o
  mesmo padrão: `required BuildContext context`, leem paleta/estilo do
  `context` e devolvem `Future`.
- Docs (`///`) em português, em todo membro público. Exemplos em blocos
  ` ```dart `.

## Checklist para widget novo

1. `lib/src/widgets/neon_x.dart` seguindo as regras acima.
2. `export` em `lib/components.dart`.
3. `test/widgets/neon_x_test.dart` usando `pumpBare` (funciona sem tema),
   cobrindo interação, estado desabilitado, semântica e reduce motion quando
   houver animação.
   Em teste, **nunca dê `await` direto em `showNeonX`** (dialog, picker,
   toast, loading): o `Future` só completa quando a rota fecha, e o teste
   trava para sempre esperando. Use `unawaited(showNeonX(...).then(...))`
   (de `dart:async`), que é o que o lint `unawaited_futures` aceita, e
   bombeie com `tester.pump`.
4. Seção na galeria (`example/lib/main.dart`).
5. Linha na tabela "O que vem dentro" do `README.md` + exemplo curto se a API
   não for óbvia; marcar no `ROADMAP.md`.
6. `dart format lib test example/lib`, `flutter analyze` e `flutter test` limpos.

## Git

Commits em português no estilo conventional (`feat:`, `fix:`,
`refactor:`). PRs descrevem o que muda visualmente; screenshot da galeria
ajuda quando o visual muda.
