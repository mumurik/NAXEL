;;; -*- mode: lisp; package: xtal-mode -*-
;;;;
;;;; File: xtal-mode/ix-mode.l
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
  (require "xtal-mode/keyword")
  (require "xtal-mode/process")
  )

(in-package :xtal-mode)

(export '(*ix-mode-hook*
          *ix-mode-after-kill-hook*
          *ix-mode-map*
          *ix-ret*
          *ix-prompt-regexp*
          *ix-prompt-regexp-color*
          ix
          ix-console
          ix-mode
          ix-send-input
          ix-send-interrupt
          ))

(defvar *ix-mode-hook* nil)
(defvar *ix-mode-after-kill-hook* nil)
(defvar-local *ix-ret* "\n")
(defparameter *ix-prompt-regexp* "^ix:[0-9]+>")
(defparameter *ix-prompt-regexp-color* '(:keyword 0))

(defparameter *ix-mode-map* nil)
(unless *ix-mode-map*
  (setq *ix-mode-map* (make-sparse-keymap))
  (define-key *ix-mode-map* #\RET 'ix-send-input)
  (define-key *ix-mode-map* '(#\C-c #\C-c) 'ix-send-interrupt)
  (define-key *ix-mode-map* '(#\C-c #\0) 'ix-kill-buffer)

  (define-key *ix-mode-map* #\C-a 'ix-beginning-of-line)
  (define-key *ix-mode-map* #\C-b 'ix-backward-char)
  (define-key *ix-mode-map* #\C-f 'ix-forward-char)
  (define-key *ix-mode-map* #\C-d 'ix-delete-char-or-selection)
  (define-key *ix-mode-map* #\C-h 'ix-backward-delete-char-untabify-or-selection)

  (define-key *ix-mode-map* #\M-n 'ix-next-virtual-line)
  (define-key *ix-mode-map* #\M-p 'ix-previous-virtual-line)

  (define-key *ix-mode-map* #\C-M-n 'ix-forward-prompt)
  (define-key *ix-mode-map* #\C-M-p 'ix-backward-prompt)

  (define-key *ix-mode-map* #\Up 'ix-previous-history-or-virtual-line)
  (define-key *ix-mode-map* #\C-p 'ix-previous-history-or-virtual-line)
  (define-key *ix-mode-map* #\Down 'ix-next-history-or-virtual-line)
  (define-key *ix-mode-map* #\C-n 'ix-next-history-or-virtual-line)
  (define-key *ix-mode-map* #\M-q 'ix-push-current-line)
  )


(defun ix-console ()
  (interactive)
  (xtal-ensure-command *xtal-command-ix*)
  (launch-application (xtal-command-line *xtal-command-ix*)))

(defun ix ()
  (interactive)
  (xtal-ensure-command *xtal-command-ix*)
  (let ((output (setup-process-buffer *xtal-ix-buffer-name* :kill nil)))
    (popup-to-output-buffer output *xtal-ix-window-height* :move t)
    (goto-char (point-max))
    (ix-mode)
    (unless (buffer-process-running?)
      (make-ix-process (selected-buffer)))))

(defun ix-mode ()
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "ix")
  (setq buffer-mode 'ix-mode)
  (setq need-not-save t)
  (setq auto-save nil)
  (setq kept-undo-information nil)
  (set-buffer-fold-width 80)
  (use-keymap *ix-mode-map*)
  (xtal-load-keyword-file-once :ignore-case nil)
  (set-local-variable keyword-hash-table *xtal-keyword-hash-table*)
  (set-local-variable regexp-keyword-list
                      (compile-regexp-keyword-list
                       `(,@*xtal-regexp-keyword-list*
                         (,*ix-prompt-regexp* t ((0 . ,*ix-prompt-regexp-color*)))
                         )))
  (run-hooks '*ix-mode-hook*))

(defun make-ix-process (output)
  (make-process (xtal-command-line *xtal-command-ix* nil nil)
                :output output))

(defun buffer-ix-mode-p (&optional (buffer (selected-buffer)))
  (eq (buffer-local-value buffer 'buffer-mode) 'ix-mode))

(defun ix-current-marker ()
  (process-marker (buffer-process (selected-buffer))))

(defun ix-prompt-reset ()
  (when (and (ix-beginning-of-line)
             (not (eolp)))
    (kill-line)))

(defun ix-kill-buffer ()
  (interactive)
  (when (buffer-ix-mode-p)
    (let ((buf (selected-buffer)))
      (ix-send-interrupt)
      (delete-buffer-and-window buf))))

(defun ix-send-interrupt ()
  (interactive)
  (with-runnning-process (proc)
    (kill-subprocess)
    (wait-for-process-terminate proc)
    (run-hook-with-args '*ix-mode-after-kill-hook* proc)))

(defun ix-send-input ()
  (interactive)
  (with-runnning-process (process)
    (multiple-value-bind (start end prompt)
        (ix-mode-current-input process)
      (when (and start end)
        (goto-char end)
        (ix-send-input0 process (buffer-substring start end) prompt)
        ;; process-filter は遅すぎて使えない
        (when (and (ix-push-line-exist?)
                   (ix-wait-for-prompt process))
          (ix-pop-line-and-insert))))))

(defun ix-mode-current-input (process)
  (let ((last-ix-output-point (marker-point (process-marker process))))
      (cond ((<= last-ix-output-point (point))
             (values last-ix-output-point (eol-point) nil))
            ((looking-bol *ix-prompt-regexp*)
             (values (match-end 0) (eol-point) (match-string 0))))))

(defun ix-send-input0 (process command prompt)
  (flet ((past-input-p ()
           (not (eobp)))
         (copy-past-command-line ()
           (goto-marker (process-marker process))
           (ix-push-current-line)
           (insert command)))
    (when (past-input-p)
      (copy-past-command-line))
    (delete-trailing-spaces)
    (insert "\n")
    (set-marker (process-marker process))
    (when (and command (< 0 (length command)))
      (ix-history-push command)
      (reset-command-history-index))
    (process-send-string process (concatenate 'string command *ix-ret*))))

(defun ix-wait-for-prompt (proc)
  (timeout 2
    (do-events) ;; process の出力をバッファに反映
    (unless (process-running? proc)
      (return nil))
    (goto-marker (process-marker proc))
    (when (looking-bol *ix-prompt-regexp*)
      (return t))
    (sit-for 0.1)))


;;; cursor 移動

(defun ix-prompt-line-p ()
  (looking-bol *ix-prompt-regexp*))

(defun ix-current-prompt-line-p ()
  (and (ix-prompt-line-p)
       (eql (marker-line-number (ix-current-marker))
            (current-line-number))))

(defun ix-beginning-of-line-point ()
  (interactive)
  (cond ((ix-current-prompt-line-p)
         (marker-point (ix-current-marker)))
        ((ix-prompt-line-p)
         (match-end 0))
        (t
         (bol-point))))

(defun ix-beginning-of-line-point-p ()
  (<= (bol-point) (point) (ix-beginning-of-line-point)))

(defun ix-beginning-of-line ()
  (interactive)
  (goto-char (ix-beginning-of-line-point)))

(defun ix-backward-char ()
  (interactive)
  (if (ix-beginning-of-line-point-p)
      (and (previous-line)
           (goto-eol))
    (backward-char)))

(defun ix-forward-char ()
  (interactive)
  (forward-char)
  (when (ix-beginning-of-line-point-p)
    (ix-beginning-of-line)))

(defun ix-delete-char-or-selection ()
  (interactive)
  (unless (eolp)
    (delete-char-or-selection)))

(defun ix-backward-delete-char-untabify-or-selection ()
  (interactive)
  (unless (ix-beginning-of-line-point-p)
    (backward-delete-char-untabify-or-selection)))

(defun ix-forward-prompt ()
  (interactive)
  (save-current-point-only-if-fail
    (goto-eol)
    (scan-buffer *ix-prompt-regexp* :regexp t :tail t)))

(defun ix-backward-prompt ()
  (interactive)
  (save-current-point-only-if-fail
    (goto-bol)
    (scan-buffer *ix-prompt-regexp* :regexp t :reverse t :no-dup t :tail t)))

(defun ix-previous-virtual-line ()
  (interactive)
  (previous-virtual-line)
  (when (ix-beginning-of-line-point-p)
    (ix-beginning-of-line)))

(defun ix-next-virtual-line ()
  (interactive)
  (next-virtual-line)
  (when (ix-beginning-of-line-point-p)
    (ix-beginning-of-line)))


;;; history

(defparameter *ix-command-history* nil)
(defparameter *ix-current-history-index* -1)
(defparameter *ix-pushed-line* nil)

(defun ix-push-line-exist? ()
  (not (null *ix-pushed-line*)))

(defun ix-push-line (line)
  (push (list line) *ix-pushed-line*))

(defun ix-pop-line ()
  (or (car (pop *ix-pushed-line*)) ""))

(defun ix-push-current-line ()
  (interactive)
  (ix-beginning-of-line)
  (ix-push-line (buffer-substring-and-delete
                 (point) (eol-point))))

(defun ix-pop-line-and-insert ()
  (interactive)
  (insert (ix-pop-line)))


(defun reset-command-history-index (&optional (index -1))
  (setf *ix-current-history-index* index))

(defun ix-history-push (command)
  (push (list command) *ix-command-history*))

(defun ix-history-backward ()
  (incf *ix-current-history-index*)
  (cond ((< *ix-current-history-index* (length *ix-command-history*))
         (car (nth *ix-current-history-index* *ix-command-history*)))
        (t
         (reset-command-history-index (length *ix-command-history*))
         nil)))

(defun ix-history-forward ()
  (decf *ix-current-history-index*)
  (cond ((<= 0 *ix-current-history-index*)
         (car (nth *ix-current-history-index* *ix-command-history*)))
        (t
         (reset-command-history-index)
         nil)))

(defun ix-previous-history ()
  (interactive)
  (let ((command (ix-history-backward)))
    (if command
        (progn
          (ix-prompt-reset)
          (insert command))
      (message "No previous history."))))

(defun ix-next-history ()
  (interactive)
  (let ((command (ix-history-forward)))
    (ix-prompt-reset)
    (if command
	(insert command)
      (message "No next history."))))

(defun ix-previous-history-or-virtual-line ()
  (interactive)
  (if (ix-current-prompt-line-p)
      (ix-previous-history)
    (ix-previous-virtual-line)))

(defun ix-next-history-or-virtual-line ()
  (interactive)
  (if (ix-current-prompt-line-p)
      (ix-next-history)
    (ix-next-virtual-line)))


(provide "xtal-mode/ix-mode")

;;;; End
