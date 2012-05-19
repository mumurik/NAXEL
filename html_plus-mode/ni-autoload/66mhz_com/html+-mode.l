;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; html+-mode.l --- html+-modeのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     html+-modeのni-autoload用モジュール

; 任意の時点で実行するのでautoloadで読み込む
(export 'ed::html+-mode "ed")
(autoload 'html+-mode "html+-mode" t)
(pushnew '("\\.s?html?$" . html+-mode) *auto-mode-alist* :test 'equal)
