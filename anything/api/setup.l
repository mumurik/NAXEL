;;; -*- Mode: Lisp -*-
;;  setup: 
;;; Author:        amefura <amefura@gmail.com>
;;; License:       setup is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :anything)
    (defpackage :anything
      (:use
       :lisp :editor)
      ))
  (require :anything/api/def)
  (require :anything/api/macro)
  (require :anything/api/frame)
  (require :anything/api/mode)
  (require :anything/api/category)
  (require :anything/api/action)
  (require :anything/api/move)
  (require :anything/api/isearch)
  (require :anything/api/keymap)
  (require :anything/api/filer)
  (require :anything/api/another)
  (require :anything/api/history)
  )

(in-package :anything)
(in-package :user)
(use-package :anything)

(provide :anything/api/setup)
;;end
