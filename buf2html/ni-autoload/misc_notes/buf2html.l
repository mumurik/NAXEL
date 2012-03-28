;;; -*- Mode: Lisp; Package: user -*-
;;; buf2html.l --- buf2html.l の ni-autoload 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 11:09:33 +0900>

;; Description:
;;
;;     buf2html.l の ni-autoload 用モジュール
;;

; 起動時から使用するためrequireで読み込む
(require "buf2html")
(buf2html-set-app-menu)
(buf2html-set-app-popup-menu)

;;; buf2html.l ends here
