;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; html+-mode.l --- HTML編集用モード

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-04-30"

;;; install
;;;	1.解凍して出来たhtml+-mode.lを$XYZZY/site-lisp/にコピーします。
;;;     2.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lに記述を追加します。
;;;
;;;		--------------------------------
;;;		(export 'ed::html+-mode "ed")
;;;		(autoload 'html+-mode "html+-mode" t)
;;;		(pushnew '("\\.s?html?$" . html+-mode) *auto-mode-alist* :test 'equal)
;;;		--------------------------------
;;;
;;;	3.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; uninstall
;;;	1.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lの関連する箇所を削除します。
;;;	  ※siteinit.lに記述していたならば再度ダンプし直します。

;;; keybind
;;; 	RET	改行＋インデント付け
;;; 	TAB	インデント付け＋補完
;;; 	/	'</'に一致したら自動補完
;;;	C-,	状況に依存したのそれっぽいタグの挿入
;;;	C-M-,	以前に出現したタグの複写
;;; 	C-.	いろいろと自動補完（閉じタグ、括弧、パス、引用符）
;;; 	C-:	タグの対応のチェック
;;;	C-j	ブレークタグの挿入
;;; 	C-x C-i	イメージタグの挿入
;;; 	C-x C-@	インターネットショートカットの挿入
;;; 	C-x C-j	相対／絶対パスの挿入
;;; 	C-x C-m	リンク先選択ダイアログ
;;; 	ESC C-j	相対／絶対パスの挿入ダイアログ
;;; 	ESC C-m	バッファ選択ダイアログ
;;;	C-d	delete-char-or-selectionのタグ削除版
;;;	C-h	backward-delete-char-untabify-or-selectionのタグ削除版
;;;	C-M-h	直前のタグの削除
;;;	C-M-d	直後のタグの削除

;;; changes
;;;	Wed, 30 Apr 2003 23:17:23 +0900
;;;		・導入の説明の :test 'equal が何故か :test 'string= になってたので修正
;;;	Tue, 29 Apr 2003 12:38:33 +0900
;;;		・NetInstaller対応
;;;		・説明文を修正
;;;	Sat, 15 Mar 2003 11:00:51 +0900
;;;		・2chで話があったので、delete-trailing-spacesを付けてみました
;;;		・navigateするときにURLを調整できるようにフックを付けてみました。
;;;	Fri, 06 Dec 2002 01:47:34 +0900
;;;		・charsetで指定された文字コードにするhtml+-detect-charset/*html+-detect-charset*を追加
;;;		  都合上#\_をシンボル構成文字に変更
;;;	Fri, 24 May 2002 22:25:19 +0900
;;;		・TreeView関連を削除（outline-tree.lに依存することに決定）
;;;		・get-tag-treeだけは使えるかもしれないので残す
;;;	Sun, 24 Mar 2002 07:49:09 +0900（ツリー表示評価版）
;;;		・match-tagがチェックしたタグ構造を返すように変更
;;;		・get-tag-treeを追加、全体のタグ構造を取得する
;;;		・html+-show-tag-tree/html+-hide-tag-treeを追加
;;;		・もーいろいろと試行錯誤中（よくわかりません）
;;;	Sun, 10 Feb 2002 12:41:15 +0900
;;;		・show-match-tagが必ずtを返すように修正。
;;;		　これにより、閉じタグを補完するキーボードマクロがちゃんと動く筈。
;;;	Tue, 05 Feb 2002 00:17:33 +0900
;;;		・nameやidは二重引用符付けないと飛べないようにした
;;;		・tag-stringがnilの場合に適当に回避するよう修正
;;;		・html+-copy-tagの変数のsrcとdstが逆だった…ために起こったバグを修正
;;;	Sun, 20 Jan 2002 15:50:46 +0900
;;;		・html+-insert-internet-shortcutの追加
;;;			インターネットショートカットを元にアンカータグを挿入
;;;			自分は案外「お気に入り」を使っているため
;;;		・formatの出力指定が変なところがあったので修正
;;;	Thu, 10 Jan 2002 10:45:05 +0900
;;;		・大久保さんの指摘部分を直す。
;;;			1.find-file-with-nameのnameが正規表現として見なされてた部分を修正
;;;			2.*html+-select-link-no-select*が二重に宣言されてたのを修正
;;;			3.html+-select-link-dialogの動作を修正
;;;			4.html+-insert-imageの説明を修正
;;;	Sun, 14 Oct 2001 22:28:35 +0900
;;;		・変なところを修正（通常空間での補完がおかしくなるかも）
;;;	Wed, 15 Aug 2001 16:16:52 +0900
;;;		・意味も無く(parse-point-syntax)を(parse-point-syntax)に変えてみたり
;;;		・引用符付き文字列の一括削除機能
;;;		・goto-matched-quoteの修正
;;; 			html+-delete-char-or-selection
;;;			html+-backward-delete-char-untabify-or-selection
;;;	Sun, 29 Jul 2001 03:25:48 +0900
;;;		・0.2.2.207のhtml-kwdとの擦り合わせをしてみた（それなりに危険）
;;;			テストし切れないので本当に正常なのか不明。
;;;			*html+-use-html-kwd*をnon-nilにすると、文書のDOCTYPE毎に異なった補完リストをキーワードファイルから生成する。
;;;			ユーザが指定してても上書きする筈。ただし、その場合のキーワードファイルは *html-keyword-file* に指定すること。
;;;			多分、~/etc/HTMLをそのまま使うのが一番良い（と思う）。
;;;				*html+-tags-list*
;;;				*html+-completion-tags-list*
;;;				*html+-completion-prop-list*
;;;				*html+-completion-text-list*
;;;			こいつらに付け加えたければ、hookの中でやればいいと思う。
;;;			DOCTYPEに厳格に書きたければ、*html+-use-html-kwd*をnon-nilにした方が良い筈。
;;;		・補完の仕方を変えて見た（空白が後ろに付かない）。多分副作用有り。
;;;	Sun, 29 Jul 2001 03:25:48 +0900
;;;		・正規表現のキーワード色付けをやってみた。
;;;			他に色をつけると分かりやすくなるところって？
;;;	Tue, 29 May 2001 23:30:02 +0900
;;;		・wip/jpeg-headerからimagehdrに変更
;;;			PNGも読めるようになったはず
;;;	Sun, 13 May 2001 08:49:48 +0900
;;;		・html+-select-link-dialogをいろいろと整理
;;;			跳び先をお尻の方にしてみた
;;;			行番号をマルチカラムに修正
;;;			browser.dllとの連携を少しだけ整理
;;;			browser.dllが無い場合でもそれなりに動くように修正
;;;			href=\nとなっている場合の変な動作を修正
;;;			IDで飛ぶ場合を追加
;;;		・*html+-select-link-lineno*の削除
;;;		・導入用の文章の追加（ちょっと大雑把か？）
;;;		・*html+-completion-text-list*を削除しようか考え中
;;;		・html+-insert-path-dialogの追加
;;;		・html+-select-buffer-dialogの追加
;;;		・html+-kill-following-tagとhtml+-kill-preceding-tagの追加
;;;	Wed, 03 Jan 2001 22:30:22 +0900
;;;		・html+-do-completionの障害を修正
;;;	Sat, 16 Dec 2000 13:43:54 +0900
;;;		・adjust-urlをちょっと回避のための修正版追加
;;;		・名前付きのAnchorに飛べるように修正
;;;		・ダイアログに行番号を表示できるオプションの追加
;;;			*html+-select-link-linno*で設定
;;;		・kbd-macroが効かなかったのはやはりsit-forの所為か、、、
;;;	Wed, 27 Sep 2000 22:31:34 +0900
;;;		・ダイアログからのジャンプしなかった部分を修正
;;;		・ダイアログで外部のページを表示しない方針を変更
;;;		・*html+-select-link-no-select*/*html+-select-link-no-open*の初期値を修正
;;;	Fri, 07 Jul 2000 11:50:27 +0900
;;;		・browser.dllまわりをネットワーク共有用に修正
;;;	Sun, 04 Jun 2000 19:19:39 +0900
;;;		・html+-comment-indentを追加（htmlmode.lよりパクリ）
;;;			問題があるかもしれないのであったら連絡下さい。
;;;		・タグのチェックや補完をした時にマークを付ける。
;;;	Fri, 21 Apr 2000 15:28:45 +0900
;;;		・html+-select-link-dialogの追加
;;;			一応、browser.lが有りそうだとIEを表示するようにした。
;;;			表示させたくなければ、*html+-kick-browser*をnilに設定すること
;;;	Sun, 26 Mar 2000 12:28:38 +0900
;;;		・html+-delete-char-or-selectionとかhtml+-backward-delete-char-untabify-or-selectionを追加
;;;		・html+-guess-tagを追加（static-abbrevの状況依存版）
;;;			本当はdo-completionと融合させてDTD対応したかった、、、
;;;			個人的にはhtml+-copy-tagのanother version
;;;			ついでにキーバインドも変更
;;;		・html+-insert-breakを追加（Toy氏対応）
;;;		・ハイライトとか改良
;;;		・html+-forward/backward-tagを追加
;;;		・html+-delete-preceding/following-tagがごっそり削除するよう修正
;;;		・html+-insert-imageでファイルが存在しない場合でも透過させる(マッシュ氏対応)
;;;			html+-insert-pathも同様
;;;		・*html+-show-no-jump*を追加
;;;			ジャンプせずにメッセージだけ表示する
;;;		・html+-insert-pathをちょっと修正
;;;	Sun, 27 Feb 2000 22:50:08 +0900
;;;		・html+-delete-preceding/following-tagを追加
;;;		・html+-copy-tagを追加
;;;		・*html+-tags-list-no-indent*を追加（<pre><xmp>対応）
;;;		・*html+-completion-text-list*を追加
;;;			デフォルトで&lt; &gt; &amp; &quot; を設定
;;;		・*Completion*がスクロールするように修正
;;;		・html+-show-match-tagを修正
;;;		・html+-check-match-tagをlong-operationに修正
;;;	Wed, 09 Feb 2000 00:08:06 +0900
;;;		do-completionを正式に追加
;;;		*Completion*がうまく消えたらいいのに
;;;	Sat, 05 Feb 2000 02:44:38 +0900
;;;		・ソースの大幅な変更をした
;;;		・改行方式の改善（そぶそぶしげき対応）
;;;		・タグの補完を高速にするために、完全なチェックを止めた
;;;			完全なチェックをしたければ、html+-check-match-tagを使用すること
;;;	Sun, 23 Jan 2000 13:01:29 +0900
;;;		・タグのハイライト表示（喜多さんからもろパクリ）
;;;			それに合わせて、タグの表示を改良
;;;		・タグの中の改行を改良
;;;		・interactiveの引数を整理
;;;		・JavaScriptのインデント用にいろいろと整理
;;;		・html+-indentをhtml+-indent-lineに変名
;;;		・html+-complete-match-tagをhtml+-do-completionに格上げ
;;;			実装は無いかも
;;;		・コメントの中のタグまで補完していたのを回避
;;;	Mon, 17 Jan 2000 20:33:43 +0900
;;;		・何を直したか良くわからない
;;;	Wed, 24 Nov 1999 23:11:20 +0900
;;;		html+-indent-lineの修正がいらない場合は修正しないように
;;;		・タグを扱いやすいように修正／おまぬけ部分も修正
;;;	Thu, 18 Nov 1999 18:47:47 +0900
;;;		・html+-insert-imageの追加
;;;	Sat, 05 Jun 1999 12:12:16 +0900
;;;		・プロトタイプ

(provide "html+-mode")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "imagehdr")
  (require "html-kwd")
  (require "foreign")
  (require "wip/winapi"))

(in-package "editor")

(export '(*html+-mode-hook*
	  *html+-mode-map*
	  *html+-indent-column*
	  *html+-select-link-no-select*
	  *html+-select-link-no-open*
	  *html+-select-link-no-browser*
	  *html+-show-no-jump*
	  *html+-show-split-window*
	  *html+-show-split-window-lines*
	  *html+-tag-highlight*
	  *html+-tag-attribute*
	  *html+-tag-invalid-attribute*
	  *html+-keyword-file*
	  *html+-tags-list-no-indent*
	  *html+-tags-list*
	  *html+-completion-tags-list*
	  *html+-completion-prop-list*
	  *html+-completion-text-list*
	  *html+-regexp-keyword-list*
	  *html+-use-html-kwd*
	  *html+-navigate-function*
	  *html+-detect-charset*
	  *html+-adjust-url-hook*))

(export '(html+-mode
	  html+-select-link-dialog
	  html+-select-buffer-dialog
	  html+-insert-path-dialog
	  html+-indent-line
	  html+-slash
	  html+-newline-and-indent
	  html+-guess-tag
	  html+-copy-tag
	  html+-calc-indent
	  html+-comment-indent
	  html+-do-completion
	  html+-close-match-tag
	  html+-check-match-tag
	  html+-insert-break
	  html+-insert-image
	  html+-insert-internet-shortcut
	  html+-insert-path
	  html+-forward-tag
	  html+-backward-tag
	  html+-delete-preceding-tag
	  html+-delete-following-tag
	  html+-delete-preceding-string
	  html+-delete-following-string
	  html+-delete-char-or-selection
	  html+-backward-delete-char-untabify-or-selection
	  html+-kill-preceding-tag
	  html+-kill-following-tag
	  html+-highlight-tag
	  html+-recompile-tags-list
	  html+-detect-charset))

;;; 以下自由に触るところ

(defvar *html+-adjust-url-hook* nil
  "html+-mode: navigateする時にURLを調整するためのフック")
(defvar *html+-detect-charset* nil
  "html+-mode: charsetで指定された文字コードを使用する")
(defvar *html+-navigate-function* nil
  "html+-mode: ブラウザで表示する際に使用する関数")
(defvar *html+-use-html-kwd* nil
  "html+-mode: html-kwdを使用する場合")
(defvar *html+-regexp-keyword-list*
  (compile-regexp-keyword-list nil)
  "html+-mode: 正規表現のキーワード")
(defvar *html+-select-link-no-select*
  '("script:" "mailto:")
  "html+-mode: ダイアログに表示しないURL")
(defvar *html+-select-link-no-open*
  '("://" ".gif" ".jpg" ".lzh" ".pdf")
  "html+-mode: エディタで開かないファイル")
(defvar *html+-select-link-no-browser*
  '(".css" ".lzh")
  "html+-mode: ブラウザで開かないファイル")
(defvar *html+-mode-hook* nil
  "html+-mode: フック変数")
(defvar *html+-indent-column* 2
  "html+-mode: インデント桁数")
(defvar *html+-show-no-jump* nil
  "html+-mode: 自動補完及びチェック時に対応するタグを表示しない" )
(defvar *html+-show-split-window* t
  "html+-mode: 対応するタグの表示時にウィンドウを分割する")
(defvar *html+-show-split-window-lines* 5
  "html+-mode: 対応するタグの表示時にウィンドウを分割する行数")
(defvar *html+-count-limit-copy-tag* 20
  "html+-mode: 入力候補列挙時の検索回数")
(defvar *html+-tag-highlight* t
  "html+-mode: タグの表示時にハイライト表示をする")
(defvar *html+-tag-attribute* '(:bold t :foreground 3)
  "html+-mode: ハイライト表示の属性")
(defvar *html+-tag-invalid-attribute* '(:bold t :foreground 1)
  "html+-mode: ハイライト表示の属性（不整合のあるタグのみ）")
(defvar *html+-tags-list-no-indent*
  '("PRE" "XMP")
  "html+-mode: インデント付けの対象外とするタグ")

(defvar *html+-guess-list*
  ; めちゃめちゃてきとー且つ自己充足的です
  ; DTDに完全に対応させたければここをそれなりに
  ; 【Sat, 12 May 2001 19:08:55 +0900】
  ; 確かここを連想配列にしなかったのはいろいろと後の事を考えてだったような・・・
  ; 【Mon, 06 Aug 2001 00:17:00 +0900】
  ; 他の部分はhtml-kwd対応したけどここは置き去り、DTDから生成しなきゃ無理です
  '((""
     . ("html"))
    ("html"
     . ("head" "body"))
    ("head"
     . ("title"))
    ("body"
     . ("blockquote" "p" "div" "table" "dl" "dl compact" "ul" "ol"
	"script" "script language=\"JavaScript\"" "script language=\"VBScript\""))
    ("blockquote"
     . ("blockquote" "p" "div" "table" "dl" "dl compact" "ul" "ol"))
    ("p"
     . ("blockquote" "p" "div" "table" "dl" "dl compact" "ul" "ol"))
    ("div"
     . ("blockquote" "p" "div" "table" "dl" "dl compact" "ul" "ol"))
    ("table"
     . ("tr"))
    ("tr"
     . ("th" "td"))
    ("dl"
     . ("dt" "dd"))
    ("ul"
     . ("li" "ul" "ol"))
    ("ol"
     . ("li" "ol" "ul")))
  "html+-mode: 状況依存したタグの候補")

(defvar *html+-tag* 'html+ "html+-mode: タグのハイライトに使用する属性")

; *html+-use-html-kwd*がnon-nilの場合には、*html-keyword-file*に指定すること
; 普通は亀井さんが用意してくれたものを使うってことで
(defvar *html+-keyword-file* "HTML")

(defvar *html+-mode-map* nil)
(unless *html+-mode-map*
  (setq *html+-mode-map* (make-sparse-keymap))
  (define-key *html+-mode-map* #\TAB	'html+-do-completion)
  (define-key *html+-mode-map* #\/	'html+-slash)
  (define-key *html+-mode-map* #\RET	'html+-newline-and-indent)
  (define-key *html+-mode-map* #\C-\,	'html+-guess-tag)
  (define-key *html+-mode-map* #\C-M-\,	'html+-copy-tag)
  (define-key *html+-mode-map* #\C-.	'html+-close-match-tag)
  (define-key *html+-mode-map* #\C-:	'html+-check-match-tag)
  (define-key *html+-mode-map* #\C-j	'html+-insert-break)
  (define-key *html+-mode-map* '(#\C-x #\C-i)	'html+-insert-image)
  (define-key *html+-mode-map* '(#\C-x #\C-@)	'html+-insert-internet-shortcut)
  (define-key *html+-mode-map* '(#\C-x #\C-j)	'html+-insert-path)
  (define-key *html+-mode-map* '(#\C-x #\C-m)	'html+-select-link-dialog)
  (define-key *html+-mode-map* '(#\ESC #\RET)	'html+-select-buffer-dialog)
  (define-key *html+-mode-map* '(#\ESC #\C-j)	'html+-insert-path-dialog)
  (define-key *html+-mode-map* #\C-d	'html+-delete-char-or-selection)
  (define-key *html+-mode-map* #\C-h	'html+-backward-delete-char-untabify-or-selection)
  (define-key *html+-mode-map* #\C-M-h	'html+-kill-preceding-tag)
  (define-key *html+-mode-map* #\C-M-d	'html+-kill-following-tag)
  (define-key *html+-mode-map* #\C-M-f	'html+-forward-tag)
  (define-key *html+-mode-map* #\C-M-b	'html+-backward-tag))

(defvar *html+-mode-abbrev-table* nil)
(unless *html+-mode-abbrev-table*
  (define-abbrev-table '*html+-mode-abbrev-table*))

(defvar *html+-mode-syntax-table* nil)
(unless *html+-mode-syntax-table*
  (setq *html+-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x))) ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *html+-mode-syntax-table* c))))
  (set-syntax-symbol-prefix *html+-mode-syntax-table* #\&)
  (set-syntax-symbol *html+-mode-syntax-table* #\-)
  (set-syntax-symbol *html+-mode-syntax-table* #\_)
  (set-syntax-symbol *html+-mode-syntax-table* #\:)
  (set-syntax-string *html+-mode-syntax-table* #\")
  (set-syntax-string *html+-mode-syntax-table* #\')
  (set-syntax-tag *html+-mode-syntax-table* #\< #\>)
  (set-syntax-match *html+-mode-syntax-table* #\{ #\})
  (set-syntax-match *html+-mode-syntax-table* #\[ #\])
  (set-syntax-match *html+-mode-syntax-table* #\( #\))
  (set-syntax-symbol *html+-mode-syntax-table* #\/))

;;; *html+-use-html-kwd* が non-nil の場合には、html-kwdを使用して
;;; *html-keyword-file*を標準のキーワードファイルとして使用する。
;;; 以下のシンボルは各DOCTYPEに対応したもので置き換える。

(if *html+-use-html-kwd*
    (progn
      (defvar *html+-tags-hash-list* nil)
      (defvar *html+-completion-tags-hash-list* nil)
      (defvar *html+-completion-prop-hash-list* nil)
      (defvar *html+-completion-text-hash-list* nil)
      (defvar *html+-tags-regexp-hash-list* nil)
      (make-variable-buffer-local '*html+-tags-list*)
      (make-variable-buffer-local '*html+-completion-tags-list*)
      (make-variable-buffer-local '*html+-completion-prop-list*)
      (make-variable-buffer-local '*html+-completion-text-list*)
      (make-variable-buffer-local '*html+-tags-regexp*)
      #| html-kwdを使用するので、キーワードのハッシュテーブルは不要 |#)
  (progn
    (defvar *html+-tags-list*
      '("A" "ABBR" "ABBREV" "ABOVE" "ACRONYM" "ADDRESS" "ANIMATE" "APPLET" "ARRAY" "AU"
	"B" "BANNER" "BAR" "BASEFONT" "BDO" "BELOW" "BIG" "BLINK" "BLOCKQUOTE" "BODY" "BODYTEXT" "BOX" "BQ" "BT" "BUTTON"
	"CAPTION" "CENTER" "CITE" "CODE" "COLGROUP" "COMMENT" "CREDIT"
	"DD" "DDOT" "DEL" "DFN" "DIR" "DIV" "DL" "DOT" "DT"
	"EM" "EMBED"
	"FIELDSET" "FIG" "FIGTEXT" "FN" "FONT" "FORM" "FRAMESET"
	"H1" "H2" "H3" "H4" "H5" "H6" "H7" "HAT" "HEAD" "HTML"
	"I" "IFRAME" "ILAYER" "INS" "ITEM"
	"KBD"
	"LABEL" "LANG" "LAYER" "LEGEND" "LH" "LI" "LISTING"
	"MAP" "MARQUEE" "MATH" "MENU" "MULTICOL"
	"NOBR" "NOEMBED" "NOFRAMES" "NOLAYER" "NOSCRIPT" "NOTE"
	"OBJECT" "OF" "OL" "OPTGROUP" "OPTION"
	"P" "PERSON" "PLAINTEXT" "PRE"
	"Q" "QUOTE"
	"ROOT" "ROW"
	"S" "SAMP" "SCRIPT" "SELECT" "SERVER" "SMALL" "SPAN" "SQRT" "STRIKE" "STRONG" "STYLE" "SUB" "SUP"
	"T" "TABLE" "TBODY" "TD" "TEXTAREA" "TFOOT" "TH" "THEAD" "TILDE" "TITLE" "TR" "TT"
	"U" "UL"
	"VAR" "VEC"
	"XMP"))
    (defvar *html+-completion-text-list* '("&lt" "&gt" "&amp" "&quot"))
    (defvar *html+-completion-tags-list* nil)
    (defvar *html+-completion-prop-list* nil)
    (defvar *html+-tags-regexp* nil)
    (defvar *html+-keyword-hash-table* nil)))

; -------------------------------
; html+-mode
(defun html+-mode ()
  (interactive)
  "インデント機能付きHTML用モード"
  (kill-all-local-variables)
  (setq buffer-mode 'html+-mode)
  (setq mode-name "HTML+")
  (use-keymap *html+-mode-map*)
  (use-syntax-table *html+-mode-syntax-table*)
  (setq html-highlight-mode t)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command #'html+-indent-line)
  (make-local-variable 'regexp-keyword-list)
  (setq regexp-keyword-list *html+-regexp-keyword-list*)
  (if *html+-use-html-kwd*
      (progn
	(html-load-keyword-file nil)
	(let* ((cdt (html-current-doctype))
	       (lst (remove-if-not 'stringp (make-list-from-keyword-table keyword-hash-table))))
	  (if (assoc cdt *html+-tags-hash-list*)
	      (progn
		(setq *html+-tags-list* (cdr (assoc cdt *html+-tags-hash-list*)))
		(setq *html+-completion-tags-list* (cdr (assoc cdt *html+-completion-tags-hash-list*)))
		(setq *html+-completion-prop-list* (cdr (assoc cdt *html+-completion-prop-hash-list*)))
		(setq *html+-completion-text-list* (cdr (assoc cdt *html+-completion-text-hash-list*)))
		(setq *html+-tags-regexp* (cdr (assoc cdt *html+-tags-regexp-hash-list*))))
	    (progn
	      (setq *html+-tags-list*
		    (mapcar #'(lambda (x) (substring x 2))
			    (remove-if-not
			     #'(lambda (x) (if (stringp x) (string-match "^</" x))) lst)))
	      (setq *html+-completion-tags-list*
		    (remove-if-not
		     #'(lambda (x) (if (stringp x) (string-match "^<[^/]" x))) lst))
	      (setq *html+-completion-prop-list*
		    (remove-if
		     #'(lambda (x) (if (stringp x) (string-match "^<\\|^&" x) t)) lst))
	      (setq *html+-completion-text-list*
		    (remove-if-not
		     #'(lambda (x) (if (stringp x) (string-match "^&" x) t)) lst))
	      (setq *html+-tags-regexp*
		    (compile-tags-regexp *html+-tags-list*))
	      (push (cons cdt *html+-tags-list*) *html+-tags-hash-list*)
	      (push (cons cdt *html+-completion-tags-list*) *html+-completion-tags-hash-list*)
	      (push (cons cdt *html+-completion-prop-list*) *html+-completion-prop-hash-list*)
	      (push (cons cdt *html+-completion-text-list*) *html+-completion-text-hash-list*)
	      (push (cons cdt *html+-tags-regexp*) *html+-tags-regexp-hash-list*)))))
    (let (lst)
      (and *html+-keyword-file*
	   (null *html+-keyword-hash-table*)
	   (setq *html+-keyword-hash-table*
		 (load-keyword-file *html+-keyword-file* t)))
      (when *html+-keyword-hash-table*
	(make-local-variable 'keyword-hash-table)
	(setq keyword-hash-table *html+-keyword-hash-table*))
      (setq lst (make-list-from-keyword-table keyword-hash-table))
      (unless *html+-tags-regexp*
	(setq *html+-completion-tags-list*
	      (remove-if-not
	       #'(lambda (x) (if (stringp x) (string-match "^<[^/]" x))) lst))
	(setq *html+-completion-prop-list*
	      (remove-if
	       #'(lambda (x) (if (stringp x) (string-match "^<\\|^&" x) t)) lst))
	(setq *html+-tags-regexp*
	      (compile-tags-regexp *html+-tags-list*)))))
  (setq *local-abbrev-table* *html+-mode-abbrev-table*)
  (setq comment-start "<!-- ")
  (setq comment-end " -->")
  (setq comment-start-skip "<!--[ \t]*")
  (setq comment-indent-function 'html+-comment-indent)
  (and *html+-detect-charset*
       (html+-detect-charset))
  (run-hooks '*html+-mode-hook*)
  (let (mlst)
    (and *html+-detect-charset*
	 (push (char-encoding-display-name (buffer-fileio-encoding)) mlst))
    (and *html+-use-html-kwd*
	 (push (html-current-doctype) mlst))
    (message "~{/ ~A ~}" mlst)))

; -------------------------------
; 正規表現の再コンパイル
(defun html+-recompile-tags-list (&optional lst)
  (cond
   ((null lst)
    (setq *html+-tags-regexp* (compile-tags-regexp *html+-tags-list*)))
   ((not (eq lst *html+-tags-list*))
    (setq *html+-tags-list* lst)
    (setq *html+-tags-regexp* (compile-tags-regexp *html+-tags-list*)))))

; -------------------------------
; 改行＋インデント
(defun html+-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  "html+-mode: 改行＋インデント付け"
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (html+-indent-line))

; -------------------------------
; 現在の行のインデント付け
; Sat, 19 Feb 2000 11:26:51 +0900
(defun html+-indent-line ()
  (interactive "*")
  "html+-mode: インデント付け"
  (let (col ret1 ret2)
    ; インデント量の計算
    (setq col (html+-calc-indent))
    ; <pre>,<xmp>の中ならば何もしない
    (if (integerp col)
	(setq ret1 (indent-to-column col)))
    ; 先頭をスキップ
    (if (bol-white-p)
	(setq ret2 (skip-chars-forward " \t")))
    ; インデントかスキップで変更有りとする
    (or ret1 ret2)))

; -------------------------------
; タグのチェック
; Tue, 08 Feb 2000 21:40:31 +0900
(defun html+-check-match-tag ()
  (interactive)
  "html+-mode: タグの整合性チェック"
  (multiple-value-bind (rtn pntA tagA pntZ tagZ)
      (match-tag)
    (cond ; 正常終了
     ((and rtn pntA)
      (set-mark pntA)
      (html+-highlight-tag pntA t)
      (message "このレベルでのタグの整合は取れているらしい")
      (show-match-tag pntA nil))
     (rtn
      (message "全てのタグの整合がとれとります"))
     ; 異常終了
     (pntA
      (set-mark pntA)
      (html+-highlight-tag pntA nil)
      (html+-highlight-tag pntZ nil)
      (message (format nil "タグの整合がとれていない個所がある <~A> ... </~A>" tagA tagZ))
      (show-match-tag pntA pntZ))
     (t
      (message "はじまりのタグが足りません")))))

; -------------------------------
; タグを閉じる
; Tue, 08 Feb 2000 21:38:57 +0900
(defun html+-close-match-tag ()
  (interactive "*")
  "html+-mode: 自動的にタグを閉じる"
  (or
   ; 特殊位置
   (case (parse-point-syntax)
     ; [1]文字列の中の場合の補完
     (:string
      (insert (save-excursion
		(while (and (backward-char)
			    (eq (parse-point-syntax) :string))
		  (skip-syntax-spec-backward "^\""))
		(following-char))))
     ; [2]コメントの中の場合の補完
     (:comment
      (insert "-->"))
     ; [3]タグの中の場合
     (:tag
      (delete-trailing-spaces)
      (insert ">")))
   ; [4]閉じタグの補完
   (multiple-value-bind (rtn pntA tagA)
       (uplevel-tag)
     (if rtn
	 (progn
	   (or (bol-white-p)
	       (eq (indent-of-a-line pntA) (indent-of-a-line))
	       (insert "\n"))
	   (insert "</" tagA ">")
	   (setq pntA (indent-line-with-saved-point pntA))
	   (set-mark pntA)
	   (html+-highlight-tag pntA t)
	   (html+-highlight-tag (1- (point)) t)
	   (show-match-tag pntA nil))
       (message "必要ないか不整合があります")))))

; -------------------------------
; 補完らしきもの
; Tue, 08 Feb 2000 22:04:40 +0900
(defun html+-do-completion ()
  (interactive "*")
  "html+-mode: タグの自動補完"
  ; 補完処理
  (cond ((html+-indent-line))
	; 通常空間以外
	((eq (parse-point-syntax) :tag)
	 ; タグの場合
	 (let (from to lst)
	   (setq to (point))
	   (save-excursion
	     (skip-syntax-spec-backward "w_")
	     (cond
	      ((syntax-open-tag-p (preceding-char))
	       (backward-char)
	       (setq lst *html+-completion-tags-list*))
	      ((find (preceding-char) " \"\t")
	       (setq lst *html+-completion-prop-list*))
	      (t
	       (if (find (preceding-char) "=;\" ")
		   t
		 (if (find (preceding-char) "&")
		     (backward-char)
		   (skip-syntax-spec-backward "^ {")))
	       (setq lst *html+-completion-text-list*)))
	     (setq from (point)))
	   (do-completion from to :list-ignore-case lst)
	   (setq *this-command* 'minibuffer-complete)))
	; 通常空間の場合
	((not (or (bobp)))
	 (let ((from
		(save-excursion
		  (skip-syntax-spec-backward "w_")
		  (if (syntax-symbol-prefix-p (preceding-char)) (backward-char))
		  (point)))
	       (to (point))
	       (lst *html+-completion-text-list*))
	   (do-completion from to :list-ignore-case lst)
	   (setq *this-command* 'minibuffer-complete)))))

; -------------------------------
; "/"を入力したときの補完
; 処理速度を上げるため厳密なチェックはしないことにした
; Sat, 05 Feb 2000 11:40:28 +0900
(defun html+-slash ()
  (interactive "*")
  "html+-mode: \"/\"を入力したときのタグの補完"
  (insert "/")
  (unless (and (eq (parse-point-syntax) :tag)
	       (looking-back "</"))
    (return-from html+-slash nil))
  (multiple-value-bind (rtn pntA tagA)
      (uplevel-tag)
    (if rtn
	(progn
	  (insert tagA ">")
	  (setq pntA (indent-line-with-saved-point pntA))
	  (set-mark pntA)
	  (html+-highlight-tag pntA t)
	  (html+-highlight-tag (1- (point)) t)
	  (show-match-tag pntA nil))
      (message "必要ないか不整合があります"))))

; -------------------------------
; タグを意識した移動
; Fri, 10 Mar 2000 17:45:11 +0900
(defun html+-forward-tag ()
  (interactive)
  "html+-mode: いろいろと勘案して前に移動"
  (let ((stx (parse-point-syntax)))
    (cond ((eq stx :string)
	   (skip-syntax-spec-forward "^\""))
	  ((eq stx :tag)
	   (skip-chars-forward "^ \n<")
	   (skip-chars-forward " "))
	  (t
	   (forward-sexp)))))

(defun html+-backward-tag ()
  (interactive)
  "html+-mode: いろいろと勘案して後ろに移動"
  (let ((stx (parse-point-syntax)))
    (cond ((eq stx :string)
	   (skip-syntax-spec-backward "^\""))
	  ((eq stx :tag)
	   (skip-chars-backward " ")
	   (skip-chars-backward "^ }>"))
	  (t
	   (backward-sexp)))))

; -------------------------------
; delete-char-or-selectionと
; backward-delete-char-untabify-or-selectionの上書き
; Sun, 26 Mar 2000 21:58:41 +0900
(defun html+-delete-char-or-selection (&optional (n 1))
  (interactive "*")
  "html+-mode: delete-char-or-selectionのhtml+-mode版"
  (or
   ; タグの削除
   (html+-delete-following-tag)
   ; 文字列の削除
   (html+-delete-following-string)
   ; それ以外
   (delete-char-or-selection n)))

(defun html+-backward-delete-char-untabify-or-selection (&optional (n 1))
  (interactive "*")
  "html+-mode: backward-delete-char-untabify-or-selectionのhtml+-mode版"
  (or
   ; タグの削除
   (html+-delete-preceding-tag)
   ; 文字列の削除
   (html+-delete-preceding-string)
   ; それ以外
   (backward-delete-char-untabify-or-selection)))

; -------------------------------
; 直前／直後のタグの削除
; Fri, 25 Feb 2000 21:27:39 +0900
(defun html+-delete-following-tag ()
  (interactive "*")
  "html+-mode: 直後のタグの削除"
  (if (and (syntax-open-tag-p (following-char))
	   (not (parse-point-syntax))
	   (save-excursion
	     (unwind-protect (goto-matched-parenthesis))))
      (delete-region
       (point)
       (or (save-excursion
	     (and (unwind-protect (goto-matched-parenthesis))
		  (forward-char)
		  (point)))
	   (point)))))

(defun html+-delete-preceding-tag ()
  (interactive "*")
  "html+-mode: 直前のタグの削除"
  (if (and (syntax-close-tag-p (preceding-char))
	   (not (parse-point-syntax))
	   (save-excursion
	     (backward-char)
	     (unwind-protect (goto-matched-parenthesis))))
      (delete-region
       (point)
       (or (save-excursion
	     (and (backward-char)
		  (unwind-protect (goto-matched-parenthesis))
		  (point)))
	   (point)))))
; -------------------------------
; 直前／直後の文字列の削除
; Wed, 15 Aug 2001 16:53:31 +0900
(defun html+-delete-following-string ()
  (interactive "*")
  "html+-mode: 直後の文字列の削除"
  (if (and ; "abc"の後ろの#\"のsyntaxがnilになっているため
       ; 直後の文字列だけでなく次の文字のsyntaxも見なければ本当に開始部分か分からない。
       (syntax-string-p (following-char))
       (not (eq (parse-point-syntax) :string))
       (eq (parse-point-syntax (1+ (point))) :string)
       (save-excursion
	 (unwind-protect (goto-matched-quote))))
      (delete-region
       (point)
       (or (save-excursion
	     (and (unwind-protect (goto-matched-quote))
		  (forward-char)
		  (point)))
	   (point)))))

(defun html+-delete-preceding-string ()
  (interactive "*")
  "html+-mode: 直前の文字列の削除"
  (if (and (syntax-string-p (preceding-char))
	   (not (eq (parse-point-syntax (1- (point))) :string))
	   (eq (parse-point-syntax (- (point) 2)) :string)
	   (save-excursion
	     (backward-char)
	     (unwind-protect (goto-matched-quote))))
      (delete-region
       (point)
       (or (save-excursion
	     (and (backward-char)
		  (unwind-protect (goto-matched-quote))
		  (point)))
	   (point)))))

; -------------------------------
; 直前／直後のタグのkill
; Fri, 25 Feb 2000 21:27:39 +0900
(defun html+-kill-following-tag ()
  (interactive "*")
  "html+-mode: 直後のタグのkill"
  (if (and (syntax-open-tag-p (following-char))
	   (not (parse-point-syntax))
	   (save-excursion
	     (unwind-protect (goto-matched-parenthesis))))
      (kill-region
       (point)
       (or (save-excursion
	     (and (unwind-protect (goto-matched-parenthesis))
		  (forward-char)
		  (point)))
	   (point)))
    (progn
      (kill-word))))

(defun html+-kill-preceding-tag ()
  (interactive "*")
  "html+-mode: 直前のタグのkill"
  (if (and (syntax-close-tag-p (preceding-char))
	   (not (parse-point-syntax))
	   (save-excursion
	     (backward-char)
	     (unwind-protect (goto-matched-parenthesis))))
      (kill-region
       (point)
       (or (save-excursion
	     (and (backward-char)
		  (unwind-protect (goto-matched-parenthesis))
		  (point)))
	   (point)))
    (progn
      (backward-kill-word))))

; -------------------------------
; それっぽいタグの挿入
; Fri, 24 Mar 2000 11:37:38 +0900
(defvar *html+-guess-tmp-list* nil)
(defvar *html+-guess-src-point* nil)
(defvar *html+-guess-undo-point* nil)
(defvar *html+-guess-string* nil)
(defun html+-guess-tag ()
  (interactive "*")
  "html+-mode: それっぽいタグの挿入"
  ; 初期設定
  (if (and (eq *last-command* 'html+-guess-tag)
	   *html+-guess-tmp-list*)
      ; 以前のを無効にしてリストを進める
      (progn
	(clear-undo-boundary)
	(delete-region *html+-guess-src-point* (point))
	(pop *html+-guess-tmp-list*))
    ; それっぽいタグのリストを取り出す／できなければ抜ける
    (multiple-value-bind (rtn pntA tagA)
	(uplevel-tag nil t)
      (unless rtn (setq tagA ""))
      ; 候補のリストの取り出し
      (setq *html+-guess-tmp-list*
	    (cdr (assoc-if
		  #'(lambda (x) (string-equal x tagA))
		  *html+-guess-list*)))
      (unless *html+-guess-tmp-list*
	(message "それっぽいのがないか、別のタグの先頭に一致してます")
	(return-from html+-guess-tag nil))
      ; 位置記憶
      (setq *html+-guess-undo-point* (point))
      ; 先頭に何かあるときに候補を絞る
      (setq *html+-guess-src-point* (point))
      (let ((p (point)))
	(save-excursion
	  (when (and (eq (parse-point-syntax) :tag)
		     (progn
		       (skip-syntax-spec-backward ".w_")
		       (setq *html+-guess-string*
			     (concat "^" (buffer-substring (point) p)))
		       (backward-char)
		       (syntax-open-tag-p (following-char))))
	    (setq *html+-guess-tmp-list*
		  (remove-if-not
		   #'(lambda (x) (string-matchp *html+-guess-string* x))
		   *html+-guess-tmp-list*))
	    (unless *html+-guess-tmp-list*
	      (message "それじゃ候補なし")
	      (return-from html+-guess-tag nil))
	    (setq *html+-guess-src-point* (point))
	    (delete-region (point) p))))))
  ; 検索した結果どうなった？
  (cond
   ; リストから挿入
   (*html+-guess-tmp-list*
    (let* ((tg (car *html+-guess-tmp-list*)))
      (insert "<" tg)
      (unless (syntax-whitespace-p (char (reverse tg) 0))
	(insert ">")))
    (html+-highlight-tag *html+-guess-src-point* t)
    (message "これかも ..."))
   ; それっぽいのを挿入
   (t
    (undo)
    (goto-char *html+-guess-undo-point*)
    (message "尽きた ..."))))

; -------------------------------
; 前のタグの複写
; Sun, 27 Feb 2000 08:05:13 +0900
(defvar *html+-copy-src-point* nil)
(defvar *html+-copy-dst-point* nil)
(defun html+-copy-tag ()
  (interactive "*")
  "html+-mode: 前のタグの複写"
  (let (tgl (cnt 0))
    (save-excursion
      ; 初期処理
      (cond
       ; 二回目以降
       ((and (eq *last-command* 'html+-copy-tag)
	     (integerp *html+-copy-src-point*))
	(clear-undo-boundary)
	(delete-region *html+-copy-dst-point* (point))
	(goto-char *html+-copy-src-point*))
       ; 初めての場合
       (t
	(setq *html+-copy-dst-point* nil)))
      ; 候補の検索
      (setq *html+-copy-src-point*
	    (while (< (incf cnt) *html+-count-limit-copy-tag*)
	      (multiple-value-bind (rtn pntA tagA)
		  (uplevel-tag t t)
		(cond
		 (rtn
		  ; ネストのスキップ
		  (push tagA tgl)
		  (goto-char pntA)
		  (while (< (incf cnt) *html+-count-limit-copy-tag*)
		    (multiple-value-bind (rtn0 pntA0 tagA0 pntB0 tagB0)
			(uplevel-tag t t)
		      (cond (rtn0
			     (push tagA0 tgl)
			     (goto-char pntA0))
			    (pntA0
			     (if (string-not-equal (car tgl) tagA0)
				 (goto-char pntA0)
			       (progn
				 (goto-char pntB0)
				 (pop tgl)
				 (unless tgl (return)))))
			    (t
			     (return)))))
		  ; スキップに失敗
		  (if tgl (return nil)))
		 ; 同じレベルならそれが候補
		 (pntA
		  (return pntA))
		 ; 先頭まで来たらしい
		 (t
		  (return t)))))))
    ; 検索した結果どうなった？
    (cond
     ; 最大値になった
     ((>= cnt *html+-count-limit-copy-tag*)
      (message "真似るものが無さそうです ... この辺りには"))
     ; 候補があった
     ((integerp *html+-copy-src-point*)
      (or (bol-white-p)
	  (eq (indent-of-a-line *html+-copy-src-point*) (indent-of-a-line))
	  (insert "\n"))
      (setq *html+-copy-dst-point* (point))
      (insert (or (tag-string *html+-copy-src-point*) "<"))
      (setq *html+-copy-dst-point* (indent-line-with-saved-point *html+-copy-dst-point*))
      (html+-highlight-tag *html+-copy-src-point* t)
      (html+-highlight-tag (1- (point)) t)
      (message "見つかりました")
      (show-match-tag *html+-copy-src-point* nil))
     ; 先頭まで来た
     (*html+-copy-src-point*
      (message "真似るものが有りません"))
     ; 構造違う
     (t
      (if *html+-copy-dst-point* (undo))
      (message "尽きた ...")))))

; -------------------------------
; ブレークタグの挿入
; Fri, 24 Mar 2000 09:55:31 +0900
(defun html+-insert-break (&optional (arg 1))
  (interactive "*p")
  "html+-mode: <BR>タグの挿入"
  (dotimes (x arg)
    (unless (parse-point-syntax)
      (delete-trailing-spaces)
      (insert "<br>")
      (html+-indent-line))
    (html+-newline-and-indent)))

; -------------------------------
; イメージタグの挿入
; Tue, 29 May 2001 23:28:18 +0900
(defun html+-insert-image (f)
  (interactive "*FInsert Image Tag (GIF/JPEG/PNG only): ")
  "html+-mode: <IMG>タグの挿入 GIF/JPEG/PNG形式に対応"
  (when (parse-point-syntax)
    (message "へんなところです")
    (return-from html+-insert-image nil))
  (if (file-exist-p f)
      (let (w h)
	(or (multiple-value-bind (w0 h0) (get-image-size f) (setq w w0) (setq h h0))
	    (message "多分... GIF/JPEG/PNG形式ではありません"))
	(and w h (insert (format nil "<img src=\"~A\" width=\"~D\" height=\"~D\" alt=\"\">" (adjust-path f) w h))))
    (progn
      (message "ファイルが見当たらないのですが、、、")
      (insert (format nil "<img src=\"~A\" alt=\"\">" (adjust-path f))))))

; -------------------------------
; インターネットショートカットの挿入
; 【Sun, 20 Jan 2002 15:59:23 +0900】
(c:define-dll-entry
  winapi:DWORD
  GetPrivateProfileString
  (winapi:LPCSTR winapi:LPCSTR winapi:LPCSTR winapi:LPCSTR winapi:DWORD winapi:LPCSTR)
  "kernel32" "GetPrivateProfileStringA")

(defun html+-insert-internet-shortcut (f)
  (interactive "*FInsert Internet Shortcut: ")
  "html+-mode: インターネットショートカットの挿入"
  (unless (string-matchp "^\\(.*\\)\.url$" (file-namestring f))
    (message "インターネットショートカットでは無いと思われます")
    (return-from html+-insert-internet-shortcut nil))
  (when (parse-point-syntax)
    (message "へんなところです")
    (return-from html+-insert-internet-shortcut nil))
  (let* ((ttl (match-string 1))
	 (sec (si:make-string-chunk "InternetShortcut"))
	 (key (si:make-string-chunk "URL"))
	 (non (si:make-string-chunk ""))
	 (sz 500)
	 (url (si:make-chunk nil sz))
	 (file (si:make-string-chunk (map-slash-to-backslash f))))
    (GetPrivateProfileString sec key non url sz file)
    (insert (format nil "<a href=\"~A\">~A</a>" (si:unpack-string url 0) ttl))))

; -------------------------------
; 相対／絶対パスの挿入
; Mon, 17 Jan 2000 21:29:13 +0900
(defun html+-insert-path (f)
  (interactive "*FInsert Path: ")
  "html+-mode: パスの挿入"
  (let ((e (string-trim "\"'" (format nil "~A" (adjust-path f)))))
    (unless				; 状況に依存して処理を変更
	(case
	    (progn (insert "*") (prog1 (parse-point-syntax(1-(point))) (undo)))
	  (:string (insert #\' e #\'))	; 文字列中の場合は引用符
	  (:tag (insert #\" e #\")))	; タグの場合は二重引用符
      (insert e))))			; 通常空間ならなし

; -------------------------------
; バッファからファイルと識別子を探し出して挿入
; Mon, 14 May 2001 21:57:13 +0900
(defun html+-insert-path-dialog ()
  (interactive "*")
  "html+-mode: パス選択用ダイアログ"
  (let (lst)
    ; リストの作成
    (dolist (dbuf (get-html+-mode-buffer-list))
      (let (fname)
	(unless (eq dbuf (selected-buffer))
	  (setq fname (adjust-path (get-buffer-file-name dbuf)))
	  (push (list fname) lst))
	(dolist (name (get-name-list dbuf))
	  (push (list (concat fname "#" name)) lst))))
    (setq lst (reverse lst))
    ; 一覧の作成
    (multiple-value-bind (result data)
	(dialog-box `(dialog 0 0 245 178
			     (:caption "ﾘﾝｸ候補")
			     (:font 9 "ＭＳ Ｐゴシック")
			     (:control
			      (:listbox list1 nil #x50b10111 1 1 242 156)
			      (:button IDOK "OK" #x50010001 141 162 50 14)
			      (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 193 162 50 14)))
		    (list (cons 'list1 lst))
		    `((list1 :must-match t :enable (open all IDOK))))
      (when (eq result 'IDOK)
	(html+-insert-path (cadr (assoc 'list1 data)))))))

; -------------------------------
; ハイライト表示
; 喜多さんからパクリ
; Sun, 23 Jan 2000 17:01:56 +0900
(defun html+-highlight-tag (pnt0 flg)
  "html+-mode: タグのハイライト表示"
  (if *html+-tag-highlight*
      (let (pnt1 attr)
	(save-excursion
	  (goto-char pnt0)
	  (if (unwind-protect (goto-matched-parenthesis))
	      (setq pnt1 (point))
	    (setq pnt1 (save-excursion
			 (skip-syntax-spec-forward "{w_")
			 (1- (point))))))
	(if (< pnt0 pnt1) (incf pnt1) (incf pnt0))
	(setq attr (if flg *html+-tag-attribute* *html+-tag-invalid-attribute*))
	(apply #'set-text-attribute pnt0 pnt1 *html+-tag* attr))))

; ハイライト削除
(defun html+-delete-highlight-tag ()
  (if *html+-tag-highlight*
      (delete-text-attributes *html+-tag*)))

(add-hook '*pre-command-hook* 'html+-delete-highlight-tag)

; -------------------------------
; バッファの選択
; Fri, 27 Apr 2001 08:39:00 +0900
(define-history-variable *html+-select-link-all* nil)
(define-history-variable *html+-select-link-open* t)
(define-history-variable *html+-select-link-browser* t)
(defun html+-select-buffer-dialog ()
  (interactive)
  "html+-mode: バッファ選択用ダイアログ"
  (let (lst title sbuf (navigate (get-navigate-function)))
    ; リストの作成
    (setq sbuf (selected-buffer))
    (dolist (dbuf (get-html+-mode-buffer-list))
      (set-buffer dbuf)
      (save-excursion
	(goto-char (point-min))
	(setq title (if (scan-buffer "<title[^>]*>[ \t　\n]*\\([^<\n]*\\)"
				     :no-dup nil :regexp t :case-fold t
				     :tail t :reverse nil :limit 500)
			(match-string 1)
		      "<タイトル不明>")))
      (set-buffer sbuf)
      (let ((adp (adjust-path (get-buffer-file-name dbuf))))
	(push (list title adp adp) lst)
	(dolist (name (get-name-list dbuf))
	  (push (list "" (concat adp "#" name) adp name) lst))))
    (setq lst (reverse lst))
    ; 一覧の作成
    (multiple-value-bind (result data)
	(dialog-box `(dialog 0 0 245 178
			     (:caption "html+-mode のﾊﾞｯﾌｧ")
			     (:font 9 "ＭＳ Ｐゴシック")
			     (:control
			      (:listbox list1 nil #x50b10111 1 1 242 156)
			      (:button browser "Browser(&B)" ,(if navigate #x50010003 #x58010003) 2 162 46 14)
			      (:button IDOK "OK" #x50010001 141 162 50 14)
			      (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 193 162 50 14)))
		    (list (cons 'list1 lst)
			  (cons 'browser *html+-select-link-browser*))
		    `((list1 :must-match t :column (25 55) :enable (open all ,(if navigate 'browser nil) IDOK))))
      (when (eq result 'IDOK)
	(let (path name)
	  (if navigate (setq *html+-select-link-browser* (cdr (assoc 'browser data))))
	  (setq path (adjust-truename (nth 3 (assoc 'list1 data))))
	  (setq name (nth 4 (assoc 'list1 data)))
	  (find-file-with-name path name)
	  (if (and navigate
		   (fboundp navigate)
		   *html+-select-link-browser*)
	      (funcall navigate (adjust-url path name))))))))

; -------------------------------
; リンク先の選択
; Fri, 21 Apr 2000 15:19:18 +0900
(defun html+-select-link-dialog ()
  (interactive)
  "html+-mode: リンク選択用ダイアログ"
  (let (lst url pntA pntZ (navigate (get-navigate-function)))
    ; 候補の収集
    (save-excursion
      (if *html+-select-link-all* (goto-char (point-min)))
      (unless (eq (point) (point-min))
	(save-excursion
	  (goto-char (point-min))
	  (push (list 1 "<先頭行へ>" (point) (point)) lst)))
      (while (scan-buffer "\\(href\\|name\\|id\\)=\\(\"[^\">]+\"\\|[^\"> \t\n]+\\)"
			  :no-dup nil
			  :regexp t
			  :case-fold t
			  :tail t
			  :reverse nil)
	(when (eq (parse-point-syntax) :tag)
	  (setq url (string-trim "\"" (match-string 2)))
	  (unless (string-equal (match-string 1) "href")
	    (setq url (format nil "【~A】" url)))
	  (setq pntA (match-beginning 0))
	  (setq pntZ (match-end 0))
	  (unless (member url
			  *html+-select-link-no-select*
			  :test 'string-matchp-internal)
	    (push (list (current-line-number) url pntA pntZ) lst))))
      (setq lst (reverse lst)))
    ; ダイアログ
    (multiple-value-bind (result data)
	(dialog-box `(dialog 0 0 245 178
			     (:caption ,(concat (buffer-name (selected-buffer)) " のﾘﾝｸ"))
			     (:font 9 "ＭＳ Ｐゴシック")
			     (:control
			      (:listbox list1 nil #x50b10111 1 1 242 145)
			      (:button open "開く(&O)" #x50010003 2 150 32 14)
			      (:button all "次から全部(&A)" #x50010003 48 150 56 14)
			      (:button browser "Browser(&B)" ,(if navigate #x50010003 #x58010003) 2 162 46 14)
			      (:button IDOK "OK" #x50010001 141 162 50 14)
			      (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 193 162 50 14)))
		    (list (cons 'list1 lst)
			  (cons 'open *html+-select-link-open*)
			  (cons 'all *html+-select-link-all*)
			  (cons 'browser *html+-select-link-browser*))
		    `((list1 :must-match t :column (-4 66) :enable (open all ,(if navigate 'browser nil) IDOK))))
      (when (eq result 'IDOK)
	; 取り敢えず移動
	(if *html+-select-link-all* (goto-char (point-min)))
	; ダイアログの情報を更新
	(setq lst (cdr (assoc 'list1 data)))
	(setq url (nth 1 lst))
	(setq pntA (nth 2 lst))
	(setq pntZ (nth 3 lst))
	(setq *html+-select-link-open* (cdr (assoc 'open data)))
	(setq *html+-select-link-all* (cdr (assoc 'all data)))
	(if navigate (setq *html+-select-link-browser* (cdr (assoc 'browser data))))
	; リンク元にジャンプ
	(goto-char pntZ)
	(save-restriction
	  (save-excursion
	    (goto-char pntA)
	    (narrow-to-region pntA pntZ)
	    (looking-at "href=\"?\\([^#?\"]+\\)?\\(#\\([^?\"]*\\)\\)?\\(\?[^\"]*\\)?\\|\\(name\\|id\\)=\"?\\([^?\"]+\\)" t)))
	(let ((path (match-string 1))
	      (name (or (match-string 3)
			(match-string 6)))
	      (query (match-string 4)))
	  ; パスを修正
	  (setq path (adjust-truename path))
	  ; エディタで開くもしくは色づけ
	  (if (and *html+-select-link-open*
		   (file-readable-p path)
		   (not (member path
				*html+-select-link-no-open*
				:test 'string-matchp-internal)))
	      (find-file-with-name path name)
	    (apply #'set-text-attribute pntA pntZ *html+-tag* *html+-tag-attribute*))
	  ; ブラウザで開く
	  (if (and navigate
		   (fboundp navigate)
		   *html+-select-link-browser*
		   (not (member path
				*html+-select-link-no-browser*
				:test 'string-matchp-internal)))
	      (funcall navigate (adjust-url path name query))))))))

; -------------------------------
; インデントの計算
; Sun, 04 Jun 2000 19:44:34 +0900
; 計算できれば数値を返す
; <xmp><pre>とかの中ならnilを返す
(defun html+-calc-indent ()
  (let (col)
    (save-excursion
      (goto-bol)
      (skip-chars-forward " \t")
      (if (parse-point-syntax)
	  ; タグ中の継続行の場合
	  (save-excursion
	    (while (and (scan-buffer "^[ \t]*[^ \t\n].*$"
				     :reverse t
				     :regexp t
				     :tail nil
				     :no-dup t)
			(parse-point-syntax)))
	    (skip-chars-forward " \t")
	    (setq col (+ (current-column) *html+-indent-column*)))
	; タグを探す
	(let ((f1 (looking-at "</\\(\\w*\\)"))
	      ; <pre>,<xmp>は確実にひとレベル上のタグを調べる
	      ; それ以外は同じレベルで抜けても良し
	      (f2 (not (find (match-string 1) *html+-tags-list-no-indent*
			     :test 'string-equal))))
	  (multiple-value-bind (rtn pntA tagA)
	      (uplevel-tag f2)
	    (cond (rtn
		   ; ひとレベル上のタグが見つかった
		   (setq col (indent-of-a-line pntA))
		   (unless f1
		     (if (find tagA *html+-tags-list-no-indent*
			       :test 'string-equal)
			 (setq col nil)
		       (setq col (+ col *html+-indent-column*)))))
		  (pntA
		   ; 同じレベルのタグが見つかった
		   (setq col (indent-of-a-line pntA))
		   (when f1
		     (setq col (- col *html+-indent-column*)))))))))
    col))

; -------------------------------
; インデントコマンド用
; Sun, 04 Jun 2000 19:44:34 +0900
(defun html+-comment-indent ()
  (save-excursion
    (cond ((looking-for comment-start-skip)
	   (current-column))
	  (t
	   (or (html+-calc-indent)
	       0)))))

; -------------------------------
; charsetの検出
(defun html+-detect-charset ()
  (interactive)
  (let (code result)
    (and (save-excursion
	   (goto-char (point-min))
	   (scan-buffer "charset=\\(\\_s+\\)" :regexp t :limit 3000))
	 (setq code (match-string 1))
	 (setq result (find-if #'(lambda (x) (find code x :test 'string-equal))
			       *character-set-alist*))
	 (change-fileio-encoding (eval (car result)))
	 (revert-buffer (car result)))))

;;; -------------------------------------------------------
;;; Local Functions
;;; -------------------------------------------------------

; -------------------------------
; タグリストの正規表現化
(defun compile-tags-regexp (lst)
  (compile-regexp
   (concat "<\\(/\\)?\\(" (string-right-trim "\\|" (format nil "~{~A\\|~}" lst)) "\\)\\(\\W\\|$\\)") t))

; -------------------------------
; navigate関数の取得
; Fri, 21 Apr 2000 15:19:18 +0900
(defun get-navigate-function ()
  (or *html+-navigate-function*
      (and (find-package "browserex")
	   (find-symbol "navigate" "browserex"))
      (find-symbol "navigate" "user")))

; -------------------------------
; 対応する引用符（途中）
; Wed, 16 May 2001 06:47:28 +0900
(defun goto-matched-quote ()
  (let ((spnt (point)) dpnt)
    (save-excursion
      ; "abc"<の場合
      (if (and (eq (parse-point-syntax (1- (point))) :string)
	       (not (eq (parse-point-syntax) :string)))
	  (progn
	    (skip-syntax-spec-backward "^\"")
	    (while (and (backward-char)
			(eq (parse-point-syntax) :string))
	      (skip-syntax-spec-backward "^\""))
	    (setq dpnt (point)))
	; >"abc"の場合
	(if (and (not (eq (parse-point-syntax) :string))
		 (eq (parse-point-syntax (1+ (point))) :string))
	    (progn
	      (forward-char)
	      (skip-syntax-spec-forward "^\"")
	      (while (and (eq (parse-point-syntax) :string)
			  (forward-char))
		(skip-syntax-spec-forward "^\""))
	      (unless (eobp) (setq dpnt (point)))))))
    (and dpnt (goto-char dpnt))))

; -------------------------------
; ファイル名と名前で開く
; Mon, 14 May 2001 23:26:55 +0900
(defun find-file-with-name (path &optional name)
  (if (find-file path)
      (when name
	(save-excursion
	  (goto-char (point-min))
	  (scan-buffer (concat "\\(name\\|id\\)=\"\\(" (regexp-quote name) "\\)\"")
		       :no-dup nil
		       :regexp t
		       :case-fold t
		       :tail nil
		       :reverse nil))
	(if (match-beginning 0)
	    (progn
	      (goto-char (match-end 0))
	      (when *html+-tag-highlight*
		(apply #'set-text-attribute
		       (match-beginning 0)
		       (match-end 0)
		       *html+-tag*
		       *html+-tag-attribute*)))
	  (message "#~A はないようだ" name)))
    (message "#~A はないようだ" path)))

; -------------------------------
; html+-modeのバッファのリスト
; Mon, 14 May 2001 23:26:55 +0900
(defun get-html+-mode-buffer-list ()
  (let (lst (sbuf (selected-buffer)))
    (dolist (dbuf (buffer-list))
      (set-buffer dbuf)
      (make-local-variable 'buffer-mode)
      (when (eq buffer-mode 'html+-mode)
	(push dbuf lst)))
    (set-buffer sbuf)
    (sort lst #'string-lessp :key #'(lambda (x) (interactive) (get-buffer-file-name x)))))

; -------------------------------
; 指定バッファ内の識別子のリスト
; Sun, 23 Apr 2000 10:05:15 +0900
(defun get-name-list (dbuf)
  (let (lst (sbuf (selected-buffer)))
    (set-buffer dbuf)
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "\\(name\\|id\\)=\\(\"[^\">]+\"\\|[^\"> \t\n]+\\)"
			  :no-dup nil
			  :regexp t
			  :case-fold t
			  :tail t
			  :reverse nil)
	(when (eq (parse-point-syntax) :tag)
	  (pushnew (string-trim "\"" (match-string 2)) lst))))
    (set-buffer sbuf)
    (reverse lst)))

; -------------------------------
; string-matchpの引数スワップ版
; Sun, 23 Apr 2000 10:05:15 +0900
(defun string-matchp-internal (x y)
  (string-match y x))

; -------------------------------
; 桁ずれを考慮したインデント
; 引数のポイントがどうなったかを戻す
; Wed, 22 Mar 2000 16:22:00 +0900
(defun indent-line-with-saved-point (pnt)
  (let ((m (make-marker)))
    (set-marker m pnt)
    (html+-indent-line)
    (prog1
	(marker-point m)
      (unset-marker m))))

; -------------------------------
; タグ全体の取得
; Sun, 27 Feb 2000 08:07:58 +0900
(defun tag-string (&optional pnt)
  (save-excursion
    (if (integerp pnt)
	(goto-char pnt)
      (setq pnt (point)))
    (let (pnt2)
      (cond ((setq pnt2 (point-end-of-tag pnt))
	     (buffer-substring pnt pnt2))
	    (t
	     (save-excursion
	       (skip-syntax-spec-forward "{w_")
	       (setq pnt2 (point)))
	     (buffer-substring pnt pnt2))))))

; -------------------------------
; タグのうしろ
; Sun, 27 Feb 2000 08:08:05 +0900
(defun point-end-of-tag (&optional pnt)
  (save-excursion
    (if (integerp pnt)
	(goto-char pnt)
      (setq pnt (point)))
    (and (syntax-open-tag-p (following-char))
	 (unwind-protect (goto-matched-parenthesis))
	 (1+ (point)))))

; -------------------------------
; インデント関連
(defun indent-to-column (col)
  (save-excursion
    (goto-bol)
    (skip-chars-forward " \t")
    (unless (eq col (current-column))
      (delete-trailing-spaces)
      (or (if (backward-char)
	      (prog2
		  (insert #\LFD)
		  (indent-to col)
		(delete-char))
	    (indent-to col))
	  (zerop col)))))

(defun indent-of-a-line (&optional pnt)
  (save-excursion
    (if pnt (goto-char pnt))
    (goto-bol)
    (skip-chars-forward " \t")
    (current-column)))

(defun bol-white-p ()
  (save-excursion
    (skip-chars-backward " \t")
    (bolp)))

; -------------------------------
; タグの構造をツリーで取得
(defun get-tag-tree (&optional str)
  (long-operation
    (let (strb)
      (save-restriction
	(widen)
	(save-excursion
	  (goto-char (point-max))
	  (loop
	    (multiple-value-bind (rtn pntA tagA pntZ tagZ strl)
		(match-tag *html+-tags-regexp* strb)
	      (setq strb strl)
	      (unless pntA (return))
	      (goto-char pntA)))))
      (list* (list* (list (selected-buffer)) strb) str))))

; -------------------------------
; 一致するタグの名前とポイントを検索
; 1.	正常終了か？
; 2.	一致する開始タグの位置
; 3.	一致する開始タグの名前
; 4.	一致する／しない閉じタグの位置
; 5.	一致する／しない閉じタグの名前
; 6.	ツリーの構造
; 	HTMLの例）
; 		<html>
; 		  <head>
;		    <title>
; 		    </title>
; 		  </head>
;		  <body>
; 		  </body>
; 		</html>
; 	構造の取得例）
; 	(((0 79) ((9 52) ((29 41))) ((62 71))))
(defun match-tag (&optional (expr *html+-tags-regexp*) str)
  (let ((lev 0) pnt tag tgl ptl (stl str) stb)
    (save-excursion
      (while
	  (and (<= 0 lev)
	       (scan-buffer expr
			    :regexp t
			    :reverse t
			    :tail nil
			    :case-fold t
			    :no-dup t))
	(cond ((parse-point-syntax))
	      ((match-string 1)
	       (incf lev)
	       (push (match-string 2) tgl)
	       (push (point) ptl)
	       (push stl stb)
	       (setq stl nil))
	      ((match-string 2)
	       (decf lev)
	       (setq tag (match-string 2))
	       (setq pnt (match-beginning 0))
	       (when (and tgl (not (string-equal (car tgl) tag)))
		 (return-from match-tag
		   (values nil pnt tag (car ptl) (car tgl)
			   (list* (list* (list pnt (point-end-of-tag (car ptl)) :unmatch) stl) (pop stb)))))
	       (setq stl (list* (list* (list pnt (point-end-of-tag (car ptl))) stl) (pop stb)))
	       (pop tgl)
	       (pop ptl)))))
    (cond ((< 0 lev)
	   (while ptl
	     (setq stl (list* (list* (list nil (point-end-of-tag (car ptl)) :unmatch) stl) (pop stb)))
	     (pop ptl))
	   (values nil nil nil nil nil stl))
	  ((= 0 lev)
	   (values t nil nil nil nil stl))
	  (t
	   (values t pnt tag nil nil stl)))))

; -------------------------------
; ひとつ上のタグを取り出す
; 同レベルのタグの場合でも中断可
; 1.	正常終了か？
; 2.	開始タグの位置
; 3.	開始タグの名前
(defun uplevel-tag (&optional same nobol)
  (save-excursion
    (while (scan-buffer *html+-tags-regexp*
			:regexp t
			:reverse t
			:tail nil
			:case-fold t
			:no-dup t)
      (cond ((parse-point-syntax))
	    ((match-string 1)
	     (let ((pntB (point)))
	       (multiple-value-bind (rtn pntA tagA pntZ tagZ)
		   (match-tag (compile-tags-regexp (list (match-string 2))))
		 (unless (and rtn pntA)
		   (return-from uplevel-tag (values nil nil nil nil nil)))
		 (goto-char pntA)
		 (if (and same (or nobol (bol-white-p)))
		     (return-from uplevel-tag (values nil pntA tagA pntB tagA))))))
	    ((match-string 2)
	     (return-from uplevel-tag
	       (values t (match-beginning 0) (match-string 2) nil nil)))))))

; -------------------------------
; 一致したタグを表示
(defun show-match-tag (pntA pntZ)
  (let (v0 v1 v2)
    (setq v0 (pos-visible-in-window-p pntA))
    (cond (v0
	   (save-excursion
	     (goto-char pntA)
	     (unless *executing-macro* (sit-for .5))))
	  (*html+-show-no-jump*
	   (save-excursion
	     (goto-char pntA)
	     (let ((bol (progn (goto-virtual-bol) (point)))
		   (eol (progn (goto-virtual-eol) (point))))
	       (setq eol (min eol (+ bol 100)))
	       (message "~D: ~A"
			(current-line-number)
			(buffer-substring bol eol)))))
	  (*html+-show-split-window*
	   (save-window-excursion
	     (split-window *html+-show-split-window-lines*)
	     (goto-char pntA)
	     (recenter)
	     (when pntZ
	       (setq v1  (not (pos-visible-in-window-p pntZ)))
	       (other-window)
	       (setq v2  (not (pos-visible-in-window-p pntZ)))
	       (when (and v1 v2)
		 (split-window *html+-show-split-window-lines*)
		 (goto-char pntZ)
		 (recenter)
		 (other-window)))
	     (unless *executing-macro* (sit-for -1))
	     t))
	  (t
	   (save-excursion
	     (goto-char pntA)
	     (unless *executing-macro* (sit-for .5))
	     (let ((bol (progn (goto-virtual-bol) (point)))
		   (eol (progn (goto-virtual-eol) (point))))
	       (setq eol (min eol (+ bol 100)))
	       (message "~D: ~A"
			(current-line-number)
			(buffer-substring bol eol)))))))
  t)

; -------------------------------
; パスを修正
; Sat, 26 May 2001 23:59:26 +0900
; ※パス記述そのものがなければバッファのパスを使用
; ※パスが存在すれば、絶対のパスを取得
; ※パスが存在しなければ、それは多分URLなのでそのまま使用
(defun adjust-truename (path)
  (cond
   ((not path)
    (setq path (get-buffer-file-name)))
   ((file-exist-p path)
    (setq path (truename path)))
   (t
    path)))

; -------------------------------
; パスの調整
; Mon, 17 Jan 2000 21:31:46 +0900
(defun adjust-path (f)
  (let ((fl (split-string f "/:"))
	(dl (split-string (default-directory) "/:")))
    (when (string= (car fl) (car dl))
      (while (and dl (string= (car fl) (car dl))) (pop fl) (pop dl))
      (while dl (push ".." fl) (pop dl))
      (setq f (string-right-trim "/" (format nil "~{~A/~}" fl))))
    f))

; -------------------------------
; URLの調整
; 【Sat, 16 Dec 2000 11:56:40 +0900】
(defun adjust-url (u &optional (n nil) (q nil))
  (let (url)
    (setq url (concat (cond ((string-match "^//" u) "file:")
			    ((string-match "^\\w[:|]" u) "file:///"))
		      u (if n "#") n (if q "?") q))
    (or (run-hook-with-args-until-success '*html+-adjust-url-hook* url)
	url)))
; ファイル名だけだと何故かIEが確実にreloadされる気配なので、
; 回避するために必ず#を付けるようにする場合
;(defun adjust-url (u &optional (n nil) (q nil))
;  (concat (if (string-match "^//" u) "file:")
;	  u (if (or n (not q)) "#") n (if q "?") q))

