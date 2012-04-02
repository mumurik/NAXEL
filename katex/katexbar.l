;;; -*- Lisp; syntax: Common-Lisp -*-
;;; Yet Another tex-mode for xyzzy - //花鳥//
;;; katex.l, v 1.67.1.7
;;; fixed by Maeda Manabu
;;; Last fixed  "Mon Aug 18 2003 20:37:22 +0900"

; toolbarを使用する場合は、~/.xyzzyもしくはsitinit.lに以
; 下を追加してください。
;    (setq *KaTeX-use-toolbar* t)
;
; toolbarの絵を変更する場合は、~/.xyzzyもしくはsitinit.lに以
; 下を追加してください。
;    (setq *KaTeX-toolbar-bitmap* [filename])
; [filename] は、絵が入っているファイルのファイル名
; position 0 がtypesetの絵に、
; position 1 がpreviewの絵になるようにしてください。

(in-package "elisp")

(defvar *KaTeX-use-toolbar* nil)
(defvar *KaTeX-toolbar-bitmap* (merge-pathnames "site-lisp/katex/KaTeX-toolbar.bmp" (si:system-root)))

(defun KaTeX-check-KaTeX-mode-p ()
  (eq buffer-mode 'katex-mode))

(defun KaTeX-typeset-menu-after-mode-check (arg &optional char)
  (when (KaTeX-check-KaTeX-mode-p)
    (KaTeX-typeset-menu arg char)))

(defun KaTeX-tool-bar ()
  (create-tool-bar
   'KaTeX-tool-bar
   *KaTeX-toolbar-bitmap*
   '(("LaTeX" 0 (lambda () (interactive) (KaTeX-typeset-menu-after-mode-check nil #\j)))
     ("Preview" 1 (lambda () (interactive) (KaTeX-typeset-menu-after-mode-check nil #\p)))
    )))

(defun KaTeX-delete-tool-bar ()
  (interactive)
  (when (find-command-bar 'elisp::KaTeX-tool-bar)
    (delete-command-bar 'elisp::KaTeX-tool-bar)))

(unless (find-command-bar 'elisp::KaTeX-tool-bar)
  (if *KaTeX-use-toolbar*
      (define-command-bar 'elisp::KaTeX-tool-bar "かてふ(&K)")))
