;;; -*- mode: lisp; package: user -*-
;;;
;;; File: layered-window/ffi/package.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi")
  (require "api")

  (unless (find-package :layered-window.ffi)
    (defpackage :layered-window.ffi
      (:use
       :lisp :foreign
       )
      (:import-from :winapi
       BOOL
       BYTE
       COLORREF
       DWORD
       HRGN
       HWND
       RECT
       UINT
       )
      )))


(provide "layered-window/ffi/package")

;;; End
