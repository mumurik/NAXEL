; $Id: makefile.l 441 2005-11-25 11:44:49Z torihat $

(provide "2ch/makefile")

(defvar *2ch-file-list* '("main.l"
			  "menu.l"
			  "board.l"
			  "http.l"
			  "form.l"
			  "thread.l"
			  "tracking.l"
			  "search.l"
			  "popup.l"
			  "view.l"
			  "grep.l"
			  "bookmark.l"
			  "history.l"
			  "macro.l"
			 ))

(defvar *2ch-root-directory*
  (merge-pathnames "site-lisp/2ch" (si:system-root)))

(defvar *2ch-buffer-make* "2ch: MAKE")

(defun 2ch-make ()
  (interactive)
  (let ((files *2ch-file-list*)
	(path *2ch-root-directory*))
    (dolist (f files)
      (let ((file (merge-pathnames f path))
	    (filec))
	(setq filec (concat file "c"))
	(if (file-newer-than-file-p file filec)
	    (byte-compile-file file)
	  (message "skipping file: ~A" file))))))

(defun 2ch-make-tags-file ()
  (interactive)
  (let ((path *2ch-root-directory*))
    (set-default-directory path)
    (make-tags-file path)))

(defun 2ch-make-all ()
  (interactive)
  (2ch-make)
  (2ch-make-tags-file))

(defun 2ch-make-clean ()
  (interactive)
  (let ((path *2ch-root-directory*))
    (set-default-directory path)
    (dolist (f (directory path))
      (when (or (string-match "~$" f)
		(string-match "\.lc" f)
		(string-matchp "xtags" f))
	(delete-file f)
	(message "File deleted: ~A" f)))))
