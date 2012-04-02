;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX helper with LaTeX commands and macros.
;;; katexhlp.l, 1.66.1.7
;;; fixed by Maeda Manabu
;;; Last fixed  "Sun Jun 29 2003 17:24:53 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX helper with LaTeX commands and macros.
;;; yatexhlp.el
;;; (c ) 1994,1998 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Thu Mar 12 11:10:07 1998 on crx
;;; $Old-Id: yatexhlp.el,v 1.66 1998/10/26 12:05:53 yuuji Rel $

(provide "katexhlp")

(in-package "elisp")

(let ((help-file (concat "katexHLP."
			 (cond (KaTeX-japan "jp")
			       (t "eng"))))
      (help-dir (concat (si:system-root) doc-directory)))
  (defvar KaTeX-help-file
    (expand-file-name help-file help-dir)
    "*Help file of LaTeX/TeX commands or macros.")
  (defvar KaTeX-help-file-private
    (expand-file-name (concat "~/" help-file))
    "*Private help file of LaTeX/TeX macros."))

(defvar KaTeX-help-delimiter "" "Delimiter of each help entry.") ; m.m \C-_
(defvar KaTeX-help-entry-map (copy-keymap *KaTeX-mode-map*)
  "Key map used in help entry.")
(defvar KaTeX-help-file-current nil
  "Holds help file name to which the description in current buffer should go.")
(defvar KaTeX-help-command-current nil
  "Holds command name on which the user currently write description.")
(defvar KaTeX-help-saved-config nil
  "Holds window configruation before the editing of manual.")
(defvar KaTeX-help-synopsis
  (cond (KaTeX-japan "ÅyèëéÆÅz")
	(t "[[ Synopsis ]]"))
  "Section header of synopsis.")
(defvar KaTeX-help-description
  (cond (KaTeX-japan "Åyê‡ñæÅz")
	(t "[[ Description ]]"))
  "Section header of description.")

(defvar KaTeX-help-reference-regexp "<refer\\s +\\([^>]+\\)>"
  "Regexp of reference format of KaTeX-help file.")
(defvar KaTeX-help-buffer "** KaTeX HELP **" "Help buffer name for katexhlp")

(defun KaTeX-help-entries ()
  "Return the alist which contains all the entries in KaTeX-help file."
  (let (entries entry)
    (save-excursion
      (mapcar
       (function
	(lambda (help)
	  (if (file-exists-p help)
	      (progn
		(set-buffer (find-file-noselect help))
		(save-excursion
		  (goto-char (point-min))
		  (while (re-search-forward
			  (concat "^" (regexp-quote KaTeX-help-delimiter)
				  "\\(.+\\)$") nil t)
		    (setq entry (buffer-substring
				 (match-beginning 1) (match-end 1)))
		    (or (assoc entry entries)
			(setq entries (cons (list entry) entries)))))))))
       (list KaTeX-help-file KaTeX-help-file-private)))
    entries)
)

(defvar KaTeX-help-entries (KaTeX-help-entries))

(defun KaTeX-help-resolve-reference (buffer1 buffer2 &optional done-list)
  "Replace reference format in buffer1 with refered contents in buffer2."
  (let (ref ref-list beg end)
    (save-excursion
      (switch-to-buffer buffer1)
      (goto-char (point-min))
      (while (re-search-forward KaTeX-help-reference-regexp nil t)
	(setq ref (buffer-substring (match-beginning 1) (match-end 1))
	      ref-list (cons (list ref) ref-list))
	(replace-match "")
	(if (assoc ref done-list) nil	;already documented.
	  (progn
	    (switch-to-buffer buffer2)
	    (save-excursion
	      (goto-char (point-min))
	      (if (re-search-forward
		   (concat (regexp-quote KaTeX-help-delimiter)
			   (regexp-quote ref)
			   "$") nil t)
		  (progn
		    (setq beg (progn (forward-line 2) (point))
			  end (progn
			        (re-search-forward
			         (concat "^" (regexp-quote KaTeX-help-delimiter))
			         nil 1)
			        (goto-char (match-beginning 0))
			        (forward-line -1)
			        (while (and (bolp) (eolp) (not (bobp)))
				(forward-char -1))
			        (point)))
		    (switch-to-buffer buffer1)
		    (insert-buffer-substring buffer2 beg end))))
	    (switch-to-buffer buffer1))))
      (if beg (KaTeX-help-resolve-reference
	       buffer1 buffer2 (append done-list ref-list))))
    )
)

(defun KaTeX-refer-help (command help-file &optional append)
  "Refer the COMMAND's help into HELP-FILE.
\[Help-file format\]
<DELIM><LaTeX/TeX command without escape character(\\)><NL>
<Synopsis><NL>
<Documentation><TERM>
Where:	<DELIM> is the value of KaTeX-help-delimiter.
	<NL> is newline.
	<TERM> is newline or end of buffer."
  (save-excursion ;m.m
    (let ((hfbuf (find-file-noselect help-file))
	  (hbuf (get-buffer-create KaTeX-help-buffer))
	  (curwin (selected-window))
	  sb se db de)
      (set-buffer hfbuf)
      (goto-char (point-min))
      (if (null
	   (let ((case-fold-search nil))
	     (re-search-forward
	      (concat (regexp-quote KaTeX-help-delimiter)
		      (regexp-quote command)
		      "$") nil t)))
	  nil				;if not found, return nil
	(progn
	  (forward-line 1)
	  (setq sb (point)
		se (progn (forward-line 1) (point))
		db (point)
		de (progn
		     (re-search-forward
		      (concat "^" (regexp-quote KaTeX-help-delimiter)) nil 1)
		     (- (point) (length KaTeX-help-delimiter))))
	  (KaTeX-showup-buffer
	   hbuf (function (lambda (x) (nth 3 (window-edges x)))) t)
	  (set-buffer hbuf)
	  (if append (goto-char (point-max)) (erase-buffer))
	  (insert KaTeX-help-synopsis "\n")
	  (insert-buffer-substring hfbuf sb se)
	  (insert "\n" KaTeX-help-description "\n")
	  (insert-buffer-substring hfbuf db de)
	  (KaTeX-help-resolve-reference hbuf hfbuf (list (list command)))
	  (goto-char (point-min))
	  (setup-temp-buffer hbuf)
	  (select-window curwin)
	  (unless append (kill-buffer hfbuf)) ;m.m
	  t)))
    ))
(defun KaTeX-help-newline (&optional arg)
  (interactive "P")
  (if (and (= (current-column) 1) (= (preceding-char) #\.) (eolp))
;  (if (and (= (current-column) 1) (char= (preceding-char) #\.) (eolp))
      (let ((cbuf (current-buffer)))
	(beginning-of-line)
	(delete-region (point) (progn (forward-line 1) (point)))
	(save-excursion
	  (KaTeX-help-add-entry
	   KaTeX-help-command-current KaTeX-help-file-current))
	(set-window-configuration KaTeX-help-saved-config)
	(bury-buffer cbuf))
    (newline arg))
)
(defun KaTeX-help-add-entry (command help-file)
  (let ((hfbuf (find-file-noselect help-file))
		(dbuf (current-buffer)) beg end)
    (goto-char (point-min))
    (re-search-forward (concat "^" (regexp-quote KaTeX-help-synopsis)))
    (forward-line 1)	(setq beg (point))
    (end-of-line)	(setq end (point))
    (set-buffer hfbuf)
    (goto-char (point-min))
    (insert KaTeX-help-delimiter command "\n")
    (insert-buffer-substring dbuf beg end)
    (insert "\n")
    (set-buffer dbuf)
    (re-search-forward (concat "^" (regexp-quote KaTeX-help-description)))
    (forward-line 1)
    (setq beg (point))
    (setq end (point-max))
    (set-buffer hfbuf)
    (insert-buffer-substring dbuf beg end)
    (insert "\n\n")
    (forward-line -1)
    (delete-blank-lines)
    (let ((make-backup-files t))
      (basic-save-buffer))
    (bury-buffer hfbuf)
    (setq KaTeX-help-entries (cons (list command) KaTeX-help-entries)))
)
(defun KaTeX-help-prepare-entry (command help-file)
  "Read help description on COMMAND and add it to HELP-FILE."
  (let ((buf (get-buffer-create "**Description**"))
		(conf (current-window-configuration)))
    (KaTeX-showup-buffer
     buf (function (lambda (x) (nth 3 (window-edges x)))) t)
    (make-local-variable 'KaTeX-help-file-current)
    (make-local-variable 'KaTeX-help-command-current)
    (make-local-variable 'KaTeX-help-saved-config)
    (setq KaTeX-help-file-current help-file
	  KaTeX-help-command-current command
	  KaTeX-help-saved-config conf
	  mode-name "Text"
	  buffer-mode 'text-mode)
    (erase-buffer)
    (insert KaTeX-help-synopsis "\n\n" KaTeX-help-description "\n\n")
    (define-key KaTeX-help-entry-map #\RET 'KaTeX-help-newline)
    (use-local-map KaTeX-help-entry-map)
    (message
     (cond (KaTeX-japan "ì¸óÕÇèIÇ¶ÇΩÇÁ . ÇÃÇ›ì¸óÕÇµÇƒRET")
	   (t "Type only `.' and RET to exit."))))
)
(defun KaTeX-enrich-help (command)
  "Add the COMMAND's help to help file."
  (if (y-or-n-p (format nil "No help on `~A'. Create help?" command))
      (KaTeX-help-prepare-entry
       command
       (if (y-or-n-p "Add help to global documentation?")
	   KaTeX-help-file KaTeX-help-file-private)))
)

(defun KaTeX-help-sort (&optional help-file)
  "Sort help file HELP-FILE.
If HELP-FILE is nil or called interactively, sort current buffer
as a help file."
  (interactive)
  (if help-file (set-buffer (find-file-noselect help-file)))
  (sort-regexp-fields
   nil "\\(\\sw+\\)\\([^]+\\|\\s'\\)" "\\1" (point-min) (point-max))
)

(defun KaTeX-apropos-file (keyword help-file &optional append)
  (save-excursion ;m.m
    (let ((hb (find-file-noselect help-file))
	  (ab (get-buffer-create KaTeX-help-buffer))
	  (sw (selected-window))
	  (head (concat "^" (regexp-quote KaTeX-help-delimiter)))
	  pt command)
      (KaTeX-showup-buffer
       ab (function (lambda (x) (nth 3 (window-edges x)))))
      ;(select-window (get-buffer-window ab)) ;m.m
      (set-buffer ab)			;assertion
      (or append (erase-buffer))
      (set-buffer hb)
      (goto-char (point-min))
      (while (re-search-forward keyword nil t)
	(setq pt (point))
	(re-search-backward head nil t)
	(setq command (buffer-substring (match-end 0) (point-end-of-line)))
	(switch-to-buffer ab)
	(goto-char (point-max))
	(insert-char #\- (1- (window-width)))
	(insert (format nil "\n<<~A>>\n" command))
	(KaTeX-refer-help command help-file t) ;append mode
	(set-buffer hb)
	(goto-char pt)
	(if (re-search-forward head nil 1)
	    (goto-char (1- (match-beginning 0)))))
      (select-window sw)
      pt))
  )

;;;###autoload
(defun KaTeX-apropos (key)
  (interactive "sLaTeX apropos (regexp): ")
  (if (string= "" key) (error "Nothing to show"))
  (or (KaTeX-apropos-file key KaTeX-help-file)
      (KaTeX-apropos-file key KaTeX-help-file-private t)
      (message "No matches found."))
)

;;;###autoload
(defun KaTeX-help ()
  "Show help buffer of LaTeX/TeX commands or macros."
  (interactive)
  (let (p beg end command)
    (save-excursion
      (if (looking-at KaTeX-ec-regexp)
	  (goto-char (match-end 0)))
      (setq p (point))			;remember current position.
      (cond
       ((KaTeX-on-begin-end-p)
	;;if on \begin or \end, extract its environment.
	(setq command
	      (cond ((match-beginning 1)
		     (buffer-substring (match-beginning 1) (match-end 1)))
		    ((match-beginning 2)
		     (buffer-substring (match-beginning 2) (match-end 2))))))
       ((search-backward KaTeX-ec (point-beginning-of-line) t)
	(goto-char (setq beg (match-end 0)))
	(re-search-forward KaTeX-TeX-token-regexp (point-end-of-line) t)
	(setq end (point))
	(if (and (<= beg p) (<= p end))
	    (setq command (buffer-substring beg end)))))
      (if (or (string= command "begin") (string= command "end"))
	  (progn
	    (search-forward "{" (point-end-of-line))
	    (setq beg (point))
	    (search-forward "}" (point-end-of-line))
	    (setq command (buffer-substring beg (match-beginning 0)))))
      (setq command
	    (completing-read
	     "Describe (La)TeX command: "
	     KaTeX-help-entries nil nil command))
      );end excursion
    (or (KaTeX-refer-help command KaTeX-help-file)
	(KaTeX-refer-help command KaTeX-help-file-private)
	(KaTeX-enrich-help command)))
)
