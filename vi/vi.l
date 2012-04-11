;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;;  Copyright (c) 2012 mumurik765
;;;
#|
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
|#
;;;
;;; This file is for vi-mode.
;;;

(provide "vi-mode")
(in-package "editor")
(export '(vi-mode vi-toggle-mode vi-quit-mode *vi-mode-map* *vi-insesrt-mode-map*))

;;;for debug
(setq *vi-insert-mode-map* nil)
(setq *vi-mode-map* nil)

;;; custormize layer
(defun my-backward-word()
  (my-forward-word -1))

(defun looking-back-regexp(regexp)
  (eq (point)
      (save-excursion
	(re-search-backward regexp t)
	(match-end 0))))

(defun my-find-file (filename &optional encoding nomsg)
  (interactive "lMy Find file: \n0zEncoding: " :title0 "Find file")
  (find-file filename encoding nomsg)
  (vi-mode))

(defun my-jump-tag (&optional other-window)
  (interactive)
  (jump-tag other-window)
  (vi-mode))


(defun skip-non-word(unit)
  (if (>= unit 0)
    (while (and (not (syntax-word-p (char-after (point))))
		(forward-char 1)))
    (while (and (not (syntax-word-p (char-before (point))))
		(forward-char -1)))))      

(defun my-forward-word(&optional (arg 1))
  (let* ((flag t)
	(unit (if (> arg 0)
		  1
		-1))
	(abs (* arg unit)))
    (if (if (>= unit 0)
	    (syntax-word-p (char-after (point)))
	  (syntax-word-p (char-before (point))))
	(forward-word arg)
      (skip-non-word unit))))

(defun my-copy-region-as-kill(from to)
  (interactive "r")
  (copy-region-as-kill from to)
  (copy-region-to-clipboard from to))

(defun my-kill-region(from to)
  (interactive "r")
  (copy-region-to-clipboard from to)
  (kill-region from to))

;*last-command-char*


;;; vi-dy
(defun vi-dy-each-line (action movefunc)
  (setq *vi-last-yank* 'line)  
  (let (start end linenum)
    (save-excursion
      (beginning-of-line)
      (setq start (point))
      (funcall movefunc)
      (setq end (point)))
    (vi-kill-or-yank-line action (get-linenum-from-region start end))))


(defun myforward-line(&optional (arg 1))
  (if (eq (point) (point-max))
      nil
    (if (forward-line arg)
	0
      (end-of-line))))

(defun get-linenum-from-region(in_start in_end)
  (save-excursion
    (let ((continue t) (linenum 0) sign start end)
      (if (<= in_start in_end)
	  (setq sign 1 start in_start end in_end)
	(setq sign -1 start in_end end in_start))
      (goto-char start)
      (if (eobp)
	  (error "end of buffer"))
      (while (and continue (<= (point) end))
	(setq linenum (1+ linenum))
	(unless (myforward-line)
	  (setq continue nil)))
      (if (> sign 0)
	  linenum
	(* sign (- linenum 1))))))

(defvar *vi-last-yank* 'substring)

(defun vi-dy-each-substring(action move-func plus-p)
  (setq *vi-last-yank* 'substring)
  (save-excursion
    (let ((beg (point))
	  (end
	   (progn
	     (funcall move-func)
	     (point))))
      (if (> beg end)
	  (rotatef beg end))
      (if plus-p
	  (incf end))
      (funcall action beg end))))



(defun vi-dy-each(action arg)
  (cond ((eq (car arg) 'line)
	 (vi-dy-each-line action (cadr arg)))
	((eq (car arg) 'substring)
	 (vi-dy-each-substring action (cadr arg) nil))
	((eq (car arg) 'substring-plus)
	 (vi-dy-each-substring action (cadr arg) t))
	(t
	 (error "why here?"))))

(defun vi-c()
  (interactive)
  (vi-dy 'my-kill-region)
  (goto-insert-state))

(defun vi-d()
  (interactive)
  (vi-dy 'my-kill-region))

(defun vi-y()
  (interactive)
  (vi-dy 'my-copy-region-as-kill))

(defun vi-dy(action)
  (interactive)
  (let (max
	res)
    (if (null *vi-num*)
	(setq max 1)
      (setq max *vi-num*))
    (setq *vi-num nil)
    (setq res (vi-dy-row))
    (do ((c 1 (1+ c)))
	((> c max))
      (vi-dy-each action res))
    (setq *vi-num* nil)))

(defun do-nothing())
(defun vi-dy-row ()
  "return the list '(type movefunc).
type is ether 'line' or 'relative'"
  (interactive)
  (let (c (res nil))
    (defun handle-char-and-continue(c)
      (cond
       ((eq c #\d)
	(setq res '(line do-nothing)))
       ((eq c #\y)
	(setq res '(line do-nothing)))
       ((eq c #\j)
	(setq res '(line vi-j)))
       ((eq c #\k)
	(setq res '(line vi-k)))
       ((eq c #\G)
	(setq res '(line vi-G)))
       ((eq c #\')
	(setq res '(line vi-quote)))       
       ((eq c #\w)
	(setq res '(substring vi-w)))
       ((eq c #\$)
	(setq res '(substring vi-dollar2)))
       ((eq c #\^)
	(setq res '(substring vi-hat)))
       ((eq c #\l)
	(setq res '(substring vi-l2)))
       ((eq c #\h)
	(setq res '(substring vi-h)))
       ((eq c #\f)
	(setq res '(substring-plus vi-f)))
       ((eq c #\F)
	(setq res '(substring-plus vi-F)))
       ((eq c #\%)
	(setq res '(substring-plus vi-percent)))
       ((eq c #\ESC)
	(throw 'vi-dy-exit t))
       ((char-to-num c)
	(append-vi-num (char-to-num c))
	(setq res nil))))
    (while t
      (setq c (read-char *keyboard*))
      (handle-char-and-continue c)
      (if res
	  (progn
	    (goto-normal-state)
	    (return res))))))

(defun vi-J-row()
  (end-of-line)
  (unless (eobp)
    (delete-char)
    (insert " ")
    (backward-char)))

(defun vi-Cwj()
  (interactive)
  (let ((max
	 (if (null *vi-num*)
	     (setq max 1)
	   (setq max *vi-num*))))
    (setq *vi-num* nil)
    (other-window max)))

(defun vi-Cwk()
  (interactive)
  (let ((max
	 (if (null *vi-num*)
	     (setq max 1)
	   (setq max *vi-num*))))
    (setq *vi-num* nil)    
    (other-window (* -1 max))))
    

(defmacro vi-create-handler(name funcname)
  `(defun ,name ()
     (interactive)
	 (let (max)
	   (if (null *vi-num*)
	       (setq max 1)
	     (setq max *vi-num*))
	   (do ((count 1 (1+ count)))
	       ((> count max))
	     (,funcname)))
     (setq *vi-num* nil)))

(defun vi-forward-char()
  (interactive)
  (unless (or (eolp) (save-excursion (forward-char 1) (eolp)))
    (forward-char)))

(defun vi-backward-char()
  (interactive)
  (if (not (bolp))
      (forward-char -1)))

(vi-create-handler vi-J vi-J-row)
(vi-create-handler vi-h vi-backward-char)
(vi-create-handler vi-j next-virtual-line)
(vi-create-handler vi-k previous-virtual-line)
(vi-create-handler vi-l vi-forward-char)
(vi-create-handler vi-l2 forward-char)
(vi-create-handler vi-Cf next-page)
(vi-create-handler vi-Cb previous-page)
(vi-create-handler vi-w my-forward-word)
(vi-create-handler vi-b my-backward-word)
(vi-create-handler vi-u undo)
(vi-create-handler vi-p vi-p-row)
(vi-create-handler vi-P vi-P-row)
(vi-create-handler vi-semicolon vi-semicolon-row)
(vi-create-handler vi-esc vi-esc-row)
(vi-create-handler vi-x delete-char)
(vi-create-handler vi-tab vi-tab-row)
(vi-create-handler vi-Cr redo)

(defvar *vi-mode-map* nil)
(unless *vi-mode-map*
  (setq *vi-mode-map* (make-keymap))
  (define-key *vi-mode-map* #\h 'vi-h)
  (define-key *vi-mode-map* #\j 'vi-j)
  (define-key *vi-mode-map* #\J 'vi-J)  
  (define-key *vi-mode-map* #\k 'vi-k)
  (define-key *vi-mode-map* #\l 'vi-l)
  (define-key *vi-mode-map* #\C-f 'vi-Cf)
  (define-key *vi-mode-map* #\C-b 'vi-Cb)
  (define-key *vi-mode-map* #\w 'vi-w)
  (define-key *vi-mode-map* #\b 'vi-b)
  (define-key *vi-mode-map* #\u 'vi-u)
  (define-key *vi-mode-map* #\d 'vi-d)
  (define-key *vi-mode-map* #\y 'vi-y)
  (define-key *vi-mode-map* #\m 'vi-m)
  (define-key *vi-mode-map* #\' 'vi-quote)
  (define-key *vi-mode-map* #\c 'vi-c)  
  (define-key *vi-mode-map* #\p 'vi-p)
  (define-key *vi-mode-map* #\P 'vi-P)
  (define-key *vi-mode-map* #\$ 'vi-dollar)
  (define-key *vi-mode-map* #\^ 'vi-hat)
  (define-key *vi-mode-map* #\* 'vi-aster)
  (define-key *vi-mode-map* #\# 'vi-sharp)
  (define-key *vi-mode-map* #\n 'vi-n)
  (define-key *vi-mode-map* #\N 'vi-N)
  (define-key *vi-mode-map* #\/ 'vi-slash)
  (define-key *vi-mode-map* #\? 'vi-question)
  (define-key *vi-mode-map* #\% 'vi-percent)
  (define-key *vi-mode-map* #\f 'vi-f)
  (define-key *vi-mode-map* #\F 'vi-F)
  (define-key *vi-mode-map* #\C-] 'my-jump-tag)
  (define-key *vi-mode-map* #\C-t 'back-tag-jump)  
  (define-key *vi-mode-map* #\; 'vi-semicolon)
  (define-key *vi-mode-map* #\G 'vi-G)
  (define-key *vi-mode-map* #\o 'vi-o)
  (define-key *vi-mode-map* #\O 'vi-O)
  (define-key *vi-mode-map* #\x 'vi-x)
  (define-key *vi-mode-map* #\r 'vi-r)
  (define-key *vi-mode-map* #\C-r 'vi-Cr)
  (define-key *vi-mode-map* '(#\C-w #\k) 'vi-Cwk)
  (define-key *vi-mode-map* '(#\C-w #\j) 'vi-Cwj)
  (define-key *vi-mode-map* '(#\C-x #\C-f) 'my-find-file)  
  (define-key *vi-mode-map* '(#\C-w #\o) 'delete-other-windows) ; just for nigligence (*vi-num*)
  (define-key *vi-mode-map* '(#\C-w #\c) 'delete-window) ; just for nigligence (*vi-num*)  
  (define-key *vi-mode-map* #\0 'num-handler)
  (define-key *vi-mode-map* #\1 'num-handler)
  (define-key *vi-mode-map* #\2 'num-handler)
  (define-key *vi-mode-map* #\3 'num-handler)
  (define-key *vi-mode-map* #\4 'num-handler)
  (define-key *vi-mode-map* #\5 'num-handler)
  (define-key *vi-mode-map* #\6 'num-handler)
  (define-key *vi-mode-map* #\7 'num-handler)
  (define-key *vi-mode-map* #\8 'num-handler)
  (define-key *vi-mode-map* #\9 'num-handler)
  (define-key *vi-mode-map* #\ESC 'vi-esc)
  (define-key *vi-mode-map* #\TAB 'vi-tab)
  (define-key *vi-mode-map* #\: 'vi-ex)
  (define-key *vi-mode-map* #\a 'vi-a)  
  (define-key *vi-mode-map* #\i 'goto-insert-state))


(defun char-to-num(arg)
  (cond ((eq arg #\0) 0)
	((eq arg #\1) 1)
	((eq arg #\2) 2)
	((eq arg #\3) 3)
	((eq arg #\4) 4)
	((eq arg #\5) 5)
	((eq arg #\6) 6)
	((eq arg #\7) 7)
	((eq arg #\8) 8)
	((eq arg #\9) 9)
	(t nil)))

(defun append-vi-num(arg)
  (if (null *vi-num*)
      (setq *vi-num* arg)
    (setq *vi-num* (+ (* *vi-num* 10) arg))))

(defvar *vi-num* nil)
(defun num-handler()
  (interactive)
  (let ((cur (char-to-num *last-command-char*)))
    (if (eq nil cur)
	(error "not number"))
    (append-vi-num cur)))


(defun goto-normal-state-with-backward-char()
  (interactive)
  (goto-normal-state)
  (unless (bolp)
    (backward-char)))


(require "dabbrev")


(defvar *vi-insert-mode-map* nil)
(unless *vi-insert-mode-map*
  (setq *vi-insert-mode-map* (make-keymap))
  (define-key *vi-insert-mode-map* #\C-p 'dabbrev-expand)
  (define-key *vi-insert-mode-map* #\C-n 'dabbrev-expand)
  (define-key *vi-insert-mode-map* #\ESC 'goto-normal-state-with-backward-char))

(defvar *vi-state* 'normal
  "vi state. the value is one of normal, insert. I think we don't need command-mode")

(defvar *vi-mode* nil)

(defun vi-toggle-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*vi-mode* arg sv)
  (update-mode-line t)
  (set-syntax-word (syntax-table) #\_)
  (if *vi-mode*
      (set-minor-mode-map *vi-mode-map*)
    (if (eq *vi-state* 'normal)
	(unset-minor-mode-map *vi-mode-map*)
      (unset-minor-mode-map *vi-insert-mode-map*)))
  t)

(defun vi-quit-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*vi-mode* nil t)
  (update-mode-line t)
  (unless *vi-mode*
    (if (eq *vi-state* 'normal)
	(unset-minor-mode-map *vi-mode-map*)
      (unset-minor-mode-map *vi-insert-mode-map*)))
  t)

(defun vi-mode ()
  (interactive "p")
  (vi-toggle-mode t))

  


(defun goto-normal-state ()
  (interactive)
  (setq *vi-state* 'normal)
  (unset-minor-mode-map *vi-insert-mode-map*)
  (set-minor-mode-map *vi-mode-map*))

(defun goto-insert-state ()
  (interactive)  
  (setq *vi-state* 'insert)
  (unset-minor-mode-map *vi-mode-map*)
  (set-minor-mode-map *vi-insert-mode-map*))




;; normal mode

(defun vi-dollar()
  (interactive)
  (setq *vi-num* nil)
  (end-of-line)
  (unless (bolp)
    (forward-char -1)))

(defun vi-dollar2()
  (interactive)
  (setq *vi-num* nil)
  (end-of-line))

(defun vi-hat()
  (interactive)
  (setq *vi-num* nil)
  (beginning-of-line))


(defun vi-p-row-line()
  (save-excursion
    (myforward-line)
    (if (eobp)
	(newline))
    (yank)))

(defun vi-p-row-substring()
  (forward-char)
  (yank)
  (backward-char))
  
(defun vi-p-row ()
  (interactive)
  (if (eq *vi-last-yank* 'substring)
      (vi-p-row-substring)
    (vi-p-row-line)))

(defun vi-P-row-line()
  (save-excursion
    (beginning-of-line)
    (yank)))

(defun vi-P-row-substring()
  (yank)
  (backward-char))

(defun vi-P-row ()
  (interactive)
  (if (eq *vi-last-yank* 'substring)
      (vi-P-row-substring)
    (vi-P-row-line)))

(defun current-line-region()
  (save-excursion
    (values
     (progn (beginning-of-line) (point))
     (progn (end-of-line) (point)))))


(defvar *vi-f-char* nil)
(defvar *vi-f-direction* nil)

(defun scan-buffer-region-x (pattern nodup reverse begin end regp)
  (let ((prev-point (point)))
    (scan-buffer pattern
		 :regexp regp
		 :nodup nodup
		 :reverse reverse
		 :case-fold *case-fold-search*
		 :left-bound *word-search*
		 :right-bound *word-search*)
    (if (or (< (match-beginning 0) begin)
	    (> (match-end 0) end))
	(progn
	  (goto-char prev-point)
	  nil)
      t)))

(defun scan-buffer-region (pattern nodup reverse begin end )
  (scan-buffer-region-x pattern nodup reverse begin end t))

(defun scan-buffer-noreg-region (pattern nodup reverse begin end )
  (scan-buffer-region-x pattern nodup reverse begin end nil))



(defun vi-fF-common-search(rightorder-p)
  (let ((dir (if rightorder-p
		 *vi-f-direction*
	       (upsidedown-direction *vi-f-direction*))))
    (if (eq dir 'backward)
	(progn
	  (forward-char -1)
	  (multiple-value-bind(beg end)
	      (current-line-region)
	    (scan-buffer-noreg-region *vi-f-char* t t beg
				end)))
      (progn
	(forward-char 1)
	  (multiple-value-bind(beg end)
	      (current-line-region)
	    (scan-buffer-noreg-region *vi-f-char* t nil beg
				end))))))

(defun vi-fF-prepare()
  (interactive)
  (let ((c (read-char *keyboard*)))
    (cond
     ((eq c #\ESC)
      t)
     (t
      (setq *vi-f-char* (string c))))))


(defun vi-f-prepare()
  (interactive)
  (setq *vi-f-direction* 'forward)
  (vi-fF-prepare))


(defun vi-F-prepare()
  (interactive)
  (setq *vi-f-direction* 'backward)
  (vi-fF-prepare))

(defun vi-semicolon-row()
  (interactive)
  (vi-fF-common-search t))

(defun vi-f()
  (interactive)
  (vi-fF nil))

(defun vi-F()
  (interactive)
  (vi-fF t))

(defun vi-fF(isF-p)
  (if isF-p
      (vi-F-prepare)
    (vi-f-prepare))
  (let (max)
    (setq max
	  (if (null *vi-num*)
	      1
	    *vi-num*))
    (do ((count 1 (1+ count)))
	((> count max))
      (vi-fF-common-search t))
    (setq *vi-num* nil)))

(defun vi-G()
  (interactive)
  (if (null *vi-num*)
      (end-of-buffer)
    (goto-line *vi-num*))
  (setq *vi-num* nil))

(defun vi-a()
  (interactive)
  (setq *vi-num* nil)
  (unless (eolp)
    (forward-char))
  (goto-insert-state))

(defun vi-o()
  (interactive)
  (setq *vi-num* nil)
  (end-of-line)
  (newline)
  (goto-insert-state))

(defun vi-O()
  (interactive)
  (setq *vi-num* nil)
  (beginning-of-line)
  (newline)
  (forward-line -1)
  (goto-insert-state))


(defun vi-r()
  (interactive)
  (setq *vi-num* nil)
  (setq c (read-char *keyboard*))
  (if (eq c #\ESC)
      t
    (progn
      (delete-char)
      (insert (string c)))))

  
(defun vi-percent()
  (interactive)
  (setq *vi-num* nil)
  (goto-matched-parenthesis))

(defun vi-tab-row()
  (interactive)
  (funcall mode-specific-indent-command))

(defun get-word-region()
  (values (progn (my-forward-word 1) (point))
	  (progn (my-forward-word -1) (point))))

(defun get-word()
  (multiple-value-bind(beg end)
      (get-word-region)
    (buffer-substring beg end)))
		    

(defun vi-word-select()
  (multiple-value-bind(beg end)
      (get-word-region)
    (when beg
      (or (> beg end)
	  (rotatef beg end))
      (goto-char end)
      (start-selection 2 t)
      (goto-char beg))
    (valuse beg end)))

(defvar *vi-last-search-rexp* nil)
(defvar *vi-last-search-direction* nil)
(defvar *vi-last-search-match* nil)

(defun upsidedown-direction(dir)
  (if (eq dir 'forward)
      'backward
    'forward))


(defun vi-search-wrap (rightorder-p)
  "This function is called from vi-search-common.
Check if we should wrap or not and execute the wrap"
  (setq *vi-search-common-depth* 1)
  (if (eq 'forward (if rightorder-p
		       *vi-last-search-direction*
		     (upsidedown-direction *vi-last-search-direction*)))
      (goto-char 0)
    (goto-char (buffer-size)))
  (message "wrap")
  (vi-search-common rightorder-p)
  (unless *vi-last-search-match*
    (ding)
    (message "no such word")
    (goto-char  *vi-search-common-start*)))

(defun vi-search-common (rightorder-p)
  (let ((cur_point (point)) (before-match *vi-last-search-match*) (dir (if rightorder-p
						       *vi-last-search-direction*
						     (upsidedown-direction *vi-last-search-direction*))))
    (setq *vi-last-search-match*
	  (if (eq dir 'backward)
	      (progn
		(my-forward-word -1)
		(re-search-backward *vi-last-search-rexp* t))
	    (progn
	      (my-forward-word 1)
	      (re-search-forward *vi-last-search-rexp* t))))
    (when *vi-last-search-match*
      (goto-char (match-end 0))
      (start-selection 2 t)
      (goto-char (match-beginning 0)))
    (unless *vi-last-search-match*
      (if (eq *vi-search-common-depth* 0)
	  (vi-search-wrap rightorder-p)
	(progn
	  (message "そんな文字無いよ")
	  (goto-char *vi-search-common-start*))))))

(defvar *vi-search-common-depth* 0)
(defvar *vi-search-common-start* 0)

(defun vi-aster ()
  (interactive)
  (setq *vi-search-common-start* (point))
  (setq *vi-last-search-rexp* (format nil "\\<~A\\>" (get-word)))
  (setq *vi-last-search-match* nil)
  (setq *vi-last-search-direction* 'forward)
  (setq *vi-search-common-depth* 0)
  (vi-search-common t))

(defun vi-sharp ()
  (interactive)
  (setq *vi-search-common-start* (point))
  (setq *vi-last-search-rexp* (format nil "\\<~A\\>" (get-word)))
  (setq *vi-last-search-direction* 'backward)
  (setq *vi-search-common-depth* 0)
  (vi-search-common t))

(defun vi-add-search-rexp(ch)
  (unless (graphic-char-p ch)
    (unread-char ch *keyboard*)
    (throw 'vi-slash-exit t))
  (setq *vi-last-search-rexp*
	(concat *vi-last-search-rexp* (string ch))))


(defun vi-isearch(string no-dup)
  (unless (setq *vi-last-search-match*
	(scan-buffer string
		     :reverse (if (eq *vi-last-search-direction* 'backward)
				  t)
		     :nodup no-dup
		     :case-fold *case-fold-search*))
    (ding)))

(defvar *vi-isearch-map* nil)
(unless *vi-isearch-map*
  (setq *vi-isearch-map* (make-sparse-keymap))
  (define-key *vi-isearch-map* #\C-h 'vi-isearch-delete-char)
  (define-key *vi-isearch-map* #\ESC 'vi-isearch-exit-proc)
  (define-key *vi-isearch-map* #\RET 'vi-isearch-return))

(defun vi-isearch-exit-proc()
  (goto-char *vi-search-start-pos*)
  (throw 'vi-isearch-exit t))

(defun vi-isearch-delete-char()
  (let ((l (length *vi-last-search-rexp*)))
    (if (zerop l)
	(ding)
      (setq *vi-last-search-rexp* (subseq *vi-last-search-rexp* 0 (- l 1)))))
  nil)
(defun vi-isearch-return()
  t)

(defun vi-isearch-common()
  (stop-selection)
  (let ((with-return nil)
	search-success)
    (unwind-protect
	(catch 'vi-isearch-exit
	  (setq with-return 
		(loop
		  (minibuffer-prompt "~:[~;/~]~:[~;?~]~a"
				     (eq *vi-last-search-direction* 'forward)
				     (eq *vi-last-search-direction* 'backward)
				     *vi-last-search-rexp*)
		  (let ((ch (read-char *keyboard*))
			com)
		    (setq com (lookup-keymap *vi-isearch-map* ch t))
		    (if com
			(if (funcall com)
			    (return t))
		      (progn
			(vi-add-search-rexp ch)
			(vi-isearch *vi-last-search-rexp* nil)
			(if *vi-last-search-match*
			    (progn
			      (goto-char (match-end 0))
			      (start-selection 2 t)
			      (goto-char (match-beginning 0)))
			  (stop-selection))
			(refresh-screen)))))))
      (unless with-return
	(stop-selection)))))


(defun vi-slash ()
  (interactive)
  (setq *vi-last-search-rexp* "")
  (setq *vi-last-search-direction* 'forward)
  (setq *vi-last-search-match* t)
  (setq *vi-search-start-pos* (point))
  (vi-isearch-common))

(defun vi-question ()
  (interactive)
  (setq *vi-last-search-rexp* "")
  (setq *vi-last-search-direction* 'backward)
  (setq *vi-last-search-match* t)
  (setq *vi-search-start-pos* (point))
  (vi-isearch-common))


(defun vi-n()
  (interactive)
  (setq *vi-search-common-depth* 0)
  (setq *vi-search-common-start* (point))
  (vi-search-common t))

(defun vi-N()
  (interactive)
  (setq *vi-search-common-depth* 0)
  (setq *vi-search-common-start* (point))
  (vi-search-common nil))

(setq *vi-mark-table* (make-hash-table :test #'equal))
(defun vi-m()
  (interactive)
  (setq c (read-char *keyboard*))
  (cond
   ((eq c #\ESC)
    t)
   ((graphic-char-p c)
    (setf (gethash (string c) *vi-mark-table*) (current-line-number)))
   (t t)))

(defun vi-quote()
  (interactive)
  (setq c (read-char *keyboard*))
  (cond
   ((eq c #\ESC)
    t)
   ((graphic-char-p c)
    (if (gethash (string c) *vi-mark-table*)
	(goto-line (gethash (string c) *vi-mark-table*))))
   (t t)))


;;; ex related
(defvar *vi-ex-token-begin* 0)
(defvar *vi-ex-token-end* 0)
(defvar *vi-ex-token-type* 'undefine)
(defvar *vi-ex-current-buffer* nil)

(defun vi-ex-prepare-parse(command)
  (setq *vi-ex-current-buffer* (selected-buffer))
  (set-buffer (get-buffer-create "*vi-ex-command-buffer*"))
  (make-local-variable 'need-not-save)
  (setq need-not-save t)
  (make-local-variable 'auto-save)
  (setq auto-save nil)
  (end-of-buffer)
  (insert command)
  (newline)
  (previous-line)
  (beginning-of-line)
  (setq *vi-ex-token-begin* (point))
  (setq *vi-ex-token-end* (point))
  (setq *vi-ex-token-type* 'unefine))

(defun endof-linepoint()
  (save-excursion
    (end-of-line)
    (point)))


(defun vi-ex-lex()
  (let (str line-end)
    (goto-char *vi-ex-token-begin*)
    (setq line-end (endof-linepoint))
    (setq *vi-ex-token-begin* *vi-ex-token-end*)
    (if (>= *vi-ex-token-begin* line-end)
	nil
      (progn
	(setq str (buffer-substring *vi-ex-token-begin* line-end))
	(cond
	 ((string-match "^[0-9]+" str)
	  (setq *vi-ex-token-type* 'number)
	  (setq *vi-ex-token-end* (+ *vi-ex-token-begin* (match-end 0))))
	 ((string-match "^%" str)
	  (setq *vi-ex-token-type* 'percent)
	  (setq *vi-ex-token-end* (+ *vi-ex-token-begin* (match-end 0))))
	 ((string-match "^ +" str)
	   (setq *vi-ex-token-type* 'white-space)
	   (setq *vi-ex-token-end* (+ *vi-ex-token-begin* (match-end 0))))
	  ((string-match "^," str)
	   (setq *vi-ex-token-type* 'comma)
	   (setq *vi-ex-token-end* (+ *vi-ex-token-begin* (match-end 0))))
	 ((string-match "^.+" str)
	  (setq *vi-ex-token-type* 'string)
	  (setq *vi-ex-token-end* (+ *vi-ex-token-begin* (match-end 0))))
	  (t
	   nil))))))

(defun string-to-num(string)
  (let (s)
    (with-input-from-string (s string)
      (read s))))

(defun get-current-token()
  (buffer-substring  *vi-ex-token-begin*
		     *vi-ex-token-end*))

(defun vi-ex-parse-region()
  "Return the list of (type-region begin end)
Begin and end is line-number. type-region is symbol.
Current buffer is *vi-ex-command-buffer*."
  (let ((begin-num (string-to-num (get-current-token)))
	end-num)
    (unless (and (vi-ex-lex)
		 (eq *vi-ex-token-type* 'comma))	 
      (error "invalid format (in vi-ex-parse-region)"))
    (unless (and (vi-ex-lex)
		 (eq *vi-ex-token-type* 'number))
      (error "invalid format2 (in vi-ex-parse-region)"))
    (setq end-num (string-to-num (get-current-token)))
    (list 'type-region begin-num end-num)))


(defvar *vi-ex-target-region* nil)

(defun vi-ex-target-begin()
  (let ((target-type (car *vi-ex-target-region*)))
    (cond
     ((eq target-type 'type-region)
      (cadr *vi-ex-target-region*))
     ((eq target-type 'type-current-line)
      (current-line-number))
     ((eq target-type 'type-percent)
      1)
     (t
      (error "unknown target type")))))


(defun vi-ex-target-end()
  (let ((target-type (car *vi-ex-target-region*)))
    (cond
     ((eq target-type 'type-region)
      (caddr *vi-ex-target-region*))
     ((eq target-type 'type-current-line)
      (current-line-number))
     ((eq target-type 'type-percent)
      (buffer-lines))
     (t
      (error "unknown target type")))))



(defun vi-ex-set-target-region(region)
"set target-region of ex-command.
The argument region is '(type-region begin-num end-num) or '(type-region"
  (setq *vi-ex-target-region* region))

(defun vi-ex-sp(&rest arg)
  (split-window))

(defun vi-ex-bufexplorer(&rest arg)
  (select-buffer))


(defvar *vi-ex-s-token-begin* nil)
(defvar *vi-ex-s-token-end* nil)
(defvar *vi-ex-s-sepalator* "/")


(defun vi-ex-s-lex()
  "tenuki-"
  (let (str str2 line-end prevend)
    (goto-char *vi-ex-s-token-begin*)
    (setq line-end (endof-linepoint))
    (setq *vi-ex-s-token-begin* *vi-ex-s-token-end*)
    (if (>= *vi-ex-s-token-begin* line-end)
	nil
      (progn
	(setq str (buffer-substring *vi-ex-s-token-begin* line-end))
	(cond
	 ((string-match (format nil "^~A" *vi-ex-s-sepalator*) str)
	  (setq *vi-ex-token-type* 'slash)
	  (setq *vi-ex-s-token-end* (+ *vi-ex-s-token-begin* (match-end 0))))
	 ((string-match (format nil "\\([^\\]\\)~A" *vi-ex-s-sepalator*) str)
	  (setq *vi-ex-token-type* 'string)
	  (setq *vi-ex-s-token-end* (+ *vi-ex-s-token-begin* (match-end 1))))
	 ((string-match ".*" str)
	  (setq *vi-ex-token-type* 'string)
	  (setq *vi-ex-s-token-end* (+ *vi-ex-s-token-begin* (match-end 0))))
	 (t
	  nil))))))


(defun get-current-token-s()
  (buffer-substring  *vi-ex-s-token-begin*
		     *vi-ex-s-token-end*))

(defun vi-ex-s(&rest arg)
  (setq *vi-ex-s-token-begin* *vi-ex-token-begin*)
  (setq *vi-ex-s-token-end* *vi-ex-token-begin*)
  (let (before after cmds)
    (unless (vi-ex-s-lex)
      (error "deb1"))
    (unless (eq *vi-ex-token-type* 'slash)
      (error "deb2"))
    (unless (vi-ex-s-lex)
      (error "deb3"))
    (unless (eq *vi-ex-token-type* 'string)
      (error "deb4"))
    (setq before (get-current-token-s))
    (if (not
	 (and (vi-ex-s-lex)
	      (eq *vi-ex-token-type* 'slash)))
	(error "deb5"))
    (unless (vi-ex-s-lex)
      (error "deb6"))
    (if (eq *vi-ex-token-type* 'slash)
	(setq after "")
      (if (eq *vi-ex-token-type* 'string)
	  (progn
	    (setq after (get-current-token-s))
	    (unless (vi-ex-s-lex)
	      ("deb7")))
	(error "deb8")))
    (unless
	(eq *vi-ex-token-type* 'slash)
      (error "vi-ex-s format error3"))
    (if (vi-ex-s-lex)
	(if (eq *vi-ex-token-type* 'string)
	    (setq cmds (get-current-token-s))
	  (error (format nil "vi-ex-s format error4 ~S" *vi-ex-token-type*)))
      (setq cmds nil))
    (vi-ex-s-1 before after cmds)))

(defun my-debug(string)
  (save-window-excursion
    (switch-to-buffer "*scratch*")
    (goto-char (point-max))
    (insert string)))

(defvar *vi-ex-last-match* nil)
(defvar *vi-ex-last-match-char* nil)
(defvar *vi-ex-nodup* nil)
(defvar *vi-ex-query* nil)
(defvar *vi-ex-done* nil)

(defun my-show-match ()
  (goto-char (match-end 0))
  (start-selection 2 t)
  (goto-char (match-beginning 0)))
(defun my-hide-match ()
  (stop-selection))

(defun my-perform-replace-one(pattern replacement query regexp interactive-p noerror begin end)
  (let ((prev-point (point)))
   (setq *last-search-regexp* pattern
	  *last-replace-regexp* replacement)
  (if
      (scan-buffer pattern
		   :regexp regexp
		   :no-dup *vi-ex-nodup*
		   :last-match (cons *vi-ex-last-match* *vi-ex-last-match-char*)
		   :case-fold *case-fold-search*
		   :left-bound *word-search*
		   :right-bound *word-search*)
      (if (or (> (match-end 0) end)
	      (< (match-beginning 0) begin))
	  (progn
	    (goto-char prev-point)
	    nil)
	(if (and (eql (match-beginning 0) (match-end 0))
		 (eql *vi-ex-last-match* (match-beginning 0)))
	    (setq *vi-ex-nodup* t)
	  (if query
	      (progn
		(let ((continue t) c)
		  (my-show-match)
		  (message "置換する？ y,n,a,q")
		  (refresh-screen)
		  (while continue
		    (setq continue nil)
		    (setq c (read-char *keyboard*))
		    (cond
		     ((eq #\y c)
		      (setq *vi-ex-last-match-char* (unless (= (match-end 0) (point-min))
						      (char-before (match-end 0))))
		      (replace-match replacement)
		      (setq *vi-ex-last-match* (point))
		      t)
		     ((eq #\n c)
		      (setq *vi-ex-nodup* t)
		      t)
		     ((eq #\a c)
		      (setq *vi-ex-query* nil)
		      t)
		     ((eq #\q c)
		      (setq *vi-ex-done* t))
		     (t
		      (message "他のキー押すなって y,n,a,q")
		      (setq continue t))))
		  (my-hide-match)))
	      (progn
		(setq *vi-ex-last-match-char* (unless (= (match-end 0) (point-min))
						(char-before (match-end 0))))
		(replace-match replacement)
		(setq *vi-ex-last-match* (point))
		t))))
    nil)))



(defun perform-replace-with-region (pattern replacement query regexp interactive-p noerror begin end)
  (let (res)
    (setq res (my-perform-replace-one pattern replacement query regexp interactive-p noerror begin end))
    res))

(defun beginningof-linepoint()
  (save-excursion
    (beginning-of-line)
    (point)))

(defun vi-replace-oneline(before after query global)
  (beginning-of-line)
  (if global
      (while (and (not *vi-ex-done*)
		  (perform-replace-with-region
		   before after *vi-ex-query* t t t (beginningof-linepoint) (endof-linepoint)))
      )
    (perform-replace-with-region before after query t t t (beginningof-linepoint) (endof-linepoint))))

(defun linenum-to-point(num begin-p)
  (save-excursion
    (beginning-of-buffer)
    (forward-line num)
    (if begin-p
	(beginning-of-line)
      (end-of-line))
    (point)))

(defun vi-ex-s-1(before after cmds)
  "after parse"
  (let ((continue t) (query nil) (global nil)
	      begin
	      end)
    (unless (null cmds)
      (if (string-match "c" cmds)
	  (setq query t))
      (if (string-match "g" cmds)
	  (setq global t)))
    (switch-to-buffer *vi-ex-current-buffer*)
    (setq begin (vi-ex-target-begin))
    (setq end (vi-ex-target-end))
    (setq *vi-ex-last-match* nil)
    (setq *vi-ex-last-match-char* nil)
    (setq *vi-ex-nodup* nil)
    (setq *vi-ex-query* query)
    (setq *vi-ex-done* nil)
    (beginning-of-buffer)
    (forward-line (- begin 1))
    (while (and continue (<= (current-line-number) end))
      (beginning-of-line)
      (vi-replace-oneline before after query global)
      (unless (forward-line)
	(setq continue nil)))
    (message "終了")))
    




(defun vi-ex-w (&rest arg)
"Unsupport forth
withquit forth filename"
  (let ((withquit (car (car arg)))
	(forth (cadr arg))
	(filename (caddr arg)))
    (if (null filename)
	(save-buffer)
      (write-file filename))
    (if withquit
	(vi-ex-q forth))))


(defun vi-ex-q(forth)
  (if (>= (count-windows) 2)
      (delete-window)
    (kill-xyzzy)))


(defun vi-ex-parse-command()
"tenuki-"
  (let ((command (get-current-token)))
    (cond
     ((string-match "^s\\([^a-zA-Z]\\)" command)
      (setq *vi-ex-s-sepalator* (substring command (match-beginning 1) (match-end 1)))
      (incf *vi-ex-token-begin*)
      (vi-ex-s)
      nil)
     ((string-match "^sp" command)
      '(vi-ex-sp))
     ((string-match "^wq!" command)
      '(vi-ex-w t t nil))
     ((string-match "^wq" command)
      '(vi-ex-w t nil nil))
     ((string-match "^w!" command)
      '(vi-ex-w nil t nil))     
     ((string-match "^w" command)
      (if (vi-ex-lex)
	  `(vi-ex-w nil nil ,(get-current-token))
	'(vi-ex-w nil nil nil)))
     ((string-match "^q!" command)
      '(vi-ex-q t))
     ((string-match "^q" command)
      '(vi-ex-q nil))
     ((string-match "^Bu" command) ; tenuki!
      '(vi-ex-bufexplorer))
     (t
      (error (format nil "ex format error, ~A" command))))))
	  
		    

(defun vi-ex-eval(command)
  (let (res)  
    (save-window-excursion
      (vi-ex-prepare-parse command)
      (if (vi-ex-lex)
	  (cond
	   ((eq *vi-ex-token-type*  'number)
	    (vi-ex-set-target-region (vi-ex-parse-region))
	    (unless (and (vi-ex-lex)
			 (eq *vi-ex-token-type* 'string))
	      (error "vi-ex-eval error"))
	    (setq res (vi-ex-parse-command)))
	   ((eq *vi-ex-token-type* 'percent)
	    (unless (vi-ex-lex)
	      (error "perse error in vi-ex-eval"))
	    (vi-ex-set-target-region `(type-percent))
	    (setq res (vi-ex-parse-command)))
	   ((eq *vi-ex-token-type* 'string)
	    (vi-ex-set-target-region '(type-current-line))
	    (setq res (vi-ex-parse-command)))
	   (t
	    (error "parse error")))
	(error "no command")))
    (if (not (null res))
	(funcall (car res) (cdr res)))))


(defun vi-ex(command)
  (interactive "s:")
  (vi-ex-eval command)
  (goto-normal-state))

(defun vi-esc-row ()
  (interactive)
  (setq *vi-num* nil))


(defun vi-kill-or-yank-line(action linenum)
  (let ((region (linenum-to-region linenum)))
;    (error (format nil "~d ~d ~d " (car region) (cdr region) linenum))
    (funcall action
     (car region)
	     (cdr region))))

(defun linenum-to-region(linenum)
  (if (>= linenum 0)
      (linenum-to-region-plus linenum)
    (linenum-to-region-minus linenum)))
(defun last-line-p()
  (save-excursion
    (end-of-line)
    (let ((p (point)))
      (end-of-buffer)
      (= p (point)))))

(defun linenum-to-region-plus(linenum)
  (interactive "*p")
  (let (start)
    (save-excursion
      (beginning-of-line)
      (setq start (point))
      (progn
	(cond ((null linenum)
	       (error "linenum = null"))
	      ((zerop linenum)
	       (error "linenum = 0"))
	      (t (progn
		   (myforward-line linenum)
		   (if (last-line-p)
		       (end-of-line))
		   ))))
      (cons start (point)))))
	      
(defun linenum-to-region-minus(linenum)
  (interactive "*p")
  (let (start)
    (save-excursion
      (forward-line linenum)
      (setq start (point)))
    (cons start
		 (progn
		   (myforward-line)
		   (point)))))
