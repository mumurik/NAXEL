;;; -*- Mode: Lisp -*-
;;  keymap:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       keymap is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :anything)

(export '(*anything-mode-map*))

(unless *anything-mode-map*
  (setq *anything-mode-map* (make-sparse-keymap))
  (define-key *anything-mode-map* #\C-p 'anything-previous-line)
  (define-key *anything-mode-map* #\Up 'anything-previous-line)
  (define-key *anything-mode-map* #\C-n 'anything-next-line)
  (define-key *anything-mode-map* #\Down 'anything-next-line)
  (define-key *anything-mode-map* #\C-v 'anything-next-source)
  (define-key *anything-mode-map* #\M-v 'anything-previous-source)
  (define-key *anything-mode-map* #\C-M-p 'anything-previous-page)
  (define-key *anything-mode-map* #\PageUp 'anything-previous-page)
  (define-key *anything-mode-map* #\C-M-n 'anything-next-page)
  (define-key *anything-mode-map* #\PageDown 'anything-next-page)
  (define-key *anything-mode-map* #\C-h 'anything-backward-char)
  (define-key *anything-mode-map* #\C-l 'anything-recenter)
  (define-key *anything-mode-map* #\C-g 'anything-quit)
  (define-key *anything-mode-map* #\C-@ 'anything-set-mark-action)
  (define-key *anything-mode-map* #\C-i 'anything-action-tab)
  (define-key *anything-mode-map* #\RET 'anything-action-return)
  (define-key *anything-mode-map* #\LFD 'anything-action-return)
  (define-key *anything-mode-map* #\C-s 'anything-isearch-forward)
  (define-key *anything-mode-map* #\C-r 'anything-isearch-backward)
  (define-key *anything-mode-map* #\C-z 'anything-upper-directory)
  (define-key *anything-mode-map* #\C-M-v 'anything-scroll-other-window)
  )

(defun anything-previous-line (&optional (arg 1))
  (interactive "p")
  (anything-move-selection 'line 'previous arg))

(defun anything-next-line (&optional (arg 1))
  (interactive "p")
  (anything-move-selection 'line 'next arg))

(defun anything-previous-page (&optional arg)
  (interactive)
  (anything-move-selection 'page 'previous arg))

(defun anything-next-page (&optional arg)
  (interactive)
  (anything-move-selection 'page 'next arg))

(defun anything-previous-source (&optional (arg 1))
  (interactive "p")
  (anything-move-selection 'source 'previous arg))

(defun anything-next-source (&optional (arg 1))
  (interactive "p")
  (anything-move-selection 'source 'next arg))

(defun anything-action-tab()
  (interactive)
  (anything-get-action 'tab))

(defun anything-action-return()
  (interactive)
  (anything-get-action 'ret)
  (minibuffer-exit))

(defun anything-backward-char()
  (interactive)
  (backward-delete-char-untabify)
  (with-anything-window
   (get-category (point))
   (sources-history(get-category-contents 0))
   (backward-char))
  (setq *anything-attribute-buffer* nil))

(defun anything-recenter(&optional (arg nil))
  (interactive "p")
  (with-anything-window(recenter arg)))

(defun anything-quit()
  (interactive)
  (setq *anything-execute-action-list* nil)
  (minibuffer-exit))

(defun anything-set-mark-action()
  (interactive)
  (anything-set-marker))
                      
(defun anything-scroll-other-window()
  (interactive)
  (with-selected-window
    (other-window)
    (scroll-up-other-window (window-height))))

;;(scroll-other-window (window-height))  ;;  strange name

(provide :anything/api/keymap)
;;end
