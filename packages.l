("name" . "NAXEL")
("author" . "mumurik765, etc.")
("url" . "https://github.com/mumurik/NAXEL")
("description" . "Network Archive for Xyzzy Extending Lisp.")
("packages"
 (("name" . "Browser.dll") ("version" . "1.1") ("author" . "mumurik765") ("file" . "browser-1.1.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/browser-1.1.zip") ("description" . "Browser.dllをスクラッチから書き直しました。") ("category" "Network") ("md5" . "a4adc3647fc83c21c1327102ad1cc75a") ("time" . 3542562710) ("depends") ("changes" . "browserexでクラッシュするのを修正。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ac-mode") ("md5" . "b6780b9437452eafe588cb4498b94447") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fac-mode&openfile=ac-mode-2007.12.21.zip") ("version" . "2007.12.21") ("author" . "snj14") ("file" . "ac-mode-2007.12.21.zip") ("description" . " - paren,rv-region,セレクションの有無,直前に実行したコマンド を考慮したインデント\n - snippetの展開\n - (URI|ファイル名|abbrev|lispの関数,変数|バッファ内の関数,変数|Keyword|XTAGS|dabbrev)\n   のインクリメンタルな補完\n をC-i(TAB)のみで行えるようにするマイナーモードです。\n snippetの展開には別途snippet.lが必要です。\n\n インテリジェント補完コマンド ac-mode\n http://taiyaki.org/elisp/ac-mode/\n の説明から想像で実装し、便利そうな機能を追加したものです。\n \n \n また、いくつかの補完には専用のコマンドもあり、\n 文字を入力せずに補完することや、\n (complete+が入っていれば)部分一致/スキップマッチも可能です。\n ") ("time" . 3407169979) ("depends" nil) ("category" "Editing" ) ("changes" . "補完はカーソルが単語の上 or 末尾にあるときのみにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ansi-loop") ("version" . "1.0.1") ("author" . "MIYAMUKO Katsuyuki") ("file" . "ansi-loop.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/ansi-loop.zip") ("description" . "ansi-loop は Macintosh Common Lisp ( http://code.google.com/p/mcl/ ) の
loop マクロ (loop.lisp と extended-loop.lisp) を xyzzy に移植したものです。

xyzzy 付属の cmu_loop.l は少しバグっているので、Common Lisp のライブラリを移植する場合などに
不都合が生じる場合がありますが、ansi-loop を使えば解決するかもしれません。
") ("category" "Libraries" "Development") ("md5" . "18ba7e43161985bdfb10182faec57d9d") ("time" . 3536910292) ("depends" "ansify") ("changes" . "### 2012-01-30 / 1.0.1

ansi-loop 1.0.1 リリース!

#### 新規機能

  * なし

#### 非互換を含む変更点

  * なし

#### バグ修正

  * ed:lisp-indent-hook を設定

  * destructuring-bind など一部 import し忘れていたのを修正

  * print-unreadable-object が未定義で loop-universe の
    print-function が動いていなかったのを修正

#### その他

  * ansify に依存するようになりましたのでインストールしてください。
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ansify")
 ("version" . "0.03.03")
 ("file" . "ansify-0.03.03.zip")
 ("src" . "http://bowbow99.sakura.ne.jp/xyzzy/ansify-0.03.03.zip")
 ("description" . "ANSI Common Lisp にあって xyzzy にないもの詰め合わせ")
 ("md5" . "46a1703d811a7ccec1bdd1b8f884ebab")
 ("time" . 3542021675)
 ("category" "Lisp" "Libraries")
 ("changes" . "2012-03-29  Ver. 0.03.03
========================
- リファレンスに typo や古い記述があったのを修正; thx to @youz
- リファレンスが間違って SJIS になってたのを修正; thx to @youz

2012-02-16  Ver. 0.03.02
========================
- リファレンスを生成できないのがバレたので xy-reference から見える所へ
  引っ越し; thx to @miyamuko

2012-01-09  Ver. 0.03.01
========================
- cmu_loop 使うのをやめた
- パッケージ \"compiler\" のパッケージ定義だけ同梱
  compile.l を丸ごと読み込まずに `compiler::optimize-form` を使えるように
- バグ修正など
  - ansify をダンプイメージに含めると `optimize-type-check` を利用したマクロ
    （`typecase` など）が壊れてた; thx to @miyamuko
  - `ansify:defun` のインデント情報が無かった
  - `ansify:symbol-macrolet` で `multiple-value-setq` の多値式に symbol macro
    を置くと展開されてなかった; thx to @miyamuko

2011-11-04  Ver. 0.03.00
========================
- 一部の型指定子をグローバルに修正
  - `eql` -- 不要な deftype による定義を削除（実は前のバージョンでやってた）
  - `real`, `cons` -- リストでの指定にできなかったのを修正
  この修正は lisp パッケージの方を直接修正してるのでグローバルに影響するけど
  正しく書かれたプログラムでは問題は起きないはず。
- setf function サポート
  `(setf READER)` という形式の関数名を使えるようにした。
  - `defun`
  - `fdefinition`
  - `fboundp`
  - `fmakunbound`
- 細々したオペレータを追加
  - `sleep`

2011-10-16  Ver. 0.02.00
========================
- パッケージ周りを調整
  ANSI 標準のシンボルは \"ansify\" から export して、それ以外で xyzzy/ansify
  特有の機能などは \"ansify.ext\" から export するように
  ちゃんと export するようにしたので `ansify:etypecase` とか書けるようになった
- 細々したオペレータを追加
  - `type-of`（structure に対して `lisp:structure` ではなく構造体名を返す）
  - `constantly`
  - `the`
  - `nth-value`
  - `upgraded-complex-part-type`
  - 単に名前が変わったもの
    - `special-operator-p`
    - `get-setf-expansion`
    - `define-setf-expander`
- バグ修正（主に typespec 周り）

2011-10-05  Ver. 0.01.01
========================
- バージョン変数 `ansify::+version+` を追加
- バグ2つ修正（thx to @miyamuko）

2011-09-30  Ver. 0.01.00
========================
- 初リリース
- バラバラに作ってた Common Lisp なものを集めた
  - [symbol-macrolet](https://github.com/bowbow99/xyzzy.symbol-macrolet)
  - [condition-restart](https://github.com/bowbow99/xyzzy.condition-restart)
  - [destructuring-bind](https://github.com/bowbow99/xyzzy.destructuring-bind)
  - [typespec+](https://github.com/bowbow99/xyzzy.typespec-plus)
  - [typecase](https://github.com/bowbow99/xyzzy.typecase)
- case, ecase, ccase を実装
- print-unreadable-object を実装
"))
(("name" . "approx-search") ("md5" . "06e495aefe17b77988de51a38358b739") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fapprox-search&openfile=approx-search-2007.02.15.zip") ("version" . "2007.02.15") ("author" . "shiro") ("file" . "approx-search-2007.02.15.zip") ("description" . " emacs用の曖昧検索ライブラリ approx-search.el の xyzzy移植版です\n ") ("time" . 3380454344) ("depends" . nil) ("category" "Libraries" "Text Processing" ) ("changes" . "キーボードマクロ実行時にちらつかないようにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "describe-bindings-mode") ("md5" . "affafc9fd7ce8bc8cc9bf3e4981ba0c8") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fdescribe-bindings-mode&openfile=describe-bindings-mode-2007.02.22.zip") ("version" . "2007.02.22") ("author" . "shiro") ("file" . "describe-bindings-mode-2007.02.22.zip") ("description" . " キーマップ表示(describe-bindings)に\n  * 色付け\n  * タグジャンプ\n  * qで閉じる\n  * 強制的に真ん中から上下2分割での表示\n  * 日本語の解説表示\n の機能を付けます。\n \n 日本語の解説表示にはinfo-modoki-mode + reference.txtが、\n 色付けにはlispのキーワードファイルが必要です。") ("time" . 3381086409) ("depends" . nil) ("category" "Utilities" ) ("changes" . "ミニバッファでも使えるようにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "gmark-select") ("md5" . "9a45835f673039f2546d9794a080b659") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fgmark-select&openfile=gmark-select-2007.02.22.zip") ("version" . "2007.02.22") ("author" . "shiro") ("file" . "gmark-select-2007.02.22.zip") ("description" . " 画面を分割してグローバルマークを選び、ジャンプしたり削除したりできます。") ("time" . 3381086398) ("depends" . nil) ("category" "Utilities" ) ("changes" . "gmark-select-search-forwardで次のバッファも探すようにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "paren") ("md5" . "a7d3ec008679baf596e93fca325eb500") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fparen&openfile=paren-2007.04.12.zip") ("version" . "2007.04.12") ("author" . "shiro") ("file" . "paren-2007.04.12.zip") ("description" . " KITAさん作のparen.lの改造版です\n \n 以下変更点\n  \n  - ハイライトの前後で属性を保存\n  - delete-text-attributesのタイミングの変更\n  - エスケープされている場合は動作を行わないように\n  - 指定されたコマンドの直後では動作を行わないように\n  - シンタックスがタグの場合でもハイライト(設定可)\n  - 閉じ括弧の反応する位置を1つ前にできるように(設定可)\n  - ハイライト中でも元の属性を表示し続ける(設定可)") ("time" . 3385370028) ("depends" nil) ("category" "Utilities" ) ("changes" . "連続したエスケープの直後の括弧が強調できていなかったのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "virtual-file-archive") ("md5" . "56387a8ee4febd24e324d4c46504483c") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-archive&openfile=virtual-file-archive-2007.03.23.zip") ("version" . "2007.03.23") ("author" . "shiro") ("file" . "virtual-file-archive-2007.03.23.zip") ("description" . " virtual-fileのアーカイブ用プラグイン\n \n ミニバッファで圧縮ファイルの中身を補完し、\n 読み込み時に展開し、\n 保存時に再圧縮を行います。\n filer-list-archive(ファイラ上でV)で開いたファイルも保存時の圧縮を行います。\n \n complete+ と virtual-file が必要です。\n \n 標準関数find-file-in-archiveを上書きしています。") ("time" . 3383606468) ("depends" "complete+" "virtual-file") ("category" "Utilities" "File Systems" ) ("changes" . "リストを返す関数の仕様を変更") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "virtual-file-ftp") ("md5" . "ad597d75071eee393c7119d51b8af1e1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-ftp&openfile=virtual-file-ftp-2007.03.23.zip") ("version" . "2007.03.23") ("author" . "shiro") ("file" . "virtual-file-ftp-2007.03.23.zip") ("description" . " virtual-fileのFTP用プラグイン\n \n ミニバッファでFTPに接続して補完し、\n 読み込み時に一時ファイルにダウンロードし、\n 保存時に再アップロードを行います。") ("time" . 3383607443) ("depends" "complete+" "virtual-file") ("category" "Utilities" "File Systems" ) ("changes" . "リストを返す関数の仕様を変更") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "virtual-file") ("md5" . "e3a05503a31f2a95a1d7dd11c750a0e1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file&openfile=virtual-file-2007.07.09.zip") ("version" . "2007.07.09") ("author" . "shiro") ("file" . "virtual-file-2007.07.09.zip") ("description" . " 仮想的なファイルの読み込みと保存を行うための仕組みを提供するものです。\n 単体では機能しません。\n \n virtual-file-archive.lなどをインストールしてください。\n ") ("time" . 3392896302) ("depends" "complete+" "session-ext") ("category" "Utilities" "File Systems" ) ("changes" . "時間制限付きmemoize関数を追加") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "virtual-file-pscp") ("md5" . "0681f8010d950656b769c40a246408ef") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-pscp&openfile=virtual-file-pscp-2007.07.09.zip") ("version" . "2007.07.09") ("author" . "shiro") ("file" . "virtual-file-pscp-2007.07.09.zip") ("description" . " virtual-fileのpscp.exe用プラグイン\n \n pscp.exeを経由して\n   ファイルのリストを取得\n   ファイルを取得\n   ファイルを転送\n することで\n   ミニバッファでサーバ上のファイルを補完\n   読み込み時に一時ファイルにダウンロードしバッファに読み込み\n   保存時に自動で再アップロード\n が可能になります。\n \n virtual-file-ftpと比較すると\n   scpなので通信が暗号化される\n   鍵が使えるのでパスワードをファイルに直接書かなくて済む\n   pagent.exeを使えばSOCKSも使える\n   pscp.exeを起動する時間が余計にかかる\n   (ftpの方はxyzzy lispだけで完結している)\n 等が異なります。") ("time" . 3392896696) ("depends" "complete+" "virtual-file") ("category" "Utilities" "File Systems" ) ("changes" . "初版") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "snippet") ("md5" . "214faf15c6daec0d0a833c7e699eb568") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fsnippet&openfile=snippet-2007.07.15.zip") ("version" . "2007.07.15") ("author" . "shiro") ("file" . "snippet-2007.07.15.zip") ("description" . " Abbrevで展開した後に、\n   * 指定した位置にジャンプ\n   * 編集した部分を他の場所に反映\n します。\n プログラムやHTMLなどの定型的な文を良く入力する人以外はあまり美味しくないかもしれません。\n \n TextMateで話題になっていたので勢いで実装しました。\n 詳細が良く分からないところや、しっかり考えてないところがあるので、\n いろいろと問題があるかもしれません。\n \n ac-modeと一緒に使うことを推奨。\n ") ("time" . 3393473889) ("depends" nil) ("category" "Editing" ) ("changes" . "10個以上の展開ができなかったのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "ffap") ("md5" . "72cb0dfbc51752ebc82e70400293a4b0") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fffap&openfile=ffap-2007.10.19.zip") ("version" . "2007.10.19") ("author" . "shiro") ("file" . "ffap-2007.10.19.zip") ("description" . "   emacsにあるffapの説明(http://www.bookshelf.jp/soft/meadow_23.html#SEC226)\n   をみて想像で実装したものです。\n   コードは参考にしていないのでバグや機能不足があるかもしれません。\n\n   カーソル位置周辺の文字を見てパスやURIを探し、\n   パスの場合、デフォルトの値に指定した状態でfind-fileします。\n   URIの場合、ブラウザ等で開きます。(設定可)\n   カーソル位置周辺から探せなかった場合は、\n   以前と変わらぬfind-fileをお楽しみ頂けます。\n\n   要するに (require \"ffap\") や <a href=\"../index.html\">\n   等の上でC-x C-fしたときにミニバッファが\n   Find file: c:/bin/xyzzy/site-lisp/ffap.l\n   や\n   Find file: c:/data/web/index.html\n   という状態でfind-fileを開始できるようになります。\n\n   カーソル周辺のファイル名の親ディレクトリをアクティブな側、\n   またはアクティブでない側のパスにして2画面ファイラを開く機能もあります。") ("time" . 3401731504) ("depends" nil) ("category" "Utilities" ) ("changes" . "virtual-fileからfind-fileした場合の初期ディレクトリをまともにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "complete+") ("md5" . "05b818a1c9f05b29934d8001ec8e62d1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fcomplete%2B&openfile=complete%2B-2007.12.21.zip") ("version" . "2007.12.21") ("author" . "snj14") ("file" . "complete+-2007.12.21.zip") ("description" . "   ミニバッファ等で\n    - 先頭一致/Migemo/部分一致/スキップマッチングで絞り込み、\n      かつ全ての項目に先頭一致する文字列で補完\n    - 存在するファイルでないものをファイルのように補完\n      実際にファイルを開くにはvirtual-fileやその他もろもろ(virtual-file-*.l)が必要です\n    - 大文字・小文字の区別をしたりしなかったり、大文字の時だけ区別したりする\n    - ディレクトリのスキップマッチング( c:/d/m/hoge => c:/data/music/hoge )\n    - 指定文字で区切りAND検索         ( c:/data/zip;xyz => c:/data/xyzzy.zip )\n    - インクリメンタルに補完候補を表示(補完自体は行わない)\n    - ↑を有効にしてる場合、補完できるところまでハイライトで表示\n    - *Completion*バッファの候補のマッチしてる部分を強調表示\n    - cygwin-mountと連携してcygwinのパスを補完\n    - ファイル補完時に空白ならドライブも候補に入れる\n    - C-i(TAB)やSpaceの直後の新規ファイル作成はRET2回で行なう\n   を可能にするものです\n   ") ("time" . 3407170008) ("depends" nil) ("category" "Utilities" ) ("changes" . "補完候補なしのcompleting-read中にエラーが出ていたのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "igsearch") ("md5" . "fd7282ca59a098050757241cbca648e1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Figsearch&openfile=igsearch-2008.01.06.zip") ("version" . "2008.01.06") ("author" . "snj14") ("file" . "igsearch-2008.01.06.zip") ("description" . "   インクリメンタルサーチ中に\n    - マッチした候補を反対側のウィンドウに列挙\n    - エスケープシーケンスの理解とそのトグル\n    - *case-fold-search*の値のトグル\n    - Migemo検索,曖昧検索,正規表現検索,通常検索の切り替え\n    - 検索語のハイライト\n   ができます。\n   \n   また、ミニバッファで文字入力中に実行すると\n    - 履歴の一覧を表示\n    - 履歴のインクリメンタルサーチ\n    - 履歴の削除\n   ができます。\n   ") ("time" . 3408584224) ("depends" nil) ("category" "Utilities" ) ("changes" . "igsearch-minibuffer-end-of-buffer追加\nigsearch-minibuffer-beginning-of-buffer追加\n正規表現での検索で１文字目に^を入力すると固まったのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
(("name" . "lisp-minibuffer-mode") ("md5" . "f28e0f806cf8ae601632b0ec25d96bcf") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Flisp-minibuffer-mode&openfile=lisp-minibuffer-mode-2008.01.06.zip") ("version" . "2008.01.06") ("author" . "snj14") ("file" . "lisp-minibuffer-mode-2008.01.06.zip") ("description" . " eval-expression [ESC ESC] 用のメジャーモードです\n \n 以下の特徴があります\n - paren.lの強調が有効になる\n - 専用のキーマップが指定できる\n - ミニバッファの高さが可変になる\n - undoができる\n ") ("time" . 3408585749) ("depends" nil) ("category" "Editing" ) ("changes" . "ミニバッファのサイズを変更できない時でも可能な大きさで拡大するように修正\nlisp-minibuffer-mode-check-size をミニバッファの post-command-hook にhookするように修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "tterm") ("version" . "0.35+1.0") ("author" . "YAMAMOTO Shinji <sinj@mb.neweb.ne.jp>") ("file" . "") ("src" . "https://github.com/downloads/DeaR/NAXEL/tterm-0.35_1.0.zip") ("description" . "ライセンス: MIT
改変者: DeaR
Telnet 端末です。

tterm.l は xyzzy 上で Telnet クライアントとして動作するターミナルエミュレータです。
たぶん動くと思いますが、だめな場合もあるかもしれません。
不確かな情報によると、FreeBSD, linux, SunOS などの Telnet サーバと接続できるようです。
使用される場合は十分注意してください。") ("category" "Network") ("md5" . "98a58ca8d8217ca5352dec82dc20bd7f") ("time" . 3542430707) ("depends") ("changes" . "multiframe対応
UTF-8対応
デフォルト反転色の修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "www-mode") ("version" . "0.0.1.6") ("author" . "Masashi Hattori <hat@kme.biglobe.ne.jp>") ("file" . "www-0.0.1.6.lzh") ("src" . "http://www7a.biglobe.ne.jp/~hat/xyzzy/download.cgi?www-0.0.1.6.lzh") ("description" . "へなちょこWWWブラウザ") ("category" "Network") ("md5" . "0dd624d17823a41b6a1690925cc9ac3c") ("time" . 3344173298) ("depends") ("changes" . "・ページにformが複数ある時に何かとおかしくなっていたのをある程度修正。
・multipart/form-dataにへなちょこ対応。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "2ch-mode") ("version" . "0.0.1.4-4+1.0") ("author" . "Masashi Hattori <hat@kme.biglobe.ne.jp>") ("file" . "2ch-mode-0.0.1.4-4_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/2ch-mode-0.0.1.4-4_1.0.zip") ("description" . "ライセンス: 修正BSD\\n改変者: mumurik765\\nへなちょこ２ちゃんねるブラウザ") ("category" "Network") ("md5" . "8420237175f71c485a9cb3c95672fd13") ("time" . 3542419205) ("depends" "www-mode") ("changes" . "Support multiframe.") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "browserex") ("version" . "2005.10.08+1.0") ("author" . "OHKUBO Hiroshi") ("file" . "browserex-20051008_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/browserex-20051008_1.0.zip") ("description" . "ライセンス: 修正BSD\\n改変者: mumurik765\\nbrowser.dll 使用のためのサンプル") ("category" "Network") ("md5" . "1d738915e133ba8d70b961b056005834") ("time" . 3542408424) ("depends" "Browser.dll") ("changes" . "Support multiframe.") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . "site-lisp/ni-before-uninstall/misc_notes/browserex.l"))
 (("name" . "buf2html") ("version" . "0.0.0.15+1.0") ("author" . "OHKUBO Hiroshi") ("file" . "buf2html-0.0.0.15_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/buf2html-0.0.0.15_1.0.zip") ("description" . "ライセンス: 修正BSDライセンス\\n改変者: mumurik765\\nなるべくバッファの表示を再現するような HTML を生成します。") ("category" "Formatting" "Utilities") ("md5" . "7b86f2d5c04123cc288e412ca6599787") ("time" . 3542405032) ("depends") ("changes" . "multiframe対応") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "katex") ("version" . "1.67.1.11+1.0") ("author" . "Maeda Manabu") ("file" . "katext-1.67.1.11_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/katext-1.67.1.11_1.0.zip") ("description" . "ライセンス: GPL v2\\n改変者: mumurik765") ("category" "TeX") ("md5" . "67b9e84e36bf0223f3a696729259699f") ("time" . 3542359498) ("depends") ("changes" . "multiframe support") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "elisp") ("version" . "1.67.1.11+1.0") ("author" . "Maeda Manabu") ("file" . "elisp-1.67.1.11_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/elisp-1.67.1.11_1.0.zip") ("description" . "ライセンス: GPLv2\\n改変者: mumurik765") ("category" "Libraries") ("md5" . "b68608b0ff07872b2e2d9a01786ca2ff") ("time" . 3542357113) ("depends") ("changes" . "multiframe対応。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "iswitchb") ("version" . "1.1+1.1") ("author" . "Deecay") ("file" . "iswitchb-1.1_1.1.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/iswitchb-1.1_1.1.zip") ("description" . "改変者: mumurik765\\nライセンス: GPL\\nバッファ切り替えをキーボードから") ("category" "Miscellaneous") ("md5" . "efd53018410905f555ebed58dd7ad73a") ("time" . 3542355467) ("depends" "elisp") ("changes" . "GPLが誤ってv3になっていたのを修正。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 )
