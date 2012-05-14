;;; -*- mode: lisp; package: layered-window.editor -*-
;;;
;;; File: layered-window/editor/menu.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2003-2007 MIYAMUKO Katsuyuki.
;;;
;;;   layered-window is released under an MIT license.
;;;   See layered-window/docs/MIT-LICENSE for full license.
;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "layered-window/editor/package")
  (require "layered-window/editor/command")
  )

(in-package :layered-window.editor)

;;
;; メニュー
;;   based on http://www3.ocn.ne.jp/~han/200306.html#03_t4
;;

(defvar *layered-window-menu-tag* 'toggle-layered-window)
(defvar *layered-window-menu-name* "透明化(&T)")

(defun layered-window-setup-menu ()
  (let ((window-menu (get-menu *app-menu* 'ed::window)))
    (when window-menu
      (delete-menu window-menu *layered-window-menu-tag*)
      (add-menu-item  window-menu
                      *layered-window-menu-tag*
                      *layered-window-menu-name*
                      'toggle-layered-window
                      #'(lambda () (if (layered-window-p) :check))))))

(if *app-menu*
    ;; xyzzy 起動済みならすぐに追加
    (layered-window-setup-menu)
  ;; xyzzy 起動中/ダンプ中なら *init-app-menus-hook* に引っ掛けて実行
  (add-hook '*init-app-menus-hook* 'layered-window-setup-menu))


(provide "layered-window/editor/menu")

;;; End
