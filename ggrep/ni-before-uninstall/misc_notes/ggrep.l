;;; -*- Mode: Lisp; Package: user -*-
;;; ggrep.l --- ggrep.l の uninstall 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:26:33 +0900>

;; Description:
;;
;;     ggrep.l の uninstall 用モジュール
;;

(require "ggrep")
(ed::ggrep-uninstall)

;; アップデート時 history を維持するため
(setq lisp::*modules*
      (delete "ggrep" lisp::*modules* :test 'string-equal))

;;; ggrep.l ends here
