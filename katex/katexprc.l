;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX process handler.
;;; katexprc.l, v 1.67.1.11
;;; fixed by Maeda Manabu
;;; Last fixed  "Sat Sep 04 2004 21:33:52 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX process handler.
;;; yatexprc.el
;;; (c ) 1993-1999 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Tue Jul 13 13:47:46 1999 on firestorm
;;; $Old-Id: yatexprc.el,v 1.67 1999/07/15 04:58:48 yuuji Rel $

(provide "katexprc")

;(require "katex")
(require "katexlib")

(in-package "elisp")

(defvar KaTeX-typeset-process nil
  "Process identifier for jlatex")

(defvar KaTeX-typeset-buffer "*KaTeX-typesetting*"
  "Process buffer for jlatex")

(defvar KaTeX-typeset-buffer-syntax nil
  "*Syntax table for typesetting buffer")

(defvar KaTeX-current-TeX-buffer nil
  "Keeps the buffer on which recently typeset run.")

(defvar KaTeX-preview-process nil
  "Process identifier for dviout") ;m.m

(defvar KaTeX-shell-command-option
  (or (and (boundp 'shell-command-option) shell-command-option)
      (and (boundp 'shell-command-switch) shell-command-switch)
      "/c")
  "Shell option for command execution.")

(defvar *typeset-with-shell-command* nil) ;m.m

(defvar *preview-with-typeset* nil) ;m.m

(defvar KaTeX-latex-message-code
   (symbol-value (cdr (assq 1 KaTeX-kanji-code-alist)))
  "Process coding system for LaTeX.")

(if KaTeX-typeset-buffer-syntax nil
  (progn
    (setq KaTeX-typeset-buffer-syntax
	  (make-syntax-table)) ;m.m (standard-syntax-table)
    (set-syntax-word KaTeX-typeset-buffer-syntax #\{)
    (set-syntax-word KaTeX-typeset-buffer-syntax #\})
    (set-syntax-word KaTeX-typeset-buffer-syntax #\[)
    (set-syntax-word KaTeX-typeset-buffer-syntax #\])
  ))

(defun KaTeX-typeset-sentinel (proc)
  (cond ((null (buffer-name (process-buffer proc)))
         ;; buffer killed
         (set-process-buffer proc nil))
        ((memq (process-status proc) '(signal exit))
         (let* ((obuf (current-buffer)) (pbuf (process-buffer proc))
		(pwin (get-buffer-window pbuf))
		(owin (selected-window)) win
		(mes (if (eq (process-status proc) 'exit)
			 "finished\n" "run\n")))
           ;; save-excursion isn't the right thing if
           ;;  process-buffer is current-buffer
           (unwind-protect
               (progn
                 ;; Write something in *typesetting* and hack its mode line
		 (if pwin
		     (select-window pwin)
		   (set-buffer pbuf))
		 ;;(KaTeX-showup-buffer pbuf nil t)
                 (goto-char (point-max))
		 (if pwin (recenter -3))
                 (insert "\n" mode-name " " mes)
                 (forward-char -1)
                 (insert " at " (substring (current-time-string) 0 -5) "\n")
                 (forward-char 1)
                 ;(setq mode-line-process
                 ;      (concat ": "
                 ;              (symbol-name (process-status proc))))
		 (message "~A ~A." mode-name
			  (if (eq (process-status proc) 'exit)
			      "done" "ceased"))
                 ;; If buffer and mode line shows that the process
                 ;; is dead, we can delete it now.  Otherwise it
                 ;; will stay around until M-x list-processes.
                 (delete-process proc)
		 )
             (setq KaTeX-typeset-process nil)
             ;; Force mode line redisplay soon
             (set-buffer-modified-p (buffer-modified-p))
	     )
	   (select-window owin)
	   (set-buffer obuf)))
	))

(defun KaTeX-typeset (command buffer &optional prcname modename)
  "Execute jlatex (or other) to LaTeX typeset."
  (interactive)
  (save-excursion
    (let ((p (point)) (window (selected-window)) execdir (cb (current-buffer))
	  (map KaTeX-typesetting-mode-map)
	  (outcode
	   (cond ((eq buffer-mode 'katex-mode) KaTeX-coding-system)
		 ((eq buffer-mode 'yahtml-mode) yahtml-kanji-code))))
      (if (and KaTeX-typeset-process
	       (eq (process-status KaTeX-typeset-process) 'run))
	  ;; if tex command is halting.
	(KaTeX-kill-typeset-process KaTeX-typeset-process))
      (KaTeX-put-nonstopmode)
      (setq prcname (or prcname "LaTeX")
	    modename (or modename "typeset"))
      (if (eq buffer-mode 'katex-mode) (KaTeX-visit-main t)) ;;execution dir
      (setq execdir default-directory)
      ;;Select lower-most window if there are more than 2 windows and
      ;;typeset buffer not seen.
      (KaTeX-showup-buffer
       buffer (function (lambda (x) (nth 3 (window-edges x)))) t) ;m.m
;;;    (KaTeX-showup-buffer
;;;     buffer (function (lambda (x) (nth 3 (window-edges x)))))
      (set-buffer (get-buffer-create buffer))
      (setq default-directory execdir)
      (cd execdir)
      (erase-buffer)
      (make-local-variable 'need-not-save) ;m.m
      (setq need-not-save t) ;m.m
      (when *typeset-with-shell-command*
	(setq command (concat *shell* " " KaTeX-shell-command-option " " command)))
      (setq KaTeX-typeset-process ; *shell* " " KaTeX-shell-command-option " "
	    (make-process command
			  :output buffer :outcode KaTeX-latex-message-code))
      (set-process-sentinel KaTeX-typeset-process 'KaTeX-typeset-sentinel)
      (set-process-filter KaTeX-typeset-process 'KaTeX-typeset-process-filter)
      (message "Calling `~A'..." command)
      (setq KaTeX-current-TeX-buffer (buffer-name))
      (use-local-map map)		;map may be localized
      (set-syntax-table KaTeX-typeset-buffer-syntax)
      (setq mode-name modename)
      (set-marker (process-mark KaTeX-typeset-process) (1- (point)))
      (if (bolp) (forward-line -1))	;what for?
      (select-window (get-buffer-window buffer))
;;;   (if (and KaTeX-emacs-19 window-system) ;m.m ->
;;;     (let ((win (get-buffer-window buffer t)) owin)
;;;	    (select-frame (window-frame win))
;;;	    (setq owin (selected-window))
;;;	    (select-window win)
;;;	    (goto-char (point-max))
;;;	    (recenter -1)
;;;	    (select-window owin))
;;;	(progn
;;;	  (select-window (get-buffer-window buffer))
;;;	  (goto-char (point-max))
;;;	  (recenter -1))) ;m.m <-
      ;(message "Done.")
      (set-buffer-modified-p nil)
      (select-window window)
      (switch-to-buffer cb)
      (KaTeX-remove-nonstopmode))))

(defvar KaTeX-texput-file "texput.tex"
  "*File name for temporary file of typeset-region.")

(defun KaTeX-typeset-region ()
  "Paste the region to the file `texput.tex' and execute typesetter.
The region is specified by the rule:
	(1)If keyword `%#BEGIN' is found in the upper direction from (point).
	  (1-1)if the keyword `%#END' is found after `%#BEGIN',
		->Assume the text between `%#BEGIN' and `%#END' as region.
	  (1-2)if the keyword `%#END' is not found anywhere after `%#BEGIN',
		->Assume the text after `%#BEGIN' as region.
	(2)If no `%#BEGIN' usage is found before the (point),
		->Assume the text between current (point) and (mark) as region.
DON'T forget to eliminate the `%#BEGIN/%#END' notation after editing
operation to the region."
  (interactive)
  (save-excursion
    (let*
	((end "") typeout ;Type out message that tells the method of cutting.
	 (texput KaTeX-texput-file)
	 (cmd (concat (KaTeX-get-latex-command nil) " " texput))
	 (buffer (current-buffer)) opoint preamble (subpreamble "") main
	 (hilit-auto-highlight nil)	;for Emacs19 with hilit19
	 reg-begin reg-end lineinfo)

      (save-excursion
	(if (search-backward "%#BEGIN" nil t)
	    (progn
	      (setq typeout "--- Region from BEGIN to "
		    end "the end of the buffer ---"
		    reg-begin (match-end 0))
	      (if (search-forward "%#END" nil t)
		  (setq reg-end (match-beginning 0)
			end "END ---")
		(setq reg-end (point-max))))
	  (setq typeout "=== Region from (point) to (mark) ==="
		reg-begin (point) reg-end (mark)))
	(goto-char (min reg-begin reg-end))
	(setq lineinfo (count-lines (point-min) (point-end-of-line)))
	(goto-char (point-min))
	(while (search-forward "%#REQUIRE" nil t)
	  (setq subpreamble
		(concat subpreamble
			(cond
			 ((eolp)
			  (buffer-substring
			   (match-beginning 0)
			   (point-beginning-of-line)))
			 (t (buffer-substring
			     (match-end 0)
			     (point-end-of-line))))
			"\n"))
	  (goto-char (match-end 0))))
      (KaTeX-visit-main t)
      (setq main (current-buffer))
      (setq opoint (point))
      (goto-char (point-min))
      (setq
       preamble
       (if (re-search-forward "^[ 	]*\\\\begin.*{document}" nil t)
	   (buffer-substring (point-min) (match-end 0))
	 (concat "\\documentstyle{" KaTeX-default-document-style "}\n"
		 "\\begin{document}")))
      (goto-char opoint)
      ;;(set-buffer buffer)		;for clarity
      (let ((hilit-auto-highlight nil))
	(set-buffer (get-buffer-create "* temp*"))) ;m.m
;	(set-buffer (find-file-noselect texput))
      ;;(find-file KaTeX-texput-file)
      (erase-buffer)
      (if (and (eq buffer-mode 'katex-mode) KaTeX-need-nonstop)
	  (insert "\\nonstopmode{}\n"))
      (insert preamble "\n" subpreamble "\n")
      (setq lineinfo (list (count-lines 1 (point-end-of-line)) lineinfo))
      (insert-buffer-substring buffer reg-begin reg-end)
      (insert "\\typeout{" typeout end "}\n") ;Notice the selected method.
      (insert "\n\\end{document}\n")
      (set-buffer-file-name texput) ;m.m
      (basic-save-buffer)
      (kill-buffer (current-buffer))
      (set-buffer main)		;return to parent file or itself.
      (KaTeX-typeset cmd KaTeX-typeset-buffer)
      (switch-to-buffer buffer)		;for Emacs-19
      (put 'dvi2-command 'region t)
      (put 'dvi2-command 'file buffer)
      (put 'dvi2-command 'offset lineinfo))))

(defun KaTeX-typeset-buffer ()
  "Typeset whole buffer.
If %#! usage says other buffer is main text,
visit main buffer to confirm if its includeonly list contains current
buffer's file.  And if it doesn't contain editing text, ask user which
action wants to be done, A:Add list, R:Replace list, %:comment-out list."
  (interactive)
  (KaTeX-save-buffers)
  (let*((me (substring (buffer-name) 0 (rindex (buffer-name) #\.)))
	(mydir (file-name-directory (buffer-file-name)))
	(cmd (KaTeX-get-latex-command t)) (cb (current-buffer)))
    (setq default-directory mydir)
    (if (KaTeX-main-file-p) nil
      (progn
	(save-excursion
	  (KaTeX-visit-main t)	;search into main buffer
	  (save-excursion
	    (push-mark (point) t)
	    (goto-char (point-min))
	    (if (and (re-search-forward "^[ 	]*\\\\begin{document}" nil t)
		     (re-search-backward "^[ 	]*\\\\includeonly{" nil t))
	        (let*
		    ((b (progn (skip-chars-forward "^{") (point)))
		     (e (progn (skip-chars-forward "^}") (1+ (point))))
		     (s (buffer-substring b e)) c
		     (pardir (file-name-directory (buffer-file-name))))
		  (if (string-match (concat "[{,/]" me "[,}]") s)
		      nil ; Nothing to do when it's already in includeonly.
		    (progn
		      (ding)
		      (switch-to-buffer (current-buffer));Display this buffer.
		      (setq
		       me	  ;;Rewrite my name(me) to contain sub directory name.
		       (concat
		        (if (string-match pardir mydir) ;if mydir is child of main
			    (substring mydir (length pardir)) ;cut absolute path
		          mydir) ;else concat absolute path name.
		        me))
		      (message
		       "`~A' is not in \\includeonly. A)dd R)eplace %%)comment? "
		       me)
		      (setq c (read-char))
		      (cond
		       ((= c #\a)
		        (goto-char (1+ b))
		        (insert me (if (string= s "{}") "" ",")))
		       ((= c #\r)
		        (delete-region (1+ b) (1- e)) (insert me))
		       ((= c #\%)
		        (beginning-of-line) (insert "%"))
		       (t nil))
		      (save-buffer))))) ;m.m (basic-save-buffer)
	    (exchange-point-and-mark)))
	(switch-to-buffer cb)))		;for 19
    (KaTeX-typeset cmd KaTeX-typeset-buffer)
    (put 'dvi2-command 'region nil)))

(defvar KaTeX-call-command-history nil
  "Holds history list of KaTeX-call-command-on-file.")
(put 'KaTeX-call-command-history 'no-default t)
(defun KaTeX-call-command-on-file (base-cmd buffer)
  (KaTeX-save-buffers)
  (KaTeX-typeset
   (read-string-with-history
    "Call command: "
    (concat base-cmd " " (KaTeX-get-preview-file-name))
    'KaTeX-call-command-history)
   buffer))

(defun KaTeX-bibtex-buffer (cmd)
  "Pass the bibliography data of editing file to bibtex."
  (interactive)
  (KaTeX-save-buffers)
  (KaTeX-call-command-on-file cmd "*KaTeX-bibtex*" ))

(defun KaTeX-kill-typeset-process (proc)
  "Kill process PROC after sending signal to PROC.
PROC should be process identifier."
  (cond
   ((or (null proc) (not (eq (process-status proc) 'run)))
    (message "Typesetting process is not running."))
   (t
    (save-excursion
      (set-buffer (process-buffer proc))
      (save-excursion
	(goto-char (point-max))
	(beginning-of-line)
	(if (looking-at "\\? +$")
	    (let ((mp (point-max)))
	      (process-send-string proc "x\n")
	      (while (= mp (point-max)) (sit-for 1))))))
    (if (eq (process-status proc) 'run)
	(progn
	  (interrupt-process proc)
	  (delete-process proc))))))

(defun KaTeX-system (command buffer)
  "Execute some command on buffer.  Not a official function."
  (save-excursion
    (KaTeX-showup-buffer
     buffer (function (lambda (x) (nth 3 (window-edges x)))))
    (let ((df default-directory))		;preserve current buf's pwd
      (set-buffer (get-buffer-create buffer))	;1.61.3
      (setq default-directory df)
      (cd df))
    (erase-buffer)
    (if (not (fboundp 'start-process))
	(call-process
	 shell-file-name nil buffer nil KaTeX-shell-command-option command)
      (if (and (get-buffer-process buffer)
	       (eq (process-status (get-buffer-process buffer)) 'run)
	       (not
		(y-or-n-p (format nil "Process ~A is running. Continue?" buffer))))
	  nil
	(set-process-buffer
	 (start-process
	  "system" buffer shell-file-name KaTeX-shell-command-option command)
	 (get-buffer buffer))))))

(defvar KaTeX-preview-command-history nil
  "Holds minibuffer history of preview command.")
(put 'KaTeX-preview-command-history 'no-default t)
(defvar KaTeX-preview-file-history nil
  "Holds minibuffer history of file to preview.")
(put 'KaTeX-preview-file-history 'no-default t)

(defvar *last-preview-command* nil) ;m.m
(defvar *last-preview-file* nil)    ;m.m

(defun KaTeX-preview (preview-command preview-file)
  "Execute xdvi (or other) to tex-preview."
  (interactive
      (list
       (read-string-with-history
	"Preview command: "
	(or (KaTeX-get-builtin "PREVIEW") dvi2-command)
	'KaTeX-preview-command-history)
       (read-string-with-history
	"Preview file[.dvi]: "
	(if (get 'dvi2-command 'region)
	    (substring KaTeX-texput-file
		       0 (rindex KaTeX-texput-file #\.))
	  (KaTeX-get-preview-file-name))
	'KaTeX-preview-file-history)))
  (setq dvi2-command preview-command)	;`dvi2command' is buffer local
  (unless (string-matchp "\.dvi$" preview-file)
      (setq preview-file (concat preview-file ".dvi")))
  (cond
   ((file-exist-p preview-file)  ;m.m
    (save-excursion
      (KaTeX-visit-main t)
      (let ((pbuffer "*dvi-preview*") (dir default-directory))
;;;          (KaTeX-showup-buffer                     ;-> m.m
;;;            pbuffer (function (lambda (x) (nth 3 (window-edges x)))))
;;;	(set-buffer (get-buffer-create pbuffer))
;;;	(erase-buffer)
	(make-local-variable 'need-not-save)
	(setq need-not-save t) ;m.m <-
	(setq default-directory dir)	;for 18
	(cd dir)				;for 19
	(setq preview-command (concat preview-command " " preview-file))
	(when *typeset-with-shell-command*
	  (setq preview-command (concat *shell* " " KaTeX-shell-command-option
					" " preview-command)))
        (editor::call-process preview-command :no-std-handles t :show :show)
	(message
	 (concat "Starting " preview-command
		 " to preview " preview-file))
	(refresh-screen) ;m.m (redraw-display)
	)))
   (*preview-with-typeset*  ;m.m ->
    (setq *typeset-and-preview* t
	  *last-preview-command* preview-command
	  *last-preview-file* preview-file)
    (KaTeX-typeset-buffer))
   (t
    nil)))                  ;m.m <-

(defvar KaTeX-xdvi-remote-program "xdvi")
(defun KaTeX-xdvi-remote-search (&optional region-mode)
  "Search string at the point on xdvi -remote window.
Non-nil for optional argument REGION-MODE specifies the search string
by region."
  (interactive "P")
  (let ((pb " *xdvi*") str proc)
    (save-excursion
      (if region-mode
	  (setq str (buffer-substring (region-beginning) (region-end)))
	(setq str (buffer-substring
		   (point)
		   (progn (skip-chars-forward "^\n\\\\}") (point)))))
      (message "Searching `~A'..." str)
      (if (boundp 'MULE)
	  (define-program-coding-system
	    (regexp-quote pb) (regexp-quote KaTeX-xdvi-remote-program)
	    *euc-japan*))
      (setq proc
	    (start-process
	     "xdvi" pb KaTeX-xdvi-remote-program
	     "-remote"  (format nil "SloppySearch(~A) " str)
	     (concat (KaTeX-get-preview-file-name) ".dvi")))
      (message "Searching `~A'...Done" str))))

(defun KaTeX-set-virtual-error-position (file-sym line-sym)
  "Replace the value of FILE-SYM, LINE-SYM by virtual error position."
  (cond
   ((and (get 'dvi2-command 'region)
	 (> (symbol-value line-sym) (car (get 'dvi2-command 'offset))))
    (set file-sym (get 'dvi2-command 'file))
    (set line-sym
	 (+ (- (apply '- (get 'dvi2-command 'offset)))
	    (symbol-value line-sym)
	    -1)))))

(defun KaTeX-prev-error ()
  "Visit previous typeset error.
  To avoid making confliction of line numbers by editing, jump to
error or warning lines in reverse order."
  (interactive)
  (let ((cur-buf (buffer-name)) (cur-win (selected-window))
	error-line typeset-win error-buffer error-win)
    (if (null (get-buffer KaTeX-typeset-buffer))
	(error "There is no typesetting buffer."))
    (KaTeX-showup-buffer KaTeX-typeset-buffer nil t)
    (setq typeset-win (selected-window))
    (if (re-search-backward
	 (concat "\\(" latex-error-regexp "\\)\\|\\("
		 latex-warning-regexp "\\)")
	 nil t)
	nil
      (progn
	(select-window cur-win)
	(error "No more errors on ~A" cur-buf)))
    (goto-char (match-beginning 0))
    (skip-chars-forward "^0-9" (match-end 0))
    (setq error-line
	  (string-to-int
	   (buffer-substring
	    (point)
	    (progn (skip-chars-forward "0-9" (match-end 0)) (point))))
	  error-buffer (KaTeX-get-error-file cur-buf))
    (if (or (null error-line) (equal 0 error-line))
	(error "Can't detect error position."))
    (KaTeX-set-virtual-error-position 'error-buffer 'error-line)
    (setq error-win (get-buffer-window error-buffer))
    (select-window cur-win)
    (cond
     (error-win (select-window error-win))
     ((eq (get-lru-window) typeset-win)
      (KaTeX-switch-to-buffer error-buffer))
     (t (select-window (get-lru-window))
	(KaTeX-switch-to-buffer error-buffer)))
    (setq error-win (selected-window))
    (goto-line error-line)
    (message "LaTeX ~A in `~A' on line: ~D."
	     (if (match-beginning 1) "error" "warning")
	     error-buffer error-line)
    (sit-for 1) ;m.m
    (select-window typeset-win)
    (skip-chars-backward "0-9")
    (recenter (/ (window-height) 2))
;    (sit-for 1) ;m.m
;    (goto-char (match-beginning 0))
    (select-window error-win)))

(defun KaTeX-jump-error-line ()
  "Jump to corresponding line on latex command's error message."
  (interactive)
  (let (error-line error-file error-buf)
    (save-excursion
      (beginning-of-line)
      (setq error-line (re-search-forward "l[ ines]*\\.?\\([1-9][0-9]*\\)"
					  (point-end-of-line) t)))
    (if (null error-line)
	(if (eobp) (insert *last-command-char*) ;(insert (this-command-keys))
	  (error "No line number expression."))
      (progn
	(goto-char (match-beginning 0))
        (setq error-line (string-to-int
			  (buffer-substring (match-beginning 1) (match-end 1)))
	      error-file ;(expand-file-name ;m.m
			  (KaTeX-get-error-file KaTeX-current-TeX-buffer);)
	)
        (KaTeX-set-virtual-error-position 'error-file 'error-line)
	(save-excursion    ; m.m
	  (setq error-buf (KaTeX-switch-to-buffer error-file t)))))
    (if (null error-buf)
        (error "`~A' is not found in this directory." error-file))
    (KaTeX-showup-buffer error-buf nil t)
    (goto-line error-line)))

(defun KaTeX-send-string ()
  "Send string to current typeset process."
  (interactive)
  (if (and (eq (process-status KaTeX-typeset-process) 'run)
	   (>= (point) (mark)))
    (let ((b (mark))
	  (e (point-end-of-line)))
      (goto-char b)
      (skip-chars-forward " \t" e)
      (setq b (point))
      (process-send-string
       KaTeX-typeset-process (concat (buffer-substring b e) "\n"))
      (goto-char e)
      (insert "\n")
      (set-marker (process-mark KaTeX-typeset-process) (point)))
    (ding)))

(defun KaTeX-view-error ()
  (interactive)
  (if (null (get-buffer KaTeX-typeset-buffer))
      (message "No typeset buffer found.")
    (let ((win (selected-window)))
      (KaTeX-showup-buffer KaTeX-typeset-buffer nil t)
      ;; Next 3 lines are obsolete because KaTeX-typesetting-buffer is
      ;; automatically scrolled up at typesetting.
      ;;(goto-char (point-max))
      ;;(forward-line -1)
      ;;(recenter -1)
      (select-window win))))

(defun KaTeX-get-error-file (default)
  "Get current processing file from typesetting log."
  (save-excursion
    (let (s (pt nil))
;      (handler-case (up-list -1)  ;m.m
;	(error  ;m.m
	    (let ((list 0) (found nil))
	      (while
		  (and (<= list 0) (not found)
		       (re-search-backward "\\((\\)\\|\\()\\)" nil t))
		(if (equal (match-beginning 0) (match-beginning 2)) ;close paren.
		  (setq list (1- list)) ;open paren
		  (progn
		    (setq list (1+ list))
		    (if (= list 1)
			(if (looking-at "\\([^,{}%]+\.\\)\\(tex\\|sty\\)")
			    (setq found t)
			  (setq list (1- list))))))))
;	))  ;m.m
      (setq s (map-backslash-to-slash
	       (buffer-substring
		(progn (forward-char 1) (point))
		(progn (skip-chars-forward "^ \n" (point-end-of-line))
		  (point)))))
      (if (string= "" s) default s))))

(defun KaTeX-put-nonstopmode ()
  (if (and (eq buffer-mode 'katex-mode) KaTeX-need-nonstop)
      (if (re-search-backward "\\\\nonstopmode{}" (point-min) t)
	  nil                    ;if already written in text then do nothing
	(save-excursion
	  (KaTeX-visit-main t)
	  (goto-char (point-min))
	  (insert "\\nonstopmode{}%_KaTeX_%\n")
	  (if (buffer-file-name) (basic-save-buffer))))))

(defun KaTeX-remove-nonstopmode ()
  (if (and (eq buffer-mode 'katex-mode) KaTeX-need-nonstop) ;for speed
      (save-excursion
	(KaTeX-visit-main t)
	(goto-char (point-min))
	(forward-line 1)
	(narrow-to-region (point-min) (point))
	(goto-char (point-min))
	(delete-matching-lines "^\\\\nonstopmode\\{\\}%_KaTeX_%$")
	(widen))))

(defun KaTeX-get-preview-file-name ()
  "Get file name to preview by inquiring KaTeX-get-latex-command"
  (let* ((latex-cmd (KaTeX-get-latex-command t))
	 (rin (rindex latex-cmd #\SPC))
	 (fname (if (> rin -1) (substring latex-cmd (1+ rin)) ""))
	 (period))
    (if (string= fname "")
	(setq fname (substring (file-name-nondirectory
				(buffer-file-name))
			       0 -4))
      (progn
	(setq period (rindex fname #\.))
	(setq fname (substring fname 0 (if (eq -1 period) nil period)))))))

(defun KaTeX-get-latex-command (&optional switch)
  "Specify the latex-command name and its argument.
If there is a line which begins with string: \"%#!\", the following
strings are assumed to be the latex-command and arguments.  The
default value of latex-command is:
	tex-command FileName
and if you write \"%#!jlatex\" in the beginning of certain line.
	\"jlatex \" FileName
will be the latex-command,
and you write \"%#!jlatex main.tex\" on some line and argument SWITCH
is non-nil, then
	\"jlatex main.tex\"

will be given to the shell."
  (let (magic command target)
    (setq parent
	  (cond
	   (KaTeX-parent-file KaTeX-parent-file)
	   (t (save-excursion
		(KaTeX-visit-main t)
		(file-name-nondirectory (buffer-file-name)))))
	  magic (KaTeX-get-builtin "!"))
    (cond
     (magic
      (cond
       (switch (if (string-match "\\s " magic) magic
		 (concat magic " " parent)))
       (t (concat (substring magic 0 (string-match "\\s " magic)) " "))))
     (t (concat tex-command " " (if switch parent))))))

(defvar KaTeX-lpr-command-history nil
  "Holds command line history of KaTeX-lpr.")
(put 'KaTeX-lpr-command-history 'no-default t)
(defun KaTeX-lpr (arg)
  "Print out.  If prefix arg ARG is non nil, call print driver without
page range description."
  (interactive "P")
  (let*((cmd (or (KaTeX-get-builtin "LPR") dviprint-command-format))
	from to (lbuffer "*dvi-printing*") dir)
    (setq
     cmd
     (KaTeX-replace-format
      cmd "f"
      (if (or arg (not (string-match "%f" cmd)))
	  ""
	(KaTeX-replace-format
	 dviprint-from-format
	 "b"
	 (if (string=
	      (setq from (read-string "From page(default 1): ")) "")
	     "1" from))))
     )
    (setq
     cmd
     (KaTeX-replace-format
      cmd "t"
      (if (or arg (not (string-match "%t" cmd))
	      (string=
	       (setq to (read-string "To page(default none): ")) ""))
	  ""
	(KaTeX-replace-format dviprint-to-format "e" to)))
     )
    (setq cmd                                          ;m.m ->
	  (read-string-with-history
	   "Edit command line: "
	   (KaTeX-replace-format cmd "s"
		   (if (get 'dvi2-command 'region)
		       (substring KaTeX-texput-file
				  0 (rindex KaTeX-texput-file #\.))
		     (KaTeX-get-preview-file-name)))
	   'KaTeX-lpr-command-history))                ;m.m <-
    (save-excursion
      (KaTeX-visit-main t) ;;change execution directory
      (setq dir default-directory)
      (KaTeX-showup-buffer
       lbuffer (function (lambda (x) (nth 3 (window-edges x)))))
      (set-buffer (get-buffer-create lbuffer))
      (make-local-variable 'need-not-save) ;m.m ->
      (setq need-not-save t) ;m.m <-
      (erase-buffer)
      (cd dir)				;for 19
      (when *typeset-with-shell-command*
	(setq cmd (concat *shell* " " KaTeX-shell-command-option
			  " " cmd)))
      (editor::call-process cmd :output "*dvi-printing*" :no-std-handles t :show :show)
      )))

(defun KaTeX-main-file-p ()
  "Return if current buffer is main LaTeX source."
  (cond
   (KaTeX-parent-file
    (eq (get-file-buffer KaTeX-parent-file) (current-buffer)))
   ((KaTeX-get-builtin "!")
    (string-match (KaTeX-guess-parent (KaTeX-get-builtin "!")) (buffer-name)))
   (t
    (save-excursion
      (let ((latex-main-id
			 (concat "^\\s *" KaTeX-ec-regexp "document\\(style\\|class\\)")))
		(or (re-search-backward latex-main-id nil t)
			(re-search-forward latex-main-id nil t)))))))

(defun KaTeX-visit-main (&optional setbuf)
  "Switch buffer to main LaTeX source.
Use set-buffer instead of switch-to-buffer if the optional second argument
SETBUF is t(Use it only from Emacs-Lisp program)."
  (interactive "P")
  (if (and (interactive-p) setbuf) (setq KaTeX-parent-file nil))
  (let (b-in main-file)
    (if (setq b-in (KaTeX-get-builtin "!"))
	(setq main-file (KaTeX-guess-parent b-in)))
    (if KaTeX-parent-file
	(setq main-file ;;(get-file-buffer KaTeX-parent-file)
	      KaTeX-parent-file))
    (if (KaTeX-main-file-p)
	(if (interactive-p) (message "I think this is main LaTeX source.") nil)
      (cond
       ((and (interactive-p) main-file (get-file-buffer main-file))
	(goto-buffer-window main-file))
       ((and main-file (KaTeX-switch-to-buffer main-file setbuf)))
       ((and main-file
	     (file-exists-p (setq main-file (concat "../" main-file)))
	     (y-or-n-p (concat (expand-file-name main-file)
			       " is main file?:")))
	(setq KaTeX-parent-file main-file)
	(KaTeX-switch-to-buffer main-file setbuf))
       (t (setq main-file (read-file-name "Enter your main text: " nil nil 1))
	  (setq KaTeX-parent-file main-file)
	  (KaTeX-switch-to-buffer main-file setbuf))
       )))
  nil)

(defun KaTeX-guess-parent (command-line)
  (setq command-line
	(if (string-match ".*\\s " command-line)
	    (substring command-line (match-end 0))
	  (file-name-nondirectory (buffer-file-name)))
	command-line
	(concat (if (string-match "\\(.*\\)\\." command-line)
		    (substring command-line (match-beginning 1) (match-end 1))
		  command-line)
		".tex")))

(defun KaTeX-visit-main-other-window ()
  "Switch to buffer main LaTeX source in other window."
  (interactive)
  (if (KaTeX-main-file-p) (message "I think this is main LaTeX source.")
      (KaTeX-switch-to-buffer-other-window
       (concat (KaTeX-get-preview-file-name) ".tex"))))

(defun KaTeX-get-builtin (key)
  "Read source built-in command of %# usage."
  (save-excursion
    (goto-char (point-min))
    (if (and (re-search-forward
	      (concat "^" (regexp-quote (concat "%#" key))) nil t)
	     (not (eolp)))
	(buffer-substring
	 (progn (skip-chars-forward " 	" (point-end-of-line))(point))
	 (point-end-of-line))
      nil)))

(defun KaTeX-save-buffers () ;m.m
  "Save buffers whose buffer-mode is equal to current buffer-mode."
  (save-buffer)
  (let ((cmm buffer-mode))
	(save-excursion
	  (dolist (buf (buffer-list))
		(set-buffer buf)
		(if (and (buffer-file-name buf)
				 (eq buffer-mode cmm)
				 (buffer-modified-p buf)
				 (y-or-n-p (format nil "Save ~A" (buffer-name buf))))
			(save-buffer buf))))
  ))

;m.m ->
(defun KaTeX-typeset-process-filter (proc string)
  "latex からの出力を監視するフィルタ"
  (let ((buffer (process-buffer proc))
		(window (selected-window)))
    (and (get-buffer-window buffer)
	 (set-window (get-buffer-window buffer)))
    (set-buffer buffer)
    (goto-char (point-max))
    (insert string)
    (recenter -1)
    (set-mark (point))
    (refresh-screen)
    (cond
     ((string-match "^? $" string)
	  (let ((procwin (selected-window)))
		(set-window window)
		(KaTeX-prev-error)
		(set-window procwin)
		(goto-char (point-max))
		(refresh-screen)))
     ((string-match "^Enter file name: $" string)
     )
     ;((string-match "^LaTeX Warning: Label(s) may have changed." string)
     ; (set-window window))
     ((and (string-match "^Output written on [^. ]+\.dvi" string)
	   *typeset-and-preview*)
      (set-window window)
      (setq *typeset-and-preview* nil)
      (KaTeX-preview *last-preview-command* *last-preview-file*)
      (refresh-screen))
     (t
      (set-window window)))))
;m.m <-
