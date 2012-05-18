;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/parser.l
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

(defparameter *xtal-ident-regexp* "[a-zA-Z0-9_]+")
(defparameter *xtal-block-parameter-regexp*
  (concat "|"
          (re-space)
          (re-repeat-with "," *xtal-ident-regexp*)
          (re-space)
          "|"))

(defun build-regexp (&key class name kinds)
  (concat "^"
          (re-space)
          (re-opt (list (re-capture "[+#-]") (re-space)))
          (re-opt (list (re-capture class) "::"))
          (re-capture name) (re-space)
          (re-space) ":" (re-space)
          (re-capture (re-union kinds))
          "\\b"))

(defun parse-visibility (str)
  (if (null str)
      :public
    (let ((s (string-left-trim " \t\r\f\n" str)))
      (if (= (length s) 0)
          :public
        (case (char s 0)
          (#\+ :public)
          (#\# :protected)
          (#\- :private)
          (t (plain-error "invalid visibility: `~S'" str)))))))

(defun space-line-p ()
  (looking-bol "[ \t]*$"))


(defun xtal-skip-white-spaces-forward ()
  (skip-chars-forward " \t\r\f\n"))

(defun xtal-skip-white-spaces-backward ()
  (skip-chars-backward " \t\r\f\n"))

(defun looking-regexp-forward (re)
  (save-excursion
    (skip-regexp-forward re)))

(defun looking-regexp-backward (re)
  (save-excursion
    (skip-regexp-backward re)))

(defun xtal-skip-block-parameter-forward ()
  (skip-regexp-forward *xtal-block-parameter-regexp*))

(defun xtal-skip-block-parameter-backward ()
  (skip-regexp-backward *xtal-block-parameter-regexp*))

(defun skip-regexp-forward (re)
  (skip-regexp re 'xtal-skip-white-spaces-forward
               #'(lambda (opoint)
                   (eql (match-beginning 0) opoint))
               #'(lambda ()
                   (match-end 0))
               :reverse nil :no-dup nil))

(defun skip-regexp-backward (re)
  (cursor-moved?
    (let ((data))
      (while (skip-regexp re 'xtal-skip-white-spaces-backward
                          #'(lambda (opoint)
                              (<= (match-beginning 0) opoint (match-end 0)))
                          #'(lambda ()
                              (match-beginning 0))
                          :reverse t :no-dup t)
        (setf data (match-data)))
      (store-match-data data))))

(defun skip-regexp (re prep judge pointer &key reverse no-dup)
  (cursor-moved?
    (funcall prep)
    (let ((opoint (point)))
      (save-current-point-only-if-fail
        (when (and (scan-buffer re :regexp t :reverse reverse :no-dup no-dup)
                   (funcall judge opoint))
          (goto-char (funcall pointer)))))))


(defmacro xtal-skip-syntax (direction &rest syntaxs)
  `(cursor-moved?
     (while (or ,@(mapcar #'(lambda (syntax)
                              `(,(symbol-join "xtal-skip-" syntax "-" direction)))
                          syntaxs)))))

(defmacro xtal-skip-syntax-forward (&rest syntaxs)
  `(xtal-skip-syntax :forward ,@syntaxs))

(defmacro xtal-skip-syntax-backward (&rest syntaxs)
  `(xtal-skip-syntax :backward ,@syntaxs))


(provide "xtal-mode/parser")

;;;; End
