;;; -*- mode: lisp; package: layered-window.ffi -*-
;;;
;;; File: layered-window/ffi/user32.l
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


;;; GetLayeredWindowAttributes

(c:*define-dll-entry
  BOOL
  GetLayeredWindowAttributes (HWND
                              (COLORREF *)
                              (BYTE *)
                              (DWORD *))
  "user32")


;;; RedrawWindow

(c:*define-dll-entry
  BOOL
  RedrawWindow (HWND
                (RECT *)
                HRGN
                UINT)
  "user32")


(provide "layered-window/ffi/user32")

;;; End
