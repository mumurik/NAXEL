;;; -*- mode: lisp; package: user -*-
;;;
;;; File: ni-autoload/xyzzy_times/xtal-mode.l
;;;
;;; License:
;;;
;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;
;;;   xtal-mode is released under an MIT license.
;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;

(require "xtal-mode")
(pushnew '("\\.xtal$" . xtal-mode::xtal-mode) *auto-mode-alist* :test 'equal)

;; End
