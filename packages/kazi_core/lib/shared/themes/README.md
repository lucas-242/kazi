# O design system do Kazi

Duas regras, e o resto sai delas:

1. **Cor vem de `context.colors`.** Sempre. Não existe outro caminho.
2. **Tipografia vem de `KaziTextStyles`**, com os nomes de slot do Flutter.

Nenhuma tela pergunta em que modo está. Se você escreveu
`Brightness.dark ? … : …` numa tela, falta um token.

Para ver tudo renderizado em light e dark ao mesmo tempo, rode o app em debug e
vá em **Menu → Debug → Design tokens** (`KaziThemeGalleryPage`).

---

## Cores — "quero pintar X, uso o quê?"

### Superfícies

| Quero pintar | Token |
|---|---|
| o fundo da página / scaffold | `colors.background` |
| um cartão sobre a página | `colors.card` |
| um campo, chip ou linha inativa | `colors.surfaceMuted` |
| um bloco que precisa ler como região própria | `colors.surfaceStrong` |
| uma faixa do brilho oposto (snackbar, tooltip) | `colors.inverse` / `colors.onInverse` |

### Tinta e bordas

| Quero pintar | Token |
|---|---|
| texto e ícones normais | `colors.text` |
| texto de apoio, legenda, metadado | `colors.textMuted` |
| filete, divisor, contorno de cartão | `colors.border` |
| borda que precisa ser notada | `colors.borderStrong` |
| indicador de foco | `colors.focusRing` |

### Marca (o amarelo)

O amarelo tem dois tokens de propósito diferente porque **amarelo Kazi sobre
Névoa é 1,4:1** — invisível. `fill` é superfície; `text` é tinta.

| Quero pintar | Token |
|---|---|
| a ação principal: FAB, CTA | `colors.brand.fill` + `colors.brand.onFill` |
| o estado pressionado dessa ação | `colors.brand.pressed` |
| **escrever** em amarelo, tingir ícone, rótulo selecionado | `colors.brand.text` |
| o mesmo, mas em texto menor que 18,66px | `colors.brand.textStrong` |
| uma lavagem suave de destaque | `colors.brand.surface` + `colors.brand.onSurface` |

> Um amarelo por tela. Ele marca a ação principal **ou** o número principal —
> nunca os dois.

### Status

Os quatro têm exatamente a mesma forma. Nada de especial a lembrar sobre o
`danger` (ele era o `error` do Material).

| Quero pintar | Token |
|---|---|
| bolinha, ícone, chip sólido | `colors.<status>.fill` + `.onFill` |
| fundo de badge ou banner | `colors.<status>.surface` |
| texto de status (no badge ou direto na página) | `colors.<status>.onSurface` |

`<status>` = `success` · `warning` · `info` · `danger`.

> Alerta nunca é o amarelo da marca. `warning` é âmbar-laranja — se o amarelo
> Kazi sinalizasse problema, a marca passaria a significar "atenção".

### Casos especiais

| Quero pintar | Token |
|---|---|
| o painel escuro que carrega o valor principal | `colors.money.surface` / `.onSurface` / `.accent` |
| um splash ou a tela de login (a marca **é** o fundo) | `colors.hero.surface` / `.ink` / `.mark` / `.muted` |
| a categoria de um serviço | `colors.category(index)` |
| a barra de status sobre uma cor qualquer | `colors.overlayOn(<a cor de fundo>)` |

`colors.hero` existe para que splash e login não perguntem o brilho: no light é
fundo amarelo com arte grafite, no dark é fundo grafite com o raio amarelo.

Categorias só em marcas pequenas: barras de borda, bolinhas, tags, fatias de
gráfico. Nunca fundo de tela, botão principal ou header — esse espaço é do
amarelo. Quatro das dezoito ficam abaixo de 3:1 no light, o que decide a forma
de cada marca:

- **`KaziCategoryBar`** — 3 dp na borda esquerda, é a marca de **linha de
  lista**. Encostada no fundo da tela, uma cor fraca ainda se lê como faixa; e
  na borda ela não cobra largura do texto, ao contrário da bolinha, que tirava
  ~16 px do nome do cliente. A barra diz o *tipo*, e o tipo não muda: nenhum
  estado a repinta.
- **`KaziColorDot`** — a marca onde a cor está cercada de conteúdo: linha de
  dropdown, cabeçalho de detalhe, seletor. Leva um anel de `colors.border`
  obrigatório, que é o que resgata as quatro cores fracas.

---

## Tipografia

Os quinze slots têm os nomes do Flutter, então não há tabela de tradução:
`KaziTextStyles.bodyMedium` é `TextTheme.bodyMedium`.

```
displayLarge  displayMedium  displaySmall     Archivo 800
headlineLarge headlineMedium headlineSmall    Archivo 800
titleLarge    titleMedium    titleSmall       Archivo 600
bodyLarge     bodyMedium     bodySmall        IBM Plex Sans 400
labelLarge    labelMedium    labelSmall       IBM Plex Sans 400/500
```

Fora da escala Material, porque o Material não tem onde encaixá-los:

| Token | Para quê |
|---|---|
| `KaziTextStyles.amount` / `amountAt(size)` | valores em dinheiro, com algarismos tabulares |
| `KaziTextStyles.tag` | etiquetas e eyebrows em mono — **o único lugar onde caixa alta é permitida**, e o call site que faz o `.toUpperCase()` |
| `KaziTextStyles.wordmarkAt(size)` | "kazi" como logo. Em texto corrido é "Kazi" em corpo normal, como qualquer nome próprio |

O APOIO do brandbook (15/24) não tem token: ele ficava espremido entre
`bodyMedium` e `bodySmall` sem justificar a decisão a mais. Onde uma tela
realmente quer, ela diz em voz alta:
`bodyMedium.copyWith(fontSize: 15, height: 24 / 15)`.

**Os estilos são sem cor de propósito.** `Text` mescla o estilo sobre o
`DefaultTextStyle` ambiente, então a cor chega do tema e acompanha o brilho
sozinha. Use `context.text.<slot>` quando quiser a versão já colorida.

---

## Estados de tela

Toda lista tem cinco versões, e quatro delas não são a de sucesso. Tela entregue
com um estado só volta para o desenho. Cada estado tem um componente, e a
diferença entre eles não é de grau — é de significado:

| Estado | Componente | O que ele diz |
|---|---|---|
| Carregando | `KaziSkeletonList` / `KaziSkeleton` | Está vindo. Nada aqui responde. |
| Vazio | `KaziEmpty` | Sua conta não tem nada dessa coisa **ainda**. |
| Sem resultados | `KaziNoResults` | Você tem, mas não **neste recorte**. |
| Erro | `KaziError` | Falhou a leitura — e seus dados continuam salvos. |
| Offline | *(ainda não existe)* | Faixa, não tela. |

**Vazio e sem resultado não são o mesmo estado.** O teste é de uma linha: se
remover o filtro traria linhas de volta, é *sem resultado*. É por isso que o
bloco amarelo com o símbolo da marca vive só em `KaziEmpty` — em uma busca sem
retorno ele daria a impressão falsa de conta zerada, e manda a pessoa procurar
um dado que ela tem. `KaziEmpty` convida (símbolo, frase de como a coisa nasce,
botão que cria a primeira); `KaziNoResults` devolve o controle (repete o termo,
oferece criar o que foi procurado ou limpar os filtros).

**Carregamento é por superfície.** `KaziSkeletonList` se embrulha em um
`AbsorbPointer`: a área que carrega engole o toque, porque não há o que
responder ali. Fora dela tudo continua vivo — barra inferior, FAB, busca,
filtros, chave Lista/Resumo. Travar a tela inteira tira da pessoa a chance de
sair para outra aba enquanto espera, e um esqueleto clicável dispara cinco
pedidos. Nunca dois esqueletos de tela cheia ao mesmo tempo: o segundo pedido é
faixa fina no topo.

**Trocar de aba cancela o pedido da aba abandonada.** As duas abas com
controller `keepAlive` — Início e Serviços — carregam um contador de geração:
uma leitura guarda o valor com que começou e joga a resposta fora se ele mudou
enquanto ela estava no ar. Voltar para a aba pede de novo. Sem isso, a resposta
chega para uma tela que ninguém está olhando, e ainda por cima escreve por cima
do que a pessoa está vendo agora.

**Ação destrutiva reversível tem faixa de desfazer por 5 s**, e é o
`KaziUndoSnackbar` que a desenha — arquivar cliente, arquivar item, marcar um
lote como recebido. O que não tem volta tem diálogo com a consequência escrita.
Nunca as duas coisas ao mesmo tempo, e nunca nenhuma das duas.

**Leitura e escrita carregam diferente.** Esqueleto é de leitura. Numa escrita o
botão vira "Salvando…" e fica inerte, o formulário fica somente leitura **e
visível** — nada de véu escuro, porque a pessoa precisa continuar vendo o que
digitou. Overlay bloqueante só onde a escrita muda a navegação: sair da conta,
trocar idioma.

**O erro responde ao medo, não ao log.** Em app de dinheiro, o que a pessoa teme
numa falha de leitura é que os registros sumiram. Por isso `KaziError` afirma
que os dados estão salvos antes de qualquer outra coisa, e o código de suporte é
rodapé — nunca a mensagem.

---

## Por dentro

| Arquivo | O que é |
|---|---|
| `kazi_colors.dart` | `KaziColors` e seus grupos. A fonte da verdade. |
| `settings/kazi_palette.dart` | Os hexes crus. **Não exportado pelo barrel** — de propósito. |
| `settings/kazi_text_styles.dart` | A escala tipográfica. |
| `settings/kazi_theme_settings.dart` | O `ThemeData`. O único lugar autorizado a falar Material. |
| `gallery/` | A galeria de tokens (debug). |

`KaziPalette` ficar fora do barrel é o que transforma "não use hex na tela" de
observação de code review em erro de compilação: os apps não conseguem
importá-lo. O `ColorScheme` continua existindo, dentro de `KaziColors.scheme`,
porque os widgets do próprio Flutter precisam dele — mas ele é encanamento, não
API. Em particular, `scheme.primary` é o amarelo da marca, que como tinta some
numa superfície clara; `colors.brand.text` é o token para isso.

### Adicionar um token

1. O hex vai em `KaziPalette` (se ainda não existir lá).
2. O papel vai em `KaziColors` ou no grupo que lhe cabe, com valor para **as
   duas** instâncias `light` e `dark`.
3. Se o grupo for novo, dê a ele um `lerp` — o `ThemeExtension` interpola por
   grupo.
4. Acrescente-o à galeria, senão ele não existe para quem for usar.

### Por que os dois `ColorScheme` são escritos à mão

`ColorScheme.fromSeed` foi descartado de propósito. Ele deriva por HCT todo
papel que você não sobrescrever — ou seja, reinventaria por algoritmo uma
paleta que o brandbook já especifica inteira, e a repintaria sozinho a cada
mudança de seed ou de versão do Flutter. Escrever os dois esquemas também os
torna `const`: montar o tema não custa nada em runtime.

`surfaceTint` está fixado em `surface` nos dois. Deixado em branco ele cai para
`primary`, o que lavaria de amarelo toda superfície Material elevada. O design
é plano ("sem gradientes"): a separação vem da escada de superfícies mais um
contorno de 1px, não de elevação tonal.

O esquema claro roda Névoa → branco, com tinta Graphite e o acento na forma
**tinta** (Âmbar) onde precisa ser lido. O escuro se ancora nos artefatos
escuros do brandbook — hero, splash e ícone — e ali o acento não precisa de
forma tinta: sobre grafite o amarelo dá 12,42:1 e lê perfeitamente como texto.
