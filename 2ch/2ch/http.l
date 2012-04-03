;$Id: http.l 395 2005-11-07 18:01:25Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "www/www"))

(provide "2ch/http")

(in-package "2ch")

(defvar *http-buffer-name* "2ch: HTTP")

(defvar *http-compare-size* t)

(defvar *http-accept-encoding* nil)

(defvar *http-gzip-buffer-name* "2ch: GZIP")

(defvar *http-map* nil)
(setq *http-map* (make-sparse-keymap))
(define-key *http-map* #\RET 'http-quit)
(define-key *http-map* #\LBtnUp '2ch-mouse-left-press)
(define-key *http-map* #\RBtnUp '2ch-mouse-right-press)
(define-key *http-map* #\S 'http-show-status)
(define-key *http-map* #\q 'http-quit)
(define-key *http-map* #\Q 'exit)

(defconstant *read-cgi-ok* "+OK")
(defconstant *read-cgi-incr* "-INCR")
(defconstant *read-cgi-err* "-ERR")

(defconstant *post-result-ok* "<!-- 2ch_X:true -->")       ; 正常終了：（正常に書き込みが終了）
(defconstant *post-result-false* "<!-- 2ch_X:false -->")   ; 注意終了：（書き込みはしたが注意つき）
(defconstant *post-result-error* "<!-- 2ch_X:error -->")   ; エラー表示：（今はＥＲＲＯＲ！のタイトル）
(defconstant *post-result-check* "<!-- 2ch_X:check -->")   ; 書き込み確認：（スレ立てなど書き込み別画面
(defconstant *post-result-cookie* "<!-- 2ch_X:cookie -->") ; クッキー確認：（クッキーを食べさせる画面）

(defun set-buffer-http ()
  (set-buffer (get-buffer-create *http-buffer-name*))
  (http-mode))

(defun http-error-string (status header &optional request)
  (let (str tmp)
    (setq str (format nil "~@[~A~%~%~]Status: ~A~%~%" request (or status "")))
    (dolist (tmp header)
      (let ((key (car tmp))
	    (val (cadr tmp)))
	(setq str (format nil
			  "~A~A: ~A~%"
			  str
			  (string-capitalize (or key ""))
			  (or val "")))))
    str))

(defun http-get-last-line (file)
  "ファイルの最終行の内容・行番号を返す"
  (let (line number)
    (save-excursion
      (set-buffer-temp)
      (insert-file-contents file)
      (goto-char (point-max))
      (when (bolp)
	(setq line
	      (buffer-substring (point)
				(progn
				  (previous-line)
				  (point))))
	(setq number (current-line-number))))
    (values line number)))

(defun http-head (url)
  (let ((www::*www-user-agent* *2ch-user-agent*))
    (declare (special www::*www-user-agent*))
    (multiple-value-bind (sock status header)
	(www::www-http-get-url url :head t)
      (close sock)
      (values status header))))

(defun http-create-file-directory (file)
  (let ((dir (directory-namestring file)))
    (unless (file-exist-p dir)
      (create-directory dir))))

(defvar *2ch-user-agent-orig* nil)

(defun 2ch-dolib-init (&optional force)
  (when *2ch-use-dolib*
    (unless *2ch-user-agent-orig*
      (setq *2ch-user-agent-orig* *2ch-user-agent*))
    (dolib-init force)
    (setq *2ch-user-agent*
	  (format nil "~A (~A)"
		  (dolib-current-user-agent)
		  *version-name*))))

(defun http-get-thread-offlaw (url file &optional force &key append compare lines referer)
  (interactive)
  (let (sock
	status
	header
	request
	(size 0)
	wtime
	other
	range
	compare-line
	(compare-number 0)
	gzip-p
	read-cgi-ok-p
	(url-orig url)
	result
	www::*www-user-agent*)
    (declare (special www::*www-user-agent*))
    (2ch-dolib-init)
    (setq www::*www-user-agent* *2ch-user-agent*)
    (when *debug*
      (msgbox "URL:~S~%FILE:~S~%FORCE:~S~%APPEND:~S~%COMPARE:~S~%LINES:~S~%REFERER:~S"
	      url file force append compare lines referer))
    ; ローカルディレクトリがなければ作成
    (http-create-file-directory file)
    ; force not append
    (when force
      (setq append nil))
    ; 既にファイルがある場合
    (when (file-exist-p file)
      (unless force
	(setq size (file-length file))
	(setq wtime (file-write-time file))
	; Range: 追加差分取得
	(when append
	  ; チェック文字列を取得
	  (multiple-value-setq (compare-line compare-number)
	    (http-get-last-line file)))
	; If-Modified-Since: 更新されていれば取得
	(unless lines
	  (push (cons "If-Modified-Since" (format-header-date wtime)) other))
	))
    (unless (string-match "\\?" url)
      (setq url (concat url "?")))
    (unless (string-match "raw=" url)
      (setq url (format nil "~A&raw=~D.~D" url (or compare-number 0) (or size 0))))
    (unless (string-match "sid=" url)
      (setq url (format nil "~A&sid=~A" url (url-encode (dolib-current-session-id)))))
    (push (cons "Accept" "*/*") other)
    (push (cons "Accept-Language" "ja,en") other)
    (when *http-accept-encoding*
      (push (cons "Accept-Encoding" *http-accept-encoding*) other))
    (when *debug*
      (message-box (format nil "~S" other))
      (message-box (format nil "URL : ~S~%File: ~S" url file)))
    ; HTTP GET
    (handler-case
	(multiple-value-setq (sock status header request)
	  (www::www-http-get-url url
				 :referer referer
				 :other other))
      (socket-error (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Socket error: ~A" (si:*condition-string c)))
      (quit (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Interrupted: ~A" (si:*condition-string c)))
    )
    (unless (stringp status)
      (error (http-error-string status header)))
    (when *debug*
      (message-box (http-error-string status header request)))
    ; 更新されていない
    (when (string-match "^304" status)
      (message "~A" status)
      (return-from http-get-thread-offlaw))
    ; エラーステータス
    (unless (and (string-match "^2[0-9][0-9]" status)
		 header)
      (error (http-error-string status header)))
    (let (length len last stime content-range total-length content-encoding gzip-p)
      ; 更新日時の取得
      (when (setq last (www::www-get-header-value "last-modified" header))
	(setq stime (parse-header-date last)))
      ; 受信バイト数の取得
      (setq len (www::www-get-header-value "content-length" header))
      ; Content-Encoding
      (when *http-accept-encoding*
	(setq content-encoding (www::www-get-header-value "content-encoding" header))
	(setq gzip-p (and (stringp content-encoding)
			  (string-match "gzip" content-encoding))))
      (when (and (setq content-range (www::www-get-header-value "content-range" header))
		 (string-matchp "bytes +[0-9]+-[0-9]+/\\([0-9]+\\)" content-range))
	(setq total-length
	      (parse-integer
	       (substring content-range (match-beginning 1) (match-end 1)))))
      (when (and len
		 (string-match "^[0-9]+$" len))
	(setq length (parse-integer len)))
      (when *debug*
	(message-box (format nil "Local : ~S~%Content-Length: ~S~%Content-Range: ~S"
			     size length total-length)))
      (when gzip-p
	(setq sock (http-gzip-to-stream sock)))
      ; 差分更新のチェック
      (let ((line (read-line sock nil)))
	(unless line
	  (error "Socket error"))
	(when *debug*
	  (msgbox "~S~%~%~A" line (http-error-string status header request)))
	(cond ((string-match *read-cgi-ok* line)
	       (setq read-cgi-ok-p t)
	       (message line))
	      ((string-match *read-cgi-incr* line)
	       (message "read.cgi detect aborn")
	       (setq append nil)
	       (when *debug*
		 (msgbox "~S" line)))
	      ((string-match *read-cgi-err* line)
	       (close sock)
	       (when (string-match "指定時間が過ぎました。" line)
		 (dolib-expire-session)
		 (return-from http-get-thread-offlaw
		   (http-get-thread-offlaw url-orig file force :append append :compare compare :lines lines :referer referer)))
	       (error "Error: ~S" line))
	      (t
	       (close sock)
	       (error "Error: ~S" line))))
      (long-operation
	(if lines
	    (http-lines-to-file sock
				file
				lines
				:append (and append
					     read-cgi-ok-p))
	  (http-data-to-file sock
			     file
			     length
			     :append (and append
					  read-cgi-ok-p))))
      (when stime
	(set-file-write-time file stime))
      (message "2ch: saved ~A" file)
      nil)
    t))

(defun http-get-thread (url file &optional force &key append compare lines referer)
  (interactive)
  (let (sock
	status
	header
	request
	(size 0)
	wtime
	other
	range
	compare-line
	(compare-number 0)
	gzip-p
	read-cgi-ok-p
	result
	www::*www-user-agent*)
    (declare (special www::*www-user-agent*))
    (2ch-dolib-init)
    (setq www::*www-user-agent* *2ch-user-agent*)
    (when *debug*
      (msgbox "URL:~S~%FILE:~S~%FORCE:~S~%APPEND:~S~%COMPARE:~S~%LINES:~S~%REFERER:~S"
	      url file force append compare lines referer))
    ; ローカルディレクトリがなければ作成
    (http-create-file-directory file)
    ; force not append
    (when force
      (setq append nil))
    ; 既にファイルがある場合
    (when (file-exist-p file)
      (unless force
	(setq size (file-length file))
	(setq wtime (file-write-time file))
	; Range: 追加差分取得
	(when append
	  ; チェック文字列を取得
	  (multiple-value-setq (compare-line compare-number)
	    (http-get-last-line file)))
	; If-Modified-Since: 更新されていれば取得
	(unless lines
	  (push (cons "If-Modified-Since" (format-header-date wtime)) other))
	))
    (unless (string-match "\\?" url)
      (setq url (concat url "?")))
    (unless (string-match "raw=" url)
      (setq url (format nil "~A&raw=~D.~D" url (or compare-number 0) (or size 0))))
    (push (cons "Accept" "*/*") other)
    (push (cons "Accept-Language" "ja,en") other)
    (when *http-accept-encoding*
      (push (cons "Accept-Encoding" *http-accept-encoding*) other))
    (when *debug*
      (message-box (format nil "~S" other))
      (message-box (format nil "URL : ~S~%File: ~S" url file)))
    ; HTTP GET
    (handler-case
	(multiple-value-setq (sock status header request)
	  (www::www-http-get-url url
				 :referer referer
				 :other other))
      (socket-error (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Socket error: ~A" (si:*condition-string c)))
      (quit (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Interrupted: ~A" (si:*condition-string c)))
    )
    (unless (stringp status)
      (error (http-error-string status header)))
    (when *debug*
      (message-box (http-error-string status header request)))
    ; 更新されていない
    (when (string-match "^304" status)
      (message "~A" status)
      (return-from http-get-thread))
    ; エラーステータス
    (unless (and (string-match "^2[0-9][0-9]" status)
		 header)
      (error (http-error-string status header)))
    (let (length len last stime content-range total-length content-encoding gzip-p)
      ; 更新日時の取得
      (when (setq last (www::www-get-header-value "last-modified" header))
	(setq stime (parse-header-date last)))
      ; 受信バイト数の取得
      (setq len (www::www-get-header-value "content-length" header))
      ; Content-Encoding
      (when *http-accept-encoding*
	(setq content-encoding (www::www-get-header-value "content-encoding" header))
	(setq gzip-p (and (stringp content-encoding)
			  (string-match "gzip" content-encoding))))
      (when (and (setq content-range (www::www-get-header-value "content-range" header))
		 (string-matchp "bytes +[0-9]+-[0-9]+/\\([0-9]+\\)" content-range))
	(setq total-length
	      (parse-integer
	       (substring content-range (match-beginning 1) (match-end 1)))))
      (when (and len
		 (string-match "^[0-9]+$" len))
	(setq length (parse-integer len)))
      (when *debug*
	(message-box (format nil "Local : ~S~%Content-Length: ~S~%Content-Range: ~S"
			     size length total-length)))
      (when gzip-p
	(setq sock (http-gzip-to-stream sock)))
      ; 差分更新のチェック
      (let ((line (read-line sock nil)))
	(unless line
	  (error "Socket error"))
	(when *debug*
	  (msgbox "~S~%~%~A" line (http-error-string status header request)))
	(cond ((string-match *read-cgi-ok* line)
	       (setq read-cgi-ok-p t)
	       (message line))
	      ((string-match *read-cgi-incr* line)
	       (message "read.cgi detect aborn")
	       (setq append nil)
	       (when *debug*
		 (msgbox "~S" line)))
	      ((string-match *read-cgi-err* line)
	       (close sock)
	       (error "Error: ~S" line))
	      (t
	       (close sock)
	       (error "Error: ~S" line))))
      (long-operation
	(if lines
	    (http-lines-to-file sock
				file
				lines
				:append (and append
					     read-cgi-ok-p))
	  (http-data-to-file sock
			     file
			     length
			     :append (and append
					  read-cgi-ok-p))))
      (when stime
	(set-file-write-time file stime))
      (message "2ch: saved ~A" file)
      nil)
    t))

(defun http-get (url file &optional force &key append compare lines)
  (interactive)
  (let (sock
	status
	header
	dir
	size
	wtime
	other
	range
	compare-line
	gzip-p
	result
	www::*www-user-agent*)
    (declare (special www::*www-user-agent*))
    (2ch-dolib-init)
    (setq www::*www-user-agent* *2ch-user-agent*)
    (when *debug*
      (msgbox "URL:~S~%FILE:~S~%FORCE:~S~%APPEND:~S~%COMPARE:~S~%LINES:~S"
	      url file force append compare lines))
    ; ローカルディレクトリがなければ作成
    (setq dir (directory-namestring file))
    (unless (file-exist-p dir)
      (create-directory dir))
    ; 既にファイルがある場合
    (when (file-exist-p file)
      (setq size (file-length file))
      (setq wtime (file-write-time file))
      (unless force
	; Range: 追加差分取得
	(when append
	  (if compare
	      (let (comp-size)
		; チェック文字列を取得
		(when (setq compare-line (http-get-last-line file))
		  (setq comp-size (http-strlen compare-line)))
		(if (and comp-size
			 (< comp-size size))
		    (setq range (- size comp-size))
		  (setq append nil)))
	    (setq range size)))
	(when range
	  ;(push (cons "If-Range" (format-header-date wtime)) other)
	  (push (cons "Range" (format nil "bytes=~D-" range)) other))
	; If-Modified-Since: 更新されていれば取得
	(unless lines
	  (push (cons "If-Modified-Since" (format-header-date wtime)) other))
      ))
    (push (cons "Accept" "*/*") other)
    (push (cons "Accept-Language" "ja,en") other)
    (when (and *http-accept-encoding*
	       (not range))
      (push (cons "Accept-Encoding" *http-accept-encoding*) other))
    (when *debug*
      (message-box (format nil "~S" other))
      (message-box (format nil "URL : ~S~%File: ~S" url file)))
    ; HTTP GET
    (handler-case
	(multiple-value-setq (sock status header)
	  (www::www-http-get-url url :other other))
      (socket-error (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Socket error: ~A" (si:*condition-string c)))
      (quit (c)
	(when (socket-stream-p sock)
	  (close sock))
	(error "Interrupted: ~A" (si:*condition-string c)))
    )
    (unless (stringp status)
      (error (http-error-string status header)))
    (when *debug*
      (message-box (http-error-string status header)))
    ; 更新されていない
    (when (string-match "^304" status)
      (message "~A" status)
      (return-from http-get))
    ; [2003.02.09]
    ; Apache2 で416が返る場合はとりあえず更新されていないことにしとく
    (when (string-match "^416" status)
      (message "~A" status)
      (return-from http-get (http-get url file t)))
    ; エラーステータス
    (unless (and (string-match "^2[0-9][0-9]" status)
		 header)
      (error (http-error-string status header)))
    ; 差分更新のチェック
    (setq result
	  (catch 'aborn-detected
	    (when (and (string-match "^206" status)
		       ;(not gzip-p)
		       range
		       append
		       compare-line)
	      (let ((line (read-line sock nil)))
		(unless line
		  (error "Socket error"))
		(setq line (format nil "~A~%" line))
		; 一致しない場合全読み直し
		(unless (equal compare-line line)
		  (close sock)
		  (throw 'aborn-detected (list line compare-line)))))
	    (let (length len last stime content-range total-length content-encoding gzip-p)
	      ; 更新日時の取得
	      (when (setq last (www::www-get-header-value "last-modified" header))
		(setq stime (parse-header-date last)))
	      ; 受信バイト数の取得
	      (setq len (www::www-get-header-value "content-length" header))
	      ; Content-Encoding
	      (when *http-accept-encoding*
		(setq content-encoding (www::www-get-header-value "content-encoding" header))
		(setq gzip-p (and (stringp content-encoding)
				  (string-match "gzip" content-encoding))))
	      (when (and (setq content-range (www::www-get-header-value "content-range" header))
			 (string-matchp "bytes +[0-9]+-[0-9]+/\\([0-9]+\\)" content-range))
		(setq total-length
		      (parse-integer
		       (substring content-range (match-beginning 1) (match-end 1)))))
	      (when (and len
			 (string-match "^[0-9]+$" len))
		(setq length (parse-integer len)))
	      (when *debug*
		(message-box (format nil "Local : ~S~%Content-Length: ~S~%Content-Range: ~S"
					   size length total-length)))
	      ; バイト数での比較
	      (when (and *http-compare-size*
			 (not gzip-p))
		(when (and (not force)
			   size
			   (or total-length length)
			   (= size
			      (or total-length length)))
		  (message "File not updated: ~A (~D = ~D)" url size (or total-length length))
		  (close sock)
		  (return-from http-get)))
	      (long-operation
		(if gzip-p
		    (http-gzip-to-file sock
				       file
				       length
				       :append (and append
						    (string-match "^206" status)
						    compare-line))
		  (if lines
		      (http-lines-to-file sock
					  file
					  lines
					  :append (and append
						       (string-match "^206" status)))
		    (http-data-to-file sock
				       file
				       length
				       :append (and append
						    (string-match "^206" status))))))
	      (when stime
		(set-file-write-time file stime)
		;(message-box (format nil "Write-Time: ~A:~D:~A" file stime last))
		)
	      (message "2ch: saved ~A" file)
	      nil)))
    (when result
      (when *debug*
	(msgbox"あぼーん検出！~%~%~S" result))
      (message "あぼーん検出！全部読み直し。”")
      (return-from http-get (http-get url file t)))
    t))

(defun http-data-to-file (is file &optional size &key append)
  (with-open-file (os file
		      :direction :output
		      :if-exists (if append
				     :append
				   :supersede)
		      :if-does-not-exist :create)
    (www::www-get-data-to-stream is os size))
  (close is))

(defun http-lines-to-file (is file lines &key append)
  (let ((i 0)
	line)
    (with-open-file (os file
			:direction :output
			:if-exists (if append
				       :append
				     :supersede)
			:if-does-not-exist :create
			:encoding :binary)
      (www::www-interval-message (300)
	(while (setq line (read-line is nil))
	  (format os "~A\n" line) ; LF
	  (incf i)
	  (and (= i lines)
	       (close is)
	       (return))
	  (message "2ch: ~4D/~D" i lines))))
    (close is)
    ))

(defun http-create-temp-buffer ()
  (set-buffer (get-buffer-create *http-gzip-buffer-name*))
  (erase-buffer (selected-buffer))
  (setq need-not-save t))

;; 2001.09.15
;;   xyzzy-0.2.2.210 で亀井さんがgzip解凍関数を作って下さいました。(__)
;;   mod_gzipでは差分は取れなさそうなのでappendは無視して上書きします。
(defun http-gzip-to-file (is file &optional size &key append)
  (set-stream-encoding is :binary)
  (unwind-protect
      (with-open-file (os file
			  :direction :output
			  :if-exists (if append
					 :append
				       :supersede)
			  :if-does-not-exist :create
			  :encoding :binary)
	(si:inflate-stream is os))
    (close is)))

(defun http-gzip-to-stream (is)
  (set-stream-encoding is :binary)
  (save-excursion
    (http-create-temp-buffer)
    (with-output-to-selected-buffer
      (si:inflate-stream is *standard-output*))
    (close is))
  (make-buffer-stream *http-gzip-buffer-name*))

#|
(defun http-gzip-to-stream (is)
  (let (bs)
    (save-excursion
      (http-create-temp-buffer)
      (with-output-to-selected-buffer
	(format t "~A" (si:inflate-stream is)))
      (close is))
    (make-buffer-stream *http-gzip-buffer-name*)))

(defvar *http-gzip-file-name* "~/.2ch-gzip")

(defun http-gzip-to-stream (is)
  (http-gzip-to-file is *http-gzip-file-name*)
  (open *http-gzip-file-name*
	:direction :input))

(defun http-gzip-to-file (is file &optional size &key append)
  (let (temp)
    (unwind-protect
	(setq temp (make-temp-file-name nil "gz"))
      (let (line)
	(unwind-protect
	    (with-open-file (os temp
				:direction :output
				:if-exists :supersede
				:if-does-not-exist :create)
	      (www::www-get-data-to-stream is os size))
	  (close is))
	(http-extract-and-read-gzip temp)
	(unless (find-buffer *http-gzip-buffer-name*)
	  (error "Buffer not exist: ~S" *http-gzip-buffer-name*))
	(save-excursion
	  (set-buffer *http-gzip-buffer-name*)
	  (goto-char (point-min))
	  (when append
	    (setq line (buffer-substring (point)
					 (progn
					   (forward-line 1)
					   (point))))
	    (unless (equal append line)
	      (throw 'aborn-detected (list line append))))
	  (write-region (point) (point-max) file append)))
      (delete-file temp :if-does-not-exist :skip :if-access-denied :force))
    ))

(defun http-extract-and-read-gzip (gzip-file)
  (let (file filename dir path)
    (unless (string-match "\.gz$" gzip-file)
      (error "Not gzip suffix: ~S" gzip-file))
    (setq filename (file-namestring gzip-file))
    (setq file (substring filename 0 (- (length filename) 3)))
    (unwind-protect
	(progn
	  (setq dir (make-temp-file-name nil nil nil t))
	  (setq path (merge-pathnames file dir))
	  (extract-archive gzip-file dir file)
	  (unless (file-exist-p path)
	    (error "Could not extract: ~S in ~S" file gzip-file))
	  (save-excursion
	    (set-buffer (get-buffer-create *http-gzip-buffer-name*))
	    (erase-buffer (selected-buffer))
	    (setq need-not-save t)
	    (insert-file-contents path)))
      (when dir
	(directory dir
		   :absolute t :recursive t
		   :callback #'(lambda (f)
				 (if (file-directory-p f)
				     (delete-directory f :if-access-denied :force)
				   (delete-file f :if-access-denied :force))))
	(delete-directory dir :if-does-not-exist :skip :if-access-denied :force)))))
|#

(defun http-strlen (str)
  (1- (si:chunk-size (si:make-string-chunk str))))

(defvar *http-post-loop-max* 3)

(defvar *http-server-cookie* nil)
(defvar *http-server-cookie-lifetime* (* 60 60 3))

(defmacro http-server-cookie (server)
  `(assoc server *http-server-cookie* :test #'equal))
(defmacro http-server-cookie-server (sc)
  `(car ,sc))
(defmacro http-server-cookie-cookie (sc)
  `(cadr ,sc))
(defmacro http-server-cookie-time (sc)
  `(caddr ,sc))

(defun http-server-cookie-get (server)
  (let ((sc (http-server-cookie server)))
    (when (and sc
	       (http-server-cookie-cookie sc)
	       (> (http-server-cookie-time sc) (- (get-universal-time) *http-server-cookie-lifetime*)))
      (http-server-cookie-cookie sc))))

(defun http-server-cookie-set (server cookie)
  (if (http-server-cookie-get server)
      (if (http-server-cookie server)
	  (progn
	    (setf (http-server-cookie-cookie (http-server-cookie server)) cookie)
	    (setf (http-server-cookie-time (http-server-cookie server)) (get-universal-time)))
	(push (list server cookie (get-universal-time)) *http-server-cookie*))))

(defun http-post (url &key post referer cookie (loop 0))
  (let ((buf (buffer-name (selected-buffer)))
	sock
	status
	header
	other
	www::*www-user-agent*)
    (declare (special www::*www-user-agent*))
    (2ch-dolib-init)
    (setq www::*www-user-agent* *2ch-user-agent*)
    (when (= loop 0)
      (let ((pon (http-server-cookie-get url)))
	(when pon
	  (setq cookie (concat cookie ";" pon)))))
    (when cookie
      (push (cons "Cookie" cookie) other))
    (when *2ch-use-dolib*
      (unless (string-match "sid=" post)
	(setq post (format nil "~A&sid=~A" post (url-encode (dolib-current-session-id))))))
    (handler-case
	(multiple-value-setq (sock status header)
	  (www::www-http-get-url url
				 :post post
				 :referer referer
				 :other other))
      (socket-error (c)
	(close sock)
	(error "Socket error."))
      (quit (c)
	(close sock)
	(error "Interrupted.")))
    (unless (stringp status)
      (error (http-error-string status header)))
    (set-buffer-http)
    (erase-buffer (selected-buffer))
    (setq http-status status)
    (setq http-header header)
    (setq http-buffer-parent buf)
    (cond ((string-match "^2" status)
	   (setq *latest-post-time* (www::www-get-header-value "date" header)) 
	   (when (string-match "&time=\\([^&]*\\)&bbs=" post) 
	     (let (end-of-first-string 
		   beginning-of-second-string) 
	       (setq end-of-first-string (match-beginning 1)) 
	       (setq beginning-of-second-string (match-end 1)) 
	       (setq post (format nil "~A~A~A" 
				  (substring post 0 end-of-first-string) 
				  (form-time) 
				  (substring post beginning-of-second-string))))) 
	   (www::www-get-data sock)
	   (goto-char (point-min))
	   (save-excursion
	     (let ((body (buffer-substring (point-min) (point-max))))
	       (cond ((string-match *post-result-cookie* body) 
		      (unless (> loop *http-post-loop-max*) 
			(incf loop) 
			(let ((cookies (mapcar #'(lambda (x) 
						   (if (string-match "\\([^=]+\\)=?$" x) 
						       (list (match-string 1) "") 
						     (split-string x #\= nil " "))) 
					       (split-string cookie #\; nil " "))) 
			      (set-cookies (let (cookies) 
					     (dolist (x header) 
					       (when (and (equal (car x) "set-cookie") (cadr x) 
							  (string-match " *\\([^=]+\\)=\\([^;]+\\)" (cadr x))) 
						 (push (list (match-string 1) (match-string 2)) cookies))) 
					     cookies))) 
			  (when (set-difference set-cookies cookies :test #'equal :key #'car) 
			    (http-server-cookie-set url (format nil "~:{~A=~A;~}" set-cookies)) 
			    (mapc #'(lambda (x) 
				      (setq set-cookies (adjoin x set-cookies :test #'equal :key #'car))) 
				  cookies) 
			    (setq cookie (format nil "~:{~A=~A;~}" set-cookies)) 
			    (set-buffer buf) 
			    (return-from http-post 
			      (http-post url 
					 :post post 
					 :referer referer 
					 :cookie cookie 
					 :loop loop))))) 
		      nil)
		     ((string-match *post-result-check* body)
		      (http-html-format)
		      (goto-char (point-min))
		      nil)
		     ((string-match *post-result-error* body)
		      (http-html-format)
		      (goto-char (point-min))
		      nil)
		     ((string-match *post-result-false* body)
		      (http-html-format)
		      (goto-char (point-min))
		      nil)
		     ((string-match *post-result-ok* body)
		      (http-html-format)
		      (goto-char (point-min))
		      t)
		     (t
		      (http-html-format)
		      (goto-char (point-min))
		      (scan-buffer "書きこみました。")
		      )))))
	  ((string-match "^3" status)
	   (insert "\n 書き込み完了（たぶん）")
	   (goto-char (point-min))
	   t)
	  (t
	   (error (http-error-string status header))))
    ))

(defun http-show-status ()
  (interactive)
  (message-box (http-error-string http-status http-header)))

(defun http-quit ()
  (interactive)
  (let ((buf http-buffer-parent))
    (delete-buffer (selected-buffer))
    (when (and buf
	       (find-buffer buf))
      (set-buffer buf)
      (form-back-parent))))

(defun http-mode ()
  (kill-all-local-variables)
  (setq buffer-mode '2ch-http)
  (setq mode-name *mode-name*)
  (make-local-variable 'http-buffer-parent)
  (setq http-buffer-parent nil)
  (make-local-variable 'http-status)
  (setq http-status nil)
  (make-local-variable 'http-header)
  (setq http-header nil)
  (make-local-variable 'title-bar-format)
  (setq title-bar-format (format nil "~A - %b" *version-name*))
  (set-local-window-flags (selected-buffer)
			  *window-flag-line-number* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-newline* nil)
  (set-local-window-flags (selected-buffer)
			  *window-flag-eof* nil)
  (set-buffer-fold-width nil)
  (toggle-ime nil)
  (use-keymap *http-map*)
  (run-hooks '*form-mode-hook*))

(defun http-html-format ()
  (map-char-encoding-region (point-min) (point-max))
  (save-excursion
    (goto-char (point-min))
    (while (scan-buffer "<[^>]+>" :regexp t)
      (delete-region (match-beginning 0) (match-end 0)))
    (goto-char (point-min))
    (while (scan-buffer "\n+" :regexp t)
      (delete-region (match-beginning 0) (match-end 0))
      (insert "\n"))))

(defvar *rfc822-date-time-regexp*
  (compile-regexp
   "^[ \t]*\\([A-Za-z]+[ \t]*,[ \t]*\\)?\\([0-9]+\\)[ \t]+\\([A-Za-z]+\\)[ \t]+\\([0-9]+\\)[ \t]+\\\([0-9]+\\):\\([0-9]+\\)\\(:\\([0-9]+\\)\\)?\\([ \t]+\\([-+][0-9]+\\|[A-Za-z]+\\)\\)?"))

(defvar *month-name-hash*
  (let ((hash (make-hash-table :test #'equalp)))
    (dotimes (i 12)
      (setf (gethash (svref #("Jan" "Feb" "Mar" "Apr" "May" "Jun"
			      "Jul" "Aug" "Sep" "Oct" "Nov" "Dec")
			    i)
		     hash)
	    (+ i 1)))
    hash))
 
(defvar *timezone-hash-table*
  (let ((hash (make-hash-table :test #'equal)))
    (mapc #'(lambda (x)
	      (setf (gethash (car x) hash) (cdr x)))
	  '(("A" . "-0100") ("B" . "-0200") ("C" . "-0300") ("D" . "-0400")
	    ("E" . "-0500") ("F" . "-0600") ("G" . "-0700") ("H" . "-0800")
	    ("I" . "-0900") ("K" . "-1000") ("L" . "-1100") ("M" . "-1200")
	    ("N" . "+0100") ("O" . "+0200") ("P" . "+0300") ("Q" . "+0400")
	    ("R" . "+0500") ("S" . "+0600") ("T" . "+0700") ("U" . "+0800")
	    ("V" . "+0900") ("W" . "+1000") ("X" . "+1100") ("Y" . "+1200")
	    ("Z" . "+0000")
	    ("IDLW" . "-1200") ("NT" . "-1100") ("AHST" . "-1000") ("CAT" . "-1000")
	    ("HST" . "-1000") ("YST" . "-0900") ("PST" . "-0800") ("MST" . "-0700")
	    ("CST" . "-0600") ("EST" . "-0500") ("AST" . "-0400") ("AT" . "-0200")
	    ("WAT" . "-0100") ("GMT" . "+0000") ("UT" . "+0000") ("UTC" . "+0000")
	    ("WET" . "+0000") ("CET" . "+0100") ("FWT" . "+0100") ("MET" . "+0100")
	    ("MEWT" . "+0100") ("SWT" . "+0100") ("EET" . "+0200") ("BT" . "+0300")
	    ("ZP4" . "+0400") ("ZP5" . "+0500") ("ZP6" . "+0600") ("WAST" . "+0700")
	    ("CCT" . "+0800") ("HKT" . "+0800") ("JST" . "+0900") ("EAST" . "+1000")
	    ("GST" . "+1000") ("IDLE" . "+1200") ("NZST" . "+1200") ("NZT" . "+1200")
	    ("HDT" . "-0900") ("YDT" . "-0800") ("PDT" . "-0700") ("MDT" . "-0600")
	    ("CDT" . "-0500") ("EDT" . "-0400") ("ADT" . "-0400") ("BST" . "+0100")
	    ("MEST" . "+0200") ("MESZ" . "+0200") ("SST" . "+0200") ("FST" . "+0200")
	    ("WADT" . "+0800") ("EADT" . "+1100") ("NZDT" . "+1300")))
    hash))
   
(defun parse-header-date (date)
  (when date
    (while (let (f)
	     (multiple-value-setq (date f)
	       (substitute-string date "([^()]*)" " "))
	     (and f (plusp f))))
    (when (string-match *rfc822-date-time-regexp* date)
      (encode-universal-time (if (match-beginning 8)
				 (parse-integer (subseq date (match-beginning 8) (match-end 8)))
			       0)
			     (parse-integer (subseq date (match-beginning 6) (match-end 6)))
			     (parse-integer (subseq date (match-beginning 5) (match-end 5)))
			     (parse-integer (subseq date (match-beginning 2) (match-end 2)))
			     (gethash (subseq date (match-beginning 3) (match-end 3))
				      *month-name-hash* 1)
			     (parse-integer (subseq date (match-beginning 4) (match-end 4)))
			     (if (match-beginning 9)
				 (let ((zone (subseq date (match-beginning 9) (match-end 9))))
				   (setq zone (string-left-trim " \t" zone))
				   (when (string-match "^[a-zA-Z]+$" zone)
				     (setq zone (gethash zone *timezone-hash-table* zone)))
				   (if (string-match "^[-+][0-9][0-9][0-9][0-9]$" zone)
				       (- (truncate (parse-integer zone) 100))
				     0))
			       0)))))

#|
(defun format-header-date (&optional time)
  "Dateヘッダー書式化して返す。(ex.Date: Sun, 12 Sep 1999 13:18:13 +0900"
  (format-date-string "%a, %d %b %Y %H:%M:%S %Z" time))
|#

(defun format-header-date (&optional time)
  "Dateヘッダー書式化して返す。(ex.Date: Sun, 12 Sep 1999 13:18:13 GMT"
  (setq time (- (or time (get-universal-time)) (* 9 60 60)))
  (format-date-string "%a, %d %b %Y %H:%M:%S GMT" time))

(defun url-encode (str)
  (si::www-url-encode str nil "-A-Za-z0-9$_.!*'(|),"))
