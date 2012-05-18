;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/version.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/package")
  )

(in-package :xtal-mode)

(export '(xtal-mode-version
          xtal-mode-show-credit
          ))

(defconstant xtal-mode-version "0.0.5")

(defun xtal-mode-version ()
  xtal-mode-version)


;;; command

(defun xtal-mode-show-credit ()
  (interactive)
  (message (concat "xtal-mode version " (xtal-mode-version))))


(provide "xtal-mode/version")

;;;; End
