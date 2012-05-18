;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/keyword.l
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

(defparameter *xtal-keyword-hash-table* nil)
(defparameter *xtal-regexp-keyword-list*
  '(
    ("#!.*" t ((0 . :comment)))
    ("\\.\\.\\." t ((0 . (:keyword 1))))
    ))


(defun xtal-load-keyword-file (&key ignore-case)
  (setf *xtal-keyword-hash-table*
        (load-keyword-file *xtal-keyword-file* ignore-case)))

(defun xtal-load-keyword-file-once (&key ignore-case)
  (when (and *xtal-keyword-file*
             (null *xtal-keyword-hash-table*))
    (xtal-load-keyword-file :ignore-case nil))
  *xtal-keyword-hash-table*)

(defun xtal-mode-setup-keyword ()
  (xtal-load-keyword-file-once :ignore-case nil)
  (set-local-variable keyword-hash-table *xtal-keyword-hash-table*)
  (set-local-variable regexp-keyword-list
                      (compile-regexp-keyword-list
                       `(,@*xtal-regexp-keyword-list*))))

#+xtal-mode-debug
(defun user::xtal-mode-debug-keyword ()
  (interactive)
  (msgbox "~S" (xtal-load-keyword-file-once)))

(provide "xtal-mode/keyword")

;;;; End
