# okajun777.github.io

Threads のプロフィール用リンク集サイト。公開先: https://okajun777.github.io/

## アクセス解析（Google アナリティクス4）

1. https://analytics.google.com/ でプロパティとウェブストリーム（URL: `https://okajun777.github.io`）を作成
2. 表示された「測定ID」（`G-` から始まる）をコピー
3. `index.html` の `window.GA_ID = "G-XXXXXXXXXX";` を自分の測定IDに書き換えて push

計測される内容:
- 訪問者数・ページビュー・参照元（Threads など）・端末・地域（GA4 標準）
- リンクごとのクリック数: イベント名 `link_click`（パラメータ `link_text` / `link_url` / `link_section`）
  - GA4 の「管理 > カスタム定義」で `link_text` と `link_section` をイベントスコープのカスタムディメンションに登録すると、レポートでリンク名ごとに見られます
