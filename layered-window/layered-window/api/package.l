;;; -*- mode: lisp; package: user -*-
;;;
;;; File: layered-window/api/package.l
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

  (require "layered-window/ffi/package")

  (unless (find-package :layered-window.api)
    (defpackage :layered-window.api
      (:nicknames :lwapi)
      (:use
       :lisp
       :layered-window.ffi
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

       SetLayeredWindowAttributes

       LWA_COLORKEY
       LWA_ALPHA

       GetWindowLong
       SetWindowLong

       GWL_WNDPROC
       GWL_HINSTANCE
       GWL_HWNDPARENT
       GWL_STYLE
       GWL_EXSTYLE
       GWL_USERDATA
       GWL_ID

       GWLP_WNDPROC
       GWLP_HINSTANCE
       GWLP_HWNDPARENT
       GWLP_USERDATA
       GWLP_ID

       WS_EX_DLGMODALFRAME
       WS_EX_NOPARENTNOTIFY
       WS_EX_TOPMOST
       WS_EX_ACCEPTFILES
       WS_EX_TRANSPARENT
       WS_EX_MDICHILD
       WS_EX_TOOLWINDOW
       WS_EX_WINDOWEDGE
       WS_EX_CLIENTEDGE
       WS_EX_CONTEXTHELP
       WS_EX_RIGHT
       WS_EX_LEFT
       WS_EX_RTLREADING
       WS_EX_LTRREADING
       WS_EX_LEFTSCROLLBAR
       WS_EX_RIGHTSCROLLBAR
       WS_EX_CONTROLPARENT
       WS_EX_STATICEDGE
       WS_EX_APPWINDOW
       WS_EX_OVERLAPPEDWINDOW
       WS_EX_PALETTEWINDOW
       WS_EX_LAYERED
       WS_EX_NOINHERITLAYOUT
       WS_EX_LAYOUTRTL
       WS_EX_NOACTIVATE
       )
      )))


(provide "layered-window/api/package")

;;; End
