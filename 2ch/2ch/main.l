; $Id: main.l 699 2006-06-01 03:20:55Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "www/www"))

(defpackage "2ch"
  (:use "lisp" "editor"))

(provide "2ch/main")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(require "2ch/http")
(require "2ch/menu")
(require "2ch/board")
(require "2ch/thread")
(require "2ch/tracking")
(require "2ch/form")
(require "2ch/search")
(require "2ch/popup")
(require "2ch/view")
(require "2ch/bookmark")
(require "2ch/history")
(require "2ch/grep")

(defun 2ch ()
  (interactive)
  (2ch::start))

(defun 2ch-toggle ()
  (interactive)
  (2ch::toggle))

(in-package "2ch")

(defconstant *version* "0.0.1.4-4")

(defconstant *version-name*
  (format nil "2ch-mode-~A" *version*))

(defconstant *monazilla-version* "Monazilla/1.0")

(defvar *2ch-user-agent*
  (format nil "~A (~A [~A])"
	  *monazilla-version*
	  *version-name*
	  www::*www-user-agent*))

(defvar *mode-name* "2ch")
(defvar *pframe-name* "2ch")

(defvar *buffer-temp* "2ch: Temp")

(defvar *online* nil)

(defvar *base-directory* "~/.2ch")
(defvar *config-file-name* "config.l")

(defvar *2ch-base-url* "http://menu.2ch.net/")

(defvar *favorits-name* "‚¨‹C‚É“ü‚è")

(defvar *tracking-name* "’Ç‚Á‚©‚¯ƒXƒŒ")

(defvar *tracking-list-all* nil)

(defvar *thread-archive-file-name* "archive.lzh")

(defvar *config-file*
  (merge-pathnames *config-file-name* *base-directory*))

(defvar *index-file-name* "2ch.html")
(defvar *2ch-url*
  (concat *2ch-base-url* *index-file-name*))

(defvar *menu-file-name* "bbsmenu.html")
(defvar *menu-file*
  (merge-pathnames *menu-file-name* *base-directory*))
(defvar *menu-url*
  (concat *2ch-base-url* *menu-file-name*))

(defvar *menu-save-file-name* "bbsmenu.txt")
(defvar *menu-save-file*
  (merge-pathnames *menu-save-file-name* *base-directory*))

(defvar *favorits-file-name* "favorits.txt")
(defvar *favorits-file*
  (merge-pathnames *favorits-file-name* *base-directory*))

(defvar *tracking-file-name* "tracking.txt")
(defvar *tracking-file*
  (merge-pathnames *tracking-file-name* *base-directory*))

(defvar *tracking-directory-name* "tracking")
(defvar *tracking-directory*
  (merge-pathnames *tracking-directory-name* *base-directory*))

(defvar *thread-archive-file*
  (merge-pathnames *thread-archive-file-name* *base-directory*))

(defvar *form-file-name*
  (merge-pathnames "form-name.txt" *base-directory*))
(defvar *form-file-email*
  (merge-pathnames "form-email.txt" *base-directory*))

(defvar *form-file-save*
  (merge-pathnames "form-save.txt" *base-directory*))
(defvar *form-file-post*
  (merge-pathnames "form-post.txt" *base-directory*))
(defvar *form-file-save-new*
  (merge-pathnames "form-save-new.txt" *base-directory*))
(defvar *form-file-post-new*
  (merge-pathnames "form-post-new.txt" *base-directory*))

(defvar *bookmark-file-name* "bookmark.txt")
(defvar *bookmark-file*
  (merge-pathnames *bookmark-file-name* *base-directory*))

(defvar *history-save-file-name* "history.txt")
(defvar *history-save-file*
  (merge-pathnames *history-save-file-name* *base-directory*))

(defvar *2ch-mouse-single-click* t)

(defvar *2ch-start-hook* nil)
(defvar *2ch-exit-hook* nil)
(defvar *init-variables-hook* nil)

(defvar *2ch-running* nil)

(defvar *2ch-use-dolib* nil)

(defvar *debug* nil)

(defun set-buffer-temp ()
  (set-buffer (get-buffer-create *buffer-temp*))
  (setq need-not-save t)
  (erase-buffer (selected-buffer)))

(defun init ()
  (unless (file-exist-p *base-directory*)
    (create-directory *base-directory*))
  (setq *config-file*
	(merge-pathnames *config-file-name* *base-directory*))
  (let ((lc (concat *config-file* "c")))
    (if (file-exist-p lc)
	(load lc)
      (when (file-exist-p *config-file*)
	(load *config-file*))))
  (init-variables)
  (when *2ch-use-dolib*
    (require "2ch/dolib")
    (when *online*
      (2ch-dolib-init)))
  (unless (file-exist-p *tracking-directory*)
    (create-directory *tracking-directory*))
  (tracking-load-menu)
  (thread-load-archive)
)

(defun init-variables ()
  (setq *thread-archive-file*
	(merge-pathnames *thread-archive-file-name* *base-directory*))
  (setq *tracking-file*
	(merge-pathnames *tracking-file-name* *base-directory*))
  (setq *tracking-directory*
	(merge-pathnames *tracking-directory-name* *base-directory*))
  (setq *favorits-file*
      (merge-pathnames *favorits-file-name* *base-directory*))
  (setq *config-file*
	(merge-pathnames *config-file-name* *base-directory*))
  (setq *menu-file*
	(merge-pathnames *menu-file-name* *base-directory*))
  (setq *menu-url*
	(concat *2ch-base-url* *menu-file-name*))
  (setq *menu-save-file*
	(merge-pathnames *menu-save-file-name* *base-directory*))
  (setq *form-file-name*
	(merge-pathnames "form-name.txt" *base-directory*))
  (setq *form-file-email*
	(merge-pathnames "form-email.txt" *base-directory*))
  (setq *form-file-save*
	(merge-pathnames "form-save.txt" *base-directory*))
  (setq *form-file-post*
      (merge-pathnames "form-post.txt" *base-directory*))
  (setq *form-file-save-new*
      (merge-pathnames "form-save-new.txt" *base-directory*))
  (setq *form-file-post-new*
	(merge-pathnames "form-post-new.txt" *base-directory*))
  (setq *bookmark-file*
	(merge-pathnames *bookmark-file-name* *base-directory*))
  (setq *history-save-file*
	(merge-pathnames *history-save-file-name* *base-directory*))
  (run-hooks '*init-variables-hook*)
)

(defun start ()
  (init)
  (when (frame-get)
    (restore)
    (return-from start))
  (message "2ch: starting ...")
  (new-pseudo-frame *pframe-name*)
  (menu-load)
  (menu-save-restore)
  (bookmark-load)
  (history-load)
  (tracking-uplist-load)
  (thread-bar-create)
  (menu-show)
  (setq *2ch-running* t)
  (message "2ch: starting ... done.")
  (run-hooks '*2ch-start-hook*))

(defun split-2 ()
  (set-buffer-menu)
  (delete-other-windows)
  (when *menu-width*
    (split-window-vertically *menu-width*)
    (other-window 1))
  (setq *board-window* (selected-window)))

(defun exit ()
  (interactive)
  (unless *2ch-running*
    (return-from exit))
  (let ((tb (tool-bar-exist-p 'thread-bar))
	(frame (frame-get)))
    (when (equal buffer-mode '2ch-thread)
      (thread-tbk-save))
    (delete-other-windows)
    (when tb
      (thread-bar-clear))
    (dolist (buf (buffer-list))
      (let ((bufname (buffer-name buf)))
	(when (string-match "^2ch:" bufname)
	  (delete-buffer bufname))))
    (and tb (hide-command-bar 'thread-bar))
    (when frame
      (delete-pseudo-frame frame))
    (menu-save-write)
    (when *2ch-use-dolib*
      (setq *dolib-current-session* nil))
    (setq *2ch-running* nil)
    (run-hooks '*2ch-exit-hook*)))

(defun hide ()
  (interactive)
  (next-pseudo-frame)
  (when (tool-bar-exist-p 'thread-bar)
    (setq *thread-bar-hide* t)
    (hide-command-bar 'thread-bar)))

(defun frame-get ()
  (find-pseudo-frame *pframe-name*))

(defun restore ()
  (interactive)
  (let ((frame (frame-get)))
    (if frame
	(progn
	  (select-pseudo-frame frame)
	  (when *thread-bar-hide*
	    (show-command-bar 'thread-bar)))
      (start))))

(defun toggle ()
  (interactive)
  (if (eq *pframe-name*
	  (ed::pseudo-frame-name ed::*current-pseudo-frame*))
      (hide)
    (restore)))

(defun open-browser (url)
  (shell-execute url t))

(defun open-browser-index ()
  (interactive)
  (open-browser *2ch-url*))

(defun toggle-online ()
  (interactive)
  (message "2ch: ~:[off~;on~]line mode."
	   (setq *online* (not *online*)))
  (menu-mode-line-update))

(defun reverse-line ()
  (reverse-region (progn (goto-eol) (point))
		  (progn (goto-bol) (point))))

(defvar *2ch-mouse-left-press*  '((2ch-menu . menu-select)
				  (2ch-board . board-thread-select)
				  (2ch-tracking . tracking-select)
				  (2ch-search . search-select)
				  (2ch-thread . thread-jump)
				  (2ch-view . view-jump)
				  (2ch-grep . grep-jump)
				  (2ch-bookmark . bookmark-select)
				  (2ch-history . history-select)
				  (2ch-http . http-quit)))

(defun 2ch-mouse-left-press ()
  (interactive)
  (let ((owindow (selected-window))
	func)
    (set-window *last-mouse-window*)
    (continue-pre-selection)
    (if (setq func (cdr (assoc buffer-mode *2ch-mouse-left-press*)))
      (progn
	(goto-last-mouse-point)
	(when (or *2ch-mouse-single-click*
		  (> *last-mouse-click-count* 1))
	  (funcall func))
	t)
      (progn
	(set-window owindow)
	(mouse-left-press)))))

(defvar *version-aa* "
 ƒ©Qƒ©@@^PPPP
i@EÍEjƒ@~A
i@@@@j@_QQQQQ
b b@| @
iQ_jQj ")

(defun version-aa ()
  (format nil *version-aa* *version-name*))

(defun version ()
  (interactive)
  (message-box (version-aa)
	       "2ch-mode"
	       '(:information)))

(defun read-number (&optional prompt default)
  (let (str)
    (setq str (string-trim " " (read-string (or prompt "Number: ")
					    :default (or default ""))))
    (unless (string-match "^[0-9]+$" str)
      (error "Not number: ~S" str))
    (parse-integer str)))

(defun file-backup (file)
  (when (file-exist-p file)
    (copy-file file
	       (concat file ".bak")
	       :if-exists :overwrite)))

(add-hook 'ed::*kill-xyzzy-hook* 'exit)
