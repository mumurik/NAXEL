;;; diff-backup.l --- バックアップファイルとのdiffを表示

;; Author: rufein 
;; Created: 2008-03-15
;; Version: 0.0.2
;; Keywords: Text

;; Licence:
;; 
;; diff-backup.l は MIT license に基づいて利用可能です。
;; 
;; Copyright (C) 2008 rufein.
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

;;; Commentary:
;;
;; == 概要
;; バックアップファイルとのdiffを表示します。
;; 
;; バックアップをとる設定になっていなければ意味のない拡張です。
;; 使用される場合は、ツール -> 共通設定 -> バックアップファイル で、
;; バックアップファイルをつくる にチェックを入れてください。
;;
;; === 注意点
;; 以下の場合しか確認していません。
;; (1) バックアップファイルがオリジナルのファイルと同じディレクトリに作成される場合(*backup-directory* が nil の場合)
;;     "バックアップファイルをつくる"以外はデフォルトのままならこちらにあてはまるはずです。
;; (2) バックアップディレクトリを以下のように設定している場合
;;       (require "backup")
;;       (setq *backup-directory* "C:/path/to/backup")
;;       (setq *hierarchic-backup-directory* t)
;;     *backup-directory* にリストを設定したり、"/"を含まない設定にしている、もしくは、
;;     *hierarchic-backup-directory* が nil になっている場合は未確認です。
;; 
;; 
;; == インストール
;; NetInstallerでインストールした場合は(1),(2)は必要ありません。
;; 
;; (1) diff-backup.lzhをダウンロードして展開し、diff-backup.lをsite-lisp以下に保存してください。
;; (2) .xyzzy に
;;     (require "diff-backup")
;;     としてください。
;; (3) キーバインドを設定する場合は
;;     (global-set-key #\S-#\F10 'diff-backup)
;;     などとしてください。(Shift+F10 に割り当てる場合)
;;
;; == 使用方法
;; バックアップファイルとのdiffをとりたいバッファを選択して、
;;  M-x diff-backup
;; としてください。
;; 
;; もしくはキーバインドを設定して実行してください。
;; 
;; デフォルトでは最新(1世代前)のバックアップファイルとのdiffを表示しますが、
;;   C-u 2 diff-backup
;; とすると、2世代前のバックアップファイルとのdiffを表示します。
;;

;;; Change log:
;; * 2008-03-15  ver 0.0.1
;;   *  作成
;; * 2008-03-20  ver 0.0.2
;;   * diff-backupの引数を変更
;;   * バックアップファイル名の検索の正規表現を修正
;;   * NetInstaller対応
;;

;;; Code:

(provide "diff-backup")

(in-package "editor")
(require "diff")
(require "backup")

(export
 '(diff-backup))

(defun diff-backup (&optional (count 1))
  "バックアップファイルとのdiffを表示"
  (interactive "p")
  (let* ((original (get-buffer-file-name (selected-buffer)))
	 (backup (get-backup-file-name original count)))
    (unless backup
      (error "バックアップファイルがありません。"))
    (diff original
	  backup)))

(defun get-backup-file-name (file-absolute-path-name count)
  "バックアップファイルのパスを返す。
file-absolute-path-name はオリジナルのファイルの絶対パス名。
count に何世代前のものかを指定する。"
  ;  (car (list-backup-files (get-backup-base-file-name file-absolute-path-name))))
  (let ((backup-files (list-backup-files (get-backup-base-file-name file-absolute-path-name)))
	(backup))
    (and (> count 0)
	 (<= count (length backup-files))
	 (setf backup (nth (- count 1) backup-files)))
    backup))

(defun list-backup-files (base-file-name)
  "バックアップファイルの一覧をリストで取得する。
base-file-nameはバックアップファイル名の基となるファイル名。(絶対パス)
C:/original/foo.txt のバックアップファイルの一覧を取得するには、
C:/path/to/backup/C/original/foo.txt というパスを渡す必要がある。"
  (let* ((directory-name (directory-namestring base-file-name))
	 (backup-files (directory directory-name :absolute t :recursive nil :file-only t )))
    (sort
     (remove-if-not #'(lambda (x)
			(string-match (format nil "^~A\.??[0-9]*~~$" base-file-name) x))
		    backup-files)
     #'file-newer-than-file-p)))

(defun get-backup-base-file-name (file-absolute-path-name)
  "バックアップファイル名の基となるファイル名を取得する。
file-absolute-path-name はオリジナルのファイルの絶対パス名。"
  (if *backup-directory*
      (merge-pathnames
       (substitute-string file-absolute-path-name ":" "")
       *backup-directory*)
    file-absolute-path-name))

;;; diff-backup.l ends here
