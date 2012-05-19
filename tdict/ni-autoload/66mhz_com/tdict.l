;;; -*- Mode: Lisp; Package: user -*-
;;;
;;; tdict.l --- tdictのni-autoload用モジュール

;;; author
;;;     YAMAMOTO Taizo

;;; date
;;;     Last updated: "2003-04-29"

;;; description
;;;     tdictのni-autoload用モジュール

; 任意の時点で実行するのでautoloadで読み込む
(export '(ed::tdict-mode ed::tdict-reload) "ed") 
(autoload 'tdict-mode "tdict" t)
(autoload 'tdict-reload "tdict" t)
