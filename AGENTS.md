# AGENTS.md — lumen_kit

Guia para agentes (e humanos com pressa) que vão mexer neste repositório.
O README é para quem **usa** o kit; este arquivo é para quem **altera** o kit.
Para aplicar o kit em outro app, veja a skill em
[`skills/lumen-kit/SKILL.md`](skills/lumen-kit/SKILL.md).

## O que é

`lumen_kit` é um pacote Flutter (não publicado no pub.dev, `publish_to: none`)
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
  lumen_kit.dart          # import completo: components.dart + AppTheme + AppColors
  components.dart       # só widgets + paleta/estilo, sem AppTheme/AppColors
  src/
    theme/              # LumenPalette, LumenPreset, LumenThemeExt, LumenScope, LumenStyle, AppTheme, AppColors
    foundation/         # peças reaproveitáveis: LumenPressable, LumenDecorations,
                        #   LumenActionContent, LumenLabeled, LumenMotion + kLumen* tokens
    backgrounds/        # LumenAnimatedGridBackground, LumenGlowOrbSpec
    widgets/            # um arquivo por widget (ou família: lumen_tabs.dart tem LumenTabs + LumenSegmentedControl)
test/
  widgets/_harness.dart # bareApp/pumpBare: app SEM LumenThemeExt registrado
  widgets/*_test.dart   # um teste por widget novo
  components_import_test.dart  # garante que components.dart funciona sem o tema do kit
example/lib/main.dart   # galeria; todo widget novo aparece aqui
```

### Os dois imports públicos

- `package:lumen_kit/lumen_kit.dart`: tudo. Exporta `components.dart` +
  `AppTheme` + `AppColors`.
- `package:lumen_kit/components.dart`: widgets, foundation, `LumenPalette`,
  `LumenStyle`, `LumenScope`, `LumenThemeExt`. **Não** exporta `AppTheme` nem
  `AppColors`, para não colidir com classes de mesmo nome no app do usuário
  (`test/components_import_test.dart` cobre isso).

Widget novo → `export` em `lib/components.dart` (ordem alfabética, o lint
`directives_ordering` cobra). Nunca exporte nada de `src/theme/app_*.dart`
por `components.dart`.

## Regras de tema (as que quebram coisas quando ignoradas)

**Cor.** Sempre `final LumenPalette p = LumenThemeExt.of(context).palette;`.
Nunca `AppColors.x` dentro de widget ou foundation: a cor fica congelada e
ignora `AppTheme.fromSeed`, presets, modo claro e `LumenScope`. Tokens:
`backgroundDeep/Mid/Soft`, `surface`, `surfaceOutline`, `surfaceHighlight`,
`primary`, `secondary`, `tertiary`, `textPrimary/Secondary/Muted`,
`success`, `warning`, `danger`, `backgroundGradient`, `accentGradient`.
`accentCyan/Magenta/Blue` são aliases `@Deprecated`; não use em código novo.

**Estilo.** Sempre `final LumenStyle s = LumenStyle.of(context);` e passe
efeitos por ele:

| Em vez de                     | Use                                  |
|-------------------------------|--------------------------------------|
| `BorderRadius.circular(r)`    | `s.radius(r)`                        |
| `boxShadow: [BoxShadow(...)]` | `s.shadows([...glows])`              |
| `gradient: g`                 | `s.fill(g)` (vira cor sólida no flat/brutal) |
| `Border.all(...)`             | `s.borderAll(color: c, width: w)`    |
| `surface.withValues(alpha: a)`| `surface.withValues(alpha: s.surfaceAlpha(a))` |
| painel flutuante              | `s.frost(child: ..., borderRadius: ...)` + `LumenDecorations.panel(p, s, accent: a)` |

Senão o widget fica igual nos cinco estilos (neon, flat, glass, soft, brutal).

**Resolução de tema.** `LumenThemeExt.of(context)` procura, nesta ordem:
`LumenScope` mais próximo → `LumenThemeExt` no `ThemeData` → paleta default
(escura ou clara conforme `Theme.of(context).brightness`) com
`LumenStyle.neon`. Todo widget tem que funcionar no terceiro caso, sem nada
registrado; é o que `bareApp` testa.

**Alpha em cores da paleta.** `Color.withValues(alpha: x)` **substitui** o
alpha, não multiplica. `surfaceOutline` no claro default já é translúcido
(`0x15000000`), então `p.surfaceOutline.withValues(alpha: 0.5)` vira preto
quase opaco. Para contorno use `p.surfaceOutline.outlineAlpha(0.5)`: no
escuro o alpha pedido entra direto (o cyan continua visível) e no claro o
preto fraco é só escalado. Token que já nasce translúcido (`textMuted`,
`textSecondary`, `surfaceHighlight`) usa `c.scaleAlpha(x)`, que faz `c.a * x`.
Accent opaco pode usar `withValues(alpha:)` à vontade. Não multiplique um
accent opaco achando que está suavizando um token que já tinha alpha.

**Material 3 e tipografia.** Texto usa `Theme.of(context).textTheme` com
`copyWith(color: p.textX)`. Não fixe `fontFamily`.

## Convenções de widget

- Um arquivo por widget em `lib/src/widgets/`, nome `lumen_<coisa>.dart`.
- Construtor `const`, `super.key` logo após os `required`, overrides de cor
  como `Color? accentColor` (default `p.primary`).
- Controlado de fora: `value` + `onChanged`. `onChanged == null` (ou
  `onPressed == null`) = desabilitado, com opacidade `kLumenDisabledOpacity`.
  `busy: true` = spinner inline (`LumenActionContent`).
- Área tocável: `LumenPressable` (ripple, foco de teclado, semântica
  `selected`/`checked`/`toggled`), não `GestureDetector` cru. Controle +
  rótulo: `LumenLabeled`.
- Animações: durações `kLumenFastDuration`/`kLumenMediumDuration` passadas por
  `LumenMotion.duration(context, d)`; loops via `LumenMotion.syncRepeat` em
  `didChangeDependencies`/`didUpdateWidget`. Tudo precisa parar com
  "reduzir animações" (`MediaQuery.disableAnimations`).
- Funções `showLumenX` (dialog, bottom sheet, menu, toast, loading…) seguem o
  mesmo padrão: `required BuildContext context`, leem paleta/estilo do
  `context` e devolvem `Future`.
- Docs (`///`) em português, em todo membro público. Exemplos em blocos
  ` ```dart `.

## Checklist para widget novo

1. `lib/src/widgets/lumen_x.dart` seguindo as regras acima.
2. `export` em `lib/components.dart`.
3. `test/widgets/lumen_x_test.dart` usando `pumpBare` (funciona sem tema),
   cobrindo interação, estado desabilitado, semântica e reduce motion quando
   houver animação.
   Em teste, **nunca dê `await` direto em `showLumenX`** (dialog, picker,
   toast, loading): o `Future` só completa quando a rota fecha, e o teste
   trava para sempre esperando. Use `unawaited(showLumenX(...).then(...))`
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
