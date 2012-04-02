;;; -*- Lisp; syntax: Common-Lisp -*-
;;; Hooks for KaTeX

;;; -*- Emacs-Lisp -*-
;;; Hooks for YaTeX

;;; 野鳥に関連する記述(たとえばアドイン関数)は katexhks.el という名前の
;;; ファイルに入れてください。起動時に自動的にロードします。

;;; All the private definitions for KaTeX can be stuffed into the file
;;; named `katexhks.el'.  The file `katexhks.el' will be automatically
;;; loaded at the end of loading `katex.el'.

(provide "katexhks")

;Private definitions begin from here.

;;97/1/27
(define-key KaTeX-user-extensional-map #\v 'KaTeX-section-overview)
;;initial version
(define-key KaTeX-user-extensional-map #\0
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "part")))
(define-key KaTeX-user-extensional-map #\1
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "chapter")))
(define-key KaTeX-user-extensional-map #\2
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "section")))
(define-key KaTeX-user-extensional-map #\3
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "subsection")))
(define-key KaTeX-user-extensional-map #\4
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "subsubsection")))
(define-key KaTeX-user-extensional-map #\5
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "paragraph")))
(define-key KaTeX-user-extensional-map #\6
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "subparagraph")))
(define-key KaTeX-user-extensional-map #\r
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "ref")))
(define-key KaTeX-user-extensional-map #\i
  '(lambda () (interactive) (KaTeX-make-singlecmd "item")))
(define-key KaTeX-user-extensional-map #\C-b
  '(lambda () (interactive) (KaTeX-make-singlecmd "leftarrow")))
(define-key KaTeX-user-extensional-map #\l
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "label")))
(define-key KaTeX-user-extensional-map #\f
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "frac")))
(define-key KaTeX-user-extensional-map #\S
  '(lambda () (interactive) (KaTeX-make-section nil nil nil "setlength")))
(define-key KaTeX-user-extensional-map #\b
  '(lambda () (interactive) (KaTeX-make-fontsize nil "bf")))


;
;;; End of katexhks.el
