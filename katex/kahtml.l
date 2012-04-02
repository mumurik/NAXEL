;;; -*- Lisp; syntax: Common-Lisp -*-
;;; kahtml.l, v 1.67.1.11
;;; fixed by Maeda Manabu
;;; Last fixed  "Sat Sep 04 2004 21:33:45 +0900"

;;; -*- Emacs-Lisp -*-
;;; (c ) 1994-1999 by HIROSE Yuuji [yuuji@gentei.org]
;;; Last modified Wed Jul 14 18:01:18 1999 on firestorm
;;; $Old-Id: yahtml.el,v 1.67 1999/07/15 04:58:48 yuuji Rel $

;;;[Installation]
;;; 
;;; First, you have to install KaTeX and make sure it works fine.  Then
;;; put these expressions into your ~/.xyzzy
;;; 
;;; 	(setq *auto-mode-alist*
;;; 		(cons (cons "\\.html$" 'kahtml-mode) *auto-mode-alist*))
;;; 	(autoload 'kahtml-mode "kahtml" "Yet Another HTML mode" t)
;;; 	(setq kahtml-www-browser "netscape")
;;;      ;Write your favorite browser.  But netscape is advantageous.
;;; 	(setq kahtml-path-url-alist
;;; 	      '(("/home/yuuji/public_html" . "http://www.mynet/~yuuji")
;;; 		("/home/staff/yuuji/html" . "http://www.othernet/~yuuji")))
;;;      ;Write correspondence alist from ABSOLUTE unix path name to URL path.
;;; 
;;;[インストール方法]
;;;
;;; kahtml.l, katexlib.l, katexprc.l を load-path の通ったディレクト
;;; リにインストールしてください。その後、以下を参考に ~/.xyzzy に設定を
;;; 追加して下さい。
;;;
;;; 	(setq *auto-mode-alist*
;;; 		(cons (cons "\\.html$" 'kahtml-mode) *auto-mode-alist*))
;;; 	(autoload 'kahtml-mode "kahtml" "Yet Another HTML mode" t)
;;; 	(setq kahtml-www-browser "netscape")
;;;      ;お気に入りのブラウザを書いて下さい。netscapeが便利です。
;;; 	(setq kahtml-path-url-alist
;;; 	      '(("/home/yuuji/public_html" . "http://www.mynet/~yuuji")
;;; 		("/home/staff/yuuji/html" . "http://www.othernet/~yuuji")))
;;;      ;UNIXの絶対パスと対応するURLのリストを書いて下さい。
;;; 
;;;[Commentary]
;;;
;;; It is assumed you are already familiar with KaTeX.  The following
;;; completing featureas are available: ([prefix] means `C-c' by default)
;;;
;;;  * [prefix] b X	Complete environments such as `H1' which
;;;			normally requires closing tag `</H1>
;;;			<a href=foo> ... </a> is also classified into
;;;			this group
;;;			When input `href=...', you can complete file
;;;			name or label(href="#foo") by typing TAB.
;;;  * [prefix] l	Complete typeface-changing commands such as
;;;			`<i> ... </i>' or `<samp> ... </samp>'
;;; 			This completion can be used to make in-line
;;; 			tags which is normally completed with [prefix] b.
;;;  * [prefix] s	Complete declarative notations such as
;;;			`<img src="foo.gif">'
;;;			`<input name="var" ...>'
;;;  * [prefix] m	Complete single commands such as
;;;			`<br>' or `<hr> or <li>...'
;;;  * [prefix] p	Insert <p></p> on the point
;;;  * M-RET		Intelligent newline; if current TAG is one of
;;;			ul, ol, or  dl. insert newline and <li> or
;;;			<dt> or <dd> suitable for current condition.
;;;  * menu-bar kahtml	Complete all by selecting a menu item (Though I
;;;			hate menu, this is most useful)
;;;  * [prefix] g	Goto corresponding Tag or HREF such as
;;; 			<dl> <-> </dl>  or href="xxx".
;;;			Or invoke image viewer if point is on <img src=...>.
;;;  * [prefix] k	Kill html tags on the point.  If you provide
;;; 			universal-argument, kill surrounded contents too.
;;;  * [prefix] c	Change html tags on the point.
;;;			When typeing [prefix] c on `href="xxx"', you can 
;;;			change the reference link with completion.
;;;  * [prefix] t j	Call weblint on current file.
;;;  * [prefix] t p	View current html with WWW browser
;;; 			(To activate this, never fail to set the lisp
;;; 			 variable kahtml-www-browser.  Recommended value
;;; 			 is "netscape")
;;;  * [prefix] a	KaTeX's accent mark's equivalent of kahtml.
;;;			This function can input $lt, $gt or so.
;;;  * [prefix] ;	Translate chars of `>', `<', `&', and `"' to 
;;;			`&gt;', `&lt;', `&amp;', `&quot;' respectively
;;;			in the region.
;;;  * [prefix] :	Do translation opposite to above, in the region.
;;;  * [prefix] #	Translate unsafe-chars and unreserved-chars to
;;;			URLencoded string in the region.
;;; 
;;;[キーの説明]
;;; 
;;; 以下の説明において、特にカスタマイズをしていない限り、[prefix] は
;;; C-c キーを意味します。
;;;
;;;  * [prefix] b X	`</H1>' といった終了タグが必要となる`H1'のよう
;;;			な環境を補完入力します。<a href=foo> ... </a>
;;;			もこのグループです。
;;;			`href=...' と入力した後、TABキーを押すことで、
;;;			ファイル名や (href="#foo") のようなラベルも補完
;;;			できます。
;;;  * [prefix] s	以下のような宣言の補完を行います。
;;;			`<img src="foo.gif">'
;;;			`<input name="var" ...>'
;;;  * [prefix] l	`<i> ... </i>' や `<samp> ... </samp>' のよう
;;;			なテキストスタイル指定のタグを補完します。
;;;			この補完機能は通常 [prefix] b で補完できるものを
;;;			一行内で書きたいときにも用いることが出来ます。
;;;  * [prefix] m	`<br>' や `<hr> '、`<li>' 等の単体タグの補完
;;;			を行います。
;;;  * [prefix] p	カーソル位置に<p></p>を挿入します。
;;;  * M-RET		おまかせ改行; もしul、ol、dl等のタグ(リスト)を
;;;			使っている場合に、環境に合わせて改行と <li>、
;;;			<dt>、<dd>を入力します。
;;;  * menu-bar kahtml	選択したアイテムをメニューより補完できます。
;;;			(私はメニューが嫌いなんですが、htmlに関してはメ
;;;			ニューは一番ありがたいかも)
;;;  * [prefix] g	対応するタグ、<dl> <-> </dl> や href="xxx" の
;;;			ような TAG にジャンプします。
;;;			<img src=...> の場合はイメージビューワを呼び出
;;;			します。href=hoge.html の場合はhoge.htmlに飛びま
;;;			す。
;;;  * [prefix] k	ポイント上の HTML タグを消去します。
;;;			もし universal-argument を付けた場合(C-uを先に押
;;;			す)HTMLタグで囲まれた内容も同時に消去します。
;;;  * [prefix] c	ポイント上のタグを変更します。
;;;			`href="xxx"'の上で [prefix] c を利用した場合は、
;;;			参照しているリンクを補完機能を使いながら変更で
;;;			きます。
;;;  * [prefix] t j	カレントファイルに対して jweblint を呼び出しま
;;;			す。
;;;  * [prefix] t p	WWW ブラウザでカレントファイルを表示します。
;;;			(lisp変数 kahtml-www-browser の設定をお忘れな
;;;			く。お推めは "netscape" で、ねすけの場合既にねす
;;;			けが起動されていた場合そのねすけに Reload 命令を
;;;			送るという芸当が出来ます)
;;;  * [prefix] a	KaTeX のアクセント記号補完と同じです。
;;;			&lt; &gt; 等が入力できます。
;;;  * [prefix] ;	指定したリジョン中の > < & " をそれぞれ
;;;			&gt; &lt; &amp; &quot; に変換します。
;;;  * [prefix] :	指定したリジョン中で上と逆の変換をします。
;;;  * [prefix] #	指定したリジョン中で%エンコードの必要な文字が
;;;			あればそれらをエンコードします。
;;; 
;;; [謝辞]
;;; 
;;; fj野鳥の会の皆さんには貴重な助言を頂きました。また、下に示す方々には
;;; 特に大きな協力を頂きました。あわせてここに感謝申し上げます。
;;; 
;;;	* 横田和也さん(マツダ)
;;;		マニュアルの和訳をして頂きました。
;;;	* 吉田尚志さん(NTT Data)
;;;		Mule for Win32 での動作のさせ方を教えて頂きました。
;;;		(というかほとんどやってもらった ^^;)
;;; 

(provide "kahtml")

(in-package "elisp")

(require "emacs")
(require "katex")
(require "katexlib")

(require "html-kwd") ;htmlmode.l ;m.m

;;; --- customizable variable starts here ---
(defvar *kahtml-prefix* #\C-c
  "*Prefix key stroke of kahtml functions.")
(defvar kahtml-image-viewer "gv" "*Image viewer program")
(defvar kahtml-www-browser "browserex"
  "*WWW Browser command")

(defvar kahtml-browserex-posiotion nil) ;m.m
(defvar kahtml-browserex-size nil)      ;m.m

(defvar kahtml-kanji-code 2
  "*Kanji coding system number of html file; 1=sjis, 2=jis, 3=euc")

(defvar kahtml-fill-column 72 "*fill culumn used for kahtml-mode")
(defvar kahtml-fill-prefix nil "*fill prefix for kahtml-mode")

;;(defvar kahtml-www-server "www" "*Host name of your domain's WWW server")
(defvar kahtml-path-url-alist nil
  "*Alist of unix path name vs. URL name of WWW server.
Ex.
'((\"c:/usr/home/yuuji/http\" . \"http://www.comp.ae.keio.ac.jp/~yuuji\")
  (\"c:/usr/home/yuuji/darts/http\" . \"http://darts.comp.ae.keio.ac.jp/~darts\"))")
(defvar kahtml-directory-index "index.html"
  "*Directory index file name;
Consult your site's WWW administrator.")

(defvar kahtml-environment-indent 1
  "*Indentation depth of HTML's listing environment")

(defvar KaTeX-japan t
  "Whether katex mode is running on Japanese environment or not.")

(defvar kahtml-lint-program (if KaTeX-japan "jweblint" "weblint")
  "*Program name to lint HTML file")
(defvar kahtml-hate-too-deep-indentation nil
  "*Non-nil for this variable suppress deep indentation in listing environments.")

(defvar kahtml-always-/p nil
  "*Those who always use <p> with </p> set this to t.")

(defvar kahtml-p-prefered-env-regexp "^\\(body\\|dl\\)"
  "*Regexp of envs where paragraphed sentences are prefered.")

(defvar kahtml-template-file "~/http/template.html"
  "*Template HTML file.  It'll be inserted to empty file.")

(defvar kahtml-prefer-upcases nil
  "*Non-nil for preferring upcase TAGs")

(defvar kahtml-prefer-upcase-attributes nil
  "*Non-nil for preferring upcase attributes")

(defvar kahtml-server-type 'apache
  "*WWW server program type")

(defvar kahtml-apache-access-file ".htaccess"
  "*Server access file name for apache")

(defvar kahtml-use-css t "*Use stylesheet or not")

;;; --- customizable variable ends here ---
(defvar *kahtml-prefix-map* nil)
(defvar *kahtml-mode-map* nil "Keymap used in kahtml-mode.")
(defvar *kahtml-lint-buffer-map* nil "Keymap used in lint buffer.")
(defvar kahtml-shell-command-option
  (or (and (boundp 'shell-command-option) shell-command-option)
      (if (eq system-type 'ms-dos) "/c" "-c")))


(defun kahtml-define-begend-key-normal (key env &optional map)
  "Define short cut kahtml-insert-begend key."
  (KaTeX-define-key
   key
   (list 'lambda '(arg) '(interactive "P")
	 (list 'kahtml-insert-begend 'arg env))
   map))

(defun kahtml-define-begend-region-key (key env &optional map)
  "Define short cut kahtml-insert-begend-region key."
  (KaTeX-define-key key (list 'lambda nil '(interactive)
			      (list 'kahtml-insert-begend t env)) map))

(defun kahtml-define-begend-key (key env &optional map)
  "Define short cut key for begin type completion both for
normal and region mode.  To customize kahtml, user should use this function."
  (kahtml-define-begend-key-normal key env map)
  (if KaTeX-inhibit-prefix-letter nil
    (kahtml-define-begend-region-key
      (cons (char-upcase (car key)) (cdr key)) env map)))
;m.m (concat (upcase (substring key 0 1)) (substring key 1))

(if *kahtml-mode-map* nil
  (progn
    (setq *kahtml-mode-map* (make-sparse-keymap)
	*kahtml-prefix-map* (make-sparse-keymap))
    (define-key *kahtml-mode-map* *kahtml-prefix* *kahtml-prefix-map*)
    (define-key *kahtml-mode-map* #\M-\C-@ 'kahtml-mark-begend)
;    (define-key *kahtml-mode-map* #\M-\C-\SPC 'kahtml-mark-begend)
    (define-key *kahtml-mode-map* #\M-\C-a 'KaTeX-beginning-of-environment)
    (define-key *kahtml-mode-map* #\M-\C-e 'KaTeX-end-of-environment)
    (define-key *kahtml-mode-map* #\M-\C-m 'kahtml-intelligent-newline)
    (define-key *kahtml-mode-map* #\C-i 'kahtml-indent-line)
    (let ((map *kahtml-prefix-map*))
      (KaTeX-define-key #\^ 'kahtml-visit-main map)
      (KaTeX-define-key '(#\4 #\^) 'kahtml-visit-main-other-window map)
      (KaTeX-define-key '(#\4 #\g) 'kahtml-goto-corresponding-*-other-window map)
;m.m      (KaTeX-define-key '(#\4 #\4) 'KaTeX-switch-to-window map)
;      (and KaTeX-emacs-19 window-system
;	   (progn
;	     (KaTeX-define-key '(#\5 #\^) 'kahtml-visit-main-other-frame map)
;		 (KaTeX-define-key '(#\5 #\g) 'kahtml-goto-corresponding-*-other-frame map)))
;m.m	     (KaTeX-define-key '(#\5 #\5) 'KaTeX-switch-to-window map)
      (KaTeX-define-key #\v 'KaTeX-version map)
      (KaTeX-define-key #\} 'KaTeX-insert-braces-region map)
      (KaTeX-define-key #\] 'KaTeX-insert-brackets-region map)
      (KaTeX-define-key #\) 'KaTeX-insert-parens-region map)
      (KaTeX-define-key #\s 'kahtml-insert-form map)
      (KaTeX-define-key #\l 'kahtml-insert-tag map)
      (KaTeX-define-key #\L 'kahtml-insert-tag-region map)
      (KaTeX-define-key #\m 'kahtml-insert-single map)
      (KaTeX-define-key #\n '(lambda () (interactive) (insert (if kahtml-prefer-upcases "<BR>" "<br>"))) map)
      (KaTeX-define-key #\- '(lambda () (interactive) (insert (if kahtml-prefer-upcases "<HR>" "<hr>") "\n")) map)
      (KaTeX-define-key #\p 'kahtml-insert-p map)
      (if KaTeX-no-begend-shortcut
	  (progn
	    (KaTeX-define-key #\B 'kahtml-insert-begend-region map)
	    (KaTeX-define-key #\b 'kahtml-insert-begend map))
        (progn
	  (kahtml-define-begend-key '(#\b #\h) "html" map)
          (kahtml-define-begend-key '(#\b #\H) "head" map)
          (kahtml-define-begend-key '(#\b #\t) "title" map)
          (kahtml-define-begend-key '(#\b #\T) "table" map)
          (kahtml-define-begend-key '(#\b #\b) "body" map)
          (kahtml-define-begend-key '(#\b #\c) "center" map)
          (kahtml-define-begend-key '(#\b #\d) "dl" map)
          (kahtml-define-begend-key '(#\b #\u) "ul" map)
          (kahtml-define-begend-key '(#\b #\1) "h1" map)
          (kahtml-define-begend-key '(#\b #\2) "h2" map)
          (kahtml-define-begend-key '(#\b #\3) "h3" map)
          (kahtml-define-begend-key '(#\b #\a) "a" map)
          (kahtml-define-begend-key '(#\b #\f) "form" map)
          (kahtml-define-begend-key '(#\b #\s) "select" map)
          (KaTeX-define-key '(#\b #\SPC) 'kahtml-insert-begend map)
          (KaTeX-define-key '(#\B #\SPC) 'kahtml-insert-begend-region map)
	))
      (KaTeX-define-key #\e 'KaTeX-end-environment map)
      (KaTeX-define-key #\> 'kahtml-comment-region map)
      (KaTeX-define-key #\< 'kahtml-uncomment-region map)
      (KaTeX-define-key #\g 'kahtml-goto-corresponding-* map)
      (KaTeX-define-key #\k 'kahtml-kill-* map)
      (KaTeX-define-key #\c 'kahtml-change-* map)
      (KaTeX-define-key #\t 'kahtml-browse-menu map)
      (KaTeX-define-key #\a 'kahtml-complete-mark map)
      (KaTeX-define-key #\' 'kahtml-prev-error map)
      (KaTeX-define-key #\; 'kahtml-translate-region map)
      (KaTeX-define-key #\: 'kahtml-translate-reverse-region map)
      (KaTeX-define-key #\# 'kahtml-escape-chars-region map)
      ;;;;;(KaTeX-define-key #\i 'kahtml-fill-item map)
	)))

(if *kahtml-lint-buffer-map* nil
  (progn
    (setq *kahtml-lint-buffer-map* (make-keymap))
    (define-key *kahtml-lint-buffer-map* #\SPC 'kahtml-jump-to-error-line)))


(defvar kahtml-paragraph-start
  (concat
   "^$\\|<!--\\|^[ \t]*</?\\(h[1-6]\\|p\\|d[ldt]\\|[bhtd][rdh]\\|li\\|body\\|html\\|head\\|title\\|ul\\|ol\\|dl\\|pre\\|table\\|center\\|blockquote\\)\\b")
  "*Regexp of html paragraph separater")
(defvar kahtml-paragraph-separate
  (concat
   "^$\\|<!--\\|^[ \t]*</?\\(h[1-6]\\|p\\|[bhtd][ldt]\\|li\\|body\\|html\\|head\\|title\\|ul\\|ol\\|dl\\|pre\\|table\\|center\\|blockquote\\|!--\\)\\b")
  "*Regexp of html paragraph separater")

(defvar *kahtml-syntax-table* nil
  "*Syntax table for kahtml-mode")

(unless *kahtml-syntax-table*
  (setq *kahtml-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alphanumericp c)
	(set-syntax-punctuation *kahtml-syntax-table* c))))
  (set-syntax-symbol-prefix *kahtml-syntax-table* #\&)
  (set-syntax-symbol *kahtml-syntax-table* #\-)
  (set-syntax-symbol *kahtml-syntax-table* #\:)
  (set-syntax-string *kahtml-syntax-table* #\")
  (set-syntax-tag *kahtml-syntax-table* #\< #\>)
  (set-syntax-symbol *kahtml-syntax-table* #\/))
#| ;m.m
(if kahtml-syntax-table nil
  (progn
    (setq kahtml-syntax-table (standard-syntax-table))
    (modify-syntax-entry #\< "(>" kahtml-syntax-table)
    (modify-syntax-entry #\> ")<" kahtml-syntax-table)
    (modify-syntax-entry #\n " " kahtml-syntax-table)))
|#
(defvar kahtml-command-regexp "[A-Za-z0-9]+"
  "Regexp of constituent of html commands.")

;;; Completion tables for `form'
(defvar kahtml-form-table
  '(("img") ("input") ("link") ("meta")))
(defvar kahtml-user-form-table nil)
(defvar kahtml-tmp-form-table nil)
(defvar kahtml-last-form "img")

(defvar kahtml-env-table
  '(("html") ("head") ("title") ("body") ("dl") ("ul") ("ol") ("pre")
    ("a") ("form") ("select") ("center") ("textarea") ("blockquote")
    ("OrderedList" . "ol")
    ("UnorderedList" . "ul")
    ("DefinitionList" . "dl")
    ("Preformatted" . "pre")
    ("table") ("thead") ("tbody") ("tfoot") ("caption") ("tr") ("th") ("td")
    ("address") 
    ("h1") ("h2") ("h3") ("h4") ("h5") ("h6")
    ;; ("p") ;This makes indentation screwed up!
    ("style") ("div")
    ))

;(defvar kahtml-itemizing-regexp
;  "\\(ul\\|ol\\|dl\\)"
;  "Regexp of itemizing forms")

(defvar kahtml-user-env-table nil)
(defvar kahtml-tmp-env-table nil)

;;; Completion tables for typeface designator
(and kahtml-always-/p
     (or (assoc "p" kahtml-env-table)
	 (setq kahtml-env-table (cons '("p") kahtml-env-table))))

(defvar kahtml-typeface-table
  (append
   '(("dfn") ("em") ("cite") ("code") ("kbd") ("samp") ("strike")
     ("strong") ("var") ("b") ("i") ("tt") ("u") ("big") ("small") ("font")
     ("sup") ("sub") ("span"))
   kahtml-env-table)
  "Default completion table of typeface designator")
(defvar kahtml-user-typeface-table nil)
(defvar kahtml-tmp-typeface-table nil)
(defvar kahtml-last-typeface-cmd "a")

(defvar kahtml-single-cmd-table
  '(("hr") ("br") ("option") ("p")
    ("HorizontalLine" . "hr")
    ("BreakLine" . "br")
    ("Paragraph" . "p")
    ("Item" . "li")
    ("DefineTerm" . "dt")
    ("Description" . "dd")
    ("dd") ("dt") ("li")
    )
  "Default completion table of HTML single command.")
(defvar kahtml-user-single-cmd-table nil)
(defvar kahtml-tmp-single-cmd-table nil)
(defvar kahtml-last-single-cmd nil)

;(defvar kahtml-struct-name-regexp
;  "\\<\\(h[1-6]\\|[uod]l\\|html\\|body\\|title\\|head\\|table\\|t[rhd]\\|pre\\|a\\|form\\|select\\|center\\|blockquote\\)\\b")
(defvar kahtml-struct-name-regexp
  (concat
   "\\<\\("
   (mapconcat (function (lambda (x) (car x))) kahtml-typeface-table "\\|")
   "\\)\\b")
  "Regexp of structure beginning.")
(or (assoc "p" kahtml-env-table)
    (setq kahtml-env-table (cons '("p") kahtml-env-table)))

(defun kahtml-dir-default-charset ()
  (cond
   ((and (eq kahtml-server-type 'apache) ;;check .htaccess
	 (get-buffer-file-name))
    (let ((dir default-directory)
	  charset af ext (ldir "")
	  (case-fold-search t)
	  (uid (car (cdr (cdr (file-attributes "."))))))
      (setq ext (file-name-nondirectory (get-buffer-file-name))
	    ext (substring ext (string-match "\\.[a-z0-9]+$" ext)))
;      (if (string-match "^[A-Z]:" dir) ;m.m
;	  (setq dir (substring dir 2)))	;remove drive letter
      (while (and dir
		  (not (string= dir ldir))
		  (equal uid (car (cdr (cdr (file-attributes dir))))))
	(setq af (expand-file-name kahtml-apache-access-file dir))
	(if (file-exists-p af)
	    (save-excursion
	      (set-buffer (find-file-noselect af))
	      (save-excursion
		(goto-char (point-min))
		(if (re-search-forward  ;search the charset for same extension
		     (format nil "^\\s *AddType.*charset=\\(.*\\)\\~A$" ext)
		     nil t)
		    (progn
		      (setq charset
			    (buffer-substring
			     (match-beginning 1) (match-end 1)))
		      (cond
		       ((string-match "iso-2022-jp" charset)
			(setq charset 2))
		       ((string-match "euc-jp" charset)
			(setq charset 3))
		       ((string-match "shift_jis" charset)
			(setq charset 1))
		       (t (setq charset nil)))
		      (setq dir ""))))
	      (kill-buffer (current-buffer))))
	(setq ldir dir
	      dir (substring dir 0 (string-match "/$" dir))
	      dir (file-name-directory dir)))
      (if (featurep 'mule)
	  (setq charset (cdr (assq charset KaTeX-kanji-code-alist))))
      charset
      ))
   (t nil))
  )

;-> htmlmode.l ;m.m
(defvar *kahtml-comment-column* 0)
(defvar *kahtml-mode-abbrev-table* nil)
(unless *kahtml-mode-abbrev-table*
  (define-abbrev-table '*kahtml-mode-abbrev-table*))

(defun kahtml-comment-indent ()
  (save-excursion
    (cond ((looking-for "<!--")
	   (current-column))
	  (t
	   (goto-eol)
	   (skip-chars-backward " \t")
	   (if (bolp)
	       0
	     (max (current-column) comment-column))))))
;<-

(defun kahtml-mode ()
  (interactive)
  (let ((coding (or (kahtml-dir-default-charset) kahtml-kanji-code)))
    (cond
     ((and KaTeX-emacs-20 (boundp 'buffer-file-coding-system))
      (setq buffer-file-coding-system coding))
     ((featurep 'mule)
      (set-file-coding-system coding))
     ((boundp 'NEMACS)
      (make-local-variable 'kanji-fileio-code)
      (setq kanji-fileio-code coding)))
    (setq buffer-mode 'kahtml-mode
	  mode-name "kahtml")
    (mapcar
     (function (lambda (x)
		 (make-local-variable (car x))
		 (set (car x) (if (and (symbolp (cdr x))
				       (boundp (cdr x)))
				  (symbol-value (cdr x))
				(cdr x)))))
     '((KaTeX-ec . "")
       (KaTeX-struct-begin . "<%1%2")
       (KaTeX-struct-end . "</%1>")
       (KaTeX-struct-name-regexp . kahtml-struct-name-regexp)
       (KaTeX-comment-prefix . "<!--")
       (KaTeX-coding-system . kahtml-kanji-code) ;necessary?
       (KaTeX-typesetting-mode-map . *kahtml-lint-buffer-map*)
       (fill-prefix . kahtml-fill-prefix) (fill-column . kahtml-fill-column)
       (paragraph-start . kahtml-paragraph-start)
       (paragraph-separate . kahtml-paragraph-separate)
       (comment-start . "<!-- ") (comment-end . " -->")
       (comment-start-skip . "<!--[ \t]*") ;m.m
       (comment-indent-function . 'html-comment-indent) ;m.m
       (indent-line-function . kahtml-indent-line)))
    ;-> htmlmode.l ;m.m
    (when *kahtml-comment-column*
      (setq comment-column *kahtml-comment-column*))
    (make-local-variable 'highlight-keyword)
    (setq highlight-keyword t)
    (html-load-keyword-file nil)
    ;<-
    (set-syntax-table *kahtml-syntax-table*)
    (use-local-map *kahtml-mode-map*)
    (KaTeX-read-user-completion-table)
    (kahtml-css-scan-styles)
    (turn-on-auto-fill)			;Sorry, this is prerequisite
    (and (= 0 (buffer-size)) (file-exists-p kahtml-template-file)
	 (y-or-n-p (format nil "Insert ~A?" kahtml-template-file))
	 (insert-file-contents (expand-file-name kahtml-template-file)))
    (run-hooks 'text-mode-hook 'kahtml-mode-hook)))

(defun kahtml-define-menu (keymap bindlist)
  (cond
   ((featurep 'xemacs)
    (let ((name (keymap-name (symbol-value keymap))))
      (set keymap nil)
      (mapcar
       (function
	(lambda (bind)
	  (setq bind (cdr bind))
	   (if (eq (car (cdr bind)) 'lambda)
	       (setcar (cdr bind) 'progn))
	   (if (stringp (car (cdr bind)))
	       (set keymap (cons (cdr bind) (symbol-value keymap)))
	     (set keymap (cons (vector (car bind) (cdr bind) t)
			       (symbol-value keymap))))))
       bindlist)
      (set keymap (cons name (symbol-value keymap)))))
   (t
    (mapcar
     (function
      (lambda (bind)
	(define-key (symbol-value keymap) (vector (car bind)) (cdr bind))))
     bindlist))))

(defvar kahtml-menu-map nil "Menu map of kahtml")
(defvar kahtml-menu-map-sectioning nil "Menu map of kahtml(sectioning)")
(defvar kahtml-menu-map-listing nil "Menu map of kahtml(listing)")
(defvar kahtml-menu-map-logical nil "Menu map of kahtml(logical tags)")
(defvar kahtml-menu-map-typeface nil "Menu map of kahtml(typeface tags)")

;;; Variables for mosaic url history
(defvar kahtml-urls nil "Alist of global history")
(defvar kahtml-urls-private nil)
(defvar kahtml-urls-local nil)
#| <- ;m.m
(setq kahtml-menu-map (make-sparse-keymap "kahtml"))
(setq kahtml-menu-map-sectioning (make-sparse-keymap "sectioning menu"))
(KaTeX-define-menu
 'kahtml-menu-map-sectioning
 (nreverse
  '((1 "H1" . (lambda () (interactive) (kahtml-insert-begend nil "H1")))
    (2 "H2" . (lambda () (interactive) (kahtml-insert-begend nil "H2")))
    (3 "H3" . (lambda () (interactive) (kahtml-insert-begend nil "H3")))
    (4 "H4" . (lambda () (interactive) (kahtml-insert-begend nil "H4")))
    (5 "H5" . (lambda () (interactive) (kahtml-insert-begend nil "H5")))
    (6 "H6" . (lambda () (interactive) (kahtml-insert-begend nil "H6")))
   )))
(setq kahtml-menu-map-logical (make-sparse-keymap "logical tags"))
(KaTeX-define-menu
 'kahtml-menu-map-logical
 (nreverse
  '((em	"Embolden" .
	(lambda () (interactive) (kahtml-insert-tag nil "EM")))
    (dfn	"Define a word" .
		(lambda () (interactive) (kahtml-insert-tag nil "DFN")))
    (cite	"Citation" .
		(lambda () (interactive) (kahtml-insert-tag nil "CITE")))
    (code	"Code" .
		(lambda () (interactive) (kahtml-insert-tag nil "CODE")))
    (kbd	"Keyboard" .
		(lambda () (interactive) (kahtml-insert-tag nil "KBD")))
    (samp	"Sample display" .
		(lambda () (interactive) (kahtml-insert-tag nil "SAMP")))
    (strong	"Strong" .
		(lambda () (interactive) (kahtml-insert-tag nil "STRONG")))
    (VAR	"Variable notation" .
		(lambda () (interactive) (kahtml-insert-tag nil "VAR")))
   )))
(setq kahtml-menu-map-typeface (make-sparse-keymap "typeface tags"))
(KaTeX-define-menu
 'kahtml-menu-map-typeface
 (nreverse
  '((b	"Bold" .
	(lambda () (interactive) (kahtml-insert-tag nil "B")))
    (i	"Italic" .
	(lambda () (interactive) (kahtml-insert-tag nil "I")))
    (tt	"Typewriter" .
	(lambda () (interactive) (kahtml-insert-tag nil "TT")))
    (u	"Underlined" .
	(lambda () (interactive) (kahtml-insert-tag nil  "U")))
   )))
(setq kahtml-menu-map-listing (make-sparse-keymap "listing"))
(KaTeX-define-menu
 'kahtml-menu-map-listing
 (nreverse
  '((ul	"Unordered" .
	(lambda () (interactive) (kahtml-insert-begend nil "UL")))
    (ol	"Ordered" .
	(lambda () (interactive) (kahtml-insert-begend nil "OL")))
    (dl	"Definition" .
	(lambda () (interactive) (kahtml-insert-begend nil "DL")))
   )))
(setq kahtml-menu-map-item (make-sparse-keymap "item"))
(KaTeX-define-menu
 'kahtml-menu-map-item
 (nreverse
  '((li	"Simple item" .
	(lambda () (interactive) (kahtml-insert-single "li")))
    (dt	"Define term" .
	(lambda () (interactive) (kahtml-insert-single "dt")))
    (dd	"Description of term" .
	(lambda () (interactive) (kahtml-insert-single "dd")))
   )))
(define-key *kahtml-mode-map* [menu-bar kahtml]
	    (cons "kahtml" kahtml-menu-map))
(let ((keys (where-is-internal 'fill-paragraph *global-keymap*)))
  (while keys
    (define-key *kahtml-mode-map* (car keys) 'kahtml-fill-paragraph)
    (setq keys (cdr keys))))
(KaTeX-define-menu
 'kahtml-menu-map
 (nreverse
  (list
   (cons (list 'sect "Sectioning")
	 (cons "sectioning" kahtml-menu-map-sectioning))
   (cons (list 'list "Listing")
	 (cons "Listing" kahtml-menu-map-listing))
   (cons (list 'item "Item")
	 (cons "Itemizing" kahtml-menu-map-item));;;
   (cons (list 'logi "Logical tags")
	 (cons "logical" kahtml-menu-map-logical))
   (cons (list 'type "Typeface tags")
	 (cons "typeface" kahtml-menu-map-typeface))
  )))
|# ;<- ;m.m
;;; ----------- Completion ----------
(defvar kahtml-last-begend "html")
(defun kahtml-insert-begend (&optional region env)
  "Insert <cmd> ... </cmd>."
  (interactive "P")
  (let*((completion-ignore-case t)
	(cmd
	 (or env
	     (KaTeX-cplread-with-learning
	      (format nil "Environment(default ~A): " kahtml-last-begend)
	      'kahtml-env-table 'kahtml-user-env-table 'kahtml-tmp-env-table)))
	(bolp (save-excursion
		(skip-chars-backward " \t" (point-beginning-of-line)) (bolp)))
	(cc (current-column)))
    (if (string< "" cmd) (setq kahtml-last-begend cmd))
    (setq kahtml-last-begend
	  (or (cdr (assoc kahtml-last-begend kahtml-env-table))
	      kahtml-last-begend))
    (setq cmd kahtml-last-begend)
    (if kahtml-prefer-upcases (setq cmd (upcase cmd)))
    (if region
	;; We want to keep region effective for new tagged environment
	;; to enable continuous regioning by another environment
	(let ((beg (region-beginning))
	      (end (region-end))
	      (addin (kahtml-addin cmd)))
	  (save-excursion
	    (goto-char end)
	    (insert-before-markers (format nil "</~A>~A" cmd (if bolp "\n" "")))
	    (goto-char beg)
	    (insert (format nil "<~A~A>~A" cmd addin (if bolp "\n" "")))))
      (progn
	(insert (format nil "<~A~A>" cmd (kahtml-addin cmd)))
        (save-excursion
	  (insert "\n")
	  (indent-to-column cc)
	  (insert (format nil "</~A>" cmd)))
        (if (string-match "^a\\|p$" cmd)	;aとp決め打ちってのが美しくない…
	  (newline)
	  (kahtml-intelligent-newline nil))
	(kahtml-indent-line)))))

(defun kahtml-insert-begend-region ()
  "Call kahtml-insert-begend in the region mode."
  (interactive)
  (kahtml-insert-begend t))


(defun kahtml-insert-form (&optional form)
  "Insert <FORM option=\"argument\">."
   (interactive)
   (or form
       (let ((completion-ignore-case t))
	 (setq form
	       (KaTeX-cplread-with-learning
		(format nil "Form(default ~A): " kahtml-last-form)
		'kahtml-form-table 'kahtml-user-form-table
		'kahtml-tmp-form-table))))
   (let ((p (point)) q)
     (if (string= form "") (setq form kahtml-last-form))
     (setq kahtml-last-form form)
     (if kahtml-prefer-upcases (setq form (upcase form)))
     (insert (format nil "<~A~A>" form (kahtml-addin form)))
     ;;(indent-relative-maybe)
     (if (cdr (assoc form kahtml-form-table))
	 (save-excursion (insert (format nil "</~A>" form))))
     (if (search-backward "\"\"" p t) (forward-char 1))))

;;; ---------- Add-in ----------
(defun kahtml-addin (form)
  "Check add-in function's existence and call it if exists."
   (let ((addin (concat "kahtml-" (downcase form))) s a)
     (concat
      (if (setq a (assoc form kahtml-css-class-alist))
	  (kahtml-make-optional-argument ;should be made generic?
	   "class" (completing-read "class: " (cdr a))))
      (if (and (intern-soft addin) (fboundp (intern-soft addin))
	       (stringp (setq s (funcall (intern addin))))
	       (string< "" s))
	  (if (eq (aref s 0) #\SPC) s (concat " " s))
	""))))


(defvar kahtml-completing-buffer nil)
(defun kahtml-collect-labels (&optional file)
  "Collect current buffers label (<?? name=...>).
If optional argument FILE is specified collect labels in FILE."
  (let (list end)
    (save-excursion
      (set-buffer kahtml-completing-buffer)
      (if file (let (hilit-auto-highlight)
		 (set-buffer (find-file-noselect file))))
      (save-excursion
	(goto-char (point-min))
	(while ;(re-search-forward "<\\w+\\b" nil t)
	    (re-search-forward "\\(name\\|id\\)\\s *=" nil t)
	  ;(setq bound (match-end 0))
	  ;(search-forward ">" nil t)
	  (setq end (match-end 0))
	  (if (and ;(re-search-backward "\\(name\\|id\\)\\s *=" bound t)
	       (kahtml-on-assignment-p)
	       (progn
		 (goto-char end)
		 (skip-chars-forward " \t\n")
		 (looking-at "\"?#?\\([^\">]+\\)\"?\\b")))
	      (setq list (cons
			  (list (concat "#" (KaTeX-match-string 1)))
			  list))))
	list)))
  )

(defvar kahtml-url-completion-map nil "Key map used in URL completion buffer")
(if kahtml-url-completion-map nil
  (progn
    (setq kahtml-url-completion-map
	(copy-keymap minibuffer-local-completion-map))
    (define-key kahtml-url-completion-map #\TAB	'kahtml-complete-url)
    (define-key kahtml-url-completion-map #\SPC	'kahtml-complete-url)
  ))

(defun kahtml-complete-url ()
  "Complete external URL from history or local file name."
  (interactive)
  (let ((p (point)) initial i2 cmpl path dir file listfunc beg labels)
    (setq initial (buffer-string))
    (cond
     ((string-match "^http:" initial)
      (setq cmpl (try-completion initial kahtml-urls)
	    listfunc (list 'lambda nil
			   (list 'all-completions initial 'kahtml-urls))
	    beg (point-min)))
     ((setq beg (string-match "#" initial))
      (or (equal beg 0)			;begin with #
	  (progn
	    (setq path (substring initial 0 beg))
	    (if (string-match "^/" path)
		(setq path (kahtml-url-to-path path)))))
      (setq initial (substring initial beg))
      (setq labels (kahtml-collect-labels path)
	    cmpl (try-completion initial labels)
	    listfunc (list 'lambda ()
			   (list 'all-completions
				 initial (list 'quote labels)))
	    beg (+ (point-min) beg)))
     (t
      (setq path (if (string-match "^/" initial)
		     (or (kahtml-url-to-path initial) initial)
		   initial))
      (setq dir (or (file-name-directory path) ".")
	    file (file-name-nondirectory path)
	    initial file
	    cmpl (file-name-completion file dir)
	    listfunc (list 'lambda nil
			   (list 'file-name-all-completions
				 file dir))
	    beg (save-excursion (skip-chars-backward "^/") (point)))))
    (cond
     ((stringp cmpl)
      (if (string= initial cmpl)
	  (with-output-to-temp-buffer "*Completions*"
	    (princ "Possible completinos are:\n")
	    (princ
	     (mapconcat '(lambda (x) x)  (funcall listfunc) "\n")))
	(progn
	  (delete-region (point) beg)
	  (insert cmpl))))
     ((null cmpl)
      (ding))
     ((eq t cmpl)
      (save-excursion
	(unwind-protect
	    (progn
	      (goto-char p)
	      (insert " [Sole completion]"))
	  (delete-region p (point-max))))))))

(defvar kahtml-escape-chars 'ask
  "*Escape reserved characters to URL-encoding or not.
Nil for never, t for everytime, and 'ask for inquiring
at each reserved chars.")

;
; Subject: [katex:02849] Re: [yahtml] tilda in href tag
; From: Masayasu Ishikawa <mimasa@sfc.keio.ac.jp>
; To: katex@arcadia.jaist.ac.jp
; Date: Mon, 31 May 1999 21:09:31 +0900
; RFC 2396 の "2.4.3. Excluded US-ASCII Characters" によると、以下の文字
; は必ずエスケープしないといけません。
;
;     control     = <US-ASCII coded characters 00-1F and 7F hexadecimal>
;     space       = <US-ASCII coded character 20 hexadecimal>
;     delims      = "<" | ">" | "#" | "%" | <">
;     unwise      = "{" | "}" | "|" | "\" | "^" | "[" | "]" | "`"
(defvar kahtml-unsafe-chars-regexp
  "[][\x0- \x7f <>%\"{}|\\^`]" ;#は除去する
  "Characters regexp which must be escaped in URI.")
;
; また、以下の文字は予約された用法以外に用いる場合にはエスケープしないと
; いけないことになっています。
;
;     reserved    = ";" | "/" | "?" | ":" | "@" | "&" | "=" | "+" |
;                   "$" | ","
(defvar kahtml-unreserved-chars-regexp
  "[;/?:@&=+$,]"
  "Characters regexp which should be escaped in URI on certain conditions.
Not used yet.")

(defun kahtml-escape-chars-string (str)
  "Translate reserved chars to URL encoded string."
  (let ((p 0) (target "")
	(ask (eq kahtml-escape-chars 'ask)))
    (cond
     ((null kahtml-escape-chars) str)
     (t
      (while (and (string< "" str)
		  (setq p (string-match kahtml-unsafe-chars-regexp str)))
	(if (and ask (y-or-n-p (format nil "Escape char [~C] of `~A'"
				       (aref str p) (substring str 0 (1+ p)))))
	    (setq target (concat target
				 (substring str 0 p)
				 (format nil "%~:@(~2,'0x~)" (char-code (aref str p)))))
	  (setq target (concat target (substring str 0 (1+ p)))))
	(setq str (substring str (1+ p))))
      (concat target str)))))

(defun kahtml-escape-chars-region (beg end)
  "Translate reserved chars to encoded string in the region."
  (interactive "r")
  (save-excursion
    (let ((e (set-marker (make-marker) end)) c m yes)
      (goto-char beg)
      (while (and (< (point) e)
		  (re-search-forward
		   (concat kahtml-unsafe-chars-regexp "\\|"
			   kahtml-unreserved-chars-regexp) e t))
	(sit-for 0)
; 	(setq m (buffer-modified-p)
; 	      c (char-after (1- (point))))
; 	(save-excursion (backward-char 1) (insert " ==>"))
; 	(unwind-protect
; 	    (setq yes (y-or-n-p (format nil "Replace: [~C]" c)))
; 	  (save-excursion
; 	    (backward-char 1)
; 	    (delete-backward-char 4))
; 	  (set-buffer-modified-p m))
	(message "Replace: [~C] (y or n):" (setq c (char-after (1- (point)))))
	(if (memq (read-char) '(#\y #\Y))
	    (progn
	      (delete-region (match-beginning 0) (match-end 0))
	      (insert (format nil "%~:@(~2,'0x~)" (char-code c))))))
      (set-marker e nil))))
;; ab%defgls/.|

(defun kahtml-a ()
  "Add-in function for <a>"
  (let ((href ""))
    (setq kahtml-completing-buffer (current-buffer)
	  kahtml-urls (append kahtml-urls-private kahtml-urls-local)
	  href (kahtml-escape-chars-string
		(read-from-minibuffer "href: " "" kahtml-url-completion-map)))
    (prog1
	(concat (kahtml-make-optional-argument
		 "href" href)
		(kahtml-make-optional-argument
		 "name" (read-string "name: ")))
      (if (and (string-match "^http://" href)
	       (null (assoc href kahtml-urls-private))
	       (null (assoc href kahtml-urls-local)))
	  (KaTeX-update-table
	   (list href)
	   'kahtml-urls-private 'kahtml-urls-private 'kahtml-urls-local))
      )))

(defvar kahtml-parameters-completion-alist
  '(("align" ("top") ("middle") ("bottom") ("left") ("right") ("center"))
    ("src" . file)
    ("method" ("POST") ("GET"))
    ("rev" . kahtml-link-types-alist)
    ("rel" . kahtml-link-types-alist)
    ("type" . kahtml-content-types-alist)))

(defvar kahtml-link-types-alist 
  '(("alternate") ("stylesheet") ("start") ("next") ("prev")
    ("contents") ("index") ("glossary") ("chapter") ("section")
    ("subsection") ("appendix") ("help") ("bookmark")))

(defvar kahtml-content-types-alist
  '(("text/css") ("text/html") ("text/plain") ("text/richtext")
    ("text/sgml") ("text/xml")
    ("application/octet-stream") ("application/postscript") ("application/pdf")
    ("image/jpeg") ("image/gif") ("image/tiff") ("video/mpeg"))
  "Alist of content-types")

(defun kahtml-read-parameter (par &optional default alist)
  (let* ((alist
	  (cdr-safe (assoc (downcase par)
			   (or alist kahtml-parameters-completion-alist))))
	 (prompt (concat par ": "))
	 v)
    (cond
     ((eq alist 'file)
      (read-file-name prompt "" default nil ""))
     ((symbolp alist)
      (completing-read prompt (symbol-value alist) nil nil default))
     (alist
      (completing-read prompt alist nil nil default))
     (t 
      (read-string prompt default)))))
      
(defun kahtml-make-optional-argument (opt arg)
  "Make optional argument string."
  (if (string= "" arg)
      ""
    (concat " "
	    (if kahtml-prefer-upcase-attributes (upcase opt) (downcase opt))
	    "=\"" arg "\"")))

(defun kahtml-body ()
  "Add-in function for <body>"
  (let ((b (read-string "bgcolor="))
	(x (read-string "text color="))
	(l (read-string "link color="))
	(v (read-string "vlink color=")))
    (concat
     (kahtml-make-optional-argument "bgcolor" b)
     (kahtml-make-optional-argument "text" x)
     (kahtml-make-optional-argument "link" l)
     (kahtml-make-optional-argument "vlink" v))))


(defun kahtml-img ()
  "Add-in function for <img>"
  (let ((src (kahtml-read-parameter "src"))
	(alg (kahtml-read-parameter "align"))
	(alt (kahtml-read-parameter "alt"))
	(brd (read-string "border="))
	(l kahtml-prefer-upcase-attributes))
    (concat (if l "SRC" "src") "=\"" src "\""
	    (kahtml-make-optional-argument "align" alg)
	    (kahtml-make-optional-argument "alt" alt)
	    (kahtml-make-optional-argument "border" brd))))

(defun kahtml-form ()
  "Add-in function `form' input format"
  (concat
   " " (if kahtml-prefer-upcase-attributes "METHOD" "method=")
   (completing-read "Method: " '(("POST") ("GET")) nil t)
   " " (if kahtml-prefer-upcase-attributes "ACTION" "action") "=\""
   (read-string "Action: ") "\""
   ))

(defun kahtml-select ()
  "Add-in function for `select' input format"
  (setq kahtml-last-single-cmd "option")
  (concat " " (if kahtml-prefer-upcase-attributes "NAME" "name") "=\""
	  (read-string "name: ") "\""))

(defun kahtml-ol ()
  (setq kahtml-last-single-cmd "li") "")
(defun kahtml-ul ()
  (setq kahtml-last-single-cmd "li") "")
(defun kahtml-dl ()
  (setq kahtml-last-single-cmd "dt") "")
(defun kahtml-dt ()
  (setq kahtml-last-single-cmd "dd") "")

(defun kahtml-p ()
  (let ((alg (kahtml-read-parameter "align")))
    (kahtml-make-optional-argument "align" alg)
))

(defvar kahtml-input-types
  '(("text") ("password") ("checkbox") ("radio") ("submit")
    ("reset") ("image") ("hidden") ("file")))

(defun kahtml-input ()
  "Add-in function for `input' form"
  (let ((size "") name type value checked (maxlength "")
	(l kahtml-prefer-upcase-attributes))
    (setq name (read-string "name: ")
	  type (completing-read "type (default=text): "
				kahtml-input-types nil t)
	  value (read-string "value: "))
    (if (string-match "text\\|password\\|^$" type)
	(setq size (read-string "size: ")
	      maxlength (read-string "maxlength: ")))
    (concat
     (if l "NAME" "name") "=\"" name "\""
     (kahtml-make-optional-argument "type" type)
     (kahtml-make-optional-argument "value" value)
     (kahtml-make-optional-argument "size" size)
     (kahtml-make-optional-argument "maxlength" maxlength)
    )))

(defun kahtml-textarea ()
  "Add-in function for `textarea'"
  (interactive)
  (let (name rows cols)
    (setq name (read-string "Name: ")
	  cols (read-string "Columns: ")
	  rows (read-string "Rows: "))
    (concat
     (concat (if kahtml-prefer-upcase-attributes "NAME=" "name=")
	     "\"" name "\"")
     (kahtml-make-optional-argument "cols" cols)
     (kahtml-make-optional-argument "rows" rows))))

(defun kahtml-table ()
  "Add-in function for `table'"
  (let ((b (read-string "border="))
	(a (kahtml-read-parameter "align")))
    (concat
     (kahtml-make-optional-argument "border" b)
     (kahtml-make-optional-argument "align" a))))
;(fset 'kahtml-caption #'kahtml-p)
(defun kahtml-caption ()
  "Add-in function for `caption' in table tag"
  (let ((kahtml-parameters-completion-alist '(("align" ("top") ("bottom")))))
    (kahtml-make-optional-argument "align" (kahtml-read-parameter "align"))))

(defun kahtml-font ()
  "Add-in function for `font'"
  (concat 
   (kahtml-make-optional-argument "color" (read-string "color="))
   (kahtml-make-optional-argument "size" (read-string "size="))))

(defun kahtml-style ()
  "Add-in function for `style'"
  (kahtml-make-optional-argument
   "type" (read-string "type=" "text/css")))

(defun kahtml-tr ()
  "Add-in function for `tr'"
  (setq ;kahtml-last-begend "td"		;; which do you prefer?
	kahtml-last-typeface-cmd "td")
  "")

(defun kahtml-link ()
  "Add-in function for `link' (まだちょっと良く分かってない)"
  (let (rel rev type href)
    (setq rel (kahtml-read-parameter "rel"))
    (cond
     ((equal rel "")
      (concat (kahtml-make-optional-argument
	       "rev" (kahtml-read-parameter "rev"))
	      (kahtml-make-optional-argument
	       "href" (kahtml-read-parameter "href")
	       ;;他に良く使うのって何?
	       )))
     ((string-match "stylesheet" rel)
      (concat
       (kahtml-make-optional-argument "rel" rel)
       (kahtml-make-optional-argument
	"type" (kahtml-read-parameter "type" "text/css"))
       (progn
	 (setq href
	       (read-from-minibuffer "href: " "" kahtml-url-completion-map))
	 (if (string< "" href)
	     (progn
	       (if (and (file-exists-p (kahtml-url-to-path href))
			(y-or-n-p "Load css symbols now? "))
		   (setq kahtml-css-class-alist
			 (kahtml-css-collect-classes-file
			  (kahtml-url-to-path href) kahtml-css-class-alist)))
	       (message "")
	       (kahtml-make-optional-argument "href" href))))))
     (t ;;??
      ))))

;;; ---------- Simple tag ----------
(defun kahtml-insert-tag (region-mode &optional tag)
  "Insert <TAG> </TAG> and put cursor inside of them."
  (interactive "P")
  (or tag
      (let ((completion-ignore-case t))
	(setq tag
	      (KaTeX-cplread-with-learning
	       (format nil "Tag ~A(default ~A): " 
		       (if region-mode "region: " "") kahtml-last-typeface-cmd)
	       'kahtml-typeface-table 'kahtml-user-typeface-table
	       'kahtml-tmp-typeface-table))))
  (if (string= "" tag) (setq tag kahtml-last-typeface-cmd))
  (setq tag (or (cdr (assoc tag kahtml-typeface-table)) tag))
  (setq kahtml-last-typeface-cmd tag
	tag (funcall (if kahtml-prefer-upcases 'upcase 'downcase) tag))
  (if region-mode
      (if (if (string< "19" emacs-version) (mark t) (mark))
	  (save-excursion
	    (if (> (point) (mark)) (exchange-point-and-mark))
	    (insert (format nil "<~A~A>" tag (kahtml-addin tag)))
	    (exchange-point-and-mark)
	    (insert "</" tag ">"))
	(message "No mark set now"))
    (progn
      (insert (format nil "<~A~A>" tag (kahtml-addin tag)))
      (save-excursion (insert (format nil "</~A>" tag))))))

(defun kahtml-insert-tag-region (&optional tag)
  "Call kahtml-insert-tag with region mode."
  (interactive)
  (kahtml-insert-tag t tag))


(defun kahtml-insert-single (cmd)
  "Insert <CMD>."
  (interactive
   (list
    (let ((completion-ignore-case t))
      (KaTeX-cplread-with-learning
       (format nil "Command~A: "
	       (if kahtml-last-single-cmd
		   (concat "(default " kahtml-last-single-cmd ")") ""))
       'kahtml-single-cmd-table 'kahtml-user-single-cmd-table
       'kahtml-tmp-single-cmd-table))))
  (if (string= "" cmd) (setq cmd kahtml-last-single-cmd))
  (setq kahtml-last-single-cmd
	(or (cdr (assoc cmd kahtml-single-cmd-table)) cmd))
  (setq cmd (funcall (if kahtml-prefer-upcases 'upcase 'downcase)
		     kahtml-last-single-cmd))
  (insert (format nil "<~A>" cmd)))

(defun kahtml-insert-p (&optional arg)
  "Convenient function to insert <p></p>"
  (interactive "P")
  (if arg (kahtml-insert-tag nil "p")
    (progn
      (save-excursion			;insert "/p" first to memorize "p"
        (kahtml-insert-single "/p"))	;in the last-completion variable
      (kahtml-insert-single "p"))))

;;; ---------- Jump ----------
(defun kahtml-on-href-p ()
  "Check if point is on href clause."
  (let ((p (point)) e cmd (case-fold-search t))
    (save-excursion
      (and ;;(string= (KaTeX-inner-environment t) "a") ;aでなくても許可にした
	   (save-excursion
	     ;;(search-forward "</a>" nil t) ;aでなくても許可にした
	     (search-forward "[\" \t\n]" nil t)
	     (setq e (point)))
	   ;(goto-char (get 'KaTeX-inner-environment 'point))
	   (re-search-backward "<\\(a\\|link\\)\\>" nil t)
	   (search-forward "href" e t)
	   (search-forward "=" e t)
	   (progn
	     (skip-chars-forward " \t\n")
	     (looking-at "\"?\\([^\"> \t\n]+\\)\"?"))
	   (< p (match-end 0))
	   (KaTeX-match-string 1)
	   ))))

(defun kahtml-netscape-sentinel (proc mes)
  (cond
   ((null (buffer-name (process-buffer proc)))
    (set-process-buffer proc nil))
   ((eq (process-status proc) 'exit)
    (let ((cb (current-buffer)))
      (set-buffer (process-buffer proc))
      (goto-char (point-min))
      (if (search-forward "not running" nil t)
	  (progn
	    (message "Starting netscape...")
	    (start-process
	     "browser" (process-buffer proc)
	     shell-file-name kahtml-shell-command-option
	     (format nil "~A \"~A\"" kahtml-www-browser
		     (get 'kahtml-netscape-sentinel 'url)))
	    (message "Starting netscape...Done")))
      (set-buffer cb)))))

(defvar kahtml-browser-process nil)

(defun kahtml-browse-html (href)
  "Call WWW Browser to see HREF."
  (let ((pb "* WWW Browser *") (cb (current-buffer)))
    (cond
     ((and (string-match "browserex" kahtml-www-browser)
	   (fboundp 'bx:navigate-current-buffer))
      (bx:navigate-current-buffer kahtml-browserex-posiotion kahtml-browserex-size))
#| ;m.m
     ((string-match "^start\\>" kahtml-www-browser)
      (if (get-buffer pb)
	  (progn (set-buffer pb) (erase-buffer) (set-buffer cb)))
      (put 'kahtml-netscape-sentinel 'url href)
      (set-process-sentinel
       (setq kahtml-browser-process
	     (start-process
	      "browser" pb shell-file-name kahtml-shell-command-option
	      (format nil "~A \"~A\"" kahtml-www-browser href)))
       'kahtml-netscape-sentinel))
     ((and (string-match "[Nn]etscape" kahtml-www-browser)
	   (not (eq system-type 'windows-nt)))
      (if (get-buffer pb)
	  (progn (set-buffer pb) (erase-buffer) (set-buffer cb)))
      (put 'kahtml-netscape-sentinel 'url href)
      (set-process-sentinel
       (setq kahtml-browser-process
	     (start-process
	      "browser" pb shell-file-name kahtml-shell-command-option ;"-c"
	      (format nil "~A -remote \"openURL(~A)\"" kahtml-www-browser href)))
       'kahtml-netscape-sentinel))
     ((and (string= "w3" kahtml-www-browser) (fboundp 'w3-fetch))
      (w3-fetch href))
     ((stringp kahtml-www-browser)
      (if (and kahtml-browser-process
	       (eq (process-status kahtml-browser-process) 'run))
	  (message "~A is already running" kahtml-www-browser)
	(setq kahtml-browser-process
	      (start-process
	       "browser" "* WWW Browser *"
	       shell-file-name kahtml-shell-command-option
	       (format nil "~A \"~A\"" kahtml-www-browser href)))))
|# ;m.m
     (t
      (message "Sorry, jump across http is not supported.")))))

(defun kahtml-goto-corresponding-href (&optional other)
  "Go to corresponding name."
  (let ((href (kahtml-on-href-p)) file name (parent (get-buffer-file-name)))
    (if href
	(cond
	 ((string-match "^\\(ht\\|f\\)tp:" href)
	  (kahtml-browse-html href))
	 (t (setq file (substring href 0 (string-match "#" href)))
	    (if (string-match "#" href)
		(setq name (substring href (1+ (string-match "#" href)))))
	    (if (string< "" file)
		(progn
		  (if (string-match "/$" file)
		      (setq file (concat file kahtml-directory-index)))
		  (if (string-match "^/" file)
		      (setq file (kahtml-url-to-path file)))
		  (if other (KaTeX-switch-to-buffer-other-window file)
		    (KaTeX-switch-to-buffer file))
		  (or KaTeX-parent-file (setq KaTeX-parent-file parent))))
	    (if name
		(progn (set-mark-command nil) (kahtml-jump-to-name name)))
	    t)))))

(defun kahtml-jump-to-name (name)
  "Jump to html's named tag."
  (setq name (format nil "\\(name\\|id\\)\\s *=\\s *\"?~A\\>\"?" name))
  (or (and (re-search-forward name nil t) (goto-char (match-beginning 0)))
      (and (re-search-backward name nil t) (goto-char (match-beginning 0)))
      (message "Named tag `~A' not found" (substring href 1))))

(defun kahtml-on-begend-p (&optional p)
  "Check if point is on begend clause."
  (let ((p (or p (point))) cmd (case-fold-search t))
    (save-excursion
      (goto-char p)
      (if (equal (char-after (point)) #\<) (forward-char 1))
      (if (and (re-search-backward "<" nil t)
	       (looking-at
		(concat "<\\(/?" kahtml-struct-name-regexp "\\)\\b"))
	       (handler-case
		   (forward-list 1)
		 (error nil))
	       (< p (point)))
	  (KaTeX-match-string 1)))))

(defun kahtml-goto-corresponding-begend (&optional noerr)
  "Go to corresponding opening/closing tag.
Optional argument NOERR causes no error for unballanced tag."
  (let ((cmd (kahtml-on-begend-p)) m0
	(p (point)) (case-fold-search t) func str (nest 0))
    (cond
     (cmd
      (setq m0 (match-beginning 0))
      (if (= (aref cmd 0) #\/)		;on </cmd> line
	      (setq cmd (substring cmd 1)
		    str (format nil "\\(<~A\\)\\|\\(</~A\\)" cmd cmd)
		    func 're-search-backward)
	    (setq str (format nil "\\(</~A\\)\\|\\(<~A\\)" cmd cmd)
		  func 're-search-forward))
      (while (and (>= nest 0) (funcall func str nil t))
	(if (equal m0 (match-beginning 0))
	    nil
	  (setq nest (+ nest (if (match-beginning 1) -1 1)))))
      (if (< nest 0)
	  (goto-char (match-beginning 0))
	(progn
	  (funcall
	   (if noerr 'message 'error)
	   "Corresponding tag of `~A' not found." cmd)
	  (goto-char p)
	  nil)))
     (t nil))))

(defun kahtml-current-tag ()
  "Return the current tag name."
  (save-excursion
    (let ((p (point)) b tag)
      (or (bobp)
	  (looking-at "<")
	  (progn (skip-chars-backward "^<") (forward-char -1)))
      (setq b (point))
      (skip-chars-forward "<")
      (setq tag (buffer-substring
		 (point) (progn (skip-chars-forward "^ \t\n") (point))))
      (goto-char b)
      (forward-list 1)
      (and (< p (point)) tag))))
      

(defun kahtml-goto-corresponding-img ()
  "View image on point"
  (let ((tag (kahtml-current-tag)) image (p (point)) (case-fold-search t))
    (if (and tag
	     (string-match "img" tag)
	     (save-excursion
	       (re-search-backward "<\\s *img" nil t)
	       (re-search-forward "src=\"?\\([^\"> ]+\\)\"?")
	       (match-beginning 1)
	       (setq image
		     (buffer-substring (match-beginning 1) (match-end 1)))))
	(progn
	  (message "Invoking ~A ~A..." kahtml-image-viewer image)
	  (start-process
	   "Viewer" " * Image Viewer *"
	   shell-file-name kahtml-shell-command-option ;"-c"
	   (concat kahtml-image-viewer " " image))
	  (message "Invoking ~A ~A...Done" kahtml-image-viewer image)))))

(defun kahtml-get-attrvalue (attr)
  "Extract current tag's attribute value from buffer."
  (let (e (case-fold-search t))
    (save-excursion
      (or (looking-at "<")
	  (progn (skip-chars-backward "^<") (backward-char 1)))
      (setq e (save-excursion (forward-list 1) (point)))
      (if (and
	   (re-search-forward (concat "\\b" attr "\\b") e t)
	   (progn (skip-chars-forward " \t\n=")
	     (looking-at "\"?\\([^\"> \t\n]+\\)\"?")))
	  (KaTeX-match-string 1)))))

(defun kahtml-goto-corresponding-source (&optional other)
  "Goto applet's source."
  (let ((env (kahtml-current-tag)) s (p (point)))
    (cond
     ((string-match "applet" env)
      (if (setq s (kahtml-get-attrvalue "code"))
	  (progn
	    (setq s (KaTeX-match-string 1)
		  s (concat
		     (substring s 0 (string-match "\\.[A-Za-z]+$" s))
		     ".java"))
	    (if other (KaTeX-switch-to-buffer-other-window s)
	      (KaTeX-switch-to-buffer s))
	    s)				;return source file name
	(progn
	  (message "No applet source specified")
	  (sit-for 1)
	  nil)))
     ((string-match "!--#include" env)
      (cond
       ((setq s (kahtml-get-attrvalue "file")) ;<!--#include file="foo"-->
	(if other (KaTeX-switch-to-buffer-other-window s)
	  (KaTeX-switch-to-buffer s))
	s)
       ((setq s (kahtml-get-attrvalue "virtual"));<!--#include virtual="foo"-->
	(setq s (kahtml-url-to-path s))
	(if other (KaTeX-switch-to-buffer-other-window s)
	  (KaTeX-switch-to-buffer s))
	s)))
     ((and (string-match "!--#exec" env)
	   (setq s (kahtml-get-attrvalue "cmd")))
      (setq s (substring s 0 (string-match " \t\\?" s))) ;get argv0
      (let ((b " *kahtmltmp*"))		;peek a little
	(unwind-protect
	    (progn
	      (set-buffer (get-buffer-create b))
	      (insert-file-contents s nil 0 100)
	      (if (looking-at "#!")
		  (if other (KaTeX-switch-to-buffer-other-window s)
		    (KaTeX-switch-to-buffer s))))
	  (kill-buffer (get-buffer b)))
	(get-file-buffer s))))))

(defun kahtml-goto-corresponding-* (&optional other)
  "Go to corresponding object."
  (interactive)
  (cond
   ((kahtml-goto-corresponding-href other))
   ((kahtml-goto-corresponding-img))
   ((kahtml-goto-corresponding-begend))
   ((kahtml-goto-corresponding-source other))
   (t (message "I don't know where to go."))
   ))

(defun kahtml-goto-corresponding-*-other-window ()
  "Go to corresponding object."
  (interactive)
  (kahtml-goto-corresponding-* t))

(defun kahtml-visit-main ()
  "Go to parent file from where you visit current file."
  (interactive)
  (if KaTeX-parent-file (KaTeX-switch-to-buffer KaTeX-parent-file)))

;;; ---------- killing ----------
(defun kahtml-kill-begend (&optional whole)
  (let ((tag (kahtml-on-begend-p)) p q r bbolp)
    (if tag
	(save-excursion
	  (or (looking-at "<")
	      (progn (skip-chars-backward "^<") (forward-char -1)))
	  (setq p (point))
	  (kahtml-goto-corresponding-begend)
	  (or (looking-at "<")
	      (progn (skip-chars-backward "^<") (forward-char -1)))
	  (if (< (point) p)		;if on the opening tag
	      (progn (setq q p p (point))
		     (goto-char q))
	    (setq q (point)))		;now q has end-line's (point)
	  (if (not whole)
	      (kill-region
	       (progn (skip-chars-backward " \t")
		      (if (setq bbolp (bolp)) (point) q))
	       (progn (forward-list 1)
		      (setq r (point))
		      (skip-chars-forward " \t")
		      (if (and bbolp (eolp) (not (eobp))) (1+ (point)) r))))
	  (goto-char p)
	  (skip-chars-backward " \t")
	  (if (not whole)
	      (progn
		(kill-append
		 (buffer-substring
		  (setq p (if (setq bbolp (bolp)) (point) p))
		  (setq q (progn
			    (forward-list 1)
			    (setq r (point))
			    (skip-chars-forward " \t")
			    (if (and bbolp (eolp) (not (eobp)))
				(1+ (point))
			      r))))
		 t)
		(delete-region p q))
	    (kill-region
	     (if (bolp) (point) p)
	     (progn (goto-char q)
		    (forward-list 1)
		    (setq r (point))
		    (skip-chars-forward " \t")
		    (if (and (eolp) (not (eobp))) (1+ (point)) r))))
	  tag))))

(defun kahtml-kill-* (whole)
  "Kill current position's HTML tag (set)."
  (interactive "P")
  (cond
   ((kahtml-kill-begend whole))
   ))


;;; ---------- changing ----------
(defun kahtml-on-assignment-p ()
  "Return if current point is on parameter assignment.
If so, return parameter name, otherwise nil.
This function should be able to treat white spaces in value, but not yet."
  (let ((p (point)))
    (save-excursion
      (put 'kahtml-on-assignment-p 'region nil)
      (skip-chars-backward "^ \t")
      (and (looking-at "\\([A-Za-z0-9]+\\)\\s *=\\s *\"?\\([^ \t\"]+\\)\"?")
	   (< p (match-end 0))
	   (>= p (1- (match-beginning 2)))
	   (put 'kahtml-on-assignment-p 'region
		(cons (match-beginning 2) (match-end 2)))
	   (KaTeX-match-string 1)))))

(defun kahtml-change-begend ()
  (let ((tag (kahtml-on-begend-p))
	(completion-ignore-case t)
	(case-fold-search t)
	(p (point)) (q (make-marker))
	(default (append kahtml-env-table kahtml-typeface-table))
	(user (append kahtml-user-env-table kahtml-user-typeface-table))
	(tmp (append kahtml-tmp-env-table kahtml-tmp-typeface-table))
	href b1 e1 attr new css)
    (cond
     (tag
      (cond
       ((and (string-match "^a$" tag)
	     (save-excursion
	       (and
		(re-search-backward "<a\\b" nil t)
		(progn
		  (goto-char (match-end 0))
		  (skip-chars-forward " \t\n")
		  (setq b1 (point))
		  (search-forward ">" nil t))
		(setq e1 (match-beginning 0))
		(goto-char b1)
		(re-search-forward "href\\s *=" e1 t)
		(>= p (point))
		(progn
		  (goto-char (match-end 0))
		  (skip-chars-forward " \t\n")
		  (looking-at "\"?\\([^\"> \t\n]+\\)\"?"))
		(< p (match-end 0)))))
	(setq b1 (match-beginning 1) e1 (match-end 1)
	      kahtml-completing-buffer (current-buffer)
	      ;; kahtml-urls-local is buffer-local, so we must put
	      ;; that into kahtml-urls here
	      kahtml-urls (append kahtml-urls-private kahtml-urls-local)
	      href (read-from-minibuffer
		    "Change href to: " "" kahtml-url-completion-map))
	(if (string< "" href)
	    (progn
	      ;;(setq href  ;??
		;;    (if kahtml-prefer-upcases (upcase href) (downcase href)))
	      (delete-region b1 e1)
	      (goto-char b1)
	      (insert href))))
       ((setq attr (kahtml-on-assignment-p)) ;if on the assignment to attr
	(if (and (equal attr "class")	     ;treat "class" attribute specially
		 (setq css (assoc tag kahtml-css-class-alist)))
	    (setq new (kahtml-read-parameter ;should be made generic?
		       attr nil (list (cons "class" (cdr css)))))
	  ;;other than "class", read parameter normally
	  (setq new (kahtml-read-parameter attr)))
	(goto-char (car (get 'kahtml-on-assignment-p 'region)))
	(delete-region (point) (cdr (get 'kahtml-on-assignment-p 'region)))
	(insert new))
       (t
	(save-excursion
	  (if (= (aref tag 0) #\/) (setq tag (substring tag 1)))
	  (or (= (char-after (point)) #\<) (skip-chars-backward "^<"))
	  (skip-chars-forward "^A-Za-z")
	  (set-marker q (point))
	  (setq p (point))
	  (kahtml-goto-corresponding-begend)
	  (or (= (char-after (point)) #\<)
	      (skip-chars-backward "^<"))
	  (skip-chars-forward "^A-Za-z")
	  (if (= (char-after (1- (point))) #\/)
	      (progn
		(set-marker q (point))
		(goto-char p)))
	  (setq tag (let ((completion-ignore-case t))
		      (KaTeX-cplread-with-learning
		       (format nil "Change `~A' to(default ~A): "
			       tag kahtml-last-begend)
		       'default 'user 'tmp)))
	  (delete-region (point) (progn (skip-chars-forward "^>") (point)))
	  (if (string= "" tag) (setq tag kahtml-last-begend))
	  (setq kahtml-last-begend
		(or (cdr (assoc tag kahtml-env-table)) tag)
		tag kahtml-last-begend)
	  (setq tag (if kahtml-prefer-upcases (upcase tag) (downcase tag)))
	  (insert (format nil "~A~A" tag (kahtml-addin tag)))
	  (goto-char q)
	  (set-marker q nil)
	  (delete-region (point) (progn (skip-chars-forward "^>") (point)))
	  (insert tag))))
      t))))

(defun kahtml-change-command ()
  (let ((p (point)) (case-fold-search t) cmd par new
	(beg (make-marker)) (end (make-marker)))
    (skip-chars-backward "^<")
    (if (and
	 (looking-at kahtml-command-regexp)
	 (progn
	   (set-marker beg (match-beginning 0))
	   (set-marker end (match-end 0))
	   t)				;for further work
	 (progn
	   (forward-char -1)
	   (handler-case
	       (forward-list 1)
	     (error nil))
	   (< p (point))))
	(progn
	  (goto-char p)
	  (if (setq par (kahtml-on-assignment-p))
	      (progn
		(setq new (kahtml-read-parameter par))
		(set-marker beg (car (get 'kahtml-on-assignment-p 'region)))
		(set-marker end (cdr (get 'kahtml-on-assignment-p 'region))))
	    (setq new
		  (KaTeX-cplread-with-learning
		   "Change form to: "
		   'kahtml-form-table 'kahtml-user-form-table
		   'kahtml-tmp-form-table)))
	  (delete-region beg end)
	  (goto-char beg)
	  (set-marker beg nil)
	  (set-marker end nil)	
	  (insert new)
	  t)
      (progn
	(goto-char p)
	nil))))

(defun kahtml-change-* ()
  "Change current position's HTML tag (set)."
  (interactive)
  (cond
   ((kahtml-change-begend))
   ((kahtml-change-command))
  ))

;;; ---------- commenting ----------
(defvar kahtml-translate-hyphens-when-comment-region t
  "*Non-nil for translate hyphens to &#45; when comment-region")

(defun kahtml-comment-region (&optional uncom)
  "Comment out region or environment."
  (interactive)
  (let ((e (make-marker)) be beg p)
    (cond
     (;(marker-position (set-marker e (kahtml-on-begend-p)))
      (setq be (kahtml-on-begend-p))
      (save-excursion
	(setq p (point))
	(if (string-match "^/" be)
	    (setq beg (progn (forward-line 1) (point)))
	  (setq beg (progn (beginning-of-line) (point))))
	(goto-char p)
	(kahtml-goto-corresponding-begend)
	(if (string-match "^/" be)
	    (beginning-of-line)
	  (forward-line 1))
	(set-marker e (point))
	;(comment-region beg (point) (if uncom (list 4)))
	))
     (t ;(comment-region (region-beginning) (region-end) (if uncom (list 4)))
      (setq beg (region-beginning))
      (set-marker e (region-end))))
    (if kahtml-translate-hyphens-when-comment-region
	(let ((kahtml-entity-reference-chars-alist-default nil)
	      (kahtml-entity-reference-chars-alist '((#\- . "#45")))
	      kahtml-entity-reference-chars-regexp
	      kahtml-entity-reference-chars-reverse-regexp)
	  (kahtml-entity-reference-chars-setup)
	  (funcall
	   (if uncom 'kahtml-translate-reverse-region
	     'kahtml-translate-region)
	   beg e)))
    (comment-region beg (marker-point e) (if uncom (list 4)))
    (set-marker e nil)))

(defun kahtml-uncomment-region ()
  (interactive)
  (kahtml-comment-region t))

;;; ---------- translate to entity references ----------
(defvar kahtml-entity-reference-chars-alist-default
  ;'((#\> . "gt") (#\< . "lt") (#\& . "amp") (#\" . "quot") (#\' . "apos"))
  '((#\> . "gt") (#\< . "lt") (#\& . "amp") (#\" . "quot"))
  "Default translation table from character to entity reference")
(defvar kahtml-entity-reference-chars-alist nil
  "*Translation table from character to entity reference")
(defvar kahtml-entity-reference-chars-regexp nil)
(defvar kahtml-entity-reference-chars-reverse-regexp nil)

(defun kahtml-entity-reference-chars-setup ()
  (let ((list (append kahtml-entity-reference-chars-alist-default
		      kahtml-entity-reference-chars-alist)))
    (setq kahtml-entity-reference-chars-regexp "["
	  kahtml-entity-reference-chars-reverse-regexp "&\\(")
    (while list
      (setq kahtml-entity-reference-chars-regexp
	    (concat kahtml-entity-reference-chars-regexp
		    (char-to-string (car (car list))))
	    kahtml-entity-reference-chars-reverse-regexp
	    (concat kahtml-entity-reference-chars-reverse-regexp
		    (cdr (car list))
		    (if (cdr list) "\\|")))
      (setq list (cdr list)))
    (setq kahtml-entity-reference-chars-regexp
	  (concat kahtml-entity-reference-chars-regexp "]")
	  kahtml-entity-reference-chars-reverse-regexp
	  (concat kahtml-entity-reference-chars-reverse-regexp "\\);"))))

(kahtml-entity-reference-chars-setup)

(defun kahtml-translate-region (beg end)
  "Translate inhibited literals."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (let ((ct (append kahtml-entity-reference-chars-alist
		       kahtml-entity-reference-chars-alist-default)))
	(goto-char beg)
	(while (re-search-forward kahtml-entity-reference-chars-regexp nil t)
	  ;(setq c (preceding-char))
	  (replace-match
	   (concat "&" (cdr (assoc (preceding-char) ct)) ";")))))))

(defun kahtml-translate-reverse-region (beg end)
  "Translate entity references to literals."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (let ((ct (append kahtml-entity-reference-chars-alist
		       kahtml-entity-reference-chars-alist-default))
	    ec)
	(goto-char beg)
	(while (re-search-forward
		kahtml-entity-reference-chars-reverse-regexp nil t)
	  ;(setq c (preceding-char))
	  (setq ec (KaTeX-match-string 1))
	  (delete-region (match-end 0) (match-beginning 0))
	  (insert (car (KaTeX-rassoc ec ct))))))))

(defun kahtml-inner-environment-but (exclude &optional quick)
  "Return the inner environment but matches with EXCLUDE tag."
  (let (e (case-fold-search t))
    (save-excursion
      (while (and (setq e (KaTeX-inner-environment quick))
		  (string-match exclude e))
	(goto-char (get 'KaTeX-inner-environment 'point))))
    e))

;;; ---------- filling ----------
(defvar kahtml-saved-move-to-column (symbol-function 'move-to-column))
(defun kahtml-move-to-column (col &optional force)
  (beginning-of-line)
  (let ((ccol 0))
  (while (and (> col ccol) (not (eolp)))
    (if (eq (following-char) #\<)
	(progn
	  (while (and (not (eq (following-char) #\>))
		      (not (eolp)))
		   (forward-char))
	  (or (eolp) (forward-char)))
      (progn
	(or (eolp) (forward-char))
        (if (eq (preceding-char) #\t)
	    (let ((wd (- 8 (% (+ ccol 8) 8))))
	      (if (and force (< col (+ ccol wd)))
	  	  (progn
		    (backward-char 1)
		    (insert-char #\\  (- col ccol))
		    (setq ccol col))
	        (setq ccol (+ ccol wd))))
	  (setq ccol (1+ ccol)))
        (if (and KaTeX-japan
	         (or
		  (and (fboundp 'char-category)
		       (string-match "[chj]" (char-category (preceding-char))))
		  (and (fboundp 'char-charset)
		       (not (eq (char-charset (preceding-char)) 'ascii)))))
	    (setq ccol (1+ ccol))))))
  (if (and force (> col ccol))
      (progn
	(insert-char #\\  (- col ccol))
	col)
    ccol)))

(defun kahtml-fill-paragraph (arg)
  (interactive "P")
  (let*((case-fold-search t) (p (point)) fill-prefix
	(e (or (kahtml-inner-environment-but "^\\(a\\|p\\)\\b" t) "html"))
	indent
	(startp (get 'KaTeX-inner-environment 'point))
	(prep (string-match "^pre$" e))
	(ps1 (if prep (default-value 'paragraph-start)
	       paragraph-start))
	(ps2 (if prep (concat (default-value 'paragraph-start)
			      "$\\|^\\s *</?pre>")
	       paragraph-start)))
    (save-excursion
      (unwind-protect
	  (progn
	    (if prep
		(fset 'move-to-column #'kahtml-move-to-column))
	    (save-excursion
	      (beginning-of-line)
	      (indent-to-column (kahtml-this-indent))
	      (setq fill-prefix
		    (buffer-substring (point) (point-beginning-of-line)))
	      (delete-region (point) (point-beginning-of-line)))
	    (fill-region-as-paragraph
	     (progn (re-search-backward paragraph-start nil t)
		    (or (save-excursion
			  (goto-char (match-beginning 0))
			  (if (looking-at "<")
			      (forward-list)
			    (progn
			      (goto-char (match-end 0))
			      (skip-chars-forward " \t>")))
			  (if (looking-at "[ \t]*$")
			      (progn (forward-line 1) (point))))
			(point)))
	     (progn (goto-char p)
		    (re-search-forward ps2 nil t)
		    (match-beginning 0))))
	(fset 'move-to-column kahtml-saved-move-to-column)))))

;(defun kahtml-indent-new-commnet-line ()
;  (unwind-protect
;      (progn
;	(fset 'move-to-column #'kahtml-move-to-column)
;	(apply 'KaTeX-saved-indent-new-comment-line (if soft (list soft))))
;    (fset 'move-to-column kahtml-saved-move-to-column)))

;;; 
;;; ---------- indentation ----------
;;; 
(defun kahtml-indent-line ()
  "Indent a line (faster wrapper)"
  (interactive)
  (let (indent)
    (if (and (save-excursion
	       (beginning-of-line) (skip-chars-forward "\t ")
	       (not (looking-at "<")))
	     (save-excursion
	       (forward-line -1)
	       (while (and (not (bobp)) (looking-at "^\\s *$"))
		 (forward-line -1))
	       (skip-chars-forward "\t ")
	       (setq indent (current-column))
	       (not (looking-at "<"))))
	(progn
	  (save-excursion
	    (beginning-of-line)
	    (skip-chars-forward " \t")
	    (or (= (current-column) indent)
		(KaTeX-reindent indent)))
	  (and (bolp) (skip-chars-forward " \t")))
      (kahtml-indent-line-real))))

(defun kahtml-this-indent ()
  (let ((envs "[uod]l\\|table\\|[ht][rhd0-6]\\|select\\|blockquote\\|center\\|menu\\|dir\\|font")
	(itemizing-envs "^\\([uod]l\\|menu\\|dir\\)$")
	(itms "<\\(dt\\|dd\\|li\\|t[rdh]\\|option\\)\\b")
	inenv p col peol (case-fold-search t))
    (save-excursion
      (beginning-of-line)
      (setq inenv (or (kahtml-inner-environment-but "^\\(a\\|p\\)\\b" t)
		      "html")
	    col (get 'KaTeX-inner-environment 'indent)
	    p (get 'KaTeX-inner-environment 'point)
	    op nil))
    (save-excursion
      (cond
       ((string-match envs inenv)
	(save-excursion
	  (beginning-of-line)
	  (skip-chars-forward " \t")
	  (cond				;lookup current line's tag
	   ((looking-at (concat "</\\(" envs "\\)>"))
	    col)
	   ((looking-at itms)
	    (+ col kahtml-environment-indent))
	   ((and kahtml-hate-too-deep-indentation
		 (looking-at (concat "<\\(" envs "\\)")))
	    (+ col (* 2 kahtml-environment-indent)))
	   ((and (< p (point))
		 (string-match itemizing-envs inenv)
		 (save-excursion
		   (and
		    (setq op (point))
		    (goto-char p)
		    (re-search-forward itms op t)
		    (progn
		      (skip-chars-forward "^>")
		      (skip-chars-forward ">")
		      (skip-chars-forward " \t")
		      (setq col (if (looking-at "$")
				    (+ col kahtml-environment-indent)
				  (current-column)))))))
	    col)
	   (t
	    (+ col kahtml-environment-indent)))))
       (t col)))))

(defun kahtml-indent-line-real ()
  "Indent current line."
  (interactive)
  (KaTeX-reindent (kahtml-this-indent))
  (if (bolp) (skip-chars-forward " \t"))
  (let (peol col)
    (if (and (setq inenv (kahtml-on-begend-p))
	     (string-match
	      (concat "^\\<\\(" kahtml-struct-name-regexp "\\)") inenv))
	(save-excursion
	  (setq peol (point-end-of-line))
	  (or (= (char-after (point)) #\<)
	      (progn (skip-chars-backward "^<") (forward-char -1)))
	  (setq col (current-column))
	  (if (and (kahtml-goto-corresponding-begend t)
		   (> (point) peol))	;if on the different line
	      (KaTeX-reindent col))))))

;(defun kahtml-fill-item ()
;  "Fill item HTML version"
;  (interactive)
;  (let (inenv p fill-prefix peol (case-fold-search t))
;    (setq inenv (or (KaTeX-inner-environment) "html")
;	  p (get 'KaTeX-inner-environment 'point))
;    (cond
;     ((string-match "^[uod]l" inenv)
;      (save-excursion
;	(if (re-search-backward "<\\(d[td]\\|li\\)>[ \t\n]*" p t)
;	    (progn
;	      (goto-char (match-end 0))
;	      (setq col (current-column)))
;	  (error "No <li>, <dt>, <dd>")))
;      (save-excursion
;	(end-of-line)
;	(setq peol (point))
;	(newline)
;	(indent-to-column col)
;	(setq fill-prefix (buffer-substring (point) (1+ peol)))
;	(delete-region (point) peol)
;	(fill-region-as-paragraph
;	 (progn (re-search-backward paragraph-start nil t) (point))
;	 (progn (re-search-forward paragraph-start nil t 2)
;		(match-beginning 0)))))
;     (t nil))))

;;; 
;;; ---------- Lint and Browsing ----------
;;; 
(defun kahtml-browse-menu ()
  "Browsing menu"
  (interactive)
  (message "J)weblint p)Browse R)eload...")
  (let ((c (char-to-string (read-char))))
    (cond
     ((string-match "j" c)
      (kahtml-lint-buffer (current-buffer)))
     ((string-match "[bp]" c)
      (kahtml-browse-current-file))
     ((string-match "r" c)
      (kahtml-browse-reload)))))

(defvar kahtml-lint-buffer "*weblint*")

(defun kahtml-lint-buffer (buf)
  "Call lint on buffer BUF."
  (require 'katexprc)
  (interactive "bCall lint on buffer: ")
  (setq buf (get-buffer buf))
  (KaTeX-save-buffers)
  (KaTeX-typeset
   (concat kahtml-lint-program " "
	   (file-name-nondirectory (buffer-file-name buf)))
   kahtml-lint-buffer  "lint" "lint"))

(defun kahtml-file-to-url (file)
  "Convert local unix file name to URL.
If no matches found in kahtml-path-url-alist, return raw file name."
  (let ((list kahtml-path-url-alist) p url)
    (if (file-directory-p file)
	(setq file (expand-file-name kahtml-directory-index file))
      (setq file (expand-file-name file)))
    (if (string-match "^[A-Za-z]:/" file)
	(progn
	  ;; (aset file 1 #\|) ;これは要らないらしい…
	  (setq file (concat "///" file))))
    (while list
      (if (string-match (concat "^" (regexp-quote (car (car list)))) file)
	  (setq url (cdr (car list))
		file (substring file (match-end 0))
		url (concat url file)
		list nil))
      (setq list (cdr list)))
    (or url (concat "file:" file))))

(defun kahtml-url-to-path (file &optional basedir)
  "Convert local URL name to unix file name."
  (let ((list kahtml-path-url-alist) url realpath docroot
	(dirsufp (string-match "/$" file)))
    (setq basedir (or basedir
		      (file-name-directory
		       (expand-file-name default-directory))))
    (cond
     ((string-match "^/" file)
      (while list
	(if (file-directory-p (car (car list)))
	    (progn
	      (setq url (cdr (car list)))
	      (if (string-match "\\(http://[^/]*\\)/" url)
		  (setq docroot (substring url (match-end 1)))
		(setq docroot url))
	      (cond
	       ((string-match (concat "^" (regexp-quote docroot)) file)
		(setq realpath
		      (expand-file-name
		       (substring
			file
			(if (= (aref file (1- (match-end 0))) #\/)
			    (match-end 0) ; "/foo"
			  (min (1+ (match-end 0)) (length file)))) ; "/~foo"
		       (car (car list))))))
	      (if realpath
		  (progn (setq list nil)
			 (if (and dirsufp (not (string-match "/$" realpath)))
			     (setq realpath (concat realpath "/")))))))
	(setq list (cdr list)))
      realpath)
     (t file))))
		
(defun kahtml-browse-current-file ()
  "Call WWW browser on current file."
  (interactive)
  (basic-save-buffer)
  (kahtml-browse-html (kahtml-file-to-url (buffer-file-name))))

(defun kahtml-browse-reload ()
  "Send `reload' event to netzscape."
  (let ((pb "* WWW Browser *") (cb (current-buffer)))
    (cond
     ((string-match "browserex" kahtml-www-browser)
      (bx:refresh-browser))
#| ;m.m
     ((string-match "[Nn]etscape" kahtml-www-browser)
      (if (get-buffer pb)
	  (progn (set-buffer pb) (erase-buffer) (set-buffer cb)))
      ;;(or (get 'kahtml-netscape-sentinel 'url)
	;;  (error "Reload should be called after Browsing."))
      (put 'kahtml-netscape-sentinel 'url
	   (kahtml-file-to-url (buffer-file-name)))
      (basic-save-buffer)
      (set-process-sentinel
       (setq kahtml-browser-process
	     (start-process
	      "browser" pb shell-file-name kahtml-shell-command-option ;"-c"
	      (format nil "~A -remote 'reload'" kahtml-www-browser)))
       'kahtml-netscape-sentinel))
|# ;m.m
     (t
      (message "Sorry, RELOAD is supported only for browserex.")))))

;;; ---------- Intelligent newline ----------
(defun kahtml-intelligent-newline (arg)
  "Intelligent newline for HTML"
  (interactive "P")
  (let (env func)
    (end-of-line)
    (setq env (downcase (or (kahtml-inner-environment-but "^\\(a\\|p\\)\\b" t)
			    "html")))
    (setq func (intern-soft (concat "kahtml-intelligent-newline-" env)))
    (newline)
    (if (and env func (fboundp func))
	;; if intelligent line function is defined, call that
	(funcall func)
      ;; else do the default action
      (if (string-match kahtml-p-prefered-env-regexp env)
	  (kahtml-insert-p)))))

(defvar kahtml-faithful-to-htmllint nil)
(defun kahtml-intelligent-newline-ul ()
  (interactive)
  (kahtml-insert-single "li")
  (or kahtml-faithful-to-htmllint (insert " "))
  (kahtml-indent-line))

(fset 'kahtml-intelligent-newline-ol #'kahtml-intelligent-newline-ul)

(defun kahtml-intelligent-newline-dl ()
  (interactive)
  (let ((case-fold-search t))
    (if (save-excursion
	  (re-search-backward "<\\(\\(dt\\)\\|\\(dd\\)\\)>"
			      (get 'KaTeX-inner-environment 'point) t))
	(cond
	 ((match-beginning 2)
	  (kahtml-insert-single "dd")
	  (or kahtml-faithful-to-htmllint (insert " "))
	  (setq kahtml-last-single-cmd "dt"))
	 ((match-beginning 3)
	  (kahtml-insert-single "dt")
	  (or kahtml-faithful-to-htmllint (insert " "))
	  (setq kahtml-last-single-cmd "dd")))
      (progn
	(insert (if kahtml-prefer-upcases "<DT> " "<dt> "))
	(setq kahtml-last-single-cmd "dd")))
    (kahtml-indent-line)
    (and (string-match kahtml-p-prefered-env-regexp "dl")
	 (string-equal kahtml-last-single-cmd "dt")
	 (kahtml-insert-p nil))))

(defun kahtml-intelligent-newline-select ()
  (interactive)
  (insert "<" (if kahtml-prefer-upcases "OPTION" "option") "> ")
  (kahtml-indent-line))

;;; ---------- Marking ----------
(defun kahtml-mark-begend ()
  "Mark current tag"
  (interactive)
  (KaTeX-beginning-of-environment)
  (let ((p (point)))
    (save-excursion
      (skip-chars-backward " \t" (point-beginning-of-line))
      (if (bolp) (setq p (point))))
    (push-mark p t))
  (kahtml-goto-corresponding-begend)
  (forward-list 1)
  (if (eolp) (forward-char 1)))

;;; ---------- complete marks ----------
(defun kahtml-complete-mark ()
  "Complete &gt, &lt, &ampersand, and &quote."
  (interactive)
  (message "1:< 2:> 3:& 4:\" 5:' 6:nbsp")
  (let ((c (read-char)))
    (setq c (if (or (< c #\0) (> c #\7))
		(string-match (regexp-quote (char-to-string c)) "<>&\"")
	      (- c #\1)))
    (if (or (< c 0) (> c 6))
	nil
      (insert (format nil "&~A;"
		      (nth c '("lt" "gt" "amp" "quot" "apos" "nbsp")))))))


;;; ---------- jump to error line ----------
(defvar kahtml-error-line-regexp
  "^\\(.*\\)(\\([0-9]+\\)):"
  "*Regexp of error position which is produced by lint program.")
(defun kahtml-prev-error ()
  "Jump to previous error seeing lint buffer."
  (interactive)
  (or (get-buffer kahtml-lint-buffer)
      (error "No lint program ran."))
  (KaTeX-showup-buffer kahtml-lint-buffer nil t)
  (kahtml-jump-to-error-line t))

(defun kahtml-jump-to-error-line (&optional sit)
  (interactive "P")
  (let ((p (point)) (e (point-end-of-line)))
    (end-of-line)
    (if (re-search-backward kahtml-error-line-regexp nil t)
	(let ((f (KaTeX-match-string 1))
	      (l (string-to-int (KaTeX-match-string 2))))
	  (if sit (sit-for 1))
	  (forward-line -1)
	  (KaTeX-showup-buffer (KaTeX-switch-to-buffer f t) nil t)
	  (goto-line l))
      (message "No line number usage"))))

;;; ---------- Style Sheet Support ----------
(defvar kahtml-css-class-alist nil
  "Alist of elements vs. their classes")

(defun kahtml-css-collect-classes-region (beg end &optional initial)
  (save-restriction
    (save-excursion
      (narrow-to-region beg end)
      (goto-char (point-min))
      (let ((alist initial) b e element class a
	    ;(s1 (aref (syntax-table) #\{ )) ;m.m
	    ;(s2 (aref (syntax-table) #\} )) ;m.m
	    )
	;(modify-syntax-entry #{ "(}")
        ;(modify-syntax-entry #} "){")
	(setq b (point))
	(unwind-protect
	    (while (search-forward "{" nil t)
	      (setq e (point))
	      (goto-char b)
	      (while (re-search-forward		;ちょといい加減なREGEXP
		      "\\([a-z][a-z0-9]*\\)\\.\\([a-z][a-z0-9]*\\)\\>" e t)
		(setq element (KaTeX-match-string 1)
		      class (KaTeX-match-string 2))
		(if (setq a (assoc element alist))
		    (or (assoc class (cdr a))
			(setcdr a (cons (list class) (cdr a))))
		  (setq alist (cons (list element (list class)) alist))))
	      (goto-char (1- e))
	      ;(forward-list 1)
	      (search-forward "}" nil t)
	      (setq b (point)))
	  ;(aset (syntax-table) #\{ s1) ;m.m
	  ;(aset (syntax-table) #\} s2) ;m.m
	  )
      alist))))
	    
(defun kahtml-css-collect-classes-buffer (&optional initial)
  (interactive)
  (kahtml-css-collect-classes-region (point-min) (point-max) initial))

(defun kahtml-css-collect-classes-file (file &optional initial)
  (let ((hilit-auto-highlight nil) (cb (current-buffer)))
    (set-buffer (find-file-noselect file))
    (prog1
	(kahtml-css-collect-classes-buffer initial)
      (set-buffer cb))))

(defun kahtml-css-scan-styles ()
  (save-excursion
    (goto-char (point-min))
    (set (make-local-variable 'kahtml-css-class-alist) nil)
    (while (re-search-forward "<\\(style\\|link\\)" nil t)
      (let ((b (match-beginning 0))(tag (KaTeX-match-string 1)) e href alist)
	(cond
	 ((string-match "style" tag)
	  (goto-char b)
	  (save-excursion (forward-list 1) (setq e (point)))
	  (cond
	   ((search-forward "text/css" e 1) ;css definition starts
	    (setq alist
		  (kahtml-css-collect-classes-region
		   (point) (progn (search-forward "</style>") (point))
		   alist)))))
	 ((and (string-match "link" tag)
	       (setq href (kahtml-get-attrvalue "href"))
	       (kahtml-url-to-path href)
	       (file-exists-p (kahtml-url-to-path href)))
	    (setq alist
		  (kahtml-css-collect-classes-file
		   (kahtml-url-to-path href) alist))))
	(setq kahtml-css-class-alist alist)))))

;;; ---------- ----------

;;;
;;hilit19
;;;
(defvar kahtml-default-face-table
  '(
    (form	black/ivory	white/hex-442233	italic)
    ))
(defvar kahtml-hilit-patterns-alist
  '(
    ;; comments
    ("<!--\\s " "-->" comment)
    ;; include&exec
    ("<!--#\\(include\\|exec\\|config\\|fsize\\|flastmod\\)" "-->" include)
    ;; string
    (hilit-string-find #\\ string)
    (kahtml-hilit-region-tag "\\(em\\|strong\\)" bold)
    ("</?[uod]l>" 0 decl)
    ("<\\(di\\|dt\\|li\\|dd\\)>" 0 label)
    ("<a\\s +href" "</a>" crossref)
    (kahtml-hilit-region-tag-itself "</?\\sw+\\>" decl)
    ))

(defun kahtml-hilit-region-tag (tag)
  "Return list of start/end point of <TAG> form."
  (if (re-search-forward (concat "<" tag ">") nil t)
      (let ((m0 (match-beginning 0)))
	(skip-chars-forward " \t\n")
	(cons (point)
	      (progn (re-search-forward (concat "</" tag ">") nil t)
		     (match-beginning 0))))))

(defun kahtml-hilit-region-tag-itself (ptn)
  "Return list of start/end point of <tag options...> itself."
  (if (re-search-forward ptn nil t)
      (let ((m0 (match-beginning 0)))
	(skip-chars-forward "^>")
	(cons m0 (1+ (point) )))))

;(setq hilit-patterns-alist (delq (assq 'kahtml-mode hilit-patterns-alist) hilit-patterns-alist))
(and (featurep 'hilit19)
     (or (assq 'kahtml-mode hilit-patterns-alist)
	 (setq hilit-patterns-alist
	       (cons (cons 'kahtml-mode kahtml-hilit-patterns-alist)
		     hilit-patterns-alist))))

(run-hooks 'kahtml-load-hook)
(provide 'kahtml)

; Local variables:
; fill-prefix: ";;; "
; paragraph-start: "^$\\|\\|;;;$"
; paragraph-separate: "^$\\|\\|;;;$"
; End:
