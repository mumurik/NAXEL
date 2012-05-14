;;; -*- mode: lisp; package: user -*-
;;;
;;; File: layered-window/editor/package.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/api/package")

  #+xyzzy
  (progn
    (unless (find-package :layered-window.editor)
      (defpackage :layered-window.editor
        (:use
         :lisp :editor
         :layered-window.api
         )))

    ;; for convenience
    (use-package :layered-window.editor :editor)
    (use-package :layered-window.editor :user))
  )


(provide "layered-window/editor/package")

;;; End
