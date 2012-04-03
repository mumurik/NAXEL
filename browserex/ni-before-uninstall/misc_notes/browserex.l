;;; -*- Mode: Lisp; Package: user -*-
;;; browserex.l --- browserex.l の uninstall 用モジュール

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 10:09:27 +0900>

;; Description:
;;
;;     browserex.l の uninstall 用モジュール
;;

(require "browserex")
(bx::browserex-uninstall)

;; アップデート時 history を維持するため
(setq lisp::*modules*
      (delete "browserex" lisp::*modules* :test 'string-equal))

;;; browserex.l ends here
