;;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/buffer.l
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
  )

(in-package :xtal-mode)

(defun buffer-xtal-mode-p (&optional (buffer (selected-buffer)))
  (eq (buffer-local-value buffer 'buffer-mode) 'xtal-mode))

(defun one-window-p ()
  (= (count-windows) 1))

(defun delete-buffer-and-window (buffer)
  (let ((now (selected-window))
        (win (get-buffer-window buffer)))
    (when (and win (not (one-window-p)))
      (set-window win)
      (delete-window)
      (unless (equal win now)
        (set-window now)))
    (delete-buffer buffer)))

(defun buffer->filename (buffer)
  (if (and (get-buffer-file-name buffer)
           (not (buffer-modified-p buffer)))
      (values (get-buffer-file-name buffer) nil)
    (values (create-temp-buffer-file buffer) t)))

(defun create-temp-buffer-file (buffer)
  (let ((tmp (make-temp-file-name "xtal-mode" "xtal")))
    (save-excursion
      (set-buffer buffer)
      (write-file tmp))
    tmp))

(defun xtal-save-buffer-if-need (buffer)
  (when (and (get-buffer-file-name buffer)
             (buffer-modified-p buffer))
    (with-temporary-set-buffer (buffer)
      (save-buffer))
    t))


(provide "xtal-mode/buffer")

;;;; End
