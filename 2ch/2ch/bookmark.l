; $Id: bookmark.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(require "2ch/board")

(provide "2ch/bookmark")

(in-package "2ch")

(defvar *bookmark-list* nil)
(defvar *bookmark-point* -1)
(defvar *bookmark-clipboard* nil)

(defvar *bookmark-fgcolor-category* *board-fgcolor-name*)
(defvar *bookmark-bgcolor-category* *board-bgcolor-name*)
(defvar *bookmark-fgcolor-board* *board-fgcolor-tracking*)
(defvar *bookmark-bgcolor-board* *board-bgcolor-tracking*)
(defvar *bookmark-fgcolor-mark* *board-fgcolor-read*)
(defvar *bookmark-bgcolor-mark* *board-bgcolor-read*)
(defvar *bookmark-fgcolor-title* *board-fgcolor-title*)
(defvar *bookmark-bgcolor-title* *board-bgcolor-title*)
(defvar *bookmark-fgcolor-point* *board-fgcolor-num*)
(defvar *bookmark-bgcolor-point* *board-bgcolor-num*)

(defvar *mark-char-bookmark* "*")

(defvar *buffer-bookmark* "2ch: Bookmark")

(defvar *bookmark-map* nil)
(setq *bookmark-map* (make-sparse-keymap))
(define-key *bookmark-map* #\RET 'bookmark-select)
(define-key *bookmark-map* #\SPC 'bookmark-select)
(define-key *bookmark-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *bookmark-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *bookmark-map* #\q 'bookmark-quit)
;(define-key *bookmark-map* #\a 'bookmark-tracking-add)
;(define-key *bookmark-map* #\A 'bookmark-tracking-add-dialog)
;(define-key *bookmark-map* #\o 'bookmark-thread-open-browser)
;(define-key *bookmark-map* #\C 'bookmark-thread-url-copy)
(define-key *bookmark-map* #\d 'bookmark-delete)
(define-key *bookmark-map* #\C-k 'bookmark-cut)
(define-key *bookmark-map* #\C-y 'bookmark-paste)
(define-key *bookmark-map* #\M-t 'toggle-online)
(define-key *bookmark-map* #\Q 'exit)
(define-key *bookmark-map* #\C-M-Right 'bookmark-next)
(define-key *bookmark-map* #\C-M-Left 'bookmark-previous)

(defun bookmark-mode ()
  (tracking-mode)
  (make-local-variable 'bookmark-old-winconf)
  (setq bookmark-old-winconf nil)
  (setq buffer-mode '2ch-bookmark)
  (use-keymap *bookmark-map*))

(defun bookmark-menu (bookmark)
  (list (bookmark-board bookmark)
	(bookmark-host bookmark)
	(bookmark-path bookmark)))

(defun set-buffer-bookmark ()
  (if (find-buffer *buffer-bookmark*)
      (set-buffer *buffer-bookmark*)
    (progn
      (set-buffer (get-buffer-create *buffer-bookmark*))
      (bookmark-mode))))

(defun bookmark-quit ()
  (interactive)
  (let ((winconf bookmark-old-winconf))
    (when winconf
      (set-window-configuration winconf))))

(defun bookmark-select ()
  (interactive)
  (multiple-value-bind (book num)
      (bookmark-line)
    (when (and book num)
      (setq *bookmark-point* (1- num))
      (bookmark-quit)
      (bookmark-go book))))

(defun bookmark-line ()
  (let ((num (current-line-number)))
    (values (nth (1- num) *bookmark-list*) num)))

(defun bookmark-open ()
  (interactive)
  (let (curwin)
    (unless (equal buffer-mode '2ch-bookmark)
      (when (equal buffer-mode '2ch-thread)
	(thread-tbk-save))
      (setq curwin (current-window-configuration))
      (set-buffer-bookmark)
      (setq bookmark-old-winconf curwin)
      (delete-other-windows)
      (bookmark-show))))

(defun bookmark-show ()
  (let ((i 0)
	(buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (dolist (book *bookmark-list*)
      (bookmark-insert-line book
			    (= i *bookmark-point*))
      (incf i))
    (if (< -1 *bookmark-point* (list-length *bookmark-list*))
	(goto-line (1+ *bookmark-point*))
      (goto-char (point-min)))
  ))

(defun bookmark-insert-line (book current)
  (set-text-attribute (point)
		      (progn
			(insert (format nil " ~A "
					(if current
					    *mark-char-bookmark*
					  *mark-char-space*)))
			(point))
		      'number
		      :foreground *bookmark-fgcolor-mark*
		      :background *bookmark-bgcolor-mark*
		      :bold current
  );3
  (set-text-attribute (point)
		      (progn
			(insert (format nil " ~15@A" (format nil "[~A]" (bookmark-category book))))
			(point))
		      'name
		      :foreground *bookmark-fgcolor-category*
		      :background *bookmark-bgcolor-category*
		      :bold current
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil " ~15@A" (format nil "[~A]" (bookmark-board book))))
			(point))
		      'tracking
		      :foreground *bookmark-fgcolor-board*
		      :background *bookmark-bgcolor-board*
		      :bold current
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~60@A" (bookmark-title book)))
			(point))
		      'title
		      :foreground *bookmark-fgcolor-title*
		      :background *bookmark-bgcolor-title*
		      :bold current
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~@[(~8D)~]" (bookmark-point book)))
			(point))
		      'num
		      :foreground *bookmark-fgcolor-point*
		      :background *bookmark-bgcolor-point*
		      :bold current
  )
  (insert "\n")
  ;(message-box (format nil "~S" tmp))
)

(defun bookmark-load ()
  (setq *bookmark-list* (bookmark-read))
  (setq *bookmark-point* -1))

(defun bookmark-read ()
  (let (bookmarks)
    (when (file-exist-p *bookmark-file*)
      (with-open-file (s *bookmark-file*
			 :direction :input)
	(let (line)
	  (while (setq line (read s nil))
	    (push line bookmarks)))))
    (nreverse bookmarks)))

(defun bookmark-write ()
  (with-open-file (s *bookmark-file*
		     :direction :output
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" *bookmark-list*)))

(defun bookmark-cut ()
  (interactive)
  (let ((book (bookmark-delete)))
    (when book
      (push book *bookmark-clipboard*))))

(defun bookmark-paste ()
  (interactive)
  (multiple-value-bind (book number)
      (bookmark-line)
    (let ((tmp (pop *bookmark-clipboard*)))
      (when tmp
	(when (bookmark-add tmp (1- number))
	  (bookmark-show))))))

(defun bookmark-delete ()
  (interactive)
  (multiple-value-bind (book num)
      (bookmark-line)
    (when num
      (let ((del (bookmark-del (1- num))))
	(bookmark-show)
	del))))

(defun bookmark-del (num)
  (let (new
	del
	(i 0))
    (dolist (book *bookmark-list*)
      (if (= i num)
	  (setq del book)
	(push book new))
      (incf i))
    (setq *bookmark-list* (nreverse new))
    (when (< num *bookmark-point*)
      (decf *bookmark-point*))
    (bookmark-write)
    del))

(defun bookmark-add (bookmark &optional pos)
  (let ((i 0)
	tmp)
    (setq pos (or pos (list-length *bookmark-list*)))
    (dolist (book *bookmark-list*)
      (when (= pos i)
	(push bookmark tmp))
      (push book tmp)
      (incf i))
    (when (= pos i)
      (push bookmark tmp))
    (setq *bookmark-list* (nreverse tmp))
    (when (<= pos *bookmark-point*)
      (incf *bookmark-point*))
    (bookmark-write)
    (message "2ch: Bookmark added: [~A] [~A] [~A]"
	     (bookmark-category bookmark)
	     (bookmark-board bookmark)
	     (bookmark-title bookmark))))

(defun bookmark-next ()
  (interactive)
  (unless *bookmark-list*
    (return-from bookmark-next))
  (let (book)
    (when (equal buffer-mode '2ch-thread)
      (thread-tbk-save))
    (if (= *bookmark-point* -1)
	(setq *bookmark-point* 0)
      (progn
	(incf *bookmark-point*)
	(when (>= *bookmark-point* (list-length *bookmark-list*))
	  (setq *bookmark-point* 0))))
    (when (setq book (nth *bookmark-point* *bookmark-list*))
      (bookmark-go book))))

(defun bookmark-previous ()
  (interactive)
  (unless *bookmark-list*
    (return-from bookmark-previous))
  (let (book)
    (when (equal buffer-mode '2ch-thread)
      (thread-tbk-save))
    (if (= *bookmark-point* -1)
	(setq *bookmark-point* (1- (list-length *bookmark-list*)))
      (progn
	(decf *bookmark-point*)
	(when (< *bookmark-point* 0)
	  (setq *bookmark-point* (1- (list-length *bookmark-list*))))))
    (when (setq book (nth *bookmark-point* *bookmark-list*))
      (bookmark-go book))))

(defun bookmark-go (bookmark)
  (let* ((category (bookmark-category bookmark))
	 (list (category-name-menu category))
	 (menu (category-menu list))
	 (line (category-name-number category))
	 (bmenu (bookmark-menu bookmark))
	 (i 0)
	 (found nil))
    (unless menu
      (return-from bookmark-go))
    (board-quit)
    (unless (category-open-p (category-name-menu category))
      (setf (category-open-p (category-name-menu category)) t)
      (menu-show nil t))
    (goto-line line)
    (dolist (m menu)
      (forward-line 1)
      (when (menu-equal m bmenu)
	(setq found t)
	(return)))
    (unless found
      (error "”Â‚ªŒ©‚Â‚©‚è‚Ü‚Ö‚ñ"))
    (menu-select)
    (cond ((equal buffer-mode '2ch-tracking)
	   (let ((num (board-dat-number (bookmark-dat bookmark)))
		 (pos (bookmark-point bookmark)))
	     (unless num
	       (error "ƒXƒŒ‚ªŒ©‚Â‚©‚è‚Ü‚Ö‚ñ"))
	     (goto-line (1+ num))
	     (tracking-select)
	     (when pos
	       (goto-char (min pos (point-max))))))
	  ((equal buffer-mode '2ch-board)
	   (let ((num (board-dat-number (bookmark-dat bookmark)))
		 (pos (bookmark-point bookmark)))
	     (unless num
	       (error "ƒXƒŒ‚ªŒ©‚Â‚©‚è‚Ü‚Ö‚ñ"))
	     (goto-line (1+ num))
	     (board-select)
	     (when pos
	       (goto-char (min pos (point-max))))))
	  (t
	   (error "‚È‚ñ‚©‚¨‚©‚µ‚¢‚æ`")))
  ))

(defun board-dat-number (dat)
  (let ((i 0))
    (dolist (b board-list)
      (when (equal dat (tracking-list-dat b))
	(return-from board-dat-number i))
      (incf i))
    nil))

(define-key *thread-map* #\C-M-Right 'bookmark-next)
(define-key *thread-map* #\C-M-Left 'bookmark-previous)
(define-key *thread-map* #\C-M-Up 'bookmark-open)

(define-key *menu-map* #\C-M-Right 'bookmark-next)
(define-key *menu-map* #\C-M-Left 'bookmark-previous)
(define-key *menu-map* #\C-M-Up 'bookmark-open)

(define-key *board-map* #\C-M-Right 'bookmark-next)
(define-key *board-map* #\C-M-Left 'bookmark-previous)
(define-key *board-map* #\C-M-Up 'bookmark-open)

(define-key *tracking-map* #\C-M-Right 'bookmark-next)
(define-key *tracking-map* #\C-M-Left 'bookmark-previous)
(define-key *tracking-map* #\C-M-Up 'bookmark-open)

(define-key *search-map* #\C-M-Right 'bookmark-next)
(define-key *search-map* #\C-M-Left 'bookmark-previous)
(define-key *search-map* #\C-M-Up 'bookmark-open)

(define-key *form-map* #\C-M-Right 'bookmark-next)
(define-key *form-map* #\C-M-Left 'bookmark-previous)
(define-key *form-map* #\C-M-Up 'bookmark-open)

(define-key *form-new-map* #\C-M-Right 'bookmark-next)
(define-key *form-new-map* #\C-M-Left 'bookmark-previous)
(define-key *form-new-map* #\C-M-Up 'bookmark-open)

(define-key *http-map* #\C-M-Right 'bookmark-next)
(define-key *http-map* #\C-M-Left 'bookmark-previous)
(define-key *http-map* #\C-M-Up 'bookmark-open)
