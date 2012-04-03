; $Id: history.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(require "2ch/bookmark")

(provide "2ch/history")

(in-package "2ch")

(defvar *history-back* nil)
(defvar *history-forward* nil)

(defvar *history-save-size* 30)

(defvar *history-map* nil)
(setq *history-map* (make-sparse-keymap))
(define-key *history-map* #\RET 'history-select)
(define-key *history-map* #\SPC 'history-select)
(define-key *history-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *history-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *history-map* #\q 'bookmark-quit)
(define-key *history-map* #\d 'history-delete)
(define-key *history-map* #\D 'history-clear)
(define-key *history-map* #\M-t 'toggle-online)
(define-key *history-map* #\Q 'exit)
(define-key *history-map* #\C-M-Right 'bookmark-next)
(define-key *history-map* #\C-M-Left 'bookmark-previous)

(defun history-mode ()
  (bookmark-mode)
  (setq buffer-mode '2ch-history)
  (use-keymap *history-map*))

(defvar *buffer-history* "2ch: History")

(defun set-buffer-history ()
  (if (find-buffer *buffer-history*)
      (set-buffer *buffer-history*)
    (progn
      (set-buffer (get-buffer-create *buffer-history*))
      (history-mode))))

(defun history-open ()
  (interactive)
  (let (curwin)
    (unless (equal buffer-mode '2ch-history)
      (when (equal buffer-mode '2ch-thread)
	(thread-tbk-save))
      (setq curwin (current-window-configuration))
      (set-buffer-history)
      (setq bookmark-old-winconf curwin)
      (delete-other-windows)
      (history-show))))

(defun history-show ()
  (let ((i 0)
	(line 1)
	(history-list (history-list))
	(current (history-current))
	(buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (dolist (history history-list)
      (let ((this (equal history current)))
	(incf i)
	(bookmark-insert-line history this)
	(when this
	  (setq line i))))
    (goto-line line)
  ))

(defun history-select ()
  (interactive)
  (let ((history-list (history-list))
	(num (1- (current-line-number)))
	current)
    (unless (< num (list-length history-list))
      (return-from history-select))
    (when (setq current (nth num history-list))
      (setq *history-forward* (reverse (butlast history-list (- (list-length history-list) num))))
      (setq *history-back* (nthcdr num history-list))
      (bookmark-quit)
      (bookmark-go current))))

(defun history-delete ()
  (interactive)
  (let ((history-list (history-list))
	(num (1- (current-line-number)))
	current)
    (unless (< num (list-length history-list))
      (return-from history-delete))
    (when (setq current (nth num history-list))
      (history-del current)
      (history-save)
      (history-show))))

(defun history-list ()
  (append (reverse *history-forward*) *history-back*))

(defun history-save ()
  (let* ((history-list (history-list))
	 (history-length (list-length history-list)))
    (when (> history-length *history-save-size*)
      (setq history-list (butlast history-list (- history-length *history-save-size*))))
    (history-write history-list *history-save-file*)))

(defun history-load ()
  (setq *history-back* (history-read *history-save-file*))
  (setq *history-forward* nil))

(defun history-write (list file)
  (with-open-file (s file
		     :direction :output
		     :if-exists :overwrite
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" list)))

(defun history-read (file)
  (let (list)
    (when (file-exist-p file)
      (with-open-file (s file
			 :direction :input)
	(let (line)
	  (while (setq line (read s nil))
	    (push line list)))))
    (nreverse list)))

(defun history-del (history)
  (setq *history-back* (delete history *history-back* :test #'equal))
  (setq *history-forward* (delete history *history-forward* :test #'equal)))

(defun history-exist (history)
  (or (member history *history-back* :test #'equal)
      (member history *history-forward* :test #'equal)))

(defun history-add ()
  (let ((history (thread-bookmark-get))
	(current (history-current)))
    (when (and history
	       (not (equal history current)))
      (history-del history)
      (push history *history-back*)
      (history-save))))

(defun history-move-next ()
  (push (pop *history-forward*) *history-back*))

(defun history-move-previous ()
  (push (pop *history-back*) *history-forward*))

(defun history-next ()
  (interactive)
  (unless *history-forward*
    (message "2ch: No history.")
    (return-from history-next))
  (history-move-next)
  (history-current-show))

(defun history-previous ()
  (interactive)
  (when (>= 1 (list-length *history-back*))
    (message "2ch: No history.")
    (return-from history-previous))
  (history-move-previous)
  (history-current-show))

(defun history-current-show ()
  (let ((history (history-current)))
    (when history
      (bookmark-go history))))

(defun history-current ()
  (car *history-back*))

(defun history-clear ()
  (interactive)
  (setq *history-forward* nil)
  (setq *history-back* nil)
  (history-save)
  (history-show))

(define-key *thread-map* '(#\C-c #\Right) 'history-next)
(define-key *thread-map* '(#\C-c #\Left) 'history-previous)
(define-key *thread-map* '(#\C-c #\Up) 'history-open)

(define-key *menu-map* '(#\C-c #\Right) 'history-next)
(define-key *menu-map* '(#\C-c #\Left) 'history-previous)
(define-key *menu-map* '(#\C-c #\Up) 'history-open)

(define-key *board-map* '(#\C-c #\Right) 'history-next)
(define-key *board-map* '(#\C-c #\Left) 'history-previous)
(define-key *board-map* '(#\C-c #\Up) 'history-open)

(define-key *tracking-map* '(#\C-c #\Right) 'history-next)
(define-key *tracking-map* '(#\C-c #\Left) 'history-previous)
(define-key *tracking-map* '(#\C-c #\Up) 'history-open)

(define-key *search-map* '(#\C-c #\Right) 'history-next)
(define-key *search-map* '(#\C-c #\Left) 'history-previous)
(define-key *search-map* '(#\C-c #\Up) 'history-open)

(define-key *form-map* '(#\C-c #\Right) 'history-next)
(define-key *form-map* '(#\C-c #\Left) 'history-previous)
(define-key *form-map* '(#\C-c #\Up) 'history-open)

(define-key *form-new-map* '(#\C-c #\Right) 'history-next)
(define-key *form-new-map* '(#\C-c #\Left) 'history-previous)
(define-key *form-new-map* '(#\C-c #\Up) 'history-open)

(define-key *http-map* '(#\C-c #\Right) 'history-next)
(define-key *http-map* '(#\C-c #\Left) 'history-previous)
(define-key *http-map* '(#\C-c #\Up) 'history-open)

(define-key *bookmark-map* '(#\C-c #\Right) 'history-next)
(define-key *bookmark-map* '(#\C-c #\Left) 'history-previous)
(define-key *bookmark-map* '(#\C-c #\Up) 'history-open)
