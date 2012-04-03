; $Id: tracking.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/tracking")

(in-package "2ch")

(defvar *tracking-update-list-hook* nil)

(defvar *tracking-updated-name* "更新リスト")

(defvar *tracking-round-ignore-list* nil)

(defvar *tracking-delete-file-recycle* nil)

(defvar *tracking-name-list* nil)
(defvar *tracking-name-current* nil)

(defvar *tracking-mode-hook* nil)
(defvar *tracking-show-hook* nil)

(defvar *tracking-update-all-hook* nil)
(defvar *tracking-update-full-hook* nil)

(defvar *tracking-uplist* nil)

(defvar *tracking-file-backup* nil)

(defvar *tracking-wtime-check* nil)

(defvar *tracking-map* nil)
(setq *tracking-map* (make-sparse-keymap))
;(setq *tracking-map* (copy-keymap *board-map*))
(define-key *tracking-map* #\RET 'tracking-select)
(define-key *tracking-map* #\SPC 'tracking-select)
(define-key *tracking-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *tracking-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *tracking-map* #\TAB 'tracking-next-updated)
(define-key *tracking-map* #\g 'tracking-open-in-board)
(define-key *tracking-map* #\d 'tracking-del)
(define-key *tracking-map* #\D 'tracking-del-marked)
(define-key *tracking-map* #\q 'tracking-quit)
(define-key *tracking-map* #\o 'tracking-thread-open-browser)
(define-key *tracking-map* #\/ 'tracking-grep)
(define-key *tracking-map* #\? 'tracking-grep-dialog)
(define-key *tracking-map* #\C 'tracking-thread-url-copy)
(define-key *tracking-map* #\t 'tracking-thread-title-copy)
(define-key *tracking-map* #\T 'tracking-thread-url-title-copy)
(define-key *tracking-map* #\O 'open-browser-index)
(define-key *tracking-map* #\M-d 'tracking-thread-delete-dat)
(define-key *tracking-map* #\M-D 'tracking-thread-delete-dat-tbk)
(define-key *tracking-map* #\r 'tracking-reload)
(define-key *tracking-map* #\R 'tracking-update-all)
(define-key *tracking-map* #\u 'tracking-update-current)
(define-key *tracking-map* #\U 'tracking-update-all)
(define-key *tracking-map* #\K 'tracking-change-kako)
(define-key *tracking-map* #\M-K 'tracking-change-dat)
(define-key *tracking-map* #\C-k 'tracking-cut)
(define-key *tracking-map* #\M-k 'tracking-copy)
(define-key *tracking-map* #\C-y 'tracking-paste)
(define-key *tracking-map* #\M-y 'tracking-send)
(define-key *tracking-map* #\M-Y 'tracking-send-dialog)
(define-key *tracking-map* #\F6 'tracking-sort-dialog)
(define-key *tracking-map* #\M-t 'toggle-online)
(define-key *tracking-map* #\Q 'exit)

(defvar *tracking-clipboard* nil)

(defun set-buffer-tracking (track-name)
  (let ((bufname (tracking-buffer-name track-name)))
    (if (find-buffer bufname)
	(progn
	  (set-buffer bufname)
	  t)
      (progn
	(set-buffer (get-buffer-create bufname))
	(tracking-mode)
	(setq board-name track-name)
	nil))))

(defun tracking-mode ()
  (board-mode)
  (setq buffer-mode '2ch-tracking)
  (use-keymap *tracking-map*)
  (run-hooks '*tracking-mode-hook*))

(defun tracking-buffer-name (track-name)
  (format nil "2ch: ~A: [~A] ~A" *tracking-name* track-name (tracking-file track-name)))

(defun tracking-thread-open-browser ()
  (interactive)
  (let ((track (tracking-line)))
    (when track
      (open-browser (thread-url-read (tracking-list-host track)
				     (tracking-list-path track)
				     (tracking-list-dat track))))))

(defun tracking-thread-url-copy ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (let ((host (tracking-list-host track))
	  (path (tracking-list-path track))
	  (dat (tracking-list-dat track)))
      (when (and host path dat)
	(let ((url (thread-url-read host path dat)))
	  (when url
	    (copy-to-clipboard url)
	    (message "~A" url)))))))

(defun tracking-thread-title-copy ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (let ((title (tracking-list-title track)))
      (when title
	(copy-to-clipboard title)
	(message "~A" title)))))

(defun tracking-thread-url-title-copy ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (let ((name (tracking-list-name track))
	  (host (tracking-list-host track))
	  (path (tracking-list-path track))
	  (dat (tracking-list-dat track))
	  (title (tracking-list-title track)))
      (when (and host path dat)
	(let ((url (thread-url-read host path dat)))
	  (copy-to-clipboard (thread-url-title-format name title url))
	  (message "~A" title))))))

(defun tracking-thread-delete-dat-tbk (&optional archive)
  (interactive "p")
  (tracking-thread-delete-dat archive t))

(defun tracking-thread-delete-dat (&optional archive tbk)
  (interactive "p")
  (let ((track (tracking-line)))
    (when track
      (when (yes-or-no-p "~A のデータを削除しますか？" (tracking-list-title track))
	(thread-delete-dat track archive tbk)
	(board-update-line)))))

(defun tracking-thread-delete-marked-dat-tbk (&optional archive)
  (interactive "p")
  (tracking-thread-delete-marked-dat archive t))

(defun tracking-thread-delete-marked-dat (&optional archive tbk)
  (interactive "p")
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-thread-delete-marked-dat))
  (let ((track-list (tracking-get-marked)))
    (when (and track-list
	       (yes-or-no-p "マークしたスレのデータを削除しますか？"))
      (thread-delete-dat-files track-list archive tbk)
      (board-redraw))))

(defun tracking-show (track-name &optional force)
  (let ((bufname (tracking-buffer-name track-name))
	current
	mark)
    (when (set-buffer-tracking track-name)
      (unless force
	(return-from tracking-show)))
    (tracking-load track-name force)
    (setq current (current-line-number))
    (let ((buffer-read-only nil))
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (tracking-show-list board-list)
      (goto-line current)
    )
    (run-hooks '*tracking-show-hook*)
  ))

(defun tracking-show-list (&optional list)
  (setq list (or list board-list))
  (setq tracking-uplist nil)
  (let ((i 0))
    (dolist (track list)
      (incf i)
      (let ((host (tracking-list-host track))
	    (path (tracking-list-path track))
	    (dat (tracking-list-dat track))
	    (name (tracking-list-name track))
	    (title (tracking-list-title track))
	    (num (tracking-list-num track))
	    (uplist-p (tracking-uplist-p track))
	    (mark-p (board-mark-p i)))
	(when uplist-p
	  (tracking-uplist-addnum i))
	(board-insert-line dat title num name i
			   :bold uplist-p
			   :tracking t
			   :read (and *thread-read-check*
				      (thread-data-read-p host path dat))
			   :kako (thread-dat-kako-p dat)
			   :mark mark-p
			   :wtime (and *tracking-wtime-check*
				       (thread-data-wtime host path dat)))))
  ))

(defun tracking-uplist-equal (a b)
  (and (equal (tracking-list-dat a) (tracking-list-dat b))
       (equal (tracking-list-path a) (tracking-list-path b))
       (equal (tracking-list-host a) (tracking-list-host b))))

(defun tracking-uplist-p (track)
  (member-if #'(lambda (x)
		 (tracking-uplist-equal track x))
	     *tracking-uplist*))

(defun tracking-uplist-add (track)
  (unless (tracking-uplist-p track)
    (push track *tracking-uplist*)
    (tracking-uplist-save)))

(defun tracking-uplist-del (track)
  (when (tracking-uplist-p track)
    (setq *tracking-uplist*
	  (delete-if #'(lambda (x)
			 (tracking-uplist-equal track x))
		     *tracking-uplist*))
    (tracking-uplist-save)))

(defun tracking-uplist-clear ()
  (interactive)
  (when *tracking-uplist*
    (setq *tracking-uplist* nil)
    (tracking-uplist-save)
    (message "2ch: ~A 更新リストをクリアしました。" *tracking-name*)))

(defun tracking-uplist-addnum (num)
  (setq tracking-uplist (sort (pushnew num tracking-uplist) #'<)))

(defun tracking-uplist-delnum (num)
  (setq tracking-uplist (delete num tracking-uplist)))

(defun tracking-uplist-nump (num)
  (member num tracking-uplist))

(defun tracking-line ()
  (let (track number)
    (save-excursion
      (goto-bol)
      (when (looking-at "^\\([0-9]+\\) ")
	(setq number (parse-integer (match-string 1)))
	(when number
	  (setq track (nth (1- number) board-list)))))
    (values track number)))

(defun tracking-next-updated ()
  (interactive)
  (unless tracking-uplist
    (board-close)
    (forward-line 1)
    (return-from tracking-next-updated))
  (let ((current (current-line-number)))
    (dolist (num (sort tracking-uplist #'<))
      (when (<= current num)
	(goto-line num)
	(board-select)
	(return-from tracking-next-updated)))
    (goto-line (car (sort tracking-uplist #'<)))
    (board-select)))

(defun tracking-mouse-left-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (goto-last-mouse-point)
  (tracking-select))

(defun tracking-select ()
  (interactive)
  (let ((track-name board-name)
	(parent (buffer-name (selected-buffer))))
    (multiple-value-bind (track number)
	(tracking-line)
      (unless track
	(tracking-quit)
	(forward-line 1)
	(return-from tracking-select))
      (tracking-uplist-delnum number)
      (when (tracking-uplist-p track)
	(tracking-uplist-del track)
	(tracking-show track-name t))
      (reverse-line)
      (recenter *board-recenter*)
      ;(refresh-screen)
      (board-split)
      (let* ((oldnum (tracking-list-num track))
	     (newnum (thread-show (tracking-list-name track)
				  (tracking-list-host track)
				  (tracking-list-path track)
				  (tracking-list-dat track)
				  (tracking-list-title track)
				  oldnum
				  *online*
				  nil
				  parent)))
	(when (and newnum oldnum)
	  (when (string-match "^[0-9]+$" oldnum)
	    (setq oldnum (parse-integer oldnum))
	    (unless (= newnum oldnum)
	      (save-excursion
		(set-buffer parent)
		(setf (tracking-list-num (nth (1- number) board-list))
		      (format nil "~D" newnum))
		(tracking-write track-name board-list)
		;ここで数字を更新したいんだけど･･･
		;(tracking-reload)
		;(reverse-line)
	      )))))
    )))

(defun tracking-reload ()
  (interactive)
  (tracking-show board-name t))

(defun tracking-round-ignore (track-name)
  (member-if #'(lambda (x)
		 (string-match x track-name))
	     *tracking-round-ignore-list*))

(defun tracking-update-full (&optional ignore-error)
  (interactive "p")
  (let (updated-list
	(i (category-name-number *tracking-name*))
	current)
    (tracking-quit)
    (setq current (current-line-number))
    (unless (category-open-p (category-name-menu *tracking-name*))
      (setf (category-open-p (category-name-menu *tracking-name*)) t)
      (menu-show nil t))
    (goto-line i)
    (dolist (track *tracking-menu-list*)
      (let ((track-name (menu-list-name track))
	    updated)
	(forward-line 1)
	(cond ((tracking-round-ignore track-name)
	       (message "2ch: skip \"~A\"" track-name))
	      ((not (tracking-time-ok track-name))
	       (message "2ch: まだ~D分たってまへん" *tracking-update-interval-min*))
	      (t
	       (reverse-line)
	       (refresh-screen)
	       (menu-tracking-show track-name)
	       (when (setq updated (tracking-update-list ignore-error))
		 (setq updated-list (append updated-list updated)))
	       (tracking-quit))
	)))
    (clear-reverse-region)
    (goto-line current)
    (message "~D スレ更新" (list-length updated-list))
    (run-hooks '*tracking-update-full-hook*)
    updated-list))

(defun tracking-show-updated (&optional updated)
  (interactive)
  (setq updated (or updated (reverse *tracking-uplist*)))
  (when updated
    (split-2)
    (search-show updated *tracking-updated-name*)))

(defun tracking-update-marked (&optional ignore-error)
  (interactive "p")
  (tracking-update-list ignore-error t))

(defun tracking-update-all (&optional ignore-error)
  (interactive "p")
  (tracking-update-list ignore-error)
  (run-hooks '*tracking-update-all-hook*))

(defun tracking-update-list (&optional ignore-error marked-only)
  (interactive)
  (let (updated
	(i 0)
	(current (current-line-number)))
    (multiple-value-bind (ok-p interval)
	(tracking-time-ok board-name)
      (unless ok-p
	(message "まだ~D分たってまへん(~A経過)"
		 *tracking-update-interval-min*
		 (tracking-interval-format interval))
	(return-from tracking-update-list)))
    (dolist (track board-list)
      (incf i)
      (goto-line i)
      (when (and (not (thread-dat-kako-p (tracking-list-dat track)))
		 (or (not marked-only)
		     (board-mark-p i)))
	(reverse-line)
	(refresh-screen)
	(handler-case
	    (when (tracking-update track i)
	      (push track updated)
	      (tracking-uplist-add track))
	  (quit (c)
	    (error "Interrupted.")) ; <= ここにはこない？
	  (error (c)
	    (let ((msg (si:*condition-string c))
		  (data-file (thread-path-data (tracking-list-host track)
					       (tracking-list-path track)
					       (tracking-list-dat track))))
	      ;(msgbox "~S" msg)
	      (cond ((and (file-exist-p data-file)
			  (string-matchp "status: \\(302\\|404\\)" msg))
		     (if ignore-error
			 nil
		       (when (yes-or-no-p "エラー：過去ログにしますか？~%~%~A" msg)
			 (tracking-change2kako track i))))
		    (t
		     (if ignore-error
			 nil
		       (if (string-match "過去ログ倉庫で発見\\|html化待ち" msg)
			   (when (yes-or-no-p "エラー：過去ログにしますか？~%~%~A" msg)
			     (tracking-change2kako track i))
			 (unless (yes-or-no-p "エラー：続行しますか？~%~%~A" msg)
			   (return)))))))))))
    (clear-reverse-region)
    (goto-line current)
    (gc)
    (tracking-update-time-save board-name)
    (message "~D スレ更新" (list-length updated))
    (run-hooks '*tracking-update-list-hook*)
    (nreverse updated)))

(defun tracking-change-kako ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (when (and track number)
      (tracking-change2kako track number)
      (tracking-uplist-del track)
      (tracking-reload))))

(defun tracking-change2kako (track number)
  (let* ((num (1- number))
	 (host (tracking-list-host track))
	 (path (tracking-list-path track))
	 (dat (tracking-list-dat track))
	 (kako (thread-dat2kako dat))
	 (data-file (thread-path-data host path dat))
	 (kako-file (thread-path-data host path kako))
	 (data-file-tbk (thread-path-tbk host path dat))
	 (kako-file-tbk (thread-path-tbk host path kako))
	 (kako-dir (directory-namestring kako-file)))
    (setf (tracking-list-dat (nth num board-list)) kako)
    (when (file-exist-p data-file)
      (unless (file-exist-p kako-dir)
	(create-directory kako-dir))
      (rename-file data-file kako-file :if-exists :overwrite)
      (when (file-exist-p data-file-tbk)
	(rename-file data-file-tbk kako-file-tbk :if-exists :overwrite)))
    (tracking-write board-name board-list)))

(defun tracking-change-dat ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (when (and track number)
      (tracking-change2dat track number)
      (tracking-uplist-del track)
      (tracking-reload))))

(defun tracking-change2dat (track number)
  (let* ((num (1- number))
	 (host (tracking-list-host track))
	 (path (tracking-list-path track))
	 (kako (tracking-list-dat track))
	 (dat (thread-kako2dat kako))
	 (data-file (thread-path-data host path dat))
	 (kako-file (thread-path-data host path kako))
	 (data-file-tbk (thread-path-tbk host path dat))
	 (kako-file-tbk (thread-path-tbk host path kako))
	 (data-dir (directory-namestring data-file)))
    (setf (tracking-list-dat (nth num board-list)) dat)
    (when (file-exist-p kako-file)
      (unless (file-exist-p data-dir)
	(create-directory data-dir))
      (rename-file kako-file data-file :if-exists :overwrite)
      (when (file-exist-p kako-file-tbk)
	(rename-file kako-file-tbk data-file-tbk :if-exists :overwrite)))
    (tracking-write board-name board-list)))

(defun tracking-update-current ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (when track
      (tracking-update track number))))

(defun tracking-update (track number)
  (when (thread-get (tracking-list-host track)
		    (tracking-list-path track)
		    (tracking-list-dat track))
    (tracking-uplist-addnum number)
    (board-update-line)
    (let* ((bufname (thread-buffer-name (tracking-list-host track)
					(tracking-list-path track)
					(tracking-list-title track)
					(tracking-list-dat track)))
	   (buf (find-buffer bufname)))
      (when buf
	(thread-bar-del bufname)
	(delete-buffer bufname))
      (message "スレ更新: ~A" (tracking-list-title track)))
    t))

(defun tracking-sort-dialog ()
  (interactive)
  (multiple-value-bind (result data)
      (dialog-box '(dialog 0 0 131 109
		    (:caption "ソート")
		    (:font 9 "ＭＳ Ｐゴシック")
		    (:control
		     (:button nil "ｿｰﾄ方法" #x50000007 7 7 61 78)
		     (:button update "更新(&N)" #x50030009 13 21 39 10)
		     (:button title "題名(&D)" #x50000009 13 37 39 10)
		     (:button number "発言数(&F)" #x50000009 13 53 53 10)
		     (:button board "板(&S)" #x50000009 13 69 45 10)
		     (:button reverse "降順でｿｰﾄ(&R)" #x50030003 7 92 57 10)
		     (:button IDOK "OK" #x50010001 74 7 50 14)
		     (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 74 24 50 14)))
		  (list (cons 'update t)
			(cons 'title nil)
			(cons 'number nil)
			(cons 'board nil)
			(cons 'reverse nil))
		  nil)
    (when result
      (tracking-sort data))))

(defun tracking-sort (order)
  (let ((reverse (assoc 'reverse order)))
    (message "Sorting ...")
    (cond ((assoc 'update order)
	   (tracking-sort-by-update reverse))
	  ((assoc 'title order)
	   (tracking-sort-by-title reverse))
	  ((assoc 'number order)
	   (tracking-sort-by-number reverse))
	  ((assoc 'board order)
	   (tracking-sort-by-board reverse))
    )
    (message "Sorting ... done.")
  ))

(defun tracking-sort-by-title (&optional rev)
  (interactive)
  (setq board-list
	(tracking-list-sort-by-title board-list rev))
  (tracking-write board-name board-list)
  (tracking-reload))

(defun tracking-sort-by-update (&optional rev)
  (interactive)
  (setq board-list
	(tracking-list-sort-by-update board-list rev))
  (tracking-write board-name board-list)
  (tracking-reload))

(defun tracking-sort-by-number (&optional rev)
  (interactive)
  (setq board-list
	(tracking-list-sort-by-number board-list rev))
  (tracking-write board-name board-list)
  (tracking-reload))

(defun tracking-sort-by-board (&optional rev)
  (interactive)
  (setq board-list
	(tracking-list-sort-by-board board-list rev))
  (tracking-write board-name board-list)
  (tracking-reload))

(defun tracking-list-sort-by-title (tracking-list &optional rev)
  (sort tracking-list
	(if rev
	    #'string>
	  #'string<)
	:key #'(lambda (x)
		 (tracking-list-title x))))

(defun tracking-list-sort-by-number (tracking-list &optional rev)
  (sort tracking-list
	(if rev
	    #'<
	  #'>)
	:key #'(lambda (x)
		 (parse-integer (tracking-list-num x)))))

(defun tracking-list-sort-by-board (tracking-list &optional rev)
  (sort tracking-list
	(if rev
	    #'string>
	  #'string<)
	:key #'(lambda (x)
		 (tracking-list-name x))))

(defun tracking-list-sort-by-update (tracking-list &optional rev)
  (mapcar #'car
	  (sort (mapcar #'(lambda (x)
			    (let ((file (thread-path-data
					 (tracking-list-host x)
					 (tracking-list-path x)
					 (tracking-list-dat x))))
			      (cons x (if (file-exist-p file)
					  (file-write-time file)
					0))))
			tracking-list)
		(if rev
		    #'<
		  #'>)
		:key #'cdr)))

(defun tracking-quit ()
  (interactive)
  (board-quit))

#|
(defun tracking-quit ()
  (interactive)
  (board-quit)
  (setf (category-open-p (category-name-menu *tracking-name*)) nil)
  (menu-show nil t))
|#

(defun tracking-load-menu ()
  (setq *tracking-menu-list* (tracking-read-directory)))

(defun tracking-load (track-name &optional force)
  (when (or force
	    (not board-list)
	    (not (equal track-name board-name)))
    (setq board-list (tracking-read track-name))
    (setq board-name track-name)))

(defun tracking-list-all ()
  (unless *tracking-list-all*
    (setq *tracking-list-all* (tracking-read-all)))
  *tracking-list-all*)

(defun tracking-list-board (host path)
  (let (tmp)
    (dolist (track (tracking-list-all))
      (when (and (equal host (tracking-list-host track))
		 (equal path (tracking-list-path track)))
	(push track tmp)))
    (nreverse tmp)))

(defun tracking-read-all ()
  (interactive)
  (let (tmp)
    (dolist (track *tracking-menu-list*)
      (setq tmp (append tmp (tracking-read (tracking-list-name track)))))
    tmp))

(defun tracking-move-board (diff)
  (dolist (track *tracking-menu-list*)
    (let* ((name (tracking-list-name track))
	   (list (tracking-read name))
	   (bufname (tracking-buffer-name name))
	   (changed nil))
      (dotimes (i (list-length list))
	(let* ((current (nth i list))
	       (c-host (tracking-list-host current))
	       (c-path (tracking-list-path current)))
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
		(setf (nth i list) (list m-name
					 m-host
					 m-path
					 (tracking-list-dat current)
					 (tracking-list-title current)
					 (tracking-list-num current)))
		(setq changed t))))))
      (when changed
	(when (find-buffer bufname)
	  (delete-buffer bufname))
	(tracking-write name list)))))

(defvar *tracking-file-suffix* ".txt")

(defun tracking-read-directory ()
  (unless (file-directory-p *tracking-directory*)
    (error "フォルダないっす: ~S" *tracking-directory*))
  (setq *tracking-menu-list* nil)
  (let (tmp)
    (dolist (file (directory *tracking-directory*
			     :wild (concat "*" *tracking-file-suffix*)))
      (let ((track (substring file
			      0
			      (- (length file) (length *tracking-file-suffix*)))))
	(push (list track nil nil t) tmp)))
    (setq *tracking-menu-list* (sort tmp #'string< :key #'car))))

(defun tracking-file (track-name)
  (merge-pathnames (concat track-name *tracking-file-suffix*)
		   *tracking-directory*))

(defun tracking-read (track-name)
  (let (tracking
	line
	(file (tracking-file track-name)))
    (when (file-exist-p file)
      (with-open-file (s file
			 :direction :input)
	(while (setq line (read s nil))
	  (push line tracking))))
    (nreverse tracking)))

(defun tracking-menu-p (track-name)
  (member track-name *tracking-menu-list* :test #'equal :key #'car))

(defun tracking-get-group (&optional dialog)
  (if dialog
      (tracking-get-group-dialog)
    (completing-read "グループ: "
		     (mapcar 'car *tracking-menu-list*)
		     :must-match nil)))

(defun tracking-exist-p (board list)
  (member-if #'(lambda (x)
		 (tracking-uplist-equal x board))
	     list))

(defun tracking-add (board &optional pos track-name dialog)
  (let (tmp
	(i 0)
	exist
	tracking-list)
    (setq track-name
	  (or track-name
	      (tracking-get-group dialog)))
    (when (or (not track-name)
	      (equal track-name ""))
      (return-from tracking-add))
    (setq exist (tracking-menu-p track-name))
    (setq tracking-list (tracking-read track-name))
    (when (tracking-exist-p board tracking-list)
      (return-from tracking-add))
    (setq pos (or pos (list-length tracking-list)))
    (dolist (track tracking-list)
      (when (= pos i)
	(push board tmp))
      (push track tmp)
      (incf i))
    (when (= pos i)
      (push board tmp))
    (setq tracking-list (nreverse tmp))
    (tracking-write track-name tracking-list)
    (setq *tracking-list-all* nil)
    (unless exist
      (menu-update)))
  t)

(defun tracking-get-group-dialog ()
  (let (group)
    (multiple-value-bind (result data)
	(dialog-box '(dialog 0 0 186 162
		      (:caption "グループの選択")
		      (:font 9 "ＭＳ Ｐゴシック")
		      (:control
		       (:listbox list nil #x50b10111 7 7 116 148)
		       (:button IDOK "OK" #x50010001 129 7 50 14)
		       (:button IDCANCEL "ｷｬﾝｾﾙ" #x50010000 129 24 50 14)))
		    (list (cons 'list *tracking-menu-list*))
		    '((list :column (30) :must-match t :enable (IDOK))))
      (when result
	(cadr (assoc 'list data))))))

(defun tracking-menu-rename (track)
  (let* ((old-name (menu-list-name track))
	 (old-file (tracking-file old-name))
	 (old-time-file (tracking-time-file old-name))
	 (old-menu (category-menu (category-name-menu *tracking-name*)))
	 (new-name (read-string "グループ名："))
	 (new-file (tracking-file new-name))
	 (new-time-file (tracking-time-file new-name))
	 new)
    (when (tracking-menu-p new-name)
      (error "もうあるっす：~A" new-name))
    (when (file-exist-p old-file)
      (rename-file old-file new-file :if-exists :overwrite))
    (when (file-exist-p old-time-file)
      (rename-file old-time-file new-time-file :if-exists :overwrite))
    (tracking-load-menu)
    (when (equal old-name *tracking-name-current*)
      (setq *tracking-name-current* new-name))
    (setf (category-menu (category-name-menu *tracking-name*)) *tracking-menu-list*)))

(defun tracking-menu-del (track)
  (let* ((track-name (menu-list-name track))
	 (file (tracking-file track-name))
	 (old (category-menu (category-name-menu *tracking-name*)))
	 new)
    (when (file-exist-p file)
      (tracking-delete-file file))
    (setq *tracking-menu-list*
	  (delete track-name *tracking-menu-list* :test #'equal :key #'car))
    (when (equal track-name *tracking-name-current*)
      (setq *tracking-name-current* nil))
    (setq new (delete track old :test 'equal))
    (setf (category-menu (category-name-menu *tracking-name*)) new)))

(defvar *tracking-delete-file* t)

(defun tracking-delete-file (file)
  (if *tracking-delete-file*
      (delete-file file :recycle *tracking-delete-file-recycle*)
    (rename-file file
		 (concat file ".del")
		 :if-exists :overwrite)))

(defun tracking-rm (track)
  (setq board-list (delete track board-list :test 'equal))
  (tracking-uplist-del track))

(defun tracking-del ()
  (interactive)
  (let ((track (tracking-line)))
    (when track
      (tracking-rm track)
      (tracking-write board-name board-list)
      (tracking-reload))
    track))

(defun tracking-del-marked ()
  (interactive)
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-del-marked))
  (let ((track-list (tracking-rm-marked)))
    (when track-list
      (tracking-write board-name board-list)
      (setq board-mark nil)
      (tracking-reload))))

(defun tracking-cut ()
  (interactive)
  (let ((track (tracking-del)))
    (when track
      (push track *tracking-clipboard*)
      (message "2ch: ~A" (tracking-list-name track)))))

(defun tracking-cut-marked ()
  (interactive)
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-cut-marked))
  (let ((track-list (tracking-rm-marked)))
    (when track-list
      (dolist (track track-list)
	(msgbox "~S" track)
	(push track *tracking-clipboard*))
      (tracking-write board-name board-list)
      (setq board-mark nil)
      (tracking-reload))
    (message "2ch: ~Dスレ切り取り" (list-length track-list))))

(defun tracking-copy ()
  (interactive)
  (let ((track (tracking-line)))
    (when track
      (push track *tracking-clipboard*)
      (message "2ch: ~A" (tracking-list-title track)))))

(defun tracking-copy-marked ()
  (interactive)
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-copy-marked))
  (let ((track-list (tracking-get-marked)))
    (when track-list
      (dolist (track track-list)
	(push track *tracking-clipboard*)))
    (message "2ch: ~Dスレコピー" (list-length track-list))))

(defun tracking-paste ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (let ((tmp (pop *tracking-clipboard*)))
      (when tmp
	(when (tracking-add tmp
			    (if number
				(1- number)
			      (list-length board-list))
			    board-name)
	  (tracking-reload))))))

(defun tracking-send-dialog ()
  (interactive)
  (tracking-send t))

(defun tracking-send (&optional dialog)
  (interactive)
  (unless *tracking-clipboard*
    (return-from tracking-send))
  (let ((track-name (tracking-get-group dialog)))
    (when (or (not track-name)
	      (equal track-name ""))
      (return-from tracking-send))
    (dolist (track (reverse *tracking-clipboard*))
      (tracking-add track nil track-name))
    (setq *tracking-clipboard* nil)
    (message "2ch: => ~A" track-name)))

(defun tracking-write (track-name tracking-list)
  (let ((file (tracking-file track-name)))
    (when *tracking-file-backup*
      (file-backup file))
    (with-open-file (s file
		       :direction :output
		       :if-does-not-exist :create)
      (format s "~{~S~%~}" tracking-list))))

(defun tracking-uplist-load ()
  (unless *tracking-uplist*
    (setq *tracking-uplist* (tracking-uplist-read))))

(defun tracking-uplist-read ()
  (let (tracking
	line)
    (when (file-exist-p *tracking-file*)
      (with-open-file (s *tracking-file*
			 :direction :input)
	(while (setq line (read s nil))
	  (push line tracking))))
    (nreverse tracking)))

(defun tracking-uplist-save ()
  (with-open-file (s *tracking-file*
		     :direction :output
		     :if-does-not-exist :create)
    (format s "~{~S~%~}" *tracking-uplist*)))

(defun tracking-open-in-board ()
  (interactive)
  (let ((bookmark (tracking-bookmark-get)))
    (when bookmark
      (bookmark-go bookmark))))

(defun tracking-bookmark-get ()
  (multiple-value-bind (track number)
      (tracking-line)
    (unless track
      (return-from tracking-bookmark-get))
    (let ((board (tracking-list-name track))
	  (host (tracking-list-host track))
	  (path (tracking-list-path track))
	  (title (tracking-list-title track))
	  (dat (tracking-list-dat track))
	  category)
      (when (setq category (menu-category (list board host path)))
	(list category
	      board
	      host
	      path
	      title
	      dat
	      nil)))))

(defvar *tracking-time-file-suffix* ".time")

(defun tracking-time-file (track-name)
  (concat (tracking-file track-name) *tracking-time-file-suffix*))

(defun tracking-update-time-read (track-name)
  (let ((file (tracking-time-file track-name)))
    (if (file-exist-p file)
	(file-write-time file)
      0)))

(defun tracking-update-time-save (track-name &optional time)
  (setq time (or time (get-universal-time)))
  (let ((file (tracking-time-file track-name)))
    (if (file-exist-p file)
	(set-file-write-time file time)
      (with-open-file (s file
			 :direction :output
			 :if-does-not-exist :create)))))

(defconstant *tracking-update-interval-min* 10)

(defun tracking-time-ok (track-name)
  (let* ((now (get-universal-time))
	 (time (tracking-update-time-read track-name))
	 (min (* *tracking-update-interval-min* 60))
	 (interval (- now time)))
    (values (< min interval) interval)))

(defun tracking-interval-format (interval)
  (multiple-value-bind (min sec)
      (floor interval 60)
    (format nil "~2D分~2D秒" min sec)))

(defun board-mark-p (num)
  (member num board-mark))

(defun board-mark-add (num)
  (pushnew num board-mark)
  (setq board-mark
	(sort board-mark #'<)))

(defun board-mark-del (num)
  (setq board-mark
	(delete num board-mark)))

(defun tracking-mark-toggle ()
  (interactive)
  (multiple-value-bind (track num)
      (tracking-line)
    (when num
      (if (board-mark-p num)
	  (board-mark-del num)
	(board-mark-add num))
      (board-update-line))))

(defun tracking-mark-set ()
  (interactive)
  (multiple-value-bind (track num)
      (tracking-line)
    (when num
      (board-mark-add num)
      (board-update-line))))

(defun tracking-mark-set-all ()
  (interactive)
  (let (mark)
    (dotimes (i (list-length board-mark))
      (push (1+ i) mark))
    (setq board-mark (nreverse mark))
    (board-redraw)))

(defun tracking-mark-unset ()
  (interactive)
  (multiple-value-bind (track num)
      (tracking-line)
    (when num
      (board-mark-del num)
      (board-update-line))))

(defun tracking-mark-unset-all ()
  (interactive)
  (setq board-mark nil)
  (board-redraw))

(defun tracking-get-marked ()
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-get-marked))
  (let (track-list)
    (dolist (m board-mark)
      (goto-line m)
      (let ((track (tracking-line)))
	(when track
	  (push track track-list))))
    (nreverse track-list)
  ))

(defun tracking-rm-marked ()
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-rm-marked))
  (let ((track-list (tracking-get-marked)))
    (dolist (track track-list)
      (tracking-rm track))
    track-list))

(defun tracking-send-marked-dialog ()
  (interactive)
  (tracking-send-marked t))

(defun tracking-send-marked (&optional dialog (delete t))
  (interactive)
  (unless board-mark
    (message "2ch: no mark")
    (return-from tracking-send-marked))
  (let ((send-to (tracking-get-group dialog))
	track-list)
    (when (or (not send-to)
	      (equal send-to "")
	      (equal send-to board-name))
      (return-from tracking-send-marked))
    (when (setq track-list (tracking-get-marked))
      (dolist (track track-list)
	(tracking-add track nil send-to)))
    (when delete
      (tracking-del-marked))
  ))

(defun tracking-mark-set-kako ()
  (interactive)
  (let (mark
	(i 0))
    (dolist (track board-list)
      (incf i)
      (when (thread-dat-kako-p (tracking-list-dat track))
	(board-mark-add i)))
    (board-redraw)))

(defvar *tracking-mark-old-days* 10)
(defvar *tracking-mark-nouse-days* 10)

(defun tracking-mark-set-old ()
  (interactive)
  (let ((days (read-number "日数: " (format nil "~D" *tracking-mark-old-days*)))
	(i 0)
	limit)
    (when days
      (setq limit (- (get-universal-time) (* days 24 60 60)))
      (dolist (track board-list)
	(incf i)
	(let* ((host (tracking-list-host track))
	       (path (tracking-list-path track))
	       (dat (tracking-list-dat track))
	       (data-file (thread-path-data host path dat))
	       wtime)
	  (when (file-exist-p data-file)
	    (setq wtime (file-write-time data-file))
	    (when (< wtime limit)
	      (board-mark-add i))))))
    (board-redraw)))

(defun tracking-mark-set-tracking-reverse ()
  (interactive)
  (tracking-mark-set-tracking t))

(defun tracking-mark-set-tracking (&optional (reverse nil))
  (interactive)
  (let ((i 0))
    (dolist (track board-list)
      (incf i)
      (when (equal (null (tracking-list-p track))
		   reverse)
	(board-mark-add i)))
    (board-redraw)))

(defun tracking-mark-set-reverse ()
  (interactive)
  (let (rev)
    (dotimes (i (list-length board-list))
      (unless (board-mark-p (1+ i))
	(push (1+ i) rev)))
    (setq board-mark (nreverse rev))
    (board-redraw)))

(defun tracking-list-p (track)
  (let ((all (tracking-list-all)))
    (member-if #'(lambda (x)
		   (tracking-uplist-equal x track))
	       all)))

(defun tracking-mark-set-nouse ()
  (interactive)
  (let ((days (read-number "日数: " (format nil "~D" *tracking-mark-old-days*)))
	(i 0)
	limit)
    (when days
      (setq limit (- (get-universal-time) (* days 24 60 60)))
      (dolist (track board-list)
	(incf i)
	(let* ((host (tracking-list-host track))
	       (path (tracking-list-path track))
	       (dat (tracking-list-dat track))
	       (tbk-file (thread-path-tbk host path dat))
	       wtime)
	  (when (file-exist-p tbk-file)
	    (setq wtime (file-write-time tbk-file))
	    (when (< wtime limit)
	      (board-mark-add i))))))
    (board-redraw)))

(defun tracking-mark-set-query ()
  (interactive)
  (let ((regexp (read-string "Regexp: "))
	(i 0))
    (string-match regexp "")	; <= test regexp
    (dolist (track board-list)
      (incf i)
      (let ((title (tracking-list-title track)))
	(when (string-match regexp title)
	  (board-mark-add i))))
    (board-redraw)))

(define-key *tracking-map* #\* 'tracking-mark-toggle)
(define-key *tracking-map* '(#\m #\m) 'tracking-mark-set)
(define-key *tracking-map* '(#\m #\M) 'tracking-mark-set-all)
(define-key *tracking-map* '(#\m #\d) 'tracking-mark-unset)
(define-key *tracking-map* '(#\m #\D) 'tracking-mark-unset-all)

(define-key *tracking-map* '(#\m #\s) 'tracking-send-marked)
(define-key *tracking-map* '(#\m #\S) 'tracking-send-marked-dialog)
(define-key *tracking-map* '(#\m #\u) 'tracking-update-marked)
(define-key *tracking-map* '(#\m #\C-k) 'tracking-cut-marked)
(define-key *tracking-map* '(#\m #\M-k) 'tracking-copy-marked)

(define-key *tracking-map* '(#\m #\k) 'tracking-mark-set-kako)
(define-key *tracking-map* '(#\m #\o) 'tracking-mark-set-old)
(define-key *tracking-map* '(#\m #\n) 'tracking-mark-set-nouse)
(define-key *tracking-map* '(#\m #\/) 'tracking-mark-set-query)
(define-key *tracking-map* '(#\m #\r) 'tracking-mark-set-reverse)

(define-key *tracking-map* '(#\m #\M-d) 'tracking-thread-delete-marked-dat)
(define-key *tracking-map* '(#\m #\M-D) 'tracking-thread-delete-marked-dat-tbk)
