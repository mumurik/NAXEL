;;; -*- mode: lisp; package: layered-window.api -*-
;;;
;;; File: layered-window/api/window.l
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
  (require "layered-window/api/util")
  )

(in-package :layered-window.api)

(export '(set-layered-window-attributes/color
          set-layered-window-attributes/alpha

          get-layered-window-attributes/color
          get-layered-window-attributes/alpha

          set-window-ex-layered
          window-ex-layered-p
          ))


;;
;; GetLayeredWindowAttributes / SetLayeredWindowAttributes
;;
(defun set-layered-window-attributes/color (hwnd color)
  (set-layered-window-attributes hwnd (coerce-to-color color) 0 LWA_COLORKEY)
  nil)

(defun set-layered-window-attributes/alpha (hwnd alpha)
  (set-layered-window-attributes hwnd 0 alpha LWA_ALPHA)
  nil)

(defun set-layered-window-attributes (hwnd color alpha flag)
  (set-window-ex-layered hwnd t)
  (handler-case
      (progn
        (let ((r (SetLayeredWindowAttributes hwnd color alpha flag))
              (err (GetLastError)))
          (when (zerop r)
            (plain-error "set-layered-window-attributes: 0x~x" err))
          r))
    (error (c)
      (set-window-ex-layered hwnd nil)
      (error c))))

(defun get-layered-window-attributes/color (hwnd)
  (car (multiple-value-list (get-layered-window-attributes hwnd))))

(defun get-layered-window-attributes/alpha (hwnd)
  (cadr (multiple-value-list (get-layered-window-attributes hwnd))))

(defun get-layered-window-attributes (hwnd)
  (let ((alpha (make-BYTE-chunk))
        (color (make-COLORREF-chunk))
        (flags (make-DWORD-chunk)))
    (when (not (zerop (GetLayeredWindowAttributes hwnd color alpha flags)))
      (values (unpack-COLORREF color)
              (unpack-BYTE alpha)
              (unpack-DWORD flags)))))

;;
;; WS_EX_LAYERED
;;
(defun set-window-ex-layered (hwnd flag)
  (set-window-ex-style-flag hwnd WS_EX_LAYERED flag)
  nil)

(defun window-ex-layered-p (hwnd)
  (window-ex-style-flag-p hwnd WS_EX_LAYERED))


(defun set-window-ex-style-flag (hwnd flag-bit value)
  (let ((exstyle (get-window-ex-style hwnd)))
    (unless (eq value (window-ex-style-flag-p hwnd flag-bit exstyle))
      (set-window-ex-style hwnd
                           (if value
                               (logior exstyle flag-bit)
                             (logand exstyle (lognot flag-bit)))))))

(defun window-ex-style-flag-p (hwnd flag-bit &optional ex-style)
  (not (zerop (logand (or ex-style (get-window-ex-style hwnd))
                      flag-bit))))


(defun get-window-ex-style (hwnd)
  (get-window-long hwnd GWL_EXSTYLE))

(defun set-window-ex-style (hwnd value)
  (set-window-long hwnd GWL_EXSTYLE value))


;;
;; SetWindowLong / GetWindowLong
;;

(defun get-window-long (hwnd flag)
  (GetWindowLong hwnd flag))

(defun set-window-long (hwnd flag value)
  (SetWindowLong hwnd flag value))


(provide "layered-window/api/window")

;;; End
