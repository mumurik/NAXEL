; $Id: board.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/board")

(in-package "2ch")

(defvar *buffer-board* "2ch: Board")
(defvar *buffer-board-temp* "2ch: Board Temp")

(defvar *board-window* nil)

(defvar *board-data-file-name* "subject.txt")
(defvar *board-rule-file-name* "SETTING.TXT")
(defvar *board-head-file-name* "head.txt")

(defvar *board-mode-hook* nil)
(defvar *board-show-hook* nil)

(defvar *board-height* 5)
(defvar *board-recenter* (floor (/ *board-height* 2)))
(defvar *board-scroll-margin* 5)
(defvar *board-title-width* 60)
(defvar *board-name-width* 15)
(defvar *board-date-width* 22)
(defvar *board-date-format* "%Y/%m/%d(%v) %H:%M")

(defvar *board-max-lines* nil)

(defvar *board-wtime-check* nil)

(defvar *board-read-first* 10)

(defvar *board-new-days* 3)

(defvar *mark-char-tracking* "T")
(defvar *mark-char-space* " ")
(defvar *mark-char-read* "R")
(defvar *mark-char-kako* "K")
(defvar *mark-char-mark* "*")

(defvar *board-fgcolor-number* 0)
(defvar *board-fgcolor-tracking* 0)
(defvar *board-fgcolor-kako* 0)
(defvar *board-fgcolor-mark* 0)
(defvar *board-fgcolor-title* 0)
(defvar *board-fgcolor-num* 0)
(defvar *board-fgcolor-name* 0)
(defvar *board-fgcolor-wtime* 0)
(defvar *board-fgcolor-read* 0)

(defvar *board-bgcolor-number* 0)
(defvar *board-bgcolor-tracking* 0)
(defvar *board-bgcolor-kako* 0)
(defvar *board-bgcolor-mark* 0)
(defvar *board-bgcolor-title* 0)
(defvar *board-bgcolor-num* 0)
(defvar *board-bgcolor-name* 0)
(defvar *board-bgcolor-wtime* 0)
(defvar *board-bgcolor-read* 0)

(defvar *board-map* nil)
(setq *board-map* (make-sparse-keymap))
(define-key *board-map* #\RET 'board-select)
(define-key *board-map* #\M-RET 'board-select-lines)
(define-key *board-map* #\SPC 'board-select)
(define-key *board-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *board-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *board-map* #\TAB 'tracking-next-updated)
(define-key *board-map* #\q 'board-close)
(define-key *board-map* #\a 'board-tracking-add)
(define-key *board-map* #\A 'board-tracking-add-dialog)
(define-key *board-map* #\o 'tracking-thread-open-browser)
(define-key *board-map* #\O 'board-open-browser)
(define-key *board-map* #\r 'board-update)
(define-key *board-map* #\R 'board-reload)
;(define-key *board-map* #\w 'board-form)
(define-key *board-map* #\w 'board-open-browser)
(define-key *board-map* #\s 'board-search)
(define-key *board-map* #\n 'board-new-show)
(define-key *board-map* #\/ 'board-grep)
(define-key *board-map* #\? 'board-grep-dialog)
(define-key *board-map* #\C 'tracking-thread-url-copy)
(define-key *board-map* #\t 'tracking-thread-title-copy)
(define-key *board-map* #\T 'tracking-thread-url-title-copy)
(define-key *board-map* #\M-d 'tracking-thread-delete-dat)
(define-key *board-map* #\M-D 'tracking-thread-delete-dat-tbk)
(define-key *board-map* #\u 'tracking-update-current)
(define-key *board-map* #\M-t 'toggle-online)
(define-key *board-map* '(#\C-c #\r) 'board-rule)
(define-key *board-map* '(#\C-c #\R) 'board-rule-force)
(define-key *board-map* #\l 'board-show-read-dat)
(define-key *board-map* #\L 'board-show-read-dat-kako)
(define-key *board-map* #\Q 'exit)

(defun board-dir (host path)
  (concat host path))

(defun board-path (host path)
  (merge-pathnames (board-dir host path) *base-directory*))

(defun board-url (host path)
  (concat "http://" (board-dir host path)))

(defun board-url-data (host path)
  (concat (board-url host path) *board-data-file-name*))

(defun board-url-cgi-data (host path)
  (let ((adr (thread-cgi-url host path))
	(bbs (form-bbs path)))
    (format nil "~A/~A/?raw=0.0" adr bbs)))

(defun board-path-data (host path)
  (merge-pathnames *board-data-file-name* (board-path host path)))

(defun board-dir-data (host path)
  (concat (board-dir host path) *board-data-file-name*))

(defun board-quit ()
  (interactive)
  (clear-reverse-region)
  (set-buffer-menu)
  (delete-other-windows)
  (setq *board-window* nil))

(defun board-thread-name (host path dat-file &optional reload)
  (let ((data-file (board-path-data host path))
	regexp)
    (save-excursion
      (set-buffer-temp)
      (when (or reload
		(not (file-exist-p data-file)))
	(board-get host path))
      (insert-file-contents data-file)
      (goto-char (point-min))
      (setq regexp (board-regexp-test))
      (let ((line "")
	    (i 0))
	(with-input-from-selected-buffer
	  (while (setq line (read-line nil nil))
	    (incf i)
	    (when (string-match regexp line)
	      (let ((dat (substring line (match-beginning 1) (match-end 1)))
		    (title (string-trim " " (substring line (match-beginning 2) (match-end 2))))
		    (num (substring line (match-beginning 3) (match-end 3))))
		(setq title (thread-parse-special-strings title))
		(when (equal dat dat-file)
		  (return-from board-thread-name
		    (values title num i)))))))))))

(defun board-thread-dat-files (host path)
  (let (dat-files
	arc-files)
    (setq dat-files (directory (thread-path host path)
			       :wild "*.dat"))
    (when (setq arc-files (thread-archive-board-files host path))
      (mapc #'(lambda (x)
		(pushnew x dat-files :test #'equal))
	    arc-files))
    ;(msgbox "~S~%~%~S" dat-files arc-files)
    dat-files))

(defun board-show (name host path &optional force reload)
  (split-2)
  (let* ((data-file (board-path-data host path))
	 (bufname (board-buffer-name name host path))
	 (track-list (tracking-list-board host path))
	 (data-exist (file-exist-p data-file))
	 buf-exist
	 dat-files
	 regexp)
    ; buffer がすでにあった場合
    (when (setq buf-exist (find-buffer bufname))
      (set-buffer-board name host path)
      (if force
	  (refresh-screen)
	(return-from board-show)))
    ; アーカイブから解凍
;    (unless data-exist
;      (setq data-exist
;	    (board-get-archive host path)))
    (when (or force
	      (not data-exist))
      (board-get host path reload))
    (set-buffer-board-temp)
    (insert-file-contents data-file)
    (goto-char (point-min))
    (unless (setq regexp (board-regexp-test))
      (error "スレ一覧の形式がわからんよ: ~A" data-file))
    (when (and (not force)
	       (find-buffer bufname))
      (set-buffer bufname)
      (return-from board-show))
    (when *thread-read-check*
      (setq dat-files (board-thread-dat-files host path)))
    (set-buffer-board name host path)
    (setq board-regexp regexp)
    (let ((line "")
	  (i 0)
	  (buffer-read-only nil)
	  list)
      (declare (special buffer-read-only))
      (erase-buffer (selected-buffer))
      (message "2ch: parsing board \"~A\" ..." name)
      (with-input-from-buffer (*buffer-board-temp*)
	(while (setq line (read-line nil nil))
	  (when (string-match board-regexp line)
	    (incf i)
	    (let ((dat (substring line (match-beginning 1) (match-end 1)))
		  (title (string-trim " " (substring line (match-beginning 2) (match-end 2))))
		  (num (substring line (match-beginning 3) (match-end 3))))
	      ; num が数字ではなかった場合の対処
	      (unless (string-match "^[0-9]+$" num)
		(setq num "0"))
	      (setq title (thread-parse-special-strings title))
	      (board-insert-line dat title num board-name i
				 :bold (tracking-uplist-nump i)
				 :tracking (board-tracking-p dat track-list)
				 :read  (and *thread-read-check*
					     (member dat dat-files :test #'equal))
				 :wtime (and *board-wtime-check*
					     (thread-data-wtime host path dat)))
	      (push (list name host path dat title num) list)))))
      (setq board-list (reverse list))
      (message "2ch: parsing board \"~A\" ... done." name)
      (goto-char (point-min)))
    (run-hooks '*board-show-hook*)))

(defun board-get-archive (host path)
  (let ((file (board-path-data host path))
	(dir-data (board-dir-data host path)))
    (when (file-exist-p *thread-archive-file*)
      (when (thread-archive-exist dir-data)
	(extract-archive *thread-archive-file*
			 *base-directory*
			 dir-data))
      (file-exist-p file))))

(defun board-tracking-p (dat list)
  (member dat list :test #'equal :key #'cadddr))

(defun board-insert-line (dat title num name i &key bold tracking read kako mark wtime)
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~3,'0D"i))
			(point))
		      'number
		      :foreground *board-fgcolor-number*
		      :background *board-bgcolor-number*
		      :bold bold
  );3
  (insert " ")
  (set-text-attribute (point)
		      (progn
			(insert (if tracking
				    (if kako
					*mark-char-kako*
				      *mark-char-tracking*)
				  *mark-char-space*))
			(point))
		      'tracking
		      :foreground (if kako *board-fgcolor-kako* *board-fgcolor-tracking*)
		      :background (if kako *board-bgcolor-kako* *board-bgcolor-tracking*)
		      :bold bold
  )
  (set-text-attribute (point)
		      (progn
			(insert (if read
				    *mark-char-read*
				  *mark-char-space*))
			(point))
		      'tracking
		      :foreground *board-fgcolor-read*
		      :background *board-bgcolor-read*
		      :bold bold
  )
  (set-text-attribute (point)
		      (progn
			(insert (if mark
				    *mark-char-mark*
				  *mark-char-space*))
			(point))
		      'tracking
		      :foreground *board-fgcolor-mark*
		      :background *board-bgcolor-mark*
		      :bold bold
  )
  (set-text-attribute (point)
		      (progn
			;(insert (format nil (format nil "~~~D@A" *board-title-width*) title))
			(insert (format nil "~VA" *board-title-width* title))
			(point))
		      'title
		      :foreground *board-fgcolor-title*
		      :background *board-bgcolor-title*
		      :bold bold
  )
  ;(insert (format nil (format nil "~~~D@A " width) name))
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~6@A" (format nil "(~3@A)" num)))
			(point))
		      'num
		      :foreground *board-fgcolor-num*
		      :background *board-bgcolor-num*
		      :bold bold
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "  ~VA" *board-name-width* (format nil "[~A]" name)))
			(point))
		      'name
		      :foreground *board-fgcolor-name*
		      :background *board-bgcolor-name*
		      :bold bold
  )
  (set-text-attribute (point)
		      (progn
			(insert (format nil "~VA"
					*board-date-width*
					(if wtime
					    (format nil "[~A]" (view-format-date wtime
										 *board-date-format*))
					  "")))
			(point))
		      'date
		      :foreground *board-fgcolor-wtime*
		      :background *board-bgcolor-wtime*
		      :bold bold
  )
  (insert "\n")
  ;(message-box (format nil "~S" tmp))
)

(defun board-reload ()
  (interactive)
  (board-update t))

(defun board-update (&optional reload)
  (interactive)
  (board-show board-name
	      board-host
	      board-path
	      t
	      reload))

(defun board-regexp-test ()
  (dolist (reg *board-regexp-list*)
    (when (looking-at reg)
      (return-from board-regexp-test reg))))

(defun board-get (host path &optional force)
  (interactive)
  (let ((read-cgi-p (read-cgi-host-p host))
	url
	(file (board-path-data host path)))
    (if read-cgi-p
	(progn
	  (setq url (board-url-cgi-data host path))
	  (http-get-thread url
			   file
			   force))
      (progn
	(setq url (board-url-data host path))
	(http-get url
		  file
		  force
		  :lines *board-max-lines*)))))

(defun board-buffer-name (name host path)
  (format nil "~A: [~A] ~A" *buffer-board* name (board-path-data host path)))

(defun set-buffer-board (name host path)
  (let ((bufname (board-buffer-name name host path)))
    (if (find-buffer bufname)
	(progn
	  (set-buffer bufname)
	  t)
      (progn
	(set-buffer (get-buffer-create bufname))
	(board-mode)
	(setq board-name name)
	(setq board-host host)
	(setq board-path path)
	nil))
  ))

#|
(defvar *board-regexp-list*
  (list (compile-regexp "^\\([0-9]+\.dat\\)<>\\(.*\\)<\\([0-9]+\\)>$")
	(compile-regexp "^\\([0-9]+\.dat\\),\\(.*\\)（\\([0-9]+\\)）$")
	(compile-regexp "^\\([0-9]+\.dat\\),\\(.*\\)(\\([0-9]+\\))$")))
|#

(defvar *board-regexp-list*
  (list (compile-regexp "^\\([0-9]+\.dat\\)<>\\(.*\\)[<(]\\([0-9]+\\)[>)]$") 
	(compile-regexp "^\\([0-9]+\.dat\\),\\(.*\\)（\\([0-9]+\\)）$")
	(compile-regexp "^\\([0-9]+\.dat\\),\\(.*\\)(\\(.*\\))$")))

(defun board-mouse-left-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (goto-last-mouse-point)
  (board-select))

(defun board-thread-select ()
  (interactive)
  (let ((parent (buffer-name (selected-buffer)))
	dat title num name host path)
    (setq name board-name)
    (setq host board-host)
    (setq path board-path)
    (multiple-value-bind (track number)
	(board-line)
      (setq dat (tracking-list-dat track))
      (setq title (tracking-list-title track))
      (setq num (tracking-list-num track))
      (unless (and dat title num)
	(board-close)
	(return-from board-thread-select))
      (when (tracking-uplist-nump number)
	(tracking-uplist-delnum number)
	(board-update-line))
      (reverse-line)
      (recenter *board-recenter*)
      (board-split)
      (thread-show name host path dat title num *online* nil parent)
    )))

(defun board-select-lines ()
  (interactive)
  (multiple-value-bind (track number)
      (board-line)
    (let ((dat (tracking-list-dat track))
	  (title (tracking-list-title track))
	  (num (tracking-list-num track)))
      (unless (and dat title num)
	(board-close)
	(return-from board-select-lines))
      (if (file-exist-p (thread-path-data board-host board-path dat))
	  (board-select)
	(let* ((lines (read-number "Lines: " (format nil "~D" *board-read-first*)))
	       (*thread-max-lines* lines))
	  (declare (special *thread-max-lines*))
	  (board-select))))))

#|
(defun board-line ()
  (multiple-value-bind (track number)
      (tracking-line)
    (values (tracking-list-dat track)
	    (tracking-list-title track)
	    (tracking-list-num track))))
|#

(defun board-line ()
  (tracking-line))

(defun board-tracking-add (&optional dialog)
  (interactive)
  (multiple-value-bind (track number)
      (tracking-line)
    (when track
      (when (tracking-add track
			  nil
			  nil
			  dialog)
	(message "~Aに\"~A\"を追加しました。" *tracking-name* (tracking-list-title track))))))

(defun board-tracking-add-dialog ()
  (interactive)
  (board-tracking-add t))

(defun board-split ()
  (let ((cur (buffer-name (selected-buffer))))
    (split-2)
    (set-buffer cur)
    (when *board-height*
      (split-window *board-height*)
      (other-window 1))
    (setq *thread-window* (selected-window))))

(defun board-open-browser ()
  (interactive)
  (open-browser (board-url board-host board-path)))

(defun board-url-copy ()
  (interactive)
  (let ((url (board-url board-host board-path)))
    (copy-to-clipboard url)
    (message "~A" url)))

(defun board-name-copy ()
  (interactive)
  (copy-to-clipboard board-name)
  (message "~A" board-name))

(defun board-url-name-copy ()
  (interactive)
  (let ((url (board-url board-host board-path)))
    (copy-to-clipboard (board-url-name-format name url))
    (message "~A" board-name)))

(defun board-url-name-format (name url)
  (format nil "~@[~A板~%~]~@[~A~]" name url))

(defun board-form ()
  (interactive)
  (let ((cur (buffer-name (selected-buffer)))
	(name board-name)
	(host board-host)
	(path board-path))
    (split-2)
    (set-buffer cur)
    (refresh-screen)
    (form-create name host path)))

(defun board-mode ()
  (setq buffer-mode '2ch-board)
  (setq mode-name *mode-name*)
  (make-local-variable 'board-name)
  (setq board-name nil)
  (make-local-variable 'board-host)
  (setq board-host nil)
  (make-local-variable 'board-path)
  (setq board-path nil)
  (make-local-variable 'board-regexp)
  (setq board-regexp nil)
  (make-local-variable 'board-list)
  (setq board-list nil)
  (make-local-variable 'board-mark)
  (setq board-mark nil)
  (make-local-variable 'board-buffer-parent)
  (setq board-buffer-parent nil)
  (make-local-variable 'tracking-uplist)
  (setq tracking-uplist nil)
  (make-local-variable '*scroll-margin*)
  (setq *scroll-margin* *board-scroll-margin*)
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
  (set-local-window-flags (selected-buffer)
			  *window-flag-cursor-line* t)
  (set-buffer-fold-width nil)
  (use-keymap *board-map*)
  (run-hooks '*board-mode-hook*))

(defun set-buffer-board-temp ()
  (set-buffer (get-buffer-create *buffer-board-temp*))
  (setq need-not-save t)
  (erase-buffer (selected-buffer)))

(defun board-url-rule (host path)
  (concat (board-url host path) *board-rule-file-name*))

(defun board-path-rule (host path)
  (merge-pathnames *board-rule-file-name* (board-path host path)))

(defun board-dir-rule (host path)
  (concat (board-dir host path) *board-rule-file-name*))

(defun board-url-head (host path)
  (concat (board-url host path) *board-head-file-name*))

(defun board-path-head (host path)
  (merge-pathnames *board-head-file-name* (board-path host path)))

(defun board-dir-head (host path)
  (concat (board-dir host path) *board-head-file-name*))

(defun board-get-rule (host path &optional force)
  (interactive)
  (let ((url (board-url-rule host path))
	(file (board-path-rule host path)))
    (http-get url
	      file
	      force)))

(defun board-get-head (host path &optional force)
  (interactive)
  (let ((url (board-url-head host path))
	(file (board-path-head host path)))
    (handler-case
	(http-get url
		  file
		  force)
      (error (c)
	(let ((msg (si:*condition-string c)))
	  (message "Error: ~A" msg)
	  (when (string-match "Status: \\(404\\|302\\)" msg)
	    (with-open-file (s file :direction :output)))))
      (quit (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Interrupted: ~A" (si:*condition-string c)))
    )))

(defun board-rule-load (file)
  (let (rules)
    (when (file-exist-p file)
      (with-open-file (s file
			 :direction :input)
	(let (line key val)
	  (while (setq line (read-line s nil))
	    (cond ((string-match "^\\([a-zA-Z0-9_]+\\)=\\(.*\\)$" line)
		   (setq key (substring line (match-beginning 1) (match-end 1)))
		   (setq val (substring line (match-beginning 2) (match-end 2)))
		   (push (cons key val) rules))
		  ((and key val (not (equal "" line)))
		   (setq val (concat val "\n" line))
		   (setf (cdr (assoc key rules :test #'equal)) val)))))))
    (nreverse rules)))

(defun board-head-format ()
  (save-excursion
    (goto-char (point-min))
    (replace-string "\n" "" t)
    (goto-char (point-min))
    (replace-regexp "<[bB][rR]>" "\n" t)
    (goto-char (point-min))
    (replace-regexp "<[pP]>" "\n\n" t)
    (goto-char (point-min))
    (replace-regexp "</?[uU][lL]>" "\n" t)
    (goto-char (point-min))
    (replace-regexp "<[lL][iI]>" "\n・" t)
    (goto-char (point-min))
    (replace-regexp "<[dD][tT]>" "\n" t)
    (goto-char (point-min))
    (while (scan-buffer "<[^>]+>" :regexp t)
      (delete-region (match-beginning 0) (match-end 0)))))

(defun board-head-load (file)
  (when (file-exist-p file)
    (save-excursion
      (set-buffer-temp)
      (insert-file-contents file)
      (goto-char (point-min))
      (board-head-format)
      (buffer-substring (point-min) (point-max)))))

(defun board-rule-show (name host path &optional force reload)
  (let* ((rule-file (board-path-rule host path))
	 (head-file (board-path-head host path))
	 (rule-exist (file-exist-p rule-file))
	 (head-exist (file-exist-p head-file))
	 (text nil)
	 (rules nil))
    (when (or force
	      *online*
	      (not rule-exist))
      (board-get-rule host path reload))
    (when (or force
	      *online*
	      (not head-exist))
      (board-get-head host path reload))
    (unless (file-exist-p rule-file)
      (error "ファイルがないっす: ~A" rule-file))
    (setq rules (board-rule-load rule-file))
    (when (file-exist-p head-file)
      (setq text (board-head-load head-file)))
    (and *debug* (msgbox "~{~S~%~}~%~A" rules text))
    (message-box (board-rule-format rules text)
		 (format nil "~A板" name))))

(defun board-rule-value (rules key)
  (cdr (assoc key rules :test #'equal)))

(defun board-rule-proxy (rules)
  (let ((proxy (board-rule-value rules "BBS_PROXY_CHECK"))
	(timecheck (board-rule-value rules "timecheck"))
	(timecount (board-rule-value rules "timecount"))
	(timeclose (board-rule-value rules "timeclose")))
    (and (stringp proxy)
	 (string-match "checked" proxy)
	 "Proxy規制中")))

(defun board-rule-format (rules text)
  (format nil
	  "~@[「~A」~%~]~%~@[~A~%~]名無しは \"~@[~A~]\"~%~@[~%~A~]"
	  (board-rule-value rules "BBS_TITLE")
	  (board-rule-proxy rules)
	  (board-rule-value rules "BBS_NONAME_NAME")
	  text))

(defun board-rule-force ()
  (interactive)
  (board-rule t))

(defun board-rule (&optional force reload)
  (interactive)
  (board-rule-show board-name
		   board-host
		   board-path
		   force
		   reload))

(defun board-refresh (&optional list)
  (setq list (or list board-list))
  (let* ((line "")
	 (name board-name)
	 (host board-host)
	 (path board-path)
	 (data-file (board-path-data host path))
	 (bufname (board-buffer-name name host path))
	 (track-list (tracking-list-board host path))
	 (current (current-line-number))
	 dat-files
	 (i 0)
	 (buffer-read-only nil))
    (declare (special buffer-read-only))
    (erase-buffer (selected-buffer))
    (when *thread-read-check*
      (setq dat-files (board-thread-dat-files host path)))
    (mapc #'(lambda (track)
	      (incf i)
	      (let ((dat (tracking-list-dat track))
		    (title (tracking-list-title track))
		    (num (tracking-list-num track)))
		(board-insert-line dat title num name i
				   :tracking (tracking-list-p track)
				   :read (and *thread-read-check*
					     (member dat dat-files :test #'equal))
				   :mark (board-mark-p i)
				   :wtime (and *board-wtime-check*
					       (thread-data-wtime host path dat)))))
	  list)
    (goto-line current)))

(defun board-update-emphasis ()
  (interactive)
  (let* ((new-file (board-path-data board-host board-path))
	 (old-file (concat new-file ".old")))
    (unless (equal buffer-mode
		   '2ch-board)
      (return-from board-update-emphasis))
    (unless (file-exist-p new-file)
      (return-from board-update-emphasis))
    (unless (file-exist-p old-file)
      (copy-file new-file old-file :if-exists :overwrite)
      (return-from board-update-emphasis))
    (when (<= (file-write-time new-file)
	      (file-write-time old-file))
      (return-from board-update-emphasis))
    (let* ((line "")
	   (new-list board-list)
	   (new-lines (list-length new-list))
	   (regexp board-regexp)
	   (name board-name)
	   update-list)
      (message "2ch: parsing old board \"~A\" ..." name)
      (save-excursion
	(set-buffer-board-temp)
	(insert-file-contents old-file)
	(goto-char (point-min))
	(with-input-from-buffer (*buffer-board-temp*)
	  (while (setq line (read-line nil nil))
	    (when (string-match regexp line)
	      (let ((dat (match-string 1))
		    (num (match-string 3))
		    matched)
		(when (setq matched (member dat new-list
					    :test #'equal
					    :key #'(lambda (x)
						     (tracking-list-dat x))))
		  (unless (equal num (tracking-list-num (car matched)))
		    (push (1+ (- new-lines
				 (list-length matched)))
			  update-list))))))))
      (message "2ch: parsing old board \"~A\" ... done." name)
      (when update-list
	(message "2ch: updating board \"~A\" ..." name)
	(setq tracking-uplist nil)
	(copy-file new-file old-file :if-exists :overwrite)
	(save-excursion
	  (mapc #'(lambda (x)
		    (tracking-uplist-addnum x)
		    (goto-line x)
		    (board-update-line))
		update-list))
	(message "2ch: updating board \"~A\" ... done." name)))))

(defun board-update-line ()
  (let* ((buffer-read-only nil))
    (declare (special buffer-read-only))
    (multiple-value-bind (track number)
	(tracking-line)
      (when track
	(let ((name (tracking-list-name track))
	      (host (tracking-list-host track))
	      (path (tracking-list-path track))
	      (dat (tracking-list-dat track))
	      (title (tracking-list-title track))
	      (num (tracking-list-num track)))
	  (save-excursion
	    (delete-region (progn (goto-bol) (point))
			   (progn (forward-line 1) (point)))
	    (board-insert-line dat title num name number
			       :bold (tracking-uplist-nump number)
			       :tracking (tracking-list-p track)
			       :read (and *thread-read-check*
					  (thread-data-read-p host path dat))
			       :kako (thread-dat-kako-p dat)
			       :mark (board-mark-p number)
			       :wtime (and (cond ((equal buffer-mode '2ch-board)
						  *board-wtime-check*)
						 ((equal buffer-mode '2ch-tracking)
						  *tracking-wtime-check*)
						 ((equal buffer-mode '2ch-search)
						  *search-wtime-check*))
					   (thread-data-wtime host path dat)))))))))

(defun board-dat-files (dir)
  (directory dir :wild "*.dat"))

(defun board-kako-files (dir)
  (let ((tmp (directory dir :wild "*.dat" :recursive t)))
    (mapcar #'(lambda (x)
		(thread-dat2kako (file-namestring x)))
	    tmp)))

(defun board-archive-dat-files (dir)
  (let (dat)
    (when (find-buffer *buffer-archive*)
      (save-excursion
	(set-buffer *buffer-archive*)
	(goto-char (point-min))
	(while (scan-buffer (concat "^" dir "\\([0-9]+\\.dat\\)$")
			    :regexp t
			    :tail t)
	  (push (match-string 1) dat))))
    (nreverse dat)))

(defun board-archive-kako-files (dir)
  (let (dat)
    (when (find-buffer *buffer-archive*)
      (save-excursion
	(set-buffer *buffer-archive*)
	(goto-char (point-min))
	(while (scan-buffer (concat "^" dir "[0-9]+/\\([0-9]+\\.dat\\)$")
			    :regexp t
			    :tail t)
	  (push (thread-dat2kako (match-string 1)) dat))))
    (nreverse dat)))

(defun board-list-dat (host path &optional archive kako)
  (let ((dat-dir (thread-path host path))
	(kako-dir (thread-path-kako host path))
	(dat-arc (thread-dir host path))
	(kako-arc (thread-dir-kako host path))
	dat-files
	kako-files
	tmp)
    (long-operation
      (message "2ch: parsing directory: ~A ..." dat-dir)
      (setq dat-files (board-dat-files dat-dir))
      (when archive
	(dolist (dat (board-archive-dat-files dat-arc))
	  (unless (member dat dat-files :test #'equal)
	    (push dat tmp)))
	(when tmp
	  (setq dat-files (append dat-files tmp))
	  (setq tmp nil)))
      (when kako
	(message "2ch: parsing directory: ~A ..." kako-dir)
	(setq kako-files (board-kako-files kako-dir))
	(when archive
	  (dolist (kako (board-archive-kako-files kako-arc))
	    (unless (member kako kako-files :test #'equal)
	      (push kako tmp)))
	  (when tmp
	    (setq kako-files (appned kako-files tmp))))
	(setq dat-files (append dat-files kako-files)))
      (message "2ch: parsing directory ... done."))
    dat-files))

(defun board-dat-thread (dat list)
  (car (board-dat-thread-p dat list)))

(defun board-dat-thread-p (dat list)
  (member dat list :test #'equal :key #'(lambda (x)
					  (tracking-list-dat x))))

(defun board-show-read-dat-kako (&optional archive)
  (interactive "p")
  (board-show-read-dat archive t))

(defun board-show-read-dat (&optional archive kako)
  (interactive "p")
  (let ((board board-name)
	(host board-host)
	(path board-path)
	(data board-list)
	current
	old
	tmp
       )
    (dolist (dat (board-list-dat host path archive kako))
      (if (setq tmp (board-dat-thread dat data))
	  (push tmp current)
	(let ((title (or (thread-dat-get-title (thread-path-data host path dat))
			 "")))
	  (push (list board host path dat title "0") old))))
    (board-dat-list-show board
			 host
			 path
			 (nreverse current)
			 (nreverse old))
  ))

(defun board-dat-list-show (board host path current old)
  (let ((bufname (buffer-name (selected-buffer)))
	start
	stop
	marks)
    (set-buffer-search board)
    (setq board-buffer-parent bufname)
    (setq board-list (append current old))
    (setq start (list-length current))
    (setq stop (list-length board-list))
    (while (< start stop)
      (incf start)
      (let ((track (nth (1- start) board-list)))
	(unless (thread-dat-kako-p (tracking-list-dat track))
	  (push start marks))))
    (setq board-mark (nreverse marks))
    (search-redraw)))

(define-key *board-map* #\* 'tracking-mark-toggle)
(define-key *board-map* '(#\m #\m) 'tracking-mark-set)
(define-key *board-map* '(#\m #\M) 'tracking-mark-set-all)
(define-key *board-map* '(#\m #\d) 'tracking-mark-unset)
(define-key *board-map* '(#\m #\D) 'tracking-mark-unset-all)

(define-key *board-map* '(#\m #\s) 'search-send-marked)
(define-key *board-map* '(#\m #\S) 'search-send-marked-dialog)
(define-key *board-map* '(#\m #\u) 'search-update-marked)
(define-key *board-map* '(#\m #\M-k) 'tracking-copy-marked)

(define-key *board-map* '(#\m #\k) 'tracking-mark-set-kako)
(define-key *board-map* '(#\m #\o) 'tracking-mark-set-old)
(define-key *board-map* '(#\m #\n) 'tracking-mark-set-nouse)
(define-key *board-map* '(#\m #\/) 'tracking-mark-set-query)
(define-key *board-map* '(#\m #\t) 'tracking-mark-set-tracking)
(define-key *board-map* '(#\m #\T) 'tracking-mark-set-tracking-reverse)
(define-key *board-map* '(#\m #\r) 'tracking-mark-set-reverse)

(define-key *board-map* '(#\m #\M-d) 'tracking-thread-delete-marked-dat)
(define-key *board-map* '(#\m #\M-D) 'tracking-thread-delete-marked-dat-tbk)
