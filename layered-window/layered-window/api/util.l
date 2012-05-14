;;; -*- mode: lisp; package: layered-window.api -*-
;;;
;;; File: layered-window/api/util.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2003-2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/api/package")
  (require "layered-window/ffi")
  )

(in-package :layered-window.api)

(export '(opacity->alpha
          alpha->opacity
          rgb->color
          color->rgb
          coerce-to-color))

;;
;; RedrawWindow
;;
(defun redraw-window (hwnd)
  (RedrawWindow hwnd 0 0 (logior RDW_ERASE
                                 RDW_INVALIDATE
                                 RDW_FRAME
                                 RDW_ALLCHILDREN)))

;; •s“§–¾“x (%) <-> alpha •ÏŠ·
(defun opacity->alpha (opacity)
  (cond ((< opacity 0)
         0)
        ((> opacity 100)
         255)
        (t (values (round (* (/ opacity 100.0) 255))))))

(defun alpha->opacity (alpha)
  (cond ((< alpha 0)
         0)
        ((> alpha 255)
         100)
        (t
         (values (round (* (/ alpha 255.0) 100))))))


;; #define RGB(r,g,b) \
;;   ((COLORREF)(((BYTE)(r)|((WORD)((BYTE)(g))<<8))|(((DWORD)(BYTE)(b))<<16)))
(defun rgb->color (r g b)
  (logior
   (ash (logand #xff r) 0)
   (ash (logand #xff g) 8)
   (ash (logand #xff b) 16)))

(defun color->rgb (color)
  (list (logand #xff (ash color 0))
        (logand #xff (ash color -8))
        (logand #xff (ash color -16))))

(defun coerce-to-color (color-or-rgb)
  (cond ((integerp color-or-rgb)
         color-or-rgb)
        ((listp color-or-rgb)
         (apply 'rgb->color color-or-rgb))
        (t
         (error 'type-error
                :datum color-or-rgb
                :expected-type '(or integer list)))))


(provide "layered-window/api/util")

;;; End
