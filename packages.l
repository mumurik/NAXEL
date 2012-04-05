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
