;;; -*- mode: lisp; package: layered-window.ffi -*-
;;;
;;; File: layered-window/ffi/kernel32.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2003-2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/ffi/package")
  (require "layered-window/ffi/macros")
  )

(in-package :layered-window.ffi)

(c:*define-dll-entry
  DWORD
  GetLastError ()
  "kernel32")


(provide "layered-window/ffi/kernel32")

;;; End
