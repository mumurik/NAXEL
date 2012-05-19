;;; -*- Mode: Lisp; Package: editor -*-
;;;
;;; tdict.l --- 簡易辞書

;;; author
;;;	YAMAMOTO Taizo

;;; date
;;;	Last updated: "2003-05-03"

;;; description
;;;	項目名と項目説明をタブ文字で区切ったファイルを辞書として
;;;	簡単な辞書の機能を提供します。項目説明がポップアップ表示されます。

;;; install
;;;	1.解凍して出来たtdict.lを、$XYZZY/site-lisp/にコピーします。
;;;     2.~/.xyzzyもしくは$XYZZY/site-lisp/siteini.lに記述を追加します。
;;;
;;;		--------------------------------
;;;		(require "tdict")
;;;		--------------------------------
;;;
;;;     3.上記の設定を反映させるために、xyzzyを再起動します。
;;;	  ※siteinit.lに記述した場合には再ダンプもして下さい。

;;; uninstall
;;;	1.$XYZZY/site-lisp/tdict/を削除します。
;;;	2.~/.xyzzyもしくは$XYZZY/site-lisp/siteinit.lの関連する箇所を削除します。
;;;	  ※siteinit.lに記述していたならば再度ダンプし直します。

;;; usage
;;;	1.辞書にしたいファイルをTSV形式で$XYZZY/etc/に格納します。
;;;
;;;		--------------------------------
;;;		defun	関数
;;;		defvar	スペシャル変数
;;;		--------------------------------
;;;
;;;	2.必要に応じてtdict-modeを実行します。
;;;
;;;		--------------------------------
;;;		M-x tdict-mode[RET]
;;;		--------------------------------
;;;
;;;	3.キーワードファイルを変更したければtdict-reloadを実行します。
;;;
;;;		--------------------------------
;;;		M-x tdict-reload[RET]
;;;		tdict file: C:/applications/xyzzy/site-lisp/tdict/tdict[RET]
;;;		--------------------------------

;;; note
;;;	・仕事用に作ったので大した機能はありません。
;;;	※項目数が1000を越えそうな構造体を扱わなければならなく、
;;;	　項目を把握できなくなったので作りました。
;;;	・何も考えてないので英和辞典とかはつっこまないように。
;;;	・個人的な作業で検索したいような場合に使用ください。

;;; changes
;;;	Sat, 03 May 2003 00:07:55 +0900
;;;		・NetInstaller対応（書き忘れ）
;;;		・説明文の修正（書き忘れ）
;;;		・tdict-modeをdefvar-localに変更
;;;	Sat, 17 Aug 2002 07:15:49 +0900
;;		・goal-columnへの配慮（感謝、大久保さん）
;;; 	Tue, 13 Aug 2002 14:30:01 +0900
;;;		・サイトに載せるよう体裁を整えた
;;;	Thu, 20 Jun 2002 00:51:44 +0900
;;;		・初版

(provide "tdict/tdict")

(in-package "editor")

;;; variable
(export '(tdict-mode tdict-reload))

(defvar-local tdict-mode nil
	      "tdict-mode")
(defvar *tdict-file* (merge-pathnames "tdict" (etc-path))
  "簡易辞書ファイル格納ファイル名")
(defvar *tdict-attr* '(:underline t :bold t)
  "簡易辞書強調表示属性")

; 内部用
(defvar *tdict-list* nil
  "簡易辞書管理リスト")
(defvar *tdict-last-range-begin* nil
  "簡易辞書強調表示開始位置")
(defvar *tdict-last-range-end* nil
  "簡易辞書強調表示終了位置")
(defvar *tdict-last-buffer* nil
  "簡易辞書表示バッファ")

;;; function
(defun tdict-mode (&optional (arg nil sv))
  "簡易辞書モード"
  (interactive "p")
  (toggle-mode 'tdict-mode arg sv)
  (unless *tdict-list*
    (tdict-reload *tdict-file*)))

(defun tdict-reload (filename)
  "簡易辞書の再読み込み"
  (interactive "Ftdict file: " :default0 *tdict-file*)
  (unless (file-exist-p filename)
    (message "tdict: ~A not exits" filename)
    (return-from tdict-reload nil))
  (setq *tdict-file* filename)
  (setq *tdict-list*
	(mapcar #'(lambda (x) (split-string x "\t"))
		(make-list-from-keyword-table
		 (load-keyword-file *tdict-file*)))))

(defun tdict-popup ()
  "簡易辞書によるポップアップ表示"
  (when tdict-mode
    (and (eq *tdict-last-buffer* (selected-buffer))
	 *tdict-last-range-begin*
	 *tdict-last-range-end*
	 (<= *tdict-last-range-begin* (point))
	 (< (point) *tdict-last-range-end*)
	 (continue-popup)
	 (return-from tdict-popup nil))
    (let (beg end itm (goal (goal-column)))
      (when *tdict-last-buffer*
	(save-window-excursion
	  (when (minibuffer-window-p (selected-window))
	    (other-window))
	  (set-buffer *tdict-last-buffer*)
	  (delete-text-attributes 'tdict-attr)))
      (setq *tdict-last-buffer* nil
	    *tdict-last-range-begin* nil
	    *tdict-last-range-end* nil)
      (save-excursion
	(setq beg (progn (skip-syntax-spec-backward "jw_") (point))
	      end (progn (skip-syntax-spec-forward "jw_") (point))))
      (and (/= beg end)
	   (setq itm (assoc (buffer-substring beg end)
			    *tdict-list* :test 'string-equal))
	   (setq *tdict-last-buffer* (selected-buffer)
		 *tdict-last-range-begin* beg
		 *tdict-last-range-end* end)
	   (popup-string (cadr itm) end)
	   (apply 'set-text-attribute beg end 'tdict-attr *tdict-attr*))
      (set-goal-column goal))))

(pushnew '(tdict-mode . "Tdict") *minor-mode-alist* :key #'car)

;;; hook
(add-hook '*post-command-hook* 'tdict-popup)
