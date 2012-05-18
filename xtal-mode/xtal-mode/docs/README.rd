=begin

= xtal-mode - Xtal 言語のメジャーモード

  * Author: みやむこ かつゆき ((<URL:mailto:miyamuko@gmail.com>))
  * Home URL: ((<URL:http://miyamuko.s56.xrea.com/xyzzy/xtal-mode/intro.htm>))
  * Version: 0.0.5


== DESCRIPTION

xtal-mode は ((<Xtal|URL:http://code.google.com/p/xtal-language/>))
言語を編集するためのメジャーモードです。

以下の機能を提供します。

  * キーワード・組み込み関数・メソッドの色づけ
  * キーワード・組み込み関数・メソッドの補完
  * 自動インデント
  * クラス・メソッドの一覧
  * 文単位 (クラス・メソッド・文など) での移動・編集
  * タグジャンプ
  * xtal の実行
  * ix の実行


== INSTALL

=== NetInstaller でインストール

(1) NetInstaller で xtal-mode をインストールしてください。

(2) ((*ni-autoload を利用していない場合*))は、
    ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加してください。

        ;; xtal-mode
        (require "xtal-mode")
        (pushnew '("\\.xtal$" . xtal-mode) *auto-mode-alist* :test 'equal)

    ni-autoload を利用している場合は追加する必要はありません。

(3) 同じように xtal のインストールディレクトリを設定してください。

        ;; xtal のインストール先
        (setf *xtal-install-path* "c:/Program Files/xtal/")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) 拡張子が .xtal のファイルを開くと xtal-mode に移行します。

=== NetInstaller を使わずにインストール

(1) アーカイブをダウンロードします。

    ((<URL:http://miyamuko.s56.xrea.com/xyzzy/archives/xtal-mode.zip>))

(2) アーカイブを展開して、$XYZZY 配下にファイルをコピーします。

(3) ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを追加します。

        ;; xtal-mode
        (require "xtal-mode")
        (pushnew '("\\.xtal$" . xtal-mode) *auto-mode-alist* :test 'equal)
        ;; xtal のインストール先
        (setf *xtal-install-path* "c:/Program Files/xtal/")

(4) 設定を反映させるため xyzzy を再起動してください。

    ※siteinit.l に記述した場合には再ダンプが必要です。

(5) 拡張子が .xtal のファイルを開くと xtal-mode に移行します。



== MODULE

=== PACKAGE

xtal-mode は以下のパッケージを利用しています。

  * xtal-mode

xtal-mode パッケージからは以下の変数・関数を export しています。

また、xtal-mode パッケージはデフォルトで user および editor パッケージから use されます。


=== VARIABLE

--- *xtal-mode-map*
    xtal-mode のキーマップ

--- *xtal-mode-syntax-table*
    xtal-mode のシンタックステーブル

--- *xtal-mode-hook*
    xtal-mode 実行時に呼ばれるフック

--- *xtal-create-output-buffer-hook*
    xtal コマンドの実行結果バッファ作成時に呼ばれるフック

--- *xtal-before-run-xtal-hook*
    xtal コマンド実行直前に呼ばれるフック

--- *xtal-run-xtal-hook*
    xtal コマンド実行開始時に呼ばれるフック。引数は xtal.exe の process

--- *xtal-after-run-xtal-hook*
    xtal コマンドの実行が終了したときに呼ばれるフック。引数は xtal.exe の process

--- *xtal-comment-column*
    indent-for-comment で挿入するコメントの開始位置

--- *xtal-indent-level*
    インデントレベル (デフォルト: 4)

      ;; インデントレベルを 2 にする
      (setf *xtal-indent-level* 2)

--- *xtal-electric-insert-close-parentheses*
    対応する閉じ括弧を自動的に挿入する場合 non-nil (デフォルト: t)

--- *xtal-electric-insert-close-string*
    文字列を自動的に閉じる場合 non-nil (デフォルト: t)

--- *xtal-keyword-file*
    キーワードファイル名 (デフォルト: Xtal)。

    $XYZZY/etc 配下のファイル名を指定。

--- *xtal-install-path*
    Xtal のインストールパス。

    この値は必ず設定してください。

        (setf *xtal-install-path* "d:/usr/local/xtal")

--- *xtal-command-xtal*
    xtal.exe のパス (デフォルト: "xtal.exe")。

    相対パスの場合 ((<*xtal-install-path*>)) から探します。

--- *xtal-command-ix*
    ix.exe のパス (デフォルト: "ix.exe")。

    相対パスの場合 ((<*xtal-install-path*>)) から探します。

--- *xtal-mode-output-buffer-name*
    xtal コマンドの実行結果バッファの名前 (デフォルト: "*Xtal*")

--- *xtal-command-output-window-height*
    xtal の実行結果を表示するウィンドウの高さ (デフォルト -10)

--- *xtal-ix-buffer-name*
    ix を実行するバッファの名前 (デフォルト: "*ix*")

--- *xtal-ix-window-height*
    ix を実行するウィンドウの高さ (デフォルト: -20)

--- *xtal-online-reference-url*
    オンラインリファレンスの URL

--- *xtal-home-url*
    Home URL


=== COMMAND

--- xtal-mode

    バッファを Xtal 編集モードにします。

--- xtal-completion

    デフォルトキーバインド: ((%M-TAB%))

    Xtal のキーワード、メソッド名を補完します。

--- xtal-indent-buffer

    デフォルトキーバインド: ((%C-c C-\%))

    バッファ全体をインデントします。

--- xtal-comment-region

    デフォルトキーバインド: ((%C-c C-9%))

    リージョンをコメントアウトします。

--- xtal-uncomment-region

    デフォルトキーバインド: ((%C-c C-8%))

    リージョンをコメントを解除します。

--- xtal-toggle-comment-line

    デフォルトキーバインド: ((%C-c C-/%))

    カーソル行の 1 行コメントを切り替えます。

--- xtal-run-with-current-buffer

    デフォルトキーバインド: ((%C-c C-x%))

    編集中のバッファを xtal で実行します。

    * ファイルを保存していない場合は、ファイルに保存してから実行します。
    * ファイル名が存在しない場合は、一時ファイルに保存してから実行します。

--- xtal-first-error

    デフォルトキーバインド: ((%F10%))

    Xtal を実行結果の最初のエラーに移動します。

    その後、F11 を押すことで次のエラーに移動できます。

--- xtal-close-output-buffer

    デフォルトキーバインド: ((%C-c 0%))

    Xtal の実行結果をバッファを削除します。

--- ix

    デフォルトキーバインド: ((%C-c 1%))

    ix を xyzzy 内部で実行します。
    ix バッファの操作方法は ((<ix-mode>)) を参照してください。

--- ix-console

    デフォルトキーバインド: ((%C-c !%))

    コマンドプロンプトで ix を起動します。

--- xtal-mark-statement

    デフォルトキーバインド: ((%M-SPC%))

    カーソルがある行の文全体をマークします。

    例:

      ●Hello: class {
      ▲    world: method() {
                say("World!");
            }
            say: method(name) {
                print("Hello, " ~ name);
            }
        }

    * ●にカーソルを置いて実行すると Hello クラス全体をマークします。
    * ▲にカーソルを置いて実行すると world メソッド全体をマークします。

--- xtal-forward-statement

    デフォルトキーバインド: ((%C-M-n%))

    次の文に移動します。

    例:

      Hello: class {
        ●world: method() {
            ▲say("World!");
          }
        ■say: method(name) {
              print("Hello, " ~ name);
          }
      }

    * ●にカーソルを置いて実行すると say() の先頭 (▲) に移動します。
    * もう一度実行すると say method の先頭 (■) に移動します。

--- xtal-backward-statement

    デフォルトキーバインド: ((%C-M-p%))

    前の文に移動します。

--- xtal-forward-statement-in-scope

    デフォルトキーバインド: ((%C-M-j%))

    同一のスコープ内で次の文に移動します。

    例:

      Hello: class {
        ●world: method() {
              say("World!");
          }
        ▲say: method(name) {
              print("Hello, " ~ name);
          }
      }

    * ●にカーソルを置いて実行すると say method の先頭 (▲) に移動します。
    * もう一度実行するとカーソルは移動しません。

--- xtal-backward-statement-in-scope

    デフォルトキーバインド: ((%C-M-k%))

    同一のスコープ内で前の文に移動します。

--- xtal-up-statement

    デフォルトキーバインド: ((%C-M-u%))

    ひとつ上のスコープに移動します。

    例:

      ■Hello: class {
            world: method() {
                say("World!");
            }
          ▲say: method(name) {
              ●print("Hello, " ~ name);
            }
        }

    * ●にカーソルを置いて実行すると say method の先頭 (▲) に移動します。
    * もう一度実行すると Hello クラスの先頭 (■) に移動します。

--- xtal-down-statement

    デフォルトキーバインド: ((%C-c 0%))

    ひとつ下のスコープに移動します。

    例:

      ●Hello: class {
          ▲world: method() {
              ■say("World!");
            }
            say: method(name) {
                print("Hello, " ~ name);
            }
        }

    * ●にカーソルを置いて実行すると world method の先頭 (▲) に移動します。
    * もう一度実行すると say() の先頭 (■) に移動します。

--- xtal-transpose-statement

    デフォルトキーバインド: ((%C-M-t%))

    文と文の間で実行すると文を入れ替えます。
    クラスやメソッド単位で入れ替えることができます。

    文内部で実行するとカーソル前後の式を入れ替えます (通常の transpose-sexp ど同じ)。

    例:

        Hello: class {
            world: method() {
                say("World!");
            }
            ●
            say: method(name) {
                print("Hello,"▲ ~ name);
            }
        }

    * ●にカーソルを置いて実行すると world メソッドと say メソッドが入れ替わります。
    * ▲にカーソルを置いて実行すると "Hello, " と name が入れ替わります。

    例 2:

    xtal-transpose-statement は if と else if のみ特別な処理をします
    (if と else の入れ替えは何も考えず入れ替えるだけ)。

        if (a == 1) {
          hello();
        }●else if (a == 2) {
          world();
        }

    ●にカーソルを置いて実行すると以下のようになります。

        if (a == 2) {
            world();
        } else if (a == 1) {
            hello();
        }

--- xtal-open-install-path-by-command-prompt

    ((<*xtal-install-path*>)) で設定したディレクトリを
    コマンドプロンプトで開きます。

--- xtal-open-install-path-by-explorer

    ((<*xtal-install-path*>)) で設定したディレクトリを
    エクスプローラで開きます。

--- xtal-track-popup-menu

    xtal-mode のメニューをポップアップ表示します。

--- xtal-mode-show-credit

    xtal-mode のバージョンを表示します。


=== FUNCTION

--- xtal-add-bookmark-menu tag name file-or-url

    指定したファイルや URL を開くメニュー項目を Xtal メニューに追加する関数です。

    メニュー項目はバージョン番号の上に追加されます。

    * tag にはメニュー項目をあとから識別できるようにする値を指定します。nil でもかまいません。
    * name にはメニューに表示する名前を指定します。
    * file-or-url にはファイルパスまたは URL を文字列で指定します。
      file-or-url は shell-execute で実行されます。

    例:

        ;; Xtgl の HTML ヘルプをメニューに追加。
        ;; xtal.chm は xtal.exe と同じ場所においておく。
        (xtal-add-bookmark-menu :chm "Xtal リファレンス (&C)"
                                (merge-pathnames "xtal.chm" *xtal-install-path*))

--- goto-matched-multi-line-comment

    対応する複数行コメントの開始・終了位置に移動します。

    * 「/*」の近くで実行した場合対応する「*/」に移動します。
    * 「*/」の近くで実行した場合対応する「/*」に移動します。

--- goto-beginning-of-multi-line-comment

    複数行コメントの開始 (/*) に移動します。

--- goto-end-of-multi-line-comment

    複数行コメントの終了 (*/) に移動します。

--- xtal-comment-line-p

    現在行がコメント行なら t を返します。

--- xtal-in-comment-p

    カーソルのある位置が 1 行コメントまたは複数行コメントなら t を返します。

--- xtal-in-multiline-comment-p

    カーソルのある位置が複数行コメントなら t を返します。
    1 行コメントの場合は nil を返します。

--- xtal-in-shebang-comment-p

    カーソルのある位置が「#!」で始まるコメント行なら t を返します。

--- xtal-parse-point-syntax

    「#!」コメントに対応した parse-point-syntax です。

--- xtal-mode-version

    xtal-mode のバージョンを返します。

    バージョンは major.minor.teeny という形式です。
    それぞれの番号は必ず 1 桁にするので、以下のように比較することができます

        (if (string<= "1.1.0" (xtal-mode-version))
            (1.1.0 以降で有効な処理)
          (1.1.0 より前のバージョンでの処理))


== ix-mode

xyzzy のバッファ内で ix を起動 (((<ix>))) すると ix-mode になります。

ix-mode では以下のキーが定義されています。

: RET
    入力しているコマンドを ix に送ります。

: C-c C-c
    ix を停止します。

: C-c 0
    ix を停止し、バッファを閉じます。

: C-p
    過去に入力した ix コマンドの履歴を挿入します。
    連続して実行することで履歴を古い方へさかのぼって行きます。

: C-n
    過去に入力した ix コマンドの履歴を挿入します。
    連続して実行することで履歴を新しい方へさかのぼって行きます。

: C-M-p
    一つ前のプロンプトに移動します。

    過去のプロンプトで Enter を押すとそのコマンドを再実行できます。
    入力中のコマンドは保存されます (M-q と同じ)。

: C-M-n
    一つ後のプロンプトに移動します。

: M-q
    現在入力中のコマンドを保存して入力行をクリアします。

    他のコマンドを実行すると次のプロンプトには保存した入力行が自動的に挿入されます。


== TODO

* lib:foo から foo.xtal を開く
* xtal-mode
  * xtal 実行時に引数の指定（前置引数）
* xtal
  * 外部プログラムとして xtal.exe を実行。
    * 必要?
* ix
  * カーソル移動系の前置引数
  * 現在のクラスを送る
  * 現在のメソッドを送る
  * ヒストリ
    * ヒストリの編集
    * ヒストリの一覧
      * popup
    * !23
    * ヒストリ検索 (C-r)
    * 複数行
      * 文が終了しているかどうかの判定を自前で
      * zsh
      * inferior-ruby-mode
  * //=> 形式で実行結果の挿入
  * 入力行をまとめてバッファに変換
* 外部 ix
  * ウィンドウの管理
    * xyzzy の子プロセス
    * 閉じる
    * forground
    * 2重起動防止
    * ウィンドウの切り替え
  * 現在のxxxを送る
    * clipborad 経由?
* コンテキストに応じた補完
  * math:: の後なら math のメソッドだけ, ::?
  * . のあとならメソッドだけ, .?
  * 前になにもないなら、
  * 数値リテラル、文字列リテラルのあと
  * クラス名を明示した補完
* HTML Help
  * ウィンドウ位置の保存
  * キーワード検索
* ソースの整理
  * 階層化
* iterator のクラステンプレートの挿入
  * iter_first, iter_next, iter_break
* 複数の xtal の切り替え
  * menu
  * history
* 行末に ~ や + がある場合のインデント
* lambda 式のインデント


== KNOWN BUGS

なし。


== AUTHOR

みやむこ かつゆき (((<URL:mailto:miyamuko@gmail.com>)))


== SEE ALSO

  : Xtal Language
        ((<URL:http://code.google.com/p/xtal-language/>))

  : Xtal オンラインリファレンス
        ((<URL:http://www.h5.dion.ne.jp/~putora/xtal_doc/>))


== COPYRIGHT

xtal-mode は MIT/X ライセンスに基づいて利用可能です。

See xtal-mode/docs/MIT-LICENSE for full license.


== NEWS

<<<NEWS.rd

=end
