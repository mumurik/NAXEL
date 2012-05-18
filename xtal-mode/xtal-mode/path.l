;;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/path.l
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

(export '(xtal-open-install-path-by-command-prompt
          xtal-open-install-path-by-explorer
          ))


(defun xtal-install-path ()
  (let ((path (xtal-install-path0)))
    (unless (and (valid-path-p path)
                 (file-exist-p path))
      (error (concat "~A ディレクトリが見つかりません\n"
                     "*xtal-install-path* を正しく設定してください")
             path))
    path))

(defun xtal-install-path0 ()
  (case (type-of *xtal-install-path*)
    (simple-string *xtal-install-path*)
    (function (funcall *xtal-install-path*))
    (t
     (error 'type-error
            :datum *xtal-install-path*
            :expected-type '(or string function)))))

(defun xtal-bin-path ()
  (let* ((inst (xtal-install-path))
         (bin (merge-pathnames "bin" inst)))
    (if (and (file-exist-p bin)
             (file-directory-p bin))
        bin
      ;; xtal 0.9.7 以前
      inst)))

(defun xtal-command-path (exe)
  (map-slash-to-backslash (merge-pathnames exe (xtal-bin-path))))

(defun xtal-ensure-command (exe)
  (let ((path (xtal-command-path exe)))
    (unless (file-exist-p path)
      (error (concat "~A が見つかりません\n"
                     "*xtal-install-path* を正しく設定してください")
             path))))

(defmacro with-xtal-install-path ((var) &body body)
  `(let ((,var (map-slash-to-backslash (xtal-install-path))))
     ,@body))
(setf (get 'with-xtal-install-path 'ed:lisp-indent-hook) 'with-open-file)


;;; command

(defun xtal-open-install-path-by-command-prompt ()
  (interactive)
  (with-xtal-install-path (path)
    (let ((ed::*launch-app-directory* path))
      (run-console))))

(defun xtal-open-install-path-by-explorer ()
  (interactive)
  (with-xtal-install-path (path)
    (call-process (format nil "explorer.exe /e,\"~A\"" path))))


(provide "xtal-mode/path")

;;;; End
