;;; -*- mode: lisp; package: layered-window.editor -*-
;;;
;;; File: layered-window/editor/hook.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/api")
  (require "layered-window/editor/package")
  (require "layered-window/editor/function")
  )

(in-package :layered-window.editor)

(export '(*layered-window-hook*
          ))

(defvar *layered-window-hook* 'layered-window-refresh
  "layered-window: 透明度/透過色を変更するたびによばれるフック, 引数は Window ハンドル")

(defun layered-window-run-hooks (hwnd)
  (run-hook-with-args '*layered-window-hook* hwnd))


(provide "layered-window/editor/hook")

;;; End
