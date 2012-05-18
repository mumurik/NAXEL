;;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/workaround.l
;;;;
;;;; License:
;;;;
;;;;   Copyright (c) 2007 MIYAMUKO Katsuyuki.
;;;;
;;;;   xtal-mode is released under an MIT license.
;;;;   See xtal-mode/docs/MIT-LICENSE for full license.
;;;;

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "xtal-mode/base")
  (require "xtal-mode/buffer")
  )

(in-package :xtal-mode)

(defun xtal-workaround-insert-local-menu-again ()
  (when (buffer-xtal-mode-p)
    (let ((localmenu (current-menu)))
      (when (and localmenu (menup localmenu))
        (unless (get-menu localmenu *xtal-menu-tag*)
          (insert-xtal-menu))))))

(defun xtal-workaround-setup-svn-mode ()
  (when (and (file-exist-p ".svn")
             (member "svn-open-file" ed::*find-file-hooks* :key 'make-string :test #'equalp))
    (delete-hook 'ed::*find-file-hooks* 'xtal-workaround-insert-local-menu-again)
    (add-hook 'ed::*find-file-hooks* 'xtal-workaround-insert-local-menu-again t)))

(defun xtal-mode-workaround-setup ()
  (xtal-workaround-setup-svn-mode))


(provide "xtal-mode/workaround")

;;;; End
