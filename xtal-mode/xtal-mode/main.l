;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/main.l
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
  (require "xtal-mode/syntax-table")
  (require "xtal-mode/keymap")
  (require "xtal-mode/keyword")
  (require "xtal-mode/completion")
  (require "xtal-mode/comment")
  (require "xtal-mode/indent")
  (require "xtal-mode/outline")
  (require "xtal-mode/menu")
  (require "xtal-mode/workaround")
  )

(in-package :xtal-mode)

(export '(xtal-mode
          ))

(defun xtal-mode ()
  "xtal-mode"
  (interactive)
  (kill-all-local-variables)
  (setf mode-name "Xtal")
  (setf buffer-mode 'xtal-mode)

  (xtal-mode-setup-syntax-table)
  (xtal-mode-setup-mode-map)

  (xtal-mode-setup-keyword)
  (xtal-mode-setup-completion)
  (xtal-mode-setup-comment)
  (xtal-mode-setup-outline)
  (xtal-mode-setup-indent)
  (xtal-mode-setup-menu)
  (xtal-mode-workaround-setup)

  ; フックの実行
  (run-hooks '*xtal-mode-hook*))

(provide "xtal-mode/main")

;;;; End
