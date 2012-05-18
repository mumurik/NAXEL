;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/menu.l
;;;;
;;;; Modified by: mumurik765 2012/05/18
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/base")
  (require "xtal-mode/completion")
  (require "xtal-mode/comment")
  (require "xtal-mode/indent")
  (require "xtal-mode/outline")
  (require "xtal-mode/path")
  (require "xtal-mode/process")
  (require "xtal-mode/ix-mode")
  )

(in-package :xtal-mode)

(export '(xtal-track-popup-menu
          xtal-add-bookmark-menu
          ))

(defparameter *xtal-menu-name* "&Xtal")
(defparameter *xtal-menu-tag* 'xtal)
(defparameter *xtal-menu-position* 'ed::help)
(defparameter *xtal-popup-menu* nil)

(defun xtal-define-popup-menu ()
  (define-popup-menu 'xtal
    (:item nil "&Xtal で実行" 'xtal-run-with-current-buffer)
    (:item nil "実行結果を閉じる" 'xtal-close-output-buffer)
    (:item nil "実行結果の最初のエラー行にジャンプ" 'xtal-first-error)
    (:sep :above-ix)
    (:item nil "ix を xyzzy 内で実行 (&I)" 'ix)
    (:item nil "ix を外部で実行 (&J)" 'ix-console)
    (:sep :above-comment)
    (:item nil "リージョンをコメントアウト" 'xtal-comment-region)
    (:item nil "リージョンをコメント解除" 'xtal-uncomment-region)
    (:item nil "コメントをトグル" 'xtal-toggle-comment-line
     #'(lambda () (if (xtal-in-multiline-comment-p)
                      :disable
                    (if (or (xtal-in-comment-p) (xtal-beginning-of-one-line-comment-p))
                        :check))))
    (:sep :above-indent)
    (:item nil "バッファをインデント" 'xtal-indent-buffer)
    (:sep :above-outline)
    (:item nil "クラス・メソッド一覧(&L)..." 'list-function)
    (:sep :above-edit)
    (:item nil "ステートメントをマーク" 'xtal-mark-statement)
    (:item nil "次のステートメント" 'xtal-forward-statement)
    (:item nil "前のステートメント" 'xtal-backward-statement)
    (:item nil "同一スコープの次のステートメント" 'xtal-forward-statement-in-scope)
    (:item nil "同一スコープの前のステートメント" 'xtal-backward-statement-in-scope)
    (:item nil "スコープを上に移動" 'xtal-up-statement)
    (:item nil "スコープを下に移動" 'xtal-down-statement)
    (:item nil "前後のステートメントを入れ替え" 'xtal-transpose-statement)
    (:sep :above-path)
    (:item nil "Xtal インストールパスをエクスプローラで開く (&E)" 'xtal-open-install-path-by-explorer)
    (:item nil "Xtal インストールパスをコマンドプロンプトで開く (&C)" 'xtal-open-install-path-by-command-prompt)
    (:sep :above-manual)
    (:item :home-page "Xtal &Home Page"
     (open-url-command *xtal-home-url*))
    (:item :online-reference "Xtal オンラインリファレンス (&O)"
     (open-url-command *xtal-online-reference-url*))
    (:sep :above-version)
    (:item :version (concat "xtal-mode &version " (xtal-mode-version))
     'xtal-mode-show-credit)
    ))

(defun xtal-popup-menu ()
  (or *xtal-popup-menu*
      (setf *xtal-popup-menu* (xtal-define-popup-menu))))


(defun insert-xtal-menu (&key (menu (current-menu))
                              (position *xtal-menu-position*)
                              (menu-name *xtal-menu-name*))
  (when (menup menu)
    (setq menu (copy-menu-items menu (create-menu *xtal-menu-tag*)))
    (delete-xtal-menu menu)
    (cond
     ((and (numberp position) (integerp position))
      (insert-popup-menu menu position (xtal-popup-menu) menu-name))
     ((and (symbolp position) (get-menu-position menu position))
      (insert-popup-menu menu (get-menu-position menu position)
                         (xtal-popup-menu) menu-name))
     (t
      (add-popup-menu menu (xtal-popup-menu) menu-name)))
    (use-local-menu menu)))

(defun delete-xtal-menu (&optional (menu (current-menu)))
  (when (menup menu)
    (while (delete-menu menu *xtal-menu-tag*))))

(defun insert-xtal-menu-all-buffers ()
  (save-excursion
    (dolist (buffer (buffer-list))
      (set-buffer buffer)
      (when (eq buffer-mode 'xtal-mode)
        (insert-xtal-menu)))))

(defun xtal-track-popup-menu ()
  (interactive)
  (track-popup-menu (xtal-popup-menu)))

(defun xtal-add-bookmark-menu (tag name url)
  (let* ((menu (xtal-popup-menu))
         (pos (and menu (get-menu-position menu :above-version))))
    (when pos
      (insert-menu-item menu pos
                        tag name (open-url-command url)))))


;;; 初期化

(unless (get-app-menu (selected-frame))
  ;; local-menu は他のメニューが全て生成された後に変更すべきなので
  ;; *init-app-menus-hook* でなく *post-startup-hook* で実行
  (add-hook '*post-startup-hook* 'insert-xtal-menu-all-buffers))

;; xtal の実行結果バッファにもメニューを付ける
(add-hook '*xtal-create-output-buffer-hook* 'insert-xtal-menu)


(defun xtal-mode-setup-menu ()
  (insert-xtal-menu))


(provide "xtal-mode/menu")

;;;; End
