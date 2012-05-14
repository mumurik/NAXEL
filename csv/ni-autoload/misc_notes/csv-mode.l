;;; -*- Mode: Lisp; Package: user -*-
;;; csv-mode.l --- csv-mode の ni-autoload 用モジュール

;; Copyright (C) 2001-2006 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2006/10/21 20:15:19 +0900>

;; Description:
;;
;;     csv-mode の ni-autoload 用モジュール
;;

; 任意の時点で実行するのでautoloadで読み込む
(export '(ed::csv-mode  ed::tsv-mode) "ed")
(autoload 'csv-mode "csv-mode" t)
(autoload 'tsv-mode "csv-mode" t)
(pushnew '("\\.csv$" . csv-mode) *auto-mode-alist* :test 'equal)
(pushnew '("\\.tsv$" . tsv-mode) *auto-mode-alist* :test 'equal)

;; csv-mode.l ends here
