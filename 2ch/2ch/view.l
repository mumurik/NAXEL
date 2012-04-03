; $Id: view.l 454 2005-11-28 16:37:25Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/view")

(in-package "2ch")

(shadow '(view-mode *view-mode-hook*))

(defvar *buffer-view* "2ch: View")

(defvar *view-mode-hook* nil)
(defvar *view-show-hook* nil)

(defun view-mode ()
  (setq buffer-mode '2ch-view)
  (setq mode-name *mode-name*)
  (make-local-variable 'view-data)
  (setq view-data nil)
  (make-local-variable 'view-buffer-parent)
  (setq view-buffer-parent nil)
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
  (use-keymap *view-map*)
  (run-hooks '*view-mode-hook*))

(defvar *view-map* nil)
(setq *view-map* (make-sparse-keymap))
(define-key *view-map* #\RET 'view-jump)
(define-key *view-map* #\M-Right 'view-jump)
(define-key *view-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *view-map* #\RBtnUp '2ch-mouse-right-press)
;(define-key *view-map* #\o 'view-jump-in-browser)
(define-key *view-map* #\O 'view-open-thread)
(define-key *view-map* #\M-Left 'thread-history-back)
(define-key *view-map* #\SPC 'next-page)
(define-key *view-map* #\C-h 'previous-page)
;(define-key *view-map* #\TAB 'view-next-article)
(define-key *view-map* #\M-Down 'view-next-article)
(define-key *view-map* #\M-Up 'view-previous-article)
;(define-key *view-map* #\g 'view-goto)
;(define-key *view-map* #\p 'view-anchor-popup)
;(define-key *view-map* #\P 'view-anchor-popup-msgbox)
;(define-key *view-map* #\v 'view-view-current)
;(define-key *view-map* #\V 'view-view-range)
;(define-key *view-map* #\w 'view-form)
;(define-key *view-map* #\f 'view-form-back)
(define-key *view-map* #\W 'view-create-form)
(define-key *view-map* #\D 'view-delete-current)
(define-key *view-map* #\r 'view-update)
(define-key *view-map* #\q 'view-quit)
(define-key *view-map* #\M-t 'toggle-online)
(define-key *view-map* #\Q 'exit)

(defun set-buffer-view ()
  (set-buffer (get-buffer-create *buffer-view*))
  (view-mode))

(defun view-show ()
  (interactive)
  (unless (file-exist-p *form-file-post*)
    (return-from view-show))
  (let ((parent (buffer-name (selected-buffer))))
    (set-buffer-view)
    (setq view-buffer-parent parent)
    (view-load)
    (let (line
	  (i 0)
	  (buffer-read-only nil))
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (dolist (data view-data)
	(incf i)
	(view-insert data i))
      (goto-char (point-max))
      (thread-convert-link)
    )))

(defun view-load (&optional file)
  (setq file (or file *form-file-post*))
  (unless (file-exist-p file)
    (return-from view-load))
  (let (line tmp)
    (with-open-file (f file
		       :direction :input)
      (while (setq line (read f nil))
	(push line tmp)))
    (setq view-data (nreverse tmp))))

(defun view-quit ()
  (interactive)
  (when (and view-buffer-parent
	     (find-buffer view-buffer-parent))
    (set-buffer view-buffer-parent))
  (delete-buffer *buffer-view*))

(defvar *view-date-format* "%Y/%m/%d(%v) %H:%M")

(defun view-format-date (time &optional fmt)
  (setq fmt (or fmt *view-date-format*))
  (format-date-string fmt time))

(defvar *view-fgcolor-board* 0)
(defvar *view-bgcolor-board* 14)

(defun view-insert (line i)
  (set-text-attribute (point)
		      (progn
			(insert (format nil "[~A”Â:~A]~%"
					(form-data-board line)
					(form-data-subject line)))
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
			(insert (format nil "[~A] " (view-format-date (form-data-time line))))
			(point))
		      'date
		      :foreground *thread-fgcolor-date*
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~A " (form-data-name line)))
			(point))
		      'name
		      :foreground (if (addr-sage-p (form-data-addr line))
				      *thread-fgcolor-name-sage*
				    *thread-fgcolor-name*)
		      :bold t
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "<~A>~%~%" (form-data-addr line)))
			(point))
		      'addr
		      :foreground (if (addr-sage-p (form-data-addr line))
				      *thread-fgcolor-addr-sage*
				    *thread-fgcolor-addr*)
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~{ ~A~%~}~%"
					(split-string (thread-parse-special-strings (form-data-body line))
						      "\n" t)))
			(point))
		      'body
		      :foreground *thread-fgcolor-body*
  )
)

(defun view-create-form (&optional newp)
  (interactive)
  (let ((number (thread-current-number))
	data
	(parent (buffer-name (selected-buffer))))
    (when (and number
	       (setq data (view-current-article number)))
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
      (goto-char (point-max))
      (insert (thread-parse-special-strings (form-data-body data))))))

(defun view-current-article (number)
  (nth (1- number) view-data))

(defun view-delete-current ()
  (interactive)
  (unless (yes-or-no-p "íœ‚µ‚Ü‚·‚©H")
    (return-from view-delete-current))
  (let ((number (thread-current-number)))
    (when number
      (view-delete number))))

(defun view-delete (number &optional file)
  (setq file (or file *form-file-post*))
  (let (tmp)
    (dotimes (i (list-length view-data))
      (unless (= i (1- number))
	(push (nth i view-data) tmp)))
    (setq view-data (nreverse tmp))
    (form-write view-data file)
    (view-update)))

(defun view-update ()
  (interactive)
  (let ((parent view-buffer-parent)
	(pos (point)))
    (view-show)
    (setq view-buffer-parent parent)
    (goto-char (min pos (point-max)))))

(defun view-open-thread ()
  (interactive)
  (let ((number (thread-current-number))
	article)
    (when number
      (when (setq article (view-current-article number))
	(thread-history-push)
	(thread-show (form-data-board article)
		     (form-data-host article)
		     (form-data-path article)
		     (form-data-dat article)
		     (form-data-subject article)
		     "0")))))

(defun view-jump ()
  (interactive)
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (type (attr-tag attr))
	 (curnum (thread-current-number)))
    (cond ((eq type 'anchor)
	   (let (number article)
	     (save-excursion
	       (goto-char (attr-beg attr))
	       (when (looking-at ">>\\([0-9]+\\)")
		 (setq number (parse-integer (match-string 1)))))
	     (when curnum
	       (setq article (view-current-article curnum)))
	     (when (and article number)
	       (thread-history-push)
	       (thread-show (form-data-board article)
			    (form-data-host article)
			    (form-data-path article)
			    (form-data-dat article)
			    (form-data-subject article)
			    "0")
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
	   (let (number article)
	     (save-excursion
	       (skip-chars-backward "„>0-9")
	       (when (looking-at "[„>]*\\([0-9]+\\)")
		 (setq number (parse-integer (match-string 1)))))
	     (when curnum
	       (setq article (view-current-article curnum)))
	     (when article
	       (thread-history-push)
	       (thread-show (form-data-board article)
			    (form-data-host article)
			    (form-data-path article)
			    (form-data-dat article)
			    (form-data-subject article)
			    "0")
	       (when number
		 (thread-goto-number number)))))
    )))

(defun view-next-article ()
  (interactive)
  (let ((po (find-text-attribute 'board
				 :start (1+ (point)))))
    (if (and po
	     (pos-visible-in-window-p po))
	(progn
	  (goto-char po)
	  (recenter 0))
      (unless (pos-visible-in-window-p (point-max))
	(next-page)))))

(defun view-previous-article ()
  (interactive)
  (let ((po (find-text-attribute 'board
				 :end (1- (point))
				 :from-end t)))
    (if po
	(progn
	  (goto-char po)
	  (recenter 0))
      (unless (pos-visible-in-window-p (point-min))
	(previous-page)))))
