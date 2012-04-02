;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX sectioning browser.
;;; katexsec.l, v 1.66.1.2
;;; fixed by Maeda Manabu
;;; Last fixed  "Sat May 05 2001 13:05:28 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX sectioning browser.
;;; yatexsec.el
;;; (c ) 1994,1998 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Wed Sep 30 20:09:35 1998 on firestorm
;;; $Old-Id: yatexsec.el,v 1.66 1998/10/26 12:05:53 yuuji Rel $

(provide "katexsec")

(in-package "elisp")

(defvar KaTeX-sectioning-level
  '(("part" . 0)
    ("chapter" . 1)
    ("section" . 2)
    ("subsection" . 3)
    ("subsubsection" . 4)
    ("paragraph" . 5)
    ("subparagraph" . 6))
  "*Alist of LaTeX's sectioning command and its level.
This value must be written in numerically ascending order and consecutive.
Needn't define the level of `*' commands such as `section*'.")

(defvar KaTeX-sectioning-max-level
  (cdr (nth (1- (length KaTeX-sectioning-level)) KaTeX-sectioning-level))
  "*The heighest(numerically) level of sectioning command.
This must be the heighest number in KaTeX-sectioning-level.")

(defun KaTeX-sectioning-map-hide (map)
  (let ((ch #\0))
    (while (<= ch #\9)
      (define-key map ch 'KaTeX-sectioning-hide) ;m.m (char-to-string ch)
      (setq ch (1+ ch))))
)

(defvar KaTeX-sectioning-minibuffer-map nil
  "Key map used in minibuffer for sectioning.")
(if KaTeX-sectioning-minibuffer-map nil
  (progn
    (setq KaTeX-sectioning-minibuffer-map
	  (copy-keymap minibuffer-local-completion-map))
    (define-key KaTeX-sectioning-minibuffer-map #\C-p
      'KaTeX-sectioning-up)
    (define-key KaTeX-sectioning-minibuffer-map #\C-e
      'KaTeX-sectioning-up)
    (define-key KaTeX-sectioning-minibuffer-map #\C-i
      'KaTeX-minibuffer-complete)
    (define-key KaTeX-sectioning-minibuffer-map #\SPC
      'KaTeX-minibuffer-complete)
    (define-key KaTeX-sectioning-minibuffer-map #\C-n
      'KaTeX-sectioning-down)
    (define-key KaTeX-sectioning-minibuffer-map #\C-x
      'KaTeX-sectioning-down)
    (define-key KaTeX-sectioning-minibuffer-map #\C-v
      'KaTeX-sectioning-scroll-up)
    (define-key KaTeX-sectioning-minibuffer-map #\C-c
      'KaTeX-sectioning-scroll-up)
    (define-key KaTeX-sectioning-minibuffer-map #\M-v
      'KaTeX-sectioning-scroll-down)
    (define-key KaTeX-sectioning-minibuffer-map #\C-r
      'KaTeX-sectioning-scroll-down)
    (define-key KaTeX-sectioning-minibuffer-map #\C-w
      '(lambda () (interactive) (KaTeX-sectioning-scroll-down 1)))
    (define-key KaTeX-sectioning-minibuffer-map #\C-z
      '(lambda () (interactive) (KaTeX-sectioning-scroll-up 1)))
    (define-key KaTeX-sectioning-minibuffer-map #\C-l
      'KaTeX-sectioning-recenter)
    (define-key KaTeX-sectioning-minibuffer-map #\?
      'KaTeX-sectioning-help)
    (KaTeX-sectioning-map-hide KaTeX-sectioning-minibuffer-map)
  ))

(defvar KaTeX-sectioning-buffer-map nil
  "Key map used in KaTeX-sectioning-buffer.")
(if KaTeX-sectioning-buffer-map nil
  (progn
    (setq KaTeX-sectioning-buffer-map (make-sparse-keymap))
    (define-key KaTeX-sectioning-buffer-map #\SPC	'KaTeX-sectioning-buffer-jump)
    (define-key KaTeX-sectioning-buffer-map #\.	'KaTeX-sectioning-buffer-show)
    ;(define-key KaTeX-sectioning-buffer-map '(*KaTeX-prefix* #\C-c) ;m.m
				;'KaTeX-sectioning-buffer-jump)
    (define-key KaTeX-sectioning-buffer-map #\u	'KaTeX-shift-section-up)
    (define-key KaTeX-sectioning-buffer-map #\d	'KaTeX-shift-section-down)
    (define-key KaTeX-sectioning-buffer-map #\U   'KaTeX-shift-section-up-region)
    (define-key KaTeX-sectioning-buffer-map #\D 'KaTeX-shift-section-down-region)
    (define-key KaTeX-sectioning-buffer-map #\s	'KaTeX-sync-section-buffer)
    (define-key KaTeX-sectioning-buffer-map #\n
      'KaTeX-sectioning-buffer-next-line)
    (define-key KaTeX-sectioning-buffer-map #\p
      'KaTeX-sectioning-buffer-prev-line)
    ;(define-key KaTeX-sectioning-buffer-map #\h  'describe-mode) ;m.m
    (define-key KaTeX-sectioning-buffer-map #\o  'other-window)
    (define-key KaTeX-sectioning-buffer-map #\-  'shrink-window)
    (define-key KaTeX-sectioning-buffer-map #\+  'enlarge-window)
    (define-key KaTeX-sectioning-buffer-map #\q  'delete-window)
    (define-key KaTeX-sectioning-buffer-map #\C-_ 'KaTeX-shift-section-undo)
    (define-key KaTeX-sectioning-buffer-map #\C-/ 'KaTeX-shift-section-undo)
    ;(KaTeX-sectioning-map-hide KaTeX-sectioning-buffer-map) ;m.m
  ))

(defun KaTeX-sectioning-mode ()
  "Mode for browsing document's sectioning structure.
\\[KaTeX-shift-section-up]	Shift up a sectioning command
\\[KaTeX-shift-section-down]	Shift down a sectioning command
\\[KaTeX-shift-section-up-region]	Shift up sectioning commands in region
\\[KaTeX-shift-section-down-region]	Shift down sectioning commands in region
\\[KaTeX-shift-section-undo]	Undo changes of shifting
\\[KaTeX-sync-section-buffer]	Synchronize sectioning buffer with source
\\[KaTeX-sectioning-buffer-next-line]	Next line
\\[KaTeX-sectioning-buffer-prev-line]	Previous line
\\[KaTeX-sectioning-buffer-jump]	Previous line
\\[KaTeX-sectioning-buffer-show]	Show curresponding source line
"
  (interactive)
  (setq buffer-mode 'KaTeX-sectioning-mode
	mode-name "sectioning")
  (use-local-map KaTeX-sectioning-buffer-map)
)

(defvar KaTeX-sectioning-buffer-parent nil)
(defun KaTeX-sectioning-buffer-jump-internal (&optional keep)
  (let (ptn (p (point)))		;save-excursion is NG because
    (beginning-of-line)		;this function should switch buffer
    (if (re-search-forward KaTeX-sectioning-regexp)
	(progn (setq ptn (buffer-substring
					  (1- (match-beginning 0))
					  (progn (skip-chars-forward "^}") (1+ (point)))))
	  (goto-char p)
	  (KaTeX-showup-buffer KaTeX-sectioning-buffer-parent nil t)
	  (goto-char (point-max))
	  (search-backward ptn)
	  (if keep (goto-buffer-window KaTeX-sectioning-buffer))
	  (current-buffer))
      nil))
)
(defun KaTeX-sectioning-buffer-jump (&optional keep)
  "Goto corresponding sectioning unit with current line in the next window.
If optional argument KEEP is non-nil, only shows the line."
  (interactive)
  (if (and KaTeX-sectioning-buffer-parent
		   (get-buffer KaTeX-sectioning-buffer-parent))
	  (KaTeX-sectioning-buffer-jump-internal keep)
	(message "No line number expression."))
)

(defun KaTeX-sectioning-buffer-show ()
  "Show corresponding sectioning unit with current line."
  (interactive)
  (KaTeX-sectioning-buffer-jump-internal t)
)

(defun KaTeX-sectioning-hide-under (n)
  "Hide sectioning commands under level N."
  (let ((cw (selected-window)))
	(KaTeX-showup-buffer KaTeX-sectioning-buffer nil t)
	(if (>= n KaTeX-sectioning-max-level)
		(progn
		  ;(set-selective-display nil)
		  (message "Show all."))
	  (progn
		;(set-selective-display (1+ n))
		(if (rassq n KaTeX-sectioning-level)
			(message "Hide lower than ~A" (car (rassq n KaTeX-sectioning-level)))
		  (message ""))))
	;(if (numberp selective-display)        ;m.m ->
		;(setq mode-name (format nil "level ~D" (1- selective-display)))
	  ;(setq mode-name (format nil "all"))) ;m.m <-
	(select-window cw))
)
(defun KaTeX-sectioning-hide ()
  "Call KaTeX-sectioning-hide-under with argument according to pressed key."
  (interactive)
  (KaTeX-sectioning-hide-under (- *last-command-char* #\0)))
;  (KaTeX-sectioning-hide-under (char- *last-command-char* #\0)))

(defun KaTeX-sectioning-help ()
  "Show help of sectioning."
  (interactive)
  (let ((cw (selected-window)) sb (hb (get-buffer-create "*Help*")))
    (unwind-protect
	(progn
	  (other-window 1)
	  (setq sb (current-buffer))
	  (switch-to-buffer hb)
	  (erase-buffer)
	  (insert "===== View sectioning =====
C-p	Up sectioning level.			0	Show only \\part, 
C-n	Down sectioning level.			1	 and \\chapter,
C-v	Scroll up *Sectioning line* buffer.	2	 and \\section,
M-v	Scroll down *Sectioning line* buffer.	3	 and \\subsection,
C-z	Scroll up by 1 line.			4	 and \\subsubsection,
C-w	Scroll down by 1 line.			5	 and \\paragraph.
SPC	Complete word.				6	Show all.
TAB	Complete word.
C-l	Recenter recent line.
RET	Select.
==== End of HELP =====
")
	  (set-buffer-modified-p nil)
	  (goto-char (point-min))
	  (momentary-string-display "" (point-min)))
      (bury-buffer hb)
      (switch-to-buffer sb)
      (select-window cw)))
)

(defun KaTeX-sectioning-up (n)
  "Up section level.
Refers the KaTeX-read-section-in-minibuffer's local variable minibuffer-start."
  (interactive "p")
  (if (eq (selected-window) (minibuffer-window))
	  (let*((command (buffer-string))
			(aster (and (string< "" command)
						(equal (substring command -1) "*")))
			(command (if aster (substring command 0 -1) command))
			(alist KaTeX-sectioning-level)
			(level 0))
		(or (assoc command alist) (error "No such sectioning command."))
		(while (not (string= (car (nth level alist)) command))
		  (setq level (1+ level)))	;I want to use `member'....
		(setq level (- level n))
		(if (or (< level 0) (>= level (length alist)))
			(ding)
		  (progn
			(erase-buffer)
			(insert (concat (car (nth level alist)) (if aster "*" "")))))))
)

(defun KaTeX-sectioning-down (n)
  "Down section level."
  (interactive "p")
  (KaTeX-sectioning-up (- n))
)

(defun KaTeX-sectioning-scroll-up (n)
  (interactive "P")
  (let ((section-buffer KaTeX-sectioning-buffer)
	(cw (selected-window)))
    (KaTeX-showup-buffer section-buffer nil t)
    (unwind-protect
	(scroll-up (or n (- (window-height) 2)))
      (select-window cw)))
)

(defun KaTeX-sectioning-scroll-down (n)
  (interactive "P")
  (let ((section-buffer KaTeX-sectioning-buffer)
	(cw (selected-window)))
    (KaTeX-showup-buffer section-buffer nil t)
    (unwind-protect
	(scroll-down (or n (- (window-height) 2)))
      (select-window cw)))
)

(defun KaTeX-sectioning-recenter (arg)
  "Recenter `<<--' line"
  (interactive "P")
  (let ((cw (selected-window)))
    (unwind-protect
	(progn
	  (KaTeX-showup-buffer KaTeX-sectioning-buffer nil t)
	  (or (search-forward "<<--" nil t)
	      (search-backward "<<--" nil))
	  (recenter (or arg (/ (window-height) 2))))
      (select-window cw)))
)

(defvar KaTeX-sectioning-minibuffer " *sectioning*"
  "Miniuffer used for sectioning")
;;;###autoload
(defun KaTeX-read-section-in-minibuffer (prompt table &optional default delim)
  (interactive)
  (setq minibuffer-completion-table table)
    (read-from-minibuffer
     prompt default KaTeX-sectioning-minibuffer-map))

(defun KaTeX-get-sectioning-level ()
  "Get section-level on the cursor."
   (cdr-safe (assoc (buffer-substring
		     (point)
		     (progn (skip-chars-forward "a-z") (point)))
		     KaTeX-sectioning-level))
)

(defvar KaTeX-sectioning-buffer "*Sectioning lines*")
(defvar KaTeX-sectioning-indent 1)
(defun KaTeX-colloect-sections ()
  "Collect all the lines which contains sectioning command."
  (let ((cw (selected-window)) level indent begp (prevp 1) (prevl 1)
		(pattern (concat KaTeX-ec-regexp
						 "\\(" KaTeX-sectioning-regexp "\\)\\*?{"))
		(cb (current-buffer)))
	(save-excursion
	  (set-buffer (get-buffer-create KaTeX-sectioning-buffer))
	  (setq buffer-read-only nil)
	  (KaTeX-showup-buffer KaTeX-sectioning-buffer) ;show buffer
	  (set-buffer cb)
	  (goto-char (point-min))
	  (let* ((secstream (make-buffer-stream (get-buffer KaTeX-sectioning-buffer)))
			 (*standard-output* secstream))
		(while (re-search-forward pattern nil t)
		  (goto-char (1+ (match-beginning 0)))
		  (setq level (KaTeX-get-sectioning-level)
				begp (match-beginning 0))
		  ;;(beginning-of-line)
		  ;;(skip-chars-forward " \t")
		  (setq indent (format nil "~~~DA" (* level KaTeX-sectioning-indent)))
		  (princ (format nil indent ""))
		  (if (KaTeX-on-comment-p) (princ "%"))
		  (princ (buffer-substring begp (progn (forward-list 1) (point))))
		  (setq prevl (+ prevl (count-lines prevp (point)) -1)
				prevp (point))
		  (princ (format nil " (line:~D)" prevl))
		  (princ "\n")))
	  (set-buffer KaTeX-sectioning-buffer)
	  (make-local-variable 'KaTeX-sectioning-buffer-parent)
	  (KaTeX-sectioning-mode)
	  (use-local-map KaTeX-sectioning-buffer-map)
	  (setq KaTeX-sectioning-buffer-parent cb)
	  ;(if (numberp selective-display) ;m.m
		 ;(setq mode-name (format nil "level ~D" (1- selective-display))))
	  KaTeX-sectioning-buffer))
)

(defvar KaTeX-pending-undo nil)
(defun KaTeX-section-overview ()
  "Show section overview.  Return the nearest sectioning command."
  (interactive)
  (let ((cw (selected-window)) (ln (count-lines (point-min) (point)))
		(pattern "(line:\\([0-9]+\\))")
		secbuf (command ""))
    (save-excursion
      (setq secbuf (KaTeX-colloect-sections))
      (KaTeX-showup-buffer secbuf nil t)
      (set-buffer secbuf)
      (goto-char (point-max))
      (while (re-search-backward pattern nil t)
	(if (< ln (string-to-int (KaTeX-match-string 1))) nil
	  (progn
	    (beginning-of-line)
	    (search-forward KaTeX-ec)
	    (looking-at KaTeX-TeX-token-regexp)
	    (setq command (KaTeX-match-string 0))
	    (end-of-line)
	    (insert "  <<--")
	    (setq pattern (concat "HackyRegexp" "ForFailure")))))
      (set-buffer-modified-p nil)
      (setq buffer-read-only t buffer-undo-list nil)
      (make-local-variable 'KaTeX-pending-undo)
      (forward-line 1)
      (if (eobp) (recenter -1) (recenter -3))
      (select-window cw)
      command))
)

;;;###autoload
(defun KaTeX-make-section-with-overview ()
  "Input sectining command with previous overview."
  (interactive)
  (insert
   KaTeX-ec
   (KaTeX-read-section-in-minibuffer
    "Sectioning(Up=C-p, Down=C-n, Help=?): "
    KaTeX-sectioning-level (KaTeX-section-overview))
   "{}")
  (forward-char -1)
)

(defun KaTeX-shifted-section (sc n)
  "Get SC's N-shifted sectioning command."
  (let (lv)
    (setq lv (- (cdr (assoc sc KaTeX-sectioning-level)) n)
	  lv (max (min KaTeX-sectioning-max-level lv) 0))
    (car (nth lv KaTeX-sectioning-level)))
)

(defun KaTeX-shift-section-up (n)
  "Shift sectioning command down by level N."
  (interactive "p")
  (let ((cb (current-buffer)) sc nsc lv)
	(if (and KaTeX-sectioning-buffer-parent
			 (get-buffer KaTeX-sectioning-buffer-parent)
			 (save-excursion
			   (beginning-of-line)
			   (skip-chars-forward "^\\\\" (point-end-of-line))
			   (KaTeX-on-section-command-p KaTeX-sectioning-regexp)))
		(save-excursion
		  (or (buffer-name (get-buffer KaTeX-sectioning-buffer-parent))
			  (error "This buffer is obsolete."))
		  (setq nsc (KaTeX-shifted-section (KaTeX-match-string 1) n))
		  (KaTeX-sectioning-buffer-jump-internal)
		  (undo-boundary)
		  (goto-char (match-beginning 0))
		  (skip-chars-forward "\\\\")
		  (delete-region
		   (point) (progn (skip-chars-forward "^*{") (point)))
		  (insert nsc)
		  (undo-boundary)
		  ;; Return to *Sectioning Lines* buffer
		  (select-window (get-buffer-window cb))
		  (beginning-of-line)
		  ;(let ;m.m
			  (setq buffer-read-only nil)
			(delete-region
			 (point) (progn (skip-chars-forward " \t") (point)))
			(indent-to-column (* (cdr (assoc nsc KaTeX-sectioning-level))
								 KaTeX-sectioning-indent))
			(skip-chars-forward "^\\\\")
			(delete-region
			 (1+ (point)) (progn (skip-chars-forward "^*{") (point)))
			(insert nsc)
			(undo-boundary)
		  ;) ;m.m
		  (set-buffer-modified-p nil)
		  ;(setq KaTeX-pending-undo pending-undo-list) ;m.m
		)))
)
(defun KaTeX-shift-section-down (n)
  "Shift sectioning command down by level N."
  (interactive "p")
  (KaTeX-shift-section-up (- n))
)
(defun KaTeX-shift-section-undo (arg)
  "Undo KaTeX-shift-section-up/down."
  (interactive "p")
  (and KaTeX-sectioning-buffer-parent
	   (get-buffer KaTeX-sectioning-buffer-parent)
	   (equal (current-buffer) (get-buffer KaTeX-sectioning-buffer))
	   (let ((cb (current-buffer))
			 (lc (if (eq *last-command* 'KaTeX-shift-section-undo) 'undo t)))
		 (let ((pending-undo-list KaTeX-pending-undo)
			   buffer-read-only (last-command lc))
		   ;(undo arg) ;m.m
		   (undo)
		   (setq KaTeX-pending-undo pending-undo-list))
		 (KaTeX-showup-buffer KaTeX-sectioning-buffer-parent)
		 (goto-buffer-window KaTeX-sectioning-buffer-parent)
		 (undo-boundary)
		 (let ((pending-undo-list
				(if (eq lc 'undo) KaTeX-pending-undo)))
		   (setq *last-command* lc)
		   ;(undo arg) ;m.m
		   (undo)
		   (setq KaTeX-pending-undo pending-undo-list))
		 (goto-buffer-window cb)
		 (setq this-command 'KaTeX-shift-section-undo)))
)
(defun KaTeX-sync-section-buffer ()
  "Synchronize *Sectioning Lines* buffer with parent buffer."
  (interactive)
  (if (and KaTeX-sectioning-buffer-parent
	   (get-buffer KaTeX-sectioning-buffer-parent))
      (let ((cb (current-buffer)) (p (point)))
	(set-buffer (get-buffer KaTeX-sectioning-buffer-parent))
	(KaTeX-section-overview)
	(switch-to-buffer cb)
	(goto-char p)))
)
(defun KaTeX-shift-section-up-region (beg end n)
  "Shift sectioning commands in region down by level N."
  (interactive "r\np")
  (or KaTeX-sectioning-buffer-parent
	  (get-buffer KaTeX-sectioning-buffer-parent)
	  (error "Can't find corresponding LaTeX buffer"))
  (save-excursion
	(goto-char beg)
	(let ((cb (current-buffer)) nsc from to repllist (e (make-marker)))
	  (set-marker e end)
	  (while (progn (skip-chars-forward "^\\\\") (< (point) e))
		(KaTeX-on-section-command-p KaTeX-sectioning-regexp)
		(setq from (KaTeX-match-string 0)
			  nsc (KaTeX-shifted-section (KaTeX-match-string 1) n))
		(goto-char (match-beginning 0))
		(let (buffer-read-only)
		  ;(delete-region (point) (progn (beginning-of-line) (point)))
		  (delete-region (progn (beginning-of-line) (point))
						 (progn (skip-chars-forward " \t") (point)))
		  (indent-to-column (cdr (assoc nsc KaTeX-sectioning-level)))
		  (delete-region
		   (progn (skip-chars-forward "%\\\\") (point))
		   (progn (skip-chars-forward "^*{") (point)))
		  (insert nsc))
		(KaTeX-on-section-command-p KaTeX-sectioning-regexp)
		(setq to (KaTeX-match-string 0)
			  repllist (cons (cons from to) repllist))
		(forward-line 1))
	  (KaTeX-showup-buffer KaTeX-sectioning-buffer-parent)
	  (goto-buffer-window KaTeX-sectioning-buffer-parent)
	  (save-excursion
		(goto-char (point-max))
		(undo-boundary)
		(while repllist
		  (if (search-backward (car (car repllist)) nil t)
			  (progn
				(goto-char (match-beginning 0))	;confirm
				(delete-region (point) (match-end 0))
				(insert (cdr (car repllist)))
				(goto-char (match-beginning 0))))
		  (setq repllist (cdr repllist))))
	  (goto-buffer-window cb)
	  (set-buffer-modified-p nil)))
)
(defun KaTeX-shift-section-down-region (beg end n)
  "Shift sectioning commands in region down by level N."
  (interactive "r\np")
  (KaTeX-shift-section-up-region beg end (- n))
)
(defun KaTeX-sectioning-buffer-next-line (n)
  "Move to next line in *Sectioning Lines* buffer."
  (interactive "p")
  (forward-line n)
  (skip-chars-forward " \t%")
)
(defun KaTeX-sectioning-buffer-prev-line (n)
  "Move to previous line in *Sectioning Lines* buffer."
  (interactive "p")
  (KaTeX-sectioning-buffer-next-line (- n))
)
