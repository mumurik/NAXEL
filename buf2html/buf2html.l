;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; buf2html.l --- convert text of buffer to HTML

;; Copyright (C) 2001-2006 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Version: 0.0.0.15
;; Time-stamp: <2006/01/29 13:46:44 +0900>
;; Xyzzy: 0.2.2.235

;;; Commentary:

;; Description:
;;
;;  なるべくバッファの表示を再現するような HTML を生成します。
;;  キーワード、正規表現キーワード、text-attribute に対応していますが、
;;  一行反転表示には対応していません。
;;
;;  勘で書いている部分があるのでおかしな変換があると思います。
;;  気がついた点を知らせて頂けるとありがたいです。
;;
;;
;;  ・コンテキストを指定したキーワードには対応していません。
;;  ・xyzzy とは異なり正規表現キーワードよりも、必ずキーワードを
;;    優先させてしまいます。
;;  ・正規表現キーワードのコンテキスト範囲を xyzzy と完全に同じには
;;    できていません。
;;    コンテキスト指定は、本来は開始位置指定にのみ影響しますが、
;;    buf2html では正規表現全体が同一コンテキストに含まれていなければ
;;    なりません。
;;

;; Installation:
;;
;;      1. アーカイブを展開して buf2html.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/buf2html.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "buf2html")
;;
;;      4. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. buf2html.l に関する記述を削除します。
;;
;;      2. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Setting example:
;;
;;      (require "buf2html")
;;      (buf2html-set-app-menu)
;;      (buf2html-set-app-popup-menu)
;;      (setq *buf2html-encoding* *encoding-euc-jp*)
;;      (setq *buf2html-eol-code* *eol-lf*)
;;      (setq *buf2html-auto-mode-parameter-string* "Mode: html+")
;;      (setq *buf2html-date-format* "%a, %d %b %Y %H:%M:%S %Z")
;;      (setq *buf2html-time-stamp-start* "Time-stamp: &lt;")
;;      (setq *buf2html-time-stamp-end* "&gt;")
;;      (setq *buf2html-css-list* '("xyzzy.css" "foo.css"))
;;      (setq *buf2html-region-css-class-list* '("bgcolor" "border"))
;;      (setq *buf2html-ignore-paren-highlight* t)
;;      (setq *buf2html-anchor-url* t)
;;      (setq *buf2html-lower-case* t)
;;      (setq *buf2html-internal-css-alist*
;;            '(("A.buf2html" . ("text-decoration: none"
;;                               "background: #ffe0e0"))
;;              ("A.buf2html:active" . ("background: #ffaaaa"))
;;              ("A.buf2html:hover" . ("background: #ffaaaa"))))
;;      (setq *buf2html-mode-function* 'ed::html-mode)
;;

;; Usage:
;;
;;      A:
;;        1. メニュー [ファイル]->[HTML形式で名前を付けて保存] から
;;           HTML 形式で保存。
;;
;;      B:
;;        1. M-x ini2css-file または M-x ini2css-buffer で xyzzy の
;;           INI ファイル (標準では xyzzy.ini) からスタイルシートを生成し、
;;           xyzzy.css というファイル名で保存。
;;
;;        2. 変換元のバッファで M-x buf2html または M-x buf2html-with-number
;;           し、HTML の出力されたバッファを xyzzy.css を保存したフォルダに
;;           保存。
;;

;; Changes:
;;
;;      [Version 0.0.0.15]
;;      Sun, 29 Jan 2006 12:49:31 +0900
;;        ・変換後、出力バッファをカレントバッファとして動作する
;;          *buf2html-post-convert-buffer-hook* 追加。
;;        ・明示的に出力バッファのエンコーディングを設定するための
;;          *buf2html-encoding* 及び、改行コードを設定するための
;;          *buf2html-eol-code* を追加。
;;          無指定時は変換元バッファの設定を用いる。
;;        ・出力バッファのエンコーディングと HTML ヘッダの整合がとれるように、
;;          エンコーディングと改行コードの指定位置を変更。
;;
;;      [Version 0.0.0.14]
;;      Sat, 08 Oct 2005 11:05:07 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      [Version 0.0.0.13]
;;      Sat, 09 Apr 2005 15:06:23 +0900
;;        ・xyzzy 0.2.2.234 対応
;;          - 半角カナを全角カナに変更。
;;          - buf2html-insert-menu-items 更新。
;;            「HTML形式で名前を付けて保存」メニューを追加する位置の
;;            デフォルトを「名前を付けて保存」の下に。
;;
;;      Tue, 11 Jan 2005 19:02:04 +0900
;;        ・buf2html-set-buffer を修正。
;;        ・コメントの修正
;;
;;      Wed, 01 Dec 2004 01:06:47 +0900
;;        ・各種関数に nomsg 引数を追加。
;;
;;      [Version 0.0.0.12]
;;      Sun, 13 Jun 2004 05:45:53 +0900
;;        ・buf2html-save-as-dialog (HTML形式で名前を付けて保存) 追加。
;;        ・buf2html-set-app-menu 追加。
;;          HTML形式で名前を付けて保存 をメニューに追加する。
;;
;;      Wed, 14 Jan 2004 00:54:07 +0900
;;        ・ini2css-buffer での出力にタブ文字を含めないように変更。
;;        ・*buf2html-buffer-tmp* バッファを非表示バッファに変更。
;;        ・buf2html-get-ini2css-string 追加。
;;        ・*buf2html-internal-xyzzy-css* 追加。
;;          HTML ファイル内に xyzzy.ini から生成した CSS を含めるか否か。
;;        ・buf2html, buf2html-print-header に、internal-css-p 引数追加。
;;        ・buf2html-get-region-string 時のバッファを非表示に。
;;
;;      Fri, 21 Nov 2003 00:22:12 +0900
;;        ・部分(region, selection)を対象に buf2html を行った場合、
;;          進捗ステータスがバッファ全体に対しての値となっていたのを修正。
;;
;;      [Version 0.0.0.11]
;;      Wed, 19 Feb 2003 01:14:56 +0900
;;        ・URL らしきところに <A> タグをつける設定
;;          *buf2html-anchor-url* 設定追加。
;;          アンカータグのクラスは buf2html。<A class="buf2html" href="...">。
;;        ・内部 CSS 指定連想配列 *buf2html-internal-css-alist* 追加。
;;        ・その他。
;;
;;      [Version 0.0.0.10]
;;      Sun, 16 Feb 2003 22:41:52 +0900
;;        ・buf2html-copy-region-as-kill,
;;          buf2html-copy-region-to-clipboard,
;;          buf2html-copy-selection,
;;          buf2html-copy-selection-to-clipboard 追加。
;;        ・buf2html-set-app-popup-menu 追加。
;;          右クリックメニューへの追加。
;;
;;      Thu, 28 Nov 2002 09:30:05 +0900
;;        ・buf2html-downcase-tag-region の動作を修正。
;;          ed::html-highlight-mode が t でなければ変換しないように。
;;
;;      [Version 0.0.0.9]
;;      Sun, 24 Nov 2002 23:22:17 +0900
;;        ・出力 CSS ファイルリスト
;;          *buf2html-css-list* 
;;        ・リージョン指定変換時の <pre> タグのクラス
;;          *buf2html-region-css-class-list*
;;        ・出力バッファのモード指定 *buf2html-mode-function*
;;
;;      Sat, 23 Nov 2002 12:09:48 +0900
;;        ・*buf2html-lower-case* の指定でタグを小文字にできるように。
;;          ただ、モノグサしたので出力先を無理やり string に変更した場合は
;;          多分動作しません。
;;
;;      Thu, 17 Oct 2002 22:29:26 +0900
;;        ・editor パッケージに入れた。
;;        ・buf2html-region, buf2html-region-complete を追加。
;;        ・*buf2html-ignore-paren-highlight* で喜多さんの paren.l の
;;          効果を一時的に無効化して変換できるように。
;;
;;      [Version 0.0.0.8]
;;      Mon, 11 Feb 2002 14:11:39 +0900
;;        ・buf2html を (interactive "p") にしてみた。
;;
;;      Fri, 11 Jan 2002 08:04:00 +0900
;;        ・ini2css-file での xyzzy の INI ファイルのデフォルトパスを修正。
;;        ・ini2css-buffer で ctlColor も変換するように。
;;
;;      [Version 0.0.0.7]
;;      Wed, 09 Jan 2002 21:59:48 +0900
;;        ・キーワードを使用していないモードのバッファで
;;          エラーがでるのを修正。
;;
;;      [Version 0.0.0.6]
;;      Tue, 18 Dec 2001 11:46:48 +0900
;;        ・syntax-symbol-prefix-p が t の時の変換で引数の順番を
;;          間違えていてエラーがでるのを修正。
;;
;;      [Version 0.0.0.5]
;;      Sat, 15 Dec 2001 11:19:03 +0900
;;        ・ML で亀井さんに教えていただいたキーワード検索の方法に変更。
;;          - タグをハイライトするかどうかを html-highlight-mode の値で判定
;;          - syntax-symbol-prefix-p が non-nil の場合のハイライト
;;          - syntax-table の option に *syntax-option-c-preprocessor* が
;;            指定されていた場合の動作
;;          上記 3 点について xyzzy と同様の動作になったと思います。
;;
;;      [Version 0.0.0.4]
;;      Fri, 14 Dec 2001 18:25:03 +0900
;;        ・tag のあるモードかどうかを syntax-table で判断するように。
;;
;;      Tue, 11 Dec 2001 10:30:34 +0900
;;        ・Memo 修正。
;;        ・<TITLE></TITLE> の間では半角スペースを &nbsp; に変換
;;          しないように変更。
;;
;;      [Version 0.0.0.3]
;;      Mon, 10 Dec 2001 17:58:20 +0900
;;        ・context をパースする際の message の位置を変更。
;;        ・行番号付き出力 buf2html-with-number 追加。
;;        ・HTML 出力後バッファの modify flag を nil に。
;;        ・その他修正。
;;
;;      [Version 0.0.0.2]
;;      Fri, 07 Dec 2001 07:40:23 +0900
;;        ・message の位置を修正。
;;        ・bgr2rgb を buf2html-bgr2rgb に名称変更。
;;        ・余分な HTML タグの削減。
;;        ・キーワードが大文字小文字を区別するかの判定。
;;        ・tag 文字 (syntax-open-tag-p, syntax-close-tag-p) を
;;          キーワードより優先させるように修正。
;;        ・その他修正。
;;
;;      [Version 0.0.0.1]
;;      Fri, 07 Dec 2001 02:37:41 +0900
;;        ・門田さんの mode2htm.l, ini2css.l を参考にして初版作成。
;;

;; Todo:
;;
;;      ・キーワードの最大長 (MAX_KWDLEN) を考慮するように
;;      ・正規表現キーワードの最大長 (MAX_KWDLEN) を考慮するように
;;      ・正規表現のコンパイル
;;
;;      ・正規表現キーワードの適用範囲の修正
;;      ・キーワードと正規表現キーワードの優先順位の関係の修正
;;      ・できれば行反転表示への対応
;;      ・制御文字の表示
;;      ・改行、タブ、EOF、全角スペース、半角スペースの表示
;;      ・行間への対応
;;      ・固定幅 bold 表示
;;      ・lang や charset へのまともな対応
;;      ・CSS を同一ファイルに含める動作モードの追加
;;      ・CSS を使わない動作モードの追加 (css, font)
;;      ・余分な HTML タグの削減
;;      ・TAB 文字への対処
;;      ・速度改善
;;

;; Memo:
;;      ・disp.cc をきちんと読む。
;;      ・（正規表現キーワードよりもキーワードの方が優先される。
;;          色が重ならないだけでなく、キーワード自体が重ならない。）
;;         上記は間違い。開始位置が先の方が優先されるよう。
;;         同じ開始位置の場合はキーワードが正規表現キーワードよりも
;;         優先される（多分）。
;;
;;      ・キーワードの色よりもタグの開始・終了の色の方が優先される。
;;        ただしタグの開始・終了文字の部分はキーワード構成部分となり得る。
;;      ・html-highlight-mode が non-nil の場合は :tag の中でしか context は
;;        切り替わらない。
;;      ・context が nil 中での :string は 終了の " 自体までだが、
;;        context が :tag 中での :string は終了の " の前まで。
;;        "abcdefghijklmn"    "abcdefghijklmn"
;;         ^^^^^^^^^^^^^^^ と  ^^^^^^^^^^^^^^ の違い。
;;      ・正規表現キーワードは指定されたコンテキスト内であれば、隣接した
;;        コンテキストをまたいでもよい。
;;        単一のコンテキスト内でキーワードが完結する必要はない。
;;        ("abc \"\" def" t (:color 1 0 :underline) (:string))
;;        は 2 つの :string コンテキストによる「"abc "" def"」 をキーワードと
;;        認識する。
;;      ・正規表現キーワードにて個々の色設定がなされていても、begin end により除外
;;        されている場合色はつかない。
;;      ・("123\\(45\\(67\\)89\\)0" nil ((1 . (:color 1)) (2 . (:color 2))) t 1 1)
;;        では、(:color 1) の色で 456789 に色がつくのではなく、67 には
;;        (:color 2) の色で色がつく。
;;        最後の begin end は色をつける point の範囲を group 番号で指定している。
;;      ・text-attribute に (:underline nil) 等を指定しても、
;;        (正規表現)キーワードで underline 等が指定されている場合は
;;        それらは無効化されない。
;;      ・color の nil と (:color nil) は異なる。
;;      ・color に nil を指定するとその色指定は無視されるよう。
;;
;;
;;      ・html-highlight-mode が non-nil の場合は基本的にキーワードは
;;        タグ内部のみだが、0.2.2.207 で追加された記述方法で
;;        nil context の中にもキーワード指定ができる。
;;        keyword-hash-table をよくみていないがもしかしたら、キーワードファイル
;;        自体を読んで parse しなければならない？
;;      ・ed::regexp-keyword-list は必ず (compile-regexp-keyword-list) されている？
;;      ・「正規表現のキーワード色分けの、グループごとの色指定」における
;;        「colorがnilなら、同一範囲にマッチした若いグループ番号の色。tなら元の色。」
;;        は具体的にどういうことなのか。「元の色」とは何か。
;;        「元の色」は「地の色」（「文字色」「背景色」）であっているのか。
;;        context は考慮する必要はないのか。
;;

;; Data structure:
;;
;;      <UNITS>  : (<UNIT>*)
;;      <UNIT>   : (<TYPE> . <RANGE>)
;;      <RANGES> : (<RANGE>*)
;;      <RANGE>  : (<FROM> . <TO>)
;;      <TYPE>   : (<keyword> . <INFO>)
;;      <FROM>   : <POINT>
;;      <TO>     : <POINT>
;;      <POINT>  : <number>
;;
;;      <number> : /[0-9]+/
;;      <keyword>: nil
;;               | :string
;;               | :comment
;;               | :tag
;;               | :buf2html-keyword
;;               | :buf2html-regexp-keyword
;;               | :buf2html-regexp-keyword-group
;;               | :buf2html-text-attribute
;;               | :buf2html-line-feed
;;               | :buf2html-url
;;
;;      <INFO>   : <TYPE> の <keyword> 毎に色々。
;;
;;        <keyword> == nil | :string | :comment | :tag
;;               : nil
;;
;;        <keyword> == :buf2html-keyword
;;               : compiled-color
;;
;;        <keyword> == :buf2html-regexp-keyword
;;               : regexp-keyword-group-units
;;
;;        <keyword> == :buf2html-regexp-keyword-group
;;               : compiled-color
;;
;;        <keyword> == :buf2html-text-attribute
;;               : (btag . etag)
;;
;;        <keyword> == :buf2html-line-feed
;;               : nil
;;
;;        <keyword> == :buf2html-url
;;               : nil
;;
;;
;;      ・<UNITS> を構成する <UNIT> は (<TYPE> . (<FROM> . <TO>)) の
;;        <FROM> で昇順ソートされていなければならない。
;;
;;      ・<TO> は実際には範囲に含まれない。
;;        <FROM>, <TO> は (buffer-substring <FROM> <TO>) となる値。
;;

;; Licence:
;;
;;    buf2html は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2006, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "buf2html")

(in-package "editor")

(export '(*buf2html-version*
          *buf2html-color-context*
          *buf2html-color-keyword*
          *buf2html-color-regexp-keyword*
          *buf2html-color-text-attribute*
          *buf2html-anchor-url*
          *buf2html-lower-case*
          *buf2html-internal-xyzzy-css*
          *buf2html-auto-mode-parameter-string*
          *buf2html-date-format*
          *buf2html-time-stamp-start*
          *buf2html-time-stamp-end*
          *buf2html-buffer-tmp*
          *buf2html-buffer-css*
          *buf2html-buffer-html*
          *buf2html-convert-half-space*
          *buf2html-number-link*
          *buf2html-string-encode-alist*
          *buf2html-char-code-limit*
          *buf2html-css-list*
          *buf2html-internal-css-alist*
          *buf2html-region-css-class-list*
          *buf2html-ignore-paren-highlight*
          *buf2html-mode-function*
          *buf2html-url-scheme-regexp*
          *buf2html-url-chars-regexp*
          *buf2html-url-mail-address-regexp*
          *buf2html-file-dialog-filter*
          *buf2html-encoding*
          *buf2html-eol-code*
          *buf2html-post-convert-buffer-hook*
          buf2html
          buf2html-with-number
          buf2html-region
          buf2html-region-complete
          buf2html-downcase-tag-region
          buf2html-get-region-string
          buf2html-copy-region-as-kill
          buf2html-copy-region-to-clipboard
          buf2html-copy-selection
          buf2html-copy-selection-to-clipboard
          buf2html-get-ini2css-string
          buf2html-save-as-dialog
          buf2html-insert-menu-items
          buf2html-delete-menu
          buf2html-set-app-menu
          buf2html-set-app-popup-menu
          ini2css-file
          ini2css-buffer))

(defconstant *buf2html-version* "0.0.0.15"
  "buf2html: Version")

(defvar *buf2html-color-context* t
  "buf2html: context の解析を行う")
(defvar *buf2html-color-keyword* t
  "buf2html: キーワードの解析を行う")
(defvar *buf2html-color-regexp-keyword* t
  "buf2html: 正規表現キーワードの解析を行う")
(defvar *buf2html-color-text-attribute* t
  "buf2html: text-attribute の解析を行う")
(defvar *buf2html-anchor-url* t
  "buf2html: URL の解析を行い <A> タグをつける")

(defvar *buf2html-lower-case* nil
  "buf2html: タグを小文字にする")
(defvar *buf2html-internal-xyzzy-css* nil
  "buf2html: xyzzy.ini から生成した CSS を内部に含める")

(defvar *buf2html-auto-mode-parameter-string* "Mode: html"
  "buf2html: HTML 文書に含める xyzzy 用のモード指定")
(defvar *buf2html-date-format* "%a, %d %b %Y %H:%M:%S %Z"
  "buf2html: HTML 文書に含める日付書式")
(defvar *buf2html-time-stamp-start* "Last updated: <"
  "buf2html: 日付の前の文字列")
(defvar *buf2html-time-stamp-end* ">"
  "buf2html: 日付の後の文字列")

(defvar *buf2html-buffer-tmp* " *buf2html: Tmp*"
  "buf2html: 作業バッファ名")
(defvar *buf2html-buffer-css* "*buf2html: CSS*"
  "buf2html: スタイルシート出力バッファ名")
(defvar *buf2html-buffer-html* "*buf2html: HTML*"
  "buf2html: HTML 文書出力バッファ名")

(defvar *buf2html-convert-half-space* nil
  "buf2html: 半角スペースを必ず &nbsp; に変換")
(defvar *buf2html-number-link* t
  "buf2html: 行番号出力時、行番号の <A> タグを付加")

(defvar *buf2html-string-encode-alist*
  '(("&" . "&amp;")
    ("<" . "&lt;")
    (">" . "&gt;")
    ( "\"" . "&quot;")
;   " " は状況に応じて変換
;   (" " . "&nbsp;")
    )
  "buf2html: 変換する文字参照リスト")

(defvar *buf2html-char-code-limit* 128
  "buf2html: syntax-table を調べる char-code の限界
全て調べる場合は lisp:char-code-limit を指定")

(defvar *buf2html-css-list*
  '("xyzzy.css")
  "buf2html: スタイルシートのリスト")
(defvar *buf2html-internal-css-alist*
  '(("A.buf2html" . ("text-decoration: none")))
  "buf2html: 内部 CSS 指定連想リスト")
(defvar *buf2html-region-css-class-list*
  '("bgcolor" "border")
  "buf2html: buf2html-region での <PRE> タグのクラス")

(defvar *buf2html-ignore-paren-highlight* nil
  "buf2html: 喜多さんの paren.l の効果を変換時無効化")

(defvar *buf2html-mode-function* 'ed::html-mode
  "buf2html: モード指定 function")

(defvar *buf2html-url-scheme-regexp*
  "\\(http\\|https\\|ftp\\|news\\|nntp\\|wais\\|telnet\\|mailto\\|gopher\\|ttp\\):"
  "buf2html: URL scheme の正規表現")
(defvar *buf2html-url-chars-regexp*
  "[-a-zA-Z0-9_/~.@?&=;+(),'$!*:#%]+"
  "buf2html: URL の scheme 以外の部分の正規表現")
(defvar *buf2html-url-mail-address-regexp*
  "[-a-zA-Z0-9_.]+@[-a-zA-Z0-9_]+\\(?:\\.[-a-zA-Z0-9_]+\\)+"
  "buf2html: メールアドレスの正規表現")

(defvar *buf2html-file-dialog-filter*
  '(("HTML(*.htm;*.html)" . "*.htm;*.html")
    ("すべてのファイル(*.*)" . "*.*"))
  "buf2html: HTML形式で名前を付けて保存ダイアログでのフィルタ")

(defvar *buf2html-encoding* nil
  "buf2html: 出力バッファのエンコーディング指定")
(defvar *buf2html-eol-code* nil
  "buf2html: 出力バッファの改行コード指定")

(defvar *buf2html-post-convert-buffer-hook* nil
  "buf2html: 変換後、出力バッファをカレントバッファとして動作するフック")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-with-number
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-with-number ()
  "buf2html: xyzzy の表示に従ってバッファを行番号つきで HTML に変換"
  (interactive)
  (buf2html t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-region
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-region (from to &optional print-header print-footer nomsg)
  "buf2html: xyzzy の表示に従ってリージョンを部分的な HTML に変換"
  (interactive "r")
  (save-restriction
    (narrow-to-region from to)
    (buf2html nil t :print-header print-header :print-footer print-footer :nomsg nomsg)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-region-complete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-region-complete (from to)
  "buf2html: xyzzy の表示に従ってリージョンを完全な HTML に変換"
  (interactive "r")
  (buf2html-region from to t t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html (&optional line-number-p region-p
                 &key (print-header t) (print-footer t)
                      (internal-css-p nil sv-internal-css-p)
                      nomsg)
  "buf2html: xyzzy の表示に従ってバッファを HTML に変換"
  (interactive "p")
  (let ((point-min (point-min)) (point-max (point-max))
        (compiled-color-tag-table (make-hash-table))
        all-units keyword-units regexp-keyword-units text-attribute-units
        tag-char-units line-feed-units
        opitimized-keyword-color-list line-feed-p
        (source-buffer (selected-buffer))
        (paren-status (and *buf2html-ignore-paren-highlight*
                           (fboundp 'paren-highlight) *paren-status*)))
    (unless sv-internal-css-p
      (setq internal-css-p *buf2html-internal-xyzzy-css*))
    (long-operation
      ;; paren.l の効果を解除
      (when paren-status
        (turn-off-paren)
        (paren-highlight))
      (unwind-protect
          (save-excursion
            (buf2html-set-buffer *buf2html-buffer-html*)
            (save-excursion
              (set-buffer *buf2html-buffer-html*)
              (set-buffer-fileio-encoding (or *buf2html-encoding*
                                              (buffer-fileio-encoding source-buffer)))
              (set-buffer-eol-code (or *buf2html-eol-code*
                                       (buffer-eol-code source-buffer))))
            (with-output-to-buffer (*buf2html-buffer-html*)
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; context
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (if *buf2html-color-context*
                  (setq all-units (buf2html-get-units-context :nomsg nomsg))
                (setq all-units (cons nil (cons (point-min) (point-max)))))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; tag-char
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (if html-highlight-mode
                  (setq tag-char-units
                        (buf2html-get-units-tag-char
                         (buf2html-get-ranges-if-context all-units '(:tag)))))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; keyword
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (when (and *buf2html-color-context*
                         *buf2html-color-keyword*
                         (boundp 'ed::keyword-hash-table))

                (setq keyword-units
                      (buf2html-get-units-keyword
                       (buf2html-range-concatenate
                        (if html-highlight-mode
                            (buf2html-get-ranges-if-context all-units '(:tag))
                          (buf2html-get-ranges-if-not-context all-units '(:string :comment))))
                       :nomsg nomsg))

                ;; keyword の compiled-color の値(数)にあった HTML タグの登録
                (buf2html-add-compiled-color-tag-hash-table
                 compiled-color-tag-table (mapcar #'cdar keyword-units))

                ;; keyword の範囲を適用
                (unless nomsg
                  (message "Merge keyword range."))
                (setq all-units (buf2html-unit-cover all-units keyword-units))

                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;; c-preprocessor 用の特殊キーワード検索
                (when (not (zerop (logand (get-syntax-option (syntax-table))
                                          *syntax-option-c-preprocessor*)))
                  (setq keyword-units
                        (buf2html-get-units-keyword-c-preprocessor
                         (buf2html-range-concatenate
                          (if html-highlight-mode
                              (buf2html-get-ranges-if-context all-units '(:tag))
                            (buf2html-get-ranges-if-not-context all-units '(:string :comment))))
                         :nomsg nomsg))

                  ;; keyword の compiled-color の値(数)にあった HTML タグの登録
                  (buf2html-add-compiled-color-tag-hash-table
                   compiled-color-tag-table (mapcar #'cdar keyword-units))

                  ;; keyword の範囲を適用
                  (unless nomsg
                    (message "Merge c preprocessor keyword range."))
                  (setq all-units (buf2html-unit-cover all-units keyword-units))
                  )
                )

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; regexp-keyword
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (when (and *buf2html-color-context*
                         *buf2html-color-regexp-keyword*
                         (boundp 'ed::regexp-keyword-list))
                ;; 正規表現キーワードの compiled-color の値にあった HTML タグの登録
                (buf2html-add-compiled-color-tag-hash-table
                 compiled-color-tag-table
                 (buf2html-make-regexp-keyword-color-list ed::regexp-keyword-list))

                (let (regexp colors compiled-context begin end (i 0)
                      (regexp-keyword-list-length (length ed::regexp-keyword-list)))
                  (dolist (regexp-keyword ed::regexp-keyword-list)
                    (incf i)
                    (unless nomsg
                      (message "Parse regexp keyword: ~D/~D" i regexp-keyword-list-length))
;                   (setq regexp (car regexp-keyword))
;                   (setq colors (cadr regexp-keyword))
                    (setq compiled-context (caddr regexp-keyword))
;                   (setq begin (cadddr regexp-keyword))
;                   (setq end (car (cddddr regexp-keyword)))
                    (setq regexp-keyword-units
                          (buf2html-get-units-regexp-keyword
                           (buf2html-range-concatenate
                            (buf2html-get-ranges-if-context
                             all-units
                             (buf2html-decode-compiled-context compiled-context)))
                           regexp-keyword))
                    ;; regexp-keyword の範囲を適用
                    (unless nomsg
                      (message "Merge regexp keyword range: ~D/~D" i regexp-keyword-list-length))
                    (setq all-units
                          (buf2html-unit-cover all-units regexp-keyword-units)))))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; tag-char をキーワードよりも優先
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (when html-highlight-mode
                (unless nomsg
                  (message "Merge tag-char range."))
                (setq all-units (buf2html-unit-cover all-units tag-char-units)))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; 最適化
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (setq all-units (buf2html-unit-concatenate all-units))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; 行分割 (line-feed)
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (setq line-feed-p line-number-p)
              (when line-feed-p
                (setq line-feed-units (buf2html-get-units-line-feed))
                (setq all-units (buf2html-unit-cover all-units line-feed-units)))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; text-attribute
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (when *buf2html-color-text-attribute*
                (unless nomsg
                  (message "Parse text attribute."))
                (setq text-attribute-units (buf2html-get-units-text-attribute)))

              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;; 出力
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              (when print-header
                (buf2html-print-header line-number-p region-p internal-css-p))
              (buf2html-print-body all-units compiled-color-tag-table
                                   text-attribute-units line-number-p region-p
                                   nomsg)
              (when print-footer
                (buf2html-print-footer))
              (save-excursion
                (set-buffer *buf2html-buffer-html*)
                (run-hooks '*buf2html-post-convert-buffer-hook*))
              (unless nomsg
                (message "Output HTML: done.")))
            (set-buffer-modified-p nil *buf2html-buffer-html*))
        ;; paren.l の効果を復元
        (when paren-status
          (save-excursion
            (set-buffer source-buffer)
            (turn-on-paren)
            (paren-highlight))))
      (pop-to-buffer *buf2html-buffer-html*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-copy-region-as-kill
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-copy-region-as-kill (from to &optional complete)
  "buf2html: リージョンを部分的な HTML に変換し *kill-ring* へ追加"
  (interactive "r")
  (kill-new
   (buf2html-get-region-string from to complete)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-copy-region-to-clipboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-copy-region-to-clipboard (from to &optional complete)
  "buf2html: リージョンを部分的な HTML に変換し clipboard へ登録"
  (interactive "r")
  (copy-to-clipboard
   (buf2html-get-region-string from to complete)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-copy-selection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-copy-selection (&optional complete)
  "buf2html: 選択範囲を部分的な HTML に変換し *selection-ring* へ追加"
  (interactive "P")
  (let ((type (get-selection-type)))
    (when (member type '(1 2))
      (selection-start-end (start end)
        (selection-new
         1 (buf2html-get-region-string start end complete))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-copy-selection-to-clipboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-copy-selection-to-clipboard (&optional complete)
  "buf2html: 選択範囲を部分的な HTML に変換し clipboard へ登録"
  (interactive "P")
  (let ((type (get-selection-type)))
    (when (member type '(1 2))
      (selection-start-end (start end)
        (copy-to-clipboard
         (buf2html-get-region-string start end complete))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-get-region-string (from to &optional complete nomsg)
  "buf2html: リージョンを HTML に変換した文字列を作成"
  (let ((*buf2html-buffer-html* (concat " " *buf2html-buffer-html*))
        (*buf2html-mode-function* nil) (str ""))
    (declare (special *buf2html-buffer-html*))
    (declare (special *buf2html-mode-function*))
    (save-window-excursion
      (unwind-protect
          (progn
            (setq *buf2html-buffer-html*
                  (buffer-name (create-new-buffer *buf2html-buffer-html*)))
            (buf2html-region from to complete complete nomsg)
            (setq str (buffer-substring (point-min)
                                        (if complete (point-max) (1- (point-max))))))
        (delete-buffer (find-buffer *buf2html-buffer-html*))))
    str))

(defun buf2html-get-units-url (&key begin end)
  "buf2html: URL の範囲のリストを作成"
  (let (url-units
        url-regexp)
    (setq url-regexp
          (compile-regexp
           (concat "\\(" *buf2html-url-scheme-regexp* *buf2html-url-chars-regexp* "\\|" *buf2html-url-mail-address-regexp* "\\)")))
    (save-excursion
      (save-restriction
        (unless begin
          (setq begin (point-min)))
        (unless end
          (setq end (point-max)))
        (goto-char begin)
        (widen)
        (narrow-to-region begin end)
        (while (scan-buffer url-regexp :regexp t :tail t)
          (push (cons (cons :buf2html-url nil)
                      (cons (match-beginning 0) (match-end 0)))
                url-units))))
    (nreverse url-units)))

(defun buf2html-get-units-context (&key begin end nomsg)
  "buf2html: context の範囲のリストを作成"
  (let ((point-min (point-min)) (point-max (point-max))
        rate pre-rate all-units context pre-context from to range)
    (save-excursion
      (unless begin
        (setq begin (point-min)))
      (unless end
        (setq end (point-max)))
      (setq from begin)
      (goto-char from)
      (if (= begin 0)
          (setq context nil)
        (setq context (parse-point-syntax (1- (point)))))
      (setq rate -1)
      (while (and (<= (point) end) (not (eobp)))
        (setq pre-context context)
        (setq context (parse-point-syntax (point)))
        (unless nomsg
          (setq pre-rate rate)
          (setq rate (floor (* 100 (/ (- (point) point-min) (- point-max point-min)))))
          (if (/= pre-rate rate)
              (message "Parse context: ~2D%" rate)))
        (unless (eq pre-context context)
          (do-events)
          ;; とりあえず 0.2.2.219 での context を元に適当にやってみる
          (cond
           ; nil から context が切り替わる際は一つ前から
           ((eq pre-context nil)
            (setq to (1- (point))))
           ; nil に切り替わる際はそのまま
           ((eq context nil)
            (setq to (point)))
           ;; :tag については html(+)-mode でしか試していないのであってないかも
           ((eq pre-context :tag)
            (setq to (1- (point))))
           ((and (eq context :tag)
                 (eq pre-context :string))
            (setq to (1+ (point))))
           (t
            (setq to (point))))

          (setq range (cons from to))
          (when (< from to)
            (push (cons (cons pre-context nil) range) all-units)
            (setq from to))
#|
          ; こんな感じのことをすると少しは早くなるかも。でもバグの元かも。
          (cond
           ((eq context :string)
            (skip-syntax-spec-forward "^\"")
            (backward-char)))
|#
          )
        (forward-char))
      (setq range (cons from end))
      (if (< from end)
          (push (cons (cons pre-context nil) range) all-units)))
    (unless nomsg
      (message "Parse context: done."))
    (nreverse all-units)))

(defun buf2html-get-units-line-feed ()
  "buf2html: 改行文字の範囲（位置）のリストを作成"
  (let (line-feed-units point)
    (goto-char (point-min))
    (while (scan-buffer "\n" :tail t)
      (setq point (1- (point)))
      (push (cons (cons :buf2html-line-feed nil) (cons point (1+ point)))
            line-feed-units))
    (nreverse line-feed-units)))

(defun buf2html-get-units-tag-char (ranges)
  "buf2html: タグの開始、終了文字の範囲（位置）のリストを作成"
  (let (tag-char-units from to c)
    (dolist (range ranges)
      (setq from (car range))
      (setq to (cdr range))
      (when (< from to)
        (setq c (char (buffer-substring from (1+ from)) 0))
        (if (or (syntax-open-tag-p c) (syntax-close-tag-p c))
            (push (cons (cons :tag nil) (cons from (1+ from))) tag-char-units))
        (when (< from (1- to))
          (setq c (char (buffer-substring (1- to) to) 0))
          (if (or (syntax-open-tag-p c) (syntax-close-tag-p c))
              (push (cons (cons :tag nil) (cons (1- to) to)) tag-char-units)))))
    (nreverse tag-char-units)))

(defun buf2html-get-units-text-attribute ()
  "buf2html: text-attribute の範囲のリストを作成"
  (let (text-attribute-units btag etag range key value)
    (dolist (text-attributes (list-text-attributes (point-min) (point-max)))
      (setq range (cons (car text-attributes) (cadr text-attributes)))
      (setq text-attributes (cdddr text-attributes))
      (setq btag "")
      (setq etag "")
      (while text-attributes
        (setq key (car text-attributes))
        (setq value (cadr text-attributes))
        (setq text-attributes (cddr text-attributes))
        (case key
          (:foreground
           (setq btag (format nil "~A<SPAN class=\"fg~D\">" btag value))
           (setq etag (format nil "</SPAN>~A" etag)))
          (:background
           (setq btag (format nil "~A<SPAN class=\"bg~D\">" btag value))
           (setq etag (format nil "</SPAN>~A" etag)))
          (:bold
           (when value
             (setq btag (concat btag "<SPAN class=\"bold\">"))
             (setq etag (concat "</SPAN>" etag))))
          (:underline
           (when value
             (setq btag (concat btag "<SPAN class=\"underline\">"))
             (setq etag (concat "</SPAN>" etag))))
          (:strike-out
           (when value
             (setq btag (concat btag "<SPAN class=\"strike-out\">"))
             (setq etag (concat "</SPAN>" etag))))))
      (push (cons (cons :buf2html-text-attribute (cons btag etag)) range)
            text-attribute-units))
    (nreverse text-attribute-units)))

(defun buf2html-get-units-keyword (ranges &key nomsg)
  "buf2html: キーワードの範囲のリストを作成"
  (let ((point-min (point-min)) (point-max (point-max))
        keyword-units from to regexp compiled-color
        str begin end)
    (unless (hash-table-p ed::keyword-hash-table)
      (return-from buf2html-get-units-keyword keyword-units))
    (dolist (range ranges)
      (setq from (car range))
      (setq to (cdr range))
      (goto-char from)
      (unless nomsg
        (message "Parse keyword: ~2D%" (floor (* 100 (/ (- from point-min)
                                                        (- point-max point-min))))))
      (setq regexp (compile-regexp "\\(\\s@\\|\\s{\\|\\s\\\\)?\\(\\sw\\|\\s_\\)+"))
      (while (scan-buffer regexp :limit to)
        (setq str (match-string 0))
        (setq begin (match-beginning 0))
        (setq end (match-end 0))
        (when (syntax-symbol-prefix-p (char str 0))
          (setq str (substring str 1))
          (setq begin (1- begin)))
        (multiple-value-bind (compiled-color init)
            (gethash str ed::keyword-hash-table)
          (when init
            (push (cons (cons :buf2html-keyword compiled-color)
                        (cons begin end)) keyword-units)))
        (goto-char end)))
    (unless nomsg
      (message "Parse keyword: done."))
    (nreverse keyword-units)))

(defun buf2html-get-units-keyword-c-preprocessor (ranges &key nomsg)
  "buf2html: C preprocessor 用キーワードの範囲のリストを作成"
  (let ((point-min (point-min)) (point-max (point-max))
        keyword-units from to regexp compiled-color
        str begin end)
    (unless (hash-table-p ed::keyword-hash-table)
      (return-from buf2html-get-units-keyword-c-preprocessor keyword-units))
    (dolist (range ranges)
      (setq from (car range))
      (setq to (cdr range))
      (goto-char from)
      (unless nomsg
        (message "Parse c preprocessor keyword: ~2D%" (floor (* 100 (/ (- from point-min)
                                                                       (- point-max point-min))))))
      (setq regexp (compile-regexp "#[ \t]*\\(\\(\\sw\\|\\s_\\)+\\)"))
      (while (scan-buffer regexp :limit to)
        (setq str (concat "#" (match-string 1)))
        (setq begin (match-beginning 0))
        (setq end (match-end 0))
        (multiple-value-bind (compiled-color init)
            (gethash str ed::keyword-hash-table)
          (when init
            (push (cons (cons :buf2html-keyword compiled-color)
                        (cons begin end)) keyword-units)))
        (goto-char end)))
    (unless nomsg
      (message "Parse c preprocessor keyword: done."))
    (nreverse keyword-units)))

(defun buf2html-get-units-regexp-keyword (ranges regexp-keyword)
  "buf2html: 正規表現キーワードの範囲のリストを作成"
  (let ((regexp (car regexp-keyword))
        (colors (cadr regexp-keyword))
        (compiled-context (caddr regexp-keyword))
        (begin (cadddr regexp-keyword))
        (end (car (cddddr regexp-keyword)))
        regexp-keyword-units from to
        whole-range enable-range regexp-keyword-group-units
        group-number group-range compiled-color)
    (dolist (range ranges)
      (setq from (car range))
      (setq to (cdr range))
      (goto-char from)
      (while (scan-buffer regexp :tail t :limit to)
        (setq whole-range (cons (match-beginning 0) (match-end 0)))
        (setq enable-range
              (cons (if (minusp begin) (match-end (* -1 begin)) (match-beginning begin))
                    (if (minusp end) (match-beginning (* -1 end)) (match-end end))))
        (setq whole-range enable-range)
        (setq regexp-keyword-group-units
              (list (cons (cons :buf2html-regexp-keyword-group nil)
                          (copy-list whole-range))))
        (cond
         ((not (consp colors))
          (setq compiled-color colors)
          (setq regexp-keyword-group-units
                (buf2html-unit-cover
                 regexp-keyword-group-units
                 (list (cons (cons :buf2html-regexp-keyword-group compiled-color)
                             enable-range)))))
         (t
          (dolist (color (sort colors #'< :key #'car)); group 順にソート
            (setq group-number (car color))
            (setq compiled-color (cdr color))
            (setq group-range (cons (match-beginning group-number)
                                    (match-end group-number)))
            
            (when (and compiled-color                 ; compiled-color が nil でない
                       (buf2html-in-range-p group-range enable-range))
              (setq regexp-keyword-group-units
                    (buf2html-unit-cover
                     regexp-keyword-group-units
                     (list (cons (cons :buf2html-regexp-keyword-group compiled-color)
                                 group-range))))))))
        (push (cons (cons :buf2html-regexp-keyword regexp-keyword-group-units) whole-range)
              regexp-keyword-units)))
    (nreverse regexp-keyword-units)))

(defun buf2html-make-regexp-keyword-color-list (regexp-keyword-list)
  "buf2html: regexp-keyword-list から color のリストを作成"
  (let (compiled-color-list)
    (when regexp-keyword-list
      ;; nil は使うので必ずいれておく。
      (pushnew nil compiled-color-list :test 'eql)
      (dolist (compiled-colors (mapcar #'cadr regexp-keyword-list))
        (cond
         ((consp compiled-colors)
          (dolist (compiled-color (mapcar #'cdr compiled-colors))
            (pushnew compiled-color compiled-color-list :test 'eql)))
         ((numberp compiled-colors)
          (pushnew compiled-colors compiled-color-list :test 'eql))
         (t
          (pushnew compiled-colors compiled-color-list :test 'eql)))))
    compiled-color-list))

(defun buf2html-add-compiled-color-tag-hash-table (hash-table compiled-colors)
  "buf2html: compiled-colors に対応する HTML タグを hash-table に登録"
  (when (hash-table-p hash-table)
    (dolist (compiled-color compiled-colors)
      (multiple-value-bind (value init)
          (gethash compiled-color hash-table)
        (unless init
          (setf (gethash compiled-color hash-table)
                (buf2html-make-compiled-color-tag compiled-color)))))
    hash-table))

;; 正規表現キーワードのグループ毎の色指定での
;; color 部分が t の場合の動作がよくわからない。
;; nil のときは、compiled-color は nil
;; t   のときは、compiled-color は 0
(defun buf2html-make-compiled-color-tag (compiled-color)
  "buf2html: compiled-color に対応する HTML タグを作成"
  (unless (numberp compiled-color)
    (return-from buf2html-make-compiled-color-tag (cons "" "")))
  (let ((fg-bg-p (= (logand compiled-color #x1) #x1))
        (line-p (= (logand compiled-color #x2) #x2))
        (bold-p (= (logand compiled-color #x200000) #x200000))
        (underline-p (= (logand compiled-color #x800000) #x800000))
        (strike-out-p (= (logand compiled-color #x1000000) #x1000000))
        (color (logand compiled-color (lognot #x1)
                       (lognot #x2) (lognot #x200000) (lognot #x800000) (lognot #x1000000)))
        (btag "") (etag ""))

    (cond
     (fg-bg-p
      (setq btag (format nil "<SPAN class=\"fg~D bg~D\">"
                         (floor (logand color #x1f00) #x200)
                         (floor (logand color #x1f0000) #x20000)))
      (setq etag "</SPAN>"))
     (t
      (when (hash-table-p ed::*keyword-translate-hash-table*)
        (cond
         ((= color 0)
          (setq btag "" etag ""))
         ((= color (gethash #\0 ed::*keyword-translate-hash-table*));keyword1
          (setq btag "<SPAN class=\"keyword1\">" etag "</SPAN>"))
         ((= color (gethash #\1 ed::*keyword-translate-hash-table*));keyword2
          (setq btag "<SPAN class=\"keyword2\">" etag "</SPAN>"))
         ((= color (gethash #\2 ed::*keyword-translate-hash-table*));keyword3
          (setq btag "<SPAN class=\"keyword3\">" etag "</SPAN>"))
         ((= color (gethash #\3 ed::*keyword-translate-hash-table*));keyword1 反転
          (setq btag "<SPAN class=\"keyword1inverse\">" etag "</SPAN>"))
         ((= color (gethash #\4 ed::*keyword-translate-hash-table*));keyword2 反転
          (setq btag "<SPAN class=\"keyword2inverse\">" etag "</SPAN>"))
         ((= color (gethash #\5 ed::*keyword-translate-hash-table*));keyword3 反転
          (setq btag "<SPAN class=\"keyword3inverse\">" etag "</SPAN>"))
         ((= color (gethash #\S ed::*keyword-translate-hash-table*));string
          (setq btag "<SPAN class=\"string\">" etag "</SPAN>"))
         ((= color (gethash #\T ed::*keyword-translate-hash-table*));tag
          (setq btag "<SPAN class=\"tag\">" etag "</SPAN>"))
         ((= color (gethash #\C ed::*keyword-translate-hash-table*));comment
          (setq btag "<SPAN class=\"comment\">" etag "</SPAN>"))))))

    ;; bold
    (when bold-p
      (setq btag (concat btag "<SPAN class=\"bold\">"))
      (setq etag (concat "</SPAN>" etag)))
    ;; underline
    (when underline-p
      (setq btag (concat btag "<SPAN class=\"underline\">"))
      (setq etag (concat "</SPAN>" etag)))
    ;; strike-out
    (when strike-out-p
      (setq btag (concat btag "<SPAN class=\"strike-out\">"))
      (setq etag (concat "</SPAN>" etag)))
    ;; line (どうすればよい？)
    (when line-p
      t)
    (cons btag etag)))

(defun buf2html-decode-compiled-context (compiled-context)
  "buf2html: compiled-context をデコードし context のリストを作成"
  (let (context-list)
    (if (= (logand compiled-context #x1) #x1)
        (push nil context-list))
    (if (= (logand compiled-context #x2) #x2)
        (push :string context-list))
    (if (= (logand compiled-context #x4) #x4)
        (push :tag context-list))
    (if (= (logand compiled-context #x8) #x8)
        (push :comment context-list))
    context-list))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; range, unit 操作関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-in-range-p (position_or_range range)
  "buf2html: range に position_or_range が含まれるかどうか"
  (if (null range)
      nil
    (cond
     ((numberp position_or_range)
      (if (and (<= (car range) position_or_range)
               (<= position_or_range (cdr range)))
          range
        nil))
     ((consp position_or_range)
      (if (and (<= (car range) (car position_or_range))
               (<= (cdr position_or_range) (cdr range)))
          range
        nil))
     (t nil))))

(defun buf2html-range-concatenate (ranges)
  "buf2html: 隣接した range を連結"
  (let (return-ranges work-range)
    (unless ranges
      (return-from buf2html-range-concatenate nil))
    (setq work-range (car ranges))
    (dolist (range (cdr ranges))
      (cond
       ((= (cdr work-range) (car range))
        (setq work-range (cons (car work-range) (cdr range))))
       (t
        (push work-range return-ranges)
        (setq work-range range))))
    (push work-range return-ranges)
    (nreverse return-ranges)))

(defun buf2html-unit-concatenate (units)
  "buf2html: 隣接した同じ type の unit を連結"
  (let (return-units work-unit)
    (unless units
      (return-from buf2html-unit-concatenate nil))
    (setq work-unit (car units))
    (dolist (unit (cdr units))
      (cond
       ((and (equal (car work-unit) (car unit))
             (= (cddr work-unit) (cadr unit)))
        (setq work-unit (cons (car work-unit)
                              (cons (cadr work-unit) (cddr unit)))))
       (t
        (push work-unit return-units)
        (setq work-unit unit))))
    (push work-unit return-units)
    (nreverse return-units)))

(defun buf2html-unit-cover (base-units priority-units)
  "buf2html: base-units に priority-units をかぶせる"
  (let (return-units base-type-range priority-type-range base-unit priority-unit start)
    (setq start 0)
    (setq base-unit (car base-units))
    (setq base-units (cdr base-units))
    (setq priority-unit (car priority-units))
    (setq priority-units (cdr priority-units))
    (while (and base-unit priority-unit)
      (cond
       ;; 重ならず base が前
       ((<= (cddr base-unit) (cadr priority-unit))
        (if (< (cadr base-unit) (cddr base-unit))
            (push base-unit return-units))
        (setq start (cddr base-unit)))
       ;; 重ならず priority が前
       ((<= (cddr priority-unit) (cadr base-unit))
        (if (< (cadr priority-unit) (cddr priority-unit))
            (push priority-unit return-units))
        (setq start (cddr priority-unit))
        (setq priority-unit nil))
       ;; priority が base を含む
       ((and (<= (cadr priority-unit) (cadr base-unit))
             (<= (cddr base-unit) (cddr priority-unit)))
        (if (< (cadr priority-unit) (cddr priority-unit))
            (push priority-unit return-units))
        (setq start (cddr priority-unit))
        (setq priority-unit nil))
       ;; base が priority を含む
       ((and (<= (cadr base-unit) (cadr priority-unit))
             (<= (cddr priority-unit) (cddr base-unit)))
        (if (< (cadr base-unit) (cadr priority-unit))
            (push (cons (car base-unit)
                        (cons (cadr base-unit) (cadr priority-unit))) return-units))
        (if (< (cadr priority-unit) (cddr priority-unit))
            (push priority-unit return-units))
        (setq start (cddr priority-unit))
        (setq priority-unit nil))
       ;; 重なり priority が前
       ((<= (cadr priority-unit) (cadr base-unit))
        (if (< (cadr priority-unit) (cddr priority-unit))
            (push priority-unit return-units))
        (setq start (cddr priority-unit))
        (setq priority-unit nil))
       ;; 重なり priority が後
       (t
        (if (< (cadr base-unit) (cadr priority-unit))
            (push (cons (car base-unit)
                        (cons (cadr base-unit) (cadr priority-unit))) return-units))
        (if (< (cadr priority-unit) (cddr priority-unit))
            (push priority-unit return-units))
        (setq start (cddr priority-unit))
        (setq priority-unit nil)))

      (unless priority-unit
        (setq priority-unit (car priority-units))
        (setq priority-units (cdr priority-units)))
      (while (and base-unit (<= (cddr base-unit) start))
        (setq base-unit (car base-units))
        (setq base-units (cdr base-units)))
      (if (and base-unit (< (cadr base-unit) start))
          (setq base-unit (cons (car base-unit) (cons start (cddr base-unit)))))
      )
    (cond
     (base-unit
      (while base-unit
        (if (< (cadr base-unit) (cddr base-unit))
            (push base-unit return-units))
        (setq base-unit (car base-units))
        (setq base-units (cdr base-units))))
     (priority-unit
      (while priority-unit
        (if (< (cadr priority-unit) (cddr priority-unit))
            (push priority-unit return-units))
        (setq priority-unit (car priority-units))
        (setq priority-units (cdr priority-units)))))
    (nreverse return-units)))

(defun buf2html-get-ranges-if-context (units contexts)
  "buf2html: contexts に含まれる context である unit の range のリストを返す"
  (mapcar #'cdr
          (remove contexts units
                  :test #'(lambda (contexts context)
                            (not (position context contexts)))
                  :key #'caar)))

(defun buf2html-get-ranges-if-not-context (units contexts)
  "buf2html: contexts に含まれない context である unit の range のリストを返す"
  (mapcar #'cdr
          (remove contexts units
                  :test #'(lambda (contexts context)
                            (position context contexts))
                  :key #'caar)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 出力関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-protect-string (body &optional convert-half-space-p)
  "buf2html: 文字参照を変換した文字列を返す"
  (dolist (cell *buf2html-string-encode-alist*)
    (setq body (substitute-string body (car cell) (cdr cell))))
  (if convert-half-space-p
      (setq body (substitute-string body " " "&nbsp;")))
  body)

(defun buf2html-convert-region (begin end
                                &key btag etag
                                     (protect-p t) convert-half-space-p anchor-p)
  "buf2html: 末端文字列範囲を変換した文字列を返す"
  (unless anchor-p
    (return-from buf2html-convert-region
      (buf2html-protect-string (buffer-substring begin end) convert-half-space-p)))
  (let ((url-units (buf2html-get-units-url :begin begin :end end))
        (from begin) str str-list)
    (when (or (null btag) (equal btag ""))
      (setq btag "<SPAN class=\"fg0\">"
            etag "</SPAN>"))
    (dolist (unit url-units)
      (push (buf2html-protect-string (buffer-substring from (cadr unit))
                                     convert-half-space-p)
            str-list)
      (setq str (buf2html-protect-string
                 (buffer-substring (cadr unit) (cddr unit))
                 convert-half-space-p))
      (push (format nil "<A class=\"buf2html\" href=\"~A\">~A~A~A</A>"
                    (cond
                     ((string-match (concat "^" *buf2html-url-mail-address-regexp*) str)
                      (concat "mailto:" str))
                     ((string-match "^ttp://" str)
                      (concat "h" str))
                     (t str))
                    btag str etag) str-list)
      (setq from (cddr unit)))
    (push (buf2html-protect-string (buffer-substring from end)
                                   convert-half-space-p)
          str-list)
;    (msgbox "~{~A~}" (reverse str-list))
    (format nil "~{~A~}" (nreverse str-list))))

(defun buf2html-print-header (&optional line-number-p region-p internal-css-p)
  "buf2html: HTML の開始部分を出力"
  (let (lang title charset encoding-display-name
        (from (buffer-stream-point *standard-output*)))
    (if (setq title (get-buffer-file-name))
        (setq title (concat (pathname-name title)
                            (if (pathname-type title)
                                (concat "." (pathname-type title)) "")))
      (setq title (buffer-name (selected-buffer))))
    (save-excursion
      (set-buffer *buf2html-buffer-html*)
      (setq encoding-display-name (char-encoding-display-name (buffer-fileio-encoding))))
    (cond
     ((string-match "日本語" encoding-display-name)
      (setq lang "ja"))
     ((string-match "中国語" encoding-display-name)
      nil)
     ((string-match "韓国語" encoding-display-name)
      nil)
     (t
      nil))
    (cond
     ((string-match "Shift_JIS" encoding-display-name)
      (setq charset "Shift_JIS"))
     ((string-match "EUC-JP" encoding-display-name)
      (setq charset "EUC-JP"))
     ((string-match "ISO-2022-JP" encoding-display-name)
      (setq charset "ISO-2022-JP"))
     ((string-match "UTF-8" encoding-display-name)
      (setq charset "UTF-8"))
     (t
      nil))

    (format t "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">~%")
    (if (stringp *buf2html-auto-mode-parameter-string* )
        (format t "<!-- -*- ~A -*- -->~%" *buf2html-auto-mode-parameter-string*))
    (if (and (stringp *buf2html-date-format*)
             (stringp *buf2html-time-stamp-start*)
             (stringp *buf2html-time-stamp-end*))
        (format t "<!-- ~A~A~A -->~%"
                *buf2html-time-stamp-start*
                (format-date-string *buf2html-date-format*)
                *buf2html-time-stamp-end*))
    (format t "<!-- Created by buf2html-~A -->~%" *buf2html-version*)
    (if lang
        (format t "<HTML lang=\"~A\">~%" lang)
      (format t "<HTML>~%"))
    (format t "  <HEAD>~%")
    (format t "    <META name=\"GENERATOR\" content=\"buf2html-~A\">~%"
            *buf2html-version*)
    (if charset
        (format t "    <META http-equiv=\"Content-Type\" content=\"text/html; charset=~A\">~%"
                charset))
    (dolist (css *buf2html-css-list*)
      (format t "    <LINK href=\"~A\" rel=\"stylesheet\" type=\"text/css\">~%" css))
    (when (or internal-css-p *buf2html-internal-css-alist*)
      (format t "    <META http-equiv=\"Content-Style-Type\" content=\"text/css\">~%")
      (format t "    <STYLE type=\"text/css\">~%")
      (format t "      <!--~%")
      (when internal-css-p
        (format t "~A" (buf2html-get-ini2css-string 8)))
      (dolist (internal-css *buf2html-internal-css-alist*)
        (format t "        ~A {~%" (car internal-css))
        (dolist (x (cdr internal-css))
          (format t "          ~A;~%" x))
        (format t "        }~%"))
      (format t "        -->~%")
      (format t "    </STYLE>~%"))
    (format t "    <TITLE>~A</TITLE>~%" (buf2html-protect-string title))
    (format t "  </HEAD>~%")
    (if region-p
        (format t "  <BODY>~%")
      (format t "  <BODY class=\"bgcolor\">~%"))
    (when *buf2html-lower-case*
      (save-excursion
        (set-buffer (buffer-stream-buffer *standard-output*))
        (buf2html-downcase-tag-region from (buffer-stream-point *standard-output*))))
    ))

(defun buf2html-print-footer ()
  "buf2html: HTML の終了部分を出力"
  (let ((from (buffer-stream-point *standard-output*)))
    (format t "  </BODY>~%")
    (format t "</HTML>~%")
    (when *buf2html-lower-case*
      (save-excursion
        (set-buffer (buffer-stream-buffer *standard-output*))
        (buf2html-downcase-tag-region from (buffer-stream-point *standard-output*))))))

(defun buf2html-print-body (all-units compiled-color-tag-table text-attribute-units
                            &optional line-number-p region-p nomsg)
  "buf2html: HTML のメイン部分を出力"
  (let ((point-min (point-min)) (point-max (point-max))
        btag etag type range tags (line-number 1)
        regexp-keyword-group-units regexp-keyword-group-range
        (from (buffer-stream-point *standard-output*)))
    (flet ((print-range (range btag etag text-attribute-units)
             (let (text-attribute-unit
                   text-attribute-tags
                   text-attribute-range
                   (convert-half-space-p (or *buf2html-convert-half-space* line-number-p)))
;              ;; 念のため前の部分を除外
;              (while (and text-attribute-units
;                          (<= (cddar text-attribute-units) (car range)))
;                (setq text-attribute-units (cdr text-attribute-units)))

               ;; text-attribute-units の先頭を取得（先頭には残したまま）
               (when text-attribute-units
                 (setq text-attribute-unit (car text-attribute-units))
                 (setq text-attribute-tags (cdar text-attribute-unit))
                 (setq text-attribute-range (cdr text-attribute-unit))
                 (if (< (car text-attribute-range) (car range))
                     (setq text-attribute-range
                           (cons (car range) (cdr text-attribute-range)))))

               (while (< (car range) (cdr range))
                 (cond
                  ;; text-attribute-range と関係がない場合
                  ((or (null text-attribute-range)
                       (<= (cdr range) (car text-attribute-range)))
                   (format t "~A" btag)
                   (format t "~A"
                           (buf2html-convert-region (car range) (cdr range)
                                                    :btag btag :etag etag
                                                    :convert-half-space-p convert-half-space-p
                                                    :anchor-p *buf2html-anchor-url*))
                   (format t "~A" etag)
                   (return))
                  ;; text-attribute-range が range の終端以降まである場合
                  ((< (cdr range) (cdr text-attribute-range))
                   (format t "~A" btag)
                   (when (< (car range) (car text-attribute-range))
                     (format t "~A"
                             (buf2html-convert-region (car range) (car text-attribute-range)
                                                      :btag btag
                                                      :etag etag
                                                      :convert-half-space-p convert-half-space-p
                                                      :anchor-p *buf2html-anchor-url*)))
                   (format t "~A" (car text-attribute-tags))
                   (format t "~A"
                           (buf2html-convert-region (car text-attribute-range) (cdr range)
                                                    :btag (car text-attribute-tags)
                                                    :etag (cdr text-attribute-tags)
                                                    :convert-half-space-p convert-half-space-p
                                                    :anchor-p *buf2html-anchor-url*))
                   (format t "~A~A" (cdr text-attribute-tags) etag)
                   (return))
                  ;; text-attribute-range が range に含まれる場合
                  (t
                   (format t "~A" btag)
                   (when (< (car range) (car text-attribute-range))
                     (format t "~A"
                             (buf2html-convert-region (car range) (car text-attribute-range)
                                                      :btag btag
                                                      :etag etag
                                                      :convert-half-space-p convert-half-space-p
                                                      :anchor-p *buf2html-anchor-url*)))
                   (format t "~A" (car text-attribute-tags))
                   (format t "~A"
                           (buf2html-convert-region (car text-attribute-range)
                                                    (cdr text-attribute-range)
                                                    :btag (car text-attribute-tags)
                                                    :etag (cdr text-attribute-tags)
                                                    :convert-half-space-p convert-half-space-p
                                                    :anchor-p *buf2html-anchor-url*))
                   (format t "~A~A" (cdr text-attribute-tags) etag)
                   (setq range (cons (cdr text-attribute-range) (cdr range)))

                   ;; 使用済みの text-attribute-unit を先頭から除外
                   (setq text-attribute-units (cdr text-attribute-units))
                   (if text-attribute-units
                       (progn
                         (setq text-attribute-unit (car text-attribute-units))
                         (setq text-attribute-tags (cdar text-attribute-unit))
                         (setq text-attribute-range (cdr text-attribute-unit)))
                     (progn
                       (setq text-attribute-unit nil)
                       (setq text-attribute-tags nil)
                       (setq text-attribute-range nil)))))))
             text-attribute-units))
      (cond
       (region-p
        (if *buf2html-region-css-class-list*
            (format t "<PRE class=\"~A\">~%"
                    (substring (format nil "~{ ~A~}" *buf2html-region-css-class-list*) 1))
          (format t "<PRE>~%")))
       (line-number-p
        (format t "<OL>~%<LI><CODE>~A" (if *buf2html-number-link* "<A name=\"1\">" "")))
       (t
        (format t "<PRE>~%")))
      (dolist (all-unit all-units)
        (setq type (car all-unit))
        (setq range (cdr all-unit))
        (unless nomsg
          (message "Output HTML: ~2D%" (floor (* 100 (/ (- (car range) point-min)
                                                        (- point-max point-min))))))
        (case (car type)
          ((nil)
           (setq text-attribute-units
                 (print-range range "" "" text-attribute-units)))
          (:string
           (setq text-attribute-units
                 (print-range range "<SPAN class=\"string\">" "</SPAN>"
                              text-attribute-units)))
          (:comment
           (setq text-attribute-units
                 (print-range range "<SPAN class=\"comment\">" "</SPAN>"
                              text-attribute-units)))
          (:tag
           (setq text-attribute-units
                 (print-range range "<SPAN class=\"tag\">" "</SPAN>"
                              text-attribute-units)))
          (:buf2html-keyword
           (setq tags (gethash (cdr type) compiled-color-tag-table))
           (setq text-attribute-units
                 (print-range range (car tags) (cdr tags) text-attribute-units)))
          (:buf2html-regexp-keyword
           (setq regexp-keyword-group-units (cdr type))
           (dolist (regexp-keyword-group-unit regexp-keyword-group-units)
             (setq tags (gethash (cdar regexp-keyword-group-unit)
                                 compiled-color-tag-table))
             (setq regexp-keyword-group-range (cdr regexp-keyword-group-unit))
             (if (< (car regexp-keyword-group-range) (car range))
                 (setq regexp-keyword-group-range
                       (cons (car range) (cdr regexp-keyword-group-range))))
             (if (< (cdr range) (cdr regexp-keyword-group-range))
                 (setq regexp-keyword-group-range
                       (cons (car regexp-keyword-group-range) (cdr range))))
             (if (< (car regexp-keyword-group-range) (cdr regexp-keyword-group-range))
                 (setq text-attribute-units
                       (print-range regexp-keyword-group-range (car tags) (cdr tags)
                                    text-attribute-units)))))
          (:buf2html-line-feed
           (cond
            ((not line-number-p)
             (setq text-attribute-units
                   (print-range range "" "" text-attribute-units)))
            ((= (cdr range) point-max)
             (if *buf2html-number-link*
                 (setq text-attribute-units
                       (print-range range "</A></CODE></LI>" ""
                                    text-attribute-units))
               (setq text-attribute-units
                     (print-range range "</CODE></LI>" ""
                                  text-attribute-units))))
            (t
             (incf line-number)
             (if *buf2html-number-link*
                 (setq text-attribute-units
                       (print-range range "</A></CODE></LI>"
                                    (format nil "<LI><CODE><A name=\"~D\">"
                                            line-number)
                                    text-attribute-units))
               (setq text-attribute-units
                     (print-range range "</CODE></LI>" "<LI><CODE>"
                                  text-attribute-units))))))

          (t
           (setq text-attribute-units
                 (print-range range "" "" text-attribute-units)))))
      (cond
       (region-p
        (format t "</PRE>~%"))
       (line-number-p
        (format t "</OL>~%"))
       (t
        (format t "</PRE>~%")))
      )
    (when *buf2html-lower-case*
      (save-excursion
        (set-buffer (buffer-stream-buffer *standard-output*))
        (buf2html-downcase-tag-region from (buffer-stream-point *standard-output*))))))

(defun buf2html-downcase-tag-region (from to)
  "buf2html: リージョン内のタグを小文字に変換
ed::html-highlight-mode が t でなければ変換しない。"
  (interactive "*r")
  (unless html-highlight-mode
    (return-from buf2html-downcase-tag-region nil))
  (let ((regexp (compile-regexp "</?\\([A-Z]+\\)" t)))
    (save-excursion
      (save-restriction
        (narrow-to-region from to)
        (goto-char (point-min))
        (while (scan-buffer regexp)
          (when (eq (parse-point-syntax) nil)
            (downcase-region (match-beginning 1) (match-end 1)))
          (goto-char (match-end 0)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; syntax-table 関連
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 使用していない
(defun buf2html-syntax-table-check (&key nomsg)
  "buf2html: syntax-table を調べる"
  (let ((percent -1) pre-percent c
        open-tag-characters close-tag-characters
        start-comment-characters end-comment-characters
        start-multi-comment-1-characters start-multi-comment-2-characters
        end-multi-comment-1-characters end-multi-comment-2-characters)
    (dotimes (i *buf2html-char-code-limit*)
      (setq pre-percent percent)
      (setq percent (floor (* 100 (/ i *buf2html-char-code-limit*))))
      (unless nomsg
        (if (/= pre-percent percent) (message "Check syntax table: ~2D%" percent)))
      (setq c (code-char i))
      (if (syntax-open-tag-p c) (push c open-tag-characters))
      (if (syntax-close-tag-p c) (push c close-tag-characters))
      (if (syntax-start-comment-p c) (push c start-comment-characters))
      (if (syntax-end-comment-p c) (push c end-comment-characters))
      (if (syntax-start-multi-comment-1-p c) (push c start-multi-comment-1-characters))
      (if (syntax-start-multi-comment-2-p c) (push c start-multi-comment-2-characters))
      (if (syntax-end-multi-comment-1-p c) (push c end-multi-comment-1-characters))
      (if (syntax-end-multi-comment-2-p c) (push c end-multi-comment-2-characters))
      )
    (values open-tag-characters close-tag-characters
            start-comment-characters end-comment-characters
            start-multi-comment-1-characters start-multi-comment-2-characters
            end-multi-comment-1-characters end-multi-comment-2-characters)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; buf2html-get-ini2css-string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-get-ini2css-string (&optional indent)
  (let ((ini-path (merge-pathnames "xyzzy.ini" (user-config-path)))
        (*buf2html-buffer-css* (concat " " *buf2html-buffer-css*)))
    (declare (special *buf2html-buffer-css*))
    (if (file-exist-p ini-path)
        (save-window-excursion
          (save-excursion
            (ini2css-file ini-path)
            (set-buffer *buf2html-buffer-css*)
            (if (and (numberp indent) (integerp indent) (plusp indent))
                (loop
                  (unless (looking-at "^$")
                    (insert " " indent))
                  (unless (forward-line)
                    (return))))
            (prog1
                (buffer-substring (point-min) (point-max))
              (delete-buffer *buf2html-buffer-css*))))
      "")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ini2css-file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ini2css-file (ini-path)
  "buf2html: xyzzy の設定ファイルからスタイルシートを生成"
  (interactive "fFind ini file: "
    :title0 "Find ini file"
    :default0 (let ((path (merge-pathnames "xyzzy.ini" (user-config-path))))
                (if (file-exist-p path) path "")))
  (if (file-exist-p ini-path)
      (progn
        (save-excursion
          (buf2html-set-buffer *buf2html-buffer-tmp*)
          (with-output-to-buffer (*buf2html-buffer-tmp*)
            (with-open-file (fp ini-path)
              (let ((line nil))
                (while (setq line (read-line fp nil nil nil))
                  (format t "~A~%" line)))))
          (set-buffer *buf2html-buffer-tmp*)
          (goto-char (point-min))
          (ini2css-buffer)
          (delete-buffer (find-buffer *buf2html-buffer-tmp*)))
        (pop-to-buffer *buf2html-buffer-css*))
    (message "ファイルが存在しません")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ini2css-buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ini2css-buffer ()
  "buf2html: 現在のバッファからスタイルシートを生成"
  (interactive)
  (let (start-point end-point colors-alist)
    (save-excursion
      (goto-char (point-min))
      (when (scan-buffer "^\\[Colors\\]" :regexp t :case-fold t)
        (setq start-point (point))
        (setq end-point
              (if (scan-buffer "^\\[.+\\]" :regexp t :no-dup t) (point) (point-max)))
        (save-restriction
          (narrow-to-region start-point end-point)
          (goto-char (point-min))
          (while (scan-buffer "^\\([^=]+\\)=#\\([0-9a-f]+\\)"
                              :regexp t :case-fold t :no-dup t)
            (push (cons (match-string 1)
                        (buf2html-bgr2rgb (parse-integer (match-string 2) :radix 16)))
                  colors-alist)))))
    (buf2html-set-buffer *buf2html-buffer-css*)
    (with-output-to-buffer (*buf2html-buffer-css*)
      (flet ((format-selector (colors-alist selector fg-item &optional bg-item single-line)
               (let (fgcolor bgcolor)
                 (if (stringp fg-item)
                     (setq fgcolor (find fg-item colors-alist :key 'car :test 'string-equal)))
                 (if (stringp bg-item)
                     (setq bgcolor (find bg-item colors-alist :key 'car :test 'string-equal)))
                 (when (or fgcolor bgcolor)
                   (format t "~A {" selector)
                   (unless single-line (format t "~%"))
                   (when fgcolor
                     (format t "~A" (if single-line " " "  "))
                     (format t "~A: #~6,'0x;" "color" (cdr fgcolor))
                     (unless single-line (format t "~%")))
                   (when bgcolor
                     (format t "~A" (if single-line " " "  "))
                     (format t "~A: #~6,'0x;" "background-color" (cdr bgcolor))
                     (unless single-line (format t "~%")))
                   (if single-line (format t " "))
                   (cond
                    ((and fgcolor bgcolor)
                     (format t "} /* ~A, ~A */~%" fg-item bg-item))
                    (fgcolor
                     (format t "} /* ~A */~%" fg-item))
                    (bgcolor
                     (format t "} /* ~A */~%" bg-item))))
                 )))
        (format-selector colors-alist ".bgcolor" "textColor" "backColor")
        (format-selector colors-alist "SPAN.keyword1" "kwdColor1")
        (format-selector colors-alist "SPAN.keyword2" "kwdColor2")
        (format-selector colors-alist "SPAN.keyword3" "kwdColor3")
        (format-selector colors-alist "SPAN.keyword1inverse" "backColor" "kwdColor1")
        (format-selector colors-alist "SPAN.keyword2inverse" "backColor" "kwdColor2")
        (format-selector colors-alist "SPAN.keyword3inverse" "backColor" "kwdColor3")
        (format-selector colors-alist "SPAN.ctl" "ctlColor")
        (format-selector colors-alist "SPAN.string" "stringColor")
        (format-selector colors-alist "SPAN.comment" "commentColor")
        (format-selector colors-alist "SPAN.tag" "tagColor")
        (format-selector colors-alist ".fg0" "textColor")
        (format-selector colors-alist ".bg0" nil "backColor")
        (do ((i 1 (1+ i)))
            ((> i 15))
          (format-selector colors-alist (format nil ".fg~D" i) (format nil "fg~D" i) nil t)
          (format-selector colors-alist (format nil ".bg~D" i) nil (format nil "bg~D" i) t))
        )
      ;; bold
      (format t "~A { ~A; }~%" ".bold" "font-weight: bold")
      ;; underline
      (format t "~A { ~A; }~%" ".underline" "text-decoration: underline")
      ;; strike-out
      (format t "~A { ~A; }~%" ".strike-out" "text-decoration: line-through")

      )
    (pop-to-buffer *buf2html-buffer-css*)
    (if (fboundp 'css-mode)
        (css-mode))
    (set-buffer-modified-p nil)
    ))

(defun buf2html-bgr2rgb (bgr)
  "buf2html: bgr の数値を rgb の数値に変換"
  (let ((b (floor (mod bgr #x1000000) #x10000))
        (g (floor (mod bgr #x10000) #x100))
        (r (mod bgr #x100)))
    (+ (* r #x10000) (* g #x100) b)))

(defun buf2html-set-buffer (buffer-name)
  "buf2html: 出力用バッファの準備"
  (save-excursion
    (get-buffer-create buffer-name)
    (erase-buffer buffer-name)
    (set-buffer buffer-name)
    (make-local-variable 'need-not-save)
    (setq need-not-save t)
    (if (and *buf2html-mode-function*
             (fboundp *buf2html-mode-function*))
        (funcall *buf2html-mode-function*)
      (html-mode))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; menu
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun buf2html-save-as-dialog ()
  "buf2html: HTML形式で名前を付けて保存ダイアログ"
  (interactive)
  (let ((*buf2html-internal-xyzzy-css* t)
        (*buf2html-css-list* nil)
        default-file-name)
    (save-window-excursion
      (setq default-file-name (get-buffer-file-name))
      (when (and default-file-name
                 (string-match "^\\(.+\\)\\(\\.[^.]*\\)$" default-file-name))
        (setq default-file-name (match-string 1)))
      (multiple-value-bind (file index encoding eol-code)
          (file-name-dialog :save t
                            :title "HTML形式で名前を付けて保存"
                            :default default-file-name
                            :filter *buf2html-file-dialog-filter*
                            :extension "htm"
                            :overwrite t :hide-read-only t
                            :char-encoding (or *buf2html-encoding* (buffer-fileio-encoding))
                            :eol-code (or *buf2html-eol-code* (buffer-eol-code)))
        (when file
          (let ((*buf2html-encoding* encoding)
                (*buf2html-eol-code* eol-code))
            (declare (special *buf2html-encoding*))
            (declare (special *buf2html-eol-code*))
            (buf2html)
            (rename file t)
            (save-buffer)
            (when (find-buffer *buf2html-buffer-tmp*)
              (delete-buffer *buf2html-buffer-tmp*))
            (when (find-buffer *buf2html-buffer-css*)
              (delete-buffer *buf2html-buffer-css*))
            (when (find-buffer *buf2html-buffer-html*)
              (delete-buffer *buf2html-buffer-html*))
            (add-history file '*minibuffer-file-name-history*))
          t)))))

(defun buf2html-insert-menu-items (&key menu pre-tag position head-sep tail-sep)
  "buf2html: HTML形式で名前を付けて保存ダイアログをメニューに追加"
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::file)))
  (when (menup menu)
    (buf2html-delete-menu menu)
    (unless (or pre-tag position)
      (setq pre-tag 'ed::save-as-dialog))
    (when (and pre-tag
               (setq position (get-menu-position menu pre-tag)))
      (incf position))
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (unless position
        (setq position -1)
        (while (get-menu menu (incf position) t))))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'buf2html-sep))
    (insert-menu-item menu (incf position) 'buf2html-save-as-dialog
                      "HTML形式で名前を付けて保存(&H)..."
                      'buf2html-save-as-dialog)
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'buf2html-sep))))

(defun buf2html-delete-menu (&optional menu)
  "buf2html: HTML形式で名前を付けて保存ダイアログをメニューから削除"
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::file)))
  (when (menup menu)
    (while (delete-menu menu 'buf2html-save-as-dialog))
    (while (delete-menu menu 'buf2html-sep))))

(defun buf2html-set-app-menu (&optional position)
  "buf2html: HTML形式で名前を付けて保存を *app-menu* に追加"
  (if *app-menu*
      (buf2html-insert-menu-items :position position)
    (add-hook '*init-app-menus-hook*
              #'(lambda () (buf2html-set-app-menu position)))))
(defun buf2html-set-app-popup-menu (&optional position)
  "buf2html: buf2html の操作を *app-popup-menu* に追加"
  (flet ((menu-length (menu)
           (let ((pos 0))
             (when (menup menu)
               (while (get-menu menu pos t)
                 (incf pos)))
             pos)))
    (if *app-popup-menu*
        (progn
          (if (or (not (integerp position))
                  (minusp position)
                  (> position (menu-length *app-popup-menu*)))
              (setq position (menu-length *app-popup-menu*)))
          (insert-popup-menu
           *app-popup-menu* position
           (define-popup-menu
             (:item 'buf2html-copy-selection-to-clipboard
              "選択範囲を部分的な HTML に変換してコピー(&S)"
              'buf2html-copy-selection-to-clipboard
              :selection)
             (:item 'buf2html-copy-selection-to-clipboard
              "選択範囲を HTML に変換してコピー(&S)"
              #'(lambda ()
                  (interactive)
                  (buf2html-copy-selection-to-clipboard t))
              :selection)
             (:item 'buf2html
              "バッファを HTML に変換(&B)"
              'buf2html))
           "buf2html(&B)"))
      (add-hook '*init-app-menus-hook*
                #'(lambda () (buf2html-set-app-popup-menu position))))))

;;; buf2html.l ends here
