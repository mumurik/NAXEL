;;; -*- Mode: Lisp; Package: user -*-
;;; chini.l --- chini.l の ni-autoload 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 10:58:20 +0900>

;; Description:
;;
;;     chini.l の ni-autoload 用モジュール
;;

; 起動時から使用するためrequireで読み込む
(require "chini")
(add-hook '*init-app-menus-hook*
          #'(lambda ()
              (chini-print-insert-menu-items :pre-tag 'ed::print-selected-buffer-dialog)
              (chini-insert-menu-items :head-sep t)) t)

;;; chini.l ends here
