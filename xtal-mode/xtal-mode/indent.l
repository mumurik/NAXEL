;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/indent.l
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
  (require "xtal-mode/comment")
  )

(in-package :xtal-mode)

(export '(xtal-indent-buffer
          ))

; map to c-*
(defparameter *xtal-continued-statement-offset* *xtal-indent-level*)
(defparameter *xtal-brace-offset* (- *xtal-indent-level*))
(defparameter *xtal-brace-imaginary-offset* 0)
(defparameter *xtal-argdecl-indent* 0)
(defparameter *xtal-label-offset* 0)


(defparameter *xtal-last-electric-insert-char* nil)
(defparameter *xtal-electric-insert-pair*
  '((#\{ #\} t)
    (#\( #\) nil)
    (#\[ #\] nil)
    ))

(defun xtal-electric-insert (&optional (arg 1))
  (interactive "*p")
  (self-insert-command arg)
  (xtal-indent-line)
  (when (and *xtal-electric-insert-close-parentheses*
             (eolp))
    (save-excursion
      (xtal-electric-insert-close-parentheses arg))))

(defun xtal-electric-insert-close-parentheses (&optional (arg 1))
  (let* ((o *last-command-char*)
         (c (assoc o *xtal-electric-insert-pair*))
         (pair (second c))
         (newline? (third c)))
    (flet ((insert-pairs ()
             (dotimes (i arg)
               (insert-chars-if-not pair))))
      (setf *xtal-last-electric-insert-char* pair)
      (cond (newline?
             (unless (matched-close-parentheses-exist-p)
               (insert #\LFD)
               (insert-pairs)
               (xtal-indent-line)))
            (t
             (insert-pairs))))))

(defun matched-close-parentheses-exist-p ()
  (save-excursion
    (let ((open-indent (current-line-indent)))
      (when (and (backward-char)
                 (goto-matched-parenthesis)
                 (= open-indent (current-line-indent)))
        (ed::show-matched-parenthesis)
        t))))

(defun xtal-electric-close (&optional (arg 1))
  (interactive "*p")
  (when (and *xtal-electric-insert-close-parentheses*
             (eq *last-command* 'xtal-electric-insert)
             (equal *xtal-last-electric-insert-char* *last-command-char*))
    (xtal-skip-white-spaces-forward)
    (forward-char)
    (decf arg))
  (self-insert-command arg)
  (xtal-indent-line)
  (save-excursion
    (forward-char -1)
    (and (goto-matched-parenthesis)
         (ed::show-matched-parenthesis)))
  t)

(defun xtal-electric-string (&optional (arg 1))
  (interactive "*p")
  (when (or (not (= arg 1))
            (not *xtal-electric-insert-close-string*))
    (self-insert-command arg)
    (return-from xtal-electric-string))
  (if (and (after-char= #\")
           (eq (xtal-parse-point-syntax) :string))
      ;; 既に閉じられている
      (forward-char)
    (progn
      (self-insert-command arg)
      ;; 文字列中でカーソルの後に何もないときだけ文字列を自動的に閉じる
      (when (and (eolp)
                 (eq (xtal-parse-point-syntax) :string))
        (self-insert-command arg)
        (backward-char)))))

(defun xtal-newline-and-indent (&optional (arg 1))
  (interactive "*p")
  (delete-trailing-spaces)
  (insert #\LFD arg)
  (xtal-indent-line))

; from c-indent-line
(defun xtal-indent-line ()
  (interactive "*")
  ; (indent-region (point-min) (point-max)) とされた場合、
  ; 時間がかかって画面が白くなるのを防ぐ
  ; ただし、インデント作業中の画面が描画されることがあるがしかたない。
  (do-events)
  (if (or (not (interactive-p))
          *c-tab-always-indent*
          (save-excursion
            (skip-chars-backward " \t")
            (bolp)))
      (case (save-excursion
              (goto-bol)
              (parse-point-syntax))
        (:string)
        (:comment
         (xtal-smart-comment-indentation))
        (t
         (let ((column (calc-xtal-indent)))
           (when (integerp column)
             (smart-indentation column)))))
    (insert "\t"))
  t)

(defun xtal-previous-line ()
  (cursor-moved?
    (while (and (backward-line) (goto-eol))
      (xtal-skip-white-spaces-or-comment-backward)
      (unless (xtal-comment-line-p)
        (return)))))

(defun fixup-calc-c-indent (before-char column)
  (when (char= before-char #\|)
    (current-line-eval (:stay)
      (when (xtal-skip-block-parameter-backward)
        (xtal-skip-white-spaces-or-comment-backward)
        (when (bolp)
          (- column *xtal-continued-statement-offset*))))))

(defun calc-xtal-indent ()
  (let ((column (calc-c-indent)))
    (unless (integerp column)
      (setf column 0))
    (save-excursion
      (if (xtal-previous-line)
          (or (fixup-calc-c-indent (char-before (point)) column)
              column)
        column))))

(defun xtal-previous-comment-line ()
  (cursor-moved?
    (while (backward-line)
      (unless (space-line-p)
        (return)))))

(defun xtal-smart-comment-indentation ()
  (let ((column (or (save-excursion
                      (when (and (xtal-previous-comment-line)
                                 (skip-chars-forward " \t/"))
                        (current-column)))
                    (ed::calc-c-comment-indent)
                    0)))
    (save-excursion
      (goto-bol)
      (smart-indentation column)
      (unless (looking-for "*/")
        (insert-chars-if-not #\* #\SPC)))
    (skip-chars-forward " \t*/")
    (save-excursion
      (unless (or (looking-around "*/")
                  (save-excursion (goto-end-of-multi-line-comment)))
        (insert #\LFD)
        (smart-indentation column)
        (insert-chars-if-not #\* #\/)))))


;;; command

(defun xtal-indent-buffer ()
  (interactive "*")
  (message "indent buffer ...")
  (long-operation
    (save-excursion
      ;; indent-region は 1 行目をインデントしない
      (goto-char (point-min))
      (xtal-indent-line)
      (indent-region (point-min) (point-max))))
  (message "indent buffer ... done."))


(defun xtal-mode-setup-indent ()
  (set-local-variable c-indent-level *xtal-indent-level*)
  (set-local-variable c-continued-statement-offset *xtal-continued-statement-offset*)
  (set-local-variable c-brace-offset *xtal-brace-offset*)
  (set-local-variable c-brace-imaginary-offset *xtal-brace-imaginary-offset*)
  (set-local-variable c-argdecl-indent *xtal-argdecl-indent*)
  (set-local-variable c-label-offset *xtal-label-offset*)

  (set-local-variable mode-specific-indent-command 'xtal-indent-line)
  (set-local-variable mode-newline-and-indent-command 'xtal-newline-and-indent)
  )

(provide "xtal-mode/indent")

;;;; End
