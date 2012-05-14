;;; -*- mode: lisp; package: layered-window.ffi -*-
;;;
;;; File: layered-window/ffi/types.l
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
  (require "layered-window/ffi/macros")
  )

(in-package :layered-window.ffi)

(make-c-type-accessor BYTE)
(make-c-type-accessor DWORD)
(make-c-type-accessor COLORREF)


;;; GetLayeredWindowAttributes

(*define ULW_COLORKEY            #x00000001)
(*define ULW_ALPHA               #x00000002)
(*define ULW_OPAQUE              #x00000004)
(*define ULW_EX_NORESIZE         #x00000008)


;;; RedrawWindow

(c:*define RDW_INVALIDATE          #x0001)
(c:*define RDW_INTERNALPAINT       #x0002)
(c:*define RDW_ERASE               #x0004)

(c:*define RDW_VALIDATE            #x0008)
(c:*define RDW_NOINTERNALPAINT     #x0010)
(c:*define RDW_NOERASE             #x0020)

(c:*define RDW_NOCHILDREN          #x0040)
(c:*define RDW_ALLCHILDREN         #x0080)

(c:*define RDW_UPDATENOW           #x0100)
(c:*define RDW_ERASENOW            #x0200)

(c:*define RDW_FRAME               #x0400)
(c:*define RDW_NOFRAME             #x0800)


(provide "layered-window/ffi/types")

;;; End
