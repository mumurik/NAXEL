;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/comment.l
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
  (require "xtal-mode/parser")
  )

(in-package :xtal-mode)

(export '(xtal-in-shebang-comment-p
          xtal-in-comment-p
          xtal-in-multiline-comment-p
          xtal-comment-line-p
          xtal-parse-point-syntax

          goto-matched-multi-line-comment
          goto-beginning-of-multi-line-comment
          goto-end-of-multi-line-comment

          xtal-toggle-comment-line
          xtal-comment-region
          xtal-uncomment-region
          ))


(defparameter *xtal-comment-start-regexp*
  (re-union (list "//" "#!" "/\\*")))

(defparameter *xtal-comment-end-regexp*
  (re-union (list "\n" "\\*/")))

(defparameter *xtal-comment-line-regexp*
  (concat "^" (re-space) *xtal-comment-start-regexp*))


(defun xtal-in-shebang-comment-p (&optional (point (point)))
  (save-excursion
    (goto-char point)
    (current-line-eval (:stay)
      (and (scan-buffer "#!" :reverse t :no-dup t)
           (not (parse-point-syntax))))))

(defun xtal-in-comment-p (&optional (point (point)))
  (eq (xtal-parse-point-syntax point) :comment))

(defun xtal-in-multiline-comment-p (&optional (point (point)))
  (eq (parse-point-syntax (beginning-of-line-point point)) :comment))

(defun xtal-comment-line-p ()
  (current-line-eval (:bol)
    (or (eq (xtal-parse-point-syntax) :comment)
        (looking-at *xtal-comment-line-regexp*))))

(defun xtal-beginning-of-one-line-comment-p ()
  (looking-bol "^//"))

(defun xtal-parse-point-syntax (&optional (point (point)) other)
  (or (parse-point-syntax point)
      (if (xtal-in-shebang-comment-p point)
          :comment
        other)))


(defun xtal-skip-comment-forward ()
  (cursor-moved?
    (loop
      (xtal-skip-comment *xtal-comment-end-regexp*
                         1 :no-dup nil :reverse nil :tail t)
      (or (forward-char)
          (return))
      (unless (xtal-in-comment-p)
        (backward-char)
        (return)))))

(defun xtal-skip-comment-backward ()
  (cursor-moved?
    (loop
      (xtal-skip-comment *xtal-comment-start-regexp*
                         -1 :no-dup t :reverse t :tail nil)
      (or (backward-char)
          (return))
      (unless (xtal-in-comment-p)
        (forward-char)
        (return)))))

(defun xtal-skip-comment (re direction &key no-dup reverse tail)
  (cursor-moved?
    (while (eq (xtal-parse-point-syntax) :comment)
      (unless (or (scan-buffer re :regexp t :no-dup no-dup :reverse reverse :tail tail)
                  (forward-char direction))
        (return)))))

(defun xtal-skip-white-spaces-or-comment-forward ()
  (xtal-skip-syntax-forward :white-spaces :comment))

(defun xtal-skip-white-spaces-or-comment-backward ()
  (xtal-skip-syntax-backward :white-spaces :comment))

(defparameter *multi-line-comment-regexp*
  (re-union (list (re-capture (regexp-quote "/*"))
                  (re-capture (regexp-quote "*/")))))

(defun goto-matched-multi-line-comment ()
  (cond ((looking-around "/*")
         (goto-end-of-multi-line-comment (match-end 0)))
        ((looking-around "*/")
         (goto-beginning-of-multi-line-comment (match-beginning 0)))
        (t
         nil)))

(defun goto-beginning-of-multi-line-comment (&optional (start (point)))
  (goto-multi-line-comment0 start 2 :reverse t :tail nil))

(defun goto-end-of-multi-line-comment (&optional (start (point)))
  (goto-multi-line-comment0 start 1 :reverse nil :tail t))

(defun goto-multi-line-comment0 (start failer-group &key reverse tail)
  (let ((pt (regexp-matched-point start failer-group
                                  *multi-line-comment-regexp*
                                  :reverse reverse :tail tail)))
    (when pt (goto-char pt))))

(defun regexp-matched-point (start failer-group re &key reverse tail)
  (save-excursion
    (goto-char start)
    (while (scan-buffer re :regexp t :reverse reverse :tail tail :no-dup t)
      (when (save-excursion (and (forward-char (if tail -1 1))
                                 (eq (parse-point-syntax) :comment)))
        (if (match-beginning failer-group)
            (return nil)
          (return (point)))))))


;;; command

(defun xtal-toggle-comment-line ()
  (interactive "*")
  (with-current-line-points (begin end)
    (unless (xtal-in-multiline-comment-p)
      (if (or (xtal-in-comment-p) (xtal-beginning-of-one-line-comment-p))
          (xtal-uncomment-region begin end)
        (xtal-comment-region begin end)))))

(defun xtal-comment-region (begin end)
  (interactive "*r")
  (if (< end begin) (rotatef begin end))
  (with-narrowing (begin end :line)
    (goto-char (point-min))
    (loop
      (goto-bol)
      (insert comment-start)
      (unless (forward-line 1) (return)))))

(defun xtal-uncomment-region (begin end)
  (interactive "*r")
  (if (< end begin) (rotatef begin end))
  (with-narrowing (begin end :line)
    (goto-char (point-min))
    (replace-buffer "^// ?" "" :regexp t)))


(defun xtal-mode-setup-comment ()
  ;; indent-for-comment‚Å‘}“ü‚³‚ê‚é“z
  (setf comment-start "// " comment-end "")
  (setf comment-start-skip "//+[ \t]*")
  (setf comment-indent-function 'c-comment-indent) ; c-mode‚ð—¬—p
  (when *xtal-comment-column*
    (setf comment-column *xtal-comment-column*)))


(provide "xtal-mode/comment")

;;;; End
