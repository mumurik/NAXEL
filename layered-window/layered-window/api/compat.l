;;; -*- mode: lisp; package: layered-window.api -*-
;;;
;;; File: layered-window/api/compat.l
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
  (require "layered-window/api/window")
  )

(in-package :layered-window.api)

(defmacro define-deprecated (&rest pairs)
  `(progn
     ,@(mapcar #'(lambda (pair)
                   `(setf (symbol-function ',(car pair))
                          (symbol-function ',(cadr pair))))
               pairs)))

;;
;; layered-window 0.3 ŒÝŠ· API
;;

(define-deprecated
 (set-lwa-colorkey     set-layered-window-attributes/color)
 (set-lwa-alpha        set-layered-window-attributes/alpha)
 (set-lwa              set-layered-window-attributes)
 (get-lwa-colorkey     get-layered-window-attributes/color)
 (get-lwa-alpha        get-layered-window-attributes/alpha)
 (get-lwa              get-layered-window-attributes)
 (test-ex-layered-flag window-ex-layered-p)
 (set-ex-style-flag    set-window-ex-style-flag)
 (test-ex-style-flag   window-ex-style-flag-p)
 (get-ex-style         get-window-ex-style)
 (set-ex-style         set-window-ex-style))

(defun set-ex-layered-flag (hwnd)
  (set-window-ex-layered hwnd t))

(defun unset-ex-layered-flag (hwnd)
  (set-window-ex-layered hwnd nil))


(provide "layered-window/api/compat")

;;; End
