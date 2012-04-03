; $Id: thread.l 321 2003-05-05 06:09:58Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/thread")

(in-package "2ch")

(defvar *buffer-thread* "2ch: Thread")

(defvar *thread-window* nil)
(defvar *thread-bar-hide* nil)

(defvar *thread-get-diff* t)

(defvar *thread-delete-dat-recycle* nil)
(defvar *thread-delete-tbk-recycle* nil)

(defvar *thread-data-dir* "dat/")
(defvar *thread-kako-dir* "kako/")

(defvar *thread-tbk-suffix* ".tbk")

(defvar *thread-read-url* "../test/read.cgi")
(defvar *thread-offlaw-url* "../test/offlaw.cgi")

(defvar *thread-open-2ch-url* t)

(defvar *thread-view-range-max* 10)

(defvar *thread-log-history* t)

(defvar *thread-body-left-space* " ")

(defvar *thread-aborn-string* "自主あぼーん")
(defvar *thread-aborn-article*
  (list *thread-aborn-string*
	*thread-aborn-string*
	*thread-aborn-string*
	*thread-aborn-string*))

(defvar *thread-max-lines* nil)

(defvar *thread-read-check* nil)

(defvar *thread-read-default* nil)

(defvar *thread-show-preview* t)

(defvar *thread-scroll-margin* 5)

(defvar *thread-clean-days* 30)
(defvar *thread-clean-archive* nil)
(defvar *thread-clean-recycle* nil)
(defvar *thread-clean-tracking* nil)
(defvar *thread-clean-tbk* nil)

(defvar *thread-bar-title-length* 50)
(defvar *thread-bar-show* nil)

(defvar *thread-mode-hook* nil)
(defvar *thread-show-hook* nil)
(defvar *thread-show-pre-hook* nil)

(defvar *thread-separater* "")

(defvar *thread-fgcolor-number* 0)
(defvar *thread-fgcolor-date* 0)
(defvar *thread-fgcolor-name* 0)
(defvar *thread-fgcolor-addr* 0)
(defvar *thread-fgcolor-body* 0)

(defvar *thread-fgcolor-name-sage* 0)
(defvar *thread-fgcolor-addr-sage* 0)

(defvar *thread-fgcolor-cite* nil)

(defvar *thread-cite-regexp*
  (compile-regexp "^ [>＞].*$"))

(defvar *thread-history* nil)

(defvar *thread-hide-addr* nil)

(defvar *thread-map* nil)
(setq *thread-map* (make-sparse-keymap))
(define-key *thread-map* #\RET 'thread-jump)
(define-key *thread-map* #\M-Right 'thread-jump)
(define-key *thread-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *thread-map* #\RBtnUp 'thread-popup)
(define-key *thread-map* #\o 'thread-jump-in-browser)
(define-key *thread-map* #\k 'thread-jump-as-kako)
(define-key *thread-map* #\K 'thread-jump-as-kako-in-browser)
(define-key *thread-map* #\c 'thread-link-copy)
(define-key *thread-map* #\M-Left 'thread-history-back)
(define-key *thread-map* #\SPC 'thread-next-page)
(define-key *thread-map* #\C-h 'thread-previous-page)
(define-key *thread-map* #\TAB 'thread-next-article)
(define-key *thread-map* #\M-Down 'thread-next-article-obstinacy)
(define-key *thread-map* #\M-Up 'thread-previous-article)
(define-key *thread-map* #\M-n 'thread-next-tag)
(define-key *thread-map* #\M-p 'thread-previous-tag)
(define-key *thread-map* #\g 'thread-goto)
(define-key *thread-map* #\p 'thread-anchor-popup)
(define-key *thread-map* #\P 'thread-anchor-popup-msgbox)
(define-key *thread-map* #\e 'thread-anchor-popup-next)
(define-key *thread-map* #\E 'thread-anchor-popup-previous)
(define-key *thread-map* #\v 'thread-view-current)
(define-key *thread-map* #\V 'thread-view-range)
(define-key *thread-map* #\x 'thread-view-current-in-browser)
(define-key *thread-map* #\X 'thread-view-range-in-browser)
(define-key *thread-map* #\w 'thread-form)
(define-key *thread-map* #\f 'thread-form-back)
(define-key *thread-map* #\W 'thread-reply)
(define-key *thread-map* #\M 'thread-reply-range)
(define-key *thread-map* '(#\C-c #\v) 'view-show)
(define-key *thread-map* #\a 'thread-tracking-add)
(define-key *thread-map* #\A 'thread-tracking-add-dialog)
(define-key *thread-map* #\d 'thread-aborn-add)
(define-key *thread-map* #\D 'thread-aborn-add-range)
(define-key *thread-map* #\M-D 'thread-aborn-del)
(define-key *thread-map* #\r 'thread-update)
(define-key *thread-map* #\R 'thread-reload)
(define-key *thread-map* #\O 'thread-open-browser)
(define-key *thread-map* #\/ 'thread-grep)
(define-key *thread-map* #\? 'thread-grep-dialog)
(define-key *thread-map* #\C 'thread-url-copy)
(define-key *thread-map* #\t 'thread-title-copy)
(define-key *thread-map* #\T 'thread-url-title-copy)
(define-key *thread-map* #\h 'thread-hide-addr-popup)
(define-key *thread-map* #\u 'thread-open-2ch-url)
(define-key *thread-map* #\F 'thread-open-local-dat)
(define-key *thread-map* #\F2 'thread-buffer-select)
(define-key *thread-map* #\b 'thread-bookmark-add)
(define-key *thread-map* #\B 'thread-bookmark-add-pos)
(define-key *thread-map* #\q 'thread-quit)
(define-key *thread-map* '(#\C-c #\r) 'thread-board-rule)
(define-key *thread-map* '(#\C-c #\R) 'thread-board-rule-force)
(define-key *thread-map* #\M-t 'toggle-online)
(define-key *thread-map* #\Q 'exit)

(defun thread-path (host path)
  (merge-pathnames *thread-data-dir* (board-path host path)))

(defun thread-path-kako (host path)
  (merge-pathnames *thread-kako-dir* (board-path host path)))

(defun thread-dir (host path)
  (concat (board-dir host path) *thread-data-dir*))

(defun thread-dir-kako (host path)
  (concat (board-dir host path) *thread-kako-dir*))

(defun thread-url (host path)
  (concat (board-url host path) *thread-data-dir*))

(defun thread-url-kako (host path)
  (concat (board-url host path) *thread-kako-dir*))

(defun thread-url-data (host path dat)
  (if (thread-dat-kako-p dat)
      (thread-url-data-kako host path dat)
    (concat (thread-url host path) dat)))

#|
(defun thread-kako-prefix-dir (dat)
  (substring dat 0 3))

(defun thread-kako-prefix-dir (dat &optional new-p)
  (let ((num (pathname-name dat)))
    (if (and new-p
	     (> (length num) 9))
	(format nil "~A/~A" (substring num 0 4) (substring num 0 5))
      (substring num 0 3))))
|#

(defun thread-kako-prefix-dir (dat &optional new-p)
  (if (thread-kako-new-p dat)
      (format nil "~A/~A" (substring dat 0 4) (substring dat 0 5))
    (substring dat 0 3)))

#|
(defun thread-url-data-kako (host path dat &optional new-p)
  (let ((add (thread-kako-prefix-dir dat new-p)))
    (concat (thread-url-kako host path)
	    add
	    "/"
	    (thread-kako2dat dat)
	    (if (thread-kako-new-p dat)
		".gz"
	      ""))))

(defun thread-url-data-kako-html (host path dat &optional new-p)
  (let ((add (thread-kako-prefix-dir dat new-p)))
    (concat (thread-url-kako host path)
	    add
	    "/"
	    dat
	    (if (thread-kako-new-p dat)
		".gz"
	      ""))))
|#

(defun thread-url-data-kako (host path dat &optional new-p)
  (let ((add (thread-kako-prefix-dir dat new-p)))
    (concat (thread-url-kako host path)
	    add
	    "/"
	    (thread-kako2dat dat)
	    ".gz")))

(defun thread-url-data-kako-html (host path dat &optional new-p)
  (let ((add (thread-kako-prefix-dir dat new-p)))
    (concat (thread-url-kako host path)
	    add
	    "/"
	    dat
	    ".gz")))

(defun thread-path-data (host path dat)
  (if (thread-dat-kako-p dat)
      (thread-path-data-kako host path dat)
    (merge-pathnames dat (thread-path host path))))

(defun thread-path-data-kako (host path dat)
  (let ((add (thread-kako-prefix-dir dat)))
    (merge-pathnames
     (thread-kako2dat dat)
     (merge-pathnames
      add
      (thread-path-kako host path)))))

(defun thread-dir-data (host path dat)
  (if (thread-dat-kako-p dat)
      (thread-dir-data-kako host path dat)
    (concat (thread-dir host path) dat)))

(defun thread-dir-data-kako (host path dat)
  (let ((add (thread-kako-prefix-dir dat)))
    (concat (thread-dir-kako host path)
	    add
	    "/"
	    (thread-kako2dat dat))))

(defun thread-path-tbk (host path dat)
  (concat (thread-path-data host path dat) *thread-tbk-suffix*))

(defun thread-dir-tbk (host path dat)
  (concat (thread-dir-data host path dat) *thread-tbk-suffix*))

(defun thread-url-read (host path dat &optional ls)
  (if (thread-dat-kako-p dat)
      (thread-url-data-kako-html host path dat)
    (format nil
	    "~A~@[l~D~]"
	    (thread-url-read-cgi host path dat)
	    (or ls *thread-read-default*))))

(defvar *read-cgi-hosts* nil)

(defun read-cgi-host-p (host)
  (member host *read-cgi-hosts* :test #'equal))

(defun thread-cgi-url (host path)
  (www::www-url-merge-path (board-url host path)
			   *thread-read-url*))

(defun thread-url-read-cgi (host path dat)
  (let ((bbs (form-bbs path))
	(key (form-key dat)))
    (format nil "~A/~A/~A/" (thread-cgi-url host path) bbs key)))

(defun thread-cgi-url-offlaw (host path)
  (www::www-url-merge-path (board-url host path)
			   *thread-offlaw-url*))

(defun thread-url-offlaw-cgi (host path dat)
  (let ((bbs (form-bbs path))
	(key (form-key dat)))
    (format nil "~A/~A/~A/" (thread-cgi-url-offlaw host path) bbs key)))

(defun thread-open-browser ()
  (interactive)
  (let ((url (thread-url-read thread-host
			      thread-path
			      thread-dat)))
    (when url
      (open-browser url))))

(defun thread-url-copy ()
  (interactive)
  (let ((url (thread-url-read thread-host
			      thread-path
			      thread-dat)))
    (when url
      (copy-to-clipboard url)
      (message "~A" url))))

(defun thread-title-copy ()
  (interactive)
  (when thread-title
    (copy-to-clipboard thread-title)
    (message "~A" thread-title)))

(defun thread-url-title-copy ()
  (interactive)
  (let ((url (thread-url-read thread-host
			      thread-path
			      thread-dat)))
    (copy-to-clipboard (thread-url-title-format thread-board thread-title url))
    (message "~A" thread-title)))

(defun thread-url-title-format (board title url)
  (format nil "~@[[~A板] ~]~@[~A~]~%~@[~A~]" board title url))

(defvar *thread-line-regexp* "^[^\n]+<>[^\n]*<>")

(defun thread-separater ()
  (cond ((looking-at *thread-line-regexp*)
	 "<>")
	(t
	 ",")))

(defun thread-separater-line (string)
  (cond ((string-match *thread-line-regexp* string)
	 "<>")
	(t
	 ",")))

(defun thread-anchor-get-range ()
  (let* (beg
	 end
	 start
	 stop
	 (attr (multiple-value-list (find-text-attribute-point (point))))
	 (tag (attr-tag attr)))
    (when (or (equal tag 'number)
	      (equal tag 'date))
      (return-from thread-anchor-get-range))
    (save-excursion
      (if (equal tag 'anchor)
	  (goto-char (attr-beg attr))
	(skip-chars-backward *thread-anchor-syntax-chars*))
      (cond ((looking-at *thread-anchor-regexp*)
	     (setq beg (parse-integer (match-string 1)))
	     (if (match-beginning 3)
		 (setq end (parse-integer (match-string 3)))
	       (setq end beg))
	     (setq start (match-beginning 0))
	     (setq stop (match-end 0)))
	    ((looking-at *thread-anchor-zenkaku-regexp*)
	     (setq beg (parse-integer-zenkaku (match-string 1)))
	     (setq end beg)
	     (setq start (match-beginning 0))
	     (setq stop (match-end 0)))
      ))
    (values beg end start stop)))

(defun thread-get-articles (beg end)
  (let ((i beg)
	articles)
    (save-excursion
      (while (<= i end)
	(let ((po (thread-search-number i))
	      art)
	  (when po
	    (goto-char po)
	    (when (setq art (thread-current-article))
	      (push art articles))))
	(incf i)))
    (nreverse articles)))

(defun thread-article-popup-string (article)
  (format nil "[~3D] ~A <~A> ~A~%~%~A~%"
	  (thread-line-number article)
	  (thread-line-name article)
	  (thread-line-addr article)
	  (thread-line-date article)
	  (thread-line-body article)))

(defvar *thread-anchor-regexp*
  "[>＞]*\\([0-9]+\\)\\(-\\([0-9]+\\)\\)?")
(defvar *thread-anchor-zenkaku-regexp*
  "[>＞]*\\([０-９]+\\)")
(defvar *thread-anchor-syntax-chars*
  ">＞-0123456789０１２３４５６７８９")

(defun thread-anchor-popup-msgbox ()
  (interactive)
  (thread-anchor-popup t))

(defun thread-anchor-popup (&optional msgbox)
  (interactive)
  (multiple-value-bind (beg end)
      (thread-anchor-get-range)
    (when (and beg end)
      (let ((articles (thread-get-articles beg end))
	    (str ""))
	(when articles
	  (dolist (article articles)
	    (setq str
		  (concat str (thread-article-popup-string article))))
	  (if msgbox
	      (message-box str
			   (format nil "[~3D~A]"
				   beg
				   (if (/= beg end)
				       (format nil "-~3D" end)
				     "")))
	    (popup-string str (point))))))))

(defun thread-anchor-popup-next (&optional reverse)
  (interactive "p")
  (when (scan-buffer "[＞>≫][0-9０-９]"
		     :regexp t
		     :tail nil
		     :no-dup t
		     :reverse reverse)
    (thread-anchor-popup)))

(defun thread-anchor-popup-previous ()
  (interactive)
  (thread-anchor-popup-next t))

(defvar *zenkaku-numbers* '(("０" . "0")
			    ("１" . "1")
			    ("２" . "2")
			    ("３" . "3")
			    ("４" . "4")
			    ("５" . "5")
			    ("６" . "6")
			    ("７" . "7")
			    ("８" . "8")
			    ("９" . "9")))

(defun parse-integer-zenkaku (string)
  (mapc #'(lambda (x)
	    (setq string
		  (substitute-string string (car x) (cdr x))))
	*zenkaku-numbers*)
  (parse-integer string :junk-allowed t))

(defun thread-view-current-in-browser ()
  (interactive)
  (let ((article (thread-current-article))
	url
	(*thread-read-default* nil)
	number)
    (declare (special *thread-read-default*))
    (setq number (thread-line-number article))
    (setq url (thread-url-read thread-host
			       thread-path
			       thread-dat))
    (when (and url number)
      ;(setq url (format nil "~A&st=~D&to=~D&nofirst=true" url number number))
      (setq url (format nil "~A~D?&nofirst=true" url number))
      (open-browser url))))

(defun thread-view-range-in-browser ()
  (interactive)
  (let (url
	(*thread-read-default* nil))
    (declare (special *thread-read-default*))
    (when (setq url (thread-url-read thread-host
				     thread-path
				     thread-dat))
      (multiple-value-bind (beg end)
	  (thread-get-range)
	(when (and beg end)
	  ;(setq url (format nil "~A&st=~D&to=~D&nofirst=true" url beg end))
	  (setq url (format nil "~A~D-~D?&nofirst=true" url beg end))
	  (open-browser url))))))

(defun thread-view-current ()
  (interactive)
  (let ((article (thread-current-article)))
    (when (thread-line-number article)
      (message-box (thread-line-body article)
		   (format nil "~03D ~A <~A> ~A"
			   (thread-line-number article)
			   (thread-line-name article)
			   (thread-line-addr article)
			   (thread-line-date article))
		   nil
		   :no-wrap t))))

(defun thread-get-range ()
  (let* ((mk (mark t))
	 (cur (thread-current-number))
	 old
	 beg
	 end)
    (setq old (if mk
		  (thread-current-number mk)
		cur))
    (setq beg (read-number "Start: " (if old
					 (format nil "~D" old)
				       "")))
    (setq end (read-number "End: " (if cur
				       (format nil "~D" cur)
				     "")))
    (values beg end)))

(defun thread-view-range ()
  (interactive)
  (let* ((body "")
	 articles)
    (multiple-value-bind (beg end)
	(thread-get-range)
      (when (and beg end)
	(setq articles (thread-get-articles beg end))
	(dolist (article articles)
	  (setq body (concat body (thread-line-body article)))))
      (message-box body
		   (format nil "~03D - ~03D" beg end)
		   nil
		   :no-wrap t))))

(defun thread-form (&optional reply)
  (interactive)
  (when (thread-dat-kako-p thread-dat)
    (error "過去ログには書き込めません"))
  (form-create thread-board
	       thread-host
	       thread-path
	       thread-title
	       thread-dat
	       reply
	       thread-tbk))

(defun thread-reply ()
  (interactive)
  (let ((article (thread-current-article)))
    (thread-form (list article))))

(defun thread-form-back ()
  (interactive)
  (if (find-buffer *buffer-form*)
      (set-form-buffer)
    (thread-form)))

(defun thread-reply-range ()
  (interactive)
  (let (articles)
    (multiple-value-bind (beg end)
	(thread-get-range)
      (when (and beg end)
	(when (setq articles (thread-get-articles beg end))
	  (thread-form articles))))))

(defun thread-current-number (&optional pos)
  (save-excursion
    (when pos
      (goto-char pos))
    (let ((po (find-text-attribute 'number
				   :end (1+ (point))
				   :from-end t))
	  number)
      (when po
	(goto-char po)
	(when (looking-at "\\([0-9]+\\) ")
	  (setq number (parse-integer (match-string 1)))))
      number)))

(defun thread-current-article ()
  (save-excursion
    (let ((beg (find-text-attribute 'number
				    :end (1+ (point))
				    :from-end t))
	  (end (find-text-attribute 'number
				    :start (1+ (point))))
	  name
	  addr
	  date
	  body
	  number)
      ;(msgbox "~S:~S" beg end)
      (when beg
	(goto-char beg)
	(when (looking-at "\\([0-9]+\\) +\\[\\([^\]]+\\)\\] +\\(.+\\)? +<\\(.*\\)>$")
	  (setq number (parse-integer (match-string 1))
		date (match-string 2)
		name (match-string 3)
		addr (match-string 4))
	  (forward-line 2)
	  (setq body (buffer-substring (point) (- (or end (point-max)) 1)))))
      (list name addr date body number))))

#|
(defun thread-get-article (number)
  (let ((buf (buffer-name (selected-buffer)))
	article)
    (set-buffer *buffer-temp*)
    (goto-line number)
    (setq article (split-string (buffer-substring (progn (goto-bol) (point))
						  (progn (goto-eol) (point)))
				*thread-separater*
				t
				" "))
    (set-buffer buf)
    article))

(defun thread-current-article ()
  (let ((number (thread-current-number)))
    (when number
      (thread-get-article number))))
|#

(defun thread-data-read-p (host path dat)
  (or (file-exist-p (thread-path-data host path dat))
      (thread-archive-exist (thread-dir-data host path dat))))

(defun thread-data-wtime (host path dat)
  (let ((data-file (thread-path-data host path dat)))
    (when (file-exist-p data-file)
      (file-write-time data-file))))

(defun thread-show (board host path dat title num &optional force reload parent)
  (let* ((kako-p (thread-dat-kako-p dat))
	 (data-file (thread-path-data host path dat))
	 (bufname (thread-buffer-name host path title dat))
	 (data-exist (file-exist-p data-file))
	 buf-exist
	 separater)
    ; buffer がすでにあった場合
    (when (setq buf-exist (find-buffer bufname))
      (set-buffer-thread board host path title dat num)
      (when parent
	(setq thread-buffer-parent parent))
      ;(set-buffer bufname)
      (if force
	  (refresh-screen)
	(return-from thread-show)))
    ; アーカイブから解凍
    (unless data-exist
      (setq data-exist
	    (thread-get-archive host path dat)))
    ; データを前に読んでいるかどうか
    (if data-exist
	(when force
	  ; いったん前に読んだところまで表示する
	  (if (and *thread-show-preview*
		     (not buf-exist))
	      (progn
		(thread-show board host path dat title num nil nil parent)
		(refresh-screen)
		(unless (thread-get host path dat reload)
		  (return-from thread-show)))
	    (thread-get host path dat reload)))
      (thread-get host path dat reload))
    (set-buffer-temp)
    (insert-file-contents data-file)
    (goto-char (point-min))
    (thread-convert-separater)
    ; タイトル不明の場合には一行目から取得
    (when (equal title "")
      (setq title (or (thread-get-title) "")))
    (set-buffer-thread board host path title dat num)
    (when parent
      (setq thread-buffer-parent parent))
    (thread-tbk-load)
    (let ((buffer-read-only nil)
	  max)
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (message "2ch: parsing thread ...")
      (setq max (thread-parse-dat))
      (message "2ch: parsing thread ... done")
      (goto-char (point-min))
      (run-hooks '*thread-show-pre-hook*)
      (when *thread-fgcolor-cite*
	(thread-search-cite))
      (thread-convert-anchor)
      (when kako-p
	(thread-convert-html-link))
      (thread-convert-link)
      (thread-tbk-back)
      (tracking-uplist-del (list board host path dat title num))
      (when *thread-log-history*
	(history-add))
      (run-hooks '*thread-show-hook*)
      max
    )))

(defvar *thread-local-dat-directory* nil)

(defun thread-open-local-dat ()
  (interactive)
  (let* ((data-file (file-name-dialog :title "Local dat"
				      :default *thread-local-dat-directory*))
	 (board "local")
	 (host "")
	 (title "")
	 (path (directory-namestring data-file))
	 (dat (file-namestring data-file))
	 (bufname (thread-buffer-name host path title dat))
	 buf-exist
	 (num ""))
    (unless path
      (return-from thread-open-local-dat))
    (setq *thread-local-dat-directory* data-file)
    ; buffer がすでにあった場合
    (when (setq buf-exist (find-buffer bufname))
      (set-buffer-thread board host path title dat num)
      (if force
	  (refresh-screen)
	(return-from thread-open-local-dat)))
    (set-buffer-temp)
    (insert-file-contents data-file)
    (goto-char (point-min))
    (thread-convert-separater)
    ; タイトル不明の場合には一行目から取得
    (when (equal title "")
      (setq title (or (thread-get-title) "")))
    (set-buffer-thread board host path title dat num)
    (thread-tbk-load)
    (let ((buffer-read-only nil))
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (message "2ch: parsing thread ...")
      (setq max (thread-parse-dat))
      (message "2ch: parsing thread ... done")
      (goto-char (point-min))
      (run-hooks '*thread-show-pre-hook*)
      (when *thread-fgcolor-cite*
	(thread-search-cite))
      (thread-convert-anchor)
      (thread-convert-link)
      (run-hooks '*thread-show-hook*)
      )))

(defun thread-convert-separater ()
  (let (separater)
    (save-excursion
      (message "2ch: converting separater ...")
      (goto-char (point-min))
      (setq separater (thread-separater))
      (replace-string *thread-separater* "" t)
      (goto-char (point-min))
      (replace-string separater *thread-separater* t)
      (message "2ch: converting separater ... done."))))

(defun thread-line-to-article (line)
  (split-string (thread-parse-special-strings line)
		*thread-separater*
		t
		" "))

(defun thread-parse-dat (&optional buf)
  (setq buf (or buf *buffer-temp*))
  (let (line
	(i 0))
    (with-input-from-buffer (*buffer-temp*)
      (while (setq line (read-line nil nil))
	(unless (equal line "")
	  (incf i)
	  ;(setq line (thread-parse-special-strings line))
	  (let ((tmp (thread-line-to-article line)))
	    (thread-insert (if (thread-aborn-p i)
			       *thread-aborn-article*
			     (if (cdr tmp)
				 tmp
			       (cons (car tmp) '("" "" "" "" ""))))
			   i)))))
    i))

(defun thread-get-title ()
  (let (tmp)
    (save-excursion
      (goto-char (point-min))
      (setq tmp (split-string
		 (thread-parse-special-strings
		  (buffer-substring (point)
				    (progn (goto-eol) (point))))
		 *thread-separater*
		 t
		 " ")))
    ;(msgbox "~S" tmp)
    (thread-line-title tmp)))

(defun thread-dat-get-title (dat)
  (let (line
	separater
	article)
    (when (file-exist-p dat)
      (with-open-file (s dat
			 :direction :input)
	(setq line (read-line s nil)))
      (when (and line
		 (setq separater (thread-separater-line line)))
	(setq line (substitute-string line separater *thread-separater*))
	(thread-line-title (thread-line-to-article line))))))

#|
(defvar *thread-dat-html-regexp*
  "^<dt>\\([0-9]+\\) 名前：\\(<font color=\"[^\"]*\">\\|<a href=\"mailto:\\([^\"]*\\)\">\\)<b>\\(.*\\)\\(</B></a>\\|</b></font>\\) 投稿日： \\([^<]+\\)<br><dd>\\(.*\\)<br><br><br>$")

(defun thread-parse-html (&optional buf)
  (setq buf (or buf *buffer-temp*))
  (let (line
	max)
    (with-input-from-buffer (buf)
      (while (setq line (read-line nil nil))
	(when (string-match *thread-dat-html-regexp* line)
	  (let ((num (parse-integer (substring line (match-beginning 1) (match-end 1))))
		(addr "")
		(name (substring line (match-beginning 4) (match-end 4)))
		(date (substring line (match-beginning 6) (match-end 6)))
		(body (substring line (match-beginning 7) (match-end 7))))
	    (when (match-beginning 3)
	      (setq addr (string-trim " " (substring line (match-beginning 3) (match-end 3)))))
	    (setq name (thread-parse-special-strings name))
	    (setq addr (thread-parse-special-strings addr))
	    (setq body (thread-parse-special-strings body))
	    (thread-insert (if (thread-aborn-p num)
			       *thread-aborn-article*
			     (list name addr date body num))
			   num)
	    (setq max num)))))
    max))

(defun thread-get-html-title ()
  (let (tmp)
    (save-excursion
      (goto-char (point-min))
      (when (scan-buffer "^<title>\\([^\n]*\\)</title>$" :regexp t)
	(setq tmp (match-string 1))))
    tmp))
|#

(defun thread-convert-anchor ()
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "<a href=\"[^\"]+\" target=\"_blank\">>>\\([-0-9]+\\)</a>"
			:regexp t
			:tail nil)
      (let ((num (match-string 1)))
	(delete-region (match-beginning 0) (match-end 0))
	(set-text-attribute (point)
			    (progn
			      (insert (format nil ">>~A" num))
			      (point))
			    'anchor
			    :bold t)))))

(defun thread-convert-html-link ()
  "過去ログの場合はリンクはURLなので、<A>タグを削除"
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "<a href=\"[^\"]+\" target=\"_blank\">\\([^<]*\\)</a>"
			:regexp t
			:tail nil)
      (let ((url (match-string 1)))
	(delete-region (match-beginning 0) (match-end 0))
	(insert url)))))

(defvar *thread-url-attribute* '(:foreground 4
				 :underline t))

(defun thread-convert-link ()
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "\\(\\(h?ttp\\|ftp\\|ｈｔｔｐ\\)://[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+\\)"
			:regexp t
			:tail t)
      (apply #'set-text-attribute (append (list (match-beginning 0)
                                                (match-end 0)
						'link)
					  *thread-url-attribute*)))))

(defun thread-convert-link-like ()
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "[^/]www[0-9]*\\.[-a-zA-Z0-9_/~.#@%?&=;+(),'$!*:]+"
			:regexp t
			:tail t)
      (let* ((attr (multiple-value-list (find-text-attribute-point (1- (point)))))
	     (type (attr-tag attr)))
	(cond ((equal type 'anchor)
	       nil)
	      ((equal type 'link)
	       nil)
	      (t
	       (set-text-attribute (1+ (match-beginning 0))
				   (match-end 0)
				   'link
				   :underline t)))))))

(defun thread-convert-unicode-chars ()
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "&#\\([0-9]+\\);" :regexp t :tail t)
      (let ((num (match-string 1)))
	(delete-region (match-beginning 0) (match-end 0))
	(insert (unicode-char (parse-integer num)))))))

(defvar *special-char-type* '(
			      ("nbsp" . 160)
			      ("iexcl" . 161)
			      ("cent" . 162)
			      ("pound" . 163)
			      ("curren" . 164)
			      ("yen" . 165)
			      ("brvar" . 166)
			      ("sect" . 167)
			      ("uml" . 168)
			      ("copy" . 169)
			      ("ordf" . 170)
			      ("laquo" . 171)
			      ("not" . 172)
			      ("shy" . 173)
			      ("reg" . 174)
			      ("macr" . 175)
			      ("deg" . 176)
			      ("plusmn" . 177)
			      ("sup2" . 178)
			      ("sup3" . 179)
			      ("acute" . 180)
			      ("micro" . 181)
			      ("para" . 182)
			      ("middot" . 183)
			      ("cedil" . 184)
			      ("sup1" . 185)
			      ("ordm" . 186)
			      ("raquo" . 187)
			      ("frac14" . 188)
			      ("frac12" . 189)
			      ("frac34" . 190)
			      ("iquest" . 191)
			      ("Agrave" . 192)
			      ("Aacute" . 193)
			      ("Acirc" . 194)
			      ("Atilde" . 195)
			      ("Auml" . 196)
			      ("Aring" . 197)
			      ("AElig" . 198)
			      ("Ccedil" . 199)
			      ("Egrave" . 200)
			      ("Eacute" . 201)
			      ("Ecirc" . 202)
			      ("Euml" . 203)
			      ("Igrave" . 204)
			      ("Iacute" . 205)
			      ("Icirc" . 206)
			      ("Iuml" . 207)
			      ("ETH" . 208)
			      ("Ntilde" . 209)
			      ("Ograve" . 210)
			      ("Oacute" . 211)
			      ("Ocirc" . 212)
			      ("Otilde" . 213)
			      ("Ouml" . 214)
			      ("times" . 215)
			      ("Oslash" . 216)
			      ("Ugrave" . 217)
			      ("Uacute" . 218)
			      ("Ucirc" . 219)
			      ("Uuml" . 220)
			      ("Yacute" . 221)
			      ("THORN" . 222)
			      ("szlig" . 223)
			      ("agrave" . 224)
			      ("aacute" . 225)
			      ("acirc" . 226)
			      ("atilde" . 227)
			      ("auml" . 228)
			      ("aring" . 229)
			      ("aelig" . 230)
			      ("ccedil" . 231)
			      ("egrave" . 232)
			      ("eacute" . 233)
			      ("ecirc" . 234)
			      ("euml" . 235)
			      ("igrave" . 236)
			      ("iacute" . 237)
			      ("icirc" . 238)
			      ("iuml" . 239)
			      ("eth" . 240)
			      ("ntilde" . 241)
			      ("ograve" . 242)
			      ("oacute" . 243)
			      ("ocirc" . 244)
			      ("otilde" . 245)
			      ("ouml" . 246)
			      ("divide" . 247)
			      ("oslash" . 248)
			      ("ugrave" . 249)
			      ("uacute" . 250)
			      ("ucirc" . 251)
			      ("uuml" . 252)
			      ("yacute" . 253)
			      ("thorn" . 254)
			      ("yuml" . 255)
			      ("fnof" . 402)
			      ("Alpha" . 913)
			      ("Beta" . 914)
			      ("Gamma" . 915)
			      ("Delta" . 916)
			      ("Epsilon" . 917)
			      ("Zeta" . 918)
			      ("Eta" . 919)
			      ("Theta" . 920)
			      ("Iota" . 921)
			      ("Kappa" . 922)
			      ("Lambda" . 923)
			      ("Mu" . 924)
			      ("Nu" . 925)
			      ("Xi" . 926)
			      ("Omicron" . 927)
			      ("Pi" . 928)
			      ("Rho" . 929)
			      ("Sigma" . 931)
			      ("Tau" . 932)
			      ("Upsilon" . 933)
			      ("Phi" . 934)
			      ("Chi" . 935)
			      ("Psi" . 936)
			      ("Omega" . 937)
			      ("alpha" . 945)
			      ("beta" . 946)
			      ("gamma" . 947)
			      ("delta" . 948)
			      ("epsilon" . 949)
			      ("zeta" . 950)
			      ("eta" . 951)
			      ("theta" . 952)
			      ("iota" . 953)
			      ("kappa" . 954)
			      ("lambda" . 955)
			      ("mu" . 956)
			      ("nu" . 957)
			      ("xi" . 958)
			      ("omicron" . 959)
			      ("pi" . 960)
			      ("rho" . 961)
			      ("sigmaf" . 962)
			      ("sigma" . 963)
			      ("tau" . 964)
			      ("upsilon" . 965)
			      ("phi" . 966)
			      ("chi" . 967)
			      ("psi" . 968)
			      ("omega" . 969)
			      ("thetasym" . 977)
			      ("upsih" . 978)
			      ("piv" . 982)
			      ("bull" . 8226)
			      ("hellip" . 8230)
			      ("prime" . 8242)
			      ("Prime" . 8243)
			      ("oline" . 8254)
			      ("frasl" . 8260)
			      ("weierp" . 8472)
			      ("image" . 8465)
			      ("real" . 8476)
			      ("trade" . 8482)
			      ("alefsym" . 8501)
			      ("larr" . 8592)
			      ("uarr" . 8593)
			      ("rarr" . 8594)
			      ("darr" . 8595)
			      ("harr" . 8596)
			      ("crarr" . 8629)
			      ("lArr" . 8656)
			      ("uArr" . 8657)
			      ("rArr" . 8658)
			      ("dArr" . 8659)
			      ("hArr" . 8660)
			      ("forall" . 8704)
			      ("part" . 8706)
			      ("exit" . 8707)
			      ("empty" . 8709)
			      ("nabla" . 8711)
			      ("isin" . 8712)
			      ("notin" . 8713)
			      ("ni" . 8715)
			      ("prod" . 8719)
			      ("sum" . 8721)
			      ("minus" . 8722)
			      ("lowast" . 8727)
			      ("radic" . 8730)
			      ("prop" . 8733)
			      ("infin" . 8734)
			      ("ang" . 8736)
			      ("and" . 8743)
			      ("or" . 8744)
			      ("cap" . 8745)
			      ("cup" . 8746)
			      ("int" . 8747)
			      ("there4" . 8756)
			      ("sim" . 8764)
			      ("cong" . 8773)
			      ("asymp" . 8776)
			      ("ne" . 8800)
			      ("equiv" . 8801)
			      ("le" . 8804)
			      ("ge" . 8805)
			      ("sub" . 8834)
			      ("sup" . 8835)
			      ("nsub" . 8836)
			      ("sube" . 8838)
			      ("supe" . 8839)
			      ("oplus" . 8853)
			      ("otimes" . 8855)
			      ("perp" . 8869)
			      ("sdot" . 8901)
			      ("lceil" . 8968)
			      ("rceil" . 8969)
			      ("lfloor" . 8970)
			      ("rfloor" . 8971)
			      ("lang" . 9001)
			      ("rang" . 9002)
			      ("loz" . 9674)
			      ("spades" . 9824)
			      ("clubs" . 9827)
			      ("hearts" . 9829)
			      ("diams" . 9830)
			      ("quot" . 34)
			      ("amp" . 38)
			      ("lt" . 60)
			      ("gt" . 62)
			      ("OElig" . 338)
			      ("oelig" . 339)
			      ("Scaron" . 352)
			      ("scaron" . 353)
			      ("Yuml" . 376)
			      ("circ" . 710)
			      ("tilde" . 732)
			      ("ensp" . 8194)
			      ("emsp" . 8195)
			      ("thinsp" . 8201)
			      ("zwnj" . 8204)
			      ("zwj" . 8205)
			      ("lrm" . 8206)
			      ("rlm" . 8207)
			      ("ndash" . 8211)
			      ("mdash" . 8212)
			      ("lsquo" . 8216)
			      ("rsquo" . 8217)
			      ("sbquo" . 8218)
			      ("ldquo" . 8220)
			      ("rdquo" . 8221)
			      ("bdquo" . 8222)
			      ("dagger" . 8224)
			      ("Dagger" . 8225)
			      ("permil" . 8240)
			      ("lsaquo" . 8249)
			      ("rsaquo" . 8250)
			      ("euro" . 8364)
			      ))

(defun special-char-hash ()
  (let ((hash (make-hash-table :size (list-length *special-char-type*)
			       :test #'equal)))
    (mapc #'(lambda (x)
	      (setf (gethash (car x) hash) (cdr x)))
	  *special-char-type*)
    hash))

(defvar *special-char-hash* (special-char-hash))

#|
(defun special-char-regexp ()
  (let ((reg ""))
    (mapc #'(lambda (x)
	      (setq reg (concat reg "\\|" (car x))))
	  *special-char-type*)
    (concat "&\\(" reg "\\);")))

(defvar *special-char-regexp* (special-char-regexp))
|#

(defun thread-convert-special-chars ()
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "&\\([a-zA-Z0-9]+\\);" :regexp t :tail t)
      (let* ((type (match-string 1))
	     (num (gethash type *special-char-hash*)))
	(when num
	  (delete-region (match-beginning 0) (match-end 0))
	  (insert (unicode-char num)))))))

(defun thread-search-cite ()
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer *thread-cite-regexp*
			:regexp t
			:tail t)
      (set-text-attribute (match-beginning 0)
			  (match-end 0)
			  'cite
			  :foreground *thread-fgcolor-cite*))))

(defun thread-update (&optional reload)
  (interactive)
  (let ((parent thread-buffer-parent))
    (thread-tbk-save)
    (thread-show thread-board
		 thread-host
		 thread-path
		 thread-dat
		 thread-title
		 thread-num
		 t
		 reload
		 parent)))

(defun thread-reload ()
  (interactive)
  (thread-update t))

(defun thread-insert (line i)
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
			(insert (format nil "[~A] " (thread-line-date line)))
			(point))
		      'date
		      :foreground *thread-fgcolor-date*
		      )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~A " (thread-line-name line)))
			(point))
		      'name
		      :foreground (if (addr-sage-p (thread-line-addr line))
				      *thread-fgcolor-name-sage*
				    *thread-fgcolor-name*)
		      :bold t
		      )
  (if *thread-hide-addr*
      (progn
	(set-text-attribute (point)
			    (progn
			      (insert (format nil "<~A>~%" (substitute-string (thread-line-addr line) "." "*")))
			      (point))
			    'addr
			    :foreground (if (addr-sage-p (thread-line-addr line))
					    *thread-fgcolor-addr-sage*
					  *thread-fgcolor-addr*))
	(set-text-attribute (point)
			    (progn
			      (insert (format nil "~%"))
			      (point))
			    (cons 'addr-contents (thread-line-addr line))))
    (set-text-attribute (point)
			(progn
			  (insert (format nil "<~A>~%~%" (thread-line-addr line)))
			  (point))
			'addr
			:foreground (if (addr-sage-p (thread-line-addr line))
					*thread-fgcolor-addr-sage*
				      *thread-fgcolor-addr*)))
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~A~A~%~%" *thread-body-left-space* (thread-line-body line)))
			(point))
		      'body
		      :foreground *thread-fgcolor-body*
		      ))

(defun thread-hide-addr-popup ()
  (interactive)
  (when *thread-hide-addr*
    (let ((addr-contents "")
	  (po (find-text-attribute 'number
				   :end (1+ (point))
				   :from-end t)))
      (when po
	(save-excursion
	  (goto-char po)
	  (multiple-value-bind (from to tag)
	      (find-text-attribute 'addr-contents
				   :start (point)
				   :test #'(lambda (symbol tag)
					     (if (and (consp tag)
						      (eq (car tag) symbol))
						 t nil)))
	    (if from
		(setq addr-contents (cdr tag))))))
      (popup-string addr-contents (point)))))

#|
(defun thread-insert (line i)
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
			(insert (format nil "[~A] " (thread-line-date line)))
			(point))
		      'date
		      :foreground *thread-fgcolor-date*
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~A " (thread-line-name line)))
			(point))
		      'name
		      :foreground (if (addr-sage-p (thread-line-addr line))
				      *thread-fgcolor-name-sage*
				    *thread-fgcolor-name*)
		      :bold t
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "<~A>~%~%" (thread-line-addr line)))
			(point))
		      'addr
		      :foreground (if (addr-sage-p (thread-line-addr line))
				      *thread-fgcolor-addr-sage*
				    *thread-fgcolor-addr*)
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~A~A~%~%" *thread-body-left-space* (thread-line-body line)))
			(point))
		      'body
		      :foreground *thread-fgcolor-body*
  )
)
|#

(defun thread-goto (number)
  (interactive "nNumber: ")
  (thread-history-push)
  (thread-goto-number number))

(defun thread-search-number (number)
  (let ((regexp (format nil "^~3,'0D " number))
	beg)
    (save-excursion
      (goto-char (point-min))
      (when (scan-buffer regexp :regexp t :tail nil)
	(setq beg (match-beginning 0))))
    beg))

(defun thread-goto-number (number)
  (let ((beg (thread-search-number number)))
    (when beg
      (goto-char beg)
      (recenter 0))))

(defun thread-jump-in-browser ()
  (interactive)
  (let ((*thread-open-2ch-url* nil))
    (declare (special *thread-open-2ch-url*))
    (thread-jump)))

(defun thread-jump ()
  (interactive)
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (type (attr-tag attr)))
    (cond ((eq type 'anchor)
	   (let (number)
	     (save-excursion
	       (goto-char (attr-beg attr))
	       (when (looking-at ">>\\([0-9]+\\)")
		 (setq number (parse-integer (match-string 1)))))
	     (when number
	       (thread-history-push)
	       (thread-goto-number number))))
	  ((eq type 'link)
	   (let ((url (buffer-substring (attr-beg attr)
					(attr-end attr))))
	     (cond ((string-match "^ttp://" url)
		    (setq url (concat "h" url)))
		   ((string-match "^ｈｔｔｐ" url)
		    (setq url (substitute-string url "ｈｔｔｐ" "http")))
		   ((string-match "^www\." url)
		    (setq url (concat "http://" url))))
	     (unless (and *thread-open-2ch-url*
			  (thread-open-2ch-url url))
	       (open-browser url))))
	  (t
	   (let (number)
	     (save-excursion
	       (skip-chars-backward "0-9")
	       (when (looking-at "[0-9]+")
		 (setq number (parse-integer (match-string 0)))))
	     (when number
	       (thread-history-push)
	       (thread-goto-number number))))
    )))

(defun thread-jump-as-kako-in-browser ()
  (interactive)
  (let ((*thread-open-2ch-url* nil))
    (declare (special *thread-open-2ch-url*))
    (thread-jump-as-kako)))

(defun thread-jump-as-kako ()
  (interactive)
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (type (attr-tag attr)))
    (cond ((eq type 'anchor)
	   nil)
	  ((eq type 'link)
	   (let ((url (buffer-substring (attr-beg attr)
					(attr-end attr))))
	     (when (string-match "^ttp://" url)
	       (setq url (concat "h" url)))
	     (unless (and *thread-open-2ch-url*
			  (thread-open-2ch-url-as-kako url))
	       (open-browser url))))
	  (t
	   nil)
    )))

(defun thread-link-copy ()
  (interactive)
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (type (attr-tag attr)))
    (cond ((eq type 'anchor)
	   nil)
	  ((eq type 'link)
	   (let ((url (buffer-substring (attr-beg attr)
					(attr-end attr))))
	     (when url
	       (when (string-match "^ttp://" url)
		 (setq url (concat "h" url)))
	       (copy-to-clipboard url)
	       (message "~A" url))))
	  (t
	   nil)
    )))

#|
(defun thread-open-2ch-url-as-kako (url)
  (interactive "s2ch URL: ")
  (let ((parent thread-buffer-parent)
	host path bbs key board title num)
    (cond ((string-match *thread-read-cgi-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".html"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   (thread-tbk-save)
	   (thread-history-push)
	   (setq num (thread-show board host path key (or title "") (or num "0") nil nil parent))
	   (when (string-match "&st=\\([0-9]+\\)" url)
	     (let ((line (parse-integer
			  (substring url (match-beginning 1) (match-end 1)))))
	       (thread-goto line)))
	   t)
	  ((string-match *thread-kako-html-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 2) (match-end 2)))
	   (setq key (substring url (match-beginning 3) (match-end 3)))
	   (setq path (format nil "/~A/" bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (thread-tbk-save)
	   (thread-history-push)
	   (setq num (thread-show board host path key "" "0" nil nil parent))
	   t)
	  (t
	   nil))))
|#

(defun thread-parse-2ch-url (url)
  (let (host path bbs key board title num goto line)
    (cond ((string-match *thread-read-cgi-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".dat"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   (when (string-match "&st=\\([0-9]+\\)" url)
	     (setq line (parse-integer (substring url (match-beginning 1) (match-end 1)))))
	   )
	  ((string-match *thread-read-cgi-path-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".dat"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (when (match-beginning 5)
	     (setq line (parse-integer (substring url (match-beginning 6) (match-end 6)))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   )
	  ((string-match *thread-kako-cgi-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".html"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   (when (string-match "&st=\\([0-9]+\\)" url)
	     (setq line (parse-integer (substring url (match-beginning 1) (match-end 1)))))
	   )
	  ((string-match *thread-kako-html-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 2) (match-end 2)))
	   (setq key (substring url (match-beginning 3) (match-end 3)))
	   (setq path (format nil "/~A/" bbs))
	   (setq board (or (menu-board-name host path) "")))
	  (t
	   nil))
    (values host bbs key path board title num line)))

(defun thread-open-2ch-url (url &optional as-kako)
  (interactive "s2ch URL: ")
  (let ((parent thread-buffer-parent))
    (multiple-value-bind (host bbs key path board title num line)
	(thread-parse-2ch-url url)
      (let ()
	(unless host
	  (return-from thread-open-2ch-url))
	(when (and as-kako
		   (string-match "^\\([0-9]+\\).dat$" key))
	  (setq key (concat (match-string 1) ".html")))
	(thread-tbk-save)
	(thread-history-push)
	(setq num (thread-show board host path key (or title "") (or num "0") nil nil parent))
	(when line
	  (thread-goto line)))))
  t)

(defun thread-open-2ch-url-as-kako (url)
  (interactive "s2ch URL (kako): ")
  (thread-open-2ch-url url t))

#|
(defun thread-open-2ch-url (url)
  (interactive "s2ch URL: ")
  (let ((parent thread-buffer-parent)
	host path bbs key board title num goto)
    (cond ((string-match *thread-read-cgi-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".dat"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   (thread-tbk-save)
	   (thread-history-push)
	   (setq num (thread-show board host path key (or title "") (or num "0") nil nil parent))
	   (when (string-match "&st=\\([0-9]+\\)" url)
	     (let ((line (parse-integer
			  (substring url (match-beginning 1) (match-end 1)))))
	       (thread-goto line)))
	   t)
	  ((string-match *thread-read-cgi-path-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".dat"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (when (match-beginning 5)
	     (setq goto (parse-integer (substring url (match-beginning 5) (match-end 5)))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   (thread-tbk-save)
	   (thread-history-push)
	   (setq num (thread-show board host path key (or title "") (or num "0") nil nil parent))
	   (when goto
	     (thread-goto goto))
	   t)
	  ((string-match *thread-kako-cgi-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 3) (match-end 3)))
	   (setq key (substring url (match-beginning 4) (match-end 4)))
	   (setq key (concat key ".html"))
	   (when (match-beginning 2)
	     (setq path
		   (substring url (match-beginning 2) (match-end 2))))
	   (setq path (format nil "/~A~A/" (or path "") bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (multiple-value-setq (title num)
	     (board-thread-name host path key *online*))
	   (thread-tbk-save)
	   (thread-history-push)
	   (setq num (thread-show board host path key (or title "") (or num "0") nil nil parent))
	   (when (string-match "&st=\\([0-9]+\\)" url)
	     (let ((line (parse-integer
			  (substring url (match-beginning 1) (match-end 1)))))
	       (thread-goto line)))
	   t)
	  ((string-match *thread-kako-html-regexp* url)
	   (setq host (substring url (match-beginning 1) (match-end 1)))
	   (setq bbs (substring url (match-beginning 2) (match-end 2)))
	   (setq key (substring url (match-beginning 3) (match-end 3)))
	   (setq path (format nil "/~A/" bbs))
	   (setq board (or (menu-board-name host path) ""))
	   (thread-tbk-save)
	   (thread-history-push)
	   (setq num (thread-show board host path key "" "0" nil nil parent))
	   t)
	  (t
	   nil)
    )))
|#

#|
(defvar *thread-read-cgi-regexp*
  "^http://\\([^/]+\\)/\\([^/]+/\\)?test/read.cgi\\?bbs=\\([-0-9a-zA-Z_]+\\)&key=\\([0-9]+\\)")

(defvar *thread-read-cgi-path-regexp*
  "^http://\\([^/]+\\)/\\([^/]+/\\)?test/read.cgi/\\([-0-9a-zA-Z_]+\\)/\\([0-9]+\\)/\\([0-9]+\\)?")
|#
(defvar *thread-read-cgi-regexp*
  "^http://\\([^/]+\\)/\\(.*/\\)?test/read.cgi\\?bbs=\\([-0-9a-zA-Z_]+\\)&key=\\([0-9]+\\)")

(defvar *thread-read-cgi-path-regexp*
  "^http://\\([^/]+\\)/\\(.*/\\)?test/read.cgi/\\([-0-9a-zA-Z_]+\\)/\\([0-9]+\\)\\(/\\([0-9]+\\)\\)?")

(defvar *thread-kako-html-regexp*
  "^http://\\([^/]+\\)/\\(.+\\)/kako/[0-9/]+/\\([0-9]+\.html\\)$")
#|
(defvar *thread-kako-cgi-regexp*
  "^http://\\([^/]+\\)/\\([^/]+/\\)?test/read.cgi\\?bbs=\\([-0-9a-zA-Z_]+\\)&key=\.\./kako/[0-9][0-9][0-9]/\\([0-9]+\\)")
|#
(defvar *thread-kako-cgi-regexp*
  "^http://\\([^/]+\\)/\\(.*/\\)?test/read.cgi\\?bbs=\\([-0-9a-zA-Z_]+\\)&key=\.\./kako/[0-9][0-9][0-9]/\\([0-9]+\\)")

(defvar *special-string-list* '(("<[Bb][Rr]> ?" . "\n ")
				("<hr>" . "\n")
				("</?[bB]> ?" . "")
				("＠｀" . ",")
				("&amp;" . "&")
				("&quot;" . "\"")
				("&lt;" . "<")
				("&gt;" . ">")
				("&amp" . "&")
				("&nbsp;" . " ")
				("&nbsp" . " ")
			       ))

(defun thread-parse-special-strings (body)
  (dolist (sp *special-string-list*)
    (setq body (substitute-string body (car sp) (cdr sp))))
  body)

(defvar *buffer-archive* "2ch: Archive")

(defun thread-load-archive ()
  (when (file-exist-p *thread-archive-file*)
    (save-excursion
      (set-buffer (get-buffer-create *buffer-archive*))
      (setq need-not-save t)
      (erase-buffer (selected-buffer))
      (insert (format nil "~{~A~%~}"
		      (mapcar #'car (list-archive *thread-archive-file*)))))))

(defun thread-archive-exist (file)
  (when (find-buffer *buffer-archive*)
    (save-excursion
      (set-buffer *buffer-archive*)
      (goto-char (point-min))
      (scan-buffer file))))

(defun thread-archive-board-files (host path)
  (unless (find-buffer *buffer-archive*)
    (return-from thread-archive-board-files))
  (let* ((dir (thread-dir host path))
	 (regexp (format nil "^~A\\([0-9]+\.dat\\)$" dir))
	 files)
    (save-excursion
      (set-buffer *buffer-archive*)
      (goto-char (point-min))
      (while (scan-buffer regexp
			  :regexp t
			  :tail t)
	(push (match-string 1) files)))
    (nreverse files)))

(defun thread-get-archive (host path dat)
  (let ((file (thread-path-data host path dat))
	(dir-data (thread-dir-data host path dat))
	(tbk-data (thread-dir-tbk host path dat)))
    (when (file-exist-p *thread-archive-file*)
      ;(msgbox "search: ~A" dir-data)
      (when (thread-archive-exist dir-data)
	;(msgbox "exist: ~A" dir-data)
	(if (thread-archive-exist tbk-data)
	    (extract-archive *thread-archive-file*
			     *base-directory*
			     dir-data
			     tbk-data)
	  (extract-archive *thread-archive-file*
			   *base-directory*
			   dir-data))
	(file-exist-p file)))))

(defun thread-get (host path dat &optional force)
  (interactive)
  (let ((kako-p (thread-dat-kako-p dat))
	(read-cgi-p (read-cgi-host-p host))
	(file (thread-path-data host path dat))
	url)
    (long-operation
      (if (and (read-cgi-host-p host)
	       (not (thread-dat-kako-p dat)))
	  (progn
	    (setq url (thread-url-read-cgi host path dat))
	    (handler-case
		(http-get-thread url
				 file
				 force
				 :append *thread-get-diff*
				 :compare *thread-get-diff*
				 ;:referer (form-url-referer host path)
				 ;:referer (thread-cgi-url host path)
				 :referer url
				 :lines (and (not force)
					     *thread-max-lines*))
	      (error (c)
		(let ((msg (si:*condition-string c)))
		  (if msg
		      (cond ((and kako-p
				  (string-match "-ERR 過去ログ倉庫で発見 ../[^/]+/kako/[0-9]+\\(/[0-9]+\\)?/[0-9]+.dat\\(.gz\\)?" msg))
			     (http-get (thread-url-data-kako-html host path dat (match-beginning 1))
				       file
				       force
				       :append *thread-get-diff*
				       :compare *thread-get-diff*
				       :lines (and (not force)
						   *thread-max-lines*)))
			    ((and *2ch-use-dolib*
				  (string-match "-ERR html化待ち" msg))
			     (setq url (thread-url-offlaw-cgi host path dat))
			     (http-get-thread-offlaw url
						     file
						     force
						     :append *thread-get-diff*
						     :compare *thread-get-diff*
						     ;:referer (form-url-referer host path)
						     ;:referer (thread-cgi-url host path)
						     :referer url
						     :lines (and (not force)
								 *thread-max-lines*)))
			    (t
			     (error "~A" msg)))
		    (error "~S" msg))))))
	(progn
	  (setq url (thread-url-data host path dat))
	  (handler-case
	      (http-get url
			file
			force
			:append *thread-get-diff*
			:compare *thread-get-diff*
			:lines (and (not force)
				    *thread-max-lines*))
	    (error (c)
	      (let ((msg (si:*condition-string c)))
		(if msg
		    (cond ((and *2ch-use-dolib*
				(string-matchp "status: 302" msg)) ; html化待ちを見てみる
			   (setq url (thread-url-offlaw-cgi host path dat))
			   (http-get-thread-offlaw url
						   file
						   force
						   :append *thread-get-diff*
						   :compare *thread-get-diff*
						   :referer url
						   :lines (and (not force)
							       *thread-max-lines*)))
			  (t
			   (error "~S" msg)))
		  (error "~S" msg)))))))
      )))

(defun thread-buffer-name (host path title dat)
  (format nil "~A: [~A] ~A" *buffer-thread* title (thread-path-data host path dat)))

(defun set-buffer-thread (board host path title dat num)
  (let* ((bufname (thread-buffer-name host path title dat))
	 (buf (find-buffer bufname)))
    (if buf
	(set-buffer bufname)
      (progn
	(set-buffer (get-buffer-create bufname))
	(thread-mode)
      ))
    (setq thread-board board)
    (setq thread-host host)
    (setq thread-path path)
    (setq thread-title title)
    (setq thread-dat dat)
    (setq thread-num num)
    (unless buf
      (thread-bar-add bufname))
    (thread-bar-select)
  ))

(defun thread-mode ()
  (setq buffer-mode '2ch-thread)
  (setq mode-name *mode-name*)
  (make-local-variable 'thread-board)
  (setq thread-board nil)
  (make-local-variable 'thread-host)
  (setq thread-host nil)
  (make-local-variable 'thread-path)
  (setq thread-path nil)
  (make-local-variable 'thread-title)
  (setq thread-title nil)
  (make-local-variable 'thread-dat)
  (setq thread-dat nil)
  (make-local-variable 'thread-tbk)
  (setq thread-tbk nil)
  (make-local-variable 'thread-buffer-parent)
  (setq thread-buffer-parent nil)
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
  (use-keymap *thread-map*)
  (run-hooks '*thread-mode-hook*))

(defun thread-next-page ()
  (interactive)
  (if (pos-visible-in-window-p (point-max))
      (progn
	(thread-quit)
	(forward-line 1))
    (next-page)))

(defun thread-previous-page ()
  (interactive)
  (if (pos-visible-in-window-p (point-min))
      (thread-quit)
    (previous-page)))

(defvar *thread-next-article-obstinacy* nil) 

(defun thread-next-article-obstinacy ()
  (interactive)
  (thread-next-article t))

(defun thread-next-article (&optional obstinacy)
  (interactive) 
  (let ((po (find-text-attribute 'number
				 :start (1+ (point)))))
    (if (and po
	     (or obstinacy
		 *thread-next-article-obstinacy*
		 (pos-visible-in-window-p po)))
	(progn
	  (goto-char po)
	  (recenter 0))
      (if (pos-visible-in-window-p (point-max))
	  (thread-quit)
	(next-page)))))

(defun thread-previous-article ()
  (interactive)
  (let ((po (find-text-attribute 'number
				 :end (1- (point))
				 :from-end t)))
    (if po
	(progn
	  (goto-char po)
	  (recenter 0))
      (if (pos-visible-in-window-p (point-min))
	  (thread-quit)
	(previous-page)))))

(defun thread-next-tag ()
  (interactive)
  (let (pos)
    (dolist (tag '(link anchor number))
      (let ((p (find-text-attribute tag
				    :start (1+ (point)))))
	(when p
	  (if pos
	      (when (< p pos)
		(setq pos p))
	    (setq pos p)))))
    (when pos
      (goto-char pos))))

(defun thread-previous-tag ()
  (interactive)
  (let (pos)
    (dolist (tag '(link anchor number))
      (let ((p (find-text-attribute tag
				    :end (1- (point))
				    :from-end t)))
	(when p
	  (if pos
	      (when (< pos p)
		(setq pos p))
	    (setq pos p)))))
    (when pos
      (goto-char pos))))

(defun thread-quit ()
  (interactive)
  (let ((parent (or thread-buffer-parent
		    (board-buffer-name thread-board
				       thread-host
				       thread-path))))
    (thread-tbk-save)
    (if (and parent
	     (find-buffer parent))
	(progn
	  (split-2)
	  (set-buffer parent))
      (progn
	(thread-bar-del)
	(delete-buffer (selected-buffer))))
    (setq *thread-window* nil)))

(defun thread-history-push ()
  (push (list (point) (buffer-name (selected-buffer)))
	*thread-history*))

(defun thread-history-pop ()
  (pop *thread-history*))

(defun thread-history-back ()
  (interactive)
  (let ((history (thread-history-pop)))
    (when history
      (set-buffer (thread-history-buffer history))
      (thread-bar-select)
      (goto-char (thread-history-point history)))))

(defun thread-history-clear ()
  (setq *thread-history* nil))

(defun thread-aborn-add (&optional number)
  (interactive)
  (when (setq number (or number (thread-current-number)))
    (thread-tbk-add-aborn number)
    (thread-tbk-write)
    (message "~A: ~D" *thread-aborn-string* number)))

(defun thread-aborn-add-range ()
  (interactive)
  (let (articles)
    (multiple-value-bind (beg end)
	(thread-get-range)
      (when (and beg end)
	(let ((i beg))
	  (while (<= i end)
	    (thread-aborn-add i)
	    (incf i)))))))

(defun thread-article-abornize (article)
  (list *thread-aborn-string*
	*thread-aborn-string*
	(thread-line-date article)
	*thread-aborn-string*))

(defun thread-aborn-del (&optional number)
  (interactive)
  (when (setq number (or number (thread-current-number)))
    (thread-tbk-del-aborn number)
    (thread-tbk-write)
    (message "~A解除: ~D" *thread-aborn-string* number)))

(defun thread-tbk-set-value (key val)
  (if (tbk-assoc thread-tbk key)
      (setf (tbk-value thread-tbk key) val)
    (push (cons key val) thread-tbk)))

(defun thread-tbk-set-point (point)
  (thread-tbk-set-value 'point point))

(defun thread-tbk-set-aborn (aborn)
  (thread-tbk-set-value 'aborn aborn))

(defun thread-tbk-set-name (name)
  (thread-tbk-set-value 'name name))

(defun thread-tbk-set-addr (addr)
  (thread-tbk-set-value 'addr addr))

(defun thread-aborn-p (number)
  (member number (tbk-aborn thread-tbk)))

(defun thread-tbk-add-aborn (number)
  (let ((aborn (tbk-aborn thread-tbk)))
    (pushnew number aborn)
    (thread-tbk-set-aborn (sort aborn #'<))))

(defun thread-tbk-del-aborn (number)
  (let ((aborn (tbk-aborn thread-tbk)))
    (thread-tbk-set-aborn (delete number aborn))))

(defun thread-tbk-file ()
  (thread-path-tbk thread-host
		   thread-path
		   thread-dat))

(defun thread-tbk-back ()
  (let ((point (tbk-point thread-tbk)))
    (when point
      (goto-char point))))

(defun thread-tbk-load (&optional file)
  (setq thread-tbk (thread-tbk-read file)))

(defun thread-tbk-read (&optional file)
  (setq file (or file (thread-tbk-file)))
  (let (tbk tmp)
    (when (file-exist-p file)
      (with-open-file (s file
			 :direction :input)
	(while (setq tmp (read s nil))
	  (and (listp tmp)
	       (push tmp tbk)))))
    (nreverse tbk)))

(defun thread-tbk-save ()
  (thread-tbk-set-point (point))
  (thread-tbk-write))

(defun thread-tbk-write (&optional file)
  (setq file (or file (thread-tbk-file)))
  (with-open-file (s file
		     :direction :output
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" thread-tbk)))

(defun thread-tracking-add (&optional dialog)
  (interactive)
  (when (and thread-board thread-host thread-path thread-dat thread-title thread-num)
    (when (tracking-add (list thread-board thread-host thread-path thread-dat thread-title thread-num)
			nil
			nil
			dialog)
      (message "~Aに\"~A\"を追加しました。" *tracking-name* thread-title))))

(defun thread-tracking-add-dialog ()
  (interactive)
  (thread-tracking-add t))

(defun thread-delete-dat-files (track-list &optional archive tbk)
  (let ((arc-p (and archive
		    (file-exist-p *thread-archive-file*)))
	tmp)
    (dolist (track track-list)
      (let* ((host (tracking-list-host track))
	     (path (tracking-list-path track))
	     (dat (tracking-list-dat track))
	     (dat-file (thread-path-data host path dat))
	     (tbk-file (thread-path-tbk host path dat))
	     (dir-data (thread-dir-data host path dat))
	     (tbk-data (thread-dir-tbk host path dat)))
	(when (file-exist-p dat-file)
	  (delete-file dat-file :recycle *thread-delete-dat-recycle*)
	  (message "2ch: delete ~A" dat-file))
	(when (and tbk
		   (file-exist-p tbk-file))
	  (delete-file tbk-file :recycle *thread-delete-tbk-recycle*)
	  (message "2ch: delete ~A" tbk-file))
	(when arc-p
	  (when (thread-archive-exist dir-data)
	    (push dir-data tmp))
	  (when (and tbk
		     (thread-archive-exist tbk-data))
	    (push tbk-data tmp)))))
    (when tmp
      (apply 'delete-file-in-archive *thread-archive-file* tmp)
      (message "2ch: delete ~D file~P in ~A"
	       (list-length tmp)
	       (list-length tmp)
	       *thread-archive-file*)
      (thread-load-archive))))

(defun thread-delete-dat (track &optional archive tbk)
  (thread-delete-dat-files (list track) archive tbk))

#|
(defun thread-delete-dat (host path dat &optional archive tbk)
  (let ((dat-file (thread-path-data host path dat))
	(tbk-file (thread-path-tbk host path dat))
	(dir-data (thread-dir-data host path dat))
	(tbk-data (thread-dir-tbk host path dat))
	(archive-modified nil))
    (when (file-exist-p dat-file)
      (delete-file dat-file :recycle *thread-delete-dat-recycle*)
      (message "2ch: delete ~A" dat-file))
    (when (and tbk
	       (file-exist-p tbk-file))
      (delete-file tbk-file :recycle *thread-delete-tbk-recycle*)
      (message "2ch: delete ~A" tbk-file))
    (when (and archive
	       (file-exist-p *thread-archive-file*))
      (when (thread-archive-exist dir-data)
	(delete-file-in-archive *thread-archive-file* dir-data)
	(setq archive-modified t)
	(message "2ch: delete in ~A: ~A" *thread-archive-file* dir-data))
      (when (and tbk
		 (thread-archive-exist tbk-data))
	(delete-file-in-archive *thread-archive-file* tbk-data)
	(setq archive-modified t)
	(message "2ch: delete in ~A: ~A" *thread-archive-file* tbk-data))
      (when archive-modified
	(thread-load-archive)))))
|#

(defun thread-clean-dat (&optional noquestion)
  (interactive)
  (unless (or noquestion
	      (yes-or-no-p "~D日間開いていないスレを削除~@[+アーカイブ~]します。"
			   *thread-clean-days*
			   *thread-clean-archive*))
    (return-from thread-clean-dat))
  (let ((ctime (- (get-universal-time) (* *thread-clean-days* 24 60 60)))
	(all (mapcar #'(lambda (x)
			 (thread-path-data (tracking-list-host x)
					   (tracking-list-path x)
					   (tracking-list-dat x)))
		     (tracking-list-all)))
	(ign (list *menu-file*))
	(i 0)
	files)
    (long-operation
      (message "2ch: parsing directory ...")
      (dolist (dat (directory *base-directory*
			      :wild '("*.dat" "*.html")
			      :absolute t
			      :recursive t))
	(when (and (not (member dat ign :test #'path-equal))
		   (or *thread-clean-tracking*
		       (not (member dat all :test #'path-equal))))
	  (let* ((tbk (concat dat *thread-tbk-suffix*))
		 (exist (file-exist-p tbk))
		wtime)
	    (if exist
		(setq wtime (file-write-time tbk))
	      (setq wtime (file-write-time dat)))
	    (when (< wtime ctime)
	      (push dat files)
	      (when (and exist
			 *thread-clean-tbk*)
		(push tbk files))
	      (incf i)))))
      (when files
	(when *thread-clean-archive*
	  (message "2ch: archiving files ...")
	  (create-archive *thread-archive-file*
			  files
			  *base-directory*)
	  (thread-load-archive))
	(dolist (file files)
	  (delete-file file :recycle *thread-clean-recycle*)
	  (message "2ch: delete ~A" file))))
    (message "~Dスレ削除~@[+アーカイブ~]しました。" i *thread-clean-archive*)))

(defun thread-bar-func (buf)
  (unless (find-buffer buf)
    (thread-bar-del buf)
    (message "バッファがないっす")
    (return-from thread-bar-func))
  (unless (eq *pframe-name*
	     (ed::pseudo-frame-name ed::*current-pseudo-frame*))
    (restore))
  (unless *thread-window*
    (if *board-window*
	(progn
	  (set-window *board-window*)
	  (board-split))
      (let (parent)
	(save-excursion
	  (set-buffer buf)
	  (setq parent (or thread-buffer-parent (board-buffer-name  thread-board
								    thread-host
								    thread-path))))
	(if (find-buffer parent)
	    (progn
	      (split-2)
	      (set-buffer parent)
	      (board-split))
	  (progn
	    (message "スレ表示する窓がないっす")
	    (return-from thread-bar-func))))))
  (set-window *thread-window*)
  (when (equal buffer-mode '2ch-thread)
    (thread-tbk-save))
  (set-buffer buf)
  (refresh-screen))

(defun thread-bar ()
  (create-tab-bar 'thread-bar 'thread-bar-func)
  (mapc #'(lambda (x)
	    (let ((bufname (buffer-name x)))
	      (when (string-match (concat "^" *buffer-thread*) bufname)
		(thread-bar-add bufname))))
	(buffer-list)))

(defun thread-bar-clear ()
  (when (tool-bar-exist-p 'thread-bar)
    (let ((items (tab-bar-list-items 'thread-bar)))
      ; あらかじめ最後のタブを選択しておく。
      ; でないと選択したのを消した時に他のタブが選択されて関数が呼ばれてしまう。
      (tab-bar-select-item 'thread-bar (car (reverse items)))
      (dolist (item items)
	(tab-bar-delete-item 'thread-bar item))
      (refresh-screen))))

(defun thread-bar-create ()
  (define-command-bar 'thread-bar "2ch(&C)")
  (when *thread-bar-show*
    (show-command-bar 'thread-bar))
  (refresh-screen))

(defun thread-bar-add (&optional bufname)
;  (format *error-output* "2ch: thread-bar-add: ~S~%" bufname)
;  (format *error-output* "~{\t~S~%~}" (tab-bar-list-items 'thread-bar))
  (when (tool-bar-exist-p 'thread-bar)
    (setq bufname (or bufname (buffer-name (selected-buffer))))
    (let ((title (thread-bar-name bufname)))
;      (unless (tab-bar-find-item 'thread-bar bufname)   ; <= なんかよくわからんけどうまくいかん
      (unless (thread-bar-exist-p bufname)
;	(format *error-output* "2ch: thread-bar-add: not found! ~S~%" bufname)
	(tab-bar-add-item 'thread-bar bufname (thread-bar-title title) title)))))

(defun thread-bar-del (&optional bufname)
;  (format *error-output* "2ch: thread-bar-del: ~S~%" bufname)
;  (format *error-output* "~{\t~S~%~}" (tab-bar-list-items 'thread-bar))
  (when (tool-bar-exist-p 'thread-bar)
    (setq bufname (or bufname (buffer-name (selected-buffer))))
;    (when (tab-bar-find-item 'thread-bar bufname)   ; <= なんかよくわからんけどうまくいかん
     (when (thread-bar-exist-p bufname)
;      (format *error-output* "2ch: thread-bar-del: found! ~S~%" bufname)
      (tab-bar-delete-item 'thread-bar bufname))))

(defun thread-bar-exist-p (bufname)
  (member bufname (tab-bar-list-items 'thread-bar)
	  :test #'equal))

(defun thread-bar-select (&optional bufname)
  (when (tool-bar-exist-p 'thread-bar)
    (setq bufname (or bufname (buffer-name (selected-buffer))))
    (tab-bar-select-item 'thread-bar bufname)))

(defun thread-bar-name (bufname)
  (save-excursion
    (set-buffer bufname)
    thread-title))

(defun thread-bar-title (name)
  (abbreviate-display-string name *thread-bar-title-length*))

(defun thread-buffer-select-dialog()
  (let (buflist)
    (mapc #'(lambda (x)
	      (when (string-match (concat "^" *buffer-thread*)
				  (buffer-name x))
		(push (cons (thread-bar-name x) x) buflist)))
	  (buffer-list))
    (multiple-value-bind (result data)
	(dialog-box '(dialog 0 0 186 162
		      (:caption "スレの選択")
		      (:font 9 "ＭＳ Ｐゴシック")
		      (:control
		       (:listbox list nil #x50b10111 7 7 116 148)
		       (:button IDOK "OK" #x50010001 129 7 50 14)
		       (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 129 24 50 14)))
		    (list (cons 'list (reverse buflist)))
		    '((list :column (38) :must-match t :enable (IDOK))))
      (when result
	(cdr (assoc 'list data))))))

(defun thread-buffer-select ()
  (interactive)
  (let ((buf (cdr (thread-buffer-select-dialog))))
    (when (and buf
	       (find-buffer (buffer-name buf)))
      (thread-tbk-save)
      (set-buffer buf))))

(defun thread-bookmark-add-pos ()
  (interactive)
  (thread-bookmark-add t))

(defun thread-bookmark-add (&optional pos)
  (interactive)
  (let ((bookmark (thread-bookmark-get pos)))
    (when bookmark
      (bookmark-add bookmark))))

(defun thread-bookmark-get (&optional pos)
  (let ((board thread-board)
	(host thread-host)
	(path thread-path)
	(title thread-title)
	(dat thread-dat)
	(point (and pos (point)))
	category)
    (when (and thread-buffer-parent
	       (find-buffer thread-buffer-parent))
      (save-excursion
	(set-buffer thread-buffer-parent)
	(cond ((equal buffer-mode '2ch-tracking)
	       (setq board board-name
		     host nil
		     path nil))
	      (t
	       nil))))
    (when (setq category (menu-category (list board host path)))
      (list category
	    board
	    host
	    path
	    title
	    dat
	    point))))

;;;
;;; Thread Popup Mode
;;;
(defvar *thread-anchor-region-beg* nil)
(defvar *thread-anchor-region-end* nil)

(define-key *thread-map* #\M-m 'thread-popup-mode)

(defvar-local *thread-popup-mode* nil)

(defvar *thread-popup-map* nil)
(unless *thread-popup-map*
  (setq *thread-popup-map* (make-sparse-keymap))
  (define-key *thread-popup-map* #\MouseMove 'thread-anchor-mouse-popup)
)

(defun thread-popup-mode (&optional (arg nil sv))
  (interactive)
  (ed::toggle-mode '*thread-popup-mode* arg sv)
  (update-mode-line t)
  (require-mouse-move *thread-popup-mode*)
  (if *thread-popup-mode*
      (set-minor-mode-map *thread-popup-map*)
    (unset-minor-mode-map *thread-popup-map*))
  t)

(pushnew '(*thread-popup-mode* . "Popup") *minor-mode-alist* :key #'car)

(defun thread-anchor-mouse-popup ()
  (interactive)
  (let ((w (selected-window)))
    (continue-pre-selection)
    (unless (equal w *last-mouse-window*)
      ;(msgbox "~S~%~S" w *last-mouse-window*)
      (return-from thread-anchor-mouse-popup))
    (unwind-protect
	(progn
	  (set-window *last-mouse-window*)
	  (save-excursion
	    (goto-last-mouse-point)
	    (cond ((eolp)
		   (setq *thread-anchor-region-beg* nil))
		  ((and *thread-anchor-region-beg*
			(<= *thread-anchor-region-beg* (point) *thread-anchor-region-end*))
		   (continue-popup))
		  (t
		   (multiple-value-bind (beg end start stop)
		       (thread-anchor-get-range)
		     (if (and beg end start stop)
			 (let (articles
			       (str ""))
			   (setq *thread-anchor-region-beg* start)
			   (setq *thread-anchor-region-end* stop)
			   (setq articles (thread-get-articles beg end))
			   (if articles
			       (progn
				 (dolist (article articles)
				   (setq str
					 (concat str (thread-article-popup-string article))))
				 (popup-string str (point)))
			     (setq *thread-anchor-region-beg* nil)))
		       (setq *thread-anchor-region-beg* nil))))
	    );cond
	  ))
      (set-window w))))

(defun thread-board-rule-force ()
  (interactive)
  (thread-board-rule t))

(defun thread-board-rule (&optional force reload)
  (interactive)
  (board-rule-show thread-board
		   thread-host
		   thread-path
		   force
		   reload))
