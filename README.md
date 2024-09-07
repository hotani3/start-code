# start-code
これからプログラミングを始める方が、素早く開発環境を構築するための、セットアップスクリプト集です。  
Shell scripts to setup build and runtime environments with version managers for a starter.

Here is English version of [README](./README_en.md).

## 背景
現在では、複数アプリケーションを並行開発できるように、1台の開発マシンに複数バージョンの開発・実行環境をインストールし、アプリケーションごとに切り替えて使用することが常識的です。

また、アプリケーションで使用する外部ライブラリであるパッケージも、ローカルなアプリケーション（プロジェクト）の領域で管理すべきで、グローバルな開発・実行環境の領域にインストールすべきではありません。

これら2点を実現するため、言語ごとにバージョン管理ツールやパッケージ管理ツールが提供されていますが、複数ツールを導入するのが手間だったり、パッケージ依存関係の問題がしばしば発生したりと、必ずしもセットアップが容易とは言えませんでした。

こうした理由から、手軽にこれらツールをセットアップでき、素早くプログラミングが始められるスクリプトを作成しました。

## システム要件
現時点で、動作確認を行なっているプラットフォームはmacOSのみです。

| プラットフォーム | CPUアーキテクチャー | OSバージョン |
| :--- | :--- | :--- |
| macOS | x86_64 (Intel), ARM64 (Apple Silicon) | Monterey, Ventura, Sonoma |

## プログラミング言語
現時点で、本スクリプトが対象としているプログラミング言語は、Pythonのみです。

各言語のバージョン管理ツール、パッケージ管理ツールは次の通りです。バージョン管理ツールは、言語ごとに標準的なものを1つ選択しています。

| 言語 | バージョン管理ツール | 実行環境バージョン | パッケージ管理ツール |
| :--- | :--- | :--- | :--- |
| Python | pyenv | 3.9.x, 3.10.x, 3.11.x, 3.12.x | venv+pip, Pipenv, Poetry |

## 実行方法
まず最初に、macOSのターミナルを開き、本リポジトリをクローンします。
```sh
git clone https://github.com/hotani3/start-code.git
```

まだgitコマンドがインストール済みでないときは、[Releases](https://github.com/hotani3/start-code/releases)からZIPファイルをダウンロードし、展開します。
```sh
unzip start-code.zip
```

次に、クローンまたはZIP展開したディレクトリに移動します。
```sh
cd start-code
```

そして、各言語のセットアップスクリプトを実行します。  
スクリプトは必ず、「start-code」ディレクトリにいる状態で実行してください。
```sh
./macos/install/python.sh -v 3.12.5
```

`-v`オプションで開発・実行環境バージョンが指定可能です。  
指定しなかった場合は、Python 3.12.5がインストールされます。

スクリプト実行直後、次のようにパスワード入力を促されたときは、Macログインユーザーのパスワードを入力してください。

<img src="./images/password-prompt.png" width="800px" alt="パスワード入力" />

しばらく待ち、ターミナルに以下のようなログが出力されれば、Python実行環境のインストールに成功しています。
```sh
[2024-09-03 22:57:35] python.sh: Successfully installed Python!
[2024-09-03 22:57:36] python.sh: Detected Python 3.12.5
```

Python標準のvenv+pipではなく、PipenvやPoetryでパッケージ管理を行う場合は、`python.sh`の代わりに、次のスクリプトを実行してください。

#### Pipenv
```sh
./macos/install/python-pipenv.sh -v 3.12.5
```

#### Poetry
```sh
./macos/install/python-poetry.sh -v 3.12.5
```

上記の例では、Python 3.12.5がインストールされ、さらにPipenvまたはPoetryがインストールされます。  
いずれの場合も、`-v`オプションはPython実行環境のバージョンです。PipenvやPoetryのバージョンではないことに注意してください。

なお、Pipenvは`-v`で指定されたバージョンに加えて、`pyenv global`で指定された現在選択中のバージョンにもインストールされます。

最後に、ターミナルで新規ウィンドウまたは新規タブを開くか、もしくは現在のターミナルで次のように`.zshrc`の再読み込みを行うと、各ツールが使えるようになります。

```sh
source ~/.zshrc
```

## 補足説明：追加・更新されるパッケージと設定ファイル
本スクリプトを実行すると、バージョン管理ツール、開発・実行環境、パッケージ管理ツールの動作のため、必要に応じて以下のパッケージが自動でダウンロード、インストールされます。

#### macOS
- Xcode Command Line Tools
- Homebrew
- OpenSSL
- XZ Utils

加えて、環境変数やプログラム実行パスの設定を行うため、必要に応じて以下の設定ファイルも自動更新されます。

#### macOS
- ~/.zprofile
- ~/.zshrc

このため、各ツールの動作に必要なパッケージの手動インストールや、環境変数の手動設定は不要です。

## 参考情報
#### Python
- [pyenv, virtualenv, pipenv, poetry の概要](https://blog.serverworks.co.jp/pyenv-virtualenv-pipenv-poetry)
- [Pipenvを使ったPython開発まとめ](https://qiita.com/y-tsutsu/items/54c10e0b2c6b565c887a)
- [Poetryをサクッと使い始めてみる](https://qiita.com/ksato9700/items/b893cf1db83605898d8a)