;;;; -*- mode: lisp; package: user -*-
;;;;
;;;; File: xtal-mode/package.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :xtal-mode)
    (defpackage :xtal-mode
      (:use
       :lisp
       :editor
       ))))

(provide "xtal-mode/package")

;;;; End
