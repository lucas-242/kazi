# Kazi — landing page

Site estático, sem build: abra `index.html` no navegador ou envie a pasta inteira para qualquer hospedagem estática (Netlify, Vercel, GitHub Pages, Firebase Hosting, S3).

## Estrutura

    index.html          página única, responsiva (desktop, tablet e celular)
    assets/styles.css   todos os estilos; tokens do Brandbook v1 no topo (:root)
    assets/favicon.svg  ícone do app (símbolo grafite sobre amarelo)

Fontes: Archivo, IBM Plex Sans e IBM Plex Mono, carregadas do Google Fonts.

## Antes de publicar

1. **Link da Play Store** — troque `SEU_PACOTE` pelo package name do app (aparece 2 vezes no `index.html`).
2. **Selos das lojas** — os botões são próprios da marca. Se preferir os selos oficiais, as regras de uso estão em
   https://play.google.com/intl/pt-BR/badges/ e https://developer.apple.com/app-store/marketing/guidelines/
3. **Botão do iOS** — está como `<button disabled>`. Quando o app sair, troque por um `<a>` com a mesma classe
   `store` e a variante `store--light` (hero) / `store--dark` (chamada final).
4. **Rodapé** — Política de privacidade, Termos de uso e Contato apontam para `#`.
5. **Imagem de compartilhamento** — se quiser prévia em WhatsApp/redes, adicione uma imagem 1200×630 e a tag
   `<meta property="og:image" content="https://seu-dominio/og.png">` no `<head>`.

## Telas do app

As quatro telas (Início, Detalhe do serviço, Lista e Resumo) são desenhadas em HTML/CSS dentro do `index.html`
(blocos `<div class="phone">`), com dados de exemplo. Para usar screenshots reais, substitua o conteúdo de cada
`<div class="phone-slot">` por uma imagem 300×620 (ou proporcional):

    <div class="phone-slot"><img src="assets/tela-inicio.png" width="300" height="620" alt="…"></div>

e adicione ao CSS: `.phone-slot img { width: 100%; height: 100%; border-radius: 46px; }`
