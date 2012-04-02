;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX and kahtml common libraries, general functions and definitions
;;; katexlib.l, v 1.67.1.3
;;; fixed by Maeda Manabu
;;; Last fixed  "Fri Oct 31 2003 23:04:25 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX and yahtml common libraries, general functions and definitions
;;; yatexlib.el
;;; (c ) 1994-1999 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Tue May  4 10:25:55 1999 on firestorm
;;; $Old-Id: yatexlib.el,v 1.67 1999/07/15 04:58:48 yuuji Rel $

(provide "katexlib")

(in-package "elisp")

;; General variables
(defvar KaTeX-emacs-19 (>= (string-to-int emacs-version) 19))
(defvar KaTeX-emacs-20 (>= (string-to-int emacs-version) 20))
(defvar KaTeX-user-completion-table "~/_katexrc"
  "*Default filename in which user completion table is saved.")

(defvar KaTeX-japan t
  "Whether katex mode is running on Japanese environment or not.")

(defvar KaTeX-kanji-code-alist
  (list '(1 . *encoding-sjis*)
	'(2 . *encoding-jis*)
	'(3 . *encoding-euc-jp*))
  "Kanji-code expression translation table.")
(defvar KaTeX-inhibit-prefix-letter nil
  "*T for changing key definitions from [prefix] Letter to [prefix] C-Letter.")

(defvar KaTeX-no-begend-shortcut nil
  "*T for disabling shortcut of begin-type completion, [prefix] b d, etc.")

(defvar KaTeX-default-pop-window-height 10
  "Default typesetting buffer height.
If integer, sets the window-height of typesetting buffer.
If string, sets the percentage of it.
If nil, use default pop-to-buffer.")

(defvar KaTeX-create-file-prefix-g nil
  "*Non-nil creates new file when [prefix] g on \\include{foo}.")

(defvar KaTeX-nervous t
  "*If you are nervous about maintenance of katexrc, set this value to T.
And you will have the local dictionary.")

;----------- work variables ----------------------------------------
(defvar KaTeX-typesetting-mode-map nil
  "Keymap used in KaTeX typesetting buffer")

(if KaTeX-typesetting-mode-map nil
  (progn
    (setq KaTeX-typesetting-mode-map (make-keymap))
    ;(suppress-keymap KaTeX-typesetting-mode-map t)
    (define-key KaTeX-typesetting-mode-map #\SPC 'KaTeX-jump-error-line)
    (define-key KaTeX-typesetting-mode-map #\C-m 'KaTeX-send-string)
    (define-key KaTeX-typesetting-mode-map #\1 'delete-other-windows)
    (define-key KaTeX-typesetting-mode-map #\0 'delete-window)
    (define-key KaTeX-typesetting-mode-map #\q 'delete-window)))

(defvar KaTeX-parent-file nil
  "*Main LaTeX source file name used when %#! expression doesn't exist.")
(make-variable-buffer-local 'KaTeX-parent-file)

;---------- Define default key bindings on KaTeX mode map ----------
;;;###autoload
(defun KaTeX-define-key (key binding &optional map)
  "Define key on *KaTeX-prefix-map*."
  (if KaTeX-inhibit-prefix-letter
      (let ((c (if (listp key) (nth 0 key) key)))
	(cond
	 ((and (>= c #\a) (<= c #\z))
;	 ((and (char>= c #\a) (char<= c #\z))
	  (if (listp key)
	      (setq key (append (list (1+ (- c #\a))) (cdr key)))
;	      (setq key (append (list (char1+ (char- c #\a))) (cdr key)))
	    (setq key (1+ (- c #\a)))))
;	    (setq key (char1+ (char- c #\a)))))
	 ((and (>= c #\A) (<= c #\Z)
;	 ((and (char>= c #\A) (char<= c #\Z)
	       (numberp KaTeX-inhibit-prefix-letter))
	  (if (listp key)
	      (setq key (append (list (1+ (- c #\A))) (cdr key)))
;	      (setq key (append (list (char1+ (char- c #\A))) (cdr key)))
	    (setq key (1+ (- c #\A)))))
;	    (setq key (char1+ (char- c #\A)))))
	 (t nil))))
  (define-key (or map *KaTeX-prefix-map*) key binding))

;;;###autoload
(defun KaTeX-local-table-symbol (symbol)
  "Return the lisp symbol which keeps local completion table of SYMBOL."
  (intern (concat "KaTeX$"
		  default-directory
		  (symbol-name symbol))))

;;;###autoload
(defun KaTeX-sync-local-table (symbol)
  "Synchronize local variable SYMBOL.
Copy its corresponding directory dependent completion table to SYMBOL."
  (if (boundp (KaTeX-local-table-symbol symbol))
      (set symbol (symbol-value (KaTeX-local-table-symbol symbol)))))

(defvar KaTeX-user-table-is-read nil
  "Flag that means whether user completion table has been read or not.")
;;;###autoload
(defun KaTeX-read-user-completion-table (&optional forcetoread)
  "Append user completion table of LaTeX macros"
  (let*((user-table (expand-file-name KaTeX-user-completion-table))
		(curbuf (current-buffer)))
	(unless KaTeX-user-table-is-read
	  (message "Loading user completion table")
	  (if (file-exists-p user-table)
		  (load-file user-table)
		(message "Welcome to the field of KaTeX.  I'm glad to see you!")))
	(setq KaTeX-user-table-is-read t)
	(set-buffer curbuf)))

;;;###autoload
(defun KaTeX-reload-dictionary ()
  "Reload local dictionary.
Use this function after editing ./_katexrc."
  (interactive)
  (setq KaTeX-user-table-is-read nil)
  (KaTeX-read-user-completion-table t))

;;;###autoload
(defun KaTeX-lookup-table (word type)
  "Lookup WORD in completion table whose type is TYPE.
This function refers the symbol tmp-TYPE-table, user-TYPE-table, TYPE-table.
Typically, TYPE is one of 'env, 'section, 'fontsize, 'singlecmd."
  (if (symbolp type) (setq type (symbol-name type)))
  (or (assoc word (symbol-value (intern (concat "tmp-" type "-table"))))
      (assoc word (symbol-value (intern (concat "user-" type "-table"))))
      (assoc word (symbol-value (intern (concat type "-table"))))))

;;;###autoload
(defun KaTeX-update-table (vallist default-table user-table local-table)
  "Update completion table if the car of VALLIST is not in current tables.
Second argument DEFAULT-TABLE is the quoted symbol of default completion
table, third argument USER-TABLE is user table which will be saved in
KaTeX-user-completion-table, fourth argument LOCAL-TABLE should have the
completion which is valid during current Emacs's session.  If you
want to make LOCAL-TABLE valid longer span (but restrict in this directory)
create the file in current directory which has the same name with
KaTeX-user-completion-table."
  (let ((car-v (car vallist)) key answer
		(file (file-name-nondirectory KaTeX-user-completion-table)))
	(cond
	 ((assoc car-v (symbol-value default-table))
	  nil) ;Nothing to do
	 ((setq key (assoc car-v (symbol-value user-table)))
	  (if (equal (cdr vallist) (cdr key)) nil
		;; if association hits, but contents differ.
		(progn
		  (message
		   "~A's attributes turned into ~A" (car vallist) (cdr vallist))
		  (set user-table (delq key (symbol-value user-table)))
		  (set user-table (cons vallist (symbol-value user-table)))
		  (KaTeX-update-dictionary
		   KaTeX-user-completion-table user-table "user"))))
	 ((setq key (assoc car-v (symbol-value local-table)))
	  (if (equal (cdr vallist) (cdr key)) nil
		(progn
		  (message
		   "~A's attributes turned into ~A" (car vallist) (cdr vallist))
		  (set local-table (delq key (symbol-value local-table)))
		  (set local-table (cons vallist (symbol-value local-table)))
		  (set (KaTeX-local-table-symbol local-table) (symbol-value local-table))
		  (KaTeX-update-dictionary file local-table))))
	 ;; All of above cases, there are some completion in tables.
	 ;; Then update tables.
	 (t
	  (if (not KaTeX-nervous)
		  (setq answer "u")
		(progn
		  (message
		   (cond
			(KaTeX-japan
			 "`~A'‚Ì“o˜^æ: U)ƒ†[ƒUŽ«‘ L)ƒ[ƒJƒ‹Ž«‘ N)ƒƒ‚ƒŠ D)‚µ‚È‚¢")
			(t
			 "Register `~A' into: U)serDic L)ocalDic N)one D)iscard"))
		   (if (> (length car-v) 23)
			   (concat (substring car-v 0 10) "..." (substring car-v -9))
			 car-v))
		  (setq answer (char-to-string (read-char)))))
	  (cond
	   ((string-match answer "uy")
		(set user-table (cons vallist (symbol-value user-table)))
		(KaTeX-update-dictionary KaTeX-user-completion-table user-table "user")
	   )
	   ((string-match answer "tl")
		(set local-table (cons vallist (symbol-value local-table)))
		(set (KaTeX-local-table-symbol local-table) (symbol-value local-table))
		(KaTeX-update-dictionary file local-table))
	   ((string-match answer "d") nil)	;discard it
	   (t (set default-table
			   (cons vallist (symbol-value default-table)))))))))

;;;###autoload
(defun KaTeX-cplread-with-learning
  (prom default-table user-table local-table
		&optional pred reqmatch init hsym)
  "Completing read with learning.
Do a completing read with prompt PROM.  Completion table is what
DEFAULT-TABLE, USER-TABLE, LOCAL table are appended in reverse order.
Note that these tables are passed by the symbol.
Optional arguments PRED, REQMATH and INIT are passed to completing-read
as its arguments PREDICATE, REQUIRE-MATCH and INITIAL-INPUT respectively.
If optional 8th argument HSYM, history symbol, is passed, use it as
history list variable."
  (KaTeX-sync-local-table local-table)
  (let*((table (append (symbol-value local-table)
					   (symbol-value user-table)
					   (symbol-value default-table)))
		(word (completing-read-with-history
			   prom table pred reqmatch init hsym)))
	(if (and (string< "" word) (not (assoc word table)))
		(KaTeX-update-table (list word) default-table user-table local-table))
	word))

;;;###autoload
(defun KaTeX-update-dictionary (file symbol &optional type)
  (let ((local-table-buf (find-file-noselect file))
		(name (symbol-name symbol))
		(value (symbol-value symbol)))
    (save-excursion
      (message "Updating ~A dictionary..." (or type "local"))
      (set-buffer local-table-buf)
      (goto-char (point-max))
      (search-backward (concat "(setq elisp::" name) nil t)
      (delete-region (point) (progn (forward-sexp 1) (point)))
      (delete-blank-lines)
      (insert "(setq elisp::" name " '(\n")
      (mapcar '(lambda (s)
		 (insert (format nil "~A\n" (prin1-to-string s))))
	      value)
      (insert "))\n\n")
      (delete-blank-lines)
      (basic-save-buffer)
      (kill-buffer local-table-buf)
      (message "Updating ~A dictionary...Done" (or type "local")))))

;;;###autoload
(defun KaTeX-define-begend-key-normal (key env &optional map)
  "Define short cut KaTeX-make-begin-end key."
  (KaTeX-define-key
   key
   (list 'lambda '(arg) '(interactive "P")
	 (list 'KaTeX-insert-begin-end env 'arg))
   map))

;;;###autoload
(defun KaTeX-define-begend-region-key (key env &optional map)
  "Define short cut KaTeX-make-begin-end-region key."
  (KaTeX-define-key key (list 'lambda nil '(interactive)
			      (list 'KaTeX-insert-begin-end env t)) map))

;;;###autoload
(defun KaTeX-define-begend-key (key env &optional map)
  "Define short cut key for begin type completion both for normal
and region mode.  To customize KaTeX, user should use this function."
  (KaTeX-define-begend-key-normal key env map)
  (if KaTeX-inhibit-prefix-letter nil
    (KaTeX-define-begend-region-key
     (cons (char-upcase (car key)) (cdr key)) env)))
;m.m     (concat (upcase (substring key 0 1)) (substring key 1))

;;;###autoload
(defun KaTeX-search-active-forward (string cmntrx &optional bound err cnt func)
  "Search STRING which is not commented out by CMNTRX.
Optional arguments after BOUND, ERR, CNT are passed literally to search-forward
or search-backward.
Optional sixth argument FUNC changes search-function."
  (let ((sfunc (or func 'search-forward)) found md mb0 (count 0)) ;m.m
    (while (and (prog1
		    (setq found (funcall sfunc string bound err cnt))
		  (setq md (match-data))
		  (setq mb0 (match-beginning 0))) ;m.m
		(or
		 (and (eq buffer-mode 'katex-mode)
		      (setq temp (KaTeX-in-verb-p mb0))) ;m.m
		 (save-excursion
		   (beginning-of-line)
		   (setq temp (re-search-forward cmntrx mb0 t)) ;m.m
		 ))))
    (store-match-data md)
    found))

(defun KaTeX-re-search-active-forward (regexp cmntrx &optional bound err cnt)
  "Search REGEXP backward which is not commented out by regexp CMNTRX.
See also KaTeX-search-active-forward."
  (KaTeX-search-active-forward regexp cmntrx bound err cnt 're-search-forward))

(defun KaTeX-search-active-backward (string cmntrx &optional bound err cnt)
  "Search STRING backward which is not commented out by regexp CMNTRX.
See also KaTeX-search-active-forward."
  (KaTeX-search-active-forward string cmntrx bound err cnt 'search-backward))

(defun KaTeX-re-search-active-backward (regexp cmntrx &optional bound err cnt)
  "Search REGEXP backward which is not commented out by regexp CMNTRX.
See also KaTeX-search-active-forward."
  (KaTeX-search-active-forward
   regexp cmntrx bound err cnt 're-search-backward))

;;;###autoload
(defun KaTeX-switch-to-buffer (file &optional setbuf)
  "Switch to buffer if buffer exists, find file if not.
Optional second arg SETBUF t make use set-buffer instead of switch-to-buffer."
  (interactive "Fswitch to file: ")
  (if (bufferp file) (setq file (buffer-file-name file)))
  (let (buf (hilit-auto-highlight (not setbuf)))
    (cond
     ((setq buf (get-file-buffer file))
      (funcall (if setbuf 'set-buffer 'switch-to-buffer)
	       (get-file-buffer file))
      buf)
     ((or KaTeX-create-file-prefix-g (file-exists-p file))
      (or ;find-file returns nil but set current-buffer...
	  (if setbuf
	      (progn
		(set-buffer (find-file-noselect file))
		(get-file-buffer file)) ;m.m
	    (progn
	      (find-file file)
	      (get-file-buffer file)))  ;m.m
	(current-buffer)))
     (t (message "~A was not found in this directory." file)
	nil))))

;;;###autoload
(defun KaTeX-switch-to-buffer-other-window (file)
  "Switch to buffer if buffer exists, find file if not."
  (interactive "Fswitch to file: ")
  (if (bufferp file) (setq file (buffer-file-name file)))
  (cond
   ((get-file-buffer file)
    (switch-to-buffer-other-window (get-file-buffer file))
    t)
   ((or KaTeX-create-file-prefix-g (file-exists-p file))
    (find-file-other-window file) t)
   (t (message "~A was not found in this directory." file)
      nil)))

(defun KaTeX-replace-format-sub (string format repl)
  (let ((beg (or (string-match (concat "^\\(%" format "\\)") string)
		 (string-match (concat "[^%]\\(%" format "\\)") string)))
	(len (length format)))
    (if (null beg) string ;no conversion
      (concat
       (substring string 0 (match-beginning 1)) repl
       (substring string (match-end 1))))))

;;;###autoload
(defun KaTeX-replace-format (string format repl)
  "In STRING, replace first appearance of FORMAT to REPL as if
function `format' does.  FORMAT does not contain `%'"
  (let ((ans string))
    (while (not (string=
		 ans (setq string (KaTeX-replace-format-sub ans format repl))))
      (setq ans string))
    string))

;;;###autoload
(defun KaTeX-replace-format-args (string &rest args)
  "Translate the argument mark #1, #2, ... #n in the STRING into the
corresponding real arguments ARGS."
  (let ((argp 1))
    (while args
      (setq string
	    (KaTeX-replace-format string (int-to-string argp) (car args)))
      (setq args (cdr args) argp (1+ argp))))
  string)

;;;###autoload
(defun rindex (string char)
  (let ((pos (1- (length string)))(index -1))
    (while (>= pos 0)
      (cond
       ((= (aref string pos) char)
	(setq index pos) (setq pos -1))
       (t (setq pos (1- pos))))
      )
    index))

;;;###autoload
(defun point-beginning-of-line ()
  (save-excursion (beginning-of-line)(point)))

;;;###autoload
(defun point-end-of-line ()
  (save-excursion (end-of-line)(point)))


;;;###autoload
(defun KaTeX-showup-buffer (buffer &optional func select)
  "Make BUFFER show up in certain window (but current window)
that gives the maximum value by the FUNC.  FUNC should take an argument
of its window object.  Non-nil for optional third argument SELECT selects
that window.  This function never selects minibuffer window."
  (or (and (if (and KaTeX-emacs-19 select)
	       (get-buffer-window buffer t)
	     (get-buffer-window buffer))
	   (progn
	     (if select
		 (goto-buffer-window buffer)) ;‚±‚±‚ª•Ï
	     t))
      (let ((window (selected-window))
	    (wlist (KaTeX-window-list)) win w (x 0))
	(cond
	 ((> (length wlist) 2)
	  (if func
	      (while wlist
		(setq w (car wlist))
		(if (and (not (eq window w))
			 (> (funcall func w) x))
		    (setq win w x (funcall func w)))
		(setq wlist (cdr wlist)))
	    (setq win (get-lru-window)))
	  (select-window win)
	  (switch-to-buffer buffer)
	  (or select (select-window window)))
	 ((= (length wlist) 2)
	  ;(other-window 1);This does not work properly on Emacs-19
	  (select-window (get-lru-window))
	  (switch-to-buffer buffer)
	  (or select (select-window window)))
	 (t				;if one-window
					(cond
					 ;((and KaTeX-emacs-19 (get-buffer-window buffer t))
					   ; nil)			;if found in other frame
					 (KaTeX-default-pop-window-height
					  (split-window-calculate-height KaTeX-default-pop-window-height)
					  ;; (pop-to-buffer buffer)	;damn! emacs-19.30
					  (select-window (next-window nil 1))
					  (switch-to-buffer buffer)
					  (or select (select-window window)))
					 (t nil)))
	))))

(cond
; ((fboundp 'screen-height) ;m.m ->
;  (fset 'KaTeX-screen-height #'screen-height)
;  (fset 'KaTeX-screen-width #'screen-width))
 ((fboundp 'window-height)
  (fset 'KaTeX-screen-height #'window-height)
  (fset 'KaTeX-screen-width #'window-width)) ;m.m <-
 ((fboundp 'frame-height)
  (fset 'KaTeX-screen-height #'frame-height)
  (fset 'KaTeX-screen-width #'frame-width))
 (t (error "I don't know how to run windows.el on this Emacs...")))

;;;###autoload
(defun split-window-calculate-height (height)
  "Split current window wight specified HEIGHT.
If HEIGHT is number, make a new window that has HEIGHT lines.
If HEIGHT is string, make a new window that occupies HEIGT % of screen height.
Otherwise split window conventionally."
  (if (one-window-p t)
      (split-window
       (selected-window)
       (max
	(min
	 (- (KaTeX-screen-height)
	    (if (numberp height)
		(+ height 4)
	      (/ (* (KaTeX-screen-height)
		    (string-to-int height))
		 100)))
	 (- (KaTeX-screen-height) window-min-height 1))
	window-min-height))))

;;;###autoload
(defun KaTeX-window-list ()
  (let*((curw (selected-window)) (win curw) (wlist (list curw)))
    (while (not (eq curw (setq win (next-window win))))
      (or (eq win (minibuffer-window))
	  (setq wlist (cons win wlist))))
    wlist))

;;;###autoload
(defun substitute-all-key-definition (olddef newdef keymap)
  "Replace recursively OLDDEF with NEWDEF for any keys in KEYMAP now
defined as OLDDEF. In other words, OLDDEF is replaced with NEWDEF
where ever it appears."
  (if KaTeX-emacs-19
      (substitute-key-definition olddef newdef keymap *global-keymap*)
    (mapcar
     (function (lambda (key) (define-key keymap key newdef)))
     (where-is-internal olddef keymap))))

;;;###autoload
(defun KaTeX-match-string (n &optional m)
  "Return (buffer-substring (match-beginning n) (match-beginning m))."
  (if (match-beginning n)
      (buffer-substring (match-beginning n)
			(match-end (or m n)))))

;;;###autoload
(defun KaTeX-minibuffer-complete ()
  "Complete in minibuffer.
If the symbol 'delim is bound and is string, its value is assumed to be
the character class of delimiters.  Completion will be performed on
the last field separated by those delimiters.
If the symbol 'quick is bound and is 't, when the try-completion results
in t, exit minibuffer immediately."
  (interactive)
  (let ((md (match-data)) beg word compl
	(quick (and (boundp 'quick) (eq quick t)))
	(displist ;function to display completion-list
		  (function
		   (lambda (word)
		     (with-output-to-temp-buffer "*Completions*"
		       (display-completion-list
			(all-completions word minibuffer-completion-table)))))))
    (setq beg (if (and (boundp 'delim) (stringp delim))
		  (save-excursion
		    (skip-chars-backward (concat "^" delim))
		    (point))
		(point-min))
	  word (buffer-substring beg (point-max))
	  compl (try-completion word minibuffer-completion-table))
    (cond
     ((eq compl t)
      (if quick (exit-minibuffer)
	(let ((p (point)) (max (point-max)))
	  (unwind-protect
	      (progn
		(goto-char max)
		(insert " [Sole completion]")
		(goto-char p)
		(sit-for 1))
	    (delete-region max (point-max))
	    (goto-char p)))))
     ((eq compl nil)
      (ding)
      (save-excursion
	(let (p)
	  (unwind-protect
	      (progn
		(goto-char (setq p (point-max)))
		(insert " [No match]")
		(goto-char p)
		(sit-for 2))
	    (delete-region p (point-max))))))
     ((string= compl word)
      (funcall displist word))
     (t (delete-region beg (point-max))
	(insert compl)
	(if quick
	    (if (eq (try-completion compl minibuffer-completion-table) t)
		(exit-minibuffer)
	      (funcall displist word)))))
    (store-match-data md)))

(defun KaTeX-minibuffer-quick-complete ()
  "Set 'quick to 't and call KaTeX-minibuffer-complete.
See documentation of KaTeX-minibuffer-complete."
  (interactive)
  (let ((quick t))
    (self-insert-command 1)
    (KaTeX-minibuffer-complete)))

(defun foreach-buffers (pattern job)
  "For each buffer which matches with PATTERN, do JOB."
  (let ((list (buffer-list)))
    (save-excursion
      (while list
	(set-buffer (car list))
	(if (or (and (stringp pattern)
		     (buffer-file-name)
		     (string-match pattern (buffer-file-name)))
		(and (symbolp pattern) buffer-mode (eq buffer-mode pattern)))
	    (eval job))
	(setq list (cdr list))))))

(defun goto-buffer-window (buffer)
  "Select window which is bound to BUFFER.
If no such window exist, switch to buffer BUFFER."
  (interactive "BGoto buffer: ")
  (if (stringp buffer)
      (setq buffer (or (get-file-buffer buffer) (get-buffer buffer))))
  (if (get-buffer (buffer-name buffer))
      (cond
       ((get-buffer-window buffer)
	(select-window (get-buffer-window buffer)))
;       ((and KaTeX-emacs-19 (get-buffer-window buffer t)) ;m.m ->
;	(let*((win (get-buffer-window buffer t))
;	      (frame (window-frame win)))
;	  (select-frame frame)
;	  (raise-frame frame)
;	  (focus-frame frame)
;	  (select-window win)
;	  (set-mouse-position frame 0 0)
;;	  (and (featurep 'windows) (fboundp 'win:adjust-window)
;;	       (win:adjust-window))
;	)) ;m.m <-
;;       ((and (featurep 'windows) (fboundp 'win:get-buffer-window)
;;	     (let ((w (win:get-buffer-window buffer)))
;;	       (and w (win:switch-window w))))
;;	(select-window (get-buffer-window buffer)))
       (t (switch-to-buffer buffer)))))

;; Here starts the functions which support gmhist-vs-Emacs19 compatible
;; reading with history.
;;;###autoload
(defun completing-read-with-history
  (prompt table &optional predicate must-match initial hsym)
  "Completing read with general history."
  (let (result) ;m.m ->
	(setq result
		  (completing-read prompt table predicate must-match initial hsym))
	result) ;m.m <-
)

;;;###autoload
(defun read-from-minibuffer-with-history (prompt &optional init map read hsym)
  "Read from minibuffer with general history: gmhist, Emacs-19."
    (read-from-minibuffer prompt init map read hsym))

;;;###autoload
(defun read-string-with-history (prompt &optional init hsym)
  "Read string with history: gmhist(Emacs-18) and Emacs-19."
    (read-from-minibuffer prompt init minibuffer-local-map nil hsym))

;;;###autoload
(fset 'KaTeX-rassoc
      (if (and nil (fboundp 'rassoc) (subrp (symbol-function 'rassoc)))
	  (symbol-function 'rassoc)
	#'(lambda (key list)
	    (let ((l list))
	      (catch 'found
	        (while l
		  (if (equal key (cdr (car l)))
		      (throw 'found (car l)))
		  (setq l (cdr l))))))))
#| ;m.m
;;;
;; Interface function for windows.el
;;;
;;;###autoload
(defun KaTeX-switch-to-window ()
  "Switch to windows.el's window decided by last pressed key."
  (interactive)
  (or (featurep 'windows) (error "Why don't you use `windows.el'?"))
  (win-switch-to-window 1 (- *last-command-char* win:base-key)))
|# ;m.m
;;;###autoload
(defun KaTeX-reindent (col)
  "Remove current indentation and reindento to COL column."
  (save-excursion
    (beginning-of-line)
    (skip-chars-forward " \t")
    (if (/= col (current-column))
	(progn
	  (delete-region (point) (progn (beginning-of-line) (point)))
	  (indent-to col))))
  (skip-chars-forward " \t" (point-end-of-line)))

(defun KaTeX-inner-environment (&optional quick)
  "Return current inner-most environment.
Non-nil for optional argument QUICK restricts search bound to most
recent sectioning command.  Matching point is stored to property 'point
of 'KaTeX-inner-environment, which can be referred by
 (get 'KaTeX-inner-environment 'point)."
  (let*((nest 0)
	(beg (KaTeX-replace-format-args
	      (regexp-quote KaTeX-struct-begin)
	      ;KaTeX-struct-begin		;=== TENTATIVE!! ==
	      KaTeX-struct-name-regexp
	      (if (eq buffer-mode 'kahtml-mode) "\\s *.*" "")
	      ""))
	(end (KaTeX-replace-format-args
	      (regexp-quote KaTeX-struct-end)
	      KaTeX-struct-name-regexp "" ""))
	(begend (concat "\\(" beg "\\)\\|\\(" end "\\)"))
	bound m0
	(htmlp (eq buffer-mode 'kahtml-mode))
	(open
	 (concat "^" (or (cdr (assq buffer-mode '((kahtml-mode . "<")))) "{")))
	(close
	 (concat "^"
		 (or (cdr(assq buffer-mode '((kahtml-mode . "\n\t >")))) "}"))))
    (save-excursion
      (if quick
	  (setq bound
		(save-excursion
		  (if htmlp 
		      ;;(re-search-backward KaTeX-sectioning-regexp nil 1)
		      (goto-char (point-min)) ;Is this enough? 97/6/26
		    (KaTeX-re-search-active-backward
		     (concat KaTeX-ec-regexp
			     "\\(" KaTeX-sectioning-regexp "\\)\\*?{")
		     KaTeX-comment-prefix nil 1))
		  (or (bobp) (end-of-line))
		  (point))))
      (if (catch 'begin
	    (if (and (numberp bound) (< (point) bound)) (throw 'begin nil))
	    (while (KaTeX-re-search-active-backward
		    begend KaTeX-comment-prefix bound t)
	      (setq m0 (match-beginning 0))
	      (if (looking-at end) ;;(match-beginning 2)
		(setq nest (1+ nest))
		(setq nest (1- nest)))
	      (if (< nest 0)
		  (progn
		    (put 'KaTeX-inner-environment 'point m0)
		    (goto-char m0)
		    (put 'KaTeX-inner-environment 'indent (current-column))
		    (throw 'begin t)
		  ))))
	  (buffer-substring
	   (progn (skip-chars-forward open) (1+ (point)))
	   (progn (skip-chars-forward close) (point)))))))

(defun KaTeX-end-environment ()
  "Close opening environment"
  (interactive)
  (let ((env (KaTeX-inner-environment)))
	(if (not env) (error "No premature environment")
	  (progn
		(save-excursion
		  (if (KaTeX-search-active-forward
			   (KaTeX-replace-format-args KaTeX-struct-end env "" "")
			   KaTeX-comment-prefix nil t)
			  (unless (y-or-n-p
					   (concat "Environment `" env
							   "' may be already closed. Force close?"))
				(error "end environment aborted."))))
		(KaTeX-insert-struc 'end env)
		(save-excursion
		  (goto-char (or (get 'KaTeX-inner-environment 'point) (match-end 0)))
;;; m.m cut
		  (message "Matches with ~A at line ~D"
				   (KaTeX-replace-format-args KaTeX-struct-begin env "" "")
				   (count-lines (point-min) (point))))))))

;;;VER2
(defun KaTeX-insert-struc (what env)
  (cond
   ((eq what 'begin)
    (insert (KaTeX-replace-format-args
	     KaTeX-struct-begin env (KaTeX-addin env))))
   ((eq what 'end)
    (insert (KaTeX-replace-format-args KaTeX-struct-end env)))
   (t nil)))

;;; save history symbol : history.l‚æ‚è ;m.m ->
(defun KaTeX-save-history ()
  (ed::find-file-internal KaTeX-user-completion-table
			  :if-does-not-exist :create)
  (set-buffer (file-namestring KaTeX-user-completion-table))
  (goto-char (point-min))
  (while (scan-buffer "^(set-default" :regexp t)
    (kill-region (progn (beginning-of-line) (point))
		 (progn (forward-sexp 1) (point))))
  (delete-blank-lines)
  (goto-char (point-max))
  (mapcar #'(lambda (var)
	      (when (and (symbolp var)
			 (boundp var))
		(insert "(set-default 'elisp::" (symbol-name var) " '(\n")
		(mapcar '(lambda (s)
			  (insert (format nil "~A\n" (prin1-to-string s))))
			(default-value var))
		(insert "))\n\n")))
	  '(elisp::KaTeX-read-singlecmd-history
	    elisp::KaTeX-read-environment-history
	    elisp::KaTeX-read-section-history
	    elisp::KaTeX-read-fontsize-history
	    elisp::KaTeX-call-command-history
	    elisp::KaTeX-preview-command-history
	    elisp::KaTeX-preview-file-history
	    elisp::KaTeX-length-history))
  (save-buffer)
  (kill-buffer (selected-buffer))
)

(add-hook '*kill-xyzzy-hook* #'elisp::KaTeX-save-history)
;;;m.m <-

;;; Function for menu support
(defun KaTeX-define-menu (menu bindlist)
  "Define menu-bindings according to BINDLIST.
MENU should be a quoted symbol of newly allocated menu.
BINDLIST consists of binding list.  Each element is as follows.

'(menusymbol DOC_String . contents)

CONTENTS is one of lambda-form, interactive function, or other menu."
  (mapcar
   (function
    (lambda (bind)
      (add-menu-item menu (car bind) (cadr bind) (cddr bind))))
   bindlist)
)


