;;; -*- Lisp; syntax: Common-Lisp -*-
;;; KaTeX environment-specific functions.
;;; katexenv.l, v 1.66.1.2
;;; fixed by Maeda Manabu
;;; Last fixed  "Sat May 05 2001 12:52:24 +0900"

;;; -*- Emacs-Lisp -*-
;;; YaTeX environment-specific functions.
;;; yatexenv.el
;;; (c ) 1994-1997 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Wed Jan 14 16:44:36 1998 on firestorm
;;; $Old-Id: yatexenv.el,v 1.66 1998/10/26 12:05:53 yuuji Rel $

;;;
;; Functions for tabular environment
;;;

(provide "katexenv")

(in-package "elisp")

;; Showing the matching column of tabular environment.
(defun KaTeX-array-what-column ()
  "Show matching columne title of array environment.
When calling from a program, make sure to be in array/tabular environment."
  (let ((p (point)) beg eot bor (nlptn "\\\\\\\\") (andptn "[^\\]&")
		(n 0) j
		(firsterr "This line might be the first row."))
    (save-excursion
      (KaTeX-beginning-of-environment)
      (search-forward "{" p) (up-list 1)
      (search-forward "{" p) (up-list 1)
      ;;(re-search-forward andptn p)
      (while (progn (search-forward "&" p)
		    (equal (char-after (1- (match-beginning 0))) #\\ )))
      (setq beg (1- (point)))		;beg is the point of the first &
      (or (re-search-forward nlptn p t)
	  (error firsterr))
      (setq eot (point))		;eot is the point of the first \\
      (goto-char p)
      (or (re-search-backward nlptn beg t)
	  (error firsterr))
      (setq bor (point))		;bor is the beginning of this row.
      (while (< (1- (point)) p)
	(if (equal (following-char) #\&)
	    (forward-char 1)
	  (re-search-forward andptn nil 1))
	(setq n (1+ n)))		;Check current column number
      (goto-char p)
      (cond				;Start searching \multicolumn{N}
       ((> n 1)
	(re-search-backward andptn)	;Sure to find!
	(while (re-search-backward "\\\\multicolumn{\\([0-9]+\\)}" bor t)
	  (setq n (+ n (string-to-int
			(buffer-substring (match-beginning 1)
					  (match-end 1)))
		     -1)))))
      (message "~A" n)
      (goto-char (1- beg))
      (beginning-of-line)
      (setq j n)
      (while (> j 1)
	(or (re-search-forward andptn p nil)
	    (error "This column exceeds the limit."))
	(setq j (1- j)))
      (skip-chars-forward "\\s ")
      (message
       "This is the column(#~D) of: ~A" n
       (buffer-substring
	(point)
	(progn
	  (re-search-forward (concat andptn "\\|" nlptn) eot)
	  (goto-char (match-beginning 0))
	  (if (looking-at andptn)
	      (forward-char 1))
	  (skip-chars-backward "\\s ")
	  (point))))))
)

;;;###autoload
(defun KaTeX-what-column ()
  "Show which kind of column the current position is belonging to."
  (interactive)
  (cond
   ((KaTeX-quick-in-environment-p '("tabular" "tabular*" "array" "array*"))
    (KaTeX-array-what-column))
   (t (message "Not in array/tabular environment.")))
)

(defun KaTeX-tabular-parse-format (&optional tabular*)
  "Parse `tabular' format.
Return the list of (No.ofCols PointEndofFormat)"
  (let ((p (point)) elt boform eoform (cols 0))
    (save-excursion
      (if (null (KaTeX-beginning-of-environment t))
	  (error "Beginning of tabular not found."))
      (skip-chars-forward "^{")
      (forward-list 1)
      (if tabular*
	  (progn (skip-chars-forward "^{")
		 (forward-list 1)))
      (skip-chars-forward "^{" p)
      (if (/= (following-char) #\{) (error "Tabular format not found."))
;      (if (char/= (following-char) #\{) (error "Tabular format not found."))
      (setq boform (1+ (point))
	    eoform (progn (forward-list 1) (1- (point))))
      (if (> eoform p) (error "Non-terminated tabular format."))
      (goto-char boform)
      (while (< (point) eoform)
	(setq elt (following-char))
	(cond
	 ((string-match (char-to-string elt) "clr") ;normal indicators.
	  (setq cols (1+ cols))
	  (forward-char 1))
	 ((equal elt #\|)		;vertical
	  (forward-char 1))
	 ((string-match (char-to-string elt) "p@") ;p or @ expression
	  (setq cols (+ (if (eq elt #\p) 1 0) cols))
	  (skip-chars-forward "^{" p)
	  (forward-list 1))
	 (t (forward-char 1))		;unknown char
	 ))
      (list cols (1+ eoform))))
)
;; Insert &
(defun KaTeX-intelligent-newline-tabular (&optional tabular*)
  "Parse current tabular format and insert that many `&'s."
  (let*((p (point)) (format (KaTeX-tabular-parse-format tabular*))
	(cols (car format)) (beg (car (cdr format)))
	space hline)
    (cond
     ((search-backward "&" beg t)
      (goto-char p)
      (setq hline (search-backward "\\hline" beg t))
      (setq space (if (search-backward "\t&" beg t) "\t" " "))
      (goto-char p))
     (t ;;(insert "\\hline\n")
	(setq space " ")))
    (goto-char p)
    (while (> (1- cols) 0)
      (insert "&" space)
      (setq cols (1- cols)))
    (insert "\\\\")
    (if hline (insert " \\hline"))
    (goto-char p)
    (KaTeX-indent-line)
)
) 

(defun KaTeX-intelligent-newline-tabular* ()
  "Parse current tabular* format and insert that many `&'s."
  (KaTeX-intelligent-newline-tabular t)
)

(fset 'KaTeX-intelligent-newline-array #'KaTeX-intelligent-newline-tabular)

;;;
;; Functions for tabbing environment
;;;
(defun KaTeX-intelligent-newline-tabbing ()
  "Check the number of \\= in the first line and insert that many \\>."
  (let ((p (point)) begenv tabcount)
    (save-excursion
      (KaTeX-beginning-of-environment)
      (setq begenv (point-end-of-line))
      (if (KaTeX-search-active-forward "\\\\" KaTeX-comment-prefix p t)
	  (progn
	    (setq tabcount 0)
	    (while (> (point) begenv)
	      (if (search-backward "\\=" begenv 1)
		  (setq tabcount (1+ tabcount)))))))
    (KaTeX-indent-line)
    (if tabcount
	(progn
	  (save-excursion
	    (while (> tabcount 0)
	      (insert "\\>\t")
	      (setq tabcount (1- tabcount))))
	  (forward-char 2))
      (progn
	(insert "\\= \\\\")
	(forward-char -5))))
)

;;;
;; Functions for itemize/enumerate/list environments
;;;

(defun KaTeX-intelligent-newline-itemize ()
  "Insert '\\item '."
  (insert "\\item ")
  (KaTeX-indent-line)
)
(fset 'KaTeX-intelligent-newline-enumerate #'KaTeX-intelligent-newline-itemize)
(fset 'KaTeX-intelligent-newline-list #'KaTeX-intelligent-newline-itemize)

(defun KaTeX-intelligent-newline-description ()
  (insert "\\item[] ")
  (forward-char -2)
  (KaTeX-indent-line)
)

(defun KaTeX-intelligent-newline-thebibliography ()
  "Insert '\\bibitem '."
  (KaTeX-indent-line)
  (KaTeX-make-section nil nil nil "bibitem")
  (KaTeX-indent-line)
)

;;;
;; Intelligent newline
;;;
;;;###autoload
(defun KaTeX-intelligent-newline (arg)
  "Insert newline and environment-specific entry.
`\\item'	for some itemizing environment,
`\\> \\> \\'	for tabbing environemnt,
`& & \\ \hline'	for tabular environment."
  (interactive "P")
  (let*(env func)
    (end-of-line)
    (if arg (setq env (KaTeX-read-environment "For what environment? "))
      (setq env (KaTeX-inner-environment)))
    (setq func (intern-soft (concat "KaTeX-intelligent-newline-" env)))
    (end-of-line)
    (newline)
    (undo-boundary)
    (if (and env func (fboundp func))
	(funcall func)))
)

;;;
;; Environment-specific line indenting functions
;;;
;;;###autoload
(defun KaTeX-indent-line-equation ()
  "Indent a line in equation family."
  (let ((p (point)) (l-r 0) right-p peol depth (mp KaTeX-environment-indent))
    (if (save-excursion
	  (beginning-of-line)
	  (skip-chars-forward " \t")
	  (looking-at "\\\\right\\b"))
	(progn (KaTeX-reindent
		(save-excursion (KaTeX-goto-corresponding-leftright)
				(1- (current-column)))))
      (progn
	(save-excursion
	  (forward-line -1)
	  (while (and (not (bobp)) (KaTeX-on-comment-p))
	    (forward-line -1))
	  ;;(beginning-of-line)	;must be unnecessary
	  (skip-chars-forward " \t")
	  (if (eolp) (error "Math-environment can't have a null line!!"))
	  (setq depth (current-column)
	        peol (point-end-of-line))
	  (while (re-search-forward
		  "\\\\\\(\\(left\\)\\|\\(right\\)\\)\\b" peol t)
	    (setq l-r (+ l-r (if (match-beginning 2) 1 -1))))
	  (cond
	   ((progn (beginning-of-line)
		   (re-search-forward "\\\\\\\\\\s *$" (point-end-of-line) t))
	    ;;If previous line has `\\', this indentation is always normal.
	    (setq depth (+ (KaTeX-current-indentation) mp)))
	   ((> l-r 0)
	    (beginning-of-line)
	    (search-forward "\\left" peol nil l-r)
	    (goto-char (1+ (match-beginning 0)))
	    (setq depth (current-column)))
	   ((< l-r 0)
	    (goto-char (match-beginning 0))	;should be \right
	    (KaTeX-goto-corresponding-leftright)
	    (beginning-of-line)
	    (skip-chars-forward " \t")
	    ;(setq depth (+ (current-column) mp)) ;+mp is good?
	    (setq depth (current-column)))
	   (t				;if \left - \right = 0
	    (cond
	     ((re-search-forward "\\\\\\\\\\s *$" peol t)
	      (setq depth (+ (KaTeX-current-indentation) mp)))
	     ((re-search-forward "\\\\end{" peol t)
	      nil)			;same indentation as previous line's
	     ((re-search-forward "\\\\begin{" peol t)
	      (setq depth (+ depth mp)))
	     (t
	      (or (bobp) (forward-line -1))
	      (cond
	       ((re-search-forward
	         "\\\\\\\\\\s *$\\|\\\\begin{" (point-end-of-line) t)
	        (setq depth (+ depth mp)))
	       )))))
	  (goto-char p))
	(KaTeX-reindent depth)))))

;;;###autoload
(defun KaTeX-goto-corresponding-leftright ()
  "Go to corresponding \left or \right.
Note that this function assumes the corresponding \left\right
is on another line."
  (setq KaTeX-struct-begin "\\left%1")
  (setq KaTeX-struct-end "\\right%1")
  (setq KaTeX-struct-name-regexp "[][(){}.|]")
  (KaTeX-goto-corresponding-environment t))

;;;
;; Functions for formatting region being enclosed with environment
;;;
; These functions must take two argument; region-beginning, region-end.

(defun KaTeX-enclose-equation (beg end)
  (goto-char beg)
  (save-restriction
    (let (m0 bsl)
      (narrow-to-region beg end)
      (while (KaTeX-re-search-active-forward
	      "\\(\\$\\)" KaTeX-comment-prefix nil t)
	(goto-char (setq m0 (match-beginning 0)))
	(setq bsl 0)
	(if (and (not (bobp)) (= (char-after (1- (point))) #\\ ))
;	(if (and (not (bobp)) (char= (char-after (1- (point))) #\\ ))
	    (while (progn (forward-char -1) (= (char-after (point)) #\\ ))
;	    (while (progn (forward-char -1) (char= (char-after (point)) #\\ ))
	      (setq bsl (1+ bsl))))
	(goto-char m0)
	(if (= 0 (% bsl 2))
	    (delete-char 1)
	  (forward-char 1))))))

(fset 'KaTeX-enclose-eqnarray #'KaTeX-enclose-equation)
(fset 'KaTeX-enclose-eqnarray* #'KaTeX-enclose-equation)

(defun KaTeX-enclose-verbatim (beg end)) ;do nothing when enclose verbatim
(fset 'KaTeX-enclose-verbatim* #'KaTeX-enclose-verbatim)
