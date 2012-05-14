;;; -*- mode: lisp; package: layered-window.editor -*-
;;;
;;; File: layered-window/editor/function.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/api")
  (require "layered-window/editor/package")
  )

(in-package :layered-window.editor)

(export '(layered-window-get-opacity
          layered-window-get-alpha
          layered-window-get-transparency-color
          ))

;; 不透明度 (0-100) の取得
(defun layered-window-get-opacity ()
  "layered-window: 現在の透明度を取得する。
透過設定していない場合は nil を返す。"
  (let ((alpha (layered-window-get-alpha)))
    (when alpha
      (alpha->opacity alpha))))

;; α値 (0-255) の取得
(defun layered-window-get-alpha ()
  "layered-window: 現在のα値を取得する。
透過設定していない場合は nil を返す。"
  (get-layered-window-attributes/alpha (get-window-handle)))

;; 透過色取得
(defun layered-window-get-transparency-color ()
  "layered-window: 透過色に指定されている色を取得する。
戻り値は RGB のリスト -> '(R G B)
透過設定していない場合は nil を返す。"
  (let ((color (get-layered-window-attributes/color (get-window-handle))))
    (when color
      (color->rgb color))))

(defun layered-window-refresh (&optional (hwnd (get-window-handle)))
  (interactive)
  (layered-window.api::redraw-window hwnd))


(provide "layered-window/editor/function")

;;; End
