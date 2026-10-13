# Revisão do kit

Leitura do repositório em 12 out 2026, quando o pacote ainda se chamava `neon_ui`.
Depois disso ele foi renomeado para `lumen_kit` e o prefixo `Neon` virou `Lumen`.
Os nomes abaixo são os daquela leitura.

Pacote Flutter 0.1.0, não publicado. 7.482 linhas em `lib`, 41 arquivos de
widget, cinco estilos visuais e uma base de tema que já separa cor de efeito.
O kit está bem desenhado; a dívida que sobrou é teste e distribuição. O tema
claro foi o item tratado na branch `fix/tema-claro-alpha`.

| Medida | Valor |
| --- | --- |
| Arquivos de widget | 41 |
| Sem nenhum teste | 13 |
| Arquivos com alpha quebrado no claro | 12 na leitura; o caminho foi fechado nesta branch |
| Workflows de CI | 0 |

Contagens de linha: `lib` 7.482, `test` 1.399, galeria 1.014.

## O exemplo público ensina o import errado

O README importa `package:flutter/material.dart` junto com `neon_ui`. O kit
usa `material_ui`, e os dois `ThemeData` não são o mesmo tipo. O `AGENTS.md`
já avisa que essa mistura compila às vezes e quebra em runtime. Quem copia o
uso mínimo cai nessa armadilha.

## O que segura o kit

**Tema ortogonal.** `NeonPalette` e `NeonStyle` são independentes. Preset,
`fromSeed`, `NeonScope` e o fallback sem nada registrado no `ThemeData` cobrem
os três jeitos de usar o kit. Widgets novos já nascem no `bareApp`.

**Base reaproveitável.** `NeonPressable`, `NeonDecorations`,
`NeonActionContent`, `NeonLabeled` e `NeonMotion` concentram toque, semântica,
painel e reduzir animações. O catálogo não reimplementa `InkWell` em cada
arquivo.

**Contrato de API estável.** Dois imports públicos, `components.dart` sem
`AppTheme` e `AppColors`, construtor const, `onChanged` nulo desabilita,
`busy` mostra spinner. A skill e o `AGENTS.md` repetem as mesmas regras que o
código segue.

**Acessibilidade de verdade.** Há testes de semântica, teclado no switch,
`Form` no text field e animações que param com `disableAnimations`. Isso é
raro num kit visual e vale preservar.

## Cobertura dos 41 arquivos de widget

Cruzamento de `lib/src/widgets` com `test/` em 12 out 2026.

| Tipo | Arquivos | O que conta |
| --- | ---: | --- |
| Com asserção | 22 | Interação ou semântica |
| Só render | 6 | Só entra num pump que não pode estourar |
| Ausente do teste | 13 | O arquivo não é referenciado |

## Onde dói

**A rede de testes cobre a leva nova, não o catálogo.** 1.399 linhas de teste
contra 7.482 de `lib`. Os widgets do PR de menu, chips, rating, carrossel e
loading têm arquivo próprio. Dialog, dropdown, drawer, sheet, stepper, tabela
e busca não aparecem em nenhum teste. Não há golden: uma regressão de flat,
glass ou brutal passa no `flutter test`.

**Tema claro substituía alpha em vez de multiplicar.** `surfaceOutline` no
claro já é translúcido. `withValues(alpha: 0.9)` troca esse alpha e vira
quase preto. Na leitura, checkbox, radio, switch, slider, progress, tabs,
stepper, data table, list tile, expansion, bottom nav e a borda desabilitada
de `LumenDecorations` ainda passavam por esse caminho. Isso foi fechado:
contorno usa `outlineAlpha`, e token que já nasce translúcido usa
`scaleAlpha`. Detalhe na seção seguinte.

**Distribuição é git em `main`, versão 0.1.0.** `publish_to: none`, sem
CHANGELOG, sem tag e sem CI. O README pede `ref: main`. Quem consome o kit
não tem como fixar uma revisão nem saber o que quebrou entre um `pub get` e
o seguinte.

## Arquivos que o teste nunca abre

| Widget | Área | O que falta provar |
| --- | --- | --- |
| NeonDialog | overlay | Abre rota; o Future só completa ao fechar |
| NeonDropdown | formulário | Seleção, item desabilitado, valor nulo |
| NeonDrawer | navegação | Item selecionado e fechamento |
| NeonBottomSheet | overlay | `showNeonBottomSheet` e gesto de fechar |
| NeonStepper | navegação | Passo atual, erro e direção |
| NeonDataTable | dados | Cabeçalho, linha e rolagem |
| NeonSearchBar | formulário | Controller, limpar, `onChanged` |
| NeonTooltip | feedback | Hover, foco e reduce motion |
| NeonFab | ação | `onPressed` nulo e `busy` |
| GradientCta | ação | Desabilitado e semântica |
| NeonAppBar | estrutura | Título, subtitle e ações |
| NavigationCard | navegação | Hover e `onTap` |
| NeonDivider | display | Gradiente some no estilo flat |
| NeonBottomNavBar | navegação | O rail tem teste; a barra não |
| NeonSegmentedControl | navegação | Só o `NeonTabs` é exercitado |
| NeonTag | display | O badge só aparece de carona no rail |

## Melhorias, na ordem em que valem o esforço

1. **CI com `flutter analyze` e `flutter test`.** O analyzer é estrito e hoje
   só roda na máquina de quem lembra.
2. **Corrigir o import do README para `material_ui`.** É o primeiro código
   que um app novo copia.
3. **Testes dos 13 arquivos ausentes, overlays primeiro.** Dialog, sheet e
   menu são os que travam teste se o Future for awaited.
4. **Helper de alpha (`c.a * x`) e corrigir o tema claro.** Feito. Ver abaixo.
5. **Trocar `ref: main` por tag e abrir um CHANGELOG.** 0.1.0 parado não
   comunica o que os nove widgets novos já entregaram.
6. **Alinhar os nomes públicos ao prefixo `Lumen`.** `LumenCta`,
   `LumenNavigationCard` e `LumenStatusChip` já estavam certos. Nesta branch
   faltavam o fundo e o posicionamento do menu. Feito, com alias deprecated.
7. **Fatiar `example/lib/main.dart` (1.014 linhas) e tirar `Colors.white` /
   `Colors.black`.** A galeria é o único lugar que mostra os cinco estilos.
   Badge, thumb do slider, sombra do menu e a barreira do sheet ignoram a
   paleta.

## Feito na `fix/tema-claro-alpha`

**`Color.scaleAlpha`.** Multiplica o alpha que a cor já tem (`a * factor`),
com teto em `1`. `outlineAlpha` continua o caminho do contorno: no escuro o
pedido entra direto, no claro o preto fraco é só escalado e não passa de
`0.28`. Accent opaco segue em `withValues`, porque ali o alpha pedido é
absoluto.

O helper entrou onde o token já era translúcido ou o código já multiplicava:

- `textMuted` no rating, no thumb desligado do switch, no handle do bottom
  sheet e no ponto inativo do page indicator
- borda de `LumenStyle.borderAll` e o glow adaptado das sombras
- pontos do fundo, que compensam a opacidade da grade com `scaleAlpha(3)`

**`LumenPalette.fromSeed` no claro.** `surfaceOutline` e `surfaceHighlight`
passam a ser o preto fraco de `LumenPalette.light` (`0x15000000` e
`0x08000000`). Antes o contorno era o accent a 25%, e `outlineAlpha` subia
isso para `0.6`–`0.9`.

**Nomes.** `animated_grid_background.dart` virou
`lumen_animated_grid_background.dart`. `AnimatedGridBackground` e
`GlowOrbSpec` viraram `LumenAnimatedGridBackground` e `LumenGlowOrbSpec`.
`neonMenuPositionAt` virou `lumenMenuPositionAt`. Os três nomes antigos
continuam, marcados como deprecated.

## Roadmap

Ainda aberto naquela leitura: banner, empty state, pin field, timeline e
file upload. A seção “A fazer” está quase toda marcada e não serve mais como
plano.
