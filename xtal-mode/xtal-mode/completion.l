;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/completion.l
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
  (require "xtal-mode/keyword")
  )

(in-package :xtal-mode)

(export '(xtal-completion
          ))

(defparameter *xtal-mode-abbrev-table* nil)
(define-abbrev-table '*xtal-mode-abbrev-table*)

(defparameter *xtal-completion-list* nil)


(defun load-completion-list ()
  (setf *xtal-completion-list*
        (make-list-from-keyword-table (xtal-load-keyword-file-once))))

(defun load-completion-list-once ()
  (or *xtal-completion-list*
      (load-completion-list)))

(defun xtal-completion ()
  (interactive "*")
  (xtal-keyword-completion))

(defun xtal-keyword-completion ()
  (interactive "*")
  (when (load-completion-list-once)
    (xtal-do-completion *xtal-completion-list*)))

(defun xtal-do-completion (completion-list &optional (skip-syntax "w_"))
  (let ((opoint (point)))
    (skip-syntax-spec-backward skip-syntax)
    (skip-syntax-spec-forward " ")
    (let ((from (min opoint (point))))
      (goto-char opoint)
      (do-completion from opoint :list
                     completion-list
                     nil nil
                     completion-list
                     ))))

(defun xtal-mode-setup-completion ()
  (setf *local-abbrev-table* *xtal-mode-abbrev-table*))

#+xtal-mode-debug
(defun user::xtal-mode-debug-completion ()
  (interactive "*")
  (msgbox "~S" *xtal-completion-list*)
  (xtal-completion))


(provide "xtal-mode/completion")

;;;; End
