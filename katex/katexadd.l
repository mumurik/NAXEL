;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX add-in functions.
;;; katexadd.l rev.14.1.3
;;; fixed by Maeda Manabu
;;; Last fixed  "Fri Oct 04 2002 13:35:49 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX add-in functions.
;;; yatexadd.el rev.14
;;; (c ) 1991-1999 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Tue Jul 13 13:57:45 1999 on firestorm
;;; $Old-Id: yatexadd.el,v 1.67 1999/07/15 04:58:48 yuuji Rel $

(provide "katexadd")

(in-package "elisp")

;;;
;;Sample functions for LaTeX environment.
;;;
(defvar KaTeX-tabular-default-rule
  "@{\\vrule width 1pt\\ }c|c|c@{\\ \\vrule width 1pt}"
  "*Your favorite default rule format.")

(defvar KaTeX-tabular-thick-vrule "\\vrule width ~A"
  "*Vertical thick line format (without @{}). ~A'll be replaced by its width.")

(defvar KaTeX-tabular-thick-hrule "\\noalign{\\hrule height ~A}"
  "*Horizontal thick line format.  ~A will be replaced by its width.")

(defun KaTeX-tabular ()
  "KaTeX add-in function for tabular environment.
Notice that this function refers the let-variable `env' in
KaTeX-make-begin-end."
  (let ((width "") bars (rule "") (and "") (j 1) loc ans (hline "\\hline"))
    (if (string= env-name "tabular*")
	(setq width (concat "{" (read-string "Width: ") "}")))
    (setq loc (KaTeX-read-position "tb")
	  bars (string-to-int
		(read-string "Number of columns(0 for default format): " "3")))
    (if (<= bars 0)
	(setq				;if 0, simple format
	 rule KaTeX-tabular-default-rule
	 and "& &")
      (progn
	(while (< j bars)			;repeat bars-1 times
	  (setq rule (concat rule "c|")
	        and (concat and "& ")
	        j (1+ j)))
        (setq rule (concat rule "c"))
        (minibuffer-prompt "(N)ormal-frame or (T)hick frame? [nt]")
        (setq ans (read-char))
        (cond
         ((or (equal ans #\t) (equal ans #\T))
	  (setq ans (read-string "Rule width: " "1pt")
	        rule (concat
		      "@{" (format nil KaTeX-tabular-thick-vrule ans) "}"
		      rule
		      "@{\\ " (format nil KaTeX-tabular-thick-vrule ans) "}")
	        hline (format nil KaTeX-tabular-thick-hrule ans)))
         (t (setq rule (concat "|" rule "|")
		  hline "\\hline")))))

    (setq rule (read-string "rule format: " rule))
    (setq single-command "hline")

    (format nil "~A~A{~A}" width loc rule)))

(fset 'KaTeX-tabular* #'KaTeX-tabular)
(defun KaTeX-array ()
  (concat (KaTeX-read-position "tb")
	  "{" (read-string "Column format: ") "}"))

(defun KaTeX-read-oneof (oneof)
  (let ((pos "") loc (guide ""))
    (and (boundp 'name) name (setq guide (format nil "~A " name)))
    (while (not (string-match
		 (setq loc (read-key-sequence
			    (format nil "~A position (`~A') [~A]: "
				    guide oneof pos));name is in KaTeX-addin
;		       loc (if (fboundp 'events-to-keys)
;			       (events-to-keys loc) loc)
		 )
		 "\r\^g\n"))
      (cond
       ((string-match loc oneof)
	(if (not (string-match loc pos))
	    (setq pos (concat pos loc))))
       ((and (string-match loc "\C-h\C-?") (> (length pos) 0))
	(setq pos (substring pos 0 (1- (length pos)))))
       (t
	(ding)
	(message "Please input one of `~A'." oneof)
	(sit-for 3))))
    (message "")
    pos))

(defun KaTeX-read-position (oneof)
  "Read a LaTeX (optional) position format such as `[htbp]'."
  (let ((pos (KaTeX-read-oneof oneof)))
    (if (string= pos "")  "" (concat "[" pos "]"))))

(defun KaTeX-table ()
  "KaTeX add-in function for table environment."
  (setq env-name "tabular"
	section-name "caption")
  (KaTeX-read-position "htbp"))

(fset 'KaTeX-figure #'KaTeX-table)
(fset 'KaTeX-figure* #'KaTeX-table)


(defun KaTeX-description ()
  "Truly poor service:-)"
  (setq single-command "item[]")
  "")

(defun KaTeX-itemize ()
  "It's also poor service."
  (setq single-command "item")
  "")

(fset 'KaTeX-enumerate #'KaTeX-itemize)

(defun KaTeX-picture ()
  "Ask the size of coordinates of picture environment."
  (concat (KaTeX-read-coordinates "Picture size")
	  (KaTeX-read-coordinates "Initial position")))

(defun KaTeX-equation ()
  (KaTeX-jmode-off)
  (if (fboundp 'KaTeX-toggle-math-mode)
      (KaTeX-toggle-math-mode t)))		;force math-mode ON.

(mapcar '(lambda (f) (fset f #'KaTeX-equation))
	'(KaTeX-eqnarray KaTeX-eqnarray* KaTeX-align KaTeX-align*
	  KaTeX-split KaTeX-multline KaTeX-multline* KaTeX-gather KaTeX-gather*
	  KaTeX-aligned* KaTeX-gathered KaTeX-gathered*
	  KaTeX-alignat KaTeX-alignat* KaTeX-xalignat KaTeX-xalignat*
	  KaTeX-xxalignat KaTeX-xxalignat*))

(defun KaTeX-list ()
  "%\n{} %default label\n{} %formatting parameter")

(defun KaTeX-minipage ()
  (concat (KaTeX-read-position "cbt")
	  "{" (read-string "Width: ") "}"))

(defun KaTeX-thebibliography ()
  (setq section-name "bibitem")
  "")

;;;
;;Sample functions for section-type command.
;;;
(defun KaTeX-multiput ()
  (concat (KaTeX-read-coordinates "Pos")
	  (KaTeX-read-coordinates "Step")
	  "{" (read-string "How many times: ") "}"))

(defun KaTeX-put ()
  (KaTeX-read-coordinates "Pos"))

(defun KaTeX-makebox ()
  (cond
   ((KaTeX-in-environment-p "picture")
    (concat (KaTeX-read-coordinates "Dimension")
	    (KaTeX-read-position "lrtb")))
   (t
    (let ((width (read-string "Width: ")))
      (if (string< "" width)
	  (progn
	    (or (equal (aref width 0) #\[)
		(setq width (concat "[" width "]")))
	    (concat width (KaTeX-read-position "lr"))))))))

(defun KaTeX-framebox ()
  (if (KaTeX-quick-in-environment-p "picture")
      (KaTeX-makebox)))

(defun KaTeX-dashbox ()
  (concat "{" (read-string "Dash dimension: ") "}"
	  (KaTeX-read-coordinates "Dimension")))

(defvar KaTeX-minibuffer-quick-map nil)
(if KaTeX-minibuffer-quick-map nil
  (progn
    (setq KaTeX-minibuffer-quick-map
	(copy-keymap minibuffer-local-completion-map))
    (let ((ch (1+ #\SPC)))
      (while (< ch #\DEL) ;m.m (< ch 127)
        (define-key KaTeX-minibuffer-quick-map ch ;m.m (char-to-string ch)
	  'KaTeX-minibuffer-quick-complete)
	 (setq ch (1+ ch))))))

(defvar KaTeX-left-right-delimiters
   '(("(" . ")") (")" . "(") ("[" . "]") ("]" . "[")
     ("\\{" . "\\}") ("\\}" . "\\{") ("|") ("\\|")
     ("\\lfloor" . "\\rfloor") ("\\lceil" . "\\rceil")
     ("\\langle" . "\\rangle") ("/") (".")
     ("\\rfloor" . "\\rfloor") ("\\rceil" . "\\lceil")
     ("\\rangle" . "\\langle") ("\\backslash")
     ("\\uparrow") ("\\downarrow") ("\\updownarrow") ("\\Updownarrow"))
   "TeX math delimiter, which can be completed after \\right or \\left.")

(defvar KaTeX-left-right-default nil "Default string of KaTeX-right.")

(defun KaTeX-left ()
  (let (delimiter (leftp (string= single-command "left")))
	(setq minibuffer-completion-table KaTeX-left-right-delimiters)
	(setq delimiter
		  (read-from-minibuffer
		   (format nil "Delimiter~A: "
				   (if KaTeX-left-right-default
					   (format nil "(default=`~A')" KaTeX-left-right-default)
					 "(SPC for menu)"))
		   nil KaTeX-minibuffer-quick-map))
	(if (string= "" delimiter) (setq delimiter KaTeX-left-right-default))
	(setq single-command (if leftp "right" "left")
		  KaTeX-left-right-default
		  (or (cdr (assoc delimiter KaTeX-left-right-delimiters)) delimiter))
	delimiter))

(fset 'KaTeX-right #'KaTeX-left)


(defun KaTeX-read-coordinates (&optional mes varX varY)
  (concat
   "("
   (read-string (format nil "~A ~A: " (or mes "Dimension") (or varX "X")))
   ","
   (read-string (format nil "~A ~A: " (or mes "Dimension") (or varY "Y")))
   ")"))

;;;
;;Sample functions for maketitle-type command.
;;;
(defun KaTeX-sum ()
  "Read range of summation."
  (KaTeX-check-completion-type 'maketitle)
  (concat (KaTeX-read-boundary "_") (KaTeX-read-boundary "^")))

(fset 'KaTeX-int #'KaTeX-sum)

(defun KaTeX-lim ()
  "Insert limit notation of \\lim."
  (KaTeX-check-completion-type 'maketitle)
  (let ((var (read-string "Variable: ")) limit)
    (if (string= "" var) ""
      (progn
	(setq limit (read-string "Limit ($ means infinity): "))
        (if (string= "$" limit) (setq limit "\\infty"))
	(concat "_{" var " \\rightarrow " limit "}")))))

(defun KaTeX-gcd ()
  "Add-in function for \\gcd(m,n)."
  (KaTeX-check-completion-type 'maketitle)
  (KaTeX-read-coordinates "\\gcd" "(?,)" "(,?)"))

(defun KaTeX-read-boundary (ULchar)
  "Read boundary usage by _ or ^.  _ or ^ is indicated by argument ULchar."
  (let ((bndry (read-string (concat ULchar "{???} ($ for infinity): "))))
    (if (string= bndry "") ""
      (progn
	(if (string= bndry "$") (setq bndry "\\infty"))
	(concat ULchar "{" bndry "}")))))

(defun KaTeX-verb ()
  "Enclose \\verb's contents with the same characters."
  (let ((quote-char (read-string "Quoting char: " "|"))
	(contents (read-string "Quoted contents: ")))
    (concat quote-char contents quote-char)))

(fset 'KaTeX-verb* #'KaTeX-verb)

(defun KaTeX-footnotemark ()
  (setq section-name "footnotetext")
  nil)

(defun KaTeX-cite ()
  (let ((comment (read-string "Comment for citation: ")))
    (if (string= comment "") ""
      (concat "[" comment "]"))))

(defun KaTeX-bibitem ()
  (let ((label (read-string "Citation label for bibitem: ")))
    (if (string= label "") ""
      (concat "[" label "]"))))

(defun KaTeX-item ()
  (KaTeX-indent-line)
  (setq section-name "label")
  " ")
(fset 'KaTeX-item\[\] #'KaTeX-item)
(fset 'KaTeX-subitem #'KaTeX-item)
(fset 'KaTeX-subsubitem #'KaTeX-item)

(defun KaTeX-linebreak ()
  (let (obl)
    (message "Break strength 0,1,2,3,4 (default: 4): ")
    (setq obl (char-to-string (read-char)))
    (if (string-match "[0-4]" obl)
	(concat "[" obl "]")
      "")))
(fset 'KaTeX-pagebreak #'KaTeX-linebreak)

;;;
;;Subroutine
;;;

(defun KaTeX-check-completion-type (type)
  "Check valid completion type."
  (if (not (eq type KaTeX-current-completion-type))
      (error "This should be completed with ~A-type completion." type)))


;;;
;;;		[[Add-in functions for reading section arguments]]
;;;
;; All of add-in functions for reading sections arguments should
;; take an argument ARGP that specify the argument position.
;; If argument position is out of range, nil should be returned,
;; else nil should NOT be returned.

;;
; Label selection
;;
(defvar KaTeX-label-menu-other
  (if KaTeX-japan "':他のバッファのラベル\n" "':LABEL IN OTHER BUFFER.\n"))
(defvar KaTeX-label-menu-repeat
  (if KaTeX-japan ".:直前の\\refと同じ\n" "/:REPEAT LAST \ref{}\n"))
(defvar KaTeX-label-menu-any
  (if KaTeX-japan "*:任意の文字列\n" "*:ANY STRING.\n"))
(defvar KaTeX-label-buffer "*Label completions*")
(defvar KaTeX-label-guide-msg "Select label and hit RETURN.")
(defvar KaTeX-label-select-map nil
  "Key map used in label selection buffer.")
(defun KaTeX--label-setup-key-map ()
  (if KaTeX-label-select-map nil
    (progn
      (message "Setting up label selection mode map...")
      ;(setq KaTeX-label-select-map (copy-keymap *global-keymap*))
      (setq KaTeX-label-select-map (make-keymap))
      (suppress-keymap KaTeX-label-select-map)
      (substitute-all-key-definition
       'previous-line 'KaTeX--label-previous KaTeX-label-select-map)
      (substitute-all-key-definition
       'next-line 'KaTeX--label-next KaTeX-label-select-map)
      (define-key KaTeX-label-select-map #\C-n	'KaTeX--label-next)
      (define-key KaTeX-label-select-map #\C-p	'KaTeX--label-previous)
      (define-key KaTeX-label-select-map #\<	'beginning-of-buffer)
      (define-key KaTeX-label-select-map #\>	'end-of-buffer)
      (define-key KaTeX-label-select-map #\C-m	'exit-recursive-edit)
      (define-key KaTeX-label-select-map #\C-j	'exit-recursive-edit)
      (define-key KaTeX-label-select-map #\SPC	'exit-recursive-edit)
      (define-key KaTeX-label-select-map #\C-g	'abort-recursive-edit)
      (define-key KaTeX-label-select-map #\/	'isearch-forward)
      (define-key KaTeX-label-select-map #\?	'isearch-backward)
      (define-key KaTeX-label-select-map #\'	'KaTeX--label-search-tag)
      (define-key KaTeX-label-select-map #\.	'KaTeX--label-search-tag)
      (define-key KaTeX-label-select-map #\*	'KaTeX--label-search-tag)
      (message "Setting up label selection mode map...Done")
      (let ((key #\A))
        (while (<= key #\Z)
	  (define-key KaTeX-label-select-map key ;m.m (char-to-string key)
	    'KaTeX--label-search-tag)
	  (define-key KaTeX-label-select-map (char-downcase key)
	 		       ;m.m (char-to-string (char+ key (char- #\a #\A)))
	    'KaTeX--label-search-tag)
	  (setq key (1+ key)))))))

(defun KaTeX--label-next ()
  (interactive) (forward-line 1) (message KaTeX-label-guide-msg))
(defun KaTeX--label-previous ()
  (interactive) (forward-line -1) (message KaTeX-label-guide-msg))
(defun KaTeX--label-search-tag ()
  (interactive)
  (let ((case-fold-search t)
		(tag (regexp-quote (char-to-string *last-command-char*))))
    (cond
     ((save-excursion
	(forward-char 1)
	(re-search-forward (concat "^" tag) nil t))
      (goto-char (match-beginning 0)))
     ((save-excursion
	(goto-char (point-min))
	(re-search-forward (concat "^" tag) nil t))
      (goto-char (match-beginning 0))))
    (message KaTeX-label-guide-msg)))

(defun KaTeX--ref (argp &optional labelcmd refcmd)
  (cond
   ((= argp 1)
    (let ((lnum 0) e0 label label-list (buf (current-buffer))
		  (labelcmd (or labelcmd "label")) (refcmd (or refcmd "ref"))
		  (p (point)) initl line cf)
      (message "Collecting labels...")
      (save-window-excursion
	(KaTeX-showup-buffer
	 KaTeX-label-buffer (function (lambda (x) (window-width x))))
;	(if (fboundp 'select-frame) (setq cf (selected-frame))) ;m.m
	(if (eq (window-buffer (minibuffer-window)) buf)
	    (progn
	      (other-window 1)
	      (setq buf (current-buffer))
	      (set-buffer buf)
	      ;(message "cb=~A" buf)(sit-for 3)
	      ))
	(save-excursion
	  (set-buffer (get-buffer-create KaTeX-label-buffer))
	  (setq buffer-read-only nil)
	  (set-buffer-modified-p nil) ;m.m
	  (erase-buffer))
	(save-excursion
	  (goto-char (point-min))
	  (let ((*standard-output*
			 (make-buffer-stream (get-buffer KaTeX-label-buffer))))
	    (format t "=== LABELS in [~A] ===\n" (buffer-name buf))
	    (while (KaTeX-re-search-active-forward
		    (concat "\\\\" labelcmd "\\b")
		    (regexp-quote KaTeX-comment-prefix) nil t)
	      (goto-char (match-beginning 0))
	      (skip-chars-forward "^{")
	      (setq label
		    (buffer-substring
		     (1+ (point))
		     (prog2 (forward-list 1) (setq e0 (1- (point)))))
		    label-list (cons label label-list))
	      (or initl
		  (if (< p (point)) (setq initl lnum)))
	      (beginning-of-line)
	      (skip-chars-forward " \t\n" nil)
	      (format t "~C:{~A}\t<<~A>>\n"
			     (+ (code-char (% lnum 26)) #\A) label
			     (buffer-substring (point) (point-end-of-line)))
	      (setq lnum (1+ lnum))
	      (message "Collecting \\~A{}... ~D" labelcmd lnum)
	      (goto-char e0))
	    (princ KaTeX-label-menu-other)
	    (princ KaTeX-label-menu-repeat)
	    (princ KaTeX-label-menu-any)
	    );*standard-output*
	  (goto-char p)
	  (or initl (setq initl lnum))
	  (message "Collecting ~A...Done" labelcmd)
;	  (if (fboundp 'select-frame) (select-frame cf)) ;m.m
	  (KaTeX-showup-buffer KaTeX-label-buffer nil t)
	  (KaTeX--label-setup-key-map)
	  (setq truncate-lines t)
	  (set-buffer-modified-p nil) ;m.m
	  (setq buffer-read-only t)
	  (use-local-map KaTeX-label-select-map)
	  (message KaTeX-label-guide-msg)
	  (goto-line (1+ initl)) ;goto recently defined label line
	  (switch-to-buffer (current-buffer))
	  (unwind-protect
	      (progn
		(recursive-edit)
		(set-buffer (get-buffer KaTeX-label-buffer)) ;assertion
		(beginning-of-line)
		(setq line (1- (count-lines (point-min)(point))))
		(cond
		 ((= line -1)
		  (setq label ""))
		 ((= line lnum)
		  (setq label (KaTeX-label-other argp labelcmd refcmd)))
		 ((= line (1+ lnum))
		  (save-excursion
		    (switch-to-buffer buf)
		    (goto-char p)
		    (if (re-search-backward
			 (concat "\\\\" refcmd "{\\([^}]+\\)}") nil t)
			(setq label (KaTeX-match-string 1))
		      (setq label ""))))
		 ((>= line (+ lnum 2))
		  (setq label (read-string (format nil "\\~A{???}: " refcmd))))
		 (t (setq label (nth (- lnum line 1) label-list)))))
	    (bury-buffer KaTeX-label-buffer)))
	label)))))

(fset 'KaTeX--pageref #'KaTeX--ref)

(defun KaTeX--cite (argp)
  (cond
   ((eq argp 1)
    (KaTeX--ref argp "bibitem\\(\\[.*\\]\\)?" "cite"))
   (t nil)))

(defun KaTeX-katex-buffer-list ()
  (save-excursion
    (delq nil (mapcar (function (lambda (buf)
				  (set-buffer buf)
				  (if (ignore-errors
				       (eq buffer-mode 'katex-mode)) buf)))
		      (buffer-list)))))

(defun KaTeX-select-other-katex-buffer ()
  "Select buffer from all katex-mode's buffers interactivelly."
  (interactive)
  (let ((lbuf "*KaTeX mode buffers*") (blist (KaTeX-katex-buffer-list))
		(lnum -1) buf rv
		(ff "**find-file**"))
    (KaTeX-showup-buffer
     lbuf (function (lambda (x) 1)))	;;Select next window surely.
    (save-excursion
      (set-buffer (get-buffer lbuf))
      (setq buffer-read-only nil)
      (set-buffer-modified-p nil) ;m.m
      (erase-buffer))
    (let ((*standard-output* (make-buffer-stream (get-buffer lbuf))))
      (while blist
	(princ
	 (format nil "~C:{~A}\n" (+ (code-char (% (setq lnum (1+ lnum)) 26)) #\A)
;	 (format nil "~C:{~A}\n" (char+ (code-char (% (setq lnum (1+ lnum)) 26)) #\A)
		 (buffer-name (car blist))))
	(setq blist (cdr blist)))
      (princ (format nil "':{~A}" ff)))
    (KaTeX-showup-buffer lbuf nil t)
    (KaTeX--label-setup-key-map)
    (set-buffer-modified-p nil) ;m.m
    (setq buffer-read-only t)
    (use-local-map KaTeX-label-select-map)
    (message KaTeX-label-guide-msg)
    (unwind-protect
	(progn
	  (recursive-edit)
	  (set-buffer lbuf)
	  (beginning-of-line)
	  (setq rv
		(if (re-search-forward "{\\([^\\}]+\\)}" (point-end-of-line) t)
		    (buffer-substring (match-beginning 1) (match-end 1)) nil)))
      (kill-buffer lbuf))
    (if (string= rv ff)
	(progn
	  (call-interactively 'find-file)
	  (current-buffer))
      rv)))

(defun KaTeX-label-other (argp labelcmd refcmd)
  (let ((rv (KaTeX-select-other-katex-buffer)))
    (cond
     ((null rv) "")
     (t
      (set-buffer rv)
      (KaTeX--ref argp labelcmd refcmd)))))

;;
; completion for the arguments of \newcommand
;;
(defun KaTeX--newcommand (&optional argp)
  (cond
   ((= argp 1)
    (let ((command (read-string "Define newcommand: " "\\")))
      (put 'KaTeX--newcommand 'command (substring command 1))
      command))
   ((= argp 2)
    (let ((argc
		   (string-to-int (read-string "Number of arguments(Default 0): ")))
		  (def (read-string "Definition: "))
		  (command (get 'KaTeX--newcommand 'command)))
      ;;!!! It's illegal to insert string in the add-in function !!!
      (if (> argc 0) (insert (format nil "[~D]" argc)))
      (if (and (stringp command)
	       (string< "" command)
	       (y-or-n-p "Update dictionary?"))
	  (cond
	   ((= argc 0)
	    (KaTeX-update-table
	     (list command)
	     'singlecmd-table 'user-singlecmd-table 'tmp-singlecmd-table))
	   ((= argc 1)
	    (KaTeX-update-table
	     (list command)
	     'section-table 'user-section-table 'tmp-section-table))
	   (t (KaTeX-update-table
	       (list command argc)
	       'section-table 'user-section-table 'tmp-section-table))))
      (message "")
      def				;return command name
      ))
   (t "")))

;;
; completion for the arguments of \pagestyle
;;
(defun KaTeX--pagestyle (&optional argp)
  "Read the pagestyle with completion."
  (completing-read
   "Page style: "
   '(("plain") ("empty") ("headings") ("myheadings") ("normal") nil)))

(fset 'KaTeX--thispagestyle #'KaTeX--pagestyle)

;;
; completion for the arguments of \pagenumbering
;;
(defun KaTeX--pagenumbering (&optional argp)
  "Read the numbering style."
  (completing-read
   "Page numbering style: "
   '(("arabic") ("Alpha") ("alpha") ("Roman") ("roman"))))

;;
; Length
;;
(defvar KaTeX-style-parameters-default
  '(("\\arraycolsep")
    ("\\arrayrulewidth")
    ("\\baselineskip")
    ("\\columnsep")
    ("\\columnseprule")
    ("\\doublerulesep")
    ("\\evensidemargin")
    ("\\footheight")
    ("\\footskip")
    ("\\headheight")
    ("\\headsep")
    ("\\itemindent")
    ("\\itemsep")
    ("\\labelsep")
    ("\\labelwidth")
    ("\\leftmargin")
    ("\\linewidth")
    ("\\listparindent")
    ("\\marginparsep")
    ("\\marginparwidth")
    ("\\mathindent")
    ("\\oddsidemargin")
    ("\\parindent")
    ("\\parsep")
    ("\\parskip")
    ("\\partopsep")
    ("\\rightmargin")
    ("\\tabcolsep")
    ("\\textheight")
    ("\\textwidth")
    ("\\topmargin")
    ("\\topsep")
    ("\\topskip")
    )
  "Alist of LaTeX style parameters.")
(defvar KaTeX-style-parameters-private nil
  "*User definable alist of style parameters.")
(defvar KaTeX-style-parameters-local nil
  "*User definable alist of local style parameters.")

(defvar KaTeX-length-history nil "Holds history of length.")
(put 'KaTeX-length-history 'no-default t)
(defun KaTeX--setlength (&optional argp)
  "KaTeX add-in function for arguments of \\setlength."
  (cond
   ((equal 1 argp)
    ;;(completing-read "Length variable: " KaTeX-style-parameters nil nil "\\")
    (KaTeX-cplread-with-learning
     "Length variable: "
     'KaTeX-style-parameters-default
     'KaTeX-style-parameters-private
     'KaTeX-style-parameters-local
     nil nil "\\")
    )
   ((equal 2 argp)
    (read-string-with-history "Length: " nil 'KaTeX-length-history))))

(fset 'KaTeX--addtolength #'KaTeX--setlength)

(defun KaTeX--settowidth (&optional argp)
  "KaTeX add-in function for arguments of \\settowidth."
  (cond
   ((equal 1 argp)
    (KaTeX-cplread-with-learning
     "Length variable: "
     'KaTeX-style-parameters-default
     'KaTeX-style-parameters-private
     'KaTeX-style-parameters-local
     nil nil "\\"))
   ((equal 2 argp)
    (read-string "Text: "))))

(defun KaTeX--newlength (&optional argp)
  "KaTeX add-in function for arguments of \\newlength"
  (cond
   ((equal argp 1)
    (let ((length (read-string "Length variable: " "\\")))
      (if (string< "" length)
	  (KaTeX-update-table
	   (list length)
	   'KaTeX-style-parameters-default
	   'KaTeX-style-parameters-private
	   'KaTeX-style-parameters-local))
      length))))

;; \multicolumn's arguments
(defun KaTeX--multicolumn (&optional argp)
  "KaTeX add-in function for arguments of \\multicolumn."
  (cond
   ((equal 1 argp)
    (read-string "Number of columns: "))
   ((equal 2 argp)
    (let (c)
      (while (not (string-match
		   (progn (message "Format(one of l,r,c): ")
			  (setq c (char-to-string (read-char))))
		   "lrc")))
      c))
   ((equal 3 argp)
    (read-string "Item: "))))

(defvar KaTeX-documentstyles-default
  '(("article") ("jarticle") ("j-article")
    ("book") ("jbook") ("j-book")
    ("report") ("jreport") ("j-report")
    ("letter") ("ascjletter"))
  "List of LaTeX documentstyles.")
(defvar KaTeX-documentstyles-private nil
  "*User defined list of LaTeX documentstyles.")
(defvar KaTeX-documentstyles-local nil
  "*User defined list of local LaTeX documentstyles.")
(defvar KaTeX-documentstyle-options-default
  '(("a4j") ("a5j") ("b4j") ("b5j")
    ("twocolumn") ("jtwocolumn") ("epsf") ("epsfig") ("epsbox") ("nfig"))
  "List of LaTeX documentstyle options.")
(defvar KaTeX-documentstyle-options-private nil
  "*User defined list of LaTeX documentstyle options.")
(defvar KaTeX-documentstyle-options-local nil
  "List of LaTeX local documentstyle options.")

(defvar KaTeX-minibuffer-completion-map nil
  "Minibuffer completion key map that allows comma completion.")
(if KaTeX-minibuffer-completion-map nil
  (progn
	(setq KaTeX-minibuffer-completion-map
		  (copy-keymap minibuffer-local-completion-map))
	(define-key KaTeX-minibuffer-completion-map #\SPC
				'KaTeX-minibuffer-complete)
	(define-key KaTeX-minibuffer-completion-map #\TAB
				'KaTeX-minibuffer-complete)))

(defun KaTeX-documentstyle ()
  (let*((delim ",")
		(dt (append KaTeX-documentstyle-options-local
					KaTeX-documentstyle-options-private
					KaTeX-documentstyle-options-default)) o)
	(setq minibuffer-completion-table dt)
	(setq opt (read-from-minibuffer
			   "Style options ([opt1,opt2,...]): "
			   nil KaTeX-minibuffer-completion-map nil))
	(setq substr opt)
	(if (string< "" opt)
	(progn
	  (while substr
	    (setq o (substring substr 0 (string-match delim substr)))
	    (or (assoc o dt)
		(KaTeX-update-table
		 (list o)
		 'KaTeX-documentstyle-options-default
		 'KaTeX-documentstyle-options-private
		 'KaTeX-documentstyle-options-local))
	    (setq substr
		  (if (string-match delim substr)
		      (substring substr (1+ (string-match delim substr))))))
	  (concat "[" opt "]"))
      "")))

(defun KaTeX--documentstyle (&optional argp)
  "KaTeX add-in function for arguments of \\documentstyle."
  (cond
   ((equal argp 1)
    (setq env-name "document")
    (let ((sname
		   (KaTeX-cplread-with-learning
			(format nil "Documentstyle (default ~A): "
					KaTeX-default-document-style)
			'KaTeX-documentstyles-default
			'KaTeX-documentstyles-private
			'KaTeX-documentstyles-local)))
      (if (string= "" sname) (setq sname KaTeX-default-document-style))
      (setq KaTeX-default-document-style sname)))))

;;; -------------------- LaTeX2e stuff --------------------
(defvar KaTeX-documentclass-options-default
  '(("a4paper") ("a5paper") ("b5paper") ("10pt") ("11pt") ("12pt")
    ("latterpaper") ("legalpaper") ("executivepaper") ("landscape")
    ("oneside") ("twoside") ("draft") ("final") ("leqno") ("fleqn") ("openbib")
    ("clock")				;for slides class only
    )
    "Default options list for documentclass")
(defvar KaTeX-documentclass-options-private nil
  "*User defined options list for documentclass")
(defvar KaTeX-documentclass-options-local nil
  "*User defined options list for local documentclass")

(defun KaTeX-documentclass ()
  (let*((delim ",")
		(dt (append KaTeX-documentclass-options-local
					KaTeX-documentclass-options-private
					KaTeX-documentclass-options-default))
		o)
	(setq minibuffer-completion-table dt)
	(setq opt (read-from-minibuffer
			   "Documentclass options ([opt1,opt2,...]): "
			   nil KaTeX-minibuffer-completion-map nil))
	(setq substr opt)
	(if (string< "" opt)
		(progn
		  (while substr
			(setq o (substring substr 0 (string-match delim substr)))
			(or (assoc o dt)
				(KaTeX-update-table
				 (list o)
				 'KaTeX-documentclass-options-default
				 'KaTeX-documentclass-options-private
				 'KaTeX-documentclass-options-local))
			(setq substr
				  (if (string-match delim substr)
					  (substring substr (1+ (string-match delim substr))))))
		  (concat "[" opt "]"))
	  "")))

(defvar KaTeX-documentclasses-default
  '(("article") ("jarticle") ("report") ("jreport") ("book") ("jbook")
    ("j-article") ("j-report") ("j-book")
    ("letter") ("slides") ("ltxdoc") ("ltxguide") ("ltnews") ("proc"))
  "Default documentclass alist")
(defvar KaTeX-documentclasses-private nil
  "*User defined documentclass alist")
(defvar KaTeX-documentclasses-local nil
  "*User defined local documentclass alist")
(defvar KaTeX-default-documentclass (if KaTeX-japan "jarticle" "article")
  "*Default documentclass")

(defun KaTeX--documentclass (&optional argp)
  (cond
   ((equal argp 1)
    (setq env-name "document")
    (let ((sname
	   (KaTeX-cplread-with-learning
	    (format nil "Documentclass (default ~A): " KaTeX-default-documentclass)
	    'KaTeX-documentclasses-default
	    'KaTeX-documentclasses-private
	    'KaTeX-documentclasses-local)))
      (if (string= "" sname) (setq sname KaTeX-default-documentclass))
      (setq KaTeX-default-documentclass sname)))))

(defun KaTeX-caption ()
  (setq section-name "label")
  nil)

;;; -------------------- math-mode stuff --------------------
(defun KaTeX--tilde (&optional pos)
  "For accent macros in mathmode"
  (cond
   ((equal pos 1)
    (message "Put accent on variable: ")
    (let ((v (char-to-string (read-char))) (case-fold-search nil))
      (message "")
      (cond
       ((string-match "i\\|j" v)
	(concat "\\" v "math"))
       ((string-match "[\r\n\t ]" v)
	"")
       (t v))))
   (nil "")))

(fset 'KaTeX--hat	#'KaTeX--tilde)
(fset 'KaTeX--check	#'KaTeX--tilde)
(fset 'KaTeX--bar	#'KaTeX--tilde)
(fset 'KaTeX--dot	#'KaTeX--tilde)
(fset 'KaTeX--ddot	#'KaTeX--tilde)
(fset 'KaTeX--vec	#'KaTeX--tilde)

(defun KaTeX--widetilde (&optional pos)
  "For multichar accent macros in mathmode"
  (cond
   ((equal pos 1)
    (let ((m "Put over chars[~A ]: ") v v2)
      (message m " ")
      (setq v (char-to-string (read-char)))
      (message "")
      (if (string-match "[\r\n\t ]" v)
	  ""
	(progn
	  (message m v)
	  (setq v2 (char-to-string (read-char)))
	  (message "")
	  (if (string-match "[\r\n\t ]" v2)
	      v
	    (concat v v2))))))
   (nil "")))

(fset 'KaTeX--widehat		#'KaTeX--widetilde)
(fset 'KaTeX--overline		#'KaTeX--widetilde)
(fset 'KaTeX--overrightarrow	#'KaTeX--widetilde)
	

;;;
;; Add-in functions for large-type command.
;;;
(defun KaTeX-em ()
  (cond
   ((eq KaTeX-current-completion-type 'large) "\\/")
   (t nil)))
(fset 'KaTeX-it #'KaTeX-em)

;;; -------------------- End of katexadd --------------------
