;;; -*- Mode: Lisp; Package: user -*-
;;; browserex.l --- browserex.l �� uninstall �p���W���[��

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 10:09:27 +0900>

;; Description:
;;
;;     browserex.l �� uninstall �p���W���[��
;;

(require "browserex")
(bx::browserex-uninstall)

;; �A�b�v�f�[�g�� history ���ێ����邽��
(setq lisp::*modules*
      (delete "browserex" lisp::*modules* :test 'string-equal))

;;; browserex.l ends here