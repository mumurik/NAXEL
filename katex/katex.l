;;; -*- Lisp; syntax: Common-Lisp -*-
;;; Yet Another tex-mode for xyzzy - //花鳥//
;;; katex.l, v 1.67.1.11+1.0
;;; modified by mumurik765
;;; fixed by Maeda Manabu
;;; Last fixed  "Thu Oct 14 2004 23:21:33 +0900"

;;; -*- Emacs-Lisp -*-
;;; Yet Another tex-mode for emacs - //野鳥//
;;; yatex.el rev. 1.67
;;; (c ) 1991-1999 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Tue Jul 13 14:20:45 1999 on firestorm
;;; $Old-Id: yatex.el,v 1.67 1999/07/15 04:58:48 yuuji Rel $
;;; The latest version of this software is always available at;
;;; http://www.yatex.org/

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Software Foundation Inc., 59 Temple Place - Suite 330, Boston, MA
;; 02111-1307, USA.

(provide "katex")

(in-package "elisp")

(require "emacs")
(require "comment")
(require "katexlib")
(require "katexprc")
(require "katexbar")

(defconstant KaTeX-revision-number "1.67.1.11"
  "Revision number of running katex.l")

;---------- Local variables ----------
(defvar *KaTeX-prefix* #\C-c
  "*Prefix key to call KaTeX functions.
You can select favorite prefix key by setq in your ~/.xyzzy")

(defvar KaTeX-environment-indent 1
  "*Indentation depth at column width in LaTeX environments.")

(defvar KaTeX-fill-prefix nil
  "*fill-prefix used for auto-fill-mode.
The default value is nil.")

(defvar KaTeX-fill-column 72
  "*fill-column used for auto-fill-mode.")

(defvar KaTeX-comment-prefix "%"
  "TeX comment prefix.")

(defvar KaTeX-current-position-register #\3
  "*Position register to keep where the last completion was done.
All of KaTeX completing input store the current position into
the register KaTeX-current-position-register.  So every time you
make a trip to any other part of text other than you are writing, you can
return to the editing paragraph by calling register-to-point with argument
KaTeX-current-position-register.")

;;(defvar KaTeX-tmp-dic-unit 'main-file
;;  "*Default switching unit of temporary dictionary.
;;There are two switching unit:
;;'main-file	: switch tmp-dic according to main-file directory.
;;'directory	: switch tmp-dic dir by dir."
;;)
(defvar tex-command (if KaTeX-japan "jlatex" "latex")
  "*Default command for typesetting LaTeX text.")

(defvar bibtex-command (if KaTeX-japan "jbibtex" "bibtex")
  "*Default command of BibTeX.")

(defvar dvi2-command "dviout -wait=0"  	;previewer command for your site
  "*Default previewer command including its option.")

(defvar makeindex-command "makeindex"
  "*Default makeindex command.")

(defvar dviprint-command-format "dviprt %s %f%t"
  "*Command line string to print out current file.
Format string ~A will be replaced by the filename.  Do not forget to
specify the `from usage' and `to usage' with their option by format string
%f and %t.
  See also documentation of dviprint-from-format and dviprint-to-format.")

(defvar dviprint-from-format "%b-"
  "*`From' page format of dvi filter.  %b will turn to beginning page number.")

(defvar dviprint-to-format "%e"
  "*`To' page format of dvi filter.  %e will turn to end page number.")

(defvar KaTeX-default-document-style
  (concat (if KaTeX-japan "j" "") "article")
  "*Default LaTeX Documentstyle for KaTeX-typeset-region.")

(defvar KaTeX-need-nonstop nil
  "*T for adding `\\nonstopmode{}' to text before invoking latex command.")

(defvar latex-warning-regexp "line.* [0-9]*"
  "*Regular expression of line number of warning message by latex command.")

(defvar latex-error-regexp "l\\.[1-9][0-9]*"
  "*Regular expression of line number of latex error.
Perhaps your latex command stops at this error message with line number of
LaTeX source text.")

(defvar latex-dos-emergency-message
  "Emergency stop"      ;<- for Micro tex, ASCII-pTeX 1.6
  "Message pattern of emergency stop of typesetting.
Because Demacs (GNU Emacs on DOS) cannot have concurrent process, the
latex command which is stopping on a LaTeX error, is terminated by Demacs.
Many latex command on DOS display some messages when it is terminated by
other process, user or OS.  Define to this variable a message string of your
latex command on DOS shown at abnormal termination.
  Remember Demacs's call-process function is not oriented for interactive
process.")

(defvar latex-message-kanji-code 2
  "*Kanji coding system latex command types out.
1 = Shift JIS, 2 = JIS, 3 = EUC.")

(defvar NTT-jTeX nil
  "*T for using NTT-jTeX for latex command.
More precisely, setting t to this variables inhibits inter-word break on
typeset document by line-break of source text.  That is, KaTeX automatically
put % after each line at filling.
改行+インデントによって、タイプセット後の字間が空いてしまうのを抑制する場合に
tにする(古いNTT-jTeXで顕著に現れる)。具体的には、fillするときに各行の終わりに
%を付加する。")

(defvar KaTeX-item-regexp
  (concat (regexp-quote "\\") "\\(sub\\|bib\\)*item")
  "*Regular expression of item command.")

(defvar KaTeX-sectioning-regexp
  "\\(part\\|chapter\\*?\\|\\(sub\\)*\\(section\\|paragraph\\)\\)\\(\\*\\|\\b\\)"
  "*LaTeX sectioning commands regexp.")

(defvar KaTeX-paragraph-start
  (concat "^[ \t]*%\\|^[ \t]*$\\|\\'\\|^\C-l\\|\\\\\\\\$\\|^[ \t]*\\\\\\("
	  KaTeX-sectioning-regexp		;sectioning commands
	  "\\|[A-z]*item\\|begin{\\|end{"	;special declaration
	  "\\|newpage\\b\\|vspace\\b"
	  "\\)")
  "*Paragraph starting regexp of common LaTeX source.  Use this value
for KaTeX-uncomment-paragraph.")

(defvar KaTeX-paragraph-separate
  (concat "^[ \t]*%\\|^[ \t]*$\\|^\C-l\\|\\\\\\\\$\\|^[ \t]*\\\\\\("
	  KaTeX-sectioning-regexp		;sectioning commands
	  "\\|begin{\\|end{"			;special declaration
	  "\\|\\[\\|\\]"
	  "\\|newpage\\b\\|vspace\\b"
	  "\\)")
  "*Paragraph delimiter regexp of common LaTeX source.  Use this value
for KaTeX-uncomment-paragraph.")

(defvar KaTeX-verbatim-environments 
  '("verbatim" "verbatim*")
  "*Assume these environments of this variable disable LaTeX commands.")
(defvar KaTeX-verb-regexp "verb\\*?\\|path"
  "*Regexp of verb family.  Do not contain preceding \\\\ nor \\(\\).")
(defvar KaTeX-fill-inhibit-environments
  (append '("tabular" "tabular*" "array" "picture" "eqnarray" "eqnarray*"
	    "equation" "equation*" "math" "displaymath")
	  KaTeX-verbatim-environments)
  "*In these environments, KaTeX inhibits fill-paragraph from formatting.
Define those environments as a form of list.")

(defvar KaTeX-itemizing-env-regexp
  "itemize\\|enumerate\\|description\\|list\\|thebibliography"
  "*Regexp of itemizing environments")
(defvar KaTeX-equation-env-regexp
  "array\\*?\\|equation\\*?"
  "*Regexp of environments for equations")
(defvar KaTeX-array-env-regexp
  (concat
   "array\\*?\\|eqnarray\\*?\\|tabbing\\|tabular\\*?\\|"	;LaTeX
   "matrix\\|pmatrix\\|bmatrix\\|vmatrix\\|Vmatrix\\|"		;AMS-LaTeX
   "align\\*?\\|split\\*?\\|aligned\\*?\\|alignat\\*?\\|"	;AMS-LaTeX
   "[bpvV]?matrix\\|smallmatrix\\|cases\\|"			;AMS-LaTeX
   "xalignat\\*?\\|xxalignat\\*?")				;AMS-LaTeX
  "*Regexp of environments where `&' becomes field delimiter.")
(defvar KaTeX-uncomment-once t
  "*T for removing all continuous commenting character(%).
Nil for removing only one commenting character at the beginning-of-line.")

(defvar KaTeX-close-paren-always t
  "*Close parenthesis always when KaTeX-modify-mode is nil.")

(defvar KaTeX-greek-by-maketitle-completion nil
  "*T for greek letters completion by maketitle-type completion.")

(defvar KaTeX-auto-math-mode t
  "*T for changing KaTeX-math mode automatically.")
(defvar KaTeX-use-AMS-LaTeX nil
  "*T for using AMS-LaTeX")

(defvar katex-mode-hook nil
  "*List of functions to be called at the end of katex-mode initializations.")

;;-- Math mode values --

(defvar KaTeX-math-key-list-default
  '((#\; . KaTeX-math-sign-alist)
    (#\: . KaTeX-greek-key-alist))
  "Default key sequence to invoke math-mode's image completion.")

(defvar KaTeX-math-key-list-private nil
  "*User defined alist, math-mode-prefix vs completion alist.")

(defvar KaTeX-math-key-list
  (append KaTeX-math-key-list-private KaTeX-math-key-list-default)
  "Key sequence to invoke math-mode's image completion.")

(defvar KaTeX-skip-default-reader nil
  "Non-nil skips default argument reader of section-type completion.")

(defvar KaTeX-simple-messages nil
  "Non-nil makes minibuffer messages simpler.")

(defvar KaTeX-template-file "~/work/template.tex"
  "*Template TeX source file.  This will be inserted to empty file.")

(defvar KaTeX-addin-prefix "KaTeX-")
;------------ Completion table ------------
; Set tex-section-like command possible completion
(defvar section-table
  '(("part") ("chapter") ("section") ("subsection")
    ("subsubsection") ("paragraph") ("subparagraph")
    ("author") ("thanks") ("documentstyle") ("documentclass") ("pagestyle")
    ("title") ("underline") ("label") ("makebox")
    ("footnote") ("footnotetext")
    ("hspace*") ("vspace*") ("bibliography") ("bibitem") ("cite")
    ("input") ("include") ("includeonly") ("mbox") ("hbox") ("caption")
    ("newlength") ("setlength" 2) ("addtolength" 2) ("settowidth" 2)
    ("setcounter" 2) ("addtocounter" 2) ("stepcounter" 2)
    ("newcommand" 2) ("renewcommand" 2)
    ("setcounter" 2) ("newenvironment" 3) ("newtheorem" 2)
    ("cline") ("framebox") ("savebox" 2) ("sbox" 2) ("newsavebox") ("usebox")
    ("date") ("put") ("ref") ("pageref")
    ("multicolumn" 3) ("shortstack")
    ;; for mathmode accent
    ("tilde") ("hat") ("check") ("bar") ("dot") ("ddot") ("vec")
    ("widetilde") ("widehat") ("overline") ("overrightarrow")
    ;; section types in mathmode
    ("frac" 2) ("sqrt") ("mathrm") ("mathbf") ("mathit")
    )
  "Default completion table for section-type completion.")

(defvar user-section-table nil)
(defvar tmp-section-table nil)

; Set tex-environment possible completion
(defvar env-table
  '(("quote") ("quotation") ("center") ("verse") ("document")
    ("verbatim") ("itemize") ("enumerate") ("description")
    ("list") ("tabular") ("tabular*") ("table") ("tabbing") ("titlepage")
    ("sloppypar") ("quotation") ("picture") ("displaymath")
    ("eqnarray") ("figure") ("equation") ("abstract") ("array")
    ("thebibliography") ("theindex") ("flushleft") ("flushright")
    ("minipage")
    )
  "Default completion table for begin-type completion.")

(defvar user-env-table nil)
(defvar tmp-env-table nil)

; Set {\Large }-like completion
(defvar fontsize-table
  '(("rm") ("em") ("bf") ("boldmath") ("it") ("sl") ("sf") ("sc") ("tt")
    ("dg") ("dm")
    ("tiny") ("scriptsize") ("footnotesize") ("small")("normalsize")
    ("large") ("Large") ("LARGE") ("huge") ("Huge")
    )
  "Default completion table for large-type completion.")

(defvar user-fontsize-table nil)
(defvar tmp-fontsize-table nil)

(defvar singlecmd-table
  (append
   '(("maketitle") ("makeindex") ("sloppy") ("protect")
     ("LaTeX") ("TeX") ("item") ("item[]") ("appendix") ("hline")
     ;;("rightarrow") ("Rightarrow") ("leftarrow") ("Leftarrow")
     ("pagebreak") ("nopagebreak")
     ("newpage") ("clearpage") ("cleardoublepage")
     ("footnotemark") ("verb") ("verb*")
     ("linebreak") ("noindent") ("indent")
     ("left") ("right") ("dots")
     )
   (if KaTeX-greek-by-maketitle-completion
       '(("alpha") ("beta") ("gamma") ("delta") ("epsilon")
	 ("varepsilon") ("zeta") ("eta") ("theta")("vartheta")
	 ("iota") ("kappa") ("lambda") ("mu") ("nu") ("xi") ("pi")
	 ("varpi") ("rho") ("varrho") ("sigma") ("varsigma") ("tau")
	 ("upsilon") ("phi") ("varphi") ("chi") ("psi") ("omega")
	 ("Gamma") ("Delta") ("Theta") ("Lambda")("Xi") ("Pi")
	 ("Sigma") ("Upsilon") ("Phi") ("Psi") ("Omega"))))
  "Default completion table for maketitle-type completion.")

(defvar user-singlecmd-table nil)
(defvar tmp-singlecmd-table nil)

;---------- Key mode map ----------
;;;
;; Create new key map: KaTeX-mode-map
;; Do not change this section.
;;;
(defvar *KaTeX-mode-map* nil
  "Keymap used in KaTeX mode")

(defvar *KaTeX-prefix-map* nil
  "Keymap used when *KaTeX-prefix* key pushed")

(defvar KaTeX-user-extensional-map (make-sparse-keymap)
  "*Keymap used for the user's customization")
(defvar KaTeX-current-completion-type nil
  "Has current completion type.  This may be used in KaTeX addin functions.")

(defvar KaTeX-modify-mode nil
  "*Current editing mode.
When non-nil, each opening parentheses only opens,
nil enters both open/close parentheses when opening parentheses key pressed.")

(defvar KaTeX-math-mode nil
  "Holds whether current mode is math-mode.")
;;;
;; Define key table
;;;
(unless *KaTeX-mode-map*
  (setq *KaTeX-mode-map* (make-sparse-keymap))
  (setq *KaTeX-prefix-map* (make-sparse-keymap))
  (define-key *KaTeX-mode-map* #\" 'KaTeX-insert-quote)
  (define-key *KaTeX-mode-map* #\{ 'KaTeX-insert-braces)
  (define-key *KaTeX-mode-map* #\( 'KaTeX-insert-parens)
  (define-key *KaTeX-mode-map* #\$ 'KaTeX-insert-dollar)
  (define-key *KaTeX-mode-map* #\| 'KaTeX-insert-bar)
  (define-key *KaTeX-mode-map* #\& 'KaTeX-insert-amper)
  (define-key *KaTeX-mode-map* #\[ 'KaTeX-insert-brackets)
  (define-key *KaTeX-mode-map* *KaTeX-prefix* *KaTeX-prefix-map*)
  (define-key *KaTeX-mode-map* #\M-C-@ 'KaTeX-mark-environment)
  (define-key *KaTeX-mode-map* #\M-C-a 'KaTeX-beginning-of-environment)
  (define-key *KaTeX-mode-map* #\M-C-e 'KaTeX-end-of-environment)
  (define-key *KaTeX-mode-map* #\M-C-m 'KaTeX-intelligent-newline)
  (define-key *KaTeX-mode-map* #\C-i 'KaTeX-indent-line)
  (KaTeX-define-key #\% 'KaTeX-%-menu)
  (KaTeX-define-key #\t 'KaTeX-typeset-menu)
  (KaTeX-define-key #\w 'KaTeX-switch-mode-menu)
  (KaTeX-define-key #\' 'KaTeX-prev-error)
  (KaTeX-define-key #\^ 'KaTeX-visit-main)
  (KaTeX-define-key '(#\4 #\^) 'KaTeX-visit-main-other-window)
  (KaTeX-define-key '(#\4 #\g) 'KaTeX-goto-corresponding-*-other-window)
;m.m    (KaTeX-define-key '(#\4 #\4) 'KaTeX-switch-to-window)
;  (and KaTeX-emacs-19 window-system
;       (progn
;	 (KaTeX-define-key '(#\5 #\^) 'KaTeX-visit-main-other-frame)
;	 (KaTeX-define-key '(#\5 #\g) 'KaTeX-goto-corresponding-*-other-frame)
;m.m	 (KaTeX-define-key '(#\5 #\5) 'KaTeX-switch-to-window)
;       ))
  (KaTeX-define-key #\SPC 'KaTeX-do-completion)
  (KaTeX-define-key #\v 'KaTeX-version)

  (KaTeX-define-key #\} 'KaTeX-insert-braces-region)
  (KaTeX-define-key #\] 'KaTeX-insert-brackets-region)
  (KaTeX-define-key #\) 'KaTeX-insert-parens-region)
  (KaTeX-define-key #\$ 'KaTeX-insert-dollars-region)
  (KaTeX-define-key #\i 'KaTeX-fill-item)
  (KaTeX-define-key
   #\\ '(lambda () (interactive) (insert "$\\backslash$")))
  (if KaTeX-no-begend-shortcut
      (progn
	(KaTeX-define-key #\B 'KaTeX-make-begin-end-region)
	(KaTeX-define-key #\b 'KaTeX-make-begin-end))
    (progn
      (KaTeX-define-begend-key '(#\b #\c) "center")
      (KaTeX-define-begend-key '(#\b #\d) "document")
      (KaTeX-define-begend-key '(#\b #\D) "description")
      (KaTeX-define-begend-key '(#\b #\e) "enumerate")
      (KaTeX-define-begend-key '(#\b #\E) "equation")
      (KaTeX-define-begend-key '(#\b #\i) "itemize")
      (KaTeX-define-begend-key '(#\b #\l) "flushleft")
      (KaTeX-define-begend-key '(#\b #\m) "minipage")
      (KaTeX-define-begend-key '(#\b #\t) "tabbing")
      (KaTeX-define-begend-key '(#\b #\T) "tabular")
      (KaTeX-define-begend-key '(#\b #\TAB) "table")
      (KaTeX-define-begend-key '(#\b #\p) "picture")
      (KaTeX-define-begend-key '(#\b #\q) "quote")
      (KaTeX-define-begend-key '(#\b #\Q) "quotation")
      (KaTeX-define-begend-key '(#\b #\r) "flushright")
      (KaTeX-define-begend-key '(#\b #\v) "verbatim")
      (KaTeX-define-begend-key '(#\b #\V) "verse")
      (KaTeX-define-key '(#\B #\SPC) 'KaTeX-make-begin-end-region)
      (KaTeX-define-key '(#\b #\SPC) 'KaTeX-make-begin-end)))
  (KaTeX-define-key #\e 'KaTeX-end-environment)
  (KaTeX-define-key #\S 'KaTeX-make-section-region)
  (KaTeX-define-key #\s 'KaTeX-make-section)
  (KaTeX-define-key #\L 'KaTeX-make-fontsize-region)
  (KaTeX-define-key #\l 'KaTeX-make-fontsize)
  (KaTeX-define-key #\m 'KaTeX-make-singlecmd)
  (KaTeX-define-key #\. 'KaTeX-comment-paragraph)
  (KaTeX-define-key #\, 'KaTeX-uncomment-paragraph)
  (KaTeX-define-key #\> 'KaTeX-comment-region)
  (KaTeX-define-key #\< 'KaTeX-uncomment-region)
  (KaTeX-define-key #\g 'KaTeX-goto-corresponding-*)
  (KaTeX-define-key #\k 'KaTeX-kill-*)
  (KaTeX-define-key #\c 'KaTeX-change-*)
  (KaTeX-define-key #\a 'KaTeX-make-accent)
  (KaTeX-define-key #\? 'KaTeX-help)
  (KaTeX-define-key #\/ 'KaTeX-apropos)
  (KaTeX-define-key #\& 'KaTeX-what-column)
  (KaTeX-define-key #\d 'KaTeX-display-hierarchy)
  (KaTeX-define-key #\x KaTeX-user-extensional-map)
  (KaTeX-define-key #\n
		    '(lambda () (interactive) (insert "\\\\")))
  (define-key *KaTeX-prefix-map* #\C-r
	      '(lambda () (interactive)
		(set-screen-height KaTeX-saved-screen-height) (recenter)))
  (mapcar
   (function
    (lambda (key)
      (define-key *KaTeX-mode-map* (car key) 'KaTeX-math-insert-sequence)))
   KaTeX-math-key-list))

(defvar KaTeX-section-completion-map nil
  "*Key map used at KaTeX completion in the minibuffer.")
(unless KaTeX-section-completion-map
  (setq KaTeX-section-completion-map
	(copy-keymap (or (and (boundp 'gmhist-completion-map)
			      gmhist-completion-map)
			 minibuffer-local-completion-map)))
  (define-key KaTeX-section-completion-map
	      #\SPC 'KaTeX-minibuffer-complete)
  (define-key KaTeX-section-completion-map
	      #\C-i 'KaTeX-minibuffer-complete)
  (define-key KaTeX-section-completion-map
	      #\C-v 'KaTeX-read-section-with-overview))

(defvar *KaTeX-recursive-prefix-map* nil)
(unless *KaTeX-recursive-prefix-map*
  (setq *KaTeX-recursive-prefix-map* (copy-keymap *KaTeX-prefix-map*))
  (define-key *KaTeX-recursive-prefix-map* #\b 'nil)
  (define-key *KaTeX-recursive-prefix-map* #\B 'nil)
  (define-key *KaTeX-recursive-prefix-map* #\4 'nil)
  (define-key *KaTeX-recursive-prefix-map* #\5 'nil)
  (mapcar
   (function
    (lambda (key)
      (define-key *KaTeX-recursive-prefix-map* (car key) 'nil)))
   KaTeX-math-key-list))

(defvar *KaTeX-recursive-map* nil
  "*Key map used at KaTeX reading arguments in the minibuffer.")
(unless *KaTeX-recursive-map*
  (setq *KaTeX-recursive-map* (copy-keymap *KaTeX-mode-map*)) ;m.m
  (define-key *KaTeX-recursive-map* *KaTeX-prefix* *KaTeX-recursive-prefix-map*)
;  (define-key *KaTeX-recursive-map* *KaTeX-prefix* *KaTeX-prefix-map*) ;m.m
  (define-key *KaTeX-recursive-map* #\RET 'minibuffer-exit)) ;m.m

;---------- Define other variable ----------
(defvar env-name "document" "*Initial tex-environment completion")
(defvar section-name "documentclass" "*Initial tex-section completion")
(defvar fontsize-name "large" "*Initial fontsize completion")
(defvar single-command "maketitle" "*Initial LaTeX single command")
(defvar KaTeX-kanji-code 1 "*File kanji code used by Japanese TeX.")

(defvar KaTeX-coding-system nil "File coding system used by Japanese TeX.")
(setq KaTeX-coding-system
      (symbol-value (cdr (assoc KaTeX-kanji-code KaTeX-kanji-code-alist))))

(defvar *KaTeX-mode-syntax-table* nil "*Syntax table for katex-mode")
; LaTeX.l ;m.m ->
(unless *KaTeX-mode-syntax-table*
  (setq *KaTeX-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x))) ((>= x #x7f))
    (let ((c (code-char x)))
      (unless (alpha-char-p c)
	(set-syntax-punctuation *KaTeX-mode-syntax-table* c))))
  ;(set-syntax-math *KaTeX-mode-syntax-table* #\$)
  (set-syntax-symbol-prefix *KaTeX-mode-syntax-table* #\\)
  (set-syntax-symbol *KaTeX-mode-syntax-table* #\*)
  (set-syntax-symbol *KaTeX-mode-syntax-table* #\@)
  (set-syntax-symbol *KaTeX-mode-syntax-table* #\')
  (set-syntax-tag *KaTeX-mode-syntax-table* #\{ #\})
  ;(set-syntax-match *KaTeX-mode-syntax-table* #\{ #\})
  (set-syntax-match *KaTeX-mode-syntax-table* #\[ #\])
  (set-syntax-start-comment *KaTeX-mode-syntax-table* #\% t)
  (set-syntax-end-comment *KaTeX-mode-syntax-table* #\LFD t t))

(defvar *KaTeX-keyword-hash-table* nil)
(defvar *KaTeX-keyword-file* "TeX")
; <- LaTeX.l ;m.m

(defvar *KaTeX-math-formats*           ;-> $$ color ;m.m
  (compile-regexp-keyword-list
   '(("\\$[^$]*\\$" t (:keyword 1 :underline) nil)
     )
   ))                                  ;<- $$ color ;m.m
(defvar buffer-file-coding-system nil) ;m.m
(defvar *typeset-and-preview* nil)     ;m.m
(defvar *not-use-verbatime* t)         ;m.m

;---------- Provide KaTeX-mode ----------
;;;
;; Major mode definition
;;;
(defun katex-mode ()
  "  Yet Another LaTeX mode: Major mode for editing input files of LaTeX.
-You can invoke processes concerning LaTeX typesetting by
 		\\[KaTeX-typeset-menu]
-Complete LaTeX environment form of `\\begin{env} ... \\end{env}' by
		\\[KaTeX-make-begin-end]
-Enclose region into some environment by
		\\[universal-argument] \\[KaTeX-make-begin-end]
-Complete LaTeX command which takes argument like `\\section{}' by
		\\[KaTeX-make-section]
-Put LaTeX command which takes no arguments like `\\maketitle' by
		\\[KaTeX-make-singlecmd]
-Complete font or character size descriptor like `{\\large }' by
		\\[KaTeX-make-fontsize]
-Enclose region into those descriptors above by
		\\[universal-argument] \\[KaTeX-make-fontsize]
-Enter European accent notations by
		\\[KaTeX-make-accent]
-Toggle various modes of KaTeX by
		\\[KaTeX-switch-mode-menu]
-Change environt name (on the begin/end line) by
		\\[KaTeX-change-*]
-Kill LaTeX command/environment sequences by
		\\[KaTeX-kill-*]
-Kill LaTeX command/environment with its contents 
		\\[universal-argument] \\[KaTeX-kill-*]
-Go to corresponding object (begin/end, file, labels) by
		\\[KaTeX-goto-corresponding-*]   or
		\\[KaTeX-goto-corresponding-*-other-window]   (in other window)
		\\[KaTeX-goto-corresponding-*-other-frame]   (in other frame)
-Go to main LaTeX source text by
		\\[KaTeX-visit-main]   or
		\\[KaTeX-visit-main-other-window]   (in other window)
		\\[KaTeX-visit-main-other-frame]   (in other frame)
-Comment out or uncomment region by
		\\[KaTeX-comment-region]  or  \\[KaTeX-uncomment-region]
-Comment out or uncomment paragraph by
		\\[KaTeX-comment-paragraph]  or  \\[KaTeX-uncomment-paragraph]
-Make an \\item entry hang-indented by
		\\[KaTeX-fill-item]
-Enclose the region with parentheses by
		\\[KaTeX-insert-parens-region]
		\\[KaTeX-insert-braces-region]
		\\[KaTeX-insert-brackets-region]
		\\[KaTeX-insert-dollars-region]
-Look up the corresponding column header of tabular environment by
		\\[KaTeX-what-column]
-Enter a newline and an entry suitable for environment by
		\\[KaTeX-intelligent-newline]
-View the structure of file inclusion by
		\\[KaTeX-display-hierarchy]
-Refer the online help of popular LaTeX commands by
		\\[KaTeX-help]   (help)
		\\[KaTeX-apropos]   (apropos)
-Edit `%# notation' by
		\\[KaTeX-%-menu]

  Those are enough for fastening your editing of LaTeX source.  But further
more features are available and they are documented in the manual.
"
  (interactive)
  (kill-all-local-variables)
  (setq buffer-mode 'katex-mode)
  (setq mode-name (if KaTeX-japan "かてふ" "KaTeX"))
  (mapcar 'make-local-variable
	  '(dvi2-command fill-column fill-prefix
	    tmp-env-table tmp-section-table tmp-fontsize-table
	    tmp-singlecmd-table paragraph-start paragraph-separate
	    KaTeX-math-mode indent-line-function
	    comment-start comment-start-skip
	    ))
  (when (boundp 'buffer-file-coding-system)
    (setq buffer-file-coding-system KaTeX-coding-system))
  (setq fill-column KaTeX-fill-column
	fill-prefix KaTeX-fill-prefix
	paragraph-start    KaTeX-paragraph-start
	paragraph-separate KaTeX-paragraph-separate
	indent-line-function 'KaTeX-indent-line
	comment-start KaTeX-comment-prefix
	comment-end ""
	;;comment-start-skip "[^\\\\]%+[ \t]*"
	)
  (use-local-map *KaTeX-mode-map*)
  (set-syntax-table *KaTeX-mode-syntax-table*)
  (require "katexmen") ;m.m
  (KaTeX-menu-update)
  (setq KaTeX-saved-screen-height (screen-height))
  (KaTeX-read-user-completion-table)
  (auto-fill-mode t) ;m.m
; LaTeX.l ->
  (and *KaTeX-keyword-file*
       (null *KaTeX-keyword-hash-table*)
       (setq *KaTeX-keyword-hash-table*
	     (load-keyword-file *KaTeX-keyword-file*)))
  (when *KaTeX-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *KaTeX-keyword-hash-table*)
    (setf (gethash #\$ keyword-hash-table) #\$))
; <- LaTeX.l ;m.m
  (make-local-variable 'regexp-keyword-list)             ;-> $$ color
  (setq regexp-keyword-list *KaTeX-math-formats*)        ;<- $$ color
  (make-local-variable 'mode-specific-indent-command)    ;m.m
  (setq mode-specific-indent-command 'KaTeX-indent-line) ;m.m
  (and (= 0 (buffer-size)) (file-exists-p KaTeX-template-file)
       (setq KaTeX-template-file (expand-file-name KaTeX-template-file))
       (y-or-n-p (format nil "Insert ~A" KaTeX-template-file))
       (insert-file-contents (expand-file-name KaTeX-template-file)))
  (run-hooks 'katex-mode-hook))

;---------- Define KaTeX-mode functions ----------
(defvar KaTeX-ec "\\" "Escape character of current mark-up language.")
(defvar KaTeX-ec-regexp (regexp-quote KaTeX-ec))
(defvar KaTeX-struct-begin
  (concat KaTeX-ec "begin{%1}%2")
  "Keyword format of begin-environment.")
(defvar KaTeX-struct-end
  (concat KaTeX-ec "end{%1}")
  "Keyword format of end-environment.")
(defvar KaTeX-struct-name-regexp "[^}]+"
  "Environment name regexp.")
(defvar KaTeX-TeX-token-regexp
  (cond (KaTeX-japan "[A-Za-z*あ-ん亜-龠]+")
	(t "[A-Za-z*]+"))
  "Regexp of characters which can be a member of TeX command's name.")
(defvar KaTeX-command-token-regexp KaTeX-TeX-token-regexp
  "Regexp of characters which can be a member of current mark up language's command name.")

;;(defvar KaTeX-struct-section
;;  (concat KaTeX-ec "%1{%2}")
;;  "Keyword to make section.")

;;;
;; autoload section
;;;

;;autoload from katexprc.el
(autoload 'KaTeX-visit-main "katexprc" "Visit main LaTeX file." t)
(autoload 'KaTeX-visit-main-other-window "katexprc"
  "Visit main other window." t)
(autoload 'KaTeX-main-file-p "katexprc" "Check if the file is main." t)
(autoload 'KaTeX-get-builtin "katexprc" "Get %# built-in." t)
(autoload 'KaTeX-system "katexprc" "Call system command" t)
(autoload 'KaTeX-save-buffers "katexprc" "Save buffers of same major mode" t)

;;autoload from katexmth.el
(autoload 'KaTeX-math-insert-sequence "katexmth" "Image input." t)
(autoload 'KaTeX-in-math-mode-p "katexmth" "Check if in math-env." t)
(autoload 'KaTeX-toggle-math-mode "katexmth" "KaTeX math-mode interfaces." t)
(autoload 'KaTeX-math-member-p "katexmth" "Check if a word is math command." t)
(autoload 'KaTeX-insert-amsparens-region "katexmth" "AMS parens region" t)
(autoload 'KaTeX-insert-amsbraces-region "katexmth" "AMS braces region" t)
(autoload 'KaTeX-insert-amsbrackets-region "katexmth" "AMS brackets region" t)
(autoload 'KaTeX-on-parenthesis-p "katexmth" "Check if on math-parens" t)
(autoload 'KaTeX-goto-open-paren "katexmth" "Goto opening paren" t)
(autoload 'KaTeX-change-parentheses "katexmth" "Change corresponding parens" t)

;;autoload from katexhlp.el
(autoload 'KaTeX-help "katexhlp" "KaTeX helper with LaTeX commands." t)
(autoload 'KaTeX-apropos "katexhlp" "Apropos for (La)TeX commands." t)

;;autoload from katexgen.el
(autoload 'KaTeX-generate "katexgen" "KaTeX add-in function generator." t)
(autoload 'KaTeX-generate-simple "katexgen" "KaTeX add-in support." t)

;;autoload from katexsec.el
(autoload 'KaTeX-section-overview "katexsec" "KaTeX sectioning(view)" t)
(autoload 'KaTeX-read-section-in-minibuffer "katexsec" "KaTeX sectioning" t)
(autoload 'KaTeX-make-section-with-overview "katexsec" "KaTeX sectioning" t)

;;autoload from katexenv.el
(autoload 'KaTeX-what-column "katexenv" "KaTeX env. specific funcs" t)
(autoload 'KaTeX-intelligent-newline "katexenv" "KaTeX env. specific funcs" t)
(autoload 'KaTeX-indent-line-equation "katexenv" "Indent equation lines." t)
(autoload 'KaTeX-goto-corresponding-leftright "katexenv" "\left\right jumps" t)

;;autoload from katexhie.el
(autoload 'KaTeX-display-hierarchy "katexhie"
  "KaTeX document hierarchy browser" t)
(autoload 'KaTeX-display-hierarchy-directly "katexhie"
  "Same as KaTeX-display-hierarchy.  Call from mouse." t)

;; autoload from kahtml.el
(autoload 'kahtml-inner-environment-but "kahtml" "kahtml internal func." t)

;;;
;; KaTeX-mode functions
;;;
(defun KaTeX-insert-begin-end (env region-mode)
  "Insert \\begin{mode-name} and \\end{mode-name}.
This works also for other defined begin/end tokens to define the structure."
  (setq KaTeX-current-completion-type 'begin)
  (let*((ccol (current-column)) beg beg2 exchange
	(arg region-mode)		;for old compatibility
	(indent-column (+ ccol KaTeX-environment-indent))(i 1) func)
    (when (and region-mode (> (point) (mark)))
      (exchange-point-and-mark)
      (setq exchange t
	    ccol (current-column)
	    indent-column (+ ccol KaTeX-environment-indent)))
    ;;VER2 (insert "\\begin{" env "}" (KaTeX-addin env))
    (setq beg (point))
    (KaTeX-insert-struc 'begin env)
    (setq beg2 (point))
    (insert "\n")
    (indent-to indent-column)
    (save-excursion
      ;;indent optional argument of \begin{env}, if any
      (while (> (point-beginning-of-line) beg)
		(skip-chars-forward "\\s " (point-end-of-line))
		(indent-to indent-column)
		(forward-line -1)))
    (require "katexenv")
    (when region-mode
	  ;;if region-mode, indent all text in the region
	(save-excursion
	  (if (fboundp (intern-soft (concat "KaTeX-enclose-" env)))
	      (funcall (intern-soft (concat "KaTeX-enclose-" env))
		       (point) (mark))
	    (while (< (progn (forward-line 1) (point)) (mark))
		  (if (eolp) nil
			(progn
			  (skip-chars-forward " \t\n")
			  (indent-to indent-column)))))))
    (when region-mode (exchange-point-and-mark))
    (indent-to ccol)
    ;;VER2 (insert "\\end{" env "}\n")
    (KaTeX-insert-struc 'end env)
    (KaTeX-reindent ccol)
    (if region-mode
		(progn
		  (insert "\n")
		  (or exchange (exchange-point-and-mark)))
		(goto-char beg2)
		(KaTeX-intelligent-newline nil)
		(KaTeX-indent-line))
    (when KaTeX-current-position-register
	(point-to-register KaTeX-current-position-register))))

(defun KaTeX-make-begin-end (arg)
  "Make LaTeX environment command of \\begin{env.} ... \\end{env.}
by completing read.
If you invoke this command with universal argument,
\(key binding for universal-argument is \\[universal-argument]\)
you can put REGION into that environment between \\begin and \\end."
  (interactive "P")
  (let*
      ((mode (if arg " region" ""))
       (env
	(KaTeX-read-environment
	 (format nil "Begin environment~A(default ~A): " mode env-name))))
    (if (string= env "")
	(setq env env-name)
      (setq env-name env))
    (KaTeX-update-table
     (list env-name) 'env-table 'user-env-table 'tmp-env-table)
    (KaTeX-insert-begin-end env-name arg)
  ))

(defun KaTeX-make-begin-end-region ()
  "Call KaTeX-make-begin-end with ARG to specify region mode."
  (interactive)
  (KaTeX-make-begin-end t))

(defun KaTeX-make-section (arg &optional beg end cmd)
  "Make LaTeX \\section{} type command with completing read.
With numeric ARG, you can specify the number of arguments of
LaTeX command.
  For example, if you want to produce LaTeX command

	\\addtolength{\\topmargin}{8mm}

which has two arguments.  You can produce that sequence by typing...
	ESC 2 C-c s add SPC RET \\topm SPC RET 8mm RET
\(by default\)
Then katex will automatically complete `addtolength' with two arguments
next time.
  You can complete symbol at LaTeX command and the 1st argument.

If the optional 2nd and 3rd argument BEG END are specified, enclose
the region from BEG to END into the first argument of the LaTeX sequence.
Optional 4th arg CMD is LaTeX command name, for non-interactive use."
  (interactive "P")
  (setq KaTeX-current-completion-type 'section)
  (when (equal arg '(4)) (setq beg (region-beginning) end (region-end)))
  (setq arg *prefix-value*)
  (unwind-protect
      (setq source-window (selected-window))
      (let*
	  (;(source-window (selected-window))
	   (mlmap (copy-keymap minibuffer-local-map)) ;m.m
	   (section
	    (or cmd
		(KaTeX-read-section
		 (if KaTeX-simple-messages
		     (format nil "Section-type (default ~A): " section-name)
		   (if (> (minibuffer-depth) 0)
		       (format nil "~A???{} (default ~A)~A: " KaTeX-ec section-name
			       (format nil "[level:~D]" (minibuffer-depth)))
		     (format nil "(C-v for view-section) ~A???{~A} (default ~A): "
			     KaTeX-ec (if beg "region" "") section-name)))
		 nil)))
	   (message "~A" section)
	   (section (if (string= section "") section-name section))
	   (numarg	;; The number of section-type command's argument
			(or (and (numberp arg) arg)
			    (nth 1 (KaTeX-lookup-table section 'section))
			    1))
	   (message "~A" numarg)
	   (arg-reader (intern-soft (concat "KaTeX--" section)))
	   (message "~A" arg-reader)
	   (addin-args (and arg-reader (fboundp arg-reader)))
	   (message "~A" addin-args)
	   (title "")
	   (j 1)
	   (*enable-recursive-minibuffers* t));;let
	(setq section-name section)
	(if beg
	    (let ((e (make-marker)))
	      (goto-char end)
	      (insert "}")
	      (set-marker e (point))
	      (goto-char beg)
	      (insert KaTeX-ec section-name "{")
	      (goto-char e)
	      (set-marker e nil))
	  (progn
	    (setq ed::minibuffer-local-map (copy-keymap *KaTeX-recursive-map*)) ;m.m
	    ;	    (use-global-map *KaTeX-recursive-map*)
	    (if (= numarg 0) (KaTeX-make-singlecmd section-name)
	      (progn (insert KaTeX-ec section-name)
		(insert (KaTeX-addin section-name))))
	    (while (<= j numarg)
	    (insert
	     "{"
	     (setq title
		   (cond
		    (addin-args (funcall arg-reader j))
		    (KaTeX-skip-default-reader "")
		    (t
		     (read-string (format nil "Argument ~D of ~A: " j section)))))
	     "}")
	      (setq j (1+ j)))))
	(KaTeX-update-table
	 (if (/= numarg 1) (list section numarg)
	   (list section))
	 'section-table 'user-section-table 'tmp-section-table)
	(when KaTeX-current-position-register
	  (point-to-register KaTeX-current-position-register))
	(when (string= (buffer-substring (- (point) 2) (point)) "{}")
	  (forward-char -1))
	(while (string= (buffer-substring (- (point) 3) (1- (point))) "{}")
	  (forward-char -2))
	(when (<= (minibuffer-depth) 0)
	  (setq minibuffer-local-map (copy-keymap mlmap))))))
; (use-global-map global-map) -> (setq minibuffer-local-map mlmap) ;m.m

(defun KaTeX-make-section-region (args beg end)
  "Call KaTeX-make-section with arguments to specify region mode."
  (interactive "P\nr")
  (KaTeX-make-section args beg end))

(defun KaTeX-make-fontsize (arg &optional fontsize)
  "Make completion like {\\large ...} or {\\slant ...} in minibuffer.
If you invoke this command with universal argument, you can put region
into {\\xxx } braces.
\(key binding for universal-argument is \\[universal-argument]\)"
  (interactive "P")
  (KaTeX-sync-local-table 'tmp-fontsize-table)
  (let* ((mode (if arg "region" ""))
	 (fontsize
	  (or fontsize
	      (KaTeX-read-fontsize
	       (if KaTeX-simple-messages
		   (format nil "Font or size (default ~A): " fontsize-name)
		 (format nil "{\\??? ~A} (default ~A)~A: " mode fontsize-name
			 (if (> (minibuffer-depth) 0)
			     (format nil "[level:~D]" (minibuffer-depth)) "")))
	       nil nil))))
    (when (string= fontsize "")
	(setq fontsize fontsize-name))
    (setq KaTeX-current-completion-type 'large)
    (setq fontsize-name fontsize)
    (KaTeX-update-table
     (list fontsize-name)
     'fontsize-table 'user-fontsize-table 'tmp-fontsize-table)
    (if arg
	(save-excursion
	  (when (> (point) (mark)) (exchange-point-and-mark))
	  (insert "{\\" fontsize-name " ")
	  (exchange-point-and-mark)
	  (insert "}"))
      (progn
	(insert "{\\" fontsize-name " ")
        (when KaTeX-current-position-register
	    (point-to-register KaTeX-current-position-register))
        (save-excursion
	  (insert (KaTeX-addin fontsize-name) "}"))))))

(defun KaTeX-make-fontsize-region ()
  "Call function:KaTeX-make-fontsize with ARG to specify region mode."
  (interactive)
  (KaTeX-make-fontsize t))

(defvar KaTeX-singlecmd-suffix "" "*Suffix for maketitle-type commands.")
(defvar KaTeX-read-singlecmd-history nil "Holds maketitle-type history.")
(put 'KaTeX-read-singlecmd-history 'no-default t)
(defun KaTeX-make-singlecmd (single)
  (interactive
	  (list (KaTeX-cplread-with-learning
			 (if KaTeX-simple-messages
				 (format nil "maketitle-type (default ~A): " single-command)
			   (format nil "~A??? (default ~A)~A: " KaTeX-ec single-command
					   (if (> (minibuffer-depth) 0)
						   (format nil "[level:~D]" (minibuffer-depth)) "")))
			 'singlecmd-table 'user-singlecmd-table 'tmp-singlecmd-table
			 nil nil nil 'KaTeX-read-singlecmd-history)))
  (when (string= single "")
	(setq single single-command))
  (setq single-command single)
  (setq KaTeX-current-completion-type 'maketitle)
  (let ((dollar (and (not (KaTeX-in-math-mode-p))
					 (KaTeX-math-member-p single-command)))
		p q)
	(when dollar (insert "$"))
	(insert KaTeX-ec single-command)
	(setq p (point))
	(insert (KaTeX-addin single) KaTeX-singlecmd-suffix)
	(when dollar (insert "$"))
	(setq q (point))
	(goto-char p)
	(forward-char -2)
	(if (looking-at "\\[\\]") (forward-char 1) (goto-char q)))
  (when KaTeX-current-position-register
	(point-to-register KaTeX-current-position-register)))

(defvar KaTeX-completion-begin-regexp "[{\\]"
  "Regular expression of limit where LaTeX command's completion begins.")

(defun KaTeX-do-completion ()
  "Try completion on LaTeX command preceding point."
  (interactive)
  (if
      (or (eq (preceding-char) #\SPC)
	  (eq (preceding-char) #\TAB)
	  (eq (preceding-char) #\LFD)
	  (bobp))
      (message "Nothing to complete.")   ;Do not complete
    (let* ((end (point))
	   (limit (point-beginning-of-line))
	   (completion-begin
	    (progn (re-search-backward "[ \t\n]" limit 1) (point)))
	   (begin (progn
		    (goto-char end)
		    (if (re-search-backward KaTeX-completion-begin-regexp
					    completion-begin t)
			(1+ (point))
		      nil))))
      (goto-char end)
      (cond
       ((null begin)
	(message "I think it is not a LaTeX sequence."))
       (t
	(mapcar 'KaTeX-sync-local-table
		'(tmp-section-table tmp-env-table tmp-singlecmd-table))
	(let*((pattern (buffer-substring begin end))
	      (all-table
	       (append
		section-table user-section-table tmp-section-table
		env-table     user-env-table     tmp-env-table
		singlecmd-table user-singlecmd-table tmp-singlecmd-table))
	      ;; First,
	      ;; search completion without backslash.
	      (completion (try-completion pattern all-table)))
	  (when (eq completion nil)
	    ;; Next,
	    ;; search completion with backslash
	    (setq completion
		  (try-completion (buffer-substring (1- begin) end)
				  all-table nil)
		  begin (1- begin)))
	  (cond
	   ((null completion)
	    (message (concat "Can't find completion for '" pattern "'"))
	    (ding))
	   ((eq completion t) (message "Sole completion."))
	   ((not (string= completion pattern))
	    (kill-region begin end)
	    (insert completion))
	   (t
	    (message "Making completion list...")
	    (with-output-to-temp-buffer "*Help*"
	      (display-completion-list
	       (all-completions pattern all-table)))))))))))

(defun KaTeX-toggle-modify-mode (arg)
  (interactive "P")
#|  (or (memq 'KaTeX-modify-mode mode-line-format)
      (setq mode-line-format
	    (append (list "" 'KaTeX-modify-mode) mode-line-format))) |#
  (if (or arg (null KaTeX-modify-mode))
      (progn
	(setq KaTeX-modify-mode "*m*")
	(message "Modify mode"))
    (progn
      (setq KaTeX-modify-mode nil)
      (message "Cancel modify mode.")))
  (set-buffer-modified-p (buffer-modified-p)))	;redraw mode-line

(defun KaTeX-switch-mode-menu (arg &optional char)
  (interactive "P")
  (message "Toggle: (M)odify-mode ma(T)h-mode")
  (let ((c (or char (read-char))))
    (cond
     ((= c #\m) (KaTeX-toggle-modify-mode arg))
     ((or (= c #\$) (= c #\t))
      (if KaTeX-auto-math-mode
	  (message "Makes no sense in KaTeX-auto-math-mode.")
	(KaTeX-toggle-math-mode arg))))))

(defun KaTeX-jmode ()
  (get-ime-mode)) ;m.m for Windows

(defun KaTeX-jmode-off ()
  (toggle-ime nil)) ;m.m for Windows

(defun KaTeX-self-insert (arg)
  (call-interactively (global-key-binding *last-command-char*)))
;m.m (global-key-binding (char-to-string last-command-char))

(defun KaTeX-insert-quote ()
  (interactive)
  (insert
   (cond
    ((KaTeX-literal-p) #\")
    ((= (preceding-char) #\\ ) #\")
    ((or (= (preceding-char) (code-char 32))
	 (= (preceding-char) (code-char 9))
	 (= (preceding-char) #\n)
	 (bobp)
	 (string-match
	  (regexp-quote (char-to-string (preceding-char)))
	  "、。，．？！「」『』【】()"))
     "``")
    (t  "''"))))

(defun KaTeX-closable-p ()
  (and (not KaTeX-modify-mode)
       (not (eq KaTeX-close-paren-always 'never))
       (or KaTeX-close-paren-always (eolp))
;m.m       (not (input-pending-p))
       (not (KaTeX-literal-p)))
  ;;(or KaTeX-modify-mode
  ;;    (and (not KaTeX-close-paren-always) (not (eolp)))
  ;;    (input-pending-p)
  ;;    (KaTeX-quick-in-environment-p "verbatim"))
  )

(defun KaTeX-insert-braces-region (beg end &optional open close)
  (interactive "r")
  (save-excursion
    (let ((tmp beg))
      (when (> beg end)
	(setq beg end)
	(setq end tmp)))
    (goto-char end)
    (insert (or close "}"))
    (goto-char beg)
    (insert (or open "{"))))

(defun KaTeX-insert-braces (arg &optional open close)
  (interactive "p")
  (let (env)
    (cond
     ((KaTeX-jmode) (KaTeX-self-insert arg))
     ((not (KaTeX-closable-p)) (KaTeX-self-insert arg))
     ((save-excursion
	(and (> (- (point) (point-min)) 6)
	     (ignore-errors (forward-char -6)))
	(looking-at "\\\\left\\\\"))
      (insert "{\\right\\}")
      (forward-char -8))
     ((save-excursion			;from matsu@math.s.chiba-u.ac.jp
	(and (> (- (point) (point-min)) 6) (forward-char -6))
	(looking-at "\\\\[bB]igl\\\\"))
      (insert
       (concat
	"{" (buffer-substring (match-beginning 0) (- (match-end 0) 2)) "r\\}"))
      (forward-char -7))
     ((save-excursion
	(and (> (- (point) (point-min)) 7)
	     (ignore-errors (forward-char -7)))
	(looking-at "\\\\[bB]iggl\\\\"))
      (insert
       (concat
	"{" (buffer-substring (match-beginning 0) (- (match-end 0) 2)) "r\\}"))
      (forward-char -8))
     ((= (preceding-char) #\\ )
      (insert "{\\}")
      (forward-char -2))		;matsu's hack ends here
     ((and (> (point) (+ (point-min) 4))
	   (save-excursion (backward-char 4) (looking-at "\\\\end"))
	   (not (KaTeX-literal-p))
	   (setq env (KaTeX-inner-environment)))
      (momentary-string-display
       (concat
	"{"
	(cond
	 (KaTeX-japan
	  (format nil "今度からはちゃんと ~A b を使いましょう" *KaTeX-prefix*))
	 (t (format nil "You don't understand Zen of `~A b':p" *KaTeX-prefix*)))
	"}")
       (point))
      (insert (or open "{") env (or close "}")))
     (t
      (insert (or open "{") (or close "}"))
      (forward-char -1)
      (if (and (eq (char-after (point)) #\})
	       (eq (char-after (- (point) 2)) #\\ ))
	  (progn (insert "\\") (forward-char -1)))
      ))))

(defun KaTeX-insert-brackets (arg)
  "Insert Kagi-kakko or \\ [ \\] pair or simply \[."
  (interactive "p")
  (let ((col (1- (current-column))))
    (cond
     ((KaTeX-jmode) (KaTeX-self-insert arg))
     ((not (KaTeX-closable-p))
      (KaTeX-self-insert arg))
     ((save-excursion
	(and (> (- (point) (point-min)) 5) (forward-char -5))
	(looking-at "\\\\left"))
      (insert "[\\right]")
      (forward-char -7))
     ((save-excursion			;from matsu@math.s.chiba-u.ac.jp
	(and (> (- (point) (point-min)) 5) (forward-char -5))
	(looking-at "\\\\[bB]igl"))
      (insert
       (concat
	"[" (buffer-substring (match-beginning 0) (- (match-end 0) 1)) "r]"))
      (forward-char -6))
     ((save-excursion
	(and (> (- (point) (point-min)) 6) (forward-char -6))
	(looking-at "\\\\[bB]iggl"))
      (insert
       (concat
	"[" (buffer-substring (match-beginning 0) (- (match-end 0) 1)) "r]"))
      (forward-char -7))		;matsu's hack ends here
     ((and (= (preceding-char) #\\ )
	   (/= (char-after (- (point) 2)) #\\ )
	   (not (KaTeX-in-math-mode-p)))
      (insert *last-command-char* "\n")
      (indent-to (max 0 col))
      (insert "\\]")
      (beginning-of-line)
      (open-line 1)
      (delete-region (point) (progn (beginning-of-line) (point)))
      (indent-to (+ KaTeX-environment-indent (max 0 col)))
      (or KaTeX-auto-math-mode KaTeX-math-mode (KaTeX-toggle-math-mode 1)))
     ((KaTeX-closable-p)
      (insert "[]")
      (backward-char 1))
     (t (KaTeX-self-insert arg)))))

(defun KaTeX-insert-brackets-region (beg end)
  (interactive "r")
  (KaTeX-insert-braces-region beg end "[" "]"))

(defun KaTeX-insert-parens (arg)
  "Insert parenthesis pair."
  (interactive "p")
  (cond
   ((KaTeX-jmode) (KaTeX-self-insert arg))
   ((not (KaTeX-closable-p)) (KaTeX-self-insert arg))
   ((save-excursion
      (and (> (- (point) (point-min)) 5) (forward-char -5))
      (looking-at "\\\\left"))
    (insert "(\\right)")
    (forward-char -7))
   ((save-excursion			;from matsu@math.s.chiba-u.ac.jp
      (and (> (- (point) (point-min)) 5) (forward-char -5))
      (looking-at "\\\\[bB]igl"))
    (insert
     (concat
      "(" (buffer-substring (match-beginning 0) (- (match-end 0) 1)) "r)"))
     (forward-char -6))
   ((save-excursion
      (and (> (- (point) (point-min)) 6) (forward-char -6))
      (looking-at "\\\\[bB]iggl"))
    (insert
     (concat
      "(" (buffer-substring (match-beginning 0) (- (match-end 0) 1)) "r)"))
     (forward-char -7))
   ((= (preceding-char) #\\ )		;matsu's hack ends here
    (insert "(\\)")
    (backward-char 2))
   ((= (preceding-char) #\| )		;m.m
    (insert "("))
   ((KaTeX-closable-p)
    (insert "()")
    (backward-char 1))
   (t (KaTeX-self-insert arg))))

(defun KaTeX-insert-parens-region (beg end)
  (interactive "r")
  (KaTeX-insert-braces-region beg end "(" ")"))

(defun KaTeX-insert-bar (arg)
  "Insert bar pair."
  (interactive "p")
  (cond
   ((KaTeX-jmode) (KaTeX-self-insert arg))
   ((not (KaTeX-closable-p)) (KaTeX-self-insert arg))
   ((save-excursion
      (and (> (- (point) (point-min)) 5) (forward-char -5))
      (looking-at "\\\\left"))
    (insert "|\\right|")
    (forward-char -7))
   ((save-excursion			;from matsu@math.s.chiba-u.ac.jp
      (and (> (- (point) (point-min)) 5) (forward-char -5))
      (looking-at "\\\\[bB]igl"))
    (insert
     (concat
      "|" (buffer-substring (match-beginning 0) (- (match-end 0) 1)) "r|"))
     (forward-char -6))
   ((save-excursion
      (and (> (- (point) (point-min)) 6) (forward-char -6))
      (looking-at "\\\\[bB]iggl"))
    (insert
     (concat
      "|" (buffer-substring (match-beginning 0) (- (match-end 0) 1)) "r|"))
     (forward-char -7))
   ((save-excursion		; added by Jin <MAF01011@nifty.ne.jp>
      (and (> (- (point) (point-min)) 6) (forward-char -6))
      (looking-at "\\\\left\\\\"))
    (insert "|\\right\\|")
    (forward-char -8))
   ((save-excursion
      (and (> (- (point) (point-min)) 6) (forward-char -6))
      (looking-at "\\\\[bB]igl\\\\"))
    (insert
     (concat
      "|" (buffer-substring (match-beginning 0) (- (match-end 0) 2)) "r\\|"))
     (forward-char -7))
   ((save-excursion
      (and (> (- (point) (point-min)) 7) (forward-char -7))
      (looking-at "\\\\[bB]iggl\\\\"))
    (insert
     (concat
      "|" (buffer-substring (match-beginning 0) (- (match-end 0) 2)) "r\\|"))
     (forward-char -8))		; added by Jin up to here.
   ((= (preceding-char) #\\ )
    (insert "|\\|")
    (backward-char 2))
;   ((and (KaTeX-closable-p)
;	 (/= (preceding-char) #\|)
;	 (/= (following-char) #\|))
;    (insert "||")
;    (backward-char 1))
   (t (KaTeX-self-insert arg))))
#|
(defvar *KaTeX-math-forecolor* 2)
(defvar *KaTeX-math-backcolor* nil)
(defvar *KaTeX-math-bold* t)
(defvar *KaTeX-math-italic* nil)
|#
(defun KaTeX-insert-dollar ()
  (interactive)
  (if (or (not (KaTeX-closable-p))
	  (= (preceding-char) #\\) ;m.m 92 -> #\\
	  (and (KaTeX-in-math-mode-p)
	       (or (/= (preceding-char) #\$) (/= (following-char) #\$))))
      (insert "$")
    (progn
      (insert "$$")
#|
      (set-text-attribute (- (point) 2) (point) 'KaTeX-math
			  :foreground *KaTeX-math-forecolor*
			  :background *KaTeX-math-backcolor*
			  :bold *KaTeX-math-bold*
			  :italic *KaTeX-math-italic*)
|#
      (forward-char -1)
      (KaTeX-jmode-off)
      (or KaTeX-auto-math-mode KaTeX-math-mode (KaTeX-toggle-math-mode 1)))))

(defun KaTeX-insert-dollars-region (beg end)
  (interactive "r")
  (KaTeX-insert-braces-region beg end "$" "$"))

(defun KaTeX-insert-amper ()
  (interactive)
  (if (or (string-match KaTeX-array-env-regexp
			(or (KaTeX-inner-environment t) "document"))
	  (= (preceding-char) #\\)
	  (KaTeX-literal-p))
      (insert "&")
    (insert "\\&")))

(defun KaTeX-version ()
  "Return string of the version of running KaTeX."
  (interactive)
  (message
   (concat "Yet Another tex-mode "
	   (if KaTeX-japan "「花鳥」" "`Flower Bird'")
	   " Revision "
	   KaTeX-revision-number)))

(defun KaTeX-typeset-menu (arg &optional char)
  "Typeset, preview, visit error and miscellaneous convenient menu.
Optional second argument CHAR is for non-interactive call from menu."
  (interactive "P")
  (message
   (concat "J)latex R)egion B)ibtex mk(I)ndex "
	   (if (fboundp 'start-process) "K)ill-latex ")
	   "P)review "
	   (and (boundp 'window-system) window-system "S)earch ")
	   "V)iewerr L)pr"))
  (let ((pre-ime (and (get-ime-mode) (toggle-ime)))
	(sw (selected-window)) (c (or char (read-char))))
    (require "katexprc")			;for Nemacs's bug
    (select-window sw)
    (cond
     ((= c #\j) (KaTeX-typeset-buffer))
     ((= c #\r) (KaTeX-typeset-region))
     ((= c #\b) (KaTeX-call-command-on-file
		bibtex-command "*KaTeX-bibtex*"))
     ((= c #\i) (KaTeX-call-command-on-file
		makeindex-command "*KaTeX-makeindex*"))
     ((= c #\k) (KaTeX-kill-typeset-process KaTeX-typeset-process))
     ((= c #\p) (call-interactively 'KaTeX-preview))
     ;((= c #\q) (KaTeX-system "lpq" "*Printer queue*"))
     ((= c #\v) (KaTeX-view-error))
     ((= c #\l) (KaTeX-lpr arg))
     ((= c #\m) (KaTeX-switch-mode-menu arg))
     ((= c #\b) (KaTeX-insert-string "\\")) ;???
     ;((= c #\s) (KaTeX-xdvi-remote-search arg))
    )
    (and pre-ime (not (get-ime-mode)) (toggle-ime))))

(defun KaTeX-%-menu (&optional beg end char)
  "Operate %# notation."
  ;;Do not use interactive"r" for the functions which require no mark
  (interactive)
  (message "!)Edit-%#! B)EGIN-END-region L)Edit-%#LPR")
  (let ((c (or char (read-char))) (string "") key
		(b (make-marker)) (e (make-marker)))
	(save-excursion
	  (cond
	   ((or (= c #\!) (= c #\l))		;Edit `%#!'
		(goto-char (point-min))
		(setq key (cond ((= c #\!) "%#!")
						((= c #\l) "%#LPR")))
		(if (re-search-forward key nil t)
			(progn
			  (setq string (buffer-substring (point) (point-end-of-line)))
			  (delete-region (point) (progn (end-of-line) (point))))
		  (progn
			(open-line 1)
			(delete-region (point) (progn (beginning-of-line)(point)));for 19 :-<
			(insert key)))
		(unwind-protect
			(setq string (read-string (concat key ": ") string))
		  (insert string)))
	   ((= c #\b)			;%#BEGIN %#END region
		(or end (setq beg (min (point) (mark)) end (max (point) (mark))))
		(set-marker b beg)
		(set-marker e end)
		(goto-char (point-min))
		(while (re-search-forward "^%#\\(BEGIN\\)\\|\\(END\\)$" nil t)
		  (beginning-of-line)
		  (delete-region (point) (progn (forward-line 1) (point))))
		(goto-char b)
		(open-line 1)
		(delete-region (point) (progn (beginning-of-line)(point)));for 19 :-<
		(insert "%#BEGIN")
		(goto-char e)
		(insert "%#END\n")
		(set-marker b nil)
		(set-marker e nil))
	  ))))

(defun KaTeX-goto-corresponding-label (reverse &optional otherwin)
  "Jump to corresponding \\label{} and \\ref{} or \\cite and \\bibitem.
The default search direction depends on the command at the cursor position.
When the cursor is on \\ref(\\cite), KaTeX will try to search the
corresponding \\label(\\bibitem) backward,
and if it fails search forward again.  And when the cursor is
on \\label(\\bibitem), KaTeX will search the corresponding \\ref(\\cite)
forward at first and secondary backward.
Argument REVERSE non-nil makes the default
direction rule reverse.  Since Search string is automatically set in
search-last-string, you can repeat search the same label/ref by typing
\\[isearch-forward] or \\[isearch-backward].
If optional second argument OTHERWIN is non-nil, move to other window."

  (let ((scmd "") label direc string blist (p (point)) (cb (current-buffer))
	(refcommands "label\\|\\(page\\)?ref\\|cite\\|bibitem")
	(func (function (lambda (string sfunc)
			  (or
			   (funcall sfunc string nil t)
			   (funcall (if (eq sfunc 're-search-forward)
					're-search-backward 're-search-forward)
				    string nil t))))))
    (cond
     ((KaTeX-on-section-command-p refcommands)
      (setq scmd (cdr (assoc (KaTeX-match-string 1)
			     '(("label" . "\\(page\\)?ref") ("ref" . "label")
			       ("pageref" . "label")
			       ("cite" . "bibitem") ("bibitem" . "cite")))))
      (goto-char (match-end 0))
      (let ((label (buffer-substring
		    (1- (point)) (progn (backward-list 1) (1+ (point))))))
	;(setq string (concat "\\" scmd "{" label "}"))
	(setq string (concat "\\\\" scmd "{" (regexp-quote label) "}"))
	(setq direc (if (string-match "ref\\|cite" scmd)
			're-search-forward 're-search-backward))
	(when KaTeX-current-position-register
	  (point-to-register KaTeX-current-position-register))
	(when reverse (setq direc (if (eq direc 're-search-forward)
				      're-search-backward 're-search-forward)))
	(if (funcall func string direc)	;label/ref found!
	  (progn
	    (when otherwin
	      (goto-char p)
	      (when (one-window-p)
		(split-window-calculate-height
		 KaTeX-default-pop-window-height))
	      (select-window (get-lru-window))
	      (switch-to-buffer cb))
	    (goto-char (match-beginning 0))
	    (push-mark p))
	  ;;if label/ref not found, search through all katex buffers.
	  (progn
	    (goto-char p)			;resume position of current buffer
	    (setq blist (KaTeX-katex-buffer-list))
	    (catch 'found
	      (while blist
		(set-buffer (car blist))
		(when (KaTeX-on-section-command-p refcommands)
		  (goto-char (match-beginning 0)))
		(when (funcall func string direc)
		  (cond
		   (otherwin
		    (set-buffer cb)
		    (goto-char p)
		    (when (one-window-p)
		      (split-window-calculate-height
		       KaTeX-default-pop-window-height))
		    (select-window (get-lru-window))
		    (switch-to-buffer (car blist)))
		   ((or (get-buffer-window (car blist))
			(get-buffer-window (car blist) t))
		    (goto-buffer-window (car blist)))
		   (t
		    (switch-to-buffer (car blist))
		    (message
		     (format nil "Type ~A ~C to return to original position."
			     (key-description
			      (car
			       (or (where-is-internal 'register-to-point)
				   (where-is-internal 'jump-to-register))))
			     KaTeX-current-position-register))))
		  (goto-char (match-beginning 0))
		  (throw 'found t)))
	      (setq blist (cdr blist)))))
      )
      (setq regexp-search-ring
	    (cons string (delete string regexp-search-ring))))
     (t nil))))

(defun KaTeX-goto-corresponding-environment (&optional allow-mismatch noerr)
  "Go to corresponding begin/end enclosure.
Optional argument ALLOW-MISMATCH allows mismatch open/clese.  Use this
for \left(, \right).
Optional third argument NOERR causes no error for unballanced environment."
  (interactive)
  (when (KaTeX-on-begin-end-p)
    (let ((p  (match-end 0)) b0 b1 env (nest 0) regexp re-s (op (point))
	  (m0 (match-beginning 0))	;whole matching
	  (m1 (match-beginning 1))	;environment in \begin{}
	  (m2 (match-beginning 2)))	;environment in \end{}
      ;(setq env (regexp-quote (buffer-substring p (match-beginning 0))))
      (when (cond
	   (m1				;if begin{xxx}
	    (setq env
		  (if allow-mismatch KaTeX-struct-name-regexp
		    (regexp-quote (buffer-substring m1 (match-end 1)))))
	;    (setq regexp (concat "\\(\\\\end{" env "}\\)\\|"
	;			 "\\(\\\\begin{" env "}\\)"))
	    (setq regexp
		  (concat
		   "\\("
		   (KaTeX-replace-format-args
		    (regexp-quote KaTeX-struct-end) env "" "")
		   "\\)\\|\\("
		   (KaTeX-replace-format-args
		    (regexp-quote KaTeX-struct-begin) env "" "")
		   "\\)"))
	    (setq re-s 're-search-forward))
	   (m2				;if end{xxx}
	    (setq env
		  (if allow-mismatch KaTeX-struct-name-regexp
		    (regexp-quote (buffer-substring m2 (match-end 2)))))
	;   (setq regexp (concat "\\(\\\\begin{" env "}\\)\\|"
	;			 "\\(\\\\end{" env "}\\)"))
	    (setq regexp
		  (concat
		   "\\("
		   (KaTeX-replace-format-args
		    (regexp-quote KaTeX-struct-begin) env "" "")
		   "\\)\\|\\("
		   (KaTeX-replace-format-args
		    (regexp-quote KaTeX-struct-end) env "" "")
		   "\\)"))
	    (setq re-s 're-search-backward))
	   (t (if noerr nil (error "Corresponding environment not found."))))
	  (while (and (>= nest 0) (funcall re-s regexp nil t))
	    (setq b0 (match-beginning 0) b1 (match-beginning 1))
	    (unless (or (equal b0 m0)
			(KaTeX-literal-p b0))
	      (setq nest (if (equal b0 b1)
			     (1- nest) (1+ nest)))))
	  (if (< nest 0)
	      (goto-char b0) ;found.
;;;	      (goto-char (match-beginning 0)) ;found.
	    (progn
	      (goto-char op)
	      (funcall
	       (if noerr 'message 'error)
	       "Corresponding environment `~A' not found." env)
	      (sit-for 1)
	      nil))))))

(defun KaTeX-goto-corresponding-file (&optional other)
  "Visit or switch buffer of corresponding file,
looking at \\input or \\include or \includeonly on current line."
  (if (not (KaTeX-on-includes-p)) nil
    (let ((parent (get-buffer-file-name)) input-file)
      (save-excursion
	(unless (search-forward "{" (point-end-of-line) t)
	  (skip-chars-backward "^,{"))
	(setq input-file
	      (buffer-substring
	       (point) (progn (skip-chars-forward "^ ,}") (point))))
	(when (not (string-match "\\.\\(tex\\|sty\\)$" input-file))
	  (setq input-file (concat input-file ".tex"))))
      (cond
       (other (KaTeX-switch-to-buffer-other-window input-file))
       ((get-file-buffer input-file) (goto-buffer-window input-file))
       (t (KaTeX-switch-to-buffer input-file)))
      (or (KaTeX-get-builtin "!")
	  KaTeX-parent-file
	  (setq KaTeX-parent-file parent)))))

(defun KaTeX-goto-corresponding-BEGIN-END ()
  (when (KaTeX-on-BEGIN-END-p)
    (when
	(cond
	 ((equal (match-beginning 0) (match-beginning 1)) ;if on %#BEGIN
	  (not (search-forward "%#END" nil t)))
	 (t ; if on %#END
	    (not (search-backward "%#BEGIN" nil t))))
      (error "Corresponding %%#BEGIN/END not found."))
    (beginning-of-line)
    t))

(defvar KaTeX-processed-file-regexp-alist nil
  "Alist of regexp of processed file regexp vs. its file name part;
For example, if you include image file with `\\epsfile{file=FILE}' where
`FILE' is processed file.  You might want to view FILE with other previewer
such as ghostview, or want to preview its source which was drawn with
other drawing tool, tgif for example.  Then you should set entire regexp
of including expression and enclose its file name part with \\\\( and \\\\).

 Ex. (\"\\\\\\\\epsfile{[^}]*file=\\\\([^,} ]+\\\\)\\\\(\\\\.e?ps\\\\)?[^}]*}\" 1)

Where the first group surrounded by \\\\( and \\\\) is the file name part
of expression.  So you should set 1 to second element.  And the first
matching group is sent to (image) processor defined by the variable
KaTeX-file-processor-alist. See also the documentation of
KaTeX-file-processor-alist.

↑じゃ良くわかんないすね。例えば tgif hoge.obj して hoge.eps を
\\epsfile{file=hoge.eps} でインクルードしているとしよう。その行で
\[prefix\] g を押した時に tgif を起動して欲しかったら、まず上のような
正規表現を設定する。\\\\(と\\\\)で囲んだところがファイル名になるように
注意する。でファイル名部分が何番目の\\\\(\\\\)になるかをリストの2番目に書く。
すると、その部分が変数 KaTeX-file-processor-alist で定義された
処理プログラムに渡される。というわけ。
ん～やっぱりむずかしいね。分からない時は隣の Lisper に聞くか、
fj野鳥の会で聞こう!
")

(defvar KaTeX-processed-file-regexp-alist-default
  '(("\\\\epsfile\\(\\[[^]]+\\]\\)?{[^},]*file=\\(\\([^,} ]*/\\)?[^,}. ]+\\)\\(\\.e?ps\\)?[^}]*}" 2)
    ("\\\\epsfig{[^},]*fi\\(le\\|gure\\)=\\(\\([^,} ]*/\\)?[^,}. ]+\\)\\(\\.e?ps\\)?[^}]*}" 2)
    ("\\\\postscriptbox{[^}]*}{[^}]*}{\\(\\([^,} ]*/\\)?[^}. ]+\\)\\(\\.e?ps\\)?}" 1)
    ("\\\\\\(epsfbox\\|includegraphics\\|epsfig\\)\\*?{\\(\\([^,} ]*/\\)?[^}. ]+\\)\\(\\.e?ps\\)?}" 2) ;\epsfbox{hoge.ps} or \includegraphics{hoge.eps}
    ("\\\\\\(psbox\\)\\(\\[[^]]+\\]\\)?{\\(\\([^,} ]*/\\)?[^} ]+\\)\\(\\.e?ps\\)}" 3) ;\psbox[options...]{hoge.eps} (97/1/11)
    ("\\\\input{\\([^} ]+\\)\\(\\.tps\\)}" 1) ;tgif2tex (1998/9/16)
    )
  "See the documentation of KaTeX-processed-file-regexp-alist.")

(defvar KaTeX-file-processor-alist nil
  "*Alist of files' processor vs. its extension;
See also the documentation of KaTeX-processed-file-regexp-alist.")
  
(defvar KaTeX-file-processor-alist-default
  '(("tgif" . ".obj")
    ("ghostview" . ".ps")
    ("ghostview" . ".eps")
    (t . ".tex")
    (t . ".sty")
    (t . ""))
  "See the documentation of KaTeX-file-processor-alist.")

(defun KaTeX-goto-corresponding-file-processor (&optional other)
  "Execute corresponding file processor."
  (save-excursion
    (or (looking-at KaTeX-ec-regexp)
	(skip-chars-backward (concat "^" KaTeX-ec) (point-beginning-of-line)))
    (let ((list (append KaTeX-processed-file-regexp-alist
			KaTeX-processed-file-regexp-alist-default))
	  (p (point)) flist file
	  (peol (point-end-of-line)))
      (setq flist (catch 'found
		   (while list
		     (goto-char p)
		     (when (re-search-forward (car (car list)) peol t)
		       (setq file (KaTeX-match-string
				   (car (cdr (car list)))))
		       (throw 'found (cdr (car list))))
		     (setq list (cdr list)))))
      (when flist				;if pattern and file name found
	  (let*((plist (append KaTeX-file-processor-alist
			       KaTeX-file-processor-alist-default))
		(plist0 plist)
		ext cmd src buf (alt (car (cdr flist))))
	    (if (and (re-search-forward
		      (concat KaTeX-comment-prefix "\\s *\\(.*\\)$") peol t)
		     (assoc (setq cmd (KaTeX-match-string 1))
			    KaTeX-file-processor-alist))
		(setq src		;if processor is specified
		      (concat file
			      (cdr (assoc cmd KaTeX-file-processor-alist))))
	      (progn
		(while plist		;if processor is not specified
		(setq ext (cdr (car plist)))
		(when (and (string< "" (concat file ext))
			 (file-exists-p (concat file ext)))
		  (setq cmd (car (car plist))
			src (concat file ext) plist nil))
		(setq plist (cdr plist)))
	        (when (and (null src) alt KaTeX-create-file-prefix-g)
		  (setq cmd alt
			src (concat file (cdr (assoc alt plist0)))))))
	    (when src		;if processor and src file found
		(cond
		 ((stringp cmd)
		  (let ((buf (concat "* " cmd " " src " *")))
		    (KaTeX-system (concat cmd " " src) buf)
		    t))
		 ((eq t cmd)
		  (let ((parent (get-buffer-file-name)))
		    (funcall
		     (cond
		      (other 'KaTeX-switch-to-buffer-other-window)
		      ((get-file-buffer src) 'goto-buffer-window)
		      (t 'KaTeX-switch-to-buffer))
		     src)
		    (or (KaTeX-get-builtin "!")
			KaTeX-parent-file
			(setq KaTeX-parent-file parent))
		    t))
		 ((symbolp cmd)
		  (cond
		   ((symbol-function cmd)
		    (funcall cmd src other)))
		  t))))))))

(defun KaTeX-on-section-command-p (command)
  "Check if point is on the LaTeX command: COMMAND(regexp).
Return nil if point is not on it.  Otherwise return the
number of argument position.
Section command name is stored in match-data #1."
  (let ((p (point)) md (parg 0) (argc 1) word (grouping 0) (i 0))
    (while (setq i (string-match "\\\\(" command i))
      (setq grouping (1+ grouping) i (+ i 2)))
    (save-excursion
      (unless (looking-at KaTeX-ec-regexp)
	(catch 'found			;caught value has no meaning
	  (while t
	    (when (bobp) (throw 'found nil))
	    (cond
	     ((looking-at KaTeX-ec-regexp) (throw 'found t))
	     ((looking-at "[[{]") nil)
	     ((looking-at "[]}]")(ignore-errors (up-list -1)))
	     (t (skip-chars-backward " \t\r\n")))
	    (skip-chars-backward (concat "^ \t\r\n{}[]" KaTeX-ec-regexp))
	    (or (bobp) (forward-char -1)))))
      (when (and
	   (looking-at (concat KaTeX-ec-regexp "\\(" command "\\)"
			       "\\(\\(\\[[^]]+\\]\\)*\\)"	;optional arg
			       ;"[ \t\n\r]*{[^}]+}" ;arg braces
			       "[ \t\n\r]*{[^}]*}")) ;arg braces
	   (not (KaTeX-lookup-table
		 (setq word (KaTeX-match-string 1)) 'singlecmd)))
	(setq md (match-data))
	(skip-chars-forward "^{")
	(when (<= (point) p) (setq parg (1+ parg)))
	(setq argc
	      (or (car (cdr (KaTeX-lookup-table word 'section)))
		      argc))
	(while (and (>= (setq argc (1- argc)) 0)
		    (progn (skip-chars-forward " \t\n\r")
			       (looking-at "{")))
	  (forward-list 1)
	  (when (<= (point) p) (setq parg (1+ parg))))
	(store-match-data md)
	(setq i (+ 2 grouping))
	(if (and (match-beginning i)
		     (>= p (match-beginning i)) (< p (match-end i)))
		-1			;return -1 if point is on optional arg
	      (when (< p (point)) parg))
      ))))

(defun KaTeX-on-maketitle-p ()
  "Check if point is on maketitle type commands.
Call this function after KaTeX-on-section-command-p."
  (let ((p (point)))
    (save-excursion
      (or (= (char-after (point)) #\\ )
	  (progn
	    (skip-chars-backward
	     (concat "^" KaTeX-ec-regexp) (point-beginning-of-line))
	    (or (bobp) (bolp) (backward-char 1))))
      (and (looking-at (concat KaTeX-ec-regexp KaTeX-TeX-token-regexp))
	   (<= (match-beginning 0) p)
	   (> (match-end 0) p)))))

(defun KaTeX-on-begin-end-p ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward
     ;;"\\\\begin{\\([^}]+\\)}\\|\\\\end{\\([^}]+\\)}"
     (concat
      (KaTeX-replace-format-args
       (regexp-quote KaTeX-struct-begin)
       (concat "\\(" KaTeX-struct-name-regexp "\\)") "" "" "")
      "\\|"
      (KaTeX-replace-format-args
       (regexp-quote KaTeX-struct-end)
       (concat "\\(" KaTeX-struct-name-regexp "\\)") "" "" ""))
     (point-end-of-line) t)))

(defun KaTeX-on-includes-p ()
  (save-excursion
    (beginning-of-line)
    (re-search-forward "\\(\\(include.*\\)\\|\\(input\\)\\){.*}"
		       (point-end-of-line) t)))

(defun KaTeX-on-comment-p (&optional sw)
  "Return t if current line is commented out.
Optional argument SW t to treat all `%' lines as comment,
even if on `%#' notation."
  (save-excursion
    (beginning-of-line)
    (skip-chars-forward "\\s ")
    (looking-at (if sw "%" "%[^#]"))))

(defun KaTeX-on-BEGIN-END-p ()
  (save-excursion
    (let ((case-fold-search nil))
      (beginning-of-line)
      (re-search-forward
       "\\(%#BEGIN\\)\\|\\(%#END\\)" (point-end-of-line) t))))

(defun KaTeX-goto-corresponding-* (arg)
  "Parse current line and call suitable function."
  (interactive "P")
  (cond
   ((KaTeX-goto-corresponding-label arg))
   ((KaTeX-goto-corresponding-environment))
   ((KaTeX-goto-corresponding-file-processor arg))
   ((KaTeX-goto-corresponding-file arg))
   ((KaTeX-goto-corresponding-BEGIN-END))
   ((and (string-match
	  KaTeX-equation-env-regexp	;to delay loading
	  (or (KaTeX-inner-environment t) "document"))
	 (KaTeX-goto-corresponding-leftright)) (iiii))
   (t (message "I don't know where to go."))))

(defun KaTeX-goto-corresponding-*-other-window (arg)
  "Parse current line and call suitable function."
  (interactive "P")
  (cond
   ((KaTeX-goto-corresponding-label arg t))
   ;;((KaTeX-goto-corresponding-environment))
   ((KaTeX-goto-corresponding-file t))
   ;;((KaTeX-goto-corresponding-BEGIN-END))
   (t (message "I don't know where to go."))))

(defun KaTeX-comment-region (alt-prefix)
  "Comment out region by '%'.
If you call this function on the 'begin{}' or 'end{}' line,
it comments out whole environment"
  (interactive "P")
  (if (not (KaTeX-on-begin-end-p))
      (comment-out-region
       (if alt-prefix
	   (read-string "Insert prefix: ")
	 KaTeX-comment-prefix))
    (KaTeX-comment-uncomment-env 'comment-out-region)))

(defun KaTeX-uncomment-region (alt-prefix)
  "Uncomment out region by '%'."
  (interactive "P")
  (if (not (KaTeX-on-begin-end-p))
      (uncomment-region
       (if alt-prefix (read-string "Remove prefix: ")
	 KaTeX-comment-prefix)
       (region-beginning) (region-end) KaTeX-uncomment-once)
    (KaTeX-comment-uncomment-env 'uncomment-region)))

(defun KaTeX-comment-uncomment-env (func)
  "Comment or uncomment out one LaTeX environment switching function by FUNC."
  (let (beg (p (point)))
    (save-excursion
      (beginning-of-line)
      (setq beg (point))
      (KaTeX-goto-corresponding-environment)
      (beginning-of-line)
      (if (> p (point)) (setq beg (1+ beg)) (forward-char 1))
      (funcall func KaTeX-comment-prefix beg (point) KaTeX-uncomment-once)))
  (message "~Aommented out current environment."
	   (if (eq func 'comment-out-region) "C" "Un-c")))

(defun KaTeX-beginning-of-environment (&optional limit-search-bound end)
  "Goto the beginning of the current environment.
Optional argument LIMIT-SEARCH-BOUND non-nil limits the search bound to
most recent sectioning command.  Non-nil for optional third argument END
goes to end of environment."
  (interactive)
  (let ((op (point)))
    (when (KaTeX-inner-environment limit-search-bound)
      (goto-char (get 'KaTeX-inner-environment 'point))
      (and end (KaTeX-goto-corresponding-environment))
      (when (interactive-p) (push-mark op))
      t)))

(defun KaTeX-end-of-environment (&optional limit-search-bound)
  "Goto the end of the current environment.
Optional argument LIMIT-SEARCH-BOUND non-nil limits the search bound
to most recent sectioning command."
  (interactive)
  (KaTeX-beginning-of-environment limit-search-bound t))

(defun KaTeX-mark-environment ()
  "Mark current position and move point to end of environment."
  (interactive)
  (let ((curp (point)))
    (if (and (KaTeX-on-begin-end-p) (match-beginning 1)) ;if on \\begin
	(forward-line 1)
      (beginning-of-line))
    (if (not (KaTeX-end-of-environment))   ;arg1 turns to match-beginning 1
      (progn
	  (goto-char curp)
	  (error "Cannot found the end of current environment."))
      (progn
	(KaTeX-goto-corresponding-environment)
        (beginning-of-line)		;for confirmation
        (when (< curp (point))
	  (message "Mark this environment?(y or n): ")
	  (unless (= (read-char) #\y)
	      (goto-char curp)
	      (error "Abort.  Please call again at more proper position.")))
        (set-mark-command nil)
	(KaTeX-goto-corresponding-environment)
        (end-of-line)
	(if (eobp) nil (forward-char 1))))))

(defun KaTeX-comment-paragraph ()
  "Comment out current paragraph."
  (interactive)
  (save-excursion
    (cond
     ((KaTeX-on-begin-end-p)
      (beginning-of-line)
      (insert KaTeX-comment-prefix)
      (KaTeX-goto-corresponding-environment)
      (beginning-of-line)
      (insert KaTeX-comment-prefix))
     ((KaTeX-on-comment-p)
      (message "Already commented out."))
     (t
      (mark-paragraph)
      (when (looking-at paragraph-separate) (forward-line 1))
      (comment-out-region "%")))))

(defun KaTeX-uncomment-paragraph ()
  "Uncomment current paragraph."
  (interactive)
  (save-excursion
    (if (KaTeX-on-begin-end-p)
	(let ((p (point-marker)))
	  (KaTeX-goto-corresponding-environment)
	  (KaTeX-remove-prefix KaTeX-comment-prefix KaTeX-uncomment-once)
	  (goto-char p)
	  (KaTeX-remove-prefix KaTeX-comment-prefix KaTeX-uncomment-once)
	  (set-marker p nil))
      (if (KaTeX-on-comment-p)
	  (let*((fill-prefix "")
		;;append `^%' to head of paragraph delimiter.
		(paragraph-start
		 (concat
		  "^$\\|^%\\(" KaTeX-paragraph-separate "\\)"))
		(paragraph-separate paragraph-start))
	    (mark-paragraph)
	    (when (not (bobp)) (forward-line 1))
	    (uncomment-region "%" nil nil KaTeX-uncomment-once))
	(message "This line is not a comment line.")))))

(defun KaTeX-remove-prefix (prefix &optional once)
  "Remove prefix on current line as far as prefix detected. But
optional argument ONCE makes deletion once."
  (interactive "sPrefix:")
  (beginning-of-line)
  (while (re-search-forward (concat "^" prefix) (point-end-of-line) t)
    (replace-match "")
    (when once (end-of-line))))

(defun KaTeX-kill-some-pairs (predicate gofunc kill-contents)
  "Kill some matching pair.
This function assumes that pairs occupy whole of each line where they resid."
  (when (funcall predicate)
    (let ((b1 (match-beginning 0)) (e1 (match-end 0))
	  b2 e2)
      (save-excursion
	(funcall gofunc)
	(funcall predicate)		;get match data
	(if (< (point) e1)		;if currently on begin-line
	    (progn
	      (setq b2 b1 e2 e1
		    b1 (match-beginning 0) e1 (match-end 0))
	      (goto-char e2))		;goto end-line's end
	  (progn
	    (setq b2 (match-beginning 0)
		e2 (match-end 0))
	    (goto-char e2)))	;now e2 has surely end-line's end
	(skip-chars-forward " \t")
	(and (eolp)
	     (not (eobp))
	     (setq e2 (1+ (point))))
	(when (not kill-contents)
	  (kill-region
	   (progn
	     (goto-char b2)
	     (skip-chars-backward " \t%")
	     (if (bolp) (point) b2))
	   e2))
	(goto-char b1)
	(skip-chars-backward " \t%")
	(if (not kill-contents)
	    (progn
	      (kill-append
	       (buffer-substring
		(setq b1 (if (bolp) (point) b1))
		(setq e1
		      (progn
			(goto-char e1)
			(while (looking-at "{\\| \t") 
			  (forward-list 1))
			(skip-chars-forward " \t")
			(if (and (eolp) (not (eobp)))
			    (1+ (point))
			  (point)))))
	       t)
	      (delete-region b1 e1))
	  (kill-region
	   (if (bolp) (point) b1)
	   e2)))
      t)))

(defun KaTeX-kill-section-command (point kill-all)
  "Kill section-type command at POINT leaving its argument.
Non-nil for the second argument kill its argument too."
  (let (beg (end (make-marker)))
	(save-excursion
	  (goto-char point)
	  (or (looking-at KaTeX-ec-regexp)
		  (progn
			(skip-chars-backward (concat "^" KaTeX-ec-regexp))
			(forward-char -1)))
	  (setq beg (point))
	  (skip-chars-forward "^{")
	  (forward-list 1)
	  (set-marker end (point))
	  (if kill-all (kill-region beg end)
		(progn
		  (goto-char beg)
		  (kill-region
		   (point) (progn (skip-chars-forward "^{" end) (1+ (point))))
		  (goto-char end)
		  (set-marker end nil)
		  (kill-append (buffer-substring (point) (1- (point))) nil)
		  (delete-backward-char 1))))))

(defun KaTeX-kill-paren (kill-contents)
  "Kill parentheses leaving its contents.
But kill its contents if the argument KILL-CONTENTS is non-nil."
  (save-excursion
    (let (p)
      (when (looking-at "\\s(\\|\\(\\s)\\)")
	(when (match-beginning 1)
	  (up-list -1))
	(setq p (point))
	(forward-list 1)
	(if kill-contents
	    (delete-region p (point))
	  (progn
	    (delete-backward-char 1)
	    (goto-char p)
	    (if (looking-at
		 (concat "{" KaTeX-ec-regexp
			     KaTeX-command-token-regexp "+"
			     "\\s +"))
		(delete-region
		 (point)
		 (progn (re-search-forward "\\s +" nil t) (point)))
	      (delete-char 1))))
	t))))

(defvar KaTeX-read-environment-history nil "Holds history of environments.")
(put 'KaTeX-read-environment-history 'no-default t)
(defun KaTeX-read-environment (prompt &optional predicate must-match initial)
  "Read a LaTeX environment name with completion."
  (KaTeX-sync-local-table 'tmp-env-table)
  (completing-read-with-history
   prompt
   (append tmp-env-table user-env-table env-table)
   predicate must-match initial
   'KaTeX-read-environment-history))

(defvar KaTeX-read-section-history nil "Holds history of section-types.")
(put 'KaTeX-read-section-history 'no-default t)
(defun KaTeX-read-section (prompt &optional predicate initial)
  "Read a LaTeX section-type command with completion."
  (KaTeX-sync-local-table 'tmp-section-table)
  (let ((mct minibuffer-completion-table))
	(setq minibuffer-completion-table
		  (append tmp-section-table user-section-table section-table))
	(prog1
		(read-from-minibuffer-with-history
		 prompt initial KaTeX-section-completion-map nil
		 'KaTeX-read-section-history)
	  (setq minibuffer-completion-table mct))))

(defun KaTeX-read-section-with-overview ()
  "Read sectioning command with overview.
This function refers a local variable `source-window' in KaTeX-make-section"
  (interactive)
  (require "katexsec")			;some case needs this
  (when (> (minibuffer-depth) 1)
    (error "Too many minibuffer levels for overview."))
  (let ((sw (selected-window))
	(minibuffer-max-depth nil) ; for XEmacs20
	(enable-recursive-minibuffers t) sect)
    (unwind-protect
	(progn
	  (select-window source-window)
	  (setq sect (KaTeX-read-section-in-minibuffer
		      "Sectioning(Up=C-p, Down=C-n, Help=?): "
		      KaTeX-sectioning-level (KaTeX-section-overview))))
      (select-window sw))
    (when (eq (selected-window) (minibuffer-window))
      (erase-buffer))
    (insert sect)
    (exit-minibuffer)))

(defvar KaTeX-read-fontsize-history nil "Holds history of font designator.")
(put 'KaTeX-read-fontsize-history 'no-default t)
(defun KaTeX-read-fontsize (prompt &optional predicate must-match initial)
  "Read a LaTeX font changing command with completion."
  (KaTeX-sync-local-table 'tmp-fontsize-table)
  (completing-read-with-history
   prompt (append tmp-fontsize-table user-fontsize-table fontsize-table)
   predicate must-match initial 'KaTeX-read-fontsize-history))

(defun KaTeX-change-environment ()
  "Change the name of environment."
  (interactive)
  (when (KaTeX-on-begin-end-p)
	(save-excursion
	  (let (p env (m1 (match-beginning 1)) (m2 (match-beginning 2)))
		(setq env (if m1 (buffer-substring m1 (match-end 1))
					(buffer-substring m2 (match-end 2))))
		(goto-char (match-beginning 0))
		(set-mark-command nil)
		(KaTeX-goto-corresponding-environment)
		(setq newenv (KaTeX-read-environment
					  (format nil "Change environment `~A' to: " env)))
		(cond
		 ((string= newenv "")	(message "Change environment cancelled."))
		 ((string= newenv env)	(message "No need to change."))
		 (t
		  (search-forward (concat "{" env) (point-end-of-line) t)
		  (replace-match (concat "{" newenv) t)
		  (exchange-point-and-mark)
		  (search-forward (concat "{" env) (point-end-of-line) t)
		  (replace-match (concat "{" newenv) t)))
		t))))

(defun KaTeX-change-section ()
  "Change section-type command."
  (interactive)
  (let*((where (KaTeX-on-section-command-p KaTeX-command-token-regexp))
	(p (point)) (cmd (KaTeX-match-string 1)) beg end old new)
    (unless (null where)
      (cond
	   ((equal where 0);;if point is on section command
		(setq beg (match-beginning 1)
			  end (match-end 1))
		(goto-char beg)			;beginning of the command
		(setq new (KaTeX-read-section (format nil "Change `~A' to: " cmd) nil)))
	   ((= where -1);;if point is on a optional parameter
		(setq beg (match-beginning 2))
		(skip-chars-forward "^{")
		(setq end (point))
		(goto-char p)
		(setq new
			  (if (fboundp (intern-soft (concat KaTeX-addin-prefix cmd)))
				  (KaTeX-addin cmd)
				(concat "["
						(read-string (format nil "Change `~A' to: "
											 (buffer-substring
											  (1+ beg) (1- end))))
						"]"))))
	   ((> where 0);;if point is in arguments' braces
		(or (looking-at "{")
			(progn (skip-chars-backward "^{") (forward-char -1)))
		(setq beg (1+ (point)))
		(forward-list 1)
		(forward-char -1)
		(setq end (point)
			  old (buffer-substring beg end))
		(goto-char p)
		(when (> (length old) 40)
		  (setq old (concat (substring old 0 12) "..." (substring old -12))))
		(setq new
			  (if (intern-soft (concat "KaTeX--" cmd))
				  (funcall (intern-soft (concat "KaTeX--" cmd)) where)
				(read-string (format nil "Change `~A' to: " old)))))
	  );cond
      (delete-region beg end)
      (goto-char beg)
      (insert-before-markers new)
      ;;(goto-char (marker-position p))
      new)))

(defun KaTeX-change-fontsize ()
  "Change large-type command."
  (let ((lt (append tmp-fontsize-table user-fontsize-table fontsize-table))
	(p (point)) large old new beg end)
    ;;(and (looking-at "}") (up-list -1))
    ;;(and (looking-at "{") (forward-char 1))
    ;;Is above convenient?
    (save-excursion
      (or (looking-at KaTeX-ec-regexp)
	  (progn
	    (skip-chars-backward (concat "^" KaTeX-ec-regexp))
	    (forward-char -1)))
      (cond
       ((and
	 (looking-at
	  (concat KaTeX-ec-regexp "\\(" KaTeX-TeX-token-regexp "\\)"))
	 (< p (match-end 0))
	 (assoc (setq old (KaTeX-match-string 1)) lt))
	(goto-char p)
	(setq beg (match-beginning 1) end (match-end 1) ;save match position
	      new (completing-read
		   (format nil "Change font/size `~A' to : " old) lt))
	(delete-region beg end)
	(goto-char beg)
	(insert-before-markers new)
	new)
       (t nil)
       ))))

(defun KaTeX-change-math-image ()
  "Change with image completion."
  (let (maketitle memberp beg end)
	(when (and (KaTeX-on-maketitle-p)
			   (progn
				 (setq maketitle (substring (KaTeX-match-string 0) 1))
				 (setq memberp (KaTeX-math-member-p maketitle))))
	  (setq *last-command-char* (string-to-char (car memberp)))
	  (setq beg (match-beginning 0) end (match-end 0))
	  (delete-region beg end)
	  (KaTeX-math-insert-sequence t (cdr memberp)))))

(defun KaTeX-kill-* (arg)
  "Parse current line and call suitable function.
Non-nil for ARG kills its contents too."
  (interactive "P")
  (cond
   ((KaTeX-kill-some-pairs 'KaTeX-on-begin-end-p
			   'KaTeX-goto-corresponding-environment arg))
   ((KaTeX-kill-some-pairs 'KaTeX-on-BEGIN-END-p
			   'KaTeX-goto-corresponding-BEGIN-END arg))
   ((KaTeX-on-section-command-p KaTeX-command-token-regexp);on any command
    (KaTeX-kill-section-command (match-beginning 0) arg))
   ((KaTeX-kill-paren arg))
   (t (message "I don't know what to kill."))))

(defun KaTeX-change-* ()
  "Parse current line and call suitable function."
  (interactive)
  (cond
   ((KaTeX-change-environment))
   ((KaTeX-change-section))
   ((KaTeX-change-fontsize))
   ((KaTeX-change-math-image))
   ((KaTeX-change-parentheses))
   (t (message "I don't know what to change."))))

;;;
;Check availability of add-in functions
;;;
(cond
; ((featurep 'katexadd) nil)		;Already provided.
 ((progn (load-library "katexadd") (featurep 'katexadd)) nil)
 (t (message "KaTeX add-in functions not supplied.")))

(defun KaTeX-addin (name)
  "Check availability of addin function and call it if exists."
  (if (and (not (get 'KaTeX-generate 'disabled))
	   (intern-soft (concat KaTeX-addin-prefix name))
	   (fboundp (intern-soft (concat KaTeX-addin-prefix name))))
      (let ((s (funcall (intern (concat KaTeX-addin-prefix name)))))
	(if (stringp s) s ""))
    "")) ;Add in function is not bound.


(defun KaTeX-on-item-p (&optional point)
  "Return t if POINT (default is (point)) is on \\item."
  (let ((p (or point (point))))
    (save-excursion
      (goto-char p)
      (end-of-line)
      (setq p (point))
      (re-search-backward KaTeX-paragraph-delimiter nil t)
      (re-search-forward KaTeX-item-regexp p t))))

(defun KaTeX-in-verb-p (&optional point)
  "Check if POINT is in verb or verb*.  Default of POINT is (point)."
  (setq point (or point (point)))
  (save-excursion
    (goto-char point)
    (when (re-search-backward
	   (concat KaTeX-ec-regexp
		   "\\(" KaTeX-verb-regexp "\\)"
		   "\\([^-A-Za-z_*]\\)")
	   (point-beginning-of-line) t)
      (goto-char (match-end 2))
      (skip-chars-forward
       (concat "^" (buffer-substring (match-beginning 2) (match-end 2))))
      (and (< (match-beginning 2) point) (< (1- point) (point))))))

(defun KaTeX-literal-p (&optional point)
  "Check if POINT is in verb or verb* or verbatime environment family.
Default of POINT is (point)."
  (cond
   (*not-use-verbatime*
    nil)
   ((equal KaTeX-ec "\\")		;maybe LaTeX
    (save-excursion
      (and point (goto-char point))
      (or (KaTeX-in-verb-p (point))
	  (and (not (looking-at "\\\\end{verb"))
	       (KaTeX-quick-in-environment-p KaTeX-verbatim-environments)))))))

(defun KaTeX-in-environment-p (env)
  "Return if current LaTeX environment is ENV.
ENV is given in the form of environment's name or its list."
  (let ((md (match-data)) (nest 0) p envrx)
    (cond
     ((atom env)
      (setq envrx
	    (concat "\\("
		    (regexp-quote
		     (KaTeX-replace-format-args
		      KaTeX-struct-begin env "" ""))
		    "\\)\\|\\("
		    (regexp-quote
		     (KaTeX-replace-format-args
		      KaTeX-struct-end env "" ""))
		    "\\)"))
      (save-excursion
	(setq p (catch 'open
		  (while (KaTeX-re-search-active-backward
			  envrx KaTeX-comment-prefix nil t)
		    (if (match-beginning 2)
			(setq nest (1+ nest))
		      (setq nest (1- nest)))
		    (when (< nest 0) (throw 'open t)))))))
     ((listp env)
      (setq p
	    (or (KaTeX-in-environment-p (car env))
		(and (cdr env) (KaTeX-in-environment-p (cdr env)))))))
    (store-match-data md)
    p;(or p (KaTeX-in-verb-p (match-beginning 0)))
    ))

(defun KaTeX-quick-in-environment-p (env)
  "Check quickly but unsure if current environment is ENV.
ENV is given in the form of environment's name or its list.
This function returns correct result only if ENV is NOT nested."
  (save-excursion
    (if (stringp env) (setq env (list env)))
    (let ((inner (KaTeX-inner-environment t)) (rc nil))
      (cond ((listp env)
	     (member inner env))
	    (t
	     (equal env inner))))
#|    (let ((md (match-data)) (p (point)) rc clfound)
      (cond
       ((listp env)
	(or (KaTeX-quick-in-environment-p (car env))
	    (and (cdr env) (KaTeX-quick-in-environment-p (cdr env)))))
       (t
	(when (KaTeX-search-active-backward
	       (KaTeX-replace-format-args KaTeX-struct-begin env "" "")
	       KaTeX-comment-prefix nil t)
	  (setq rc (not (KaTeX-search-active-forward
			 (KaTeX-replace-format-args
			  KaTeX-struct-end env)
			 KaTeX-comment-prefix p t nil))))
	(store-match-data md)
	rc)))|#
  ))

;; Filling \item
(defun KaTeX-remove-trailing-comment (start end)
  "Remove trailing comment from START to end."
  (save-excursion
    (let ((trcom (concat KaTeX-comment-prefix "$")))
      (goto-char start)
      (while (re-search-forward trcom end t)
	(when (/= (char-after (1- (match-beginning 0))) #\\ )
	  (replace-match "\\1"))))))

(defun KaTeX-get-item-info (&optional recent thisenv)
  "Return the list of the beginning of \\item and column of its item.
If it seems to be outside of itemizing environment, just return nil.
Non-nil for optional argument RECENT refers recent \\item.
Optional second argument THISENV omits calling KaTeX-inner-environment."
  (save-excursion
    (let* ((p (point)) env e0 c
	   (bndry (and (setq env (or thisenv (KaTeX-inner-environment t)))
		       (get 'KaTeX-inner-environment 'point)
		       )))
      (end-of-line)
      (when (if recent
	      (KaTeX-re-search-active-backward
	       KaTeX-item-regexp KaTeX-comment-prefix bndry t)
	    (progn
	      (goto-char bndry)
	      (KaTeX-re-search-active-forward
	       KaTeX-item-regexp KaTeX-comment-prefix p t)))
	(goto-char (match-end 0))
	;(setq c (current-column))
	(if (string-match "desc" env)
	    (setq c 6)
	  (progn
	    (when (equal (following-char) #\[) (forward-list 1))
	    (setq c 0)))
	(skip-chars-forward " \t" (point-end-of-line))
	(list (point-beginning-of-line) (+ c (current-column)))))))

(defun KaTeX-fill-item ()
  "Fill item in itemize environment."
  (interactive)
  (save-excursion
    (let* ((p (point))
	   (item-term (concat
		       "\\(^[ \t]*$\\)\\|" KaTeX-item-regexp "\\|\\("
		       KaTeX-ec-regexp "\\(begin\\|end\\)\\)"))
	   ;;This value depends on LaTeX.
	   fill-prefix start col
	   (info (KaTeX-get-item-info t)))
      (unless (null info)		;not on \item, do nothing
	(setq start (car info)
	      col (car (cdr info)))
	(save-excursion
	  (when (re-search-backward "^\\s *$" start t)
	      ;;if separated from \item line, isolate this block
	    (setq start (1+ (match-end 0)))
	    (goto-char start)
	    (skip-chars-forward " \t")
	    (delete-region (point) start) ;is this your favor???
	    (indent-to col)))
	(beginning-of-line)
	(if (<= (save-excursion
		  (re-search-forward
		  (concat "\\\\end{\\|\\\\begin{\\|^[ \t]*$") nil t)
		 (match-beginning 0))
	       p)
	    (progn  (message "Not on itemize.") nil)
	  (progn
	    (end-of-line)
	    (newline)
	    (indent-to col)
	    (setq fill-prefix
		  (buffer-substring (point-beginning-of-line)(point)))
	    (beginning-of-line)
	    (delete-region (point) (progn (forward-line 1) (point)))
	    (re-search-forward item-term nil 1)
	    (KaTeX-remove-trailing-comment start (point))
	    (beginning-of-line)
	    (push-mark (point) t)
	    (goto-char start)
	    (forward-line 1)
	    (while (< (point) (mark))
	      (delete-region (point) (progn (skip-chars-forward " \t") (point)))
	      (forward-line 1))
	    (fill-region-as-paragraph start (mark))
	    (if NTT-jTeX
	        (while (progn(forward-line -1)(end-of-line) (> (point) start))
		  (insert #\%)))
	    (pop-mark)))))))

(defun KaTeX-fill-paragraph (arg)
  "KaTeX adjustment function for fill-paragraph.
*Protect \\verb from unexpected broken up."
  (interactive "P")
  (cond
   ((not (eq buffer-mode 'katex-mode)) (fill-paragraph arg))
   ((KaTeX-quick-in-environment-p KaTeX-fill-inhibit-environments) nil)
   ((KaTeX-in-math-mode-p) nil)
   (t
    (save-excursion
      (let ((verbrex (concat KaTeX-ec-regexp
			     "\\(" KaTeX-verb-regexp "\\)" ;match#1
			     "\\(.\\).*\\(\\2\\)")) ;match #2 and #3
	    (p (point)) ii end poslist spacelist (fill-prefix fill-prefix))
	(cond
	 ((save-excursion (beginning-of-line) ;if point is on the first
			  (setq end (point))  ;non-whitespace char
			  (skip-chars-forward " \t")
			  (equal (point) p))
	  (setq fill-prefix (buffer-substring p end)))
	 ((and ;;(not KaTeX-emacs-19)
	       (string-match KaTeX-itemizing-env-regexp
			     (or (KaTeX-inner-environment t) "document"))
	       (setq ii (KaTeX-get-item-info)))
	  (save-excursion
	    (beginning-of-line)
	    (indent-to-column (car (cdr ii)))
	    (setq fill-prefix
		  (buffer-substring (point) (point-beginning-of-line)))
	    (delete-region (point) (progn (beginning-of-line) (point))))))
        (mark-paragraph)
	(save-restriction
	  (narrow-to-region (region-beginning) (region-end))
	  (KaTeX-remove-trailing-comment (point-min) (point-max))
	  (goto-char (point-min))
	  (while (KaTeX-re-search-active-forward
		  verbrex KaTeX-comment-prefix (point-max) t)
	    (setq end (match-beginning 3))
	    (goto-char (match-beginning 2))
	    (while (re-search-forward "\\s " end t)
	      (setq poslist (cons (make-marker) poslist)
		    spacelist (cons (preceding-char) spacelist))
	      (replace-match "_")
	      (set-marker (car poslist) (match-beginning 0))))
	  ;;(fill-paragraph arg)
	  (fill-region-as-paragraph (point-min) (point-max) arg)
	  (while spacelist
	    (goto-char (car poslist))
	    (set-marker (car poslist) nil)
	    (delete-char 1)
	    (insert (car spacelist))
	    (setq spacelist (cdr spacelist) poslist (cdr poslist)))
	  (goto-char (point-min))
	  (forward-word 1)
	  (beginning-of-line)
	  (while (re-search-forward "\\\\\\(\\(page\\)?ref\\|cite\\){" nil t)
	    (when (< (point-end-of-line)
		   (save-excursion (forward-char -1) (forward-list 1) (point)))
		(end-of-line) (insert KaTeX-comment-prefix)))
	  (goto-char (point-min))
	  (when (and NTT-jTeX (looking-at "[ \t]"))
	    (goto-char (point-min))
	    (while (not (eobp))
	      (end-of-line)
	      (or (bolp)
		  (save-excursion
		    (backward-word 1)
		    (looking-at "\\sw+")) ;is not japanese string
		  (progn (setq p (point)) (insert KaTeX-comment-prefix)))
	      (forward-line 1))
	    (goto-char p)
	    (if (looking-at "%") (delete-char 1)) ;remove last inserted `%'
	    )))))))

(defun KaTeX-indent-new-comment-line (&optional soft)
  "Tuned `indent-new-comment-line' function for katex.
See the documentation of `KaTeX-saved-indent-new-comment-line'."
  (interactive)
  (cond
   ((or (not (memq buffer-mode '(katex-mode yahtml-mode)))
	(string-match
	 "document"
	 (or (and (boundp 'inenv) inenv)
	     (or (KaTeX-inner-environment t) "document"))))
    (apply 'KaTeX-saved-indent-new-comment-line (when soft (list soft))))
;   ((and (eq buffer-mode 'yahtml-mode)
;	 (string-match
;	  "^[Pp][Rr][Ee]" (yahtml-inner-environment-but "^[Aa]\\b" t)))
;    (yahtml-indent-new-commnet-line))
   ((and (eq buffer-mode 'katex-mode)	;1997/2/4
	 (KaTeX-in-math-mode-p)) nil)		;1996/12/30
   (t (let (fill-prefix)
	(apply 'KaTeX-saved-indent-new-comment-line (if soft (list soft)))))))

(if (fboundp 'KaTeX-saved-indent-new-comment-line) nil
  (progn
;    (fset 'KaTeX-saved-indent-new-comment-line
;	(symbol-function 'indent-new-comment-line)) ;m.m
    (fset 'indent-new-comment-line #'KaTeX-indent-new-comment-line)))

(defun KaTeX-fill-* ()
  "Fill paragraph according to its condition."
  (interactive)
  (cond
   ((KaTeX-fill-item))
   ))

;; Accent completion
(defun KaTeX-read-accent-char (x &optional (pre ""))
  "Read char in accent braces."
  (minibuffer-prompt "\\~A{~A?}" x pre) ;m.m
  (let ((c (read-char)))
    (concat
     (if (and (or (= c #\i) (= c #\j))
	      (not (string-match (regexp-quote x) "cdb")))
	 "\\" "")
     (char-to-string c))))

(defun KaTeX-make-accent ()
  "Make accent usage."
  (interactive)
  (minibuffer-prompt "1:` 2:' 3:^ 4:\" 5:~~ 6:= 7:. u v H t c d b ") ;m.m
  (let ((c (read-char)) pre)
	(setq case-fold-search nil)
    (setq c (cond ((and (> c #\0) (< c #\8))
		   (substring "`'^\"~=."
			      (1- (char-code (- c #\0)))
			      (char-code (- c #\0))))
		  ((= c #\h) "H")
		  (t (char-to-string c))))
    (when (string-match c "`'^\"~=.uvHtcdb")
      (insert "\\" c "{}")
      (backward-char 1)
      (insert (setq pre (KaTeX-read-accent-char c)))
      (when (string= c "t") (insert (KaTeX-read-accent-char c pre)))
      (forward-char 1))))

;; Indentation
(defun KaTeX-current-indentation ()
  "Return the indentation of current environment."
  (save-excursion
    ;;(beginning-of-line)
    (if (KaTeX-beginning-of-environment t)
	(goto-char (get 'KaTeX-inner-environment 'point))
      (progn
	(forward-line -1)
        (beginning-of-line)
	(skip-chars-forward " \t")))
    (current-column)))

(defun KaTeX-previous-line-indentation ()
  (save-excursion
    (forward-line -1)
    (skip-chars-forward " \t")
    (current-column)))

(defun KaTeX-indent-line ()
  "Indent corrent line referrin current environment."
  (interactive)
  (let ((indent-relative
		 (function
		  (lambda (&optional additional)
			(KaTeX-reindent
			 (+ (KaTeX-current-indentation)
				(or additional 0)
				KaTeX-environment-indent)))))
		sect depth iteminfo (p (point)) pp (peol (point-end-of-line))
		;;inenv below is sometimes defined in KaTeX-indent-new-comment-line
		(inenv (or (and (boundp 'inenv) inenv) (KaTeX-inner-environment t))))
    ;;(if NTT-jTeX		;;Do you need this section?
    ;;	(save-excursion
    ;;  (end-of-line)
    ;;  (let ((p (point)))
    ;;    (forward-line -1)
    ;;    (end-of-line)
    ;;    (or (= p (point))
    ;;	(progn (backward-char (length KaTeX-comment-prefix))
    ;;	       (not (looking-at (regexp-quote KaTeX-comment-prefix))))
    ;;	(progn
    ;;	  (skip-chars-backward KaTeX-comment-prefix)
    ;;	  (kill-line))))))
    (or inenv (setq inenv "document"))	;is the default environment
    (cond
     ((and (KaTeX-on-begin-end-p) (match-beginning 2)) ;if \end
      (KaTeX-reindent (KaTeX-current-indentation)))
     ((string-match KaTeX-equation-env-regexp inenv)
      (KaTeX-indent-line-equation))	;autoload-ed from katexenv
     (;(KaTeX-in-environment-p '("itemize" "enumerate" "description" "list"))
      (string-match KaTeX-itemizing-env-regexp inenv)
      ;;(KaTeX-on-item-p) ??
      ;;(setq iteminfo (KaTeX-get-item-info t))
      (if (save-excursion
	    (beginning-of-line)
	    (re-search-forward KaTeX-item-regexp peol t))
	  (progn
	    (save-excursion
	      (goto-char (1+ (match-beginning 0)))
	      (setq depth
		    (* KaTeX-environment-indent
		       (cond
			((looking-at "subsubsub")	3)
			((looking-at "subsub")	2)
			((looking-at "sub")	1)
			(t			0)))))
	    (funcall indent-relative depth))
	(KaTeX-reindent (or (car (cdr (KaTeX-get-item-info nil inenv)))
			    (+ (save-excursion
				 (beginning-of-line)
				 (KaTeX-current-indentation))
			       KaTeX-environment-indent))))
      )
     ((KaTeX-literal-p)			;verbatims
      (tab-to-tab-stop))
     ((and inenv (not (equal "document" inenv)))
      (funcall indent-relative))
     ((KaTeX-on-section-command-p KaTeX-sectioning-regexp)
      (require "katexsec")		;to know KaTeX-sectioning-level
      (setq sect (KaTeX-match-string 1))
      (when (string-match "\\*$" sect)
	(setq sect (substring sect 0 -1)))
      (KaTeX-reindent
       (* (max
	   (1-				;I want chapter to have indentation 0
	    (or (cdr (assoc sect KaTeX-sectioning-level))
		0))
	   0)
	  KaTeX-environment-indent)))
     ;;Default movement
     ((and (bolp) fill-prefix) (insert fill-prefix))
     (t (save-excursion
	  (beginning-of-line)
	  (if fill-prefix
	      (progn
		(delete-region (point)
			       (progn (skip-chars-forward " \t")
				      (point)))
		(insert fill-prefix))
	    (progn
	      (skip-chars-forward " \t")
	      (indent-relative-maybe))))
	(skip-chars-forward " \t")))
    ;;if current line is \begin, re-indent \end too
    (when (and (KaTeX-on-begin-end-p) (match-beginning 1))
      (save-excursion
	;;(beginning-of-line)
	;;(search-forward "\\begin")
	(goto-char (match-beginning 0))
	(setq depth (current-column))
	(KaTeX-goto-corresponding-environment)
	(KaTeX-reindent depth)))
    (when (or
	   (and NTT-jTeX
		(save-excursion (beginning-of-line) (looking-at "[ \t]")))
	   (save-excursion
	     (beginning-of-line)
	     (backward-char 1)
	     (and
	      (re-search-backward
	       "\\\\\\(\\(page\\)?ref\\|cite\\){" (point-beginning-of-line) t)
	      (goto-char (1- (match-end 0)))
	      (> (save-excursion
		   (handler-case
		       (progn (forward-list 1) (point))
		     (error (point-max))))
		 (point-end-of-line)))))
      (save-excursion
	(end-of-line)
	(let ((p (point)))
	  (forward-line -1)
	  (end-of-line)
	  (or (= p (point))
	      (looking-at (regexp-quote KaTeX-comment-prefix))
	      (bobp) (bolp)
	      (save-excursion
		(backward-word 1)
		(looking-at "\\sw+")) ;is not japanese string
	      (insert KaTeX-comment-prefix)))))))

(defvar katex-mode-load-hook nil
  "*List of functions to be called when katex.el is loaded.")
(load-library "katexhks")

;;-------------------- Final hook jobs --------------------
(substitute-all-key-definition
 'fill-paragraph 'KaTeX-fill-paragraph *KaTeX-mode-map*)
(run-hooks 'katex-mode-load-hook)

;; `History' was moved to ChangeLog
;----------------------------- End of katex.el -----------------------------
