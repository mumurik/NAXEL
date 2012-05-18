;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/syntax-table.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/base")
  )

(in-package :xtal-mode)

(defun make-default-syntax-table ()
  (let ((table (make-syntax-table)))
    (do ((x #x21 (1+ x)))((>= x #x7f))
      (let ((c (code-char x)))
        (unless (alphanumericp c)
          (set-syntax-punctuation table c))))
    table))

(defun make-xtal-syntax-table ()
  (let ((table (make-default-syntax-table)))
    (set-syntax-word table #\_)
    (set-syntax-escape table #\\)
    (set-syntax-string table #\")
    (set-syntax-match table #\( #\)) ; ‘Î‰‚·‚é()‚É”ò‚Ô
    (set-syntax-match table #\{ #\})
    (set-syntax-match table #\[ #\])
    (set-syntax-start-multi-comment table "/*")
    (set-syntax-end-multi-comment table "*/")
    (set-syntax-start-c++-comment table #\/)
    (set-syntax-end-c++-comment table #\LFD)
    ;; #! Œ`®‚ÌƒRƒƒ“ƒg‚Í syntax ‚Å‚Í‘Î‰‚Å‚«‚È‚¢
    table))

(defun make-xtal-syntax-table-once ()
  (or *xtal-mode-syntax-table*
      (setf *xtal-mode-syntax-table* (make-xtal-syntax-table))))


;;; ‰Šú‰»

(make-xtal-syntax-table-once)

(defun xtal-mode-setup-syntax-table ()
  (use-syntax-table *xtal-mode-syntax-table*))


(provide "xtal-mode/syntax-table")

;;;; End
