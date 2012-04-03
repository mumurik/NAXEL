;;; -*- Mode: Lisp -*-
;;  menu:
;;; Author:        amefura <amefura@gmail.com>
;;; License:       menu is released under an MIT license.
;;                 See anything/doc/mit-license for full license.
;;; Code:
(in-package :user)

;; migemo の恩恵でメニューなんかも意外といけた

(defvar *anything-menu*
  '(("共通設定(&C)..." . option-property-sheet)
    ("ローカル設定(&L)..." . local-option-property-sheet)
    ("新規作成(&N)" . new-file)
    ("開く(&O)..." . open-file-dialog)
    ("名前を付けて保存(&A)..." . save-as-dialog)
    ("ファイルの挿入(&I)..." . insert-file-dialog)
    ("名前の変更(&R)..." . rename-dialog)
    ("全て保存(&V)" . save-all-buffers)
    ("セッションを開く(&D)..." . open-session-dialog)
    ("セッションの保存(&W)..." . save-session-dialog)
    ("セッションを閉じる(&Y)" . close-session-dialog)
    ("印刷(&P)..." . print-selected-buffer-dialog)
    ("検索(&F)..." . search-dialog)
    ("置換(&R)..." . replace-dialog)
    ("一致する文字列を数える(&C)..." . count-matches-dialog)
    ("最初のタグ(&I)" . first-error)
    ("次のタグ(&E)" .  next-error)
    ("指定行(&J)..." . goto-line-dialog)
    ("マーク(&M)..." . mark-dialog-box)
    ("Gresreg(&S)..." . gresreg-dialog)
    ("Grep(&G)..." . grep-dialog)
    ("新しいフレーム(&F)" . new-pseudo-frame)
    ("現在のフレームを閉じる(&D)" . delete-pseudo-frame)
    ("横に分割(&S)" . split-window)
    ("縦に分割(&V)" . split-window-vertically)
    ("他のウィンドウを閉じる(&O)" . delete-other-windows)
    ("現在のウィンドウを閉じる(&C)" . delete-window)
    ("次のウィンドウ(&N)" . other-window)
    ("前のウィンドウ(&P)" . move-previous-window)
    ("バッファ選択(&B)..." . select-buffer)
    ("コンソールプログラムを非同期で実行(&A)..." .  execute-subprocess-dialog)
    ("非同期プログラムを死なす(&K)" . kill-subprocess)
    ("コンソールプログラムの実行(&P)..." . pipe-command-dialog)
    ("キーボードマクロ記録開始(&S)" . start-kbd-macro)
    ("キーボードマクロ記録終了(&E)" . end-kbd-macro)
    ("キーボードマクロ実行(&X)" . call-last-kbd-macro)
    ("罫線モード(&R)" . box-drawings-mode)
    ("日付と時刻の挿入(&M)..." . insert-date-string)
    ("ファイラ(&F)..." . open-filer)
    ("TAGSファイルの作成(&G)..." . make-tags-file-dialog)
    ("タグジャンプ(&J)" .  jump-tag)
    ("ダイレクトタグジャンプ(&U)" . direct-tag-jump)
    ("バックタグジャンプ(&B)" . back-tag-jump)
    ("キー割り当て一覧(&K)" . describe-bindings)
    ("最近入力したキー(&L)" . view-lossage)
    ("について(&A)..." . about-dialog)
    ("辞書引きモード(&D)" . edict-mode)
    ))

(add-anything-sources
 :name "XYZZY MENU"
 :candidates (lambda()(mapcar 'car *anything-menu*))
 :action (lambda(m)(command-execute (cdr(assoc m *anything-menu* :test 'equal)))))

(provide :anything/menu)
;;end
