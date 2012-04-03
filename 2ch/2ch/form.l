; $Id: form.l 699 2006-06-01 03:20:55Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(require "2ch/http")

(provide "2ch/form")

(in-package "2ch")

(defvar *form-height* t)

(defvar *form-name* nil)
(defvar *form-email* nil)

(defvar *form-name-list* nil)
(defvar *form-email-list* nil)

(defvar *buffer-form* "2ch: Form")

(defvar *form-address-auto-save* t)
(defvar *form-update-after-post* t)

(defvar *form-color-board* 0)
(defvar *form-color-title* 0)
(defvar *form-color-header* 0)
(defvar *form-color-name* 0)
(defvar *form-color-email* 0)

(defvar *form-cite-string* "> ")

(defvar *form-create-hook* nil)
(defvar *form-mode-hook* nil)
(defvar *form-new-mode-hook* nil)

(defvar *form-text-submit* (url-encode "書き込む"))
(defvar *form-text-submit-new* (url-encode "新規書き込み"))
(defvar *form-line* "--- ")

(defvar *form-map* (copy-keymap *text-mode-map*))
(define-key *form-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *form-map* #\TAB 'form-complete-menu)
(define-key *form-map* '(#\C-c #\C-c) 'form-post)
(define-key *form-map* '(#\C-c #\C-s) 'form-post-sage)
(define-key *form-map* '(#\C-c #\s) 'form-sage)
(define-key *form-map* '(#\C-c #\C-y) 'form-cite-yank)
(define-key *form-map* '(#\C-c #\C-v) 'form-cite-paste)
(define-key *form-map* '(#\C-c #\a) 'form-name-add)
(define-key *form-map* '(#\C-c #\m) 'form-addr-add)
(define-key *form-map* '(#\C-c #\q) 'form-delete)
(define-key *form-map* '(#\C-c #\b) 'form-back)
(define-key *form-map* '(#\C-c #\p) 'form-preview)
(define-key *form-map* '(#\C-c #\P) 'form-preview-all)
(define-key *form-map* '(#\C-c #\v) 'view-show)
(define-key *form-map* '(#\C-c #\A) 'form-body-convert)
(define-key *form-map* '(#\C-x #\C-s) 'form-save)
(define-key *form-map* #\M-Right 'form-article-saved-next)
(define-key *form-map* #\M-Left 'form-article-saved-previous)
(define-key *form-map* '(#\C-c #\d) 'form-article-current-del)
(define-key *form-map* '(#\C-c #\r) 'form-board-rule)
(define-key *form-map* '(#\C-c #\R) 'form-board-rule-force)
(define-key *form-map* #\M-t 'toggle-online)

(defvar *form-new-map* (copy-keymap *form-map*))
(define-key *form-new-map* '(#\C-c #\C-c) 'form-post-new)
(define-key *form-new-map* '(#\C-c #\C-s) 'form-post-new-sage)
(define-key *form-new-map* '(#\C-x #\C-s) 'form-save-new)
(define-key *form-new-map* #\M-Right 'form-article-saved-new-next)
(define-key *form-new-map* #\M-Left 'form-article-saved-new-previous)
(define-key *form-new-map* '(#\C-c #\d) 'form-article-current-del-new)

(defvar *form-post-url* "../test/bbs.cgi")
(defvar *form-referer* "index2.html")

(defun set-form-window ()
  (let (win)
    (if (and (find-buffer *buffer-form*)
	     (setq win (get-buffer-window *buffer-form*)))
	(set-window win)
      (when *form-height*
	(if (integerp *form-height*)
	    (split-window *form-height*)
	  (split-window (- (floor (window-height) 2) 2)))
	(other-window 1)))))

(defun set-form-buffer ()
  (set-form-window)
  (set-buffer (get-buffer-create *buffer-form*)))

(defun form-url-post (host path)
  (www::www-url-merge-path (board-url host path)
			   *form-post-url*))

(defun form-url-referer (host path)
  (concat (board-url host path) *form-referer*))

(defun form-bbs (path)
  (when (string-match "\\([^/]+\\)/$" path)
    (substring path (match-beginning 1) (match-end 1))))

(defun form-key (dat)
  (let (key ext)
    (when (string-match "^\\([0-9]+\\)\.\\(dat\\|html\\)$" dat)
      (setq key (match-string 1)))
    (or key "")))

#|
(defun form-key (dat)
  (let (key ext)
    (when (string-match "^\\([0-9]+\\)\.\\(dat\\|html\\)$" dat)
      (setq key (match-string 1))
      (setq ext (match-string 2))
      (cond ((equal ext "dat")
	     key)
	    ((equal ext "html")
	     (concat "../kako/ " (thread-kako-prefix-dir dat) "/" key))
	    (t
	     "")))))
|#

(defvar *latest-post-time* nil)
(defvar *diff-post-time* (* 60 5))

(defun form-time ()
  (let ((uni (encode-universal-time 0 0 0 1 1 1970))
	(diff *diff-post-time*)
	now) 
     (if (and *latest-post-time*
	      (setq now (parse-header-date *latest-post-time*)))
	 (- now uni (* 60 60 9) diff)
       (- (get-universal-time) uni (* 60 60 9) diff))))

(defun form-mode-base ()
  (kill-all-local-variables)
  (make-local-variable 'form-board)
  (setq form-board nil)
  (make-local-variable 'form-host)
  (setq form-host nil)
  (make-local-variable 'form-path)
  (setq form-path nil)
  (make-local-variable 'form-title)
  (setq form-title nil)
  (make-local-variable 'form-dat)
  (setq form-dat nil)
  (make-local-variable 'form-buffer-parent)
  (setq form-buffer-parent nil)
  (make-local-variable 'form-window-parent)
  (setq form-window-parent nil)
  (make-local-variable 'form-article-current)
  (setq form-article-current nil)
  (make-local-variable 'form-article-data)
  (setq form-article-data nil)
  (make-local-variable 'form-article-data-point)
  (setq form-article-data-point 0)
  (make-local-variable 'title-bar-format)
  (setq title-bar-format (format nil "~A - %b" *version-name*))
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (setq need-not-save t)
  (setq auto-save nil)
  (set-buffer-fold-width nil))

(defun form-mode ()
  (form-mode-base)
  (setq buffer-mode '2ch-form)
  (setq mode-name *mode-name*)
  (use-keymap *form-map*)
  (run-hooks '*form-mode-hook*))

(defun form-new-mode ()
  (form-mode-base)
  (setq buffer-mode '2ch-form-new)
  (setq mode-name *mode-name*)
  (use-keymap *form-new-map*)
  (run-hooks '*form-new-mode-hook*))

(defun form-post-sage (&optional noquestion)
  (interactive)
  (form-sage)
  (refresh-screen)
  (form-post noquestion))

(defun form-thread-exist-check (host path dat)
  (when (thread-dat-kako-p dat)
    (error "過去ログには書き込めまへん"))
  (let ((url (thread-url-data host path dat))
	(result nil))
    (multiple-value-bind (status header)
	(http-head url)
      (setq result (and (stringp status)
			(string-match "^200" status)))
      (values result status header))))

(defun form-post (&optional noquestion)
  (interactive)
  (unless (or noquestion
	      (yes-or-no-p "書き込む？"))
    (return-from form-post))
  (multiple-value-bind (result status header)
      (form-thread-exist-check form-host
			       form-path
			       form-dat)
    (unless result
      (error "スレッドがなくなってるみたいっす~%~%~A" (http-error-string status header))))
  (let (post
	cookie
	(pos form-article-data-point)
	(url (form-url-post form-host form-path))
	(ref (form-url-referer form-host form-path))
	(bbs (form-bbs form-path))
	(key (form-key form-dat))
	save-data)
    (multiple-value-bind (subject name email body)
	(form-get-values)
      (setq post (form-format-post-vars name email body bbs :key key))
      (setq cookie (form-format-cookie-vars name email)))
    (setq save-data (form-save-data))
;    (let ((test (split-string post "&"))
;	  tmp
;	  str)
;      (setq str (format nil "URL:~A~%REF:~A~%COOKIE:~A~%~%" url ref cookie))
;      (dolist (tmp test)
;	(setq str (format nil "~A~A~%" str tmp)))
;      (message-box str))
;    (return-from form-post)
    (when (http-post url
		     :post post
		     :referer ref
		     :cookie cookie)
      (form-save-post save-data)
      (http-quit)
      (when (and *form-update-after-post*
		 (= pos 0))
	(form-thread-update))
    )))

(defun form-thread-update ()
  (let (buf
	host
	path
	dat)
    (save-excursion
      (set-buffer *buffer-form*)
      (setq buf form-buffer-parent
	    host form-host
	    path form-path
	    dat form-dat))
    (when (and buf
	       (find-buffer buf))
      (set-buffer buf)
      (when (and (equal buffer-mode '2ch-thread)
		 (equal host thread-host)
		 (equal path thread-path)
		 (equal dat thread-dat))
	(thread-update)))))

(defun form-save-post-new (data)
  (form-save data *form-file-post-new*))

(defun form-save-post (data)
  (form-save data *form-file-post*))

(defun form-save-new ()
  (interactive)
  (form-save (form-save-data) *form-file-save-new*))

(defun form-save-data ()
  (multiple-value-bind (subject name email body)
      (form-get-values)
    (list (get-universal-time)
	  form-board
	  form-host
	  form-path
	  form-dat
	  subject
	  name
	  email
	  body)))

(defun form-save (&optional data file)
  (interactive)
  (setq data (or data (form-save-data)))
  (setq file (or file *form-file-save*))
  (with-open-file (s file
		     :direction :output
		     :if-exists :append
		     :if-does-not-exist :create)
    (format s "~S~%" data))
  (when *form-address-auto-save*
    (form-save-name-addr data))
  (message "保存しました。"))

(defun form-write (data &optional file)
  (setq file (or file *form-file-save*))
  (with-open-file (s file
		     :direction :output
		     :if-exists :supersede
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" data)))

(defun form-preview-all ()
  (interactive)
  (let ((data (form-save-data)))
    (message-box
     (thread-parse-special-strings
      (format nil "~D [~A] ~A~A~A~%[~A] \"~A\" <~A>~%~%~A"
	      form-article-data-point
	      (form-data-board data)
	      (form-data-host data)
	      (form-data-path data)
	      (form-data-dat data)
	      (form-data-subject data)
	      (form-data-name data)
	      (form-data-addr data)
	      (form-data-body data)))
     (format nil "[~A]" (form-data-board data)))))

(defun form-preview ()
  (interactive)
  (let ((data (form-save-data)))
    (message-box
     (thread-parse-special-strings
      (format nil "[~A] \"~A\" <~A>~%~%~A"
	      (form-data-subject data)
	      (form-data-name data)
	      (form-data-addr data)
	      (form-data-body data)))
     (format nil "[~A]" (form-data-board data)))))

(defun form-article-current-store ()
  (setq form-article-current (form-save-data)))

(defun form-article-saved-new-previous ()
  (interactive)
  (form-load-saved-new)
  (form-article-previous t))

(defun form-article-saved-new-next ()
  (interactive)
  (form-load-saved-new)
  (form-article-next t))

(defun form-article-saved-previous ()
  (interactive)
  (form-load-saved)
  (form-article-previous))

(defun form-article-saved-next ()
  (interactive)
  (form-load-saved)
  (form-article-next))

(defun form-article-previous (&optional newp)
  (unless form-article-data
    (return-from form-article-previous))
  (let ((max (list-length form-article-data))
	(pos form-article-data-point))
    (when (< pos max)
      (when (= pos 0)
	(form-article-current-store))
      (incf pos)
      (form-set-article (form-article-data-point pos) newp)
      (setq form-article-data-point pos))))

(defun form-article-next (&optional newp)
  (unless form-article-data
    (return-from form-article-next))
  (let ((pos form-article-data-point))
    (when (< 0 pos)
      (decf pos)
      (form-set-article (form-article-data-point pos) newp)
      (setq form-article-data-point pos))))

(defun form-article-data-point (pos)
  (if (= pos 0)
      form-article-current
    (nth (1- pos) (reverse form-article-data))))

(defun form-article-current-del ()
  (interactive)
  (when (= 0 form-article-data-point)
    (return-from form-article-current-del))
  (form-article-del form-article-data-point
		    *form-file-save*))

(defun form-article-current-del-new ()
  (interactive)
  (when (= 0 form-article-data-point)
    (return-from form-article-current-del-new))
  (form-article-del form-article-data-point
		    *form-file-save-new*
		    t))

(defun form-article-del (num file &optional newp)
  (unless (yes-or-no-p "この発言を削除しますか？")
    (return-from form-article-del))
  (let ((old (reverse form-article-data))
	new
	(pos form-article-data-point))
    (dotimes (i (list-length old))
      (unless (= i (1- num))
	(push (nth i old) new)))
    ;(msgbox "~S~%~%~{~S~%~}~%~%~{~S~%~}" file form-article-data new)
    (setq form-article-data new)
    (decf pos)
    (form-write form-article-data file)
    (form-set-article (form-article-data-point pos) newp)
    (setq form-article-data-point pos)))

(defun form-set-article (data &optional newp)
  (let ((parent form-buffer-parent)
	(winconf form-window-parent)
	(current form-article-current)
	(article form-article-data))
    (form-create (form-data-board data)
		 (form-data-host data)
		 (form-data-path data)
		 (if newp
		     nil
		   (form-data-subject data))
		 (form-data-dat data))
    (form-set-name (form-data-name data))
    (form-set-addr (form-data-addr data))
    (when newp
      (form-set-subject (form-data-subject data)))
    (setq form-buffer-parent parent)
    (setq form-window-parent winconf)
    (setq form-article-current current)
    (setq form-article-data article)
    (goto-char (point-max))
    (insert (form-data-body data))))

(defun form-load-saved (&optional force)
  (when (or force
	    (not form-article-data))
    (setq form-article-data (form-load-data *form-file-save*))))

(defun form-load-saved-new (&optional force)
  (when (or force
	    (not form-article-data))
    (setq form-article-data (form-load-data *form-file-save-new*))))

(defun form-load-data (file)
  (unless (file-exist-p file)
    (return-from form-load-data))
  (let (tmp
	line)
    (with-open-file (s file
		       :direction :input)
      (while (setq line (read s nil))
	(push line tmp)))
    (nreverse tmp)))

(defun form-post-new-sage (&optional noquestion)
  (interactive)
  (form-sage)
  (refresh-screen)
  (form-post-new noquestion))

(defun form-post-new (&optional noquestion)
  (interactive)
  (unless (or noquestion
	      (yes-or-no-p "書き込む？"))
    (return-from form-post-new))
  (let (post
	cookie
	(pos form-article-data-point)
	(url (form-url-post form-host form-path))
	(ref (form-url-referer form-host form-path))
	(bbs (form-bbs form-path)))
    (multiple-value-bind (subject name email body)
	(form-get-values)
      (when (or (not subject)
		(string-match "^[ 　\t]*$" subject))
	(error "タイトルがないっす"))
      (setq post (form-format-post-vars name email body bbs :subject subject))
      (setq cookie (form-format-cookie-vars name email)))
    (setq save-data (form-save-data))
;    (let ((test (split-string post "&"))
;	  tmp
;	  (str "この機能はまだ使えません。\n\n"))
;      (setq str (format nil "~AURL:~A~%REF:~A~%COOKIE:~A~%~%" str url ref cookie))
;      (dolist (tmp test)
;	(setq str (format nil "~A~A~%" str (si::www-url-decode tmp))))
;      (message-box str))
;    (return-from form-post-new)
    (when (http-post url
		     :post post
		     :referer ref
		     :cookie cookie)
      (form-save-post-new save-data)
      (when (and *form-update-after-post*
		 (= pos 0))
	(form-board-update)))
  ))

(defun form-board-update ()
  (let (buf
	host
	path)
    (save-excursion
      (set-buffer *buffer-form*)
      (setq buf form-buffer-parent
	    host form-host
	    path form-path))
    (when (and buf
	       (find-buffer buf))
      (set-buffer buf)
      (when (and (equal buffer-mode '2ch-board)
		 (equal host board-host)
		 (equal path board-path))
	(board-update)))))

(defun form-format-cookie-vars (name email)
  (format nil
	  "NAME=~A; MAIL=~A"
	  (url-encode (or name ""))
	  (url-encode (or email ""))))

;(defvar *form-motituke-sec* 15)

(defun form-format-post-vars (name email body bbs &key key subject)
  (let ((post "")
;	(time (- (form-time) *form-motituke-sec*)))
	(time (form-time)))
    (setq post (format nil
		       "submit=~A&FROM=~A&mail=~A&MESSAGE=~A&time=~D&bbs=~A&hana=mogera"  
		       (if subject
			   *form-text-submit-new*
			 *form-text-submit*)
		       (url-encode (or name ""))
		       (url-encode (or email ""))
		       (url-encode (or body ""))
		       time
		       bbs))
    (when key
      (setq post (concat post
			 (format nil "&key=~A" key))))
    (when subject
      (setq post (concat post
			 (format nil "&subject=~A" (url-encode subject)))))
    post))

(defun form-get-values ()
  (interactive)
  (let (subject
	name
	email
	body
	po)
    (save-excursion
      (goto-char (point-min))
      (when (setq po (find-text-attribute 'subject))
	(setq subject (buffer-substring (progn (goto-char po) (point))
					(progn (goto-eol) (point)))))
      (when (setq po (find-text-attribute 'name))
	(setq name (buffer-substring (progn (goto-char po) (point))
				     (progn (goto-eol) (point)))))
      (when (setq po (find-text-attribute 'email))
	(setq email (buffer-substring (progn (goto-char po) (point))
				      (progn (goto-eol) (point))))
	(forward-line 2)
	(setq body (buffer-substring (point) (point-max)))))
    (values subject name email body)
  ))

(defun form-complete-menu ()
  (interactive)
  (multiple-value-bind (p1 p2 tag)
      (find-text-attribute-point (point))
    (cond ((equal tag 'name)
	   (popup-form-name-menu))
	  ((equal tag 'email)
	   (popup-form-addr-menu))
	  (t
	   (insert #\TAB))
    )))

(defun popup-form-name-menu ()
  (interactive)
  (track-popup-menu (name-popup-menu-create *form-name-list*)))

(defun name-popup-menu-create (alist)
  (let ((menu (create-popup-menu nil)))
    (dolist (a alist)
      (let* ((name (car a)))
	(add-menu-item menu 'name name
		       #'(lambda () (interactive) (form-set-name name)))))
    menu))

(defun popup-form-addr-menu ()
  (interactive)
  (track-popup-menu (addr-popup-menu-create *form-email-list*)))

(defun addr-popup-menu-create (alist)
  (let ((menu (create-popup-menu nil)))
    (dolist (a alist)
      (let* ((addr (car a)))
	(add-menu-item menu 'addr addr
		       #'(lambda () (interactive) (form-set-addr addr)))))
    menu))

(defun form-sage ()
  (interactive)
  (form-set-addr "sage"))

(defun form-set-name (name)
  (let (po)
    (save-excursion
      (goto-char (point-min))
      (when (setq po (find-text-attribute 'name))
	(goto-char po)
	(insert name)
	(delete-region (point)
		       (progn (goto-eol) (point)))))))

(defun form-set-addr (addr)
  (let (po)
    (save-excursion
      (goto-char (point-min))
      (when (setq po (find-text-attribute 'email))
	(goto-char po)
	(insert addr)
	(delete-region (point)
		       (progn (goto-eol) (point)))))))

(defun form-set-subject (subject)
  (let (po)
    (save-excursion
      (goto-char (point-min))
      (when (setq po (find-text-attribute 'subject))
	(goto-char po)
	(insert subject)
	(delete-region (point)
		       (progn (goto-eol) (point)))))))

(defun form-name-list ()
  (unless *form-name-list*
    (form-load-name))
  *form-name-list*)

(defun form-save-name-addr (save-data)
  (let ((name (form-data-name save-data))
	(addr (form-data-addr save-data)))
    (save-excursion
      (set-buffer *buffer-form*)
      (when (equal name "")
	(setq name nil))
      (when (and name
		 (not (string-match "^[ 　\t\n]*$" name)))
	(form-name-add (list name)))
      (form-tbk-set-name name)
      (when (equal addr "")
	(setq addr nil))
      (when (and addr
		 (not (string-match "^[ 　\t\n]*$" addr)))
	(form-addr-add (list addr)))
      (form-tbk-set-addr addr)
    )))

(defun form-tbk-set-name (name)
  (when (and form-buffer-parent
	     (find-buffer form-buffer-parent))
    (save-excursion
      (set-buffer form-buffer-parent)
      (unless (equal buffer-mode '2ch-thread)
	(return-from form-tbk-set-name))
      (thread-tbk-set-name name)
      (thread-tbk-save))))

(defun form-name-add (&optional name)
  (interactive)
  (unless name
    (let (tmp)
      (multiple-value-bind (subject name email body)
	  (form-get-values)
	(setq tmp (read-string "Name: " :default (or name ""))))
      (when (or (not tmp)
		(string-match "^[ 　\t\n]*$" tmp))
	(return-from form-name-add))
      (setq name (list tmp))))
  (form-name-push name)
  (form-name-save))

(defun form-load-name ()
  (let (line
	names)
    (setq *form-name-list* nil)
    (when (file-exist-p *form-file-name*)
      (with-open-file (s *form-file-name*
			 :direction :input
			 :if-does-not-exist nil)
	(while (setq line (read s nil))
	  (form-name-push line))))
    (when *form-name*
      (form-name-push (list *form-name*)))))

(defun form-name-push (name)
  (unless (member name *form-name-list* :test #'equal)
    (setq *form-name-list*
	  (append *form-name-list*
		  (list name)))))

(defun form-name-save ()
  (with-open-file (s *form-file-name*
		     :direction :output
		     :if-does-not-exist :create)
    (dolist (name *form-name-list*)
      (format s "~S~%" name))))

(defun form-addr-list ()
  (unless *form-email-list*
    (form-load-addr))
  *form-email-list*)

(defun form-tbk-set-addr (addr)
  (when (and form-buffer-parent
	     (find-buffer form-buffer-parent))
    (save-excursion
      (set-buffer form-buffer-parent)
      (unless (equal buffer-mode '2ch-thread)
	(return-from form-tbk-set-addr))
      (thread-tbk-set-addr addr)
      (thread-tbk-save))))

(defun form-addr-add (&optional addr)
  (interactive)
  (unless addr
    (let (tmp)
      (multiple-value-bind (subject name email body)
	  (form-get-values)
	(setq tmp (read-string "Email: " :default (or email ""))))
      (when (or (not tmp)
		(string-match "^[ 　\t\n]*$" tmp))
	(return-from form-addr-add))
      (setq addr (list tmp))))
  (form-addr-list)
  (form-addr-push addr)
  (form-addr-save))

(defun form-load-addr ()
  (let (line)
    (setq *form-email-list* nil)
    (when (file-exist-p *form-file-email*)
      (with-open-file (s *form-file-email*
			 :direction :input
			 :if-does-not-exist nil)
	(while (setq line (read s nil))
	  (form-addr-push line))))
    (form-addr-push '("sage"))
    (when *form-email*
      (form-addr-push (list *form-email*)))))

(defun form-addr-push (addr)
  (unless (member addr *form-email-list* :test #'equal)
    (setq *form-email-list*
	  (append *form-email-list*
		  (list addr)))))

(defun form-addr-save ()
  (with-open-file (s *form-file-email*
		     :direction :output
		     :if-does-not-exist :create)
    (dolist (addr *form-email-list*)
      (format s "~S~%" addr))))

(defun form-back ()
  (interactive)
  (form-back-parent))

(defun form-delete ()
  (interactive)
  (let ((bufname (buffer-name (selected-buffer))))
    (form-back-parent)
    (delete-buffer bufname)))

(defun form-back-parent ()
  (if form-window-parent
      (set-window-configuration form-window-parent)
    (when (and form-buffer-parent
	       (find-buffer form-buffer-parent))
      (set-buffer form-buffer-parent))))

(defun form-create (board host path &optional title dat articles tbk)
  (let (start
	(bufname (buffer-name (selected-buffer)))
	(winconf (current-window-configuration)))
    (set-form-buffer)
    (form-load-name)
    (form-load-addr)
    (if title
	(form-mode)
      (form-new-mode))
    (setq form-board board
	  form-host host
	  form-path path
	  form-title title
	  form-dat dat
	  form-buffer-parent bufname
	  form-window-parent winconf)
    (erase-buffer (selected-buffer))
    (set-text-attribute (point)
			(progn
			  (insert (if title
				      "[書き込む]\n"
				    "[スレを立てる]\n"))
			  (insert (concat *form-line* "\n"))
			  (point))
			'form-title
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert "板      : ")
			  (point))
			'header-board
			:foreground *form-color-header*
			:bold t
    )
    (setq start (point))
    (set-text-attribute (point)
			(progn
			  (insert (format nil "~A~%" board))
			  (point))
			'board
			:foreground *form-color-board*
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert "タイトル: ")
			  (point))
			'header-subject
			:foreground *form-color-header*
			:bold t
    )
    (setq start (point))
    (set-text-attribute (point)
			(progn
			  (insert (format nil
					  "~A~%"
					  (thread-parse-special-strings (or title ""))))
			  (point))
			'subject
			:foreground *form-color-title*
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert "名前    : ")
			  (point))
			'header-name
			:foreground *form-color-header*
			:bold t
    )
    (when title
      (setq start (point)))
    (set-text-attribute (point)
			(progn
			  (insert (format nil "~A~%" (or (tbk-name tbk)
							 *form-name*
							 "")))
			  (point))
			'name
			:foreground *form-color-name*
    )
    (set-text-attribute (point)
			(progn
			  (insert "E-Mail  : ")
			  (point))
			'header-email
			:foreground *form-color-header*
			:bold t
    )
    (set-text-attribute (point)
			(progn
			  (insert (format nil "~A~%" (or (tbk-addr tbk)
							 *form-email*
							 "")))
			  (point))
			'email
			:foreground *form-color-email*
    )
    (insert (concat *form-line* "\n"))
    (dolist (article articles)
      (let* ((number (thread-line-number article))
	     (body (thread-line-body article))
	     (lines (split-string body "\n" t))
	     line)
	;(message-box (format nil "~S~%~S" body lines))
	(when number
	  (insert (format nil ">>~D~%" number)))
	(dolist (line lines)
	  (insert (format nil "~A~A~%" *form-cite-string* line)))
      ))
    (goto-char start)
    (run-hooks '*form-create-hook*)
  ))

(defun form-cite-yank ()
  (interactive)
  (let ((curp (point)))
    (save-excursion
      (save-restriction
	(yank)
	(when (eq (point) curp)
	  (return-from form-cite-yank))
	(narrow-to-region curp (point))
	(goto-char curp)
	(when (bolp)
	  (insert *form-cite-string*))
	(while (forward-line 1)
	  (insert *form-cite-string*))
      ))))

(defun form-cite-paste ()
  (interactive)
  (let ((curp (point)))
    (save-excursion
      (save-restriction
	(paste-from-clipboard)
	(when (eq (point) curp)
	  (return-from form-cite-paste))
	(narrow-to-region curp (point))
	(goto-char curp)
	(when (bolp)
	  (insert *form-cite-string*))
	(while (forward-line 1)
	  (insert *form-cite-string*))
      ))))

(defun form-body-convert ()
  (interactive)
  (let (pos
	beg)
    (save-excursion
      (goto-char (point-min))
      (unless (setq pos (find-text-attribute 'email))
	(error "メールの場所が見つかりまへん"))
      (goto-char pos)
      (forward-line 2)
      (when (eobp)
	(return-from form-body-convert))
      (setq beg (point))
      (untabify beg (point-max))
      (goto-char beg)
      (save-restriction
	(narrow-to-region (point) (point-max))
	(replace-regexp "^ " "&nbsp;" t)
	(goto-char beg)
	(replace-string "  " " &nbsp;" t)))))

(defun form-board-rule-force ()
  (interactive)
  (form-board-rule t))

(defun form-board-rule (&optional force reload)
  (interactive)
  (board-rule-show form-board
		   form-host
		   form-path
		   force
		   reload))
