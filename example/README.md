# Galeria do Lumen Kit

Execute o comando abaixo na pasta `example` para abrir a galeria.

```powershell
flutter run -d windows
```

## Como comparar

Use a seção **Cores e estilo** para alternar a paleta e o estilo de forma
independente. A galeria abre com os dois controles ligados.

| Cores do Lumen | Estilo dos componentes | Resultado na galeria Lumen |
| --- | --- | --- |
| Ligadas | Ligado | Paleta e estilo selecionados. |
| Desligadas | Ligado | Cores do Material com o estilo selecionado. |
| Ligadas | Desligado | Paleta selecionada com os cantos e as bordas base do kit. |
| Desligadas | Desligado | Cores do Material com os cantos e as bordas base do kit. |

Com o estilo desligado, a galeria usa preenchimentos sólidos e dispensa
sombras e ornamentos de fundo. O modo claro ou escuro e a tipografia do
Material valem para todas as combinações.

**Material padrão** abre uma tela separada com as cores e as formas nativas
do Material. Ela reúne equivalentes para cards, botões, campos, seleção,
navegação, feedback e tabelas. A seta de voltar recupera a configuração
anterior da galeria Lumen.

## Como o exemplo aplica o tema

A [galeria Lumen](lib/main.dart) combina a paleta e o estilo escolhidos via
`LumenThemeExt`. Quando as cores do Lumen estão desligadas, ela mapeia o
`ColorScheme` do Material para uma `LumenPalette` e usa verde e âmbar para
sucesso e alerta. A [tela de comparação](lib/material_gallery.dart) usa o
`ThemeData` padrão e widgets do `material_ui`.
