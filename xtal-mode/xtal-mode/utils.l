;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/utils.l
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

(defun make-string (&rest args)
  (with-output-to-string (s)
    (dolist (o args)
      (princ o s))))

(defun symbol-join (&rest args)
  (values (intern (apply 'make-string args))))


(defun re-space ()
  "[ \t]*")

(defun re-capture (re)
  (concat "\\(" re "\\)"))

(defun re-group (re)
  (concat "\\(?:" re "\\)"))

(defun re-opt (relst)
  (format nil "\\(?:~{~A~}\\)?" relst))

(defun re-union (relst)
  (format nil "\\(?:~{~A~^\\|~}\\)" relst))

(defun re-repeat-with (separator re)
  (concat (re-group re)
          (concat
           (re-group (concat (re-space) separator (re-space) re))
           "*")))

(defun buffer-substring-and-delete (start end)
  (prog1
      (buffer-substring start end)
    (delete-region start end)))

(defun current-line-point-values ()
  (values-list (current-line-points)))

(defun current-line-points ()
  (save-excursion
    (list (progn (goto-bol) (point))
          (progn (goto-eol) (point)))))

(defun bol-point ()
  (car (current-line-points)))

(defun eol-point ()
  (cadr (current-line-points)))

(defun beginning-of-line-point (&optional (pt (point)))
  (save-excursion
    (goto-char pt)
    (goto-bol)
    (point)))

(defun end-of-line-point (&optional (pt (point)))
  (save-excursion
    (goto-char pt)
    (goto-eol)
    (point)))

(defun open-url-command (url)
  #'(lambda ()
      (interactive)
      (shell-execute url t)))


(defun looking-around (str)
  (let ((opoint (point)))
    (save-excursion
      (and (scan-buffer str :reverse t :no-dup nil :limit (- (point) (length str)))
           (<= (match-beginning 0) opoint (match-end 0))))))

(defun before-char= (char)
  (char= (char-before (point)) char))

(defun after-char= (char)
  (char= (char-after (point)) char))

(defun insert-chars-if-not (&rest chars)
  (dolist (c chars)
    (if (after-char= c)
        (forward-char)
      (insert c))))

(defun marker-line-number (marker)
  (if marker
      (save-excursion
        (goto-marker marker)
        (current-line-number))
    -1))


(provide "xtal-mode/utils")

;;;; End
