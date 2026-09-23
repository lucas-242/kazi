# Kazi — landing page

Site estático em três idiomas (pt-BR, en, es). Não há bundler nem dependências: as páginas são geradas por um
script Dart a partir de um template e de um dicionário por idioma, e o resultado é HTML puro — abra no navegador
ou envie a pasta inteira para qualquer hospedagem estática (Netlify, Vercel, GitHub Pages, Firebase Hosting, S3).

## Estrutura

    tool/template.html  a página, com {{chaves}} no lugar de todo texto visível
    tool/build.dart     gera uma página por idioma
    l10n/pt.json        dicionário do português (idioma padrão, vai para a raiz)
    l10n/en.json        inglês
    l10n/es.json        espanhol

    index.html          gerado — pt-BR
    en/index.html       gerado — inglês
    es/index.html       gerado — espanhol
    assets/styles.css   todos os estilos; tokens do Brandbook v1 no topo (:root)
    assets/favicon.svg  ícone do app (símbolo grafite sobre amarelo)

Fontes: Archivo, IBM Plex Sans e IBM Plex Mono, carregadas do Google Fonts.

**Os três `index.html` são gerados — não edite à mão.** Texto vai nos dicionários, marcação no template.

## Gerar as páginas

Da raiz do monorepo:

```bash
melos run generate-landing
melos run generate-landing -- --site-url=https://seu-dominio   # canonical e hreflang
```

Ou direto, de dentro do pacote:

```bash
cd packages/kazi_landing
dart tool/build.dart
dart tool/build.dart --site-url=https://seu-dominio
```

O script falha se uma chave usada no template faltar em algum dicionário, então uma tradução esquecida aparece
na hora de gerar, não em produção.

### Mudar um texto

Edite a chave nos três dicionários e gere de novo. Cada idioma guarda o texto **já formatado**, inclusive
dinheiro, datas e horas — não há formatador em runtime:

| | pt-BR | en | es |
|---|---|---|---|
| valor | `R$ 1.712,00` | `$1,712.00` | `$1.712,00` |
| data | `09 ago` | `Aug 09` | `09 ago` |
| hora | `14:00` | `2:00 PM` | `14:00` |

Os números do exemplo (32 serviços em agosto, comissões de 30% a 50%) são os mesmos nos três idiomas; só a
moeda e a formatação mudam. Inglês e espanhol usam dólar porque o exemplo é genérico — se a landing ganhar
um público principal em outra moeda, é trocar os valores no dicionário daquele idioma.

### Adicionar um idioma

1. Copie `l10n/en.json` para `l10n/<código>.json` e traduza. **Mantenha exatamente as mesmas chaves.**
2. Ajuste o cabeçalho do arquivo: `lang` (atributo `lang` do `<html>` e do `hreflang`), `ogLocale`, `name`
   (nome do idioma no próprio idioma, usado no `aria-label` do seletor) e `code` (as duas letras do seletor).
3. Acrescente o código à lista `locales` em [tool/build.dart](tool/build.dart).
4. `dart tool/build.dart`.

O seletor de idioma, as tags `hreflang`, o `canonical` e os caminhos relativos para `assets/` saem disso
sozinhos. O primeiro idioma da lista é o padrão e vai para a raiz; os outros ganham uma pasta com o próprio
código.

### Chaves do template

`{{chave}}` vem do dicionário e é escapado para HTML. `{{_chave}}` é gerado pelo script e entra cru:
`_lang`, `_ogLocale`, `_assets`, `_canonical`, `_alternates` e `_langSwitch`.

## Seletor de idioma

`PT · EN · ES` aparece no cabeçalho e no rodapé, com `aria-current="page"` no idioma atual. Em telas de até
639px o botão "Baixar o app" do cabeçalho fica oculto para o seletor caber — o botão do Google Play do hero
está logo abaixo, visível sem rolar.

Não há redirecionamento por idioma do navegador: a raiz é sempre português e a escolha é explícita.

## Antes de publicar

1. **Domínio** — gere com `--site-url=https://seu-dominio` (o padrão é `https://kazi.app`, em
   [tool/build.dart](tool/build.dart)). É o que entra em `canonical`, `og:url` e nas tags `hreflang`.
2. **Selos das lojas** — os botões são próprios da marca. Se preferir os selos oficiais, as regras de uso estão em
   https://play.google.com/intl/pt-BR/badges/ e https://developer.apple.com/app-store/marketing/guidelines/
3. **Botão do iOS** — está como `<button disabled>`. Quando o app sair, troque no template por um `<a>` com a mesma
   classe `store` e a variante `store--light` (hero) / `store--dark` (chamada final).
4. **Rodapé** — Política de privacidade, Termos de uso e Contato apontam para `#`. Se as páginas legais tiverem
   versão por idioma, os `href` precisam virar chaves de dicionário.
5. **Imagem de compartilhamento** — se quiser prévia em WhatsApp/redes, adicione uma imagem 1200×630 e a tag
   `<meta property="og:image" content="{{_canonical}}og.png">` no `<head>` do template.

## Telas do app

As quatro telas (Início, Detalhe do serviço, Lista e Resumo) são desenhadas em HTML/CSS dentro do template
(blocos `<div class="phone">`), com dados de exemplo vindos do dicionário. O aparelho tem altura fixa (620px)
e as linhas não truncam, então texto muito mais longo que o português empurra o conteúdo para fora da tela —
vale gerar e olhar depois de mexer nos nomes de serviço.

Para usar screenshots reais, substitua o conteúdo de cada `<div class="phone-slot">` por uma imagem 300×620
(ou proporcional):

    <div class="phone-slot"><img src="{{_assets}}tela-inicio.png" width="300" height="620" alt="…"></div>

e adicione ao CSS: `.phone-slot img { width: 100%; height: 100%; border-radius: 46px; }`

Uma imagem por idioma vira uma chave no dicionário (`{{screenshotHome}}`) apontando para arquivos diferentes.
