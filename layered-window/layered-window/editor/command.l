;;; -*- mode: lisp; package: layered-window.editor -*-
;;;
;;; File: layered-window/editor/command.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2003-2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/api")
  (require "layered-window/editor/package")
  (require "layered-window/editor/util")
  (require "layered-window/editor/hook")
  (require "layered-window/editor/function")
  )



(in-package :layered-window.editor)

(export '(*layered-window-default-opacity*

          toggle-layered-window

          layered-window-set-opacity
          layered-window-set-alpha
          layered-window-set-transparency-color
          layered-window-set-transparency-color-bgr
          layered-window-set-opaque

          layered-window-p
          ))

;;
;; 変数
;;

(defvar *layered-window-default-opacity* 80
  "layered-window: トグルで切り替えるときのデフォルトの不透明率(%)")


;;;
;;; コマンド
;;;

;; 半透明を toggle
(defun toggle-layered-window ()
  "layered-window: ウィンドウの透明化をトグル"
  (interactive)
  (if (layered-window-p)
      (layered-window-set-opaque)
    (layered-window-set-opacity *layered-window-default-opacity*)))

;; 半透明化
(defun layered-window-set-opacity (opacity)
  "layered-window: ウィンドウを半透明にする。
引数には不透明度を 0-100 の範囲で指定する。"
  (interactive "nOpacity(0-100%): ")
  (layered-window-set-alpha (opacity->alpha opacity)))

;; 半透明化 その2
(defun layered-window-set-alpha (alpha)
  "layered-window: ウィンドウを半透明にする。
引数にはアルファ値を 0-255の範囲で指定する。"
  (interactive "nAlpha(0-255): ")
  (unless (and (integerp alpha) (<= 0 alpha 255))
    (plain-error "α値は 0-255 の範囲で指定してください: ~S" alpha))
  (let ((hwnd (get-window-handle)))
    (set-window-ex-layered hwnd t)
    (set-layered-window-attributes/alpha hwnd alpha)
    (layered-window-run-hooks hwnd)))

;; 透過色設定
(defun layered-window-set-transparency-color-bgr (bgr)
  "layered-window: 指定した色を透過色に設定する。"
  (interactive "sBGR: ")
  (apply 'layered-window-set-transparency-color
         (parse-bgr bgr)))

(defun layered-window-set-transparency-color (r g b)
  "layered-window: 指定した色を透過色に設定する。"
  (interactive "nRed(0-255): \nnGreen(0-255): \nnBlue(0-255): ")
  (unless (and (integerp r) (<= 0 r 255)
               (integerp g) (<= 0 g 255)
               (integerp b) (<= 0 b 255))
    (plain-error "RGB の各値は 0-255 の範囲で指定してください: RGB(~S ~S ~S)" r g b))
  (let ((hwnd (get-window-handle)))
    (set-window-ex-layered hwnd t)
    (set-layered-window-attributes/color hwnd (rgb->color r g b))
    (layered-window-run-hooks hwnd)))

;; 不透明化 (半透明化の解除)
(defun layered-window-set-opaque ()
  "layered-window: ウィンドウを不透明にする。"
  (interactive)
  (unless (layered-window-p)
    (return-from layered-window-set-opaque))
  (let ((hwnd (get-window-handle)))
    (set-window-ex-layered hwnd nil)
    (layered-window-run-hooks hwnd)))

;; non-nil  透明
;; nil      不透明
(defun layered-window-p (&optional (hwnd (get-window-handle)))
  "layered-window: ウィンドウが Layered Window か判定する。
ウィンドウが透過状態なら non-nil
ウィンドウが不透明なら nil"
  (interactive)
  (window-ex-layered-p (get-window-handle)))


(provide "layered-window/editor/command")

;;; End
