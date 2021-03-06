; $Id: search.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/search")

(in-package "2ch")

(defvar *search-regexp* nil)

(defvar *search-case-fold* t)
(defvar *search-wtime-check* nil)

(defvar *buffer-search* "2ch: Search")

(defvar *search-map* nil)
(setq *search-map* (make-sparse-keymap))
;(setq *search-map* (copy-keymap *tracking-map*))
;(setq *search-map* (copy-keymap *board-map*))
(define-key *search-map* #\RET 'search-select)
(define-key *search-map* #\M-RET 'search-select-lines)
(define-key *search-map* #\SPC 'search-select)
(define-key *search-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *search-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *search-map* #\TAB 'tracking-next-updated)
(define-key *search-map* #\q 'board-close)
(define-key *search-map* #\a 'board-tracking-add)
(define-key *search-map* #\A 'board-tracking-add-dialog)
(define-key *search-map* #\S 'search-save-as-tracking)
(define-key *search-map* #\o 'tracking-thread-open-browser)
(define-key *search-map* #\C 'tracking-thread-url-copy)
(define-key *search-map* #\t 'tracking-thread-title-copy)
(define-key *search-map* #\T 'tracking-thread-url-title-copy)
(define-key *search-map* #\M-d 'tracking-thread-delete-dat)
(define-key *search-map* #\M-D 'tracking-thread-delete-dat-tbk)
(define-key *search-map* #\u 'tracking-update-current)
(define-key *search-map* #\M-t 'toggle-online)
(define-key *search-map* #\Q 'exit)

(defun search-mode ()
  (tracking-mode)
  (setq buffer-mode '2ch-search)
  (use-keymap *search-map*))

(defun set-buffer-search (search)
  (let ((bufname (search-buffer-name search)))
    (if (find-buffer bufname)
	(progn
	  (set-buffer bufname)
	  t)
      (progn
	(set-buffer (get-buffer-create bufname))
	(search-mode)
	(setq board-name search)
	nil))
  ))

(defun search-buffer-name (search)
  (format nil "~A [~A]" *buffer-search* search))

(defun menu-board-search ()
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (unless board
      (return-from menu-board-search))
    (let ((search (search-get-regexp)))
      (unless search
	(return-from menu-board-search))
      (menu-select)
      (if (equal category *tracking-name*)
	  (tracking-search search)
	(board-search search)))))

(defun menu-category-search-force-reload ()
  (interactive)
  (menu-category-search t t))

(defun menu-category-search-force ()
  (interactive)
  (menu-category-search t))

(defun menu-category-search-reload ()
  (interactive)
  (menu-category-search nil t))

(defun menu-category-search (&optional force reload)
  (interactive)
  (multiple-value-bind (category open-p board)
      (menu-line)
    (unless category
      (return-from menu-category-search))
    (if (equal category *tracking-name*)
	(tracking-search-all)
      (let (board-list)
	(message "2ch: listing board ...")
	(dolist (m (category-menu (category-name-menu category)))
	  (let ((data-file (board-path-data (menu-list-host m)
					    (menu-list-path m))))
	    (when (or (file-exist-p data-file)
		      force)
	      (push m board-list))))
	(message "2ch: listing board ... done.")
	(when board-list
	  (search-board-list (nreverse board-list) reload))))))

(defun menu-all-search-force-reload ()
  (interactive)
  (menu-all-search t t))

(defun menu-all-search-force ()
  (interactive)
  (menu-all-search t nil))

(defun menu-all-search-reload ()
  (interactive)
  (menu-all-search nil t))

(defun menu-all-search (&optional force reload)
  (interactive)
  (let (board-list)
    (long-operation
      (message "2ch: listing board ... ")
      (dolist (c *menu-list*)
	(unless (or (equal *favorits-name* (category-name c))
		    (equal *tracking-name* (category-name c)))
	  (dolist (m (category-menu c))
	    (let ((data-file (board-path-data (menu-list-host m)
					      (menu-list-path m))))
	      (when (or (file-exist-p data-file)
			force)
		(push m board-list))))))
      (message "2ch: listing board ... done."))
    (when board-list
      (search-board-list (nreverse board-list) reload))))

(defun search-board-list (board-list &optional reload)
  (let ((search (search-get-regexp))
	matched)
    (unless search
      (return-from search-board-list))
    (save-excursion
      (long-operation
	(dolist (board board-list)
	  (let* ((name (menu-list-name board))
		 (host (menu-list-host board))
		 (path (menu-list-path board))
		 data-file)
	    (when (and name host path)
	      (setq data-file (board-path-data host path))
	      (when (or reload
			(not (file-exist-p data-file)))
		(board-get host path))
	      (setq matched
		    (append matched (search-board search name host path))))))
      ))
    (split-2)
    (search-show matched search)))

(defun board-search (&optional search)
  (interactive)
  (setq search (or search (search-get-regexp)))
  (unless search
    (return-from board-search))
  (let ((bufname (buffer-name (selected-buffer)))
	(matched (search-board search
			       board-name
			       board-host
			       board-path)))
    (search-show matched search)
    (setq board-buffer-parent bufname)))

(defun board-new-show ()
  (interactive)
  (let ((days (read-number "日数: " (format nil "~D" *board-new-days*)))
	dat-limit
	(bufname (buffer-name (selected-buffer)))
	list)
    (unless days
      (return-from board-new-show))
    (setq *board-new-days* days)
    (setq dat-limit (format nil "~D.dat"
			    (- (form-time) (* days 60 60 24))))
    (dolist (board board-list)
      (let ((dat (tracking-list-dat board)))
	(when (string>= dat dat-limit)
	  (push board list))))
    (search-show (nreverse list) board-name)
    (setq board-buffer-parent bufname)))

(defun tracking-search (&optional search)
  (interactive)
  (setq search (or search (search-get-regexp)))
  (unless search
    (return-from tracking-search))
  (let ((matched (search-tracking-list search board-list)))
    (split-2)
    (search-show matched search)))

(defun tracking-search-all (&optional search)
  (interactive)
  (setq search (or search (search-get-regexp)))
  (unless search
    (return-from tracking-search-all))
  (let ((matched (search-tracking-list search (tracking-list-all))))
    (split-2)
    (search-show matched search)))

(defun search-tracking-list (search tracking-list)
  (let (matched)
    (dolist (track tracking-list)
      (let ((title (tracking-list-title track)))
	(when (stringp title)
	  (when (if *search-case-fold*
		    (string-matchp search title)
		  (string-match search title))
	    (push track matched)))))
    (nreverse matched)))

(defun search-get-regexp ()
  (let ((search (read-string "タイトル検索： " :default (or *search-regexp* ""))))
    (when (string-match "^[\t\n 　]*$" search)
      (return-from search-get-regexp))
    (string-matchp search "")	; 正規表現のテスト
    (add-history search '*minibuffer-search-string-history*)
    (setq *search-regexp* search)
    search))

(defun search-board (search name host path)
  (let ((search-regexp (compile-regexp search))
	(board-file (board-path-data host path))
	matched
	regexp)
    (unless (file-exist-p board-file)
      (error "スレ一覧データがないっす: ~S" board-file))
    (set-buffer-board-temp)
    (insert-file-contents board-file)
    (goto-char (point-min))
    (unless (setq regexp (board-regexp-test))
      (return-from search-board))
    (let ((line "")
	  (i 0))
      (with-input-from-selected-buffer
	(message "2ch: searching in ~A ..." name)
	(while (setq line (read-line nil nil))
	  (when (string-match regexp line)
	    (let ((dat (substring line (match-beginning 1) (match-end 1)))
		  (title (string-trim " " (substring line (match-beginning 2) (match-end 2))))
		  (num (substring line (match-beginning 3) (match-end 3))))
	      (when (setq title (thread-parse-special-strings title))
		(when (if *search-case-fold*
			  (string-matchp search title)
			(string-match search title))
		  (incf i)
		  (push (list name host path dat title num) matched)
		)))))))
    (message "2ch: searching in ~A ... done." name)
    (nreverse matched)))

(defun search-redraw ()
  (interactive)
  (search-show board-list board-name))

(defun search-show (matched search)
  (set-buffer-search search)
  (setq board-list matched)
  (search-refresh))

(defun search-refresh (&optional list)
  (setq list (or list board-list))
  (let ((line "")
	(current (current-line-number))
	(i 0)
	(buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (mapc #'(lambda (track)
	      (incf i)
	      (let ((host (tracking-list-host track))
		    (path (tracking-list-path track))
		    (dat (tracking-list-dat track))
		    (name (tracking-list-name track))
		    (title (tracking-list-title track))
		    (num (tracking-list-num track)))
		(board-insert-line dat title num name i
				   :tracking (tracking-list-p track)
				   :read (and *thread-read-check*
					      (thread-data-read-p host path dat))
				   :mark (board-mark-p i)
				   :kako (thread-dat-kako-p dat)
				   :wtime (and *search-wtime-check*
					       (thread-data-wtime host path dat)))))
	  list)
    (goto-line current)))

(defun search-select-lines ()
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (unless track
      (board-close)
      (forward-line 1)
      (return-from search-select-lines))
    (if (file-exist-p (thread-path-data (tracking-list-host track)
					(tracking-list-path track)
					(tracking-list-dat track)))
	(search-select)
      (let* ((lines (read-number "Lines: " (format nil "~D" *board-read-first*)))
	     (*thread-max-lines* lines))
	(declare (special *thread-max-lines*))
	(search-select)))))

(defun search-select ()
  (interactive)
  (let ((track-name board-name)
	(parent (buffer-name (selected-buffer))))
    (multiple-value-bind (track number)
	(tracking-line)
      (unless track
	(board-close)
	(forward-line 1)
	(return-from search-select))
      (when (tracking-uplist-nump number)
	(tracking-uplist-delnum number)
	(board-update-line))
      (reverse-line)
      (recenter *board-recenter*)
      ;(refresh-screen)
      (board-split)
      (thread-show (tracking-list-name track)
		   (tracking-list-host track)
		   (tracking-list-path track)
		   (tracking-list-dat track)
		   (tracking-list-title track)
		   (tracking-list-num track)
		   *online*
		   nil
		   parent))))

(defun search-save-as-tracking ()
  (interactive)
  (let ((track-name (read-string "グループ名: ")))
    (when (tracking-menu-p track-name)
      (error "もうあります: ~A" track-name))
    (tracking-write track-name board-list)
    (menu-update)
    (message "\"~A\"を保存しました。" track-name)))

(defun search-update-marked (&optional ignore-error)
  (interactive)
  (let (updated
	(i 0)
	(current (current-line-number)))
    (dolist (i board-mark)
      (goto-line i)
      (multiple-value-bind (track number)
	  (tracking-line)
	(reverse-line)
	(refresh-screen)
	(handler-case
	    (when (tracking-update track number)
	      (push track updated))
	  (quit (c)
	    (error "Interrupted.")) ; <= ここにはこない？
	  (error (c)
	    (let ((msg (si:*condition-string c)))
	      (unless (or ignore-error
			  (yes-or-no-p "エラー：続行しますか？~%~%~A" msg))
		(return)))))
      ))
    (clear-reverse-region)
    (goto-line current)
    (gc)
    (message "~D スレ更新" (list-length updated))
    (run-hooks '*search-update-marked-hook*)
    (nreverse updated)))

(defun search-quit ()
  (interactive)
  (if (and board-buffer-parent
	   (find-buffer board-buffer-parent))
      (set-buffer board-buffer-parent)
    (board-quit)))

(defun search-send-marked ()
  (interactive)
  (tracking-send-marked nil nil))

(defun search-send-marked-dialog ()
  (interactive)
  (tracking-send-marked t nil))

(define-key *search-map* #\* 'tracking-mark-toggle)
(define-key *search-map* '(#\m #\m) 'tracking-mark-set)
(define-key *search-map* '(#\m #\M) 'tracking-mark-set-all)
(define-key *search-map* '(#\m #\d) 'tracking-mark-unset)
(define-key *search-map* '(#\m #\D) 'tracking-mark-unset-all)

(define-key *search-map* '(#\m #\s) 'search-send-marked)
(define-key *search-map* '(#\m #\S) 'search-send-marked-dialog)
(define-key *search-map* '(#\m #\u) 'search-update-marked)
(define-key *search-map* '(#\m #\M-k) 'tracking-copy-marked)

(define-key *search-map* '(#\m #\k) 'tracking-mark-set-kako)
(define-key *search-map* '(#\m #\o) 'tracking-mark-set-old)
(define-key *search-map* '(#\m #\n) 'tracking-mark-set-nouse)
(define-key *search-map* '(#\m #\/) 'tracking-mark-set-query)
(define-key *search-map* '(#\m #\t) 'tracking-mark-set-tracking)
(define-key *search-map* '(#\m #\T) 'tracking-mark-set-tracking-reverse)
(define-key *search-map* '(#\m #\r) 'tracking-mark-set-reverse)

(define-key *search-map* '(#\m #\M-d) 'tracking-thread-delete-marked-dat)
(define-key *search-map* '(#\m #\M-D) 'tracking-thread-delete-marked-dat-tbk)
