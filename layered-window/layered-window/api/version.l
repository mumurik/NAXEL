;;; -*- mode: lisp; package: layered-window.api -*-
;;;
;;; File: layered-window/api/version.l
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
  )

(in-package :layered-window.api)

(export '(layered-window-version
          layered-window-api-version
          ))

(defconstant *layered-window-version* "1.0.1")

;; layered-window.api パッケージの API に追加・変更があるたびにインクリメント
(defconstant *layered-window-api-version* 1)


(defun layered-window-version ()
  *layered-window-version*)

(defun layered-window-api-version ()
  *layered-window-api-version*)

(provide "layered-window/api/version")

;;; End
