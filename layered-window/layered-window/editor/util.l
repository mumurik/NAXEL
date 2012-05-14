;;; -*- mode: lisp; package: layered-window.editor -*-
;;;
;;; File: layered-window/editor/util.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/editor/package")
  )

(in-package :layered-window.editor)

(defun parse-bgr (str-or-integer)
  (cond ((integerp str-or-integer)
         (color->rgb str-or-integer))
        ((and (stringp str-or-integer)
              (string-matchp "^\\(?:[0#]x?\\)?\\([0-9a-f]\\{1,6\\}\\)$" str-or-integer))
         (color->rgb (parse-integer (match-string 1) :radix 16)))
        (t
         (plain-error (format nil "ïsê≥Ç»BGRílÇ≈Ç∑: ~S" str-or-integer)))))


(provide "layered-window/editor/util")

;;; End
