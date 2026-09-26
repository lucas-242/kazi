# Landing page do Kazi

Site estático em três idiomas (pt-BR, en, es). Não há bundler nem dependências. As páginas são geradas por um
script Dart a partir de dois templates e de um dicionário por idioma, e o resultado é HTML puro: envie a pasta
inteira para qualquer hospedagem estática (Netlify, Vercel, GitHub Pages, Firebase Hosting, S3). As URLs sem
`index.html` vêm da configuração do host — a do Firebase está no [firebase.json](firebase.json).

Os links internos são absolutos (`/en`, `/privacy-policy`), então as páginas **não** funcionam abertas direto
do disco — precisam de um servidor. Para olhar antes de publicar:

```bash
cd packages/kazi_landing && firebase emulators:start --only hosting
```

O emulador respeita o [firebase.json](firebase.json), então é ele quem mostra as URLs como elas vão sair no ar.

## Estrutura

    tool/template.html  a home, com {{chaves}} no lugar de todo texto visível
    tool/policy.html    a política de privacidade, no mesmo formato
    tool/build.dart     gera cada página em cada idioma
    l10n/pt.json        dicionário do português (idioma padrão, vai para a raiz)
    l10n/en.json        inglês
    l10n/es.json        espanhol

    index.html                  gerado: home pt-BR
    en/index.html               gerado: home inglês
    es/index.html               gerado: home espanhol
    privacy-policy/index.html   gerado: política pt-BR
    en/privacy-policy/...       gerado: política inglês
    es/privacy-policy/...       gerado: política espanhol
    assets/styles.css   todos os estilos; tokens do Brandbook v1 no topo (:root)
    assets/favicon.svg  ícone do app (símbolo grafite sobre amarelo)
    assets/screens/     telas do app em WebP, uma pasta por idioma (geradas pelo kazi_mockups)

Fontes: Archivo, IBM Plex Sans e IBM Plex Mono, carregadas do Google Fonts.

**Todos os `index.html` são gerados. Não edite à mão.** Texto vai nos dicionários, marcação nos templates.

## Gerar as páginas

Da raiz do monorepo:

```bash
melos run generate-landing                 # ambiente staging (padrão)
melos run generate-landing -- --env=prod   # ambiente de produção
```

Ou direto, de dentro do pacote:

```bash
cd packages/kazi_landing
dart tool/build.dart
dart tool/build.dart --env=prod
dart tool/build.dart --site-url=https://outro-endereco   # override pontual
```

O ambiente escolhe a URL pública que vai para `canonical`, `og:url` e `hreflang`. A lista está em
`environments`, no topo de [tool/build.dart](tool/build.dart). Gerar com um ambiente sem URL definida falha
com mensagem, em vez de publicar um endereço errado.

O script também falha se uma chave usada num template faltar em algum dicionário. Assim uma tradução esquecida
aparece na hora de gerar, e não em produção.

### Mudar um texto

Edite a chave nos três dicionários e gere de novo. Cada idioma guarda o texto **já formatado**, inclusive
dinheiro, datas e horas. Não há formatador em runtime:

| | pt-BR | en | es |
|---|---|---|---|
| valor | `R$ 1.712,00` | `$1,712.00` | `$1.712,00` |
| data | `09 ago` | `Aug 09` | `09 ago` |
| hora | `14:00` | `2:00 PM` | `14:00` |

Os valores escritos no texto da página usam dólar em inglês e espanhol, porque o exemplo é genérico. As telas
do app não: são os mockups de cada locale, e o espanhol mostra guaranis (ver [Telas do app](#telas-do-app)).

### Adicionar um idioma

1. Copie `l10n/en.json` para `l10n/<código>.json` e traduza. **Mantenha exatamente as mesmas chaves.**
2. Ajuste o cabeçalho do arquivo: `lang` (atributo `lang` do `<html>` e do `hreflang`), `ogLocale`, `name`
   (nome do idioma no próprio idioma, usado no `aria-label` do seletor) e `code` (as duas letras do seletor).
3. Acrescente o código à lista `locales` em [tool/build.dart](tool/build.dart). O código precisa existir também
   como ARB do app (`intl_<código>.arb`), de onde sai o texto da política.
4. `dart tool/build.dart`.

O seletor de idioma, as tags `hreflang`, o `canonical` e os caminhos relativos para `assets/` saem disso
sozinhos. O primeiro idioma da lista é o padrão e vai para a raiz. Os outros ganham uma pasta com o próprio
código.

### Chaves do template

`{{chave}}` vem do dicionário — ou da ARB do app, nas chaves da política — e é escapado para HTML.
`{{_chave}}` é gerado pelo script e entra cru: `_lang`, `_ogLocale`, `_assets`, `_screens`, `_home`, `_policy`,
`_canonical`, `_alternates`, `_langSwitch` e o `_` na frente de qualquer chave da ARB, que rende os parágrafos
daquele texto.

## Política de privacidade

A página em `privacy-policy/` é a versão web do que o app mostra em Menu › Privacidade, e é o endereço que o
app abre (`AppUrls.privacyPolicy`, em `packages/kazi/lib/core/constants/app_urls.dart`). Mudar a pasta quebra
o link de toda versão já publicada na Play.

O texto **não** fica nos dicionários: [tool/build.dart](tool/build.dart) lê as ARBs do kazi_core
(`../kazi_core/lib/shared/l10n/arb/intl_<idioma>.arb`) pelas chaves da lista `appKeys`. É o que impede as duas
versões de divergirem — mudar a política é mudar a ARB e gerar de novo. Uma chave da lista que falte numa ARB
faz o script falhar.

Cada chave da ARB chega ao template em duas formas: `{{chave}}` é o texto escapado, numa linha só, e
`{{_chave}}` é o mesmo texto quebrado em `<p>` a cada `\n` — o app também trata cada quebra como um bloco.
Uma seção nova na política precisa da chave em `appKeys` e do bloco em [tool/policy.html](tool/policy.html).

Três chaves são do site, não do app, e ficam nos dicionários: `policyBackToSite`, `policyMetaDescription` e
`policyUpdatedAt`. A última é a data que o app formata em runtime (`PrivacyPolicyPage.updatedAt`); aqui ela vai
escrita por extenso em cada idioma, e precisa ser atualizada junto com a do app quando o texto mudar.

## Seletor de idioma

`PT · EN · ES` aparece no cabeçalho e no rodapé, com `aria-current="page"` no idioma atual. Em telas de até
639px o botão "Baixar o app" do cabeçalho fica oculto para o seletor caber. O botão do Google Play do hero
está logo abaixo, visível sem rolar.

Não há redirecionamento por idioma do navegador: a raiz é sempre português e a escolha é explícita.

## Deploy (Firebase Hosting)

Dois ambientes, nos mesmos projetos Firebase do app. Os aliases estão em `.firebaserc`:

| Ambiente | Projeto | URL |
|---|---|---|
| `staging` | `kazi-clients-staging` | https://kazi-clients-staging.web.app |
| `prod` | `my-services-2703` | https://kazipro.io |

```bash
melos run deploy-landing-staging
melos run deploy-landing-prod
```

Cada script gera as páginas com a URL daquele ambiente e só então publica, então o `canonical` nunca sai
apontando para o outro. O `prod_test` do app não existe aqui: ele só troca unidades de anúncio, e isso não tem
equivalente num site.

Sobem vinte arquivos: os seis `index.html`, os dois de `assets/` e as doze telas de `assets/screens/`. `README.md`, `l10n/` e `tool/` ficam de fora
pela lista `ignore` do [firebase.json](firebase.json), que também define o cache. HTML sem cache, para um deploy
aparecer na hora. `assets/` por uma hora, já que o CSS não tem hash no nome e um cache longo atrasaria correção
de estilo.

**Endereços sem `index.html` e sem barra no fim**: `cleanUrls` e `trailingSlash: false` fazem o Hosting servir
`privacy-policy/index.html` em `/privacy-policy`, e mandar 301 de `/privacy-policy/` e de
`/privacy-policy/index.html` para lá. Só um endereço responde 200, que é o mesmo que está no `canonical` e o
mesmo que o app abre.

Por isso os links internos são absolutos (`/`, `/en`, `/privacy-policy`): escritos como
`privacy-policy/index.html` eles funcionariam, mas cada clique pagaria um redirecionamento e a barra de
endereço mostraria a forma que a gente não quer. O preço é não abrir mais do disco — use o emulador.

Para revisar antes de publicar, dá para usar um canal temporário em vez do site principal:

```bash
cd packages/kazi_landing && firebase hosting:channel:deploy revisao -P staging
```

## Antes de publicar

1. **Domínio de produção**: `environments['prod']` já aponta para `https://kazipro.io`; falta conectar o domínio
   em Hosting → Adicionar domínio personalizado, no projeto `my-services-2703`. Enquanto isso não acontecer, o
   link da política que o app abre (`AppUrls.privacyPolicy`) não responde.
2. **Selos das lojas**: os botões são próprios da marca. Se preferir os selos oficiais, as regras de uso estão em
   https://play.google.com/intl/pt-BR/badges/ e https://developer.apple.com/app-store/marketing/guidelines/
3. **Botão do iOS**: está como `<button disabled>`. Quando o app sair, troque no template por um `<a>` com a mesma
   classe `store` e a variante `store--light` (hero) ou `store--dark` (chamada final).
4. **Rodapé**: Política de privacidade aponta para a página gerada e Contato para o e-mail da ARB
   (`contactEmail`). Só Termos de uso continua em `#`, à espera da página.
5. **Imagem de compartilhamento**: se quiser prévia em WhatsApp e redes, adicione uma imagem 1200×630 e a tag
   `<meta property="og:image" content="{{_canonical}}og.png">` no `<head>` do template.

## Telas do app

As telas são screenshots do [kazi_mockups](../kazi_mockups), não HTML: cada `<div class="phone">` do template
tem só uma `<img class="screen">` com `src="{{_screens}}<tela>.webp"`, e `_screens` aponta para
`/assets/screens/<idioma>/`. Cada idioma mostra a versão local do mockup (`pt` ← `pt-BR`, `en` ← `en-US`,
`es` ← `es-PY`, em guaranis).

| Seção | Tela |
|---|---|
| hero e "Início" | `01_home` |
| "Detalhe do serviço" | `07_service_details` |
| "Serviços · lista" | `02_services_list` |
| "Serviços · resumo" | `03_services_summary` |

Para atualizar, gere os mockups e exporte os WebP (720 px de largura, 2x do maior tamanho em que a tela
aparece):

```bash
cd packages/kazi_mockups/generator
python3 render.py      # PNGs 1080×2160 para as lojas; copie para ../<locale>/
python3 landing.py     # WebP em ../../kazi_landing/assets/screens/<idioma>/ (precisa de Pillow)
```

O texto alternativo de cada tela (`ariaHome`, `ariaDetail`, `ariaList`, `ariaSummary`) descreve os números do
mockup. Se os dados de exemplo em `data.py` mudarem, atualize esses textos nos três dicionários.
