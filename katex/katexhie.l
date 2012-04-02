;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX hierarchy browser.
;;; katexhie.l, v 1.66.1.2
;;; fixed by Maeda Manabu
;;; Last fixed  "Sat May 05 2001 12:53:55 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX hierarchy browser.
;;; yatexhie.el
;;; (c ) 1995 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Thu Sep 17 21:46:29 1998 on firestorm
;;; $Old-Id: yatexhie.el,v 1.66 1998/10/26 12:05:53 yuuji Rel $

(provide "katexhie")

(in-package "elisp")

;; ----- Customizable variables -----
(defvar KaTeX-hierarchy-ignore-heading-regexp
  "\\$[A-Z][a-z]+: .* \\$\\|-\\*- .* -\\*-"
  "*Regexp of lines to ignore as files' headline.")

;; ----- General variables -----
(defvar KaTeX-default-TeX-extensions "\\.\\(tex\\|sty\\)")
(defvar KaTeX-hierarchy-current-main nil)
(defvar KaTeX-hierarchy-buffer-message
  (concat
   "n)ext p)rev N)extsame P)revsame u)p K)illbuf RET)select"
   (if (and KaTeX-emacs-19 window-system) " Mouse2)select" "")
   " ?)help"))
(defvar KaTeX-hierarchy-saved-wc nil "Saved window configuration.")

;; ----- Functions for parsing hierarchy -----

(defun KaTeX-all-included-files (&optional file)
  "Return all included files from FILE as a list.
If FILE is nil, use current buffer."
  (save-excursion
    (let ((include-regex (concat KaTeX-ec-regexp
								 "\\(\\(input\\)\\|"		;match#2
								 "\\(include\\)\\)\\b"))	;match#3
		  list file (cb (current-buffer)))
      (if file (set-buffer (KaTeX-switch-to-buffer file t)))
      (goto-char (point-min))
      (while (KaTeX-re-search-active-forward
	      include-regex KaTeX-comment-prefix nil t)
	(cond
	 ((match-beginning 2)		;\input, {} is optional, 1 argument
	  (skip-chars-forward " {")
	  (setq file (buffer-substring
		      (point)
		      (progn
			(skip-chars-forward
			 (concat "^ \t\n\r" KaTeX-ec-regexp "{}"))
			(point)))))
	 ((and (match-beginning 3) (looking-at "{"))
	  (skip-chars-forward "{")
	  (setq file (buffer-substring
		      (point)
		      (progn
			(forward-char -1) (forward-list 1) (1- (point)))))))
	(or (string-match KaTeX-default-TeX-extensions file)
	    (setq file (concat file ".tex")))
	(setq list (cons file list)))
      (set-buffer cb)
      (nreverse list))))

(defun KaTeX-document-hierarchy (&optional file)
  "Return the document hierarchy beginning from FILE as a list.
If FILE is nil, beginning with current buffer's file."
  (setq file (or file (buffer-file-name)))
  (message "Parsing [~A]..." (file-name-nondirectory file))
  (prog1
      (save-excursion
	(if (or (file-exists-p file) (null file))
	    (progn
	      (if file
		  (let ((parent file))
		    (KaTeX-switch-to-buffer file t)	;set buffer to file
		    (or KaTeX-parent-file
			(KaTeX-get-builtin "!")
			(setq KaTeX-parent-file parent))))
	      (cons (buffer-file-name (current-buffer))  ;m.m
		    (mapcar 'KaTeX-document-hierarchy	;return value
			    (KaTeX-all-included-files))))))
    (message "Parsing [~A]...done" (file-name-nondirectory file))))

;; ----- Functions for displaying hierarchy -----

(defun KaTeX-hierarchy-get-file-heading (file)
  "Get a FILE's heading."
  (save-excursion
    (set-buffer (find-file-noselect file))
    (save-excursion
      (let (p)
	(goto-char (point-min))
	(cond
	 ((re-search-forward
	   (concat KaTeX-ec-regexp KaTeX-sectioning-regexp) nil t)
	  (search-forward "{")
	  (forward-char -1)
	  (setq p (handler-case
		      (progn (forward-list 1) (1- (point)))
		    (error (point-end-of-line))))
	  (goto-char (1+ (match-beginning 0)))
	  (skip-chars-forward " \t\n")
	  (buffer-substring (point) (min (point-end-of-line) p)))
	 ((catch 'found
	    (while (re-search-forward "^ *%\\([^#]\\)" nil t)
	      (or (re-search-forward
		   KaTeX-hierarchy-ignore-heading-regexp
		   (point-end-of-line) t)
		  (throw 'found t))))
	  (beginning-of-line)
	  (search-forward "%")
	  (skip-chars-forward "% \t")
	  (buffer-substring (point) (point-end-of-line)))
	 (t ""))))))

(defun KaTeX-display-a-hierachy (hier level)
  "Put a HIER of document hierarchy.
LEVEL is including depth."
  (message "Formatting hierarchy buffer...")
  (let ((lastatomcol 0) list i p)
    (cond
     ((listp hier)
      (setq  list hier)
      (while list
	(KaTeX-display-a-hierachy (car list) (1+ level))
	(setq list (cdr list))))
     ((stringp hier)			;is an atom
      (insert "  ")
      (setq i level)
      (while (> i 2)
	(insert "|   ")
	(setq i (1- i)))
      (if (> level 1) (insert "+---"))
      (setq p (point))
      (insert (or (buffer-name (get-file-buffer hier))
		  (file-name-nondirectory hier)))
;      (if (and window-system KaTeX-emacs-19)                   ;m.m
;	  (put-text-property p (point) 'mouse-face 'underline)) ;m.m
      (insert " ")
      (indent-to-column (1- (truncate (window-width) 2)))
      (insert "% " (KaTeX-hierarchy-get-file-heading hier))
      (insert "\n"))))
  (message "Formatting hierarchy buffer..."))

(defun KaTeX-display-hierarchy (file &optional use-default)
  "Display document hierarchy that is beginning from FILE."
  (interactive "P")
  (setq KaTeX-hierarchy-saved-wc
		(list (current-window-configuration)
			  nil))
  (let*((b-in (KaTeX-get-builtin "!"))
		(default (or KaTeX-parent-file
					 (and b-in (KaTeX-guess-parent b-in))
					 (buffer-file-name))))
	;;むーん↓このへんの仕様どうしたらいいか良く分からん...
	(if default (setq default (expand-file-name default)))
	(KaTeX-visit-main t)		;move to parent file
	(setq file
		  (or (if use-default default file)
			  (read-file-name
			   (format nil
					   "Main .tex file~A: "
					   (if default
						   (format nil "(default ~A)"(file-name-nondirectory default))
						 ""))
			   "" default 1))))
  (setq file (expand-file-name file))
  (setq KaTeX-hierarchy-current-main file)
  (let ((dbuf "*document hierarchy*"))
	(KaTeX-showup-buffer dbuf nil t)
	(set-buffer (get-buffer dbuf))
	(setq truncate-lines t)
	(let ((buffer-read-only nil))
	  (erase-buffer)
	  (KaTeX-display-a-hierachy (KaTeX-document-hierarchy file) 0))
	(goto-char (point-min))
	(KaTeX-hierarchy-next 0)
	(set-buffer-modified-p nil)
	(KaTeX-hierarchy-mode)
  ))

(defun KaTeX-display-hierarchy-directly ()
  "Same as KaTeX-display-hierarchy.  Call from mouse."
  (interactive)
  (KaTeX-display-hierarchy nil t))

(defun KaTeX-hierarchy-mode ()
  "Major mode to browse and select document hierarchy.

\\[KaTeX-hierarchy-next]	next line
\\[KaTeX-hierarchy-prev]	previous line
\\[KaTeX-hierarchy-forward]	move forward in the same level
\\[KaTeX-hierarchy-backward]	move backward in the same level
\\[KaTeX-hierarchy-up-document]	move to parent file
\\[delete-other-windows]	delete other windows
\\[other-window]	other window
\\[shrink-window]	shrink window
\\[enlarge-window]	enlarge window
\\[KaTeX-hierarchy-show]	show file contents in the next window
\\[KaTeX-hierarchy-scroll-up]	scroll up file contents buffer
\\[KaTeX-hierarchy-scroll-down]	scroll down file contents buffer
\\[KaTeX-hierarchy-top]	show the top of file contents
\\[KaTeX-hierarchy-bottom]	show the bottom of file contents
\\[KaTeX-hierarchy-lastpos]	return to the previous position
\\[KaTeX-hierarchy-select]	select file
\\[KaTeX-hierarchy-mouse-select]	select
"
  (setq buffer-mode 'KaTeX-hierarchy-mode
	mode-name "KaTeX hier")
  (use-local-map KaTeX-hierarchy-mode-map)
  (setq buffer-read-only t)
  (message KaTeX-hierarchy-buffer-message))

;; ----- Subfunctions for interactive functions -----
(defun KaTeX-hierarchy-get-current-file-buffer ()
  "Return the buffer associated with current line's file."
  (let ((file (buffer-substring
			   (point)
			   (save-excursion
				 (skip-chars-forward "^ \t" (point-end-of-line)) (point))))
		(hilit-auto-highlight) buffer)
;    (set-buffer (find-file-noselect KaTeX-hierarchy-current-main)) ;m.m
    (if (get-buffer file)		;buffer is active
	(setq buffer (get-buffer file)) ;may contain `<2>'
      (progn
	(if (string-match "<[2-9]>$" file)
	    (setq file (substring file 0 -3)))
        (save-excursion
	  (setq buffer (KaTeX-switch-to-buffer file t))))))) ; open it!

;; ----- Interactive functions -----
(defun KaTeX-hierarchy-next (arg &optional quiet)
  "Move to next line's file in KaTeX document hierarchy buffer."
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (forward-line arg)
  (skip-chars-forward "- +\\|")
  (if (and (/= arg 0) (not quiet))
      (KaTeX-hierarchy-select t))
  (message KaTeX-hierarchy-buffer-message))

(defun KaTeX-hierarchy-prev (arg)
  "Move to previous line's file in KaTeX document hierarchy buffer."
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (KaTeX-hierarchy-next (- arg)))

(defun KaTeX-hierarchy-next-line (arg)
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (KaTeX-hierarchy-next arg t))

(defun KaTeX-hierarchy-prev-line (arg)
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (KaTeX-hierarchy-next (- arg) t))

(defun KaTeX-hierarchy-forward (arg)
  "Move to forward file in same hierarchy level."
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (KaTeX-hierarchy-next 0)
  (let ((p (point))(column (current-column)) (i (if (> arg 0) arg (- arg))))
    (if (= column 0) (error "Not on file line."))
    (while (> i 0)
      (if (catch 'found
	    (while (and (not (eobp)) (not (bobp)))
	      (forward-line (if (> arg 0) 1 -1))
	      (move-to-column column)
	      (unless (looking-at "[- +\\|]")
		(KaTeX-hierarchy-next 0)
		(if (= (current-column) column) (throw 'found t)))
	      (beginning-of-line)))
	  nil
	(progn
	  (goto-char p)
	  (error "No same level file.")))
      (setq i (1- i)))))

(defun KaTeX-hierarchy-backward (arg)
  "Move to backward file in same hierarchy level."
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (KaTeX-hierarchy-forward (- arg)))

(defun KaTeX-hierarchy-up-document ()
  "Up level, that is, move to parent file position."
  (interactive)
  (KaTeX-hierarchy-next 0)		;adjust column
  (let ((p (point)) (line (count-lines (point-min) (point))) column)
    (if (or (<= line 1) (< (current-column) 6))
	(message "No more parent")
      (progn
	(backward-char 1)
        (or (= (char-after (point)) #\-) (error "Unexpected hierarchy buffer"))
;        (or (char= (char-after (point)) #\-) (error "Unexpected hierarchy buffer"))
        (setq column (current-column))
        (while (and (> line 1) (looking-at "[- +\\|]"))
	  (forward-line -1)
	  (move-to-column column))
        (KaTeX-hierarchy-next 0)
        (push-mark p t)
	(message "Mark set to last position")))))

(defun KaTeX-hierarchy-kill-buffer (arg)
  "Kill buffer associated with current line's file."
  (interactive "P") ;m.m ->
  (or arg
      (setq arg 1))  ;<- m.m
  (KaTeX-hierarchy-next 0)		;move to file name column
  (if (bolp) (error "Not on file name line"))
  (let ((file (buffer-substring
	       (point)
	       (progn (skip-chars-forward "^ \t") (point)))))
    (KaTeX-hierarchy-next arg)
    (cond
     ((get-buffer file)
      (kill-buffer (get-buffer file))
      (message "Buffer [~A] was killed" file))
     (t (message "Buffer [~A] is not active." file)))))

(defun KaTeX-hierarchy-select (arg)
  "Select current line's file in KaTeX document hierarchy buffer.
If ARG is non-nil, show the buffer in the next window."
  (interactive "P")
  (beginning-of-line)
  (skip-chars-forward "- +\\|")
  (or (eolp)
      (let ((buffer (KaTeX-hierarchy-get-current-file-buffer)))
	(if buffer			;if file was found
	    (if arg
		(KaTeX-showup-buffer buffer nil)
	      (if (and KaTeX-emacs-19 window-system
		       (get-buffer-window buffer t))
		  (goto-buffer-window buffer) ;select currently displaying
		(KaTeX-switch-to-buffer-other-window buffer)))))))

(defun KaTeX-hierarchy-show ()
  "Show current line's file in the next window."
  (interactive)
  (KaTeX-hierarchy-select t))

(defun KaTeX-hierarchy-mouse-select (event)
  (interactive "e")
  (mouse-set-point event)
  (KaTeX-hierarchy-select nil))

(defun KaTeX-hierarchy-quit ()
  "Quit from KaTeX-hierarchy buffer and restore window configuration."
  (interactive)
  (if (or (not (featurep 'windows))
	  (car KaTeX-hierarchy-saved-wc)
	  nil)
;m.m	  (and (= (car (cdr KaTeX-hierarchy-saved-wc)) win:current-config))
      (set-window-configuration (car KaTeX-hierarchy-saved-wc))
    (bury-buffer nil)))

(defun KaTeX-hierarchy-scroll-up (arg &optional action)
  "Scroll up file contents of KaTeX-hierarchy."
  (interactive "P")
  (KaTeX-hierarchy-next 0 t)
  (let*((bufname (buffer-substring
		  (point)
		  (save-excursion (skip-chars-forward "^ \t") (point))))
	(buf (get-buffer bufname))
	(cw (selected-window)))
    (cond
     ((and buf (get-buffer-window buf))
      (select-window (get-buffer-window buf)))
     ((and buf (KaTeX-showup-buffer buf nil t)) t)
     (t (KaTeX-hierarchy-select nil)))
    (unwind-protect
	(cond
	 ((eq action 'down)	(scroll-down arg))
	 ((eq action 'top)	(beginning-of-buffer))
	 ((eq action 'bottom)	(end-of-buffer))
	 ((eq action 'last)	(exchange-point-and-mark))
	 (t (scroll-up arg)))
      (select-window cw))))

(defun KaTeX-hierarchy-scroll-down (arg)
  "Scroll down file contents of KaTeX-hierarchy."
  (interactive "P")
  (KaTeX-hierarchy-scroll-up arg 'down))

(defun KaTeX-hierarchy-top ()
  "Show the top of KaTeX-hierarchy inspection buffer's."
  (interactive)
  (KaTeX-hierarchy-scroll-up nil 'top)
)

(defun KaTeX-hierarchy-bottom ()
  "Show the top of KaTeX-hierarchy inspection buffer's."
  (interactive)
  (KaTeX-hierarchy-scroll-up nil 'bottom)
)

(defun KaTeX-hierarchy-lastpos ()
  "Go to last position in KaTeX-hierarchy buffer."
  (interactive)
  (KaTeX-hierarchy-scroll-up nil 'last)
)

;; ----- Setting up keymap -----
(defvar KaTeX-hierarchy-mode-map nil "Keymap used in KaTeX-hierarchy-mode.")
(if KaTeX-hierarchy-mode-map nil
  (progn
    (setq KaTeX-hierarchy-mode-map (make-sparse-keymap))
    (define-key KaTeX-hierarchy-mode-map #\n	'KaTeX-hierarchy-next)
    (define-key KaTeX-hierarchy-mode-map #\p	'KaTeX-hierarchy-prev)
    (define-key KaTeX-hierarchy-mode-map #\j	'KaTeX-hierarchy-next-line)
    (define-key KaTeX-hierarchy-mode-map #\k	'KaTeX-hierarchy-prev-line)
    (substitute-all-key-definition
     'next-line 'KaTeX-hierarchy-next-line KaTeX-hierarchy-mode-map)
    (substitute-all-key-definition
     'previous-line 'KaTeX-hierarchy-prev-line KaTeX-hierarchy-mode-map)
    (define-key KaTeX-hierarchy-mode-map #\N	'KaTeX-hierarchy-forward)
    (define-key KaTeX-hierarchy-mode-map #\P	'KaTeX-hierarchy-backward)
    (define-key KaTeX-hierarchy-mode-map #\u	'KaTeX-hierarchy-up-document)
    (define-key KaTeX-hierarchy-mode-map #\K	'KaTeX-hierarchy-kill-buffer)
    (define-key KaTeX-hierarchy-mode-map #\1	'delete-other-windows)
    (define-key KaTeX-hierarchy-mode-map #\o	'other-window)
    (define-key KaTeX-hierarchy-mode-map #\-	'shrink-window)
    (define-key KaTeX-hierarchy-mode-map #\+	'enlarge-window)
    (define-key KaTeX-hierarchy-mode-map #\.	'KaTeX-hierarchy-show)
    (define-key KaTeX-hierarchy-mode-map #\SPC	'KaTeX-hierarchy-scroll-up)
    (define-key KaTeX-hierarchy-mode-map #\b	'KaTeX-hierarchy-scroll-down)
    (define-key KaTeX-hierarchy-mode-map #\C-?	'KaTeX-hierarchy-scroll-down)
    (define-key KaTeX-hierarchy-mode-map #\C-m	'KaTeX-hierarchy-select)
    (define-key KaTeX-hierarchy-mode-map #\<	'KaTeX-hierarchy-top)
    (define-key KaTeX-hierarchy-mode-map #\>	'KaTeX-hierarchy-bottom)
    (define-key KaTeX-hierarchy-mode-map #\'	'KaTeX-hierarchy-lastpos)
    (define-key KaTeX-hierarchy-mode-map #\g	'KaTeX-hierarchy-select)
    (define-key KaTeX-hierarchy-mode-map #\q	'KaTeX-hierarchy-quit)
    (define-key KaTeX-hierarchy-mode-map #\?	'describe-mode)
;    (if (and KaTeX-emacs-19 window-system)
;        (define-key KaTeX-hierarchy-mode-map
;	  [mouse-2] 'KaTeX-hierarchy-mouse-select))
  ))

;;end of katexhie.el
