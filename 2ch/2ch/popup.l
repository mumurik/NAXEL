; $Id: popup.l 3 2003-01-25 20:35:51Z torihat $

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require "2ch/macro"))

(provide "2ch/popup")

(in-package "2ch")

(defvar *popup-menu-list*
  '((2ch-menu popup-buffer-menu nil)
    (2ch-board popup-buffer-board nil)
    (2ch-search popup-buffer-search nil)
    (2ch-tracking popup-buffer-tracking nil)
    (2ch-thread popup-buffer-thread nil)
    (2ch-view popup-buffer-view nil)
    (2ch-grep popup-buffer-grep nil)
    (2ch-bookmark popup-buffer-bookmark nil)
    (2ch-history popup-buffer-history nil)
    (2ch-form popup-buffer-form nil)
    (2ch-form-new popup-buffer-form-new nil)
    (2ch-http popup-buffer-http nil)))

(defun 2ch-mouse-right-press ()
  (interactive)
  (set-window *last-mouse-window*)
  (continue-pre-selection)
  (goto-last-mouse-point)
  ;(refresh-screen)
  (popup-menu-popup))

(defun thread-popup ()
  (interactive)
  (set-window *last-mouse-window*)
  (continue-pre-selection)
  (goto-last-mouse-point)
  (refresh-screen)
  (let ((menu (thread-popup-menu)))
    (when menu
      (track-popup-menu menu))))

(defun thread-popup-menu ()
  (let* ((attr (multiple-value-list (find-text-attribute-point (point))))
	 (number (thread-current-number))
	 (type (attr-tag attr))
	 (menu (popup-menu))
	 pos)
    (unless menu
      (return-from thread-popup-menu))
    (while (delete-menu menu 'thread-history))
    (while (delete-menu menu 'thread-aborn))
    (while (delete-menu menu 'thread-attr))
    (while (delete-menu menu 'thread-link))
    (while (delete-menu menu 'thread-anchor))
    (setq pos (get-menu-position menu 'thread-update))
    (unless pos
      (return-from thread-popup-menu menu))
    (when *thread-history*
      (insert-menu-item menu pos 'thread-history
			"戻る"
			'thread-history-back)
      (incf pos)
      (insert-menu-separator menu pos 'thread-history)
      (incf pos))
    (when number
      (let ((aborn-p (thread-aborn-p number)))
	(insert-menu-item menu pos 'thread-aborn
			  "あぼーん"
			  'thread-aborn-add
			  #'(lambda () (and aborn-p :disable)))
	(incf pos)
	(insert-menu-item menu pos 'thread-aborn
			  "あぼーん解除"
			  'thread-aborn-del
			  #'(lambda () (or aborn-p :disable)))
	(incf pos)
	(insert-menu-separator menu pos 'thread-attr)
	(incf pos)))
    (cond ((eq type 'anchor)
	   (insert-popup-menu menu pos (popup-menu-anchor) "番号の発言")
	   (insert-menu-separator menu (1+ pos) 'thread-attr))
	  ((eq type 'link)
	   (insert-popup-menu menu pos (popup-menu-link) "このURLを")
	   (insert-menu-separator menu (1+ pos) 'thread-attr))
    )
    menu))

(defun popup-menu-anchor ()
  (let ((menu (create-popup-menu 'thread-anchor)))
    (add-menu-item menu nil "へジャンプ"
		   'thread-jump)
    (add-menu-item menu nil "をポップアップ"
		   'thread-anchor-popup)
    (add-menu-item menu nil "をダイアログ表示"
		   'thread-anchor-popup-msgbox)
    menu))

(defun popup-menu-link ()
  (let ((menu (create-popup-menu 'thread-link)))
    (add-menu-item menu nil "開く"
		   'thread-jump)
    (add-menu-item menu nil "ブラウザで開く"
		   'thread-jump-in-browser)
    (add-menu-item menu nil "コピー"
		   'thread-link-copy)
    menu))

(defun popup-menu-popup ()
  (let ((menu (popup-menu)))
    (unless menu
      (return-from popup-menu-popup))
    (track-popup-menu menu)))

(defun popup-menu (&optional force)
  (let ((menu (popup-menu-menu (popup-menu-list buffer-mode)))
	func)
    (when (or force
	      (not menu))
      (when (setq func (popup-menu-func (popup-menu-list buffer-mode)))
	(setq menu (funcall func))
	(setf (popup-menu-menu (popup-menu-list buffer-mode)) menu)))
    (or menu *app-popup-menu*)))

(defun popup-menu-add (menu)
  (add-menu-separator menu nil)
  (add-popup-menu menu *app-popup-menu* "その他")
  (add-menu-separator menu nil)
  (add-popup-menu menu (popup-menu-bookmark) "ブックマーク")
  (add-popup-menu menu (popup-menu-history) "履歴")
  (add-menu-separator menu nil)
  (add-menu-item menu nil
		 "...について"
		 'version)
  (add-menu-item menu nil "2chトップページ"
		 'open-browser-index)
  (add-menu-separator menu nil)
  (add-menu-item menu nil "スレをクリーンアップ"
		 'thread-clean-dat)
  (add-menu-item menu nil "オンラインモード"
		 'toggle-online
		 #'(lambda () (when *online* :check)))
  (add-menu-item menu nil "終了"
		 'exit)
  menu)

(defun popup-menu-bookmark ()
  (let ((menu (create-popup-menu '2ch-bookmark)))
    (add-menu-item menu nil "開く"
		   'bookmark-open
		   #'(lambda () (unless *bookmark-list* :disable)))
    (add-menu-separator menu nil)
    (add-menu-item menu nil "進む"
		   'bookmark-next
		   #'(lambda () (unless *bookmark-list* :disable)))
    (add-menu-item menu nil "戻る"
		   'bookmark-previous
		   #'(lambda () (unless *bookmark-list* :disable)))
    menu))

(defun popup-menu-history ()
  (let ((menu (create-popup-menu '2ch-history)))
    (add-menu-item menu nil "開く"
		   'history-open
		   #'(lambda () (unless (or *history-back* *history-forward*) :disable)))
    (add-menu-separator menu nil)
    (add-menu-item menu nil "進む"
		   'history-next
		   #'(lambda () (unless *history-forward* :disable)))
    (add-menu-item menu nil "戻る"
		   'history-previous
		   #'(lambda () (unless *history-back* :disable)))
    menu))

(defun popup-buffer-menu ()
  (let ((menu (create-popup-menu '2ch-menu)))
    (add-menu-item menu nil "選択"
		   'menu-select)
    (add-menu-item menu nil "カテゴリへ戻る"
		   'menu-back-category)
    (add-menu-item menu nil "カテゴリを開く"
		   'menu-category-open)
    (add-menu-item menu nil "カテゴリを閉じる"
		   'menu-category-close)
    (add-menu-item menu nil "板リストを更新"
		   'menu-update)
    (add-menu-item menu nil "板リストを再読込"
		   'menu-reload)
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "~Aグループを巡回更新" *tracking-name*)
		   'menu-tracking-update)
    (add-menu-item menu nil (format nil "~Aを巡回更新" *tracking-name*)
		   'tracking-update-full)
    (add-menu-item menu nil "更新されたスレを一覧表示"
		   'tracking-show-updated
		   #'(lambda () (unless *tracking-uplist* :disable)))
    (add-menu-item menu nil "次の更新されたスレを開く"
		   'menu-tracking-uplist-next
		   #'(lambda () (unless *tracking-uplist* :disable)))
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "~Aのグループを追加" *tracking-name*)
		   'menu-tracking-add)
    (add-menu-item menu nil (format nil "~Aに板を追加" *favorits-name*)
		   'menu-favorits-add)
    (add-menu-item menu nil (format nil "~AにURLから追加" *favorits-name*)
		   'favorits-add-from-url)
    (add-menu-item menu nil (format nil "グループを削除")
		   'menu-del)
    (add-menu-item menu nil (format nil "~Aの板を切り取り" *favorits-name*)
		   'menu-cut)
    (add-menu-item menu nil (format nil "~Aに板を貼り付け" *favorits-name*)
		   'menu-paste)
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "~Aのスレ一覧を更新" *favorits-name*)
		   'favorits-update)
    (add-menu-item menu nil "カテゴリのスレ一覧を更新"
		   'menu-category-board-update)
    (add-menu-item menu nil "全板のスレ一覧を更新"
		   'menu-category-board-update-all)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "カテゴリを全て開く"
		   'menu-category-open-all)
    (add-menu-item menu nil "カテゴリを全て閉じる"
		   'menu-category-close-all)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "板をブラウザで開く"
		   'menu-board-open-browser)
    (add-menu-item menu nil "板のURLをコピー"
		   'menu-board-url-copy)
    (add-menu-item menu nil "板名をコピー"
		   'menu-board-name-copy)
    (add-menu-item menu nil "板名とURLをコピー"
		   'menu-board-url-name-copy)
    (add-menu-item menu nil "この板について..."
		   'menu-board-rule)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-buffer-menu-search) "スレタイトル検索")
    (setq menu (popup-menu-add menu))
    menu))

(defun popup-buffer-menu-search ()
  (let ((menu (create-popup-menu '2ch-menu-search)))
    (add-menu-item menu nil "全検索"
		   'menu-all-search)
    (add-menu-item menu nil "全検索+更新"
		   'menu-all-search-reload)
    (add-menu-item menu nil "全検索+取得"
		   'menu-all-search-force)
    (add-menu-item menu nil "全検索+取得+更新"
		   'menu-all-search-force-reload)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "カテゴリ検索"
		   'menu-category-search)
    (add-menu-item menu nil "カテゴリ検索+更新"
		   'menu-category-search-reload)
    (add-menu-item menu nil "カテゴリ検索+取得"
		   'menu-category-search-force)
    (add-menu-item menu nil "カテゴリ検索+取得+更新"
		   'menu-category-search-force-reload)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "板検索"
		   'menu-board-search)
    menu))

(defun popup-buffer-board ()
  (let ((menu (create-popup-menu '2ch-menu-board)))
    (add-menu-item menu nil "スレを開く"
		   'board-select)
    (add-menu-item menu nil "スレを開く(件数指定)"
		   'board-select-lines)
    (add-menu-item menu nil (format nil "スレを~Aに追加" *tracking-name*)
		   'board-tracking-add-dialog)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "板をブラウザで開く"
		   'board-open-browser)
    (add-menu-item menu nil "板のURLをコピー"
		   'board-url-copy)
    (add-menu-item menu nil "板名をコピー"
		   'board-name-copy)
    (add-menu-item menu nil "板名とURLをコピー"
		   'board-url-name-copy)
    (add-menu-item menu nil "この板について..."
		   'board-rule)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレをブラウザで開く"
		   'tracking-thread-open-browser)
    (add-menu-item menu nil "スレのURLをコピー"
		   'tracking-thread-url-copy)
    (add-menu-item menu nil "スレタイトルをコピー"
		   'tracking-thread-title-copy)
    (add-menu-item menu nil "スレタイトルとURLをコピー"
		   'tracking-thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレ一覧を更新"
		   'board-update)
    (add-menu-item menu nil "スレ一覧を再読み込み"
		   'board-reload)
;    (add-menu-separator menu nil)
;    (add-menu-item menu nil "新スレをたてる"
;		   'board-form)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレデータを削除"
		   'tracking-thread-delete-dat)
    (add-menu-item menu nil "スレデータを削除（完全）"
		   'tracking-thread-delete-dat-tbk)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレタイトル検索..."
		   'board-search)
    (add-menu-item menu nil "板内検索..."
		   'board-grep-dialog)
    (add-menu-item menu nil "既得スレ一覧"
		   'board-show-read-dat)
    (add-menu-item menu nil "既得スレ一覧（過去ログも）"
		   'board-show-read-dat-kako)
    (add-menu-item menu nil "..日間の新スレ一覧"
		   'board-new-show)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-menu-mark-set) "マークを付ける")
    (add-popup-menu menu (popup-menu-mark-unset) "マークを外す")
    (add-popup-menu menu (popup-menu-mark-cmd-search) "マークしたスレを")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'board-close)
    (popup-menu-add menu)))

(defun popup-buffer-tracking ()
  (let ((menu (create-popup-menu '2ch-menu-tracking)))
    (add-menu-item menu nil "スレを開く"
		   'tracking-select)
    (add-menu-item menu nil "次の更新スレを開く"
		   'tracking-next-updated)
    (add-menu-item menu nil "元の板でスレを開く"
		   'tracking-open-in-board)
    (add-menu-item menu nil "スレを削除"
		   'tracking-del)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレをブラウザで開く"
		   'tracking-thread-open-browser)
    (add-menu-item menu nil "スレのURLをコピー"
		   'tracking-thread-url-copy)
    (add-menu-item menu nil "スレタイトルをコピー"
		   'tracking-thread-title-copy)
    (add-menu-item menu nil "スレタイトルとURLをコピー"
		   'tracking-thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレ一覧を更新"
		   'tracking-reload)
    (add-menu-item menu nil "このスレを更新"
		   'tracking-update-current)
    (add-menu-item menu nil "スレを全て更新"
		   'tracking-update-all)
    (add-menu-item menu nil "スレを並び替え"
		   'tracking-sort-dialog)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレを過去ログにする"
		   'tracking-change-kako)
    (add-menu-item menu nil "スレを通常ログにする"
		   'tracking-change-dat)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレを切り取り"
		   'tracking-cut)
    (add-menu-item menu nil "スレをコピー"
		   'tracking-copy)
    (add-menu-item menu nil "スレを貼り付け"
		   'tracking-paste)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-menu-mark-set) "マークを付ける")
    (add-popup-menu menu (popup-menu-mark-unset) "マークを外す")
    (add-popup-menu menu (popup-menu-mark-cmd) "マークしたスレを")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレデータを削除"
		   'tracking-thread-delete-dat)
    (add-menu-item menu nil "スレデータを削除（完全）"
		   'tracking-thread-delete-dat-tbk)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'tracking-quit)
    (popup-menu-add menu)))

(defun popup-menu-mark-set ()
  (let ((menu (create-popup-menu '2ch-menu-mark-set)))
    (add-menu-item menu nil "これ"
		   'tracking-mark-set)
    (add-menu-item menu nil "全て"
		   'tracking-mark-set-all)
    (add-menu-item menu nil "反転"
		   'tracking-mark-set-reverse)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "過去ログ"
		   'tracking-mark-set-kako)
    (add-menu-item menu nil "追っかけスレ"
		   'tracking-mark-set-tracking)
    (add-menu-item menu nil "追っかけスレ以外"
		   'tracking-mark-set-tracking-reverse)
    (add-menu-item menu nil "更新がないスレ..."
		   'tracking-mark-set-old)
    (add-menu-item menu nil "開いていないスレ..."
		   'tracking-mark-set-nouse)
    (add-menu-item menu nil "正規表現..."
		   'tracking-mark-set-query)
    menu))

(defun popup-menu-mark-unset ()
  (let ((menu (create-popup-menu '2ch-menu-mark-unset)))
    (add-menu-item menu nil "これ"
		   'tracking-mark-unset
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "全て"
		   'tracking-mark-unset-all
		   #'(lambda () (unless board-mark :disable)))
    menu))

(defun popup-menu-mark-cmd ()
  (let ((menu (create-popup-menu '2ch-menu-cmd)))
    (add-menu-item menu nil "一覧から削除"
		   'tracking-del-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "切り取り"
		   'tracking-cut-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "コピー"
		   'tracking-copy-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "送る..."
		   'tracking-send-marked-dialog
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "更新"
		   'tracking-update-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "スレデータを削除"
		   'tracking-thread-delete-marked-dat
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "スレデータを削除（完全）"
		   'tracking-thread-delete-marked-dat-tbk
		   #'(lambda () (unless board-mark :disable)))
    menu))

(defun popup-menu-mark-cmd-search ()
  (let ((menu (create-popup-menu '2ch-menu-cmd)))
    (add-menu-item menu nil "コピー"
		   'tracking-copy-marked
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "送る..."
		   'search-send-marked-dialog
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "スレデータを削除"
		   'tracking-thread-delete-marked-dat
		   #'(lambda () (unless board-mark :disable)))
    (add-menu-item menu nil "スレデータを削除（完全）"
		   'tracking-thread-delete-marked-dat-tbk
		   #'(lambda () (unless board-mark :disable)))
    menu))

(defun popup-buffer-search ()
  (let ((menu (create-popup-menu '2ch-menu-search)))
    (add-menu-item menu nil "スレを開く"
		   'search-select)
    (add-menu-item menu nil "スレを開く(件数指定)"
		   'search-select-lines)
    (add-menu-item menu nil (format nil "スレを~Aに追加" *tracking-name*)
		   'board-tracking-add-dialog)
    (add-menu-item menu nil (format nil "一覧を~Aとして保存" *tracking-name*)
		   'search-save-as-tracking)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレをブラウザで開く"
		   'tracking-thread-open-browser)
    (add-menu-item menu nil "スレのURLをコピー"
		   'tracking-thread-url-copy)
    (add-menu-item menu nil "スレタイトルをコピー"
		   'tracking-thread-title-copy)
    (add-menu-item menu nil "スレタイトルとURLをコピー"
		   'tracking-thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレデータを削除"
		   'tracking-thread-delete-dat)
    (add-menu-item menu nil "スレデータを削除（完全）"
		   'tracking-thread-delete-dat-tbk)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-menu-mark-set) "マークを付ける")
    (add-popup-menu menu (popup-menu-mark-unset) "マークを外す")
    (add-popup-menu menu (popup-menu-mark-cmd-search) "マークしたスレを")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'board-close)
    (popup-menu-add menu)))

(defun popup-buffer-thread ()
  (let ((menu (create-popup-menu '2ch-menu-thread)))
    (add-menu-item menu 'thread-update "スレを更新"
		   'thread-update)
    (add-menu-item menu nil "スレを再読み込み"
		   'thread-reload)
    (add-menu-separator menu nil)
    (add-popup-menu menu (popup-thread-move) "移動")
    (add-menu-separator menu nil)
    (add-menu-item menu nil "記事をダイアログで開く"
		   'thread-view-current)
    (add-menu-item menu nil "記事をダイアログで開く(範囲指定)"
		   'thread-view-range)
    (add-menu-item menu nil "記事をブラウザで開く"
		   'thread-view-current-in-browser)
    (add-menu-item menu nil "記事をブラウザで開く(範囲指定)"
		   'thread-view-range-in-browser)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "発言"
		   'thread-form)
    (add-menu-item menu nil "返信"
		   'thread-reply)
    (add-menu-item menu nil "まとめて返信"
		   'thread-reply-range)
    (add-menu-item menu nil "書き込みを表示"
		   'view-show)
    (add-menu-separator menu nil)
    (add-menu-item menu nil (format nil "スレを~Aに追加" *tracking-name*)
		   'thread-tracking-add-dialog)
    (add-menu-item menu nil "スレのURLをコピー"
		   'thread-url-copy)
    (add-menu-item menu nil "スレタイトルをコピー"
		   'thread-title-copy)
    (add-menu-item menu nil "スレタイトルとURLをコピー"
		   'thread-url-title-copy)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレをブラウザで開く"
		   'thread-open-browser)
    (add-menu-item menu nil "スレをURLで指定"
		   'thread-open-2ch-url)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "ポップアップモード"
		   'thread-popup-mode
		   #'(lambda () (when *thread-popup-mode* :check)))
    (add-menu-item menu nil "この板について..."
		   'thread-board-rule)
    (add-menu-item menu nil "閉じる"
		   'thread-quit)
    (popup-menu-add menu)))

(defun popup-thread-move ()
  (let ((menu (create-popup-menu 'thread-move)))
    (add-menu-item menu nil "次ページ"
		   'thread-next-page)
    (add-menu-item menu nil "前ページ"
		   'thread-previous-page)
    (add-menu-item menu nil "次の発言"
		   'thread-next-article)
    (add-menu-item menu nil "前の発言"
		   'thread-previous-article)
    (add-menu-item menu nil "次のタグ"
		   'thread-next-tag)
    (add-menu-item menu nil "前のタグ"
		   'thread-previous-tag)
    (add-menu-item menu nil "番号へジャンプ"
		   'thread-goto)
    menu))

(defun popup-buffer-view ()
  (let ((menu (create-popup-menu '2ch-menu-view)))
    (add-menu-item menu 'view-update "表示を更新"
		   'view-update)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "ジャンプ"
		   'view-jump)
    (add-menu-item menu nil "戻る"
		   'thread-history-back)
    (add-menu-item menu nil "発言のスレを開く"
		   'view-open-thread)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "次ページ"
		   'next-page)
    (add-menu-item menu nil "前ページ"
		   'previous-page)
    (add-menu-item menu nil "次の発言"
		   'view-next-article)
    (add-menu-item menu nil "前の発言"
		   'view-previous-article)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "発言を削除"
		   'view-delete-current)
    (add-menu-item menu nil "発言をフォームで開く"
		   'view-create-form)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'view-quit)
    (popup-menu-add menu)))

(defun popup-buffer-grep ()
  (let ((menu (create-popup-menu '2ch-menu-grep)))
    (add-menu-item menu nil "ジャンプ"
		   'grep-jump)
    (add-menu-item menu nil "発言のスレを開く"
		   'grep-open-thread)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "次ページ"
		   'next-page)
    (add-menu-item menu nil "前ページ"
		   'previous-page)
    (add-menu-item menu nil "次の発言"
		   'view-next-article)
    (add-menu-item menu nil "前の発言"
		   'view-previous-article)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "次のマッチ"
		   'grep-next-match)
    (add-menu-item menu nil "前のマッチ"
		   'grep-previous-match)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'grep-quit)
    (popup-menu-add menu)))

(defun popup-buffer-form ()
  (let ((menu (create-popup-menu '2ch-menu-form)))
    (add-menu-item menu nil "発言を送信"
		   'form-post)
    (add-menu-item menu nil "発言をsage送信"
		   'form-post-sage)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "発言を保存"
		   'form-save)
    (add-menu-item menu nil "前の発言"
		   'form-article-saved-previous)
    (add-menu-item menu nil "次の発言"
		   'form-article-saved-next)
    (add-menu-item menu nil "発言を削除"
		   'form-article-current-del)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "sageにする"
		   'form-sage)
    (add-menu-item menu nil "名前を選ぶ"
		   'popup-form-name-menu)
    (add-menu-item menu nil "メールを選ぶ"
		   'popup-form-addr-menu)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "名前を登録"
		   'form-name-add)
    (add-menu-item menu nil "メールを登録"
		   'form-addr-add)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "引用記号付きyank"
		   'form-cite-yank)
    (add-menu-item menu nil "引用記号付き貼り付け"
		   'form-cite-paste)
    (add-menu-item menu nil "スペースを変換"
		   'form-body-convert)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレへ戻る"
		   'form-back)
    (add-menu-item menu nil "この板について..."
		   'form-board-rule)
    (add-menu-item menu nil "閉じる"
		   'form-delete)
    (popup-menu-add menu)))

(defun popup-buffer-form-new ()
  (let ((menu (create-popup-menu '2ch-menu-form-new)))
    (add-menu-item menu nil "発言を送信"
		   'form-post-new)
    (add-menu-item menu nil "発言をsage送信"
		   'form-post-new-sage)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "発言を保存"
		   'form-save-new)
    (add-menu-item menu nil "前の発言"
		   'form-article-saved-new-previous)
    (add-menu-item menu nil "次の発言"
		   'form-article-saved-new-next)
    (add-menu-item menu nil "発言を削除"
		   'form-article-current-del-new)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "sageにする"
		   'form-sage)
    (add-menu-item menu nil "名前を選ぶ"
		   'popup-form-name-menu)
    (add-menu-item menu nil "メールを選ぶ"
		   'popup-form-addr-menu)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "名前を登録"
		   'form-name-add)
    (add-menu-item menu nil "メールを登録"
		   'form-addr-add)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "引用記号付きyank"
		   'form-cite-yank)
    (add-menu-item menu nil "引用記号付き貼り付け"
		   'form-cite-paste)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "スレへ戻る"
		   'form-back)
    (add-menu-item menu nil "閉じる"
		   'form-delete)
    (popup-menu-add menu)))

(defun popup-buffer-http ()
  (let ((menu (create-popup-menu '2ch-menu-http)))
    (add-menu-item menu nil "ヘッダを表示"
		   'http-show-status)
    (add-menu-item menu nil "閉じる"
		   'http-quit)
    (popup-menu-add menu)))

(defun popup-buffer-bookmark ()
  (let ((menu (create-popup-menu '2ch-menu-bookmark)))
    (add-menu-item menu nil "ブックマークへジャンプ"
		   'bookmark-select)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "ブックマークを削除"
		   'bookmark-delete)
    (add-menu-item menu nil "ブックマークを切り取り"
		   'bookmark-cut)
    (add-menu-item menu nil "ブックマークを貼り付け"
		   'bookmark-paste)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'bookmark-quit)
    (popup-menu-add menu)))

(defun popup-buffer-history ()
  (let ((menu (create-popup-menu '2ch-menu-history)))
    (add-menu-item menu nil "ジャンプ"
		   'history-select)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "この履歴を削除"
		   'history-delete)
    (add-menu-item menu nil "履歴をクリアー"
		   'history-clear)
    (add-menu-separator menu nil)
    (add-menu-item menu nil "閉じる"
		   'bookmark-quit)
    (popup-menu-add menu)))
