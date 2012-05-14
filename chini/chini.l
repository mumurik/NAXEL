;;; -*- Mode: Lisp; Package: EDITOR -*-
;;; chini.l --- xyzzy.ini の直接操作による設定変更

;; Copyright (C) 2001-2005 OHKUBO Hiroshi <ohkubo@s53.xrea.com>

;; Author: OHKUBO Hiroshi <ohkubo@s53.xrea.com>
;; Time-stamp: <2005/10/08 11:00:16 +0900>

;;; Commentary:

;; Description:
;;
;;  xyzzy.ini を直接操作し設定を変更します。
;;
;;    ・印刷設定の保存/読込(切替)
;;    ・ファイラ設定の保存/読込(切替)
;;    ・バッファセレクタ設定の保存/読込(切替)
;;    ・Misc設定の保存/読込(切替)
;;
;;    ・フォント設定の保存/読込(切替)
;;    ・色設定の保存/読込(切替)
;;

;; Installation:
;;
;;      1. アーカイブを展開して chini.l を $XYZZY/site-lisp に
;;         コピーします。
;;
;;      2. バイトコンパイルします。
;;
;;              M-x byte-compile-file
;;              Byte compile file: $XYZZY/site-lisp/chini.l
;;
;;      3. ~/.xyzzy または $XYZZY/site-lisp/siteinit.l に以下のコードを
;;         追加します。
;;
;;              (require "chini")
;;
;;      4. 必要に応じ、メニュー追加コードを追加します。
;;         :position の後の数、:head-sep 等については適宜変更してください。
;;
;;              ;; 印刷設定と *chini-popup-menu* を追加する例
;;              (add-hook '*init-app-menus-hook*
;;                        #'(lambda ()
;;                            ;; フォント
;;                            ;(chini-font-insert-menu-items :head-sep t)
;;                            ;; 色
;;                            ;(chini-color-insert-menu-items :head-sep t)
;;                            ;; 印刷
;;                            (chini-print-insert-menu-items :pre-tag 'ed::print-selected-buffer-dialog)
;;                            ;; ファイラ
;;                            ;(chini-filer-insert-menu-items :head-sep t)
;;                            ;; バッファセレクタ
;;                            ;(chini-bufselector-insert-menu-items :head-sep t)
;;                            ;; Misc
;;                            ;(chini-misc-insert-menu-items :head-sep t)
;;                            ;; *chini-popup-menu*
;;                            (chini-insert-menu-items :head-sep t :access-key #\0)) t)
;;
;;      5. 上記の設定を反映させるために、xyzzy を再起動します。
;;         siteinit.l に記述した場合は Ctrl キーと Shift キーを押しながら
;;         xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Uninstallation:
;;
;;      1. ESC ESC (ed::chini-uninstall) とタイプし、
;;         chini.l 関連の情報を xyzzy から削除します。
;;
;;      2. chini.l に関する記述を削除します。
;;
;;      3. siteinit.l に記述していた場合は Ctrl キーと Shift キーを押し
;;         ながら xyzzy を再起動し、ダンプファイルを再構築します。
;;

;; Usage:
;;
;;      以下「印刷」の設定変更方法。他も同様。
;;
;;      [ミニバッファ]
;;      1. M-x chini-save-print-setting で印刷設定を保存する。
;;      2. M-x chini-load-print-setting で印刷設定を読み込む。
;;
;;      [ダイアログ]
;;      1. メニューの [ファイル]-[印刷設定の保存] で印刷設定を保存する。
;;      2. メニューの [ファイル]-[印刷設定の読み込み] もしくは、
;;         [ファイル]-[最近使った印刷設定] で印刷設定を読み込む。
;;

;; Changes:
;;
;;      Sat, 08 Oct 2005 11:00:12 +0900
;;        ・メールアドレスを変更。
;;        ・ライセンス条項(修正BSDライセンス)を記載。
;;
;;      Wed, 13 Apr 2005 00:15:36 +0900
;;        ・xyzzy 0.2.2.234 対応
;;          - 半角カナを全角カナに変更。
;;          - chini-insert-menu-items 更新。
;;            「xyzzy.ini 設定変更」メニューを追加する位置のデフォルトを
;;            「(>_<)」の下に。
;;          - chini-*-insert-menu-items 更新。
;;            メニュー追加位置の指定を :pre-tag でも指定できるように。
;;
;;      Wed, 07 Jul 2004 23:46:25 +0900
;;        ・フォント/印刷/ファイラ/バッファセレクタ/Misc についての
;;          設定切り替えを追加。
;;        ・各関数を一括生成するように変更(ed::chini-generate-function)。
;;          関数生成時に compile するかは ed::*chini-compile-function-p*
;;          変数で制御する。
;;        ・*chini-directory* の初期値を (user-homedir-pathname) から
;;          (user-config-path) に変更。
;;        ・*chini-popup-menu* 追加。(chini-insert-menu-items) では
;;          デフォルトでは "ツール" メニューに追加する。
;;        ・chini-*-insert-menu-items で access-key を指定できるように。
;;
;;      Mon, 05 Jul 2004 12:37:28 +0900
;;        ・ダンプファイル内に chini.l の処理が含まれた場合に
;;          エラーが発生するのを修正。
;;          (create-popup-menu を行うタイミングの修正)
;;
;;      Mon, 28 Jun 2004 23:21:58 +0900
;;        ・初版作成。
;;

;; Licence:
;;
;;    chini は修正BSDライセンスに基づいて利用可能です。
;;    <http://www.opensource.org/licenses/bsd-license.php>
;;
;;
;;    Copyright (C) 2001-2005, OHKUBO Hiroshi.  All rights reserved.
;;
;;    Redistribution and use in source and binary forms, with or without
;;    modification, are permitted provided that the following conditions
;;    are met:
;;
;;    1. Redistributions of source code must retain the above copyright
;;       notice, this list of conditions and the following disclaimer.
;;
;;    2. Redistributions in binary form must reproduce the above copyright
;;       notice, this list of conditions and the following disclaimer in
;;       the documentation and/or other materials provided with the
;;       distribution.
;;
;;    3. Neither the name of the University nor the names of its
;;       contributors may be used to endorse or promote products derived
;;       from this software without specific prior written permission.
;;
;;    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;;    ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;;    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;;    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
;;    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;;    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;;    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
;;    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
;;    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
;;    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;;    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;;

;;; Code:

(provide "chini")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "foreign")
  (require "wip/winapi"))
(require "app-menu")

(in-package "winapi")

;; WINBASE.H
(*define-dll-entry DWORD GetPrivateProfileString
                   ;AppName KeyName Default ReturnedString Size  FileName
                   (LPCSTR  LPCSTR  LPCSTR  LPCSTR         DWORD LPCSTR)
                   "kernel32" "GetPrivateProfileStringA")
(*define-dll-entry BOOL WritePrivateProfileString
                   ;AppName KeyName String FileName
                   (LPCSTR  LPCSTR  LPCSTR LPCSTR)
                   "kernel32" "WritePrivateProfileStringA")

(in-package "editor")

(export '(*chini-directory*
          *chini-font-directory*
          *chini-color-directory*
          *chini-print-directory*
          *chini-filer-directory*
          *chini-bufselector-directory*
          *chini-misc-directory*
          *chini-setting-list*
          *chini-compile-function-p*
          *chini-backup-config-file-directory*
          *chini-uninstall-hook*
          *chini-popup-menu*
          chini-backup-config-file
          chini-restore-config-file
          chini-backup-config-file-dialog
          chini-restore-config-file-dialog
          chini-backup-config-file-insert-menu-items
          chini-insert-menu-items))

(defvar *chini-directory* (user-config-path))
(defvar *chini-buffer-name-tmp* " *chini: tmp*")
(defvar *chini-uninstall-hook* nil)
(defvar *chini-popup-menu* nil)

;; フォント設定
(defvar *chini-font-directory* *chini-directory*)
(define-history-variable *chini-font-setting-history* nil)
(defvar *chini-recent-font-setting-popup-menu* nil)
;; 色設定
(defvar *chini-color-directory* *chini-directory*)
(define-history-variable *chini-color-setting-history* nil)
(defvar *chini-recent-color-setting-popup-menu* nil)
;; 印刷設定
(defvar *chini-print-directory* *chini-directory*)
(define-history-variable *chini-print-setting-history* nil)
(defvar *chini-recent-print-setting-popup-menu* nil)
;; ファイラ設定
(defvar *chini-filer-directory* *chini-directory*)
(define-history-variable *chini-filer-setting-history* nil)
(defvar *chini-recent-filer-setting-popup-menu* nil)
;; バッファセレクタ設定
(defvar *chini-bufselector-directory* *chini-directory*)
(define-history-variable *chini-bufselector-setting-history* nil)
(defvar *chini-recent-bufselector-setting-popup-menu* nil)
;; Misc 設定
(defvar *chini-misc-directory* *chini-directory*)
(define-history-variable *chini-misc-setting-history* nil)
(defvar *chini-recent-misc-setting-popup-menu* nil)

;; バックアップ/リストア 用
(defvar *chini-backup-config-file-directory* *chini-directory*)
(define-history-variable *chini-backup-config-file-history* nil)
(defvar *chini-recent-backup-config-file-popup-menu* nil)

;; 一括ファンクション生成用
(defvar *chini-setting-list*
  '((font "フォント" ("Font")
          *chini-font-directory*
          *chini-font-setting-history*
          *chini-recent-font-setting-popup-menu*)
    (color "色" ("Colors")
           *chini-color-directory*
           *chini-color-setting-history*
           *chini-recent-color-setting-popup-menu*)
    (print "印刷" ("PrintPreview" "Print" "header" "footer")
           *chini-print-directory*
           *chini-print-setting-history*
           *chini-recent-print-setting-popup-menu*)
    (filer "ファイラ" ("Filer")
           *chini-filer-directory*
           *chini-filer-setting-history*
           *chini-recent-filer-setting-popup-menu*)
    (bufselector "バッファセレクタ" ("BufferSelector")
                 *chini-bufselector-directory*
                 *chini-bufselector-setting-history*
                 *chini-recent-bufselector-setting-popup-menu*)
    (misc "Misc" ("Misc")
          *chini-misc-directory*
          *chini-misc-setting-history*
          *chini-recent-misc-setting-popup-menu*))
  "chini: 一括ファンクション生成用設定")
(defvar *chini-compile-function-p* nil
  "chini: 一括ファンクション生成後 compile 実施")

;; base
(defun chini-get-private-profile-string (app key default size file)
  (let ((chunk (si:make-chunk nil size)))
    (winapi::GetPrivateProfileString (si:make-string-chunk app)
                                     (si:make-string-chunk key)
                                     (si:make-string-chunk default)
                                     chunk
                                     size
                                     (si:make-string-chunk file))
    (si:unpack-string chunk 0)))

(defun chini-write-private-profile-string (app key str file)
  (winapi::WritePrivateProfileString (si:make-string-chunk app)
                                     (si:make-string-chunk key)
                                     (si:make-string-chunk str)
                                     (si:make-string-chunk file)))

(defun chini-read-config-data-1 (section &optional config-path)
  (unless config-path
    (setq config-path (merge-pathnames "xyzzy.ini" (user-config-path))))
  (when (file-exist-p config-path)
    (let ((temp-buffer (create-new-buffer *chini-buffer-name-tmp*))
          alist)
      (unwind-protect
          (save-excursion
            (setup-temp-buffer temp-buffer)
            (set-buffer temp-buffer)
            (insert-file-contents config-path)
            (goto-char (point-min))
            (when (scan-buffer (format nil "^\\[~A\\]" section) :regexp t)
              (while (and (forward-line)
                          (not (looking-at "^\\[.+\\]")))
                (if (looking-at "^\\([^=\n]+\\)=\\(.*\\)$")
                    (push (cons (match-string 1) (match-string 2)) alist)))))
        (progn
          (delete-buffer temp-buffer)))
      (nreverse alist))))

(defun chini-read-config-data (section &optional config-path)
  (let (data)
    (unless (listp section)
      (setq section (list section)))
    (dolist (x section)
      (push (list x (chini-read-config-data-1 x config-path)) data))
    (nreverse data)))

(defun chini-write-config-data (data &optional config-path)
  (unless config-path
    (setq config-path (merge-pathnames "xyzzy.ini" (user-config-path))))
  (let (section key val)
    (dolist (x data)
      (setq section (car x))
      (setq x (cadr x))
      (dolist (key-val x)
        (chini-write-private-profile-string section (car key-val)
                                            (cdr key-val) config-path)))))

;; 一括ファンクション生成用
(defun chini-generate-function (setting)
  (let* ((sym (nth 0 setting))
         (display-name (nth 1 setting))
         (sections (nth 2 setting))
         (directory (nth 3 setting))
         (history (nth 4 setting))
         (popup-menu (nth 5 setting))
         (save-func
          (intern (concat "chini-save-" (symbol-name sym) "-setting")))
         (load-func
          (intern (concat "chini-load-" (symbol-name sym) "-setting")))
         (save-dialog-func
          (intern (concat "chini-save-" (symbol-name sym) "-setting-dialog")))
         (load-dialog-func
          (intern (concat "chini-load-" (symbol-name sym) "-setting-dialog")))
         (history-to-menu-func
          (intern (concat "chini-add-" (symbol-name sym) "-setting-history-to-menu")))
         (insert-menu-items-func
          (intern (concat "chini-" (symbol-name sym) "-insert-menu-items")))
         (delete-menu-func
          (intern (concat "chini-" (symbol-name sym) "-delete-menu")))
         (popup-menu-tag
          (intern (concat "chini-recent-" (symbol-name sym) "-setting-popup-menu")))
         (menu-sep-tag
          (intern (concat "chini-" (symbol-name sym) "-sep"))))
    (eval
     `(progn
        (export '(,save-func ,load-func ,save-dialog-func ,load-dialog-func
                  ,insert-menu-items-func))
        (defun ,save-func (file)
          (interactive "FFile: " :default0 ,directory)
          (when (valid-path-p file)
            (chini-write-config-data
             (chini-read-config-data (quote ,sections))
             file)
            (add-history file (quote ,history))
            (,history-to-menu-func)))
        (defun ,load-func (file)
          (interactive "fFile: " :default0 ,directory)
          (if (file-exist-p file)
              (progn
                (chini-write-config-data
                 (chini-read-config-data (quote ,sections) file))
                (add-history file (quote ,history))
                (,history-to-menu-func))
            (message "~A は存在しません。" file)))
        (defun ,save-dialog-func ()
          (interactive)
          (multiple-value-bind (file index encoding eol-code)
              (file-name-dialog :save t
                                :title ,(concat display-name "設定の保存")
                                :initial-directory ,directory
                                :filter '(("INIファイル(*.ini)" . "*.ini"))
                                :extension "ini"
                                :overwrite t
                                :hide-read-only t)
            (when file
              (,save-func file))))
        (defun ,load-dialog-func ()
          (interactive)
          (multiple-value-bind (file index encoding eol-code)
              (file-name-dialog :title ,(concat display-name "設定の読み込み")
                                :initial-directory ,directory
                                :filter '(("INIファイル(*.ini)" . "*.ini"))
                                :extension "ini"
                                :must-exist t)
            (when file
              (,load-func file))))
        (defun ,history-to-menu-func ()
          (unless (menup ,popup-menu)
            (setq ,popup-menu
                  (create-popup-menu (quote ,popup-menu-tag))))
          (add-lru-menu ,popup-menu
                        ,history
                        #'(lambda (filename)
                            #'(lambda ()
                                (interactive)
                                (,load-func filename)
                                (add-history filename (quote ,history))))))
        (defun ,insert-menu-items-func (&key menu pre-tag position head-sep tail-sep access-key)
          (,history-to-menu-func)
          (if (and (not (menup menu)) (menup *app-menu*))
              (setq menu (get-menu *app-menu* 'ed::file)))
          (when (menup menu)
            (,delete-menu-func menu)
            (when (and pre-tag
                       (setq position (get-menu-position menu pre-tag)))
              (incf position))
            (unless (and (numberp position) (integerp position) (not (minusp position))
                         (get-menu menu position t))
              (setq position -1)
              (while (get-menu menu (incf position) t)))
            (decf position)
            (if (and head-sep
                     (not (minusp position))
                     (get-menu menu position t))
                (insert-menu-separator menu (incf position) (quote ,menu-sep-tag)))
            (unless (characterp access-key)
              (setq access-key #\0))
            (insert-popup-menu menu (incf position)
                               ,popup-menu
                               (format nil "最近使った~A設定(&~C)" ,display-name access-key))
            (setq access-key (code-char (1+ (char-code access-key))))
            (insert-menu-item menu (incf position) (quote ,load-dialog-func)
                              (format nil "~A設定の読み込み(&~C)..." ,display-name access-key)
                              (quote ,load-dialog-func))
            (setq access-key (code-char (1+ (char-code access-key))))
            (insert-menu-item menu (incf position) (quote ,save-dialog-func)
                              (format nil "~A設定の保存(&~C)..." ,display-name access-key)
                              (quote ,save-dialog-func))
            (if (and tail-sep
                     (get-menu menu (incf position) t))
                (insert-menu-separator menu position (quote ,menu-sep-tag)))))

        (defun ,delete-menu-func (&optional menu)
          (if (and (not (menup menu)) (menup *app-menu*))
              (setq menu (get-menu *app-menu* 'ed::file)))
          (when (menup menu)
            (while (delete-menu menu (quote ,popup-menu-tag)))
            (while (delete-menu menu (quote ,load-dialog-func)))
            (while (delete-menu menu (quote ,save-dialog-func)))
            (while (delete-menu menu (quote ,menu-sep-tag)))))
        (when *chini-compile-function-p*
          (compile (quote ,save-func))
          (compile (quote ,load-func))
          (compile (quote ,save-dialog-func))
          (compile (quote ,load-dialog-func))
          (compile (quote ,history-to-menu-func))
          (compile (quote ,insert-menu-items-func))
          (compile (quote ,delete-menu-func)))
        (add-hook '*chini-uninstall-hook* (quote ,delete-menu-func))))))

;; 一括ファンクション生成
(dolist (setting *chini-setting-list*)
  (chini-generate-function setting))

;; xyzzy.ini バックアップ/リストア
(defun chini-backup-config-file (file)
  "chini: xyzzy.ini のバックアップ"
  (interactive "FFile: " :default0
    (merge-pathnames (concat "xyzzy-" (format-date-string "%Y%m%d_%H%M") ".ini")
                     *chini-backup-config-file-directory*))
  (let ((config-file (merge-pathnames "xyzzy.ini" (user-config-path))))
    (when (and (file-exist-p config-file)
               (valid-path-p file))
      (copy-file config-file file :if-exists :overwrite)
      (add-history file '*chini-backup-config-file-history*)
      (chini-add-backup-config-file-history-to-menu))))
(defun chini-restore-config-file (file)
  "chini: xyzzy.ini のリストア"
  (interactive "fFile: " :default0 *chini-backup-config-file-directory*)
  (let ((config-file (merge-pathnames "xyzzy.ini" (user-config-path))))
    (if (file-exist-p file)
        (progn
          (copy-file file config-file :if-exists :overwrite)
          (add-history file '*chini-backup-config-file-history*)
          (chini-add-backup-config-file-history-to-menu))
      (message "~A は存在しません。" file))))
(defun chini-backup-config-file-dialog ()
  "chini: xyzzy.ini のバックアップダイアログ"
  (interactive)
  (multiple-value-bind (file index encoding eol-code)
      (file-name-dialog :save t
                        :title "xyzzy.iniのバックアップ"
                        :initial-directory *chini-backup-config-file-directory*
                        :default (merge-pathnames (concat "xyzzy-" (format-date-string "%Y%m%d_%H%M") ".ini")
                                                  *chini-backup-config-file-directory*)
                        :filter '(("INIファイル(*.ini)" . "*.ini"))
                        :extension "ini"
                        :overwrite t
                        :hide-read-only t)
    (when file
      (chini-backup-config-file file))))
(defun chini-restore-config-file-dialog ()
  "chini: xyzzy.ini のリストアダイアログ"
  (interactive)
  (multiple-value-bind (file index encoding eol-code)
      (file-name-dialog :title "xyzzy.iniのリストア"
                        :initial-directory *chini-backup-config-file-directory*
                        :filter '(("INIファイル(*.ini)" . "*.ini"))
                        :extension "ini"
                        :must-exist t)
    (when file
      (chini-restore-config-file file))))
(defun chini-add-backup-config-file-history-to-menu ()
  (unless (menup *chini-recent-backup-config-file-popup-menu*)
    (setq *chini-recent-backup-config-file-popup-menu*
          (create-popup-menu 'chini-recent-backup-config-file-popup-menu)))
  (add-lru-menu *chini-recent-backup-config-file-popup-menu*
                *chini-backup-config-file-history*
                #'(lambda (filename)
                    #'(lambda ()
                        (interactive)
                        (chini-restore-config-file filename)
                        (add-history filename *chini-backup-config-file-history*)))))
(defun chini-backup-config-file-insert-menu-items (&key menu position head-sep tail-sep access-key)
  (chini-add-backup-config-file-history-to-menu)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::file)))
  (when (menup menu)
    (chini-backup-config-file-delete-menu)
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'chini-backup-config-file-sep))
    (unless (characterp access-key)
      (setq access-key #\0))
    (insert-popup-menu menu (incf position)
                       *chini-recent-backup-config-file-popup-menu*
                       (format nil "最近使った xyzzy.ini バックアップ(&~C)" access-key))
    (setq access-key (code-char (1+ (char-code access-key))))
    (insert-menu-item menu (incf position) 'chini-restore-config-file-dialog
                      (format nil "xyzzy.ini バックアップからの復旧(&~C)..." access-key)
                      'chini-restore-config-file-dialog)
    (setq access-key (code-char (1+ (char-code access-key))))
    (insert-menu-item menu (incf position) 'chini-backup-config-file-dialog
                      (format nil "xyzzy.ini のバックアップ(&~C)..." access-key)
                      'chini-backup-config-file-dialog)
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'chini-backup-config-file-sep))))
(defun chini-backup-config-file-delete-menu (&optional menu)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::file)))
  (when (menup menu)
    (while (delete-menu menu 'chini-recent-backup-config-file-popup-menu))
    (while (delete-menu menu 'chini-restore-config-file-dialog))
    (while (delete-menu menu 'chini-backup-config-file-dialog))
    (while (delete-menu menu 'chini-backup-config-file-sep))))

;;
(defun chini-create-popup-menu ()
  (let ((menu (create-popup-menu 'chini-menu))
        (access-key #\A))
    (chini-font-insert-menu-items :menu menu :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-color-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-print-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-filer-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-bufselector-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-misc-insert-menu-items :menu menu :head-sep t :access-key access-key)
    (setq access-key (code-char (+ (char-code access-key) 3)))
    (chini-backup-config-file-insert-menu-items :menu menu :head-sep t :access-key access-key)
    menu))

(defun chini-insert-menu-items (&key menu pre-tag position head-sep tail-sep access-key)
  (unless *chini-popup-menu*
    (setq *chini-popup-menu* (chini-create-popup-menu)))
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::tools)))
  (when (menup menu)
    (chini-delete-menu)
    (unless (or pre-tag position)
      (setq pre-tag :|(>_<)-popup|))
    (when (and pre-tag
               (setq position (get-menu-position menu pre-tag)))
      (incf position))
    (unless (and (numberp position) (integerp position) (not (minusp position))
                 (get-menu menu position t))
      (setq position -1)
      (while (get-menu menu (incf position) t)))
    (decf position)
    (if (and head-sep
             (not (minusp position))
             (get-menu menu position t))
        (insert-menu-separator menu (incf position) 'chini-sep))
    (unless (characterp access-key)
      (setq access-key #\0))
    (insert-popup-menu menu (incf position)
                       *chini-popup-menu*
                       (format nil "xyzzy.ini 設定変更(&~C)" access-key))
    (if (and tail-sep
             (get-menu menu (incf position) t))
        (insert-menu-separator menu position 'chini-sep))))
(defun chini-delete-menu (&optional menu)
  (if (and (not (menup menu)) (menup *app-menu*))
      (setq menu (get-menu *app-menu* 'ed::tools)))
  (when (menup menu)
    (while (delete-menu menu 'chini-menu))
    (while (delete-menu menu 'chini-sep))))

;; uninstall
(defun chini-uninstall ()
  (let ((history-variables
         '(*chini-font-setting-history*
           *chini-color-setting-history*
           *chini-print-setting-history*
           *chini-filer-setting-history*
           *chini-bufselector-setting-history*
           *chini-misc-setting-history*
           *chini-backup-config-file-history*)))
    (dolist (variable history-variables)
      (unregister-history-variable variable)))
  (run-hooks '*chini-uninstall-hook*))

;;
(add-hook '*init-app-menus-hook*
          #'(lambda ()
              (unless *chini-popup-menu*
                (setq *chini-popup-menu* (chini-create-popup-menu)))))

;;; chini.l ends here
