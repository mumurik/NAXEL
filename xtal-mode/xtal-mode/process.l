;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/process.l
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
  (require "xtal-mode/path")
  )

(in-package :xtal-mode)

(export '(xtal-run-with-current-buffer
          xtal-close-output-buffer
          xtal-first-error
          ))


(defmacro with-runnning-process ((var) &body body)
  `(let ((,var (buffer-process (selected-buffer))))
     (when (and ,var (eq (process-status ,var) :run))
       ,@body)))
(setf (get 'with-runnning-process 'ed:lisp-indent-hook) 'with-open-file)


(defun buffer-process-running? (&optional (buffer (selected-buffer)))
  (process-running? (buffer-process buffer)))

(defun process-running? (proc)
  (and proc (eq (process-status proc) :run)))

(defun wait-for-process-terminate (proc)
  (while (process-running? proc)
    (sit-for 0.1)))

(defun xtal-command-line (exe &optional options filename)
  (xtal-ensure-command exe)
  (flet ((q (arg)
           (let ((arg (map-slash-to-backslash arg)))
             (if (string-match " " arg)
                 (concat "\"" arg "\"")
               arg))))
    (format nil "~A ~{~A~^ ~} ~A"
            (q (xtal-command-path exe))
            options
            (q (or filename "")))))

(defun xtal-kill-process (buffer)
  (with-temporary-set-buffer (buffer)
    (with-runnning-process (proc)
      (message "kill xtal proces... ")
      (kill-subprocess)
      (wait-for-process-terminate proc)
      (message "kill xtal proces... done"))))

(defun setup-process-buffer (name &key (kill t))
  (let* ((first? (not (find-buffer name)))
         (output (get-buffer-create name)))
    (with-temporary-set-buffer (output)
      (when first?
        (setup-temp-buffer output))
      (when kill
        (xtal-kill-process output))
      (unless (buffer-process-running? output)
        (erase-buffer output)))
    (values output first?)))

(defun popup-to-output-buffer (output height &key move callback)
  (let ((original (selected-window)))
    (unless (get-buffer-window output)
      (split-window height)
      (set-buffer output))
    (when callback
      (set-window (get-buffer-window output))
      (funcall callback))
    (set-window (if move
                    (get-buffer-window output)
                  original))))


;;; for xtal.exe

(defun make-xtal-process (filename output)
  (make-process (xtal-command-line *xtal-command-xtal* nil filename)
                :output output))

(defun xtal-process-sentinel (proc)
  (run-hook-with-args '*xtal-after-run-xtal-hook* proc))

(defun xtal-process-sentinel-for-temp (proc)
  (xtal-process-sentinel proc)
  (xtal-fixup-temp-file proc))

(defun xtal-fixup-temp-file (proc)
  (let* ((output (process-buffer proc))
         (tmp? (buffer-local-value output 'xtal-tmp-file-p))
         (tmp (buffer-local-value output 'xtal-tmp-file))
         (src (buffer-local-value output 'xtal-src-file)))
    (when (and output tmp? tmp src)
      (with-temporary-set-buffer (output)
        (goto-char (point-min))
        (replace-buffer (map-slash-to-backslash tmp) src))
      (delete-file tmp :if-does-not-exist :skip :if-access-denied :skip))))

(defun xtal-setup-output-buffer ()
  (multiple-value-bind (output first?)
      (setup-process-buffer *xtal-mode-output-buffer-name*)
    (when first?
      (run-hooks '*xtal-create-output-buffer-hook*))
    output))

(defun find-xtal-output-buffer ()
  (find-buffer *xtal-mode-output-buffer-name*))

(defun popup-to-xtal-output-buffer (output &optional fn)
  (popup-to-output-buffer output *xtal-command-output-window-height*
                          :callback fn
                          :move nil))


;;; command

(defun xtal-run-with-current-buffer ()
  (interactive)
  (xtal-ensure-command *xtal-command-xtal*)
  (let ((buf (selected-buffer))
        (output (xtal-setup-output-buffer)))
    (xtal-save-buffer-if-need (selected-buffer))
    (popup-to-xtal-output-buffer output)
    (run-hooks '*xtal-before-run-xtal-hook*)
    (multiple-value-bind (filename tmp?)
        (buffer->filename buf)
      (with-temporary-set-buffer (output)
        (set-local-variable xtal-tmp-file-p tmp?)
        (set-local-variable xtal-tmp-file filename)
        (set-local-variable xtal-src-file (get-buffer-file-name buf)))
      (let ((proc (make-xtal-process filename output)))
        (set-process-sentinel proc (if tmp?
                                       'xtal-process-sentinel-for-temp
                                     'xtal-process-sentinel))
        (run-hook-with-args '*xtal-run-xtal-hook* proc)))))

(defun xtal-close-output-buffer ()
  (interactive)
  (let ((output (find-xtal-output-buffer)))
    (unless output
      (return-from xtal-close-output-buffer nil))
    (xtal-kill-process output)
    (delete-buffer-and-window output)))

(defun xtal-first-error ()
  (interactive)
  (let ((output (find-xtal-output-buffer)))
    (when output
      (popup-to-xtal-output-buffer output #'(lambda ()
                                              (goto-char (point-min))
                                              (first-error))))))


(provide "xtal-mode/process")

;;;; End
