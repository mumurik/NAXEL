;;; -*- Lisp; syntax: Common-Lisp -*-
;;; comment/uncomment region for emacs.
;;; comment.l, v 1.67.1.0
;;; fixed by Maeda Manabu
;;; Last fixed  "Sun May 20 2001 00:10:19 +0900"

;;; -*- Emacs-Lisp -*-
;;; comment/uncomment region for emacs.
;;; comment.el rev.0.1
;;; (c )1991-1999 by HIROSE Yuuji.[yuuji@gentei.org]
;;; Last modified Sat Nov 19 23:58:40 1994 on figaro

;;; Rename `comment-region' to `comment-out-region' for standard
;;; Emacs-19 function.

(provide "comment")

(in-package "elisp")

(defvar current-comment-prefix "> " "*Default prefix string")

(defun cite-region (string beg end)
  (save-excursion
    (goto-char (max beg end))
    (if (bolp)
	(forward-line -1))
    (if (string= string "") (setq string current-comment-prefix)
      (setq current-comment-prefix string))
    (save-restriction
      (narrow-to-region (min beg end) (point))
      (goto-char (point-min))
      (message "~A" string)
      (perform-replace "^" string nil t nil nil) ;m.m
    ))
)

(defun comment-out-region (string &optional beg end once)
  "Inserts STRING at the beginning of every line in the region specified
BEG and END.
Called interactively, STRING defaults to comment-start (or '> ' if
none is defined) unless a prefix argument is given, in which case it
prompts for a string.  Optional second argument ONCE is only for
compatibility for uncomment-region.  It has no means now."
  (interactive
      (list (if current-prefix-arg
		(read-string
		 (concat "String to insert"
			 (format nil "(default \"~A\")" current-comment-prefix
				 " ")
			 ": "))
	      current-comment-prefix)))
  (if (not (stringp string)) (setq string current-comment-prefix))
  (cite-region string (or beg (region-beginning)) (or end (region-end)))
)


(defun uncomment-region (string &optional beg end once)
  "Deletes STRING from the beginning of every line in the region.
Called interactively, STRING defaults to comment-start (or '> ' if
none is defined) unless a prefix argument is given, in which case it
prompts for a string.  Optional second argument ONCE restricts
deletion to first occurance of STRING on each line."
  (interactive
      (list (if current-prefix-arg
		(read-string
		 (concat "String to delete"
			 (format nil "(default \"~A\")" current-comment-prefix
				 " ")
			 ": "))
	      current-comment-prefix)))
  (if (not (stringp string)) (setq string current-comment-prefix))
  (save-excursion
    (save-restriction
      (narrow-to-region (or beg (region-beginning)) (or end (region-end)))
      (goto-char (point-min))
      (while (re-search-forward (concat "^" string) nil t)
	(replace-match "")
	(if once (end-of-line)))
    ))
)

(defun cite-file (filename)
  "insert the file with citation string."
  (interactive "FCite-file: ")
  (let*
      ((string
	(read-string
	 (format nil "Citation string (default \"~A\"): " current-comment-prefix)
	))
       (ins-tail (car (cdr (insert-file-contents filename)))))
    (save-excursion
      (cite-region string (point) (+ (point) ins-tail))))
)
