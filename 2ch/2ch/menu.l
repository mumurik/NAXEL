; $Id: menu.l 3 2003-01-25 20:35:51Z torihat $

(provide "2ch/menu")

(in-package "2ch")

(defvar *buffer-menu* "2ch: Menu")

(defvar *menu-list* nil)

(defvar *menu-width* 20)
(defvar *menu-scroll-margin* 5)

(defvar *menu-mode-hook* nil)
(defvar *menu-show-hook* nil)
(defvar *menu-load-hook* nil)

(defvar *menu-fgcolor* 0)
(defvar *menu-bgcolor* 0)
(defvar *category-fgcolor-open* 0)
(defvar *category-fgcolor-close* 0)
(defvar *category-bgcolor-open* 0)
(defvar *category-bgcolor-close* 0)

(defvar *favorits-file-backup* nil)
(defvar *favorits-clipboard* nil)

(defvar *menu-map* nil)
(setq *menu-map* (make-sparse-keymap))
(define-key *menu-map* #\RET 'menu-select)
(define-key *menu-map* #\SPC 'menu-select)
(define-key *menu-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *menu-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *menu-map* #\TAB 'menu-tracking-uplist-next)
(define-key *menu-map* #\C-h 'menu-back-category)
(define-key *menu-map* #\Right 'menu-category-open)
(define-key *menu-map* #\Left 'menu-category-close)
(define-key *menu-map* #\M-Down 'menu-category-next)
(define-key *menu-map* #\M-Up 'menu-category-previous)
(define-key *menu-map* #\r 'menu-update)
(define-key *menu-map* #\R 'menu-reload)
;(define-key *menu-map* #\t 'menu-tracking-update)
(define-key *menu-map* #\t 'tracking-show-updated)
(define-key *menu-map* #\T 'tracking-update-full)
(define-key *menu-map* #\f 'favorits-update)
(define-key *menu-map* #\F 'favorits-add-from-url)
(define-key *menu-map* #\a 'menu-tracking-add)
(define-key *menu-map* #\A 'menu-favorits-add)
(define-key *menu-map* #\D 'menu-del)
(define-key *menu-map* #\M 'menu-rename)
(define-key *menu-map* #\C-k 'menu-cut)
(define-key *menu-map* #\C-y 'menu-paste)
(define-key *menu-map* #\[ 'menu-category-open-all)
(define-key *menu-map* #\] 'menu-category-close-all)
(define-key *menu-map* #\o 'menu-board-open-browser)
(define-key *menu-map* #\O 'open-browser-index)
(define-key *menu-map* #\u 'menu-category-board-update)
(define-key *menu-map* #\U 'menu-category-board-update-all)
(define-key *menu-map* #\C 'thread-clean-dat)
(define-key *menu-map* #\/ 'category-grep)
(define-key *menu-map* #\? 'category-grep-dialog)
(define-key *menu-map* #\g 'menu-grep-all)
(define-key *menu-map* #\G 'menu-grep-all-dialog)
(define-key *menu-map* '(#\s #\a) 'menu-all-search)
(define-key *menu-map* '(#\s #\A) 'menu-all-search-reload)
(define-key *menu-map* '(#\S #\a) 'menu-all-search-force)
(define-key *menu-map* '(#\S #\A) 'menu-all-search-force-reload)
(define-key *menu-map* '(#\s #\c) 'menu-category-search)
(define-key *menu-map* '(#\s #\C) 'menu-category-search-reload)
(define-key *menu-map* '(#\S #\c) 'menu-category-search-force)
(define-key *menu-map* '(#\S #\C) 'menu-category-search-force-reload)
(define-key *menu-map* '(#\s #\b) 'menu-board-search)
(define-key *menu-map* '(#\C-c #\r) 'menu-board-rule)
(define-key *menu-map* '(#\C-c #\R) 'menu-board-rule-force)
(define-key *menu-map* #\M-t 'toggle-online)
(define-key *menu-map* #\q 'exit)
(define-key *menu-map* #\Q 'exit)

(defun menu-equal (menu1 menu2)
  (and (equal (menu-list-name menu1) (menu-list-name menu2))
       (equal (menu-list-host menu1) (menu-list-host menu2))
       (equal (menu-list-path menu1) (menu-list-path menu2))))

(defun set-buffer-menu ()
  (set-buffer (get-buffer-create *buffer-menu*))
  (menu-mode))

(defun menu-mode-line ()
  (setq mode-line-format (format nil "%b (~:[OFF~;ON~]LINE)" *online*))
  (setq title-bar-format (format nil "~A - %b (~:[OFF~;ON~]LINE)" *version-name* *online*)))

(defun menu-mode-line-update ()
  (save-excursion
    (set-buffer *buffer-menu*)
    (menu-mode-line)))

(defun menu-mode ()
  (setq buffer-mode '2ch-menu)
  (setq mode-name *mode-name*)
  (make-local-variable 'mode-line-format)
  (make-local-variable 'title-bar-format)
  (menu-mode-line)
  (make-local-variable '*scroll-margin*)
  (setq *scroll-margin* *menu-scroll-margin*)
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
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-local-window-flags (selected-buffer)
			  *window-flag-vscroll-bar* nil)
  (set-buffer-fold-width nil)
  (use-keymap *menu-map*)
  (run-hooks '*menu-mode-hook*))

(defun menu-get ()
  (interactive)
  (when (string-match "^http://" *menu-url*)
    (http-get *menu-url* *menu-file*)))

(defun menu-category (menu)
  (dolist (c *menu-list*)
    (dolist (m (category-menu c))
      (when (menu-equal m menu)
	(return-from menu-category (category-name c))))))

(defun menu-number (number)
  (let ((i 0))
    (dolist (c *menu-list*)
      (incf i)
      (when (= i number)
	(return-from menu-number (values nil c)))
      (when (category-open-p c)
	(dolist (m (category-menu c))
	  (incf i)
	  (when (= i number)
	    (return-from menu-number (values m c))))))))

(defun menu-name-number (name)
  (let ((i 0))
    (dolist (c *menu-list*)
      (incf i)
      (when (category-open-p c)
	(dolist (m (category-menu c))
	  (incf i)
	  (when (equal name (menu-list-name c))
	    (return-from menu-name-number i)))))))

(defun category-name-number (name)
  (let ((i 0))
    (dolist (c *menu-list*)
      (incf i)
      (when (equal name (category-name c))
	(return-from category-name-number i))
      (when (category-open-p c)
	(dolist (m (category-menu c))
	  (incf i))))))

(defun category-number (name)
  (let ((i 0))
    (dolist (c *menu-list*)
      (when (equal name (category-name c))
	(return-from category-number i))
      (incf i))
    nil))

(defun menu-board-name (host path)
  (dolist (c *menu-list*)
    (dolist (m (category-menu c))
      (when (and (equal host (menu-list-host m))
		 (equal path (menu-list-path m)))
	(return-from menu-board-name (menu-list-name m))))))

#|
(defun menu-line ()
  (let (category
	open-p
	board
	(current-line (current-line-number)))
    (save-excursion
      (goto-bol)
      (cond ((looking-at "\\([\-\+]\\)\\[\\([^]]+\\)\\]")
	     (setq open-p (not (equal (match-string 1) "+")))
	     (setq category (match-string 2)))
	    ((looking-at " +\\([^ \n]+\\)")
	     (let (board-c)
	       (multiple-value-setq (board board-c)
		 (menu-number current-line))
	       (setq open-p t)
	       (setq category (category-name board-c))
	     ))))
    (values category open-p board)))

(defun menu-back-category ()
  (interactive)
  (let (beg)
    (save-excursion
      (when (scan-buffer "^[-+]\\["
			 :regexp t
			 :reverse t
			 :no-dup t)
	(setq beg (point))))
    (when beg
      (goto-char beg))))
|#

(defun menu-line ()
  (multiple-value-bind (m c)
      (menu-number (current-line-number))
    (values (category-name c)
	    (category-open-p c)
	    m)))

(defun menu-back-category ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when category
      (goto-line (category-name-number category)))))

(defun menu-category-next ()
  (interactive)
  (let ((max (list-length *menu-list*)))
    (multiple-value-bind (category open-p board)
	(menu-line)
      (when category
	(let ((num (category-number category)))
	  (when (and num
		     (< (1+ num) max))
	    (goto-line (category-name-number
			(category-name (nth (1+ num) *menu-list*))))))))))

(defun menu-category-previous ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when category
      (let ((num (category-number category)))
	(when (and num
		   (< 0 num))
	  (goto-line (category-name-number
		      (category-name (nth (1- num) *menu-list*)))))))))

(defun menu-category-open ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when category
      (if (and open-p board)
	  (menu-select)
	(unless open-p
	  (goto-line (category-name-number category))
	  (menu-select)
	  (forward-line 1))))))

(defun menu-category-close ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when open-p
      (goto-line (category-name-number category))
      (menu-select))))

(defun menu-board-rule-force ()
  (interactive)
  (menu-board-rule t))

(defun menu-board-rule (&optional force reload)
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when (and board
	       (not (equal category *tracking-name*)))
      (board-rule-show (menu-list-name board)
		       (menu-list-host board)
		       (menu-list-path board)
		       force
		       reload))))

(defun menu-board-open-browser ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when (and board
	       (not (equal category *tracking-name*)))
      (let ((host (menu-list-host board))
	    (path (menu-list-path board)))
	(open-browser (board-url host path))))))

(defun menu-board-url-copy ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when (and board
	       (not (equal category *tracking-name*)))
      (let ((host (menu-list-host board))
	    (path (menu-list-path board)))
	(copy-to-clipboard (board-url host path))))))

(defun menu-board-name-copy ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when (and board
	       (not (equal category *tracking-name*)))
      (copy-to-clipboard (menu-list-name board)))))

(defun menu-board-url-name-copy ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when (and board
	       (not (equal category *tracking-name*)))
      (let ((name (menu-list-name board))
	    (host (menu-list-host board))
	    (path (menu-list-path board)))
	(copy-to-clipboard (board-url-name-format name (board-url host path)))))))

(defun menu-category-close-all (&optional open)
  (interactive)
  (dotimes (i (list-length *menu-list*))
    (setf (category-open-p (nth i *menu-list*)) open))
  (menu-show nil t))

(defun menu-category-open-all ()
  (interactive)
  (menu-category-close-all t))

(defun menu-category-board-update ()
  (interactive)
  (let ((category (menu-line)))
    (when (or (not category)
	      (equal category *tracking-name*))
      (return-from menu-category-board-update))
    (category-board-update category)))

(defun menu-category-board-update-all (&optional noquestion)
  (interactive)
  (unless (or noquestion
	      (yes-or-no-p "全板ののスレ一覧を更新する？"))
    (return-from menu-category-board-update-all))
  (dolist (c *menu-list*)
    (let ((category (category-name c)))
      (unless (or (equal *tracking-name* category)
		  (equal *favorits-name* category))
	(category-board-update category t))))
  (message "全板スレ一覧更新完了"))

(defun category-board-update (category &optional noquestion)
  (unless (or noquestion
	      (yes-or-no-p "~A のスレ一覧を更新する？" category))
    (return-from category-board-update))
  (let* ((list (category-name-menu category))
	 (menu (category-menu list))
	 (cur (current-line-number))
	 (line (category-name-number category))
	 (i 0))
    (unless menu
      (return-from category-board-update))
    (unless (category-open-p (category-name-menu category))
      (setf (category-open-p (category-name-menu category)) t)
      ;(incf current (list-length *tracking-menu-list*))
      (menu-show nil t))
    (goto-line line)
    (dolist (m menu)
      (let* ((name (menu-list-name m))
	     (host (menu-list-host m))
	     (path (menu-list-path m))
	     (bufname (board-buffer-name name host path)))
	(forward-line 1)
	(reverse-line)
	(refresh-screen)
	(board-get host path)
	(when (find-buffer bufname)
	  (delete-buffer bufname))))
    (goto-line cur)
    (clear-reverse-region)
    (message "更新完了: ~A" category)
  ))

(defun menu-select ()
  (interactive)
  (let ((current-line (current-line-number)))
    (goto-bol)
    (multiple-value-bind (category open-p board)
	(menu-line)
      (cond (board
	     (let ((name (menu-list-name board))
		   (host (menu-list-host board))
		   (path (menu-list-path board))
		   (tracking-p (menu-list-tracking-p board)))
	       (reverse-line)
	       (if tracking-p
		   (menu-tracking-show name t)
		 (if (and name host path)
		     (board-show name host path *online*)
		   (error "~A: ~A: ~A" name host path)))))
	    (category
	     (setf (category-open-p (category-name-menu category)) (not open-p))
	     (menu-show nil t)
	     (goto-line current-line))
      ))))

(defun menu-tracking-uplist-next ()
  (interactive)
  (unless *tracking-uplist*
    (message "2ch: 更新スレなし")
    (return-from menu-tracking-uplist-next))
  (unless (category-open-p (category-name-menu *tracking-name*))
    (setf (category-open-p (category-name-menu *tracking-name*)) t)
    (menu-show nil t))
  (multiple-value-bind (category open-p board)
      (menu-line)
    (let (forward
	  back
	  (line (current-line-number)))
      (if (and board
	       (equal category *tracking-name*))
	  (progn
	    (setq forward (member board *tracking-menu-list* :test #'equal))
	    (setq back (reverse (cdr (member board (reverse *tracking-menu-list*) :test #'equal)))))
	(setq forward *tracking-menu-list*))
      (let* ((start (category-name-number *tracking-name*))
	     (i (+ (list-length back) start)))
	; 今いる位置から下へ
	(dolist (track forward)
	  (let ((track-name (menu-list-name track))
		updated)
	    (incf i)
	    (unless (tracking-round-ignore track-name)
	      (goto-line i)
	      (reverse-line)
	      (menu-tracking-show track-name)
	      (when tracking-uplist
		(tracking-next-updated)
		(return-from menu-tracking-uplist-next))
	      (tracking-quit))))
	; 一番上から下へ
	(setq i start)
	(dolist (track back)
	  (let ((track-name (menu-list-name track))
		updated)
	    (incf i)
	    (unless (tracking-round-ignore track-name)
	      (goto-line i)
	      (reverse-line)
	      (menu-tracking-show track-name)
	      (when tracking-uplist
		(tracking-next-updated)
		(return-from menu-tracking-uplist-next))
	      (tracking-quit))))
	(clear-reverse-region)
	(goto-line line)
	))))

(defun menu-tracking-update ()
  (interactive)
  (goto-bol)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when board
      (let ((name (menu-list-name board))
	    (host (menu-list-host board))
	    (path (menu-list-path board))
	    (tracking-p (menu-list-tracking-p board)))
	(when tracking-p
	  (reverse-line)
	  (menu-tracking-show name t)
	  (tracking-update-all))))))

(defun menu-tracking-show (track-name &optional (force t))
  (split-2)
  (tracking-show track-name force))

(defun menu-tracking-add ()
  (interactive)
  (let ((track-name (read-string "グループ名: ")))
    (when (tracking-menu-p track-name)
      (error "もうあります: ~A" track-name))
    (tracking-write track-name nil)
    (menu-update)))

(defun menu-favorits-add ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when board
      (cond ((equal category *favorits-name*)
	     nil)
	    ((equal category *tracking-name*)
	     nil)
	    (t
	     (favorits-add board)
	     (menu-show nil t))))))

(defun menu-del ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when board
      (cond ((equal category *favorits-name*)
	     (favorits-del board)
	     (menu-show nil t))
	    ((equal category *tracking-name*)
	     (tracking-menu-del board)
	     (menu-show nil t))))))

(defun menu-rename ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when board
      (cond ((equal category *tracking-name*)
	     (tracking-menu-rename board)
	     (menu-show nil t))))))

(defun menu-cut ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when board
      (cond ((equal category *tracking-name*)
	     nil)
	    ((equal category *favorits-name*)
	     (favorits-cut board)
	     (menu-show nil t))
	    (t
	     (favorits-copy board))))))

(defun menu-paste ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (when board
      (cond ((equal category *favorits-name*)
	     (favorits-paste board)
	     (menu-show nil t))
	    (t
	     nil)))))

(defun menu-restore-open (old)
  (dolist (c old)
    (let ((name (category-name c)))
      ;(msgbox "~S" c)
      (when (category-name-menu name)
	(setf (category-open-p (category-name-menu name))
	      (category-open-p c))))))

(defun menu-load (&optional force reload)
  (when (and *menu-list*
	     (not force))
    (return-from menu-load))
  (when (or reload
	    (not (file-exist-p *menu-file*)))
    (menu-get))
  (when force
    (tracking-load-menu))
  (let ((favorits (favorits-load))
	(menu-old *menu-list*))
    (set-buffer-temp)
    (insert-file-contents *menu-file*)
    (setq *menu-list* (menu-parse))
    (when favorits
      (push favorits *menu-list*))
    (when *tracking-menu-list*
      (push (list *tracking-name*
		  *tracking-menu-list*
		  nil)
	    *menu-list*))
    (when menu-old
      (menu-restore-open menu-old))
    (run-hooks '*menu-load-hook*)
  ))

(defun menu-show-diff (menu-old)
  (unless (and menu-old *menu-list*)
    (return-from menu-show-diff))
  (let ((str "")
	(new (menu-diff-list *menu-list*))
	(old (menu-diff-list menu-old))
	add
	del
	diff)
    (setq add (set-difference new old :test #'equal))
    (setq del (set-difference old new :test #'equal))
    (when (setq diff (menu-board-move menu-old))
      (menu-favorits-move diff)
      (tracking-move-board diff))
    (when add
      (setq str (concat str "新しい板\n"))
      (dolist (tmp (reverse add))
	(setq str (format nil "~A  ~10@A: ~A~%" str (cdr tmp) (car tmp))))
      (setq str (concat str "\n")))
    (when del
      (setq str (concat str "消えた板\n"))
      (dolist (tmp (reverse del))
	(setq str (format nil "~A   ~10@A: ~A~%" str (cdr tmp) (car tmp))))
      (setq str (concat str "\n")))
    (when diff
      (setq str (concat str "移転\n"))
      (dolist (tmp diff)
	(let ((o (car tmp))
	      (n (cdr tmp)))
	  (setq str (format nil "~A   ~A: ~A => ~A~%"
			    str
			    (menu-list-name n)
			    (board-dir (menu-list-host o) (menu-list-path o))
			    (board-dir (menu-list-host n) (menu-list-path n)))))))
    (if (or add del diff)
	(message-box str)
      (message "板の更新なし"))
    diff
    ))

(defun menu-diff-list (menu)
  (let (tmp)
    (dolist (c menu)
      (dolist (m (category-menu c))
	(push (cons (menu-list-name m) (category-name c)) tmp)))
    tmp))

(defun menu-board-list (menu)
  (let (list)
    (dolist (c menu)
      (let ((cname (category-name c)))
	(unless (equal cname *tracking-name*)
	  (dolist (m (category-menu c))
	    (push m list)))))
    (nreverse list)))

(defun menu-board-move-input (old new)
  (interactive "sURL OLD: \nsURL NEW: ")
  (let (old-host
	old-path
	new-host
	new-path)
    (multiple-value-setq (old-host old-path)
      (favorits-url-parse old))
    (multiple-value-setq (new-host new-path)
      (favorits-url-parse new))))

(defun menu-board-move (menu-old)
  (let ((old (menu-board-list menu-old))
	(new (menu-board-list *menu-list*))
	diff)
    (when (equal old new)
      (return-from menu-board-move))
    (dolist (m new)
      (let* ((name (menu-list-name m))
	     (o (assoc name old :test #'equal)))
	(when (and o
		   (not (equal m o)))
	  (let* ((opath (board-path (menu-list-host o) (menu-list-path o)))
		 (npath (board-path (menu-list-host m) (menu-list-path m)))
		 (npath-parent (directory-namestring npath)))
	    (when (file-exist-p opath)
	      (menu-move-directory opath npath)
	      (message "移転：[~A] \"~A\" => \"~A\""
		       name
		       opath
		       npath)))
	  (push (cons o m) diff))))
    (nreverse diff)))

(defun menu-move-directory (from dest)
  (when (and (file-exist-p from)
	     (not (sub-directory-p dest from)))
    (unless (file-exist-p dest)
      (create-directory dest))
    (message "moving ~A => ~A ..." from dest)
    (dolist (file (directory from))
      (let ((file-path (merge-pathnames file from))
	    (dest-child (merge-pathnames file dest)))
	(if (file-directory-p file-path)
	    (menu-move-directory file-path dest-child)
	  (if (file-exist-p dest-child)
	      (delete-file file-path)
	    (rename-file file-path dest-child)))
	(do-events)))
    (ignore-errors (delete-directory from))
    (message "moving ~A => ~A ...done." from dest)))

(defun menu-favorits-move (diff)
  (let ((list (favorits-read))
	(changed nil))
    (dotimes (i (list-length list))
      (let* ((current (nth i list))
	     (c-host (menu-list-host current))
	     (c-path (menu-list-path current)))
	(dolist (d diff)
	  (let* ((o (car d))
		 (m (cdr d))
		 (o-host (menu-list-host o))
		 (o-path (menu-list-path o))
		 (m-name (menu-list-name m))
		 (m-host (menu-list-host m))
		 (m-path (menu-list-path m)))
	    (when (and (equal c-host o-host)
		       (equal c-path o-path))
	      (setf (nth i list) (list m-name m-host m-path))
	      (setq changed t))))))
    (when changed
      (favorits-write-file list))))

(defun menu-reload ()
  (interactive)
  (let ((menu-old *menu-list*))
    (menu-update t)
    (when (menu-show-diff menu-old)
      (menu-update))))

(defun menu-update (&optional reload)
  (interactive)
  (let ((current (current-line-number))
	(bufname (buffer-name (selected-buffer))))
    (save-excursion
      (unless (equal bufname *buffer-menu*)
	(set-buffer *buffer-menu*))
      (menu-load t reload)
      (menu-show nil t))
    (goto-line current)))

;;
;; bbstable2.html読み取り用
;;

(defun menu-parse-bbstable2 ()
  (let (menu
	current
	board)
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "【<B>\\([^<]+\\)</B>】"
			  :regexp t
			  :tail t)
	;(msgbox "~S~%~{~S~%~}" current board)
	(when (and current board)
	  (push (list current (reverse board) nil) menu)
	  (setq board nil))
	(setq current (buffer-substring (match-beginning 1) (match-end 1)))
	(when (equal current "チャット") ; めっさ決め打ち
	  (return))
	(loop
	  (cond ((looking-at "<A HREF=http://\\([^/]+\\)\\([^> ]+\\)\\(index2.html\\)?>\\([^<]+\\)</A>")
		 (push (list (buffer-substring (match-beginning 4) (match-end 4))
			     (buffer-substring (match-beginning 1) (match-end 1))
			     (buffer-substring (match-beginning 2) (match-end 2)))
		       board)
		 (goto-char (match-end 0)))
		((looking-at "21歳以上！子供はだめ！")
		 (goto-char (match-end 0)))
		((looking-for "/")
		 (or (forward-char 1) (return)))
		((and (eolp) (not (eobp)))
		 (or (forward-char 1) (return)))
		(t
		 (return))))
	))
    (nreverse menu)
    ))

;;
;; bbsmenu.html読み取り用
;;

(defun menu-parse-bbsmenu ()
  (let (menu
	current
	board)
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "<B>\\([^<]+\\)</B><BR>"
			  :regexp t
			  :tail t)
	(when (and current board)
	  (push (list current (reverse board) nil) menu)
	  (setq board nil))
	(setq current (buffer-substring (match-beginning 1) (match-end 1)))
	(when (equal current "チャット")
	  (return))
	(loop
	  (cond ((looking-at "[ \n]*<A HREF=http://\\([^/]+\\)\\([^> ]+/\\)[^>]*>\\([^<]+\\)</A>[ \n]*\\(<BR>\\)+" t)
		 (push (list (buffer-substring (match-beginning 3) (match-end 3))
			     (buffer-substring (match-beginning 1) (match-end 1))
			     (buffer-substring (match-beginning 2) (match-end 2)))
		       board))
		((looking-at "<FONT COLOR=#aaaaaa>[^<]+</FONT><BR>")
		 t)
		((looking-at "[^<]+<BR>")
		 t)
		(t
		 (return)))
	  (goto-char (match-end 0)))
      ))
    (nreverse menu)
  ))

;; デフォルトは bbsmenu.htmlから読む
(setf (symbol-function 'menu-parse) #'menu-parse-bbsmenu)

;;
;; 2channel.brd読み取り用
;;

(defun menu-parse-2channel-brd ()
  (let (menu
	current
	board)
    (save-excursion
      (goto-char (point-min))
      (forward-line 1)
      (loop
	(cond ((looking-at "^[^\t]+")
	       (when (and current board)
		 (push (list current (reverse board) nil) menu)
		 (setq board nil))
	       (setq current (match-string 0)))
	      ((looking-at "^\t\\([^\t]+\\)\t\\([^\t]+\\)\t\\([^\t]+\\)$")
	       (let ((srv (match-string 1))
		     (bbs (match-string 2))
		     (name (match-string 3)))
		 (setq bbs (concat "/" bbs "/"))
		 (when (string-match "^\\([^/]+\\)\\(/.*\\)$" srv)
		   (setq bbs (concat (match-string 2) bbs))
		   (setq srv (match-string 1)))
		 (push (list name srv bbs) board)))
	      (t
	       (return)))
	(or (forward-line 1) (return))))
    (nreverse menu)
    ))

(defun menu-save-write ()
  (with-open-file (s *menu-save-file*
		     :direction :output
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" *menu-list*)))

(defun menu-save-read ()
  (let (menu)
    (when (file-exist-p *menu-save-file*)
      (with-open-file (s *menu-save-file*
			 :direction :input)
	(let (line)
	  (while (setq line (read s nil))
	    (push line menu)))))
    (nreverse menu)))

(defun menu-save-restore ()
  (let ((menu (menu-save-read)))
    (when menu
      (menu-restore-open menu))))

(defun menu-show (&optional menu force)
  (setq menu (or menu *menu-list*))
  (if (and (find-buffer *buffer-menu*)
	   (not force))
      (set-buffer *buffer-menu*)
    (progn
      (set-buffer-menu)
      (let ((current (current-line-number))
	    (buffer-read-only nil))
	(declare (special buffer-read-only))
	(erase-buffer (selected-buffer))
	(dolist (m menu)
	  (let ((name (category-name m))
		(boards (category-menu m))
		(open-p (category-open-p m)))
	    (menu-insert-category name open-p)
	    (when open-p
	      (dolist (b boards)
		(menu-insert-menu (menu-list-name b))))))
	(goto-line current))))
  (run-hooks '*menu-show-hook*))

(defun menu-insert-category (name open-p)
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~22@A~%"
					(format nil "~:[+~;-~][~A]" open-p name)))
			(point))
		      'name
		      :foreground (if open-p *category-fgcolor-open* *category-fgcolor-close*)
		      :background (if open-p *category-bgcolor-open* *category-bgcolor-close*)
		      :bold open-p))

(defun menu-insert-menu (name)
  (set-text-attribute (point)
		      (progn
			(insert (format nil "  ~20@A~%" name))
			(point))
		      'board
		      :foreground *menu-fgcolor*
		      :background *menu-bgcolor*))

(defun favorits-load ()
  (let ((list (favorits-read)))
    (when list
      (list *favorits-name* list nil))))

(defun favorits-read ()
  (let (favorits line)
    (when (file-exist-p *favorits-file*)
      (with-open-file (s *favorits-file*
			 :direction :input)
	(while (setq line (read s nil))
	  (push line favorits))))
    (nreverse favorits)))

(defun favorits-url-parse (url)
  (let (host path)
    (when (string-match "^http://\\([^/]+\\)\\(.+/\\)\\(index2?.html?\\)?$" url)
      (setq host (substring url (match-beginning 1) (match-end 1)))
      (setq path (substring url (match-beginning 2) (match-end 2))))
    (values host path)))

(defun favorits-add-from-url (url)
  (interactive "sURL: ")
  (multiple-value-bind (host path)
      (favorits-url-parse url)
    (when (and host path)
      (let ((name (read-string "Name: ")))
	(favorits-add (list name host path))
	(menu-show nil t)))))

(defun favorits-add (menu &optional pos)
  (let ((old (category-name-menu *favorits-name*)))
    (if old
	(let ((old-c (category-menu old))
	      new-c
	      (i 0))
	  (when (member menu old-c :test #'equal)
	    (return-from favorits-add))
	  (setq pos (or pos (list-length old-c)))
	  (dolist (c old-c)
	    (when (= pos i)
	      (push menu new-c))
	    (push c new-c)
	    (incf i))
	  (when (= pos i)
	    (push menu new-c))
	  (setf (category-menu (category-name-menu *favorits-name*)) (reverse new-c)))
      (push (list *favorits-name* (list menu) t) *menu-list*))
    (favorits-write)))

(defun favorits-del (menu)
  (let ((old (category-menu (category-name-menu *favorits-name*)))
	new)
    (setq new (delete menu old :test 'equal))
    (setf (category-menu (category-name-menu *favorits-name*)) new)
    (favorits-write)))

(defun favorits-copy (menu)
  (push menu *favorits-clipboard*)
  (message "2ch: ~A" (menu-list-name menu)))

(defun favorits-cut (menu)
  (favorits-copy menu)
  (favorits-del menu))

(defun favorits-paste (&optional menu)
  (let ((paste (pop *favorits-clipboard*)))
    (when paste
      (favorits-add paste
		    (if menu
			(favorits-num menu)
		      nil)))))

(defun favorits-num (menu)
  (let ((cur (category-menu (category-name-menu *favorits-name*)))
	(i 0))
    (dolist (c cur)
      (when (equal c menu)
	(return-from favorits-num i))
      (incf i))
    i))

(defun favorits-write ()
  (let* ((list (category-name-menu *favorits-name*))
	 (menu (category-menu list)))
    (when *favorits-file-backup*
      (file-backup *favorits-file*))
    (favorits-write-file menu *favorits-file*)))

(defun favorits-write-file (menu &optional file)
  (with-open-file (s (or file *favorits-file*)
		     :direction :output
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" menu)))
  
(defun favorits-update ()
  (interactive)
  (category-board-update *favorits-name*))

#|
(defun parse-bbsinfo ()
  (let (menu
	current
	board)
    (save-excursion
      (goto-char (point-min))
      (while (scan-buffer "<A NAME=\"[^\"]+\"></A><b>\\([^<]+\\)</b><br>"
			  :regexp t
			  :tail t)
	(when (and current board)
	  (push (cons current (reverse board)) menu)
	  (setq board nil))
	(setq current (buffer-substring (match-beginning 1) (match-end 1)))
	(while (and (forward-line 1)
		    (looking-at "<a href=\"\\([^\"]+\\)index2.html\">\\([^<]+\\)</a>"))
	  (push (cons (buffer-substring (match-beginning 2) (match-end 2))
		      (buffer-substring (match-beginning 1) (match-end 1)))
		board))
      ))
    (nreverse menu)
  ))
|#

