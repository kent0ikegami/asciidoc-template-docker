
# asciidoc-template-docker

Asciidoc を使った仕様書の構成管理・CI/CD環境の雛形です。

この[記事](https://qiita.com/ynitto/items/fa44aae90c927e52613c)がベースになっています。


## 導入

- vscodeとその拡張
- git
- npm
- docker

が必要です。

gitはバージョン管理と、github actionでアクションを発火させるために使います。それらがいらない場合は不要です。

npm環境はtextlintで使います。textlintをローカルでもgithub上でもしない場合は不要です。

dockerはローカルでビルドするために使います。ビルドはgithub actions上だけでよければ不要です。


vscode拡張
```json
{
  "recommendations": [
    "asciidoctor.asciidoctor-vscode",
    "taichi.vscode-textlint",
    "ms-vscode.live-server",
    "hediet.vscode-drawio"
  ]
}
```

textlint用のライブラリ導入
```sh
npm run install
```

## ダイアグラム

ダイアグラムの作成にkrokiを使用します。
vscodeのasciidoctorの設定で、`"asciidoc.extensions.enableKroki": true, ` と設定します。

デフォルトでは https://kroki.io のサーバにダイアグラムの情報を送信して画像を生成します。

ネットワークが繋がらない環境であったり、セキュリティ上問題になりそうな場合は、ローカルにkrokiサーバを立てて利用することもできます。

ローカルのkrokiサーバを利用する場合は、以下のコマンドでサーバを立ち上げてください。

```sh
docker run -p8000:8000 yuzutech/kroki
```

vscodeのasciidoctorの設定で、`Change Preview Security Settings → Allow insecure local content`　としてください。このオプションでプレビュー時のローカルhttp通信を許可します。


ローカルサーバを利用する場合のURLの設定はindex.adocにあります。

```
:kroki-server-url: http://localhost:8000
```






## ローカルビルド

ローカルでhtmlとpdfを作成するのには、公式のdockerイメージをラップした、`./Dockerfile` を使います。

```sh
# 初回だけ
docker build . -t asciidoc-local

docker run -it -v $(pwd):/documents/ asciidoc-local
```

出力処理は `./.github/workflows/asciidoc.sh ` にあります。

日本語を含んだSVGをpdfに埋め込むと文字化けする問題が2点あり、その対策が含まれています。

- plantUMLで作図されたSVGが文字化ける問題の対策 -> patch-prawn.rb でフォントファミリーを置き換え

- drawioで作図されたSVGが文字化ける問題の対策 -> sed -i でフォントファミリーを置き換え



## デプロイ

github pagesに設置するワークフロー `run-deploy-github-pages.yml` と aws s3　に設置(とついでにcloudfrontのキャッシュを作り直し)するワークフロー `run-deploy-aws.yml` があります。

### run-deploy-github-pages.yml

初回プルリクエストマージ後、`gh-pages`というブランチがリモートに作られます。

github -> Settings -> Pages の中で、Build and deploymentという項目の Branchという項目で、`gh-pages`を指定してください。

### run-deploy-aws.yml

AWS側の設定は以下の流れになります。

- S3バケットを非公開で作成
- CloudForntのディストリビューションを作成(IAMユーザ以外にアクセスさせたい場合)
  - オリジンドメインを先ほどのS3バケットに設定
  - 代替ドメイン名を設定(独自ドメインを使いたい場合)
  - カスタム SSL 証明書を設定
    - us-east-1リージョンのACMで使用したい代替ドメインの証明書が発行されている必要があります。
- S3のバケットにポリシーを設定(IAMユーザ以外にアクセスさせたい場合)
  - アクセス許可 -> バケットポリシー に以下を設定します。

```json
{
  "Version": "2008-10-17",
  "Id": "PolicyForCloudFrontPrivateContent",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServicePrincipal",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::バケット名/*",
      "Condition": {
        "StringEquals": {
        "AWS:SourceArn": "CloudFrontのディストリビューションのARN"
        }
      }
    }
  ]
}
```
- github action用のポリシーを作成します。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "cloudfront:CreateInvalidation"
      ],
      "Resource": [
        "CloudFrontのディストリビューションのARN",
        "arn:aws:s3:::バケット名/*",
        "arn:aws:s3:::バケット名"
      ]
    }
  ]
}
```
- 上記ポリシーをアタッチしたグループを作成します
- 上記グループに所属したIAMユーザー(アクセスキーとシークレットキーの発行)を作成します

repository secretで以下の値の設定をします。

```
  AWS_S3_BUCKET: バケット名
  DISTRIBUTION: CloudFrontのディストリビューション名 ※CloudFrontを使う場合
  AWS_ACCESS_KEY_ID: 
  AWS_SECRET_ACCESS_KEY: 
```

CloudFrontの関数を利用することで、Basic認証や、CognitoのHostedUIを使った認証を入れることもできます。



## 運用例

GitFlowを想定しています。

詳細な解説は[@ynitto様の記事](https://qiita.com/ynitto/items/569de7073f476d588d36)を参照してください。

### feature

1. メンバーはdevelopからfeature/Aブランチを生やす
2. メンバーは担当部分を追記してfeature/Aブランチを push し、developブランチへの pull request を作る
3. リーダーが pull request を確認してレビューする。指摘事項はコメントで残す。
4. リーダーがレビュー完了 (指摘事項が対応済み) を確認したらマージする

### release

1. リーダーは仕様書をリリースするタイミングでdevelopからrelease/x.y.zブランチを生やす
1. リーダーやメンバーはrelease/x.y.zブランチに対して、記載不備の修正など校正する。このとき仕様書のバージョンを上げる。
1. リーダーはrelease/x.y.zブランチを push し、developブランチへの pull request を作る
1. リーダーは pull request を確認してマージする
1. リーダーはrelease/x.y.zブランチを push し、mainブランチへの pull request を作る
1. リーダーは pull request を確認してマージする

### その他

デプロイのタイミングは以下。

- 開発中である程度追記が完了したタイミング
今回のフローではfeature/Aブランチがdevelopにマージされたタイミング。製本した成果物は中間データのため、バージョン管理する必要はない。現在の最新の状態が見れればよい。

- 正式版としてリリースするタイミング
 今回のフローではrelease/x.y.zブランチがmainにマージされたタイミング。製本した成果物はバージョン管理していつでも見返せる状態にしたい。

運用に応じてgithubのworkflowファイルの`on:`と`if`を調節してください。


## License

MIT License

Copyright (c) 2022 @kent0ikegami <modify> https://github.com/kent0ikegami/asciidoc-template-docker

Copyright (c) 2022 @ynitto <original> https://github.com/ynitto/asciidoc-template

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## sample
