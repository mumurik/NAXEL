#|text
■機能
セッションに含める情報を拡張するために、フックを追加しました。
このファイルをロードしただけでは、オリジナルの動作とほとんど違いありま
せん。基本的にフックを追加する事で、処理を追加できるようにします。

多くの拡張lispでこれらの関数を再定義していて、競合する原因となっていま
す。それを解消するためにいくつかのフックを追加し、拡張lispが再定義する
ことなくフックを追加する事で機能を追加できるようにします。


save-session-info, restore-session-info, load-session,
list-buffer-info の定義を上書きしています。

  *save-session-hook* :
    セッションファイルへの出力ストリームを引数とした関数を実行します。
    セッション情報を拡張するときは、通常このフックに関数を追加する事で
    行います。

  *pre-restore-buffer-info-hook* :
    セッションのロードで、バッファに情報を設定しなおす前に全体1度だけ
    呼び出されます。

  *restore-session-hook* :
    セッションのロードで、バッファに情報を設定しなおす前に、バッファご
    とに一度ずつ呼び出されます。
    run-hook-with-args でファイルのパスを引数にして呼び出されます。 

  *post-restore-buffer-info-hook* :
    セッションのロードで、バッファに情報を設定しなおした後に全体1度だ
    け呼び出されます。

  *after-session-load-hook*
    セッションファイルロード後に実行されるフックです。

  *before-save-session* :
    セッションの保存でバッファ情報を保存するかの判定に利用されます。
    run-hook-with-args-until-success でバッファを引数にして呼び出されます。

  *before-restore-session* :
    セッションのロードでバッファ情報をロードするかの判定に利用されます。
    run-hook-with-args-until-success でバッファを引数にして呼び出されます。

■インストール
  .xyzzy か siteini.l に下のを書いてください．
   ni-autoload を使用している人は必要ありません。
  (require "session-ext")

■注意事項
  以下の定義を上書きしています。
    save-session-info, 
    restore-session-info,
    load-session 

■License
Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the 
"Software"), to deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, merge, publish, 
distribute, sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, subject to 
the following conditions: 

The above copyright notice and this permission notice shall be 
included in all copies or substantial portions of the Software. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 

copyright 2006   Masahiro Nakano
modified by mumurik765 2012/05/16

・Author 
    Masahiro Nakano <m-nakano@jaist.ac.jp>


■更新履歴
  on 12/11/2006
   ・restore-session-info, list-buffer-info に対してもフックを追加。
   ・誤ってdebug用のコードが入っていたのを修正 + 1

  on 06/30/2007
   ・バッファ名を保存するオプション *session-keeps-buffer-name* を追加

  on 09/08/2006
   ・公開
|#


(provide "session-ext")


(in-package "editor")

(export '(*save-session-hook*
	  *pre-restore-buffer-info-hook*
	  *restore-buffer-info-hook*
	  *post-restore-buffer-info-hook*
	  *after-session-load-hook*
	  *before-save-session*
	  *before-restore-session*
	  *session-keeps-buffer-name*
	  ))

(defvar *save-session-hook* nil
  "セッションを保存時に呼び出されます。")
(defvar *pre-restore-buffer-info-hook* nil
  "セッションのロードでバッファ情報を設定する前に呼び出されます。")
(defvar *restore-buffer-info-hook* nil
  "セッションのロードでバッファ情報を設定する時に呼び出されます。
run-hook-with-args でファイルのパスを引数にして呼び出されます。 ")

(defvar *post-restore-buffer-info-hook* nil
  "セッションのロードで全バッファ情報を設定した後に呼び出されます。")
(defvar *after-session-load-hook* nil
  "セッションをロード後に呼び出されます。")

(defvar *before-save-session* nil
  "セッションの保存でバッファ情報を保存するかの判定に利用されます。
run-hook-with-args-until-success でバッファを引数にして呼び出されます。 ")

(defvar *before-restore-session* nil
  "セッションのロードでバッファ情報をロードするかの判定に利用されます。
run-hook-with-args-until-success でバッファを引数にして呼び出されます。")


(defvar *session-keeps-buffer-name* nil
  "バッファ名を保存する時 non-nil")

; デフォルトの関数を上書き
; from session.l
(defun list-buffer-info ()
  (save-excursion
    (let ((info nil))
      (mapc #'(lambda (buffer)
		(when (or (file-visited-p buffer)
			  (run-hook-with-args-until-success '*before-save-session* buffer))  ;;
		  (set-buffer buffer)
		  (push (list (or (get-buffer-file-name buffer)
				  (get-buffer-alternate-file-name buffer))  ;; フック追加以外の変更点
			      (point)
			      (cons buffer-mode ;; userパッケージ以外のシンボルで、
				                ;; かつexportされていないとロード時にエラー
				    (mapcan #'(lambda (mode)
						(let ((var (and (consp mode) (car mode))))
						  (and (symbolp var)
						       (boundp var)
						       (symbol-value var)
						       (list var))))
					    *minor-mode-alist*))
			      (mapcar #'(lambda (var)
					  (and (symbolp var)
					       (local-variable-p var)
					       (cons var (symbol-value var))))
				      *buffer-info-variable-list*)
			      (buffer-name buffer)
			      )
			info)))
	    (buffer-list :buffer-bar-order t))
      (nreverse info))))

; デフォルトの関数を上書き
; from session.l
(defun save-session-info (s)
  (save-current-pseudo-frame)
  (let ((finfo (mapcan #'(lambda (frame)
			   (when (pseudo-frame-save-p frame)
			     (list (list (pseudo-frame-name frame)
					 (winconf-to-readable-winconf
					  (pseudo-frame-winconf frame))
					 (eq frame (get-current-pseudo-frame (selected-frame)))))))
		       (get-pseudo-frame-list (selected-frame))))
	(binfo (list-buffer-info)))
    (princ ";;; xyzzy session file.\n;;; This file is generated automatically. do not edit.\n" s)
    (write `(in-package ,(package-name *package*)) :stream s :escape t)
    (terpri s)
    (write `(restore-session ',binfo ',finfo) :stream s :escape t)
    (terpri s))
  (run-hook-with-args '*save-session-hook* s))

;; デフォルトの関数を上書き
;; from session.l
(defun restore-buffer-info (info)
  (run-hooks '*pre-restore-buffer-info-hook*) ;;
  (unwind-protect                             ;;
      (let ((obuffer (selected-buffer)))
	(mapc #'(lambda (i)
		  (let ((file (pop i)))
		    (when (or (file-exist-p file)
			      (run-hook-with-args-until-success     ;;
				   '*before-restore-session* file)) ;;
		      (handler-case
			  (let ((point (pop i))
				(mode (pop i))
				(minor nil)
				(name nil))                         ;;
			    (if (listp mode)
				(setq minor (cdr mode)
				      mode (car mode)))
			    (let ((*find-file-auto-mode-function* mode))
			      (find-file file)
			      (run-hook-with-args '*restore-buffer-info-hook* file)  ;;
			      )
			    (goto-char point)
			    (mapc #'(lambda (f) (and (fboundp f) (funcall f))) minor)
			    (mapc #'(lambda (x)
				      (let ((carx (car x)))
					(when (and carx (symbolp carx))
					  (make-local-variable carx)
					  (set carx (cdr x)))))
				  (pop i))
			    (setq name (pop i))              ;;
			    (and *session-keeps-buffer-name* ;;
				 name                        ;;
				 (rename-buffer name))       ;;
			    )
			(file-error (c)
			  (si:*print-condition c))))))
	      info)
	(set-buffer obuffer))
    (run-hooks '*post-restore-buffer-info-hook*) ;;
    ))


;; デフォルトの関数を上書き
;; from session.l
(defun load-session (filename &optional not-close)
  (interactive "fLoad session: \np"
    :title0 "Load session" :history0 '*session-file-history*
    :default0 (session-directory))
  (long-operation
    (setq filename (namestring filename))
    (with-open-file (s filename
		       :direction :input
		       :if-does-not-exist :error)
      (unless (equal (read-line s nil) ";;; xyzzy session file.")
	(error "セッションファイルではありません")))
    (unwind-protect
	(progn
	  (or not-close
	      (close-session nil nil (if (interactive-p)
					 #'write-file #'save-buffer-dialog)))
	  (load filename :verbose nil :print nil)
	  (setq *current-session-file-name* filename)
	  (run-hooks '*after-session-load-hook*)
	  )
      (init-pseudo-frame))
    t))

