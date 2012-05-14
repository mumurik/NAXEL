("name" . "NAXEL")
("author" . "mumurik765, etc.")
("url" . "https://github.com/mumurik/NAXEL")
("description" . "Network Archive for Xyzzy Extending Lisp.")
("packages"
 (("name" . "guidgen") ("version" . "1.2.0+1.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "guidgen-1.2.0_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/guidgen-1.2.0_1.0.zip") ("description" . "ライセンス: MIT/X\\n改変者: mumurik765") ("category" "Libraries" "Development") ("md5" . "c45fd23dee6b0e8278ab34b1f024e436") ("time" . 3545988354) ("depends") ("changes" . "") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "layered-window") ("version" . "1.0.1+1.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "layered-window_1.0.1_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/layered-window_1.0.1_1.0.zip") ("description" . "ライセンス: MIT\\n改変者: mumurik765") ("category" "Libraries" "Graphics/Sound") ("md5" . "a75b69ce204969f38983cb5f8647b795") ("time" . 3545986303) ("depends" "api") ("changes" . "") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "api") ("version" . "2006.06.15") ("author" . "") ("file" . "api2006.06.15.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/api2006.06.15.zip") ("description" . ".") ("category") ("md5" . "b48655721bd930d71376bab39de5bfb3") ("time" . 3545974194) ("depends") ("changes" . "") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ggrep") ("version" . "2005.10.08+1.1") ("author" . "OHKUBO Hiroshi") ("file" . "ggrep-20051008_1.1.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/ggrep-20051008_1.1.zip") ("description" . "ライセンス: 修正BSD\\n改変者: mumurik765\\nGrep 類似の行指向検索を行います。

  □検索方法
  ・複数検索パターン指定 AND/OR 検索
  ・一致/不一致検索
  ・バッファ/ファイル単位絞込み検索
      - 前回マッチしたバッファ/ファイルが再検索の対象
  ・行単位絞込み検索
      - 前回マッチした行が再検索の対象
      - 検索パターンが複数行に渡ってマッチする場合でも絞込み検索可能
  ・エンコード指定検索 (ファイル)
  ・シンタックス指定検索 (バッファ)

  □検索対象
  ・カレントバッファ指定検索
  ・全表示バッファ指定検索
  ・複数ディレクトリ指定検索
  ・複数ファイル指定検索
  ・正規表現での複数バッファ指定検索

  □出力方法
  ・バッファ/ファイル名、行番号なしの出力
  ・バッファ/ファイル名のみの出力
  ・フルパス名での出力

  □検索設定の保存
  ・検索条件設定の保存、読込、削除(ダイアログ使用時)

  □提供コマンド
  ┏━━━━━━━┯━━━━┯━━━━━━━━━┯━━━━━━━━┓
  ┃コマンド名    │パターン│対象              │対象(C-u)       ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │説明                                          ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep         │正規表現│バッファリスト    │カレントバッファ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │AND/OR 検索                                   ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃fggrep        │文字列  │バッファリスト    │カレントバッファ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │AND/OR 検索                                   ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-and     │正規表現│バッファリスト    │カレントバッファ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │AND 検索                                      ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃fggrep-and    │文字列  │バッファリスト    │カレントバッファ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │AND 検索                                      ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-or      │正規表現│バッファリスト    │カレントバッファ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │OR 検索                                       ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃fggrep-or     │文字列  │バッファリスト    │カレントバッファ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │OR 検索                                       ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-narrow  │正規表現│grep 結果バッファ │                ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │絞込み検索(バッファからは行番号情報のみ取得)  ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃fggrep-narrow │文字列  │grep 結果バッファ │                ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │絞込み検索(バッファからは行番号情報のみ取得)  ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃xggrep        │正規表現│ディレクトリ      │                ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │複数ディレクトリ指定検索                      ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃zggrep        │正規表現│ファイル          │                ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │複数ファイル指定検索                          ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-contents│正規表現│カレントバッファ  │指定バッファ    ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │絞込み検索(指定バッファ内コンテンツのみで検索)┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-buffer  │正規表現│カレントバッファ  │指定バッファ    ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │ggrep / ggrep-narrow / ggrep-contents         ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-detail  │        │                  │                ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │minibuffer から全てを指定して検索             ┃
  ┣━━━━━━━┿━━━━┯━━━━━━━━━┯━━━━━━━━┫
  ┃ggrep-dialog  │        │                  │                ┃
  ┃              ├────┴─────────┴────────┨
  ┃              │dialog から全てを指定して検索                 ┃
  ┗━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━━━┛") ("category" "Editing") ("md5" . "b5ca6bf699e98ea83e00f3021903a93a") ("time" . 3545972705) ("depends") ("changes" . "・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . "site-lisp/ni-before-uninstall/misc_notes/ggrep.l"))
 (("name" . "csv-mode") ("version" . "0.0.3.0+1.0") ("author" . "OHKUBO Hiroshi") ("file" . "csv-0.0.3.0_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/csv-0.0.3.0_1.0.zip") ("description" . "ライセンス: 修正BSD\\n改変者: mumurik765") ("category" "Editing") ("md5" . "3da98152b38fcc3e975536ad00e8172b") ("time" . 3545970624) ("depends") ("changes" . "") ("notice" . "") ("load-after-install" . "site-lisp/ni-autoload/misc_notes/csv-mode.l") ("load-before-uninstall" . ""))
 (("name" . "chini") ("version" . "2005.10.08+1.0") ("author" . "OHKUBO Hiroshi") ("file" . "chini-20051008_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/chini-20051008_1.0.zip") ("description" . "ライセンス: 修正BSDライセンス\\n改変者: mumurik765") ("category" "Utilities") ("md5" . "cbf2378136a1c189821a8eb99f35e982") ("time" . 3545947358) ("depends") ("changes" . "multiframeに対応。") ("notice" . "") ("load-after-install" . ".") ("load-before-uninstall" . "site-lisp/ni-before-uninstall/misc_notes/chini.l"))
 (("name" . "vi-mode") ("version" . "1.0") ("author" . "mumurik765.") ("file" . "vi-1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/vi-1.0.zip") ("description" . "vi-modeです。") ("category" "Editing") ("md5" . "17a8ae1c0d221315c5530e7981358d5f") ("time" . 3543136140) ("depends") ("changes" . "Initial release.") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "Browser.dll") ("version" . "1.1") ("author" . "mumurik765") ("file" . "browser-1.1.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/browser-1.1.zip") ("description" . "Browser.dllをスクラッチから書き直しました。") ("category" "Network") ("md5" . "a4adc3647fc83c21c1327102ad1cc75a") ("time" . 3542562710) ("depends") ("changes" . "browserexでクラッシュするのを修正。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "mercurial") ("version" . "0.2") ("author" . "Deecay") ("file" . "mercurial-20090215.zip") ("src" . "http://www.geocities.co.jp/Milano-Cat/2067/mercurial-20090215.zip") ("description" . "Minor mode for Mercurial VCS") ("category" "Miscellaneous") ("md5" . "b1c56b57d6dd16315856dab0b2281e8c") ("time" . 3443668075) ("depends") ("changes" . "1.1対応") ("notice" . "Please send me patches!") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "jaunte") ("version" . "0.00.01") ("file" . "jaunte-0.00.01.zip") ("src" . "http://bowbow99.sakura.ne.jp/xyzzy/jaunte-0.00.01.zip") ("description" . "画面内にヒントを散らかしてそこへジャンプ") ("md5" . "39ce5368cd9e2f4603bcda1c28fa7f15") ("time" . 3528031205) ("depends" "ansify" "ansi-loop") ("category" "Utilities") ("changes" . "2011-10-20  Ver. 0.00.01
========================
- 折り返し表示を再現してなかったせいでズレてたのを修正

2011-10-19  Ver. 0.00.00
========================
- こっそりと初リリース
  - ブログ記事書いてたら バグ発見 > 修正> Ver.up コンボ発動
"))
 (("name" . "setf-values") ("version" . "0.01.02") ("file" . "setf-values-0.01.02.zip") ("src" . "http://bowbow99.sakura.ne.jp/xyzzy/setf-values-0.01.02.zip") ("description" . "setf で多値を扱えるようにする") ("md5" . "14fc77ea9e2c5de718da8fe222bfb607") ("time" . 3526381979) ("category" "Lisp" "Libraries") ("changes" . "2011-09-30  bowbow99  <bowbow99@gmail.com>

	* version 0.01.02

2011-09-30  MIYAMUKO Katsuyuki  <miyamuko@gmail.com>

	* (setf (values a b c) (progn (values 1 2 3))) とかしたときに、
	  「変数が定義されていません: #:G2532」というエラーになっていた
	  のを修正

2011-09-30  bowbow99  <bowbow99@gmail.com>

	* (setf 3 8) とかしたときに、(setq 3 8) に展開されてからエラーに
	  なっていたのを展開時にエラー投げるようにした。

2011-04-09  bowbow99  <bowbow99@gmail.com>

	* version 0.01.01

	* `values` の setf-expander が色々ダメだったのをマシにした。
	  - subforms の setf-expansion を使うように。
	  - store-form が設定した多値を返すように（最後の値だけ返ってた）。

	* `setf-expand-1` で特定の場合に何かしてたのを削除
	  - 1つ目（`macroexpand-1` して再帰する）は、どうせ `get-setf-method`
	    が同じ事してくれるのでいらない。
	  - 2つ目（`setf-update` プロパティがあったら、その関数の呼び出しに
	    展開）は、`macrolet` で shadow した場合にもグローバルな setf-expander
	    を使って展開することになってしまうので削除。

2009-07-16  bowbow99  <bowbow99@gmail.com>

	* MIT ライセンスを適用したらしい。

2009-07-0?  bowbow99  <bowbow99@gmail.com>

	* 始めたらしい。
"))
 (("name" . "insert-directory-tree") ("version" . "2005.10.19") ("author" . "OHKUBO Hiroshi") ("file" . "insert-directory-tree-20051019.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/insert-directory-tree-20051019.zip") ("description" . "ディレクトリツリーを出力します。") ("category" "Utilities") ("md5" . "d2cfa52052d33c825fa47993c950fe88") ("time" . 3338642628) ("depends") ("changes" . "・NANRI さんの拡張を取り込み。
  *insert-directory-tree-leaf-function* に、file を引数にと
  り文字列を返す関数を指定することで情報を付加出力する。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ruby-refe") ("version" . "2.00") ("author" . "HIE Masahiro") ("file" . "ruby-refe_2.00.zip") ("src" . "http://hie.s64.xrea.com/xyzzy/pub/ruby-refe_2.00.zip") ("description" . "ruby-mode から，ReFe を参照します。") ("category" "Documentation") ("md5" . "f2485dc589402273e45380e529e1df51") ("time" . 3479122615) ("depends") ("changes" . "[Version 2.00] 2010-04-01 (木)
・ReFe2 に対応した(はず)。
・ReFe1 非対応にした。
・オプションが指定できるようにした。
・その他いろいろ。") ("notice" . "ReFe2より前のバージョンには非対応。") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "indent-to-token+") ("version" . "2008.01.07") ("author" . "bove-crach") ("file" . "indent-to-token-plus2008.01.07.zip") ("src" . "http://park.geocities.jp/bovecrach/xyzzy/indent-to-token-plus2008.01.07.zip") ("description" . "正規表現の token を使用して桁位置を整列させる。
思いつくまま xyzzy の Masahiro Nakano さんが作成された
indent-to-token の改造版です") ("category" "Editing" "Development") ("md5" . "5e7c86899920761ca9f6c4d705fd0c92") ("time" . 3408719834) ("depends") ("changes" . "右揃えに対応するため、処理を見直し") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "generic-comment-toggle") ("version" . "2008.01.07") ("author" . "bove-crach") ("file" . "generic-comment-toggle2008.01.07.zip") ("src" . "http://park.geocities.jp/bovecrach/xyzzy/generic-comment-toggle2008.01.07.zip") ("description" . "バッファモード毎のコメントアウトorアンコメントを行います。
要は HIEさんのページのNOTE->編集->1 行コメントをトグル を改造しただけです") ("category" "Development" "Editing") ("md5" . "8933fa328feb50e92cb422970000779f") ("time" . 3408629027) ("depends") ("changes" . "packagesとしては初版
・コメントアウト/アンコメントする度に行っていた(set-comment-words)を、最小限になるように。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "clickable-uri") ("version" . "2005.10.08") ("author" . "OHKUBO Hiroshi") ("file" . "clickable-uri-20051008.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/clickable-uri-20051008.zip") ("description" . "左ダブルクリックによる WEB ブラウザ、メーラー等の起動を可能にします。
URI (Uniform Resource Identifier) 強調表示も行います。") ("category" "Miscellaneous") ("md5" . "6459dda4f7e91ffde0bac8b6f14a3138") ("time" . 3337729390) ("depends") ("changes" . "・file: の場合そのまま shell-execute に渡すように変更。
・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "sort-line") ("version" . "2005.10.08") ("author" . "OHKUBO Hiroshi") ("file" . "sort-line-20051008.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/sort-line-20051008.zip") ("description" . "任意のカラム以降をキーとして、バッファ全体／選択範囲の行のソートを
行います。") ("category" "Text Processing") ("md5" . "0d336221d03200da7f33b1140ee57d61") ("time" . 3337733132) ("depends") ("changes" . "・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . "site-lisp/ni-before-uninstall/misc_notes/sort-line.l"))
 (("name" . "mayu-mode") ("version" . "0.0.0.6") ("author" . "OHKUBO Hiroshi") ("file" . "mayu-0.0.0.6.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/mayu-0.0.0.6.zip") ("description" . "「窓使いの憂鬱」設定ファイル編集モード") ("category" "Editing") ("md5" . "1cd21dd230cdb16b0d85740e037465d5") ("time" . 3337739053) ("depends") ("changes" . "・「窓使いの憂鬱」ver. 3.30 付属の mayu-mode.el のキーワードに準拠。
・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "bat-mode") ("version" . "0.0.0.4") ("author" . "OHKUBO Hiroshi") ("file" . "bat-0.0.0.4.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/bat-0.0.0.4.zip") ("description" . "バッチファイル編集モード") ("category" "Editing") ("md5" . "d50999698bc298bbaf6c4ba6107f42e5") ("time" . 3337739210) ("depends") ("changes" . "・HIE さんに 2002/10/17 に教えていただいていた typo の修正漏れを修正。
・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ini-mode") ("version" . "0.0.0.4") ("author" . "OHKUBO Hiroshi") ("file" . "ini-0.0.0.4.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/ini-0.0.0.4.zip") ("description" . "INIファイル編集モード") ("category" "Editing") ("md5" . "38b9a00b55b2610507e85e947efab79d") ("time" . 3337739353) ("depends") ("changes" . "・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "win-window") ("version" . "2005.10.08") ("author" . "OHKUBO Hiroshi") ("file" . "win-window-20051008.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/win-window-20051008.zip") ("description" . "Windows の Window を操作します。") ("category" "Libraries") ("md5" . "4bd7fc79df079917368f6e52cf2989f5") ("time" . 3337740003) ("depends") ("changes" . "・GetWindowRect, IsZoomed の戻り値の型を int -> BOOL に変更
・メールアドレスを変更。
・ライセンス条項(修正BSDライセンス)を記載。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "insert-directory-tree") ("version" . "2005.10.19") ("author" . "OHKUBO Hiroshi") ("file" . "insert-directory-tree-20051019.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/insert-directory-tree-20051019.zip") ("description" . "ディレクトリツリーを出力します。") ("category" "Utilities") ("md5" . "d2cfa52052d33c825fa47993c950fe88") ("time" . 3338642628) ("depends") ("changes" . "・NANRI さんの拡張を取り込み。
  *insert-directory-tree-leaf-function* に、file を引数にと
  り文字列を返す関数を指定することで情報を付加出力する。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "color") ("version" . "2005.10.06") ("author" . "OHKUBO Hiroshi") ("file" . "color-20051006.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/color-20051006.zip") ("description" . "COLOR-NAME と RGB値 の対応リスト、操作関数を提供します。") ("category" "Libraries") ("md5" . "48424d119b6a6f0f4be88231387220f9") ("time" . 3343223908) ("depends") ("changes" . "・公開") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "treeview") ("version" . "2006.11.03") ("author" . "OHKUBO Hiroshi") ("file" . "treeview-20061103.zip") ("src" . "http://ohkubo.s53.xrea.com/xyzzy/treeview-20061103.zip") ("description" . "TreeView.dll を操作するライブラリ") ("category" "Libraries") ("md5" . "5fd5513a0b3a371d4c11cedf7454ccee") ("time" . 3371492676) ("depends" "treeview.dll(ver.1.03)" "win-window" "color") ("changes" . "・treeview-get-up-item 関数を修正。
  連鎖して treeview-scan-treeview, treeview-isearch-forward,
  treeview-isearch-backward などでの逆検索が正常動作に。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . "site-lisp/ni-before-uninstall/misc_notes/treeview.l"))
 (("name" . "bash-mode") ("version" . "0.2") ("author" . "TKI") ("file" . "bashmode.zip") ("src" . "http://www2.ocn.ne.jp/~cheerful/script/xyzzy/mode/bashmode.zip") ("description" . "bashスクリプトを書くモードです。shにもいいと思います.") ("category" "Editing") ("md5" . "726f725e4bd982a3bc11f94f062d76f9") ("time" . 3313565882) ("depends") ("changes" . "") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "warn-if-read-1mb-over-file") ("version" . "2003/09/23") ("author" . "ろひの宮") ("file" . "warn-if-read-1mb-over-file_20061123.zip") ("src" . "http://rohinomiya.cocolog-nifty.com/xyzzy/warn-if-read-1mb-over-file_20061123.zip") ("description" . "1MB超のファイルを開こうとする時に警告と確認を行います。") ("category" "Miscellaneous") ("md5" . "dd5f5969ebed16f272d431120c138ce6") ("time" . 3373272072) ("depends") ("changes" . "・サイトが消えて失われていた分を再公開。（中身は変わっていません）") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "AutoHotKey-mode") ("version" . "2006/11/27") ("author" . "ろひの宮") ("file" . "ahk-mode.zip") ("src" . "http://rohinomiya.cocolog-nifty.com/xyzzy/ahk-mode.zip") ("description" . "AutoHotKeyのスクリプトファイル(.ahk)を編集するためのモード。") ("category" "Editing") ("md5" . "2b96fa3d0d336fa73da9021f978ca29d") ("time" . 3373542328) ("depends") ("changes" . "大幅に修正。[TAB]でコマンド補完に変更。補完時にコマンド引数表示。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "luna") ("version" . "0.1") ("author" . "miyamuko") ("file" . "luna.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/luna.zip") ("description" . "Windows XP スタイルで xyzzy を表示する。") ("category" "Graphics/Sound") ("md5" . "b3f171cddc449bb46c7e48e7ae3540e8") ("time" . 3301057714) ("depends") ("changes" . "仕切りなおしリリース") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "properties-mode") ("version" . "0.1") ("author" . "miyamuko") ("file" . "properties-mode.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/properties-mode.zip") ("description" . "Java の properties ファイルを読み書きする。") ("category" "Development") ("md5" . "65d21a67d5299d956e71c25e0e0c9852") ("time" . 3301057729) ("depends") ("changes" . "仕切りなおしリリース") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xyzzydiff") ("version" . "0.1") ("author" . "miyamuko") ("file" . "xyzzydiff.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xyzzydiff.zip") ("description" . "コマンドラインから diff する。") ("category" "Development") ("md5" . "d764dbbac7381fd43321e23d7104cfc0") ("time" . 3301058729) ("depends") ("changes" . "初期リリース") ("notice" . "") ("load-after-install" . "site-lisp/xyzzydiff/install.l") ("load-before-uninstall" . ""))
 (("name" . "xyzzytail") ("version" . "0.1") ("author" . "miyamuko") ("file" . "xyzzytail.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xyzzytail.zip") ("description" . "コマンドラインから tail-f する。") ("category" "Utilities") ("md5" . "18ea1e53e8b81bcfb5582911dffa8210") ("time" . 3301058739) ("depends") ("changes" . "初期リリース") ("notice" . "") ("load-after-install" . "site-lisp/xyzzytail/install.l") ("load-before-uninstall" . ""))
 (("name" . "cygwin-mount") ("version" . "1.1.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "cygwin-mount.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/cygwin-mount.zip") ("description" . "cygwin-mount - Cygwin のパスを指定してファイルを開く
http://miyamuko.s56.xrea.com/xyzzy/cygwin-mount/intro.htm") ("category" "Utilities" "File Systems") ("md5" . "f94a47130167ea4edd58ef4d9da6c48f") ("time" . 3424845911) ("depends") ("changes" . "cygwin-mount 1.1.0 リリース!

: 新規機能

    * (cygmount-point-info): path 引数で mount 情報を取得するパスを指定できるようにした

: 非互換を含む変更点

    * なし

: バグ修正

    * なし

: その他

    * ライセンスファイルを同梱
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "json") ("version" . "0.1.2") ("author" . "MIYAMUKO Katsuyuki") ("file" . "json.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/json.zip") ("description" . "json - 安全で高速な JSON パーサ
http://miyamuko.s56.xrea.com/xyzzy/json/intro.htm

json は xyzzy Lisp のみで実装した JSON パーサです。
json-syck より高速でかつ外部ライブラリを利用していないので安全です。
") ("category" "Development" "Libraries") ("md5" . "1fa971cd431488f846b08f6805962f36") ("time" . 3424844545) ("depends") ("changes" . "json 0.1.2 リリース!

: 新規機能

    * なし

: 非互換を含む変更点

    * なし

: バグ修正

    * なし

: その他

    * ライセンスファイルを同梱
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "grep-a-lot") ("version" . "1.1.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "grep-a-lot.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/grep-a-lot.zip") ("description" . "grep-a-lot は grep バッファの名前を自動的に変更して、
grep バッファを複数保存できるようにします。

grep バッファのバッファ名には以下のように検索キーワードが含まれます。

  *grep:<foo>*
  *ggrep:<tiger AND bunny>*
") ("category" "Editing" "Utilities") ("md5" . "e2bb7ca126796a828ea292cfa3607f99") ("time" . 3521605470) ("depends") ("changes" . "* 1.1.0 リリース!
  - outline-tree2 との親和性を高めた (#2)
    - outline-tree2 でグループ化されるようにバッファ名を変更
      - 変更前: *grep*<キーワード>
      - 変更後: *grep:<キーワード>*
    - バッファ名変更後に outline-tree2 のノード名も更新するようにした
  - fggrep で検索文字列が取得できていなかったのを修正
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xl-ppcre") ("version" . "1.0.1") ("author" . "MIYAMUKO Katsuyuki") ("file" . "xl-ppcre.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xl-ppcre.zip") ("description" . "xl-ppcre は CL-PPCRE ( http://weitz.de/cl-ppcre/ ) を xyzzy に移植したものです。

xl-ppcre は以下の機能を提供しています。

* Perl 互換の正規表現が使えます (一部制限があります)
* シングルラインモード、マルチラインモード、拡張正規表現
* cl-ppcre 互換の API

xl-ppcre は以下の機能は提供していません。

* 肯定先読み、否定先読み、埋め込みコードなどは処理できません
  * xl-ppcre は Perl 互換の正規表現を xyzzy 用に変換するのみで、
    正規表現エンジンは xyzzy 組み込みのものを利用しているためです
* 正規表現リテラル (リーダーマクロ)はありません
* replace-string や replace-dialog で Perl 互換の正規表現の利用はできません
* cl-ppcre の parse tree 形式での指定はできません
* ユニコードプロパティは利用できません
") ("category" "Text Processing" "Libraries") ("md5" . "4a97ae56b7e1c32129a4ace660a88980") ("time" . 3525502199) ("depends") ("changes" . "=== 2011/09/20

* 1.0.1 リリース!
  * register-groups-bind, do-register-groups のインデントスタイルを
    multiple-value-bind のようにした
  * \"xl-\" を付けなくても (require \"ppcre\") でロードできるようにした
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xl-interpol") ("version" . "1.0.2") ("author" . "MIYAMUKO Katsuyuki") ("file" . "xl-interpol.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xl-interpol.zip") ("description" . "xl-interpol は CL-INTERPOL ( http://weitz.de/cl-interpol/ ) を xyzzy に移植したものです。

xl-interpol は以下の機能を提供しています。

* 変数や式を文字列に埋め込める
* 正規表現リテラル
* ユニコード文字 (\\N{HIRAGANA LETTER A})
") ("category" "Text Processing" "Libraries") ("md5" . "a7f7b0806cb120c08279bcfbc095d69d") ("time" . 3526258386) ("depends" "xl-ppcre" "ansi-loop") ("changes" . "=== 2011/09/29

* 1.0.2 リリース!
  * xl-interpol 独自部分のライセンスが MIT になっていたので BSD で統一
  * ansi-loop を使って cl-interpol オリジナルのコードに戻した
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xl-alexandria") ("version" . "0.0.2") ("author" . "MIYAMUKO Katsuyuki") ("file" . "xl-alexandria.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xl-alexandria.zip") ("description" . "xl-alexandria は Common Lisp の Alexandria ( http://common-lisp.net/project/alexandria/ ) を
を xyzzy に移植したものです。

Alexandria は巨大なユーティリティ集です。
実践 Common Lisp や OnLisp に載っていたり、自分で書いたことがあるような
関数・マクロが大量に詰まっています。
") ("category" "Libraries" "Lisp") ("md5" . "d7df943941f93f6869638346753451f0") ("time" . 3535185958) ("depends" "setf-values" "ansi-loop" "ansify") ("changes" . "xl-alexandria 0.0.2 リリース!

  * parse-body が interactive 式も取り出せるようになりました (by @bowbow99)。

    (ansify:destructuring-bind (defun name lambda-list &rest body)
        '(defun foobar-region (start end)
          \"foobar region\"
          (interactive \"*r\")
          (delete-region start end)
          (insert \"foobar\"))
      (alexandria:parse-body body :documentation t :interactive t))
    ;=> ((delete-region start end) (insert \"foobar\"))
    ;   nil
    ;   \"foobar region\"
    ;   (interactive \"*r\")

  * symbolicate が動作していなかったのを修正

    (alexandria:symbolicate \"prefix-\" :foo)
    ;=> prefix-foo

  * upstream の変更を取り込み (3eacfac87b2...77b219a8361)
    https://github.com/miyamuko/xl-alexandria/compare/3eacfac87b27654f7ca9eeaf1ce40344b8136b03...77b219a8361b9549aeb8941afc945fa2e3c84eb9
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xml-http-request") ("version" . "1.3.2") ("author" . "MIYAMUKO Katsuyuki") ("file" . "xml-http-request.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xml-http-request.zip") ("description" . "xml-http-request - 非同期 HTTP 通信ライブラリ
http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm") ("category" "Network" "Libraries" "Development") ("md5" . "3ac01d65997774382b8b406d46fdfa40") ("time" . 3536910309) ("depends") ("changes" . "### 2012-01-30 / 1.3.2

xml-http-request 1.3.2 リリース!

#### 新規機能

  * なし

#### 非互換を含む変更点

  * なし

#### バグ修正

  * xhr-(get|post)-async で :key に xhr-response-text とか指定してると
    :onabort の起動時にこける問題を修正
    (Reported by @youz)

#### その他

  * なし
") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xl-winhttp") ("version" . "1.0.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "xl-winhttp.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xl-winhttp.zip") ("description" . "xl-winhttp は [Windows HTTP Services](http://msdn.microsoft.com/en-us/library/windows/desktop/aa384273.aspx)
を利用した HTTP 通信を行うためのライブラリです。

[xml-http-request](http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm)
と比べて低レベルなライブラリですが、xml-http-request では取得出来なかった以下のようなデータも取得可能です。

  * チャンク形式のエンコーディング (Transfer-Encoding: chunked)
  * バイナリファイルの取得
  * 文字エンコーディングを自動的に変換しないため、charset などが不適切でも文字化けしません

Proxy や Basic/Digest 認証、SSL、非同期通信などは xml-http-request と同様に対応しています。
") ("category" "Network" "Libraries" "Development") ("md5" . "7c848750ad0af9cea30c00a8b3d3b40d") ("time" . 3537688440) ("depends" "xl-alexandria" "ansi-loop" "ansify" "setf-values") ("changes" . "初版リリース") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "http-client") ("version" . "1.0.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "http-client.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/http-client.zip") ("description" . "http-client は [xl-winhttp] を利用した HTTP クライアント・ライブラリです。
Proxy、Basic/Digest 認証、SSL、Cookie、非同期通信などをサポートしています。

[xml-http-request] と比較したメリット・デメリットはそれぞれ以下のとおりです。

  * メリット
    * ストリーミングに対応している (Transfer-Encoding: chunked)
    * Content-Type の charset が不明な場合でも文字化けしない
    * バイナリ・データの送受信に対応している
    * ファイル・ダウンロードに対応している
    * ファイル・アップロードに対応している (multipart/form-data)
    * IE とセッションが分離されているので、IE のキャッシュやクッキーの影響を受けない

  * デメリット
    * IE とは別にプロキシを WinHTTP で設定しておく必要がある
    * IE とセッションが分離されているので、自前でログイン処理などを実装する必要がある
    * クッキーは xyzzy を再起動するとすべて消える
    * 認証情報は毎回指定する必要がある
      - 自動的に認証ダイアログがでない
      - 認証情報のキャッシュは行わない
    * 圧縮転送に対応していない (Content-Encoding: gzip)
    * 受信処理を xyzzy Lisp で行うため若干遅い

  [xl-winhttp]: http://miyamuko.s56.xrea.com/xyzzy/xl-winhttp/intro.htm
  [xml-http-request]: http://miyamuko.s56.xrea.com/xyzzy/xml-http-request/intro.htm
") ("category" "Network" "Libraries" "Development") ("md5" . "6b6fc035942729dc948c514bd07a61a9") ("time" . 3537688464) ("depends" "xl-winhttp" "xl-alexandria" "ansi-loop" "ansify" "setf-values") ("changes" . "初版リリース") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "xl-open-uri") ("version" . "1.0.0") ("author" . "MIYAMUKO Katsuyuki") ("file" . "xl-open-uri.zip") ("src" . "http://miyamuko.s56.xrea.com/xyzzy/archives/xl-open-uri.zip") ("description" . "xl-open-uri は Ruby の [open-uri] とほぼ同様の機能を xyzzy Lisp に実装したライブラリです。
HTTP や FTP に簡単にアクセスするための機能を提供します。

デフォルトでサポートしている URL スキームは http, https, ftp, data です。
また、URL スキームを追加するための API も公開しています。

Ruby の open-uri では HTTP GET および FTP のダウンロードしか対応していませんが、
xl-open-uri では任意の HTTP メソッドの送信が可能です。
また FTP のアップロードにも対応しています。

  [open-uri]: http://doc.ruby-lang.org/ja/1.9.3/library/open=2duri.html
") ("category" "Network" "Libraries" "Development") ("md5" . "3243520bd298368c9bd6afe7c55a12e5") ("time" . 3537946975) ("depends" "http-client" "xl-winhttp" "xl-alexandria" "ansi-loop" "ansify" "setf-values") ("changes" . "初版リリース") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ac-mode") ("md5" . "b6780b9437452eafe588cb4498b94447") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fac-mode&openfile=ac-mode-2007.12.21.zip") ("version" . "2007.12.21") ("author" . "snj14") ("file" . "ac-mode-2007.12.21.zip") ("description" . " - paren,rv-region,セレクションの有無,直前に実行したコマンド を考慮したインデント
 - snippetの展開
 - (URI|ファイル名|abbrev|lispの関数,変数|バッファ内の関数,変数|Keyword|XTAGS|dabbrev)
   のインクリメンタルな補完
 をC-i(TAB)のみで行えるようにするマイナーモードです。
 snippetの展開には別途snippet.lが必要です。

 インテリジェント補完コマンド ac-mode
 http://taiyaki.org/elisp/ac-mode/
 の説明から想像で実装し、便利そうな機能を追加したものです。
 
 
 また、いくつかの補完には専用のコマンドもあり、
 文字を入力せずに補完することや、
 (complete+が入っていれば)部分一致/スキップマッチも可能です。
 ") ("time" . 3407169979) ("depends" nil) ("category" "Editing") ("changes" . "補完はカーソルが単語の上 or 末尾にあるときのみにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
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
 (("name" . "ansify") ("version" . "0.03.03") ("file" . "ansify-0.03.03.zip") ("src" . "http://bowbow99.sakura.ne.jp/xyzzy/ansify-0.03.03.zip") ("description" . "ANSI Common Lisp にあって xyzzy にないもの詰め合わせ") ("md5" . "46a1703d811a7ccec1bdd1b8f884ebab") ("time" . 3542021675) ("category" "Lisp" "Libraries") ("changes" . "2012-03-29  Ver. 0.03.03
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
 (("name" . "approx-search") ("md5" . "06e495aefe17b77988de51a38358b739") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fapprox-search&openfile=approx-search-2007.02.15.zip") ("version" . "2007.02.15") ("author" . "shiro") ("file" . "approx-search-2007.02.15.zip") ("description" . " emacs用の曖昧検索ライブラリ approx-search.el の xyzzy移植版です
 ") ("time" . 3380454344) ("depends") ("category" "Libraries" "Text Processing") ("changes" . "キーボードマクロ実行時にちらつかないようにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "describe-bindings-mode") ("md5" . "affafc9fd7ce8bc8cc9bf3e4981ba0c8") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fdescribe-bindings-mode&openfile=describe-bindings-mode-2007.02.22.zip") ("version" . "2007.02.22") ("author" . "shiro") ("file" . "describe-bindings-mode-2007.02.22.zip") ("description" . " キーマップ表示(describe-bindings)に
  * 色付け
  * タグジャンプ
  * qで閉じる
  * 強制的に真ん中から上下2分割での表示
  * 日本語の解説表示
 の機能を付けます。
 
 日本語の解説表示にはinfo-modoki-mode + reference.txtが、
 色付けにはlispのキーワードファイルが必要です。") ("time" . 3381086409) ("depends") ("category" "Utilities") ("changes" . "ミニバッファでも使えるようにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "gmark-select") ("md5" . "9a45835f673039f2546d9794a080b659") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fgmark-select&openfile=gmark-select-2007.02.22.zip") ("version" . "2007.02.22") ("author" . "shiro") ("file" . "gmark-select-2007.02.22.zip") ("description" . " 画面を分割してグローバルマークを選び、ジャンプしたり削除したりできます。") ("time" . 3381086398) ("depends") ("category" "Utilities") ("changes" . "gmark-select-search-forwardで次のバッファも探すようにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "paren") ("md5" . "a7d3ec008679baf596e93fca325eb500") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fparen&openfile=paren-2007.04.12.zip") ("version" . "2007.04.12") ("author" . "shiro") ("file" . "paren-2007.04.12.zip") ("description" . " KITAさん作のparen.lの改造版です
 
 以下変更点
  
  - ハイライトの前後で属性を保存
  - delete-text-attributesのタイミングの変更
  - エスケープされている場合は動作を行わないように
  - 指定されたコマンドの直後では動作を行わないように
  - シンタックスがタグの場合でもハイライト(設定可)
  - 閉じ括弧の反応する位置を1つ前にできるように(設定可)
  - ハイライト中でも元の属性を表示し続ける(設定可)") ("time" . 3385370028) ("depends" nil) ("category" "Utilities") ("changes" . "連続したエスケープの直後の括弧が強調できていなかったのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "virtual-file-archive") ("md5" . "56387a8ee4febd24e324d4c46504483c") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-archive&openfile=virtual-file-archive-2007.03.23.zip") ("version" . "2007.03.23") ("author" . "shiro") ("file" . "virtual-file-archive-2007.03.23.zip") ("description" . " virtual-fileのアーカイブ用プラグイン
 
 ミニバッファで圧縮ファイルの中身を補完し、
 読み込み時に展開し、
 保存時に再圧縮を行います。
 filer-list-archive(ファイラ上でV)で開いたファイルも保存時の圧縮を行います。
 
 complete+ と virtual-file が必要です。
 
 標準関数find-file-in-archiveを上書きしています。") ("time" . 3383606468) ("depends" "complete+" "virtual-file") ("category" "Utilities" "File Systems") ("changes" . "リストを返す関数の仕様を変更") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "virtual-file-ftp") ("md5" . "ad597d75071eee393c7119d51b8af1e1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-ftp&openfile=virtual-file-ftp-2007.03.23.zip") ("version" . "2007.03.23") ("author" . "shiro") ("file" . "virtual-file-ftp-2007.03.23.zip") ("description" . " virtual-fileのFTP用プラグイン
 
 ミニバッファでFTPに接続して補完し、
 読み込み時に一時ファイルにダウンロードし、
 保存時に再アップロードを行います。") ("time" . 3383607443) ("depends" "complete+" "virtual-file") ("category" "Utilities" "File Systems") ("changes" . "リストを返す関数の仕様を変更") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "virtual-file") ("md5" . "e3a05503a31f2a95a1d7dd11c750a0e1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file&openfile=virtual-file-2007.07.09.zip") ("version" . "2007.07.09") ("author" . "shiro") ("file" . "virtual-file-2007.07.09.zip") ("description" . " 仮想的なファイルの読み込みと保存を行うための仕組みを提供するものです。
 単体では機能しません。
 
 virtual-file-archive.lなどをインストールしてください。
 ") ("time" . 3392896302) ("depends" "complete+" "session-ext") ("category" "Utilities" "File Systems") ("changes" . "時間制限付きmemoize関数を追加") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "virtual-file-pscp") ("md5" . "0681f8010d950656b769c40a246408ef") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fvirtual-file-pscp&openfile=virtual-file-pscp-2007.07.09.zip") ("version" . "2007.07.09") ("author" . "shiro") ("file" . "virtual-file-pscp-2007.07.09.zip") ("description" . " virtual-fileのpscp.exe用プラグイン
 
 pscp.exeを経由して
   ファイルのリストを取得
   ファイルを取得
   ファイルを転送
 することで
   ミニバッファでサーバ上のファイルを補完
   読み込み時に一時ファイルにダウンロードしバッファに読み込み
   保存時に自動で再アップロード
 が可能になります。
 
 virtual-file-ftpと比較すると
   scpなので通信が暗号化される
   鍵が使えるのでパスワードをファイルに直接書かなくて済む
   pagent.exeを使えばSOCKSも使える
   pscp.exeを起動する時間が余計にかかる
   (ftpの方はxyzzy lispだけで完結している)
 等が異なります。") ("time" . 3392896696) ("depends" "complete+" "virtual-file") ("category" "Utilities" "File Systems") ("changes" . "初版") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "snippet") ("md5" . "214faf15c6daec0d0a833c7e699eb568") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fsnippet&openfile=snippet-2007.07.15.zip") ("version" . "2007.07.15") ("author" . "shiro") ("file" . "snippet-2007.07.15.zip") ("description" . " Abbrevで展開した後に、
   * 指定した位置にジャンプ
   * 編集した部分を他の場所に反映
 します。
 プログラムやHTMLなどの定型的な文を良く入力する人以外はあまり美味しくないかもしれません。
 
 TextMateで話題になっていたので勢いで実装しました。
 詳細が良く分からないところや、しっかり考えてないところがあるので、
 いろいろと問題があるかもしれません。
 
 ac-modeと一緒に使うことを推奨。
 ") ("time" . 3393473889) ("depends" nil) ("category" "Editing") ("changes" . "10個以上の展開ができなかったのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "ffap") ("md5" . "72cb0dfbc51752ebc82e70400293a4b0") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fffap&openfile=ffap-2007.10.19.zip") ("version" . "2007.10.19") ("author" . "shiro") ("file" . "ffap-2007.10.19.zip") ("description" . "   emacsにあるffapの説明(http://www.bookshelf.jp/soft/meadow_23.html#SEC226)
   をみて想像で実装したものです。
   コードは参考にしていないのでバグや機能不足があるかもしれません。

   カーソル位置周辺の文字を見てパスやURIを探し、
   パスの場合、デフォルトの値に指定した状態でfind-fileします。
   URIの場合、ブラウザ等で開きます。(設定可)
   カーソル位置周辺から探せなかった場合は、
   以前と変わらぬfind-fileをお楽しみ頂けます。

   要するに (require \"ffap\") や <a href=\"../index.html\">
   等の上でC-x C-fしたときにミニバッファが
   Find file: c:/bin/xyzzy/site-lisp/ffap.l
   や
   Find file: c:/data/web/index.html
   という状態でfind-fileを開始できるようになります。

   カーソル周辺のファイル名の親ディレクトリをアクティブな側、
   またはアクティブでない側のパスにして2画面ファイラを開く機能もあります。") ("time" . 3401731504) ("depends" nil) ("category" "Utilities") ("changes" . "virtual-fileからfind-fileした場合の初期ディレクトリをまともにした") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "complete+") ("md5" . "05b818a1c9f05b29934d8001ec8e62d1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Fcomplete%2B&openfile=complete%2B-2007.12.21.zip") ("version" . "2007.12.21") ("author" . "snj14") ("file" . "complete+-2007.12.21.zip") ("description" . "   ミニバッファ等で
    - 先頭一致/Migemo/部分一致/スキップマッチングで絞り込み、
      かつ全ての項目に先頭一致する文字列で補完
    - 存在するファイルでないものをファイルのように補完
      実際にファイルを開くにはvirtual-fileやその他もろもろ(virtual-file-*.l)が必要です
    - 大文字・小文字の区別をしたりしなかったり、大文字の時だけ区別したりする
    - ディレクトリのスキップマッチング( c:/d/m/hoge => c:/data/music/hoge )
    - 指定文字で区切りAND検索         ( c:/data/zip;xyz => c:/data/xyzzy.zip )
    - インクリメンタルに補完候補を表示(補完自体は行わない)
    - ↑を有効にしてる場合、補完できるところまでハイライトで表示
    - *Completion*バッファの候補のマッチしてる部分を強調表示
    - cygwin-mountと連携してcygwinのパスを補完
    - ファイル補完時に空白ならドライブも候補に入れる
    - C-i(TAB)やSpaceの直後の新規ファイル作成はRET2回で行なう
   を可能にするものです
   ") ("time" . 3407170008) ("depends" nil) ("category" "Utilities") ("changes" . "補完候補なしのcompleting-read中にエラーが出ていたのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "igsearch") ("md5" . "fd7282ca59a098050757241cbca648e1") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Figsearch&openfile=igsearch-2008.01.06.zip") ("version" . "2008.01.06") ("author" . "snj14") ("file" . "igsearch-2008.01.06.zip") ("description" . "   インクリメンタルサーチ中に
    - マッチした候補を反対側のウィンドウに列挙
    - エスケープシーケンスの理解とそのトグル
    - *case-fold-search*の値のトグル
    - Migemo検索,曖昧検索,正規表現検索,通常検索の切り替え
    - 検索語のハイライト
   ができます。
   
   また、ミニバッファで文字入力中に実行すると
    - 履歴の一覧を表示
    - 履歴のインクリメンタルサーチ
    - 履歴の削除
   ができます。
   ") ("time" . 3408584224) ("depends" nil) ("category" "Utilities") ("changes" . "igsearch-minibuffer-end-of-buffer追加
igsearch-minibuffer-beginning-of-buffer追加
正規表現での検索で１文字目に^を入力すると固まったのを修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "lisp-minibuffer-mode") ("md5" . "f28e0f806cf8ae601632b0ec25d96bcf") ("src" . "http://white.s151.xrea.com/wiki/index.php?plugin=attach&refer=script%2Flisp-minibuffer-mode&openfile=lisp-minibuffer-mode-2008.01.06.zip") ("version" . "2008.01.06") ("author" . "snj14") ("file" . "lisp-minibuffer-mode-2008.01.06.zip") ("description" . " eval-expression [ESC ESC] 用のメジャーモードです
 
 以下の特徴があります
 - paren.lの強調が有効になる
 - 専用のキーマップが指定できる
 - ミニバッファの高さが可変になる
 - undoができる
 ") ("time" . 3408585749) ("depends" nil) ("category" "Editing") ("changes" . "ミニバッファのサイズを変更できない時でも可能な大きさで拡大するように修正
lisp-minibuffer-mode-check-size をミニバッファの post-command-hook にhookするように修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "tterm") ("version" . "0.35+1.0") ("author" . "YAMAMOTO Shinji <sinj@mb.neweb.ne.jp>") ("file" . "") ("src" . "https://github.com/downloads/DeaR/NAXEL/tterm-0.35_1.0.zip") ("description" . "ライセンス: MIT
改変者: DeaR
Telnet 端末です。

tterm.l は xyzzy 上で Telnet クライアントとして動作するターミナルエミュレータです。
たぶん動くと思いますが、だめな場合もあるかもしれません。
不確かな情報によると、FreeBSD, linux, SunOS などの Telnet サーバと接続できるようです。
使用される場合は十分注意してください。") ("category" "Network") ("md5" . "98a58ca8d8217ca5352dec82dc20bd7f") ("time" . 3542430707) ("depends") ("changes" . "multiframe対応
UTF-8対応
デフォルト反転色の修正") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "2ch-mode") ("version" . "0.0.1.4-4+1.0") ("author" . "Masashi Hattori <hat@kme.biglobe.ne.jp>") ("file" . "2ch-mode-0.0.1.4-4_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/2ch-mode-0.0.1.4-4_1.0.zip") ("description" . "ライセンス: 修正BSD\\n改変者: mumurik765\\nへなちょこ２ちゃんねるブラウザ") ("category" "Network") ("md5" . "8420237175f71c485a9cb3c95672fd13") ("time" . 3542419205) ("depends" "www-mode") ("changes" . "Support multiframe.") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "browserex") ("version" . "2005.10.08+1.0") ("author" . "OHKUBO Hiroshi") ("file" . "browserex-20051008_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/browserex-20051008_1.0.zip") ("description" . "ライセンス: 修正BSD\\n改変者: mumurik765\\nbrowser.dll 使用のためのサンプル") ("category" "Network") ("md5" . "1d738915e133ba8d70b961b056005834") ("time" . 3542408424) ("depends" "Browser.dll") ("changes" . "Support multiframe.") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . "site-lisp/ni-before-uninstall/misc_notes/browserex.l"))
 (("name" . "buf2html") ("version" . "0.0.0.15+1.0") ("author" . "OHKUBO Hiroshi") ("file" . "buf2html-0.0.0.15_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/buf2html-0.0.0.15_1.0.zip") ("description" . "ライセンス: 修正BSDライセンス\\n改変者: mumurik765\\nなるべくバッファの表示を再現するような HTML を生成します。") ("category" "Formatting" "Utilities") ("md5" . "7b86f2d5c04123cc288e412ca6599787") ("time" . 3542405032) ("depends") ("changes" . "multiframe対応") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "katex") ("version" . "1.67.1.11+1.0") ("author" . "Maeda Manabu") ("file" . "katext-1.67.1.11_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/katext-1.67.1.11_1.0.zip") ("description" . "ライセンス: GPL v2\\n改変者: mumurik765") ("category" "TeX") ("md5" . "67b9e84e36bf0223f3a696729259699f") ("time" . 3542359498) ("depends") ("changes" . "multiframe support") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "elisp") ("version" . "1.67.1.11+1.0") ("author" . "Maeda Manabu") ("file" . "elisp-1.67.1.11_1.0.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/elisp-1.67.1.11_1.0.zip") ("description" . "ライセンス: GPLv2\\n改変者: mumurik765") ("category" "Libraries") ("md5" . "b68608b0ff07872b2e2d9a01786ca2ff") ("time" . 3542357113) ("depends") ("changes" . "multiframe対応。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 (("name" . "iswitchb") ("version" . "1.1+1.1") ("author" . "Deecay") ("file" . "iswitchb-1.1_1.1.zip") ("src" . "https://github.com/downloads/mumurik/NAXEL/iswitchb-1.1_1.1.zip") ("description" . "改変者: mumurik765\\nライセンス: GPL\\nバッファ切り替えをキーボードから") ("category" "Miscellaneous") ("md5" . "efd53018410905f555ebed58dd7ad73a") ("time" . 3542355467) ("depends" "elisp") ("changes" . "GPLが誤ってv3になっていたのを修正。") ("notice" . "") ("load-after-install" . "") ("load-before-uninstall" . ""))
 )
