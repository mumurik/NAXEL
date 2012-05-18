;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/keymap.l
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
  (require "xtal-mode/completion")
  (require "xtal-mode/comment")
  (require "xtal-mode/indent")
  (require "xtal-mode/outline")
  (require "xtal-mode/process")
  )

(in-package :xtal-mode)

(defun make-default-mode-map ()
  (make-sparse-keymap))

(defun define-xtal-base-mode-map (keymap)
  (define-key keymap #\{ 'xtal-electric-insert)
  (define-key keymap #\} 'xtal-electric-close)
  (define-key keymap #\[ 'xtal-electric-insert)
  (define-key keymap #\] 'xtal-electric-close)
  (define-key keymap #\( 'xtal-electric-insert)
  (define-key keymap #\) 'xtal-electric-close)
  (define-key keymap #\" 'xtal-electric-string)
  (define-key keymap #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key keymap #\TAB 'xtal-indent-line)
  (define-key keymap #\RET 'xtal-newline-and-indent)
  (define-key keymap #\M-TAB 'xtal-completion)
  (define-key keymap #\C-M-q 'indent-sexp)
  )

(defun define-xtal-specific-mode-map (keymap)
  (define-key keymap #\F10 'xtal-first-error)
  (define-key keymap '(#\C-c #\C-x) 'xtal-run-with-current-buffer)
  (define-key keymap '(#\C-c #\0) 'xtal-close-output-buffer)
  (define-key keymap '(#\C-c #\9) 'xtal-comment-region)
  (define-key keymap '(#\C-c #\8) 'xtal-uncomment-region)
  (define-key keymap '(#\C-c #\C-/) 'xtal-toggle-comment-line)
  (define-key keymap '(#\C-c #\C-l) 'list-function)
  (define-key keymap '(#\C-c #\C-\\) 'xtal-indent-buffer)
  (define-key keymap '(#\C-c #\1) 'ix)
  (define-key keymap '(#\C-c #\!) 'ix-console)

  (define-key keymap #\M-NUL 'xtal-mark-statement)
  (define-key keymap #\C-M-n 'xtal-forward-statement)
  (define-key keymap #\C-M-p 'xtal-backward-statement)
  (define-key keymap #\C-M-j 'xtal-forward-statement-in-scope)
  (define-key keymap #\C-M-k 'xtal-backward-statement-in-scope)
  (define-key keymap #\C-M-t 'xtal-transpose-statement)
  (define-key keymap #\C-M-u 'xtal-up-statement)
  (define-key keymap #\C-M-d 'xtal-down-statement)
  )

(defun make-xtal-mode-map ()
  (let ((keymap (make-default-mode-map)))
    (define-xtal-base-mode-map keymap)
    (define-xtal-specific-mode-map keymap)
    keymap))

(defun make-xtal-mode-map-once ()
  (or *xtal-mode-map*
      (setf *xtal-mode-map* (make-xtal-mode-map))))

;;; èâä˙âª

#+xtal-mode-debug
(setf *xtal-mode-map* nil)

(make-xtal-mode-map-once)

(defun xtal-mode-setup-mode-map ()
  (use-keymap *xtal-mode-map*))


(provide "xtal-mode/keymap")

;;;; End
