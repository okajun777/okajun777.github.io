# okajun777.github.io

Threads のプロフィール用リンク集サイト。公開先: https://okajun777.github.io/

## アクセス解析（Google タグマネージャー → GA4）

`index.html` には GTM コンテナ `GTM-WJ7WBB2T` が入っています。GA4 にデータを送る設定は GTM 側で行います。

### 1. 訪問者数（ページビュー）
1. GTM で「タグ」→「新規」→ タグの種類「Google タグ」
2. タグ ID に GA4 の測定ID（`G-` から始まる）を入れる
3. トリガー「Initialization - All Pages」（または All Pages）を選んで保存

### 2. リンクごとのクリック数
ページはリンクが押されるたびに dataLayer へ次を送ります:
`{ event: "link_click", link_text, link_url, link_section }`

1. 「変数」→ ユーザー定義変数 →「データレイヤーの変数」で `link_text` / `link_url` / `link_section` の3つを作成
2. 「トリガー」→ 新規 →「カスタム イベント」、イベント名 `link_click`
3. 「タグ」→ 新規 →「Google アナリティクス: GA4 イベント」
   - 測定ID: 上と同じ `G-…`、イベント名: `link_click`
   - イベントパラメータに `link_text` `link_url` `link_section` を、それぞれ上の変数で追加
   - トリガー: 手順2のトリガー
4. 右上の「公開」で反映
5. GA4 の「管理 > カスタム定義」で `link_text` と `link_section` をイベントスコープのカスタムディメンションに登録すると、レポートでリンク名ごとに見られます
