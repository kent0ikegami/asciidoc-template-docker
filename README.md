
# asciidoc-template

Asciidoc を使った仕様書の構成管理・CI/CD環境の雛形です。

この[記事](https://qiita.com/ynitto/items/fa44aae90c927e52613c)を参考にしています。


## 導入

git
vscode
npm

vscode拡張
```
{
  "recommendations": [
    "asciidoctor.asciidoctor-vscode",
    "taichi.vscode-textlint",
    "ms-vscode.live-server",
    "hediet.vscode-drawio"
  ]
}
```

```
npm run install
```

## ダイアグラム

ダイアグラムの作成にkrokiを使用します。
vscodeのasciidoctorの設定で、"asciidoc.extensions.enableKroki": true, とします。

https://kroki.io のサーバを利用する場合は、index.adocから以下の行を削除してください。

```
:kroki-server-url: http://localhost:8000
```

ローカルのkrokiサーバを利用する場合は、以下のコマンドでサーバを立ち上げてください。

```
docker run -p8000:8000 yuzutech/kroki
```

vscodeのasciidoctorの設定で、Change Preview Security Settings → Allow insecure local content　としてください。プレビュー時のローカルのhttp通信を許可します。

## License

MIT License

Copyright (c) 2022 @kent0ikegami <add aws deploy settings> https://github.com/kent0ikegami/asciidoc-template

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