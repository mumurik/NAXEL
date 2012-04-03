; $Id: grep.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(require "2ch/view")

(provide "2ch/grep")

(in-package "2ch")

(defvar *buffer-grep* "2ch: Grep")

(defvar *grep-last-regexp* nil)

(defvar *grep-case-fold* t)
(defvar *grep-search-name* nil)
(defvar *grep-search-addr* nil)
(defvar *grep-search-body* t)
(defvar *grep-search-kako* t)

(defvar *grep-mode-hook* nil)
(defvar *grep-exec-hook* nil)

(defvar *grep-match-fgcolor* 1)
(defvar *grep-match-bgcolor* 0)

(defun grep-mode ()
  (setq buffer-mode '2ch-grep)
  (setq mode-name *mode-name*)
  (make-local-variable 'grep-data)
  (setq grep-data nil)
  (make-local-variable 'grep-buffer-parent)
  (setq grep-buffer-parent nil)
  (make-local-variable '*scroll-margin*)
  (setq *scroll-margin* *thread-scroll-margin*)
  (make-local-variable 'title-bar-format)
  (setq title-bar-format (format nil "~A - %b" *version-name*))
  (setq buffer-read-only t)
  (setq need-not-save t)
  (setq kept-undo-information nil)
  (setq auto-save nil)
  (toggle-ime nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-buffer-fold-width t)
  (use-keymap *grep-map*)
  (run-hooks '*grep-mode-hook*))

(defvar *grep-map* nil)
(setq *grep-map* (make-sparse-keymap))
(define-key *grep-map* #\RET 'grep-jump)
(define-key *grep-map* #\M-Right 'grep-jump)
(define-key *grep-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *grep-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *grep-map* #\O 'grep-open-thread)
(define-key *grep-map* #\SPC 'next-page)
(define-key *grep-map* #\C-h 'previous-page)
(define-key *grep-map* #\M-Down 'view-next-article)
(define-key *grep-map* #\M-Up 'view-previous-article)
(define-key *grep-map* #\n 'grep-next-match)
(define-key *grep-map* #\p 'grep-previous-match)
(define-key *grep-map* #\q 'grep-quit)
(define-key *grep-map* #\M-t 'toggle-online)
(define-key *grep-map* #\Q 'exit)

(defun set-buffer-grep ()
  (set-buffer (get-buffer-create *buffer-grep*))
  (grep-mode))

(defun grep-match (article regexp)
  (let ((str (grep-type-article article)))
    (and (stringp str)
	 (if *grep-case-fold*
	     (string-matchp regexp str)
	   (string-match regexp str)))))

(defun grep-type-article (article)
  (let ((str "")
	(name (thread-line-name article))
	(addr (thread-line-addr article))
	(body (thread-line-body article)))
    (when (and name *grep-search-name*)
      (setq str (concat str *thread-separater* name)))
    (when (and addr *grep-search-addr*)
      (setq str (concat str *thread-separater* addr)))
    (when (and body *grep-search-body*)
      (setq str (concat str *thread-separater* body)))
    str))

(defun grep-board-files (board host path)
  (let ((files (board-list-dat host path nil *grep-search-kako*)))
    (mapcar #'(lambda (x)
		(list board host path x))
	    files)))

(defun grep-tracking (track-list regexp)
  (grep-exec track-list regexp))

(defun grep-board (board host path regexp)
  (let ((files (grep-board-files board host path)))
    (grep-exec files regexp)))

(defun grep-thread (board host path dat regexp)
  (grep-exec (list (list board host path dat)) regexp))

(defun grep-category (category regexp)
  (let ((menu (category-menu (category-name-menu category)))
	files)
    (dolist (m menu)
      (let ((name (menu-list-name m))
	    (host (menu-list-host m))
	    (path (menu-list-path m))
	    (tracking-p (menu-list-tracking-p m)))
	(if tracking-p
	    (setq files (append files
				(tracking-read name)))
	  (setq files (append files
			      (grep-board-files name host path))))))
    (grep-exec files regexp)))

(defun grep-exec (files regexp)
  (let ((parent (buffer-name (selected-buffer)))
	(i 0))
    (set-buffer-grep)
    (unless (equal parent *buffer-menu*)
      (setq grep-buffer-parent parent))
    (let ((buffer-read-only nil))
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (long-operation
	(setq i (grep-dat-files files regexp i))
	(goto-char (point-min))
	(thread-convert-anchor)
	(thread-convert-link)
	(grep-set-match regexp)
	(message "2ch: formatting articles ... done."))
      (run-hooks '*grep-exec-hook*)
    )))

(defun grep-dat-files (files regexp i)
  (dolist (file files)
    (let* ((name (tracking-list-name file))
	   (host (tracking-list-host file))
	   (path (tracking-list-path file))
	   (dat (tracking-list-dat file))
	   (tmp (grep-dat name host path dat regexp)))
      (dolist (line tmp)
	(incf i)
	(grep-insert-line line i))
      (setq grep-data (append grep-data tmp))))
  i)

(defun grep-set-match (regexp)
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer regexp
			:regexp t
			:tail nil
			:no-dup t
			:case-fold *grep-case-fold*)
      (let ((tag (attr-tag (multiple-value-list (find-text-attribute-point (point))))))
	(unless (or (equal tag 'number)
		    (equal tag 'date)
		    (equal tag 'board))
	  (set-text-attribute (match-beginning 0)
			      (match-end 0)
			      'match
			      :foreground *grep-match-fgcolor*
			      :background *grep-match-bgcolor*
			      :bold t))))))

(defun grep-dat (board host path dat regexp)
  (let ((data-file (thread-path-data host path dat))
	matched
	title
	line
	article
	(i 0))
    (unless (file-exist-p data-file)
      (msgbox "Not Exist: ~S" data-file)
      (return-from grep-dat))
    (save-excursion
      (set-buffer-temp)
      (insert-file-contents data-file)
      (thread-convert-separater)
      (setq title (or (thread-get-title) "")))
    (message "2ch: parsing \"~A\" ..." title)
    (with-input-from-buffer (*buffer-temp*)
      (while (setq line (read-line nil nil))
	(incf i)
	(or (setq article (split-string (thread-parse-special-strings line)
					*thread-separater*
					t
					" "))
	    (return))
	  (and (grep-match article regexp)
	       (push (list board
			   host
			   path
			   dat
			   title
			   i
			   article)
		     matched))
	(do-events)))
    (message "2ch: parsing \"~A\" ... done." title)
    (nreverse matched)))

(defun grep-insert-line (line i)
  (let ((article (grep-line-article line)))
    (set-text-attribute (point)
			(progn
			  (insert (format nil "[~A板:~A:~3,'0D]~%"
					  (grep-line-board line)
					  (grep-line-title line)
					  (grep-line-number line)))
			  (point))
			'board
			:foreground *view-fgcolor-board*
			:background *view-bgcolor-board*
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert (format nil "~3,'0D " i))
			  (point))
			'number
			:foreground *thread-fgcolor-number*
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert (format nil "[~A] " (thread-line-date article)))
			  (point))
			'date
			:foreground *thread-fgcolor-date*
    )
    (set-text-attribute (point)
			(progn
			  (insert (format nil "~A " (thread-line-name article)))
			  (point))
			'name
			:foreground (if (addr-sage-p (thread-line-addr article))
					*thread-fgcolor-name-sage*
				      *thread-fgcolor-name*)
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert (format nil "<~A>~%~%" (thread-line-addr article)))
			  (point))
			'addr
			:foreground (if (addr-sage-p (thread-line-addr article))
					*thread-fgcolor-addr-sage*
				      *thread-fgcolor-addr*)
    )
    (set-text-attribute (point)
			(progn
			  (insert (format nil "~{ ~A~%~}~%"
					  (split-string (thread-parse-special-strings (thread-line-body article))
							"\n" t)))
			  (point))
			'body
			:foreground *thread-fgcolor-body*
    )
  ))

(defun grep-quit ()
  (interactive)
  (if (and grep-buffer-parent
	   (find-buffer grep-buffer-parent))
      (set-buffer grep-buffer-parent)
    (board-quit)))

(defun grep-current-article (number)
  (nth (1- number) grep-data))

(defun grep-open-thread ()
  (interactive)
  (let ((number (thread-current-number))
	line)
    (when number
      (when (setq line (grep-current-article number))
	(thread-history-push)
	(thread-show (grep-line-board line)
		     (grep-line-host line)
		     (grep-line-path line)
		     (grep-line-dat line)
		     (grep-line-title line)
		     (format nil "~D" (or (grep-line-number line) 0))
		     nil
		     nil
		     (buffer-name (selected-buffer)))
	(thread-goto-number (or (grep-line-number line) 0))))))

(defun grep-jump ()
  (interactive)
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (type (attr-tag attr))
	 (curnum (thread-current-number)))
    (cond ((eq type 'anchor)
	   (let (number line)
	     (save-excursion
	       (goto-char (attr-beg attr))
	       (when (looking-at ">>\\([0-9]+\\)")
		 (setq number (parse-integer (match-string 1)))))
	     (when curnum
	       (setq line (grep-current-article curnum)))
	     (when (and number line)
	       (thread-history-push)
	       (thread-show (grep-line-board line)
			    (grep-line-host line)
			    (grep-line-path line)
			    (grep-line-dat line)
			    (grep-line-title line)
			    (format nil "~D" (or (grep-line-number line) 0))
			    nil
			    nil
			    (buffer-name (selected-buffer)))
	       (thread-goto-number number))))
	  ((eq type 'link)
	   (let ((url (buffer-substring (attr-beg attr)
					(attr-end attr))))
	     (when (string-match "^ttp://" url)
	       (setq url (concat "h" url)))
	     (unless (and *thread-open-2ch-url*
			  (thread-open-2ch-url url))
	       (open-browser url))))
	  (t
	   (let (number line)
	     (save-excursion
	       (skip-chars-backward "＞>0-9")
	       (when (looking-at "[＞>]*\\([0-9]+\\)")
		 (setq number (parse-integer (match-string 1)))))
	     (when curnum
	       (setq line (grep-current-article curnum)))
	     (when line
	       (unless number
		 (setq number (grep-line-number line)))
	       (thread-history-push)
	       (thread-show (grep-line-board line)
			    (grep-line-host line)
			    (grep-line-path line)
			    (grep-line-dat line)
			    (grep-line-title line)
			    (format nil "~D" (or number 0))
			    nil
			    nil
			    (buffer-name (selected-buffer)))
	       (when number
		 (thread-goto-number number)))))
    )))

(defun grep-next-match ()
  (interactive)
  (let ((po (find-text-attribute 'match
				 :start (1+ (point)))))
    (when po
      (goto-char po)
      (recenter))))

(defun grep-previous-match ()
  (interactive)
  (let ((po (find-text-attribute 'match
				 :end (1- (point))
				 :from-end t)))
    (when po
      (goto-char po)
      (recenter))))

(defun grep-read-string (&optional dialog)
  (let (string)
    (if dialog
	(setq string (grep-board-dialog))
      (when (setq string (read-string "スレ検索: " :default *grep-last-regexp*))
	(add-history string '*minibuffer-search-string-history*)
	(setq *grep-last-regexp* string)))
    string))

(defun tracking-grep (&optional dialog)
  (interactive)
  (unless (equal buffer-mode '2ch-tracking)
    (return-from tracking-grep))
  (let ((string (grep-read-string dialog)))
    (when string
      (grep-tracking board-list string))))

(defun tracking-grep-dialog ()
  (interactive)
  (tracking-grep t))

(defun menu-grep-all (&optional dialog)
  (interactive)
  (let ((string (grep-read-string dialog))
	files)
    (when string
      (when (setq files (menu-thread-list-all))
	(grep-exec files string)))))

(defun menu-grep-all-dialog ()
  (interactive)
  (menu-grep-all t))

(defun menu-thread-list-all ()
  (let (files)
    (dolist (c 2ch::*menu-list*)
      (dolist (m (category-menu c))
	(let ((name (menu-list-name m))
	      (host (menu-list-host m))
	      (path (menu-list-path m))
	      (tracking-p (menu-list-tracking-p m))
	      tmp)
	  (if tracking-p
	      (setq tmp (tracking-read name))
	    (setq tmp (grep-board-files name host path)))
	  (dolist (f tmp)
	    (let ((board (tracking-list-name f))
		  (host (tracking-list-host f))
		  (path (tracking-list-path f))
		  (dat (tracking-list-dat f)))
	      (pushnew (list board host path dat) files :test #'equal))))))
    (nreverse files)))

(defun category-grep (&optional dialog)
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when category
      (let ((string (grep-read-string dialog)))
	(when string
	  (split-2)
	  (grep-category category string))))))

(defun category-grep-dialog ()
  (interactive)
  (category-grep t))

(defun board-grep (&optional dialog)
  (interactive)
  (unless (equal buffer-mode '2ch-board)
    (return-from board-grep))
  (unless (and board-name board-host board-path)
    (return-from board-grep))
  (let ((string (grep-read-string dialog)))
    (when string
      (grep-board board-name
		  board-host
		  board-path
		  string))))

(defun board-grep-dialog ()
  (interactive)
  (board-grep t))

(defun thread-grep (&optional dialog)
  (interactive)
  (let ((string (grep-read-string dialog)))
    (when string
      (grep-thread thread-board
		   thread-host
		   thread-path
		   thread-dat
		   string))))

(defun thread-grep-dialog ()
  (interactive)
  (thread-grep t))

;;
;; 検索ダイアログ。dialogs.l からパクった
;;
(setq *grep-board-dialog-template*
  '(dialog 0 0 242 95
    (:caption "スレ検索")
    (:font 9 "ＭＳ Ｐゴシック")
    (:control
     (:static nil "検索(&S):" #x50020000 7 10 31 8)
     (:combobox regexp nil #x50210842 39 8 140 96)
     (:button name "名前を検索する(&N)" #x50010003 39 27 100 10)
     (:button addr "メールを検索する(&M)" #x50010003 39 40 100 10)
     (:button body "本文を検索する(&B)" #x50010003 39 53 105 10)
     (:button kako "過去ログも検索する(&K)" #x50010003 39 66 105 10)
     (:button case-fold "大文字小文字を区別する(&C)" #x50010003 39 79 113 10)
     (:button forward "検索(&P)" #x50010001 185 7 50 14)
     (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 185 24 50 14))))

(defun grep-board-dialog ()
  (let (string)
    (multiple-value-bind (result data)
	(let ((string (or (selection-start-end (start end)
			    (buffer-substring start end))
			  *grep-last-regexp*)))
	  (dialog-box *grep-board-dialog-template*
		      (list (cons 'regexp *minibuffer-search-string-history*)
			    (cons 'regexp string)
			    (cons 'case-fold (not *grep-case-fold*))
			    (cons 'name *grep-search-name*)
			    (cons 'body *grep-search-body*)
			    (cons 'addr *grep-search-addr*)
			    (cons 'kako *grep-search-kako*))
		      '((regexp :non-null "検索文字列を入力して" :enable (forward backward)))))
      (when result
	(when (setq string (cdr (assoc 'regexp data)))
	  (add-history string '*minibuffer-search-string-history*)
	  (setq *grep-last-regexp* string)
	  (setq *grep-case-fold* (not (cdr (assoc 'case-fold data))))
	  (setq *grep-search-name* (cdr (assoc 'name data)))
	  (setq *grep-search-addr* (cdr (assoc 'addr data)))
	  (setq *grep-search-body* (cdr (assoc 'body data)))
	  (setq *grep-search-kako* (cdr (assoc 'kako data))))))
    string))
