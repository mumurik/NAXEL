;;; -*- Mode: Lisp; Last updated: "2007/04/07" -*-
;;;

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;;   xyzzy版の説明
;;;
;;;   py-mode --- 言語Python用メジャーモード
;;;
;;;     by Deecay

#|
●概要

  Furukawa Toru氏が作成したpy-modeにいくつかの機能(shift-regionなど)
を追加してみたものをFurukawa氏のサイトで公開してもらっていましたが、
このたび本格的にTim Peters, Barry Warsawらによるemacs用Python-mode.elの
移植にチャレンジしてみました。作成に当たっては以下のソフトウェアを参考に
しました。
  python-mode.el by Tim Peters
  py-mode.l by Toru Furukawa氏
  emacs.l by manabu@chaos.club.ne.jp
  shell3.l by Hattori Masashi
  comint.el


●注意事項

  pdb関係、Jython関連はまだ移植が終わっていません。
時間があればチャレンジしてみたいと思います。

●インストール
   0. netinstallerを利用した場合は特に設定は必要ありません。
　　　動作に不満がある場合はこのソースの設定用変数部分を参照してください

   1. py-mode.lをsite-lispフォルダにコピー。
   2. バイトコンパイル(byte-compile-file)して、.xyzzyかsite-init.lに

  (load-library "py-mode")
  (push '("\\.py$" . py-mode) *auto-mode-alist*)

    と書いて、必要に応じてダンプし直せば大丈夫です。

   x. 文字コードについて
        PYTHONPATH\Lib\site-packages\sitecustomize.py(なければ作る)に

import sys
from codecs import getwriter
sys.setdefaultencoding('shift_jis')
sys.stdout = getwriter('shift_jis')(sys.stdout)

        と書くと日本語のエンコード関係がマシになるかもしれません。



●使い方

    M-x py-mode  バッファをpy-modeにする

    C-c m  (py-describe-mode)  py-modeの日本語ヘルプ

●更新履歴

    version 0.97 2007/04/07
        逆インデントがおかしかったのを修正
        開き括弧の直後に"n"があるとインデントがおかしかったのを修正
        その他こまかい修正

    version 0.96 2007/03/19
        py-shellへの出力ができるように
        全体的に無限ループに嵌りにくくなったはず
        その他こまかい修正

    version 0.95
        py-shellをもっと使いやすく。

    version 0.94
        continuation lineのインデントに不具合があったのを修正。

    version 0.93
        mapconcatを修正。thanks to nakayato & NANRI.
        py-execute-stringを移植。
        py-shellを移植。
        py-execute-import-or-reloadを移植。

    version 0.92
        速度をいくらか改善。
        execute-regionが以前のバージョンのままだったのを修正。
        pycheckerを移植。
        pydocを移植。

    version 0.91
        キーワード用pyファイルを同梱。
        menuを移植。
        その他細かい修正。

|#


(provide "py-mode")
(in-package "editor")

;;;; 以下、emacs.lより流用、一部改変。

;; 未完成。emacsのparse-partial-sexpは10個の値のリストを返すが、py-modeでは
;; 最初の5値を返すだけで十分。whileで範囲内の文字を走査しているので信じられ
;; ないほど遅い。しかもnth 2とnth 3は文字列の認識のしかたが不十分。ここが
;; このpy-modeの生命線なのでなんとかしたい。

(defun py-parse-partial-sexp-new (&optional start end)
  "incomplete. partial-start ignores string block"
  (interactive "r")
  (if (> start end) (rotatef start end))
  (let ((depth 0)
		bracket-open partial-start at-string at-comment stack-bs)
		(goto-char (1+ start))
		(while (scan-buffer "\\(\\s(\\)\\|\\(\\s)\\)" :regexp t :limit end :tail t)
			(if (parse-point-syntax)
					(skip-syntax-spec-forward "^\"")
				(cond
				 ((match-string 1)
					(incf depth)
					(push bracket-open stack-bs)
					(setq bracket-open (point))
					(setq bracket-end nil))
				 (t
					(decf depth)
					(setq partial-start bracket-open)
					(setq bracket-open (pop stack-bs))
					(setq bracket-end (point))))))
		(goto-char end)
		(setq pps (parse-point-syntax))
		(setq at-string (if (eq pps :string) (char-code #\")))
		(setq at-comment (eq pps :comment))
		(setq bracket-open (if bracket-open (1- bracket-open)))
		(list depth bracket-open partial-start at-string at-comment)))

(defun py-parse-partial-sexp-old (&optional start end)
  "incomplete. partial-start ignores string block"
  (interactive "r")
  (if (> start end) (rotatef start end))
  (let ((depth 0)
		(char-open-bracket (list 40 91 123)) ; "([{"
		(char-close-bracket (list 41 93 125)) ; ")]}"
		(char-string 34) ; #\"
		bracket-open partial-start at-string at-comment stack-bs)
	(goto-char (1+ start))
	(while (py-re-search-forward "[\]\[\(\)\{\}]" end t)
	  (let ((chr (py-char-before))
			(pps (parse-point-syntax)))
		(cond ((and (not pps) (find chr char-open-bracket))
			   (setq depth (1+ depth))
			   (push bracket-open stack-bs)
			   (setq bracket-open (point))
			   (setq bracket-end nil))
			  ((and (not pps) (find chr char-close-bracket))
			   (setq depth (1- depth))
			   (setq partial-start bracket-open)
			   (setq bracket-open (pop stack-bs))
			   (setq bracket-end (point)))
			  )))
	(goto-char end)
	(setq pps (parse-point-syntax))
	(setq at-string (if (eq pps :string) (char-code #\")))
	(setq at-comment (eq pps :comment))
	(setq bracket-open (if bracket-open (1- bracket-open)))
	(list depth bracket-open partial-start at-string at-comment)))

(defun py-parse-partial-sexp (&optional start end)
	(interactive "r")
	(py-parse-partial-sexp-new start end))




;; from emacs.l and revised. negative arg allowed.
(defun elisp-search (string reverse regexp &optional limit noerror repeat)
  (let* ((tail (not reverse))
         (count (if repeat repeat 1))
         (limit (if (numberp limit) limit
                  (if reverse (point-min) (point-max))))
         (noerror (if (eq 't limit) limit noerror))
         (spoint (point)))
    ;(when reverse (backward-char 1))
    (setq *last-search-regexp-p* regexp)
    (if regexp
        (setq *last-search-regexp* string)
					(setq *last-search-string* string))
    (save-restriction
      (while (and (> count 0)
                  spoint)
        (setq spoint
              (if (scan-buffer string
							   :no-dup reverse;;;;;
                               :regexp regexp
                               :reverse reverse
                               :tail tail
                               :case-fold *case-fold-search*
                               :left-bound *word-search*
                               :right-bound *word-search*
                               :limit limit)
                  (point)
                (cond
                 ((numberp noerror)
                  (goto-char limit)
                  nil)
				 ((eq noerror t) nil)
				 ((eq noerror nil)
                  (plain-error "文字列が見つかりまへん") 
                  nil)
				 (t
				  (goto-char (if reverse (point-min) (point-max)))
				  nil))))
        (setq count (1- count))))
    spoint))


;; from emacs.l and revised. repeatの値が負の時にも対応
(defun py-re-search-backward (regexp &optional limit noerror repeat)
  (interactive "sRe-Search backward: "
    :default0 *last-search-regexp* :history0 'search)
	(if (and repeat (minusp repeat))
			(progn (setq repeat (abs repeat))
				(elisp-search regexp nil t limit noerror repeat))
		(elisp-search regexp t t limit noerror repeat)))


;; from emacs.l and revised. 
(defun py-re-search-forward (regexp &optional limit noerror repeat)
  (interactive "sRe-Search forward: "
    :default0 *last-search-regexp* :history0 'search)
	(if (and repeat (minusp repeat))
			(progn (setq repeat (abs repeat))
				(elisp-search regexp t t limit noerror repeat))
		(elisp-search regexp nil t limit noerror repeat)))

(defun find-file-noselect (filename &optional nowarn rawfile)
  (unless (get-file-buffer filename)
    (editor::find-file-internal filename nowarn))
  (get-file-buffer filename))

(defun push-mark (&optional (markp (point)) nomsg active)
  (and (mark t)
       (push (mark-marker) mark-ring))
  (set-mark markp)
  (unless nomsg
    (message "Mark set"))
  nil)

(defun mark-marker ()
  (set-marker (make-marker) (mark t)))


(defun memq (object list)
  (lisp::member object list :test #'eq))

(defun prefix-numeric-value (arg)
  (cond
   ((and (symbolp arg)
         (eq arg 'nil))
    (setq arg 1))
   ((and (symbolp arg)
         (eq arg '-))
    (setq arg -1))
   ((listp arg)
    (setq arg (car arg))))
  arg)

(defun py-char-after (&optional n)
     (save-excursion
			 (if n (goto-char n))
			 (char-code (following-char))))

(defun py-char-before (&optional n)
     (save-excursion
			 (if n (goto-char n))
			 (char-code (preceding-char))))

(defun py-current-indentation ()
  (save-excursion
    (goto-bol)
    (skip-chars-forward " \t")
    (current-column)))

; revised. universal-argument allowed.
(defun comment-region (start end &optional arg)
  (interactive "r\nP")
  (or comment-start (error "No comment syntax is defined"))
	(if (> start end) (rotatef start end))
  (save-excursion
    (save-restriction
      (let ((cs comment-start) (ce comment-end)
						(cp (when comment-padding
						(format nil (format nil "~~~DA" comment-padding) #\ )))
	    numarg)
	(if (eq *prefix-args* 'universal-argument)
			(setq numarg t)
		(progn
			(setq numarg (prefix-numeric-value
						  (if *prefix-args* *prefix-value* arg)))
	  ;; For positive arg > 1, replicate the comment delims now,
	  ;; then insert the replicated strings just once.
	  (while (> numarg 1)
			(setq cs (concat cs comment-start)
		  ce (concat ce comment-end)
			numarg (1- numarg)))))
	;; Loop over all lines from BEG to END.
	(narrow-to-region start end)
	(goto-char start)
	(if (or (eq numarg t) (< numarg 0))
	    (while (not (eobp))
	      (let (found-comment)
		;; Delete comment start from beginning of line.
		(if (eq numarg t)
		    (while (looking-at (regexp-quote cs))
		      (setq found-comment t)
		      (delete-char (length cs)))
		  (let ((count numarg))
		    (while (and (> 1 (setq count (1+ count)))
				(looking-at (regexp-quote cs)))
		      (setq found-comment t)
		      (delete-char (length cs)))))
		;; Delete comment padding from beginning of line
		(when (and found-comment comment-padding
			   (looking-at (regexp-quote cp)))
		  (delete-char comment-padding))
		;; Delete comment end from end of line.
		(if (string= "" ce)
		    nil
		  (if (eq numarg t)
		      (progn
			(end-of-line)
			;; This is questionable if comment-end ends in
			;; whitespace.  That is pretty brain-damaged,
			;; though.
			(while (progn (skip-chars-backward " \t")
				      (and (>= (- (point) (point-min)) (length ce))
					   (save-excursion
					     (backward-char (length ce))
					     (looking-at (regexp-quote ce)))))
			    (delete-char (- (length ce)))))
		    (let ((count numarg))
		      (while (> 1 (setq count (1+ count)))
			(end-of-line)
			;; this is questionable if comment-end ends in whitespace
			;; that is pretty brain-damaged though
			(skip-chars-backward " \t")
			(if (>= (- (point) (point-min)) (length ce))
			    (save-excursion
			      (backward-char (length ce))
			      (if (looking-at (regexp-quote ce))
				  (delete-char (length ce)))))))))
		(forward-line 1)))
		(progn
			(when comment-padding
				(setq cs (concat cs cp)))
			(while (not (eobp))
				;; Insert at beginning and at end.
				(if (looking-at "[ \t]*$") ()
					(progn
						(insert cs)
						(if (string= "" ce) ()
							(progn
								(end-of-line)
								(insert ce)))))
				(or (forward-line 1) (goto-eol))))
		)))))

;; make-sequence??
(defun make-string (count character)
  (if (< count 0)
      (error "Out of range")
    (let ((key "")
          (char (string character)))
      (dotimes (i count)
        (setq key (concat key char)))
      key)))

(defvar-local mark-ring nil)

(defun mark-marker ()
  (py-set-marker (make-marker) (mark t)))

(defun py-set-marker (marker position &optional buffer)
  (unless (markerp marker)
    (setq marker (make-marker)))
  (let ((sb (selected-buffer)))
    (when buffer
      (set-buffer buffer))
    (editor::set-marker marker position)
    (when buffer
      (set-bufer sb)))
  marker)

(defun push-mark (&optional (markp (point)) nomsg active)
  (and (mark t)
       (push (mark-marker) mark-ring))
  (set-mark markp)
  (unless nomsg
    (message "Mark set"))
  nil)

(defun assq (key alist)
  (lisp::assoc key alist :test #'eq))

(eval-when (:compile-toplevel :load-toplevel :execute)
	(defun mapconcat (function sequence separator)
		(let* ((list (mapcar function sequence))
					 (result (car list)))
			(setq list (cdr list))
			(dolist (tmp list result)
				(setq result (concat result separator (string tmp))))
			)))

;; arg は無視。適当。 
(defun py-forward-comment(&optional arg)
	(interactive)
	(while (or (eq (parse-point-syntax) :comment)
							(looking-at "[# \t\n]"))
		(forward-char))
	nil)

(defun py-skip-chars-forward (character-set &optional limit)
  (interactive "p")
  (let ((p (point)))
    (if (integerp limit)
        (save-restriction
          (narrow-to-region (point) limit)
          (editor::skip-chars-forward character-set))
      (editor::skip-chars-forward character-set))
    (- (point) p)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; 以下本体

;; 設定用変数

(defvar-local py-which-shell "python"
  "シェル用コマンド")

(defvar py-which-args '("-i")
  "シェルコマンドに送るオプションのリスト")

(defvar *py-indent-offset* 4
  "インデントに使われるスペースの量")

(defvar-local *py-continuation-offset* 4
  "継続行の場合に追加されるインデントスペースの量。
  「継続行」とは、バックスラッシュで終わる行の次の行と、
  閉じていない括弧がある行の次の行のこと。")

(defvar py-block-comment-prefix "##"
  "py-comment-regionで使われるコメントアウト用文字列")

(defvar py-honor-comment-indentation t
  "コメント行が、それ以降の行のインデントに与える影響を切り替える。

  nil ならコメント行はインデントに影響を与えません。
  t なら、一つの'#'で始まる行は以降の行のインデント量の指標となります。")

(defconstant py-jump-on-exception t)

(defvar py-ask-about-save t
  "non-nil ならコードを実行するときに各バッファを保存するかを聞く。
  nil なら何も聞かずにすべてのバッファを保存する。")

(defvar py-backspace-function 'backward-delete-char-untabify
  "py-electric-backspace で呼ばれる削除用関数。")

(defvar py-align-multiline-strings-p t
  "三重引用符のインデント方法を指定するフラグ。
   non-nil なら直前の行のインデントにあわせる。
   nil ならゼロ桁目にインデントする。")

;; ;; 設定用変数部 おわり



(export '(*py-mode-hook* *py-mode-map* *py-keyword-hash-table*
	      *py-keyword-file* *py-mode-syntax-table* *py-indent-tabs-mode*
          *py-indent-offset* *py-continuation-offset* *py-menu-name*
		  *py-menu-default*))
(export '(py-mode py-electric-colon py-execute-region py-execute-buffer
		  py-goto-exception py-indent-line py-shift-region-right
		  py-shift-region-left py-comment-region py-previous-statement
		  py-next-statement py-goto-block-up py-beginning-of-def-or-class
		  py-end-of-def-or-class py-mark-block py-mark-def-or-class
		  py-narrow-to-defun py-electric-backspace py-pychecker-run
		  py-help-at-point py-shell py-execute-string
		  py-restart-shell py-quit-shell))


(defvar *py-mode-hook* nil)


(defvar *py-mode-map* nil)
(unless *py-mode-map*
  (setq *py-mode-map* (make-sparse-keymap))
  (define-key *py-mode-map* #\TAB 'py-indent-line)
  (define-key *py-mode-map* #\RET 'py-newline-and-indent)
  (define-key *py-mode-map* #\:   'py-electric-colon)
  (define-key *py-mode-map* #\C-h 'py-electric-backspace)
  (define-key *py-mode-map* '(#\C-c #\#) 'py-comment-region)
  (define-key *py-mode-map* '(#\C-c #\|) 'py-execute-region)
  (define-key *py-mode-map* '(#\C-c #\C-e) 'py-execute-buffer)
  (define-key *py-mode-map* '(#\C-c #\C-s) 'py-execute-string)
  (define-key *py-mode-map* '(#\C-c #\>) 'py-shift-region-right)
  (define-key *py-mode-map* '(#\C-c #\<) 'py-shift-region-left)
  (define-key *py-mode-map* '(#\C-c #\C-r) 'py-shift-region-right)
  (define-key *py-mode-map* '(#\C-c #\C-l) 'py-shift-region-left)
  (define-key *py-mode-map* '(#\C-c #\C-n) 'py-next-statement)
  (define-key *py-mode-map* '(#\C-c #\C-p) 'py-previous-statement)
  (define-key *py-mode-map* '(#\C-c #\C-u) 'py-goto-block-up)
  (define-key *py-mode-map* '(#\M-C-a) 'py-beginning-of-def-or-class)
  (define-key *py-mode-map* '(#\M-C-e) 'py-end-of-def-or-class)
  (define-key *py-mode-map* '(#\M-C-h) 'py-mark-def-or-class)
  (define-key *py-mode-map* '(#\C-c #\C-k) 'py-mark-block)
  (define-key *py-mode-map* '(#\C-c #\C-w) 'py-pychecker-run)
  (define-key *py-mode-map* '(#\C-c #\C-h) 'py-help-at-point)
  (define-key *py-mode-map* '(#\C-x #\n #\d) 'py-narrow-to-defun)
  (define-key *py-mode-map* '(#\C-c #\m) 'py-describe-mode)
  (define-key *py-mode-map* '(#\C-c #\!) 'py-shell))


(defconstant py-stringlit-re
  (concat
   "[rR]?'''[^']*\\(\\('[^']\\|''[^']\\)[^']*\\)*'''"
   "\\|"
   "[rR]?\"\"\"[^\"]*\\(\\(\"[^\"]\\|\"\"[^\"]\\)[^\"]*\\)*\"\"\""
   "\\|"
   "[rR]?'\\([^'\n\\]\\|\\\\.\\)*'"	; single-quoted
   "\\|"				; or
   "[rR]?\"\\([^\"\n\\]\\|\\\\.\\)*\""	; double-quoted
   )
  "Regular expression matching a Python string literal.")

(defconstant py-continued-re
  (concat
   ".*\\$\\|"
   "\\(" "[^#'\"\n\\]" "\\|" py-stringlit-re "\\)*"
   "\\\\$")
	"Regular expression matching Python backslash continuation lines.")

(defconstant py-traceback-line-re
  "[ \t]+File \"\\([^\"]+\\)\", line \\([0-9]+\\)"
  "Regular expression that describes tracebacks.")

(defconstant py-blank-or-comment-re "[ \t]*\\($\\|#\\)"
  "Regular expression matching a blank or comment line.")

(defconstant py-block-closing-keywords-re
  "\\(return\\|raise\\|break\\|continue\\|pass\\)"
  "Regular expression matching keywords which typically close a block.")

(defconstant py-outdent-re
  (concat "\\(" (mapconcat 'identity
			   '("else:"
			     "except\\(\\s +.*\\)?:"
			     "finally:"
			     "elif\\s +.*:")
			   "\\|")
	  "\\)")
  "Regular expression matching statements to be dedented one level.")

(defconstant py-no-outdent-re
  (concat
   "\\("
   (mapconcat 'identity
	      (list "try:"
		    "except\\(\\s +.*\\)?:"
		    "while\\s +.*:"
		    "for\\s +.*:"
		    "if\\s +.*:"
		    "elif\\s +.*:"
		    (concat py-block-closing-keywords-re "[ \t\n]")
		    )
	      "\\|")
	  "\\)")
  "Regular expression matching lines not to dedent after.")


(defvar-local py-master-file nil)
(defvar py-pychecker-command "pychecker.bat")
(defvar py-pychecker-command-args '("--stdlib"))
(defvar py-pychecker-history nil)
(defvar *py-indent-tabs-mode* nil)
(defvar *py-keyword-hash-table* nil)
(defvar *py-keyword-file* "py")


(defvar *py-mode-syntax-table* nil)
(unless *py-mode-syntax-table*
  (setq *py-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
	(let ((c (code-char x)))
	  (unless (alpha-char-p c)
		(set-syntax-punctuation *py-mode-syntax-table* c))))
  (set-syntax-string *py-mode-syntax-table* #\")
  (set-syntax-string *py-mode-syntax-table* #\')
  (set-syntax-match *py-mode-syntax-table* #\( #\))
  (set-syntax-match *py-mode-syntax-table* #\{ #\})
  (set-syntax-match *py-mode-syntax-table* #\[ #\])
  ;(set-syntax-tag *py-mode-syntax-table* #\( #\))
  ;(set-syntax-tag *py-mode-syntax-table* #\[ #\])
  (set-syntax-escape *py-mode-syntax-table* #\\)
  (set-syntax-start-comment *py-mode-syntax-table* #\#)
  (set-syntax-end-comment *py-mode-syntax-table* #\LFD nil t)
  (set-syntax-word *py-mode-syntax-table* #\_))

;;; ローカル補完テーブルの定義
(defvar *py-mode-abbrev-table* nil)
(unless *py-mode-abbrev-table*
  (define-abbrev-table '*py-mode-abbrev-table*))

(defun py-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "py")
  (setq buffer-mode 'py-mode)
  (use-keymap *py-mode-map*)
  (use-syntax-table *py-mode-syntax-table*)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'py-indent-line)
;  (make-local-variable 'tags-find-target)
;  (setq tags-find-target #'py-tags-find-target)
;  (make-local-variable 'tags-find-point)
;  (setq tags-find-point #'py-tags-find-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'py-build-summary-of-functions)
  (and *py-keyword-file*
       (null *py-keyword-hash-table*)
       (setq *py-keyword-hash-table*
             (load-keyword-file *py-keyword-file* t)))
  (when *py-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *py-keyword-hash-table*))
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *py-indent-tabs-mode*)
  (py-menu-update)
  (setq *local-abbrev-table* *py-mode-abbrev-table*)
  (run-hooks '*py-mode-hook*))



;; Utilities

(defmacro py-safe (&rest body)
  "BODYを実行する。その中でエラーが起きたらnilを返す。"
	`(handler-case (progn ,@ body)
       (error nil)))

(defun py-keep-region-active ()
	"needed for XEmacs. xyzzyでは不要。"
	)

(defun py-point (position)
  "あるPOSITIONのポイント位置を返します。
引数POSITIONがとりうる値は以下の八つです。

  bol  -- beginning of line
  eol  -- end of line
  bod  -- beginning of def or class
  eod  -- end of def or class
  bob  -- beginning of buffer
  eob  -- end of buffer
  boi  -- back to indentation
  bos  -- beginning of statement

この関数はポイントもマークも変更しません。"
  (let ((here (point)))
    (cond
     ((eq position 'bol) (goto-bol))
     ((eq position 'eol) (goto-eol))
     ((eq position 'bod) (py-beginning-of-def-or-class))
     ((eq position 'eod) (py-end-of-def-or-class))
     ;; Kind of funny, I know, but useful for py-up-exception.
     ((eq position 'bob) (beginning-of-buffer))
     ((eq position 'eob) (end-of-buffer))
     ((eq position 'boi) (back-to-indentation))
     ((eq position 'bos) (py-goto-initial-line))
     (t (error "Unknown buffer position requested: ~a" position))
     )
    (prog1
        (point)
      (goto-char here))))

;; todo2 py-highlight-line
(defun py-highlight-line (from to file line)
	"XEmacsでの挙動が分からないので保留。"
	)

;; todo2 py-in-literal py-parse-partial-sexpが不完全なため、こちらも不完全。
;; limが無視される。
(defun py-in-literal (&optional lim)
  "ポイントがリテラル(コメント、または文字列)のなかにあったらnon-nilを返す。
引数LIMが与えられた場合、その位置からスキャンします。"
  (let* ((lim (or lim (py-point 'bod)))
	;(state (py-parse-partial-sexp lim (point))))
	 (state (parse-point-syntax)))
    (cond
     ((eq state :string) 'string)
     ((eq state :comment) 'comment)
     (t nil))))


;; Menu

(defvar *py-menu-name*  "Python(&P)"
  "py-mode: メニュー文字列")

(defvar *py-menu-default* nil
  "py-mode: ローカルメニュー")

(defun py-menu-update ()
  "py-mode: ローカルメニューの設定"
  (let ((menu (py-get-menu)))
	(when (and (menup menu) (current-menu))
      (use-local-menu menu))))

(defun py-menu-update-all-buffers ()
  "py-mode: 起動時のローカルメニューの設定"
  (let ((menu (py-get-menu)))
    (when (menup menu)
      (save-excursion
        (dolist (buffer (buffer-list))
          (set-buffer buffer)
		  (when (and (eq buffer-mode 'py-mode) (current-menu))
            (use-local-menu menu)))))))

(unless (get-app-menu (selected-frame))
  (add-hook '*post-startup-hook* 'py-menu-update-all-buffers))

(defun py-get-menu ()
  "py-mode: 状況に応じたローカルメニューの作成"
  (when (get-app-menu (selected-frame))
	(let ((menu (copy-menu-items (get-app-menu (selected-frame)) (create-menu))))
	  ;(insert-popup-menu menu (get-menu-position menu 'ed::help)
	  ;									 (create-imenu)
	  ;                   *py-imenu-name*)
	  (insert-popup-menu menu (get-menu-position menu 'ed::help)
						 (py-default-menu)
						 *py-menu-name*)
	  menu)))

(defun py-default-menu()
  (or *py-menu-default*
	  (setq *py-menu-default*
			(let ((menu (create-popup-menu 'py-mode)))
			  (add-menu-item menu nil "リージョンをコメントアウト"
							 'py-comment-region
							 #'(lambda ()
								 (and (not (mark t)) :disable)))
			  (add-menu-item menu nil "リージョンのコメント解除"
							 #'(lambda ()
								 (interactive)
								 (py-comment-region (mark) (point) -1))
							 #'(lambda ()
								 (and (not (mark t)) :disable)))
			  (add-menu-separator menu)
			  (add-menu-item menu nil "ブロックをマーク"
							 'py-mark-block)
			  (add-menu-item menu nil "defをマーク"
							 'py-mark-def-or-class)
			  (add-menu-item menu nil "classをマーク"
							 #'(lambda ()
								 (interactive)
								 (py-mark-def-or-class t)))
			  (add-menu-separator menu)
			  (add-menu-item menu nil "リージョンを左に"
							 'py-shift-region-left
							 #'(lambda ()
								 (and (not (mark t)) :disable)))
			  (add-menu-item menu nil "リージョンを右に"
							 'py-shift-region-right
							 #'(lambda ()
								 (and (not (mark t)) :disable)))
			  (add-menu-separator menu)
			  (add-menu-item menu nil "バッファを実行"
							 'py-execute-buffer)
			  (add-menu-item menu nil "リージョンを実行"
							 'py-execute-region
							 #'(lambda ()
								 (and (not (mark t)) :disable)))
			  (add-menu-item menu nil "defもしくはclassを実行"
							 'py-execute-def-or-class
							 #'(lambda ()
								 (and (not (mark t)) :disable)))
			  (add-menu-item menu nil "文字列を実行"
							 'py-execute-string)
			  (add-menu-item menu nil "シェルを起動..."
							 'py-shell)
			  (add-menu-separator menu)
			  (add-menu-item menu nil "ブロックの先頭へ"
							 'py-goto-block-up)
			  (add-menu-item menu nil "classの先頭へ"
							 #'(lambda ()
								 (interactive)
								 (py-beginning-of-def-or-class t)))
			  (add-menu-item menu nil "classの末尾へ"
							 #'(lambda ()
								 (interactive)
								 (py-end-of-def-or-class t)))
			  (add-menu-item menu nil "defの先頭へ"
							 'py-beginning-of-def-or-class)
			  (add-menu-item menu nil "defの末尾へ"
							 'py-end-of-def-or-class)
			  menu))))


;; todo2 py-choose-shell-by-shebang 
(defun py-choose-shell-by-shebang ()
	"Jython関連")

;; todo2 py-choose-shell-by-import
(defun py-choose-shell-by-import ()
	"Jython関連")

;; todo2 py-choose-shell
(defun py-choose-shell ()
	"Jython関連")

(defun py-outdent-p ()
  "現在行が一段アンインデントする必要があるならnon-nilを返す。"
  (save-excursion
    (and (progn (back-to-indentation)
		(looking-at py-outdent-re))
	 ;; short circuit infloop on illegal construct
	 (not (bobp))
	 (progn (forward-line -1)
		(py-goto-initial-line)
		(back-to-indentation)
		(while (or (looking-at py-blank-or-comment-re)
			   (bobp))
			(progn (forward-line -1) (back-to-indentation)))
		(not (looking-at py-no-outdent-re)))
	 )))

;; originally arg not optional
(defun py-electric-colon (&optional arg)
  "コロンを挿入する。
必要に応じて行のアンインデントを行います。数引数が与えられた場合はその数だけの
コロンが挿入されます。その場合、アンインデントは行われません。また、
アンインデントはコメントや文字列の中では行われません。"
  (interactive "*P")
  (let ((pref (prefix-numeric-value *prefix-value*)))
	(if (plusp pref)
		(self-insert-command pref)))
  ;; are we in a string or comment?
  (if (save-excursion
		(let ((pps (py-parse-partial-sexp (save-excursion
											(py-beginning-of-def-or-class)
											(point))
										  (point))))
		  (not (or (nth 3 pps) (nth 4 pps)))))
	  (save-excursion
		(let ((here (point))
			  (outdent 0)
			  (indent (py-compute-indentation t))) ;;;;
		  (if (and (not arg)
				   (py-outdent-p)
				   (= indent (save-excursion
							   (py-next-statement -1)
							   (py-compute-indentation t)))
				   )
			  (setq outdent *py-indent-offset*))
		  ;; Don't indent, only dedent.  This assumes that any lines
		  ;; that are already dedented relative to
		  ;; py-compute-indentation were put there on purpose.  It's
		  ;; highly annoying to have `:' indent for you.  Use TAB, C-c
		  ;; C-l or C-c C-r to adjust.  TBD: Is there a better way to
		  ;; determine this???
		  (if (< (py-current-indentation) indent) nil
			(progn
			  (goto-char here)
			  (goto-bol)
			  (delete-horizontal-spaces)
			  (indent-to (- indent outdent)))
			)))))

;;; pdb関連は保留。時間があったらやろうと思います。


(defun py-postprocess-output-buffer (buf &optional linenum)
  "Highlight exceptions found in BUF.
If an exception occurred return t, otherwise return nil.  BUF must exist."
  (let (line file bol err-p)
	(save-excursion
	  (set-buffer buf)
	  (beginning-of-buffer)
	  (when (py-re-search-forward py-traceback-line-re nil t)
		(setq file (match-string 1)
			  line (+ (parse-integer (match-string 2)) linenum)
			  bol (py-point 'bol))
		;ここはパス。
		;(py-highlight-line bol (py-point 'eol) file line)
		))
	(when (and py-jump-on-exception line)
	  (ding)
	  (py-jump-to-exception file line)
	  (setq err-p t))
	err-p))


;;; Subprocess commands
(defvar py-exception-buffer nil)
(defconstant py-output-buffer "*Py Output*")


;; todo2 py-toggle-shells
(defun py-toggle-shells ()
	"無くても平気？"
	)



(defvar py-which-bufname "Python")

(defvar py-shell-hook nil
  "*Hook called by `py-shell'.")

(defvar py-shell-map nil
  "Keymap used in *Python* shell buffers.")

(if py-shell-map
	nil
  (progn (require "shell")
	(setq py-shell-map (copy-keymap ed::*shell-mode-map*))
	(define-key py-shell-map #\M-p 'shell-history-previous)
	(define-key py-shell-map #\M-n 'shell-history-next)
	(define-key py-shell-map #\Up 'previous-virtual-line)
	(define-key py-shell-map #\Down 'next-virtual-line)
	(define-key py-shell-map #\RET 'py-shell-send-input)
	(define-key py-shell-map #\C-a 'shell-goto-bol)
	(define-key py-shell-map #\C-r 'shell-history-search-backward)
	(define-key py-shell-map #\C-F6 'py-restart-shell)
	(define-key py-shell-map #\C-F4 'py-quit-shell)
	(define-key py-shell-map '(#\C-c #\C-n) 'comint-next-prompt)
	(define-key py-shell-map '(#\C-c #\C-p) 'comint-previous-prompt)
	(define-key py-shell-map #\M-C-l 'comint-show-output)
	(define-key py-shell-map '(#\C-c #\C-u) 'comint-kill-input)
	;(define-key py-shell-map [tab]   'tab-to-tab-stop)
	;(define-key py-shell-map "\C-c-" 'py-up-exception)
	;(define-key py-shell-map "\C-c=" 'py-down-exception)
	))

;; ** todo0 py-shell
(defun py-shell (&optional argprompt)
  "Start an interactive Python interpreter in another window.
This is like Shell mode, except that Python is running in the window
instead of a shell.  See the `Interactive Shell' and `Shell Mode'
sections of the Emacs manual for details, especially for the key
bindings active in the `*Python*' buffer.

With optional \\[universal-argument], the user is prompted for the
flags to pass to the Python interpreter.  This has no effect when this
command is used to switch to an existing process, only when a new
process is started.  If you use this, you will probably want to ensure
that the current arguments are retained (they will be included in the
prompt).  This argument is ignored when this function is called
programmatically, or when running in Emacs 19.34 or older.

Note: You can toggle between using the CPython interpreter and the
JPython interpreter by hitting \\[py-toggle-shells].  This toggles
buffer local variables which control whether all your subshell
interactions happen to the `*JPython*' or `*Python*' buffers (the
latter is the name used for the CPython buffer).

Warning: Don't use an interactive Python if you change sys.ps1 or
sys.ps2 from their default values, or if you're running code that
prints `>>> ' or `... ' at the start of a line.  `python-mode' can't
distinguish your output from Python's output, and assumes that `>>> '
at the start of a line is a prompt from Python.  Similarly, the Emacs
Shell mode code assumes that both `>>> ' and `... ' at the start of a
line are Python prompts.  Bad things can happen if you fool either
mode.

Warning:  If you do any editing *in* the process buffer *while* the
buffer is accepting output from Python, do NOT attempt to `undo' the
changes.  Some of the output (nowhere near the parts you changed!) may
be lost if you do.  This appears to be an Emacs bug, an unfortunate
interaction between undo and process filters; the same problem exists in
non-Python process buffers using the default (Emacs-supplied) process
filter."
  (interactive "P")
  ;; Set the default shell if not already set
  (when (null py-which-shell)
    (py-toggle-shells py-default-interpreter))
  (let ((args py-which-args))
    (when (and argprompt
	       (interactive-p)
	       (fboundp 'split-string))
      ;; TBD: Perhaps force "-i" in the final list?
      (setq args (split-string
		  (read-string (concat py-which-bufname
				       " arguments: ")
			       (concat
				(mapconcat 'identity py-which-args " ") " ")
			       ))))
    (switch-to-buffer-other-window
		 (progn
			 (get-buffer-create py-which-bufname)
     (make-process *eshell* :output py-which-bufname)
		   (process-send-string (buffer-process (find-buffer py-which-bufname))
				(concatenate 'string
				 py-which-shell " " (mapconcat 'identity args " ") *shell-ret*))
			 (find-buffer py-which-bufname)))
			 (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
    ;(make-local-variable 'comint-prompt-regexp)
    (setq *shell-prompt-regexp* "^>>> \\|^[.][.][.] \\|^(pdb) ")
    ;(add-hook 'comint-output-filter-functions
	  ;    'py-comint-output-filter-function)
    ;; pdbtrack
    ;(add-hook 'comint-output-filter-functions 'py-pdbtrack-track-stack-file)
    ;(setq py-pdbtrack-do-tracking-p t)
    (use-syntax-table *py-mode-syntax-table*)
    (use-keymap py-shell-map)
    (run-hooks 'py-shell-hook)
    ))




;; todo2 py-clear-queue
(defun py-clear-queue ()
	"無くても平気？"
	)

(defun py-execute-file (proc filename)
	(let ((curbuf (selected-buffer))
				(procbuf (process-buffer proc))
				(msg (format nil "## working on region in file ~A"
										 filename))
				(cmd (format nil "execfile(r'~A')\n" filename)))
		(unwind-protect
				(save-excursion
					(set-buffer procbuf)
					(goto-char (point-max))
					(set-marker (process-marker proc) (point))))
		(process-send-string proc cmd)))
					
;; ** todo2 asyncとproc機能が省かれている。
(defun py-execute-region (start end &optional async)
  "Execute the region in a Python interpreter.

The region is first copied into a temporary file (in the directory
						     `py-temp-directory').  If there is no Python interpreter shell
running, this file is executed synchronously using
`shell-command-on-region'.  If the program is long running, use
\\[universal-argument] to run the command asynchronously in its own
buffer.

When this function is used programmatically, arguments START and END
specify the region to execute, and optional third argument ASYNC, if
non-nil, specifies to run the command asynchronously in its own
buffer.

If the Python interpreter shell is running, the region is execfile()'d
in that shell.  If you try to execute regions too quickly,
`python-mode' will queue them up and execute them one at a time when
it sees a `>>> ' prompt from Python.  Each time this happens, the
process buffer is popped into a window (if it's not already in some
					 window) so you can see it, and a comment of the form

\t## working on region in file <name>...

is inserted at the end.  See also the command `py-clear-queue'."
  (interactive "r\nP")
  (or (/= start end)
      (error "Region is empty"))
	(let* ((proc (buffer-process (find-buffer py-which-bufname)))
	 (file (make-temp-file-name nil "py"
				    (or (si:getenv "TEMP")
					(si:getenv "TMP")
					(si:system-root))))
	 (cur (selected-buffer))
	 (encoding (buffer-fileio-encoding cur))
	 (buf (get-buffer-create file))
	 (linenum (save-excursion (goto-char start)(current-line-number))))
    (save-excursion
      (goto-char start)
      (let ((needs-if (/= (py-point 'bol) (py-point 'boi))))
		(set-buffer buf)
		(set-buffer-fileio-encoding encoding)
		(when needs-if (insert "if 1:\n"))
		(insert-buffer-substring cur start end)
		;(save-buffer encoding)
		))
    ; async機能はスキップ。どなたか。
		(cond (async
					 (message "Asynchronous execution not supported yet.")
					 (return-from py-execute-region))
		;output in shell buffer if pyshell is started
					(proc
					 (save-excursion
						 (set-buffer (process-buffer proc))
						 (goto-char (point-max))
						 (insert "\n"))
					 (save-excursion
						 (set-buffer buf)
						 (write-region (point-min) (point-max) file)
						 (py-execute-file proc file))
					 (cond ((get-buffer-window (process-buffer proc))
									(pop-to-buffer (process-buffer proc))
									(goto-char (point-max))
									(recenter)
									(pop-to-buffer cur))
								 (t
									(set-buffer (process-buffer proc))
									(pop-to-buffer cur t)
									(scroll-up-other-window 1000)))
					 ; wait before deleting temp file
					 (sleep-for 0.3))
	  (t
	   (save-excursion
	     (set-buffer buf)
		 ;(call-process "python" :input file)
	     (filter-region py-which-shell (point-min) (point-max))
	     (if (= (point-min) (point-max))
		 (and (find-buffer py-output-buffer)
		      (delete-buffer py-output-buffer))
	       (progn
		 (set-buffer (get-buffer-create py-output-buffer))
		 (delete-region (point-min)(point-max))
		 (insert-buffer buf)
		 (set-buffer-modified-p nil))))
	   (if (= (count-windows) 1) (split-window))
	   (if (not (find-buffer py-output-buffer))
	       (progn (other-window -1)(delete-window)
		 (message "No output."))
	     (progn
	       (setq py-exception-buffer (selected-buffer))
	       (let ((err-p (py-postprocess-output-buffer py-output-buffer linenum)))
		 (pop-to-buffer py-output-buffer t)
		 (if err-p
		     (pop-to-buffer py-exception-buffer t)))))))
    (delete-buffer buf)
    (delete-file file)
    ))

;; todo2 py-execute-regionが対応していないのでasync引数は無効。
(defun py-execute-buffer(&optional async)
  "Send the contents of the buffer to a Python interpreter.
If the file local variable `py-master-file' is non-nil, execute the
named file instead of the buffer's file.

If there is a *Python* process buffer it is used.  If a clipping
restriction is in effect, only the accessible portion of the buffer is
sent.  A trailing newline will be supplied if needed.

See the `\\[py-execute-region]' docs for an account of some
subtleties, including the use of the optional ASYNC argument."
	(interactive "P")
	(if py-master-file
      (let* ((filename (expand-file-name py-master-file))
	     (buffer (or (get-file-buffer filename)
			 (find-file filename))))
	(set-buffer buffer)))
  (py-execute-region (point-min) (point-max) async))

;; ** todo2 py-execute-import-or-reload
(defun py-execute-import-or-reload (&optional async)
  "Import the current buffer's file in a Python interpreter.

If the file has already been imported, then do reload instead to get
the latest version.

If the file's name does not end in \".py\", then do execfile instead.

If the current buffer is not visiting a file, do `py-execute-buffer'
instead.

If the file local variable `py-master-file' is non-nil, import or
reload the named file instead of the buffer's file.  The file may be
saved based on the value of `py-execute-import-or-reload-save-p'.

See the `\\[py-execute-region]' docs for an account of some
subtleties, including the use of the optional ASYNC argument.

This may be preferable to `\\[py-execute-buffer]' because:

 - Definitions stay in their module rather than appearing at top
   level, where they would clutter the global namespace and not affect
   uses of qualified names (MODULE.NAME).

 - The Python debugger gets line number information about the functions."
  (interactive "P")
  ;; Check file local variable py-master-file
  (if py-master-file
      (let* ((filename (find-load-path py-master-file))
             (buffer (or (get-file-buffer filename)
                         (find-file-noselect filename))))
        (set-buffer buffer)))
  (let ((file (get-buffer-file-name (selected-buffer))))
    (if file
        (progn
	  ;; Maybe save some buffers
	  (save-some-buffers py-ask-about-save nil)
          (py-execute-string
           (if (string-match "\\.py$" file)
               (let ((f (pathname-name
																					 (file-namestring file))))
                 (format nil "if globals().has_key('~A'):\n    reload(~A)\nelse:\n    import ~A\n" f f f))
             (format "execfile(r'~A')\n" file))
           async))
      ;; else
      (py-execute-buffer async))))

(defun py-execute-def-or-class (&optional async)
  "Send the current function or class definition to a Python interpreter.

If there is a *Python* process buffer it is used.

See the `\\[py-execute-region]' docs for an account of some
subtleties, including the use of the optional ASYNC argument."
  (interactive "P")
  (save-excursion
    (py-mark-def-or-class)
    ;; mark is before point
    (py-execute-region (mark) (point) async)))

(defun py-execute-string (string &optional async)
  "Send the argument STRING to a Python interpreter.

If there is a *Python* process buffer it is used.

See the `\\[py-execute-region]' docs for an account of some
subtleties, including the use of the optional ASYNC argument."
  (interactive "sExecute Python command: ")
  (save-excursion
    (set-buffer (get-buffer-create " *Python Command*"))
		(delete-region (point-min) (point-max))
    (insert string)
		(py-execute-region (point-min) (point-max) async))
	;; 挙動の違いを修正
	(if (> (count-windows) 1)
			(progn
				(other-window)
	(delete-window)
	(and (find-buffer py-output-buffer)
			 (split-window)
			 (pop-to-buffer py-output-buffer t)))))


(defun py-jump-to-exception (file line)
  "Jump to the Python code in FILE at LINE."
  (let ((buffer (cond ((string-equal file "<stdin>")
		       (if (consp py-exception-buffer)
			   (cdr py-exception-buffer)
			 py-exception-buffer))
		      ((and (consp py-exception-buffer)
			    (string-equal file (car py-exception-buffer)))
		       (cdr py-exception-buffer))
		      ((py-safe (find-file file)))
		      ;; could not figure out what file the exception
		      ;; is pointing to, so prompt for it
		      (t (find-file (read-file-name "Exception file: "
						    nil
						    file t))))))
    (pop-to-buffer buffer)
    ;; Force Python mode
    (if (not (eq buffer-mode 'py-mode))
	(py-mode))
		(goto-line line)
    (message
		 (format nil "Jumping to exception in file ~A on line ~D" file line))))

(defun py-mouseto-exception (event)
	"XEmacsでの挙動が分からないので保留")

(defun py-goto-exception ()
  "Go to the line indicated by the traceback."
  (interactive)
  (let (file line)
    (save-excursion
      (goto-bol)
      (if (looking-at py-traceback-line-re)
	  (setq file (match-string 1)
		line (parse-integer (match-string 2)))))
    (if (not file)
	(error "Not on a traceback line"))
    (py-jump-to-exception file line)))

;; todo2 py-find-next-exception
(defun py-find-next-exception (start buffer searchdir errwhere)
	)

;; todo2 py-down-exception
(defun py-down-exception (&optional bottom)
	)

;; todo2 py-up-exception
(defun py-up-exception (&optional top)
	)

(defun py-electric-backspace (&optional arg)
  "Delete preceding character or levels of indentation.
Deletion is performed by calling the function in `py-backspace-function'
with a single argument (the number of characters to delete).

If point is at the leftmost column, delete the preceding newline.

Otherwise, if point is at the leftmost non-whitespace character of a
line that is neither a continuation line nor a non-indenting comment
line, or if point is at the end of a blank line, this command reduces
the indentation to match that of the line that opened the current
block of code.  The line that opened the block is displayed in the
echo area to help you keep track of where you are.  With
\\[universal-argument] dedents that many blocks (but not past column
													 zero).

Otherwise the preceding character is deleted, converting a tab to
spaces if needed so that only a single column position is deleted.
\\[universal-argument] specifies how many characters to delete;
default is 1.

When used programmatically, argument ARG specifies the number of
blocks to dedent, or the number of characters to delete, as indicated
above."
  (interactive "*p")
  ;; 苦肉の策
  (or arg (setq arg 1))
  (if (or (/= (py-current-indentation) (current-column))
		  (bolp)
		  (py-continuation-line-p)
		  ;	  (not py-honor-comment-indentation)
		  ;	  (looking-at "#[^ \t\n]")	; non-indenting #
		  )
	  (funcall py-backspace-function arg) ;;backward-delete-char-untabify
	;; else indent the same as the colon line that opened the block
	;; force non-blank so py-goto-block-up doesn't ignore it
	(progn
	  (insert #\*)
	  (backward-char)
	  (let ((base-indent 0)		; indentation of base line
			(base-text "")		; and text of base line
			(base-found-p nil))
		(save-excursion
		  (while (< 0 arg)
			(handler-case		; in case no enclosing block
				(progn
				  (py-goto-block-up 'no-mark)
				  (setq base-indent (py-current-indentation)
						base-text   (py-suck-up-leading-text)
						base-found-p t))
			  (error (c) nil))
			(setq arg (1- arg))))
		(delete-char 1)			; toss the dummy character
		(delete-horizontal-spaces)
		(indent-to base-indent)
		(if base-found-p
			(message "Closes block: ~a" base-text))))))

(defun py-electric-delete (&optional arg)
	(interactive "*p")
	(or arg (setq arg 1))
	(py-electric-backspace arg))




(defun py-indent-line (&optional arg)
  "Fix the indentation of the current line according to Python rules.
With \\[universal-argument] (programmatically, the optional argument
ARG non-nil), ignore dedenting rules for block closing statements
[e.g. return, raise, break, continue, pass]

This function is normally bound to `indent-line-function' so
\\[indent-for-tab-command] will call it."
  (interactive "P")
  (let* ((ci (py-current-indentation))
	 (move-to-indentation-p (<= (current-column) ci))
	 (need (py-compute-indentation (not arg)))
         (cc (current-column)))
    ;; dedent out a level unless we're in column 1
    (if (and (equal *last-command* *this-command*)
             (/= cc 0))
        (progn
          (goto-bol)
          (delete-horizontal-spaces)
          (indent-to (* (floor (- cc 1) *py-indent-offset*) *py-indent-offset*)))
      (progn
	;; see if we need to dedent
	(if (py-outdent-p)
	    (setq need (- need *py-indent-offset*)))
	(if (/= ci need)
	    (save-excursion
	      (goto-bol)
	      (delete-horizontal-spaces)
	      (indent-to need)))
	(if move-to-indentation-p (back-to-indentation))))))

(defun py-newline-and-indent ()
  "Strives to act like the Emacs `newline-and-indent'.
This is just `strives to' because correct indentation can't be computed
from scratch for Python code.  In general, deletes the whitespace before
point, inserts a newline, and takes an educated guess as to how you want
the new line indented."
  (interactive)
  (let ((ci (py-current-indentation)))
	(if (< ci (current-column))		; if point beyond indentation
		(progn
		  (newline-and-indent)
		  (py-indent-line))
	  ;; else try to act like newline-and-indent "normally" acts
	  (progn
		(goto-bol)
		(insert #\LFD)
		(goto-column ci)))))


(defun py-compute-indentation (honor-block-close-p)
  "Compute Python indentation.
When HONOR-BLOCK-CLOSE-P is non-nil, statements such as `return',
`raise', `break', `continue', and `pass' force one level of
dedenting."
  (save-excursion
		(goto-bol)
    (let* ((bod (py-point 'bod))
	   (pps (py-parse-partial-sexp bod (point)))
	   (boipps (py-parse-partial-sexp bod (py-point 'boi)))
	   placeholder)
      (cond
       ;; are we inside a multi-line string or comment?
       ((or (and (nth 3 pps) (nth 3 boipps))
	    (and (nth 4 pps) (nth 4 boipps)))
	(save-excursion
	  (if (not py-align-multiline-strings-p) 0
	    ;; skip back over blank & non-indenting comment lines
	    ;; note: will skip a blank or non-indenting comment line
	    ;; that happens to be a continuation line too
	    (progn
		  (py-re-search-backward "^[ \t]*\\([^ \t\n#]\\|#[ \t\n]\\)" nil 'move)
	    (back-to-indentation)
				(current-column)))))
       ;; are we on a continuation line?
			 ((py-continuation-line-p)
	(let ((startpos (point))
	      (open-bracket-pos (py-nesting-level))
	      endpos searching found state)
	  (if open-bracket-pos
	      (progn
		;; align with first item in list; else a normal
		;; indent beyond the line with the open bracket
		(goto-char (1+ open-bracket-pos)) ; just beyond bracket
		;; is the first list item on the same line?
		(skip-chars-forward " \t")
		(if (null (memq (following-char) '(#\LFD #\# #\\)))
					; yes, so line up with it
		    (current-column)
		  ;; first list item on another line, or doesn't exist yet
			(progn
		  (forward-line 1)
		  (while (and (< (point) startpos)
			      (looking-at "[ \t]*[#\n\\\\]")) ; skip noise
		    (forward-line 1))
		  (if (and (< (point) startpos)
			   (/= startpos
			       (save-excursion
				 (goto-char (1+ open-bracket-pos))
				 (py-forward-comment (point-max))
				 (point))))
		      ;; again mimic the first list item
		      (py-current-indentation)
		    ;; else they're about to enter the first item
				(progn
		    (goto-char open-bracket-pos)
		    (setq placeholder (point))
		    (py-goto-initial-line)
		    (py-goto-beginning-of-tqs
		     (save-excursion (nth 3 (py-parse-partial-sexp
					     placeholder (point)))))
				(+ (py-current-indentation) *py-indent-offset*))))))
	    ;; else on backslash continuation line
			(progn
	    (forward-line -1)
	    (if (py-continuation-line-p) ; on at least 3rd line in block
		(py-current-indentation)	; so just continue the pattern
	      ;; else started on 2nd line in block, so indent more.
	      ;; if base line is an assignment with a start on a RHS,
	      ;; indent to 2 beyond the leftmost "="; else skip first
	      ;; chunk of non-whitespace characters on base line, + 1 more
	      ;; column
				(progn
	      (end-of-line)
	      (setq endpos (point)
		    searching t)
	      (back-to-indentation)
	      (setq startpos (point))
	      ;; look at all "=" from left to right, stopping at first
	      ;; one not nested in a list or string
	      (while searching
		(py-skip-chars-forward "^=" endpos)
		(if (= (point) endpos)
		    (setq searching nil)
		  (progn(forward-char 1)
		  (setq state (py-parse-partial-sexp startpos (point)))
		  (if (and (zerop (car state)) ; not in a bracket
			   (null (nth 3 state))) ; & not in a string
		      (progn
			(setq searching nil) ; done searching in any case
			(setq found
			      (not (or
				    (eq (following-char) #\=)
				    (memq (char-after (- (point) 2))
									'(#\< #\> #\!))))))))))
	      (if (or (not found)	; not an assignment
		      (looking-at "[ \t]*\\\\")) ; <=><spaces><backslash>
		  (progn 
		    (goto-char startpos)
		    (skip-chars-forward "^ \t\n")))
	      ;; if this is a continuation for a block opening
	      ;; statement, add some extra offset.
				  
	      (+ (current-column) (if (py-statement-opens-block-p)
				      *py-continuation-offset* 0)
		 1)
				))))))

       ;; not on a continuation line
       ((bobp) (py-current-indentation))
			 
       ;; else indentation based on that of the statement that
       ;; precedes us; use the first line of that statement to
       ;; establish the base, in case the user forced a non-std
       ;; indentation for the continuation lines (if any)
       (t
	;; skip back over blank & non-indenting comment lines note:
	;; will skip a blank or non-indenting comment line that
	;; happens to be a continuation line too.  use fast Emacs 19
	;; function if it's there.
	(if (and (eq py-honor-comment-indentation nil)
		 (fboundp 'forward-comment))
	    (forward-comment (- (point-max)))
	  (let ((prefix-re (concat py-block-comment-prefix "[ \t]*"))
		done)
	    (while (not done)
	      (goto-bol)
	      (py-re-search-backward "^[ \t]*\\([^ \n\t#]\\|#\\)" nil 'move)
				(setq done (or (bobp)
			     (and (eq py-honor-comment-indentation t)
				  (save-excursion
				    (back-to-indentation)
				    (not (looking-at prefix-re))
				    ))
			     (and (not (eq py-honor-comment-indentation t))
				  (save-excursion
				    (back-to-indentation)
				    (and (not (looking-at prefix-re))
					 (or (looking-at "[^#]")
					     (not (zerop (current-column)))
					     ))
				    ))
			     ))
		  )))
	;; if we landed inside a string, go to the beginning of that
	;; string. this handles triple quoted, multi-line spanning
	;; strings.
	(py-goto-beginning-of-tqs (nth 3 (py-parse-partial-sexp bod (point))))
	;; now skip backward over continued lines
	(setq placeholder (point))
	(py-goto-initial-line)
	;; we may *now* have landed in a TQS, so find the beginning of
	;; this string.
	(py-goto-beginning-of-tqs
	 (save-excursion (nth 3 (py-parse-partial-sexp
				 placeholder (point)))))
	(+ (py-current-indentation)
	   (if (py-statement-opens-block-p)
	       *py-indent-offset*
	     (if (and honor-block-close-p (py-statement-closes-block-p))
		 (- *py-indent-offset*)
	       0)))
	)))))


;; todo2 py-guess-indent-offset
(defun py-guess-indent-offset (&optional global)
	"難しそう")

;; todo2 py-comment-indent-function
(defun py-comment-indent-function ()
	"必要かどうかは不明。"
	)

(defun py-narrow-to-defun (&optional class)
  "Make text outside current defun invisible.
The defun visible is the one that contains point or follows point.
Optional CLASS is passed directly to `py-beginning-of-def-or-class'."
  (interactive "P")
  (save-excursion
    (widen)
    (py-end-of-def-or-class class)
    (let ((end (point)))
      (py-beginning-of-def-or-class class)
      (narrow-to-region (point) end))))


(defun py-shift-region-left (start end &optional count)
  "リージョンを左に移動させる。

リージョンの開始点を含む行からリージョンの終点までの行を、
py-indent-offsetぶんだけ左に移動する。

数引数が与えられた場合、その桁数だけ左に移動する。リージョンがない場合
現在行だけ左に移動させる。リージョンのなかにすでに左端によっている行がある
場合はそのリージョンを左に移動させることはできません。"
  (interactive
      (let ((p (point))
	    (m (mark))
	    (arg *prefix-args*))
	(if m
	    (list (min p m) (max p m) arg)
	  (list p (save-excursion (forward-line 1) (point)) arg))))
  ;if any line is at column zero, don't shift the region
  (save-excursion
    (goto-char start)
    (while (< (point) end)
      (back-to-indentation)
      (if (and (zerop (current-column))
	       (not (looking-at "\\s *$")))
	  (progn (message "Region is at left edge")
			(return-from py-shift-region-left)))
			(unless (forward-line 1) (goto-eol))))
	(if (> start end) (rotatef start end))
	(setq last-line-number (save-excursion
													 (goto-char end)
													 (if (bolp)
															 (1- (current-line-number))
														 (current-line-number))))
  (save-excursion
    (shift-region start end (- (prefix-numeric-value
				(or *prefix-value* *py-indent-offset*)))))
  (reverse-region start (save-excursion (goto-line last-line-number) (goto-eol) (point)) t))


(defun py-shift-region-right (start end &optional count)
  (interactive
      (let ((p (point))
	    (m (mark))
	    (arg *prefix-value*))
	(if m
	    (list (min p m) (max p m) arg)
	  (list p (save-excursion (forward-line 1) (point)) arg))))
	(if (> start end) (rotatef start end))
	(setq last-line-number (save-excursion
													 (goto-char end)
													 (if (bolp)
															 (1- (current-line-number))
														 (current-line-number))))
  (save-excursion
    (shift-region start end (prefix-numeric-value
			     (or *prefix-value* *py-indent-offset*))))
	(reverse-region start (save-excursion (goto-line last-line-number) (goto-eol) (point)) t))

(defun py-indent-region (start end &optional indent-offset)
	"使わないみたい")

(defun py-comment-region (start end &optional arg)
  "Like `comment-region' but uses double hash (`#') comment starter."
  (interactive "r\nP")
  (setq comment-start py-block-comment-prefix)
  (setq comment-end "")
  (setq comment-padding 1)
	(if (> start end) (rotatef start end))
	(setq last-line-number (save-excursion
													 (goto-char end)
													 (if (or (bolp)
																	 (< (current-column) (py-current-indentation)))
															 (1- (current-line-number))
														 (current-line-number))))
  (comment-region start end arg)
  (reverse-region start (save-excursion (goto-line last-line-number) (goto-eol) (point)) t))

(defun py-previous-statement (&optional count)
  "Go to the start of the COUNTth preceding Python statement.
By default, goes to the previous statement.  If there is no such
statement, goes to the first statement.  Return count of statements
left to move.  `Statements' do not include blank, comment, or
continuation lines."
  (interactive "p")			; numeric prefix arg
  (setq count (prefix-numeric-value count))
  (if (< count 0) (py-next-statement (- count))
    (progn
      (py-goto-initial-line)
      (let (start)
	(while (and
		(setq start (point))	; always true -- side effect
		(> count 0)
		(eq (forward-line -1) -1)
		(py-goto-statement-at-or-above))
	  (setq count (1- count)))
	(if (> count 0) (goto-char start)))
      count)))

(defun py-next-statement (&optional count)
  "Go to the start of next Python statement.
If the statement at point is the i'th Python statement, goes to the
start of statement i+COUNT.  If there is no such statement, goes to the
last statement.  Returns count of statements left to move.  `Statements'
do not include blank, comment, or continuation lines."
  (interactive "p")			; numeric prefix arg
  (setq count (prefix-numeric-value count))
  (if (< count 0) (py-previous-statement (- count))
    (progn
      (goto-bol)
      (let (start)
	(while (and
		(setq start (point))	; always true -- side effect
		(> count 0)
		(py-goto-statement-below))
	  (setq count (1- count)))
	(if (> count 0) (goto-char start)))
      count)))

(defun py-goto-block-up (&optional nomark)
  "Move up to start of current block.
Go to the statement that starts the smallest enclosing block; roughly
speaking, this will be the closest preceding statement that ends with a
colon and is indented less than the statement you started on.  If
successful, also sets the mark to the starting point.

`\\[py-mark-block]' can be used afterward to mark the whole code
block, if desired.

If called from a program, the mark will not be set if optional argument
NOMARK is not nil."
  (interactive)
  (let ((start (point))
	(found nil)
	initial-indent)
    (py-goto-initial-line)
    ;; if on blank or non-indenting comment line, use the preceding stmt
    (if (looking-at "[ \t]*\\($\\|#[^ \t\n]\\)")
	(progn
	  (py-goto-statement-at-or-above)
	  (setq found (py-statement-opens-block-p))))
    ;; search back for colon line indented less
    (setq initial-indent (py-current-indentation))
    (if (zerop initial-indent)
	;; force fast exit
	(goto-char (point-min)))
    (while (not (or found (bobp)))
      (setq found
	    (and
	     (py-re-search-backward ":[ \t]*\\($\\|[#\\]\\)" nil 'move)
	     (or (py-goto-initial-line) t) ; always true -- side effect
	     (< (py-current-indentation) initial-indent)
	     (py-statement-opens-block-p))))
    (if found
		(progn
		  (or nomark (push-mark start))
		  (back-to-indentation))
	  (progn
		(goto-char start)
		;; ここは(error)でないとpy-electric-backspaceがうまく
		;; 動かなくなる場合がある。[共通設定]から[エラーの表示を
		;; マイルドに]をチェックするとダイアログはでなくなる。
		(error "Enclosing block not found")))))


(defun py-beginning-of-def-or-class (&optional class count)
  (interactive "P")			; raw prefix arg
  (setq count (or count 1))
  (let ((at-or-before-p (<= (current-column) (py-current-indentation)))
				(start-of-line (progn (goto-char (py-point 'bol))(point)))
				(start-of-stmt (progn (goto-char (py-point 'bos))(point)))
	(start-re (cond ((eq class 'either) "^[ \t]*\\(class\\|def\\)\\>")
			(class "^[ \t]*class\\>")
			(t "^[ \t]*def\\>")))
	)
    ;; searching backward
    (if (and (< 0 count)
	     (or (/= start-of-stmt start-of-line)
		 (not at-or-before-p)))
	(end-of-line))
    ;; search forward
    (if (and (> 0 count)
	     (zerop (current-column))
	     (looking-at start-re))
	(end-of-line))
    (if (py-re-search-backward start-re nil 'move count)
				(progn (goto-char (match-beginning 0))(point))
			(progn (goto-char (point-min)) nil))))

(defun py-end-of-def-or-class (&optional class count)
  "Move point beyond end of `def' or `class' body.

By default, looks for an appropriate `def'.  If you supply a prefix
arg, looks for a `class' instead.  The docs below assume the `def'
case; just substitute `class' for `def' for the other case.
Programmatically, if CLASS is `either', then moves to either `class'
or `def'.

When second optional argument is given programmatically, move to the
COUNTth end of `def'.

If point is in a `def' statement already, this is the `def' we use.

Else, if the `def' found by `\\[py-beginning-of-def-or-class]'
contains the statement you started on, that's the `def' we use.

Otherwise, we search forward for the closest following `def', and use that.

If a `def' can be found by these rules, point is moved to the start of
the line immediately following the `def' block, and the position of the
start of the `def' is returned.

Else point is moved to the end of the buffer, and nil is returned.

Note that doing this command repeatedly will take you closer to the
end of the buffer each time.

To mark the current `def', see `\\[py-mark-def-or-class]'."
  (interactive "P")			; raw prefix arg
  (if (and count (/= count 1))
      (py-beginning-of-def-or-class (- 1 count)))
  (let ((start (progn (py-goto-initial-line) (point)))
	(which (cond ((eq class 'either) "\\(class\\|def\\)")
		     (class "class")
		     (t "def")))
	(state 'not-found))
    ;; move point to start of appropriate def/class
    (if (looking-at (concat "[ \t]*" which "\\>")) ; already on one ;X
	(setq state 'at-beginning)
      ;; else see if py-beginning-of-def-or-class hits container
      (if (and (py-beginning-of-def-or-class class)
	       (progn (py-goto-beyond-block)
		 (> (point) start)))
	  (setq state 'at-end)
	;; else search forward
	(progn
	  (goto-char start)
	  (if (py-re-search-forward (concat "^[ \t]*" which "\\>") nil 'move)
	      (progn (setq state 'at-beginning)
		(goto-bol))
	    (progn (goto-char (point-max))
	      (setq state 'not-found))))))
    (cond
     ((eq state 'at-beginning) (py-goto-beyond-block) t)
     ((eq state 'at-end) t)
     ((eq state 'not-found) nil)
     (t (error "Internal error in `py-end-of-def-or-class'")))))


(defun py-mark-block (&optional extend just-move)
  "Mark following block of lines.  With prefix arg, mark structure.
Easier to use than explain.  It sets the region to an `interesting'
block of succeeding lines.  If point is on a blank line, it goes down to
the next non-blank line.  That will be the start of the region.  The end
of the region depends on the kind of line at the start:

- If a comment, the region will include all succeeding comment lines up
to (but not including) the next non-comment line (if any).

- Else if a prefix arg is given, and the line begins one of these
structures:

if elif else try except finally for while def class

the region will be set to the body of the structure, including
following blocks that `belong' to it, but excluding trailing blank
and comment lines.  E.g., if on a `try' statement, the `try' block
and all (if any) of the following `except' and `finally' blocks
that belong to the `try' structure will be in the region.  Ditto
for if/elif/else, for/else and while/else structures, and (a bit
							     degenerate, since they're always one-block structures) def and
class blocks.

- Else if no prefix argument is given, and the line begins a Python
block (see list above), and the block is not a `one-liner' (i.e.,
								the statement ends with a colon, not with code), the region will
include all succeeding lines up to (but not including) the next
code statement (if any) that's indented no more than the starting
line, except that trailing blank and comment lines are excluded.
E.g., if the starting line begins a multi-statement `def'
structure, the region will be set to the full function definition,
but without any trailing `noise' lines.

- Else the region will include all succeeding lines up to (but not
							       including) the next blank line, or code or indenting-comment line
indented strictly less than the starting line.  Trailing indenting
comment lines are included in this case, but not trailing blank
lines.

A msg identifying the location of the mark is displayed in the echo
area; or do `\\[exchange-point-and-mark]' to flip down to the end.

If called from a program, optional argument EXTEND plays the role of
the prefix arg, and if optional argument JUST-MOVE is not nil, just
moves to the end of the block (& does not set mark or display a msg)."
  (interactive "P")			; raw prefix arg
  (py-goto-initial-line)
  ;; skip over blank lines
  (while (and
	  (looking-at "[ \t]*$")	; while blank line
	  (not (eobp)))			; & somewhere to go
    (setq middle (forward-line 1))
    (if middle () (goto-eol)))
  (if (eobp)
      (message "Hit end of buffer without finding a non-blank stmt"))
  (let ((initial-pos (point))
	(initial-indent (py-current-indentation))
	last-pos			; position of last stmt in region
	(followers
	 '(("if" "elif" "else") ("elif" "elif" "else") ("else")
	   ("try" "except" "finally") ("except" "except") ("finally")
	   ("for" "else") ("while" "else")
	   ("def") ("class") ) )
	first-symbol next-symbol)
    (cond
     ;; if comment line, suck up the following comment lines
     ((looking-at "[ \t]*#")
      (py-re-search-forward "^[ \t]*[^ \t#]" nil 'move) ; look for non-comment
      (py-re-search-backward "^[ \t]*#")     ; and back to last comment in block
      (setq last-pos (point)))

     ;; else if line is a block line and EXTEND given, suck up
     ;; the whole structure

     ((and extend
	   (setq first-symbol (string (py-suck-up-first-keyword) ))
	   (assoc first-symbol followers :test #'string=))
      (while (and
	      (or (py-goto-beyond-block) t) ; side effect
	      (forward-line -1)		; side effect
	      (setq last-pos (point))	; side effect
	      (py-goto-statement-below)
	      (= (py-current-indentation) initial-indent)
	      (setq next-symbol (string (py-suck-up-first-keyword)))
	      (member next-symbol (cdr (assoc first-symbol followers :test #'string=)) :test #'string=))
	(setq first-symbol next-symbol)))

     ;; else if line *opens* a block, search for next stmt indented <=

     ((py-statement-opens-block-p)
      (while (and
	      (setq last-pos (point))	; always true -- side effect
	      (py-goto-statement-below)
	      (> (py-current-indentation) initial-indent)
	      )))

     ;; else plain code line; stop at next blank line, or stmt or
     ;; indenting comment line indented <
     (t
      (while (and
	      (setq last-pos (point))	; always true -- side effect
	      (or (py-goto-beyond-final-line) t)
	      (not (looking-at "[ \t]*$")) ; stop at blank line
	      (or
	       (>= (py-current-indentation) initial-indent)
	       (looking-at "[ \t]*#[^ \t\n]"))) ; ignore non-indenting #
	nil)))
    ;; skip to end of last stmt
    (goto-char last-pos)
    (py-goto-beyond-final-line)
    ;; set mark & display
    (if just-move
		()				; just return
	  (progn
		(push-mark (point) 'no-msg)
		(forward-line -1)
		(setq leading-text (py-suck-up-leading-text))
		(goto-char initial-pos)
		(reverse-region (point) (mark) t)
		(message "Mark set after: ~a" leading-text)))))


(defun py-mark-def-or-class (&optional class)
  "Set region to body of def (or class, with prefix arg) enclosing point.
Pushes the current mark, then point, on the mark ring (all language
modes do this, but although it's handy it's never documented ...).

In most Emacs language modes, this function bears at least a
hallucinogenic resemblance to `\\[py-end-of-def-or-class]' and
`\\[py-beginning-of-def-or-class]'.

And in earlier versions of Python mode, all 3 were tightly connected.
Turned out that was more confusing than useful: the `goto start' and
`goto end' commands are usually used to search through a file, and
people expect them to act a lot like `search backward' and `search
forward' string-search commands.  But because Python `def' and `class'
can nest to arbitrary levels, finding the smallest def containing
point cannot be done via a simple backward search: the def containing
point may not be the closest preceding def, or even the closest
preceding def that's indented less.  The fancy algorithm required is
appropriate for the usual uses of this `mark' command, but not for the
`goto' variations.

So the def marked by this command may not be the one either of the
`goto' commands find: If point is on a blank or non-indenting comment
line, moves back to start of the closest preceding code statement or
indenting comment line.  If this is a `def' statement, that's the def
we use.  Else searches for the smallest enclosing `def' block and uses
that.  Else signals an error.

When an enclosing def is found: The mark is left immediately beyond
the last line of the def block.  Point is left at the start of the
def, except that: if the def is preceded by a number of comment lines
followed by (at most) one optional blank line, point is left at the
start of the comments; else if the def is preceded by a blank line,
point is left at its start.

The intent is to mark the containing def/class and its associated
documentation, to make moving and duplicating functions and classes
pleasant."
  (interactive "P")			; raw prefix arg
  (let ((start (point))
	(which (cond ((eq class 'either) "\\(class\\|def\\)")
		     (class "class")
		     (t "def"))))
    (push-mark start)
    (if (not (py-go-up-tree-to-keyword which)) ;;;;;;;debug 70
	(progn
	  (goto-char start)
	  (message "Enclosing ~A not found"
		 (if (eq class 'either)
		     "def or class"
		   which)))
      ;; else enclosing def/class found
      (progn
	(setq start (point))
	(py-goto-beyond-block)
	(push-mark (point))
	(goto-char start)
	(if (eq (forward-line -1) -1)	; if there is a preceding line
		(progn
		  (if (looking-at "[ \t]*$")	; it's blank
			  (setq start (point))	; so reset start point
			(goto-char start))	; else try again
		  (if (eq (forward-line -1) -1)
			  (if (looking-at "[ \t]*#") ; a comment
				  ;; look back for non-comment line
				  ;; tricky: note that the regexp matches a blank
				  ;; line, cuz \n is in the 2nd character class
				  (and
				   (py-re-search-backward "^[ \t]*[^ \t#]" nil 'move)
				   (forward-line 1))
				;; no comment, so go back
				(goto-char start))))))))
  (reverse-region (mark) (point) t))

(defun py-forward-into-nomenclature (&optional arg)
  "Move forward to end of a nomenclature section or word.
With \\[universal-argument] (programmatically, optional argument ARG), 
do it that many times.

A `nomenclature' is a fancy way of saying AWordWithMixedCaseNotUnderscores."
  (interactive "p")
  (let ((*case-fold-search* nil))
    (if (> arg 0)
	(py-re-search-forward
	 "\\(\\W\\|[_]\\)*\\([A-Z]*[a-z0-9]*\\)"
	 (point-max) t arg)
      (while (and (< arg 0)
		  (py-re-search-backward
		   "\\(\\W\\|[a-z0-9]\\)[A-Z]+\\|\\(\\W\\|[_]\\)\\w+"
		   (point-min) 0))
	(forward-char 1)
	(setq arg (1+ arg))))))

(defun py-backward-into-nomenclature (&optional arg)
  "Move backward to beginning of a nomenclature section or word.
With optional ARG, move that many times.  If ARG is negative, move
forward.

A `nomenclature' is a fancy way of saying AWordWithMixedCaseNotUnderscores."
  (interactive "p")
  (py-forward-into-nomenclature (- arg)))

;;; pdbtrack関連

(defun py-pychecker-run (command)
  "*Run pychecker (default on the file currently visited)."
  (interactive
      (let ((default
	     (format nil "~A ~A ~A" py-pychecker-command
		     (mapconcat 'identity py-pychecker-command-args " ")
		     (get-buffer-file-name)))
	    (last (when py-pychecker-history
		    (let* ((lastcmd (car py-pychecker-history))
			   (cmd (cdr (reverse (split-string lastcmd))))
			   (newcmd (reverse (cons (buffer-file-name) cmd))))
		      (mapconcat 'identity newcmd " ")))))

	(list
	 (if (fboundp 'read-shell-command)
	     (read-shell-command "Run pychecker like this: "
				 (if last
				     last
				   default)
				 'py-pychecker-history)
	   (read-string "Run pychecker like this: "
			:default (if last
				     last
				   default)
			:history 'py-pychecker-history))
	 )))
  (save-some-buffers (not py-ask-about-save) nil)
  (execute-shell-command command t "*py compilation*"))


;; An auxiliary syntax table which places underscore and dot in the
;; symbol class for simplicity
(defvar py-dotted-expression-syntax-table nil
  "Syntax table used to identify Python dotted expressions.")
(unless py-dotted-expression-syntax-table
  (setq py-dotted-expression-syntax-table (make-syntax-table))
  (copy-syntax-table *py-mode-syntax-table* py-dotted-expression-syntax-table)
  (set-syntax-symbol py-dotted-expression-syntax-table #\_)
  (set-syntax-symbol py-dotted-expression-syntax-table #\.))

(defun py-symbol-near-point ()
  "Return the first textual item to the nearest point."
  ;; alg stolen from etag.el
  (save-excursion
    (let ((syntab (syntax-table)))
      (use-syntax-table py-dotted-expression-syntax-table)
      (if (or (bobp) (not (or (syntax-word-p (preceding-char))
			      (syntax-symbol-p (preceding-char)))))
	  (while (not (looking-at "\\sw\\|\\s_\\|\\'"))
	    (forward-char 1)))
      (while (looking-at "\\sw\\|\\s_")
	(forward-char 1))
      (prog1 (if (py-re-search-backward "\\sw\\|\\s_" nil t)
		 (progn (forward-char 1)
		   (buffer-substring (point)
				     (progn (forward-sexp -1)
				       (while (looking-at "\\s'")
					 (forward-char 1))
				       (point))))
	       nil)
	(use-syntax-table syntab)))))

(defun py-help-at-point ()
  "Get help from Python based on the symbol nearest point."
  (interactive)
  (let* ((sym (py-symbol-near-point))
	 (base (substring sym 0 (or (progn
				      (string-match "\\..+\\." sym)
				      (match-end 0)) 0)))
	 cmd)
    (if (not (equal base ""))
	;;
	(progn
	  (if (string-match "\\.$" base)
	      (setq base (substring base 0 (1- (length base)))))
	  (setq cmd (concat "import " base "\n"))))
    (setq cmd (concat "import pydoc\n"
		      cmd
		      "try: pydoc.help('" sym "')\n"
		      "except: print 'No help available on:', \"" sym "\""))
    ;(message cmd)
    (py-execute-string cmd)
		(if (find-buffer py-which-bufname)
				(save-excursion
					(let ((curbuf (selected-buffer)))
						(set-buffer (find-buffer py-which-bufname))
						(pop-to-buffer curbuf t))))
    ;; BAW: Should we really be leaving the output buffer in help-mode?
    ;(view-mode)
    ))



(defvar py-parse-state-re
  (concat
   "^[ \t]*\(if\\|elif\\|else\\|while\\|def\\|class\)\\>"
   "\\|"
   "^[^ #\t\n]"))

(defun py-parse-state ()
  "Return the parse state at point (see `parse-partial-sexp' docs)."
  (save-excursion
    (let ((here (point))
	  pps done)
      (while (not done)
	;; back up to the first preceding line (if any; else start of
	;; buffer) that begins with a popular Python keyword, or a
	;; non- whitespace and non-comment character.  These are good
	;; places to start parsing to see whether where we started is
	;; at a non-zero nesting level.  It may be slow for people who
	;; write huge code blocks or huge lists ... tough beans.
	(let ((*case-fold-search* nil))
	  (py-re-search-backward py-parse-state-re nil 'move))
	(goto-bol)
	;; In XEmacs, we have a much better way to test for whether
	;; we're in a triple-quoted string or not.  Emacs does not
	;; have this built-in function, which is its loss because
	;; without scanning from the beginning of the buffer, there's
	;; no accurate way to determine this otherwise.
	(save-excursion (setq pps (py-parse-partial-sexp (point) here)))
	;; make sure we don't land inside a triple-quoted string
	;(setq done (or (not (nth 3 pps))
	(setq done (or (not (eq (parse-point-syntax) :string))
		       (bobp)))
	;; Just go ahead and short circuit the test back to the
	;; beginning of the buffer.  This will be slow, but not
	;; nearly as slow as looping through many
	;; re-search-backwards.
	(if (not done)
	    (goto-char (point-min))))
      pps)))

(defun py-nesting-level ()
  "Return the buffer position of the last unclosed enclosing list.
If nesting level is zero, return nil."
  (let ((status (py-parse-state)))
    (if (zerop (car status))
	nil				; not in a nest
      (car (cdr status)))))		; char# of open bracket

(defun py-backslash-continuation-line-p ()
  "Return t iff preceding line ends with backslash that is not in a comment."
  (save-excursion
    (goto-bol)
    (and
     ;; use a cheap test first to avoid the regexp if possible
     ;; use 'eq' because char-after may return nil
     (eq (py-char-after (- (point) 2)) (char-code #\\))
     ;; make sure; since eq test passed, there is a preceding line
     (forward-line -1)			; always true -- side effect
     (looking-at py-continued-re))))

(defun py-continuation-line-p ()
  "Return t iff current line is a continuation line."
  (save-excursion
    (goto-bol)
    (or (py-backslash-continuation-line-p)
	(py-nesting-level))))

(defun py-goto-beginning-of-tqs (delim)
  "Go to the beginning of the triple quoted string we find ourselves in.
DELIM is the TQS string delimiter character we're searching backwards
for."
  (let ((skip (and delim (make-string 1 #\")))
	(continue t))
    (when skip
      (save-excursion
	(while continue
	  (py-safe (search-backward skip))
	  (setq continue (and (not (bobp))
			      (= (py-char-before) (char-code #\\)))))
	(if (and (= (py-char-before) delim)
		 (= (py-char-before (1- (point))) delim))
	    (setq skip (make-string 3 #\"))))
      ;; we're looking at a triple-quoted string
      (py-safe (search-backward skip)))
    (point)))

(defun py-goto-initial-line ()
  "Go to the initial line of the current statement.
Usually this is the line we're on, but if we're on the 2nd or
following lines of a continuation block, we need to go up to the first
line of the block."
  ;; Tricky: We want to avoid quadratic-time behavior for long
  ;; continued blocks, whether of the backslash or open-bracket
  ;; varieties, or a mix of the two.  The following manages to do that
  ;; in the usual cases.
  ;;
  ;; Also, if we're sitting inside a triple quoted string, this will
  ;; drop us at the line that begins the string.
  (let (open-bracket-pos)
    (while (py-continuation-line-p)
      (goto-bol)
      (if (py-backslash-continuation-line-p)
	  (while (py-backslash-continuation-line-p)
	    (forward-line -1))
	;; else zip out of nested brackets/braces/parens
	(while (setq open-bracket-pos (py-nesting-level))
	  (goto-char open-bracket-pos)))))
  (goto-bol))

(defun py-goto-beyond-final-line ()
  "Go to the point just beyond the fine line of the current statement.
Usually this is the start of the next line, but if this is a
multi-line statement we need to skip over the continuation lines."
  ;; Tricky: Again we need to be clever to avoid quadratic time
  ;; behavior.
  ;;
  ;; XXX: Not quite the right solution, but deals with multi-line doc
  ;; strings
  ;;zip out of tqs. 
  (if (looking-at "[ \t]*\"\"\"")
      (progn
	(search-forward (make-string 3 #\"))
	(goto-char (+ (point) 2))
	(search-forward (make-string 3 #\"))))
  (forward-line 1)
  (while (and (or (py-continuation-line-p)
		  (py-backslash-continuation-line-p))
	      (forward-line 1))))

(defun py-statement-opens-block-p ()
  "Return t iff the current statement opens a block.
I.e., iff it ends with a colon that is not in a comment.  Point should 
be at the start of a statement."
  (save-excursion
    (let ((start (point))
	  (finish (progn (py-goto-beyond-final-line) (1- (point))))
	  (searching t)
	  (answer nil)
	  state)
      (goto-char start)
      (while searching
	;; look for a colon with nothing after it except whitespace, and
	;; maybe a comment
	(if (py-re-search-forward ":\\([ \t]\\|\\\\\n\\)*\\(#.*\\)?$"
			       finish t)
	    (if (eq (point) finish)	; note: no `else' clause; just
					; keep searching if we're not at
					; the end yet
		;; sure looks like it opens a block -- but it might
		;; be in a comment
		(progn
		  (setq searching nil)	; search is done either way
		  (setq state (py-parse-partial-sexp start
						  (match-beginning 0)))
		  (setq answer (not (nth 4 state)))))
	  ;; search failed: couldn't find another interesting colon
	  (setq searching nil)))
      answer)))

(defun py-statement-closes-block-p ()
  "現在pointがある実行文がブロックを閉じるならtを返す。
具体的には、return, raise, break, continue, passで始まる行。This doesn't
catch embedded statements."
  (let ((here (point)))
    (py-goto-initial-line)
    (back-to-indentation)
    (prog1
	(looking-at (concat py-block-closing-keywords-re "\\>"))
      (goto-char here))))

(defun py-goto-beyond-block ()
  "Go to point just beyond the final line of block begun by the current line.
This is the same as where `py-goto-beyond-final-line' goes unless
we're on colon line, in which case we go to the end of the block.
Assumes point is at the beginning of the line."
  (if (py-statement-opens-block-p)
		(py-mark-block nil 'just-move)
    (py-goto-beyond-final-line)))

(defun py-goto-statement-at-or-above ()
  "現在pointがある実行文か、一つ前の実行文のあたまに移動。
次の実行文に当たる文があればtを返す。なければnilを返す。「実行文」に空白行、
コメント、継続文は含みません。"
  (py-goto-initial-line)
  (if (looking-at py-blank-or-comment-re)
      ;; skip back over blank & comment lines
      ;; note:  will skip a blank or comment line that happens to be
      ;; a continuation line too
      (if (py-re-search-backward "^[ \t]*[^ \t#\n]" nil t)
	  (progn (py-goto-initial-line) t)
	nil)
    t))

(defun py-goto-statement-below ()
  "現在pointがある実行文の次の実行文のあたまに移動。
次の実行文に当たる文があればtを返す。なければnilを返す。「実行文」に空白行、
コメント、継続文は含みません。"
  (goto-bol)
  (let ((start (point)))
    (py-goto-beyond-final-line)
    (while (and (or (looking-at py-blank-or-comment-re)
		(py-in-literal))
	    (not (eobp)))
      (if (forward-line 1) () (goto-eol)))
    (if (eobp)
	(progn (goto-char start) nil)
      t)))

(defun py-go-up-tree-to-keyword (key)
  "Go to begining of statement starting with KEY, at or preceding point.
現在、もしくは直前にあり、KEYで始まる実行文(statement)の先頭に移動。

KEY is a regular expression describing a Python keyword.  Skip blank
lines and non-indenting comments.  If the statement found starts with
KEY, then stop, otherwise go back to first enclosing block starting
with KEY.  If successful, leave point at the start of the KEY line and 
return t.  Otherwise, leave point at an undefined place and return nil."
  ;; skip blanks and non-indenting #
  (py-goto-initial-line)
  (while (and
	  (looking-at "[ \t]*\\($\\|#[^ \t\n]\\)")
	  (eq (forward-line -1) -1))	; go back
    nil)
  (py-goto-initial-line)
  (let* ((re (concat "[ \t]*" key "\\b"))
	 (*case-fold-search* nil)		; let* so looking-at sees this
	 (found (looking-at re))
	 (dead nil))
    (while (not (or found dead))
      (handler-case 		; in case no enclosing block
	  (py-goto-block-up 'no-mark)
	(error (c) (setq dead t)))
      (or dead (setq found (looking-at re))))
    (goto-bol)
    found))

(defun py-suck-up-leading-text ()
  "インデントの始まりから行末までの文字列を返す。
行頭に空白があった場合は'...'が頭に追加されます。"
  (save-excursion
    (back-to-indentation)
    (concat
     (if (bolp) "" "...")
     (buffer-substring (point) (progn (end-of-line) (point))))))

(defun py-suck-up-first-keyword ()
  "現在行の最初のキーワードを探して返す。
ここで言う「キーワード」は正規表現[a-z]+と(大体)同じです。見つからなければ
nilを返します。"
  (let ((*case-fold-search* nil))
    (if (looking-at "[ \t]*\\([a-z]+\\)\\b")
	(intern (buffer-substring (match-beginning 1) (match-end 1)))
      nil)))

(defun py-current-defun ()
	"必要なし？"
	)

;; ;; py-shell関連

;; from shell3.l

(setq *shell-prompt-regexp2* "^>>> \\|^[.][.][.] \\|^(Pdb) ")


(defun py-shell-send-input ()
  (interactive)
  (let ((process (buffer-process (selected-buffer)))
	start end prompt)
    (when (and process
	       (eq (process-status process) :run))
      (cond ((>= (point) (marker-point (process-marker process)))
	     (setq start (marker-point (process-marker process)))
	     (setq end (progn (goto-eol) (point))))
	    ((save-excursion
	      (goto-bol)
	      (looking-at *shell-prompt-regexp*))
	     (setq start (match-end 0))
	     (setq end (progn (goto-eol) (point)))
	     (setq prompt (match-string 0)))
	    (t
	     (return-from py-shell-send-input nil)))
      (let ((cmd (buffer-substring start end)))
	(cond ((eobp)
	       (if *shell-echo*
		   (delete-region start end)
		 (insert "\n")))
	      (t
	       (goto-char (point-max))
	       ;(or (bolp)
		 ;  (insert "\n"))
	       ;(and prompt (insert prompt))
	       (unless *shell-echo*
		 (insert cmd "\n"))))
	(set-marker (process-marker process))
	(set-marker comint-last-input-end (point))
	;;; add history
	(when (and cmd
		   (< 0 (length cmd)))
	  (shell-history-save)
	  (shell-history-backward-push cmd))
	(process-send-string process (concatenate 'string cmd *shell-ret*)))))
  (set-goal-column 4))


(defvar *shell-history-backward* nil)
(defvar *shell-history-current* nil)
(defvar *shell-history-forward* nil)

(defun shell-history-save ()
  (let (command)
    (when *shell-history-current*
      (shell-history-backward-push *shell-history-current*)
      (setq *shell-history-current* nil))
    (while (setq command (shell-history-forward-pop))
      (shell-history-backward-push command))))

(defun shell-history-backward-push (command)
  (push (list command) *shell-history-backward*))

(defun shell-history-backward-pop ()
  (car (pop *shell-history-backward*)))

(defun shell-history-forward-push (command)
  (push (list command) *shell-history-forward*))

(defun shell-history-forward-pop ()
  (car (pop *shell-history-forward*)))

(defun shell-history-previous ()
  (interactive)
  (if (not (comint-after-pmark-p))
	 (message "Not at command line"))
  (let ((command (shell-history-backward-pop)))
    (shell-prompt-reset)
    (when *shell-history-current*
      (shell-history-forward-push *shell-history-current*))
    (setq *shell-history-current* command)
    (if command
	(insert command)
      (message "No previous history."))))

(defun shell-history-next ()
  (interactive)
  (if (not (comint-after-pmark-p))
	 (message "Not at command line"))
  (let ((command (shell-history-forward-pop)))
    (shell-prompt-reset)
    (when *shell-history-current*
      (shell-history-backward-push *shell-history-current*))
    (setq *shell-history-current* command)
    (if command
	(insert command)
      (message "No next history."))))

(defun shell-history-search-backward ()
  (interactive)
  (let ((curp (point))
	beg)
    (save-excursion
      (shell-goto-bol)
      (setq beg (point))
      (when (= beg curp)
	(return-from shell-history-search-backward)))
    (do-completion beg curp :list *shell-history-backward*)))

(defun shell-prompt-reset ()
  (let ((curp (point)))
    (save-excursion
      (shell-goto-bol)
      (when (< (point) curp)
	(delete-region (point) curp)))))

(defun shell-goto-bol ()
  (interactive)
  (let ((curp (point)))
    (goto-bol)
    (if (looking-at *shell-prompt-regexp2*)
	(goto-char (match-end 0))
      (goto-char curp))))


;; ;; from comint.el


(defun comint-bol (arg)
  "Goes to the beginning of line, then skips past the prompt, if any.
If prefix argument is given (\\[universal-argument]) the prompt is not skipped. 

The prompt skip is done by skipping text matching the regular expression
`comint-prompt-regexp', a buffer local variable."
  (interactive "P")
  (beginning-of-line)
  (if (null arg) (comint-skip-prompt)))


(defun comint-goto-process-mark ()
  "Move point to the process mark.
The process mark separates output, and input already sent,
from input that has not yet been sent."
  (interactive)
  (let ((proc (or (buffer-process (selected-buffer))
		  (message "Current buffer has no process"))))
    (goto-char (process-marker proc))
    (message "Point is now at the process mark")))


(defun comint-skip-prompt ()
  "Skip past the text matching regexp `comint-prompt-regexp'.
If this takes us past the end of the current line, don't skip at all."
  (let ((eol (save-excursion (goto-eol) (point))))
    (if (and (looking-at *shell-prompt-regexp2*)
	     (<= (match-end 0) eol))
	(goto-char (match-end 0)))))


(defun comint-bol-or-process-mark ()
  "Move point to beginning of line (after prompt) or to the process mark.
The first time you use this command, it moves to the beginning of the line
\(but after the prompt, if any).  If you repeat it again immediately,
it moves point to the process mark.

The process mark separates the process output, along with input already sent,
from input that has not yet been sent.  Ordinarily, the process mark
is at the beginning of the current input line; but if you have
used \\[comint-accumulate] to send multiple lines at once,
the process mark is at the beginning of the accumulated input."
  (interactive)
  (if (not (eq *last-command* 'comint-bol-or-process-mark))
      (comint-bol nil)
    (comint-goto-process-mark)))


(defun comint-next-prompt (&optional n)
  "Move to end of Nth next prompt in the buffer.
See `comint-prompt-regexp'."
  (interactive "p")
  (let ((n (prefix-numeric-value n)))
    ;(if (> n 0) nil (forward-line -1))
    (goto-eol)
    (setq paragraph-start "^>>> \\|^[.][.][.] \\|^(Pdb) ")
    (forward-paragraph n)
    (comint-skip-prompt)))


(defun comint-previous-prompt (&optional n)
  "Move to end of Nth previous prompt in the buffer.
See `comint-prompt-regexp'."
  (interactive "p")
  (let ((n (if (numberp n) n 1)))
    (comint-next-prompt (- n))))


(defun comint-show-output ()
  "Display start of this batch of interpreter output at top of window.
Sets mark to the value of point when this command is run."
  (interactive)
  (push-mark)
  (let ((pos (point)))
    (goto-char (or (marker-point comint-last-input-end) (point-max)))
    (forward-line -1)
    (goto-bol)
    (save-excursion (scroll-window (get-window-line)))
    (comint-skip-prompt)))


(defun comint-kill-input ()
  "Kill all text from last stuff output by interpreter to point."
  (interactive)
  (let ((pmark (process-marker (buffer-process (selected-buffer)))))
    (if (> (point) (marker-point pmark))
	(kill-region pmark (point)))))


(defun comint-after-pmark-p ()
  "Return t if point is after the process output marker."
  (let ((pmark (process-marker (buffer-process (selected-buffer)))))
    (<= (marker-point pmark) (point))))



;; ;; original functions for py-shell

(defun colorize-in-regexp()
  "py-shellバッファを正規表現で色つけ"
  (interactive)
  (let ((*pyshell-regexp-keyword-list*
      (compile-regexp-keyword-list
	 '(("^>>> \\|^[.][.][.] \\|^(Pdb) " nil ((0 . (:color 1))) nil)
	   ("\\(^  File\\|^Traceback (most recent call last)\\).*\\(.*\n\\)+?\\(ArithmeticError\\|AssertionError\\|AttributeError\\|DeprecationWarning\\|EOFError\\|EnvironmentError\\|Exception\\|FloatingPointError\\|FutureWarning\\|IOError\\|ImportError\\|IndentationError\\|IndexError\\|KeyError\\|KeyboardInterrupt\\|LookupError\\|MemoryError\\|NameError\\|NotImplemented\\|NotImplementedError\\|OSError\\|OverflowError\\|OverflowWarning\\|PendingDeprecationWarning\\|ReferenceError\\|RuntimeError\\|RuntimeWarning\\|StandardError\\|StopIteration\\|SyntaxError\\|SyntaxWarning\\|SystemError\\|SystemExit\\|TabError\\|TypeError\\|UnboundLocalError\\|UnicodeDecodeError\\|UnicodeEncodeError\\|UnicodeError\\|UnicodeTranslateError\\|UserWarning\\|ValueError\\|Warning\\|ZeroDivisionError\\): .*" nil ((0 . (:color 3))) nil)
	   ("^[^>]\n\\|^[^>][^>]\n\\|^[^>][^>][^>].*\\|^[^>][^>][^>] .*" nil ((0 . (:color 2))) nil)
	   ))))
    (make-local-variable 'regexp-keyword-list)
    (setq regexp-keyword-list *pyshell-regexp-keyword-list*)))


(defun py-shell-mode()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "pyshell")
  (setq buffer-mode 'py-shell)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^>>> \\|^(Pdb) ")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate "^>>> $")
  (make-local-variable 'comint-last-input-end)
  (setq comint-last-input-end (make-marker))
  (set-marker comint-last-input-end (point-min))
  (let ((*pyshell-keyword-hash-table* (load-keyword-file "py" t)))
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *pyshell-keyword-hash-table*))
  (colorize-in-regexp)
  (refresh-screen t))

(add-hook 'ed::py-shell-hook 'py-shell-mode)


(defun py-restart-shell ()
  "py-shellを再実行。"
  (interactive)
  (let ((proc (buffer-process (selected-buffer)))
	  (window-count (count-windows)))
    (save-restriction
	(kill-process proc)
        (insert "\n=========RESTART=========\n")
      (sleep-for 0.15)
        (other-window)
      (py-shell)
      (if (= window-count 1) (delete-window))
      (goto-char (point-max)))))

(defun py-quit-shell ()
  "py-shellを終了"
  (interactive)
  (let ((proc (buffer-process (selected-buffer))))
    (kill-process proc)
    (sleep-for 0.15)
    (kill-buffer (selected-buffer))
		(if (not (eq (count-windows) 1))
				(delete-window))))

(defun py-describe-mode ()
  (interactive)
  (let ((buf (selected-buffer))
		(hbuf (switch-to-buffer "*Help*")))
	(set-buffer hbuf)
	(erase-buffer hbuf)
	(insert "@ 設定・カスタマイズ

.xyzzyやsiteinit.lに

\(setq ed::py-align-multiline-strings-p nil\)

のように\(setq ed::変数名 値\)と書き加えることによって設定を変えることが
できます。設定できる変数はpy-mode.lの設定用変数部分や下記のヘルプを参照
してください。


@ 自動インデント

py-modeはユーザーがインデントのことを考えなくていいよう
に出来るかぎり自動的に処理します。

RET py-newline-and-indent
改行したあと自動的に必要と思われる量のインデントを行います。インデント方
法は変数*py-indent-offset*で変えることができます。デフォルトではスペース
四つです。継続行で改行すると継続が始まった場所\(開き括弧など\)に応じてイ
ンデントされます。継続する行が継続される行に対してどれだけインデントする
かは変数*py-continuation-offset*で変えることができます。デフォルトではス
ペース四つです。コメント行には行の頭にシャープ二個がある「完全な」コメン
ト行と、それ以外の「普通の」コメント行があります。この「普通の」コメント
行が次の行のインデントに影響を与えるかを変数py-honor-comment-indentation
で変えることができます。py-honor-comment-indentationがnilなら「普通の」
コメント行はその後にくる行のインデントには影響しません。tならば「普通の」
コメント行はその後の行のインデントに影響を与えます。デフォルトではtです。
三重引用符内の文字列をインデントするかは変数py-align-multiline-strings-p
で変えることができます。tならインデントする、nilならば全くインデントせず、
左端に寄せます。デフォルトではtです。

TAB py-indent-line
現在ポイントがある行のインデントを補正します。

:\(コロン\) py-electric-colon
コロンを挿入して、必要があれば行を逆インデント\(左にずらす\)します。

BACKSPACE py-electric-backspace
ポイントが継続行でも、インデントされていないコメント行でもない行の左端の
文字上にあるか、もしくは空白文字だけの行にある場合、ポイントがあるブロックを
閉じるように空白を削除します。どのブロックを閉じたかはステータス部分に表示
されます。
それ以外の場合は普通のバックスペースと同じ\(backward-delete-char-untabify\)を
実行します。


@ 範囲選択

特定の範囲をリージョン指定する\(マークする\)ことができます。マ
ークした範囲はpy-shift-region-*で左右にシフトする、py-comment-regionで一
気にコメントアウトする、py-execute-regionで実行するといった操作をサポー
トします。

M-C-h py-mark-def-or-class
ポイントを含む最小のdef文全体をマークします。もしdef文がみつかれば、def
文全体がリージョンとなるようにポイントはdef文の最後に移動し、マークがdef
文の先頭につけられます。ただし、直前、もしくは一行の空行をはさんでコメン
ト行のブロックがある場合は、そのコメントブロックの頭にマークをつけます。

C-c C-k py-mark-block
現在いる行以降の「ブロック」をマークする。「ブロック」の範囲はこの
py-mark-blockがどんな行で実行したかに依存します。実行した行が

-コメント行なら、コメント行でない行までが「ブロック」になります。

-[if, elif, else, try, except, finally, for, while, def, class]のいずれか
の「ブロック」キーワードで始まる行で、かつuniversal-argumentが\(C-u C-c 
C-k\)ある場合、その行に属すると思われる部分全体が「ブロック」になります。
つまりifで始まる行であれば、そのifに属すると思われるすべてのelif/elseが
「ブロック」としてマークされます。try/except/finally、while/elseなども同
じように全体がリージョンとしてマークされます。

-上記の「ブロック」キーワードで始まる行で、かつuniversal-argumentが与えら
れていなければ、その行よりも深くインデントされた部分が「ブロック」になり
ます。ただし、ブロックの最後にあるコメント行や空行は無視されます。

-上記のいずれでもない場合は次の空行か、実行した行よりも浅くインデントされ
た行までが「ブロック」になります。この場合は、ブロックの最後にある空行は
無視されますが、コメント行は無視されません。


@ コメントアウト

C-c # py-comment-region
リージョンをコメントアウトします。コメント文字列は'##'です。この変数は変
えない方が無難かと思いますが、変数py-block-comment-prefixで変えることも
できます。py-comment-regionはリージョン内の行頭に'## '\(シャープ・シャー
プ・スペース\)を挿入することでリージョンをコメントアウトします。空行は無
視されます。
-universal-argumentに数引数が与えられた場合\(C-u 2 C-c #\)、変数
py-block-comment-prefixを指定された回数だけ連続で挿入してコメントアウト
します。上記の例では'#### 'が行頭に挿入されます。この場合も空行は無視さ
れます。
-universal-argumetが与えられた場合\(C-u C-c #\)はアンコメント、つまりコ
メントをはずします。リージョン内にある、'##'で始まるすべての行のコメント
をはずします。シャープが一個だけの行や、ダブルシャープが行頭ではないとこ
ろにあるような行は無視されます。また、空行も無視されます。
universal-argumentで数を指定して\(C-u 2 C-c #\)コメントアウトされた行、
つまり行頭に偶数個のシャープが連続してある場合は一気にすべてのコメントを
はずすことができます。


@ 範囲シフト

C-c C-r py-shift-region-right
リージョンを変数py-indent-offsetの量だけ右にシフトします。
universal-argumentを与えると\(C-u 8 C-c C-r\)その量だけ右にシフトします。

C-c C-l py-shift-region-left
リージョンを変数py-indent-offsetの量だけ左にシフトします。リージョン内に
ある行のどれかがすでに左端によっていればエラーを出し、何も操作はしません。
-universal-argumentを与えると\(C-u 8 C-c C-r\)その量だけ左にシフトします。
-すでに左端に寄っている行がある場合はエラーを出して何も操作はしません。
-そうでない場合は、リージョンの内の各行を指定された量だけシフトします。
-もしシフトする量がインデント量よりも多く、途中で左端に寄ってしまった行が
あってもエラーを出さずに次の行をシフトします。


@ カーソル\(ポイント\)移動

C-c C-n py-next-statement
一つ前のステートメントに移動。ステートメントとは空行、コメント行、継続行 
「以外」の行のことです。

C-c C-p py-previous-statement
一つ後のステートメントに移動。

M-C-a py-beginning-of-def-or-class
defブロックの先頭に移動します。ただし、ポイントがdef文の'd'にある時は一
つ前のdefに移動します。universal-argumentを与えると\(C-u M-C-a\)defでは
なくclassに移動します。

M-C-e py-end-of-def-or-class
現在行がdef文の場合はそのdefの最後に移動します。def文でない場合は
py-beginning-of-def-or-classで見つかったdef文の最後に移動します。それで
も見つからなかった場合は現在行よりも後にあるdef文の最後に移動します。
universal-argumentを与えると\(C-u M-C-e\)defではなくclassの最後に移動し
ます。

C-c C-u py-goto-block-up
現在行よりも浅くインデントされていて、コロン\(:\)で終わる行まで戻ります。


@ 簡易シェル

C-c ! py-shell
対話式pythonシェルを起動します。C-F4で終了します。shellバッファでの
キーバインドは以下の通りです。

M-p, M-n shell-history-previous/next
ポイントがコマンドライン上\(入力待ち状態になっている最後のプロンプトのあ
る行\)にある時、これまで実行したコマンドの履歴を挿入します。
shell-history-previousは実行した履歴を後ろに戻ります。shell-history-next
は前に進みます。、ポイントがコマンドライン上にない場合はエラーを出して、
何も操作はしません。

RET py-shell-send-input
ポイントがコマンドライン上にある場合はそのコマンドを実行します。ポイント
が以前に実行したコマンド上にある場合、そのコマンドを再び実行します。

C-a shell-goto-bol
ポイントがコマンドライン上にある場合、ポイントを行頭に持って行きます。

C-r shell-history-search-backward
入力済みの文字列にマッチするコマンド履歴を検索します。print 'a'という入
力履歴があれば'p'と入力した後C-rを押せば'p'からはじまる履歴が選択されま
す。

C-F6 py-restart-shell
Pythonシェルを再起動します。それまでimportしたモジュールや変数はクリアさ
れます。

C-F4 py-quit-shell
pythonシェルを終了、pythonシェルバッファを閉じます。

C-c C-p, C-c C-n comint-previous/next-prompt
現在いる行より一つ前、一つ後ろのプロンプトに移動します。

M-C-l comint-show-output
最後の出力の先頭を画面の最上部に表示します。出力が長すぎて確認できない場
合などに使います。

C-c C-u comint-kill-input
ポイントがコマンドライン上にある場合、プロンプト以降に入力した文字列を
削除します。

[注] オリジナルのpython-mode.elはcomintという機能を使ってコマンドの履歴
などを表示させますが、comint.el全体を移植する必要はないと判断して機能の
一部だけを移植しました。またshell3.lのコードも一部に使われています。現時
点ではemacsのpy-shellを完全再現することはできていません。


@ Python文の評価・実行 \(移植率80%くらい。\)

C-c | py-execute-region
指定したリージョンを実行します。結果が別バッファに表示されます。py-shell
バッファがあるときはそちらに表示します。実行処理をスタックしたり、
非同期で実行することはできません。

C-c C-s py-execute-string 
ミニバッファプロンプトで指定したpythonコードを実行します。

C-c C-e py-execute-buffer
現在のバッファ内容を実行します。py-shellバッファがあるときはそちらに表示します。


@ Pydocによる簡易ヘルプ
C-c C-h py-help-at-point 
http://www.python.org/doc/current/download.htmlからHTML Documentationを
ダウンロードして展開します。つぎに環境変数PYTHONDOCSをつくり、その値を
index.htmlがあるフォルダにセットします。Windowsを再起動後、
py-help-at-point\(C-c C-h\)でpydocによるヘルプを見ることが出来ます。")
	(goto-char (point-min))
	(make-local-variable 'need-not-save)
	(setq need-not-save t)
	(set-buffer buf)
	(pop-to-buffer hbuf t)))


(defun py-build-summary-of-functions ()
  (let ((result nil))
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "^[ \t]*\\(class .*\\|def .*\\):"
													:regexp t :case-fold t :tail t)
		(setq actual-indent-amount (/ (save-excursion
						  (goto-bol)
						  (back-to-indentation)
						  (current-column)) *py-indent-offset*))
		(setq indent (make-vector actual-indent-amount
								  :element-type 'character
								  :initial-element #\ ))
		(push (list (current-line-number) (concat indent (match-string 1))) result)))
    (nreverse result)))
