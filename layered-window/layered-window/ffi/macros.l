;;; -*- mode: lisp; package: layered-window.ffi -*-
;;;
;;; File: layered-window/ffi/macros.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/ffi/package")
  )

(in-package :layered-window.ffi)

(defmacro make-c-type-accessor (type)
  (let ((make (intern (format nil "make-~A-chunk" type)))
        (unpack (intern (format nil "unpack-~A" type))))
    `(progn
       (defun ,make ()
         (si:make-chunk nil ,(c::ctypedef-size (c::expand-c-type type))))
       (defun ,unpack (chunk)
         (,(c::ctypedef-accessor (c::expand-c-type type)) chunk 0))
       (export '(,make ,unpack)))))


(provide "layered-window/ffi/macros")

;;; End
