;;; -*- Mode: Lisp; Package: user -*-
;;; ggrep.l --- ggrep.l �� uninstall �p���W���[��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 12:26:33 +0900>

;; Description:
;;
;;     ggrep.l �� uninstall �p���W���[��
;;

(require "ggrep")
(ed::ggrep-uninstall)

;; �A�b�v�f�[�g�� history ���ێ����邽��
(setq lisp::*modules*
      (delete "ggrep" lisp::*modules* :test 'string-equal))

;;; ggrep.l ends here